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
	print("Terminator Captain saved-loadout checks: %d failures" % failures)
	quit(1 if failures else 0)

func check_source_schema() -> void:
	var definition := Adapter.TERMINATOR_CAPTAIN
	var controls := Adapter.controls(definition)
	var legal := 0
	for combi: Dictionary in controls[0].choices:
		for fist: Dictionary in controls[1].choices:
			var equipment := Adapter.defaults(definition)
			equipment.terminator_captain_combi_weapon = combi.id
			equipment.terminator_captain_relic_fist = fist.id
			var factory := Profiles.terminator_captain_weapons(bool(combi.id), bool(fist.id))
			check(Adapter.valid(definition, equipment, 1) == not factory.is_empty(), "Terminator Captain admission matches both independent local replacements")
			if not factory.is_empty(): legal += 1
	check(legal == 4, "Terminator Captain schema accepts all four combinations of independent replacements")
	check(not Adapter.valid(definition, Adapter.defaults(definition), 2), "Terminator Captain equipment schema stays one model per unit copy")
	var invalid_type := Adapter.defaults(definition)
	invalid_type.terminator_captain_combi_weapon = "combi"
	check(not Adapter.valid(definition, invalid_type, 1), "Terminator Captain rejects string values for boolean equipment fields")

func run_saved_copy_flow() -> void:
	var definition := Adapter.TERMINATOR_CAPTAIN
	var identity := "captain-in-terminator-armour"
	var choice := Catalog.current_catalog_choice({"id": definition, "edition": "11e", "faction": "Space Marines"})
	choice.role = Roster.role(choice.get("keywords", []))
	var list := Roster.new_list("11e", "Space Marines", "custom", 2000)
	var item: Dictionary = Roster.entry(choice, 0, 1)
	var configured := {"terminator_captain_combi_weapon": true, "terminator_captain_relic_fist": true}
	for field: String in configured: Roster.set_model_equipment(item, 0, 0, field, configured[field])
	list.entries.append(item)
	check(Roster.model_equipment(item, 0, 0) == configured, "Workshop storage retains both independent Captain choices")
	var admitted := Training.admit_current_catalog(list)
	check(admitted.error.is_empty(), "Configured Terminator Captain passes current-catalog admission: " + str(admitted.get("error", "")))
	if admitted.error.is_empty():
		var entry: Dictionary = admitted.selection.entries[0]
		check(entry.saved_model_loadouts == [configured], "Canonical admission preserves the complete saved package")
		var selections := F.current_marine_selections()
		selections[1] = admitted.selection
		selections[1].category = "custom"
		selections[1].points_limit = 2000
		selections[2].category = "custom"
		selections[2].points_limit = 2000
		var state: Dictionary = Prepared.initial_state({"checked_rosters": false, "official_mission": false, "unit_abilities": true}, selections)
		check(not state.has("error") and str(state.get("setup_error", "")).is_empty(), "Saved Terminator Captain materializes without setup errors: " + str(state.get("setup_error", state.get("error", ""))))
		if not state.has("error"):
			var captain := -1
			for model_id: int in state.units:
				var model: Dictionary = state.units[model_id]
				if int(model.get("owner", -1)) == 1 and C.UnitAbilities.identity(model) == identity: captain = model_id
			check(captain >= 0, "Prepared roster contains the saved Terminator Captain")
			if captain >= 0:
				var model: Dictionary = state.units[captain]
				var expected := Profiles.terminator_captain_weapons(true, true)
				check(model.get("saved_model_equipment", {}) == configured and model.ranged_weapons == expected.ranged and model.melee_weapons == expected.melee and bool(model.get("terminator_captain_loadout_locked", false)), "Saved Captain copy materializes the Combi-weapon and Relic Fist profiles and locks them")
				state.phase = "deployment"
				state.active = 1
				state.unit_abilities.setup_players = []
				check(not Actions.choices(state, 1).any(func(option: Dictionary) -> bool: return str(option.get("action", "")) in ["terminator-captain-gun", "terminator-captain-blade"]), "Saved Terminator Captain suppresses duplicate preparation choices")
				var forced := {"action": "terminator-captain-gun", "model": captain, "target": int(model.get("squad", -1)), "value": "bolter"}
				var result: String = C.unit_action(state, 1, forced, Vector2.ZERO, int(state.revision))
				check(not result.is_empty() and state.units[captain].ranged_weapons == expected.ranged and state.units[captain].melee_weapons == expected.melee, "Forced setup edit cannot replace saved Captain weapons")

	var panel := Builder.new()
	panel.storage_path = "user://terminator-captain-saved-loadout-editor.json"
	root.add_child(panel)
	panel.draft = list.duplicate(true)
	panel._render_draft()
	panel._select_entry(0)
	panel._render_sergeant_loadout_controls(1)
	check(panel.per_model_equipment_controls.get_child_count() == 4, "Workshop renders both Terminator Captain equipment selectors")
	if panel.per_model_equipment_controls.get_child_count() >= 4:
		var picker := panel.per_model_equipment_controls.get_child(1) as OptionButton
		picker.select(0)
		picker.item_selected.emit(0)
		var edited := Roster.model_equipment(panel.draft.entries[0], 0, 0)
		check(panel.dirty and not bool(edited.terminator_captain_combi_weapon) and bool(edited.terminator_captain_relic_fist), "Workshop edits the ranged replacement while preserving the independent melee choice")
	panel.free()
