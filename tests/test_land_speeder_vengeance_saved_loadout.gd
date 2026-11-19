extends SceneTree

const F = preload("res://tests/all_units_fixture.gd")
const Catalog = preload("res://scripts/edition_11/army_capabilities.gd")
const ArmyRoster = preload("res://scripts/army_roster.gd")
const TrainingRoster = preload("res://scripts/edition_11/training_roster.gd")
const BuilderPanel = preload("res://scripts/army_builder_panel.gd")
const MainSceneScript = preload("res://scripts/main.gd")
const PublicUnitCommand = preload("res://tests/public_unit_command.gd")
const UNIT_ID := "40kdc:11e:adeptus-astartes:land-speeder-vengeance"

var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func action_choices(state: Dictionary, model_id: int, target_id: int) -> Array:
	var result: Array = []
	for option: Dictionary in F.C.UnitActions.choices(state, 1):
		if str(option.get("action", "")) == "land-speeder-vengeance-cannon" and int(option.get("model", -1)) == model_id and int(option.get("target", -1)) == target_id: result.append(option)
	return result

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var summary_state := {
		"saved_army_setup": {"armies": {1: {}}},
		"squads": {
			1: {"owner": 1, "name": "Land Speeder"},
			2: {"owner": 1, "name": "Vengeance"},
		},
		"units": {
			101: {"squad": 1, "land_speeder_loadout_locked": true, "land_speeder_pyrecannon": true},
			102: {"squad": 2, "land_speeder_vengeance_loadout_locked": true, "land_speeder_vengeance_assault_cannon": true},
		},
	}
	var readiness_summary: String = MainSceneScript._saved_roster_equipment_status_for_state(summary_state, 1)
	check(readiness_summary.contains("Land Speeder · 1 Pyrecannon") and readiness_summary.contains("Vengeance · 1 Assault Cannon"), "Battle readiness reports saved Land Speeder cannon choices")

	var unit := Catalog.current_catalog_choice({"id": UNIT_ID, "edition": "11e", "faction": "Space Marines"})
	unit.role = ArmyRoster.role(unit.get("keywords", []))
	var source_list := ArmyRoster.new_list("11e", "Space Marines", "custom", 3000)
	var entry: Dictionary = ArmyRoster.entry(unit, 0, 2)
	ArmyRoster.set_model_equipment(entry, 0, 0, "land_speeder_vengeance_cannon", "assault-cannon")
	source_list.entries.append(entry)
	var admitted := TrainingRoster.inspect(source_list, {}, true)
	var canonical_choices: Array[String] = []
	if admitted.get("error", "").is_empty():
		for canonical_entry: Dictionary in admitted.selection.entries:
			for cannon: Variant in canonical_entry.get("land_speeder_vengeance_loadouts", []): canonical_choices.append(str(cannon))
	canonical_choices.sort()
	check(ArmyRoster.validate(source_list).is_empty() and admitted.get("error", "").is_empty() and canonical_choices == ["assault-cannon", "heavy-bolter"], "Local admission preserves different source-listed Vengeance cannons on separate copies")
	var stable_refs := TrainingRoster.stable_model_refs(source_list, admitted.get("selection", {})) if admitted.get("error", "").is_empty() else {"error": "Saved-list admission failed."}
	check(stable_refs.get("error", "").is_empty() and stable_refs.get("models", {}).size() == 2, "Saved Vengeance copies retain stable miniature-to-match model mappings")

	var builder := BuilderPanel.new()
	var assault_hint := {"visual_definitions": [UNIT_ID], "visual_weapons": ["Assault Cannon"], "ready": true}
	var heavy_hint := {"visual_definitions": [UNIT_ID], "visual_weapons": ["Heavy Bolter"], "ready": true}
	var matches := builder._appearance_model_match_rationale(assault_hint, entry, 0, 0)
	var conflicts := builder._appearance_model_match_rationale(heavy_hint, entry, 0, 0)
	builder.free()
	check(matches.contains("match this Land Speeder Vengeance's saved Assault Cannon") and conflicts.contains("conflict with this Land Speeder Vengeance's saved Assault Cannon"), "Appearance gallery hints compare the Vengeance's saved cannon")

	var selections := F.current_marine_selections()
	if admitted.get("error", "").is_empty(): selections[1] = admitted.selection
	selections[2].category = "custom"
	selections[2].points_limit = 3000
	var options := {"checked_rosters": false, "official_mission": false, "unit_abilities": true, "combat_doctrines": false, "manual_allocation": false, "marine_chapters": {1: "DARK ANGELS", 2: "DARK ANGELS"}}
	var state: Dictionary = F.P.initial_state(options, selections)
	var models: Array[int] = []
	if not state.has("error"):
		for model_id: int in state.units:
			var model: Dictionary = state.units[model_id]
			if int(model.get("owner", -1)) == 1 and F.C.UnitAbilities.identity(model) == "land-speeder-vengeance": models.append(model_id)
		models.sort()
	var installed: Array[String] = []
	var assault_model_id := -1
	if models.size() == 2:
		for model_id: int in models:
			var model: Dictionary = state.units[model_id]
			var ids: Array = model.get("ranged_weapons", []).map(func(weapon: Dictionary) -> String: return str(weapon.get("id", "")))
			if ids.has("assault-cannon"):
				installed.append("assault-cannon")
				assault_model_id = model_id
			else: installed.append("heavy-bolter" if ids.has("heavy-bolter") else "missing")
		installed.sort()
		check(installed == ["assault-cannon", "heavy-bolter"] and bool(state.units.get(assault_model_id, {}).get("land_speeder_vengeance_assault_cannon", false)), "Saved Vengeance cannons install the exact profiles before Deployment")
		var assault_unit: Dictionary = state.units.get(assault_model_id, {})
		var target_id := int(assault_unit.get("squad", -1))
		state.phase = "deployment"
		state.active = 1
		var available := action_choices(state, assault_model_id, target_id)
		var forced := PublicUnitCommand.submit(state, 1, {"action": "land-speeder-vengeance-cannon", "model": assault_model_id, "target": target_id, "value": "heavy-bolter"})
		var unchanged: Array = assault_unit.get("ranged_weapons", []).map(func(weapon: Dictionary) -> String: return str(weapon.get("id", "")))
		check(available.is_empty() and not str(forced.get("error", "")).is_empty() and unchanged.has("assault-cannon") and not unchanged.has("heavy-bolter"), "Saved-list matches suppress Vengeance setup choices and reject forced mid-match changes")
	else:
		check(false, "The local saved army materializes two Vengeance models: %s" % str(state.get("error", "Expected two models.")))

	if failures == 0:
		print("Land Speeder Vengeance saved-loadout checks passed")
		quit()
	else:
		print("Land Speeder Vengeance saved-loadout checks: %d failures" % failures)
		quit(1)
