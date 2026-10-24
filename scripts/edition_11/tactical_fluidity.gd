extends RefCounted
## Captain in Phobos Armour reaction, transcribed from the local Wahapedia 11e export.
const Geometry = preload("res://scripts/edition_11/contact_movement.gd")
const Terrain = preload("res://scripts/edition_11/terrain.gd")
const Queue = preload("res://scripts/edition_11/fight_queue.gd")
const RandomStat = preload("res://scripts/edition_11/random_characteristic.gd")
const Doctrines = preload("res://scripts/edition_11/combat_doctrines.gd")
const UnitAbilities = preload("res://scripts/edition_11/unit_abilities.gd")

const WINDOW := "tactical-fluidity"
const PLACEMENT := "tactical-fluidity-placement"

static func _used_key(squad: int, round_number: int) -> String:
	return "tactical-fluidity:%d:%d" % [squad, round_number]

static func wind_mode(state: Dictionary, squad: int) -> String:
	if not state.squads.has(squad): return ""
	return "fallback" if Queue.engaged(state, squad) else "shoot"

static func start_wind(state: Dictionary, player: int, squad: int, mode: String) -> void:
	var resume_window: Dictionary = state.unit_abilities.get("window", {}).duplicate(true)
	var origins := {}
	var positions := {}
	var distances := {}
	for model: int in Geometry.alive(state, squad):
		origins[model] = state.units[model].position
		positions[model] = state.units[model].position
		distances[model] = float(state.units[model].movement) + Doctrines.movement_bonus(state, squad)
	state.unit_abilities.window = {"kind": PLACEMENT, "owners": [player], "squad": squad, "mode": mode, "distance": 0, "distance_by_model": distances, "origins": origins, "positions": positions, "wind_swift": true, "resume_window": resume_window}

static func _eligible(state: Dictionary, squad: int, owner: int, mode: String) -> bool:
	if not state.squads.has(squad) or int(state.squads[squad].owner) != owner: return false
	if not state.unit_abilities.used.get(_used_key(squad, int(state.round)), false):
		if not Geometry.alive(state, squad).is_empty():
			var has_source := false
			for model: int in Geometry.alive(state, squad):
				if str(state.units[model].get("definition_id", "")).get_slice(":", 3) == "captain-in-phobos-armour": has_source = true
			if has_source:
				if mode == "shoot" and state.phase == "shooting" and int(state.active) == owner and state.squads[squad].shot and not Queue.engaged(state, squad): return true
				if mode == "fallback" and state.phase == "fight" and int(state.active) != owner and Queue.engaged(state, squad): return true
	return false

static func suboden_squads(state: Dictionary, owner: int) -> Array[int]:
	var result: Array[int] = []
	if state.phase != "fight" or not Doctrines.enabled(state) or Doctrines.detachment_for(state, owner) != "spearpoint-task-force": return result
	if owner not in state.combat_doctrines.get("owners", []): return result
	for squad: int in state.squads:
		if int(state.squads[squad].get("owner", -1)) != owner: continue
		if not state.squads[squad].get("fight_eligible", false): continue
		if Geometry.alive(state, squad).is_empty(): continue
		var has_living_suboden := false
		for model: int in Geometry.alive(state, squad):
			if not state.units[model].get("on_battlefield", true): continue
			if UnitAbilities.identity(state.units[model]) == "suboden-khan": has_living_suboden = true
		if not has_living_suboden: continue
		var use_key := "storm-swift-onslaught:%d:%d:%s" % [squad, int(state.turn), str(state.phase)]
		if state.get("unit_abilities", {}).get("used", {}).get(use_key, false): continue
		result.append(squad)
	return result

static func end_fight_squads(state: Dictionary, owner: int) -> Array[int]:
	var result := suboden_squads(state, owner)
	if state.phase != "fight": return result
	for squad: int in state.squads:
		if squad in result: continue
		var passed_key := "tactical-fluidity-end:%d:%d" % [squad, int(state.turn)]
		if state.unit_abilities.get("used", {}).get(passed_key, false): continue
		if _eligible(state, squad, owner, "fallback"): result.append(squad)
	return result

static func start_end_fight(state: Dictionary, player: int, squad: int) -> String:
	if squad in suboden_squads(state, player): return start_storm_swift(state, player, squad)
	if not _eligible(state, squad, player, "fallback"): return "Tactical Fluidity requires its living Captain in a unit engaged at the end of the opponent's Fight phase."
	var previous: Dictionary = state.unit_abilities.get("window", {}).duplicate(true)
	state.unit_abilities.window = {"kind": WINDOW, "owners": [player], "squad": squad, "mode": "fallback", "source": "tactical-fluidity", "resume_window": previous}
	return ""

static func start_storm_swift(state: Dictionary, player: int, squad: int) -> String:
	if squad not in suboden_squads(state, player): return "Wrath of the First Khan requires Suboden Khan's unit to have been eligible to fight this phase."
	var mode := "fallback" if Queue.engaged(state, squad) else "normal"
	state.unit_abilities.window = {"kind": WINDOW, "owners": [player], "squad": squad, "mode": mode, "source": "storm-swift-onslaught", "resume_window": state.unit_abilities.get("window", {}).duplicate(true)}
	return ""

static func open_after_shot(state: Dictionary, squad: int) -> void:
	if not _eligible(state, squad, int(state.active), "shoot"): return
	var previous: Dictionary = state.unit_abilities.get("window", {}).duplicate(true)
	state.unit_abilities.window = {"kind": WINDOW, "owners": [int(state.active)], "squad": squad, "mode": "shoot", "source": "tactical-fluidity", "resume_window": previous}

static func choices(state: Dictionary, player: int) -> Array:
	var window: Dictionary = state.unit_abilities.get("window", {})
	if window.get("kind", "") not in [WINDOW, PLACEMENT] or int(window.get("owners", [0])[0]) != player: return []
	if window.kind == PLACEMENT:
		var result: Array = []
		var title := "Wind-Swift Evasion" if window.get("wind_swift", false) else "Wrath of the First Khan" if window.get("source", "") == "storm-swift-onslaught" else "Tactical Fluidity"
		for model: int in window.positions: result.append({"label": "%s: preview model %d" % [title, model], "action": "fluidity-place", "model": model, "target": int(window.squad), "value": ""})
		result.append({"label": "Confirm %s move" % title, "action": "fluidity-confirm", "model": -1, "target": int(window.squad), "value": ""})
		return result
	var movement := int(state.units[Geometry.alive(state, int(window.squad))[0]].get("movement", 0))
	var movement_label := "Normal Move up to D6 inches" if window.mode == "shoot" else ("Normal Move up to %d inches" % movement if window.mode == "normal" else "Fall Back up to %d inches" % movement)
	return [
		{"label": "%s %d: %s — %s" % ["Suboden Khan" if window.get("source", "") == "storm-swift-onslaught" else "Captain", int(Geometry.alive(state, int(window.squad))[0]), "Wrath of the First Khan" if window.get("source", "") == "storm-swift-onslaught" else "Tactical Fluidity", movement_label], "action": "fluidity-use", "model": -1, "target": int(window.squad), "value": ""},
		{"label": "Decline %s" % ("Wrath of the First Khan" if window.get("source", "") == "storm-swift-onslaught" else "Tactical Fluidity"), "action": "fluidity-pass", "model": -1, "target": int(window.squad), "value": ""}
	]

static func _advance(state: Dictionary) -> void:
	var window: Dictionary = state.unit_abilities.window
	var queue: Array = window.get("queue", [])
	if not queue.is_empty(): queue.pop_front()
	if queue.is_empty(): state.unit_abilities.window = window.get("resume_window", {})
	else:
		window.queue = queue
		window.squad = int(queue[0])
		state.unit_abilities.window = window

static func apply(state: Dictionary, player: int, selected: Dictionary, point: Vector2, roller: Callable) -> Dictionary:
	var window: Dictionary = state.unit_abilities.get("window", {})
	var squad := int(selected.get("target", -1))
	if window.get("kind", "") == WINDOW:
		if int(window.get("owners", [0])[0]) != player or int(window.squad) != squad: return {"error": "This Tactical Fluidity choice belongs to the pending Captain."}
		if selected.action == "fluidity-pass":
			if window.get("source", "") == "storm-swift-onslaught":
				var storm_swift_key := "storm-swift-onslaught:%d:%d:%s" % [squad, int(state.turn), str(state.phase)]
				state.unit_abilities.used[storm_swift_key] = true
			if window.mode == "fallback" and window.get("resume_window", {}).get("kind", "") == "end":
				state.unit_abilities.used["tactical-fluidity-end:%d:%d" % [squad, int(state.turn)]] = true
			_advance(state)
			return {"error": ""}
			if selected.action != "fluidity-use": return {"error": "Choose to use or decline the pending ability."}
		var storm_swift: bool = window.get("source", "") == "storm-swift-onslaught"
		if storm_swift:
			if squad not in suboden_squads(state, player) or window.mode != ("fallback" if Queue.engaged(state, squad) else "normal"): return {"error": "Wrath of the First Khan's eligibility or engagement state changed before the move."}
		elif not _eligible(state, squad, player, str(window.mode)):
			return {"error": "Tactical Fluidity's phase, engagement or once-per-round condition is no longer met."}
		var distance := 6
		if storm_swift: distance = int(state.units[Geometry.alive(state, squad)[0]].get("movement", 0))
		if window.mode == "shoot" and not storm_swift:
			var roll := RandomStat.roll("D6", roller)
			if not roll.error.is_empty(): return roll
			distance = int(roll.value)
		var origins: Dictionary = {}
		var positions: Dictionary = {}
		for model: int in Geometry.alive(state, squad):
			origins[model] = state.units[model].position
			positions[model] = state.units[model].position
		if storm_swift:
			var storm_swift_key := "storm-swift-onslaught:%d:%d:%s" % [squad, int(state.turn), str(state.phase)]
			state.unit_abilities.used[storm_swift_key] = true
		else: state.unit_abilities.used[_used_key(squad, int(state.round))] = true
		var distance_by_model := {}
		for model: int in origins: distance_by_model[model] = float(state.units[model].get("movement", distance)) if storm_swift else float(distance)
		state.unit_abilities.window = {"kind": PLACEMENT, "owners": [player], "squad": squad, "mode": window.mode, "distance": distance, "distance_by_model": distance_by_model, "origins": origins, "positions": positions, "source": window.get("source", "tactical-fluidity"), "resume_window": window.get("resume_window", {}), "queue": window.get("queue", [])}
		var title := "Wrath of the First Khan" if storm_swift else "Tactical Fluidity"
		return {"error": "", "message": "%s: move up to %d inches." % [title, distance]}
	if window.get("kind", "") != PLACEMENT or int(window.get("owners", [0])[0]) != player or int(window.get("squad", -1)) != squad: return {"error": "No Tactical Fluidity move is pending."}
	match selected.action:
		"fluidity-place":
			var error := position_error(state, int(selected.get("model", -1)), point)
			if not error.is_empty(): return {"error": error}
			window.positions[int(selected.model)] = point
		"fluidity-confirm":
			var projected := state.duplicate(true)
			var longest := 0.0
			for model: int in window.positions:
				var error := position_error(state, model, Vector2(window.positions[model]))
				if not error.is_empty(): return {"error": error}
				projected.units[model].position = window.positions[model]
				longest = maxf(longest, Vector2(window.origins[model]).distance_to(Vector2(window.positions[model])))
			if not Geometry.coherent(projected, squad): return {"error": "The move must leave the unit coherent."}
			if window.mode == "shoot" and Queue.engaged(projected, squad): return {"error": "The Normal Move must end unengaged."}
			if window.get("source", "") == "storm-swift-onslaught" and window.mode == "normal" and Queue.engaged(projected, squad): return {"error": "Wrath of the First Khan's Normal Move must end outside Engagement Range."}
			if window.mode == "fallback" and (not Queue.engaged(state, squad) or Queue.engaged(projected, squad)): return {"error": "The Fall Back move must start engaged and end unengaged."}
			for model: int in window.positions:
				state.units[model].position = window.positions[model]
				state.units[model].moved = true
			state.squads[squad].moved = true
			state.squads[squad].moved_distance = longest
			var normal_move: bool = window.mode in ["shoot", "normal"]
			state.squads[squad].move_type = "normal" if normal_move else "fall_back"
			state.squads[squad].advanced = false
			state.squads[squad].fell_back = window.mode == "fallback"
			var wind_swift: bool = window.get("wind_swift", false)
			var storm_swift: bool = window.get("source", "") == "storm-swift-onslaught"
			state.unit_abilities.window = window.get("resume_window", {}) if wind_swift or storm_swift else window
			if not wind_swift and not storm_swift: _advance(state)
			var source := "Wind-Swift Evasion" if wind_swift else "Wrath of the First Khan" if storm_swift else "Tactical Fluidity"
			return {"error": "", "message": "%s %s completed; %.2f inches maximum model movement." % [source, "Normal Move" if normal_move else "Fall Back", longest]}
		_:
			return {"error": "Unsupported Tactical Fluidity action."}
	return {"error": ""}

static func position_error(state: Dictionary, model: int, point: Vector2) -> String:
	var window: Dictionary = state.get("unit_abilities", {}).get("window", {})
	if window.get("kind", "") != PLACEMENT or not window.get("positions", {}).has(model): return "Select a model in the pending Tactical Fluidity move."
	if not point.is_finite(): return "Choose a finite destination."
	var unit: Dictionary = state.units[model]
	var radius := float(unit.radius)
	if absf(point.x) + radius > state.board_size.x / 2.0 + 0.001 or absf(point.y) + radius > state.board_size.y / 2.0 + 0.001: return "The whole base must stay on the battlefield."
	var travel := Vector2(window.origins[model]).distance_to(point)
	var move_limit := float(window.get("distance_by_model", {}).get(model, window.distance))
	if travel > move_limit + 0.001: return "This model exceeds its move distance."
	var projected := state.duplicate(true)
	projected.units[model].position = point
	var terrain_error := Terrain.path_error(projected, model, point)
	if not terrain_error.is_empty(): return terrain_error
	if not Geometry.clear_path(state, model, point, move_limit, false): return "This model cannot move through terrain or blocking enemy bases."
	for other: int in state.units:
		if other == model or state.units[other].wounds <= 0 or not state.units[other].get("on_battlefield", true): continue
		var other_point: Vector2 = Vector2(window.positions.get(other, state.units[other].position)) if window.positions.has(other) else Vector2(state.units[other].position)
		if point.distance_to(other_point) < radius + float(state.units[other].radius) - 0.001: return "Bases cannot overlap at the destination."
	return ""
