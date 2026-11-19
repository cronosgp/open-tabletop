extends SceneTree

const F = preload("res://tests/all_units_fixture.gd")
const Catalog = preload("res://scripts/edition_11/army_capabilities.gd")
const ArmyRoster = preload("res://scripts/army_roster.gd")
const TrainingRoster = preload("res://scripts/edition_11/training_roster.gd")
const BuilderPanel = preload("res://scripts/army_builder_panel.gd")
const PublicUnitCommand = preload("res://tests/public_unit_command.gd")
const UNIT_ID := "40kdc:11e:adeptus-astartes:land-speeder"

var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func choice_for(state: Dictionary, action: String, model_id: int, target_id: int) -> Dictionary:
	for option: Dictionary in F.C.UnitActions.choices(state, 1):
		if str(option.get("action", "")) == action and int(option.get("model", -1)) == model_id and int(option.get("target", -1)) == target_id: return option
	return {}

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var unit := Catalog.current_catalog_choice({"id": UNIT_ID, "edition": "11e", "faction": "Space Marines"})
	unit.role = ArmyRoster.role(unit.get("keywords", []))
	var source_list := ArmyRoster.new_list("11e", "Space Marines", "custom", 3000)
	var entry: Dictionary = ArmyRoster.entry(unit, 0, 2)
	ArmyRoster.set_model_equipment(entry, 0, 0, "land_speeder_cannon", "pyrecannon")
	source_list.entries.append(entry)
	var admitted := TrainingRoster.inspect(source_list, {}, true)
	var canonical_entries: Array = admitted.get("selection", {}).get("entries", []) if admitted.get("error", "") == "" else []
	var cannons: Array[String] = []
	for canonical_entry: Dictionary in canonical_entries:
		for cannon: Variant in canonical_entry.get("land_speeder_loadouts", []): cannons.append(str(cannon))
	check(ArmyRoster.validate(source_list).is_empty() and admitted.get("error", "").is_empty() and cannons == ["onslaught", "pyrecannon"], "Local admission preserves different source-listed cannons on separate Land Speeder copies")
	var stable_refs := TrainingRoster.stable_model_refs(source_list, admitted.get("selection", {})) if admitted.get("error", "") == "" else {"error": "Saved-list admission failed."}
	check(stable_refs.get("error", "").is_empty() and stable_refs.get("models", {}).size() == 2, "Each saved Land Speeder copy maps to a stable miniature and match model")

	var builder := BuilderPanel.new()
	var pyrecannon_hint := {"visual_definitions": [UNIT_ID], "visual_weapons": ["Pyrecannon"], "ready": true}
	var onslaught_hint := {"visual_definitions": [UNIT_ID], "visual_weapons": ["Onslaught Gatling Cannon"], "ready": true}
	var matches := builder._appearance_model_match_rationale(pyrecannon_hint, entry, 0, 0)
	var conflicts := builder._appearance_model_match_rationale(onslaught_hint, entry, 0, 0)
	builder.free()
	check(matches.contains("match this Land Speeder's saved Pyrecannon") and conflicts.contains("conflict with this Land Speeder's saved Pyrecannon"), "Appearance gallery hints explain matching and conflicting Land Speeder cannon metadata")

	var selections := F.current_marine_selections()
	if admitted.get("error", "").is_empty(): selections[1] = admitted.selection
	selections[2].category = "custom"
	selections[2].points_limit = 3000
	var state: Dictionary = F.P.initial_state({"checked_rosters": false, "official_mission": false, "unit_abilities": true, "combat_doctrines": false, "manual_allocation": false}, selections)
	var models: Array[int] = []
	if not state.has("error"):
		for model_id: int in state.units:
			var model: Dictionary = state.units[model_id]
			if int(model.get("owner", -1)) == 1 and F.C.UnitAbilities.identity(model) == "land-speeder": models.append(model_id)
		models.sort()
	var equipped := []
	var pyrecannon_model_id := -1
	if models.size() == 2:
		for model_id: int in models:
			var model: Dictionary = state.units[model_id]
			var ids: Array = model.get("ranged_weapons", []).map(func(weapon: Dictionary) -> String: return str(weapon.get("id", "")))
			if ids.has("pyrecannon"):
				equipped.append("pyrecannon")
				pyrecannon_model_id = model_id
			else: equipped.append("onslaught" if ids.has("onslaught-gatling-cannon") else "missing")
		check(equipped == ["onslaught", "pyrecannon"] and bool(state.units.get(pyrecannon_model_id, {}).get("land_speeder_pyrecannon", false)), "Saved choices install the exact weapon profiles before Deployment")
		var pyrecannon_unit: Dictionary = state.units.get(pyrecannon_model_id, {})
		var target_id := int(pyrecannon_unit.get("squad", -1))
		state.phase = "deployment"
		state.active = 1
		var available := choice_for(state, "land-speeder-cannon", pyrecannon_model_id, target_id)
		var forced := PublicUnitCommand.submit(state, 1, {"action": "land-speeder-cannon", "model": pyrecannon_model_id, "target": target_id, "value": "onslaught"})
		var unchanged: Array = pyrecannon_unit.get("ranged_weapons", []).map(func(weapon: Dictionary) -> String: return str(weapon.get("id", "")))
		check(available.is_empty() and not str(forced.get("error", "")).is_empty() and unchanged.has("pyrecannon") and not unchanged.has("onslaught-gatling-cannon"), "Saved-list matches suppress duplicate preparation choices and reject a forced mid-match change")
	else:
		check(false, "The local saved army materializes two Land Speeders: %s" % str(state.get("error", "Expected two model instances.")))

	if failures == 0:
		print("Land Speeder saved-loadout checks passed")
		quit()
	else:
		print("Land Speeder saved-loadout checks: %d failures" % failures)
		quit(1)
