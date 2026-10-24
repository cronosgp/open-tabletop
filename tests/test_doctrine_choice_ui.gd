extends "res://tests/test_tactical_combat_flow.gd"

var game: Node

func prepare_command() -> void:
	game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	game.match_save_path = "user://matches/doctrine-ui-%s.save" % Time.get_ticks_usec()
	game.match_journal_directory = "user://matches/journals/doctrine-ui-%s" % Time.get_ticks_usec()
	game.main_menu.guided_button.pressed.emit()
	state = game.state
	for owner: int in [1, 2]:
		var leader := model_of(owner, "captain" if owner == 1 else "chaplain")
		var bodyguard := model_of(owner, "intercessor-squad" if owner == 1 else "assault-intercessor-squad")
		choose(owner, raw_choice(owner, "warlord", leader))
		choose(owner, raw_choice(owner, "attach", leader, int(state.units[bodyguard].squad)))
		choose(owner, raw_choice(owner, "setup-done"))
	for step in range(8):
		var squad := Prepared.Deployment.current(state)
		if squad < 0: break
		var owner := Prepared.Deployment.actor(state)
		var ids := C.living(state, squad)
		var lower := str(state.units[ids[0]].definition_id).ends_with(":hellblaster-squad") or str(state.units[ids[0]].definition_id).ends_with(":bladeguard-veteran-squad")
		for index in range(ids.size()):
			command(owner, {"kind": Commands.PLACE_MODEL, "model": ids[index], "destination": Vector2(-12 if owner == 1 else 12, (-12 if lower else 6) + index * 1.65)})
		command(owner, {"kind": Commands.DEPLOYMENT_CONFIRM})
	for step in range(80):
		var decision := Decisions.current(state, ["combat-doctrines"])
		if not decision.is_empty():
			for option: Dictionary in decision.legal_options:
				if str(option.value) == "devastator":
					command(int(decision.priority_player_id), {"kind": Commands.SELECT_DOCTRINE, "doctrine": option.value, "decision_id": decision.decision_id, "option_id": option.id})
					break
			continue
		if not raw_choice(1, "acumen").is_empty(): break
		if resolve_one(): continue
		command(C.actor(state), {"kind": Commands.ADVANCE_PHASE})
	game.state = state
	game._refresh()
	check(state.phase == "command" and not raw_choice(1, "acumen").is_empty(), "Real tactical Command exposes the Captain's doctrine ability")

func capture(label: String) -> void:
	for dimensions in [Vector2i(1280, 800), Vector2i(1024, 768)]:
		root.mode = Window.MODE_WINDOWED
		root.size = dimensions
		game._refresh()
		for frame in range(18): await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://.tools/doctrine-%s-%d.png" % [label, dimensions.x])

func run() -> void:
	prepare_command()
	var args := OS.get_cmdline_user_args()
	if "--capture-before" in args:
		await capture("before")
	else:
		var panel: VBoxContainer = game.doctrine_action_panel
		var checkpoint: Dictionary = game.state.duplicate(true)
		var unchanged := var_to_bytes(game.state)
		check(panel.is_visible_in_tree() and not game.unit_action_picker.visible, "Grouped selectors replace the repeated combinations")
		check(panel.action_picker.get_selected_metadata() == "acumen" and "0 CP" in panel.explanation.text and "Strategic Acumen" in panel.explanation.text, "Free Captain ability is distinct and initially selected")
		check("100" not in panel.explanation.text and "100" not in panel.unit_picker.text, "No internal Captain model ID in the doctrine card")
		if "--capture-after" in args: await capture("free")
		select_doctrine(panel, "assault")
		check(var_to_bytes(game.state) == unchanged, "Browsing doctrine selectors does not change state or spend CP")
		var captain_squad := int(game.unit_action_picker.get_selected_metadata().target)
		var cp := int(game.state.cp[1])
		var revision := int(game.state.revision)
		game.unit_action_button.pressed.emit()
		check(game.state.revision > revision and game.state.cp[1] == cp and C.Doctrines.active_for(game.state, captain_squad) == "assault", "Actual free Confirm applies the Captain doctrine without spending CP")
		game.state = checkpoint.duplicate(true)
		game._reset_history()
		game._refresh()
		for index in range(panel.action_picker.item_count):
			if panel.action_picker.get_item_metadata(index) == "adaptive":
				panel.action_picker.select(index)
				panel.action_picker.item_selected.emit(index)
				break
		var hell_squad := int(game.state.units[model_of(1, "hellblaster-squad")].squad)
		var unit_index: int = panel.unit_picker.get_item_index(hell_squad)
		panel.unit_picker.select(unit_index)
		panel.unit_picker.item_selected.emit(unit_index)
		select_doctrine(panel, "devastator")
		check("Already active" in panel.explanation.text, "A redundant paid doctrine explicitly warns of no additional effect")
		if "--capture-after" in args: await capture("redundant")
		select_doctrine(panel, "assault")
		check("1 CP" in panel.explanation.text and "charge after Advance" in panel.explanation.text and "next Command" in panel.explanation.text, "Paid preview explains cost effect and duration")
		check(var_to_bytes(game.state) == unchanged, "Browsing action and unit also preserves authoritative state")
		if "--capture-after" in args: await capture("paid")
		game.unit_action_button.pressed.emit()
		check(game.state.revision > revision and game.state.cp[1] == cp - 1 and C.Doctrines.active_for(game.state, hell_squad) == "assault", "Actual paid Confirm applies to selected unit and spends one CP")
		check(C.Doctrines.active_for(game.state, captain_squad) != "assault", "Paid selection does not change a different unit's doctrine")
	print("Doctrine choice UI: %d failures" % failures)
	game.queue_free()
	await process_frame
	await process_frame
	quit(1 if failures else 0)

func select_doctrine(panel: VBoxContainer, value: String) -> void:
	for index in range(panel.doctrine_picker.item_count):
		if str(panel.doctrine_picker.get_item_metadata(index).value) == value:
			panel.doctrine_picker.select(index)
			panel.doctrine_picker.item_selected.emit(index)
			return
	check(false, "Expected legal doctrine selector option: " + value)
