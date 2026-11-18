extends RefCounted
## Source-bounded saved packages for the existing leader-led squad profiles.
const P = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const JUMP := "40kdc:11e:adeptus-astartes:assault-intercessors-with-jump-packs"
const BLOOD := "40kdc:11e:adeptus-astartes:blood-claws"
const GREY := "40kdc:11e:adeptus-astartes:grey-hunters"
static func supports(definition: String) -> bool:
	return definition in [JUMP, BLOOD, GREY]
static func prefix(definition: String) -> String:
	return "jump_intercessor" if definition == JUMP else "blood_claws_pack_leader" if definition == BLOOD else "grey_hunters_pack_leader" if definition == GREY else ""
static func sizes(definition: String) -> Array:
	return [5, 10] if definition == JUMP else [10, 20] if definition == BLOOD else [10] if definition == GREY else []
static func defaults(definition: String) -> Dictionary:
	if not supports(definition): return {}
	return {prefix(definition) + "_pistol": "heavy-bolt-pistol" if definition == JUMP else "bolt-pistol", prefix(definition) + "_melee": "chainsword"}
static func role(definition: String, models: int, model_index: int) -> String:
	if models not in sizes(definition) or model_index < 0 or model_index >= models: return ""
	return "sergeant" if definition == JUMP and model_index == 0 else "pack-leader" if model_index == 0 else "trooper"
static func controls(definition: String) -> Array[Dictionary]:
	if not supports(definition): return []
	var ranged: Array = ["heavy-bolt-pistol", "hand-flamer", "plasma-pistol"] if definition == JUMP else P.profile(definition.get_slice(":", 3)).options.pack_leader_ranged_packages
	var melee: Array = ["chainsword", "power-fist", "power-weapon"] if definition == JUMP else P.profile(definition.get_slice(":", 3)).options.pack_leader_melee_packages
	var names := {"heavy-bolt-pistol": "Heavy Bolt Pistol", "hand-flamer": "Hand Flamer", "plasma-pistol": "Plasma Pistol", "bolt-pistol": "Bolt Pistol", "chainsword": "Chainsword", "power-fist": "Power Fist", "power-weapon": "Power Weapon"}
	var descriptors: Array[Dictionary] = []
	for group in range(2):
		var choices: Array[Dictionary] = []
		for package: String in (ranged if group == 0 else melee): choices.append({"id": package, "label": names[package]})
		descriptors.append({"field": prefix(definition) + ("_pistol" if group == 0 else "_melee"), "label": ("Pistol (+ Bolt Carbine)" if definition == GREY else "Pistol") if group == 0 else "Melee", "choices": choices})
	return descriptors
static func controls_for_model(definition: String, models: int, model_index: int) -> Array[Dictionary]:
	var model_role := role(definition, models, model_index)
	if model_role.is_empty(): return []
	var result := controls(definition)
	if model_index > 0:
		result[1].choices = [{"id": "chainsword", "label": "Chainsword"}]
		if definition == JUMP:
			result[0].label = "Pistol (1 Plasma / 5)"
			result[0].choices = result[0].choices.filter(func(c: Dictionary) -> bool: return c.id != "hand-flamer")
		else: result[0].choices = [{"id": "bolt-pistol", "label": "Bolt Pistol"}]
	return result
static func valid(definition: String, equipment: Variant, models: int) -> bool:
	if models not in sizes(definition) or not equipment is Dictionary or equipment.size() != 2: return false
	for descriptor: Dictionary in controls(definition):
		if not equipment.has(descriptor.field) or not equipment[descriptor.field] is String: return false
		if not descriptor.choices.any(func(c: Dictionary) -> bool: return c.id == equipment[descriptor.field]): return false
	return true
static func valid_saved(definition: String, loadout: Variant, models: int) -> bool:
	if models not in sizes(definition) or not loadout is Array or loadout.size() != models: return false
	var trooper_plasma := 0
	for index in range(models):
		if not valid(definition, loadout[index], models): return false
		if index == 0: continue
		if str(loadout[index][prefix(definition) + "_melee"]) != "chainsword": return false
		var pistol := str(loadout[index][prefix(definition) + "_pistol"])
		if definition != JUMP:
			if pistol != "bolt-pistol": return false
		else:
			if pistol not in ["heavy-bolt-pistol", "plasma-pistol"]: return false
			if pistol == "plasma-pistol": trooper_plasma += 1
	return trooper_plasma <= int(models / 5) if definition == JUMP else true
static func prepare(unit: Dictionary, definition: String, equipment: Dictionary, models: int, model_index: int) -> void:
	if not valid(definition, equipment, models) or role(definition, models, model_index).is_empty(): return
	var pistol := str(equipment[prefix(definition) + "_pistol"])
	var melee := str(equipment[prefix(definition) + "_melee"])
	if model_index > 0 and (melee != "chainsword" or (pistol not in ["heavy-bolt-pistol", "plasma-pistol"] if definition == JUMP else pistol != "bolt-pistol")): return
	var weapons := {"ranged": [P.jump_pack_pistol(pistol)], "melee": [P.jump_pack_sergeant_melee(melee)]} if definition == JUMP else P.blood_claws_pack_leader_weapons(pistol, melee) if definition == BLOOD else P.grey_hunters_pack_leader_weapons(pistol, melee)
	if weapons.is_empty(): return
	unit.ranged_weapons = weapons.ranged.duplicate(true)
	unit.melee_weapons = weapons.melee.duplicate(true)
	unit.sergeant = model_index == 0
	unit.model_role = role(definition, models, model_index)
	if definition == JUMP: unit.jump_plasma_pistol = model_index > 0 and pistol == "plasma-pistol"
	for field: String in equipment: unit[field] = equipment[field]
	unit.sergeant_squad_loadout_locked = true
