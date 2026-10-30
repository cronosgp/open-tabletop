extends RefCounted
## Core 15.10 coverage in the existing ground-level cylindrical proxy.
const Abilities = preload("res://scripts/edition_11/detection_rules.gd")
const IMPLEMENTATION_ID := "core-reaction-stratagems-2026-10-high-marshal-helbrecht-v3-defensive-array"
const EPSILON := 0.001
const SIGHT_RADIUS := 0.5 / 25.4

static func active(state: Dictionary) -> Dictionary:
	if state.get("core_reactions", {}).get("implementation", "") != IMPLEMENTATION_ID or not state.has("stratagems"): return {}
	if state.get("unit_abilities", {}).get("implementation", "") != Abilities.ABILITY_IMPLEMENTATION_ID: return {}
	var current_key := "%d:%s" % [state.turn, state.phase]
	if state.phase != "shooting": return {}
	for smoke: Dictionary in sources(state):
		if smoke.get("phase_key", "") == current_key: return smoke
	return {}

static func sources(state: Dictionary) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var smoke: Variant = state.get("core_reactions", {}).get("smoke", {})
	if smoke is Dictionary:
		if not smoke.is_empty(): result.append(smoke)
	elif smoke is Array:
		for record: Variant in smoke:
			if record is Dictionary: result.append(record)
	return result

static func _intervenes(observer: Dictionary, target: Dictionary, blocker: Dictionary) -> bool:
	var delta: Vector2 = target.position - observer.position
	var length_squared := delta.length_squared()
	if length_squared <= EPSILON: return false
	var along: float = (blocker.position - observer.position).dot(delta) / length_squared
	# Only an intervening disk can obstruct the facing surface of the target.
	if along <= 0.0 or along >= 1.0: return false
	var radius: float = target.radius
	if length_squared <= radius * radius: return false
	var towards: Vector2 = -delta
	var foot: Vector2 = target.position + towards * radius * radius / length_squared
	var offset: Vector2 = towards.orthogonal() * radius * sqrt(length_squared - radius * radius) / length_squared
	var triangle := PackedVector2Array([observer.position, foot + offset, foot - offset])
	if Geometry2D.is_point_in_polygon(blocker.position, triangle): return true
	for index in range(3):
		var closest := Geometry2D.get_closest_point_to_segment(blocker.position, triangle[index], triangle[(index + 1) % 3])
		if closest.distance_to(blocker.position) <= float(blocker.radius) + SIGHT_RADIUS: return true
	return false

static func cover(state: Dictionary, observer: int, target: int) -> bool:
	for smoke: Dictionary in sources(state):
		if smoke.get("phase_key", "") != "%d:%s" % [state.turn, state.phase] or state.phase != "shooting": continue
		var source: int = int(smoke.get("squad", -1))
		if target == source: return true
		# Models in the observer's own unit are ignored for line of sight.
		if source == state.units[observer].squad: continue
		for model: Dictionary in state.units.values():
			if model.squad != source or model.wounds <= 0 or not model.get("on_battlefield", true): continue
			for defender: Dictionary in state.units.values():
				if defender.squad != target or defender.wounds <= 0 or not defender.get("on_battlefield", true): continue
				if _intervenes(state.units[observer], defender, model): return true
	return false
