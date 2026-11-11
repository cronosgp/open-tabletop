extends Node3D

const TableCameraMotion = preload("res://scripts/ui/table_camera_motion.gd")
const WorkspaceTheme = preload("res://scripts/ui/workspace_theme.gd")
## Read-only visual catalog table. This screen does not create a match or rules state.
signal close_requested

const MarineProfiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Assets = preload("res://scripts/local_models.gd")
const DEFINITION_PREFIX := "40kdc:11e:adeptus-astartes:"
const PAGE_SIZE := 24
const COLUMNS := 6
const CELL_SPACING := 5.3
const MODEL_LAYER := 2
const PROFILE_ARGUMENT := "--profile-training-tools"
const PROFILE_WINDOW_SECONDS := 10.0
const BASE_PROXY_HEIGHT := 0.05
const BASE_RIM_HEIGHT := 0.018
const BASE_RIM_WIDTH := 0.035
const OVAL_RIM_HEADING_OVERRIDES := {
	"land-speeder-vengeance": 90.0,
	"nephilim-jetfighter": 90.0,
	"outrider-squad": 90.0,
	"ravenwing-black-knights": 90.0,
	"ravenwing-command-squad": 90.0,
	"ravenwing-dark-talon": 90.0,
	"invader-atvs": 90.0,
	"captain-on-bike": 90.0,
	"corvus-blackstar": 90.0,
	"chaplain-on-bike": 90.0,
}

var model_imports: Node
var profiles: Array[Dictionary] = []
var page_index := 0
var side_mode := 0
var selected_slot := 0
var selected_side := 1
var angle := 0.0
var zoom := 51.0
var pitch := atan(0.82)
var motion_enabled := true
var zoom_goal := 51.0
var pivot_goal := Vector3.ZERO
var zoom_anchor: Variant = null
var camera_target := Vector3.ZERO
var orbiting := false
var camera: Camera3D
var model_root: Node3D
var ui_layer: CanvasLayer
var page_label: Label
var status_label: Label
var selected_label: Label
var profile_picker: OptionButton
var side_picker: OptionButton
var previous_button: Button
var next_button: Button
var page_progress: ProgressBar
var left_positions: Array[Vector3] = []
var right_positions: Array[Vector3] = []
var page_ready := 0
var page_total := 0
var page_visual_ready: Array[bool] = []
var page_base_status: Array[String] = []
var page_load_generation := 0
var page_open_ms := 0.0
var page_model_build_ms := 0.0
var profiling_enabled := false
var page_loading := false
var profile_collecting := false
var profile_elapsed := 0.0
var profile_samples: Array[Dictionary] = []
var page_load_samples: Array[Dictionary] = []
var page_load_started_usec := 0
var side_materials: Dictionary = {}
var proxy_materials: Dictionary = {}
var repair_attempted: Dictionary = {}
var repair_in_progress := false

static func standard_profiles() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var allowed_books := ["000000139", "000000021", "000000023", "000000035", "000000036", "000000162"]
	for identity: String in MarineProfiles.catalog():
		var profile: Dictionary = MarineProfiles.profile(identity)
		if str(profile.get("source_book_id", "")) not in allowed_books: continue
		result.append({
			"identity": identity,
			"datasheet_id": str(profile.get("source_datasheet_id", profile.get("datasheet_id", ""))),
			"definition": DEFINITION_PREFIX + identity,
			"name": str(profile.get("name", identity)),
			"base_summary": str(_base_spec(profile).summary),
			"base_radius_inches": float(profile.get("base_radius_inches", 0.0)),
			"base_size_source_mm": profile.get("base_size_source_mm", null),
			"base_geometry": str(profile.get("base_geometry", "")),
			"geometry_scope": str(profile.get("geometry_scope", "")),
		})
	result.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		var name_order := str(a.name).nocasecmp_to(str(b.name))
		return str(a.identity) < str(b.identity) if name_order == 0 else name_order < 0
	)
	var name_counts: Dictionary = {}
	for profile: Dictionary in result:
		name_counts[profile.name] = int(name_counts.get(profile.name, 0)) + 1
	for index in result.size():
		var profile: Dictionary = result[index]
		var display_name := str(profile.name)
		if int(name_counts.get(profile.name, 0)) > 1:
			var exact_id := str(profile.get("datasheet_id", ""))
			if exact_id.is_empty(): exact_id = str(profile.identity)
			display_name += " • DS " + exact_id
		profile.display_name = display_name
		result[index] = profile
	return result

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	profiling_enabled = PROFILE_ARGUMENT in OS.get_cmdline_user_args()
	Assets.set_profiling_enabled(profiling_enabled)
	side_materials = {
		1: _material(Color("57c6e0"), Color("57c6e0"), 0.05),
		2: _material(Color("e78a4f"), Color("e78a4f"), 0.05),
	}
	proxy_materials = {
		1: _material(Color("267384")),
		2: _material(Color("89502f")),
	}
	profiles = standard_profiles()
	if model_imports != null and model_imports.has_signal("automatic_finished"):
		model_imports.automatic_finished.connect(_on_model_repair_finished)
	_build_table()
	_build_ui()
	_show_page(0)
	_set_camera()

func _process(delta: float) -> void:
	_move_camera(delta)
	if not profiling_enabled: return
	var sample := {
		"frame_ms": delta * 1000.0,
		"fps": float(Performance.get_monitor(Performance.TIME_FPS)),
		"process_ms": float(Performance.get_monitor(Performance.TIME_PROCESS)) * 1000.0,
		"draw_calls": int(Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)),
		"render_objects": int(Performance.get_monitor(Performance.RENDER_TOTAL_OBJECTS_IN_FRAME)),
		"primitives": int(Performance.get_monitor(Performance.RENDER_TOTAL_PRIMITIVES_IN_FRAME)),
		"static_memory_bytes": int(Performance.get_monitor(Performance.MEMORY_STATIC)),
		"video_memory_bytes": int(Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED)),
	}
	if page_loading: page_load_samples.append(sample)
	if not profile_collecting: return
	profile_elapsed += delta
	profile_samples.append(sample)
	if profile_elapsed >= PROFILE_WINDOW_SECONDS:
		_finish_profile_window()

func _finish_profile_window() -> void:
	profile_collecting = false
	var viewport_size: Vector2 = get_viewport().get_visible_rect().size
	var display_size := DisplayServer.screen_get_size()
	var base_fit_counts := {"ring_within_tolerance": 0, "estimated_or_proxy": 0, "review": 0}
	for status: String in page_base_status:
		if "Review base fit" in status: base_fit_counts.review += 1
		elif "within 0.5 mm" in status: base_fit_counts.ring_within_tolerance += 1
		elif "contour and center are estimated" in status: base_fit_counts.estimated_or_proxy += 1
		else: base_fit_counts.estimated_or_proxy += 1
	var asset_stages := Assets.get_profile_metrics()
	if not asset_stages.has("network_download"):
		asset_stages["network_download"] = {"count": 0, "total_ms": 0.0, "bytes": 0, "note": "No model transfer occurred in this capture."}
	var report := {
		"capture": "Training Tools live Godot runtime",
		"viewport": {"width": int(viewport_size.x), "height": int(viewport_size.y)},
		"physical_display": {"width": display_size.x, "height": display_size.y},
		"page": page_index + 1,
		"datasheets": page_total,
		"miniature_positions": page_total * (2 if side_mode == 0 else 1),
		"base_fit_counts": base_fit_counts,
		"page_open_ms": page_open_ms,
		"page_model_build_ms": page_model_build_ms,
		"page_load_frames": {
			"count": page_load_samples.size(),
			"frame_time_ms": _sample_summary_from(page_load_samples, "frame_ms"),
			"fps": _sample_summary_from(page_load_samples, "fps"),
			"process_ms": _sample_summary_from(page_load_samples, "process_ms"),
			"draw_calls": _sample_summary_from(page_load_samples, "draw_calls"),
			"render_objects": _sample_summary_from(page_load_samples, "render_objects"),
			"primitives": _sample_summary_from(page_load_samples, "primitives"),
			"static_memory_bytes": _sample_summary_from(page_load_samples, "static_memory_bytes"),
			"video_memory_bytes": _sample_summary_from(page_load_samples, "video_memory_bytes"),
		},
		"sample_seconds": profile_elapsed,
		"frame_time_ms": _sample_summary("frame_ms"),
		"fps": _sample_summary("fps"),
		"process_ms": _sample_summary("process_ms"),
		"draw_calls": _sample_summary("draw_calls"),
		"render_objects": _sample_summary("render_objects"),
		"primitives": _sample_summary("primitives"),
		"static_memory_bytes": _sample_summary("static_memory_bytes"),
		"video_memory_bytes": _sample_summary("video_memory_bytes"),
		"asset_stages": asset_stages,
		"gpu_frame_time_ms": null,
		"gpu_timing_note": "Godot runtime Performance monitors do not expose GPU frame time; use the editor Profiler for a CPU/GPU split.",
		"build_note": "Runtime measurement; confirm final target with a release build.",
	}
	var directory := ProjectSettings.globalize_path("res://.tools/training-tools-profile")
	var directory_error := DirAccess.make_dir_recursive_absolute(directory)
	if directory_error != OK:
		push_warning("Training Tools profile could not create its local output folder: " + error_string(directory_error))
		return
	var timestamp := Time.get_datetime_string_from_system().replace(":", "-").replace(" ", "T")
	var path := directory.path_join("profile-%s-page-%02d.json" % [timestamp, page_index + 1])
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		push_warning("Training Tools profile could not be written: " + path)
		return
	file.store_string(JSON.stringify(report, "  "))
	file.close()
	print("[TRAINING_TOOLS_PROFILE] %s" % path)

func _sample_summary(key: String) -> Dictionary:
	return _sample_summary_from(profile_samples, key)

func _sample_summary_from(samples: Array[Dictionary], key: String) -> Dictionary:
	var values: Array[float] = []
	for sample: Dictionary in samples:
		values.append(float(sample.get(key, 0.0)))
	if values.is_empty(): return {"count": 0}
	values.sort()
	return {
		"count": values.size(),
		"min": values[0],
		"p50": _percentile_sample(values, 0.50),
		"p95": _percentile_sample(values, 0.95),
		"max": values[-1],
		"average": _mean_sample(values),
	}

func _percentile_sample(values: Array[float], fraction: float) -> float:
	var index := clampi(int(ceil(float(values.size()) * fraction)) - 1, 0, values.size() - 1)
	return values[index]

func _mean_sample(values: Array[float]) -> float:
	var total := 0.0
	for value: float in values: total += value
	return total / float(values.size())

func _add_grid_lines(major: bool) -> void:
	var mesh := ArrayMesh.new()
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_LINES)
	for x_index in range(-38, 39):
		if major != (x_index % 5 == 0): continue
		var x := float(x_index)
		surface.add_vertex(Vector3(x, -0.075, -23.0))
		surface.add_vertex(Vector3(x, -0.075, 23.0))
	for z_index in range(-23, 24):
		if major != (z_index % 5 == 0): continue
		var z := float(z_index)
		surface.add_vertex(Vector3(-38.0, -0.075, z))
		surface.add_vertex(Vector3(38.0, -0.075, z))
	surface.commit(mesh)
	var line := MeshInstance3D.new()
	line.mesh = mesh
	line.material_override = _material(Color("34424a") if major else Color("29353c"))
	line.layers = MODEL_LAYER
	add_child(line)

func _build_table() -> void:
	var floor := MeshInstance3D.new()
	var plane := PlaneMesh.new()
	plane.size = Vector2(76.0, 47.0)
	floor.mesh = plane
	floor.position.y = -0.1
	floor.material_override = _material(Color("202a31"))
	floor.layers = MODEL_LAYER
	add_child(floor)
	_add_grid_lines(false)
	_add_grid_lines(true)
	var lamp := DirectionalLight3D.new()
	lamp.rotation_degrees = Vector3(-52.0, -28.0, 0.0)
	lamp.light_energy = 1.4
	lamp.light_cull_mask = MODEL_LAYER
	add_child(lamp)
	camera = Camera3D.new()
	camera.fov = 60.0
	camera.cull_mask = MODEL_LAYER
	add_child(camera)
	camera.current = true
	model_root = Node3D.new()
	model_root.name = "ShowcaseMiniatures"
	add_child(model_root)
	var rows := ceili(float(PAGE_SIZE) / float(COLUMNS))
	var anchor := COLUMNS * CELL_SPACING * 0.5 + 4.0
	for slot in PAGE_SIZE:
		var row := slot / COLUMNS
		var col := slot % COLUMNS
		var x_offset := (float(col) - (COLUMNS - 1) * 0.5) * CELL_SPACING
		var z_offset := (float(row) - (rows - 1) * 0.5) * CELL_SPACING
		left_positions.append(Vector3(-anchor + x_offset, 0.0, z_offset))
		right_positions.append(Vector3(anchor + x_offset, 0.0, z_offset))
	_add_side_heading("PLAYER 1", Vector3(-anchor, 0.06, -21.8), Color("6cd6ed"))
	_add_side_heading("PLAYER 2", Vector3(anchor, 0.06, -21.8), Color("f2a76c"))

func _build_ui() -> void:
	ui_layer = CanvasLayer.new()
	ui_layer.layer = 30
	add_child(ui_layer)
	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_PASS
	root.theme = WorkspaceTheme.create()
	ui_layer.add_child(root)
	var top := PanelContainer.new()
	top.anchor_left = 0.0
	top.anchor_top = 0.0
	top.anchor_right = 1.0
	top.anchor_bottom = 0.0
	top.offset_left = 12.0
	top.offset_top = 12.0
	top.offset_right = -12.0
	top.offset_bottom = 122.0
	top.add_theme_stylebox_override("panel", WorkspaceTheme.box(WorkspaceTheme.SURFACE, WorkspaceTheme.GOLD, 12, 2, 2))
	root.add_child(top)
	var controls := VBoxContainer.new()
	controls.add_theme_constant_override("separation", 5)
	top.add_child(controls)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	controls.add_child(row)
	var title := Label.new()
	title.text = "TRAINING TOOLS  /  MODEL TABLE"
	title.add_theme_color_override("font_color", WorkspaceTheme.GOLD_HIGHLIGHT)
	title.add_theme_font_size_override("font_size", 19)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(title)
	page_label = Label.new()
	page_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	row.add_child(page_label)
	previous_button = _button(row, "Previous", func(): _show_page(page_index - 1), "previous")
	next_button = _button(row, "Next", func(): _show_page(page_index + 1), "next")
	side_picker = OptionButton.new()
	side_picker.add_item("Both sides", 0)
	side_picker.add_item("Player 1", 1)
	side_picker.add_item("Player 2", 2)
	side_picker.item_selected.connect(_side_selected)
	row.add_child(side_picker)
	var close := _button(row, "Back", func(): close_requested.emit(), "close")
	close.tooltip_text = "Close the model table and return to Training Tools. Escape also returns."
	var profile_row := HBoxContainer.new()
	profile_row.add_theme_constant_override("separation", 8)
	controls.add_child(profile_row)
	var profile_heading := Label.new()
	profile_heading.text = "DATASHEET"
	profile_heading.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	profile_heading.add_theme_color_override("font_color", WorkspaceTheme.GOLD)
	profile_row.add_child(profile_heading)
	profile_picker = OptionButton.new()
	profile_picker.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	profile_picker.item_selected.connect(_profile_selected)
	profile_row.add_child(profile_picker)
	var focus_button := _button(profile_row, "Focus", _focus_selected, "focus")
	focus_button.tooltip_text = "Zoom in on the selected miniature."
	var bottom := PanelContainer.new()
	bottom.anchor_left = 0.0
	bottom.anchor_top = 1.0
	bottom.anchor_right = 1.0
	bottom.anchor_bottom = 1.0
	bottom.offset_left = 12.0
	bottom.offset_top = -108.0
	bottom.offset_right = -12.0
	bottom.offset_bottom = -12.0
	bottom.add_theme_stylebox_override("panel", WorkspaceTheme.box(WorkspaceTheme.SURFACE, WorkspaceTheme.GOLD, 12, 2, 2))
	root.add_child(bottom)
	var info := VBoxContainer.new()
	info.add_theme_constant_override("separation", 2)
	bottom.add_child(info)
	selected_label = Label.new()
	selected_label.add_theme_color_override("font_color", Color("f2df83"))
	selected_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	info.add_child(selected_label)
	status_label = Label.new()
	status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	status_label.text = "One representative per datasheet on each side. Visual inspection only; no match state or army legality. Click a base to focus it. Wheel zooms; middle-drag orbits; Page Up/Down changes pages; Escape returns."
	info.add_child(status_label)
	page_progress = ProgressBar.new()
	page_progress.min_value = 0.0
	page_progress.max_value = PAGE_SIZE
	page_progress.value = 0.0
	page_progress.show_percentage = false
	page_progress.custom_minimum_size.y = 7.0
	info.add_child(page_progress)

func _show_page(wanted: int, preserve_cache: bool = false, preserve_selection: bool = false) -> void:
	var page_count := maxi(1, ceili(float(profiles.size()) / float(PAGE_SIZE)))
	var previous_page := page_index
	page_index = clampi(wanted, 0, page_count - 1)
	if previous_page != page_index:
		camera_target = Vector3.ZERO
		zoom = 51.0
		zoom_goal = zoom
		pivot_goal = camera_target
		zoom_anchor = null
		angle = 0.0
		pitch = atan(0.82)
	if not preserve_selection: selected_slot = 0
	selected_slot = clampi(selected_slot, 0, maxi(0, mini(PAGE_SIZE, profiles.size() - page_index * PAGE_SIZE) - 1))
	page_load_generation += 1
	var generation := page_load_generation
	page_ready = 0
	page_total = mini(PAGE_SIZE, maxi(0, profiles.size() - page_index * PAGE_SIZE))
	page_visual_ready.clear()
	page_base_status.clear()
	if model_root != null:
		for child: Node in model_root.get_children():
			child.queue_free()
	if not preserve_cache and previous_page != page_index and model_imports != null and model_imports.has_method("clear_cached_visuals"):
		model_imports.clear_cached_visuals()
	profile_picker.clear()
	for local_index in page_total:
		var profile: Dictionary = profiles[page_index * PAGE_SIZE + local_index]
		profile_picker.add_item("%03d  %s" % [page_index * PAGE_SIZE + local_index + 1, profile.get("display_name", profile.name)])
		var tooltip := "Identity: %s" % str(profile.identity)
		if not str(profile.get("datasheet_id", "")).is_empty(): tooltip += "\nDatasheet ID: " + str(profile.datasheet_id)
		tooltip += "\nRequired base sizes: " + str(profile.get("base_summary", "unknown"))
		if not str(profile.get("geometry_scope", "")).is_empty(): tooltip += "\n" + str(profile.geometry_scope)
		profile_picker.set_item_tooltip(profile_picker.item_count - 1, tooltip)
	var side_label: String = ["both sides", "P1 only", "P2 only"][side_mode]
	page_label.text = "Profiles %d–%d of %d  •  %s" % [page_index * PAGE_SIZE + 1, page_index * PAGE_SIZE + page_total, profiles.size(), side_label]
	previous_button.disabled = page_index <= 0
	next_button.disabled = page_index >= page_count - 1
	profile_picker.disabled = page_total == 0
	if page_total > 0: profile_picker.select(selected_slot)
	page_progress.max_value = maxf(1.0, float(page_total))
	page_progress.value = 0.0
	page_open_ms = 0.0
	page_model_build_ms = 0.0
	page_loading = true
	profile_collecting = false
	profile_samples.clear()
	page_load_samples.clear()
	page_load_started_usec = Time.get_ticks_usec()
	status_label.text = "Loading models: 0/%d datasheets on %s. The table remains interactive while the page is prepared." % [page_total, ["both sides", "P1", "P2"][side_mode]]
	_refresh_selection_label()
	_set_camera()
	call_deferred("_load_page", generation)

func _load_page(generation: int) -> void:
	await get_tree().process_frame
	var unavailable_definitions: Array[String] = []
	var requested_sides: Array[int] = []
	if side_mode == 0:
		requested_sides.append(1)
		requested_sides.append(2)
	else:
		requested_sides.append(side_mode)
	for local_index in page_total:
		if generation != page_load_generation: return
		var record: Dictionary = profiles[page_index * PAGE_SIZE + local_index]
		var global_index := page_index * PAGE_SIZE + local_index
		var build_started_usec := Time.get_ticks_usec()
		var visual: Node3D = null
		if model_imports != null and model_imports.has_method("visual_for_async"):
			visual = await model_imports.visual_for_async(str(record.definition), float(record.base_radius_inches), Callable(self, "_is_page_generation_current").bind(generation))
		elif model_imports != null:
			visual = model_imports.visual_for(str(record.definition), float(record.base_radius_inches))
		if generation != page_load_generation: return
		if visual == null and not repair_attempted.has(str(record.definition)):
			repair_attempted[str(record.definition)] = true
			unavailable_definitions.append(str(record.definition))
		var base_status := _base_fit_status(record, visual)
		var ready := visual != null
		for side_index in requested_sides.size():
			var side := requested_sides[side_index]
			var side_visual: Node3D = visual if side_index == 0 else (visual.duplicate() as Node3D if visual != null else null)
			var at: Vector3 = left_positions[local_index] if side == 1 else right_positions[local_index]
			var side_ready := _add_miniature(record, global_index, side, at, side_visual, base_status)
			ready = ready and side_ready
		page_model_build_ms += float(Time.get_ticks_usec() - build_started_usec) / 1000.0
		page_visual_ready.append(ready)
		page_base_status.append(base_status)
		if ready: page_ready += 1
		page_progress.value = float(local_index + 1)
		status_label.text = "Loading models: %d/%d datasheets • %d/%d miniatures. ! unavailable; ~ estimated base; ? base fit needs review." % [local_index + 1, page_total, (local_index + 1) * requested_sides.size(), page_total * requested_sides.size()]
		_refresh_selection_label()
		await get_tree().process_frame
	if generation != page_load_generation: return
	page_open_ms = float(Time.get_ticks_usec() - page_load_started_usec) / 1000.0
	page_loading = false
	var side_text: String = ["both sides", "P1 only", "P2 only"][side_mode]
	status_label.text = "Models ready: %d/%d datasheets on %s. ! unavailable; ~ estimated base; ? base fit needs review. Page Up/Down changes pages. Visual-only, no match state or army legality." % [page_ready, page_total, side_text]
	_refresh_selection_label()
	if not unavailable_definitions.is_empty() and model_imports != null and model_imports.has_method("repair_unavailable_visuals"):
		repair_in_progress = true
		status_label.text = "Rechecking %d unavailable visual(s) from the local ForceOrg catalog…" % unavailable_definitions.size()
		if not model_imports.repair_unavailable_visuals(unavailable_definitions):
			repair_in_progress = false
			status_label.text = "Visual repair could not start. ! marks unavailable models; configure ForceOrg under Models and retry."
	if profiling_enabled:
		profile_elapsed = 0.0
		profile_samples.clear()
		profile_collecting = true

func _is_page_generation_current(generation: int) -> bool:
	return generation == page_load_generation

func _on_model_repair_finished(_ready: int, _total: int, _summary: String) -> void:
	if not repair_in_progress: return
	repair_in_progress = false
	_show_page(page_index, true, true)

func _add_miniature(record: Dictionary, global_index: int, side: int, at: Vector3, visual: Node3D, _base_status: String) -> bool:
	var base_spec := _base_spec(record)
	var profile_size: Vector2 = base_spec.size_inches
	var base_method := str(visual.get_meta("base_alignment_method", "")) if visual != null else ""
	var has_embedded_base := base_method in ["ring", "estimated-base"]
	# The colored rim represents the authoritative datasheet dimensions. The
	# imported scenic base stays underneath and is uniformly fitted by the model
	# importer; a detected footprint must not redefine the rules reference.
	var base_size := profile_size
	var color := Color("57c6e0") if side == 1 else Color("e78a4f")
	var pedestal := StaticBody3D.new()
	pedestal.position = at
	pedestal.input_ray_pickable = true
	pedestal.collision_layer = 1
	pedestal.set_meta("showcase_side", side)
	# Imported assets use +Z as forward: each side faces inward toward the table.
	var heading := _inward_yaw(side)
	pedestal.rotation_degrees.y = heading
	if has_embedded_base:
		var rim := MeshInstance3D.new()
		rim.mesh = _annular_base_mesh(base_size, BASE_RIM_WIDTH, BASE_RIM_HEIGHT)
		rim.position.y = BASE_RIM_HEIGHT * 0.5
		rim.rotation_degrees.y = float(OVAL_RIM_HEADING_OVERRIDES.get(str(record.get("identity", "")), 0.0))
		rim.material_override = side_materials[side]
		rim.layers = MODEL_LAYER
		pedestal.add_child(rim)
	else:
		var base := MeshInstance3D.new()
		var cylinder := CylinderMesh.new()
		cylinder.top_radius = 0.5
		cylinder.bottom_radius = 0.5
		cylinder.height = BASE_PROXY_HEIGHT
		cylinder.radial_segments = 48
		base.mesh = cylinder
		base.scale = Vector3(base_size.x, 1.0, base_size.y)
		base.position.y = BASE_PROXY_HEIGHT * 0.5
		base.material_override = proxy_materials[side]
		base.layers = MODEL_LAYER
		pedestal.add_child(base)
	var collision := CollisionShape3D.new()
	var shape := _footprint_pick_shape(base_size, 0.10)
	collision.shape = shape
	collision.position.y = BASE_PROXY_HEIGHT * 0.5
	pedestal.add_child(collision)
	var global_slot := global_index - page_index * PAGE_SIZE
	pedestal.input_event.connect(func(_camera: Node, event: InputEvent, _position: Vector3, _normal: Vector3, _shape_idx: int):
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			_select_profile(global_slot, side)
	)
	model_root.add_child(pedestal)
	var visual_root := Node3D.new()
	visual_root.position.y = 0.0 if has_embedded_base else BASE_PROXY_HEIGHT
	if visual != null:
		visual_root.add_child(visual)
		_set_render_layers(visual, MODEL_LAYER)
	else:
		visual_root.visible = false
		var missing := Label3D.new()
		missing.text = "!"
		missing.position.y = BASE_PROXY_HEIGHT + 0.25
		missing.font_size = 48
		missing.pixel_size = 0.009
		missing.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		missing.modulate = Color("f09078")
		missing.outline_size = 8
		missing.outline_modulate = Color("111820")
		missing.layers = MODEL_LAYER
		pedestal.add_child(missing)
	pedestal.add_child(visual_root)
	var number := Label3D.new()
	var base_marker := "?" if _base_status.begins_with("Review base fit") else ("~" if base_method != "ring" or bool(base_spec.proxy) else "")
	number.text = "%03d%s" % [global_index + 1, base_marker]
	number.position = Vector3(0.0, 0.025, base_size.y * 0.5 + 0.35)
	number.font_size = 38
	number.pixel_size = 0.009
	number.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	number.modulate = color.lightened(0.2)
	number.outline_size = 8
	number.outline_modulate = Color("111820")
	number.layers = MODEL_LAYER
	pedestal.add_child(number)
	return visual != null

static func _base_spec(profile: Dictionary) -> Dictionary:
	var source: Variant = profile.get("base_size_source_mm", null)
	var geometry := str(profile.get("base_geometry", "")).to_lower()
	var dimensions_mm := Vector2.ZERO
	var shape := "circle"
	if source is Array and not source.is_empty():
		if geometry == "per-model-circles":
			var largest_diameter := 0.0
			for size: Variant in source:
				if (size is int or size is float) and is_finite(float(size)):
					largest_diameter = maxf(largest_diameter, float(size))
			if largest_diameter > 0.0: dimensions_mm = Vector2.ONE * largest_diameter
		elif source.size() >= 2 and (source[0] is int or source[0] is float) and (source[1] is int or source[1] is float):
			dimensions_mm = Vector2(float(source[0]), float(source[1]))
			shape = "oval"
		elif source[0] is int or source[0] is float:
			dimensions_mm = Vector2.ONE * float(source[0])
	elif source is int or source is float:
		dimensions_mm = Vector2.ONE * float(source)
	elif source is String:
		var size_parts: PackedStringArray = source.to_lower().replace("mm", "").split("x", false)
		if size_parts.size() >= 2 and size_parts[0].strip_edges().is_valid_float() and size_parts[1].strip_edges().is_valid_float():
			dimensions_mm = Vector2(float(size_parts[0].strip_edges()), float(size_parts[1].strip_edges()))
			shape = "oval"
	var has_reference_dimensions := dimensions_mm.x > 0.0 and dimensions_mm.y > 0.0
	if not has_reference_dimensions:
		var diameter_mm := float(profile.get("base_radius_inches", 0.0)) * 50.8
		if diameter_mm <= 0.0: diameter_mm = 32.0
		dimensions_mm = Vector2.ONE * diameter_mm
	var source_description := str(profile.get("base_size_source", "")).to_lower()
	var proxy: bool = not has_reference_dimensions or bool(profile.get("base_size_is_approximate", false)) or "use model" in source_description or (source is String and "use model" in source.to_lower())
	if absf(dimensions_mm.x - dimensions_mm.y) > 0.5: shape = "oval"
	var role_sizes_mm: Array = source.duplicate() if source is Array and geometry == "per-model-circles" else []
	var summary := _base_dimensions_summary(source, geometry, dimensions_mm, shape)
	return {"size_inches": dimensions_mm / 25.4, "shape": shape, "dimensions_mm": dimensions_mm, "proxy": proxy,
		"role_sizes_mm": role_sizes_mm, "summary": summary}

static func _format_base_mm(value: float) -> String:
	var formatted := "%.1f" % value
	return formatted.trim_suffix(".0")

static func _base_dimensions_summary(source: Variant, geometry: String, dimensions_mm: Vector2, shape: String) -> String:
	if geometry == "per-model-circles" and source is Array:
		var counts: Dictionary = {}
		var sizes: Array[float] = []
		for value: Variant in source:
			if not (value is int or value is float) or not is_finite(float(value)): continue
			var size := float(value)
			var key := _format_base_mm(size)
			counts[key] = int(counts.get(key, 0)) + 1
			if size not in sizes: sizes.append(size)
		sizes.sort()
		var role_summary: Array[String] = []
		for size: float in sizes:
			var key := _format_base_mm(size)
			var count := int(counts[key])
			role_summary.append("%s mm (%d model%s)" % [key, count, "" if count == 1 else "s"])
		return ", ".join(role_summary)
	if shape == "oval":
		return "%s × %s mm oval" % [_format_base_mm(dimensions_mm.x), _format_base_mm(dimensions_mm.y)]
	return "%s mm circle" % _format_base_mm(dimensions_mm.x)

static func _inward_yaw(side: int) -> float:
	return 90.0 if side == 1 else -90.0

func _base_fit_status(profile: Dictionary, visual: Node3D) -> String:
	var spec := _base_spec(profile)
	if visual == null: return "Visual unavailable; showing %.1f mm %s proxy" % [spec.dimensions_mm.x, spec.shape]
	var method := str(visual.get_meta("base_alignment_method", ""))
	if method == "estimated-base": return "Native scenic base retained; contour and center are estimated"
	if method != "ring":
		return "Estimated ground contacts; showing %.1f × %.1f mm %s base proxy" % [spec.dimensions_mm.x, spec.dimensions_mm.y, spec.shape]
	if bool(spec.proxy): return "Native base ring detected; profile footprint is an approximate proxy"
	var actual: Vector2 = visual.get_meta("asset_base_footprint_inches", Vector2.ZERO) * 25.4
	var expected: Vector2 = spec.dimensions_mm
	var actual_sorted := Vector2(minf(actual.x, actual.y), maxf(actual.x, actual.y))
	var expected_sorted := Vector2(minf(expected.x, expected.y), maxf(expected.x, expected.y))
	var mismatch := maxf(absf(actual_sorted.x - expected_sorted.x), absf(actual_sorted.y - expected_sorted.y))
	if mismatch > 0.5:
		return "Review base fit: %.1f mm maximum difference" % mismatch
	return "Base ring fits within 0.5 mm"

func _annular_base_mesh(size: Vector2, rim_width: float, rim_height: float) -> ArrayMesh:
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	var half_inner := size * 0.5
	var half_outer := half_inner + Vector2.ONE * rim_width
	var segments := 48
	for index in segments:
		var angle_a := TAU * float(index) / float(segments)
		var angle_b := TAU * float(index + 1) / float(segments)
		var inner_a := Vector3(cos(angle_a) * half_inner.x, 0.0, sin(angle_a) * half_inner.y)
		var inner_b := Vector3(cos(angle_b) * half_inner.x, 0.0, sin(angle_b) * half_inner.y)
		var outer_a := Vector3(cos(angle_a) * half_outer.x, 0.0, sin(angle_a) * half_outer.y)
		var outer_b := Vector3(cos(angle_b) * half_outer.x, 0.0, sin(angle_b) * half_outer.y)
		var inner_a_top := inner_a + Vector3.UP * rim_height
		var inner_b_top := inner_b + Vector3.UP * rim_height
		var outer_a_top := outer_a + Vector3.UP * rim_height
		var outer_b_top := outer_b + Vector3.UP * rim_height
		_add_triangle(surface, outer_a_top, outer_b_top, inner_b_top, Vector3.UP)
		_add_triangle(surface, outer_a_top, inner_b_top, inner_a_top, Vector3.UP)
		_add_triangle(surface, outer_a, outer_b, outer_b_top, Vector3(cos(angle_a + angle_b), 0.0, sin(angle_a + angle_b)).normalized())
		_add_triangle(surface, outer_a, outer_b_top, outer_a_top, Vector3(cos(angle_a + angle_b), 0.0, sin(angle_a + angle_b)).normalized())
	surface.generate_normals()
	return surface.commit()

func _add_triangle(surface: SurfaceTool, a: Vector3, b: Vector3, c: Vector3, normal: Vector3) -> void:
	surface.set_normal(normal)
	surface.add_vertex(a)
	surface.add_vertex(b)
	surface.add_vertex(c)

func _footprint_pick_shape(size: Vector2, height: float) -> ConvexPolygonShape3D:
	var points := PackedVector3Array()
	var segments := 32
	for y: float in [-height * 0.5, height * 0.5]:
		for index in segments:
			var angle := TAU * float(index) / float(segments)
			points.append(Vector3(cos(angle) * size.x * 0.5, y, sin(angle) * size.y * 0.5))
	var shape := ConvexPolygonShape3D.new()
	shape.points = points
	return shape

func _set_render_layers(node: Node, layer: int) -> void:
	if node is VisualInstance3D: (node as VisualInstance3D).layers = layer
	for child: Node in node.get_children(): _set_render_layers(child, layer)

func _profile_selected(index: int) -> void:
	selected_slot = clampi(index, 0, maxi(0, page_total - 1))
	_refresh_selection_label()

func _select_profile(slot: int, side: int) -> void:
	selected_slot = clampi(slot, 0, maxi(0, page_total - 1))
	selected_side = side
	profile_picker.select(selected_slot)
	_refresh_selection_label()
	_focus_selected()

func _side_selected(index: int) -> void:
	side_mode = clampi(index, 0, 2)
	_show_page(page_index, true, true)

func _focus_selected() -> void:
	if page_total <= 0: return
	var side := selected_side
	if side_mode == 1: side = 1
	elif side_mode == 2: side = 2
	var positions := left_positions if side == 1 else right_positions
	pivot_goal = positions[selected_slot]
	pivot_goal.y = 0.0
	var profile: Dictionary = profiles[page_index * PAGE_SIZE + selected_slot]
	zoom_goal = clampf(float(profile.get("base_radius_inches", 1.0)) * 9.0, 5.0, 28.0)
	zoom_anchor = null

func _refresh_selection_label() -> void:
	if selected_label == null or page_total <= 0: return
	var profile: Dictionary = profiles[page_index * PAGE_SIZE + selected_slot]
	var model_status := "Model ready on both sides" if selected_slot < page_visual_ready.size() and page_visual_ready[selected_slot] else "No valid local model link"
	var base_status := page_base_status[selected_slot] if selected_slot < page_base_status.size() else "Base check pending"
	var base_summary := str(_base_spec(profile).summary)
	var display_name := str(profile.get("display_name", profile.name))
	selected_label.text = "%03d  %s  •  Rules bases: %s  •  %s  •  %s  •  P1 cyan / P2 orange  •  Facing review pending" % [page_index * PAGE_SIZE + selected_slot + 1, display_name, base_summary, base_status, model_status]

func set_preparation_status(message: String) -> void:
	if status_label != null: status_label.text = message

func handle_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_MIDDLE):
		zoom_goal = zoom
		pivot_goal = camera_target
		zoom_anchor = null
		angle -= event.relative.x * 0.006
		pitch = clampf(pitch + event.relative.y * 0.006, 0.16, 1.56)
		_set_camera()
	elif event is InputEventMouseButton and event.pressed and event.button_index in [MOUSE_BUTTON_WHEEL_UP, MOUSE_BUTTON_WHEEL_DOWN]:
		zoom_goal = clampf(zoom_goal * (0.88 if event.button_index == MOUSE_BUTTON_WHEEL_UP else 1.0 / 0.88), 5.0, 90.0)
		pivot_goal = camera_target
		zoom_anchor = TableCameraMotion.ground_anchor(camera, event.position)
		if zoom_anchor is Vector3 and (absf(zoom_anchor.x) > 44.0 or absf(zoom_anchor.z) > 44.0):
			zoom_anchor = null
	elif event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_PAGEUP: _show_page(page_index - 1)
		elif event.keycode == KEY_PAGEDOWN: _show_page(page_index + 1)

func _move_camera(delta: float) -> void:
	var direction := Vector3.ZERO
	if not get_viewport().gui_get_focus_owner() is Button and not Input.is_mouse_button_pressed(MOUSE_BUTTON_MIDDLE):
		direction.x = float(Input.is_physical_key_pressed(KEY_D)) - float(Input.is_physical_key_pressed(KEY_A))
		direction.z = float(Input.is_physical_key_pressed(KEY_S)) - float(Input.is_physical_key_pressed(KEY_W))
	if direction != Vector3.ZERO:
		pivot_goal = camera_target + direction.limit_length().rotated(Vector3.UP, angle) * delta * clampf(zoom * 0.55, 2.0, 24.0)
		camera_target = pivot_goal
		zoom_goal = zoom
		zoom_anchor = null
	elif camera_target.is_equal_approx(pivot_goal) and is_equal_approx(zoom, zoom_goal):
		return
	var weight := TableCameraMotion.zoom_weight(delta, motion_enabled)
	var next := lerpf(zoom, zoom_goal, weight)
	if absf(next - zoom_goal) < 0.005: next = zoom_goal
	if zoom_anchor is Vector3:
		camera_target = TableCameraMotion.anchored_pivot(camera_target, zoom_anchor, next / zoom)
		pivot_goal = camera_target
		if next == zoom_goal: zoom_anchor = null
	else:
		camera_target = camera_target.lerp(pivot_goal, weight)
		if camera_target.distance_to(pivot_goal) < 0.005: camera_target = pivot_goal
	camera_target.x = clampf(camera_target.x, -44.0, 44.0)
	camera_target.z = clampf(camera_target.z, -44.0, 44.0)
	zoom = next
	_set_camera()

func _set_camera() -> void:
	if camera == null: return
	camera.position = camera_target + TableCameraMotion.offset(angle, pitch, zoom * sqrt(1.0 + 0.82 * 0.82))
	camera.look_at(camera_target, Vector3.UP)

func _add_side_heading(text: String, at: Vector3, color: Color) -> void:
	var label := Label3D.new()
	label.text = text
	label.position = at
	label.font_size = 48
	label.pixel_size = 0.012
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.modulate = color
	label.outline_size = 10
	label.outline_modulate = Color("111820")
	label.layers = MODEL_LAYER
	add_child(label)

func _box(size: Vector3, at: Vector3, material: Material) -> MeshInstance3D:
	var mesh := BoxMesh.new()
	mesh.size = size
	var instance := MeshInstance3D.new()
	instance.mesh = mesh
	instance.position = at
	instance.material_override = material
	instance.layers = MODEL_LAYER
	return instance

func _material(color: Color, emission_color: Color = Color.BLACK, energy: float = 0.0) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.84
	if energy > 0.0:
		material.emission_enabled = true
		material.emission = emission_color
		material.emission_energy_multiplier = energy
	return material

func _button(parent: Node, text: String, action: Callable, icon_key: String = "") -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size.y = 38.0
	button.pressed.connect(action)
	WorkspaceTheme.decorate_button(button, icon_key)
	parent.add_child(button)
	return button
