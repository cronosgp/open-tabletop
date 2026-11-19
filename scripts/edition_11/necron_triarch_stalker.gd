extends RefCounted
## Source-bounded Triarch Stalker Targeting Relay from Necrons App v1.2 datasheet 000000540.
const Geometry = preload("res://scripts/edition_11/contact_movement.gd")
const UnitAbilities = preload("res://scripts/edition_11/unit_abilities.gd")

const IDENTITY := "triarch-stalker"
const WINDOW := "targeting-relay"
const ACTION := "targeting-relay"

static func hit_targets(state: Dictionary, squad: int, resolved: Dictionary) -> Array[int]:
	var result: Array[int] = []
	if not state.get("squads", {}).has(squad): return result
	for pool: Dictionary in resolved.get("pools", []):
		var target := int(pool.get("target_squad", -1))
		if int(pool.get("hits", 0)) <= 0 or target in result or not state.get("squads", {}).has(target): continue
		if int(state.squads[target].get("owner", -1)) == int(state.squads[squad].get("owner", -2)): continue
		if Geometry.alive(state, target).is_empty(): continue
		result.append(target)
	result.sort()
	return result

static func offer_after_shot(state: Dictionary, squad: int, resolved: Dictionary, melee: bool) -> bool:
	if melee or str(state.get("phase", "")) != "shooting" or not UnitAbilities.enabled(state): return false
	if not state.get("squads", {}).has(squad) or int(state.get("active", -1)) != int(state.squads[squad].get("owner", -2)): return false
	if not UnitAbilities.has(state, squad, "targeting-relay"): return false
	var targets := hit_targets(state, squad, resolved)
	if targets.is_empty(): return false
	var owner := int(state.squads[squad].get("owner", -1))
	if targets.size() == 1:
		_mark(state, owner, squad, targets[0])
		return false
	var previous: Dictionary = state.get("unit_abilities", {}).get("window", {}).duplicate(true)
	state.unit_abilities.window = {
		"kind": WINDOW,
		"owners": [owner],
		"squad": squad,
		"targets": targets,
		"hit_pools": resolved.get("pools", []).duplicate(true),
		"source": squad
	}
	if not previous.is_empty(): state.unit_abilities.window.resume_window = previous
	return true

static func choices(state: Dictionary, player: int) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var window: Dictionary = state.get("unit_abilities", {}).get("window", {})
	if str(window.get("kind", "")) != WINDOW or window.get("owners", []) != [player]: return result
	var squad := int(window.get("squad", -1))
	if not state.get("squads", {}).has(squad) or not UnitAbilities.has(state, squad, "targeting-relay"): return result
	for target: int in window.get("targets", []):
		if state.get("squads", {}).has(target) and not Geometry.alive(state, target).is_empty():
			result.append({"label": "Targeting Relay: deny Cover to %s" % str(state.squads[target].get("name", "enemy unit")), "action": ACTION, "model": -1, "target": target, "value": "deny"})
	return result

static func apply(state: Dictionary, player: int, selected: Dictionary) -> Dictionary:
	var window: Dictionary = state.get("unit_abilities", {}).get("window", {})
	if str(window.get("kind", "")) != WINDOW or window.get("owners", []) != [player]:
		return {"error": "No matching Targeting Relay decision is pending."}
	var squad := int(window.get("squad", -1))
	if not state.get("squads", {}).has(squad) or int(state.squads[squad].get("owner", -1)) != player or not UnitAbilities.has(state, squad, "targeting-relay"):
		return {"error": "Targeting Relay is no longer available to this unit."}
	var target := int(selected.get("target", -1))
	if str(selected.get("action", "")) != ACTION or target not in window.get("targets", []) or target not in hit_targets(state, squad, {"pools": window.get("hit_pools", [])}):
		return {"error": "Choose one living enemy unit that this Triarch Stalker hit."}
	if Geometry.alive(state, target).is_empty():
		return {"error": "Targeting Relay cannot mark a destroyed unit."}
	_mark(state, player, squad, target)
	state.unit_abilities.window = window.get("resume_window", {})
	return {"error": "", "message": "Targeting Relay: %s cannot have the Benefit of Cover for the rest of the phase." % str(state.squads[target].get("name", "the enemy unit"))}

static func _mark(state: Dictionary, owner: int, source_squad: int, target: int) -> void:
	if not state.get("unit_abilities") is Dictionary: return
	if not state.unit_abilities.has("signum_targets"): state.unit_abilities.signum_targets = {}
	state.unit_abilities.signum_targets[target] = {
		"owner": owner,
		"phase_key": "%d:%s" % [int(state.get("turn", 0)), str(state.get("phase", ""))],
		"source": source_squad,
		"ability": "targeting-relay"
	}
