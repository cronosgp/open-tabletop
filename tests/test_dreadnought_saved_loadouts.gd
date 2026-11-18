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
	check_source_option_schemas()
	for definition: String in [Adapter.DREADNOUGHT, Adapter.VENERABLE_DREADNOUGHT]:
		run_saved_copy_flow(definition)
	print("Dreadnought saved-loadout checks: %d failures" % failures)
	quit(1 if failures else 0)

func check_source_option_schemas() -> void:
	var dreadnought_controls := Adapter.controls(Adapter.DREADNOUGHT)
	var dreadnought_legal := 0
	for primary: Dictionary in dreadnought_controls[0].choices:
		for package: Dictionary in dreadnought_controls[1].choices:
			for secondary: Dictionary in dreadnought_controls[2].choices:
				var equipment := Adapter.defaults(Adapter.DREADNOUGHT)
				equipment.dreadnought_primary = primary.id
				equipment.dreadnought_melee_package = package.id
				equipment.dreadnought_secondary = secondary.id
				var factory := Profiles.dreadnought_weapons(str(primary.id), str(package.id), str(secondary.id))
				check(Adapter.valid(Adapter.DREADNOUGHT, equipment, 1) == not factory.is_empty(), "Dreadnought admission matches its source-bounded replacement groups")
				if not factory.is_empty(): dreadnought_legal += 1
	check(dreadnought_legal == 12, "Dreadnought saved schema admits exactly its 12 source-listed legal combinations")
	check(not Adapter.valid(Adapter.DREADNOUGHT, Adapter.defaults(Adapter.DREADNOUGHT), 2), "Dreadnought saved schema is limited to its one-model unit copy")

	var venerable_controls := Adapter.controls(Adapter.VENERABLE_DREADNOUGHT)
	var venerable_legal := 0
	for primary: Dictionary in venerable_controls[0].choices:
		for package: Dictionary in venerable_controls[1].choices:
			var equipment := Adapter.defaults(Adapter.VENERABLE_DREADNOUGHT)
			equipment.venerable_dreadnought_legends_primary = primary.id
			equipment.venerable_dreadnought_legends_package = package.id
			var factory := Profiles.venerable_dreadnought_legends_weapons(str(primary.id), str(package.id))
			check(Adapter.valid(Adapter.VENERABLE_DREADNOUGHT, equipment, 1) == not factory.is_empty(), "Venerable Dreadnought Legends admission matches its source-listed groups")
			if not factory.is_empty(): venerable_legal += 1
	check(venerable_legal == 32, "Venerable Dreadnought Legends saved schema admits all 32 source-listed combinations")
	check(not Adapter.valid(Adapter.VENERABLE_DREADNOUGHT, Adapter.defaults(Adapter.VENERABLE_DREADNOUGHT), 2), "Venerable Dreadnought Legends saved schema is limited to its one-model copy")

func run_saved_copy_flow(definition: String) -> void:
	var identity := definition.get_slice(":", 3)
	var choice := Catalog.current_catalog_choice({"id": definition, "edition": "11e", "faction": "Space Marines"})
	choice.role = Roster.role(choice.get("keywords", []))
	var list := Roster.new_list("11e", "Space Marines", "custom", 3000)
	var item: Dictionary = Roster.entry(choice, 0, 2)
	if definition == Adapter.DREADNOUGHT:
		Roster.set_model_equipment(item, 0, 0, "dreadnought_primary", "heavy-plasma-cannon")
		Roster.set_model_equipment(item, 0, 0, "dreadnought_secondary", "heavy-flamer")
	else:
		Roster.set_model_equipment(item, 0, 0, "venerable_dreadnought_legends_primary", "dreadnought-inferno-cannon")
		Roster.set_model_equipment(item, 0, 0, "venerable_dreadnought_legends_package", "heavy-flamer-and-fist")
	list.entries.append(item)
	var configured := Roster.model_equipment(item, 0, 0)
	var defaults := Adapter.defaults(definition)
	check(configured != defaults and Adapter.valid(definition, configured, 1), identity + " stores a changed legal loadout on its model identity")
	var admitted := Training.admit_current_catalog(list)
	check(admitted.error.is_empty(), identity + " passes current local catalog admission: " + str(admitted.get("error", "")))
	if admitted.error.is_empty():
		var variants: Array = admitted.selection.get("entries", [])
		check(variants.size() == 2 and variants.all(func(entry: Dictionary) -> bool: return entry.has("saved_model_loadouts")), identity + " retains both separately configured unit copies")
		var selections := F.current_marine_selections()
		selections[1] = admitted.selection
		selections[2].category = "custom"
		selections[2].points_limit = 3000
		var state: Dictionary = Prepared.initial_state({"checked_rosters": false, "official_mission": false, "unit_abilities": true}, selections)
		check(not state.has("error") and str(state.get("setup_error", "")).is_empty(), identity + " materializes without unresolved setup errors: " + str(state.get("setup_error", state.get("error", ""))))
		if not state.has("error"):
			var observed: Array[Dictionary] = []
			var configured_model := -1
			for model_id: int in state.units:
				var model: Dictionary = state.units[model_id]
				if int(model.get("owner", -1)) != 1 or C.UnitAbilities.identity(model) != identity: continue
				var equipment: Dictionary = model.get("saved_model_equipment", {})
				observed.append(equipment.duplicate(true))
				var expected: Dictionary
				if definition == Adapter.DREADNOUGHT:
					expected = Profiles.dreadnought_weapons(str(equipment.get("dreadnought_primary", "assault-cannon")), str(equipment.get("dreadnought_melee_package", "dreadnought-fist")), str(equipment.get("dreadnought_secondary", "none")))
				else:
					expected = Profiles.venerable_dreadnought_legends_weapons(str(equipment.get("venerable_dreadnought_legends_primary", "assault-cannon")), str(equipment.get("venerable_dreadnought_legends_package", "fist-and-storm-bolter")))
				var lock_field := "dreadnought_loadout_locked" if definition == Adapter.DREADNOUGHT else "venerable_dreadnought_legends_loadout_locked"
				check(Adapter.valid(definition, equipment, 1) and model.ranged_weapons == expected.ranged and model.melee_weapons == expected.melee and bool(model.get(lock_field, false)), identity + " installs the exact saved ranged/melee package and locks it")
				if equipment == configured: configured_model = model_id
			check(observed.size() == 2 and observed.any(func(value: Dictionary) -> bool: return value == configured) and observed.any(func(value: Dictionary) -> bool: return value == defaults), identity + " materializes one customized and one default copy independently")
			state.phase = "deployment"
			state.active = 1
			state.unit_abilities.setup_players = []
			var suppressed: Array[String] = ["dreadnought-primary", "dreadnought-melee-package", "dreadnought-secondary"]
			if definition == Adapter.VENERABLE_DREADNOUGHT: suppressed = ["venerable-dreadnought-legends-primary", "venerable-dreadnought-legends-package"]
			check(not Actions.choices(state, 1).any(func(option: Dictionary) -> bool: return str(option.get("action", "")) in suppressed), identity + " suppresses duplicate preparation choices for saved equipment")
			if configured_model >= 0:
				var model: Dictionary = state.units[configured_model]
				var before: Dictionary = model.duplicate(true)
				var action := "dreadnought-primary" if definition == Adapter.DREADNOUGHT else "venerable-dreadnought-legends-primary"
				var forced := {"action": action, "model": configured_model, "target": int(model.get("squad", -1)), "value": "assault-cannon"}
				check(not C.unit_action(state, 1, forced, Vector2.ZERO, int(state.revision)).is_empty() and state.units[configured_model].ranged_weapons == before.ranged_weapons, identity + " rejects a forced in-match loadout change without mutating the saved profile")

	var panel := Builder.new()
	panel.storage_path = "user://%s-saved-loadout-editor.json" % identity
	root.add_child(panel)
	panel.draft = list.duplicate(true)
	panel._render_draft()
	panel._select_entry(0)
	panel._render_sergeant_loadout_controls(1)
	check(panel.per_model_equipment_controls.get_child_count() == Adapter.controls(definition).size() * 2, identity + " renders each saved option group for both copies")
	if panel.per_model_equipment_controls.get_child_count() == Adapter.controls(definition).size() * 2:
		var picker := panel.per_model_equipment_controls.get_child(1) as OptionButton
		picker.select(0)
		picker.item_selected.emit(0)
		var edited := Roster.model_equipment(panel.draft.entries[0], 1, 0)
		var descriptor: Dictionary = Adapter.controls(definition)[0]
		var field := str(descriptor.field)
		check(panel.dirty and edited[field] == descriptor.choices[0].id and Roster.model_equipment(panel.draft.entries[0], 0, 0)[field] == configured[field], identity + " editor signals update only the chosen stable copy in the draft")
	panel.free()
