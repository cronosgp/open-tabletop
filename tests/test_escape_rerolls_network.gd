extends SceneTree
const S = preload("res://scripts/edition_11/stratagems.gd")
var game
func _initialize() -> void: call_deferred("run")
func make_game() -> void:
	game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	game.auto_models.button_pressed = false
	game.escape_reroll_choice.button_pressed = true
	game._start_prepared_match()
func wait_for(predicate: Callable, label: String) -> bool:
	for attempt in range(150):
		if predicate.call(): return true
		await create_timer(0.1).timeout
	push_error("Escape network timeout: " + label + ": " + game.status.text)
	return false
func expected() -> Dictionary:
	var rng := RandomNumberGenerator.new()
	for seed_value in range(1, 10000):
		rng.seed = seed_value
		var rolls := [rng.randi_range(1, 6), rng.randi_range(1, 6), rng.randi_range(1, 6)]
		if rolls[0] <= 2 and rolls[1] >= 3 and rolls[2] >= 3: return {"seed": seed_value, "rolls": rolls, "state": rng.state}
	return {}
func run() -> void:
	var host: bool = "--host-test" in OS.get_cmdline_user_args()
	var prediction := expected()
	make_game()
	if host:
		if "--restored-host" not in OS.get_cmdline_user_args():
			game._host()
			game.state.phase = "movement"
			game.state.turn = 2
			game.state.active = 2
			game.state.cp = {1: 4, 2: 4}
			for model: int in game.state.units:
				if model not in [100, 200, 201, 300, 400]: game.state.units[model].wounds = 0
			game.state.units[200].position = Vector2(-10, -8)
			game.state.units[201].position = Vector2(-10, -6.5)
			game.state.units[100].position = Vector2(-8.5, -8)
			game.rng.seed = prediction.seed
			game._reset_history()
			if not await wait_for(func(): return not S.pending(game.state).is_empty(), "original hazards"): quit(1); return
			assert(game.state.revision == 1 and game.state.cp[2] == 4 and game.state.pending_move.hazard_remaining == 1)
			if not await wait_for(func(): return game.guest_id == 0, "guest disconnect"): quit(1); return
			game.multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()
			game.free()
			await create_timer(0.4).timeout
			var output: Array = []
			var arguments: Array[String] = ["--headless", "--path", ProjectSettings.globalize_path("res://"), "--script", "res://tests/test_escape_rerolls_network.gd", "--log-file", ProjectSettings.globalize_path("res://.tools/escape-restored-host.log"), "--", "--host-test", "--restored-host"]
			var code := OS.execute(OS.get_executable_path(), arguments, output, true)
			for line in output: print(line)
			quit(code)
			return
		game._load_match(true)
		assert(game.mode == "host" and game.escape_rerolls and game.state.revision == 1)
		assert(S.pending(game.state).kind == "after_escape_roll" and S.pending(game.state).rolls == prediction.rolls.slice(0, 2))
		if not await wait_for(func(): return game.state.revision >= 3, "reroll and placement reset"): quit(1); return
		assert(game.state.cp == {1: 4, 2: 3} and game.state.stratagems.uses.size() == 1)
		assert(game.rng.state == prediction.state and S.pending(game.state).is_empty())
		assert(game.state.pending_move.hazard_rolls == [prediction.rolls[2], prediction.rolls[1]] and game.state.pending_move.hazard_remaining == 0)
		assert(game.state.units[200].wounds == 1 and game.state.units[201].wounds == 1)
		var dice_count := 0
		for entry: Dictionary in game.journal.entries: dice_count += entry.dice.size()
		assert(dice_count == 3)
		print("ESCAPE REROLLS HOST: PASS")
		await create_timer(1.0).timeout
		quit()
		return
	game._join()
	if not await wait_for(func(): return game.state.active == 2 and game.state.phase == "movement", "initial fixture"): quit(1); return
	game.selected = 200
	game.request_begin_movement.rpc_id(1, 200, "desperate_escape", 0)
	if not await wait_for(func(): return game.state.revision == 1, "escape window"): quit(1); return
	var original: Array = S.pending(game.state).rolls.duplicate()
	game._offline("Testing escape pool after host restart")
	game.free()
	await create_timer(1.1).timeout
	make_game()
	game._join()
	if not await wait_for(func(): return game.state.revision == 1, "restored escape"): quit(1); return
	assert(S.pending(game.state).rolls == original and game.state.cp[2] == 4 and game.reaction_die.visible)
	game.request_command_reaction.rpc_id(1, 1, "command-re-roll", 1, 0)
	game.request_command_reaction.rpc_id(1, 2, "command-re-roll", 0, 0)
	game.request_command_reaction.rpc_id(1, 2, "command-re-roll", 1, 2)
	game.request_escape_wound.rpc_id(1, 200, 1)
	await create_timer(0.2).timeout
	assert(game.state.revision == 1 and game.state.cp[2] == 4)
	game.reaction_die.select(0)
	game._request_use_reaction()
	if not await wait_for(func(): return game.state.revision == 2, "reroll accepted"): quit(1); return
	assert(game.state.cp[2] == 3 and game.state.pending_move.hazard_remaining == 0)
	game.request_command_reaction.rpc_id(1, 2, "command-re-roll", 1, 0)
	game.request_command_reaction.rpc_id(1, 2, "command-re-roll", 2, 0)
	game.request_finish_movement.rpc_id(1, 2, true)
	if not await wait_for(func(): return game.state.revision == 3, "placement reset"): quit(1); return
	assert(game.state.cp[2] == 3 and game.state.stratagems.uses.size() == 1 and game.state.pending_move.hazard_rolls == [prediction.rolls[2], original[1]])
	game.request_command_reaction.rpc_id(1, 2, "command-re-roll", 3, 0)
	await create_timer(0.2).timeout
	assert(game.state.revision == 3 and game.state.cp[2] == 3)
	print("ESCAPE REROLLS CLIENT: PASS")
	quit()
