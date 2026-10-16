extends VBoxContainer
const Roster = preload("res://scripts/army_roster.gd")
const Profiles = preload("res://scripts/army_profiles.gd")
const Catalog = preload("res://scripts/army_catalog.gd")
const Training = preload("res://scripts/edition_11/training_roster.gd")
signal library_changed
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

func label(text: String, parent: Node = null) -> Label:
	if parent == null: parent = self
	var control := Label.new()
	control.text = text
	control.custom_minimum_size.x = 400
	control.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	parent.add_child(control)
	return control

func button(text: String, action: Callable, parent: Node = null) -> Button:
	if parent == null: parent = self
	var control := Button.new()
	control.text = text
	control.pressed.connect(action)
	parent.add_child(control)
	return control

func row() -> HBoxContainer:
	var control := HBoxContainer.new()
	add_child(control)
	return control

func _ready() -> void:
	store = Profiles.new(storage_path)
	source = Catalog.new()
	source.cache_directory = cache_directory
	add_child(source)
	draft = Roster.new_list("11e", "")
	label("MY ARMIES")
	label("Build lists and save them to your local profile. Compatible lists can be used for partial training in Match Setup.")
	catalog_status = label("")
	var updates := row()
	refresh_button = button("Refresh online catalog", source.refresh, updates)
	cancel_button = button("Cancel", source.cancel, updates)
	var library_toggle := CheckButton.new()
	library_toggle.text = "Profiles and saved lists"
	add_child(library_toggle)
	library = VBoxContainer.new()
	add_child(library)
	library.visible = false
	library_toggle.toggled.connect(func(value: bool): library.visible = value)
	label("Local profile", library)
	profile_picker = OptionButton.new()
	library.add_child(profile_picker)
	profile_picker.item_selected.connect(_select_profile)
	profile_name = LineEdit.new()
	profile_name.placeholder_text = "Name for a new profile"
	profile_name.max_length = 80
	library.add_child(profile_name)
	button("Create profile", _create_profile, library)
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
	add_child(name_input)
	name_input.text_changed.connect(func(_text: String): _changed())
	var selectors := row()
	edition_picker = OptionButton.new()
	for edition in Roster.EDITIONS: edition_picker.add_item(edition)
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
	add_child(faction_picker)
	faction_picker.item_selected.connect(_faction_selected)
	allies = CheckBox.new()
	allies.text = "Allow other factions (custom list)"
	add_child(allies)
	allies.toggled.connect(func(_value: bool): _changed(); _filter_units())
	summary_label = label("")
	var saves := row()
	save_button = button("Save list", _save, saves)
	button("Save a copy", _save_copy, saves)
	button("New empty list", _new_empty)
	button("New editable standard base", _new_standard)
	button("New training-compatible list", _new_training)
	button("New mixed reference army", _new_reference)
	button("Check training compatibility", _check_training)
	button("Find / add units ↓", func(): _scroll_to(add_button))
	label("List units")
	entries = ItemList.new()
	entries.custom_minimum_size.y = 140
	add_child(entries)
	button("Remove selected entry", _remove)
	button("Recalculate costs from current catalog", _reprice)
	notes = TextEdit.new()
	notes.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY
	notes.placeholder_text = "Notes / planned equipment"
	notes.custom_minimum_size.y = 70
	add_child(notes)
	notes.text_changed.connect(_changed)
	label("CHOOSE UNITS")
	query = LineEdit.new()
	query.placeholder_text = "Search units by name"
	add_child(query)
	query.text_changed.connect(func(_text: String): _filter_units())
	role_picker = OptionButton.new()
	for text in ["All categories", "Character", "Battleline", "Dedicated transport", "Other units"]: role_picker.add_item(text)
	add_child(role_picker)
	role_picker.item_selected.connect(func(_index: int): _filter_units())
	unit_picker = ItemList.new()
	unit_picker.custom_minimum_size.y = 190
	add_child(unit_picker)
	unit_picker.item_selected.connect(_select_unit)
	choice_picker = OptionButton.new()
	add_child(choice_picker)
	var additions := row()
	copies = SpinBox.new()
	copies.min_value = 1
	copies.max_value = 20
	copies.step = 1
	additions.add_child(copies)
	add_button = button("Add unit(s)", _add, additions)
	catalog_totals = label("")
	button("↑ Back to list and save", func(): _scroll_to(summary_label))
	label("Costs are API references, not an official validation of detachments, allies, or equipment. Chapters also use the shared Space Marines catalog. Missing costs are marked in the draft.")
	source.changed.connect(_catalog_changed)
	_render_profiles()
	_render_draft()
	source.select_edition("11e")

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
	_render_summary()

func _render_summary() -> void:
	var totals := Roster.summary(draft)
	summary_label.text = "%d / %d pts • %d units%s" % [totals.points, draft.points_limit, totals.units, " • unsaved" if dirty or draft.id.is_empty() else ""]
	if totals.unknown > 0: summary_label.text += "\n%d unit(s) without confirmed costs; total is partial." % totals.unknown
	elif totals.remaining < 0: summary_label.text += "\nOver the limit by %d pts; you can save as a draft." % -totals.remaining
	else: summary_label.text += "\nRestam %d pts." % totals.remaining
	if draft.get("pricing_source", "") == "starter-training-v1": summary_label.text += "\nCosts use the pinned training pack."
	elif not source.catalog.is_empty() and not draft.catalog_digest.is_empty() and draft.catalog_digest != source.catalog.digest:
		summary_label.text += "\nCatalog changed: explicitly recalculate to update costs."
	if catalog_totals != null: catalog_totals.text = summary_label.text
	save_button.disabled = not store.error.is_empty() or not Roster.validate(draft).is_empty()

func _scroll_to(control: Control) -> void:
	var ancestor: Node = get_parent()
	while ancestor != null:
		if ancestor is ScrollContainer:
			ancestor.ensure_control_visible(control)
			return
		ancestor = ancestor.get_parent()

func _render_draft() -> void:
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
	for item: Dictionary in draft.entries:
		var origin := "training" if item.unit_id.begins_with("40kdc:11e:") else "API"
		entries.add_item("%d× %s • %s • %s" % [item.copies, item.name, "%d models (%s)" % [item.models, origin] if item.models > 0 else "composition pending", "%d pts" % (int(item.cost) * int(item.copies)) if item.cost != null else "cost pending"])
	updating = false
	_fill_factions()
	_render_summary()

func _render_profiles() -> void:
	profile_picker.clear()
	for profile: Dictionary in store.data.profiles:
		profile_picker.add_item(profile.name)
		profile_picker.set_item_metadata(profile_picker.item_count - 1, profile.id)
		if profile.id == store.data.active: profile_picker.select(profile_picker.item_count - 1)
	saved_picker.clear()
	for list: Dictionary in store.active().lists:
		saved_picker.add_item("%s • %d/%d pts" % [list.name, Roster.summary(list).points, list.points_limit])
		saved_picker.set_item_metadata(saved_picker.item_count - 1, list.id)
		if list.id == draft.id: saved_picker.select(saved_picker.item_count - 1)

func _select_profile(index: int) -> void:
	if source.busy:
		notice.text = "Cancel the refresh before switching profiles."
		_render_profiles()
		return
	_sync()
	drafts[store.data.active] = draft.duplicate(true)
	var error: String = store.select_profile(profile_picker.get_item_metadata(index))
	if not error.is_empty():
		notice.text = error
		_render_profiles()
		return
	draft = drafts.get(store.data.active, Roster.new_list(source.edition, "")).duplicate(true)
	dirty = true
	_render_profiles()
	if source.edition != draft.edition: source.select_edition(draft.edition)
	_render_draft()
	notice.text = "Active profile: " + store.active().name

func _create_profile() -> void:
	_sync()
	drafts[store.data.active] = draft.duplicate(true)
	var error: String = store.create_profile(profile_name.text)
	if not error.is_empty():
		notice.text = error
		return
	profile_name.clear()
	draft = Roster.new_list(source.edition, "")
	dirty = false
	_render_profiles()
	_render_draft()
	notice.text = "Local profile created."

func _load_list() -> void:
	if source.busy:
		notice.text = "Cancel the refresh before loading another list."
		return
	if saved_picker.item_count == 0: return
	for list: Dictionary in store.active().lists:
		if list.id == saved_picker.get_selected_metadata():
			draft = list.duplicate(true)
			dirty = false
			if source.edition != draft.edition: source.select_edition(draft.edition)
			_render_draft()
			notice.text = "List loaded with its saved costs."
			return

func _save() -> bool:
	_sync()
	var saved: Dictionary = store.save_list(draft)
	notice.text = saved.error
	if not saved.error.is_empty(): return false
	draft = saved.list
	dirty = false
	_render_profiles()
	_render_summary()
	notice.text = "List saved to profile " + store.active().name + "."
	library_changed.emit()
	return true

func _save_copy() -> void:
	_sync()
	var old_id: String = draft.id
	var old_name := name_input.text
	draft.id = ""
	name_input.text = old_name.left(110) + " (copy)"
	if not _save():
		draft.id = old_id
		name_input.text = old_name

func _ask_delete() -> void:
	if saved_picker.item_count == 0: return
	deleting = saved_picker.get_selected_metadata()
	delete_dialog.dialog_text = "Delete from profile: " + saved_picker.get_item_text(saved_picker.selected) + "?"
	delete_dialog.popup_centered()

func _delete_list() -> void:
	var error: String = store.delete_list(deleting)
	if error.is_empty() and draft.id == deleting:
		draft.id = ""
		dirty = true
	notice.text = "List deleted; the open draft was kept." if error.is_empty() else error
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
	if draft.edition == "11e":
		for faction: String in Training.SPECS:
			if FileAccess.file_exists(Training.DIRECTORY.path_join(Training.SPECS[faction].folder).path_join("manifest.json")): factions[faction] = true
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
	add_button.disabled = true
	for unit: Dictionary in source.catalog.get("units", []):
		if unit.edition != draft.edition or not Roster.faction_allowed(draft.faction, unit.faction, allies.button_pressed): continue
		if not query.text.strip_edges().is_empty() and query.text.strip_edges().to_lower() not in unit.name.to_lower(): continue
		if role_picker.selected > 0 and unit.role != role_picker.get_item_text(role_picker.selected): continue
		unit_picker.add_item(unit.name + (" • " + unit.faction if unit.faction != draft.faction else ""))
		unit_picker.set_item_metadata(unit_picker.item_count - 1, unit)

func _select_unit(index: int) -> void:
	selected_unit = unit_picker.get_item_metadata(index)
	choice_picker.clear()
	for option: Dictionary in selected_unit.options:
		choice_picker.add_item(("%d models (API)" % option.models if option.models > 0 else "Composition not provided") + (" • %d pts" % option.cost if option.cost != null else " • cost unconfirmed"))
	add_button.disabled = false

func _add() -> void:
	_sync()
	if selected_unit.is_empty() or choice_picker.selected < 0: return
	if draft.entries.size() >= 100:
		notice.text = "The list has reached the 100-entry limit."
		return
	draft.entries.append(Roster.entry(selected_unit, choice_picker.selected, int(copies.value)))
	if draft.catalog_digest.is_empty(): draft.catalog_digest = source.catalog.digest
	dirty = true
	_render_draft()

func _remove() -> void:
	var selected := entries.get_selected_items()
	if selected.is_empty(): return
	draft.entries.remove_at(selected[0])
	dirty = true
	_render_draft()

func _new_empty() -> void:
	_sync()
	draft = Roster.new_list(source.edition, draft.faction, draft.category, int(draft.points_limit))
	dirty = true
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
	notice.text = "Training list created. Save it to select it in Match Setup. Remove an entry to use only one unit."

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
	var updated := Roster.reprice(draft, source.catalog)
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
