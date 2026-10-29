extends RefCounted
## Asmodai's Dark Angels App abilities, resolved through the shared Fight phase window.
const Geometry = preload("res://scripts/edition_11/contact_movement.gd")
const Abilities = preload("res://scripts/edition_11/unit_abilities.gd")
const Morale = preload("res://scripts/edition_11/morale.gd")
const MarineEnhancements = preload("res://scripts/edition_11/stormlance_enhancements.gd")
const FEARED := "feared-interrogator"

static func _has_character(state: Dictionary, squad: int) -> bool:
	for model: int in Geometry.alive(state, squad):
		if "CHARACTER" in state.units[model].get("keywords", []): return true
	return false

static func begin_fight(state: Dictionary) -> bool:
	if state.get("phase", "") != "fight" or not Abilities.enabled(state): return false
	var targets: Array[int] = []
	for source_squad: int in state.squads:
		if not Abilities.has(state, source_squad, FEARED): continue
		var sources := Abilities.sources(state, source_squad, FEARED)
		for target_squad: int in state.squads:
			if state.squads[target_squad].owner == state.squads[source_squad].owner or Geometry.alive(state, target_squad).is_empty() or not _has_character(state, target_squad): continue
			for source: int in sources:
				if Geometry.distance_to_target_at_height(state, state.units[source], target_squad) <= 6.0 + Geometry.EPSILON:
					targets.append(target_squad)
					break
	targets.sort()
	if targets.is_empty():
		state.erase(FEARED)
		return false
	state[FEARED] = {"owner": int(state.active), "targets": targets, "results": []}
	return true

static func actor(state: Dictionary) -> int:
	var pending: Dictionary = state.get(FEARED, {})
	if pending.is_empty(): return -1
	if not pending.get("current_result", {}).is_empty(): return int(pending.get("decision_owner", -1))
	return int(pending.get("owner", -1))

static func choices(state: Dictionary, player: int) -> Array:
	var pending: Dictionary = state.get(FEARED, {})
	if pending.is_empty(): return []
	var current_result: Dictionary = pending.get("current_result", {})
	if not current_result.is_empty():
		var target := int(current_result.get("squad", -1))
		if int(pending.get("decision_owner", -1)) != player or not state.squads.has(target): return []
		var options: Array[Dictionary] = [{"label": "Keep the current Feared Interrogator result for %s" % state.squads[target].name, "action": FEARED, "model": -1, "target": target, "value": "keep"}]
		if MarineEnhancements.leadership_reroll_available(state, target): options.append({"label": "%s: re-roll both Leadership dice for %s (free)" % [MarineEnhancements.leadership_reroll_name(state, target), state.squads[target].name], "action": FEARED, "model": -1, "target": target, "value": "tempered-in-battle"})
		return options
	if int(pending.get("owner", -1)) != player: return []
	var result: Array[Dictionary] = []
	for squad: int in pending.get("targets", []):
		if not state.squads.has(squad) or Geometry.alive(state, squad).is_empty(): continue
		result.append({"label": "Feared Interrogator: roll Battle-shock for %s (-1 to the roll)" % state.squads[squad].name, "action": FEARED, "model": -1, "target": squad, "value": "roll"})
	return result

static func resolve(state: Dictionary, player: int, selected: Dictionary, roller: Callable) -> Dictionary:
	if selected not in choices(state, player): return {"error": "Feared Interrogator requires each eligible enemy CHARACTER unit to take its Battle-shock test."}
	var target := int(selected.target)
	var pending: Dictionary = state[FEARED]
	var current_result: Dictionary = pending.get("current_result", {})
	var was_battle_shocked := bool(pending.get("was_battle_shocked", false))
	var result: Dictionary
	if not current_result.is_empty():
		if selected.value == "tempered-in-battle":
			if not MarineEnhancements.leadership_reroll_available(state, target): return {"error": "No eligible Leadership re-roll applies to this roll."}
			result = Morale.roll_battle_shock(state, target, roller, -1)
			if not str(result.get("error", "")).is_empty(): return result
			result["rerolled_from"] = current_result.get("rolls", []).duplicate()
		else:
			if selected.value != "keep": return {"error": "Choose whether to keep or re-roll the Feared Interrogator result."}
			result = current_result.duplicate(true)
	else:
		result = Morale.roll_battle_shock(state, target, roller, -1)
		if not str(result.get("error", "")).is_empty(): return result
		was_battle_shocked = bool(state.squads[target].battle_shocked)
		if MarineEnhancements.leadership_reroll_available(state, target):
			result["source"] = FEARED
			result["modified_total"] = int(result.rolls[0]) + int(result.rolls[1]) - 1
			pending.current_result = result.duplicate(true)
			pending.was_battle_shocked = was_battle_shocked
			pending.decision_owner = int(state.squads[target].owner)
			return {"error": "", "pending_reroll": true, "message": "Feared Interrogator Leadership result is waiting for the target unit's controller."}
	state.squads[target].battle_shocked = was_battle_shocked or not bool(result.get("passed", false))
	result["source"] = FEARED
	result["modifier"] = -1
	result["modified_total"] = int(result.rolls[0]) + int(result.rolls[1]) - 1
	if not pending.has("results"): pending.results = []
	pending.results.append(result.duplicate(true))
	pending.targets.erase(target)
	var complete: bool = pending.targets.is_empty()
	if complete:
		state["last_feared_interrogator"] = pending.results.duplicate(true)
		state.erase(FEARED)
	else:
		pending.erase("current_result")
		pending.erase("was_battle_shocked")
		pending.erase("decision_owner")
	var message := "Feared Interrogator: %s rolled %s (-1 = %d vs Leadership %d) — %s." % [state.squads[target].name, str(result.rolls), int(result.modified_total), int(result.target), "passed" if result.passed else "Battle-shocked"]
	return {"error": "", "result": result, "complete": complete, "message": message}
