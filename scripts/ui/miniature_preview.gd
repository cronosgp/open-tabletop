extends VBoxContainer
var title: Label
var caption: Label
var scene: Node3D
var camera: Camera3D
var viewport: SubViewport
var surface: SubViewportContainer
var camera_controls: HBoxContainer
var visual: Node3D
var imported := false
var focus_point := Vector3.ZERO
var fit_distance := 2.5
var zoom := 1.0
func _ready() -> void:
	custom_minimum_size.x = 290
	title = Label.new()
	title.text = "Select a unit"
	title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	add_child(title)
	surface = SubViewportContainer.new()
	surface.custom_minimum_size = Vector2(290, 260)
	surface.stretch = true
	add_child(surface)
	viewport = SubViewport.new()
	viewport.size = Vector2i(360, 300)
	viewport.own_world_3d = true
	viewport.render_target_update_mode = SubViewport.UPDATE_WHEN_VISIBLE
	surface.add_child(viewport)
	scene = Node3D.new()
	viewport.add_child(scene)
	camera = Camera3D.new()
	viewport.add_child(camera)
	var light := DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-40, -35, 0)
	viewport.add_child(light)
	var world := WorldEnvironment.new()
	world.environment = Environment.new()
	world.environment.background_mode = Environment.BG_COLOR
	world.environment.background_color = Color("151f29")
	world.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	world.environment.ambient_light_color = Color.WHITE
	world.environment.ambient_light_energy = 0.65
	viewport.add_child(world)
	caption = Label.new()
	caption.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	add_child(caption)
	move_child(caption, 1)
	var rotate := HBoxContainer.new()
	camera_controls = rotate
	add_child(rotate)
	for direction in [-1, 1]:
		var button := Button.new()
		button.text = "↶" if direction == -1 else "↷"
		button.tooltip_text = "Rotate left" if direction == -1 else "Rotate right"
		button.custom_minimum_size = Vector2(40, 36)
		button.pressed.connect(func(): scene.rotate_y(direction * PI / 6))
		rotate.add_child(button)
	var tools := rotate
	for action in ["Zoom −", "Fit", "Zoom +"]:
		var button := Button.new()
		button.text = action.replace("Zoom ", "")
		button.custom_minimum_size = Vector2(40, 36)
		button.tooltip_text = action + " · adjusts the preview camera only."
		button.pressed.connect(func():
			if action == "Fit":
				zoom = 1.0
				scene.rotation = Vector3.ZERO
			else: zoom = clampf(zoom * (1.2 if action == "Zoom −" else 0.8), 0.4, 3.0)
			_fit_camera()
		)
		tools.add_child(button)
	surface.resized.connect(_fit_camera)
	show_model({}, null, false)

func show_model(entry: Dictionary, node: Node3D, is_imported: bool) -> void:
	if scene == null:
		if node != null: node.free()
		return
	for child in scene.get_children():
		scene.remove_child(child)
		child.queue_free()
	scene.rotation = Vector3.ZERO
	title.text = str(entry.get("name", "Select a unit"))
	imported = is_imported
	surface.visible = not entry.is_empty()
	camera_controls.visible = not entry.is_empty()
	visual = node
	if visual == null:
		visual = MeshInstance3D.new()
		var mesh := CylinderMesh.new()
		mesh.top_radius = 0.28
		mesh.bottom_radius = 0.4
		mesh.height = 1.2
		visual.mesh = mesh
		visual.position.y = 0.6
		var material := StandardMaterial3D.new()
		material.albedo_color = Color("68b8c7")
		visual.material_override = material
	scene.add_child(visual)
	var bounds := bounds_of(visual)
	focus_point = bounds.get_center()
	# Rotate around the model's center, including off-origin imported meshes.
	visual.position -= focus_point
	focus_point = Vector3.ZERO
	fit_distance = maxf(0.05, bounds.size.length() * 0.5)
	zoom = 1.0
	_fit_camera()
	caption.text = "Imported local model" if imported else "Default placeholder · no ready local model"
	if entry.is_empty(): caption.text = "Select a roster unit to preview its appearance."
	caption.tooltip_text = caption.text

func _fit_camera() -> void:
	if camera == null or viewport == null or not camera.is_inside_tree(): return
	var aspect := float(viewport.size.x) / maxf(1.0, float(viewport.size.y))
	var half_angle := deg_to_rad(camera.fov * 0.5)
	if aspect < 1.0: half_angle = atan(tan(half_angle) * aspect)
	var distance := fit_distance / sin(half_angle) * 1.12 * zoom
	camera.position = focus_point + Vector3(0.7, 0.4, 1).normalized() * distance
	camera.look_at(focus_point)
	camera.near = maxf(0.001, distance / 1000.0)
	camera.far = maxf(100.0, distance * 5)

static func bounds_of(node: Node3D) -> AABB:
	var result := AABB()
	var found := false
	var pending: Array[Node] = [node]
	while not pending.is_empty():
		var current: Node = pending.pop_back()
		pending.append_array(current.get_children())
		if current is MeshInstance3D and current.mesh != null:
			var bounds: AABB = current.global_transform * current.get_aabb()
			result = result.merge(bounds) if found else bounds
			found = true
	return result
