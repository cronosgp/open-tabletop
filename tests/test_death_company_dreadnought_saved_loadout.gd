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
	var controls := Adapter.controls(Adapter.DEATH_COMPANY_DREADNOUGHT)
	var legal := 0
	for heavy: Dictionary in controls[0].choices:
		for package: Dictionary in controls[1].choices:
			var equipment := Adapter.defaults(Adapter.DEATH_COMPANY_DREADNOUGHT)
			equipment.death_company_twin_multi_melta = heavy.id
			equipment.death_company_blood_talons = package.id
			var factory := Profiles.death_company_dreadnought_weapons(bool(heavy.id), bool(package.id))
			check(Adapter.valid(Adapter.DEATH_COMPANY_DREADNOUGHT, equipment, 1) == not factory.is_empty(), "Death Company Dreadnought admission matches its local weapon factory")
			if not factory.is_empty(): legal += 1
	check(legal == 4, "Death Company Dreadnought schema admits all four source-listed combinations")
	check(not Adapter.valid(Adapter.DEATH_COMPANY_DREADNOUGHT, Adapter.defaults(Adapter.DEATH_COMPANY_DREADNOUGHT), 2), "Death Company Dreadnought saved schema is limited to one model per copy")
	run_saved_copy_flow()
	print("Death Company Dreadnought saved-loadout checks: %d failures" % failures)
	quit(1 if failures else 0)

func run_saved_copy_flow() -> void:
	var definition := Adapter.DEATH_COMPANY_DREADNOUGHT
	var identity := "death-company-dreadnought"
	var choice := Catalog.current_catalog_choice({"id": definition, "edition": "11e", "faction": "Space Marines"})
	choice.role = Roster.role(choice.get("keywords", []))
	var list := Roster.new_list("11e", "Space Marines", "custom", 3000)
	var item: Dictionary = Roster.entry(choice, 0, 2)
	Roster.set_model_equipment(item, 0, 0, "death_company_twin_multi_melta", true)
	Roster.set_model_equipment(item, 0, 0, "death_company_blood_talons", true)
	list.entries.append(item)
	var configured := Roster.model_equipment(item, 0, 0)
	var defaults := Adapter.defaults(definition)
	check(Adapter.valid(definition, configured, 1) and configured != defaults, "Death Company Dreadnought saves a changed legal weapon package")
	var admitted := Training.admit_current_catalog(list)
	check(admitted.error.is_empty(), "Death Company Dreadnought passes current local admission: " + str(admitted.get("error", "")))
	if admitted.error.is_empty():
		var variants: Array = admitted.selection.get("entries", [])
		check(variants.size() == 2 and variants.all(func(entry: Dictionary) -> bool: return entry.has("saved_model_loadouts")), "Two Dreadnought copies retain separate equipment records")
		var selections := F.current_marine_selections()
		selections[1] = admitted.selection
		selections[1].category = "custom"
		selections[1].points_limit = 3000
		selections[2].category = "custom"
		selections[2].points_limit = 3000
		var state: Dictionary = Prepared.initial_state({"checked_rosters": false, "official_mission": false, "unit_abilities": true, "marine_chapters": {1: "BLOOD ANGELS", 2: "BLOOD ANGELS"}}, selections)
		check(not state.has("error") and str(state.get("setup_error", "")).is_empty(), "Death Company Dreadnought materializes without setup errors: " + str(state.get("setup_error", state.get("error", ""))))
		if not state.has("error"):
			var observed: Array[Dictionary] = []
			var configured_model := -1
			for model_id: int in state.units:
				var model: Dictionary = state.units[model_id]
				if int(model.get("owner", -1)) != 1 or C.UnitAbilities.identity(model) != identity: continue
				var equipment: Dictionary = model.get("saved_model_equipment", {})
				observed.append(equipment.duplicate(true))
				var expected := Profiles.death_company_dreadnought_weapons(bool(equipment.get("death_company_twin_multi_melta", false)), bool(equipment.get("death_company_blood_talons", false)))
				check(Adapter.valid(definition, equipment, 1) and model.ranged_weapons == expected.ranged and model.melee_weapons == expected.melee and bool(model.get("death_company_dreadnought_loadout_locked", false)), "Exact saved ranged/melee package is installed and locked")
				if equipment == configured: configured_model = model_id
			check(observed.size() == 2 and observed.any(func(value: Dictionary) -> bool: return value == configured) and observed.any(func(value: Dictionary) -> bool: return value == defaults), "One configured and one default Dreadnought copy materialize independently")
			state.phase = "deployment"
			state.active = 1
			state.unit_abilities.setup_players = []
			check(not Actions.choices(state, 1).any(func(option: Dictionary) -> bool: return str(option.get("action", "")) == "death-company-dreadnought-loadout"), "Saved choices suppress duplicate match-preparation actions")
			if configured_model >= 0:
				var configured_unit: Dictionary = state.units[configured_model]
				var before := configured_unit.duplicate(true)
				var forced := {"action": "death-company-dreadnought-loadout", "model": configured_model, "target": 0, "value": "twin-heavy-bolter"}
				check(not C.unit_action(state, 1, forced, Vector2.ZERO, int(state.revision)).is_empty() and state.units[configured_model].ranged_weapons == before.ranged_weapons and state.units[configured_model].melee_weapons == before.melee_weapons, "Forced setup mutation is rejected without changing the saved weapons")

	var panel := Builder.new()
	panel.storage_path = "user://death-company-dreadnought-saved-loadout-editor.json"
	root.add_child(panel)
	panel.draft = list.duplicate(true)
	panel._render_draft()
	panel._select_entry(0)
	panel._render_sergeant_loadout_controls(1)
	check(panel.per_model_equipment_controls.get_child_count() == Adapter.controls(definition).size() * 2, "Army Workshop renders both source-listed equipment groups")
	if panel.per_model_equipment_controls.get_child_count() == Adapter.controls(definition).size() * 2:
		var picker := panel.per_model_equipment_controls.get_child(1) as OptionButton
		picker.select(0)
		picker.item_selected.emit(0)
		var edited := Roster.model_equipment(panel.draft.entries[0], 1, 0)
		check(panel.dirty and edited.death_company_twin_multi_melta == false and Roster.model_equipment(panel.draft.entries[0], 0, 0) == configured, "Workshop signal edits only the selected stable copy")
	panel.free()
