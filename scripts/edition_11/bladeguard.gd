extends RefCounted
## Current shared-book Bladeguard choice. Core 01.02.02 gives phase duration.
const Geometry = preload("res://scripts/edition_11/contact_movement.gd")
const Detection = preload("res://scripts/edition_11/detection_rules.gd")

static func available(state: Dictionary, squad: int) -> bool:
	if state.get("unit_abilities", {}).get("implementation", "") != Detection.ABILITY_IMPLEMENTATION_ID or state.phase != "fight": return false
	if state.unit_abilities.get("used", {}).get("bladeguard:%d" % squad, -1) == state.turn: return false
	return has_source(state, squad)

static func has_source(state: Dictionary, squad: int) -> bool:
	for model: int in Geometry.alive(state, squad):
		if state.units[model].get("definition_id", "") == "40kdc:11e:adeptus-astartes:bladeguard-veteran-squad": return true
	return false

static func mode(state: Dictionary, squad: int) -> String:
	if state.get("unit_abilities", {}).get("implementation", "") != Detection.ABILITY_IMPLEMENTATION_ID or state.phase != "fight": return ""
	var record: Dictionary = state.unit_abilities.get("bladeguard", {}).get(squad, {})
	if record.get("turn", -1) != state.turn: return ""
	var selected: String = str(record.get("mode", ""))
	if has_source(state, squad): return selected
	# Core 19.04 retains a slain source's effect until this attacking unit finishes.
	return selected if state.get("pending_attack", {}).get("bladeguard_effects", {}).get(squad, "") == selected else ""

static func hit_modifier(state: Dictionary, squad: int, target: int, melee: bool) -> int:
	return (1 if melee and mode(state, squad) == "attack" else 0) - (1 if mode(state, target) == "defend" else 0)

static func offer(state: Dictionary, declaration: Dictionary, targets: Array) -> bool:
	if state.phase != "fight": return false
	var queue: Array[int] = []
	var squad: int = declaration.squad
	# Selection to fight precedes enemy target triggers.
	if declaration.melee and available(state, squad): queue.append(squad)
	var ordered := targets.duplicate()
	ordered.sort()
	for target: int in ordered:
		if target not in queue and available(state, target): queue.append(target)
	if queue.is_empty(): return false
	state.unit_abilities.window = {"kind": "bladeguard", "owners": [state.squads[queue[0]].owner], "remaining": queue, "declaration": declaration.duplicate(true)}
	return true

static func choose(state: Dictionary, selected: String) -> Dictionary:
	var window: Dictionary = state.unit_abilities.window
	var squad: int = window.remaining[0]
	if selected != "pass":
		if not state.unit_abilities.has("bladeguard"): state.unit_abilities.bladeguard = {}
		state.unit_abilities.bladeguard[squad] = {"mode": selected, "turn": state.turn}
		state.unit_abilities.used["bladeguard:%d" % squad] = state.turn
	window.remaining.pop_front()
	if not window.remaining.is_empty():
		window.owners = [state.squads[window.remaining[0]].owner]
		return {"error": ""}
	var declaration: Dictionary = window.declaration
	state.unit_abilities.window = {}
	return {"error": "", "resume_declaration": declaration}
