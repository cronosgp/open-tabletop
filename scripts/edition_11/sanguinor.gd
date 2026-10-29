extends RefCounted
## The Sanguinor's Aura of Fervour and Miraculous Saviour.
const Geometry = preload("res://scripts/edition_11/contact_movement.gd")
const ResolutionFrames = preload("res://scripts/edition_11/resolution_frame.gd")

const AURA := "aura-of-fervour"
const SAVIOUR := "miraculous-saviour"

static func aura_of_fervour_active(state: Dictionary, target_squad: int) -> bool:
	if not state.get("unit_abilities", {}).has("implementation") or not state.get("squads", {}).has(target_squad): return false
	var target_models := Geometry.alive(state, target_squad)
	if target_models.is_empty(): return false
	var owner := int(state.squads[target_squad].get("owner", -1))
	if owner not in [1, 2]: return false
	var target_is_astartes := false
	for target_model: int in target_models:
		if "ADEPTUS ASTARTES" in state.units[target_model].get("keywords", []):
			target_is_astartes = true
			break
	if not target_is_astartes: return false
	for source: int in state.units:
		var bearer: Dictionary = state.units[source]
		if int(bearer.get("owner", -1)) != owner or int(bearer.get("wounds", 0)) <= 0 or not bearer.get("on_battlefield", true): continue
		if str(bearer.get("definition_id", "")).get_slice(":", 3) != "the-sanguinor": continue
		if Geometry.distance_to_target_at_height(state, bearer, target_squad) <= 12.0 + Geometry.EPSILON: return true
	return false

static func reserve_squads(state: Dictionary, player: int) -> Array[int]:
	var result: Array[int] = []
	if not state.get("unit_abilities", {}).has("implementation") or int(state.get("round", 0)) <= 1 or str(state.get("phase", "")) != "charge" or int(state.get("active", -1)) == player: return result
	var used: Dictionary = state.get("unit_abilities", {}).get("used", {})
	if bool(used.get("miraculous-saviour:%d" % player, false)): return result
	var reserves: Dictionary = state.get("unit_abilities", {}).get("reserves", {})
	for squad: int in state.squads:
		if int(state.squads[squad].get("owner", -1)) != player or bool(state.squads[squad].get("battle_shocked", false)): continue
		if not reserves.has(squad) or not _has_sanguinor(state, squad): continue
		result.append(squad)
	result.sort()
	return result

static func _has_sanguinor(state: Dictionary, squad: int) -> bool:
	for model: int in state.get("units", {}):
		var unit: Dictionary = state.units[model]
		if int(unit.get("squad", -1)) != squad or int(unit.get("wounds", 0)) <= 0: continue
		if str(unit.get("definition_id", "")).get_slice(":", 3) == "the-sanguinor": return true
	return false

static func charged_enemy_squads(state: Dictionary, sanguinor_player: int) -> Array[int]:
	var result: Array[int] = []
	if str(state.get("phase", "")) != "charge": return result
	var charging_player := int(state.get("active", -1))
	if charging_player not in [1, 2] or charging_player == sanguinor_player: return result
	for squad: int in state.squads:
		if int(state.squads[squad].get("owner", -1)) != charging_player or not bool(state.squads[squad].get("charged", false)): continue
		if Geometry.alive(state, squad).is_empty(): continue
		result.append(squad)
	result.sort()
	return result

static func choices(state: Dictionary, player: int) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if str(state.get("phase", "")) != "charge" or int(state.get("active", -1)) == player: return result
	var enemies := charged_enemy_squads(state, player)
	for squad: int in reserve_squads(state, player):
		for enemy: int in enemies:
			result.append({"label": "Miraculous Saviour: ingress %s engaged with %s" % [state.squads[squad].name, state.squads[enemy].name], "action": SAVIOUR, "model": enemy, "target": squad, "value": "use"})
	return result

static func begin_ingress(state: Dictionary, player: int, selected: Dictionary) -> Dictionary:
	if selected not in choices(state, player): return {"error": "Miraculous Saviour requires a living reserve Sanguinor and an enemy unit that made a Charge move this phase."}
	var squad := int(selected.get("target", -1))
	var enemy := int(selected.get("model", -1))
	var abilities: Dictionary = state.unit_abilities
	var phase_window: Dictionary = abilities.get("window", {})
	var parent := ResolutionFrames.current(state)
	if str(parent.get("kind", "")) == "phase-close" and str(parent.get("status", "")) == "resolving":
		var parent_error := ResolutionFrames.suspend(state, str(parent.get("frame_id", "")), "opponent-miraculous-saviour")
		if not parent_error.is_empty(): return {"error": parent_error}
	var action_id := "ingress:%d:%s:%d:%d:reserve" % [int(state.get("turn", 0)), str(state.get("phase", "")), player, squad]
	var frame := ResolutionFrames.begin(state, "unit-action", action_id, "ingress-placement")
	if frame.is_empty(): return {"error": "Could not open the Miraculous Saviour placement frame."}
	var frame_id := str(frame.get("frame_id", ""))
	var suspend_error := ResolutionFrames.suspend(state, frame_id, "ingress-placement")
	if not suspend_error.is_empty():
		ResolutionFrames.complete(state, frame_id)
		return {"error": suspend_error}
	abilities.used["miraculous-saviour:%d" % player] = true
	abilities.window = {"kind": "ingress", "owners": [player], "squad": squad, "positions": {}, "homer": false, "deep_strike": true, "miraculous_saviour": true, "engaged_enemy": enemy, "resolution_frame_id": frame_id, "return_window": phase_window.duplicate(true)}
	return {"error": "", "message": "Miraculous Saviour: set up The Sanguinor engaged with the charging unit."}

static func confirms_engagement(projected: Dictionary, sanguinor_squad: int, enemy_squad: int) -> bool:
	if not projected.get("squads", {}).has(sanguinor_squad) or not projected.get("squads", {}).has(enemy_squad): return false
	for model: int in Geometry.alive(projected, sanguinor_squad):
		for enemy: int in Geometry.alive(projected, enemy_squad):
			if Geometry.within_engagement(projected.units[model], projected.units[enemy]): return true
	return false
