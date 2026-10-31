extends RefCounted
## Canoptek Scarab Swarms datasheet 000002114. Local App v1.2 wording.
const A = preload("res://scripts/edition_11/unit_abilities.gd")
const G = preload("res://scripts/edition_11/contact_movement.gd")
const RandomStat = preload("res://scripts/edition_11/random_characteristic.gd")
const ACTION := "scarab-self-destruction"
const MORTAL_WINDOW := "necron-scarab-self-destruction-mortal"
const RANGE := 6.0
const EPSILON := 0.001

static func _phase_key(state: Dictionary) -> String:
	return "%d:%s" % [int(state.get("turn", 0)), str(state.get("phase", ""))]

static func _edge(left: Dictionary, right: Dictionary) -> float:
	return maxf(0.0, left.get("position", Vector2.ZERO).distance_to(right.get("position", Vector2.ZERO)) - float(left.get("radius", 0.0)) - float(right.get("radius", 0.0)))

static func _keyword(unit: Dictionary, word: String) -> bool:
	for item: Variant in unit.get("keywords", []):
		if str(item).strip_edges().to_upper() == word: return true
	return false

static func _squad_has_keyword(state: Dictionary, squad: int, word: String) -> bool:
	for model: int in G.alive(state, squad):
		if _keyword(state.units[model], word): return true
	return false

static func _engaged_targets_for_model(state: Dictionary, model: int) -> Array[int]:
	var result: Array[int] = []
	if not state.get("units", {}).has(model): return result
	var source: Dictionary = state.units[model]
	var owner := int(source.get("owner", -1))
	for target: int in state.get("squads", {}):
		if int(state.squads[target].get("owner", -1)) == owner: continue
		for enemy: int in G.alive(state, target):
			if G.within_engagement(source, state.units[enemy]):
				result.append(target)
				break
	return result

static func _eligible_models(state: Dictionary, owner: int) -> Array[int]:
	var result: Array[int] = []
	if not A.enabled(state) or str(state.get("phase", "")) != "fight": return result
	var used: Dictionary = state.get("unit_abilities", {}).get("used", {})
	var phase_key := _phase_key(state)
	for model: int in state.get("units", {}):
		var unit: Dictionary = state.units[model]
		if int(unit.get("owner", -1)) != owner or int(unit.get("wounds", 0)) <= 0 or not unit.get("on_battlefield", true): continue
		if A.identity(unit) != "canoptek-scarab-swarms": continue
		var squad := int(unit.get("squad", -1))
		if not state.squads.has(squad) or not A.has(state, squad, "self-destruction"): continue
		if str(used.get("self-destruction:%d" % squad, "")) == phase_key: continue
		if not _engaged_targets_for_model(state, model).is_empty(): result.append(model)
	return result

static func start_available(state: Dictionary, owner: int) -> bool:
	return not _eligible_models(state, owner).is_empty()

static func choices(state: Dictionary, player: int) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var window: Dictionary = state.get("unit_abilities", {}).get("window", {})
	var owners: Array = window.get("owners", [])
	if window.get("kind", "") != "start" or owners.is_empty() or int(owners[0]) != player: return result
	for model: int in _eligible_models(state, player):
		for target: int in _engaged_targets_for_model(state, model):
			result.append({"label": "Self-destruction: destroy Scarab %d against %s" % [model, str(state.squads[target].get("name", "enemy unit"))], "action": ACTION, "model": model, "target": target, "value": ""})
	return result

static func apply(state: Dictionary, player: int, selected: Dictionary, roller: Callable) -> Dictionary:
	if selected not in choices(state, player): return {"error": "Self-destruction is available at the start of the Fight phase for one engaged Scarab Swarm model."}
	var model := int(selected.get("model", -1))
	var target := int(selected.get("target", -1))
	var squad := int(state.units[model].squad)
	var vehicle := _squad_has_keyword(state, target, "VEHICLE")
	var roll := RandomStat.roll("D6", roller)
	if not str(roll.get("error", "")).is_empty(): return roll
	var modified := int(roll.value) + (1 if vehicle else 0)
	var wounds := 0
	var damage_roll: Dictionary = {}
	if modified >= 6:
		wounds = 3
	elif modified >= 2:
		damage_roll = RandomStat.roll("D3", roller)
		if not str(damage_roll.get("error", "")).is_empty(): return damage_roll
		wounds = int(damage_roll.value)
	state.units[model].wounds = 0
	var phase_key := _phase_key(state)
	state.unit_abilities.used["self-destruction:%d" % squad] = phase_key
	var record := {"implementation": "canoptek-scarab-swarms-2026-10-31-v1", "owner": int(state.squads[target].owner), "source": model, "squad": squad, "target": target, "phase_key": phase_key, "roll": roll, "modified": modified, "vehicle": vehicle, "damage_roll": damage_roll, "remaining": wounds, "total": wounds, "allocations": [], "discarded": 0, "stage": "allocating" if wounds > 0 else "complete"}
	state.last_scarab_self_destruction = record
	if wounds > 0:
		var resume_window: Dictionary = state.unit_abilities.window.duplicate(true)
		state.unit_abilities.window = {"kind": MORTAL_WINDOW, "owners": [int(state.squads[target].owner)], "target": target, "resume_window": resume_window}
	return {"error": "", "message": "Self-destruction: Scarab %d is destroyed. D6 %d%s; %d mortal wound(s) assigned to %s." % [model, int(roll.value), " (+1 Vehicle)" if vehicle else "", wounds, str(state.squads[target].get("name", "the enemy unit"))]}

static func cryptek_sets_unit_oc(state: Dictionary, squad: int) -> bool:
	if not A.enabled(state) or not state.get("squads", {}).has(squad) or not A.has(state, squad, "chittering-swarm"): return false
	var owner := int(state.squads[squad].get("owner", -1))
	var scarabs: Array[int] = []
	for model: int in G.alive(state, squad):
		if state.units[model].get("on_battlefield", true): scarabs.append(model)
	if scarabs.is_empty(): return false
	for other: int in state.get("units", {}):
		var cryptek: Dictionary = state.units[other]
		if int(cryptek.get("owner", -1)) != owner or int(cryptek.get("wounds", 0)) <= 0 or not cryptek.get("on_battlefield", true): continue
		if int(cryptek.get("squad", -1)) == squad or not _keyword(cryptek, "CRYPTEK"): continue
		for scarab: int in scarabs:
			if _edge(state.units[scarab], cryptek) <= RANGE + EPSILON: return true
	return false

static func chittering_penalty(state: Dictionary, model: int) -> int:
	if not A.enabled(state) or not state.get("units", {}).has(model): return 0
	var unit: Dictionary = state.units[model]
	var squad := int(unit.get("squad", -1))
	var owner := int(unit.get("owner", -1))
	var sources: Dictionary = {}
	for other: int in state.get("units", {}):
		var scarab: Dictionary = state.units[other]
		if int(scarab.get("wounds", 0)) <= 0 or not scarab.get("on_battlefield", true) or int(scarab.get("owner", -1)) == owner: continue
		var source := int(scarab.get("squad", -1))
		if source == squad or sources.has(source) or not A.has(state, source, "chittering-swarm"): continue
		if A.identity(scarab) != "canoptek-scarab-swarms": continue
		for friendly: int in G.alive(state, squad):
			if not state.units[friendly].get("on_battlefield", true): continue
			if G.within_engagement(scarab, state.units[friendly]):
				sources[source] = true
				break
	return sources.size()
