extends RefCounted
## Bounded Heresy Begets Retribution Surge Move placement for Vow-sworn Crusaders.
const Geometry = preload("res://scripts/edition_11/contact_movement.gd")
const Terrain = preload("res://scripts/edition_11/terrain.gd")

const WINDOW := "vow-sworn-heresy-retribution-placement"
const EPSILON := 0.001

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
	if typeof(origins_value) != TYPE_DICTIONARY or typeof(positions_value) != TYPE_DICTIONARY:
		return "Cannot continue while Heresy Begets Retribution placement is invalid."
	var living := Geometry.alive(state, squad)
	if origins_value.size() != living.size() or positions_value.size() != living.size(): return "Cannot continue while Heresy Begets Retribution placement is invalid."
	for model: int in living:
		if not origins_value.has(model) or not origins_value[model] is Vector2 or not positions_value.has(model) or not positions_value[model] is Vector2:
			return "Cannot continue while Heresy Begets Retribution placement is invalid."
	return ""

static func _closest_enemy_targets(state: Dictionary, squad: int) -> Array[int]:
	var result: Array[int] = []
	if not state.squads.has(squad) or Geometry.alive(state, squad).is_empty(): return result
	var owner := int(state.squads[squad].get("owner", -1))
	var closest := INF
	for enemy_squad: int in state.squads:
		if int(state.squads[enemy_squad].get("owner", -1)) == owner or Geometry.alive(state, enemy_squad).is_empty(): continue
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
	for model: int in Geometry.alive(state, squad):
		origins[model] = state.units[model].position
		positions[model] = state.units[model].position
	state.unit_abilities.window = {"kind": WINDOW, "owners": [player], "squad": squad, "trigger_squad": trigger_squad,
		"surge_target": surge_target, "distance": float(distance_value), "roll": roll.duplicate(true),
		"origins": origins, "positions": positions, "phase_key": "%d:%s" % [int(state.turn), str(state.phase)],
		"resume_window": parent}
	var shown_rolls: Array = roll.get("rolls", [distance_value])
	var shown_die := int(shown_rolls[0]) if not shown_rolls.is_empty() else int(distance_value)
	return {"error": "", "message": "Heresy Begets Retribution: D6 roll %d; preview the Surge move up to %d inches toward %s, then confirm." % [shown_die, int(distance_value), str(state.squads[surge_target].get("name", "the closest enemy unit"))]}

static func apply(state: Dictionary, player: int, selected: Dictionary, point: Vector2) -> Dictionary:
	var window: Dictionary = state.get("unit_abilities", {}).get("window", {})
	var squad := int(selected.get("target", -1))
	if window.get("kind", "") != WINDOW or window.get("owners", []) != [player] or int(window.get("squad", -1)) != squad:
		return {"error": "No Heresy Begets Retribution Surge move is pending."}
	if str(window.get("phase_key", "")) != "%d:%s" % [int(state.turn), str(state.phase)]:
		return {"error": "The Heresy Begets Retribution Movement phase has changed."}
	if selected.action == "heresy-retribution-place":
		var position_error := position_error_for_model(state, int(selected.get("model", -1)), point)
		if not position_error.is_empty(): return {"error": position_error}
		window.positions[int(selected.model)] = point
		return {"error": ""}
	if selected.action == "heresy-retribution-reset":
		window.positions = window.origins.duplicate(true)
		return {"error": "", "message": "Heresy Begets Retribution placement reset; its CP and D6 roll remain spent."}
	if selected.action != "heresy-retribution-confirm": return {"error": "Preview a model, reset placement, or confirm the Surge move."}
	if Geometry.alive(state, squad).is_empty(): return {"error": "The selected Infantry unit has no surviving models to move."}
	var surge_target := int(window.get("surge_target", -1))
	if not state.squads.has(surge_target) or Geometry.alive(state, surge_target).is_empty(): return {"error": "The selected Surge target is no longer a living enemy unit."}
	var projected := state.duplicate(true)
	var longest := 0.0
	for model: int in window.positions:
		var position_error := position_error_for_model(state, model, Vector2(window.positions[model]))
		if not position_error.is_empty(): return {"error": position_error}
		projected.units[model].position = window.positions[model]
		longest = maxf(longest, Vector2(window.origins[model]).distance_to(Vector2(window.positions[model])))
	var coherency := Geometry.coherent(projected, squad)
	if not coherency: return {"error": "The Surge move must preserve unit coherency."}
	for model: int in Geometry.alive(projected, squad):
		if _engaged_with(projected, model, surge_target): continue
		if _can_reach_engagement(state, model, surge_target, float(window.distance)):
			return {"error": "Each model that can reach Engagement Range of the Surge target must end engaged with it."}
		var closest_possible := _closest_reachable_distance(state, model, surge_target, float(window.distance))
		if is_inf(closest_possible): return {"error": "This local Surge move cannot validate a direct path for every model; choose a supported unobstructed placement."}
		if Geometry.distance_to_target_at_height(projected, projected.units[model], surge_target) > closest_possible + 0.08:
			return {"error": "A model that cannot engage the Surge target must end as close as possible to it."}
	if _engaged_with_other_enemy(projected, squad, surge_target):
		return {"error": "The Surge move cannot end engaged with an enemy unit other than its selected target."}
	for model: int in window.positions:
		state.units[model].position = window.positions[model]
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
	for model: int in Geometry.alive(state, squad):
		if _can_reach_engagement(state, model, surge_target, distance): continue
		if is_inf(_closest_reachable_distance(state, model, surge_target, distance)):
			return "This local Surge move requires a clear direct path for every model; the move can be declined if terrain or bases block that path."
	return ""

static func position_error_for_model(state: Dictionary, model: int, point: Vector2) -> String:
	var window: Dictionary = state.get("unit_abilities", {}).get("window", {})
	if window.get("kind", "") != WINDOW or not window.get("positions", {}).has(model): return "Select a model in the pending Heresy Begets Retribution move."
	if not point.is_finite(): return "Choose a finite destination."
	var unit: Dictionary = state.units[model]
	var squad := int(window.squad)
	var surge_target := int(window.surge_target)
	if not state.squads.has(squad) or not state.squads.has(surge_target): return "The Surge move no longer has a valid unit or target."
	if Vector2(window.origins[model]).distance_to(point) > float(window.distance) + EPSILON: return "This model exceeds its Heresy Begets Retribution D6 move distance."
	var projected := state.duplicate(true)
	projected.units[model].position = point
	if not _inside_board(state, model, point): return "The whole base must stay on the battlefield."
	var terrain_error := Terrain.path_error(projected, model, point)
	if not terrain_error.is_empty(): return terrain_error
	if not Geometry.clear_path(state, model, point, float(window.distance), false, false, -1.0, "surge"):
		return "This model cannot move through terrain or blocking bases along that direct path."
	for other: int in state.units:
		if other == model or int(state.units[other].get("wounds", 0)) <= 0 or not state.units[other].get("on_battlefield", true): continue
		var other_position: Vector2 = Vector2(window.positions[other]) if window.positions.has(other) else Vector2(state.units[other].position)
		if absf(float(unit.get("elevation", 0.0)) - float(state.units[other].get("elevation", 0.0))) <= EPSILON and point.distance_to(other_position) < float(unit.radius) + float(state.units[other].radius) - EPSILON:
			return "Bases cannot overlap at the destination."
	if Geometry.distance_to_target_at_height(projected, projected.units[model], surge_target) >= Geometry.distance_to_target_at_height(state, state.units[model], surge_target) - EPSILON: return "Each model must end closer to the selected Surge target."
	return ""

static func _inside_board(state: Dictionary, model: int, point: Vector2) -> bool:
	var radius := float(state.units[model].get("radius", 0.0))
	return absf(point.x) + radius <= float(state.board_size.x) / 2.0 + EPSILON and absf(point.y) + radius <= float(state.board_size.y) / 2.0 + EPSILON

static func _candidate_clear(state: Dictionary, model: int, target: int, point: Vector2, maximum: float, squad: int, allow_engagement: bool) -> bool:
	if not _inside_board(state, model, point): return false
	var projected := state.duplicate(true)
	projected.units[model].position = point
	if not Terrain.path_error(projected, model, point).is_empty(): return false
	if not Geometry.clear_path(state, model, point, maximum, false, false, -1.0, "surge"): return false
	for other: int in state.units:
		if other == model or int(state.units[other].get("wounds", 0)) <= 0 or not state.units[other].get("on_battlefield", true): continue
		if int(state.units[other].get("squad", -1)) == squad: continue
		if absf(float(state.units[model].get("elevation", 0.0)) - float(state.units[other].get("elevation", 0.0))) > EPSILON: continue
		if point.distance_to(state.units[other].position) < float(state.units[model].radius) + float(state.units[other].radius) - EPSILON: return false
	if _engaged_with_other_enemy_at(projected, model, target): return false
	if not allow_engagement and _engaged_with(projected, model, target): return false
	return true

static func _can_reach_engagement(state: Dictionary, model: int, target: int, maximum: float) -> bool:
	if not state.squads.has(target): return false
	for enemy_model: int in Geometry.alive(state, target):
		if absf(float(state.units[model].get("elevation", 0.0)) - float(state.units[enemy_model].get("elevation", 0.0))) > 5.0 + EPSILON: continue
		var away: Vector2 = (state.units[model].position - state.units[enemy_model].position).normalized()
		if away == Vector2.ZERO: away = Vector2.LEFT
		var radius := float(state.units[model].radius) + float(state.units[enemy_model].radius) + 1.95
		for sample in range(32):
			var point: Vector2 = state.units[enemy_model].position + away.rotated(sample * TAU / 32.0) * radius
			if _candidate_clear(state, model, target, point, maximum, int(state.units[model].squad), true): return true
	return false

static func _closest_reachable_distance(state: Dictionary, model: int, target: int, maximum: float) -> float:
	if not state.squads.has(target): return INF
	var best := INF
	for enemy_model: int in Geometry.alive(state, target):
		if absf(float(state.units[model].get("elevation", 0.0)) - float(state.units[enemy_model].get("elevation", 0.0))) > 5.0 + EPSILON: continue
		var direction: Vector2 = (state.units[enemy_model].position - state.units[model].position).normalized()
		if direction == Vector2.ZERO: continue
		var point: Vector2 = state.units[model].position + direction * maximum
		if not _candidate_clear(state, model, target, point, maximum, int(state.units[model].squad), false): continue
		best = minf(best, Geometry.distance_to_target_at_height(state, {"position": point, "radius": state.units[model].radius, "elevation": state.units[model].get("elevation", 0.0)}, target))
	return best

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
