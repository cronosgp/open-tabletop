extends RefCounted
## Ravenwing Dark Talon's Stasis Bomb and its next-Movement continuation.
const Terrain = preload("res://scripts/edition_11/terrain.gd")
const AircraftRules = preload("res://scripts/edition_11/aircraft_rules.gd")
const MORTAL_WINDOW := "ravenwing-stasis-bomb-mortal"
const RESUME_WINDOW := "ravenwing-stasis-bomb-resume-movement"

static func can_target(state: Dictionary, model: int, target: int) -> bool:
	if not state.get("units", {}).has(model) or not state.get("squads", {}).has(target): return false
	var source: Dictionary = state.units[model]
	if int(source.get("wounds", 0)) <= 0 or not source.get("on_battlefield", true): return false
	if int(source.get("owner", -1)) == int(state.squads[target].get("owner", -1)): return false
	if _has_keyword(state, target, "AIRCRAFT") or _has_keyword(state, target, "LONE OPERATIVE"): return false
	if state.get("unit_abilities", {}).get("stasis_bomb_marks", {}).has(target): return false
	var sight := Terrain.targeting(state, model, target)
	return bool(sight.get("visible", false)) and float(sight.get("distance", INF)) <= 24.001

static func available(state: Dictionary, player: int) -> bool:
	return _end_window_allows(state, player) and has_candidates(state, player)

static func has_candidates(state: Dictionary, player: int) -> bool:
	if str(state.get("phase", "")) != "fight" or int(state.get("active", -1)) == player: return false
	for model: int in state.get("units", {}):
		var unit: Dictionary = state.units[model]
		if str(unit.get("definition_id", "")).get_slice(":", 3) != "ravenwing-dark-talon": continue
		var squad := int(unit.get("squad", -1))
		if int(unit.get("owner", -1)) != player or not unit.get("on_battlefield", true) or int(unit.get("wounds", 0)) <= 0: continue
		if state.get("unit_abilities", {}).get("used", {}).has(_use_key(state, squad)): continue
		for target: int in state.get("squads", {}):
			if can_target(state, model, target): return true
	return false

static func choices(state: Dictionary, player: int) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if not available(state, player): return result
	for model: int in state.get("units", {}):
		var unit: Dictionary = state.units[model]
		var squad := int(unit.get("squad", -1))
		if int(unit.get("owner", -1)) != player or not unit.get("on_battlefield", true) or int(unit.get("wounds", 0)) <= 0: continue
		if str(unit.get("definition_id", "")).get_slice(":", 3) != "ravenwing-dark-talon" or state.get("unit_abilities", {}).get("used", {}).has(_use_key(state, squad)): continue
		for target: int in state.get("squads", {}):
			if can_target(state, model, target):
				result.append({"label": "Stasis Bomb: slow %s with Ravenwing Dark Talon %d" % [str(state.squads[target].get("name", "enemy unit")), model], "action": "stasis-bomb", "model": model, "target": target, "value": ""})
	return result

static func resume_choices(state: Dictionary, player: int) -> Array[Dictionary]:
	var window: Dictionary = state.get("unit_abilities", {}).get("window", {})
	if window.get("kind", "") != RESUME_WINDOW or window.get("owners", []) != [player]: return []
	var record: Dictionary = state.get("last_stasis_bomb", {})
	if record.is_empty() or str(record.get("stage", "")) != "complete" or int(record.get("owner", -1)) != player: return []
	return [{"label": "Continue movement after Stasis Bomb", "action": "stasis-movement-resume", "model": -1, "target": int(record.get("target", -1)), "value": ""}]

static func apply(state: Dictionary, player: int, selected: Dictionary) -> Dictionary:
	if selected not in choices(state, player): return {"error": "Stasis Bomb requires a visible enemy within 24 inches, excluding AIRCRAFT and Lone Operative units."}
	var source: Dictionary = state.units[selected.model]
	var target_owner := int(state.squads[selected.target].get("owner", -1))
	var squad := int(source.get("squad", -1))
	var marks: Dictionary = state.unit_abilities.get("stasis_bomb_marks", {})
	marks[int(selected.target)] = {"owner": target_owner, "source_squad": squad, "source_model": int(selected.model), "expires_turn": int(state.turn) + 2}
	state.unit_abilities.stasis_bomb_marks = marks
	state.unit_abilities.used[_use_key(state, squad)] = true
	return {"error": "", "message": "Stasis Bomb slowed %s until the end of its next Movement phase." % str(state.squads[int(selected.target)].get("name", "the target unit"))}

static func should_resolve_movement(state: Dictionary, player: int, squad: int, move_type: String) -> bool:
	if move_type == "stationary" or str(state.get("phase", "")) != "movement" or int(state.get("active", -1)) != player: return false
	if not state.get("unit_abilities", {}).get("stasis_bomb_marks", {}).has(squad): return false
	return not state.get("unit_abilities", {}).get("used", {}).has(_movement_key(state, squad))

static func resolve_movement(state: Dictionary, player: int, squad: int, model: int, move_type: String, roller: Callable, continuation: Dictionary) -> Dictionary:
	if not should_resolve_movement(state, player, squad, move_type): return {"error": "", "pending": false}
	if not roller.is_valid(): return {"error": "Stasis Bomb requires the host's D6 provider.", "pending": false}
	var die := _d6(roller)
	if die < 1: return {"error": "Stasis Bomb requires dice from 1 to 6.", "pending": false}
	var penalty := 2 if die <= 4 else 3
	var wounds := 0
	var rolls: Array[int] = [die]
	var damage_dice := 1 if die <= 4 else 2
	for _index in range(damage_dice):
		var damage_die := _d6(roller)
		if damage_die < 1: return {"error": "Stasis Bomb requires dice from 1 to 6.", "pending": false}
		rolls.append(damage_die)
		wounds += int(ceil(float(damage_die) / 2.0))
	var source_squad := int(state.unit_abilities.stasis_bomb_marks.get(squad, {}).get("source_squad", -1))
	return {"error": "", "pending": true, "record": {"source_squad": source_squad, "target": squad, "owner": player, "rolls": rolls, "penalty": penalty, "remaining": wounds, "allocations": [], "discarded": 0, "stage": "pending", "continuation": continuation.duplicate(true)}}

static func open_mortal_window(state: Dictionary, record: Dictionary) -> void:
	var squad := int(record.get("target", -1))
	var penalties: Dictionary = state.unit_abilities.get("stasis_bomb_penalties", {})
	penalties[squad] = {"turn": int(state.get("turn", -1)), "penalty": int(record.get("penalty", 0))}
	state.unit_abilities.stasis_bomb_penalties = penalties
	state.unit_abilities.used[_movement_key(state, squad)] = true
	record.stage = "allocating"
	record.resume_window = {"kind": RESUME_WINDOW, "owners": [int(record.get("owner", -1))]}
	state.last_stasis_bomb = record.duplicate(true)
	state.unit_abilities.window = {"kind": MORTAL_WINDOW, "owners": [int(record.get("owner", -1))], "target": squad, "resume_window": record.resume_window.duplicate(true)}

static func movement_penalty(state: Dictionary, squad: int) -> int:
	if str(state.get("phase", "")) != "movement" or not state.get("unit_abilities", {}).get("stasis_bomb_marks", {}).has(squad): return 0
	var mark: Dictionary = state.unit_abilities.stasis_bomb_marks[squad]
	if int(mark.get("owner", -1)) != int(state.get("active", -2)) or int(mark.get("expires_turn", -1)) != int(state.get("turn", -2)): return 0
	var penalty: Dictionary = state.unit_abilities.get("stasis_bomb_penalties", {}).get(squad, {})
	return int(penalty.get("penalty", 0)) if int(penalty.get("turn", -2)) == int(state.get("turn", -1)) else 0

static func continuation(state: Dictionary, player: int, selected: Dictionary) -> Dictionary:
	var window: Dictionary = state.get("unit_abilities", {}).get("window", {})
	if window.get("kind", "") != RESUME_WINDOW or window.get("owners", []) != [player] or selected.get("action", "") != "stasis-movement-resume": return {"error": "Stasis Bomb has no matching movement continuation."}
	var record: Dictionary = state.get("last_stasis_bomb", {})
	if record.is_empty() or str(record.get("stage", "")) != "complete" or int(record.get("owner", -1)) != player: return {"error": "The saved Stasis Bomb movement is missing."}
	state.unit_abilities.window = {}
	return {"error": "", "resume_stasis_movement": record.get("continuation", {}).duplicate(true)}

static func end_movement_phase(state: Dictionary) -> void:
	if str(state.get("phase", "")) != "movement": return
	var marks: Dictionary = state.get("unit_abilities", {}).get("stasis_bomb_marks", {})
	var penalties: Dictionary = state.get("unit_abilities", {}).get("stasis_bomb_penalties", {})
	for squad: Variant in marks.keys():
		var mark: Dictionary = marks[squad]
		if int(mark.get("owner", -1)) == int(state.get("active", -2)) and int(mark.get("expires_turn", -1)) <= int(state.get("turn", -1)):
			marks.erase(squad)
			penalties.erase(squad)
	state.unit_abilities.stasis_bomb_marks = marks
	state.unit_abilities.stasis_bomb_penalties = penalties

static func _end_window_allows(state: Dictionary, player: int) -> bool:
	var window: Dictionary = state.get("unit_abilities", {}).get("window", {})
	return str(state.get("phase", "")) == "fight" and int(state.get("active", -1)) != player and str(window.get("kind", "")) == "end" and player in window.get("owners", [])

static func _has_keyword(state: Dictionary, squad: int, keyword: String) -> bool:
	for model: int in state.get("units", {}):
		var unit: Dictionary = state.units[model]
		if int(unit.get("squad", -1)) == squad and int(unit.get("wounds", 0)) > 0 and AircraftRules.has_keyword(unit, keyword): return true
	return false

static func _use_key(state: Dictionary, squad: int) -> String:
	return "stasis-bomb:%d:%d" % [int(state.get("turn", -1)), squad]

static func _movement_key(state: Dictionary, squad: int) -> String:
	return "stasis-bomb-movement:%d:%d" % [int(state.get("turn", -1)), squad]

static func _d6(roller: Callable) -> int:
	var value: Variant = roller.call()
	return int(value) if value is int and int(value) >= 1 and int(value) <= 6 else -1
