extends RefCounted
## Black Templars Sword Brethren reaction to an enemy Fall Back move.
const Geometry = preload("res://scripts/edition_11/contact_movement.gd")
const Terrain = preload("res://scripts/edition_11/terrain.gd")
const FightQueue = preload("res://scripts/edition_11/fight_queue.gd")
const UnitAbilities = preload("res://scripts/edition_11/unit_abilities.gd")

const WINDOW := "sword-brethren-exploit-window"
const PLACEMENT := "sword-brethren-exploit-placement"

static func fall_back_reaction_squads(state: Dictionary, moved_squad: int) -> Array[int]:
	var result: Array[int] = []
	if not UnitAbilities.enabled(state) or not state.squads.has(moved_squad): return result
	var moving_owner := int(state.squads[moved_squad].get("owner", -1))
	if moving_owner not in [1, 2]: return result
	for squad_value: Variant in state.squads.keys():
		if not squad_value is int: continue
		var squad := int(squad_value)
		if int(state.squads[squad].get("owner", -1)) == moving_owner or Geometry.alive(state, squad).is_empty(): continue
		if not UnitAbilities.has(state, squad, "exploit-their-cowardice"): continue
		if _engaged_with(state, squad, moved_squad): result.append(squad)
	return result

static func open_after_enemy_fall_back(state: Dictionary, moved_squad: int, move_type: String, trigger_squads: Array[int]) -> bool:
	if move_type not in ["ordered_retreat", "desperate_escape"] or trigger_squads.is_empty(): return false
	if not UnitAbilities.enabled(state) or state.phase != "movement" or not state.squads.has(moved_squad): return false
	if int(state.squads[moved_squad].get("owner", -1)) != int(state.active): return false
	var previous: Dictionary = state.get("unit_abilities", {}).get("window", {}).duplicate(true)
	return _open_next(state, trigger_squads.duplicate(), moved_squad, previous)

static func _open_next(state: Dictionary, remaining: Array, trigger: int, previous: Dictionary) -> bool:
	while not remaining.is_empty():
		var squad := int(remaining.pop_front())
		if not _eligible(state, squad, trigger): continue
		state.unit_abilities.window = {"kind": WINDOW, "owners": [int(state.squads[squad].owner)], "squad": squad,
			"trigger": trigger, "remaining": remaining.duplicate(), "resume_window": previous.duplicate(true)}
		return true
	state.unit_abilities.window = previous
	return false

static func _eligible(state: Dictionary, squad: int, trigger: int) -> bool:
	if not state.squads.has(squad) or not state.squads.has(trigger) or Geometry.alive(state, squad).is_empty(): return false
	if int(state.squads[squad].get("owner", -1)) == int(state.squads[trigger].get("owner", -1)): return false
	if not UnitAbilities.has(state, squad, "exploit-their-cowardice") or FightQueue.engaged(state, squad): return false
	return bool(state.squads[trigger].get("fell_back", false)) and str(state.squads[trigger].get("move_type", "")) in ["ordered_retreat", "desperate_escape"]

static func _engaged_with(state: Dictionary, first_squad: int, second_squad: int) -> bool:
	for first: int in Geometry.alive(state, first_squad):
		for second: int in Geometry.alive(state, second_squad):
			if Geometry.within_engagement(state.units[first], state.units[second]): return true
	return false

static func choices(state: Dictionary, player: int) -> Array[Dictionary]:
	var window: Dictionary = state.get("unit_abilities", {}).get("window", {})
	if window.get("kind", "") not in [WINDOW, PLACEMENT] or window.get("owners", []) != [player]: return []
	var squad := int(window.get("squad", -1))
	var trigger := int(window.get("trigger", -1))
	if window.kind == WINDOW:
		if not _eligible(state, squad, trigger): return [{"label": "Decline Exploit their Cowardice", "action": "sword-brethren-exploit-pass", "model": -1, "target": squad, "value": ""}]
		return [
			{"label": "%s: Exploit their Cowardice — Normal Move up to 6 inches" % str(state.squads[squad].get("name", "Sword Brethren")), "action": "sword-brethren-exploit-use", "model": -1, "target": squad, "value": ""},
			{"label": "Decline Exploit their Cowardice", "action": "sword-brethren-exploit-pass", "model": -1, "target": squad, "value": ""}
		]
	var result: Array[Dictionary] = []
	for model_value: Variant in window.get("positions", {}).keys():
		if model_value is int: result.append({"label": "Sword Brethren: preview model %d" % int(model_value), "action": "sword-brethren-exploit-place", "model": int(model_value), "target": squad, "value": ""})
	result.append({"label": "Confirm Sword Brethren Normal Move (up to 6 inches)", "action": "sword-brethren-exploit-confirm", "model": -1, "target": squad, "value": ""})
	return result

static func apply(state: Dictionary, player: int, selected: Dictionary, point: Vector2) -> Dictionary:
	var window: Dictionary = state.get("unit_abilities", {}).get("window", {})
	var squad := int(selected.get("target", -1))
	if window.get("kind", "") == WINDOW:
		if window.get("owners", []) != [player] or int(window.get("squad", -1)) != squad: return {"error": "This Exploit their Cowardice decision belongs to the Sword Brethren player's army."}
		if selected.get("action", "") == "sword-brethren-exploit-pass":
			_open_next(state, window.get("remaining", []).duplicate(), int(window.get("trigger", -1)), window.get("resume_window", {}).duplicate(true))
			return {"error": ""}
		if selected.get("action", "") != "sword-brethren-exploit-use" or not _eligible(state, squad, int(window.get("trigger", -1))): return {"error": "Exploit their Cowardice is no longer eligible for this Sword Brethren unit."}
		var origins: Dictionary = {}
		var positions: Dictionary = {}
		for model: int in Geometry.alive(state, squad):
			origins[model] = state.units[model].position
			positions[model] = state.units[model].position
		state.unit_abilities.window = {"kind": PLACEMENT, "owners": [player], "squad": squad, "trigger": int(window.get("trigger", -1)),
			"distance": 6.0, "origins": origins, "positions": positions, "remaining": window.get("remaining", []).duplicate(),
			"resume_window": window.get("resume_window", {}).duplicate(true)}
		return {"error": "", "message": "Sword Brethren may make a Normal Move up to 6 inches."}
	if window.get("kind", "") != PLACEMENT or window.get("owners", []) != [player] or int(window.get("squad", -1)) != squad: return {"error": "No Sword Brethren reaction move is pending."}
	match str(selected.get("action", "")):
		"sword-brethren-exploit-place":
			var model := int(selected.get("model", -1))
			var error := position_error(state, model, point)
			if not error.is_empty(): return {"error": error}
			window.positions[model] = point
		"sword-brethren-exploit-confirm":
			var projected := state.duplicate(true)
			var longest := 0.0
			for model_value: Variant in window.get("positions", {}).keys():
				if not model_value is int: return {"error": "Sword Brethren placement data is invalid."}
				var model := int(model_value)
				var destination := Vector2(window.positions[model])
				var error := position_error(state, model, destination)
				if not error.is_empty(): return {"error": error}
				projected.units[model].position = destination
				longest = maxf(longest, Vector2(window.origins[model]).distance_to(destination))
			if not Geometry.coherent(projected, squad) or FightQueue.engaged(projected, squad): return {"error": "Exploit their Cowardice must end with the unit coherent and outside Engagement Range."}
			for model_value: Variant in window.positions.keys():
				var model := int(model_value)
				state.units[model].position = window.positions[model]
				state.units[model].moved = true
			state.squads[squad].moved = true
			state.squads[squad].moved_distance = longest
			state.squads[squad].move_type = "normal"
			state.squads[squad].advanced = false
			state.squads[squad].fell_back = false
			var trigger := int(window.get("trigger", -1))
			var remaining: Array = window.get("remaining", []).duplicate()
			var previous: Dictionary = window.get("resume_window", {}).duplicate(true)
			_open_next(state, remaining, trigger, previous)
			return {"error": "", "message": "Sword Brethren made a Normal Move up to 6 inches."}
		_:
			return {"error": "Unsupported Exploit their Cowardice action."}
	return {"error": ""}

static func position_error(state: Dictionary, model: int, point: Vector2) -> String:
	var window: Dictionary = state.get("unit_abilities", {}).get("window", {})
	if window.get("kind", "") != PLACEMENT or not window.get("positions", {}).has(model): return "Select a model in the pending Sword Brethren reaction move."
	if not point.is_finite(): return "Choose a finite destination."
	var unit: Dictionary = state.units[model]
	var radius := float(unit.radius)
	if absf(point.x) + radius > state.board_size.x / 2.0 + 0.001 or absf(point.y) + radius > state.board_size.y / 2.0 + 0.001: return "The whole base must stay on the battlefield."
	if Vector2(window.origins[model]).distance_to(point) > float(window.distance) + 0.001: return "This model cannot move more than 6 inches for Exploit their Cowardice."
	var projected := state.duplicate(true)
	projected.units[model].position = point
	var terrain_error := Terrain.path_error(projected, model, point)
	if not terrain_error.is_empty(): return terrain_error
	if not Geometry.clear_path(state, model, point, float(window.distance), false): return "This model cannot pass through terrain or blocking enemy bases."
	for other: int in state.units:
		if other == model or state.units[other].wounds <= 0 or not state.units[other].get("on_battlefield", true): continue
		var other_point: Vector2 = Vector2(window.positions[other]) if window.positions.has(other) else state.units[other].position
		if point.distance_to(other_point) < radius + float(state.units[other].radius) - 0.001: return "Bases cannot overlap at the destination."
	return ""
