extends SceneTree

const F = preload("res://tests/all_units_fixture.gd")
const Catalog = preload("res://scripts/edition_11/army_capabilities.gd")
const ArmyRoster = preload("res://scripts/army_roster.gd")
const TrainingRoster = preload("res://scripts/edition_11/training_roster.gd")
const BuilderPanel = preload("res://scripts/army_builder_panel.gd")
const MainSceneScript = preload("res://scripts/main.gd")
const PublicUnitCommand = preload("res://tests/public_unit_command.gd")
const UNIT_ID := "40kdc:11e:adeptus-astartes:hellblaster-squad"

var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var unit := Catalog.current_catalog_choice({"id": UNIT_ID, "edition": "11e", "faction": "Space Marines"})
	unit.role = ArmyRoster.role(unit.get("keywords", []))
	var source_list := ArmyRoster.new_list("11e", "Space Marines", "custom", 3000)
	var entry: Dictionary = ArmyRoster.entry(unit, 0, 2)
	ArmyRoster.set_model_equipment(entry, 1, 0, "hellblaster_sergeant_pistol", "plasma-pistol")
	source_list.entries.append(entry)
	var admitted := TrainingRoster.inspect(source_list, {}, true)
	var pistol_choices: Array[String] = []
	if admitted.get("error", "").is_empty():
		for canonical_entry: Dictionary in admitted.selection.entries:
			for pistol: Variant in canonical_entry.get("hellblaster_sergeant_pistol_loadouts", []): pistol_choices.append(str(pistol))
	pistol_choices.sort()
	check(ArmyRoster.validate(source_list).is_empty() and admitted.get("error", "").is_empty() and pistol_choices == ["bolt-pistol", "plasma-pistol"], "Local admission preserves different Hellblaster Sergeant pistols by stable copy ID")
	var stable_refs := TrainingRoster.stable_model_refs(source_list, admitted.get("selection", {})) if admitted.get("error", "").is_empty() else {"error": "Saved-list admission failed."}
	check(stable_refs.get("error", "").is_empty() and stable_refs.get("models", {}).size() == 10, "Saved Hellblaster copies retain stable model identities")

	var preview := BuilderPanel.new()
	var plasma_hint := {"visual_definitions": [UNIT_ID], "visual_weapons": ["Plasma Pistol"], "ready": true}
	var rationale := preview._appearance_model_match_rationale(plasma_hint, entry, 1, 0)
	preview.free()
	check(rationale.contains("match this Hellblaster Sergeant's saved Plasma Pistol"), "Appearance guidance compares the local hint with the saved Sergeant pistol")

	var summary_state := {
		"saved_army_setup": {"armies": {1: {}}},
		"squads": {1: {"owner": 1, "name": "Hellblaster Squad"}},
		"units": {101: {"squad": 1, "hellblaster_loadout_locked": true, "plasma_pistol": true}},
	}
	var readiness_summary: String = MainSceneScript._saved_roster_equipment_status_for_state(summary_state, 1)
	check(readiness_summary.contains("Hellblaster Squad · 1 Plasma Pistol"), "Battle readiness reports the saved Hellblaster Sergeant pistol")

	var selections := F.current_marine_selections()
	if admitted.get("error", "").is_empty(): selections[1] = admitted.selection
	selections[2].category = "custom"
	selections[2].points_limit = 3000
	var options := {"checked_rosters": false, "official_mission": false, "unit_abilities": true, "combat_doctrines": false, "manual_allocation": false}
	var state: Dictionary = F.P.initial_state(options, selections)
	var sergeants: Array[int] = []
	if not state.has("error"):
		for model_id: int in state.units:
			var model: Dictionary = state.units[model_id]
			if int(model.get("owner", -1)) == 1 and F.C.UnitAbilities.identity(model) == "hellblaster-squad" and bool(model.get("sergeant", false)): sergeants.append(model_id)
	sergeants.sort()
	var materialized: Array[String] = []
	var plasma_sergeant := -1
	if sergeants.size() == 2:
		for model_id: int in sergeants:
			var model: Dictionary = state.units[model_id]
			var weapon_id := str(model.get("ranged_weapons", [])[1].get("id", "")) if model.get("ranged_weapons", []).size() == 2 else "missing"
			materialized.append(weapon_id)
			if weapon_id == "plasma-pistol": plasma_sergeant = model_id
			check(bool(model.get("hellblaster_loadout_locked", false)), "Saved Hellblaster pistol is locked for match preparation")
		materialized.sort()
		check(materialized == ["bolt-pistol", "plasma-pistol"], "Saved pistol choices install their exact local weapon profiles before Deployment")
		var plasma_model: Dictionary = state.units[plasma_sergeant]
		var forced := PublicUnitCommand.submit(state, 1, {"action": "hellblaster-pistol", "model": plasma_sergeant, "target": int(plasma_model.get("squad", -1)), "value": "bolt"})
		check(not str(forced.get("error", "")).is_empty() and str(plasma_model.ranged_weapons[1].get("id", "")) == "plasma-pistol", "A forced preparation command cannot overwrite the saved Plasma Pistol")
		var setup_choices := F.C.UnitActions.choices(state, 1).filter(func(choice: Dictionary) -> bool: return str(choice.get("action", "")) == "hellblaster-pistol")
		check(setup_choices.is_empty(), "Saved-list matches suppress the duplicate Hellblaster pistol prompt")
	else:
		check(false, "The local saved army materializes both Hellblaster copies: %s" % str(state.get("error", "Expected two Sergeant models.")))

	if failures == 0:
		print("Hellblaster saved-loadout checks passed")
		quit()
	else:
		print("Hellblaster saved-loadout checks: %d failures" % failures)
		quit(1)
