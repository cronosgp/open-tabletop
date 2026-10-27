extends Node3D
## Schematic completed-attack relationship, never a ballistic/visibility simulation.
var observed := false
var signature := ""
var bursts := 0

func reset() -> void:
	observed = false
	signature = ""
	clear()

func clear() -> void:
	for child in get_children():
		remove_child(child)
		child.queue_free()

static func record_key(state: Dictionary) -> String:
	var last: Dictionary = state.get("last_attack", {})
	if last.is_empty(): return ""
	# History is bounded: array positions change even when no attack happens.
	# New records persist their completion identity; old saves use stable content.
	if last.has("completion_revision"): return "attack:%d" % int(last.completion_revision)
	return "legacy:" + str(hash(var_to_str(last)))

static func center(state: Dictionary, squad: int) -> Variant:
	var point := Vector3.ZERO
	var count := 0
	for unit: Dictionary in state.get("units", {}).values():
		# Include casualties so an eliminated target still has a recorded location.
		if unit.squad != squad or not unit.get("on_battlefield", true): continue
		point += Vector3(unit.position.x, 0.18, unit.position.y)
		count += 1
	return point / count if count > 0 else null

func sync(state: Dictionary, enabled: bool, presenting: bool) -> void:
	var key := record_key(state)
	var previous := signature
	signature = key
	if not enabled or not presenting: clear()
	if not observed:
		observed = true
		return
	if key.is_empty() or key == previous or not enabled or not presenting: return
	if not state.get("pending_attack", {}).is_empty() or not state.get("pending_hazard", {}).is_empty(): return
	var targets := {}
	for pool: Dictionary in state.last_attack.get("pools", []):
		var target := int(pool.get("target_squad", -1))
		targets[target] = int(targets.get(target, 0)) + int(pool.get("damage_applied", 0))
	clear()
	for target: int in targets:
		if get_child_count() >= 8: break
		var end: Variant = center(state, target)
		if end == null: continue
		var source: Variant = null
		for row: Dictionary in state.last_attack.get("assignments", []):
			if row.get("target", -1) == target and state.units.has(row.get("model", -1)):
				source = center(state, int(state.units[row.model].squad))
				break
		if source == null: continue
		_burst(source, end, int(targets[target]) > 0)

func _burst(start: Vector3, end: Vector3, damaged: bool) -> void:
	var mesh := ImmediateMesh.new()
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.vertex_color_use_as_albedo = true
	material.no_depth_test = false
	mesh.surface_begin(Mesh.PRIMITIVE_LINES, material)
	mesh.surface_set_color(Color("e8cd79"))
	mesh.surface_add_vertex(start)
	mesh.surface_add_vertex(end)
	var direction := (end - start).normalized()
	var side := direction.cross(Vector3.UP)
	for signum: float in [-1.0, 1.0]:
		mesh.surface_add_vertex(end)
		mesh.surface_add_vertex(end - direction * 1.0 + side * signum * 0.5)
	mesh.surface_set_color(Color("f0a478") if damaged else Color("a3dce5"))
	for i in 40:
		for step in [i, i + 1]:
			var angle: float = TAU * step / 40.0
			mesh.surface_add_vertex(end + Vector3(cos(angle), 0, sin(angle)) * 1.6)
	mesh.surface_end()
	var instance := MeshInstance3D.new()
	instance.mesh = mesh
	add_child(instance)
	bursts += 1
	var tween := instance.create_tween()
	tween.tween_interval(0.2)
	tween.tween_method(func(alpha: float): material.albedo_color.a = alpha, 1.0, 0.0, 0.6)
	tween.tween_callback(instance.queue_free)
