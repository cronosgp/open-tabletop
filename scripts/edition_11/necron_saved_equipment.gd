extends RefCounted
## Persistent, source-bounded model equipment for the Necrons App v1.2 profiles.
const Profiles = preload("res://scripts/edition_11/current_reference_necron_profiles.gd")

const LOKHUST_HEAVY := "40kdc:11e:necrons:lokhust-heavy-destroyers"
const TRIARCH_PRAETORIANS := "40kdc:11e:necrons:triarch-praetorians"
const TRIARCH_STALKER := "40kdc:11e:necrons:triarch-stalker"

const LOKHUST_FIELD := "lokhust_heavy_weapon"
const PRAETORIANS_FIELD := "triarch_praetorian_weapon_package"
const STALKER_FIELD := "triarch_stalker_weapon"

static func supports(definition: String) -> bool:
	return definition in [LOKHUST_HEAVY, TRIARCH_PRAETORIANS, TRIARCH_STALKER]

static func is_model_scoped(definition: String) -> bool:
	return definition in [LOKHUST_HEAVY, TRIARCH_PRAETORIANS]

static func _identity(definition: String) -> String:
	if definition == LOKHUST_HEAVY: return "lokhust-heavy-destroyers"
	if definition == TRIARCH_PRAETORIANS: return "triarch-praetorians"
	if definition == TRIARCH_STALKER: return "triarch-stalker"
	return ""

static func _size_supported(definition: String, models: int) -> bool:
	if definition == LOKHUST_HEAVY: return models in [1, 2, 3]
	if definition == TRIARCH_PRAETORIANS: return models in [5, 10]
	return definition == TRIARCH_STALKER and models == 1

static func defaults(definition: String) -> Dictionary:
	if definition == LOKHUST_HEAVY: return {LOKHUST_FIELD: "gauss-destructor"}
	if definition == TRIARCH_PRAETORIANS: return {PRAETORIANS_FIELD: "rod-of-covenant"}
	if definition == TRIARCH_STALKER: return {STALKER_FIELD: "heat-ray"}
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
	return []

static func controls(definition: String) -> Array[Dictionary]:
	if not supports(definition): return []
	var field := LOKHUST_FIELD if definition == LOKHUST_HEAVY else PRAETORIANS_FIELD if definition == TRIARCH_PRAETORIANS else STALKER_FIELD
	var label := "Ranged weapon" if definition != TRIARCH_PRAETORIANS else "Weapon package"
	return [{"field": field, "label": label, "choices": _choices(definition)}]

static func role(definition: String, models: int, model_index: int) -> String:
	if not supports(definition) or not _size_supported(definition, models) or model_index < 0 or model_index >= models: return ""
	return "model"

static func model_label(definition: String, models: int, model_index: int) -> String:
	if role(definition, models, model_index).is_empty(): return ""
	if definition == LOKHUST_HEAVY: return "Lokhust Heavy Destroyer %d" % (model_index + 1)
	if definition == TRIARCH_PRAETORIANS: return "Praetorian %d" % (model_index + 1)
	return "Triarch Stalker"

static func controls_for_model(definition: String, models: int, model_index: int) -> Array[Dictionary]:
	if role(definition, models, model_index).is_empty(): return []
	return controls(definition)

static func valid(definition: String, equipment: Variant, models: int) -> bool:
	if not supports(definition) or not _size_supported(definition, models) or not equipment is Dictionary or equipment.size() != 1: return false
	var descriptor := controls(definition)[0]
	var field := str(descriptor.field)
	if not equipment.has(field) or not equipment[field] is String: return false
	for choice: Dictionary in descriptor.choices:
		if str(choice.id) == str(equipment[field]): return true
	return false

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
