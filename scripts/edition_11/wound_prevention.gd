extends RefCounted
## One applicable Feel No Pain roll per prospective wound; never stack rolls.
static func describe(rules: Variant) -> String:
	if not validate(rules).is_empty(): return "unresolved rule"
	var labels: Array[String] = []
	for rule: Dictionary in rules: labels.append("%d+ (%s wounds)" % [rule.target, "all" if rule.against == "any" else rule.against])
	return ", ".join(labels)

static func validate(rules: Variant) -> String:
	if not rules is Array or rules.size() > 32: return "Invalid Feel No Pain rules."
	for rule: Variant in rules:
		if not rule is Dictionary or rule.size() != 2: return "Feel No Pain needs only target and against."
		if not rule.get("target") is int or rule.target < 2 or rule.target > 6: return "Feel No Pain target must be 2–6."
		if rule.get("against") not in ["any", "normal", "mortal", "psychic"]: return "Unsupported Feel No Pain condition."
	return ""

static func resolve(damage: int, wounds: int, rules: Variant, kind: String, roller: Callable, special_kind: String = "") -> Dictionary:
	var error := validate(rules)
	if not error.is_empty(): return {"error": error}
	if damage < 0 or damage > 10000 or wounds <= 0 or kind not in ["normal", "mortal"] or special_kind not in ["", "psychic"]: return {"error": "Invalid wound prevention packet."}
	var target := 0
	for rule: Dictionary in rules:
		if rule.against in ["any", kind, special_kind] and (target == 0 or rule.target < target): target = rule.target
	var lost := 0
	var prevented := 0
	var rolls: Array[int] = []
	for point in range(damage):
		if lost == wounds: break
		if target > 0:
			if not roller.is_valid(): return {"error": "Missing Feel No Pain dice provider."}
			var die: Variant = roller.call()
			if not die is int or die < 1 or die > 6: return {"error": "Feel No Pain dice must be integers from 1 to 6."}
			rolls.append(die)
			if die >= target:
				prevented += 1
				continue
		lost += 1
	return {"error": "", "target": target, "rolls": rolls, "lost": lost, "prevented": prevented, "discarded": damage - lost - prevented}
