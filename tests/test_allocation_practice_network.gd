extends SceneTree
func _initialize() -> void: call_deferred("run")
func six() -> int: return 6
func revision(game: Node, wanted: int) -> bool:
	for attempt in range(100):
		if game.state.revision >= wanted: return game.state.revision == wanted
		await create_timer(0.1).timeout
	return false
func run() -> void:
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	game._start_allocation_practice()
	if "--host-test" in OS.get_cmdline_user_args():
		game._host()
		game.rng.seed = 42
		for attempt in range(100):
			if game.guest_id != 0: break
			await create_timer(0.1).timeout
		await create_timer(0.3).timeout
		var result: Dictionary = game.Combat.shoot(game.state, 1, 100, 200, 0, true, six)
		var passed: bool = result.error.is_empty() and game.state.pending_attack.current.phase == "precision"
		passed = passed and game.state.board_size == Vector2(43, 43) and game.state.points_limit == 1000
		game._broadcast()
		game._request_skip_precision()
		for attempt in range(100):
			if game.state.squads[1].shot: break
			await create_timer(0.1).timeout
		passed = passed and game.state.squads[1].shot and game.state.last_attack.pools[0].devastating_wounds == 4 and game.state.last_attack.pools[0].precision_model == -1
		print("ALLOCATION PRACTICE HOST: ", "PASS" if passed else "FAIL")
		await create_timer(0.6).timeout
		quit(0 if passed else 1)
		return
	game._join()
	var passed: bool = await revision(game, 2)
	passed = passed and game.state.rules_practice and game.state.pending_attack.current.steps.size() == 4 and game.state.pack_hash == game._initial_state().pack_hash
	passed = passed and game.state.board_size == Vector2(43, 43) and game.state.points_limit == 1000 and game.rendered_board_size == Vector2(43, 43)
	game.selected = 200
	game._refresh()
	game._request_allocate_damage()
	passed = await revision(game, 3) and passed
	game._offline("Rules practice rejoin fixture")
	await create_timer(0.7).timeout
	game._join()
	passed = await revision(game, 3) and passed
	passed = passed and game.state.pending_attack.current.cursor == 1 and game.state.units[201].feel_no_pain[0].target == 5
	for step in range(5):
		if game.state.pending_attack.is_empty(): break
		var choices: Array[int] = game.Combat.Allocation.eligible(game.state)
		var wanted: int = game.state.revision + 1
		game.selected = choices[0]
		game._refresh()
		game._request_allocate_damage()
		passed = await revision(game, wanted) and passed
	passed = passed and game.state.pending_attack.is_empty() and game.state.squads[1].shot and game.state.last_attack.pools[0].allocations.size() == 4
	print("ALLOCATION PRACTICE CLIENT: ", "PASS" if passed else "FAIL")
	await create_timer(0.3).timeout
	quit(0 if passed else 1)
