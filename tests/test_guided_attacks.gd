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
	game._start_allocation_practice()
	var before := var_to_str(game.state)
	game._begin_attack_plan()
	check("Select → Assign → Review" in game.plan_steps.text and "0 assignments" in game.plan_steps.text and "4 • Review" in game.attack_reference.text, "Compact planner keeps full instructions accessible in Help without rolling dice")
	game._assign_attack()
	check("1 assignments" in game.plan_steps.text and "Synthetic mixed allocation group" in game.plan_summary.text and not game.plan_confirm.disabled, "Review names the target and assignment count")
	check(var_to_str(game.state) == before, "Editing and review do not mutate combat state")
	game.selected = 201
	game._refresh()
	check("Select a model from" in game.plan_steps.text and game.plan_add.disabled, "Wrong unit selection gives an explicit selection instruction")
	game.attack_draft = {}
	game.selected = -1
	check(game.Combat.shoot(game.state, 1, 100, 200, 0, true, roll).error.is_empty(), "Attack enters Precision")
	game._refresh()
	check("Optional Precision" in game.defense_steps.text and game.defense_picker.item_count == 3 and game.defense_picker.get_item_id(0) == -1, "Precision offers a prompt and only the two visible eligible characters")
	before = var_to_str(game.state)
	var pick: int = game.defense_picker.get_item_index(202)
	game.defense_picker.item_selected.emit(pick)
	check(game.selected == 202 and "Model 202" in game.defense_picker.get_item_text(game.defense_picker.selected) and not game.allocate_button.disabled, "Dropdown selection updates board selection and its visible model label")
	check(var_to_str(game.state) == before, "Choosing an eligible model does not commit a decision")
	game.defense_picker.item_selected.emit(0)
	check(game.selected == -1 and game.allocate_button.disabled and var_to_str(game.state) == before, "Returning to the prompt clears selection without declining Precision")
	check(game.Combat.allocate_damage(game.state, 1, -1, game.state.revision, roll).is_empty(), "Explicit Precision decline")
	game._refresh()
	check("Defense group order" in game.defense_steps.text and "before saves" in game.defense_steps.text, "Defensive order explains save timing")
	game.mode = "host"
	game.guest_id = 2
	game._refresh()
	check(game.defense_picker.disabled and "Player 2 decides" in game.defense_steps.text, "Opponent decision is named and cannot be edited locally")
	game.mode = "local"
	game._start_objectives()
	check(not game.defense_steps.visible and not game.defense_picker.visible, "Completed pending state hides old defense guidance")
	print("Guided attack/defense checks: %d failures" % failures)
	quit(0 if failures == 0 else 1)
