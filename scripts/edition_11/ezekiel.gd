extends RefCounted
## Ezekiel's active Engulfing Fear ability and its Leadership decision flow.
const A = preload("res://scripts/edition_11/unit_abilities.gd")
const Geometry = preload("res://scripts/edition_11/contact_movement.gd")
const RandomStat = preload("res://scripts/edition_11/random_characteristic.gd")
const Morale = preload("res://scripts/edition_11/morale.gd")
const Enhancements = preload("res://scripts/edition_11/stormlance_enhancements.gd")
const Actions = preload("res://scripts/edition_11/actions.gd")

const TARGET_WINDOW := "engulfing-fear-target"
const REROLL_WINDOW := "engulfing-fear-reroll"
const ABILITY := "engulfing-fear"

static func phase_key(state: Dictionary) -> String:
	return "%d:%s" % [int(state.get("turn", 0)), str(state.get("phase", ""))]

static func used_key(state: Dictionary, squad: int) -> String:
	return "%s:%d:%s" % [ABILITY, squad, phase_key(state)]

static func available(state: Dictionary, player: int, source: int, require_target: bool = true) -> bool:
	var unit: Dictionary = state.get("units", {}).get(source, {})
	if not A.enabled(state) or unit.is_empty() or int(unit.get("owner", -1)) != player or int(unit.get("wounds", 0)) <= 0 or not unit.get("on_battlefield", true): return false
	var squad := int(unit.get("squad", -1))
	if not state.get("squads", {}).has(squad) or int(state.squads[squad].get("owner", -1)) != player or bool(state.squads[squad].get("battle_shocked", false)): return false
	if state.phase != "shooting" or int(state.active) != player or state.unit_abilities.get("window", {}).size() > 0 or state.unit_abilities.used.has(used_key(state, squad)): return false
	if source not in A.sources(state, squad, ABILITY): return false
	return not require_target or not eligible_targets(state, player, source).is_empty()

static func eligible_targets(state: Dictionary, player: int, source: int) -> Array[int]:
	var result: Array[int] = []
	if not state.get("units", {}).has(source): return result
	for target: int in state.squads:
		if int(state.squads[target].get("owner", -1)) == player or Geometry.alive(state, target).is_empty(): continue
		if Geometry.distance_to_target(state, state.units[source], target) <= 12.001: result.append(target)
	return result

static func choices(state: Dictionary, player: int) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var window: Dictionary = state.get("unit_abilities", {}).get("window", {})
	var kind := str(window.get("kind", ""))
	if kind == TARGET_WINDOW:
		if window.get("owners", []) != [player]: return result
		var source := int(window.get("source", -1))
		for target: int in eligible_targets(state, player, source):
			result.append({"label": "Engulfing Fear: make %s take a Battle-shock test (-1)" % state.squads[target].name, "action": TARGET_WINDOW, "model": source, "target": target, "value": "target"})
		return result
	if kind == REROLL_WINDOW:
		var target := int(window.get("target", -1))
		if window.get("owners", []) != [player] or not state.squads.has(target): return result
		result.append({"label": "Keep the Engulfing Fear Battle-shock result for %s" % state.squads[target].name, "action": REROLL_WINDOW, "model": -1, "target": target, "value": "keep"})
		if Enhancements.leadership_reroll_available(state, target):
			result.append({"label": "%s: re-roll both Leadership dice for %s (free)" % [Enhancements.leadership_reroll_name(state, target), state.squads[target].name], "action": REROLL_WINDOW, "model": -1, "target": target, "value": "tempered-in-battle"})
		return result
	if not window.is_empty() or state.phase != "shooting" or int(state.active) != player: return result
	for squad: int in state.squads:
		if int(state.squads[squad].get("owner", -1)) != player: continue
		for source: int in A.sources(state, squad, ABILITY):
			if available(state, player, source):
				result.append({"label": "Ezekiel %d: use Engulfing Fear (Psychic roll, then choose an enemy within 12 inches)" % source, "action": ABILITY, "model": source, "target": -1, "value": "use"})
	return result

static func resolve(state: Dictionary, player: int, selected: Dictionary, roller: Callable) -> Dictionary:
	var action := str(selected.get("action", ""))
	if action == ABILITY: return _start(state, player, selected, roller)
	var window: Dictionary = state.get("unit_abilities", {}).get("window", {})
	if action == TARGET_WINDOW: return _target(state, player, selected, roller, window)
	if action == REROLL_WINDOW: return _reroll(state, player, selected, roller, window)
	return {"error": "Unknown Engulfing Fear decision."}

static func _start(state: Dictionary, player: int, selected: Dictionary, roller: Callable) -> Dictionary:
	if selected.value != "use" or selected not in choices(state, player) or not available(state, player, int(selected.get("model", -1))):
		return {"error": "Engulfing Fear requires a living, un-Battle-shocked Ezekiel in your Shooting phase and an enemy within 12 inches."}
	var source := int(selected.model)
	var squad := int(state.units[source].squad)
	var psychic_roll := RandomStat.roll("D6", roller)
	if not psychic_roll.error.is_empty(): return psychic_roll
	state.unit_abilities.used[used_key(state, squad)] = true
	if psychic_roll.value == 1:
		state.squads[squad].battle_shocked = true
		Actions.interrupt(state, squad, "unit became battle-shocked")
	state.unit_abilities.window = {"kind": TARGET_WINDOW, "owners": [player], "source": source, "source_squad": squad, "psychic_roll": int(psychic_roll.value)}
	return {"error": "", "message": "Engulfing Fear psychic roll: %d. Select an enemy unit within 12 inches." % int(psychic_roll.value)}

static func _target(state: Dictionary, player: int, selected: Dictionary, roller: Callable, window: Dictionary) -> Dictionary:
	var source := int(window.get("source", -1))
	var squad := int(window.get("source_squad", -1))
	var target := int(selected.get("target", -1))
	if window.get("kind", "") != TARGET_WINDOW or window.get("owners", []) != [player] or selected.get("value", "") != "target" or int(selected.get("model", -1)) != source:
		return {"error": "Choose an enemy unit for the pending Engulfing Fear ability."}
	if not state.get("squads", {}).has(squad) or source not in A.sources(state, squad, ABILITY) or target not in eligible_targets(state, player, source):
		return {"error": "Engulfing Fear requires a living enemy unit within 12 inches of Ezekiel."}
	var result := Morale.roll_battle_shock(state, target, roller, -1)
	if not result.error.is_empty(): return result
	var was_battle_shocked := bool(state.squads[target].get("battle_shocked", false))
	result.source = ABILITY
	result.modifier = -1
	result.modified_total = int(result.rolls[0]) + int(result.rolls[1]) - 1
	if Enhancements.leadership_reroll_available(state, target):
		state.unit_abilities.window = {"kind": REROLL_WINDOW, "owners": [int(state.squads[target].owner)], "source_squad": squad, "source": source, "target": target, "psychic_roll": int(window.get("psychic_roll", 0)), "was_battle_shocked": was_battle_shocked, "current_result": result.duplicate(true)}
		return {"error": "", "pending_reroll": true, "message": "Engulfing Fear Leadership result is waiting for the target unit's controller."}
	return _finish(state, target, was_battle_shocked, result, int(window.get("psychic_roll", 0)))

static func _reroll(state: Dictionary, player: int, selected: Dictionary, roller: Callable, window: Dictionary) -> Dictionary:
	var target := int(window.get("target", -1))
	if window.get("kind", "") != REROLL_WINDOW or window.get("owners", []) != [player] or target != int(selected.get("target", -1)):
		return {"error": "There is no matching Engulfing Fear Leadership decision."}
	var current: Dictionary = window.get("current_result", {}).duplicate(true)
	var result: Dictionary
	if selected.get("value", "") == "tempered-in-battle":
		if not Enhancements.leadership_reroll_available(state, target): return {"error": "No eligible Leadership re-roll applies to this roll."}
		result = Morale.roll_battle_shock(state, target, roller, -1)
		if not result.error.is_empty(): return result
		result.source = ABILITY
		result.modifier = -1
		result.modified_total = int(result.rolls[0]) + int(result.rolls[1]) - 1
		result.rerolled_from = current.get("rolls", []).duplicate()
	elif selected.get("value", "") == "keep":
		result = current
	else:
		return {"error": "Keep the Engulfing Fear result or use the available Leadership re-roll."}
	return _finish(state, target, bool(window.get("was_battle_shocked", false)), result, int(window.get("psychic_roll", 0)))

static func _finish(state: Dictionary, target: int, was_battle_shocked: bool, result: Dictionary, psychic_roll: int) -> Dictionary:
	state.squads[target].battle_shocked = was_battle_shocked or not bool(result.get("passed", false))
	result.psychic_roll = psychic_roll
	if not state.unit_abilities.has("engulfing_fear_results"): state.unit_abilities.engulfing_fear_results = []
	state.unit_abilities.engulfing_fear_results.append(result.duplicate(true))
	state.last_engulfing_fear = result.duplicate(true)
	state.unit_abilities.window = {}
	var message := "Engulfing Fear: %s rolled %s (-1 = %d vs Leadership %d) — %s." % [state.squads[target].name, str(result.rolls), int(result.modified_total), int(result.target), "passed" if result.passed else "Battle-shocked"]
	return {"error": "", "result": result, "message": message}
