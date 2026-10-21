extends RefCounted
## Bounded characteristic expressions, never executable text.
static func spec(value: Variant) -> Dictionary:
	if (value is int or value is float) and is_finite(value) and value == floor(value) and value > 0 and value <= 10000:
		return {"error": "", "count": 0, "sides": 0, "bonus": int(value), "minimum": int(value), "maximum": int(value)}
	if not value is String: return {"error": "Expected a positive integer or bounded dice expression."}
	var pattern := RegEx.new()
	pattern.compile("^([1-9][0-9]?)?D(3|6)(?:\\+([0-9]{1,4}))?$")
	var found := pattern.search(value)
	if found == null: return {"error": "Supported random characteristics: D3/D6, up to 20 dice, optional +constant."}
	var count := 1 if found.get_string(1).is_empty() else int(found.get_string(1))
	var sides := int(found.get_string(2))
	var bonus := 0 if found.get_string(3).is_empty() else int(found.get_string(3))
	if count > 20 or count * sides + bonus > 10000: return {"error": "Random characteristic exceeds limits."}
	return {"error": "", "count": count, "sides": sides, "bonus": bonus, "minimum": count + bonus, "maximum": count * sides + bonus}

static func add_bonus(value: Variant, extra: int) -> Variant:
	var parsed := spec(value)
	if not parsed.error.is_empty() or extra <= 0: return value
	if parsed.count == 0: return int(parsed.bonus) + extra
	var dice := "D%d" % parsed.sides if parsed.count == 1 else "%dD%d" % [parsed.count, parsed.sides]
	return dice if parsed.bonus + extra == 0 else "%s+%d" % [dice, parsed.bonus + extra]

static func random(value: Variant) -> bool:
	return value is String

static func replace_die(rolled: Dictionary, index: int, roller: Callable) -> Dictionary:
	var definition := spec(rolled.get("expression"))
	if not definition.error.is_empty(): return definition
	if index < 0 or index >= definition.count or rolled.get("rolls", []).size() != definition.count: return {"error": "Choose a die in this random characteristic roll."}
	if not rolled.get("rerolls", []).is_empty(): return {"error": "This characteristic has already been re-rolled."}
	if not roller.is_valid(): return {"error": "Missing host dice provider."}
	var replacement: Variant = roller.call()
	if not replacement is int or replacement < 1 or replacement > 6: return {"error": "Dice provider must return an integer from 1 to 6."}
	var next := rolled.duplicate(true)
	next.rerolls = [{"index": index, "original": next.rolls[index], "replacement": replacement}]
	next.rolls[index] = replacement
	next.value = int(definition.bonus)
	for value: int in next.rolls: next.value += ceili(float(value) / 2.0) if definition.sides == 3 else value
	return next

static func roll(value: Variant, roller: Callable) -> Dictionary:
	var definition := spec(value)
	if not definition.error.is_empty(): return definition
	if definition.count > 0 and not roller.is_valid(): return {"error": "Missing host dice provider."}
	var total: int = definition.bonus
	var rolls: Array[int] = []
	for index in range(definition.count):
		var die: Variant = roller.call()
		if not die is int or die < 1 or die > 6: return {"error": "Dice provider must return an integer from 1 to 6."}
		rolls.append(die)
		total += ceili(float(die) / 2.0) if definition.sides == 3 else die
	return {"error": "", "expression": value, "value": total, "rolls": rolls}
