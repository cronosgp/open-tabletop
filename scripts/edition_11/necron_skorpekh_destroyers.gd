extends RefCounted
## Skorpekh Destroyers: Whirling Onslaught (App v1.2 local export 000002110).
## Plasmacyte tokens reuse necron_ophydian_destroyers.gd shared spend path.
const UnitAbilities = preload("res://scripts/edition_11/unit_abilities.gd")

const IDENTITY := "skorpekh-destroyers"
const WHIRLING := "whirling-onslaught"

static func hit_reroll(state: Dictionary, squad: int) -> String:
	if not UnitAbilities.enabled(state) or not UnitAbilities.has(state, squad, WHIRLING): return "none"
	if bool(state.get("squads", {}).get(squad, {}).get("charged", false)): return "all"
	return "ones"
