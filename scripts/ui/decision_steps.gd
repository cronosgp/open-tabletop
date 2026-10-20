extends VBoxContainer
## A compact progress strip; it does not execute or validate game actions.

var strip: HFlowContainer
var instruction: Label
var labels: Array[Label] = []
var current_steps: Array[String] = []

func _ready() -> void:
	add_theme_constant_override("separation", 6)
	strip = HFlowContainer.new()
	strip.add_theme_constant_override("h_separation", 10)
	add_child(strip)
	instruction = Label.new()
	instruction.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	instruction.add_theme_font_size_override("font_size", 14)
	add_child(instruction)

func configure(steps: Array[String], active: int, message: String) -> void:
	if steps != current_steps:
		for label: Label in labels: label.free()
		labels.clear()
		current_steps = steps.duplicate()
		for step: String in steps:
			var label := Label.new()
			label.add_theme_font_size_override("font_size", 13)
			strip.add_child(label)
			labels.append(label)
	for index in labels.size():
		labels[index].text = "%s %s" % ["✓" if index < active else str(index + 1), steps[index]]
		labels[index].add_theme_color_override("font_color", Color("f2df83") if index == active else Color("a5afb5"))
	instruction.text = message
