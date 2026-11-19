extends SceneTree
const Controlled = preload("res://tests/fixtures/controlled_model_preparer.gd")
var failures := 0
func _initialize() -> void: call_deferred("run")
func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func run() -> void:
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game._skip_first_run_model_setup()
	var preparer = Controlled.install(game)
	var before := var_to_str(game.state)
	game.main_menu.guided_button.pressed.emit()
	check(game.local_visual_preflight_pending and not game.combat_enabled and var_to_str(game.state) == before, "Preparation preserves the current state and waits before materializing a match")
	check(preparer.requested_definitions.size() == 6 and not preparer.requested_variants.is_empty(), "Tactical launch requests its six real local definitions and role scopes")
	preparer.finish_preparation(true)
	for frame in range(3): await process_frame
	check(game.combat_enabled and game.guided_first_session, "Successful asynchronous preparation starts tactical training")
	check(not game.main_menu.visible and game.tactical_overlay_content == null and game.combat_hud.visible, "Asynchronous success reveals the actual table rather than leaving the title over it")
	game._exit_match_to_title_screen()
	game.main_menu.guided_button.pressed.emit()
	preparer.finish_preparation(false)
	check(not game.combat_enabled and game.main_menu.guided_button.text == "Start with available models", "Unavailable models offer an explicit fallback action without starting silently")
	game.main_menu.guided_button.pressed.emit()
	check(game.combat_enabled and game.guided_first_session and not game.main_menu.visible, "The public fallback action starts the intended training and closes the menu")
	game._exit_match_to_title_screen()
	before = var_to_str(game.state)
	game.main_menu.guided_button.pressed.emit()
	game.main_menu.guided_button.pressed.emit()
	check(preparer.cancel_calls == 1 and not game.local_visual_preflight_pending and not game.combat_enabled, "The public cancel action stops preparation without starting a match")
	preparer.finish_preparation(true)
	await process_frame
	check(var_to_str(game.state) == before and not game.combat_enabled, "A late completion after cancellation cannot launch or change the match")
	game.main_menu.guided_button.pressed.emit()
	check(game.combat_enabled, "Cancellation leaves an explicit available-models continuation")
	game._exit_match_to_title_screen()
	game.main_menu.guided_button.pressed.emit()
	game._set_training_swap(true)
	preparer.finish_preparation(true)
	await process_frame
	check(not game.combat_enabled and not game.local_visuals_ready_for_launch and "changed" in game.main_menu.status_label.text.to_lower(), "Changing sides during preparation rejects the obsolete completion")
	game.main_menu.guided_button.pressed.emit()
	preparer.finish_preparation(false)
	game.main_menu.guided_button.pressed.emit()
	check(game.combat_enabled and game._picked_army(1).id == game.TrainingRoster.Tactical.ASSAULT_ID and game.state.training_points[1] < game.state.training_points[2], "Retry prepares and launches the newly selected sides")
	game._exit_match_to_title_screen()
	preparer.accept_start = false
	game.main_menu.guided_button.pressed.emit()
	check(not game.local_visual_preflight_pending and not game.main_menu.guided_button.disabled and not game.combat_enabled, "An unavailable preparer leaves a retryable title without a partial match")
	preparer.accept_start = true
	game.main_menu.guided_button.pressed.emit()
	preparer.finish_preparation(true)
	game._set_training_swap(false)
	for frame in range(3): await process_frame
	check(not game.combat_enabled, "A side change between completion and deferred launch is rechecked")
	game.local_visuals_ready_for_launch = false
	game.auto_models.set_pressed_no_signal(false)
	game._open_new_match_workspace()
	game._refresh_army_choices()
	var calls: int = preparer.prepare_calls
	game.saved_army_start_button.pressed.emit()
	for frame in range(2): await process_frame
	check(game.combat_enabled and not game.main_menu.visible and game.tactical_overlay_content == null, "New Match's saved-army action closes its workspace and reveals the table")
	check(preparer.prepare_calls == calls, "Disabling automatic models does not request preparation")
	print("Match launch workflow checks: %d failures" % failures)
	game.queue_free()
	await process_frame
	quit(0 if failures == 0 else 1)
