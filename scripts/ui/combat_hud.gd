extends Control

signal menu_requested
signal focus_requested
signal help_requested
signal history_requested
signal command_panel_requested
signal side_requested
signal army_requested
signal mission_requested
signal layout_changed

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
var side_button: Button
var army_button: Button
var mission_button: Button
var menu_button: Button
var guide_progress_label: Label
var command_panel_button: Button
var step_labels: Dictionary = {}
var header_panel: PanelContainer
var phase_row: HBoxContainer
var toolbar: HBoxContainer
var toolbar_controls: Array[Control] = []

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_build()
	get_viewport().size_changed.connect(_fit_hud)
	_fit_hud()

func _build() -> void:
	var bar := PanelContainer.new()
	header_panel = bar
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
	phase_row = steps
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
	mission_button = Button.new()
	mission_button.text = "Mission"
	mission_button.visible = false
	mission_button.custom_minimum_size = Vector2(70, 28)
	mission_button.tooltip_text = "Read the mission score, objectives and latest resolved control values."
	mission_button.pressed.connect(func(): mission_requested.emit())
	steps.add_child(mission_button)
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
	focus_button.tooltip_text = "Center the camera on the selected unit. Camera only."
	focus_button.disabled = true
	focus_button.pressed.connect(func(): focus_requested.emit())
	steps.add_child(focus_button)
	side_button = Button.new()
	side_button.text = "P1 side"
	side_button.custom_minimum_size = Vector2(72, 28)
	side_button.tooltip_text = "Return the camera to this player's side of the table. Orbit still works. Camera only."
	side_button.pressed.connect(func(): side_requested.emit())
	steps.add_child(side_button)
	army_button = Button.new()
	army_button.text = "Army"
	army_button.visible = false
	army_button.custom_minimum_size = Vector2(64, 28)
	army_button.tooltip_text = "Show the army list and the selected model card."
	army_button.pressed.connect(func(): army_requested.emit())
	steps.add_child(army_button)
	command_panel_button = Button.new()
	command_panel_button.text = "Actions"
	command_panel_button.custom_minimum_size = Vector2(64, 28)
	command_panel_button.tooltip_text = "Show or hide the contextual command panel."
	command_panel_button.pressed.connect(func(): command_panel_requested.emit())
	steps.add_child(command_panel_button)
	var help_button := Button.new()
	help_button.text = "Help"
	help_button.custom_minimum_size = Vector2(54, 28)
	help_button.tooltip_text = "Open the field guide and full explanations."
	help_button.pressed.connect(func(): help_requested.emit())
	steps.add_child(help_button)
	var history_button := Button.new()
	history_button.text = "Log"
	history_button.custom_minimum_size = Vector2(46, 28)
	history_button.tooltip_text = "Open the battle log. Reading it does not change the match."
	history_button.pressed.connect(func(): history_requested.emit())
	steps.add_child(history_button)
	guide_progress_label = Label.new()
	guide_progress_label.visible = false
	guide_progress_label.custom_minimum_size.x = 64
	guide_progress_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	guide_progress_label.add_theme_font_size_override("font_size", 12)
	guide_progress_label.add_theme_color_override("font_color", Color("f2df83"))
	steps.add_child(guide_progress_label)
	menu_button = Button.new()
	menu_button.text = "Menu"
	menu_button.custom_minimum_size = Vector2(64, 28)
	menu_button.tooltip_text = "Open the local menu. A LAN match continues for the other player."
	menu_button.pressed.connect(func(): menu_requested.emit())
	steps.add_child(menu_button)
	toolbar = HBoxContainer.new()
	toolbar.add_theme_constant_override("separation", 8)
	column.add_child(toolbar)
	toolbar_controls = [connection_label, objective_label, focus_button, side_button, army_button, mission_button, command_panel_button, help_button, history_button, guide_progress_label, menu_button]
	header_panel.minimum_size_changed.connect(func():
		header_panel.offset_bottom = header_panel.offset_top + header_panel.get_combined_minimum_size().y
		layout_changed.emit()
	)
	decision_label = Label.new()
	decision_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	decision_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	decision_label.add_theme_font_size_override("font_size", 16)
	decision_label.add_theme_color_override("font_color", Color("eee9df"))
	column.add_child(decision_label)

func set_round(text: String) -> void:
	round_label.text = text

func set_steps(phase: String, round_number: int, active_player: int, decision_player: int = -1) -> void:
	if decision_player < 0: decision_player = active_player
	var mapped := phase
	if phase in ["start_turn", "command"]: mapped = "command"
	elif phase == "end_turn": mapped = "fight"
	var current_index := STEP_ORDER.find(mapped)
	if phase.is_empty():
		current_index = -1
	elif current_index < 0:
		round_label.text = "Setup"
		round_label.tooltip_text = "Round %d · Player %d active · Player %d decides" % [round_number, active_player, decision_player]
	else:
		round_label.text = "R%d  P%d" % [round_number, active_player]
		round_label.tooltip_text = "Round %d · Player %d active · Player %d decides" % [round_number, active_player, decision_player]
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

func set_focus_binding_label(key_label: String) -> void:
	focus_button.tooltip_text = "Center the camera on the selected unit (%s). Camera only." % key_label

func set_army_open(open: bool) -> void:
	army_button.visible = not open
	army_button.text = "Army"
	army_button.tooltip_text = "Show the army list and the selected model card."

func set_mission_available(available: bool) -> void:
	mission_button.visible = available

func set_side_player(player: int) -> void:
	var seat := player if player in [1, 2] else 1
	side_button.text = "P%d side" % seat
	side_button.tooltip_text = "Return the camera to player %d's side of the table. The P1 and P2 marks stay on those edges. Orbit still works. Camera only." % seat

func set_command_panel_open(open: bool) -> void:
	command_panel_button.text = "Hide" if open else "Actions"
	command_panel_button.tooltip_text = "Hide the command panel." if open else "Show the command panel."

func set_guide_progress(active: bool, step: int = 0, total: int = 10) -> void:
	guide_progress_label.visible = active
	guide_progress_label.text = "GUIDE %d/%d" % [step, total] if active else ""
	guide_progress_label.tooltip_text = "Guided sample progress. The decision banner shows the current action." if active else ""

func _fit_hud() -> void:
	if objective_label == null: return
	var compact := get_viewport_rect().size.x < 1120.0
	var two_rows := get_viewport_rect().size.x < 1400.0
	var destination: HBoxContainer = toolbar if two_rows else phase_row
	for control: Control in toolbar_controls:
		if control.get_parent() != destination: control.reparent(destination)
	toolbar.visible = two_rows
	objective_label.visible = true
	objective_label.add_theme_font_size_override("font_size", 11 if compact else 14)
	for step: Label in step_labels.values():
		step.add_theme_font_size_override("font_size", 12 if compact else 14)
	round_label.add_theme_font_size_override("font_size", 12 if compact else 14)
	command_panel_button.custom_minimum_size.x = 50 if compact else 64
	layout_changed.emit()
