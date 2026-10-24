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

static func command_error(state: Dictionary, player: int, expected_revision: int, continuation_action_id: String = "", resolved_decision_source: String = "", allow_non_actor_command: bool = false) -> String:
	var error := _command_preconditions(state, player, expected_revision, resolved_decision_source, allow_non_actor_command)
	if not error.is_empty(): return error
	return _resolution_frame_command_error(state, continuation_action_id)

## Validate the nested unit-action containers before decision projection reads their owners.
static func unit_action_state_error(state: Dictionary) -> String:
	return MatchActor.unit_action_state_error(state)

static func stratagem_state_error(state: Dictionary) -> String:
	return MatchActor.stratagem_state_error(state)

static func reanimation_state_error(state: Dictionary) -> String:
	return MatchActor.reanimation_state_error(state)

static func decision_container_error(state: Dictionary, source: String) -> String:
	return MatchActor.decision_container_error(state, source)

static func _command_preconditions(state: Dictionary, player: int, expected_revision: int, resolved_decision_source: String = "", allow_non_actor_command: bool = false) -> String:
	var pending_deadly_value: Variant = state.get("pending_deadly_demise", {})
	if typeof(pending_deadly_value) != TYPE_DICTIONARY: return "Cannot continue while destruction resolution state is invalid."
	var pending_deadly: Dictionary = pending_deadly_value
	var pending_hazard_value: Variant = state.get("pending_hazard", {})
	if typeof(pending_hazard_value) != TYPE_DICTIONARY: return "Cannot continue while Hazardous allocation state is invalid."
	var pending_hazard: Dictionary = pending_hazard_value
	var pending_attack_value: Variant = state.get("pending_attack", {})
	if typeof(pending_attack_value) != TYPE_DICTIONARY: return "Cannot continue while damage allocation state is invalid."
	var pending_attack: Dictionary = pending_attack_value
	if typeof(state.get("pending_move", {})) != TYPE_DICTIONARY: return "Cannot continue while movement state is invalid."
	var stratagem_error := stratagem_state_error(state)
	if not stratagem_error.is_empty(): return stratagem_error
	var reanimation_error := reanimation_state_error(state)
	if not reanimation_error.is_empty(): return reanimation_error
	for source: String in ["mission-preparation", "combat-doctrines", "oath-of-moment", "awakened-attachment"]:
		var decision_error := decision_container_error(state, source)
		if not decision_error.is_empty(): return decision_error
	if Awakened.needs_setup(state): return "Finish Overlord attachment declarations before deployment."
	if not pending_deadly.is_empty(): return "Finish pending destruction effects before continuing."
	var abilities_value: Variant = state.get("unit_abilities", {})
	if typeof(abilities_value) != TYPE_DICTIONARY: return "Cannot continue while unit ability state is invalid."
	var transport_window: Variant = abilities_value.get("transport_window", {})
	if typeof(transport_window) != TYPE_DICTIONARY: return "Cannot continue while transport resolution state is invalid."
	if not transport_window.is_empty(): return "Finish the pending transport hazard or model placement choice first."
	var ability_state_error := unit_action_state_error(state)
	if not ability_state_error.is_empty(): return ability_state_error
	var unit_action_actor := UnitActions.actor(state)
	if unit_action_actor > 0:
		var unit_action_decision := PendingDecisions.current(state, ["unit-actions"])
		if resolved_decision_source != "unit-actions" or unit_action_actor != player or str(unit_action_decision.get("source", "")) != "unit-actions" or int(unit_action_decision.get("priority_player_id", -1)) != player:
			return "Resolve or decline the pending unit ability choices first."
	if Mission.actor(state) > 0: return "Resolve the mission preparation choice first."
	var decision := PendingDecisions.current(state, ["awakened-attachment", "mission-preparation", "unit-actions", "combat-doctrines", "oath-of-moment", "reanimation", "stratagems", "damage-allocation", "coherency", "escape-wounds"])
	if not decision.is_empty() and str(decision.get("source", "")) != resolved_decision_source: return _decision_error(str(decision.get("source", "")))
	if Doctrines.needs_choice(state): return "Choose a Combat Doctrine or no doctrine before continuing Command."
	if not Reanimation.pending(state).is_empty(): return "Finish Reanimation Protocols before continuing."
	if OathOfMoment.needs_choice(state): return "Select the Oath of Moment target before continuing the Command phase."
	if state.get("phase", "") in ["deployment", "army_selection"]: return "Finish army selection and deployment before playing the first turn."
	if not Stratagems.pending(state).is_empty(): return "Resolve the pending decision before continuing."
	if not pending_hazard.is_empty(): return "Finish Hazardous mortal-wound allocation first."
	if not pending_attack.is_empty(): return "The defender must finish damage allocation first."
	if state.test_winner != 0: return "Exercise finished. Start a new local exercise to reset."
	if player != MatchActor.player(state) and not allow_non_actor_command: return "Wait for your action window."
	if expected_revision != state.revision: return "State changed; try again after synchronization."
	return ""

static func close_request_error(state: Dictionary, player: int, expected_revision: int) -> String:
	var abilities_value: Variant = state.get("unit_abilities", {})
	if typeof(abilities_value) != TYPE_DICTIONARY: return "Cannot advance while unit ability state is invalid."
	var abilities: Dictionary = abilities_value
	var transport_window_value: Variant = abilities.get("transport_window", {})
	if typeof(transport_window_value) != TYPE_DICTIONARY: return "Cannot advance while transport resolution state is invalid."
	var transport_window: Dictionary = transport_window_value
	if not UnitAbilities.Detection.selection(state).is_empty(): return "Finish the selected Eliminator shooting or cancel its selection first."
	if not transport_window.is_empty(): return "Finish transport hazard allocation or model placement before advancing."
	var error := _command_preconditions(state, player, expected_revision)
	if not error.is_empty(): return error
	if DetachmentStratagems.vengeful_actor(state) > 0: return "Resolve the pending reactive shooting window before continuing."
	var pending_contact_value: Variant = state.get("pending_contact", {})
	if typeof(pending_contact_value) != TYPE_DICTIONARY: return "Cannot advance while contact movement state is invalid."
	var pending_contact: Dictionary = pending_contact_value
	if not pending_contact.is_empty(): return "Confirm or cancel the pending contact movement first."
	var pending_move_value: Variant = state.get("pending_move", {})
	if typeof(pending_move_value) != TYPE_DICTIONARY: return "Cannot advance while movement state is invalid."
	var pending_move: Dictionary = pending_move_value
	if not pending_move.is_empty(): return "Confirm or cancel the squad's movement before advancing."
	var pending_charge_value: Variant = state.get("pending_charge", {})
	if typeof(pending_charge_value) != TYPE_DICTIONARY: return "Cannot advance while Charge state is invalid."
	var pending_charge: Dictionary = pending_charge_value
	if state.phase == "charge" and not pending_charge.is_empty(): return "Resolve or decline the rolled charge before advancing."
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

static func _resolution_frame_command_error(state: Dictionary, continuation_action_id: String = "") -> String:
	var pending_move_value: Variant = state.get("pending_move", {})
	if typeof(pending_move_value) != TYPE_DICTIONARY: return "Cannot continue while movement state is invalid."
	var pending_move: Dictionary = pending_move_value
	if not pending_move.is_empty():
		var move_squad_value: Variant = pending_move.get("squad", -1)
		var move_squads: Variant = state.get("squads", {})
		if not move_squad_value is int or typeof(move_squads) != TYPE_DICTIONARY or not move_squads.has(int(move_squad_value)) or str(state.get("phase", "")) != "movement": return "Cannot continue while movement state is invalid."
		var move_squad := int(move_squad_value)
		var move_action_id := "movement:%d:%d:%s" % [int(state.get("turn", 0)), move_squad, str(state.get("phase", ""))]
		if continuation_action_id != move_action_id: return "Finish or cancel the pending movement before issuing another command."
	var pending_charge_value: Variant = state.get("pending_charge", {})
	if typeof(pending_charge_value) != TYPE_DICTIONARY: return "Cannot continue while Charge state is invalid."
	var pending_charge: Dictionary = pending_charge_value
	if not pending_charge.is_empty():
		var charge_squad_value: Variant = pending_charge.get("squad", -1)
		var charge_squads: Variant = state.get("squads", {})
		if not charge_squad_value is int or typeof(charge_squads) != TYPE_DICTIONARY or not charge_squads.has(int(charge_squad_value)) or str(state.get("phase", "")) != "charge": return "Cannot continue while Charge state is invalid."
		var charge_squad := int(charge_squad_value)
		var charge_action_id := "charge:%d:%d:%s" % [int(state.get("turn", 0)), charge_squad, str(state.get("phase", ""))]
		if continuation_action_id != charge_action_id: return "Resolve the pending Charge before issuing another command."
	var pending_contact_value: Variant = state.get("pending_contact", {})
	if typeof(pending_contact_value) != TYPE_DICTIONARY: return "Cannot continue while contact movement state is invalid."
	var pending_contact: Dictionary = pending_contact_value
	if not pending_contact.is_empty():
		var squad_value: Variant = pending_contact.get("squad", -1)
		var kind := str(pending_contact.get("kind", ""))
		var contact_squads: Variant = state.get("squads", {})
		if not squad_value is int or typeof(contact_squads) != TYPE_DICTIONARY or not contact_squads.has(int(squad_value)) or kind not in ["charge", "pile_in", "overrun", "consolidate_ongoing", "consolidate_engaging", "consolidate_objective"]:
			return "Cannot continue while contact movement state is invalid."
		var squad := int(squad_value)
		if str(state.get("phase", "")) != ("charge" if kind == "charge" else "fight"): return "Cannot continue while contact movement state is invalid."
		var expected_contact_action_id := "charge:%d:%d:%s" % [int(state.get("turn", 0)), squad, str(state.get("phase", ""))] if kind == "charge" else "contact:%d:%s:%d:%s" % [int(state.get("turn", 0)), str(state.get("phase", "")), squad, kind]
		var stored_contact_action_id := str(pending_contact.get("resolution_action_id", ""))
		if not stored_contact_action_id.is_empty() and stored_contact_action_id != expected_contact_action_id: return "Cannot continue while contact movement state is invalid."
		if kind == "charge" and (pending_charge.is_empty() or int(pending_charge.get("squad", -1)) != squad): return "Cannot continue while contact movement state is invalid."
		if continuation_action_id != expected_contact_action_id: return "Finish or cancel the pending contact movement before issuing another command."
	var raw_frames: Variant = state.get("resolution_frames", [])
	if typeof(raw_frames) != TYPE_ARRAY: return "Cannot continue while the resolution-frame stack is invalid."
	var frames: Array = raw_frames
	if frames.is_empty(): return ""
	var frame := ResolutionFrames.current(state)
	if frame.is_empty(): return "Cannot continue while the active resolution frame is invalid."
	if not continuation_action_id.is_empty() and str(frame.get("action_id", "")) == continuation_action_id: return ""
	return "Resolve the pending action or decision before issuing another command."

static func progression_error(state: Dictionary) -> String:
	if state.phase == "end_turn" and MatchActor.incoherent_squad(state) != -1:
		return "The controlling player must select coherency casualties before ending the turn."
	if not PhaseProgression.contains(str(state.phase)): return "Cannot advance an unknown phase."
	return ""

static func _decision_error(source: String) -> String:
	match source:
		"combat-doctrines": return "Choose a Combat Doctrine or no doctrine before continuing Command."
		"oath-of-moment": return "Select the Oath of Moment target before continuing the Command phase."
		"reanimation": return "Finish Reanimation Protocols before continuing."
		"stratagems": return "Resolve the pending decision before continuing."
		"damage-allocation": return "The defender must finish damage allocation first."
		"coherency": return "Select a casualty to restore coherency before ending the turn."
		"escape-wounds": return "Allocate the remaining escape mortal wounds before continuing movement."
		"unit-actions": return "Resolve or decline the pending unit ability choices first."
	return "Resolve the pending decision before continuing."
