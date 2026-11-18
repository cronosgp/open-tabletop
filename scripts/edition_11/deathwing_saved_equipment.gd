extends RefCounted
const P = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const BaseTerminators = preload("res://scripts/edition_11/terminator_saved_equipment.gd")
const TERMINATORS := "40kdc:11e:adeptus-astartes:deathwing-terminator-squad"
const KNIGHTS := "40kdc:11e:adeptus-astartes:deathwing-knights"
static func supports(definition: String) -> bool:
	return definition in [TERMINATORS, KNIGHTS]
static func sizes(definition: String) -> Array:
	return [5, 10] if definition == TERMINATORS else [5] if definition == KNIGHTS else []
static func defaults(definition: String) -> Dictionary:
	return BaseTerminators.defaults(BaseTerminators.STANDARD) if definition == TERMINATORS else {"deathwing_knight_melee": "default"} if definition == KNIGHTS else {}
static func role(definition: String, models: int, index: int) -> String:
	if models not in sizes(definition) or index < 0 or index >= models: return ""
	return ("knight-master" if definition == KNIGHTS else "sergeant") if index == 0 else "ordinary"
static func controls(definition: String) -> Array[Dictionary]:
	if definition == TERMINATORS:
		var result := BaseTerminators.controls(BaseTerminators.STANDARD)
		result[1].choices.append({"id": "plasma-cannon", "label": "Plasma Cannon"})
		return result
	if definition == KNIGHTS: return [{"field": "deathwing_knight_melee", "label": "Melee", "choices": [{"id": "default", "label": "Default role weapon"}, {"id": "relic-weapon", "label": "Relic Weapon"}, {"id": "power-weapon", "label": "Power Weapon"}]}]
	return []
static func controls_for_model(definition: String, models: int, index: int) -> Array[Dictionary]:
	if role(definition, models, index).is_empty(): return []
	var result := controls(definition)
	if definition == TERMINATORS:
		if index == 0: result[1].choices = [{"id": "", "label": "Storm Bolter"}]
		else: result[0].choices.pop_back()
	else:
		result[0].choices = [{"id": "default", "label": "Great Weapon of the Unforgiven" if index == 0 else "Mace of Absolution"}, {"id": "relic-weapon" if index == 0 else "power-weapon", "label": "Relic Weapon" if index == 0 else "Power Weapon"}]
	return result
static func valid(definition: String, equipment: Variant, models: int) -> bool:
	return models in sizes(definition) and BaseTerminators._valid_fields(equipment, controls(definition))
static func valid_saved(definition: String, loadout: Variant, models: int) -> bool:
	if models not in sizes(definition) or not loadout is Array or loadout.size() != models: return false
	var descriptors := controls(definition)
	var specials := 0
	for i in range(models):
		if not BaseTerminators._valid_fields(loadout[i], descriptors): return false
		if definition == TERMINATORS:
			if i == 0 and not str(loadout[i].terminator_special_weapon).is_empty(): return false
			if i > 0 and loadout[i].terminator_melee_choice == "power-weapon": return false
			if not str(loadout[i].terminator_special_weapon).is_empty(): specials += 1
		else:
			if loadout[i].deathwing_knight_melee not in (["default", "relic-weapon"] if i == 0 else ["default", "power-weapon"]): return false
	return specials <= int(models / 5)
static func points(definition: String, loadout: Variant, models: int) -> int:
	if definition != TERMINATORS or not valid_saved(definition, loadout, models): return 0
	var count := 0
	for equipment: Dictionary in loadout:
		if equipment.terminator_special_weapon == "cyclone-missile-launcher": count += 1
	return count * int(P.profile("deathwing-terminator-squad").wargear_costs["cyclone-missile-launcher"])
static func prepare(unit: Dictionary, definition: String, equipment: Dictionary, models: int, index: int) -> void:
	if not valid(definition, equipment, models) or role(definition, models, index).is_empty(): return
	for descriptor: Dictionary in controls_for_model(definition, models, index):
		if not descriptor.choices.any(func(c: Dictionary) -> bool: return c.id == equipment[descriptor.field]): return
	var identity := definition.get_slice(":", 3)
	var source := P.profile(identity)
	var ranged: Array = source.ranged.duplicate(true)
	var melee: Array = source.melee.duplicate(true)
	if definition == TERMINATORS:
		if equipment.terminator_melee_choice != "power-fist": melee = [P.additional_weapon(identity, "melee", equipment.terminator_melee_choice)]
		var special := str(equipment.terminator_special_weapon)
		if not special.is_empty():
			if special != "cyclone-missile-launcher": ranged.clear()
			ranged.append(P.additional_weapon(identity, "ranged", special))
		unit.terminator_melee_choice = equipment.terminator_melee_choice
		unit.terminator_special_weapon = special
	else:
		var weapon_id := str(equipment.deathwing_knight_melee)
		if weapon_id == "default": weapon_id = "great-weapon-of-the-unforgiven" if index == 0 else "mace-of-absolution"
		melee = [P.deathwing_knight_melee_weapon(weapon_id)]
		unit.deathwing_knight_melee = weapon_id
	if ranged.has({}) or melee.has({}): return
	unit.ranged_weapons = ranged
	unit.melee_weapons = melee
	unit.sergeant = index == 0
	unit.model_role = role(definition, models, index)
	unit.deathwing_saved_model_loadout_locked = true
static func unit_defaults(definition: String) -> Dictionary:
	return {"watcher_in_the_dark": false} if supports(definition) else {}
static func unit_controls(definition: String) -> Array[Dictionary]:
	return [{"field": "watcher_in_the_dark", "label": "Watcher in the Dark (whole unit; free)"}] if supports(definition) else []
static func unit_valid(definition: String, equipment: Variant) -> bool:
	return supports(definition) and equipment is Dictionary and equipment.size() == 1 and equipment.has("watcher_in_the_dark") and equipment.watcher_in_the_dark is bool
static func prepare_unit(squad: Dictionary, definition: String, equipment: Dictionary) -> void:
	if not unit_valid(definition, equipment): return
	var field := "deathwing_knights_watcher_equipped" if definition == KNIGHTS else "deathwing_terminator_watcher_equipped"
	squad[field] = bool(equipment.watcher_in_the_dark)
	squad.deathwing_saved_unit_loadout_locked = true
