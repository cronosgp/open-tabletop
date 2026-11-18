## Persistent, source-bounded Grenade Launcher replacements for Ravenwing squads.
const P = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const BLACK_KNIGHTS := "40kdc:11e:adeptus-astartes:ravenwing-black-knights"
const COMMAND_SQUAD := "40kdc:11e:adeptus-astartes:ravenwing-command-squad"
const COMMAND_ROLES := ["Ravenwing Ancient", "Ravenwing Apothecary", "Ravenwing Champion"]

static func supports(definition: String) -> bool:
	return definition in [BLACK_KNIGHTS, COMMAND_SQUAD]

static func sizes(definition: String) -> Array:
	if definition == BLACK_KNIGHTS: return [3, 6]
	if definition == COMMAND_SQUAD: return [3]
	return []

static func defaults(definition: String) -> Dictionary:
	if definition == BLACK_KNIGHTS: return {"black_knight_grenade_launcher": false}
	if definition == COMMAND_SQUAD: return {"ravenwing_command_grenade_launcher": false}
	return {}

static func role(definition: String, models: int, model_index: int) -> String:
	if not supports(definition) or models not in sizes(definition) or model_index < 0 or model_index >= models: return ""
	if definition == BLACK_KNIGHTS: return "huntmaster" if model_index == 0 else "black-knight"
	return ["ancient", "apothecary", "champion"][model_index]

static func model_label(definition: String, models: int, model_index: int) -> String:
	var model_role := role(definition, models, model_index)
	if model_role.is_empty(): return ""
	if definition == BLACK_KNIGHTS: return "Ravenwing Huntmaster" if model_index == 0 else "Ravenwing Black Knight %d" % (model_index + 1)
	return COMMAND_ROLES[model_index]

static func controls(definition: String) -> Array[Dictionary]:
	if definition == BLACK_KNIGHTS:
		return [{"field": "black_knight_grenade_launcher", "label": "Plasma Talon replacement", "choices": _launcher_choices()}]
	if definition == COMMAND_SQUAD:
		return [{"field": "ravenwing_command_grenade_launcher", "label": "Plasma Talon replacement", "choices": _launcher_choices()}]
	return []

static func controls_for_model(definition: String, models: int, model_index: int) -> Array[Dictionary]:
	return controls(definition) if not role(definition, models, model_index).is_empty() else []

static func valid(definition: String, equipment: Variant, models: int) -> bool:
	if not supports(definition) or models not in sizes(definition) or not equipment is Dictionary: return false
	var descriptors := controls(definition)
	if equipment.size() != 1 or not equipment.has(descriptors[0].field): return false
	return equipment[descriptors[0].field] is bool

static func valid_saved(definition: String, loadout: Variant, models: int) -> bool:
	if not supports(definition) or models not in sizes(definition) or not loadout is Array or loadout.size() != models: return false
	var count := 0
	var field := str(controls(definition)[0].field)
	for equipment: Variant in loadout:
		if not valid(definition, equipment, models): return false
		if bool(equipment[field]): count += 1
	return count <= int(models / 3)

static func points(_definition: String, _loadout: Variant, _models: int) -> int:
	return 0

static func prepare(unit: Dictionary, definition: String, equipment: Dictionary, models: int, model_index: int) -> void:
	if not valid(definition, equipment, models): return
	var model_role := role(definition, models, model_index)
	if model_role.is_empty(): return
	var grenade_launcher_field := str(controls(definition)[0].field)
	var grenade_launcher := bool(equipment[grenade_launcher_field])
	var weapons: Dictionary = {}
	var command_role := ""
	if definition == BLACK_KNIGHTS:
		weapons = P.ravenwing_black_knight_weapons(grenade_launcher)
	else:
		command_role = COMMAND_ROLES[model_index]
		weapons = P.ravenwing_command_weapons(command_role, grenade_launcher)
	if weapons.is_empty(): return
	if definition == BLACK_KNIGHTS:
		unit.black_knight_grenade_launcher = grenade_launcher
	else:
		unit.ravenwing_command_role = command_role
		unit.ravenwing_command_grenade_launcher = grenade_launcher
	unit.ranged_weapons = weapons.ranged.duplicate(true)
	unit.melee_weapons = weapons.melee.duplicate(true)
	unit.model_role = model_role
	unit.ravenwing_saved_model_loadout_locked = true

static func _launcher_choices() -> Array[Dictionary]:
	return [
		{"id": false, "label": "Plasma Talon"},
		{"id": true, "label": "Grenade Launcher (Frag / Krak)"}
	]
