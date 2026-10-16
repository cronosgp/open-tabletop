extends SceneTree

func _initialize() -> void:
	call_deferred("run")

func arrange(state: Dictionary) -> void:
	for id: int in state.units:
		var unit: Dictionary = state.units[id]
		if unit.owner == 1:
			unit.position = Vector2(-6 + (id - 100) * 1.5, -9)
		else:
			var index: int = id - 200
			unit.position = Vector2(-6 + (index % 5) * 1.5, -4.5 + floori(index / 5.0) * 1.5)
	state.phase = "charge"

func run() -> void:
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	game._toggle_combat("legacy-solid-v1")
	if not game.combat_enabled:
		push_error("Import starter data before this optional integration test.")
		quit(1)
		return
	var host: bool = "--host-test" in OS.get_cmdline_user_args()
	if host:
		game._host()
		arrange(game.state)
		game.rng.seed = 44
		for attempt in range(100):
			await create_timer(0.1).timeout
			if game.guest_id != 0: break
		if game.guest_id == 0:
			quit(1)
			return
		game._apply_charge_roll(1, 100, game.state.revision, false)
		# This fixture uses the optional validated straight-line assist; manual
		# target/placement RPCs are covered in test_contact_network.gd.
		var charge_result: Dictionary = game.Combat.charge(game.state, 1, 200, game.state.revision)
		if not charge_result.error.is_empty():
			push_error(charge_result.error)
		game._broadcast()
		if not game.state.squads[1].charged:
			push_error("Host charge failed unexpectedly")
			quit(1)
			return
		game._apply_end(1, game.state.revision)
		game._apply_end(1, game.state.revision)
		for attempt in range(60):
			await create_timer(0.1).timeout
			if game.state.fight_step == "attacks": break
		if game.state.revision != 5 or game.Combat.actor(game.state) != 1:
			push_error("Defender skipped charge priority or the pile-in decision")
			quit(1)
			return
		game._apply_fight(1, 100, 200, game.state.revision)
		for attempt in range(60):
			await create_timer(0.1).timeout
			if game.state.squads[2].fought: break
		await create_timer(0.6).timeout
		var passed: bool = game.state.revision == 7 and game.state.active == 1 and game.state.squads[2].fought and game.state.fight_step == "consolidate" and game.Combat.living(game.state, 2).size() == 7
		print("MELEE NETWORK HOST: ", "PASS" if passed else "FAIL", " revision=", game.state.revision)
		quit(0 if passed else 1)
		return
	game._join()
	for attempt in range(100):
		await create_timer(0.1).timeout
		if game.state.revision == 4: break
	if game.state.revision != 4 or game.Combat.actor(game.state) != 2 or not game.state.squads[1].charged or game.end_button.disabled:
		push_error("Defender has no actionable pile-in window")
		quit(1)
		return
	game.request_fight.rpc_id(1, 200, 100, game.state.revision)
	game.request_end.rpc_id(1, game.state.revision)
	for attempt in range(60):
		await create_timer(0.1).timeout
		if game.state.revision == 6: break
	if game.state.revision != 6 or game.Combat.actor(game.state) != 2 or game.state.active != 1:
		push_error("Defender did not receive its out-of-turn melee window")
		quit(1)
		return
	var revision: int = game.state.revision
	var attacker: int = game.Combat.living(game.state, 2)[0]
	game.request_fight.rpc_id(1, 100, attacker, revision)
	game.request_fight.rpc_id(1, attacker, 100, revision)
	for attempt in range(40):
		await create_timer(0.1).timeout
		if game.state.squads[2].fought: break
	game.request_fight.rpc_id(1, attacker, 100, revision)
	game.request_end.rpc_id(1, revision)
	await create_timer(0.25).timeout
	game._refresh()
	var passed: bool = game.state.revision == 7 and game.state.squads[2].fought and game.state.fight_step == "consolidate" and not game.pieces[200].visible and game.end_button.disabled
	print("MELEE NETWORK CLIENT: ", "PASS" if passed else "FAIL", " revision=", game.state.revision)
	await create_timer(0.8).timeout
	quit(0 if passed else 1)
