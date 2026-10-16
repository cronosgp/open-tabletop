extends RefCounted
## Ground-level terrain and explicit cylindrical visibility proxies.
const Board = preload("res://scripts/rules.gd")
const EPSILON := 0.001
const SIGHT_RADIUS := 0.5 / 25.4 # Half of the required 1mm sightline width.
const DEFAULT_LAYOUT := "terrain-11e-v1"

static func layout(id: String = DEFAULT_LAYOUT) -> Dictionary:
	if id == "legacy-solid-v1":
		var areas: Array[Dictionary] = []
		for index in range(Board.TERRAIN.size()):
			var bounds: Rect2 = Board.TERRAIN[index]
			areas.append({"name": "Legacy obstacle", "category": "legacy", "bounds": bounds, "features": [{"bounds": bounds, "height": 1.5, "blocks_end": true}]})
		return {"id": id, "areas": areas}
	if id != DEFAULT_LAYOUT: return {"error": "Unknown terrain layout: " + id}
	return {"id": id, "areas": [
		{"name": "Central ruin", "category": "dense", "bounds": Rect2(-3, -2, 6, 4), "features": [
			{"bounds": Rect2(-3, -2, 6, 0.25), "height": 4.0, "blocks_end": true},
			{"bounds": Rect2(-3, -2, 0.25, 4), "height": 4.0, "blocks_end": true}]},
		{"name": "Rubble", "category": "exposed", "bounds": Rect2(-11, 3, 4, 2), "features": [
			{"bounds": Rect2(-10, 3.8, 2, 0.25), "height": 0.2, "blocks_end": false}]},
		{"name": "Barricade", "category": "light", "bounds": Rect2(7, -5, 4, 2), "features": [
			{"bounds": Rect2(7, -4.1, 4, 0.2), "height": 1.0, "blocks_end": true}]}
	]}

static func areas(state: Dictionary) -> Array:
	if state.has("terrain"): return state.terrain.areas
	return layout("legacy-solid-v1").areas

static func legacy(state: Dictionary) -> bool:
	return state.get("terrain", {}).get("id", "legacy-solid-v1") == "legacy-solid-v1"

static func has_keyword(model: Dictionary, keywords: Array[String]) -> bool:
	for keyword: String in model.get("keywords", []):
		if keyword.to_lower() in keywords: return true
	return false

static func within(model: Dictionary, bounds: Rect2) -> bool:
	return model.position.distance_to(model.position.clamp(bounds.position, bounds.end)) <= float(model.radius) + EPSILON

static func model_areas(state: Dictionary, model: int) -> Array[Dictionary]:
	var found: Array[Dictionary] = []
	for area: Dictionary in areas(state):
		if within(state.units[model], area.bounds): found.append(area)
	return found

static func segment_hits(first: Vector2, last: Vector2, rect: Rect2) -> bool:
	if rect.has_point(first) or rect.has_point(last): return true
	var corners: Array[Vector2] = [rect.position, Vector2(rect.end.x, rect.position.y), rect.end, Vector2(rect.position.x, rect.end.y)]
	for index in range(4):
		if Geometry2D.segment_intersects_segment(first, last, corners[index], corners[(index + 1) % 4]) != null: return true
	return false

static func movement_obstacles(state: Dictionary, model: int) -> Array[Rect2]:
	var blocked: Array[Rect2] = []
	var passes_dense := has_keyword(state.units[model], ["infantry", "beasts", "swarm", "mobile"])
	for area: Dictionary in areas(state):
		for feature: Dictionary in area.features:
			if area.category == "legacy" or (area.category == "dense" and not passes_dense and float(feature.height) > 2.0): blocked.append(feature.bounds)
	return blocked

static func path_error(state: Dictionary, model: int, destination: Vector2) -> String:
	var unit: Dictionary = state.units[model]
	if float(unit.get("elevation", 0)) != 0.0: return "Upper-floor movement is not supported in this exercise."
	var radius := maxf(0.0, float(unit.radius) - EPSILON)
	for obstacle: Rect2 in movement_obstacles(state, model):
		if segment_hits(unit.position, destination, obstacle.grow(radius)): return "This model cannot pass through that terrain feature at ground level."
	for area: Dictionary in areas(state):
		for feature: Dictionary in area.features:
			if feature.blocks_end and destination.distance_to(destination.clamp(feature.bounds.position, feature.bounds.end)) < radius:
				return "The base cannot finish inside a terrain wall or barricade."
	return ""

static func _alive(state: Dictionary, squad: int) -> Array[int]:
	var ids: Array[int] = []
	for id: int in state.units:
		if state.units[id].squad == squad and state.units[id].wounds > 0: ids.append(id)
	return ids

static func hidden(state: Dictionary, model: int) -> bool:
	if legacy(state) or state.units[model].wounds <= 0: return false
	var unit: Dictionary = state.units[model]
	if not has_keyword(unit, ["infantry", "beasts", "swarm"]): return false
	if int(state.squads[unit.squad].get("last_ranged_turn", -1)) >= int(state.turn) - 1: return false
	for area: Dictionary in model_areas(state, model):
		if area.category in ["light", "dense"] and not area.features.is_empty(): return true
	return false

static func _point_in_triangle(point: Vector2, triangle: Array[Vector2]) -> bool:
	return Geometry2D.is_point_in_polygon(point, PackedVector2Array(triangle))

static func _hull_hits(observer: Vector2, target: Dictionary, rect: Rect2) -> bool:
	# Convex hull of observing centre and target disk = tangent triangle + disk.
	# This certifies full visibility from that centre without sampling gaps.
	var radius: float = target.radius
	if target.position.distance_to(target.position.clamp(rect.position, rect.end)) <= radius: return true
	var delta: Vector2 = observer - target.position
	var square := delta.length_squared()
	if square <= radius * radius: return false
	var foot: Vector2 = target.position + delta * radius * radius / square
	var offset: Vector2 = delta.orthogonal() * radius * sqrt(square - radius * radius) / square
	var triangle: Array[Vector2] = [observer, foot + offset, foot - offset]
	for corner in [rect.position, Vector2(rect.end.x, rect.position.y), rect.end, Vector2(rect.position.x, rect.end.y)]:
		if _point_in_triangle(corner, triangle): return true
	for index in range(3):
		if segment_hits(triangle[index], triangle[(index + 1) % 3], rect): return true
	return false

static func pair(state: Dictionary, observer: int, target: int) -> Dictionary:
	var first: Dictionary = state.units[observer]
	var last: Dictionary = state.units[target]
	if legacy(state):
		var clear := true
		for area: Dictionary in areas(state):
			if segment_hits(first.position, last.position, area.bounds): clear = false
		return {"visible": clear, "fully_visible": clear, "hidden": false, "detection": 15.0, "gone_to_ground": false}
	var partially_blocked := false
	var dense_blocked := false
	for area: Dictionary in areas(state):
		var own_area := within(first, area.bounds) or within(last, area.bounds)
		if area.category in ["light", "dense"] and not own_area and _hull_hits(first.position, last, area.bounds.grow(SIGHT_RADIUS)):
			partially_blocked = true
		for feature: Dictionary in area.features:
			if float(feature.height) > 0 and _hull_hits(first.position, last, feature.bounds.grow(SIGHT_RADIUS)):
				partially_blocked = true
				if area.category == "dense": dense_blocked = true
	var is_hidden := hidden(state, target)
	var grounded := is_hidden and dense_blocked
	var detection := 12.0 if grounded else 15.0
	var distance: float = maxf(0.0, first.position.distance_to(last.position) - float(first.radius) - float(last.radius))
	if is_hidden and distance > detection + EPSILON:
		return {"visible": false, "fully_visible": false, "hidden": true, "detection": detection, "gone_to_ground": grounded}
	var side: Vector2 = (last.position - first.position).normalized().orthogonal()
	if side == Vector2.ZERO: side = Vector2.UP
	var visible := false
	# A clear ray is a valid witness in the cylindrical proxy. No witness is
	# conservative, rather than claiming exact imported-mesh visibility.
	var ray_height := minf(float(first.get("sight_height", 1.3)), float(last.get("sight_height", 1.3)))
	for first_offset in [0.0, -1.0, 1.0]:
		for last_offset in [0.0, -1.0, 1.0]:
			var start: Vector2 = first.position + side * float(first.radius) * first_offset
			var end: Vector2 = last.position + side * float(last.radius) * last_offset
			var clear := true
			for area: Dictionary in areas(state):
				if area.category in ["light", "dense"] and not within(first, area.bounds) and not within(last, area.bounds) and segment_hits(start, end, area.bounds.grow(SIGHT_RADIUS)): clear = false
				for feature: Dictionary in area.features:
					if float(feature.height) >= ray_height and segment_hits(start, end, feature.bounds.grow(SIGHT_RADIUS)): clear = false
			if clear: visible = true
	return {"visible": visible, "fully_visible": visible and not partially_blocked, "hidden": is_hidden, "detection": detection, "gone_to_ground": grounded}

static func benefit_of_cover(state: Dictionary, observer: int, squad: int) -> bool:
	if legacy(state): return false
	var ids := _alive(state, squad)
	if ids.is_empty(): return false
	for id: int in ids:
		var in_area := has_keyword(state.units[id], ["infantry", "beasts", "swarm"]) and not model_areas(state, id).is_empty()
		if not in_area and pair(state, observer, id).fully_visible: return false
	return true

static func targeting(state: Dictionary, observer: int, squad: int) -> Dictionary:
	var visible := false
	var distance := INF
	for id: int in _alive(state, squad):
		visible = visible or pair(state, observer, id).visible
		distance = minf(distance, maxf(0.0, state.units[observer].position.distance_to(state.units[id].position) - float(state.units[observer].radius) - float(state.units[id].radius)))
	return {"visible": visible, "distance": distance, "cover": benefit_of_cover(state, observer, squad)}
