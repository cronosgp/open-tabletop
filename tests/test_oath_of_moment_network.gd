extends SceneTree
const P = preload("res://scripts/edition_11/prepared_training.gd")
const C = P.Combat
var game
func _initialize() -> void: call_deferred("run")
func make_game(host: bool) -> void:
	game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	game.auto_models.button_pressed = false
	game.hail_of_bolts_choice.button_pressed = true
	game.oath_of_moment_choice.button_pressed = true
	game.attack_reroll_choice.button_pressed = true
	game.defender_choice.button_pressed = false
	var reference := P.Training.Capabilities.reference_army("Necrons" if host else "Space Marines")
	var picker: OptionButton = game.saved_army_pickers[1 if host else 2]
	for index in range(picker.item_count):
		if picker.get_item_metadata(index).get("id", "") == reference.list.id: picker.select(index)
	game.saved_training_consent.button_pressed = true
	game._start_saved_match(false)
func wait_for(predicate: Callable, label: String) -> bool:
	for attempt in range(180):
		if predicate.call(): return true
		await create_timer(0.05).timeout
	push_error("Oath/Hail network timeout: " + label + ": " + game.status.text)
	return false
func run() -> void:
	var host: bool = "--host-test" in OS.get_cmdline_user_args()
	make_game(host)
	if host:
		if "--restored-host" not in OS.get_cmdline_user_args():
			game._host()
			if not await wait_for(func(): return game.state.phase == "deployment", "accepted armies"): quit(1); return
			game.state.phase = "start_turn"
			game.state.active = 2
			game.state.turn = 2
			game.state.revision = 0
			game.state.terrain.areas = []
			game.state.cp = {1: 3, 2: 3}
			for id: int in game.state.units:
				if id not in [100, 200, 300, 400]: game.state.units[id].wounds = 0
				game.state.units[id].position = Vector2(-12 if game.state.units[id].owner == 2 else 3, -8 if id < 300 else 8)
			game.state.squads[2].moved_distance = 4.0
			assert(C.advance_phase(game.state, 2, 0).is_empty())
			game._reset_history()
			game._broadcast()
			if not await wait_for(func(): return game.state.revision == 2, "guest faction target"): quit(1); return
			assert(game.state.oath_of_moment.targets[2] == 1 and game.state.cp[2] == 4)
			game.state.phase = "shooting"
			var probe := RandomNumberGenerator.new()
			for candidate in range(1, 10000):
				probe.seed = candidate
				var values := [probe.randi_range(1, 6), probe.randi_range(1, 6), probe.randi_range(1, 6), probe.randi_range(1, 6), probe.randi_range(1, 6)]
				if values[0] == 1 and values[1] >= 3 and values[2] >= 3 and values[3] >= 3 and values[4] >= 3:
					game.rng.seed = candidate
					break
			game._reset_history()
			game._broadcast()
			if not await wait_for(func(): return game.state.revision == 3, "expanded hit pool"): quit(1); return
			assert(game.state.pending_attack.prepared.hail_of_bolts.target == 1 and game.state.pending_attack.current.checkpoint.generated.count == 4)
			assert(game.state.pending_attack.current.checkpoint.rerolled_hits == [0] and C.Stratagems.pending(game.state).eligible == [1, 2, 3])
			if not await wait_for(func(): return game.guest_id == 0, "guest disconnect"): quit(1); return
			game.multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()
			game.free()
			await create_timer(0.4).timeout
			var output: Array = []
			var args: Array[String] = ["--headless", "--path", ProjectSettings.globalize_path("res://"), "--script", "res://tests/test_oath_of_moment_network.gd", "--log-file", ProjectSettings.globalize_path("res://.tools/oath-restored-host.log"), "--", "--host-test", "--restored-host"]
			var code := OS.execute(OS.get_executable_path(), args, output, true)
			for line in output: print(line)
			quit(code)
			return
		game._load_match(true)
		assert(game.mode == "host" and game.oath_of_moment and game.hail_of_bolts and game.state.revision == 3)
		var predicted: Dictionary = game.state.duplicate(true)
		var rng := RandomNumberGenerator.new()
		rng.state = game.rng.state
		var continuation: Array[int] = []
		assert(C.resolve_attack_reaction(predicted, 2, 2, "command-re-roll", 3, 1, func() -> int:
			var value := rng.randi_range(1, 6)
			continuation.append(value)
			return value).is_empty())
		if not await wait_for(func(): return game.state.revision == 4, "command reroll after restart"): quit(1); return
		assert(game.state == predicted and game.rng.state == rng.state and game.state.cp[2] == 3)
		assert(game.state.last_attack.hail_of_bolts.target == 1 and game.state.last_attack.pools[0].wound_modifier == 1)
		var dice_count := 0
		for entry: Dictionary in game.journal.entries: dice_count += entry.dice.size()
		assert(dice_count == 5 + continuation.size())
		print("OATH/HAIL HOST: PASS")
		await create_timer(0.8).timeout
		quit()
		return
	game._join()
	if not await wait_for(func(): return game.state.phase == "command" and game.state.active == 2, "faction selection"): quit(1); return
	game.request_oath_target.rpc_id(1, 2, 1)
	game.request_oath_target.rpc_id(1, 1, 0)
	await create_timer(0.15).timeout
	assert(game.state.revision == 1)
	game._request_oath_target()
	if not await wait_for(func(): return game.state.phase == "shooting", "selected target"): quit(1); return
	game.selected = 200
	game._begin_attack_plan()
	var index: int = game.plan_hail.get_item_index(1)
	game.plan_hail.select(index)
	game.plan_hail.item_selected.emit(index)
	game._assign_attack()
	game._confirm_attack_plan()
	if not await wait_for(func(): return game.state.revision == 3, "hit window"): quit(1); return
	assert(game.state.pending_attack.prepared.hail_of_bolts.target == 1 and C.Stratagems.pending(game.state).eligible == [1, 2, 3])
	game._offline("Testing Oath/Hail checkpoint after host restart")
	game.free()
	await create_timer(1.1).timeout
	make_game(false)
	game._join()
	if not await wait_for(func(): return game.state.revision == 3, "restored attack"): quit(1); return
	game.request_command_reaction.rpc_id(1, 2, "command-re-roll", 3, 0)
	game.request_attack_plan.rpc_id(1, 200, [{"model": 200, "target": 1, "amount": 1}], 3, false, true, 3)
	await create_timer(0.15).timeout
	assert(game.state.revision == 3 and game.state.cp[2] == 4)
	game.request_command_reaction.rpc_id(1, 2, "command-re-roll", 3, 1)
	if not await wait_for(func(): return game.state.revision == 4, "completed attack"): quit(1); return
	assert(game.state.last_attack.hail_of_bolts.target == 1 and game.state.oath_of_moment.targets[2] == 1)
	print("OATH/HAIL CLIENT: PASS")
	quit()
