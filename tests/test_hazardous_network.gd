extends SceneTree
var dice: Array = [1, 1, 1, 2]
func roll() -> int: return dice.pop_front() if not dice.is_empty() else 0
func _initialize() -> void: call_deferred("run")
func revision(game: Node, wanted: int) -> bool:
	for attempt in range(100):
		if game.state.revision >= wanted: return game.state.revision == wanted
		await create_timer(0.1).timeout
	return false
func run() -> void:
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	game.equipment_choice.button_pressed = true
	game._start_objectives(2)
	if "--host-test" in OS.get_cmdline_user_args():
		game._host()
		game.state.squads[1].owner = 2
		game.state.squads[2].owner = 1
		for id: int in game.state.units:
			if game.state.units[id].squad == 1: game.state.units[id].owner = 2
			if game.state.units[id].squad == 2: game.state.units[id].owner = 1
			if id not in [100, 101, 200, 201]: game.state.units[id].wounds = 0
		game.state.active = 2
		game.state.phase = "shooting"
		game.state.units[100].position = Vector2(-12, -8)
		game.state.units[101].position = Vector2(-10, -8)
		game.state.units[200].position = Vector2(-2, -8)
		game.state.units[201].position = Vector2(0, -8)
		game.state.units[101].ranged_weapons.append(game.state.units[100].ranged_weapons[1].duplicate(true))
		for attempt in range(100):
			if game.guest_id != 0: break
			await create_timer(0.1).timeout
		await create_timer(0.3).timeout
		var rows := [{"model": 100, "target": 2, "amount": 1, "weapon": "plasma", "profile": "supercharge"}, {"model": 101, "target": 2, "amount": 1, "weapon": "plasma", "profile": "supercharge"}]
		var result: Dictionary = game.Combat.resolve_attack_plan(game.state, 2, 100, rows, 0, false, true, roll)
		var passed: bool = result.error.is_empty() and game.state.pending_hazard.remaining == 2 and dice.is_empty()
		game._broadcast()
		game._refresh()
		passed = await revision(game, 3) and passed
		passed = passed and game.state.pending_hazard.is_empty() and game.state.last_attack.hazardous.rolls == [1, 2] and game.state.last_attack.hazardous.allocations == [101, 101] and game.state.squads[1].shot
		print("HAZARDOUS NETWORK HOST: ", "PASS" if passed else "FAIL")
		await create_timer(0.5).timeout
		quit(0 if passed else 1)
		return
	game._join()
	var passed: bool = await revision(game, 1)
	game.selected = 101
	game._refresh()
	passed = passed and game.Combat.actor(game.state) == 2 and game.allocate_button.visible and not game.allocate_button.disabled and game.end_button.disabled and "Hazardous" in game.details.text
	var before := var_to_str(game.state)
	game.request_end.rpc_id(1, 1)
	game.request_allocate_damage.rpc_id(1, 200, 1)
	game.request_allocate_damage.rpc_id(1, 101, 0)
	await create_timer(0.2).timeout
	passed = passed and before == var_to_str(game.state)
	game._request_allocate_damage()
	passed = await revision(game, 2) and passed
	passed = passed and game.state.units[101].wounds == 1 and game.Combat.Hazard.eligible(game.state) == [101]
	game._offline("Hazardous reconnect fixture")
	await create_timer(0.7).timeout
	game._join()
	passed = await revision(game, 2) and passed
	passed = passed and game.state.pending_hazard.resolved.hazardous.rolls == [1, 2] and game.state.pending_hazard.remaining == 1
	game.selected = 101
	game._refresh()
	game._request_allocate_damage()
	passed = await revision(game, 3) and passed
	passed = passed and game.state.pending_hazard.is_empty() and not game.allocate_button.visible and "Hazardous: [1, 2]" in game.event_log.text
	print("HAZARDOUS NETWORK CLIENT: ", "PASS" if passed else "FAIL")
	await create_timer(0.3).timeout
	quit(0 if passed else 1)
