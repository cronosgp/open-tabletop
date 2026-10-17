extends SceneTree
const F = preload("res://tests/awakened_fixture.gd")
const C = F.C
const A = F.A
var game
func _initialize() -> void: call_deferred("run")
func make_game(host: bool) -> void:
	game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	game.auto_models.button_pressed = false
	game.awakened_dynasty_choice.button_pressed = true
	game.stratagem_choice.button_pressed = true
	game.attack_reroll_choice.button_pressed = true
	game.defender_choice.button_pressed = false
	F.populate(game, 1 if host else 2)
	game.saved_training_consent.button_pressed = true
	game._start_saved_match(false)
func wait_for(predicate: Callable, label: String) -> bool:
	for attempt in range(180):
		if predicate.call(): return true
		await create_timer(0.05).timeout
	push_error("Awakened network timeout: " + label + ": " + game.status.text)
	return false
func run() -> void:
	var host: bool = "--host-test" in OS.get_cmdline_user_args()
	make_game(host)
	if host:
		if "--restored-host" not in OS.get_cmdline_user_args():
			game._host()
			if not await wait_for(func(): return A.needs_setup(game.state), "attachment declaration"): quit(1); return
			var identity: String = game.state.pack_hash
			if not await wait_for(func(): return game.state.revision == 1, "guest assignment"): quit(1); return
			assert(game.state.pack_hash == identity and game.state.units[600].squad == 4 and A.hit_bonus(game.state, 4) == 1)
			F.combat(game.state)
			for id: int in game.state.units:
				if id not in [100, 400, 600]: game.state.units[id].wounds = 0
			game.rng.seed = 522
			game._reset_history()
			game._broadcast()
			if not await wait_for(func(): return game.state.revision == 2, "frozen hit checkpoint"): quit(1); return
			assert(game.state.pending_attack.current.checkpoint.hit_modifier == 1 and game.state.pending_attack.prepared.batches[0].context.hit_modifier == 1)
			if not await wait_for(func(): return game.guest_id == 0, "disconnect"): quit(1); return
			game.multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()
			game.free()
			await create_timer(0.4).timeout
			var output: Array = []
			var args: Array[String] = ["--headless", "--path", ProjectSettings.globalize_path("res://"), "--script", "res://tests/test_awakened_dynasty_network.gd", "--log-file", ProjectSettings.globalize_path("res://.tools/awakened-restored-host.log"), "--", "--host-test", "--restored-host"]
			var code := OS.execute(OS.get_executable_path(), args, output, true)
			for line in output: print(line)
			quit(code)
			return
		game._load_match(true)
		assert(game.mode == "host" and game.awakened_dynasty and game.state.revision == 2 and game.state.units[600].squad == 4 and game.state.pending_attack.current.checkpoint.hit_modifier == 1)
		var predicted: Dictionary = game.state.duplicate(true)
		var rng := RandomNumberGenerator.new()
		rng.state = game.rng.state
		assert(C.resolve_attack_reaction(predicted, 2, 4, "command-re-roll", 2, 0, func() -> int: return rng.randi_range(1, 6)).is_empty())
		if not await wait_for(func(): return game.state.revision == 3, "restored attack"): quit(1); return
		assert(game.state == predicted and game.rng.state == rng.state and game.state.cp[2] == 2 and game.state.last_attack.pools[0].hit_modifier == 1)
		assert(game.state.awakened_dynasty.attachments == [{"owner": 2, "leader": 6, "bodyguard": 4}])
		print("11E AWAKENED HOST: PASS")
		await create_timer(0.8).timeout
		quit()
		return
	game._join()
	if not await wait_for(func(): return A.needs_setup(game.state), "Overlord selection"): quit(1); return
	game.request_awakened_attachment.rpc_id(1, 1, 0)
	game.request_awakened_attachment.rpc_id(1, 4, -1)
	await create_timer(0.15).timeout
	assert(game.state.revision == 0 and A.needs_setup(game.state))
	game.awakened_target.select(game.awakened_target.get_item_index(4))
	game._request_awakened_attachment()
	if not await wait_for(func(): return game.state.phase == "shooting" and game.state.revision == 1, "prepared combat"): quit(1); return
	game.selected = 400
	game._begin_attack_plan()
	game._assign_attack()
	game._confirm_attack_plan()
	if not await wait_for(func(): return game.state.revision == 2, "hit decision"): quit(1); return
	assert(game.state.pending_attack.current.checkpoint.hit_modifier == 1 and game.state.units[600].squad == 4)
	game._offline("Testing led hit modifier after host restart")
	game.free()
	await create_timer(1.1).timeout
	make_game(false)
	game._join()
	if not await wait_for(func(): return game.state.revision == 2, "restored checkpoint"): quit(1); return
	assert(game.state.pending_attack.current.checkpoint.hit_modifier == 1 and A.hit_bonus(game.state, 4) == 1)
	game.request_awakened_attachment.rpc_id(1, -1, 2)
	game.request_command_reaction.rpc_id(1, 4, "command-re-roll", 1, 0)
	await create_timer(0.15).timeout
	assert(game.state.revision == 2 and game.state.cp[2] == 3)
	game.request_command_reaction.rpc_id(1, 4, "command-re-roll", 2, 0)
	if not await wait_for(func(): return game.state.revision == 3, "completed attack"): quit(1); return
	assert(game.state.cp[2] == 2 and game.state.last_attack.pools[0].hit_modifier == 1)
	print("11E AWAKENED CLIENT: PASS")
	quit()
