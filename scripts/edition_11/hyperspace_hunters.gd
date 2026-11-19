extends RefCounted
## Deathmarks Hyperspace Hunters from the local Necrons App v1.2 export.
const AttackPlan = preload("res://scripts/edition_11/attack_plan.gd")
const Equipment = preload("res://scripts/edition_11/equipment.gd")
const Geometry = preload("res://scripts/edition_11/contact_movement.gd")
const Terrain = preload("res://scripts/edition_11/terrain.gd")
const UnitAbilities = preload("res://scripts/edition_11/unit_abilities.gd")

const KIND := "hyperspace-hunters"
const DEFINITION := "40kdc:11e:necrons:deathmarks"
const RANGE := 18.0
const EPSILON := 0.001

static func offer(state: Dictionary, arrived_squad: int) -> bool:
	if not UnitAbilities.enabled(state) or str(state.get("phase", "")) != "movement": return false
	if not state.get("squads", {}).has(arrived_squad): return false
	var arrived: Dictionary = state.squads[arrived_squad]
	if str(arrived.get("move_type", "")) != "ingress" or int(arrived.get("owner", -1)) != int(state.get("active", -2)): return false
	if Geometry.alive(state, arrived_squad).is_empty(): return false
	var reactor := 3 - int(arrived.owner)
	var pending := _eligible_squads(state, arrived_squad, reactor)
	if pending.is_empty(): return false
	var current: Dictionary = state.unit_abilities.get("window", {})
	if str(current.get("kind", "")) == KIND: return false
	state.unit_abilities.window = {
		"kind": KIND,
		"owners": [reactor],
		"arrived_squad": arrived_squad,
		"pending": pending,
		"active_squad": -1,
		"return_window": current.duplicate(true)
	}
	return true

static func choices(state: Dictionary, player: int) -> Array:
	var window := _window(state)
	if window.is_empty() or int(window.owners[0]) != player: return []
	var arrived := int(window.get("arrived_squad", -1))
	var arrived_name := str(state.squads.get(arrived, {}).get("name", "the arriving unit"))
	var active := int(window.get("active_squad", -1))
	var result: Array = []
	if active >= 0:
		result.append(_choice("Decline Hyperspace Hunters against %s" % arrived_name, active, "pass"))
		return result
	for squad_value: Variant in window.get("pending", []):
		var squad := int(squad_value)
		var squad_name := str(state.squads.get(squad, {}).get("name", "Deathmarks"))
		result.append(_choice("Hyperspace Hunters: %s shoots at %s" % [squad_name, arrived_name], squad, "shoot"))
		result.append(_choice("Hyperspace Hunters: %s declines this arrival" % squad_name, squad, "pass"))
	return result

static func apply(state: Dictionary, player: int, selected: Dictionary) -> Dictionary:
	var window := _window(state)
	if window.is_empty() or int(window.owners[0]) != player: return {"error": "Hyperspace Hunters is not waiting for this player."}
	var squad := int(selected.get("target", -1))
	var pending: Array = window.get("pending", [])
	if squad not in pending: return {"error": "Choose one Deathmarks unit that can see this arrival."}
	var value := str(selected.get("value", ""))
	if value == "shoot":
		if int(window.get("active_squad", -1)) >= 0: return {"error": "Resolve or decline the selected Hyperspace Hunters shot first."}
		window.active_squad = squad
		state.unit_abilities.window = window
		return {"error": "", "message": "Hyperspace Hunters: shoot only at the unit that just arrived from Reserves."}
	if value == "pass":
		return consume(state, squad, false)
	return {"error": "Choose whether this Deathmarks unit shoots at the arriving unit."}

static func active_shooter(state: Dictionary, squad: int) -> bool:
	var window := _window(state)
	return not window.is_empty() and int(window.get("active_squad", -1)) == squad

static func consume(state: Dictionary, squad: int, spent_shot: bool) -> Dictionary:
	var window := _window(state)
	if window.is_empty(): return {}
	if spent_shot:
		if not state.unit_abilities.has("used"): state.unit_abilities.used = {}
		state.unit_abilities.used["hyperspace-hunters:%d" % squad] = int(state.get("turn", 0))
	var pending: Array = window.get("pending", []).duplicate()
	pending.erase(squad)
	window.pending = pending
	window.active_squad = -1
	if not pending.is_empty():
		state.unit_abilities.window = window
		return {}
	var deferred: Dictionary = window.get("deferred_drop_pod", {}).duplicate(true)
	state.unit_abilities.window = window.get("return_window", {}).duplicate(true)
	return {"deferred_drop_pod": deferred}

static func _eligible_squads(state: Dictionary, arrived_squad: int, reactor: int) -> Array[int]:
	var result: Array[int] = []
	for squad: int in state.get("squads", {}):
		if int(state.squads[squad].get("owner", -1)) != reactor or not _deathmarks(state, squad): continue
		if int(state.unit_abilities.get("used", {}).get("hyperspace-hunters:%d" % squad, -1)) == int(state.get("turn", 0)): continue
		if not _in_range_and_visible(state, squad, arrived_squad): continue
		if not _eligible_target(state, squad, arrived_squad): continue
		result.append(squad)
	result.sort()
	return result

static func _deathmarks(state: Dictionary, squad: int) -> bool:
	var found := false
	for model: int in Geometry.alive(state, squad):
		var unit: Dictionary = state.units[model]
		if str(unit.get("definition_id", "")) != DEFINITION or not unit.get("on_battlefield", true): return false
		found = true
	return found

static func _in_range_and_visible(state: Dictionary, squad: int, target: int) -> bool:
	var closest := INF
	var visible := false
	for model: int in Geometry.alive(state, squad):
		var sight := Terrain.targeting(state, model, target)
		closest = minf(closest, float(sight.get("distance", INF)))
		visible = visible or bool(sight.get("visible", false))
	return visible and closest <= RANGE + EPSILON

static func _eligible_target(state: Dictionary, squad: int, target: int) -> bool:
	for model: int in Geometry.alive(state, squad):
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
