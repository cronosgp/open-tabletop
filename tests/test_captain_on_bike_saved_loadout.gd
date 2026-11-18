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
	run_saved_copy_flow()
	print("Captain on Bike saved-loadout checks: %d failures" % failures)
	quit(1 if failures else 0)

func check_source_schema() -> void:
	var definition := Adapter.BIKE_CAPTAIN
	var controls := Adapter.controls(definition)
	var legal := 0
	for pistol: Dictionary in controls[0].choices:
		for melee: Dictionary in controls[1].choices:
			var equipment := Adapter.defaults(definition)
			equipment.captain_bike_plasma_pistol = pistol.id
			equipment.captain_bike_thunder_hammer = melee.id
			var factory := Profiles.captain_bike_weapons(bool(pistol.id), bool(melee.id))
			check(Adapter.valid(definition, equipment, 1) == not factory.is_empty(), "Captain on Bike schema matches the local independent weapon factories")
			if not factory.is_empty(): legal += 1
	check(legal == 4, "Captain on Bike schema accepts all four combinations of its independent replacements")
	check(not Adapter.valid(definition, Adapter.defaults(definition), 2), "Captain on Bike saved equipment stays scoped to its one model")
	var invalid_type := Adapter.defaults(definition)
	invalid_type.captain_bike_plasma_pistol = "plasma"
	check(not Adapter.valid(definition, invalid_type, 1), "Captain on Bike rejects non-boolean saved equipment values")

func run_saved_copy_flow() -> void:
	var definition := Adapter.BIKE_CAPTAIN
	var identity := "captain-on-bike"
	var choice := Catalog.current_catalog_choice({"id": definition, "edition": "11e", "faction": "Space Marines"})
	choice.role = Roster.role(choice.get("keywords", []))
	var list := Roster.new_list("11e", "Space Marines", "custom", 2000)
	var item: Dictionary = Roster.entry(choice, 0, 3)
	var configured := [
		{"captain_bike_plasma_pistol": false, "captain_bike_thunder_hammer": false},
		{"captain_bike_plasma_pistol": true, "captain_bike_thunder_hammer": true},
		{"captain_bike_plasma_pistol": false, "captain_bike_thunder_hammer": true},
	]
	for copy_index in range(configured.size()):
		for field: String in configured[copy_index]:
			Roster.set_model_equipment(item, copy_index, 0, field, configured[copy_index][field])
	list.entries.append(item)
	for equipment: Dictionary in configured: check(Adapter.valid(definition, equipment, 1), "Saved Bike Captain copy uses a source-legal package")
	var admitted := Training.admit_current_catalog(list)
	check(admitted.error.is_empty(), "Three source-permitted Captain on Bike copies pass local admission: " + str(admitted.get("error", "")))
	if admitted.error.is_empty():
		var entries: Array = admitted.selection.get("entries", [])
		var admitted_loadouts: Array[Dictionary] = []
		for canonical_entry: Dictionary in entries:
			var copy_loadouts: Array = canonical_entry.get("saved_model_loadouts", [])
			if copy_loadouts.size() == 1 and copy_loadouts[0] is Dictionary: admitted_loadouts.append(copy_loadouts[0])
		check(entries.size() == 3 and admitted_loadouts.size() == 3 and admitted_loadouts.any(func(value: Dictionary) -> bool: return value == configured[0]) and admitted_loadouts.any(func(value: Dictionary) -> bool: return value == configured[1]) and admitted_loadouts.any(func(value: Dictionary) -> bool: return value == configured[2]), "Canonical admission retains independent equipment on every Captain copy")
		var selections := F.current_marine_selections()
		selections[1] = admitted.selection
		selections[1].category = "custom"
		selections[1].points_limit = 2000
		selections[2].category = "custom"
		selections[2].points_limit = 2000
		var state: Dictionary = Prepared.initial_state({"checked_rosters": false, "official_mission": false, "unit_abilities": true}, selections)
		check(not state.has("error") and str(state.get("setup_error", "")).is_empty(), "Saved Captain on Bike copies materialize without setup errors: " + str(state.get("setup_error", state.get("error", ""))))
		if not state.has("error"):
			var observed: Array[Dictionary] = []
			var editable_model := -1
			for model_id: int in state.units:
				var model: Dictionary = state.units[model_id]
				if int(model.get("owner", -1)) != 1 or C.UnitAbilities.identity(model) != identity: continue
				var equipment: Dictionary = model.get("saved_model_equipment", {})
				observed.append(equipment.duplicate(true))
				var expected := Profiles.captain_bike_weapons(bool(equipment.get("captain_bike_plasma_pistol", false)), bool(equipment.get("captain_bike_thunder_hammer", false)))
				check(Adapter.valid(definition, equipment, 1) and model.ranged_weapons == expected.ranged and model.melee_weapons == expected.melee and bool(model.get("captain_bike_loadout_locked", false)), "Saved Captain copy materializes exact weapons and blocks match-time edits")
				if equipment == configured[0]: editable_model = model_id
			check(observed.size() == 3 and observed.any(func(value: Dictionary) -> bool: return value == configured[0]) and observed.any(func(value: Dictionary) -> bool: return value == configured[1]) and observed.any(func(value: Dictionary) -> bool: return value == configured[2]), "Three permitted Bike Captain copies preserve their independent packages")
			state.phase = "deployment"
			state.active = 1
			state.unit_abilities.setup_players = []
			check(not Actions.choices(state, 1).any(func(option: Dictionary) -> bool: return str(option.get("action", "")) in ["captain-bike-pistol", "captain-bike-melee"]), "Saved Captain on Bike copies suppress duplicate preparation choices")
			if editable_model >= 0:
				var before: Dictionary = state.units[editable_model].duplicate(true)
				var forced := {"action": "captain-bike-pistol", "model": editable_model, "target": int(before.get("squad", -1)), "value": "plasma"}
				var result: String = C.unit_action(state, 1, forced, Vector2.ZERO, int(state.revision))
				check(not result.is_empty() and state.units[editable_model].ranged_weapons == before.ranged_weapons and state.units[editable_model].melee_weapons == before.melee_weapons, "Forced setup edit cannot replace saved Bike Captain weapons")

	var panel := Builder.new()
	panel.storage_path = "user://captain-on-bike-saved-loadout-editor.json"
	root.add_child(panel)
	panel.draft = list.duplicate(true)
	panel._render_draft()
	panel._select_entry(0)
	panel._render_sergeant_loadout_controls(2)
	check(panel.per_model_equipment_controls.get_child_count() == 4, "Workshop renders the two Captain on Bike replacement selectors")
	if panel.per_model_equipment_controls.get_child_count() >= 4:
		var picker := panel.per_model_equipment_controls.get_child(1) as OptionButton
		picker.select(1)
		picker.item_selected.emit(1)
		var edited := Roster.model_equipment(panel.draft.entries[0], 2, 0)
		check(panel.dirty and bool(edited.captain_bike_plasma_pistol) and bool(edited.captain_bike_thunder_hammer) and Roster.model_equipment(panel.draft.entries[0], 0, 0) == configured[0] and Roster.model_equipment(panel.draft.entries[0], 1, 0) == configured[1], "Workshop edits only the selected copy and preserves its independent melee choice")
	panel.free()
