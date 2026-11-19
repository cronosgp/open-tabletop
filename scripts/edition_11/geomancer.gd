extends RefCounted
## Source-bounded Geomancer: Tectonic Reverberations, Obelisk Node Control, and Vanguard Protocols (Scouts 8").
const AbilityCatalog = preload("res://scripts/edition_11/unit_ability_catalog.gd")
const Geometry = preload("res://scripts/edition_11/contact_movement.gd")
const Objectives = preload("res://scripts/edition_11/objectives.gd")
const Terrain = preload("res://scripts/edition_11/terrain.gd")

const IDENTITY := "geomancer"
const DEFINITION_ID := "40kdc:11e:necrons:geomancer"
const TECTONIC_ACTION := "tectonic-reverberations"
const TECTONIC_RANGE := 18.0
const RESERVE_EXCLUSION_RANGE := 12.0
const VANGUARD_SCOUT_DISTANCE := 8
const EPSILON := 0.001

static func _phase_key(state: Dictionary) -> String:
	return "%d:%s" % [int(state.get("turn", 0)), str(state.get("phase", ""))]

static func _is_geomancer(unit: Dictionary) -> bool:
	return AbilityCatalog.identity(unit) == IDENTITY or str(unit.get("definition_id", "")) == DEFINITION_ID

static func _geomancer_models(state: Dictionary, owner: int) -> Array[int]:
	var result: Array[int] = []
	for model_id: int in state.get("units", {}):
		var unit: Dictionary = state.units[model_id]
		if not _is_geomancer(unit): continue
		if int(unit.get("owner", -1)) != owner or int(unit.get("wounds", 0)) <= 0: continue
		if not bool(unit.get("on_battlefield", true)): continue
		var squad := int(unit.get("squad", -1))
		if state.get("unit_abilities", {}).get("reserves", {}).has(squad): continue
		if int(unit.get("embarked_transport", -1)) >= 0: continue
		result.append(model_id)
	result.sort()
	return result

## Tectonic Reverberations:
## In your Movement phase, select one enemy unit within 18" of and visible to this model.
## Until the start of your next Movement phase that enemy unit is pinned (-2 Move, -2 Charge).
static func tectonic_choices(state: Dictionary, player: int) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if str(state.get("phase", "")) != "movement" or int(state.get("active", -1)) != player:
		return result
	var used: Dictionary = state.get("unit_abilities", {}).get("used", {})
	var pkey := _phase_key(state)
	for model_id: int in _geomancer_models(state, player):
		if used.get("%s:%d:%s" % [TECTONIC_ACTION, model_id, pkey], false):
			continue
		for enemy_squad: int in state.get("squads", {}):
			if int(state.squads[enemy_squad].get("owner", -1)) == player: continue
			if Geometry.alive(state, enemy_squad).is_empty(): continue
			var sight := Terrain.targeting(state, model_id, enemy_squad)
			if sight.visible and float(sight.distance) <= TECTONIC_RANGE + EPSILON:
				result.append({
					"label": "Tectonic Reverberations %d: pin %s (-2 Move, -2 Charge)" % [model_id, str(state.squads[enemy_squad].get("name", "Enemy unit"))],
					"action": TECTONIC_ACTION,
					"model": model_id,
					"target": enemy_squad
				})
	return result

static func apply_tectonic(state: Dictionary, player: int, selected: Dictionary) -> Dictionary:
	var model := int(selected.get("model", -1))
	var target := int(selected.get("target", -1))
	var matched := false
	for opt: Dictionary in tectonic_choices(state, player):
		if int(opt.get("model", -1)) == model and int(opt.get("target", -1)) == target:
			matched = true
			break
	if not matched:
		return {"error": "Tectonic Reverberations requires a visible enemy unit within 18 inches during your Movement phase."}
	if not state.has("unit_abilities"): state.unit_abilities = {}
	if not state.unit_abilities.has("used"): state.unit_abilities.used = {}
	if not state.unit_abilities.has("pinned_units"): state.unit_abilities.pinned_units = {}
	state.unit_abilities.used["%s:%d:%s" % [TECTONIC_ACTION, model, _phase_key(state)]] = true
	state.unit_abilities.pinned_units[target] = {
		"source_owner": player,
		"source_model": model,
		"turn": int(state.get("turn", 0))
	}
	return {
		"error": "",
		"message": "Tectonic Reverberations: %s is pinned until your next Movement phase (-2 Move, -2 Charge)." % str(state.squads[target].get("name", "Enemy unit"))
	}

static func is_pinned(state: Dictionary, squad: int) -> bool:
	return state.get("unit_abilities", {}).get("pinned_units", {}).has(squad)

static func movement_penalty(state: Dictionary, squad: int) -> float:
	return 2.0 if is_pinned(state, squad) else 0.0

static func charge_penalty(state: Dictionary, squad: int) -> int:
	return 2 if is_pinned(state, squad) else 0

static func clear_pinned_at_owner_movement_start(state: Dictionary) -> void:
	if str(state.get("phase", "")) != "movement" or not state.get("unit_abilities") is Dictionary:
		return
	var active := int(state.get("active", -1))
	var pinned: Dictionary = state.unit_abilities.get("pinned_units", {})
	if pinned.is_empty(): return
	var kept: Dictionary = {}
	for squad: Variant in pinned.keys():
		var mark: Dictionary = pinned[squad]
		if int(mark.get("source_owner", -1)) == active:
			continue
		kept[squad] = mark
	state.unit_abilities.pinned_units = kept

## Obelisk Node Control:
## While this model is within range of an objective marker you control,
## enemy units that are set up on the battlefield from Reserves cannot be set up within 12" of this model.
static func obelisk_node_control_active(state: Dictionary, model: int) -> bool:
	if not state.get("units", {}).has(model): return false
	var unit: Dictionary = state.units[model]
	if not _is_geomancer(unit): return false
	if int(unit.get("wounds", 0)) <= 0 or not bool(unit.get("on_battlefield", true)): return false
	var squad := int(unit.get("squad", -1))
	if state.get("unit_abilities", {}).get("reserves", {}).has(squad): return false
	if int(unit.get("embarked_transport", -1)) >= 0: return false
	var owner := int(unit.get("owner", -1))
	for objective: Dictionary in state.get("mission", {}).get("objectives", []):
		if int(objective.get("controller", 0)) == owner and Objectives.in_range(unit, objective):
			return true
	return false

static func reserve_exclusion_error(state: Dictionary, arriving_unit: Dictionary, point: Vector2) -> String:
	var arriving_owner := int(arriving_unit.get("owner", -1))
	var arriving_radius := float(arriving_unit.get("radius", 0.0))
	for model_id: int in state.get("units", {}):
		var other: Dictionary = state.units[model_id]
		if int(other.get("owner", -1)) == arriving_owner: continue
		if not obelisk_node_control_active(state, model_id): continue
		var dist := point.distance_to(other.position) - arriving_radius - float(other.get("radius", 0.0))
		if dist <= RESERVE_EXCLUSION_RANGE + EPSILON:
			return "Enemy units from Reserves cannot be set up within 12 inches of a Geomancer with Obelisk Node Control."
	return ""

## Vanguard Protocols:
## If this model is attached to a Canoptek Macrocytes unit during the Declare Battle Formations step,
## this model has the Scouts 8" ability.
static func vanguard_protocols_active(state: Dictionary, model: int) -> bool:
	if not state.get("units", {}).has(model): return false
	var unit: Dictionary = state.units[model]
	if not _is_geomancer(unit): return false
	var squad := int(unit.get("squad", -1))
	if not state.get("squads", {}).has(squad): return false
	for member_id: int in state.get("units", {}):
		var member: Dictionary = state.units[member_id]
		if int(member.get("squad", -1)) != squad: continue
		if AbilityCatalog.identity(member) == "canoptek-macrocytes":
			return true
	return false
