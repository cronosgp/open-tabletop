extends SceneTree

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	game._toggle_combat("legacy-solid-v1")
	if not game.combat_enabled:
		push_error("Starter data required")
		quit(1)
		return
	var host: bool = "--host-test" in OS.get_cmdline_user_args()
	if host:
		game._host()
		for attempt in range(100):
			await create_timer(0.1).timeout
			if game.guest_id != 0: break
		if game.guest_id == 0:
			quit(1)
			return
		game._apply_end(1, game.state.revision)
		game._apply_end(1, game.state.revision)
		game._apply_move(1, 100, Vector2(-13, -4), game.state.revision)
		await create_timer(0.7).timeout
		if game.state.revision != 3 or game.state.pending_move.is_empty():
			push_error("Guest cancelled the host's draft")
			quit(1)
			return
		game._apply_finish_movement(1, game.state.revision, false)
		for step in range(7): game._apply_end(game.state.active, game.state.revision)
		for attempt in range(80):
			await create_timer(0.1).timeout
			if game.state.squads[2].moved: break
		await create_timer(0.5).timeout
		var passed: bool = game.state.revision == 15 and game.state.pending_move.is_empty() and game.state.squads[2].moved and game.state.units[200].position.is_equal_approx(Vector2(11.8, -4)) and game.state.units[201].position == Vector2(12, -2)
		print("MOVEMENT NETWORK HOST: ", "PASS" if passed else "FAIL", " revision=", game.state.revision)
		quit(0 if passed else 1)
		return
	game._join()
	for attempt in range(100):
		await create_timer(0.1).timeout
		if game.state.revision == 3: break
	if game.state.revision != 3 or game.state.units[101].position != Vector2(-12, -2):
		quit(1)
		return
	game.request_finish_movement.rpc_id(1, game.state.revision, true)
	for attempt in range(80):
		await create_timer(0.1).timeout
		if game.state.revision == 11: break
	if game.state.revision != 11:
		quit(1)
		return
	game.selected = 200
	game.request_move.rpc_id(1, 200, Vector2(11.8, -4), game.state.revision)
	for attempt in range(40):
		await create_timer(0.1).timeout
		if game.state.revision == 12: break
	if game.state.revision != 12 or not is_equal_approx(game.guides.current_range, 4.8):
		push_error("Remote draft or movement range did not synchronize")
		quit(1)
		return
	game.request_finish_movement.rpc_id(1, game.state.revision, true)
	for attempt in range(40):
		await create_timer(0.1).timeout
		if game.state.revision == 13: break
	if game.state.units[200].position != Vector2(12, -4) or not game.state.pending_move.is_empty():
		quit(1)
		return
	game.request_move.rpc_id(1, 200, Vector2(11.8, -4), game.state.revision)
	for attempt in range(40):
		await create_timer(0.1).timeout
		if game.state.revision == 14: break
	var revision: int = game.state.revision
	game.request_move.rpc_id(1, 200, Vector2(11.7, -4), revision - 1)
	game.request_finish_movement.rpc_id(1, revision, false)
	for attempt in range(40):
		await create_timer(0.1).timeout
		if game.state.revision == 15: break
	game.request_finish_movement.rpc_id(1, revision, true)
	await create_timer(0.25).timeout
	var passed: bool = game.state.revision == 15 and game.state.units[200].position.is_equal_approx(Vector2(11.8, -4)) and game.state.units[201].position == Vector2(12, -2) and game.state.pending_move.is_empty() and is_zero_approx(game.guides.current_range)
	print("MOVEMENT NETWORK CLIENT: ", "PASS" if passed else "FAIL", " revision=", game.state.revision)
	await create_timer(0.8).timeout
	quit(0 if passed else 1)
