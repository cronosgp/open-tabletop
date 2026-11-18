extends VBoxContainer
## Read-only mission dashboard. Mission rules and scoring remain in the match controller.

signal focus_requested(objective_index: int)

const WorkspaceTheme = preload("res://scripts/ui/workspace_theme.gd")
const CARD_BORDER := Color("47545d")
const CARD_HOVER := Color("73828a")

var mission_title := Label.new()
var mission_subtitle := Label.new()
var score_row := HBoxContainer.new()
var score_cards: Array[Dictionary] = []
var details_panel := PanelContainer.new()
var details_list := VBoxContainer.new()
var objectives_heading := Label.new()
var objective_list := VBoxContainer.new()
var timing_note := Label.new()
var history_heading := Label.new()
var history_list := VBoxContainer.new()
var empty_objectives := Label.new()
var objective_cards: Array[Dictionary] = []
var objective_count := -1
var _shown_signature := ""

func _ready() -> void:
	theme = WorkspaceTheme.create()
	add_theme_constant_override("separation", 14)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	mission_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	mission_title.text_overrun_behavior = TextServer.OVERRUN_NO_TRIMMING
	mission_title.add_theme_font_size_override("font_size", 24)
	mission_title.add_theme_color_override("font_color", WorkspaceTheme.TEXT)
	add_child(mission_title)
	mission_subtitle.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	mission_subtitle.text_overrun_behavior = TextServer.OVERRUN_NO_TRIMMING
	mission_subtitle.add_theme_font_size_override("font_size", 14)
	mission_subtitle.add_theme_color_override("font_color", WorkspaceTheme.MUTED)
	add_child(mission_subtitle)
	score_row.add_theme_constant_override("separation", 12)
	add_child(score_row)
	for player: int in [1, 2]:
		score_cards.append(_make_score_card(player))
		score_row.add_child(score_cards[-1].panel)
	details_panel.add_theme_stylebox_override("panel", WorkspaceTheme.box(WorkspaceTheme.ELEVATED, CARD_BORDER, 12, 1, 4))
	details_list.add_theme_constant_override("separation", 4)
	details_panel.add_child(details_list)
	add_child(details_panel)
	objectives_heading = WorkspaceTheme.heading(self, "OBJECTIVES")
	objectives_heading.add_theme_font_size_override("font_size", 14)
	objective_list.add_theme_constant_override("separation", 8)
	add_child(objective_list)
	empty_objectives.text = "This exercise does not use objective scoring."
	empty_objectives.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	empty_objectives.text_overrun_behavior = TextServer.OVERRUN_NO_TRIMMING
	empty_objectives.add_theme_color_override("font_color", WorkspaceTheme.MUTED)
	add_child(empty_objectives)
	timing_note.text = "Control and OC show the latest resolved phase result. Movement previews do not update these values; the next relevant phase boundary does."
	timing_note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	timing_note.text_overrun_behavior = TextServer.OVERRUN_NO_TRIMMING
	timing_note.add_theme_color_override("font_color", WorkspaceTheme.MUTED)
	timing_note.add_theme_font_size_override("font_size", 14)
	add_child(timing_note)
	history_heading = WorkspaceTheme.heading(self, "RECENT SCORING EVENTS")
	history_heading.add_theme_font_size_override("font_size", 14)
	history_list.add_theme_constant_override("separation", 4)
	add_child(history_list)

func present(view_model: Dictionary) -> void:
	var signature := var_to_str(view_model)
	if signature == _shown_signature:
		return
	_shown_signature = signature
	mission_title.text = str(view_model.get("title", "Mission"))
	mission_subtitle.text = str(view_model.get("subtitle", ""))
	var scores: Array = view_model.get("scores", [])
	score_row.visible = bool(view_model.get("show_scores", true))
	for index in range(score_cards.size()):
		var data: Dictionary = scores[index] if index < scores.size() else {}
		var card: Dictionary = score_cards[index]
		card.player_label.text = str(data.get("label", "Player %d" % (index + 1)))
		card.total_label.text = "%d VP" % int(data.get("total", 0))
		card.breakdown_label.text = str(data.get("breakdown", ""))
		card.details_label.text = "\n".join(data.get("details", []))
		card.details_label.visible = not card.details_label.text.is_empty()
	var detail_lines: Array = view_model.get("details", [])
	_sync_text_rows(details_list, detail_lines, 14)
	details_panel.visible = not detail_lines.is_empty()
	var objectives: Array = view_model.get("objectives", [])
	_sync_objective_cards(objectives)
	objectives_heading.visible = not objectives.is_empty()
	empty_objectives.visible = objectives.is_empty()
	timing_note.visible = not objectives.is_empty()
	var history: Array = view_model.get("history", [])
	_sync_text_rows(history_list, history, 14)
	if history.is_empty():
		_sync_text_rows(history_list, ["No scoring event recorded yet."], 14)

func _make_score_card(player: int) -> Dictionary:
	var panel := PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.add_theme_stylebox_override("panel", WorkspaceTheme.box(WorkspaceTheme.SURFACE, CARD_BORDER, 12, 1, 4))
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 4)
	panel.add_child(column)
	var player_label := Label.new()
	player_label.text = "PLAYER %d" % player
	player_label.add_theme_font_size_override("font_size", 13)
	player_label.add_theme_color_override("font_color", WorkspaceTheme.MUTED)
	column.add_child(player_label)
	var total_label := Label.new()
	total_label.text = "0 VP"
	total_label.add_theme_font_size_override("font_size", 30)
	total_label.add_theme_color_override("font_color", WorkspaceTheme.GOLD_HIGHLIGHT if player == 1 else WorkspaceTheme.TEXT)
	column.add_child(total_label)
	var breakdown_label := Label.new()
	breakdown_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	breakdown_label.text_overrun_behavior = TextServer.OVERRUN_NO_TRIMMING
	breakdown_label.add_theme_font_size_override("font_size", 14)
	column.add_child(breakdown_label)
	var details_label := Label.new()
	details_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	details_label.text_overrun_behavior = TextServer.OVERRUN_NO_TRIMMING
	details_label.add_theme_font_size_override("font_size", 13)
	details_label.add_theme_color_override("font_color", WorkspaceTheme.MUTED)
	column.add_child(details_label)
	return {"panel": panel, "player_label": player_label, "total_label": total_label, "breakdown_label": breakdown_label, "details_label": details_label}

func _sync_objective_cards(objectives: Array) -> void:
	if objective_count != objectives.size():
		for child in objective_list.get_children():
			objective_list.remove_child(child)
			child.queue_free()
		objective_cards.clear()
		objective_count = objectives.size()
		for index in objective_count:
			var card := _make_objective_card(index)
			objective_cards.append(card)
			objective_list.add_child(card.panel)
	for index in range(mini(objectives.size(), objective_cards.size())):
		var data: Dictionary = objectives[index]
		var card: Dictionary = objective_cards[index]
		card.name_label.text = str(data.get("name", "Objective"))
		card.control_label.text = str(data.get("control", "Neutral"))
		card.p1_label.text = "P1 OC  %d" % int(data.get("p1_oc", 0))
		card.p2_label.text = "P2 OC  %d" % int(data.get("p2_oc", 0))
		card.focus_button.visible = bool(data.get("focus_available", false))
		card.focus_button.disabled = not card.focus_button.visible

func _make_objective_card(index: int) -> Dictionary:
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", WorkspaceTheme.box(WorkspaceTheme.ELEVATED, CARD_BORDER, 12, 1, 4))
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 6)
	panel.add_child(column)
	var top := HBoxContainer.new()
	top.add_theme_constant_override("separation", 8)
	column.add_child(top)
	var name_label := Label.new()
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	name_label.text_overrun_behavior = TextServer.OVERRUN_NO_TRIMMING
	name_label.add_theme_font_size_override("font_size", 16)
	top.add_child(name_label)
	var focus_button := Button.new()
	focus_button.text = "Focus on board"
	focus_button.tooltip_text = "Close this screen and center the camera on this objective. Camera only."
	focus_button.focus_mode = Control.FOCUS_ALL
	WorkspaceTheme.decorate_button(focus_button, "focus")
	focus_button.add_theme_stylebox_override("normal", WorkspaceTheme.box(WorkspaceTheme.ELEVATED, CARD_BORDER, 10, 1, 3))
	focus_button.add_theme_stylebox_override("hover", WorkspaceTheme.box(WorkspaceTheme.HOVER, CARD_HOVER, 10, 1, 3))
	focus_button.add_theme_stylebox_override("pressed", WorkspaceTheme.box(WorkspaceTheme.HOVER, CARD_BORDER, 10, 1, 3))
	focus_button.add_theme_stylebox_override("focus", WorkspaceTheme.box(WorkspaceTheme.ELEVATED, WorkspaceTheme.GOLD_HIGHLIGHT, 10, 2, 3))
	focus_button.add_theme_stylebox_override("disabled", WorkspaceTheme.box(WorkspaceTheme.SURFACE, CARD_BORDER, 10, 1, 3))
	focus_button.pressed.connect(func() -> void: focus_requested.emit(index))
	top.add_child(focus_button)
	var control_label := Label.new()
	control_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	control_label.text_overrun_behavior = TextServer.OVERRUN_NO_TRIMMING
	control_label.add_theme_color_override("font_color", WorkspaceTheme.TEXT)
	column.add_child(control_label)
	var oc_row := HBoxContainer.new()
	oc_row.add_theme_constant_override("separation", 8)
	var p1_label := Label.new()
	var p2_label := Label.new()
	for label in [p1_label, p2_label]:
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		label.add_theme_color_override("font_color", WorkspaceTheme.TEXT)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		var cell := PanelContainer.new()
		cell.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		cell.add_theme_stylebox_override("panel", WorkspaceTheme.box(WorkspaceTheme.SURFACE, CARD_BORDER, 8, 1, 3))
		cell.add_child(label)
		oc_row.add_child(cell)
	column.add_child(oc_row)
	return {"panel": panel, "name_label": name_label, "control_label": control_label, "p1_label": p1_label, "p2_label": p2_label, "focus_button": focus_button}

func _sync_text_rows(container: VBoxContainer, rows: Array, font_size: int) -> void:
	while container.get_child_count() > rows.size():
		var child := container.get_child(container.get_child_count() - 1)
		container.remove_child(child)
		child.queue_free()
	while container.get_child_count() < rows.size():
		var label := Label.new()
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		label.text_overrun_behavior = TextServer.OVERRUN_NO_TRIMMING
		label.add_theme_font_size_override("font_size", font_size)
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		container.add_child(label)
	for index in range(rows.size()):
		var label := container.get_child(index) as Label
		label.text = str(rows[index])

