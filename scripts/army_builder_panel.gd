extends VBoxContainer
const Roster = preload("res://scripts/army_roster.gd")
const Profiles = preload("res://scripts/army_profiles.gd")
const Catalog = preload("res://scripts/implemented_army_catalog.gd")
const Training = preload("res://scripts/edition_11/training_roster.gd")
signal library_changed
signal import_requested
var preview_entry: Dictionary = {}
var miniature_preview
var saved_roster: ItemList
var editor_tabs: TabContainer
var appearance_button: Button
var preview_model_input: SpinBox
var preview_slot := 0
var save_status: Label
var save_error := ""
var addition_summary: Label
var addition_panel: VBoxContainer
var import_button: Button
var catalog_boundary: Label
var storage_path := "user://profiles/army-lists.json"
var cache_directory := "user://army-catalogs"
var store
var source
var draft: Dictionary
var drafts: Dictionary = {}
var updating := false
var dirty := false
var profile_picker: OptionButton
var profile_name: LineEdit
var saved_picker: OptionButton
var library: VBoxContainer
var edition_picker: OptionButton
var faction_picker: OptionButton
var category_picker: OptionButton
var points_limit: SpinBox
var allies: CheckBox
var name_input: LineEdit
var summary_label: Label
var catalog_totals: Label
var notice: Label
var catalog_status: Label
var refresh_button: Button
var cancel_button: Button
var save_button: Button
var query: LineEdit
var role_picker: OptionButton
var unit_picker: ItemList
var choice_picker: OptionButton
var copies: SpinBox
var add_button: Button
var selected_unit: Dictionary = {}
var entries: ItemList
var notes: TextEdit
var delete_dialog: ConfirmationDialog
var deleting := ""
var build_parent: Node
var saved_lists_view: ItemList
var saved_list_detail: Label
var library_notice: Label
var editor: VBoxContainer
var selected_saved_id := ""
var overview: VBoxContainer
var model_imports
var selected_entry_index := -1
var entry_models_input: SpinBox
var entry_copies_input: SpinBox
var enhancement_picker: OptionButton
var visual_copy_picker: OptionButton
var visual_models: VBoxContainer
var visual_notice: Label
var visual_download_button: Button
var visual_slot_controls: Array[OptionButton] = []

func label(text: String, parent: Node = null) -> Label:
	if parent == null: parent = build_parent if build_parent != null else self
	var control := Label.new()
	control.text = text
	control.custom_minimum_size.x = 400
	control.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	parent.add_child(control)
	return control

func button(text: String, action: Callable, parent: Node = null) -> Button:
	if parent == null: parent = build_parent if build_parent != null else self
	var control := Button.new()
	control.text = text
	control.pressed.connect(action)
	parent.add_child(control)
	return control

func row() -> HBoxContainer:
	var control := HBoxContainer.new()
	(build_parent if build_parent != null else self).add_child(control)
	return control

func _ready() -> void:
	store = Profiles.new(storage_path)
	source = Catalog.new()
	source.cache_directory = cache_directory
	add_child(source)
	draft = Roster.new_list("11e", "")
	overview = VBoxContainer.new()
	overview.add_theme_constant_override("separation", 7)
	add_child(overview)
	build_parent = overview
	var page_heading := label("ARMY WORKSHOP")
	page_heading.add_theme_font_size_override("font_size", 22)
	page_heading.add_theme_color_override("font_color", Color("e8bc62"))
	page_heading.tooltip_text = "Saved lists and local miniature appearances. List checks do not establish full army legality."
	library_notice = label("")
	var profile_row := row()
	profile_picker = OptionButton.new()
	profile_picker.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	profile_row.add_child(profile_picker)
	profile_picker.item_selected.connect(_select_profile)
	profile_name = LineEdit.new()
	profile_name.placeholder_text = "New profile name"
	profile_name.max_length = 80
	profile_row.add_child(profile_name)
	button("Create profile", _create_profile, profile_row)
	saved_lists_view = ItemList.new()
	saved_lists_view.custom_minimum_size.y = 90
	saved_lists_view.item_selected.connect(_select_saved_list)
	overview.add_child(saved_lists_view)
	var detail_scroll := ScrollContainer.new()
	detail_scroll.custom_minimum_size.y = 44
	detail_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	overview.add_child(detail_scroll)
	saved_list_detail = Label.new()
	saved_list_detail.text = "Select an army to inspect its roster and saved points."
	saved_list_detail.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	saved_list_detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	detail_scroll.add_child(saved_list_detail)
	saved_roster = ItemList.new()
	saved_roster.custom_minimum_size.y = 180
	overview.add_child(saved_roster)
	saved_roster.item_selected.connect(func(index: int):
		var list := _find_saved_list(selected_saved_id)
		if not list.is_empty() and index < list.entries.size(): _preview_entry(list.entries[index])
	)
	var library_actions := HBoxContainer.new()
	overview.add_child(library_actions)
	overview.move_child(library_actions, profile_row.get_index() + 1)
	button("New army", _new_empty, library_actions)
	button("Edit selected", _edit_saved_list, library_actions)
	button("Delete…", _ask_delete, library_actions)
	library_notice.text = ""
	editor = VBoxContainer.new()
	editor.add_theme_constant_override("separation", 8)
	add_child(editor)
	build_parent = editor
	catalog_status = label("")
	var editor_header := row()
	button("← Armies", _close_editor, editor_header)
	label("EDIT ARMY", editor_header)
	var updates := row()
	refresh_button = button("Reload local catalog", source.refresh, updates)
	cancel_button = button("Cancel", source.cancel, updates)
	library = VBoxContainer.new()
	editor.add_child(library)
	library.visible = false
	saved_picker = OptionButton.new()
	library.add_child(saved_picker)
	button("Load selected list", _load_list, library)
	button("Delete selected list…", _ask_delete, library)
	delete_dialog = ConfirmationDialog.new()
	delete_dialog.title = "Delete profile list"
	delete_dialog.confirmed.connect(_delete_list)
	add_child(delete_dialog)
	if not store.error.is_empty(): label("Profile was not changed: " + store.error)
	notice = label("")
	name_input = LineEdit.new()
	name_input.placeholder_text = "Army name"
	name_input.max_length = 120
	editor.add_child(name_input)
	name_input.text_changed.connect(func(_text: String): _changed())
	var selectors := row()
	edition_picker = OptionButton.new()
	for edition in Roster.EDITIONS: edition_picker.add_item(edition)
	for index in edition_picker.item_count: edition_picker.set_item_disabled(index, edition_picker.get_item_text(index) != "11e")
	selectors.add_child(edition_picker)
	edition_picker.item_selected.connect(_edition_selected)
	category_picker = OptionButton.new()
	for item in [["Training • 500", "training"], ["Incursion • 1,000", "incursion"], ["Strike Force • 2,000", "strike_force"], ["Onslaught • 3,000", "onslaught"], ["Custom", "custom"]]:
		category_picker.add_item(item[0])
		category_picker.set_item_metadata(category_picker.item_count - 1, item[1])
	selectors.add_child(category_picker)
	category_picker.item_selected.connect(_category_selected)
	points_limit = SpinBox.new()
	points_limit.min_value = 100
	points_limit.max_value = 100000
	points_limit.step = 1
	selectors.add_child(points_limit)
	points_limit.value_changed.connect(func(_value: float): _changed())
	label("Army / faction")
	faction_picker = OptionButton.new()
	editor.add_child(faction_picker)
	faction_picker.item_selected.connect(_faction_selected)
	allies = CheckBox.new()
	allies.text = "Allow other factions (custom list)"
	editor.add_child(allies)
	allies.toggled.connect(func(_value: bool): _changed(); _filter_units())
	summary_label = label("")
	catalog_boundary = label("")
	var saves := row()
	save_button = button("Save list", _save, saves)
	button("Save a copy", _save_copy, saves)
	save_status = label("")
	button("New empty list", _new_empty)
	button("New editable standard base", _new_standard)
	button("Check training compatibility", _check_training)
	button("Find / add units ↓", func(): _scroll_to(add_button))
	label("List units")
	entries = ItemList.new()
	entries.custom_minimum_size.y = 125
	editor.add_child(entries)
	entries.item_selected.connect(_select_entry)
	var entry_edits := row()
	entry_models_input = SpinBox.new()
	entry_models_input.min_value = 0
	entry_models_input.max_value = 1000
	entry_models_input.step = 1
	entry_models_input.prefix = "Models "
	entry_models_input.custom_minimum_size.x = 150
	entry_edits.add_child(entry_models_input)
	entry_copies_input = SpinBox.new()
	entry_copies_input.min_value = 1
	entry_copies_input.max_value = 20
	entry_copies_input.step = 1
	entry_copies_input.prefix = "Units "
	entry_copies_input.custom_minimum_size.x = 130
	entry_edits.add_child(entry_copies_input)
	button("Apply unit size", _apply_entry_size, entry_edits)
	enhancement_picker = OptionButton.new()
	enhancement_picker.fit_to_longest_item = false
	enhancement_picker.tooltip_text = "Space Marine detachment enhancements from the local Wahapedia e11 export. Costs and eligible datasheets come from the local catalog; each selection applies to one unit. For model-only enhancements, the first model in that roster entry is the bearer."
	editor.add_child(enhancement_picker)
	enhancement_picker.item_selected.connect(_enhancement_selected)
	button("Remove selected entry", _remove)
	button("Recalculate costs from current catalog", _reprice)
	notes = TextEdit.new()
	notes.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY
	notes.placeholder_text = "Notes / planned equipment"
	notes.custom_minimum_size.y = 70
	editor.add_child(notes)
	notes.text_changed.connect(_changed)
	label("CHOOSE UNITS")
	query = LineEdit.new()
	query.placeholder_text = "Search units by name"
	editor.add_child(query)
	query.text_changed.connect(func(_text: String): _filter_units())
	role_picker = OptionButton.new()
	for text in ["All categories", "Character", "Battleline", "Dedicated transport", "Other units"]: role_picker.add_item(text)
	editor.add_child(role_picker)
	role_picker.item_selected.connect(func(_index: int): _filter_units())
	unit_picker = ItemList.new()
	unit_picker.custom_minimum_size.y = 190
	editor.add_child(unit_picker)
	unit_picker.item_selected.connect(_select_unit)
	choice_picker = OptionButton.new()
	editor.add_child(choice_picker)
	choice_picker.item_selected.connect(func(_index: int): _refresh_addition_summary())
	addition_summary = label("Select a unit to preview the addition.")
	var additions := row()
	copies = SpinBox.new()
	copies.min_value = 1
	copies.max_value = 20
	copies.step = 1
	copies.prefix = "Units "
	copies.custom_minimum_size.x = 130
	copies.value_changed.connect(func(_value: float): _refresh_addition_summary())
	additions.add_child(copies)
	add_button = button("Add unit(s)", _add, additions)
	catalog_totals = label("")
	button("Back to roster", func(): _scroll_to(summary_label))
	label("Construction uses reconciled local e11 profiles. Pending and historical profiles are excluded. Complete army legality and final network validation remain pending.")
	var visual_header := label("MINIATURE APPEARANCE")
	visual_header.add_theme_font_size_override("font_size", 15)
	visual_header.add_theme_color_override("font_color", Color("d7b96d"))
	visual_notice = label("Select a unit entry to assign local visuals to its miniatures.")
	var visual_controls := row()
	visual_copy_picker = OptionButton.new()
	visual_copy_picker.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	visual_controls.add_child(visual_copy_picker)
	visual_copy_picker.item_selected.connect(func(_index: int):
		_render_visual_slots()
		if selected_entry_index >= 0 and selected_entry_index < draft.entries.size():
			var item: Dictionary = draft.entries[selected_entry_index]
			_preview_entry(item, visual_copy_picker.selected * int(item.models))
	)
	visual_download_button = button("Download unit models", _download_unit_variants, visual_controls)
	var visual_scroll := ScrollContainer.new()
	visual_scroll.custom_minimum_size.y = 120
	visual_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	editor.add_child(visual_scroll)
	visual_models = VBoxContainer.new()
	visual_models.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	visual_scroll.add_child(visual_models)
	editor.visible = false
	build_parent = self
	source.changed.connect(_catalog_changed)
	_render_profiles()
	_render_draft()
	_organize_workshop()
	source.select_edition("11e")

func _organize_workshop() -> void:
	var original := editor.get_children()
	editor_tabs = TabContainer.new()
	editor.add_child(editor_tabs)
	var pages := {}
	for title in ["Roster", "Add units", "Appearance", "Options"]:
		var page := VBoxContainer.new()
		page.name = title
		editor_tabs.add_child(page)
		pages[title] = page
	var destination := "Options"
	for control in original:
		if control in [save_status, catalog_boundary]: continue
		if control is Label and control.text.begins_with("Construction uses reconciled"):
			control.reparent(pages["Options"])
			continue
		if control is Label:
			if control.text == "List units": destination = "Roster"
			elif control.text == "CHOOSE UNITS": destination = "Add units"
			elif control.text == "MINIATURE APPEARANCE": destination = "Appearance"
		if control in [notice, name_input, summary_label]:
			editor.move_child(control, 0)
			continue
		if control is HBoxContainer and control.get_child_count() > 0 and control.get_child(0) is Button and control.get_child(0).text in ["← Armies", "Save list"]: continue
		control.reparent(pages[destination])
	entries.custom_minimum_size.y = 240
	var content := HBoxContainer.new()
	content.add_theme_constant_override("separation", 24)
	add_child(content)
	var lists := VBoxContainer.new()
	lists.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_child(lists)
	overview.reparent(lists)
	editor.reparent(lists)
	var inspector := VBoxContainer.new()
	inspector.custom_minimum_size.x = 290
	content.add_child(inspector)
	miniature_preview = preload("res://scripts/ui/miniature_preview.gd").new()
	inspector.add_child(miniature_preview)
	preview_model_input = SpinBox.new()
	preview_model_input.prefix = "Preview model "
	preview_model_input.min_value = 1
	preview_model_input.max_value = 1
	preview_model_input.step = 1
	preview_model_input.tooltip_text = "Inspect a miniature's current appearance. Preview only; does not assign a variant or change the list."
	miniature_preview.add_child(preview_model_input)
	miniature_preview.move_child(preview_model_input, 1)
	preview_model_input.value_changed.connect(func(value: float):
		if not preview_entry.is_empty(): _preview_entry(preview_entry, int(value) - 1)
	)
	appearance_button = button("Choose appearance", _open_entry_appearance, inspector)
	import_button = button("Import / replace model", func(): import_requested.emit(), inspector)
	addition_panel = VBoxContainer.new()
	addition_panel.custom_minimum_size.x = 290
	inspector.add_child(addition_panel)
	addition_summary.custom_minimum_size.x = 290
	choice_picker.fit_to_longest_item = false
	choice_picker.reparent(addition_panel)
	addition_summary.reparent(addition_panel)
	copies.get_parent().reparent(addition_panel)
	editor.visibility_changed.connect(_update_inspector_mode)
	editor_tabs.tab_changed.connect(func(_index: int): _update_inspector_mode())
	_update_inspector_mode()
	if selected_entry_index >= 0 and selected_entry_index < draft.entries.size(): _preview_entry(draft.entries[selected_entry_index])

func _preview_entry(item: Dictionary, slot: int = 0) -> void:
	preview_entry = item.duplicate(true)
	_update_inspector_mode()
	var total := mini(20000, int(item.get("models", 0)) * int(item.get("copies", 0)))
	slot = clampi(slot, 0, maxi(0, total - 1))
	preview_slot = slot
	if preview_model_input != null:
		preview_model_input.set_block_signals(true)
		preview_model_input.max_value = maxi(1, total)
		preview_model_input.value = slot + 1
		preview_model_input.visible = total > 0
		preview_model_input.set_block_signals(false)
	if miniature_preview == null: return
	var visual: Node3D = null
	var missing_variant := false
	if model_imports != null:
		var slots: Array = item.get("visual_variants", [])
		if slot < slots.size() and not str(slots[slot]).is_empty(): visual = model_imports.visual_variant_for(str(slots[slot]))
		missing_variant = slot < slots.size() and not str(slots[slot]).is_empty() and visual == null
		if visual == null and item.has("unit_id"): visual = model_imports.visual_for(str(item.unit_id))
	miniature_preview.show_model(item, visual, visual != null)
	if not item.is_empty(): miniature_preview.title.text = "Roster · " + str(item.name)
	if total > 0:
		miniature_preview.caption.text += "\nUnit %d · model %d" % [slot / int(item.models) + 1, slot % int(item.models) + 1]
	elif not item.is_empty(): miniature_preview.caption.text += "\nComposition pending · representative visual"
	if missing_variant: miniature_preview.caption.text += "\nAssigned variant unavailable · fallback shown"

func _update_inspector_mode() -> void:
	if addition_panel == null: return
	var adding := editor.visible and editor_tabs.current_tab == 1
	addition_panel.visible = adding
	miniature_preview.visible = not adding
	appearance_button.visible = not adding and editor.visible and not preview_entry.is_empty()
	import_button.visible = not adding

func _open_entry_appearance() -> void:
	if not editor.visible or selected_entry_index < 0 or selected_entry_index >= draft.entries.size(): return
	editor_tabs.current_tab = 2
	var count := maxi(1, int(draft.entries[selected_entry_index].models))
	_render_visual_slots()
	visual_copy_picker.select(clampi(preview_slot / count, 0, maxi(0, visual_copy_picker.item_count - 1)))
	_render_visual_slots()
	var model := preview_slot % count
	_scroll_to(visual_slot_controls[model] if model < visual_slot_controls.size() else visual_copy_picker)

func _sync() -> void:
	if updating: return
	draft.name = name_input.text.strip_edges()
	draft.category = category_picker.get_selected_metadata()
	draft.points_limit = int(points_limit.value)
	draft.allow_allies = allies.button_pressed
	draft.notes = notes.text

func _changed() -> void:
	if updating: return
	_sync()
	dirty = true
	save_error = ""
	_render_summary()

func _render_summary() -> void:
	var totals := Roster.summary(draft)
	var outside := 0
	for item: Dictionary in draft.entries:
		if not source.supports_size(str(item.unit_id), int(item.models)): outside += int(item.copies)
	var legacy_training: bool = draft.get("pricing_source", "") == "starter-training-v1"
	catalog_boundary.visible = outside > 0 or legacy_training
	catalog_boundary.text = ("%d units use the historical training profile · preserved as a legacy draft" % draft.entries.size()) if legacy_training else ("%d units outside the consolidated catalog/compositions · preserved as a legacy draft" % outside)
	summary_label.text = "%d / %d pts • %d units" % [totals.points, draft.points_limit, totals.units]
	if totals.unknown > 0: summary_label.text += "\n%d unit(s) without confirmed costs; total is partial." % totals.unknown
	elif totals.remaining < 0: summary_label.text += "\nOver the limit by %d pts; you can save as a draft." % -totals.remaining
	else: summary_label.text += "\nRestam %d pts." % totals.remaining
	if draft.get("pricing_source", "") == "starter-training-v1": summary_label.text += "\nCosts use the pinned training pack."
	elif not source.catalog.is_empty() and not draft.catalog_digest.is_empty() and draft.catalog_digest != source.catalog.digest:
		summary_label.text += "\nCatalog changed: explicitly recalculate to update costs."
	if catalog_totals != null:
		catalog_totals.text = summary_label.text
		catalog_totals.visible = false
	summary_label.tooltip_text = summary_label.text
	summary_label.text = "\n".join(Array(summary_label.text.split("\n")).slice(0, 2))
	var blocked: String = store.error if not store.error.is_empty() else Roster.validate(draft)
	save_button.disabled = not blocked.is_empty()
	save_button.tooltip_text = blocked if not blocked.is_empty() else "Save this list locally. Saving does not establish full army legality."
	if not blocked.is_empty():
		save_status.text = "Cannot save · " + blocked
	elif not save_error.is_empty():
		save_status.text = "Save failed · retry when storage is available"
	else:
		save_status.text = "Unsaved changes" if dirty or draft.id.is_empty() else "✓ Saved locally"
	save_status.tooltip_text = save_error if not save_error.is_empty() else save_button.tooltip_text
	save_status.add_theme_color_override("font_color", Color("f0b46a") if save_button.disabled or not save_error.is_empty() else (Color("f2df83") if dirty or draft.id.is_empty() else Color("82d49c")))
	_refresh_addition_summary()

func _refresh_addition_summary() -> void:
	if addition_summary == null or copies == null: return
	if selected_unit.is_empty() or choice_picker.selected < 0 or choice_picker.selected >= selected_unit.get("options", []).size():
		addition_summary.text = "Select a unit to preview the addition."
		return
	var option: Dictionary = selected_unit.options[choice_picker.selected]
	var amount := int(copies.value)
	var totals := Roster.summary(draft)
	var count := int(option.get("models", 0))
	var unknown: bool = option.get("cost") == null
	var tiered_addition: Variant = Roster.addition_cost(draft, str(selected_unit.id), option, amount)
	var added := 0 if unknown else int(tiered_addition)
	var partial: bool = unknown or int(totals.unknown) > 0
	addition_summary.text = "To add · %s\n%d units · %s · %s\nAfter adding: %d / %d pts%s" % [str(selected_unit.name), amount, "%d models" % (count * amount) if count > 0 else "composition pending", "cost unconfirmed" if unknown else "%d pts added" % added, int(totals.points) + added, int(draft.points_limit), " · partial" if partial else (" · over budget" if int(totals.points) + added > int(draft.points_limit) else "")]

func _scroll_to(control: Control) -> void:
	if editor_tabs != null:
		if control == summary_label: editor_tabs.current_tab = 0
		for index in editor_tabs.get_tab_count():
			if editor_tabs.get_child(index).is_ancestor_of(control): editor_tabs.current_tab = index
	var ancestor: Node = get_parent()
	while ancestor != null:
		if ancestor is ScrollContainer:
			ancestor.ensure_control_visible(control)
			return
		ancestor = ancestor.get_parent()

func _render_draft() -> void:
	save_error = ""
	updating = true
	name_input.text = draft.name
	edition_picker.select(Roster.EDITIONS.find(draft.edition))
	for index in range(category_picker.item_count):
		if category_picker.get_item_metadata(index) == draft.category: category_picker.select(index)
	points_limit.value = draft.points_limit
	points_limit.editable = draft.category == "custom"
	allies.button_pressed = draft.allow_allies
	notes.text = draft.notes
	entries.clear()
	for index in range(draft.entries.size()):
		var item: Dictionary = draft.entries[index]
		_ensure_visual_slots(item)
		var entry_points: Variant = Roster.entry_cost(draft.entries, index)
		var enhancement_id := str(item.get("enhancement_id", ""))
		var enhancement_suffix := " • +%d pts: %s" % [Roster.enhancement_cost(enhancement_id), _enhancement_name(enhancement_id)] if enhancement_id != "" else ""
		entries.add_item("%d× %s • %s • %s%s" % [item.copies, item.name, "%d models" % item.models if item.models > 0 else "composition pending", "%d pts" % int(entry_points) if entry_points != null else "cost pending", enhancement_suffix])
	updating = false
	_fill_factions()
	_render_summary()
	if selected_entry_index >= draft.entries.size(): selected_entry_index = -1
	if selected_entry_index < 0 and not draft.entries.is_empty(): selected_entry_index = 0
	if selected_entry_index >= 0:
		entries.select(selected_entry_index)
		_select_entry(selected_entry_index)
	else:
		_render_visual_slots()
		if miniature_preview != null: _preview_entry({})

func _render_profiles() -> void:
	if _find_saved_list(selected_saved_id).is_empty(): selected_saved_id = ""
	profile_picker.clear()
	for profile: Dictionary in store.data.profiles:
		profile_picker.add_item(profile.name)
		profile_picker.set_item_metadata(profile_picker.item_count - 1, profile.id)
		if profile.id == store.data.active: profile_picker.select(profile_picker.item_count - 1)
	saved_picker.clear()
	saved_lists_view.clear()
	var active: Dictionary = store.active()
	for list: Dictionary in active.get("lists", []):
		saved_picker.add_item("%s • %d/%d pts" % [list.name, Roster.summary(list).points, list.points_limit])
		saved_picker.set_item_metadata(saved_picker.item_count - 1, list.id)
		if list.id == draft.id: saved_picker.select(saved_picker.item_count - 1)
		var totals := Roster.summary(list)
		saved_lists_view.add_item("%s  ·  %s  ·  %d / %d pts  ·  %d units" % [list.name, list.faction, totals.points, int(list.points_limit), totals.units])
		saved_lists_view.set_item_metadata(saved_lists_view.item_count - 1, list.id)
		if list.id == selected_saved_id: saved_lists_view.select(saved_lists_view.item_count - 1)
	if not selected_saved_id.is_empty(): _show_saved_detail(selected_saved_id)
	elif saved_lists_view.item_count == 0:
		saved_list_detail.text = "No saved armies in %s yet. Create one to get started." % active.get("name", "this profile")
	else:
		saved_list_detail.text = "Select an army to inspect its roster and saved points."

func _find_saved_list(id: String) -> Dictionary:
	for list: Dictionary in store.active().get("lists", []):
		if list.id == id: return list
	return {}

func _select_saved_list(index: int) -> void:
	if index < 0 or index >= saved_lists_view.item_count: return
	selected_saved_id = str(saved_lists_view.get_item_metadata(index))
	_show_saved_detail(selected_saved_id)

func _show_saved_detail(id: String) -> void:
	saved_roster.clear()
	var list := _find_saved_list(id)
	if list.is_empty():
		saved_list_detail.text = "Select an army to inspect its roster and saved points."
		_preview_entry({})
		return
	var totals := Roster.summary(list)
	var lines: Array[String] = ["%s  ·  %s  ·  %s  ·  %d / %d pts  ·  %d units" % [list.name, list.faction, list.edition, totals.points, list.points_limit, totals.units]]
	for index in range(list.entries.size()):
		var entry: Dictionary = list.entries[index]
		var entry_points: Variant = Roster.entry_cost(list.entries, index)
		saved_roster.add_item("%d× %s · %d models · %s" % [entry.copies, entry.name, entry.models, "%d pts" % int(entry_points) if entry_points != null else "cost pending"])
	if totals.unknown > 0: lines.append("Some costs are unconfirmed; total is partial.")
	saved_list_detail.text = "\n".join(lines)
	if not list.entries.is_empty():
		saved_roster.select(0)
		if not editor.visible: _preview_entry(list.entries[0])

func _edit_saved_list() -> void:
	if selected_saved_id.is_empty():
		library_notice.text = "Select a saved army first."
		return
	_load_list_by_id(selected_saved_id)

func _close_editor() -> void:
	_sync()
	drafts[store.data.active] = draft.duplicate(true)
	editor.visible = false
	overview.visible = true
	_show_saved_detail(selected_saved_id)
	library_notice.text = "Unsaved changes are kept in this session." if dirty else ""

func _ensure_visual_slots(item: Dictionary) -> void:
	var wanted := mini(item.models * item.copies, 20000)
	var slots: Array = item.get("visual_variants", []) if item.get("visual_variants", []) is Array else []
	while slots.size() > wanted: slots.pop_back()
	while slots.size() < wanted: slots.append("")
	item.visual_variants = slots

func _select_entry(index: int) -> void:
	selected_entry_index = index
	visual_copy_picker.clear()
	if index < 0 or index >= draft.entries.size():
		_render_visual_slots()
		return
	var item: Dictionary = draft.entries[index]
	_preview_entry(item)
	entry_models_input.value = int(item.models)
	entry_copies_input.value = int(item.copies)
	_refresh_enhancement_picker(item)
	for copy in range(int(item.copies)):
		visual_copy_picker.add_item("Unit %d appearance" % (copy + 1))
		visual_copy_picker.set_item_metadata(copy, copy)
	visual_copy_picker.select(0)
	visual_notice.text = "Choose a local visual for each miniature. Appearance never affects rules or saves sent to a match."
	_render_visual_slots()

func _enhancement_name(identity: String) -> String:
	for enhancement: Dictionary in source.catalog.get("enhancements", []):
		if str(enhancement.get("id", "")) == identity: return str(enhancement.get("name", identity))
	return identity

func _refresh_enhancement_picker(item: Dictionary) -> void:
	if enhancement_picker == null: return
	updating = true
	enhancement_picker.clear()
	enhancement_picker.add_item("No enhancement")
	enhancement_picker.set_item_metadata(0, "")
	var identity := str(item.get("unit_id", "")).get_slice(":", 3)
	for enhancement: Dictionary in source.catalog.get("enhancements", []):
		if identity not in enhancement.get("datasheets", []): continue
		var duplicate := false
		for index in draft.entries.size():
			if index != selected_entry_index and str(draft.entries[index].get("enhancement_id", "")) == str(enhancement.id): duplicate = true
		var index := enhancement_picker.item_count
		enhancement_picker.add_item("%s · %d pts · %s" % [enhancement.name, int(enhancement.cost), str(enhancement.detachment).capitalize()])
		enhancement_picker.set_item_metadata(index, str(enhancement.id))
		enhancement_picker.set_item_disabled(index, duplicate)
	var selected := 0
	for index in enhancement_picker.item_count:
		if str(enhancement_picker.get_item_metadata(index)) == str(item.get("enhancement_id", "")): selected = index
	enhancement_picker.select(selected)
	enhancement_picker.disabled = enhancement_picker.item_count == 1
	updating = false

func _enhancement_selected(index: int) -> void:
	if updating or selected_entry_index < 0 or selected_entry_index >= draft.entries.size(): return
	var identity := str(enhancement_picker.get_item_metadata(index))
	var item: Dictionary = draft.entries[selected_entry_index]
	if identity == "": item.erase("enhancement_id")
	else:
		if int(item.copies) > 1:
			var assigned := item.duplicate(true)
			assigned.copies = 1
			item.copies = int(item.copies) - 1
			draft.entries.insert(selected_entry_index + 1, assigned)
			selected_entry_index += 1
			item = assigned
		item.enhancement_id = identity
	dirty = true
	_render_draft()
	entries.select(selected_entry_index)
	_select_entry(selected_entry_index)
	notice.text = "Enhancement assigned to one unit. Verify the matching detachment when preparing the match."

func _apply_entry_size() -> void:
	if selected_entry_index < 0 or selected_entry_index >= draft.entries.size():
		notice.text = "Select a unit entry first."
		return
	var item: Dictionary = draft.entries[selected_entry_index]
	var next_models := int(entry_models_input.value)
	var next_copies := int(entry_copies_input.value)
	if source.contains(str(item.unit_id)) and not source.supports_size(str(item.unit_id), next_models):
		notice.text = "This composition is outside the consolidated local profile. Choose an available model count from Add units."
		return
	if next_models != int(item.models): item.cost = null
	item.models = next_models
	if item.get("enhancement_id", "") != "" and next_copies > 1:
		var unenhanced := item.duplicate(true)
		unenhanced.copies = next_copies - 1
		unenhanced.erase("enhancement_id")
		unenhanced.erase("visual_variants")
		item.copies = 1
		draft.entries.insert(selected_entry_index + 1, unenhanced)
	else: item.copies = next_copies
	_ensure_visual_slots(item)
	dirty = true
	_render_draft()
	entries.select(selected_entry_index)
	_select_entry(selected_entry_index)
	notice.text = "Unit size updated. Recalculate or confirm costs before relying on the points total." if next_models > 0 else "Composition is pending; this list may not pass a training check."

func _render_visual_slots() -> void:
	if visual_models == null: return
	var wanted_copy := visual_copy_picker.selected
	for child in visual_models.get_children(): child.queue_free()
	visual_slot_controls.clear()
	visual_copy_picker.clear()
	visual_download_button.disabled = true
	if selected_entry_index < 0 or selected_entry_index >= draft.entries.size(): return
	var item: Dictionary = draft.entries[selected_entry_index]
	for copy in range(int(item.copies)):
		visual_copy_picker.add_item("Unit %d appearance" % (copy + 1))
		visual_copy_picker.set_item_metadata(copy, copy)
	var copy_index := clampi(wanted_copy, 0, maxi(0, int(item.copies) - 1))
	visual_copy_picker.select(copy_index)
	var definition := str(item.unit_id)
	var variants: Array = model_imports.variants_for(definition) if model_imports != null and model_imports.has_method("variants_for") else []
	visual_download_button.disabled = true
	if model_imports != null: visual_download_button.disabled = not model_imports.has_method("download_variants_for")
	var start := copy_index * int(item.models)
	for model_index in range(int(item.models)):
		var line := HBoxContainer.new()
		visual_models.add_child(line)
		var caption := Label.new()
		caption.text = "Model %d" % (model_index + 1)
		caption.custom_minimum_size.x = 78
		line.add_child(caption)
		var picker := OptionButton.new()
		picker.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		picker.add_item("Default miniature")
		picker.set_item_metadata(0, "")
		for variant_index in range(variants.size()):
			var option: Dictionary = variants[variant_index]
			picker.add_item("%d · %s%s" % [variant_index + 1, str(option.get("name", "Visual variant")), " · ready" if option.get("ready", false) else " · download"])
			picker.set_item_metadata(picker.item_count - 1, str(option.get("variant_id", "")))
		line.add_child(picker)
		var slot_index := start + model_index
		var selected_variant := str(item.visual_variants[slot_index]) if slot_index < item.visual_variants.size() else ""
		for option_index in range(picker.item_count):
			if str(picker.get_item_metadata(option_index)) == selected_variant: picker.select(option_index)
		var captured_slot := slot_index
		picker.item_selected.connect(func(option_index: int): _set_visual_slot(captured_slot, str(picker.get_item_metadata(option_index))))
		visual_slot_controls.append(picker)
	visual_notice.text = "No variants yet. Open Import models to add a local miniature." if variants.is_empty() else "%d compatible local variant(s)." % variants.size()

func _set_visual_slot(slot: int, variant_id: String) -> void:
	if selected_entry_index < 0 or selected_entry_index >= draft.entries.size(): return
	var item: Dictionary = draft.entries[selected_entry_index]
	_ensure_visual_slots(item)
	if slot < 0 or slot >= item.visual_variants.size(): return
	item.visual_variants[slot] = variant_id
	save_error = ""
	_preview_entry(item, slot)
	dirty = true
	_render_summary()

func _download_unit_variants() -> void:
	if selected_entry_index < 0 or selected_entry_index >= draft.entries.size() or model_imports == null: return
	var item: Dictionary = draft.entries[selected_entry_index]
	model_imports.download_variants_for(str(item.unit_id))

func set_visual_status(message: String) -> void:
	if visual_notice != null: visual_notice.text = message

func _select_profile(index: int) -> void:
	if source.busy:
		library_notice.text = "Cancel the refresh before switching profiles."
		_render_profiles()
		return
	_sync()
	drafts[store.data.active] = draft.duplicate(true)
	var error: String = store.select_profile(profile_picker.get_item_metadata(index))
	if not error.is_empty():
		library_notice.text = error
		_render_profiles()
		return
	draft = drafts.get(store.data.active, Roster.new_list(source.edition, "")).duplicate(true)
	dirty = true
	_render_profiles()
	if source.edition != draft.edition: source.select_edition(draft.edition)
	_render_draft()
	library_notice.text = "Active profile: " + store.active().name

func _create_profile() -> void:
	_sync()
	drafts[store.data.active] = draft.duplicate(true)
	var error: String = store.create_profile(profile_name.text)
	if not error.is_empty():
		library_notice.text = error
		return
	profile_name.clear()
	draft = Roster.new_list(source.edition, "")
	dirty = false
	_render_profiles()
	_render_draft()
	overview.visible = false
	editor.visible = true
	library_notice.text = "Local profile created."

func _load_list() -> void:
	if source.busy:
		notice.text = "Cancel the refresh before loading another list."
		return
	if saved_picker.item_count == 0: return
	_load_list_by_id(str(saved_picker.get_selected_metadata()))

func _load_list_by_id(id: String) -> void:
	if source.busy:
		library_notice.text = "Cancel the catalog refresh before loading another army."
		return
	var list := _find_saved_list(id)
	if list.is_empty(): return
	draft = list.duplicate(true)
	selected_saved_id = id
	dirty = false
	selected_entry_index = -1
	editor.visible = true
	overview.visible = false
	if source.edition != draft.edition: source.select_edition(draft.edition)
	_render_draft()
	_render_profiles()
	notice.text = "Army loaded with its saved costs and local appearances."

func _save() -> bool:
	_sync()
	var inspected_slot := preview_slot
	var saved: Dictionary = store.save_list(draft)
	save_error = str(saved.error)
	notice.text = saved.error
	if not saved.error.is_empty():
		_render_summary()
		return false
	draft = saved.list
	dirty = false
	selected_saved_id = draft.id
	_render_profiles()
	_render_summary()
	if editor.visible and selected_entry_index >= 0 and selected_entry_index < draft.entries.size():
		_select_entry(selected_entry_index)
		_preview_entry(draft.entries[selected_entry_index], inspected_slot)
		if editor_tabs.current_tab == 2: _open_entry_appearance()
	notice.text = ""
	library_changed.emit()
	return true

func _save_copy() -> void:
	_sync()
	var original_draft := draft.duplicate(true)
	var original_dirty := dirty
	var old_name := name_input.text
	draft.id = ""
	name_input.text = old_name.left(110) + " (copy)"
	if not _save():
		draft = original_draft
		dirty = original_dirty
		name_input.text = old_name
		_render_summary()

func _ask_delete() -> void:
	if selected_saved_id.is_empty():
		library_notice.text = "Select a saved army first."
		return
	deleting = selected_saved_id
	var list := _find_saved_list(deleting)
	delete_dialog.dialog_text = "Delete '%s' from profile %s?" % [list.get("name", "this army"), store.active().get("name", "Local Player")]
	delete_dialog.popup_centered()

func _delete_list() -> void:
	var error: String = store.delete_list(deleting)
	if error.is_empty() and draft.id == deleting:
		draft.id = ""
		dirty = true
	if error.is_empty(): selected_saved_id = ""
	library_notice.text = "Army deleted; the open draft was kept." if error.is_empty() else error
	if notice != null: notice.text = library_notice.text
	_render_profiles()
	_render_summary()
	library_changed.emit()

func _category_selected(_index: int) -> void:
	if updating: return
	var category: String = category_picker.get_selected_metadata()
	if category != "custom": points_limit.value = Roster.LIMITS[category]
	points_limit.editable = category == "custom"
	_changed()

func _edition_selected(index: int) -> void:
	if updating: return
	if not draft.entries.is_empty():
		edition_picker.select(Roster.EDITIONS.find(draft.edition))
		notice.text = "Create an empty list before changing the edition."
		return
	draft.edition = Roster.EDITIONS[index]
	draft.faction = ""
	draft.catalog_digest = ""
	dirty = true
	source.select_edition(draft.edition)

func _faction_selected(index: int) -> void:
	if updating: return
	var faction := faction_picker.get_item_text(index)
	for item: Dictionary in draft.entries:
		if not Roster.faction_allowed(faction, item.faction, draft.allow_allies):
			notice.text = "Remove incompatible units or allow other factions before changing the army."
			_fill_factions()
			return
	draft.faction = faction
	dirty = true
	_filter_units()
	_render_summary()

func _catalog_changed(message: String) -> void:
	catalog_status.text = message
	refresh_button.disabled = source.busy
	cancel_button.disabled = not source.busy
	edition_picker.disabled = source.busy
	_fill_factions()
	_render_summary()

func _fill_factions() -> void:
	var factions: Dictionary = {}
	for unit: Dictionary in source.catalog.get("units", []): factions[unit.faction] = true
	if not draft.faction.is_empty(): factions[draft.faction] = true
	var names := factions.keys()
	names.sort()
	faction_picker.clear()
	for faction: String in names: faction_picker.add_item(faction)
	if draft.faction.is_empty() and not names.is_empty(): draft.faction = names[0]
	for index in range(faction_picker.item_count):
		if faction_picker.get_item_text(index) == draft.faction: faction_picker.select(index)
	_filter_units()

func _filter_units() -> void:
	unit_picker.clear()
	choice_picker.clear()
	selected_unit = {}
	_refresh_addition_summary()
	add_button.disabled = true
	for unit: Dictionary in source.catalog.get("units", []):
		if unit.edition != draft.edition or not Roster.faction_allowed(draft.faction, unit.faction, allies.button_pressed): continue
		if not query.text.strip_edges().is_empty() and query.text.strip_edges().to_lower() not in unit.name.to_lower(): continue
		var roles := {1: ["Character", "Personagem"], 2: ["Battleline", "Linha de batalha"], 3: ["Dedicated transport", "Transporte dedicado"], 4: ["Other units"]}
		if role_picker.selected > 0 and unit.role not in roles[role_picker.selected]: continue
		unit_picker.add_item(unit.name + (" • " + unit.faction if unit.faction != draft.faction else ""))
		unit_picker.set_item_metadata(unit_picker.item_count - 1, unit)

func _select_unit(index: int) -> void:
	selected_unit = unit_picker.get_item_metadata(index)
	var current := Training.Capabilities.current_catalog_choice(selected_unit)
	if not current.is_empty(): selected_unit = current
	choice_picker.clear()
	for option: Dictionary in selected_unit.options:
		var origin := "Wahapedia e11" if not current.is_empty() else "local"
		var price_text := "%d pts" % option.cost if option.cost != null else "cost unconfirmed"
		if option.has("third_plus_cost") and option.cost != null and int(option.third_plus_cost) != int(option.cost): price_text += " · 3rd+ %d pts" % int(option.third_plus_cost)
		choice_picker.add_item(("%d models (%s)" % [option.models, origin] if option.models > 0 else "Composition not provided") + " • " + price_text)
	add_button.disabled = false
	_refresh_addition_summary()

func _add() -> void:
	_sync()
	if selected_unit.is_empty() or choice_picker.selected < 0: return
	var allowed: Dictionary = source.lookup(str(selected_unit.id))
	if allowed.is_empty():
		notice.text = "This datasheet is outside the consolidated local catalog. Reload the local catalog."
		return
	var current := Training.Capabilities.current_catalog_choice(allowed)
	if not current.is_empty(): allowed = current
	var wanted: int = selected_unit.options[choice_picker.selected].models
	var option_index := -1
	for index in allowed.options.size():
		if int(allowed.options[index].models) == wanted: option_index = index
	if option_index < 0:
		notice.text = "This composition is not available in the consolidated local catalog."
		return
	if draft.entries.size() >= 100:
		notice.text = "The list has reached the 100-entry limit."
		return
	draft.entries.append(Roster.entry(allowed, option_index, int(copies.value)))
	selected_entry_index = draft.entries.size() - 1
	if draft.catalog_digest.is_empty(): draft.catalog_digest = source.catalog.digest
	dirty = true
	_render_draft()
	if editor_tabs != null: editor_tabs.current_tab = 0
	notice.text = "Added %s. Choose appearance or add another unit." % str(draft.entries[selected_entry_index].name)

func _remove() -> void:
	var selected := entries.get_selected_items()
	if selected.is_empty(): return
	draft.entries.remove_at(selected[0])
	dirty = true
	_render_draft()

func _new_empty() -> void:
	if editor_tabs != null: editor_tabs.current_tab = 0
	_sync()
	draft = Roster.new_list(source.edition, draft.faction, draft.category, int(draft.points_limit))
	selected_saved_id = ""
	dirty = true
	selected_entry_index = -1
	editor.visible = true
	overview.visible = false
	_render_draft()
	notice.text = "New list created; saved lists were preserved."

func _new_standard() -> void:
	_sync()
	if source.catalog.is_empty() or draft.faction.is_empty():
		notice.text = "Load the catalog and choose an army first."
		return
	draft = Roster.standard(source.catalog, draft.faction, draft.category, int(draft.points_limit))
	dirty = true
	_render_draft()
	notice.text = "Editable base created: %d units. Complete it to fit your match limit and rules." % Roster.summary(draft).units

func _new_training() -> void:
	_sync()
	if draft.edition != "11e":
		notice.text = "The implemented training mode uses the 11th edition pack."
		return
	var created := Training.template(draft.faction, draft.category, int(draft.points_limit))
	if not created.error.is_empty():
		notice.text = created.error
		return
	draft = created.list
	dirty = true
	_render_draft()
	notice.text = "Training list ready. Save to use in a match."

func _check_training() -> void:
	_sync()
	var report := Training.inspect(draft)
	notice.text = report.error if not report.error.is_empty() else "Compatible with partial training: %d/%d pts in the local pack. Default weapons are fixed; unit and faction abilities and equipment notes are not executed." % [report.total, draft.points_limit]

func _reprice() -> void:
	_sync()
	if draft.get("pricing_source", "") == "starter-training-v1":
		var revised := Training.reprice(draft)
		if not revised.error.is_empty():
			notice.text = revised.error
			return
		draft = revised.list
		dirty = true
		_render_draft()
		notice.text = "Training costs recalculated. Save to keep this revision."
		return
	if source.catalog.is_empty() or source.edition != draft.edition:
		notice.text = "Load the catalog for the list's edition."
		return
	var pricing_catalog: Dictionary = source.catalog.duplicate(true)
	for unit: Dictionary in source.catalog.units:
		var current := Training.Capabilities.current_catalog_choice(unit)
		if not current.is_empty(): pricing_catalog.units.append(current)
	var updated := Roster.reprice(draft, pricing_catalog)
	if not updated.error.is_empty():
		notice.text = updated.error
		return
	draft = updated.list
	dirty = true
	_render_draft()
	notice.text = "Draft costs recalculated. Save to replace the previous costs."

func _new_reference() -> void:
	_sync()
	if draft.edition != "11e":
		notice.text = "Reference armies use the pinned 11e training pack."
		return
	var result := Training.Capabilities.reference_army(draft.faction)
	if not result.error.is_empty():
		notice.text = result.error
		return
	draft = result.list
	draft.id = ""
	dirty = true
	_render_draft()
	notice.text = "Mixed reference created: 480/500 local pack points. Unit and faction abilities remain unavailable; save a copy to your profile."
