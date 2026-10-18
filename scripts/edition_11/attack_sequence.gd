extends RefCounted
## Original implementation of the 11e identical-attack sequence, §§04.03–05.04.
## One homogeneous non-character allocation group; action eligibility is separate.
## Does not enable entire datasheets or faction rules by itself.

const RandomStat = preload("res://scripts/edition_11/random_characteristic.gd")
const Traits = preload("res://scripts/edition_11/weapon_traits.gd")
const Prevention = preload("res://scripts/edition_11/wound_prevention.gd")
const IMPLEMENTATION := "11e-identical-attacks-v4"
const SUPPORTED_KEYWORDS := ["lethal-hits", "rapid-fire", "sustained-hits", "torrent", "heavy", "twin-linked", "assault", "ignores-cover", "blast", "hazardous", "close-quarters", "hunter", "extra-attacks", "devastating-wounds", "precision", "cleave"]

class Dice:
	extends RefCounted
	var roller: Callable
	var error := ""
	var history: Array[int] = []
	func _init(callback: Callable) -> void:
		roller = callback
	func d6() -> int:
		var value: Variant = roller.call()
		if not value is int or value < 1 or value > 6:
			error = "Dice provider must return an integer from 1 to 6."
			return 1
		history.append(value)
		return value

static func wound_target(strength: int, toughness: int) -> int:
	if strength >= 2 * toughness: return 2
	if strength > toughness: return 3
	if strength == toughness: return 4
	if strength * 2 <= toughness: return 6
	return 5

static func successful_roll(unmodified: int, target: int, modifier: int = 0) -> bool:
	# Natural 1 fails and natural 6 succeeds independently of modifiers.
	return unmodified == 6 or (unmodified != 1 and unmodified + modifier >= target)

static func _positive_integer(value: Variant) -> bool:
	return (value is int or value is float) and is_finite(value) and value == floor(value) and value > 0 and value <= 10000

static func _validate(weapon: Dictionary, defender: Dictionary, context: Dictionary) -> String:
	if not defender.get("error", "").is_empty(): return defender.error
	for key in ["skill", "strength"]:
		if not _positive_integer(weapon.get(key)):
			return "Requires a positive fixed integer weapon stat: " + key
	for key in ["attacks", "damage"]:
		if not RandomStat.spec(weapon.get(key)).error.is_empty(): return "Invalid random/fixed characteristic: " + key
	if weapon.skill < 2 or weapon.skill > 6: return "Skill must be 2–6."
	var ap: Variant = weapon.get("ap")
	if not (ap is int or ap is float) or not is_finite(ap) or ap != floor(ap) or ap > 0 or ap < -10:
		return "AP must be an integer from -10 to 0."
	if not weapon.get("keywords", {}) is Dictionary: return "Invalid weapon keywords."
	for keyword: Variant in weapon.get("keywords", {}):
		if keyword not in SUPPORTED_KEYWORDS: return "Unsupported weapon mechanic: " + str(keyword)
		if keyword in ["rapid-fire", "sustained-hits", "cleave"] and not _positive_integer(weapon.keywords[keyword]):
			return "Keyword requires a positive integer: " + keyword
		if keyword not in ["rapid-fire", "sustained-hits", "blast", "hunter", "cleave"] and not weapon.keywords[keyword] is bool:
			return "Keyword flag requires a boolean: " + keyword
	var hunter_error := Traits.hunter_error(weapon, context.get("target_keywords"))
	if not hunter_error.is_empty(): return hunter_error
	if weapon.get("keywords", {}).has("blast") and not weapon.keywords.blast is bool and not _positive_integer(weapon.keywords.blast): return "Blast needs a boolean or positive integer."
	if weapon.get("keywords", {}).get("blast", false):
		if not context.get("target_model_count") is int or context.target_model_count < 0: return "Blast requires target size at selection."
		if context.get("target_engaged", false): return "Blast cannot target an engaged unit."
	for key in ["toughness", "save_target", "wounds_per_model"]:
		if not _positive_integer(defender.get(key)): return "Invalid defender stat: " + key
	if defender.save_target < 2 or defender.save_target > 7: return "Save must be 2–7."
	var invulnerable: Variant = defender.get("invulnerable_target", 0)
	if invulnerable != 0 and (not _positive_integer(invulnerable) or invulnerable < 2 or invulnerable > 6):
		return "Invulnerable save must be 0 or 2–6."
	if not defender.get("remaining_wounds") is Array or defender.remaining_wounds.is_empty():
		return "Requires remaining wounds for each defending model."
	var wounded := 0
	for wounds: Variant in defender.remaining_wounds:
		if not _positive_integer(wounds) or wounds > defender.wounds_per_model: return "Invalid remaining wounds."
		if wounds < defender.wounds_per_model: wounded += 1
	if wounded > 1 and not defender.get("mixed", false): return "This allocation group cannot contain multiple wounded models."
	var prevention: Variant = defender.get("prevention", [])
	if not prevention is Array or (not prevention.is_empty() and prevention.size() != defender.remaining_wounds.size()): return "Invalid defender prevention profiles."
	for rules: Variant in prevention:
		var prevention_error := Prevention.validate(rules)
		if not prevention_error.is_empty(): return prevention_error
	var shooters: Variant = context.get("weapon_count", 1)
	if not _positive_integer(shooters) or RandomStat.spec(weapon.attacks).maximum * shooters > 1000:
		return "Invalid or excessive identical weapon count."
	if not context.has("attack_sources"):
		var maximum: int = RandomStat.spec(weapon.attacks).maximum
		if weapon.get("keywords", {}).has("rapid-fire") and context.get("distance_inches", INF) <= float(weapon.get("range_inches", 0)) / 2.0: maximum += int(weapon.keywords["rapid-fire"])
		if weapon.get("keywords", {}).get("blast", false): maximum += (1 if weapon.keywords.blast is bool else int(weapon.keywords.blast)) * floori(float(context.target_model_count) / 5.0)
		if maximum * shooters > 1000: return "Attack generation exceeds prototype limit."
	if context.has("attack_sources"):
		if not context.attack_sources is Array or context.attack_sources.is_empty() or context.attack_sources.size() > 256: return "Invalid attack generation sources."
		var maximum := 0
		for source: Variant in context.attack_sources:
			if not source is Dictionary or not source.get("bonus") is int or source.bonus < 0: return "Invalid attack generation source."
			var definition := RandomStat.spec(source.get("expression"))
			if not definition.error.is_empty(): return definition.error
			maximum += definition.maximum + source.bonus
		if maximum > 1000: return "Attack pool exceeds prototype limit."
	if not context.get("unresolved_effects", []) is Array or not context.get("unresolved_effects", []).is_empty():
		return "Unresolved effects must be implemented before resolving this attack."
	if context.get("wound_reroll", "none") not in ["none", "ones", "failed"]: return "Unsupported wound re-roll mode."
	if context.get("hit_reroll", "none") not in ["none", "failed", "ones"]: return "Unsupported hit re-roll mode."
	for key in ["hit_modifier", "wound_modifier"]:
		var value: Variant = context.get(key, 0)
		if not (value is int or value is float) or not is_finite(value) or value != floor(value) or absf(value) > 1:
			return "Only final roll modifiers between -1 and +1 are accepted."
	var keywords: Dictionary = weapon.get("keywords", {})
	if not context.get("benefit_of_cover", false) is bool: return "Benefit of cover must be a boolean computed by the match rules."
	if keywords.has("rapid-fire"):
		var distance: Variant = context.get("distance_inches")
		var weapon_range: Variant = weapon.get("range_inches")
		if not (distance is int or distance is float) or not is_finite(distance) or distance < 0:
			return "Rapid Fire requires distance at target selection."
		if not (weapon_range is int or weapon_range is float) or not is_finite(weapon_range) or weapon_range <= 0:
			return "Rapid Fire requires a positive weapon range."
	if keywords.get("heavy", false) and not context.get("heavy_eligible") is bool:
		return "Heavy requires eligibility computed by the match rules."
	return ""

static func roll_pool(weapon: Dictionary, defender: Dictionary, context: Dictionary, roller: Callable) -> Dictionary:
	if defender.get("mixed", false) and not context.get("defer_saves", false): return {"error": "Mixed defenders require the unit allocation engine before saves."}
	var error := _validate(weapon, defender, context)
	if not error.is_empty(): return {"error": error}
	if not roller.is_valid(): return {"error": "Missing dice provider."}
	var dice := Dice.new(roller)
	var keywords: Dictionary = weapon.get("keywords", {})
	var generated := generate_attacks(weapon, context, roller)
	if not generated.error.is_empty(): return generated
	var count: int = generated.count
	dice.history.append_array(generated.rolls)
	var hit_modifier: int = int(context.get("hit_modifier", 0))
	var covered: bool = context.get("benefit_of_cover", false) and not keywords.get("ignores-cover", false)
	var effective_skill := mini(6, int(weapon.skill) + (1 if covered else 0))
	if keywords.get("heavy", false) and context.heavy_eligible:
		hit_modifier = clampi(hit_modifier + 1, -1, 1)
	var hit_rolls: Array[int] = []
	var wound_rolls: Array[int] = []
	var save_rolls: Array[int] = []
	var normal_hits := 0
	var automatic_wounds := 0
	var effective_hits: Array[int] = []
	if keywords.get("torrent", false): normal_hits = count
	else:
		for attack in range(count): effective_hits.append(dice.d6())
		hit_rolls.append_array(effective_hits)
		var replacements := reroll_hit_pool(effective_hits, effective_skill, hit_modifier, context, dice)
		for replacement: Dictionary in replacements: hit_rolls.append(replacement.replacement)
	for roll: int in effective_hits:
		if context.get("snap_shooting", false):
			if roll != 6: continue
			normal_hits += 1
			continue
		if not successful_roll(roll, effective_skill, hit_modifier): continue
		if roll == 6 and keywords.get("lethal-hits", false) and context.get("use_lethal_hits", true):
			automatic_wounds += 1
		else: normal_hits += 1
		if roll == 6: normal_hits += int(keywords.get("sustained-hits", 0))
	if normal_hits + automatic_wounds > 10000:
		return {"error": "Hit pool exceeds prototype limit."}
	var wounds := automatic_wounds
	var critical_wounds := 0
	var target := wound_target(int(weapon.strength), int(defender.toughness))
	var wound_modifier: int = int(context.get("wound_modifier", 0))
	# Roll the original pool first, then replace eligible dice once.
	var effective: Array[int] = []
	for hit in range(normal_hits): effective.append(dice.d6())
	wound_rolls.append_array(effective)
	for index in range(effective.size()):
		if not reroll_wound(effective[index], target, wound_modifier, weapon, context): continue
		effective[index] = dice.d6()
		wound_rolls.append(effective[index])
	for roll: int in effective:
		if successful_roll(roll, target, wound_modifier): wounds += 1
		if roll == 6: critical_wounds += 1
	var devastating := critical_wounds if keywords.get("devastating-wounds", false) else 0
	if not context.get("defer_saves", false):
		for wound in range(wounds - devastating): save_rolls.append(dice.d6())
	save_rolls.sort()
	if not dice.error.is_empty(): return {"error": dice.error}
	return {"error": "", "implementation": IMPLEMENTATION, "attacks": count,
		"benefit_of_cover": covered, "effective_skill": effective_skill,
		"hit_modifier": hit_modifier, "wound_modifier": wound_modifier, "wound_target": target,
		"snap_shooting": context.get("snap_shooting", false),
		"attack_generation": generated.records, "damage_rolls": [], "hits": normal_hits + automatic_wounds, "wounds": wounds,
		"critical_wounds": critical_wounds, "devastating_wounds": devastating, "devastating_attacks_resolved": 0,
		"save_count": wounds - devastating,
		"normal_damage_applied": 0, "mortal_damage_applied": 0,
		"prevented_wounds": 0, "prevention_rolls": [],
		"hit_rolls": hit_rolls, "wound_rolls": wound_rolls,
		"final_hit_rolls": effective_hits.duplicate(), "final_wound_rolls": effective.duplicate(),
		"save_rolls": save_rolls, "dice_history": dice.history}

static func allocation_steps(result: Dictionary, weapon: Dictionary, defender: Dictionary) -> Array[Dictionary]:
	var steps: Array[Dictionary] = []
	for roll: int in result.save_rolls:
		var invulnerable := int(defender.get("invulnerable_target", 0))
		var saved: bool = roll != 1 and ((invulnerable > 0 and roll >= invulnerable) or roll + int(weapon.ap) >= int(defender.save_target))
		if not saved: steps.append({"kind": "normal", "save_roll": roll})
	# Each critical wound is a separate mortal packet, after this pool's normal damage.
	for index in range(int(result.devastating_wounds)): steps.append({"kind": "devastating", "save_roll": 0})
	return steps

static func generate_attacks(weapon: Dictionary, context: Dictionary, roller: Callable) -> Dictionary:
	var sources: Array = context.get("attack_sources", [])
	if sources.is_empty():
		var bonus := 0
		if weapon.keywords.has("rapid-fire") and context.distance_inches <= weapon.range_inches / 2.0: bonus += int(weapon.keywords["rapid-fire"])
		if weapon.keywords.get("blast", false): bonus += (1 if weapon.keywords.blast is bool else int(weapon.keywords.blast)) * floori(float(context.target_model_count) / 5.0)
		for index in range(int(context.get("weapon_count", 1))): sources.append({"expression": weapon.attacks, "bonus": bonus})
	var count := 0
	var rolls: Array[int] = []
	var records: Array[Dictionary] = []
	for source: Dictionary in sources:
		var generated := RandomStat.roll(source.expression, roller)
		if not generated.error.is_empty(): return generated
		generated.bonus = int(source.get("bonus", 0))
		generated.total = generated.value + generated.bonus
		generated.model = source.get("model", -1)
		generated.weapon = source.get("weapon", "default")
		count += generated.total
		if count > 1000: return {"error": "Attack pool exceeds prototype limit."}
		rolls.append_array(generated.rolls)
		records.append(generated)
	return {"error": "", "count": count, "rolls": rolls, "records": records}

static func resolve(weapon: Dictionary, defender: Dictionary, context: Dictionary, roller: Callable) -> Dictionary:
	if defender.get("mixed", false) or weapon.get("keywords", {}).get("precision", false): return {"error": "Use the unit allocation engine for mixed groups or Precision."}
	var result := roll_pool(weapon, defender, context, roller)
	if not result.error.is_empty(): return result
	var steps := allocation_steps(result, weapon, defender)
	var remaining: Array = defender.remaining_wounds.duplicate()
	var profiles: Array[Dictionary] = []
	for index in range(remaining.size()): profiles.append({"wounds": remaining[index], "index": index, "rules": defender.prevention[index] if not defender.get("prevention", []).is_empty() else []})
	profiles.sort_custom(func(a: Dictionary, b: Dictionary): return a.wounds < b.wounds if a.wounds != b.wounds else a.index < b.index)
	# Wounded model is selected first within the homogeneous group.
	remaining.sort()
	var unsaved := 0
	var applied_damage := 0
	var lost_damage := 0
	for step: Dictionary in steps:
		if remaining.is_empty(): break
		if step.kind == "normal": unsaved += 1
		else: result.devastating_attacks_resolved += 1
		var rolled_damage := RandomStat.roll(weapon.damage, roller)
		if not rolled_damage.error.is_empty(): return rolled_damage
		result.damage_rolls.append(rolled_damage)
		result.dice_history.append_array(rolled_damage.rolls)
		var damage: int = rolled_damage.value
		var prevented := Prevention.resolve(damage, int(remaining[0]), profiles[0].rules, "normal" if step.kind == "normal" else "mortal", roller)
		if not prevented.error.is_empty(): return prevented
		result.prevention_rolls.append(prevented)
		result.prevented_wounds += prevented.prevented
		result.dice_history.append_array(prevented.rolls)
		var actual: int = prevented.lost
		applied_damage += actual
		if step.kind == "normal": result.normal_damage_applied += actual
		else: result.mortal_damage_applied += actual
		lost_damage += prevented.discarded
		remaining[0] -= actual
		if remaining[0] <= 0:
			remaining.pop_front()
			profiles.pop_front()
	result.unsaved = unsaved
	result.models_destroyed = defender.remaining_wounds.size() - remaining.size()
	result.damage_applied = applied_damage
	result.excess_damage_discarded = lost_damage
	result.remaining_wounds = remaining
	return result

static func reroll_wound(value: int, target: int, modifier: int, weapon: Dictionary, context: Dictionary) -> bool:
	# Training policy: preserve successful rolls; never fish for critical wounds.
	var failed := not successful_roll(value, target, modifier)
	var mode: String = context.get("wound_reroll", "none")
	return (mode == "ones" and value == 1) or (failed and (mode == "failed" or (weapon.get("keywords", {}).get("twin-linked", false) and context.get("use_twin_linked", true))))

static func reroll_hit_pool(values: Array, skill: int, modifier: int, context: Dictionary, dice: Dice) -> Array:
	var changes: Array = []
	if context.get("snap_shooting", false): return changes
	var mode: String = context.get("hit_reroll", "none")
	if mode not in ["failed", "ones"]: return changes
	# Training policy keeps successes; replacement dice cannot be rerolled again.
	for index in range(values.size()):
		if mode == "ones" and values[index] != 1: continue
		if mode == "failed" and successful_roll(values[index], skill, modifier): continue
		var original: int = values[index]
		values[index] = dice.d6()
		changes.append({"phase": "hit", "index": index, "original": original, "replacement": values[index], "source": "hit-reroll"})
	return changes
