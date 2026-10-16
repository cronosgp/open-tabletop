extends RefCounted
## Serializable hit/wound checkpoints. Session ownership, CP and publication belong
## to the command layer; this module never authorizes a stratagem by itself.
const Attacks = preload("res://scripts/edition_11/attack_sequence.gd")
const IMPLEMENTATION := "attack-roll-checkpoints-v1"

static func begin(weapon: Dictionary, defender: Dictionary, context: Dictionary, roller: Callable, pause_generation: bool = false) -> Dictionary:
	var error := Attacks._validate(weapon, defender, context)
	if not error.is_empty(): return {"error": error}
	if not roller.is_valid(): return {"error": "Missing dice provider."}
	if defender.get("mixed", false) and not context.get("defer_saves", false): return {"error": "Mixed defenders require the unit allocation engine before saves."}
	var generated := Attacks.generate_attacks(weapon, context.duplicate(true), roller)
	if not generated.error.is_empty(): return generated
	var keywords: Dictionary = weapon.get("keywords", {})
	var covered: bool = context.get("benefit_of_cover", false) and not keywords.get("ignores-cover", false)
	var modifier: int = context.get("hit_modifier", 0)
	if keywords.get("heavy", false) and context.heavy_eligible: modifier = clampi(modifier + 1, -1, 1)
	var dice := Attacks.Dice.new(roller)
	var hits: Array[int] = []
	if not pause_generation and not keywords.get("torrent", false):
		for index in range(generated.count): hits.append(dice.d6())
	if not dice.error.is_empty(): return {"error": dice.error}
	var history: Array = generated.rolls.duplicate()
	history.append_array(dice.history)
	return {"error": "", "implementation": IMPLEMENTATION, "phase": "generation" if pause_generation else "hit", "revision": 0,
		"weapon": weapon.duplicate(true), "defender": defender.duplicate(true), "context": context.duplicate(true),
		"generated": generated, "covered": covered, "effective_skill": mini(6, int(weapon.skill) + (1 if covered else 0)),
		"hit_modifier": modifier, "hit_rolls": hits, "wound_rolls": [], "effective_wounds": [],
		"rerolled_hits": [], "rerolled_wounds": [], "changes": [], "dice_history": history}

static func eligible(checkpoint: Dictionary) -> Array[int]:
	var result: Array[int] = []
	var phase: String = checkpoint.get("phase", "")
	if phase == "generation":
		var offset := 0
		for record: Dictionary in checkpoint.generated.records:
			for index in range(record.rolls.size()):
				if record.get("rerolls", []).is_empty(): result.append(offset + index)
			offset += record.rolls.size()
		return result
	if phase not in ["hit", "wound"]: return result
	var values: Array = checkpoint.hit_rolls if phase == "hit" else checkpoint.effective_wounds
	var used: Array = checkpoint.rerolled_hits if phase == "hit" else checkpoint.rerolled_wounds
	for index in range(values.size()):
		if index not in used: result.append(index)
	return result

static func reroll(checkpoint: Dictionary, index: int, revision: int, roller: Callable) -> Dictionary:
	if revision != checkpoint.get("revision", -1): return {"error": "Stale attack checkpoint."}
	if index not in eligible(checkpoint): return {"error": "Choose a die that has not already been re-rolled in this stage."}
	if not roller.is_valid(): return {"error": "Missing dice provider."}
	if checkpoint.phase == "generation":
		var next := checkpoint.duplicate(true)
		var offset := 0
		for record_index in range(next.generated.records.size()):
			var record: Dictionary = next.generated.records[record_index]
			if index < offset + record.rolls.size():
				var replaced := Attacks.RandomStat.replace_die(record, index - offset, roller)
				if not replaced.error.is_empty(): return replaced
				replaced.total = replaced.value + replaced.bonus
				next.generated.count += replaced.total - record.total
				if next.generated.count > 1000: return {"error": "Attack pool exceeds prototype limit."}
				next.generated.records[record_index] = replaced
				next.generated.rolls[index] = replaced.rolls[index - offset]
				next.dice_history.append(replaced.rolls[index - offset])
				next.changes.append({"phase": "generation", "index": index, "previous": record.rolls[index - offset], "replacement": replaced.rolls[index - offset]})
				next.revision += 1
				return next
			offset += record.rolls.size()
		return {"error": "Invalid attack generation die."}
	var dice := Attacks.Dice.new(roller)
	var value := dice.d6()
	if not dice.error.is_empty(): return {"error": dice.error}
	var next := checkpoint.duplicate(true)
	var hit: bool = next.phase == "hit"
	var values: Array = next.hit_rolls if hit else next.effective_wounds
	var previous: int = values[index]
	values[index] = value
	if hit: next.rerolled_hits.append(index)
	else:
		next.rerolled_wounds.append(index)
		next.wound_rolls.append(value)
	next.dice_history.append(value)
	next.changes.append({"phase": next.phase, "index": index, "previous": previous, "replacement": value})
	next.revision += 1
	return next

static func advance(checkpoint: Dictionary, revision: int, roller: Callable) -> Dictionary:
	if revision != checkpoint.get("revision", -1): return {"error": "Stale attack checkpoint."}
	if checkpoint.get("phase", "") not in ["generation", "hit", "wound"]: return {"error": "No attack roll stage to advance."}
	if not roller.is_valid(): return {"error": "Missing dice provider."}
	var next := checkpoint.duplicate(true)
	var keywords: Dictionary = next.weapon.keywords
	var dice := Attacks.Dice.new(roller)
	if next.phase == "generation":
		if not keywords.get("torrent", false):
			for index in range(next.generated.count): next.hit_rolls.append(dice.d6())
		next.phase = "hit"
	elif next.phase == "hit":
		var normal: int = next.generated.count if keywords.get("torrent", false) else 0
		var automatic := 0
		for value: int in next.hit_rolls:
			if not Attacks.successful_roll(value, next.effective_skill, next.hit_modifier): continue
			if value == 6 and keywords.get("lethal-hits", false) and next.context.get("use_lethal_hits", true): automatic += 1
			else: normal += 1
			if value == 6: normal += int(keywords.get("sustained-hits", 0))
		if normal + automatic > 10000: return {"error": "Hit pool exceeds prototype limit."}
		next.hits = normal + automatic
		next.automatic_wounds = automatic
		var target := Attacks.wound_target(int(next.weapon.strength), int(next.defender.toughness))
		var modifier: int = next.context.get("wound_modifier", 0)
		for index in range(normal): next.effective_wounds.append(dice.d6())
		next.wound_rolls = next.effective_wounds.duplicate()
		# Preserve batch ordering. Twin-linked replacements cannot receive a second
		# re-roll, including from a different rule.
		for index in range(normal):
			if not Attacks.reroll_wound(next.effective_wounds[index], target, modifier, next.weapon, next.context): continue
			var replacement := dice.d6()
			next.effective_wounds[index] = replacement
			next.wound_rolls.append(replacement)
			next.rerolled_wounds.append(index)
		next.phase = "wound"
	else:
		var target := Attacks.wound_target(int(next.weapon.strength), int(next.defender.toughness))
		var modifier: int = next.context.get("wound_modifier", 0)
		var wounds: int = next.automatic_wounds
		var critical := 0
		for value: int in next.effective_wounds:
			if Attacks.successful_roll(value, target, modifier): wounds += 1
			if value == 6: critical += 1
		var devastating: int = critical if keywords.get("devastating-wounds", false) else 0
		var saves: Array[int] = []
		if not next.context.get("defer_saves", false):
			for index in range(wounds - devastating): saves.append(dice.d6())
		saves.sort()
		next.result = {"error": "", "implementation": Attacks.IMPLEMENTATION, "attacks": next.generated.count,
			"benefit_of_cover": next.covered, "effective_skill": next.effective_skill,
			"hit_modifier": next.hit_modifier, "wound_modifier": modifier,
			"attack_generation": next.generated.records.duplicate(true), "damage_rolls": [], "hits": next.hits, "wounds": wounds,
			"critical_wounds": critical, "devastating_wounds": devastating, "devastating_attacks_resolved": 0,
			"save_count": wounds - devastating, "normal_damage_applied": 0, "mortal_damage_applied": 0,
			"prevented_wounds": 0, "prevention_rolls": [], "hit_rolls": next.hit_rolls.duplicate(),
			"wound_rolls": next.wound_rolls.duplicate(), "save_rolls": saves}
		next.phase = "complete"
	if not dice.error.is_empty(): return {"error": dice.error}
	next.dice_history.append_array(dice.history)
	if next.phase == "complete": next.result.dice_history = next.dice_history.duplicate()
	next.revision += 1
	return next
