extends PanelContainer
## Pins the existing authoritative action controls. No new command or legality.
const WorkspaceTheme = preload("res://scripts/ui/workspace_theme.gd")
var primary_slot := VBoxContainer.new()
var secondary_slot := HFlowContainer.new()
var choice := Label.new()
var reason := Label.new()
var sources: Array[Dictionary] = []
var previous_focus: WeakRef

func _ready() -> void:
	theme = WorkspaceTheme.create()
	add_theme_stylebox_override("panel", WorkspaceTheme.box(WorkspaceTheme.SURFACE, WorkspaceTheme.GOLD, 10, 2, 2))
	var column := VBoxContainer.new()
	add_child(column)
	choice.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	choice.text_overrun_behavior = TextServer.OVERRUN_NO_TRIMMING
	choice.add_theme_color_override("font_color", WorkspaceTheme.TEXT)
	choice.visible = false
	column.add_child(choice)
	reason.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	reason.text_overrun_behavior = TextServer.OVERRUN_NO_TRIMMING
	reason.add_theme_color_override("font_color", WorkspaceTheme.MUTED)
	column.add_child(reason)
	column.add_child(primary_slot)
	secondary_slot.add_theme_constant_override("h_separation", 8)
	secondary_slot.add_theme_constant_override("v_separation", 8)
	column.add_child(secondary_slot)
	visible = false

func restore() -> void:
	var focused := get_viewport().gui_get_focus_owner() if is_inside_tree() else null
	var owned_focus := false
	for record: Dictionary in sources:
		if is_instance_valid(record.source) and record.source == focused: owned_focus = true
	if focused != null and not owned_focus: previous_focus = null
	for record: Dictionary in sources:
		if not is_instance_valid(record.source): continue
		var source: Button = record.source
		if source == focused: previous_focus = weakref(source)
		if not is_instance_valid(record.parent):
			if source.get_parent() != null: source.get_parent().remove_child(source)
			source.queue_free()
			continue
		source.reparent(record.parent, false)
		record.parent.move_child(source, mini(int(record.index), record.parent.get_child_count() - 1))
		source.custom_minimum_size = record.minimum
		source.autowrap_mode = record.wrap
		source.theme_type_variation = record.variation
		source.size_flags_horizontal = record.horizontal
	sources.clear()

func _pin(source: Button, destination: Container, primary: bool) -> void:
	sources.append({"source":source,"parent":source.get_parent(),"index":source.get_index(),"minimum":source.custom_minimum_size,"wrap":source.autowrap_mode,"variation":source.theme_type_variation,"horizontal":source.size_flags_horizontal})
	source.reparent(destination, false)
	source.custom_minimum_size = Vector2(0 if primary else 120, maxf(44, source.custom_minimum_size.y))
	source.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	source.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	if primary: source.theme_type_variation = &"MatchPrimaryAction"

func present(primary: Button, secondary: Array[Button], disabled_reason: String, allow_focus: bool, choice_text: String = "") -> void:
	if not sources.is_empty(): restore()
	visible = primary != null
	if primary == null:
		choice.text = ""
		choice.visible = false
		previous_focus = null
		return
	choice.text = choice_text
	choice.visible = not choice_text.is_empty()
	reason.text = disabled_reason
	reason.visible = primary.disabled and not disabled_reason.is_empty()
	_pin(primary, primary_slot, true)
	for source: Button in secondary:
		if source != primary: _pin(source, secondary_slot, false)
	secondary_slot.visible = not secondary.is_empty()
	if allow_focus and previous_focus != null:
		var focused = previous_focus.get_ref()
		var still_owned := false
		for record: Dictionary in sources:
			if is_instance_valid(record.source) and record.source == focused: still_owned = true
		if is_instance_valid(focused) and focused is Button and still_owned and focused.is_visible_in_tree():
			if not focused.disabled:
				focused.grab_focus()
				previous_focus = null
		else: previous_focus = null
	else: previous_focus = null
