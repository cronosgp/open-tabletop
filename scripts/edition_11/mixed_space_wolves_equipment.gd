extends RefCounted
## Equipment only for existing admitted mixed compositions; never prices new role mixes.
const P = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const SCOUTS := "40kdc:11e:adeptus-astartes:wolf-scouts"
const HEADTAKERS := "40kdc:11e:adeptus-astartes:wolf-guard-headtakers"

static func supports(definition: String) -> bool:
	return definition in [SCOUTS, HEADTAKERS]

static func defaults(definition: String) -> Dictionary:
	return {"wolf_scouts_loadout": "default", "wolf_scouts_haywire_mine": false} if definition == SCOUTS else {"wolf_guard_headtaker_storm_shield": false} if definition == HEADTAKERS else {}

static func headtaker_roles(models: int) -> Array:
	var found: Array = []
	for option: Dictionary in P.profile("wolf-guard-headtakers").get("composition_options", []):
		if int(option.get("models", 0)) != models: continue
		if not found.is_empty(): return [] # Ambiguous future compositions need their own schema.
		found = option.get("roles", []).duplicate()
	return found if found.size() == models and models in [6, 12] else []

static func role(definition: String, models: int, model_index: int) -> String:
	if models not in [6, 12] or model_index < 0 or model_index >= models: return ""
	if definition == HEADTAKERS:
		var roles := headtaker_roles(models)
		return str(roles[model_index]) if not roles.is_empty() else ""
	if definition == SCOUTS:
		return "pack-leader" if model_index == 0 else "hunting-wolf" if model_index <= (2 if models == 12 else 1) else "wolf-scout"
	return ""

static func controls(definition: String) -> Array[Dictionary]:
	if definition == HEADTAKERS:
		return [{"field": "wolf_guard_headtaker_storm_shield", "label": "Storm Shield", "choices": [{"id": false, "label": "Paired power weapons"}, {"id": true, "label": "Power weapon + Storm Shield"}]}]
	if definition != SCOUTS: return []
	var choices: Array[Dictionary] = []
	var names := {"default": "Plasma Pistol + Combat Knife", "bolt-pistol": "Bolt Pistol", "runic-stave": "Runic Stave", "thunderclap": "Thunderclap", "instigator-bolt-carbine": "Instigator Bolt Carbine", "plasma-gun": "Plasma Gun"}
	for id: String in P.profile("wolf-scouts").options.wolf_scout_loadouts: choices.append({"id": id, "label": names[id]})
	return [{"field": "wolf_scouts_loadout", "label": "Weapons", "choices": choices}, {"field": "wolf_scouts_haywire_mine", "label": "Haywire Mine", "choices": [{"id": false, "label": "Not equipped"}, {"id": true, "label": "Equipped (one per unit)"}]}]

static func controls_for_model(definition: String, models: int, model_index: int) -> Array[Dictionary]:
	var model_role := role(definition, models, model_index)
	if model_role.is_empty(): return []
	var result := controls(definition)
	if model_role == "hunting-wolf":
		result[0].label = "Fixed weapons"
		result[0].choices = [{"id": false if definition == HEADTAKERS else "default", "label": "Teeth and Claws"}]
		if definition == SCOUTS: result[1].choices = [{"id": false, "label": "Unavailable"}]
	elif model_role == "pack-leader":
		result[0].choices = [{"id": "default", "label": "Plasma Pistol + Power Weapon"}]
	elif definition == SCOUTS and models == 6:
		result[0].choices = (result[0].choices as Array).filter(func(c: Dictionary) -> bool: return str(c.id) != "instigator-bolt-carbine")
	return result

static func valid(definition: String, equipment: Variant, models: int) -> bool:
	if not supports(definition) or models not in [6, 12] or not equipment is Dictionary: return false
	var descriptors := controls(definition)
	if equipment.size() != descriptors.size(): return false
	for descriptor: Dictionary in descriptors:
		if not equipment.has(descriptor.field): return false
		var found := false
		for choice: Dictionary in descriptor.choices:
			if typeof(equipment[descriptor.field]) == typeof(choice.id) and equipment[descriptor.field] == choice.id: found = true
		if not found: return false
	return true

static func valid_saved(definition: String, loadout: Variant, models: int) -> bool:
	if not supports(definition) or models not in [6, 12] or not loadout is Array or loadout.size() != models: return false
	var mines := 0
	var special := 0
	var carbines := 0
	var plasma := 0
	for index in range(models):
		var equipment: Variant = loadout[index]
		if not valid(definition, equipment, models): return false
		var model_role := role(definition, models, index)
		if model_role.is_empty(): return false
		if definition == HEADTAKERS:
			if model_role == "hunting-wolf" and bool(equipment.wolf_guard_headtaker_storm_shield): return false
			continue
		var package := str(equipment.wolf_scouts_loadout)
		var mine := bool(equipment.wolf_scouts_haywire_mine)
		if model_role != "wolf-scout" and package != "default": return false
		if mine and (model_role == "hunting-wolf" or package != "default"): return false
		if mine: mines += 1
		if package in ["bolt-pistol", "runic-stave", "thunderclap"]: special += 1
		if package == "instigator-bolt-carbine": carbines += 1
		if package == "plasma-gun": plasma += 1
	if definition == HEADTAKERS: return true
	var options: Dictionary = P.profile("wolf-scouts").options
	return mines <= int(options.haywire_mines_per_unit) and special <= int(options.special_replacements_per_unit) and plasma <= int(options.plasma_gun_per_unit) and carbines <= int(models / 12) * int(options.instigator_carbine_per_12_models)

static func prepare(unit: Dictionary, definition: String, equipment: Dictionary, models: int, model_index: int) -> void:
	if not valid(definition, equipment, models): return
	var model_role := role(definition, models, model_index)
	if model_role.is_empty(): return
	var data: Dictionary
	if definition == SCOUTS:
		if model_role != "wolf-scout" and str(equipment.wolf_scouts_loadout) != "default": return
		if bool(equipment.wolf_scouts_haywire_mine) and (model_role == "hunting-wolf" or str(equipment.wolf_scouts_loadout) != "default"): return
		data = P.wolf_scouts_model_loadout(model_index, models, str(equipment.wolf_scouts_loadout))
		unit.wolf_scouts_model = model_index
		unit.wolf_scouts_role = str(data.get("role", ""))
		unit.wolf_scouts_loadout = str(equipment.wolf_scouts_loadout)
		unit.wolf_scouts_haywire_mine = bool(equipment.wolf_scouts_haywire_mine)
	else:
		if model_role == "hunting-wolf" and bool(equipment.wolf_guard_headtaker_storm_shield): return
		data = P.wolf_guard_headtaker_model_loadout(model_role, bool(equipment.wolf_guard_headtaker_storm_shield))
		unit.wolf_guard_headtaker_model = model_index
		unit.wolf_guard_headtaker_role = model_role
		unit.wolf_guard_headtaker_storm_shield = bool(equipment.wolf_guard_headtaker_storm_shield)
	if data.is_empty(): return
	unit.model_role = model_role
	unit.ranged_weapons = data.ranged.duplicate(true)
	unit.melee_weapons = data.melee.duplicate(true)
	unit.movement = int(data.stats.movement_inches)
	unit.max_wounds = int(data.stats.wounds)
	unit.wounds = unit.max_wounds
	unit.objective_control = int(data.stats.objective_control)
	unit.leadership_target = int(data.stats.leadership_target)
	unit.defense = {"toughness": data.stats.toughness, "save_target": data.stats.save_target, "invulnerable_target": data.stats.invulnerable_target}
	unit.radius = float(data.base_radius_inches)
	unit.mixed_space_wolves_loadout_locked = true
