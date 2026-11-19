extends RefCounted
## Persistent, source-bounded model equipment for the fixed ten-model Fortis Kill Team.
const P = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const DEFINITION := "40kdc:11e:adeptus-astartes:fortis-kill-team"
const ROCKET := "fortis_kill_team_rocket_launcher"
const SERGEANT_MELEE := "fortis_kill_team_sergeant_melee"
const SERGEANT_RANGED := "fortis_kill_team_sergeant_ranged"
const GRENADE_LAUNCHER := "fortis_kill_team_grenade_launcher"
const PLASMA_PISTOL := "fortis_kill_team_plasma_pistol"

const MELEE_CHOICES := ["knives-and-fists", "chainsword", "power-fist", "power-weapon", "thunder-hammer"]
const RANGED_CHOICES := ["deathwatch-bolt-rifle", "chainsword", "hand-flamer", "plasma-pistol", "power-weapon"]
const ROCKET_CHOICES := ["superfrag", "superkrak", "vengor"]

static func supports(definition: String) -> bool:
	return definition == DEFINITION

static func valid_size(models: int) -> bool:
	return models == 10

static func role(definition: String, models: int, model_index: int) -> String:
	if not supports(definition) or not valid_size(models) or model_index < 0 or model_index >= models: return ""
	var loadouts: Array = P.profile("fortis-kill-team").get("model_loadouts", [])
	return str(loadouts[model_index].get("role", "")) if model_index < loadouts.size() else ""

static func defaults(definition: String) -> Dictionary:
	return defaults_for_model(definition, 10, 0) if supports(definition) else {}

static func defaults_for_model(definition: String, models: int, model_index: int) -> Dictionary:
	match role(definition, models, model_index):
		"castellan-launcher-intercessor": return {ROCKET: "superfrag"}
		"sergeant": return {SERGEANT_MELEE: "knives-and-fists", SERGEANT_RANGED: "deathwatch-bolt-rifle", GRENADE_LAUNCHER: false}
		"plasma-incinerator-intercessor": return {PLASMA_PISTOL: false}
		"deathwatch-bolt-rifle-intercessor": return {GRENADE_LAUNCHER: false}
	return {}

static func model_label(definition: String, models: int, model_index: int) -> String:
	var model_role := role(definition, models, model_index)
	var labels := {
		"castellan-launcher-intercessor": "Castellan Launcher Intercessor",
		"sergeant": "Sergeant",
		"plasma-incinerator-intercessor": "Plasma Incinerator Intercessor",
		"deathwatch-bolt-rifle-intercessor": "Deathwatch Bolt Rifle Intercessor",
		"heavy-bolt-pistol-intercessor": "Heavy Bolt Pistol Intercessor",
		"pyreblaster-intercessor": "Pyreblaster Intercessor"
	}
	if model_role.is_empty(): return ""
	if model_role in ["castellan-launcher-intercessor", "sergeant"]: return str(labels[model_role])
	var ordinal := 0
	for index in range(model_index + 1):
		if role(definition, models, index) == model_role: ordinal += 1
	return "%s %d" % [str(labels[model_role]), ordinal]

static func _all_controls() -> Array[Dictionary]:
	return [
		{"field": SERGEANT_MELEE, "label": "Knives and Fists replacement", "choices": [
			{"id": "knives-and-fists", "label": "Knives and Fists"},
			{"id": "chainsword", "label": "Chainsword"},
			{"id": "power-fist", "label": "Power Fist"},
			{"id": "power-weapon", "label": "Power Weapon"},
			{"id": "thunder-hammer", "label": "Thunder Hammer"}
		]},
		{"field": SERGEANT_RANGED, "label": "Deathwatch Bolt Rifle replacement", "choices": [
			{"id": "deathwatch-bolt-rifle", "label": "Deathwatch Bolt Rifle"},
			{"id": "chainsword", "label": "Chainsword"},
			{"id": "hand-flamer", "label": "Hand Flamer"},
			{"id": "plasma-pistol", "label": "Plasma Pistol"},
			{"id": "power-weapon", "label": "Power Weapon"}
		]},
		{"field": GRENADE_LAUNCHER, "label": "Astartes Grenade Launcher (requires Deathwatch Bolt Rifle; 1 per 5 models)", "choices": [
			{"id": false, "label": "Not equipped"},
			{"id": true, "label": "Equipped"}
		]},
		{"field": PLASMA_PISTOL, "label": "Bolt Pistol replacement (one per unit)", "choices": [
			{"id": false, "label": "Bolt Pistol"},
			{"id": true, "label": "Plasma Pistol"}
		]},
		{"field": ROCKET, "label": "Castellan Launcher rocket", "choices": [
			{"id": "superfrag", "label": "Superfrag Rocket Launcher"},
			{"id": "superkrak", "label": "Superkrak Rocket Launcher"},
			{"id": "vengor", "label": "Vengor Launcher"}
		]}
	]

static func controls(definition: String) -> Array[Dictionary]:
	return _all_controls() if supports(definition) else []

static func controls_for_model(definition: String, models: int, model_index: int) -> Array[Dictionary]:
	match role(definition, models, model_index):
		"castellan-launcher-intercessor": return [_all_controls()[4]]
		"sergeant": return [_all_controls()[0], _all_controls()[1], _all_controls()[2]]
		"plasma-incinerator-intercessor": return [_all_controls()[3]]
		"deathwatch-bolt-rifle-intercessor": return [_all_controls()[2]]
	return []

static func valid(definition: String, equipment: Variant, models: int) -> bool:
	if not supports(definition) or not valid_size(models) or not equipment is Dictionary: return false
	if equipment.is_empty(): return true
	if equipment.has(ROCKET):
		return equipment.size() == 1 and equipment[ROCKET] is String and str(equipment[ROCKET]) in ROCKET_CHOICES
	if equipment.has(SERGEANT_MELEE) or equipment.has(SERGEANT_RANGED):
		if equipment.size() != 3 or not equipment.has(SERGEANT_MELEE) or not equipment.has(SERGEANT_RANGED) or not equipment.has(GRENADE_LAUNCHER): return false
		if not equipment[SERGEANT_MELEE] is String or str(equipment[SERGEANT_MELEE]) not in MELEE_CHOICES: return false
		if not equipment[SERGEANT_RANGED] is String or str(equipment[SERGEANT_RANGED]) not in RANGED_CHOICES: return false
		if not equipment[GRENADE_LAUNCHER] is bool: return false
		return not bool(equipment[GRENADE_LAUNCHER]) or str(equipment[SERGEANT_RANGED]) == "deathwatch-bolt-rifle"
	if equipment.has(GRENADE_LAUNCHER): return equipment.size() == 1 and equipment[GRENADE_LAUNCHER] is bool
	if equipment.has(PLASMA_PISTOL): return equipment.size() == 1 and equipment[PLASMA_PISTOL] is bool
	return false

static func valid_for_model(definition: String, equipment: Variant, models: int, model_index: int) -> bool:
	var model_role := role(definition, models, model_index)
	if model_role.is_empty() or not valid(definition, equipment, models): return false
	var expected := defaults_for_model(definition, models, model_index)
	if equipment.size() != expected.size(): return false
	for field: Variant in expected:
		if not equipment.has(field): return false
	match model_role:
		"castellan-launcher-intercessor": return equipment[ROCKET] is String and str(equipment[ROCKET]) in ROCKET_CHOICES
		"sergeant":
			return equipment[SERGEANT_MELEE] is String and str(equipment[SERGEANT_MELEE]) in MELEE_CHOICES \
				and equipment[SERGEANT_RANGED] is String and str(equipment[SERGEANT_RANGED]) in RANGED_CHOICES \
				and equipment[GRENADE_LAUNCHER] is bool \
				and (not bool(equipment[GRENADE_LAUNCHER]) or str(equipment[SERGEANT_RANGED]) == "deathwatch-bolt-rifle")
		"plasma-incinerator-intercessor": return equipment[PLASMA_PISTOL] is bool
		"deathwatch-bolt-rifle-intercessor": return equipment[GRENADE_LAUNCHER] is bool
		_: return equipment.is_empty()

static func valid_saved(definition: String, loadout: Variant, models: int) -> bool:
	if not supports(definition) or not valid_size(models) or not loadout is Array or loadout.size() != models: return false
	var grenade_launchers := 0
	var plasma_pistols := 0
	var source := P.profile("fortis-kill-team")
	for model_index in range(models):
		var equipment: Variant = loadout[model_index]
		if not valid_for_model(definition, equipment, models, model_index): return false
		if bool(equipment.get(GRENADE_LAUNCHER, false)): grenade_launchers += 1
		if bool(equipment.get(PLASMA_PISTOL, false)): plasma_pistols += 1
	var grenade_limit := int(source.options.grenade_launchers_per_five_models) * int(models / 5)
	return grenade_launchers <= grenade_limit and plasma_pistols <= int(source.options.plasma_pistol_limit)

static func points(_definition: String, _loadout: Variant, _models: int) -> int:
	return 0

static func prepare(unit: Dictionary, definition: String, equipment: Dictionary, models: int, model_index: int) -> void:
	if not valid_for_model(definition, equipment, models, model_index): return
	var model := P.fortis_kill_team_model_loadout(
		model_index,
		str(equipment.get(SERGEANT_MELEE, "knives-and-fists")),
		str(equipment.get(SERGEANT_RANGED, "deathwatch-bolt-rifle")),
		bool(equipment.get(GRENADE_LAUNCHER, false)),
		bool(equipment.get(PLASMA_PISTOL, false)),
		str(equipment.get(ROCKET, "superfrag"))
	)
	if model.is_empty(): return
	unit.fortis_kill_team_model = model_index
	unit.fortis_kill_team_role = str(model.role)
	unit.model_role = str(model.role)
	unit[ROCKET] = str(equipment.get(ROCKET, "superfrag"))
	unit[SERGEANT_MELEE] = str(equipment.get(SERGEANT_MELEE, "knives-and-fists"))
	unit[SERGEANT_RANGED] = str(equipment.get(SERGEANT_RANGED, "deathwatch-bolt-rifle"))
	unit[GRENADE_LAUNCHER] = bool(equipment.get(GRENADE_LAUNCHER, false))
	unit[PLASMA_PISTOL] = bool(equipment.get(PLASMA_PISTOL, false))
	unit.saved_equipment_model_index = model_index
	unit.saved_model_equipment = equipment.duplicate(true)
	unit.ranged_weapons = model.ranged.duplicate(true)
	unit.melee_weapons = model.melee.duplicate(true)
	unit.keywords = model.keywords.duplicate()
	unit.fortis_saved_equipment_locked = true
