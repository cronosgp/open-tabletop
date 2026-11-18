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
const BLACK_KNIGHTS := "40kdc:11e:adeptus-astartes:ravenwing-black-knights"
const COMMAND_SQUAD := "40kdc:11e:adeptus-astartes:ravenwing-command-squad"
const LOCKED_ACTIONS := ["black-knight-grenade-launcher", "ravenwing-command-grenade-launcher"]
const COMMAND_ROLES := ["Ravenwing Ancient", "Ravenwing Apothecary", "Ravenwing Champion"]
var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func _initialize() -> void:
	call_deferred("run")

func records(definition: String, models: int) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for _index in range(models): result.append(E.defaults(definition).duplicate(true))
	return result

func entry(catalog: Node, definition: String, models: int, copies: int) -> Dictionary:
	var source: Dictionary = catalog.lookup(definition)
	for index in range(source.options.size()):
		if int(source.options[index].models) == models: return R.entry(source, index, copies)
	check(false, "Ravenwing source size is in the consolidated local catalog")
	return {}

func make_army(catalog: Node) -> Dictionary:
	var army := R.new_list("11e", "Space Marines", "strike_force", 2000)
	army.entries = [entry(catalog, BLACK_KNIGHTS, 3, 2), entry(catalog, BLACK_KNIGHTS, 6, 1), entry(catalog, COMMAND_SQUAD, 3, 3)]
	for copy_index in range(2):
		check(R.set_model_equipment(army.entries[0], copy_index, copy_index, "black_knight_grenade_launcher", true), "Each three-model Black Knight copy saves a distinct bearer")
	for model_index in [0, 4]:
		check(R.set_model_equipment(army.entries[1], 0, model_index, "black_knight_grenade_launcher", true), "Six-model Black Knights save both allowed Grenade Launcher bearers")
	for copy_index in range(3):
		check(R.set_model_equipment(army.entries[2], copy_index, copy_index, "ravenwing_command_grenade_launcher", true), "Each Command Squad copy saves a role-specific bearer")
	return army

func check_source_options() -> void:
	for definition: String in [BLACK_KNIGHTS, COMMAND_SQUAD]:
		check(E.supports(definition) and E.is_model_scoped(definition), "%s is a per-model saved-equipment profile" % definition)
		check(E.valid_saved_loadout(definition, records(definition, 3), 3) and E.points_for_loadout(definition, records(definition, 3), 3) == 0, "%s accepts defaults with no equipment surcharge" % definition)
		check(not E.valid_saved_loadout(definition, records(definition, 4), 4), "%s rejects unsupported four-model size" % definition)
	check(E.valid_saved_loadout(BLACK_KNIGHTS, records(BLACK_KNIGHTS, 6), 6) and not E.valid_saved_loadout(COMMAND_SQUAD, records(COMMAND_SQUAD, 6), 6), "The Workshop admits only source-listed unit sizes")
	check(E.model_label(BLACK_KNIGHTS, 3, 0) == "Ravenwing Huntmaster" and E.model_label(BLACK_KNIGHTS, 6, 5) == "Ravenwing Black Knight 6", "Black Knight rows retain stable role labels at both sizes")
	check(E.model_label(COMMAND_SQUAD, 3, 0) == COMMAND_ROLES[0] and E.model_label(COMMAND_SQUAD, 3, 2) == COMMAND_ROLES[2], "Command Squad rows retain the three fixed source roles")
	var six_knights := records(BLACK_KNIGHTS, 6)
	six_knights[0].black_knight_grenade_launcher = true
	six_knights[1].black_knight_grenade_launcher = true
	check(E.valid_saved_loadout(BLACK_KNIGHTS, six_knights, 6), "Six Black Knights allow two Grenade Launchers")
	six_knights[2].black_knight_grenade_launcher = true
	check(not E.valid_saved_loadout(BLACK_KNIGHTS, six_knights, 6), "Six Black Knights reject a third Grenade Launcher")
	var three_knights := records(BLACK_KNIGHTS, 3)
	three_knights[0].black_knight_grenade_launcher = true
	three_knights[1].black_knight_grenade_launcher = true
	check(not E.valid_saved_loadout(BLACK_KNIGHTS, three_knights, 3), "Three Black Knights reject a second Grenade Launcher")
	var two_command_launchers := records(COMMAND_SQUAD, 3)
	two_command_launchers[0].ravenwing_command_grenade_launcher = true
	two_command_launchers[1].ravenwing_command_grenade_launcher = true
	check(not E.valid_saved_loadout(COMMAND_SQUAD, two_command_launchers, 3), "Command Squad rejects more than one Grenade Launcher")
	var invalid := records(COMMAND_SQUAD, 3)
	invalid[1].invented_ravenwing_option = true
	check(not E.valid_saved_loadout(COMMAND_SQUAD, invalid, 3), "Saved records reject extra, unlisted fields")
	var black_knight_default := P.ravenwing_black_knight_weapons(false)
	var black_knight_launcher := P.ravenwing_black_knight_weapons(true)
	check(black_knight_default.ranged.size() == 2 and black_knight_default.ranged[1].id == "plasma-talon" and black_knight_launcher.ranged[1].id == "grenade-launcher", "Black Knight saved choice resolves through the local source-profile factory")
	for role_index in range(COMMAND_ROLES.size()):
		var default_weapons := P.ravenwing_command_weapons(COMMAND_ROLES[role_index], false)
		var launcher_weapons := P.ravenwing_command_weapons(COMMAND_ROLES[role_index], true)
		check(default_weapons.ranged.size() == 2 and default_weapons.ranged[1].id == "plasma-talon" and launcher_weapons.ranged[1].id == "grenade-launcher" and default_weapons.melee == launcher_weapons.melee, "%s keeps its role melee while replacing its Plasma Talon" % COMMAND_ROLES[role_index])

func inspect_bank(army: Dictionary) -> void:
	check(R.validate(army).is_empty(), "Saved Ravenwing list passes roster validation")
	check(R.summary(army).points == 715, "Saved options preserve 3/6-model Black Knight and third-plus Command Squad copy tiers")
	for copy_index in range(2):
		var black_loadout := R.model_equipment_loadouts(army.entries[0], copy_index)
		check(bool(black_loadout[copy_index].black_knight_grenade_launcher) and not bool(black_loadout[(copy_index + 1) % 3].black_knight_grenade_launcher), "Three-model Black Knight copy %d retains its exact independent bearer" % (copy_index + 1))
		check(E.valid_saved_loadout(BLACK_KNIGHTS, black_loadout, 3), "Reopened three-model Black Knight copy %d remains within the source cap" % (copy_index + 1))
	var six_knights := R.model_equipment_loadouts(army.entries[1], 0)
	check(six_knights.count({"black_knight_grenade_launcher": true}) == 2 and E.valid_saved_loadout(BLACK_KNIGHTS, six_knights, 6), "Reopened six-model Black Knights retain both independent launcher choices")
	for copy_index in range(3):
		var command_loadout := R.model_equipment_loadouts(army.entries[2], copy_index)
		check(bool(command_loadout[copy_index].ravenwing_command_grenade_launcher), "Command Squad copy %d retains its role-specific Grenade Launcher" % (copy_index + 1))
		check(E.valid_saved_loadout(COMMAND_SQUAD, command_loadout, 3), "Reopened Command Squad copy %d remains within the source cap" % (copy_index + 1))

func find_model_in_squad(state: Dictionary, owner: int, squad: int, model_index: int) -> int:
	for model: int in state.units:
		var unit: Dictionary = state.units[model]
		if int(unit.get("owner", -1)) == owner and int(unit.get("squad", -1)) == squad and int(unit.get("saved_equipment_model_index", -1)) == model_index: return model
	return -1

func verify_matches(army: Dictionary) -> void:
	var admitted := Training.admit_current_catalog(army)
	check(str(admitted.get("error", "")).is_empty(), "Saved Ravenwing options project into the current catalog: " + str(admitted.get("error", "")))
	if not str(admitted.get("error", "")).is_empty(): return
	var state := Prepared.initial_state({"unit_abilities": true, "official_mission": false, "checked_rosters": false}, {1: admitted.selection, 2: admitted.selection})
	check(not state.has("error"), "Both players materialize the saved Ravenwing choices: " + str(state.get("error", "")))
	if state.has("error"): return
	for owner: int in [1, 2]:
		var squad_offset := 0
		for selected_entry: Dictionary in admitted.selection.entries:
			var definition := str(selected_entry.definition_id)
			for copy_index in range(int(selected_entry.copies)):
				var squad := owner + squad_offset * 2
				var copy_loadout: Array = selected_entry.saved_model_loadouts[copy_index]
				for model_index in range(int(selected_entry.models)):
					var model := find_model_in_squad(state, owner, squad, model_index)
					check(model >= 0, "Prepared %s copy %d contains saved model %d for player %d" % [definition, copy_index + 1, model_index + 1, owner])
					if model < 0: continue
					var unit: Dictionary = state.units[model]
					var equipment: Dictionary = copy_loadout[model_index]
					var expected: Dictionary = {}
					E.prepare(expected, definition, equipment, int(selected_entry.models), model_index)
					var weapons_match: bool = unit.ranged_weapons == expected.ranged_weapons and unit.melee_weapons == expected.melee_weapons
					var saved_match: bool = unit.get("saved_model_equipment", {}) == equipment
					var locked: bool = bool(unit.get("ravenwing_saved_model_loadout_locked", false))
					check(weapons_match and saved_match and locked, "Prepared %s model %d has exact saved equipment, weapon profiles and match lock" % [definition, model_index + 1])
					if definition == COMMAND_SQUAD:
						check(str(unit.get("ravenwing_command_role", "")) == COMMAND_ROLES[model_index], "Prepared Command Squad model keeps its fixed role")
					var launcher := bool(equipment.get("black_knight_grenade_launcher", equipment.get("ravenwing_command_grenade_launcher", false)))
					if launcher: check(unit.ranged_weapons[1].id == "grenade-launcher", "Saved Grenade Launcher reaches its exact prepared model")
				squad_offset += 1
	var setup_choices: Array = Actions.choices(state, 1)
	check(not setup_choices.any(func(choice: Dictionary) -> bool: return str(choice.get("action", "")) in LOCKED_ACTIONS), "Saved Ravenwing equipment does not appear in match-preparation options")
	for tuple: Array in [[BLACK_KNIGHTS, "black-knight-grenade-launcher", 0, "off"], [COMMAND_SQUAD, "ravenwing-command-grenade-launcher", 0, "off"]]:
		var definition: String = tuple[0]
		var target_definition := definition.get_slice(":", 3)
		var chosen_model := -1
		for model: int in state.units:
			if int(state.units[model].get("owner", -1)) == 1 and str(state.units[model].get("definition_id", "")).ends_with(target_definition):
				chosen_model = model
				break
		if chosen_model < 0: continue
		var before := state.duplicate(true)
		var result := Actions.apply(state, 1, {"action": str(tuple[1]), "model": chosen_model, "target": int(state.units[chosen_model].squad), "value": str(tuple[3])}, Vector2.ZERO, Callable())
		check(not str(result.get("error", "")).is_empty() and state == before, "Saved %s command is rejected without mutating the match" % str(tuple[1]))

func picker_index(picker: OptionButton, wanted: String) -> int:
	for index in range(picker.item_count):
		if str(picker.get_item_metadata(index)) == wanted: return index
	return -1

func verify_builder(army: Dictionary) -> void:
	var panel := Builder.new()
	panel.storage_path = ProjectSettings.globalize_path("user://ravenwing-builder-%d.json" % OS.get_process_id())
	root.add_child(panel)
	panel.draft = army.duplicate(true)
	panel._render_draft()
	panel._select_entry(0)
	var black_rows: Control = panel.per_model_equipment_controls
	var black_card: Control = black_rows.get_child(0)
	var black_heading := black_card.get_child(0) as Label
	var black_picker := black_card.get_child(1).get_child(0).get_child(1) as OptionButton
	check(black_rows.get_child_count() == 3 and black_heading.text == "Ravenwing Huntmaster" and black_picker.item_count == 2, "Workshop stacks a readable Huntmaster heading above its audited selector")
	var default_index := picker_index(black_picker, "false")
	black_picker.select(default_index)
	black_picker.item_selected.emit(default_index)
	var second_card: Control = black_rows.get_child(1)
	var second_picker := second_card.get_child(1).get_child(0).get_child(1) as OptionButton
	var launcher_index := picker_index(second_picker, "true")
	second_picker.select(launcher_index)
	second_picker.item_selected.emit(launcher_index)
	check(not bool(R.model_equipment(panel.draft.entries[0], 0, 0).black_knight_grenade_launcher) and bool(R.model_equipment(panel.draft.entries[0], 0, 1).black_knight_grenade_launcher), "Workshop updates a stable model and honors the one-per-three cap")
	panel._select_entry(2)
	var command_rows: Control = panel.per_model_equipment_controls
	var command_card: Control = command_rows.get_child(1)
	var command_heading := command_card.get_child(0) as Label
	var command_picker := command_card.get_child(1).get_child(0).get_child(1) as OptionButton
	check(command_rows.get_child_count() == 3 and command_heading.text == "Ravenwing Apothecary" and command_picker.item_count == 2, "Workshop distinguishes the fixed Command Squad roles and selector")
	panel.free()
	var path := ProjectSettings.globalize_path("user://ravenwing-builder-%d.json" % OS.get_process_id())
	for suffix in ["", ".bak"]:
		if FileAccess.file_exists(path + suffix): DirAccess.remove_absolute(path + suffix)

func run() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() == 2 and args[0] == "--reopen":
		var reopened := Store.new(args[1])
		check(reopened.error.is_empty() and reopened.active().lists.size() == 1, "A separate process reopens the saved Ravenwing list")
		if reopened.error.is_empty() and reopened.active().lists.size() == 1: inspect_bank(reopened.active().lists[0])
		quit(1 if failures else 0)
		return
	check_source_options()
	var catalog := Catalog.new()
	check(catalog.select_edition("11e").is_empty(), "Consolidated local catalog opens without network access")
	var army := make_army(catalog)
	check(R.validate(army).is_empty() and R.summary(army).points == 715, "Source-priced copy tiers total 715 points across both Black Knight sizes")
	var before_cap: Dictionary = army.entries[0].duplicate(true)
	check(not R.set_model_equipment(army.entries[0], 0, 1, "black_knight_grenade_launcher", true) and army.entries[0] == before_cap, "A second launcher is rejected atomically in a three-model squad")
	var saved_path := ProjectSettings.globalize_path("user://ravenwing-saved-equipment-%d.json" % OS.get_process_id())
	var store := Store.new(saved_path)
	var saved := store.save_list(army)
	check(saved.error.is_empty(), "Army Workshop persists Ravenwing equipment by stable model ID")
	if saved.error.is_empty():
		var child_output: Array = []
		var child_exit := OS.execute(OS.get_executable_path(), ["--headless", "--path", ProjectSettings.globalize_path("res://"), "--script", "res://tests/test_ravenwing_saved_equipment.gd", "--", "--reopen", saved_path], child_output, true)
		check(child_exit == 0, "A separate process reopens and validates every Ravenwing record: " + str(child_output))
		var reopened := Store.new(saved_path)
		if reopened.error.is_empty() and reopened.active().lists.size() == 1:
			var active_army: Dictionary = reopened.active().lists[0]
			inspect_bank(active_army)
			verify_matches(active_army)
			verify_builder(active_army)
	catalog.free()
	for suffix in ["", ".bak", ".panel", ".panel.bak"]:
		if FileAccess.file_exists(saved_path + suffix): DirAccess.remove_absolute(saved_path + suffix)
	await process_frame
	print("Saved Ravenwing equipment: %d failures" % failures)
	quit(1 if failures else 0)
