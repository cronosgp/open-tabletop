extends SceneTree
const P = preload("res://scripts/edition_11/prepared_training.gd")
const C = P.Combat
const D = C.Doctrines
var game
func _initialize() -> void: call_deferred("run")
func make_game(host: bool) -> void:
	game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	game.auto_models.button_pressed = false
	game.combat_doctrines_choice.button_pressed = true
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
	push_error("11e doctrine network timeout: " + label + ": " + game.status.text)
	return false
func run() -> void:
	var host: bool = "--host-test" in OS.get_cmdline_user_args()
	make_game(host)
	if host:
		if "--restored-host" not in OS.get_cmdline_user_args():
			game._host()
			if not await wait_for(func(): return game.state.phase == "deployment", "accepted lists"): quit(1); return
			game.state.phase = "start_turn"
			game.state.active = 2
			game.state.turn = 2
			game.state.revision = 0
			game.state.terrain.areas = []
			for id: int in game.state.units:
				if id not in [100, 200, 300, 400]: game.state.units[id].wounds = 0
				game.state.units[id].position = Vector2(-6 if game.state.units[id].owner == 2 else 3, -8 if id < 300 else 8)
			assert(C.advance_phase(game.state, 2, 0).is_empty() and D.needs_choice(game.state) and game.state.cp == {1: 0, 2: 0})
			game._reset_history()
			game._broadcast()
			if not await wait_for(func(): return game.guest_id == 0, "guest disconnect"): quit(1); return
			game.multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()
			game.free()
			await create_timer(0.4).timeout
			var output: Array = []
			var args: Array[String] = ["--headless", "--path", ProjectSettings.globalize_path("res://"), "--script", "res://tests/test_combat_doctrines_network.gd", "--log-file", ProjectSettings.globalize_path("res://.tools/doctrines-restored-host.log"), "--", "--host-test", "--restored-host"]
			var code := OS.execute(OS.get_executable_path(), args, output, true)
			for line in output: print(line)
			quit(code)
			return
		game._load_match(true)
		assert(game.mode == "host" and game.combat_doctrines and game.state.revision == 1 and D.needs_choice(game.state) and game.state.cp == {1: 0, 2: 0})
		var saved_rng: int = game.rng.state
		if not await wait_for(func(): return game.state.revision == 2, "restored doctrine selection"): quit(1); return
		assert(D.active_for(game.state, 2) == "assault" and game.state.combat_doctrines.used[2] == ["assault"] and game.state.cp == {1: 1, 2: 1} and game.rng.state == saved_rng)
		game.state.phase = "charge"
		game.state.squads[2].advanced = true
		game._reset_history()
		var predicted: Dictionary = game.state.duplicate(true)
		var rng := RandomNumberGenerator.new()
		rng.state = game.rng.state
		assert(C.declare_charge(predicted, 2, 200, 2, func() -> int: return rng.randi_range(1, 6)).error.is_empty())
		game._broadcast()
		if not await wait_for(func(): return game.state.revision == 3, "advance-charge"): quit(1); return
		assert(game.state == predicted and game.rng.state == rng.state and game.state.cp == {1: 1, 2: 1})
		var dice_count := 0
		for entry: Dictionary in game.journal.entries: dice_count += entry.dice.size()
		assert(dice_count == 2)
		print("11E DOCTRINES HOST: PASS")
		await create_timer(0.8).timeout
		quit()
		return
	game._join()
	if not await wait_for(func(): return game.state.revision == 1 and D.needs_choice(game.state), "start choice"): quit(1); return
	game.request_combat_doctrine.rpc_id(1, "invented", 1)
	game.request_combat_doctrine.rpc_id(1, "assault", 0)
	await create_timer(0.15).timeout
	assert(game.state.revision == 1 and game.state.cp == {1: 0, 2: 0})
	game._offline("Testing current e11 doctrine choice after host restart")
	game.free()
	await create_timer(1.1).timeout
	make_game(false)
	game._join()
	if not await wait_for(func(): return game.state.revision == 1 and D.needs_choice(game.state), "restored choice"): quit(1); return
	game.doctrine_choice.select(game.doctrine_choice.get_item_index(3))
	game._request_combat_doctrine()
	if not await wait_for(func(): return game.state.phase == "charge" and game.state.revision == 2, "active Assault"): quit(1); return
	game.request_combat_doctrine.rpc_id(1, "tactical", 2)
	await create_timer(0.15).timeout
	assert(game.state.revision == 2 and D.active_for(game.state, 2) == "assault")
	game.selected = 200
	game._refresh()
	assert(not game.charge_button.disabled)
	game._request_charge_roll()
	if not await wait_for(func(): return game.state.revision == 3, "charge roll"): quit(1); return
	assert(game.state.squads[2].charge_declared and D.active_for(game.state, 2) == "assault" and game.state.cp == {1: 1, 2: 1})
	print("11E DOCTRINES CLIENT: PASS")
	quit()
