extends SceneTree
const S = preload("res://scripts/edition_11/stratagems.gd")
var game
func _initialize() -> void: call_deferred("run")
func make_game() -> void:
	game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	game.stratagem_choice.button_pressed = true
	game._start_prepared_match()
func wait_for(predicate: Callable, label: String) -> bool:
	for step in range(150):
		if predicate.call(): return true
		await create_timer(0.1).timeout
	push_error("Stratagem network timeout: " + label + ": " + game.status.text)
	return false
func run() -> void:
	make_game()
	var host: bool = "--host-test" in OS.get_cmdline_user_args()
	if host:
		game._host()
		game.state.phase = "command"
		game.state.turn = 2
		game.state.active = 2
		game.state.cp = {1: 2, 2: 2}
		for squad in [2, 4]:
			for model in game.Combat.living(game.state, squad).slice(4): game.state.units[model].wounds = 0
		game._reset_history()
		if not await wait_for(func(): return not S.pending(game.state).is_empty(), "pending window"): quit(1); return
		var random_state: int = game.rng.state
		assert(game.state.cp[2] == 2 and game.state.revision == 1)
		if not await wait_for(func(): return game.guest_id == 0, "guest disconnect"): quit(1); return
		game.multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()
		game.free()
		await create_timer(0.3).timeout
		make_game()
		game._load_match(true)
		assert(game.mode == "host" and game.state.revision == 1 and game.rng.state == random_state)
		assert(S.pending(game.state).remaining == [2, 4])
		if not await wait_for(func(): return game.state.phase == "movement", "resolved resumed window"): quit(1); return
		assert(game.state.cp == {1: 2, 2: 1} and game.state.stratagems.uses.size() == 1)
		assert(game.state.last_morale.size() == 2 and game.state.last_morale[0].automatic and game.state.last_morale[1].rolls.size() == 2)
		var dice := 0
		for entry in game.journal.entries: dice += entry.dice.size()
		assert(dice == 2)
		print("STRATAGEMS HOST: PASS")
		await create_timer(0.8).timeout
		quit()
		return
	game._join()
	if not await wait_for(func(): return game.state.phase == "command" and game.state.active == 2, "initial fixture"): quit(1); return
	game._request_end()
	if not await wait_for(func(): return game.state.revision == 1, "window opened"): quit(1); return
	assert(not game.reaction_use.disabled and game.end_button.disabled)
	game._offline("Testing pending-window resume")
	game.free()
	await create_timer(0.9).timeout
	make_game()
	game._join()
	if not await wait_for(func(): return game.state.revision == 1, "restored decision"): quit(1); return
	game.request_command_reaction.rpc_id(1, 1, "insane-bravery", 1)
	game.request_command_reaction.rpc_id(1, 2, "unknown", 1)
	game.request_command_reaction.rpc_id(1, 2, "insane-bravery", 0)
	game.request_end.rpc_id(1, 1)
	await create_timer(0.2).timeout
	assert(game.state.revision == 1 and game.state.cp[2] == 2)
	game._request_command_reaction("insane-bravery")
	if not await wait_for(func(): return game.state.revision == 2, "CP debit"): quit(1); return
	assert(game.state.cp[2] == 1 and S.pending(game.state).remaining == [4] and game.reaction_use.disabled)
	game.request_command_reaction.rpc_id(1, 2, "insane-bravery", 1)
	game.request_command_reaction.rpc_id(1, 4, "insane-bravery", 2)
	await create_timer(0.2).timeout
	assert(game.state.revision == 2 and game.state.cp[2] == 1)
	game._request_command_reaction("")
	if not await wait_for(func(): return game.state.phase == "movement", "normal roll after pass"): quit(1); return
	assert(game.state.revision == 4 and game.state.cp[2] == 1 and game.state.stratagems.uses.size() == 1)
	print("STRATAGEMS CLIENT: PASS")
	await create_timer(0.3).timeout
	quit()
