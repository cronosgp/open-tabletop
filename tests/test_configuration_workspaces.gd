extends SceneTree
## Configuration integration checks; current local catalog, isolated by tools/verify.py.
var failures := 0
func _initialize() -> void: call_deferred("run")
func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func run() -> void:
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	for frame in range(3): await process_frame
	if game.main_menu.first_run_model_setup != null: game.main_menu.first_run_model_setup.hide()
	game._open_menu_section(3)
	var builder = game.army_builder
	builder._new_empty()
	builder.query.text = "Intercessor Squad"
	builder._filter_units()
	var found := -1
	for index in builder.unit_picker.item_count:
		if builder.unit_picker.get_item_metadata(index).name == "Intercessor Squad": found = index
	check(found >= 0, "Current local catalog supplies the editor")
	if found < 0:
		quit(1)
		return
	var empty_before := var_to_str(builder.draft)
	builder.unit_picker.select(found)
	builder.unit_picker.item_selected.emit(found)
	check(builder.preview_entry.is_empty() and var_to_str(builder.draft) == empty_before, "Catalog preview preserves roster selection and draft")
	check(builder.miniature_preview.title.text.begins_with("Catalog · "), "Candidate is explicitly distinguished from roster selection")
	builder._add()
	check(builder.draft.entries.size() == 1 and builder.selected_entry_index == 0, "Existing add callback updates and selects the roster")
	builder.unit_picker.select(found)
	builder.unit_picker.item_selected.emit(found)
	builder.editor_tabs.current_tab = 0
	check(not builder.candidate_preview and builder.miniature_preview.title.text.begins_with("Roster · "), "Leaving candidate inspection restores the roster preview")
	builder.entry_models_input.value = 10
	builder.entry_copies_input.value = 2
	builder._apply_entry_size()
	var totals: Dictionary = builder.Roster.summary(builder.draft)
	check(builder.draft.entries[0].models == 10 and totals.units == 2 and builder.points_meter.value == totals.points, "Squad size, copies and budget use existing roster calculations")
	builder.name_input.text = "Workspace persistence fixture"
	check(builder._save(), "Current roster saves through profile storage")
	var saved: Dictionary = builder.draft.duplicate(true)
	var reloaded = builder.Profiles.new(builder.storage_path)
	check(reloaded.active().lists.size() == 1 and reloaded.active().lists[0] == JSON.parse_string(JSON.stringify(saved)), "Fresh profile store restores the complete saved roster across JSON numeric normalization")
	builder._save_copy()
	check(builder.store.active().lists.size() == 2 and builder.draft.id != saved.id, "Copy retains original and uses a distinct saved identity")
	builder._load_list_by_id(saved.id)
	check(builder.Roster.summary(builder.draft) == totals, "Reload preserves points, copies and squad size")
	builder._close_editor()
	check(builder.library_workspace.visible and builder.library_preview.is_ancestor_of(builder.miniature_preview), "Army library retains saved-roster miniature inspection")
	game._open_new_match_workspace()
	check(game.tactical_overlay_content == game.new_match_scroll and game.saved_army_pickers.size() == 2, "New Match exposes both existing side selectors")
	game._open_settings_screen()
	var bindings: Dictionary = game.control_draft.duplicate(true)
	game.settings_toggles.board.button_pressed = not game.settings_toggles.board.button_pressed
	game.settings_categories.current_tab = 2
	game.settings_categories.current_tab = 1
	check(game.control_draft == bindings, "Changing settings categories preserves staged bindings")
	game._revert_ui_preferences()
	check(game.control_draft == bindings, "Revert still restores applied bindings")
	game._open_title_field_guide()
	var guide = game.title_guide_scroll.get_child(0)
	guide.search.text = "nonexistent-guide-term"
	guide.search.text_changed.emit(guide.search.text)
	check(guide.navigation.item_count == 0 and "No matching topics" in guide.article.text, "Guide search has a recoverable zero-result state")
	guide.search.text = ""
	guide.search.text_changed.emit("")
	check(guide.navigation.item_count > 1, "Clearing search restores maintained guide topics")
	game._close_tactical_screen()
	await process_frame
	game._open_home()
	check(game.main_menu.training_details_button == null, "Training details button is intentionally omitted")
	check(game.main_menu.training_details.visible and game.main_menu.training_teaser == null and game.main_menu.training_swap_choice.visible, "Only the side-swap control remains nested under Start tactical training")
	check(not game.main_menu.training_summary.visible and "290" in game.main_menu.training_summary.text and "290" in game.main_menu.training_swap_choice.tooltip_text, "Full training summary stays on the swap tooltip without bloating the button stack")
	check(game.main_menu.guided_button.icon != null and game.main_menu.new_match_button.icon != null and game.main_menu.exit_application_button.icon != null, "Dataslate action and toolbar buttons carry credited icons")
	check("game-icons.net" in game.main_menu.footer_label.text and "CC BY 3.0" in game.main_menu.footer_label.text, "Title footer credits the CC BY icon source")
	game.main_menu.new_match_button.grab_focus()
	check(root.gui_get_focus_owner() == game.main_menu.new_match_button, "Primary navigation accepts keyboard focus")
	var next := InputEventAction.new()
	next.action = "ui_focus_next"
	next.pressed = true
	Input.parse_input_event(next)
	await process_frame
	check(root.gui_get_focus_owner() != null and root.gui_get_focus_owner() != game.main_menu.new_match_button, "Synthetic keyboard navigation advances visible focus")
	game._open_title_field_guide()
	var cancel := InputEventJoypadButton.new()
	cancel.button_index = JOY_BUTTON_B
	cancel.pressed = true
	check(cancel.is_action_pressed("ui_cancel"), "Default controller Back maps to the existing cancel action")
	Input.parse_input_event(cancel)
	await process_frame
	check(game.tactical_overlay_content == null, "Synthetic controller Back closes the workspace")
	print("Configuration workspace checks: %d failures" % failures)
	game.queue_free()
	await process_frame
	quit(0 if failures == 0 else 1)
