extends SceneTree
var failures := 0
func six() -> int: return 6
func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	game._start_allocation_practice()
	check(not game.event_log.visible and not game.result_summary.visible and game.log_toggle.visible, "Detailed history starts collapsed; no result is invented before an attack")
	check(game.status.get_index() < game.selection_card.get_index(), "Latest notice appears before selection and action controls")
	check(game.Combat.shoot(game.state, 1, 100, 200, 0, true, six).error.is_empty(), "Start synthetic attack")
	game._refresh()
	check(not game.result_summary.visible and not game.event_log.visible and game.defense_steps.visible, "Pending attack keeps mandatory guidance without exposing a completed result")
	var steps := 0
	while not game.state.pending_attack.is_empty() and steps < 100:
		var current: Dictionary = game.state.pending_attack.current
		var eligible: Array[int] = game.Combat.Allocation.eligible(game.state)
		var choice: int = -1 if current.phase == "precision" else eligible[0]
		check(game.Combat.allocate_damage(game.state, game.Combat.actor(game.state), choice, game.state.revision, six).is_empty(), "Resolve required allocation")
		steps += 1
	check(game.state.has("last_attack"), "Attack finishes before summarizing")
	game._refresh()
	check(game.result_summary.visible and "Last completed attack" in game.result_summary.text and "Synthetic mixed allocation group" in game.result_summary.text, "Result names the completed attack and defending unit")
	check("damage applied" in game.result_summary.text and "Feel No Pain" in game.result_summary.text and "Excess damage" in game.result_summary.text, "Summary separates damage, prevention and excess")
	check(not "Dice:" in game.result_summary.text and "Dice:" in game.event_log.text and not game.event_log.visible, "Raw dice remain available only in detailed history")
	var before := var_to_str(game.state)
	game.log_toggle.button_pressed = true
	check(game.event_log.visible, "History expands on request")
	game._refresh()
	check(game.event_log.visible and var_to_str(game.state) == before, "Expansion survives refresh without altering rules state")
	for index in range(80): game.state.events.append({"message": "History line %d" % index})
	game._refresh()
	for frame in range(4): await process_frame
	var scroll: VScrollBar = game.event_log.get_v_scroll_bar()
	scroll.value = scroll.max_value * 0.25
	var old_scroll := scroll.value
	game._refresh()
	for frame in range(4): await process_frame
	check(is_equal_approx(scroll.value, old_scroll), "Unchanged history preserves the reader's scroll position")
	game.log_toggle.button_pressed = false
	game.state.pending_attack = {"ui_test": true}
	game._refresh_result_summary()
	check("another attack is pending" in game.result_summary.text, "Previous result is clearly identified during another attack")
	game.state.pending_attack = {}
	game.state.last_attack.hazardous = {"total": 3, "prevention": [{"lost": 1, "prevented": 1}], "discarded": 1}
	game._refresh_result_summary()
	check("Hazardous (attacking unit): 1 wounds lost • 1 prevented" in game.result_summary.text and "1 unallocated wounds discarded" in game.result_summary.text, "Hazardous self-damage and prevention remain separate from defender damage")
	game._toggle_combat()
	check(not game.result_summary.visible and not game.log_toggle.visible and not game.event_log.visible, "Returning to preview hides old combat results")
	print("Combat results UI checks: %d failures" % failures)
	quit(0 if failures == 0 else 1)
