extends RefCounted
## Victrix Honour Guard abilities transcribed from the local Wahapedia e11 export.
const Geometry = preload("res://scripts/edition_11/contact_movement.gd")
const Terrain = preload("res://scripts/edition_11/terrain.gd")
const Queue = preload("res://scripts/edition_11/fight_queue.gd")
const RandomStat = preload("res://scripts/edition_11/random_characteristic.gd")

const WINDOW := "glory-of-ultramar"
const PLACEMENT := "glory-of-ultramar-placement"

static func _is_victrix(state: Dictionary, squad: int) -> bool:
	if not state.squads.has(squad): return false
	for model: int in Geometry.alive(state, squad):
		if str(state.units[model].get("definition_id", "")).get_slice(":", 3) == "victrix-honour-guard": return true
	return false

static func open_after_enemy_shot(state: Dictionary, shooter: int, pools: Array) -> void:
	if state.phase != "shooting" or not state.squads.has(shooter) or int(state.squads[shooter].owner) != int(state.active): return
	var casualties: Array[int] = []
	for pool: Dictionary in pools:
		var target_squad := int(pool.get("target_squad", -1))
		if not _is_victrix(state, target_squad) or int(pool.get("models_destroyed", 0)) <= 0: continue
		var destroyed_here := false
		for allocation: Dictionary in pool.get("allocations", []):
			var model := int(allocation.get("model", -1))
			if model >= 0 and state.units.has(model) and int(state.units[model].wounds) <= 0 and state.units[model].squad == target_squad:
				destroyed_here = true
				break
		if destroyed_here and target_squad not in casualties: casualties.append(target_squad)
	if casualties.is_empty(): return
	var previous: Dictionary = state.unit_abilities.get("window", {}).duplicate(true)
	state.unit_abilities.window = {"kind": WINDOW, "owners": [3 - int(state.active)], "squad": casualties[0], "shooter": shooter, "casualties": casualties, "resume_window": previous}

static func choices(state: Dictionary, player: int) -> Array:
	var window: Dictionary = state.get("unit_abilities", {}).get("window", {})
	if window.get("kind", "") not in [WINDOW, PLACEMENT] or window.get("owners", []).is_empty() or int(window.owners[0]) != player: return []
	if window.kind == PLACEMENT:
		var result: Array = []
		for model: int in window.positions: result.append({"label": "Glory of Ultramar: preview model %d" % model, "action": "glory-place", "model": model, "target": int(window.squad), "value": ""})
		result.append({"label": "Confirm Glory of Ultramar Surge move", "action": "glory-confirm", "model": -1, "target": int(window.squad), "value": ""})
		return result
	return [
		{"label": "Glory of Ultramar: Surge move up to D6 inches with %s" % state.squads[int(window.squad)].name, "action": "glory-use", "model": -1, "target": int(window.squad), "value": ""},
		{"label": "Decline Glory of Ultramar", "action": "glory-pass", "model": -1, "target": int(window.squad), "value": ""}
	]

static func apply(state: Dictionary, player: int, selected: Dictionary, point: Vector2, roller: Callable) -> Dictionary:
	var window: Dictionary = state.unit_abilities.get("window", {})
	var squad := int(selected.get("target", -1))
	if window.get("kind", "") == WINDOW:
		if window.get("owners", []).is_empty() or int(window.owners[0]) != player or int(window.get("squad", -1)) != squad: return {"error": "This Glory of Ultramar decision belongs to the Victrix Honour Guard targeted by the pending enemy attacks."}
		if selected.action == "glory-pass":
			state.unit_abilities.window = window.get("resume_window", {})
			return {"error": ""}
		if selected.action != "glory-use" or not _is_victrix(state, squad): return {"error": "Choose to use or decline the pending Glory of Ultramar reaction."}
		var roll := RandomStat.roll("D6", roller)
		if not roll.error.is_empty(): return roll
		var origins := {}
		var positions := {}
		for model: int in Geometry.alive(state, squad):
			origins[model] = state.units[model].position
			positions[model] = state.units[model].position
		state.unit_abilities.window = {"kind": PLACEMENT, "owners": [player], "squad": squad, "distance": int(roll.value), "origins": origins, "positions": positions, "resume_window": window.get("resume_window", {})}
		return {"error": "", "message": "Glory of Ultramar: Surge move up to %d inches." % int(roll.value)}
	if window.get("kind", "") != PLACEMENT or window.get("owners", []).is_empty() or int(window.owners[0]) != player or int(window.get("squad", -1)) != squad: return {"error": "No Glory of Ultramar Surge move is pending."}
	if selected.action == "glory-place":
		var error := position_error(state, int(selected.get("model", -1)), point)
		if not error.is_empty(): return {"error": error}
		window.positions[int(selected.model)] = point
		return {"error": ""}
	if selected.action != "glory-confirm": return {"error": "Preview a Victrix model or confirm its Surge move."}
	if Geometry.alive(state, squad).is_empty(): return {"error": "The Victrix Honour Guard has no surviving models to move."}
	var projected := state.duplicate(true)
	var longest := 0.0
	for model: int in window.positions:
		var error := position_error(state, model, Vector2(window.positions[model]))
		if not error.is_empty(): return {"error": error}
		projected.units[model].position = window.positions[model]
		longest = maxf(longest, Vector2(window.origins[model]).distance_to(Vector2(window.positions[model])))
	if not Geometry.coherent(projected, squad): return {"error": "The Surge move must preserve unit coherency."}
	for model: int in window.positions:
		state.units[model].position = window.positions[model]
		state.units[model].moved = true
	state.squads[squad].moved = true
	state.squads[squad].moved_distance = longest
	state.squads[squad].move_type = "surge"
	state.squads[squad].advanced = false
	state.squads[squad].fell_back = false
	state.unit_abilities.window = window.get("resume_window", {})
	return {"error": "", "message": "Glory of Ultramar Surge move completed; %.2f inches maximum model movement." % longest}

static func position_error(state: Dictionary, model: int, point: Vector2) -> String:
	var window: Dictionary = state.get("unit_abilities", {}).get("window", {})
	if window.get("kind", "") != PLACEMENT or not window.get("positions", {}).has(model): return "Select a model in the pending Glory of Ultramar move."
	if not point.is_finite(): return "Choose a finite destination."
	var unit: Dictionary = state.units[model]
	var radius := float(unit.radius)
	if absf(point.x) + radius > state.board_size.x / 2.0 + 0.001 or absf(point.y) + radius > state.board_size.y / 2.0 + 0.001: return "The whole base must stay on the battlefield."
	if Vector2(window.origins[model]).distance_to(point) > float(window.distance) + 0.001: return "This model exceeds its Glory of Ultramar Surge move distance."
	var projected := state.duplicate(true)
	projected.units[model].position = point
	var terrain_error := Terrain.path_error(projected, model, point)
	if not terrain_error.is_empty(): return terrain_error
	if not Geometry.clear_path(state, model, point, float(window.distance), false): return "This model cannot move through terrain or blocking enemy bases."
	for other: int in state.units:
		if other == model or int(state.units[other].wounds) <= 0 or not state.units[other].get("on_battlefield", true): continue
		var other_point: Vector2 = Vector2(window.positions[other]) if window.positions.has(other) else Vector2(state.units[other].position)
		if point.distance_to(other_point) < radius + float(state.units[other].radius) - 0.001: return "Bases cannot overlap at the destination."
	return ""
