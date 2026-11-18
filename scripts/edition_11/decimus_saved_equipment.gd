extends RefCounted
## Persistent, source-bounded Decimus Kill Team equipment for the admitted ten-model composition.
const P = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const DEFINITION := "40kdc:11e:adeptus-astartes:decimus-kill-team"
const GRAVIS_WEAPON := "decimus_gravis_weapon"
const STORM_SHIELD := "decimus_storm_shield"
const PLASMA_INCINERATOR := "decimus_plasma_incinerator"

static func supports(definition: String) -> bool:
	return definition == DEFINITION

static func valid_size(models: int) -> bool:
	return models == 10

static func _roles() -> Array:
	var compositions := P.decimus_kill_team_composition_options()
	return compositions[0].get("roles", []) if not compositions.is_empty() else []

static func role(definition: String, models: int, model_index: int) -> String:
	if not supports(definition) or not valid_size(models) or model_index < 0 or model_index >= models: return ""
	var roles := _roles()
	return str(roles[model_index]) if model_index < roles.size() else ""

static func defaults(definition: String) -> Dictionary:
	return defaults_for_model(definition, 10, 8) if supports(definition) else {}

static func defaults_for_model(definition: String, models: int, model_index: int) -> Dictionary:
	match role(definition, models, model_index):
		"gravis-veteran": return {GRAVIS_WEAPON: "infernus-heavy-bolter"}
		"heavy-veteran": return {STORM_SHIELD: false}
		"stalker-veteran": return {PLASMA_INCINERATOR: false}
	return {}

static func model_label(definition: String, models: int, model_index: int) -> String:
	var model_role := role(definition, models, model_index)
	var labels := {
		"xenophase-veteran": "Xenophase Veteran",
		"sergeant": "Sergeant",
		"marksman-veteran": "Marksman Veteran",
		"heavy-veteran": "Heavy Veteran",
		"stalker-veteran": "Stalker Veteran",
		"gravis-veteran": "Gravis Veteran"
	}
	if model_role.is_empty(): return ""
	if model_role in ["xenophase-veteran", "sergeant"]: return str(labels[model_role])
	var ordinal := 0
	for index in range(model_index + 1):
		if role(definition, models, index) == model_role: ordinal += 1
	return "%s %d" % [str(labels[model_role]), ordinal]

static func controls(definition: String) -> Array[Dictionary]:
	if not supports(definition): return []
	return [
		{"field": GRAVIS_WEAPON, "label": "Infernus Heavy Bolter replacement", "choices": [
			{"id": "infernus-heavy-bolter", "label": "Infernus Heavy Bolter"},
			{"id": "frag-cannon", "label": "Frag Cannon"},
			{"id": "hellstorm-bolt-rifle", "label": "Hellstorm Bolt Rifle + Grenade Launcher"}
		]},
		{"field": STORM_SHIELD, "label": "Heavy Thunder Hammer replacement", "choices": [
			{"id": false, "label": "Heavy Thunder Hammer"},
			{"id": true, "label": "Power Weapon + Storm Shield (4+ invulnerable save)"}
		]},
		{"field": PLASMA_INCINERATOR, "label": "Stalker Bolt Rifle replacement", "choices": [
			{"id": false, "label": "Stalker Bolt Rifle"},
			{"id": true, "label": "Plasma Incinerator"}
		]}
	]

static func controls_for_model(definition: String, models: int, model_index: int) -> Array[Dictionary]:
	match role(definition, models, model_index):
		"gravis-veteran": return [controls(definition)[0]]
		"heavy-veteran": return [controls(definition)[1]]
		"stalker-veteran": return [controls(definition)[2]]
	return []

static func valid(definition: String, equipment: Variant, models: int) -> bool:
	if not supports(definition) or not valid_size(models) or not equipment is Dictionary: return false
	if equipment.is_empty(): return true
	if equipment.size() != 1: return false
	if equipment.has(GRAVIS_WEAPON):
		return equipment[GRAVIS_WEAPON] is String and str(equipment[GRAVIS_WEAPON]) in ["infernus-heavy-bolter", "frag-cannon", "hellstorm-bolt-rifle"]
	if equipment.has(STORM_SHIELD): return equipment[STORM_SHIELD] is bool
	if equipment.has(PLASMA_INCINERATOR): return equipment[PLASMA_INCINERATOR] is bool
	return false

static func valid_for_model(definition: String, equipment: Variant, models: int, model_index: int) -> bool:
	if role(definition, models, model_index).is_empty() or not valid(definition, equipment, models): return false
	var expected := defaults_for_model(definition, models, model_index)
	if expected.is_empty(): return equipment.is_empty()
	if equipment.size() != expected.size(): return false
	var field := str(expected.keys()[0])
	if not equipment.has(field): return false
	if field == GRAVIS_WEAPON:
		return equipment[field] is String and str(equipment[field]) in ["infernus-heavy-bolter", "frag-cannon", "hellstorm-bolt-rifle"]
	return equipment[field] is bool

static func valid_saved(definition: String, loadout: Variant, models: int) -> bool:
	if not supports(definition) or not valid_size(models) or not loadout is Array or loadout.size() != models: return false
	var gravis_replacements := 0
	var storm_shields := 0
	var plasma_incinerators := 0
	var source := P.profile("decimus-kill-team")
	var per_five := int(models / 5)
	for model_index in range(models):
		var equipment: Variant = loadout[model_index]
		if not valid_for_model(definition, equipment, models, model_index): return false
		if bool(equipment.get(STORM_SHIELD, false)): storm_shields += 1
		if bool(equipment.get(PLASMA_INCINERATOR, false)): plasma_incinerators += 1
		if equipment.has(GRAVIS_WEAPON) and str(equipment[GRAVIS_WEAPON]) != "infernus-heavy-bolter": gravis_replacements += 1
	return gravis_replacements <= int(source.options.gravis_replacements_per_five_models) * per_five \
		and storm_shields <= int(source.options.storm_shields_per_five_models) * per_five \
		and plasma_incinerators <= int(source.options.plasma_incinerators_per_five_models) * per_five

static func points(_definition: String, _loadout: Variant, _models: int) -> int:
	return 0

static func prepare(unit: Dictionary, definition: String, equipment: Dictionary, models: int, model_index: int) -> void:
	if not valid_for_model(definition, equipment, models, model_index): return
	var model_role := role(definition, models, model_index)
	var gravis_weapon := str(equipment.get(GRAVIS_WEAPON, "infernus-heavy-bolter"))
	var storm_shield := bool(equipment.get(STORM_SHIELD, false))
	var plasma_incinerator := bool(equipment.get(PLASMA_INCINERATOR, false))
	var model := P.decimus_kill_team_model_loadout(model_role, gravis_weapon, storm_shield, plasma_incinerator)
	if model.is_empty(): return
	var stats: Dictionary = model.stats
	unit.decimus_kill_team_model = model_index
	unit.decimus_kill_team_role = model_role
	unit.model_role = model_role
	unit.sergeant = model_role == "sergeant"
	unit[GRAVIS_WEAPON] = gravis_weapon
	unit[STORM_SHIELD] = storm_shield
	unit[PLASMA_INCINERATOR] = plasma_incinerator
	unit.saved_equipment_model_index = model_index
	unit.saved_model_equipment = equipment.duplicate(true)
	unit.ranged_weapons = model.ranged.duplicate(true)
	unit.melee_weapons = model.melee.duplicate(true)
	unit.keywords = model.keywords.duplicate()
	unit.movement = int(stats.movement_inches)
	unit.max_wounds = int(stats.wounds)
	unit.wounds = unit.max_wounds
	unit.radius = float(model.base_radius_inches)
	unit.leadership_target = int(stats.leadership_target)
	unit.objective_control = int(stats.objective_control)
	unit.defense = {"toughness": stats.toughness, "save_target": stats.save_target, "invulnerable_target": 4 if model.storm_shield else stats.invulnerable_target}
	unit.decimus_saved_equipment_locked = true
