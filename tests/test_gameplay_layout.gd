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
	check(game.main_menu.visible and not game.sidebar_panel.visible and not game.combat_hud.visible, "Launch opens the dedicated title screen")
	check(game.main_menu.resume_button.visible == game.resume_compatible, "Continue only appears for a compatible local save")
	game.main_menu.set_resume_state(false, "No compatible save found.")
	check(not game.main_menu.resume_button.visible and game.main_menu.guided_button.visible, "Guided match is the fallback when no compatible save exists")
	game.main_menu.set_resume_state(game.resume_compatible)
	game._start_objectives()
	game._dismiss_home(1)
	check(game.match_tabs.current_tab == 1 and game.combat_hud.visible, "Starting combat opens the combat HUD")
	check(game.objective_summary.visible and "VP" in game.objective_summary.text, "Training scoreboard visible in the HUD")
	var match_before_menu := var_to_str(game.state)
	game._open_home()
	check(game.main_menu.visible and not game.sidebar_panel.visible and not game.combat_hud.visible, "Match menu is a local overlay above the board")
	check(var_to_str(game.state) == match_before_menu, "Opening the menu does not change match state")
	game._dismiss_home(1)
	game.mode = "client"
	match_before_menu = var_to_str(game.state)
	game._open_home()
	check(var_to_str(game.state) == match_before_menu and game.mode == "client", "Opening the menu during LAN leaves session state unchanged")
	game._dismiss_home(1)
	game.mode = "local"
	game.match_tabs.current_tab = 0
	game._refresh()
	check(game.match_tabs.current_tab == 0, "Refreshing state preserves deliberately opened setup tab")
	game.match_tabs.current_tab = 1
	var play_width: float = game.sidebar_panel.size.x
	game.match_tabs.current_tab = 3
	var army_width: float = game.sidebar_panel.size.x
	game.match_tabs.current_tab = 1
	check(army_width > play_width, "Army Workshop expands its workspace while Play keeps more of the board visible")
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
