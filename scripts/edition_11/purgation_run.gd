extends RefCounted
## Land Speeder Purgation Run, sourced from the local Wahapedia e11 extraction.
const Geometry = preload("res://scripts/edition_11/contact_movement.gd")
const Terrain = preload("res://scripts/edition_11/terrain.gd")
const Queue = preload("res://scripts/edition_11/fight_queue.gd")
const RandomStat = preload("res://scripts/edition_11/random_characteristic.gd")

const WINDOW := "purgation-run"
const PLACEMENT := "purgation-run-placement"

static func _charge_key(squad: int, turn: int) -> String:
	return "purgation-charge-block:%d:%d" % [squad, turn]

static func _eligible(state: Dictionary, squad: int) -> bool:
	if not state.squads.has(squad) or state.phase != "shooting" or int(state.active) != int(state.squads[squad].owner): return false
	if not state.squads[squad].shot or Queue.engaged(state, squad): return false
	for model: int in Geometry.alive(state, squad):
		if str(state.units[model].get("definition_id", "")).get_slice(":", 3) == "land-speeder": return true
	return false

static func open_after_shot(state: Dictionary, squad: int) -> void:
	if not _eligible(state, squad): return
	var previous: Dictionary = state.unit_abilities.get("window", {}).duplicate(true)
	state.unit_abilities.window = {"kind": WINDOW, "owners": [int(state.active)], "squad": squad, "resume_window": previous}

static func choices(state: Dictionary, player: int) -> Array:
	var window: Dictionary = state.unit_abilities.get("window", {})
	if window.get("kind", "") not in [WINDOW, PLACEMENT] or int(window.get("owners", [0])[0]) != player: return []
	if window.kind == PLACEMENT:
		var result: Array = []
		for model: int in window.positions: result.append({"label": "Purgation Run: preview Land Speeder move", "action": "purgation-place", "model": model, "target": int(window.squad), "value": ""})
		result.append({"label": "Confirm Purgation Run move", "action": "purgation-confirm", "model": -1, "target": int(window.squad), "value": ""})
		return result
	return [
		{"label": "Purgation Run: Normal Move up to D6 inches", "action": "purgation-use", "model": -1, "target": int(window.squad), "value": ""},
		{"label": "Decline Purgation Run", "action": "purgation-pass", "model": -1, "target": int(window.squad), "value": ""}
	]

static func apply(state: Dictionary, player: int, selected: Dictionary, point: Vector2, roller: Callable) -> Dictionary:
	var window: Dictionary = state.unit_abilities.get("window", {})
	var squad := int(selected.get("target", -1))
	if window.get("kind", "") == WINDOW:
		if int(window.get("owners", [0])[0]) != player or int(window.squad) != squad: return {"error": "This Purgation Run choice belongs to the pending Land Speeder."}
		if selected.action == "purgation-pass":
			state.unit_abilities.window = window.get("resume_window", {})
			return {"error": ""}
		if selected.action != "purgation-use": return {"error": "Choose to use or decline Purgation Run."}
		if not _eligible(state, squad): return {"error": "Purgation Run's shooting-phase or normal-move eligibility is no longer met."}
		var roll := RandomStat.roll("D6", roller)
		if not roll.error.is_empty(): return roll
		var origins: Dictionary = {}
		var positions: Dictionary = {}
		for model: int in Geometry.alive(state, squad):
			origins[model] = state.units[model].position
			positions[model] = state.units[model].position
		state.unit_abilities.used[_charge_key(squad, int(state.turn))] = true
		state.unit_abilities.window = {"kind": PLACEMENT, "owners": [player], "squad": squad, "distance": int(roll.value), "origins": origins, "positions": positions, "resume_window": window.get("resume_window", {})}
		return {"error": "", "message": "Purgation Run: Normal Move up to %d inches; this Land Speeder cannot charge this turn." % int(roll.value)}
	if window.get("kind", "") != PLACEMENT or int(window.get("owners", [0])[0]) != player or int(window.get("squad", -1)) != squad: return {"error": "No Purgation Run move is pending."}
	match selected.action:
		"purgation-place":
			var error := position_error(state, int(selected.get("model", -1)), point)
			if not error.is_empty(): return {"error": error}
			window.positions[int(selected.model)] = point
		"purgation-confirm":
			var model := int(window.positions.keys()[0]) if not window.positions.is_empty() else -1
			if model < 0: return {"error": "The Land Speeder has no living model to move."}
			var error := position_error(state, model, Vector2(window.positions[model]))
			if not error.is_empty(): return {"error": error}
			var projected := state.duplicate(true)
			projected.units[model].position = window.positions[model]
			if Queue.engaged(projected, squad): return {"error": "The Normal Move must end unengaged."}
			var longest := Vector2(window.origins[model]).distance_to(Vector2(window.positions[model]))
			state.units[model].position = window.positions[model]
			state.units[model].moved = true
			state.squads[squad].moved = true
			state.squads[squad].moved_distance = longest
			state.squads[squad].move_type = "normal"
			state.squads[squad].advanced = false
			state.squads[squad].fell_back = false
			state.unit_abilities.window = window.get("resume_window", {})
			return {"error": "", "message": "Purgation Run Normal Move completed; this Land Speeder cannot charge this turn."}
		_:
			return {"error": "Unsupported Purgation Run action."}
	return {"error": ""}

static func position_error(state: Dictionary, model: int, point: Vector2) -> String:
	var window: Dictionary = state.get("unit_abilities", {}).get("window", {})
	if window.get("kind", "") != PLACEMENT or not window.get("positions", {}).has(model): return "Select the Land Speeder in the pending Purgation Run move."
	if not point.is_finite(): return "Choose a finite destination."
	var unit: Dictionary = state.units[model]
	var radius := float(unit.radius)
	if absf(point.x) + radius > state.board_size.x / 2.0 + 0.001 or absf(point.y) + radius > state.board_size.y / 2.0 + 0.001: return "The whole base must stay on the battlefield."
	if Vector2(window.origins[model]).distance_to(point) > float(window.distance) + 0.001: return "The Land Speeder exceeds its Purgation Run distance."
	var projected := state.duplicate(true)
	projected.units[model].position = point
	var terrain_error := Terrain.path_error(projected, model, point)
	if not terrain_error.is_empty(): return terrain_error
	if not Geometry.clear_path(state, model, point, float(window.distance), false, false, -1.0, "normal"): return "The Land Speeder cannot move through blocking model bases."
	for other: int in state.units:
		if other == model or state.units[other].wounds <= 0 or not state.units[other].get("on_battlefield", true): continue
		if point.distance_to(Vector2(state.units[other].position)) < radius + float(state.units[other].radius) - 0.001: return "Bases cannot overlap at the destination."
	return ""
