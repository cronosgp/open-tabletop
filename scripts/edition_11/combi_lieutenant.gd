extends RefCounted
## Lieutenant with Combi-weapon rules from the local Wahapedia 11e extraction.
const Geometry = preload("res://scripts/edition_11/contact_movement.gd")
const Terrain = preload("res://scripts/edition_11/terrain.gd")
const Queue = preload("res://scripts/edition_11/fight_queue.gd")
const RandomStat = preload("res://scripts/edition_11/random_characteristic.gd")

static func _identity(state: Dictionary, model: int) -> String:
	return str(state.units.get(model, {}).get("definition_id", "")).get_slice(":", 3)

static func models(state: Dictionary, owner: int) -> Array[int]:
	var result: Array[int] = []
	for model: int in state.units:
		var unit: Dictionary = state.units[model]
		if unit.owner == owner and unit.wounds > 0 and unit.get("on_battlefield", true) and _identity(state, model) == "lieutenant-with-combi-weapon": result.append(model)
	return result

static func priority_choices(state: Dictionary, owner: int) -> Array:
	var result: Array = []
	if state.phase != "command" or state.active != owner: return result
	for model: int in models(state, owner):
		var squad: int = state.units[model].squad
		if state.unit_abilities.used.has("priority-target:%d" % squad): continue
		for feature: Dictionary in Terrain.visible_features(state, model):
			result.append({"label": "Lieutenant %d: identify %s" % [model, feature.label], "action": "priority-target", "model": model, "target": int(feature.area), "value": str(feature.feature)})
	return result

static func select_priority_target(state: Dictionary, player: int, selected: Dictionary) -> String:
	var model: int = int(selected.get("model", -1))
	if state.phase != "command" or state.active != player: return "Priority Target Identified is used in your Command phase."
	if not state.units.has(model) or state.units[model].owner != player or _identity(state, model) != "lieutenant-with-combi-weapon" or state.units[model].wounds <= 0: return "This ability belongs to a living Lieutenant with Combi-weapon."
	var squad: int = state.units[model].squad
	if state.unit_abilities.used.has("priority-target:%d" % squad): return "This unit already used Priority Target Identified this battle."
	if not selected.get("target", -1) is int or not str(selected.get("value", "")).is_valid_int(): return "Select a visible extracted terrain feature."
	var area_index: int = selected.target
	var feature_index: int = int(selected.value)
	var visible := false
	for feature: Dictionary in Terrain.visible_features(state, model):
		if int(feature.area) == area_index and int(feature.feature) == feature_index: visible = true
	if not visible: return "The selected terrain feature is not visible to this Lieutenant."
	state.unit_abilities.used["priority-target:%d" % squad] = true
	var rect: Rect2 = Terrain.areas(state)[area_index].features[feature_index].bounds
	state.unit_abilities.priority_target = {"owner": player, "squad": squad, "area": area_index, "feature": feature_index, "bounds": [rect.position.x, rect.position.y, rect.size.x, rect.size.y], "turn": state.turn}
	return ""

static func priority_feature_contains(state: Dictionary, model: int) -> bool:
	var mark: Dictionary = state.get("unit_abilities", {}).get("priority_target", {})
	if mark.is_empty() or int(mark.get("turn", -1)) != state.turn or not state.units.has(model): return false
	if int(state.units[model].owner) == int(mark.get("owner", -1)): return false
	var areas := Terrain.areas(state)
	var area_index := int(mark.get("area", -1))
	var feature_index := int(mark.get("feature", -1))
	if area_index < 0 or area_index >= areas.size(): return false
	var features: Array = areas[area_index].get("features", [])
	if feature_index < 0 or feature_index >= features.size(): return false
	return Terrain.within(state.units[model], features[feature_index].bounds)

static func open_after_enemy_move(state: Dictionary, moved_squad: int) -> void:
	if state.phase != "movement" or state.active <= 0 or not state.squads.has(moved_squad) or state.squads[moved_squad].owner != state.active: return
	var previous_window: Dictionary = state.unit_abilities.get("window", {}).duplicate(true)
	var queue: Array[Dictionary] = []
	for model: int in models(state, 3 - int(state.active)):
		var squad: int = state.units[model].squad
		if state.squads[squad].get("attached", false) or Queue.engaged(state, squad): continue
		var use_key := "evade:%d:%d:movement" % [squad, state.turn]
		if state.unit_abilities.used.get(use_key, false): continue
		var nearest := INF
		for moved_model: int in Geometry.alive(state, moved_squad):
			nearest = minf(nearest, Geometry.edge(state.units[model], state.units[moved_model]))
		if nearest <= 8.001: queue.append({"model": model, "squad": squad, "trigger": moved_squad})
	queue.sort_custom(func(a: Dictionary, b: Dictionary): return int(a.model) < int(b.model))
	if queue.is_empty(): return
	state.unit_abilities.window = {"kind": "evade-and-survive", "owners": [3 - int(state.active)], "queue": queue, "resume_window": previous_window}

static func choices(state: Dictionary, player: int) -> Array:
	var window: Dictionary = state.get("unit_abilities", {}).get("window", {})
	if window.get("kind", "") not in ["evade-and-survive", "evade-placement"] or int(window.get("owners", [0])[0]) != player: return []
	if window.kind == "evade-and-survive":
		var row: Dictionary = window.queue[0]
		var label := "Lieutenant %d: Evade and Survive (D3+3 inches)" % int(row.model)
		return [
			{"label": label, "action": "evade-use", "model": int(row.model), "target": int(row.squad), "value": ""},
			{"label": "Decline Evade and Survive for this trigger", "action": "evade-pass", "model": int(row.model), "target": int(row.squad), "value": ""}
		]
	var result: Array = []
	for model: int in window.positions:
		result.append({"label": "Evade model %d: preview position" % model, "action": "evade-place", "model": model, "target": int(window.squad), "value": ""})
	result.append({"label": "Confirm Evade and Survive move (up to %d inches)" % int(window.distance), "action": "evade-confirm", "model": -1, "target": int(window.squad), "value": ""})
	return result

static func _advance_queue(state: Dictionary) -> void:
	var queue: Array = state.unit_abilities.window.get("queue", [])
	if not queue.is_empty():
		queue.pop_front()
	if queue.is_empty(): state.unit_abilities.window = state.unit_abilities.window.get("resume_window", {})
	else: state.unit_abilities.window.queue = queue

static func apply(state: Dictionary, player: int, selected: Dictionary, point: Vector2, roller: Callable) -> Dictionary:
	var window: Dictionary = state.unit_abilities.get("window", {})
	var squad: int = int(selected.get("target", -1))
	var model: int = int(selected.get("model", -1))
	if window.get("kind", "") == "evade-and-survive":
		if window.owners[0] != player or window.queue.is_empty(): return {"error": "This Evade and Survive decision belongs to the other player."}
		var row: Dictionary = window.queue[0]
		if squad != int(row.squad) or model != int(row.model): return {"error": "This reaction belongs to the Lieutenant named in the pending decision."}
		if selected.action == "evade-pass":
			_advance_queue(state)
			return {"error": ""}
		if selected.action != "evade-use": return {"error": "Choose to use or decline Evade and Survive."}
		if Queue.engaged(state, squad) or state.units[model].wounds <= 0: return {"error": "Evade and Survive requires this unit to remain alive and unengaged."}
		var roll := RandomStat.roll("D3", roller)
		if not roll.error.is_empty(): return roll
		var origins: Dictionary = {}
		var positions: Dictionary = {}
		for member: int in Geometry.alive(state, squad):
			origins[member] = state.units[member].position
			positions[member] = state.units[member].position
		state.unit_abilities.used["evade:%d:%d:movement" % [squad, state.turn]] = true
		state.unit_abilities.window = {"kind": "evade-placement", "owners": [player], "queue": window.queue.duplicate(true), "resume_window": window.get("resume_window", {}), "squad": squad, "model": model, "trigger": row.trigger, "roll": roll.value, "distance": int(roll.value) + 3, "origins": origins, "positions": positions}
		return {"error": ""}
	if window.get("kind", "") != "evade-placement" or window.owners[0] != player or squad != int(window.squad): return {"error": "No matching Evade and Survive move is pending."}
	match selected.action:
		"evade-place":
			var error := position_error(state, model, point)
			if not error.is_empty(): return {"error": error}
			window.positions[model] = point
		"evade-confirm":
			var projected := state.duplicate(true)
			for member: int in window.positions:
				var error := position_error(state, member, window.positions[member])
				if not error.is_empty(): return {"error": error}
				projected.units[member].position = window.positions[member]
			if not Geometry.coherent(projected, squad): return {"error": "Evade and Survive must leave the unit coherent."}
			if Queue.engaged(projected, squad): return {"error": "Evade and Survive must end unengaged."}
			var moved := false
			for member: int in window.positions:
				if window.origins[member] != window.positions[member]: moved = true
				state.units[member].position = window.positions[member]
				state.units[member].moved = true
			state.unit_abilities.window = window
			_advance_queue(state)
			return {"error": "", "message": "Lieutenant %d used Evade and Survive: D3 %d + 3 inches; %s." % [int(window.model), int(window.roll), "the unit moved" if moved else "the unit stayed in place"]}
		_:
			return {"error": "Unsupported Evade and Survive action."}
	return {"error": ""}

static func position_error(state: Dictionary, model: int, point: Vector2) -> String:
	var window: Dictionary = state.get("unit_abilities", {}).get("window", {})
	if window.get("kind", "") != "evade-placement" or not window.positions.has(model): return "Select a model in the pending Evade and Survive move."
	if not point.is_finite(): return "Choose a finite destination."
	var unit: Dictionary = state.units[model]
	var radius := float(unit.radius)
	if absf(point.x) + radius > state.board_size.x / 2.0 + 0.001 or absf(point.y) + radius > state.board_size.y / 2.0 + 0.001: return "The whole base must stay on the battlefield."
	if Vector2(window.origins[model]).distance_to(point) > float(window.distance) + 0.001: return "This model cannot move more than D3+3 inches rolled for Evade and Survive."
	var projected := state.duplicate(true)
	projected.units[model].position = point
	var terrain_error := Terrain.path_error(projected, model, point)
	if not terrain_error.is_empty(): return terrain_error
	if not Geometry.clear_path(state, model, point, float(window.distance), false): return "This model cannot pass through terrain or blocking enemy bases."
	for other: int in state.units:
		if other == model or state.units[other].wounds <= 0 or not state.units[other].get("on_battlefield", true): continue
		var other_point: Vector2 = window.positions.get(other, state.units[other].position) if window.positions.has(other) else state.units[other].position
		if point.distance_to(other_point) < radius + float(state.units[other].radius) - 0.001: return "Bases cannot overlap at the destination."
	return ""
