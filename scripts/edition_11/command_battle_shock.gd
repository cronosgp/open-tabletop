extends RefCounted
## Command-phase Battle-shock batch used when Core Stratagem decisions are disabled.
const Morale = preload("res://scripts/edition_11/morale.gd")
const MarineEnhancements = preload("res://scripts/edition_11/stormlance_enhancements.gd")
const PendingDecision = preload("res://scripts/edition_11/pending_decision.gd")
const ID := "command-battle-shock-with-aura-decisions-v1"

static func pending(state: Dictionary) -> Dictionary:
	return state.get("command_battle_shock", {}).get("pending", {})

static func done(state: Dictionary) -> bool:
	return int(state.get("command_battle_shock", {}).get("done_turn", -1)) == int(state.get("turn", -2))

static func actor(state: Dictionary) -> int:
	var batch := pending(state)
	return int(batch.get("decision_owner", -1)) if not batch.get("current_result", {}).is_empty() else -1

static func choices(state: Dictionary, player: int) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var batch := pending(state)
	var current: Dictionary = batch.get("current_result", {})
	var squad := int(current.get("squad", -1))
	if squad < 0 or player != int(batch.get("decision_owner", -1)) or not MarineEnhancements.tempered_in_battle_active(state, squad): return result
	result.append({"label": "Keep %s's Battle-shock result" % str(state.squads[squad].get("name", "unit")), "action": "command-battle-shock-decision", "model": -1, "target": squad, "value": "keep"})
	result.append({"label": "Tempered in Battle: re-roll both Leadership dice for %s" % str(state.squads[squad].get("name", "unit")), "action": "command-battle-shock-decision", "model": -1, "target": squad, "value": "tempered-in-battle"})
	return result

static func pending_decision(state: Dictionary) -> Dictionary:
	var batch := pending(state)
	if batch.get("current_result", {}).is_empty(): return {}
	var owner := int(batch.get("decision_owner", -1))
	return PendingDecision.create(state, "unit-actions", "command-phase:battle-shock-leadership", owner, choices(state, owner), false)

static func resolve_command(state: Dictionary, roller: Callable) -> Dictionary:
	var working: Dictionary = state.duplicate(true)
	var result := _resolve_command(working, roller)
	if not str(result.get("error", "")).is_empty(): return result
	state.clear()
	state.merge(working, true)
	return result

static func _resolve_command(state: Dictionary, roller: Callable) -> Dictionary:
	if state.get("phase", "") != "command": return {"error": "Command Battle-shock can only resolve during the Command phase."}
	if done(state): return {"error": "Command Battle-shock has already resolved this turn."}
	if pending(state).is_empty():
		var remaining: Array[int] = []
		for squad: int in state.squads:
			if Morale.needs_command_roll(state, squad): remaining.append(squad)
		remaining.sort()
		state.command_battle_shock = {"implementation": ID, "done_turn": -1, "pending": {"player": int(state.active), "turn": int(state.turn), "phase_key": "%d:%s" % [int(state.turn), str(state.phase)], "remaining": remaining, "results": []}}
	return _pump(state, roller)

static func resolve(state: Dictionary, player: int, selected: Dictionary, revision: int, roller: Callable) -> Dictionary:
	var batch := pending(state)
	var current: Dictionary = batch.get("current_result", {})
	var squad := int(current.get("squad", -1))
	if squad < 0 or str(batch.get("phase_key", "")) != "%d:%s" % [int(state.turn), str(state.phase)]: return {"error": "There is no pending Command Battle-shock Leadership choice."}
	if revision != int(state.get("revision", -1)): return {"error": "State changed; synchronize before deciding."}
	if player != int(batch.get("decision_owner", -1)) or player != int(state.squads[squad].get("owner", -1)): return {"error": "This Leadership decision belongs to the tested unit's controller."}
	if selected not in choices(state, player) or int(selected.get("target", -1)) != squad: return {"error": "Choose a legal option for the current Command Battle-shock result."}
	if selected.get("value", "") == "tempered-in-battle":
		if not MarineEnhancements.tempered_in_battle_active(state, squad): return {"error": "Tempered in Battle no longer applies to this Leadership roll."}
		var rerolled := Morale.roll_battle_shock(state, squad, roller, int(current.get("modifier", 0)))
		if not rerolled.get("error", "").is_empty(): return rerolled
		rerolled["rerolled_from"] = current.get("rolls", []).duplicate()
		rerolled["reroll_source"] = "tempered-in-battle"
		current = rerolled
	elif selected.get("value", "") == "keep":
		current["reroll_declined"] = true
	else:
		return {"error": "Choose to keep the result or use the eligible aura re-roll."}
	batch["current_result"] = current
	return _finish_current(state, roller)

static func _pump(state: Dictionary, roller: Callable) -> Dictionary:
	var batch: Dictionary = state.command_battle_shock.pending
	while not batch.get("remaining", []).is_empty():
		var remaining: Array = batch.get("remaining", [])
		var squad := int(remaining[0])
		if not state.squads.has(squad) or not Morale.needs_command_roll(state, squad):
			remaining.pop_front()
			continue
		var result := Morale.roll_battle_shock(state, squad, roller)
		if not result.get("error", "").is_empty(): return result
		if MarineEnhancements.tempered_in_battle_active(state, squad):
			batch["current_result"] = result
			batch["decision_owner"] = int(state.squads[squad].get("owner", -1))
			return {"error": "", "pending": true}
		batch["current_result"] = result
		var finish := _finish_current(state, roller)
		if not finish.get("error", "").is_empty() or finish.get("pending", false) or finish.get("complete", false): return finish
		batch = state.command_battle_shock.pending
	return _complete(state)

static func _finish_current(state: Dictionary, roller: Callable) -> Dictionary:
	var batch: Dictionary = state.command_battle_shock.pending
	var result: Dictionary = batch.get("current_result", {}).duplicate(true)
	var squad := int(result.get("squad", -1))
	if squad < 0 or not state.squads.has(squad): return {"error": "The pending Leadership target is no longer available."}
	state.squads[squad].battle_shocked = not bool(result.get("passed", false))
	batch.results.append(result)
	var remaining: Array = batch.get("remaining", [])
	remaining.erase(squad)
	batch.erase("current_result")
	batch.erase("decision_owner")
	state.last_morale = batch.results.duplicate(true)
	if batch.remaining.is_empty(): return _complete(state)
	return _pump(state, roller)

static func _complete(state: Dictionary) -> Dictionary:
	state.last_morale = state.get("command_battle_shock", {}).get("pending", {}).get("results", []).duplicate(true)
	state.command_battle_shock.done_turn = int(state.turn)
	state.command_battle_shock.pending = {}
	return {"error": "", "complete": true, "advance": true, "message": "Command Battle-shock tests resolved."}
