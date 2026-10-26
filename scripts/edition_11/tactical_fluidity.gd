extends RefCounted
## Shared movement preview and confirmation path for tactical rules.
const Geometry = preload("res://scripts/edition_11/contact_movement.gd")
const Terrain = preload("res://scripts/edition_11/terrain.gd")
const Queue = preload("res://scripts/edition_11/fight_queue.gd")
const RandomStat = preload("res://scripts/edition_11/random_characteristic.gd")
const Doctrines = preload("res://scripts/edition_11/combat_doctrines.gd")
const UnitAbilities = preload("res://scripts/edition_11/unit_abilities.gd")
const ObjectiveRules = preload("res://scripts/edition_11/objectives.gd")
const AncientFury = preload("res://scripts/edition_11/medusa_ancient_fury.gd")

const WINDOW := "tactical-fluidity"
const PLACEMENT := "tactical-fluidity-placement"

static func _used_key(squad: int, round_number: int) -> String:
	return "tactical-fluidity:%d:%d" % [squad, round_number]

static func _normal_move_phase_key(state: Dictionary) -> String:
	return "%d:%s:%d" % [int(state.get("turn", 0)), str(state.get("phase", "")), int(state.get("active", -1))]

static func normal_move_used_this_phase(state: Dictionary, squad: int) -> bool:
	if not state.get("squads", {}).has(squad): return false
	return str(state.squads[squad].get("normal_move_phase_key", "")) == _normal_move_phase_key(state)

static func mark_normal_move_used_this_phase(state: Dictionary, squad: int) -> void:
	if state.get("squads", {}).has(squad): state.squads[squad].normal_move_phase_key = _normal_move_phase_key(state)

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
		distances[model] = float(state.units[model].movement) + Doctrines.movement_bonus(state, squad) + AncientFury.movement_bonus(state, squad)
	state.unit_abilities.window = {"kind": PLACEMENT, "owners": [player], "squad": squad, "mode": mode, "distance": 0, "distance_by_model": distances, "origins": origins, "positions": positions, "wind_swift": true, "resume_window": resume_window}

static func _eligible(state: Dictionary, squad: int, owner: int, mode: String) -> bool:
	if not state.squads.has(squad) or int(state.squads[squad].owner) != owner: return false
	if not state.unit_abilities.used.get(_used_key(squad, int(state.round)), false):
		if not Geometry.alive(state, squad).is_empty():
			var has_source := false
			for model: int in Geometry.alive(state, squad):
				if str(state.units[model].get("definition_id", "")).get_slice(":", 3) == "captain-in-phobos-armour": has_source = true
			if has_source:
				if mode == "shoot" and state.phase == "shooting" and int(state.active) == owner and state.squads[squad].shot and not Queue.engaged(state, squad) and not normal_move_used_this_phase(state, squad): return true
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

static func purgation_push_eligible(state: Dictionary, squad: int, player: int) -> bool:
	if not state.squads.has(squad) or int(state.squads[squad].get("owner", -1)) != player: return false
	if state.phase != "shooting" or int(state.active) != player or not bool(state.squads[squad].get("shot", false)) or Queue.engaged(state, squad): return false
	var models := Geometry.alive(state, squad)
	if models.is_empty(): return false
	for model: int in models:
		if not bool(state.units[model].get("on_battlefield", true)): return false
	return _could_reach_objective(state, models)

static func start_purgation_push(state: Dictionary, player: int, squad: int) -> String:
	if not purgation_push_eligible(state, squad, player): return "Purgation Push requires your unengaged GRAVIS unit after it shoots."
	var origins := {}
	var positions := {}
	var distances := {}
	for model: int in Geometry.alive(state, squad):
		origins[model] = state.units[model].position
		positions[model] = state.units[model].position
		distances[model] = 5.0
	var previous: Dictionary = state.unit_abilities.get("window", {}).duplicate(true)
	state.unit_abilities.window = {"kind": PLACEMENT, "owners": [player], "squad": squad, "mode": "purgation-push", "distance": 5, "distance_by_model": distances, "origins": origins, "positions": positions, "source": "gravis-linebreaker-purgation-push", "resume_window": previous}
	return ""

static func start_we_are_vengeance(state: Dictionary, player: int, squad: int, distance: int) -> String:
	if not state.squads.has(squad) or int(state.squads[squad].get("owner", -1)) != player or Geometry.alive(state, squad).is_empty(): return "We Are Vengeance requires a living friendly Ravenwing Fly unit."
	if distance < 4 or distance > 6: return "We Are Vengeance move distance must be D3+3 inches."
	if Queue.engaged(state, squad): return "We Are Vengeance requires the unit to remain unengaged."
	var origins := {}
	var positions := {}
	var distances := {}
	for model: int in Geometry.alive(state, squad):
		if not bool(state.units[model].get("on_battlefield", true)): return "Every We Are Vengeance model must be on the battlefield."
		origins[model] = state.units[model].position
		positions[model] = state.units[model].position
		distances[model] = float(distance)
	var previous: Dictionary = state.unit_abilities.get("window", {}).duplicate(true)
	state.unit_abilities.window = {"kind": PLACEMENT, "owners": [player], "squad": squad, "mode": "we-are-vengeance", "distance": distance, "distance_by_model": distances, "origins": origins, "positions": positions, "source": "darkflight-we-are-vengeance", "resume_window": previous}
	return ""

static func choices(state: Dictionary, player: int) -> Array:
	var window: Dictionary = state.unit_abilities.get("window", {})
	if window.get("kind", "") not in [WINDOW, PLACEMENT] or int(window.get("owners", [0])[0]) != player: return []
	if window.kind == PLACEMENT:
		var result: Array = []
		var title := "Shadow Masters" if window.get("source", "") == "phobos-shadow-masters" else "Execute and Redeploy" if window.get("source", "") == "phobos-execute-and-redeploy" else "We Are Vengeance" if window.get("source", "") == "darkflight-we-are-vengeance" else "Purgation Push" if window.get("source", "") == "gravis-linebreaker-purgation-push" else ("Wind-Swift Evasion" if window.get("wind_swift", false) else "Wrath of the First Khan" if window.get("source", "") == "storm-swift-onslaught" else "Tactical Fluidity")
		for model: int in window.positions: result.append({"label": "%s: preview model %d" % [title, model], "action": "fluidity-place", "model": model, "target": int(window.squad), "value": ""})
		result.append({"label": "Confirm %s move" % title, "action": "fluidity-confirm", "model": -1, "target": int(window.squad), "value": ""})
		return result
	var movement := int(state.units[Geometry.alive(state, int(window.squad))[0]].get("movement", 0))
	var movement_label := "Normal Move up to D6 inches" if window.mode == "shoot" else "Normal Move up to 6 inches" if window.mode == "execute-redeploy" else ("Normal Move up to %d inches" % movement if window.mode == "normal" else "Fall Back up to %d inches" % movement)
	var storm_swift: bool = window.get("source", "") == "storm-swift-onslaught"
	var squad := int(window.squad)
	var use_available := false
	if storm_swift:
		use_available = squad in suboden_squads(state, player) and (window.mode != "normal" or not normal_move_used_this_phase(state, squad))
	else:
		use_available = _eligible(state, squad, player, str(window.mode))
	var title := "Wrath of the First Khan" if storm_swift else "Tactical Fluidity"
	var result: Array = []
	if use_available:
		result.append({"label": "%s %d: %s — %s" % ["Suboden Khan" if storm_swift else "Captain", int(Geometry.alive(state, int(window.squad))[0]), title, movement_label], "action": "fluidity-use", "model": -1, "target": int(window.squad), "value": ""})
	result.append({"label": "Decline %s" % title, "action": "fluidity-pass", "model": -1, "target": int(window.squad), "value": ""})
	return result

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
		var purgation_push: bool = window.get("source", "") == "gravis-linebreaker-purgation-push"
		var storm_swift: bool = window.get("source", "") == "storm-swift-onslaught"
		var shadow_masters: bool = window.get("source", "") == "phobos-shadow-masters"
		var execute_redeploy: bool = window.get("source", "") == "phobos-execute-and-redeploy"
		if storm_swift:
			if squad not in suboden_squads(state, player) or window.mode != ("fallback" if Queue.engaged(state, squad) else "normal") or (window.mode == "normal" and normal_move_used_this_phase(state, squad)): return {"error": "Wrath of the First Khan's eligibility or engagement state changed before the move."}
		elif purgation_push:
			if window.mode != "purgation-push" or not purgation_push_eligible(state, squad, player): return {"error": "Purgation Push's shooting or engagement condition is no longer met."}
		elif shadow_masters:
			if window.mode != "shoot" or state.phase != "shooting" or int(state.active) != player or not state.squads.has(squad) or int(state.squads[squad].get("owner", -1)) != player or not bool(state.squads[squad].get("shot", false)) or (not UnitAbilities.has_target_keyword(state, squad, "PHOBOS") and not UnitAbilities.has_target_keyword(state, squad, "SCOUT SQUAD")):
				return {"error": "Shadow Masters' shooting-phase, keyword or Normal Move condition is no longer met."}
		elif execute_redeploy:
			if window.mode != "execute-redeploy" or state.phase != "shooting" or int(state.active) != player or not state.squads.has(squad) or int(state.squads[squad].get("owner", -1)) != player or not bool(state.squads[squad].get("shot", false)) or Queue.engaged(state, squad) or normal_move_used_this_phase(state, squad) or not UnitAbilities.has_target_keyword(state, squad, "PHOBOS"):
				return {"error": "Execute and Redeploy's shooting, PHOBOS or Normal Move condition is no longer met."}
		elif not _eligible(state, squad, player, str(window.mode)):
			return {"error": "Tactical Fluidity's phase, engagement or once-per-round condition is no longer met."}
		var distance := 5 if purgation_push else 6
		if storm_swift: distance = int(state.units[Geometry.alive(state, squad)[0]].get("movement", 0))
		if window.mode == "shoot" and not storm_swift and not purgation_push:
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
		elif not shadow_masters and not execute_redeploy: state.unit_abilities.used[_used_key(squad, int(state.round))] = true
		var distance_by_model := {}
		for model: int in origins: distance_by_model[model] = float(state.units[model].get("movement", distance)) if storm_swift else float(distance)
		state.unit_abilities.window = {"kind": PLACEMENT, "owners": [player], "squad": squad, "mode": window.mode, "distance": distance, "distance_by_model": distance_by_model, "origins": origins, "positions": positions, "source": window.get("source", "tactical-fluidity"), "resume_window": window.get("resume_window", {}), "queue": window.get("queue", [])}
		var title := "Shadow Masters" if shadow_masters else "Execute and Redeploy" if execute_redeploy else "Purgation Push" if purgation_push else ("Wrath of the First Khan" if storm_swift else "Tactical Fluidity")
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
			if window.mode in ["shoot", "execute-redeploy", "purgation-push", "we-are-vengeance"] and Queue.engaged(projected, squad): return {"error": "The Normal Move must end unengaged."}
			if window.get("source", "") == "storm-swift-onslaught" and window.mode == "normal" and Queue.engaged(projected, squad): return {"error": "Wrath of the First Khan's Normal Move must end outside Engagement Range."}
			if window.mode == "fallback" and (not Queue.engaged(state, squad) or Queue.engaged(projected, squad)): return {"error": "The Fall Back move must start engaged and end unengaged."}
			var purgation_push: bool = window.get("source", "") == "gravis-linebreaker-purgation-push"
			var shadow_masters: bool = window.get("source", "") == "phobos-shadow-masters"
			var execute_redeploy: bool = window.get("source", "") == "phobos-execute-and-redeploy"
			if purgation_push and not purgation_push_eligible(state, squad, player): return {"error": "Purgation Push's Shooting phase or engagement condition is no longer met."}
			if shadow_masters and (state.phase != "shooting" or int(state.active) != player or not state.squads.has(squad) or not bool(state.squads[squad].get("shot", false)) or (not UnitAbilities.has_target_keyword(state, squad, "PHOBOS") and not UnitAbilities.has_target_keyword(state, squad, "SCOUT SQUAD"))): return {"error": "Shadow Masters' Shooting phase or keyword condition is no longer met."}
			if execute_redeploy and (state.phase != "shooting" or int(state.active) != player or not state.squads.has(squad) or not bool(state.squads[squad].get("shot", false)) or Queue.engaged(state, squad) or normal_move_used_this_phase(state, squad) or not UnitAbilities.has_target_keyword(state, squad, "PHOBOS")): return {"error": "Execute and Redeploy's Shooting phase, unengaged or Normal Move condition is no longer met."}
			if purgation_push and not _within_objective_range(projected, squad): return {"error": "Purgation Push must end within range of an objective."}
			for model: int in window.positions:
				state.units[model].position = window.positions[model]
				state.units[model].moved = true
			state.squads[squad].moved = true
			state.squads[squad].moved_distance = longest
			var normal_move: bool = window.mode in ["shoot", "execute-redeploy", "normal", "purgation-push", "we-are-vengeance"]
			state.squads[squad].move_type = "normal" if normal_move else "fall_back"
			if normal_move:
				state.squads[squad].normal_moved_this_turn = true
				mark_normal_move_used_this_phase(state, squad)
			state.squads[squad].advanced = false
			state.squads[squad].fell_back = window.mode == "fallback"
			if purgation_push or shadow_masters or execute_redeploy:
				state.squads[squad].cannot_charge_until_turn = int(state.turn)
			if purgation_push:
				state.squads[squad].cannot_embark_until_turn = int(state.turn)
			var wind_swift: bool = window.get("wind_swift", false)
			var storm_swift: bool = window.get("source", "") == "storm-swift-onslaught"
			state.unit_abilities.window = window.get("resume_window", {}) if wind_swift or storm_swift or purgation_push or shadow_masters or execute_redeploy else window
			if not wind_swift and not storm_swift and not purgation_push and not shadow_masters and not execute_redeploy: _advance(state)
			var source := "We Are Vengeance" if window.get("source", "") == "darkflight-we-are-vengeance" else "Wind-Swift Evasion" if wind_swift else "Wrath of the First Khan" if storm_swift else "Tactical Fluidity"
			if purgation_push: source = "Purgation Push"
			if shadow_masters: source = "Shadow Masters"
			if execute_redeploy: source = "Execute and Redeploy"
			if shadow_masters: return {"error": "", "message": "Shadow Masters Normal Move completed; this unit cannot Charge until the end of the turn."}
			if purgation_push: return {"error": "", "message": "Purgation Push Normal Move completed; this unit cannot Charge or embark until the end of the turn."}
			if execute_redeploy: return {"error": "", "message": "Execute and Redeploy Normal Move completed; this unit cannot Charge until the end of the turn."}
			return {"error": "", "message": "%s %s completed; %.2f inches maximum model movement." % [source, "Normal Move" if normal_move else "Fall Back", longest]}
		_:
			return {"error": "Unsupported Tactical Fluidity action."}
	return {"error": ""}

static func position_error(state: Dictionary, model: int, point: Vector2) -> String:
	var window: Dictionary = state.get("unit_abilities", {}).get("window", {})
	if window.get("kind", "") != PLACEMENT or not window.get("positions", {}).has(model): return "Select a model in the pending %s move." % ("Purgation Push" if window.get("source", "") == "gravis-linebreaker-purgation-push" else "Tactical Fluidity")
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

static func _within_objective_range(state: Dictionary, squad: int) -> bool:
	var objectives: Array = state.get("mission", {}).get("objectives", [])
	for model: int in Geometry.alive(state, squad):
		if not bool(state.units[model].get("on_battlefield", true)): continue
		for objective_value: Variant in objectives:
			if objective_value is Dictionary and ObjectiveRules.in_range(state.units[model], objective_value): return true
	return false

static func _could_reach_objective(state: Dictionary, models: Array[int]) -> bool:
	var objectives: Array = state.get("mission", {}).get("objectives", [])
	for model: int in models:
		for objective_value: Variant in objectives:
			if not objective_value is Dictionary: continue
			var terrain_objective := str(objective_value.get("kind", "")) == "terrain"
			if not terrain_objective and float(state.units[model].get("elevation", 0.0)) > 5.0 + Terrain.EPSILON: continue
			var limit := 5.0 if terrain_objective else 8.0
			if ObjectiveRules.distance(state.units[model], objective_value) <= limit + Terrain.EPSILON: return true
	return false
