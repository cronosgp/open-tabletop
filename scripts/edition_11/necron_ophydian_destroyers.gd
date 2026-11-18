extends RefCounted
## Ophydian Destroyers: Plasmacyte tokens and Tunnelling Horrors (App v1.2 local export 000002358).
## Plasmacyte token spend is shared with Skorpekh Destroyers (000002110).
const UnitAbilities = preload("res://scripts/edition_11/unit_abilities.gd")
const Geometry = preload("res://scripts/edition_11/contact_movement.gd")
const FightQueue = preload("res://scripts/edition_11/fight_queue.gd")

const IDENTITY := "ophydian-destroyers"
const PLASMACYTE := "plasmacyte"
const TUNNELLING := "tunnelling-horrors"

static func max_plasmacytes(models: int) -> int:
	return maxi(0, int(models) / 3)

static func ensure_tokens(state: Dictionary, squad: int) -> void:
	if not state.get("squads", {}).has(squad) or not UnitAbilities.has(state, squad, PLASMACYTE): return
	var record: Dictionary = state.squads[squad]
	if record.has("plasmacyte_tokens"): return
	var living := Geometry.alive(state, squad).size()
	var starting := int(record.get("starting_strength", living))
	record.plasmacyte_tokens = max_plasmacytes(starting)
	record.plasmacyte_starting = int(record.plasmacyte_tokens)

static func tokens_remaining(state: Dictionary, squad: int) -> int:
	ensure_tokens(state, squad)
	return int(state.squads.get(squad, {}).get("plasmacyte_tokens", 0))

static func _plasmacyte_key(state: Dictionary, squad: int) -> String:
	return "plasmacyte:%d:%s" % [squad, _phase_key(state)]

static func plasmacyte_active(state: Dictionary, squad: int) -> bool:
	if not UnitAbilities.has(state, squad, PLASMACYTE): return false
	var used: Dictionary = state.get("unit_abilities", {}).get("used", {})
	# Prefer the shared key; keep reading the older Ophydian-prefixed key for in-flight states.
	return bool(used.get(_plasmacyte_key(state, squad), false)) or bool(used.get("ophydian-plasmacyte:%d:%s" % [squad, _phase_key(state)], false))

static func can_use_plasmacyte(state: Dictionary, player: int, squad: int) -> bool:
	if not UnitAbilities.enabled(state) or not state.get("squads", {}).has(squad): return false
	if int(state.squads[squad].get("owner", -1)) != player: return false
	if not UnitAbilities.has(state, squad, PLASMACYTE): return false
	if state.get("phase", "") != "fight" or int(state.get("fight_actor", -1)) != player: return false
	if str(state.get("fight_step", "")) != "attacks": return false
	if bool(state.squads[squad].get("fought", false)): return false
	if squad not in FightQueue.choices(state, player): return false
	if plasmacyte_active(state, squad): return false
	return tokens_remaining(state, squad) > 0

static func use_plasmacyte(state: Dictionary, player: int, squad: int) -> Dictionary:
	if not can_use_plasmacyte(state, player, squad): return {"error": "Plasmacyte requires a remaining token when this unit is selected to fight."}
	ensure_tokens(state, squad)
	state.squads[squad].plasmacyte_tokens = tokens_remaining(state, squad) - 1
	var used: Dictionary = state.unit_abilities.get("used", {})
	used[_plasmacyte_key(state, squad)] = true
	state.unit_abilities.used = used
	state.fight_selected = squad
	return {}

static func tunnelling_squads(state: Dictionary, owner: int) -> Array[int]:
	var result: Array[int] = []
	if not UnitAbilities.enabled(state) or state.get("phase", "") != "fight" or owner == int(state.get("active", -1)): return result
	for squad: int in state.get("squads", {}):
		if int(state.squads[squad].get("owner", -1)) != owner: continue
		if state.get("unit_abilities", {}).get("reserves", {}).has(squad): continue
		if not UnitAbilities.has(state, squad, TUNNELLING): continue
		var alive := Geometry.alive(state, squad)
		if alive.is_empty() or FightQueue.engaged(state, squad): continue
		var all_on_battlefield := true
		for model: int in alive:
			if not state.units[model].get("on_battlefield", true): all_on_battlefield = false
		if all_on_battlefield: result.append(squad)
	return result

static func early_ingress_allowed(state: Dictionary, squad: int) -> bool:
	var reserve: Dictionary = state.get("unit_abilities", {}).get("reserves", {}).get(squad, {})
	return str(reserve.get("source", "")) == TUNNELLING

static func _phase_key(state: Dictionary) -> String:
	return "%d:%s" % [int(state.get("turn", 0)), str(state.get("phase", ""))]
