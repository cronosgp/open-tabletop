extends SceneTree
var failures := 0
func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	game.state = game.PreparedTraining.initial_state({"unit_abilities": true})
	game.combat_enabled = true
	game._reset_history()
	game._spawn_pieces()
	game._dismiss_home(1)
	game._refresh()
	var before := var_to_str(game.state)
	check(game.unit_details_button.visible and game.unit_action_help.text == "Choose an option, then Confirm choice.", "Setup shows compact immediate instruction")
	var choice: Dictionary = game.unit_action_picker.get_selected_metadata()
	check(str(choice.label) in game.unit_choice_reference.text and "Pending phase/setup" in game.unit_choice_reference.text, "Help preserves full choice and original explanation")
	var reference: String = game.unit_choice_reference.text
	game._refresh_unit_actions()
	check(game.unit_choice_reference.text == reference, "Repeated refresh does not duplicate tooltip text")
	game.unit_details_button.pressed.emit()
	check(game.match_tabs.current_tab == 6 and var_to_str(game.state) == before, "Reading Help does not confirm the choice or alter rules")
	game.match_tabs.current_tab = 1
	game._start_objectives()
	game._refresh()
	check(not game.unit_details_button.visible and not game.unit_choice_reference.visible and game.unit_choice_reference.text.is_empty(), "No choices clears stale reference and controls")
	print("Unit choice Help checks: %d failures" % failures)
	quit(0 if failures == 0 else 1)
