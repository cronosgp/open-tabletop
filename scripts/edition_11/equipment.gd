extends RefCounted
const Traits = preload("res://scripts/edition_11/weapon_traits.gd")
## Server-owned weapon instances and profiles. Legacy squads expose one default.

static func inventory(state: Dictionary, model: int, melee: bool) -> Array:
	var key := "melee_weapons" if melee else "ranged_weapons"
	if state.units[model].has(key): return state.units[model][key]
	var stats: Dictionary = state.squads[state.units[model].squad].melee_weapon if melee else state.squads[state.units[model].squad].weapon
	return [{"id": "default", "name": stats.get("name", "Default weapon"), "profiles": {"default": stats}}]

static func choices(state: Dictionary, model: int, melee: bool) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for weapon: Dictionary in inventory(state, model, melee):
		for profile: String in weapon.profiles:
			var stats: Dictionary = weapon.profiles[profile]
			var label: String = stats.get("name", "Default weapon")
			if Traits.extra(stats): label += " [Extra Attacks]"
			if stats.get("keywords", {}).has("hunter"):
				var hunter: Variant = stats.keywords.hunter
				var names: Array[String] = []
				if hunter is Array:
					for keyword: Variant in hunter:
						if keyword is String: names.append(keyword)
				label += " [Hunter: %s]" % ("/".join(names) if not names.is_empty() else "unresolved")
			result.append({"weapon": weapon.id, "profile": profile, "label": label, "stats": stats})
	# Identical weapon instances still need distinct choices in the planner.
	var counts: Dictionary = {}
	var ordinal: Dictionary = {}
	for option: Dictionary in result: counts[option.label] = int(counts.get(option.label, 0)) + 1
	for option: Dictionary in result:
		var label: String = option.label
		if counts[label] > 1:
			ordinal[label] = int(ordinal.get(label, 0)) + 1
			option.label += " (weapon %d)" % ordinal[label]
	return result

static func select(state: Dictionary, model: int, melee: bool, weapon: String = "", profile: String = "") -> Dictionary:
	var options := choices(state, model, melee)
	if weapon.is_empty() and profile.is_empty(): return options[0] if not options.is_empty() else {"error": "This model has no supported weapon."}
	for option: Dictionary in options:
		if option.weapon == weapon and option.profile == profile: return option
	return {"error": "That model does not own the selected weapon/profile."}

static func explicit_loadout(state: Dictionary, model: int, melee: bool) -> bool:
	return state.units[model].has("melee_weapons" if melee else "ranged_weapons")
