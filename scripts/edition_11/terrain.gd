extends RefCounted
## Ground-level terrain and explicit cylindrical visibility proxies.
const Board = preload("res://scripts/rules.gd")
const Smoke = preload("res://scripts/edition_11/smokescreen.gd")
const Detection = preload("res://scripts/edition_11/detection_rules.gd")
const EPSILON := 0.001
const SIGHT_RADIUS := 0.5 / 25.4 # Half of the required 1mm sightline width.
const DEFAULT_LAYOUT := "terrain-11e-v1"
const TAKE_AND_HOLD_LAYOUTS := {
	"ca-2026-27-take-and-hold-mirror-a-v1": {"label": "Layout A", "image": "43_Take_and_Hold_vs_Take_and_Hold_Layout_A.png"},
	"ca-2026-27-take-and-hold-mirror-b-v1": {"label": "Layout B", "image": "44_Take_and_Hold_vs_Take_and_Hold_Layout_B.png"},
	"ca-2026-27-take-and-hold-mirror-c-v1": {"label": "Layout C", "image": "45_Take_and_Hold_vs_Take_and_Hold_Layout_C.png"}
}

static func event_layout_options() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for id: String in TAKE_AND_HOLD_LAYOUTS:
		var item: Dictionary = TAKE_AND_HOLD_LAYOUTS[id].duplicate(true)
		item.id = id
		result.append(item)
	return result

static func is_event_layout(id: String) -> bool:
	return TAKE_AND_HOLD_LAYOUTS.has(id)

static func event_layout_image_path(id: String) -> String:
	if not TAKE_AND_HOLD_LAYOUTS.has(id): return ""
	return ".tools/wahapedia/11e/event-layouts/take-and-hold-mirror/" + str(TAKE_AND_HOLD_LAYOUTS[id].image)

static func layout(id: String = DEFAULT_LAYOUT) -> Dictionary:
	if is_event_layout(id): return _event_companion_layout(id)
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

static func _event_companion_layout(id: String) -> Dictionary:
	var areas: Array[Dictionary] = []
	match id:
		"ca-2026-27-take-and-hold-mirror-a-v1":
			areas = [
				_proxy_area("Northwest ruin", "dense", Rect2(-29, 16, 7, 5), [Rect2(-29, 16, 5, 0.35), Rect2(-29, 16, 0.35, 4)]),
				_proxy_area("Southwest ruin", "dense", Rect2(-29, -21, 7, 5), [Rect2(-29, -16.35, 5, 0.35), Rect2(-22.35, -20, 0.35, 4)]),
				_proxy_area("Northeast ruin", "dense", Rect2(22, 16, 7, 5), [Rect2(24, 16, 5, 0.35), Rect2(28.65, 16, 0.35, 4)]),
				_proxy_area("Southeast ruin", "dense", Rect2(22, -21, 7, 5), [Rect2(24, -16.35, 5, 0.35), Rect2(22, -20, 0.35, 4)]),
				_proxy_area("Northwest barricade", "light", Rect2(-29, -4, 6, 2), [Rect2(-29, -3.1, 6, 0.2)]),
				_proxy_area("Southeast barricade", "light", Rect2(23, 2, 6, 2), [Rect2(23, 2.9, 6, 0.2)])]
		"ca-2026-27-take-and-hold-mirror-b-v1":
			areas = [
				_proxy_area("Northwest ruin", "dense", Rect2(-29, 16, 7, 5), [Rect2(-24.35, 16, 0.35, 4), Rect2(-29, 20.65, 5, 0.35)]),
				_proxy_area("Southwest ruin", "dense", Rect2(-29, -21, 7, 5), [Rect2(-29, -20.65, 5, 0.35), Rect2(-22.35, -20, 0.35, 4)]),
				_proxy_area("Northeast ruin", "dense", Rect2(22, 16, 7, 5), [Rect2(22, 16, 5, 0.35), Rect2(26.65, 16, 0.35, 4)]),
				_proxy_area("Southeast ruin", "dense", Rect2(22, -21, 7, 5), [Rect2(28.65, -20, 0.35, 4), Rect2(24, -16.35, 5, 0.35)]),
				_proxy_area("West barricade", "light", Rect2(-29, -3, 6, 2), [Rect2(-29, -2.1, 6, 0.2)]),
				_proxy_area("East barricade", "light", Rect2(23, 5, 6, 2), [Rect2(23, 5.9, 6, 0.2)])]
		"ca-2026-27-take-and-hold-mirror-c-v1":
			areas = [
				_proxy_area("Northwest ruin", "dense", Rect2(-29, 16, 7, 5), [Rect2(-29, 16, 0.35, 4), Rect2(-28.65, 20.65, 5, 0.35)]),
				_proxy_area("Southwest ruin", "dense", Rect2(-29, -21, 7, 5), [Rect2(-29, -20.65, 5, 0.35), Rect2(-22.35, -20, 0.35, 4)]),
				_proxy_area("Northeast ruin", "dense", Rect2(22, 16, 7, 5), [Rect2(28.65, 16, 0.35, 4), Rect2(22, 16, 5, 0.35)]),
				_proxy_area("Southeast ruin", "dense", Rect2(22, -21, 7, 5), [Rect2(22, -20, 0.35, 4), Rect2(24, -16.35, 5, 0.35)]),
				_proxy_area("Northwest barricade", "light", Rect2(-29, -3, 6, 2), [Rect2(-29, -2.1, 6, 0.2)]),
				_proxy_area("Northeast barricade", "light", Rect2(23, -3, 6, 2), [Rect2(23, -2.1, 6, 0.2)])]
	return {"id": id, "areas": areas}

static func _proxy_area(area_name: String, category: String, bounds: Rect2, walls: Array[Rect2]) -> Dictionary:
	var features: Array[Dictionary] = []
	var height := 4.0 if category == "dense" else 1.0
	for wall: Rect2 in walls:
		features.append({"bounds": wall, "height": height, "blocks_end": true})
	return {"name": area_name, "category": category, "bounds": bounds, "features": features}

static func areas(state: Dictionary) -> Array:
	if state.has("terrain"): return state.terrain.areas
	return layout("legacy-solid-v1").areas

static func legacy(state: Dictionary) -> bool:
	return state.get("terrain", {}).get("id", "legacy-solid-v1") == "legacy-solid-v1"

static func has_keyword(model: Dictionary, keywords: Array[String]) -> bool:
	for keyword: String in model.get("keywords", []):
		if keyword.to_lower() in keywords: return true
	return false

static func mobile_unit(state: Dictionary, model: int) -> bool:
	if has_keyword(state.units[model], ["mobile"]): return true
	var squad: int = state.units[model].squad
	var mobile: Dictionary = state.get("detachment_stratagems", {}).get("mobile", {}).get(squad, {})
	if mobile.get("phase_key", "") == "%d:%s" % [state.get("turn", -1), state.get("phase", "")]: return true
	for member: int in _alive(state, squad):
		if str(state.units[member].get("definition_id", "")).ends_with(":suboden-khan"): return true
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
	var passes_dense := has_keyword(state.units[model], ["infantry", "beasts", "swarm"]) or mobile_unit(state, model)
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
		if state.units[id].squad == squad and state.units[id].wounds > 0 and state.units[id].get("on_battlefield", true): ids.append(id)
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
	var detection := Detection.detection_range(state, target, grounded)
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
	if Detection.stealth(state, squad) or Smoke.cover(state, observer, squad): return true
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

static func visible_features(state: Dictionary, observer: int) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if not state.units.has(observer) or state.units[observer].wounds <= 0: return result
	var terrain_areas := areas(state)
	for area_index in range(terrain_areas.size()):
		var area: Dictionary = terrain_areas[area_index]
		for feature_index in range(area.get("features", []).size()):
			if _feature_visible(state, observer, area_index, feature_index):
				result.append({"area": area_index, "feature": feature_index, "label": "%s · section %d" % [str(area.get("name", "Terrain")), feature_index + 1]})
	return result

static func _feature_visible(state: Dictionary, observer: int, area_index: int, feature_index: int) -> bool:
	var terrain_areas := areas(state)
	if area_index < 0 or area_index >= terrain_areas.size(): return false
	var area: Dictionary = terrain_areas[area_index]
	var features: Array = area.get("features", [])
	if feature_index < 0 or feature_index >= features.size(): return false
	var rect: Rect2 = features[feature_index].bounds
	var center := rect.get_center()
	var samples: Array[Vector2] = [center, rect.position, Vector2(rect.end.x, rect.position.y), rect.end, Vector2(rect.position.x, rect.end.y),
		Vector2(center.x, rect.position.y), Vector2(rect.end.x, center.y), Vector2(center.x, rect.end.y), Vector2(rect.position.x, center.y)]
	var origin: Vector2 = state.units[observer].position
	for target: Vector2 in samples:
		var blocked := false
		for blocker_index in range(terrain_areas.size()):
			var blocker: Dictionary = terrain_areas[blocker_index]
			if blocker_index != area_index and blocker.category in ["light", "dense"] and not within(state.units[observer], blocker.bounds) and segment_hits(origin, target, blocker.bounds.grow(SIGHT_RADIUS)):
				blocked = true
				break
			for other_feature_index in range(blocker.get("features", []).size()):
				if blocker_index == area_index and other_feature_index == feature_index: continue
				var other: Dictionary = blocker.features[other_feature_index]
				if float(other.get("height", 0.0)) < float(state.units[observer].get("sight_height", 1.3)): continue
				if segment_hits(origin, target, other.bounds.grow(SIGHT_RADIUS)):
					blocked = true
					break
			if blocked: break
		if not blocked: return true
	return false
