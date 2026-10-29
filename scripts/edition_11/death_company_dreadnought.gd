extends RefCounted
## Death Company Dreadnought sheet effects and its Driven by Fury Surge reaction.
const Geometry = preload("res://scripts/edition_11/contact_movement.gd")
const Terrain = preload("res://scripts/edition_11/terrain.gd")
const MovementPathfinder = preload("res://scripts/edition_11/movement_pathfinder.gd")
const HeresyRetribution = preload("res://scripts/edition_11/heresy_retribution.gd")
const AbilityCatalog = preload("res://scripts/edition_11/unit_ability_catalog.gd")
const RandomStat = preload("res://scripts/edition_11/random_characteristic.gd")

const WINDOW := "death-company-driven-by-fury"
const TARGET_WINDOW := "death-company-driven-by-fury-target"
const PLACEMENT := "death-company-driven-by-fury-placement"
const EPSILON := 0.001

static func _is_dreadnought(state: Dictionary, squad: int) -> bool:
	if not state.get("squads", {}).has(squad) or not AbilityCatalog.enabled(state): return false
	for model: int in Geometry.alive(state, squad):
		var identity := AbilityCatalog.identity(state.units[model])
		if identity == "death-company-dreadnought" and AbilityCatalog.has(state, squad, "driven-by-fury"):
			return true
		if identity == "wulfen-dreadnought" and AbilityCatalog.has(state, squad, "bestial-rage"):
			return true
	return false

static func _rule_name(state: Dictionary, squad: int) -> String:
	for model: int in Geometry.alive(state, squad):
		if AbilityCatalog.identity(state.units[model]) == "wulfen-dreadnought": return "Bestial Rage"
	return "Driven by Fury"

static func _triggered_by_pool(state: Dictionary, target: int, pool: Dictionary) -> bool:
	var identity := ""
	for model: int in state.get("units", {}):
		if int(state.units[model].get("squad", -1)) != target: continue
		identity = AbilityCatalog.identity(state.units[model])
		break
	if identity == "death-company-dreadnought": return int(pool.get("hits", 0)) > 0
	if identity != "wulfen-dreadnought": return false
	for allocation: Dictionary in pool.get("allocations", []):
		if int(allocation.get("damage", 0)) > 0 and state.get("units", {}).has(int(allocation.get("model", -1))) and AbilityCatalog.identity(state.units[int(allocation.model)]) == "wulfen-dreadnought": return true
	return false

static func _eligible(state: Dictionary, squad: int) -> bool:
	return _is_dreadnought(state, squad) and not Geometry.alive(state, squad).is_empty() and not bool(state.squads[squad].get("battle_shocked", false)) and not bool(state.squads[squad].get("moved", false)) and not HeresyRetribution._unit_engaged(state, squad)

static func open_after_enemy_shot(state: Dictionary, shooter: int, pools: Array) -> void:
	if str(state.get("phase", "")) != "shooting" or not state.get("squads", {}).has(shooter) or int(state.squads[shooter].get("owner", -1)) != int(state.get("active", -2)):
		return
	var candidates: Array[int] = []
	for pool: Dictionary in pools:
		var target := int(pool.get("target_squad", -1))
		if not state.get("squads", {}).has(target) or int(state.squads[target].get("owner", -1)) == int(state.active) or not _triggered_by_pool(state, target, pool): continue
		if not _eligible(state, target) or target in candidates: continue
		candidates.append(target)
	if candidates.is_empty(): return
	var previous: Dictionary = state.get("unit_abilities", {}).get("window", {}).duplicate(true)
	state.unit_abilities.window = {"kind": WINDOW, "owners": [int(state.squads[candidates[0]].owner)], "phase_key": "%d:%s" % [int(state.turn), str(state.phase)], "queue": candidates, "queue_index": 0, "squad": candidates[0], "shooter": shooter, "resume_window": previous}

static func _current_squad(window: Dictionary) -> int:
	var queue: Array = window.get("queue", [])
	var index := int(window.get("queue_index", 0))
	return int(queue[index]) if index >= 0 and index < queue.size() else int(window.get("squad", -1))

static func window_error(state: Dictionary) -> String:
	var window: Dictionary = state.get("unit_abilities", {}).get("window", {})
	if window.get("kind", "") not in [WINDOW, TARGET_WINDOW, PLACEMENT]: return "No Surge move decision is pending."
	var owners: Array = window.get("owners", [])
	var squad := _current_squad(window)
	if owners.size() != 1 or int(owners[0]) not in [1, 2] or not state.get("squads", {}).has(squad): return "The pending Surge move has no valid player or unit."
	var rule_name := _rule_name(state, _current_squad(window))
	if str(window.get("phase_key", "")) != "%d:%s" % [int(state.get("turn", 0)), str(state.get("phase", ""))] or str(state.get("phase", "")) != "shooting" or int(state.get("active", -1)) == int(owners[0]): return "The %s Shooting-phase window has expired." % rule_name
	if int(state.squads[squad].get("owner", -1)) != int(owners[0]) or not _eligible(state, squad): return "The unit is no longer eligible to make this Surge move."
	if window.kind == TARGET_WINDOW and (typeof(window.get("distance", null)) != TYPE_INT or int(window.distance) < 1): return "Roll %s before selecting a Surge target." % rule_name
	if window.kind == PLACEMENT:
		var target := int(window.get("surge_target", -1))
		if not state.get("squads", {}).has(target) or int(state.squads[target].get("owner", -1)) == int(owners[0]):
			return "%s has no valid enemy Surge target." % rule_name
		if target not in HeresyRetribution._closest_enemy_targets(state, squad): return "The closest enemy Surge target has changed."
		if typeof(window.get("origins", null)) != TYPE_DICTIONARY or typeof(window.get("positions", null)) != TYPE_DICTIONARY or window.positions.size() != Geometry.alive(state, squad).size(): return "The Dreadnought placement record is incomplete."
	return ""

static func choices(state: Dictionary, player: int) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var window: Dictionary = state.get("unit_abilities", {}).get("window", {})
	if window.get("kind", "") not in [WINDOW, TARGET_WINDOW, PLACEMENT] or window.get("owners", []) != [player]: return result
	var squad := _current_squad(window)
	if not state.get("squads", {}).has(squad): return result
	var rule_name := _rule_name(state, squad)
	if window.kind == WINDOW:
		result.append({"label": "%s: roll D6+1 for a Surge move with %s" % [rule_name, str(state.squads[squad].get("name", "Dreadnought"))], "action": "death-company-fury-use", "model": -1, "target": squad, "value": ""})
		result.append({"label": "Decline %s" % rule_name, "action": "death-company-fury-pass", "model": -1, "target": squad, "value": ""})
		return result
	if window.kind == TARGET_WINDOW:
		for target: int in HeresyRetribution._closest_enemy_targets(state, squad):
			result.append({"label": "%s: surge toward closest enemy %s" % [rule_name, str(state.squads[target].get("name", "unit"))], "action": "death-company-fury-target", "model": -1, "target": squad, "enemy_target": target, "value": str(target)})
		result.append({"label": "Cancel %s" % rule_name, "action": "death-company-fury-pass", "model": -1, "target": squad, "value": ""})
		return result
	for model: int in window.get("positions", {}).keys():
		result.append({"label": "%s: preview model %d" % [rule_name, model], "action": "death-company-fury-place", "model": model, "target": squad, "value": ""})
	result.append({"label": "Reset %s placement" % rule_name, "action": "death-company-fury-reset", "model": -1, "target": squad, "value": ""})
	result.append({"label": "Confirm %s Surge move" % rule_name, "action": "death-company-fury-confirm", "model": -1, "target": squad, "value": ""})
	return result

static func apply(state: Dictionary, player: int, selected: Dictionary, point: Vector2, roller: Callable) -> Dictionary:
	var error := window_error(state)
	if not error.is_empty(): return {"error": error}
	var window: Dictionary = state.unit_abilities.window
	var squad := int(selected.get("target", -1))
	var rule_name := _rule_name(state, _current_squad(window))
	if window.get("owners", []) != [player] or _current_squad(window) != squad: return {"error": "This %s choice belongs to the Dreadnought hit by the pending enemy attacks." % rule_name}
	if window.kind == WINDOW:
		if selected.action == "death-company-fury-pass":
			_advance_queue(state, window)
			return {"error": ""}
		if selected.action != "death-company-fury-use": return {"error": "Choose to use or decline %s." % rule_name}
		var roll := RandomStat.roll("D6", roller)
		if not str(roll.get("error", "")).is_empty(): return roll
		window.kind = TARGET_WINDOW
		window.roll = roll.duplicate(true)
		window.distance = int(roll.value) + 1
		state.unit_abilities.window = window
		return {"error": "", "message": "%s: D6 roll %d; move up to %d inches. Select a closest enemy Surge target." % [rule_name, int(roll.value), int(window.distance)]}
	if window.kind == TARGET_WINDOW:
		if selected.action == "death-company-fury-pass":
			_advance_queue(state, window)
			return {"error": ""}
		if selected.action != "death-company-fury-target": return {"error": "Choose a closest enemy Surge target or cancel %s." % rule_name}
		var target := int(selected.get("enemy_target", -1))
		if target not in HeresyRetribution._closest_enemy_targets(state, squad): return {"error": "Choose one of the closest enemy Surge targets."}
		var origins := {}
		var positions := {}
		for model: int in Geometry.alive(state, squad):
			origins[model] = state.units[model].position
			positions[model] = state.units[model].position
		window.kind = PLACEMENT
		window.surge_target = target
		window.origins = origins
		window.positions = positions
		state.unit_abilities.window = window
		return {"error": "", "message": "Preview the %s Surge move up to %d inches, then confirm." % [rule_name, int(window.distance)]}
	if selected.action == "death-company-fury-pass":
		_advance_queue(state, window)
		return {"error": ""}
	if selected.action == "death-company-fury-place":
		var position_error := position_error_for_model(state, int(selected.get("model", -1)), point)
		if not position_error.is_empty(): return {"error": position_error}
		window.positions[int(selected.model)] = point
		state.unit_abilities.window = window
		return {"error": ""}
	if selected.action == "death-company-fury-reset":
		window.positions = window.origins.duplicate(true)
		state.unit_abilities.window = window
		return {"error": "", "message": "%s placement reset; the roll remains." % rule_name}
	if selected.action != "death-company-fury-confirm": return {"error": "Preview the model, reset placement, confirm, or cancel %s." % rule_name}
	var model := Geometry.alive(state, squad)[0]
	var position_error := position_error_for_model(state, model, Vector2(window.positions[model]))
	if not position_error.is_empty(): return {"error": position_error}
	var projected := state.duplicate(true)
	projected.units[model].position = window.positions[model]
	var route := MovementPathfinder.new(state, model, float(window.distance), "surge")
	var route_distance := route.distance_to(Vector2(window.positions[model]))
	if is_inf(route_distance): return {"error": "The Dreadnought has no supported route to this Surge destination."}
	var target_error := _target_end_error(state, projected, model, int(window.surge_target), float(window.distance), route)
	if not target_error.is_empty(): return {"error": target_error}
	state.units[model].position = window.positions[model]
	state.units[model].moved = true
	state.squads[squad].moved = true
	state.squads[squad].moved_distance = route_distance
	state.squads[squad].move_type = "surge"
	state.squads[squad].advanced = false
	state.squads[squad].fell_back = false
	_advance_queue(state, window)
	return {"error": "", "completed": true, "message": "%s Surge move completed; %.2f inches maximum model movement." % [rule_name, route_distance]}

static func _advance_queue(state: Dictionary, window: Dictionary) -> void:
	var queue: Array = window.get("queue", []).duplicate()
	var next_index := int(window.get("queue_index", 0)) + 1
	if next_index >= queue.size():
		state.unit_abilities.window = window.get("resume_window", {})
		return
	window.queue_index = next_index
	window.squad = int(queue[next_index])
	window.owners = [int(state.squads[window.squad].get("owner", -1))]
	window.kind = WINDOW
	window.erase("roll")
	window.erase("distance")
	window.erase("surge_target")
	window.erase("origins")
	window.erase("positions")
	state.unit_abilities.window = window

static func position_error_for_model(state: Dictionary, model: int, point: Vector2) -> String:
	var window: Dictionary = state.get("unit_abilities", {}).get("window", {})
	if window.get("kind", "") != PLACEMENT or not window.get("positions", {}).has(model): return "Select the Dreadnought model in the pending Surge move."
	if not state.get("units", {}).has(model) or not point.is_finite(): return "Choose a living model and a finite destination."
	var squad := _current_squad(window)
	var unit: Dictionary = state.units[model]
	if int(unit.get("squad", -1)) != squad or Vector2(window.origins[model]).distance_to(point) > float(window.distance) + EPSILON: return "The Dreadnought exceeds its Surge distance."
	var radius := float(unit.get("radius", 0.0))
	if absf(point.x) + radius > float(state.board_size.x) / 2.0 + EPSILON or absf(point.y) + radius > float(state.board_size.y) / 2.0 + EPSILON: return "The whole base must stay on the battlefield."
	var projected := state.duplicate(true)
	projected.units[model].position = point
	var terrain_error := Terrain.path_error(projected, model, point)
	if not terrain_error.is_empty(): return terrain_error
	var route := MovementPathfinder.new(state, model, float(window.distance), "surge")
	if is_inf(route.distance_to(point)): return "The Dreadnought cannot reach that destination through terrain and blocking bases within its Surge distance."
	for other: int in state.units:
		if other == model or int(state.units[other].get("wounds", 0)) <= 0 or not state.units[other].get("on_battlefield", true): continue
		if absf(float(unit.get("elevation", 0.0)) - float(state.units[other].get("elevation", 0.0))) > EPSILON: continue
		if point.distance_to(Vector2(window.positions[other]) if window.positions.has(other) else Vector2(state.units[other].position)) < radius + float(state.units[other].get("radius", 0.0)) - EPSILON:
			return "Bases cannot overlap at the destination."
	var target := int(window.get("surge_target", -1))
	if target not in HeresyRetribution._closest_enemy_targets(state, squad): return "Select one of the closest enemy Surge targets."
	if Geometry.distance_to_target_at_height(projected, projected.units[model], target) >= Geometry.distance_to_target_at_height(state, unit, target) - EPSILON: return "The Dreadnought must end closer to its selected Surge target."
	return ""

static func _target_end_error(original: Dictionary, projected: Dictionary, model: int, target: int, maximum: float, route: Variant) -> String:
	if HeresyRetribution._engaged_with(projected, model, target):
		if HeresyRetribution._engaged_with_other_enemy_at(projected, model, target): return "The Surge move cannot end engaged with an enemy unit other than its selected target."
		return ""
	if HeresyRetribution._can_reach_engagement(original, model, target, maximum, route): return "The Dreadnought must end engaged with the Surge target when it can reach Engagement Range."
	var closest_possible := HeresyRetribution._closest_reachable_distance(original, model, target, maximum, route)
	if is_inf(closest_possible): return "This local Surge move cannot find a supported route to its target."
	if Geometry.distance_to_target_at_height(projected, projected.units[model], target) > closest_possible + 0.08: return "The Dreadnought must end as close as possible to its Surge target."
	if HeresyRetribution._engaged_with_other_enemy_at(projected, model, target): return "The Surge move cannot end engaged with an enemy unit other than its selected target."
	return ""
