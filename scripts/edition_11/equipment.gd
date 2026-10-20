extends RefCounted
const UnitAbilities = preload("res://scripts/edition_11/unit_abilities.gd")
const Traits = preload("res://scripts/edition_11/weapon_traits.gd")
const FiringDeck = preload("res://scripts/edition_11/firing_deck.gd")
const MarineEnhancements = preload("res://scripts/edition_11/stormlance_enhancements.gd")
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
			if melee and UnitAbilities.enabled(state) and UnitAbilities.identity(state.units[model]) == "captain" and state.unit_abilities.used.get("finest-active:%d" % model, -1) == state.turn:
				stats = stats.duplicate(true)
				stats.attacks = int(stats.attacks) + 3
				stats.keywords["devastating-wounds"] = true
			var label: String = stats.get("name", "Default weapon")
			if Traits.extra(stats): label += " [Extra Attacks]"
			if stats.get("keywords", {}).has("hunter"):
				var hunter: Variant = stats.keywords.hunter
				var names: Array[String] = []
				if hunter is Array:
					for keyword: Variant in hunter:
						if keyword is String: names.append(keyword)
				label += " [Hunter: %s]" % ("/".join(names) if not names.is_empty() else "unresolved")
			var option := {"weapon": weapon.id, "profile": profile, "label": label, "stats": stats}
			if weapon.has("firing_deck_source_model"):
				option.firing_deck_source_model = int(weapon.firing_deck_source_model)
			result.append(option)
	if melee and MarineEnhancements.imperiums_sword_bearer(state, model):
		var sword := {"id": "imperiums-sword", "name": "Imperium's Sword", "profiles": {"standard": {
			"name": "Imperium's Sword", "range_inches": 0.0, "attacks": 6, "skill": 2, "strength": 7, "ap": -3, "damage": 3, "keywords": {}}}}
		result.append({"weapon": sword.id, "profile": "standard", "label": sword.name, "stats": sword.profiles.standard})
	if not melee: result.append_array(FiringDeck.weapon_choices(state, model))
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
