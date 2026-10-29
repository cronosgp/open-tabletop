extends RefCounted
## Validated routes for short movement around supported blockers.
## Ground-level circular routes use tangents/arcs; ContactMovement validates every straight edge.

const Geometry = preload("res://scripts/edition_11/contact_movement.gd")
const Terrain = preload("res://scripts/edition_11/terrain.gd")
const AircraftRules = preload("res://scripts/edition_11/aircraft_rules.gd")
const EPSILON := 0.001
const NODE_CLEARANCE := 0.01
const CIRCLE_SAMPLES := 24
const VISIBILITY_ROUTE_NODE_LIMIT := 256
const VERTICAL_ACCESS_EDGE_SUBDIVISIONS := 32
const ENDPOINT_FILTER_SAMPLES := 32
const ENDPOINT_FILTER_SEARCH_STEPS := 20
const CLEAR_PATH_SEARCH_STEPS := 24
const ENDPOINT_EXCLUSION_MARGIN := 0.004

var _state: Dictionary = {}
var _model_id := -1
var _maximum := 0.0
var _move_type := ""
var _nodes: Array[Vector2] = []
var _base_route_nodes: Array[Vector2] = []
# Preserve bounded graph candidates for route-geometry diagnostics and regressions.
var _visibility_graph_nodes: Array[Vector2] = []
var _distances: Array[float] = []
var _scratch: Dictionary = {}
var _built := false
var _distances_built := false
var _valid := false
var _visibility_graph_overflow := false
var _visibility_graph_ellipse_pruned_nodes := 0
var _visibility_graph_ellipse_pruned_straight_edges := 0
var _visibility_graph_ellipse_pruned_arc_edges := 0
var _fallback_route_expansions := 0
var _fallback_route_edge_checks := 0
var _fallback_route_edge_cache: Dictionary = {}
var _allow_intermediate_surface_search := true
var _visited_surface_ids: Array[String] = []

func _init(state: Dictionary, model_id: int, maximum: float, move_type: String = "surge", allow_intermediate_surface_search: bool = true, visited_surface_ids: Array[String] = []) -> void:
	_state = state
	_model_id = model_id
	_maximum = maxf(0.0, maximum)
	_move_type = move_type
	_allow_intermediate_surface_search = allow_intermediate_surface_search
	_visited_surface_ids = visited_surface_ids.duplicate()
	if not state.get("units", {}).has(model_id): return
	var scratch := state.duplicate(false)
	var units: Dictionary = state.units.duplicate(false)
	units[model_id] = state.units[model_id].duplicate(false)
	scratch["units"] = units
	_scratch = scratch
	_valid = true

## Returns the shortest supported route, or INF if no route fits the move.
## Straight paths remain the fast path; the waypoint graph is built only when needed.
func distance_to(destination: Vector2, destination_elevation: float = -1.0) -> float:
	if not _valid or not destination.is_finite(): return INF
	var origin: Vector2 = _state.units[_model_id].position
	var origin_elevation := float(_state.units[_model_id].get("elevation", 0.0))
	var target_elevation := origin_elevation if destination_elevation < 0.0 else destination_elevation
	if not is_finite(target_elevation) or target_elevation < 0.0: return INF
	var ignores_vertical := Terrain.ignores_vertical_movement(_state, _model_id)
	var direct_distance := Terrain.movement_distance(origin, origin_elevation, destination, target_elevation, ignores_vertical)
	if direct_distance > _maximum + EPSILON: return INF
	if Geometry.clear_path(_state, _model_id, destination, _maximum, false, false, target_elevation, _move_type): return direct_distance
	var origin_surface := Terrain.surface_at(_state, _state.units[_model_id], origin, origin_elevation)
	var destination_surface := Terrain.surface_at(_state, _state.units[_model_id], destination, target_elevation)
	var cross_surface := absf(target_elevation - origin_elevation) > EPSILON
	if not cross_surface and not origin_surface.is_empty() and not destination_surface.is_empty():
		cross_surface = not Terrain.same_surface(origin_surface, destination_surface)
	var same_upper_surface := not cross_surface and origin_elevation > EPSILON \
		and not origin_surface.is_empty() and Terrain.same_surface(origin_surface, destination_surface)
	if cross_surface:
		if destination_surface.is_empty(): return INF
		var vertical_blockers := _model_blocking_circles(origin)
		if not _built: _build_waypoint_nodes()
		_add_vertical_access_nodes(origin, 0, target_elevation, Rect2(destination, Vector2.ZERO))
		var cross_surface_distance := _distance_to_waypoint_graph(destination, vertical_blockers, target_elevation)
		if is_inf(cross_surface_distance) and _add_vertical_access_nodes(origin, VERTICAL_ACCESS_EDGE_SUBDIVISIONS, target_elevation, Rect2(destination, Vector2.ZERO)):
			cross_surface_distance = _distance_to_waypoint_graph(destination, vertical_blockers, target_elevation)
		if not _allow_intermediate_surface_search: return cross_surface_distance
		return _distance_via_intermediate_surfaces(destination, target_elevation, cross_surface_distance)
	var blockers := _model_blocking_circles(origin)
	var terrain_obstacles := Terrain.movement_obstacles(_state, _model_id)
	if blockers.size() == 1 and absf(float(_state.units[_model_id].get("elevation", 0.0))) <= EPSILON and terrain_obstacles.is_empty():
		var exact_single_circle_route := _single_circle_route_distance(destination, blockers[0])
		if not is_inf(exact_single_circle_route):
			return exact_single_circle_route if exact_single_circle_route <= _maximum + EPSILON else INF
	if (blockers.size() > 1 or not terrain_obstacles.is_empty()) and _uses_surface_visibility_graph():
		var surface_visibility_route := _same_surface_visibility_route_distance(destination, blockers, terrain_obstacles)
		if not is_inf(surface_visibility_route):
			var bounded_surface_route := surface_visibility_route if surface_visibility_route <= _maximum + EPSILON else INF
			if same_upper_surface and _allow_intermediate_surface_search:
				return _distance_via_intermediate_surfaces(destination, target_elevation, bounded_surface_route)
			return bounded_surface_route
	if _visibility_graph_overflow:
		if not _built: _build_waypoint_nodes()
		return _distance_to_waypoint_graph(destination, blockers, target_elevation)
	if not _built: _build_graph()
	if _nodes.is_empty(): return INF
	var best := INF
	for index in range(_nodes.size()):
		var travelled := _distances[index]
		if is_inf(travelled) or travelled >= best: continue
		var remaining := _maximum - travelled
		if remaining < -EPSILON: continue
		var point: Vector2 = _nodes[index]
		var edge_length := point.distance_to(destination)
		if edge_length > remaining + EPSILON: continue
		_set_origin(point)
		if not Geometry.clear_path(_scratch, _model_id, destination, edge_length + EPSILON, false, false, -1.0, _move_type): continue
		best = travelled + edge_length
	# Add analytic tangent approaches to each clearance-expanded blocker circle.
	# The reusable graph already contains fixed boundary waypoints; query
	# tangents avoid making the last leg depend on their angular sample phase.
	for obstacle: Dictionary in blockers:
		for tangent: Vector2 in _circle_tangent_points(destination, obstacle.center, obstacle.radius):
			var final_leg := tangent.distance_to(destination)
			_set_origin(tangent)
			if not Geometry.clear_path(_scratch, _model_id, destination, final_leg + EPSILON, false, false, -1.0, _move_type): continue
			for index in range(_nodes.size()):
				var travelled := _distances[index]
				if is_inf(travelled) or travelled >= best: continue
				var point: Vector2 = _nodes[index]
				var first_leg := point.distance_to(tangent)
				var proposed := travelled + first_leg + final_leg
				if proposed > _maximum + EPSILON or proposed >= best: continue
				_set_origin(point)
				if not Geometry.clear_path(_scratch, _model_id, tangent, first_leg + EPSILON, false, false, -1.0, _move_type): continue
				best = proposed
	if same_upper_surface and _allow_intermediate_surface_search:
		best = _distance_via_intermediate_surfaces(destination, target_elevation, best)
	return best

## Exact tangent-and-arc distance for the isolated ground-level circle case.
## Other blockers, terrain and elevated routes stay on the validated waypoint graph.
func _single_circle_route_distance(destination: Vector2, blocker: Dictionary) -> float:
	var model: Dictionary = _state.units[_model_id]
	var origin: Vector2 = model.position
	var center: Vector2 = blocker.center
	var radius := float(blocker.exact_radius)
	var starts := _circle_tangent_points(origin, center, radius)
	var ends := _circle_tangent_points(destination, center, radius)
	if starts.is_empty() or ends.is_empty(): return INF
	var best := INF
	for start: Vector2 in starts:
		var first_leg := origin.distance_to(start)
		_set_origin(origin)
		if not Geometry.clear_path(_scratch, _model_id, start, first_leg + EPSILON, false, false, -1.0, _move_type): continue
		var start_angle := (start - center).angle()
		for finish: Vector2 in ends:
			var last_leg := finish.distance_to(destination)
			_set_origin(finish)
			if not Geometry.clear_path(_scratch, _model_id, destination, last_leg + EPSILON, false, false, -1.0, _move_type): continue
			var finish_angle := (finish - center).angle()
			var counterclockwise_sweep := fposmod(finish_angle - start_angle, TAU)
			var clockwise_sweep := fposmod(start_angle - finish_angle, TAU)
			if _circle_arc_fits_board(center, radius, start_angle, finish_angle, false, float(model.get("radius", 0.0))):
				best = minf(best, first_leg + radius * counterclockwise_sweep + last_leg)
			if _circle_arc_fits_board(center, radius, start_angle, finish_angle, true, float(model.get("radius", 0.0))):
				best = minf(best, first_leg + radius * clockwise_sweep + last_leg)
	return best

## Same-height visibility graph for circular model blockers and rectangular terrain.
## Elevated routes stay inside the mover's one supported surface for the whole arc.
func _same_surface_visibility_route_distance(destination: Vector2, blockers: Array[Dictionary], terrain_obstacles: Array[Rect2]) -> float:
	_visibility_graph_overflow = false
	_visibility_graph_ellipse_pruned_nodes = 0
	_visibility_graph_ellipse_pruned_straight_edges = 0
	_visibility_graph_ellipse_pruned_arc_edges = 0
	_visibility_graph_nodes.clear()
	var origin: Vector2 = _state.units[_model_id].position
	var model: Dictionary = _state.units[_model_id]
	var route_circles := _route_relevant_blockers(destination, blockers)
	var nodes: Array[Vector2] = []
	var origin_index := _append_surface_route_node(nodes, origin, destination)
	var destination_index := _append_surface_route_node(nodes, destination, destination)
	if origin_index < 0 or destination_index < 0: return INF
	var terrain_expansion := maxf(0.0, float(model.get("radius", 0.0)) - EPSILON) + NODE_CLEARANCE
	var route_terrain_obstacles := _route_relevant_terrain_obstacles(destination, terrain_obstacles, terrain_expansion)
	var terrain_corner_nodes: Array[int] = []
	for terrain_obstacle: Rect2 in route_terrain_obstacles:
		if origin.distance_to(origin.clamp(terrain_obstacle.position, terrain_obstacle.end)) > _maximum + terrain_expansion: continue
		var bounds := terrain_obstacle.grow(terrain_expansion)
		var corners: Array[Vector2] = [bounds.position, Vector2(bounds.end.x, bounds.position.y), bounds.end, Vector2(bounds.position.x, bounds.end.y)]
		for corner: Vector2 in corners:
			var corner_index := _append_surface_route_node(nodes, corner, destination)
			if corner_index >= 0: terrain_corner_nodes.append(corner_index)
		if _visibility_graph_overflow: return INF
	var circle_nodes: Array = []
	for _obstacle in route_circles: circle_nodes.append([])
	for obstacle_index in range(route_circles.size()):
		var obstacle: Dictionary = route_circles[obstacle_index]
		for corner_index in terrain_corner_nodes:
			for tangent: Vector2 in _circle_tangent_points(nodes[corner_index], obstacle.center, float(obstacle.radius)):
				var node_index := _append_surface_route_node(nodes, tangent, destination)
				if node_index >= 0: circle_nodes[obstacle_index].append(node_index)
			if _visibility_graph_overflow: return INF
		for tangent: Vector2 in _circle_tangent_points(origin, obstacle.center, float(obstacle.radius)):
			var node_index := _append_surface_route_node(nodes, tangent, destination)
			if node_index >= 0: circle_nodes[obstacle_index].append(node_index)
		for tangent: Vector2 in _circle_tangent_points(destination, obstacle.center, float(obstacle.radius)):
			var node_index := _append_surface_route_node(nodes, tangent, destination)
			if node_index >= 0: circle_nodes[obstacle_index].append(node_index)
	for first_index in range(route_circles.size()):
		for second_index in range(first_index + 1, route_circles.size()):
			var first: Dictionary = route_circles[first_index]
			var second: Dictionary = route_circles[second_index]
			for pair: Dictionary in _circle_pair_tangents(first, second):
				var first_node := _append_surface_route_node(nodes, pair.first, destination)
				var second_node := _append_surface_route_node(nodes, pair.second, destination)
				if first_node >= 0: circle_nodes[first_index].append(first_node)
				if second_node >= 0: circle_nodes[second_index].append(second_node)
			for intersection: Vector2 in _circle_intersections(first, second):
				var intersection_node := _append_surface_route_node(nodes, intersection, destination)
				if intersection_node >= 0:
					circle_nodes[first_index].append(intersection_node)
					circle_nodes[second_index].append(intersection_node)
			if _visibility_graph_overflow: return INF
		if _visibility_graph_overflow: return INF
	var adjacency: Array = []
	for _node in nodes: adjacency.append([])
	for first_index in range(nodes.size()):
		for second_index in range(first_index + 1, nodes.size()):
			var first_point := nodes[first_index]
			var second_point := nodes[second_index]
			var edge_length := first_point.distance_to(second_point)
			if edge_length <= EPSILON or edge_length > _maximum + EPSILON: continue
			if not _surface_route_edge_within_allowance(first_point, second_point, edge_length, destination):
				_visibility_graph_ellipse_pruned_straight_edges += 1
				continue
			_set_origin(first_point)
			if Geometry.clear_path(_scratch, _model_id, second_point, edge_length + EPSILON, false, false, -1.0, _move_type):
				_add_circle_route_edge(adjacency, first_index, second_index, edge_length)
	for obstacle_index in range(route_circles.size()):
		var obstacle: Dictionary = route_circles[obstacle_index]
		var unique_nodes: Dictionary = {}
		for node_index_variant: Variant in circle_nodes[obstacle_index]: unique_nodes[int(node_index_variant)] = true
		var ordered_nodes: Array[int] = []
		for node_index_variant: Variant in unique_nodes.keys(): ordered_nodes.append(int(node_index_variant))
		var center: Vector2 = obstacle.center
		ordered_nodes.sort_custom(func(first: int, second: int) -> bool:
			return (nodes[first] - center).angle() < (nodes[second] - center).angle())
		if ordered_nodes.size() < 2: continue
		var radius := float(obstacle.radius)
		for node_offset in range(ordered_nodes.size()):
			var first_index := ordered_nodes[node_offset]
			var second_index := ordered_nodes[(node_offset + 1) % ordered_nodes.size()]
			var first_angle := (nodes[first_index] - center).angle()
			var second_angle := (nodes[second_index] - center).angle()
			var sweep := fposmod(second_angle - first_angle, TAU)
			var arc_length := radius * sweep
			if sweep <= EPSILON or arc_length > _maximum + EPSILON: continue
			if not _surface_route_edge_within_allowance(nodes[first_index], nodes[second_index], arc_length, destination):
				_visibility_graph_ellipse_pruned_arc_edges += 1
				continue
			if not _circle_arc_fits_board(center, radius, first_angle, second_angle, false, float(_state.units[_model_id].get("radius", 0.0))): continue
			if not _circle_arc_fits_current_surface(center, radius, first_angle, second_angle, false): continue
			if not _circle_arc_clear(route_circles, obstacle_index, center, radius, first_angle, sweep, route_terrain_obstacles, float(model.get("radius", 0.0))): continue
			_add_circle_route_edge(adjacency, first_index, second_index, arc_length)
	_visibility_graph_nodes = nodes
	var distances: Array[float] = []
	distances.resize(nodes.size())
	distances.fill(INF)
	distances[origin_index] = 0.0
	var visited: Array[bool] = []
	visited.resize(nodes.size())
	visited.fill(false)
	for _step in range(nodes.size()):
		var current := -1
		var current_distance := INF
		for node_index in range(nodes.size()):
			if not visited[node_index] and distances[node_index] < current_distance:
				current = node_index
				current_distance = distances[node_index]
		if current < 0 or current_distance > _maximum + EPSILON: break
		if current == destination_index: return current_distance
		visited[current] = true
		for edge: Dictionary in adjacency[current]:
			var next_index := int(edge.to)
			if visited[next_index]: continue
			var proposed := current_distance + float(edge.cost)
			if proposed < distances[next_index]: distances[next_index] = proposed
	return INF

## A route within the move allowance cannot touch a circle whose minimum
## origin-to-circle-to-destination path already exceeds that allowance.
## Omitting such circles reduces visibility-graph nodes without changing any
## route that this query is allowed to return.
func _route_relevant_blockers(destination: Vector2, blockers: Array[Dictionary]) -> Array[Dictionary]:
	var relevant: Array[Dictionary] = []
	var origin: Vector2 = _state.units[_model_id].position
	for blocker: Dictionary in blockers:
		var center: Vector2 = blocker.get("center", Vector2(INF, INF))
		var radius := float(blocker.get("radius", -1.0))
		if not center.is_finite() or is_nan(radius) or is_inf(radius) or radius < 0.0:
			relevant.append(blocker)
			continue
		var route_lower_bound := origin.distance_to(center) + destination.distance_to(center) - 2.0 * radius
		if is_nan(route_lower_bound) or is_inf(route_lower_bound) or route_lower_bound <= _maximum + EPSILON:
			relevant.append(blocker)
	return relevant

## A route that touches a rectangle costs at least the distance from its origin
## to that rectangle plus the distance from that rectangle to its destination.
## Keep malformed rectangles so uncertain geometry never weakens validation.
func _route_relevant_terrain_obstacles(destination: Vector2, obstacles: Array[Rect2], expansion: float) -> Array[Rect2]:
	var relevant: Array[Rect2] = []
	var origin: Vector2 = _state.units[_model_id].position
	for obstacle: Rect2 in obstacles:
		if not obstacle.position.is_finite() or not obstacle.size.is_finite() or obstacle.size.x < 0.0 or obstacle.size.y < 0.0:
			relevant.append(obstacle)
			continue
		var expanded := obstacle.grow(expansion)
		var origin_distance := origin.distance_to(origin.clamp(expanded.position, expanded.end))
		var destination_distance := destination.distance_to(destination.clamp(expanded.position, expanded.end))
		var route_lower_bound := origin_distance + destination_distance
		if is_nan(route_lower_bound) or is_inf(route_lower_bound) or route_lower_bound <= _maximum + EPSILON:
			relevant.append(obstacle)
	return relevant

func _uses_surface_visibility_graph() -> bool:
	var model: Dictionary = _state.units[_model_id]
	var elevation := float(model.get("elevation", 0.0))
	if absf(elevation) > EPSILON and Terrain.surface_at(_state, model, model.position, elevation).is_empty(): return false
	if Terrain.take_to_skies_active(_state, _model_id): return false
	if _state.get("squads", {}).get(int(_state.units[_model_id].get("squad", -1)), {}).get("reiver_grapnel_launchers", false): return false
	return true

func _circle_arc_fits_current_surface(center: Vector2, radius: float, start_angle: float, finish_angle: float, clockwise: bool) -> bool:
	var model: Dictionary = _state.units[_model_id]
	var elevation := float(model.get("elevation", 0.0))
	if absf(elevation) <= EPSILON: return true
	var surface := Terrain.surface_at(_state, model, model.position, elevation)
	if surface.is_empty(): return false
	var bounds: Rect2 = surface.get("bounds", Rect2())
	var inset := maxf(0.0, float(model.get("radius", 0.0)))
	var safe_bounds := Rect2(bounds.position + Vector2.ONE * inset, bounds.size - Vector2.ONE * inset * 2.0)
	if safe_bounds.size.x < -EPSILON or safe_bounds.size.y < -EPSILON: return false
	var sweep := fposmod(start_angle - finish_angle, TAU) if clockwise else fposmod(finish_angle - start_angle, TAU)
	var candidate_angles: Array[float] = [start_angle, start_angle + ( -sweep if clockwise else sweep)]
	for angle: float in [0.0, PI / 2.0, PI, PI * 1.5]:
		var along_arc := fposmod(start_angle - angle, TAU) if clockwise else fposmod(angle - start_angle, TAU)
		if along_arc <= sweep + EPSILON: candidate_angles.append(angle)
	for angle: float in candidate_angles:
		var point := center + Vector2.from_angle(angle) * radius
		if point.x < safe_bounds.position.x - EPSILON or point.x > safe_bounds.end.x + EPSILON: return false
		if point.y < safe_bounds.position.y - EPSILON or point.y > safe_bounds.end.y + EPSILON: return false
	return true

func _append_circle_route_node(nodes: Array[Vector2], point: Vector2) -> int:
	if not point.is_finite(): return -1
	for node_index in range(nodes.size()):
		if nodes[node_index].distance_to(point) <= EPSILON: return node_index
	if nodes.size() >= VISIBILITY_ROUTE_NODE_LIMIT:
		_visibility_graph_overflow = true
		return -1
	var model: Dictionary = _state.units[_model_id]
	var radius := maxf(0.0, float(model.get("radius", 0.0)))
	var half_board: Vector2 = Vector2(_state.get("board_size", Vector2.ZERO)) / 2.0
	if absf(point.x) > half_board.x - radius + EPSILON or absf(point.y) > half_board.y - radius + EPSILON: return -1
	if point.distance_to(model.position) > _maximum + EPSILON: return -1
	var point_surface := Terrain.surface_at(_state, model, point, float(model.get("elevation", 0.0)))
	if point_surface.is_empty(): return -1
	var elevation := float(model.get("elevation", 0.0))
	if absf(elevation) > EPSILON:
		var origin_surface := Terrain.surface_at(_state, model, model.position, elevation)
		if origin_surface.is_empty(): return -1
		if not Terrain.same_surface(point_surface, origin_surface): return -1
	_set_origin(point)
	if not Geometry.clear_path(_scratch, _model_id, point, 0.0, false, false, -1.0, _move_type): return -1
	nodes.append(point)
	return nodes.size() - 1

## A route through a candidate point cannot cost less than the straight
## origin-to-point plus point-to-destination distances. Skip candidates whose
## lower bound already exceeds the movement allowance.
func _append_surface_route_node(nodes: Array[Vector2], point: Vector2, destination: Vector2) -> int:
	var origin: Vector2 = _state.units[_model_id].position
	if origin.is_finite() and point.is_finite() and destination.is_finite():
		var route_lower_bound := origin.distance_to(point) + point.distance_to(destination)
		if not is_nan(route_lower_bound) and not is_inf(route_lower_bound) and route_lower_bound > _maximum + EPSILON:
			_visibility_graph_ellipse_pruned_nodes += 1
			return -1
	return _append_circle_route_node(nodes, point)

## An undirected edge is irrelevant when neither orientation can fit in the
## allowance, even before validating its straight or circular geometry.
func _surface_route_edge_within_allowance(first: Vector2, second: Vector2, cost: float, destination: Vector2) -> bool:
	var origin: Vector2 = _state.units[_model_id].position
	if not origin.is_finite() or not first.is_finite() or not second.is_finite() or not destination.is_finite(): return true
	if is_nan(cost) or is_inf(cost) or cost < 0.0: return true
	var forward_lower_bound := origin.distance_to(first) + cost + second.distance_to(destination)
	var reverse_lower_bound := origin.distance_to(second) + cost + first.distance_to(destination)
	if is_nan(forward_lower_bound) or is_inf(forward_lower_bound) or is_nan(reverse_lower_bound) or is_inf(reverse_lower_bound): return true
	return minf(forward_lower_bound, reverse_lower_bound) <= _maximum + EPSILON

func _circle_arc_clear(route_circles: Array[Dictionary], obstacle_index: int, center: Vector2, radius: float, start_angle: float, sweep: float, terrain_obstacles: Array[Rect2], model_radius: float) -> bool:
	for other_index in range(route_circles.size()):
		if other_index == obstacle_index: continue
		var other: Dictionary = route_circles[other_index]
		var minimum_distance := _distance_to_circle_arc(Vector2(other.center), center, radius, start_angle, sweep)
		if minimum_distance < float(other.radius) - EPSILON: return false
	for terrain_obstacle: Rect2 in terrain_obstacles:
		if not _circle_arc_clear_of_rect(center, radius, start_angle, sweep, terrain_obstacle, model_radius): return false
	return true

static func _circle_arc_clear_of_rect(center: Vector2, radius: float, start_angle: float, sweep: float, obstacle: Rect2, model_radius: float) -> bool:
	var required_clearance := maxf(0.0, model_radius - EPSILON) + NODE_CLEARANCE
	var blocked_bounds := obstacle.grow(required_clearance)
	if _circle_arc_intersects_rect(center, radius, start_angle, sweep, blocked_bounds): return false
	var candidate_angles: Array[float] = [start_angle, start_angle + sweep, 0.0, PI / 2.0, PI, PI * 1.5]
	for angle: float in candidate_angles:
		if fposmod(angle - start_angle, TAU) > sweep + EPSILON: continue
		var point := center + Vector2.from_angle(angle) * radius
		if blocked_bounds.has_point(point): return false
	return true

static func _circle_arc_intersects_rect(center: Vector2, radius: float, start_angle: float, sweep: float, obstacle: Rect2) -> bool:
	for x in [obstacle.position.x, obstacle.end.x]:
		var horizontal_offset := float(x) - center.x
		if absf(horizontal_offset) > radius + EPSILON: continue
		var vertical_intersection := sqrt(maxf(0.0, radius * radius - horizontal_offset * horizontal_offset))
		for y in [center.y + vertical_intersection, center.y - vertical_intersection]:
			if float(y) < obstacle.position.y - EPSILON or float(y) > obstacle.end.y + EPSILON: continue
			if fposmod((Vector2(float(x), float(y)) - center).angle() - start_angle, TAU) <= sweep + EPSILON: return true
	for y in [obstacle.position.y, obstacle.end.y]:
		var vertical_offset := float(y) - center.y
		if absf(vertical_offset) > radius + EPSILON: continue
		var horizontal_intersection := sqrt(maxf(0.0, radius * radius - vertical_offset * vertical_offset))
		for x in [center.x + horizontal_intersection, center.x - horizontal_intersection]:
			if float(x) < obstacle.position.x - EPSILON or float(x) > obstacle.end.x + EPSILON: continue
			if fposmod((Vector2(float(x), float(y)) - center).angle() - start_angle, TAU) <= sweep + EPSILON: return true
	return false

static func _distance_to_circle_arc(point: Vector2, center: Vector2, radius: float, start_angle: float, sweep: float) -> float:
	var offset := point - center
	var point_angle := offset.angle()
	if fposmod(point_angle - start_angle, TAU) <= sweep + EPSILON:
		return absf(offset.length() - radius)
	var start_point := center + Vector2.from_angle(start_angle) * radius
	var end_point := center + Vector2.from_angle(start_angle + sweep) * radius
	return minf(point.distance_to(start_point), point.distance_to(end_point))

static func _circle_intersections(first: Dictionary, second: Dictionary) -> Array[Vector2]:
	var first_center := Vector2(first.get("center", Vector2.ZERO))
	var second_center := Vector2(second.get("center", Vector2.ZERO))
	var first_radius := float(first.get("radius", -1.0))
	var second_radius := float(second.get("radius", -1.0))
	var delta := second_center - first_center
	var center_distance := delta.length()
	if center_distance <= EPSILON or center_distance > first_radius + second_radius + EPSILON or center_distance < absf(first_radius - second_radius) - EPSILON: return []
	var along := (first_radius * first_radius - second_radius * second_radius + center_distance * center_distance) / (2.0 * center_distance)
	var height_squared := maxf(0.0, first_radius * first_radius - along * along)
	var midpoint := first_center + delta / center_distance * along
	var perpendicular := (delta / center_distance).orthogonal() * sqrt(height_squared)
	return [midpoint + perpendicular, midpoint - perpendicular]

static func _add_circle_route_edge(adjacency: Array, first_index: int, second_index: int, cost: float) -> void:
	adjacency[first_index].append({"to": second_index, "cost": cost})
	adjacency[second_index].append({"to": first_index, "cost": cost})

func _circle_arc_fits_board(center: Vector2, radius: float, start_angle: float, finish_angle: float, clockwise: bool, model_radius: float) -> bool:
	var half_board: Vector2 = Vector2(_state.get("board_size", Vector2.ZERO)) / 2.0
	var sweep := fposmod(start_angle - finish_angle, TAU) if clockwise else fposmod(finish_angle - start_angle, TAU)
	for angle in [0.0, PI / 2.0, PI, PI * 1.5]:
		var along_arc := fposmod(start_angle - angle, TAU) if clockwise else fposmod(angle - start_angle, TAU)
		if along_arc > sweep + EPSILON: continue
		var point := center + Vector2.from_angle(angle) * radius
		if absf(point.x) > half_board.x - model_radius + EPSILON or absf(point.y) > half_board.y - model_radius + EPSILON: return false
	return true

## Returns the best reachable endpoint toward a rectangular or point target region.
## The selected route may bend through any validated waypoint; the final segment stays straight.
func closest_reachable_to_region(region: Rect2, target_radius: float, endpoint_filter: Callable = Callable(), endpoint_exclusion_circles: Array = [], destination_elevation: float = -1.0) -> Dictionary:
	if not _valid or not region.position.is_finite() or not region.end.is_finite() or is_nan(target_radius) or is_inf(target_radius) or target_radius < 0.0:
		return {"point": Vector2.ZERO, "distance": INF, "route_distance": INF}
	var origin_elevation := float(_state.units[_model_id].get("elevation", 0.0))
	var target_elevation := origin_elevation if destination_elevation < 0.0 else destination_elevation
	if not is_finite(target_elevation) or target_elevation < 0.0:
		return {"point": Vector2.ZERO, "distance": INF, "route_distance": INF}
	if not _built: _build_waypoint_nodes()
	var cross_surface := _region_requires_surface_transition(region, target_radius, target_elevation)
	var same_upper_surface := not cross_surface and origin_elevation > EPSILON
	if cross_surface:
		_add_vertical_access_nodes(_state.units[_model_id].position, 0, target_elevation, region.grow(target_radius), true)
	var result := _closest_reachable_to_region_on_current_graph(region, target_radius, endpoint_filter, endpoint_exclusion_circles, target_elevation)
	var initial_gap := float(result.get("distance", INF))
	if cross_surface and (is_inf(initial_gap) or initial_gap > EPSILON) \
		and _add_vertical_access_nodes(_state.units[_model_id].position, VERTICAL_ACCESS_EDGE_SUBDIVISIONS, target_elevation, region.grow(target_radius), true):
		var refined_result := _closest_reachable_to_region_on_current_graph(region, target_radius, endpoint_filter, endpoint_exclusion_circles, target_elevation)
		var refined_gap := float(refined_result.get("distance", INF))
		var current_route := float(result.get("route_distance", INF))
		var refined_route := float(refined_result.get("route_distance", INF))
		if refined_gap < initial_gap - EPSILON or (absf(refined_gap - initial_gap) <= EPSILON and refined_route < current_route - EPSILON):
			result = refined_result
	if (cross_surface or same_upper_surface) and _allow_intermediate_surface_search:
		result = _closest_region_via_intermediate_surfaces(region, target_radius, endpoint_filter, endpoint_exclusion_circles, target_elevation, result)
	return result

func _closest_region_via_intermediate_surfaces(region: Rect2, target_radius: float, endpoint_filter: Callable, endpoint_exclusion_circles: Array, target_elevation: float, best_result: Dictionary) -> Dictionary:
	var model: Dictionary = _state.units[_model_id]
	var origin: Vector2 = model.position
	var origin_elevation := float(model.get("elevation", 0.0))
	var current_surface := Terrain.surface_at(_state, model, origin, origin_elevation)
	if current_surface.is_empty(): return best_result
	var visited := _visited_surface_ids.duplicate()
	var current_surface_id := _surface_identity(current_surface)
	if not visited.has(current_surface_id): visited.append(current_surface_id)
	var best := best_result
	var best_gap := float(best.get("distance", INF))
	var best_route := float(best.get("route_distance", INF))
	var ignores_vertical := Terrain.ignores_vertical_movement(_state, _model_id)
	for surface: Dictionary in Terrain.surfaces(_state):
		var next_elevation := float(surface.get("elevation", 0.0))
		if absf(next_elevation - origin_elevation) <= EPSILON or absf(next_elevation - target_elevation) <= EPSILON: continue
		var surface_id := _surface_identity(surface)
		if visited.has(surface_id) or not Terrain.can_end_on_surface(model, surface): continue
		var access_points := _vertical_surface_access_points(surface, region.get_center(), target_elevation, region, target_radius, false)
		if access_points.is_empty(): continue
		var first_leg_pathfinder: Variant = get_script().new(_state, _model_id, _maximum, _move_type, false, visited)
		for access_point: Vector2 in access_points:
			var remaining_lower_bound := _region_distance(access_point, region, target_radius) \
				+ (0.0 if ignores_vertical else absf(target_elevation - next_elevation))
			var first_leg_lower_bound := Terrain.movement_distance(origin, origin_elevation, access_point, next_elevation, ignores_vertical)
			if first_leg_lower_bound > _maximum + EPSILON: continue
			if best_gap <= EPSILON and first_leg_lower_bound + remaining_lower_bound >= best_route - EPSILON: continue
			var first_leg := float(first_leg_pathfinder.distance_to(access_point, next_elevation))
			if is_inf(first_leg) or first_leg > _maximum + EPSILON: continue
			if best_gap <= EPSILON and first_leg + remaining_lower_bound >= best_route - EPSILON: continue
			var remaining := _maximum - first_leg
			var next_state := _state_at_surface(access_point, next_elevation)
			var next_visited := visited.duplicate()
			next_visited.append(surface_id)
			var next_pathfinder: Variant = get_script().new(next_state, _model_id, remaining, _move_type, true, next_visited)
			var candidate: Dictionary = next_pathfinder.closest_reachable_to_region(region, target_radius, endpoint_filter, endpoint_exclusion_circles, target_elevation)
			var candidate_gap := float(candidate.get("distance", INF))
			var candidate_route := first_leg + float(candidate.get("route_distance", INF))
			if is_inf(candidate_gap) or is_inf(candidate_route): continue
			if candidate_gap < best_gap - EPSILON or (absf(candidate_gap - best_gap) <= EPSILON and candidate_route < best_route - EPSILON):
				best_gap = candidate_gap
				best_route = candidate_route
				best = candidate.duplicate()
				best.route_distance = candidate_route
	var ground_id := _surface_identity({"id": "ground", "area_index": -1})
	if origin_elevation > EPSILON and target_elevation > EPSILON and not visited.has(ground_id):
		var ground_access_points := _vertical_surface_access_points(current_surface, region.get_center(), target_elevation, region, target_radius, false)
		var ground_first_leg_pathfinder: Variant = get_script().new(_state, _model_id, _maximum, _move_type, false, visited)
		for access_point: Vector2 in ground_access_points:
			var ground_first_lower_bound := Terrain.movement_distance(origin, origin_elevation, access_point, 0.0, ignores_vertical)
			var remaining_lower_bound := _region_distance(access_point, region, target_radius) \
				+ (0.0 if ignores_vertical else target_elevation)
			if ground_first_lower_bound > _maximum + EPSILON: continue
			if best_gap <= EPSILON and ground_first_lower_bound + remaining_lower_bound >= best_route - EPSILON: continue
			var first_leg := float(ground_first_leg_pathfinder.distance_to(access_point, 0.0))
			if is_inf(first_leg) or first_leg > _maximum + EPSILON: continue
			if best_gap <= EPSILON and first_leg + remaining_lower_bound >= best_route - EPSILON: continue
			var next_state := _state_at_surface(access_point, 0.0)
			var next_visited := visited.duplicate()
			next_visited.append(ground_id)
			var remaining := _maximum - first_leg
			var next_pathfinder: Variant = get_script().new(next_state, _model_id, remaining, _move_type, true, next_visited)
			var candidate: Dictionary = next_pathfinder.closest_reachable_to_region(region, target_radius, endpoint_filter, endpoint_exclusion_circles, target_elevation)
			var candidate_gap := float(candidate.get("distance", INF))
			var candidate_route := first_leg + float(candidate.get("route_distance", INF))
			if is_inf(candidate_gap) or is_inf(candidate_route): continue
			if candidate_gap < best_gap - EPSILON or (absf(candidate_gap - best_gap) <= EPSILON and candidate_route < best_route - EPSILON):
				best_gap = candidate_gap
				best_route = candidate_route
				best = candidate.duplicate()
				best.route_distance = candidate_route
	return best

func _closest_reachable_to_region_on_current_graph(region: Rect2, target_radius: float, endpoint_filter: Callable, endpoint_exclusion_circles: Array, target_elevation: float) -> Dictionary:
	if _nodes.is_empty():
		return {"point": Vector2.ZERO, "distance": INF, "route_distance": INF}
	var origin_elevation := float(_state.units[_model_id].get("elevation", 0.0))
	if _visibility_graph_overflow or _nodes.size() > VISIBILITY_ROUTE_NODE_LIMIT:
		return _closest_reachable_to_region_waypoint_astar(region, target_radius, endpoint_filter, endpoint_exclusion_circles, target_elevation)
	if not _distances_built: _build_graph()
	if _distances.size() != _nodes.size(): return {"point": Vector2.ZERO, "distance": INF, "route_distance": INF}
	var vertical_cost := Terrain.movement_distance(Vector2.ZERO, origin_elevation, Vector2.ZERO, target_elevation, Terrain.ignores_vertical_movement(_state, _model_id))
	var best_point: Vector2 = _state.units[_model_id].position
	var best_distance := INF
	var best_route_distance := INF
	for index in range(_nodes.size()):
		var travelled := _distances[index]
		if is_inf(travelled) or travelled > _maximum + EPSILON: continue
		var node: Vector2 = _nodes[index]
		var anchor := node.clamp(region.position, region.end)
		var offset := anchor - node
		var distance_to_region := maxf(0.0, offset.length() - target_radius)
		var leg_distance := minf(maxf(0.0, _maximum - travelled - vertical_cost), distance_to_region)
		var candidate := node
		if leg_distance > EPSILON and offset.length() > EPSILON:
			candidate += offset / offset.length() * leg_distance
		var direction := (candidate - node).normalized()
		leg_distance = _furthest_clear_leg(node, direction, leg_distance, target_elevation)
		candidate = node + direction * leg_distance
		if endpoint_filter.is_valid():
			var allowed_endpoint := _furthest_allowed_endpoint(node, direction, leg_distance, endpoint_filter)
			if allowed_endpoint.is_empty(): continue
			candidate = allowed_endpoint.point
			leg_distance = float(allowed_endpoint.distance)
		if not endpoint_exclusion_circles.is_empty():
			var outside_endpoint := _furthest_outside_exclusion_circles(node, direction, leg_distance, endpoint_exclusion_circles)
			if outside_endpoint.is_empty(): continue
			candidate = outside_endpoint.point
			leg_distance = float(outside_endpoint.distance)
		var score := _region_distance(candidate, region, target_radius)
		var route_distance := travelled + leg_distance + vertical_cost
		if score < best_distance - EPSILON or (absf(score - best_distance) <= EPSILON and route_distance < best_route_distance):
			best_point = candidate
			best_distance = score
			best_route_distance = route_distance
	return {"point": best_point, "distance": best_distance, "route_distance": best_route_distance, "elevation": target_elevation}

func _closest_reachable_to_region_waypoint_astar(region: Rect2, target_radius: float, endpoint_filter: Callable, endpoint_exclusion_circles: Array, target_elevation: float) -> Dictionary:
	_fallback_route_expansions = 0
	_fallback_route_edge_checks = 0
	var best_point: Vector2 = _state.units[_model_id].position
	var best_distance := INF
	var best_route_distance := INF
	var origin_elevation := float(_state.units[_model_id].get("elevation", 0.0))
	var vertical_cost := Terrain.movement_distance(Vector2.ZERO, origin_elevation, Vector2.ZERO, target_elevation, Terrain.ignores_vertical_movement(_state, _model_id))
	var distances: Array[float] = []
	distances.resize(_nodes.size())
	distances.fill(INF)
	distances[0] = 0.0
	var visited: Array[bool] = []
	visited.resize(_nodes.size())
	visited.fill(false)
	var open: Array[Array] = []
	var origin: Vector2 = _state.units[_model_id].position
	var origin_bound := maxf(0.0, _region_distance(origin, region, target_radius) - _maximum)
	_path_heap_push(open, [origin_bound, 0.0, 0])
	while not open.is_empty():
		var entry := _path_heap_pop(open)
		var current := int(entry[2])
		var travelled := float(entry[1])
		if visited[current] or travelled > distances[current] + 0.0000001: continue
		var score_bound := float(entry[0])
		if score_bound > best_distance + EPSILON \
			or (score_bound >= best_distance - EPSILON and travelled >= best_route_distance - EPSILON):
			break
		if travelled > _maximum + EPSILON: continue
		visited[current] = true
		_fallback_route_expansions += 1
		var node: Vector2 = _nodes[current]
		var anchor := node.clamp(region.position, region.end)
		var offset := anchor - node
		var distance_to_region := maxf(0.0, offset.length() - target_radius)
		var leg_distance := minf(maxf(0.0, _maximum - travelled - vertical_cost), distance_to_region)
		var candidate := node
		if leg_distance > EPSILON and offset.length() > EPSILON:
			candidate += offset / offset.length() * leg_distance
		var direction := (candidate - node).normalized()
		leg_distance = _furthest_clear_leg(node, direction, leg_distance, target_elevation)
		candidate = node + direction * leg_distance
		if endpoint_filter.is_valid():
			var allowed_endpoint := _furthest_allowed_endpoint(node, direction, leg_distance, endpoint_filter)
			if allowed_endpoint.is_empty():
				leg_distance = -1.0
			else:
				candidate = allowed_endpoint.point
				leg_distance = float(allowed_endpoint.distance)
		if leg_distance >= 0.0 and not endpoint_exclusion_circles.is_empty():
			var outside_endpoint := _furthest_outside_exclusion_circles(node, direction, leg_distance, endpoint_exclusion_circles)
			if outside_endpoint.is_empty():
				leg_distance = -1.0
			else:
				candidate = outside_endpoint.point
				leg_distance = float(outside_endpoint.distance)
		if leg_distance >= 0.0:
			var score := _region_distance(candidate, region, target_radius)
			var route_distance := travelled + leg_distance + vertical_cost
			if score < best_distance - EPSILON or (absf(score - best_distance) <= EPSILON and route_distance < best_route_distance):
				best_point = candidate
				best_distance = score
				best_route_distance = route_distance
		for next in range(_nodes.size()):
			if next == current or visited[next]: continue
			var next_point: Vector2 = _nodes[next]
			var edge_length := node.distance_to(next_point)
			if edge_length <= EPSILON: continue
			var proposed := travelled + edge_length
			if proposed > _maximum + EPSILON or proposed >= distances[next]: continue
			var next_score_bound := maxf(0.0, _region_distance(next_point, region, target_radius) - (_maximum - proposed))
			if next_score_bound > best_distance + EPSILON \
				or (next_score_bound >= best_distance - EPSILON and proposed >= best_route_distance - EPSILON):
				continue
			if not _fallback_edge_is_clear(current, next, edge_length): continue
			distances[next] = proposed
			_path_heap_push(open, [next_score_bound, proposed, next])
	return {"point": best_point, "distance": best_distance, "route_distance": best_route_distance, "elevation": target_elevation}

func _fallback_edge_is_clear(first_index: int, second_index: int, edge_length: float) -> bool:
	var first := mini(first_index, second_index)
	var second := maxi(first_index, second_index)
	var key := first * _nodes.size() + second
	if _fallback_route_edge_cache.has(key): return bool(_fallback_route_edge_cache[key])
	_set_origin(_nodes[first_index])
	_fallback_route_edge_checks += 1
	var clear := Geometry.clear_path(_scratch, _model_id, _nodes[second_index], edge_length + EPSILON, false, false, -1.0, _move_type)
	_fallback_route_edge_cache[key] = clear
	return clear

## Target-directed fallback used only when the analytic visibility graph exceeds
## its node cap. It retains the validated waypoint graph but checks edges as A*
## reaches them instead of validating every pair before routing.
func _distance_to_waypoint_graph(destination: Vector2, blockers: Array[Dictionary], destination_elevation: float = -1.0) -> float:
	_fallback_route_expansions = 0
	_fallback_route_edge_checks = 0
	if _nodes.is_empty(): return INF
	var origin_elevation := float(_state.units[_model_id].get("elevation", 0.0))
	var target_elevation := origin_elevation if destination_elevation < 0.0 else destination_elevation
	var ignores_vertical := Terrain.ignores_vertical_movement(_state, _model_id)
	var terminals: Array[Dictionary] = [{"point": destination, "elevation": target_elevation, "finish_cost": 0.0}]
	for obstacle: Dictionary in blockers:
		for tangent: Vector2 in _circle_tangent_points(destination, Vector2(obstacle.center), float(obstacle.radius)):
			var finish_cost := Terrain.movement_distance(tangent, origin_elevation, destination, target_elevation, ignores_vertical)
			if finish_cost > _maximum + EPSILON: continue
			_set_origin(tangent)
			if not Geometry.clear_path(_scratch, _model_id, destination, finish_cost + EPSILON, false, false, target_elevation, _move_type): continue
			terminals.append({"point": tangent, "elevation": origin_elevation, "finish_cost": finish_cost})
	var heuristics: Array[float] = []
	for point: Vector2 in _nodes: heuristics.append(_waypoint_goal_heuristic(point, terminals))
	var distances: Array[float] = []
	distances.resize(_nodes.size())
	distances.fill(INF)
	distances[0] = 0.0
	var visited: Array[bool] = []
	visited.resize(_nodes.size())
	visited.fill(false)
	var open: Array[Array] = []
	_path_heap_push(open, [heuristics[0], 0.0, 0])
	var best := INF
	while not open.is_empty():
		var entry := _path_heap_pop(open)
		var current := int(entry[2])
		var travelled := float(entry[1])
		if visited[current] or travelled > distances[current] + 0.0000001: continue
		var estimate := float(entry[0])
		if estimate >= best - EPSILON or estimate > _maximum + EPSILON: break
		visited[current] = true
		_fallback_route_expansions += 1
		var point: Vector2 = _nodes[current]
		for terminal: Dictionary in terminals:
			var endpoint: Vector2 = terminal.point
			var endpoint_elevation := float(terminal.get("elevation", origin_elevation))
			var leg_length := Terrain.movement_distance(point, origin_elevation, endpoint, endpoint_elevation, ignores_vertical)
			var proposed := travelled + leg_length + float(terminal.finish_cost)
			if leg_length <= EPSILON and absf(endpoint_elevation - origin_elevation) <= EPSILON or proposed > _maximum + EPSILON or proposed >= best - EPSILON: continue
			_set_origin(point)
			_fallback_route_edge_checks += 1
			if Geometry.clear_path(_scratch, _model_id, endpoint, leg_length + EPSILON, false, false, endpoint_elevation, _move_type): best = proposed
		for next in range(_nodes.size()):
			if next == current or visited[next]: continue
			var next_point: Vector2 = _nodes[next]
			var edge_length := point.distance_to(next_point)
			if edge_length <= EPSILON: continue
			var proposed := travelled + edge_length
			if proposed > _maximum + EPSILON or proposed >= distances[next]: continue
			var next_estimate := proposed + heuristics[next]
			if next_estimate >= best - EPSILON or next_estimate > _maximum + EPSILON: continue
			if not _surface_route_edge_within_allowance(point, next_point, edge_length, destination): continue
			if not _fallback_edge_is_clear(current, next, edge_length): continue
			distances[next] = proposed
			_path_heap_push(open, [next_estimate, proposed, next])
	return best

func _waypoint_goal_heuristic(point: Vector2, terminals: Array[Dictionary]) -> float:
	var estimate := INF
	var origin_elevation := float(_state.units[_model_id].get("elevation", 0.0))
	for terminal: Dictionary in terminals:
		var terminal_elevation := float(terminal.get("elevation", origin_elevation))
		var distance := Terrain.movement_distance(point, origin_elevation, Vector2(terminal.point), terminal_elevation, Terrain.ignores_vertical_movement(_state, _model_id))
		estimate = minf(estimate, distance + float(terminal.finish_cost))
	return estimate

static func _path_heap_less(first: Array, second: Array) -> bool:
	if float(first[0]) != float(second[0]): return float(first[0]) < float(second[0])
	if float(first[1]) != float(second[1]): return float(first[1]) < float(second[1])
	return int(first[2]) < int(second[2])

static func _path_heap_push(heap: Array[Array], entry: Array) -> void:
	var child := heap.size()
	heap.append(entry)
	while child > 0:
		var parent := (child - 1) / 2
		if not _path_heap_less(entry, heap[parent]): break
		heap[child] = heap[parent]
		child = parent
	heap[child] = entry

static func _path_heap_pop(heap: Array[Array]) -> Array:
	var first: Array = heap[0]
	var last: Array = heap.pop_back()
	if heap.is_empty(): return first
	var parent := 0
	while true:
		var child := parent * 2 + 1
		if child >= heap.size(): break
		if child + 1 < heap.size() and _path_heap_less(heap[child + 1], heap[child]): child += 1
		if not _path_heap_less(heap[child], last): break
		heap[parent] = heap[child]
		parent = child
	heap[parent] = last
	return first

func _furthest_clear_leg(origin: Vector2, direction: Vector2, requested_distance: float, destination_elevation: float = -1.0) -> float:
	if requested_distance <= EPSILON: return 0.0
	_set_origin(origin)
	var origin_elevation := float(_state.units[_model_id].get("elevation", 0.0))
	var target_elevation := origin_elevation if destination_elevation < 0.0 else destination_elevation
	var vertical_cost := Terrain.movement_distance(Vector2.ZERO, origin_elevation, Vector2.ZERO, target_elevation, Terrain.ignores_vertical_movement(_state, _model_id))
	var endpoint := origin + direction * requested_distance
	if Geometry.clear_path(_scratch, _model_id, endpoint, requested_distance + vertical_cost + EPSILON, false, false, target_elevation, _move_type): return requested_distance
	var low := 0.0
	var high := requested_distance
	for _step in range(CLEAR_PATH_SEARCH_STEPS):
		var middle := (low + high) * 0.5
		var point := origin + direction * middle
		if Geometry.clear_path(_scratch, _model_id, point, middle + vertical_cost + EPSILON, false, false, target_elevation, _move_type): low = middle
		else: high = middle
	return low

func _furthest_allowed_endpoint(origin: Vector2, direction: Vector2, maximum_distance: float, endpoint_filter: Callable) -> Dictionary:
	if not endpoint_filter.is_valid(): return {"point": origin + direction * maximum_distance, "distance": maximum_distance}
	var endpoint := origin + direction * maximum_distance
	if bool(endpoint_filter.call(endpoint)): return {"point": endpoint, "distance": maximum_distance}
	var best_distance := -1.0
	var best_sample := -1
	for sample in range(ENDPOINT_FILTER_SAMPLES + 1):
		var distance := maximum_distance * float(sample) / float(ENDPOINT_FILTER_SAMPLES)
		if bool(endpoint_filter.call(origin + direction * distance)):
			best_distance = distance
			best_sample = sample
	if best_sample < 0: return {}
	var farther_sample := best_sample + 1
	if farther_sample <= ENDPOINT_FILTER_SAMPLES:
		var low := best_distance
		var high := maximum_distance * float(farther_sample) / float(ENDPOINT_FILTER_SAMPLES)
		for _step in range(ENDPOINT_FILTER_SEARCH_STEPS):
			var middle := (low + high) * 0.5
			if bool(endpoint_filter.call(origin + direction * middle)): low = middle
			else: high = middle
		best_distance = low
	return {"point": origin + direction * best_distance, "distance": best_distance}

func _furthest_outside_exclusion_circles(origin: Vector2, direction: Vector2, maximum_distance: float, circles: Array) -> Dictionary:
	if maximum_distance <= EPSILON:
		for circle: Dictionary in circles:
			var center: Vector2 = circle.get("center", Vector2(INF, INF))
			var radius := float(circle.get("radius", -1.0))
			if not center.is_finite() or is_nan(radius) or is_inf(radius) or radius < 0.0: return {}
			if origin.distance_to(center) <= radius + EPSILON: return {}
		return {"point": origin, "distance": 0.0}
	var unit_direction := direction.normalized()
	if unit_direction.length_squared() <= EPSILON * EPSILON: return {}
	var blocked_intervals: Array[Vector2] = []
	for circle: Dictionary in circles:
		var center: Vector2 = circle.get("center", Vector2(INF, INF))
		var radius := float(circle.get("radius", -1.0))
		if not center.is_finite() or is_nan(radius) or is_inf(radius) or radius < 0.0: return {}
		var relative := center - origin
		var projection := relative.dot(unit_direction)
		var perpendicular_squared := maxf(0.0, relative.length_squared() - projection * projection)
		var radius_squared := radius * radius
		if perpendicular_squared > radius_squared + EPSILON: continue
		var half_width := sqrt(maxf(0.0, radius_squared - perpendicular_squared))
		var interval_start := maxf(0.0, projection - half_width)
		var interval_end := minf(maximum_distance, projection + half_width)
		if interval_end >= interval_start - EPSILON:
			blocked_intervals.append(Vector2(interval_start, interval_end))
	if blocked_intervals.is_empty():
		return {"point": origin + unit_direction * maximum_distance, "distance": maximum_distance}
	blocked_intervals.sort_custom(func(a: Vector2, b: Vector2) -> bool: return a.x < b.x)
	var merged_intervals: Array[Vector2] = []
	for interval: Vector2 in blocked_intervals:
		if merged_intervals.is_empty() or interval.x > merged_intervals.back().y + EPSILON:
			merged_intervals.append(interval)
		else:
			var previous: Vector2 = merged_intervals.pop_back()
			merged_intervals.append(Vector2(previous.x, maxf(previous.y, interval.y)))
	for interval: Vector2 in merged_intervals:
		if maximum_distance < interval.x - EPSILON or maximum_distance > interval.y + EPSILON: continue
		if interval.x <= EPSILON: return {}
		var safe_distance := maxf(0.0, interval.x - ENDPOINT_EXCLUSION_MARGIN)
		return {"point": origin + unit_direction * safe_distance, "distance": safe_distance}
	return {"point": origin + unit_direction * maximum_distance, "distance": maximum_distance}

static func _region_distance(point: Vector2, region: Rect2, target_radius: float) -> float:
	var nearest := point.clamp(region.position, region.end)
	return maxf(0.0, point.distance_to(nearest) - target_radius)

func _build_graph() -> void:
	if _distances_built: return
	if not _built: _build_waypoint_nodes()
	_distances_built = true
	_distances.clear()
	var origin: Vector2 = _state.units[_model_id].position
	if _nodes.is_empty(): return
	_distances.resize(_nodes.size())
	_distances.fill(INF)
	_distances[0] = 0.0
	var visited: Array[bool] = []
	visited.resize(_nodes.size())
	visited.fill(false)
	for _step in range(_nodes.size()):
		var current := -1
		var current_distance := INF
		for index in range(_nodes.size()):
			if not visited[index] and _distances[index] < current_distance:
				current = index
				current_distance = _distances[index]
		if current < 0 or current_distance > _maximum + EPSILON: break
		visited[current] = true
		for next in range(_nodes.size()):
			if next == current or visited[next]: continue
			var edge_length := _nodes[current].distance_to(_nodes[next])
			if edge_length <= EPSILON or current_distance + edge_length > _maximum + EPSILON: continue
			if current_distance + edge_length >= _distances[next]: continue
			_set_origin(_nodes[current])
			if not Geometry.clear_path(_scratch, _model_id, _nodes[next], edge_length + EPSILON, false, false, -1.0, _move_type): continue
			_distances[next] = current_distance + edge_length

func _build_waypoint_nodes() -> void:
	if _built: return
	_built = true
	_nodes.clear()
	_base_route_nodes.clear()
	_distances.clear()
	var origin: Vector2 = _state.units[_model_id].position
	_add_node(origin, true)
	_add_terrain_nodes(origin)
	_add_model_nodes(origin)
	_base_route_nodes = _nodes.duplicate()

## Add source-surface waypoints at legal ruin-wall access zones. A cross-floor
## route can then reach the access zone on its current floor before making a
## validated final segment to the destination surface.
func _add_vertical_access_nodes(origin: Vector2, edge_subdivisions: int = 0, target_elevation: float = -1.0, target_bounds: Rect2 = Rect2(), preserve_partial_endpoints: bool = false) -> bool:
	var initial_node_count := _nodes.size()
	var model: Dictionary = _state.units[_model_id]
	var radius := maxf(0.0, float(model.get("radius", 0.0)))
	var origin_elevation := float(model.get("elevation", 0.0))
	var terrain_areas := Terrain.areas(_state)
	var access_blockers: Array[Dictionary] = []
	var ignores_vertical := false
	if target_elevation >= 0.0:
		access_blockers = _model_blocking_circles(origin)
		ignores_vertical = Terrain.ignores_vertical_movement(_state, _model_id)
	for surface: Dictionary in Terrain.surfaces(_state):
		if target_elevation >= 0.0 and absf(float(surface.get("elevation", 0.0)) - target_elevation) > EPSILON: continue
		if not Terrain.can_end_on_surface(model, surface): continue
		var area_index := int(surface.get("area_index", -1))
		if area_index < 0 or area_index >= terrain_areas.size(): continue
		var area: Dictionary = terrain_areas[area_index]
		var surface_bounds: Rect2 = surface.get("bounds", Rect2())
		var fit_bounds := Rect2(surface_bounds.position + Vector2.ONE * radius, surface_bounds.size - Vector2.ONE * radius * 2.0)
		if fit_bounds.size.x < -EPSILON or fit_bounds.size.y < -EPSILON: continue
		if target_elevation >= 0.0 and (fit_bounds.end.x < target_bounds.position.x - EPSILON
			or target_bounds.end.x < fit_bounds.position.x - EPSILON
			or fit_bounds.end.y < target_bounds.position.y - EPSILON
			or target_bounds.end.y < fit_bounds.position.y - EPSILON): continue
		for feature_index_value: Variant in surface.get("access_features", []):
			var feature_index := int(feature_index_value)
			if feature_index < 0 or feature_index >= area.get("features", []).size(): continue
			var feature: Dictionary = area.features[feature_index]
			if float(feature.get("height", 0.0)) <= 0.0: continue
			var access_bounds: Rect2 = feature.get("bounds", Rect2()).grow(radius + 0.5 + Terrain.EPSILON)
			var zone := fit_bounds.intersection(access_bounds)
			if zone.size.x < -EPSILON or zone.size.y < -EPSILON: continue
			var candidates: Array[Vector2] = [zone.get_center(), zone.position, Vector2(zone.end.x, zone.position.y), zone.end, Vector2(zone.position.x, zone.end.y)]
			candidates.append(Vector2(zone.get_center().x, zone.position.y))
			candidates.append(Vector2(zone.end.x, zone.get_center().y))
			candidates.append(Vector2(zone.get_center().x, zone.end.y))
			candidates.append(Vector2(zone.position.x, zone.get_center().y))
			var tangent_anchors: Array[Vector2] = [zone.position, Vector2(zone.end.x, zone.position.y),
				zone.end, Vector2(zone.position.x, zone.end.y)]
			if target_elevation >= 0.0:
				var mover_projection := _clamp_point_to_rect(origin, zone)
				candidates.append(mover_projection)
				tangent_anchors.append(mover_projection)
				var nearest_goal_point := _clamp_point_to_rect(zone.get_center(), target_bounds)
				var goal_projection := _clamp_point_to_rect(nearest_goal_point, zone)
				candidates.append(goal_projection)
				tangent_anchors.append(goal_projection)
				# When the direct origin-to-goal segment crosses the portal, its exact
				# entry/exit points can be shorter than projecting either endpoint.
				for contact_point: Vector2 in _segment_rect_intersection_points(origin, nearest_goal_point, zone):
					_append_unique_candidate_point(candidates, contact_point)
					_append_unique_candidate_point(tangent_anchors, contact_point)
				# Route waypoints include terrain corners and blocker tangencies. Their
				# exact projections onto this access zone add portal endpoints between
				# the fixed edge samples; movement geometry still validates each route.
				for route_anchor: Vector2 in _nodes:
					var route_projection := _clamp_point_to_rect(route_anchor, zone)
					_append_unique_candidate_point(candidates, route_projection)
					_append_unique_candidate_point(tangent_anchors, route_projection)
				# A shortest source-surface route may enter the portal on an edge
				# between two blocker/terrain waypoints, not only on an edge from
				# the mover. Add contacts from the bounded route graph; later route
				# checks still validate movement through each candidate.
				_append_route_portal_contacts(candidates, _base_route_nodes, origin, _maximum, zone)
				for blocker: Dictionary in access_blockers:
					for point: Vector2 in _circle_rect_intersections(Vector2(blocker.center), float(blocker.radius), zone):
						_append_unique_candidate_point(candidates, point)
						_append_unique_candidate_point(tangent_anchors, point)
				for anchor: Vector2 in tangent_anchors:
					for blocker: Dictionary in access_blockers:
						for tangent: Vector2 in _circle_tangent_points(anchor, Vector2(blocker.center), float(blocker.radius)):
							_append_unique_candidate_point(candidates, tangent)
			if edge_subdivisions > 1:
				var corners: Array[Vector2] = [zone.position, Vector2(zone.end.x, zone.position.y), zone.end,
					Vector2(zone.position.x, zone.end.y)]
				for edge_index in range(corners.size()):
					var edge_start: Vector2 = corners[edge_index]
					var edge_end: Vector2 = corners[(edge_index + 1) % corners.size()]
					for subdivision in range(1, edge_subdivisions):
						candidates.append(edge_start.lerp(edge_end, float(subdivision) / float(edge_subdivisions)))
			for point: Vector2 in candidates:
				if origin.distance_to(point) > _maximum + EPSILON: continue
				# Exact destination queries need not add access nodes whose optimistic
				# route through this point already exceeds the movement allowance.
				# Closest-region queries keep them because they may lead to a legal
				# partial endpoint before the requested region.
				if target_elevation >= 0.0 and not preserve_partial_endpoints:
					var route_lower_bound := Terrain.movement_distance(origin, origin_elevation,
						point, target_elevation, ignores_vertical) \
						+ _region_distance(point, target_bounds, 0.0)
					if route_lower_bound > _maximum + EPSILON: continue
				_add_node(point)
	if _nodes.size() != initial_node_count:
		_distances_built = false
		_distances.clear()
		_fallback_route_edge_cache.clear()
		return true
	return false

func _distance_via_intermediate_surfaces(destination: Vector2, target_elevation: float, best_route: float) -> float:
	var model: Dictionary = _state.units[_model_id]
	var origin: Vector2 = model.position
	var origin_elevation := float(model.get("elevation", 0.0))
	var current_surface := Terrain.surface_at(_state, model, origin, origin_elevation)
	if current_surface.is_empty(): return best_route
	var visited := _visited_surface_ids.duplicate()
	var current_surface_id := _surface_identity(current_surface)
	if not visited.has(current_surface_id): visited.append(current_surface_id)
	var ignores_vertical := Terrain.ignores_vertical_movement(_state, _model_id)
	var best := best_route
	for surface: Dictionary in Terrain.surfaces(_state):
		var next_elevation := float(surface.get("elevation", 0.0))
		if absf(next_elevation - origin_elevation) <= EPSILON or absf(next_elevation - target_elevation) <= EPSILON: continue
		if visited.has(_surface_identity(surface)) or not Terrain.can_end_on_surface(model, surface): continue
		var vertical_lower_bound := 0.0 if ignores_vertical else absf(next_elevation - origin_elevation) + absf(target_elevation - next_elevation)
		if vertical_lower_bound > _maximum + EPSILON: continue
		var access_points := _vertical_surface_access_points(surface, destination, target_elevation)
		if access_points.is_empty(): continue
		var first_leg_pathfinder: Variant = get_script().new(_state, _model_id, _maximum, _move_type, false, visited)
		for access_point: Vector2 in access_points:
			var optimistic_route := Terrain.movement_distance(origin, origin_elevation, access_point, next_elevation, ignores_vertical) \
				+ Terrain.movement_distance(access_point, next_elevation, destination, target_elevation, ignores_vertical)
			if optimistic_route > _maximum + EPSILON or optimistic_route >= best - EPSILON: continue
			var first_leg: float = float(first_leg_pathfinder.distance_to(access_point, next_elevation))
			if is_inf(first_leg) or first_leg >= best - EPSILON: continue
			var remaining: float = _maximum - first_leg
			if Terrain.movement_distance(access_point, next_elevation, destination, target_elevation, ignores_vertical) > remaining + EPSILON: continue
			var next_state := _state_at_surface(access_point, next_elevation)
			var next_visited := visited.duplicate()
			next_visited.append(_surface_identity(surface))
			var next_pathfinder: Variant = get_script().new(next_state, _model_id, remaining, _move_type, true, next_visited)
			var remaining_route := float(next_pathfinder.distance_to(destination, target_elevation))
			if not is_inf(remaining_route): best = minf(best, first_leg + remaining_route)
	var ground_id := _surface_identity({"id": "ground", "area_index": -1})
	if origin_elevation > EPSILON and target_elevation > EPSILON and not visited.has(ground_id):
		var ground_access_points := _vertical_surface_access_points(current_surface, destination, target_elevation, Rect2(destination, Vector2.ZERO), -1.0, false)
		var ground_first_leg_pathfinder: Variant = get_script().new(_state, _model_id, _maximum, _move_type, false, visited)
		for access_point: Vector2 in ground_access_points:
			var optimistic_route := Terrain.movement_distance(origin, origin_elevation, access_point, 0.0, ignores_vertical) \
				+ Terrain.movement_distance(access_point, 0.0, destination, target_elevation, ignores_vertical)
			if optimistic_route > _maximum + EPSILON or optimistic_route >= best - EPSILON: continue
			var first_leg := float(ground_first_leg_pathfinder.distance_to(access_point, 0.0))
			if is_inf(first_leg) or first_leg >= best - EPSILON: continue
			var remaining := _maximum - first_leg
			if Terrain.movement_distance(access_point, 0.0, destination, target_elevation, ignores_vertical) > remaining + EPSILON: continue
			var next_state := _state_at_surface(access_point, 0.0)
			var next_visited := visited.duplicate()
			next_visited.append(ground_id)
			var next_pathfinder: Variant = get_script().new(next_state, _model_id, remaining, _move_type, true, next_visited)
			var remaining_route := float(next_pathfinder.distance_to(destination, target_elevation))
			if not is_inf(remaining_route): best = minf(best, first_leg + remaining_route)
	return best

func _vertical_surface_access_points(surface: Dictionary, destination: Vector2, target_elevation: float, goal_region: Rect2 = Rect2(), goal_radius: float = -1.0, require_goal_budget: bool = true) -> Array[Vector2]:
	var points: Array[Vector2] = []
	var model: Dictionary = _state.units[_model_id]
	var area_index := int(surface.get("area_index", -1))
	var terrain_areas := Terrain.areas(_state)
	var terrain_surfaces := Terrain.surfaces(_state)
	if area_index < 0 or area_index >= terrain_areas.size(): return points
	var area: Dictionary = terrain_areas[area_index]
	var radius := maxf(0.0, float(model.get("radius", 0.0)))
	var surface_bounds: Rect2 = surface.get("bounds", Rect2())
	var fit_bounds := Rect2(surface_bounds.position + Vector2.ONE * radius, surface_bounds.size - Vector2.ONE * radius * 2.0)
	if fit_bounds.size.x < -EPSILON or fit_bounds.size.y < -EPSILON: return points
	var origin: Vector2 = model.position
	var origin_elevation := float(model.get("elevation", 0.0))
	var ignores_vertical := Terrain.ignores_vertical_movement(_state, _model_id)
	for feature_index_value: Variant in surface.get("access_features", []):
		var feature_index := int(feature_index_value)
		if feature_index < 0 or feature_index >= area.get("features", []).size(): continue
		var feature: Dictionary = area.features[feature_index]
		if float(feature.get("height", 0.0)) <= 0.0: continue
		var access_bounds: Rect2 = feature.get("bounds", Rect2()).grow(radius + 0.5 + Terrain.EPSILON)
		var zone := fit_bounds.intersection(access_bounds)
		if zone.size.x < -EPSILON or zone.size.y < -EPSILON: continue
		var candidates: Array[Vector2] = [zone.get_center(), zone.position, Vector2(zone.end.x, zone.position.y), zone.end,
			Vector2(zone.position.x, zone.end.y), Vector2(zone.get_center().x, zone.position.y), Vector2(zone.end.x, zone.get_center().y),
			Vector2(zone.get_center().x, zone.end.y), Vector2(zone.position.x, zone.get_center().y)]
		# Exact projections add useful transition candidates between fixed edge samples.
		var corners: Array[Vector2] = [zone.position, Vector2(zone.end.x, zone.position.y), zone.end, Vector2(zone.position.x, zone.end.y)]
		var tangent_anchors: Array[Vector2] = corners.duplicate()
		var origin_projection := _clamp_point_to_rect(origin, zone)
		var destination_projection := _clamp_point_to_rect(destination, zone)
		_append_unique_candidate_point(candidates, origin_projection)
		_append_unique_candidate_point(candidates, destination_projection)
		_append_unique_candidate_point(tangent_anchors, origin_projection)
		_append_unique_candidate_point(tangent_anchors, destination_projection)
		var nearest_goal_point := destination
		if goal_radius >= 0.0:
			nearest_goal_point = _clamp_point_to_rect(zone.get_center(), goal_region)
			var goal_projection := _clamp_point_to_rect(nearest_goal_point, zone)
			_append_unique_candidate_point(candidates, goal_projection)
			_append_unique_candidate_point(tangent_anchors, goal_projection)
		for contact_point: Vector2 in _segment_rect_intersection_points(origin, nearest_goal_point, zone):
			_append_unique_candidate_point(candidates, contact_point)
			_append_unique_candidate_point(tangent_anchors, contact_point)
		# Project the existing source-surface route graph onto this convex portal.
		# This supplies access candidates at blocker tangencies and terrain corners
		# that the fixed edge subdivisions do not necessarily sample.
		for route_anchor: Vector2 in _nodes:
			var route_projection := _clamp_point_to_rect(route_anchor, zone)
			_append_unique_candidate_point(candidates, route_projection)
			_append_unique_candidate_point(tangent_anchors, route_projection)
		# Preserve exact portal contacts along edges between source-route
		# waypoints, including paths that have already rounded another blocker.
		_append_route_portal_contacts(candidates, _base_route_nodes, origin, _maximum, zone)
		var access_blockers := _model_blocking_circles(origin)
		for blocker: Dictionary in access_blockers:
			for point: Vector2 in _circle_rect_intersections(Vector2(blocker.center), float(blocker.radius), zone):
				_append_unique_candidate_point(candidates, point)
				_append_unique_candidate_point(tangent_anchors, point)
		for anchor: Vector2 in tangent_anchors:
			for blocker: Dictionary in access_blockers:
				for tangent: Vector2 in _circle_tangent_points(anchor, Vector2(blocker.center), float(blocker.radius)):
					_append_unique_candidate_point(candidates, tangent)
		for edge_index in range(corners.size()):
			var edge_start: Vector2 = corners[edge_index]
			var edge_end: Vector2 = corners[(edge_index + 1) % corners.size()]
			for subdivision in range(1, VERTICAL_ACCESS_EDGE_SUBDIVISIONS):
				candidates.append(edge_start.lerp(edge_end, float(subdivision) / float(VERTICAL_ACCESS_EDGE_SUBDIVISIONS)))
		for point: Vector2 in candidates:
			if point.distance_to(origin) > _maximum + EPSILON: continue
			var remaining_lower_bound := point.distance_to(destination) if goal_radius < 0.0 else _region_distance(point, goal_region, goal_radius)
			var transition_lower_bound := Terrain.movement_distance(origin, origin_elevation, point, float(surface.elevation), ignores_vertical)
			if transition_lower_bound > _maximum + EPSILON: continue
			if require_goal_budget and remaining_lower_bound + transition_lower_bound \
				+ (0.0 if ignores_vertical else absf(target_elevation - float(surface.elevation))) > _maximum + EPSILON: continue
			if _surface_identity_at(terrain_surfaces, model, point, float(surface.elevation)) != _surface_identity(surface): continue
			var duplicate := false
			for existing: Vector2 in points:
				if existing.distance_to(point) <= EPSILON:
					duplicate = true
					break
			if not duplicate: points.append(point)
	return points

func _region_requires_surface_transition(region: Rect2, target_radius: float, target_elevation: float) -> bool:
	var model: Dictionary = _state.units[_model_id]
	var origin_elevation := float(model.get("elevation", 0.0))
	if absf(target_elevation - origin_elevation) > EPSILON: return true
	if target_elevation <= EPSILON: return false
	var origin_surface := Terrain.surface_at(_state, model, model.position, origin_elevation)
	if origin_surface.is_empty(): return false
	var origin_surface_id := _surface_identity(origin_surface)
	var goal_bounds := region.grow(target_radius)
	var base_radius := maxf(0.0, float(model.get("radius", 0.0)))
	for surface: Dictionary in Terrain.surfaces(_state):
		if absf(float(surface.get("elevation", 0.0)) - target_elevation) > EPSILON: continue
		if not Terrain.can_end_on_surface(model, surface) or _surface_identity(surface) == origin_surface_id: continue
		var bounds: Rect2 = surface.get("bounds", Rect2())
		var fit_bounds := Rect2(bounds.position + Vector2.ONE * base_radius, bounds.size - Vector2.ONE * base_radius * 2.0)
		if fit_bounds.size.x < -EPSILON or fit_bounds.size.y < -EPSILON: continue
		if fit_bounds.end.x < goal_bounds.position.x - EPSILON or goal_bounds.end.x < fit_bounds.position.x - EPSILON: continue
		if fit_bounds.end.y < goal_bounds.position.y - EPSILON or goal_bounds.end.y < fit_bounds.position.y - EPSILON: continue
		return true
	return false

static func _surface_identity(surface: Dictionary) -> String:
	return "%s@%d:%d" % [str(surface.get("id", "")), int(surface.get("area_index", -1)), int(surface.get("surface_index", -1))]

func _surface_identity_at(surfaces: Array[Dictionary], model: Dictionary, position: Vector2, elevation: float) -> String:
	if absf(elevation) <= EPSILON:
		return _surface_identity({"id": "ground", "area_index": -1, "surface_index": -1})
	for candidate: Dictionary in surfaces:
		if absf(float(candidate.get("elevation", 0.0)) - elevation) > EPSILON: continue
		if not Terrain.can_end_on_surface(model, candidate): continue
		if not Terrain.surface_contains(model, candidate, position): continue
		return _surface_identity(candidate)
	return ""

func _state_at_surface(position: Vector2, elevation: float) -> Dictionary:
	var next_state := _state.duplicate(false)
	var next_units: Dictionary = _state.units.duplicate(false)
	var next_model: Dictionary = next_units[_model_id].duplicate(false)
	next_model["position"] = position
	next_model["elevation"] = elevation
	next_units[_model_id] = next_model
	next_state["units"] = next_units
	return next_state

static func _clamp_point_to_rect(point: Vector2, bounds: Rect2) -> Vector2:
	var minimum := Vector2(minf(bounds.position.x, bounds.end.x), minf(bounds.position.y, bounds.end.y))
	var maximum := Vector2(maxf(bounds.position.x, bounds.end.x), maxf(bounds.position.y, bounds.end.y))
	return Vector2(clampf(point.x, minimum.x, maximum.x), clampf(point.y, minimum.y, maximum.y))

static func _segment_rect_contact_points(first: Vector2, last: Vector2, bounds: Rect2) -> Array[Vector2]:
	var points: Array[Vector2] = []
	if not first.is_finite() or not last.is_finite() or not bounds.position.is_finite() or not bounds.size.is_finite(): return points
	_append_unique_candidate_point(points, _clamp_point_to_rect(first, bounds))
	_append_unique_candidate_point(points, _clamp_point_to_rect(last, bounds))
	for intersection: Vector2 in _segment_rect_intersection_points(first, last, bounds):
		_append_unique_candidate_point(points, intersection)
	return points

static func _append_route_portal_contacts(candidates: Array[Vector2], route_nodes: Array[Vector2], origin: Vector2,
		maximum_distance: float, portal: Rect2) -> void:
	var route_points: Array[Vector2] = []
	_append_unique_candidate_point(route_points, origin)
	for point: Vector2 in route_nodes:
		_append_unique_candidate_point(route_points, point)
	var reachable_anchor_indices: Array[int] = []
	for route_index in range(route_points.size()):
		var point: Vector2 = route_points[route_index]
		# A path through this waypoint cannot beat its straight-line origin and
		# portal lower bounds. The other end of a route segment may be remote:
		# the segment can cross the portal within budget before reaching it.
		if point.distance_to(origin) + _region_distance(point, portal, 0.0) <= maximum_distance + EPSILON:
			reachable_anchor_indices.append(route_index)
	for anchor_index in reachable_anchor_indices:
		var first: Vector2 = route_points[anchor_index]
		for second_index in range(route_points.size()):
			if second_index == anchor_index: continue
			# Visit a pair only once when both ends are reachable anchors.
			if second_index < anchor_index and second_index in reachable_anchor_indices: continue
			var second: Vector2 = route_points[second_index]
			var segment_bounds := Rect2(Vector2(minf(first.x, second.x), minf(first.y, second.y)),
				Vector2(absf(first.x - second.x), absf(first.y - second.y)))
			if segment_bounds.end.x < portal.position.x - EPSILON or segment_bounds.position.x > portal.end.x + EPSILON \
				or segment_bounds.end.y < portal.position.y - EPSILON or segment_bounds.position.y > portal.end.y + EPSILON: continue
			for contact_point: Vector2 in _segment_rect_intersection_points(first, second, portal):
				if contact_point.distance_to(origin) > maximum_distance + EPSILON: continue
				_append_unique_candidate_point(candidates, contact_point)

static func _segment_rect_intersection_points(first: Vector2, last: Vector2, bounds: Rect2) -> Array[Vector2]:
	var points: Array[Vector2] = []
	if not first.is_finite() or not last.is_finite() or not bounds.position.is_finite() or not bounds.size.is_finite(): return points
	var corners: Array[Vector2] = [bounds.position, Vector2(bounds.end.x, bounds.position.y), bounds.end, Vector2(bounds.position.x, bounds.end.y)]
	for edge_index in range(corners.size()):
		var intersection: Variant = Geometry2D.segment_intersects_segment(
			first, last, corners[edge_index], corners[(edge_index + 1) % corners.size()])
		if intersection is Vector2:
			_append_unique_candidate_point(points, intersection)
	return points

static func _append_unique_candidate_point(points: Array[Vector2], candidate: Vector2) -> void:
	if not candidate.is_finite(): return
	for existing: Vector2 in points:
		if existing.distance_to(candidate) <= EPSILON: return
	points.append(candidate)

func _add_terrain_nodes(origin: Vector2) -> void:
	var model: Dictionary = _state.units[_model_id]
	var expansion := maxf(0.0, float(model.get("radius", 0.0)) - EPSILON) + NODE_CLEARANCE
	for obstacle: Rect2 in Terrain.movement_obstacles(_state, _model_id):
		if origin.distance_to(origin.clamp(obstacle.position, obstacle.end)) > _maximum + expansion: continue
		var bounds := obstacle.grow(expansion)
		_add_node(bounds.position)
		_add_node(Vector2(bounds.end.x, bounds.position.y))
		_add_node(bounds.end)
		_add_node(Vector2(bounds.position.x, bounds.end.y))

func _add_model_nodes(origin: Vector2) -> void:
	var obstacles := _model_blocking_circles(origin)
	var fixed_nodes := _nodes.duplicate()
	for obstacle: Dictionary in obstacles:
		var center: Vector2 = obstacle.center
		var outer_radius := float(obstacle.radius)
		for sample in range(CIRCLE_SAMPLES):
			var angle := float(sample) * TAU / float(CIRCLE_SAMPLES)
			_add_node(center + Vector2.from_angle(angle) * outer_radius)
		for tangent: Vector2 in _circle_tangent_points(origin, center, outer_radius):
			_add_node(tangent)
		for point: Vector2 in fixed_nodes:
			for tangent: Vector2 in _circle_tangent_points(point, center, outer_radius):
				_add_node(tangent)
	for first_index in range(obstacles.size()):
		for second_index in range(first_index + 1, obstacles.size()):
			for pair: Dictionary in _circle_pair_tangents(obstacles[first_index], obstacles[second_index]):
				_add_node(pair.first)
				_add_node(pair.second)

func _model_blocking_circles(origin: Vector2) -> Array[Dictionary]:
	var blockers: Array[Dictionary] = []
	var model: Dictionary = _state.units[_model_id]
	for other_id: int in _state.units:
		if other_id == _model_id: continue
		var other: Dictionary = _state.units[other_id]
		if int(other.get("wounds", 0)) <= 0 or not other.get("on_battlefield", true): continue
		if AircraftRules.is_aircraft(_state, int(other.get("squad", -1))): continue
		var is_enemy := int(other.get("owner", -1)) != int(model.get("owner", -2))
		if not is_enemy and not Geometry.monster_vehicle_move_blocks_large_model(model, other, _move_type): continue
		if is_enemy and Geometry.monster_vehicle_can_pass_enemy_model(model, other, _move_type): continue
		if absf(float(other.get("elevation", 0.0)) - float(model.get("elevation", 0.0))) > EPSILON: continue
		var combined_radius := float(model.get("radius", 0.0)) + float(other.get("radius", 0.0))
		var exact_radius := combined_radius + NODE_CLEARANCE
		var outer_radius := exact_radius / cos(PI / float(CIRCLE_SAMPLES))
		if other.position.distance_to(origin) > _maximum + outer_radius: continue
		blockers.append({"center": Vector2(other.position), "radius": outer_radius, "exact_radius": exact_radius})
	return blockers

static func _circle_tangent_points(point: Vector2, center: Vector2, radius: float) -> Array[Vector2]:
	var offset := point - center
	var distance := offset.length()
	if distance <= radius + EPSILON: return []
	var tangent_angle := acos(clampf(radius / distance, -1.0, 1.0))
	var angle := offset.angle()
	return [center + Vector2.from_angle(angle + tangent_angle) * radius,
		center + Vector2.from_angle(angle - tangent_angle) * radius]

static func _circle_rect_intersections(center: Vector2, radius: float, bounds: Rect2) -> Array[Vector2]:
	var points: Array[Vector2] = []
	if not center.is_finite() or not bounds.position.is_finite() or not bounds.size.is_finite() or radius < 0.0: return points
	for x in [bounds.position.x, bounds.end.x]:
		var horizontal_offset := float(x) - center.x
		var vertical_remainder := radius * radius - horizontal_offset * horizontal_offset
		if vertical_remainder < -EPSILON: continue
		var vertical_offset := sqrt(maxf(0.0, vertical_remainder))
		for y in [center.y - vertical_offset, center.y + vertical_offset]:
			if y < bounds.position.y - EPSILON or y > bounds.end.y + EPSILON: continue
			_append_unique_candidate_point(points, Vector2(float(x), clampf(float(y), bounds.position.y, bounds.end.y)))
	for y in [bounds.position.y, bounds.end.y]:
		var vertical_offset := float(y) - center.y
		var horizontal_remainder := radius * radius - vertical_offset * vertical_offset
		if horizontal_remainder < -EPSILON: continue
		var horizontal_offset := sqrt(maxf(0.0, horizontal_remainder))
		for x in [center.x - horizontal_offset, center.x + horizontal_offset]:
			if x < bounds.position.x - EPSILON or x > bounds.end.x + EPSILON: continue
			_append_unique_candidate_point(points, Vector2(clampf(float(x), bounds.position.x, bounds.end.x), float(y)))
	return points

static func _circle_pair_tangents(first: Dictionary, second: Dictionary) -> Array[Dictionary]:
	var first_center := Vector2(first.get("center", Vector2.ZERO))
	var second_center := Vector2(second.get("center", Vector2.ZERO))
	var first_radius := float(first.get("radius", -1.0))
	var second_radius := float(second.get("radius", -1.0))
	var center_delta := second_center - first_center
	var center_distance := center_delta.length()
	if not first_center.is_finite() or not second_center.is_finite() or is_nan(first_radius) or is_inf(first_radius) or first_radius < 0.0:
		return []
	if is_nan(second_radius) or is_inf(second_radius) or second_radius < 0.0 or center_distance <= EPSILON:
		return []
	var tangents: Array[Dictionary] = []
	var base_angle := center_delta.angle()
	for side in [1.0, -1.0]:
		var cosine: float = (first_radius - float(side) * second_radius) / center_distance
		if absf(cosine) > 1.0 + EPSILON: continue
		var angle_offset := acos(clampf(cosine, -1.0, 1.0))
		for angle_value in [base_angle + angle_offset, base_angle - angle_offset]:
			var angle: float = float(angle_value)
			var normal := Vector2.from_angle(angle)
			tangents.append({
				"first": first_center + normal * first_radius,
				"second": second_center + normal * float(side) * second_radius,
			})
	return tangents

func _add_node(point: Vector2, is_origin: bool = false) -> void:
	if not point.is_finite(): return
	var model: Dictionary = _state.units[_model_id]
	var radius := maxf(0.0, float(model.get("radius", 0.0)))
	var half_board: Vector2 = Vector2(_state.get("board_size", Vector2.ZERO)) / 2.0
	if absf(point.x) > half_board.x - radius + EPSILON or absf(point.y) > half_board.y - radius + EPSILON: return
	if not is_origin:
		var elevation := float(model.get("elevation", 0.0))
		if Terrain.surface_at(_state, model, point, elevation).is_empty(): return
		if point.distance_to(model.position) > _maximum + EPSILON: return
		_set_origin(point)
		if not Geometry.clear_path(_scratch, _model_id, point, 0.0, false, false, -1.0, _move_type): return
	for existing: Vector2 in _nodes:
		if existing.distance_to(point) <= EPSILON: return
	_nodes.append(point)

func _set_origin(point: Vector2) -> void:
	_scratch.units[_model_id]["position"] = point
