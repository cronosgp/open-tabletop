## Persistent source-listed Crusader Squad model weapon replacements.
const P = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const DEFINITION := "40kdc:11e:adeptus-astartes:crusader-squad"
const LOADOUT := "crusader_squad_loadout"

static func supports(definition: String) -> bool:
	return definition == DEFINITION

static func valid_size(models: int) -> bool:
	return models in [10, 20]

static func role(definition: String, models: int, model_index: int) -> String:
	if not supports(definition) or not valid_size(models): return ""
	var model := P.crusader_squad_model_loadout(model_index, models)
	return str(model.get("role", ""))

static func defaults(definition: String) -> Dictionary:
	return {LOADOUT: "default"} if supports(definition) else {}

static func defaults_for_model(definition: String, models: int, model_index: int) -> Dictionary:
	if role(definition, models, model_index).is_empty(): return {}
	return defaults(definition)

static func model_label(definition: String, models: int, model_index: int) -> String:
	var model_role := role(definition, models, model_index)
	if model_role == "Sword Brother": return model_role
	var first_model := 1 if model_role == "Neophyte" else (5 if models == 10 else 9) if model_role == "Initiate" else -1
	if first_model < 0: return ""
	return "%s %d" % [model_role, model_index - first_model + 1]

static func controls(definition: String) -> Array[Dictionary]:
	return controls_for_model(definition, 10, 0)

static func controls_for_model(definition: String, models: int, model_index: int) -> Array[Dictionary]:
	match role(definition, models, model_index):
		"Sword Brother":
			return [{"field": LOADOUT, "label": "Heavy Bolt Pistol replacement", "choices": [
				{"id": "default", "label": "Heavy Bolt Pistol + Master-crafted Power Weapon"},
				{"id": "hand-flamer", "label": "Hand Flamer + Master-crafted Power Weapon"}
			]}]
		"Neophyte":
			return [{"field": LOADOUT, "label": "Neophyte weapon package", "choices": [
				{"id": "default", "label": "Bolt Pistol + Neophyte Chainsword"},
				{"id": "shotgun", "label": "Shotgun + Combat Knife"}
			]}]
		"Initiate":
			return [{"field": LOADOUT, "label": "Initiate weapon package", "choices": [
				{"id": "default", "label": "Bolt Pistol + Bolt Rifle"},
				{"id": "pistol-chainsword", "label": "Heavy Bolt Pistol + Initiate Chainsword"},
				{"id": "heavy-pistol-power-fist", "label": "Heavy Bolt Pistol + Power Fist"},
				{"id": "pyreblaster", "label": "Pyreblaster"}
			]}]
	return []

static func valid(definition: String, equipment: Variant, models: int) -> bool:
	if not supports(definition) or not valid_size(models) or not equipment is Dictionary or equipment.size() != 1: return false
	return equipment.has(LOADOUT) and equipment[LOADOUT] is String

static func valid_for_model(definition: String, equipment: Variant, models: int, model_index: int) -> bool:
	if not valid(definition, equipment, models) or role(definition, models, model_index).is_empty(): return false
	for loadout_id: String in P.crusader_squad_loadout_options(model_index, models):
		if equipment[LOADOUT] == loadout_id: return true
	return false

static func valid_saved(definition: String, loadout: Variant, models: int) -> bool:
	if not supports(definition) or not valid_size(models) or not loadout is Array or loadout.size() != models: return false
	var limited_initiate_weapons := 0
	for model_index in range(models):
		var equipment: Variant = loadout[model_index]
		if not valid_for_model(definition, equipment, models, model_index): return false
		if str(equipment[LOADOUT]) in ["heavy-pistol-power-fist", "pyreblaster"]: limited_initiate_weapons += 1
	return limited_initiate_weapons <= int(models / 10) * 2

static func points(_definition: String, _loadout: Variant, _models: int) -> int:
	return 0

static func prepare(unit: Dictionary, definition: String, equipment: Dictionary, models: int, model_index: int) -> void:
	if not valid_for_model(definition, equipment, models, model_index): return
	var loadout_id := str(equipment[LOADOUT])
	var model := P.crusader_squad_model_loadout(model_index, models, loadout_id)
	if model.is_empty(): return
	unit.crusader_squad_model = model_index
	unit.crusader_squad_role = str(model.role)
	unit[LOADOUT] = loadout_id
	unit.saved_equipment_model_index = model_index
	unit.saved_model_equipment = equipment.duplicate(true)
	unit.ranged_weapons = model.ranged.duplicate(true)
	unit.melee_weapons = model.melee.duplicate(true)
	unit.defense = {"toughness": model.stats.toughness, "save_target": model.stats.save_target, "invulnerable_target": model.stats.invulnerable_target}
	unit.crusader_squad_saved_equipment_locked = true
