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
	await process_frame
	check(game.main_menu.visible and not game.sidebar_panel.visible and not game.combat_hud.visible, "Launch opens the dedicated title screen")
	check(game.main_menu.resume_button.visible == game.resume_compatible, "Continue only appears for a compatible local save")
	var launch_primary: Control = game.main_menu.resume_button if game.resume_compatible else game.main_menu.guided_button
	check(launch_primary.has_focus(), "Title screen focuses the first valid primary action")
	game.main_menu.set_resume_state(false, "No compatible save found.")
	check(not game.main_menu.resume_button.visible and game.main_menu.guided_button.visible and game.main_menu.guided_button.has_focus(), "Guided match is the focused fallback when no compatible save exists")
	game.main_menu.set_resume_state(false, "The saved match requires a different rules version or local data pack.")
	check("Previous save unavailable" in game.main_menu.resume_note.text and "different rules version" in game.main_menu.resume_note.tooltip_text, "Technical save incompatibility is summarized with an actionable title-screen fallback")
	game.main_menu.set_resume_state(game.resume_compatible)
	game._start_objectives()
	await process_frame
	game._dismiss_home(1)
	await process_frame
	check(game.combat_hud.visible and game.command_panel.visible, "Starting combat opens the combat HUD and contextual command panel")
	check(not game.sidebar_panel.visible and game.gameplay_scroll.get_parent() == game.command_panel_body and game.command_panel.visible, "Active combat uses the contextual command panel over the board")
	check(game.objective_summary.visible and "VP" in game.objective_summary.text, "Training scoreboard visible in the HUD")
	var match_before_menu := var_to_str(game.state)
	game._open_home()
	check(game.main_menu.visible and not game.sidebar_panel.visible and not game.combat_hud.visible, "Match menu is a local overlay above the board")
	check(game.main_menu.resume_button.text == "Return to current match" and game.main_menu.match_section.visible, "In-match menu keeps Return to current match primary and exposes local actions")
	check(game.main_menu.resume_button.has_focus(), "In-match menu focuses Return to current match")
	check(not game.main_menu.title_sections.visible, "Army, model and training navigation is hidden during an active match")
	check(var_to_str(game.state) == match_before_menu, "Opening the menu does not change match state")
	game._dismiss_home(1)
	await process_frame
	check(game.match_tabs.tabs_visible == false and game.gameplay_scroll.get_parent() == game.command_panel_body, "Active match removes the persistent Play/workshop tab navigation")
	game._toggle_command_panel()
	check(not game.command_panel.visible, "Command panel can collapse to free board space")
	game._toggle_command_panel()
	check(game.command_panel.visible, "Command panel can reopen from the HUD")
	var selected_before_screen: int = game.selected
	match_before_menu = var_to_str(game.state)
	game._open_history_screen()
	for frame in range(3): await process_frame
	check(game.tactical_overlay.visible and game.tactical_overlay_title.text.begins_with("BATTLE LOG"), "Battle log opens as its own overlay")
	check(var_to_str(game.state) == match_before_menu and game.selected == selected_before_screen, "Opening the battle log preserves match state and selection")
	game._close_tactical_screen()
	check(game.command_panel.visible and not game.tactical_overlay.visible, "Closing the battle log returns to the same command panel")
	game._open_settings_screen()
	check(game.tactical_overlay.visible and game.settings_panel.get_parent() == game.tactical_overlay_body, "Settings open as a dedicated local screen")
	game.ui_preferences_path = "user://ui_redesign_test.cfg"
	var board_option: CheckButton = game.settings_toggles.board
	var applied_board_value := not board_option.button_pressed
	board_option.button_pressed = applied_board_value
	game._apply_ui_preferences()
	var saved_preferences := ConfigFile.new()
	check(game.board_feedback_toggle.button_pressed == applied_board_value and saved_preferences.load(game.ui_preferences_path) == OK and saved_preferences.get_value("presentation", "options", {}).board == applied_board_value, "Settings Apply updates presentation and persists it locally")
	board_option.button_pressed = not applied_board_value
	game._revert_ui_preferences()
	check(board_option.button_pressed == applied_board_value and game.board_feedback_toggle.button_pressed == applied_board_value, "Settings Revert returns to the last applied presentation values")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(game.ui_preferences_path))
	game._close_tactical_screen()
	game._open_help_screen()
	check(game.tactical_overlay.visible and game.help_scroll.get_parent() == game.tactical_overlay_body, "Help opens outside the match sidebar")
	game._close_tactical_screen()
	game.mode = "client"
	match_before_menu = var_to_str(game.state)
	game._open_home()
	check(var_to_str(game.state) == match_before_menu and game.mode == "client", "Opening the menu during LAN leaves session state unchanged")
	game._dismiss_home(1)
	check(game.gameplay_scroll.get_parent() == game.command_panel_body and not game.sidebar_panel.visible, "Returning from the menu restores the command panel and board")
	game.mode = "local"
	game.combat_enabled = false
	game._layout_ui()
	game.match_tabs.current_tab = 0
	game._refresh()
	check(game.match_tabs.current_tab == 0 and not game.match_tabs.is_tab_hidden(0) and game.main_menu.title_sections.visible, "Setup and title-screen workshop links remain available outside an active match")
	check(game.saved_army_start_button.visible and not game.saved_army_start_button.disabled, "Current-catalog saved-list local match is ready from New match")
	check(not game.action_groups.phase.container.visible, "Play phase actions stay hidden while New match setup is open")
	game.combat_enabled = true
	game._layout_ui()
	game.match_tabs.current_tab = 1
	game.combat_enabled = false
	game._layout_ui()
	check(game.match_tabs.is_tab_hidden(3) and game.match_tabs.is_tab_hidden(5) and game.main_menu.title_sections.visible, "Army Workshop and Tools are reached from the title screen rather than lateral tabs")
	game._open_home()
	game._open_menu_section(5)
	check(game.tactical_overlay_content == game.tools_scroll and game.main_menu.visible, "Title-screen Tools link opens its own screen")
	game._close_tactical_screen()
	game._open_home()
	game._open_menu_section(2)
	check(game.tactical_overlay_content == game.workshop_scroll and game.workshop_tabs.current_tab == 1, "Title-screen Models link opens model import in the shared workshop")
	game._close_tactical_screen()
	game._open_home()
	game._open_menu_section(3)
	check(game.tactical_overlay_content == game.workshop_scroll and game.workshop_tabs.current_tab == 0, "Title-screen Armies link opens the roster workshop")
	game._close_tactical_screen()
	game._dismiss_home(0)
	game.combat_enabled = true
	game.match_tabs.current_tab = 1
	game._layout_ui()
	game.technical_toggle.button_pressed = true
	game.technical_toggle.toggled.emit(true)
	game.details.text += "\nLong selection details".repeat(80)
	game._open_help_screen()
	for frame in range(5): await process_frame
	var details_scroll: ScrollContainer = game.help_scroll
	var header_position: Vector2 = game.decision_label.global_position
	var score_position: Vector2 = game.objective_summary.global_position
	details_scroll.scroll_vertical = 10000
	for frame in range(5): await process_frame
	check(details_scroll.scroll_vertical > 0, "Long gameplay details can scroll in Help")
	check(game.decision_label.global_position == header_position and game.objective_summary.global_position == score_position, "Decision and scoreboard remain fixed while details scroll")
	check(game.decision_label.get_global_rect().end.y <= game.command_panel.global_position.y, "Decision text stays above the command panel")
	game._close_tactical_screen()
	game._start_allocation_practice()
	check(game.objective_summary.visible, "Synthetic objective lab retains its scoreboard")
	game._toggle_combat()
	check(game.match_tabs.current_tab == 0, "Returning to preview opens setup")
	game._toggle_combat()
	check(not game.objective_summary.visible, "Elimination exercise hides the training scoreboard")
	print("Gameplay layout checks: %d failures" % failures)
	game.free()
	await process_frame
	quit(0 if failures == 0 else 1)
