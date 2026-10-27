extends RefCounted
## Normalized, state-based choice for mandatory End-of-Turn coherency casualties.

const Contact = preload("res://scripts/edition_11/contact_movement.gd")
const PendingDecision = preload("res://scripts/edition_11/pending_decision.gd")
const REMOVE_MODEL := "remove-coherency-model"

static func incoherent_squad(state: Dictionary) -> int:
	if state.get("phase", "") != "end_turn": return -1
	var active := int(state.get("active", 1))
	for owner in [active, 3 - active]:
		for squad: int in state.get("squads", {}):
			if int(state.squads[squad].get("owner", -1)) == owner and not Contact.coherent(state, squad): return squad
	return -1

static func pending_decision(state: Dictionary) -> Dictionary:
	var squad := incoherent_squad(state)
	if squad < 0: return {}
	var owner := int(state.squads[squad].get("owner", -1))
	if owner not in [1, 2]: return {}
	var models := Contact.alive(state, squad)
	models.sort()
	var options: Array[Dictionary] = []
	for model: int in models:
		options.append({"label": "Remove model %d from the incoherent unit" % model, "action": REMOVE_MODEL, "model": model, "target": squad, "value": "remove"})
	return PendingDecision.create(state, "coherency", "end-turn:coherency-casualties", owner, options, false)
