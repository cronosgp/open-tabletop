extends RefCounted
## Fenrisian Wolves' reactive Normal Move and Hunting Hounds OC.
const Geometry = preload("res://scripts/edition_11/contact_movement.gd")
const Terrain = preload("res://scripts/edition_11/terrain.gd")
const Queue = preload("res://scripts/edition_11/fight_queue.gd")
const UnitAbilities = preload("res://scripts/edition_11/unit_abilities.gd")

const WINDOW := "predatory-instinct"
const PLACEMENT := "predatory-instinct-placement"

static func _used_key(squad: int, round: int) -> String:
	return "fenrisian-predatory-instinct:%d:%d" % [squad, round]

static func open_after_enemy_move(state: Dictionary, moved_squad: int) -> void:
	if state.get("phase", "") != "movement" or not state.get("squads", {}).has(moved_squad): return
	if int(state.squads[moved_squad].get("owner", -1)) != int(state.get("active", -1)): return
	var owner := 3 - int(state.active)
	var eligible: Array[int] = []
	for candidate: int in state.squads:
		var squad: Dictionary = state.squads[candidate]
		if int(squad.get("owner", -1)) != owner or Queue.engaged(state, candidate): continue
		var candidate_models := Geometry.alive(state, candidate)
		if candidate_models.is_empty() or UnitAbilities.identity(state.units[candidate_models[0]]) != "fenrisian-wolves": continue
		if not UnitAbilities.has(state, candidate, "predatory-instinct") or state.unit_abilities.used.has(_used_key(candidate, int(state.get("round", 0)))): continue
		var distance := INF
		for model: int in Geometry.alive(state, candidate):
			if not state.units[model].get("on_battlefield", true): continue
			for target: int in Geometry.alive(state, moved_squad):
				if not state.units[target].get("on_battlefield", true): continue
				distance = minf(distance, Geometry.edge(state.units[model], state.units[target]))
		if distance <= 8.001: eligible.append(candidate)
	if eligible.is_empty(): return
	var next_window: Dictionary = state.unit_abilities.get("window", {}).duplicate(true)
	for squad: int in eligible:
		var source := Geometry.alive(state, squad)[0]
		next_window = {"kind": WINDOW, "owners": [owner], "squad": squad, "source": source, "trigger": moved_squad, "resume_window": next_window}
	state.unit_abilities.window = next_window

static func choices(state: Dictionary, player: int) -> Array[Dictionary]:
	var window: Dictionary = state.get("unit_abilities", {}).get("window", {})
	if window.get("kind", "") not in [WINDOW, PLACEMENT] or window.get("owners", []) != [player]: return []
	if window.kind == WINDOW:
		return [
			{"label": "Fenrisian Wolves: Predatory Instinct — Normal Move up to D6 inches", "action": "predatory-instinct-use", "model": int(window.source), "target": int(window.squad), "value": ""},
			{"label": "Decline Predatory Instinct", "action": "predatory-instinct-pass", "model": int(window.source), "target": int(window.squad), "value": ""}
		]
	var result: Array[Dictionary] = []
	for model: int in window.positions:
		result.append({"label": "Fenrisian Wolves: preview model %d" % model, "action": "predatory-instinct-place", "model": model, "target": int(window.squad), "value": ""})
	result.append({"label": "Confirm Fenrisian Wolves Normal Move (up to %d inches)" % int(window.distance), "action": "predatory-instinct-confirm", "model": -1, "target": int(window.squad), "value": ""})
	return result

static func _resume(state: Dictionary) -> void:
	state.unit_abilities.window = state.unit_abilities.window.get("resume_window", {})

static func apply(state: Dictionary, player: int, selected: Dictionary, point: Vector2, roller: Callable) -> Dictionary:
	var window: Dictionary = state.get("unit_abilities", {}).get("window", {})
	var squad := int(selected.get("target", -1))
	if window.get("kind", "") == WINDOW:
		if window.get("owners", []) != [player] or int(window.get("squad", -1)) != squad: return {"error": "This Predatory Instinct decision belongs to the Fenrisian Wolves' player."}
		if selected.get("action", "") == "predatory-instinct-pass":
			_resume(state)
			return {"error": ""}
		if selected.get("action", "") != "predatory-instinct-use": return {"error": "Choose to use or decline Predatory Instinct."}
		if not state.squads.has(squad) or Queue.engaged(state, squad) or Geometry.alive(state, squad).is_empty() or not UnitAbilities.has(state, squad, "predatory-instinct"):
			return {"error": "Predatory Instinct requires a living, unengaged Fenrisian Wolves unit."}
		if state.phase != "movement" or int(state.active) == player or not state.squads.has(int(window.get("trigger", -1))):
			return {"error": "Predatory Instinct requires the current opponent Movement-phase reaction."}
		var die: Variant = roller.call()
		if not die is int or int(die) < 1 or int(die) > 6: return {"error": "Predatory Instinct requires a valid D6 result."}
		var origins := {}
		var positions := {}
		for model: int in Geometry.alive(state, squad):
			if not state.units[model].get("on_battlefield", true): continue
			origins[model] = state.units[model].position
			positions[model] = state.units[model].position
		if positions.is_empty(): return {"error": "Predatory Instinct requires the unit to remain on the battlefield."}
		state.unit_abilities.used[_used_key(squad, int(state.get("round", 0)))] = true
		state.unit_abilities.window = {"kind": PLACEMENT, "owners": [player], "squad": squad, "source": int(window.get("source", -1)), "trigger": int(window.get("trigger", -1)), "distance": int(die), "origins": origins, "positions": positions, "resume_window": window.get("resume_window", {})}
		return {"error": "", "message": "Predatory Instinct rolled %d; Fenrisian Wolves may make a Normal Move up to %d inches." % [int(die), int(die)]}
	if window.get("kind", "") != PLACEMENT or window.get("owners", []) != [player] or int(window.get("squad", -1)) != squad:
		return {"error": "No Fenrisian Wolves reaction move is pending."}
	match selected.get("action", ""):
		"predatory-instinct-place":
			var error := position_error(state, int(selected.get("model", -1)), point)
			if not error.is_empty(): return {"error": error}
			window.positions[int(selected.model)] = point
		"predatory-instinct-confirm":
			var projected := state.duplicate(true)
			var longest := 0.0
			for model: int in window.positions:
				var error := position_error(state, model, Vector2(window.positions[model]))
				if not error.is_empty(): return {"error": error}
				projected.units[model].position = window.positions[model]
				longest = maxf(longest, Vector2(window.origins[model]).distance_to(Vector2(window.positions[model])))
			if not Geometry.coherent(projected, squad) or Queue.engaged(projected, squad): return {"error": "Predatory Instinct must preserve coherency and end unengaged."}
			for model: int in window.positions:
				state.units[model].position = window.positions[model]
				state.units[model].moved = true
			state.squads[squad].moved = true
			state.squads[squad].moved_distance = longest
			state.squads[squad].move_type = "normal"
			state.squads[squad].advanced = false
			state.squads[squad].fell_back = false
			_resume(state)
			return {"error": "", "message": "Fenrisian Wolves made a Normal Move up to %d inches." % int(window.distance)}
		_:
			return {"error": "Unsupported Predatory Instinct action."}
	return {"error": ""}

static func position_error(state: Dictionary, model: int, point: Vector2) -> String:
	var window: Dictionary = state.get("unit_abilities", {}).get("window", {})
	if window.get("kind", "") != PLACEMENT or not window.get("positions", {}).has(model): return "Select a model in the pending Fenrisian Wolves move."
	if not point.is_finite(): return "Choose a finite destination."
	var unit: Dictionary = state.units[model]
	var radius := float(unit.radius)
	if absf(point.x) + radius > state.board_size.x / 2.0 + 0.001 or absf(point.y) + radius > state.board_size.y / 2.0 + 0.001: return "The whole base must stay on the battlefield."
	var distance := int(window.get("distance", 0))
	if Vector2(window.origins[model]).distance_to(point) > float(distance) + 0.001: return "This model cannot move farther than the Predatory Instinct D6 result."
	var projected := state.duplicate(true)
	projected.units[model].position = point
	var terrain_error := Terrain.path_error(projected, model, point)
	if not terrain_error.is_empty(): return terrain_error
	if not Geometry.clear_path(state, model, point, float(distance), false): return "This model cannot pass through terrain or blocking enemy bases."
	for other: int in state.units:
		if other == model or int(state.units[other].get("wounds", 0)) <= 0 or not state.units[other].get("on_battlefield", true): continue
		var other_point: Vector2 = Vector2(window.positions[other]) if window.positions.has(other) else state.units[other].position
		if point.distance_to(other_point) < radius + float(state.units[other].radius) - 0.001: return "Bases cannot overlap at the destination."
	return ""

static func hunting_hounds_bonus(state: Dictionary, model: int) -> int:
	if not state.get("units", {}).has(model): return 0
	var unit: Dictionary = state.units[model]
	var squad := int(unit.get("squad", -1))
	if not UnitAbilities.has(state, squad, "hunting-hounds"): return 0
	if not state.squads.has(squad) or bool(state.squads[squad].get("battle_shocked", false)): return 0
	var identity := UnitAbilities.identity(unit)
	var wolf_scout_hunting_wolf := identity == "wolf-scouts" and str(unit.get("wolf_scouts_role", "")) == "Hunting Wolf"
	var headtaker_hunting_wolf := identity == "wolf-guard-headtakers" and str(unit.get("wolf_guard_headtaker_role", "")) == "hunting-wolf"
	if identity != "fenrisian-wolves" and not bool(unit.get("fenrisian_hunting_wolf", false)) and not wolf_scout_hunting_wolf and not headtaker_hunting_wolf: return 0
	for character: int in state.units:
		var candidate: Dictionary = state.units[character]
		if int(candidate.get("owner", -1)) != int(unit.get("owner", -2)) or int(candidate.get("wounds", 0)) <= 0 or not candidate.get("on_battlefield", true): continue
		var keywords: Array = candidate.get("keywords", [])
		if "CHARACTER" not in keywords or "SPACE WOLVES" not in keywords or "WULFEN" in keywords: continue
		if Geometry.edge(unit, candidate) <= 6.001: return 1
	return 0
