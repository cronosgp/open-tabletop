extends SceneTree

const F = preload("res://tests/all_units_fixture.gd")
const Catalog = preload("res://scripts/edition_11/army_capabilities.gd")
const ArmyRoster = preload("res://scripts/army_roster.gd")
const TrainingRoster = preload("res://scripts/edition_11/training_roster.gd")
const BuilderPanel = preload("res://scripts/army_builder_panel.gd")
const PublicUnitCommand = preload("res://tests/public_unit_command.gd")
const UNIT_ID := "40kdc:11e:adeptus-astartes:predator-destructor"

var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func find_models(state: Dictionary, owner: int) -> Array[int]:
	var result: Array[int] = []
	for model_id: int in state.get("units", {}):
		var model: Dictionary = state.units[model_id]
		if int(model.get("owner", -1)) == owner and F.C.UnitAbilities.identity(model) == "predator-destructor": result.append(model_id)
	result.sort()
	return result

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var unit := Catalog.current_catalog_choice({"id": UNIT_ID, "edition": "11e", "faction": "Space Marines"})
	unit.role = ArmyRoster.role(unit.get("keywords", []))
	var source_list := ArmyRoster.new_list("11e", "Space Marines", "strike_force", 2000)
	var entry: Dictionary = ArmyRoster.entry(unit, 0, 2)
	ArmyRoster.set_model_equipment(entry, 0, 0, "predator_destructor_heavy_bolters", true)
	ArmyRoster.set_model_equipment(entry, 0, 0, "predator_destructor_storm_bolter", true)
	ArmyRoster.set_model_equipment(entry, 0, 0, "predator_destructor_hunter_killer_missile", true)
	source_list.entries.append(entry)
	var full_loadout := ArmyRoster.model_equipment(entry, 0, 0)
	var default_loadout := ArmyRoster.model_equipment(entry, 1, 0)
	var admitted := TrainingRoster.inspect(source_list, {}, true)
	var canonical_loadouts: Array = []
	if admitted.get("error", "").is_empty():
		for canonical_entry: Dictionary in admitted.selection.get("entries", []):
			for loadout: Variant in canonical_entry.get("predator_destructor_loadouts", []):
				canonical_loadouts.append(loadout)
	check(ArmyRoster.validate(source_list).is_empty() and admitted.get("error", "").is_empty()
		and full_loadout == {"predator_destructor_heavy_bolters": true, "predator_destructor_hunter_killer_missile": true, "predator_destructor_storm_bolter": true}
		and default_loadout == {"predator_destructor_heavy_bolters": false, "predator_destructor_hunter_killer_missile": false, "predator_destructor_storm_bolter": false}
		and canonical_loadouts.size() == 2 and canonical_loadouts.has(full_loadout) and canonical_loadouts.has(default_loadout),
		"Saved Destructor copies retain independent local options through current-catalog admission: admission=%s configs=%s" % [str(admitted.get("error", "")), str(canonical_loadouts)])
	check(ArmyRoster.model_equipment_role(entry, 0, 0) != ArmyRoster.model_equipment_role(entry, 1, 0), "Different Predator Destructor packages remain distinct appearance roles")

	var panel := BuilderPanel.new()
	panel.storage_path = "user://predator-destructor-saved-loadout-test.json"
	panel.cache_directory = "user://predator-destructor-saved-loadout-catalog"
	root.add_child(panel)
	panel.draft = source_list.duplicate(true)
	panel._render_draft()
	panel._select_entry(0)
	check(panel.sergeant_loadout_heading.visible and panel.sergeant_loadout_heading.text == "PREDATOR DESTRUCTOR EQUIPMENT" and panel.per_model_equipment_controls.get_child_count() == 3,
		"Army Builder exposes the two sponson and optional weapon choices on the Predator Destructor")
	if panel.per_model_equipment_controls.get_child_count() == 3:
		var checkbox_heavy_bolters: CheckBox = panel.per_model_equipment_controls.get_child(0)
		var checkbox_storm_bolter: CheckBox = panel.per_model_equipment_controls.get_child(1)
		var checkbox_missile: CheckBox = panel.per_model_equipment_controls.get_child(2)
		var ui_saved := ArmyRoster.model_equipment(panel.draft.entries[0], 0, 0)
		check(checkbox_heavy_bolters.button_pressed and checkbox_storm_bolter.button_pressed and checkbox_missile.button_pressed
			and bool(ui_saved.get("predator_destructor_heavy_bolters", false)) and bool(ui_saved.get("predator_destructor_storm_bolter", false)) and bool(ui_saved.get("predator_destructor_hunter_killer_missile", false)),
			"The editable controls reopen with this copy's saved equipment")
	var visual_hint := {"visual_definitions": [UNIT_ID], "visual_weapons": ["Heavy Bolter", "Heavy Bolter", "Predator Autocannon", "Hunter-killer Missile", "Storm Bolter", "Armoured Tracks"], "ready": true}
	var visual_assessment := panel._appearance_model_match_assessment(visual_hint, entry, 0, 0)
	check(visual_assessment.get("confidence", "") == "strong", "Equipment-aware appearance guidance compares the saved sponsons and optional weapons against local labels")
	panel.free()

	var selections := F.current_marine_selections()
	if admitted.get("error", "").is_empty(): selections[1] = admitted.selection
	selections[2].category = str(selections[1].get("category", "strike_force"))
	selections[2].points_limit = int(selections[1].get("points_limit", 2000))
	var state: Dictionary = F.P.initial_state({"checked_rosters": false, "official_mission": false, "unit_abilities": true, "combat_doctrines": false, "manual_allocation": false}, selections)
	var models: Array[int] = []
	if not state.has("error"): models = find_models(state, 1)
	if models.size() == 2:
		var first: Dictionary = state.units[models[0]]
		var second: Dictionary = state.units[models[1]]
		var first_ids: Array = first.get("ranged_weapons", []).map(func(weapon: Dictionary) -> String: return str(weapon.get("id", "")))
		var second_ids: Array = second.get("ranged_weapons", []).map(func(weapon: Dictionary) -> String: return str(weapon.get("id", "")))
		var installed_loadouts: Array = [first_ids, second_ids]
		check(installed_loadouts.has(["heavy-bolter", "heavy-bolter", "predator-autocannon", "hunter-killer-missile", "storm-bolter"])
			and installed_loadouts.has(["lascannon", "lascannon", "predator-autocannon"])
			and bool(first.get("predator_destructor_loadout_locked", false)) and bool(second.get("predator_destructor_loadout_locked", false)),
			"Saved options materialize exact source profiles and lock each copy before Deployment: first=%s second=%s" % [str(first_ids), str(second_ids)])
		state.phase = "deployment"
		state.active = 1
		state.unit_abilities.setup_players = []
		var choices: Array = F.C.UnitActions.choices(state, 1).filter(func(option: Dictionary) -> bool: return str(option.get("action", "")) == "predator-destructor-loadout")
		var before: Array = first.get("ranged_weapons", []).map(func(weapon: Dictionary) -> String: return str(weapon.get("id", "")))
		var forced := PublicUnitCommand.submit(state, 1, {"action": "predator-destructor-loadout", "model": models[0], "target": 0, "value": "off"})
		var after: Array = state.units[models[0]].get("ranged_weapons", []).map(func(weapon: Dictionary) -> String: return str(weapon.get("id", "")))
		check(choices.is_empty() and not str(forced.get("error", "")).is_empty() and before == after,
			"Saved Destructor choices do not reappear before battle and public commands reject forced changes")
	else:
		check(false, "The admitted saved army materializes both Destructor copies: %s" % str(state.get("error", "Expected two model instances.")))

	if failures == 0:
		print("Predator Destructor saved-loadout checks passed")
		quit()
	else:
		print("Predator Destructor saved-loadout checks: %d failures" % failures)
		quit(1)
