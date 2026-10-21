extends SceneTree

var failures := 0
func three() -> int: return 3
func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1
func _initialize() -> void: call_deferred("run")

func fixture(game) -> void:
	game.mode = "local"
	game._start_objectives()
	game._dismiss_home(1)
	for id: int in game.state.units:
		if id not in [100, 200]: game.state.units[id].wounds = 0
	game.state.phase = "charge"
	game.state.units[100].position = Vector2(-8, -8)
	game.state.units[200].position = Vector2(-3, -8)
	game.selected = -1
	game._refresh()

func run() -> void:
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	fixture(game)
	check(game.action_unit_picker.visible and game.charge_button.disabled, "Charge starts with explicit unit selection")
	var before := var_to_str(game.state)
	game.action_unit_picker.item_selected.emit(1)
	check(game.selected == 100 and not game.charge_button.disabled and var_to_str(game.state) == before, "Charge unit selection neither rolls dice nor mutates state")
	game.state.units[200].position = Vector2(10, 8)
	game._refresh()
	check(game.charge_button.disabled and "12 inches" in game.action_groups.contact.reason.text and game.action_unit_picker.is_item_disabled(1), "Out-of-range declaration uses the command's read-only eligibility")
	game.state.units[200].position = Vector2(-3, -8)
	check(game.Combat.declare_charge(game.state, 1, 100, game.state.revision, three).error.is_empty(), "Open target selection after charge roll")
	game._refresh()
	check(game.charge_targets.visible and game.charge_target_buttons.has(2) and not game.charge_target_buttons[2].disabled, "Rolled charge exposes available enemy units")
	check(not game.action_groups.phase.container.visible and not game.action_unit_picker.visible and game.begin_contact_button.disabled, "Unresolved charge keeps target choice exclusive")
	before = var_to_str(game.state)
	game._refresh()
	check(var_to_str(game.state) == before and game.state.pending_charge.targets.is_empty(), "Refresh does not choose targets or alter dice")
	var rolls: Array = game.state.pending_charge.rolls.duplicate()
	game.charge_target_buttons[2].toggled.emit(true)
	check(game.state.pending_charge.targets == [2] and game.charge_target_buttons[2].button_pressed and not game.begin_contact_button.disabled, "Target toggle dispatches the existing selection command")
	game.charge_target_buttons[2].toggled.emit(false)
	check(game.state.pending_charge.targets.is_empty() and game.state.pending_charge.rolls == rolls, "Target can be removed without granting another roll")
	game.charge_target_buttons[2].toggled.emit(true)
	check(game.Combat.begin_contact_move(game.state, 1, 100, "charge", game.state.revision).is_empty(), "Begin charge placement")
	before = var_to_str(game.state)
	game._refresh()
	check(var_to_str(game.state) == before and game.confirm_contact_button.disabled and game.action_groups.contact.reason.visible, "Invalid preview reports the final validator reason without mutating state")
	check(not game.charge_targets.visible and not game.charge_button.visible and game.cancel_contact_button.visible, "Placement shows confirmation/cancel instead of target/roll controls")
	check(game.Combat.stage_contact_move(game.state, 1, 100, Vector2(-4.4, -8), game.state.revision).is_empty(), "Place model within rolled charge")
	game._refresh()
	check(not game.confirm_contact_button.disabled and "Preview valid" in game.contact_flow.instruction.text, "Legal preview enables confirmation")
	check(game.Combat.finish_contact_move(game.state, 1, game.state.revision).is_empty(), "Confirm charge")
	check(game.Combat.advance_phase(game.state, 1, game.state.revision).is_empty(), "Enter Fight")
	game._refresh()
	check(game.action_unit_picker.visible and not game.plan_begin.visible and "Pile-in" in game.contact_flow.labels[1].text, "Pile-in has a unit selector and hides premature attack planning")
	check(game.Combat.advance_phase(game.state, 1, game.state.revision).is_empty(), "Decline first optional pile-in")
	check(game.Combat.advance_phase(game.state, 2, game.state.revision).is_empty(), "Decline second optional pile-in")
	game._refresh()
	check(game.state.fight_step == "attacks" and game.plan_begin.visible and "Plan attacks" in game.contact_flow.instruction.text, "Fight attacks explicitly lead to the planner")
	check(not game.action_groups.phase.container.visible and not game.begin_contact_button.visible, "Required melee planning hides redundant progression and ineligible overrun controls")
	game._begin_attack_plan()
	check(not game.action_unit_picker.visible, "Attack draft keeps unit selection fixed")
	game.attack_draft = {}
	fixture(game)
	game.state.squads[3] = game.state.squads[2].duplicate(true)
	game.state.units[201].squad = 3
	game.state.units[201].wounds = 1
	game.state.units[201].position = Vector2(-3, -6)
	game.selected = 100
	game.Combat.declare_charge(game.state, 1, 100, game.state.revision, three)
	game._refresh()
	game.charge_target_buttons[2].toggled.emit(true)
	game.charge_target_buttons[3].toggled.emit(true)
	check(game.state.pending_charge.targets == [2, 3] and game.charge_target_buttons[2].button_pressed and game.charge_target_buttons[3].button_pressed, "Target list preserves multiple simultaneous charge targets")
	game.charge_target_buttons[2].toggled.emit(false)
	check(game.state.pending_charge.targets == [3] and game.state.pending_charge.maximum == 6, "Removing one target preserves the other selection and original roll")
	fixture(game)
	game.selected = 100
	game.Combat.declare_charge(game.state, 1, 100, game.state.revision, three)
	game.mode = "client"
	game._refresh()
	before = var_to_str(game.state)
	game._request_charge_target(200)
	check(not game.charge_targets.visible and var_to_str(game.state) == before and "Waiting for player 1" in game.decision_label.text, "Inactive client cannot dispatch a target choice")
	fixture(game)
	game.selected = 100
	game.Combat.Stratagems.enable(game.state, true)
	game.state.cp = {1: 4, 2: 4}
	game.Combat.declare_charge(game.state, 1, 100, game.state.revision, three)
	game._refresh()
	check(not game.Combat.Stratagems.pending(game.state).is_empty() and game.action_groups.reaction.container.visible and not game.contact_flow.visible and not game.action_unit_picker.visible, "Charge dice reaction takes priority over ordinary contact flow")
	print("Contact flow UI checks: %d failures" % failures)
	quit(0 if failures == 0 else 1)
