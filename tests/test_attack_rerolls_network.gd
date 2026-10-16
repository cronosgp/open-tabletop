extends SceneTree
const C = preload("res://scripts/edition_11/combat_scenario.gd")
const S = C.Stratagems
var game
var counting := false
var hazarding := false
var damaging := false
var saving := false
var wound := false
func _initialize() -> void: call_deferred("run")
func make_game() -> void:
	game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	game.attack_reroll_choice.button_pressed = not (saving or damaging or hazarding or counting)
	game.damage_reroll_choice.button_pressed = damaging
	game.hazard_reroll_choice.button_pressed = hazarding
	game.count_reroll_choice.button_pressed = counting
	game.save_reroll_choice.button_pressed = saving
	game.defender_choice.button_pressed = false
	game._start_prepared_match()
func wait_for(predicate: Callable, label: String) -> bool:
	for attempt in range(150):
		if predicate.call(): return true
		await create_timer(0.1).timeout
	push_error("Attack reroll network timeout: " + label + ": " + game.status.text)
	return false
func run() -> void:
	counting = "--count-test" in OS.get_cmdline_user_args()
	hazarding = "--hazard-test" in OS.get_cmdline_user_args()
	damaging = "--damage-test" in OS.get_cmdline_user_args()
	saving = "--save-test" in OS.get_cmdline_user_args()
	wound = "--wound-test" in OS.get_cmdline_user_args()
	var host: bool = "--host-test" in OS.get_cmdline_user_args()
	var target_revision := 2 if wound else 1
	make_game()
	if host:
		if "--restored-host" not in OS.get_cmdline_user_args():
			game._host()
			game.state.phase = "shooting"
			game.state.active = 1 if saving else 2
			game.state.turn = 2
			game.state.cp = {1: 4, 2: 4}
			for id: int in game.state.units:
				if id not in [100, 200, 300, 400]: game.state.units[id].wounds = 0
				game.state.units[id].position = Vector2(-12 if game.state.units[id].owner == (1 if saving else 2) else -2, -8 if id < 300 else 8)
			game.state.squads[1 if saving else 2].weapon = {"name": "Network checkpoint", "attacks": "2D3+1" if counting else 2, "skill": 2, "strength": 10, "ap": -6 if damaging else 0, "damage": "2D3+1" if damaging else 1, "range_inches": 30, "keywords": {"hazardous": true} if hazarding else {}}
			var probe := RandomNumberGenerator.new()
			for candidate in range(1, 1000):
				probe.seed = candidate
				if probe.randi_range(1, 6) >= 5 and probe.randi_range(1, 6) >= 5 and (not (saving or damaging or hazarding or counting) or (probe.randi_range(1, 6) >= 5 and probe.randi_range(1, 6) >= 5)):
					game.rng.seed = candidate
					break
			game._reset_history()
			if saving:
				if not await wait_for(func(): return game.guest_id != 0, "guest authenticated"): quit(1); return
				game._apply_attack(1, 100, 200, 0, true)
			if not await wait_for(func(): return game.state.revision == target_revision, "pending checkpoint"): quit(1); return
			if not await wait_for(func(): return game.guest_id == 0, "disconnect"): quit(1); return
			game.multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()
			game.free()
			await create_timer(0.4).timeout
			var output: Array = []
			var args: Array[String] = ["--headless", "--path", ProjectSettings.globalize_path("res://"), "--script", "res://tests/test_attack_rerolls_network.gd", "--log-file", ProjectSettings.globalize_path("res://.tools/attack-restored-host.log"), "--", "--host-test", "--restored-host"]
			if wound: args.append("--wound-test")
			if saving: args.append("--save-test")
			if damaging: args.append("--damage-test")
			if hazarding: args.append("--hazard-test")
			if counting: args.append("--count-test")
			var code := OS.execute(OS.get_executable_path(), args, output, true)
			for line in output: print(line)
			quit(code)
			return
		game._load_match(true)
		assert(game.mode == "host" and (game.count_rerolls if counting else (game.hazard_rerolls if hazarding else (game.damage_rerolls if damaging else (game.save_rerolls if saving else game.attack_rerolls)))) and game.state.revision == target_revision)
		var prediction: Dictionary = game.state.duplicate(true)
		var expected_rng := RandomNumberGenerator.new()
		expected_rng.state = game.rng.state
		var command: Callable = C.resolve_hazard_reaction if hazarding else C.resolve_attack_reaction
		assert(command.call(prediction, 2, 2, "command-re-roll", target_revision, 0, func(): return expected_rng.randi_range(1, 6)).is_empty())
		if not await wait_for(func(): return game.state.revision == target_revision + 1, "re-roll after restart"): quit(1); return
		assert(game.state == prediction and game.rng.state == expected_rng.state)
		assert(game.state.cp[2] == 3 and game.state.stratagems.uses.size() == 1 and S.pending(game.state).is_empty())
		print("ATTACK REROLLS HOST: PASS")
		await create_timer(0.8).timeout
		quit()
		return
	game._join()
	if not await wait_for(func(): return game.state.active == (1 if saving else 2) and game.state.phase == "shooting", "fixture"): quit(1); return
	if saving:
		# Only the host owns the attacker; guest waits for its defensive choice.
		pass
	else: game.request_attack.rpc_id(1, 200, 100, 0, true)
	if not await wait_for(func(): return game.state.revision == 1, "hit window"): quit(1); return
	if wound:
		game._request_command_reaction("")
		if not await wait_for(func(): return game.state.revision == 2, "wound window"): quit(1); return
	assert(S.pending(game.state).kind == ("after_attack_count_roll" if counting else ("after_hazardous_roll" if hazarding else ("after_damage_roll" if damaging else ("after_save_roll" if saving else ("after_wound_roll" if wound else "after_hit_roll"))))))
	var original: Array = S.pending(game.state).rolls.duplicate()
	game._offline("Testing attack checkpoint after host restart")
	game.free()
	await create_timer(1.1).timeout
	make_game()
	game._join()
	if not await wait_for(func(): return game.state.revision == target_revision, "restored checkpoint"): quit(1); return
	assert(S.pending(game.state).rolls == original and game.state.cp[2] == 4)
	game.request_command_reaction.rpc_id(1, 1, "command-re-roll", target_revision, 0)
	game.request_command_reaction.rpc_id(1, 2, "command-re-roll", target_revision - 1, 0)
	game.request_command_reaction.rpc_id(1, 2, "command-re-roll", target_revision, 99)
	await create_timer(0.15).timeout
	assert(game.state.revision == target_revision and game.state.cp[2] == 4)
	game._request_use_reaction()
	if not await wait_for(func(): return game.state.revision == target_revision + 1, "accepted"): quit(1); return
	game.request_command_reaction.rpc_id(1, 2, "command-re-roll", target_revision, 0)
	game.request_command_reaction.rpc_id(1, 2, "command-re-roll", target_revision + 1, 0)
	await create_timer(0.15).timeout
	assert(game.state.cp[2] == 3 and game.state.stratagems.uses.size() == 1)
	print("ATTACK REROLLS CLIENT: PASS")
	quit()
