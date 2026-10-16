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
	check(game.match_tabs.current_tab == 0, "Preview opens match setup")
	game._start_objectives()
	check(game.match_tabs.current_tab == 1, "Starting combat opens gameplay")
	check(game.objective_summary.visible and "VP 0 / 0" in game.objective_summary.text, "Training scoreboard visible outside scrolling details")
	game.match_tabs.current_tab = 0
	game._refresh()
	check(game.match_tabs.current_tab == 0, "Refreshing state preserves deliberately opened setup tab")
	game.match_tabs.current_tab = 1
	game.technical_toggle.button_pressed = true
	game.details.text += "\nLong selection details".repeat(80)
	for frame in range(5): await process_frame
	var header_position: Vector2 = game.decision_label.global_position
	var score_position: Vector2 = game.objective_summary.global_position
	game.gameplay_scroll.scroll_vertical = 10000
	for frame in range(5): await process_frame
	check(game.gameplay_scroll.scroll_vertical > 0, "Long gameplay details can scroll")
	check(game.decision_label.global_position == header_position and game.objective_summary.global_position == score_position, "Decision and scoreboard remain fixed while details scroll")
	check(game.decision_label.get_global_rect().end.y <= game.match_tabs.global_position.y, "Decision text stays above the tabs")
	game._start_allocation_practice()
	check(game.objective_summary.visible, "Synthetic objective lab retains its scoreboard")
	game._toggle_combat()
	check(game.match_tabs.current_tab == 0, "Returning to preview opens setup")
	game._toggle_combat()
	check(not game.objective_summary.visible, "Elimination exercise hides the training scoreboard")
	print("Gameplay layout checks: %d failures" % failures)
	quit(0 if failures == 0 else 1)
