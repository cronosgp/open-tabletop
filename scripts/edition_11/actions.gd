extends RefCounted
const UnitAbilities = preload("res://scripts/edition_11/unit_abilities.gd")
## Core eligibility/lifecycle plus one explicitly custom training action.
const Morale = preload("res://scripts/edition_11/morale.gd")
const Terrain = preload("res://scripts/edition_11/terrain.gd")
const Geometry = preload("res://scripts/edition_11/contact_movement.gd")
const Objectives = preload("res://scripts/edition_11/objectives.gd")
const AncientFury = preload("res://scripts/edition_11/medusa_ancient_fury.gd")
const MarineEnhancements = preload("res://scripts/edition_11/stormlance_enhancements.gd")
const TemplarVows = preload("res://scripts/edition_11/templar_vows.gd")
const SECURE := "training-secure"
const SECURE_ASSET := "secure-asset"
const SABOTAGE := "sabotage"

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
			if state.units[enemy].wounds > 0 and state.units[enemy].get("on_battlefield", true) and state.units[enemy].owner != state.squads[squad].owner and Geometry.within_engagement(state.units[id], state.units[enemy]): return true
	return false

static func eligibility_error(state: Dictionary, squad: int) -> String:
	if not state.squads.has(squad) or not on_field(state, squad): return "The unit must be on the battlefield."
	var unit: Dictionary = state.squads[squad]
	if keyword(state, squad, ["aircraft", "fortification"]): return "Aircraft and Fortifications cannot start actions."
	if unit.battle_shocked and not UnitAbilities.has(state, squad, "tactical-mainstay"): return "Battle-shocked units cannot start actions."
	var objective_control := int(unit.stats.objective_control) + AncientFury.objective_control_bonus(state, squad)
	var lion_will: Dictionary = state.get("detachment_stratagems", {}).get("lion_will", {}).get(squad, {})
	if int(lion_will.get("turn", -1)) == int(state.get("turn", -2)) and int(lion_will.get("owner", -1)) == int(unit.get("owner", -2)): objective_control += 1
	var for_the_emperor: Dictionary = state.get("detachment_stratagems", {}).get("for_the_emperor", {}).get(squad, {})
	if int(for_the_emperor.get("turn", -1)) == int(state.get("turn", -2)) and int(for_the_emperor.get("owner", -1)) == int(unit.get("owner", -2)): objective_control += 1
	if objective_control <= 0: return "The unit needs positive OC to start an action."
	if engaged(state, squad) and not UnitAbilities.has(state, squad, "tactical-mainstay") and not keyword(state, squad, ["titanic"]): return "Engaged units cannot start actions."
	var action_movement_exception := UnitAbilities.has(state, squad, "flexible-asset") or MarineEnhancements.oathbound_exemplar_active(state, squad)
	if unit.fell_back and not action_movement_exception: return "Units that Fell Back cannot start actions this turn."
	if unit.advanced and not action_movement_exception and not TemplarVows.advance_action_allowed(state, squad): return "Units that Advanced cannot start actions this turn."
	if unit.get("started_action_turn", -1) == state.turn: return "This unit already started an action this turn."
	if str(unit.get("overwatch_block", "")) == "%d:%s" % [state.turn, state.phase]: return "A unit that fired Overwatch cannot start an action until this phase ends."
	if str(unit.get("indirect_shooting_block", "")) == "%d:%s" % [state.turn, state.phase]: return "A unit that used Indirect Shooting cannot start an action until this phase ends."
	return ""

static func shooting_blocked(state: Dictionary, squad: int) -> bool:
	if int(state.squads[squad].get("firing_deck_blocked_until_turn", -1)) == int(state.get("turn", -2)): return true
	return state.squads[squad].get("started_action_turn", -1) == state.turn and not UnitAbilities.has(state, squad, "tactical-mainstay") and not keyword(state, squad, ["titanic"])

static func charge_blocked(state: Dictionary, squad: int) -> bool:
	return state.squads[squad].get("started_action_turn", -1) == state.turn or state.squads[squad].get("cannot_charge_until_turn", -1) == state.turn or state.get("unit_abilities", {}).get("used", {}).get("purgation-charge-block:%d:%d" % [squad, int(state.turn)], false)

static func targets(state: Dictionary, squad: int) -> Array[int]:
	var result: Array[int] = []
	var objectives: Array = state.get("mission", {}).get("objectives", [])
	for index in range(objectives.size()):
		if objectives[index].controller == state.squads[squad].owner and squad in Objectives.controlling_squads(state, objectives[index], Callable(Morale, "objective_control")): result.append(index)
	return result

static func mission_actions(state: Dictionary, player: int) -> Array:
	var mission: Dictionary = state.get("mission", {})
	var by_player: Variant = mission.get("actions_by_player", {})
	if by_player is Dictionary and (by_player.has(player) or by_player.has(str(player))):
		var selected: Variant = by_player.get(player, by_player.get(str(player), []))
		return selected if selected is Array else []
	return mission.get("actions", [])

static func has_mission_action(state: Dictionary, player: int, action_id: String) -> bool:
	return action_id in mission_actions(state, player)

static func _mission_action_for_squad(state: Dictionary, squad: int) -> String:
	var owner := int(state.get("squads", {}).get(squad, {}).get("owner", -1))
	if has_mission_action(state, owner, SABOTAGE): return SABOTAGE
	return SECURE_ASSET if has_mission_action(state, owner, SECURE_ASSET) else SECURE

static func action_targets(state: Dictionary, squad: int) -> Array[int]:
	var result: Array[int] = []
	if not state.get("squads", {}).has(squad): return result
	var owner := int(state.squads[squad].get("owner", -1))
	if _mission_action_for_squad(state, squad) != SABOTAGE: return targets(state, squad)
	var objectives: Array = state.get("mission", {}).get("objectives", [])
	var home_role := "attacker" if owner == int(state.get("mission", {}).get("attacker", 0)) else "defender"
	for index in range(objectives.size()):
		if str(objectives[index].get("role", "")) == home_role: continue
		for model: int in Morale.living(state, squad):
			if Objectives.in_range(state.units[model], objectives[index]):
				result.append(index)
				break
	return result

static func start_error(state: Dictionary, squad: int, objective: int) -> String:
	var error := eligibility_error(state, squad)
	if not error.is_empty(): return error
	var owner := int(state.squads[squad].owner)
	var action_id := _mission_action_for_squad(state, squad)
	if not has_mission_action(state, owner, action_id): return "This mission does not offer this action."
	if action_id in [SECURE_ASSET, SABOTAGE]:
		var objectives: Array = state.get("mission", {}).get("objectives", [])
		if objective < 0 or objective >= objectives.size(): return "Select a valid objective."
		var home_role := "attacker" if owner == int(state.mission.get("attacker", 0)) else "defender"
		if str(objectives[objective].get("role", "")) == home_role: return "This mission action cannot target your home objective."
	if state.phase != "shooting" or state.squads[squad].owner != state.active: return "Start this action during your Shooting phase."
	if not state.pending_move.is_empty() or not state.pending_contact.is_empty(): return "Finish pending placement first."
	if state.squads[squad].shot: return "A unit that has already shot this phase cannot start an action."
	if action_id != SABOTAGE:
		for other: int in state.squads:
			if state.squads[other].owner == state.active and state.squads[other].get("started_action_turn", -1) == state.turn:
				return "This action can start once per army per turn."
	if objective not in action_targets(state, squad):
		return "Select an objective within range of this unit." if action_id == SABOTAGE else "Select a controlled objective within range of this unit."
	if action_id == SABOTAGE:
		var starts: Dictionary = state.get("mission", {}).get("sabotage_started_objectives", {})
		var player_starts: Dictionary = starts.get(owner, starts.get(str(owner), {}))
		if int(player_starts.get("turn", -1)) == int(state.turn) and objective in player_starts.get("objectives", []):
			return "Each unit that starts Sabotage this phase must be within range of a different objective."
	return ""

static func start(state: Dictionary, squad: int, objective: int) -> void:
	state.squads[squad].started_action_turn = state.turn
	var action_id := _mission_action_for_squad(state, squad)
	state.squads[squad].action = {"id": action_id, "objective": objective, "turn": state.turn}
	if action_id == SABOTAGE:
		if not state.mission.get("sabotage_started_objectives", null) is Dictionary: state.mission.sabotage_started_objectives = {}
		var starts: Dictionary = state.mission.sabotage_started_objectives
		var owner := int(state.squads[squad].owner)
		var player_starts: Dictionary = starts.get(owner, starts.get(str(owner), {"turn": -1, "objectives": []}))
		if int(player_starts.get("turn", -1)) != int(state.turn): player_starts = {"turn": int(state.turn), "objectives": []}
		var selected_objectives: Array = player_starts.get("objectives", []).duplicate()
		if objective not in selected_objectives: selected_objectives.append(objective)
		starts[owner] = {"turn": int(state.turn), "objectives": selected_objectives}

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
		if str(action.id) == SECURE_ASSET:
			state.mission.asset_secured_turn[state.squads[squad].owner] = state.turn
		elif str(action.id) == SABOTAGE:
			if not state.mission.get("sabotage_committed_units", null) is Dictionary: state.mission.sabotage_committed_units = {1: [], 2: []}
			var owner := int(state.squads[squad].owner)
			var committed: Array = state.mission.sabotage_committed_units.get(owner, state.mission.sabotage_committed_units.get(str(owner), []))
			committed.append({"turn": int(state.turn), "squad": squad})
			state.mission.sabotage_committed_units[owner] = committed
		else:
			var error := Objectives.secure(state, action.objective, state.squads[squad].owner)
			if not error.is_empty():
				interrupt(state, squad, error)
				continue
		state.squads[squad].last_action = {"id": action.id, "objective": action.objective, "turn": action.turn, "status": "completed"}
		state.squads[squad].action = {}
		var action_name := "Secure Asset" if str(action.id) == SECURE_ASSET else "Sabotage" if str(action.id) == SABOTAGE else "Secure Ground"
		state.events.append({"revision": state.revision + 1, "message": "%s completed %s at %s." % [state.squads[squad].name, action_name, state.mission.objectives[action.objective].name]})
