extends RefCounted
## Bounded Heresy Begets Retribution Surge Move placement for Vow-sworn Crusaders.
const Geometry = preload("res://scripts/edition_11/contact_movement.gd")
const Terrain = preload("res://scripts/edition_11/terrain.gd")
const AircraftRules = preload("res://scripts/edition_11/aircraft_rules.gd")
const MovementPathfinder = preload("res://scripts/edition_11/movement_pathfinder.gd")
const Reachability = preload("res://scripts/edition_11/contact_reachability.gd")

const WINDOW := "vow-sworn-heresy-retribution-placement"
const EPSILON := 0.001
const SURGE_CERTIFICATE_BOX_LIMIT := 4096

static func choices(state: Dictionary, player: int) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var window: Dictionary = state.get("unit_abilities", {}).get("window", {})
	if window.get("kind", "") != WINDOW or window.get("owners", []) != [player]: return result
	var squad := int(window.get("squad", -1))
	for model: int in window.get("positions", {}):
		result.append({"label": "Heresy Begets Retribution: preview model %d" % model, "action": "heresy-retribution-place", "model": model, "target": squad, "value": ""})
	result.append({"label": "Reset Heresy Begets Retribution placement", "action": "heresy-retribution-reset", "model": -1, "target": squad, "value": ""})
	result.append({"label": "Confirm Heresy Begets Retribution Surge move", "action": "heresy-retribution-confirm", "model": -1, "target": squad, "value": ""})
	return result

static func window_error(state: Dictionary) -> String:
	var window: Dictionary = state.get("unit_abilities", {}).get("window", {})
	if window.get("kind", "") != WINDOW: return ""
	var owners_value: Variant = window.get("owners", null)
	var squad_value: Variant = window.get("squad", null)
	var trigger_value: Variant = window.get("trigger_squad", null)
	var target_value: Variant = window.get("surge_target", null)
	if typeof(owners_value) != TYPE_ARRAY or owners_value.size() != 1 or not owners_value[0] is int or not squad_value is int or not trigger_value is int or not target_value is int:
		return "Cannot continue while Heresy Begets Retribution placement is invalid."
	var player := int(owners_value[0])
	var squad := int(squad_value)
	var trigger_squad := int(trigger_value)
	var surge_target := int(target_value)
	if player not in [1, 2] or not state.squads.has(squad) or not state.squads.has(trigger_squad) or not state.squads.has(surge_target):
		return "Cannot continue while Heresy Begets Retribution placement is invalid."
	if int(state.squads[squad].get("owner", -1)) != player or int(state.squads[trigger_squad].get("owner", -1)) != int(state.get("active", -2)):
		return "Cannot continue while Heresy Begets Retribution placement is invalid."
	if int(state.squads[surge_target].get("owner", -1)) == player or bool(state.squads[squad].get("moved", false)) or bool(state.squads[squad].get("battle_shocked", false)):
		return "Cannot continue while Heresy Begets Retribution placement is invalid."
	if str(window.get("phase_key", "")) != "%d:%s" % [int(state.turn), str(state.phase)] or str(state.phase) != "movement":
		return "Cannot continue while Heresy Begets Retribution placement is invalid."
	if Geometry.alive(state, squad).is_empty() or Geometry.alive(state, trigger_squad).is_empty() or Geometry.alive(state, surge_target).is_empty() or _unit_engaged(state, squad):
		return "Cannot continue while Heresy Begets Retribution placement is invalid."
	var within_trigger_range := false
	for model: int in Geometry.alive(state, squad):
		if Geometry.distance_to_target(state, state.units[model], trigger_squad) <= 8.001: within_trigger_range = true
	if not within_trigger_range: return "Cannot continue while Heresy Begets Retribution placement is invalid."
	var parent_value: Variant = window.get("resume_window", null)
	if typeof(parent_value) != TYPE_DICTIONARY or parent_value.get("kind", "") != "detachment-movement-reaction" or parent_value.get("owners", []) != [player] or int(parent_value.get("squad", -1)) != trigger_squad:
		return "Cannot continue while Heresy Begets Retribution placement is invalid."
	var distance_value: Variant = window.get("distance", null)
	var roll_value: Variant = window.get("roll", null)
	if typeof(distance_value) not in [TYPE_INT, TYPE_FLOAT] or float(distance_value) < 1.0 or float(distance_value) > 6.0 or typeof(roll_value) != TYPE_DICTIONARY:
		return "Cannot continue while Heresy Begets Retribution placement is invalid."
	var rolls_value: Variant = roll_value.get("rolls", null)
	if typeof(rolls_value) != TYPE_ARRAY or rolls_value.size() != 1 or not rolls_value[0] is int or int(rolls_value[0]) < 1 or int(rolls_value[0]) > 6 or str(roll_value.get("expression", "")) != "D6" or int(roll_value.get("value", -1)) != int(distance_value):
		return "Cannot continue while Heresy Begets Retribution placement is invalid."
	if surge_target not in _closest_enemy_targets(state, squad): return "Cannot continue while Heresy Begets Retribution placement is invalid."
	var use_found := false
	var uses_value: Variant = state.get("stratagems", {}).get("uses", [])
	if typeof(uses_value) != TYPE_ARRAY: return "Cannot continue while Heresy Begets Retribution placement is invalid."
	for use_value: Variant in uses_value:
		if not use_value is Dictionary: continue
		if int(use_value.get("player", -1)) == player and int(use_value.get("squad", -1)) == squad and str(use_value.get("stratagem", "")) == "vow-sworn-heresy-begets-retribution" and str(use_value.get("phase_key", "")) == "%d:%s" % [int(state.turn), str(state.phase)]: use_found = true
	if not use_found: return "Cannot continue while Heresy Begets Retribution placement is invalid."
	var origins_value: Variant = window.get("origins", null)
	var positions_value: Variant = window.get("positions", null)
	var origin_elevations_value: Variant = window.get("origin_elevations", {})
	var elevations_value: Variant = window.get("elevations", {})
	if typeof(origins_value) != TYPE_DICTIONARY or typeof(positions_value) != TYPE_DICTIONARY or typeof(origin_elevations_value) != TYPE_DICTIONARY or typeof(elevations_value) != TYPE_DICTIONARY:
		return "Cannot continue while Heresy Begets Retribution placement is invalid."
	var living := Geometry.alive(state, squad)
	if origins_value.size() != living.size() or positions_value.size() != living.size() or (not origin_elevations_value.is_empty() and origin_elevations_value.size() != living.size()) or (not elevations_value.is_empty() and elevations_value.size() != living.size()): return "Cannot continue while Heresy Begets Retribution placement is invalid."
	for model: int in living:
		if not origins_value.has(model) or not origins_value[model] is Vector2 or not positions_value.has(model) or not positions_value[model] is Vector2:
			return "Cannot continue while Heresy Begets Retribution placement is invalid."
		if (not origin_elevations_value.is_empty() and (not origin_elevations_value.has(model) or typeof(origin_elevations_value[model]) not in [TYPE_INT, TYPE_FLOAT])) or (not elevations_value.is_empty() and (not elevations_value.has(model) or typeof(elevations_value[model]) not in [TYPE_INT, TYPE_FLOAT])):
			return "Cannot continue while Heresy Begets Retribution placement is invalid."
		if (origin_elevations_value.has(model) and (not is_finite(float(origin_elevations_value[model])) or float(origin_elevations_value[model]) < 0.0)) or (elevations_value.has(model) and (not is_finite(float(elevations_value[model])) or float(elevations_value[model]) < 0.0)):
			return "Cannot continue while Heresy Begets Retribution placement is invalid."
	return ""

static func _closest_enemy_targets(state: Dictionary, squad: int) -> Array[int]:
	var result: Array[int] = []
	if not state.squads.has(squad) or Geometry.alive(state, squad).is_empty(): return result
	var owner := int(state.squads[squad].get("owner", -1))
	var closest := INF
	for enemy_squad: int in state.squads:
		if int(state.squads[enemy_squad].get("owner", -1)) == owner or Geometry.alive(state, enemy_squad).is_empty(): continue
		if AircraftRules.is_aircraft(state, enemy_squad) and not AircraftRules.is_flying(state, squad): continue
		var distance := INF
		for model: int in Geometry.alive(state, squad): distance = minf(distance, Geometry.distance_to_target(state, state.units[model], enemy_squad))
		if distance < closest - EPSILON:
			closest = distance
			result = [enemy_squad]
		elif absf(distance - closest) <= EPSILON:
			result.append(enemy_squad)
	return result

static func begin(state: Dictionary, player: int, squad: int, trigger_squad: int, surge_target: int, roll: Dictionary) -> Dictionary:
	var parent: Dictionary = state.get("unit_abilities", {}).get("window", {}).duplicate(true)
	if parent.get("kind", "") != "detachment-movement-reaction" or parent.get("owners", []) != [player] or int(parent.get("squad", -1)) != trigger_squad:
		return {"error": "Heresy Begets Retribution requires its current post-move reaction."}
	var distance_value: Variant = roll.get("value", -1)
	if not distance_value is int or distance_value < 1 or distance_value > 6:
		return {"error": "Heresy Begets Retribution requires a valid D6 result."}
	var path_error := preflight_error(state, squad, surge_target, float(distance_value))
	if not path_error.is_empty(): return {"error": path_error}
	var origins: Dictionary = {}
	var positions: Dictionary = {}
	var origin_elevations: Dictionary = {}
	var elevations: Dictionary = {}
	for model: int in Geometry.alive(state, squad):
		origins[model] = state.units[model].position
		positions[model] = state.units[model].position
		origin_elevations[model] = float(state.units[model].get("elevation", 0.0))
		elevations[model] = float(state.units[model].get("elevation", 0.0))
	state.unit_abilities.window = {"kind": WINDOW, "owners": [player], "squad": squad, "trigger_squad": trigger_squad,
		"surge_target": surge_target, "distance": float(distance_value), "roll": roll.duplicate(true),
		"origins": origins, "positions": positions, "origin_elevations": origin_elevations, "elevations": elevations, "phase_key": "%d:%s" % [int(state.turn), str(state.phase)],
		"resume_window": parent}
	var shown_rolls: Array = roll.get("rolls", [distance_value])
	var shown_die := int(shown_rolls[0]) if not shown_rolls.is_empty() else int(distance_value)
	return {"error": "", "message": "Heresy Begets Retribution: D6 roll %d; preview the Surge move up to %d inches toward %s, then confirm." % [shown_die, int(distance_value), str(state.squads[surge_target].get("name", "the closest enemy unit"))]}

static func apply(state: Dictionary, player: int, selected: Dictionary, point: Vector2, destination_elevation: float = -1.0) -> Dictionary:
	var window: Dictionary = state.get("unit_abilities", {}).get("window", {})
	var squad := int(selected.get("target", -1))
	if window.get("kind", "") != WINDOW or window.get("owners", []) != [player] or int(window.get("squad", -1)) != squad:
		return {"error": "No Heresy Begets Retribution Surge move is pending."}
	if str(window.get("phase_key", "")) != "%d:%s" % [int(state.turn), str(state.phase)]:
		return {"error": "The Heresy Begets Retribution Movement phase has changed."}
	if not window.get("origin_elevations", {}) is Dictionary or window.origin_elevations.is_empty():
		window.origin_elevations = {}
		for model: int in window.origins: window.origin_elevations[model] = float(state.units[model].get("elevation", 0.0))
	if not window.get("elevations", {}) is Dictionary or window.elevations.is_empty(): window.elevations = window.origin_elevations.duplicate(true)
	state.unit_abilities.window = window
	if selected.action == "heresy-retribution-place":
		var position_error := position_error_for_model(state, int(selected.get("model", -1)), point, destination_elevation)
		if not position_error.is_empty(): return {"error": position_error}
		window.positions[int(selected.model)] = point
		window.elevations[int(selected.model)] = float(state.units[int(selected.model)].get("elevation", 0.0)) if destination_elevation < 0.0 else destination_elevation
		return {"error": ""}
	if selected.action == "heresy-retribution-reset":
		window.positions = window.origins.duplicate(true)
		window.elevations = window.origin_elevations.duplicate(true)
		return {"error": "", "message": "Heresy Begets Retribution placement reset; its CP and D6 roll remain spent."}
	if selected.action != "heresy-retribution-confirm": return {"error": "Preview a model, reset placement, or confirm the Surge move."}
	if Geometry.alive(state, squad).is_empty(): return {"error": "The selected Infantry unit has no surviving models to move."}
	var surge_target := int(window.get("surge_target", -1))
	if not state.squads.has(surge_target) or Geometry.alive(state, surge_target).is_empty(): return {"error": "The selected Surge target is no longer a living enemy unit."}
	var projected := state.duplicate(true)
	var longest := 0.0
	for model: int in window.positions:
		var position_error := position_error_for_model(state, model, Vector2(window.positions[model]), float(window.elevations[model]))
		if not position_error.is_empty(): return {"error": position_error}
		projected.units[model].position = window.positions[model]
		projected.units[model].elevation = window.elevations[model]
		var route := MovementPathfinder.new(state, model, float(window.distance), "surge")
		var route_distance := route.distance_to(Vector2(window.positions[model]), float(window.elevations[model]))
		if is_inf(route_distance): return {"error": "This model has no supported route to its selected destination."}
		longest = maxf(longest, route_distance)
	var coherency := Geometry.coherent(projected, squad)
	if not coherency: return {"error": "The Surge move must preserve unit coherency."}
	var coherency_state := surge_coherency_state(state, squad, float(window.distance), window.origins)
	var target_error := enemy_target_end_error(state, projected, squad, surge_target, float(window.distance), coherency_state)
	if not target_error.is_empty(): return {"error": target_error}
	for model: int in window.positions:
		state.units[model].position = window.positions[model]
		state.units[model].elevation = window.elevations[model]
		state.units[model].moved = true
	state.squads[squad].moved = true
	state.squads[squad].moved_distance = longest
	state.squads[squad].move_type = "surge"
	state.squads[squad].advanced = false
	state.squads[squad].fell_back = false
	state.unit_abilities.window = window.get("resume_window", {})
	return {"error": "", "completed": true, "message": "Heresy Begets Retribution Surge move completed; %.2f inches maximum model movement toward %s." % [longest, str(state.squads[surge_target].get("name", "the surge target"))]}

static func preflight_error(state: Dictionary, squad: int, surge_target: int, distance: float) -> String:
	if not state.squads.has(squad) or not state.squads.has(surge_target): return "Choose a living friendly Infantry unit and a living enemy Surge target."
	var coherency_state := surge_coherency_state(state, squad, distance)
	for model: int in Geometry.alive(state, squad):
		var route := MovementPathfinder.new(state, model, distance, "surge")
		if _can_reach_engagement(state, model, surge_target, distance, route, coherency_state): continue
		if is_inf(_closest_reachable_distance(state, model, surge_target, distance, route)):
			var gap := Geometry.distance_to_target_at_height(state, state.units[model], surge_target)
			if is_inf(gap) or not _coherent_closest_impossible(coherency_state, model, surge_target, gap):
				return "This local Surge move requires a reachable path for every model; the move can be declined if terrain or bases block every route."
	return ""

static func position_error_for_model(state: Dictionary, model: int, point: Vector2, destination_elevation: float = -1.0) -> String:
	var window: Dictionary = state.get("unit_abilities", {}).get("window", {})
	if window.get("kind", "") != WINDOW or not window.get("positions", {}).has(model): return "Select a model in the pending Heresy Begets Retribution move."
	if not point.is_finite(): return "Choose a finite destination."
	var unit: Dictionary = state.units[model]
	var current_elevation := float(unit.get("elevation", 0.0))
	var target_elevation := current_elevation if destination_elevation < 0.0 else destination_elevation
	var squad := int(window.squad)
	var surge_target := int(window.surge_target)
	if not state.squads.has(squad) or not state.squads.has(surge_target): return "The Surge move no longer has a valid unit or target."
	if not is_finite(target_elevation) or target_elevation < 0.0: return "Choose a supported battlefield surface."
	var origin_elevations: Dictionary = window.get("origin_elevations", {})
	var origin_elevation := float(origin_elevations.get(model, current_elevation))
	var move_distance := Terrain.movement_distance(Vector2(window.origins[model]), origin_elevation, point, target_elevation, Terrain.ignores_vertical_movement(state, model))
	if move_distance > float(window.distance) + EPSILON: return "This model exceeds its Heresy Begets Retribution D6 move distance."
	if not _inside_board(state, model, point): return "The whole base must stay on the battlefield."
	var route := MovementPathfinder.new(state, model, float(window.distance), "surge")
	var route_distance := route.distance_to(point, target_elevation)
	if is_inf(route_distance): return "This model cannot reach that destination through terrain and blocking bases within its Surge distance."
	for other: int in state.units:
		if other == model or int(state.units[other].get("wounds", 0)) <= 0 or not state.units[other].get("on_battlefield", true): continue
		var other_position: Vector2 = Vector2(window.positions[other]) if window.positions.has(other) else Vector2(state.units[other].position)
		var pending_elevations: Dictionary = window.get("elevations", {})
		var other_elevation := float(pending_elevations[other]) if pending_elevations.has(other) else float(state.units[other].get("elevation", 0.0))
		if absf(target_elevation - other_elevation) <= EPSILON and point.distance_to(other_position) < float(unit.radius) + float(state.units[other].radius) - EPSILON:
			return "Bases cannot overlap at the destination."
	var projected := state.duplicate(true)
	projected.units[model].position = point
	projected.units[model].elevation = target_elevation
	var start_gap := Geometry.distance_to_target_at_height(state, unit, surge_target)
	var end_gap := Geometry.distance_to_target_at_height(projected, projected.units[model], surge_target)
	if end_gap >= start_gap - EPSILON:
		var stationary := point.distance_to(Vector2(window.origins[model])) <= EPSILON and absf(target_elevation - origin_elevation) <= EPSILON
		var coherency_state := surge_coherency_state(state, squad, float(window.distance), window.origins)
		if not stationary or not _coherent_closest_impossible(coherency_state, model, surge_target, start_gap):
			return "Each model must end closer to the selected Surge target unless it is already as close as possible."
	return ""

static func _inside_board(state: Dictionary, model: int, point: Vector2) -> bool:
	var radius := float(state.units[model].get("radius", 0.0))
	return absf(point.x) + radius <= float(state.board_size.x) / 2.0 + EPSILON and absf(point.y) + radius <= float(state.board_size.y) / 2.0 + EPSILON

static func _candidate_clear(state: Dictionary, model: int, target: int, point: Vector2, maximum: float, squad: int, allow_engagement: bool, route_graph: Variant = null) -> bool:
	if not _inside_board(state, model, point): return false
	var projected := state.duplicate(true)
	projected.units[model].position = point
	if not Terrain.path_error(projected, model, point).is_empty(): return false
	var routes: Variant = route_graph
	if routes == null: routes = MovementPathfinder.new(state, model, maximum, "surge")
	if is_inf(routes.distance_to(point)): return false
	for other: int in state.units:
		if other == model or int(state.units[other].get("wounds", 0)) <= 0 or not state.units[other].get("on_battlefield", true): continue
		if int(state.units[other].get("squad", -1)) == squad: continue
		if absf(float(state.units[model].get("elevation", 0.0)) - float(state.units[other].get("elevation", 0.0))) > EPSILON: continue
		if point.distance_to(state.units[other].position) < float(state.units[model].radius) + float(state.units[other].radius) - EPSILON: return false
	if _engaged_with_other_enemy_at(projected, model, target): return false
	if not allow_engagement and _engaged_with(projected, model, target): return false
	return true

static func surge_coherency_state(state: Dictionary, squad: int, maximum: float, origins_value: Variant = null) -> Dictionary:
	var origins: Dictionary = origins_value if origins_value is Dictionary else {}
	var move_origins: Dictionary = {}
	var engaged: Dictionary = {}
	for model: int in Geometry.alive(state, squad):
		move_origins[model] = Vector2(origins.get(model, state.units[model].position))
		engaged[model] = []
	var analysis_state := state.duplicate(false)
	analysis_state["pending_contact"] = {
		"squad": squad,
		"kind": "surge",
		"maximum": maximum,
		"origins": move_origins,
		"locked": {},
		"engaged": engaged,
	}
	return analysis_state

static func _coherent_closest_impossible(coherency_state: Dictionary, model: int, target: int, edge_distance: float, certificate_context: Dictionary = {}) -> bool:
	if is_inf(edge_distance) or is_nan(edge_distance): return false
	# Keep the proof target 0.05 inches inside the submitted edge distance so
	# the bounded solver can resolve a coherency boundary without guessing.
	var gap := maxf(0.0, edge_distance - 0.05)
	var proof := Reachability.certify_impossible(coherency_state, model, [target], gap, SURGE_CERTIFICATE_BOX_LIMIT, certificate_context)
	return bool(proof.get("impossible", false))

static func _can_reach_engagement(state: Dictionary, model: int, target: int, maximum: float, route_graph: Variant = null, coherency_state: Variant = null) -> bool:
	if not state.squads.has(target): return false
	var formation: Dictionary = coherency_state if coherency_state is Dictionary else surge_coherency_state(state, int(state.units[model].get("squad", -1)), maximum)
	# Unknown/search-limited certificates are treated as reachable, so analysis
	# can never waive the Surge engagement requirement because it ran out of work.
	var proof := Reachability.certify_impossible(formation, model, [target], 2.0)
	return not bool(proof.get("impossible", false))

static func enemy_target_end_error(original: Dictionary, projected: Dictionary, squad: int, target: int, maximum: float, coherency_state: Variant = null) -> String:
	var formation: Dictionary = coherency_state if coherency_state is Dictionary else surge_coherency_state(original, squad, maximum)
	var certificate_context := Reachability.make_certificate_context(formation)
	for model: int in Geometry.alive(projected, squad):
		if _engaged_with(projected, model, target): continue
		var edge_distance := Geometry.distance_to_target_at_height(projected, projected.units[model], target)
		if is_inf(edge_distance): return "This local Surge move cannot verify a target within Engagement Range height."
		if _coherent_closest_impossible(formation, model, target, edge_distance, certificate_context): continue
		var engagement_proof := Reachability.certify_impossible(formation, model, [target], 2.0, SURGE_CERTIFICATE_BOX_LIMIT, certificate_context)
		if not bool(engagement_proof.get("impossible", false)):
			return "Each model that can reach Engagement Range of the Surge target in a coherent placement must end engaged with it."
		return "A model that cannot engage the Surge target must end as close as possible to it."
	if _engaged_with_other_enemy(projected, squad, target):
		return "The Surge move cannot end engaged with an enemy unit other than its selected target."
	return ""

static func _closest_reachable_distance(state: Dictionary, model: int, target: int, maximum: float, route_graph: Variant = null) -> float:
	if not state.squads.has(target): return INF
	var routes: Variant = route_graph
	if routes == null: routes = MovementPathfinder.new(state, model, maximum, "surge")
	var best := INF
	var mover: Dictionary = state.units[model]
	var initial_edge := Geometry.distance_to_target_at_height(state, mover, target)
	for enemy_model: int in Geometry.alive(state, target):
		var enemy: Dictionary = state.units[enemy_model]
		var exclusion_circles := _enemy_engagement_exclusion_circles(state, model, -1, float(enemy.get("elevation", 0.0)))
		var region := Rect2(Vector2(enemy.position), Vector2.ZERO)
		var radius := float(mover.radius) + float(enemy.radius) + 2.01
		var closest: Dictionary = routes.closest_reachable_to_region(region, radius, Callable(), exclusion_circles, float(enemy.get("elevation", 0.0)))
		var point := Vector2(closest.get("point", Vector2.ZERO))
		if is_inf(float(closest.get("distance", INF))): continue
		var projected_model: Dictionary = mover.duplicate(false)
		projected_model.position = point
		projected_model.elevation = float(closest.get("elevation", enemy.get("elevation", 0.0)))
		var remaining := Geometry.distance_to_target_at_height(state, projected_model, target)
		if remaining < initial_edge - EPSILON: best = minf(best, remaining)
	return best

static func _enemy_engagement_exclusion_circles(state: Dictionary, model: int, excluded_squad: int = -1, destination_elevation: float = -1.0) -> Array[Dictionary]:
	var circles: Array[Dictionary] = []
	if not state.get("units", {}).has(model): return circles
	var mover: Dictionary = state.units[model]
	var endpoint_elevation := float(mover.get("elevation", 0.0)) if destination_elevation < 0.0 else destination_elevation
	for enemy_squad: int in state.get("squads", {}):
		if enemy_squad == excluded_squad: continue
		var squad: Dictionary = state.squads[enemy_squad]
		if int(squad.get("owner", -1)) == int(mover.get("owner", -2)): continue
		for enemy_model: int in Geometry.alive(state, enemy_squad):
			var enemy: Dictionary = state.units[enemy_model]
			if absf(endpoint_elevation - float(enemy.get("elevation", 0.0))) > 5.0 + EPSILON: continue
			circles.append({
				"center": Vector2(enemy.get("position", Vector2.ZERO)),
				"radius": float(mover.get("radius", 0.0)) + float(enemy.get("radius", 0.0)) + 2.0 + EPSILON,
			})
	return circles

static func _engaged_with(state: Dictionary, model: int, target: int) -> bool:
	for enemy_model: int in Geometry.alive(state, target):
		if Geometry.within_engagement(state.units[model], state.units[enemy_model]): return true
	return false

static func _unit_engaged(state: Dictionary, squad: int) -> bool:
	for model: int in Geometry.alive(state, squad):
		for enemy_squad: int in state.squads:
			if int(state.squads[enemy_squad].get("owner", -1)) == int(state.squads[squad].get("owner", -2)): continue
			for enemy_model: int in Geometry.alive(state, enemy_squad):
				if Geometry.within_engagement(state.units[model], state.units[enemy_model]): return true
	return false

static func _engaged_with_other_enemy_at(state: Dictionary, model: int, target: int) -> bool:
	for enemy_squad: int in state.squads:
		if enemy_squad == target or int(state.squads[enemy_squad].get("owner", -1)) == int(state.units[model].get("owner", -2)): continue
		for enemy_model: int in Geometry.alive(state, enemy_squad):
			if Geometry.within_engagement(state.units[model], state.units[enemy_model]): return true
	return false

static func _engaged_with_other_enemy(state: Dictionary, squad: int, surge_target: int) -> bool:
	for model: int in Geometry.alive(state, squad):
		for enemy_squad: int in state.squads:
			if enemy_squad == surge_target or int(state.squads[enemy_squad].get("owner", -1)) == int(state.squads[squad].get("owner", -2)): continue
			for enemy_model: int in Geometry.alive(state, enemy_squad):
				if Geometry.within_engagement(state.units[model], state.units[enemy_model]): return true
	return false
