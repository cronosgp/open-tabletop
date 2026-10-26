extends RefCounted
## Phobos Shadow Force's post-shot choice, using the shared Normal Move preview.
const Geometry = preload("res://scripts/edition_11/contact_movement.gd")
const Queue = preload("res://scripts/edition_11/fight_queue.gd")
const TacticalFluidity = preload("res://scripts/edition_11/tactical_fluidity.gd")
const ExecuteRedeploy = preload("res://scripts/edition_11/phobos_execute_redeploy.gd")
const UnitAbilities = preload("res://scripts/edition_11/unit_abilities.gd")
const Detachment = preload("res://scripts/edition_11/detachment_stratagems.gd")

const WINDOW := "phobos-shadow-masters"
const MOVE_SOURCE := "phobos-shadow-masters"

static func _hidden_key(squad: int, turn: int) -> String:
	return "phobos-shadow-hidden:%d:%d" % [squad, turn]

static func eligible(state: Dictionary, player: int, squad: int) -> bool:
	if not UnitAbilities.enabled(state) or not state.squads.has(squad): return false
	if int(state.squads[squad].get("owner", -1)) != player or int(state.get("active", -1)) != player or str(state.get("phase", "")) != "shooting": return false
	if not bool(state.squads[squad].get("shot", false)) or not Detachment.phobos_shadow_masters_enabled(state, player): return false
	if not UnitAbilities.has_target_keyword(state, squad, "PHOBOS") and not UnitAbilities.has_target_keyword(state, squad, "SCOUT SQUAD"): return false
	var models := Geometry.alive(state, squad)
	if models.is_empty(): return false
	for model: int in models:
		if not bool(state.units[model].get("on_battlefield", true)): return false
	return true

static func move_available(state: Dictionary, player: int, squad: int) -> bool:
	return eligible(state, player, squad) and not Queue.engaged(state, squad) and not TacticalFluidity.normal_move_used_this_phase(state, squad)

static func open_after_shot(state: Dictionary, squad: int) -> void:
	var player := int(state.squads[squad].get("owner", -1)) if state.squads.has(squad) else -1
	if not eligible(state, player, squad): return
	var previous: Dictionary = state.unit_abilities.get("window", {}).duplicate(true)
	var resume_window := ExecuteRedeploy.after_shadow_masters(state, squad, previous)
	state.unit_abilities.window = {"kind": WINDOW, "owners": [player], "squad": squad, "resume_window": resume_window}

static func choices(state: Dictionary, player: int) -> Array:
	var window: Dictionary = state.get("unit_abilities", {}).get("window", {})
	var squad := int(window.get("squad", -1))
	if window.get("kind", "") != WINDOW or window.get("owners", []) != [player] or not eligible(state, player, squad): return []
	var result: Array = [
		{"label": "Shadow Masters: these attacks do not prevent %s from being Hidden" % str(state.squads[squad].get("name", "this unit")), "action": "shadow-masters-hidden", "model": -1, "target": squad, "value": ""}
	]
	if move_available(state, player, squad):
		result.append({"label": "Shadow Masters: Normal Move up to D6 inches; cannot Charge this turn (%s)" % str(state.squads[squad].get("name", "this unit")), "action": "shadow-masters-move", "model": -1, "target": squad, "value": ""})
	return result

static func apply(state: Dictionary, player: int, selected: Dictionary, point: Vector2, roller: Callable) -> Dictionary:
	var window: Dictionary = state.get("unit_abilities", {}).get("window", {})
	var squad := int(selected.get("target", -1))
	if window.get("kind", "") != WINDOW or window.get("owners", []) != [player] or int(window.get("squad", -1)) != squad:
		return {"error": "No matching Shadow Masters choice is pending."}
	if not eligible(state, player, squad): return {"error": "Shadow Masters' detachment, shooting or battlefield eligibility changed."}
	if selected.get("action", "") == "shadow-masters-hidden":
		state.unit_abilities.used[_hidden_key(squad, int(state.turn))] = true
		state.unit_abilities.window = window.get("resume_window", {})
		return {"error": "", "message": "Shadow Masters: these attacks do not prevent %s from being Hidden this turn." % str(state.squads[squad].get("name", "this unit"))}
	if selected.get("action", "") != "shadow-masters-move" or not move_available(state, player, squad):
		return {"error": "Shadow Masters requires choosing the Hidden benefit or an available Normal Move."}
	state.unit_abilities.window = {"kind": TacticalFluidity.WINDOW, "owners": [player], "squad": squad, "mode": "shoot", "source": MOVE_SOURCE, "resume_window": window.get("resume_window", {})}
	return TacticalFluidity.apply(state, player, {"action": "fluidity-use", "model": -1, "target": squad, "value": ""}, point, roller)

static func apply_move(state: Dictionary, player: int, selected: Dictionary, point: Vector2, roller: Callable) -> Dictionary:
	var window: Dictionary = state.get("unit_abilities", {}).get("window", {})
	if window.get("source", "") != MOVE_SOURCE or window.get("owners", []) != [player] or not eligible(state, player, int(window.get("squad", -1))):
		return {"error": "Shadow Masters' Normal Move is no longer eligible."}
	return TacticalFluidity.apply(state, player, selected, point, roller)
