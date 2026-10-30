extends RefCounted
## Source-bounded 11th-edition Blood Angels rules for Chief Librarian Mephiston.

const Abilities = preload("res://scripts/edition_11/unit_ability_catalog.gd")
const Geometry = preload("res://scripts/edition_11/contact_movement.gd")
const RandomStat = preload("res://scripts/edition_11/random_characteristic.gd")
const LeadershipRerolls = preload("res://scripts/edition_11/stormlance_enhancements.gd")

const IDENTITY := "mephiston"
const FALLBACK_WINDOW := "mephiston-fallback-leadership"

static func models(state: Dictionary, owner: int) -> Array[int]:
	var result: Array[int] = []
	if not Abilities.enabled(state): return result
	for model: int in state.get("units", {}):
		var unit: Dictionary = state.units[model]
		if int(unit.get("owner", -1)) == owner and Abilities.identity(unit) == IDENTITY and int(unit.get("wounds", 0)) > 0 and bool(unit.get("on_battlefield", true)):
			result.append(model)
	result.sort()
	return result

static func _usage_key(model: int, round_number: int, power: String) -> String:
	return "mephiston:%d:%d:%s" % [model, round_number, power]

static func start_available(state: Dictionary, owner: int) -> bool:
	if not Abilities.enabled(state) or state.get("phase", "") not in ["command", "movement"]: return false
	for model: int in models(state, owner):
		var squad := int(state.units[model].get("squad", -1))
		if not state.get("squads", {}).has(squad) or bool(state.squads[squad].get("battle_shocked", false)): continue
		if state.phase == "command" and int(state.get("active", -1)) == owner and not state.unit_abilities.get("used", {}).has(_usage_key(model, int(state.get("round", 0)), "quickening")): return true
		if state.phase == "movement" and int(state.get("active", -1)) != owner and not state.unit_abilities.get("used", {}).has(_usage_key(model, int(state.get("round", 0)), "transfixing-gaze")): return true
	return false

static func start_choices(state: Dictionary, owner: int) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if not start_available(state, owner): return result
	for model: int in models(state, owner):
		var squad := int(state.units[model].get("squad", -1))
		if not state.get("squads", {}).has(squad) or bool(state.squads[squad].get("battle_shocked", false)): continue
		if state.phase == "command" and int(state.get("active", -1)) == owner and not state.unit_abilities.used.has(_usage_key(model, int(state.round), "quickening")):
			result.append({"label": "Mephiston %d: Quickening (Psychic test; gain Assault Doctrine)" % model, "action": "mephiston-psychic", "model": model, "target": squad, "value": "quickening"})
		if state.phase == "movement" and int(state.get("active", -1)) != owner and not state.unit_abilities.used.has(_usage_key(model, int(state.round), "transfixing-gaze")):
			result.append({"label": "Mephiston %d: Transfixing Gaze (Psychic test; hinder nearby Fall Backs)" % model, "action": "mephiston-psychic", "model": model, "target": squad, "value": "transfixing-gaze"})
	return result

static func use_psychic(state: Dictionary, player: int, selected: Dictionary, roller: Callable) -> Dictionary:
	var model := int(selected.get("model", -1))
	var bearer: Dictionary = state.get("units", {}).get(model, {})
	var squad := int(bearer.get("squad", -1))
	var power := str(selected.get("value", ""))
	if bearer.is_empty() or int(bearer.get("owner", -1)) != player or int(bearer.get("wounds", 0)) <= 0 or not bool(bearer.get("on_battlefield", true)) or Abilities.identity(bearer) != IDENTITY or not state.get("squads", {}).has(squad): return {"error": "A living Chief Librarian Mephiston must use this Psychic ability."}
	if state.get("unit_abilities", {}).get("window", {}).get("kind", "") != "start" or state.unit_abilities.window.get("owners", []) != [player]: return {"error": "Mephiston's Psychic ability is selected in its start-of-phase window."}
	if bool(state.squads[squad].get("battle_shocked", false)): return {"error": "A Battle-shocked unit cannot use this Psychic ability."}
	if power == "quickening":
		if state.phase != "command" or int(state.get("active", -1)) != player: return {"error": "Quickening is used in Mephiston's Command phase."}
	elif power == "transfixing-gaze":
		if state.phase != "movement" or int(state.get("active", -1)) == player: return {"error": "Transfixing Gaze is used at the start of the opponent's Movement phase."}
	else:
		return {"error": "Unknown Mephiston Psychic ability."}
	var used_key := _usage_key(model, int(state.get("round", 0)), power)
	if state.unit_abilities.used.has(used_key): return {"error": "Mephiston has already used this Psychic ability this phase."}
	var psychic_roll := RandomStat.roll("D6", roller)
	if not str(psychic_roll.get("error", "")).is_empty(): return psychic_roll
	state.unit_abilities.used[used_key] = true
	var record := {"source": model, "squad": squad, "power": power, "roll": int(psychic_roll.value), "battle_shocked": int(psychic_roll.value) == 1}
	if power == "quickening" and int(psychic_roll.value) != 1:
		if not state.unit_abilities.has("mephiston_quickening"): state.unit_abilities.mephiston_quickening = {}
		state.unit_abilities.mephiston_quickening[squad] = {"source": model, "owner": player, "expires_turn": int(state.turn) + 2, "roll": int(psychic_roll.value)}
	elif power == "transfixing-gaze" and int(psychic_roll.value) != 1:
		if not state.unit_abilities.has("mephiston_transfixing_gaze"): state.unit_abilities.mephiston_transfixing_gaze = {}
		state.unit_abilities.mephiston_transfixing_gaze[model] = {"source": model, "owner": player, "phase_key": "%d:movement" % int(state.turn)}
	if int(psychic_roll.value) == 1:
		state.squads[squad].battle_shocked = true
	if not state.unit_abilities.has("mephiston_psychic_results"): state.unit_abilities.mephiston_psychic_results = []
	state.unit_abilities.mephiston_psychic_results.append(record)
	var result := {"error": "", "message": "Mephiston's %s Psychic test rolled %d%s." % ["Quickening" if power == "quickening" else "Transfixing Gaze", int(psychic_roll.value), "; the unit becomes Battle-shocked" if int(psychic_roll.value) == 1 else ""]}
	if int(psychic_roll.value) == 1: result.interrupt_squad = squad
	return result

static func quickening_additional_doctrine(state: Dictionary, squad: int) -> Array[String]:
	var result: Array[String] = []
	if not Abilities.enabled(state) or not state.get("squads", {}).has(squad): return result
	var effect: Dictionary = state.get("unit_abilities", {}).get("mephiston_quickening", {}).get(squad, {})
	if effect.is_empty() or int(state.get("turn", 0)) >= int(effect.get("expires_turn", -1)) or int(effect.get("owner", -1)) != int(state.squads[squad].get("owner", -2)): return result
	var source := int(effect.get("source", -1))
	if not state.get("units", {}).has(source) or int(state.units[source].get("squad", -1)) != squad or int(state.units[source].get("wounds", 0)) <= 0: return result
	result.append("assault")
	return result

static func transfixing_gaze_sources(state: Dictionary, target_squad: int) -> Array[int]:
	var result: Array[int] = []
	if not Abilities.enabled(state) or not state.get("squads", {}).has(target_squad) or Geometry.alive(state, target_squad).is_empty() or state.phase != "movement": return result
	var target_owner := int(state.squads[target_squad].get("owner", -1))
	var expected_phase_key := "%d:movement" % int(state.get("turn", 0))
	for model_value: Variant in state.get("unit_abilities", {}).get("mephiston_transfixing_gaze", {}):
		var model := int(model_value)
		if not state.get("units", {}).has(model): continue
		var source: Dictionary = state.units[model]
		var mark: Dictionary = state.unit_abilities.mephiston_transfixing_gaze.get(model, {})
		if int(source.get("owner", -1)) == target_owner or int(source.get("owner", -1)) == int(state.get("active", -2)) or int(mark.get("owner", -1)) != int(source.get("owner", -2)) or str(mark.get("phase_key", "")) != expected_phase_key: continue
		if int(source.get("wounds", 0)) <= 0 or not bool(source.get("on_battlefield", true)) or Abilities.identity(source) != IDENTITY: continue
		if Geometry.distance_to_target(state, source, target_squad) <= 6.0 + Geometry.EPSILON: result.append(model)
	result.sort()
	return result

static func fallback_resolution_key(state: Dictionary, squad: int) -> String:
	return "%d:%d" % [int(state.get("turn", 0)), squad]

static func fallback_resolved(state: Dictionary, squad: int) -> bool:
	return bool(state.get("unit_abilities", {}).get("mephiston_gaze_resolved", {}).get(fallback_resolution_key(state, squad), false))

static func record_fallback_test(state: Dictionary, target_squad: int, result: Dictionary) -> void:
	if not state.unit_abilities.has("mephiston_gaze_resolved"): state.unit_abilities.mephiston_gaze_resolved = {}
	state.unit_abilities.mephiston_gaze_resolved[fallback_resolution_key(state, target_squad)] = true
	if not state.has("last_morale"): state.last_morale = []
	state.last_morale.append(result.duplicate(true))

static func open_fallback_reroll(state: Dictionary, player: int, target_squad: int, source_model: int, movement: Dictionary, current_result: Dictionary) -> void:
	state.unit_abilities.window = {"kind": FALLBACK_WINDOW, "owners": [player], "squad": target_squad, "source_model": source_model, "movement": movement.duplicate(true), "current_result": current_result.duplicate(true), "round": int(state.get("round", 0)), "turn": int(state.get("turn", 0))}

static func fallback_choices(state: Dictionary, player: int) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var window: Dictionary = state.get("unit_abilities", {}).get("window", {})
	var target := int(window.get("squad", -1))
	if window.get("kind", "") != FALLBACK_WINDOW or window.get("owners", []) != [player] or not state.get("squads", {}).has(target) or int(state.get("turn", -1)) != int(window.get("turn", -2)): return result
	result.append({"label": "Keep the Leadership result for %s" % str(state.squads[target].get("name", "the unit")), "action": FALLBACK_WINDOW, "model": int(window.get("source_model", -1)), "target": target, "value": "keep"})
	if LeadershipRerolls.leadership_reroll_available(state, target):
		result.append({"label": "%s: re-roll both Leadership dice" % LeadershipRerolls.leadership_reroll_name(state, target), "action": FALLBACK_WINDOW, "model": int(window.get("source_model", -1)), "target": target, "value": "reroll"})
	return result

static func complete_fallback_choice(state: Dictionary, player: int, selected: Dictionary, outcome: Dictionary) -> Dictionary:
	var window: Dictionary = state.get("unit_abilities", {}).get("window", {})
	var target := int(window.get("squad", -1))
	if window.get("kind", "") != FALLBACK_WINDOW or window.get("owners", []) != [player] or int(window.get("round", -1)) != int(state.get("round", -2)) or int(window.get("turn", -1)) != int(state.get("turn", -2)) or selected not in fallback_choices(state, player): return {"error": "No matching Mephiston Leadership re-roll decision is pending."}
	if not outcome.has("rerolled"): outcome.rerolled = false
	record_fallback_test(state, target, outcome)
	state.unit_abilities.window = {}
	return {"error": "", "resume_mephiston_fallback": window.get("movement", {}).duplicate(true), "fallback_passed": bool(outcome.get("passed", false)), "fallback_result": outcome, "message": "%s Leadership test %s vs %d: %s." % [str(state.squads[target].get("name", "The unit")), str(outcome.get("rolls", [])), int(outcome.get("target", -1)), "passed; continue its Fall Back" if bool(outcome.get("passed", false)) else "failed; it must Remain Stationary"]}
