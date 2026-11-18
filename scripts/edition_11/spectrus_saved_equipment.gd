extends RefCounted
## Persistent, source-bounded model equipment for the fixed ten-model Spectrus Kill Team.
const P = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const DEFINITION := "40kdc:11e:adeptus-astartes:spectrus-kill-team"
const SNIPER := "spectrus_sniper_weapon"
const COMBAT_KNIFE := "spectrus_knife_replaced"
const HELIX := "spectrus_helix_gauntlet"
const SNIPER_CHOICES := ["bolt-sniper-rifle", "las-fusil", "instigator-bolt-carbine"]

static func supports(definition: String) -> bool:
	return definition == DEFINITION

static func valid_size(models: int) -> bool:
	return models == 10

static func role(definition: String, models: int, model_index: int) -> String:
	if not supports(definition) or not valid_size(models) or model_index < 0 or model_index >= models: return ""
	var loadouts: Array = P.profile("spectrus-kill-team").get("model_loadouts", [])
	return str(loadouts[model_index].get("role", "")) if model_index < loadouts.size() else ""

static func defaults(definition: String) -> Dictionary:
	return defaults_for_model(definition, 10, 0) if supports(definition) else {}

static func defaults_for_model(definition: String, models: int, model_index: int) -> Dictionary:
	match role(definition, models, model_index):
		"sniper-infiltrator": return {SNIPER: "bolt-sniper-rifle"}
		"special-issue-infiltrator": return {COMBAT_KNIFE: false}
		"marksman-infiltrator": return {HELIX: false}
	return {}

static func model_label(definition: String, models: int, model_index: int) -> String:
	var model_role := role(definition, models, model_index)
	var labels := {
		"sniper-infiltrator": "Sniper Infiltrator",
		"oculus-infiltrator": "Occulus Infiltrator",
		"special-issue-infiltrator": "Special-issue Infiltrator",
		"marksman-infiltrator": "Marksman Infiltrator"
	}
	if model_role.is_empty(): return ""
	var ordinal := 0
	for index in range(model_index + 1):
		if role(definition, models, index) == model_role: ordinal += 1
	return "%s %d" % [str(labels.get(model_role, "Model")), ordinal]

static func _all_controls() -> Array[Dictionary]:
	return [
		{"field": SNIPER, "label": "Bolt Sniper Rifle replacement", "choices": [
			{"id": "bolt-sniper-rifle", "label": "Bolt Sniper Rifle"},
			{"id": "las-fusil", "label": "Las Fusil"},
			{"id": "instigator-bolt-carbine", "label": "Instigator Bolt Carbine"}
		]},
		{"field": COMBAT_KNIFE, "label": "Combat Knife replacement", "choices": [
			{"id": false, "label": "Combat Knife"},
			{"id": true, "label": "Deathwatch Bolt Carbine + Ceramite Fists"}
		]},
		{"field": HELIX, "label": "Helix Gauntlet (one per unit)", "choices": [
			{"id": false, "label": "Deathwatch Marksman Bolt Carbine"},
			{"id": true, "label": "Helix Gauntlet"}
		]}
	]

static func controls(definition: String) -> Array[Dictionary]:
	return _all_controls() if supports(definition) else []

static func controls_for_model(definition: String, models: int, model_index: int) -> Array[Dictionary]:
	match role(definition, models, model_index):
		"sniper-infiltrator": return [_all_controls()[0]]
		"special-issue-infiltrator": return [_all_controls()[1]]
		"marksman-infiltrator": return [_all_controls()[2]]
	return []

static func valid(definition: String, equipment: Variant, models: int) -> bool:
	if not supports(definition) or not valid_size(models) or not equipment is Dictionary: return false
	if equipment.is_empty(): return true
	if equipment.has(SNIPER): return equipment.size() == 1 and equipment[SNIPER] is String and str(equipment[SNIPER]) in SNIPER_CHOICES
	if equipment.has(COMBAT_KNIFE): return equipment.size() == 1 and equipment[COMBAT_KNIFE] is bool
	if equipment.has(HELIX): return equipment.size() == 1 and equipment[HELIX] is bool
	return false

static func valid_for_model(definition: String, equipment: Variant, models: int, model_index: int) -> bool:
	var model_role := role(definition, models, model_index)
	if model_role.is_empty() or not valid(definition, equipment, models): return false
	var expected := defaults_for_model(definition, models, model_index)
	if equipment.size() != expected.size(): return false
	for field: Variant in expected:
		if not equipment.has(field): return false
	match model_role:
		"sniper-infiltrator": return equipment[SNIPER] is String and str(equipment[SNIPER]) in SNIPER_CHOICES
		"special-issue-infiltrator": return equipment[COMBAT_KNIFE] is bool
		"marksman-infiltrator": return equipment[HELIX] is bool
		_: return equipment.is_empty()

static func valid_saved(definition: String, loadout: Variant, models: int) -> bool:
	if not supports(definition) or not valid_size(models) or not loadout is Array or loadout.size() != models: return false
	var helix_count := 0
	for model_index in range(models):
		var equipment: Variant = loadout[model_index]
		if not valid_for_model(definition, equipment, models, model_index): return false
		if bool(equipment.get(HELIX, false)): helix_count += 1
	return helix_count <= int(P.profile("spectrus-kill-team").options.helix_gauntlet_limit)

static func points(_definition: String, _loadout: Variant, _models: int) -> int:
	return 0

static func prepare(unit: Dictionary, definition: String, equipment: Dictionary, models: int, model_index: int) -> void:
	if not valid_for_model(definition, equipment, models, model_index): return
	var model := P.spectrus_kill_team_model_loadout(
		model_index,
		str(equipment.get(SNIPER, "bolt-sniper-rifle")),
		bool(equipment.get(COMBAT_KNIFE, false)),
		bool(equipment.get(HELIX, false))
	)
	if model.is_empty(): return
	unit.spectrus_kill_team_model = model_index
	unit.spectrus_kill_team_role = str(model.role)
	unit.model_role = str(model.role)
	unit[SNIPER] = str(equipment.get(SNIPER, "bolt-sniper-rifle"))
	unit[COMBAT_KNIFE] = bool(equipment.get(COMBAT_KNIFE, false))
	unit[HELIX] = bool(equipment.get(HELIX, false))
	unit.saved_equipment_model_index = model_index
	unit.saved_model_equipment = equipment.duplicate(true)
	unit.ranged_weapons = model.ranged.duplicate(true)
	unit.melee_weapons = model.melee.duplicate(true)
	unit.keywords = model.keywords.duplicate()
	unit.spectrus_saved_equipment_locked = true
