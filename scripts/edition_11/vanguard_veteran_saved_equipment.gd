## Persistent, source-bounded equipment for the two Vanguard Veteran profiles.
const P = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const VETERANS := "40kdc:11e:adeptus-astartes:vanguard-veteran-squad"
const JUMP_PACKS := "40kdc:11e:adeptus-astartes:vanguard-veteran-squad-with-jump-packs"

static func supports(definition: String) -> bool:
	return definition in [VETERANS, JUMP_PACKS]

static func sizes(definition: String) -> Array:
	return [5, 10] if supports(definition) else []

static func defaults(definition: String) -> Dictionary:
	if definition == VETERANS: return {"vanguard_veteran_squad_loadout": "bolt-pistol"}
	if definition == JUMP_PACKS: return {"vanguard_pistol": "heavy-bolt-pistol", "vanguard_melee": "default"}
	return {}

static func role(definition: String, models: int, model_index: int) -> String:
	if not supports(definition) or models not in sizes(definition) or model_index < 0 or model_index >= models: return ""
	return "sergeant" if model_index == 0 else "vanguard-veteran"

static func model_label(definition: String, models: int, model_index: int) -> String:
	if role(definition, models, model_index).is_empty(): return ""
	return "Vanguard Sergeant" if model_index == 0 else "Vanguard Veteran %d" % (model_index + 1)

static func controls(definition: String) -> Array[Dictionary]:
	if definition == VETERANS:
		var profile := P.profile("vanguard-veteran-squad")
		var labels := {
			"bolt-pistol": "Bolt Pistol",
			"storm-shield": "Storm Shield (+4 invulnerable save)",
			"grav-pistol": "Grav-pistol",
			"hand-flamer": "Hand Flamer",
			"inferno-pistol": "Inferno Pistol",
			"plasma-pistol": "Plasma Pistol"
		}
		var choices: Array[Dictionary] = []
		for package: String in profile.get("options", {}).get("pistol_replacements", []):
			choices.append({"id": package, "label": str(labels.get(package, package))})
		return [{"field": "vanguard_veteran_squad_loadout", "label": "Pistol / shield", "choices": choices}]
	if definition == JUMP_PACKS:
		return [
			{"field": "vanguard_pistol", "label": "Pistol / shield", "choices": _pistol_choices()},
			{"field": "vanguard_melee", "label": "Sergeant melee", "choices": _sergeant_melee_choices()}
		]
	return []

static func controls_for_model(definition: String, models: int, model_index: int) -> Array[Dictionary]:
	if role(definition, models, model_index).is_empty(): return []
	var result := controls(definition)
	if definition == JUMP_PACKS:
		if model_index > 0:
			result[1].label = "Fixed melee"
			result[1].choices = [{"id": "default", "label": "Master-crafted Power Weapon"}]
		else:
			result[1].choices[0].label = "Relic Blade"
	return result

static func valid(definition: String, equipment: Variant, models: int) -> bool:
	if not supports(definition) or models not in sizes(definition) or not equipment is Dictionary: return false
	if definition == VETERANS:
		return _valid_fields(equipment, controls(definition)) and not P.vanguard_veteran_squad_weapons(str(equipment.vanguard_veteran_squad_loadout)).is_empty()
	if equipment.size() != 2 or not equipment.has("vanguard_pistol") or not equipment.has("vanguard_melee"): return false
	if not equipment.vanguard_pistol is String or not equipment.vanguard_melee is String: return false
	if str(equipment.vanguard_pistol) not in ["heavy-bolt-pistol", "plasma-pistol", "combat-shield"]: return false
	var melee := str(equipment.vanguard_melee)
	if melee not in ["default", "relic-blade", "power-fist", "thunder-hammer"]: return false
	return not P.vanguard_veteran_weapons(true, str(equipment.vanguard_pistol), melee, str(equipment.vanguard_pistol) == "combat-shield").is_empty() \
		or not P.vanguard_veteran_weapons(false, str(equipment.vanguard_pistol), melee, str(equipment.vanguard_pistol) == "combat-shield").is_empty()

static func valid_saved(definition: String, loadout: Variant, models: int) -> bool:
	if not supports(definition) or models not in sizes(definition) or not loadout is Array or loadout.size() != models: return false
	var ordinary_plasma := 0
	for index in range(models):
		var equipment: Variant = loadout[index]
		if not valid(definition, equipment, models): return false
		if definition == VETERANS: continue
		var pistol := str(equipment.vanguard_pistol)
		var melee := str(equipment.vanguard_melee)
		var weapons := P.vanguard_veteran_weapons(index == 0, pistol, melee, pistol == "combat-shield")
		if weapons.is_empty(): return false
		if index > 0 and pistol == "plasma-pistol": ordinary_plasma += 1
	if definition == JUMP_PACKS: return ordinary_plasma <= int(models / 5) * 2
	return true

static func points(definition: String, loadout: Variant, models: int) -> int:
	return 0

static func prepare(unit: Dictionary, definition: String, equipment: Dictionary, models: int, model_index: int) -> void:
	if not valid(definition, equipment, models) or role(definition, models, model_index).is_empty(): return
	if definition == VETERANS:
		var loadout := str(equipment.vanguard_veteran_squad_loadout)
		var weapons := P.vanguard_veteran_squad_weapons(loadout)
		if weapons.is_empty(): return
		unit.vanguard_veteran_squad_loadout = loadout
		unit.vanguard_veteran_squad_loadout_locked = true
		unit.ranged_weapons = weapons.ranged.duplicate(true)
		unit.melee_weapons = weapons.melee.duplicate(true)
		var defense: Dictionary = unit.get("defense", {}).duplicate(true)
		defense.invulnerable_target = int(weapons.get("invulnerable_target", 0))
		unit.defense = defense
	else:
		var pistol := str(equipment.vanguard_pistol)
		var melee := str(equipment.vanguard_melee)
		var shield := pistol == "combat-shield"
		var weapons := P.vanguard_veteran_weapons(model_index == 0, pistol, melee, shield)
		if weapons.is_empty(): return
		unit.vanguard_pistol = pistol
		unit.vanguard_melee = melee
		unit.combat_shield = shield
		unit.jump_plasma_pistol = model_index > 0 and pistol == "plasma-pistol"
		unit.sergeant_squad_loadout_locked = true
		unit.ranged_weapons = weapons.ranged.duplicate(true)
		unit.melee_weapons = weapons.melee.duplicate(true)
		var defense: Dictionary = unit.get("defense", {}).duplicate(true)
		defense.invulnerable_target = 5 if shield else 0
		unit.defense = defense
	unit.sergeant = model_index == 0
	unit.model_role = role(definition, models, model_index)
	unit.vanguard_veteran_saved_model_loadout_locked = true

static func _valid_fields(equipment: Dictionary, descriptors: Array[Dictionary]) -> bool:
	if equipment.size() != descriptors.size(): return false
	for descriptor: Dictionary in descriptors:
		var field := str(descriptor.field)
		if not equipment.has(field) or not equipment[field] is String: return false
		var matches := false
		for choice: Dictionary in descriptor.choices:
			if equipment[field] == choice.id: matches = true
		if not matches: return false
	return true

static func _pistol_choices() -> Array[Dictionary]:
	return [
		{"id": "heavy-bolt-pistol", "label": "Heavy Bolt Pistol"},
		{"id": "plasma-pistol", "label": "Plasma Pistol"},
		{"id": "combat-shield", "label": "Combat Shield (+5 invulnerable save)"}
	]

static func _sergeant_melee_choices() -> Array[Dictionary]:
	return [
		{"id": "default", "label": "Role default melee"},
		{"id": "power-fist", "label": "Power Fist"},
		{"id": "thunder-hammer", "label": "Thunder Hammer"}
	]
