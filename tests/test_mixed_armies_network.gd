extends SceneTree
const Training = preload("res://scripts/edition_11/training_roster.gd")
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var host: bool = "--host-test" in OS.get_cmdline_user_args()
	var owner := 1 if host else 2
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	game.auto_models.button_pressed = false
	var own := Training.Capabilities.reference_army("Space Marines" if host else "Necrons")
	own.list.name = "PRIVATE REFERENCE NAME"
	own.list.notes = "PRIVATE REFERENCE NOTES"
	game.army_builder.store.path = "user://mixed-network-list.json"
	var saved: Dictionary = game.army_builder.store.save_list(own.list)
	if not saved.error.is_empty():
		push_error(saved.error)
		quit(1)
		return
	game._refresh_army_choices()
	var picker: OptionButton = game.saved_army_pickers[owner]
	for index in range(picker.item_count):
		if picker.get_item_metadata(index).get("id", "") == saved.list.id: picker.select(index)
	game.saved_training_consent.button_pressed = true
	game._start_saved_match(false)
	if host: game._host()
	else: game._join()
	var started := Time.get_ticks_msec()
	while game.state.phase != "deployment" and Time.get_ticks_msec() - started < 12000: await create_timer(0.05).timeout
	var passed: bool = game.state.phase == "deployment" and game.state.units.size() == 70 and game.state.squads.size() == 10 and game.state.training_points == {1: 480, 2: 480}
	var identity: String = game.state.pack_hash
	var revision := -1
	while game.state.phase == "deployment" and Time.get_ticks_msec() - started < 18000:
		if Training.Capabilities.ID != game.state.match_manifest.get("capabilities", ""): passed = false
		if game.state.revision != revision and game.Combat.actor(game.state) == owner:
			revision = game.state.revision
			game._request_deployment_preset()
			await create_timer(0.1).timeout
			game._request_end()
		await create_timer(0.05).timeout
	passed = passed and game.state.phase == "start_turn" and game.state.deployment.committed.size() == 10 and game.state.pack_hash == identity and "PRIVATE" not in var_to_str(game.state)
	if host:
		await create_timer(0.4).timeout
		game._request_end()
		await create_timer(0.5).timeout
		passed = passed and game.state.phase == "command"
	else:
		while game.state.phase != "command" and Time.get_ticks_msec() - started < 20000: await create_timer(0.05).timeout
		passed = passed and game.state.phase == "command" and game.pieces.size() == 70
	if not passed: print("DETAILS: ", game.mode, " ", game.state.phase, " units=", game.state.units.size(), " revision=", game.state.revision, " committed=", game.state.get("deployment", {}).get("committed", []), " notice=", game.status.text)
	print("MIXED ARMIES ", "HOST" if host else "CLIENT", ": ", "PASS" if passed else "FAIL")
	quit(0 if passed else 1)
