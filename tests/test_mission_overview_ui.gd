extends SceneTree

const C = preload("res://scripts/edition_11/combat_scenario.gd")

var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	if game.main_menu.first_run_model_setup != null:
		game._skip_first_run_model_setup()
	game._start_allocation_practice()
	game._dismiss_home(1)
	game._open_mission_overview()
	var view = game.mission_overview_view
	var original := var_to_bytes(game.state)
	check(game.tactical_overlay.visible and view.mission_title.text == "Custom objective training", "Mission opens on the structured objective training dashboard")
	check(view.score_cards[0].total_label.text == "0 VP" and view.score_cards[1].total_label.text == "0 VP", "Both player scores are shown as separate cards")
	check(view.objective_cards.size() == game.state.mission.objectives.size() and view.objective_cards.size() > 0, "Every current objective receives a card")
	check("Latest resolved control" in view.objective_cards[0].control_label.text and "P1 OC" in view.objective_cards[0].p1_label.text and "P2 OC" in view.objective_cards[0].p2_label.text, "Objective cards identify stored control and both OC totals")
	check(view.objective_cards[0].focus_button.visible, "An objective with board bounds offers camera focus")
	check("next relevant phase boundary" in view.timing_note.text, "The screen explains that objective control is the latest resolved value")
	check(original == var_to_bytes(game.state), "Opening the dashboard does not change match state")
	var no_location: Dictionary = game._mission_overview_view_model()
	var objective_row: Dictionary = no_location.objectives[0]
	objective_row.focus_available = false
	no_location.objectives[0] = objective_row
	view.present(no_location)
	check(not view.objective_cards[0].focus_button.visible, "Objectives without a board location do not offer focus")
	view.present(game._mission_overview_view_model())
	original = var_to_bytes(game.state)
	view.objective_cards[0].focus_button.pressed.emit()
	for frame in 4: await process_frame
	check(not game.tactical_overlay.visible and original == var_to_bytes(game.state), "Focus closes the Mission screen and moves only the camera")
	view.present({"title":"Mission status", "subtitle":"No scoring", "show_scores":false, "scores":[], "details":[], "objectives":[], "history":[]})
	check(not view.score_row.visible and view.empty_objectives.visible, "Exercises without objective scoring show an explicit empty state")
	check("No scoring event" in view.history_list.get_child(0).text, "An empty history has a readable message")
	var training_state: Dictionary = game.state
	var official_state: Dictionary = C.initial_state(C.Terrain.DEFAULT_LAYOUT, "elimination")
	C.Mission.enable(official_state)
	official_state.mission.scores = {1: 8, 2: 4}
	official_state.mission.primary = {1: 5, 2: 3}
	official_state.mission.secondary = {1: 3, 2: 1}
	official_state.mission.cards[1][official_state.mission.secondary_cards[0]] = 2
	official_state.mission.cards[2][official_state.mission.secondary_cards[0]] = 1
	official_state.mission.objectives[0].controller = 2
	official_state.mission.objectives[0].levels = {1: 2, 2: 4}
	official_state.mission.log = ["Player 1 scored 3 VP at the end of Round 1."]
	game.state = official_state
	view.present(game._mission_overview_view_model())
	check(view.mission_title.text == "Battlefield Dominance" and view.score_cards[0].total_label.text == "8 VP", "The official mission name and total score come from the match snapshot")
	check("Primary 5 VP" in view.score_cards[0].breakdown_label.text and "Secondaries 3 VP" in view.score_cards[0].breakdown_label.text, "Primary and secondary score components stay separate")
	check("Engage on All Fronts" in view.score_cards[0].details_label.text and "Latest resolved control  ·  Controlled by Player 2" in view.objective_cards[0].control_label.text, "Selected secondary cards and stored objective control are exposed")
	check("3 VP" in view.history_list.get_child(0).text, "Recent mission scoring history is shown")
	game.state = training_state
	print("Mission overview UI checks: %d failures" % failures)
	game.queue_free()
	await process_frame
	quit(0 if failures == 0 else 1)
