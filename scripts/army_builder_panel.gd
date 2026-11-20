extends VBoxContainer
const SavedEquipment = preload("res://scripts/edition_11/saved_equipment_profiles.gd")
const WorkspaceTheme = preload("res://scripts/ui/workspace_theme.gd")
const Roster = preload("res://scripts/army_roster.gd")
const Profiles = preload("res://scripts/army_profiles.gd")
const Catalog = preload("res://scripts/implemented_army_catalog.gd")
const Training = preload("res://scripts/edition_11/training_roster.gd")
const CurrentMarines = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const CurrentNecrons = preload("res://scripts/edition_11/current_reference_necron_profiles.gd")
const CanoptekMacrocytes = preload("res://scripts/edition_11/canoptek_macrocytes.gd")
const CanoptekSpyders = preload("res://scripts/edition_11/canoptek_spyders.gd")
const CanoptekTombCrawlers = preload("res://scripts/edition_11/canoptek_tomb_crawlers.gd")
const NecronVehicleLoadouts = preload("res://scripts/edition_11/necron_vehicle_loadouts.gd")
const ForceOrgMatcher = preload("res://scripts/forceorg_matcher.gd")
const ArmyLegalityPresenter = preload("res://scripts/ui/army_legality_presenter.gd")
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
var legality_status: Label
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
var appearance_workspace: HBoxContainer
var appearance_preview_column: VBoxContainer
var appearance_gallery_column: VBoxContainer
var selected_saved_id := ""
var overview: VBoxContainer
var model_imports
var selected_entry_index := -1
var entry_models_input: SpinBox
var entry_copies_input: SpinBox
var enhancement_picker: OptionButton
var visual_copy_picker: OptionButton
var visual_models: VBoxContainer
var visual_header: Label
var visual_notice: Label
var visual_download_button: Button
var visual_gallery_grid: GridContainer
var visual_gallery_scroll: ScrollContainer
var visual_gallery_search: LineEdit
var visual_gallery_ready_only: CheckBox
var visual_gallery_detail: Label
var visual_gallery_unit_target: Button
var visual_gallery_model_target: Button
var visual_gallery_apply_similar_button: Button
var visual_gallery_buttons: Array[Button] = []
var visual_gallery_variants: Array = []
var visual_gallery_context: Dictionary = {}
var visual_gallery_target := 0
var visual_gallery_ready_only_preference := false
var sergeant_loadout_copy_picker: OptionButton
var sergeant_rifle_picker: OptionButton
var sergeant_melee_picker: OptionButton
var sergeant_loadout_heading: Label
var per_model_equipment_controls: VBoxContainer
var warlord_picker: OptionButton
var warlord_status: Label
var leader_source_picker: OptionButton
var leader_target_picker: OptionButton
var leader_assignment_button: Button
var leader_assignment_view: ItemList
var leader_remove_button: Button
var leader_assignment_status: Label
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
const ELIMINATOR_SERGEANT_OPTIONS := [
	{"id": "sniper", "label": "Bolt Sniper Rifle"},
	{"id": "las", "label": "Las Fusil"},
	{"id": "carbine", "label": "Instigator Bolt Carbine"}
]
const ELIMINATOR_TROOPER_OPTIONS := [
	{"id": "sniper", "label": "Bolt Sniper Rifle"},
	{"id": "las", "label": "Las Fusil"}
]
const NECRON_WARRIOR_OPTIONS := [
	{"id": "gauss-flayer", "label": "Gauss flayer"},
	{"id": "gauss-reaper", "label": "Gauss reaper"}
]
const IMMORTAL_OPTIONS := [
	{"id": "gauss-blaster", "label": "Gauss blaster"},
	{"id": "tesla-carbine", "label": "Tesla carbine"}
]
const CANOPTEK_MACROCYTE_OPTIONS := [
	{"id": "gauss-scalpel", "label": "Gauss scalpel"},
	{"id": "tesla-caster", "label": "Tesla caster"},
	{"id": "atomiser-beam-projector", "label": "Atomiser beam + Nanoscarab Projector"},
	{"id": "accelerator-mandible", "label": "Accelerator Mandible"}
]
const CANOPTEK_TOMB_CRAWLER_OPTIONS := [
	{"id": "twin-gauss-reaper", "label": "Twin gauss reaper"},
	{"id": "transdimensional-isolator", "label": "Transdimensional isolator"}
]
const NECRON_ANNIHILATION_BARGE_OPTIONS := [
	{"id": "gauss-cannon", "label": "Gauss cannon"},
	{"id": "tesla-cannon", "label": "Tesla cannon"}
]
const NECRON_MONOLITH_OPTIONS := [
	{"id": "gauss-flux-arcs", "label": "Four Gauss Flux Arcs"},
	{"id": "death-rays", "label": "Four Death Rays"}
]
const BAAL_PREDATOR_PRIMARY_OPTIONS := [
	{"id": "twin-assault-cannon", "label": "Twin Assault Cannon"},
	{"id": "baal-flamestorm-cannon", "label": "Baal Flamestorm Cannon"}
]
const BAAL_PREDATOR_SPONSON_OPTIONS := [
	{"id": "none", "label": "No sponson weapons"},
	{"id": "heavy-bolters", "label": "Two Heavy Bolters"},
	{"id": "heavy-flamers", "label": "Two Heavy Flamers"}
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
	legality_status = label("")
	legality_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
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
	sergeant_loadout_heading = label("MODEL EQUIPMENT")
	sergeant_loadout_heading.visible = false
	var sergeant_copy_row := row()
	sergeant_loadout_copy_picker = OptionButton.new()
	sergeant_loadout_copy_picker.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sergeant_loadout_copy_picker.tooltip_text = "Set saved equipment for one unit copy. Saved-list matches use these choices for the whole match; edit the list before starting another match."
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
	per_model_equipment_controls = VBoxContainer.new()
	per_model_equipment_controls.visible = false
	editor.add_child(per_model_equipment_controls)
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
	visual_header = label("MINIATURE APPEARANCE")
	visual_header.add_theme_font_size_override("font_size", 15)
	visual_header.add_theme_color_override("font_color", Color("d7b96d"))
	visual_notice = label("Each unit shares one appearance by default. Use a model override only for a distinct role or loadout sculpt.")
	var visual_controls := row()
	visual_copy_picker = OptionButton.new()
	visual_copy_picker.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	visual_controls.add_child(visual_copy_picker)
	visual_copy_picker.item_selected.connect(func(_index: int):
		if selected_entry_index >= 0 and selected_entry_index < draft.entries.size():
			var item: Dictionary = draft.entries[selected_entry_index]
			var models := maxi(1, int(item.get("models", 1)))
			var copy_index := int(visual_copy_picker.get_item_metadata(visual_copy_picker.selected))
			var model_index := posmod(preview_slot, models)
			_preview_entry(item, copy_index * models + model_index)
		_render_visual_slots()
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
	visual_models = VBoxContainer.new()
	visual_models.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	editor.add_child(visual_models)
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
	preview_model_input.prefix = "Model "
	preview_model_input.min_value = 1
	preview_model_input.max_value = 1
	preview_model_input.step = 1
	preview_model_input.tooltip_text = "Choose a miniature in the selected unit copy. Preview only; does not change equipment, appearances or points."
	inspector_region.add_child(preview_model_input)
	preview_model_input.value_changed.connect(func(value: float):
		if preview_entry.is_empty(): return
		var models := maxi(1, int(preview_entry.get("models", 1)))
		var copy_index := 0
		if visual_copy_picker != null and visual_copy_picker.selected >= 0:
			copy_index = int(visual_copy_picker.get_item_metadata(visual_copy_picker.selected))
		_preview_entry(preview_entry, copy_index * models + int(value) - 1)
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
	var formation_heading := label("BATTLE FORMATION", pages["Army"])
	formation_heading.add_theme_font_size_override("font_size", 14)
	formation_heading.add_theme_color_override("font_color", Color("d7b96d"))
	label("Warlord candidate", pages["Army"])
	warlord_picker = OptionButton.new()
	warlord_picker.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	warlord_picker.tooltip_text = "Save a Warlord choice with this army. Match preparation rechecks it against the selected rules and any mandatory Warlord requirements."
	pages["Army"].add_child(warlord_picker)
	warlord_picker.item_selected.connect(_set_saved_warlord)
	warlord_status = label("No saved choice · choose during Battle Readiness.", pages["Army"])
	warlord_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label("LEADER / SUPPORT ASSIGNMENTS", pages["Army"])
	leader_source_picker = OptionButton.new()
	leader_source_picker.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	leader_source_picker.tooltip_text = "Choose a Character or Support miniature from this saved army. Match rules recheck the assignment before launch."
	pages["Army"].add_child(leader_source_picker)
	leader_source_picker.item_selected.connect(func(_index: int): _render_saved_leader_controls())
	leader_target_picker = OptionButton.new()
	leader_target_picker.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	leader_target_picker.tooltip_text = "Choose a bodyguard unit copy. Eligibility is checked by the active match rules before launch."
	pages["Army"].add_child(leader_target_picker)
	leader_assignment_button = Button.new()
	leader_assignment_button.text = "Save attachment candidate"
	leader_assignment_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	pages["Army"].add_child(leader_assignment_button)
	leader_assignment_button.pressed.connect(_save_leader_assignment)
	leader_assignment_view = ItemList.new()
	leader_assignment_view.custom_minimum_size.y = 70
	leader_assignment_view.select_mode = ItemList.SELECT_SINGLE
	leader_assignment_view.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	pages["Army"].add_child(leader_assignment_view)
	leader_remove_button = Button.new()
	leader_remove_button.text = "Remove selected assignment"
	leader_remove_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	pages["Army"].add_child(leader_remove_button)
	leader_remove_button.pressed.connect(_remove_leader_assignment)
	leader_assignment_status = label("Match rules verify each assignment.", pages["Army"])
	leader_assignment_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	appearance_workspace = HBoxContainer.new()
	appearance_workspace.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	appearance_workspace.size_flags_vertical = Control.SIZE_EXPAND_FILL
	appearance_workspace.add_theme_constant_override("separation", 14)
	pages["Appearance"].add_child(appearance_workspace)
	appearance_preview_column = VBoxContainer.new()
	appearance_preview_column.custom_minimum_size.x = 232
	appearance_preview_column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	appearance_preview_column.size_flags_vertical = Control.SIZE_EXPAND_FILL
	appearance_workspace.add_child(appearance_preview_column)
	appearance_gallery_column = VBoxContainer.new()
	appearance_gallery_column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	appearance_gallery_column.size_flags_vertical = Control.SIZE_EXPAND_FILL
	appearance_workspace.add_child(appearance_gallery_column)
	var appearance_preview_heading := label("LIVE MINIATURE PREVIEW", appearance_preview_column)
	appearance_preview_heading.add_theme_font_size_override("font_size", 13)
	appearance_preview_heading.add_theme_color_override("font_color", Color("d7b96d"))
	miniature_preview.custom_minimum_size.x = 232
	miniature_preview.surface.custom_minimum_size.x = 232
	miniature_preview.reparent(appearance_preview_column)
	preview_model_input.reparent(appearance_preview_column)
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
	for control in [visual_header, visual_notice, visual_copy_picker, visual_models, visual_download_button, automatic_appearance_toggle, palette_button, palette_notice, palette_prepare_button]:
		if control != null: control.reparent(appearance_gallery_column)
	visual_header.text = "LOCAL APPEARANCE"
	visual_header.visible = true
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
	import_button = button("Advanced model import…", func(): import_requested.emit(), appearance_gallery_column)
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
	_render_saved_warlord_control()
	_render_saved_leader_controls()
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
	# The Appearance page needs room for a live preview and the two-column local
	# gallery. Collapse the outer three-column workshop before their minimum
	# widths force the inspector off-screen on common 1280px displays.
	var compact := size.x < 1560
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
	var model_count := maxi(1, int(item.get("models", 0)))
	var total := mini(20000, int(item.get("models", 0)) * int(item.get("copies", 0)))
	slot = clampi(slot, 0, maxi(0, total - 1))
	preview_slot = slot
	var selected_copy_index := floori(float(slot) / float(model_count))
	if visual_copy_picker != null and selected_copy_index >= 0 and selected_copy_index < visual_copy_picker.item_count:
		visual_copy_picker.select(selected_copy_index)
	if preview_model_input != null:
		preview_model_input.set_block_signals(true)
		preview_model_input.max_value = model_count
		preview_model_input.value = posmod(slot, model_count) + 1
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
		var palette_choice := Roster.palette_variant(draft, str(item.get("unit_id", "")), appearance_index)
		var appearance_choice := unit_choice if not unit_choice.is_empty() else palette_choice
		var source_family: String = model_imports.visual_family_for(appearance_choice, str(item.get("unit_id", "")), appearance_index, appearance_choice.is_empty())
		var role_choice := ""
		var role_variant := ""
		if str(item.get("unit_id", "")).ends_with(":intercessor-squad") and model_index == 0:
			var loadout := Roster.intercessor_sergeant_loadout(item, copy_index)
			var role_unit := {"definition_id": str(item.unit_id), "sergeant": true, "intercessor_rifle_choice": str(loadout.rifle_choice), "intercessor_melee_choice": str(loadout.melee_choice)}
			role_choice = ForceOrgMatcher.intercessor_sergeant_visual_role(role_unit)
			role_variant = model_imports.visual_role_variant_for(role_choice, source_family, appearance_choice.is_empty())
			role_variant_missing = role_choice != ForceOrgMatcher.INTERCESSOR_SERGEANT_DEFAULT_ROLE and role_variant.is_empty()
			role_loadout_fallback = role_choice == ForceOrgMatcher.INTERCESSOR_SERGEANT_DEFAULT_ROLE and (str(loadout.rifle_choice) != "bolt-rifle" or str(loadout.melee_choice) != "knives-and-fists")
		elif str(item.get("unit_id", "")).ends_with(":hellblaster-squad") and model_index == 0:
			var pistol_choice := str(Roster.model_equipment(item, copy_index, model_index).get("hellblaster_sergeant_pistol", "bolt-pistol"))
			var hellblaster_profile := CurrentMarines.profile("hellblaster-squad")
			var ranged_weapons: Array = hellblaster_profile.get("ranged", []).duplicate(true)
			if ranged_weapons.size() == 2: ranged_weapons[1] = CurrentMarines.hellblaster_pistol(pistol_choice == "plasma-pistol")
			var role_unit := {"definition_id": str(item.unit_id), "sergeant": true, "ranged_weapons": ranged_weapons, "melee_weapons": hellblaster_profile.get("melee", []).duplicate(true)}
			role_variant = model_imports.equipment_variant_for(role_unit, source_family)
			role_variant_missing = pistol_choice == "plasma-pistol" and role_variant.is_empty()
			role_loadout_fallback = role_variant_missing
		elif str(item.get("unit_id", "")).ends_with(":eliminator-squad"):
			var equipment := Roster.model_equipment(item, copy_index, model_index)
			var choice_id := str(equipment.get("eliminator_sergeant_ranged", "sniper")) if model_index == 0 else str(equipment.get("eliminator_trooper_ranged", "sniper"))
			var role_unit := {"definition_id": str(item.unit_id), "sergeant": model_index == 0, "ranged_weapons": [CurrentMarines.eliminator_gun(choice_id)], "melee_weapons": []}
			role_variant = model_imports.equipment_variant_for(role_unit, source_family)
			role_variant_missing = choice_id != "sniper" and role_variant.is_empty()
			role_loadout_fallback = choice_id != "sniper" and role_variant.is_empty()
		elif str(item.get("unit_id", "")).ends_with(":outrider-squad"):
			var equipment := Roster.model_equipment(item, copy_index, model_index)
			var plasma_pistol := bool(equipment.get("outrider_plasma_pistol", false))
			var melee_choice := str(equipment.get("outrider_sergeant_melee", "chainsword")) if model_index == 0 else "chainsword"
			var weapons := CurrentMarines.outrider_weapons(plasma_pistol, melee_choice)
			if not weapons.is_empty():
				var role_unit := {"definition_id": str(item.unit_id), "sergeant": model_index == 0, "ranged_weapons": weapons.ranged, "melee_weapons": weapons.melee}
				role_variant = model_imports.equipment_variant_for(role_unit, source_family)
			var customized := plasma_pistol or melee_choice != "chainsword"
			role_variant_missing = customized and role_variant.is_empty()
			role_loadout_fallback = role_variant_missing
		elif str(item.get("unit_id", "")).ends_with(":ravenwing-darkshroud"):
			var cannon_choice := str(Roster.model_equipment(item, copy_index, model_index).get("ravenwing_darkshroud_cannon", "heavy-bolter"))
			var darkshroud_profile := CurrentMarines.profile("ravenwing-darkshroud")
			var ranged_weapons: Array = darkshroud_profile.get("ranged", []).duplicate(true)
			if cannon_choice == "assault-cannon":
				ranged_weapons = ranged_weapons.filter(func(weapon: Dictionary) -> bool: return str(weapon.get("id", "")) != "heavy-bolter")
				var additional_ranged: Array = darkshroud_profile.get("additional_weapon_profiles", {}).get("ranged", [])
				if not additional_ranged.is_empty(): ranged_weapons.append(additional_ranged[0].duplicate(true))
			var role_unit := {"definition_id": str(item.unit_id), "model_role": "ravenwing-darkshroud", "ranged_weapons": ranged_weapons, "melee_weapons": darkshroud_profile.get("melee", []).duplicate(true)}
			role_variant = model_imports.equipment_variant_for(role_unit, source_family)
			role_variant_missing = cannon_choice != "heavy-bolter" and role_variant.is_empty()
			role_loadout_fallback = role_variant_missing
		elif str(item.get("unit_id", "")).ends_with(":land-speeder"):
			var cannon_choice := str(Roster.model_equipment(item, copy_index, model_index).get("land_speeder_cannon", "onslaught"))
			var land_speeder_profile := CurrentMarines.profile("land-speeder")
			var ranged_weapons: Array = land_speeder_profile.get("ranged", []).duplicate(true)
			if cannon_choice == "pyrecannon":
				ranged_weapons = ranged_weapons.filter(func(weapon: Dictionary) -> bool: return str(weapon.get("id", "")) != "onslaught-gatling-cannon")
				var additional_ranged: Array = land_speeder_profile.get("additional_weapon_profiles", {}).get("ranged", [])
				if additional_ranged.size() == 1: ranged_weapons.append(additional_ranged[0].duplicate(true))
			var role_unit := {"definition_id": str(item.unit_id), "model_role": "land-speeder", "ranged_weapons": ranged_weapons, "melee_weapons": land_speeder_profile.get("melee", []).duplicate(true)}
			role_variant = model_imports.equipment_variant_for(role_unit, source_family)
			role_variant_missing = cannon_choice == "pyrecannon" and role_variant.is_empty()
			role_loadout_fallback = role_variant_missing
		elif SavedEquipment.supports(str(item.get("unit_id", ""))):
			var role_unit := {"definition_id": str(item.unit_id), "melee_weapons": CurrentMarines.profile(str(item.unit_id).get_slice(":", 3)).get("melee", []).duplicate(true)}
			SavedEquipment.prepare(role_unit, str(item.unit_id), Roster.model_equipment(item, copy_index, model_index), int(item.models), model_index)
			role_variant = model_imports.equipment_variant_for(role_unit, source_family)
			role_variant_missing = role_variant.is_empty()
			role_loadout_fallback = role_variant_missing
		elif str(item.get("unit_id", "")).ends_with(":land-speeder-vengeance"):
			var cannon_choice := str(Roster.model_equipment(item, copy_index, model_index).get("land_speeder_vengeance_cannon", "heavy-bolter"))
			var vengeance_profile := CurrentMarines.profile("land-speeder-vengeance")
			var ranged_weapons: Array = vengeance_profile.get("ranged", []).duplicate(true)
			if cannon_choice == "assault-cannon":
				ranged_weapons = ranged_weapons.filter(func(weapon: Dictionary) -> bool: return str(weapon.get("id", "")) != "heavy-bolter")
				var additional_ranged: Array = vengeance_profile.get("additional_weapon_profiles", {}).get("ranged", [])
				if additional_ranged.size() == 1: ranged_weapons.append(additional_ranged[0].duplicate(true))
			var role_unit := {"definition_id": str(item.unit_id), "model_role": "land-speeder-vengeance", "ranged_weapons": ranged_weapons, "melee_weapons": vengeance_profile.get("melee", []).duplicate(true)}
			role_variant = model_imports.equipment_variant_for(role_unit, source_family)
			role_variant_missing = cannon_choice == "assault-cannon" and role_variant.is_empty()
			role_loadout_fallback = role_variant_missing
		elif str(item.get("unit_id", "")).ends_with(":baal-predator"):
			var baal_equipment := Roster.model_equipment(item, copy_index, model_index)
			var primary := str(baal_equipment.get("baal_predator_primary_cannon", "twin-assault-cannon"))
			var sponsons := str(baal_equipment.get("baal_predator_sponson_package", "none"))
			var storm_bolter := bool(baal_equipment.get("baal_predator_storm_bolter", false))
			var missile := bool(baal_equipment.get("baal_predator_hunter_killer_missile", false))
			var baal_profile := CurrentMarines.profile("baal-predator")
			var baal_ranged := CurrentMarines.baal_predator_weapons(primary, sponsons, storm_bolter, missile)
			if not baal_ranged.is_empty():
				var role_unit := {"definition_id": str(item.unit_id), "model_role": "baal-predator", "ranged_weapons": baal_ranged, "melee_weapons": baal_profile.get("melee", []).duplicate(true)}
				role_variant = model_imports.equipment_variant_for(role_unit, source_family)
			var customized := primary != "twin-assault-cannon" or sponsons != "none" or storm_bolter or missile
			role_variant_missing = customized and role_variant.is_empty()
			role_loadout_fallback = role_variant_missing
		elif str(item.get("unit_id", "")).ends_with(":predator-destructor"):
			var equipment := Roster.model_equipment(item, copy_index, model_index)
			var heavy_bolters := bool(equipment.get("predator_destructor_heavy_bolters", false))
			var missile := bool(equipment.get("predator_destructor_hunter_killer_missile", false))
			var storm_bolter := bool(equipment.get("predator_destructor_storm_bolter", false))
			var profile := CurrentMarines.profile("predator-destructor")
			var weapons := CurrentMarines.predator_destructor_weapons(heavy_bolters, missile, storm_bolter)
			if not weapons.is_empty():
				var role_unit := {"definition_id": str(item.unit_id), "model_role": "predator-destructor", "ranged_weapons": weapons.ranged, "melee_weapons": weapons.melee}
				role_variant = model_imports.equipment_variant_for(role_unit, source_family)
			var customized := heavy_bolters or missile or storm_bolter
			role_variant_missing = customized and role_variant.is_empty()
			role_loadout_fallback = role_variant_missing
		elif str(item.get("unit_id", "")).ends_with(":predator-destructor"):
			var destructor_equipment := Roster.model_equipment(item, copy_index, model_index)
			var destructor_heavy_bolters := bool(destructor_equipment.get("predator_destructor_heavy_bolters", false))
			var destructor_missile := bool(destructor_equipment.get("predator_destructor_hunter_killer_missile", false))
			var destructor_storm_bolter := bool(destructor_equipment.get("predator_destructor_storm_bolter", false))
			var destructor_profile := CurrentMarines.profile("predator-destructor")
			var destructor_weapons := CurrentMarines.predator_destructor_weapons(destructor_heavy_bolters, destructor_missile, destructor_storm_bolter)
			if not destructor_weapons.is_empty():
				var role_unit := {"definition_id": str(item.unit_id), "model_role": "predator-destructor", "ranged_weapons": destructor_weapons.ranged, "melee_weapons": destructor_weapons.melee}
				role_variant = model_imports.equipment_variant_for(role_unit, source_family)
			var customized := destructor_heavy_bolters or destructor_missile or destructor_storm_bolter
			role_variant_missing = customized and role_variant.is_empty()
			role_loadout_fallback = role_variant_missing
		elif str(item.get("unit_id", "")).ends_with(":predator-annihilator"):
			var equipment := Roster.model_equipment(item, copy_index, model_index)
			var heavy_bolters := bool(equipment.get("predator_annihilator_heavy_bolters", false))
			var missile := bool(equipment.get("predator_annihilator_hunter_killer_missile", false))
			var storm_bolter := bool(equipment.get("predator_annihilator_storm_bolter", false))
			var annihilator_profile := CurrentMarines.profile("predator-annihilator")
			var annihilator_weapons := CurrentMarines.predator_annihilator_weapons(heavy_bolters, missile, storm_bolter)
			if not annihilator_weapons.is_empty():
				var role_unit := {"definition_id": str(item.unit_id), "model_role": "predator-annihilator", "ranged_weapons": annihilator_weapons.ranged, "melee_weapons": annihilator_weapons.melee}
				role_variant = model_imports.equipment_variant_for(role_unit, source_family)
			var customized := heavy_bolters or missile or storm_bolter
			role_variant_missing = customized and role_variant.is_empty()
			role_loadout_fallback = role_variant_missing
		elif str(item.get("unit_id", "")).ends_with(":inceptor-squad"):
			var weapon_choice := str(Roster.model_equipment(item, copy_index, model_index).get("inceptor_weapon", "assault-bolters"))
			var inceptor_profile := CurrentMarines.profile("inceptor-squad")
			var ranged_options: Array = inceptor_profile.get("ranged", []) if weapon_choice == "assault-bolters" else inceptor_profile.get("additional_weapon_profiles", {}).get("ranged", [])
			if ranged_options.size() == 1:
				var role_unit := {"definition_id": str(item.unit_id), "sergeant": model_index == 0, "ranged_weapons": [ranged_options[0].duplicate(true)], "melee_weapons": inceptor_profile.get("melee", []).duplicate(true)}
				role_variant = model_imports.equipment_variant_for(role_unit, source_family)
			role_variant_missing = weapon_choice == "plasma-exterminators" and (ranged_options.size() != 1 or role_variant.is_empty())
			role_loadout_fallback = role_variant_missing
		elif str(item.get("unit_id", "")).ends_with(":invader-atvs"):
			var multi_melta := bool(Roster.model_equipment(item, copy_index, model_index).get("invader_atv_multi_melta", false))
			var atv_weapons := CurrentMarines.invader_atv_weapons(multi_melta)
			var role_unit := {"definition_id": str(item.unit_id), "model_role": "invader-atv", "ranged_weapons": atv_weapons, "melee_weapons": []}
			role_variant = model_imports.equipment_variant_for(role_unit, source_family)
			role_variant_missing = multi_melta and role_variant.is_empty()
			role_loadout_fallback = role_variant_missing
		elif str(item.get("unit_id", "")).ends_with(":scout-squad"):
			var equipment := Roster.model_equipment(item, copy_index, model_index)
			var scout_gun := str(equipment.get("scout_gun", "boltgun"))
			var scout_blade := str(equipment.get("scout_sergeant_blade", "combat-knife")) if model_index == 0 else "combat-knife"
			var scout_ranged := CurrentMarines.scout_ranged(scout_gun)
			var scout_melee := CurrentMarines.scout_melee(scout_blade)
			var role_unit := {"definition_id": str(item.unit_id), "model_role": "scout-sergeant" if model_index == 0 else "scout", "sergeant": model_index == 0, "ranged_weapons": scout_ranged, "melee_weapons": scout_melee}
			role_variant = model_imports.equipment_variant_for(role_unit, source_family)
			var customized := scout_gun != "boltgun" or (model_index == 0 and scout_blade != "combat-knife")
			role_variant_missing = customized and role_variant.is_empty()
			role_loadout_fallback = role_variant_missing
		elif str(item.get("unit_id", "")).ends_with(":necron-warriors") or str(item.get("unit_id", "")).ends_with(":immortals"):
			var is_warrior := str(item.unit_id).ends_with(":necron-warriors")
			var source := "necron-warriors" if is_warrior else "immortals"
			var equipment := Roster.model_equipment(item, copy_index, model_index)
			var default_weapon := "gauss-flayer" if is_warrior else "gauss-blaster"
			var choice_id := str(equipment.get("necron_ranged_weapon", default_weapon))
			var weapon := _necron_visual_weapon(source, choice_id)
			if not weapon.is_empty():
				var role_id := "necron-warrior" if is_warrior else "immortal"
				var role_unit := {"definition_id": str(item.unit_id), "model_role": role_id, "ranged_weapons": [weapon], "melee_weapons": []}
				role_variant = model_imports.equipment_variant_for(role_unit, source_family)
			role_variant_missing = choice_id != default_weapon and role_variant.is_empty()
			role_loadout_fallback = role_variant_missing
		elif str(item.get("unit_id", "")).ends_with(":canoptek-macrocytes"):
			var loadout := str(Roster.model_equipment(item, copy_index, model_index).get("canoptek_macrocytes_loadout", CanoptekMacrocytes.GAUSS_SCALPEL))
			var weapons := CanoptekMacrocytes.weapons(loadout)
			if not weapons.is_empty():
				var role_unit := {"definition_id": str(item.unit_id), "model_role": "canoptek-macrocyte", "ranged_weapons": weapons.ranged, "melee_weapons": weapons.melee}
				role_variant = model_imports.equipment_variant_for(role_unit, source_family)
			role_variant_missing = loadout != CanoptekMacrocytes.GAUSS_SCALPEL and role_variant.is_empty()
			role_loadout_fallback = role_variant_missing
		elif str(item.get("unit_id", "")).ends_with(":canoptek-spyders"):
			var equipment := Roster.model_equipment(item, copy_index, model_index)
			var weapons := CanoptekSpyders.weapon_inventory(equipment)
			if not weapons.is_empty():
				var role_unit := {"definition_id": str(item.unit_id), "model_role": "canoptek-spyder", "ranged_weapons": weapons.ranged, "melee_weapons": weapons.melee}
				role_variant = model_imports.equipment_variant_for(role_unit, source_family)
			var customized := false
			for field: String in CanoptekSpyders.EQUIPMENT_FIELDS:
				customized = customized or bool(equipment.get(field, false))
			role_variant_missing = customized and role_variant.is_empty()
			role_loadout_fallback = role_variant_missing
		elif str(item.get("unit_id", "")).ends_with(":canoptek-tomb-crawlers"):
			var loadout := str(Roster.model_equipment(item, copy_index, model_index).get("canoptek_tomb_crawlers_loadout", CanoptekTombCrawlers.GAUSS_REAPER))
			var weapons := CanoptekTombCrawlers.weapons(loadout)
			if not weapons.is_empty():
				var role_unit := {"definition_id": str(item.unit_id), "model_role": "canoptek-tomb-crawler", "ranged_weapons": weapons.ranged, "melee_weapons": weapons.melee}
				role_variant = model_imports.equipment_variant_for(role_unit, source_family)
			role_variant_missing = loadout == CanoptekTombCrawlers.ISOLATOR and role_variant.is_empty()
			role_loadout_fallback = role_variant_missing
		elif str(item.get("unit_id", "")).ends_with(":" + NecronVehicleLoadouts.ANNIHILATION_BARGE) or str(item.get("unit_id", "")).ends_with(":" + NecronVehicleLoadouts.MONOLITH):
			var definition_id := str(item.unit_id)
			var vehicle_loadouts := Roster.model_equipment(item, copy_index, model_index)
			var vehicle_choice := str(vehicle_loadouts.get("necron_annihilation_barge_loadout", NecronVehicleLoadouts.default_choice(definition_id))) if definition_id.ends_with(":" + NecronVehicleLoadouts.ANNIHILATION_BARGE) else str(vehicle_loadouts.get("necron_monolith_loadout", NecronVehicleLoadouts.default_choice(definition_id)))
			var profile_id := NecronVehicleLoadouts.ANNIHILATION_BARGE if definition_id.ends_with(":" + NecronVehicleLoadouts.ANNIHILATION_BARGE) else NecronVehicleLoadouts.MONOLITH
			var source_profile := CurrentNecrons.profile(profile_id)
			var ranged := NecronVehicleLoadouts.ranged_weapons(definition_id, vehicle_choice, source_profile)
			if not ranged.is_empty():
				var role_unit := {"definition_id": definition_id, "model_role": profile_id, "ranged_weapons": ranged, "melee_weapons": source_profile.get("melee", []).duplicate(true)}
				role_variant = model_imports.equipment_variant_for(role_unit, source_family)
			role_variant_missing = vehicle_choice != NecronVehicleLoadouts.default_choice(definition_id) and role_variant.is_empty()
			role_loadout_fallback = role_variant_missing
		var candidates: Array[String] = []
		if not model_override.is_empty(): candidates.append(model_override)
		elif not role_variant.is_empty(): candidates.append(role_variant)
		for identity: String in [unit_choice, palette_choice]:
			if not identity.is_empty() and identity not in candidates: candidates.append(identity)
		var explicit_choice := not model_override.is_empty() or not unit_choice.is_empty()
		for identity: String in candidates:
			visual = await model_imports.preview_variant_for_async(identity, current)
			if visual != null: break
		if visual == null and not role_variant.is_empty(): role_variant_missing = true
		missing_variant = (explicit_choice or not palette_choice.is_empty()) and visual == null
		if visual == null and candidates.is_empty() and model_imports.has_method("automatic_variant_for"):
			var automatic_choice: String = model_imports.automatic_variant_for(str(item.get("unit_id", "")), appearance_index, source_family)
			if not automatic_choice.is_empty(): visual = await model_imports.preview_variant_for_async(automatic_choice, current)
		if visual == null and item.has("unit_id") and model_override.is_empty() and unit_choice.is_empty() and palette_choice.is_empty():
			visual = await model_imports.preview_visual_for_async(str(item.unit_id), current)
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
		var role_copy_index := floori(float(slot) / float(maxi(1, int(item.models))))
		miniature_preview.caption.text += "\nUnit %d · %s" % [role_copy_index + 1, _visual_model_role_label(item, model_index, role_copy_index)]
		if str(item.get("unit_id", "")).ends_with(":intercessor-squad") and model_index == 0:
			var loadout := Roster.intercessor_sergeant_loadout(item, floori(float(slot) / float(maxi(1, int(item.models)))))
			miniature_preview.caption.text += "\nSergeant · %s + %s" % [str(Roster.INTERCESSOR_RIFLE_CHOICES[loadout.rifle_choice]), str(Roster.INTERCESSOR_MELEE_CHOICES[loadout.melee_choice])]
			if role_variant_missing: miniature_preview.caption.text += "\nMatching weapon sculpt prepares before a local match; fallback shown for now."
			elif role_loadout_fallback: miniature_preview.caption.text += "\nNo exact local sculpt for this combination; the default Sergeant sculpt will be used."
		elif str(item.get("unit_id", "")).ends_with(":eliminator-squad"):
			var copy_index := floori(float(slot) / float(maxi(1, int(item.models))))
			var model_equipment := Roster.model_equipment(item, copy_index, model_index)
			var choice_id := str(model_equipment.get("eliminator_sergeant_ranged", "sniper")) if model_index == 0 else str(model_equipment.get("eliminator_trooper_ranged", "sniper"))
			var weapon_label := str(Roster.ELIMINATOR_SERGEANT_WEAPONS.get(choice_id, "Bolt Sniper Rifle"))
			miniature_preview.caption.text += "\n%s · %s" % [_visual_model_role_label(item, model_index, copy_index), weapon_label]
			if role_loadout_fallback: miniature_preview.caption.text += "\nNo exact local weapon sculpt is ready; the default miniature remains visible."
		elif str(item.get("unit_id", "")).ends_with(":inceptor-squad"):
			if role_variant_missing: miniature_preview.caption.text += "\nNo exact Plasma Exterminator sculpt is ready; the selected appearance remains visible."
		elif str(item.get("unit_id", "")).ends_with(":invader-atvs"):
			var copy_index := floori(float(slot) / float(maxi(1, int(item.models))))
			var multi_melta := bool(Roster.model_equipment(item, copy_index, model_index).get("invader_atv_multi_melta", false))
			if role_variant_missing and multi_melta: miniature_preview.caption.text += "\nNo exact Multi-melta sculpt is ready; the selected appearance remains visible."
		elif str(item.get("unit_id", "")).ends_with(":scout-squad"):
			if role_loadout_fallback: miniature_preview.caption.text += "\nNo exact local loadout sculpt is linked; the selected equipment remains saved."
		elif str(item.get("unit_id", "")).ends_with(":necron-warriors") or str(item.get("unit_id", "")).ends_with(":immortals"):
			var copy_index := floori(float(slot) / float(maxi(1, int(item.models))))
			var equipment := Roster.model_equipment(item, copy_index, model_index)
			var is_warrior := str(item.get("unit_id", "")).ends_with(":necron-warriors")
			var default_weapon := "gauss-flayer" if is_warrior else "gauss-blaster"
			var choice_id := str(equipment.get("necron_ranged_weapon", default_weapon))
			var weapon_options := Roster.NECRON_WARRIOR_WEAPONS if is_warrior else Roster.IMMORTAL_WEAPONS
			miniature_preview.caption.text += "\n%s · %s" % [_visual_model_role_label(item, model_index, copy_index), str(weapon_options.get(choice_id, "Unresolved ranged weapon"))]
			if role_loadout_fallback: miniature_preview.caption.text += "\nNo exact local weapon sculpt is ready; the default miniature remains visible."
		elif str(item.get("unit_id", "")).ends_with(":canoptek-macrocytes"):
			var copy_index := floori(float(slot) / float(maxi(1, int(item.models))))
			var equipment := Roster.model_equipment(item, copy_index, model_index)
			var loadout := str(equipment.get("canoptek_macrocytes_loadout", CanoptekMacrocytes.GAUSS_SCALPEL))
			miniature_preview.caption.text += "\n%s · %s" % [_visual_model_role_label(item, model_index, copy_index), CanoptekMacrocytes.loadout_label(loadout)]
			if role_loadout_fallback: miniature_preview.caption.text += "\nNo exact local equipment sculpt is ready; the default miniature remains visible."
		elif str(item.get("unit_id", "")).ends_with(":canoptek-spyders"):
			var copy_index := floori(float(slot) / float(maxi(1, int(item.models))))
			var equipment := Roster.model_equipment(item, copy_index, model_index)
			var selected_options: Array[String] = []
			for option: String in CanoptekSpyders.OPTIONS:
				if bool(equipment.get(CanoptekSpyders.equipment_field(option), false)):
					selected_options.append(CanoptekSpyders.equipment_label(option))
			miniature_preview.caption.text += "\nCanoptek Spyder %d · %s" % [model_index + 1, ", ".join(selected_options) if not selected_options.is_empty() else "Automaton Claws"]
			if role_loadout_fallback: miniature_preview.caption.text += "\nNo exact local equipment sculpt is ready; the default miniature remains visible."
		elif str(item.get("unit_id", "")).ends_with(":canoptek-tomb-crawlers"):
			var copy_index := floori(float(slot) / float(maxi(1, int(item.models))))
			var loadout := str(Roster.model_equipment(item, copy_index, model_index).get("canoptek_tomb_crawlers_loadout", CanoptekTombCrawlers.GAUSS_REAPER))
			var loadout_name := "Twin gauss reaper" if loadout == CanoptekTombCrawlers.GAUSS_REAPER else "Transdimensional isolator"
			miniature_preview.caption.text += "\nCanoptek Tomb Crawler %d · %s" % [model_index + 1, loadout_name]
			if role_loadout_fallback: miniature_preview.caption.text += "\nNo exact local equipment sculpt is ready; the default miniature remains visible."
		elif str(item.get("unit_id", "")).ends_with(":" + NecronVehicleLoadouts.ANNIHILATION_BARGE) or str(item.get("unit_id", "")).ends_with(":" + NecronVehicleLoadouts.MONOLITH):
			var copy_index := floori(float(slot) / float(maxi(1, int(item.models))))
			var definition_id := str(item.unit_id)
			var equipment := Roster.model_equipment(item, copy_index, model_index)
			var field := "necron_annihilation_barge_loadout" if definition_id.ends_with(":" + NecronVehicleLoadouts.ANNIHILATION_BARGE) else "necron_monolith_loadout"
			var loadout := str(equipment.get(field, NecronVehicleLoadouts.default_choice(definition_id)))
			var unit_name := "Annihilation Barge" if definition_id.ends_with(":" + NecronVehicleLoadouts.ANNIHILATION_BARGE) else "Monolith"
			miniature_preview.caption.text += "\n%s · %s" % [unit_name, NecronVehicleLoadouts.choice_label(definition_id, loadout)]
			if role_loadout_fallback: miniature_preview.caption.text += "\nNo exact local weapon sculpt is ready; the default miniature remains visible."
	elif not item.is_empty(): miniature_preview.caption.text += "\nComposition pending · representative visual"
	if missing_variant: miniature_preview.caption.text += "\nAssigned variant unavailable · fallback shown"
	miniature_preview.caption.tooltip_text = miniature_preview.caption.text

func _necron_visual_weapon(source: String, weapon_id: String) -> Dictionary:
	var profile := CurrentNecrons.profile(source)
	for weapon: Variant in profile.get("ranged", []):
		if weapon is Dictionary and str(weapon.get("id", "")) == weapon_id: return weapon.duplicate(true)
	var alternatives: Variant = profile.get("additional_weapon_profiles", {}).get("ranged", [])
	if alternatives is Array:
		for weapon: Variant in alternatives:
			if weapon is Dictionary and str(weapon.get("id", "")) == weapon_id: return weapon.duplicate(true)
	return {}

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
	if editor.visible and editor_tabs.current_tab == 2 and appearance_preview_column != null:
		if miniature_preview.get_parent() != appearance_preview_column: miniature_preview.reparent(appearance_preview_column)
		appearance_preview_column.move_child(miniature_preview, 1)
		if preview_model_input.get_parent() != appearance_preview_column: preview_model_input.reparent(appearance_preview_column)
		appearance_preview_column.move_child(preview_model_input, 2)
	else:
		if miniature_preview.get_parent() != page: miniature_preview.reparent(page)
		page.move_child(miniature_preview, 0)
		if preview_model_input.get_parent() != page: preview_model_input.reparent(page)
		page.move_child(preview_model_input, 1)
	if editor.visible and editor_tabs.current_tab == 0 and unit_size_controls != null:
		page.move_child(unit_size_controls, 0)

func _open_entry_appearance() -> void:
	if not editor.visible or selected_entry_index < 0 or selected_entry_index >= draft.entries.size(): return
	reveal_appearance_when_ready = true
	if size.x < 1560:
		compact_navigation.select(2)
		_layout_workspace()
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
	Roster.normalize_formation_assignments(draft)

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
	if legality_status != null:
		var legality_view := ArmyLegalityPresenter.summarize_draft(draft, {"legality_mode": "casual_legends"})
		legality_status.text = str(legality_view.get("status_text", ""))
		legality_status.tooltip_text = str(legality_view.get("tooltip", ""))
		legality_status.add_theme_color_override("font_color", legality_view.get("status_color", Color("82d49c")))
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
	_render_saved_warlord_control()
	_render_saved_leader_controls()

func _render_saved_warlord_control() -> void:
	if warlord_picker == null: return
	updating = true
	warlord_picker.clear()
	warlord_picker.add_item("Choose during Battle Readiness")
	warlord_picker.set_item_metadata(0, "")
	var chosen := str(draft.get("warlord_model_id", ""))
	var selected_index := 0
	for item: Dictionary in draft.get("entries", []):
		var role_name := str(item.get("role", "")).to_lower()
		if "character" not in role_name and "personagem" not in role_name: continue
		var copy_ids := Roster.normalize_copy_instance_ids(item)
		for copy_index in range(int(item.get("copies", 0))):
			for model_index in range(int(item.get("models", 0))):
				var model_id := Roster.model_instance_id(item, copy_index, model_index)
				warlord_picker.add_item("%s · Unit %d · Model %d" % [str(item.get("name", "Character")), copy_index + 1, model_index + 1])
				var option_index := warlord_picker.item_count - 1
				warlord_picker.set_item_metadata(option_index, model_id)
				if model_id == chosen: selected_index = option_index
	warlord_picker.select(selected_index)
	warlord_picker.disabled = warlord_picker.item_count == 1
	updating = false
	if chosen.is_empty():
		warlord_status.text = "Choose in Battle Readiness."
	else:
		warlord_status.text = "Rules check eligibility before battle."

func _set_saved_warlord(index: int) -> void:
	if updating or warlord_picker == null or index < 0 or index >= warlord_picker.item_count: return
	var model_id := str(warlord_picker.get_item_metadata(index))
	if str(draft.get("warlord_model_id", "")) == model_id: return
	draft.warlord_model_id = model_id
	dirty = true
	save_error = ""
	_render_saved_warlord_control()
	_render_summary()

func _entry_can_be_attached(item: Dictionary) -> bool:
	var role := str(item.get("role", "")).to_lower()
	return "character" in role or "personagem" in role or "support" in role or "suporte" in role

func _render_saved_leader_controls() -> void:
	if leader_source_picker == null or leader_target_picker == null: return
	var chosen_source := str(leader_source_picker.get_item_metadata(leader_source_picker.selected)) if leader_source_picker.selected >= 0 else ""
	var chosen_target := str(leader_target_picker.get_item_metadata(leader_target_picker.selected)) if leader_target_picker.selected >= 0 else ""
	updating = true
	leader_source_picker.clear()
	leader_target_picker.clear()
	leader_source_picker.add_item("Choose a Character or Support")
	leader_source_picker.set_item_metadata(0, "")
	leader_target_picker.add_item("Choose a bodyguard unit")
	leader_target_picker.set_item_metadata(0, "")
	var source_items: Array[Dictionary] = []
	var targets: Array[Dictionary] = []
	for item: Dictionary in draft.get("entries", []):
		var copy_ids := Roster.normalize_copy_instance_ids(item)
		for copy_index in range(int(item.get("copies", 0))):
			var copy_id := str(copy_ids[copy_index])
			if _entry_can_be_attached(item):
				for model_index in range(int(item.get("models", 0))):
					source_items.append({"id": Roster.model_instance_id(item, copy_index, model_index), "copy_id": copy_id, "name": str(item.get("name", "Character")), "copy_index": copy_index, "model_index": model_index})
			targets.append({"id": copy_id, "name": str(item.get("name", "Unit")), "copy_index": copy_index})
	var source_selected_index := 0
	for candidate: Dictionary in source_items:
		leader_source_picker.add_item("%s · Unit %d · Model %d" % [candidate.name, int(candidate.copy_index) + 1, int(candidate.model_index) + 1])
		var option_index := leader_source_picker.item_count - 1
		leader_source_picker.set_item_metadata(option_index, candidate.id)
		if candidate.id == chosen_source: source_selected_index = option_index
	if source_selected_index == 0 and not source_items.is_empty(): source_selected_index = 1
	leader_source_picker.select(source_selected_index)
	var source_copy := ""
	if source_selected_index > 0:
		for candidate: Dictionary in source_items:
			if str(candidate.id) == str(leader_source_picker.get_item_metadata(source_selected_index)):
				source_copy = str(candidate.copy_id)
				break
	var target_selected_index := 0
	for candidate: Dictionary in targets:
		if str(candidate.id) == source_copy: continue
		leader_target_picker.add_item("%s · Unit %d" % [candidate.name, int(candidate.copy_index) + 1])
		var option_index := leader_target_picker.item_count - 1
		leader_target_picker.set_item_metadata(option_index, candidate.id)
		if str(candidate.id) == chosen_target: target_selected_index = option_index
	if target_selected_index == 0 and leader_target_picker.item_count > 1: target_selected_index = 1
	leader_target_picker.select(target_selected_index)
	leader_source_picker.disabled = leader_source_picker.item_count == 1
	leader_target_picker.disabled = leader_target_picker.item_count == 1
	leader_assignment_button.disabled = leader_source_picker.disabled or leader_target_picker.disabled
	leader_assignment_view.clear()
	var assignments: Variant = draft.get("leader_assignments", [])
	if assignments is Array:
		for assignment: Variant in assignments:
			if not assignment is Dictionary: continue
			var leader_label := _formation_model_label(str(assignment.get("leader_model_id", "")))
			var target_label := _formation_copy_label(str(assignment.get("target_copy_id", "")))
			leader_assignment_view.add_item("%s → %s" % [leader_label, target_label])
			leader_assignment_view.set_item_metadata(leader_assignment_view.item_count - 1, assignment.duplicate(true))
		if leader_assignment_view.item_count > 0: leader_assignment_view.select(0)
	leader_remove_button.disabled = leader_assignment_view.item_count == 0
	leader_assignment_status.text = "Match rules verify each assignment." if leader_assignment_view.item_count > 0 else "No assignments saved."
	updating = false

func _formation_model_label(model_id: String) -> String:
	for item: Dictionary in draft.get("entries", []):
		var copy_ids := Roster.normalize_copy_instance_ids(item)
		for copy_index in range(int(item.get("copies", 0))):
			for model_index in range(int(item.get("models", 0))):
				if Roster.model_instance_id(item, copy_index, model_index) == model_id:
					return "%s · Unit %d · Model %d" % [str(item.get("name", "Character")), copy_index + 1, model_index + 1]
	return "Unavailable miniature"

func _formation_copy_label(copy_id: String) -> String:
	for item: Dictionary in draft.get("entries", []):
		var copy_ids := Roster.normalize_copy_instance_ids(item)
		for copy_index in range(int(item.get("copies", 0))):
			if str(copy_ids[copy_index]) == copy_id:
				return "%s · Unit %d" % [str(item.get("name", "Unit")), copy_index + 1]
	return "Unavailable unit"

func _save_leader_assignment() -> void:
	if updating or leader_source_picker == null or leader_target_picker == null: return
	if leader_source_picker.selected <= 0 or leader_target_picker.selected <= 0: return
	var leader_model_id := str(leader_source_picker.get_item_metadata(leader_source_picker.selected))
	var target_copy_id := str(leader_target_picker.get_item_metadata(leader_target_picker.selected))
	if leader_model_id.is_empty() or target_copy_id.is_empty(): return
	var assignments: Array = draft.get("leader_assignments", []).duplicate(true)
	var replacement := {"leader_model_id": leader_model_id, "target_copy_id": target_copy_id}
	var replaced := false
	for index in range(assignments.size()):
		var assignment: Variant = assignments[index]
		if assignment is Dictionary and str(assignment.get("leader_model_id", "")) == leader_model_id:
			assignments[index] = replacement
			replaced = true
			break
	if not replaced: assignments.append(replacement)
	draft.leader_assignments = assignments
	_sync()
	var validation := Roster.validate(draft)
	if not validation.is_empty():
		leader_assignment_status.text = validation
		return
	dirty = true
	save_error = ""
	_render_saved_leader_controls()
	_render_summary()

func _remove_leader_assignment() -> void:
	if updating or leader_assignment_view == null: return
	var selected_rows := leader_assignment_view.get_selected_items()
	if selected_rows.is_empty(): return
	var assignments: Array = draft.get("leader_assignments", []).duplicate(true)
	var row: int = int(selected_rows[0])
	if row < 0 or row >= assignments.size(): return
	assignments.remove_at(row)
	draft.leader_assignments = assignments
	_sync()
	dirty = true
	save_error = ""
	_render_saved_leader_controls()
	_render_summary()

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

func _visual_model_role_label(item: Dictionary, model_index: int, copy_index: int = 0) -> String:
	var definition := str(item.get("unit_id", ""))
	if definition.ends_with(":intercessor-squad") and model_index == 0:
		return "Intercessor Sergeant"
	if definition.ends_with(":intercessor-squad"):
		if not item.has("models") or model_index >= int(item.get("models", 0)): return "Model %d" % (model_index + 1)
		return "Intercessor Grenadier" if bool(Roster.model_equipment(item, copy_index, model_index).get("intercessor_grenade_launcher", false)) else "Intercessor Trooper"
	if definition.ends_with(":sanguinary-guard"):
		var inferno := bool(Roster.model_equipment(item, copy_index, model_index).get("sanguinary_guard_inferno_pistol", false))
		return "Sanguinary Guard %d · %s" % [model_index + 1, "Inferno Pistol" if inferno else "Angelus Boltgun"]
	if definition.ends_with(":aggressor-squad"):
		var model_name := "Aggressor Sergeant" if model_index == 0 else "Aggressor %d" % (model_index + 1)
		if not item.has("models") or model_index >= int(item.get("models", 0)): return model_name
		var boltstorm := bool(Roster.model_equipment(item, copy_index, model_index).get("aggressor_boltstorm", false))
		return "%s · %s" % [model_name, "Boltstorm / Fragstorm" if boltstorm else "Flamestorm"]
	if definition.ends_with(":eliminator-squad"):
		return "Eliminator Sergeant" if model_index == 0 else "Eliminator Trooper %d" % model_index
	if definition.ends_with(":hellblaster-squad") and model_index == 0:
		var pistol_choice := str(Roster.model_equipment(item, copy_index, model_index).get("hellblaster_sergeant_pistol", "bolt-pistol"))
		return "Hellblaster Sergeant · %s" % ("Plasma Pistol" if pistol_choice == "plasma-pistol" else "Bolt Pistol")
	if definition.ends_with(":assault-intercessor-squad") and model_index == 0:
		var equipment := Roster.model_equipment(item, copy_index, model_index)
		var pistol_name: String = str({"heavy-bolt-pistol": "Heavy Bolt Pistol", "hand-flamer": "Hand Flamer", "plasma-pistol": "Plasma Pistol"}.get(str(equipment.get("assault_intercessor_sergeant_pistol", "heavy-bolt-pistol")), "Unresolved pistol"))
		var melee_name: String = str({"chainsword": "Chainsword", "power-fist": "Power Fist", "power-weapon": "Power Weapon", "thunder-hammer": "Thunder Hammer"}.get(str(equipment.get("assault_intercessor_sergeant_melee", "chainsword")), "Unresolved melee weapon"))
		return "Assault Intercessor Sergeant · %s · %s" % [pistol_name, melee_name]
	if definition.ends_with(":heavy-intercessor-squad") and model_index > 0:
		return "Heavy Intercessor %d%s" % [model_index + 1, " · Heavy Bolter" if bool(Roster.model_equipment(item, copy_index, model_index).get("heavy_intercessor_bolter", false)) else ""]
	if definition.ends_with(":outrider-squad"):
		var equipment := Roster.model_equipment(item, copy_index, model_index)
		var role_name := "Outrider Sergeant" if model_index == 0 else "Outrider %d" % (model_index + 1)
		if bool(equipment.get("outrider_plasma_pistol", false)): role_name += " · Plasma Pistol"
		return role_name
	if definition.ends_with(":ravenwing-darkshroud"):
		var choice_id := str(Roster.model_equipment(item, copy_index, model_index).get("ravenwing_darkshroud_cannon", "heavy-bolter"))
		return "Ravenwing Darkshroud · %s" % str({"heavy-bolter": "Heavy Bolter", "assault-cannon": "Assault Cannon"}.get(choice_id, "Unresolved weapon"))
	if definition.ends_with(":land-speeder"):
		var choice_id := str(Roster.model_equipment(item, copy_index, model_index).get("land_speeder_cannon", "onslaught"))
		return "Land Speeder · %s" % str({"onslaught": "Onslaught Gatling Cannon", "pyrecannon": "Pyrecannon"}.get(choice_id, "Unresolved weapon"))
	if SavedEquipment.supports(definition):
		var equipment := Roster.model_equipment(item, copy_index, model_index)
		return str(item.get("name", "Model")) + " · " + SavedEquipment.summary(definition, equipment, int(item.get("models", 0)), model_index)
	if definition.ends_with(":land-speeder-vengeance"):
		var choice_id := str(Roster.model_equipment(item, copy_index, model_index).get("land_speeder_vengeance_cannon", "heavy-bolter"))
		return "Land Speeder Vengeance · %s" % str({"heavy-bolter": "Heavy Bolter", "assault-cannon": "Assault Cannon"}.get(choice_id, "Unresolved weapon"))
	if definition.ends_with(":baal-predator"):
		var equipment := Roster.model_equipment(item, copy_index, model_index)
		var primary := str({"twin-assault-cannon": "Twin Assault Cannon", "baal-flamestorm-cannon": "Baal Flamestorm Cannon"}.get(str(equipment.get("baal_predator_primary_cannon", "twin-assault-cannon")), "Unresolved cannon"))
		var sponsons := str({"none": "no sponsons", "heavy-bolters": "two Heavy Bolters", "heavy-flamers": "two Heavy Flamers"}.get(str(equipment.get("baal_predator_sponson_package", "none")), "unresolved sponsons"))
		return "Baal Predator · %s · %s%s%s" % [primary, sponsons, " · Storm Bolter" if bool(equipment.get("baal_predator_storm_bolter", false)) else "", " · Hunter-killer Missile" if bool(equipment.get("baal_predator_hunter_killer_missile", false)) else ""]
	if definition.ends_with(":predator-destructor"):
		var equipment := Roster.model_equipment(item, copy_index, model_index)
		var sponsons := "two Heavy Bolters" if bool(equipment.get("predator_destructor_heavy_bolters", false)) else "two Lascannons"
		return "Predator Destructor · %s%s%s" % [sponsons, " · Storm Bolter" if bool(equipment.get("predator_destructor_storm_bolter", false)) else "", " · Hunter-killer Missile" if bool(equipment.get("predator_destructor_hunter_killer_missile", false)) else ""]
	if definition.ends_with(":predator-annihilator"):
		var equipment := Roster.model_equipment(item, copy_index, model_index)
		var sponsons := "two Heavy Bolters" if bool(equipment.get("predator_annihilator_heavy_bolters", false)) else "two Lascannons"
		return "Predator Annihilator · %s%s%s" % [sponsons, " · Storm Bolter" if bool(equipment.get("predator_annihilator_storm_bolter", false)) else "", " · Hunter-killer Missile" if bool(equipment.get("predator_annihilator_hunter_killer_missile", false)) else ""]
	if definition.ends_with(":inceptor-squad"):
		var choice_id := str(Roster.model_equipment(item, copy_index, model_index).get("inceptor_weapon", "assault-bolters"))
		return "Inceptor %d%s · %s" % [model_index + 1, " · Sergeant" if model_index == 0 else "", str({"assault-bolters": "Assault Bolters", "plasma-exterminators": "Plasma Exterminators"}.get(choice_id, "Unresolved weapon"))]
	if definition.ends_with(":invader-atvs"):
		var multi_melta := bool(Roster.model_equipment(item, copy_index, model_index).get("invader_atv_multi_melta", false))
		return "Invader ATV %d · %s" % [model_index + 1, "Multi-melta" if multi_melta else "Onslaught Gatling Cannon"]
	if definition.ends_with(":scout-squad"):
		var equipment := Roster.model_equipment(item, copy_index, model_index)
		var gun_label := str({"boltgun": "Boltgun", "shotgun": "Shotgun", "sniper-rifle": "Sniper Rifle", "heavy-bolter": "Heavy Bolter", "missile-launcher": "Missile Launcher"}.get(str(equipment.get("scout_gun", "boltgun")), "Unresolved weapon"))
		if model_index == 0:
			var blade_label := "Chainsword" if str(equipment.get("scout_sergeant_blade", "combat-knife")) == "chainsword" else "Combat Knife"
			return "Scout Sergeant · %s · %s" % [gun_label, blade_label]
		return "Scout %d · %s" % [model_index + 1, gun_label]
	if definition.ends_with(":necron-warriors"):
		return "Necron Warrior %d" % (model_index + 1)
	if definition.ends_with(":immortals"):
		return "Immortal %d" % (model_index + 1)
	if definition.ends_with(":canoptek-macrocytes"):
		return "Canoptek Macrocyte %d" % (model_index + 1)
	if definition.ends_with(":canoptek-spyders"):
		return "Canoptek Spyder %d" % (model_index + 1)
	if definition.ends_with(":canoptek-tomb-crawlers"):
		return "Canoptek Tomb Crawler %d" % (model_index + 1)
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
	Roster.normalize_copy_instance_ids(item)
	Roster.normalize_visual_variants(item)
	Roster.normalize_model_visual_overrides(item)
	Roster.normalize_model_visual_selection_modes(item)
	Roster.normalize_model_equipment(item)

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

func _set_necron_model_weapon_from_controls(_selected_option: int, model_index: int, picker: OptionButton, is_warrior: bool) -> void:
	if updating or selected_entry_index < 0 or selected_entry_index >= draft.entries.size() or sergeant_loadout_copy_picker.selected < 0 or picker.selected < 0: return
	var item: Dictionary = draft.entries[selected_entry_index]
	var unit_id := str(item.get("unit_id", ""))
	if is_warrior != unit_id.ends_with(":necron-warriors") or (not is_warrior and not unit_id.ends_with(":immortals")): return
	var copy_index := int(sergeant_loadout_copy_picker.get_selected_metadata())
	var choice_id := str(picker.get_selected_metadata())
	var default_weapon := "gauss-flayer" if is_warrior else "gauss-blaster"
	var previous := str(Roster.model_equipment(item, copy_index, model_index).get("necron_ranged_weapon", default_weapon))
	if previous == choice_id: return
	Roster.set_model_equipment(item, copy_index, model_index, "necron_ranged_weapon", choice_id)
	dirty = true
	save_error = ""
	var slot := copy_index * maxi(1, int(item.get("models", 1))) + model_index
	_preview_entry(item, slot)
	_render_visual_slots()
	_render_summary()
	if notice != null:
		var weapon_name := str(Roster.NECRON_WARRIOR_WEAPONS.get(choice_id, "Gauss flayer")) if is_warrior else str(Roster.IMMORTAL_WEAPONS.get(choice_id, "Gauss blaster"))
		notice.text = "%s %d · %s saved for this miniature and fixed for saved-list matches. Edit the saved list before starting another match." % ["Necron Warrior" if is_warrior else "Immortal", model_index + 1, weapon_name]

func _set_canoptek_macrocyte_loadout(_selected_option: int, model_index: int, picker: OptionButton) -> void:
	if updating or selected_entry_index < 0 or selected_entry_index >= draft.entries.size() or sergeant_loadout_copy_picker.selected < 0 or picker.selected < 0: return
	var item: Dictionary = draft.entries[selected_entry_index]
	if not str(item.get("unit_id", "")).ends_with(":canoptek-macrocytes"): return
	var copy_index := int(sergeant_loadout_copy_picker.get_selected_metadata())
	var choice_id := str(picker.get_selected_metadata())
	var previous := str(Roster.model_equipment(item, copy_index, model_index).get("canoptek_macrocytes_loadout", CanoptekMacrocytes.GAUSS_SCALPEL))
	if previous == choice_id: return
	Roster.set_model_equipment(item, copy_index, model_index, "canoptek_macrocytes_loadout", choice_id)
	dirty = true
	save_error = ""
	var slot := copy_index * maxi(1, int(item.get("models", 1))) + model_index
	_preview_entry(item, slot)
	_render_visual_slots()
	_render_summary()
	if notice != null:
		notice.text = "Canoptek Macrocyte %d · %s saved for this miniature and fixed for saved-list matches. Specialist equipment limits are checked when the list is admitted." % [model_index + 1, CanoptekMacrocytes.loadout_label(choice_id)]

func _set_canoptek_spyder_equipment(toggled: bool, model_index: int, field: String, checkbox: CheckBox) -> void:
	if updating or selected_entry_index < 0 or selected_entry_index >= draft.entries.size() or sergeant_loadout_copy_picker.selected < 0: return
	var item: Dictionary = draft.entries[selected_entry_index]
	if not str(item.get("unit_id", "")).ends_with(":canoptek-spyders"): return
	var copy_index := int(sergeant_loadout_copy_picker.get_selected_metadata())
	var previous := bool(Roster.model_equipment(item, copy_index, model_index).get(field, false))
	if previous == toggled: return
	Roster.set_model_equipment(item, copy_index, model_index, field, toggled)
	dirty = true
	save_error = ""
	var slot := copy_index * maxi(1, int(item.get("models", 1))) + model_index
	_preview_entry(item, slot)
	_render_visual_slots()
	_render_summary()
	if notice != null:
		var option_name := field.trim_prefix("canoptek_spyders_").replace("_", " ").capitalize()
		notice.text = "Canoptek Spyder %d · %s %s. Saved-list matches use this equipment without asking again." % [model_index + 1, "Equipped" if checkbox.button_pressed else "Removed", option_name]

func _set_canoptek_tomb_crawler_loadout(_selected_option: int, model_index: int, picker: OptionButton) -> void:
	if updating or selected_entry_index < 0 or selected_entry_index >= draft.entries.size() or sergeant_loadout_copy_picker.selected < 0 or picker.selected < 0: return
	var item: Dictionary = draft.entries[selected_entry_index]
	if not str(item.get("unit_id", "")).ends_with(":canoptek-tomb-crawlers"): return
	var copy_index := int(sergeant_loadout_copy_picker.get_selected_metadata())
	var choice_id := str(picker.get_selected_metadata())
	if choice_id == CanoptekTombCrawlers.ISOLATOR:
		for other_model in range(int(item.get("models", 0))):
			if other_model == model_index: continue
			var other_loadout := str(Roster.model_equipment(item, copy_index, other_model).get("canoptek_tomb_crawlers_loadout", CanoptekTombCrawlers.GAUSS_REAPER))
			if other_loadout == CanoptekTombCrawlers.ISOLATOR:
				_render_sergeant_loadout_controls(copy_index)
				if notice != null: notice.text = "Only one Canoptek Tomb Crawler in this unit can take the transdimensional isolator."
				return
	var previous := str(Roster.model_equipment(item, copy_index, model_index).get("canoptek_tomb_crawlers_loadout", CanoptekTombCrawlers.GAUSS_REAPER))
	if previous == choice_id: return
	Roster.set_model_equipment(item, copy_index, model_index, "canoptek_tomb_crawlers_loadout", choice_id)
	dirty = true
	save_error = ""
	var slot := copy_index * maxi(1, int(item.get("models", 1))) + model_index
	_preview_entry(item, slot)
	_render_visual_slots()
	_render_summary()
	if notice != null:
		var loadout_name := "Twin gauss reaper" if choice_id == CanoptekTombCrawlers.GAUSS_REAPER else "Transdimensional isolator"
		notice.text = "Canoptek Tomb Crawler %d · %s saved for this miniature and fixed for saved-list matches." % [model_index + 1, loadout_name]

func _set_necron_vehicle_loadout(_selected_option: int, model_index: int, picker: OptionButton) -> void:
	if updating or selected_entry_index < 0 or selected_entry_index >= draft.entries.size() or sergeant_loadout_copy_picker.selected < 0 or picker.selected < 0: return
	var item: Dictionary = draft.entries[selected_entry_index]
	var definition_id := str(item.get("unit_id", ""))
	if not definition_id.ends_with(":" + NecronVehicleLoadouts.ANNIHILATION_BARGE) and not definition_id.ends_with(":" + NecronVehicleLoadouts.MONOLITH): return
	var copy_index := int(sergeant_loadout_copy_picker.get_selected_metadata())
	var choice_id := str(picker.get_selected_metadata())
	if not NecronVehicleLoadouts.valid_choice(definition_id, choice_id): return
	var field := "necron_annihilation_barge_loadout" if definition_id.ends_with(":" + NecronVehicleLoadouts.ANNIHILATION_BARGE) else "necron_monolith_loadout"
	if str(Roster.model_equipment(item, copy_index, model_index).get(field, "")) == choice_id: return
	Roster.set_model_equipment(item, copy_index, model_index, field, choice_id)
	dirty = true
	save_error = ""
	var slot := copy_index * maxi(1, int(item.get("models", 1))) + model_index
	_preview_entry(item, slot)
	_render_visual_slots()
	_render_summary()
	if notice != null:
		var vehicle_name := "Annihilation Barge" if definition_id.ends_with(":" + NecronVehicleLoadouts.ANNIHILATION_BARGE) else "Monolith"
		notice.text = "%s · %s saved for this miniature and fixed for saved-list matches." % [vehicle_name, NecronVehicleLoadouts.choice_label(definition_id, choice_id)]

func _sergeant_loadout_summary(item: Dictionary) -> String:
	var unit_id := str(item.get("unit_id", ""))
	if unit_id.ends_with(":baal-predator"):
		var first_baal := Roster.model_equipment(item, 0, 0)
		for copy_index in range(1, int(item.get("copies", 0))):
			if Roster.model_equipment(item, copy_index, 0) != first_baal: return " · Equipment varies by unit"
		var primary := str({"twin-assault-cannon": "Twin Assault Cannon", "baal-flamestorm-cannon": "Baal Flamestorm Cannon"}.get(str(first_baal.get("baal_predator_primary_cannon", "twin-assault-cannon")), "Unresolved cannon"))
		var sponsons := str({"none": "no sponsons", "heavy-bolters": "two Heavy Bolters", "heavy-flamers": "two Heavy Flamers"}.get(str(first_baal.get("baal_predator_sponson_package", "none")), "unresolved sponsons"))
		var options: Array[String] = [primary, sponsons]
		if bool(first_baal.get("baal_predator_storm_bolter", false)): options.append("Storm Bolter")
		if bool(first_baal.get("baal_predator_hunter_killer_missile", false)): options.append("Hunter-killer Missile")
		return " · " + " · ".join(options)
	if unit_id.ends_with(":sanguinary-guard"):
		var first_loadouts := Roster.model_equipment_loadouts(item, 0)
		for copy_index in range(1, int(item.get("copies", 0))):
			if Roster.model_equipment_loadouts(item, copy_index) != first_loadouts: return " · Model equipment varies by unit"
		var inferno_models: Array[String] = []
		for model_index in range(first_loadouts.size()):
			if bool(first_loadouts[model_index].get("sanguinary_guard_inferno_pistol", false)): inferno_models.append(str(model_index + 1))
		return " · Inferno Pistol: models %s" % ", ".join(inferno_models) if not inferno_models.is_empty() else ""
	if unit_id.ends_with(":predator-destructor"):
		var first_destructor := Roster.model_equipment(item, 0, 0)
		for copy_index in range(1, int(item.get("copies", 0))):
			if Roster.model_equipment(item, copy_index, 0) != first_destructor: return " · Equipment varies by unit"
		var options: Array[String] = ["two Heavy Bolters" if bool(first_destructor.get("predator_destructor_heavy_bolters", false)) else "two Lascannons"]
		if bool(first_destructor.get("predator_destructor_storm_bolter", false)): options.append("Storm Bolter")
		if bool(first_destructor.get("predator_destructor_hunter_killer_missile", false)): options.append("Hunter-killer Missile")
		return " · " + " · ".join(options)
	if unit_id.ends_with(":predator-annihilator"):
		var first_annihilator := Roster.model_equipment(item, 0, 0)
		for copy_index in range(1, int(item.get("copies", 0))):
			if Roster.model_equipment(item, copy_index, 0) != first_annihilator: return " · Equipment varies by unit"
		var options: Array[String] = ["two Heavy Bolters" if bool(first_annihilator.get("predator_annihilator_heavy_bolters", false)) else "two Lascannons"]
		if bool(first_annihilator.get("predator_annihilator_storm_bolter", false)): options.append("Storm Bolter")
		if bool(first_annihilator.get("predator_annihilator_hunter_killer_missile", false)): options.append("Hunter-killer Missile")
		return " · " + " · ".join(options)
	if unit_id.ends_with(":" + NecronVehicleLoadouts.ANNIHILATION_BARGE) or unit_id.ends_with(":" + NecronVehicleLoadouts.MONOLITH):
		var vehicle_loadouts := Roster.necron_vehicle_loadouts(item, 0)
		for copy_index in range(1, int(item.get("copies", 0))):
			if Roster.necron_vehicle_loadouts(item, copy_index) != vehicle_loadouts: return " · Weapon choice varies by unit"
		var field := "necron_annihilation_barge_loadout" if unit_id.ends_with(":" + NecronVehicleLoadouts.ANNIHILATION_BARGE) else "necron_monolith_loadout"
		return " · " + NecronVehicleLoadouts.choice_label(unit_id, str(Roster.model_equipment(item, 0, 0).get(field, NecronVehicleLoadouts.default_choice(unit_id))))
	if unit_id.ends_with(":canoptek-tomb-crawlers"):
		var first_crawlers := Roster.canoptek_tomb_crawlers_loadouts(item, 0)
		for copy_index in range(1, int(item.get("copies", 0))):
			if Roster.canoptek_tomb_crawlers_loadouts(item, copy_index) != first_crawlers: return " · Model equipment varies by unit"
		var crawler_summary: Array[String] = []
		for model_index in range(first_crawlers.size()):
			var label_text := "Twin gauss reaper" if first_crawlers[model_index] == CanoptekTombCrawlers.GAUSS_REAPER else "Transdimensional isolator"
			crawler_summary.append("%d: %s" % [model_index + 1, label_text])
		return " · " + " / ".join(crawler_summary)
	if unit_id.ends_with(":canoptek-spyders"):
		var first_spyders := Roster.canoptek_spyders_loadouts(item, 0)
		for copy_index in range(1, int(item.get("copies", 0))):
			if Roster.canoptek_spyders_loadouts(item, copy_index) != first_spyders: return " · Model equipment varies by unit"
		var model_summaries: Array[String] = []
		for model_index in range(first_spyders.size()):
			var equipped: Array[String] = []
			for option: String in CanoptekSpyders.OPTIONS:
				if bool(first_spyders[model_index].get(CanoptekSpyders.equipment_field(option), false)):
					equipped.append(CanoptekSpyders.equipment_label(option))
			model_summaries.append("%d: %s" % [model_index + 1, ", ".join(equipped) if not equipped.is_empty() else "default"])
		return " · " + " / ".join(model_summaries)
	if unit_id.ends_with(":canoptek-macrocytes"):
		var first_macrocytes := Roster.canoptek_macrocytes_loadouts(item, 0)
		for copy_index in range(1, int(item.get("copies", 0))):
			if Roster.canoptek_macrocytes_loadouts(item, copy_index) != first_macrocytes: return " · Model equipment varies by unit"
		var macrocyte_counts: Dictionary = {}
		for loadout: String in first_macrocytes: macrocyte_counts[loadout] = int(macrocyte_counts.get(loadout, 0)) + 1
		var macrocyte_summary: Array[String] = []
		for loadout: String in CanoptekMacrocytes.LOADOUTS:
			if int(macrocyte_counts.get(loadout, 0)) > 0: macrocyte_summary.append("%d %s" % [int(macrocyte_counts[loadout]), CanoptekMacrocytes.loadout_label(loadout)])
		return " · " + " / ".join(macrocyte_summary)
	if unit_id.ends_with(":necron-warriors") or unit_id.ends_with(":immortals"):
		var first_loadouts := Roster.necron_warrior_loadouts(item, 0) if unit_id.ends_with(":necron-warriors") else Roster.immortal_loadouts(item, 0)
		for copy_index in range(1, int(item.get("copies", 0))):
			var current_loadouts := Roster.necron_warrior_loadouts(item, copy_index) if unit_id.ends_with(":necron-warriors") else Roster.immortal_loadouts(item, copy_index)
			if current_loadouts != first_loadouts: return " · Model equipment varies by unit"
		var selected_counts := {"gauss-flayer": 0, "gauss-reaper": 0} if unit_id.ends_with(":necron-warriors") else {"gauss-blaster": 0, "tesla-carbine": 0}
		for choice_id: String in first_loadouts:
			if selected_counts.has(choice_id): selected_counts[choice_id] += 1
		var names := Roster.NECRON_WARRIOR_WEAPONS if unit_id.ends_with(":necron-warriors") else Roster.IMMORTAL_WEAPONS
		var counts: Array[String] = []
		for choice_id: String in names:
			if int(selected_counts.get(choice_id, 0)) > 0: counts.append("%d %s" % [int(selected_counts[choice_id]), str(names[choice_id])])
		return " · " + " / ".join(counts)
	if unit_id.ends_with(":eliminator-squad"):
		var first_equipment := str(Roster.model_equipment(item, 0, 0).get("eliminator_sergeant_ranged", "sniper"))
		var first_troopers: Array = Roster.eliminator_trooper_loadouts(item)[0] if int(item.get("copies", 0)) > 0 else []
		for copy_index in range(1, int(item.get("copies", 0))):
			var current_equipment := str(Roster.model_equipment(item, copy_index, 0).get("eliminator_sergeant_ranged", "sniper"))
			if current_equipment != first_equipment or Roster.eliminator_trooper_loadouts(item)[copy_index] != first_troopers: return " · Model equipment varies by unit"
		var summary := " · Sergeant: %s" % str(Roster.ELIMINATOR_SERGEANT_WEAPONS.get(first_equipment, "Bolt Sniper Rifle"))
		if not first_troopers.is_empty():
			var troop_names: Array[String] = []
			for weapon_choice: Variant in first_troopers: troop_names.append(str(Roster.ELIMINATOR_SERGEANT_WEAPONS.get(str(weapon_choice), "Bolt Sniper Rifle")))
			summary += " · Troopers: " + ", ".join(troop_names)
		return summary
	if unit_id.ends_with(":outrider-squad"):
		var first_outrider := Roster.outrider_loadout(item, 0)
		for copy_index in range(1, int(item.get("copies", 0))):
			if Roster.outrider_loadout(item, copy_index) != first_outrider: return " · Model equipment varies by unit"
		var sergeant_melee := str(first_outrider.get("sergeant_melee_choice", "chainsword"))
		var melee_label: String = str({"chainsword": "Chainsword", "power-weapon": "Power Weapon", "thunder-hammer": "Thunder Hammer"}.get(sergeant_melee, "Unresolved weapon"))
		var plasma_models: Array[String] = []
		var plasma_choices: Array = first_outrider.get("plasma_pistol_choices", [])
		for model_index in range(plasma_choices.size()):
			if bool(plasma_choices[model_index]): plasma_models.append(str(model_index + 1))
		var summary := " · Sergeant: %s" % melee_label
		if not plasma_models.is_empty(): summary += " · Plasma Pistols: models " + ", ".join(plasma_models)
		return summary
	if unit_id.ends_with(":ravenwing-darkshroud"):
		var first_choice := Roster.ravenwing_darkshroud_loadout(item, 0)
		for copy_index in range(1, int(item.get("copies", 0))):
			if Roster.ravenwing_darkshroud_loadout(item, copy_index) != first_choice: return " · Weapon choice varies by unit"
		return " · " + str({"heavy-bolter": "Heavy Bolter", "assault-cannon": "Assault Cannon"}.get(first_choice, "Unresolved weapon"))
	if unit_id.ends_with(":land-speeder"):
		var first_choice := str(Roster.model_equipment(item, 0, 0).get("land_speeder_cannon", "onslaught"))
		for copy_index in range(1, int(item.get("copies", 0))):
			if str(Roster.model_equipment(item, copy_index, 0).get("land_speeder_cannon", "onslaught")) != first_choice: return " · Weapon choice varies by unit"
		return " · " + str({"onslaught": "Onslaught Gatling Cannon", "pyrecannon": "Pyrecannon"}.get(first_choice, "Unresolved weapon"))
	if unit_id.ends_with(":land-speeder-vengeance"):
		var first_choice := str(Roster.model_equipment(item, 0, 0).get("land_speeder_vengeance_cannon", "heavy-bolter"))
		for copy_index in range(1, int(item.get("copies", 0))):
			if str(Roster.model_equipment(item, copy_index, 0).get("land_speeder_vengeance_cannon", "heavy-bolter")) != first_choice: return " · Weapon choice varies by unit"
		return " · " + str({"heavy-bolter": "Heavy Bolter", "assault-cannon": "Assault Cannon"}.get(first_choice, "Unresolved weapon"))
	if unit_id.ends_with(":invader-atvs"):
		var first_loadouts := Roster.invader_atv_loadouts(item, 0)
		for copy_index in range(1, int(item.get("copies", 0))):
			if Roster.invader_atv_loadouts(item, copy_index) != first_loadouts: return " · Weapon choice varies by unit"
		var multi_melta_models: Array[String] = []
		for model_index in range(first_loadouts.size()):
			if first_loadouts[model_index]: multi_melta_models.append(str(model_index + 1))
		if multi_melta_models.is_empty(): return ""
		return " · Multi-melta: model %s (+%d pts)" % [", ".join(multi_melta_models), Roster.equipment_points_for_copy(item, 0)]
	if unit_id.ends_with(":scout-squad"):
		var first_loadout := Roster.scout_loadout(item, 0)
		for copy_index in range(1, int(item.get("copies", 0))):
			if Roster.scout_loadout(item, copy_index) != first_loadout: return " · Equipment varies by unit"
		var parts: Array[String] = []
		var sergeant := first_loadout[0]
		if str(sergeant.get("scout_gun", "boltgun")) != "boltgun" or str(sergeant.get("scout_sergeant_blade", "combat-knife")) != "combat-knife":
			var gun_name: String = str({"boltgun": "Boltgun", "shotgun": "Shotgun"}.get(str(sergeant.get("scout_gun", "boltgun")), "Unresolved gun"))
			var blade_name: String = "Chainsword" if str(sergeant.get("scout_sergeant_blade", "combat-knife")) == "chainsword" else "Combat Knife"
			parts.append("Sergeant %s + %s" % [gun_name, blade_name])
		var counts: Dictionary = {}
		var labels := {"shotgun": "Shotgun", "sniper-rifle": "Sniper Rifle", "heavy-bolter": "Heavy Bolter", "missile-launcher": "Missile Launcher"}
		for model_index in range(1, first_loadout.size()):
			var gun := str(first_loadout[model_index].get("scout_gun", "boltgun"))
			if gun != "boltgun": counts[gun] = int(counts.get(gun, 0)) + 1
		var gun_ids := counts.keys()
		gun_ids.sort()
		for gun_id: String in gun_ids: parts.append("%d %s" % [int(counts[gun_id]), str(labels.get(gun_id, gun_id))])
		return " · " + " · ".join(parts) if not parts.is_empty() else ""
	if unit_id.ends_with(":reiver-squad"):
		var first_loadout := Roster.unit_equipment(item, 0)
		for copy_index in range(1, int(item.get("copies", 0))):
			if Roster.unit_equipment(item, copy_index) != first_loadout: return " · Squad gear varies by unit"
		var gear: Array[String] = []
		if bool(first_loadout.get("reiver_grav_chutes", false)): gear.append("Grav-chutes")
		if bool(first_loadout.get("reiver_grapnel_launchers", false)): gear.append("Grapnel Launchers")
		return " · " + " + ".join(gear) if not gear.is_empty() else ""
	if unit_id.ends_with(":aggressor-squad"):
		var first_loadouts := Roster.aggressor_model_loadouts(item, 0)
		if first_loadouts.is_empty(): return ""
		for copy_index in range(1, int(item.get("copies", 0))):
			if Roster.aggressor_model_loadouts(item, copy_index) != first_loadouts: return " · Equipment varies by unit"
		var boltstorm_models: Array[String] = []
		for model_index in range(first_loadouts.size()):
			if first_loadouts[model_index]: boltstorm_models.append(str(model_index + 1))
		return " · Boltstorm/Fragstorm: models %s" % ", ".join(boltstorm_models) if not boltstorm_models.is_empty() else ""
	if unit_id.ends_with(":inceptor-squad"):
		var first_loadouts := Roster.inceptor_loadouts(item, 0)
		for copy_index in range(1, int(item.get("copies", 0))):
			if Roster.inceptor_loadouts(item, copy_index) != first_loadouts: return " · Model equipment varies by unit"
		var weapon_names := {"assault-bolters": "Assault Bolters", "plasma-exterminators": "Plasma Exterminators"}
		var loadout_summary: Array[String] = []
		for model_index in range(first_loadouts.size()):
			loadout_summary.append("%d: %s" % [model_index + 1, str(weapon_names.get(first_loadouts[model_index], "Unresolved weapon"))])
		return " · " + " / ".join(loadout_summary)
	if unit_id.ends_with(":hellblaster-squad"):
		var first_choice := str(Roster.model_equipment(item, 0, 0).get("hellblaster_sergeant_pistol", "bolt-pistol"))
		for copy_index in range(1, int(item.get("copies", 0))):
			if str(Roster.model_equipment(item, copy_index, 0).get("hellblaster_sergeant_pistol", "bolt-pistol")) != first_choice: return " · Sergeant pistol varies by unit"
		return " · Sergeant: Plasma Pistol" if first_choice == "plasma-pistol" else ""
	if unit_id.ends_with(":assault-intercessor-squad"):
		var first_loadout := Roster.assault_intercessor_sergeant_loadouts(item)[0]
		for copy_index in range(1, int(item.get("copies", 0))):
			if Roster.assault_intercessor_sergeant_loadouts(item)[copy_index] != first_loadout: return " · Sergeant equipment varies by unit"
		var pistol_name := str({"heavy-bolt-pistol": "Heavy Bolt Pistol", "hand-flamer": "Hand Flamer", "plasma-pistol": "Plasma Pistol"}.get(str(first_loadout.pistol_choice), "Unresolved pistol"))
		var melee_name := str({"chainsword": "Chainsword", "power-fist": "Power Fist", "power-weapon": "Power Weapon", "thunder-hammer": "Thunder Hammer"}.get(str(first_loadout.melee_choice), "Unresolved melee weapon"))
		if pistol_name == "Heavy Bolt Pistol" and melee_name == "Chainsword": return ""
		return " · Sergeant: %s + %s" % [pistol_name, melee_name]
	if unit_id.ends_with(":heavy-intercessor-squad"):
		var first_loadouts := Roster.heavy_intercessor_bolter_loadouts(item, 0)
		for copy_index in range(1, int(item.get("copies", 0))):
			if Roster.heavy_intercessor_bolter_loadouts(item, copy_index) != first_loadouts: return " · Heavy Bolter choices vary by unit"
		var equipped_models: Array[String] = []
		for model_index in range(1, first_loadouts.size()):
			if first_loadouts[model_index]: equipped_models.append(str(model_index + 1))
		return " · Heavy Bolter: models %s" % ", ".join(equipped_models) if not equipped_models.is_empty() else ""
	if not unit_id.ends_with(":intercessor-squad"): return ""
	var summary_parts: Array[String] = []
	var first_sergeant := Roster.intercessor_sergeant_loadout(item, 0)
	var first_launchers := Roster.intercessor_grenade_launcher_loadouts(item, 0)
	var same_equipment := true
	for copy_index in range(1, int(item.get("copies", 0))):
		if Roster.intercessor_sergeant_loadout(item, copy_index) != first_sergeant or Roster.intercessor_grenade_launcher_loadouts(item, copy_index) != first_launchers:
			same_equipment = false
			break
	if not same_equipment:
		summary_parts.append("Equipment varies by unit")
	else:
		if str(first_sergeant.rifle_choice) != "bolt-rifle" or str(first_sergeant.melee_choice) != "knives-and-fists":
			summary_parts.append("Sergeant: %s + %s" % [str(Roster.INTERCESSOR_RIFLE_CHOICES[first_sergeant.rifle_choice]), str(Roster.INTERCESSOR_MELEE_CHOICES[first_sergeant.melee_choice])])
		var launcher_count := 0
		for equipped: bool in first_launchers:
			if equipped: launcher_count += 1
		if launcher_count > 0: summary_parts.append("%d Grenade Launcher%s" % [launcher_count, "" if launcher_count == 1 else "s"])
	return " · " + " · ".join(summary_parts) if not summary_parts.is_empty() else ""

func _render_sergeant_loadout_controls(preferred_copy: int = -1) -> void:
	if sergeant_loadout_heading == null: return
	var visible: bool = selected_entry_index >= 0 and selected_entry_index < draft.entries.size()
	var item: Dictionary = draft.entries[selected_entry_index] if visible else {}
	var unit_id := str(item.get("unit_id", ""))
	var is_intercessor := unit_id.ends_with(":intercessor-squad")
	var is_assault_intercessor := unit_id.ends_with(":assault-intercessor-squad")
	var is_heavy_intercessor := unit_id.ends_with(":heavy-intercessor-squad")
	var is_inceptor := unit_id.ends_with(":inceptor-squad")
	var is_invader_atv := unit_id.ends_with(":invader-atvs")
	var is_reiver := unit_id.ends_with(":reiver-squad")
	var is_aggressor := unit_id.ends_with(":aggressor-squad")
	var is_scout := unit_id.ends_with(":scout-squad")
	var is_eliminator := unit_id.ends_with(":eliminator-squad")
	var is_outrider := unit_id.ends_with(":outrider-squad")
	var is_darkshroud := unit_id.ends_with(":ravenwing-darkshroud")
	var is_land_speeder := unit_id.ends_with(":land-speeder")
	var is_land_speeder_vengeance := unit_id.ends_with(":land-speeder-vengeance")
	var is_saved_equipment := SavedEquipment.supports(unit_id)
	var is_baal_predator := unit_id.ends_with(":baal-predator")
	var is_predator_destructor := unit_id.ends_with(":predator-destructor")
	var is_predator_annihilator := unit_id.ends_with(":predator-annihilator")
	var is_hellblaster := unit_id.ends_with(":hellblaster-squad")
	var is_necron_warriors := unit_id.ends_with(":necron-warriors")
	var is_immortals := unit_id.ends_with(":immortals")
	var is_canoptek_macrocytes := unit_id.ends_with(":canoptek-macrocytes")
	var is_canoptek_spyders := unit_id.ends_with(":canoptek-spyders")
	var is_canoptek_tomb_crawlers := unit_id.ends_with(":canoptek-tomb-crawlers")
	var is_necron_annihilation_barge := unit_id.ends_with(":" + NecronVehicleLoadouts.ANNIHILATION_BARGE)
	var is_necron_monolith := unit_id.ends_with(":" + NecronVehicleLoadouts.MONOLITH)
	visible = visible and (is_intercessor or is_assault_intercessor or is_heavy_intercessor or is_inceptor or is_invader_atv or is_reiver or is_aggressor or is_scout or is_eliminator or is_outrider or is_darkshroud or is_land_speeder or is_land_speeder_vengeance or is_saved_equipment or is_baal_predator or is_predator_destructor or is_predator_annihilator or is_hellblaster or is_necron_warriors or is_immortals or is_canoptek_macrocytes or is_canoptek_spyders or is_canoptek_tomb_crawlers or is_necron_annihilation_barge or is_necron_monolith) and int(item.get("models", 0)) > 0
	sergeant_loadout_heading.visible = visible
	sergeant_loadout_copy_picker.get_parent().visible = visible
	sergeant_rifle_picker.get_parent().visible = visible and (is_intercessor or is_assault_intercessor or is_eliminator or is_outrider or is_darkshroud or is_land_speeder or is_land_speeder_vengeance or is_hellblaster)
	sergeant_rifle_picker.visible = visible and (is_intercessor or is_assault_intercessor or is_eliminator or is_outrider or is_darkshroud or is_land_speeder or is_land_speeder_vengeance or is_hellblaster)
	sergeant_rifle_picker.disabled = false
	sergeant_rifle_picker.tooltip_text = "Choose the Sergeant's source-listed weapon replacement."
	sergeant_rifle_picker.get_parent().visible = visible and (is_intercessor or is_assault_intercessor or is_eliminator or is_outrider or is_darkshroud or is_land_speeder or is_land_speeder_vengeance or is_hellblaster)
	sergeant_melee_picker.get_parent().visible = visible and (is_intercessor or is_assault_intercessor)
	sergeant_melee_picker.visible = visible and (is_intercessor or is_assault_intercessor)
	per_model_equipment_controls.visible = visible and (is_intercessor or is_heavy_intercessor or is_inceptor or is_invader_atv or is_reiver or is_aggressor or is_scout or is_eliminator or is_outrider or is_darkshroud or is_land_speeder or is_land_speeder_vengeance or is_saved_equipment or is_baal_predator or is_predator_destructor or is_predator_annihilator or is_necron_warriors or is_immortals or is_canoptek_macrocytes or is_canoptek_spyders or is_canoptek_tomb_crawlers or is_necron_annihilation_barge or is_necron_monolith)
	if not visible: return
	if is_saved_equipment and not SavedEquipment.is_model_scoped(unit_id): sergeant_loadout_heading.text = str(item.get("name", "Unit")).to_upper() + " EQUIPMENT"
	elif SavedEquipment.is_model_scoped(unit_id): sergeant_loadout_heading.text = str(item.get("name", "Unit")).to_upper() + " MODEL EQUIPMENT"
	elif is_intercessor: sergeant_loadout_heading.text = "INTERCESSOR EQUIPMENT"
	elif is_assault_intercessor: sergeant_loadout_heading.text = "ASSAULT INTERCESSOR SERGEANT EQUIPMENT"
	elif is_heavy_intercessor: sergeant_loadout_heading.text = "HEAVY INTERCESSOR MODEL EQUIPMENT"
	elif is_inceptor: sergeant_loadout_heading.text = "INCEPTOR MODEL EQUIPMENT"
	elif is_invader_atv: sergeant_loadout_heading.text = "INVADER ATV MODEL EQUIPMENT"
	elif is_reiver: sergeant_loadout_heading.text = "REIVER SQUAD GEAR"
	elif is_aggressor: sergeant_loadout_heading.text = "AGGRESSOR MODEL EQUIPMENT"
	elif is_scout: sergeant_loadout_heading.text = "SCOUT SQUAD MODEL EQUIPMENT"
	elif is_eliminator: sergeant_loadout_heading.text = "ELIMINATOR MODEL EQUIPMENT"
	elif is_outrider: sergeant_loadout_heading.text = "OUTRIDER MODEL EQUIPMENT"
	elif is_darkshroud: sergeant_loadout_heading.text = "RAVENWING DARKSHROUD WEAPON"
	elif is_land_speeder: sergeant_loadout_heading.text = "LAND SPEEDER CANNON"
	elif is_land_speeder_vengeance: sergeant_loadout_heading.text = "LAND SPEEDER VENGEANCE CANNON"
	elif is_baal_predator: sergeant_loadout_heading.text = "BAAL PREDATOR EQUIPMENT"
	elif is_predator_destructor: sergeant_loadout_heading.text = "PREDATOR DESTRUCTOR EQUIPMENT"
	elif is_predator_annihilator: sergeant_loadout_heading.text = "PREDATOR ANNIHILATOR EQUIPMENT"
	elif is_hellblaster: sergeant_loadout_heading.text = "HELLBLASTER SERGEANT PISTOL"
	elif is_necron_warriors: sergeant_loadout_heading.text = "NECRON WARRIOR MODEL EQUIPMENT"
	elif is_immortals: sergeant_loadout_heading.text = "IMMORTAL MODEL EQUIPMENT"
	elif is_canoptek_macrocytes: sergeant_loadout_heading.text = "CANOPTEK MACROCYTES MODEL EQUIPMENT"
	elif is_canoptek_spyders: sergeant_loadout_heading.text = "CANOPTEK SPYDERS MODEL EQUIPMENT"
	elif is_canoptek_tomb_crawlers: sergeant_loadout_heading.text = "CANOPTEK TOMB CRAWLERS MODEL EQUIPMENT"
	elif is_necron_annihilation_barge: sergeant_loadout_heading.text = "ANNIHILATION BARGE WEAPON"
	else: sergeant_loadout_heading.text = "MONOLITH WEAPONS"
	var wanted_copy := preferred_copy if preferred_copy >= 0 else maxi(0, sergeant_loadout_copy_picker.selected)
	sergeant_loadout_copy_picker.clear()
	for copy_index in range(int(item.get("copies", 0))):
		sergeant_loadout_copy_picker.add_item("Unit %d equipment" % (copy_index + 1))
		sergeant_loadout_copy_picker.set_item_metadata(copy_index, copy_index)
	var copy_index := clampi(wanted_copy, 0, maxi(0, int(item.get("copies", 0)) - 1))
	sergeant_loadout_copy_picker.select(copy_index)
	var old_rows := per_model_equipment_controls.get_children().duplicate()
	for old_row: Node in old_rows:
		per_model_equipment_controls.remove_child(old_row)
		old_row.queue_free()
	if is_saved_equipment:
		sergeant_rifle_picker.get_parent().visible = false
		for descriptor: Dictionary in SavedEquipment.unit_controls(unit_id):
			var checkbox := CheckBox.new()
			checkbox.text = str(descriptor.label)
			checkbox.tooltip_text = "Saved once for this unit copy; using the ability remains a match decision."
			checkbox.button_pressed = bool(Roster.unit_equipment(item, copy_index).get(descriptor.field, false))
			per_model_equipment_controls.add_child(checkbox)
			checkbox.toggled.connect(_set_registered_unit_equipment.bind(unit_id, str(descriptor.field), copy_index))
		var model_limit := int(item.get("models", 0)) if SavedEquipment.is_model_scoped(unit_id) else 1
		for model_index in range(model_limit):
			var equipment := Roster.model_equipment(item, copy_index, model_index)
			var controls_parent: Node = per_model_equipment_controls
			var descriptors := SavedEquipment.controls_for_model(unit_id, model_index, int(item.models))
			if SavedEquipment.uses_stacked_model_controls(unit_id):
				var model_card := VBoxContainer.new()
				model_card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
				per_model_equipment_controls.add_child(model_card)
				var model_heading := label(SavedEquipment.model_label(unit_id, int(item.models), model_index), model_card)
				model_heading.add_theme_font_size_override("font_size", 15)
				model_heading.add_theme_color_override("font_color", Color("e8bc62"))
				var model_fields := GridContainer.new()
				model_fields.columns = mini(2, maxi(1, descriptors.size()))
				model_fields.size_flags_horizontal = Control.SIZE_EXPAND_FILL
				model_fields.add_theme_constant_override("h_separation", 12)
				model_fields.add_theme_constant_override("v_separation", 6)
				model_card.add_child(model_fields)
				controls_parent = model_fields
				for descriptor: Dictionary in descriptors:
					var field_stack := VBoxContainer.new()
					field_stack.size_flags_horizontal = Control.SIZE_EXPAND_FILL
					controls_parent.add_child(field_stack)
					var field_label := label(str(descriptor.label), field_stack)
					field_label.add_theme_font_size_override("font_size", 13)
					var picker := OptionButton.new()
					picker.size_flags_horizontal = Control.SIZE_EXPAND_FILL
					for choice: Dictionary in descriptor.choices:
						picker.add_item(str(choice.label))
						picker.set_item_metadata(picker.item_count - 1, choice.id)
					_select_equipment_choice(picker, str(equipment.get(descriptor.field, "")))
					picker.disabled = picker.item_count <= 1
					field_stack.add_child(picker)
					picker.item_selected.connect(_set_registered_equipment.bind(unit_id, str(descriptor.field), copy_index, picker, model_index))
				continue
			if SavedEquipment.is_model_scoped(unit_id):
				var model_row := HBoxContainer.new()
				model_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
				per_model_equipment_controls.add_child(model_row)
				controls_parent = model_row
				label(SavedEquipment.model_label(unit_id, int(item.models), model_index), model_row)
			for descriptor: Dictionary in descriptors:
				var field_label := Label.new()
				field_label.text = str(descriptor.label)
				controls_parent.add_child(field_label)
				var picker := OptionButton.new()
				picker.size_flags_horizontal = Control.SIZE_EXPAND_FILL
				for choice: Dictionary in descriptor.choices:
					picker.add_item(str(choice.label))
					picker.set_item_metadata(picker.item_count - 1, choice.id)
				_select_equipment_choice(picker, str(equipment.get(descriptor.field, "")))
				picker.disabled = picker.item_count <= 1
				controls_parent.add_child(picker)
				picker.item_selected.connect(_set_registered_equipment.bind(unit_id, str(descriptor.field), copy_index, picker, model_index))
	elif is_baal_predator:
		sergeant_rifle_picker.get_parent().visible = false
		var baal_equipment := Roster.model_equipment(item, copy_index, 0)
		for choice_row: Dictionary in [
			{"label": "Primary cannon", "field": "baal_predator_primary_cannon", "options": BAAL_PREDATOR_PRIMARY_OPTIONS},
			{"label": "Sponson package", "field": "baal_predator_sponson_package", "options": BAAL_PREDATOR_SPONSON_OPTIONS}
		]:
			var row := HBoxContainer.new()
			row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			per_model_equipment_controls.add_child(row)
			label(str(choice_row.label), row)
			var picker := OptionButton.new()
			picker.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			picker.tooltip_text = "Choose a source-listed option from the verified local Baal Predator datasheet."
			row.add_child(picker)
			for option: Dictionary in choice_row.options:
				picker.add_item(str(option.label))
				picker.set_item_metadata(picker.item_count - 1, str(option.id))
			_select_equipment_choice(picker, str(baal_equipment.get(str(choice_row.field), "")))
			picker.item_selected.connect(_set_baal_predator_picker.bind(str(choice_row.field), picker))
		for optional_weapon: Dictionary in [
			{"field": "baal_predator_storm_bolter", "label": "Storm Bolter"},
			{"field": "baal_predator_hunter_killer_missile", "label": "Hunter-killer Missile"}
		]:
			var checkbox := CheckBox.new()
			checkbox.text = str(optional_weapon.label)
			checkbox.tooltip_text = "Save this source-listed optional weapon on this Baal Predator copy. Army cost follows the local current-reference profile."
			checkbox.button_pressed = bool(baal_equipment.get(str(optional_weapon.field), false))
			per_model_equipment_controls.add_child(checkbox)
			checkbox.toggled.connect(_set_baal_predator_optional_weapon.bind(str(optional_weapon.field)))
	elif is_predator_destructor or is_predator_annihilator:
		sergeant_rifle_picker.get_parent().visible = false
		var identity := "predator-destructor" if is_predator_destructor else "predator-annihilator"
		_render_predator_equipment(item, copy_index, identity)
	elif is_hellblaster:
		sergeant_rifle_picker.clear()
		sergeant_rifle_picker.tooltip_text = "Choose the Hellblaster Sergeant's source-listed, free Bolt Pistol replacement."
		for option: Dictionary in [{"id": "bolt-pistol", "label": "Bolt Pistol"}, {"id": "plasma-pistol", "label": "Plasma Pistol"}]:
			sergeant_rifle_picker.add_item(str(option.label))
			sergeant_rifle_picker.set_item_metadata(sergeant_rifle_picker.item_count - 1, str(option.id))
		var equipment := Roster.model_equipment(item, copy_index, 0)
		_select_equipment_choice(sergeant_rifle_picker, str(equipment.get("hellblaster_sergeant_pistol", "bolt-pistol")))
		sergeant_melee_picker.get_parent().visible = false
	elif is_scout:
		sergeant_rifle_picker.get_parent().visible = false
		sergeant_melee_picker.get_parent().visible = false
		var helper := Label.new()
		helper.text = "One Sniper Rifle and one Heavy Bolter or Missile Launcher per five models. The Sergeant may take a Shotgun and Chainsword."
		helper.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		per_model_equipment_controls.add_child(helper)
		var gun_labels := {"boltgun": "Boltgun", "shotgun": "Shotgun", "sniper-rifle": "Sniper Rifle", "heavy-bolter": "Heavy Bolter", "missile-launcher": "Missile Launcher"}
		for model_index in range(int(item.get("models", 0))):
			var equipment := Roster.model_equipment(item, copy_index, model_index)
			var gun_row := HBoxContainer.new()
			gun_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			per_model_equipment_controls.add_child(gun_row)
			label("Sergeant ranged" if model_index == 0 else "Scout %d" % (model_index + 1), gun_row)
			var gun_picker := OptionButton.new()
			gun_picker.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			gun_picker.tooltip_text = "Choose this model's source-listed Scout weapon. Specialist limits are checked for this unit copy."
			gun_row.add_child(gun_picker)
			for gun: String in Roster.scout_gun_options(item, copy_index, model_index):
				gun_picker.add_item(str(gun_labels.get(gun, gun)))
				gun_picker.set_item_metadata(gun_picker.item_count - 1, gun)
			_select_equipment_choice(gun_picker, str(equipment.get("scout_gun", "boltgun")))
			gun_picker.item_selected.connect(_set_scout_gun_from_controls.bind(model_index, gun_picker))
			if model_index == 0:
				var blade_row := HBoxContainer.new()
				blade_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
				per_model_equipment_controls.add_child(blade_row)
				label("Sergeant melee", blade_row)
				var blade_picker := OptionButton.new()
				blade_picker.size_flags_horizontal = Control.SIZE_EXPAND_FILL
				blade_picker.tooltip_text = "Choose the Scout Sergeant's source-listed Combat Knife replacement."
				blade_row.add_child(blade_picker)
				for option: Dictionary in [{"id": "combat-knife", "label": "Combat Knife"}, {"id": "chainsword", "label": "Chainsword"}]:
					blade_picker.add_item(str(option.label))
					blade_picker.set_item_metadata(blade_picker.item_count - 1, str(option.id))
				_select_equipment_choice(blade_picker, str(equipment.get("scout_sergeant_blade", "combat-knife")))
				blade_picker.item_selected.connect(_set_scout_blade_from_controls.bind(blade_picker))
	elif is_reiver:
		sergeant_rifle_picker.get_parent().visible = false
		label("These two source-listed options apply to the whole squad.", per_model_equipment_controls)
		var loadout := Roster.unit_equipment(item, copy_index)
		for option: Dictionary in [{"field": "reiver_grav_chutes", "label": "Grav-chutes"}, {"field": "reiver_grapnel_launchers", "label": "Grapnel Launchers"}]:
			var checkbox := CheckBox.new()
			checkbox.text = str(option.label)
			checkbox.tooltip_text = "Saved for this Reiver Squad copy. Saved-list matches apply it before Deployment."
			checkbox.button_pressed = bool(loadout.get(str(option.field), false))
			per_model_equipment_controls.add_child(checkbox)
			checkbox.toggled.connect(_set_reiver_equipment_from_controls.bind(str(option.field)))
	elif is_aggressor:
		sergeant_rifle_picker.get_parent().visible = false
		sergeant_melee_picker.get_parent().visible = false
		label("Each model may replace its Flamestorm Gauntlets with both source-listed Boltstorm weapons.", per_model_equipment_controls)
		for model_index in range(int(item.get("models", 0))):
			var checkbox := CheckBox.new()
			checkbox.text = "%s %d · Auto Boltstorm Gauntlets + Fragstorm Grenade Launcher" % ["Sergeant" if model_index == 0 else "Aggressor", model_index + 1]
			checkbox.tooltip_text = "Save this miniature's source-listed package for the selected Aggressor unit. Saved-list matches apply it before Deployment."
			checkbox.button_pressed = bool(Roster.model_equipment(item, copy_index, model_index).get("aggressor_boltstorm", false))
			per_model_equipment_controls.add_child(checkbox)
			checkbox.toggled.connect(_set_aggressor_boltstorm_from_controls.bind(model_index))
	elif is_assault_intercessor:
		sergeant_rifle_picker.clear()
		sergeant_rifle_picker.tooltip_text = "Choose the Assault Intercessor Sergeant's source-listed Heavy Bolt Pistol replacement."
		for option: Dictionary in [{"id": "heavy-bolt-pistol", "label": "Heavy Bolt Pistol"}, {"id": "hand-flamer", "label": "Hand Flamer"}, {"id": "plasma-pistol", "label": "Plasma Pistol"}]:
			sergeant_rifle_picker.add_item(str(option.label))
			sergeant_rifle_picker.set_item_metadata(sergeant_rifle_picker.item_count - 1, str(option.id))
		sergeant_melee_picker.clear()
		sergeant_melee_picker.tooltip_text = "Choose the Assault Intercessor Sergeant's source-listed Chainsword replacement."
		for option: Dictionary in [{"id": "chainsword", "label": "Chainsword"}, {"id": "power-fist", "label": "Power Fist"}, {"id": "power-weapon", "label": "Power Weapon"}, {"id": "thunder-hammer", "label": "Thunder Hammer"}]:
			sergeant_melee_picker.add_item(str(option.label))
			sergeant_melee_picker.set_item_metadata(sergeant_melee_picker.item_count - 1, str(option.id))
		var equipment := Roster.model_equipment(item, copy_index, 0)
		_select_equipment_choice(sergeant_rifle_picker, str(equipment.get("assault_intercessor_sergeant_pistol", "heavy-bolt-pistol")))
		_select_equipment_choice(sergeant_melee_picker, str(equipment.get("assault_intercessor_sergeant_melee", "chainsword")))
	elif is_heavy_intercessor:
		sergeant_rifle_picker.get_parent().visible = false
		var loadouts := Roster.heavy_intercessor_bolter_loadouts(item, copy_index)
		var equipped_count := 0
		for equipped: bool in loadouts:
			if equipped: equipped_count += 1
		var limit := int(int(item.get("models", 0)) / 5.0)
		var helper := Label.new()
		helper.text = "One non-Sergeant per five models may replace its Heavy Bolt Rifle with a Heavy Bolter. %d/%d equipped." % [equipped_count, limit]
		helper.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		per_model_equipment_controls.add_child(helper)
		for model_index in range(1, int(item.get("models", 0))):
			var checkbox := CheckBox.new()
			checkbox.text = "Heavy Intercessor %d · Heavy Bolter" % (model_index + 1)
			checkbox.tooltip_text = "Save whether this model replaces its Heavy Bolt Rifle with a Heavy Bolter. One model per five starting models."
			checkbox.button_pressed = loadouts[model_index]
			checkbox.disabled = not checkbox.button_pressed and equipped_count >= limit
			if checkbox.disabled: checkbox.tooltip_text = "This unit has reached its Heavy Bolter limit. Remove a checked choice before choosing another model."
			per_model_equipment_controls.add_child(checkbox)
			checkbox.toggled.connect(_set_heavy_intercessor_bolter_from_controls.bind(model_index))
	elif is_inceptor:
		sergeant_rifle_picker.get_parent().visible = false
		for model_index in range(int(item.get("models", 0))):
			var equipment_row := HBoxContainer.new()
			equipment_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			per_model_equipment_controls.add_child(equipment_row)
			label("Inceptor %d%s" % [model_index + 1, " · Sergeant" if model_index == 0 else ""], equipment_row)
			var picker := OptionButton.new()
			picker.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			picker.tooltip_text = "Choose this model's source-listed Assault Bolters or Plasma Exterminators."
			equipment_row.add_child(picker)
			for option: Dictionary in [{"id": "assault-bolters", "label": "Assault Bolters"}, {"id": "plasma-exterminators", "label": "Plasma Exterminators"}]:
				picker.add_item(str(option.label))
				picker.set_item_metadata(picker.item_count - 1, str(option.id))
			var equipment := Roster.model_equipment(item, copy_index, model_index)
			_select_equipment_choice(picker, str(equipment.get("inceptor_weapon", "assault-bolters")))
			picker.item_selected.connect(_set_inceptor_weapon_from_controls.bind(model_index, picker))
	elif is_invader_atv:
		sergeant_rifle_picker.get_parent().visible = false
		for model_index in range(int(item.get("models", 0))):
			var checkbox := CheckBox.new()
			checkbox.text = "Invader ATV %d · Multi-melta (+5 points)" % (model_index + 1)
			checkbox.tooltip_text = "Replace this model's Onslaught Gatling Cannon with a Multi-melta. The source costs 5 points for each equipped model."
			checkbox.button_pressed = bool(Roster.model_equipment(item, copy_index, model_index).get("invader_atv_multi_melta", false))
			per_model_equipment_controls.add_child(checkbox)
			checkbox.toggled.connect(_set_invader_atv_multi_melta_from_controls.bind(model_index))
	elif is_land_speeder_vengeance:
		sergeant_rifle_picker.clear()
		sergeant_rifle_picker.tooltip_text = "Choose the Land Speeder Vengeance's source-listed Heavy Bolter replacement."
		for option: Dictionary in [{"id": "heavy-bolter", "label": "Heavy Bolter"}, {"id": "assault-cannon", "label": "Assault Cannon"}]:
			sergeant_rifle_picker.add_item(str(option.label))
			sergeant_rifle_picker.set_item_metadata(sergeant_rifle_picker.item_count - 1, str(option.id))
		var equipment := Roster.model_equipment(item, copy_index, 0)
		_select_equipment_choice(sergeant_rifle_picker, str(equipment.get("land_speeder_vengeance_cannon", "heavy-bolter")))
		sergeant_melee_picker.get_parent().visible = false
	elif is_land_speeder:
		sergeant_rifle_picker.clear()
		sergeant_rifle_picker.tooltip_text = "Choose the Land Speeder's source-listed Onslaught Gatling Cannon replacement."
		for option: Dictionary in [{"id": "onslaught", "label": "Onslaught Gatling Cannon"}, {"id": "pyrecannon", "label": "Pyrecannon"}]:
			sergeant_rifle_picker.add_item(str(option.label))
			sergeant_rifle_picker.set_item_metadata(sergeant_rifle_picker.item_count - 1, str(option.id))
		var equipment := Roster.model_equipment(item, copy_index, 0)
		_select_equipment_choice(sergeant_rifle_picker, str(equipment.get("land_speeder_cannon", "onslaught")))
		sergeant_melee_picker.get_parent().visible = false
	elif is_darkshroud:
		sergeant_rifle_picker.clear()
		sergeant_rifle_picker.tooltip_text = "Choose the source-listed Heavy Bolter replacement for this Darkshroud copy."
		for option: Dictionary in [{"id": "heavy-bolter", "label": "Heavy Bolter"}, {"id": "assault-cannon", "label": "Assault Cannon"}]:
			sergeant_rifle_picker.add_item(str(option.label))
			sergeant_rifle_picker.set_item_metadata(sergeant_rifle_picker.item_count - 1, str(option.id))
		_select_equipment_choice(sergeant_rifle_picker, Roster.ravenwing_darkshroud_loadout(item, copy_index))
		sergeant_melee_picker.get_parent().visible = false
	elif is_outrider:
		sergeant_rifle_picker.clear()
		sergeant_rifle_picker.tooltip_text = "Choose the Outrider Sergeant's source-listed Chainsword replacement."
		for option: Dictionary in [{"id": "chainsword", "label": "Chainsword"}, {"id": "power-weapon", "label": "Power Weapon"}, {"id": "thunder-hammer", "label": "Thunder Hammer"}]:
			sergeant_rifle_picker.add_item(str(option.label))
			sergeant_rifle_picker.set_item_metadata(sergeant_rifle_picker.item_count - 1, str(option.id))
		var sergeant_equipment := Roster.model_equipment(item, copy_index, 0)
		_select_equipment_choice(sergeant_rifle_picker, str(sergeant_equipment.get("outrider_sergeant_melee", "chainsword")))
		var plasma_count := 0
		for model_index in range(int(item.get("models", 0))):
			if bool(Roster.model_equipment(item, copy_index, model_index).get("outrider_plasma_pistol", false)): plasma_count += 1
		var plasma_limit := int(int(item.get("models", 0)) / 3.0)
		var helper := Label.new()
		helper.text = "Any model may replace its Heavy Bolt Pistol with a Plasma Pistol. Limit: one per three models. %d/%d equipped." % [plasma_count, plasma_limit]
		helper.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		per_model_equipment_controls.add_child(helper)
		for model_index in range(int(item.get("models", 0))):
			var checkbox := CheckBox.new()
			checkbox.text = "Outrider %d%s · Plasma Pistol" % [model_index + 1, " · Sergeant" if model_index == 0 else ""]
			checkbox.tooltip_text = "Save whether this model replaces its Heavy Bolt Pistol with a Plasma Pistol. One per three starting models."
			checkbox.button_pressed = bool(Roster.model_equipment(item, copy_index, model_index).get("outrider_plasma_pistol", false))
			checkbox.disabled = not checkbox.button_pressed and plasma_count >= plasma_limit
			if checkbox.disabled: checkbox.tooltip_text = "This unit has reached its Plasma Pistol limit. Remove a checked choice before choosing another model."
			per_model_equipment_controls.add_child(checkbox)
			checkbox.toggled.connect(_set_outrider_plasma_pistol_from_controls.bind(model_index))
		sergeant_melee_picker.get_parent().visible = false
	elif is_eliminator:
		sergeant_rifle_picker.clear()
		sergeant_rifle_picker.tooltip_text = "Choose the Eliminator Sergeant's ranged weapon from the current local datasheet options."
		for option: Dictionary in ELIMINATOR_SERGEANT_OPTIONS:
			sergeant_rifle_picker.add_item(str(option.label))
			sergeant_rifle_picker.set_item_metadata(sergeant_rifle_picker.item_count - 1, str(option.id))
		var equipment := Roster.model_equipment(item, copy_index, 0)
		_select_equipment_choice(sergeant_rifle_picker, str(equipment.get("eliminator_sergeant_ranged", "sniper")))
		for model_index in range(1, int(item.get("models", 0))):
			var equipment_row := HBoxContainer.new()
			equipment_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			per_model_equipment_controls.add_child(equipment_row)
			label("Eliminator %d" % model_index, equipment_row)
			var picker := OptionButton.new()
			picker.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			picker.tooltip_text = "Choose this miniature's ranged weapon from the current local datasheet options."
			equipment_row.add_child(picker)
			for option: Dictionary in ELIMINATOR_TROOPER_OPTIONS:
				picker.add_item(str(option.label))
				picker.set_item_metadata(picker.item_count - 1, str(option.id))
			var trooper_equipment := Roster.model_equipment(item, copy_index, model_index)
			_select_equipment_choice(picker, str(trooper_equipment.get("eliminator_trooper_ranged", "sniper")))
			picker.item_selected.connect(_set_eliminator_trooper_from_controls.bind(model_index, picker))
	elif is_necron_warriors or is_immortals:
		var options: Array = NECRON_WARRIOR_OPTIONS if is_necron_warriors else IMMORTAL_OPTIONS
		var role_name := "Necron Warrior" if is_necron_warriors else "Immortal"
		var default_weapon := "gauss-flayer" if is_necron_warriors else "gauss-blaster"
		sergeant_rifle_picker.get_parent().visible = false
		for model_index in range(int(item.get("models", 0))):
			var equipment_row := HBoxContainer.new()
			equipment_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			per_model_equipment_controls.add_child(equipment_row)
			label("%s %d" % [role_name, model_index + 1], equipment_row)
			var picker := OptionButton.new()
			picker.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			picker.tooltip_text = "Choose this model's source-listed ranged weapon from the local Necrons App v1.2 profile."
			equipment_row.add_child(picker)
			for option: Dictionary in options:
				picker.add_item(str(option.label))
				picker.set_item_metadata(picker.item_count - 1, str(option.id))
			var equipment := Roster.model_equipment(item, copy_index, model_index)
			_select_equipment_choice(picker, str(equipment.get("necron_ranged_weapon", default_weapon)))
			picker.item_selected.connect(_set_necron_model_weapon_from_controls.bind(model_index, picker, is_necron_warriors))
	elif is_canoptek_macrocytes:
		sergeant_rifle_picker.get_parent().visible = false
		for model_index in range(int(item.get("models", 0))):
			var equipment_row := HBoxContainer.new()
			equipment_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			per_model_equipment_controls.add_child(equipment_row)
			label("Canoptek Macrocyte %d" % (model_index + 1), equipment_row)
			var picker := OptionButton.new()
			picker.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			picker.tooltip_text = "Choose this model's source-listed equipment from the local Necrons App v1.2 profile. Specialist model limits are admission-checked."
			equipment_row.add_child(picker)
			for option: Dictionary in CANOPTEK_MACROCYTE_OPTIONS:
				picker.add_item(str(option.label))
				picker.set_item_metadata(picker.item_count - 1, str(option.id))
			var equipment := Roster.model_equipment(item, copy_index, model_index)
			_select_equipment_choice(picker, str(equipment.get("canoptek_macrocytes_loadout", CanoptekMacrocytes.GAUSS_SCALPEL)))
			picker.item_selected.connect(_set_canoptek_macrocyte_loadout.bind(model_index, picker))
	elif is_canoptek_spyders:
		sergeant_rifle_picker.get_parent().visible = false
		for model_index in range(int(item.get("models", 0))):
			var model_group := VBoxContainer.new()
			model_group.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			per_model_equipment_controls.add_child(model_group)
			label("Canoptek Spyder %d" % (model_index + 1), model_group)
			var equipment := Roster.model_equipment(item, copy_index, model_index)
			for option: String in CanoptekSpyders.OPTIONS:
				var checkbox := CheckBox.new()
				checkbox.text = CanoptekSpyders.equipment_label(option)
				checkbox.tooltip_text = "Source-listed equipment for this Canoptek Spyder. The same model can select other listed options independently."
				checkbox.button_pressed = bool(equipment.get(CanoptekSpyders.equipment_field(option), false))
				model_group.add_child(checkbox)
				checkbox.toggled.connect(_set_canoptek_spyder_equipment.bind(model_index, CanoptekSpyders.equipment_field(option), checkbox))
	elif is_canoptek_tomb_crawlers:
		sergeant_rifle_picker.get_parent().visible = false
		for model_index in range(int(item.get("models", 0))):
			var equipment_row := HBoxContainer.new()
			equipment_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			per_model_equipment_controls.add_child(equipment_row)
			label("Tomb Crawler %d" % (model_index + 1), equipment_row)
			var picker := OptionButton.new()
			picker.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			picker.tooltip_text = "Select this miniature's source-listed ranged weapon. Only one Tomb Crawler per unit can take the transdimensional isolator."
			equipment_row.add_child(picker)
			for option: Dictionary in CANOPTEK_TOMB_CRAWLER_OPTIONS:
				picker.add_item(str(option.label))
				picker.set_item_metadata(picker.item_count - 1, str(option.id))
			var loadout := str(Roster.model_equipment(item, copy_index, model_index).get("canoptek_tomb_crawlers_loadout", CanoptekTombCrawlers.GAUSS_REAPER))
			_select_equipment_choice(picker, loadout)
			picker.item_selected.connect(_set_canoptek_tomb_crawler_loadout.bind(model_index, picker))
	elif is_necron_annihilation_barge or is_necron_monolith:
		sergeant_rifle_picker.get_parent().visible = false
		var options: Array = NECRON_ANNIHILATION_BARGE_OPTIONS if is_necron_annihilation_barge else NECRON_MONOLITH_OPTIONS
		var field := "necron_annihilation_barge_loadout" if is_necron_annihilation_barge else "necron_monolith_loadout"
		for model_index in range(int(item.get("models", 0))):
			var equipment_row := HBoxContainer.new()
			equipment_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			per_model_equipment_controls.add_child(equipment_row)
			label("Barge" if is_necron_annihilation_barge else "Monolith", equipment_row)
			var picker := OptionButton.new()
			picker.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			picker.tooltip_text = "Choose the source-listed weapon replacement for this saved Necrons App v1.2 model."
			equipment_row.add_child(picker)
			for option: Dictionary in options:
				picker.add_item(str(option.label))
				picker.set_item_metadata(picker.item_count - 1, str(option.id))
			var equipment := Roster.model_equipment(item, copy_index, model_index)
			_select_equipment_choice(picker, str(equipment.get(field, NecronVehicleLoadouts.default_choice(str(item.unit_id)))))
			picker.item_selected.connect(_set_necron_vehicle_loadout.bind(model_index, picker))
	else:
		sergeant_rifle_picker.clear()
		for option: Dictionary in INTERCESSOR_RIFLE_OPTIONS:
			sergeant_rifle_picker.add_item(str(option.label))
			sergeant_rifle_picker.set_item_metadata(sergeant_rifle_picker.item_count - 1, str(option.id))
		var loadout := Roster.intercessor_sergeant_loadout(item, copy_index)
		_select_equipment_choice(sergeant_rifle_picker, str(loadout.rifle_choice))
		_select_equipment_choice(sergeant_melee_picker, str(loadout.melee_choice))
		var launcher_loadouts := Roster.intercessor_grenade_launcher_loadouts(item, copy_index)
		var launcher_count := 0
		for equipped: bool in launcher_loadouts:
			if equipped: launcher_count += 1
		var launcher_limit := int(int(item.get("models", 0)) / 5.0)
		var helper := Label.new()
		helper.text = "One non-Sergeant per five models may take a Grenade Launcher. %d/%d equipped." % [launcher_count, launcher_limit]
		helper.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		per_model_equipment_controls.add_child(helper)
		for model_index in range(1, int(item.get("models", 0))):
			var checkbox := CheckBox.new()
			checkbox.text = "Intercessor %d · Grenade Launcher" % model_index
			checkbox.tooltip_text = "Save this miniature's Grenade Launcher choice. One model per five models may take it."
			checkbox.button_pressed = launcher_loadouts[model_index]
			checkbox.disabled = not checkbox.button_pressed and launcher_count >= launcher_limit
			if checkbox.disabled: checkbox.tooltip_text = "This unit has reached its Grenade Launcher limit. Remove a checked choice before choosing another model."
			per_model_equipment_controls.add_child(checkbox)
			checkbox.toggled.connect(_set_intercessor_grenade_launcher_from_controls.bind(model_index))

func _set_intercessor_grenade_launcher_from_controls(equipped: bool, model_index: int) -> void:
	if updating or selected_entry_index < 0 or selected_entry_index >= draft.entries.size() or sergeant_loadout_copy_picker.selected < 0: return
	var item: Dictionary = draft.entries[selected_entry_index]
	if not str(item.get("unit_id", "")).ends_with(":intercessor-squad"): return
	var copy_index := int(sergeant_loadout_copy_picker.get_selected_metadata())
	if not Roster.set_intercessor_grenade_launcher(item, copy_index, model_index, equipped):
		if notice != null: notice.text = "The Intercessor Grenade Launcher choice was not changed. Check the squad's per-five-model limit."
		_render_sergeant_loadout_controls(copy_index)
		return
	dirty = true
	save_error = ""
	_preview_entry(item, copy_index * maxi(1, int(item.get("models", 1))) + model_index)
	_render_sergeant_loadout_controls(copy_index)
	_render_visual_slots()
	_render_summary()
	if notice != null: notice.text = "Intercessor %d · Grenade Launcher %s for this miniature. Saved-list matches use this choice without asking again." % [model_index, "equipped" if equipped else "removed"]

func _set_heavy_intercessor_bolter_from_controls(equipped: bool, model_index: int) -> void:
	if updating or selected_entry_index < 0 or selected_entry_index >= draft.entries.size() or sergeant_loadout_copy_picker.selected < 0: return
	var item: Dictionary = draft.entries[selected_entry_index]
	if not str(item.get("unit_id", "")).ends_with(":heavy-intercessor-squad"): return
	var copy_index := int(sergeant_loadout_copy_picker.get_selected_metadata())
	var loadouts := Roster.heavy_intercessor_bolter_loadouts(item, copy_index)
	if model_index <= 0 or model_index >= loadouts.size() or loadouts[model_index] == equipped: return
	if equipped:
		var count := 0
		for current: bool in loadouts:
			if current: count += 1
		if count >= int(int(item.get("models", 0)) / 5.0):
			_render_sergeant_loadout_controls(copy_index)
			if notice != null: notice.text = "This Heavy Intercessor unit has reached its one Heavy Bolter per five models limit."
			return
	Roster.set_model_equipment(item, copy_index, model_index, "heavy_intercessor_bolter", equipped)
	dirty = true
	save_error = ""
	_preview_entry(item, copy_index * maxi(1, int(item.get("models", 1))) + model_index)
	_render_sergeant_loadout_controls(copy_index)
	_render_visual_slots()
	_render_summary()
	if notice != null: notice.text = "Heavy Intercessor %d · Heavy Bolter %s for this miniature. Saved-list matches use this choice without asking again." % [model_index + 1, "equipped" if equipped else "removed"]

func _set_invader_atv_multi_melta_from_controls(equipped: bool, model_index: int) -> void:
	if updating or selected_entry_index < 0 or selected_entry_index >= draft.entries.size() or sergeant_loadout_copy_picker.selected < 0: return
	var item: Dictionary = draft.entries[selected_entry_index]
	if not str(item.get("unit_id", "")).ends_with(":invader-atvs"): return
	var copy_index := int(sergeant_loadout_copy_picker.get_selected_metadata())
	var current := bool(Roster.model_equipment(item, copy_index, model_index).get("invader_atv_multi_melta", false))
	if current == equipped: return
	Roster.set_model_equipment(item, copy_index, model_index, "invader_atv_multi_melta", equipped)
	dirty = true
	save_error = ""
	_preview_entry(item, copy_index * maxi(1, int(item.get("models", 1))) + model_index)
	_render_sergeant_loadout_controls(copy_index)
	_render_visual_slots()
	_render_summary()
	if notice != null: notice.text = "Invader ATV %d · %s saved for this model. This choice adds 5 points; saved-list matches apply it before Deployment." % [model_index + 1, "Multi-melta" if equipped else "Onslaught Gatling Cannon"]

func _set_reiver_equipment_from_controls(equipped: bool, field: String) -> void:
	if updating or selected_entry_index < 0 or selected_entry_index >= draft.entries.size() or sergeant_loadout_copy_picker.selected < 0: return
	var item: Dictionary = draft.entries[selected_entry_index]
	if not str(item.get("unit_id", "")).ends_with(":reiver-squad"): return
	var copy_index := int(sergeant_loadout_copy_picker.get_selected_metadata())
	if not Roster.set_unit_equipment(item, copy_index, field, equipped): return
	dirty = true
	save_error = ""
	var loadout := Roster.unit_equipment(item, copy_index)
	_render_sergeant_loadout_controls(copy_index)
	_render_summary()
	if notice != null:
		var gear: Array[String] = []
		if bool(loadout.reiver_grav_chutes): gear.append("Grav-chutes")
		if bool(loadout.reiver_grapnel_launchers): gear.append("Grapnel Launchers")
		var selected_gear := " + ".join(gear)
		notice.text = "Reiver Squad %d gear saved: %s. Saved-list matches apply it before Deployment." % [copy_index + 1, selected_gear if not selected_gear.is_empty() else "no optional gear"]

func _set_aggressor_boltstorm_from_controls(equipped: bool, model_index: int) -> void:
	if updating or selected_entry_index < 0 or selected_entry_index >= draft.entries.size() or sergeant_loadout_copy_picker.selected < 0: return
	var item: Dictionary = draft.entries[selected_entry_index]
	if not str(item.get("unit_id", "")).ends_with(":aggressor-squad"): return
	var copy_index := int(sergeant_loadout_copy_picker.get_selected_metadata())
	if bool(Roster.model_equipment(item, copy_index, model_index).get("aggressor_boltstorm", false)) == equipped: return
	Roster.set_model_equipment(item, copy_index, model_index, "aggressor_boltstorm", equipped)
	if bool(Roster.model_equipment(item, copy_index, model_index).get("aggressor_boltstorm", false)) != equipped: return
	dirty = true
	save_error = ""
	_preview_entry(item, copy_index * maxi(1, int(item.get("models", 1))) + model_index)
	_render_sergeant_loadout_controls(copy_index)
	_render_visual_slots()
	_render_summary()
	if notice != null:
		var package := "Auto Boltstorm Gauntlets + Fragstorm Grenade Launcher" if equipped else "Flamestorm Gauntlets"
		notice.text = "Aggressor %d in unit %d saved: %s. Saved-list matches apply it before Deployment." % [model_index + 1, copy_index + 1, package]

func _set_scout_gun_from_controls(_selected_option: int, model_index: int, picker: OptionButton) -> void:
	if updating or selected_entry_index < 0 or selected_entry_index >= draft.entries.size() or sergeant_loadout_copy_picker.selected < 0 or picker.selected < 0: return
	var item: Dictionary = draft.entries[selected_entry_index]
	if not str(item.get("unit_id", "")).ends_with(":scout-squad"): return
	var copy_index := int(sergeant_loadout_copy_picker.get_selected_metadata())
	var selected_label := picker.get_item_text(picker.selected)
	var gun := str(picker.get_item_metadata(picker.selected))
	if not Roster.set_scout_gun(item, copy_index, model_index, gun):
		_render_sergeant_loadout_controls(copy_index)
		if notice != null: notice.text = "The Scout weapon was not changed. Check the one-per-five-model specialist limits."
		return
	dirty = true
	save_error = ""
	_preview_entry(item, copy_index * maxi(1, int(item.get("models", 1))) + model_index)
	_render_sergeant_loadout_controls(copy_index)
	_render_visual_slots()
	_render_summary()
	if notice != null: notice.text = "Scout %d weapon saved as %s. Saved-list matches apply it before Deployment." % [model_index + 1, selected_label]

func _set_scout_blade_from_controls(_selected_option: int, picker: OptionButton) -> void:
	if updating or selected_entry_index < 0 or selected_entry_index >= draft.entries.size() or sergeant_loadout_copy_picker.selected < 0 or picker.selected < 0: return
	var item: Dictionary = draft.entries[selected_entry_index]
	if not str(item.get("unit_id", "")).ends_with(":scout-squad"): return
	var copy_index := int(sergeant_loadout_copy_picker.get_selected_metadata())
	var selected_label := picker.get_item_text(picker.selected)
	var blade := str(picker.get_item_metadata(picker.selected))
	if not Roster.set_scout_sergeant_blade(item, copy_index, blade):
		_render_sergeant_loadout_controls(copy_index)
		return
	dirty = true
	save_error = ""
	_preview_entry(item, copy_index * maxi(1, int(item.get("models", 1))))
	_render_sergeant_loadout_controls(copy_index)
	_render_visual_slots()
	_render_summary()
	if notice != null: notice.text = "Scout Sergeant melee weapon saved as %s. Saved-list matches apply it before Deployment." % selected_label

func _select_equipment_choice(picker: OptionButton, choice_id: String) -> void:
	for option_index in range(picker.item_count):
		if str(picker.get_item_metadata(option_index)) == choice_id:
			picker.select(option_index)
			return

func _set_baal_predator_picker(_selected_option: int, field: String, picker: OptionButton) -> void:
	if picker.selected < 0 or sergeant_loadout_copy_picker.selected < 0: return
	var copy_index := int(sergeant_loadout_copy_picker.get_selected_metadata())
	_save_baal_predator_equipment(field, picker.get_selected_metadata(), copy_index)

func _set_baal_predator_optional_weapon(equipped: bool, field: String) -> void:
	if sergeant_loadout_copy_picker.selected < 0: return
	_save_baal_predator_equipment(field, equipped, int(sergeant_loadout_copy_picker.get_selected_metadata()))

func _save_baal_predator_equipment(field: String, value: Variant, copy_index: int) -> void:
	if updating or selected_entry_index < 0 or selected_entry_index >= draft.entries.size(): return
	var item: Dictionary = draft.entries[selected_entry_index]
	if not str(item.get("unit_id", "")).ends_with(":baal-predator"): return
	var current := Roster.model_equipment(item, copy_index, 0)
	if current.get(field, null) == value: return
	Roster.set_model_equipment(item, copy_index, 0, field, value)
	var updated := Roster.model_equipment(item, copy_index, 0)
	if updated.get(field, null) != value: return
	dirty = true
	save_error = ""
	_preview_entry(item, copy_index)
	_render_sergeant_loadout_controls(copy_index)
	_render_visual_slots()
	_render_summary()
	if notice != null: notice.text = "Baal Predator equipment saved for this unit copy. Saved-list matches apply it before Deployment."

func _render_predator_equipment(item: Dictionary, copy_index: int, identity: String) -> void:
	var prefix := identity.replace("-", "_")
	var equipment := Roster.model_equipment(item, copy_index, 0)
	for option: Dictionary in [
		{"field": prefix + "_heavy_bolters", "label": "Replace both sponson Lascannons with Heavy Bolters"},
		{"field": prefix + "_storm_bolter", "label": "Add Storm Bolter"},
		{"field": prefix + "_hunter_killer_missile", "label": "Add Hunter-killer Missile"}
	]:
		var checkbox := CheckBox.new()
		checkbox.text = str(option.label)
		checkbox.tooltip_text = "Update this source-listed option in the draft, then Save the army list. Points follow the local profile."
		checkbox.button_pressed = bool(equipment.get(str(option.field), false))
		per_model_equipment_controls.add_child(checkbox)
		checkbox.toggled.connect(_set_predator_equipment.bind(identity, str(option.field), copy_index))

func _set_predator_equipment(equipped: bool, identity: String, field: String, copy_index: int) -> void:
	if updating or selected_entry_index < 0 or selected_entry_index >= draft.entries.size(): return
	if identity not in ["predator-destructor", "predator-annihilator"]: return
	var item: Dictionary = draft.entries[selected_entry_index]
	if not str(item.get("unit_id", "")).ends_with(":" + identity): return
	var current := Roster.model_equipment(item, copy_index, 0)
	if not current.has(field) or current[field] == equipped: return
	Roster.set_model_equipment(item, copy_index, 0, field, equipped)
	if Roster.model_equipment(item, copy_index, 0).get(field, null) != equipped: return
	dirty = true
	save_error = ""
	_preview_entry(item, copy_index)
	_render_sergeant_loadout_controls(copy_index)
	_render_visual_slots()
	_render_summary()
	if notice != null: notice.text = "Equipment updated in this draft. Save the army list to keep these changes."

func _set_sergeant_loadout_from_controls() -> void:
	if updating or selected_entry_index < 0 or selected_entry_index >= draft.entries.size(): return
	if sergeant_loadout_copy_picker.selected < 0 or sergeant_rifle_picker.selected < 0: return
	var item: Dictionary = draft.entries[selected_entry_index]
	var copy_index := int(sergeant_loadout_copy_picker.get_selected_metadata())
	var rifle_choice := str(sergeant_rifle_picker.get_selected_metadata())
	if str(item.get("unit_id", "")).ends_with(":ravenwing-darkshroud"):
		var prior_cannon := Roster.ravenwing_darkshroud_loadout(item, copy_index)
		if prior_cannon == rifle_choice: return
		Roster.set_model_equipment(item, copy_index, 0, "ravenwing_darkshroud_cannon", rifle_choice)
		dirty = true
		save_error = ""
		_preview_entry(item, copy_index * maxi(1, int(item.get("models", 1))))
		_render_visual_slots()
		_render_summary()
		if notice != null: notice.text = "Darkshroud weapon saved for this unit copy and fixed for saved-list matches."
		return
	if str(item.get("unit_id", "")).ends_with(":land-speeder"):
		var prior_cannon := str(Roster.model_equipment(item, copy_index, 0).get("land_speeder_cannon", "onslaught"))
		if prior_cannon == rifle_choice: return
		Roster.set_model_equipment(item, copy_index, 0, "land_speeder_cannon", rifle_choice)
		dirty = true
		save_error = ""
		_preview_entry(item, copy_index)
		_render_visual_slots()
		_render_summary()
		if notice != null: notice.text = "Land Speeder cannon saved for this unit copy. Saved-list matches use it without asking again."
		return
	if str(item.get("unit_id", "")).ends_with(":land-speeder-vengeance"):
		var prior_cannon := str(Roster.model_equipment(item, copy_index, 0).get("land_speeder_vengeance_cannon", "heavy-bolter"))
		if prior_cannon == rifle_choice: return
		Roster.set_model_equipment(item, copy_index, 0, "land_speeder_vengeance_cannon", rifle_choice)
		dirty = true
		save_error = ""
		_preview_entry(item, copy_index)
		_render_visual_slots()
		_render_summary()
		if notice != null: notice.text = "Land Speeder Vengeance cannon saved for this unit copy. Saved-list matches use it without asking again."
		return
	if str(item.get("unit_id", "")).ends_with(":hellblaster-squad"):
		var prior_pistol := str(Roster.model_equipment(item, copy_index, 0).get("hellblaster_sergeant_pistol", "bolt-pistol"))
		if prior_pistol == rifle_choice: return
		Roster.set_model_equipment(item, copy_index, 0, "hellblaster_sergeant_pistol", rifle_choice)
		dirty = true
		save_error = ""
		_preview_entry(item, copy_index * maxi(1, int(item.get("models", 1))))
		_render_visual_slots()
		_render_summary()
		if notice != null: notice.text = "Hellblaster Sergeant pistol saved for this unit copy. Saved-list matches use it without asking again."
		return
	if str(item.get("unit_id", "")).ends_with(":assault-intercessor-squad"):
		if sergeant_melee_picker.selected < 0: return
		var melee_choice := str(sergeant_melee_picker.get_selected_metadata())
		var equipment := Roster.model_equipment(item, copy_index, 0)
		if str(equipment.get("assault_intercessor_sergeant_pistol", "heavy-bolt-pistol")) == rifle_choice and str(equipment.get("assault_intercessor_sergeant_melee", "chainsword")) == melee_choice: return
		Roster.set_model_equipment(item, copy_index, 0, "assault_intercessor_sergeant_pistol", rifle_choice)
		Roster.set_model_equipment(item, copy_index, 0, "assault_intercessor_sergeant_melee", melee_choice)
		dirty = true
		save_error = ""
		_preview_entry(item, copy_index * maxi(1, int(item.get("models", 1))))
		_render_sergeant_loadout_controls(copy_index)
		_render_visual_slots()
		_render_summary()
		if notice != null: notice.text = "Assault Intercessor Sergeant pistol and melee equipment saved for this unit copy. Saved-list matches use both choices without asking again."
		return
	if str(item.get("unit_id", "")).ends_with(":outrider-squad"):
		var prior_melee := str(Roster.model_equipment(item, copy_index, 0).get("outrider_sergeant_melee", "chainsword"))
		if prior_melee == rifle_choice: return
		Roster.set_model_equipment(item, copy_index, 0, "outrider_sergeant_melee", rifle_choice)
		dirty = true
		save_error = ""
		_preview_entry(item, copy_index * maxi(1, int(item.get("models", 1))))
		_render_visual_slots()
		_render_summary()
		if notice != null: notice.text = "Outrider Sergeant melee weapon saved for this unit copy and fixed for saved-list matches."
		return
	if str(item.get("unit_id", "")).ends_with(":eliminator-squad"):
		var prior_equipment := str(Roster.model_equipment(item, copy_index, 0).get("eliminator_sergeant_ranged", "sniper"))
		if prior_equipment == rifle_choice: return
		Roster.set_model_equipment(item, copy_index, 0, "eliminator_sergeant_ranged", rifle_choice)
		dirty = true
		save_error = ""
		_preview_entry(item, copy_index * maxi(1, int(item.get("models", 1))))
		_render_visual_slots()
		_render_summary()
		if notice != null: notice.text = "Eliminator Sergeant weapon saved for this miniature. Match preparation uses it without asking again."
		return
	if sergeant_melee_picker.selected < 0: return
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
	if notice != null: notice.text = "Sergeant equipment saved for this unit copy and used as its match loadout. Edit the saved list before starting another match."

func _set_outrider_plasma_pistol_from_controls(equipped: bool, model_index: int) -> void:
	if updating or selected_entry_index < 0 or selected_entry_index >= draft.entries.size() or sergeant_loadout_copy_picker.selected < 0: return
	var item: Dictionary = draft.entries[selected_entry_index]
	if not str(item.get("unit_id", "")).ends_with(":outrider-squad"): return
	var copy_index := int(sergeant_loadout_copy_picker.get_selected_metadata())
	var current := Roster.model_equipment(item, copy_index, model_index)
	if bool(current.get("outrider_plasma_pistol", false)) == equipped: return
	if not Roster.set_outrider_plasma_pistol(item, copy_index, model_index, equipped):
		_render_sergeant_loadout_controls(copy_index)
		if notice != null: notice.text = "This Outrider unit has reached its one Plasma Pistol per three models limit."
		return
	dirty = true
	save_error = ""
	var slot := copy_index * maxi(1, int(item.get("models", 1))) + model_index
	_preview_entry(item, slot)
	_render_visual_slots()
	_render_sergeant_loadout_controls(copy_index)
	_render_summary()
	if notice != null: notice.text = "Outrider %d · Plasma Pistol %s for this miniature. Saved-list matches use this choice without asking again." % [model_index + 1, "equipped" if equipped else "removed"]

func _set_eliminator_trooper_from_controls(_selected_option: int, model_index: int, picker: OptionButton) -> void:
	if updating or selected_entry_index < 0 or selected_entry_index >= draft.entries.size() or sergeant_loadout_copy_picker.selected < 0 or picker.selected < 0: return
	var item: Dictionary = draft.entries[selected_entry_index]
	var copy_index := int(sergeant_loadout_copy_picker.get_selected_metadata())
	var choice_id := str(picker.get_selected_metadata())
	var previous := str(Roster.model_equipment(item, copy_index, model_index).get("eliminator_trooper_ranged", "sniper"))
	if previous == choice_id: return
	Roster.set_model_equipment(item, copy_index, model_index, "eliminator_trooper_ranged", choice_id)
	dirty = true
	save_error = ""
	_preview_entry(item, copy_index * maxi(1, int(item.get("models", 1))) + model_index)
	_render_visual_slots()
	_render_summary()
	if notice != null: notice.text = "Eliminator trooper weapon saved for this miniature. Match preparation uses it without asking again."

func _set_inceptor_weapon_from_controls(_selected_option: int, model_index: int, picker: OptionButton) -> void:
	if updating or selected_entry_index < 0 or selected_entry_index >= draft.entries.size() or sergeant_loadout_copy_picker.selected < 0 or picker.selected < 0: return
	var item: Dictionary = draft.entries[selected_entry_index]
	if not str(item.get("unit_id", "")).ends_with(":inceptor-squad"): return
	var copy_index := int(sergeant_loadout_copy_picker.get_selected_metadata())
	var choice_id := str(picker.get_selected_metadata())
	var previous := str(Roster.model_equipment(item, copy_index, model_index).get("inceptor_weapon", "assault-bolters"))
	if previous == choice_id: return
	Roster.set_model_equipment(item, copy_index, model_index, "inceptor_weapon", choice_id)
	dirty = true
	save_error = ""
	var slot := copy_index * maxi(1, int(item.get("models", 1))) + model_index
	_preview_entry(item, slot)
	_render_sergeant_loadout_controls(copy_index)
	_render_visual_slots()
	_render_summary()
	var weapon_name := "Plasma Exterminators" if choice_id == "plasma-exterminators" else "Assault Bolters"
	if notice != null: notice.text = "Inceptor %d · %s saved for this miniature. Saved-list matches use it without asking again." % [model_index + 1, weapon_name]

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
			var split := Roster.split_copy(item, 0)
			if not str(split.get("error", "")).is_empty():
				notice.text = str(split.error)
				return
			var assigned: Dictionary = split.selected
			item = split.remaining
			draft.entries[selected_entry_index] = item
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
	Roster.normalize_copy_instance_ids(item)
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
		unenhanced.copy_instance_ids = []
		if had_sergeant_loadouts: Roster.normalize_intercessor_sergeant_loadouts(unenhanced)
		Roster.normalize_unit_equipment(unenhanced)
		item.copies = 1
		draft.entries.insert(selected_entry_index + 1, unenhanced)
	else: item.copies = next_copies
	if had_sergeant_loadouts: Roster.normalize_intercessor_sergeant_loadouts(item)
	Roster.normalize_unit_equipment(item)
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
	visual_gallery_buttons.clear()
	visual_gallery_context.clear()
	visual_gallery_variants.clear()
	visual_gallery_grid = null
	visual_gallery_scroll = null
	visual_gallery_search = null
	visual_gallery_ready_only = null
	visual_gallery_detail = null
	visual_gallery_unit_target = null
	visual_gallery_model_target = null
	visual_gallery_apply_similar_button = null
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
	var models := maxi(1, int(item.get("models", 1)))
	var model_index := posmod(preview_slot, models)
	var role_label := _visual_model_role_label(item, model_index, copy_index)
	var is_intercessor_sergeant := str(item.get("unit_id", "")).ends_with(":intercessor-squad") and model_index == 0
	visual_gallery_context = {"entry_index": selected_entry_index, "copy_index": copy_index, "model_index": model_index, "item": item}
	visual_gallery_variants = variants.duplicate(true)
	WorkspaceTheme.heading(visual_models, "CHOOSE HOW THIS MODEL LOOKS")
	var target_help := _appearance_detail_label()
	target_help.text = "Unit appearance is shared by this copy. A model override affects only %s; clear it to use the unit appearance and automatic role match." % role_label
	visual_models.add_child(target_help)
	var target_row := HBoxContainer.new()
	visual_models.add_child(target_row)
	visual_gallery_unit_target = Button.new()
	visual_gallery_unit_target.text = "Unit appearance"
	visual_gallery_unit_target.toggle_mode = true
	visual_gallery_unit_target.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	visual_gallery_unit_target.tooltip_text = "Choose the shared appearance used by all models in this unit copy."
	target_row.add_child(visual_gallery_unit_target)
	visual_gallery_unit_target.pressed.connect(_set_visual_gallery_target.bind(0))
	visual_gallery_model_target = Button.new()
	visual_gallery_model_target.text = "This model · %s" % role_label
	visual_gallery_model_target.toggle_mode = true
	visual_gallery_model_target.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	visual_gallery_model_target.tooltip_text = "Choose an optional sculpt override for only this model. Rules equipment stays unchanged."
	target_row.add_child(visual_gallery_model_target)
	visual_gallery_model_target.pressed.connect(_set_visual_gallery_target.bind(1))
	visual_gallery_apply_similar_button = Button.new()
	visual_gallery_apply_similar_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	visual_gallery_apply_similar_button.visible = false
	visual_gallery_apply_similar_button.pressed.connect(_apply_visual_override_to_similar_models)
	visual_models.add_child(visual_gallery_apply_similar_button)
	var gallery_heading := Label.new()
	gallery_heading.text = "Available local looks"
	visual_models.add_child(gallery_heading)
	visual_gallery_detail = _appearance_detail_label()
	visual_models.add_child(visual_gallery_detail)
	visual_gallery_search = LineEdit.new()
	visual_gallery_search.placeholder_text = "Search local looks"
	visual_gallery_search.clear_button_enabled = true
	visual_gallery_search.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var gallery_controls := HBoxContainer.new()
	gallery_controls.add_child(visual_gallery_search)
	visual_gallery_ready_only = CheckBox.new()
	visual_gallery_ready_only.text = "Ready only"
	visual_gallery_ready_only.tooltip_text = "Show only local looks whose files are ready on this computer. Automatic and saved choices stay visible."
	visual_gallery_ready_only.button_pressed = visual_gallery_ready_only_preference
	gallery_controls.add_child(visual_gallery_ready_only)
	visual_models.add_child(gallery_controls)
	visual_gallery_scroll = ScrollContainer.new()
	visual_gallery_scroll.custom_minimum_size.y = 230
	visual_gallery_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	visual_gallery_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	visual_models.add_child(visual_gallery_scroll)
	visual_gallery_grid = GridContainer.new()
	visual_gallery_grid.columns = 2
	visual_gallery_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	visual_gallery_grid.add_theme_constant_override("h_separation", 8)
	visual_gallery_grid.add_theme_constant_override("v_separation", 8)
	visual_gallery_scroll.add_child(visual_gallery_grid)
	visual_gallery_search.text_changed.connect(func(_text: String): _build_visual_gallery(entry_index, copy_index, model_index))
	visual_gallery_ready_only.toggled.connect(func(pressed: bool): _toggle_visual_gallery_ready_only(pressed, entry_index, copy_index, model_index))
	_build_visual_gallery(selected_entry_index, copy_index, model_index)
	if variants.is_empty():
		visual_notice.text = "No local variants are listed yet. The built-in miniature remains available; preparing models is optional."
	elif is_intercessor_sergeant:
		visual_notice.text = "%d catalog variants. Unit %d shares its base appearance; the Sergeant follows its saved equipment sculpt when available, then this fallback." % [variants.size(), copy_index + 1]
	else:
		visual_notice.text = "%d local variants. Unit %d shares a base appearance; %s can use an optional sculpt override." % [variants.size(), copy_index + 1, role_label]

	if reveal_appearance_when_ready:
		reveal_appearance_when_ready = false
		_scroll_to(visual_gallery_unit_target if visual_gallery_target == 0 else visual_gallery_model_target)

func _build_visual_gallery(entry_index: int, copy_index: int, model_index: int) -> void:
	if visual_gallery_grid == null or entry_index != selected_entry_index or visual_gallery_context.is_empty(): return
	for child in visual_gallery_grid.get_children():
		visual_gallery_grid.remove_child(child)
		child.queue_free()
	visual_gallery_buttons.clear()
	var default_button := _visual_gallery_card("Automatic", "Local recommendation", "", entry_index, copy_index, model_index)
	visual_gallery_grid.add_child(default_button)
	visual_gallery_buttons.append(default_button)
	var item: Dictionary = visual_gallery_context.get("item", {})
	var saved_identities := [Roster.unit_visual_variant(item, copy_index), Roster.model_visual_override(item, copy_index, model_index)]
	var listed_identities: Dictionary = {}
	var ready_options: Array[Dictionary] = []
	var pending_options: Array[Dictionary] = []
	var ready_total := 0
	var listed_total := 0
	for variant_index in range(visual_gallery_variants.size()):
		var raw_option: Variant = visual_gallery_variants[variant_index]
		if not raw_option is Dictionary: continue
		var option: Dictionary = raw_option
		var identity := str(option.get("variant_id", ""))
		if identity.is_empty(): continue
		listed_identities[identity] = true
		listed_total += 1
		var is_ready := _visual_gallery_option_ready(option)
		if is_ready: ready_total += 1
		if not _visual_gallery_matches_search(option): continue
		if is_ready: ready_options.append(option)
		else: pending_options.append(option)
	if visual_gallery_ready_only != null:
		visual_gallery_ready_only.text = "Ready only · %d of %d" % [ready_total, listed_total]
	var ready_only := _visual_gallery_ready_only_active()
	var hidden_pending := 0
	var visible_options: Array[Dictionary] = []
	for option: Dictionary in ready_options: visible_options.append(option)
	for option: Dictionary in pending_options:
		if ready_only and not saved_identities.has(str(option.get("variant_id", ""))):
			hidden_pending += 1
			continue
		visible_options.append(option)
	for option: Dictionary in visible_options:
		var identity := str(option.get("variant_id", ""))
		var display_name := str(option.get("name", "Visual variant"))
		if display_name.length() > 34: display_name = display_name.substr(0, 31) + "…"
		if bool(option.get("paint_alternative", false)):
			display_name += " · Texture %d" % int(option.get("paint_index", 0))
		var availability_state := str(option.get("availability", "ready" if bool(option.get("ready", false)) else "download_pending"))
		var availability := "✓ Ready locally"
		match availability_state:
			"downloading": availability = "Preparing now · fallback shown"
			"download_pending": availability = "Needs preparation · fallback shown"
			"conversion_failed": availability = "Preparation failed · fallback shown"
			"missing": availability = "Missing locally · fallback shown"
		var availability_reason := str(option.get("availability_reason", ""))
		var assessment := _appearance_model_match_assessment(option, item, copy_index, model_index)
		var card := _visual_gallery_card(display_name, availability, identity, entry_index, copy_index, model_index, availability_reason, str(assessment.get("confidence", "unverified")), str(assessment.get("rationale", "")))
		visual_gallery_grid.add_child(card)
		visual_gallery_buttons.append(card)
	for saved_identity: Variant in saved_identities:
		var identity := str(saved_identity)
		if identity.is_empty() or listed_identities.has(identity): continue
		listed_identities[identity] = true
		var unavailable := _visual_gallery_card("Saved appearance unavailable", "Preserved · fallback shown", identity, entry_index, copy_index, model_index, "This saved choice is preserved; its local asset is unavailable. Choose another look or prepare the asset again.", "unverified", "The saved candidate is missing from the local catalog.")
		visual_gallery_grid.add_child(unavailable)
		visual_gallery_buttons.append(unavailable)
	_update_visual_gallery_selection()
	var search_active := visual_gallery_search != null and not visual_gallery_search.text.strip_edges().is_empty()
	if visible_options.is_empty() and (search_active or hidden_pending > 0):
		var empty_result := Label.new()
		if hidden_pending > 0:
			empty_result.text = "%d candidate%s need local preparation and are hidden. Clear \"Ready only\" to browse them." % [hidden_pending, "s" if hidden_pending != 1 else ""]
		else:
			empty_result.text = "No local looks match this search. Clear the search to browse all candidates."
		empty_result.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		visual_gallery_grid.add_child(empty_result)
		visual_gallery_grid.columns = 1
	else:
		visual_gallery_grid.columns = 2

func _visual_gallery_option_ready(option: Dictionary) -> bool:
	if bool(option.get("ready", false)): return true
	return str(option.get("availability", "download_pending")) == "ready"

func _visual_gallery_ready_only_active() -> bool:
	return visual_gallery_ready_only != null and visual_gallery_ready_only.button_pressed

func _toggle_visual_gallery_ready_only(pressed: bool, entry_index: int, copy_index: int, model_index: int) -> void:
	visual_gallery_ready_only_preference = pressed
	_build_visual_gallery(entry_index, copy_index, model_index)

func _visual_gallery_matches_search(option: Dictionary) -> bool:
	if visual_gallery_search == null: return true
	var query_text := visual_gallery_search.text.strip_edges().to_lower()
	if query_text.is_empty(): return true
	var searchable := str(option.get("name", "")) + " " + str(option.get("visual_role", "")) + " " + str(option.get("visual_model_role", ""))
	var weapons: Variant = option.get("visual_weapons", [])
	if weapons is Array:
		for weapon: Variant in weapons: searchable += " " + str(weapon)
	return query_text in searchable.to_lower()

func _visual_gallery_card(title: String, status: String, identity: String, entry_index: int, copy_index: int, model_index: int, status_reason: String = "", confidence: String = "", confidence_reason: String = "") -> Button:
	var card := Button.new()
	card.toggle_mode = true
	card.text = "%s\n%s" % [title, status]
	if not confidence.is_empty(): card.text += "\nMatch: " + _appearance_confidence_label(confidence)
	card.custom_minimum_size = Vector2(150, 82)
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	var tooltip_parts: Array[String] = [status_reason if not status_reason.is_empty() else status]
	if not confidence_reason.is_empty():
		tooltip_parts.append("Match confidence: %s — %s This rates local metadata, not exact sculpt parity." % [_appearance_confidence_label(confidence), confidence_reason])
	card.tooltip_text = "\n".join(tooltip_parts)
	card.set_meta("visual_variant_id", identity)
	card.pressed.connect(_apply_visual_gallery_choice.bind(identity, entry_index, copy_index, model_index))
	return card

func _set_visual_gallery_target(target: int) -> void:
	visual_gallery_target = clampi(target, 0, 1)
	_update_visual_gallery_selection()

func _apply_visual_gallery_choice(identity: String, entry_index: int, copy_index: int, model_index: int) -> void:
	if selected_entry_index != entry_index or entry_index < 0 or entry_index >= draft.entries.size(): return
	var item: Dictionary = draft.entries[entry_index]
	var models := maxi(1, int(item.get("models", 1)))
	if copy_index < 0 or copy_index >= int(item.get("copies", 0)) or model_index < 0 or model_index >= models: return
	if visual_gallery_target == 0:
		_set_visual_slot(copy_index * models, identity)
	else:
		_set_model_visual_override(copy_index * models + model_index, identity)
	_update_visual_gallery_selection()

func _update_visual_gallery_selection() -> void:
	if visual_gallery_context.is_empty() or visual_gallery_detail == null: return
	var item: Dictionary = visual_gallery_context.get("item", {})
	var copy_index := int(visual_gallery_context.get("copy_index", 0))
	var model_index := int(visual_gallery_context.get("model_index", 0))
	var mode := Roster.model_visual_selection_mode(item, copy_index, model_index)
	if visual_gallery_unit_target != null: visual_gallery_unit_target.button_pressed = visual_gallery_target == 0
	if visual_gallery_model_target != null:
		visual_gallery_model_target.button_pressed = visual_gallery_target == 1
		visual_gallery_model_target.text = "This model · %s · %s" % [_visual_model_role_label(item, model_index, copy_index), "Manual" if mode == "manual" else "Auto"]
	var identity := Roster.unit_visual_variant(item, copy_index) if visual_gallery_target == 0 else Roster.model_visual_override(item, copy_index, model_index)
	for card: Button in visual_gallery_buttons:
		card.button_pressed = str(card.get_meta("visual_variant_id", "")) == identity
	if visual_gallery_target == 0:
		if not visual_gallery_buttons.is_empty(): visual_gallery_buttons[0].text = "Automatic\nLocal recommendation"
		visual_gallery_detail.text = _model_visual_mode_summary(item, copy_index, model_index) + "\n" + _appearance_rationale(visual_gallery_variants, identity, false, item, copy_index, model_index)
	else:
		if not visual_gallery_buttons.is_empty(): visual_gallery_buttons[0].text = "Use unit look\nAllow role match"
		visual_gallery_detail.text = _model_visual_mode_summary(item, copy_index, model_index) + "\n" + _appearance_rationale(visual_gallery_variants, identity, true, item, copy_index, model_index)
	_update_visual_gallery_apply_button()

func _model_visual_mode_summary(item: Dictionary, copy_index: int, model_index: int) -> String:
	if Roster.model_visual_selection_mode(item, copy_index, model_index) == "manual":
		return "Manual model appearance is saved. If its local asset is unavailable, the game keeps this choice and shows a fallback."
	return "Automatic model appearance is saved. The resolver follows the unit look, equipment/role matches and local fallback order."

func _update_visual_gallery_apply_button() -> void:
	if visual_gallery_apply_similar_button == null: return
	visual_gallery_apply_similar_button.visible = false
	if visual_gallery_target != 1 or visual_gallery_context.is_empty(): return
	var entry_index := int(visual_gallery_context.get("entry_index", -1))
	if entry_index < 0 or entry_index >= draft.entries.size(): return
	var item: Dictionary = draft.entries[entry_index]
	var copy_index := int(visual_gallery_context.get("copy_index", -1))
	var model_index := int(visual_gallery_context.get("model_index", -1))
	var similar := _similar_visual_model_indices(item, copy_index, model_index)
	if similar.is_empty(): return
	var current_override := Roster.model_visual_override(item, copy_index, model_index)
	var plural := "" if similar.size() == 1 else "s"
	if current_override.is_empty():
		visual_gallery_apply_similar_button.text = "Reset %d matching model%s in this copy to unit look" % [similar.size(), plural]
	else:
		visual_gallery_apply_similar_button.text = "Apply this look to %d matching model%s in this copy" % [similar.size(), plural]
	visual_gallery_apply_similar_button.tooltip_text = "Matches the same model role and saved equipment; equipment stays unchanged."
	visual_gallery_apply_similar_button.visible = true

func _similar_visual_model_indices(item: Dictionary, copy_index: int, model_index: int) -> Array[int]:
	var result: Array[int] = []
	var models := int(item.get("models", 0))
	if copy_index < 0 or copy_index >= int(item.get("copies", 0)) or model_index < 0 or model_index >= models: return result
	var selected_key := _visual_similarity_key(item, copy_index, model_index)
	if selected_key.is_empty(): return result
	for candidate_index in range(models):
		if candidate_index == model_index: continue
		if _visual_similarity_key(item, copy_index, candidate_index) == selected_key:
			result.append(candidate_index)
	return result

func _visual_similarity_key(item: Dictionary, copy_index: int, model_index: int) -> String:
	var definition := str(item.get("unit_id", ""))
	var role := Roster.model_equipment_role(item, copy_index, model_index)
	if role.is_empty(): return ""
	var equipment := Roster.model_equipment(item, copy_index, model_index)
	if equipment.is_empty(): return ""
	var equipment_keys: Array = equipment.keys()
	equipment_keys.sort()
	var parts: Array[String] = [definition, role]
	for key: Variant in equipment_keys:
		parts.append("%s=%s" % [str(key), str(equipment[key])])
	return "|".join(parts)

func _apply_visual_override_to_similar_models() -> void:
	if visual_gallery_target != 1 or visual_gallery_context.is_empty(): return
	var entry_index := int(visual_gallery_context.get("entry_index", -1))
	if entry_index < 0 or entry_index >= draft.entries.size(): return
	var item: Dictionary = draft.entries[entry_index]
	var copy_index := int(visual_gallery_context.get("copy_index", -1))
	var model_index := int(visual_gallery_context.get("model_index", -1))
	var similar := _similar_visual_model_indices(item, copy_index, model_index)
	if similar.is_empty(): return
	var models := int(item.get("models", 0))
	var visual_id := Roster.model_visual_override(item, copy_index, model_index)
	var changed := false
	for similar_model_index: int in similar:
		if Roster.model_visual_override(item, copy_index, similar_model_index) == visual_id: continue
		Roster.set_model_visual_override(item, copy_index, similar_model_index, visual_id)
		changed = true
	if not changed: return
	save_error = ""
	dirty = true
	_preview_entry(item, copy_index * models + model_index)
	_render_summary()
	_update_visual_gallery_selection()

func _appearance_detail_label() -> Label:
	var detail := Label.new()
	detail.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	detail.add_theme_font_size_override("font_size", 11)
	detail.add_theme_color_override("font_color", Color("aab4bb"))
	return detail

func _appearance_rationale(variants: Array, identity: String, model_override: bool, item: Dictionary = {}, copy_index: int = 0, model_index: int = 0) -> String:
	if identity.is_empty():
		if model_override:
			return "Automatic sculpt · this miniature inherits its unit appearance. A reviewed equipment or role match may select a more specific local sculpt."
		return "Automatic unit appearance · follows the local unit match or saved army palette. Models inherit it unless given a per-model override."
	for raw_option: Variant in variants:
		if not raw_option is Dictionary: continue
		var option: Dictionary = raw_option
		if str(option.get("variant_id", "")) != identity: continue
		var description := str(option.get("name", "Visual variant"))
		if bool(option.get("ready", false)):
			description += " · files ready on this computer"
		else:
			description += " · needs local preparation; a fallback stays visible until then"
		var hints: Array[String] = []
		var weapons: Variant = option.get("visual_weapons", [])
		if weapons is Array and not weapons.is_empty():
			var weapon_labels: Array[String] = []
			for weapon: Variant in weapons: weapon_labels.append(str(weapon))
			hints.append("catalog equipment hints: " + ", ".join(weapon_labels))
		var role := str(option.get("visual_model_role", option.get("visual_role", "")))
		if role.is_empty(): role = str(option.get("visual_role", ""))
		if not role.is_empty(): hints.append("catalog role hint: " + role)
		if hints.is_empty():
			description += " · no equipment or model-role mapping is recorded; compatibility is unverified"
		else:
			description += " · " + "; ".join(hints) + " (visual metadata only)"
		var model_assessment := _appearance_model_match_assessment(option, item, copy_index, model_index)
		var confidence := str(model_assessment.get("confidence", "unverified"))
		description += " · Match confidence: %s — %s This rates local metadata coverage, not exact sculpt parity" % [_appearance_confidence_label(confidence), str(model_assessment.get("rationale", "No supported comparison is available."))]
		description += ". Appearance does not change saved equipment, points, rules or match state."
		return description
	return "This saved appearance is missing from the current local catalog. Match confidence: Unverified. The assignment is preserved; an available sculpt or built-in placeholder is shown."

func _appearance_model_match_rationale(option: Dictionary, item: Dictionary, copy_index: int, model_index: int) -> String:
	return str(_appearance_model_match_assessment(option, item, copy_index, model_index).get("rationale", ""))

func _appearance_model_match_assessment(option: Dictionary, item: Dictionary, copy_index: int, model_index: int) -> Dictionary:
	if item.is_empty(): return _visual_match_assessment("unverified", "No saved unit and model context is available for comparison.")
	var definition := str(item.get("unit_id", ""))
	if SavedEquipment.supports(definition):
		var role_unit := {"definition_id": definition}
		SavedEquipment.prepare(role_unit, definition, Roster.model_equipment(item, copy_index, model_index), int(item.models), model_index)
		return _equipment_match_assessment(option, definition, role_unit, "Saved equipment", "source-listed weapon package")
	var catalog_role := str(option.get("visual_role", ""))
	if catalog_role.is_empty(): catalog_role = str(option.get("visual_model_role", ""))
	if definition.ends_with(":intercessor-squad") and model_index == 0:
		var loadout := Roster.intercessor_sergeant_loadout(item, copy_index)
		var role_unit := {"definition_id": definition, "sergeant": true, "intercessor_rifle_choice": str(loadout.get("rifle_choice", "bolt-rifle")), "intercessor_melee_choice": str(loadout.get("melee_choice", "knives-and-fists"))}
		var expected_role := ForceOrgMatcher.intercessor_sergeant_visual_role(role_unit)
		if catalog_role == expected_role:
			return _visual_match_assessment("strong", "reviewed visual role matches this Sergeant's saved equipment")
		if catalog_role.begins_with("intercessor-sergeant:"):
			return _visual_match_assessment("conflict", "reviewed Sergeant visual mapping is for a different saved loadout")
		return _visual_match_assessment("unverified", "this Sergeant's saved rifle and melee combination has no matching role recorded here")
	if definition.ends_with(":hellblaster-squad") and model_index == 0:
		var choice_id := str(Roster.model_equipment(item, copy_index, model_index).get("hellblaster_sergeant_pistol", "bolt-pistol"))
		var weapon_name := "Plasma Pistol" if choice_id == "plasma-pistol" else "Bolt Pistol"
		var profile := CurrentMarines.profile("hellblaster-squad")
		var ranged: Array = profile.get("ranged", []).duplicate(true)
		if ranged.size() == 2: ranged[1] = CurrentMarines.hellblaster_pistol(choice_id == "plasma-pistol")
		var role_unit := {"definition_id": definition, "sergeant": true, "ranged_weapons": ranged, "melee_weapons": profile.get("melee", []).duplicate(true)}
		return _equipment_match_assessment(option, definition, role_unit, "Hellblaster Sergeant", weapon_name)
	if definition.ends_with(":assault-intercessor-squad") and model_index == 0:
		var equipment := Roster.model_equipment(item, copy_index, model_index)
		var pistol_choice := str(equipment.get("assault_intercessor_sergeant_pistol", "heavy-bolt-pistol"))
		var melee_choice := str(equipment.get("assault_intercessor_sergeant_melee", "chainsword"))
		var pistol_name: String = str({"heavy-bolt-pistol": "Heavy Bolt Pistol", "hand-flamer": "Hand Flamer", "plasma-pistol": "Plasma Pistol"}.get(pistol_choice, "Unresolved pistol"))
		var melee_name: String = str({"chainsword": "Chainsword", "power-fist": "Power Fist", "power-weapon": "Power Weapon", "thunder-hammer": "Thunder Hammer"}.get(melee_choice, "Unresolved melee weapon"))
		var role_unit := {"definition_id": definition, "sergeant": true, "ranged_weapons": [CurrentMarines.assault_intercessor_sergeant_pistol(pistol_choice)], "melee_weapons": [CurrentMarines.assault_intercessor_sergeant_melee(melee_choice)]}
		return _equipment_match_assessment(option, definition, role_unit, "Assault Intercessor Sergeant", "%s and %s" % [pistol_name, melee_name])
	if definition.ends_with(":heavy-intercessor-squad") and model_index > 0:
		var equipment := Roster.model_equipment(item, copy_index, model_index)
		var equipped := bool(equipment.get("heavy_intercessor_bolter", false))
		var profile := CurrentMarines.profile("heavy-intercessor-squad")
		var ranged: Array = profile.get("ranged", []).duplicate(true)
		if equipped:
			var alternatives: Array = profile.get("additional_weapon_profiles", {}).get("ranged", [])
			if alternatives.size() == 1 and str(alternatives[0].get("id", "")) == "heavy-bolter":
				ranged = ranged.filter(func(weapon: Dictionary) -> bool: return str(weapon.get("id", "")) != "heavy-bolt-rifle")
				ranged.append(alternatives[0].duplicate(true))
		var role_unit := {"definition_id": definition, "sergeant": false, "ranged_weapons": ranged, "melee_weapons": profile.get("melee", []).duplicate(true)}
		var weapon_name := "Heavy Bolter" if equipped else "Heavy Bolt Rifle"
		return _equipment_match_assessment(option, definition, role_unit, "Heavy Intercessor", weapon_name)
	if definition.ends_with(":intercessor-squad") and model_index > 0:
		var equipment := Roster.model_equipment(item, copy_index, model_index)
		if not bool(equipment.get("intercessor_grenade_launcher", false)):
			return _visual_match_assessment("unverified", "No supported model-specific equipment comparison is available for this Intercessor.")
		if catalog_role == ForceOrgMatcher.INTERCESSOR_GRENADIER_ROLE:
			return _visual_match_assessment("strong", "reviewed visual role matches this miniature's saved Grenade Launcher")
		if catalog_role.begins_with("intercessor-model:"):
			return _visual_match_assessment("conflict", "reviewed Intercessor role mapping does not match this miniature's saved Grenade Launcher")
		return _visual_match_assessment("unverified", "this miniature's saved Grenade Launcher has no matching role recorded here")
	if definition.ends_with(":eliminator-squad"):
		var equipment := Roster.model_equipment(item, copy_index, model_index)
		var choice_id := str(equipment.get("eliminator_sergeant_ranged", "sniper")) if model_index == 0 else str(equipment.get("eliminator_trooper_ranged", "sniper"))
		var weapon_label := str(Roster.ELIMINATOR_SERGEANT_WEAPONS.get(choice_id, "Bolt Sniper Rifle"))
		var role_unit := {"definition_id": definition, "sergeant": model_index == 0, "ranged_weapons": [CurrentMarines.eliminator_gun(choice_id)], "melee_weapons": []}
		return _equipment_match_assessment(option, definition, role_unit, "Eliminator model", weapon_label)
	if definition.ends_with(":outrider-squad"):
		var equipment := Roster.model_equipment(item, copy_index, model_index)
		var has_plasma := bool(equipment.get("outrider_plasma_pistol", false))
		var melee_choice := str(equipment.get("outrider_sergeant_melee", "chainsword")) if model_index == 0 else "chainsword"
		var weapons := CurrentMarines.outrider_weapons(has_plasma, melee_choice)
		var role_unit := {"definition_id": definition, "sergeant": model_index == 0, "ranged_weapons": weapons.ranged, "melee_weapons": weapons.melee}
		return _equipment_match_assessment(option, definition, role_unit, "Outrider", "saved weapon package")
	if definition.ends_with(":ravenwing-darkshroud"):
		var cannon_choice := Roster.ravenwing_darkshroud_loadout(item, copy_index)
		var profile := CurrentMarines.profile("ravenwing-darkshroud")
		var ranged: Array = profile.get("ranged", []).duplicate(true)
		if cannon_choice == "assault-cannon":
			ranged = ranged.filter(func(weapon: Dictionary) -> bool: return str(weapon.get("id", "")) != "heavy-bolter")
			var additional: Array = profile.get("additional_weapon_profiles", {}).get("ranged", [])
			if additional.size() == 1: ranged.append(additional[0].duplicate(true))
		var role_unit := {"definition_id": definition, "ranged_weapons": ranged, "melee_weapons": profile.get("melee", []).duplicate(true)}
		var weapon_name := "Assault Cannon" if cannon_choice == "assault-cannon" else "Heavy Bolter"
		return _equipment_match_assessment(option, definition, role_unit, "Darkshroud", weapon_name)
	if definition.ends_with(":land-speeder"):
		var cannon_choice := str(Roster.model_equipment(item, copy_index, model_index).get("land_speeder_cannon", "onslaught"))
		var profile := CurrentMarines.profile("land-speeder")
		var ranged: Array = profile.get("ranged", []).duplicate(true)
		if cannon_choice == "pyrecannon":
			ranged = ranged.filter(func(weapon: Dictionary) -> bool: return str(weapon.get("id", "")) != "onslaught-gatling-cannon")
			var additional: Array = profile.get("additional_weapon_profiles", {}).get("ranged", [])
			if additional.size() == 1: ranged.append(additional[0].duplicate(true))
		var role_unit := {"definition_id": definition, "model_role": "land-speeder", "ranged_weapons": ranged, "melee_weapons": profile.get("melee", []).duplicate(true)}
		var weapon_name := "Pyrecannon" if cannon_choice == "pyrecannon" else "Onslaught Gatling Cannon"
		return _equipment_match_assessment(option, definition, role_unit, "Land Speeder", weapon_name)
	if definition.ends_with(":land-speeder-vengeance"):
		var cannon_choice := str(Roster.model_equipment(item, copy_index, model_index).get("land_speeder_vengeance_cannon", "heavy-bolter"))
		var profile := CurrentMarines.profile("land-speeder-vengeance")
		var ranged: Array = profile.get("ranged", []).duplicate(true)
		if cannon_choice == "assault-cannon":
			ranged = ranged.filter(func(weapon: Dictionary) -> bool: return str(weapon.get("id", "")) != "heavy-bolter")
			var additional: Array = profile.get("additional_weapon_profiles", {}).get("ranged", [])
			if additional.size() == 1: ranged.append(additional[0].duplicate(true))
		var role_unit := {"definition_id": definition, "model_role": "land-speeder-vengeance", "ranged_weapons": ranged, "melee_weapons": profile.get("melee", []).duplicate(true)}
		var weapon_name := "Assault Cannon" if cannon_choice == "assault-cannon" else "Heavy Bolter"
		return _equipment_match_assessment(option, definition, role_unit, "Land Speeder Vengeance", weapon_name)
	if definition.ends_with(":baal-predator"):
		var equipment := Roster.model_equipment(item, copy_index, model_index)
		var primary := str(equipment.get("baal_predator_primary_cannon", "twin-assault-cannon"))
		var sponsons := str(equipment.get("baal_predator_sponson_package", "none"))
		var storm_bolter := bool(equipment.get("baal_predator_storm_bolter", false))
		var missile := bool(equipment.get("baal_predator_hunter_killer_missile", false))
		var profile := CurrentMarines.profile("baal-predator")
		var ranged := CurrentMarines.baal_predator_weapons(primary, sponsons, storm_bolter, missile)
		if ranged.is_empty(): return _visual_match_assessment("unverified", "The saved Baal Predator package does not resolve to the local weapon profiles.")
		var role_unit := {"definition_id": definition, "model_role": "baal-predator", "ranged_weapons": ranged, "melee_weapons": profile.get("melee", []).duplicate(true)}
		var loadout := "%s; %s%s%s" % [primary, sponsons, "; Storm Bolter" if storm_bolter else "", "; Hunter-killer Missile" if missile else ""]
		return _equipment_match_assessment(option, definition, role_unit, "Baal Predator", loadout)
	if definition.ends_with(":predator-destructor"):
		var equipment := Roster.model_equipment(item, copy_index, model_index)
		var heavy_bolters := bool(equipment.get("predator_destructor_heavy_bolters", false))
		var missile := bool(equipment.get("predator_destructor_hunter_killer_missile", false))
		var storm_bolter := bool(equipment.get("predator_destructor_storm_bolter", false))
		var profile := CurrentMarines.profile("predator-destructor")
		var weapons := CurrentMarines.predator_destructor_weapons(heavy_bolters, missile, storm_bolter)
		if weapons.is_empty(): return _visual_match_assessment("unverified", "The saved Predator Destructor package does not resolve to the local weapon profiles.")
		var role_unit := {"definition_id": definition, "model_role": "predator-destructor", "ranged_weapons": weapons.ranged, "melee_weapons": weapons.melee}
		var loadout := "%s%s%s" % ["two Heavy Bolters" if heavy_bolters else "two Lascannons", "; Storm Bolter" if storm_bolter else "", "; Hunter-killer Missile" if missile else ""]
		return _equipment_match_assessment(option, definition, role_unit, "Predator Destructor", loadout)
	if definition.ends_with(":predator-annihilator"):
		var equipment := Roster.model_equipment(item, copy_index, model_index)
		var heavy_bolters := bool(equipment.get("predator_annihilator_heavy_bolters", false))
		var missile := bool(equipment.get("predator_annihilator_hunter_killer_missile", false))
		var storm_bolter := bool(equipment.get("predator_annihilator_storm_bolter", false))
		var profile := CurrentMarines.profile("predator-annihilator")
		var weapons := CurrentMarines.predator_annihilator_weapons(heavy_bolters, missile, storm_bolter)
		if weapons.is_empty(): return _visual_match_assessment("unverified", "The saved Predator Annihilator package does not resolve to the local weapon profiles.")
		var role_unit := {"definition_id": definition, "model_role": "predator-annihilator", "ranged_weapons": weapons.ranged, "melee_weapons": weapons.melee}
		var loadout := "%s%s%s" % ["two Heavy Bolters" if heavy_bolters else "two Lascannons", "; Storm Bolter" if storm_bolter else "", "; Hunter-killer Missile" if missile else ""]
		return _equipment_match_assessment(option, definition, role_unit, "Predator Annihilator", loadout)
	if definition.ends_with(":invader-atvs"):
		var multi_melta := bool(Roster.model_equipment(item, copy_index, model_index).get("invader_atv_multi_melta", false))
		var weapons := CurrentMarines.invader_atv_weapons(multi_melta)
		var role_unit := {"definition_id": definition, "model_role": "invader-atv", "ranged_weapons": weapons, "melee_weapons": []}
		var weapon_name := "Multi-melta" if multi_melta else "Onslaught Gatling Cannon"
		return _equipment_match_assessment(option, definition, role_unit, "Invader ATV", weapon_name)
	if definition.ends_with(":inceptor-squad"):
		var weapon_choice := str(Roster.model_equipment(item, copy_index, model_index).get("inceptor_weapon", "assault-bolters"))
		var profile := CurrentMarines.profile("inceptor-squad")
		var ranged: Array = profile.get("ranged", []).duplicate(true) if weapon_choice == "assault-bolters" else profile.get("additional_weapon_profiles", {}).get("ranged", []).duplicate(true)
		var weapon_name := "Plasma Exterminators" if weapon_choice == "plasma-exterminators" else "Assault Bolters"
		if ranged.is_empty(): return _visual_match_assessment("unverified", "The selected %s profile is not available in the local source." % weapon_name)
		var role_unit := {"definition_id": definition, "sergeant": model_index == 0, "ranged_weapons": ranged, "melee_weapons": profile.get("melee", []).duplicate(true)}
		return _equipment_match_assessment(option, definition, role_unit, "Inceptor", weapon_name)
	return _visual_match_assessment("unverified", "No supported model/loadout comparison is available for this candidate.")

func _equipment_match_assessment(option: Dictionary, definition: String, unit: Dictionary, subject: String, loadout: String) -> Dictionary:
	var assessment := ForceOrgMatcher.equipment_visual_assessment(option, definition, unit)
	var confidence := str(assessment.get("confidence", "unverified"))
	var matched_list: Variant = assessment.get("matched_weapons", [])
	var configured_list: Variant = assessment.get("configured_weapons", [])
	var matched: int = matched_list.size() if matched_list is Array else 0
	var configured: int = configured_list.size() if configured_list is Array else 0
	var rationale := ""
	match confidence:
		"strong": rationale = "catalog equipment hints match this %s's saved %s (%d/%d configured weapon labels)" % [subject, loadout, matched, configured]
		"partial": rationale = "catalog equipment hints match this %s's saved %s in part (%d/%d configured weapon labels)" % [subject, loadout, matched, configured]
		"role_only": rationale = "model-role hint matches this %s; its saved %s is not confirmed by weapon hints" % [subject, loadout]
		"conflict": rationale = "recorded role or equipment hints conflict with this %s's saved %s" % [subject, loadout]
		_: rationale = "this %s's saved %s has no matching catalog hint" % [subject, loadout]
	assessment.rationale = rationale
	return assessment

func _visual_match_assessment(confidence: String, rationale: String) -> Dictionary:
	return {"confidence": confidence, "rationale": rationale, "coverage": 0.0, "matched_weapons": [], "configured_weapons": []}

func _appearance_confidence_label(confidence: String) -> String:
	match confidence:
		"strong": return "Strong"
		"partial": return "Partial"
		"role_only": return "Role only"
		"conflict": return "Conflict"
		_: return "Unverified"

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
	var models := int(item.get("models", 0))
	if models <= 0: return
	Roster.set_model_visual_override(item, floori(float(slot) / float(models)), posmod(slot, models), variant_id)
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
		var default_equipment_cost := Roster.default_equipment_points(str(selected_unit.id), int(option.models))
		var price_text := "%d pts" % (int(option.cost) + default_equipment_cost) if option.cost != null else "cost unconfirmed"
		if option.has("second_plus_cost") and option.cost != null and int(option.second_plus_cost) != int(option.cost): price_text += " · 2nd+ %d pts" % (int(option.second_plus_cost) + default_equipment_cost)
		if option.has("third_plus_cost") and option.cost != null and int(option.third_plus_cost) != int(option.get("second_plus_cost", option.cost)): price_text += " · 3rd+ %d pts" % (int(option.third_plus_cost) + default_equipment_cost)
		if option.has("fourth_plus_cost") and option.cost != null and int(option.fourth_plus_cost) != int(option.get("third_plus_cost", option.cost)): price_text += " · 4th+ %d pts" % (int(option.fourth_plus_cost) + default_equipment_cost)
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

func _set_registered_equipment(_index: int, definition: String, field: String, copy_index: int, picker: OptionButton, model_index: int = 0) -> void:
	if updating or selected_entry_index < 0 or selected_entry_index >= draft.entries.size(): return
	var item: Dictionary = draft.entries[selected_entry_index]
	if str(item.unit_id) != definition or not SavedEquipment.supports(definition): return
	var value: Variant = picker.get_selected_metadata()
	if definition == "40kdc:11e:adeptus-astartes:lieutenant" and field == "lieutenant_weapon_package" and str(value) != "neo-volkite":
		Roster.set_model_equipment(item, copy_index, 0, "lieutenant_storm_shield", false)
	var applied := Roster.set_model_equipment(item, copy_index, model_index, field, value)
	if not applied:
		_render_sergeant_loadout_controls(copy_index)
		if notice != null: notice.text = "That equipment choice exceeds a source-listed limit or does not match this model."
		return
	dirty = true
	_preview_entry(item, copy_index)
	_render_sergeant_loadout_controls(copy_index)
	_render_visual_slots()
	_render_summary()
	if notice != null: notice.text = "%s equipment updated in this draft. Save the army list to keep these changes." % str(item.get("name", "Unit"))

func _set_registered_unit_equipment(equipped: bool, definition: String, field: String, copy_index: int) -> void:
	if updating or selected_entry_index < 0 or selected_entry_index >= draft.entries.size(): return
	var item: Dictionary = draft.entries[selected_entry_index]
	if str(item.unit_id) != definition or not SavedEquipment.supports_unit(definition): return
	if not Roster.set_unit_equipment(item, copy_index, field, equipped): return
	dirty = true
	save_error = ""
	_render_sergeant_loadout_controls(copy_index)
	_render_summary()
	if notice != null: notice.text = "Unit equipment saved for this copy. Saved-list matches apply it before Deployment."
