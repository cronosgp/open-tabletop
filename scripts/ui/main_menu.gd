extends Control

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

var resume_button: Button
var resume_note: Label
var status_label: Label
var guided_button: Button
var training_swap_choice: CheckBox
var training_summary: Label
var new_match_button: Button
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

const GOLD := Color("e3b65c")
const IVORY := Color("eee7d2")
const MUTED := Color("aab4bb")

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	_build()

func _build() -> void:
	var dim := ColorRect.new()
	dim.color = Color(0.035, 0.052, 0.065, 0.42)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(dim)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(center)
	var frame := PanelContainer.new()
	menu_frame = frame
	frame.custom_minimum_size = Vector2(1040, 610)
	frame.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	frame.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var frame_style := StyleBoxFlat.new()
	frame_style.bg_color = Color("10161c")
	frame_style.bg_color.a = 0.94
	frame_style.border_color = Color("695432")
	frame_style.set_border_width_all(1)
	frame_style.border_width_left = 4
	frame_style.set_corner_radius_all(8)
	frame_style.content_margin_left = 34
	frame_style.content_margin_right = 34
	frame_style.content_margin_top = 28
	frame_style.content_margin_bottom = 28
	frame.add_theme_stylebox_override("panel", frame_style)
	center.add_child(frame)
	var body := HBoxContainer.new()
	menu_body = body
	body.add_theme_constant_override("separation", 40)
	frame.add_child(body)
	var identity := VBoxContainer.new()
	title_identity = identity
	identity.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	identity.size_flags_stretch_ratio = 1.0
	identity.add_theme_constant_override("separation", 16)
	body.add_child(identity)
	var eyebrow := Label.new()
	eyebrow.text = "COMMAND BRIEFING  /  11TH EDITION"
	eyebrow.add_theme_font_size_override("font_size", 13)
	eyebrow.add_theme_color_override("font_color", GOLD)
	identity.add_child(eyebrow)
	var title := Label.new()
	title_label = title
	title.text = "OPEN\nTABLETOP"
	title.add_theme_font_size_override("font_size", 54)
	title.add_theme_color_override("font_color", IVORY)
	title.add_theme_constant_override("line_spacing", -3)
	identity.add_child(title)
	var divider := ColorRect.new()
	divider.color = GOLD.darkened(0.45)
	divider.custom_minimum_size = Vector2(92, 2)
	identity.add_child(divider)
	var subtitle := Label.new()
	subtitle_label = subtitle
	subtitle.text = "A battlefield, two armies, one decision at a time."
	subtitle.add_theme_font_size_override("font_size", 21)
	subtitle.add_theme_color_override("font_color", Color("d0d8db"))
	subtitle.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	identity.add_child(subtitle)
	var hint := Label.new()
	hint_label = hint
	hint.text = "Choose a path to the table. The board and your match state stay under your control."
	hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hint.add_theme_color_override("font_color", MUTED)
	hint.custom_minimum_size.y = 52
	identity.add_child(hint)
	status_label = Label.new()
	status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	status_label.add_theme_color_override("font_color", Color("e8bd73"))
	identity.add_child(status_label)
	match_status = Label.new()
	match_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	match_status.add_theme_color_override("font_color", Color("e8bd73"))
	match_status.visible = false
	identity.add_child(match_status)
	var actions := VBoxContainer.new()
	actions.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	actions.size_flags_stretch_ratio = 1.15
	actions.add_theme_constant_override("separation", 10)
	body.add_child(actions)
	var section := Label.new()
	actions_heading = section
	section.text = "ENTER THE BATTLEFIELD"
	section.add_theme_font_size_override("font_size", 14)
	section.add_theme_color_override("font_color", GOLD)
	actions.add_child(section)
	resume_button = _button(actions, "Continue match", "Resume the last compatible local save.", false)
	resume_button.pressed.connect(func(): resume_requested.emit())
	resume_note = Label.new()
	resume_note.text = "No compatible saved match found."
	resume_note.add_theme_color_override("font_color", MUTED)
	actions.add_child(resume_note)
	guided_button = _button(actions, "Start tactical training", "Fire and Manoeuvre vs Close Assault. Gladius abilities and stratagems; free play with tips. Starting training enables local downloads for all six unit types. Asymmetric forces; legality and balance are not certified.", true)
	guided_button.pressed.connect(func(): start_guided_requested.emit())
	training_summary = Label.new()
	training_summary.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	training_summary.add_theme_font_size_override("font_size", 15)
	training_summary.add_theme_color_override("font_color", MUTED)
	actions.add_child(training_summary)
	training_swap_choice = CheckBox.new()
	training_swap_choice.text = "Swap training sides"
	training_swap_choice.tooltip_text = "Player 1 commands Close Assault instead of Fire and Manoeuvre."
	actions.add_child(training_swap_choice)
	training_swap_choice.toggled.connect(func(swapped: bool): training_sides_changed.emit(swapped))
	new_match_button = _button(actions, "New match", "Choose a local exercise, saved armies or LAN setup.", false)
	new_match_button.pressed.connect(func(): new_match_requested.emit())
	title_settings_button = _button(actions, "Settings", "Adjust local display and presentation options before starting.", false)
	title_settings_button.pressed.connect(func(): settings_requested.emit())
	match_section = VBoxContainer.new()
	match_section.add_theme_constant_override("separation", 10)
	match_section.visible = false
	actions.add_child(match_section)
	match_title = Label.new()
	match_title.text = "MATCH MENU"
	match_title.add_theme_font_size_override("font_size", 14)
	match_title.add_theme_color_override("font_color", GOLD)
	match_section.add_child(match_title)
	var history_button := _button(match_section, "Battle log", "Review match events and recorded D6 rolls.", false)
	history_button.pressed.connect(func(): history_requested.emit())
	var settings_button := _button(match_section, "Settings", "Adjust local display and presentation options.", false)
	settings_button.pressed.connect(func(): settings_requested.emit())
	var save_button := _button(match_section, "Save match to slot", "Choose one of five local slots for this match.", false)
	save_button.pressed.connect(func(): save_requested.emit())
	var exit_match_button := _button(match_section, "Exit match to title screen", "End this match session and return to the title screen. Save the match first if you want to resume it later.", false)
	exit_match_button.pressed.connect(func(): exit_match_requested.emit())
	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	actions.add_child(spacer)
	var nav_title := Label.new()
	nav_heading = nav_title
	nav_title.text = "YOUR TABLE"
	nav_title.add_theme_font_size_override("font_size", 13)
	nav_title.add_theme_color_override("font_color", GOLD)
	actions.add_child(nav_title)
	var nav := HFlowContainer.new()
	title_sections = nav
	nav.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	nav.add_theme_constant_override("h_separation", 6)
	nav.add_theme_constant_override("v_separation", 6)
	actions.add_child(nav)
	for entry: Dictionary in [
		{"label": "Armies", "tab": 3},
		{"label": "Models", "tab": 2},
		{"label": "Tools", "tab": 5}
	]:
		var button := _button(nav, str(entry.label), "Open " + str(entry.label) + ".", false, true)
		var tab_index := int(entry.tab)
		button.pressed.connect(func(): section_requested.emit(tab_index))
	var results_button := _button(nav, "Results", "Review match-result summaries saved on this computer.", false, true)
	results_button.pressed.connect(func(): saved_results_requested.emit())
	var guide_button := _button(nav, "Guide", "Read controls and match flow before starting.", false, true)
	guide_button.pressed.connect(func(): help_requested.emit())
	var footer_row := HBoxContainer.new()
	footer_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	actions.add_child(footer_row)
	var footer := Label.new()
	footer_label = footer
	footer.text = "Saved games and imported model files remain on this computer."
	footer.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	footer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	footer.add_theme_font_size_override("font_size", 12)
	footer.add_theme_color_override("font_color", Color("84919a"))
	footer_row.add_child(footer)
	exit_application_button = _button(footer_row, "Exit", "Close Open Tabletop.", false, true)
	exit_application_button.pressed.connect(func(): exit_application_requested.emit())

func set_resume_state(available: bool, explanation: String = "", live_match: bool = false, save_count: int = 1) -> void:
	resume_button.visible = available
	var backup_recovery := available and explanation.contains("previous backup")
	resume_note.visible = not available or backup_recovery
	resume_note.add_theme_color_override("font_color", Color("e5a394") if backup_recovery else MUTED)
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
	_fit_frame()
	focus_primary_action()

func focus_primary_action() -> void:
	var target: Control = null
	if match_section != null and match_section.visible and resume_button != null and resume_button.visible:
		target = resume_button
	elif resume_button != null and resume_button.visible:
		target = resume_button
	elif guided_button != null and guided_button.visible:
		target = guided_button
	elif new_match_button != null and new_match_button.visible:
		target = new_match_button
	if target != null and target.is_inside_tree(): target.grab_focus()

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
	shade.color = Color(0.015, 0.022, 0.029, 0.82)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.mouse_filter = Control.MOUSE_FILTER_STOP
	overlay.add_child(shade)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.add_child(center)
	var frame := PanelContainer.new()
	frame.custom_minimum_size.x = minf(720.0, get_viewport_rect().size.x - 48.0)
	var frame_style := StyleBoxFlat.new()
	frame_style.bg_color = Color("10161c")
	frame_style.border_color = Color("695432")
	frame_style.set_border_width_all(1)
	frame_style.border_width_left = 4
	frame_style.set_corner_radius_all(8)
	frame_style.content_margin_left = 28
	frame_style.content_margin_right = 28
	frame_style.content_margin_top = 24
	frame_style.content_margin_bottom = 24
	frame.add_theme_stylebox_override("panel", frame_style)
	center.add_child(frame)
	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 14)
	frame.add_child(content)
	var eyebrow := Label.new()
	eyebrow.text = "LOCAL MINIATURES"
	eyebrow.add_theme_font_size_override("font_size", 13)
	eyebrow.add_theme_color_override("font_color", GOLD)
	content.add_child(eyebrow)
	var heading := Label.new()
	heading.text = "Prepare your miniatures"
	heading.add_theme_font_size_override("font_size", 26)
	heading.add_theme_color_override("font_color", IVORY)
	content.add_child(heading)
	var explanation := Label.new()
	explanation.text = "Choose ForceOrg.json to use local miniature visuals. The catalog path is saved on this computer. When you start a local match, compatible models for the selected armies download automatically. Tactical training enables downloads for all six unit types. A unit keeps its default miniature if no supported model is available.\n\nContinue without models leaves downloads off for other local matches. Starting tactical training still prepares its miniatures. You can add ForceOrg.json later from Army & Models. Miniature downloads do not affect game rules."
	explanation.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	explanation.custom_minimum_size.x = minf(650.0, get_viewport_rect().size.x - 104.0)
	explanation.add_theme_color_override("font_color", Color("c7d0d5"))
	content.add_child(explanation)
	var actions := HBoxContainer.new()
	actions.add_theme_constant_override("separation", 10)
	content.add_child(actions)
	var choose_button := _button(actions, "Choose ForceOrg.json", "Select and validate a local model catalog.", true)
	var skip_button := _button(actions, "Continue without models", "Keep using default miniatures. Add ForceOrg.json later from Army & Models.", false)
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
	if title_identity != null: title_identity.visible = true
	if title_sections != null: title_sections.visible = not active
	if nav_heading != null: nav_heading.visible = not active
	if footer_label != null: footer_label.visible = not active
	if exit_application_button != null: exit_application_button.visible = not active
	if guided_button != null: guided_button.visible = not active
	if training_swap_choice != null: training_swap_choice.visible = not active
	if training_summary != null: training_summary.visible = not active
	if new_match_button != null: new_match_button.visible = not active
	if title_settings_button != null: title_settings_button.visible = not active
	if title_label != null:
		title_label.text = "MATCH\nMENU" if active else "OPEN\nTABLETOP"
		title_label.add_theme_font_size_override("font_size", 42 if active else 54)
	if subtitle_label != null: subtitle_label.text = "Your battle stays in play." if active else "A battlefield, two armies, one decision at a time."
	if hint_label != null: hint_label.text = "Return when ready. Review the battle log, save, or adjust local settings." if active else "Choose a path to the table. The board and your match state stay under your control."
	if actions_heading != null: actions_heading.text = "MATCH CONTROLS" if active else "ENTER THE BATTLEFIELD"
	if match_title != null: match_title.text = "LOCAL OPTIONS" if active else "MATCH MENU"
	resume_button.text = "Return to current match" if active else "Continue saved match"
	resume_button.visible = active or resume_button.visible
	resume_note.visible = not active and not resume_button.visible
	if active:
		match_status.text = "The match stays active while this local menu is open."
		_set_emphasis(resume_button, true)
	_fit_frame()

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED: call_deferred("_fit_frame")

func _fit_frame() -> void:
	if menu_frame == null or not is_inside_tree(): return
	var viewport := get_viewport_rect().size
	menu_frame.custom_minimum_size = Vector2(maxf(360.0, minf(1040.0, viewport.x - 36.0)), maxf(420.0, minf(700.0, viewport.y - 36.0)))

func _set_emphasis(button: Button, emphasized: bool) -> void:
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color("d2a751") if emphasized else Color("202b33")
	normal.border_color = Color("f0cc78") if emphasized else Color("3f515d")
	normal.set_border_width_all(1)
	normal.set_corner_radius_all(5)
	button.add_theme_stylebox_override("normal", normal)
	var hover := normal.duplicate() as StyleBoxFlat
	hover.bg_color = Color("edc875") if emphasized else Color("2a3943")
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_color_override("font_color", Color("141a1e") if emphasized else IVORY)

func _button(parent: Node, caption: String, tip: String, primary: bool, compact: bool = false) -> Button:
	var button := Button.new()
	button.text = caption
	button.tooltip_text = tip
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.custom_minimum_size.y = 44 if not compact else 36
	button.add_theme_font_size_override("font_size", 15 if compact else 17)
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color("d2a751") if primary else Color("202b33")
	normal.border_color = Color("f0cc78") if primary else Color("3f515d")
	normal.set_border_width_all(1)
	normal.set_corner_radius_all(5)
	normal.content_margin_left = 11
	normal.content_margin_right = 11
	button.add_theme_stylebox_override("normal", normal)
	var hover := normal.duplicate() as StyleBoxFlat
	hover.bg_color = Color("edc875") if primary else Color("2a3943")
	button.add_theme_stylebox_override("hover", hover)
	var focus := normal.duplicate() as StyleBoxFlat
	focus.border_color = Color("f7e6a6")
	focus.set_border_width_all(2)
	button.add_theme_stylebox_override("focus", focus)
	button.add_theme_color_override("font_color", Color("141a1e") if primary else IVORY)
	parent.add_child(button)
	return button
