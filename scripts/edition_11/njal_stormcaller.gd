extends RefCounted
## Source-bounded psychic abilities and attack reaction for Njal Stormcaller.
const A = preload("res://scripts/edition_11/unit_abilities.gd")
const G = preload("res://scripts/edition_11/contact_movement.gd")
const Terrain = preload("res://scripts/edition_11/terrain.gd")
const RandomStat = preload("res://scripts/edition_11/random_characteristic.gd")
const Actions = preload("res://scripts/edition_11/actions.gd")

const STORM_CALLER_WINDOW := "njal-storm-caller"

static func phase_key(state: Dictionary) -> String:
	return "%d:%s" % [int(state.get("turn", 0)), str(state.get("phase", ""))]

static func _models(state: Dictionary, squad: int) -> Array[int]:
	var result: Array[int] = []
	for model: int in G.alive(state, squad):
		var unit: Dictionary = state.units.get(model, {})
		if A.identity(unit) == "njal-stormcaller" and bool(unit.get("on_battlefield", true)): result.append(model)
	return result

static func _usage(state: Dictionary, squad: int) -> Dictionary:
	var record: Dictionary = state.get("unit_abilities", {}).get("njal_psychic_uses", {}).get(squad, {})
	return record if int(record.get("turn", -1)) == int(state.get("turn", -2)) else {"turn": int(state.get("turn", -1)), "count": 0}

static func _has_capacity(state: Dictionary, squad: int) -> bool:
	return int(_usage(state, squad).get("count", 0)) < 3

static func _power_used(state: Dictionary, squad: int, power: String) -> bool:
	return bool(state.get("unit_abilities", {}).get("used", {}).get("njal:%d:%d:%s" % [squad, int(state.get("turn", -1)), power], false))

static func _source_valid(state: Dictionary, player: int, model: int, squad: int) -> bool:
	if not state.get("units", {}).has(model) or not state.get("squads", {}).has(squad): return false
	var unit: Dictionary = state.units[model]
	return int(unit.get("owner", -1)) == player and int(unit.get("squad", -1)) == squad and A.identity(unit) == "njal-stormcaller" and int(unit.get("wounds", 0)) > 0 and bool(unit.get("on_battlefield", true))

static func _visible_targets(state: Dictionary, player: int, model: int, maximum_range: float) -> Array[int]:
	var result: Array[int] = []
	for enemy: int in state.get("squads", {}):
		if int(state.squads[enemy].get("owner", -1)) == player or G.alive(state, enemy).is_empty(): continue
		var sight := Terrain.targeting(state, model, enemy)
		if sight.visible and float(sight.distance) <= maximum_range + 0.001: result.append(enemy)
	return result

static func psychic_choices(state: Dictionary, player: int) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if not A.enabled(state) or int(state.get("active", -1)) != player or str(state.get("phase", "")) not in ["movement", "shooting"]: return result
	for squad: int in state.get("squads", {}):
		if int(state.squads[squad].get("owner", -1)) != player or state.squads[squad].get("battle_shocked", false) or not _has_capacity(state, squad): continue
		var sources := _models(state, squad)
		if sources.is_empty(): continue
		var model := sources[0]
		if state.phase == "movement" and A.has(state, squad, "murderous-hurricane") and not _power_used(state, squad, "murderous-hurricane"):
			for enemy: int in _visible_targets(state, player, model, 12.0):
				result.append({"label": "Murderous Hurricane: disable Snap Shooting for %s" % state.squads[enemy].name, "action": "njal-psychic", "model": model, "target": enemy, "value": "murderous-hurricane"})
		if state.phase == "shooting" and _has_capacity(state, squad) and A.has(state, squad, "tempests-wrath") and not _power_used(state, squad, "tempests-wrath"):
			for enemy: int in _visible_targets(state, player, model, 18.0):
				result.append({"label": "Tempest's Wrath: suppress %s (-1 to hit)" % state.squads[enemy].name, "action": "njal-psychic", "model": model, "target": enemy, "value": "tempests-wrath"})
	return result

static func _consume_use(state: Dictionary, squad: int, power: String, once_per_turn: bool) -> void:
	var abilities: Dictionary = state.unit_abilities
	if not abilities.has("njal_psychic_uses"): abilities.njal_psychic_uses = {}
	var record := _usage(state, squad)
	record.count = int(record.get("count", 0)) + 1
	abilities.njal_psychic_uses[squad] = record
	if once_per_turn:
		if not abilities.has("used"): abilities.used = {}
		abilities.used["njal:%d:%d:%s" % [squad, int(state.turn), power]] = true

static func _psychic_roll(state: Dictionary, squad: int, power: String, roller: Callable) -> Dictionary:
	var result := RandomStat.roll("D6", roller)
	if not str(result.get("error", "")).is_empty(): return result
	_consume_use(state, squad, power, power != "storm-caller")
	if not state.unit_abilities.has("njal_psychic_results"): state.unit_abilities.njal_psychic_results = []
	state.unit_abilities.njal_psychic_results.append({"squad": squad, "power": power, "turn": state.turn, "phase": state.phase, "roll": int(result.value), "battle_shocked": int(result.value) == 1})
	if int(result.value) == 1:
		state.squads[squad].battle_shocked = true
		Actions.interrupt(state, squad, "Njal's psychic roll caused Battle-shock")
	return result

static func resolve_psychic(state: Dictionary, player: int, selected: Dictionary, roller: Callable) -> Dictionary:
	var model := int(selected.get("model", -1))
	var target := int(selected.get("target", -1))
	var power := str(selected.get("value", ""))
	if not state.get("units", {}).has(model): return {"error": "Select Njal Stormcaller for this psychic ability."}
	var squad := int(state.units[model].get("squad", -1))
	if not A.enabled(state) or int(state.get("active", -1)) != player or not _source_valid(state, player, model, squad) or state.squads[squad].get("battle_shocked", false) or not _has_capacity(state, squad): return {"error": "Njal cannot use another psychic ability now."}
	if power not in ["murderous-hurricane", "tempests-wrath"] or not A.has(state, squad, power) or _power_used(state, squad, power): return {"error": "This Njal psychic ability is unavailable this turn."}
	var required_phase := "movement" if power == "murderous-hurricane" else "shooting"
	var maximum_range := 12.0 if power == "murderous-hurricane" else 18.0
	if str(state.get("phase", "")) != required_phase: return {"error": "This Njal psychic ability is used in its source-listed phase."}
	if target not in _visible_targets(state, player, model, maximum_range): return {"error": "Choose a visible enemy unit within the ability's range."}
	var roll := _psychic_roll(state, squad, power, roller)
	if not str(roll.get("error", "")).is_empty(): return roll
	if power == "murderous-hurricane":
		if not state.unit_abilities.has("snap_shooting_block_targets"): state.unit_abilities.snap_shooting_block_targets = {}
		state.unit_abilities.snap_shooting_block_targets[target] = {"owner": player, "source_squad": squad, "ability": power}
	else:
		if not state.unit_abilities.has("tempests_wrath_targets"): state.unit_abilities.tempests_wrath_targets = {}
		state.unit_abilities.tempests_wrath_targets[target] = {"owner": player, "source_squad": squad, "expires_turn": int(state.turn) + 2}
	return {"error": "", "message": "%s resolves against %s (D6: %d)." % ["Murderous Hurricane" if power == "murderous-hurricane" else "Tempest's Wrath", state.squads[target].name, int(roll.value)]}

static func storm_caller_available(state: Dictionary, squad: int) -> bool:
	return A.enabled(state) and state.get("squads", {}).has(squad) and not state.squads[squad].get("battle_shocked", false) and not _models(state, squad).is_empty() and A.has(state, squad, "storm-caller") and _has_capacity(state, squad)

static func offer(state: Dictionary, declaration: Dictionary, targets: Array) -> bool:
	var queue: Array[int] = []
	var ordered := targets.duplicate()
	ordered.sort()
	for target_variant: Variant in ordered:
		if not target_variant is int: continue
		var target := int(target_variant)
		if state.get("squads", {}).has(target) and int(state.squads[target].get("owner", -1)) != int(declaration.get("player", -1)) and storm_caller_available(state, target): queue.append(target)
	if queue.is_empty(): return false
	state.unit_abilities.window = {"kind": STORM_CALLER_WINDOW, "owners": [int(state.squads[queue[0]].owner)], "remaining": queue, "declaration": declaration.duplicate(true)}
	return true

static func choices(state: Dictionary, player: int) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var window: Dictionary = state.get("unit_abilities", {}).get("window", {})
	if window.get("kind", "") != STORM_CALLER_WINDOW or window.get("owners", [-1])[0] != player or window.get("remaining", []).is_empty(): return result
	var squad := int(window.remaining[0])
	if storm_caller_available(state, squad):
		for model: int in _models(state, squad):
			result.append({"label": "Njal Stormcaller %d: Storm Caller (psychic roll; -3 detection this phase)" % model, "action": STORM_CALLER_WINDOW, "model": model, "target": squad, "value": "use"})
	result.append({"label": "Decline Storm Caller for %s" % state.squads[squad].name, "action": STORM_CALLER_WINDOW, "model": -1, "target": squad, "value": "pass"})
	return result

static func choose_storm_caller(state: Dictionary, player: int, selected: Dictionary, roller: Callable) -> Dictionary:
	var window: Dictionary = state.get("unit_abilities", {}).get("window", {})
	if window.get("kind", "") != STORM_CALLER_WINDOW or window.get("owners", [-1])[0] != player or window.get("remaining", []).is_empty(): return {"error": "There is no matching Storm Caller trigger."}
	var squad := int(window.remaining[0])
	if int(selected.get("target", -1)) != squad or str(selected.get("value", "")) not in ["use", "pass"]: return {"error": "Choose the current Storm Caller trigger."}
	if selected.value == "use":
		var model := int(selected.get("model", -1))
		if not storm_caller_available(state, squad) or not _source_valid(state, player, model, squad): return {"error": "Storm Caller is unavailable for this unit."}
		var roll := _psychic_roll(state, squad, "storm-caller", roller)
		if not str(roll.get("error", "")).is_empty(): return roll
		if not state.unit_abilities.has("njal_storm_caller_detection"): state.unit_abilities.njal_storm_caller_detection = {}
		state.unit_abilities.njal_storm_caller_detection[squad] = {"owner": player, "phase_key": phase_key(state), "source": model}
	window.remaining.pop_front()
	if not window.remaining.is_empty():
		window.owners = [int(state.squads[window.remaining[0]].owner)]
		return {"error": ""}
	var declaration: Dictionary = window.get("declaration", {}).duplicate(true)
	state.unit_abilities.window = {}
	return {"error": "", "resume_declaration": declaration}
