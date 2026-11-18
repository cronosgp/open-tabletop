extends SceneTree

const Catalog = preload("res://scripts/edition_11/army_capabilities.gd")
const ArmyRoster = preload("res://scripts/army_roster.gd")
const ArmyProfiles = preload("res://scripts/army_profiles.gd")
const MatchSave = preload("res://scripts/match_save.gd")
const MatchRecovery = preload("res://scripts/match_recovery.gd")
const Deployment = preload("res://scripts/edition_11/deployment.gd")
const UnitActions = preload("res://scripts/edition_11/unit_actions.gd")
const MainScene = preload("res://scenes/main.tscn")
var failures := 0

func check(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		failures += 1

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() == 3 and args[0] in ["--reopen", "--reopen-readiness"]:
		if args[0] == "--reopen": _reopen_match(int(args[1]), args[2])
		else: _reopen_readiness_match(int(args[1]), args[2])
		return

	var game = MainScene.instantiate()
	root.add_child(game)
	game.auto_models.button_pressed = false
	game.unit_abilities_choice.button_pressed = true
	var profile_path := ProjectSettings.globalize_path("user://interruption-profiles-%d.json" % OS.get_process_id())
	game.army_builder.store = ArmyProfiles.new(profile_path)

	var choice := Catalog.current_catalog_choice({
		"id": "40kdc:11e:adeptus-astartes:aggressor-squad",
		"edition": "11e",
		"faction": "Space Marines",
	})
	if not choice.is_empty():
		choice.role = ArmyRoster.role(choice.get("keywords", []))
	check(not choice.is_empty(), "The local catalog supplies the saved Aggressor profile")
	if choice.is_empty():
		_finish(game)
		return

	var player_one_list := _saved_list(choice, [false, true, false], "resume-player-one-model")
	var player_two_list := _saved_list(choice, [true, false, false], "resume-player-two-model")
	var player_one_saved: Dictionary = game.army_builder.store.save_list(player_one_list)
	var player_two_saved: Dictionary = game.army_builder.store.save_list(player_two_list)
	check(str(player_one_saved.get("error", "")).is_empty() and str(player_two_saved.get("error", "")).is_empty(),
		"Both configured armies save before match readiness")
	if not str(player_one_saved.get("error", "")).is_empty() or not str(player_two_saved.get("error", "")).is_empty():
		_finish(game)
		return

	game._refresh_army_choices()
	check(_select_saved_list(game, 1, str(player_one_saved.list.id))
		and _select_saved_list(game, 2, str(player_two_saved.list.id)),
		"Both saved lists remain selectable after reopening the Army Builder bank")
	game._start_saved_match()
	check(game.saved_army_mode and game.state.get("phase", "") == "deployment",
		"Readiness creates the frozen saved-army match before Deployment input (phase=%s; status=%s)" % [
			str(game.state.get("phase", "")), str(game.status.text),
		])
	check(int(game.active_save_slot) > 0 and MatchSave.slot_has_file(int(game.active_save_slot)),
		"The new match writes an immediate recovery checkpoint before the first Deployment command")
	if int(game.active_save_slot) <= 0 or not MatchSave.slot_has_file(int(game.active_save_slot)):
		_finish(game)
		return

	var initial_save: Dictionary = MatchSave.read(game.match_save_path)
	check(not initial_save.has("error") and initial_save.get("state", {}) == game.state,
		"The first on-disk checkpoint exactly matches the frozen match created at readiness")
	var initial_presentation: Dictionary = initial_save.get("presentation", {})
	check(MatchSave.valid_presentation(initial_presentation)
		and _presentation_has_override(initial_presentation, 1, "resume-player-one-model")
		and _presentation_has_override(initial_presentation, 2, "resume-player-two-model"),
		"The initial checkpoint freezes both players' local model appearances")
	check(_aggressor_loadouts(game.state, 1) == [[false, true, false]]
		and _aggressor_loadouts(game.state, 2) == [[true, false, false]],
		"The frozen match retains each player's distinct per-model equipment")

	var edited_source: Dictionary = player_one_saved.list.duplicate(true)
	ArmyRoster.set_model_equipment(edited_source.entries[0], 0, 1, "aggressor_boltstorm", false)
	ArmyRoster.set_model_visual_override(edited_source.entries[0], 0, 1, "edited-source-after-match")
	var source_edit: Dictionary = game.army_builder.store.save_list(edited_source)
	var after_source_edit := MatchSave.read(game.match_save_path)
	check(str(source_edit.get("error", "")).is_empty()
		and after_source_edit.get("state", {}) == game.state
		and after_source_edit.get("presentation", {}) == initial_presentation,
		"Editing the source army after match creation cannot change its initial frozen checkpoint")

	var readiness_expected_path := ProjectSettings.globalize_path("user://readiness-expected-%d.bin" % OS.get_process_id())
	var readiness_expected_file := FileAccess.open(readiness_expected_path, FileAccess.WRITE)
	check(readiness_expected_file != null, "The restart fixture can write its readiness snapshot")
	if readiness_expected_file == null:
		_finish(game)
		return
	readiness_expected_file.store_buffer(var_to_bytes({
		"state": after_source_edit.state,
		"presentation": after_source_edit.get("presentation", {}),
	}))
	readiness_expected_file.flush()
	readiness_expected_file.close()
	var readiness_output: Array = []
	var readiness_reopened := OS.execute(OS.get_executable_path(), [
		"--headless",
		"--path",
		ProjectSettings.globalize_path("res://"),
		"--script",
		"res://tests/test_saved_match_interruption.gd",
		"--",
		"--reopen-readiness",
		str(game.active_save_slot),
		readiness_expected_path,
	], readiness_output, true)
	check(readiness_reopened == 0, "A separate Godot process resumes the saved match before readiness declarations: " + str(readiness_output))
	_remove_file(readiness_expected_path)
	var first_setup_complete := _complete_setup(game, 1)
	check(first_setup_complete, "The first player completes the remaining unit-ability preparation")
	check(_has_setup_done_choice(game.state, 2), "Completing the first player's setup opens the second player's readiness action")
	check(_complete_setup(game, 2), "The second player completes unit-ability preparation and unlocks Deployment")
	check(game.state.get("unit_abilities", {}).get("setup_players", []).size() == 2,
		"Both players finish match-specific preparation before Deployment")

	var first_squad := Deployment.current(game.state)
	var first_owner := Deployment.actor(game.state)
	var preset_error := Deployment.preset(game.state, first_owner, int(game.state.revision))
	var confirm_error := "Deployment preview failed."
	if preset_error.is_empty():
		confirm_error = Deployment.confirm(game.state, first_owner, int(game.state.revision))
	check(preset_error.is_empty() and confirm_error.is_empty()
		and game.state.get("phase", "") == "deployment"
		and int(game.state.deployment.index) == 1
		and game.state.deployment.committed == [first_squad]
		and Deployment.current(game.state) >= 0,
		"One player's deployment commits while the opposing army remains pending")
	if not confirm_error.is_empty():
		_finish(game)
		return

	game._broadcast()
	var partial_save: Dictionary = MatchSave.read(game.match_save_path)
	check(not partial_save.has("error") and partial_save.get("state", {}) == game.state
		and int(partial_save.state.deployment.index) == 1,
		"The mid-Deployment autosave records the committed unit and next pending unit")
	if partial_save.has("error"):
		_finish(game)
		return

	var expected_path := ProjectSettings.globalize_path("user://interruption-expected-%d.bin" % OS.get_process_id())
	var expected_file := FileAccess.open(expected_path, FileAccess.WRITE)
	check(expected_file != null, "The restart fixture can write its expected snapshot")
	if expected_file == null:
		_finish(game)
		return
	expected_file.store_buffer(var_to_bytes({
		"state": partial_save.state,
		"presentation": partial_save.get("presentation", {}),
	}))
	expected_file.flush()
	expected_file.close()

	var output: Array = []
	var reopened := OS.execute(OS.get_executable_path(), [
		"--headless",
		"--path",
		ProjectSettings.globalize_path("res://"),
		"--script",
		"res://tests/test_saved_match_interruption.gd",
		"--",
		"--reopen",
		str(game.active_save_slot),
		expected_path,
	], output, true)
	check(reopened == 0, "A separate Godot process resumes the partial Deployment snapshot: " + str(output))

	var slot_path := ProjectSettings.globalize_path(game.match_save_path)
	_remove_file(slot_path)
	_remove_file(slot_path + ".bak")
	_remove_file(slot_path + ".tmp")
	_remove_file(expected_path)
	_remove_file(readiness_expected_path)
	_remove_file(profile_path)
	MatchRecovery.dismiss(OS.get_process_id())
	game.free()
	for _frame in range(2): await process_frame
	print("Saved match interruption checks: %d failures" % failures)
	quit(1 if failures > 0 else 0)

func _reopen_match(slot: int, expected_path: String) -> void:
	var expected_file := FileAccess.open(expected_path, FileAccess.READ)
	check(expected_file != null, "The restarted process can read the saved expected state")
	if expected_file == null:
		quit(1)
		return
	var expected: Variant = bytes_to_var(expected_file.get_buffer(expected_file.get_length()))
	expected_file.close()
	check(expected is Dictionary and expected.get("state", null) is Dictionary
		and expected.get("presentation", null) is Dictionary,
		"The restart fixture contains a match and appearance snapshot")
	if not expected is Dictionary:
		quit(1)
		return

	var game = MainScene.instantiate()
	root.add_child(game)
	game.auto_models.button_pressed = false
	var slot_selected: bool = game._set_active_save_slot(slot)
	if slot_selected:
		game._load_match()
	check(slot_selected and bool(game.resume_succeeded),
		"The application resumes the requested local saved-match slot")
	check(game.state == expected.state
		and game.state.get("phase", "") == "deployment"
		and int(game.state.deployment.index) == 1
		and Deployment.current(game.state) >= 0,
		"Restart restores the exact partial Deployment state without repeating committed placement")
	check(_aggressor_loadouts(game.state, 1) == [[false, true, false]]
		and _aggressor_loadouts(game.state, 2) == [[true, false, false]],
		"Restart retains both players' frozen model equipment")
	var presentation: Dictionary = game._local_visual_presentation()
	check(str(presentation.get("error", "")).is_empty()
		and presentation.get("snapshot", {}) == expected.presentation
		and _presentation_has_override(presentation.get("snapshot", {}), 1, "resume-player-one-model")
		and _presentation_has_override(presentation.get("snapshot", {}), 2, "resume-player-two-model"),
		"Restart restores the frozen local appearance references independently of later source edits")
	MatchRecovery.dismiss(OS.get_process_id())
	game.free()
	for _frame in range(2): await process_frame
	print("Separate-process resume checks: %d failures" % failures)
	quit(1 if failures > 0 else 0)

func _reopen_readiness_match(slot: int, expected_path: String) -> void:
	var expected_file := FileAccess.open(expected_path, FileAccess.READ)
	check(expected_file != null, "The readiness restart process can read its expected snapshot")
	if expected_file == null:
		quit(1)
		return
	var expected: Variant = bytes_to_var(expected_file.get_buffer(expected_file.get_length()))
	expected_file.close()
	check(expected is Dictionary and expected.get("state", null) is Dictionary
		and expected.get("presentation", null) is Dictionary,
		"The readiness fixture contains frozen gameplay and appearance snapshots")
	if not expected is Dictionary:
		quit(1)
		return
	var game = MainScene.instantiate()
	root.add_child(game)
	game.auto_models.button_pressed = false
	var slot_selected: bool = game._set_active_save_slot(slot)
	if slot_selected: game._load_match()
	check(slot_selected and bool(game.resume_succeeded), "The application resumes the saved match while readiness is still pending")
	check(game.state == expected.state
		and game.state.get("phase", "") == "deployment"
		and game.state.get("unit_abilities", {}).get("setup_players", []).is_empty(),
		"Restart restores the exact frozen match before either player completes readiness")
	check(_aggressor_loadouts(game.state, 1) == [[false, true, false]]
		and _aggressor_loadouts(game.state, 2) == [[true, false, false]],
		"Readiness restart retains both players' distinct frozen equipment")
	check(_has_setup_done_choice(game.state, 1) and not _has_setup_done_choice(game.state, 2),
		"The current readiness actor can continue after restart while the opposing player waits in turn")
	var presentation: Dictionary = game._local_visual_presentation()
	check(str(presentation.get("error", "")).is_empty()
		and presentation.get("snapshot", {}) == expected.presentation
		and _presentation_has_override(presentation.get("snapshot", {}), 1, "resume-player-one-model")
		and _presentation_has_override(presentation.get("snapshot", {}), 2, "resume-player-two-model"),
		"Readiness restart restores both players' frozen appearances")
	MatchRecovery.dismiss(OS.get_process_id())
	game.free()
	for _frame in range(2): await process_frame
	print("Separate-process readiness resume checks: %d failures" % failures)
	quit(1 if failures > 0 else 0)

func _saved_list(choice: Dictionary, boltstorm_choices: Array, visual_id: String) -> Dictionary:
	var list: Dictionary = ArmyRoster.new_list("11e", "Space Marines", "strike_force", 2000)
	var entry: Dictionary = ArmyRoster.entry(choice, 0, 1)
	for model_index in range(boltstorm_choices.size()):
		if bool(boltstorm_choices[model_index]):
			ArmyRoster.set_model_equipment(entry, 0, model_index, "aggressor_boltstorm", true)
	ArmyRoster.set_model_visual_override(entry, 0, 1, visual_id)
	list.entries.append(entry)
	return list

func _select_saved_list(game: Node, owner: int, list_id: String) -> bool:
	var picker: OptionButton = game.saved_army_pickers[owner]
	for index in range(picker.item_count):
		var metadata: Variant = picker.get_item_metadata(index)
		if metadata is Dictionary and str(metadata.get("id", "")) == list_id:
			picker.select(index)
			return true
	return false

func _complete_setup(game: Node, owner: int) -> bool:
	for choice: Dictionary in UnitActions.choices(game.state, owner):
		if str(choice.get("action", "")) != "setup-done": continue
		var submitted: Dictionary = game._unit_choice_payload(choice)
		game._apply_unit_action(owner, submitted, Vector2.ZERO, int(game.state.revision))
		return game.state.get("unit_abilities", {}).get("setup_players", []).has(owner)
	return false

func _has_setup_done_choice(state: Dictionary, owner: int) -> bool:
	for choice: Dictionary in UnitActions.choices(state, owner):
		if str(choice.get("action", "")) == "setup-done": return true
	return false

func _aggressor_loadouts(state: Dictionary, owner: int) -> Array:
	var setup: Dictionary = state.get("saved_army_setup", {})
	var armies: Dictionary = setup.get("armies", {})
	var army: Dictionary = armies.get(owner, armies.get(str(owner), {}))
	for entry: Variant in army.get("entries", []):
		if entry is Dictionary and str(entry.get("definition_id", "")).ends_with(":aggressor-squad"):
			return entry.get("aggressor_loadouts", [])
	return []

func _presentation_has_override(presentation: Variant, owner: int, expected_id: String) -> bool:
	if not presentation is Dictionary: return false
	var snapshots: Variant = presentation.get("visual_armies", {})
	if not snapshots is Dictionary: return false
	var snapshot: Variant = snapshots.get(owner, snapshots.get(str(owner), {}))
	if not snapshot is Dictionary: return false
	for entry: Variant in snapshot.get("entries", []):
		if not entry is Dictionary: continue
		var overrides: Variant = entry.get("visual_model_overrides_by_id", {})
		if not overrides is Dictionary: continue
		if expected_id in overrides.values(): return true
	return false

func _remove_file(path: String) -> void:
	if FileAccess.file_exists(path): DirAccess.remove_absolute(path)

func _finish(game: Node) -> void:
	game.free()
	print("Saved match interruption checks: %d failures" % failures)
	quit(1 if failures > 0 else 0)
