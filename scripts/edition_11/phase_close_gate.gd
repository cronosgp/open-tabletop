extends RefCounted
## Central preconditions for accepting player commands and closing a phase.
const Awakened = preload("res://scripts/edition_11/awakened_dynasty.gd")
const UnitAbilities = preload("res://scripts/edition_11/unit_abilities.gd")
const UnitActions = preload("res://scripts/edition_11/unit_actions.gd")
const Mission = preload("res://scripts/edition_11/chapter_approved.gd")
const Doctrines = preload("res://scripts/edition_11/combat_doctrines.gd")
const Reanimation = preload("res://scripts/edition_11/reanimation_protocols.gd")
const OathOfMoment = preload("res://scripts/edition_11/oath_of_moment.gd")
const Stratagems = preload("res://scripts/edition_11/stratagems.gd")
const CoreReactions = preload("res://scripts/edition_11/core_reactions.gd")
const DetachmentStratagems = preload("res://scripts/edition_11/detachment_stratagems.gd")
const MatchActor = preload("res://scripts/edition_11/match_actor.gd")
const PhaseProgression = preload("res://scripts/edition_11/phase_progression.gd")
const PendingDecisions = preload("res://scripts/edition_11/pending_decision_registry.gd")
const ResolutionFrames = preload("res://scripts/edition_11/resolution_frame.gd")

static func command_error(state: Dictionary, player: int, expected_revision: int) -> String:
	if Awakened.needs_setup(state): return "Finish Overlord attachment declarations before deployment."
	if UnitActions.actor(state) > 0: return "Resolve or decline the pending unit ability choices first."
	if Mission.actor(state) > 0: return "Resolve the mission preparation choice first."
	var decision := PendingDecisions.current(state, ["unit-actions", "combat-doctrines", "reanimation", "stratagems", "damage-allocation"])
	if not decision.is_empty(): return _decision_error(str(decision.get("source", "")))
	if Doctrines.needs_choice(state): return "Choose a Combat Doctrine or no doctrine before continuing Command."
	if not Reanimation.pending(state).is_empty(): return "Finish Reanimation Protocols before continuing."
	if OathOfMoment.needs_choice(state): return "Select the Oath of Moment target before continuing the Command phase."
	if state.get("phase", "") in ["deployment", "army_selection"]: return "Finish army selection and deployment before playing the first turn."
	if not Stratagems.pending(state).is_empty(): return "Resolve the pending decision before continuing."
	if not state.get("pending_hazard", {}).is_empty(): return "Finish Hazardous mortal-wound allocation first."
	if not state.get("pending_attack", {}).is_empty(): return "The defender must finish damage allocation first."
	if state.test_winner != 0: return "Exercise finished. Start a new local exercise to reset."
	if player != MatchActor.player(state): return "Wait for your action window."
	if expected_revision != state.revision: return "State changed; try again after synchronization."
	return ""

static func close_request_error(state: Dictionary, player: int, expected_revision: int) -> String:
	if not UnitAbilities.Detection.selection(state).is_empty(): return "Finish the selected Eliminator shooting or cancel its selection first."
	if not state.get("unit_abilities", {}).get("transport_window", {}).is_empty(): return "Finish transport hazard allocation or model placement before advancing."
	var error := command_error(state, player, expected_revision)
	if not error.is_empty(): return error
	if DetachmentStratagems.vengeful_actor(state) > 0: return "Resolve the pending reactive shooting window before continuing."
	if not state.pending_contact.is_empty(): return "Confirm or cancel the pending contact movement first."
	if not state.pending_move.is_empty(): return "Confirm or cancel the squad's movement before advancing."
	if state.phase == "charge" and not state.pending_charge.is_empty(): return "Resolve or decline the rolled charge before advancing."
	if CoreReactions.actor(state) > 0: return "Resolve Fire Overwatch shooting or the Heroic Intervention charge first."
	var frame_error := _resolution_frame_close_error(state)
	if not frame_error.is_empty(): return frame_error
	return ""

static func _resolution_frame_close_error(state: Dictionary) -> String:
	var raw_frames: Variant = state.get("resolution_frames", [])
	if typeof(raw_frames) != TYPE_ARRAY: return "Cannot advance while the resolution-frame stack is invalid."
	var frames: Array = raw_frames
	if frames.is_empty(): return ""
	var top := ResolutionFrames.current(state)
	if top.is_empty(): return "Cannot advance while the active resolution frame is invalid."
	var close_action_id := "phase-close:%d:%s" % [int(state.get("turn", 0)), str(state.get("phase", ""))]
	if frames.size() == 1 and str(top.get("kind", "")) == "phase-close" and str(top.get("action_id", "")) == close_action_id and str(top.get("status", "")) in ["resolving", "suspended"]:
		return ""
	return "Resolve the suspended action before advancing the phase."

static func progression_error(state: Dictionary) -> String:
	if state.phase == "end_turn" and MatchActor.incoherent_squad(state) != -1:
		return "The controlling player must select coherency casualties before ending the turn."
	if not PhaseProgression.contains(str(state.phase)): return "Cannot advance an unknown phase."
	return ""

static func _decision_error(source: String) -> String:
	match source:
		"combat-doctrines": return "Choose a Combat Doctrine or no doctrine before continuing Command."
		"reanimation": return "Finish Reanimation Protocols before continuing."
		"stratagems": return "Resolve the pending decision before continuing."
		"damage-allocation": return "The defender must finish damage allocation first."
		"unit-actions": return "Resolve or decline the pending unit ability choices first."
	return "Resolve the pending decision before continuing."
