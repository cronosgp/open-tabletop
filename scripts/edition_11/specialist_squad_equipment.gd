extends RefCounted
const P = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const ERADICATORS := "40kdc:11e:adeptus-astartes:eradicator-squad-with-melta-rifles"
const DESOLATION := "40kdc:11e:adeptus-astartes:desolation-squad"
const STERNGUARD := "40kdc:11e:adeptus-astartes:sternguard-veteran-squad"
static func supports(definition: String) -> bool:
	return definition in [ERADICATORS, DESOLATION, STERNGUARD]
static func sizes(definition: String) -> Array:
	return [3, 6] if definition == ERADICATORS else [5] if definition == DESOLATION else [5, 10] if definition == STERNGUARD else []
static func defaults(definition: String) -> Dictionary:
	return {"eradicator_multi_melta": false} if definition == ERADICATORS else {"desolation_rocket": "superfrag"} if definition == DESOLATION else {"sternguard_gun": "firearm", "sternguard_melee": "default"} if definition == STERNGUARD else {}
static func role(definition: String, models: int, model_index: int) -> String:
	if models not in sizes(definition) or model_index < 0 or model_index >= models: return ""
	return "sergeant" if model_index == 0 else "trooper"
static func controls(definition: String) -> Array[Dictionary]:
	if definition == ERADICATORS: return [{"field": "eradicator_multi_melta", "label": "Primary (1 Multi / 3)", "choices": [{"id": false, "label": "Melta Rifle"}, {"id": true, "label": "Multi-melta"}]}]
	if definition == DESOLATION: return [{"field": "desolation_rocket", "label": "Rocket launcher", "choices": [{"id": "superfrag", "label": "Superfrag"}, {"id": "superkrak", "label": "Superkrak"}, {"id": "vengor", "label": "Vengor (+5 pts)"}]}]
	if definition == STERNGUARD: return [{"field": "sternguard_gun", "label": "Primary (1 special / 5)", "choices": [{"id": "firearm", "label": "Artificer Firearm"}, {"id": "heavy", "label": "Heavy Bolter"}, {"id": "pyre", "label": "Pyrecannon"}]}, {"field": "sternguard_melee", "label": "Melee", "choices": [{"id": "default", "label": "Default role weapon"}, {"id": "fist", "label": "Power Fist"}, {"id": "power", "label": "Power Weapon"}]}]
	return []
static func controls_for_model(definition: String, models: int, model_index: int) -> Array[Dictionary]:
	if role(definition, models, model_index).is_empty(): return []
	var result := controls(definition)
	if definition == ERADICATORS and model_index == 0: result[0].choices = [{"id": false, "label": "Melta Rifle"}]
	if definition == DESOLATION and model_index > 0: result[0].choices.pop_back()
	if definition == STERNGUARD:
		if model_index == 0:
			result[0].choices = [{"id": "firearm", "label": "Artificer Firearm"}]
			result[1].choices[0].label = "Chainsword"
		else: result[1].choices = [{"id": "default", "label": "Ceramite Fists"}]
	return result
static func valid(definition: String, equipment: Variant, models: int) -> bool:
	if models not in sizes(definition) or not equipment is Dictionary: return false
	var descriptors := controls(definition)
	if equipment.size() != descriptors.size(): return false
	for descriptor: Dictionary in descriptors:
		if not equipment.has(descriptor.field): return false
		if not descriptor.choices.any(func(c: Dictionary) -> bool: return typeof(c.id) == typeof(equipment[descriptor.field]) and c.id == equipment[descriptor.field]): return false
	return true
static func valid_saved(definition: String, loadout: Variant, models: int) -> bool:
	if models not in sizes(definition) or not loadout is Array or loadout.size() != models: return false
	var special := 0
	for i in range(models):
		if not valid(definition, loadout[i], models): return false
		if definition == ERADICATORS:
			if loadout[i].eradicator_multi_melta:
				if i == 0: return false
				special += 1
		elif definition == DESOLATION:
			if i > 0 and loadout[i].desolation_rocket == "vengor": return false
		else:
			if i == 0 and loadout[i].sternguard_gun != "firearm": return false
			if i > 0 and loadout[i].sternguard_melee != "default": return false
			if loadout[i].sternguard_gun != "firearm": special += 1
	return special <= int(models / 3) if definition == ERADICATORS else special <= int(models / 5) if definition == STERNGUARD else true
static func points(definition: String, loadout: Variant, models: int) -> int:
	if definition != DESOLATION or not valid_saved(definition, loadout, models): return 0
	return int(P.profile("desolation-squad").wargear_costs["vengor-launcher"]) if loadout[0].desolation_rocket == "vengor" else 0
static func prepare(unit: Dictionary, definition: String, equipment: Dictionary, models: int, model_index: int) -> void:
	if not valid(definition, equipment, models) or role(definition, models, model_index).is_empty(): return
	if definition == ERADICATORS and model_index == 0 and equipment.eradicator_multi_melta: return
	if definition == DESOLATION and model_index > 0 and equipment.desolation_rocket == "vengor": return
	if definition == STERNGUARD and ((model_index == 0 and equipment.sternguard_gun != "firearm") or (model_index > 0 and equipment.sternguard_melee != "default")): return
	var source := P.profile(definition.get_slice(":", 3))
	unit.sergeant = model_index == 0
	unit.model_role = role(definition, models, model_index)
	unit.ranged_weapons = source.ranged.duplicate(true)
	unit.melee_weapons = source.melee.duplicate(true)
	if definition == ERADICATORS:
		unit.ranged_weapons[0] = P.eradicator_ranged(bool(equipment.eradicator_multi_melta))
		unit.multi_melta = bool(equipment.eradicator_multi_melta)
	elif definition == DESOLATION:
		unit.ranged_weapons = P.desolation_weapons(str(equipment.desolation_rocket))
	else:
		unit.ranged_weapons[0] = P.sternguard_gun(str(equipment.sternguard_gun))
		unit.sternguard_special = str(equipment.sternguard_gun) != "firearm"
		if model_index == 0: unit.melee_weapons = [P.sternguard_melee("chain" if equipment.sternguard_melee == "default" else str(equipment.sternguard_melee))]
	for field: String in equipment: unit[field] = equipment[field]
	unit.specialist_squad_loadout_locked = true
