extends SceneTree
func _initialize() -> void: call_deferred("run")

func at_revision(game: Node, revision: int) -> bool:
	for attempt in range(100):
		if game.state.revision >= revision: return game.state.revision == revision
		await create_timer(0.1).timeout
	return false

func run() -> void:
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	game._toggle_combat("legacy-solid-v1")
	if not game.combat_enabled:
		quit(1)
		return
	var host: bool = "--host-test" in OS.get_cmdline_user_args()
	if host:
		game._host()
		game.state.active = 2
		game.state.phase = "charge"
		for id: int in game.state.units:
			if id not in [100, 200]: game.state.units[id].wounds = 0
		game.state.units[200].position = Vector2(-5, 0)
		game.state.units[100].position = Vector2(5, 0)
		for candidate in range(1000):
			game.rng.seed = candidate
			if game._d6() + game._d6() == 10:
				game.rng.seed = candidate
				break
		for attempt in range(100):
			if game.guest_id != 0: break
			await create_timer(0.1).timeout
		if game.guest_id == 0 or not await at_revision(game, 6):
			quit(1)
			return
		await create_timer(0.5).timeout
		var passed: bool = game.state.revision == 6 and game.state.squads[2].charged and game.state.last_contact_proofs.size() == 1 and game.state.last_contact_proofs[0].reason == "terrain_route" and game.state.last_contact_proofs[0].lower_bound > 10.0
		print("CONTACT EXCEPTIONS NETWORK HOST: ", "PASS" if passed else "FAIL")
		quit(0 if passed else 1)
		return
	game._join()
	for attempt in range(100):
		if game.state.active == 2 and game.state.phase == "charge": break
		await create_timer(0.1).timeout
	if game.state.active != 2:
		quit(1)
		return
	game.selected = 200
	game._request_charge_roll()
	var passed: bool = await at_revision(game, 1)
	passed = passed and game.state.pending_charge.maximum == 10
	game.request_charge.rpc_id(1, 100, 1)
	passed = await at_revision(game, 2) and passed
	game._request_begin_contact()
	passed = await at_revision(game, 3) and passed
	game.request_contact_move.rpc_id(1, 200, Vector2(-3.64, 2.64), 3)
	passed = await at_revision(game, 4) and passed
	game.request_contact_move.rpc_id(1, 200, Vector2(3.3, 2.64), 4)
	passed = await at_revision(game, 5) and passed
	game._request_finish_contact(false)
	passed = await at_revision(game, 6) and passed
	game.request_finish_contact.rpc_id(1, 5, false)
	await create_timer(0.2).timeout
	passed = passed and game.state.revision == 6 and game.state.squads[2].charged and game.state.last_contact_proofs[0].model == 200 and game.state.last_contact_proofs[0].gap == 1.0 and "exception proved" in game.event_log.text
	print("CONTACT EXCEPTIONS NETWORK CLIENT: ", "PASS" if passed else "FAIL")
	await create_timer(0.8).timeout
	quit(0 if passed else 1)
