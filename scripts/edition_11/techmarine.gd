extends RefCounted
## Techmarine rules from the local Wahapedia 11e extraction.
const Geometry = preload("res://scripts/edition_11/contact_movement.gd")
const RandomStat = preload("res://scripts/edition_11/random_characteristic.gd")
const Capabilities = preload("res://scripts/edition_11/capabilities.gd")
const Traits = preload("res://scripts/edition_11/weapon_traits.gd")

static func identity(unit: Dictionary) -> String:
	return str(unit.get("definition_id", "")).get_slice(":", 3)

static func models(state: Dictionary, owner: int) -> Array[int]:
	var result: Array[int] = []
	for model: int in state.units:
		var unit: Dictionary = state.units[model]
		if int(unit.get("owner", 0)) == owner and int(unit.get("wounds", 0)) > 0 and unit.get("on_battlefield", true) and identity(unit) in ["techmarine", "iron-father-feirros"]:
			result.append(model)
	return result

static func astartes_vehicle(unit: Dictionary) -> bool:
	var keywords: Array = unit.get("keywords", [])
	var marine_faction := str(unit.get("definition_id", "")).begins_with("40kdc:11e:adeptus-astartes:") or "ADEPTUS ASTARTES" in keywords
	return "VEHICLE" in keywords and marine_faction

static func space_wolves_vehicle(state: Dictionary, squad: int) -> bool:
	if not state.get("squads", {}).has(squad): return false
	var keywords := Traits.target_keywords(state, squad)
	return "VEHICLE" in keywords and "SPACE WOLVES" in keywords

static func _repair_ability(source: int, state: Dictionary) -> String:
	if not state.get("units", {}).has(source): return ""
	match identity(state.units[source]):
		"iron-priest": return "gift-of-the-iron-wolf"
		"iron-father-feirros": return "master-of-the-forge"
		"techmarine": return "blessings-of-the-omnissiah"
	return ""

static func _nearby_vehicle_targets(state: Dictionary, source: int) -> Array[int]:
	var result: Array[int] = []
	if not state.get("units", {}).has(source): return result
	var bearer: Dictionary = state.units[source]
	var source_identity := identity(bearer)
	if int(bearer.get("wounds", 0)) <= 0 or not bearer.get("on_battlefield", true) or source_identity not in ["techmarine", "iron-father-feirros", "iron-priest"]: return result
	for model: int in state.units:
		var target: Dictionary = state.units[model]
		if model == source or int(target.get("owner", 0)) != int(bearer.owner) or int(target.get("wounds", 0)) <= 0 or not target.get("on_battlefield", true): continue
		var valid_vehicle := space_wolves_vehicle(state, int(target.get("squad", -1))) if source_identity == "iron-priest" else astartes_vehicle(target)
		if valid_vehicle and Geometry.edge(bearer, target) <= 3.001: result.append(model)
	return result

static func _target_used_key(ability: String, turn: int, phase: String, target: int) -> String:
	return "vehicle-repair-target:%s:%d:%s:%d" % [ability, turn, phase, target]

static func vehicle_targets(state: Dictionary, source: int) -> Array[int]:
	var result: Array[int] = []
	var ability := _repair_ability(source, state)
	if ability.is_empty(): return result
	for model: int in _nearby_vehicle_targets(state, source):
		if not state.get("unit_abilities", {}).get("used", {}).get(_target_used_key(ability, int(state.get("turn", -1)), str(state.get("phase", "")), model), false): result.append(model)
	return result

static func lone_operative_active(state: Dictionary, model: int) -> bool:
	if not state.units.has(model) or identity(state.units[model]) not in ["techmarine", "iron-father-feirros", "iron-priest"]: return false
	if state.squads[int(state.units[model].squad)].get("attached", false): return false
	return not _nearby_vehicle_targets(state, model).is_empty()

static func _used_key(squad: int, turn: int) -> String:
	return "blessings:%d:%d" % [squad, turn]

static func _source_in_squad(state: Dictionary, squad: int) -> int:
	for model: int in Geometry.alive(state, squad):
		if identity(state.units[model]) in ["techmarine", "iron-father-feirros", "iron-priest"]: return model
	return -1

static func open_for_move(state: Dictionary, squad: int, moment: String) -> bool:
	if not state.has("unit_abilities"): return false
	if state.phase != "movement" or not state.squads.has(squad) or state.squads[squad].owner != state.active: return false
	if moment not in ["start", "end"]: return false
	if moment == "start" and (state.pending_move.get("squad", -1) != squad or state.squads[squad].moved): return false
	if moment == "end" and not state.squads[squad].moved: return false
	if moment == "end" and state.squads[squad].get("move_type", "") not in ["normal", "advance", "ordered_retreat", "desperate_escape"]: return false
	var source := _source_in_squad(state, squad)
	if source < 0 or state.unit_abilities.used.get(_used_key(squad, state.turn), false): return false
	var targets := vehicle_targets(state, source)
	if targets.is_empty(): return false
	var previous: Dictionary = state.unit_abilities.get("window", {}).duplicate(true)
	state.unit_abilities.window = {"kind": "blessings-of-the-omnissiah", "owners": [state.active], "squad": squad, "source": source,
		"moment": moment, "targets": targets, "resume_window": previous}
	return true

static func choices(state: Dictionary, player: int) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var window: Dictionary = state.get("unit_abilities", {}).get("window", {})
	if window.get("kind", "") != "blessings-of-the-omnissiah" or int(window.get("owners", [0])[0]) != player: return result
	var source_identity := identity(state.units[int(window.source)]) if state.units.has(int(window.source)) else ""
	var iron_priest := source_identity == "iron-priest"
	var iron_father: bool = source_identity == "iron-father-feirros"
	var ability := "Gift of the Iron Wolf" if iron_priest else "Master of the Forge" if iron_father else "Blessings of the Omnissiah"
	var restore_text := "3" if iron_father else "D3"
	var repair_action := "gift-of-the-iron-wolf" if iron_priest else "master-of-the-forge" if iron_father else "blessings-of-the-omnissiah"
	var defer_action := "gift-of-the-iron-wolf-defer" if iron_priest else "master-forge-defer" if iron_father else "blessings-defer"
	var pass_action := "gift-of-the-iron-wolf-pass" if iron_priest else "master-forge-pass" if iron_father else "blessings-pass"
	for target: int in window.get("targets", []):
		if not state.units.has(target) or int(state.units[target].get("wounds", 0)) <= 0: continue
		result.append({"label": "%s: heal %s (%s) and ignore hit/wound modifiers" % [ability, state.squads[state.units[target].squad].name, restore_text],
			"action": repair_action, "model": int(window.source), "target": target, "value": str(window.moment)})
	result.append({"label": "Defer %s until the end of this move" % ability if window.moment == "start" else "Decline %s" % ability,
		"action": defer_action if window.moment == "start" else pass_action, "model": int(window.source), "target": int(window.squad), "value": str(window.moment)})
	return result

static func modifier_ignore_active(state: Dictionary, model: int) -> bool:
	if state.units.has(model):
		var squad: int = int(state.units[model].get("squad", -1))
		var spirit: Dictionary = state.get("detachment_stratagems", {}).get("might_machine_spirit", {}).get(squad, {})
		if Capabilities.enabled(state, "ironstorm-might-of-the-machine-spirit") and not spirit.is_empty() and int(state.units[model].get("owner", -1)) == int(spirit.get("owner", -2)) and int(state.turn) < int(spirit.get("expires_turn", -1)): return true
	var marks: Dictionary = state.get("unit_abilities", {}).get("techmarine_blessings", {})
	var mark: Dictionary = marks.get(model, {})
	return not mark.is_empty() and state.units.has(model) and int(state.units[model].get("owner", 0)) == int(mark.get("owner", -1)) and int(state.turn) < int(mark.get("expires_turn", -1))

static func characteristic_modifier_ignore_active(state: Dictionary, model: int) -> bool:
	if not state.units.has(model): return false
	var mark: Dictionary = state.get("unit_abilities", {}).get("techmarine_blessings", {}).get(model, {})
	var source := int(mark.get("source", -1))
	return not mark.is_empty() and state.units.has(source) and identity(state.units[source]) == "iron-father-feirros" and int(state.units[model].get("owner", 0)) == int(mark.get("owner", -1)) and int(state.turn) < int(mark.get("expires_turn", -1))

static func apply(state: Dictionary, player: int, selected: Dictionary, roller: Callable) -> Dictionary:
	var window: Dictionary = state.get("unit_abilities", {}).get("window", {})
	if window.get("kind", "") != "blessings-of-the-omnissiah" or int(window.get("owners", [0])[0]) != player: return {"error": "No matching Blessings of the Omnissiah decision is pending."}
	var source := int(window.get("source", -1))
	var target := int(selected.get("target", -1))
	if int(selected.get("model", -1)) != source or not state.units.has(source) or identity(state.units[source]) not in ["techmarine", "iron-father-feirros", "iron-priest"]: return {"error": "This repair choice belongs to its pending Techmarine, Iron Father or Iron Priest."}
	var source_identity := identity(state.units[source])
	var iron_priest := source_identity == "iron-priest"
	var iron_father: bool = source_identity == "iron-father-feirros"
	var ability := _repair_ability(source, state)
	var action: String = str(selected.get("action", ""))
	var defer_action := "gift-of-the-iron-wolf-defer" if iron_priest else "master-forge-defer" if iron_father else "blessings-defer"
	var pass_action := "gift-of-the-iron-wolf-pass" if iron_priest else "master-forge-pass" if iron_father else "blessings-pass"
	var repair_action := "gift-of-the-iron-wolf" if iron_priest else "master-of-the-forge" if iron_father else "blessings-of-the-omnissiah"
	if action in [defer_action, pass_action]:
		if action == defer_action and window.get("moment", "") != "start": return {"error": "This repair can only be deferred from the start of this move."}
		state.unit_abilities.window = window.get("resume_window", {})
		return {"error": ""}
	var target_text := "Space Wolves Vehicle" if iron_priest else "Adeptus Astartes Vehicle"
	if action != repair_action or target not in vehicle_targets(state, source): return {"error": "Select a friendly %s model within 3 inches." % target_text}
	var squad: int = int(state.units[source].squad)
	var used_key := _used_key(squad, int(state.turn))
	if state.unit_abilities.used.get(used_key, false): return {"error": "This vehicle repair ability was already used during this unit's move."}
	var target_used_key := _target_used_key(ability, int(state.turn), str(state.phase), target)
	if state.unit_abilities.used.get(target_used_key, false): return {"error": "This Vehicle model has already been selected for this ability this phase."}
	var restored_amount := 3
	var rolled := {"error": "", "value": 3, "roll": []} if iron_father else RandomStat.roll("D3", roller)
	if not rolled.error.is_empty(): return rolled
	if not iron_father: restored_amount = int(rolled.value)
	var vehicle: Dictionary = state.units[target]
	var restored := mini(restored_amount, maxi(0, int(vehicle.max_wounds) - int(vehicle.wounds)))
	vehicle.wounds += restored
	if not state.unit_abilities.has("techmarine_blessings"): state.unit_abilities.techmarine_blessings = {}
	state.unit_abilities.techmarine_blessings[target] = {"owner": player, "source": source, "ability": ability, "phase_key": "%d:%s" % [state.turn, state.phase], "expires_turn": int(state.turn) + 2}
	state.unit_abilities.used[used_key] = true
	state.unit_abilities.used[target_used_key] = true
	state.unit_abilities.window = window.get("resume_window", {})
	var ability_name := "Gift of the Iron Wolf" if iron_priest else "Master of the Forge" if iron_father else "Blessings of the Omnissiah"
	return {"error": "", "message": "%s: %s healed %d wound(s) and can ignore Hit/Wound modifiers until turn %d Movement." % [ability_name, state.squads[vehicle.squad].name, restored, int(state.turn) + 2], "restored": restored, "roll": rolled}

static func judgement_applies(state: Dictionary, attacker_model: int, target_squad: int) -> bool:
	if not state.get("units", {}).has(attacker_model) or not state.get("squads", {}).has(target_squad): return false
	var attacker: Dictionary = state.units[attacker_model]
	if identity(attacker) != "iron-priest" or int(attacker.get("wounds", 0)) <= 0 or not attacker.get("on_battlefield", true): return false
	var owner := int(attacker.get("owner", -1))
	if owner == int(state.squads[target_squad].get("owner", -2)): return false
	for vehicle_squad: int in state.squads:
		if vehicle_squad == int(attacker.get("squad", -1)) or int(state.squads[vehicle_squad].get("owner", -2)) != owner: continue
		if not space_wolves_vehicle(state, vehicle_squad): continue
		for vehicle_model: int in Geometry.alive(state, vehicle_squad):
			for enemy_model: int in Geometry.alive(state, target_squad):
				if Geometry.within_engagement(state.units[vehicle_model], state.units[enemy_model]): return true
	return false
