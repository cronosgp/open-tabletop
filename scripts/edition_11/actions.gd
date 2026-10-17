extends RefCounted
const UnitAbilities = preload("res://scripts/edition_11/unit_abilities.gd")
## Core eligibility/lifecycle plus one explicitly custom training action.
const Morale = preload("res://scripts/edition_11/morale.gd")
const Terrain = preload("res://scripts/edition_11/terrain.gd")
const Geometry = preload("res://scripts/edition_11/contact_movement.gd")
const Objectives = preload("res://scripts/edition_11/objectives.gd")
const SECURE := "training-secure"

static func keyword(state: Dictionary, squad: int, names: Array[String]) -> bool:
	for id: int in Morale.living(state, squad):
		if Terrain.has_keyword(state.units[id], names): return true
	return false

static func on_field(state: Dictionary, squad: int) -> bool:
	for id: int in Morale.living(state, squad):
		if state.units[id].get("on_battlefield", true): return true
	return false

static func engaged(state: Dictionary, squad: int) -> bool:
	for id: int in Morale.living(state, squad):
		for enemy: int in state.units:
			if state.units[enemy].wounds > 0 and state.units[enemy].get("on_battlefield", true) and state.units[enemy].owner != state.squads[squad].owner and Geometry.edge(state.units[id], state.units[enemy]) <= 2.0 + Terrain.EPSILON: return true
	return false

static func eligibility_error(state: Dictionary, squad: int) -> String:
	if not state.squads.has(squad) or not on_field(state, squad): return "The unit must be on the battlefield."
	var unit: Dictionary = state.squads[squad]
	if keyword(state, squad, ["aircraft", "fortification"]): return "Aircraft and Fortifications cannot start actions."
	if unit.battle_shocked and not UnitAbilities.has(state, squad, "tactical-mainstay"): return "Battle-shocked units cannot start actions."
	if int(unit.stats.objective_control) <= 0: return "The unit needs positive OC to start an action."
	if engaged(state, squad) and not UnitAbilities.has(state, squad, "tactical-mainstay") and not keyword(state, squad, ["titanic"]): return "Engaged units cannot start actions."
	if unit.advanced or unit.fell_back: return "Units that Advanced or Fell Back cannot start actions this turn."
	if unit.get("started_action_turn", -1) == state.turn: return "This unit already started an action this turn."
	if str(unit.get("overwatch_block", "")) == "%d:%s" % [state.turn, state.phase]: return "A unit that fired Overwatch cannot start an action until this phase ends."
	return ""

static func shooting_blocked(state: Dictionary, squad: int) -> bool:
	return state.squads[squad].get("started_action_turn", -1) == state.turn and not UnitAbilities.has(state, squad, "tactical-mainstay") and not keyword(state, squad, ["titanic"])

static func charge_blocked(state: Dictionary, squad: int) -> bool:
	return state.squads[squad].get("started_action_turn", -1) == state.turn

static func targets(state: Dictionary, squad: int) -> Array[int]:
	var result: Array[int] = []
	var objectives: Array = state.get("mission", {}).get("objectives", [])
	for index in range(objectives.size()):
		if objectives[index].controller == state.squads[squad].owner and squad in Objectives.controlling_squads(state, objectives[index]): result.append(index)
	return result

static func start_error(state: Dictionary, squad: int, objective: int) -> String:
	var error := eligibility_error(state, squad)
	if not error.is_empty(): return error
	if SECURE not in state.get("mission", {}).get("actions", []): return "This mission does not offer the training action."
	if state.phase != "shooting" or state.squads[squad].owner != state.active: return "Start Secure Ground during your Shooting phase."
	if not state.pending_move.is_empty() or not state.pending_contact.is_empty(): return "Finish pending placement first."
	if state.squads[squad].shot: return "Secure Ground requires a unit that has not shot this phase."
	for other: int in state.squads:
		if state.squads[other].owner == state.active and state.squads[other].get("started_action_turn", -1) == state.turn:
			return "Secure Ground can start once per army per turn."
	if objective not in targets(state, squad): return "Select a controlled objective within range of this unit."
	return ""

static func start(state: Dictionary, squad: int, objective: int) -> void:
	state.squads[squad].started_action_turn = state.turn
	state.squads[squad].action = {"id": SECURE, "objective": objective, "turn": state.turn}

static func interrupt(state: Dictionary, squad: int, reason: String) -> void:
	var action: Dictionary = state.squads[squad].get("action", {})
	if action.is_empty(): return
	state.squads[squad].last_action = {"id": action.id, "objective": action.objective, "turn": action.turn, "status": "failed", "reason": reason}
	state.squads[squad].action = {}
	state.events.append({"revision": state.revision + 1, "message": "%s action failed: %s." % [state.squads[squad].name, reason]})

static func reconcile(state: Dictionary) -> void:
	for squad: int in state.squads:
		if state.squads[squad].get("action", {}).is_empty(): continue
		if not on_field(state, squad): interrupt(state, squad, "unit destroyed or left battlefield")
		elif state.squads[squad].battle_shocked and not UnitAbilities.has(state, squad, "tactical-mainstay"): interrupt(state, squad, "unit became battle-shocked")

static func complete_end_turn(state: Dictionary) -> void:
	reconcile(state)
	for squad: int in state.squads:
		var action: Dictionary = state.squads[squad].get("action", {})
		if action.is_empty() or action.turn != state.turn: continue
		if action.objective not in targets(state, squad):
			interrupt(state, squad, "unit no longer controls the chosen objective from within range")
			continue
		var error := Objectives.secure(state, action.objective, state.squads[squad].owner)
		if not error.is_empty():
			interrupt(state, squad, error)
			continue
		state.squads[squad].last_action = {"id": action.id, "objective": action.objective, "turn": action.turn, "status": "completed"}
		state.squads[squad].action = {}
		state.events.append({"revision": state.revision + 1, "message": "%s completed Secure Ground: %s secured." % [state.squads[squad].name, state.mission.objectives[action.objective].name]})
