extends RefCounted
## High Marshal Helbrecht's Fight-phase mortal-wound ability.
const A = preload("res://scripts/edition_11/unit_abilities.gd")
const G = preload("res://scripts/edition_11/contact_movement.gd")
const RandomStat = preload("res://scripts/edition_11/random_characteristic.gd")
const Mortal = preload("res://scripts/edition_11/core_reactions.gd")
const MORTAL_WINDOW := Mortal.HIGH_MARSHAL_MORTAL
const ID := "high-marshal-helbrecht-2026-10-28-v1"

static func _phase_key(state: Dictionary) -> String:
	return "%d:%s" % [int(state.get("turn", 0)), str(state.get("phase", ""))]

static func _engaged_targets(state: Dictionary, source_squad: int, owner: int) -> Array[int]:
	var result: Array[int] = []
	if not state.get("squads", {}).has(source_squad): return result
	for target: int in state.squads:
		if int(state.squads[target].get("owner", -1)) == owner or G.alive(state, target).is_empty(): continue
		var engaged := false
		for source_model: int in G.alive(state, source_squad):
			if int(state.units[source_model].get("owner", -1)) != owner: continue
			for enemy_model: int in G.alive(state, target):
				if G.within_engagement(state.units[source_model], state.units[enemy_model]):
					engaged = true
					break
			if engaged: break
		if engaged: result.append(target)
	return result

static func _eligible_bearers(state: Dictionary, owner: int) -> Array[int]:
	var result: Array[int] = []
	if not A.enabled(state) or str(state.get("phase", "")) != "fight": return result
	var used: Dictionary = state.get("unit_abilities", {}).get("used", {})
	var phase_key := _phase_key(state)
	for model: int in state.get("units", {}):
		var bearer: Dictionary = state.units[model]
		if int(bearer.get("owner", -1)) != owner or int(bearer.get("wounds", 0)) <= 0 or not bearer.get("on_battlefield", true): continue
		if A.identity(bearer) != "high-marshal-helbrecht": continue
		var squad := int(bearer.get("squad", -1))
		if not state.squads.has(squad) or not A.has(state, squad, "high-marshal"): continue
		if used.get("high-marshal:%d" % model, "") == phase_key: continue
		if not _engaged_targets(state, squad, owner).is_empty(): result.append(model)
	return result

static func start_available(state: Dictionary, owner: int) -> bool:
	return not _eligible_bearers(state, owner).is_empty()

static func choices(state: Dictionary, player: int) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var window: Dictionary = state.get("unit_abilities", {}).get("window", {})
	var owners: Array = window.get("owners", [])
	if window.get("kind", "") != "start" or owners.is_empty() or int(owners[0]) != player: return result
	for model: int in _eligible_bearers(state, player):
		var squad := int(state.units[model].squad)
		for target: int in _engaged_targets(state, squad, player):
			result.append({"label": "High Marshal %d: resolve against %s" % [model, str(state.squads[target].get("name", "enemy unit"))], "action": "high-marshal", "model": model, "target": target, "value": ""})
	return result

static func apply(state: Dictionary, player: int, selected: Dictionary, roller: Callable) -> Dictionary:
	if selected not in choices(state, player): return {"error": "High Marshal is available only at the start of the Fight phase against an enemy unit engaged with Helbrecht's unit."}
	var model := int(selected.get("model", -1))
	var target := int(selected.get("target", -1))
	var squad := int(state.units[model].squad)
	var roll := RandomStat.roll("D6", roller)
	if not str(roll.get("error", "")).is_empty(): return roll
	var wounds := 0
	var damage_roll: Dictionary = {}
	if int(roll.value) in [2, 3]:
		damage_roll = RandomStat.roll("D3", roller)
		if not str(damage_roll.get("error", "")).is_empty(): return damage_roll
		wounds = int(damage_roll.value)
	elif int(roll.value) in [4, 5]:
		wounds = 3
	elif int(roll.value) == 6:
		damage_roll = RandomStat.roll("D3+3", roller)
		if not str(damage_roll.get("error", "")).is_empty(): return damage_roll
		wounds = int(damage_roll.value)
	var phase_key := _phase_key(state)
	var use_key := "high-marshal:%d" % model
	state.unit_abilities.used[use_key] = phase_key
	var record := {"implementation": ID, "owner": int(state.squads[target].owner), "source": model, "squad": squad, "target": target, "phase_key": phase_key, "roll": roll, "damage_roll": damage_roll, "remaining": wounds, "total": wounds, "allocations": [], "discarded": 0, "stage": "allocating" if wounds > 0 else "complete"}
	state.last_high_marshal = record
	if wounds > 0:
		var resume_window: Dictionary = state.unit_abilities.window.duplicate(true)
		state.unit_abilities.window = {"kind": MORTAL_WINDOW, "owners": [int(state.squads[target].owner)], "target": target, "resume_window": resume_window}
	return {"error": "", "message": "High Marshal: D6 %d; %d mortal wound(s) assigned to %s." % [int(roll.value), wounds, str(state.squads[target].get("name", "the enemy unit"))]}
