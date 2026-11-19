extends SceneTree

const F = preload("res://tests/all_units_fixture.gd")
const Catalog = preload("res://scripts/edition_11/army_capabilities.gd")
const Roster = preload("res://scripts/army_roster.gd")
const Training = preload("res://scripts/edition_11/training_roster.gd")
const Prepared = preload("res://scripts/edition_11/prepared_training.gd")
const Actions = preload("res://scripts/edition_11/unit_actions.gd")
const Builder = preload("res://scripts/army_builder_panel.gd")
const Adapter = preload("res://scripts/edition_11/saved_equipment_profiles.gd")
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const C = F.C

var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	check_source_schema()
	run_saved_army_flow()
	print("Castellan saved-loadout checks: %d failures" % failures)
	quit(1 if failures else 0)

func check_source_schema() -> void:
	var definition := Adapter.CASTELLAN
	var controls := Adapter.controls(definition)
	check(Adapter.defaults(definition) == {"castellan_ranged_package": "combi-weapon", "castellan_melee_package": "master-crafted-power-weapon"}, "Castellan saved schema starts with both source defaults")
	check(controls.size() == 2, "Castellan schema exposes the ranged and melee source choices independently")
	var legal := 0
	for ranged: Dictionary in controls[0].choices:
		for melee: Dictionary in controls[1].choices:
			var equipment := Adapter.defaults(definition)
			equipment.castellan_ranged_package = ranged.id
			equipment.castellan_melee_package = melee.id
			var factory := Profiles.castellan_weapons(str(ranged.id), str(melee.id))
			check(Adapter.valid(definition, equipment, 1) == not factory.is_empty(), "Castellan admission matches the pinned local weapon factory")
			if not factory.is_empty(): legal += 1
	check(legal == 4, "Castellan schema admits all four combinations of its independent replacements")
	check(not Adapter.valid(definition, Adapter.defaults(definition), 2), "Castellan equipment schema is limited to one model per copy")

func run_saved_army_flow() -> void:
	var definition := Adapter.CASTELLAN
	var catalog_choice := Catalog.current_catalog_choice({"id": definition, "edition": "11e", "faction": "Space Marines"})
	check(not catalog_choice.is_empty(), "Castellan remains present in the consolidated local construction catalog")
	if catalog_choice.is_empty(): return
	catalog_choice.role = Roster.role(catalog_choice.get("keywords", []))
	var list := Roster.new_list("11e", "Space Marines", "custom", 1000)
	var item: Dictionary = Roster.entry(catalog_choice, 0, 1)
	Roster.set_model_equipment(item, 0, 0, "castellan_ranged_package", "heavy-bolt-pistol")
	Roster.set_model_equipment(item, 0, 0, "castellan_melee_package", "chainsword")
	list.entries.append(item)
	var configured := Roster.model_equipment(item, 0, 0)
	check(Adapter.valid(definition, configured, 1), "Workshop draft stores a legal Castellan replacement package")
	var admitted := Training.admit_current_catalog(list)
	check(admitted.error.is_empty(), "Saved Castellan passes current local catalog admission: " + str(admitted.get("error", "")))
	if not admitted.error.is_empty(): return
	var saved_entries: Array = admitted.selection.get("entries", [])
	check(saved_entries.size() == 1 and saved_entries[0].has("saved_model_loadouts"), "Admission projects the Castellan equipment onto its stable model copy")
	var selections := F.current_marine_selections()
	selections[1] = admitted.selection
	selections[1].category = "custom"
	selections[1].points_limit = 1000
	selections[2].category = "custom"
	selections[2].points_limit = 1000
	var state: Dictionary = Prepared.initial_state({"checked_rosters": false, "official_mission": false, "unit_abilities": true, "marine_chapters": {1: "BLACK TEMPLARS", 2: "BLACK TEMPLARS"}}, selections)
	check(not state.has("error") and str(state.get("setup_error", "")).is_empty(), "Saved Castellan materializes without setup errors: " + str(state.get("setup_error", state.get("error", ""))))
	if not state.has("error"):
		var castellan_id := -1
		for model_id: int in state.units:
			var model: Dictionary = state.units[model_id]
			if int(model.get("owner", -1)) != 1 or C.UnitAbilities.identity(model) != "castellan": continue
			castellan_id = model_id
			var expected := Profiles.castellan_weapons("heavy-bolt-pistol", "chainsword")
			check(model.get("saved_model_equipment", {}) == configured and model.ranged_weapons == expected.ranged and model.melee_weapons == expected.melee and bool(model.get("castellan_loadout_locked", false)), "Saved Castellan materializes the exact saved weapon profiles and locks them")
			check(int(model.get("max_wounds", 0)) == 4, "Equipment materialization preserves the audited Castellan Wounds characteristic")
		state.phase = "deployment"
		state.active = 1
		state.unit_abilities.setup_players = []
		var equipment_actions := ["castellan-ranged-loadout", "castellan-melee-loadout"]
		check(not Actions.choices(state, 1).any(func(option: Dictionary) -> bool: return str(option.get("action", "")) in equipment_actions), "Saved Castellan suppresses duplicate Army Preparation choices")
		if castellan_id >= 0:
			var before: Dictionary = state.units[castellan_id].duplicate(true)
			var forced := {"action": "castellan-ranged-loadout", "model": castellan_id, "target": int(before.get("squad", -1)), "value": "combi-weapon"}
			var forced_result := C.unit_action(state, 1, forced, Vector2.ZERO, int(state.revision))
			check(not forced_result.is_empty() and state.units[castellan_id].ranged_weapons == before.ranged_weapons and state.units[castellan_id].melee_weapons == before.melee_weapons, "Forced Army Preparation edit cannot mutate saved Castellan equipment")

	var panel := Builder.new()
	panel.storage_path = "user://castellan-saved-loadout-editor.json"
	root.add_child(panel)
	panel.draft = list.duplicate(true)
	panel._render_draft()
	panel._select_entry(0)
	panel._render_sergeant_loadout_controls(0)
	check(panel.per_model_equipment_controls.get_child_count() == Adapter.controls(definition).size() * 2, "Workshop displays both Castellan equipment selectors")
	if panel.per_model_equipment_controls.get_child_count() >= 2:
		var ranged_picker := panel.per_model_equipment_controls.get_child(1) as OptionButton
		ranged_picker.select(0)
		ranged_picker.item_selected.emit(0)
		var edited := Roster.model_equipment(panel.draft.entries[0], 0, 0)
		check(panel.dirty and edited.castellan_ranged_package == "combi-weapon" and edited.castellan_melee_package == "chainsword", "Workshop signal updates the selected Castellan copy and retains its other choice")
	panel.free()
