extends ScrollContainer
## Read-only browser for explicitly saved local match-result summaries.
const MatchResult = preload("res://scripts/match_result.gd")

var records: Array[Dictionary] = []
var filtered_record_indices: Array[int] = []
var record_picker := OptionButton.new()
var search_field := LineEdit.new()
var summary := Label.new()
var details := RichTextLabel.new()
var empty_label := Label.new()
var scan_status := Label.new()
var scan_issue_toggle := Button.new()
var scan_issue_details := RichTextLabel.new()
var copy_button := Button.new()
var notice := Label.new()
var json_file_count := 0
var ignored_file_count := 0
var invalid_files: Array[Dictionary] = []
var results_location_unreadable := false

func _ready() -> void:
	horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	var column := VBoxContainer.new()
	column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	column.add_theme_constant_override("separation", 9)
	add_child(column)
	var intro := Label.new()
	intro.text = "Results saved on this computer, newest first. This screen does not open or change a match."
	intro.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(intro)
	scan_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	scan_status.add_theme_color_override("font_color", Color("b5c4ca"))
	column.add_child(scan_status)
	scan_issue_toggle.text = "Show ignored-file details"
	scan_issue_toggle.tooltip_text = "Explain why saved result files were skipped."
	scan_issue_toggle.custom_minimum_size.y = 40
	scan_issue_toggle.visible = false
	scan_issue_toggle.toggle_mode = true
	scan_issue_toggle.pressed.connect(_toggle_scan_issue_details)
	column.add_child(scan_issue_toggle)
	scan_issue_details.custom_minimum_size.y = 128
	scan_issue_details.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scan_issue_details.scroll_active = true
	scan_issue_details.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	scan_issue_details.focus_mode = Control.FOCUS_ALL
	scan_issue_details.selection_enabled = true
	scan_issue_details.visible = false
	scan_issue_details.add_theme_font_size_override("normal_font_size", 14)
	scan_issue_details.add_theme_color_override("default_color", Color("e5a394"))
	column.add_child(scan_issue_details)
	search_field.placeholder_text = "Search scenario, result, score or unit"
	search_field.tooltip_text = "Search compatible saved results on this computer."
	search_field.clear_button_enabled = true
	search_field.custom_minimum_size.y = 40
	search_field.visible = false
	search_field.text_changed.connect(_on_search_text_changed)
	column.add_child(search_field)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	column.add_child(row)
	record_picker.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	record_picker.item_selected.connect(_show_record)
	record_picker.visible = false
	row.add_child(record_picker)
	copy_button.text = "Copy summary"
	copy_button.tooltip_text = "Copy the selected saved result summary to the clipboard."
	copy_button.custom_minimum_size = Vector2(128, 40)
	copy_button.disabled = true
	copy_button.pressed.connect(_copy_selected)
	row.add_child(copy_button)
	var reload := Button.new()
	reload.text = "Reload"
	reload.tooltip_text = "Read saved result files again."
	reload.custom_minimum_size = Vector2(92, 40)
	reload.pressed.connect(refresh_records)
	row.add_child(reload)
	summary.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	summary.add_theme_color_override("font_color", Color("e3b65c"))
	column.add_child(summary)
	notice.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	notice.add_theme_color_override("font_color", Color("9cc8a8"))
	column.add_child(notice)
	empty_label.text = "No saved results yet. Use Save result on a completed match to add one here."
	empty_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	empty_label.visible = false
	column.add_child(empty_label)
	details.fit_content = true
	details.scroll_active = false
	details.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	details.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	details.visible = false
	details.add_theme_font_size_override("normal_font_size", 15)
	details.add_theme_color_override("default_color", Color("edf1f2"))
	column.add_child(details)

func refresh_records() -> void:
	var selected_id := ""
	if record_picker.item_count > 0 and record_picker.selected >= 0:
		selected_id = str(record_picker.get_item_metadata(record_picker.selected))
	var report: Dictionary = MatchResult.saved_records_report()
	records.clear()
	var scanned_records: Variant = report.get("records", [])
	if typeof(scanned_records) == TYPE_ARRAY:
		for entry: Variant in scanned_records:
			if typeof(entry) == TYPE_DICTIONARY: records.append(entry)
	json_file_count = int(report.get("json_files", 0))
	ignored_file_count = int(report.get("ignored_files", 0))
	invalid_files.clear()
	var scanned_issues: Variant = report.get("invalid_files", [])
	if typeof(scanned_issues) == TYPE_ARRAY:
		for entry: Variant in scanned_issues:
			if typeof(entry) == TYPE_DICTIONARY: invalid_files.append(entry)
	results_location_unreadable = bool(report.get("unreadable", false))
	scan_issue_details.visible = false
	scan_issue_toggle.set_pressed_no_signal(false)
	search_field.visible = records.size() > 1
	if not search_field.visible and not search_field.text.is_empty():
		search_field.set_block_signals(true)
		search_field.clear()
		search_field.set_block_signals(false)
	_apply_search(search_field.text, selected_id)

func _on_search_text_changed(query: String) -> void:
	_apply_search(query)

func _toggle_scan_issue_details() -> void:
	scan_issue_details.visible = not scan_issue_details.visible
	scan_issue_toggle.set_pressed_no_signal(scan_issue_details.visible)
	_update_scan_issue_details()

func _apply_search(query: String, preferred_id: String = "") -> void:
	if preferred_id.is_empty() and record_picker.item_count > 0 and record_picker.selected >= 0:
		preferred_id = str(record_picker.get_item_metadata(record_picker.selected))
	var normalized_query := query.strip_edges().to_lower()
	filtered_record_indices.clear()
	for index in range(records.size()):
		var record: Dictionary = records[index].record
		if normalized_query.is_empty() or _matches_search(record, normalized_query):
			filtered_record_indices.append(index)
	record_picker.clear()
	for visible_index in range(filtered_record_indices.size()):
		var source_index := filtered_record_indices[visible_index]
		var entry: Dictionary = records[source_index]
		var record: Dictionary = entry.record
		record_picker.add_item(_record_label(source_index, entry))
		record_picker.set_item_metadata(visible_index, str(record.id))
	var has_matches := not filtered_record_indices.is_empty()
	record_picker.visible = has_matches
	details.visible = has_matches
	empty_label.visible = not has_matches
	copy_button.disabled = not has_matches
	_update_scan_status(filtered_record_indices.size())
	if has_matches:
		var selected := 0
		for visible_index in range(filtered_record_indices.size()):
			var source_index := filtered_record_indices[visible_index]
			if str(records[source_index].record.id) == preferred_id:
				selected = visible_index
				break
		record_picker.select(selected)
		_show_record(selected)
	else:
		summary.text = ""
		notice.text = ""
		details.text = ""
		if results_location_unreadable:
			empty_label.text = "No records are available while this location cannot be read."
		elif records.is_empty() and json_file_count == 0:
			empty_label.text = "No saved results yet. Use Save result on a completed match to add one here."
		elif records.is_empty():
			empty_label.text = "Damaged or unsupported records stay hidden. Restore a valid saved result file, then select Reload."
		else:
			empty_label.text = "No saved results match this search. Clear the search to show all compatible results."

func _matches_search(record: Dictionary, query: String) -> bool:
	var outcome := "draw" if int(record.get("winner", 0)) == -1 else "player %d wins" % int(record.get("winner", 0))
	var scores: Dictionary = record.get("scores", {})
	var mission_details: Dictionary = record.get("mission_details", {})
	var searchable_text := "%s %s %s %s round %d p1 %d p2 %d" % [
		str(record.get("scenario", "")), str(record.get("scope", "")), outcome,
		str(mission_details.get("name", "")), int(record.get("round", 0)),
		int(scores.get("P1", 0)), int(scores.get("P2", 0)),
	]
	var armies: Dictionary = record.get("armies", {})
	for owner: String in ["P1", "P2"]:
		var army: Array = armies.get(owner, [])
		for unit_name: String in army:
			searchable_text += " " + unit_name
	return searchable_text.to_lower().contains(query)

func _update_scan_status(matched_count: int) -> void:
	scan_status.remove_theme_color_override("font_color")
	scan_issue_toggle.visible = not invalid_files.is_empty()
	if invalid_files.is_empty():
		scan_issue_details.visible = false
		scan_issue_toggle.set_pressed_no_signal(false)
	scan_issue_toggle.set_pressed_no_signal(scan_issue_details.visible)
	scan_issue_toggle.text = "Show ignored-file details (%d)" % invalid_files.size()
	if results_location_unreadable:
		scan_status.text = "The saved-results location exists but could not be opened. Check its access and select Reload to try again."
		scan_status.add_theme_color_override("font_color", Color("e5a394"))
	elif json_file_count == 0:
		scan_status.text = ""
	elif records.is_empty():
		scan_status.text = "Found %d JSON file(s); none contain a supported saved result." % json_file_count
		scan_status.add_theme_color_override("font_color", Color("e5a394"))
	else:
		scan_status.text = "%d of %d compatible result(s) shown." % [matched_count, records.size()]
		if ignored_file_count > 0:
			scan_status.text += " %d damaged or unsupported JSON file(s) hidden." % ignored_file_count
		scan_status.add_theme_color_override("font_color", Color("b5c4ca"))
	_update_scan_issue_details()

func _update_scan_issue_details() -> void:
	if not scan_issue_details.visible: return
	var lines: Array[String] = ["Files remain in user://matches/results. Restore a valid copy, then select Reload."]
	var visible_count := mini(invalid_files.size(), 12)
	for index in range(visible_count):
		var issue: Dictionary = invalid_files[index]
		lines.append("%s — %s" % [str(issue.get("filename", "Unknown file")), str(issue.get("reason", "Unsupported result."))])
	if invalid_files.size() > visible_count:
		lines.append("%d more file(s) hidden from this list." % (invalid_files.size() - visible_count))
	scan_issue_details.text = "\n".join(lines)
	scan_issue_toggle.text = "Hide ignored-file details (%d)" % invalid_files.size()

func _copy_selected() -> void:
	var index := record_picker.selected
	if index < 0 or index >= filtered_record_indices.size(): return
	var record_index := filtered_record_indices[index]
	var record: Dictionary = records[record_index].record
	DisplayServer.clipboard_set(MatchResult.text(record))
	notice.text = "Saved result summary copied to the clipboard."

func _show_record(index: int) -> void:
	if index < 0 or index >= filtered_record_indices.size(): return
	var record_index := filtered_record_indices[index]
	var entry: Dictionary = records[record_index]
	var record: Dictionary = entry.record
	notice.text = ""
	var outcome := "Draw" if int(record.winner) == -1 else "Player %d wins" % int(record.winner)
	var scores: Dictionary = record.get("scores", {})
	var score_text := ""
	if not scores.is_empty(): score_text = " · P1 %d VP · P2 %d VP" % [int(scores.get("P1", 0)), int(scores.get("P2", 0))]
	summary.text = "%s · %s%s · schema v%d" % [str(record.get("scenario", "Saved match")), outcome, score_text, int(record.get("schema_version", 0))]
	details.text = MatchResult.text(record)

func _record_label(index: int, entry: Dictionary) -> String:
	var record: Dictionary = entry.record
	var outcome := "Draw" if int(record.winner) == -1 else "P%d wins" % int(record.winner)
	var scores: Dictionary = record.get("scores", {})
	var score_text := ""
	if not scores.is_empty(): score_text = " · %d–%d VP" % [int(scores.get("P1", 0)), int(scores.get("P2", 0))]
	var saved_at := int(entry.get("saved_at", 0))
	var date_text := Time.get_datetime_string_from_unix_time(saved_at) + " UTC" if saved_at > 0 else "Saved time unknown"
	return "%s · %s · %s%s" % [date_text, str(record.get("scenario", "Saved match")), outcome, score_text]
