extends SceneTree
const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const D = preload("res://scripts/edition_11/detachment_stratagems.gd")
var game
func _initialize() -> void: call_deferred("run")
func make_game() -> void:
	game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	var ack = load("res://tests/network_test_ack.gd").new()
	ack.name = "VerificationAck"
	game.add_child(ack)
	game.auto_models.button_pressed = false
	game.checked_rosters_choice.button_pressed = true
	F.populate(game,1 if "--host-test" in OS.get_cmdline_user_args() else 2)
	game.saved_training_consent.button_pressed = true
	game._start_saved_match(false)
func wait_for(predicate: Callable, label: String) -> bool:
	for attempt in range(500):
		if predicate.call(): return true
		await create_timer(0.05).timeout
	push_error("Detachment network timeout: " + label + ": " + game.status.text)
	return false
func pick(player: int, squad: int, value: String) -> Dictionary:
	for choice: Dictionary in C.unit_choices(game.state,player):
		if choice.action == "detachment-stratagem" and choice.target == squad and choice.value == value: return choice
	return {}
func run() -> void:
	var host := "--host-test" in OS.get_cmdline_user_args()
	make_game()
	if host:
		if "--restored-host" not in OS.get_cmdline_user_args():
			game._host()
			if not await wait_for(func(): return game.guest_id != 0 and game.state.phase == "deployment","admitted lists"): quit(1); return
			var s: Dictionary = game.state
			C.UnitActions.attach(s,600,4)
			s.awakened_dynasty.pending = []
			s.unit_abilities.setup_players = [1,2]
			s.unit_abilities.battle_players = [1,2]
			s.deployment.complete = true
			s.mission.stage = "battle"
			s.phase = "command"
			s.active = 1
			s.turn = 3
			s.round = 2
			s.cp = {1:3,2:3}
			s.combat_doctrines.selected_turn[1] = s.turn
			s.unit_abilities.phase_key = C.UnitActions.key(s)
			var chosen := pick(1,1,"assault")
			assert(not chosen.is_empty())
			assert(C.unit_action(s,1,chosen,Vector2.ZERO,s.revision,game._d6).is_empty())
			s.phase = "fight"
			s.fight_actor = 1
			s.fight_selected = -1
			s.unit_abilities.phase_key = C.UnitActions.key(s)
			game._reset_history()
			game._broadcast()
			if not await wait_for(func(): return game.state.revision == 2,"guest stratagem"): quit(1); return
			assert(game.state.cp == {1:2,2:2} and game.state.detachment_stratagems.hungry[4].led)
			if not await wait_for(func(): return game.guest_id == 0,"disconnect"): quit(1); return
			game.multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()
			game.free()
			await create_timer(0.4).timeout
			var output: Array = []
			var args: Array[String] = ["--headless","--path",ProjectSettings.globalize_path("res://"),"--script","res://tests/test_detachment_stratagems_network.gd","--log-file",ProjectSettings.globalize_path("res://.tools/detachment-restored-host.log"),"--","--host-test","--restored-host"]
			var code := OS.execute(OS.get_executable_path(),args,output,true)
			for line in output: print(line)
			quit(code)
			return
		game._load_match(true)
		assert(game.mode == "host" and D.enabled(game.state) and game.state.cp == {1:2,2:2} and game.state.revision == 2)
		var before := var_to_bytes(game.state)
		var saved_rng: int = game.rng.state
		if not await wait_for(func(): return game.get_node("VerificationAck").acknowledged,"restored verification"): quit(1); return
		assert(var_to_bytes(game.state) == before and game.rng.state == saved_rng)
		var count := 0
		for entry: Dictionary in game.journal.entries: count += entry.dice.size()
		assert(count == 0)
		print("DETACHMENT STRATAGEMS HOST: PASS")
		await create_timer(0.2).timeout
		quit()
		return
	game._join()
	if not await wait_for(func(): return game.state.phase == "fight" and game.state.revision == 1,"fight setup"): quit(1); return
	assert(D.enabled(game.state) and C.Doctrines.active_for(game.state,1) == "assault")
	var selected := pick(2,4,D.HUNGRY)
	assert(not selected.is_empty())
	var invalid := selected.duplicate(true)
	invalid.target = 1
	game.request_unit_action.rpc_id(1,invalid,Vector2.ZERO,1)
	game.request_unit_action.rpc_id(1,selected,Vector2.ZERO,0)
	await create_timer(0.2).timeout
	assert(game.state.revision == 1 and game.state.cp == {1:2,2:3})
	game.request_unit_action.rpc_id(1,selected,Vector2.ZERO,1)
	if not await wait_for(func(): return game.state.revision == 2,"Hungry Void accepted"): quit(1); return
	assert(game.state.cp == {1:2,2:2} and game.state.detachment_stratagems.hungry[4].led)
	var preview: Dictionary = game.state.duplicate(true)
	game._offline("Testing active stratagem restoration")
	game.free()
	await create_timer(1.1).timeout
	make_game()
	game._join()
	if not await wait_for(func(): return game.state.phase == "fight" and game.state.revision == 2,"restored effects"): quit(1); return
	assert(game.state == preview and C.Doctrines.active_for(game.state,1) == "assault")
	game.request_unit_action.rpc_id(1,selected,Vector2.ZERO,2)
	await create_timer(0.2).timeout
	assert(game.state == preview)
	game.get_node("VerificationAck").finish.rpc_id(1)
	await create_timer(0.2).timeout
	print("DETACHMENT STRATAGEMS CLIENT: PASS")
	quit()
