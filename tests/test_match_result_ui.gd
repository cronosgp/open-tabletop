extends SceneTree

const Result = preload("res://scripts/match_result.gd")
const Restart = preload("res://scripts/match_restart.gd")
var failures := 0
func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1
func _initialize() -> void: call_deferred("run")

func finish(game, winner: int = 1) -> void:
	game.state.test_winner = winner
	game.state.round = 5
	game.state.phase = "end_turn"
	if game.state.get("mission", {}).has("scores"): game.state.mission.scores = {1: 18, 2: 12}
	game._refresh()

func run() -> void:
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	game._start_objectives()
	game._dismiss_home(1)
	check(not game.match_result_panel.visible and not game._rematch_local(), "Ongoing match cannot show a result or restart through rematch")
	check(Result.build(game.state).has("error"), "Summary requires a recorded final result")
	var initial := var_to_str(game.state)
	var config: Dictionary = game._save_config().duplicate(true)
	finish(game)
	check(game.match_result_panel.visible and "PLAYER 1 WINS" == game.match_result_panel.title.text and "18 VP" in game.match_result_panel.scores.text, "Result card uses the recorded winner and scores")
	check(not game.action_groups.phase.container.visible and not game.selection_card.get_parent().visible and game.combat_hud.round_label.text == "Result", "Finished presentation removes exhausted actions and the active-phase marker")
	var snapshot := var_to_str(game.state)
	var record := Result.build(game.state, game.journal.checkpoint())
	var again := Result.build(game.state, game.journal.checkpoint())
	check(record == again and var_to_str(game.state) == snapshot, "Reading the result is deterministic and does not change match state")
	game.state.seat_token = "do-not-export"
	check(not "do-not-export" in JSON.stringify(Result.build(game.state)), "Result export whitelists summary fields rather than copying state credentials")
	game.state.erase("seat_token")
	var saved: Dictionary = game._save_final_result("user://result-ui-tests")
	check(saved.error.is_empty() and FileAccess.file_exists(saved.get("path", "")), "Save writes a local result file")
	check(game.match_result_panel.folder_button.visible and not saved.get("path", "") in game.match_result_panel.notice.text, "Save feedback stays compact and provides the folder action")
	if saved.error.is_empty():
		var loaded: Variant = JSON.parse_string(FileAccess.get_file_as_string(saved.path))
		check(loaded is Dictionary and loaded.winner == 1 and loaded.scores.P1 == 18 and loaded.id == record.id, "Saved result retains winner, score and identifier")
		check(game._save_final_result("user://result-ui-tests").error.is_empty(), "Saving the same result again is idempotent")
	game._save_match()
	game._load_match(false)
	check(game.resume_succeeded and game.state.test_winner == 1 and game.match_result_panel.visible and var_to_str(game.state) == snapshot, "Resuming a finished save restores the result card without changing the recorded match")
	var blocker := FileAccess.open("user://result-ui-blocker", FileAccess.WRITE)
	blocker.store_string("file, not a directory")
	blocker.close()
	check(not game._rematch_local("user://result-ui-blocker") and var_to_str(game.state) == snapshot, "Save failure keeps the completed match intact")
	game.mode = "host"
	game._refresh()
	check(game.match_result_panel.rematch_button.disabled and not game._rematch_local() and var_to_str(game.state) == snapshot, "Host cannot silently start a local replacement for a LAN game")
	game.mode = "local"
	game.defender_choice.button_pressed = not game.defender_choice.button_pressed
	check(game._rematch_local("user://result-ui-tests"), "Local rematch starts after preserving the result")
	check(var_to_str(game.state) == initial and game._save_config() == config and game.attack_draft.is_empty(), "Rematch restores the same fresh scenario/options instead of edited menu controls")
	check(not game.match_result_panel.visible and game.journal.entries.is_empty() and game.journal.pending_dice.is_empty(), "New match has fresh presentation and history")
	game._start_guided_first_session()
	check(game.saved_army_mode and game.state.has("saved_army_setup"), "Guided sample provides a saved-army setup")
	check(game.guided_first_session and not game.checked_rosters_choice.button_pressed and not game.official_mission_choice.button_pressed, "Guided sample starts from current local profiles without the legacy roster check or incompatible CA mission")
	var guided_armies: Dictionary = game.state.saved_army_setup.get("armies", {})
	check(guided_armies.size() == 2 and guided_armies[1].faction == "Space Marines" and guided_armies[2].faction == "Space Marines" and game.state.training_points == {1: 290, 2: 235}, "Initial tactical training uses the two distinct current Marine forces")
	game._open_home()
	game._menu_start_guided()
	check(not game.main_menu.visible and game.guided_first_session and game.combat_enabled, "Title-screen guided launch closes the menu after its local match starts")
	var setup: Dictionary = game.state.get("saved_army_setup", {}).duplicate(true)
	var pack_hash: String = game.state.pack_hash
	finish(game, -1)
	check(game.match_result_panel.title.text == "DRAW", "Draw comes from the recorded result, not a recalculation from displayed VP")
	var fresh := Restart.build(game._save_config(), game.state)
	check(not fresh.has("error") and fresh.get("saved_army_setup") == setup and fresh.get("pack_hash") == pack_hash and fresh.get("test_winner") == 0, "Saved-army rematch re-admits the same lists and resets the outcome")
	var changed: Dictionary = game.state.duplicate(true)
	changed.pack_hash = "different"
	check(Restart.build(game._save_config(), changed).has("error"), "Changed rules-pack identity blocks rematch")
	game._start_allocation_practice()
	finish(game)
	check(game.match_result_panel.rematch_button.text == "Restart this lab" and not Restart.build(game._save_config(), game.state).has("error"), "Synthetic restart is labeled as a lab and uses its original builder")
	print("Match result/rematch UI checks: %d failures" % failures)
	quit(0 if failures == 0 else 1)
