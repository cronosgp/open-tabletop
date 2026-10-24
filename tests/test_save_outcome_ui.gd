extends "res://tests/test_roll_choice_ui.gd"

func run() -> void:
	game = ControlledGame.new()
	root.add_child(game)
	game.match_save_path = "user://matches/save-outcome-%s.save" % Time.get_ticks_usec()
	game.match_journal_directory = "user://matches/journals/save-outcome-%s" % Time.get_ticks_usec()
	game.combat_enabled = true
	game.manual_allocation = true
	for saved: bool in [true, false]:
		var state := fixture("shooting")
		state.squads[1].weapon.ap = 0 if saved else -6
		state.squads[1].weapon.damage = 1
		state.squads[1].weapon.keywords = {}
		install(state)
		var result := Commands.execute(game.state, 1, {"kind": Commands.SHOOT, "attacker": 100, "target": 200, "revision": game.state.revision}, game._d6)
		check(str(result.get("error", "")).is_empty(), "Synthetic save outcome begins through public attack")
		var save_decision_seen := false
		var allocation_captured := false
		for iteration in range(30):
			game._refresh()
			var window: Dictionary = C.Stratagems.pending(game.state)
			if not window.is_empty():
				if str(window.kind) == "after_save_roll":
					save_decision_seen = true
					game.combat_tray.finish()
					check("await confirmation" in game.combat_tray.summary.text, "A pending save reroll never announces damage or a confirmed save")
				game.reaction_roll.pressed.emit()
			elif not game.state.get("pending_attack", {}).is_empty():
				game.combat_tray.finish()
				check(not saved and "Save failed" in game.combat_tray.summary.text and "damage is still pending" in game.combat_tray.summary.text, "Failed save distinguishes pending allocation from applied damage")
				if not allocation_captured and "--capture-feedback" in OS.get_cmdline_user_args():
					await capture("failed-pending")
					allocation_captured = true
				var eligible: Array = C.Allocation.eligible(game.state)
				if eligible.is_empty(): break
				game.selected = int(eligible[0])
				game._refresh()
				game.allocate_button.pressed.emit()
			else: break
		game._refresh()
		game.combat_tray.finish()
		check(save_decision_seen and not game.state.get("last_attack", {}).is_empty(), "Both cases reached real save confirmation and attack completion")
		var pool: Dictionary = game.state.last_attack.pools[0]
		check(game.state.last_attack.completion_revision <= game.state.revision, "Attack identity is a stable recorded completion revision")
		if saved:
			check(pool.saves_passed == 4 and pool.unsaved == 0 and pool.damage_applied == 0 and "Saved · no damage applied" in game.combat_tray.summary.text, "Confirmed successful saves visibly protect models")
		else:
			check(pool.saves_passed == 0 and pool.unsaved == 4 and pool.damage_applied == 4 and "4 damage applied" in game.combat_tray.summary.text, "Failed saves announce damage only after allocation commits")
		if "--capture-feedback" in OS.get_cmdline_user_args(): await capture("saved" if saved else "damage")
		var completion_key: String = game.combat_tray.signature
		var bursts: int = game.attack_feedback.bursts
		game._apply_end(1, int(game.state.revision))
		check(game.state.phase != "shooting", "The real phase transition completes without an attack")
		check(game.combat_tray.signature == completion_key and not game.combat_tray.sequence.is_running() and game.attack_feedback.bursts == bursts, "Actual phase progression does not replay dice or battlefield attack cues")
	print("Save outcome UI checks: %d failures" % failures)
	game.queue_free()
	await process_frame
	await process_frame
	quit(1 if failures else 0)

func capture(label: String) -> void:
	for dimensions in [Vector2i(1280, 800), Vector2i(1024, 768)]:
		root.mode = Window.MODE_WINDOWED
		root.size = dimensions
		root.warp_mouse(Vector2(20, 20))
		game._refresh()
		for frame in range(16): await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://.tools/save-feedback-%s-%d.png" % [label, dimensions.x])
