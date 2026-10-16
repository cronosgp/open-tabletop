extends SceneTree
func _initialize() -> void: call_deferred("run")

func at_revision(game: Node, revision: int) -> bool:
	for attempt in range(100):
		if game.state.revision >= revision: return game.state.revision == revision
		await create_timer(0.1).timeout
	push_error("Contact network timeout at %d: %s" % [revision, game.status.text])
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
		game.state.units[100].position = Vector2(-3, -8)
		game.state.units[200].position = Vector2(-8, -8)
		for candidate in range(100):
			game.rng.seed = candidate
			if game._d6() + game._d6() >= 6:
				game.rng.seed = candidate
				break
		for attempt in range(100):
			if game.guest_id != 0: break
			await create_timer(0.1).timeout
		if game.guest_id == 0 or not await at_revision(game, 9):
			quit(1)
			return
		var passed: bool = game.state.squads[2].charged and game.state.pending_contact.is_empty()
		game._apply_end(2, 9)
		passed = await at_revision(game, 13) and passed
		passed = passed and game.Combat.actor(game.state) == 1
		# Fixture profiles each roll one attack; choose host dice so both miss.
		for squad in [1, 2]:
			game.state.squads[squad].melee_weapon.attacks = 1
			game.state.squads[squad].melee_weapon.skill = 6
		for candidate in range(100):
			game.rng.seed = candidate
			var first: int = game._d6()
			var second: int = game._d6()
			if first < 6 and second < 6:
				game.rng.seed = candidate
				break
		game._apply_end(1, 13)
		passed = await at_revision(game, 15) and passed
		game._apply_fight(1, 100, 200, 15)
		passed = await at_revision(game, 18) and passed
		passed = passed and game.state.fight_step == "consolidate" and game.Combat.actor(game.state) == 1
		game._apply_begin_contact(1, 100, "consolidate", 18)
		game._apply_finish_contact(1, 19, false)
		await create_timer(0.5).timeout
		passed = passed and game.state.revision == 20 and game.state.fight_step == "complete"
		print("CONTACT NETWORK HOST: ", "PASS" if passed else "FAIL")
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
	var maximum: int = game.state.pending_charge.maximum
	game.request_charge.rpc_id(1, 100, 1)
	passed = await at_revision(game, 2) and passed
	game._request_begin_contact()
	passed = await at_revision(game, 3) and passed
	passed = passed and game.confirm_contact_button.visible and game.end_button.disabled
	game.request_contact_move.rpc_id(1, 100, Vector2(-4, -8), 3) # Cannot move opponent.
	game.request_contact_move.rpc_id(1, 200, Vector2(-8, -6), 3)
	passed = await at_revision(game, 4) and passed
	game.request_contact_move.rpc_id(1, 200, Vector2(-4.4, -7.5), 4)
	passed = await at_revision(game, 5) and passed
	game._request_finish_contact(true)
	passed = await at_revision(game, 6) and passed
	passed = passed and game.state.units[200].position == Vector2(-8, -8) and game.state.pending_charge.maximum == maximum
	game._request_begin_contact()
	passed = await at_revision(game, 7) and passed
	game.request_contact_move.rpc_id(1, 200, Vector2(-4.4, -8), 7)
	passed = await at_revision(game, 8) and passed
	game._request_finish_contact(false)
	passed = await at_revision(game, 10) and passed
	game._request_begin_contact()
	passed = await at_revision(game, 11) and passed
	var radii: float = game.state.units[100].radius + game.state.units[200].radius
	game.request_contact_move.rpc_id(1, 200, Vector2(-3 - radii, -8), 11)
	passed = await at_revision(game, 12) and passed
	game._request_finish_contact(false)
	passed = await at_revision(game, 14) and passed
	game.request_fight.rpc_id(1, 200, 100, 14)
	passed = await at_revision(game, 16) and passed
	game._request_begin_contact()
	passed = await at_revision(game, 17) and passed
	game._request_finish_contact(false)
	passed = await at_revision(game, 20) and passed
	game.request_finish_contact.rpc_id(1, 17, false) # Stale confirmation.
	game.request_contact_move.rpc_id(1, 200, Vector2(-8, -8), 17)
	await create_timer(0.2).timeout
	passed = passed and game.state.revision == 20 and game.state.fight_step == "complete" and game.state.units[100].wounds == 2 and game.state.units[200].wounds == 1
	print("CONTACT NETWORK CLIENT: ", "PASS" if passed else "FAIL")
	await create_timer(0.8).timeout
	quit(0 if passed else 1)
