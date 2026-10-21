extends Control

signal menu_requested
signal focus_requested
signal help_requested

const STEP_ORDER: Array[String] = ["command", "movement", "shooting", "charge", "fight"]
const STEP_LABELS := {
	"command": "Command",
	"movement": "Move",
	"shooting": "Shoot",
	"charge": "Charge",
	"fight": "Fight",
}

var round_label: Label
var decision_label: Label
var objective_label: Label
var connection_label: Label
var focus_button: Button
var menu_button: Button
var step_labels: Dictionary = {}

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_build()

func _build() -> void:
	var bar := PanelContainer.new()
	bar.anchor_right = 1.0
	bar.offset_left = 16
	bar.offset_top = 12
	bar.offset_right = -16
	bar.offset_bottom = 96
	bar.mouse_filter = Control.MOUSE_FILTER_STOP
	var style := StyleBoxFlat.new()
	style.bg_color = Color("11181e")
	style.bg_color.a = 0.95
	style.border_color = Color("50606a")
	style.set_border_width_all(1)
	style.border_width_bottom = 2
	style.set_corner_radius_all(6)
	style.content_margin_left = 12
	style.content_margin_right = 12
	style.content_margin_top = 8
	style.content_margin_bottom = 8
	bar.add_theme_stylebox_override("panel", style)
	add_child(bar)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 6)
	bar.add_child(column)
	var steps := HBoxContainer.new()
	steps.add_theme_constant_override("separation", 6)
	column.add_child(steps)
	round_label = Label.new()
	round_label.custom_minimum_size = Vector2(72, 0)
	round_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	round_label.add_theme_font_size_override("font_size", 14)
	round_label.add_theme_color_override("font_color", Color("f1ede2"))
	steps.add_child(round_label)
	for step_id: String in STEP_ORDER:
		var chip := Label.new()
		chip.text = STEP_LABELS[step_id]
		chip.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		chip.tooltip_text = "Turn phase %d of %d" % [STEP_ORDER.find(step_id) + 1, STEP_ORDER.size()]
		chip.add_theme_font_size_override("font_size", 14)
		chip.add_theme_color_override("font_color", Color("4d5c66"))
		steps.add_child(chip)
		step_labels[step_id] = chip
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	steps.add_child(spacer)
	objective_label = Label.new()
	objective_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	objective_label.add_theme_font_size_override("font_size", 14)
	objective_label.add_theme_color_override("font_color", Color("c4ced1"))
	steps.add_child(objective_label)
	connection_label = Label.new()
	connection_label.custom_minimum_size.x = 88
	connection_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	connection_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	connection_label.add_theme_font_size_override("font_size", 12)
	connection_label.add_theme_color_override("font_color", Color("8fc8bd"))
	steps.add_child(connection_label)
	focus_button = Button.new()
	focus_button.text = "Focus"
	focus_button.custom_minimum_size = Vector2(64, 28)
	focus_button.tooltip_text = "Center the camera on the selected unit (F). Camera only."
	focus_button.disabled = true
	focus_button.pressed.connect(func(): focus_requested.emit())
	steps.add_child(focus_button)
	var help_button := Button.new()
	help_button.text = "Help"
	help_button.custom_minimum_size = Vector2(54, 28)
	help_button.tooltip_text = "Toggle Help / Play: instructions, technical details and display preferences."
	help_button.pressed.connect(func(): help_requested.emit())
	steps.add_child(help_button)
	menu_button = Button.new()
	menu_button.text = "Menu"
	menu_button.custom_minimum_size = Vector2(64, 28)
	menu_button.tooltip_text = "Open the local menu. A LAN match continues for the other player."
	menu_button.pressed.connect(func(): menu_requested.emit())
	steps.add_child(menu_button)
	decision_label = Label.new()
	decision_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	decision_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	decision_label.add_theme_font_size_override("font_size", 16)
	decision_label.add_theme_color_override("font_color", Color("eee9df"))
	column.add_child(decision_label)

func set_round(text: String) -> void:
	round_label.text = text

func set_steps(phase: String, round_number: int, actor: int) -> void:
	var mapped := phase
	if phase in ["start_turn", "command"]: mapped = "command"
	elif phase == "end_turn": mapped = "fight"
	var current_index := STEP_ORDER.find(mapped)
	if phase.is_empty():
		current_index = -1
	elif current_index < 0:
		round_label.text = "Setup"
		round_label.tooltip_text = "Round %d · Player %d" % [round_number, actor]
	else:
		round_label.text = "R%d  P%d" % [round_number, actor]
		round_label.tooltip_text = "Round %d · Player %d to act" % [round_number, actor]
	for index in STEP_ORDER.size():
		var step_id: String = STEP_ORDER[index]
		var chip: Label = step_labels[step_id]
		var color := Color("4d5c66")
		chip.text = "%d %s" % [index + 1, STEP_LABELS[step_id]]
		var background := StyleBoxFlat.new()
		background.bg_color = Color.TRANSPARENT
		background.set_corner_radius_all(4)
		background.content_margin_left = 6
		background.content_margin_right = 6
		background.content_margin_top = 4
		background.content_margin_bottom = 4
		if current_index >= 0 and index < current_index:
			color = Color("7f8c86")
			chip.text = "✓ " + STEP_LABELS[step_id]
		elif index == current_index:
			color = Color("f2df83")
			chip.text = "%d %s · NOW" % [index + 1, STEP_LABELS[step_id]]
			background.bg_color = Color("343126")
		chip.add_theme_stylebox_override("normal", background)
		chip.add_theme_color_override("font_color", color)

func set_connection(text: String) -> void:
	connection_label.text = text

func set_complete(round_number: int) -> void:
	round_label.text = "Result"
	round_label.tooltip_text = "Recorded result · round %d" % round_number
	for step: String in STEP_ORDER:
		var chip: Label = step_labels[step]
		chip.text = STEP_LABELS[step]
		chip.add_theme_color_override("font_color", Color("7f8c86"))
		chip.remove_theme_stylebox_override("normal")

func set_focus_available(available: bool) -> void:
	focus_button.disabled = not available
