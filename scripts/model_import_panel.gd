extends VBoxContainer
## Local import settings and preview. Paths and mappings never enter match snapshots.
signal mappings_changed
signal automatic_status(message: String)
signal variants_changed(definition: String)
const CatalogDownload = preload("res://scripts/forceorg_catalog_download.gd")
var catalog_downloader: Node
var catalog_definitions: Array[String] = []
const Matcher = preload("res://scripts/forceorg_matcher.gd")
var automatic_queue: Array[Dictionary] = []
var automatic_current: Dictionary = {}
var automatic_messages: Array[String] = []
var automatic_ready := 0
var automatic_total := 0
var automatic_generation := 0
var automatic_running := false
var automatic_index: Dictionary = {}
const Assets = preload("res://scripts/local_models.gd")
const Download = preload("res://scripts/model_download.gd")
var downloader: Node
var download_path: LineEdit
var download_button: Button
var download_cancel: Button
var download_status: Label
var download_selection := ""
var settings_path := "user://local-models.cfg"
var selected_definition: Callable
var selected_radius: Callable
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
var catalog: Dictionary = {}
var cache: Dictionary = {}
var source_path: LineEdit
var cache_path: LineEdit
var cache_index: Dictionary = {}
var lookup_status: Label
var mesh_path: LineEdit
var texture_path: LineEdit
var inventory: OptionButton
var inventory_filter: LineEdit
var selected_description: Label
var notice: Label
var target: Label
var scale_input: SpinBox
var rotation_input: SpinBox
var offset_input: SpinBox
var preview_root: Node3D
var preview_asset: Dictionary = {}
var apply_button: Button

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
	_label("FORCEORG / TTS MODELS\nConfigure your ForceOrg JSON once for automatic models in local matches. You can also search, preview and link a specific visual manually. TTS is not required.")
	source_path = _path("TTS / ForceOrg JSON", PackedStringArray(["*.json ; TTS saves"]))
	_button("Scan local save", scan_source)
	inventory_filter = LineEdit.new()
	inventory_filter.placeholder_text = "Search miniatures: Intercessor, Necron, Ripper…"
	add_child(inventory_filter)
	inventory = OptionButton.new()
	inventory.fit_to_longest_item = false
	inventory.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	inventory.item_selected.connect(func(_index: int): _describe_entry())
	add_child(inventory)
	selected_description = _label("Search by miniature name. CustomMesh describes a 3D model; it is not the unit name.")
	inventory_filter.text_changed.connect(func(_text: String):
		if not catalog.is_empty(): lookup_status.text = _populate_inventory()
	)
	download_path = _path("Model download folder", PackedStringArray(), true)
	download_path.text = ProjectSettings.globalize_path("user://downloaded-models")
	download_button = _button("Download this model's files", start_download)
	_button("Save download folder", func():
		if _save(mappings): download_status.text = "Download folder saved."
	)
	download_cancel = _button("Cancel download", cancel_automatic)
	download_cancel.visible = false
	download_status = _label("Only the selected mesh and texture are downloaded, up to 64 MiB per file. Unity bundles are not supported.")
	downloader = Download.new()
	add_child(downloader)
	downloader.progress.connect(func(received: int, total: int, label: String):
		download_status.text = "%s: %.1f KiB%s" % [label, received / 1024.0, " / %.1f KiB" % (total / 1024.0) if total > 0 else " • total size unknown"]
		if automatic_running: automatic_status.emit(download_status.text)
	)
	downloader.finished.connect(_download_finished)
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
			_start_variant_downloads(variant_catalog_definition)
			return
		if not automatic_running: return
		var definitions: Array[String] = catalog_definitions.duplicate()
		catalog_definitions.clear()
		automatic_running = false
		if not result.error.is_empty():
			automatic_messages.append(result.error)
			_report_automatic()
			return
		source_path.text = result.path
		prepare_armies(definitions)
	)
	cache_path = _path("Optional: local files / cache folder", PackedStringArray(), true)
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
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	container.add_child(viewport)
	preview_root = Node3D.new()
	viewport.add_child(preview_root)
	var camera := Camera3D.new()
	viewport.add_child(camera)
	camera.position = Vector3(1.6, 1.3, 2)
	camera.look_at(Vector3(0, 0.65, 0))
	var light := DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-45, -30, 0)
	viewport.add_child(light)
	scale_input = _number("Extra visual scale (1.0 = official base diameter / TTS table scale)", 0.01, 20, 0.01, 1)
	rotation_input = _number("Rotation (degrees)", -360, 360, 1, 0)
	offset_input = _number("Height offset (inches)", -10, 10, 0.01, 0)
	target = _label("Select a battlefield model to choose a unit type.")
	apply_button = _button("Save visual for selected unit type", apply_mapping)
	_button("Remove visual for selected unit type", remove_mapping)
	notice = _label("No model loaded. Source scripts are ignored. Missing models use placeholders. OBJ materials use the selected diffuse image; MTL, normal maps and AssetBundles are not supported yet.")
	load_settings()

func _process(_delta: float) -> void:
	var definition := _definition()
	inventory.disabled = downloader.busy or automatic_running or variant_download_active
	inventory_filter.editable = not downloader.busy and not automatic_running and not variant_download_active
	download_path.editable = not downloader.busy and not automatic_running and not variant_download_active
	download_cancel.visible = downloader.busy or automatic_running or variant_download_active
	var entry := _selected_entry()
	download_button.disabled = downloader.busy or automatic_running or variant_download_active or entry.get("kind", "") != "CustomMesh" or str(entry.get("references", {}).get("MeshURL", "")).is_empty()
	target.text = "Target unit type: " + definition if not definition.is_empty() else "Select a battlefield model in Play, then return here."
	apply_button.disabled = downloader.busy or automatic_running or variant_download_active or definition.is_empty() or preview_asset.is_empty() or preview_asset.get("path", "") != mesh_path.text.strip_edges() or preview_asset.get("texture", "") != texture_path.text.strip_edges()

func start_download() -> void:
	if downloader.busy or automatic_running: return
	var entry := _selected_entry()
	if entry.is_empty():
		download_status.text = "Open a JSON file and select a miniature first."
		return
	download_selection = JSON.stringify(entry)
	_clear_candidate_files()
	download_status.text = "Iniciando download: " + _entry_title(entry)
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
	mesh_path.text = result.mesh
	texture_path.text = result.texture
	load_preview()
	download_status.text = "Download complete. " + ("Preview loaded; adjust the model and save it for the selected unit." if not preview_asset.is_empty() else notice.text)
	lookup_status.text = "Files retrieved with the download button. Using the TTS cache is optional."

func _definition() -> String:
	return str(selected_definition.call()) if selected_definition.is_valid() else ""

func scan_source() -> void:
	if downloader.busy or automatic_running: return
	var result := Assets.scan(source_path.text.strip_edges())
	if not result.error.is_empty():
		notice.text = result.error
		return
	catalog = result
	_save(mappings)
	var matches := _populate_inventory()
	variants_changed.emit(_definition())
	lookup_status.text = "%d entries • %d embedded static objects • %d skipped-table warnings\n%s" % [catalog.entries.size(), catalog.get("embedded_objects", 0), catalog.get("warnings", []).size(), matches]
	if not catalog.get("warnings", []).is_empty(): notice.text += "\n" + "\n".join(catalog.warnings.slice(0, 10))

func _populate_inventory() -> String:
	inventory.clear()
	var matching := 0
	var visible_indices: Array[int] = []
	var totals: Dictionary = {}
	var occurrences: Dictionary = {}
	var query := inventory_filter.text.strip_edges().to_lower()
	for index in range(catalog.entries.size()):
		var entry: Dictionary = catalog.entries[index]
		if not query.is_empty() and query not in str(entry.name).to_lower(): continue
		matching += 1
		var name: String = entry.name
		totals[name] = int(totals.get(name, 0)) + 1
		if visible_indices.size() < 200: visible_indices.append(index)
	for index: int in visible_indices:
		var entry: Dictionary = catalog.entries[index]
		var name: String = entry.name
		occurrences[name] = int(occurrences.get(name, 0)) + 1
		var title := _entry_title(entry)
		if totals[name] > 1: title += " • Option %d/%d" % [occurrences[name], totals[name]]
		inventory.add_item(title)
		inventory.set_item_metadata(inventory.item_count - 1, index)
	_clear_candidate_files()
	if inventory.item_count > 0: _describe_entry()
	else:
		notice.text = "No miniature found with this name. Try another search term."
		selected_description.text = notice.text
	return "%d results • showing %d. Use search to refine the list." % [matching, inventory.item_count]

func _entry_title(entry: Dictionary) -> String:
	var name := str(entry.get("name", "Unnamed object"))
	var title := name.replace(" / component ", " • Part ")
	var base_name := RegEx.new()
	base_name.compile("(?i)^\\d+(?:[x×]\\d+)?\\s*mm(?:\\s[^/]*|$)$")
	if base_name.search(name) != null: title = "Base: " + title
	if name in ["Custom_Model", "Custom_Assetbundle", "Custom_Model_Infinite_Bag"]: title = "Unnamed object"
	if entry.get("kind", "") == "CustomAssetbundle": title += " • Unity bundle (unsupported)"
	elif int(entry.get("child_components", 0)) > 0: title += " • has separate parts"
	return title

func _selected_entry() -> Dictionary:
	if catalog.is_empty() or inventory.selected < 0: return {}
	var index: int = inventory.selected
	var metadata: Variant = inventory.get_item_metadata(index)
	if metadata is int: index = metadata
	return catalog.entries[index] if index >= 0 and index < catalog.entries.size() else {}

func _describe_entry() -> void:
	if inventory.selected < 0 or catalog.is_empty(): return
	_clear_candidate_files()
	lookup_status.text = "Object changed. Find its files in the cache or choose them manually."
	var entry := _selected_entry()
	selected_description.text = "Selecionado: " + inventory.get_item_text(inventory.selected)
	if "component" in str(entry.get("path", "")).to_lower() or "/ChildObjects/" in str(entry.get("path", "")):
		selected_description.text += "\nThis is one part of a set; the preview shows this part only."
	elif int(entry.get("child_components", 0)) > 0:
		selected_description.text += "\nThis object has separate parts. If only the base appears, search for parts with the same name."
	selected_description.text += "\nConfirm the preview before linking it to a unit."
	notice.text = "%s\n%s\n%s" % [entry.name, entry.path, JSON.stringify(entry.references, "  ")]
	if not str(entry.get("credit", "")).is_empty(): notice.text += "\nSource description/credits: " + str(entry.credit)
	if entry.kind == "CustomAssetbundle": notice.text += "\nAssetBundle unsupported: choose an independently compatible local OBJ."
	else: notice.text += "\nChoose this object's downloaded/cached OBJ and optional diffuse image below."

func _clear_candidate_files() -> void:
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
	if entry.kind != "CustomMesh":
		notice.text = "AssetBundle unsupported: select a compatible local OBJ manually."
		lookup_status.text = notice.text
		return
	# Re-index on an explicit request, so newly cached files and duplicates are seen.
	cache_index = Assets.index_cache(cache_path.text.strip_edges())
	if not cache_index.error.is_empty():
		notice.text = cache_index.error
		lookup_status.text = notice.text
		return
	var resolved := Assets.resolve_cache(entry, cache_index)
	# Never retain an earlier object's files or preview after an incomplete match.
	mesh_path.text = resolved.mesh.path
	texture_path.text = resolved.diffuse.path
	preview_asset = {}
	_update_preview()
	var message := "Inspected %d local files.\nMesh: %s\nDiffuse: %s" % [cache_index.files, resolved.mesh.status, resolved.diffuse.status if resolved.diffuse_required else "not required"]
	for kind: String in ["mesh", "diffuse"]:
		if resolved[kind].status == "ambiguous": message += "\n%s: %d candidates (choose manually), first ten:\n%s" % [kind.capitalize(), resolved[kind].candidates.size(), "\n".join(resolved[kind].candidates.slice(0, 10))]
	if resolved.mesh.status == "found" and (not resolved.diffuse_required or resolved.diffuse.status == "found"):
		load_preview()
		notice.text = message + "\n" + notice.text
	else:
		notice.text = message + "\nNo complete match. Choose missing/ambiguous files manually; nothing was downloaded or mapped."
		if resolved.mesh.status == "missing" or (resolved.diffuse_required and resolved.diffuse.status == "missing"):
			notice.text = "Local files not found for: %s.\nThe JSON contains references, not the miniatures. Choose the folder where the mesh and texture were downloaded or cached.\nThe JSON or project folder may not contain these files. Nothing was downloaded or linked.\n\n%s" % [_entry_title(entry), message]
	lookup_status.text = notice.text

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
	_update_preview()
	notice.text = "Preview loaded. Adjust its appearance, select a battlefield model, then save for that unit type. Gameplay bases and rules stay authoritative."

func _settings() -> Dictionary:
	var settings := {"scale": scale_input.value, "rotation": rotation_input.value, "offset": offset_input.value, "tts_scale": 1.0}
	var entry := _selected_entry()
	if not entry.is_empty() and (entry.get("tts_scale") is float or entry.get("tts_scale") is int):
		settings.tts_scale = float(entry.tts_scale)
	var radius := float(selected_radius.call()) if selected_radius.is_valid() else 0.0
	if radius > 0.01: settings.base_radius_inches = radius
	return settings

func _update_preview() -> void:
	if preview_root == null or offset_input == null: return
	for child in preview_root.get_children():
		preview_root.remove_child(child)
		child.queue_free()
	if not preview_asset.is_empty(): preview_root.add_child(Assets.visual(preview_asset, _settings()))

func apply_mapping() -> void:
	if automatic_running: return
	var definition := _definition()
	if definition.is_empty() or preview_asset.is_empty():
		notice.text = "Load a model preview and select a battlefield model first."
		return
	if preview_asset.path != mesh_path.text.strip_edges() or preview_asset.texture != texture_path.text.strip_edges():
		notice.text = "Reload the preview after changing its files."
		return
	var mapping := _settings()
	mapping.erase("base_radius_inches")
	mapping.path = preview_asset.path
	mapping.texture = preview_asset.texture
	mapping.fingerprint = preview_asset.fingerprint
	mapping.texture_fingerprint = preview_asset.texture_fingerprint
	mapping.source = catalog.get("source", "")
	mapping.source_fingerprint = catalog.get("fingerprint", "")
	if not _selected_entry().is_empty():
		mapping.entry = _selected_entry().duplicate(true)
		if mapping.entry.get("tts_scale") is float or mapping.entry.get("tts_scale") is int:
			mapping.tts_scale = float(mapping.entry.tts_scale)
	var next := mappings.duplicate(true)
	next[definition] = mapping
	if not _save(next): return
	mappings = next
	cache[definition] = preview_asset
	mappings_changed.emit()
	notice.text = "Saved local visual for " + definition + ". Other players keep their own visuals."

func remove_mapping() -> void:
	if automatic_running: return
	var definition := _definition()
	if definition.is_empty():
		notice.text = "Select a battlefield model first."
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
	var saved_source: Variant = cfg.get_value("paths", "source", "")
	if saved_source is String: source_path.text = saved_source
	var saved_cache: Variant = cfg.get_value("paths", "cache", "")
	if saved_cache is String: cache_path.text = saved_cache
	var saved_downloads: Variant = cfg.get_value("paths", "downloads", "")
	if saved_downloads is String and not saved_downloads.is_empty(): download_path.text = saved_downloads

func visual_for(definition: String, base_radius_inches: float = 0.0) -> Node3D:
	if not mappings.has(definition): return null
	if not cache.has(definition):
		var mapping: Dictionary = mappings[definition]
		var result := Assets.obj_mesh(mapping.path, mapping.get("texture", ""))
		if not result.error.is_empty():
			notice.text = "Placeholder for %s: %s" % [definition, result.error]
			cache[definition] = result
			return null
		if result.fingerprint != mapping.get("fingerprint", "") or result.texture_fingerprint != mapping.get("texture_fingerprint", ""):
			notice.text = "Placeholder: model file changed for %s. Preview and save it again." % definition
			cache[definition] = {"error": "Model changed"}
			return null
		cache[definition] = result
	if not cache[definition].get("error", "").is_empty(): return null
	var settings: Dictionary = mappings[definition].duplicate()
	if base_radius_inches > 0.01: settings.base_radius_inches = base_radius_inches
	return Assets.visual(cache[definition], settings)

func variants_for(definition: String) -> Array[Dictionary]:
	var options: Array[Dictionary] = Matcher.variants(definition, catalog.get("entries", [])) if not catalog.is_empty() else []
	for identity: String in variant_mappings:
		var mapping: Dictionary = variant_mappings[identity]
		if str(mapping.get("definition", "")) != definition: continue
		var known := false
		for option: Dictionary in options:
			if str(option.get("variant_id", "")) == identity: known = true
		if not known:
			var entry: Dictionary = mapping.get("entry", {}).duplicate(true)
			entry.variant_id = identity
			options.append(entry)
	for option: Dictionary in options:
		option.ready = variant_mappings.has(str(option.get("variant_id", "")))
	return options

func download_variants_for(definition: String) -> void:
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
			variant_catalog_pending = true
			download_status.text = "Downloading the model catalog…"
			automatic_status.emit(download_status.text)
			var issue: String = catalog_downloader.start()
			if not issue.is_empty():
				variant_catalog_pending = false
				download_status.text = issue
				automatic_status.emit(download_status.text)
			return
	_start_variant_downloads(definition)

func _start_variant_downloads(definition: String) -> void:
	variant_download_definition = definition
	variant_queue.clear()
	variant_failures.clear()
	var options := Matcher.variants(definition, catalog.get("entries", []))
	if options.is_empty():
		download_status.text = "No compatible complete OBJ variants were found for this unit."
		automatic_status.emit(download_status.text)
		return
	for entry: Dictionary in options:
		if not variant_mappings.has(str(entry.get("variant_id", ""))): variant_queue.append(entry)
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
	var cache_index := Assets.index_cache(download_path.text.strip_edges())
	var resolved := Assets.resolve_cache(variant_current, cache_index) if not cache_index.is_empty() and cache_index.get("error", "").is_empty() else {}
	if not resolved.is_empty() and resolved.mesh.status == "found" and (not resolved.diffuse_required or resolved.diffuse.status == "found"):
		_finish_variant_download({"error": "", "mesh": resolved.mesh.path, "texture": resolved.diffuse.path})
		return
	download_status.text = "Downloading %s…" % str(variant_current.get("name", "visual variant"))
	automatic_status.emit(download_status.text)
	var issue: String = downloader.start(variant_current, download_path.text.strip_edges())
	if not issue.is_empty(): _finish_variant_download({"error": issue})

func _finish_variant_download(result: Dictionary) -> void:
	var issue := str(result.get("error", ""))
	if issue.is_empty():
		var asset := Assets.obj_mesh(str(result.get("mesh", "")), str(result.get("texture", "")))
		issue = str(asset.get("error", ""))
		if issue.is_empty():
			var entry: Dictionary = variant_current.duplicate(true)
			var tts := float(entry.get("tts_scale", 1.0))
			if not is_finite(tts) or tts < 0.01 or tts > 20.0: tts = 1.0
			var identity := str(entry.get("variant_id", ""))
			var mapping := {"definition": variant_download_definition, "path": str(result.mesh), "texture": str(result.texture), "fingerprint": asset.fingerprint,
				"texture_fingerprint": asset.texture_fingerprint, "scale": 1.0, "rotation": 0.0, "offset": 0.0, "tts_scale": tts, "entry": entry}
			variant_mappings[identity] = mapping
			variant_cache[identity] = asset
			if not _save(mappings):
				variant_mappings.erase(identity)
				variant_cache.erase(identity)
				issue = "Could not save local variant settings."
	if not issue.is_empty():
		variant_failures.append(str(variant_current.get("name", "variant")) + ": " + issue)
		download_status.text = "Variant unavailable: " + issue
	else: download_status.text = "Saved local visual variant: " + str(variant_current.get("name", "visual variant"))
	automatic_status.emit(download_status.text)
	if variant_download_active: call_deferred("_next_variant_download")

func visual_variant_for(identity: String, base_radius_inches: float = 0.0) -> Node3D:
	if identity.is_empty() or not variant_mappings.has(identity): return null
	if not variant_cache.has(identity):
		var mapping: Dictionary = variant_mappings[identity]
		var asset := Assets.obj_mesh(str(mapping.path), str(mapping.get("texture", "")))
		if not asset.error.is_empty() or asset.fingerprint != mapping.get("fingerprint", "") or asset.texture_fingerprint != mapping.get("texture_fingerprint", ""):
			download_status.text = "This local variant is unavailable; using the default miniature."
			variant_cache[identity] = {"error": "Variant unavailable"}
			return null
		variant_cache[identity] = asset
	if not variant_cache[identity].get("error", "").is_empty(): return null
	var settings: Dictionary = variant_mappings[identity].duplicate()
	if base_radius_inches > 0.01: settings.base_radius_inches = base_radius_inches
	return Assets.visual(variant_cache[identity], settings)

## Batch uses captured profile IDs, independent of the selected pawn or inventory row.
func prepare_armies(definitions: Array[String]) -> void:
	if downloader.busy and not automatic_running:
		automatic_status.emit("A manual model download is running. Retry automatic models when it finishes.")
		return
	cancel_automatic()
	automatic_messages.clear()
	automatic_ready = 0
	automatic_total = definitions.size()
	var missing: Array[String] = []
	for definition: String in definitions:
		var existing := visual_for(definition)
		if existing != null:
			existing.free()
			automatic_ready += 1
			automatic_messages.append("Reused saved model: " + definition)
		elif mappings.has(definition):
			automatic_messages.append("Saved model needs repair in Models: " + definition)
		else: missing.append(definition)
	if missing.is_empty():
		_report_automatic()
		return
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
			_report_automatic()
		return
	var scanned := Assets.scan(path)
	if not scanned.error.is_empty():
		automatic_messages.append(scanned.error + " — choose the ForceOrg JSON in Models and retry.")
		_report_automatic()
		return
	catalog = scanned
	_save(mappings)
	_populate_inventory()
	automatic_index = Assets.index_cache(download_path.text.strip_edges())
	if not cache_path.text.strip_edges().is_empty():
		var external := Assets.index_cache(cache_path.text.strip_edges())
		# Resolve separately to preserve duplicate/ambiguous-file checks.
		automatic_index["external"] = external
	for definition: String in missing:
		var chosen := Matcher.choose(definition, catalog.entries)
		if not chosen.error.is_empty(): automatic_messages.append(chosen.error)
		else:
			automatic_queue.append({"definition": definition, "entry": chosen.entry})
			automatic_messages.append("Selected %s (%d compatible visual variants; change in Models)." % [chosen.entry.name, chosen.variants])
	automatic_running = true
	_next_automatic()

func _report_automatic() -> void:
	var message := "\n".join(automatic_messages)
	download_status.text = message
	automatic_status.emit(message)

func cancel_automatic() -> void:
	automatic_generation += 1
	if catalog_downloader != null: catalog_downloader.cancel()
	variant_catalog_pending = false
	variant_download_active = false
	variant_queue.clear()
	variant_current = {}
	catalog_definitions.clear()
	var was_running := automatic_running
	automatic_running = false
	automatic_queue.clear()
	automatic_current = {}
	if downloader != null and downloader.busy: downloader.cancel()
	if was_running:
		automatic_messages.append("Automatic models cancelled. Existing links and the match are preserved.")
		_report_automatic()

func _next_automatic(ticket: int = -1) -> void:
	if not automatic_running or (ticket != -1 and ticket != automatic_generation): return
	if automatic_queue.is_empty():
		automatic_running = false
		automatic_current = {}
		automatic_messages.append("Models ready: %d/%d. %s" % [automatic_ready, automatic_total, "Play now; links are saved." if automatic_ready == automatic_total else "Missing visuals keep placeholders. Configure / retry in Models or Match setup."])
		_report_automatic()
		return
	automatic_current = automatic_queue.pop_front()
	var entry: Dictionary = automatic_current.entry
	for index: Dictionary in [automatic_index, automatic_index.get("external", {})]:
		if index.is_empty() or not index.get("error", "").is_empty(): continue
		var resolved := Assets.resolve_cache(entry, index)
		if resolved.mesh.status == "found" and (not resolved.diffuse_required or resolved.diffuse.status == "found"):
			_finish_automatic_item({"error": "", "mesh": resolved.mesh.path, "texture": resolved.diffuse.path})
			return
	download_status.text = "Downloading and linking: " + str(entry.name)
	automatic_status.emit(download_status.text)
	var error: String = downloader.start(entry, download_path.text.strip_edges())
	if not error.is_empty(): _finish_automatic_item({"error": error})

func _finish_automatic_item(result: Dictionary) -> void:
	if not automatic_running or automatic_current.is_empty(): return
	var definition: String = automatic_current.definition
	var issue: String = result.error
	if issue.is_empty():
		var asset := Assets.obj_mesh(result.mesh, result.texture)
		issue = asset.error
		if issue.is_empty() and not mappings.has(definition):
			var entry: Dictionary = automatic_current.entry.duplicate(true)
			var tts := float(entry.get("tts_scale", 1.0))
			if not is_finite(tts) or tts < 0.01 or tts > 20.0: tts = 1.0
			var mapping := {"scale": 1.0, "rotation": 0.0, "offset": 0.0, "tts_scale": tts, "path": result.mesh, "texture": result.texture,
				"fingerprint": asset.fingerprint, "texture_fingerprint": asset.texture_fingerprint,
				"source": catalog.source, "source_fingerprint": catalog.fingerprint, "entry": entry}
			var next := mappings.duplicate(true)
			next[definition] = mapping
			if _save(next):
				mappings = next
				cache[definition] = asset
				mappings_changed.emit()
			else: issue = "Could not save model settings."
	if issue.is_empty(): automatic_ready += 1
	automatic_messages.append(("Linked: " if issue.is_empty() else "Unavailable: ") + definition + (" — " + issue if not issue.is_empty() else ""))
	# Reindex after a successful download so identical mesh/texture URLs are reused.
	var external: Dictionary = automatic_index.get("external", {})
	automatic_index = Assets.index_cache(download_path.text.strip_edges())
	if not external.is_empty(): automatic_index["external"] = external
	_report_automatic()
	call_deferred("_next_automatic", automatic_generation)
