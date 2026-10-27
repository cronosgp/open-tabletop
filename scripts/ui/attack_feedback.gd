extends Node3D
## Schematic completed-attack relationship, never a ballistic/visibility simulation.
var observed := false
var signature := ""
var declaration_key := ""
var bursts := 0

func reset() -> void:
	observed = false
	signature = ""
	declaration_key = ""
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
	if not enabled or not presenting:
		declaration_key = ""
		clear()
	if not observed:
		observed = true
		return
	if not enabled or not presenting: return
	if not state.get("pending_attack", {}).is_empty():
		var declare := _declaration_key(state)
		if declare == declaration_key: return
		declaration_key = declare
		clear()
		if not declare.is_empty(): _show_declaration(state)
		return
	var pending_hazard: bool = not state.get("pending_hazard", {}).is_empty()
	if declaration_key != "":
		declaration_key = ""
		clear()
	if pending_hazard or key.is_empty() or key == previous: return
	var targets := {}
	var weapons := {}
	for pool: Dictionary in state.last_attack.get("pools", []):
		var target := int(pool.get("target_squad", -1))
		targets[target] = int(targets.get(target, 0)) + int(pool.get("damage_applied", 0))
		var weapon_name := str(pool.get("weapon_name", "")).strip_edges()
		if weapon_name.is_empty(): continue
		if not weapons.has(target): weapons[target] = []
		if weapon_name not in weapons[target]: weapons[target].append(weapon_name)
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
		var damage := int(targets[target])
		var weapon_label := ", ".join(weapons.get(target, []))
		var target_name := str(state.get("squads", {}).get(target, {}).get("name", "Target"))
		var relation := target_name if weapon_label.is_empty() else "%s → %s" % [weapon_label, target_name]
		var caption := "%s\n%d damage" % [relation, damage] if damage > 0 else "%s\nNo damage" % relation
		_burst(source, end, damage > 0, caption)

func _declaration_key(state: Dictionary) -> String:
	var pending: Dictionary = state.get("pending_attack", {})
	var current: Dictionary = pending.get("current", {})
	var checkpoint: Dictionary = current.get("checkpoint", {})
	var weapon: Dictionary = current.get("weapon", checkpoint.get("weapon", {}))
	var attacker := int(pending.get("squad", -1))
	var target := int(current.get("target", checkpoint.get("target", -1)))
	if attacker < 0 or target < 0: return ""
	return "declare:%d:%d:%s" % [attacker, target, str(weapon.get("name", ""))]

func _show_declaration(state: Dictionary) -> void:
	var pending: Dictionary = state.get("pending_attack", {})
	var current: Dictionary = pending.get("current", {})
	var checkpoint: Dictionary = current.get("checkpoint", {})
	var weapon: Dictionary = current.get("weapon", checkpoint.get("weapon", {}))
	var attacker := int(pending.get("squad", -1))
	var target := int(current.get("target", checkpoint.get("target", -1)))
	var start: Variant = center(state, attacker)
	var end: Variant = center(state, target)
	if start == null or end == null: return
	var weapon_name := str(weapon.get("name", "Attack")).strip_edges()
	if weapon_name.is_empty(): weapon_name = "Attack"
	var target_name := str(state.get("squads", {}).get(target, {}).get("name", "Target"))
	_link(start, end, Color("f2df83"), false, "%s → %s" % [weapon_name, target_name], false)

func _burst(start: Vector3, end: Vector3, damaged: bool, caption: String) -> void:
	var color := Color("f0a478") if damaged else Color("7eb8c4")
	_link(start, end, color, true, caption, true)

func _link(start: Vector3, end: Vector3, color: Color, ring: bool, caption: String, fade: bool) -> void:
	var root := Node3D.new()
	var mesh := ImmediateMesh.new()
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.vertex_color_use_as_albedo = true
	material.no_depth_test = false
	mesh.surface_begin(Mesh.PRIMITIVE_LINES, material)
	mesh.surface_set_color(color)
	mesh.surface_add_vertex(start)
	mesh.surface_add_vertex(end)
	var direction := (end - start).normalized()
	var side := direction.cross(Vector3.UP)
	if side.length_squared() < 0.001: side = Vector3.RIGHT
	else: side = side.normalized()
	for signum: float in [-1.0, 1.0]:
		mesh.surface_add_vertex(end)
		mesh.surface_add_vertex(end - direction * 1.0 + side * signum * 0.5)
	if ring:
		for i in 40:
			for step in [i, i + 1]:
				var angle: float = TAU * step / 40.0
				mesh.surface_add_vertex(end + Vector3(cos(angle), 0, sin(angle)) * 1.6)
	mesh.surface_end()
	var instance := MeshInstance3D.new()
	instance.mesh = mesh
	root.add_child(instance)
	var label := Label3D.new()
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.no_depth_test = true
	label.pixel_size = 0.01
	label.font_size = 42
	label.outline_size = 8
	label.outline_modulate = Color("10161b")
	label.modulate = color
	label.text = caption
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.position = end + Vector3(0, 0.9, 0)
	root.add_child(label)
	add_child(root)
	bursts += 1
	if not fade: return
	var tween := root.create_tween()
	tween.tween_interval(0.45)
	tween.tween_method(func(alpha: float):
		material.albedo_color.a = alpha
		label.modulate.a = alpha
	, 1.0, 0.0, 0.5)
	tween.tween_callback(root.queue_free)
