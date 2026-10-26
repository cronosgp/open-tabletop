extends RefCounted
## Execute and Redeploy's optional post-shot Normal Move for Phobos Shadow Force.
const Geometry = preload("res://scripts/edition_11/contact_movement.gd")
const Queue = preload("res://scripts/edition_11/fight_queue.gd")
const TacticalFluidity = preload("res://scripts/edition_11/tactical_fluidity.gd")
const UnitAbilities = preload("res://scripts/edition_11/unit_abilities.gd")
const MarineEnhancements = preload("res://scripts/edition_11/stormlance_enhancements.gd")

const WINDOW := "phobos-execute-and-redeploy"
const MOVE_SOURCE := "phobos-execute-and-redeploy"

static func eligible(state: Dictionary, player: int, squad: int) -> bool:
	if not UnitAbilities.enabled(state) or not state.get("squads", {}).has(squad): return false
	if int(state.squads[squad].get("owner", -1)) != player or int(state.get("active", -1)) != player or str(state.get("phase", "")) != "shooting": return false
	if not bool(state.squads[squad].get("shot", false)) or Queue.engaged(state, squad): return false
	if not MarineEnhancements.execute_and_redeploy_active(state, squad) or TacticalFluidity.normal_move_used_this_phase(state, squad): return false
	var models := Geometry.alive(state, squad)
	if models.is_empty(): return false
	for model: int in models:
		if not bool(state.units[model].get("on_battlefield", true)): return false
	return true

static func after_shadow_masters(state: Dictionary, squad: int, resume_window: Dictionary) -> Dictionary:
	var player := int(state.squads[squad].get("owner", -1)) if state.get("squads", {}).has(squad) else -1
	if not eligible(state, player, squad): return resume_window.duplicate(true)
	return {"kind": WINDOW, "owners": [player], "squad": squad, "resume_window": resume_window.duplicate(true)}

static func choices(state: Dictionary, player: int) -> Array:
	var window: Dictionary = state.get("unit_abilities", {}).get("window", {})
	var squad := int(window.get("squad", -1))
	if window.get("kind", "") != WINDOW or window.get("owners", []) != [player] or not state.get("squads", {}).has(squad): return []
	var name := str(state.squads[squad].get("name", "this unit"))
	var result: Array = []
	if eligible(state, player, squad):
		result.append({"label": "Execute and Redeploy: Normal Move up to 6 inches (%s)" % name, "action": "execute-redeploy-use", "model": -1, "target": squad, "value": ""})
	result.append({"label": "Pass Execute and Redeploy for %s" % name, "action": "execute-redeploy-pass", "model": -1, "target": squad, "value": ""})
	return result

static func apply(state: Dictionary, player: int, selected: Dictionary, point: Vector2, roller: Callable) -> Dictionary:
	var window: Dictionary = state.get("unit_abilities", {}).get("window", {})
	var squad := int(selected.get("target", -1))
	if window.get("kind", "") != WINDOW or window.get("owners", []) != [player] or int(window.get("squad", -1)) != squad:
		return {"error": "No matching Execute and Redeploy choice is pending."}
	if selected.get("action", "") == "execute-redeploy-pass":
		state.unit_abilities.window = window.get("resume_window", {})
		return {"error": "", "message": "Execute and Redeploy passed."}
	if selected.get("action", "") != "execute-redeploy-use" or not eligible(state, player, squad):
		return {"error": "Execute and Redeploy requires its living PHOBOS bearer unit to have shot unengaged in its own Shooting phase, with no Normal Move already made this phase."}
	state.unit_abilities.window = {"kind": TacticalFluidity.WINDOW, "owners": [player], "squad": squad, "mode": "execute-redeploy", "source": MOVE_SOURCE, "resume_window": window.get("resume_window", {})}
	return TacticalFluidity.apply(state, player, {"action": "fluidity-use", "model": -1, "target": squad, "value": ""}, point, roller)

static func apply_move(state: Dictionary, player: int, selected: Dictionary, point: Vector2, roller: Callable) -> Dictionary:
	var window: Dictionary = state.get("unit_abilities", {}).get("window", {})
	if window.get("source", "") != MOVE_SOURCE or window.get("owners", []) != [player] or not eligible(state, player, int(window.get("squad", -1))):
		return {"error": "Execute and Redeploy's Normal Move is no longer eligible."}
	return TacticalFluidity.apply(state, player, selected, point, roller)
