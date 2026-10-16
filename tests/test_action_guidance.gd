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
	game.selected = -1
	game._refresh()
	check(game.plan_begin.disabled and "Select your living attacker" in game.action_groups.attack.reason.text, "Unavailable planning explains the actual validator error")
	check(not game.action_groups.movement.container.visible and game.action_groups.attack.container.visible, "Shooting hides movement controls as a group")
	game.selected = 100
	game._refresh()
	check(not game.plan_begin.disabled and not game.action_groups.attack.reason.visible, "Valid selection clears stale blocking explanation")
	game._begin_attack_plan()
	check(game.action_groups.attack.container.visible and not game.action_groups.phase.container.visible and not game.action_groups.objectives.container.visible, "Editing a plan focuses its controls and retains cancellation")
	check(game.plan_cancel.is_visible_in_tree() and "Cannot confirm" in game.action_groups.attack.reason.text, "Incomplete plan reports why confirmation is blocked")
	game._assign_attack()
	check(not game.plan_confirm.disabled and not game.action_groups.attack.reason.visible, "Complete plan clears confirmation error")
	game.attack_draft = {}
	game._refresh()
	var before := var_to_str(game.state)
	game._refresh_action_groups()
	check(var_to_str(game.state) == before, "Guidance does not mutate gameplay state")
	check(game.Combat.shoot(game.state, 1, 100, 200, 0, true, roll).error.is_empty(), "Synthetic attack reaches Precision decision")
	game.selected = -1
	game._refresh()
	check(game.action_groups.defense.container.visible and not game.action_groups.attack.container.visible and not game.action_groups.phase.container.visible, "Mandatory allocation hides competing actions")
	check(game.precision_skip.is_visible_in_tree() and game.allocate_button.disabled and not game.action_groups.defense.reason.text.is_empty(), "Precision decline remains visible alongside recipient guidance")
	check(game.Combat.allocate_damage(game.state, 1, -1, game.state.revision, roll).is_empty(), "Decline Precision")
	game.mode = "host"
	game.guest_id = 2
	game._refresh()
	check("Waiting for player 2" in game.action_groups.defense.reason.text, "Opponent-owned decisions name the responsible player")
	game.mode = "local"
	game._start_objectives()
	game.state.phase = "movement"
	game._refresh()
	check(game.begin_move_button.disabled and "Select" in game.action_groups.movement.reason.text, "Movement exposes its rule validator reason")
	game.state.phase = "charge"
	game.selected = 100
	game.state.squads[1].advanced = true
	game._refresh()
	check(game.charge_button.disabled and "Advanced" in game.action_groups.contact.reason.text, "Charge explains Advance restriction")
	print("Contextual action guidance: %d failures" % failures)
	quit(0 if failures == 0 else 1)
