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
	game.defender_choice.button_pressed = true
	game._start_objectives(2)
	if "--host-test" in OS.get_cmdline_user_args():
		game._host()
		for id: int in game.state.units:
			if id not in [100, 200, 201, 400]: game.state.units[id].wounds = 0
		game.state.units[100].position = Vector2(-12, -8)
		game.state.units[200].position = Vector2(-2, -8)
		game.state.units[201].position = Vector2(0, -8)
		game.state.units[400].position = Vector2(10, -8)
		game.state.squads[2].stats.wounds = 10
		for id in [200, 201]:
			game.state.units[id].wounds = 10
			game.state.units[id].max_wounds = 10
			game.state.units[id].feel_no_pain = [{"target": 2, "against": "any"}]
		game.state.phase = "shooting"
		game.state.squads[1].weapon = {"name": "FNP fixture", "attacks": 2, "skill": 2, "strength": 8, "ap": -2, "damage": 3, "range_inches": 30, "keywords": {"devastating-wounds": true}}
		game.rng.seed = 42
		for attempt in range(100):
			if game.guest_id != 0: break
			await create_timer(0.1).timeout
		await create_timer(0.3).timeout
		var result: Dictionary = game.Combat.shoot(game.state, 1, 100, 200, 0, true, six)
		var passed: bool = result.error.is_empty() and game.state.pending_attack.current.steps.size() == 2
		game._broadcast()
		passed = await revision(game, 3) and passed
		var pool: Dictionary = game.state.last_attack.pools[0]
		passed = passed and pool.prevented_wounds > 0 and pool.prevention_rolls.size() == 2 and pool.prevention_rolls[0].rolls.size() == 3 and game.state.squads[1].shot
		print("PREVENTION NETWORK HOST: ", "PASS" if passed else "FAIL")
		await create_timer(0.6).timeout
		quit(0 if passed else 1)
		return
	game._join()
	var passed: bool = await revision(game, 1)
	game.selected = 200
	game._refresh()
	passed = passed and "Feel No Pain: 2+" in game.details.text
	game._request_allocate_damage()
	passed = await revision(game, 2) and passed
	var previous: Dictionary = game.state.pending_attack.current.result.prevention_rolls[0].duplicate(true)
	game._offline("Prevention reconnect fixture")
	await create_timer(0.7).timeout
	game._join()
	passed = await revision(game, 2) and passed
	passed = passed and game.state.pending_attack.current.result.prevention_rolls[0] == previous
	game.selected = 200
	game._refresh()
	game._request_allocate_damage()
	passed = await revision(game, 3) and passed
	passed = passed and game.state.pending_attack.is_empty() and "Feel No Pain:" in game.event_log.text and game.state.last_attack.pools[0].prevented_wounds + game.state.last_attack.pools[0].damage_applied == 6
	print("PREVENTION NETWORK CLIENT: ", "PASS" if passed else "FAIL")
	await create_timer(0.3).timeout
	quit(0 if passed else 1)
