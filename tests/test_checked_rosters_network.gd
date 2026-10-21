extends SceneTree
const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
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
	F.populate(game, 1 if "--host-test" in OS.get_cmdline_user_args() else 2)
	game.saved_training_consent.button_pressed = true
	game._start_saved_match(false)
func wait_for(predicate: Callable, label: String) -> bool:
	for attempt in range(500):
		if predicate.call(): return true
		await create_timer(0.05).timeout
	push_error("CA network timeout: " + label + ": " + game.status.text)
	return false
func pick(s: Dictionary, player: int, action: String, model: int = -2, target: int = -2) -> Dictionary:
	for selected: Dictionary in C.unit_choices(s, player):
		if selected.action == action and (model == -2 or selected.model == model) and (target == -2 or selected.target == target): return selected
	return {}
func act(player: int, action: String, model: int = -2, target: int = -2) -> void:
	var selected := pick(game.state, player, action, model, target)
	assert(not selected.is_empty(), action)
	assert(C.unit_action(game.state, player, selected, Vector2.ZERO, game.state.revision, game._d6).is_empty(), action)
	game._broadcast()
func guest_action(action: String, model: int = -2, target: int = -2) -> bool:
	var revision: int = game.state.revision
	var selected := pick(game.state, 2, action, model, target)
	assert(not selected.is_empty(), action)
	game.request_unit_action.rpc_id(1, selected, Vector2.ZERO, revision)
	return await wait_for(func(): return game.state.revision > revision, action)
func run() -> void:
	var host: bool = "--host-test" in OS.get_cmdline_user_args()
	make_game()
	if host:
		if "--restored-host" not in OS.get_cmdline_user_args():
			game._host()
			if not await wait_for(func(): return game.guest_id != 0 and game.state.phase == "deployment", "authenticated lists"): quit(1); return
			assert(C.RosterValidation.enabled(game.state) and game.state.training_points == {1:615,2:290})
			var probe := RandomNumberGenerator.new()
			for seed_value in range(10000):
				probe.seed = seed_value
				probe.randi_range(1,6)
				var one := probe.randi_range(1,6)
				var two := probe.randi_range(1,6)
				var first_one := probe.randi_range(1,6)
				var first_two := probe.randi_range(1,6)
				if two > one and first_two > first_one: game.rng.seed = seed_value; break
			act(1, "mission-terrain")
			act(1, "mission-roles")
			if not await wait_for(func(): return game.state.mission.stage == "battle-ready", "guest role choice"): quit(1); return
			act(1, "mission-ready", -2, 0)
			if not await wait_for(func(): return game.state.mission.stage == "formations", "guest battle ready"): quit(1); return
			assert(C.select_awakened_attachment(game.state, 2, -1, game.state.revision).is_empty())
			act(1, "attach", 900, 1)
			act(1, "warlord", 300)
			act(1, "reserve", -2, 11)
			act(1, "setup-done")
			if not await wait_for(func(): return game.state.unit_abilities.get("setup_players", []).size() == 2, "formations reveal"): quit(1); return
			while game.state.phase == "deployment":
				var owner := C.Deployment.actor(game.state)
				assert(C.Deployment.preset(game.state, owner, game.state.revision).is_empty())
				assert(C.Deployment.confirm(game.state, owner, game.state.revision).is_empty())
			game._broadcast()
			if not await wait_for(func(): return game.guest_id == 0, "disconnect before first-turn roll"): quit(1); return
			game.multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()
			game.free()
			await create_timer(0.4).timeout
			var output: Array = []
			var args: Array[String] = ["--headless", "--path", ProjectSettings.globalize_path("res://"), "--script", "res://tests/test_checked_rosters_network.gd", "--log-file", ProjectSettings.globalize_path("res://.tools/ca-restored-host.log"), "--", "--host-test", "--restored-host"]
			var code := OS.execute(OS.get_executable_path(), args, output, true)
			for line in output: print(line)
			quit(code)
			return
		game._load_match(true)
		assert(C.RosterValidation.enabled(game.state) and game.state.roster_validation.armies[1].formations_verified and game.state.roster_validation.armies[2].formations_verified and not game.state.roster_validation.full_match_certified and not game.state.match_manifest.official_legality_validated)
		assert(game.mode == "host" and game.official_mission and game.state.phase == "mission_first_turn")
		var predicted: Dictionary = game.state.duplicate(true)
		var rng := RandomNumberGenerator.new()
		rng.state = game.rng.state
		assert(C.unit_action(predicted, 1, pick(predicted, 1, "mission-first"), Vector2.ZERO, predicted.revision, func() -> int: return rng.randi_range(1,6)).is_empty())
		if not await wait_for(func(): return game.guest_id != 0, "authenticated rejoin"): quit(1); return
		# Give the rejoined client time to validate the pending checkpoint and stale request.
		await create_timer(0.6).timeout
		act(1, "mission-first")
		assert(game.state == predicted and game.rng.state == rng.state and game.state.active == 2 and game.state.first_player == 2)
		var dice_count := 0
		for entry: Dictionary in game.journal.entries: dice_count += entry.dice.size()
		assert(dice_count == 5)
		if not await wait_for(func(): return game.get_node("VerificationAck").acknowledged, "guest acknowledged restored mission"): quit(1); return
		print("CHECKED ROSTERS HOST: PASS")
		await create_timer(0.2).timeout
		quit()
		return
	game._join()
	if not await wait_for(func(): return game.state.get("mission", {}).get("stage", "") == "roles-choice", "role choice"): quit(1); return
	assert(C.RosterValidation.enabled(game.state) and game.state.training_points == {1:615,2:290})
	var before := var_to_bytes(game.state)
	var forged: Dictionary = game.submitted_army.duplicate(true)
	forged.entries[0].cost = 1
	game.request_saved_army.rpc_id(1, forged)
	await create_timer(0.1).timeout
	assert(var_to_bytes(game.state) == before)
	var selected := pick(game.state, 2, "mission-side", -2, 2)
	var revision: int = game.state.revision
	game.request_unit_action.rpc_id(1, selected, Vector2.ZERO, revision - 1)
	await create_timer(0.1).timeout
	assert(game.state.revision == revision)
	if not await guest_action("mission-side", -2, 2): quit(1); return
	if not await wait_for(func(): return C.Mission.actor(game.state) == 2, "Battle Ready declaration"): quit(1); return
	if not await guest_action("mission-ready", -2, 0): quit(1); return
	if not await wait_for(func(): return C.UnitActions.setup_actor(game.state) == 2, "guest formations"): quit(1); return
	assert(not game.state.unit_abilities.reserves.has(11) and game.state.units[1100].on_battlefield and 11 in game.state.deployment.order)
	if not await guest_action("warlord", 600): quit(1); return
	if not await guest_action("setup-done"): quit(1); return
	assert(game.state.unit_abilities.reserves.has(11) and not game.state.units[1100].on_battlefield)
	if not await wait_for(func(): return game.state.phase == "mission_first_turn", "deployment complete"): quit(1); return
	var preview: Dictionary = game.state.duplicate(true)
	game._offline("CA host restart")
	game.free()
	await create_timer(1.1).timeout
	make_game()
	game._join()
	if not await wait_for(func(): return game.state.phase == "mission_first_turn", "restored first-turn roll"): quit(1); return
	assert(game.state == preview and game.official_mission)
	selected = C.unit_choices(game.state, 1)[0]
	game.request_unit_action.rpc_id(1, selected, Vector2.ZERO, game.state.revision)
	await create_timer(0.1).timeout
	# Host prediction and the five-dice journal verify this foreign request did not roll.
	if not await wait_for(func(): return game.state.phase == "start_turn", "resolved first turn"): quit(1); return
	assert(game.state.active == 2 and game.state.first_player == 2 and game.state.round == 1 and game.state.cp == {1:0,2:0})
	game.get_node("VerificationAck").finish.rpc_id(1)
	await create_timer(0.2).timeout
	print("CHECKED ROSTERS CLIENT: PASS")
	quit()
