extends RefCounted
## Source-bounded Illuminor Szeras: Illuminor, Mechanical Augmentation (Aura), and Atomic Energy Manipulator.
const AbilityCatalog = preload("res://scripts/edition_11/unit_ability_catalog.gd")
const Geometry = preload("res://scripts/edition_11/contact_movement.gd")

const IDENTITY := "illuminor-szeras"
const DEFINITION_ID := "40kdc:11e:necrons:illuminor-szeras"
const BASE_AURA_RANGE := 3.0
const MAX_AURA_RANGE := 12.0
const RANGE_INCREMENT := 3.0
const LONE_OP_DISTANCE := 3.0
const LONE_OP_RANGE := 12.0
const EPSILON := 0.001

static func _phase_key(state: Dictionary) -> String:
	return "%d:%s" % [int(state.get("turn", 0)), str(state.get("phase", ""))]

static func _has_keyword(unit: Dictionary, keyword: String) -> bool:
	var target_kw := keyword.strip_edges().to_upper()
	if target_kw == "NECRONS" and str(unit.get("definition_id", "")).begins_with("40kdc:11e:necrons:"):
		return true
	for kw: Variant in unit.get("keywords", []):
		if str(kw).replace("_", " ").replace("-", " ").strip_edges().to_upper() == target_kw:
			return true
	return false

static func _squad_has_keyword(state: Dictionary, squad: int, keyword: String) -> bool:
	for model_id: int in Geometry.alive(state, squad):
		if _has_keyword(state.units[model_id], keyword):
			return true
	return false

## Illuminor: While this model is within 3" of one or more other friendly NECRONS units,
## this model has the Lone Operative ability.
static func lone_operative_active(state: Dictionary, model: int) -> bool:
	if not state.get("units", {}).has(model): return false
	var szeras: Dictionary = state.units[model]
	if AbilityCatalog.identity(szeras) != IDENTITY and str(szeras.get("definition_id", "")) != DEFINITION_ID:
		return false
	if int(szeras.get("wounds", 0)) <= 0 or not bool(szeras.get("on_battlefield", true)):
		return false
	var own_squad := int(szeras.get("squad", -1))
	if state.get("squads", {}).has(own_squad) and bool(state.squads[own_squad].get("attached", false)):
		return false
	var owner := int(szeras.get("owner", -1))
	for squad: int in state.get("squads", {}):
		if squad == own_squad: continue
		if int(state.squads[squad].get("owner", -1)) != owner: continue
		if not _squad_has_keyword(state, squad, "NECRONS"): continue
		if Geometry.alive(state, squad).is_empty(): continue
		if Geometry.distance_to_target(state, szeras, squad) <= LONE_OP_DISTANCE + EPSILON:
			return true
	return false

static func lone_operative_range(state: Dictionary, model: int) -> float:
	if not lone_operative_active(state, model): return 0.0
	return LONE_OP_RANGE

## Atomic Energy Manipulator range tracking:
## Base 3", permanently +3" (max 12") if Szeras destroyed >= 1 model in a Fight phase.
static func mechanical_augmentation_range(state: Dictionary, model: int) -> float:
	if not state.get("units", {}).has(model): return BASE_AURA_RANGE
	var val: Variant = state.units[model].get("mechanical_augmentation_range", BASE_AURA_RANGE)
	return clampf(float(val), BASE_AURA_RANGE, MAX_AURA_RANGE)

## Mechanical Augmentation (Aura):
## While a friendly Necrons Battleline unit is within range of this model,
## improve AP of that unit's attacks by 1, and worsen AP of attacks targeting that unit by 1.
static func mechanical_augmentation_applies(state: Dictionary, squad: int) -> bool:
	if not state.get("squads", {}).has(squad): return false
	if not _squad_has_keyword(state, squad, "NECRONS"): return false
	if not _squad_has_keyword(state, squad, "BATTLELINE"): return false
	var squad_owner := int(state.squads[squad].get("owner", -1))
	for model_id: int in state.get("units", {}):
		var unit: Dictionary = state.units[model_id]
		if AbilityCatalog.identity(unit) != IDENTITY and str(unit.get("definition_id", "")) != DEFINITION_ID:
			continue
		if int(unit.get("owner", -1)) != squad_owner: continue
		if int(unit.get("wounds", 0)) <= 0 or not bool(unit.get("on_battlefield", true)): continue
		var szeras_squad := int(unit.get("squad", -1))
		if state.get("unit_abilities", {}).get("reserves", {}).has(szeras_squad): continue
		var aura_dist := mechanical_augmentation_range(state, model_id)
		if Geometry.distance_to_target(state, unit, squad) <= aura_dist + EPSILON:
			return true
	return false

## Kill tracking for Atomic Energy Manipulator:
static func record_kill(state: Dictionary, model: int, count: int = 1) -> void:
	if not state.get("units", {}).has(model) or count <= 0: return
	var key := _phase_key(state)
	if not state.has("unit_abilities"): state.unit_abilities = {}
	if not state.unit_abilities.has("phase_kills"):
		state.unit_abilities.phase_kills = {}
	if not state.unit_abilities.phase_kills.has(key):
		state.unit_abilities.phase_kills[key] = {}
	state.unit_abilities.phase_kills[key][model] = int(state.unit_abilities.phase_kills[key].get(model, 0)) + count

static func kills_this_phase(state: Dictionary, model: int) -> int:
	var key := _phase_key(state)
	return int(state.get("unit_abilities", {}).get("phase_kills", {}).get(key, {}).get(model, 0))

## Resolves Atomic Energy Manipulator at the end of the Fight phase.
static func resolve_atomic_energy_manipulator(state: Dictionary) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for model_id: int in state.get("units", {}):
		var unit: Dictionary = state.units[model_id]
		if AbilityCatalog.identity(unit) != IDENTITY and str(unit.get("definition_id", "")) != DEFINITION_ID:
			continue
		if int(unit.get("wounds", 0)) <= 0 or not bool(unit.get("on_battlefield", true)):
			continue
		if kills_this_phase(state, model_id) >= 1:
			var current_range := mechanical_augmentation_range(state, model_id)
			var new_range := minf(MAX_AURA_RANGE, current_range + RANGE_INCREMENT)
			unit.mechanical_augmentation_range = new_range
			result.append({
				"model": model_id,
				"previous_range": current_range,
				"new_range": new_range,
				"kills": kills_this_phase(state, model_id)
			})
	return result
