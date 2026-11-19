extends RefCounted
## Persistent, source-bounded model equipment for the Necrons App v1.2 profiles.
const Profiles = preload("res://scripts/edition_11/current_reference_necron_profiles.gd")

const LOKHUST_HEAVY := "40kdc:11e:necrons:lokhust-heavy-destroyers"
const TRIARCH_PRAETORIANS := "40kdc:11e:necrons:triarch-praetorians"
const TRIARCH_STALKER := "40kdc:11e:necrons:triarch-stalker"
const OVERLORD := "40kdc:11e:necrons:overlord"
const LYCHGUARD := "40kdc:11e:necrons:lychguard"
const LOKHUST_LORD := "40kdc:11e:necrons:lokhust-lord"
const CATACOMB_COMMAND_BARGE := "40kdc:11e:necrons:catacomb-command-barge"
const CANOPTEK_WRAITHS := "40kdc:11e:necrons:canoptek-wraiths"
const TOMB_BLADES := "40kdc:11e:necrons:tomb-blades"

const LOKHUST_FIELD := "lokhust_heavy_weapon"
const PRAETORIANS_FIELD := "triarch_praetorian_weapon_package"
const STALKER_FIELD := "triarch_stalker_weapon"
const OVERLORD_FIELD := "overlord_loadout"
const LYCHGUARD_FIELD := "lychguard_loadout"
const LOKHUST_LORD_WEAPON_FIELD := "lokhust_lord_weapon"
const LOKHUST_LORD_WARGEAR_FIELD := "lokhust_lord_wargear"
const CCB_CANNON_FIELD := "ccb_cannon"
const CCB_MELEE_FIELD := "ccb_melee"
const CCB_WARGEAR_FIELD := "ccb_wargear"
const WRAITH_RANGED_FIELD := "wraith_ranged"
const WRAITH_MELEE_FIELD := "wraith_melee"
const TOMB_BLADE_RANGED_FIELD := "tomb_blade_ranged"
const TOMB_BLADE_SHIELDVANES_FIELD := "tomb_blade_shieldvanes"
const TOMB_BLADE_OPTIC_FIELD := "tomb_blade_optic"

static func supports(definition: String) -> bool:
	return definition in [LOKHUST_HEAVY, TRIARCH_PRAETORIANS, TRIARCH_STALKER, OVERLORD, LYCHGUARD, LOKHUST_LORD, CATACOMB_COMMAND_BARGE, CANOPTEK_WRAITHS, TOMB_BLADES]

static func is_model_scoped(definition: String) -> bool:
	return definition in [LOKHUST_HEAVY, TRIARCH_PRAETORIANS, CANOPTEK_WRAITHS, TOMB_BLADES]

static func _identity(definition: String) -> String:
	if definition == LOKHUST_HEAVY: return "lokhust-heavy-destroyers"
	if definition == TRIARCH_PRAETORIANS: return "triarch-praetorians"
	if definition == TRIARCH_STALKER: return "triarch-stalker"
	if definition == OVERLORD: return "overlord"
	if definition == LYCHGUARD: return "lychguard"
	if definition == LOKHUST_LORD: return "lokhust-lord"
	if definition == CATACOMB_COMMAND_BARGE: return "catacomb-command-barge"
	if definition == CANOPTEK_WRAITHS: return "canoptek-wraiths"
	if definition == TOMB_BLADES: return "tomb-blades"
	return ""

static func _size_supported(definition: String, models: int) -> bool:
	if definition == LOKHUST_HEAVY: return models in [1, 2, 3]
	if definition == TRIARCH_PRAETORIANS: return models in [5, 10]
	if definition == TRIARCH_STALKER: return models == 1
	if definition == OVERLORD: return models == 1
	if definition == LYCHGUARD: return models in [5, 10]
	if definition == LOKHUST_LORD: return models == 1
	if definition == CATACOMB_COMMAND_BARGE: return models == 1
	if definition == CANOPTEK_WRAITHS: return models in [3, 6]
	if definition == TOMB_BLADES: return models in [3, 6]
	return false

static func defaults(definition: String) -> Dictionary:
	if definition == LOKHUST_HEAVY: return {LOKHUST_FIELD: "gauss-destructor"}
	if definition == TRIARCH_PRAETORIANS: return {PRAETORIANS_FIELD: "rod-of-covenant"}
	if definition == TRIARCH_STALKER: return {STALKER_FIELD: "heat-ray"}
	if definition == OVERLORD: return {OVERLORD_FIELD: "tachyon-arrow-and-overlords-blade"}
	if definition == LYCHGUARD: return {LYCHGUARD_FIELD: "warscythe"}
	if definition == LOKHUST_LORD: return {LOKHUST_LORD_WEAPON_FIELD: "staff-of-light", LOKHUST_LORD_WARGEAR_FIELD: "none"}
	if definition == CATACOMB_COMMAND_BARGE: return {CCB_CANNON_FIELD: "gauss-cannon", CCB_MELEE_FIELD: "staff-of-light", CCB_WARGEAR_FIELD: "none"}
	if definition == CANOPTEK_WRAITHS: return {WRAITH_RANGED_FIELD: "none", WRAITH_MELEE_FIELD: "vicious-claws"}
	if definition == TOMB_BLADES: return {TOMB_BLADE_RANGED_FIELD: "twin-gauss-blaster", TOMB_BLADE_SHIELDVANES_FIELD: "none", TOMB_BLADE_OPTIC_FIELD: "none"}
	return {}

static func _choices(definition: String) -> Array[Dictionary]:
	if definition == LOKHUST_HEAVY:
		return [
			{"id": "gauss-destructor", "label": "Gauss Destructor"},
			{"id": "enmitic-exterminator", "label": "Enmitic Exterminator"}
		]
	if definition == TRIARCH_PRAETORIANS:
		return [
			{"id": "rod-of-covenant", "label": "Rod of Covenant"},
			{"id": "particle-caster-voidblade", "label": "Particle Caster + Voidblade"}
		]
	if definition == TRIARCH_STALKER:
		return [
			{"id": "heat-ray", "label": "Heat Ray"},
			{"id": "particle-shredder", "label": "Particle Shredder"},
			{"id": "heavy-gauss-cannon-array", "label": "Heavy Gauss Cannon Array"}
		]
	if definition == OVERLORD:
		return [
			{"id": "tachyon-arrow-and-overlords-blade", "label": "Tachyon Arrow + Overlord's Blade"},
			{"id": "staff-of-light", "label": "Staff of Light"},
			{"id": "staff-of-light-and-resurrection-orb", "label": "Staff of Light + Resurrection Orb"},
			{"id": "voidscythe", "label": "Voidscythe"},
			{"id": "voidscythe-and-resurrection-orb", "label": "Voidscythe + Resurrection Orb"}
		]
	if definition == LYCHGUARD:
		return [
			{"id": "warscythe", "label": "Warscythe"},
			{"id": "hyperphase-sword-and-dispersion-shield", "label": "Hyperphase Sword + Dispersion Shield"}
		]
	return []

static func controls(definition: String) -> Array[Dictionary]:
	if not supports(definition): return []
	if definition == LOKHUST_LORD:
		return [
			{
				"field": LOKHUST_LORD_WEAPON_FIELD,
				"label": "Weapon",
				"choices": [
					{"id": "staff-of-light", "label": "Staff of Light"},
					{"id": "lords-blade", "label": "Lord's Blade"}
				]
			},
			{
				"field": LOKHUST_LORD_WARGEAR_FIELD,
				"label": "Optional wargear",
				"choices": [
					{"id": "none", "label": "No optional wargear"},
					{"id": "nanoscarab-amulet", "label": "Nanoscarab Amulet"},
					{"id": "resurrection-orb", "label": "Resurrection Orb"}
				]
			}
		]
	if definition == CATACOMB_COMMAND_BARGE:
		return [
			{
				"field": CCB_CANNON_FIELD,
				"label": "Cannon",
				"choices": [
					{"id": "gauss-cannon", "label": "Gauss cannon"},
					{"id": "tesla-cannon", "label": "Tesla cannon"}
				]
			},
			{
				"field": CCB_MELEE_FIELD,
				"label": "Melee weapon",
				"choices": [
					{"id": "staff-of-light", "label": "Staff of light"},
					{"id": "overlords-blade", "label": "Overlord's blade"}
				]
			},
			{
				"field": CCB_WARGEAR_FIELD,
				"label": "Optional wargear",
				"choices": [
					{"id": "none", "label": "No optional wargear"},
					{"id": "resurrection-orb", "label": "Resurrection Orb"}
				]
			}
		]
	if definition == CANOPTEK_WRAITHS:
		return [
			{
				"field": WRAITH_RANGED_FIELD,
				"label": "Ranged weapon",
				"choices": [
					{"id": "none", "label": "No ranged weapon"},
					{"id": "particle-caster", "label": "Particle caster"},
					{"id": "transdimensional-beamer", "label": "Transdimensional beamer"}
				]
			},
			{
				"field": WRAITH_MELEE_FIELD,
				"label": "Melee weapon",
				"choices": [
					{"id": "vicious-claws", "label": "Vicious claws"},
					{"id": "whip-coils", "label": "Whip coils"}
				]
			}
		]
	if definition == TOMB_BLADES:
		return [
			{
				"field": TOMB_BLADE_RANGED_FIELD,
				"label": "Ranged weapon",
				"choices": [
					{"id": "twin-gauss-blaster", "label": "Twin gauss blaster"},
					{"id": "particle-beamer", "label": "Particle beamer"},
					{"id": "twin-tesla-carbine", "label": "Twin tesla carbine"}
				]
			},
			{
				"field": TOMB_BLADE_SHIELDVANES_FIELD,
				"label": "Shieldvanes",
				"choices": [
					{"id": "none", "label": "No shieldvanes"},
					{"id": "shieldvanes", "label": "Shieldvanes"}
				]
			},
			{
				"field": TOMB_BLADE_OPTIC_FIELD,
				"label": "Optic / cloak wargear",
				"choices": [
					{"id": "none", "label": "None"},
					{"id": "nebuloscope", "label": "Nebuloscope"},
					{"id": "shadowloom", "label": "Shadowloom"}
				]
			}
		]
	var field := LOKHUST_FIELD
	var label := "Ranged weapon"
	if definition == TRIARCH_PRAETORIANS:
		field = PRAETORIANS_FIELD
		label = "Weapon package"
	elif definition == TRIARCH_STALKER:
		field = STALKER_FIELD
	elif definition == OVERLORD:
		field = OVERLORD_FIELD
		label = "Equipment package"
	elif definition == LYCHGUARD:
		field = LYCHGUARD_FIELD
		label = "Unit weapon package"
	return [{"field": field, "label": label, "choices": _choices(definition)}]

static func role(definition: String, models: int, model_index: int) -> String:
	if not supports(definition) or not _size_supported(definition, models) or model_index < 0 or model_index >= models: return ""
	return "model"

static func model_label(definition: String, models: int, model_index: int) -> String:
	if role(definition, models, model_index).is_empty(): return ""
	if definition == LOKHUST_HEAVY: return "Lokhust Heavy Destroyer %d" % (model_index + 1)
	if definition == TRIARCH_PRAETORIANS: return "Praetorian %d" % (model_index + 1)
	if definition == OVERLORD: return "Overlord"
	if definition == LYCHGUARD: return "Lychguard %d" % (model_index + 1)
	if definition == LOKHUST_LORD: return "Lokhust Lord"
	if definition == CATACOMB_COMMAND_BARGE: return "Catacomb Command Barge"
	if definition == CANOPTEK_WRAITHS: return "Canoptek Wraith %d" % (model_index + 1)
	return "Triarch Stalker"

static func controls_for_model(definition: String, models: int, model_index: int) -> Array[Dictionary]:
	if role(definition, models, model_index).is_empty(): return []
	return controls(definition)

static func valid(definition: String, equipment: Variant, models: int) -> bool:
	if not supports(definition) or not _size_supported(definition, models) or not equipment is Dictionary: return false
	var descriptors := controls(definition)
	if equipment.size() != descriptors.size(): return false
	for descriptor: Dictionary in descriptors:
		var field := str(descriptor.field)
		if not equipment.has(field) or not equipment[field] is String: return false
		var choice_valid := false
		for choice: Dictionary in descriptor.choices:
			if str(choice.id) == str(equipment[field]):
				choice_valid = true
				break
		if not choice_valid: return false
	return true

static func valid_for_model(definition: String, equipment: Variant, models: int, model_index: int) -> bool:
	return not role(definition, models, model_index).is_empty() and valid(definition, equipment, models)

static func valid_saved(definition: String, loadout: Variant, models: int) -> bool:
	if not supports(definition) or not _size_supported(definition, models): return false
	if is_model_scoped(definition):
		if not loadout is Array or loadout.size() != models: return false
		for model_index in range(models):
			if not valid_for_model(definition, loadout[model_index], models, model_index): return false
		return true
	return valid(definition, loadout, models)

static func points(definition: String, loadout: Variant, models: int) -> int:
	return 0 if valid_saved(definition, loadout, models) else 0

static func _weapon(source: Dictionary, weapon_group: String, weapon_id: String) -> Dictionary:
	for weapon: Variant in source.get(weapon_group, []):
		if weapon is Dictionary and str(weapon.get("id", "")) == weapon_id: return weapon.duplicate(true)
	var additional: Variant = source.get("additional_weapon_profiles", {}).get(weapon_group, [])
	if additional is Array:
		for weapon: Variant in additional:
			if weapon is Dictionary and str(weapon.get("id", "")) == weapon_id: return weapon.duplicate(true)
	return {}

static func prepare(unit: Dictionary, definition: String, equipment: Dictionary, models: int, model_index: int) -> void:
	if not valid_for_model(definition, equipment, models, model_index): return
	var source := Profiles.profile(_identity(definition))
	if source.is_empty(): return
	var choice := str(equipment[controls(definition)[0].field])
	if definition == OVERLORD:
		match choice:
			"tachyon-arrow-and-overlords-blade":
				unit.ranged_weapons = [_weapon(source, "ranged", "tachyon-arrow")]
				unit.melee_weapons = [_weapon(source, "melee", "overlords-blade")]
				unit.wargear = []
				unit.overlord_resurrection_orb = false
			"staff-of-light", "staff-of-light-and-resurrection-orb":
				unit.ranged_weapons = [_weapon(source, "ranged", "staff-of-light-overlord")]
				unit.melee_weapons = [_weapon(source, "melee", "staff-of-light-overlord")]
				unit.overlord_resurrection_orb = choice == "staff-of-light-and-resurrection-orb"
				unit.wargear = ["resurrection-orb"] if unit.overlord_resurrection_orb else []
			"voidscythe", "voidscythe-and-resurrection-orb":
				unit.ranged_weapons = []
				unit.melee_weapons = [_weapon(source, "melee", "voidscythe")]
				unit.overlord_resurrection_orb = choice == "voidscythe-and-resurrection-orb"
				unit.wargear = ["resurrection-orb"] if unit.overlord_resurrection_orb else []
		unit.saved_model_equipment = equipment.duplicate(true)
		unit.necron_saved_equipment_locked = true
		unit.overlord_loadout_locked = true
		return
	if definition == LYCHGUARD:
		if choice == "warscythe":
			unit.ranged_weapons = []
			unit.melee_weapons = [_weapon(source, "melee", "warscythe")]
			unit.lychguard_dispersion_shield = false
		else:
			unit.ranged_weapons = []
			unit.melee_weapons = [_weapon(source, "melee", "hyperphase-sword")]
			unit.lychguard_dispersion_shield = true
		unit.saved_model_equipment = equipment.duplicate(true)
		unit.necron_saved_equipment_locked = true
		unit.lychguard_loadout_locked = true
		return
	if definition == LOKHUST_LORD:
		var weapon_choice := str(equipment.get(LOKHUST_LORD_WEAPON_FIELD, "staff-of-light"))
		var wargear_choice := str(equipment.get(LOKHUST_LORD_WARGEAR_FIELD, "none"))
		if weapon_choice == "staff-of-light":
			unit.ranged_weapons = [_weapon(source, "ranged", "staff-of-light-lokhust-lord")]
			unit.melee_weapons = [_weapon(source, "melee", "staff-of-light-lokhust-lord")]
		elif weapon_choice == "lords-blade":
			unit.ranged_weapons = []
			unit.melee_weapons = [_weapon(source, "melee", "lords-blade")]
		unit.lokhust_lord_wargear = wargear_choice
		unit.wargear = [] if wargear_choice == "none" else [wargear_choice]
		unit.saved_model_equipment = equipment.duplicate(true)
		unit.necron_saved_equipment_locked = true
		unit.lokhust_lord_loadout_locked = true
		return
	if definition == CATACOMB_COMMAND_BARGE:
		var cannon_choice := str(equipment.get(CCB_CANNON_FIELD, "gauss-cannon"))
		var melee_choice := str(equipment.get(CCB_MELEE_FIELD, "staff-of-light"))
		var wargear_choice := str(equipment.get(CCB_WARGEAR_FIELD, "none"))
		var cannon_id := "tesla-cannon-command-barge" if cannon_choice == "tesla-cannon" else "gauss-cannon-command-barge"
		unit.ranged_weapons = [_weapon(source, "ranged", cannon_id), _weapon(source, "ranged", "staff-of-light-command-barge")]
		var melee_id := "overlords-blade-command-barge" if melee_choice == "overlords-blade" else "staff-of-light-command-barge"
		unit.melee_weapons = [_weapon(source, "melee", melee_id)]
		unit.ccb_wargear = wargear_choice
		unit.wargear = [] if wargear_choice == "none" else [wargear_choice]
		unit.saved_model_equipment = equipment.duplicate(true)
		unit.necron_saved_equipment_locked = true
		unit.ccb_loadout_locked = true
		return
	if definition == CANOPTEK_WRAITHS:
		var ranged_choice := str(equipment.get(WRAITH_RANGED_FIELD, "none"))
		var melee_choice := str(equipment.get(WRAITH_MELEE_FIELD, "vicious-claws"))
		if ranged_choice == "none":
			unit.ranged_weapons = []
		else:
			var rw := _weapon(source, "ranged", ranged_choice)
			unit.ranged_weapons = [rw] if not rw.is_empty() else []
		var mw := _weapon(source, "melee", melee_choice)
		if not mw.is_empty(): unit.melee_weapons = [mw]
		unit.saved_model_equipment = equipment.duplicate(true)
		unit.necron_saved_equipment_locked = true
		unit.wraiths_loadout_locked = true
		return
	if definition == TOMB_BLADES:
		var ranged_choice := str(equipment.get(TOMB_BLADE_RANGED_FIELD, "twin-gauss-blaster"))
		var shieldvanes_choice := str(equipment.get(TOMB_BLADE_SHIELDVANES_FIELD, "none"))
		var optic_choice := str(equipment.get(TOMB_BLADE_OPTIC_FIELD, "none"))
		var weapon_id := str({"twin-gauss-blaster": "source-ranged-2", "particle-beamer": "source-ranged-1", "twin-tesla-carbine": "source-ranged-3"}.get(ranged_choice, "source-ranged-2"))
		var rw := _weapon(source, "ranged", weapon_id)
		if not rw.is_empty():
			if optic_choice == "nebuloscope":
				rw.profiles.standard.keywords["ignores-cover"] = true
			unit.ranged_weapons = [rw]
		var wargear: Array[String] = []
		var defense: Dictionary = unit.get("defense", {}).duplicate(true)
		if shieldvanes_choice == "shieldvanes":
			wargear.append("shieldvanes")
			unit.movement = 8
			defense.save_target = 3
		else:
			unit.movement = 12
			defense.save_target = 4
		unit.defense = defense
		if optic_choice in ["nebuloscope", "shadowloom"]:
			wargear.append(optic_choice)
		unit.wargear = wargear
		unit.saved_model_equipment = equipment.duplicate(true)
		unit.necron_saved_equipment_locked = true
		unit.tomb_blades_loadout_locked = true
		return
	var ranged_id := choice
	if definition == TRIARCH_PRAETORIANS and choice == "particle-caster-voidblade": ranged_id = "particle-caster"
	var ranged := _weapon(source, "ranged", ranged_id)
	if ranged.is_empty(): return
	unit.ranged_weapons = [ranged]
	if definition == TRIARCH_PRAETORIANS:
		var melee_id := "voidblade" if choice == "particle-caster-voidblade" else "rod-of-covenant"
		var melee := _weapon(source, "melee", melee_id)
		if melee.is_empty(): return
		unit.melee_weapons = [melee]
	unit.saved_model_equipment = equipment.duplicate(true)
	unit.necron_saved_equipment_locked = true
	if definition == LOKHUST_HEAVY: unit.lokhust_heavy_loadout_locked = true
	elif definition == TRIARCH_PRAETORIANS: unit.triarch_praetorian_loadout_locked = true
	else: unit.triarch_stalker_loadout_locked = true
