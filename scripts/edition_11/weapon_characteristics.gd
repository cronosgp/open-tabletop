extends RefCounted
## Per-model/per-unit weapon characteristic modifiers. Their source owns duration and cleanup.
const UNIT_ABILITY_KEY := "weapon_skill_characteristic_modifiers"

static func modifier(state: Dictionary, squad: int, model: int, characteristic: String) -> int:
	if characteristic not in ["BS", "WS"]: return 0
	var records: Dictionary = state.get("unit_abilities", {}).get(UNIT_ABILITY_KEY, {})
	var unit_modifiers: Dictionary = records.get("squads", {}).get(squad, {})
	var model_modifiers: Dictionary = records.get("models", {}).get(model, {})
	return int(unit_modifiers.get(characteristic, 0)) + int(model_modifiers.get(characteristic, 0))

static func apply_skill_modifier(base_skill: Variant, modifier: int, ignored: bool = false) -> Variant:
	if not base_skill is int or base_skill <= 0: return base_skill
	var effective_modifier := 0 if ignored else modifier
	# A positive modifier improves the characteristic (3+ to 2+); a negative one worsens it.
	return clampi(int(base_skill) - effective_modifier, 2, 6)
