extends RefCounted
## Source-bounded War Howl and Battle-lust effects for Ragnar Blackmane.
const Geometry = preload("res://scripts/edition_11/contact_movement.gd")
const AbilityCatalog = preload("res://scripts/edition_11/unit_ability_catalog.gd")

static func battle_lust_attack_bonus(state: Dictionary, model: int) -> int:
	if not AbilityCatalog.enabled(state) or not state.get("units", {}).has(model): return 0
	var unit: Dictionary = state.units[model]
	if AbilityCatalog.identity(unit) != "ragnar-blackmane": return 0
	var squad := int(unit.get("squad", -1))
	if not state.get("squads", {}).has(squad) or not AbilityCatalog.has(state, squad, "battle-lust"): return 0
	return 2 if bool(state.squads[squad].get("charged", false)) else 0

static func blood_claws_war_howl_active(state: Dictionary, squad: int) -> bool:
	return _war_howl_attached_to(state, squad, "blood-claws")

static func headtakers_war_howl_active(state: Dictionary, squad: int) -> bool:
	return _war_howl_attached_to(state, squad, "wolf-guard-headtakers")

static func _war_howl_attached_to(state: Dictionary, squad: int, bodyguard_identity: String) -> bool:
	if not AbilityCatalog.has(state, squad, "war-howl"): return false
	for model: int in Geometry.alive(state, squad):
		if AbilityCatalog.identity(state.units[model]) == bodyguard_identity: return true
	return false
