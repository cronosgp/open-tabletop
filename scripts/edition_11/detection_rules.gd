extends RefCounted
## Dependency-free visibility effects, shared by terrain and unit abilities.
const ABILITY_IMPLEMENTATION_ID := "track-a-current-datasheets-2026-10-v94-hammerfall-bunker"
const EPSILON := 0.001

static func cloaks(state: Dictionary, squad: int) -> bool:
	if state.get("unit_abilities", {}).get("implementation", "") != ABILITY_IMPLEMENTATION_ID: return false
	for model: Dictionary in state.units.values():
		if model.squad != squad or model.wounds <= 0 or not model.get("on_battlefield", true): continue
		if model.get("definition_id", "") == "40kdc:11e:adeptus-astartes:eliminator-squad": return true
	return false

static func detection_range(state: Dictionary, model: int, grounded: bool) -> float:
	var result := 15.0
	if grounded: result -= 3.0
	if cloaks(state, int(state.units[model].squad)): result -= 3.0
	if _has_trifold_path(state, int(state.units[model].squad)): result -= 3.0
	var njal_detection: Dictionary = state.get("unit_abilities", {}).get("njal_storm_caller_detection", {}).get(int(state.units[model].squad), {})
	if njal_detection.get("phase_key", "") == "%d:%s" % [int(state.turn), str(state.phase)]: result -= 3.0
	var optics := selection(state)
	if optics.get("mode", "") == "detect" and optics.get("target", -1) == state.units[model].squad: result += 6.0
	if state.get("unit_abilities", {}).get("implementation", "") == ABILITY_IMPLEMENTATION_ID:
		var mark: Dictionary = state.unit_abilities.get("detected", {}).get(state.units[model].squad, {})
		if mark.get("phase_key", "") == "%d:%s" % [state.turn, state.phase]: result += 3.0
		var terrain_mark: Dictionary = state.unit_abilities.get("priority_target", {})
		var bounds: Array = terrain_mark.get("bounds", [])
		if terrain_mark.get("turn", -1) == state.turn and terrain_mark.get("owner", -1) != state.units[model].owner and bounds.size() == 4:
			var rect := Rect2(Vector2(float(bounds[0]), float(bounds[1])), Vector2(float(bounds[2]), float(bounds[3])))
			var target_unit: Dictionary = state.units[model]
			if target_unit.position.distance_to(target_unit.position.clamp(rect.position, rect.end)) <= float(target_unit.radius) + EPSILON: result += 3.0
	var detachment_state: Dictionary = state.get("detachment_stratagems", {})
	var current_detachment_state := str(detachment_state.get("implementation", "")).begins_with("gladius-awakened-stratagems-11e-v")
	if current_detachment_state and "stormlance" in detachment_state.get("modes", []) and detachment_state.get("spotted", {}).has(int(state.units[model].squad)): result += 3.0
	var skyborne: Dictionary = detachment_state.get("skyborne_surveillance", {}).get(int(state.units[model].squad), {})
	if current_detachment_state and "darkflight-pursuit" in detachment_state.get("modes", []) and skyborne.get("phase_key", "") == "%d:%s" % [int(state.turn), str(state.phase)] and int(skyborne.get("owner", -1)) != int(state.units[model].owner): result += 3.0
	return result

static func stealth(state: Dictionary, squad: int) -> bool:
	if _has_trifold_path(state, squad): return true
	var darkflight_record: Dictionary = state.get("detachment_stratagems", {}).get("wings_shadow", {}).get(squad, {})
	var target_squad: Dictionary = state.get("squads", {}).get(squad, {})
	if not target_squad.is_empty() and int(darkflight_record.get("owner", -1)) == int(target_squad.get("owner", -2)) and state.get("phase", "") == "shooting" and darkflight_record.get("phase_key", "") == "%d:%s" % [int(state.get("turn", 0)), str(state.get("phase", ""))]: return true
	return _every_model_has_stealth(state, squad) or _darkshroud_stealth_aura(state, squad)

static func _darkshroud_stealth_aura(state: Dictionary, target_squad: int) -> bool:
	if state.get("unit_abilities", {}).get("implementation", "") != ABILITY_IMPLEMENTATION_ID or not state.get("squads", {}).has(target_squad): return false
	var target_owner := int(state.squads[target_squad].get("owner", -1))
	var all_dark_angels_astartes := true
	var target_found := false
	for target_model: int in state.get("units", {}):
		var target: Dictionary = state.units[target_model]
		if int(target.get("squad", -1)) != target_squad or int(target.get("wounds", 0)) <= 0 or not target.get("on_battlefield", true): continue
		target_found = true
		var keywords: Array = target.get("keywords", [])
		var dark_angels := "DARK ANGELS" in keywords or ("ADEPTUS ASTARTES" in keywords and str(state.get("marine_chapters", {}).get(target_owner, "")) == "DARK ANGELS")
		if not dark_angels or "ADEPTUS ASTARTES" not in keywords:
			all_dark_angels_astartes = false
			break
	if not target_found or not all_dark_angels_astartes: return false
	for source_model: int in state.get("units", {}):
		var source: Dictionary = state.units[source_model]
		if int(source.get("owner", -1)) != target_owner or int(source.get("wounds", 0)) <= 0 or not source.get("on_battlefield", true): continue
		if str(source.get("definition_id", "")).get_slice(":", 3) != "ravenwing-darkshroud": continue
		for target_model: int in state.get("units", {}):
			var target: Dictionary = state.units[target_model]
			if int(target.get("squad", -1)) != target_squad or int(target.get("wounds", 0)) <= 0 or not target.get("on_battlefield", true): continue
			var edge_distance := maxf(0.0, source.get("position", Vector2.ZERO).distance_to(target.get("position", Vector2.ZERO)) - float(source.get("radius", 0.0)) - float(target.get("radius", 0.0)))
			if edge_distance <= 6.0 + EPSILON: return true
	return false

static func _has_trifold_path(state: Dictionary, squad: int) -> bool:
	if state.get("unit_abilities", {}).get("implementation", "") != ABILITY_IMPLEMENTATION_ID: return false
	for model: Dictionary in state.units.values():
		if model.squad == squad and model.wounds > 0 and model.get("on_battlefield", true) and str(model.get("definition_id", "")).get_slice(":", 3) == "kayvaan-shrike": return true
	return false

static func infiltrators(state: Dictionary, squad: int) -> bool:
	if state.get("unit_abilities", {}).get("implementation", "") != ABILITY_IMPLEMENTATION_ID: return false
	var found := false
	for model: Dictionary in state.units.values():
		if model.squad != squad or model.wounds <= 0 or not model.get("on_battlefield", true): continue
		if str(model.get("definition_id", "")).get_slice(":", 3) not in ["eliminator-squad", "infiltrator-squad", "scout-squad", "wolf-scouts", "spectrus-kill-team", "lieutenant-in-phobos-armour", "librarian-in-phobos-armour", "captain-in-phobos-armour", "lieutenant-with-combi-weapon"]: return false
		found = true
	return found

static func _every_eliminator(state: Dictionary, squad: int) -> bool:
	if state.get("unit_abilities", {}).get("implementation", "") != ABILITY_IMPLEMENTATION_ID: return false
	var found := false
	for model: Dictionary in state.units.values():
		if model.squad != squad or model.wounds <= 0 or not model.get("on_battlefield", true): continue
		# Only the reviewed Eliminator identity currently supplies this ability.
		if model.get("definition_id", "") != "40kdc:11e:adeptus-astartes:eliminator-squad": return false
		found = true
	return found

static func _every_model_has_stealth(state: Dictionary, squad: int) -> bool:
	if state.get("unit_abilities", {}).get("implementation", "") != ABILITY_IMPLEMENTATION_ID: return false
	var found := false
	for model: Dictionary in state.units.values():
		if model.squad != squad or model.wounds <= 0 or not model.get("on_battlefield", true): continue
		if str(model.get("definition_id", "")).get_slice(":", 3) not in ["eliminator-squad", "librarian-in-phobos-armour", "captain-in-phobos-armour", "lieutenant-with-combi-weapon", "aethon-shaan", "corvus-blackstar"]: return false
		found = true
	return found

static func selection(state: Dictionary) -> Dictionary:
	if state.get("unit_abilities", {}).get("implementation", "") != ABILITY_IMPLEMENTATION_ID: return {}
	var selected: Dictionary = state.unit_abilities.get("optics", {})
	if selected.is_empty() or state.phase != "shooting" or selected.get("phase_key", "") != "%d:%s" % [state.turn, state.phase]: return {}
	var squad: int = selected.get("squad", -1)
	if not state.squads.has(squad) or state.squads[squad].shot or state.squads[squad].owner != state.active: return {}
	return selected
