extends RefCounted
## Base geometry with bounded elevation, plus sampled straight-line charge suggestions.
## Player-controlled contact paths are validated by contact_actions.gd across supported first-floor surfaces.

const Movement = preload("res://scripts/rules.gd")
const Terrain = preload("res://scripts/edition_11/terrain.gd")
const AircraftRules = preload("res://scripts/edition_11/aircraft_rules.gd")
const EPSILON := 0.001
const MAX_ENGAGEMENT_VERTICAL_DISTANCE := 5.0

static func alive(state: Dictionary, squad: int) -> Array[int]:
	var ids: Array[int] = []
	for id: int in state.units:
		if state.units[id].squad == squad and state.units[id].wounds > 0 and state.units[id].get("on_battlefield", true): ids.append(id)
	return ids

static func edge(first: Dictionary, second: Dictionary) -> float:
	return maxf(0.0, first.position.distance_to(second.position) - float(first.radius) - float(second.radius))

static func within_engagement(first: Dictionary, second: Dictionary) -> bool:
	return edge(first, second) <= 2.0 + EPSILON and absf(float(first.get("elevation", 0.0)) - float(second.get("elevation", 0.0))) <= MAX_ENGAGEMENT_VERTICAL_DISTANCE + EPSILON

static func distance_to_target(state: Dictionary, model: Dictionary, target: int) -> float:
	var distance := INF
	for id: int in alive(state, target): distance = minf(distance, edge(model, state.units[id]))
	return distance

static func distance_to_target_at_height(state: Dictionary, model: Dictionary, target: int, maximum_vertical: float = MAX_ENGAGEMENT_VERTICAL_DISTANCE) -> float:
	var distance := INF
	for id: int in alive(state, target):
		if absf(float(model.get("elevation", 0.0)) - float(state.units[id].get("elevation", 0.0))) > maximum_vertical + EPSILON: continue
		distance = minf(distance, edge(model, state.units[id]))
	return distance

static func coherent(state: Dictionary, squad: int) -> bool:
	var ids := alive(state, squad)
	if ids.size() <= 1: return true
	for id: int in ids:
		var neighbor := false
		for other: int in ids:
			if id == other: continue
			var distance := edge(state.units[id], state.units[other])
			if absf(float(state.units[id].get("elevation", 0.0)) - float(state.units[other].get("elevation", 0.0))) > 5.0 + EPSILON: return false
			if distance > 9.0 + EPSILON: return false
			if distance <= 2.0 + EPSILON: neighbor = true
		if not neighbor: return false
	# Local neighbours alone allow disconnected pairs. Require one component.
	var reached: Dictionary = {ids[0]: true}
	var frontier: Array[int] = [ids[0]]
	while not frontier.is_empty():
		var current: int = frontier.pop_back()
		for other: int in ids:
			if not reached.has(other) and edge(state.units[current], state.units[other]) <= 2.0 + EPSILON and absf(float(state.units[current].get("elevation", 0.0)) - float(state.units[other].get("elevation", 0.0))) <= 5.0 + EPSILON:
				reached[other] = true
				frontier.append(other)
	return reached.size() == ids.size()

static func clear_path(state: Dictionary, model_id: int, destination: Vector2, maximum: float, through_enemies: bool = false, through_models: bool = false, destination_elevation: float = -1.0, move_type: String = "") -> bool:
	var model: Dictionary = state.units[model_id]
	if state.get("squads", {}).get(int(model.get("squad", -1)), {}).get("reiver_grapnel_launchers", false): through_models = true
	if Terrain.take_to_skies_active(state, model_id): through_models = true
	var target_elevation := float(model.get("elevation", 0.0)) if destination_elevation < 0.0 else destination_elevation
	var ignores_vertical := Terrain.ignores_vertical_movement(state, model_id)
	if not destination.is_finite() or Terrain.movement_distance(model.position, float(model.get("elevation", 0.0)), destination, target_elevation, ignores_vertical) > maximum + EPSILON: return false
	var radius: float = model.radius
	var half_board := Movement.half_board(state)
	if absf(destination.x) > half_board.x - radius + EPSILON or absf(destination.y) > half_board.y - radius + EPSILON: return false
	if not Terrain.path_error(state, model_id, destination, target_elevation).is_empty(): return false
	if not through_enemies and not through_models:
		for id: int in state.units:
			if id == model_id: continue
			var other: Dictionary = state.units[id]
			if other.wounds <= 0 or not other.get("on_battlefield", true): continue
			if AircraftRules.is_aircraft(state, int(other.get("squad", -1))): continue
			var is_enemy: bool = other.owner != model.owner
			if not is_enemy and not monster_vehicle_move_blocks_large_model(model, other, move_type): continue
			if is_enemy and monster_vehicle_can_pass_enemy_model(model, other, move_type): continue
			var other_elevation := float(other.get("elevation", 0.0))
			if absf(other_elevation - float(model.get("elevation", 0.0))) > EPSILON and absf(other_elevation - target_elevation) > EPSILON: continue
			var closest := Geometry2D.get_closest_point_to_segment(other.position, model.position, destination)
			if closest.distance_to(other.position) < radius + float(other.radius) - EPSILON: return false
	return true

static func monster_vehicle_move_blocks_large_model(model: Dictionary, other: Dictionary, move_type: String) -> bool:
	if move_type not in ["normal", "advance"]: return false
	return Terrain.has_keyword(model, ["monster", "vehicle"]) and Terrain.has_keyword(other, ["monster", "vehicle"])

static func monster_vehicle_can_pass_enemy_model(model: Dictionary, other: Dictionary, move_type: String) -> bool:
	if move_type not in ["normal", "advance"]: return false
	if not Terrain.has_keyword(model, ["monster", "vehicle"]): return false
	return not Terrain.has_keyword(other, ["monster", "vehicle"])

static func _open_destination(state: Dictionary, model_id: int, destination: Vector2, placed: Dictionary) -> bool:
	var model: Dictionary = state.units[model_id]
	for id: int in placed:
		if absf(float(model.get("elevation", 0.0)) - float(state.units[id].get("elevation", 0.0))) > EPSILON: continue
		if destination.distance_to(placed[id]) < float(model.radius) + float(state.units[id].radius) - EPSILON: return false
	return true

static func _candidates(state: Dictionary, model_id: int, target: int, maximum: float, placed: Dictionary) -> Array[Dictionary]:
	var model: Dictionary = state.units[model_id]
	var candidates: Array[Dictionary] = []
	var old_distance := distance_to_target(state, model, target)
	for enemy_id: int in alive(state, target):
		var enemy: Dictionary = state.units[enemy_id]
		var toward: Vector2 = (model.position - enemy.position).normalized()
		if toward == Vector2.ZERO: toward = Vector2.LEFT
		for gap in [0.03, 0.95, 1.95]:
			var radius: float = float(model.radius) + float(enemy.radius) + gap
			for sample in range(32):
				var direction: Vector2 = toward.rotated(sample * TAU / 32.0)
				var position: Vector2 = enemy.position + direction * radius
				if not _open_destination(state, model_id, position, placed): continue
				if not clear_path(state, model_id, position, maximum): continue
				var projected: Dictionary = model.duplicate(true)
				projected.position = position
				var distance := distance_to_target(state, projected, target)
				if distance >= old_distance - EPSILON: continue
				candidates.append({"position": position, "distance": distance, "travel": model.position.distance_to(position)})
	# A model too far to engage can still move closer, as charge movement requires.
	var closest_id: int = alive(state, target)[0]
	for enemy_id: int in alive(state, target):
		if edge(model, state.units[enemy_id]) < edge(model, state.units[closest_id]): closest_id = enemy_id
	var shift: Vector2 = (state.units[closest_id].position - model.position).normalized() * maximum
	var destination: Vector2 = model.position + shift
	if _open_destination(state, model_id, destination, placed) and clear_path(state, model_id, destination, maximum):
		var projected: Dictionary = model.duplicate(true)
		projected.position = destination
		var distance := distance_to_target(state, projected, target)
		if distance < old_distance - EPSILON: candidates.append({"position": destination, "distance": distance, "travel": maximum})
	return candidates

static func charge_plan(state: Dictionary, squad: int, target: int, maximum: float) -> Dictionary:
	var members := alive(state, squad)
	members.sort_custom(func(a: int, b: int): return distance_to_target(state, state.units[a], target) < distance_to_target(state, state.units[b], target))
	var placed: Dictionary = {}
	for id: int in members:
		var candidates := _candidates(state, id, target, maximum, placed)
		if candidates.is_empty(): return {"error": "No supported straight charge path for every model. Finish this charge without moving."}
		candidates.sort_custom(func(a: Dictionary, b: Dictionary):
			var tier_a := 0 if a.distance <= 1.0 + EPSILON else 1 if a.distance <= 2.0 + EPSILON else 2
			var tier_b := 0 if b.distance <= 1.0 + EPSILON else 1 if b.distance <= 2.0 + EPSILON else 2
			if tier_a != tier_b: return tier_a < tier_b
			return a.travel < b.travel
		)
		placed[id] = candidates[0].position
	var working: Dictionary = state.duplicate(true)
	for id: int in placed: working.units[id].position = placed[id]
	if not coherent(working, squad): return {"error": "Supported charge placement would break coherency; finish without moving."}
	var engaged := false
	for id: int in members:
		for enemy_id: int in alive(working, target):
			if within_engagement(working.units[id], working.units[enemy_id]): engaged = true
	if not engaged:
		return {"error": "Supported charge placement cannot engage the target."}
	return {"error": "", "positions": placed}
