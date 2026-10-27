extends RefCounted
## Target Augury Web from the Medusa's Wrath enhancement.

const Geometry = preload("res://scripts/edition_11/contact_movement.gd")
const MarineEnhancements = preload("res://scripts/edition_11/stormlance_enhancements.gd")
const Techmarine = preload("res://scripts/edition_11/techmarine.gd")

const WINDOW := "target-augury-web"
const APPLY := "target-augury-web-apply"
const PASS := "target-augury-web-pass"
const MOVE_TYPES := ["normal", "advance", "ordered_retreat", "desperate_escape"]

static func _source_in_squad(state: Dictionary, squad: int) -> int:
	for model: int in Geometry.alive(state, squad):
		if Techmarine.identity(state.units[model]) == "techmarine" and MarineEnhancements.target_augury_web_bearer(state, model): return model
	return -1

static func eligible_vehicle_models(state: Dictionary, source: int) -> Array[int]:
	var result: Array[int] = []
	if not state.get("units", {}).has(source): return result
	var bearer: Dictionary = state.units[source]
	var squad := int(bearer.get("squad", -1))
	if not state.get("squads", {}).has(squad): return result
	var nearby_models := Geometry.alive(state, squad)
	for target_model: int in state.units:
		var target: Dictionary = state.units[target_model]
		if int(target.get("owner", -1)) != int(bearer.get("owner", -2)) or int(target.get("squad", -1)) == squad: continue
		if int(target.get("wounds", 0)) <= 0 or not target.get("on_battlefield", true) or not Techmarine.astartes_vehicle(target): continue
		var in_range := false
		for nearby_model: int in nearby_models:
			if not state.units.has(nearby_model) or not state.units[nearby_model].get("on_battlefield", true): continue
			if Geometry.edge(state.units[nearby_model], target) <= 3.001:
				in_range = true
				break
		if in_range: result.append(target_model)
	return result

static func _timing_is_current(state: Dictionary, squad: int, moment: String) -> bool:
	if state.get("phase", "") != "movement" or not state.get("squads", {}).has(squad): return false
	if int(state.squads[squad].get("owner", -1)) != int(state.get("active", -2)): return false
	if moment == "start":
		var pending_move: Dictionary = state.get("pending_move", {})
		if not pending_move.is_empty() and int(pending_move.get("squad", -1)) != squad: return false
		if bool(state.squads[squad].get("moved", false)): return false
		var move_type := str(pending_move.get("move_type", ""))
		return pending_move.is_empty() or move_type in MOVE_TYPES
	if moment == "end":
		return bool(state.squads[squad].get("moved", false)) and str(state.squads[squad].get("move_type", "")) in MOVE_TYPES
	return false

static func open_for_move(state: Dictionary, squad: int, moment: String) -> bool:
	if not state.has("unit_abilities") or moment not in ["start", "end"]: return false
	if not _timing_is_current(state, squad, moment): return false
	var source := _source_in_squad(state, squad)
	if source < 0: return false
	var targets := eligible_vehicle_models(state, source)
	if targets.is_empty(): return false
	var previous: Dictionary = state.unit_abilities.get("window", {}).duplicate(true)
	if previous.get("kind", "") == WINDOW and int(previous.get("squad", -1)) == squad and str(previous.get("moment", "")) == moment: return false
	state.unit_abilities.window = {"kind": WINDOW, "owners": [int(state.squads[squad].owner)], "squad": squad,
		"source": source, "moment": moment, "resume_window": previous}
	return true

static func start_decision_pending(state: Dictionary, squad: int) -> bool:
	var window: Dictionary = state.get("unit_abilities", {}).get("window", {})
	return window.get("kind", "") == WINDOW and str(window.get("moment", "")) == "start" and int(window.get("squad", -1)) == squad

static func choices(state: Dictionary, player: int) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var window: Dictionary = state.get("unit_abilities", {}).get("window", {})
	if window.get("kind", "") != WINDOW or window.get("owners", []) != [player]: return result
	var source := int(window.get("source", -1))
	var squad := int(window.get("squad", -1))
	var moment := str(window.get("moment", ""))
	var moment_label := "start" if moment == "start" else "end"
	var source_unit: Dictionary = state.get("units", {}).get(source, {})
	var source_valid := not source_unit.is_empty() and Techmarine.identity(source_unit) == "techmarine" and MarineEnhancements.target_augury_web_bearer(state, source)
	if source_valid and _timing_is_current(state, squad, moment):
		for target_model: int in eligible_vehicle_models(state, source):
			var target: Dictionary = state.units[target_model]
			var target_squad := int(target.get("squad", -1))
			if not state.get("squads", {}).has(target_squad): continue
			result.append({"label": "Target Augury Web: %s model %d gains Lethal Hits until your next Command phase" % [str(state.squads[target_squad].get("name", "Vehicle")), target_model],
				"action": APPLY, "model": source, "target": target_model, "value": moment})
	var pass_label := "Target Augury Web: do not select a Vehicle at the %s of this move" % moment_label
	if not source_valid or not _timing_is_current(state, squad, moment): pass_label = "Target Augury Web: close this expired %s-of-move choice" % moment_label
	result.append({"label": pass_label, "action": PASS, "model": source, "target": squad, "value": moment})
	return result

static func apply(state: Dictionary, player: int, selected: Dictionary) -> Dictionary:
	var window: Dictionary = state.get("unit_abilities", {}).get("window", {})
	if window.get("kind", "") != WINDOW or window.get("owners", []) != [player]: return {"error": "No matching Target Augury Web decision is pending."}
	var source := int(window.get("source", -1))
	var squad := int(window.get("squad", -1))
	var moment := str(window.get("moment", ""))
	if int(selected.get("model", -1)) != source: return {"error": "This choice belongs to the pending Techmarine bearer."}
	if selected.get("value", "") != moment: return {"error": "The Target Augury Web timing does not match the pending move."}
	if str(selected.get("action", "")) == PASS:
		if int(selected.get("target", -1)) != squad: return {"error": "This Target Augury Web pass belongs to the pending Techmarine unit."}
		state.unit_abilities.window = window.get("resume_window", {})
		return {"error": "", "message": "Target Augury Web was not used."}
	if not state.get("units", {}).has(source) or int(state.units[source].get("owner", -1)) != player or Techmarine.identity(state.units[source]) != "techmarine" or not MarineEnhancements.target_augury_web_bearer(state, source):
		return {"error": "Target Augury Web belongs to its living Techmarine bearer."}
	if str(selected.get("action", "")) != APPLY or not _timing_is_current(state, squad, moment):
		return {"error": "Target Augury Web can only be used at the start or end of its bearer unit's Movement-phase move."}
	var target := int(selected.get("target", -1))
	if target not in eligible_vehicle_models(state, source): return {"error": "Select a friendly Adeptus Astartes Vehicle model within 3 inches of the bearer unit."}
	if not state.has("marine_enhancements"): state.marine_enhancements = {}
	if not state.marine_enhancements.has("target_augury_web"): state.marine_enhancements.target_augury_web = {}
	state.marine_enhancements.target_augury_web[target] = {"owner": player, "source": source, "activated_turn": int(state.get("turn", 0)), "expires_turn": int(state.get("turn", 0)) + 2}
	state.unit_abilities.window = window.get("resume_window", {})
	return {"error": "", "message": "%s model %d gains Lethal Hits until the start of your next Command phase." % [str(state.squads[int(state.units[target].squad)].get("name", "Vehicle")), target]}

static func active(state: Dictionary, model: int) -> bool:
	if not state.get("units", {}).has(model): return false
	var unit: Dictionary = state.units[model]
	if int(unit.get("wounds", 0)) <= 0 or not unit.get("on_battlefield", true) or not Techmarine.astartes_vehicle(unit): return false
	var effect: Dictionary = state.get("marine_enhancements", {}).get("target_augury_web", {}).get(model, {})
	return not effect.is_empty() and int(effect.get("owner", -1)) == int(unit.get("owner", -2)) and int(state.get("turn", 0)) < int(effect.get("expires_turn", -1))
