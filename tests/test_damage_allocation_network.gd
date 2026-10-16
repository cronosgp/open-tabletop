extends SceneTree
func _initialize() -> void: call_deferred("run")
func at_revision(game: Node, wanted: int) -> bool:
	for attempt in range(100):
		if game.state.revision >= wanted: return game.state.revision == wanted
		await create_timer(0.1).timeout
	return false
func run() -> void:
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	game.defender_choice.button_pressed = true
	game._start_objectives(2)
	var melee: bool = "--melee-test" in OS.get_cmdline_user_args()
	var host: bool = "--host-test" in OS.get_cmdline_user_args()
	if host:
		game._host()
		game.state.phase = "fight" if melee else "shooting"
		game.state.fight_step = "attacks"
		game.state.fight_actor = 1
		game.state.squads[1].charged = melee
		for id: int in game.state.units:
			if id not in [100, 200, 201, 202, 400]: game.state.units[id].wounds = 0
		game.state.units[100].position = Vector2(-4, -8) if melee else Vector2(-12, -8)
		game.state.units[200].position = Vector2(-2, -8)
		game.state.units[201].position = Vector2(0, -8)
		game.state.units[202].position = Vector2(2, -8)
		game.state.units[400].position = Vector2(10, 8)
		game.state.squads[2].stats.wounds = 2
		for id in [200, 201, 202]:
			game.state.units[id].wounds = 2
			game.state.units[id].max_wounds = 2
		var weapon := {"name": "Allocation fixture", "attacks": 8, "skill": 2, "strength": 10, "ap": -6, "damage": 1, "range_inches": 30, "keywords": {}}
		game.state.squads[1]["melee_weapon" if melee else "weapon"] = weapon
		game.rng.seed = 42
		for attempt in range(100):
			if game.guest_id != 0: break
			await create_timer(0.1).timeout
		await create_timer(0.5).timeout
		if melee: game._apply_fight(1, 100, 200, 0)
		else: game._apply_attack(1, 100, 200, 0, true)
		var passed: bool = game.state.revision == 1 and not game.state.pending_attack.is_empty() and game.Combat.actor(game.state) == 2
		for attempt in range(100):
			if game.state.pending_attack.is_empty(): break
			await create_timer(0.1).timeout
		await create_timer(0.4).timeout
		passed = passed and game.state.pending_attack.is_empty() and game.state.last_attack.pools[0].allocations[0].model == 201 and (game.state.squads[1].fought if melee else game.state.squads[1].shot)
		print("DAMAGE ALLOCATION HOST ", "MELEE" if melee else "RANGED", ": ", "PASS" if passed else "FAIL")
		quit(0 if passed else 1)
		return
	game._join()
	var passed: bool = await at_revision(game, 1)
	passed = passed and game.state.manual_allocation and game.Combat.actor(game.state) == 2 and game.state.pending_attack.current.failed_rolls.size() >= 2
	game.selected = 201
	game._refresh()
	passed = passed and game.allocate_button.visible and not game.allocate_button.disabled and game.end_button.disabled and "Eligible models" in game.details.text
	var before := var_to_str(game.state)
	game.request_end.rpc_id(1, 1)
	game.request_allocate_damage.rpc_id(1, 100, 1)
	game.request_allocate_damage.rpc_id(1, 201, 0)
	await create_timer(0.2).timeout
	passed = passed and before == var_to_str(game.state)
	game._request_allocate_damage()
	passed = await at_revision(game, 2) and passed
	passed = passed and game.state.units[201].wounds == 1 and game.Combat.Allocation.eligible(game.state) == [201]
	game._offline("Reconnect allocation test")
	await create_timer(0.7).timeout
	game._join()
	passed = await at_revision(game, 2) and passed
	passed = passed and not game.state.pending_attack.is_empty() and game.Combat.Allocation.eligible(game.state) == [201]
	game.selected = 201
	game._refresh()
	before = var_to_str(game.state)
	game.request_allocate_damage.rpc_id(1, 200, 2)
	await create_timer(0.2).timeout
	passed = passed and before == var_to_str(game.state)
	for step in range(20):
		if game.state.pending_attack.is_empty(): break
		var choices: Array[int] = game.Combat.Allocation.eligible(game.state)
		var model: int = choices[choices.size() - 1]
		var expected: int = game.state.revision + 1
		game.request_allocate_damage.rpc_id(1, model, game.state.revision)
		passed = await at_revision(game, expected) and passed
	passed = passed and game.state.pending_attack.is_empty() and game.state.last_attack.pools[0].allocations[0].model == 201 and not game.allocate_button.visible
	print("DAMAGE ALLOCATION CLIENT ", "MELEE" if melee else "RANGED", ": ", "PASS" if passed else "FAIL")
	await create_timer(0.8).timeout
	quit(0 if passed else 1)
