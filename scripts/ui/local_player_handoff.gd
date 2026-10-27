extends Control
## Full-screen local hot-seat handoff; it never reads or changes match state.
signal confirmed(player: int)

var receiving_player := 0
var player_heading := Label.new()
var instructions := Label.new()
var ready_button := Button.new()

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	focus_mode = Control.FOCUS_ALL
	var backdrop := ColorRect.new()
	backdrop.color = Color("080d11")
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
	var style := StyleBoxFlat.new()
	style.bg_color = Color("10171d")
	style.border_color = Color("8c713e")
	style.set_border_width_all(1)
	style.border_width_top = 3
	style.set_corner_radius_all(7)
	style.content_margin_left = 22
	style.content_margin_right = 22
	style.content_margin_top = 20
	style.content_margin_bottom = 20
	panel.add_theme_stylebox_override("panel", style)
	add_child(panel)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 14)
	panel.add_child(column)
	var title := Label.new()
	title.text = "PASS THE TABLE"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 22)
	title.add_theme_color_override("font_color", Color("e3b75c"))
	column.add_child(title)
	player_heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	player_heading.add_theme_font_size_override("font_size", 32)
	player_heading.add_theme_color_override("font_color", Color("f2df83"))
	column.add_child(player_heading)
	instructions.text = "Give the controls to the next player. Their decision stays covered until they continue."
	instructions.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	instructions.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	instructions.add_theme_font_size_override("font_size", 17)
	instructions.add_theme_color_override("font_color", Color("edf1f2"))
	column.add_child(instructions)
	ready_button.custom_minimum_size = Vector2(0, 48)
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

func show_for_player(player: int) -> void:
	if player not in [1, 2]: return
	receiving_player = player
	player_heading.text = "PLAYER %d" % player
	instructions.text = "Pass the controls to Player %d, then continue to reveal their decision." % player
	ready_button.text = "Continue as Player %d" % player
	visible = true
	call_deferred("_focus_ready_button")

func _focus_ready_button() -> void:
	if visible and is_instance_valid(ready_button): ready_button.grab_focus()

func _confirm() -> void:
	if receiving_player not in [1, 2]: return
	var player := receiving_player
	visible = false
	confirmed.emit(player)

func _input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
