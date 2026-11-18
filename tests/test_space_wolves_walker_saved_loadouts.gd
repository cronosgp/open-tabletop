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
	for definition: String in [Adapter.BJORN, Adapter.SPACE_WOLVES_VENERABLE, Adapter.WULFEN_DREADNOUGHT]:
		run_saved_copy_flow(definition)
	var invalid := Adapter.defaults(Adapter.SPACE_WOLVES_VENERABLE)
	invalid.space_wolves_walker_primary = "multi-melta"
	invalid.space_wolves_walker_melee_package = "fenrisian-great-axe-blizzard-shield"
	check(not Adapter.valid(Adapter.SPACE_WOLVES_VENERABLE, invalid, 1), "Venerable Dreadnought saved schema rejects its source-listed conflicting weapon combination")
	print("Space Wolves walker saved-loadout checks: %d failures" % failures)
	quit(1 if failures else 0)

func check_source_option_schemas() -> void:
	var bjorn_controls := Adapter.controls(Adapter.BJORN)
	var bjorn_legal := 0
	for primary: Dictionary in bjorn_controls[0].choices:
		var equipment := Adapter.defaults(Adapter.BJORN)
		equipment.space_wolves_walker_primary = primary.id
		var factory := Profiles.space_wolves_walker_weapons("bjorn-the-fell-handed", str(primary.id))
		check(Adapter.valid(Adapter.BJORN, equipment, 1) == not factory.is_empty(), "Bjorn admission matches the local source weapon factory")
		if not factory.is_empty(): bjorn_legal += 1
	check(bjorn_legal == 3 and not Adapter.valid(Adapter.BJORN, Adapter.defaults(Adapter.BJORN), 2), "Bjorn schema admits all three source choices and only its one-model profile")

	var venerable_controls := Adapter.controls(Adapter.SPACE_WOLVES_VENERABLE)
	var venerable_legal := 0
	for primary: Dictionary in venerable_controls[0].choices:
		for secondary: Dictionary in venerable_controls[1].choices:
			for melee: Dictionary in venerable_controls[2].choices:
				var equipment := Adapter.defaults(Adapter.SPACE_WOLVES_VENERABLE)
				equipment.space_wolves_walker_primary = primary.id
				equipment.space_wolves_walker_secondary = secondary.id
				equipment.space_wolves_walker_melee_package = melee.id
				var factory := Profiles.space_wolves_walker_weapons("venerable-dreadnought", str(primary.id), str(secondary.id), str(melee.id))
				check(Adapter.valid(Adapter.SPACE_WOLVES_VENERABLE, equipment, 1) == not factory.is_empty(), "Venerable Dreadnought admission matches its source replacement groups")
				if not factory.is_empty(): venerable_legal += 1
	check(venerable_legal == 8, "Venerable Dreadnought schema accepts exactly its eight source-legal combinations")
	check(not Adapter.valid(Adapter.SPACE_WOLVES_VENERABLE, Adapter.defaults(Adapter.SPACE_WOLVES_VENERABLE), 2), "Venerable Dreadnought schema is limited to its one-model unit copy")

	var wulfen_controls := Adapter.controls(Adapter.WULFEN_DREADNOUGHT)
	var wulfen_legal := 0
	for secondary: Dictionary in wulfen_controls[0].choices:
		for melee: Dictionary in wulfen_controls[1].choices:
			var equipment := Adapter.defaults(Adapter.WULFEN_DREADNOUGHT)
			equipment.space_wolves_walker_secondary = secondary.id
			equipment.space_wolves_walker_melee_package = melee.id
			var factory := Profiles.space_wolves_walker_weapons("wulfen-dreadnought", "", str(secondary.id), str(melee.id))
			check(Adapter.valid(Adapter.WULFEN_DREADNOUGHT, equipment, 1) == not factory.is_empty(), "Wulfen Dreadnought admission matches its source replacement groups")
			if not factory.is_empty(): wulfen_legal += 1
	check(wulfen_legal == 4 and not Adapter.valid(Adapter.WULFEN_DREADNOUGHT, Adapter.defaults(Adapter.WULFEN_DREADNOUGHT), 2), "Wulfen Dreadnought schema admits all four combinations and only its one-model copy")

func configured_equipment(definition: String) -> Dictionary:
	var equipment := Adapter.defaults(definition)
	if definition == Adapter.BJORN:
		equipment.space_wolves_walker_primary = "helfrost-cannon"
	elif definition == Adapter.SPACE_WOLVES_VENERABLE:
		equipment.space_wolves_walker_secondary = "heavy-flamer"
		equipment.space_wolves_walker_melee_package = "fenrisian-great-axe-blizzard-shield"
	else:
		equipment.space_wolves_walker_secondary = "heavy-flamer"
		equipment.space_wolves_walker_melee_package = "blizzard-shield"
	return equipment

func run_saved_copy_flow(definition: String) -> void:
	var identity := definition.get_slice(":", 3)
	var copy_count := 1 if definition == Adapter.BJORN else 2
	var choice := Catalog.current_catalog_choice({"id": definition, "edition": "11e", "faction": "Space Marines"})
	choice.role = Roster.role(choice.get("keywords", []))
	var list := Roster.new_list("11e", "Space Marines", "custom", 3000)
	var item: Dictionary = Roster.entry(choice, 0, copy_count)
	var configured := configured_equipment(definition)
	for field: String in configured: Roster.set_model_equipment(item, 0, 0, field, configured[field])
	list.entries.append(item)
	check(Adapter.valid(definition, Roster.model_equipment(item, 0, 0), 1), identity + " saves a legal source-listed configuration")
	var admitted := Training.admit_current_catalog(list)
	check(admitted.error.is_empty(), identity + " passes local current-catalog admission: " + str(admitted.get("error", "")))
	if admitted.error.is_empty():
		var variants: Array = admitted.selection.get("entries", [])
		check(variants.size() == copy_count and variants.all(func(entry: Dictionary) -> bool: return entry.has("saved_model_loadouts")), identity + " retains a saved loadout record per copy")
		var selections := F.current_marine_selections()
		selections[1] = admitted.selection
		selections[1].category = "custom"
		selections[1].points_limit = 3000
		selections[2].category = "custom"
		selections[2].points_limit = 3000
		var state: Dictionary = Prepared.initial_state({"checked_rosters": false, "official_mission": false, "unit_abilities": true, "marine_chapters": {1: "SPACE WOLVES", 2: "SPACE WOLVES"}}, selections)
		check(not state.has("error") and str(state.get("setup_error", "")).is_empty(), identity + " materializes without setup errors: " + str(state.get("setup_error", state.get("error", ""))))
		if not state.has("error"):
			var observed: Array[Dictionary] = []
			var configured_model := -1
			for model_id: int in state.units:
				var model: Dictionary = state.units[model_id]
				if int(model.get("owner", -1)) != 1 or C.UnitAbilities.identity(model) != identity: continue
				var equipment: Dictionary = model.get("saved_model_equipment", {})
				observed.append(equipment.duplicate(true))
				var expected := Profiles.space_wolves_walker_weapons(identity, str(equipment.get("space_wolves_walker_primary", "")), str(equipment.get("space_wolves_walker_secondary", "")), str(equipment.get("space_wolves_walker_melee_package", "")))
				check(Adapter.valid(definition, equipment, 1) and model.ranged_weapons == expected.ranged and model.melee_weapons == expected.melee and bool(model.get("space_wolves_blizzard_shield", false)) == bool(expected.blizzard_shield) and bool(model.get("space_wolves_walker_loadout_locked", false)), identity + " installs and locks the exact ranged/melee profile and shield state")
				if equipment == configured: configured_model = model_id
			var defaults := Adapter.defaults(definition)
			check(observed.size() == copy_count and observed.any(func(value: Dictionary) -> bool: return value == configured) and (copy_count == 1 or observed.any(func(value: Dictionary) -> bool: return value == defaults)), identity + " materializes configured and default copies independently")
			state.phase = "deployment"
			state.active = 1
			state.unit_abilities.setup_players = []
			check(not Actions.choices(state, 1).any(func(option: Dictionary) -> bool: return str(option.get("action", "")) == "space-wolves-walker-loadout"), identity + " suppresses duplicate match-preparation choices")
			if configured_model >= 0:
				var configured_unit: Dictionary = state.units[configured_model]
				var before := configured_unit.duplicate(true)
				var target_category := 1 if identity == "wulfen-dreadnought" else 0
				var forced_value := "heavy-flamer" if target_category == 1 else "multi-melta"
				var forced := {"action": "space-wolves-walker-loadout", "model": configured_model, "target": target_category, "value": forced_value}
				check(not C.unit_action(state, 1, forced, Vector2.ZERO, int(state.revision)).is_empty() and state.units[configured_model].ranged_weapons == before.ranged_weapons and state.units[configured_model].melee_weapons == before.melee_weapons, identity + " rejects forced match-preparation edits without mutating saved weapons")

	var panel := Builder.new()
	panel.storage_path = "user://%s-walker-loadout-editor.json" % identity
	root.add_child(panel)
	panel.draft = list.duplicate(true)
	panel._render_draft()
	panel._select_entry(0)
	var edited_copy := mini(1, copy_count - 1)
	panel._render_sergeant_loadout_controls(edited_copy)
	check(panel.per_model_equipment_controls.get_child_count() == Adapter.controls(definition).size() * 2, identity + " renders every saved option group")
	if panel.per_model_equipment_controls.get_child_count() == Adapter.controls(definition).size() * 2:
		var picker := panel.per_model_equipment_controls.get_child(1) as OptionButton
		picker.select(0)
		picker.item_selected.emit(0)
		var edited := Roster.model_equipment(panel.draft.entries[0], edited_copy, 0)
		var first_descriptor: Dictionary = Adapter.controls(definition)[0]
		var first_field := str(first_descriptor.field)
		var preserves_other_copy := copy_count == 1 or Roster.model_equipment(panel.draft.entries[0], 0, 0) == configured
		check(panel.dirty and edited[first_field] == first_descriptor.choices[0].id and preserves_other_copy, identity + " editor signals update the selected copy and preserve its sibling")
	panel.free()
