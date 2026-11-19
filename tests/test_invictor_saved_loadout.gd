extends SceneTree
const Roster = preload("res://scripts/army_roster.gd")
const Catalog = preload("res://scripts/edition_11/army_capabilities.gd")
const Training = preload("res://scripts/edition_11/training_roster.gd")
const Prepared = preload("res://scripts/edition_11/prepared_training.gd")
const Builder = preload("res://scripts/army_builder_panel.gd")
const Actions = preload("res://scripts/edition_11/unit_actions.gd")
const Adapter = preload("res://scripts/edition_11/saved_equipment_profiles.gd")
const PublicCommand = preload("res://tests/public_unit_command.gd")
var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var choice := Catalog.current_catalog_choice({"id": Adapter.INVICTOR, "edition": "11e", "faction": "Space Marines"})
	choice.role = "Vehicle"
	var list := Roster.new_list("11e", "Space Marines", "strike_force", 2000)
	var item := Roster.entry(choice, 0, 2)
	Roster.set_model_equipment(item, 0, 0, "invictor_cannon", "autocannon")
	list.entries.append(item)
	var admitted := Training.admit_current_catalog(list)
	check(admitted.error.is_empty(), "Independent Invictor choices pass admission")
	if not admitted.error.is_empty():
		quit(1)
		return
	var state := Prepared.initial_state({"checked_rosters": false, "official_mission": false, "unit_abilities": true}, {1: admitted.selection, 2: admitted.selection})
	check(not state.has("error"), "Saved Invictors materialize: " + str(state.get("error", "")))
	var choices: Array[bool] = []
	if not state.has("error"):
		for id: int in state.units:
			var model: Dictionary = state.units[id]
			if int(model.owner) == 1:
				choices.append(bool(model.get("invictor_autocannon", false)))
				check(bool(model.get("invictor_loadout_locked", false)), "Saved Invictor is locked")
				check(model.ranged_weapons == Adapter.Marines.invictor_weapons(bool(model.invictor_autocannon)), "Exact source-listed weapon package materialized")
		state.phase = "deployment"
		state.active = 1
		state.unit_abilities.setup_players = []
		check(not Actions.choices(state, 1).any(func(option: Dictionary) -> bool: return option.get("action") == "invictor-gun"), "Saved copies suppress duplicate equipment setup")
		var model_id: int = state.units.keys()[0]
		var before: Array = state.units[model_id].ranged_weapons.duplicate(true)
		var forced := PublicCommand.submit(state, int(state.units[model_id].owner), {"action": "invictor-gun", "model": model_id, "target": int(state.units[model_id].squad), "value": "incendium"})
		check(not str(forced.get("error", "")).is_empty() and before == state.units[model_id].ranged_weapons, "Forced saved-loadout changes fail without mutation")
	check(choices.size() == 2 and choices.has(true) and choices.has(false), "Canonical grouping preserves different Invictor copies")
	var invalid: Dictionary = admitted.selection.duplicate(true)
	invalid.entries[0].saved_model_loadouts = [{"invictor_cannon": "invented"}]
	check(not Catalog.admit(invalid).get("error", "").is_empty(), "Admission rejects unsupported registered equipment")
	var panel := Builder.new()
	panel.storage_path = "user://invictor-editor-regression.json"
	root.add_child(panel)
	panel.draft = list.duplicate(true)
	panel._render_draft()
	panel._select_entry(0)
	check(panel.sergeant_loadout_heading.visible and panel.per_model_equipment_controls.get_child_count() == 2, "Registered equipment renders its label and accessible picker")
	var picker := panel.per_model_equipment_controls.get_child(1) as OptionButton
	picker.select(0)
	picker.item_selected.emit(0)
	check(Roster.model_equipment(panel.draft.entries[0], 0, 0).invictor_cannon == "incendium" and panel.dirty, "Generic picker edits the selected stable copy")
	panel.free()
	print("Invictor saved-loadout checks: %d failures" % failures)
	quit(1 if failures else 0)
