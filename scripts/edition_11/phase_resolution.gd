extends RefCounted
## Coordinates phase-boundary effects after common close admission succeeds.
## Rule modules own eligibility and effects; this module owns their boundary order.

const Actions = preload("res://scripts/edition_11/actions.gd")
const Capabilities = preload("res://scripts/edition_11/capabilities.gd")
const CommandBattleShock = preload("res://scripts/edition_11/command_battle_shock.gd")
const Coherency = preload("res://scripts/edition_11/coherency_decision.gd")
const Contact = preload("res://scripts/edition_11/contact_movement.gd")
const DetachmentStratagems = preload("res://scripts/edition_11/detachment_stratagems.gd")
const Doctrines = preload("res://scripts/edition_11/combat_doctrines.gd")
const MarineEnhancements = preload("res://scripts/edition_11/stormlance_enhancements.gd")
const Mission = preload("res://scripts/edition_11/chapter_approved.gd")
const Morale = preload("res://scripts/edition_11/morale.gd")
const ObjectiveSecured = preload("res://scripts/edition_11/objective_secured.gd")
const Objectives = preload("res://scripts/edition_11/objectives.gd")
const OathOfMoment = preload("res://scripts/edition_11/oath_of_moment.gd")
const PhaseProgression = preload("res://scripts/edition_11/phase_progression.gd")
const PhaseCloseGate = preload("res://scripts/edition_11/phase_close_gate.gd")
const Reanimation = preload("res://scripts/edition_11/reanimation_protocols.gd")
const Reivers = preload("res://scripts/edition_11/reivers.gd")
const ResolutionFrames = preload("res://scripts/edition_11/resolution_frame.gd")
const Stratagems = preload("res://scripts/edition_11/stratagems.gd")
const Terrain = preload("res://scripts/edition_11/terrain.gd")
const UnitAbilities = preload("res://scripts/edition_11/unit_abilities.gd")
const UnitActions = preload("res://scripts/edition_11/unit_actions.gd")

## The facade supplies journal/fight hooks to keep this coordinator below it in the dependency graph.
static func advance_after_admission(state: Dictionary, roller: Callable, hooks: Dictionary) -> String:
	var progression_error := PhaseCloseGate.progression_error(state)
	if not progression_error.is_empty(): return progression_error
	var emit_event: Callable = hooks.get("event", Callable())
	var begin_fights: Callable = hooks.get("begin_fights", Callable())

	if state.phase == "start_turn":
		UnitActions.start_round(state)
		Mission.start_turn(state)
	if state.phase == "command":
		if UnitActions.offer_command_healing(state):
			var healing_suspend_error := _suspend_phase_close_for_command_choice(state, "command-phase-healing")
			if not healing_suspend_error.is_empty(): return healing_suspend_error
			emit_event.call(state, "Resolve unit healing before finishing Command.")
			return ""
		var error := Reanimation.phase_error(state)
		if not error.is_empty(): return error
		if not Reanimation.morale_done(state) and not CommandBattleShock.done(state):
			if Stratagems.open_command(state):
				var morale_suspend_error := _suspend_phase_close_for_command_choice(state, "command-battle-shock-decision")
				if not morale_suspend_error.is_empty(): return morale_suspend_error
				emit_event.call(state, "Battle-shock: choose a unit to roll the test or use Insane Bravery before rolling.")
				return ""
			if not state.has("stratagems"):
				var morale: Dictionary = CommandBattleShock.resolve_command(state, roller)
				if not morale.get("error", "").is_empty(): return morale.error
				if morale.get("pending", false):
					var morale_suspend_error := _suspend_phase_close_for_command_choice(state, "command-battle-shock-leadership")
					if not morale_suspend_error.is_empty(): return morale_suspend_error
					emit_event.call(state, "Command Battle-shock: the tested unit's controller must keep the result or use Tempered in Battle.")
					return ""
				for result: Dictionary in morale.get("results", []):
					state.events.append({"revision": state.revision + 1, "message": "%s battle-shock: %s vs %d — %s." % [state.squads[result.squad].name, str(result.rolls), result.target, "passed" if result.passed else "battle-shocked"]})
		_resolve_current_end_control(state)
	_resolve_current_end_control(state)
	var phase_close_action_id := _phase_close_action_id(state)
	var phase_close_frame := ResolutionFrames.begin(state, "phase-close", phase_close_action_id, "after-end-of-phase-decisions")
	if phase_close_frame.is_empty(): return "Could not create a phase-close continuation frame."
	var phase_close_frame_id := str(phase_close_frame.frame_id)
	if state.phase == "command" and Reanimation.open_end_command(state):
		var reanimation_suspend_error := ResolutionFrames.suspend(state, phase_close_frame_id, "resume-after-reanimation-decision")
		if not reanimation_suspend_error.is_empty(): return reanimation_suspend_error
		emit_event.call(state, "End of Command: resolve each Necron unit's Reanimation Protocols.")
		return ""
	if UnitActions.open_end(state):
		var suspend_error := ResolutionFrames.suspend(state, phase_close_frame_id, "resume-after-end-of-phase-decision")
		if not suspend_error.is_empty(): return suspend_error
		emit_event.call(state, "End of phase: resolve or decline optional unit abilities.")
		return ""
	var complete_error := ResolutionFrames.complete(state, phase_close_frame_id)
	if not complete_error.is_empty(): return complete_error
	# Command morale resolves before end-of-phase control. Draft placements never capture.
	if not UnitAbilities.enabled(state) and state.phase in ["command", "movement", "shooting", "charge", "fight"]:
		Objectives.resolve_control(state, Callable(Morale, "objective_control"))
	var ability_note := ObjectiveSecured.end_command(state)
	if state.phase == "end_turn": Actions.complete_end_turn(state)
	if state.phase == "command":
		for healed: Dictionary in MarineEnhancements.ironstorm_command_healing(state, state.active):
			emit_event.call(state, "Redoubtable Machine Spirit restores 1 wound to %s." % str(state.squads[healed.squad].get("name", "Vehicle")))
	if Mission.enabled(state) and Mission.score(state):
		emit_event.call(state, Mission.summary(state))
		return ""
	if state.phase == "end_turn" and state.active != state.get("first_player", 1):
		var scoring := Objectives.score_round(state)
		if not scoring.is_empty():
			if state.test_winner != 0:
				emit_event.call(state, scoring)
				return ""
			state.events.append({"revision": state.revision + 1, "message": scoring})
	if not PhaseProgression.ends_turn(state.phase):
		if state.phase == "fight": DetachmentStratagems.remove_lingering(state)
		if state.phase == "movement":
			_resolve_vanguard_ambushers(state)
			for squad: int in state.squads:
				if state.squads[squad].owner == state.active and not state.squads[squad].moved:
					state.squads[squad].move_type = "stationary"
					state.squads[squad].moved = true
	var error := PhaseProgression.advance(state)
	if not error.is_empty(): return error
	if state.phase == "charge" and state.has("core_reactions"):
		state.core_reactions.chargers = []
		state.core_reactions.charge_closed = false
		state.core_reactions.heroic = {}
	if state.phase == "command":
		UnitAbilities.start_command(state)
		Doctrines.start_command(state)
		OathOfMoment.start_command(state)
		Reanimation.start_command(state)
		if Doctrines.needs_choice(state):
			state.combat_doctrines.cp_pending_turn = state.turn
			var doctrine_action_id := "phase-start:%d:%s:%d" % [int(state.turn), str(state.phase), int(state.active)]
			var doctrine_frame := ResolutionFrames.begin(state, "phase-start", doctrine_action_id, "command-doctrine-selection")
			if doctrine_frame.is_empty(): return "Could not create the Command-start doctrine frame."
			var doctrine_suspend_error := ResolutionFrames.suspend(state, str(doctrine_frame.frame_id), "command-doctrine-selection")
			if not doctrine_suspend_error.is_empty(): return doctrine_suspend_error
		else:
			state.cp[1] += 1
			state.cp[2] += 1
	if state.phase == "fight": begin_fights.call(state)
	if state.phase == "end_turn": Actions.complete_end_turn(state)
	if state.phase == "end_turn" and Coherency.incoherent_squad(state) != -1:
		var coherency_frame := ResolutionFrames.begin(state, "phase-close", _phase_close_action_id(state), "end-turn-coherency-casualties")
		if coherency_frame.is_empty(): return "Could not create the End-of-Turn coherency continuation frame."
		var coherency_suspend_error := ResolutionFrames.suspend(state, str(coherency_frame.frame_id), "end-turn-coherency-casualties")
		if not coherency_suspend_error.is_empty(): return coherency_suspend_error
	emit_event.call(state, "Player %d: %s" % [state.active, state.phase] + (" • " + ability_note if not ability_note.is_empty() else ""))
	if state.phase == "fight" and Reivers.begin_fight(state): emit_event.call(state, "Fearsome Assault: resolve the required Battle-shock tests before the Fight sequence.")
	return ""

static func _phase_close_action_id(state: Dictionary) -> String:
	return "phase-close:%d:%s" % [int(state.get("turn", 0)), str(state.get("phase", ""))]

static func _suspend_phase_close_for_command_choice(state: Dictionary, resume_point: String) -> String:
	var frame := ResolutionFrames.begin(state, "phase-close", _phase_close_action_id(state), resume_point)
	if frame.is_empty(): return "Could not create a Command phase-close continuation frame."
	return ResolutionFrames.suspend(state, str(frame.frame_id), resume_point)

static func _resolve_vanguard_ambushers(state: Dictionary) -> void:
	if not Capabilities.supported("vanguard-ambushers") or Doctrines.detachment_for(state, int(state.active)) != "phobos-shock-force": return
	if not state.combat_doctrines.has("vanguard_ambushers"): state.combat_doctrines.vanguard_ambushers = {}
	for squad: int in state.squads:
		if int(state.squads[squad].owner) != int(state.active): continue
		if not UnitAbilities.has_target_keyword(state, squad, "PHOBOS"): continue
		var alive := Contact.alive(state, squad)
		if alive.is_empty(): continue
		var is_hidden := false
		for model: int in alive:
			if Terrain.hidden(state, model):
				is_hidden = true
				break
		if is_hidden: state.combat_doctrines.vanguard_ambushers[squad] = int(state.turn)

static func _resolve_current_end_control(state: Dictionary) -> void:
	if not UnitAbilities.enabled(state) or (state.phase not in ["command", "movement", "shooting", "charge", "fight"] and not (Mission.enabled(state) and state.phase == "end_turn")): return
	var phase_key := UnitActions.key(state)
	if state.unit_abilities.get("control_done", "") == phase_key: return
	Objectives.resolve_control(state, Callable(Morale, "objective_control"))
	if state.phase == "movement":
		for index in range(state.get("mission", {}).get("objectives", []).size()):
			var objective: Dictionary = state.mission.objectives[index]
			if objective.controller != state.active: continue
			for squad: int in Objectives.controlling_squads(state, objective, Callable(Morale, "objective_control")):
				if UnitAbilities.has(state, squad, "raise-the-banner"): Objectives.secure(state, index, state.active)
				if UnitAbilities.has(state, squad, "banner-of-macragge"):
					for model: int in Contact.alive(state, squad):
						if UnitAbilities.identity(state.units[model]) == "victrix-honour-guard" and state.units[model].get("victrix_honour_guard_role", "") == "chapter-ancient":
							Objectives.secure(state, index, state.active)
							break
	state.unit_abilities.control_done = phase_key

