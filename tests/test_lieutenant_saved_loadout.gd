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
	print("Lieutenant saved-loadout checks: %d failures" % failures)
	quit(1 if failures else 0)

func check_source_schema() -> void:
	var definition := Adapter.LIEUTENANT
	check(Adapter.defaults(definition) == {"lieutenant_weapon_package": "default", "lieutenant_fists_replacement": "ceramite-fists", "lieutenant_storm_shield": false}, "Lieutenant saved schema uses the local source defaults")
	var controls := Adapter.controls(definition)
	check(controls.size() == 3 and controls[0].choices.size() == 9 and controls[1].choices.size() == 3 and controls[2].choices.size() == 2, "Lieutenant schema exposes all nine ranged packages, three fists replacements and shield toggle")
	var legal := 0
	for ranged: Dictionary in controls[0].choices:
		for melee: Dictionary in controls[1].choices:
			for shield: Dictionary in controls[2].choices:
				var equipment := {"lieutenant_weapon_package": ranged.id, "lieutenant_fists_replacement": melee.id, "lieutenant_storm_shield": shield.id}
				var factory := Profiles.lieutenant_weapons(str(ranged.id), str(melee.id), bool(shield.id))
				check(Adapter.valid(definition, equipment, 1) == not factory.is_empty(), "Lieutenant admission matches its local package and Storm Shield factory")
				if not factory.is_empty(): legal += 1
	check(legal == 30, "Lieutenant schema admits 27 non-shield packages and three Neo-volkite shield packages")
	var invalid_shield := Adapter.defaults(definition)
	invalid_shield.lieutenant_storm_shield = true
	check(not Adapter.valid(definition, invalid_shield, 1), "Lieutenant cannot save a Storm Shield without Neo-volkite")
	check(not Adapter.valid(definition, Adapter.defaults(definition), 2), "Lieutenant saved equipment remains one model per unit copy")

func run_saved_army_flow() -> void:
	var definition := Adapter.LIEUTENANT
	var catalog_choice := Catalog.current_catalog_choice({"id": definition, "edition": "11e", "faction": "Space Marines"})
	check(not catalog_choice.is_empty(), "Lieutenant remains in the consolidated local construction catalog")
	if catalog_choice.is_empty(): return
	catalog_choice.role = Roster.role(catalog_choice.get("keywords", []))
	var list := Roster.new_list("11e", "Space Marines", "custom", 1000)
	var item: Dictionary = Roster.entry(catalog_choice, 0, 1)
	for field: String in Adapter.defaults(definition): Roster.set_model_equipment(item, 0, 0, field, Adapter.defaults(definition)[field])
	Roster.set_model_equipment(item, 0, 0, "lieutenant_weapon_package", "neo-volkite")
	Roster.set_model_equipment(item, 0, 0, "lieutenant_fists_replacement", "power-fist")
	Roster.set_model_equipment(item, 0, 0, "lieutenant_storm_shield", true)
	list.entries.append(item)
	var configured := Roster.model_equipment(item, 0, 0)
	check(Adapter.valid(definition, configured, 1), "Workshop draft stores the legal Neo-volkite and Storm Shield combination")
	var admitted := Training.admit_current_catalog(list)
	check(admitted.error.is_empty(), "Saved Lieutenant passes current local catalog admission: " + str(admitted.get("error", "")))
	if not admitted.error.is_empty(): return
	var saved_entries: Array = admitted.selection.get("entries", [])
	check(saved_entries.size() == 1 and saved_entries[0].has("saved_model_loadouts"), "Admission projects the Lieutenant package onto its stable model copy")
	var selections := F.current_marine_selections()
	selections[1] = admitted.selection
	selections[1].category = "custom"
	selections[1].points_limit = 1000
	selections[2].category = "custom"
	selections[2].points_limit = 1000
	var state: Dictionary = Prepared.initial_state({"checked_rosters": false, "official_mission": false, "unit_abilities": true, "marine_chapters": {1: "ULTRAMARINES", 2: "ULTRAMARINES"}}, selections)
	check(not state.has("error") and str(state.get("setup_error", "")).is_empty(), "Saved Lieutenant materializes without setup errors: " + str(state.get("setup_error", state.get("error", ""))))
	if not state.has("error"):
		var lieutenant_id := -1
		for model_id: int in state.units:
			var model: Dictionary = state.units[model_id]
			if int(model.get("owner", -1)) != 1 or C.UnitAbilities.identity(model) != "lieutenant": continue
			lieutenant_id = model_id
			var expected := Profiles.lieutenant_weapons("neo-volkite", "power-fist", true)
			check(model.get("saved_model_equipment", {}) == configured and model.ranged_weapons == expected.ranged and model.melee_weapons == expected.melee and bool(model.get("lieutenant_loadout_locked", false)), "Saved Lieutenant materializes exact ranged/melee profiles and locks them")
			check(int(model.get("max_wounds", 0)) == 4 and int(model.get("wounds", 0)) == 4, "Saved loadout preserves the Lieutenant's source Wounds")
			check(int(model.get("defense", {}).get("invulnerable_target", 0)) == 4, "Saved Neo-volkite Storm Shield grants the Lieutenant its 4+ invulnerable save")
		state.phase = "deployment"
		state.active = 1
		state.unit_abilities.setup_players = []
		var actions := ["lieutenant-ranged-loadout", "lieutenant-melee-loadout", "lieutenant-storm-shield"]
		check(not Actions.choices(state, 1).any(func(option: Dictionary) -> bool: return str(option.get("action", "")) in actions), "Saved Lieutenant suppresses duplicate Army Preparation choices")
		if lieutenant_id >= 0:
			var before: Dictionary = state.units[lieutenant_id].duplicate(true)
			var forced := {"action": "lieutenant-ranged-loadout", "model": lieutenant_id, "target": int(before.get("squad", -1)), "value": "default"}
			var forced_result := C.unit_action(state, 1, forced, Vector2.ZERO, int(state.revision))
			check(not forced_result.is_empty() and state.units[lieutenant_id].ranged_weapons == before.ranged_weapons and state.units[lieutenant_id].melee_weapons == before.melee_weapons and state.units[lieutenant_id].defense == before.defense, "Forced Army Preparation edit cannot mutate saved weapons or shield save")

	var panel := Builder.new()
	panel.storage_path = "user://lieutenant-saved-loadout-editor.json"
	root.add_child(panel)
	panel.draft = list.duplicate(true)
	panel._render_draft()
	panel._select_entry(0)
	panel._render_sergeant_loadout_controls(0)
	check(panel.per_model_equipment_controls.get_child_count() == Adapter.controls(definition).size() * 2, "Workshop displays all three Lieutenant selectors")
	if panel.per_model_equipment_controls.get_child_count() == 6:
		var ranged_picker := panel.per_model_equipment_controls.get_child(1) as OptionButton
		ranged_picker.select(0)
		ranged_picker.item_selected.emit(0)
		var edited := Roster.model_equipment(panel.draft.entries[0], 0, 0)
		check(panel.dirty and edited.lieutenant_weapon_package == "default" and not bool(edited.lieutenant_storm_shield) and edited.lieutenant_fists_replacement == "power-fist", "Workshop changing away from Neo-volkite clears only its dependent Storm Shield: dirty=%s equipment=%s" % [str(panel.dirty), str(edited)])
		ranged_picker = panel.per_model_equipment_controls.get_child(1) as OptionButton
		ranged_picker.select(8)
		ranged_picker.item_selected.emit(8)
		var shield_picker := panel.per_model_equipment_controls.get_child(5) as OptionButton
		shield_picker.select(1)
		shield_picker.item_selected.emit(1)
		edited = Roster.model_equipment(panel.draft.entries[0], 0, 0)
		check(Adapter.valid(definition, edited, 1) and bool(edited.lieutenant_storm_shield), "Workshop allows the Storm Shield after selecting the required Neo-volkite package")
	panel.free()
