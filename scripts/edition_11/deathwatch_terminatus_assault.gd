extends RefCounted
## Deathwatch Terminatus Assault: a post-charge Battle-shock test for each engaged enemy unit.
const Geometry = preload("res://scripts/edition_11/contact_movement.gd")
const UnitAbilities = preload("res://scripts/edition_11/unit_abilities.gd")
const Morale = preload("res://scripts/edition_11/morale.gd")
const LeadershipRerolls = preload("res://scripts/edition_11/stormlance_enhancements.gd")
const Stratagems = preload("res://scripts/edition_11/stratagems.gd")
const ID := "deathwatch-terminatus-assault"
const BATTLE_SHOCK_WINDOW := Stratagems.DEATHWATCH_TERMINATUS_BATTLE_SHOCK

static func engaged_targets(state: Dictionary, charging_squad: int) -> Array[int]:
	var result: Array[int] = []
	if not state.get("squads", {}).has(charging_squad) or not UnitAbilities.has(state, charging_squad, ID): return result
	for target: int in state.get("squads", {}):
		if int(state.squads[target].get("owner", -1)) == int(state.squads[charging_squad].get("owner", -1)): continue
		var engaged := false
		for attacker: int in Geometry.alive(state, charging_squad):
			if not bool(state.units[attacker].get("on_battlefield", true)): continue
			for enemy: int in Geometry.alive(state, target):
				if not bool(state.units[enemy].get("on_battlefield", true)) or not bool(state.squads[target].get("on_battlefield", true)): continue
				if Geometry.within_engagement(state.units[attacker], state.units[enemy]):
					engaged = true
					break
			if engaged: break
		if engaged: result.append(target)
	result.sort()
	return result

static func _has_keyword(state: Dictionary, squad: int, keyword: String) -> bool:
	for model: int in Geometry.alive(state, squad):
		for value: Variant in state.units[model].get("keywords", []):
			if str(value).strip_edges().to_upper() == keyword.to_upper(): return true
	return false

static func modifier(state: Dictionary, target: int) -> int:
	return 0 if _has_keyword(state, target, "IMPERIUM") or _has_keyword(state, target, "CHAOS") else -1

static func _roll(state: Dictionary, target: int, roller: Callable) -> Dictionary:
	var result := Morale.roll_battle_shock(state, target, roller, modifier(state, target))
	if result.get("error", "").is_empty(): result["source"] = ID
	return result

static func _apply_result(state: Dictionary, result: Dictionary) -> void:
	var target := int(result.get("squad", -1))
	if not state.get("squads", {}).has(target): return
	# Outside the Command phase, passing another test does not clear a condition
	# that persists until the start of the unit's next Command phase.
	if not bool(result.get("passed", false)): state.squads[target].battle_shocked = true
	var result_source := " after a Leadership re-roll" if result.get("rerolled_from", []).size() > 0 else ""
	var modifier_text := " (%+d modifier)" % int(result.get("modifier", 0)) if int(result.get("modifier", 0)) != 0 else ""
	state.events.append({"revision": int(state.get("revision", 0)) + 1, "message": "%s battle-shock%s: %s vs %d%s — %s." % [state.squads[target].name, result_source, str(result.get("rolls", [])), int(result.get("target", 0)), modifier_text, "passed" if result.get("passed", false) else "battle-shocked"]})

static func _roll_next(state: Dictionary, batch: Dictionary, roller: Callable) -> Dictionary:
	var remaining: Array = batch.get("remaining", [])
	while not remaining.is_empty():
		var target := int(remaining.pop_front())
		if not state.get("squads", {}).has(target) or Geometry.alive(state, target).is_empty(): continue
		var result := _roll(state, target, roller)
		if not str(result.get("error", "")).is_empty(): return result
		if LeadershipRerolls.leadership_reroll_available(state, target):
			batch["remaining"] = remaining
			batch["squad"] = target
			batch["player"] = int(state.squads[target].get("owner", -1))
			batch["phase_key"] = Stratagems.phase_key(state)
			batch["current_result"] = result
			var modifier_text := " (%+d modifier)" % int(result.get("modifier", 0)) if int(result.get("modifier", 0)) != 0 else ""
			state.events.append({"revision": int(state.get("revision", 0)) + 1, "message": "Deathwatch Terminatus Assault: %s rolled %s vs %d%s. Its controller can re-roll both dice or accept the result." % [state.squads[target].name, str(result.get("rolls", [])), int(result.get("target", 0)), modifier_text]})
			return {"error": "", "pending": true}
		_apply_result(state, result)
		batch.results.append(result)
		state.last_morale = batch.results.duplicate(true)
	batch.erase("squad")
	batch.erase("player")
	batch.erase("current_result")
	state.last_morale = batch.get("results", []).duplicate(true)
	return {"error": "", "pending": false}

static func begin_charge(state: Dictionary, charging_squad: int, charging_player: int, roller: Callable, resume_heroic: bool) -> Dictionary:
	var targets := engaged_targets(state, charging_squad)
	if targets.is_empty(): return {"error": "", "results": [], "pending": {}}
	if not roller.is_valid(): return {"error": "Deathwatch Terminatus Assault requires the host's Battle-shock dice provider."}
	var batch := {"kind": BATTLE_SHOCK_WINDOW, "player": -1, "squad": -1, "charge_squad": charging_squad, "charge_player": charging_player, "resume_heroic": resume_heroic, "phase_key": Stratagems.phase_key(state), "remaining": targets, "results": []}
	var next := _roll_next(state, batch, roller)
	if not str(next.get("error", "")).is_empty(): return next
	var results: Array = batch.get("results", []).duplicate(true)
	var pending: Dictionary = {}
	if bool(next.get("pending", false)): pending = batch
	return {"error": "", "results": results, "pending": pending}

static func resolve_pending(state: Dictionary, player: int, squad: int, decision: String, roller: Callable) -> Dictionary:
	var batch: Dictionary = state.get("stratagems", {}).get("pending", {})
	if batch.get("kind", "") != BATTLE_SHOCK_WINDOW or int(batch.get("squad", -1)) != squad or int(batch.get("player", -1)) != player:
		return {"error": "There is no matching Deathwatch Terminatus Assault Battle-shock decision."}
	var current: Dictionary = batch.get("current_result", {}).duplicate(true)
	if decision == "tempered-in-battle":
		if not LeadershipRerolls.leadership_reroll_available(state, squad): return {"error": "No eligible Leadership re-roll applies to this Battle-shock test."}
		var rerolled := Morale.roll_battle_shock(state, squad, roller, int(current.get("modifier", 0)))
		if not str(rerolled.get("error", "")).is_empty(): return rerolled
		rerolled["source"] = ID
		rerolled["rerolled_from"] = current.get("rolls", []).duplicate()
		rerolled["reroll_source"] = LeadershipRerolls.leadership_reroll_name(state, squad)
		current = rerolled
	elif not decision.is_empty():
		return {"error": "Accept the result or use an eligible Leadership re-roll."}
	_apply_result(state, current)
	batch.results.append(current)
	state.last_morale = batch.results.duplicate(true)
	var next := _roll_next(state, batch, roller)
	if not str(next.get("error", "")).is_empty(): return next
	if bool(next.get("pending", false)):
		state.stratagems.pending = batch
		return {"error": "", "pending": true}
	var charge_squad := int(batch.get("charge_squad", -1))
	var charge_player := int(batch.get("charge_player", -1))
	var resume_heroic := bool(batch.get("resume_heroic", false))
	state.stratagems.pending = {}
	return {"error": "", "pending": false, "charge_squad": charge_squad, "charge_player": charge_player, "resume_heroic": resume_heroic, "results": batch.get("results", []).duplicate(true)}
