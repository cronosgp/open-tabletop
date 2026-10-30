extends RefCounted
## Deathwatch Fortis Doctrines reads the target's current model count, not remaining wounds.
const Geometry = preload("res://scripts/edition_11/contact_movement.gd")

static func target_strength_tier(state: Dictionary, target: int) -> int:
	if not state.get("squads", {}).has(target): return 0
	var living_models := Geometry.alive(state, target).size()
	var starting_strength := int(state.squads[target].get("starting_strength", 0))
	if living_models <= 0 or starting_strength <= 0: return 0
	if living_models * 2 <= starting_strength: return 2
	if living_models < starting_strength: return 1
	return 0
