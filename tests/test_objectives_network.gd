extends SceneTree
func _initialize() -> void: call_deferred("run")
func revision(game: Node, wanted: int) -> bool:
	for attempt in range(100):
		if game.state.revision >= wanted: return game.state.revision == wanted
		await create_timer(0.1).timeout
	push_error("Objective network timeout: " + game.status.text)
	return false
func run() -> void:
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	game._start_objectives()
	var host: bool = "--host-test" in OS.get_cmdline_user_args()
	if host:
		game._host()
		game.state.active = 2
		game.state.round = 5
		game.state.phase = "shooting"
		for id: int in game.state.units:
			if id not in [100, 200]: game.state.units[id].wounds = 0
		game.state.units[200].position = Vector2(1, 0)
		for attempt in range(100):
			if game.guest_id != 0: break
			await create_timer(0.1).timeout
		var passed: bool = game.guest_id != 0 and await revision(game, 4)
		await create_timer(0.4).timeout
		passed = passed and game.state.test_winner == 2 and game.state.mission.scores == {1: 0, 2: 1} and game.state.mission.scored_rounds == [5]
		print("OBJECTIVES NETWORK HOST: ", "PASS" if passed else "FAIL")
		quit(0 if passed else 1)
		return
	game._join()
	for attempt in range(100):
		if game.state.active == 2: break
		await create_timer(0.1).timeout
	var passed: bool = game.state.active == 2 and game.state.mission.id == game.Combat.Objectives.TRAINING
	game.request_end.rpc_id(1, 0)
	passed = await revision(game, 1) and passed
	passed = passed and game.state.mission.objectives[0].controller == 2 and "Central ruin: P2" in game.details.text
	game.request_end.rpc_id(1, 0)
	await create_timer(0.2).timeout
	passed = passed and game.state.revision == 1 and game.state.mission.scores[2] == 0
	for expected in [2, 3, 4]:
		game.request_end.rpc_id(1, expected - 1)
		passed = await revision(game, expected) and passed
	game.request_end.rpc_id(1, 4)
	await create_timer(0.2).timeout
	passed = passed and game.state.revision == 4 and game.state.test_winner == 2 and game.end_button.disabled and "VP 0 / 1" in game.details.text and "Training finished" in game.event_log.text
	print("OBJECTIVES NETWORK CLIENT: ", "PASS" if passed else "FAIL")
	await create_timer(0.8).timeout
	quit(0 if passed else 1)
