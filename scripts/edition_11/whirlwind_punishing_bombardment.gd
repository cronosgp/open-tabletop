extends RefCounted
## Whirlwind's mandatory post-shot INFANTRY Battle-shock selection and test.
const UnitAbilities = preload("res://scripts/edition_11/unit_abilities.gd")
const Geometry = preload("res://scripts/edition_11/contact_movement.gd")
const Morale = preload("res://scripts/edition_11/morale.gd")
const MarineEnhancements = preload("res://scripts/edition_11/stormlance_enhancements.gd")

const TARGET_WINDOW := "whirlwind-punishing-bombardment-target"
const REROLL_WINDOW := "whirlwind-punishing-bombardment-reroll"
const TARGET_ACTION := "whirlwind-punishing-bombardment-target"
const KEEP_ACTION := "whirlwind-punishing-bombardment-keep"
const REROLL_ACTION := "whirlwind-punishing-bombardment-reroll"
const LAUNCHER_NAME := "Whirlwind Vengeance Launcher"

static func eligible_targets(state: Dictionary, source_squad: int, pools: Array) -> Array[int]:
	var targets: Array[int] = []
	if not UnitAbilities.enabled(state) or state.get("phase", "") != "shooting" or not state.get("squads", {}).has(source_squad): return targets
	var owner := int(state.squads[source_squad].get("owner", -1))
	if owner != int(state.get("active", -2)) or not UnitAbilities.has(state, source_squad, "punishing-bombardment"): return targets
	for pool_value: Variant in pools:
		if not pool_value is Dictionary: continue
		var pool: Dictionary = pool_value
		if str(pool.get("weapon_name", "")) != LAUNCHER_NAME or int(pool.get("hits", 0)) <= 0: continue
		var target := int(pool.get("target_squad", -1))
		if target < 0 or not state.get("squads", {}).has(target) or int(state.squads[target].get("owner", -1)) == owner: continue
		if Geometry.alive(state, target).is_empty() or not UnitAbilities.has_target_keyword(state, target, "INFANTRY"): continue
		if target not in targets: targets.append(target)
	targets.sort()
	return targets

static func open_after_shot(state: Dictionary, source_squad: int, pools: Array) -> bool:
	var targets := eligible_targets(state, source_squad, pools)
	if targets.is_empty(): return false
	var owner := int(state.squads[source_squad].owner)
	var previous: Dictionary = state.get("unit_abilities", {}).get("window", {}).duplicate(true)
	state.unit_abilities.window = {
		"kind": TARGET_WINDOW,
		"owners": [owner],
		"source_squad": source_squad,
		"source_owner": owner,
		"target_squads": targets,
		"turn": int(state.get("turn", 0)),
		"phase": str(state.get("phase", "")),
		"resume_window": previous
	}
	return true

static func window_error(state: Dictionary) -> String:
	var window: Dictionary = state.get("unit_abilities", {}).get("window", {})
	var kind := str(window.get("kind", ""))
	if kind not in [TARGET_WINDOW, REROLL_WINDOW]: return "There is no pending Whirlwind Punishing Bombardment decision."
	if str(state.get("phase", "")) != "shooting" or int(state.get("turn", -1)) != int(window.get("turn", -2)) or str(window.get("phase", "")) != "shooting":
		return "The Whirlwind Punishing Bombardment decision is stale outside its Shooting phase."
	var source := int(window.get("source_squad", -1))
	if not state.get("squads", {}).has(source) or int(state.squads[source].get("owner", -1)) != int(window.get("source_owner", -2)):
		return "The Whirlwind Punishing Bombardment source is no longer valid."
	if kind == TARGET_WINDOW and int(state.get("active", -1)) != int(window.get("owners", [-2])[0]):
		return "Only the Whirlwind player's Shooting phase can resolve Punishing Bombardment."
	if kind == REROLL_WINDOW:
		var target := int(window.get("target_squad", -1))
		if not state.get("squads", {}).has(target) or Geometry.alive(state, target).is_empty() or not UnitAbilities.has_target_keyword(state, target, "INFANTRY"):
			return "The selected Whirlwind target is no longer a living INFANTRY unit."
	return ""

static func choices(state: Dictionary, player: int) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var window: Dictionary = state.get("unit_abilities", {}).get("window", {})
	if not window.get("kind", "") in [TARGET_WINDOW, REROLL_WINDOW] or window.get("owners", []) != [player] or not window_error(state).is_empty(): return result
	if window.kind == TARGET_WINDOW:
		var owner := int(window.owners[0])
		for target: int in window.get("target_squads", []):
			if not state.squads.has(target) or int(state.squads[target].get("owner", -1)) == owner or Geometry.alive(state, target).is_empty() or not UnitAbilities.has_target_keyword(state, target, "INFANTRY"): continue
			result.append({"label": "Punishing Bombardment: %s makes a Battle-shock test" % str(state.squads[target].get("name", "enemy Infantry unit")), "action": TARGET_ACTION, "model": -1, "target": target, "value": ""})
		return result
	var target := int(window.get("target_squad", -1))
	var test_result: Dictionary = window.get("current_result", {})
	if test_result.is_empty() or int(test_result.get("squad", -1)) != target: return result
	result.append({"label": "Keep %s's Battle-shock result" % str(state.squads[target].get("name", "unit")), "action": KEEP_ACTION, "model": -1, "target": target, "value": "keep"})
	if MarineEnhancements.leadership_reroll_available(state, target):
		result.append({"label": "%s: re-roll both Leadership dice for %s" % [MarineEnhancements.leadership_reroll_name(state, target), str(state.squads[target].get("name", "unit"))], "action": REROLL_ACTION, "model": -1, "target": target, "value": "reroll"})
	return result

static func apply(state: Dictionary, player: int, selected: Dictionary, roller: Callable) -> Dictionary:
	var window: Dictionary = state.get("unit_abilities", {}).get("window", {})
	var error := window_error(state)
	if not error.is_empty(): return {"error": error}
	if window.get("owners", []) != [player] or selected not in choices(state, player): return {"error": "Choose a legal Whirlwind Punishing Bombardment option for the current decision."}
	if str(selected.get("action", "")) == TARGET_ACTION:
		var target := int(selected.get("target", -1))
		if target not in window.get("target_squads", []) or not state.squads.has(target) or int(state.squads[target].get("owner", -1)) == player or Geometry.alive(state, target).is_empty() or not UnitAbilities.has_target_keyword(state, target, "INFANTRY"):
			return {"error": "Select a living enemy INFANTRY unit hit by Whirlwind Vengeance Launcher attacks."}
		var result := Morale.roll_battle_shock(state, target, roller)
		if not str(result.get("error", "")).is_empty(): return result
		result.source = "Punishing Bombardment"
		var previous: Dictionary = window.get("resume_window", {}).duplicate(true)
		if MarineEnhancements.leadership_reroll_available(state, target):
			state.unit_abilities.window = {"kind": REROLL_WINDOW, "owners": [int(state.squads[target].owner)], "source_squad": int(window.source_squad), "source_owner": player,
				"target_squad": target, "turn": int(window.turn), "phase": str(window.phase), "current_result": result.duplicate(true), "resume_window": previous}
			return {"error": "", "message": "%s rolled %s vs Leadership %d from Punishing Bombardment; choose to keep or re-roll the result." % [state.squads[target].name, str(result.rolls), int(result.target)]}
		return _apply_result(state, target, result, previous)
	var target_squad := int(window.get("target_squad", -1))
	var current_result: Dictionary = window.get("current_result", {}).duplicate(true)
	var resume: Dictionary = window.get("resume_window", {}).duplicate(true)
	if str(selected.get("action", "")) == REROLL_ACTION:
		if not MarineEnhancements.leadership_reroll_available(state, target_squad): return {"error": "No eligible Leadership re-roll applies to this Battle-shock roll."}
		var rerolled := Morale.roll_battle_shock(state, target_squad, roller, int(current_result.get("modifier", 0)))
		if not str(rerolled.get("error", "")).is_empty(): return rerolled
		rerolled["rerolled_from"] = current_result.get("rolls", []).duplicate()
		rerolled["reroll_source"] = MarineEnhancements.leadership_reroll_name(state, target_squad)
		rerolled["source"] = "Punishing Bombardment"
		current_result = rerolled
	elif str(selected.get("action", "")) == KEEP_ACTION:
		current_result["reroll_declined"] = true
	else:
		return {"error": "Keep the current result or use an available Leadership re-roll."}
	return _apply_result(state, target_squad, current_result, resume)

static func _apply_result(state: Dictionary, target: int, result: Dictionary, resume: Dictionary) -> Dictionary:
	if not state.get("squads", {}).has(target) or Geometry.alive(state, target).is_empty() or not UnitAbilities.has_target_keyword(state, target, "INFANTRY"):
		return {"error": "The Whirlwind target is no longer a living INFANTRY unit."}
	state.squads[target].battle_shocked = not bool(result.get("passed", false))
	state.last_morale = [result.duplicate(true)]
	state.unit_abilities.window = resume
	var result_source := " after a Leadership re-roll" if not result.get("rerolled_from", []).is_empty() else ""
	var passed := bool(result.get("passed", false))
	var message := "%s battle-shock%s from Punishing Bombardment: %s vs %d — %s." % [str(state.squads[target].get("name", "The selected Infantry unit")), result_source, str(result.get("rolls", [])), int(result.get("target", 0)), "passed" if passed else "battle-shocked"]
	return {"error": "", "message": message, "result": result.duplicate(true)}
