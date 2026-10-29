extends RefCounted
## Reiver Squad abilities sourced from the local Wahapedia e11 extract.
const Geometry = preload("res://scripts/edition_11/contact_movement.gd")
const Abilities = preload("res://scripts/edition_11/unit_abilities.gd")
const Morale = preload("res://scripts/edition_11/morale.gd")
const MarineEnhancements = preload("res://scripts/edition_11/stormlance_enhancements.gd")
const FEARSOME := "fearsome-assault"

static func begin_fight(state: Dictionary) -> bool:
	if state.phase != "fight" or not Abilities.enabled(state): return false
	var targets: Array[int] = []
	for source_squad: int in state.squads:
		if not Abilities.has(state, source_squad, FEARSOME): continue
		var sources := Geometry.alive(state, source_squad)
		for target_squad: int in state.squads:
			if state.squads[target_squad].owner == state.squads[source_squad].owner or Geometry.alive(state, target_squad).is_empty(): continue
			var engaged := false
			for source: int in sources:
				if Geometry.distance_to_target_at_height(state, state.units[source], target_squad) <= 2.0 + Geometry.EPSILON:
					engaged = true
					break
			if engaged and target_squad not in targets: targets.append(target_squad)
	targets.sort()
	if targets.is_empty():
		state.erase("fearsome_assault")
		return false
	state.fearsome_assault = {"owner": state.active, "targets": targets, "results": []}
	return true

static func choices(state: Dictionary, player: int) -> Array:
	var pending: Dictionary = state.get("fearsome_assault", {})
	if pending.is_empty(): return []
	var current_result: Dictionary = pending.get("current_result", {})
	if not current_result.is_empty():
		var target := int(current_result.get("squad", -1))
		if int(pending.get("decision_owner", -1)) != player or not state.squads.has(target): return []
		var decision_options: Array[Dictionary] = [{"label": "Keep the current Fearsome Assault result for %s" % state.squads[target].name, "action": FEARSOME, "model": -1, "target": target, "value": "keep"}]
		if MarineEnhancements.leadership_reroll_available(state, target):
			decision_options.append({"label": "%s: re-roll both Leadership dice for %s (free)" % [MarineEnhancements.leadership_reroll_name(state, target), state.squads[target].name], "action": FEARSOME, "model": -1, "target": target, "value": "tempered-in-battle"})
		return decision_options
	if int(pending.get("owner", -1)) != player: return []
	var result: Array[Dictionary] = []
	for squad: int in pending.get("targets", []):
		if not state.squads.has(squad) or Geometry.alive(state, squad).is_empty(): continue
		result.append({"label": "Fearsome Assault: roll Battle-shock for %s (-1 to the roll)" % state.squads[squad].name, "action": FEARSOME, "model": -1, "target": squad, "value": "roll"})
	return result

static func resolve(state: Dictionary, player: int, selected: Dictionary, roller: Callable) -> Dictionary:
	if selected not in choices(state, player): return {"error": "Fearsome Assault requires each eligible enemy unit to take its Battle-shock test."}
	var target: int = int(selected.target)
	var result: Dictionary
	var was_battle_shocked: bool
	var current_result: Dictionary = state.fearsome_assault.get("current_result", {})
	if not current_result.is_empty():
		was_battle_shocked = bool(state.fearsome_assault.get("was_battle_shocked", false))
		if selected.value == "tempered-in-battle":
			if not MarineEnhancements.leadership_reroll_available(state, target): return {"error": "No eligible Leadership re-roll applies to this roll."}
			result = Morale.roll_battle_shock(state, target, roller, -1)
			if not result.error.is_empty(): return result
			result["rerolled_from"] = current_result.get("rolls", []).duplicate()
		else:
			if selected.value != "keep": return {"error": "Choose whether to keep or re-roll the Fearsome Assault result."}
			result = current_result.duplicate(true)
	else:
		result = Morale.roll_battle_shock(state, target, roller, -1)
		if not result.error.is_empty(): return result
		was_battle_shocked = bool(state.squads[target].battle_shocked)
		if MarineEnhancements.leadership_reroll_available(state, target):
			result["source"] = FEARSOME
			result["modified_total"] = int(result.rolls[0]) + int(result.rolls[1]) - 1
			state.fearsome_assault.current_result = result.duplicate(true)
			state.fearsome_assault.was_battle_shocked = was_battle_shocked
			state.fearsome_assault.decision_owner = int(state.squads[target].owner)
			return {"error": "", "pending_reroll": true, "message": "Fearsome Assault Leadership result is waiting for the target unit's controller."}
	state.squads[target].battle_shocked = was_battle_shocked or not result.passed
	result["source"] = FEARSOME
	result["modifier"] = -1
	result["modified_total"] = int(result.rolls[0]) + int(result.rolls[1]) - 1
	if not state.fearsome_assault.has("results"): state.fearsome_assault.results = []
	state.fearsome_assault.results.append(result.duplicate(true))
	state.fearsome_assault.targets.erase(target)
	var complete: bool = state.fearsome_assault.targets.is_empty()
	if complete:
		state.last_fearsome_assault = state.fearsome_assault.results.duplicate(true)
		state.erase("fearsome_assault")
	else:
		state.fearsome_assault.erase("current_result")
		state.fearsome_assault.erase("was_battle_shocked")
		state.fearsome_assault.erase("decision_owner")
	var message := "Fearsome Assault: %s rolled %s (-1 = %d vs Leadership %d) — %s." % [state.squads[target].name, str(result.rolls), int(result.modified_total), int(result.target), "passed" if result.passed else "Battle-shocked"]
	return {"error": "", "result": result, "complete": complete, "message": message}
