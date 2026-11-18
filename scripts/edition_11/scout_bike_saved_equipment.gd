## Persistent Sergeant sidearm replacements and per-model Grenade Launchers.
const P = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const DEFINITION := "40kdc:11e:adeptus-astartes:scout-bike-squad"
const SERGEANT_OPTIONS: Array[String] = ["bolt-pistol", "boltgun", "combi-weapon", "chainsword", "grav-pistol", "hand-flamer", "inferno-pistol", "plasma-pistol", "power-fist", "power-weapon", "storm-bolter", "thunder-hammer"]

static func supports(definition: String) -> bool:
	return definition == DEFINITION

static func valid_size(models: int) -> bool:
	return models in [3, 6]

static func defaults(definition: String) -> Dictionary:
	return {"scout_bike_grenade_launcher": false, "scout_bike_sergeant_option": "bolt-pistol"} if supports(definition) else {}

static func role(definition: String, models: int, model_index: int) -> String:
	if not supports(definition) or not valid_size(models) or model_index < 0 or model_index >= models: return ""
	return "sergeant" if model_index == 0 else "biker"

static func model_label(definition: String, models: int, model_index: int) -> String:
	var model_role := role(definition, models, model_index)
	if model_role == "sergeant": return "Scout Biker Sergeant"
	if model_role == "biker": return "Scout Biker %d" % (model_index + 1)
	return ""

static func controls(definition: String) -> Array[Dictionary]:
	return controls_for_model(definition, 3, 0)

static func controls_for_model(definition: String, models: int, model_index: int) -> Array[Dictionary]:
	if role(definition, models, model_index).is_empty(): return []
	var result: Array[Dictionary] = [
		{"field": "scout_bike_grenade_launcher", "label": "Twin Boltgun replacement", "choices": [
			{"id": false, "label": "Twin Boltgun"},
			{"id": true, "label": "Grenade Launcher (Frag / Krak)"}
		]}
	]
	if model_index == 0:
		var choices: Array[Dictionary] = []
		for option: String in SERGEANT_OPTIONS:
			choices.append({"id": option, "label": P.scout_bike_sergeant_option_label(option)})
		result.append({"field": "scout_bike_sergeant_option", "label": "Bolt Pistol replacement", "choices": choices})
	return result

static func valid(definition: String, equipment: Variant, models: int) -> bool:
	if not supports(definition) or not valid_size(models) or not equipment is Dictionary or equipment.size() != 2: return false
	if not equipment.has("scout_bike_grenade_launcher") or not equipment.scout_bike_grenade_launcher is bool: return false
	return equipment.has("scout_bike_sergeant_option") and str(equipment.scout_bike_sergeant_option) in SERGEANT_OPTIONS

static func valid_saved(definition: String, loadout: Variant, models: int) -> bool:
	if not supports(definition) or not valid_size(models) or not loadout is Array or loadout.size() != models: return false
	for model_index in range(models):
		var equipment: Variant = loadout[model_index]
		if not valid(definition, equipment, models): return false
		if model_index > 0 and str(equipment.scout_bike_sergeant_option) != "bolt-pistol": return false
	return true

static func points(_definition: String, _loadout: Variant, _models: int) -> int:
	return 0

static func prepare(unit: Dictionary, definition: String, equipment: Dictionary, models: int, model_index: int) -> void:
	if not valid(definition, equipment, models) or role(definition, models, model_index).is_empty(): return
	var sergeant_option := str(equipment.scout_bike_sergeant_option) if model_index == 0 else "bolt-pistol"
	if model_index > 0 and str(equipment.scout_bike_sergeant_option) != "bolt-pistol": return
	var grenade_launcher := bool(equipment.scout_bike_grenade_launcher)
	var weapons := P.scout_bike_squad_weapons(grenade_launcher, sergeant_option)
	if weapons.is_empty(): return
	unit.scout_bike_grenade_launcher = grenade_launcher
	unit.scout_bike_sergeant_option = sergeant_option
	unit.ranged_weapons = weapons.ranged.duplicate(true)
	unit.melee_weapons = weapons.melee.duplicate(true)
	unit.model_role = "Scout Biker Sergeant" if model_index == 0 else "Scout Biker"
	unit.scout_bike_saved_model_loadout_locked = true
