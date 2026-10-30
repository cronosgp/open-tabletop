extends RefCounted
## Certificates of impossibility, not a sampled route search. Every relaxation
## enlarges legal movement/placement space; only an empty relaxation waives a rule.
const Board = preload("res://scripts/rules.gd")
const Geometry = preload("res://scripts/edition_11/contact_movement.gd")
const Terrain = preload("res://scripts/edition_11/terrain.gd")
const AircraftRules = preload("res://scripts/edition_11/aircraft_rules.gd")
const PADDING := 0.004
const CERTIFICATE_MARGIN := 0.02
const BOX_LIMIT := 1024
const MIN_BOX_WIDTH := 0.02
const MOVEMENT_EPSILON := 0.001
const SURGE_BLOCKER_SLICES := 16
const SURGE_BLOCKER_SPAN_FRACTION := 0.99

static func _inside(point: Vector2, rect: Rect2) -> bool:
	return point.x > rect.position.x and point.x < rect.end.x and point.y > rect.position.y and point.y < rect.end.y

static func _blocked(point: Vector2, obstacles: Array[Rect2]) -> bool:
	for rect: Rect2 in obstacles:
		if _inside(point, rect): return true
	return false

static func _enters(first: Vector2, last: Vector2, rect: Rect2) -> bool:
	var lower := 0.0
	var upper := 1.0
	for axis in range(2):
		var delta: float = last[axis] - first[axis]
		if absf(delta) < 0.0000001:
			if first[axis] <= rect.position[axis] or first[axis] >= rect.end[axis]: return false
		else:
			var a: float = (rect.position[axis] - first[axis]) / delta
			var b: float = (rect.end[axis] - first[axis]) / delta
			lower = maxf(lower, minf(a, b))
			upper = minf(upper, maxf(a, b))
	return lower < upper - 0.0000001

static func _visible(first: Vector2, last: Vector2, obstacles: Array[Rect2]) -> bool:
	for rect: Rect2 in obstacles:
		if _enters(first, last, rect): return false
	return true

static func _corners(rect: Rect2) -> Array[Vector2]:
	return [rect.position, Vector2(rect.end.x, rect.position.y), rect.end, Vector2(rect.position.x, rect.end.y)]

static func _rect_intersections(first: Rect2, second: Rect2) -> Array[Vector2]:
	var points: Array[Vector2] = []
	# Edge-only contact points are already rectangle corners; skip those pairs.
	if (first.end.x <= second.position.x or second.end.x <= first.position.x
		or first.end.y <= second.position.y or second.end.y <= first.position.y):
		return points
	var first_contains_second := (
		first.position.x <= second.position.x and first.position.y <= second.position.y
		and first.end.x >= second.end.x and first.end.y >= second.end.y)
	var second_contains_first := (
		second.position.x <= first.position.x and second.position.y <= first.position.y
		and second.end.x >= first.end.x and second.end.y >= first.end.y)
	if first_contains_second or second_contains_first: return points
	for x in [first.position.x, first.end.x]:
		for y in [second.position.y, second.end.y]:
			if x >= second.position.x and x <= second.end.x and y >= first.position.y and y <= first.end.y:
				points.append(Vector2(x, y))
	for x in [second.position.x, second.end.x]:
		for y in [first.position.y, first.end.y]:
			if x >= first.position.x and x <= first.end.x and y >= second.position.y and y <= second.end.y:
				points.append(Vector2(x, y))
	return points

static func _obstacle_vertices(obstacles: Array[Rect2]) -> Array[Vector2]:
	var vertices: Array[Vector2] = []
	for rect: Rect2 in obstacles:
		for point: Vector2 in _corners(rect):
			if _blocked(point, obstacles): continue
			var found := false
			for existing: Vector2 in vertices:
				if existing.distance_to(point) <= 0.000001:
					found = true
					break
			if not found: vertices.append(point)
	for first in range(obstacles.size()):
		for second in range(first + 1, obstacles.size()):
			for point: Vector2 in _rect_intersections(obstacles[first], obstacles[second]):
				if _blocked(point, obstacles): continue
				var found := false
				for existing: Vector2 in vertices:
					if existing.distance_to(point) <= 0.000001:
						found = true
						break
				if not found: vertices.append(point)
	return vertices

static func _rect_distance(first: Rect2, second: Rect2) -> float:
	return Vector2(maxf(0, maxf(first.position.x - second.end.x, second.position.x - first.end.x)), maxf(0, maxf(first.position.y - second.end.y, second.position.y - first.end.y))).length()

static func _point_distance(point: Vector2, rect: Rect2) -> float:
	return point.distance_to(point.clamp(rect.position, rect.end))

static func _route_relevant_obstacles(origin: Vector2, goal: Rect2, obstacles: Array[Rect2], maximum_distance: float) -> Array[Rect2]:
	var relevant: Array[Rect2] = []
	if not origin.is_finite() or not goal.position.is_finite() or not goal.size.is_finite() \
		or goal.size.x < 0.0 or goal.size.y < 0.0 \
		or is_nan(maximum_distance) or is_inf(maximum_distance):
		return obstacles.duplicate()
	for obstacle: Rect2 in obstacles:
		if not obstacle.position.is_finite() or not obstacle.size.is_finite() \
			or obstacle.size.x < 0.0 or obstacle.size.y < 0.0:
			relevant.append(obstacle)
			continue
		# Any route that touches this rectangle costs at least the distance from
		# the origin to it plus its distance to the goal region.
		var route_lower_bound := _point_distance(origin, obstacle) + _rect_distance(obstacle, goal)
		if is_nan(route_lower_bound) or is_inf(route_lower_bound) \
			or route_lower_bound <= maximum_distance + 0.000001:
			relevant.append(obstacle)
	return relevant

static func _intersection(first: Rect2, second: Rect2) -> Rect2:
	var start := first.position.max(second.position)
	var end := first.end.min(second.end)
	return Rect2(start, end - start)

static func _empty(rect: Rect2) -> bool:
	return rect.size.x < 0 or rect.size.y < 0

static func _inscribed_circle_rectangles(center: Vector2, radius: float, slices: int = SURGE_BLOCKER_SLICES) -> Array[Rect2]:
	var rectangles: Array[Rect2] = []
	if not center.is_finite() or is_nan(radius) or is_inf(radius) or radius <= 0.0 or slices <= 0: return rectangles
	# A short stack of rectangles follows the circle more closely than one
	# inscribed square. Every far corner is still inside the disk.
	var span := radius * SURGE_BLOCKER_SPAN_FRACTION
	var width := 2.0 * span / float(slices)
	for slice in range(slices):
		var left := -span + width * float(slice)
		var right := left + width
		var far_x := maxf(absf(left), absf(right))
		var half_height := sqrt(maxf(0.0, radius * radius - far_x * far_x))
		if half_height <= 0.0: continue
		rectangles.append(Rect2(center + Vector2(left, -half_height), Vector2(width, half_height * 2.0)))
	return rectangles

static func _obstacles(radius: float, state: Dictionary = {}, model: int = -1, include_surge_blockers: bool = false) -> Array[Rect2]:
	var obstacles: Array[Rect2] = []
	# Each expanded rectangle is INSIDE the rounded Minkowski sum of the
	# actual rectangle and circular base. Growing both axes by the whole
	# radius would overestimate corner obstructions and be unsafe as proof.
	var features: Array = Board.TERRAIN
	if model != -1:
		# A FLY model may use a supported elevated surface to traverse a dense
		# feature without Take to the Skies. Keep terrain out of this certificate
		# relaxation; the live path validator still enforces wall access and the
		# vertical movement cost for each staged segment.
		features = [] if Terrain.has_keyword(state.units[model], ["fly"]) else Terrain.movement_obstacles(state, model)
	for rect: Rect2 in features:
		for angle in [0.0, PI / 6.0, PI / 4.0, PI / 3.0, PI / 2.0]:
			var extent := Vector2(cos(angle), sin(angle)) * maxf(0.0, radius - PADDING)
			obstacles.append(Rect2(rect.position - extent, rect.size + extent * 2.0))
	if include_surge_blockers and model != -1 and state.get("pending_contact", {}).get("kind", "") == "surge":
		var mover: Dictionary = state.units[model]
		var move: Dictionary = state.pending_contact
		var move_origins: Dictionary = move.get("origins", {})
		var locked: Dictionary = move.get("locked", {})
		var move_type := str(move.get("kind", "surge"))
		var mover_elevation := float(move.get("origin_elevations", {}).get(model, mover.get("elevation", 0.0)))
		for other_id: int in state.get("units", {}):
			if other_id == model or (move_origins.has(other_id) and not locked.has(other_id)): continue
			var other: Dictionary = state.units[other_id]
			if int(other.get("wounds", 0)) <= 0 or not other.get("on_battlefield", true): continue
			if AircraftRules.is_aircraft(state, int(other.get("squad", -1))): continue
			var other_is_enemy := int(other.get("owner", -1)) != int(mover.get("owner", -2))
			if not other_is_enemy and not Geometry.monster_vehicle_move_blocks_large_model(mover, other, move_type): continue
			if other_is_enemy and Geometry.monster_vehicle_can_pass_enemy_model(mover, other, move_type): continue
			var other_elevation := float(move.get("origin_elevations", {}).get(other_id, other.get("elevation", 0.0)))
			if absf(other_elevation - mover_elevation) > MOVEMENT_EPSILON: continue
			var blocked_radius := maxf(0.0, radius + float(other.get("radius", 0.0)) - MOVEMENT_EPSILON - PADDING)
			# These rectangles lie wholly inside the true blocked disk, so routing
			# around their union can only underestimate the legal route length.
			obstacles.append_array(_inscribed_circle_rectangles(Vector2(other.position), blocked_radius))
	return obstacles

static func _append_unique_point(points: Array[Vector2], point: Vector2, seen: Dictionary) -> void:
	if seen.has(point): return
	seen[point] = true
	points.append(point)

static func _goal_points(goal: Rect2, obstacles: Array[Rect2], vertices: Array[Vector2]) -> Array[Vector2]:
	var goals: Array[Vector2] = []
	var seen: Dictionary = {}
	for corner: Vector2 in _corners(goal): _append_unique_point(goals, corner, seen)
	for vertex: Vector2 in vertices: _append_unique_point(goals, vertex.clamp(goal.position, goal.end), seen)
	# Clipped obstacle boundaries can form additional goal-region vertices.
	for rect: Rect2 in obstacles:
		for x in [rect.position.x, rect.end.x]:
			for y in [goal.position.y, goal.end.y]:
				if x >= goal.position.x and x <= goal.end.x and y >= rect.position.y and y <= rect.end.y:
					_append_unique_point(goals, Vector2(x, y), seen)
		for y in [rect.position.y, rect.end.y]:
			for x in [goal.position.x, goal.end.x]:
				if y >= goal.position.y and y <= goal.end.y and x >= rect.position.x and x <= rect.end.x:
					_append_unique_point(goals, Vector2(x, y), seen)
	return goals

static func _terrain_lower_bound_with_obstacles(origin: Vector2, goal: Rect2, obstacles: Array[Rect2], fixed_vertices: Array[Vector2] = [], maximum_distance: float = INF) -> float:
	# The goal box encloses the target disk. Callers provide inscribed obstacles
	# and omit board bounds, keeping this relaxed-geometry distance a lower bound.
	if _blocked(origin, obstacles): return 0.0 # Invalid/unsupported origin: no certificate.
	var direct_endpoint := origin.clamp(goal.position, goal.end)
	var direct_distance := origin.distance_to(direct_endpoint)
	if not is_nan(maximum_distance) and not is_inf(maximum_distance) and direct_distance > maximum_distance + 0.000001:
		# Obstacles can only lengthen this relaxed straight-line lower bound. If
		# it already exceeds the relevant movement allowance, graph search cannot
		# change the caller's proof decision.
		return direct_distance
	if not _blocked(direct_endpoint, obstacles) and _visible(origin, direct_endpoint, obstacles):
		return direct_distance
	var route_obstacles := obstacles
	var route_vertices := fixed_vertices
	if not is_nan(maximum_distance) and not is_inf(maximum_distance):
		var relevant_obstacles := _route_relevant_obstacles(origin, goal, obstacles, maximum_distance)
		if relevant_obstacles.size() < obstacles.size():
			route_obstacles = relevant_obstacles
			# Rebuild the complete visibility vertices for the retained obstacle
			# union. Reusing the original list could omit a newly exposed corner.
			route_vertices = _obstacle_vertices(route_obstacles)
	var vertices: Array[Vector2] = [origin]
	var obstacle_points := route_vertices if not route_vertices.is_empty() else _obstacle_vertices(route_obstacles)
	vertices.append_array(obstacle_points)
	var goals := _goal_points(goal, route_obstacles, vertices)
	for point: Vector2 in goals:
		if not _blocked(point, route_obstacles): vertices.append(point)
	var distances: Array[float] = []
	var visited: Dictionary = {}
	for index in range(vertices.size()): distances.append(0.0 if index == 0 else INF)
	# Distance to the goal region is a consistent A* heuristic for this graph;
	# the first popped goal therefore retains the exact relaxed shortest path.
	var open: Array[Array] = []
	_route_heap_push(open, [ _point_distance(origin, goal), 0.0, 0 ])
	while not open.is_empty():
		var entry: Array = _route_heap_pop(open)
		var current := int(entry[2])
		var shortest := float(entry[1])
		if visited.has(current) or shortest > distances[current] + 0.0000001: continue
		var current_estimate := float(entry[0])
		if not is_nan(maximum_distance) and not is_inf(maximum_distance) \
			and current_estimate > maximum_distance + 0.000001:
			return current_estimate
		if _point_distance(vertices[current], goal) < 0.000001: return shortest
		visited[current] = true
		for other in range(vertices.size()):
			if visited.has(other): continue
			var proposed: float = shortest + vertices[current].distance_to(vertices[other])
			if proposed < distances[other] and _visible(vertices[current], vertices[other], route_obstacles):
				distances[other] = proposed
				var estimate := proposed + _point_distance(vertices[other], goal)
				_route_heap_push(open, [estimate, proposed, other])
	return INF

static func _route_heap_less(first: Array, second: Array) -> bool:
	if float(first[0]) != float(second[0]): return float(first[0]) < float(second[0])
	if float(first[1]) != float(second[1]): return float(first[1]) < float(second[1])
	return int(first[2]) < int(second[2])

static func _route_heap_push(heap: Array[Array], entry: Array) -> void:
	var child := heap.size()
	heap.append(entry)
	while child > 0:
		var parent := (child - 1) / 2
		if not _route_heap_less(entry, heap[parent]): break
		heap[child] = heap[parent]
		child = parent
	heap[child] = entry

static func _route_heap_pop(heap: Array[Array]) -> Array:
	var first: Array = heap[0]
	var last: Array = heap.pop_back()
	if heap.is_empty(): return first
	var parent := 0
	while true:
		var child := parent * 2 + 1
		if child >= heap.size(): break
		if child + 1 < heap.size() and _route_heap_less(heap[child + 1], heap[child]): child += 1
		if not _route_heap_less(heap[child], last): break
		heap[parent] = heap[child]
		parent = child
	heap[parent] = last
	return first

static func terrain_lower_bound(origin: Vector2, radius: float, goal: Rect2, state: Dictionary = {}, model: int = -1) -> float:
	return _terrain_lower_bound_with_obstacles(origin, goal, _obstacles(radius, state, model))

static func _goal_disks(state: Dictionary, model: int, targets: Array[int], gap: float) -> Array[Dictionary]:
	var disks: Array[Dictionary] = []
	for target: int in targets:
		for enemy: int in Geometry.alive(state, target):
			disks.append({"center": state.units[enemy].position, "radius": float(state.units[model].radius) + float(state.units[enemy].radius) + gap + PADDING, "target_elevation": float(state.units[enemy].get("elevation", 0.0))})
	return disks

static func _minimum_vertical_travel(state: Dictionary, move: Dictionary, model: int, goal: Dictionary) -> float:
	if not goal.has("target_elevation") or not state.get("units", {}).has(model) or Terrain.ignores_vertical_movement(state, model): return 0.0
	var target_elevation := float(goal.target_elevation)
	var origin_elevation := float(move.get("origin_elevations", {}).get(model, state.units[model].get("elevation", 0.0)))
	if not is_finite(target_elevation) or not is_finite(origin_elevation): return 0.0
	return maxf(0.0, absf(target_elevation - origin_elevation) - Geometry.MAX_ENGAGEMENT_VERTICAL_DISTANCE)

static func _intersect_elevation_domains(domains: Array[Vector2], allowed: Array[Vector2]) -> Array[Vector2]:
	var intersections: Array[Vector2] = []
	for domain: Vector2 in domains:
		for interval: Vector2 in allowed:
			var lower := maxf(domain.x, interval.x)
			var upper := minf(domain.y, interval.y)
			if lower > upper: continue
			var duplicate := false
			for existing: Vector2 in intersections:
				if absf(existing.x - lower) <= 0.000001 and absf(existing.y - upper) <= 0.000001:
					duplicate = true
					break
			if not duplicate: intersections.append(Vector2(lower, upper))
	return intersections

static func _surface_domain_index(state: Dictionary, model: int, move: Dictionary, surfaces: Array[Dictionary]) -> Dictionary:
	var result := {"unknown": false, "surfaces": [], "ground_access_zones": []}
	if not state.get("units", {}).has(model):
		result.unknown = true
		return result
	var model_data: Dictionary = state.units[model]
	var radius := float(model_data.get("radius", 0.0))
	var origin_elevation := float(move.get("origin_elevations", {}).get(model, model_data.get("elevation", 0.0)))
	var origin_position: Vector2 = move.get("origins", {}).get(model, model_data.get("position", Vector2.ZERO))
	if not is_finite(radius) or not is_finite(origin_elevation) or not origin_position.is_finite():
		result.unknown = true
		return result
	var origin_supported := absf(origin_elevation) <= Terrain.EPSILON
	var eligible: Array[Dictionary] = []
	var eligible_access_zones: Array[Rect2] = []
	var terrain_areas := Terrain.areas(state)
	for surface: Dictionary in surfaces:
		var raw_elevation: Variant = surface.get("elevation", null)
		var bounds: Rect2 = surface.get("bounds", Rect2())
		if raw_elevation == null or not bounds.position.is_finite() or not bounds.size.is_finite() \
			or bounds.size.x < 0.0 or bounds.size.y < 0.0:
			result.unknown = true
			return result
		var elevation := float(raw_elevation)
		if not is_finite(elevation):
			result.unknown = true
			return result
		if elevation < 0.0 or not Terrain.can_end_on_surface(model_data, surface): continue
		var inner := Rect2(bounds.position + Vector2.ONE * radius, bounds.size - Vector2.ONE * radius * 2.0)
		if inner.size.x < 0.0 or inner.size.y < 0.0: continue
		var raw_access_features: Variant = surface.get("access_features", [])
		if not raw_access_features is Array:
			result.unknown = true
			return result
		var access_zones: Array[Rect2] = []
		if not raw_access_features.is_empty():
			var area_index := int(surface.get("area_index", -1))
			if area_index < 0 or area_index >= terrain_areas.size():
				result.unknown = true
				return result
			var raw_features: Variant = terrain_areas[area_index].get("features", [])
			if not raw_features is Array:
				result.unknown = true
				return result
			for feature_index_value: Variant in raw_access_features:
				var feature_index := int(feature_index_value)
				if feature_index < 0 or feature_index >= raw_features.size(): continue
				var feature_value: Variant = raw_features[feature_index]
				if not feature_value is Dictionary:
					result.unknown = true
					return result
				var raw_height: Variant = feature_value.get("height", 0.0)
				var feature_height := float(raw_height)
				var raw_feature_bounds: Variant = feature_value.get("bounds", null)
				if not raw_feature_bounds is Rect2:
					result.unknown = true
					return result
				var feature_bounds: Rect2 = raw_feature_bounds
				if not is_finite(feature_height) or not feature_bounds.position.is_finite() \
					or not feature_bounds.size.is_finite() or feature_bounds.size.x < 0.0 or feature_bounds.size.y < 0.0:
					result.unknown = true
					return result
				if feature_height <= 0.0: continue
				access_zones.append(feature_bounds.grow(radius + 0.5 + Terrain.EPSILON))
		var contains_origin := absf(elevation - origin_elevation) <= Terrain.EPSILON \
			and origin_position.x >= inner.position.x - Terrain.EPSILON and origin_position.x <= inner.end.x + Terrain.EPSILON \
			and origin_position.y >= inner.position.y - Terrain.EPSILON and origin_position.y <= inner.end.y + Terrain.EPSILON
		if contains_origin:
			origin_supported = true
		eligible_access_zones.append_array(access_zones)
		eligible.append({"elevation": elevation, "bounds": inner, "access_zones": access_zones,
			"contains_origin": contains_origin})
	if not origin_supported:
		# Invalid starting geometry must not become an impossibility proof.
		result.unknown = true
		return result
	result.surfaces = eligible
	result.ground_access_zones = eligible_access_zones
	return result

static func _access_zone_goal_lower_bound_fits(zones: Array, origin: Vector2, origin_elevation: float, target_elevation: float, goal: Rect2, allowance: float) -> bool:
	if not origin.is_finite() or not is_finite(origin_elevation) or not is_finite(target_elevation) \
		or not is_finite(allowance) or allowance < 0.0 \
		or not goal.position.is_finite() or not goal.size.is_finite() or goal.size.x < 0.0 or goal.size.y < 0.0:
		return true
	var vertical_lower_bound := absf(target_elevation - origin_elevation)
	for zone_value: Variant in zones:
		if not zone_value is Rect2: return true
		var zone: Rect2 = zone_value
		if not zone.position.is_finite() or not zone.size.is_finite() or zone.size.x < 0.0 or zone.size.y < 0.0:
			return true
		# A legal route into the floor must pass through its access zone and then
		# reach some point in the endpoint box. Independent minima stay a lower
		# bound while strengthening cases where the zone lies off the direct path.
		var zone_goal_distance := _rect_distance(zone, goal)
		if not is_finite(zone_goal_distance): return true
		var route_lower_bound := _point_distance(origin, zone) + zone_goal_distance
		var lower_bound := route_lower_bound + vertical_lower_bound
		if not is_finite(lower_bound): return true
		if lower_bound <= allowance: return true
	return false

static func _reachable_elevation_intervals(state: Dictionary, move: Dictionary, model: int, domain: Rect2, surface_domain: Dictionary, focus_goal: Dictionary = {}, retained_goals: Array = []) -> Array[Vector2]:
	var intervals: Array[Vector2] = []
	if not state.get("units", {}).has(model) or Terrain.ignores_vertical_movement(state, model):
		intervals.append(Vector2(-INF, INF))
		return intervals
	var origin_elevation := float(move.get("origin_elevations", {}).get(model, state.units[model].get("elevation", 0.0)))
	var maximum := float(move.get("maximum", INF))
	if not is_finite(origin_elevation) or not is_finite(maximum):
		intervals.append(Vector2(-INF, INF))
		return intervals
	var allowance := 0.0 if move.get("locked", {}).has(model) else maxf(0.0, maximum)
	allowance += CERTIFICATE_MARGIN + PADDING
	var travel_interval := Vector2(origin_elevation - allowance, origin_elevation + allowance)
	var model_data: Dictionary = state.units[model]
	if not domain.position.is_finite() or not domain.size.is_finite() or domain.size.x < 0.0 or domain.size.y < 0.0 \
		or surface_domain.get("unknown", true):
		intervals.append(travel_interval)
		return _clip_elevation_domains(intervals, focus_goal, retained_goals)
	# Legal endpoints use ground or a listed, eligible upper surface. Keep a
	# surface when its base-fit bounds overlap the relaxed XY box. Access lower
	# bounds account for travel to the required zone and from it to that endpoint
	# box; blockers and the rest of the route remain relaxed.
	var candidate_heights: Array[float] = []
	var origin_position: Vector2 = move.get("origins", {}).get(model, model_data.get("position", Vector2.ZERO))
	var ground_accessible := true
	if origin_elevation > Terrain.EPSILON:
		# A route can descend through a lower intermediate floor whose access is
		# closer than the starting floor's access. Any elevated surface access is
		# therefore a safe relaxation for the required path into ground.
		ground_accessible = _access_zone_goal_lower_bound_fits(
			surface_domain.get("ground_access_zones", []), origin_position, origin_elevation, 0.0, domain, allowance)
	if ground_accessible: candidate_heights.append(0.0)
	for surface: Dictionary in surface_domain.get("surfaces", []):
		var elevation := float(surface.elevation)
		if absf(elevation - origin_elevation) > allowance + PADDING: continue
		var inner: Rect2 = surface.bounds
		if inner.end.x < domain.position.x - PADDING or domain.end.x < inner.position.x - PADDING \
			or inner.end.y < domain.position.y - PADDING or domain.end.y < inner.position.y - PADDING: continue
		# Arriving on any non-ground floor uses that destination floor's listed
		# access feature, including descents from a higher intermediate surface.
		if elevation > Terrain.EPSILON and absf(elevation - origin_elevation) > Terrain.EPSILON \
			and not _access_zone_goal_lower_bound_fits(
				surface.get("access_zones", []), origin_position, origin_elevation, elevation, domain, allowance):
			continue
		var duplicate_height := false
		for known_height: float in candidate_heights:
			if absf(known_height - elevation) <= 0.000001:
				duplicate_height = true
				break
		if not duplicate_height: candidate_heights.append(elevation)
	for height: float in candidate_heights:
		var height_interval := Vector2(maxf(travel_interval.x, height - PADDING), minf(travel_interval.y, height + PADDING))
		if height_interval.x <= height_interval.y: intervals.append(height_interval)
	return _clip_elevation_domains(intervals, focus_goal, retained_goals)

static func _clip_elevation_domains(domains: Array[Vector2], focus_goal: Dictionary, retained_goals: Array) -> Array[Vector2]:
	var result := domains
	if focus_goal.has("target_elevation"):
		var target_elevation := float(focus_goal.target_elevation)
		if not is_finite(target_elevation): return domains
		var band := Geometry.MAX_ENGAGEMENT_VERTICAL_DISTANCE + PADDING
		result = _intersect_elevation_domains(result, [Vector2(target_elevation - band, target_elevation + band)])
	# For each retained enemy unit, a model may engage any living enemy model in
	# that unit. Intersect with the union of those height bands; unknown heights
	# keep that constraint open, matching the previous conservative envelope.
	for disks: Array[Dictionary] in retained_goals:
		if disks.is_empty(): continue
		var target_bands: Array[Vector2] = []
		var valid_heights := true
		for disk: Dictionary in disks:
			if not disk.has("target_elevation"):
				valid_heights = false
				break
			var target_elevation := float(disk.target_elevation)
			if not is_finite(target_elevation):
				valid_heights = false
				break
			var band := Geometry.MAX_ENGAGEMENT_VERTICAL_DISTANCE + PADDING
			target_bands.append(Vector2(target_elevation - band, target_elevation + band))
		if valid_heights: result = _intersect_elevation_domains(result, target_bands)
	return result

static func _vertical_domain_gap(first: Array[Vector2], second: Array[Vector2]) -> float:
	if first.is_empty() or second.is_empty(): return INF
	var minimum_gap := INF
	for first_interval: Vector2 in first:
		for second_interval: Vector2 in second:
			if not first_interval.is_finite() or not second_interval.is_finite(): return 0.0
			if first_interval.x > first_interval.y or second_interval.x > second_interval.y: continue
			var gap := 0.0
			if first_interval.y < second_interval.x: gap = second_interval.x - first_interval.y
			elif second_interval.y < first_interval.x: gap = first_interval.x - second_interval.y
			minimum_gap = minf(minimum_gap, gap)
	return minimum_gap

static func _disk_box(disk: Dictionary) -> Rect2:
	return Rect2(disk.center - Vector2.ONE * disk.radius, Vector2.ONE * disk.radius * 2)

static func _goal_box(goal: Dictionary) -> Rect2:
	if goal.get("kind", "") == "rounded_rect": return goal.bounds.grow(float(goal.radius))
	return _disk_box(goal)

static func _intersects_disks(box: Rect2, disks: Array[Dictionary]) -> bool:
	for disk: Dictionary in disks:
		if _point_distance(disk.center, box) <= float(disk.radius): return true
	return false

static func _intersects_goals(box: Rect2, goals: Array[Dictionary]) -> bool:
	for goal: Dictionary in goals:
		if goal.get("kind", "") == "rounded_rect":
			if _rect_distance(box, goal.bounds) <= float(goal.radius): return true
		elif _point_distance(goal.center, box) <= float(goal.radius):
			return true
	return false

static func _constraint_distance(first: Dictionary, second: Dictionary) -> float:
	var first_is_rounded_rect: bool = first.get("kind", "") == "rounded_rect"
	var second_is_rounded_rect: bool = second.get("kind", "") == "rounded_rect"
	var first_radius := float(first.get("radius", 0.0))
	var second_radius := float(second.get("radius", 0.0))
	var first_bounds: Rect2 = first.get("bounds", Rect2())
	var second_bounds: Rect2 = second.get("bounds", Rect2())
	var first_center := Vector2(first.get("center", Vector2.ZERO))
	var second_center := Vector2(second.get("center", Vector2.ZERO))
	if is_nan(first_radius) or is_inf(first_radius) or first_radius < 0.0: return 0.0
	if is_nan(second_radius) or is_inf(second_radius) or second_radius < 0.0: return 0.0
	if first_is_rounded_rect and (not first_bounds.position.is_finite() or not first_bounds.size.is_finite() or first_bounds.size.x < 0.0 or first_bounds.size.y < 0.0): return 0.0
	if second_is_rounded_rect and (not second_bounds.position.is_finite() or not second_bounds.size.is_finite() or second_bounds.size.x < 0.0 or second_bounds.size.y < 0.0): return 0.0
	if not first_is_rounded_rect and (not first.has("center") or not first_center.is_finite()): return 0.0
	if not second_is_rounded_rect and (not second.has("center") or not second_center.is_finite()): return 0.0
	if first_is_rounded_rect and second_is_rounded_rect:
		return maxf(0.0, _rect_distance(first_bounds, second_bounds) - first_radius - second_radius)
	if first_is_rounded_rect:
		return maxf(0.0, _point_distance(second_center, first_bounds) - first_radius - second_radius)
	if second_is_rounded_rect:
		return maxf(0.0, _point_distance(first_center, second_bounds) - first_radius - second_radius)
	return maxf(0.0, first_center.distance_to(second_center) - first_radius - second_radius)

static func _constraint_set_distance(first: Array[Dictionary], second: Array[Dictionary]) -> float:
	var distance := INF
	for a: Dictionary in first:
		for b: Dictionary in second:
			distance = minf(distance, _constraint_distance(a, b))
	return distance

static func _pairwise_constraint_bounds(constraint_sets: Array[Array]) -> Array[Array]:
	var pair_bounds: Array[Array] = []
	for first in range(constraint_sets.size()):
		var row: Array[float] = []
		for second in range(constraint_sets.size()):
			var bound := 0.0
			for a: Array[Dictionary] in constraint_sets[first]:
				for b: Array[Dictionary] in constraint_sets[second]:
					bound = maxf(bound, _constraint_set_distance(a, b))
			row.append(bound)
		pair_bounds.append(row)
	return pair_bounds

static func _domain_valid(state: Dictionary, move: Dictionary, ids: Array[int], boxes: Array[Rect2], focus_model_id: int, focus_goal: Dictionary, retention: Dictionary, pair_bounds: Array[Array], route_obstacles: Dictionary, route_vertices: Dictionary, surface_domains: Dictionary, route_cache: Dictionary) -> bool:
	var elevation_domains: Array[Array] = []
	for index in range(ids.size()):
		var id: int = ids[index]
		var allowance := 0.0 if move.locked.has(id) else float(move.maximum)
		if _point_distance(move.origins[id], boxes[index]) > allowance + PADDING: return false
		if id == focus_model_id:
			var focus_goals: Array[Dictionary] = [focus_goal]
			if not _intersects_goals(boxes[index], focus_goals): return false
		for disks: Array[Dictionary] in retention[id]:
			if not _intersects_disks(boxes[index], disks): return false
		var elevation_domain := _reachable_elevation_intervals(
			state, move, id, boxes[index], surface_domains[id], focus_goal if id == focus_model_id else {}, retention[id])
		if elevation_domain.is_empty(): return false
		elevation_domains.append(elevation_domain)
		# Inscribed terrain and base obstacles relax legal movement, so their
		# visibility-graph distance remains a lower bound for impossibility proof.
		# Sibling search boxes often reuse the same teammate domain; cache that bound.
		var model_cache: Dictionary = route_cache.get(id, {})
		var box_cache: Dictionary = model_cache.get(boxes[index], {})
		var route_lower_bound: float
		var vertical_floor := _minimum_vertical_travel(state, move, id, focus_goal) if id == focus_model_id else 0.0
		if box_cache.has(vertical_floor):
			route_lower_bound = float(box_cache[vertical_floor])
		else:
			var fixed_vertices: Array[Vector2] = []
			fixed_vertices.assign(route_vertices[id])
			var horizontal_allowance := maxf(0.0, allowance + CERTIFICATE_MARGIN - vertical_floor)
			route_lower_bound = _terrain_lower_bound_with_obstacles(
				move.origins[id], boxes[index], route_obstacles[id], fixed_vertices,
				horizontal_allowance) + vertical_floor
			box_cache[vertical_floor] = route_lower_bound
			model_cache[boxes[index]] = box_cache
			route_cache[id] = model_cache
		if route_lower_bound > allowance + CERTIFICATE_MARGIN: return false
		for rect: Rect2 in route_obstacles[id]:
			if _inside(boxes[index].position, rect) and _inside(boxes[index].end, rect): return false
	# Coherency requires both the diameter bound and one connected graph.
	var graph: Array[Array] = []
	for index in range(ids.size()): graph.append([])
	for first in range(ids.size()):
		for second in range(first + 1, ids.size()):
			var radii: float = float(state.units[ids[first]].radius) + float(state.units[ids[second]].radius)
			var distance := maxf(_rect_distance(boxes[first], boxes[second]), float(pair_bounds[first][second]))
			var vertical_gap := _vertical_domain_gap(elevation_domains[first], elevation_domains[second])
			if vertical_gap > Geometry.MAX_ENGAGEMENT_VERTICAL_DISTANCE + PADDING: return false
			if distance > radii + 9.0 + PADDING: return false
			if distance <= radii + 2.0 + PADDING and vertical_gap <= Geometry.MAX_ENGAGEMENT_VERTICAL_DISTANCE + PADDING:
				graph[first].append(second)
				graph[second].append(first)
	var visited: Dictionary = {0: true}
	var frontier: Array[int] = [0]
	while not frontier.is_empty():
		var current: int = frontier.pop_back()
		for neighbor: int in graph[current]:
			if not visited.has(neighbor):
				visited[neighbor] = true
				frontier.append(neighbor)
	return visited.size() == ids.size()

static func make_certificate_context(state: Dictionary) -> Dictionary:
	var move_value: Variant = state.get("pending_contact", {})
	if not move_value is Dictionary or not move_value.get("origins", {}) is Dictionary: return {}
	var move: Dictionary = move_value
	var ids := Geometry.alive(state, int(move.get("squad", -1)))
	if ids.is_empty(): return {}
	return {
		"prepared_certificate_context": true,
		"geometry_ready": false,
		"squad": int(move.squad),
		"maximum": float(move.get("maximum", 0.0)),
		"kind": str(move.get("kind", "")),
		"ids": ids,
	}

static func _prepare_certificate_context(state: Dictionary, context: Dictionary) -> bool:
	var move: Dictionary = state.get("pending_contact", {})
	var ids := Geometry.alive(state, int(move.get("squad", -1)))
	if ids.is_empty(): return false
	context["ids"] = ids
	context["terrain_obstacles"] = {}
	context["terrain_vertices"] = {}
	context["route_obstacles"] = {}
	context["route_vertices"] = {}
	context["surface_domains"] = {}
	var surface_records := Terrain.surfaces(state)
	for id: int in ids:
		context.surface_domains[id] = _surface_domain_index(state, id, move, surface_records)
		context.terrain_obstacles[id] = _obstacles(float(state.units[id].radius), state, id)
		context.terrain_vertices[id] = _obstacle_vertices(context.terrain_obstacles[id])
		context.route_obstacles[id] = _obstacles(float(state.units[id].radius), state, id, true)
		context.route_vertices[id] = _obstacle_vertices(context.route_obstacles[id])
	context["geometry_ready"] = true
	return true

static func _context_for_state(state: Dictionary, supplied: Dictionary) -> Dictionary:
	var move: Dictionary = state.get("pending_contact", {})
	var matches: bool = supplied.get("prepared_certificate_context", false) \
		and int(supplied.get("squad", -1)) == int(move.get("squad", -2)) \
		and is_equal_approx(float(supplied.get("maximum", NAN)), float(move.get("maximum", 0.0))) \
		and str(supplied.get("kind", "")) == str(move.get("kind", ""))
	var context := supplied if matches else make_certificate_context(state)
	if context.is_empty(): return context
	if not context.get("geometry_ready", false): _prepare_certificate_context(state, context)
	return context

static func certify_impossible(state: Dictionary, model: int, targets: Array[int], gap: float, box_limit: int = BOX_LIMIT, context: Dictionary = {}) -> Dictionary:
	return _certify_impossible_for_goals(state, model, _goal_disks(state, model, targets, gap), box_limit, context)

static func certify_impossible_for_goals(state: Dictionary, model: int, goals: Array[Dictionary], box_limit: int = BOX_LIMIT, context: Dictionary = {}) -> Dictionary:
	return _certify_impossible_for_goals(state, model, goals, box_limit, context)

static func _certify_impossible_for_goals(state: Dictionary, model: int, goals: Array[Dictionary], box_limit: int, context_value: Dictionary = {}) -> Dictionary:
	var move: Dictionary = state.pending_contact
	if not move.origins.has(model) or not state.units.has(model) or state.units[model].wounds <= 0:
		return {"impossible": false, "reason": "invalid_model"}
	if goals.is_empty(): return {"impossible": false, "reason": "no_target"}
	var context := _context_for_state(state, context_value)
	var ids: Array[int] = []
	ids.assign(context.get("ids", []))
	if not ids.has(model): return {"impossible": false, "reason": "invalid_context"}
	var terrain_obstacles: Dictionary = context.get("terrain_obstacles", {})
	var terrain_vertices: Dictionary = context.get("terrain_vertices", {})
	var route_obstacles: Dictionary = context.get("route_obstacles", {})
	var route_vertices: Dictionary = context.get("route_vertices", {})
	var surface_domains: Dictionary = context.get("surface_domains", {})
	var lower_bound := INF
	for goal: Dictionary in goals:
		var fixed_vertices: Array[Vector2] = []
		fixed_vertices.assign(terrain_vertices[model])
		var vertical_floor := _minimum_vertical_travel(state, move, model, goal)
		var horizontal_allowance := maxf(0.0, float(move.maximum) + CERTIFICATE_MARGIN - vertical_floor)
		var route_floor := _terrain_lower_bound_with_obstacles(
			move.origins[model], _goal_box(goal), terrain_obstacles[model], fixed_vertices,
			horizontal_allowance) + vertical_floor
		lower_bound = minf(lower_bound, route_floor)
	if lower_bound > float(move.maximum) + CERTIFICATE_MARGIN:
		return {"impossible": true, "reason": "terrain_route", "lower_bound": lower_bound, "nodes": 0}
	if ids.size() < 2: return {"impossible": false, "reason": "not_certified", "nodes": 0}
	var retention: Dictionary = {}
	var boxes: Array[Rect2] = []
	for id: int in ids:
		var allowance := PADDING if move.locked.has(id) else float(move.maximum) + PADDING
		var box := Rect2(move.origins[id] - Vector2.ONE * allowance, Vector2.ONE * allowance * 2)
		retention[id] = []
		if move.kind != "charge":
			for target: int in move.engaged[id]:
				var disks := _goal_disks(state, id, [target], 2.0)
				retention[id].append(disks)
				var bounds := _disk_box(disks[0])
				for disk: Dictionary in disks: bounds = bounds.merge(_disk_box(disk))
				box = _intersection(box, bounds)
		if _empty(box): return {"impossible": true, "reason": "coherent_placement", "nodes": 0}
		boxes.append(box)
	var stack: Array[Dictionary] = []
	var focus := ids.find(model)
	# Circular constraints are stronger than their bounding boxes, especially
	# where a locked anchor and a retained enemy are diagonally separated.
	var constraint_sets: Array[Array] = []
	for id: int in ids:
		var origin_disk: Array[Dictionary] = [{"center": move.origins[id], "radius": PADDING if move.locked.has(id) else float(move.maximum) + PADDING}]
		var sets: Array = [origin_disk]
		for disks: Array[Dictionary] in retention[id]: sets.append(disks)
		constraint_sets.append(sets)
	for goal: Dictionary in goals:
		var root: Array[Rect2] = boxes.duplicate()
		root[focus] = _intersection(root[focus], _goal_box(goal))
		if _empty(root[focus]): continue
		# Each root represents one target model/region. Keep that region separate
		# in the static coherency bounds instead of weakening every root to the
		# closest member of the full target set.
		var goal_constraints: Array[Array] = []
		for index in range(constraint_sets.size()):
			var model_constraints: Array = constraint_sets[index].duplicate()
			if index == focus:
				var goal_set: Array[Dictionary] = [goal]
				model_constraints.append(goal_set)
			goal_constraints.append(model_constraints)
		stack.append({"boxes": root, "pair_bounds": _pairwise_constraint_bounds(goal_constraints), "focus_goal": goal})
	var nodes := 0
	var route_cache: Dictionary = {}
	while not stack.is_empty():
		if nodes >= box_limit: return {"impossible": false, "reason": "search_limit", "nodes": nodes}
		var search_node: Dictionary = stack.pop_back()
		var domain: Array[Rect2] = []
		domain.assign(search_node.boxes)
		var pair_bounds: Array[Array] = search_node.pair_bounds
		var focus_goal: Dictionary = search_node.focus_goal
		nodes += 1
		if not _domain_valid(state, move, ids, domain, model, focus_goal, retention, pair_bounds, route_obstacles, route_vertices, surface_domains, route_cache): continue
		var widest := MIN_BOX_WIDTH
		var split := -1
		var axis := 0
		for index in range(domain.size()):
			for dimension in range(2):
				if domain[index].size[dimension] > widest:
					widest = domain[index].size[dimension]
					split = index
					axis = dimension
		if split == -1: return {"impossible": false, "reason": "unresolved_boundary", "nodes": nodes}
		var left: Array[Rect2] = domain.duplicate()
		var right: Array[Rect2] = domain.duplicate()
		var half := domain[split].size[axis] / 2.0
		left[split].size[axis] = half
		right[split].position[axis] += half
		right[split].size[axis] -= half
		stack.append({"boxes": left, "pair_bounds": pair_bounds, "focus_goal": focus_goal})
		stack.append({"boxes": right, "pair_bounds": pair_bounds, "focus_goal": focus_goal})
	return {"impossible": true, "reason": "coherent_placement", "nodes": nodes}
