extends SceneTree
const F = preload("res://tests/fixtures/mixed_defenders.gd")
var dice: Array = [6, 6, 3, 6]
func roll() -> int: return dice.pop_front() if not dice.is_empty() else 0
func _initialize() -> void: call_deferred("run")
func revision(game: Node, wanted: int) -> bool:
	for attempt in range(100):
		if game.state.revision >= wanted: return game.state.revision == wanted
		await create_timer(0.1).timeout
	return false
func choose(game: Node, model: int, wanted: int) -> bool:
	game.selected = model
	game._refresh()
	game._request_allocate_damage()
	return await revision(game, wanted)
func run() -> void:
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	game.defender_choice.button_pressed = true
	game._start_objectives(2)
	if "--host-test" in OS.get_cmdline_user_args():
		game._host()
		game.state = game.TestBattlefield.apply(F.state(true, true, true, F.C.Terrain.DEFAULT_LAYOUT))
		if game.state.pack_hash != game._initial_state().pack_hash:
			push_error("Mixed-defense fixture must use the same battlefield identity as the joining client")
			quit(1)
			return
		game.state.units[202].wounds = 1
		game.state.units[202].defense.save_target = 7
		game.rng.seed = 42
		for attempt in range(100):
			if game.guest_id != 0: break
			await create_timer(0.1).timeout
		await create_timer(0.3).timeout
		var result: Dictionary = game.Combat.shoot(game.state, 1, 100, 200, 0, true, roll)
		var passed: bool = result.error.is_empty() and game.state.pending_attack.current.phase == "precision"
		game._broadcast()
		game.selected = 202
		game._refresh()
		passed = passed and game.precision_skip.visible and not game.allocate_button.disabled and game.Combat.actor(game.state) == 1
		await create_timer(0.6).timeout
		game._apply_allocate_damage(1, 202, 1)
		passed = await revision(game, 8) and passed
		passed = passed and game.state.pending_attack.is_empty() and game.state.units[202].wounds == 0 and game.state.units[200].wounds == 0 and game.state.last_attack.pools[0].precision_model == 202 and game.state.last_attack.pools[0].allocation_order.size() == 4
		print("MIXED DEFENDERS HOST: ", "PASS" if passed else "FAIL")
		await create_timer(0.5).timeout
		quit(0 if passed else 1)
		return
	game._join()
	var passed: bool = await revision(game, 1)
	game.selected = 202
	game._refresh()
	passed = passed and game.precision_skip.visible and game.precision_skip.disabled and game.allocate_button.disabled
	var before := var_to_str(game.state)
	game.request_allocate_damage.rpc_id(1, 202, 1)
	await create_timer(0.15).timeout
	passed = passed and before == var_to_str(game.state)
	passed = await revision(game, 2) and passed
	game.selected = 200
	game._refresh()
	passed = passed and "group next" in game.allocate_button.text and "Saves have not been rolled" in game.details.text
	passed = await choose(game, 200, 3) and passed
	game._offline("Allocation order reconnect fixture")
	await create_timer(0.7).timeout
	game._join()
	passed = await revision(game, 3) and passed
	passed = passed and game.state.pending_attack.current.order == [0] and game.state.pending_attack.current.result.save_rolls.is_empty()
	passed = await choose(game, 201, 4) and passed
	passed = await choose(game, 203, 5) and passed
	passed = await choose(game, 202, 6) and passed
	passed = passed and game.Combat.Allocation.eligible(game.state) == [202] and game.state.pending_attack.current.result.save_rolls.size() == 1
	passed = await choose(game, 202, 7) and passed
	passed = passed and game.Combat.Allocation.eligible(game.state) == [200]
	passed = await choose(game, 200, 8) and passed
	passed = passed and game.state.pending_attack.is_empty() and game.state.last_attack.pools[0].normal_damage_applied == 1 and game.state.last_attack.pools[0].mortal_damage_applied == 1
	print("MIXED DEFENDERS CLIENT: ", "PASS" if passed else "FAIL")
	await create_timer(0.3).timeout
	quit(0 if passed else 1)
