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
	game._start_objectives()
	game._dismiss_home(1)
	game.state.phase = "movement"
	game.selected = -1
	game._refresh()
	check(game.action_unit_picker.visible and game.action_unit_picker.item_count == 2, "Movement lists the friendly living unit once, not one entry per model")
	check(game.begin_move_button.disabled and game.movement_choices.choices[0].disabled, "No unit selected cannot start movement")
	var before := var_to_str(game.state)
	game.action_unit_picker.item_selected.emit(1)
	check(game.selected == 100 and var_to_str(game.state) == before, "Unit picker selects a model without changing authoritative state")
	check(not game.movement_choices.choices[0].disabled and game.movement_choices.choices[2].disabled, "Unengaged unit offers Normal and blocks Fall Back")
	check("Only engaged" in game.movement_choices.choices[2].tooltip_text and "Only engaged" in game.movement_reference.text, "Blocked choice explains the validator restriction in tooltip and Help")
	game.movement_choices.choices[1].pressed.emit()
	check(game.movement_choice.selected == 1 and game.state.pending_move.is_empty() and var_to_str(game.state) == before, "Choosing Advance does not roll dice or start movement")
	game.movement_choices.choices[0].pressed.emit()
	check(game.Combat.begin_movement(game.state, 1, 100, "normal", game.state.revision).is_empty(), "Begin normal movement through existing validator")
	game._refresh()
	check(not game.action_unit_picker.visible and not game.movement_choices.grid.visible and game.finish_move_button.visible, "Pending placement hides unrelated unit and move choices while keeping confirmation")
	check("right-click" in game.movement_choices.instruction.text, "Placement gives the board interaction")
	check(game.Combat.finish_movement(game.state, 1, game.state.revision, false).is_empty(), "Confirm original coherent positions")
	game._refresh()
	check(game.action_unit_picker.is_item_disabled(1) and game.begin_move_button.disabled, "Completed unit cannot start another move")
	check(not game.movement_choices.grid.visible and not game.begin_move_button.visible and "Move complete" in game.decision_label.text, "Completed movement replaces stale choices with the next action")
	check("Move complete" in game.movement_choices.instruction.text and "✓ Confirm" in game.movement_choices.stages[3].text, "Completed flow does not regress to placement instructions")
	before = var_to_str(game.state)
	game.action_unit_picker.item_selected.emit(1)
	check(var_to_str(game.state) == before, "Disabled selection cannot commit an action")
	game._start_objectives()
	game.state.phase = "movement"
	game.selected = 100
	game.state.units[200].position = game.state.units[100].position + Vector2(1, 0)
	game._refresh()
	check(game.movement_choices.choices[0].disabled and not game.movement_choices.choices[2].disabled, "Engagement reverses Normal and Fall Back eligibility")
	game.state.squads[1].battle_shocked = true
	game._refresh()
	check(game.movement_choices.choices[2].disabled and not game.movement_choices.choices[3].disabled, "Battle-shock preserves distinct Fall Back restrictions")
	game.mode = "client"
	game._refresh()
	check(game.action_unit_picker.disabled and game.begin_move_button.disabled and "Waiting for player 1" in game.movement_choices.instruction.text, "Opponent movement remains non-actionable and identifies the actor")
	check(not game.action_unit_picker.visible and not game.movement_choices.visible and "Resolving movement" in game.decision_label.text, "Waiting presentation removes local movement choices and names the opponent decision")
	game.mode = "local"
	game._start_allocation_practice()
	game.selected = -1
	game._refresh()
	check(game.action_unit_picker.visible, "Ordinary shooting offers unit selection")
	game.action_unit_picker.item_selected.emit(1)
	check(not game.plan_begin.disabled, "Shooting selection enables planning through its validator")
	game._begin_attack_plan()
	check(not game.action_unit_picker.visible, "Draft editing keeps the attacking unit fixed")
	game.attack_draft = {}
	check(game.Combat.shoot(game.state, 1, 100, 200, 0, true, func(): return 6).error.is_empty(), "Reach a mandatory Precision decision")
	game._refresh()
	check(game.action_groups.defense.container.visible and not game.action_unit_picker.visible and not game.action_groups.movement.container.visible, "Mandatory defense suppresses the ordinary selection and movement workflow")
	print("Turn choice UI checks: %d failures" % failures)
	quit(0 if failures == 0 else 1)
