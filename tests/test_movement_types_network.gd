extends SceneTree

func _initialize() -> void: call_deferred("run")

func at_revision(game: Node, revision: int) -> bool:
	for attempt in range(100):
		if game.state.revision >= revision: return game.state.revision == revision
		await create_timer(0.1).timeout
	push_error("Timed out waiting for revision %d: %s" % [revision, game.status.text])
	return false

func run() -> void:
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	game._toggle_combat("legacy-solid-v1")
	if not game.combat_enabled:
		quit(1)
		return
	var host: bool = "--host-test" in OS.get_cmdline_user_args()
	if host:
		game._host()
		game.state.active = 2
		game.state.phase = "movement"
		for id: int in game.state.units:
			if id not in [100, 200, 201]: game.state.units[id].wounds = 0
		game.state.units[100].position = Vector2(-10, -8)
		game.state.units[200].position = Vector2(12, -8)
		game.state.units[201].position = Vector2(12, -6.5)
		game.rng.seed = 42
		for attempt in range(100):
			if game.guest_id != 0: break
			await create_timer(0.1).timeout
		if game.guest_id == 0 or not await at_revision(game, 3):
			quit(1)
			return
		var passed: bool = game.state.squads[2].advanced and game.state.pending_move.is_empty()
		# Second explicit test fixture: the guest is engaged and can escape.
		game.state.squads[2].moved = false
		game.state.squads[2].advanced = false
		game.state.squads[2].move_type = "unselected"
		game.state.units[100].position = Vector2(8.5, -6.5)
		game.state.units[200].position = Vector2(10, -8)
		game.state.units[201].position = Vector2(10, -6.5)
		# Select a deterministic seed with one failed hazard and one pass.
		for candidate in range(1000):
			game.rng.seed = candidate
			var first: int = game._d6()
			var second: int = game._d6()
			if first <= 2 and second > 2:
				game.rng.seed = candidate
				break
		game.Combat._event(game.state, "Network fixture: engaged Fall Back.")
		game._broadcast()
		passed = await at_revision(game, 8) and passed
		await create_timer(0.6).timeout
		passed = passed and game.state.revision == 8 and game.state.units[200].wounds == 0 and game.state.units[201].position == Vector2(5, -6.5) and game.state.squads[2].fell_back and game.state.last_morale.size() == 1
		print("MOVEMENT TYPES NETWORK HOST: ", "PASS" if passed else "FAIL")
		quit(0 if passed else 1)
		return
	game._join()
	for attempt in range(100):
		if game.state.active == 2 and game.state.phase == "movement": break
		await create_timer(0.1).timeout
	if game.state.active != 2:
		quit(1)
		return
	game.selected = 200
	game.movement_choice.select(1)
	game._refresh()
	var passed: bool = game.begin_move_button.visible and not game.begin_move_button.disabled
	game.request_begin_movement.rpc_id(1, 100, "advance", 0) # Opponent cannot act.
	game._request_begin_movement()
	passed = await at_revision(game, 1) and passed
	var bonus: int = game.state.pending_move.bonus
	passed = passed and bonus in range(1, 7) and is_equal_approx(game.guides.current_range, 5 + bonus)
	game.request_begin_movement.rpc_id(1, 200, "advance", 0) # Stale reroll.
	game._request_finish_movement(true)
	passed = await at_revision(game, 2) and passed
	passed = passed and game.state.pending_move.bonus == bonus and "retain dice" in game.cancel_move_button.text
	game._request_finish_movement(false)
	passed = await at_revision(game, 4) and passed
	game.movement_choice.select(3)
	game._request_begin_movement()
	passed = await at_revision(game, 5) and passed
	passed = passed and game.state.pending_move.hazard_remaining == 1 and game.escape_wound_button.visible and game.finish_move_button.disabled
	game.request_escape_wound.rpc_id(1, 100, 5) # Cannot allocate to enemy.
	game._request_escape_wound()
	passed = await at_revision(game, 6) and passed
	passed = passed and not game.pieces[200].visible and game.state.pending_move.hazard_remaining == 0
	game.selected = 201
	game.request_move.rpc_id(1, 201, Vector2(5, -6.5), 6)
	passed = await at_revision(game, 7) and passed
	game._request_finish_movement(false)
	passed = await at_revision(game, 8) and passed
	game.request_escape_wound.rpc_id(1, 201, 5)
	game.request_finish_movement.rpc_id(1, 7, false)
	await create_timer(0.2).timeout
	passed = passed and game.state.revision == 8 and game.state.squads[2].fell_back and game.state.last_morale[0].rolls.size() == 2 and not game.Combat.can_start_action(game.state, 2)
	print("MOVEMENT TYPES NETWORK CLIENT: ", "PASS" if passed else "FAIL")
	await create_timer(0.8).timeout
	quit(0 if passed else 1)
