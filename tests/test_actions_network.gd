extends SceneTree
func _initialize() -> void: call_deferred("run")
func revision(game: Node, wanted: int) -> bool:
	for attempt in range(100):
		if game.state.revision >= wanted: return game.state.revision == wanted
		await create_timer(0.1).timeout
	push_error("Action timeout: " + game.status.text)
	return false
func run() -> void:
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	game._start_objectives()
	var host: bool = "--host-test" in OS.get_cmdline_user_args()
	if host:
		game._host()
		game.state.active = 2
		game.state.phase = "shooting"
		for id: int in game.state.units:
			if id not in [100, 200]: game.state.units[id].wounds = 0
		game.state.units[200].position = Vector2(2, 0)
		game.Combat.Objectives.resolve_control(game.state)
		for attempt in range(100):
			if game.guest_id != 0: break
			await create_timer(0.1).timeout
		var passed: bool = game.guest_id != 0 and await revision(game, 5)
		await create_timer(0.4).timeout
		passed = passed and game.state.squads[2].last_action.status == "completed" and game.state.mission.objectives[0].secured == 2 and game.state.mission.scores[2] == 1
		print("ACTIONS NETWORK HOST: ", "PASS" if passed else "FAIL")
		quit(0 if passed else 1)
		return
	game._join()
	for attempt in range(100):
		if game.state.active == 2: break
		await create_timer(0.1).timeout
	game.selected = 200
	game._refresh()
	var passed: bool = game.action_button.visible and not game.action_button.disabled and game.action_objective.get_selected_id() == 0
	game._request_action()
	passed = await revision(game, 1) and passed
	passed = passed and not game.state.squads[2].action.is_empty() and game.action_button.disabled and "in progress" in game.details.text
	var before := var_to_str(game.state)
	game.request_action.rpc_id(1, 200, 0, 0)
	game.request_attack.rpc_id(1, 200, 100, 1, true)
	await create_timer(0.2).timeout
	passed = passed and var_to_str(game.state) == before
	game.guides.preview(game.state, 200, true, 2, game.state.units[100].position)
	passed = passed and not game.guides.hover_valid and "unavailable" in game.guides.hover_caption
	game.request_end.rpc_id(1, 1)
	passed = await revision(game, 2) and passed
	passed = passed and game.charge_button.disabled
	game.request_charge_roll.rpc_id(1, 200, 2, false)
	await create_timer(0.2).timeout
	passed = passed and game.state.revision == 2 and not game.state.squads[2].charge_declared
	for expected in [3, 4, 5]:
		game.request_end.rpc_id(1, expected - 1)
		passed = await revision(game, expected) and passed
		if expected == 4: passed = passed and game.state.mission.objectives[0].secured == 2 and game.state.squads[2].last_action.status == "completed"
	passed = passed and game.state.squads[2].action.is_empty() and not game.Combat.Actions.charge_blocked(game.state, 2) and "completed Secure Ground" in game.event_log.text
	print("ACTIONS NETWORK CLIENT: ", "PASS" if passed else "FAIL")
	await create_timer(0.8).timeout
	quit(0 if passed else 1)
