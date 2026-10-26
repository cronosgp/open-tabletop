extends ScrollContainer
## Local save-slot browser. Loading is read-only until main.gd completes full compatibility checks.
const MatchSave = preload("res://scripts/match_save.gd")

signal load_requested(slot: int)
signal save_requested(slot: int)

var records: Array[Dictionary] = []
var record_picker := OptionButton.new()
var summary := Label.new()
var status := Label.new()
var context_notice := Label.new()
var load_button := Button.new()
var save_button := Button.new()
var refresh_button := Button.new()
var overwrite_dialog := ConfirmationDialog.new()
var can_load := true
var can_save := false
var preferred_slot := 1
var pending_overwrite_slot := -1
var autosave_unassigned := false
var autosave_slot := 0


func _ready() -> void:
	horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	var column := VBoxContainer.new()
	column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	column.add_theme_constant_override("separation", 10)
	add_child(column)
	var intro := Label.new()
	intro.text = "Five local match slots. Each save keeps its own battle history. Loading checks the current rules and local data before replacing the active match."
	intro.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(intro)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	column.add_child(row)
	record_picker.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	record_picker.custom_minimum_size.y = 40
	record_picker.item_selected.connect(_show_selected)
	row.add_child(record_picker)
	refresh_button.text = "Reload"
	refresh_button.tooltip_text = "Read the five local save slots again."
	refresh_button.custom_minimum_size = Vector2(92, 40)
	refresh_button.pressed.connect(refresh_slots)
	row.add_child(refresh_button)
	summary.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	summary.custom_minimum_size.y = 56
	summary.add_theme_color_override("font_color", Color("e3b65c"))
	column.add_child(summary)
	status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	status.custom_minimum_size.y = 38
	column.add_child(status)
	context_notice.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	context_notice.custom_minimum_size.y = 38
	column.add_child(context_notice)
	var actions := HBoxContainer.new()
	actions.add_theme_constant_override("separation", 8)
	column.add_child(actions)
	load_button.text = "Load selected match"
	load_button.tooltip_text = "Run compatibility checks, then resume the selected local save."
	load_button.custom_minimum_size.y = 44
	load_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	load_button.pressed.connect(_request_load)
	actions.add_child(load_button)
	save_button.text = "Save current match here"
	save_button.tooltip_text = "Save the current local match to the selected slot."
	save_button.custom_minimum_size.y = 44
	save_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	save_button.pressed.connect(_request_save)
	actions.add_child(save_button)
	overwrite_dialog.title = "Overwrite local save"
	overwrite_dialog.ok_button_text = "Overwrite slot"
	overwrite_dialog.dialog_text = ""
	overwrite_dialog.confirmed.connect(_confirm_overwrite)
	add_child(overwrite_dialog)


func set_context(allow_load: bool, allow_save: bool, active_slot: int) -> void:
	can_load = allow_load
	can_save = allow_save
	autosave_unassigned = active_slot < 1
	autosave_slot = active_slot
	preferred_slot = clampi(active_slot, 1, MatchSave.SLOT_COUNT)
	refresh_slots()
	load_button.visible = can_load
	save_button.visible = can_save
	if can_save and autosave_unassigned:
		context_notice.text = "This match is not resumable until saved. Choose an empty slot, or choose an occupied slot and confirm replacement."
		context_notice.add_theme_color_override("font_color", Color("e5a394"))
	elif can_save:
		context_notice.text = "Accepted local actions autosave to Slot %d." % autosave_slot
		context_notice.add_theme_color_override("font_color", Color("9cc8a8"))
	else:
		context_notice.text = "Choose a slot to inspect its saved state."
		context_notice.remove_theme_color_override("font_color")


func refresh_slots() -> void:
	var selected_slot := _selected_slot() if record_picker.item_count > 0 else preferred_slot
	records = MatchSave.slot_records()
	record_picker.clear()
	for record: Dictionary in records:
		var slot := int(record.get("slot", -1))
		var label := "Slot %d · Empty" % slot
		if bool(record.get("exists", false)):
			if bool(record.get("valid", false)):
				var slot_summary := _compact_summary(str(record.get("summary", "Saved match")))
				if bool(record.get("recovered_from_backup", false)): slot_summary = "Recovered backup · " + slot_summary
				label = "Slot %d · %s" % [slot, slot_summary]
			else:
				label = "Slot %d · Save needs repair or replacement" % slot
		record_picker.add_item(label)
		var item_index := record_picker.item_count - 1
		record_picker.set_item_metadata(item_index, slot)
		var slot_tooltip := str(record.get("summary", "Saved match"))
		if bool(record.get("recovered_from_backup", false)): slot_tooltip = "Recovered backup · " + slot_tooltip
		if not str(record.get("error", "")).is_empty(): slot_tooltip += "\n" + str(record.error)
		record_picker.set_item_tooltip(item_index, slot_tooltip)
	var selected_index := 0
	for index in range(record_picker.item_count):
		if int(record_picker.get_item_metadata(index)) == selected_slot:
			selected_index = index
			break
	if record_picker.item_count > 0:
		record_picker.select(selected_index)
		_show_selected(selected_index)
	else:
		summary.text = "No local save slots are available."
		load_button.disabled = true
		save_button.disabled = true
	load_button.visible = can_load
	save_button.visible = can_save


func show_feedback(message: String, is_error: bool = false) -> void:
	status.text = message
	status.remove_theme_color_override("font_color")
	if not message.is_empty():
		status.add_theme_color_override("font_color", Color("e5a394") if is_error else Color("9cc8a8"))


func _selected_slot() -> int:
	if record_picker.item_count == 0 or record_picker.selected < 0: return preferred_slot
	return int(record_picker.get_item_metadata(record_picker.selected))


func _record_for_slot(slot: int) -> Dictionary:
	for record: Dictionary in records:
		if int(record.get("slot", -1)) == slot: return record
	return {}


func _show_selected(index: int) -> void:
	if index < 0 or index >= record_picker.item_count: return
	var record := _record_for_slot(int(record_picker.get_item_metadata(index)))
	var slot := int(record.get("slot", -1))
	if record.is_empty():
		summary.text = "No slot information is available."
		show_feedback("Reload the slot list, then select a slot.", true)
		load_button.disabled = true
		save_button.disabled = true
		return
	if not bool(record.get("exists", false)):
		summary.text = "Slot %d is empty. Saving here creates an independent local match save." % slot
		show_feedback("Choose an empty slot or select a saved match.")
	else:
		summary.text = str(record.get("summary", "Saved match"))
		if bool(record.get("valid", false)):
			if bool(record.get("recovered_from_backup", false)):
				show_feedback("Primary save unavailable (%s). A previous backup from %s is available; compatibility is checked again before loading." % [str(record.get("error", "unreadable")), _modified_text(int(record.get("modified", 0)))], true)
			else:
				show_feedback("Saved %s. Compatibility is checked again before loading." % _modified_text(int(record.get("modified", 0))))
		else:
			show_feedback(str(record.get("error", "This save cannot be read.")) + " You can overwrite it from an active local match.", true)
	load_button.disabled = not can_load or not bool(record.get("exists", false)) or not bool(record.get("valid", false))
	save_button.disabled = not can_save


func _request_load() -> void:
	var record := _record_for_slot(_selected_slot())
	if can_load and bool(record.get("valid", false)):
		load_requested.emit(int(record.slot))


func _request_save() -> void:
	if not can_save: return
	var slot := _selected_slot()
	var record := _record_for_slot(slot)
	if bool(record.get("exists", false)):
		pending_overwrite_slot = slot
		overwrite_dialog.dialog_text = "Overwrite Slot %d on this computer? This replaces that saved match." % slot
		overwrite_dialog.popup_centered()
		return
	save_requested.emit(slot)


func _confirm_overwrite() -> void:
	if pending_overwrite_slot < 1: return
	var slot := pending_overwrite_slot
	pending_overwrite_slot = -1
	save_requested.emit(slot)


func _compact_summary(value: String) -> String:
	var pieces := value.split(" · ")
	return " · ".join(pieces.slice(1)) if pieces.size() > 1 else value


func _modified_text(timestamp: int) -> String:
	if timestamp <= 0: return "date unavailable"
	return Time.get_datetime_string_from_unix_time(timestamp, true)
