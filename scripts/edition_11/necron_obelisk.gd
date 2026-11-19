extends RefCounted
## Source-bounded Obelisk Gravitic Pulse from Necrons App v1.2 datasheet 000000557.
const Geometry = preload("res://scripts/edition_11/contact_movement.gd")
const Terrain = preload("res://scripts/edition_11/terrain.gd")
const AbilityCatalog = preload("res://scripts/edition_11/unit_ability_catalog.gd")

const IDENTITY := "obelisk"
const ACTION := "gravitic-pulse"
const PASS_ACTION := "gravitic-pulse-pass"
const MORTAL_WINDOW := "gravitic-pulse-mortal"
const RANGE_INCHES := 18.0

static func _has_keyword(state: Dictionary, squad: int, keyword: String) -> bool:
	for model: int in Geometry.alive(state, squad):
		for value: Variant in state.units[model].get("keywords", []):
			if str(value).strip_edges().to_upper() == keyword.to_upper(): return true
	return false

static func _obelisk_models(state: Dictionary, owner: int) -> Array[int]:
	var result: Array[int] = []
	if not AbilityCatalog.enabled(state): return result
	for model: int in state.get("units", {}):
		var unit: Dictionary = state.units[model]
		if int(unit.get("owner", -1)) != owner or int(unit.get("wounds", 0)) <= 0 or not unit.get("on_battlefield", true): continue
		if AbilityCatalog.identity(unit) != IDENTITY: continue
		var squad := int(unit.get("squad", -1))
		if AbilityCatalog.sources(state, squad, "gravitic-pulse").is_empty(): continue
		result.append(model)
	result.sort()
	return result

static func start_available(state: Dictionary, owner: int) -> bool:
	if str(state.get("phase", "")) != "movement" or int(state.get("active", -1)) == owner: return false
	if state.get("unit_abilities", {}).get("used", {}).has(_start_key(state, owner)): return false
	return not _obelisk_models(state, owner).is_empty() and not eligible_targets(state, owner).is_empty()

static func eligible_targets(state: Dictionary, owner: int) -> Array[int]:
	var result: Array[int] = []
	var sources := _obelisk_models(state, owner)
	if sources.is_empty(): return result
	for target: int in state.get("squads", {}):
		if int(state.squads[target].get("owner", -1)) == owner: continue
		if Geometry.alive(state, target).is_empty(): continue
		for model: int in sources:
			var sight: Dictionary = Terrain.targeting(state, model, target)
			if bool(sight.get("visible", false)) and float(sight.get("distance", INF)) <= RANGE_INCHES + 0.001:
				result.append(target)
				break
	result.sort()
	return result

static func choices(state: Dictionary, player: int) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if not start_available(state, player): return result
	var sources := _obelisk_models(state, player)
	if sources.is_empty(): return result
	var source_model := sources[0]
	for target: int in eligible_targets(state, player):
		result.append({"label": "Gravitic Pulse: slow %s" % str(state.squads[target].get("name", "enemy unit")), "action": ACTION, "model": source_model, "target": target, "value": "pulse"})
	result.append({"label": "Pass Gravitic Pulse", "action": PASS_ACTION, "model": source_model, "target": -1, "value": "pass"})
	return result

static func apply(state: Dictionary, player: int, selected: Dictionary) -> Dictionary:
	if selected not in choices(state, player): return {"error": "Gravitic Pulse is available at the start of the opponent's Movement phase against one visible enemy within 18 inches."}
	state.unit_abilities.used[_start_key(state, player)] = true
	if str(selected.get("action", "")) == PASS_ACTION:
		return {"error": "", "message": "Gravitic Pulse was declined."}
	var target := int(selected.get("target", -1))
	var mark := {
		"owner": int(state.squads[target].get("owner", -1)),
		"source_owner": player,
		"source_model": int(selected.get("model", -1)),
		"half_expires_turn": int(state.get("turn", 0)),
		"fly_active": _has_keyword(state, target, "FLY")
	}
	if not state.unit_abilities.has("gravitic_pulse_marks"): state.unit_abilities.gravitic_pulse_marks = {}
	var marks: Dictionary = state.unit_abilities.gravitic_pulse_marks.duplicate(true)
	marks[target] = mark
	state.unit_abilities.gravitic_pulse_marks = marks
	return {"error": "", "message": "Gravitic Pulse marks %s until the end of the turn." % str(state.squads[target].get("name", "the enemy unit"))}

static func half_active(state: Dictionary, squad: int) -> bool:
	var mark: Dictionary = state.get("unit_abilities", {}).get("gravitic_pulse_marks", {}).get(squad, {})
	return not mark.is_empty() and int(mark.get("half_expires_turn", -2)) == int(state.get("turn", -1))

static func fly_active(state: Dictionary, squad: int) -> bool:
	var mark: Dictionary = state.get("unit_abilities", {}).get("gravitic_pulse_marks", {}).get(squad, {})
	return not mark.is_empty() and bool(mark.get("fly_active", false))

static func movement_characteristic(state: Dictionary, squad: int, base_movement: float) -> float:
	if not half_active(state, squad): return base_movement
	return float(ceili(base_movement / 2.0))

static func halve_roll(state: Dictionary, squad: int, roll_total: int) -> int:
	if not half_active(state, squad): return roll_total
	return int(ceili(float(roll_total) / 2.0))

static func clear_fly_at_owner_movement_start(state: Dictionary) -> void:
	if str(state.get("phase", "")) != "movement" or not state.get("unit_abilities") is Dictionary: return
	var active := int(state.get("active", -1))
	var marks: Dictionary = state.unit_abilities.get("gravitic_pulse_marks", {})
	if marks.is_empty(): return
	var kept: Dictionary = {}
	for squad: Variant in marks.keys():
		var mark: Dictionary = marks[squad]
		if int(mark.get("source_owner", -1)) == active:
			continue
		kept[squad] = mark
	state.unit_abilities.gravitic_pulse_marks = kept

static func after_move(state: Dictionary, squad: int, roller: Callable) -> Dictionary:
	if not fly_active(state, squad): return {"error": "", "triggered": false}
	if not roller.is_valid(): return {"error": "Gravitic Pulse requires the host's D6."}
	var roll: Variant = roller.call()
	if not roll is int or int(roll) < 1 or int(roll) > 6: return {"error": "Gravitic Pulse dice must be 1–6."}
	if int(roll) < 4: return {"error": "", "triggered": true, "roll": int(roll), "wounds": 0}
	var damage_die: Variant = roller.call()
	if not damage_die is int or int(damage_die) < 1 or int(damage_die) > 6: return {"error": "Gravitic Pulse D3 mortal wounds require a D6."}
	var wounds := int(ceili(float(damage_die) / 2.0))
	var mark: Dictionary = state.unit_abilities.gravitic_pulse_marks.get(squad, {})
	var record := {
		"owner": int(state.squads[squad].get("owner", -1)),
		"source": int(mark.get("source_model", -1)),
		"target": squad,
		"roll": int(roll),
		"damage_die": int(damage_die),
		"remaining": wounds,
		"total": wounds,
		"allocations": [],
		"discarded": 0,
		"stage": "allocating"
	}
	state.last_gravitic_pulse = record
	var resume_window: Dictionary = state.get("unit_abilities", {}).get("window", {}).duplicate(true)
	state.unit_abilities.window = {"kind": MORTAL_WINDOW, "owners": [int(state.squads[squad].get("owner", -1))], "target": squad, "resume_window": resume_window}
	return {"error": "", "triggered": true, "roll": int(roll), "wounds": wounds, "damage_die": int(damage_die)}

static func _start_key(state: Dictionary, owner: int) -> String:
	return "gravitic-pulse:%d:%d" % [int(state.get("turn", 0)), owner]
