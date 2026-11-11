extends VBoxContainer
const WorkspaceTheme = preload("res://scripts/ui/workspace_theme.gd")
const Roster = preload("res://scripts/army_roster.gd")
const Profiles = preload("res://scripts/army_profiles.gd")
const Catalog = preload("res://scripts/implemented_army_catalog.gd")
const Training = preload("res://scripts/edition_11/training_roster.gd")
const CurrentMarines = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const ForceOrgMatcher = preload("res://scripts/forceorg_matcher.gd")
signal library_changed
signal import_requested
signal new_match_requested
var workspace_columns: HBoxContainer
var catalog_region: VBoxContainer
var roster_region: VBoxContainer
var inspector_region: VBoxContainer
var compact_navigation: OptionButton
var points_meter: ProgressBar
var roster_empty: Label
var library_workspace: HBoxContainer
var library_preview: VBoxContainer
var unit_size_controls: VBoxContainer
var resume_draft_button: Button
var unsaved_dialog: ConfirmationDialog
var pending_editor_action: Callable
var candidate_preview := false
var preview_generation := 0
var preview_busy := false
var appearance_generation := 0
var reveal_appearance_when_ready := false
var preview_entry: Dictionary = {}
var miniature_preview
var saved_roster: ItemList
var editor_tabs: TabContainer
var appearance_button: Button
var palette_button: Button
var palette_notice: Label
var palette_prepare_button: Button
var automatic_appearance_toggle: CheckBox
var pending_appearance_units: Dictionary = {}
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
var chapter_status: Label
var choice_picker: OptionButton
var construction_scope_hint: Label
var composition_picker: OptionButton
var composition_hint: Label
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
var visual_model_override_control: OptionButton
var sergeant_loadout_copy_picker: OptionButton
var sergeant_rifle_picker: OptionButton
var sergeant_melee_picker: OptionButton
var sergeant_loadout_heading: Label
const INTERCESSOR_RIFLE_OPTIONS := [
	{"id": "bolt-rifle", "label": "Bolt Rifle"},
	{"id": "chainsword", "label": "Chainsword"},
	{"id": "hand-flamer", "label": "Hand Flamer"},
	{"id": "plasma-pistol", "label": "Plasma Pistol"},
	{"id": "power-weapon", "label": "Power Weapon"}
]
const INTERCESSOR_MELEE_OPTIONS := [
	{"id": "knives-and-fists", "label": "Knives and Fists"},
	{"id": "chainsword", "label": "Chainsword"},
	{"id": "power-fist", "label": "Power Fist"},
	{"id": "power-weapon", "label": "Power Weapon"},
	{"id": "thunder-hammer", "label": "Thunder Hammer"}
]

func label(text: String, parent: Node = null) -> Label:
	if parent == null: parent = build_parent if build_parent != null else self
	var control := Label.new()
	control.text = text
	control.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	control.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	parent.add_child(control)
	return control

func button(text: String, action: Callable, parent: Node = null) -> Button:
	if parent == null: parent = build_parent if build_parent != null else self
	var control := Button.new()
	control.text = text
	control.custom_minimum_size.y = 40
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
	var page_heading := label("ARMY LIBRARY")
	page_heading.add_theme_font_size_override("font_size", 22)
	page_heading.add_theme_color_override("font_color", Color("e8bc62"))
	page_heading.tooltip_text = "Saved lists and local miniature appearances. List checks do not establish full army legality."
	library_notice = label("")
	var profile_row := row()
	profile_picker = OptionButton.new()
	profile_picker.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	profile_row.add_child(profile_picker)
	profile_picker.item_selected.connect(_select_profile)
	var create_profile_row := row()
	profile_name = LineEdit.new()
	profile_name.placeholder_text = "New profile name"
	profile_name.max_length = 80
	profile_name.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	profile_name.custom_minimum_size.x = 180
	create_profile_row.add_child(profile_name)
	button("Create profile", _create_profile, create_profile_row)
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
	button("New army", func(): _request_editor_action(_new_empty), library_actions)
	button("Edit selected", _edit_saved_list, library_actions)
	button("Duplicate", _duplicate_saved_list, library_actions)
	button("Delete…", _ask_delete, library_actions)
	resume_draft_button = button("Resume unsaved draft", _resume_draft, overview)
	overview.move_child(resume_draft_button, library_actions.get_index() + 1)
	resume_draft_button.visible = false
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
	unsaved_dialog = ConfirmationDialog.new()
	unsaved_dialog.title = "Unsaved army"
	unsaved_dialog.dialog_text = "This army has unsaved changes. Save the draft, keep editing, or discard changes before continuing."
	unsaved_dialog.get_ok_button().text = "Discard changes"
	unsaved_dialog.get_cancel_button().text = "Keep editing"
	unsaved_dialog.add_button("Save draft", false, "save")
	unsaved_dialog.confirmed.connect(_continue_editor_action)
	unsaved_dialog.canceled.connect(func():
		unsaved_dialog.hide()
		pending_editor_action = Callable()
		_resume_draft()
	)
	unsaved_dialog.custom_action.connect(func(action: StringName):
		if action != &"save": return
		if _save(): _continue_editor_action()
		else: unsaved_dialog.dialog_text = "The draft could not be saved.\n" + save_status.text + "\nKeep editing to resolve it, or explicitly discard changes."
	)
	add_child(unsaved_dialog)
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
	button("New empty list", func(): _request_editor_action(_new_empty))
	button("New editable standard base", func(): _request_editor_action(_new_standard))
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
	sergeant_loadout_heading = label("INTERCESSOR SERGEANT EQUIPMENT")
	sergeant_loadout_heading.visible = false
	var sergeant_copy_row := row()
	sergeant_loadout_copy_picker = OptionButton.new()
	sergeant_loadout_copy_picker.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sergeant_loadout_copy_picker.tooltip_text = "Set the Sergeant's equipment for one individual unit copy in this list. The choice remains editable during match preparation when allowed."
	sergeant_copy_row.add_child(sergeant_loadout_copy_picker)
	sergeant_loadout_copy_picker.item_selected.connect(_sergeant_loadout_copy_selected)
	var sergeant_rifle_row := row()
	sergeant_rifle_picker = OptionButton.new()
	sergeant_rifle_picker.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sergeant_rifle_picker.tooltip_text = "The Sergeant retains a Bolt Pistol. This selects the source-listed weapon replacing the Bolt Rifle."
	sergeant_rifle_row.add_child(sergeant_rifle_picker)
	var sergeant_melee_row := row()
	sergeant_melee_picker = OptionButton.new()
	sergeant_melee_picker.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sergeant_melee_picker.tooltip_text = "Select the Sergeant's source-listed melee weapon."
	sergeant_melee_row.add_child(sergeant_melee_picker)
	for option: Dictionary in INTERCESSOR_RIFLE_OPTIONS:
		sergeant_rifle_picker.add_item(str(option.label))
		sergeant_rifle_picker.set_item_metadata(sergeant_rifle_picker.item_count - 1, str(option.id))
	for option: Dictionary in INTERCESSOR_MELEE_OPTIONS:
		sergeant_melee_picker.add_item(str(option.label))
		sergeant_melee_picker.set_item_metadata(sergeant_melee_picker.item_count - 1, str(option.id))
	sergeant_rifle_picker.item_selected.connect(func(_index: int): _set_sergeant_loadout_from_controls())
	sergeant_melee_picker.item_selected.connect(func(_index: int): _set_sergeant_loadout_from_controls())
	notes = TextEdit.new()
	notes.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY
	notes.placeholder_text = "Notes / planned equipment"
	notes.custom_minimum_size.y = 70
	editor.add_child(notes)
	notes.text_changed.connect(_changed)
	label("CHOOSE UNITS")
	chapter_status = label("")
	chapter_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	chapter_status.add_theme_font_size_override("font_size", 12)
	chapter_status.tooltip_text = "This preview uses current profiles in the consolidated local catalog. Final match admission remains authoritative and does not certify general army legality."
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
	choice_picker.item_selected.connect(func(_index: int): _refresh_composition_options())
	construction_scope_hint = label("")
	construction_scope_hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	construction_scope_hint.add_theme_font_size_override("font_size", 12)
	construction_scope_hint.add_theme_color_override("font_color", Color("f0b46a"))
	construction_scope_hint.visible = false
	composition_hint = label("Source-listed roles. The Chapter Ancient's Banner of Macragge adds 15 pts.")
	composition_hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	composition_hint.add_theme_font_size_override("font_size", 12)
	composition_hint.visible = false
	composition_picker = OptionButton.new()
	composition_picker.tooltip_text = "Choose which source-listed roles make up this Victrix Honour Guard unit. Selecting the Chapter Ancient includes its 15-point Banner of Macragge."
	composition_picker.visible = false
	editor.add_child(composition_picker)
	composition_picker.item_selected.connect(func(_index: int): _refresh_addition_summary())
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
	visual_notice = label("Each unit shares one appearance by default. Use a model override only for a distinct role or loadout sculpt.")
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
	visual_download_button = button("Prepare appearances", _download_unit_variants, visual_controls)
	automatic_appearance_toggle = CheckBox.new()
	automatic_appearance_toggle.text = "Automatically prepare added units"
	automatic_appearance_toggle.tooltip_text = "Prepare appearances for up to four unit copies when a unit entry is added. Every model inherits the unit appearance unless it has an explicit sculpt override. Existing army paint choices take priority."
	editor.add_child(automatic_appearance_toggle)
	if model_imports != null:
		model_imports.automatic_finished.connect(func(_ready: int, _total: int, _summary: String): call_deferred("_prepare_added_units"))
		model_imports.variants_changed.connect(func(_definition: String): call_deferred("_prepare_added_units"))
		model_imports.downloader.finished.connect(func(_result: Dictionary): call_deferred("_prepare_added_units"))
	palette_button = button("Add selected paint to army palette", _toggle_palette_choice)
	palette_button.tooltip_text = "Choose and preview a ForceOrg variant, then add it to the palette for this unit type. Unit copies may cycle through palette choices. Models inherit their unit choice unless one has an explicit sculpt override. Manual unit choices take priority."
	palette_notice = label("Army palette · No unit types configured.")
	palette_prepare_button = button("Prepare army palette", _prepare_army_palette)
	palette_prepare_button.disabled = true
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
	# Reuse every existing control and callback. Only presentation ownership changes.
	theme = WorkspaceTheme.create()
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	editor.size_flags_vertical = Control.SIZE_EXPAND_FILL
	library_workspace = HBoxContainer.new()
	library_workspace.size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_child(library_workspace)
	overview.reparent(library_workspace)
	overview.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	library_preview = VBoxContainer.new()
	library_preview.custom_minimum_size.x = 300
	library_workspace.add_child(library_preview)
	saved_lists_view.custom_minimum_size.y = 200
	saved_lists_view.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var original := editor.get_children()
	var header := HBoxContainer.new()
	editor.add_child(header)
	var identity := VBoxContainer.new()
	identity.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(identity)
	name_input.reparent(identity)
	var budget := VBoxContainer.new()
	budget.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(budget)
	summary_label.reparent(budget)
	points_meter = ProgressBar.new()
	points_meter.custom_minimum_size.y = 5
	points_meter.show_percentage = false
	points_meter.add_theme_stylebox_override("background", WorkspaceTheme.box(WorkspaceTheme.BASE, WorkspaceTheme.BORDER, 0))
	points_meter.add_theme_stylebox_override("fill", WorkspaceTheme.box(WorkspaceTheme.GOLD, WorkspaceTheme.GOLD, 0))
	budget.add_child(points_meter)
	var footer := HBoxContainer.new()
	compact_navigation = OptionButton.new()
	for title in ["Unit catalog", "Current roster", "Unit inspector"]: compact_navigation.add_item(title)
	compact_navigation.visible = false
	editor.add_child(compact_navigation)
	compact_navigation.item_selected.connect(func(_index: int): _layout_workspace())
	workspace_columns = HBoxContainer.new()
	workspace_columns.size_flags_vertical = Control.SIZE_EXPAND_FILL
	editor.add_child(workspace_columns)
	catalog_region = _workspace_region("UNIT CATALOG", 1.0)
	roster_region = _workspace_region("CURRENT ROSTER", 1.0)
	inspector_region = _workspace_region("UNIT INSPECTOR", 1.25)
	miniature_preview = preload("res://scripts/ui/miniature_preview.gd").new()
	inspector_region.add_child(miniature_preview)
	miniature_preview.surface.custom_minimum_size.y = 240
	miniature_preview.caption.add_theme_font_size_override("font_size", 13)
	preview_model_input = SpinBox.new()
	preview_model_input.prefix = "Preview model "
	preview_model_input.min_value = 1
	preview_model_input.max_value = 1
	preview_model_input.step = 1
	preview_model_input.tooltip_text = "Preview only; does not change equipment, appearances or points."
	inspector_region.add_child(preview_model_input)
	preview_model_input.value_changed.connect(func(value: float):
		if not preview_entry.is_empty():
			_preview_entry(preview_entry, int(value) - 1)
			if editor_tabs.current_tab == 2: _render_visual_slots()
	)
	editor_tabs = TabContainer.new()
	editor_tabs.size_flags_vertical = Control.SIZE_EXPAND_FILL
	inspector_region.add_child(editor_tabs)
	var pages := {}
	for title in ["Unit", "Add", "Appearance", "Army"]:
		var scroll := ScrollContainer.new()
		scroll.name = title
		scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
		scroll.custom_minimum_size.y = 120
		editor_tabs.add_child(scroll)
		var page := VBoxContainer.new()
		page.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		scroll.add_child(page)
		pages[title] = page
	miniature_preview.reparent(pages["Unit"])
	preview_model_input.reparent(pages["Unit"])
	addition_panel = pages["Add"]
	var destination := "Army"
	for control in original:
		if control in [name_input, summary_label]: continue
		if control == save_status:
			control.reparent(footer)
			control.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			control.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			continue
		if control is HBoxContainer and control.get_child_count() > 0 and control.get_child(0) is Button:
			if control.get_child(0).text == "← Armies":
				control.reparent(header)
				control.get_child(1).hide()
				continue
			if control.get_child(0).text == "Save list":
				control.reparent(footer)
				continue
		if control == notice:
			control.reparent(editor)
			control.max_lines_visible = 2
			control.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
			continue
		if control == catalog_boundary:
			control.reparent(editor)
			continue
		if control == notes:
			control.reparent(pages["Army"])
			continue
		if control is Label:
			if control.text == "List units": destination = "Unit"
			elif control.text == "CHOOSE UNITS": destination = "Add"
			elif control.text == "MINIATURE APPEARANCE": destination = "Appearance"
		if control in [chapter_status, query, role_picker, unit_picker]:
			control.reparent(catalog_region)
		elif control == entries:
			control.reparent(roster_region)
		elif control is Button and control.text in ["Remove selected entry", "Recalculate costs from current catalog"]:
			control.reparent(roster_region)
		elif control is Button and control.text in ["Find / add units ↓", "Back to roster"]:
			control.hide()
			control.reparent(pages["Army"])
		elif control is Label and control.text in ["List units", "CHOOSE UNITS", "MINIATURE APPEARANCE"]:
			control.hide()
			control.reparent(pages[destination])
		else:
			control.reparent(pages[destination])
	# Size controls are contextual and remain separate from add-copy controls.
	var size_row := entry_models_input.get_parent()
	unit_size_controls = VBoxContainer.new()
	pages["Unit"].add_child(unit_size_controls)
	var sizes := HBoxContainer.new()
	unit_size_controls.add_child(sizes)
	for control in [entry_models_input, entry_copies_input]:
		control.custom_minimum_size.x = 110
		control.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		control.reparent(sizes)
	for control in size_row.get_children(): control.reparent(unit_size_controls)
	size_row.queue_free()
	appearance_button = button("Choose appearance", _open_entry_appearance, pages["Unit"])
	import_button = button("Advanced model import…", func(): import_requested.emit(), pages["Appearance"])
	roster_empty = label("Your roster is empty.
Search the catalog, inspect a unit, then choose Add unit(s).", roster_region)
	roster_region.move_child(roster_empty, 1)
	entries.custom_minimum_size = Vector2(0, 130)
	entries.size_flags_vertical = Control.SIZE_EXPAND_FILL
	unit_picker.custom_minimum_size = Vector2(0, 80)
	unit_picker.size_flags_vertical = Control.SIZE_EXPAND_FILL
	chapter_status.max_lines_visible = 1
	chapter_status.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	copies.get_parent().reparent(catalog_region)
	unit_picker.allow_reselect = true
	entries.allow_reselect = true
	unit_picker.item_selected.connect(func(_index: int):
		candidate_preview = true
		editor_tabs.current_tab = 1
		_show_catalog_preview()
		compact_navigation.select(2)
		_layout_workspace()
	)
	entries.item_selected.connect(func(_index: int):
		candidate_preview = false
		editor_tabs.current_tab = 0
		compact_navigation.select(2)
		_layout_workspace()
	)
	editor.add_child(footer)
	var next := button("New match →", func(): new_match_requested.emit(), footer)
	next.tooltip_text = "Save this army, then choose saved armies in match setup."
	WorkspaceTheme.decorate_button(save_button, "save", true)
	WorkspaceTheme.decorate_button(add_button, "confirm", true)
	WorkspaceTheme.decorate_button(refresh_button, "reload")
	WorkspaceTheme.decorate_button(cancel_button, "close")
	if import_button != null:
		WorkspaceTheme.decorate_button(import_button, "miniatures")
	WorkspaceTheme.decorate_button(next, "new_match", true)
	for control in [choice_picker, composition_picker, enhancement_picker, faction_picker, role_picker]:
		control.fit_to_longest_item = false
		control.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	editor.visibility_changed.connect(_update_inspector_mode)
	editor_tabs.tab_changed.connect(_inspector_tab_changed)
	resized.connect(_layout_workspace)
	_render_summary()
	_update_inspector_mode()
	_layout_workspace()

func _workspace_region(title: String, ratio: float) -> VBoxContainer:
	var panel := PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.size_flags_stretch_ratio = ratio
	workspace_columns.add_child(panel)
	var column := VBoxContainer.new()
	column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.add_child(column)
	WorkspaceTheme.heading(column, title)
	return column

func _layout_workspace() -> void:
	if workspace_columns == null: return
	var compact := size.x < 980
	compact_navigation.visible = compact
	for index in 3:
		workspace_columns.get_child(index).visible = not compact or compact_navigation.selected == index

func _preview_request_current(ticket: int) -> bool:
	return is_inside_tree() and ticket == preview_generation

func _exit_tree() -> void:
	preview_generation += 1
	appearance_generation += 1
	preview_busy = false

func _show_catalog_preview() -> void:
	if selected_unit.is_empty() or miniature_preview == null: return
	preview_generation += 1
	var ticket := preview_generation
	var item := selected_unit.duplicate(true)
	var current := _preview_request_current.bind(ticket)
	preview_busy = true
	miniature_preview.show_model(item, null, false)
	miniature_preview.title.text = "Catalog · " + str(item.name)
	miniature_preview.caption.text = "Loading local miniature…"
	miniature_preview.surface.visible = false
	miniature_preview.camera_controls.visible = false
	preview_model_input.hide()
	var visual: Node3D = null
	if model_imports != null: visual = await model_imports.preview_visual_for_async(str(item.id), current)
	if not current.call():
		if visual != null: visual.free()
		return
	preview_busy = false
	miniature_preview.show_model(item, visual, visual != null)
	miniature_preview.title.text = "Catalog · " + str(item.name)

func _inspector_tab_changed(index: int) -> void:
	_update_inspector_mode()
	if index == 1 and not selected_unit.is_empty():
		candidate_preview = true
		_show_catalog_preview()
	elif candidate_preview:
		_preview_entry(preview_entry, preview_slot)
	if index == 2: _render_visual_slots()

func _preview_entry(item: Dictionary, slot: int = 0) -> void:
	preview_generation += 1
	var ticket := preview_generation
	var current := _preview_request_current.bind(ticket)
	candidate_preview = false
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
	preview_busy = true
	miniature_preview.show_model(item, null, false)
	miniature_preview.title.text = "Roster · " + str(item.get("name", "Select a unit"))
	miniature_preview.caption.text = "Loading local miniature…" if not item.is_empty() else "Select a roster unit to preview its appearance."
	miniature_preview.surface.visible = false
	miniature_preview.camera_controls.visible = false
	var visual: Node3D = null
	var missing_variant := false
	var role_variant_missing := false
	var role_loadout_fallback := false
	if model_imports != null:
		var models := maxi(1, int(item.get("models", 1)))
		var copy_index := floori(float(slot) / float(models))
		var model_index := posmod(slot, models)
		var appearance_index := _appearance_index_for(item, copy_index)
		var model_override := Roster.model_visual_override(item, copy_index, model_index)
		var unit_choice := Roster.unit_visual_variant(item, copy_index)
		var role_choice := ""
		var role_variant := ""
		if str(item.get("unit_id", "")).ends_with(":intercessor-squad") and model_index == 0:
			var loadout := Roster.intercessor_sergeant_loadout(item, copy_index)
			var role_unit := {"definition_id": str(item.unit_id), "sergeant": true, "intercessor_rifle_choice": str(loadout.rifle_choice), "intercessor_melee_choice": str(loadout.melee_choice)}
			role_choice = ForceOrgMatcher.intercessor_sergeant_visual_role(role_unit)
			role_variant = model_imports.visual_role_variant_for(role_choice)
			role_variant_missing = role_choice != ForceOrgMatcher.INTERCESSOR_SERGEANT_DEFAULT_ROLE and role_variant.is_empty()
			role_loadout_fallback = role_choice == ForceOrgMatcher.INTERCESSOR_SERGEANT_DEFAULT_ROLE and (str(loadout.rifle_choice) != "bolt-rifle" or str(loadout.melee_choice) != "knives-and-fists")
		var chosen := role_variant
		if chosen.is_empty(): chosen = model_override if not model_override.is_empty() else unit_choice
		var explicit_choice := not chosen.is_empty()
		var palette_choice := Roster.palette_variant(draft, str(item.get("unit_id", "")), appearance_index)
		if chosen.is_empty(): chosen = palette_choice
		if chosen.is_empty() and model_imports.has_method("automatic_variant_for"):
			chosen = model_imports.automatic_variant_for(str(item.get("unit_id", "")), appearance_index)
		if not chosen.is_empty(): visual = await model_imports.preview_variant_for_async(chosen, current)
		if visual == null and not role_variant.is_empty(): role_variant_missing = true
		missing_variant = (explicit_choice or not palette_choice.is_empty()) and visual == null
		if visual == null and not model_override.is_empty() and not unit_choice.is_empty() and unit_choice != model_override:
			visual = await model_imports.preview_variant_for_async(unit_choice, current)
		if visual == null and not palette_choice.is_empty() and chosen != palette_choice:
			visual = await model_imports.preview_variant_for_async(palette_choice, current)
		if visual == null and item.has("unit_id"): visual = await model_imports.preview_visual_for_async(str(item.unit_id), current)
		if not current.call():
			if visual != null: visual.free()
			return
		_update_palette_status(item, slot)
	if not current.call():
		if visual != null: visual.free()
		return
	preview_busy = false
	miniature_preview.show_model(item, visual, visual != null)
	if not item.is_empty(): miniature_preview.title.text = "Roster · " + str(item.name)
	if total > 0:
		var model_index := slot % int(item.models)
		miniature_preview.caption.text += "\nUnit %d · %s" % [slot / int(item.models) + 1, _visual_model_role_label(item, model_index)]
		if str(item.get("unit_id", "")).ends_with(":intercessor-squad") and model_index == 0:
			var loadout := Roster.intercessor_sergeant_loadout(item, floori(float(slot) / float(maxi(1, int(item.models)))))
			miniature_preview.caption.text += "\nSergeant · %s + %s" % [str(Roster.INTERCESSOR_RIFLE_CHOICES[loadout.rifle_choice]), str(Roster.INTERCESSOR_MELEE_CHOICES[loadout.melee_choice])]
			if role_variant_missing: miniature_preview.caption.text += "\nMatching weapon sculpt prepares before a local match; fallback shown for now."
			elif role_loadout_fallback: miniature_preview.caption.text += "\nNo exact local sculpt for this combination; the default Sergeant sculpt will be used."
	elif not item.is_empty(): miniature_preview.caption.text += "\nComposition pending · representative visual"
	if missing_variant: miniature_preview.caption.text += "\nAssigned variant unavailable · fallback shown"
	miniature_preview.caption.tooltip_text = miniature_preview.caption.text

func _update_palette_status(item: Dictionary, slot: int) -> void:
	if palette_button == null: return
	var palette: Dictionary = draft.get("visual_palette", {})
	var choices: Array = palette.get(str(item.get("unit_id", "")), [])
	var models := maxi(1, int(item.get("models", 1)))
	var chosen := Roster.unit_visual_variant(item, floori(float(slot) / float(models)))
	palette_button.disabled = chosen.is_empty() or (choices.size() >= 16 and chosen not in choices)
	palette_button.text = "Remove selected paint from army palette" if chosen in choices else "Add selected paint to army palette"
	palette_prepare_button.disabled = palette.is_empty() or model_imports == null
	palette_notice.text = "Army palette · %d unit type(s) configured · %d choices for this type. Unit copies can use different choices; models inherit their unit choice unless given a sculpt override." % [palette.size(), choices.size()]

func _prepare_added_units() -> void:
	if pending_appearance_units.is_empty() or model_imports == null: return
	if not automatic_appearance_toggle.button_pressed:
		pending_appearance_units.clear()
		return
	if model_imports.automatic_running or model_imports.variant_download_active or model_imports.downloader.busy: return
	var requests := {}
	var definitions: Array[String] = []
	var palette: Dictionary = draft.get("visual_palette", {})
	for item: Dictionary in draft.entries:
		var definition := str(item.unit_id)
		if definition not in pending_appearance_units: continue
		if definition not in definitions:
			definitions.append(definition)
			requests[definition] = {"count": 0, "manual": palette.get(definition, [])}
		if not palette.has(definition): requests[definition].count = mini(int(requests[definition].count) + int(item.copies), 4)
	pending_appearance_units.clear()
	if not definitions.is_empty(): model_imports.prepare_armies(definitions, false, false, requests)

func _prepare_army_palette() -> void:
	if model_imports == null: return
	var palette: Dictionary = draft.get("visual_palette", {})
	var requests := {}
	for item: Dictionary in draft.get("entries", []):
		var definition := str(item.get("unit_id", ""))
		if palette.has(definition):
			requests[definition] = {"count": 0, "manual": palette[definition]}
	if not requests.is_empty():
		var definitions: Array[String] = []
		model_imports.prepare_armies(definitions, false, false, requests)

func _toggle_palette_choice() -> void:
	if selected_entry_index < 0 or selected_entry_index >= draft.entries.size(): return
	var item: Dictionary = draft.entries[selected_entry_index]
	var models := maxi(1, int(item.get("models", 1)))
	var copy_index := floori(float(preview_slot) / float(models))
	var chosen := Roster.unit_visual_variant(item, copy_index)
	if chosen.is_empty(): return
	var palette: Dictionary = draft.get("visual_palette", {})
	var definition := str(item.unit_id)
	var choices: Array = palette.get(definition, [])
	if chosen in choices: choices.erase(chosen)
	elif choices.size() < 16: choices.append(chosen)
	if choices.is_empty(): palette.erase(definition)
	else: palette[definition] = choices
	draft.visual_palette = palette
	dirty = true
	_preview_entry(item, preview_slot)
	_render_summary()

func _update_inspector_mode() -> void:
	if addition_panel == null: return
	resume_draft_button.visible = dirty
	library_workspace.visible = not editor.visible
	appearance_button.visible = editor.visible and not preview_entry.is_empty()
	if roster_empty != null: roster_empty.visible = draft.entries.is_empty()
	if unit_size_controls != null: unit_size_controls.visible = selected_entry_index >= 0 and selected_entry_index < draft.entries.size()
	enhancement_picker.visible = selected_entry_index >= 0 and selected_entry_index < draft.entries.size()
	var page: Node = editor_tabs.get_child(editor_tabs.current_tab).get_child(0) if editor.visible else library_preview
	if miniature_preview.get_parent() != page: miniature_preview.reparent(page)
	page.move_child(miniature_preview, 0)
	if preview_model_input.get_parent() != page: preview_model_input.reparent(page)
	page.move_child(preview_model_input, 1)
	if editor.visible and editor_tabs.current_tab == 0 and unit_size_controls != null:
		page.move_child(unit_size_controls, 0)

func _open_entry_appearance() -> void:
	if not editor.visible or selected_entry_index < 0 or selected_entry_index >= draft.entries.size(): return
	reveal_appearance_when_ready = true
	var count := maxi(1, int(draft.entries[selected_entry_index].models))
	visual_copy_picker.select(clampi(preview_slot / count, 0, maxi(0, visual_copy_picker.item_count - 1)))
	if editor_tabs.current_tab != 2: editor_tabs.current_tab = 2
	else: _render_visual_slots()

func _sync() -> void:
	if updating: return
	draft.name = name_input.text.strip_edges()
	draft.category = category_picker.get_selected_metadata()
	draft.points_limit = int(points_limit.value)
	draft.allow_allies = allies.button_pressed
	draft.notes = notes.text
	for item: Dictionary in draft.entries: _ensure_visual_slots(item)

func _changed() -> void:
	if updating: return
	_sync()
	dirty = true
	save_error = ""
	_render_summary()

func _render_summary() -> void:
	if resume_draft_button != null: resume_draft_button.visible = dirty
	var totals := Roster.summary(draft)
	var outside := 0
	for item: Dictionary in draft.entries:
		if not source.supports_size(str(item.unit_id), int(item.models)): outside += int(item.copies)
	var legacy_training: bool = draft.get("pricing_source", "") == "starter-training-v1"
	catalog_boundary.visible = outside > 0 or legacy_training
	catalog_boundary.text = ("%d units use the historical training profile · preserved as a legacy draft" % draft.entries.size()) if legacy_training else ("%d units outside the consolidated catalog/compositions · preserved as a legacy draft" % outside)
	var models := 0
	for item: Dictionary in draft.entries: models += int(item.models) * int(item.copies)
	summary_label.text = "%d / %d pts • %d units • %d models" % [totals.points, draft.points_limit, totals.units, models]
	if points_meter != null:
		points_meter.max_value = maxi(1, int(draft.points_limit))
		points_meter.value = totals.points
		points_meter.tooltip_text = "Partial total" if totals.unknown > 0 else "%d points remaining" % totals.remaining
	if roster_empty != null: roster_empty.visible = draft.entries.is_empty()
	if totals.unknown > 0: summary_label.text += "\n%d unit(s) without confirmed costs; total is partial." % totals.unknown
	elif totals.remaining < 0: summary_label.text += "\nOver the limit by %d pts; you can save as a draft." % -totals.remaining
	else: summary_label.text += "\n%d pts remaining." % totals.remaining
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
	var selected_composition: Dictionary = composition_picker.get_item_metadata(composition_picker.selected) if composition_picker.visible and composition_picker.selected >= 0 else {}
	var amount := int(copies.value)
	var totals := Roster.summary(draft)
	var count := int(option.get("models", 0))
	var unknown: bool = option.get("cost") == null
	var wargear_cost := int(selected_composition.get("wargear_cost", 0))
	var tiered_addition: Variant = Roster.addition_cost(draft, str(selected_unit.id), option, amount, wargear_cost)
	var added := 0 if unknown else int(tiered_addition)
	var partial: bool = unknown or int(totals.unknown) > 0
	var role_summary := "\nRoles · " + str(selected_composition.get("label", "")) if not selected_composition.is_empty() else ""
	var banner_summary := " (+15 pts per unit for Banner of Macragge)" if wargear_cost > 0 else ""
	addition_summary.text = "To add · %s\n%d units · %s · %s%s%s\nAfter adding: %d / %d pts%s" % [str(selected_unit.name), amount, _model_count_label(count * amount) if count > 0 else "composition pending", "cost unconfirmed" if unknown else "%d pts added" % added, role_summary, banner_summary, int(totals.points) + added, int(draft.points_limit), " · partial" if partial else (" · over budget" if int(totals.points) + added > int(draft.points_limit) else "")]

func _refresh_composition_options() -> void:
	if composition_picker == null: return
	composition_picker.clear()
	composition_picker.visible = false
	composition_hint.visible = false
	if selected_unit.is_empty() or choice_picker.selected < 0 or choice_picker.selected >= selected_unit.get("options", []).size():
		_refresh_addition_summary()
		return
	var models := int(selected_unit.options[choice_picker.selected].get("models", 0))
	for option: Dictionary in selected_unit.get("composition_options", []):
		if int(option.get("models", -1)) != models: continue
		var price := " • +%d pts" % int(option.get("wargear_cost", 0)) if int(option.get("wargear_cost", 0)) > 0 else ""
		composition_picker.add_item(str(option.get("label", "Source-defined roles")) + price)
		composition_picker.set_item_metadata(composition_picker.item_count - 1, option)
		if str(option.get("id", "")) == "ancient-champion": composition_picker.select(composition_picker.item_count - 1)
	composition_picker.visible = composition_picker.item_count > 0
	composition_hint.visible = composition_picker.visible
	if composition_picker.visible and composition_picker.selected < 0: composition_picker.select(0)
	_refresh_addition_summary()

func _scroll_to(control: Control) -> void:
	if editor_tabs != null:
		if control == summary_label: editor_tabs.current_tab = 0
		for index in editor_tabs.get_tab_count():
			if editor_tabs.get_child(index).is_ancestor_of(control): editor_tabs.current_tab = index
	call_deferred("_reveal_control", control)

func _reveal_control(control) -> void:
	if not is_instance_valid(control) or not control is Control or not control.is_inside_tree(): return
	var ancestor: Node = control.get_parent()
	while ancestor != null:
		if ancestor is ScrollContainer:
			ancestor.ensure_control_visible(control)
		ancestor = ancestor.get_parent()
	if control.focus_mode == Control.FOCUS_ALL and control.is_visible_in_tree():
		if not (control is BaseButton and control.disabled): control.grab_focus()

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
		var source_suffix := " • " + str(item.source_scope) if str(item.get("source_scope", "")) != "" else ""
		var composition_label := _composition_label(item)
		var composition_suffix := " • " + composition_label if not composition_label.is_empty() else ""
		var equipment_suffix := _sergeant_loadout_summary(item)
		entries.add_item("%d× %s%s • %s • %s%s%s%s" % [item.copies, item.name, source_suffix, _model_count_label(int(item.models)) if item.models > 0 else "composition pending", "%d pts" % int(entry_points) if entry_points != null else "cost pending", composition_suffix, enhancement_suffix, equipment_suffix])
		entries.set_item_tooltip(index, entries.get_item_text(index))
	updating = false
	_fill_factions()
	_render_summary()
	if selected_entry_index >= draft.entries.size(): selected_entry_index = -1
	if selected_entry_index < 0 and not draft.entries.is_empty(): selected_entry_index = 0
	if selected_entry_index >= 0:
		entries.select(selected_entry_index)
		_select_entry(selected_entry_index)
	else:
		_render_sergeant_loadout_controls(0)
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
		var models := 0
		for item: Dictionary in list.entries: models += int(item.models) * int(item.copies)
		var legacy := " · legacy draft" if list.get("pricing_source", "") == "starter-training-v1" else ""
		saved_lists_view.add_item("%s  ·  %s  ·  %d / %d pts  ·  %d units · %d models%s" % [list.name, list.faction, totals.points, int(list.points_limit), totals.units, models, legacy])
		saved_lists_view.set_item_tooltip(saved_lists_view.item_count - 1, saved_lists_view.get_item_text(saved_lists_view.item_count - 1))
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
		var composition_label := _composition_label(entry)
		var composition_suffix := " · " + composition_label if not composition_label.is_empty() else ""
		var source_suffix := " · " + str(entry.source_scope) if str(entry.get("source_scope", "")) != "" else ""
		var equipment_suffix := _sergeant_loadout_summary(entry)
		saved_roster.add_item("%d× %s%s · %s%s%s · %s" % [entry.copies, entry.name, source_suffix, _model_count_label(int(entry.models)), composition_suffix, equipment_suffix, "%d pts" % int(entry_points) if entry_points != null else "cost pending"])
	if totals.unknown > 0: lines.append("Some costs are unconfirmed; total is partial.")
	saved_list_detail.text = "\n".join(lines)
	if not list.entries.is_empty():
		saved_roster.select(0)
		if not editor.visible: _preview_entry(list.entries[0])

func _composition_label(entry: Dictionary) -> String:
	var identity := str(entry.get("unit_id", "")).get_slice(":", 3)
	var profile := CurrentMarines.profile(identity)
	var choices: Array = profile.get("composition_options", [])
	if choices.is_empty(): return ""
	var choice_id := str(entry.get("composition_choice_id", "ancient-champion"))
	for option: Dictionary in choices:
		if int(option.get("models", -1)) == int(entry.get("models", 0)) and str(option.get("id", "")) == choice_id:
			return str(option.get("label", "")) + (" · +%d Banner" % int(option.get("wargear_cost", 0)) if int(option.get("wargear_cost", 0)) > 0 else "")
	return ""

func _model_count_label(count: int) -> String:
	return "%d model%s" % [count, "" if count == 1 else "s"]

func _visual_model_role_label(item: Dictionary, model_index: int) -> String:
	var definition := str(item.get("unit_id", ""))
	if definition.ends_with(":intercessor-squad") and model_index == 0:
		return "Intercessor Sergeant"
	return "Model %d" % (model_index + 1)

func _edit_saved_list() -> void:
	if selected_saved_id.is_empty():
		library_notice.text = "Select a saved army first."
		return
	if dirty and selected_saved_id == str(draft.id): _resume_draft()
	else: _request_editor_action(_load_list_by_id.bind(selected_saved_id))

func _resume_draft() -> void:
	editor.visible = true
	overview.visible = false
	_render_draft()
	name_input.grab_focus()

func _request_editor_action(action: Callable) -> void:
	_sync()
	if not dirty:
		action.call()
		return
	pending_editor_action = action
	unsaved_dialog.dialog_text = "This army has unsaved changes. Save the draft, keep editing, or discard changes before continuing."
	unsaved_dialog.popup_centered(Vector2i(530, 170))
	unsaved_dialog.get_cancel_button().grab_focus()

func _continue_editor_action() -> void:
	var action := pending_editor_action
	pending_editor_action = Callable()
	unsaved_dialog.hide()
	if action.is_valid(): action.call()

func _duplicate_saved_list() -> void:
	if selected_saved_id.is_empty():
		library_notice.text = "Select a saved army first."
		return
	var identity := selected_saved_id
	_request_editor_action(func():
		if source.busy:
			library_notice.text = "Wait for the catalog before duplicating this army."
			return
		_load_list_by_id(identity)
		_save_copy()
	)

func _close_editor() -> void:
	_sync()
	drafts[store.data.active] = draft.duplicate(true)
	editor.visible = false
	overview.visible = true
	_show_saved_detail(selected_saved_id)
	library_notice.text = "Unsaved changes are kept in this session." if dirty else ""

func _ensure_visual_slots(item: Dictionary) -> void:
	Roster.normalize_visual_variants(item)
	Roster.normalize_model_visual_overrides(item)

func _select_entry(index: int) -> void:
	selected_entry_index = index
	visual_copy_picker.clear()
	if index < 0 or index >= draft.entries.size():
		_render_sergeant_loadout_controls(0)
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
	visual_notice.text = "Choose a local paint appearance per unit copy. A Sergeant's supported loadout sculpt follows its saved equipment choice. Visual files and mapping IDs remain local."
	_render_sergeant_loadout_controls(0)
	_render_visual_slots()

func _sergeant_loadout_copy_selected(index: int) -> void:
	_render_sergeant_loadout_controls(index)
	if selected_entry_index < 0 or selected_entry_index >= draft.entries.size(): return
	var item: Dictionary = draft.entries[selected_entry_index]
	_preview_entry(item, index * maxi(1, int(item.get("models", 1))))
	_render_visual_slots()

func _sergeant_loadout_summary(item: Dictionary) -> String:
	if not item.has("intercessor_sergeant_loadouts") or not item.intercessor_sergeant_loadouts is Array: return ""
	var loadouts: Array = item.intercessor_sergeant_loadouts
	if loadouts.is_empty(): return ""
	var first := Roster.intercessor_sergeant_loadout(item, 0)
	var same := true
	for copy_index in range(1, loadouts.size()):
		var current := Roster.intercessor_sergeant_loadout(item, copy_index)
		if current != first:
			same = false
			break
	if not same: return " · Sergeant equipment varies by unit"
	return " · Sergeant: %s + %s" % [str(Roster.INTERCESSOR_RIFLE_CHOICES[first.rifle_choice]), str(Roster.INTERCESSOR_MELEE_CHOICES[first.melee_choice])]

func _render_sergeant_loadout_controls(preferred_copy: int = -1) -> void:
	if sergeant_loadout_heading == null: return
	var visible: bool = selected_entry_index >= 0 and selected_entry_index < draft.entries.size()
	var item: Dictionary = draft.entries[selected_entry_index] if visible else {}
	visible = visible and str(item.get("unit_id", "")).ends_with(":intercessor-squad") and int(item.get("models", 0)) > 0
	sergeant_loadout_heading.visible = visible
	sergeant_loadout_copy_picker.visible = visible
	sergeant_rifle_picker.visible = visible
	sergeant_melee_picker.visible = visible
	if not visible: return
	var wanted_copy := preferred_copy if preferred_copy >= 0 else maxi(0, sergeant_loadout_copy_picker.selected)
	sergeant_loadout_copy_picker.clear()
	for copy_index in range(int(item.get("copies", 0))):
		sergeant_loadout_copy_picker.add_item("Unit %d Sergeant" % (copy_index + 1))
		sergeant_loadout_copy_picker.set_item_metadata(copy_index, copy_index)
	var copy_index := clampi(wanted_copy, 0, maxi(0, int(item.get("copies", 0)) - 1))
	sergeant_loadout_copy_picker.select(copy_index)
	var loadout := Roster.intercessor_sergeant_loadout(item, copy_index)
	_select_equipment_choice(sergeant_rifle_picker, str(loadout.rifle_choice))
	_select_equipment_choice(sergeant_melee_picker, str(loadout.melee_choice))

func _select_equipment_choice(picker: OptionButton, choice_id: String) -> void:
	for option_index in range(picker.item_count):
		if str(picker.get_item_metadata(option_index)) == choice_id:
			picker.select(option_index)
			return

func _set_sergeant_loadout_from_controls() -> void:
	if updating or selected_entry_index < 0 or selected_entry_index >= draft.entries.size(): return
	if sergeant_loadout_copy_picker.selected < 0 or sergeant_rifle_picker.selected < 0 or sergeant_melee_picker.selected < 0: return
	var item: Dictionary = draft.entries[selected_entry_index]
	var copy_index := int(sergeant_loadout_copy_picker.get_selected_metadata())
	var rifle_choice := str(sergeant_rifle_picker.get_selected_metadata())
	var melee_choice := str(sergeant_melee_picker.get_selected_metadata())
	var prior := Roster.intercessor_sergeant_loadout(item, copy_index)
	if str(prior.rifle_choice) == rifle_choice and str(prior.melee_choice) == melee_choice: return
	Roster.set_intercessor_sergeant_loadout(item, copy_index, rifle_choice, melee_choice)
	dirty = true
	save_error = ""
	var slot := copy_index * maxi(1, int(item.get("models", 1)))
	_preview_entry(item, slot)
	_render_visual_slots()
	_render_summary()
	if notice != null: notice.text = "Sergeant equipment saved for this unit copy. You can adjust it again during match preparation when the rules permit."

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
		enhancement_picker.set_item_tooltip(index, str(enhancement.get("rule", "")))
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
	if identity.is_empty():
		notice.text = "Enhancement removed from this unit."
	else:
		var effect_text := ""
		for enhancement: Dictionary in source.catalog.get("enhancements", []):
			if str(enhancement.get("id", "")) == identity:
				effect_text = str(enhancement.get("rule", ""))
				break
		notice.text = "Enhancement assigned to one unit. %s Verify the matching detachment when preparing the match." % effect_text

func _apply_entry_size() -> void:
	if selected_entry_index < 0 or selected_entry_index >= draft.entries.size():
		notice.text = "Select a unit entry first."
		return
	var item: Dictionary = draft.entries[selected_entry_index]
	var next_models := int(entry_models_input.value)
	var next_copies := int(entry_copies_input.value)
	var prior_appearances: Array[String] = []
	for copy_index in range(int(item.get("copies", 0))): prior_appearances.append(Roster.unit_visual_variant(item, copy_index))
	var prior_models := int(item.get("models", 0))
	var had_sergeant_loadouts := item.has("intercessor_sergeant_loadouts")
	var prior_model_overrides: Array[String] = []
	for copy_index in range(int(item.get("copies", 0))):
		for model_index in range(prior_models): prior_model_overrides.append(Roster.model_visual_override(item, copy_index, model_index))
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
		if had_sergeant_loadouts: Roster.normalize_intercessor_sergeant_loadouts(unenhanced)
		item.copies = 1
		draft.entries.insert(selected_entry_index + 1, unenhanced)
	else: item.copies = next_copies
	if had_sergeant_loadouts: Roster.normalize_intercessor_sergeant_loadouts(item)
	item.visual_variants = []
	for _slot in range(mini(maxi(0, int(item.models) * int(item.copies)), 20000)): item.visual_variants.append("")
	item.visual_model_overrides = []
	for _slot in range(mini(maxi(0, int(item.models) * int(item.copies)), 20000)): item.visual_model_overrides.append("")
	_ensure_visual_slots(item)
	for copy_index in range(mini(prior_appearances.size(), int(item.copies))):
		Roster.set_unit_visual_variant(item, copy_index, prior_appearances[copy_index])
	for copy_index in range(mini(int(item.copies), int(prior_appearances.size()))):
		for model_index in range(mini(prior_models, int(item.models))):
			var old_slot := copy_index * prior_models + model_index
			var override_id := prior_model_overrides[old_slot] if old_slot < prior_model_overrides.size() else ""
			if not override_id.is_empty(): Roster.set_model_visual_override(item, copy_index, model_index, override_id)
	dirty = true
	_render_draft()
	entries.select(selected_entry_index)
	_select_entry(selected_entry_index)
	notice.text = "Unit size updated. Recalculate or confirm costs before relying on the points total." if next_models > 0 else "Composition is pending; this list may not pass a training check."

func _render_visual_slots() -> void:
	if visual_models == null or editor_tabs == null or not editor.visible or editor_tabs.current_tab != 2: return
	appearance_generation += 1
	var ticket := appearance_generation
	var wanted_copy := visual_copy_picker.selected
	for child in visual_models.get_children():
		visual_models.remove_child(child)
		child.queue_free()
	visual_slot_controls.clear()
	visual_model_override_control = null
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
	var entry_index := selected_entry_index
	var current := func() -> bool: return is_inside_tree() and ticket == appearance_generation and editor.visible and editor_tabs.current_tab == 2 and selected_entry_index == entry_index
	var loading := Label.new()
	loading.text = "Loading local appearances…"
	visual_models.add_child(loading)
	if reveal_appearance_when_ready: _scroll_to(loading)
	var variants: Array = []
	if model_imports != null: variants = await model_imports.variants_for_async(definition, current)
	if not current.call(): return
	loading.queue_free()
	visual_download_button.disabled = true
	if model_imports != null: visual_download_button.disabled = not model_imports.has_method("download_variants_for")
	var unit_label := Label.new()
	unit_label.text = "Unit appearance · shared by all models"
	visual_models.add_child(unit_label)
	var picker := _appearance_picker(variants, "Automatic appearance")
	visual_models.add_child(picker)
	var selected_variant := Roster.unit_visual_variant(item, copy_index)
	_select_appearance(picker, selected_variant)
	var captured_copy := copy_index
	picker.item_selected.connect(func(option_index: int): _set_visual_slot(captured_copy * maxi(1, int(item.models)), str(picker.get_item_metadata(option_index))))
	visual_slot_controls.append(picker)
	var models := maxi(1, int(item.get("models", 1)))
	var model_index := posmod(preview_slot, models)
	var model_label := Label.new()
	var role_label := _visual_model_role_label(item, model_index)
	var is_intercessor_sergeant := str(item.get("unit_id", "")).ends_with(":intercessor-squad") and model_index == 0
	model_label.text = "%s sculpt fallback · %s" % ["Sergeant" if is_intercessor_sergeant else "Optional", role_label]
	model_label.tooltip_text = "The Sergeant's saved equipment selects its matching sculpt whenever one is available. This per-model assignment is only used as a local fallback." if is_intercessor_sergeant else "Use a reviewed sculpt override for this model only; other models keep the unit appearance."
	visual_models.add_child(model_label)
	visual_model_override_control = _appearance_picker(variants, "Use unit appearance")
	visual_models.add_child(visual_model_override_control)
	_select_appearance(visual_model_override_control, Roster.model_visual_override(item, copy_index, model_index))
	var captured_model_slot := copy_index * int(item.models) + model_index
	visual_model_override_control.item_selected.connect(func(option_index: int): _set_model_visual_override(captured_model_slot, str(visual_model_override_control.get_item_metadata(option_index))))
	visual_slot_controls.append(visual_model_override_control)
	if variants.is_empty():
		visual_notice.text = "Prepare appearances to find compatible sculpts. Sergeant equipment choices remain saved and will be matched when possible."
	elif is_intercessor_sergeant:
		visual_notice.text = "%d catalog variants. Unit %d shares its base appearance; the Sergeant follows its saved equipment sculpt when available, then this fallback." % [variants.size(), copy_index + 1]
	else:
		visual_notice.text = "%d catalog variants. Unit %d shares one base appearance; %s can use a reviewed sculpt override." % [variants.size(), copy_index + 1, role_label]

	if reveal_appearance_when_ready:
		reveal_appearance_when_ready = false
		_scroll_to(picker)

func _appearance_picker(variants: Array, default_label: String) -> OptionButton:
	var picker := OptionButton.new()
	picker.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	picker.add_item(default_label)
	picker.set_item_metadata(0, "")
	for variant_index in range(variants.size()):
		var raw_option: Variant = variants[variant_index]
		if not raw_option is Dictionary: continue
		var option: Dictionary = raw_option
		var paint := " · texture %d for this sculpt" % int(option.paint_index) if option.get("paint_alternative", false) else ""
		picker.add_item("%d · %s%s%s" % [variant_index + 1, str(option.get("name", "Visual variant")), paint, " · ready" if option.get("ready", false) else " · download"])
		picker.set_item_metadata(picker.item_count - 1, str(option.get("variant_id", "")))
	return picker

func _select_appearance(picker: OptionButton, visual_id: String) -> void:
	for option_index in range(picker.item_count):
		if str(picker.get_item_metadata(option_index)) == visual_id: picker.select(option_index)

func _set_visual_slot(slot: int, variant_id: String) -> void:
	if selected_entry_index < 0 or selected_entry_index >= draft.entries.size(): return
	var item: Dictionary = draft.entries[selected_entry_index]
	_ensure_visual_slots(item)
	var models := int(item.get("models", 0))
	if models <= 0 or slot < 0 or slot >= item.visual_variants.size(): return
	Roster.set_unit_visual_variant(item, floori(float(slot) / float(models)), variant_id)
	save_error = ""
	_preview_entry(item, slot)
	dirty = true
	_render_summary()

func _set_model_visual_override(slot: int, variant_id: String) -> void:
	if selected_entry_index < 0 or selected_entry_index >= draft.entries.size(): return
	var item: Dictionary = draft.entries[selected_entry_index]
	_ensure_visual_slots(item)
	if slot < 0 or slot >= item.visual_model_overrides.size(): return
	item.visual_model_overrides[slot] = variant_id
	save_error = ""
	_preview_entry(item, slot)
	dirty = true
	_render_summary()

func _download_unit_variants() -> void:
	if selected_entry_index < 0 or selected_entry_index >= draft.entries.size() or model_imports == null: return
	var item: Dictionary = draft.entries[selected_entry_index]
	var models := maxi(1, int(item.get("models", 1)))
	var copy_index := floori(float(preview_slot) / float(models))
	var model_index := posmod(preview_slot, models)
	var selected := Roster.model_visual_override(item, copy_index, model_index)
	if selected.is_empty(): selected = Roster.unit_visual_variant(item, copy_index)
	if selected.is_empty():
		selected = Roster.palette_variant(draft, str(item.unit_id), _appearance_index_for(item, copy_index))
	model_imports.download_variants_for(str(item.unit_id), selected)

func _appearance_index_for(item: Dictionary, copy_index: int) -> int:
	var index := copy_index
	if selected_entry_index < 0 or selected_entry_index >= draft.entries.size(): return index
	var definition := str(item.get("unit_id", ""))
	for entry_index in range(selected_entry_index):
		var previous: Dictionary = draft.entries[entry_index]
		if str(previous.get("unit_id", "")) == definition: index += int(previous.get("copies", 0))
	return index

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
	_request_editor_action(_load_list_by_id.bind(str(saved_picker.get_selected_metadata())))

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
	if draft.faction.is_empty() and not names.is_empty():
		draft.faction = "Space Marines" if names.has("Space Marines") else names[0]
	for index in range(faction_picker.item_count):
		if faction_picker.get_item_text(index) == draft.faction: faction_picker.select(index)
	_filter_units()

func _filter_units() -> void:
	unit_picker.clear()
	choice_picker.clear()
	selected_unit = {}
	if candidate_preview and miniature_preview != null:
		miniature_preview.show_model({}, null, false)
		miniature_preview.title.text = "Catalog · select a unit"
		preview_model_input.hide()
	_refresh_construction_scope_hint()
	if composition_picker != null:
		composition_picker.clear()
		composition_picker.visible = false
		composition_hint.visible = false
	_refresh_addition_summary()
	add_button.disabled = true
	var chapter_state := _draft_chapter_state()
	_refresh_chapter_status(chapter_state)
	for unit: Dictionary in source.catalog.get("units", []):
		if unit.edition != draft.edition or not Roster.faction_allowed(draft.faction, unit.faction, allies.button_pressed): continue
		if draft.faction == "Space Marines":
			var unit_chapters := CurrentMarines.chapter_keywords(str(unit.get("source_id", "")))
			if unit_chapters.size() > 1: continue
			if not unit_chapters.is_empty() and not chapter_state.chapters.is_empty():
				if chapter_state.chapters.size() > 1 or unit_chapters[0] != chapter_state.chapters[0]: continue
		if not query.text.strip_edges().is_empty() and query.text.strip_edges().to_lower() not in unit.name.to_lower(): continue
		var roles := {1: ["Character", "Personagem"], 2: ["Battleline", "Linha de batalha"], 3: ["Dedicated transport", "Transporte dedicado"], 4: ["Other units"]}
		if role_picker.selected > 0 and unit.role not in roles[role_picker.selected]: continue
		var source_suffix := " • " + str(unit.source_scope) if str(unit.get("source_scope", "")) != "" else ""
		unit_picker.add_item(unit.name + source_suffix + (" • " + unit.faction if unit.faction != draft.faction else ""))
		unit_picker.set_item_metadata(unit_picker.item_count - 1, unit)
		unit_picker.set_item_tooltip(unit_picker.item_count - 1, str(unit.name) + "\n" + str(unit.role) + " · select to inspect available sizes and costs")

func _draft_chapter_state() -> Dictionary:
	var chapters: Array[String] = []
	var outside_catalog := false
	if draft.get("edition", "") != "11e" or draft.get("faction", "") != "Space Marines":
		return {"applies": false, "chapters": chapters, "outside_catalog": false}
	for entry: Dictionary in draft.get("entries", []):
		var unit: Dictionary = source.lookup(str(entry.get("unit_id", "")))
		if unit.is_empty():
			outside_catalog = true
			continue
		for chapter: String in CurrentMarines.chapter_keywords(str(unit.get("source_id", ""))):
			if chapter not in chapters: chapters.append(chapter)
	chapters.sort()
	return {"applies": true, "chapters": chapters, "outside_catalog": outside_catalog}

func _refresh_chapter_status(chapter_state: Dictionary) -> void:
	if chapter_status == null: return
	chapter_status.visible = bool(chapter_state.get("applies", false))
	if not chapter_status.visible: return
	var chapters: Array = chapter_state.get("chapters", [])
	if chapters.size() > 1:
		var names: Array[String] = []
		for chapter: String in chapters: names.append(CurrentMarines.chapter_name(chapter))
		chapter_status.text = "Chapter conflict · %s. Remove entries until one Chapter remains; other Chapter-specific choices are hidden." % " and ".join(names)
		chapter_status.add_theme_color_override("font_color", Color("f0b46a"))
	elif chapters.size() == 1:
		chapter_status.text = "Chapter · %s. Other Chapter-specific choices are hidden; generic Adeptus Astartes units remain available." % CurrentMarines.chapter_name(str(chapters[0]))
		chapter_status.add_theme_color_override("font_color", Color("c4ced1"))
	else:
		chapter_status.text = "Chapter · None selected. Current profiles from any Chapter remain available."
		chapter_status.add_theme_color_override("font_color", Color("c4ced1"))
	if bool(chapter_state.get("outside_catalog", false)):
		chapter_status.text += " Some draft entries are outside the current local catalog; this preview is partial."
		chapter_status.add_theme_color_override("font_color", Color("f0b46a"))

func _select_unit(index: int) -> void:
	selected_unit = unit_picker.get_item_metadata(index)
	var current := Training.Capabilities.current_catalog_choice(selected_unit)
	if not current.is_empty(): selected_unit = current
	_refresh_construction_scope_hint()
	choice_picker.clear()
	for option: Dictionary in selected_unit.options:
		var origin := "Wahapedia e11" if not current.is_empty() else "local"
		var price_text := "%d pts" % option.cost if option.cost != null else "cost unconfirmed"
		if option.has("second_plus_cost") and option.cost != null and int(option.second_plus_cost) != int(option.cost): price_text += " · 2nd+ %d pts" % int(option.second_plus_cost)
		if option.has("third_plus_cost") and option.cost != null and int(option.third_plus_cost) != int(option.get("second_plus_cost", option.cost)): price_text += " · 3rd+ %d pts" % int(option.third_plus_cost)
		if option.has("fourth_plus_cost") and option.cost != null and int(option.fourth_plus_cost) != int(option.get("third_plus_cost", option.cost)): price_text += " · 4th+ %d pts" % int(option.fourth_plus_cost)
		choice_picker.add_item(("%s (%s)" % [_model_count_label(int(option.models)), origin] if option.models > 0 else "Composition not provided") + " • " + price_text)
	add_button.disabled = false
	_refresh_composition_options()

func _refresh_construction_scope_hint() -> void:
	if construction_scope_hint == null: return
	var scope := str(selected_unit.get("construction_scope", ""))
	construction_scope_hint.text = scope
	construction_scope_hint.visible = not scope.is_empty()

func _add() -> void:
	_sync()
	if selected_unit.is_empty() or choice_picker.selected < 0: return
	var allowed: Dictionary = source.lookup(str(selected_unit.id))
	if allowed.is_empty():
		notice.text = "This datasheet is outside the consolidated local catalog. Reload the local catalog."
		return
	var current := Training.Capabilities.current_catalog_choice(allowed)
	if not current.is_empty(): allowed = current
	if draft.faction == "Space Marines":
		var current_chapters: Array = _draft_chapter_state().chapters
		var added_chapters := CurrentMarines.chapter_keywords(str(allowed.get("source_id", "")))
		if added_chapters.size() > 1:
			notice.text = "This current profile has conflicting Chapter keywords and cannot be added."
			return
		if not added_chapters.is_empty() and not current_chapters.is_empty():
			if current_chapters.size() > 1:
				notice.text = "Resolve the existing Chapter conflict before adding another Chapter-specific unit."
				return
			if added_chapters[0] != current_chapters[0]:
				notice.text = "This list is set to %s. Remove its Chapter-specific units before adding %s." % [CurrentMarines.chapter_name(str(current_chapters[0])), CurrentMarines.chapter_name(added_chapters[0])]
				return
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
	var selected_composition: Dictionary = composition_picker.get_item_metadata(composition_picker.selected) if composition_picker.visible and composition_picker.selected >= 0 else {}
	draft.entries.append(Roster.entry(allowed, option_index, int(copies.value), selected_composition))
	selected_entry_index = draft.entries.size() - 1
	if draft.catalog_digest.is_empty(): draft.catalog_digest = source.catalog.digest
	dirty = true
	_render_draft()
	if editor_tabs != null: editor_tabs.current_tab = 0
	notice.text = "Added %s. Choose appearance or add another unit." % str(draft.entries[selected_entry_index].name)
	if automatic_appearance_toggle.button_pressed and model_imports != null:
		var added: Dictionary = draft.entries[selected_entry_index]
		pending_appearance_units[str(added.unit_id)] = true
		call_deferred("_prepare_added_units")

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
		notice.text = "Current reference construction is available only for the local Space Marine catalog."
		return
	if draft.faction != "Space Marines":
		notice.text = "Current Necron profiles are not in the local construction catalog. Existing Necron lists remain legacy drafts."
		return
	var result := Training.Capabilities.reference_army(draft.faction)
	if not result.error.is_empty():
		notice.text = result.error
		return
	draft = result.list
	draft.id = ""
	dirty = true
	_render_draft()
	notice.text = "Space Marine reference created from the local Wahapedia profile catalog. This composition is not a complete army legality claim; save a copy to your profile."
