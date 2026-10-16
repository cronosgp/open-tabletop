extends SceneTree

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	var host: bool = "--host-test" in OS.get_cmdline_user_args()
	if host:
		game._host()
		await create_timer(3).timeout
		game._apply_end(1)
		for attempt in range(100):
			if game.state.turn == 3: break
			await create_timer(0.1).timeout
		var passed: bool = game.state.units[21].position == Vector2(7, 0) and game.state.active == 1 and game.state.turn == 3
		print("NETWORK HOST: ", "PASS" if passed else "FAIL")
		# Let the client observe the final snapshot before closing the peer.
		await create_timer(1).timeout
		quit(0 if passed else 1)
		return
	game._join()
	for attempt in range(50):
		await create_timer(0.1).timeout
		if game.status.text == "State synchronized with host.": break
	if game.status.text != "State synchronized with host.":
		push_error("Client did not receive initial snapshot")
		quit(1)
		return
	# A guest cannot move out of turn or move host pieces.
	game.request_move.rpc_id(1, 21, Vector2(7, 0))
	await create_timer(0.2).timeout
	if game.state.units[21].position != Vector2(12, 0):
		quit(1)
		return
	# Host test advances its own turn through the same validation path.
	# Triggered by a separate timer in the host process below.
	for attempt in range(50):
		await create_timer(0.1).timeout
		if game.state.active == 2: break
	game.request_move.rpc_id(1, 11, Vector2(-7, 0))
	game.request_move.rpc_id(1, 21, Vector2(7, 0))
	for attempt in range(100):
		if game.state.units[21].position == Vector2(7, 0): break
		await create_timer(0.1).timeout
	var moved: bool = game.state.units[21].position == Vector2(7, 0) and game.state.units[11].position == Vector2(-12, 0)
	game.request_end.rpc_id(1)
	for attempt in range(100):
		if game.state.active == 1 and game.state.turn == 3: break
		await create_timer(0.1).timeout
	var passed: bool = moved and game.state.active == 1 and game.state.turn == 3
	print("NETWORK CLIENT: ", "PASS" if passed else "FAIL")
	# Remain connected until host finishes checking its state.
	await create_timer(5).timeout
	quit(0 if passed else 1)
