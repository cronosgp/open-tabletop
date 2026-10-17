extends Control

signal menu_requested
signal focus_requested

var round_label: Label
var decision_label: Label
var objective_label: Label
var connection_label: Label
var focus_button: Button
var menu_button: Button

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_build()

func _build() -> void:
	var bar := PanelContainer.new()
	bar.anchor_right = 1.0
	bar.offset_left = 16
	bar.offset_top = 14
	bar.offset_right = -16
	bar.offset_bottom = 100
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
	style.content_margin_top = 9
	style.content_margin_bottom = 9
	bar.add_theme_stylebox_override("panel", style)
	add_child(bar)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 13)
	bar.add_child(row)
	var game_state := VBoxContainer.new()
	game_state.custom_minimum_size.x = 220
	row.add_child(game_state)
	var game_title := Label.new()
	game_title.text = "OPEN TABLETOP"
	game_title.add_theme_font_size_override("font_size", 12)
	game_title.add_theme_color_override("font_color", Color("d8ad5e"))
	game_state.add_child(game_title)
	round_label = Label.new()
	round_label.add_theme_font_size_override("font_size", 17)
	round_label.add_theme_color_override("font_color", Color("f1ede2"))
	game_state.add_child(round_label)
	var divider := ColorRect.new()
	divider.custom_minimum_size = Vector2(1, 50)
	divider.color = Color("35434b")
	row.add_child(divider)
	var decision_panel := VBoxContainer.new()
	decision_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	decision_panel.add_theme_constant_override("separation", 2)
	row.add_child(decision_panel)
	var decision_heading := Label.new()
	decision_heading.text = "CURRENT DECISION"
	decision_heading.add_theme_font_size_override("font_size", 11)
	decision_heading.add_theme_color_override("font_color", Color("d8ad5e"))
	decision_panel.add_child(decision_heading)
	decision_label = Label.new()
	decision_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	decision_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	decision_label.add_theme_font_size_override("font_size", 15)
	decision_label.add_theme_color_override("font_color", Color("eee9df"))
	decision_panel.add_child(decision_label)
	var objective_panel := VBoxContainer.new()
	objective_panel.custom_minimum_size.x = 330
	objective_panel.add_theme_constant_override("separation", 2)
	row.add_child(objective_panel)
	var objective_heading := Label.new()
	objective_heading.text = "MISSION / SCORE"
	objective_heading.add_theme_font_size_override("font_size", 11)
	objective_heading.add_theme_color_override("font_color", Color("d8ad5e"))
	objective_panel.add_child(objective_heading)
	objective_label = Label.new()
	objective_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	objective_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	objective_label.add_theme_font_size_override("font_size", 13)
	objective_label.add_theme_color_override("font_color", Color("c4ced1"))
	objective_panel.add_child(objective_label)
	connection_label = Label.new()
	connection_label.custom_minimum_size.x = 112
	connection_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	connection_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	connection_label.add_theme_font_size_override("font_size", 12)
	connection_label.add_theme_color_override("font_color", Color("8fc8bd"))
	row.add_child(connection_label)
	focus_button = Button.new()
	focus_button.text = "FOCUS"
	focus_button.custom_minimum_size = Vector2(68, 40)
	focus_button.tooltip_text = "Center the camera on the selected unit (F). This only changes your camera view."
	focus_button.disabled = true
	focus_button.pressed.connect(func(): focus_requested.emit())
	row.add_child(focus_button)
	menu_button = Button.new()
	menu_button.text = "MENU"
	menu_button.custom_minimum_size = Vector2(82, 40)
	menu_button.tooltip_text = "Open the local menu. A LAN match continues for the other player."
	menu_button.pressed.connect(func(): menu_requested.emit())
	var menu_style := StyleBoxFlat.new()
	menu_style.bg_color = Color("29353c")
	menu_style.border_color = Color("65737b")
	menu_style.set_border_width_all(1)
	menu_style.set_corner_radius_all(4)
	menu_button.add_theme_stylebox_override("normal", menu_style)
	row.add_child(menu_button)

func set_round(text: String) -> void:
	round_label.text = text

func set_connection(text: String) -> void:
	connection_label.text = text

func set_focus_available(available: bool) -> void:
	focus_button.disabled = not available
