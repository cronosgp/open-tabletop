extends RefCounted
## Authoritative scenario construction. This does not certify army/MFM legality.
const Groups = preload("res://scripts/edition_11/defender_groups.gd")
const Equipment = preload("res://scripts/edition_11/equipment.gd")
const Geometry = preload("res://scripts/edition_11/contact_movement.gd")

static func form_practice_unit(state: Dictionary, bodyguard: int, leader: int = -1, support: int = -1, defer_setup_coherency: bool = false) -> String:
	if state.get("revision", -1) != 0 or state.get("turn", -1) != 1 or state.get("phase", "") != "start_turn": return "Attachments must be configured before the exercise starts."
	var components := [{"squad": bodyguard, "role": "bodyguard"}]
	if leader >= 0: components.append({"squad": leader, "role": "leader"})
	if support >= 0: components.append({"squad": support, "role": "support"})
	if components.size() == 1: return "Select a leader or support unit to attach."
	var seen: Array[int] = []
	var owner := -1
	for component: Dictionary in components:
		var id: int = component.squad
		if id in seen or not state.squads.has(id): return "Invalid or duplicate attachment component."
		seen.append(id)
		var squad: Dictionary = state.squads[id]
		if squad.get("attached", false): return "A component is already attached."
		if owner < 0: owner = squad.owner
		if squad.owner != owner: return "Only friendly units can form an attachment."
		if Geometry.alive(state, id).is_empty() or Geometry.alive(state, id).size() != squad.starting_strength: return "Practice attachment requires intact starting units."
		for model: int in Geometry.alive(state, id):
			var profile := Groups.profile(state, model)
			if not profile.error.is_empty(): return profile.error
	var working := state.duplicate(true)
	var starting := 0
	var identities: Array = []
	for component: Dictionary in components:
		var id: int = component.squad
		var squad: Dictionary = working.squads[id]
		starting += squad.starting_strength
		identities.append({"squad": id, "role": component.role, "name": squad.name, "starting_strength": squad.starting_strength})
		if working.has("unit_abilities"):
			for ability: String in squad.get("enabled_abilities", []).duplicate():
				if ability not in working.squads[bodyguard].enabled_abilities: working.squads[bodyguard].enabled_abilities.append(ability)

		for model: int in Geometry.alive(working, id):
			var unit: Dictionary = working.units[model]
			var profile := Groups.profile(working, model)
			unit.ranged_weapons = Equipment.inventory(working, model, false).duplicate(true)
			unit.melee_weapons = Equipment.inventory(working, model, true).duplicate(true)
			unit.defense = {"toughness": profile.toughness, "save_target": profile.save_target, "invulnerable_target": profile.invulnerable_target, "melee_invulnerable_target": profile.melee_invulnerable_target}
			unit.leadership_target = unit.get("leadership_target", squad.stats.leadership_target)
			unit.objective_control = unit.get("objective_control", squad.stats.objective_control)
			unit.component_squad = id
			unit.attachment_role = component.role
			unit.squad = bodyguard
	working.squads[bodyguard].attached = true
	working.squads[bodyguard].components = identities
	working.squads[bodyguard].starting_strength = starting
	for id: int in seen:
		if id != bodyguard: working.squads.erase(id)
	# The validated pre-deployment setup wrapper defers placement to deployment.
	if not defer_setup_coherency and not Geometry.coherent(working, bodyguard): return "Place the component models in coherent formation before starting the practice attachment."
	working.pack_hash = (str(working.pack_hash) + var_to_str(identities)).sha256_text()
	state.clear()
	state.merge(working, true)
	return ""
