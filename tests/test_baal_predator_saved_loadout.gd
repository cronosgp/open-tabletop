extends SceneTree

const F = preload("res://tests/all_units_fixture.gd")
const Catalog = preload("res://scripts/edition_11/army_capabilities.gd")
const ArmyRoster = preload("res://scripts/army_roster.gd")
const TrainingRoster = preload("res://scripts/edition_11/training_roster.gd")
const BuilderPanel = preload("res://scripts/army_builder_panel.gd")
const PublicUnitCommand = preload("res://tests/public_unit_command.gd")
const UNIT_ID := "40kdc:11e:adeptus-astartes:baal-predator"

var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func find_model(state: Dictionary, owner: int) -> int:
	for model_id: int in state.units:
		var model: Dictionary = state.units[model_id]
		if int(model.get("owner", -1)) == owner and F.C.UnitAbilities.identity(model) == "baal-predator": return model_id
	return -1

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var unit := Catalog.current_catalog_choice({"id": UNIT_ID, "edition": "11e", "faction": "Space Marines"})
	unit.role = ArmyRoster.role(unit.get("keywords", []))
	var source_list := ArmyRoster.new_list("11e", "Space Marines", "custom", 3000)
	var entry: Dictionary = ArmyRoster.entry(unit, 0, 2)
	ArmyRoster.set_model_equipment(entry, 0, 0, "baal_predator_primary_cannon", "baal-flamestorm-cannon")
	ArmyRoster.set_model_equipment(entry, 0, 0, "baal_predator_sponson_package", "heavy-bolters")
	ArmyRoster.set_model_equipment(entry, 0, 0, "baal_predator_storm_bolter", true)
	ArmyRoster.set_model_equipment(entry, 0, 0, "baal_predator_hunter_killer_missile", true)
	ArmyRoster.set_model_equipment(entry, 1, 0, "baal_predator_sponson_package", "heavy-flamers")
	source_list.entries.append(entry)
	var first_loadout := ArmyRoster.model_equipment(entry, 0, 0)
	var second_loadout := ArmyRoster.model_equipment(entry, 1, 0)
	var admitted := TrainingRoster.inspect(source_list, {}, true)
	var canonical_entries: Array = admitted.get("selection", {}).get("entries", []) if admitted.get("error", "") == "" else []
	var canonical_loadouts: Array[Dictionary] = []
	for canonical_entry: Dictionary in canonical_entries:
		for loadout: Variant in canonical_entry.get("baal_predator_loadouts", []):
			if loadout is Dictionary: canonical_loadouts.append(loadout)
	var roster_error := ArmyRoster.validate(source_list)
	check(roster_error.is_empty() and first_loadout == {"baal_predator_primary_cannon": "baal-flamestorm-cannon", "baal_predator_sponson_package": "heavy-bolters", "baal_predator_storm_bolter": true, "baal_predator_hunter_killer_missile": true} and second_loadout.get("baal_predator_sponson_package") == "heavy-flamers" and canonical_loadouts.size() == 2 and canonical_loadouts.has(first_loadout) and canonical_loadouts.has(second_loadout), "Saved Baal Predator copies retain separate source-listed configurations through Army Builder admission: roster=%s admission=%s canonical=%s" % [roster_error, str(admitted.get("error", "")), str(canonical_loadouts)])
	var refs := TrainingRoster.stable_model_refs(source_list, admitted.get("selection", {})) if admitted.get("error", "").is_empty() else {"error": "Saved-list admission failed."}
	check(admitted.get("error", "").is_empty() and refs.get("error", "").is_empty() and refs.get("models", {}).size() == 2, "Both saved Baal Predators map to stable miniatures for match materialization: admission=%s refs=%s" % [str(admitted.get("error", "")), str(refs)])

	var panel := BuilderPanel.new()
	panel.storage_path = "user://baal-predator-saved-loadout-test.json"
	panel.cache_directory = "user://baal-predator-saved-loadout-catalog"
	root.add_child(panel)
	panel.draft = source_list.duplicate(true)
	panel._render_draft()
	panel._select_entry(0)
	check(panel.sergeant_loadout_heading.visible and panel.sergeant_loadout_heading.text == "BAAL PREDATOR EQUIPMENT" and panel.per_model_equipment_controls.get_child_count() == 4, "Army Builder exposes cannon, paired sponson and optional weapon controls for the saved vehicle")
	var primary_picker: OptionButton = panel.per_model_equipment_controls.get_child(0).get_child(1)
	var sponson_picker: OptionButton = panel.per_model_equipment_controls.get_child(1).get_child(1)
	var ui_saved := ArmyRoster.model_equipment(panel.draft.entries[0], 0, 0)
	check(primary_picker.item_count == 2 and sponson_picker.item_count == 3 and bool(ui_saved.get("baal_predator_storm_bolter", false)) and bool(ui_saved.get("baal_predator_hunter_killer_missile", false)), "The editable Army Builder controls reopen with the saved source choices")
	var visual_hint := {"visual_definitions": [UNIT_ID], "visual_weapons": ["Baal Flamestorm Cannon", "Heavy Bolter", "Storm Bolter", "Hunter-killer Missile", "Armoured Tracks"], "ready": true}
	var visual_assessment := panel._appearance_model_match_assessment(visual_hint, entry, 0, 0)
	check(visual_assessment.get("confidence", "") == "strong" and ArmyRoster.model_equipment_role(entry, 0, 0) != ArmyRoster.model_equipment_role(entry, 1, 0), "Local visual hints compare the saved physical weapon package and keep different Baal configurations in separate model roles")
	panel.free()

	var selections := F.current_marine_selections()
	if admitted.get("error", "").is_empty(): selections[1] = admitted.selection
	selections[2].category = "custom"
	selections[2].points_limit = 3000
	var state: Dictionary = F.P.initial_state({"checked_rosters": false, "official_mission": false, "unit_abilities": true, "combat_doctrines": false, "manual_allocation": false, "marine_chapters": {1: "BLOOD ANGELS", 2: "BLOOD ANGELS"}}, selections)
	var models: Array[int] = []
	if not state.has("error"):
		for model_id: int in state.units:
			var model: Dictionary = state.units[model_id]
			if int(model.get("owner", -1)) == 1 and F.C.UnitAbilities.identity(model) == "baal-predator": models.append(model_id)
	models.sort()
	if models.size() == 2:
		var installed: Array[Array] = []
		for model_id: int in models:
			var model: Dictionary = state.units[model_id]
			installed.append(model.get("ranged_weapons", []).map(func(weapon: Dictionary) -> String: return str(weapon.get("id", ""))))
		var expected := [
			["baal-flamestorm-cannon", "heavy-bolter-sponson-left", "heavy-bolter-sponson-right", "storm-bolter", "hunter-killer-missile"],
			["twin-assault-cannon", "heavy-flamer-sponson-left", "heavy-flamer-sponson-right"]
		]
		var locks: Array[bool] = []
		for model_id: int in models: locks.append(bool(state.units[model_id].get("baal_predator_loadout_locked", false)))
		check(installed.has(expected[0]) and installed.has(expected[1]) and locks == [true, true], "Saved configurations materialize their exact weapon profiles and lock Army Builder choices before Deployment: installed=%s locks=%s" % [str(installed), str(locks)])
		state.phase = "deployment"
		state.active = 1
		state.unit_abilities.setup_players = []
		var choices: Array = F.C.UnitActions.choices(state, 1).filter(func(option: Dictionary) -> bool: return str(option.get("action", "")) == "baal-predator-loadout")
		var target_model := models[1]
		var before: Array = state.units[target_model].get("ranged_weapons", []).map(func(weapon: Dictionary) -> String: return str(weapon.get("id", "")))
		var forced := PublicUnitCommand.submit(state, 1, {"action": "baal-predator-loadout", "model": target_model, "target": 0, "value": "twin-assault-cannon"})
		var after: Array = state.units[target_model].get("ranged_weapons", []).map(func(weapon: Dictionary) -> String: return str(weapon.get("id", "")))
		check(choices.is_empty() and not str(forced.get("error", "")).is_empty() and before == after and after.has("baal-flamestorm-cannon"), "Saved Baal Predator profiles suppress duplicate setup prompts and reject forced changes")
	else:
		check(false, "The saved army materializes both Baal Predators: %s" % str(state.get("error", "Expected two model instances.")))

	if failures == 0:
		print("Baal Predator saved-loadout checks passed")
		quit()
	else:
		print("Baal Predator saved-loadout checks: %d failures" % failures)
		quit(1)
