extends RefCounted
## Persistent, source-bounded equipment for Deathwatch Veterans and Terminators.
const P = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const BaseTerminators = preload("res://scripts/edition_11/terminator_saved_equipment.gd")
const VETERANS := "40kdc:11e:adeptus-astartes:deathwatch-veterans"
const TERMINATORS := "40kdc:11e:adeptus-astartes:deathwatch-terminator-squad"

static func supports(definition: String) -> bool:
	return definition in [VETERANS, TERMINATORS]

static func sizes(definition: String) -> Array:
	return [5, 10] if supports(definition) else []

static func defaults(definition: String) -> Dictionary:
	if definition == VETERANS:
		return {"deathwatch_veteran_loadout": "default", "deathwatch_sergeant_ranged_loadout": "boltgun", "deathwatch_sergeant_melee_loadout": "power-weapon"}
	if definition == TERMINATORS:
		return {"deathwatch_terminator_melee_package": "power-fist", "terminator_special_weapon": ""}
	return {}

static func role(definition: String, models: int, model_index: int) -> String:
	if models not in sizes(definition) or model_index < 0 or model_index >= models: return ""
	if definition == VETERANS: return "watch-sergeant" if model_index == 0 else "deathwatch-veteran"
	return "deathwatch-terminator-sergeant" if model_index == 0 else "deathwatch-terminator"

static func controls(definition: String) -> Array[Dictionary]:
	if definition == VETERANS:
		var profile := P.profile("deathwatch-veterans")
		var veteran_labels := {
			"default": "Boltgun + Power Weapon",
			"stalker-pattern-boltgun": "Stalker-pattern Boltgun + Knives and Fists",
			"infernus-heavy-bolter": "Infernus Heavy Bolter + Knives and Fists",
			"deathwatch-shotgun": "Deathwatch Shotgun + Knives and Fists",
			"heavy-thunder-hammer": "Heavy Thunder Hammer",
			"frag-cannon": "Frag Cannon + Knives and Fists",
			"black-shield-blades": "Black Shield Blades",
			"boltgun-storm-shield": "Boltgun + Storm Shield",
			"power-weapon-storm-shield": "Power Weapon + Storm Shield"
		}
		var veteran_choices: Array[Dictionary] = []
		for loadout: String in profile.get("options", {}).get("veteran_loadouts", []):
			veteran_choices.append({"id": loadout, "label": str(veteran_labels.get(loadout, loadout))})
		return [
			{"field": "deathwatch_veteran_loadout", "label": "Veteran equipment", "choices": veteran_choices},
			{"field": "deathwatch_sergeant_ranged_loadout", "label": "Watch Sergeant ranged weapon", "choices": [{"id": "boltgun", "label": "Boltgun"}, {"id": "combi-weapon", "label": "Combi-weapon"}]},
			{"field": "deathwatch_sergeant_melee_loadout", "label": "Watch Sergeant melee weapon", "choices": [{"id": "power-weapon", "label": "Power Weapon"}, {"id": "xenophase-blade", "label": "Xenophase Blade"}]}
		]
	if definition == TERMINATORS:
		var profile := P.profile("deathwatch-terminator-squad")
		var package_labels := {
			"power-fist": "Power Fist + Storm Bolter",
			"storm-bolter-chainfist": "Chainfist + Storm Bolter",
			"storm-bolter-power-weapon": "Power Weapon + Storm Bolter",
			"thunder-hammer-storm-shield": "Thunder Hammer + Storm Shield (+1 W; +5 pts)",
			"twin-lightning-claws": "Twin Lightning Claws"
		}
		var package_choices: Array[Dictionary] = []
		for package: String in profile.get("options", {}).get("melee_packages", []):
			package_choices.append({"id": package, "label": str(package_labels.get(package, package))})
		var special_labels := {
			"": "Storm Bolter",
			"assault-cannon": "Assault Cannon",
			"cyclone-missile-launcher": "Cyclone Missile Launcher + Storm Bolter (+10 pts)",
			"heavy-flamer": "Heavy Flamer",
			"plasma-cannon": "Plasma Cannon"
		}
		var special_choices: Array[Dictionary] = [{"id": "", "label": special_labels[""]}]
		for special: String in profile.get("options", {}).get("special_weapons", []):
			special_choices.append({"id": special, "label": str(special_labels.get(special, special))})
		return [
			{"field": "deathwatch_terminator_melee_package", "label": "Melee package", "choices": package_choices},
			{"field": "terminator_special_weapon", "label": "Ranged special (max 3)", "choices": special_choices}
		]
	return []

static func controls_for_model(definition: String, models: int, model_index: int) -> Array[Dictionary]:
	var model_role := role(definition, models, model_index)
	if model_role.is_empty(): return []
	var result := controls(definition)
	if definition == VETERANS:
		if model_index == 0: return [result[1], result[2]]
		return [result[0]]
	if model_index == 0:
		result[1].choices = [{"id": "", "label": "Storm Bolter (no replacement)"}]
	return result

static func valid(definition: String, equipment: Variant, models: int) -> bool:
	return supports(definition) and models in sizes(definition) and BaseTerminators._valid_fields(equipment, controls(definition))

static func valid_saved(definition: String, loadout: Variant, models: int) -> bool:
	if not supports(definition) or models not in sizes(definition) or not loadout is Array or loadout.size() != models: return false
	var specials := 0
	var counts: Dictionary = {}
	for index in range(models):
		var equipment: Variant = loadout[index]
		if not valid(definition, equipment, models): return false
		if definition == VETERANS:
			if index == 0:
				if equipment.deathwatch_veteran_loadout != "default": return false
			else:
				if equipment.deathwatch_sergeant_ranged_loadout != "boltgun" or equipment.deathwatch_sergeant_melee_loadout != "power-weapon": return false
				var weapons := P.deathwatch_veteran_weapons(false, str(equipment.deathwatch_veteran_loadout))
				if weapons.is_empty(): return false
				var selected := str(equipment.deathwatch_veteran_loadout)
				counts[selected] = int(counts.get(selected, 0)) + 1
		else:
			var package := str(equipment.deathwatch_terminator_melee_package)
			var special := str(equipment.terminator_special_weapon)
			if index == 0 and not special.is_empty(): return false
			if not _keeps_storm_bolter(package) and not special.is_empty(): return false
			if not special.is_empty(): specials += 1
	if definition == VETERANS:
		var blocks := int(models / 5)
		for package: String in ["stalker-pattern-boltgun", "infernus-heavy-bolter", "frag-cannon"]:
			if int(counts.get(package, 0)) > blocks: return false
		for package: String in ["deathwatch-shotgun", "heavy-thunder-hammer"]:
			if int(counts.get(package, 0)) > 2 * blocks: return false
		if int(counts.get("black-shield-blades", 0)) > 1: return false
		var shields := int(counts.get("boltgun-storm-shield", 0)) + int(counts.get("power-weapon-storm-shield", 0))
		return shields <= 2 * blocks
	var source := P.profile("deathwatch-terminator-squad")
	return specials <= int(source.get("options", {}).get("max_special_weapons", 0))

static func points(definition: String, loadout: Variant, models: int) -> int:
	if not valid_saved(definition, loadout, models): return 0
	var source := P.profile(definition.get_slice(":", 3))
	var total := 0
	if definition == TERMINATORS:
		for equipment: Dictionary in loadout:
			if equipment.deathwatch_terminator_melee_package == "thunder-hammer-storm-shield": total += int(source.get("wargear_costs", {}).get("storm-shield", 0))
			if equipment.terminator_special_weapon == "cyclone-missile-launcher": total += int(source.get("wargear_costs", {}).get("cyclone-missile-launcher", 0))
	return total

static func prepare(unit: Dictionary, definition: String, equipment: Dictionary, models: int, model_index: int) -> void:
	if not valid(definition, equipment, models) or role(definition, models, model_index).is_empty(): return
	var source := P.profile(definition.get_slice(":", 3))
	var ranged: Array = source.get("ranged", []).duplicate(true)
	var melee: Array = source.get("melee", []).duplicate(true)
	if definition == VETERANS:
		var is_sergeant := model_index == 0
		var loadout := str(equipment.deathwatch_veteran_loadout)
		var weapons := P.deathwatch_veteran_weapons(is_sergeant, loadout, str(equipment.deathwatch_sergeant_ranged_loadout), str(equipment.deathwatch_sergeant_melee_loadout))
		if weapons.is_empty(): return
		ranged = weapons.ranged
		melee = weapons.melee
		unit.deathwatch_veteran_loadout = loadout
		unit.deathwatch_sergeant_ranged_loadout = str(equipment.deathwatch_sergeant_ranged_loadout)
		unit.deathwatch_sergeant_melee_loadout = str(equipment.deathwatch_sergeant_melee_loadout)
		unit.deathwatch_veteran_storm_shield = not is_sergeant and loadout in ["boltgun-storm-shield", "power-weapon-storm-shield"]
	else:
		var package := str(equipment.deathwatch_terminator_melee_package)
		var melee_id := ""
		match package:
			"storm-bolter-chainfist": melee_id = "chainfist"
			"storm-bolter-power-weapon": melee_id = "power-weapon"
			"thunder-hammer-storm-shield": melee_id = "thunder-hammer"
			"twin-lightning-claws": melee_id = "twin-lightning-claws"
		if not melee_id.is_empty(): melee = [P.additional_weapon("deathwatch-terminator-squad", "melee", melee_id)]
		if package in ["thunder-hammer-storm-shield", "twin-lightning-claws"]: ranged.clear()
		var special := str(equipment.terminator_special_weapon)
		if special in ["assault-cannon", "heavy-flamer", "plasma-cannon"]:
			ranged = ranged.filter(func(weapon: Dictionary) -> bool: return str(weapon.get("id", "")) != "storm-bolter")
		if not special.is_empty(): ranged.append(P.additional_weapon("deathwatch-terminator-squad", "ranged", special))
		var shield := package == "thunder-hammer-storm-shield"
		unit.deathwatch_terminator_melee_package = package
		unit.deathwatch_terminator_storm_shield = shield
		unit.terminator_special_weapon = special
		unit.max_wounds = int(source.get("stats", {}).get("wounds", unit.get("max_wounds", unit.get("wounds", 1)))) + (1 if shield else 0)
		unit.wounds = unit.max_wounds
		unit.defense = {"toughness": source.stats.toughness, "save_target": source.stats.save_target, "invulnerable_target": source.stats.invulnerable_target}
	if ranged.has({}) or melee.has({}): return
	unit.ranged_weapons = ranged
	unit.melee_weapons = melee
	unit.sergeant = model_index == 0
	unit.model_role = role(definition, models, model_index)
	unit.deathwatch_saved_model_loadout_locked = true

static func _keeps_storm_bolter(package: String) -> bool:
	return package in ["power-fist", "storm-bolter-chainfist", "storm-bolter-power-weapon"]
