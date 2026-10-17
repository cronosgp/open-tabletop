extends Control

signal start_guided_requested
signal resume_requested
signal new_match_requested
signal section_requested(tab_index: int)

var resume_button: Button
var resume_note: Label
var status_label: Label
var guided_button: Button
var new_match_button: Button

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
	body.add_theme_constant_override("separation", 40)
	frame.add_child(body)
	var identity := VBoxContainer.new()
	identity.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	identity.size_flags_stretch_ratio = 1.2
	identity.add_theme_constant_override("separation", 16)
	body.add_child(identity)
	var eyebrow := Label.new()
	eyebrow.text = "COMMAND BRIEFING  /  11TH EDITION"
	eyebrow.add_theme_font_size_override("font_size", 13)
	eyebrow.add_theme_color_override("font_color", GOLD)
	identity.add_child(eyebrow)
	var title := Label.new()
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
	subtitle.text = "A battlefield, two armies, one decision at a time."
	subtitle.add_theme_font_size_override("font_size", 21)
	subtitle.add_theme_color_override("font_color", Color("d0d8db"))
	subtitle.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	identity.add_child(subtitle)
	var hint := Label.new()
	hint.text = "Choose a path to the table. The board and your match state stay under your control."
	hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hint.add_theme_color_override("font_color", MUTED)
	hint.custom_minimum_size.y = 52
	identity.add_child(hint)
	status_label = Label.new()
	status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	status_label.add_theme_color_override("font_color", Color("e8bd73"))
	identity.add_child(status_label)
	var actions := VBoxContainer.new()
	actions.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	actions.size_flags_stretch_ratio = 0.9
	actions.add_theme_constant_override("separation", 10)
	body.add_child(actions)
	var section := Label.new()
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
	guided_button = _button(actions, "Start guided match", "A local 290-point sample. You control both sides.", true)
	guided_button.pressed.connect(func(): start_guided_requested.emit())
	new_match_button = _button(actions, "New match", "Choose a local exercise, saved armies or LAN setup.", false)
	new_match_button.pressed.connect(func(): new_match_requested.emit())
	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	actions.add_child(spacer)
	var nav_title := Label.new()
	nav_title.text = "YOUR TABLE"
	nav_title.add_theme_font_size_override("font_size", 13)
	nav_title.add_theme_color_override("font_color", GOLD)
	actions.add_child(nav_title)
	var nav := HBoxContainer.new()
	nav.add_theme_constant_override("separation", 6)
	actions.add_child(nav)
	for entry: Dictionary in [
		{"label": "Armies", "tab": 3},
		{"label": "Models", "tab": 2},
		{"label": "History", "tab": 4},
		{"label": "Tools", "tab": 5}
	]:
		var button := _button(nav, str(entry.label), "Open " + str(entry.label) + ".", false, true)
		var tab_index := int(entry.tab)
		button.pressed.connect(func(): section_requested.emit(tab_index))
	var footer := Label.new()
	footer.text = "Saved games and imported model files remain on this computer."
	footer.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	footer.add_theme_font_size_override("font_size", 12)
	footer.add_theme_color_override("font_color", Color("84919a"))
	actions.add_child(footer)

func set_resume_state(available: bool, explanation: String = "", live_match: bool = false) -> void:
	resume_button.visible = available
	resume_note.visible = not available
	resume_button.text = "Return to current match" if live_match else "Continue saved match"
	resume_button.tooltip_text = explanation if not explanation.is_empty() else "Resume the last compatible local save."
	resume_note.text = explanation if not explanation.is_empty() else "No compatible saved match found."
	_set_emphasis(resume_button, available)
	_set_emphasis(guided_button, not available)

func show_status(message: String) -> void:
	status_label.text = message
	status_label.visible = not message.is_empty()

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
	button.add_theme_color_override("font_color", Color("141a1e") if primary else IVORY)
	parent.add_child(button)
	return button
