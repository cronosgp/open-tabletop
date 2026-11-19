extends RefCounted
## Void Dragon Matter Absorption at the start of its controller's Shooting phase.
const AbilityCatalog = preload("res://scripts/edition_11/unit_ability_catalog.gd")
const DetachmentStratagems = preload("res://scripts/edition_11/detachment_stratagems.gd")
const Geometry = preload("res://scripts/edition_11/contact_movement.gd")
const Groups = preload("res://scripts/edition_11/defender_groups.gd")
const UnitPrevention = preload("res://scripts/edition_11/unit_prevention.gd")
const WoundPrevention = preload("res://scripts/edition_11/wound_prevention.gd")
const RandomStat = preload("res://scripts/edition_11/random_characteristic.gd")
const DeadlyDemise = preload("res://scripts/edition_11/deadly_demise.gd")
const TransportRules = preload("res://scripts/edition_11/transport_rules.gd")

const ACTION := "void-dragon-matter-absorption"
const ALLOCATE := "void-dragon-matter-absorption-allocate"
const MORTAL_WINDOW := "void-dragon-matter-absorption-mortal"
const SOURCE := "ctan-shard-of-the-void-dragon"
const RANGE := 12.0
const EPSILON := 0.001

static func _phase_key(state: Dictionary) -> String:
	return "%d:%s" % [int(state.get("turn", 0)), str(state.get("phase", ""))]

static func _targets(state: Dictionary, source_model: int) -> Array[int]:
	var result: Array[int] = []
	if not state.get("units", {}).has(source_model): return result
	var source: Dictionary = state.units[source_model]
	for target_value: Variant in state.get("squads", {}):
		var target := int(target_value)
		if int(state.squads[target].get("owner", -1)) == int(source.get("owner", -2)): continue
		if Geometry.alive(state, target).is_empty() or TransportRules.squad_embarked(state, target): continue
		if "VEHICLE" not in DetachmentStratagems.unit_keywords(state, target): continue
		if Geometry.distance_to_target(state, source, target) <= RANGE + EPSILON: result.append(target)
	result.sort()
	return result

static func _sources(state: Dictionary, owner: int) -> Array[int]:
	var result: Array[int] = []
	if str(state.get("phase", "")) != "shooting" or int(state.get("active", -1)) != owner or not AbilityCatalog.enabled(state): return result
	var used: Dictionary = state.get("unit_abilities", {}).get("used", {})
	var phase_key := _phase_key(state)
	for model_value: Variant in state.get("units", {}):
		var model := int(model_value)
		var unit: Dictionary = state.units[model]
		if int(unit.get("owner", -1)) != owner or int(unit.get("wounds", 0)) <= 0 or not unit.get("on_battlefield", true): continue
		if AbilityCatalog.identity(unit) != SOURCE: continue
		var squad := int(unit.get("squad", -1))
		if not AbilityCatalog.has(state, squad, "matter-absorption"): continue
		if str(used.get("matter-absorption:%d" % model, "")) == phase_key: continue
		if not _targets(state, model).is_empty(): result.append(model)
	result.sort()
	return result

static func start_available(state: Dictionary, owner: int) -> bool:
	return not _sources(state, owner).is_empty()

static func available(state: Dictionary, owner: int) -> bool:
	return start_available(state, owner)

static func choices(state: Dictionary, player: int) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var window: Dictionary = state.get("unit_abilities", {}).get("window", {})
	var owners: Array = window.get("owners", [])
	if window.get("kind", "") != "start" or owners.is_empty() or int(owners[0]) != player: return result
	for model: int in _sources(state, player):
		for target: int in _targets(state, model):
			result.append({"label": "Void Dragon %d: Matter Absorption — select %s" % [model, str(state.squads[target].get("name", "enemy Vehicle"))], "action": ACTION, "model": model, "target": target, "value": ""})
	return result

static func _finish(state: Dictionary) -> void:
	var pending: Dictionary = state.get("pending_matter_absorption", {})
	if pending.is_empty(): return
	var source_model := int(pending.get("source_model", -1))
	var rolled_amount := int(pending.get("d3", {}).get("value", 0))
	var healed := 0
	if state.get("units", {}).has(source_model) and int(state.units[source_model].get("wounds", 0)) > 0:
		var source: Dictionary = state.units[source_model]
		var missing := maxi(0, int(source.get("max_wounds", source.get("wounds", 0))) - int(source.get("wounds", 0)))
		healed = mini(rolled_amount, missing)
		source.wounds = int(source.get("wounds", 0)) + healed
	pending.healed = healed
	pending.healing_roll = rolled_amount
	var finished: Dictionary = pending.duplicate(true)
	state.last_matter_absorption = finished
	state.pending_matter_absorption = {}
	state.unit_abilities.window = finished.get("resume_window", {}).duplicate(true)

static func _advance(state: Dictionary) -> bool:
	var pending: Dictionary = state.get("pending_matter_absorption", {})
	if pending.is_empty(): return false
	if bool(pending.get("awaiting_destruction", false)):
		if not state.get("pending_deadly_demise", {}).is_empty(): return true
		pending.awaiting_destruction = false
	if int(pending.get("remaining", 0)) > 0 and not Geometry.alive(state, int(pending.get("target", -1))).is_empty():
		state.unit_abilities.window = {"kind": MORTAL_WINDOW, "owners": [int(pending.get("target_owner", -1))], "target": int(pending.get("target", -1))}
		return true
	pending.discarded = int(pending.get("discarded", 0)) + int(pending.get("remaining", 0))
	pending.remaining = 0
	_finish(state)
	return false

static func resolve(state: Dictionary, player: int, selected: Dictionary, roller: Callable) -> Dictionary:
	if selected not in choices(state, player): return {"error": "At the start of your Shooting phase, select an enemy Vehicle within 12 inches for Matter Absorption."}
	if not roller.is_valid(): return {"error": "Matter Absorption requires the host's dice provider."}
	var source_model := int(selected.get("model", -1))
	var target := int(selected.get("target", -1))
	var d6: Dictionary = RandomStat.roll("D6", roller)
	if not str(d6.get("error", "")).is_empty(): return d6
	var phase_key := _phase_key(state)
	var record := {"implementation": "necrons-app-v1.2-void-dragon-matter-absorption-2026-11-12", "source_model": source_model, "target": target, "phase_key": phase_key, "d6": d6.duplicate(true), "triggered": int(d6.value) >= 2, "d3": {}, "total": 0, "remaining": 0, "allocations": [], "discarded": 0, "healed": 0, "healing_roll": 0}
	if int(d6.value) < 2:
		state.unit_abilities.used["matter-absorption:%d" % source_model] = phase_key
		state.last_matter_absorption = record
		return {"error": "", "message": "Matter Absorption: D6 %d; the Vehicle suffers no mortal wounds and the Void Dragon does not heal." % int(d6.value)}
	var d3: Dictionary = RandomStat.roll("D3", roller)
	if not str(d3.get("error", "")).is_empty(): return d3
	var amount := int(d3.value)
	state.unit_abilities.used["matter-absorption:%d" % source_model] = phase_key
	record.d3 = d3.duplicate(true)
	record.total = amount
	record.remaining = amount
	record.target_owner = int(state.squads[target].owner)
	record.resume_window = state.unit_abilities.window.duplicate(true)
	state.pending_matter_absorption = record
	_advance(state)
	if state.get("pending_matter_absorption", {}).is_empty():
		return {"error": "", "message": "Matter Absorption caused %d mortal wounds to %s; the Void Dragon regains %d wound(s)." % [amount, str(state.squads[target].get("name", "the selected Vehicle")), int(state.last_matter_absorption.get("healed", 0))]}
	return {"error": "", "message": "Player %d: allocate %d Matter Absorption mortal wounds to %s." % [int(record.target_owner), amount, str(state.squads[target].get("name", "the selected Vehicle"))]}

static func allocation_choices(state: Dictionary, player: int) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var pending: Dictionary = state.get("pending_matter_absorption", {})
	if pending.is_empty() or state.get("unit_abilities", {}).get("window", {}).get("kind", "") != MORTAL_WINDOW: return result
	if int(pending.get("target_owner", -1)) != player: return result
	var current := {"target": int(pending.get("target", -1)), "precision": -1, "groups": [], "order": []}
	for model: int in Groups.current_models(state, current, true):
		result.append({"label": "Matter Absorption: allocate mortal wound to model %d (%d remaining)" % [model, int(pending.remaining)], "action": ALLOCATE, "model": model, "target": int(pending.target), "value": MORTAL_WINDOW})
	return result

static func allocate(state: Dictionary, player: int, selected: Dictionary, roller: Callable) -> Dictionary:
	if selected not in allocation_choices(state, player): return {"error": "Choose a living model in the affected Vehicle unit to allocate the Matter Absorption mortal wound."}
	var pending: Dictionary = state.pending_matter_absorption
	var model := int(selected.model)
	var target := int(pending.target)
	var prevention: Dictionary = WoundPrevention.resolve(1, int(state.units[model].wounds), UnitPrevention.rules(state, model), "mortal", roller)
	if not str(prevention.get("error", "")).is_empty(): return prevention
	state.units[model].wounds = int(state.units[model].wounds) - int(prevention.lost)
	pending.allocations.append({"model": model, "prevention": prevention.duplicate(true)})
	pending.remaining = maxi(0, int(pending.remaining) - 1)
	var destroyed := int(state.units[model].wounds) <= 0
	if destroyed: DetachmentStratagems.record_destroyed(state, model)
	var packet_finished := int(pending.remaining) <= 0 or Geometry.alive(state, target).is_empty()
	if packet_finished and Geometry.alive(state, target).is_empty():
		pending.discarded = int(pending.get("discarded", 0)) + int(pending.remaining)
		pending.remaining = 0
	if destroyed:
		pending.awaiting_destruction = true
		state.unit_abilities.window = {"kind": MORTAL_WINDOW, "owners": [int(pending.get("target_owner", -1))], "target": target}
	elif packet_finished:
		_advance(state)
	if destroyed:
		var demise: Dictionary = DeadlyDemise.begin(state, [model], roller)
		if not str(demise.get("error", "")).is_empty(): return demise
		if not state.get("pending_deadly_demise", {}).is_empty(): return {"error": "", "message": str(demise.get("message", "Resolve the destruction effects."))}
		_advance(state)
	return {"error": "", "message": "Matter Absorption mortal wound allocated."}

static func apply(state: Dictionary, player: int, selected: Dictionary, roller: Callable) -> Dictionary:
	match str(selected.get("action", "")):
		ACTION: return resolve(state, player, selected, roller)
		ALLOCATE: return allocate(state, player, selected, roller)
	return {"error": "Unsupported Matter Absorption action."}

static func resume_after_nested_destruction(state: Dictionary) -> void:
	if not state.get("pending_matter_absorption", {}).is_empty() and state.get("pending_deadly_demise", {}).is_empty() and state.get("unit_abilities", {}).get("window", {}).get("kind", "") == MORTAL_WINDOW:
		_advance(state)
