extends Control
## Full-screen local hot-seat handoff; it never reads or changes match state.
signal confirmed(player: int)
signal menu_requested
const WorkspaceTheme = preload("res://scripts/ui/workspace_theme.gd")

var receiving_player := 0
var player_heading := Label.new()
var context_label := Label.new()
var instructions := Label.new()
var ready_button := Button.new()

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	focus_mode = Control.FOCUS_ALL
	theme = WorkspaceTheme.create()
	var backdrop := ColorRect.new()
	backdrop.color = WorkspaceTheme.BASE
	backdrop.mouse_filter = Control.MOUSE_FILTER_STOP
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(backdrop)
	var panel := PanelContainer.new()
	panel.anchor_left = 0.5
	panel.anchor_top = 0.5
	panel.anchor_right = 0.5
	panel.anchor_bottom = 0.5
	panel.offset_left = -240.0
	panel.offset_top = -145.0
	panel.offset_right = 240.0
	panel.offset_bottom = 145.0
	panel.add_theme_stylebox_override("panel", WorkspaceTheme.box(WorkspaceTheme.SURFACE, WorkspaceTheme.GOLD, 22, 2, 2))
	add_child(panel)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 14)
	panel.add_child(column)
	var title := Label.new()
	title.text = "PASS THE TABLE"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	title.max_lines_visible = -1
	title.text_overrun_behavior = TextServer.OVERRUN_NO_TRIMMING
	title.add_theme_font_size_override("font_size", 22)
	title.add_theme_color_override("font_color", WorkspaceTheme.GOLD)
	column.add_child(title)
	player_heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	player_heading.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	player_heading.max_lines_visible = -1
	player_heading.text_overrun_behavior = TextServer.OVERRUN_NO_TRIMMING
	player_heading.add_theme_font_size_override("font_size", 32)
	player_heading.add_theme_color_override("font_color", WorkspaceTheme.GOLD_HIGHLIGHT)
	column.add_child(player_heading)
	context_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	context_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	context_label.max_lines_visible = -1
	context_label.text_overrun_behavior = TextServer.OVERRUN_NO_TRIMMING
	context_label.add_theme_color_override("font_color", WorkspaceTheme.MUTED)
	column.add_child(context_label)
	instructions.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	instructions.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	instructions.max_lines_visible = -1
	instructions.text_overrun_behavior = TextServer.OVERRUN_NO_TRIMMING
	instructions.add_theme_font_size_override("font_size", 17)
	instructions.add_theme_color_override("font_color", WorkspaceTheme.TEXT)
	column.add_child(instructions)
	ready_button.custom_minimum_size = Vector2(0, 48)
	ready_button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	ready_button.clip_text = false
	ready_button.text_overrun_behavior = TextServer.OVERRUN_NO_TRIMMING
	WorkspaceTheme.decorate_button(ready_button, "handoff", true)
	ready_button.pressed.connect(_confirm)
	column.add_child(ready_button)
	var ready_path := ready_button.get_path()
	ready_button.focus_neighbor_top = ready_path
	ready_button.focus_neighbor_bottom = ready_path
	ready_button.focus_neighbor_left = ready_path
	ready_button.focus_neighbor_right = ready_path
	ready_button.focus_next = ready_path
	ready_button.focus_previous = ready_path
	visible = false

func show_for_player(player: int, context: String = "") -> void:
	if player not in [1, 2]: return
	receiving_player = player
	player_heading.text = "PLAYER %d" % player
	context_label.text = context
	context_label.visible = not context.is_empty()
	instructions.text = "Pass the controls to Player %d. Continue when ready to reveal the board and current decision." % player
	ready_button.text = "Continue as Player %d" % player
	visible = true
	call_deferred("_focus_ready_button")

func _focus_ready_button() -> void:
	if visible and is_instance_valid(ready_button): ready_button.grab_focus()

func _confirm() -> void:
	if not visible or receiving_player not in [1, 2]: return
	var player := receiving_player
	visible = false
	confirmed.emit(player)

func _input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		menu_requested.emit()
