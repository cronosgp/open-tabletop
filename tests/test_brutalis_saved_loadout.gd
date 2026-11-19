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
	print("Brutalis saved-loadout checks: %d failures" % failures)
	quit(1 if failures else 0)

func check_source_schema() -> void:
	var definition := Adapter.BRUTALIS
	var controls := Adapter.controls(definition)
	var legal := 0
	for talons: Dictionary in controls[0].choices:
		for multi_melta: Dictionary in controls[1].choices:
			var equipment := Adapter.defaults(definition)
			equipment.brutalis_talons = talons.id
			equipment.brutalis_multi_melta = multi_melta.id
			var factory := Profiles.brutalis_weapons(bool(talons.id), bool(multi_melta.id))
			check(Adapter.valid(definition, equipment, 1) == not factory.is_empty(), "Brutalis admission matches the local source weapon factory")
			if not factory.is_empty(): legal += 1
	check(legal == 4, "Brutalis schema accepts both independent source replacements")
	check(not Adapter.valid(definition, Adapter.defaults(definition), 2), "Brutalis saved equipment remains limited to its one-model profile")
	var invalid_type := Adapter.defaults(definition)
	invalid_type.brutalis_talons = "talons"
	check(not Adapter.valid(definition, invalid_type, 1), "Brutalis saved equipment rejects non-boolean values")

func run_saved_copy_flow() -> void:
	var definition := Adapter.BRUTALIS
	var identity := "brutalis-dreadnought"
	var choice := Catalog.current_catalog_choice({"id": definition, "edition": "11e", "faction": "Space Marines"})
	choice.role = Roster.role(choice.get("keywords", []))
	var list := Roster.new_list("11e", "Space Marines", "custom", 2000)
	var item: Dictionary = Roster.entry(choice, 0, 3)
	var configured := [
		{"brutalis_talons": false, "brutalis_multi_melta": false},
		{"brutalis_talons": true, "brutalis_multi_melta": false},
		{"brutalis_talons": false, "brutalis_multi_melta": true},
	]
	for copy_index in range(configured.size()):
		for field: String in configured[copy_index]:
			Roster.set_model_equipment(item, copy_index, 0, field, configured[copy_index][field])
	list.entries.append(item)
	var admitted := Training.admit_current_catalog(list)
	check(admitted.error.is_empty(), "Three source-permitted Brutalis copies pass local admission: " + str(admitted.get("error", "")))
	if admitted.error.is_empty():
		var entries: Array = admitted.selection.get("entries", [])
		var admitted_loadouts: Array[Dictionary] = []
		for canonical_entry: Dictionary in entries:
			var copy_loadouts: Array = canonical_entry.get("saved_model_loadouts", [])
			if copy_loadouts.size() == 1 and copy_loadouts[0] is Dictionary: admitted_loadouts.append(copy_loadouts[0])
		check(entries.size() == 3 and admitted_loadouts.size() == 3 and admitted_loadouts.any(func(value: Dictionary) -> bool: return value == configured[0]) and admitted_loadouts.any(func(value: Dictionary) -> bool: return value == configured[1]) and admitted_loadouts.any(func(value: Dictionary) -> bool: return value == configured[2]), "Canonical admission preserves the independent package on every Brutalis copy")
		var selections := F.current_marine_selections()
		selections[1] = admitted.selection
		selections[1].category = "custom"
		selections[1].points_limit = 2000
		selections[2].category = "custom"
		selections[2].points_limit = 2000
		var state: Dictionary = Prepared.initial_state({"checked_rosters": false, "official_mission": false, "unit_abilities": true}, selections)
		check(not state.has("error") and str(state.get("setup_error", "")).is_empty(), "Saved Brutalis copies materialize without setup errors: " + str(state.get("setup_error", state.get("error", ""))))
		if not state.has("error"):
			var observed: Array[Dictionary] = []
			var editable_model := -1
			for model_id: int in state.units:
				var model: Dictionary = state.units[model_id]
				if int(model.get("owner", -1)) != 1 or C.UnitAbilities.identity(model) != identity: continue
				var equipment: Dictionary = model.get("saved_model_equipment", {})
				observed.append(equipment.duplicate(true))
				var expected := Profiles.brutalis_weapons(bool(equipment.get("brutalis_talons", false)), bool(equipment.get("brutalis_multi_melta", false)))
				check(Adapter.valid(definition, equipment, 1) and model.ranged_weapons == expected.ranged and model.melee_weapons == expected.melee and bool(model.get("brutalis_loadout_locked", false)), "Saved Brutalis copy materializes exact weapons and locks them")
				if equipment == configured[0]: editable_model = model_id
			check(observed.size() == 3 and observed.any(func(value: Dictionary) -> bool: return value == configured[0]) and observed.any(func(value: Dictionary) -> bool: return value == configured[1]) and observed.any(func(value: Dictionary) -> bool: return value == configured[2]), "Different Brutalis copies retain their own saved packages")
			state.phase = "deployment"
			state.active = 1
			state.unit_abilities.setup_players = []
			check(not Actions.choices(state, 1).any(func(option: Dictionary) -> bool: return str(option.get("action", "")) in ["brutalis-melee", "brutalis-ranged"]), "Saved Brutalis copies suppress duplicate preparation choices")
			if editable_model >= 0:
				var before: Dictionary = state.units[editable_model].duplicate(true)
				var forced := {"action": "brutalis-ranged", "model": editable_model, "target": int(before.get("squad", -1)), "value": "multi-melta"}
				var result: String = C.unit_action(state, 1, forced, Vector2.ZERO, int(state.revision))
				check(not result.is_empty() and state.units[editable_model].ranged_weapons == before.ranged_weapons and state.units[editable_model].melee_weapons == before.melee_weapons, "Forced preparation edit cannot replace saved Brutalis weapons")

	var panel := Builder.new()
	panel.storage_path = "user://brutalis-saved-loadout-editor.json"
	root.add_child(panel)
	panel.draft = list.duplicate(true)
	panel._render_draft()
	panel._select_entry(0)
	panel._render_sergeant_loadout_controls(2)
	check(panel.per_model_equipment_controls.get_child_count() == 4, "Workshop renders both Brutalis equipment controls")
	if panel.per_model_equipment_controls.get_child_count() >= 4:
		var picker := panel.per_model_equipment_controls.get_child(1) as OptionButton
		picker.select(1)
		picker.item_selected.emit(1)
		var edited := Roster.model_equipment(panel.draft.entries[0], 2, 0)
		check(panel.dirty and bool(edited.brutalis_talons) and bool(edited.brutalis_multi_melta) and Roster.model_equipment(panel.draft.entries[0], 0, 0) == configured[0] and Roster.model_equipment(panel.draft.entries[0], 1, 0) == configured[1], "Workshop edits one Brutalis copy and preserves its independent weapon choice and neighbors")
	panel.free()
