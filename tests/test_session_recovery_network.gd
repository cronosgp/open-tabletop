extends SceneTree
const Seat = preload("res://scripts/session_seat.gd")
var game

func _initialize() -> void: call_deferred("run")

func wait_for(predicate: Callable, description: String) -> bool:
	for attempt in range(150):
		if predicate.call(): return true
		await create_timer(0.1).timeout
	push_error("Session recovery timeout: " + description + ": " + game.status.text)
	return false

func new_game() -> void:
	game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	game._start_prepared_match()

func run() -> void:
	new_game()
	var host: bool = "--host-test" in OS.get_cmdline_user_args()
	if host:
		if "--restored-host" not in OS.get_cmdline_user_args():
			game._host()
			if not await wait_for(func(): return game.guest_id != 0, "first guest"): quit(1); return
			game._request_deployment_preset()
			game._request_end()
			if not await wait_for(func(): return game.guest_id == 0, "first guest disconnect"): quit(1); return
			game.multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()
			game.free()
			await create_timer(0.4).timeout
			# The replacement host is a fresh engine process with the same user://,
			# not a scene retaining credentials or game state in memory.
			var output: Array = []
			var code := OS.execute(OS.get_executable_path(), ["--headless", "--path", ProjectSettings.globalize_path("res://"), "--script", "res://tests/test_session_recovery_network.gd", "--log-file", ProjectSettings.globalize_path("res://.tools/restarted-host.engine.log"), "--", "--host-test", "--restored-host"], output, true)
			for line in output: print(line)
			quit(code)
			return
		var saved := Seat.Save.read()
		assert(not saved.has("error"))
		var session: Dictionary = saved.session
		var snapshot: Dictionary = saved.state
		var random_state: int = saved.rng_state
		game._load_match(true)
		assert(game.mode == "host" and game.host_session == session and game.state == snapshot)
		assert(game.journal.checkpoint() == saved.journal and game.journal.entries.size() >= 3)
		# Intruder attempts a command and a forged credential before the real guest.
		if not await wait_for(func(): return game.guest_id != 0, "restored authorized guest"): quit(1); return
		assert(game.host_session == session and game.rng.state == random_state)
		# Receiving the published snapshot and sending the next command may both
		# finish between two polling frames on the host.
		assert(game.state.revision in [snapshot.revision, snapshot.revision + 1])
		if game.state.revision == snapshot.revision: assert(game.state == snapshot)
		if not await wait_for(func(): return game.state.revision == snapshot.revision + 1, "authorized deployment"): quit(1); return
		print("SESSION RECOVERY HOST: PASS")
		await create_timer(1.0).timeout
		quit()
		return
	game._join()
	if not await wait_for(func(): return game.state.revision == 2, "initial deployment"): quit(1); return
	var seats: Dictionary = Seat.credentials().seats
	assert(seats.size() == 1)
	var id: String = seats.keys()[0]
	var token: String = seats[id]
	assert(token not in var_to_str(game.state))
	game._offline("Testing restart")
	game.free()
	await create_timer(1.0).timeout
	# A different installation with no matching credential must not take the seat.
	assert(Seat.Save.write({}, {}, 0, {}, Seat.PATH).is_empty())
	new_game()
	game._join()
	if not await wait_for(func(): return game.mode == "local", "missing credential rejection"): quit(1); return
	assert(game.state.revision == 0)
	assert(game.history_panel.total == 0)
	game.free()
	await create_timer(0.5).timeout
	assert(Seat.remember(id, Seat.secret()).is_empty())
	new_game()
	game.multiplayer.connected_to_server.connect(func():
		game.request_deployment_preset.rpc_id(1, 2)
		game.request_history_page.rpc_id(1, 0), CONNECT_ONE_SHOT)
	game._join()
	if not await wait_for(func(): return game.mode == "local", "forged credential rejection"): quit(1); return
	assert(game.state.revision == 0)
	assert(game.history_panel.total == 0)
	assert(Seat.remember(id, token).is_empty())
	game.free()
	await create_timer(0.5).timeout
	new_game()
	game._join()
	if not await wait_for(func(): return game.state.revision == 2, "restored snapshot"): quit(1); return
	assert(token not in var_to_str(game.state))
	game.request_history_page.rpc_id(1, 0)
	if not await wait_for(func(): return game.history_panel.total >= 3, "authorized history page"): quit(1); return
	assert(token not in var_to_str(game.history_panel.items))
	assert(not game.history_panel.items[0].has("patch"))
	game._request_deployment_preset()
	if not await wait_for(func(): return game.state.revision == 3, "resumed command"): quit(1); return
	print("SESSION RECOVERY CLIENT: PASS")
	await create_timer(0.6).timeout
	quit()
