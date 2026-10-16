extends SceneTree
func _initialize() -> void: call_deferred("run")
func at_revision(game: Node, revision: int) -> bool:
	for attempt in range(100):
		if game.state.revision >= revision: return game.state.revision == revision
		await create_timer(0.1).timeout
	push_error("Terrain network timeout at %d: %s" % [revision, game.status.text])
	return false

func run() -> void:
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	game._toggle_combat()
	if not game.combat_enabled:
		quit(1)
		return
	var host: bool = "--host-test" in OS.get_cmdline_user_args()
	if host:
		game._host()
		game.state.active = 2
		game.state.phase = "movement"
		for id: int in game.state.units:
			if id not in [100, 200]: game.state.units[id].wounds = 0
		game.state.units[100].position = Vector2(2, 0)
		game.state.units[200].position = Vector2(-5, 1)
		game.rng.seed = 42
		for attempt in range(100):
			if game.guest_id != 0: break
			await create_timer(0.1).timeout
		if game.guest_id == 0 or not await at_revision(game, 4):
			quit(1)
			return
		await create_timer(0.5).timeout
		var passed: bool = game.state.revision == 4 and game.state.terrain.id == game.Combat.Terrain.DEFAULT_LAYOUT and game.state.units[200].position == Vector2(-1.5, 1) and game.state.squads[2].shot and game.state.last_attack.pools[0].benefit_of_cover and game.state.squads[2].last_ranged_turn == game.state.turn
		print("TERRAIN NETWORK HOST: ", "PASS" if passed else "FAIL")
		quit(0 if passed else 1)
		return
	game._join()
	for attempt in range(100):
		if game.state.active == 2: break
		await create_timer(0.1).timeout
	if game.state.active != 2:
		quit(1)
		return
	game.selected = 200
	game._refresh()
	var passed: bool = game.terrain_root.get_child_count() > 3 and game.state.terrain.id == game.Combat.Terrain.DEFAULT_LAYOUT
	game.guides.preview(game.state, 200, true, 2, Vector2(-1.5, 1))
	passed = passed and game.guides.hover_valid
	game.request_move.rpc_id(1, 200, Vector2(-1.5, 1), 0)
	passed = await at_revision(game, 1) and passed
	game._request_finish_movement(false)
	passed = await at_revision(game, 2) and passed
	game.request_end.rpc_id(1, 2)
	passed = await at_revision(game, 3) and passed
	game.guides.preview(game.state, 200, true, 2, game.state.units[100].position)
	passed = passed and game.guides.hover_valid and "cover" in game.guides.hover_caption
	game.request_attack.rpc_id(1, 200, 100, 3, true)
	passed = await at_revision(game, 4) and passed
	game.request_attack.rpc_id(1, 200, 100, 3, true) # Stale repeat.
	await create_timer(0.2).timeout
	var pool: Dictionary = game.state.last_attack.pools[0]
	passed = passed and game.state.revision == 4 and pool.benefit_of_cover and pool.effective_skill == mini(6, int(game.state.squads[2].weapon.skill) + 1) and not game.Combat.Terrain.hidden(game.state, 200) and "BS worsened" in game.event_log.text
	print("TERRAIN NETWORK CLIENT: ", "PASS" if passed else "FAIL")
	await create_timer(0.8).timeout
	quit(0 if passed else 1)
