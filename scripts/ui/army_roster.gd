extends VBoxContainer

## Read-only army list. Choosing a row only emits a local selection request.

signal model_chosen(model_id: int)
signal folds_changed(models_hidden: bool)

var _shown := ""
var _folded := {}
var _squad_ids: Array[int] = []
var _model_rows: Dictionary = {}
var _selected_id := -1

static func model_label(match_state: Dictionary, model_id: int) -> String:
	var units: Dictionary = match_state.get("units", {})
	if not units.has(model_id):
		return "Model"
	var unit: Dictionary = units[model_id]
	var squad_id := int(unit.get("squad", -1))
	var ids: Array[int] = []
	for id: int in units:
		if int(units[id].get("squad", -1)) == squad_id:
			ids.append(id)
	ids.sort()
	var place := ids.find(model_id) + 1
	if place < 1:
		place = 1
	var label := "Model %d" % place
	if bool(unit.get("sergeant", false)):
		label += " · Sergeant"
	return label

func present(match_state: Dictionary, selected_id: int, active_player: int) -> void:
	var digest := _digest(match_state, active_player)
	if digest == _shown:
		if selected_id != _selected_id:
			_set_selected_row(selected_id)
		return
	_shown = digest
	_selected_id = selected_id
	_model_rows.clear()
	var scroll := get_parent() as ScrollContainer
	var offset := scroll.scroll_vertical if scroll != null else 0
	for child in get_children():
		remove_child(child)
		child.queue_free()
	_squad_ids.clear()
	add_theme_constant_override("separation", 4)
	var units: Dictionary = match_state.get("units", {})
	var has_models := false
	for unit: Dictionary in units.values():
		if int(unit.get("owner", 0)) == active_player:
			has_models = true
			break
	if units.is_empty() or active_player <= 0 or not has_models:
		var empty := Label.new()
		empty.text = "No units for the active player."
		empty.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		add_child(empty)
		return
	_add_player(match_state, selected_id, active_player, active_player)
	if scroll != null:
		scroll.set_deferred("scroll_vertical", offset)

func _add_player(match_state: Dictionary, selected_id: int, owner: int, local_player: int) -> void:
	var squads: Array[int] = []
	var living := 0
	var shocked := 0
	for id: int in match_state.units:
		var unit: Dictionary = match_state.units[id]
		if int(unit.get("owner", 0)) != owner:
			continue
		if int(unit.get("wounds", 0)) > 0 and bool(unit.get("on_battlefield", true)):
			living += 1
		var squad_id := int(unit.squad)
		if squad_id not in squads:
			squads.append(squad_id)
			if bool(match_state.squads[squad_id].get("battle_shocked", false)) and _squad_has_living_model(match_state, squad_id):
				shocked += 1
	squads.sort_custom(func(a: int, b: int) -> bool:
		var left := str(match_state.squads[a].get("name", ""))
		var right := str(match_state.squads[b].get("name", ""))
		if left == right:
			return a < b
		return left < right
	)
	var heading := Label.new()
	heading.text = "Player %d  ·  %d living  ·  %d Battle-shocked" % [owner, living, shocked]
	heading.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	heading.add_theme_font_size_override("font_size", 13)
	heading.add_theme_color_override("font_color", Color("f2df83") if owner == local_player else Color("c4ced1"))
	heading.tooltip_text = "Living models on the battlefield, and units whose current Battle-shock result is failed."
	add_child(heading)
	for squad_id: int in squads:
		_add_squad(match_state, selected_id, squad_id)

func _squad_has_living_model(match_state: Dictionary, squad_id: int) -> bool:
	for unit: Dictionary in match_state.units.values():
		if int(unit.squad) == squad_id and int(unit.get("wounds", 0)) > 0 and bool(unit.get("on_battlefield", true)):
			return true
	return false

func _add_squad(match_state: Dictionary, selected_id: int, squad_id: int) -> void:
	var squad: Dictionary = match_state.squads[squad_id]
	var model_ids: Array[int] = []
	var alive := 0
	for id: int in match_state.units:
		var unit: Dictionary = match_state.units[id]
		if int(unit.squad) != squad_id:
			continue
		model_ids.append(id)
		if int(unit.get("wounds", 0)) > 0 and bool(unit.get("on_battlefield", true)):
			alive += 1
	model_ids.sort()
	var shocked := bool(squad.get("battle_shocked", false)) and alive > 0
	var shock_text := "Battle-shocked" if shocked else "Steady"
	var header_id := model_ids[0]
	for id: int in model_ids:
		if int(match_state.units[id].get("wounds", 0)) > 0:
			header_id = id
			break
	_squad_ids.append(squad_id)
	var folded := bool(_folded.get(squad_id, false))
	var heading_row := HBoxContainer.new()
	heading_row.add_theme_constant_override("separation", 4)
	add_child(heading_row)
	var fold := Button.new()
	fold.name = "SquadFold%d" % squad_id
	fold.text = "▸" if folded else "▾"
	fold.custom_minimum_size = Vector2(28, 28)
	fold.tooltip_text = "Show models in this unit." if folded else "Hide models in this unit."
	fold.focus_mode = Control.FOCUS_ALL
	fold.pressed.connect(_toggle_squad.bind(squad_id))
	heading_row.add_child(fold)
	var header := _row("%s  ·  %d/%d  ·  %s" % [squad.get("name", "Unit"), alive, model_ids.size(), shock_text], header_id, false, Color("f2b1a0") if shocked else Color("d5e4ea"))
	header.tooltip_text = "Select a living model in %s. %s is the unit's current Battle-shock result." % [squad.get("name", "Unit"), shock_text]
	header.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	heading_row.add_child(header)
	var models := VBoxContainer.new()
	models.name = "SquadModels%d" % squad_id
	models.visible = not folded
	models.add_theme_constant_override("separation", 2)
	add_child(models)
	for id: int in model_ids:
		var unit: Dictionary = match_state.units[id]
		var state_text := "W %d/%d" % [int(unit.get("wounds", 0)), int(unit.get("max_wounds", 0))]
		var color := Color("e6edf0")
		if not bool(unit.get("on_battlefield", true)):
			state_text = "Reserves"
			color = Color("b7c4ce")
		elif int(unit.get("wounds", 0)) <= 0:
			state_text = "Destroyed"
			color = Color("8a949b")
		var label := model_label(match_state, id)
		var row := _row("    %s  ·  %s" % [label, state_text], id, id == selected_id, color)
		_model_rows[id] = row
		row.tooltip_text = "Select %s and frame it. This does not spend an action." % label
		if "Sergeant" in label:
			row.tooltip_text += " Sergeant marks the one model that can use this unit's sergeant weapon options. It does not change wounds or Battle-shock."
		models.add_child(row)

func models_hidden() -> bool:
	if _squad_ids.is_empty():
		return false
	for squad_id: int in _squad_ids:
		if not bool(_folded.get(squad_id, false)):
			return false
	return true

func toggle_models() -> void:
	var hide := not models_hidden()
	for squad_id: int in _squad_ids:
		_folded[squad_id] = hide
	_apply_folds()
	folds_changed.emit(hide)

func _toggle_squad(squad_id: int) -> void:
	_folded[squad_id] = not bool(_folded.get(squad_id, false))
	_apply_folds()
	folds_changed.emit(models_hidden())

func _set_selected_row(selected_id: int) -> void:
	if _model_rows.has(_selected_id):
		_set_row_selected(_model_rows[_selected_id], false)
	if _model_rows.has(selected_id):
		_set_row_selected(_model_rows[selected_id], true)
	_selected_id = selected_id

func _set_row_selected(row: Button, selected: bool) -> void:
	var normal := _row_style(selected, false)
	var hover := _row_style(selected, true)
	row.add_theme_stylebox_override("normal", normal)
	row.add_theme_stylebox_override("hover", hover)
	row.add_theme_stylebox_override("pressed", hover)
	row.add_theme_stylebox_override("focus", hover)

func _apply_folds() -> void:
	for squad_id: int in _squad_ids:
		var folded := bool(_folded.get(squad_id, false))
		var models := find_child("SquadModels%d" % squad_id, true, false) as Control
		if models != null:
			models.visible = not folded
		var fold := find_child("SquadFold%d" % squad_id, true, false) as Button
		if fold != null:
			fold.text = "▸" if folded else "▾"
			fold.tooltip_text = "Show models in this unit." if folded else "Hide models in this unit."

func _row(text: String, model_id: int, selected: bool, color: Color) -> Button:
	var button := Button.new()
	button.text = text
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	button.focus_mode = Control.FOCUS_ALL
	button.add_theme_font_size_override("font_size", 13)
	button.add_theme_color_override("font_color", color)
	button.add_theme_color_override("font_hover_color", color)
	button.add_theme_color_override("font_pressed_color", color)
	button.add_theme_color_override("font_focus_color", color)
	var normal := _row_style(selected, false)
	var hover := _row_style(selected, true)
	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", hover)
	button.add_theme_stylebox_override("focus", hover)
	button.pressed.connect(func() -> void: model_chosen.emit(model_id))
	return button

func _row_style(selected: bool, hover: bool) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color("243226") if selected else Color("1b2730") if hover else Color(0, 0, 0, 0)
	style.set_corner_radius_all(4)
	style.content_margin_left = 6
	style.content_margin_right = 6
	style.content_margin_top = 3
	style.content_margin_bottom = 3
	if selected:
		style.border_color = Color("d9aa4f")
		style.set_border_width_all(1)
	return style

func _digest(match_state: Dictionary, local_player: int) -> String:
	var ids: Array[int] = []
	for id: int in match_state.get("units", {}):
		ids.append(id)
	ids.sort()
	var parts: PackedStringArray = PackedStringArray([str(local_player)])
	for id: int in ids:
		var unit: Dictionary = match_state.units[id]
		var squad: Dictionary = match_state.squads.get(unit.squad, {})
		parts.append("%d:%s:%s:%s:%s:%s:%s:%s:%s" % [id, unit.get("owner", 0), squad.get("name", ""), unit.squad, unit.get("sergeant", false), unit.get("wounds", 0), unit.get("max_wounds", 0), unit.get("on_battlefield", true), squad.get("battle_shocked", false)])
	return "|".join(parts)
