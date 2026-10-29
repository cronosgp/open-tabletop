extends RefCounted

const Geometry = preload("res://scripts/edition_11/contact_movement.gd")
const UnitAbilities = preload("res://scripts/edition_11/unit_abilities.gd")

const WINDOW := "wulfen-hammer-blow"
const USE := "wulfen-hammer-blow-use"
const PASS := "wulfen-hammer-blow-pass"

static func hit_targets(state: Dictionary, squad: int, resolved: Dictionary) -> Array[int]:
	var result: Array[int] = []
	if not state.get("squads", {}).has(squad): return result
	for pool: Dictionary in resolved.get("pools", []):
		var target := int(pool.get("target_squad", -1))
		if int(pool.get("hits", 0)) <= 0 or target in result or not state.get("squads", {}).has(target): continue
		if int(state.squads[target].get("owner", -1)) == int(state.squads[squad].get("owner", -2)) or Geometry.alive(state, target).is_empty(): continue
		if UnitAbilities.has_target_keyword(state, target, "MONSTER") or UnitAbilities.has_target_keyword(state, target, "VEHICLE"):
			result.append(target)
	return result

static func offer_after_fight(state: Dictionary, squad: int, resolved: Dictionary, melee: bool) -> bool:
	if not melee or str(state.get("phase", "")) != "fight" or not UnitAbilities.enabled(state) or not state.get("squads", {}).has(squad): return false
	if not UnitAbilities.has(state, squad, "hammer-blow") or not bool(state.squads[squad].get("fought", false)): return false
	var targets := hit_targets(state, squad, resolved)
	if targets.is_empty(): return false
	var owner := int(state.squads[squad].get("owner", -1))
	var previous: Dictionary = state.get("unit_abilities", {}).get("window", {}).duplicate(true)
	state.unit_abilities.window = {"kind": WINDOW, "owners": [owner], "squad": squad, "targets": targets, "hit_pools": resolved.get("pools", []).duplicate(true), "source": squad}
	if not previous.is_empty(): state.unit_abilities.window.resume_window = previous
	return true

static func choices(state: Dictionary, player: int) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var window: Dictionary = state.get("unit_abilities", {}).get("window", {})
	if window.get("kind", "") != WINDOW or window.get("owners", []) != [player]: return result
	var squad := int(window.get("squad", -1))
	if not state.get("squads", {}).has(squad) or not UnitAbilities.has(state, squad, "hammer-blow"): return result
	for target: int in window.get("targets", []):
		if state.get("squads", {}).has(target) and not Geometry.alive(state, target).is_empty():
			result.append({"label": "Hammer Blow: suppress %s" % str(state.squads[target].get("name", "enemy unit")), "action": USE, "model": -1, "target": target, "value": "suppress"})
	result.append({"label": "Pass Hammer Blow", "action": PASS, "model": -1, "target": squad, "value": "pass"})
	return result

static func apply(state: Dictionary, player: int, selected: Dictionary) -> Dictionary:
	var window: Dictionary = state.get("unit_abilities", {}).get("window", {})
	if window.get("kind", "") != WINDOW or window.get("owners", []) != [player]: return {"error": "No matching Hammer Blow decision is pending."}
	var squad := int(window.get("squad", -1))
	if not state.get("squads", {}).has(squad) or int(state.squads[squad].get("owner", -1)) != player or not UnitAbilities.has(state, squad, "hammer-blow"):
		return {"error": "Hammer Blow is no longer available to this unit."}
	if selected.get("action", "") == PASS:
		state.unit_abilities.window = window.get("resume_window", {})
		return {"error": "", "message": "Hammer Blow was passed."}
	var target := int(selected.get("target", -1))
	if selected.get("action", "") != USE or target not in window.get("targets", []) or target not in hit_targets(state, squad, {"pools": window.get("hit_pools", [])}):
		return {"error": "Choose one living MONSTER or VEHICLE unit that this Wulfen unit hit, or pass."}
	if Geometry.alive(state, target).is_empty(): return {"error": "Hammer Blow cannot suppress a destroyed unit."}
	if not state.has("detachment_stratagems") or not state.detachment_stratagems is Dictionary: state.detachment_stratagems = {}
	if not state.detachment_stratagems.has("suppressed") or not state.detachment_stratagems.get("suppressed") is Dictionary: state.detachment_stratagems.suppressed = {}
	state.detachment_stratagems.suppressed[target] = {"owner": player, "turn": int(state.turn), "source": "wulfen-hammer-blow", "source_squad": squad}
	state.unit_abilities.window = window.get("resume_window", {})
	return {"error": "", "message": "Hammer Blow: %s is suppressed until the start of your next turn and its attacks have -1 to Hit." % str(state.squads[target].get("name", "the enemy unit"))}
