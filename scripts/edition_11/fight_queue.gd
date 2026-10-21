extends RefCounted
## Unit IDs are independent of player IDs. Choices are recomputed after casualties.
const Geometry = preload("res://scripts/edition_11/contact_movement.gd")

const Detection = preload("res://scripts/edition_11/detection_rules.gd")

static func first(state: Dictionary, squad: int) -> bool:
	if state.squads[squad].charged or state.squads[squad].get("fights_first", false): return true
	if state.get("unit_abilities", {}).get("implementation", "") != Detection.ABILITY_IMPLEMENTATION_ID: return false
	# Tempormortis grants the whole current unit Fights First while its source lives.
	for model: int in Geometry.alive(state, squad):
		if state.units[model].get("definition_id", "") == "40kdc:11e:adeptus-astartes:judiciar": return true
	return false

static func engaged(state: Dictionary, squad: int) -> bool:
	for id: int in Geometry.alive(state, squad):
		for other: int in state.units:
			if state.units[other].wounds > 0 and state.units[other].get("on_battlefield", true) and state.units[other].owner != state.squads[squad].owner and Geometry.edge(state.units[id], state.units[other]) <= 2.001: return true
	return false

static func eligible(state: Dictionary, squad: int) -> bool:
	return not Geometry.alive(state, squad).is_empty() and not state.squads[squad].fought and (engaged(state, squad) or state.squads[squad].was_engaged or state.squads[squad].charged or squad in state.get("reaction_queue", []))

static func pool(state: Dictionary) -> Array[int]:
	var result: Array[int] = []
	var priority: Array[int] = []
	for squad: int in state.squads:
		if state.fight_step == "pile_in":
			if squad not in state.get("pile_done", []) and not Geometry.alive(state, squad).is_empty() and (engaged(state, squad) or state.squads[squad].charged): result.append(squad)
		elif state.fight_step == "consolidate":
			if squad not in state.get("consolidate_done", []) and not Geometry.alive(state, squad).is_empty() and state.squads[squad].fight_eligible: result.append(squad)
		elif state.fight_step == "consolidation_reaction":
			if squad in state.get("reaction_queue", []) and eligible(state, squad): result.append(squad)
		elif eligible(state, squad):
			result.append(squad)
			if first(state, squad): priority.append(squad)
	if state.fight_step == "attacks" and not priority.is_empty(): result = priority
	var selected: int = state.get("fight_selected", -1)
	if selected in result and state.fight_step in ["attacks", "consolidation_reaction"]: result = [selected]
	result.sort()
	return result

static func choices(state: Dictionary, player: int) -> Array[int]:
	var result: Array[int] = []
	for squad: int in pool(state):
		if state.squads[squad].owner == player: result.append(squad)
	return result

static func choose_actor(state: Dictionary, preferred: int) -> bool:
	if not choices(state, preferred).is_empty(): state.fight_actor = preferred
	elif not choices(state, 3 - preferred).is_empty(): state.fight_actor = 3 - preferred
	else: return false
	return true
