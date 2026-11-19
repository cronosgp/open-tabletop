extends SceneTree

const E = preload("res://scripts/edition_11/saved_equipment_profiles.gd")
const P = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const R = preload("res://scripts/army_roster.gd")
const Catalog = preload("res://scripts/implemented_army_catalog.gd")
const Store = preload("res://scripts/army_profiles.gd")
const Training = preload("res://scripts/edition_11/training_roster.gd")
const Prepared = preload("res://scripts/edition_11/prepared_training.gd")
const Actions = preload("res://scripts/edition_11/unit_actions.gd")
const Builder = preload("res://scripts/army_builder_panel.gd")
const UNIT := "40kdc:11e:adeptus-astartes:crusader-squad"
const LOADOUT := "crusader_squad_loadout"
const HEAVY_OPTIONS := ["heavy-pistol-power-fist", "pyreblaster"]

var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func _initialize() -> void:
	call_deferred("run")

func records(models: int) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for model_index in range(models): result.append(E.defaults_for_model(UNIT, models, model_index))
	return result

func entry(catalog: Node, models: int, copies: int = 1) -> Dictionary:
	var source: Dictionary = catalog.lookup(UNIT)
	for index in range(source.options.size()):
		if int(source.options[index].models) == models: return R.entry(source, index, copies)
	check(false, "The %d-model Crusader Squad entry exists in the consolidated local catalog" % models)
	return {}

func set_choice(item: Dictionary, copy_index: int, model_index: int, loadout_id: String, message: String) -> void:
	check(R.set_model_equipment(item, copy_index, model_index, LOADOUT, loadout_id), message)

func make_army(catalog: Node) -> Dictionary:
	var army := R.new_list("11e", "Space Marines", "custom", 3000)
	army.name = "Crusader saved equipment review"
	var item := entry(catalog, 10, 3)
	army.entries = [item]
	set_choice(item, 0, 0, "hand-flamer", "First copy saves the Sword Brother Hand Flamer")
	set_choice(item, 0, 1, "shotgun", "First copy saves a Neophyte Shotgun and Combat Knife")
	set_choice(item, 0, 5, "heavy-pistol-power-fist", "First copy saves one Initiate Power Fist")
	set_choice(item, 0, 6, "pyreblaster", "First copy saves its second limited Initiate replacement")
	set_choice(item, 1, 2, "shotgun", "Second copy saves a different Neophyte replacement")
	set_choice(item, 1, 9, "pistol-chainsword", "Second copy saves the unlimited Initiate pistol and chainsword package")
	return army

func check_source_options() -> void:
	check(E.supports(UNIT) and E.is_model_scoped(UNIT) and E.uses_stacked_model_controls(UNIT), "Crusader uses per-model saved equipment cards")
	check(str(P.profile("crusader-squad").get("source_book_id", "")) == "000000162" and str(P.profile("crusader-squad").get("source_datasheet_id", "")) == "000002799", "The local weapon factory matches the audited Black Templars App datasheet")
	for models in [10, 20]:
		var defaults := records(models)
		check(E.valid_saved_loadout(UNIT, defaults, models) and E.points_for_loadout(UNIT, defaults, models) == 0, "%d-model source defaults are valid and equipment adds no points" % models)
		var neophyte_first := 1
		var initiate_first := 5 if models == 10 else 9
		check(E.visual_model_role(UNIT, models, 0) == "Sword Brother" and E.model_label(UNIT, models, 0) == "Sword Brother", "%d-model roster starts with the source Sword Brother" % models)
		check(E.visual_model_role(UNIT, models, neophyte_first) == "Neophyte" and E.model_label(UNIT, models, neophyte_first) == "Neophyte 1", "%d-model roster labels its first Neophyte" % models)
		check(E.visual_model_role(UNIT, models, initiate_first) == "Initiate" and E.model_label(UNIT, models, initiate_first) == "Initiate 1", "%d-model roster labels its first Initiate" % models)
		check(E.controls_for_model(UNIT, 0, models)[0].choices.size() == 2 and E.controls_for_model(UNIT, neophyte_first, models)[0].choices.size() == 2 and E.controls_for_model(UNIT, initiate_first, models)[0].choices.size() == 4, "Each source role exposes only its eligible loadout choices")
		var all_allowed := defaults.duplicate(true)
		all_allowed[0][LOADOUT] = "hand-flamer"
		all_allowed[neophyte_first][LOADOUT] = "shotgun"
		for slot in range(int(models / 10) * 2): all_allowed[initiate_first + slot][LOADOUT] = HEAVY_OPTIONS[slot % HEAVY_OPTIONS.size()]
		check(E.valid_saved_loadout(UNIT, all_allowed, models), "%d-model unit accepts its exact source limit of Initiate heavy replacements" % models)
		var excess := all_allowed.duplicate(true)
		excess[initiate_first + int(models / 10) * 2][LOADOUT] = "pyreblaster"
		check(not E.valid_saved_loadout(UNIT, excess, models), "%d-model unit rejects one more heavy replacement than the source limit" % models)
		var prepared: Dictionary = {}
		var selected_id := "hand-flamer" if models == 10 else "pyreblaster"
		var selected_index := 0 if models == 10 else initiate_first
		var selected := {LOADOUT: selected_id}
		var expected := P.crusader_squad_model_loadout(selected_index, models, selected_id)
		E.prepare(prepared, UNIT, selected, models, selected_index)
		check(E.valid_for_model(UNIT, selected_index, selected, models) and not expected.is_empty() and prepared.ranged_weapons == expected.ranged and prepared.melee_weapons == expected.melee, "%d-model saved selection resolves through the exact local weapon factory" % models)
		check(prepared.get("saved_model_equipment", {}) == selected and bool(prepared.get("crusader_squad_saved_equipment_locked", false)), "%d-model prepared choice retains saved record and setup lock" % models)
	var wrong_role := {LOADOUT: "hand-flamer"}
	check(not E.valid_for_model(UNIT, 1, wrong_role, 10) and not E.valid_for_model(UNIT, 5, {LOADOUT: "shotgun"}, 10), "Sword Brother and Neophyte replacements are rejected on other roles")
	check(not E.valid_for_model(UNIT, 5, {LOADOUT: "not-a-source-choice"}, 10), "Unknown Initiate equipment is rejected")
	check(not E.valid_for_model(UNIT, 5, {LOADOUT: true}, 10), "Saved loadout fields reject wrong value types")
	check(not E.valid_saved_loadout(UNIT, records(10).slice(0, 9), 10) and not E.valid_saved_loadout(UNIT, records(11), 11), "Short records and unsupported Crusader sizes are rejected")

func inspect_bank(army: Dictionary) -> void:
	check(R.validate(army).is_empty(), "Saved Crusader list passes whole-roster validation")
	check(R.summary(army).points == 480, "Three ten-model copies retain their local Wahapedia 160-point price")
	var first := R.model_equipment_loadouts(army.entries[0], 0)
	var second := R.model_equipment_loadouts(army.entries[0], 1)
	var third := R.model_equipment_loadouts(army.entries[0], 2)
	check(first[0][LOADOUT] == "hand-flamer" and first[1][LOADOUT] == "shotgun" and first[5][LOADOUT] == HEAVY_OPTIONS[0] and first[6][LOADOUT] == HEAVY_OPTIONS[1], "First copy reopens all selected model roles and limited replacements")
	check(second[2][LOADOUT] == "shotgun" and second[9][LOADOUT] == "pistol-chainsword", "Second copy retains independent Neophyte and Initiate selections")
	check(E.valid_saved_loadout(UNIT, first, 10) and E.valid_saved_loadout(UNIT, second, 10) and E.valid_saved_loadout(UNIT, third, 10), "Each reopened copy passes the whole-unit source validator")
	check(third == records(10), "The untouched third copy retains all source defaults")

func find_model_in_squad(state: Dictionary, owner: int, squad: int, model_index: int) -> int:
	for model: int in state.units:
		var unit: Dictionary = state.units[model]
		if int(unit.get("owner", -1)) == owner and int(unit.get("squad", -1)) == squad and int(unit.get("saved_equipment_model_index", -1)) == model_index: return model
	return -1

func verify_matches(army: Dictionary) -> void:
	var admitted := Training.admit_current_catalog(army)
	check(str(admitted.get("error", "")).is_empty(), "Configured Crusaders enter the consolidated local catalog: " + str(admitted.get("error", "")))
	if not str(admitted.get("error", "")).is_empty(): return
	var state := Prepared.initial_state({"core_stratagems": true, "combat_doctrines": true, "unit_abilities": true, "official_mission": false, "checked_rosters": false, "marine_chapters": {1: "BLACK TEMPLARS", 2: "BLACK TEMPLARS"}}, {1: admitted.selection, 2: admitted.selection})
	check(not state.has("error"), "Both players materialize their saved Crusader copies: " + str(state.get("error", "")))
	if state.has("error"): return
	for owner: int in [1, 2]:
		var squad_offset := 0
		for selected_entry: Dictionary in admitted.selection.entries:
			for copy_index in range(int(selected_entry.copies)):
				var squad := owner + squad_offset * 2
				var copy_loadout: Array = selected_entry.saved_model_loadouts[copy_index]
				for model_index in range(10):
					var model := find_model_in_squad(state, owner, squad, model_index)
					check(model >= 0, "Materialized ten-model copy contains model %d for player %d" % [model_index + 1, owner])
					if model < 0: continue
					var unit: Dictionary = state.units[model]
					var equipment: Dictionary = copy_loadout[model_index]
					var expected := P.crusader_squad_model_loadout(model_index, 10, str(equipment[LOADOUT]))
					check(unit.crusader_squad_role == expected.role and unit.ranged_weapons == expected.ranged and unit.melee_weapons == expected.melee, "Player %d copy %d model %d materializes its exact role and saved weapons" % [owner, copy_index + 1, model_index + 1])
					check(unit.get("saved_model_equipment", {}) == equipment and bool(unit.get("crusader_squad_saved_equipment_locked", false)), "Player %d copy %d model %d keeps saved loadout and match lock" % [owner, copy_index + 1, model_index + 1])
				squad_offset += 1
	var choices: Array = Actions.choices(state, 1)
	check(not choices.any(func(choice: Dictionary) -> bool: return str(choice.get("action", "")) == "crusader-squad-loadout"), "Saved Crusaders remove the duplicate Army Preparation equipment choices")
	var target_model := find_model_in_squad(state, 1, 1, 0)
	if target_model >= 0:
		var before := state.duplicate(true)
		var result := Actions.apply(state, 1, {"action": "crusader-squad-loadout", "model": target_model, "target": 1, "value": "default"}, Vector2.ZERO, Callable())
		check(not str(result.get("error", "")).is_empty() and state == before, "Forced match-time equipment edit is rejected without mutating the saved loadout")

func picker_index(picker: OptionButton, wanted: String) -> int:
	for index in range(picker.item_count):
		if str(picker.get_item_metadata(index)) == wanted: return index
	return -1

func verify_builder(catalog: Node) -> void:
	var panel := Builder.new()
	panel.storage_path = ProjectSettings.globalize_path("user://crusader-builder-%d.json" % OS.get_process_id())
	root.add_child(panel)
	var army := R.new_list("11e", "Space Marines", "custom", 3000)
	army.name = "Crusader Workshop control review"
	army.entries = [entry(catalog, 20)]
	panel.draft = army
	panel._render_draft()
	panel._select_entry(0)
	var rows: Control = panel.per_model_equipment_controls
	var first_card: Control = rows.get_child(0)
	var first_heading := first_card.get_child(0) as Label
	var first_picker := first_card.get_child(1).get_child(0).get_child(1) as OptionButton
	check(rows.get_child_count() == 20 and first_heading.text == "Sword Brother" and first_picker.item_count == 2, "Workshop renders all 20 role cards with the Sword Brother replacement")
	var selected := picker_index(first_picker, "hand-flamer")
	first_picker.select(selected)
	first_picker.item_selected.emit(selected)
	check(selected >= 0 and panel.dirty and str(R.model_equipment(panel.draft.entries[0], 0, 0)[LOADOUT]) == "hand-flamer", "Live Workshop selector saves the Sword Brother's Hand Flamer")
	var neophyte_card: Control = rows.get_child(1)
	var neophyte_picker := neophyte_card.get_child(1).get_child(0).get_child(1) as OptionButton
	check((neophyte_card.get_child(0) as Label).text == "Neophyte 1" and neophyte_picker.get_item_text(1) == "Shotgun + Combat Knife", "Neophyte card displays its exact replacement package")
	var initiate_card: Control = rows.get_child(9)
	var initiate_picker := initiate_card.get_child(1).get_child(0).get_child(1) as OptionButton
	check((initiate_card.get_child(0) as Label).text == "Initiate 1" and initiate_picker.item_count == 4 and initiate_picker.get_item_text(2) == "Heavy Bolt Pistol + Power Fist", "Initiate card displays all source choices")
	panel.free()
	var path := ProjectSettings.globalize_path("user://crusader-builder-%d.json" % OS.get_process_id())
	for suffix in ["", ".bak"]:
		if FileAccess.file_exists(path + suffix): DirAccess.remove_absolute(path + suffix)

func run() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() == 2 and args[0] == "--reopen":
		var reopened := Store.new(args[1])
		check(reopened.error.is_empty() and reopened.active().lists.size() == 1, "A separate Godot process reopens the configured Crusader list")
		if reopened.error.is_empty() and reopened.active().lists.size() == 1: inspect_bank(reopened.active().lists[0])
		quit(1 if failures else 0)
		return
	check_source_options()
	var catalog := Catalog.new()
	check(catalog.select_edition("11e").is_empty(), "The consolidated local catalog opens without network access")
	var source: Dictionary = catalog.lookup(UNIT)
	check(not source.is_empty(), "The current catalog admits the source-priced Crusader profile")
	if source.is_empty():
		catalog.free()
		quit(1)
		return
	var ten := R.new_list("11e", "Space Marines", "custom", 3000)
	ten.entries = [entry(catalog, 10)]
	var twenty := R.new_list("11e", "Space Marines", "custom", 3000)
	twenty.entries = [entry(catalog, 20)]	
	check(R.summary(ten).points == 160 and R.summary(twenty).points == 305, "Saved equipment preserves the local 10/20-model Wahapedia costs")
	var army := make_army(catalog)
	check(R.validate(army).is_empty() and R.summary(army).points == 480, "Saved choices pass roster validation without changing the 160-point copy price")
	var item: Dictionary = army.entries[0]
	var before_invalid := item.duplicate(true)
	check(not R.set_model_equipment(item, 0, 7, LOADOUT, "pyreblaster") and item == before_invalid, "A third limited Initiate replacement is rejected atomically")
	check(not R.set_model_equipment(item, 0, 1, LOADOUT, "heavy-pistol-power-fist") and item == before_invalid, "A role-ineligible replacement is rejected atomically")
	var saved_path := ProjectSettings.globalize_path("user://crusader-saved-equipment-%d.json" % OS.get_process_id())
	var store := Store.new(saved_path)
	var saved := store.save_list(army)
	check(saved.error.is_empty(), "Army Workshop persists each Crusader model by stable copy and model IDs")
	if saved.error.is_empty():
		var child_output: Array = []
		var child_exit := OS.execute(OS.get_executable_path(), ["--headless", "--path", ProjectSettings.globalize_path("res://"), "--script", "res://tests/test_crusader_saved_equipment.gd", "--", "--reopen", saved_path], child_output, true)
		check(child_exit == 0, "A separate process reopens each source-role model record: " + str(child_output))
		var reopened := Store.new(saved_path)
		if reopened.error.is_empty() and reopened.active().lists.size() == 1:
			var active_army: Dictionary = reopened.active().lists[0]
			inspect_bank(active_army)
			verify_matches(active_army)
		verify_builder(catalog)
	catalog.free()
	for suffix in ["", ".bak", ".panel", ".panel.bak"]:
		if FileAccess.file_exists(saved_path + suffix): DirAccess.remove_absolute(saved_path + suffix)
	await process_frame
	print("Saved Crusader equipment: %d failures" % failures)
	quit(1 if failures else 0)
