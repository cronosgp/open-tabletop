extends RefCounted
## Temporary Medusa's Wrath Dreadnought characteristics.
const Registry = preload("res://scripts/edition_11/capabilities.gd")
const ID := "medusa-ancient-fury"

static func active(state: Dictionary, squad: int) -> bool:
	if not Registry.enabled(state, ID) or not state.get("squads", {}).has(squad): return false
	var record: Dictionary = state.get("detachment_stratagems", {}).get("ancient_fury", {}).get(squad, {})
	return not record.is_empty() and int(record.get("owner", -1)) == int(state.squads[squad].get("owner", -2)) and int(state.get("turn", -1)) < int(record.get("expires_turn", -1))

static func movement_bonus(state: Dictionary, squad: int) -> float:
	return 1.0 if active(state, squad) else 0.0

static func toughness_bonus(state: Dictionary, squad: int) -> int:
	return 1 if active(state, squad) else 0

static func leadership_bonus(state: Dictionary, squad: int) -> int:
	return 1 if active(state, squad) else 0

static func objective_control_bonus(state: Dictionary, squad: int) -> int:
	return 1 if active(state, squad) else 0

static func hit_bonus(state: Dictionary, squad: int) -> int:
	return 1 if active(state, squad) else 0
