extends SceneTree
const Training = preload("res://scripts/edition_11/training_roster.gd")
var game
func _initialize() -> void: call_deferred("run")
func wait_for(predicate: Callable, label: String) -> bool:
	for step in range(180):
		if predicate.call(): return true
		await create_timer(0.05).timeout
	push_error("Objective Secured network timeout: " + label + " / " + game.status.text)
	return false
func run() -> void:
	var host: bool = "--host-test" in OS.get_cmdline_user_args()
	var owner := 1 if host else 2
	game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	game.auto_models.button_pressed = false
	game.objective_secured_choice.button_pressed = true
	var reference := Training.Capabilities.reference_army("Necrons" if host else "Space Marines")
	var picker: OptionButton = game.saved_army_pickers[owner]
	for index in range(picker.item_count):
		if picker.get_item_metadata(index).get("id", "") == reference.list.id: picker.select(index)
	game.saved_training_consent.button_pressed = true
	game._start_saved_match(false)
	if host:
		game._host()
		if not await wait_for(func(): return game.state.phase == "deployment", "accepted lists"): quit(1); return
		game.state.phase = "command"
		game.state.active = 2
		game.state.turn = 2
		for id: int in game.Combat.living(game.state, 2): game.state.units[id].position = Vector2(-9, 4)
		game._reset_history()
		game._broadcast()
		if not await wait_for(func(): return game.state.phase == "movement", "guest phase command"): quit(1); return
		var passed: bool = game.state.mission.objectives[1].secured == 2 and game.state.match_manifest.objective_secured == game.Combat.ObjectiveSecured.ID
		if not await wait_for(func(): return game.guest_id == 0, "guest disconnect"): quit(1); return
		if not await wait_for(func(): return game.guest_id != 0, "authenticated guest rejoin"): quit(1); return
		await create_timer(0.6).timeout
		print("OBJECTIVE SECURED HOST: ", "PASS" if passed else "FAIL")
		quit(0 if passed else 1)
		return
	game._join()
	if not await wait_for(func(): return game.state.phase == "command", "Command snapshot"): quit(1); return
	var identity: String = game.state.pack_hash
	game._request_end()
	if not await wait_for(func(): return game.state.phase == "movement", "secured snapshot"): quit(1); return
	var passed: bool = game.state.mission.objectives[1].controller == 2 and game.state.mission.objectives[1].secured == 2 and game.state.pack_hash == identity
	game._offline("Rejoin Objective Secured match")
	await create_timer(0.4).timeout
	game._join()
	if not await wait_for(func(): return game.mode == "client" and game.state.phase == "movement", "restored objective"): quit(1); return
	passed = passed and game.state.mission.objectives[1].secured == 2 and game.state.pack_hash == identity and game.state.units.size() == 70
	print("OBJECTIVE SECURED CLIENT: ", "PASS" if passed else "FAIL")
	quit(0 if passed else 1)
