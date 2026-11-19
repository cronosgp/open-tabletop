extends RefCounted
## Source-bounded Nekrosor Ammentar: Protective Disciples, Infectious Murder-madness (Aura),
## Prophet of Destruction, and Nullstone Field Generator (Aura).
const AbilityCatalog = preload("res://scripts/edition_11/unit_ability_catalog.gd")
const Geometry = preload("res://scripts/edition_11/contact_movement.gd")

const IDENTITY := "nekrosor-ammentar"
const DEFINITION_ID := "40kdc:11e:necrons:nekrosor-ammentar"
const PROPHET_WINDOW := "prophet-of-destruction"
const PROPHET_SELECT := "prophet-of-destruction-select"
const PROPHET_PASS := "prophet-of-destruction-pass"
const LONE_OP_DISTANCE := 3.0
const LONE_OP_RANGE := 12.0
const AURA_RANGE := 6.0
const PROPHET_RANGE := 9.0
const EPSILON := 0.001

static func _phase_key(state: Dictionary) -> String:
	return "%d:%s" % [int(state.get("turn", 0)), str(state.get("phase", ""))]

static func is_ammentar(unit: Dictionary) -> bool:
	return AbilityCatalog.identity(unit) == IDENTITY or str(unit.get("definition_id", "")) == DEFINITION_ID

static func model_has_keyword(unit: Dictionary, keyword: String) -> bool:
	var target_kw := keyword.strip_edges().to_upper()
	if target_kw == "NECRONS" and str(unit.get("definition_id", "")).begins_with("40kdc:11e:necrons:"):
		return true
	for kw: Variant in unit.get("keywords", []):
		if str(kw).replace("_", " ").replace("-", " ").strip_edges().to_upper() == target_kw:
			return true
	return false

static func squad_has_keyword(state: Dictionary, squad: int, keyword: String) -> bool:
	for model_id: int in Geometry.alive(state, squad):
		if model_has_keyword(state.units[model_id], keyword):
			return true
	return false

static func _ammentar_models(state: Dictionary, owner: int) -> Array[int]:
	var result: Array[int] = []
	for model_id: int in state.get("units", {}):
		var unit: Dictionary = state.units[model_id]
		if not is_ammentar(unit): continue
		if int(unit.get("owner", -1)) != owner or int(unit.get("wounds", 0)) <= 0: continue
		if not bool(unit.get("on_battlefield", true)): continue
		var squad := int(unit.get("squad", -1))
		if state.get("unit_abilities", {}).get("reserves", {}).has(squad): continue
		if int(unit.get("embarked_transport", -1)) >= 0: continue
		result.append(model_id)
	result.sort()
	return result

## Protective Disciples:
## While this model is within 3" of one or more other friendly Destroyer Cult units,
## this model has the Lone Operative ability.
static func lone_operative_active(state: Dictionary, model: int) -> bool:
	if not state.get("units", {}).has(model): return false
	var unit: Dictionary = state.units[model]
	if not is_ammentar(unit): return false
	if int(unit.get("wounds", 0)) <= 0 or not bool(unit.get("on_battlefield", true)):
		return false
	var own_squad := int(unit.get("squad", -1))
	if state.get("unit_abilities", {}).get("reserves", {}).has(own_squad):
		return false
	var owner := int(unit.get("owner", -1))
	for squad: int in state.get("squads", {}):
		if squad == own_squad: continue
		if int(state.squads[squad].get("owner", -1)) != owner: continue
		if not squad_has_keyword(state, squad, "DESTROYER CULT"): continue
		if Geometry.alive(state, squad).is_empty(): continue
		if Geometry.distance_to_target(state, unit, squad) <= LONE_OP_DISTANCE + EPSILON:
			return true
	return false

static func lone_operative_range(state: Dictionary, model: int) -> float:
	return LONE_OP_RANGE if lone_operative_active(state, model) else 0.0

## Infectious Murder-madness (Aura):
## While a friendly NECRONS unit (excluding Monster and Titanic units) is within 6" of this model...
static func infectious_murder_madness_in_aura(state: Dictionary, squad: int) -> bool:
	if not state.get("squads", {}).has(squad): return false
	if Geometry.alive(state, squad).is_empty(): return false
	if not squad_has_keyword(state, squad, "NECRONS"): return false
	if squad_has_keyword(state, squad, "MONSTER") or squad_has_keyword(state, squad, "TITANIC"):
		return false
	var owner := int(state.squads[squad].get("owner", -1))
	for model_id: int in _ammentar_models(state, owner):
		if Geometry.distance_to_target(state, state.units[model_id], squad) <= AURA_RANGE + EPSILON:
			return true
	return false

## Nullstone Field Generator (Aura):
## While a friendly NECRONS unit is within 6" of the bearer, models in that unit have
## the Feel No Pain 5+ ability against mortal wounds and Psychic Attacks.
static func feel_no_pain_grants(state: Dictionary, squad: int) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if not state.get("squads", {}).has(squad): return result
	if Geometry.alive(state, squad).is_empty(): return result
	if not squad_has_keyword(state, squad, "NECRONS"): return result
	var owner := int(state.squads[squad].get("owner", -1))
	for model_id: int in _ammentar_models(state, owner):
		if Geometry.distance_to_target(state, state.units[model_id], squad) <= AURA_RANGE + EPSILON:
			result.append({"target": 5, "against": "mortal"})
			result.append({"target": 5, "against": "psychic"})
			return result
	return result

## Prophet of Destruction:
## Each time this model destroys an enemy unit, select one other friendly Destroyer Cult unit within 9" of it.
## Until the end of the phase, each time a model in that unit makes an attack, re-roll a Wound roll of 1.
static func eligible_prophet_targets(state: Dictionary, ammentar_model: int) -> Array[int]:
	var result: Array[int] = []
	if not state.get("units", {}).has(ammentar_model): return result
	var unit: Dictionary = state.units[ammentar_model]
	if not is_ammentar(unit) or int(unit.get("wounds", 0)) <= 0 or not bool(unit.get("on_battlefield", true)):
		return result
	var own_squad := int(unit.get("squad", -1))
	var owner := int(unit.get("owner", -1))
	for squad: int in state.get("squads", {}):
		if squad == own_squad: continue
		if int(state.squads[squad].get("owner", -1)) != owner: continue
		if Geometry.alive(state, squad).is_empty(): continue
		if not squad_has_keyword(state, squad, "DESTROYER CULT"): continue
		if Geometry.distance_to_target(state, unit, squad) <= PROPHET_RANGE + EPSILON:
			result.append(squad)
	result.sort()
	return result

static func open_prophet_of_destruction(state: Dictionary, squad: int, targets: Array, killed: int) -> bool:
	if killed <= 0 or not state.get("squads", {}).has(squad): return false
	var owner := int(state.squads[squad].get("owner", -1))
	var destroyed_enemy := false
	for target_value: Variant in targets:
		var target := int(target_value)
		if state.get("squads", {}).has(target) and int(state.squads[target].get("owner", -1)) != owner and Geometry.alive(state, target).is_empty():
			destroyed_enemy = true
			break
	if not destroyed_enemy: return false
	var ammentar_model := -1
	for model_id: int in Geometry.alive(state, squad):
		if is_ammentar(state.units[model_id]):
			ammentar_model = model_id
			break
	if ammentar_model < 0: return false
	if eligible_prophet_targets(state, ammentar_model).is_empty(): return false
	if not state.has("unit_abilities"): state.unit_abilities = {}
	var resume_window: Dictionary = state.unit_abilities.get("window", {}).duplicate(true)
	state.unit_abilities.window = {
		"kind": PROPHET_WINDOW,
		"owners": [owner],
		"squad": squad,
		"model": ammentar_model,
		"resume_window": resume_window
	}
	return true

static func prophet_choices(state: Dictionary, player: int) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var window: Dictionary = state.get("unit_abilities", {}).get("window", {})
	if window.get("kind", "") != PROPHET_WINDOW or player not in window.get("owners", []):
		return result
	var ammentar_model := int(window.get("model", -1))
	for target_squad: int in eligible_prophet_targets(state, ammentar_model):
		result.append({
			"label": "Prophet of Destruction: %s re-rolls Wound rolls of 1 this phase" % str(state.squads[target_squad].get("name", "Destroyer Cult unit")),
			"action": PROPHET_SELECT,
			"model": ammentar_model,
			"target": target_squad
		})
	result.append({
		"label": "Pass Prophet of Destruction",
		"action": PROPHET_PASS,
		"model": ammentar_model,
		"target": int(window.get("squad", -1))
	})
	return result

static func apply_prophet(state: Dictionary, player: int, selected: Dictionary) -> Dictionary:
	var window: Dictionary = state.get("unit_abilities", {}).get("window", {})
	if window.get("kind", "") != PROPHET_WINDOW or player not in window.get("owners", []):
		return {"error": "Prophet of Destruction is not currently active."}
	var ammentar_model := int(window.get("model", -1))
	var action := str(selected.get("action", ""))
	if action == PROPHET_PASS:
		state.unit_abilities.window = window.get("resume_window", {})
		return {"error": "", "message": "Prophet of Destruction passed."}
	if action != PROPHET_SELECT:
		return {"error": "Select a friendly Destroyer Cult unit within 9 inches for Prophet of Destruction."}
	var target := int(selected.get("target", -1))
	if target not in eligible_prophet_targets(state, ammentar_model):
		return {"error": "Prophet of Destruction target must be another friendly Destroyer Cult unit within 9 inches."}
	if not state.unit_abilities.has("prophet_of_destruction"):
		state.unit_abilities.prophet_of_destruction = {}
	state.unit_abilities.prophet_of_destruction[target] = _phase_key(state)
	state.unit_abilities.window = window.get("resume_window", {})
	return {
		"error": "",
		"message": "Prophet of Destruction: %s re-rolls Wound rolls of 1 until the end of the phase." % str(state.squads[target].get("name", "Destroyer Cult unit"))
	}

static func prophet_wound_reroll_active(state: Dictionary, squad: int) -> bool:
	return str(state.get("unit_abilities", {}).get("prophet_of_destruction", {}).get(squad, "")) == _phase_key(state)
