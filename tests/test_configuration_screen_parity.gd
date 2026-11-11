extends SceneTree
const Launch = preload("res://tests/fixtures/controlled_model_preparer.gd")
var failures := 0
func _initialize() -> void: call_deferred("run")
func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1
func key(code: int, modified: bool = false) -> InputEventKey:
	var event := InputEventKey.new()
	event.keycode = code
	event.physical_keycode = code
	event.pressed = true
	event.ctrl_pressed = modified
	return event

func run() -> void:
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game._skip_first_run_model_setup()
	game.ui_preferences_path = "user://configuration-parity.cfg"
	game._open_settings_screen()
	game.settings_categories.current_tab = 1
	await process_frame
	var initial: Dictionary = game.control_draft.duplicate(true)
	var inspect_action: String = game.INPUT_INSPECT_DATASHEET
	var focus_action: String = game.INPUT_FOCUS_SELECTED_UNIT
	game._start_binding_capture(inspect_action)
	game._unhandled_input(key(int(initial[focus_action])))
	check(game.control_draft[inspect_action] == initial[focus_action] and game.control_draft[focus_action] == initial[inspect_action] and game.pending_binding_action.is_empty(), "Rebinding an occupied key swaps the two staged actions")
	check(game._read_control_bindings_from_input_map() == initial, "Staged controls do not change active bindings before Apply")
	var swapped: Dictionary = game.control_draft.duplicate(true)
	game.settings_categories.current_tab = 0
	game.settings_categories.current_tab = 1
	game._start_binding_capture(inspect_action)
	game._unhandled_input(key(KEY_TAB))
	check(game.control_draft == swapped and game.pending_binding_action == inspect_action and "reserved" in game.settings_notice.text, "Reserved menu keys leave the staged map unchanged and capture retryable")
	game._unhandled_input(key(KEY_K, true))
	check(game.control_draft == swapped and game.pending_binding_action == inspect_action, "Modified keys cannot silently replace a binding")
	game._apply_ui_preferences()
	check(game._read_control_bindings_from_input_map() == initial and not FileAccess.file_exists(game.ui_preferences_path), "Apply cannot persist an unfinished key capture")
	game._unhandled_input(key(KEY_ESCAPE))
	check(game.pending_binding_action.is_empty() and game.control_draft == swapped and game.tactical_overlay_content == game.settings_panel, "Escape cancels capture while retaining the Settings workspace")
	game._apply_ui_preferences()
	check(FileAccess.file_exists(game.ui_preferences_path) and game._read_control_bindings_from_input_map() == swapped, "Apply persists and activates the staged binding swap")
	game._reset_control_bindings()
	game._revert_ui_preferences()
	check(game.control_draft == swapped, "Revert restores the last applied controls rather than defaults")
	game._open_saved_results()
	var browser = game.saved_results_browser
	check(browser.records.is_empty() and browser.empty_label.visible and browser.empty_action.visible, "Empty Results exposes its real recovery action")
	game._close_tactical_screen()
	check(Launch.start_tactical_with_fallbacks(game), "Create a current-catalog controlled match for result and resume checks")
	game.state.test_winner = 1
	game.state.round = 5
	game.state.phase = "end_turn"
	game.state.mission.scores = {1: 18, 2: 12}
	game._refresh()
	var result: Dictionary = game._save_final_result()
	check(result.error.is_empty(), "Save a controlled result through the actual completed-match workflow")
	game._save_match()
	var saved_state := var_to_str(game.state)
	game._exit_match_to_title_screen()
	check(game.main_menu.resume_button.visible, "A compatible saved match exposes Continue on the title")
	game.main_menu.resume_button.pressed.emit()
	check(game.resume_succeeded and not game.main_menu.visible and var_to_str(game.state) == saved_state, "Public Continue restores the saved state and reveals the resumed match")
	game._exit_match_to_title_screen()
	game._open_saved_results()
	check(browser.records.size() == 1 and browser.record_picker.visible and not browser.empty_label.visible and not browser.empty_action.visible, "Populated Results uses the actual saved record and hides empty recovery")
	check("18" in browser.summary.text and "12" in browser.summary.text and "Player 1" in browser.summary.text, "Displayed result and scores match the saved controlled outcome")
	browser.search_field.text = "no-such-match-in-this-profile"
	browser.search_field.text_changed.emit(browser.search_field.text)
	check(browser.filtered_record_indices.is_empty() and "match this search" in browser.empty_label.text and not browser.empty_action.visible, "A zero-result search is distinct from having no saved history")
	browser.search_field.text = ""
	browser.search_field.text_changed.emit("")
	var directory: String = game.saved_results_browser.MatchResult.DIRECTORY
	var bad := FileAccess.open(directory.path_join("damaged.json"), FileAccess.WRITE)
	bad.store_string("{corrupted result fixture")
	bad.close()
	browser.refresh_records()
	check(browser.records.size() == 1 and browser.invalid_files.size() == 1 and browser.scan_issue_toggle.visible, "A damaged result is reported without hiding or rewriting valid history")
	check(FileAccess.get_file_as_string(directory.path_join("damaged.json")) == "{corrupted result fixture", "Result scanning preserves damaged input for recovery")
	print("Configuration screen parity checks: %d failures" % failures)
	game.queue_free()
	await process_frame
	quit(0 if failures == 0 else 1)
