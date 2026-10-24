extends RefCounted
## Shared decision projection for mandatory Desperate Escape mortal wounds.

const DefenderGroups = preload("res://scripts/edition_11/defender_groups.gd")
const PendingDecision = preload("res://scripts/edition_11/pending_decision.gd")
const ACTION := "allocate-escape-mortal-wound"

static func pending_decision(state: Dictionary) -> Dictionary:
	if str(state.get("phase", "")) != "movement": return {}
	var move_value: Variant = state.get("pending_move", {})
	if typeof(move_value) != TYPE_DICTIONARY: return {}
	var pending_move: Dictionary = move_value
	if pending_move.is_empty() or str(pending_move.get("move_type", "")) != "desperate_escape": return {}
	var remaining: Variant = pending_move.get("hazard_remaining", 0)
	var squad_value: Variant = pending_move.get("squad", -1)
	var squads_value: Variant = state.get("squads", {})
	var units_value: Variant = state.get("units", {})
	if not remaining is int or int(remaining) <= 0 or not squad_value is int: return {}
	if typeof(squads_value) != TYPE_DICTIONARY or not squads_value.has(int(squad_value)) or typeof(units_value) != TYPE_DICTIONARY: return {}
	var abilities_value: Variant = state.get("unit_abilities", {})
	if typeof(abilities_value) == TYPE_DICTIONARY and typeof(abilities_value.get("window", {})) == TYPE_DICTIONARY and not abilities_value.get("window", {}).is_empty(): return {}
	var stratagems_value: Variant = state.get("stratagems", {})
	if typeof(stratagems_value) == TYPE_DICTIONARY and typeof(stratagems_value.get("pending", {})) == TYPE_DICTIONARY and not stratagems_value.get("pending", {}).is_empty(): return {}
	var squad := int(squad_value)
	var owner := int(squads_value[squad].get("owner", -1))
	if owner not in [1, 2]: return {}
	var eligible := DefenderGroups.current_models(state, {"target": squad}, true)
	eligible.sort()
	var options: Array[Dictionary] = []
	for model: int in eligible:
		var name := str(units_value.get(model, {}).get("name", "Model %d" % model))
		options.append({"label": "Allocate the next escape mortal wound to %s" % name, "action": ACTION, "model": model, "target": squad, "value": "mortal-wound"})
	return PendingDecision.create(state, "escape-wounds", "movement:desperate-escape-allocation", owner, options, false)
