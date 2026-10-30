extends RefCounted
## Source-bounded Space Marines Fortification interactions in ground-level base geometry.
const EPSILON := 0.001
const SIGHT_RADIUS := 0.5 / 25.4

static func _identity(unit: Dictionary) -> String:
	for key: String in ["definition_id", "source_id", "identity", "id"]:
		var value := str(unit.get(key, ""))
		if value.is_empty(): continue
		return value.get_slice(":", 3) if value.contains(":") else value
	return ""

static func _has_keyword(unit: Dictionary, keyword: String) -> bool:
	var values: Variant = unit.get("keywords", [])
	if not values is Array: return false
	for value: Variant in values:
		if str(value).strip_edges().to_upper() == keyword.to_upper(): return true
	return false

static func _living(state: Dictionary, squad: int) -> Array[int]:
	var result: Array[int] = []
	for model: int in state.get("units", {}):
		var unit: Dictionary = state.units[model]
		if int(unit.get("squad", -1)) == squad and int(unit.get("wounds", 0)) > 0 and bool(unit.get("on_battlefield", true)): result.append(model)
	return result

static func _engaged(state: Dictionary, first_squad: int, second_squad: int) -> bool:
	for first_id: int in _living(state, first_squad):
		var first: Dictionary = state.units[first_id]
		for second_id: int in _living(state, second_squad):
			var second: Dictionary = state.units[second_id]
			if absf(float(first.get("elevation", 0.0)) - float(second.get("elevation", 0.0))) > 5.0: continue
			var edge_distance: float = first.position.distance_to(second.position) - float(first.get("radius", 0.0)) - float(second.get("radius", 0.0))
			if edge_distance <= 1.0 + EPSILON: return true
	return false

static func target_engaged_only_with_hammerfall_fortifications(state: Dictionary, target_squad: int, supporting_owner: int = -1) -> bool:
	if not state.get("squads", {}).has(target_squad) or _living(state, target_squad).is_empty(): return false
	var target_owner := int(state.squads[target_squad].get("owner", -1))
	var has_supporting_hammerfall := false
	for other_squad: int in state.squads:
		if other_squad == target_squad or int(state.squads[other_squad].get("owner", -2)) == target_owner: continue
		var members := _living(state, other_squad)
		if members.is_empty() or not _engaged(state, target_squad, other_squad): continue
		if not _has_keyword(state.units[members[0]], "FORTIFICATION"): return false
		if _identity(state.units[members[0]]) == "hammerfall-bunker" and (supporting_owner < 0 or int(state.squads[other_squad].get("owner", -2)) == supporting_owner):
			has_supporting_hammerfall = true
	return has_supporting_hammerfall

static func fall_back_hazard_auto_pass(state: Dictionary, target_squad: int) -> bool:
	if not state.get("squads", {}).has(target_squad) or bool(state.squads[target_squad].get("battle_shocked", false)): return false
	return target_engaged_only_with_hammerfall_fortifications(state, target_squad)

static func _intervenes(observer: Dictionary, target: Dictionary, blocker: Dictionary) -> bool:
	var delta: Vector2 = target.position - observer.position
	var length_squared := delta.length_squared()
	if length_squared <= EPSILON: return false
	var along: float = (blocker.position - observer.position).dot(delta) / length_squared
	if along <= 0.0 or along >= 1.0: return false
	var radius := float(target.get("radius", 0.0))
	if length_squared <= radius * radius: return false
	var towards := -delta
	var foot: Vector2 = target.position + towards * radius * radius / length_squared
	var offset: Vector2 = towards.orthogonal() * radius * sqrt(length_squared - radius * radius) / length_squared
	var triangle := PackedVector2Array([observer.position, foot + offset, foot - offset])
	if Geometry2D.is_point_in_polygon(blocker.position, triangle): return true
	for index in range(3):
		var closest := Geometry2D.get_closest_point_to_segment(blocker.position, triangle[index], triangle[(index + 1) % 3])
		if closest.distance_to(blocker.position) <= float(blocker.get("radius", 0.0)) + SIGHT_RADIUS: return true
	return false

static func ceramite_cover(state: Dictionary, observer: int, target_squad: int) -> bool:
	if not state.get("units", {}).has(observer) or not state.get("squads", {}).has(target_squad): return false
	var attacking_model: Dictionary = state.units[observer]
	if int(attacking_model.get("wounds", 0)) <= 0 or not bool(attacking_model.get("on_battlefield", true)): return false
	for blocker_id: int in state.units:
		var blocker: Dictionary = state.units[blocker_id]
		if _identity(blocker) != "hammerfall-bunker" or int(blocker.get("wounds", 0)) <= 0 or not bool(blocker.get("on_battlefield", true)): continue
		if int(blocker.get("squad", -1)) == int(attacking_model.get("squad", -2)): continue
		for target_id: int in _living(state, target_squad):
			if _intervenes(attacking_model, state.units[target_id], blocker): return true
	return false
