## Persistent source-listed Indomitor Kill Team weapon replacements.
const P = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const DEFINITION := "40kdc:11e:adeptus-astartes:indomitor-kill-team"
const AUTO_BOLTSTORM := "indomitor_auto_boltstorm"
const HEAVY_BOLTER := "indomitor_heavy_bolter"
const MULTI_MELTA := "indomitor_multi_melta"

static func supports(definition: String) -> bool:
	return definition == DEFINITION

static func valid_size(models: int) -> bool:
	return models == 10

static func role(definition: String, models: int, model_index: int) -> String:
	if not supports(definition) or not valid_size(models) or model_index < 0 or model_index >= models: return ""
	if model_index in [0, 1, 2]: return "flamestorm-heavy-intercessor"
	if model_index in [3, 4, 5]: return "melta-heavy-intercessor"
	return "heavy-rifle-intercessor"

static func defaults(definition: String) -> Dictionary:
	return {AUTO_BOLTSTORM: false} if supports(definition) else {}

static func defaults_for_model(definition: String, models: int, model_index: int) -> Dictionary:
	match role(definition, models, model_index):
		"flamestorm-heavy-intercessor": return {AUTO_BOLTSTORM: false}
		"melta-heavy-intercessor": return {MULTI_MELTA: false}
		"heavy-rifle-intercessor": return {HEAVY_BOLTER: false}
	return {}

static func model_label(definition: String, models: int, model_index: int) -> String:
	match role(definition, models, model_index):
		"flamestorm-heavy-intercessor": return "Aggressor %d" % (model_index + 1)
		"melta-heavy-intercessor": return "Eradicator %d" % (model_index - 2)
		"heavy-rifle-intercessor": return "Heavy Intercessor %d" % (model_index - 5)
	return ""

static func controls(definition: String) -> Array[Dictionary]:
	return controls_for_model(definition, 10, 0)

static func controls_for_model(definition: String, models: int, model_index: int) -> Array[Dictionary]:
	match role(definition, models, model_index):
		"flamestorm-heavy-intercessor":
			return [{"field": AUTO_BOLTSTORM, "label": "Flamestorm Gauntlet replacement", "choices": [
				{"id": false, "label": "Flamestorm Gauntlets"},
				{"id": true, "label": "Auto Boltstorm Gauntlets + Fragstorm Grenade Launcher"}
			]}]
		"melta-heavy-intercessor":
			return [{"field": MULTI_MELTA, "label": "Melta Rifle replacement", "choices": [
				{"id": false, "label": "Melta Rifle"},
				{"id": true, "label": "Multi-melta"}
			]}]
		"heavy-rifle-intercessor":
			return [{"field": HEAVY_BOLTER, "label": "Deathwatch Heavy Bolt Rifle replacement", "choices": [
				{"id": false, "label": "Deathwatch Heavy Bolt Rifle"},
				{"id": true, "label": "Deathwatch Heavy Bolter"}
			]}]
	return []

static func valid(definition: String, equipment: Variant, models: int) -> bool:
	if not supports(definition) or not valid_size(models) or not equipment is Dictionary or equipment.size() != 1: return false
	for field: String in [AUTO_BOLTSTORM, HEAVY_BOLTER, MULTI_MELTA]:
		if equipment.has(field): return equipment[field] is bool
	return false

static func valid_for_model(definition: String, equipment: Variant, models: int, model_index: int) -> bool:
	var expected := defaults_for_model(definition, models, model_index)
	if expected.is_empty() or not valid(definition, equipment, models) or equipment.size() != expected.size(): return false
	var field := str(expected.keys()[0])
	return equipment.has(field) and equipment[field] is bool

static func valid_saved(definition: String, loadout: Variant, models: int) -> bool:
	if not supports(definition) or not valid_size(models) or not loadout is Array or loadout.size() != models: return false
	var heavy_bolters := 0
	var multi_meltas := 0
	for model_index in range(models):
		var equipment: Variant = loadout[model_index]
		if not valid_for_model(definition, equipment, models, model_index): return false
		if bool(equipment.get(HEAVY_BOLTER, false)): heavy_bolters += 1
		if bool(equipment.get(MULTI_MELTA, false)): multi_meltas += 1
	return heavy_bolters <= 2 and multi_meltas <= 1

static func points(_definition: String, _loadout: Variant, _models: int) -> int:
	return 0

static func prepare(unit: Dictionary, definition: String, equipment: Dictionary, models: int, model_index: int) -> void:
	if not valid_for_model(definition, equipment, models, model_index): return
	var auto_boltstorm := bool(equipment.get(AUTO_BOLTSTORM, false))
	var heavy_bolter := bool(equipment.get(HEAVY_BOLTER, false))
	var multi_melta := bool(equipment.get(MULTI_MELTA, false))
	var weapons := P.indomitor_kill_team_model_loadout(model_index, auto_boltstorm, heavy_bolter, multi_melta)
	if weapons.is_empty(): return
	unit[AUTO_BOLTSTORM] = auto_boltstorm
	unit[HEAVY_BOLTER] = heavy_bolter
	unit[MULTI_MELTA] = multi_melta
	unit.indomitor_kill_team_model = model_index
	unit.saved_equipment_model_index = model_index
	unit.saved_model_equipment = equipment.duplicate(true)
	unit.model_role = str(weapons.role)
	unit.ranged_weapons = weapons.ranged.duplicate(true)
	unit.melee_weapons = weapons.melee.duplicate(true)
	unit.keywords = weapons.keywords.duplicate()
	unit.indomitor_saved_equipment_locked = true
