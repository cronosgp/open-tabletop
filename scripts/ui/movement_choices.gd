extends VBoxContainer
## Presentation only. The caller supplies the current validator results.

signal choice_selected(index: int)

const LABELS := ["Normal move", "Advance · D6", "Fall Back", "Desperate Escape", "Stationary"]
const STAGES := ["Unit", "Move", "Place", "Confirm"]

var choices: Array[Button] = []
var stages: Array[Label] = []
var grid: GridContainer
var instruction: Label
var unavailable: Label

func _ready() -> void:
	add_theme_constant_override("separation", 8)
	var flow := HFlowContainer.new()
	flow.add_theme_constant_override("h_separation", 10)
	add_child(flow)
	for index in STAGES.size():
		var label := Label.new()
		label.text = "%d %s" % [index + 1, STAGES[index]]
		label.add_theme_font_size_override("font_size", 13)
		flow.add_child(label)
		stages.append(label)
	grid = GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 6)
	grid.add_theme_constant_override("v_separation", 6)
	add_child(grid)
	var group := ButtonGroup.new()
	for index in LABELS.size():
		var button := Button.new()
		button.text = LABELS[index]
		button.toggle_mode = true
		button.button_group = group
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.custom_minimum_size.y = 36
		button.pressed.connect(func(): choice_selected.emit(index))
		grid.add_child(button)
		choices.append(button)
	instruction = Label.new()
	instruction.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	instruction.add_theme_font_size_override("font_size", 14)
	add_child(instruction)
	unavailable = Label.new()
	unavailable.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	unavailable.max_lines_visible = 4
	unavailable.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	unavailable.add_theme_font_size_override("font_size", 13)
	unavailable.add_theme_color_override("font_color", Color("f2b1a0"))
	unavailable.visible = false
	add_child(unavailable)

func configure(choice: int, errors: Array[String], references: Array[String], stage: int, choosing: bool, message: String) -> void:
	grid.visible = choosing
	instruction.text = message
	for index in stages.size():
		var marker := "✓" if index < stage else ("Now" if index == stage else str(index + 1))
		stages[index].text = "%s %s" % [marker, STAGES[index]]
		stages[index].add_theme_color_override("font_color", Color("f2df83") if index == stage else Color("a5afb5"))
	for index in choices.size():
		var button := choices[index]
		button.set_pressed_no_signal(index == choice)
		button.disabled = not errors[index].is_empty()
		button.text = ("✓ " if index == choice else "") + LABELS[index] + (" ×" if button.disabled else "")
		button.tooltip_text = references[index] if errors[index].is_empty() else errors[index] + "\n\n" + references[index]
	var seen: Dictionary = {}
	var notes: Array[String] = []
	for index in choices.size():
		var error := errors[index]
		if error.is_empty() or seen.has(error): continue
		seen[error] = true
		var names: Array[String] = []
		for other in choices.size():
			if errors[other] == error: names.append(LABELS[other])
		notes.append("%s · %s" % [", ".join(names), error])
	unavailable.text = "\n".join(notes)
	unavailable.tooltip_text = unavailable.text
	unavailable.visible = choosing and not notes.is_empty()
