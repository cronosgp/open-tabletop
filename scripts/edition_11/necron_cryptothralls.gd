extends RefCounted
## Source-bounded Cryptothralls: Bound Creation, Systematic Vigour and Cryptek Retinue.
const Geometry = preload("res://scripts/edition_11/contact_movement.gd")
const AbilityCatalog = preload("res://scripts/edition_11/unit_ability_catalog.gd")
const DetachmentStratagems = preload("res://scripts/edition_11/detachment_stratagems.gd")

const IDENTITY := "cryptothralls"
const RETINUE_ACTION := "cryptothralls-retinue"
const FIGHT_ACTION := "systematic-vigour-fight"
const PASS_ACTION := "systematic-vigour-pass"
const WINDOW := "systematic-vigour"
const CRYPTEK_LEADERS := ["orikan-the-diviner", "plasmancer", "technomancer", "psychomancer", "chronomancer", "geomancer", "illuminor-szeras"]

static func _phase_key(state: Dictionary) -> String:
	return "%d:%s" % [int(state.get("turn", 0)), str(state.get("phase", ""))]

static func _has_keyword(unit: Dictionary, keyword: String) -> bool:
	for value: Variant in unit.get("keywords", []):
		if str(value).strip_edges().to_upper() == keyword.to_upper(): return true
	return false

static func _is_leading_cryptek(unit: Dictionary) -> bool:
	if AbilityCatalog.identity(unit) not in CRYPTEK_LEADERS or not _has_keyword(unit, "CRYPTEK"): return false
	return str(unit.get("attachment_role", "")) in ["leader", "support"]

static func bound_creation_grants(state: Dictionary, model: int) -> Array:
	var result: Array = []
	if not AbilityCatalog.enabled(state) or not state.get("units", {}).has(model): return result
	var unit: Dictionary = state.units[model]
	if not _has_keyword(unit, "CRYPTEK") or int(unit.get("wounds", 0)) <= 0: return result
	var squad := int(unit.get("squad", -1))
	if not state.get("squads", {}).has(squad): return result
	for member: int in Geometry.alive(state, squad):
		if AbilityCatalog.identity(state.units[member]) != IDENTITY: continue
		if AbilityCatalog.sources(state, squad, "bound-creation").is_empty(): continue
		result.append({"target": 4, "against": "any"})
		return result
	return result

static func hold_destroyed(state: Dictionary, model: int, roller: Callable) -> Dictionary:
	if not AbilityCatalog.enabled(state) or not state.get("units", {}).has(model): return {"error": "", "held": false}
	var unit: Dictionary = state.units[model]
	if AbilityCatalog.identity(unit) != IDENTITY or int(unit.get("wounds", 0)) > 0 or bool(unit.get("lingering", false)): return {"error": "", "held": false}
	var squad := int(unit.get("squad", -1))
	if str(state.get("phase", "")) != "fight" or not state.get("squads", {}).has(squad) or bool(state.squads[squad].get("fought", false)): return {"error": "", "held": false}
	if AbilityCatalog.sources(state, squad, "systematic-vigour").is_empty(): return {"error": "", "held": false}
	var pending: Dictionary = state.get("pending_attack", {})
	if pending.is_empty() or not bool(pending.get("melee", false)): return {"error": "", "held": false}
	var attacker := int(pending.get("squad", -1))
	if not state.get("squads", {}).has(attacker) or int(state.squads[attacker].get("owner", -1)) == int(unit.get("owner", -2)): return {"error": "", "held": false}
	if not roller.is_valid(): return {"error": "Systematic Vigour requires the host's D6."}
	var roll: Variant = roller.call()
	if not roll is int or roll < 1 or roll > 6: return {"error": "Systematic Vigour dice must be 1–6."}
	if int(roll) < 2:
		DetachmentStratagems.record_destroyed(state, model)
		return {"error": "", "held": false, "rule": "systematic-vigour", "rule_name": "Systematic Vigour", "roll": roll, "modifier": 0}
	unit.wounds = 1
	unit.lingering = true
	unit.systematic_vigour_lingering = true
	if not state.get("unit_abilities", {}).has("systematic_vigour_triggers"):
		state.unit_abilities.systematic_vigour_triggers = []
	var triggers: Array = state.unit_abilities.systematic_vigour_triggers.duplicate(true)
	triggers.append({"model": model, "owner": int(unit.get("owner", -1)), "attacker": attacker, "squad": squad, "phase_key": _phase_key(state)})
	state.unit_abilities.systematic_vigour_triggers = triggers
	return {"error": "", "held": true, "rule": "systematic-vigour", "rule_name": "Systematic Vigour", "roll": roll, "modifier": 0}

static func after_attacker_fight(state: Dictionary, attacker: int) -> bool:
	if not AbilityCatalog.enabled(state) or str(state.get("phase", "")) != "fight" or not state.get("squads", {}).has(attacker): return false
	var pending: Array = state.get("unit_abilities", {}).get("systematic_vigour_triggers", []).duplicate(true)
	var queue: Array = []
	var remaining: Array = []
	for record: Variant in pending:
		if not record is Dictionary: continue
		var model := int(record.get("model", -1))
		if int(record.get("attacker", -1)) == attacker and str(record.get("phase_key", "")) == _phase_key(state) and state.get("units", {}).has(model) and bool(state.units[model].get("systematic_vigour_lingering", false)):
			queue.append(record)
		else:
			remaining.append(record)
	state.unit_abilities.systematic_vigour_triggers = remaining
	if queue.is_empty(): return false
	var previous: Dictionary = state.get("unit_abilities", {}).get("window", {}).duplicate(true)
	state.unit_abilities.window = {"kind": WINDOW, "owners": [int(queue[0].get("owner", -1))], "queue": queue, "resume_window": previous, "phase_key": _phase_key(state)}
	return true

static func choices(state: Dictionary, player: int) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var window: Dictionary = state.get("unit_abilities", {}).get("window", {})
	if str(window.get("kind", "")) != WINDOW or window.get("owners", []) != [player] or str(window.get("phase_key", "")) != _phase_key(state): return result
	var queue: Array = window.get("queue", [])
	if queue.is_empty(): return result
	var trigger: Dictionary = queue[0]
	var model := int(trigger.get("model", -1))
	var attacker := int(trigger.get("attacker", -1))
	if state.get("units", {}).has(model) and bool(state.units[model].get("systematic_vigour_lingering", false)):
		result.append({"label": "Systematic Vigour: Cryptothrall %d fights now" % model, "action": FIGHT_ACTION, "model": model, "target": attacker, "value": "fight"})
	result.append({"label": "Pass Systematic Vigour for Cryptothrall %d" % model, "action": PASS_ACTION, "model": model, "target": attacker, "value": "pass"})
	return result

static func _advance_window(state: Dictionary, window: Dictionary) -> Dictionary:
	var queue: Array = window.get("queue", []).duplicate(true)
	if not queue.is_empty(): queue.pop_front()
	if queue.is_empty(): return window.get("resume_window", {})
	window.queue = queue
	window.owners = [int(queue[0].get("owner", -1))]
	return window

static func _remove_model(state: Dictionary, model: int) -> void:
	if not state.get("units", {}).has(model): return
	var unit: Dictionary = state.units[model]
	unit.wounds = 0
	unit.erase("systematic_vigour_lingering")
	unit.erase("lingering")
	DetachmentStratagems.record_destroyed(state, model)

static func apply(state: Dictionary, player: int, selected: Dictionary) -> Dictionary:
	if selected not in choices(state, player): return {"error": "Systematic Vigour is available only after the enemy unit that destroyed this Cryptothrall has finished its attacks."}
	var window: Dictionary = state.unit_abilities.window.duplicate(true)
	var trigger: Dictionary = window.queue[0]
	var model := int(trigger.get("model", -1))
	var attacker := int(trigger.get("attacker", -1))
	var squad := int(trigger.get("squad", -1))
	if str(selected.get("action", "")) == PASS_ACTION:
		_remove_model(state, model)
		state.unit_abilities.window = _advance_window(state, window)
		return {"error": "", "message": "Systematic Vigour was passed; Cryptothrall %d is removed." % model}
	if not state.get("units", {}).has(model) or not bool(state.units[model].get("systematic_vigour_lingering", false)):
		state.unit_abilities.window = _advance_window(state, window)
		return {"error": "That Cryptothrall is no longer eligible for Systematic Vigour."}
	var previous_fought := bool(state.squads[squad].get("fought", false)) if state.get("squads", {}).has(squad) else true
	state.unit_abilities.systematic_vigour_active = {"model": model, "squad": squad, "attacker": attacker, "previous_fought": previous_fought, "phase_key": _phase_key(state)}
	if state.get("squads", {}).has(squad): state.squads[squad].fought = false
	state.fight_actor = player
	state.fight_selected = squad
	state.fight_step = "attacks"
	state.unit_abilities.window = _advance_window(state, window)
	return {"error": "", "message": "Systematic Vigour: Cryptothrall %d may fight now, then is removed." % model}

static func finish_active_fight(state: Dictionary, squad: int) -> void:
	var active: Dictionary = state.get("unit_abilities", {}).get("systematic_vigour_active", {})
	if active.is_empty() or int(active.get("squad", -1)) != squad or str(active.get("phase_key", "")) != _phase_key(state): return
	var model := int(active.get("model", -1))
	_remove_model(state, model)
	if state.get("squads", {}).has(squad):
		state.squads[squad].fought = bool(active.get("previous_fought", true))
	state.unit_abilities.erase("systematic_vigour_active")

static func active_model(state: Dictionary) -> int:
	var active: Dictionary = state.get("unit_abilities", {}).get("systematic_vigour_active", {})
	if active.is_empty() or str(active.get("phase_key", "")) != _phase_key(state): return -1
	return int(active.get("model", -1))

static func retinue_error(state: Dictionary, model: int, target: int) -> String:
	if state.get("phase", "") != "deployment" or int(state.get("active", -1)) not in [1, 2] or state.get("unit_abilities", {}).get("setup_players", []).has(int(state.get("active", -1))):
		return "Cryptek Retinue is declared during Declare Battle Formations."
	if not state.get("units", {}).has(model) or not state.get("squads", {}).has(target): return "Choose a Cryptothralls unit and an eligible friendly unit."
	var source: Dictionary = state.units[model]
	var origin := int(source.get("squad", -1))
	if AbilityCatalog.identity(source) != IDENTITY or origin == target or not state.get("squads", {}).has(origin): return "Choose a separate Cryptothralls unit."
	var player := int(state.get("active", -1))
	if int(source.get("owner", -1)) != player or int(state.squads[target].get("owner", -1)) != player: return "Cryptek Retinue can join only a friendly unit."
	if bool(state.squads[origin].get("attached", false)) or state.get("unit_abilities", {}).get("reserves", {}).has(origin) or state.get("unit_abilities", {}).get("reserves", {}).has(target): return "Cryptek Retinue requires units that are not already attached or in Reserves."
	var thrall_models := 0
	for member: int in state.get("units", {}):
		var unit: Dictionary = state.units[member]
		if int(unit.get("squad", -1)) != origin: continue
		if AbilityCatalog.identity(unit) != IDENTITY or int(unit.get("wounds", 0)) <= 0: return "Cryptek Retinue requires the intact two-model Cryptothralls unit."
		thrall_models += 1
	if thrall_models != 2 or int(state.squads[origin].get("starting_strength", 0)) != 2: return "Cryptek Retinue requires the intact two-model Cryptothralls unit."
	if not state.squads[target].get("attached", false): return "Cryptek Retinue can join only a unit already led by a Cryptek model."
	var has_cryptek_leader := false
	for member: int in state.get("units", {}):
		var unit: Dictionary = state.units[member]
		if int(unit.get("squad", -1)) != target: continue
		if unit.get("wounds", 0) > 0 and _is_leading_cryptek(unit): has_cryptek_leader = true
		var identity := AbilityCatalog.identity(unit)
		if identity in [IDENTITY, "canoptek-tomb-crawlers"]: return "A unit cannot include both Cryptothralls and Canoptek Tomb Crawlers, or more than one Cryptothralls unit."
	if not has_cryptek_leader: return "Cryptek Retinue can join only a unit already led by a Cryptek model."
	return ""

static func retinue_choices(state: Dictionary, player: int) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if state.get("phase", "") != "deployment" or int(state.get("active", -1)) != player or state.get("unit_abilities", {}).get("setup_players", []).has(player): return result
	var seen_origins: Dictionary = {}
	for model: int in state.get("units", {}):
		var unit: Dictionary = state.units[model]
		if int(unit.get("owner", -1)) != player or int(unit.get("wounds", 0)) <= 0 or AbilityCatalog.identity(unit) != IDENTITY: continue
		var origin := int(unit.get("squad", -1))
		if seen_origins.has(origin): continue
		seen_origins[origin] = true
		for target: int in state.get("squads", {}):
			if not retinue_error(state, model, target).is_empty(): continue
			result.append({"label": "Cryptek Retinue: join %s to %s" % [str(state.squads[origin].get("name", "Cryptothralls")), str(state.squads[target].get("name", "Cryptek-led unit"))], "action": RETINUE_ACTION, "model": model, "target": target, "value": "join"})
	return result
