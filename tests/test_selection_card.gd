extends SceneTree
var failures := 0
var dice: Array = [6, 6, 6, 6, 3, 3, 6, 6]
func roll() -> int: return dice.pop_front() if not dice.is_empty() else 1
func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	check("No model selected" in game.selection_card.text and not game.details.visible, "Initial view is compact")
	game._start_allocation_practice()
	check("Intercessor" in game.selection_card.text and "W 2/2" in game.selection_card.text, "Selected unit and model wounds are visible")
	check("models alive" not in game.selection_card.text and "P1" not in game.selection_card.text, "Compact card omits repeated owner and living-count information")
	check(not game.selection_stats.visible, "Selection footer leaves combat characteristics in the full datasheet")
	check(game.army_card_host.get_index() > game.army_roster.get_parent().get_index(), "Selection footer sits below the scrollable roster")
	for phase: String in ["command", "movement", "shooting", "charge", "fight", "end_turn"]:
		var previous_phase: String = game.state.phase
		game.state.phase = phase
		game._refresh_command_panel_title()
		check(game.command_panel_title.text == phase.replace("_", " ").to_upper().replace("END TURN", "END OF TURN"), "Action heading follows phase: " + phase)
		game.state.phase = previous_phase
	game._refresh_command_panel_title()
	var card_state := var_to_str(game.state)
	game.datasheet_button.pressed.emit()
	check(game.tactical_overlay_content == game.datasheet_details and not game.datasheet_view.last_model.ranged.is_empty() and not game.datasheet_view.last_model.melee.is_empty(), "Datasheet opens structured ranged and melee profiles in the full inspector")
	check(var_to_str(game.state) == card_state, "Opening the datasheet is read-only")
	game._close_tactical_screen()
	check(not game.datasheet_details.visible and game.state.units.has(game.selected), "Closing datasheet preserves selection and clears the overlay")
	check(not "Equipped profiles" in game.selection_card.text and "Equipped profiles" in game.details.text, "Equipment remains in expandable detail")
	game.technical_toggle.button_pressed = true
	check(game.details.visible, "Details can be expanded")
	game.selected = 201
	game._refresh()
	check(game.details.visible and "Feel No Pain" in game.details.text and "Synthetic mixed allocation group" in game.selection_card.text, "Refresh preserves expansion and keeps FNP in technical details")
	game.technical_toggle.button_pressed = false
	check(game.Combat.shoot(game.state, 1, 100, 200, 0, true, roll).error.is_empty(), "Attack reaches Precision")
	game._refresh()
	check(game.decision_details.visible and "Precision" in game.decision_details.text and not game.details.visible, "Required choices stay visible with technical details collapsed")
	check(game.Combat.allocate_damage(game.state, 1, -1, game.state.revision, roll).is_empty(), "Decline Precision")
	game._refresh()
	check("Groups ordered" in game.decision_details.text and "Sv" in game.decision_details.text, "Group order and defensive profiles are not hidden")
	var before := var_to_str(game.state)
	game._refresh_selection_card()
	check(var_to_str(game.state) == before, "Selection card does not change combat state")
	game.selected = 99999
	game._refresh()
	check("No model selected" in game.selection_card.text, "Stale selection clears the card")
	game.selected = 201
	game.state.units[201].wounds = 0
	game._refresh_selection_card()
	check("Destroyed" in game.selection_card.text, "Destroyed model is explicitly identified")
	print("Selection card checks: %d failures" % failures)
	quit(0 if failures == 0 else 1)
