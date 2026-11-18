extends Control

signal menu_requested
signal focus_requested
signal overview_requested
signal active_action_requested
signal help_requested
signal diagnostics_requested
signal datasheet_requested
signal history_requested
signal command_panel_requested
signal side_requested(player: int)
signal tools_opening
signal army_requested
signal mission_requested
signal layout_changed

const WorkspaceTheme = preload("res://scripts/ui/workspace_theme.gd")
const DataslateIcons = preload("res://scripts/ui/dataslate_icons.gd")
const ASSET_TOAST_WIDTH := 310.0
enum Tool {
	CONNECTION, OVERVIEW, FOCUS, ACTIVE_ACTION, PLAYER_1_SIDE, PLAYER_2_SIDE,
	DATASHEET, ARMY, MISSION, GUIDE, HISTORY, DIAGNOSTICS, GUIDE_PROGRESS,
}
const TOOL_ICONS := {
	Tool.CONNECTION: "connection",
	Tool.OVERVIEW: "camera",
	Tool.FOCUS: "focus",
	Tool.ACTIVE_ACTION: "actions",
	Tool.PLAYER_1_SIDE: "armies",
	Tool.PLAYER_2_SIDE: "armies",
	Tool.DATASHEET: "datasheet",
	Tool.ARMY: "armies",
	Tool.MISSION: "mission",
	Tool.GUIDE: "guide",
	Tool.HISTORY: "history",
	Tool.DIAGNOSTICS: "diagnostics",
	Tool.GUIDE_PROGRESS: "guide",
}

const STEP_ORDER: Array[String] = ["command", "movement", "shooting", "charge", "fight"]
const STEP_LABELS := {
	"command": "Command",
	"movement": "Move",
	"shooting": "Shoot",
	"charge": "Charge",
	"fight": "Fight",
}

var owner_label: Label
var owner_caption := ""
var tools_button: MenuButton
var asset_badge: Label
var asset_toast: PanelContainer
var asset_toast_text: Label
var asset_toast_timer: Timer
var score_text := ""
var active_step := -1
var result_recorded := false
var connection_summary := ""
var connection_details := ""
var guide_progress := ""
var focus_available := false
var active_action_available := false
var army_open := true
var mission_available := false
var focus_binding := ""
var round_label: Label
var decision_label: Label
var objective_label: Label
var menu_button: Button
var command_panel_button: Button
var step_labels: Dictionary = {}
var step_panels: Dictionary = {}
var header_panel: PanelContainer

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	theme = WorkspaceTheme.create()
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
	style.bg_color = WorkspaceTheme.SURFACE
	style.bg_color.a = 0.96
	style.border_color = WorkspaceTheme.GOLD
	style.set_border_width_all(1)
	style.border_width_bottom = 2
	style.set_corner_radius_all(2)
	style.content_margin_left = 12
	style.content_margin_right = 12
	style.content_margin_top = 8
	style.content_margin_bottom = 8
	bar.add_theme_stylebox_override("panel", style)
	add_child(bar)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 6)
	bar.add_child(column)
	var steps := HFlowContainer.new()
	steps.add_theme_constant_override("h_separation", 8)
	steps.add_theme_constant_override("v_separation", 6)
	column.add_child(steps)
	var phase_divider := ColorRect.new()
	phase_divider.color = WorkspaceTheme.BORDER
	phase_divider.custom_minimum_size.y = 1
	phase_divider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	phase_divider.mouse_filter = Control.MOUSE_FILTER_IGNORE
	column.add_child(phase_divider)
	var utility := HBoxContainer.new()
	utility.name = "HudUtilityRow"
	utility.add_theme_constant_override("separation", 6)
	column.add_child(utility)
	var turn_panel := PanelContainer.new()
	turn_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	turn_panel.add_theme_stylebox_override("panel", WorkspaceTheme.box(WorkspaceTheme.ELEVATED, WorkspaceTheme.GOLD, 8, 1, 2, 4))
	steps.add_child(turn_panel)
	round_label = Label.new()
	round_label.size_flags_horizontal = Control.SIZE_SHRINK_END
	round_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	round_label.clip_text = false
	round_label.text_overrun_behavior = TextServer.OVERRUN_NO_TRIMMING
	round_label.add_theme_font_size_override("font_size", 16)
	round_label.add_theme_color_override("font_color", WorkspaceTheme.TEXT)
	turn_panel.add_child(round_label)
	for step_id: String in STEP_ORDER:
		var chip_panel := PanelContainer.new()
		chip_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
		chip_panel.add_theme_stylebox_override("panel", WorkspaceTheme.box(WorkspaceTheme.SURFACE, WorkspaceTheme.BORDER, 6, 1, 2, 4))
		steps.add_child(chip_panel)
		var chip := Label.new()
		chip.text = STEP_LABELS[step_id]
		chip.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		chip.clip_text = false
		chip.text_overrun_behavior = TextServer.OVERRUN_NO_TRIMMING
		chip.tooltip_text = "Turn phase %d of %d" % [STEP_ORDER.find(step_id) + 1, STEP_ORDER.size()]
		chip.add_theme_font_size_override("font_size", 15)
		chip.add_theme_color_override("font_color", WorkspaceTheme.MUTED)
		chip_panel.add_child(chip)
		step_labels[step_id] = chip
		step_panels[step_id] = chip_panel
	objective_label = Label.new()
	objective_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	objective_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	objective_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	objective_label.max_lines_visible = -1
	objective_label.text_overrun_behavior = TextServer.OVERRUN_NO_TRIMMING
	objective_label.add_theme_font_size_override("font_size", 15)
	objective_label.add_theme_color_override("font_color", WorkspaceTheme.TEXT)
	utility.add_child(objective_label)
	command_panel_button = Button.new()
	command_panel_button.text = "Actions"
	command_panel_button.custom_minimum_size = Vector2(88, 40)
	command_panel_button.tooltip_text = "Show or hide the contextual command panel."
	command_panel_button.pressed.connect(func(): command_panel_requested.emit())
	WorkspaceTheme.decorate_button(command_panel_button, "actions")
	utility.add_child(command_panel_button)
	menu_button = Button.new()
	menu_button.text = "Menu"
	menu_button.custom_minimum_size = Vector2(80, 40)
	menu_button.tooltip_text = "Open the local menu (Escape). A LAN match continues for the other player."
	menu_button.pressed.connect(func(): menu_requested.emit())
	WorkspaceTheme.decorate_button(menu_button, "menu")
	utility.add_child(menu_button)
	tools_button = MenuButton.new()
	tools_button.text = "Tools"
	tools_button.focus_mode = Control.FOCUS_ALL
	tools_button.flat = false
	tools_button.custom_minimum_size = Vector2(84, 40)
	tools_button.tooltip_text = "Camera, army, mission, guide and history. These tools do not commit a decision."
	WorkspaceTheme.decorate_button(tools_button, "tools")
	tools_button.add_theme_stylebox_override("normal", WorkspaceTheme.button_box(WorkspaceTheme.ELEVATED, WorkspaceTheme.GOLD))
	tools_button.add_theme_stylebox_override("hover", WorkspaceTheme.button_box(WorkspaceTheme.HOVER, WorkspaceTheme.GOLD_HIGHLIGHT))
	tools_button.add_theme_stylebox_override("pressed", WorkspaceTheme.button_box(WorkspaceTheme.HOVER.darkened(0.08), WorkspaceTheme.GOLD))
	tools_button.add_theme_stylebox_override("focus", WorkspaceTheme.button_box(Color.TRANSPARENT, WorkspaceTheme.GOLD_HIGHLIGHT))
	tools_button.add_theme_stylebox_override("disabled", WorkspaceTheme.button_box(WorkspaceTheme.BASE, WorkspaceTheme.BORDER))
	utility.add_child(tools_button)
	utility.move_child(tools_button, menu_button.get_index())
	asset_badge = Label.new()
	asset_badge.text = "!"
	asset_badge.custom_minimum_size = Vector2(18, 16)
	asset_badge.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	asset_badge.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	asset_badge.add_theme_color_override("font_color", WorkspaceTheme.GOLD)
	asset_badge.add_theme_font_size_override("font_size", 14)
	asset_badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	asset_badge.anchor_left = 1.0
	asset_badge.anchor_right = 1.0
	asset_badge.offset_left = -18.0
	asset_badge.offset_top = 0.0
	asset_badge.hide()
	tools_button.add_child(asset_badge)
	tools_button.about_to_popup.connect(_refresh_tools_menu)
	var popup := tools_button.get_popup()
	popup.add_theme_stylebox_override("panel", WorkspaceTheme.box(WorkspaceTheme.SURFACE, WorkspaceTheme.BORDER, 5))
	popup.add_theme_stylebox_override("hover", WorkspaceTheme.box(WorkspaceTheme.ELEVATED, WorkspaceTheme.GOLD, 4))
	popup.add_theme_color_override("font_color", WorkspaceTheme.TEXT)
	popup.add_theme_color_override("font_hover_color", WorkspaceTheme.TEXT)
	popup.add_theme_color_override("font_disabled_color", WorkspaceTheme.MUTED)
	popup.add_theme_constant_override("icon_max_width", 16)
	popup.add_theme_constant_override("item_start_padding", 8)
	popup.add_theme_constant_override("item_end_padding", 10)
	popup.add_theme_constant_override("h_separation", 8)
	popup.id_pressed.connect(_activate_tool)
	var utility_divider := ColorRect.new()
	utility_divider.color = WorkspaceTheme.BORDER
	utility_divider.custom_minimum_size.y = 1
	utility_divider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	utility_divider.mouse_filter = Control.MOUSE_FILTER_IGNORE
	column.add_child(utility_divider)
	header_panel.minimum_size_changed.connect(func():
		header_panel.offset_bottom = header_panel.offset_top + header_panel.get_combined_minimum_size().y
		_position_asset_toast()
		layout_changed.emit()
	)
	var decision_row := VBoxContainer.new()
	decision_row.add_theme_constant_override("separation", 2)
	column.add_child(decision_row)
	owner_label = Label.new()
	owner_label.text = "PLAYER 1 DECIDES"
	owner_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	owner_label.max_lines_visible = -1
	owner_label.text_overrun_behavior = TextServer.OVERRUN_NO_TRIMMING
	owner_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	owner_label.add_theme_font_size_override("font_size", 14)
	owner_label.add_theme_color_override("font_color", WorkspaceTheme.GOLD)
	decision_row.add_child(owner_label)
	decision_label = Label.new()
	decision_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	decision_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	decision_label.max_lines_visible = -1
	decision_label.text_overrun_behavior = TextServer.OVERRUN_NO_TRIMMING
	decision_label.add_theme_font_size_override("font_size", 16)
	decision_label.add_theme_color_override("font_color", Color("eee9df"))
	decision_row.add_child(decision_label)
	asset_toast = PanelContainer.new()
	asset_toast.mouse_filter = Control.MOUSE_FILTER_IGNORE
	asset_toast.offset_right = ASSET_TOAST_WIDTH
	asset_toast.add_theme_stylebox_override("panel", WorkspaceTheme.box(WorkspaceTheme.SURFACE, WorkspaceTheme.GOLD, 8))
	add_child(asset_toast)
	asset_toast_text = Label.new()
	asset_toast_text.mouse_filter = Control.MOUSE_FILTER_IGNORE
	asset_toast.add_child(asset_toast_text)
	asset_toast.hide()
	asset_toast_timer = Timer.new()
	asset_toast_timer.one_shot = true
	asset_toast_timer.wait_time = 3.0
	asset_toast_timer.timeout.connect(asset_toast.hide)
	add_child(asset_toast_timer)

func set_asset_warning(message: String) -> void:
	asset_badge.visible = not message.is_empty()
	asset_toast_timer.stop()
	asset_toast.hide()
	if message.is_empty(): return
	asset_toast_text.text = message
	_position_asset_toast()
	asset_toast.show()
	asset_toast_timer.start()

func _position_asset_toast() -> void:
	if asset_toast == null: return
	asset_toast.offset_top = header_panel.get_rect().end.y + 8.0
	asset_toast.offset_bottom = asset_toast.offset_top + asset_toast.get_combined_minimum_size().y

func fit_asset_toast(left: float, right: float) -> void:
	var centered := (left + right - ASSET_TOAST_WIDTH) * 0.5
	asset_toast.offset_left = maxf(16.0, minf(centered, right - ASSET_TOAST_WIDTH))
	asset_toast.offset_right = asset_toast.offset_left + ASSET_TOAST_WIDTH

func set_round(text: String) -> void:
	round_label.text = text
	_fit_round_label()

func _fit_round_label() -> void:
	round_label.custom_minimum_size.x = 0
	round_label.custom_minimum_size.x = round_label.get_minimum_size().x

func set_steps(phase: String, round_number: int, active_player: int, decision_player: int = -1) -> void:
	result_recorded = false
	if decision_player < 0: decision_player = active_player
	var mapped := phase
	if phase in ["start_turn", "command"]: mapped = "command"
	elif phase == "end_turn": mapped = "fight"
	var current_index := STEP_ORDER.find(mapped)
	if phase.is_empty():
		current_index = -1
	elif current_index < 0:
		_show_turn_owner(round_number, active_player, decision_player, true)
	else:
		_show_turn_owner(round_number, active_player, decision_player, false)
	active_step = current_index
	for index in STEP_ORDER.size():
		var step_id: String = STEP_ORDER[index]
		var chip: Label = step_labels[step_id]
		var chip_panel: PanelContainer = step_panels[step_id]
		var color := WorkspaceTheme.MUTED.darkened(0.12)
		var background := WorkspaceTheme.box(WorkspaceTheme.SURFACE, WorkspaceTheme.BORDER, 6, 1, 2, 4)
		if current_index >= 0 and index < current_index:
			color = WorkspaceTheme.MUTED
			background = WorkspaceTheme.box(WorkspaceTheme.ELEVATED, WorkspaceTheme.BORDER, 6, 1, 2, 4)
		elif index == current_index:
			color = WorkspaceTheme.GOLD_HIGHLIGHT
			background = WorkspaceTheme.box(Color("2a2518"), WorkspaceTheme.GOLD, 6, 1, 2, 4)
		chip_panel.add_theme_stylebox_override("panel", background)
		chip.add_theme_color_override("font_color", color)
	_format_step_captions(get_viewport_rect().size.x < 1280.0)

func _format_step_captions(compact: bool) -> void:
	for index in STEP_ORDER.size():
		var step_id := STEP_ORDER[index]
		var caption: String = STEP_LABELS[step_id]
		if not result_recorded:
			if active_step >= 0 and index < active_step:
				caption = "✓ " + caption
			elif not compact:
				caption = "%d %s" % [index + 1, caption]
				if index == active_step: caption += " · NOW"
		step_labels[step_id].text = caption

func _show_turn_owner(round_number: int, active_player: int, decision_player: int, setup: bool) -> void:
	var other_decides := decision_player > 0 and active_player > 0 and decision_player != active_player
	var caption := "Setup · P%d turn" % active_player if setup else "R%d · P%d turn" % [round_number, active_player]
	owner_caption = "PLAYER %d DECIDES" % decision_player if decision_player in [1, 2] else "WAITING"
	set_decision_kind("")
	owner_label.tooltip_text = "Turn ownership and the current decision owner are separate."
	owner_label.add_theme_color_override("font_color", WorkspaceTheme.GOLD if other_decides else WorkspaceTheme.TEXT)
	round_label.text = caption
	round_label.tooltip_text = "Round %d · Player %d's turn · Player %d decides" % [round_number, active_player, decision_player]
	_fit_round_label()
	round_label.add_theme_color_override("font_color", WorkspaceTheme.GOLD_HIGHLIGHT if other_decides else WorkspaceTheme.TEXT)

func set_decision_kind(kind: String) -> void:
	owner_label.text = owner_caption if kind.is_empty() else "%s · %s" % [kind.to_upper(), owner_caption]

func set_connection(summary: String, details: String) -> void:
	connection_summary = summary
	connection_details = details

func set_complete(round_number: int) -> void:
	result_recorded = true
	owner_label.text = "RECORDED RESULT"
	round_label.text = "Result"
	round_label.tooltip_text = "Recorded result · round %d" % round_number
	_fit_round_label()
	for step: String in STEP_ORDER:
		var chip: Label = step_labels[step]
		chip.text = STEP_LABELS[step]
		chip.add_theme_color_override("font_color", Color("7f8c86"))
		chip.remove_theme_stylebox_override("normal")

func set_focus_available(available: bool) -> void:
	focus_available = available

func set_focus_binding_label(key_label: String) -> void:
	focus_binding = key_label

func set_army_open(open: bool) -> void:
	army_open = open

func set_mission_available(available: bool) -> void:
	mission_available = available

func set_command_panel_open(open: bool) -> void:
	command_panel_button.text = "Hide" if open else "Actions"
	command_panel_button.tooltip_text = "Hide the command panel." if open else "Show the command panel."

func set_guide_progress(active: bool, step: int = 0, total: int = 10) -> void:
	guide_progress = "GUIDE %d/%d" % [step, total] if active else ""

func set_score_text(text: String) -> void:
	score_text = text
	_format_score()

func _format_score() -> void:
	if objective_label == null: return
	objective_label.text = score_text.replace("   ", "\n") if get_viewport_rect().size.x < 1280.0 else score_text

func _refresh_tools_menu() -> void:
	tools_opening.emit()
	tools_button.get_popup().clear()
	if not connection_summary.is_empty():
		_add_tool(Tool.CONNECTION, connection_summary, false, connection_details)
	_add_tool(Tool.OVERVIEW, "Board overview")
	var focus_hint := "Center the camera on the selected unit."
	if not focus_binding.is_empty(): focus_hint += " Shortcut: %s." % focus_binding
	_add_tool(Tool.FOCUS, "Selected unit", focus_available, focus_hint)
	_add_tool(Tool.ACTIVE_ACTION, "Active action", active_action_available)
	_add_tool(Tool.PLAYER_1_SIDE, "Player 1 side")
	_add_tool(Tool.PLAYER_2_SIDE, "Player 2 side")
	_add_tool(Tool.DATASHEET, "Selected datasheet", focus_available)
	if not army_open:
		_add_tool(Tool.ARMY, "Army", true, "Show the army list and the selected model card.")
	if mission_available:
		_add_tool(Tool.MISSION, "Mission", true, "Read the mission score, objectives and latest resolved control values.")
	_add_tool(Tool.GUIDE, "Guide", true, "Open the field guide and full explanations.")
	_add_tool(Tool.HISTORY, "Log", true, "Open the battle log.")
	_add_tool(Tool.DIAGNOSTICS, "Diagnostics · Model warning" if asset_badge.visible else "Diagnostics")
	if not guide_progress.is_empty():
		_add_tool(Tool.GUIDE_PROGRESS, guide_progress, false, "Guided sample progress. The decision banner shows the current action.")

func _add_tool(id: Tool, caption: String, enabled: bool = true, hint: String = "") -> void:
	var popup := tools_button.get_popup()
	popup.add_item(caption, id)
	var index := popup.item_count - 1
	popup.set_item_disabled(index, not enabled)
	if not hint.is_empty(): popup.set_item_tooltip(index, hint)
	var icon_key := str(TOOL_ICONS.get(id, ""))
	if not icon_key.is_empty():
		var icon := DataslateIcons.texture(icon_key)
		if icon != null:
			popup.set_item_icon(index, icon)

func _activate_tool(id: int) -> void:
	match id:
		Tool.OVERVIEW: overview_requested.emit()
		Tool.FOCUS:
			if focus_available: focus_requested.emit()
		Tool.ACTIVE_ACTION:
			if active_action_available: active_action_requested.emit()
		Tool.PLAYER_1_SIDE: side_requested.emit(1)
		Tool.PLAYER_2_SIDE: side_requested.emit(2)
		Tool.DATASHEET:
			if focus_available: datasheet_requested.emit()
		Tool.ARMY:
			if not army_open: army_requested.emit()
		Tool.MISSION:
			if mission_available: mission_requested.emit()
		Tool.GUIDE: help_requested.emit()
		Tool.HISTORY: history_requested.emit()
		Tool.DIAGNOSTICS: diagnostics_requested.emit()

func _fit_hud() -> void:
	if objective_label == null: return
	var compact := get_viewport_rect().size.x < 1280.0
	objective_label.add_theme_font_size_override("font_size", 14 if compact else 15)
	for index in STEP_ORDER.size():
		var chip: Label = step_labels[STEP_ORDER[index]]
		chip.add_theme_font_size_override("font_size", 14 if compact else 15)
	_format_step_captions(compact)
	round_label.add_theme_font_size_override("font_size", 15 if compact else 16)
	for button: Control in [command_panel_button, tools_button, menu_button]:
		button.custom_minimum_size.x = 0
	var utility_button_width := maxf(command_panel_button.get_combined_minimum_size().x, maxf(tools_button.get_combined_minimum_size().x, menu_button.get_combined_minimum_size().x))
	for button: Control in [command_panel_button, tools_button, menu_button]:
		button.custom_minimum_size.x = utility_button_width
	_format_score()
	layout_changed.emit()
