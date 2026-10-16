extends SceneTree
func _initialize() -> void: call_deferred("run")
func revision(game: Node, wanted: int) -> bool:
	for attempt in range(100):
		if game.state.revision >= wanted: return game.state.revision == wanted
		await create_timer(0.1).timeout
	push_error("Multi-unit timeout: " + game.status.text)
	return false
func run() -> void:
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	game._start_objectives(2)
	var host: bool = "--host-test" in OS.get_cmdline_user_args()
	if host:
		game._host()
		game.state.active = 2
		game.state.phase = "fight"
		game.state.fight_step = "consolidate"
		game.state.fight_actor = 2
		for id: int in game.state.units:
			if id not in [100, 200, 300, 400]: game.state.units[id].wounds = 0
		game.state.units[400].position = Vector2(-8, -8)
		game.state.units[100].position = Vector2(-4, -8)
		game.state.units[300].position = Vector2(-4, -6.7)
		game.state.units[200].position = Vector2(10, 8)
		game.state.squads[4].fought = true
		game.state.squads[4].fight_eligible = true
		game.state.squads[4].stats.wounds = 50
		game.state.units[400].wounds = 50
		game.state.units[400].max_wounds = 50
		game.rng.seed = 42
		for attempt in range(100):
			if game.guest_id != 0: break
			await create_timer(0.1).timeout
		var passed: bool = game.guest_id != 0 and await revision(game, 3)
		passed = passed and game.state.reaction_queue == [1, 3] and game.Combat.actor(game.state) == 1
		await create_timer(0.3).timeout
		game._apply_fight(1, 300, 400, 3)
		passed = passed and game.state.revision == 4 and game.state.reaction_queue == [1]
		await create_timer(0.3).timeout
		game._apply_fight(1, 100, 400, 4)
		passed = passed and game.state.revision == 5 and game.state.reaction_queue.is_empty() and game.state.fight_step == "consolidate"
		await create_timer(0.3).timeout
		game._apply_end(1, 5, 300)
		passed = passed and game.state.revision == 6 and game.Combat.actor(game.state) == 1
		game._apply_end(1, 6, 100)
		passed = passed and game.state.revision == 7 and game.state.fight_step == "complete"
		passed = await revision(game, 8) and passed
		await create_timer(0.4).timeout
		print("MULTI-UNIT NETWORK HOST: ", "PASS" if passed else "FAIL")
		quit(0 if passed else 1)
		return
	game._join()
	for attempt in range(100):
		if game.state.active == 2: break
		await create_timer(0.1).timeout
	var passed: bool = game.state.squads.size() == 4 and game.pieces.size() == 30 and game.state.squads[4].owner == 2
	game.selected = 400
	game._refresh()
	passed = passed and not game.begin_contact_button.disabled and "4:" in game.details.text
	game._request_begin_contact()
	passed = await revision(game, 1) and passed
	game.request_contact_move.rpc_id(1, 400, Vector2(-5.5, -7.4), 1)
	passed = await revision(game, 2) and passed
	game.request_finish_contact.rpc_id(1, 2, false)
	passed = await revision(game, 3) and passed
	passed = passed and game.state.reaction_queue == [1, 3] and "Mandatory reactions" in game.details.text
	game.request_fight.rpc_id(1, 200, 100, 3)
	game.request_begin_contact.rpc_id(1, 400, "consolidate", 2)
	passed = await revision(game, 7) and passed
	passed = passed and game.state.squads[1].fought and game.state.squads[3].fought and game.state.consolidate_done == [4, 3, 1]
	game.request_end.rpc_id(1, 7, 400)
	passed = await revision(game, 8) and passed
	passed = passed and game.state.phase == "end_turn" and game.state.pending_contact.is_empty()
	print("MULTI-UNIT NETWORK CLIENT: ", "PASS" if passed else "FAIL")
	await create_timer(0.8).timeout
	quit(0 if passed else 1)
