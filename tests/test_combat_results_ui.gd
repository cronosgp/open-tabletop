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
	check(game.status.get_index() < game.action_groups.attack.container.get_index() and game.army_card_host.is_ancestor_of(game.selection_card), "The notice precedes attack controls and selection belongs to the roster inspector")
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
	check(game.result_summary.visible and "Firing models:" not in game.result_summary.text and "Synthetic mixed allocation group" in game.result_summary.tooltip_text, "Compact result omits repeated firing-model lists and retains the full completed attack record")
	check(game.shooting_complete.visible and not game.plan_begin.visible and not game.lethal_choice.visible, "Completed shooting replaces stale attack controls")
	check(game.action_unit_picker.visible and "Shooting complete for this unit" in game.decision_label.text, "Completion preserves selection and names the next step in the HUD")
	check("damage applied" in game.result_summary.tooltip_text and "Feel No Pain" in game.result_summary.tooltip_text and "Excess damage" in game.result_summary.tooltip_text and "Excess damage discarded" in game.result_summary.text, "Full result separates damage, prevention and excess")
	check(not game.dice_visual.visible and game.dice_toggle.visible and "Dice:" in game.event_log.text and not game.event_log.visible, "Raw dice remain collapsed until requested")
	game.dice_toggle.button_pressed = true
	check(game.dice_visual.visible, "Resolved dice expand on request")
	game._fit_command_panel()
	var rail_width: float = game.command_panel.size.x
	var content_width: float = game.command_panel_body.get_combined_minimum_size().x
	check(rail_width <= 420.0 and game.dice_visual_rolls.custom_minimum_size.x <= rail_width and game.event_log.custom_minimum_size.x <= rail_width and content_width <= rail_width + 1.0, "Recorded dice and combat history fit the command rail (content %.1f, rail %.1f)" % [content_width, rail_width])
	game.dice_animation_toggle.button_pressed = false
	game.dice_visual_signature = ""
	game._refresh_dice_visual(game.state.last_attack)
	var readable_tiles := 0
	for child in game.dice_visual_rolls.get_children():
		if not child is PanelContainer: continue
		var caption: Label = child.get_child(0).get_child(0)
		readable_tiles += 1
		check(child.custom_minimum_size.x <= rail_width and caption.text_overrun_behavior == TextServer.OVERRUN_NO_TRIMMING and not caption.text.contains("…"), "A recorded die keeps its full caption inside the command rail")
	check(readable_tiles > 0, "The expanded attack shows its recorded dice")
	game.dice_toggle.button_pressed = false
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
	check("another attack is pending" in game.result_summary.tooltip_text and "Another attack is still pending" in game.result_summary.text, "Previous result is clearly identified during another attack")
	game.state.pending_attack = {}
	game.state.last_attack.hazardous = {"total": 3, "prevention": [{"lost": 1, "prevented": 1}], "discarded": 1}
	game.combat_tray.signature = ""
	game._refresh_result_summary()
	check("Hazardous (attacking unit): 1 wounds lost • 1 prevented" in game.result_summary.tooltip_text and "1 unallocated wounds discarded" in game.result_summary.tooltip_text and "1 unallocated wounds discarded" in game.result_summary.text and "1 unallocated wounds discarded" in game.combat_tray.summary.text, "Hazardous self-damage and prevention remain separate from defender damage")
	var range_note := "Movement range remains available while this card stays beside the board. ".repeat(6).strip_edges()
	game.guide_label.text = range_note
	game._layout_ui()
	check(game.guide_panel.size.x <= 280.5 and game.guide_label.custom_minimum_size.x == 0.0 and game.guide_label.text == range_note and game.guide_label.get_parent() is ScrollContainer and game.guide_label.text_overrun_behavior == TextServer.OVERRUN_NO_TRIMMING, "The range card wraps inside a bounded board card (width %.1f)" % game.guide_panel.size.x)
	var notice := "Deployment was rejected because the model would end out of coherency with the rest of its unit. The preview is still on the board."
	game.status.text = notice
	game._refresh()
	check(game.status.text == notice and game.status.max_lines_visible < 0 and game.status.text_overrun_behavior == TextServer.OVERRUN_NO_TRIMMING and not game.status.text.contains("…"), "A long match notice stays complete in the command rail")
	game._toggle_combat()
	check(not game.result_summary.visible and not game.log_toggle.visible and not game.event_log.visible, "Returning to preview hides old combat results")
	print("Combat results UI checks: %d failures" % failures)
	quit(0 if failures == 0 else 1)
