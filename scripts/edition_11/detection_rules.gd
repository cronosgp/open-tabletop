extends RefCounted
## Dependency-free visibility effects, shared by terrain and unit abilities.
const ABILITY_IMPLEMENTATION_ID := "track-a-current-datasheets-2026-10-v56-vulkan-hestan"
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
	if state.get("detachment_stratagems", {}).get("implementation", "") == "gladius-awakened-stratagems-11e-v5" and state.get("detachment_stratagems", {}).get("spotted", {}).has(int(state.units[model].squad)): result += 3.0
	return result

static func stealth(state: Dictionary, squad: int) -> bool:
	if _has_trifold_path(state, squad): return true
	return _every_model_has_stealth(state, squad)

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
		if str(model.get("definition_id", "")).get_slice(":", 3) not in ["eliminator-squad", "infiltrator-squad", "scout-squad", "lieutenant-in-phobos-armour", "librarian-in-phobos-armour", "captain-in-phobos-armour", "lieutenant-with-combi-weapon"]: return false
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
		if str(model.get("definition_id", "")).get_slice(":", 3) not in ["eliminator-squad", "librarian-in-phobos-armour", "captain-in-phobos-armour", "lieutenant-with-combi-weapon", "aethon-shaan"]: return false
		found = true
	return found

static func selection(state: Dictionary) -> Dictionary:
	if state.get("unit_abilities", {}).get("implementation", "") != ABILITY_IMPLEMENTATION_ID: return {}
	var selected: Dictionary = state.unit_abilities.get("optics", {})
	if selected.is_empty() or state.phase != "shooting" or selected.get("phase_key", "") != "%d:%s" % [state.turn, state.phase]: return {}
	var squad: int = selected.get("squad", -1)
	if not state.squads.has(squad) or state.squads[squad].shot or state.squads[squad].owner != state.active: return {}
	return selected
