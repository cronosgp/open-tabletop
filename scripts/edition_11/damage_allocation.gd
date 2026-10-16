extends RefCounted
const Groups = preload("res://scripts/edition_11/defender_groups.gd")
const Attacks = preload("res://scripts/edition_11/attack_sequence.gd")
const Geometry = preload("res://scripts/edition_11/contact_movement.gd")
const RollWindows = preload("res://scripts/edition_11/attack_roll_window.gd")
const Stratagems = preload("res://scripts/edition_11/stratagems.gd")

static func eligible(state: Dictionary) -> Array[int]:
	var pending: Dictionary = state.get("pending_attack", {})
	if pending.is_empty() or pending.current.is_empty(): return []
	var current: Dictionary = pending.current
	if current.phase in ["rolls", "damage_decision"]: return []
	if current.phase == "precision":
		var result: Array[int] = []
		result.assign(current.precision_candidates)
		return result
	if current.phase == "order": return Groups.order_choices(state, current)
	if current.cursor >= current.steps.size(): return []
	return Groups.current_models(state, current, current.steps[current.cursor].kind == "devastating")

static func start(state: Dictionary, prepared: Dictionary, squad: int, player: int, entries: Array, melee: bool, assist: bool = false, precision_prompt: bool = true) -> void:
	state.pending_attack = {"prepared": prepared.duplicate(true), "squad": squad, "player": player, "entries": entries.duplicate(true), "melee": melee,
		"index": 0, "current": {}, "pools": [], "damage": 0, "killed": 0, "assist": assist, "precision_prompt": precision_prompt}

static func saved(state: Dictionary, current: Dictionary, model: int, roll: int) -> bool:
	var profile := Groups.profile(state, model)
	return roll != 1 and ((profile.invulnerable_target > 0 and roll >= profile.invulnerable_target) or roll + int(current.weapon.ap) >= profile.save_target)

static func pump(state: Dictionary, roller: Callable) -> Dictionary:
	var pending: Dictionary = state.pending_attack
	while pending.index < pending.prepared.batches.size():
		var batch: Dictionary = pending.prepared.batches[pending.index]
		if pending.current.is_empty() or pending.current.get("phase") == "rolls":
			var defender := Groups.defender(state, batch.target)
			if not defender.error.is_empty(): return defender
			if defender.get("models", []).is_empty():
				pending.index += 1
				continue
			var context: Dictionary = batch.context.duplicate(true)
			context.defer_saves = true
			var rolled: Dictionary
			if state.get("stratagems", {}).get("attack_rerolls", false) or state.get("stratagems", {}).get("count_rerolls", false):
				if pending.current.is_empty():
					var checkpoint := RollWindows.begin(batch.weapon, defender, context, roller, state.stratagems.get("count_rerolls", false))
					if not checkpoint.error.is_empty(): return checkpoint
					pending.current = {"phase": "rolls", "target": batch.target, "checkpoint": checkpoint}
				while pending.current.checkpoint.phase != "complete":
					var checkpoint: Dictionary = pending.current.checkpoint
					var enabled: bool = state.stratagems.get("count_rerolls", false) if checkpoint.phase == "generation" else state.stratagems.get("attack_rerolls", false)
					if enabled and not RollWindows.eligible(checkpoint).is_empty() and Stratagems.eligibility_error(state, pending.player, pending.squad, "command-re-roll").is_empty() and not pending.current.get("accepted", false):
						state.stratagems.pending = {"kind": "after_attack_count_roll" if checkpoint.phase == "generation" else ("after_hit_roll" if checkpoint.phase == "hit" else "after_wound_roll"), "player": pending.player, "squad": pending.squad, "phase_key": Stratagems.phase_key(state), "rolls": checkpoint.generated.rolls.duplicate() if checkpoint.phase == "generation" else (checkpoint.hit_rolls.duplicate() if checkpoint.phase == "hit" else checkpoint.effective_wounds.duplicate()), "eligible": RollWindows.eligible(checkpoint)}
						if checkpoint.phase == "generation":
							state.stratagems.pending.total = checkpoint.generated.count
							var expressions: Array[String] = []
							var labels: Array[String] = []
							for record: Dictionary in checkpoint.generated.records:
								if str(record.expression) not in expressions: expressions.append(str(record.expression))
								for index in range(record.rolls.size()): labels.append("M%d • %s • die %d: %d" % [record.model, str(record.expression), index + 1, record.rolls[index]])
							state.stratagems.pending.expression = ", ".join(expressions)
							state.stratagems.pending.labels = labels
						return {"error": "", "complete": false}
					pending.current.accepted = false
					var advanced := RollWindows.advance(checkpoint, checkpoint.revision, roller)
					if not advanced.error.is_empty(): return advanced
					pending.current.checkpoint = advanced
				rolled = pending.current.checkpoint.result
			else: rolled = Attacks.roll_pool(batch.weapon, defender, context, roller)
			if not rolled.error.is_empty(): return rolled
			rolled.merge({"target_squad": batch.target, "weapon_name": batch.weapon.name, "unsaved": 0, "models_destroyed": 0, "damage_applied": 0, "excess_damage_discarded": 0, "allocations": []})
			var candidates := Groups.precision_candidates(state, batch)
			pending.current = {"target": batch.target, "failed_rolls": [], "steps": [], "cursor": 0, "damage": batch.weapon.damage, "weapon": batch.weapon,
				"result": rolled, "groups": Groups.groups(state, batch.target), "order": [], "precision": -1, "precision_candidates": candidates,
				"phase": "precision" if not candidates.is_empty() and rolled.wounds > 0 and pending.precision_prompt else "order"}
		var current: Dictionary = pending.current
		if current.phase == "precision": return {"error": "", "complete": false}
		if current.phase == "order":
			var choices := Groups.order_choices(state, current)
			if not choices.is_empty():
				if current.groups.size() > 1 and current.result.save_count > 0 and not pending.assist: return {"error": "", "complete": false}
				Groups.choose_order(current, choices[0])
				continue
			current.phase = "saves"
		if current.phase == "saves":
			var dice := Attacks.Dice.new(roller)
			for index in range(current.result.save_count): current.result.save_rolls.append(dice.d6())
			if not dice.error.is_empty(): return {"error": dice.error}
			current.result.dice_history.append_array(dice.history)
			current.phase = "save_finalize"
			var owner: int = state.squads[current.target].owner
			if state.get("stratagems", {}).get("save_rerolls", false) and not current.result.save_rolls.is_empty() and Stratagems.eligibility_error(state, owner, current.target, "command-re-roll").is_empty():
				var indices: Array[int] = []
				for index in range(current.result.save_rolls.size()): indices.append(index)
				state.stratagems.pending = {"kind": "after_save_roll", "player": owner, "squad": current.target, "phase_key": Stratagems.phase_key(state), "rolls": current.result.save_rolls.duplicate(), "eligible": indices}
				current.phase = "save_decision"
				return {"error": "", "complete": false}
		if current.phase == "save_decision": return {"error": "", "complete": false}
		if current.phase == "save_finalize":
			current.result.save_rolls.sort()
			for value: int in current.result.save_rolls: current.steps.append({"kind": "normal", "save_roll": value})
			for index in range(current.result.devastating_wounds): current.steps.append({"kind": "devastating", "save_roll": 0})
			if current.groups.size() == 1:
				var models := Groups.current_models(state, current)
				for value: int in current.result.save_rolls:
					if not saved(state, current, models[0], value): current.failed_rolls.append(value)
			current.result.allocation_order = current.order.duplicate()
			current.result.allocation_groups = current.groups.duplicate(true)
			current.result.precision_model = current.precision
			current.phase = "damage"
		if current.phase == "damage_decision": return {"error": "", "complete": false}
		if current.phase == "damage_finalize":
			var finalized := _apply_rolled_damage(state, current.pending_damage.model, current.pending_damage.rolled, roller, false)
			if not finalized.error.is_empty(): return finalized
			current.erase("pending_damage")
			current.phase = "damage"
		while current.cursor < current.steps.size():
			var choices := eligible(state)
			if choices.is_empty(): break
			var step: Dictionary = current.steps[current.cursor]
			if step.kind == "normal" and saved(state, current, choices[0], step.save_roll):
				current.cursor += 1
				continue
			if not pending.assist: return {"error": "", "complete": false}
			var applied := apply(state, choices[0], roller)
			if not applied.error.is_empty(): return applied
			if current.phase == "damage_decision": return {"error": "", "complete": false}
		current.result.remaining_wounds = Groups.defender(state, current.target).remaining_wounds
		pending.pools.append(current.result)
		pending.damage += current.result.damage_applied
		pending.killed += current.result.models_destroyed
		pending.current = {}
		pending.index += 1
	return {"error": "", "complete": true}

static func choice_error(state: Dictionary, player: int, model: int) -> String:
	if not Stratagems.pending(state).is_empty(): return "Resolve the re-roll decision before allocation."
	var pending: Dictionary = state.get("pending_attack", {})
	if pending.is_empty() or pending.current.is_empty(): return "No pending damage allocation."
	var current: Dictionary = pending.current
	var owner: int = pending.player if current.phase == "precision" else state.squads[current.target].owner
	if player != owner: return "Wait for the player making this allocation decision."
	if current.phase == "precision" and model == -1: return ""
	if model not in eligible(state): return "Choose an eligible model/group; wounded groups and models have priority."
	return ""

static func apply(state: Dictionary, model: int, roller: Callable) -> Dictionary:
	var current: Dictionary = state.pending_attack.current
	if current.phase == "precision":
		current.precision = model
		current.phase = "order"
		return {"error": ""}
	if current.phase == "order":
		Groups.choose_order(current, model)
		return {"error": ""}
	var rolled := Attacks.RandomStat.roll(current.damage, roller)
	if not rolled.error.is_empty(): return rolled
	var pending: Dictionary = state.pending_attack
	if state.get("stratagems", {}).get("damage_rerolls", false) and not rolled.rolls.is_empty() and Stratagems.eligibility_error(state, pending.player, pending.squad, "command-re-roll").is_empty():
		current.pending_damage = {"model": model, "rolled": rolled}
		current.phase = "damage_decision"
		current.result.dice_history.append_array(rolled.rolls)
		var indices: Array[int] = []
		for index in range(rolled.rolls.size()): indices.append(index)
		state.stratagems.pending = {"kind": "after_damage_roll", "player": pending.player, "squad": pending.squad, "phase_key": Stratagems.phase_key(state), "rolls": rolled.rolls.duplicate(), "eligible": indices, "expression": rolled.expression, "value": rolled.value, "model": model}
		return {"error": ""}
	return _apply_rolled_damage(state, model, rolled, roller)

static func _apply_rolled_damage(state: Dictionary, model: int, rolled: Dictionary, roller: Callable, append_rolls: bool = true) -> Dictionary:
	var current: Dictionary = state.pending_attack.current
	var step: Dictionary = current.steps[current.cursor]
	var before: int = state.units[model].wounds
	var prevented := Attacks.Prevention.resolve(int(rolled.value), before, state.units[model].get("feel_no_pain", []), "normal" if step.kind == "normal" else "mortal", roller)
	if not prevented.error.is_empty(): return prevented
	var applied: int = prevented.lost
	current.result.prevented_wounds += prevented.prevented
	current.result.prevention_rolls.append(prevented)
	if append_rolls: current.result.dice_history.append_array(rolled.rolls)
	current.result.dice_history.append_array(prevented.rolls)
	state.units[model].wounds -= applied
	if step.kind == "normal":
		current.result.unsaved += 1
		current.result.normal_damage_applied += applied
	else:
		current.result.devastating_attacks_resolved += 1
		current.result.mortal_damage_applied += applied
	current.result.damage_applied += applied
	current.result.excess_damage_discarded += prevented.discarded
	current.result.damage_rolls.append(rolled)
	if state.units[model].wounds == 0: current.result.models_destroyed += 1
	current.result.allocations.append({"model": model, "kind": step.kind, "save_roll": step.save_roll, "damage": applied, "rolled_damage": rolled.value, "damage_rolls": rolled.rolls, "discarded": prevented.discarded, "prevention": prevented})
	current.cursor += 1
	return {"error": ""}
