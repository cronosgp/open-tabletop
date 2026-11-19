extends RefCounted
## Persistent source-listed weapon choices for admitted Necron vehicle profiles.
const Profiles = preload("res://scripts/edition_11/current_reference_necron_profiles.gd")

const ANNIHILATION_BARGE := "annihilation-barge"
const MONOLITH := "monolith"
const ANNIHILATION_BARGE_DEFINITION_ID := "40kdc:11e:necrons:annihilation-barge"
const MONOLITH_DEFINITION_ID := "40kdc:11e:necrons:monolith"
const BARGE_GAUSS := "gauss-cannon"
const BARGE_TESLA := "tesla-cannon"
const MONOLITH_ARCS := "gauss-flux-arcs"
const MONOLITH_RAYS := "death-rays"

static func default_choice(definition_id: String) -> String:
	if definition_id.ends_with(":" + ANNIHILATION_BARGE): return BARGE_GAUSS
	if definition_id.ends_with(":" + MONOLITH): return MONOLITH_ARCS
	return ""

static func valid_choice(definition_id: String, choice_id: String) -> bool:
	if definition_id.ends_with(":" + ANNIHILATION_BARGE): return choice_id in [BARGE_GAUSS, BARGE_TESLA]
	if definition_id.ends_with(":" + MONOLITH): return choice_id in [MONOLITH_ARCS, MONOLITH_RAYS]
	return false

static func choice_label(definition_id: String, choice_id: String) -> String:
	if definition_id.ends_with(":" + ANNIHILATION_BARGE): return "Tesla cannon" if choice_id == BARGE_TESLA else "Gauss cannon"
	if definition_id.ends_with(":" + MONOLITH): return "Four Death Rays" if choice_id == MONOLITH_RAYS else "Four Gauss Flux Arcs"
	return ""

static func prepare_model(unit: Dictionary, definition_id: String, choice_id: String) -> String:
	if not valid_choice(definition_id, choice_id): return "This Necron vehicle has no supported local saved weapon choice."
	var ranged := ranged_weapons(definition_id, choice_id)
	if ranged.is_empty(): return "The local Necrons App v1.2 weapon replacement profile is incomplete."
	unit.ranged_weapons = ranged
	if definition_id.ends_with(":" + ANNIHILATION_BARGE):
		unit.necron_annihilation_barge_loadout = choice_id
		unit.annihilation_barge_loadout_locked = true
	else:
		unit.necron_monolith_loadout = choice_id
		unit.monolith_loadout_locked = true
	return ""

static func ranged_weapons(definition_id: String, choice_id: String, profile_override: Dictionary = {}) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if not valid_choice(definition_id, choice_id): return result
	var source := profile_override.duplicate(true) if not profile_override.is_empty() else Profiles.profile(ANNIHILATION_BARGE if definition_id.ends_with(":" + ANNIHILATION_BARGE) else MONOLITH)
	if source.is_empty(): return result
	if definition_id.ends_with(":" + ANNIHILATION_BARGE):
		for weapon: Variant in source.get("ranged", []):
			if weapon is Dictionary: result.append(weapon.duplicate(true))
		if choice_id == BARGE_GAUSS: return result if result.size() == 2 else []
		var alternatives: Array = source.get("additional_weapon_profiles", {}).get("ranged", [])
		if alternatives.size() != 1: return []
		var replaced := false
		for index in range(result.size()):
			if str(result[index].get("id", "")) != "source-ranged-1": continue
			result[index] = alternatives[0].duplicate(true)
			replaced = true
			break
		return result if replaced and result.size() == 2 else []
	var selected: Array = []
	if choice_id == MONOLITH_RAYS:
		var alternatives: Array = source.get("additional_weapon_profiles", {}).get("ranged", [])
		if alternatives.size() != 1: return []
		var rays: Dictionary = alternatives[0].duplicate(true)
		rays.count = 4
		selected.append(rays)
		for weapon: Dictionary in source.get("ranged", []):
			if str(weapon.get("id", "")) == "particle-whip": selected.append(weapon.duplicate(true))
	else:
		selected = source.get("ranged", []).duplicate(true)
	for weapon: Dictionary in selected:
		var copies := maxi(1, int(weapon.get("count", 1)))
		for index in range(copies):
			var copy: Dictionary = weapon.duplicate(true)
			copy.erase("count")
			if copies > 1: copy.id = "%s-%d" % [str(weapon.get("id", "weapon")), index + 1]
			result.append(copy)
	return result if result.size() == 5 else []
