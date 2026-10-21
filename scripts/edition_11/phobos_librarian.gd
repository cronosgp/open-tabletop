extends RefCounted
## Librarian in Phobos Armour's pre-attack Shrouding decision and psychic roll.
const A = preload("res://scripts/edition_11/unit_abilities.gd")
const Geometry = preload("res://scripts/edition_11/contact_movement.gd")
const RandomStat = preload("res://scripts/edition_11/random_characteristic.gd")
const Actions = preload("res://scripts/edition_11/actions.gd")

static func phase_key(state: Dictionary) -> String:
	return "%d:%s" % [state.turn, state.phase]

static func used_key(state: Dictionary, squad: int) -> String:
	return "librarius:%d:%d" % [squad, state.round]

static func available(state: Dictionary, squad: int) -> bool:
	return A.has(state, squad, "shrouding") and not state.squads[squad].battle_shocked and not A.sources(state, squad, "librarius").is_empty() and not state.unit_abilities.used.has(used_key(state, squad))

static func offer(state: Dictionary, declaration: Dictionary, targets: Array) -> bool:
	if state.phase not in ["shooting", "fight"]: return false
	var queue: Array[int] = []
	var ordered := targets.duplicate()
	ordered.sort()
	for target: int in ordered:
		if state.squads.has(target) and state.squads[target].owner != declaration.player and available(state, target): queue.append(target)
	if queue.is_empty(): return false
	state.unit_abilities.window = {"kind": "phobos-shrouding", "owners": [state.squads[queue[0]].owner], "remaining": queue, "declaration": declaration.duplicate(true)}
	return true

static func choices(state: Dictionary, player: int) -> Array:
	var result: Array = []
	var window: Dictionary = state.get("unit_abilities", {}).get("window", {})
	if window.get("kind", "") != "phobos-shrouding" or window.get("owners", [-1])[0] != player or window.get("remaining", []).is_empty(): return result
	var squad: int = window.remaining[0]
	if available(state, squad):
		var librarian: int = A.sources(state, squad, "shrouding")[0]
		result.append({"label": "Shrouding %d: Psychic roll (-1 to hit against %s this phase)" % [librarian, state.squads[squad].name], "action": "phobos-shrouding", "model": librarian, "target": squad, "value": "use"})
	result.append({"label": "Decline Shrouding for %s" % state.squads[squad].name, "action": "phobos-shrouding", "model": -1, "target": squad, "value": "pass"})
	return result

static func choose(state: Dictionary, player: int, selected: Dictionary, roller: Callable) -> Dictionary:
	var window: Dictionary = state.unit_abilities.get("window", {})
	if window.get("kind", "") != "phobos-shrouding" or window.get("owners", [-1])[0] != player or window.get("remaining", []).is_empty(): return {"error": "There is no matching Shrouding trigger."}
	var squad: int = int(window.remaining[0])
	if selected.target != squad or selected.value not in ["use", "pass"]: return {"error": "Choose the current Shrouding trigger."}
	if selected.value == "use":
		if not available(state, squad) or selected.model not in A.sources(state, squad, "shrouding"): return {"error": "Shrouding is unavailable for this unit."}
		var psychic_roll := RandomStat.roll("D6", roller)
		if not psychic_roll.error.is_empty(): return psychic_roll
		state.unit_abilities.used[used_key(state, squad)] = "shrouding"
		if not state.unit_abilities.has("shrouded_targets"): state.unit_abilities.shrouded_targets = {}
		state.unit_abilities.shrouded_targets[squad] = {"phase_key": phase_key(state), "source": selected.model}
		if not state.unit_abilities.has("librarius_results"): state.unit_abilities.librarius_results = []
		state.unit_abilities.librarius_results.append({"squad": squad, "power": "shrouding", "roll": psychic_roll.value, "battle_shocked": psychic_roll.value == 1})
		if psychic_roll.value == 1:
			state.squads[squad].battle_shocked = true
			Actions.interrupt(state, squad, "unit became battle-shocked")
	window.remaining.pop_front()
	if not window.remaining.is_empty():
		window.owners = [state.squads[window.remaining[0]].owner]
		return {"error": ""}
	var declaration: Dictionary = window.declaration
	state.unit_abilities.window = {}
	return {"error": "", "resume_declaration": declaration}
