extends RefCounted
## Black Templars Execrator post-Fight Battle-shock ability.
const Geometry = preload("res://scripts/edition_11/contact_movement.gd")
const UnitAbilities = preload("res://scripts/edition_11/unit_abilities.gd")
const MarineEnhancements = preload("res://scripts/edition_11/stormlance_enhancements.gd")
const Morale = preload("res://scripts/edition_11/morale.gd")

const IDENTITY := "execrator"
const ABILITY := "condemnatory-annihilation"
const KEEP_ACTION := "execrator-tempered-keep"
const REROLL_ACTION := "execrator-tempered-reroll"
const PENDING_KEY := "execrator_tempered_pending"
const LAST_KEY := "last_execrator_condemnatory_annihilation"

static func engaged_enemy_squads(state: Dictionary, source_squad: int) -> Array[int]:
	var result: Array[int] = []
	if not state.get("squads", {}).has(source_squad): return result
	var source_owner := int(state.squads[source_squad].get("owner", -1))
	var source_models := Geometry.alive(state, source_squad)
	for enemy: int in state.squads:
		if int(state.squads[enemy].get("owner", -1)) == source_owner: continue
		var enemy_models := Geometry.alive(state, enemy)
		if enemy_models.is_empty(): continue
		var engaged := false
		for source_model: int in source_models:
			for enemy_model: int in enemy_models:
				if Geometry.within_engagement(state.units[source_model], state.units[enemy_model]):
					engaged = true
					break
			if engaged: break
		if engaged: result.append(enemy)
	result.sort()
	return result

static func actor(state: Dictionary) -> int:
	var queue: Array = state.get("unit_abilities", {}).get(PENDING_KEY, [])
	if queue.is_empty(): return -1
	return int(queue[0].get("decision_owner", -1))

static func has_pending(state: Dictionary) -> bool:
	return actor(state) > 0

static func choices(state: Dictionary, player: int) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var queue: Array = state.get("unit_abilities", {}).get(PENDING_KEY, [])
	if queue.is_empty(): return result
	var current: Dictionary = queue[0]
	var target := int(current.get("squad", -1))
	if int(current.get("decision_owner", -1)) != player or not state.get("squads", {}).has(target): return result
	var target_name := str(state.squads[target].get("name", "the unit"))
	result.append({"label": "Keep the current Condemnatory Annihilation result for %s" % target_name, "action": KEEP_ACTION, "model": -1, "target": target, "value": "keep"})
	if MarineEnhancements.leadership_reroll_available(state, target):
		result.append({"label": "%s: re-roll both Leadership dice for %s (free)" % [MarineEnhancements.leadership_reroll_name(state, target), target_name], "action": REROLL_ACTION, "model": -1, "target": target, "value": "tempered-in-battle"})
	return result

static func after_fight_kill(state: Dictionary, source_squad: int, melee: bool, killed: int, roller: Callable) -> Dictionary:
	if not melee or killed <= 0 or state.get("phase", "") != "fight" or not UnitAbilities.enabled(state): return {"error": "", "results": [], "message": ""}
	if not UnitAbilities.has(state, source_squad, ABILITY): return {"error": "", "results": [], "message": ""}
	var targets := engaged_enemy_squads(state, source_squad)
	if targets.is_empty(): return {"error": "", "results": [], "message": ""}
	var results: Array[Dictionary] = []
	var rerolls: Array[Dictionary] = []
	for target: int in targets:
		var result := Morale.roll_battle_shock(state, target, roller, -1)
		if not str(result.get("error", "")).is_empty(): return result
		var was_battle_shocked := bool(state.squads[target].get("battle_shocked", false))
		result["source"] = ABILITY
		result["was_battle_shocked"] = was_battle_shocked
		result["battle_shocked"] = was_battle_shocked or not bool(result.get("passed", false))
		result["rerolled_from"] = []
		results.append(result)
		if MarineEnhancements.leadership_reroll_available(state, target):
			rerolls.append({"squad": target, "decision_owner": int(state.squads[target].get("owner", -1)), "was_battle_shocked": was_battle_shocked})
	for result: Dictionary in results:
		state.squads[int(result.squad)].battle_shocked = bool(result.battle_shocked)
	if not state.has("unit_abilities"): state.unit_abilities = {}
	state.unit_abilities[LAST_KEY] = {"source_squad": source_squad, "results": results.duplicate(true)}
	state.unit_abilities[PENDING_KEY] = rerolls
	var resume_cursor := int(state.get("fight_actor", 3 - int(state.squads[source_squad].get("owner", -1))))
	if not rerolls.is_empty(): state.unit_abilities.execrator_resume = {"resume_cursor": resume_cursor, "resume_step": str(state.get("fight_step", "attacks"))}
	return {"error": "", "results": results, "message": result_summary(state, results, not rerolls.is_empty())}

static func result_summary(state: Dictionary, results: Array, reroll_pending: bool = false) -> String:
	if results.is_empty(): return ""
	var lines: Array[String] = []
	for result: Dictionary in results:
		var target := int(result.get("squad", -1))
		if not state.get("squads", {}).has(target): continue
		var status := "failed; Battle-shocked" if not bool(result.get("passed", false)) else "passed"
		if bool(result.get("was_battle_shocked", false)): status += "; existing Battle-shock persists"
		lines.append("%s rolled %s -1 = %d vs Leadership %d (%s)" % [str(state.squads[target].get("name", "Enemy unit")), str(result.get("rolls", [])), int(result.get("modified_total", 0)), int(result.get("target", 0)), status])
	var summary := "Condemnatory Annihilation: " + "; ".join(lines) + "."
	if reroll_pending: summary += " Leadership re-roll choices are pending."
	return summary

static func resolve(state: Dictionary, player: int, selected: Dictionary, roller: Callable) -> Dictionary:
	if selected not in choices(state, player): return {"error": "Choose the current Condemnatory Annihilation result or its eligible Leadership re-roll."}
	var queue: Array = state.unit_abilities.get(PENDING_KEY, []).duplicate(true)
	if queue.is_empty(): return {"error": "The Condemnatory Annihilation decision is no longer pending."}
	var current: Dictionary = queue[0]
	var target := int(current.get("squad", -1))
	var last: Dictionary = state.unit_abilities.get(LAST_KEY, {}).duplicate(true)
	var results: Array = last.get("results", []).duplicate(true)
	var result_index := -1
	for index in range(results.size()):
		if int(results[index].get("squad", -1)) == target:
			result_index = index
			break
	if result_index < 0: return {"error": "The saved Battle-shock result for this unit is missing."}
	var result: Dictionary = results[result_index].duplicate(true)
	if str(selected.get("action", "")) == REROLL_ACTION:
		if not MarineEnhancements.leadership_reroll_available(state, target): return {"error": "No eligible Leadership re-roll applies to this roll."}
		var rerolled := Morale.roll_battle_shock(state, target, roller, -1)
		if not str(rerolled.get("error", "")).is_empty(): return rerolled
		rerolled["source"] = ABILITY
		rerolled["rerolled_from"] = result.get("rolls", []).duplicate()
		rerolled["was_battle_shocked"] = bool(current.get("was_battle_shocked", false))
		rerolled["battle_shocked"] = bool(rerolled.was_battle_shocked) or not bool(rerolled.get("passed", false))
		result = rerolled
		state.squads[target].battle_shocked = bool(result.battle_shocked)
	results[result_index] = result
	last.results = results
	state.unit_abilities[LAST_KEY] = last
	var resume: Dictionary = state.unit_abilities.get("execrator_resume", {}).duplicate(true)
	queue.pop_front()
	state.unit_abilities[PENDING_KEY] = queue
	if queue.is_empty(): state.unit_abilities.erase("execrator_resume")
	var name := str(state.squads[target].get("name", "Enemy unit"))
	var outcome := "re-rolled" if str(selected.get("action", "")) == REROLL_ACTION else "kept"
	var message := "Condemnatory Annihilation: %s %s result %s -1 = %d vs Leadership %d (%s)." % [name, outcome, str(result.get("rolls", [])), int(result.get("modified_total", 0)), int(result.get("target", 0)), "failed; Battle-shocked" if not bool(result.get("passed", false)) else "passed"]
	if state.get("last_attack", {}) is Dictionary and not state.last_attack.is_empty():
		state.last_attack.message = str(state.last_attack.get("message", "")) + " " + message
		state.last_attack.execrator_condemnatory_annihilation = results.duplicate(true)
	if queue.is_empty() and str(state.get("unit_abilities", {}).get("window", {}).get("kind", "")) != "counter":
		return {"error": "", "resume_fight": true, "resume_cursor": int(resume.get("resume_cursor", state.get("fight_actor", player))), "resume_fight_step": str(resume.get("resume_step", state.get("fight_step", "attacks"))), "message": message}
	return {"error": "", "message": message}
