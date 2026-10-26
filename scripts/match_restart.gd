extends RefCounted
## Re-admit the same setup through the existing fresh-state builders.
const Prepared = preload("res://scripts/edition_11/prepared_training.gd")
const Combat = Prepared.Combat
const Battlefield = preload("res://scripts/edition_11/test_battlefield.gd")
const Lab = preload("res://scripts/edition_11/allocation_practice.gd")
const OPTIONS := ["manual_allocation", "varied_equipment", "core_stratagems", "movement_rerolls", "attack_rerolls", "save_rerolls", "damage_rerolls", "hazard_rerolls", "escape_rerolls", "count_rerolls", "objective_secured", "implacable_eradication", "hail_of_bolts", "oath_of_moment", "reanimation_protocols", "combat_doctrines", "awakened_dynasty", "unit_abilities", "official_mission", "checked_rosters"]

static func build(config: Dictionary, finished: Dictionary) -> Dictionary:
	if int(finished.get("test_winner", 0)) not in [-1, 1, 2]: return {"error": "Finish the current match before starting a rematch."}
	var candidate: Dictionary
	if config.get("saved_army_mode", false):
		candidate = Prepared.from_setup(finished.get("saved_army_setup", {}))
	elif config.get("prepared_match", false):
		var options := {}
		for key: String in OPTIONS: options[key] = config.get(key, false)
		options.primary_mission = config.get("official_primary_mission", "battlefield-dominance")
		var legacy_primary := str(options.primary_mission)
		var configured_primaries: Variant = config.get("official_primary_missions", {1: legacy_primary, 2: legacy_primary})
		options.primary_missions = configured_primaries.duplicate(true) if configured_primaries is Dictionary else {1: legacy_primary, 2: legacy_primary}
		options.secondary_pair = config.get("official_secondary_pair", Combat.Mission.DEFAULT_SECONDARY_PAIR)
		options.terrain_layout = config.get("official_terrain_layout", Combat.Mission.DEFAULT_TERRAIN_LAYOUT) if options.get("official_mission", false) else config.get("terrain_layout", Combat.Mission.DEFAULT_TERRAIN_LAYOUT)
		candidate = Prepared.initial_state(options)
	elif config.get("allocation_practice", false):
		candidate = Battlefield.apply(Lab.initial_state(config.get("damage_rerolls", false), config.get("count_rerolls", false)))
	elif config.get("combat_enabled", false):
		candidate = Battlefield.apply(Combat.initial_state(config.terrain_layout, config.mission_id, config.squads_per_side, config.manual_allocation, config.varied_equipment))
	else: return {"error": "Choose a combat scenario before starting a rematch."}
	if candidate.has("error"): return candidate
	if candidate.get("pack") != finished.get("pack") or candidate.get("pack_hash") != finished.get("pack_hash"):
		return {"error": "The finished match uses a different rules setup. Choose a new match from the menu."}
	return candidate
