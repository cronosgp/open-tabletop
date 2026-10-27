extends RefCounted
## Resolves command priority independently from active turn ownership.

const Mission = preload("res://scripts/edition_11/chapter_approved.gd")
const Awakened = preload("res://scripts/edition_11/awakened_dynasty.gd")
const Reanimation = preload("res://scripts/edition_11/reanimation_protocols.gd")
const Doctrines = preload("res://scripts/edition_11/combat_doctrines.gd")
const UnitActions = preload("res://scripts/edition_11/unit_actions.gd")
const Deployment = preload("res://scripts/edition_11/deployment.gd")
const DetachmentStratagems = preload("res://scripts/edition_11/detachment_stratagems.gd")
const Stratagems = preload("res://scripts/edition_11/stratagems.gd")
const CoreReactions = preload("res://scripts/edition_11/core_reactions.gd")
const Contact = preload("res://scripts/edition_11/contact_movement.gd")
const PendingDecisions = preload("res://scripts/edition_11/pending_decision_registry.gd")

static func player(state: Dictionary) -> int:
	var mission_actor := Mission.actor(state)
	if mission_actor > 0: return mission_actor
	if Awakened.needs_setup(state): return Awakened.setup_actor(state)
	var reanimation_decision := PendingDecisions.current(state, ["reanimation"])
	if not reanimation_decision.is_empty(): return int(reanimation_decision.priority_player_id)
	var reanimation := Reanimation.pending(state)
	if not reanimation.is_empty(): return int(reanimation.player)
	var doctrine_decision := PendingDecisions.current(state, ["combat-doctrines"])
	if not doctrine_decision.is_empty(): return int(doctrine_decision.priority_player_id)
	var unit_decision := PendingDecisions.current(state, ["unit-actions"])
	if not unit_decision.is_empty(): return int(unit_decision.priority_player_id)
	var ability_actor := UnitActions.actor(state)
	if ability_actor > 0: return ability_actor
	if state.get("phase", "") == "deployment": return Deployment.actor(state)
	var detachment_actor := DetachmentStratagems.vengeful_actor(state)
	if detachment_actor > 0: return detachment_actor
	var stratagem_decision := PendingDecisions.current(state, ["stratagems"])
	if not stratagem_decision.is_empty(): return int(stratagem_decision.priority_player_id)
	var stratagem := Stratagems.pending(state)
	if not stratagem.is_empty(): return int(stratagem.player)
	var reaction_actor := CoreReactions.actor(state)
	if reaction_actor > 0: return reaction_actor
	var allocation_decision := PendingDecisions.current(state, ["damage-allocation"])
	if not allocation_decision.is_empty(): return int(allocation_decision.priority_player_id)
	var hazard: Dictionary = state.get("pending_hazard", {})
	if not hazard.is_empty(): return int(hazard.player)
	var attack: Dictionary = state.get("pending_attack", {})
	if not attack.is_empty():
		if attack.current.get("phase", "") == "precision": return int(attack.player)
		return int(state.squads[attack.current.target].owner)
	if state.get("phase", "") == "end_turn":
		var squad := incoherent_squad(state)
		if squad != -1: return int(state.squads[squad].owner)
	return int(state.get("fight_actor", state.get("active", -1))) if state.get("phase", "") == "fight" else int(state.get("active", -1))

static func incoherent_squad(state: Dictionary) -> int:
	# Resolve the turn owner's choices first, then the opponent's.
	for owner in [int(state.get("active", 1)), 3 - int(state.get("active", 1))]:
		for squad: int in state.get("squads", {}):
			if state.squads[squad].owner == owner and not Contact.coherent(state, squad): return squad
	return -1
