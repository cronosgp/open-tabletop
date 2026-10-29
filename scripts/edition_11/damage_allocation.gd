extends RefCounted
const UnitPrevention = preload("res://scripts/edition_11/unit_prevention.gd")
const UnitAbilities = preload("res://scripts/edition_11/unit_abilities.gd")
const Morale = preload("res://scripts/edition_11/morale.gd")
const Groups = preload("res://scripts/edition_11/defender_groups.gd")
const Attacks = preload("res://scripts/edition_11/attack_sequence.gd")
const Geometry = preload("res://scripts/edition_11/contact_movement.gd")
const RollWindows = preload("res://scripts/edition_11/attack_roll_window.gd")
const Stratagems = preload("res://scripts/edition_11/stratagems.gd")
const DetachmentStratagems = preload("res://scripts/edition_11/detachment_stratagems.gd")
const ChaplainGrimaldus = preload("res://scripts/edition_11/chaplain_grimaldus.gd")
const BloodAngelsCharacters = preload("res://scripts/edition_11/blood_angels_characters.gd")
const PendingDecision = preload("res://scripts/edition_11/pending_decision.gd")

static func eligible(state: Dictionary) -> Array[int]:
	var pending: Dictionary = state.get("pending_attack", {})
	if pending.is_empty() or pending.current.is_empty(): return []
	var current: Dictionary = pending.current
	if current.phase in ["rolls", "damage_decision", "damage_ability"]: return []
	if current.phase == "precision":
		var result: Array[int] = []
		result.assign(current.precision_candidates)
		return result
	if current.phase == "order": return Groups.order_choices(state, current)
	if current.cursor >= current.steps.size(): return []
	return Groups.current_models(state, current, current.steps[current.cursor].kind == "devastating")

## Common projection for Precision, mixed-defender order and damage recipient choices.
## The attacker/defender allocation rules remain authoritative in choice_error/apply.
static func pending_decision(state: Dictionary) -> Dictionary:
	for required: String in ["revision", "pending_attack", "squads", "units"]:
		if not state.has(required): return {}
	var pending: Dictionary = state.get("pending_attack", {})
	if pending.is_empty() or pending.get("current", {}).is_empty() or not Stratagems.pending(state).is_empty() or not state.get("pending_hazard", {}).is_empty(): return {}
	if not state.get("unit_abilities", {}).get("window", {}).is_empty(): return {}
	var current: Dictionary = pending.current
	if current.phase in ["rolls", "damage_decision", "damage_ability", "damage_after_ability", "damage_finalize"]: return {}
	var target := int(current.get("target", -1))
	if not state.get("squads", {}).has(target): return {}
	var owner := int(pending.player) if current.phase == "precision" else int(state.squads[target].owner)
	if owner not in [1, 2]: return {}
	var options: Array[Dictionary] = []
	if current.phase == "precision" and choice_error(state, owner, -1).is_empty():
		options.append({"label": "Skip Precision selection", "action": "damage-allocation", "model": -1, "target": target, "value": "precision"})
	for model: int in eligible(state):
		if not choice_error(state, owner, model).is_empty(): continue
		var label := "Assign the next damaging attack to model %d" % model
		if current.phase == "precision": label = "Use Precision against model %d" % model
		options.append({"label": label, "action": "damage-allocation", "model": model, "target": target, "value": str(current.phase)})
	if options.is_empty(): return {}
	return PendingDecision.create(state, "damage-allocation", "attack:%s" % str(current.phase), owner, options, current.phase == "precision")

static func start(state: Dictionary, prepared: Dictionary, squad: int, player: int, entries: Array, melee: bool, assist: bool = false, precision_prompt: bool = true) -> void:
	var bladeguard_effects := {}
	for target: int in state.squads:
		var mode := UnitAbilities.Bladeguard.mode(state, target)
		if not mode.is_empty(): bladeguard_effects[target] = mode
	state.pending_attack = {"unit_prevention": UnitPrevention.snapshot(state), "bladeguard_effects": bladeguard_effects, "prepared": prepared.duplicate(true), "squad": squad, "player": player, "entries": entries.duplicate(true), "melee": melee,
		"index": 0, "current": {}, "pools": [], "damage": 0, "killed": 0, "assist": assist, "precision_prompt": precision_prompt, "ability_saves": {}, "aquilon_used": {}, "machine_spirit_used": {"hit": false, "wound": false}, "armoured_wrath_used": {"any": false, "hit": false, "wound": false, "damage": false}, "martial_paragon_used": {"hit": false, "wound": false}}
	for target: int in prepared.targets: state.pending_attack.ability_saves[target] = UnitAbilities.save_bonus(state, target, Callable(Morale, "objective_control"))

static func armoured_wrath_available(pending_attack: Dictionary, context: Dictionary, kind: String) -> bool:
	if not context.get("armoured_wrath", false) or kind not in ["hit", "wound", "damage"]: return false
	var used: Dictionary = pending_attack.get("armoured_wrath_used", {})
	if bool(context.get("armoured_wrath_full", false)): return not bool(used.get(kind, false))
	return not bool(used.get("any", false))

static func consume_armoured_wrath(pending_attack: Dictionary, context: Dictionary, kind: String) -> void:
	var used: Dictionary = pending_attack.get("armoured_wrath_used", {}).duplicate(true)
	if used.is_empty(): used = {"any": false, "hit": false, "wound": false, "damage": false}
	used[kind] = true
	if not bool(context.get("armoured_wrath_full", false)): used.any = true
	pending_attack.armoured_wrath_used = used

static func save_roll_outcome(state: Dictionary, current: Dictionary, model: int, roll: int) -> Dictionary:
	var profile := Groups.profile(state, model, state.pending_attack.melee)
	var bonus: int = state.pending_attack.get("ability_saves", {}).get(state.units[model].squad, 0)
	var armour_target := int(profile.get("save_target", 7)) - bonus - int(current.weapon.get("ap", 0))
	var invulnerable_target := int(profile.get("invulnerable_target", 0))
	var effective_invulnerable := invulnerable_target - bonus if invulnerable_target > 0 else 0
	var passed := roll != 1 and ((invulnerable_target > 0 and roll + bonus >= invulnerable_target) or roll + bonus + int(current.weapon.get("ap", 0)) >= int(profile.get("save_target", 7)))
	return {"roll": roll, "success": passed, "armour_target": armour_target, "invulnerable_target": effective_invulnerable, "ap": int(current.weapon.get("ap", 0)), "bonus": bonus}

static func saved(state: Dictionary, current: Dictionary, model: int, roll: int) -> bool:
	return bool(save_roll_outcome(state, current, model, roll).get("success", false))

static func _record_save_outcome(current: Dictionary, step_index: int, outcome: Dictionary) -> void:
	var step: Dictionary = current.steps[step_index]
	if step.get("outcome_recorded", false): return
	var outcomes: Array = []
	var stored_outcomes: Variant = current.result.get("save_outcomes", [])
	if stored_outcomes is Array: outcomes.assign(stored_outcomes)
	outcomes.append(outcome.duplicate(true))
	current.result.save_outcomes = outcomes
	step.outcome_recorded = true
	current.steps[step_index] = step

static func pump(state: Dictionary, roller: Callable) -> Dictionary:
	var pending: Dictionary = state.pending_attack
	while pending.index < pending.prepared.batches.size():
		var batch: Dictionary = pending.prepared.batches[pending.index]
		if pending.current.is_empty() or pending.current.get("phase") == "rolls":
			var defender := Groups.defender(state, batch.target, pending.melee)
			if not defender.error.is_empty(): return defender
			if defender.get("models", []).is_empty():
				pending.index += 1
				continue
			var context: Dictionary = batch.context.duplicate(true)
			context.defer_saves = true
			var rolled: Dictionary
			if context.get("martial_paragon", false) or context.get("free_hit_reroll", false) or context.get("free_wound_reroll", false) or context.get("machine_spirit_power", false) or context.get("armoured_wrath", false) or context.get("nightforged_attack_count", false) or state.get("stratagems", {}).get("attack_rerolls", false) or state.get("stratagems", {}).get("count_rerolls", false):
				if pending.current.is_empty():
					var checkpoint := RollWindows.begin(batch.weapon, defender, context, roller, state.get("stratagems", {}).get("count_rerolls", false) or context.get("nightforged_attack_count", false))
					if not checkpoint.error.is_empty(): return checkpoint
					pending.current = {"phase": "rolls", "target": batch.target, "checkpoint": checkpoint}
				while pending.current.checkpoint.phase != "complete":
					var checkpoint: Dictionary = pending.current.checkpoint
					var aquilon_key := str(batch.target)
					if not pending.aquilon_used.has(aquilon_key): pending.aquilon_used[aquilon_key] = {}
					if checkpoint.phase == "generation" and checkpoint.context.get("nightforged_attack_count", false) and not pending.current.get("nightforged_attack_count_decided", false) and not RollWindows.eligible(checkpoint).is_empty():
						state.unit_abilities.window = {"kind": "nightforged-attack-count", "owners": [pending.player]}
						return {"error": "", "complete": false}
					if checkpoint.phase == "hit" and checkpoint.context.get("machine_spirit_power", false) and not pending.machine_spirit_used.hit and not RollWindows.eligible(checkpoint).is_empty():
						state.unit_abilities.window = {"kind": "machine-spirit-hit", "owners": [pending.player], "source": checkpoint.context.get("machine_spirit_source", "Power of the Machine Spirit")}
						return {"error": "", "complete": false}
					if checkpoint.phase == "wound" and checkpoint.context.get("machine_spirit_power", false) and not pending.machine_spirit_used.wound and not checkpoint.effective_wounds.is_empty():
						state.unit_abilities.window = {"kind": "machine-spirit-wound", "owners": [pending.player], "source": checkpoint.context.get("machine_spirit_source", "Power of the Machine Spirit")}
						return {"error": "", "complete": false}
					if checkpoint.phase == "hit" and armoured_wrath_available(pending, checkpoint.context, "hit") and not RollWindows.eligible(checkpoint).is_empty():
						state.unit_abilities.window = {"kind": "armoured-wrath-hit", "owners": [pending.player], "full_rerolls": bool(checkpoint.context.get("armoured_wrath_full", false))}
						return {"error": "", "complete": false}
					if checkpoint.phase == "wound" and armoured_wrath_available(pending, checkpoint.context, "wound") and not checkpoint.effective_wounds.is_empty():
						state.unit_abilities.window = {"kind": "armoured-wrath-wound", "owners": [pending.player], "full_rerolls": bool(checkpoint.context.get("armoured_wrath_full", false))}
						return {"error": "", "complete": false}
					if checkpoint.phase == "hit" and checkpoint.context.get("martial_paragon", false) and not pending.martial_paragon_used.hit and not pending.current.get("martial_paragon_hit_decided", false) and not RollWindows.eligible(checkpoint).is_empty():
						state.unit_abilities.window = {"kind": "martial-paragon-hit", "owners": [pending.player]}
						return {"error": "", "complete": false}
					if checkpoint.phase == "wound" and checkpoint.context.get("martial_paragon", false) and not pending.martial_paragon_used.wound and not pending.current.get("martial_paragon_wound_decided", false) and not RollWindows.eligible(checkpoint).is_empty():
						state.unit_abilities.window = {"kind": "martial-paragon-wound", "owners": [pending.player]}
						return {"error": "", "complete": false}
					if checkpoint.phase == "hit" and checkpoint.context.get("free_hit_reroll", false) and not pending.aquilon_used[aquilon_key].get("hit", false) and not RollWindows.eligible(checkpoint).is_empty():
						state.unit_abilities.window = {"kind": "aquilon-hit", "owners": [pending.player]}
						return {"error": "", "complete": false}
					var free_wound_choices := RollWindows.eligible(checkpoint)
					if checkpoint.context.get("venator_successful_twos_choice", false): free_wound_choices = RollWindows.eligible_natural_wounds(checkpoint, 2)
					if checkpoint.phase == "wound" and checkpoint.context.get("free_wound_reroll", false) and not pending.current.get("free_done", false) and not free_wound_choices.is_empty() and (not checkpoint.context.get("aquilon_optics", false) or not pending.aquilon_used[aquilon_key].get("wound", false)):
						state.unit_abilities.window = {"kind": "wound", "owners": [pending.player]}
						return {"error": "", "complete": false}
					var enabled: bool = state.get("stratagems", {}).get("count_rerolls", false) if checkpoint.phase == "generation" else state.get("stratagems", {}).get("attack_rerolls", false)
					if checkpoint.phase == "hit" and checkpoint.context.get("snap_shooting", false): enabled = false
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
			rolled.merge({"target_squad": batch.target, "weapon_name": batch.weapon.name, "saves_passed": 0, "unsaved": 0, "models_destroyed": 0, "damage_applied": 0, "excess_damage_discarded": 0, "allocations": [], "casualty_retention_rolls": []})
			var candidates := Groups.precision_candidates(state, batch)
			pending.current = {"target": batch.target, "failed_rolls": [], "steps": [], "cursor": 0, "damage": batch.weapon.damage, "weapon": batch.weapon,
				"free_damage_reroll": batch.context.get("free_damage_reroll", false), "aquilon_optics": batch.context.get("aquilon_optics", false),
				"armoured_wrath": batch.context.get("armoured_wrath", false), "armoured_wrath_full": batch.context.get("armoured_wrath_full", false),
				"result": rolled, "groups": Groups.groups(state, batch.target, pending.melee), "order": [], "precision": -1, "precision_candidates": candidates,
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
		if current.phase == "damage_ability": return {"error": "", "complete": false}
		if current.phase == "damage_after_ability":
			var stored: Dictionary = current.pending_damage
			current.phase = "damage"
			var committed := _commit_damage_roll(state, stored.model, stored.rolled, roller)
			if not committed.error.is_empty(): return committed
			if current.phase == "damage_decision": return {"error": "", "complete": false}
		if current.phase == "damage_decision": return {"error": "", "complete": false}
		if current.phase == "damage_finalize":
			var finalized := _apply_rolled_damage(state, current.pending_damage.model, current.pending_damage.rolled, roller, false)
			if not finalized.error.is_empty(): return finalized
			current.erase("pending_damage")
			current.phase = "damage"
		while current.cursor < current.steps.size():
			var choices := eligible(state)
			if choices.is_empty(): break
			var step_index: int = current.cursor
			var step: Dictionary = current.steps[step_index]
			if step.kind == "devastating":
				var offered_windows: Dictionary = current.get("layered_ceramite_offered", {})
				if not offered_windows.get(int(current.cursor), false):
					var defender_owner := int(state.squads[current.target].owner)
					var mortal_protection_available := false
					for option: Dictionary in DetachmentStratagems.mortal_wound_stratagem_choices(state, defender_owner):
						if int(option.get("target", -1)) == int(current.target): mortal_protection_available = true
					offered_windows[int(current.cursor)] = true
					current.layered_ceramite_offered = offered_windows
					if mortal_protection_available:
						state.unit_abilities.window = {"kind": DetachmentStratagems.LAYERED_CERAMITE_WINDOW, "owners": [defender_owner], "squad": int(current.target), "allocation_cursor": int(current.cursor)}
						return {"error": "", "complete": false}
			if step.kind == "normal":
				var save_outcome := save_roll_outcome(state, current, choices[0], int(step.save_roll))
				var save_succeeded: bool = save_outcome.success
				_record_save_outcome(current, step_index, save_outcome)
				if save_succeeded:
					current.result.saves_passed = int(current.result.get("saves_passed", 0)) + 1
					current.cursor += 1
					continue
			if not pending.assist: return {"error": "", "complete": false}
			var applied := apply(state, choices[0], roller)
			if not applied.error.is_empty(): return applied
			if current.phase in ["damage_decision", "damage_ability"]: return {"error": "", "complete": false}
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
	var pending: Dictionary = state.pending_attack
	var current: Dictionary = pending.current
	if current.phase == "precision":
		current.precision = model
		current.phase = "order"
		return {"error": ""}
	if current.phase == "order":
		Groups.choose_order(current, model)
		return {"error": ""}
	var rolled := Attacks.RandomStat.roll(current.damage, roller)
	if not rolled.error.is_empty(): return rolled
	var aquilon_key := str(current.target)
	if not pending.aquilon_used.has(aquilon_key): pending.aquilon_used[aquilon_key] = {}
	var aquilon_available: bool = not current.get("aquilon_optics", false) or not pending.aquilon_used[aquilon_key].get("damage", false)
	var reroll_sources: Array[String] = []
	if current.get("free_damage_reroll", false) and aquilon_available and not rolled.rolls.is_empty() and not current.get("damage_reroll_offered", false):
		reroll_sources.append("Aquilon Optics" if current.get("aquilon_optics", false) else "Total Obliteration")
	var armoured_context := {"armoured_wrath": current.get("armoured_wrath", false), "armoured_wrath_full": current.get("armoured_wrath_full", false)}
	if not rolled.rolls.is_empty() and armoured_wrath_available(pending, armoured_context, "damage"):
		reroll_sources.append("Armoured Wrath")
	if not reroll_sources.is_empty():
		current.pending_damage = {"model": model, "rolled": rolled}
		current.damage_reroll_offered = true
		current.phase = "damage_ability"
		current.damage_reroll_sources = reroll_sources.duplicate()
		current.result.dice_history.append_array(rolled.rolls)
		if "Aquilon Optics" in reroll_sources: pending.aquilon_used[aquilon_key].damage = true
		state.unit_abilities.window = {"kind": "damage-reroll", "owners": [state.pending_attack.player], "source": reroll_sources[0], "sources": reroll_sources.duplicate()}
		return {"error": ""}
	return _commit_damage_roll(state, model, rolled, roller)

static func _commit_damage_roll(state: Dictionary, model: int, rolled: Dictionary, roller: Callable) -> Dictionary:
	var current: Dictionary = state.pending_attack.current
	var pending: Dictionary = state.pending_attack
	if state.get("stratagems", {}).get("damage_rerolls", false) and not rolled.rolls.is_empty() and rolled.get("rerolls", []).is_empty() and Stratagems.eligibility_error(state, pending.player, pending.squad, "command-re-roll").is_empty():
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
	var special_kind := "psychic" if current.weapon.get("keywords", {}).get("psychic", false) else ""
	var prevented := Attacks.Prevention.resolve(UnitAbilities.damage(state, model, int(rolled.value), "normal" if step.kind == "normal" else "mortal"), before, UnitPrevention.rules(state, model), "normal" if step.kind == "normal" else "mortal", roller, special_kind)
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
	if state.units[model].wounds == 0:
		var held: Dictionary = DetachmentStratagems.hold_destroyed(state, model, roller)
		if not held.error.is_empty(): return held
		if held.has("roll"):
			var retention_rolls: Array = current.result.get("casualty_retention_rolls", []).duplicate(true)
			retention_rolls.append({"model": model, "rule_name": str(held.get("rule_name", "Model retention")), "roll": int(held.roll), "modifier": int(held.get("modifier", 0)), "total": int(held.roll) + int(held.get("modifier", 0)), "kept": bool(held.held)})
			current.result.casualty_retention_rolls = retention_rolls
		if not held.held:
			current.result.models_destroyed += 1
			BloodAngelsCharacters.record_death_visions(state, model)
			DetachmentStratagems.record_destroyed(state, model)
		if not held.held:
			var cenobytes_destroyed := ChaplainGrimaldus.destroy_cenobytes(state, model)
			current.result.models_destroyed += cenobytes_destroyed.size()
			for cenobyte: int in cenobytes_destroyed: DetachmentStratagems.record_destroyed(state, cenobyte)
	current.result.allocations.append({"model": model, "kind": step.kind, "save_roll": step.save_roll, "damage": applied, "rolled_damage": rolled.value, "damage_rolls": rolled.rolls, "discarded": prevented.discarded, "prevention": prevented})
	current.cursor += 1
	return {"error": ""}
