extends SceneTree
const T = preload("res://scripts/edition_11/training_roster.gd")
func _initialize() -> void: call_deferred("run")
func revision(game: Node, wanted: int) -> bool:
	for attempt in range(100):
		if game.state.revision >= wanted: return game.state.revision == wanted
		await create_timer(0.1).timeout
	push_error("Saved-army revision timeout %d/%d: %s" % [game.state.revision, wanted, game.status.text])
	return false
func deployment(game: Node) -> bool:
	for attempt in range(100):
		if game.state.phase == "deployment": return true
		await create_timer(0.1).timeout
	push_error("Saved-army setup timeout: " + game.status.text)
	return false
func run() -> void:
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	var host: bool = "--host-test" in OS.get_cmdline_user_args()
	var mismatch: bool = "--budget-mismatch-test" in OS.get_cmdline_user_args()
	var count_rerolls: bool = "--count-rerolls-test" in OS.get_cmdline_user_args()
	var hazard_rerolls: bool = "--hazard-rerolls-test" in OS.get_cmdline_user_args()
	var escape_rerolls: bool = "--escape-rerolls-test" in OS.get_cmdline_user_args()
	var damage_rerolls: bool = "--damage-rerolls-test" in OS.get_cmdline_user_args()
	var save_rerolls: bool = "--save-rerolls-test" in OS.get_cmdline_user_args()
	var attack_rerolls: bool = "--attack-rerolls-test" in OS.get_cmdline_user_args()
	var rerolls: bool = "--movement-rerolls-test" in OS.get_cmdline_user_args()
	var stratagems: bool = "--stratagem-test" in OS.get_cmdline_user_args() or rerolls or attack_rerolls or save_rerolls or damage_rerolls or hazard_rerolls or count_rerolls or escape_rerolls
	game.stratagem_choice.button_pressed = stratagems
	game.reroll_choice.button_pressed = rerolls
	game.attack_reroll_choice.button_pressed = attack_rerolls
	game.save_reroll_choice.button_pressed = save_rerolls
	game.damage_reroll_choice.button_pressed = damage_rerolls
	game.hazard_reroll_choice.button_pressed = hazard_rerolls
	game.escape_reroll_choice.button_pressed = escape_rerolls
	game.count_reroll_choice.button_pressed = count_rerolls
	var own: Dictionary = T.template("Necrons" if host else "Space Marines", "training", 500).list
	if host: own.entries.resize(1)
	if mismatch and not host:
		own.category = "incursion"
		own.points_limit = 1000
	own.name = "PRIVATE NAME"
	own.notes = "PRIVATE NOTES"
	game.army_builder.store.path = "res://.tools/saved-network-%s.json" % ("host" if host else "client")
	var saved: Dictionary = game.army_builder.store.save_list(own)
	if not saved.error.is_empty():
		push_error(saved.error)
		quit(1)
		return
	game._refresh_army_choices()
	var picker: OptionButton = game.saved_army_pickers[1 if host else 2]
	for index in range(picker.item_count):
		if picker.get_item_metadata(index).get("id", "") == saved.list.id: picker.select(index)
	game.saved_training_consent.button_pressed = true
	game._start_saved_match(false)
	if host:
		game._host()
		var passed: bool = await deployment(game)
		passed = passed and game.state.units.size() == 20 and game.state.training_points == {1: 85, 2: 160} and "PRIVATE" not in var_to_str(game.state)
		game._request_deployment_preset()
		game._request_end()
		passed = await revision(game, 6) and passed
		passed = passed and game.state.phase == "start_turn" and game.state.deployment.committed == [1, 2, 4]
		game._request_end()
		passed = passed and game.state.phase == "command" and game.state.cp == {1: 1, 2: 1}
		passed = passed and game.state.has("stratagems") == stratagems
		passed = passed and game.state.get("stratagems", {}).get("escape_rerolls", false) == escape_rerolls
		passed = passed and game.state.get("stratagems", {}).get("count_rerolls", false) == count_rerolls and game.state.get("stratagems", {}).get("hazard_rerolls", false) == hazard_rerolls and game.state.get("stratagems", {}).get("damage_rerolls", false) == damage_rerolls and game.state.get("stratagems", {}).get("save_rerolls", false) == save_rerolls and game.state.get("stratagems", {}).get("attack_rerolls", false) == attack_rerolls and game.state.get("stratagems", {}).get("movement_rerolls", false) == rerolls
		print("SAVED ARMIES HOST: ", "PASS" if passed else "FAIL")
		await create_timer(0.8).timeout
		quit(0 if passed else 1)
		return
	game._join()
	var passed := true
	if mismatch:
		for attempt in range(100):
			if game.state.get("ready_armies", []).size() == 2: break
			await create_timer(0.1).timeout
		passed = game.state.phase == "army_selection" and game.state.cp == {1: 0, 2: 0} and game.state.revision == 0
		game.request_end.rpc_id(1, 0)
		await create_timer(0.15).timeout
		passed = passed and game.state.phase == "army_selection"
		own.id = saved.list.id
		own.category = "training"
		own.points_limit = 500
		game.army_builder.store.save_list(own)
		game._refresh_army_choices()
		game._submit_saved_army()
	passed = await revision(game, 2) and passed
	passed = passed and game.state.units.size() == 20 and game.pieces.size() == 20 and game.state.squads[2].faction == "Space Marines"
	var identity: String = game.state.pack_hash
	var changed: Dictionary = game.submitted_army.duplicate(true)
	changed.copies = 1
	game.request_saved_army.rpc_id(1, changed)
	game.request_move.rpc_id(1, 100, Vector2(-18, 0), 2)
	await create_timer(0.2).timeout
	passed = passed and game.state.revision == 2 and game.state.pack_hash == identity and game.state.units.size() == 20
	game._request_deployment_preset()
	passed = await revision(game, 3) and passed
	game._request_end()
	passed = await revision(game, 4) and passed
	game._offline("Rejoin selected saved army")
	await create_timer(0.6).timeout
	game._join()
	passed = await revision(game, 4) and passed
	passed = passed and game.state.pack_hash == identity and game.pieces.size() == 20 and game.state.deployment.committed == [1, 2]
	game._request_deployment_preset()
	passed = await revision(game, 5) and passed
	game._request_end()
	passed = await revision(game, 7) and passed
	passed = passed and game.state.phase == "command" and game.state.training_points == {1: 85, 2: 160} and "PRIVATE" not in var_to_str(game.state)
	passed = passed and game.state.has("stratagems") == stratagems
	passed = passed and game.state.get("stratagems", {}).get("escape_rerolls", false) == escape_rerolls
	passed = passed and game.state.get("stratagems", {}).get("count_rerolls", false) == count_rerolls and game.state.get("stratagems", {}).get("hazard_rerolls", false) == hazard_rerolls and game.state.get("stratagems", {}).get("damage_rerolls", false) == damage_rerolls and game.state.get("stratagems", {}).get("save_rerolls", false) == save_rerolls and game.state.get("stratagems", {}).get("attack_rerolls", false) == attack_rerolls and game.state.get("stratagems", {}).get("movement_rerolls", false) == rerolls
	print("SAVED ARMIES CLIENT: ", "PASS" if passed else "FAIL")
	await create_timer(0.2).timeout
	quit(0 if passed else 1)
