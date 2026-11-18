extends RefCounted
## Persistent equipment for the existing admitted standard, Assault and Wolf Guard profiles.
const P = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const STANDARD := "40kdc:11e:adeptus-astartes:terminator-squad"
const ASSAULT := "40kdc:11e:adeptus-astartes:terminator-assault-squad"
const WOLVES := "40kdc:11e:adeptus-astartes:wolf-guard-terminators"
static func supports(definition: String) -> bool:
	return definition in [STANDARD, ASSAULT, WOLVES]
static func defaults(definition: String) -> Dictionary:
	return {"terminator_melee_choice": "power-fist", "terminator_special_weapon": ""} if definition == STANDARD else {"terminator_assault_storm_shield": false} if definition == ASSAULT else {"wolf_guard_terminator_loadout": "default"} if definition == WOLVES else {}
static func role(definition: String, models: int, model_index: int) -> String:
	if not supports(definition) or models not in [5, 10] or model_index < 0 or model_index >= models: return ""
	return ("pack-leader" if definition == WOLVES else "sergeant") if model_index == 0 else "terminator"
static func controls(definition: String) -> Array[Dictionary]:
	if definition == STANDARD: return [{"field": "terminator_melee_choice", "label": "Melee", "choices": [{"id": "power-fist", "label": "Power Fist"}, {"id": "chainfist", "label": "Chainfist"}, {"id": "power-weapon", "label": "Power Weapon"}]}, {"field": "terminator_special_weapon", "label": "Primary (1 special / 5)", "choices": [{"id": "", "label": "Storm Bolter"}, {"id": "assault-cannon", "label": "Assault Cannon"}, {"id": "heavy-flamer", "label": "Heavy Flamer"}, {"id": "cyclone-missile-launcher", "label": "Cyclone + Storm Bolter (+10 pts)"}]}]
	if definition == ASSAULT: return [{"field": "terminator_assault_storm_shield", "label": "Loadout", "choices": [{"id": false, "label": "Twin Lightning Claws"}, {"id": true, "label": "Thunder Hammer + Storm Shield (+5 pts, +1 W)"}]}]
	if definition == WOLVES:
		var options: Dictionary = P.profile("wolf-guard-terminators").options
		var names := {"default": "Storm Bolter + Master-crafted Power Weapon", "storm-shield": "Master-crafted Power Weapon + Storm Shield (+5 pts, +1 W)", "relic-greataxe": "Relic Greataxe", "twin-lightning-claws": "Twin Lightning Claws", "assault-cannon-power-fist": "Assault Cannon + Power Fist (1 per 5)"}
		var choices: Array[Dictionary] = []
		for package: String in options.pack_leader_loadouts + options.terminator_loadouts:
			if not choices.any(func(c: Dictionary) -> bool: return c.id == package): choices.append({"id": package, "label": names[package]})
		return [{"field": "wolf_guard_terminator_loadout", "label": "Equipment", "choices": choices}]
	return []
static func controls_for_model(definition: String, models: int, model_index: int) -> Array[Dictionary]:
	if role(definition, models, model_index).is_empty(): return []
	var result := controls(definition)
	if definition == STANDARD:
		if model_index == 0: result[1].choices = [{"id": "", "label": "Storm Bolter"}]
		else: result[0].choices.pop_back()
	if definition == WOLVES:
		var options: Dictionary = P.profile("wolf-guard-terminators").options
		var allowed: Array = options.pack_leader_loadouts if model_index == 0 else options.terminator_loadouts
		result[0].choices = result[0].choices.filter(func(c: Dictionary) -> bool: return c.id in allowed)
	return result
static func _valid_fields(equipment: Variant, descriptors: Array[Dictionary]) -> bool:
	if not equipment is Dictionary or equipment.size() != descriptors.size(): return false
	for descriptor: Dictionary in descriptors:
		if not equipment.has(descriptor.field): return false
		if not descriptor.choices.any(func(c: Dictionary) -> bool: return typeof(c.id) == typeof(equipment[descriptor.field]) and c.id == equipment[descriptor.field]): return false
	return true
static func valid(definition: String, equipment: Variant, models: int) -> bool:
	return supports(definition) and models in [5, 10] and _valid_fields(equipment, controls(definition))
static func valid_saved(definition: String, loadout: Variant, models: int) -> bool:
	if not supports(definition) or models not in [5, 10] or not loadout is Array or loadout.size() != models: return false
	var descriptors := controls(definition)
	var options: Dictionary = P.profile("wolf-guard-terminators").options if definition == WOLVES else {}
	var specials := 0
	for i in range(models):
		if not _valid_fields(loadout[i], descriptors): return false
		if definition == STANDARD:
			if i == 0 and not str(loadout[i].terminator_special_weapon).is_empty(): return false
			if i > 0 and loadout[i].terminator_melee_choice == "power-weapon": return false
			if not str(loadout[i].terminator_special_weapon).is_empty(): specials += 1
		if definition == WOLVES:
			var allowed: Array = options.pack_leader_loadouts if i == 0 else options.terminator_loadouts
			if loadout[i].wolf_guard_terminator_loadout not in allowed: return false
			if loadout[i].wolf_guard_terminator_loadout == "assault-cannon-power-fist": specials += 1
	return specials <= int(models / 5)
static func points(definition: String, loadout: Variant, models: int) -> int:
	if not valid_saved(definition, loadout, models): return 0
	var source := P.profile(definition.get_slice(":", 3))
	var total := 0
	for equipment: Dictionary in loadout:
		if definition == STANDARD and equipment.terminator_special_weapon == "cyclone-missile-launcher": total += int(source.wargear_costs["cyclone-missile-launcher"])
		if definition == ASSAULT and equipment.terminator_assault_storm_shield: total += int(source.wargear_costs["storm-shield"])
		if definition == WOLVES and equipment.wolf_guard_terminator_loadout == "storm-shield": total += int(source.wargear_costs["storm-shield"])
	return total
static func prepare(unit: Dictionary, definition: String, equipment: Dictionary, models: int, model_index: int) -> void:
	if not valid(definition, equipment, models) or role(definition, models, model_index).is_empty(): return
	for descriptor: Dictionary in controls_for_model(definition, models, model_index):
		if not descriptor.choices.any(func(c: Dictionary) -> bool: return c.id == equipment[descriptor.field]): return
	var identity := definition.get_slice(":", 3)
	var source := P.profile(identity)
	var ranged: Array = source.ranged.duplicate(true)
	var melee: Array = source.melee.duplicate(true)
	var shield := false
	if definition == STANDARD:
		if equipment.terminator_melee_choice != "power-fist": melee = [P.additional_weapon(identity, "melee", str(equipment.terminator_melee_choice))]
		var special := str(equipment.terminator_special_weapon)
		if not special.is_empty():
			if special != "cyclone-missile-launcher": ranged.clear()
			ranged.append(P.additional_weapon(identity, "ranged", special))
	elif definition == ASSAULT:
		shield = bool(equipment.terminator_assault_storm_shield)
		if shield: melee = [P.additional_weapon(identity, "melee", "thunder-hammer")]
	else:
		var weapons := P.wolf_guard_terminator_weapons(str(equipment.wolf_guard_terminator_loadout))
		ranged = weapons.ranged
		melee = weapons.melee
		shield = equipment.wolf_guard_terminator_loadout == "storm-shield"
	if ranged.has({}) or melee.has({}): return
	unit.ranged_weapons = ranged
	unit.melee_weapons = melee
	unit.sergeant = model_index == 0
	unit.model_role = role(definition, models, model_index)
	unit.max_wounds = int(source.stats.wounds) + (1 if shield else 0)
	unit.wounds = unit.max_wounds
	unit.defense = {"toughness": source.stats.toughness, "save_target": source.stats.save_target, "invulnerable_target": source.stats.invulnerable_target}
	for field: String in equipment: unit[field] = equipment[field]
	if definition == WOLVES: unit.wolf_guard_terminator_storm_shield = shield
	unit.terminator_saved_loadout_locked = true
