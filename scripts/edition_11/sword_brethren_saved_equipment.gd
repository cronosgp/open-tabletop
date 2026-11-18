## Persistent per-model Sword Brethren replacement packages.
const P = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const DEFINITION := "40kdc:11e:adeptus-astartes:sword-brethren-squad"
const LOADOUT_LABELS := {
	"default": "Default: Heavy Bolt Pistol + Chainsword",
	"hand-flamer-chainsword": "Hand Flamer + Chainsword",
	"hand-flamer-power-weapon": "Hand Flamer + Master-crafted Power Weapon",
	"hand-flamer-thunder-hammer": "Hand Flamer + Thunder Hammer",
	"plasma-pistol-chainsword": "Plasma Pistol + Chainsword",
	"plasma-pistol-power-weapon": "Plasma Pistol + Master-crafted Power Weapon",
	"plasma-pistol-thunder-hammer": "Plasma Pistol + Thunder Hammer",
	"heavy-pistol-power-weapon": "Heavy Bolt Pistol + Master-crafted Power Weapon",
	"heavy-pistol-thunder-hammer": "Heavy Bolt Pistol + Thunder Hammer",
	"twin-lightning-claws": "Twin Lightning Claws"
}

static func supports(definition: String) -> bool:
	return definition == DEFINITION

static func valid_size(models: int) -> bool:
	return models in [4, 5, 9, 10]

static func defaults(definition: String) -> Dictionary:
	return {"sword_brethren_loadout": "default"} if supports(definition) else {}

static func role(definition: String, models: int, model_index: int) -> String:
	if not supports(definition) or not valid_size(models) or model_index < 0 or model_index >= models: return ""
	return "sword-brethren"

static func model_label(definition: String, models: int, model_index: int) -> String:
	return "Sword Brethren %d" % (model_index + 1) if not role(definition, models, model_index).is_empty() else ""

static func loadout_choices(model_index: int, models: int) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for loadout_id: String in P.sword_brethren_loadout_options(model_index, models):
		result.append({"id": loadout_id, "label": str(LOADOUT_LABELS.get(loadout_id, loadout_id))})
	return result

static func controls(definition: String) -> Array[Dictionary]:
	return controls_for_model(definition, 4, 0)

static func controls_for_model(definition: String, models: int, model_index: int) -> Array[Dictionary]:
	if role(definition, models, model_index).is_empty(): return []
	return [{"field": "sword_brethren_loadout", "label": "Complete weapon loadout", "choices": loadout_choices(model_index, models)}]

static func valid(definition: String, equipment: Variant, models: int) -> bool:
	if not supports(definition) or not valid_size(models) or not equipment is Dictionary or equipment.size() != 1: return false
	if not equipment.has("sword_brethren_loadout") or not equipment.sword_brethren_loadout is String: return false
	return str(equipment.sword_brethren_loadout) in P.sword_brethren_loadout_options(0, models)

static func valid_saved(definition: String, loadout: Variant, models: int) -> bool:
	if not supports(definition) or not valid_size(models) or not loadout is Array or loadout.size() != models: return false
	var loadout_ids: Array[String] = []
	for equipment: Variant in loadout:
		if not valid(definition, equipment, models): return false
		loadout_ids.append(str(equipment.sword_brethren_loadout))
	return P.sword_brethren_loadout_limits_valid(loadout_ids, models)

static func points(_definition: String, _loadout: Variant, _models: int) -> int:
	return 0

static func prepare(unit: Dictionary, definition: String, equipment: Dictionary, models: int, model_index: int) -> void:
	if not valid(definition, equipment, models) or role(definition, models, model_index).is_empty(): return
	var loadout_id := str(equipment.sword_brethren_loadout)
	var weapons := P.sword_brethren_model_loadout(model_index, models, loadout_id)
	if weapons.is_empty(): return
	unit.sword_brethren_loadout = loadout_id
	unit.sword_brethren_model = model_index
	unit.model_role = "Sword Brethren"
	unit.ranged_weapons = weapons.ranged.duplicate(true)
	unit.melee_weapons = weapons.melee.duplicate(true)
	unit.sword_brethren_saved_model_loadout_locked = true
