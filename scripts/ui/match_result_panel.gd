extends PanelContainer
const MatchResult = preload("res://scripts/match_result.gd")
const WorkspaceTheme = preload("res://scripts/ui/workspace_theme.gd")

signal rematch_requested
signal copy_requested
signal save_requested
signal armies_requested
signal menu_requested
signal folder_requested(path: String)

var title: Label
var scores: Label
var scenario: Label
var rematch_button: Button
var rematch_note: Label
var details: Label
var notice: Label
var folder_button: Button
var armies_button: Button
var result_path := ""

func _ready() -> void:
	theme = WorkspaceTheme.create()
	add_theme_stylebox_override("panel", WorkspaceTheme.box(WorkspaceTheme.SURFACE, WorkspaceTheme.GOLD, 14, 2, 2))
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 10)
	add_child(column)
	title = _label(column, 24)
	title.add_theme_color_override("font_color", WorkspaceTheme.GOLD_HIGHLIGHT)
	scores = _label(column, 22)
	scenario = _label(column, 14)
	rematch_button = _button(column, "Rematch · same armies", func(): rematch_requested.emit(), "rematch", true)
	rematch_button.custom_minimum_size.y = 44
	rematch_button.tooltip_text = "Uses the admitted starting armies and match options. Mission setup, army declarations and deployment start again; in-match choices are not copied."
	rematch_note = _label(column, 14)
	var actions := GridContainer.new()
	actions.columns = 2
	actions.add_theme_constant_override("h_separation", 6)
	actions.add_theme_constant_override("v_separation", 6)
	column.add_child(actions)
	_button(actions, "Copy result", func(): copy_requested.emit(), "copy")
	_button(actions, "Save result", func(): save_requested.emit(), "save")
	armies_button = _button(actions, "Review armies", func(): armies_requested.emit(), "armies")
	armies_button.visible = false
	_button(actions, "Main menu", func(): menu_requested.emit(), "menu")
	var toggle := CheckButton.new()
	toggle.text = "Result details"
	column.add_child(toggle)
	details = _label(column, 13)
	details.visible = false
	toggle.toggled.connect(func(expanded: bool): details.visible = expanded)
	notice = _label(column, 14)
	notice.visible = false
	folder_button = _button(column, "Open result folder", func(): folder_requested.emit(result_path), "folder")
	folder_button.visible = false

func _label(parent: Node, font_size: int) -> Label:
	var label := Label.new()
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.max_lines_visible = -1
	label.text_overrun_behavior = TextServer.OVERRUN_NO_TRIMMING
	label.custom_minimum_size.x = 100
	label.add_theme_font_size_override("font_size", font_size)
	parent.add_child(label)
	return label

func _button(parent: Node, text: String, callback: Callable, icon_key: String = "", make_primary: bool = false) -> Button:
	var button := Button.new()
	button.text = text
	button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	button.clip_text = false
	button.text_overrun_behavior = TextServer.OVERRUN_NO_TRIMMING
	button.custom_minimum_size.y = 36
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.pressed.connect(callback)
	WorkspaceTheme.decorate_button(button, icon_key, make_primary)
	parent.add_child(button)
	return button

func show_result(record: Dictionary, can_rematch: bool, reason: String) -> void:
	title.text = "DRAW" if record.winner == -1 else "PLAYER %d WINS" % record.winner
	scores.visible = not record.scores.is_empty()
	if scores.visible: scores.text = "P1  %d VP   ·   P2  %d VP" % [record.scores.P1, record.scores.P2]
	scenario.text = "%s · Round %d" % [record.scenario, record.round]
	rematch_button.disabled = not can_rematch
	rematch_button.text = "Restart this lab" if record.scenario == "Synthetic rules lab" else "Rematch · same armies"
	rematch_note.text = reason
	rematch_note.visible = not reason.is_empty()
	details.text = MatchResult.details_text(record)

func show_notice(message: String) -> void:
	notice.text = message
	notice.visible = not message.is_empty()

func show_saved(path: String) -> void:
	result_path = path
	folder_button.visible = not path.is_empty()
	folder_button.tooltip_text = path

func set_workshop_available(available: bool) -> void:
	if armies_button != null: armies_button.visible = available
