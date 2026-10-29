extends RefCounted
## Righteous Zeal Surge choices and Fist of the God-Emperor objective movement.
const Geometry = preload("res://scripts/edition_11/contact_movement.gd")
const Objectives = preload("res://scripts/edition_11/objectives.gd")
const Terrain = preload("res://scripts/edition_11/terrain.gd")
const AbilityCatalog = preload("res://scripts/edition_11/unit_ability_catalog.gd")
const Doctrines = preload("res://scripts/edition_11/combat_doctrines.gd")
const Capabilities = preload("res://scripts/edition_11/capabilities.gd")
const HeresyRetribution = preload("res://scripts/edition_11/heresy_retribution.gd")
const Reachability = preload("res://scripts/edition_11/contact_reachability.gd")
const RandomStat = preload("res://scripts/edition_11/random_characteristic.gd")
const MovementPathfinder = preload("res://scripts/edition_11/movement_pathfinder.gd")

const WINDOW := "crusader-righteous-zeal"
const TARGET_WINDOW := "crusader-righteous-zeal-target"
const PLACEMENT := "crusader-righteous-zeal-placement"
const FIST := "fist-of-the-god-emperor"
const EPSILON := 0.001
const OBJECTIVE_CERTIFICATE_MARGIN := 0.05
const OBJECTIVE_CERTIFICATE_BOX_LIMIT := 16384

static func is_crusader_squad(state: Dictionary, squad: int) -> bool:
	if not state.get("squads", {}).has(squad): return false
	for model: int in Geometry.alive(state, squad):
		if AbilityCatalog.identity(state.units[model]) == "crusader-squad": return true
	return false

static func fist_active(state: Dictionary, player: int) -> bool:
	var chapters: Dictionary = state.get("marine_chapters", {})
	return Doctrines.enabled(state) and Doctrines.detachment_for(state, player) == FIST and str(chapters.get(player, chapters.get(str(player), ""))) == "BLACK TEMPLARS" and Capabilities.enabled(state, "purge-and-sanctify")

static func _engaged(state: Dictionary, squad: int) -> bool:
	return HeresyRetribution._unit_engaged(state, squad)

static func _eligible(state: Dictionary, squad: int) -> bool:
	return is_crusader_squad(state, squad) and AbilityCatalog.enabled(state) and AbilityCatalog.has(state, squad, "righteous-zeal") and not Geometry.alive(state, squad).is_empty() and not bool(state.squads[squad].get("battle_shocked", false)) and not bool(state.squads[squad].get("moved", false)) and not _engaged(state, squad)

static func open_after_enemy_shot(state: Dictionary, shooter: int, pools: Array) -> void:
	if state.get("phase", "") != "shooting" or not state.get("squads", {}).has(shooter) or int(state.squads[shooter].get("owner", -1)) != int(state.get("active", -2)): return
	var casualties: Array[int] = []
	for pool: Dictionary in pools:
		var target := int(pool.get("target_squad", -1))
		if not state.get("squads", {}).has(target) or int(state.squads[target].get("owner", -1)) == int(state.active) or int(pool.get("models_destroyed", 0)) <= 0: continue
		if not _eligible(state, target): continue
		var destroyed_here := false
		for allocation: Dictionary in pool.get("allocations", []):
			var model := int(allocation.get("model", -1))
			if state.get("units", {}).has(model) and int(state.units[model].get("wounds", 0)) <= 0 and int(state.units[model].get("squad", -1)) == target:
				destroyed_here = true
				break
		if destroyed_here and target not in casualties: casualties.append(target)
	if casualties.is_empty(): return
	var previous: Dictionary = state.get("unit_abilities", {}).get("window", {}).duplicate(true)
	state.unit_abilities.window = {"kind": WINDOW, "owners": [3 - int(state.active)], "phase_key": "%d:%s" % [int(state.turn), str(state.phase)], "queue": casualties, "queue_index": 0, "squad": casualties[0], "shooter": shooter, "resume_window": previous}

static func _current_squad(window: Dictionary) -> int:
	var queue: Array = window.get("queue", [])
	var index := int(window.get("queue_index", 0))
	return int(queue[index]) if index >= 0 and index < queue.size() else int(window.get("squad", -1))

static func window_error(state: Dictionary) -> String:
	var window: Dictionary = state.get("unit_abilities", {}).get("window", {})
	if window.get("kind", "") not in [WINDOW, TARGET_WINDOW, PLACEMENT]: return "No Righteous Zeal Surge decision is pending."
	var owners: Array = window.get("owners", [])
	var squad := _current_squad(window)
	if owners.size() != 1 or int(owners[0]) not in [1, 2] or not state.get("squads", {}).has(squad): return "The Righteous Zeal decision has no valid player or Crusader Squad."
	if str(window.get("phase_key", "")) != "%d:%s" % [int(state.turn), str(state.phase)] or state.phase != "shooting" or int(state.active) == int(owners[0]): return "The Righteous Zeal Shooting-phase window has expired."
	if int(state.squads[squad].get("owner", -1)) != int(owners[0]) or not _eligible(state, squad): return "The Crusader Squad is no longer eligible to make a Surge move."
	if window.kind == TARGET_WINDOW:
		if float(window.get("distance", 0.0)) < 1.0: return "Roll Righteous Zeal before selecting a Surge target."
	if window.kind == PLACEMENT:
		var origins: Variant = window.get("origins", {})
		var positions: Variant = window.get("positions", {})
		var origin_elevations: Variant = window.get("origin_elevations", {})
		var elevations: Variant = window.get("elevations", {})
		if not origins is Dictionary or not positions is Dictionary or not origin_elevations is Dictionary or not elevations is Dictionary or positions.size() != Geometry.alive(state, squad).size() or (not elevations.is_empty() and elevations.size() != positions.size()) or (not origin_elevations.is_empty() and origin_elevations.size() != positions.size()): return "The Crusader Squad's placement record is incomplete."
		for model: int in window.positions:
			if not origins.has(model) or typeof(window.positions[model]) != TYPE_VECTOR2 or typeof(origins[model]) != TYPE_VECTOR2: return "The Crusader Squad's placement record is incomplete."
			if (not origin_elevations.is_empty() and (not origin_elevations.has(model) or typeof(origin_elevations[model]) not in [TYPE_INT, TYPE_FLOAT])) or (not elevations.is_empty() and (not elevations.has(model) or typeof(elevations[model]) not in [TYPE_INT, TYPE_FLOAT])): return "The Crusader Squad's placement record is incomplete."
			if (origin_elevations.has(model) and (not is_finite(float(origin_elevations[model])) or float(origin_elevations[model]) < 0.0)) or (elevations.has(model) and (not is_finite(float(elevations[model])) or float(elevations[model]) < 0.0)): return "The Crusader Squad's placement record is incomplete."
		if str(window.get("target_type", "")) == "enemy":
			var target := int(window.get("surge_target", -1))
			if target not in _closest_enemy_targets(state, squad): return "The closest enemy Surge target has changed."
		elif str(window.get("target_type", "")) == "objective":
			var objective := int(window.get("objective", -1))
			if objective not in closest_objectives(state, squad): return "The closest objective for Purge and Sanctify has changed."
		else: return "The Surge move has no valid target."
	return ""

static func _closest_enemy_targets(state: Dictionary, squad: int) -> Array[int]:
	return HeresyRetribution._closest_enemy_targets(state, squad)

static func closest_objectives(state: Dictionary, squad: int) -> Array[int]:
	var result: Array[int] = []
	var objectives: Array = state.get("mission", {}).get("objectives", [])
	var members := Geometry.alive(state, squad)
	if objectives.is_empty() or members.is_empty(): return result
	var closest := INF
	for index in range(objectives.size()):
		var distance := INF
		for model: int in members: distance = minf(distance, Objectives.distance(state.units[model], objectives[index]))
		if distance < closest - EPSILON:
			closest = distance
			result = [index]
		elif absf(distance - closest) <= EPSILON:
			result.append(index)
	return result

static func choices(state: Dictionary, player: int) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var window: Dictionary = state.get("unit_abilities", {}).get("window", {})
	if window.get("kind", "") not in [WINDOW, TARGET_WINDOW, PLACEMENT] or window.get("owners", []) != [player]: return result
	var squad := _current_squad(window)
	if window.kind == WINDOW:
		result.append({"label": "Righteous Zeal: make a Surge move up to D6+1 inches with %s" % str(state.squads[squad].get("name", "Crusader Squad")), "action": "crusader-surge-use", "model": -1, "target": squad, "value": ""})
		result.append({"label": "Pass Righteous Zeal", "action": "crusader-surge-pass", "model": -1, "target": squad, "value": ""})
		return result
	if window.kind == TARGET_WINDOW:
		for target: int in _closest_enemy_targets(state, squad):
			result.append({"label": "Righteous Zeal: surge toward closest enemy %s" % str(state.squads[target].get("name", "unit")), "action": "crusader-surge-enemy", "model": -1, "target": squad, "enemy_target": target, "value": str(target)})
		if fist_active(state, player):
			var objectives: Array = state.get("mission", {}).get("objectives", [])
			for objective: int in closest_objectives(state, squad):
				var name := str(objectives[objective].get("name", "Objective %d" % (objective + 1)))
				result.append({"label": "Purge and Sanctify: surge toward %s instead" % name, "action": "crusader-surge-objective", "model": -1, "target": squad, "value": str(objective)})
		result.append({"label": "Cancel Righteous Zeal", "action": "crusader-surge-pass", "model": -1, "target": squad, "value": ""})
		return result
	for model: int in window.get("positions", {}).keys():
		result.append({"label": "Righteous Zeal: preview model %d" % model, "action": "crusader-surge-place", "model": model, "target": squad, "value": ""})
	result.append({"label": "Reset Righteous Zeal placement", "action": "crusader-surge-reset", "model": -1, "target": squad, "value": ""})
	result.append({"label": "Confirm Righteous Zeal Surge move", "action": "crusader-surge-confirm", "model": -1, "target": squad, "value": ""})
	return result

static func _next_or_resume(state: Dictionary, window: Dictionary) -> void:
	var queue: Array = window.get("queue", []).duplicate()
	var index := int(window.get("queue_index", 0)) + 1
	if index < queue.size():
		window.queue_index = index
		window.squad = int(queue[index])
		window.kind = WINDOW
		for key in ["distance", "roll", "target_type", "surge_target", "objective", "origins", "positions", "origin_elevations", "elevations"]: window.erase(key)
		state.unit_abilities.window = window
	else:
		state.unit_abilities.window = window.get("resume_window", {})

static func apply(state: Dictionary, player: int, selected: Dictionary, point: Vector2, roller: Callable, destination_elevation: float = -1.0) -> Dictionary:
	var window: Dictionary = state.get("unit_abilities", {}).get("window", {})
	var kind := str(window.get("kind", ""))
	var squad := _current_squad(window)
	if kind not in [WINDOW, TARGET_WINDOW, PLACEMENT] or window.get("owners", []) != [player] or int(selected.get("target", -1)) != squad: return {"error": "This Righteous Zeal decision belongs to its current Crusader Squad. " + window_error(state)}
	var blocker := window_error(state)
	if not blocker.is_empty(): return {"error": blocker}
	if kind == PLACEMENT:
		if not window.get("origin_elevations", {}) is Dictionary or window.origin_elevations.is_empty():
			window.origin_elevations = {}
			for model: int in window.origins: window.origin_elevations[model] = float(state.units[model].get("elevation", 0.0))
		if not window.get("elevations", {}) is Dictionary or window.elevations.is_empty(): window.elevations = window.origin_elevations.duplicate(true)
		state.unit_abilities.window = window
	if selected.action == "crusader-surge-pass":
		_next_or_resume(state, window)
		return {"error": ""}
	if kind == WINDOW:
		if selected.action != "crusader-surge-use": return {"error": "Choose to use or pass Righteous Zeal. "}
		var roll := RandomStat.roll("D6", roller)
		if not str(roll.get("error", "")).is_empty(): return roll
		window.kind = TARGET_WINDOW
		window.distance = int(roll.value) + 1
		window.roll = roll.duplicate(true)
		state.unit_abilities.window = window
		return {"error": "", "message": "Righteous Zeal: D6 roll %d; move up to %d inches. Select a closest enemy unit, or use Purge and Sanctify to select the closest objective." % [int(roll.value), int(roll.value) + 1]}
	if kind == TARGET_WINDOW:
		var target_type := ""
		var enemy_target := -1
		var objective := -1
		if selected.action == "crusader-surge-enemy":
			target_type = "enemy"
			enemy_target = int(selected.get("enemy_target", -1))
			if enemy_target not in _closest_enemy_targets(state, squad): return {"error": "Select one of the closest enemy Surge targets."}
			var preflight := HeresyRetribution.preflight_error(state, squad, enemy_target, float(window.distance))
			if not preflight.is_empty(): return {"error": preflight}
		elif selected.action == "crusader-surge-objective":
			target_type = "objective"
			if not fist_active(state, player): return {"error": "Purge and Sanctify requires the Fist of the God-Emperor and Black Templars Chapter context."}
			if not str(selected.get("value", "")).is_valid_int(): return {"error": "Select the closest objective for Purge and Sanctify."}
			objective = int(selected.value)
			if objective not in closest_objectives(state, squad): return {"error": "Select one of the closest objectives."}
		else: return {"error": "Choose a closest enemy Surge target or the Purge and Sanctify objective option."}
		var origins := {}
		var positions := {}
		var origin_elevations := {}
		var elevations := {}
		for model: int in Geometry.alive(state, squad):
			origins[model] = state.units[model].position
			positions[model] = state.units[model].position
			origin_elevations[model] = float(state.units[model].get("elevation", 0.0))
			elevations[model] = float(state.units[model].get("elevation", 0.0))
		window.kind = PLACEMENT
		window.target_type = target_type
		window.surge_target = enemy_target
		window.objective = objective
		window.origins = origins
		window.positions = positions
		window.origin_elevations = origin_elevations
		window.elevations = elevations
		state.unit_abilities.window = window
		return {"error": "", "message": "Preview each Crusader Squad model's Surge move up to %d inches, then confirm." % int(window.distance)}
	if selected.action == "crusader-surge-place":
		var position_error := position_error_for_model(state, int(selected.get("model", -1)), point, destination_elevation)
		if not position_error.is_empty(): return {"error": position_error}
		window.positions[int(selected.model)] = point
		window.elevations[int(selected.model)] = float(state.units[int(selected.model)].get("elevation", 0.0)) if destination_elevation < 0.0 else destination_elevation
		state.unit_abilities.window = window
		return {"error": ""}
	if selected.action == "crusader-surge-reset":
		window.positions = window.origins.duplicate(true)
		window.elevations = window.origin_elevations.duplicate(true)
		state.unit_abilities.window = window
		return {"error": "", "message": "Righteous Zeal placement reset; the Surge roll remains."}
	if selected.action != "crusader-surge-confirm": return {"error": "Preview a model, reset placement, or confirm the Righteous Zeal Surge move."}
	var projected := state.duplicate(true)
	var longest := 0.0
	for model: int in Geometry.alive(state, squad):
		var position_error := position_error_for_model(state, model, Vector2(window.positions[model]), float(window.elevations[model]))
		if not position_error.is_empty(): return {"error": position_error}
		projected.units[model].position = window.positions[model]
		projected.units[model].elevation = window.elevations[model]
		var route := MovementPathfinder.new(state, model, float(window.distance), "surge")
		var route_distance := route.distance_to(Vector2(window.positions[model]), float(window.elevations[model]))
		if is_inf(route_distance): return {"error": "This model has no supported route to its selected destination."}
		longest = maxf(longest, route_distance)
	if not Geometry.coherent(projected, squad): return {"error": "The Righteous Zeal Surge move must preserve unit coherency."}
	var target_error := _target_end_error(state, projected, squad, window)
	if not target_error.is_empty(): return {"error": target_error}
	for model: int in Geometry.alive(projected, squad):
		state.units[model].position = projected.units[model].position
		state.units[model].elevation = projected.units[model].elevation
		state.units[model].moved = true
	state.squads[squad].moved = true
	state.squads[squad].moved_distance = longest
	state.squads[squad].move_type = "surge"
	state.squads[squad].advanced = false
	state.squads[squad].fell_back = false
	var message := "Righteous Zeal Surge move completed; %.2f inches maximum model movement." % longest
	_next_or_resume(state, window)
	return {"error": "", "completed": true, "message": message}

static func position_error_for_model(state: Dictionary, model: int, point: Vector2, destination_elevation: float = -1.0) -> String:
	var window: Dictionary = state.get("unit_abilities", {}).get("window", {})
	if window.get("kind", "") != PLACEMENT or not window.get("positions", {}).has(model): return "Select a model in the pending Righteous Zeal placement."
	if not state.get("units", {}).has(model) or not point.is_finite(): return "Choose a living model and a finite destination."
	var squad := _current_squad(window)
	var unit: Dictionary = state.units[model]
	var current_elevation := float(unit.get("elevation", 0.0))
	var target_elevation := current_elevation if destination_elevation < 0.0 else destination_elevation
	if not is_finite(target_elevation) or target_elevation < 0.0: return "Choose a supported battlefield surface."
	var origin_elevations: Dictionary = window.get("origin_elevations", {})
	var origin_elevation := float(origin_elevations.get(model, current_elevation))
	var move_distance := Terrain.movement_distance(Vector2(window.origins[model]), origin_elevation, point, target_elevation, Terrain.ignores_vertical_movement(state, model))
	if int(unit.get("squad", -1)) != squad or move_distance > float(window.distance) + EPSILON: return "This model exceeds its Righteous Zeal Surge distance."
	var radius := float(unit.get("radius", 0.0))
	if absf(point.x) + radius > float(state.board_size.x) / 2.0 + EPSILON or absf(point.y) + radius > float(state.board_size.y) / 2.0 + EPSILON: return "The whole base must stay on the battlefield."
	var projected := state.duplicate(true)
	var route := MovementPathfinder.new(state, model, float(window.distance), "surge")
	if is_inf(route.distance_to(point, target_elevation)): return "This model cannot reach that destination through terrain and blocking bases within its Surge distance."
	for other: int in state.units:
		if other == model or int(state.units[other].get("wounds", 0)) <= 0 or not state.units[other].get("on_battlefield", true): continue
		var other_position: Vector2 = Vector2(window.positions[other]) if window.positions.has(other) else Vector2(state.units[other].position)
		var pending_elevations: Dictionary = window.get("elevations", {})
		var other_elevation := float(pending_elevations[other]) if pending_elevations.has(other) else float(state.units[other].get("elevation", 0.0))
		if absf(target_elevation - other_elevation) <= EPSILON and point.distance_to(other_position) < radius + float(state.units[other].get("radius", 0.0)) - EPSILON: return "Bases cannot overlap at the destination."
	projected.units[model].position = point
	projected.units[model].elevation = target_elevation
	if window.target_type == "enemy":
		var target := int(window.surge_target)
		var start_gap := Geometry.distance_to_target_at_height(state, unit, target)
		var end_gap := Geometry.distance_to_target_at_height(projected, projected.units[model], target)
		if end_gap >= start_gap - EPSILON:
			var stationary := point.distance_to(Vector2(window.origins[model])) <= EPSILON and absf(target_elevation - origin_elevation) <= EPSILON
			var coherency_state := HeresyRetribution.surge_coherency_state(state, squad, float(window.distance), window.origins)
			if not stationary or not HeresyRetribution._coherent_closest_impossible(coherency_state, model, target, start_gap):
				return "Each model must end closer to the selected Surge target unless it is already as close as possible."
	else:
		var objectives: Array = state.get("mission", {}).get("objectives", [])
		var objective := int(window.objective)
		if objective < 0 or objective >= objectives.size(): return "The selected objective is no longer available."
		var was_in_range := Objectives.in_range(state.units[model], objectives[objective])
		var is_in_range := Objectives.in_range(projected.units[model], objectives[objective])
		if was_in_range and not is_in_range: return "A model that began within objective range must end within range of that objective."
		# A model preview cannot decide the full formation's objective reachability;
		# defer objective distance checks until all model endpoints are confirmed.
	return ""

static func _objective_goal_regions(model: Dictionary, objective: Dictionary, objective_range: bool, maximum_distance: float = 0.0) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if objective.get("kind", "") == "terrain":
		var bounds: Rect2 = objective.get("bounds", Rect2())
		if bounds.size.x < 0.0 or bounds.size.y < 0.0: return result
		var distance := 0.0 if objective_range else maxf(0.0, maximum_distance)
		result.append({
			"kind": "rounded_rect",
			"bounds": bounds,
			"radius": float(model.get("radius", 0.0)) + distance + Terrain.EPSILON + 0.004,
		})
	else:
		var marker_position := Vector2(objective.get("position", model.get("position", Vector2.ZERO)))
		var distance := 3.0 + Terrain.EPSILON if objective_range else maxf(0.0, maximum_distance)
		var goal := {
			"center": marker_position,
			"radius": float(model.get("radius", 0.0)) + Objectives.MARKER_RADIUS + distance + 0.004,
		}
		if objective_range: goal.target_elevation = float(objective.get("elevation", 0.0))
		result.append(goal)
	return result

static func _objective_impossible_in_formation(formation: Dictionary, model: int, objective: Dictionary, objective_range: bool, maximum_distance: float = 0.0, certificate_context: Dictionary = {}) -> bool:
	if not formation.get("units", {}).has(model): return false
	var goals := _objective_goal_regions(formation.units[model], objective, objective_range, maximum_distance)
	if goals.is_empty(): return false
	# Other models are relaxed to any reachable coherent endpoint. Only an
	# impossibility proof is used, so this superset cannot accept an illegal move.
	var proof := Reachability.certify_impossible_for_goals(formation, model, goals, OBJECTIVE_CERTIFICATE_BOX_LIMIT, certificate_context)
	return bool(proof.get("impossible", false))

static func _solo_objective_end_error(original: Dictionary, model: int, finish: Dictionary, objective: Dictionary, maximum: float) -> String:
	var target_region: Rect2
	var target_radius: float
	var reach_threshold := 0.0
	if objective.get("kind", "") == "terrain":
		target_region = objective.get("bounds", Rect2())
		target_radius = float(original.units[model].get("radius", 0.0))
	else:
		target_region = Rect2(Vector2(objective.get("position", finish.position)), Vector2.ZERO)
		target_radius = float(original.units[model].get("radius", 0.0)) + Objectives.MARKER_RADIUS
		reach_threshold = 3.0
	var route := MovementPathfinder.new(original, model, maximum, "surge")
	var target_elevation := float(objective.get("elevation", 0.0))
	var exclusion_circles := HeresyRetribution._enemy_engagement_exclusion_circles(original, model, -1, target_elevation)
	var closest := route.closest_reachable_to_region(target_region, target_radius, Callable(), exclusion_circles, target_elevation)
	var closest_possible := float(closest.get("distance", INF))
	if is_inf(closest_possible): return "This local objective Surge cannot find a supported route for this model."
	if closest_possible <= reach_threshold + 0.03:
		if not Objectives.in_range(finish, objective): return "A model that can reach objective range must end within range of the selected objective."
	elif Objectives.distance(finish, objective) > closest_possible + 0.08:
		return "A model that cannot reach objective range must end as close as possible to the selected objective."
	return ""

static func _target_end_error(original: Dictionary, projected: Dictionary, squad: int, window: Dictionary) -> String:
	if window.target_type == "enemy":
		var target := int(window.surge_target)
		var coherency_state := HeresyRetribution.surge_coherency_state(original, squad, float(window.distance), window.get("origins", {}))
		return HeresyRetribution.enemy_target_end_error(original, projected, squad, target, float(window.distance), coherency_state)
	var objectives: Array = original.get("mission", {}).get("objectives", [])
	var objective := int(window.get("objective", -1))
	if objective < 0 or objective >= objectives.size(): return "The Purge and Sanctify objective is no longer available."
	var formation := HeresyRetribution.surge_coherency_state(original, squad, float(window.get("distance", 0.0)), window.get("origins", {}))
	var certificate_context := Reachability.make_certificate_context(formation)
	for model: int in Geometry.alive(projected, squad):
		var start: Dictionary = original.units[model]
		var finish: Dictionary = projected.units[model]
		if Objectives.in_range(start, objectives[objective]):
			if not Objectives.in_range(finish, objectives[objective]): return "A model already within objective range must remain within range after moving."
			continue
		if Objectives.in_range(finish, objectives[objective]): continue
		if Geometry.alive(formation, squad).size() < 2:
			var solo_error := _solo_objective_end_error(original, model, finish, objectives[objective], float(window.get("distance", 0.0)))
			if not solo_error.is_empty(): return solo_error
			continue
		if not _objective_impossible_in_formation(formation, model, objectives[objective], true, 0.0, certificate_context):
			return "Each model that can reach objective range in a coherent placement must end within range of the selected objective."
		var submitted_distance := Objectives.distance(finish, objectives[objective])
		if submitted_distance > OBJECTIVE_CERTIFICATE_MARGIN and not _objective_impossible_in_formation(
			formation, model, objectives[objective], false, submitted_distance - OBJECTIVE_CERTIFICATE_MARGIN, certificate_context):
			return "Each model that cannot reach objective range must end as close as possible to the selected objective while preserving coherency."
	if HeresyRetribution._unit_engaged(projected, squad): return "Purge and Sanctify cannot end engaged with an enemy unit."
	return ""
