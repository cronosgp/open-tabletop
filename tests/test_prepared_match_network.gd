extends SceneTree
# Prepared-training setup materializes the local legacy starter at res://data/imported/starter-11e-v1.
func _initialize() -> void: call_deferred("run")
func revision(game: Node, wanted: int) -> bool:
	for attempt in range(100):
		if game.state.revision >= wanted: return game.state.revision == wanted
		await create_timer(0.1).timeout
	push_error("Prepared match timed out at revision %d waiting for %d: %s" % [game.state.revision, wanted, game.status.text])
	return false
func run() -> void:
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	game._start_prepared_match()
	if "--host-test" in OS.get_cmdline_user_args():
		game._host()
		for attempt in range(100):
			if game.guest_id != 0: break
			await create_timer(0.1).timeout
		await create_timer(0.6).timeout
		var passed: bool = game.guest_id != 0 and game.state.revision == 0
		game._request_deployment_preset()
		game._request_end()
		passed = await revision(game, 5) and passed
		passed = passed and game.state.deployment.committed == [1, 2] and game.state.units[200].position == Vector2(15, -6.6)
		game._request_deployment_preset()
		game._request_end()
		passed = await revision(game, 9) and passed
		passed = passed and game.state.phase == "start_turn" and game.state.deployment.complete and game.state.cp == {1: 0, 2: 0}
		game._request_end()
		passed = passed and game.state.phase == "command" and game.state.cp == {1: 1, 2: 1}
		print("PREPARED MATCH HOST: ", "PASS" if passed else "FAIL")
		await create_timer(1).timeout
		quit(0 if passed else 1)
		return
	game._join()
	for attempt in range(100):
		if game.status.text == "State synchronized with host.": break
		await create_timer(0.05).timeout
	var passed: bool = game.mode == "client" and game.state.phase == "deployment" and game.deployment_confirm_button.disabled
	game.request_move.rpc_id(1, 100, Vector2(-18, 0), 0)
	game.request_end.rpc_id(1, 0, 100)
	await create_timer(0.2).timeout
	passed = passed and game.state.revision == 0
	passed = await revision(game, 2) and passed
	game.request_move.rpc_id(1, 200, Vector2(16, -6.6), 1)
	await create_timer(0.15).timeout
	passed = passed and game.state.revision == 2
	game.request_move.rpc_id(1, 200, Vector2(15, -6.6), 2)
	passed = await revision(game, 3) and passed
	game._offline("Reconnect during deployment")
	await create_timer(0.7).timeout
	game._join()
	passed = await revision(game, 3) and passed
	passed = passed and game.state.deployment.placed.has(200) and game.state.units[200].position == Vector2(15, -6.6) and game.state.pack_hash == game._initial_state().pack_hash
	game._request_deployment_preset()
	passed = await revision(game, 4) and passed
	game._request_end()
	passed = await revision(game, 7) and passed
	game._request_deployment_preset()
	passed = await revision(game, 8) and passed
	game._request_end()
	passed = await revision(game, 10) and passed
	passed = passed and game.state.phase == "command" and not game.action_groups.deployment.container.visible and game.state.cp == {1: 1, 2: 1}
	print("PREPARED MATCH CLIENT: ", "PASS" if passed else "FAIL")
	await create_timer(0.2).timeout
	quit(0 if passed else 1)
