extends RefCounted
## Hexmark Destroyer Multi-threat Eliminator from the local Necrons App v1.2 export.
const AttackPlan = preload("res://scripts/edition_11/attack_plan.gd")
const Equipment = preload("res://scripts/edition_11/equipment.gd")
const Geometry = preload("res://scripts/edition_11/contact_movement.gd")
const UnitAbilities = preload("res://scripts/edition_11/unit_abilities.gd")

const KIND := "multi-threat-eliminator"
const DEFINITION := "40kdc:11e:necrons:hexmark-destroyer"
const RANGE := 3.0
const EPSILON := 0.001

static func offer(state: Dictionary, attacker: int, targets: Array) -> bool:
	if not UnitAbilities.enabled(state) or str(state.get("phase", "")) != "shooting": return false
	if not state.get("squads", {}).has(attacker) or Geometry.alive(state, attacker).is_empty(): return false
	if int(state.squads[attacker].get("owner", -1)) != int(state.get("active", -2)): return false
	var current: Dictionary = state.unit_abilities.get("window", {})
	if not current.is_empty(): return false
	var reactor := 3 - int(state.squads[attacker].owner)
	var pending := _eligible_squads(state, attacker, targets, reactor)
	if pending.is_empty(): return false
	state.unit_abilities.window = {
		"kind": KIND,
		"owners": [reactor],
		"attacker": attacker,
		"pending": pending,
		"active_squad": -1
	}
	return true

static func choices(state: Dictionary, player: int) -> Array:
	var window := _window(state)
	if window.is_empty() or int(window.owners[0]) != player: return []
	var attacker := int(window.get("attacker", -1))
	var attacker_name := str(state.squads.get(attacker, {}).get("name", "the enemy unit"))
	var active := int(window.get("active_squad", -1))
	var result: Array = []
	if active >= 0:
		result.append(_choice("Decline Multi-threat Eliminator against %s" % attacker_name, active, "pass"))
		return result
	for squad_value: Variant in window.get("pending", []):
		var squad := int(squad_value)
		var squad_name := str(state.squads.get(squad, {}).get("name", "Hexmark Destroyer"))
		result.append(_choice("Multi-threat Eliminator: %s shoots at %s" % [squad_name, attacker_name], squad, "shoot"))
		result.append(_choice("Multi-threat Eliminator: %s declines" % squad_name, squad, "pass"))
	return result

static func apply(state: Dictionary, player: int, selected: Dictionary) -> Dictionary:
	var window := _window(state)
	if window.is_empty() or int(window.owners[0]) != player: return {"error": "Multi-threat Eliminator is not waiting for this player."}
	var squad := int(selected.get("target", -1))
	if squad not in window.get("pending", []): return {"error": "Choose one Hexmark Destroyer that can answer this shot."}
	var value := str(selected.get("value", ""))
	if value == "shoot":
		if int(window.get("active_squad", -1)) >= 0: return {"error": "Resolve or decline the selected Multi-threat Eliminator shot first."}
		window.active_squad = squad
		state.unit_abilities.window = window
		return {"error": "", "message": "Multi-threat Eliminator: shoot only at the enemy unit that just shot."}
	if value == "pass": return consume(state, squad, false)
	return {"error": "Choose whether this Hexmark Destroyer shoots at the attacking unit."}

static func active_shooter(state: Dictionary, squad: int) -> bool:
	var window := _window(state)
	return not window.is_empty() and int(window.get("active_squad", -1)) == squad

static func consume(state: Dictionary, squad: int, spent_shot: bool) -> Dictionary:
	var window := _window(state)
	if window.is_empty(): return {}
	if spent_shot:
		if not state.unit_abilities.has("used"): state.unit_abilities.used = {}
		state.unit_abilities.used["%s:%d" % [KIND, squad]] = int(state.get("turn", 0))
	var pending: Array = window.get("pending", []).duplicate()
	pending.erase(squad)
	window.pending = pending
	window.active_squad = -1
	if pending.is_empty(): state.unit_abilities.window = {}
	else: state.unit_abilities.window = window
	return {}

static func _eligible_squads(state: Dictionary, attacker: int, targets: Array, reactor: int) -> Array[int]:
	var result: Array[int] = []
	for target_value: Variant in targets:
		var target := int(target_value)
		if target in result or not _necron_unit(state, target, reactor): continue
		for squad: int in state.get("squads", {}):
			if squad in result or int(state.squads[squad].get("owner", -1)) != reactor: continue
			if not UnitAbilities.has(state, squad, KIND): continue
			if int(state.unit_abilities.get("used", {}).get("%s:%d" % [KIND, squad], -1)) == int(state.get("turn", 0)): continue
			if not _within(state, squad, target): continue
			if not _eligible_target(state, squad, attacker): continue
			result.append(squad)
	result.sort()
	return result

static func _necron_unit(state: Dictionary, squad: int, owner: int) -> bool:
	if not state.get("squads", {}).has(squad) or int(state.squads[squad].get("owner", -1)) != owner: return false
	var found := false
	for model: int in Geometry.alive(state, squad):
		var keywords: Array = state.units[model].get("keywords", [])
		var matched := false
		for keyword: Variant in keywords:
			if str(keyword).strip_edges().to_upper() == "NECRONS": matched = true
		if not matched: return false
		found = true
	return found

static func _within(state: Dictionary, squad: int, target: int) -> bool:
	for model: int in Geometry.alive(state, squad):
		if str(state.units[model].get("definition_id", "")) != DEFINITION: continue
		for other: int in Geometry.alive(state, target):
			if Geometry.edge(state.units[model], state.units[other]) <= RANGE + EPSILON: return true
	return false

static func _eligible_target(state: Dictionary, squad: int, target: int) -> bool:
	for model: int in Geometry.alive(state, squad):
		if str(state.units[model].get("definition_id", "")) != DEFINITION: continue
		for weapon: Dictionary in Equipment.inventory(state, model, false):
			for profile_id: String in weapon.get("profiles", {}):
				if target in AttackPlan.legal_targets(state, model, false, str(weapon.get("id", "")), profile_id): return true
	return false

static func _window(state: Dictionary) -> Dictionary:
	var window: Dictionary = state.get("unit_abilities", {}).get("window", {})
	if str(window.get("kind", "")) != KIND: return {}
	var owners: Array = window.get("owners", [])
	if owners.is_empty() or int(owners[0]) not in [1, 2]: return {}
	return window

static func _choice(label: String, squad: int, value: String) -> Dictionary:
	return {"label": label, "action": KIND, "model": -1, "target": squad, "value": value}
