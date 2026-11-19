extends RefCounted
## Persistent, source-bounded model equipment for the fixed ten-model Talonstrike Kill Team.
const P = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const DEFINITION := "40kdc:11e:adeptus-astartes:talonstrike-kill-team"
const SERGEANT_MELEE := "talonstrike_sergeant_melee"
const SERGEANT_RANGED := "talonstrike_sergeant_ranged"
const INTERCESSOR_PLASMA := "talonstrike_intercessor_plasma_pistol"
const HEAVY_PLASMA := "talonstrike_plasma_exterminator"
const MELEE_CHOICES := ["chainsword", "power-fist", "power-weapon"]
const RANGED_CHOICES := ["heavy-bolt-pistol", "hand-flamer", "plasma-pistol"]

static func supports(definition: String) -> bool:
	return definition == DEFINITION

static func valid_size(models: int) -> bool:
	return models == 10

static func role(definition: String, models: int, model_index: int) -> String:
	if not supports(definition) or not valid_size(models) or model_index < 0 or model_index >= models: return ""
	var loadouts: Array = P.profile("talonstrike-kill-team").get("model_loadouts", [])
	return str(loadouts[model_index].get("role", "")) if model_index < loadouts.size() else ""

static func defaults(definition: String) -> Dictionary:
	return defaults_for_model(definition, 10, 0) if supports(definition) else {}

static func defaults_for_model(definition: String, models: int, model_index: int) -> Dictionary:
	match role(definition, models, model_index):
		"sergeant": return {SERGEANT_MELEE: "chainsword", SERGEANT_RANGED: "heavy-bolt-pistol"}
		"heavy-intercessor": return {HEAVY_PLASMA: false}
		"intercessor": return {INTERCESSOR_PLASMA: false}
	return {}

static func model_label(definition: String, models: int, model_index: int) -> String:
	var model_role := role(definition, models, model_index)
	if model_role.is_empty(): return ""
	if model_role == "sergeant": return "Talonstrike Sergeant"
	var ordinal := 0
	for index in range(model_index + 1):
		if role(definition, models, index) == model_role: ordinal += 1
	return "%s %d" % ["Heavy Intercessor" if model_role == "heavy-intercessor" else "Intercessor", ordinal]

static func _all_controls() -> Array[Dictionary]:
	return [
		{"field": SERGEANT_MELEE, "label": "Chainsword replacement", "choices": [
			{"id": "chainsword", "label": "Chainsword"},
			{"id": "power-fist", "label": "Power Fist"},
			{"id": "power-weapon", "label": "Power Weapon"}
		]},
		{"field": SERGEANT_RANGED, "label": "Heavy Bolt Pistol replacement", "choices": [
			{"id": "heavy-bolt-pistol", "label": "Heavy Bolt Pistol"},
			{"id": "hand-flamer", "label": "Hand Flamer"},
			{"id": "plasma-pistol", "label": "Plasma Pistol"}
		]},
		{"field": INTERCESSOR_PLASMA, "label": "Heavy Bolt Pistol replacement (1 per 5 models)", "choices": [
			{"id": false, "label": "Heavy Bolt Pistol"},
			{"id": true, "label": "Plasma Pistol"}
		]},
		{"field": HEAVY_PLASMA, "label": "Assault Bolters replacement", "choices": [
			{"id": false, "label": "Assault Bolters"},
			{"id": true, "label": "Plasma Exterminators"}
		]}
	]

static func controls(definition: String) -> Array[Dictionary]:
	return _all_controls() if supports(definition) else []

static func controls_for_model(definition: String, models: int, model_index: int) -> Array[Dictionary]:
	match role(definition, models, model_index):
		"sergeant": return [_all_controls()[0], _all_controls()[1]]
		"intercessor": return [_all_controls()[2]]
		"heavy-intercessor": return [_all_controls()[3]]
	return []

static func valid(definition: String, equipment: Variant, models: int) -> bool:
	if not supports(definition) or not valid_size(models) or not equipment is Dictionary: return false
	if equipment.is_empty(): return true
	if equipment.has(SERGEANT_MELEE) or equipment.has(SERGEANT_RANGED):
		return equipment.size() == 2 \
			and equipment.has(SERGEANT_MELEE) and equipment[SERGEANT_MELEE] is String and str(equipment[SERGEANT_MELEE]) in MELEE_CHOICES \
			and equipment.has(SERGEANT_RANGED) and equipment[SERGEANT_RANGED] is String and str(equipment[SERGEANT_RANGED]) in RANGED_CHOICES
	if equipment.has(INTERCESSOR_PLASMA): return equipment.size() == 1 and equipment[INTERCESSOR_PLASMA] is bool
	if equipment.has(HEAVY_PLASMA): return equipment.size() == 1 and equipment[HEAVY_PLASMA] is bool
	return false

static func valid_for_model(definition: String, equipment: Variant, models: int, model_index: int) -> bool:
	var model_role := role(definition, models, model_index)
	if model_role.is_empty() or not valid(definition, equipment, models): return false
	var expected := defaults_for_model(definition, models, model_index)
	if equipment.size() != expected.size(): return false
	for field: Variant in expected:
		if not equipment.has(field): return false
	match model_role:
		"sergeant":
			return str(equipment[SERGEANT_MELEE]) in MELEE_CHOICES and str(equipment[SERGEANT_RANGED]) in RANGED_CHOICES
		"intercessor": return equipment[INTERCESSOR_PLASMA] is bool
		"heavy-intercessor": return equipment[HEAVY_PLASMA] is bool
	return equipment.is_empty()

static func valid_saved(definition: String, loadout: Variant, models: int) -> bool:
	if not supports(definition) or not valid_size(models) or not loadout is Array or loadout.size() != models: return false
	var plasma_pistols := 0
	for model_index in range(models):
		var equipment: Variant = loadout[model_index]
		if not valid_for_model(definition, equipment, models, model_index): return false
		if bool(equipment.get(INTERCESSOR_PLASMA, false)): plasma_pistols += 1
	var source := P.profile("talonstrike-kill-team")
	var limit := int(source.options.intercessor_plasma_pistols_per_five_models) * int(models / 5)
	return plasma_pistols <= limit

static func points(_definition: String, _loadout: Variant, _models: int) -> int:
	return 0

static func prepare(unit: Dictionary, definition: String, equipment: Dictionary, models: int, model_index: int) -> void:
	if not valid_for_model(definition, equipment, models, model_index): return
	var model := P.talonstrike_kill_team_model_loadout(
		model_index,
		str(equipment.get(SERGEANT_MELEE, "chainsword")),
		str(equipment.get(SERGEANT_RANGED, "heavy-bolt-pistol")),
		bool(equipment.get(INTERCESSOR_PLASMA, false)),
		bool(equipment.get(HEAVY_PLASMA, false))
	)
	if model.is_empty(): return
	unit.talonstrike_kill_team_model = model_index
	unit.talonstrike_kill_team_role = str(model.role)
	unit.model_role = str(model.role)
	unit[SERGEANT_MELEE] = str(equipment.get(SERGEANT_MELEE, "chainsword"))
	unit[SERGEANT_RANGED] = str(equipment.get(SERGEANT_RANGED, "heavy-bolt-pistol"))
	unit[INTERCESSOR_PLASMA] = bool(equipment.get(INTERCESSOR_PLASMA, false))
	unit[HEAVY_PLASMA] = bool(equipment.get(HEAVY_PLASMA, false))
	unit.saved_equipment_model_index = model_index
	unit.saved_model_equipment = equipment.duplicate(true)
	unit.ranged_weapons = model.ranged.duplicate(true)
	unit.melee_weapons = model.melee.duplicate(true)
	unit.keywords = model.keywords.duplicate()
	unit.talonstrike_saved_equipment_locked = true
