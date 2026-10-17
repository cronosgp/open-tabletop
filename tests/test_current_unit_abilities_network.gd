extends SceneTree
const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const R = C.Reanimation
var game
func _initialize() -> void: call_deferred("run")
func make_game() -> void:
	game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	game.auto_models.button_pressed = false
	game.unit_abilities_choice.button_pressed = true
	F.populate(game, 1 if "--host-test" in OS.get_cmdline_user_args() else 2)
	game.saved_training_consent.button_pressed = true
	game._start_saved_match(false)
func wait_for(predicate: Callable, label: String) -> bool:
	for attempt in range(240):
		if predicate.call(): return true
		await create_timer(0.05).timeout
	push_error("Current abilities network timeout: " + label + ": " + game.status.text)
	return false
func pick(s: Dictionary, owner: int, action: String, model: int = -2, target: int = -2) -> Dictionary:
	for selected: Dictionary in C.unit_choices(s, owner):
		if selected.action == action and (model == -2 or selected.model == model) and (target == -2 or selected.target == target): return selected
	return {}
func apply(s: Dictionary, owner: int, action: String, model: int = -2, target: int = -2) -> bool:
	var selected := pick(s, owner, action, model, target)
	return not selected.is_empty() and C.unit_action(s, owner, selected, Vector2.ZERO, s.revision).is_empty()
func run() -> void:
	var host: bool = "--host-test" in OS.get_cmdline_user_args()
	make_game()
	if host:
		if "--restored-host" not in OS.get_cmdline_user_args():
			game._host()
			if not await wait_for(func(): return game.guest_id != 0 and game.state.phase == "deployment", "authentication and saved-list admission"): quit(1); return
			var attachment_error := C.select_awakened_attachment(game.state, 2, 4, game.state.revision)
			assert(attachment_error.is_empty(), attachment_error)
			assert(apply(game.state, 1, "attach", 900, 1))
			assert(apply(game.state, 1, "warlord", 300))
			assert(apply(game.state, 1, "setup-done"))
			assert(apply(game.state, 2, "warlord", 600))
			assert(apply(game.state, 2, "setup-done"))
			game.state.phase = "command"
			game.state.turn = 2
			game.state.active = 2
			game.state.revision = 0
			game.state.unit_abilities.phase_key = C.UnitActions.key(game.state)
			game.state.terrain.areas = []
			game.state.units[401].wounds = 0
			game.state.units[600].wounds = 5
			for model: int in game.state.units:
				var unit: Dictionary = game.state.units[model]
				unit.position = Vector2((-10 if unit.owner == 1 else 5) + floori(float(model % 100) / 5.0) * 1.6, -8 + (model % 5) * 1.6 + (unit.squad - 4) * 4)
			game.state.units[600].position = Vector2(7, -8)
			var probe := RandomNumberGenerator.new()
			for seed_value in range(100):
				probe.seed = seed_value
				if probe.randi_range(1, 6) >= 3:
					game.rng.seed = seed_value
					break
			R.start_command(game.state)
			R.open_end_command(game.state)
			game._reset_history()
			game._broadcast()
			if not await wait_for(func(): return game.state.revision == 3, "mixed preview"): quit(1); return
			assert(game.state.units[600].wounds == 5 and game.state.units[401].wounds == 0 and R.pending(game.state).current.healed == {600: 1})
			if not await wait_for(func(): return game.guest_id == 0, "disconnect"): quit(1); return
			game.multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()
			game.free()
			await create_timer(0.4).timeout
			var output: Array = []
			var args: Array[String] = ["--headless", "--path", ProjectSettings.globalize_path("res://"), "--script", "res://tests/test_current_unit_abilities_network.gd", "--log-file", ProjectSettings.globalize_path("res://.tools/current-unit-restored-host.log"), "--", "--host-test", "--restored-host"]
			var code := OS.execute(OS.get_executable_path(), args, output, true)
			for line in output: print(line)
			quit(code)
			return
		game._load_match(true)
		assert(game.mode == "host" and game.unit_abilities and game.state.revision == 3)
		var predicted: Dictionary = game.state.duplicate(true)
		var rng := RandomNumberGenerator.new()
		rng.state = game.rng.state
		assert(C.resolve_reanimation(predicted, 2, "confirm", -1, -1, Vector2.ZERO, predicted.revision).is_empty())
		for squad in [2, 8]:
			assert(C.resolve_reanimation(predicted, 2, "roll", squad, -1, Vector2.ZERO, predicted.revision, func() -> int: return rng.randi_range(1, 6)).is_empty())
		assert(apply(predicted, 2, "pass"))
		if not await wait_for(func(): return game.state.phase == "movement", "Command complete after restart"): quit(1); return
		assert(game.state == predicted and game.rng.state == rng.state and game.state.units[401].wounds == 1 and game.state.units[600].wounds == 6)
		var dice_count := 0
		for entry: Dictionary in game.journal.entries: dice_count += entry.dice.size()
		assert(dice_count == 3)
		print("CURRENT UNIT ABILITIES HOST: PASS")
		await create_timer(0.8).timeout
		quit()
		return
	game._join()
	if not await wait_for(func(): return not R.pending(game.state).is_empty(), "Command window"): quit(1); return
	game.request_reanimation.rpc_id(1, "roll", 4, -1, Vector2.ZERO, -1)
	await create_timer(0.1).timeout
	assert(game.state.revision == 0)
	game.request_reanimation.rpc_id(1, "roll", 4, -1, Vector2.ZERO, 0)
	if not await wait_for(func(): return game.state.revision == 1, "Legion choice"): quit(1); return
	var selected := pick(game.state, 2, "legion-keep")
	assert(not selected.is_empty() and R.pending(game.state).current.reroll_pending)
	game.request_unit_action.rpc_id(1, selected, Vector2.ZERO, 0)
	await create_timer(0.1).timeout
	assert(game.state.revision == 1)
	game.request_unit_action.rpc_id(1, selected, Vector2.ZERO, 1)
	if not await wait_for(func(): return game.state.revision == 2, "accepted D3"): quit(1); return
	game._request_reanimation("suggest")
	if not await wait_for(func(): return game.state.revision == 3, "preview"): quit(1); return
	var preview: Dictionary = game.state.duplicate(true)
	game._offline("Testing current ability host restart")
	game.free()
	await create_timer(1.1).timeout
	make_game()
	game._join()
	if not await wait_for(func(): return game.state.revision == 3, "restored preview"): quit(1); return
	assert(game.state == preview and game.pieces[401].visible and game.state.units[401].wounds == 0)
	game._request_reanimation("confirm")
	if not await wait_for(func(): return game.state.revision == 4, "healing committed"): quit(1); return
	for squad in [2, 8]:
		var revision: int = game.state.revision
		game.request_reanimation.rpc_id(1, "roll", squad, -1, Vector2.ZERO, revision)
		if not await wait_for(func(): return game.state.revision > revision, "remaining activation"): quit(1); return
	if not await wait_for(func(): return C.UnitActions.pending(game.state).get("kind", "") == "end", "Orb optional window"): quit(1); return
	selected = pick(game.state, 2, "pass")
	game.request_unit_action.rpc_id(1, selected, Vector2.ZERO, game.state.revision)
	if not await wait_for(func(): return game.state.phase == "movement", "Movement"): quit(1); return
	assert(game.state.units[401].wounds == 1 and game.state.units[600].wounds == 6)
	print("CURRENT UNIT ABILITIES CLIENT: PASS")
	quit()
