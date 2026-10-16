extends SceneTree
var dice: Array = [6, 6, 6, 3, 6, 6, 1]
var calls := 0
func roll() -> int:
	calls += 1
	return dice.pop_front() if not dice.is_empty() else 0
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
	game.defender_choice.button_pressed = true
	game._start_objectives(2)
	if "--host-test" in OS.get_cmdline_user_args():
		game._host()
		for id: int in game.state.units:
			if id not in [100, 200, 201, 202, 400]: game.state.units[id].wounds = 0
		game.state.units[100].position = Vector2(-4, -8)
		for id in [200, 201, 202]:
			game.state.units[id].position = Vector2(-2 + (id - 200) * 1.5, -8)
			game.state.units[id].wounds = 2
			game.state.units[id].max_wounds = 2
		game.state.units[400].position = Vector2(10, -8)
		game.state.squads[2].stats.wounds = 2
		game.state.squads[1].charged = true
		game.state.phase = "fight"
		game.state.fight_step = "attacks"
		game.state.fight_actor = 1
		for attempt in range(100):
			if game.guest_id != 0: break
			await create_timer(0.1).timeout
		await create_timer(0.3).timeout
		var rows := [{"model": 100, "target": 2, "weapon": "hammer", "profile": "standard", "amount": 3}]
		var result: Dictionary = game.Combat.resolve_attack_plan(game.state, 1, 100, rows, 0, true, true, roll)
		var passed: bool = result.error.is_empty() and game.state.pending_attack.current.steps.size() == 3
		game._broadcast()
		game._refresh()
		passed = await revision(game, 4) and passed
		passed = passed and game.state.pending_attack.is_empty() and game.state.squads[1].fought and calls == 7 and game.state.last_attack.pools[0].mortal_damage_applied == 4 and game.state.last_attack.pools[0].normal_damage_applied == 2
		print("DEVASTATING WOUNDS HOST: ", "PASS" if passed else "FAIL")
		await create_timer(0.6).timeout
		quit(0 if passed else 1)
		return
	game._join()
	var passed: bool = await revision(game, 1)
	passed = passed and game.state.pending_attack.current.steps[0].kind == "normal"
	game.selected = 201
	game._refresh()
	game._request_allocate_damage()
	passed = await revision(game, 2) and passed
	passed = passed and game.state.pending_attack.current.steps[1].kind == "devastating" and game.state.units[201].wounds == 0 and not game.state.squads[1].fought
	game.selected = 202
	game._refresh()
	passed = passed and "Devastating Wounds" in game.allocate_button.text and "no save" in game.details.text and game.end_button.disabled
	var before := var_to_str(game.state)
	game.request_allocate_damage.rpc_id(1, 100, 2)
	game.request_allocate_damage.rpc_id(1, 202, 1)
	game.request_end.rpc_id(1, 2)
	await create_timer(0.2).timeout
	passed = passed and var_to_str(game.state) == before
	game._offline("Devastating Wounds reconnect fixture")
	await create_timer(0.7).timeout
	game._join()
	passed = await revision(game, 2) and passed
	passed = passed and game.state.pending_attack.current.cursor == 1 and game.state.pending_attack.current.result.devastating_wounds == 2
	game.selected = 202
	game._refresh()
	game._request_allocate_damage()
	passed = await revision(game, 3) and passed
	game.selected = 200
	game._refresh()
	game._request_allocate_damage()
	passed = await revision(game, 4) and passed
	passed = passed and game.state.pending_attack.is_empty() and not game.allocate_button.visible and "4 mortal damage" in game.event_log.text and game.state.last_attack.pools[0].allocations[1].kind == "devastating"
	print("DEVASTATING WOUNDS CLIENT: ", "PASS" if passed else "FAIL")
	await create_timer(0.3).timeout
	quit(0 if passed else 1)
