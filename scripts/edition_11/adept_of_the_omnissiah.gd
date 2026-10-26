extends RefCounted
## Adept of the Omnissiah from the Medusa's Wrath enhancement.
const WINDOW := "medusa-adept-of-the-omnissiah"
const USE := "adept-omnissiah-use"
const PASS := "adept-omnissiah-pass"
const Enhancement = preload("res://scripts/edition_11/stormlance_enhancements.gd")
const Techmarine = preload("res://scripts/edition_11/techmarine.gd")
const Geometry = preload("res://scripts/edition_11/contact_movement.gd")
const Doctrines = preload("res://scripts/edition_11/combat_doctrines.gd")
const AbilityCatalog = preload("res://scripts/edition_11/unit_ability_catalog.gd")

static func eligible_targets(state: Dictionary, attacker_squad: int, targets: Array) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if not state.get("squads", {}).has(attacker_squad): return result
	var attacker_owner := int(state.squads[attacker_squad].get("owner", -1))
	var used: Dictionary = state.get("marine_enhancements", {}).get("adept_used", {})
	var defender_owner := -1
	var round_number := int(state.get("round", 0))
	for target_value: Variant in targets:
		var target_squad := int(target_value)
		if not state.get("squads", {}).has(target_squad): continue
		var owner := int(state.squads[target_squad].get("owner", -1))
		if owner == attacker_owner or owner <= 0 or used.get(owner, -1) == round_number: continue
		if not _context_enabled(state, owner): continue
		if defender_owner >= 0 and defender_owner != owner: continue
		var vehicle := false
		for target_model: int in Geometry.alive(state, target_squad):
			if not state.units[target_model].get("on_battlefield", true): continue
			if Techmarine.astartes_vehicle(state.units[target_model]):
				vehicle = true
				break
		if not vehicle: continue
		# Search friendly bearer squads after confirming the target is an eligible Vehicle.
		for bearer: int in state.units:
			var unit: Dictionary = state.units[bearer]
			if int(unit.get("owner", -1)) != owner or int(unit.get("wounds", 0)) <= 0 or not unit.get("on_battlefield", true): continue
			if Techmarine.identity(unit) != "techmarine" or not Enhancement.adept_of_the_omnissiah_bearer(state, bearer): continue
			var bearer_squad := int(unit.get("squad", -1))
			if not _units_within_range(state, bearer_squad, target_squad, 6.001): continue
			var duplicate := false
			for row: Dictionary in result:
				if int(row.get("target", -1)) == target_squad:
					duplicate = true
					break
			if not duplicate:
				result.append({"owner": owner, "model": bearer, "target": target_squad, "attacker_squad": attacker_squad})
			defender_owner = owner
			break
	return result

static func _context_enabled(state: Dictionary, owner: int) -> bool:
	if not AbilityCatalog.enabled(state) or not Doctrines.enabled(state): return false
	if not Enhancement.detachment_active(state, Enhancement.MEDUSA_WRATH, owner): return false
	if Doctrines.detachment_for(state, owner) != Enhancement.MEDUSA_WRATH: return false
	if owner not in state.get("combat_doctrines", {}).get("owners", []): return false
	var chapters: Dictionary = state.get("marine_chapters", {})
	return str(chapters.get(owner, chapters.get(str(owner), ""))) == "IRON HANDS"

static func _units_within_range(state: Dictionary, first_squad: int, second_squad: int, inches: float) -> bool:
	if not state.get("squads", {}).has(first_squad) or not state.get("squads", {}).has(second_squad): return false
	for first: int in Geometry.alive(state, first_squad):
		if not state.units[first].get("on_battlefield", true): continue
		for second: int in Geometry.alive(state, second_squad):
			if not state.units[second].get("on_battlefield", true): continue
			if Geometry.edge(state.units[first], state.units[second]) <= inches: return true
	return false

static func choices(state: Dictionary, player: int) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var window: Dictionary = state.get("unit_abilities", {}).get("window", {})
	if window.get("kind", "") != WINDOW or window.get("owners", []) != [player]: return result
	for row: Dictionary in window.get("candidates", []):
		var target := int(row.get("target", -1))
		var attacker := int(row.get("attacker_squad", -1))
		if not state.get("squads", {}).has(target) or not state.get("squads", {}).has(attacker): continue
		result.append({"label": "Adept of the Omnissiah: give %s Feel No Pain 5+ against %s's attacks" % [str(state.squads[target].get("name", "Vehicle")), str(state.squads[attacker].get("name", "the attacker"))],
			"action": USE, "model": int(row.get("model", -1)), "target": target, "value": str(attacker)})
	result.append({"label": "Decline Adept of the Omnissiah for this attack", "action": PASS, "model": -1, "target": -1, "value": ""})
	return result

static func apply(state: Dictionary, player: int, selected: Dictionary) -> Dictionary:
	var window: Dictionary = state.get("unit_abilities", {}).get("window", {})
	if window.get("kind", "") != WINDOW or window.get("owners", []) != [player]: return {"error": "No matching Adept of the Omnissiah decision is pending."}
	var declaration: Dictionary = window.get("declaration", {}).duplicate(true)
	if declaration.get("kind", "") != "attack" or int(declaration.get("player", -1)) == player: return {"error": "Adept of the Omnissiah requires the pending enemy attack declaration."}
	var action := str(selected.get("action", ""))
	if action == PASS:
		state.unit_abilities.window = {}
		return {"error": "", "resume_declaration": declaration}
	if action != USE: return {"error": "Choose a Vehicle or decline Adept of the Omnissiah."}
	var target := int(selected.get("target", -1))
	var source := int(selected.get("model", -1))
	var candidates := eligible_targets(state, int(declaration.get("squad", -1)), [target])
	var valid := false
	for row: Dictionary in candidates:
		if int(row.get("model", -1)) == source and int(row.get("target", -1)) == target:
			valid = true
			break
	if not valid: return {"error": "Select a Vehicle within 6 inches of the living Adeptus of the Omnissiah bearer."}
	var owner := int(state.squads[target].get("owner", -1))
	if not state.has("marine_enhancements"): state.marine_enhancements = {}
	if not state.marine_enhancements.has("adept_used"): state.marine_enhancements.adept_used = {}
	state.marine_enhancements.adept_used[owner] = int(state.get("round", 0))
	state.marine_enhancements.adept_active = {"owner": owner, "target": target, "attacker_squad": int(declaration.get("squad", -1)),
		"source": source, "round": int(state.get("round", 0)), "attack_id": str(declaration.get("resolution_action_id", ""))}
	state.unit_abilities.window = {}
	return {"error": "", "resume_declaration": declaration,
		"message": "Adept of the Omnissiah: %s has Feel No Pain 5+ against this enemy unit's attacks until it finishes attacking." % str(state.squads[target].get("name", "The Vehicle"))}

static func active_for_attack(state: Dictionary, attacker_squad: int, target_squad: int) -> bool:
	var effect: Dictionary = state.get("marine_enhancements", {}).get("adept_active", {})
	return not effect.is_empty() and int(effect.get("attacker_squad", -1)) == attacker_squad and int(effect.get("target", -1)) == target_squad

static func active_for_damage(state: Dictionary, target_squad: int) -> bool:
	var attack: Dictionary = state.get("pending_attack", {})
	if attack.is_empty() or int(attack.get("current", {}).get("target", -1)) != target_squad: return false
	if not active_for_attack(state, int(attack.get("squad", -1)), target_squad): return false
	var expected_id := str(state.get("marine_enhancements", {}).get("adept_active", {}).get("attack_id", ""))
	return expected_id.is_empty() or expected_id == str(attack.get("resolution_action_id", ""))

static func clear_after_attack(state: Dictionary, attacker_squad: int) -> void:
	var effect: Dictionary = state.get("marine_enhancements", {}).get("adept_active", {})
	if not effect.is_empty() and int(effect.get("attacker_squad", -1)) == attacker_squad:
		state.marine_enhancements.adept_active = {}
