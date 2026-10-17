extends SceneTree
const F = preload("res://tests/awakened_fixture.gd")
const C = F.C
const R = C.Reanimation
var game
func _initialize() -> void: call_deferred("run")
func make_game() -> void:
	game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	game.auto_models.button_pressed = false
	game.reanimation_protocols_choice.button_pressed = true
	game.awakened_dynasty_choice.button_pressed = true
	var host: bool = "--host-test" in OS.get_cmdline_user_args()
	F.populate(game, 1 if host else 2)
	game.saved_training_consent.button_pressed = true
	game._start_saved_match(false)
func wait_for(predicate: Callable, label: String) -> bool:
	for attempt in range(180):
		if predicate.call(): return true
		await create_timer(0.05).timeout
	push_error("Reanimation network timeout: " + label + ": " + game.status.text)
	return false
func run() -> void:
	var host: bool = "--host-test" in OS.get_cmdline_user_args()
	make_game()
	if host:
		if "--restored-host" not in OS.get_cmdline_user_args():
			game._host()
			if not await wait_for(func(): return game.guest_id != 0 and game.state.phase == "deployment", "guest authentication and list admission"): quit(1); return
			assert(C.select_awakened_attachment(game.state, 2, 2, game.state.revision).is_empty())
			game.state.revision = 0
			F.combat(game.state)
			game.state.cp = {1: 0, 2: 0}
			for id in range(400, 410): game.state.units[id].position += Vector2(0, 10)
			game.state.units[600].wounds = 5
			# Select a seed whose first D3 can both heal and return a troop.
			var probe := RandomNumberGenerator.new()
			for seed_value in range(100):
				probe.seed = seed_value
				if probe.randi_range(1, 6) >= 3:
					game.rng.seed = seed_value
					break
			game.state.phase = "start_turn"
			game.state.active = 2
			game.state.turn = 2
			game.state.revision = 0
			game.state.terrain.areas = []
			game.state.units[201].wounds = 0
			assert(C.advance_phase(game.state, 2, 0).is_empty())
			assert(C.advance_phase(game.state, 2, 1, game._d6).is_empty())
			game._reset_history()
			game._broadcast()
			if not await wait_for(func(): return game.state.revision == 4, "rolled preview"): quit(1); return
			assert(game.state.units[201].wounds == 0 and game.state.units[600].wounds == 5 and R.pending(game.state).current.healed == {600: 1} and R.pending(game.state).current.placements.has(201))
			if not await wait_for(func(): return game.guest_id == 0, "disconnect"): quit(1); return
			game.multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()
			game.free()
			await create_timer(0.4).timeout
			var output: Array = []
			var args: Array[String] = ["--headless", "--path", ProjectSettings.globalize_path("res://"), "--script", "res://tests/test_attached_reanimation_network.gd", "--log-file", ProjectSettings.globalize_path("res://.tools/attached-reanimation-restored-host.log"), "--", "--host-test", "--restored-host"]
			var code := OS.execute(OS.get_executable_path(), args, output, true)
			for line in output: print(line)
			quit(code)
			return
		game._load_match(true)
		assert(game.mode == "host" and game.reanimation_protocols and game.state.revision == 4 and R.pending(game.state).current.placements.has(201))
		var predicted: Dictionary = game.state.duplicate(true)
		var rng := RandomNumberGenerator.new()
		rng.state = game.rng.state
		assert(C.resolve_reanimation(predicted, 2, "confirm", -1, -1, Vector2.ZERO, 4).is_empty())
		assert(C.resolve_reanimation(predicted, 2, "roll", 4, -1, Vector2.ZERO, 5, func() -> int: return rng.randi_range(1, 6)).is_empty())
		if not await wait_for(func(): return game.state.revision == 7, "confirmed after restart"): quit(1); return
		assert(game.state == predicted and game.rng.state == rng.state and game.state.phase == "movement" and game.state.units[201].wounds == 1 and game.state.units[600].wounds == 6)
		var dice_count := 0
		for entry: Dictionary in game.journal.entries: dice_count += entry.dice.size()
		assert(dice_count == 2 and game.state.cp == {1: 1, 2: 1})
		print("ATTACHED REANIMATION HOST: PASS")
		await create_timer(0.8).timeout
		quit()
		return
	game._join()
	if not await wait_for(func(): return game.state.revision == 2 and not R.pending(game.state).is_empty(), "Reanimation window"): quit(1); return
	game.request_reanimation.rpc_id(1, "roll", 1, -1, Vector2.ZERO, 2)
	game.request_reanimation.rpc_id(1, "roll", 2, -1, Vector2.ZERO, 1)
	await create_timer(0.15).timeout
	assert(game.state.revision == 2)
	game._request_reanimation("roll")
	if not await wait_for(func(): return game.state.revision == 3, "D3"): quit(1); return
	game._request_reanimation("suggest")
	if not await wait_for(func(): return game.state.revision == 4, "return preview"): quit(1); return
	assert(game.pieces[201].visible and game.state.units[201].wounds == 0)
	var preview: Dictionary = R.pending(game.state).duplicate(true)
	game._offline("Testing Reanimation after host restart")
	game.free()
	await create_timer(1.1).timeout
	make_game()
	game._join()
	if not await wait_for(func(): return game.state.revision == 4, "restored preview"): quit(1); return
	assert(R.pending(game.state) == preview and game.pieces[201].visible and game.state.units[201].wounds == 0)
	game.request_reanimation.rpc_id(1, "roll", 2, -1, Vector2.ZERO, 4)
	game.request_reanimation.rpc_id(1, "confirm", -1, -1, Vector2.ZERO, 3)
	await create_timer(0.15).timeout
	assert(game.state.revision == 4)
	game._request_reanimation("confirm")
	if not await wait_for(func(): return game.state.revision == 5, "confirmed return"): quit(1); return
	game._request_reanimation("roll")
	if not await wait_for(func(): return game.state.revision == 7, "Command complete"): quit(1); return
	assert(game.state.phase == "movement" and game.state.units[201].wounds == 1 and game.state.cp == {1: 1, 2: 1})
	print("ATTACHED REANIMATION CLIENT: PASS")
	quit()
