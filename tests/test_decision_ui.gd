extends SceneTree

var failures := 0
var dice: Array = [6, 6, 6, 6, 3, 3, 6, 6]
func roll() -> int: return dice.pop_front() if not dice.is_empty() else 1
func three() -> int: return 3
func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1
func _initialize() -> void: call_deferred("run")

func run() -> void:
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	game._start_allocation_practice()
	game._dismiss_home(1)
	game.selected = -1
	check(game.Combat.shoot(game.state, 1, 100, 200, 0, true, roll).error.is_empty(), "Enter Precision")
	game._refresh()
	check(game.allocate_button.text == "Confirm Precision" and game.precision_skip.visible and not game.selection_card.get_parent().visible, "Precision exposes Confirm/Skip without a redundant empty inspection card")
	check(not game.action_groups.defense.reason.visible and not game.defense_reference.text.is_empty(), "Filtered recipient prompt retains its full explanation in Help")
	var before := var_to_str(game.state)
	var index: int = game.defense_picker.get_item_index(202)
	game.defense_picker.item_selected.emit(index)
	check(game.selected == 202 and not game.allocate_button.disabled and var_to_str(game.state) == before, "Defense selection remains local inspection only")
	game.mode = "client"
	game._refresh()
	check(game.defense_picker.disabled and not game.defense_picker.visible and not game.allocate_button.visible and not game.precision_skip.visible, "Inactive player sees no actionable defense controls")
	game.mode = "local"
	game.attack_reroll_choice.button_pressed = true
	game._start_prepared_match()
	game.state.phase = "shooting"
	game.state.deployment = {}
	game.state.cp = {1: 4, 2: 4}
	for id: int in game.state.units:
		game.state.units[id].position = Vector2(-12 if game.state.units[id].owner == 1 else -2, -8 + (id % 100) * 1.3)
	check(game.Combat.shoot(game.state, 1, 100, 200, game.state.revision, true, three).error.is_empty(), "Enter pending hit pool")
	game._refresh()
	check(game.reaction_dice.visible and game.reaction_die.item_count > 12 and "all dice in Help" in game.reaction_dice_hint.text, "Large pool retains every choice through Help and labels the visible limit")
	check("0 CP" in game.reaction_roll.text and "1 CP" in game.reaction_use.text and "must be kept" in game.reaction_help.text, "Decision exposes cost and mandatory replacement semantics")
	before = var_to_str(game.state)
	var rng_before: int = game.rng.state
	game.reaction_dice_buttons[1].pressed.emit()
	check(game.reaction_die.get_selected_id() == 1 and game.reaction_dice_buttons[1].button_pressed and not game.reaction_dice_buttons[0].button_pressed, "Clicking a die changes the shared replacement selection")
	check(var_to_str(game.state) == before and game.rng.state == rng_before, "Die selection spends no CP and consumes no RNG")
	var last: int = game.reaction_die.get_item_id(game.reaction_die.item_count - 1)
	game.reaction_die.select(game.reaction_die.get_item_index(last))
	game.reaction_die.item_selected.emit(game.reaction_die.selected)
	check(game.reaction_dice_buttons[last].visible and game.reaction_dice_buttons[last].button_pressed, "Choice outside the first twelve remains visibly selected")
	check(var_to_str(game.state) == before and game.rng.state == rng_before, "Help selection is also presentation only")
	game.mode = "client"
	game._refresh()
	check(not game.action_groups.reaction.container.visible and not game.reaction_die.visible, "Opponent reroll choices are hidden in Play and Help")
	game._select_reaction_die(0)
	check(game.reaction_die.get_selected_id() == last and game.reaction_dice_buttons[last].disabled and var_to_str(game.state) == before, "Inactive player cannot change the replacement selection")
	game.mode = "local"
	game.state.cp[1] = 0
	game._refresh()
	check(game.reaction_use.disabled and not game.reaction_roll.disabled and "unavailable" in game.reaction_help.text, "No CP blocks reroll but leaves the free Keep action")
	game._start_objectives()
	game.Combat.Stratagems.enable(game.state, true)
	game.state.phase = "charge"
	game.state.cp = {1: 4, 2: 4}
	for id: int in game.state.units:
		if id not in [100, 200]: game.state.units[id].wounds = 0
	game.state.units[100].position = Vector2(-8, -8)
	game.state.units[200].position = Vector2(-3, -8)
	check(game.Combat.declare_charge(game.state, 1, 100, game.state.revision, three).error.is_empty(), "Enter charge dice decision")
	game._refresh()
	check(not game.reaction_die.visible and game.reaction_dice_buttons[0].disabled and "both D6" in game.reaction_dice_hint.text, "Charge displays its dice without offering an individual-die replacement")
	game._start_objectives()
	check(not game.reaction_dice.visible and not game.reaction_reference.visible and not game.defense_reference.visible, "Closing the window removes stale reaction/defense UI")
	print("Defense/reaction UI checks: %d failures" % failures)
	quit(0 if failures == 0 else 1)
