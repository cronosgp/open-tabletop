extends RefCounted
## Source-bounded Slayer's Oath and Oathbound effects for Ulrik the Slayer.
const Geometry = preload("res://scripts/edition_11/contact_movement.gd")
const AbilityCatalog = preload("res://scripts/edition_11/unit_ability_catalog.gd")

static func initial_targets(state: Dictionary, owner: int) -> Array[int]:
	var result: Array[int] = []
	for target: int in state.get("squads", {}):
		if int(state.squads[target].get("owner", -1)) == owner or Geometry.alive(state, target).is_empty(): continue
		for model: int in Geometry.alive(state, target):
			var keywords: Array = state.units[model].get("keywords", [])
			if "CHARACTER" in keywords or "MONSTER" in keywords or "VEHICLE" in keywords:
				result.append(target)
				break
	return result

static func initial_resolved(state: Dictionary, squad: int) -> bool:
	return bool(state.get("unit_abilities", {}).get("used", {}).get("slayer-oath-initial:%d" % squad, false))

static func selected_target(state: Dictionary, squad: int) -> int:
	return int(state.get("unit_abilities", {}).get("slayer_oaths", {}).get(squad, -1))

static func targets_oath(state: Dictionary, squad: int, target: int) -> bool:
	return AbilityCatalog.has(state, squad, "slayer-s-oath") and target >= 0 and selected_target(state, squad) == target

static func oathbound_hit_bonus(state: Dictionary, squad: int, melee: bool) -> int:
	return 1 if melee and AbilityCatalog.has(state, squad, "oathbound") else 0

static func oathbound_wound_bonus(state: Dictionary, squad: int, target: int, melee: bool) -> int:
	return 1 if melee and AbilityCatalog.has(state, squad, "oathbound") and targets_oath(state, squad, target) else 0

static func resolve_initial(state: Dictionary, squad: int, target: int) -> String:
	if not state.get("squads", {}).has(squad) or not AbilityCatalog.has(state, squad, "slayer-s-oath"):
		return "Slayer's Oath requires Ulrik the Slayer's unit."
	if initial_resolved(state, squad): return "This unit has already resolved its Slayer's Oath choice."
	var sources := AbilityCatalog.sources(state, squad, "slayer-s-oath")
	if sources.is_empty(): return "A living Ulrik the Slayer must be present for this choice."
	var owner := int(state.squads[squad].get("owner", -1))
	if target >= 0 and target not in initial_targets(state, owner): return "Select a living enemy CHARACTER, MONSTER or VEHICLE unit, or skip the choice."
	if not state.unit_abilities.has("slayer_oaths"): state.unit_abilities.slayer_oaths = {}
	state.unit_abilities.slayer_oaths[squad] = target
	if not state.unit_abilities.has("used"): state.unit_abilities.used = {}
	state.unit_abilities.used["slayer-oath-initial:%d" % squad] = true
	return ""
