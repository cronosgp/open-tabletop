extends SceneTree

func _initialize() -> void:
	call_deferred("run")

func await_revision(game: Node, revision: int) -> bool:
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
		game.state.phase = "end_turn"
		for id in range(205, 210): game.state.units[id].wounds = 0
		game.state.units[204].position = Vector2(12, 9)
		game.state.squads[2].stats.leadership_target = 12
		game.rng.seed = 42
		for attempt in range(100):
			if game.guest_id != 0: break
			await create_timer(0.1).timeout
		if game.guest_id == 0:
			push_error("Guest did not connect: " + game.status.text)
			quit(1)
			return
		if not await await_revision(game, 1):
			quit(1)
			return
		# Turn ownership returns to player 1 after the guest's removal.
		await create_timer(0.4).timeout
		var passed: bool = game.state.units[204].wounds == 0 and game.Combat.living(game.state, 2).size() == 4 and game.Combat.actor(game.state) == 1 and game.state.revision == 1
		game._apply_end(1, game.state.revision)
		passed = await await_revision(game, 4) and passed
		await create_timer(0.5).timeout
		passed = passed and game.state.revision == 4 and game.state.phase == "movement" and game.state.squads[2].battle_shocked and game.state.last_morale.size() == 1
		print("MORALE NETWORK HOST: ", "PASS" if passed else "FAIL")
		quit(0 if passed else 1)
		return
	game._join()
	for attempt in range(100):
		if game.state.phase == "end_turn": break
		await create_timer(0.1).timeout
	if game.state.phase != "end_turn":
		push_error("Missing initial coherency snapshot: " + game.status.text)
		quit(1)
		return
	game.selected = 204
	game._refresh()
	var passed: bool = game.Combat.actor(game.state) == 2 and game.coherency_button.visible and not game.coherency_button.disabled and game.end_button.disabled
	game.request_coherency_removal.rpc_id(1, 100, 0) # Cannot remove opponent.
	game._request_coherency_removal()
	passed = await await_revision(game, 1) and passed
	game.request_coherency_removal.rpc_id(1, 203, 0) # Stale duplicate.
	passed = passed and not game.pieces[204].visible and game.state.units[203].wounds > 0
	passed = await await_revision(game, 2) and passed
	game.request_end.rpc_id(1, 2)
	passed = await await_revision(game, 3) and passed
	game.request_end.rpc_id(1, 3)
	passed = await await_revision(game, 4) and passed
	game.request_end.rpc_id(1, 3) # Must not reroll or advance twice.
	await create_timer(0.2).timeout
	game.selected = 200
	game._refresh()
	passed = passed and game.state.revision == 4 and game.state.squads[2].battle_shocked and game.Combat.Morale.objective_control(game.state, 200) == 0 and "Battle-shocked" in game.details.text and game.state.last_morale[0].rolls.size() == 2
	print("MORALE NETWORK CLIENT: ", "PASS" if passed else "FAIL")
	await create_timer(0.8).timeout
	quit(0 if passed else 1)
