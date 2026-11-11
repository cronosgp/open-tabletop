extends Control
## Imperial Dataslate title and in-match menu shell. Presentation only.

signal start_guided_requested
signal training_sides_changed(swapped: bool)
signal resume_requested
signal new_match_requested
signal exit_match_requested
signal exit_application_requested
signal section_requested(tab_index: int)
signal help_requested
signal settings_requested
signal saved_results_requested
signal history_requested
signal save_requested
signal recovery_browse_requested
signal recovery_dismiss_requested

const MenuTheme = preload("res://scripts/ui/menu_theme.gd")
const ICON_DIR := "res://assets/ui/icons/dataslate/"

var resume_button: Button
var _resume_icon_gold: Texture2D
var _resume_icon_on_gold: Texture2D
var _guided_icon_gold: Texture2D
var _guided_icon_on_gold: Texture2D
var resume_note: Label
var recovery_actions: VBoxContainer
var recovery_note: Label
var recovery_browse: Button
var status_label: Label
var guided_button: Button
var training_swap_choice: CheckBox
var training_summary: Label
var training_teaser: Label
var training_details: VBoxContainer
var training_details_button: Button
var new_match_button: Button
var army_builder_button: Button
var title_settings_button: Button
var title_identity: Control
var title_sections: Control
var match_section: VBoxContainer
var match_status: Label
var menu_frame: PanelContainer
var menu_body: HBoxContainer
var title_label: Label
var subtitle_label: Label
var hint_label: Label
var actions_heading: Label
var match_title: Label
var nav_heading: Label
var footer_label: Label
var exit_application_button: Button
var first_run_model_setup: Control
var bottom_bar: PanelContainer
var right_actions: VBoxContainer
var edition_label: Label

func _ready() -> void:
	theme = MenuTheme.create()
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	_build()

func _build() -> void:
	var background := ColorRect.new()
	background.name = "Background"
	background.color = MenuTheme.BACKGROUND
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(background)
	var main_content := MarginContainer.new()
	main_content.name = "MainContent"
	main_content.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	main_content.offset_bottom = -88.0
	for side in ["left", "right", "top", "bottom"]:
		main_content.add_theme_constant_override("margin_" + side, 56)
	main_content.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(main_content)
	var main_hbox := HBoxContainer.new()
	main_hbox.name = "MainHBox"
	menu_body = main_hbox
	main_hbox.add_theme_constant_override("separation", 56)
	main_hbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	main_content.add_child(main_hbox)
	_build_left_panel(main_hbox)
	_build_right_actions(main_hbox)
	_build_bottom_bar()

func _build_left_panel(parent: HBoxContainer) -> void:
	var left_panel := PanelContainer.new()
	left_panel.name = "LeftPanel"
	menu_frame = left_panel
	left_panel.custom_minimum_size = Vector2(520, 0)
	left_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left_panel.size_flags_stretch_ratio = 0.9
	parent.add_child(left_panel)
	var left_margin := MarginContainer.new()
	left_margin.name = "LeftMargin"
	for side in ["left", "right", "top", "bottom"]:
		left_margin.add_theme_constant_override("margin_" + side, 28)
	left_panel.add_child(left_margin)
	var left_vbox := VBoxContainer.new()
	left_vbox.name = "LeftVBox"
	title_identity = left_vbox
	left_vbox.add_theme_constant_override("separation", 16)
	left_vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	left_margin.add_child(left_vbox)
	edition_label = Label.new()
	edition_label.name = "EditionLabel"
	edition_label.text = "COMMAND BRIEFING  /  11TH EDITION"
	edition_label.add_theme_font_size_override("font_size", 15)
	edition_label.add_theme_color_override("font_color", MenuTheme.GOLD)
	left_vbox.add_child(edition_label)
	title_label = Label.new()
	title_label.name = "TitleLabel"
	title_label.text = "OPEN\nTABLETOP"
	title_label.add_theme_font_size_override("font_size", 68)
	title_label.add_theme_color_override("font_color", MenuTheme.TEXT)
	title_label.add_theme_constant_override("line_spacing", -6)
	left_vbox.add_child(title_label)
	var divider := ColorRect.new()
	divider.name = "Divider"
	divider.color = MenuTheme.GOLD
	divider.custom_minimum_size = Vector2(180, 2)
	left_vbox.add_child(divider)
	subtitle_label = Label.new()
	subtitle_label.name = "TaglineLabel"
	subtitle_label.text = "A GRIM DARK IMPERIAL TABLETOP EXPERIENCE"
	subtitle_label.add_theme_font_size_override("font_size", 14)
	subtitle_label.add_theme_color_override("font_color", MenuTheme.TEXT)
	subtitle_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	left_vbox.add_child(subtitle_label)
	hint_label = Label.new()
	hint_label.name = "FlavorLabel"
	hint_label.text = "Command armies across a living battlefield.\nBuild your forces, then decide every action.\nOnly victory endures."
	hint_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hint_label.add_theme_font_size_override("font_size", 17)
	hint_label.add_theme_color_override("font_color", MenuTheme.TEXT_SECONDARY)
	hint_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	left_vbox.add_child(hint_label)
	status_label = Label.new()
	status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	status_label.add_theme_color_override("font_color", MenuTheme.GOLD_HIGHLIGHT)
	status_label.text_overrun_behavior = TextServer.OVERRUN_NO_TRIMMING
	left_vbox.add_child(status_label)
	match_status = Label.new()
	match_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	match_status.add_theme_color_override("font_color", MenuTheme.GOLD_HIGHLIGHT)
	match_status.visible = false
	left_vbox.add_child(match_status)
	footer_label = Label.new()
	footer_label.text = "Saved games and imported model files remain on this computer.\nMenu icons by Lorc from game-icons.net (CC BY 3.0)."
	footer_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	footer_label.add_theme_font_size_override("font_size", 12)
	footer_label.add_theme_color_override("font_color", MenuTheme.TEXT_SECONDARY.darkened(0.15))
	left_vbox.add_child(footer_label)

func _build_right_actions(parent: HBoxContainer) -> void:
	var right_margin := MarginContainer.new()
	right_margin.name = "RightMargin"
	right_margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right_margin.size_flags_stretch_ratio = 1.1
	right_margin.size_flags_vertical = Control.SIZE_EXPAND_FILL
	for side in ["left", "right", "top", "bottom"]:
		right_margin.add_theme_constant_override("margin_" + side, 8)
	parent.add_child(right_margin)
	var right_vbox := VBoxContainer.new()
	right_vbox.name = "RightVBox"
	right_actions = right_vbox
	right_vbox.add_theme_constant_override("separation", 16)
	right_vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	right_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	right_margin.add_child(right_vbox)
	actions_heading = Label.new()
	actions_heading.text = "ENTER THE BATTLEFIELD"
	actions_heading.add_theme_font_size_override("font_size", 18)
	actions_heading.add_theme_color_override("font_color", MenuTheme.GOLD_HIGHLIGHT)
	actions_heading.add_theme_constant_override("letter_spacing", 2)
	right_vbox.add_child(actions_heading)
	var heading_rule := ColorRect.new()
	heading_rule.color = MenuTheme.GOLD.darkened(0.25)
	heading_rule.custom_minimum_size = Vector2(0, 1)
	heading_rule.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right_vbox.add_child(heading_rule)
	_resume_icon_gold = _load_icon("saved_matches.svg")
	_resume_icon_on_gold = _load_icon("saved_matches_on_gold.svg")
	_guided_icon_gold = _load_icon("start_training.svg")
	_guided_icon_on_gold = _load_icon("start_training_on_gold.svg")
	resume_button = _action_button(right_vbox, "Saved matches (0)", "Resume or inspect a local saved match.", true, false, _resume_icon_on_gold)
	resume_button.name = "SavedMatchesButton"
	resume_button.pressed.connect(func(): resume_requested.emit())
	resume_note = Label.new()
	resume_note.text = "No compatible saved match found."
	resume_note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	resume_note.add_theme_color_override("font_color", MenuTheme.TEXT_SECONDARY)
	right_vbox.add_child(resume_note)
	recovery_actions = VBoxContainer.new()
	recovery_actions.visible = false
	recovery_actions.add_theme_constant_override("separation", 8)
	right_vbox.add_child(recovery_actions)
	recovery_note = Label.new()
	recovery_note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	recovery_note.add_theme_color_override("font_color", MenuTheme.GOLD)
	recovery_actions.add_child(recovery_note)
	recovery_browse = _action_button(recovery_actions, "Browse saved matches", "Open the saved-match slots.", false, true)
	recovery_browse.pressed.connect(func(): recovery_browse_requested.emit())
	var dismiss := _action_button(recovery_actions, "Dismiss recovery notice", "Keep the checkpoint in its saved-match slot.", false, true)
	dismiss.pressed.connect(func(): recovery_dismiss_requested.emit())
	guided_button = _action_button(right_vbox, "Start tactical training", "Fire and Manoeuvre vs Close Assault. Gladius abilities and stratagems; free play with tips.", false, false, _guided_icon_gold)
	guided_button.name = "StartTrainingButton"
	guided_button.pressed.connect(func(): start_guided_requested.emit())
	# Training details button and teaser omitted; keep only the side-swap under Start training.
	training_details_button = null
	training_teaser = null
	training_details = VBoxContainer.new()
	training_details.name = "TrainingSummary"
	training_details.add_theme_constant_override("separation", 0)
	right_vbox.add_child(training_details)
	var training_indent := MarginContainer.new()
	training_indent.add_theme_constant_override("margin_left", 8)
	training_indent.add_theme_constant_override("margin_right", 4)
	training_indent.add_theme_constant_override("margin_bottom", 0)
	training_details.add_child(training_indent)
	var training_column := VBoxContainer.new()
	training_column.add_theme_constant_override("separation", 0)
	training_indent.add_child(training_column)
	training_summary = Label.new()
	training_summary.visible = false
	training_summary.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	training_summary.text_overrun_behavior = TextServer.OVERRUN_NO_TRIMMING
	training_column.add_child(training_summary)
	training_swap_choice = CheckBox.new()
	training_swap_choice.text = "Swap training sides"
	training_swap_choice.tooltip_text = "Player 1 commands Close Assault instead of Fire and Manoeuvre."
	training_swap_choice.focus_mode = Control.FOCUS_ALL
	training_swap_choice.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	training_swap_choice.custom_minimum_size = Vector2(0, 28)
	training_swap_choice.add_theme_font_size_override("font_size", 13)
	MenuTheme.apply_subtle_check(training_swap_choice)
	training_column.add_child(training_swap_choice)
	training_swap_choice.toggled.connect(func(swapped: bool): training_sides_changed.emit(swapped))
	new_match_button = _action_button(right_vbox, "New match", "Choose a local exercise, saved armies or LAN setup.", false, false, _load_icon("new_match.svg"))
	new_match_button.name = "NewMatchButton"
	new_match_button.pressed.connect(func(): new_match_requested.emit())
	# Army Builder stays on the bottom Armies / Miniatures toolbar, not in the primary stack.
	army_builder_button = null
	title_settings_button = _action_button(right_vbox, "Settings", "Adjust local display and presentation options before starting.", false, false, _load_icon("settings.svg"))
	title_settings_button.name = "SettingsButton"
	title_settings_button.pressed.connect(func(): settings_requested.emit())
	match_section = VBoxContainer.new()
	match_section.add_theme_constant_override("separation", 10)
	match_section.visible = false
	right_vbox.add_child(match_section)
	match_title = Label.new()
	match_title.text = "MATCH MENU"
	match_title.add_theme_font_size_override("font_size", 14)
	match_title.add_theme_color_override("font_color", MenuTheme.GOLD)
	match_section.add_child(match_title)
	var history_button := _action_button(match_section, "Battle log", "Review match events and recorded D6 rolls.", false, false, _load_icon("history.svg"))
	history_button.pressed.connect(func(): history_requested.emit())
	var settings_button := _action_button(match_section, "Settings", "Adjust local display and presentation options.", false, false, _load_icon("settings.svg"))
	settings_button.pressed.connect(func(): settings_requested.emit())
	var save_button := _action_button(match_section, "Save match to slot", "Choose one of five local slots for this match.", false, false, _load_icon("save.svg"))
	save_button.pressed.connect(func(): save_requested.emit())
	var exit_match_button := _action_button(match_section, "Exit match to title screen", "End this match session and return to the title screen.", false, false, _load_icon("exit.svg"))
	exit_match_button.pressed.connect(func(): exit_match_requested.emit())

func _build_bottom_bar() -> void:
	bottom_bar = PanelContainer.new()
	bottom_bar.name = "BottomBar"
	bottom_bar.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	bottom_bar.offset_top = -80.0
	bottom_bar.offset_bottom = 0.0
	add_child(bottom_bar)
	var bottom_margin := MarginContainer.new()
	bottom_margin.name = "BottomMargin"
	for side in ["left", "right"]:
		bottom_margin.add_theme_constant_override("margin_" + side, 28)
	bottom_margin.add_theme_constant_override("margin_top", 12)
	bottom_margin.add_theme_constant_override("margin_bottom", 12)
	bottom_bar.add_child(bottom_margin)
	var bottom_hbox := HBoxContainer.new()
	bottom_hbox.name = "BottomHBox"
	title_sections = bottom_hbox
	nav_heading = null
	bottom_hbox.add_theme_constant_override("separation", 10)
	bottom_hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bottom_margin.add_child(bottom_hbox)
	for entry: Dictionary in [
		{"label": "Armies", "tab": 3, "icon": "armies.svg"},
		{"label": "Miniatures", "tab": 2, "icon": "miniatures.svg"},
		{"label": "Training Tools", "tab": 5, "icon": "training_tools.svg"}
	]:
		var button := _toolbar_button(bottom_hbox, str(entry.label), "Open " + str(entry.label) + ".", false, _load_icon(str(entry.icon)))
		var tab_index := int(entry.tab)
		button.pressed.connect(func(): section_requested.emit(tab_index))
	var results_button := _toolbar_button(bottom_hbox, "Results", "Review match-result summaries saved on this computer.", false, _load_icon("results.svg"))
	results_button.pressed.connect(func(): saved_results_requested.emit())
	var guide_button := _toolbar_button(bottom_hbox, "Guide", "Read controls and match flow before starting.", false, _load_icon("guide.svg"))
	guide_button.pressed.connect(func(): help_requested.emit())
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bottom_hbox.add_child(spacer)
	exit_application_button = _toolbar_button(bottom_hbox, "Exit", "Close Open Tabletop.", true, _load_icon("exit.svg"))
	exit_application_button.name = "ExitButton"
	exit_application_button.pressed.connect(func(): exit_application_requested.emit())

func refresh_training_presentation() -> void:
	var full := training_summary.text if training_summary != null else ""
	if guided_button != null and not full.is_empty():
		guided_button.tooltip_text = full
	if training_swap_choice != null and not full.is_empty():
		training_swap_choice.tooltip_text = "Player 1 commands Close Assault instead of Fire and Manoeuvre.\n\n%s" % full

func set_resume_state(available: bool, explanation: String = "", live_match: bool = false, save_count: int = 1) -> void:
	resume_button.visible = available
	var backup_recovery := available and explanation.contains("previous backup")
	resume_note.visible = not available or backup_recovery
	resume_note.add_theme_color_override("font_color", Color("e5a394") if backup_recovery else MenuTheme.TEXT_SECONDARY)
	if live_match:
		resume_button.text = "Return to current match"
	elif save_count > 1:
		resume_button.text = "Saved matches (%d)" % save_count
	else:
		resume_button.text = "Continue saved match"
	resume_button.tooltip_text = explanation if not explanation.is_empty() else "Resume or inspect a local saved match."
	resume_note.text = _resume_note_text(explanation)
	resume_note.tooltip_text = explanation if not explanation.is_empty() else "No compatible saved match found."
	_set_emphasis(resume_button, available)
	_set_emphasis(guided_button, not available)
	focus_primary_action()

func focus_primary_action() -> void:
	if not visible or not is_inside_tree():
		return
	var target: Control = null
	if match_section != null and match_section.visible and resume_button != null and resume_button.visible:
		target = resume_button
	elif resume_button != null and resume_button.visible:
		target = resume_button
	elif guided_button != null and guided_button.visible:
		target = guided_button
	elif new_match_button != null and new_match_button.visible:
		target = new_match_button
	if target != null and target.is_inside_tree() and target.is_visible_in_tree():
		target.grab_focus()

func set_recovery_notice(message: String, browse_available: bool = false, diagnostic: String = "") -> void:
	recovery_note.text = message
	recovery_note.tooltip_text = diagnostic
	recovery_actions.visible = not message.is_empty() and not match_section.visible
	recovery_browse.visible = browse_available
	if recovery_actions.visible:
		resume_button.text = "Resume recovered match"
		resume_button.tooltip_text = message
		resume_note.visible = false
	_set_emphasis(resume_button, true)

func _resume_note_text(explanation: String) -> String:
	if explanation == "The saved match requires a different rules version or local data pack.":
		return "Previous save unavailable for this rules/data pack. Start a new match or tactical training."
	if explanation.contains("previous backup"):
		return "Primary save unreadable. Continue will use its previous backup."
	return explanation if not explanation.is_empty() else "No compatible saved match found."

func show_status(message: String) -> void:
	status_label.text = message
	status_label.visible = not match_section.visible and not message.is_empty()
	if match_section.visible:
		match_status.text = message if not message.is_empty() else "The match stays active while this local menu is open."
		match_status.visible = true

func show_first_run_model_setup(choose: Callable, skip: Callable) -> void:
	if first_run_model_setup != null and is_instance_valid(first_run_model_setup):
		first_run_model_setup.visible = true
		return
	var overlay := Control.new()
	first_run_model_setup = overlay
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.z_index = 100
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(overlay)
	var shade := ColorRect.new()
	shade.color = Color(0.043, 0.047, 0.055, 0.88)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.mouse_filter = Control.MOUSE_FILTER_STOP
	overlay.add_child(shade)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.add_child(center)
	var frame := PanelContainer.new()
	frame.custom_minimum_size.x = minf(720.0, get_viewport_rect().size.x - 48.0)
	center.add_child(frame)
	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 14)
	frame.add_child(content)
	var eyebrow := Label.new()
	eyebrow.text = "LOCAL MINIATURES"
	eyebrow.add_theme_font_size_override("font_size", 13)
	eyebrow.add_theme_color_override("font_color", MenuTheme.GOLD)
	content.add_child(eyebrow)
	var heading := Label.new()
	heading.text = "Prepare your miniatures"
	heading.add_theme_font_size_override("font_size", 26)
	heading.add_theme_color_override("font_color", MenuTheme.TEXT)
	content.add_child(heading)
	var explanation := Label.new()
	explanation.text = "Choose ForceOrg.json to use local miniature visuals. The catalog path is saved on this computer. When you start a local match, compatible models for the selected armies download automatically. Tactical training prepares its selected miniatures before play, including matched Intercessor Sergeant loadouts. A unit keeps its default miniature if no supported model is available.\n\nContinue without models leaves downloads off for other local matches. Starting tactical training still prepares its miniatures. You can add ForceOrg.json later from Army & Models. Miniature downloads do not affect game rules."
	explanation.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	explanation.custom_minimum_size.x = minf(650.0, get_viewport_rect().size.x - 104.0)
	explanation.add_theme_color_override("font_color", MenuTheme.TEXT_SECONDARY)
	content.add_child(explanation)
	var actions := HBoxContainer.new()
	actions.add_theme_constant_override("separation", 10)
	content.add_child(actions)
	var choose_button := _action_button(actions, "Choose ForceOrg.json", "Select and validate a local model catalog.", true)
	var skip_button := _action_button(actions, "Continue without models", "Keep using default miniatures.", false)
	choose_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	skip_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	choose_button.pressed.connect(choose)
	skip_button.pressed.connect(skip)
	choose_button.call_deferred("grab_focus")

func hide_first_run_model_setup() -> void:
	if first_run_model_setup != null and is_instance_valid(first_run_model_setup):
		first_run_model_setup.queue_free()
	first_run_model_setup = null

func set_in_match_mode(active: bool) -> void:
	match_section.visible = active
	match_status.visible = active
	status_label.visible = not active and not status_label.text.is_empty()
	if title_identity != null:
		title_identity.visible = true
	if title_sections != null:
		title_sections.visible = not active
	if bottom_bar != null:
		bottom_bar.visible = not active
	if footer_label != null:
		footer_label.visible = not active
	if guided_button != null:
		guided_button.visible = not active
	if training_swap_choice != null:
		training_swap_choice.visible = not active
	if training_summary != null:
		training_summary.visible = false
	if training_details != null:
		training_details.visible = not active
	if new_match_button != null:
		new_match_button.visible = not active
	if army_builder_button != null:
		army_builder_button.visible = not active
	if title_settings_button != null:
		title_settings_button.visible = not active
	if actions_heading != null:
		actions_heading.visible = not active
	if title_label != null:
		title_label.text = "MATCH\nMENU" if active else "OPEN\nTABLETOP"
		title_label.add_theme_font_size_override("font_size", 48 if active else 68)
	if subtitle_label != null:
		subtitle_label.text = "YOUR BATTLE STAYS IN PLAY" if active else "A GRIM DARK IMPERIAL TABLETOP EXPERIENCE"
	if hint_label != null:
		hint_label.text = "Return when ready. Review the battle log, save, or adjust local settings." if active else "Command armies across a living battlefield.\nBuild your forces, then decide every action.\nOnly victory endures."
	if match_title != null:
		match_title.text = "LOCAL OPTIONS" if active else "MATCH MENU"
	recovery_actions.visible = not active and not recovery_note.text.is_empty()
	if active:
		resume_button.text = "Return to current match"
	elif recovery_actions.visible:
		resume_button.text = "Resume recovered match"
	resume_button.visible = active or resume_button.visible
	resume_note.visible = not active and not recovery_actions.visible and (not resume_button.visible or resume_note.tooltip_text.contains("previous backup"))
	if active:
		match_status.text = "The match stays active while this local menu is open."
		_set_emphasis(resume_button, true)
	focus_primary_action()

func _set_emphasis(button: Button, emphasized: bool) -> void:
	if button == null:
		return
	if emphasized:
		MenuTheme.apply_primary(button)
	else:
		button.theme_type_variation = &""
		button.remove_theme_color_override("font_color")
		button.remove_theme_color_override("font_hover_color")
		button.remove_theme_color_override("font_focus_color")
		button.remove_theme_color_override("font_pressed_color")
	if button == resume_button:
		button.icon = _resume_icon_on_gold if emphasized else _resume_icon_gold
	elif button == guided_button:
		button.icon = _guided_icon_on_gold if emphasized else _guided_icon_gold

func _load_icon(file_name: String) -> Texture2D:
	var path := ICON_DIR + file_name
	if not ResourceLoader.exists(path):
		return null
	return load(path) as Texture2D

func _apply_icon(button: Button, icon: Texture2D) -> void:
	if button == null or icon == null:
		return
	button.icon = icon
	button.expand_icon = false
	button.icon_alignment = HORIZONTAL_ALIGNMENT_LEFT
	button.alignment = HORIZONTAL_ALIGNMENT_CENTER

func _action_button(parent: Node, caption: String, tip: String, primary: bool, compact: bool = false, icon: Texture2D = null) -> Button:
	var button := Button.new()
	button.text = caption
	button.tooltip_text = tip
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.custom_minimum_size.y = 40 if compact else 56
	button.add_theme_font_size_override("font_size", 15 if compact else 18)
	button.alignment = HORIZONTAL_ALIGNMENT_CENTER
	button.clip_text = false
	button.text_overrun_behavior = TextServer.OVERRUN_NO_TRIMMING
	_apply_icon(button, icon)
	if primary:
		MenuTheme.apply_primary(button)
	else:
		MenuTheme.apply_action(button)
	parent.add_child(button)
	return button

func _toolbar_button(parent: Node, caption: String, tip: String, exit_style: bool = false, icon: Texture2D = null) -> Button:
	var button := Button.new()
	button.text = caption
	button.tooltip_text = tip
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.custom_minimum_size = Vector2(96, 44)
	button.add_theme_font_size_override("font_size", 14)
	button.clip_text = false
	button.text_overrun_behavior = TextServer.OVERRUN_NO_TRIMMING
	_apply_icon(button, icon)
	if exit_style:
		MenuTheme.apply_exit(button)
	else:
		MenuTheme.apply_toolbar(button)
	parent.add_child(button)
	return button
