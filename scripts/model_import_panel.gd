extends VBoxContainer

const TableCameraMotion = preload("res://scripts/ui/table_camera_motion.gd")
const WorkspaceTheme = preload("res://scripts/ui/workspace_theme.gd")
## Local import settings and preview. Paths and mappings never enter match snapshots.
signal mappings_changed
signal automatic_status(message: String)
signal automatic_finished(ready: int, total: int, summary: String)
signal automatic_cancelled
signal variants_changed(definition: String)
signal linked_unit_requested
var linked_unit_button: Button
var cached_preview_button: Button
var last_linked_definition := ""
var has_roster_context: Callable
const CatalogDownload = preload("res://scripts/forceorg_catalog_download.gd")
var catalog_downloader: Node
var catalog_definitions: Array[String] = []
var variant_catalog_identity := ""
var last_variant_catalog_path := ""
var automatic_variant_requests: Dictionary = {}
var automatic_variants_changed: Dictionary = {}
var automatic_appearance_total := 0
var automatic_appearance_ready := 0
var automatic_appearance_skipped := 0
var unavailable_automatic_variants: Dictionary = {}
var unavailable_variant_source_fingerprint := ""
var retry_unavailable_variants_button: Button
const Matcher = preload("res://scripts/forceorg_matcher.gd")
var automatic_queue: Array[Dictionary] = []
var automatic_current: Dictionary = {}
var automatic_messages: Array[String] = []
var automatic_repair_definitions: Array[String] = []
var automatic_ready := 0
var automatic_total := 0
var automatic_generation := 0
var automatic_running := false
var automatic_index: Dictionary = {}
var automatic_source_pose_pilot := false
const Assets = preload("res://scripts/local_models.gd")
const Download = preload("res://scripts/model_download.gd")
const MarineProfiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
var downloader: Node
var download_path: LineEdit
var download_button: Button
var download_cancel: Button
var download_status: Label
var download_selection := ""
var settings_path := "user://local-models.cfg"
var selected_definition: Callable
var selected_radius: Callable
var selected_label: Callable
var mappings: Dictionary = {}
var variant_mappings: Dictionary = {}
var variant_cache: Dictionary = {}
var variant_queue: Array[Dictionary] = []
var variant_download_active := false
var variant_catalog_pending := false
var variant_failures: Array[String] = []
var variant_catalog_definition := ""
var variant_download_definition := ""
var variant_current: Dictionary = {}
var variant_failure_status_by_id: Dictionary = {}
var catalog: Dictionary = {}
var variant_catalog_entries_by_id: Dictionary = {}
var variant_catalog_index_key := ""
var catalog_search_pattern := RegEx.new()
var cache: Dictionary = {}
var prepared_cache: Dictionary = {}
var visual_preparation_busy := false
var preview_worker: Thread
var source_path: LineEdit
var cache_path: LineEdit
var cache_index: Dictionary = {}
var lookup_status: Label
var inventory_status: Label
var mesh_path: LineEdit
var texture_path: LineEdit
var inventory: OptionButton
var inventory_filter: LineEdit
var inventory_search_timer: Timer
var selected_description: Label
var notice: Label
var target: Label
var scale_input: SpinBox
var rotation_input: SpinBox
var offset_input: SpinBox
var preview_root: Node3D
var preview_camera: Camera3D
var source_pose_toggle: CheckBox
var preview_fit_status: Label
var hull_review: CheckBox
var hull_scale: SpinBox
var hull_contact_x: SpinBox
var hull_contact_y: SpinBox
var hull_contact_z: SpinBox
var preview_views: HBoxContainer
var preview_identity := ""
var package_busy := false
var source_scan_busy := false
var preview_yaw := 0.61
var preview_pitch := 0.39
var preview_yaw_goal := 0.61
var preview_pitch_goal := 0.39
var preview_distance := 2.5
var preview_zoom_goal := 2.5
var preview_zoom_tween: Tween
var preview_motion_enabled: Callable
var preview_focus := Vector3.ZERO
var preview_focus_goal := Vector3.ZERO
var preview_asset: Dictionary = {}
var apply_button: Button
var selected_download_error := "No model selected."
var automatic_started_usec := 0

func _label(text: String) -> Label:
	var label := Label.new()
	label.text = text
	label.custom_minimum_size.x = 400
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	add_child(label)
	return label

func _button(text: String, action: Callable) -> Button:
	var button := Button.new()
	button.text = text
	button.pressed.connect(action)
	add_child(button)
	return button

func _path(label: String, filters: PackedStringArray, folder: bool = false) -> LineEdit:
	_label(label)
	var input := LineEdit.new()
	input.placeholder_text = "Local file path"
	add_child(input)
	_button("Browse: " + label, func():
		var dialog := FileDialog.new()
		dialog.access = FileDialog.ACCESS_FILESYSTEM
		dialog.file_mode = FileDialog.FILE_MODE_OPEN_DIR if folder else FileDialog.FILE_MODE_OPEN_FILE
		dialog.filters = filters
		add_child(dialog)
		dialog.file_selected.connect(func(path: String): input.text = path; dialog.queue_free())
		dialog.dir_selected.connect(func(path: String): input.text = path; dialog.queue_free())
		dialog.canceled.connect(dialog.queue_free)
		dialog.popup_centered_ratio(0.75)
	)
	return input

func _number(label: String, minimum: float, maximum: float, step: float, initial: float) -> SpinBox:
	_label(label)
	var number := SpinBox.new()
	number.min_value = minimum
	number.max_value = maximum
	number.step = step
	number.value = initial
	number.value_changed.connect(func(_value: float): _update_preview())
	add_child(number)
	return number

func _ready() -> void:
	theme = WorkspaceTheme.create()
	Assets.set_profiling_enabled("--profile-training-tools" in OS.get_cmdline_user_args())
	_label("FORCEORG / TTS MODELS\nConfigure your ForceOrg JSON once for automatic models in local matches. You can also search, preview and link a specific visual manually. TTS is not required.")
	source_path = _path("TTS / ForceOrg JSON", PackedStringArray(["*.json ; TTS saves"]))
	WorkspaceTheme.decorate_button(_button("Scan local save", scan_source_async), "folder")
	inventory_filter = LineEdit.new()
	inventory_filter.placeholder_text = "Search name, datasheet or weapon: Necron Warriors, Gauss Reaper…"
	add_child(inventory_filter)
	inventory_search_timer = Timer.new()
	inventory_search_timer.name = "InventorySearchDebounce"
	inventory_search_timer.one_shot = true
	inventory_search_timer.wait_time = 0.15
	inventory_search_timer.timeout.connect(_refresh_inventory_search)
	add_child(inventory_search_timer)
	inventory = OptionButton.new()
	inventory.fit_to_longest_item = false
	inventory.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	inventory.item_selected.connect(func(_index: int): _describe_entry())
	add_child(inventory)
	inventory_status = _label("Search by model, datasheet, role or weapon.")
	selected_description = _label("Select a miniature to inspect its source and available appearance. Previewing does not link it to an army.")
	inventory_filter.text_changed.connect(func(_text: String):
		if catalog.is_empty(): return
		inventory_status.text = "Searching..."
		inventory_search_timer.start()
	)
	inventory_filter.text_submitted.connect(func(_text: String): _refresh_inventory_search())
	download_path = _path("Model download folder", PackedStringArray(), true)
	download_path.text = ProjectSettings.globalize_path("user://downloaded-models")
	download_button = _button("Download this model's files", start_download)
	WorkspaceTheme.decorate_button(download_button, "load")
	WorkspaceTheme.decorate_button(_button("Save download folder", func():
		if _save(mappings): download_status.text = "Download folder saved."
	), "save")
	download_cancel = _button("Cancel download", cancel_automatic)
	WorkspaceTheme.decorate_button(download_cancel, "close")
	download_cancel.visible = false
	download_status = _label("Choose a miniature, then preview cached files or explicitly download its model. Existing links change only when you choose Link to unit type.")
	downloader = Download.new()
	add_child(downloader)
	downloader.progress.connect(func(received: int, total: int, label: String):
		download_status.text = "%s: %.1f KiB%s" % [label, received / 1024.0, " / %.1f KiB" % (total / 1024.0) if total > 0 else " • total size unknown"]
		if automatic_running: automatic_status.emit(download_status.text)
	)
	downloader.finished.connect(_download_finished)
	downloader.transfer_completed.connect(_on_model_transfer_completed)
	catalog_downloader = CatalogDownload.new()
	add_child(catalog_downloader)
	catalog_downloader.progress.connect(func(received: int, total: int):
		var message := "Downloading ForceOrg catalog: %.1f MiB%s" % [received / 1048576.0, " / %.1f MiB" % (total / 1048576.0) if total > 0 else ""]
		download_status.text = message
		automatic_status.emit(message)
	)
	catalog_downloader.finished.connect(func(result: Dictionary):
		if variant_catalog_pending:
			variant_catalog_pending = false
			if not result.error.is_empty():
				download_status.text = result.error
				automatic_status.emit(download_status.text)
				return
			var scanned := Assets.scan(result.path)
			if not scanned.error.is_empty():
				download_status.text = scanned.error
				automatic_status.emit(download_status.text)
				return
			catalog = scanned
			_start_variant_downloads(variant_catalog_definition, variant_catalog_identity)
			return
		if not automatic_running: return
		var definitions: Array[String] = catalog_definitions.duplicate()
		catalog_definitions.clear()
		automatic_running = false
		if not result.error.is_empty():
			automatic_messages.append(result.error)
			_finish_automatic_batch()
			return
		source_path.text = result.path
		prepare_armies(definitions, false, false, automatic_variant_requests.duplicate(true))
	)
	cache_path = _path("Optional: local files / cache folder", PackedStringArray(), true)
	source_pose_toggle = CheckBox.new()
	source_pose_toggle.text = "Experimental source pose (selected saved object)"
	source_pose_toggle.tooltip_text = "Preserve the saved root orientation and scale. Load the selected object's files again to preview."
	add_child(source_pose_toggle)
	_button("Find selected object's local files", find_cached_files)
	lookup_status = _label("Choose your local Mods/cache folder. Lookup reads existing files only.")
	_button("Save cache folder setting", func():
		if _save(mappings): notice.text = "Local cache folder saved."
	)
	mesh_path = _path("Local OBJ mesh", PackedStringArray(["*.obj ; OBJ mesh", "* ; Cached file"]))
	texture_path = _path("Optional diffuse texture", PackedStringArray(["*.png,*.jpg,*.jpeg,*.webp ; Image", "* ; Cached image"]))
	_button("Load model preview", load_preview)
	var container := SubViewportContainer.new()
	container.custom_minimum_size = Vector2(400, 210)
	container.stretch = true
	add_child(container)
	var viewport := SubViewport.new()
	viewport.size = Vector2i(400, 210)
	viewport.own_world_3d = true
	viewport.render_target_update_mode = SubViewport.UPDATE_WHEN_VISIBLE
	container.add_child(viewport)
	preview_root = Node3D.new()
	viewport.add_child(preview_root)
	var camera := Camera3D.new()
	preview_camera = camera
	viewport.add_child(camera)
	camera.position = Vector3(1.6, 1.3, 2)
	camera.look_at(Vector3(0, 0.65, 0))
	var light := DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-45, -30, 0)
	viewport.add_child(light)
	container.gui_input.connect(_preview_camera_input)
	preview_views = HBoxContainer.new()
	add_child(preview_views)
	for preset: String in ["Top", "Side", "Reset fit"]:
		var control := Button.new()
		control.text = preset
		preview_views.add_child(control)
		control.pressed.connect(_preview_view.bind(preset))
	var package_button := Button.new()
	package_button.text = "Prepare local GLB"
	package_button.pressed.connect(_prepare_preview_package)
	preview_views.add_child(package_button)
	preview_fit_status = _label("")
	scale_input = _number("Extra visual scale (1.0 = official base diameter / TTS table scale)", 0.01, 20, 0.01, 1)
	rotation_input = _number("Rotation (degrees)", -360, 360, 1, 0)
	offset_input = _number("Height offset (inches)", -10, 10, 0.01, 0)
	hull_review = CheckBox.new()
	hull_review.text = "Use reviewed hull mount"
	hull_review.tooltip_text = "For a source-pose model whose rules profile says Use model. This affects the visual only."
	hull_review.toggled.connect(func(_pressed: bool): _update_preview())
	add_child(hull_review)
	hull_scale = _number("Hull scale (board inches per source unit)", 0.01, 20.0, 0.01, 1.0)
	hull_contact_x = _number("Hull contact X (source offset)", -20.0, 20.0, 0.01, 0.0)
	hull_contact_y = _number("Hull contact height (source offset)", -20.0, 20.0, 0.01, 0.0)
	hull_contact_z = _number("Hull contact Z (source offset)", -20.0, 20.0, 0.01, 0.0)
	target = _label("Select a battlefield model to choose a unit type.")
	apply_button = _button("Link to unit type", apply_mapping)
	apply_button.tooltip_text = "Save a local default for this unit type. Explicit unit appearances take priority. Other players keep their own visuals."
	linked_unit_button = _button("View linked unit", func(): linked_unit_requested.emit())
	linked_unit_button.visible = false
	_button("Use built-in model for selected unit type", remove_mapping)
	notice = _label("No miniature loaded. Choose a catalog entry and preview cached files, or download the selected miniature. Missing or incompatible files keep the existing link.")
	load_settings()
	_organize_imports()

## Load and persist a player-selected ForceOrg/TTS catalog without downloading its assets.
## Match preparation downloads only compatible visuals required by the selected armies.
func load_catalog_file(path: String) -> String:
	var candidate := path.strip_edges()
	if candidate.is_empty(): return "Choose a ForceOrg JSON file."
	var scanned := Assets.scan(candidate)
	return _install_scanned_catalog(candidate, scanned)

func load_catalog_file_async(path: String, request: Callable = Callable()) -> String:
	var candidate := path.strip_edges()
	if candidate.is_empty(): return "Choose a ForceOrg JSON file."
	var scanned := await _background_preview_read(Callable(Assets, "scan").bind(candidate), request)
	if scanned.is_empty(): return "Catalog selection changed; the previous scan was not applied."
	return _install_scanned_catalog(candidate, scanned)

func _install_scanned_catalog(candidate: String, scanned: Dictionary) -> String:
	if not scanned.error.is_empty(): return scanned.error
	if scanned.entries.is_empty(): return "The selected JSON contains no compatible model catalog entries."
	var previous_path := source_path.text
	var previous_catalog := catalog
	source_path.text = candidate
	catalog = scanned
	if not _save(mappings):
		source_path.text = previous_path
		catalog = previous_catalog
		return notice.text if not notice.text.is_empty() else "Could not save the ForceOrg catalog path."
	_set_unavailable_variant_source(str(scanned.get("fingerprint", "")))
	var matches := _populate_inventory()
	variants_changed.emit(_definition())
	inventory_status.text = "%d entries • %d embedded static objects • %d skipped-table warnings\n%s" % [catalog.entries.size(), catalog.get("embedded_objects", 0), catalog.get("warnings", []).size(), matches]
	if not catalog.get("warnings", []).is_empty(): notice.text += "\n" + "\n".join(catalog.warnings.slice(0, 10))
	return ""

func _organize_imports() -> void:
	var original := get_children()
	var layout := HBoxContainer.new()
	layout.add_theme_constant_override("separation", 24)
	add_child(layout)
	var tabs := TabContainer.new()
	tabs.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	layout.add_child(tabs)
	var pages := {}
	for title in ["Miniature library", "Source & download", "Local files", "Adjust"]:
		var page := VBoxContainer.new()
		page.name = title
		tabs.add_child(page)
		pages[title] = page
	tabs.set_tab_title(1, "Advanced source")
	tabs.set_tab_title(2, "Advanced files")
	tabs.set_tab_title(3, "Advanced fit")
	var library_intro := Label.new()
	library_intro.text = "Browse your configured local catalog. Preview cached files, or explicitly download the selected miniature. Open Advanced source to choose a catalog."
	library_intro.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	pages["Miniature library"].add_child(library_intro)
	retry_unavailable_variants_button = Button.new()
	retry_unavailable_variants_button.pressed.connect(_allow_retry_unavailable_variants)
	pages["Miniature library"].add_child(retry_unavailable_variants_button)
	_update_unavailable_variants_button()
	var configure := Button.new()
	configure.text = "Choose or change miniature catalog…"
	configure.custom_minimum_size.y = 40
	configure.pressed.connect(func(): tabs.current_tab = 1)
	pages["Miniature library"].add_child(configure)
	var cached_preview := Button.new()
	cached_preview_button = cached_preview
	cached_preview.text = "Preview cached miniature"
	cached_preview.custom_minimum_size.y = 40
	cached_preview.pressed.connect(find_cached_files)
	pages["Miniature library"].add_child(cached_preview)
	var right := VBoxContainer.new()
	right.custom_minimum_size.x = 320
	layout.add_child(right)
	var preview_heading := Label.new()
	preview_heading.text = "MODEL PREVIEW"
	right.add_child(preview_heading)
	var destination := "Source & download"
	for control in original:
		if not control is Control: continue
		if control is Label:
			if control.text.begins_with("FORCEORG / TTS MODELS"):
				control.tooltip_text = control.text
				control.text = "CATALOG SOURCE · LOCAL CONFIGURATION"
			if control.text == "Model download folder": destination = "Local files"
			if control.text == "Optional: local files / cache folder": destination = "Local files"
			elif control.text.begins_with("Extra visual scale"): destination = "Adjust"
		if control in [inventory_filter, inventory, inventory_status, selected_description, download_button, download_cancel, download_status]:
			control.reparent(pages["Miniature library"])
			continue
		if control == download_button: destination = "Source & download"
		if control is Button and control.text == "Save download folder":
			control.reparent(pages["Local files"])
			continue
		if control is SubViewportContainer or control in [preview_views, preview_fit_status, target, apply_button, linked_unit_button, notice]:
			control.reparent(right)
		else: control.reparent(pages[destination])
	for text_label: Label in [notice, selected_description, download_status, lookup_status, inventory_status]:
		text_label.max_lines_visible = 3
		text_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	selected_description.max_lines_visible = 7
	if catalog.is_empty(): inventory_status.text = "No catalog loaded. Choose a local ForceOrg / TTS catalog to browse miniatures."
	for control in preview_views.get_children():
		if control is Button and control.text == "Prepare local GLB": control.reparent(pages["Local files"])

func _process(_delta: float) -> void:
	_update_unavailable_variants_button()
	if cached_preview_button != null: cached_preview_button.disabled = catalog.is_empty() or inventory.selected < 0 or downloader.busy or automatic_running or variant_download_active
	for text_label: Label in [notice, selected_description, download_status, lookup_status, inventory_status]: text_label.tooltip_text = text_label.text
	var definition := _definition()
	if not last_linked_definition.is_empty() and definition != last_linked_definition: last_linked_definition = ""
	linked_unit_button.visible = not last_linked_definition.is_empty() and has_roster_context.is_valid() and has_roster_context.call()
	inventory.disabled = downloader.busy or automatic_running or variant_download_active
	inventory_filter.editable = not downloader.busy and not automatic_running and not variant_download_active
	download_path.editable = not downloader.busy and not automatic_running and not variant_download_active
	download_cancel.visible = downloader.busy or automatic_running or variant_download_active
	download_cancel.text = "Cancel preparation" if automatic_running or variant_download_active else "Cancel download"
	var entry := _selected_entry()
	download_button.disabled = downloader.busy or automatic_running or variant_download_active or not selected_download_error.is_empty()
	var display_name := str(selected_label.call()) if selected_label.is_valid() else definition
	target.text = "Target unit: " + display_name if not definition.is_empty() else "Select a roster unit in Army, or a model in Play."
	apply_button.disabled = downloader.busy or automatic_running or variant_download_active or definition.is_empty() or preview_asset.is_empty() or preview_asset.get("path", "") != mesh_path.text.strip_edges() or preview_asset.get("texture", "") != texture_path.text.strip_edges()
	_advance_preview_view(_delta)

func start_download() -> void:
	if downloader.busy or automatic_running: return
	var entry := _selected_entry()
	if entry.is_empty():
		download_status.text = "Open a JSON file and select a miniature first."
		return
	download_selection = JSON.stringify(entry)
	_clear_candidate_files()
	download_status.text = "Starting download: " + _entry_title(entry)
	var error: String = downloader.start(entry.duplicate(true), download_path.text.strip_edges())
	if not error.is_empty(): download_status.text = error

func _download_finished(result: Dictionary) -> void:
	if not is_inside_tree(): return
	if variant_download_active:
		_finish_variant_download(result)
		return
	if automatic_running:
		_finish_automatic_item(result)
		return
	if not result.error.is_empty():
		download_status.text = result.error
		return
	if JSON.stringify(_selected_entry()) != download_selection:
		download_status.text = "Files downloaded. The selection changed; select the model again before importing."
		return
	if result.get("parts") is Array:
		_load_downloaded_preview(result.parts, result.get("asset", {}))
	else:
		mesh_path.text = result.mesh
		texture_path.text = result.texture
		load_preview()
	download_status.text = "Download complete. " + ("Preview loaded; adjust the model and save it for the selected unit." if not preview_asset.is_empty() else notice.text)
	var visual_warnings := _visual_warnings(result)
	if not visual_warnings.is_empty(): download_status.text += "\nVisual note: " + "; ".join(visual_warnings)
	lookup_status.text = "Files retrieved with the download button. Using the TTS cache is optional."

func _on_model_transfer_completed(elapsed_ms: float, downloaded_bytes: int) -> void:
	Assets.record_profile_duration("network_download", elapsed_ms, downloaded_bytes)

func _visual_warnings(result: Dictionary) -> Array[String]:
	var output: Array[String] = []
	var parts: Variant = result.get("parts", [])
	if not parts is Array: return output
	for part: Variant in parts:
		if not part is Dictionary: continue
		var warnings: Variant = part.get("warnings", [])
		if not warnings is Array: continue
		for warning: Variant in warnings:
			var message := str(warning).strip_edges()
			if not message.is_empty() and message not in output: output.append(message)
	return output

func _downloaded_asset(result: Dictionary) -> Dictionary:
	var supplied: Variant = result.get("asset", {})
	if supplied is Dictionary and not supplied.is_empty(): return supplied
	if result.get("parts") is Array: return Assets.composite_from_files(result.parts)
	return Assets.obj_mesh(str(result.get("mesh", "")), str(result.get("texture", "")))

func _downloaded_asset_async(result: Dictionary, request: Callable) -> Dictionary:
	var supplied: Variant = result.get("asset", {})
	if supplied is Dictionary and not supplied.is_empty(): return supplied
	var mapping := {"path": str(result.get("mesh", "")), "texture": str(result.get("texture", ""))}
	if result.get("parts") is Array: mapping.parts = result.parts
	if not needs_background_preview(mapping): return _downloaded_asset(result)
	var asset := await _background_preview_read(Callable(Assets, "load_mapping_asset_for_worker").bind(mapping.duplicate(true)), request)
	return Assets.finalize_pending_textures(asset) if not asset.is_empty() else {}

func _definition() -> String:
	return str(selected_definition.call()) if selected_definition.is_valid() else ""

func scan_source() -> void:
	if downloader.busy or automatic_running: return
	var issue := load_catalog_file(source_path.text)
	if not issue.is_empty(): notice.text = issue

func scan_source_async() -> void:
	if downloader.busy or automatic_running or source_scan_busy: return
	var candidate := source_path.text
	var current := func() -> bool: return is_inside_tree() and candidate == source_path.text
	source_scan_busy = true
	inventory_status.text = "Scanning the local source… You can keep browsing."
	notice.text = "Scanning the local source… Changing its path cancels applying this scan."
	var issue := await load_catalog_file_async(candidate, current)
	source_scan_busy = false
	if not issue.is_empty(): notice.text = issue

func _refresh_inventory_search() -> void:
	if catalog.is_empty(): return
	if not inventory_search_timer.is_stopped(): inventory_search_timer.stop()
	inventory_status.text = _populate_inventory()

func _populate_inventory() -> String:
	inventory.clear()
	var matching := 0
	var visible_indices: Array[int] = []
	var totals: Dictionary = {}
	var occurrences: Dictionary = {}
	var query_terms := _normalize_catalog_search(inventory_filter.text).split(" ", false)
	for index in range(catalog.entries.size()):
		var entry: Dictionary = catalog.entries[index]
		if entry.get("visual_category", "") == "ignored": continue
		if not query_terms.is_empty() and not _catalog_entry_matches_search(entry, query_terms): continue
		matching += 1
		var name: String = entry.name
		totals[name] = int(totals.get(name, 0)) + 1
		if visible_indices.size() < 200: visible_indices.append(index)
	for index: int in visible_indices:
		var entry: Dictionary = catalog.entries[index]
		var name: String = entry.name
		occurrences[name] = int(occurrences.get(name, 0)) + 1
		var title := _entry_title(entry)
		if totals[name] > 1:
			title += " • Option %d/%d" % [occurrences[name], totals[name]]
			var source_label := _source_entry_label(entry)
			if not source_label.is_empty(): title += " • " + source_label
		inventory.add_item(title)
		inventory.set_item_metadata(inventory.item_count - 1, index)
	_clear_candidate_files()
	if inventory.item_count > 0: _describe_entry()
	else:
		notice.text = "No miniature matches. Try a model, datasheet, role or weapon term."
		selected_description.text = notice.text
	var result_label := "result" if matching == 1 else "results"
	return "%d %s • showing %d. Search by model, datasheet, role or weapon." % [matching, result_label, inventory.item_count]

func _normalize_catalog_search(value: String) -> String:
	if catalog_search_pattern.get_pattern().is_empty():
		catalog_search_pattern.compile("[^\\p{L}\\p{N}]+")
	return catalog_search_pattern.sub(value.to_lower(), " ", true).strip_edges()

func _catalog_entry_matches_search(entry: Dictionary, query_terms: PackedStringArray) -> bool:
	var search_text := str(entry.get("_catalog_search_text", ""))
	if search_text.is_empty():
		var fragments: PackedStringArray = [str(entry.get("name", "")), str(entry.get("visual_model_role", ""))]
		for term: Variant in entry.get("visual_weapons", []): fragments.append(str(term).replace("-", " "))
		var alias_groups: Variant = entry.get("visual_weapon_aliases", {})
		if alias_groups is Dictionary:
			for aliases: Variant in alias_groups.values():
				if not aliases is Dictionary: continue
				for visual: Variant in aliases.keys(): fragments.append(str(visual).replace("-", " "))
				for physical: Variant in aliases.values(): fragments.append(str(physical).replace("-", " "))
		for datasheet: Variant in entry.get("visual_datasheets", []):
			if datasheet is Dictionary: fragments.append(str(datasheet.get("name", "")))
		for definition: Variant in entry.get("visual_definitions", []):
			var name := Matcher._profile_name(str(definition))
			if not name.is_empty(): fragments.append(name)
		search_text = _normalize_catalog_search(" ".join(fragments))
		entry["_catalog_search_text"] = search_text
	for query_term: String in query_terms:
		if not search_text.contains(query_term): return false
	return true

func _catalog_datasheet_labels(entry: Dictionary) -> Array[String]:
	var names: Array[String] = []
	for item: Variant in entry.get("visual_datasheets", []):
		if not item is Dictionary: continue
		var name := str(item.get("name", "")).strip_edges()
		if not name.is_empty() and name not in names: names.append(name)
	for value: Variant in entry.get("visual_definitions", []):
		var name := Matcher._profile_name(str(value))
		if not name.is_empty() and name not in names: names.append(name)
	names.sort()
	return names

func _catalog_weapon_labels(entry: Dictionary) -> Array[String]:
	var result: Array[String] = []
	for value: Variant in entry.get("visual_weapons", []):
		var words := str(value).replace("-", " ").split(" ", false)
		var label := " ".join(words).capitalize()
		if not label.is_empty() and label not in result: result.append(label)
	result.sort()
	return result

func _entry_title(entry: Dictionary) -> String:
	var name := str(entry.get("name", "Unnamed object"))
	var title := name.replace(" / component ", " • Part ")
	var base_name := RegEx.new()
	base_name.compile("(?i)^\\d+(?:[x×]\\d+)?\\s*mm(?:\\s[^/]*|$)$")
	if base_name.search(name) != null: title = "Base: " + title
	if name in ["Custom_Model", "Custom_Assetbundle", "Custom_Model_Infinite_Bag"]: title = "Unnamed object"
	if _entry_has_bundle(entry): title += " • Unity bundle (converter required)"
	elif int(entry.get("child_components", 0)) > 0: title += " • has separate parts"
	return title

func _source_entry_label(entry: Dictionary) -> String:
	var guid := str(entry.get("guid", "")).strip_edges()
	if not guid.is_empty(): return "GUID " + guid
	var identity := str(entry.get("id", "")).strip_edges()
	if not identity.is_empty(): return "ID " + identity.left(8)
	return ""

func _entry_has_bundle(entry: Dictionary) -> bool:
	var planned := Assets.component_plan(entry)
	for component: Dictionary in planned.get("components", []):
		if str(component.get("kind", "")) == "CustomAssetbundle": return true
	return false

func _selected_entry() -> Dictionary:
	if catalog.is_empty() or inventory.selected < 0: return {}
	var index: int = inventory.selected
	var metadata: Variant = inventory.get_item_metadata(index)
	if metadata is int: index = metadata
	if index < 0 or index >= catalog.entries.size(): return {}
	var entry: Dictionary = catalog.entries[index].duplicate()
	entry.preserve_source_pose = source_pose_toggle != null and source_pose_toggle.button_pressed
	return entry

func _describe_entry() -> void:
	if inventory.selected < 0 or catalog.is_empty(): return
	_clear_candidate_files()
	lookup_status.text = "Object changed. Find its files in the cache or choose them manually."
	var entry := _selected_entry()
	selected_download_error = str(Assets.component_plan(entry).get("error", ""))
	selected_description.text = "Selected: " + inventory.get_item_text(inventory.selected)
	var source_label := _source_entry_label(entry)
	if not source_label.is_empty(): selected_description.text += "\nSource identity: " + source_label
	var datasheets := _catalog_datasheet_labels(entry)
	if not datasheets.is_empty(): selected_description.text += "\nDatasheet name matches: " + ", ".join(datasheets)
	var weapon_labels := _catalog_weapon_labels(entry)
	if not weapon_labels.is_empty(): selected_description.text += "\nWeapon terms from source labels: " + ", ".join(weapon_labels)
	else: selected_description.text += "\nNo weapon term was identified in the source label."
	if "component" in str(entry.get("path", "")).to_lower() or "/ChildObjects/" in str(entry.get("path", "")):
		selected_description.text += "\nThis is one component, not the complete miniature. Select its parent assembly to preview all saved parts together."
	elif int(entry.get("child_components", 0)) > 0:
		selected_description.text += "\nThis object has separate parts. If only the base appears, search for parts with the same name."
	selected_description.text += "\nConfirm the preview before linking it to a unit."
	notice.text = "%s\n%s\n%s" % [entry.name, entry.path, JSON.stringify(entry.references, "  ")]
	if not str(entry.get("credit", "")).is_empty(): notice.text += "\nSource description/credits: " + str(entry.credit)
	if not selected_download_error.is_empty(): notice.text += "\n" + selected_download_error
	elif _entry_has_bundle(entry): notice.text += "\nOne or more parts use Unity model bundles. Install the optional local ForceOrg converter before downloading; OBJ, diffuse and normal-map parts are validated in the same batch."
	else: notice.text += "\nDownload this model's OBJ parts and optional diffuse and normal images below."

func _clear_candidate_files() -> void:
	hull_review.set_pressed_no_signal(false)
	hull_scale.set_value_no_signal(1.0)
	hull_contact_x.set_value_no_signal(0.0)
	hull_contact_y.set_value_no_signal(0.0)
	hull_contact_z.set_value_no_signal(0.0)
	mesh_path.text = ""
	texture_path.text = ""
	preview_asset = {}
	_update_preview()

func find_cached_files() -> void:
	if downloader.busy: return
	if catalog.is_empty() or inventory.selected < 0:
		notice.text = "Scan a local save and select an object first."
		lookup_status.text = notice.text
		return
	var entry := _selected_entry()
	_clear_candidate_files()
	var component_plan := Assets.component_plan(entry)
	if not component_plan.error.is_empty():
		notice.text = component_plan.error
		lookup_status.text = notice.text
		return
	# Re-index on an explicit request, so newly cached files and duplicates are seen.
	cache_index = Assets.index_cache(cache_path.text.strip_edges())
	if not cache_index.error.is_empty():
		notice.text = cache_index.error
		lookup_status.text = notice.text
		return
	var resolved := Assets.resolve_cache(entry, cache_index)
	var cached_parts := _cached_component_files(resolved)
	var message := "Inspected %d local files across %d model part(s)." % [cache_index.files, resolved.get("parts", []).size()]
	if cached_parts.error.is_empty():
		_load_downloaded_preview(cached_parts.parts)
		notice.text = message + "\n" + notice.text
	else:
		notice.text = "%s\n%s No files were downloaded or linked." % [cached_parts.error, message]
	lookup_status.text = notice.text

func _cached_component_files(resolved: Dictionary) -> Dictionary:
	var files: Array[Dictionary] = []
	for resolved_part: Dictionary in resolved.get("parts", []):
		if str(resolved_part.component.get("kind", "CustomMesh")) == "CustomAssetbundle":
			if resolved_part.bundle.status != "found": return {"error": "%s bundle: %s" % [resolved_part.component.get("name", "Model"), resolved_part.bundle.status], "parts": []}
			if resolved_part.bundle_parts.is_empty(): return {"error": "%s bundle: converted files are unavailable" % resolved_part.component.get("name", "Model"), "parts": []}
			files.append_array(resolved_part.bundle_parts)
			continue
		if resolved_part.mesh.status != "found": return {"error": "%s mesh: %s" % [resolved_part.component.get("name", "Model"), resolved_part.mesh.status], "parts": []}
		if resolved_part.diffuse_required and resolved_part.diffuse.status != "found": return {"error": "%s diffuse image: %s" % [resolved_part.component.get("name", "Model"), resolved_part.diffuse.status], "parts": []}
		if resolved_part.normal_required and resolved_part.normal.status != "found": return {"error": "%s normal image: %s" % [resolved_part.component.get("name", "Model"), resolved_part.normal.status], "parts": []}
		files.append({"path": resolved_part.mesh.path, "texture": resolved_part.diffuse.path, "normal": resolved_part.normal.path, "transforms": resolved_part.component.get("transforms", []), "name": resolved_part.component.get("name", "Model")})
	return {"error": "", "parts": files}

func _load_downloaded_preview(parts: Array, supplied_asset: Dictionary = {}) -> void:
	var loaded := supplied_asset if not supplied_asset.is_empty() else Assets.composite_from_files(parts)
	if not loaded.error.is_empty():
		preview_asset = {}
		_update_preview()
		notice.text = loaded.error
		return
	var first: Dictionary = parts[0]
	loaded.path = str(first.get("path", ""))
	loaded.texture = str(first.get("texture", ""))
	loaded.source_parts = parts.duplicate(true)
	preview_asset = loaded
	mesh_path.text = loaded.path
	texture_path.text = loaded.texture
	_update_preview()
	notice.text = "Preview loaded from %d OBJ part(s). Adjust its appearance, select a battlefield model, then save for that unit type. Gameplay bases and rules stay authoritative." % parts.size()

func load_preview() -> void:
	var path := mesh_path.text.strip_edges()
	var texture := texture_path.text.strip_edges()
	var result := Assets.obj_mesh(path, texture)
	if not result.error.is_empty():
		preview_asset = {}
		_update_preview()
		notice.text = result.error
		return
	preview_asset = result
	preview_asset.path = path
	preview_asset.texture = texture
	preview_asset.source_parts = []
	_update_preview()
	notice.text = "Preview loaded. Adjust its appearance, select a battlefield model, then save for that unit type. Gameplay bases and rules stay authoritative."

func _settings() -> Dictionary:
	var settings := {"scale": scale_input.value, "rotation": rotation_input.value, "offset": offset_input.value, "tts_scale": 1.0}
	var entry := _selected_entry()
	if not entry.is_empty() and (entry.get("tts_scale") is float or entry.get("tts_scale") is int):
		settings.tts_scale = float(entry.tts_scale)
	var radius := float(selected_radius.call()) if selected_radius.is_valid() else 0.0
	settings = _visual_settings(settings, _definition(), radius)
	if hull_review.button_pressed and settings.get("visual_hull_proxy", false) and preview_asset.get("source_pose", false):
		settings.reviewed_hull_mount = {"scale": hull_scale.value,
			"contact_offset": Vector3(hull_contact_x.value, hull_contact_y.value, hull_contact_z.value)}
	return settings

func _update_preview() -> void:
	if preview_root == null or offset_input == null: return
	for child in preview_root.get_children():
		preview_root.remove_child(child)
		child.queue_free()
	if preview_asset.is_empty():
		preview_identity = ""
		preview_fit_status.text = ""
		return
	var settings := _settings()
	var visual := Assets.visual(preview_asset, settings)
	preview_root.add_child(visual)
	var issue := Assets.visual_error_for_base(preview_asset, settings)
	var footprint: Vector2 = visual.get_meta("asset_base_footprint_inches", Vector2.ZERO)
	preview_fit_status.text = issue if not issue.is_empty() else "Visual base: %.2f × %.2f mm (%s)" % [footprint.x * 25.4, footprint.y * 25.4, visual.get_meta("base_alignment_method")]
	if issue.is_empty() and Assets.has_reviewed_hull_mount(preview_asset, settings):
		preview_fit_status.text = "Reviewed hull mount • gameplay proxy shown in cyan"
	elif issue.is_empty() and bool(settings.get("visual_hull_proxy", false)) and not bool(preview_asset.get("source_pose", false)):
		preview_fit_status.text = "Source model scale preserved • gameplay uses the profile footprint proxy"
	if bool(preview_asset.get("source_pose", false)):
		_add_preview_footprint(Assets._visual_base_axes(settings), Color("62d5ff"), 0.009, true)
		_add_preview_footprint(footprint, Color("ffc86d"), 0.012, false, float(preview_asset.get("base_heading", 0.0)) - deg_to_rad(float(settings.get("rotation", 0.0))))
	var identity := _preview_geometry_identity()
	if identity != preview_identity:
		preview_identity = identity
		_preview_view("Reset fit")

func _preview_geometry_identity() -> String:
	var identities: Array[String] = []
	for part_value: Variant in preview_asset.get("parts", []):
		if not part_value is Dictionary: continue
		var part: Dictionary = part_value
		var part_asset: Variant = part.get("asset", {})
		if not part_asset is Dictionary: continue
		identities.append("%s:%s:%s" % [part.get("name", ""), part_asset.get("fingerprint", ""), part.get("transform", Transform3D.IDENTITY)])
	if identities.is_empty(): identities.append(str(preview_asset.get("fingerprint", "")))
	return "%s|%s" % [str(preview_asset.get("source_pose", false)), "|".join(identities)]

func _add_preview_footprint(axes: Vector2, color: Color, height: float, crosshair: bool, heading: float = 0.0) -> void:
	if minf(axes.x, axes.y) <= 0.0: return
	var ring := ImmediateMesh.new()
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = color
	material.no_depth_test = true
	ring.surface_begin(Mesh.PRIMITIVE_LINES, material)
	for segment in 64:
		for endpoint in [segment, segment + 1]:
			var angle := TAU * float(endpoint) / 64.0
			var point := Vector2(cos(angle) * axes.x * 0.5, sin(angle) * axes.y * 0.5).rotated(heading)
			ring.surface_add_vertex(Vector3(point.x, height, point.y))
	if crosshair:
		for point: Vector3 in [Vector3(-0.12, height, 0.0), Vector3(0.12, height, 0.0), Vector3(0.0, height, -0.12), Vector3(0.0, height, 0.12)]:
			ring.surface_add_vertex(point)
	ring.surface_end()
	var overlay := MeshInstance3D.new()
	overlay.mesh = ring
	preview_root.add_child(overlay)

func _prepare_preview_package() -> void:
	if package_busy: return
	if not bool(preview_asset.get("source_pose", false)):
		notice.text = "Load an experimental source-pose preview before preparing a GLB."
		return
	var settings := _settings()
	var issue := Assets.visual_error_for_base(preview_asset, settings)
	if float(settings.get("base_radius_inches", 0.0)) <= 0.01 or not issue.is_empty():
		notice.text = issue if not issue.is_empty() else "Select a model with a verified target footprint first."
		return
	var current := _preview_package_request(settings)
	package_busy = true
	notice.text = "Preparing local GLB… You can keep browsing; changing its target or fit cancels linking."
	var result := await prepare_preview_glb_async(settings, current)
	package_busy = false
	if result.is_empty():
		notice.text = "Preview or target changed; the prepared package was not linked."
		return
	notice.text = str(result.get("path", "")) if result.error.is_empty() else result.error

func _preview_package_request(settings: Dictionary) -> Callable:
	var fingerprint := str(preview_asset.get("fingerprint", ""))
	var identity := preview_identity
	var definition := _definition()
	var entry := _selected_entry().duplicate(true)
	return func() -> bool:
		return is_inside_tree() and fingerprint == str(preview_asset.get("fingerprint", "")) and identity == preview_identity and definition == _definition() and entry == _selected_entry() and settings == _settings() and str(preview_asset.get("path", "")) == mesh_path.text.strip_edges() and str(preview_asset.get("texture", "")) == texture_path.text.strip_edges()

func prepare_preview_glb_async(settings: Dictionary, request: Callable = Callable()) -> Dictionary:
	var entry := _selected_entry()
	var provenance := {"catalog_sha256": catalog.get("fingerprint", ""), "object": entry.get("path", ""),
		"guid": entry.get("guid", ""), "root_transform": entry.get("root_transform", {})}
	return await _background_preview_read(Callable(Assets, "prepare_glb").bind(preview_asset.duplicate(true), settings.duplicate(true), provenance), request)

func _preview_view(preset: String) -> void:
	if preview_asset.is_empty(): return
	var reset_distance := false
	var next_distance := preview_distance
	match preset:
		"Top":
			preview_pitch_goal = deg_to_rad(89.9)
			preview_yaw_goal = 0.0
		"Side":
			preview_pitch_goal = 0.0
			preview_yaw_goal = PI / 2.0
		_:
			preview_pitch_goal = 0.39
			preview_yaw_goal = 0.61
			var bounds := preload("res://scripts/ui/miniature_preview.gd").bounds_of(preview_root)
			# Assets.visual() mounts the fitted underside/base center at the origin.
			# Keep inspection pivoted there so the footprint remains stable at every zoom.
			preview_focus_goal = Vector3.ZERO
			next_distance = maxf(2.5, bounds.size.length() * 1.65)
			reset_distance = true
	if reset_distance:
		_animate_preview_zoom(next_distance)
	else:
		_stop_preview_zoom()
	_update_preview_camera()
	_advance_preview_view(0.0)

func _advance_preview_view(delta: float) -> void:
	if preview_camera == null: return
	var motion_enabled := not preview_motion_enabled.is_valid() or bool(preview_motion_enabled.call())
	var weight := TableCameraMotion.zoom_weight(delta, motion_enabled)
	var changed := false
	if not preview_focus.is_equal_approx(preview_focus_goal):
		preview_focus = preview_focus.lerp(preview_focus_goal, weight)
		if preview_focus.distance_to(preview_focus_goal) < 0.005: preview_focus = preview_focus_goal
		changed = true
	if not is_equal_approx(preview_yaw, preview_yaw_goal):
		preview_yaw = lerp_angle(preview_yaw, preview_yaw_goal, weight)
		if absf(wrapf(preview_yaw - preview_yaw_goal, -PI, PI)) < 0.005: preview_yaw = preview_yaw_goal
		changed = true
	if not is_equal_approx(preview_pitch, preview_pitch_goal):
		preview_pitch = lerpf(preview_pitch, preview_pitch_goal, weight)
		if absf(preview_pitch - preview_pitch_goal) < 0.005: preview_pitch = preview_pitch_goal
		changed = true
	if changed: _update_preview_camera()

func _stop_preview_zoom() -> void:
	if preview_zoom_tween != null and preview_zoom_tween.is_running(): preview_zoom_tween.kill()
	preview_zoom_goal = preview_distance

func _animate_preview_zoom(target_distance: float) -> void:
	_stop_preview_zoom()
	preview_zoom_goal = target_distance
	if preview_motion_enabled.is_valid() and not preview_motion_enabled.call():
		_set_preview_distance(preview_zoom_goal)
		return
	preview_zoom_tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	preview_zoom_tween.tween_method(_set_preview_distance, preview_distance, preview_zoom_goal, 0.18)

func _preview_camera_input(event: InputEvent) -> void:
	if preview_asset.is_empty(): return
	if event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_MIDDLE):
		_stop_preview_zoom()
		preview_yaw -= event.relative.x * 0.006
		preview_pitch = clampf(preview_pitch + event.relative.y * 0.006, -1.3, 1.56)
		preview_yaw_goal = preview_yaw
		preview_pitch_goal = preview_pitch
		preview_focus_goal = preview_focus
		_update_preview_camera()
	elif event is InputEventMouseButton and event.pressed and event.button_index in [MOUSE_BUTTON_WHEEL_UP, MOUSE_BUTTON_WHEEL_DOWN]:
		var target_distance := clampf(preview_zoom_goal * (0.88 if event.button_index == MOUSE_BUTTON_WHEEL_UP else 1.0 / 0.88), 0.3, 150.0)
		_animate_preview_zoom(target_distance)

func _set_preview_distance(distance: float) -> void:
	preview_distance = distance
	_update_preview_camera()

func _update_preview_camera() -> void:
	preview_camera.position = preview_focus + TableCameraMotion.offset(preview_yaw, preview_pitch, preview_distance)
	preview_camera.look_at(preview_focus)
	preview_camera.far = maxf(100.0, preview_distance * 5.0)

func apply_mapping() -> void:
	last_linked_definition = ""
	linked_unit_button.visible = false
	if automatic_running or package_busy: return
	var definition := _definition()
	if definition.is_empty() or preview_asset.is_empty():
		notice.text = "Load a preview and select a roster unit or battlefield model first."
		return
	if preview_asset.path != mesh_path.text.strip_edges() or preview_asset.texture != texture_path.text.strip_edges():
		notice.text = "Reload the preview after changing its files."
		return
	var mapping := _settings()
	var fit_issue := Assets.visual_error_for_base(preview_asset, mapping)
	if (bool(preview_asset.get("source_pose", false)) or bool(mapping.get("require_full_miniature", false))) and not fit_issue.is_empty():
		notice.text = fit_issue
		return
	var package_error := ""
	if bool(preview_asset.get("source_pose", false)) and float(mapping.get("base_radius_inches", 0.0)) > 0.01:
		var current := _preview_package_request(mapping)
		package_busy = true
		notice.text = "Preparing local GLB before linking… Changing its target or fit cancels linking."
		var package := await prepare_preview_glb_async(mapping, current)
		package_busy = false
		if package.is_empty():
			notice.text = "Preview or target changed; the prepared package was not linked."
			return
		package_error = package.error
		if package_error.is_empty(): mapping.prepared_key = package.key
	mapping.erase("base_radius_inches")
	mapping.erase("visual_base_axes_inches")
	mapping.erase("visual_hull_proxy")
	mapping.erase("require_full_miniature")
	mapping.path = preview_asset.path
	mapping.texture = preview_asset.texture
	mapping.fingerprint = preview_asset.fingerprint
	mapping.texture_fingerprint = str(preview_asset.get("texture_fingerprint", ""))
	if preview_asset.get("source_parts") is Array and not preview_asset.source_parts.is_empty():
		mapping.parts = preview_asset.source_parts.duplicate(true)
	mapping.source = catalog.get("source", "")
	mapping.source_fingerprint = catalog.get("fingerprint", "")
	if not _selected_entry().is_empty():
		mapping.entry = _selected_entry().duplicate(true)
		mapping.source_group_hint = str(mapping.entry.get("source_group_hint", ""))
		if mapping.entry.get("tts_scale") is float or mapping.entry.get("tts_scale") is int:
			mapping.tts_scale = float(mapping.entry.tts_scale)
	if _mapping_has_unresolved_bundle_dependencies(mapping):
		notice.text = "This model still has missing Unity material dependencies. Download another compatible variant before linking it to a unit."
		return
	var next := mappings.duplicate(true)
	next[definition] = mapping
	if not _save(next): return
	mappings = next
	cache[definition] = preview_asset
	last_linked_definition = definition
	linked_unit_button.visible = has_roster_context.is_valid() and has_roster_context.call()
	mappings_changed.emit()
	notice.text = "✓ Linked locally for this unit type. Per-model variants take priority."
	if not package_error.is_empty(): notice.text += " Using the original files. " + package_error

func remove_mapping() -> void:
	last_linked_definition = ""
	linked_unit_button.visible = false
	if automatic_running: return
	var definition := _definition()
	if definition.is_empty():
		notice.text = "Select a roster unit or battlefield model first."
		return
	var next := mappings.duplicate(true)
	next.erase(definition)
	if not _save(next): return
	mappings = next
	cache.erase(definition)
	mappings_changed.emit()
	notice.text = "Placeholder restored for " + definition

func _save(next: Dictionary) -> bool:
	var cfg := ConfigFile.new()
	cfg.set_value("models", "version", 1)
	cfg.set_value("models", "mappings", next)
	cfg.set_value("models", "variants", variant_mappings)
	cfg.set_value("models", "unavailable_automatic_variants", unavailable_automatic_variants)
	cfg.set_value("models", "unavailable_variant_source_fingerprint", unavailable_variant_source_fingerprint)
	cfg.set_value("paths", "source", source_path.text.strip_edges())
	cfg.set_value("paths", "cache", cache_path.text.strip_edges())
	cfg.set_value("paths", "downloads", download_path.text.strip_edges())
	var temporary := settings_path + ".tmp"
	var error := cfg.save(temporary)
	if error == OK: error = DirAccess.rename_absolute(temporary, settings_path)
	if error != OK:
		notice.text = "Could not save local model settings: " + error_string(error)
		return false
	return true

func load_settings() -> void:
	if not FileAccess.file_exists(settings_path): return
	var cfg := ConfigFile.new()
	if cfg.load(settings_path) != OK or cfg.get_value("models", "version", 0) != 1 or not cfg.get_value("models", "mappings", {}) is Dictionary:
		notice.text = "Invalid local model settings; placeholders remain available."
		return
	for definition: Variant in cfg.get_value("models", "mappings", {}):
		var mapping: Variant = cfg.get_value("models", "mappings")[definition]
		if not definition is String or not mapping is Dictionary or not mapping.get("path") is String or not mapping.get("texture", "") is String: continue
		var valid := true
		for key: String in {"scale": [0.01, 20.0], "rotation": [-360.0, 360.0], "offset": [-10.0, 10.0]}:
			var value: Variant = mapping.get(key)
			var bounds: Array = {"scale": [0.01, 20.0], "rotation": [-360.0, 360.0], "offset": [-10.0, 10.0]}[key]
			if not (value is float or value is int) or not is_finite(float(value)) or float(value) < bounds[0] or float(value) > bounds[1]: valid = false
		var tts: Variant = mapping.get("tts_scale", 1.0)
		if mapping.has("tts_scale") and (not (tts is float or tts is int) or not is_finite(float(tts)) or float(tts) < 0.01 or float(tts) > 20.0): valid = false
		if valid: mappings[definition] = mapping
	var saved_variants: Variant = cfg.get_value("models", "variants", {})
	if saved_variants is Dictionary:
		for identity: Variant in saved_variants:
			var variant: Variant = saved_variants[identity]
			if identity is String and variant is Dictionary and variant.get("path") is String and variant.get("texture", "") is String:
				variant_mappings[identity] = variant
	var saved_unavailable_source: Variant = cfg.get_value("models", "unavailable_variant_source_fingerprint", "")
	var saved_unavailable: Variant = cfg.get_value("models", "unavailable_automatic_variants", {})
	if saved_unavailable_source is String and not saved_unavailable_source.is_empty() and saved_unavailable is Dictionary:
		unavailable_variant_source_fingerprint = saved_unavailable_source
		for key: Variant in saved_unavailable:
			var failure: Variant = saved_unavailable[key]
			if key is String and failure is Dictionary and str(failure.get("source_fingerprint", "")) == unavailable_variant_source_fingerprint:
				unavailable_automatic_variants[key] = failure
	var saved_source: Variant = cfg.get_value("paths", "source", "")
	if saved_source is String: source_path.text = saved_source
	var saved_cache: Variant = cfg.get_value("paths", "cache", "")
	if saved_cache is String: cache_path.text = saved_cache
	var saved_downloads: Variant = cfg.get_value("paths", "downloads", "")
	if saved_downloads is String and not saved_downloads.is_empty(): download_path.text = saved_downloads

func _automatic_variant_failure_key(definition: String, identity: String) -> String:
	return (definition + "\n" + identity).sha256_text()

func _automatic_variant_failure_is_current(key: String, source_fingerprint: String) -> bool:
	if key.is_empty() or source_fingerprint.is_empty(): return false
	var failure: Variant = unavailable_automatic_variants.get(key, {})
	return failure is Dictionary and str(failure.get("source_fingerprint", "")) == source_fingerprint

func _set_unavailable_variant_source(source_fingerprint: String) -> void:
	if source_fingerprint.is_empty() or source_fingerprint == unavailable_variant_source_fingerprint: return
	unavailable_variant_source_fingerprint = source_fingerprint
	unavailable_automatic_variants.clear()
	_save(mappings)
	_update_unavailable_variants_button()

func _remember_unavailable_automatic_variant(definition: String, entry: Dictionary, reason: String) -> void:
	if reason == "Could not save local variant settings.": return
	var identity := str(entry.get("variant_id", ""))
	if identity.is_empty() or catalog.is_empty() or str(catalog.get("fingerprint", "")).is_empty(): return
	var key := _automatic_variant_failure_key(definition, identity)
	var previous: Variant = unavailable_automatic_variants.get(key, null)
	unavailable_automatic_variants[key] = {
		"definition": definition,
		"variant_id": identity,
		"name": str(entry.get("name", "appearance variant")),
		"reason": reason.substr(0, 320),
		"source_fingerprint": str(catalog.fingerprint),
	}
	if not _save(mappings):
		if previous == null: unavailable_automatic_variants.erase(key)
		else: unavailable_automatic_variants[key] = previous
	_update_unavailable_variants_button()

func _allow_retry_unavailable_variants() -> void:
	if automatic_running or unavailable_automatic_variants.is_empty(): return
	var previous := unavailable_automatic_variants.duplicate(true)
	unavailable_automatic_variants.clear()
	if not _save(mappings):
		unavailable_automatic_variants = previous
		_update_unavailable_variants_button()
		return
	_update_unavailable_variants_button()
	if download_status != null:
		download_status.text = "Retry enabled. Start Tactical Training to prepare the previously unavailable appearance variants again."

func _update_unavailable_variants_button() -> void:
	if retry_unavailable_variants_button == null: return
	var count := unavailable_automatic_variants.size()
	retry_unavailable_variants_button.visible = count > 0
	retry_unavailable_variants_button.disabled = automatic_running or downloader != null and downloader.busy
	retry_unavailable_variants_button.text = "Retry %d unavailable appearance variant(s) on next preparation" % count

func _visual_settings(mapping: Dictionary, definition: String, base_radius_inches: float) -> Dictionary:
	var settings := mapping.duplicate()
	var effective_radius := base_radius_inches if base_radius_inches > 0.01 else _base_radius_for_definition(definition)
	if effective_radius > 0.01: settings.base_radius_inches = effective_radius
	_add_visual_footprint(settings, definition)
	return settings

func _prepared_visual(mapping: Dictionary, settings: Dictionary) -> Node3D:
	var key := str(mapping.get("prepared_key", ""))
	if key.is_empty(): return null
	var fit := Assets._package_fit(settings)
	var identity := key + str(fit)
	if not prepared_cache.has(identity):
		prepared_cache[identity] = Assets.load_prepared_glb(key, str(mapping.get("fingerprint", "")), settings)
	var prepared: Dictionary = prepared_cache[identity]
	if prepared.is_empty(): return null
	var root := Node3D.new()
	var scene: Node3D = prepared.scene.instantiate()
	root.scale = Vector3.ONE / 0.0254
	root.add_child(scene)
	root.set_meta("asset_base_footprint_inches", prepared.axes)
	root.set_meta("base_alignment_method", prepared.alignment)
	root.set_meta("base_center_offset_inches", Vector2.ZERO)
	return root

func visual_for(definition: String, base_radius_inches: float = 0.0) -> Node3D:
	if not mappings.has(definition): return null
	var settings := _visual_settings(mappings[definition], definition, base_radius_inches)
	var prepared := _prepared_visual(mappings[definition], settings)
	if prepared != null: return prepared
	if not cache.has(definition):
		var mapping: Dictionary = mappings[definition]
		if _mapping_has_unresolved_bundle_dependencies(mapping):
			notice.text = "Placeholder for %s: the saved model is missing Unity material dependencies and needs a refresh." % definition
			cache[definition] = {"error": "Unity material dependency missing"}
			return null
		var result := _load_mapping_asset(mapping)
		if not result.error.is_empty():
			notice.text = "Placeholder for %s: %s" % [definition, result.error]
			cache[definition] = result
			return null
		if result.fingerprint != mapping.get("fingerprint", "") or (not mapping.get("parts") is Array and result.texture_fingerprint != mapping.get("texture_fingerprint", "")):
			notice.text = "Placeholder: model file changed for %s. Preview and save it again." % definition
			cache[definition] = {"error": "Model changed"}
			return null
		cache[definition] = result
	if not cache[definition].get("error", "").is_empty(): return null
	var visual_issue := Assets.visual_error_for_base(cache[definition], settings)
	if not visual_issue.is_empty():
		notice.text = "Placeholder for %s: %s" % [definition, visual_issue]
		return null
	return Assets.visual(cache[definition], settings)

## Preview parsing uses the existing worker-safe asset loader. Resources enter the
## scene and textures upload only on the main thread. Requests may become obsolete.
func _preview_request_current(request: Callable) -> bool:
	return request.is_null() or (request.is_valid() and bool(request.call()))

func _background_preview_read(operation: Callable, request: Callable) -> Dictionary:
	while visual_preparation_busy:
		await get_tree().process_frame
		if not _preview_request_current(request): return {}
	if not _preview_request_current(request): return {}
	var worker := Thread.new()
	visual_preparation_busy = true
	preview_worker = worker
	if worker.start(operation) != OK:
		preview_worker = null
		visual_preparation_busy = false
		return {"error": "Background local-file preparation could not start."}
	await get_tree().process_frame
	while worker.is_alive(): await get_tree().process_frame
	# Reparenting/shutdown may already have joined this thread in _exit_tree.
	if not worker.is_started(): return {}
	var result: Variant = worker.wait_to_finish()
	if preview_worker == worker:
		preview_worker = null
		visual_preparation_busy = false
	if not _preview_request_current(request): return {}
	return result if result is Dictionary else {"error": "Local-file preparation returned an invalid result."}

func _exit_tree() -> void:
	if preview_worker != null and preview_worker.is_started(): preview_worker.wait_to_finish()
	preview_worker = null
	visual_preparation_busy = false

static func needs_background_preview(mapping: Dictionary) -> bool:
	var bytes := 0
	var parts: Array = mapping.get("parts", [])
	if parts.is_empty(): parts = [mapping]
	if parts.size() > 1: return true
	for part: Dictionary in parts:
		for key in ["path", "texture", "normal"]:
			var path := str(part.get(key, ""))
			if FileAccess.file_exists(path): bytes += FileAccess.get_size(path)
	return bytes > 131072

func _read_preview_mapping(mapping: Dictionary, request: Callable) -> Dictionary:
	if _mapping_has_unresolved_bundle_dependencies(mapping): return {"error": "Unity material dependency missing"}
	var result := await _background_preview_read(Callable(Assets, "load_mapping_asset_for_worker").bind(mapping.duplicate(true)), request)
	if result.is_empty(): return {}
	if str(result.get("error", "")).is_empty(): result = Assets.finalize_pending_textures(result)
	if not str(result.get("error", "")).is_empty(): return result
	if result.get("fingerprint", "") != mapping.get("fingerprint", "") or (not mapping.get("parts") is Array and result.get("texture_fingerprint", "") != mapping.get("texture_fingerprint", "")):
		return {"error": "Model changed; preview and link its current files again."}
	return result

func visual_for_async(definition: String, base_radius_inches: float = 0.0, request_is_current: Callable = Callable()) -> Node3D:
	if not mappings.has(definition): return null
	if not cache.has(definition):
		var result := await _read_preview_mapping(mappings[definition], request_is_current)
		if result.is_empty(): return null
		cache[definition] = result
	return visual_for(definition, base_radius_inches) if _preview_request_current(request_is_current) else null

func preview_visual_for_async(definition: String, request: Callable) -> Node3D:
	if not _preview_request_current(request): return null
	if not mappings.has(definition): return null
	if cache.has(definition) or not needs_background_preview(mappings[definition]): return visual_for(definition)
	return await visual_for_async(definition, 0.0, request)

func preview_variant_for_async(identity: String, request: Callable) -> Node3D:
	if not _preview_request_current(request): return null
	if not variant_mappings.has(identity): return null
	if variant_cache.has(identity) or not needs_background_preview(variant_mappings[identity]): return visual_variant_for(identity)
	var result := await _read_preview_mapping(variant_mappings[identity], request)
	if result.is_empty(): return null
	variant_cache[identity] = result
	return visual_variant_for(identity) if _preview_request_current(request) else null

func variants_for_async(definition: String, request: Callable) -> Array[Dictionary]:
	var path := source_path.text.strip_edges()
	if catalog.is_empty() and not path.is_empty() and path != last_variant_catalog_path:
		var scanned := await _background_preview_read(Callable(Assets, "scan").bind(path), request)
		if scanned.is_empty() or not _preview_request_current(request) or path != source_path.text.strip_edges(): return []
		last_variant_catalog_path = path
		if str(scanned.get("error", "")).is_empty(): catalog = scanned
		else: notice.text = str(scanned.error)
	if not _preview_request_current(request): return []
	var entries: Array = catalog.get("entries", [])
	if entries.size() <= 512: return variants_for(definition)
	var matched := await _background_preview_read(_match_preview_variants.bind(definition, entries), request)
	if matched.is_empty() or not _preview_request_current(request): return []
	var options: Array[Dictionary] = []
	options.assign(matched.get("options", []))
	return _decorate_variant_options(definition, options)

static func _match_preview_variants(definition: String, entries: Array) -> Dictionary:
	return {"options": Matcher.variants(definition, entries)}

func _load_mapping_asset(mapping: Dictionary) -> Dictionary:
	if mapping.get("parts") is Array and not mapping.parts.is_empty(): return Assets.composite_from_files(mapping.parts)
	return Assets.obj_mesh(str(mapping.get("path", "")), str(mapping.get("texture", "")))

func _mapping_has_unresolved_bundle_dependencies(mapping: Dictionary) -> bool:
	var parts: Variant = mapping.get("parts", [])
	if not parts is Array: return false
	for part: Variant in parts:
		if not part is Dictionary: continue
		var warnings: Variant = part.get("warnings", [])
		if not warnings is Array: continue
		for warning: Variant in warnings:
			var message := str(warning)
			if message.begins_with("External CAB dependency ") or message.begins_with("External CAB texture ") or message.begins_with("Declared Unity AssetBundle dependency "):
				return true
	return false

func _remember_variant_failure(identity: String, issue: String) -> void:
	var normalized_issue := issue.to_lower()
	var failed_conversion := "conversion" in normalized_issue or "converter" in normalized_issue or "unity bundle" in normalized_issue or "incompatible" in normalized_issue or "cannot be assembled" in normalized_issue or "manifest" in normalized_issue or "mesh" in normalized_issue or "parse" in normalized_issue
	variant_failure_status_by_id[identity] = {
		"state": "conversion_failed" if failed_conversion else "missing",
		"reason": issue + " Retry preparation from the Appearance tab when ready."
	}

func _add_visual_footprint(settings: Dictionary, definition: String) -> void:
	const PREFIX := "40kdc:11e:adeptus-astartes:"
	if not definition.begins_with(PREFIX): return
	var profile: Dictionary = MarineProfiles.profile(definition.trim_prefix(PREFIX))
	var keywords: Variant = profile.get("keywords", [])
	if keywords is Array and "INFANTRY" in keywords: settings.require_full_miniature = true
	if str(profile.get("base_size_source", "")).to_lower() == "use model":
		settings.visual_hull_proxy = true
	elif profile.get("base_geometry") == "oval":
		var axes: Array = profile.get("base_size_source_mm", [])
		if axes.size() == 2:
			settings.visual_base_axes_inches = Vector2(maxf(axes[0], axes[1]), minf(axes[0], axes[1])) / 25.4

func _base_radius_for_definition(definition: String) -> float:
	const prefix := "40kdc:11e:adeptus-astartes:"
	if not definition.begins_with(prefix): return 0.0
	var profile: Dictionary = MarineProfiles.profile(definition.trim_prefix(prefix))
	return float(profile.get("base_radius_inches", 0.0))

func variants_for(definition: String) -> Array[Dictionary]:
	var local_path := source_path.text.strip_edges()
	if catalog.is_empty() and not local_path.is_empty() and local_path != last_variant_catalog_path:
		last_variant_catalog_path = local_path
		var scanned := Assets.scan(local_path)
		if scanned.error.is_empty(): catalog = scanned
	var options: Array[Dictionary] = []
	if not catalog.is_empty(): options.assign(Matcher.variants(definition, catalog.get("entries", [])))
	return _decorate_variant_options(definition, options)

func visual_variant_status(identity: String, definition: String = "") -> Dictionary:
	var mapping_value: Variant = variant_mappings.get(identity, {})
	var option: Dictionary = {}
	if mapping_value is Dictionary and not mapping_value.is_empty():
		var mapping: Dictionary = mapping_value
		var definitions: Array = mapping.get("definitions", [mapping.get("definition", "")])
		if not definition.is_empty() and definition not in definitions:
			return {"state": "missing", "reason": "This saved visual is not mapped to the selected datasheet."}
		var option_value: Variant = mapping.get("entry", {})
		option = option_value if option_value is Dictionary else {}
	else:
		option = _variant_catalog_entry(identity)
		if option.is_empty(): return {"state": "missing", "reason": "This saved visual is not present in the current local catalog."}
		if not definition.is_empty() and definition not in option.get("visual_definitions", [option.get("definition", "")]):
			return {"state": "missing", "reason": "This saved visual is not mapped to the selected datasheet."}
	return _visual_variant_availability(identity, option)

func visual_default_status(definition: String) -> Dictionary:
	var mapping_value: Variant = mappings.get(definition, {})
	if not mapping_value is Dictionary or mapping_value.is_empty():
		return {"state": "missing", "reason": "No prepared default miniature is saved for this datasheet."}
	var cached_value: Variant = cache.get(definition, {})
	if cached_value is Dictionary and not str(cached_value.get("error", "")).is_empty():
		return {"state": "conversion_failed", "reason": str(cached_value.error)}
	var mapping: Dictionary = mapping_value
	if _mapping_has_unresolved_bundle_dependencies(mapping):
		return {"state": "conversion_failed", "reason": "The saved default miniature is missing Unity material dependencies."}
	if _mapping_files_available(mapping):
		return {"state": "ready", "reason": "The saved default miniature is available locally."}
	return {"state": "missing", "reason": "The saved default miniature files are unavailable locally."}

func _variant_catalog_entry(identity: String) -> Dictionary:
	var entries: Array = catalog.get("entries", []) if catalog.get("entries", []) is Array else []
	var index_key := "%s:%d" % [str(catalog.get("fingerprint", "")), entries.size()]
	if index_key != variant_catalog_index_key:
		variant_catalog_entries_by_id.clear()
		for entry: Variant in entries:
			if not entry is Dictionary: continue
			var entry_id := str(entry.get("variant_id", ""))
			if not entry_id.is_empty() and not variant_catalog_entries_by_id.has(entry_id): variant_catalog_entries_by_id[entry_id] = entry
		variant_catalog_index_key = index_key
	var option: Variant = variant_catalog_entries_by_id.get(identity, {})
	return option if option is Dictionary else {}

func _decorate_variant_options(definition: String, options: Array[Dictionary]) -> Array[Dictionary]:
	_refresh_variant_catalog_metadata(options)
	for identity: String in variant_mappings:
		var mapping: Dictionary = variant_mappings[identity]
		if definition not in mapping.get("definitions", [mapping.get("definition", "")]): continue
		var known := false
		for option: Dictionary in options:
			if str(option.get("variant_id", "")) == identity: known = true
		if not known:
			var entry: Dictionary = mapping.get("entry", {}).duplicate(true)
			entry.variant_id = identity
			options.append(entry)
	var paint_groups := {}
	for option: Dictionary in options:
		var identity := str(option.get("variant_id", ""))
		var availability := _visual_variant_availability(identity, option)
		option.availability = str(availability.get("state", "missing"))
		option.availability_reason = str(availability.get("reason", ""))
		option.ready = option.availability == "ready"
		var paint := Matcher.paint_reference(option)
		if paint.is_empty(): continue
		var geometry := Matcher.geometry_identity(option)
		if not paint_groups.has(geometry): paint_groups[geometry] = {}
		var textures: Dictionary = paint_groups[geometry]
		if not textures.has(paint): textures[paint] = textures.size() + 1
		option.paint_group = geometry
		option.paint_index = textures[paint]
	for option: Dictionary in options:
		option.paint_alternative = paint_groups.get(option.get("paint_group", ""), {}).size() > 1
	return options

func _visual_variant_availability(identity: String, option: Dictionary) -> Dictionary:
	if identity.is_empty(): return {"state": "missing", "reason": "This visual has no stable local identity."}
	var mapping_value: Variant = variant_mappings.get(identity, {})
	var mapping: Dictionary = mapping_value if mapping_value is Dictionary else {}
	if variant_download_active:
		if str(variant_current.get("variant_id", "")) == identity:
			return {"state": "downloading", "reason": "This visual is being prepared. A fallback remains available."}
		for queued: Dictionary in variant_queue:
			if str(queued.get("variant_id", "")) == identity:
				return {"state": "download_pending", "reason": "This visual is queued for preparation. A fallback remains available."}
	var failure_value: Variant = variant_failure_status_by_id.get(identity, {})
	if failure_value is Dictionary and not str(failure_value.get("state", "")).is_empty():
		return failure_value.duplicate(true)
	var cached_value: Variant = variant_cache.get(identity, {})
	if cached_value is Dictionary and not str(cached_value.get("error", "")).is_empty():
		var cached_error := str(cached_value.get("error", ""))
		var cached_error_lower := cached_error.to_lower()
		var failed_conversion := "conversion" in cached_error_lower or "converter" in cached_error_lower or "unity bundle" in cached_error_lower or "incompatible" in cached_error_lower or "mesh" in cached_error_lower
		return {"state": "conversion_failed" if failed_conversion else "missing", "reason": cached_error + " Prepare the appearance again to retry."}
	if _mapping_files_available(mapping): return {"state": "ready", "reason": "All required model files are available locally."}
	if _mapping_has_unresolved_bundle_dependencies(mapping):
		return {"state": "conversion_failed", "reason": "A required Unity material dependency is missing. Prepare this variant again from Models / Import."}
	if not option.is_empty():
		return {"state": "download_pending", "reason": "This catalog visual is not prepared locally. Select Prepare appearances to cache it; the fallback remains available."}
	if not mapping.is_empty():
		return {"state": "missing", "reason": "The saved visual files are unavailable locally. Its saved assignment is preserved and the fallback remains available."}
	return {"state": "missing", "reason": "This visual is not present in the current local catalog. Its saved assignment is preserved and the fallback remains available."}

func _refresh_variant_catalog_metadata(options: Array[Dictionary]) -> void:
	for option: Dictionary in options:
		var identity := str(option.get("variant_id", ""))
		if not variant_mappings.has(identity) or not option.has("visual_definitions"): continue
		var mapping: Dictionary = variant_mappings[identity]
		# A rebuilt source index also enriches already downloaded files. Local
		# paths, mount settings and explicit assignments remain untouched.
		mapping.entry = option.duplicate(true)
		if not str(option.get("visual_role", "")).is_empty(): mapping.visual_role = str(option.visual_role)

func download_variants_for(definition: String, selected_identity: String = "") -> void:
	if downloader.busy or automatic_running or variant_download_active:
		download_status.text = "Finish or cancel the current model download first."
		automatic_status.emit(download_status.text)
		return
	if catalog.is_empty():
		var candidate := source_path.text.strip_edges()
		if candidate.is_empty():
			for path in ["user://ForceOrg.json", "res://ForceOrg.json", OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS).path_join("My Games/Tabletop Simulator/Saves/ForceOrg.json")]:
				if FileAccess.file_exists(path):
					candidate = path
					break
		if not candidate.is_empty():
			var scanned := Assets.scan(candidate)
			if scanned.error.is_empty():
				catalog = scanned
				source_path.text = candidate
			else:
				download_status.text = scanned.error
				automatic_status.emit(download_status.text)
				return
		else:
			variant_catalog_definition = definition
			variant_catalog_identity = selected_identity
			variant_catalog_pending = true
			download_status.text = "Downloading the model catalog…"
			automatic_status.emit(download_status.text)
			var issue: String = catalog_downloader.start()
			if not issue.is_empty():
				variant_catalog_pending = false
				download_status.text = issue
				automatic_status.emit(download_status.text)
			return
	_start_variant_downloads(definition, selected_identity)

func _requested_variants(options: Array[Dictionary], automatic_count: int, manual: Array, definition: String = "") -> Array[Dictionary]:
	var chosen: Array[Dictionary] = []
	var geometries := {}
	if not definition.is_empty(): options = _locally_ready_equivalent_variants(options, definition)
	for option: Dictionary in options:
		if option.get("variant_id") in manual:
			chosen.append(option)
			continue
		# A role/loadout sculpt is only for its tagged model. Never spend a shared
		# unit-appearance slot on a Sergeant-specific visual.
		if not str(option.get("visual_role", "")).is_empty(): continue
		if automatic_count <= 0: continue
		var geometry := Matcher.geometry_identity(option)
		if geometries.has(geometry): continue
		geometries[geometry] = true
		automatic_count -= 1
		chosen.append(option)
	return chosen

func _locally_ready_equivalent_variants(options: Array[Dictionary], definition: String) -> Array[Dictionary]:
	if options.size() < 2: return options
	var group_key := _visual_choice_group_key(options[0])
	for option: Dictionary in options:
		if _visual_choice_group_key(option) != group_key: return options
	var ranked: Array[Dictionary] = []
	for option: Dictionary in options:
		ranked.append({"priority": _local_variant_priority(option, definition), "identity": str(option.get("variant_id", "")), "entry": option})
	ranked.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		if int(a.priority) != int(b.priority): return int(a.priority) < int(b.priority)
		return str(a.identity) < str(b.identity)
	)
	var result: Array[Dictionary] = []
	for row: Dictionary in ranked: result.append(row.entry)
	return result

func _visual_choice_group_key(entry: Dictionary) -> String:
	return JSON.stringify([
		str(entry.get("name", "")).strip_edges().to_lower(),
		str(entry.get("visual_role", "")),
		str(entry.get("visual_model_role", "")),
		entry.get("visual_role_constraints", {}),
		entry.get("visual_weapons", []),
		entry.get("visual_weapon_aliases", {}),
		entry.get("visual_definitions", [])
	])

func _local_variant_priority(entry: Dictionary, definition: String) -> int:
	var identity := str(entry.get("variant_id", ""))
	var mapping: Dictionary = variant_mappings.get(identity, {})
	var definitions: Array = mapping.get("definitions", [mapping.get("definition", "")])
	if not mapping.is_empty() and definition in definitions and _mapping_files_available(mapping): return 0
	var indexes: Array[Dictionary] = []
	if not automatic_index.is_empty():
		indexes.append(automatic_index)
		var external: Variant = automatic_index.get("external", {})
		if external is Dictionary and not external.is_empty(): indexes.append(external)
	for index: Dictionary in indexes:
		if not str(index.get("error", "")).is_empty(): continue
		var resolved := Assets.resolve_cache(entry, index)
		if not str(resolved.get("error", "")).is_empty(): continue
		if str(_cached_component_files(resolved).get("error", "")).is_empty(): return 1
	return 2

func _start_variant_downloads(definition: String, selected_identity: String = "") -> void:
	variant_download_definition = definition
	variant_queue.clear()
	variant_failures.clear()
	var options := Matcher.variants(definition, catalog.get("entries", []))
	_refresh_variant_catalog_metadata(options)
	options = _requested_variants(options, 4 if selected_identity.is_empty() else 0, [] if selected_identity.is_empty() else [selected_identity])
	if options.is_empty():
		download_status.text = "No compatible complete OBJ variants were found for this unit."
		automatic_status.emit(download_status.text)
		return
	for entry: Dictionary in options:
		var identity := str(entry.get("variant_id", ""))
		var cached_value: Variant = variant_cache.get(identity, {})
		var has_load_error := cached_value is Dictionary and not str(cached_value.get("error", "")).is_empty()
		var retry_failed_selection := identity == selected_identity and (variant_failure_status_by_id.has(identity) or has_load_error)
		variant_failure_status_by_id.erase(identity)
		if retry_failed_selection:
			entry.force_refresh = true
			variant_cache.erase(identity)
			variant_queue.append(entry)
		elif not _mapping_files_available(variant_mappings.get(identity, {})):
			variant_queue.append(entry)
	if variant_queue.is_empty():
		download_status.text = "All compatible visual variants are already in the local cache."
		automatic_status.emit(download_status.text)
		variants_changed.emit(definition)
		return
	variant_download_active = true
	download_status.text = "Preparing %d visual variant(s) for %s…" % [variant_queue.size(), definition]
	automatic_status.emit(download_status.text)
	_next_variant_download()

func _next_variant_download() -> void:
	if variant_queue.is_empty():
		variant_download_active = false
		download_status.text = "Visuals ready for %s. %d variant(s) unavailable; affected miniatures keep the default." % [variant_download_definition, variant_failures.size()]
		if not variant_failures.is_empty(): download_status.text += "\n" + "\n".join(variant_failures.slice(0, 3))
		automatic_status.emit(download_status.text)
		variants_changed.emit(variant_download_definition)
		return
	variant_current = variant_queue.pop_front()
	if not bool(variant_current.get("force_refresh", false)):
		var cache_index := Assets.index_cache(download_path.text.strip_edges())
		var resolved := Assets.resolve_cache(variant_current, cache_index) if not cache_index.is_empty() and cache_index.get("error", "").is_empty() else {}
		if not resolved.is_empty() and resolved.get("error", "").is_empty():
			var cached_parts := _cached_component_files(resolved)
			if cached_parts.error.is_empty():
				_finish_variant_download({"error": "", "parts": cached_parts.parts, "mesh": cached_parts.parts[0].path, "texture": cached_parts.parts[0].texture})
				return
	download_status.text = "Downloading %s…" % str(variant_current.get("name", "visual variant"))
	automatic_status.emit(download_status.text)
	var issue: String = downloader.start(variant_current, download_path.text.strip_edges())
	if not issue.is_empty(): _finish_variant_download({"error": issue})

func _finish_variant_download(result: Dictionary) -> void:
	var issue := str(result.get("error", ""))
	var identity := str(variant_current.get("variant_id", ""))
	if issue.is_empty():
		var ticket := automatic_generation
		var current := func() -> bool: return is_inside_tree() and ticket == automatic_generation and identity == str(variant_current.get("variant_id", ""))
		var asset := await _downloaded_asset_async(result, current)
		if asset.is_empty() or not current.call(): return
		issue = str(asset.get("error", ""))
		if issue.is_empty() and _mapping_has_unresolved_bundle_dependencies({"parts": result.get("parts", [])}):
			issue = "The Unity bundle is missing a required material dependency."
		if issue.is_empty():
			var fit_settings := _visual_settings({}, variant_download_definition, _base_radius_for_definition(variant_download_definition))
			issue = Assets.visual_error_for_base(asset, fit_settings)
		if issue.is_empty():
			var entry_to_store: Dictionary = variant_current.duplicate(true)
			entry_to_store.erase("force_refresh")
			issue = _store_variant(variant_download_definition, entry_to_store, result, asset)
	if not issue.is_empty():
		variant_failures.append(str(variant_current.get("name", "variant")) + ": " + issue)
		_remember_variant_failure(identity, issue)
		download_status.text = "Variant unavailable: " + issue
	else:
		variant_failure_status_by_id.erase(identity)
		download_status.text = "Saved local visual variant: " + str(variant_current.get("name", "visual variant"))
	automatic_status.emit(download_status.text)
	if variant_download_active: call_deferred("_next_variant_download")

func _store_variant(definition: String, entry: Dictionary, result: Dictionary, asset: Dictionary) -> String:
	var identity := str(entry.get("variant_id", ""))
	var previous: Dictionary = variant_mappings.get(identity, {})
	var failure_key := _automatic_variant_failure_key(definition, identity)
	var previous_failure: Variant = unavailable_automatic_variants.get(failure_key, null)
	var definitions: Array = previous.get("definitions", [previous.get("definition", definition)]).duplicate()
	if definition not in definitions: definitions.append(definition)
	var tts := float(entry.get("tts_scale", 1.0))
	if not is_finite(tts) or tts < 0.01 or tts > 20.0: tts = 1.0
	var mapping := {"definition": definition, "definitions": definitions, "path": str(result.mesh), "texture": str(result.texture),
		"fingerprint": asset.fingerprint, "texture_fingerprint": str(asset.get("texture_fingerprint", "")),
		"scale": 1.0, "rotation": 0.0, "offset": 0.0, "tts_scale": tts, "entry": entry.duplicate(true)}
	mapping.source_group_hint = str(entry.get("source_group_hint", ""))
	if not str(entry.get("visual_role", "")).is_empty(): mapping["visual_role"] = str(entry.visual_role)
	if result.get("parts") is Array: mapping.parts = result.parts.duplicate(true)
	variant_mappings[identity] = mapping
	unavailable_automatic_variants.erase(failure_key)
	if not _save(mappings):
		if previous.is_empty(): variant_mappings.erase(identity)
		else: variant_mappings[identity] = previous
		if previous_failure != null: unavailable_automatic_variants[failure_key] = previous_failure
		return "Could not save local variant settings."
	variant_cache[identity] = asset
	_update_unavailable_variants_button()
	return ""

func automatic_variant_for(definition: String, slot: int, source_family: String = "") -> String:
	var candidates := automatic_variants_for(definition, slot, source_family)
	return candidates[0] if not candidates.is_empty() else ""

## Returns every distinct shared sculpt in stable appearance order. Rendering tries
## each candidate so a missing or incompatible first choice does not hide another
## usable local miniature.
func automatic_variants_for(definition: String, slot: int, source_family: String = "") -> Array[String]:
	var available: Array[String] = []
	for identity: String in variant_mappings:
		var mapping: Dictionary = variant_mappings[identity]
		if definition not in mapping.get("definitions", [mapping.get("definition", "")]): continue
		if not str(mapping.get("visual_role", "")).is_empty(): continue
		if not source_family.strip_edges().is_empty() and _source_group_for_mapping(mapping) != source_family.strip_edges().to_lower(): continue
		available.append(identity)
	available.sort()
	var geometry_representatives := {}
	for identity: String in available:
		var mapping: Dictionary = variant_mappings[identity]
		if str(mapping.get("geometry", "")).is_empty():
			var entry: Dictionary = mapping.get("entry", {})
			mapping.geometry = Matcher.geometry_identity(entry) if not entry.is_empty() else identity
			if str(mapping.geometry).is_empty(): mapping.geometry = identity
		var package_ready := not str(mapping.get("prepared_key", "")).is_empty()
		var candidate := {"identity": identity, "available": package_ready or _mapping_files_available(mapping)}
		var geometry := str(mapping.geometry)
		var current: Dictionary = geometry_representatives.get(geometry, {})
		if current.is_empty() or (bool(candidate.available) and not bool(current.available)):
			geometry_representatives[geometry] = candidate
		elif bool(candidate.available) == bool(current.available) and identity < str(current.identity):
			geometry_representatives[geometry] = candidate
	var ranked: Array[Dictionary] = []
	for candidate: Variant in geometry_representatives.values():
		if candidate is Dictionary: ranked.append(candidate)
	ranked.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		if bool(a.available) != bool(b.available): return bool(a.available)
		return str(a.identity) < str(b.identity)
	)
	var sculpts: Array[String] = []
	for row: Dictionary in ranked: sculpts.append(str(row.identity))
	var result: Array[String] = []
	if sculpts.is_empty(): return result
	var start := posmod(slot, sculpts.size())
	for offset in sculpts.size(): result.append(sculpts[(start + offset) % sculpts.size()])
	return result

func visual_family_for(identity: String, definition: String = "", slot: int = 0, allow_automatic_fallback: bool = true) -> String:
	var mapping: Dictionary = variant_mappings.get(identity, {}) if not identity.is_empty() else {}
	var family := _source_group_for_mapping(mapping) if not mapping.is_empty() else ""
	if family.is_empty() and not identity.is_empty(): family = _source_group_for_variant_identity(identity)
	if not family.is_empty(): return family
	if allow_automatic_fallback and mapping.is_empty() and not definition.is_empty():
		var automatic := automatic_variant_for(definition, slot)
		mapping = variant_mappings.get(automatic, {}) if not automatic.is_empty() else {}
		family = _source_group_for_mapping(mapping) if not mapping.is_empty() else ""
		if family.is_empty() and not automatic.is_empty(): family = _source_group_for_variant_identity(automatic)
		if not family.is_empty(): return family
		mapping = mappings.get(definition, {})
		family = _source_group_for_mapping(mapping) if not mapping.is_empty() else ""
		if not family.is_empty(): return family
		var chosen := Matcher.choose(definition, catalog.get("entries", []))
		if chosen.error.is_empty(): return Assets.visual_family_hint(chosen.entry)
	return ""

func visual_variant_is_ready(identity: String, definition: String = "") -> bool:
	if not identity.is_empty():
		var cached: Dictionary = variant_cache.get(identity, {})
		if not str(cached.get("error", "")).is_empty(): return false
		return _mapping_files_available(variant_mappings.get(identity, {}))
	return not definition.is_empty() and _mapping_files_available(mappings.get(definition, {}))

func _source_group_for_variant_identity(identity: String) -> String:
	for candidate: Dictionary in catalog.get("entries", []):
		if str(candidate.get("variant_id", "")) == identity:
			return Assets.visual_family_hint(candidate)
	return ""

func _role_variant_ids_for_families(options: Array[Dictionary], role_families: Array) -> Array[String]:
	var accepted_families := {}
	for family: Variant in role_families:
		var normalized := str(family).strip_edges().to_lower()
		if not normalized.is_empty(): accepted_families[normalized] = true
	var identities: Array[String] = []
	if accepted_families.is_empty(): return identities
	for option: Dictionary in options:
		if str(option.get("visual_role", "")).is_empty(): continue
		var identity := str(option.get("variant_id", ""))
		var family := Assets.visual_family_hint(option)
		if identity.is_empty() or not accepted_families.has(family) or identity in identities: continue
		identities.append(identity)
	identities.sort()
	return identities

func _source_group_for_mapping(mapping: Dictionary) -> String:
	var family := str(mapping.get("source_group_hint", "")).strip_edges()
	var entry: Dictionary = mapping.get("entry", {})
	if family.is_empty(): family = Assets.visual_family_hint(entry)
	if not family.is_empty(): return family.to_lower()
	var guid := str(entry.get("guid", "")).strip_edges()
	var path := str(entry.get("path", "")).strip_edges()
	if guid.is_empty() and path.is_empty(): return ""
	for candidate: Dictionary in catalog.get("entries", []):
		if (not guid.is_empty() and str(candidate.get("guid", "")) == guid) or (not path.is_empty() and str(candidate.get("path", "")) == path):
			return Assets.visual_family_hint(candidate)
	return ""

func visual_role_variant_for(role: String, source_family: String = "", include_other_families: bool = false) -> String:
	var preferred_family := source_family.strip_edges().to_lower()
	if role.is_empty() or (preferred_family.is_empty() and not include_other_families): return ""
	var role_candidates: Array[String] = [role]
	if role == Matcher.INTERCESSOR_SERGEANT_DEFAULT_ROLE:
		role_candidates.append("intercessor-sergeant:bolt-rifle|knives-and-fists")
	for requested_role: String in role_candidates:
		var matches: Array[Dictionary] = []
		for identity: String in variant_mappings:
			var mapping: Dictionary = variant_mappings[identity]
			if str(mapping.get("visual_role", "")) != requested_role or not _mapping_files_available(mapping): continue
			var family := _source_group_for_mapping(mapping)
			if not include_other_families and family != preferred_family: continue
			matches.append({"identity": identity, "same_family": not preferred_family.is_empty() and family == preferred_family})
		matches.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
			if not preferred_family.is_empty() and bool(a.same_family) != bool(b.same_family): return bool(a.same_family)
			return str(a.identity) < str(b.identity))
		if not matches.is_empty(): return str(matches[0].identity)
	return ""

func equipment_variant_for(unit: Dictionary, source_family: String) -> String:
	var options := equipment_variants_for(unit, source_family)
	return options[0] if not options.is_empty() else ""

func equipment_variants_for(unit: Dictionary, source_family: String) -> Array[String]:
	var groups := equipment_variant_groups_for(unit, source_family)
	var options: Array[String] = []
	for identity: String in groups.get("same_family", []): options.append(identity)
	return options

func ordered_equipment_visual_variants_for(unit: Dictionary, source_family: String, allow_other_families: bool = true) -> Array[String]:
	var options: Array[String] = []
	var role := Matcher.intercessor_model_visual_role(unit)
	var groups := equipment_variant_groups_for(unit, source_family)
	for identity: String in groups.get("same_family", []): options.append(identity)
	var role_identity := ""
	if not role.is_empty():
		role_identity = visual_role_variant_for(role, source_family)
		if not role_identity.is_empty() and role_identity not in options: options.append(role_identity)
	if allow_other_families:
		for identity: String in groups.get("other_families", []):
			if identity not in options: options.append(identity)
	if role.is_empty(): return options
	if allow_other_families:
		role_identity = visual_role_variant_for(role, source_family, true)
		if not role_identity.is_empty() and role_identity not in options: options.append(role_identity)
	if role.begins_with("intercessor-sergeant:") and role != Matcher.INTERCESSOR_SERGEANT_DEFAULT_ROLE:
		role_identity = visual_role_variant_for(Matcher.INTERCESSOR_SERGEANT_DEFAULT_ROLE, source_family)
		if not role_identity.is_empty() and role_identity not in options: options.append(role_identity)
		if allow_other_families:
			role_identity = visual_role_variant_for(Matcher.INTERCESSOR_SERGEANT_DEFAULT_ROLE, source_family, true)
			if not role_identity.is_empty() and role_identity not in options: options.append(role_identity)
	return options

func equipment_variant_groups_for(unit: Dictionary, source_family: String) -> Dictionary:
	var same_family_options: Array[Dictionary] = []
	var other_family_options: Array[Dictionary] = []
	var definition := str(unit.get("definition_id", ""))
	var preferred_family := source_family.strip_edges().to_lower()
	for identity: String in variant_mappings:
		var mapping: Dictionary = variant_mappings[identity]
		if definition not in mapping.get("definitions", [mapping.get("definition", "")]): continue
		if not _mapping_files_available(mapping): continue
		var score := Matcher.equipment_visual_score(mapping.get("entry", {}), definition, unit)
		if score <= 0: continue
		var family := _source_group_for_mapping(mapping)
		var candidate := {"id": identity, "score": score}
		if not preferred_family.is_empty() and family == preferred_family:
			same_family_options.append(candidate)
		else:
			other_family_options.append(candidate)
	var sort_equipment := func(a: Dictionary, b: Dictionary) -> bool:
		return str(a.id) < str(b.id) if int(a.score) == int(b.score) else int(a.score) > int(b.score)
	same_family_options.sort_custom(sort_equipment)
	other_family_options.sort_custom(sort_equipment)
	var same_family_ids: Array[String] = []
	var other_family_ids: Array[String] = []
	for candidate: Dictionary in same_family_options: same_family_ids.append(str(candidate.id))
	for candidate: Dictionary in other_family_options: other_family_ids.append(str(candidate.id))
	return {"same_family": same_family_ids, "other_families": other_family_ids}

func visual_variant_for(identity: String, base_radius_inches: float = 0.0) -> Node3D:
	if identity.is_empty() or not variant_mappings.has(identity): return null
	if _mapping_has_unresolved_bundle_dependencies(variant_mappings[identity]):
		var dependency_issue := "This saved variant is missing Unity material dependencies. Prepare it again to retry conversion."
		variant_cache[identity] = {"error": dependency_issue}
		_remember_variant_failure(identity, dependency_issue)
		download_status.text = dependency_issue
		return null
	if not variant_cache.has(identity):
		var mapping: Dictionary = variant_mappings[identity]
		var asset := _load_mapping_asset(mapping)
		if not asset.error.is_empty() or asset.fingerprint != mapping.get("fingerprint", "") or (not mapping.get("parts") is Array and asset.texture_fingerprint != mapping.get("texture_fingerprint", "")):
			var issue := str(asset.get("error", ""))
			if issue.is_empty(): issue = "The saved model files changed after import."
			issue += " Prepare the appearance again to replace the local cache entry."
			download_status.text = issue + " Trying another available miniature."
			variant_cache[identity] = {"error": issue}
			_remember_variant_failure(identity, issue)
			return null
		variant_cache[identity] = asset
	if not variant_cache[identity].get("error", "").is_empty(): return null
	var settings := _visual_settings(variant_mappings[identity], str(variant_mappings[identity].get("definition", "")), base_radius_inches)
	var visual_issue := Assets.visual_error_for_base(variant_cache[identity], settings)
	if not visual_issue.is_empty():
		download_status.text = "This local variant is incompatible with the miniature's base; trying another available miniature."
		return null
	return Assets.visual(variant_cache[identity], settings)

## Batch uses captured profile IDs, independent of the selected pawn or inventory row.
func prepare_armies(definitions: Array[String], force_refresh_saved: bool = false, source_pose_pilot: bool = false, variant_requests: Dictionary = {}) -> bool:
	if (downloader.busy or variant_download_active) and not automatic_running:
		automatic_status.emit("A manual model download is running. Retry automatic models when it finishes.")
		return false
	cancel_automatic()
	automatic_source_pose_pilot = source_pose_pilot
	automatic_variant_requests = variant_requests.duplicate(true)
	automatic_started_usec = Time.get_ticks_usec()
	automatic_messages.clear()
	automatic_repair_definitions.clear()
	automatic_ready = 0
	automatic_appearance_total = 0
	automatic_appearance_ready = 0
	automatic_appearance_skipped = 0
	automatic_total = definitions.size()
	var missing: Array[String] = []
	for definition: String in definitions:
		var saved_mapping: Variant = mappings.get(definition, {})
		if force_refresh_saved:
			cache.erase(definition)
			automatic_repair_definitions.append(definition)
			missing.append(definition)
			automatic_messages.append(("Rebuilding visual with the opt-in ForceOrg source-pose pilot: " if source_pose_pilot else "Revalidating unavailable visual: ") + definition)
			continue
		if saved_mapping is Dictionary and _mapping_has_unresolved_bundle_dependencies(saved_mapping):
			cache.erase(definition)
			automatic_repair_definitions.append(definition)
			missing.append(definition)
			automatic_messages.append("Refreshing saved model with missing Unity materials: " + definition)
			continue
		if saved_mapping is Dictionary and _mapping_files_available(saved_mapping):
			automatic_ready += 1
			automatic_messages.append("Reused saved model: " + definition)
		elif mappings.has(definition):
			automatic_repair_definitions.append(definition)
			missing.append(definition)
			automatic_messages.append("Repairing saved model link: " + definition)
		else: missing.append(definition)
	if missing.is_empty() and variant_requests.is_empty():
		_finish_automatic_batch()
		return true
	var path := source_path.text.strip_edges()
	if path.is_empty():
		for candidate: String in ["user://ForceOrg.json", "res://ForceOrg.json", OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS).path_join("My Games/Tabletop Simulator/Saves/ForceOrg.json")]:
			if FileAccess.file_exists(candidate):
				path = candidate
				source_path.text = path
				break
	if path.is_empty():
		catalog_definitions = definitions.duplicate()
		automatic_running = true
		automatic_status.emit("Downloading ForceOrg catalog; the match is playable while models are prepared.")
		var issue: String = catalog_downloader.start()
		if not issue.is_empty():
			automatic_running = false
			automatic_messages.append(issue)
			_finish_automatic_batch()
		return true
	var source_file := path.path_join("ForceOrg.json") if DirAccess.dir_exists_absolute(path) else path
	var background := FileAccess.file_exists(source_file) and FileAccess.get_size(source_file) > 131072
	automatic_running = true
	if background:
		download_status.text = "Preparing the local model catalog and appearance choices…"
		automatic_status.emit(download_status.text)
	_prepare_automatic_plan(path, missing.duplicate(), variant_requests.duplicate(true), automatic_generation, background)
	return true

## The worker reads source/cache metadata and selects candidates only. Live queues,
## mappings, signals and all persistence remain owned by the main thread.
static func _build_automatic_plan(path: String, missing: Array[String], requests: Dictionary) -> Dictionary:
	var scanned := Assets.scan(path)
	if not str(scanned.get("error", "")).is_empty(): return {"catalog": scanned}
	var chosen := {}
	for definition: String in missing: chosen[definition] = Matcher.choose(definition, scanned.entries)
	var variants := {}
	for definition: String in requests: variants[definition] = Matcher.variants(definition, scanned.entries)
	return {"catalog": scanned, "chosen": chosen, "variants": variants}

func _build_automatic_cache_index(download_folder: String, external_folder: String) -> Dictionary:
	var index := Assets.index_cache(download_folder)
	if not external_folder.is_empty(): index["external"] = Assets.index_cache(external_folder)
	return index

func _prepare_automatic_plan(path: String, missing: Array[String], variant_requests: Dictionary, ticket: int, background: bool) -> void:
	var operation := _build_automatic_plan.bind(path, missing, variant_requests)
	var current := func() -> bool: return is_inside_tree() and automatic_running and ticket == automatic_generation
	var plan: Dictionary = await _background_preview_read(operation, current) if background else operation.call()
	if not current.call(): return
	if plan.is_empty() or path != source_path.text.strip_edges():
		automatic_messages.append("The local model source changed during preparation; retry with the current source.")
		# Reused defaults do not establish that the requested appearances are ready.
		for definition: String in variant_requests:
			var request: Dictionary = variant_requests[definition]
			automatic_appearance_total += maxi(1, maxi(int(request.get("count", 0)), request.get("manual", []).size()))
		_finish_automatic_batch()
		return
	var scanned: Dictionary = plan.catalog
	if not scanned.error.is_empty():
		automatic_messages.append(scanned.error + " — choose the ForceOrg JSON in Models and retry.")
		for definition: String in variant_requests:
			var request: Dictionary = variant_requests[definition]
			automatic_appearance_total += maxi(1, maxi(int(request.get("count", 0)), request.get("manual", []).size()))
		_finish_automatic_batch()
		return
	catalog = scanned
	_set_unavailable_variant_source(str(scanned.get("fingerprint", "")))
	_save(mappings)
	_populate_inventory()
	automatic_index = {}
	for definition: String in missing:
		var chosen: Dictionary = plan.chosen[definition]
		if not chosen.error.is_empty(): automatic_messages.append(chosen.error)
		else:
			var options: Array[Dictionary] = chosen.get("options", []).duplicate(true)
			options = _locally_ready_equivalent_variants(options, definition)
			var chosen_entry: Dictionary = options[0].duplicate(true) if not options.is_empty() else chosen.entry.duplicate(true)
			if automatic_source_pose_pilot:
				chosen_entry["preserve_source_pose"] = true
				for option: Variant in options:
					if option is Dictionary: option["preserve_source_pose"] = true
			automatic_queue.append({"definition": definition, "entry": chosen_entry, "options": options, "variant_index": 0})
			var alias_note := "; reviewed visual-only alias, rules unchanged" if bool(chosen.get("visual_alias", false)) else ""
			automatic_messages.append("Selected %s (%d compatible visual variants%s; change in Models)." % [chosen.entry.name, chosen.variants, alias_note])
	for definition: String in variant_requests:
		var request: Dictionary = variant_requests[definition]
		var count := clampi(int(request.get("count", 0)), 0, 4)
		var options: Array[Dictionary] = []
		options.assign(plan.variants[definition])
		_refresh_variant_catalog_metadata(options)
		var manual: Array = request.get("manual", []).duplicate()
		if bool(request.get("all_role_variants", false)):
			var role_families: Array = request.get("role_families", []) if request.get("role_families", []) is Array else []
			for identity: String in _role_variant_ids_for_families(options, role_families):
				if identity not in manual: manual.append(identity)
		var remaining := manual.duplicate()
		for option: Dictionary in _requested_variants(options, count if count > 1 else 0, manual, definition):
			var identity := str(option.get("variant_id", ""))
			remaining.erase(identity)
			automatic_appearance_total += 1
			var cached_mapping: Dictionary = variant_mappings.get(identity, {})
			if definition in cached_mapping.get("definitions", [cached_mapping.get("definition", "")]) and _mapping_files_available(cached_mapping):
				automatic_appearance_ready += 1
				continue
			var failure_key := _automatic_variant_failure_key(definition, identity)
			if _automatic_variant_failure_is_current(failure_key, str(scanned.get("fingerprint", ""))):
				automatic_appearance_skipped += 1
				continue
			automatic_queue.append({"definition": definition, "entry": option, "appearance_variant": true})
		for identity: String in remaining:
			automatic_appearance_total += 1
			if _mapping_files_available(variant_mappings.get(identity, {})):
				automatic_appearance_ready += 1
			else:
				automatic_appearance_skipped += 1
				automatic_messages.append("A saved appearance for %s is not available in this catalog; using an available fallback." % definition)
	if automatic_appearance_skipped > 0:
		automatic_messages.append("Skipped %d unavailable appearance variant(s); available fallbacks will be used. See Models / Import to retry recorded download failures." % automatic_appearance_skipped)
	if not automatic_queue.is_empty():
		var index_operation := Callable(self, "_build_automatic_cache_index").bind(download_path.text.strip_edges(), cache_path.text.strip_edges())
		var indexed: Dictionary = await _background_preview_read(index_operation, current)
		if not current.call(): return
		if indexed.is_empty():
			automatic_messages.append("Local model-cache scan was cancelled; queued downloads will use the selected ForceOrg source.")
		else: automatic_index = indexed
		for queue_index in range(automatic_queue.size()):
			var queued: Dictionary = automatic_queue[queue_index]
			if not bool(queued.get("appearance_variant", false)):
				var ordered_options: Array[Dictionary] = _locally_ready_equivalent_variants(queued.get("options", []), str(queued.get("definition", "")))
				if not ordered_options.is_empty():
					queued["options"] = ordered_options
					queued["entry"] = ordered_options[0].duplicate(true)
					queued["variant_index"] = 0
				automatic_queue[queue_index] = queued
	automatic_running = true
	_next_automatic()

## Explicitly rebuild a profile batch through the experimental ForceOrg source-pose path.
## Default match preparation never enables this opt-in workflow.
func prepare_source_pose_pilot(definitions: Array[String]) -> bool:
	if definitions.is_empty(): return false
	return prepare_armies(definitions, true, true)

## Recheck only visuals that failed when the showcase tried to read them.
## Existing links remain in place unless a valid replacement is found.
func repair_unavailable_visuals(definitions: Array[String]) -> bool:
	if definitions.is_empty(): return false
	return prepare_armies(definitions, true)

func _report_automatic() -> void:
	var message := "\n".join(automatic_messages)
	download_status.text = message
	automatic_status.emit(message)

func _finish_automatic_batch() -> void:
	automatic_running = false
	if automatic_started_usec > 0:
		Assets.record_profile_duration("automatic_preparation", float(Time.get_ticks_usec() - automatic_started_usec) / 1000.0)
		automatic_started_usec = 0
	if not automatic_variants_changed.is_empty():
		automatic_variants_changed.clear()
		variants_changed.emit("")
	_report_automatic()
	automatic_finished.emit(automatic_ready, automatic_total, download_status.text)
	automatic_source_pose_pilot = false

func _mapping_files_available(mapping: Dictionary) -> bool:
	if _mapping_has_unresolved_bundle_dependencies(mapping): return false
	var required_paths: Array[String] = []
	var optional_paths: Array[String] = []
	var parts: Variant = mapping.get("parts", [])
	if parts is Array and not parts.is_empty():
		for part: Variant in parts:
			if not part is Dictionary: return false
			var mesh_path := str(part.get("path", "")).strip_edges()
			if mesh_path.is_empty(): return false
			required_paths.append(mesh_path)
			for key: String in ["texture", "normal"]:
				var path := str(part.get(key, "")).strip_edges()
				if not path.is_empty(): optional_paths.append(path)
	else:
		var mesh_path := str(mapping.get("path", "")).strip_edges()
		if mesh_path.is_empty(): return false
		required_paths.append(mesh_path)
		var texture_path := str(mapping.get("texture", "")).strip_edges()
		if not texture_path.is_empty(): optional_paths.append(texture_path)
	for path: String in required_paths + optional_paths:
		if not FileAccess.file_exists(path) or FileAccess.get_size(path) <= 0: return false
	return true

func clear_cached_visuals() -> void:
	cache.clear()
	prepared_cache.clear()

func cancel_automatic() -> void:
	automatic_generation += 1
	if catalog_downloader != null: catalog_downloader.cancel()
	variant_catalog_pending = false
	variant_download_active = false
	variant_queue.clear()
	variant_current = {}
	catalog_definitions.clear()
	automatic_variant_requests.clear()
	automatic_variants_changed.clear()
	var was_running := automatic_running
	automatic_running = false
	automatic_queue.clear()
	automatic_current = {}
	automatic_repair_definitions.clear()
	if downloader != null and downloader.busy: downloader.cancel()
	if was_running:
		automatic_messages.append("Automatic models cancelled. Existing links and the match are preserved.")
		_report_automatic()
		automatic_cancelled.emit()
	automatic_source_pose_pilot = false

func _next_automatic(ticket: int = -1) -> void:
	if not automatic_running or (ticket != -1 and ticket != automatic_generation): return
	if automatic_queue.is_empty():
		automatic_running = false
		automatic_current = {}
		if automatic_total > 0:
			automatic_messages.append("Unit defaults ready: %d/%d." % [automatic_ready, automatic_total])
		if automatic_appearance_total > 0:
			automatic_messages.append("Miniature appearances ready: %d/%d." % [automatic_appearance_ready, automatic_appearance_total])
		_finish_automatic_batch()
		return
	automatic_current = automatic_queue.pop_front()
	var entry: Dictionary = automatic_current.entry
	for index: Dictionary in [automatic_index, automatic_index.get("external", {})]:
		if index.is_empty() or not index.get("error", "").is_empty(): continue
		var resolved := Assets.resolve_cache(entry, index)
		if resolved.get("error", "").is_empty():
			var cached_parts := _cached_component_files(resolved)
			if cached_parts.error.is_empty():
				_finish_automatic_item({"error": "", "parts": cached_parts.parts, "mesh": cached_parts.parts[0].path, "texture": cached_parts.parts[0].texture})
				return
	download_status.text = "Downloading and linking: " + str(entry.name)
	automatic_status.emit(download_status.text)
	var error: String = downloader.start(entry, download_path.text.strip_edges())
	if not error.is_empty(): _finish_automatic_item({"error": error})

func _finish_automatic_item(result: Dictionary) -> void:
	if not automatic_running or automatic_current.is_empty(): return
	var definition: String = automatic_current.definition
	var issue: String = result.error
	var asset: Dictionary = {}
	if issue.is_empty():
		var ticket := automatic_generation
		var current := func() -> bool: return is_inside_tree() and automatic_running and ticket == automatic_generation and definition == str(automatic_current.get("definition", ""))
		asset = await _downloaded_asset_async(result, current)
		if asset.is_empty() or not current.call(): return
		issue = asset.error
		if issue.is_empty() and _mapping_has_unresolved_bundle_dependencies({"parts": result.get("parts", [])}):
			issue = "The Unity bundle is missing a required material dependency."
		if issue.is_empty():
			var fit_settings := _visual_settings({}, definition, _base_radius_for_definition(definition))
			issue = Assets.visual_error_for_base(asset, fit_settings)
	if automatic_current.get("appearance_variant", false):
		if issue.is_empty(): issue = _store_variant(definition, automatic_current.entry, result, asset)
		if issue.is_empty():
			automatic_appearance_ready += 1
			automatic_variants_changed[definition] = true
		else:
			_remember_unavailable_automatic_variant(definition, automatic_current.entry, issue)
			automatic_messages.append("Appearance unavailable: %s — %s" % [automatic_current.entry.name, issue])
		_report_automatic()
		call_deferred("_next_automatic", automatic_generation)
		return
	if not issue.is_empty() and _try_next_automatic_variant(issue): return
	if issue.is_empty() and (not mappings.has(definition) or definition in automatic_repair_definitions):
		var entry: Dictionary = automatic_current.entry.duplicate(true)
		var tts := float(entry.get("tts_scale", 1.0))
		if not is_finite(tts) or tts < 0.01 or tts > 20.0: tts = 1.0
		var mapping := {"scale": 1.0, "rotation": 180.0 if automatic_source_pose_pilot else 0.0, "offset": 0.0, "tts_scale": tts, "path": result.mesh, "texture": result.texture,
			"fingerprint": asset.fingerprint, "texture_fingerprint": str(asset.get("texture_fingerprint", "")),
			"source": catalog.source, "source_fingerprint": catalog.fingerprint, "entry": entry}
		mapping.source_group_hint = str(entry.get("source_group_hint", ""))
		if automatic_source_pose_pilot: mapping["import_mode"] = "forceorg-source-pose-pilot"
		if result.get("parts") is Array: mapping.parts = result.parts.duplicate(true)
		var next := mappings.duplicate(true)
		next[definition] = mapping
		if _save(next):
			mappings = next
			automatic_repair_definitions.erase(definition)
			cache[definition] = asset
			mappings_changed.emit()
		else: issue = "Could not save model settings."
	if issue.is_empty(): automatic_ready += 1
	var visual_warnings: Array[String] = []
	if issue.is_empty(): visual_warnings = _visual_warnings(result)
	var visual_note := " — Visual note: " + "; ".join(visual_warnings) if not visual_warnings.is_empty() else ""
	automatic_messages.append(("Linked: " if issue.is_empty() else "Unavailable: ") + definition + (" — " + issue if not issue.is_empty() else "") + visual_note)
	# Reindex after a successful download so identical mesh/texture URLs are reused.
	var external: Dictionary = automatic_index.get("external", {})
	automatic_index = Assets.index_cache(download_path.text.strip_edges())
	if not external.is_empty(): automatic_index["external"] = external
	_report_automatic()
	call_deferred("_next_automatic", automatic_generation)

func _try_next_automatic_variant(reason: String) -> bool:
	var options: Array = automatic_current.get("options", [])
	var next_index := int(automatic_current.get("variant_index", 0)) + 1
	if next_index >= options.size(): return false
	var retry: Dictionary = automatic_current.duplicate(true)
	var previous_entry: Dictionary = retry.get("entry", {})
	var next_entry: Dictionary = options[next_index]
	retry.entry = next_entry.duplicate(true)
	retry.variant_index = next_index
	automatic_messages.append("Visual variant %s failed (%s); trying %s (%d/%d)." % [str(previous_entry.get("name", "Current entry")), reason, str(next_entry.get("name", "Alternate entry")), next_index + 1, options.size()])
	automatic_queue.push_front(retry)
	automatic_current.clear()
	_report_automatic()
	call_deferred("_next_automatic", automatic_generation)
	return true
