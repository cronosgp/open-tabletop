extends VBoxContainer
## Browses existing legal choices only; confirmation stays in the command service.
signal choice_selected(choice: Dictionary)
const Doctrines = preload("res://scripts/edition_11/combat_doctrines.gd")
const DetachmentStratagems = preload("res://scripts/edition_11/detachment_stratagems.gd")
const EFFECTS := {"devastator": "Shoot after Advance.", "tactical": "Shoot and declare a charge after Fall Back.", "assault": "Declare a charge after Advance."}
var action_picker: OptionButton
var unit_picker: OptionButton
var doctrine_picker: OptionButton
var explanation: Label
var confirmation_text := "Confirm doctrine"
var _choices: Array = []
var _state: Dictionary = {}
var _chosen: Dictionary = {}

func _ready() -> void:
	add_theme_constant_override("separation", 6)
	action_picker = _picker("1 · Choose ability or stratagem")
	unit_picker = _picker("2 · Choose the affected unit")
	doctrine_picker = _picker("3 · Choose a combat doctrine")
	explanation = Label.new()
	explanation.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	add_child(explanation)
	action_picker.item_selected.connect(_choose_action)
	unit_picker.item_selected.connect(_choose_unit)
	doctrine_picker.item_selected.connect(_choose_doctrine)

func _picker(description: String) -> OptionButton:
	var picker := OptionButton.new()
	picker.fit_to_longest_item = false
	picker.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	picker.custom_minimum_size.y = 40
	picker.tooltip_text = description
	add_child(picker)
	return picker

static func category(choice: Dictionary) -> String:
	if str(choice.get("value", "")) in EFFECTS:
		if choice.get("action", "") == "acumen": return "acumen"
		if choice.get("action", "") == "detachment-stratagem":
			return "tactical-mastery" if str(choice.get("stratagem", "")) == DetachmentStratagems.TACTICAL_MASTERY else "adaptive"
	return "other"

func sync(state: Dictionary, choices: Array, selected: Dictionary, waiting: bool) -> Dictionary:
	_state = state
	_choices = choices
	visible = false
	for choice: Dictionary in choices:
		if category(choice) != "other": visible = true
	if not visible:
		_chosen = {}
		return selected
	var preferred := selected
	if _chosen.is_empty():
		for choice: Dictionary in choices:
			if category(choice) == "acumen":
				preferred = choice
				break
	_chosen = preferred
	_rebuild()
	for picker: OptionButton in [action_picker, unit_picker, doctrine_picker]: picker.disabled = waiting
	return _chosen

func _rebuild() -> void:
	var group := category(_chosen)
	action_picker.clear()
	for key: String in ["acumen", "adaptive", "tactical-mastery", "other"]:
		var offered := false
		for choice: Dictionary in _choices:
			if category(choice) == key: offered = true
		if not offered: continue
		action_picker.add_item({"acumen": "Captain ability · 0 CP", "adaptive": "Adaptive Strategy · stratagem", "tactical-mastery": "Tactical Mastery · stratagem", "other": "Other abilities"}[key])
		var index := action_picker.item_count - 1
		action_picker.set_item_metadata(index, key)
		if key == group: action_picker.select(index)
	unit_picker.clear()
	doctrine_picker.clear()
	var targets: Array[int] = []
	for choice: Dictionary in _choices:
		if category(choice) != group: continue
		var target := int(choice.get("target", -1))
		if group == "other":
			unit_picker.add_item(str(choice.label))
			unit_picker.set_item_metadata(unit_picker.item_count - 1, choice)
			if choice == _chosen: unit_picker.select(unit_picker.item_count - 1)
			continue
		if target not in targets:
			targets.append(target)
			unit_picker.add_item("Unit: " + str(_state.squads[target].name), target)
		if target == int(_chosen.target):
			unit_picker.select(unit_picker.get_item_index(target))
			doctrine_picker.add_item(str(choice.value).capitalize())
			doctrine_picker.set_item_metadata(doctrine_picker.item_count - 1, choice)
			if choice == _chosen: doctrine_picker.select(doctrine_picker.item_count - 1)
	doctrine_picker.visible = group != "other"
	explanation.visible = group != "other"
	if group == "other": return
	var cp := "0"
	if group in ["adaptive", "tactical-mastery"]:
		var pattern := RegEx.new()
		pattern.compile("([0-9]+) CP")
		var cost := pattern.search(str(_chosen.label))
		cp = cost.get_string(1) if cost != null else "?"
	var title := "Strategic Acumen" if group == "acumen" else ("Tactical Mastery" if group == "tactical-mastery" else "Adaptive Strategy")
	confirmation_text = "Use %s · %s CP" % [title, cp]
	var value := str(_chosen.value)
	explanation.text = "%s · %s CP\n%s\nUntil the start of your next Command phase, this doctrine is active for the unit." % [title, cp, EFFECTS[value]]
	if Doctrines.active_for(_state, int(_chosen.target)) == value:
		explanation.text += "\nAlready active for this unit: no additional effect."
	elif not Doctrines.active_for(_state, int(_chosen.target)).is_empty():
		explanation.text += "\nCurrent: " + Doctrines.active_for(_state, int(_chosen.target)).capitalize()

func _choose_action(index: int) -> void:
	var group := str(action_picker.get_item_metadata(index))
	for choice: Dictionary in _choices:
		if category(choice) == group:
			choice_selected.emit(choice)
			return

func _choose_unit(index: int) -> void:
	var group := category(_chosen)
	if group == "other":
		choice_selected.emit(unit_picker.get_item_metadata(index))
		return
	var fallback: Dictionary = {}
	for choice: Dictionary in _choices:
		if category(choice) != group or int(choice.target) != unit_picker.get_item_id(index): continue
		if fallback.is_empty(): fallback = choice
		if str(choice.value) == str(_chosen.value):
			choice_selected.emit(choice)
			return
	if not fallback.is_empty(): choice_selected.emit(fallback)

func _choose_doctrine(index: int) -> void:
	choice_selected.emit(doctrine_picker.get_item_metadata(index))
