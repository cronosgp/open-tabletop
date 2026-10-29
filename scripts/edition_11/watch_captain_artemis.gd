extends RefCounted
## Watch Captain Artemis's Unstoppable Champion return, bounded to its current Deathwatch datasheet.
const A = preload("res://scripts/edition_11/unit_abilities.gd")
const G = preload("res://scripts/edition_11/contact_movement.gd")
const Board = preload("res://scripts/rules.gd")
const RandomStat = preload("res://scripts/edition_11/random_characteristic.gd")

const IDENTITY := "watch-captain-artemis"
const PLACEMENT_WINDOW := "artemis-placement"
const USE := "artemis-unstoppable-use"
const PASS := "artemis-unstoppable-pass"
const PLACE := "artemis-place"
const CONFIRM := "artemis-confirm"
const SETUP_TOLERANCE := 0.08
const LEGAL_GAP := 0.01

static func phase_key(state: Dictionary) -> String:
	return "%d:%s" % [int(state.get("turn", 0)), str(state.get("phase", ""))]

static func _ability_state(state: Dictionary) -> Dictionary:
	return state.get("unit_abilities", {})

static func record_destroyed(state: Dictionary, model: int) -> void:
	if not A.enabled(state) or not state.get("units", {}).has(model): return
	var unit: Dictionary = state.units[model]
	if A.identity(unit) != IDENTITY or int(unit.get("wounds", 0)) > 0 or bool(unit.get("lingering", false)) or not bool(unit.get("on_battlefield", true)): return
	if str(state.get("phase", "")) not in ["command", "movement", "shooting", "charge", "fight"]: return
	var owner := int(unit.get("owner", -1))
	var squad := int(unit.get("squad", -1))
	if owner not in [1, 2] or not state.get("squads", {}).has(squad): return
	var abilities := _ability_state(state)
	var records: Array = abilities.get("artemis_destroyed", []).duplicate(true)
	for record: Variant in records:
		if record is Dictionary and int(record.get("model", -1)) == model and str(record.get("phase_key", "")) == phase_key(state): return
	records.append({"model": model, "squad": squad, "owner": owner, "origin": unit.get("position", Vector2.ZERO), "phase_key": phase_key(state), "phase": str(state.phase), "passed": false})
	abilities.artemis_destroyed = records

static func _record(state: Dictionary, owner: int) -> Dictionary:
	var abilities := _ability_state(state)
	var used: Dictionary = abilities.get("used", {})
	if bool(used.get("unstoppable-champion-used:%d" % owner, false)): return {}
	for record_value: Variant in abilities.get("artemis_destroyed", []):
		if not record_value is Dictionary: continue
		var record: Dictionary = record_value
		if int(record.get("owner", -1)) == owner and str(record.get("phase_key", "")) == phase_key(state) and not bool(record.get("passed", false)):
			return record
	return {}

static func pending(state: Dictionary, owner: int) -> bool:
	return A.enabled(state) and state.get("phase", "") in ["command", "movement", "shooting", "charge", "fight"] and not _record(state, owner).is_empty()

static func choices(state: Dictionary, owner: int) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var window: Dictionary = _ability_state(state).get("window", {})
	if window.get("kind", "") != "end" or window.get("owners", []) is not Array or owner not in window.get("owners", []): return result
	var record := _record(state, owner)
	if record.is_empty(): return result
	var model := int(record.get("model", -1))
	result.append({"label": "Unstoppable Champion: roll to return Watch Captain Artemis %d" % model, "action": USE, "model": model, "target": int(record.get("squad", -1)), "value": ""})
	result.append({"label": "Pass Unstoppable Champion for Watch Captain Artemis %d" % model, "action": PASS, "model": model, "target": int(record.get("squad", -1)), "value": ""})
	return result

static func _remove_record(state: Dictionary, model: int, record_phase_key: String) -> void:
	var abilities := _ability_state(state)
	var records: Array = []
	for record_value: Variant in abilities.get("artemis_destroyed", []):
		if record_value is Dictionary and int(record_value.get("model", -1)) == model and str(record_value.get("phase_key", "")) == record_phase_key: continue
		records.append(record_value)
	abilities.artemis_destroyed = records

static func _clean_placement(state: Dictionary, point: Vector2, model: int) -> String:
	if not point.is_finite() or not state.get("units", {}).has(model): return "Choose a finite battlefield position for Watch Captain Artemis."
	var unit: Dictionary = state.units[model]
	var half: Vector2 = Board.half_board(state)
	var radius := float(unit.get("radius", 0.0))
	if absf(point.x) + radius > half.x + 0.001 or absf(point.y) + radius > half.y + 0.001: return "Watch Captain Artemis's whole base must fit on the battlefield."
	var projected := unit.duplicate(true)
	projected.wounds = 1
	projected.on_battlefield = true
	projected.position = point
	for other: int in state.units:
		if other == model: continue
		var obstacle: Dictionary = state.units[other]
		if int(obstacle.get("wounds", 0)) <= 0 or not bool(obstacle.get("on_battlefield", true)): continue
		var vertical := absf(float(projected.get("elevation", 0.0)) - float(obstacle.get("elevation", 0.0)))
		if vertical <= 0.001 and point.distance_to(obstacle.position) < radius + float(obstacle.get("radius", 0.0)) - 0.001:
			return "Watch Captain Artemis's base cannot overlap another model."
		if int(obstacle.get("owner", -1)) != int(unit.get("owner", -2)) and G.within_engagement(projected, obstacle):
			return "Watch Captain Artemis must be set up outside Engagement Range."
	return ""

static func _obstacle_circles(state: Dictionary, model: int) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var unit: Dictionary = state.units[model]
	var radius := float(unit.get("radius", 0.0))
	for other: int in state.units:
		if other == model: continue
		var obstacle: Dictionary = state.units[other]
		if int(obstacle.get("wounds", 0)) <= 0 or not bool(obstacle.get("on_battlefield", true)): continue
		var vertical := absf(float(unit.get("elevation", 0.0)) - float(obstacle.get("elevation", 0.0)))
		var minimum_distance := radius + float(obstacle.get("radius", 0.0))
		if int(obstacle.get("owner", -1)) != int(unit.get("owner", -2)) and vertical <= 5.0 + 0.001:
			minimum_distance += 2.0 + LEGAL_GAP
		elif vertical <= 0.001:
			minimum_distance += LEGAL_GAP
		else:
			continue
		result.append({"centre": obstacle.position, "radius": minimum_distance})
	return result

static func _circle_intersections(first: Dictionary, second: Dictionary) -> Array[Vector2]:
	var result: Array[Vector2] = []
	var a: Vector2 = first.centre
	var b: Vector2 = second.centre
	var ra := float(first.radius)
	var rb := float(second.radius)
	var delta := b - a
	var distance := delta.length()
	if distance <= 0.000001 or distance > ra + rb + 0.001 or distance < absf(ra - rb) - 0.001: return result
	var along := (ra * ra - rb * rb + distance * distance) / (2.0 * distance)
	var height_squared := ra * ra - along * along
	if height_squared < -0.001: return result
	var direction := delta / distance
	var midpoint := a + direction * along
	var perpendicular := Vector2(-direction.y, direction.x) * sqrt(maxf(0.0, height_squared))
	result.append(midpoint + perpendicular)
	if height_squared > 0.000001: result.append(midpoint - perpendicular)
	return result

static func _candidates(state: Dictionary, model: int, origin: Vector2) -> Array[Vector2]:
	var result: Array[Vector2] = []
	var radius := float(state.units[model].get("radius", 0.0))
	var half: Vector2 = Board.half_board(state)
	var minimum := Vector2(-half.x + radius, -half.y + radius)
	var maximum := Vector2(half.x - radius, half.y - radius)
	if minimum.x > maximum.x or minimum.y > maximum.y: return result
	var start := origin.clamp(minimum, maximum)
	result.append(start)
	result.append(Vector2(clampf(origin.x, minimum.x, maximum.x), clampf(origin.y, minimum.y, maximum.y)))
	for x in [minimum.x, maximum.x]: result.append(Vector2(x, clampf(origin.y, minimum.y, maximum.y)))
	for y in [minimum.y, maximum.y]: result.append(Vector2(clampf(origin.x, minimum.x, maximum.x), y))
	result.append(minimum)
	result.append(Vector2(minimum.x, maximum.y))
	result.append(Vector2(maximum.x, minimum.y))
	result.append(maximum)
	var circles := _obstacle_circles(state, model)
	for circle: Dictionary in circles:
		var centre: Vector2 = circle.centre
		var obstacle_radius := float(circle.radius)
		var away := origin - centre
		if away.length_squared() <= 0.000001:
			for sample in range(32): result.append(centre + Vector2.RIGHT.rotated(float(sample) * TAU / 32.0) * obstacle_radius)
		else:
			result.append(centre + away.normalized() * obstacle_radius)
		for x in [minimum.x, maximum.x]:
			var dx: float = float(x) - centre.x
			var remaining: float = obstacle_radius * obstacle_radius - dx * dx
			if remaining >= -0.001:
				var dy := sqrt(maxf(0.0, remaining))
				result.append(Vector2(x, centre.y + dy))
				result.append(Vector2(x, centre.y - dy))
		for y in [minimum.y, maximum.y]:
			var dy: float = float(y) - centre.y
			var remaining: float = obstacle_radius * obstacle_radius - dy * dy
			if remaining >= -0.001:
				var dx := sqrt(maxf(0.0, remaining))
				result.append(Vector2(centre.x + dx, y))
				result.append(Vector2(centre.x - dx, y))
	for first_index in range(circles.size()):
		for second_index in range(first_index + 1, circles.size()):
			result.append_array(_circle_intersections(circles[first_index], circles[second_index]))
	return result

static func nearest_position(state: Dictionary, model: int, origin: Vector2) -> Dictionary:
	if not state.get("units", {}).has(model): return {}
	var nearest := Vector2.ZERO
	var nearest_distance := INF
	for point: Vector2 in _candidates(state, model, origin):
		if not _clean_placement(state, point, model).is_empty(): continue
		var distance := point.distance_to(origin)
		if distance < nearest_distance:
			nearest = point
			nearest_distance = distance
	return {} if is_inf(nearest_distance) else {"position": nearest, "distance": nearest_distance}

static func placement_choices(state: Dictionary, owner: int) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var window: Dictionary = _ability_state(state).get("window", {})
	var placement: Dictionary = window.get("artemis_placement", {})
	if window.get("kind", "") != "end" or int(placement.get("owner", -1)) != owner: return result
	var model := int(placement.get("model", -1))
	if not state.get("units", {}).has(model): return result
	result.append({"label": "Unstoppable Champion: preview Watch Captain Artemis %d's return position" % model, "action": PLACE, "model": model, "target": int(placement.get("squad", -1)), "value": ""})
	if placement.has("position"):
		result.append({"label": "Confirm Watch Captain Artemis %d at the closest legal position" % model, "action": CONFIRM, "model": model, "target": int(placement.get("squad", -1)), "value": ""})
	return result

static func position_error(state: Dictionary, model: int, point: Vector2) -> String:
	var window: Dictionary = _ability_state(state).get("window", {})
	var placement: Dictionary = window.get("artemis_placement", {})
	if window.get("kind", "") != "end" or int(placement.get("model", -1)) != model: return "No Unstoppable Champion placement is pending for this model."
	var error := _clean_placement(state, point, model)
	if not error.is_empty(): return error
	var origin: Vector2 = placement.get("origin", Vector2.ZERO)
	var nearest := nearest_position(state, model, origin)
	if nearest.is_empty(): return "No legal unengaged position is available for Watch Captain Artemis."
	if point.distance_to(origin) > float(nearest.distance) + SETUP_TOLERANCE:
		return "Watch Captain Artemis must be set up as close as possible to where she was destroyed."
	return ""

static func apply_choice(state: Dictionary, player: int, selected: Dictionary, roller: Callable) -> Dictionary:
	var options := choices(state, player)
	if selected not in options: return {"error": "Unstoppable Champion is available only to Artemis's army at the end of the phase in which she was destroyed."}
	var model := int(selected.get("model", -1))
	var record := _record(state, player)
	if record.is_empty() or int(record.get("model", -1)) != model: return {"error": "No matching Watch Captain Artemis destruction is pending in this phase."}
	if selected.get("action", "") == PASS:
		var records: Array = _ability_state(state).get("artemis_destroyed", []).duplicate(true)
		for index in range(records.size()):
			if records[index] is Dictionary and int(records[index].get("model", -1)) == model and str(records[index].get("phase_key", "")) == phase_key(state):
				records[index].passed = true
				break
		_ability_state(state).artemis_destroyed = records
		return {"error": "", "message": "Unstoppable Champion was passed."}
	var roll := RandomStat.roll("D6", roller)
	if not str(roll.get("error", "")).is_empty(): return roll
	var abilities := _ability_state(state)
	if not abilities.has("used"): abilities.used = {}
	abilities.used["unstoppable-champion-used:%d" % player] = true
	_remove_record(state, model, str(record.get("phase_key", "")))
	if int(roll.get("value", 0)) < 2:
		return {"error": "", "message": "Unstoppable Champion: the D6 rolled %d; Watch Captain Artemis remains destroyed." % int(roll.value)}
	var nearest := nearest_position(state, model, record.get("origin", Vector2.ZERO))
	if nearest.is_empty():
		return {"error": "", "message": "Unstoppable Champion: the D6 rolled %d, but no legal unengaged position is available; Artemis remains destroyed." % int(roll.value)}
	var window: Dictionary = abilities.get("window", {}).duplicate(true)
	window.artemis_placement = {"model": model, "squad": int(record.get("squad", -1)), "owner": player, "origin": record.get("origin", Vector2.ZERO), "roll": roll, "position": nearest.position}
	abilities.window = window
	return {"error": "", "message": "Unstoppable Champion: the D6 rolled %d; choose the closest legal unengaged position for Watch Captain Artemis." % int(roll.value)}

static func apply_placement(state: Dictionary, player: int, selected: Dictionary, point: Vector2) -> Dictionary:
	var window: Dictionary = _ability_state(state).get("window", {})
	var placement: Dictionary = window.get("artemis_placement", {}).duplicate(true)
	if window.get("kind", "") != "end" or int(placement.get("owner", -1)) != player: return {"error": "No Watch Captain Artemis return position is pending for this player."}
	var model := int(placement.get("model", -1))
	if selected.get("action", "") == PLACE:
		if int(selected.get("model", -1)) != model: return {"error": "Select Watch Captain Artemis for this return position."}
		var error := position_error(state, model, point)
		if not error.is_empty(): return {"error": error}
		placement.position = point
		window.artemis_placement = placement
		_ability_state(state).window = window
		return {"error": ""}
	if selected.get("action", "") != CONFIRM or int(selected.get("model", -1)) != model: return {"error": "Confirm the pending Watch Captain Artemis return."}
	if not placement.has("position"): return {"error": "Preview Watch Captain Artemis's return position before confirming."}
	var confirmed_error := position_error(state, model, placement.position)
	if not confirmed_error.is_empty(): return {"error": confirmed_error}
	state.units[model].position = placement.position
	state.units[model].on_battlefield = true
	state.units[model].wounds = 3
	window.erase("artemis_placement")
	_ability_state(state).window = window
	return {"error": "", "message": "Watch Captain Artemis returns with 3 wounds remaining."}
