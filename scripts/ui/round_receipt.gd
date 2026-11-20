extends PanelContainer
## Compact, non-blocking round-end objective scoring receipt.
## Read-only presentation; never computes OC or mutates match state.

signal mission_requested

const WorkspaceTheme = preload("res://scripts/ui/workspace_theme.gd")

var summary_label := Label.new()
var totals_label := Label.new()
var details_button := Button.new()
var dismiss_button := Button.new()
var _current_round := -1
var _dismissed_round := -1
var _shown_signature := ""

func _ready() -> void:
	theme = WorkspaceTheme.create()
	add_theme_stylebox_override("panel", WorkspaceTheme.box(WorkspaceTheme.ELEVATED, WorkspaceTheme.GOLD, 8, 1, 2))
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 4)
	add_child(column)
	summary_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	summary_label.text_overrun_behavior = TextServer.OVERRUN_NO_TRIMMING
	summary_label.add_theme_font_size_override("font_size", 13)
	summary_label.add_theme_color_override("font_color", WorkspaceTheme.TEXT)
	column.add_child(summary_label)
	totals_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	totals_label.text_overrun_behavior = TextServer.OVERRUN_NO_TRIMMING
	totals_label.add_theme_font_size_override("font_size", 12)
	totals_label.add_theme_color_override("font_color", WorkspaceTheme.MUTED)
	column.add_child(totals_label)
	var actions := HBoxContainer.new()
	actions.add_theme_constant_override("separation", 8)
	column.add_child(actions)
	details_button.text = "Mission details"
	details_button.custom_minimum_size = Vector2(0, 32)
	details_button.focus_mode = Control.FOCUS_ALL
	details_button.tooltip_text = "Open the Mission overview screen. Read-only."
	details_button.pressed.connect(func(): mission_requested.emit())
	actions.add_child(details_button)
	dismiss_button.text = "Dismiss"
	dismiss_button.custom_minimum_size = Vector2(0, 32)
	dismiss_button.focus_mode = Control.FOCUS_ALL
	dismiss_button.pressed.connect(_dismiss)
	actions.add_child(dismiss_button)
	visible = false

func reset() -> void:
	_current_round = -1
	_dismissed_round = -1
	_shown_signature = ""
	visible = false

func present(receipt: Dictionary) -> void:
	if receipt.is_empty():
		visible = false
		_shown_signature = ""
		return
	var round_number := int(receipt.get("round", 0))
	if round_number != _current_round:
		_current_round = round_number
		if round_number != _dismissed_round:
			_dismissed_round = -1
	if round_number == _dismissed_round:
		visible = false
		return
	var signature := var_to_str(receipt)
	if signature != _shown_signature:
		_shown_signature = signature
		summary_label.text = str(receipt.get("summary", ""))
		totals_label.text = "%s · %s" % [str(receipt.get("totals", "")), str(receipt.get("timing_note", ""))]
	visible = true

func _dismiss() -> void:
	_dismissed_round = _current_round
	visible = false
