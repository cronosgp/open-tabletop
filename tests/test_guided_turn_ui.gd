extends SceneTree
const Combat = preload("res://scripts/edition_11/combat_scenario.gd")

var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func _initialize() -> void: call_deferred("run")

func show_step(game: Node, phase: String, expected: String, turn: int = 1, fight_step: String = "") -> void:
	game.state.phase = phase
	game.state.turn = turn
	game.state.fight_step = fight_step
	game.state.erase("last_attack")
	var before := var_to_str(game.state)
	game._refresh_first_session_guide()
	check(expected in game.first_session_heading.text, "%s shows %s" % [phase, expected])
	check(var_to_str(game.state) == before, "Refreshing %s guidance leaves match state unchanged" % phase)

func run() -> void:
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	game._start_objectives()
	game.combat_enabled = true
	game.guided_first_session = true
	game.saved_army_mode = true
	game.state.test_winner = 0
	show_step(game, "charge", "STEP 8 OF 10")
	check(not game.first_session_panel.visible and game.combat_hud.guide_progress_label.text == "GUIDE 8/10", "Guided progress stays compact in the HUD instead of a persistent Play card")
	check("2D6" in game.first_session_guide.text and game.first_session_progress.value == 8, "Charge guidance gives the immediate task and correct progress")
	show_step(game, "fight", "STEP 9 OF 10", 1, "pile_in")
	check("pile-in" in game.first_session_guide.text.to_lower(), "Fight guidance follows the current pile-in step")
	show_step(game, "fight", "STEP 9 OF 10", 1, "attacks")
	check("melee attacks" in game.first_session_guide.text, "Fight guidance points to attack planning")
	show_step(game, "fight", "STEP 9 OF 10", 1, "complete")
	check("end of the turn" in game.first_session_guide.text, "Completed Fight points to end of turn")
	game.state.phase = "shooting"
	game.state.last_attack = {"recorded": true}
	var before_result_refresh := var_to_str(game.state)
	game._refresh_first_session_guide()
	check("STEP 7 OF 10" in game.first_session_heading.text and "another eligible unit" in game.first_session_guide.text, "Recorded shooting result points to another unit or progression")
	check(var_to_str(game.state) == before_result_refresh, "Shooting-result guidance leaves match state unchanged")
	show_step(game, "end_turn", "STEP 10 OF 10")
	check("other player's turn" in game.first_session_guide.text, "End-turn guidance names the next step")
	var guided_incoherent_squad := -1
	for squad_id: int in game.state.squads:
		var squad_models: Array[int] = []
		for model_id: int in game.state.units:
			if int(game.state.units[model_id].get("squad", -1)) == squad_id and int(game.state.units[model_id].get("wounds", 0)) > 0: squad_models.append(model_id)
		if squad_models.size() >= 2:
			guided_incoherent_squad = squad_id
			game.state.units[squad_models[0]].position = Vector2(-20, -20)
			game.state.units[squad_models[1]].position = Vector2(20, 20)
			game.state.active = int(game.state.squads[squad_id].get("owner", 1))
			break
	check(guided_incoherent_squad != -1, "Guided coherency fixture has a multi-model unit")
	game._refresh_first_session_guide()
	check("Remove selected model for coherency" in game.first_session_guide.text and "coherency" in game.first_session_boundary.text.to_lower(), "End-turn guidance names the required coherency casualty choice")
	show_step(game, "command", "FIRST TURN COMPLETE", 2)
	check(game.first_session_progress.value == 10, "Completed first turn fills the progress track")
	game.state.turn = 1
	game.state.phase = "charge"
	game.state.test_winner = 1
	game._refresh_first_session_guide()
	check(game.first_session_heading.text == "MATCH ENDED" and game.first_session_progress.value == 8, "An early match ending does not claim the first-turn steps were completed")
	game._start_guided_first_session()
	check(game.state.get("training_points", {}) == {1: 290, 2: 235}, "The initial training uses distinct current-catalog forces")
	check(game.core_stratagems and game.combat_doctrines and not game.awakened_dynasty and not game.reanimation_protocols, "Tactical training enables Marine choices without historical Necron options")
	# The former mirror remains independently selectable for its Homer regression.
	for owner: int in [1, 2]:
		var picker: OptionButton = game.saved_army_pickers[owner]
		for index in range(picker.item_count):
			if picker.get_item_metadata(index).get("id", "") == "reference:core-v2:Space Marines": picker.select(index)
	game._start_saved_match()
	game.guided_first_session = true
	game._dismiss_home(1)
	game.state.phase = "start_turn"
	game.state.turn = 1
	game.state.first_player = 1
	game.state.active = 1
	game.state.unit_abilities.setup_players = [1, 2]
	game.state.unit_abilities.battle_players = []
	game.combat_enabled = true
	game._refresh()
	check(Combat.UnitActions.battle_actor(game.state) == 1, "Guided battle-start choices are available for the acting player")
	check("STEP 4 OF 10" in game.first_session_heading.text and "Teleport Homer" in game.first_session_guide.text and "X/Z" in game.first_session_guide.text and "skip" in game.first_session_guide.text.to_lower(), "Step 4 explains the optional marker, its controls and how to skip it")
	check(game.action_groups.unit.container.get_child(0).text == "Start-of-battle choices", "The Command panel names the battle-start task directly")
	var selected_choice: Variant = game.unit_action_picker.get_selected_metadata() if game.unit_action_picker.selected >= 0 else null
	check(selected_choice is Dictionary and selected_choice.get("action", "") == "homer" and game.unit_action_x.visible and game.unit_action_z.visible, "The optional Homer placement is highlighted before the finish option")
	check(game.unit_action_x.prefix == "Homer X: " and game.unit_action_z.prefix == "Homer Z: ", "Position controls identify Homer coordinates instead of calling them abilities")
	check(game.end_button.disabled and game.end_button.text == "Finish start-of-battle choices first", "Phase progression stays unavailable until the battle-start choices are finished")
	print("Guided turn UI checks: %d failures" % failures)
	game.free()
	await process_frame
	quit(0 if failures == 0 else 1)
