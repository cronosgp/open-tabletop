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
	print("Marshal saved-loadout checks: %d failures" % failures)
	quit(1 if failures else 0)

func check_source_schema() -> void:
	var definition := Adapter.MARSHAL
	var controls := Adapter.controls(definition)
	check(Adapter.defaults(definition) == {"marshal_ranged_package": "plasma-pistol"}, "Marshal saved schema uses its source default")
	check(controls.size() == 1 and controls[0].choices.size() == 2, "Marshal schema exposes exactly the Plasma Pistol and Combi-weapon")
	for package: Dictionary in controls[0].choices:
		var equipment := {"marshal_ranged_package": package.id}
		var factory := Profiles.marshal_weapons(str(package.id))
		check(Adapter.valid(definition, equipment, 1) == not factory.is_empty(), "Marshal admission matches the current local weapon factory")
		check(not factory.is_empty() and factory.melee == Profiles.marshal_weapons("plasma-pistol").melee, "Ranged replacement leaves the fixed Master-crafted Power Weapon unchanged")
	check(not Adapter.valid(definition, Adapter.defaults(definition), 2), "Marshal saved equipment remains one model per unit copy")

func run_saved_army_flow() -> void:
	var definition := Adapter.MARSHAL
	var catalog_choice := Catalog.current_catalog_choice({"id": definition, "edition": "11e", "faction": "Space Marines"})
	check(not catalog_choice.is_empty(), "Marshal remains available in the consolidated local construction catalog")
	if catalog_choice.is_empty(): return
	catalog_choice.role = Roster.role(catalog_choice.get("keywords", []))
	var list := Roster.new_list("11e", "Space Marines", "custom", 1000)
	var item: Dictionary = Roster.entry(catalog_choice, 0, 1)
	Roster.set_model_equipment(item, 0, 0, "marshal_ranged_package", "combi-weapon")
	list.entries.append(item)
	var configured := Roster.model_equipment(item, 0, 0)
	var admitted := Training.admit_current_catalog(list)
	check(admitted.error.is_empty(), "Saved Marshal passes current local catalog admission: " + str(admitted.get("error", "")))
	if not admitted.error.is_empty(): return
	var saved_entries: Array = admitted.selection.get("entries", [])
	check(saved_entries.size() == 1 and saved_entries[0].has("saved_model_loadouts"), "Admission carries the Marshal package on its stable model copy")
	var selections := F.current_marine_selections()
	selections[1] = admitted.selection
	selections[1].category = "custom"
	selections[1].points_limit = 1000
	selections[2].category = "custom"
	selections[2].points_limit = 1000
	var state: Dictionary = Prepared.initial_state({"checked_rosters": false, "official_mission": false, "unit_abilities": true, "marine_chapters": {1: "BLACK TEMPLARS", 2: "BLACK TEMPLARS"}}, selections)
	check(not state.has("error") and str(state.get("setup_error", "")).is_empty(), "Saved Marshal materializes without setup errors: " + str(state.get("setup_error", state.get("error", ""))))
	if not state.has("error"):
		var marshal_id := -1
		for model_id: int in state.units:
			var model: Dictionary = state.units[model_id]
			if int(model.get("owner", -1)) != 1 or C.UnitAbilities.identity(model) != "marshal": continue
			marshal_id = model_id
			var expected := Profiles.marshal_weapons("combi-weapon")
			check(model.get("saved_model_equipment", {}) == configured and model.ranged_weapons == expected.ranged and model.melee_weapons == expected.melee and bool(model.get("marshal_loadout_locked", false)), "Saved Marshal materializes exact ranged and fixed melee weapons and locks them")
			var squad_stats: Dictionary = state.squads[int(model.get("squad", -1))].get("stats", {})
			check(int(model.get("max_wounds", 0)) == 5 and int(squad_stats.get("invulnerable_target", 0)) == 4, "Saved equipment preserves Marshal's Wounds and invulnerable save")
		state.phase = "deployment"
		state.active = 1
		state.unit_abilities.setup_players = []
		check(not Actions.choices(state, 1).any(func(option: Dictionary) -> bool: return str(option.get("action", "")) == "marshal-ranged-loadout"), "Saved Marshal suppresses the duplicate Army Preparation choice")
		if marshal_id >= 0:
			var before: Dictionary = state.units[marshal_id].duplicate(true)
			var forced := {"action": "marshal-ranged-loadout", "model": marshal_id, "target": int(before.get("squad", -1)), "value": "plasma-pistol"}
			var forced_result := C.unit_action(state, 1, forced, Vector2.ZERO, int(state.revision))
			check(not forced_result.is_empty() and state.units[marshal_id].ranged_weapons == before.ranged_weapons and state.units[marshal_id].melee_weapons == before.melee_weapons, "Forced Army Preparation edit cannot mutate saved Marshal equipment")

	var panel := Builder.new()
	panel.storage_path = "user://marshal-saved-loadout-editor.json"
	root.add_child(panel)
	panel.draft = list.duplicate(true)
	panel._render_draft()
	panel._select_entry(0)
	panel._render_sergeant_loadout_controls(0)
	check(panel.per_model_equipment_controls.get_child_count() == 2, "Workshop displays the Marshal's saved ranged selector")
	if panel.per_model_equipment_controls.get_child_count() >= 2:
		var picker := panel.per_model_equipment_controls.get_child(1) as OptionButton
		picker.select(0)
		picker.item_selected.emit(0)
		var edited := Roster.model_equipment(panel.draft.entries[0], 0, 0)
		check(panel.dirty and edited.marshal_ranged_package == "plasma-pistol", "Workshop signal restores the default Plasma Pistol on the saved draft")
	panel.free()
