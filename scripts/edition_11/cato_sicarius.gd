extends RefCounted
## Knight Champion of Macragge; source transcription from the local Wahapedia e11 export.
const Geometry = preload("res://scripts/edition_11/contact_movement.gd")
const Terrain = preload("res://scripts/edition_11/terrain.gd")
const Queue = preload("res://scripts/edition_11/fight_queue.gd")

const WINDOW := "knight-champion-of-macragge"
const PLACEMENT := "knight-champion-placement"

static func _used_key(owner: int, turn: int) -> String:
	return "cato-knight-champion:%d:%d" % [owner, turn]

static func open_after_enemy_move(state: Dictionary, moved_squad: int) -> void:
	if state.phase != "movement" or not state.squads.has(moved_squad) or state.squads[moved_squad].owner != state.active: return
	var owner := 3 - int(state.active)
	if state.unit_abilities.used.get(_used_key(owner, int(state.turn)), false): return
	var previous: Dictionary = state.unit_abilities.get("window", {}).duplicate(true)
	for cato_squad: int in state.squads:
		if int(state.squads[cato_squad].owner) != owner or Queue.engaged(state, cato_squad): continue
		var cato_models := Geometry.alive(state, cato_squad)
		var source := -1
		for cato: int in cato_models:
			if str(state.units[cato].get("definition_id", "")).get_slice(":", 3) == "cato-sicarius" and state.units[cato].get("on_battlefield", true): source = cato
		if source < 0: continue
		var distance := INF
		for cato: int in cato_models:
			for target_model: int in Geometry.alive(state, moved_squad):
				distance = minf(distance, Geometry.edge(state.units[cato], state.units[target_model]))
		if distance <= 8.001:
			state.unit_abilities.window = {"kind": WINDOW, "owners": [owner], "squad": cato_squad, "source": source, "trigger": moved_squad, "resume_window": previous}
			return

static func choices(state: Dictionary, player: int) -> Array:
	var window: Dictionary = state.get("unit_abilities", {}).get("window", {})
	if window.get("kind", "") not in [WINDOW, PLACEMENT] or int(window.get("owners", [0])[0]) != player: return []
	if window.kind == WINDOW:
		return [
			{"label": "Cato %d: Knight Champion of Macragge — Normal Move up to 6 inches" % int(window.source), "action": "cato-knight-use", "model": int(window.source), "target": int(window.squad), "value": ""},
			{"label": "Decline Knight Champion of Macragge", "action": "cato-knight-pass", "model": int(window.source), "target": int(window.squad), "value": ""}
		]
	var result: Array = []
	for model: int in window.positions: result.append({"label": "Cato's unit: preview model %d" % model, "action": "cato-knight-place", "model": model, "target": int(window.squad), "value": ""})
	result.append({"label": "Confirm Cato's Normal Move (up to 6 inches)", "action": "cato-knight-confirm", "model": -1, "target": int(window.squad), "value": ""})
	return result

static func _resume(state: Dictionary) -> void:
	state.unit_abilities.window = state.unit_abilities.window.get("resume_window", {})

static func apply(state: Dictionary, player: int, selected: Dictionary, point: Vector2) -> Dictionary:
	var window: Dictionary = state.unit_abilities.get("window", {})
	var squad := int(selected.get("target", -1))
	if window.get("kind", "") == WINDOW:
		if int(window.get("owners", [0])[0]) != player or int(window.get("squad", -1)) != squad: return {"error": "This Knight Champion decision belongs to Cato Sicarius's player."}
		if selected.action == "cato-knight-pass":
			_resume(state)
			return {"error": ""}
		if selected.action != "cato-knight-use": return {"error": "Choose to use or decline Knight Champion of Macragge."}
		var source := int(window.get("source", -1))
		if not state.units.has(source) or state.units[source].wounds <= 0 or not state.units[source].get("on_battlefield", true) or Queue.engaged(state, squad) or Geometry.alive(state, squad).is_empty(): return {"error": "Knight Champion requires Cato's living unit to remain unengaged on the battlefield."}
		var origins := {}
		var positions := {}
		for model: int in Geometry.alive(state, squad):
			origins[model] = state.units[model].position
			positions[model] = state.units[model].position
		state.unit_abilities.used[_used_key(player, int(state.turn))] = true
		state.unit_abilities.window = {"kind": PLACEMENT, "owners": [player], "squad": squad, "source": source, "trigger": int(window.get("trigger", -1)), "distance": 6, "origins": origins, "positions": positions, "resume_window": window.get("resume_window", {})}
		return {"error": "", "message": "Cato Sicarius may make a Normal Move up to 6 inches."}
	if window.get("kind", "") != PLACEMENT or int(window.get("owners", [0])[0]) != player or int(window.get("squad", -1)) != squad: return {"error": "No Cato Sicarius reaction move is pending."}
	match selected.action:
		"cato-knight-place":
			var error := position_error(state, int(selected.get("model", -1)), point)
			if not error.is_empty(): return {"error": error}
			window.positions[int(selected.model)] = point
		"cato-knight-confirm":
			var projected := state.duplicate(true)
			var longest := 0.0
			for model: int in window.positions:
				var error := position_error(state, model, Vector2(window.positions[model]))
				if not error.is_empty(): return {"error": error}
				projected.units[model].position = window.positions[model]
				longest = maxf(longest, Vector2(window.origins[model]).distance_to(Vector2(window.positions[model])))
			if not Geometry.coherent(projected, squad) or Queue.engaged(projected, squad): return {"error": "Cato's Normal Move must preserve coherency and end unengaged."}
			for model: int in window.positions:
				state.units[model].position = window.positions[model]
				state.units[model].moved = true
			state.squads[squad].moved = true
			state.squads[squad].moved_distance = longest
			state.squads[squad].move_type = "normal"
			state.squads[squad].advanced = false
			state.squads[squad].fell_back = false
			_resume(state)
			return {"error": "", "message": "Cato Sicarius made a Normal Move up to 6 inches."}
		_:
			return {"error": "Unsupported Knight Champion of Macragge action."}
	return {"error": ""}

static func position_error(state: Dictionary, model: int, point: Vector2) -> String:
	var window: Dictionary = state.get("unit_abilities", {}).get("window", {})
	if window.get("kind", "") != PLACEMENT or not window.get("positions", {}).has(model): return "Select a model in Cato's pending reaction move."
	if not point.is_finite(): return "Choose a finite destination."
	var unit: Dictionary = state.units[model]
	var radius := float(unit.radius)
	if absf(point.x) + radius > state.board_size.x / 2.0 + 0.001 or absf(point.y) + radius > state.board_size.y / 2.0 + 0.001: return "The whole base must stay on the battlefield."
	if Vector2(window.origins[model]).distance_to(point) > 6.001: return "This model cannot move more than 6 inches for Knight Champion."
	var projected := state.duplicate(true)
	projected.units[model].position = point
	var terrain_error := Terrain.path_error(projected, model, point)
	if not terrain_error.is_empty(): return terrain_error
	if not Geometry.clear_path(state, model, point, 6.0, false): return "This model cannot pass through terrain or blocking enemy bases."
	for other: int in state.units:
		if other == model or state.units[other].wounds <= 0 or not state.units[other].get("on_battlefield", true): continue
		var other_point: Vector2 = Vector2(window.positions[other]) if window.positions.has(other) else state.units[other].position
		if point.distance_to(other_point) < radius + float(state.units[other].radius) - 0.001: return "Bases cannot overlap at the destination."
	return ""
