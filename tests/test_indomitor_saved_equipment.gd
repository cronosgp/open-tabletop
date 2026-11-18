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
const UNIT := "40kdc:11e:adeptus-astartes:indomitor-kill-team"
const AUTO := "indomitor_auto_boltstorm"
const HEAVY := "indomitor_heavy_bolter"
const MULTI := "indomitor_multi_melta"
const ACTIONS := ["indomitor-flamestorm-gauntlets", "indomitor-heavy-bolter", "indomitor-multi-melta"]

var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func _initialize() -> void:
	call_deferred("run")

func records() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for model_index in range(10): result.append(E.defaults_for_model(UNIT, 10, model_index))
	return result

func entry(catalog: Node, copies: int = 1) -> Dictionary:
	var source: Dictionary = catalog.lookup(UNIT)
	for index in range(source.options.size()):
		if int(source.options[index].models) == 10: return R.entry(source, index, copies)
	check(false, "The fixed ten-model Indomitor entry exists in the consolidated local catalog")
	return {}

func set_choice(item: Dictionary, copy_index: int, model_index: int, field: String, value: bool, message: String) -> void:
	check(R.set_model_equipment(item, copy_index, model_index, field, value), message)

func make_army(catalog: Node) -> Dictionary:
	var army := R.new_list("11e", "Space Marines", "strike_force", 2000)
	army.name = "Indomitor saved equipment review"
	var item := entry(catalog, 3)
	army.entries = [item]
	set_choice(item, 0, 0, AUTO, true, "First copy saves an Auto Boltstorm replacement")
	set_choice(item, 0, 2, AUTO, true, "First copy saves an independent second Auto Boltstorm replacement")
	set_choice(item, 0, 3, MULTI, true, "First copy saves its one Multi-melta")
	set_choice(item, 0, 6, HEAVY, true, "First copy saves its first Heavy Bolter")
	set_choice(item, 0, 8, HEAVY, true, "First copy saves its second Heavy Bolter")
	set_choice(item, 1, 1, AUTO, true, "Second copy saves a different Auto Boltstorm bearer")
	set_choice(item, 1, 4, MULTI, true, "Second copy saves a separate Multi-melta bearer")
	set_choice(item, 1, 7, HEAVY, true, "Second copy saves its first Heavy Bolter")
	set_choice(item, 1, 9, HEAVY, true, "Second copy saves its second Heavy Bolter")
	return army

func check_source_options() -> void:
	check(E.supports(UNIT) and E.is_model_scoped(UNIT) and E.uses_stacked_model_controls(UNIT), "Indomitor uses per-model saved equipment cards")
	check(str(P.profile("indomitor-kill-team").get("source_datasheet_id", "")) == "000002781", "The local factory is the audited Deathwatch App datasheet")
	var expected_roles := ["flamestorm-heavy-intercessor", "flamestorm-heavy-intercessor", "flamestorm-heavy-intercessor", "melta-heavy-intercessor", "melta-heavy-intercessor", "melta-heavy-intercessor", "heavy-rifle-intercessor", "heavy-rifle-intercessor", "heavy-rifle-intercessor", "heavy-rifle-intercessor"]
	var expected_labels := ["Aggressor 1", "Aggressor 2", "Aggressor 3", "Eradicator 1", "Eradicator 2", "Eradicator 3", "Heavy Intercessor 1", "Heavy Intercessor 2", "Heavy Intercessor 3", "Heavy Intercessor 4"]
	var defaults := records()
	check(E.valid_saved_loadout(UNIT, defaults, 10) and E.points_for_loadout(UNIT, defaults, 10) == 0, "The exact ten-model role defaults are valid and add no equipment cost")
	for model_index in range(10):
		check(E.visual_model_role(UNIT, 10, model_index) == expected_roles[model_index] and E.model_label(UNIT, 10, model_index) == expected_labels[model_index], "Model %d has its source-defined role and clear Workshop label" % (model_index + 1))
		var controls := E.controls_for_model(UNIT, model_index, 10)
		check(controls.size() == 1 and controls[0].choices.size() == 2, "Model %d exposes only its own source-listed replacement" % (model_index + 1))
		if controls.size() != 1: continue
		var field := str(controls[0].field)
		var chosen := defaults[model_index].duplicate(true)
		chosen[field] = true
		var expected := P.indomitor_kill_team_model_loadout(model_index, model_index < 3, model_index >= 6, model_index >= 3 and model_index <= 5)
		var prepared: Dictionary = {}
		E.prepare(prepared, UNIT, chosen, 10, model_index)
		check(E.valid_for_model(UNIT, model_index, chosen, 10) and not expected.is_empty() and prepared.ranged_weapons == expected.ranged and prepared.melee_weapons == expected.melee, "Model %d replacement resolves through the exact local weapon factory" % (model_index + 1))
		check(prepared.keywords == expected.keywords and prepared.get("saved_model_equipment", {}) == chosen and bool(prepared.get("indomitor_saved_equipment_locked", false)), "Prepared model %d retains its role, rules identity and setup lock" % (model_index + 1))
	var all_allowed := records()
	for index in [0, 1, 2]: all_allowed[index][AUTO] = true
	all_allowed[3][MULTI] = true
	all_allowed[6][HEAVY] = true
	all_allowed[7][HEAVY] = true
	check(E.valid_saved_loadout(UNIT, all_allowed, 10), "All three Auto Boltstorm choices and both Heavy Bolters can be selected with one Multi-melta")
	var invalid := all_allowed.duplicate(true)
	invalid[8][HEAVY] = true
	check(not E.valid_saved_loadout(UNIT, invalid, 10), "A third Heavy Bolter exceeds the source per-five cap")
	invalid = all_allowed.duplicate(true)
	invalid[4][MULTI] = true
	check(not E.valid_saved_loadout(UNIT, invalid, 10), "A second Multi-melta exceeds the source unit cap")
	invalid = records()
	invalid[3] = {HEAVY: false}
	check(not E.valid_saved_loadout(UNIT, invalid, 10), "Melta models reject fields belonging to Heavy Rifle models")
	invalid = records()
	invalid[0][AUTO] = "true"
	check(not E.valid_saved_loadout(UNIT, invalid, 10), "Boolean equipment fields reject string values")
	invalid = records()
	invalid[0].unexpected = false
	check(not E.valid_saved_loadout(UNIT, invalid, 10), "Unknown saved equipment fields are rejected")
	check(not E.valid_saved_loadout(UNIT, defaults.slice(0, 9), 10) and not E.valid_saved_loadout(UNIT, defaults, 9), "Short arrays and unsupported Indomitor sizes are rejected")
	check(E.defaults_for_model(UNIT, 10, 3) == {MULTI: false} and E.defaults_for_model(UNIT, 10, 6) == {HEAVY: false}, "Mixed-role defaults retain role-specific saved field shapes")

func inspect_bank(army: Dictionary) -> void:
	check(R.validate(army).is_empty(), "Saved Indomitor list passes whole-roster validation")
	check(R.summary(army).points == 860, "Two copies remain 280 points and the third copy remains 300 points")
	var first := R.model_equipment_loadouts(army.entries[0], 0)
	var second := R.model_equipment_loadouts(army.entries[0], 1)
	var third := R.model_equipment_loadouts(army.entries[0], 2)
	check(first[0][AUTO] and first[2][AUTO] and first[3][MULTI] and first[6][HEAVY] and first[8][HEAVY], "First copy reopens each configured role and bearer")
	check(second[1][AUTO] and second[4][MULTI] and second[7][HEAVY] and second[9][HEAVY], "Second copy keeps independent bearer assignments")
	check(E.valid_saved_loadout(UNIT, first, 10) and E.valid_saved_loadout(UNIT, second, 10) and E.valid_saved_loadout(UNIT, third, 10), "All three reopened copy arrays pass the complete unit validator")
	check(third == records(), "The third copy retains all role-specific defaults")

func find_model_in_squad(state: Dictionary, owner: int, squad: int, model_index: int) -> int:
	for model: int in state.units:
		var unit: Dictionary = state.units[model]
		if int(unit.get("owner", -1)) == owner and int(unit.get("squad", -1)) == squad and int(unit.get("saved_equipment_model_index", -1)) == model_index: return model
	return -1

func verify_matches(army: Dictionary) -> void:
	var admitted := Training.admit_current_catalog(army)
	check(str(admitted.get("error", "")).is_empty(), "Configured Indomitor enters the consolidated local catalog: " + str(admitted.get("error", "")))
	if not str(admitted.get("error", "")).is_empty(): return
	var state := Prepared.initial_state({"core_stratagems": true, "combat_doctrines": true, "unit_abilities": true, "official_mission": false, "checked_rosters": false, "marine_chapters": {1: "DEATHWATCH", 2: "DEATHWATCH"}}, {1: admitted.selection, 2: admitted.selection})
	check(not state.has("error"), "Both players materialize their three saved Indomitor copies: " + str(state.get("error", "")))
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
					var expected := P.indomitor_kill_team_model_loadout(model_index, bool(equipment.get(AUTO, false)), bool(equipment.get(HEAVY, false)), bool(equipment.get(MULTI, false)))
					check(unit.ranged_weapons == expected.ranged and unit.melee_weapons == expected.melee and unit.keywords == expected.keywords, "Player %d copy %d model %d materializes exact saved weapons" % [owner, copy_index + 1, model_index + 1])
					check(unit.get("saved_model_equipment", {}) == equipment and bool(unit.get("indomitor_saved_equipment_locked", false)), "Player %d copy %d model %d keeps saved loadout and match lock" % [owner, copy_index + 1, model_index + 1])
				squad_offset += 1
	var choices: Array = Actions.choices(state, 1)
	check(not choices.any(func(choice: Dictionary) -> bool: return str(choice.get("action", "")) in ACTIONS), "Saved Indomitor removes all three duplicate Army Preparation equipment actions")
	var target_model := -1
	for model: int in state.units:
		if int(state.units[model].get("owner", -1)) == 1 and str(state.units[model].get("definition_id", "")).ends_with("indomitor-kill-team"):
			target_model = model
			break
	if target_model >= 0:
		var before := state.duplicate(true)
		var target_squad := int(state.units[target_model].squad)
		var result := Actions.apply(state, 1, {"action": "indomitor-heavy-bolter", "model": target_model, "target": target_squad, "value": "on"}, Vector2.ZERO, Callable())
		check(not str(result.get("error", "")).is_empty() and state == before, "Forced match-time equipment edit is rejected without mutating the saved loadout")

func picker_index(picker: OptionButton, wanted: bool) -> int:
	for index in range(picker.item_count):
		if picker.get_item_metadata(index) == wanted: return index
	return -1

func verify_builder(catalog: Node) -> void:
	var panel := Builder.new()
	panel.storage_path = ProjectSettings.globalize_path("user://indomitor-builder-%d.json" % OS.get_process_id())
	root.add_child(panel)
	var army := R.new_list("11e", "Space Marines", "custom", 3000)
	army.name = "Indomitor Workshop control review"
	army.entries = [entry(catalog)]
	panel.draft = army
	panel._render_draft()
	panel._select_entry(0)
	var rows: Control = panel.per_model_equipment_controls
	var first_card: Control = rows.get_child(0)
	var first_heading := first_card.get_child(0) as Label
	var first_fields: Control = first_card.get_child(1)
	var first_picker := first_fields.get_child(0).get_child(1) as OptionButton
	check(rows.get_child_count() == 10 and first_heading.text == "Aggressor 1" and first_picker.item_count == 2, "Workshop renders ten source-role cards with one eligible replacement per role")
	var selected := picker_index(first_picker, true)
	first_picker.select(selected)
	first_picker.item_selected.emit(selected)
	check(selected >= 0 and panel.dirty and bool(R.model_equipment(panel.draft.entries[0], 0, 0).get(AUTO, false)), "Live Workshop selector saves the Auto Boltstorm choice to model 1")
	var melta_card: Control = rows.get_child(3)
	var melta_picker := melta_card.get_child(1).get_child(0).get_child(1) as OptionButton
	check((melta_card.get_child(0) as Label).text == "Eradicator 1" and melta_picker.get_item_text(1) == "Multi-melta", "Eradicator card shows only its Multi-melta replacement")
	var heavy_card: Control = rows.get_child(9)
	var heavy_picker := heavy_card.get_child(1).get_child(0).get_child(1) as OptionButton
	check((heavy_card.get_child(0) as Label).text == "Heavy Intercessor 4" and heavy_picker.get_item_text(1) == "Deathwatch Heavy Bolter", "Final Heavy Intercessor card retains its source-role label and exact option text")
	panel.free()
	var path := ProjectSettings.globalize_path("user://indomitor-builder-%d.json" % OS.get_process_id())
	for suffix in ["", ".bak"]:
		if FileAccess.file_exists(path + suffix): DirAccess.remove_absolute(path + suffix)

func run() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() == 2 and args[0] == "--reopen":
		var reopened := Store.new(args[1])
		check(reopened.error.is_empty() and reopened.active().lists.size() == 1, "A separate Godot process reopens the configured Indomitor list")
		if reopened.error.is_empty() and reopened.active().lists.size() == 1: inspect_bank(reopened.active().lists[0])
		quit(1 if failures else 0)
		return
	check_source_options()
	var catalog := Catalog.new()
	check(catalog.select_edition("11e").is_empty(), "The consolidated local catalog opens without network access")
	var source := catalog.lookup(UNIT)
	check(not source.is_empty(), "The current catalog admits the fixed-size Indomitor profile")
	if source.is_empty():
		catalog.free()
		quit(1)
		return
	var one := R.new_list("11e", "Space Marines", "custom", 3000)
	one.entries = [entry(catalog, 1)]
	var three := R.new_list("11e", "Space Marines", "custom", 3000)
	three.entries = [entry(catalog, 3)]
	check(R.summary(one).points == 280 and R.summary(three).points == 860, "First/second copies remain 280 points and the third-plus copy remains 300")
	var army := make_army(catalog)
	check(R.validate(army).is_empty() and R.summary(army).points == 860, "Saved equipment remains valid without changing source copy prices")
	var item: Dictionary = army.entries[0]
	var before_invalid := item.duplicate(true)
	check(not R.set_model_equipment(item, 0, 7, HEAVY, true) and item == before_invalid, "A third Heavy Bolter is rejected atomically")
	check(not R.set_model_equipment(item, 0, 3, HEAVY, true) and item == before_invalid, "A field from another model role is rejected atomically")
	var saved_path := ProjectSettings.globalize_path("user://indomitor-saved-equipment-%d.json" % OS.get_process_id())
	var store := Store.new(saved_path)
	var saved := store.save_list(army)
	check(saved.error.is_empty(), "Army Workshop persists each Indomitor model by stable copy and model IDs")
	if saved.error.is_empty():
		var child_output: Array = []
		var child_exit := OS.execute(OS.get_executable_path(), ["--headless", "--path", ProjectSettings.globalize_path("res://"), "--script", "res://tests/test_indomitor_saved_equipment.gd", "--", "--reopen", saved_path], child_output, true)
		check(child_exit == 0, "A separate process reopens every role-shaped model record: " + str(child_output))
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
	print("Saved Indomitor equipment: %d failures" % failures)
	quit(1 if failures else 0)
