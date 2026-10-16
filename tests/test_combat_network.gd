extends SceneTree

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	game._toggle_combat("legacy-solid-v1")
	if not game.combat_enabled:
		push_error("Starter data required for combat integration test")
		quit(1)
		return
	var host: bool = "--host-test" in OS.get_cmdline_user_args()
	if host:
		game.rng.seed = 42
		game._host()
		for attempt in range(100):
			await create_timer(0.1).timeout
			if game.guest_id != 0: break
		if game.guest_id == 0:
			quit(1)
			return
		for phase in range(3): game._apply_end(1, game.state.revision)
		game._apply_attack(1, 100, 200, game.state.revision, true)
		await create_timer(0.8).timeout
		# Guest's wrong-turn command must not consume a phase or another attack.
		if game.state.revision != 4:
			push_error("Guest changed host's turn")
			quit(1)
			return
		for phase in range(7): game._apply_end(game.state.active, game.state.revision)
		for attempt in range(80):
			await create_timer(0.1).timeout
			if game.state.squads[2].shot: break
		await create_timer(0.7).timeout
		var passed: bool = game.state.revision == 12 and game.state.squads[2].shot and game.state.active == 2 and game.Combat.living(game.state, 2).size() < 10
		print("COMBAT NETWORK HOST: ", "PASS" if passed else "FAIL", " revision=", game.state.revision)
		quit(0 if passed else 1)
		return
	game._join()
	for attempt in range(100):
		await create_timer(0.1).timeout
		if game.state.revision == 4: break
	if game.state.revision != 4:
		push_error("Missing host attack snapshot")
		quit(1)
		return
	var survivors: int = game.Combat.living(game.state, 2).size()
	if survivors >= 10:
		push_error("Host casualties not replicated")
		quit(1)
		return
	game.request_attack.rpc_id(1, 209, 100, game.state.revision, true)
	game.request_end.rpc_id(1, game.state.revision)
	for attempt in range(80):
		await create_timer(0.1).timeout
		if game.state.active == 2 and game.state.phase == "shooting": break
	var revision: int = game.state.revision
	var attacker: int = game.Combat.living(game.state, 2)[0]
	game.request_attack.rpc_id(1, attacker, 100, revision, true)
	for attempt in range(40):
		await create_timer(0.1).timeout
		if game.state.squads[2].shot: break
	game.request_attack.rpc_id(1, attacker, 100, revision, true)
	game.request_end.rpc_id(1, revision)
	await create_timer(0.4).timeout
	var passed: bool = game.state.revision == 12 and game.state.squads[2].shot and game.Combat.living(game.state, 2).size() == survivors
	# Selected-model HP and hidden casualty geometry use the synchronized state.
	game.selected = 200
	game._refresh()
	passed = passed and not game.pieces[200].visible
	print("COMBAT NETWORK CLIENT: ", "PASS" if passed else "FAIL", " revision=", game.state.revision)
	await create_timer(0.8).timeout
	quit(0 if passed else 1)
