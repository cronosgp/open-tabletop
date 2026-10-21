extends RefCounted
## Camera-only subject selection and viewport fitting. Never executes a rule command.
const Combat = preload("res://scripts/edition_11/combat_scenario.gd")

static func models(state: Dictionary, squads: Array) -> Array[int]:
	var result: Array[int] = []
	for id: int in state.get("units", {}):
		var unit: Dictionary = state.units[id]
		if unit.squad in squads and unit.wounds > 0 and unit.get("on_battlefield", true): result.append(id)
	return result

static func subject(state: Dictionary, selected: int, draft: Dictionary, context: Dictionary) -> Dictionary:
	var squads: Array = []
	var key := ""
	var actor := Combat.actor(state)
	if context.get("defense", false):
		var hazard: Dictionary = state.get("pending_hazard", {})
		if not hazard.is_empty():
			var ids := Combat.Hazard.eligible(state)
			return {"key": "hazard:%d:%s" % [actor, str(hazard.get("squad", ""))], "models": ids}
		var current: Dictionary = state.get("pending_attack", {}).get("current", {})
		if not current.is_empty():
			squads = [current.target]
			key = "defense:%d:%s:%d" % [current.target, str(current.phase), actor]
	elif context.get("reaction", false):
		var window := Combat.Stratagems.pending(state)
		var squad := int(window.get("squad", context.get("reaction_squad", -1)))
		squads = [squad]
		key = "reaction:%s:%d:%d" % [str(window.get("kind", "")), squad, actor]
	elif context.get("contact", false) and not state.get("pending_contact", {}).is_empty():
		var contact: Dictionary = state.pending_contact
		squads = [contact.squad]
		squads.append_array(contact.get("targets", []))
		key = "contact:%s:%s:%d" % [str(contact.kind), str(squads), actor]
	elif context.get("contact", false) and not state.get("pending_charge", {}).is_empty():
		squads = [state.pending_charge.squad]
		squads.append_array(state.pending_charge.get("targets", []))
		key = "charge-targets:%s:%d" % [str(squads), actor]
	elif context.get("movement", false) and not state.get("pending_move", {}).is_empty():
		squads = [state.pending_move.squad]
		key = "move:%d:%d" % [squads[0], actor]
	elif context.get("attack", false) and not draft.is_empty():
		squads = [draft.squad]
		var target := int(context.get("attack_target", -1))
		if state.squads.has(target): squads.append(target)
		key = "plan:%s:%d" % [str(squads), actor]
	elif context.get("deployment", false):
		var squad := Combat.Deployment.current(state)
		squads = [squad]
		key = "deploy:%d:%d" % [squad, actor]
	elif context.get("ordinary", false) and state.units.has(selected):
		var unit: Dictionary = state.units[selected]
		if unit.owner == actor:
			squads = [unit.squad]
			key = "unit:%s:%d:%d" % [str(state.phase), int(unit.squad), actor]
	return {"key": key, "models": models(state, squads)}

static func points(state: Dictionary, ids: Array) -> Array[Vector3]:
	var result: Array[Vector3] = []
	for id: int in ids:
		if not state.units.has(id): continue
		var unit: Dictionary = state.units[id]
		if unit.wounds <= 0 or not unit.get("on_battlefield", true): continue
		var p: Vector2 = unit.position
		var radius := float(unit.get("radius", 0.5))
		for x: float in [-radius, radius]:
			for z: float in [-radius, radius]:
				for y: float in [0.0, 2.5]: result.append(Vector3(p.x + x, y, p.y + z))
	return result

static func max_zoom(state: Dictionary) -> float:
	var size: Vector2 = state.get("board_size", Vector2(30, 20))
	return maxf(55.0, size.length() * 1.5)

static func _orient(camera: Camera3D, pivot: Node3D, zoom: float, angle: float) -> void:
	camera.position = Vector3(sin(angle) * zoom, zoom * 0.85, cos(angle) * zoom)
	camera.look_at(pivot.global_position, Vector3.UP)
	pivot.force_update_transform()
	camera.force_update_transform()

static func plan(camera: Camera3D, pivot: Node3D, state: Dictionary, ids: Array, board_area: Rect2, angle: float) -> Dictionary:
	var vertices := points(state, ids)
	var area := board_area.grow(-24.0)
	if vertices.is_empty() or area.size.x < 100.0 or area.size.y < 100.0: return {}
	var center := Vector3.ZERO
	for point: Vector3 in vertices: center += point
	center /= vertices.size()
	center.y = 0.0
	var old_position := pivot.position
	var old_camera := camera.transform
	var result := {}
	var candidate := 14.0
	var maximum := max_zoom(state)
	# Probe the existing projection synchronously, then restore the camera exactly.
	# No render frame or rule command occurs while probing.
	for _attempt in 32:
		pivot.position = old_position
		_orient(camera, pivot, candidate, angle)
		var hit: Variant = Plane(Vector3.UP, 0).intersects_ray(camera.project_ray_origin(area.get_center()), camera.project_ray_normal(area.get_center()))
		if hit == null: break
		pivot.position += center - Vector3(hit)
		_orient(camera, pivot, candidate, angle)
		var fits := true
		var bounds := Rect2(camera.unproject_position(vertices[0]), Vector2.ZERO)
		for point: Vector3 in vertices:
			if camera.is_position_behind(point):
				fits = false
				break
			var screen := camera.unproject_position(point)
			bounds = bounds.expand(screen)
			if not area.has_point(screen): fits = false
		if fits:
			result = {"position": pivot.position, "zoom": candidate, "bounds": bounds, "area": area}
			break
		if candidate >= maximum: break
		candidate = minf(maximum, candidate * 1.16)
	pivot.position = old_position
	camera.transform = old_camera
	pivot.force_update_transform()
	camera.force_update_transform()
	return result
