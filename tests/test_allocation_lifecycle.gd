extends "res://tests/test_roll_choice_ui.gd"
## Synthetic deterministic combat exercises the actual recipient-card signals.
## No datasheet accuracy or native-driver coverage is implied.
func run() -> void:
	game = ControlledGame.new()
	root.add_child(game)
	await process_frame
	game._skip_first_run_model_setup()
	game.match_save_path = "user://matches/allocation-lifecycle.save"
	game.match_journal_directory = "user://matches/journals/allocation-lifecycle"
	game.combat_enabled = true
	game.manual_allocation = true
	var checkpoint := fixture("shooting")
	checkpoint.squads[1].weapon.keywords = {}
	checkpoint.squads[1].weapon.damage = 1
	install(checkpoint)
	var result := Commands.execute(game.state, 1, {"kind":Commands.SHOOT,"attacker":100,"target":200,"revision":game.state.revision}, game._d6)
	check(str(result.get("error", "")).is_empty(), "Begin a real deterministic attack before recipient selection")
	for iteration in 30:
		game._refresh()
		if not C.Stratagems.pending(game.state).is_empty():
			game.reaction_roll.pressed.emit()
		elif not game.state.get("pending_attack", {}).is_empty():
			break
		else: break
	check(not game.state.get("pending_attack", {}).is_empty() and game.recipient_cards.get_child_count() > 0, "Reach the real failed-save recipient cards")
	if game.recipient_cards.get_child_count() > 0:
		if game.local_player_handoff.visible: game.local_player_handoff.ready_button.pressed.emit()
		var before := var_to_str(game.state)
		var row: Node = game.recipient_cards.get_child(0)
		var button: Button = row.get_child(1)
		button.pressed.emit()
		check(var_to_str(game.state) == before and game.selected in C.Allocation.eligible(game.state), "Recipient-card selection is preview-only")
		check(is_instance_valid(button) and row.is_queued_for_deletion() and row.get_parent() == null, "The detached card stays alive until its signal emission finishes")
		await process_frame
		for repeat_selection in 20:
			if game.recipient_cards.get_child_count() == 0: break
			var next_row: Node = game.recipient_cards.get_child(repeat_selection % game.recipient_cards.get_child_count())
			var next_button: Button = next_row.get_child(1)
			next_button.pressed.emit()
			check(var_to_str(game.state) == before, "Repeated real card selection never commits damage or consumes RNG")
			await process_frame
	var eligible: Array = C.Allocation.eligible(game.state)
	if not eligible.is_empty():
		game.selected = int(eligible[0])
		game._refresh()
		var allocation := C.Allocation.pending_decision(game.state)
		check(game.decision_view.is_read_only() and game.decision_view.decision_id == allocation.decision_id, "Allocation view uses the authoritative decision identity")
		check(game.decision_view.kind == "Allocation" and game.decision_view.decision_player == allocation.priority_player_id, "The owner strip identifies the defending player as the allocator")
		var inspection_state := var_to_bytes(game.state)
		var recipient: int = game.selected
		game.allocate_button.grab_focus()
		game._open_selected_datasheet()
		check(game.tactical_overlay_content == game.datasheet_details, "The recipient remains inspectable during allocation")
		game._close_tactical_screen()
		await process_frame
		check(var_to_bytes(game.state) == inspection_state and game.selected == recipient and root.gui_get_focus_owner() == game.allocate_button, "Closing the datasheet restores the recipient and pending confirmation focus")
		var checkpoint_state := game.state.duplicate(true)
		var saved_rng: int = game.rng.state
		var path := "user://matches/pending-allocation.save"
		var save_error: String = game.MatchSave.write(checkpoint_state, game._save_config(), saved_rng, {}, path)
		check(save_error.is_empty(), "The existing save format accepts the complete pending allocation")
		var restored: Dictionary = game.MatchSave.read(path)
		check(str(restored.get("error", "")).is_empty() and restored.get("state", {}) == checkpoint_state and int(restored.get("rng_state", -1)) == saved_rng, "Pending damage, revision, decisions and RNG round-trip without a new roll")
		var model: int = game.selected
		var wounds: int = game.state.units[model].wounds
		var revision: int = game.state.revision
		game.allocate_button.grab_focus()
		var echo := InputEventKey.new()
		echo.echo = true
		echo.pressed = true
		echo.keycode = KEY_ENTER
		check(game._decision_repeat_input(echo), "Held confirm-key echo is filtered before Control activation")
		var double_click := InputEventMouseButton.new()
		double_click.button_index = MOUSE_BUTTON_LEFT
		double_click.pressed = true
		double_click.double_click = true
		double_click.position = game.allocate_button.get_global_rect().get_center()
		check(game._decision_repeat_input(double_click), "A second physical double-click over allocation is filtered")
		game.allocate_button.pressed.emit()
		game.allocate_button.pressed.emit()
		check(int(game.state.revision) == revision + 1 and int(game.state.units[model].wounds) == wounds - 1, "Two confirmation callbacks in one input cycle apply exactly one damaging attack")
		check(C.Allocation.eligible(game.state) == [model], "The wounded model retains priority for the next failed save")
		await process_frame
		check(root.gui_get_focus_owner() == game.allocate_button, "The next allocation retains confirmation focus after the input-cycle guard releases")
		for step in 20:
			if game.state.get("pending_attack", {}).is_empty(): break
			var next_eligible: Array = C.Allocation.eligible(game.state)
			if next_eligible.is_empty(): break
			if game.local_player_handoff.visible: game.local_player_handoff.ready_button.pressed.emit()
			game.selected = int(next_eligible[0])
			game._refresh()
			game.allocate_button.pressed.emit()
			await process_frame
		check(game.state.get("pending_attack", {}).is_empty(), "Intentional later confirmations finish all pending damage without a lifecycle crash")
		check(game.status.text == "Attack recorded.", "Final allocation reports the completed attack")
		var pools: Array = game.state.get("last_attack", {}).get("pools", [])
		check(int(game.state.units[model].wounds) == 0 and pools.any(func(pool: Dictionary) -> bool: return int(pool.get("models_destroyed", 0)) > 0), "The wounded recipient is destroyed and recorded during later resolution")
	print("Allocation lifecycle checks: %d failures" % failures)
	game.queue_free()
	await process_frame
	quit(0 if failures == 0 else 1)
