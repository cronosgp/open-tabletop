extends RefCounted
## Certificates of impossibility, not a sampled route search. Every relaxation
## enlarges legal movement/placement space; only an empty relaxation waives a rule.
const Board = preload("res://scripts/rules.gd")
const Geometry = preload("res://scripts/edition_11/contact_movement.gd")
const Terrain = preload("res://scripts/edition_11/terrain.gd")
const PADDING := 0.004
const CERTIFICATE_MARGIN := 0.02
const BOX_LIMIT := 1024
const MIN_BOX_WIDTH := 0.02

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

static func _rect_distance(first: Rect2, second: Rect2) -> float:
	return Vector2(maxf(0, maxf(first.position.x - second.end.x, second.position.x - first.end.x)), maxf(0, maxf(first.position.y - second.end.y, second.position.y - first.end.y))).length()

static func _point_distance(point: Vector2, rect: Rect2) -> float:
	return point.distance_to(point.clamp(rect.position, rect.end))

static func _intersection(first: Rect2, second: Rect2) -> Rect2:
	var start := first.position.max(second.position)
	var end := first.end.min(second.end)
	return Rect2(start, end - start)

static func _empty(rect: Rect2) -> bool:
	return rect.size.x < 0 or rect.size.y < 0

static func _obstacles(radius: float, state: Dictionary = {}, model: int = -1) -> Array[Rect2]:
	var obstacles: Array[Rect2] = []
	# Each expanded rectangle is INSIDE the rounded Minkowski sum of the
	# actual rectangle and circular base. Growing both axes by the whole
	# radius would overestimate corner obstructions and be unsafe as proof.
	var features: Array = Board.TERRAIN
	if model != -1: features = Terrain.movement_obstacles(state, model)
	for rect: Rect2 in features:
		for angle in [0.0, PI / 6.0, PI / 4.0, PI / 3.0, PI / 2.0]:
			var extent := Vector2(cos(angle), sin(angle)) * maxf(0.0, radius - PADDING)
			obstacles.append(Rect2(rect.position - extent, rect.size + extent * 2.0))
	return obstacles

static func terrain_lower_bound(origin: Vector2, radius: float, goal: Rect2, state: Dictionary = {}, model: int = -1) -> float:
	# Exact visibility graph for a relaxed rectangular configuration space.
	# The goal square encloses the target disk; enemy bases and board bounds
	# are omitted. Therefore this distance cannot certify a false obstruction.
	var obstacles := _obstacles(radius, state, model)
	if _blocked(origin, obstacles): return 0.0 # Invalid/unsupported origin: no certificate.
	var vertices: Array[Vector2] = [origin]
	for rect: Rect2 in obstacles:
		for point: Vector2 in _corners(rect):
			if not _blocked(point, obstacles): vertices.append(point)
	var goals: Array[Vector2] = _corners(goal)
	for vertex: Vector2 in vertices: goals.append(vertex.clamp(goal.position, goal.end))
	# Clipped obstacle boundaries can form additional goal-region vertices.
	for rect: Rect2 in obstacles:
		for x in [rect.position.x, rect.end.x]:
			for y in [goal.position.y, goal.end.y]:
				if x >= goal.position.x and x <= goal.end.x and y >= rect.position.y and y <= rect.end.y: goals.append(Vector2(x, y))
		for y in [rect.position.y, rect.end.y]:
			for x in [goal.position.x, goal.end.x]:
				if y >= goal.position.y and y <= goal.end.y and x >= rect.position.x and x <= rect.end.x: goals.append(Vector2(x, y))
	for point: Vector2 in goals:
		if not _blocked(point, obstacles): vertices.append(point)
	var distances: Array[float] = []
	var visited: Dictionary = {}
	for index in range(vertices.size()): distances.append(0.0 if index == 0 else INF)
	for iteration in range(vertices.size()):
		var current := -1
		var shortest := INF
		for index in range(vertices.size()):
			if not visited.has(index) and distances[index] < shortest:
				current = index
				shortest = distances[index]
		if current == -1: break
		if _point_distance(vertices[current], goal) < 0.000001: return shortest
		visited[current] = true
		for other in range(vertices.size()):
			if visited.has(other): continue
			var proposed: float = shortest + vertices[current].distance_to(vertices[other])
			if proposed < distances[other] and _visible(vertices[current], vertices[other], obstacles): distances[other] = proposed
	return INF

static func _goal_disks(state: Dictionary, model: int, targets: Array[int], gap: float) -> Array[Dictionary]:
	var disks: Array[Dictionary] = []
	for target: int in targets:
		for enemy: int in Geometry.alive(state, target):
			disks.append({"center": state.units[enemy].position, "radius": float(state.units[model].radius) + float(state.units[enemy].radius) + gap + PADDING})
	return disks

static func _disk_box(disk: Dictionary) -> Rect2:
	return Rect2(disk.center - Vector2.ONE * disk.radius, Vector2.ONE * disk.radius * 2)

static func _intersects_disks(box: Rect2, disks: Array[Dictionary]) -> bool:
	for disk: Dictionary in disks:
		if _point_distance(disk.center, box) <= float(disk.radius): return true
	return false

static func _disk_set_distance(first: Array[Dictionary], second: Array[Dictionary]) -> float:
	var distance := INF
	for a: Dictionary in first:
		for b: Dictionary in second:
			distance = minf(distance, maxf(0.0, a.center.distance_to(b.center) - float(a.radius) - float(b.radius)))
	return distance

static func _domain_valid(state: Dictionary, move: Dictionary, ids: Array[int], boxes: Array[Rect2], focus: int, goals: Array[Dictionary], retention: Dictionary, pair_bounds: Array[Array]) -> bool:
	for index in range(ids.size()):
		var id: int = ids[index]
		var allowance := 0.0 if move.locked.has(id) else float(move.maximum)
		if _point_distance(move.origins[id], boxes[index]) > allowance + PADDING: return false
		if id == focus and not _intersects_disks(boxes[index], goals): return false
		for disks: Array[Dictionary] in retention[id]:
			if not _intersects_disks(boxes[index], disks): return false
		for rect: Rect2 in _obstacles(float(state.units[id].radius), state, id):
			if _inside(boxes[index].position, rect) and _inside(boxes[index].end, rect): return false
	# Coherency requires both the diameter bound and one connected graph.
	var graph: Array[Array] = []
	for index in range(ids.size()): graph.append([])
	for first in range(ids.size()):
		for second in range(first + 1, ids.size()):
			var radii: float = float(state.units[ids[first]].radius) + float(state.units[ids[second]].radius)
			var distance := maxf(_rect_distance(boxes[first], boxes[second]), float(pair_bounds[first][second]))
			if distance > radii + 9.0 + PADDING: return false
			if distance <= radii + 2.0 + PADDING:
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

static func certify_impossible(state: Dictionary, model: int, targets: Array[int], gap: float, box_limit: int = BOX_LIMIT) -> Dictionary:
	var move: Dictionary = state.pending_contact
	if not move.origins.has(model) or not state.units.has(model) or state.units[model].wounds <= 0:
		return {"impossible": false, "reason": "invalid_model"}
	var goals := _goal_disks(state, model, targets, gap)
	if goals.is_empty(): return {"impossible": false, "reason": "no_target"}
	var lower_bound := INF
	for goal: Dictionary in goals:
		lower_bound = minf(lower_bound, terrain_lower_bound(move.origins[model], float(state.units[model].radius), _disk_box(goal), state, model))
	if lower_bound > float(move.maximum) + CERTIFICATE_MARGIN:
		return {"impossible": true, "reason": "terrain_route", "lower_bound": lower_bound, "nodes": 0}
	var ids := Geometry.alive(state, move.squad)
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
	var stack: Array[Array] = []
	var focus := ids.find(model)
	# Circular constraints are stronger than their bounding boxes, especially
	# where a locked anchor and a retained enemy are diagonally separated.
	var constraint_sets: Array[Array] = []
	for id: int in ids:
		var origin_disk: Array[Dictionary] = [{"center": move.origins[id], "radius": PADDING if move.locked.has(id) else float(move.maximum) + PADDING}]
		var sets: Array = [origin_disk]
		for disks: Array[Dictionary] in retention[id]: sets.append(disks)
		if id == model: sets.append(goals)
		constraint_sets.append(sets)
	var pair_bounds: Array[Array] = []
	for first in range(ids.size()):
		var row: Array[float] = []
		for second in range(ids.size()):
			var bound := 0.0
			for a: Array[Dictionary] in constraint_sets[first]:
				for b: Array[Dictionary] in constraint_sets[second]: bound = maxf(bound, _disk_set_distance(a, b))
			row.append(bound)
		pair_bounds.append(row)
	for goal: Dictionary in goals:
		var root: Array[Rect2] = boxes.duplicate()
		root[focus] = _intersection(root[focus], _disk_box(goal))
		if not _empty(root[focus]): stack.append(root)
	var nodes := 0
	while not stack.is_empty():
		if nodes >= box_limit: return {"impossible": false, "reason": "search_limit", "nodes": nodes}
		var domain: Array[Rect2] = []
		domain.assign(stack.pop_back())
		nodes += 1
		if not _domain_valid(state, move, ids, domain, model, goals, retention, pair_bounds): continue
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
		stack.append(left)
		stack.append(right)
	return {"impossible": true, "reason": "coherent_placement", "nodes": nodes}
