extends SceneTree
const S = preload("res://scripts/edition_11/stratagems.gd")
var game
var advance := false
func _initialize() -> void: call_deferred("run")
func make_game() -> void:
	game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	game.reroll_choice.button_pressed = true
	game._start_prepared_match()
func wait_for(predicate: Callable, label: String) -> bool:
	for attempt in range(150):
		if predicate.call(): return true
		await create_timer(0.1).timeout
	push_error("Reroll network timeout: " + label + ": " + game.status.text)
	return false
func expected() -> Dictionary:
	var rng := RandomNumberGenerator.new()
	for seed_value in range(1, 1000):
		rng.seed = seed_value
		var rolls := [rng.randi_range(1, 6), rng.randi_range(1, 6), rng.randi_range(1, 6), rng.randi_range(1, 6)]
		if rolls[2] + rolls[3] < 4: continue
		rng.seed = seed_value
		for index in range(2 if advance else 4): rng.randi_range(1, 6)
		return {"seed": seed_value, "rolls": rolls, "state": rng.state}
	return {}
func run() -> void:
	advance = "--advance-test" in OS.get_cmdline_user_args()
	var host: bool = "--host-test" in OS.get_cmdline_user_args()
	var prediction := expected()
	make_game()
	if host:
		if "--restored-host" not in OS.get_cmdline_user_args():
			game._host()
			game.state.phase = "movement" if advance else "charge"
			game.state.turn = 2
			game.state.active = 2
			game.state.cp = {1: 4, 2: 4}
			for model in game.state.units:
				if model not in [100, 200, 300, 400]: game.state.units[model].wounds = 0
			for model in [100, 300]: game.state.units[model].position = Vector2(-3, -8 if model == 100 else 8)
			for model in [200, 400]: game.state.units[model].position = Vector2(-8, -8 if model == 200 else 8)
			game.rng.seed = prediction.seed
			game._reset_history()
			if not await wait_for(func(): return not S.pending(game.state).is_empty(), "original dice"): quit(1); return
			assert(game.state.revision == 1 and game.state.cp[2] == 4)
			if not await wait_for(func(): return game.guest_id == 0, "guest disconnect"): quit(1); return
			game.multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()
			game.free()
			await create_timer(0.4).timeout
			var output: Array = []
			var arguments: Array[String] = ["--headless", "--path", ProjectSettings.globalize_path("res://"), "--script", "res://tests/test_movement_rerolls_network.gd", "--log-file", ProjectSettings.globalize_path("res://.tools/reroll-restored-host.log"), "--", "--host-test", "--restored-host"]
			if advance: arguments.append("--advance-test")
			var code := OS.execute(OS.get_executable_path(), arguments, output, true)
			for line in output: print(line)
			quit(code)
			return
		game._load_match(true)
		assert(game.mode == "host" and game.movement_rerolls and game.state.revision == 1)
		assert(S.pending(game.state).rolls == prediction.rolls.slice(0, 1 if advance else 2))
		if not await wait_for(func(): return game.state.revision >= 3, "reroll and next action"): quit(1); return
		assert(game.state.cp == {1: 4, 2: 3} and game.state.stratagems.uses.size() == 1)
		assert(game.rng.state == prediction.state and S.pending(game.state).is_empty())
		assert(game.state.last_command_roll.rolls == prediction.rolls.slice(1, 2) if advance else game.state.last_command_roll.rolls == prediction.rolls.slice(2, 4))
		var count := 0
		for entry in game.journal.entries: count += entry.dice.size()
		assert(count == (2 if advance else 4))
		print("MOVEMENT REROLLS HOST: PASS")
		await create_timer(1.0).timeout
		quit()
		return
	game._join()
	if not await wait_for(func(): return game.state.active == 2 and game.state.phase == ("movement" if advance else "charge"), "initial fixture"): quit(1); return
	game.selected = 200
	if advance: game.request_begin_movement.rpc_id(1, 200, "advance", 0)
	else: game._request_charge_roll()
	if not await wait_for(func(): return game.state.revision == 1, "window opened"): quit(1); return
	var original: Array = S.pending(game.state).rolls.duplicate()
	game._offline("Testing pending dice after host restart")
	game.free()
	await create_timer(1.1).timeout
	make_game()
	game._join()
	if not await wait_for(func(): return game.state.revision == 1, "restored roll"): quit(1); return
	assert(S.pending(game.state).rolls == original and game.state.cp[2] == 4)
	game.request_command_reaction.rpc_id(1, 1, "command-re-roll", 1)
	game.request_command_reaction.rpc_id(1, 2, "command-re-roll", 0)
	await create_timer(0.2).timeout
	assert(game.state.revision == 1 and game.state.cp[2] == 4)
	game._request_use_reaction()
	if not await wait_for(func(): return game.state.revision == 2, "reroll accepted"): quit(1); return
	assert(game.state.cp[2] == 3)
	game.request_command_reaction.rpc_id(1, 2, "command-re-roll", 1)
	game.request_command_reaction.rpc_id(1, 2, "command-re-roll", 2)
	if advance: game.request_finish_movement.rpc_id(1, 2, false)
	else: game.request_charge.rpc_id(1, 100, 2)
	if not await wait_for(func(): return game.state.revision == 3, "continuation"): quit(1); return
	assert(game.state.cp[2] == 3 and game.state.stratagems.uses.size() == 1)
	game.request_command_reaction.rpc_id(1, 2, "command-re-roll", 3)
	await create_timer(0.2).timeout
	assert(game.state.revision == 3 and game.state.cp[2] == 3)
	print("MOVEMENT REROLLS CLIENT: PASS")
	await create_timer(0.3).timeout
	quit()
