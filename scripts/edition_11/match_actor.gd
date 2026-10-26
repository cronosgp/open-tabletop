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
const Coherency = preload("res://scripts/edition_11/coherency_decision.gd")
const EscapeWounds = preload("res://scripts/edition_11/escape_wound_decision.gd")

## Reject malformed pending containers before any actor or HUD projection reads them.
static func pending_state_error(state: Dictionary) -> String:
	for source: String in ["mission-preparation", "combat-doctrines", "oath-of-moment", "vowed-target", "awakened-attachment"]:
		var decision_error := decision_container_error(state, source)
		if not decision_error.is_empty(): return decision_error
	var doctrine_error := templar_vow_state_error(state)
	if not doctrine_error.is_empty(): return doctrine_error
	var unit_action_error := unit_action_state_error(state)
	if not unit_action_error.is_empty(): return unit_action_error
	var stratagem_error := stratagem_state_error(state)
	if not stratagem_error.is_empty(): return stratagem_error
	var reanimation_error := reanimation_state_error(state)
	if not reanimation_error.is_empty(): return reanimation_error
	var deployment: Variant = state.get("deployment", {})
	if typeof(deployment) != TYPE_DICTIONARY: return "Cannot continue while deployment decision state is invalid."
	if not deployment.is_empty():
		if typeof(deployment.get("order", [])) != TYPE_ARRAY: return "Cannot continue while deployment order is invalid."
		var deployment_order: Array = deployment.get("order", [])
		var deployment_index: Variant = deployment.get("index", 0)
		var deployment_complete: Variant = deployment.get("complete", false)
		if not deployment_complete is bool: return "Cannot continue while deployment completion state is invalid."
		if not deployment_order.is_empty():
			if not deployment_index is int or int(deployment_index) < 0 or int(deployment_index) > deployment_order.size(): return "Cannot continue while deployment order is invalid."
			if int(deployment_index) == deployment_order.size() and not deployment_complete: return "Cannot continue while deployment order is invalid."
	var core_reactions: Variant = state.get("core_reactions", {})
	if typeof(core_reactions) != TYPE_DICTIONARY: return "Cannot continue while reaction decision state is invalid."
	for field: String in ["overwatch", "heroic"]:
		if typeof(core_reactions.get(field, {})) != TYPE_DICTIONARY: return "Cannot continue while reaction decision state is invalid."
	var detachment: Variant = state.get("detachment_stratagems", {})
	if typeof(detachment) != TYPE_DICTIONARY: return "Cannot continue while detachment reaction state is invalid."
	for field: String in ["vengeful", "hail_of_vengeance", "hail_of_vengeance_pending", "after", "gravis_suppression_pending", "medusa_power_pending", "medusa_power_reactive"]:
		if typeof(detachment.get(field, {})) != TYPE_DICTIONARY: return "Cannot continue while detachment reaction state is invalid."
	var wrath_destroyed_value: Variant = detachment.get("wrath_destroyed", [])
	if typeof(wrath_destroyed_value) != TYPE_ARRAY: return "Cannot continue while Wrath of the Rock destruction state is invalid."
	for record_value: Variant in wrath_destroyed_value:
		if not record_value is Dictionary: return "Cannot continue while Wrath of the Rock destruction state is invalid."
		var record: Dictionary = record_value
		for field: String in ["model", "squad", "owner"]:
			if not record.get(field, null) is int: return "Cannot continue while Wrath of the Rock destruction state is invalid."
		if int(record.get("model", -1)) < 0 or int(record.get("squad", -1)) < 0 or int(record.get("owner", -1)) not in [1, 2]: return "Cannot continue while Wrath of the Rock destruction state is invalid."
		if not record.get("phase_key", null) is String or str(record.get("phase_key", "")).is_empty(): return "Cannot continue while Wrath of the Rock destruction state is invalid."
		for field: String in ["objectives_in_range", "previously_controlled"]:
			var indices: Variant = record.get(field, null)
			if typeof(indices) != TYPE_ARRAY: return "Cannot continue while Wrath of the Rock destruction state is invalid."
			for objective_index: Variant in indices:
				if not objective_index is int or int(objective_index) < 0: return "Cannot continue while Wrath of the Rock destruction state is invalid."
	if typeof(detachment.get("adamantine_pending", {})) != TYPE_DICTIONARY: return "Cannot continue while detachment reaction state is invalid."
	var command_battle_shock: Variant = state.get("command_battle_shock", {})
	if typeof(command_battle_shock) != TYPE_DICTIONARY: return "Cannot continue while Command Battle-shock decision state is invalid."
	if typeof(command_battle_shock.get("pending", {})) != TYPE_DICTIONARY: return "Cannot continue while Command Battle-shock decision state is invalid."
	if typeof(state.get("fearsome_assault", {})) != TYPE_DICTIONARY: return "Cannot continue while Fearsome Assault decision state is invalid."
	var pending_move: Variant = state.get("pending_move", {})
	if typeof(pending_move) != TYPE_DICTIONARY: return "Cannot continue while movement state is invalid."
	if not pending_move.is_empty() and str(pending_move.get("move_type", "")) == "desperate_escape":
		var remaining: Variant = pending_move.get("hazard_remaining", 0)
		if not remaining is int or int(remaining) < 0: return "Cannot continue while escape allocation state is invalid."
		if int(remaining) > 0:
			var squad_id: Variant = pending_move.get("squad", -1)
			var squads: Variant = state.get("squads", {})
			if not squad_id is int or typeof(squads) != TYPE_DICTIONARY or not squads.has(int(squad_id)):
				return "Cannot continue while escape allocation target is invalid."
	for field: String in ["pending_attack", "pending_hazard"]:
		if typeof(state.get(field, {})) != TYPE_DICTIONARY:
			return "Cannot continue while %s decision state is invalid." % str(field.replace("_", " "))
	return ""

static func unit_action_state_error(state: Dictionary) -> String:
	var abilities_value: Variant = state.get("unit_abilities", {})
	if typeof(abilities_value) != TYPE_DICTIONARY: return "Cannot continue while unit ability state is invalid."
	var abilities: Dictionary = abilities_value
	var transport_window: Variant = abilities.get("transport_window", {})
	if typeof(transport_window) != TYPE_DICTIONARY: return "Cannot continue while transport resolution state is invalid."
	for field: String in ["used", "reserves", "homers"]:
		if typeof(abilities.get(field, {})) != TYPE_DICTIONARY: return "Cannot continue while unit ability state is invalid."
	for field: String in ["setup_players", "battle_players"]:
		if typeof(abilities.get(field, [])) != TYPE_ARRAY: return "Cannot continue while unit ability state is invalid."
	var ability_window: Variant = abilities.get("window", {})
	if typeof(ability_window) != TYPE_DICTIONARY: return "Cannot continue while unit ability choice state is invalid."
	if ability_window.is_empty(): return ""
	var ability_owners: Variant = ability_window.get("owners", [])
	var owners_valid: bool = typeof(ability_owners) == TYPE_ARRAY and not ability_owners.is_empty()
	var seen_owners: Array[int] = []
	if typeof(ability_owners) == TYPE_ARRAY:
		for raw_owner: Variant in ability_owners:
			if not raw_owner is int or int(raw_owner) not in [1, 2] or int(raw_owner) in seen_owners:
				owners_valid = false
				break
			seen_owners.append(int(raw_owner))
	if str(ability_window.get("kind", "")).is_empty() or not owners_valid:
		return "Resolve the invalid pending unit ability choice before continuing."
	if not UnitActions.supported_window_kind(str(ability_window.get("kind", ""))):
		return "Resolve the invalid pending unit ability choice before continuing."
	return ""

static func stratagem_state_error(state: Dictionary) -> String:
	var stratagems_value: Variant = state.get("stratagems", {})
	if typeof(stratagems_value) != TYPE_DICTIONARY: return "Cannot continue while stratagem decision state is invalid."
	if typeof(stratagems_value.get("pending", {})) != TYPE_DICTIONARY: return "Cannot continue while stratagem decision state is invalid."
	return ""

static func reanimation_state_error(state: Dictionary) -> String:
	var reanimation_value: Variant = state.get("reanimation", {})
	if typeof(reanimation_value) != TYPE_DICTIONARY: return "Cannot continue while Reanimation state is invalid."
	if typeof(reanimation_value.get("pending", {})) != TYPE_DICTIONARY: return "Cannot continue while Reanimation state is invalid."
	return ""

static func decision_container_error(state: Dictionary, source: String) -> String:
	var field_by_source := {
		"mission-preparation": "mission",
		"combat-doctrines": "combat_doctrines",
		"oath-of-moment": "oath_of_moment",
		"vowed-target": "vowed_target",
		"awakened-attachment": "awakened_dynasty"
	}
	if not field_by_source.has(source): return ""
	if typeof(state.get(str(field_by_source[source]), {})) != TYPE_DICTIONARY:
		return "Cannot continue while %s decision state is invalid." % str(source.replace("-", " "))
	return ""

static func templar_vow_state_error(state: Dictionary) -> String:
	var doctrines_value: Variant = state.get("combat_doctrines", {})
	if typeof(doctrines_value) != TYPE_DICTIONARY: return "Cannot continue while Combat Doctrines state is invalid."
	var doctrines: Dictionary = doctrines_value
	for field: String in ["templar_vows", "templar_vow_passed"]:
		if not doctrines.has(field): continue
		var decisions: Variant = doctrines[field]
		if typeof(decisions) != TYPE_DICTIONARY: return "Cannot continue while Templar Vows decision state is invalid."
		for raw_owner: Variant in decisions:
			if str(raw_owner) not in ["1", "2"]: return "Cannot continue while Templar Vows decision state is invalid."
			var decision: Variant = decisions[raw_owner]
			if field == "templar_vows" and str(decision) not in ["", "uphold-honour", "abhor-the-witch", "accept-any-challenge"]: return "Cannot continue while Templar Vows decision state is invalid."
			if field == "templar_vow_passed" and not decision is bool: return "Cannot continue while Templar Vows decision state is invalid."
	return ""

static func player(state: Dictionary) -> int:
	if not pending_state_error(state).is_empty(): return -1
	var mission_decision := PendingDecisions.current(state, ["mission-preparation"])
	if not mission_decision.is_empty(): return int(mission_decision.priority_player_id)
	var awakened_decision := PendingDecisions.current(state, ["awakened-attachment"])
	if not awakened_decision.is_empty(): return int(awakened_decision.priority_player_id)
	var mission_actor := Mission.actor(state)
	if mission_actor > 0: return mission_actor
	if Awakened.needs_setup(state): return Awakened.setup_actor(state)
	var reanimation_decision := PendingDecisions.current(state, ["reanimation"])
	if not reanimation_decision.is_empty(): return int(reanimation_decision.priority_player_id)
	var reanimation := Reanimation.pending(state)
	if not reanimation.is_empty(): return int(reanimation.player)
	var doctrine_decision := PendingDecisions.current(state, ["combat-doctrines"])
	if not doctrine_decision.is_empty(): return int(doctrine_decision.priority_player_id)
	var phase_decision_actor := UnitActions.phase_decision_actor(state)
	if phase_decision_actor > 0: return phase_decision_actor
	var unit_decision := PendingDecisions.current(state, ["unit-actions"])
	if not unit_decision.is_empty(): return int(unit_decision.priority_player_id)
	var oath_decision := PendingDecisions.current(state, ["oath-of-moment"])
	if not oath_decision.is_empty(): return int(oath_decision.priority_player_id)
	var vowed_decision := PendingDecisions.current(state, ["vowed-target"])
	if not vowed_decision.is_empty(): return int(vowed_decision.priority_player_id)
	var ability_actor := UnitActions.actor(state)
	if ability_actor > 0: return ability_actor
	if state.get("phase", "") == "deployment": return Deployment.actor(state)
	var detachment_actor := DetachmentStratagems.shooting_reaction_actor(state)
	if detachment_actor > 0: return detachment_actor
	var stratagem_decision := PendingDecisions.current(state, ["stratagems"])
	if not stratagem_decision.is_empty(): return int(stratagem_decision.priority_player_id)
	var stratagem := Stratagems.pending(state)
	if not stratagem.is_empty(): return int(stratagem.player)
	var reaction_actor := CoreReactions.actor(state)
	if reaction_actor > 0: return reaction_actor
	var allocation_decision := PendingDecisions.current(state, ["damage-allocation"])
	if not allocation_decision.is_empty(): return int(allocation_decision.priority_player_id)
	var coherency_decision := PendingDecisions.current(state, ["coherency"])
	if not coherency_decision.is_empty(): return int(coherency_decision.priority_player_id)
	var escape_wounds_decision := PendingDecisions.current(state, ["escape-wounds"])
	if not escape_wounds_decision.is_empty(): return int(escape_wounds_decision.priority_player_id)
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
	return Coherency.incoherent_squad(state)
