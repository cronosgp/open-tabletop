extends SceneTree
func _initialize() -> void: call_deferred("run")
func revision(game: Node, wanted: int) -> bool:
	for attempt in range(100):
		if game.state.revision >= wanted: return game.state.revision == wanted
		await create_timer(0.1).timeout
	push_error("Consolidation timeout: " + game.status.text)
	return false
func run() -> void:
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	game._start_objectives()
	var host: bool = "--host-test" in OS.get_cmdline_user_args()
	if host:
		game._host()
		game.state.active = 2
		game.state.phase = "fight"
		game.state.fight_step = "consolidate"
		game.state.fight_actor = 2
		game.state.squads[2].fight_eligible = true
		game.state.squads[2].fought = true
		for id: int in game.state.units:
			if id not in [100, 200]: game.state.units[id].wounds = 0
		game.state.units[200].position = Vector2(5, 0)
		for attempt in range(100):
			if game.guest_id != 0: break
			await create_timer(0.1).timeout
		var passed: bool = game.guest_id != 0 and await revision(game, 7)
		await create_timer(0.4).timeout
		passed = passed and game.state.mission.objectives[0].controller == 2 and game.state.units[200].position == Vector2(3.4, 0) and game.state.pending_contact.is_empty()
		print("OBJECTIVE CONSOLIDATION HOST: ", "PASS" if passed else "FAIL")
		quit(0 if passed else 1)
		return
	game._join()
	for attempt in range(100):
		if game.state.active == 2: break
		await create_timer(0.1).timeout
	game.selected = 200
	game._refresh()
	var passed: bool = game.consolidation_objective.visible and game.consolidation_objective.get_selected_id() == 0
	game._request_begin_contact()
	passed = await revision(game, 1) and passed
	passed = passed and game.state.pending_contact.kind == "consolidate_objective" and "Central ruin" in game.guides.caption
	game.request_contact_move.rpc_id(1, 200, Vector2(3.4, 0), 1)
	passed = await revision(game, 2) and passed
	game.request_finish_contact.rpc_id(1, 2, true)
	passed = await revision(game, 3) and passed
	passed = passed and game.state.units[200].position == Vector2(5, 0)
	game._request_begin_contact()
	passed = await revision(game, 4) and passed
	game.request_contact_move.rpc_id(1, 200, Vector2(3.4, 0), 4)
	passed = await revision(game, 5) and passed
	game.request_finish_contact.rpc_id(1, 5, false)
	passed = await revision(game, 6) and passed
	game.request_end.rpc_id(1, 6)
	passed = await revision(game, 7) and passed
	game.request_begin_contact.rpc_id(1, 200, "consolidate", 5, 0)
	await create_timer(0.2).timeout
	passed = passed and game.state.revision == 7 and game.state.mission.objectives[0].controller == 2 and "Central ruin: P2" in game.details.text
	print("OBJECTIVE CONSOLIDATION CLIENT: ", "PASS" if passed else "FAIL")
	await create_timer(0.8).timeout
	quit(0 if passed else 1)
