extends RefCounted
## Builds the immutable identity for a prepared match.
## Kept separate from match setup so lobby, saves and transport can share one contract.
const Combat = preload("res://scripts/edition_11/combat_scenario.gd")
const Battlefield = preload("res://scripts/edition_11/test_battlefield.gd")
const Training = preload("res://scripts/edition_11/training_roster.gd")

static func seal(state: Dictionary, options: Dictionary, reports: Dictionary, effective: Dictionary, scenario_id: String) -> void:
	var rosters: Array[Dictionary] = []
	for owner in [1, 2]:
		var units: Array[Dictionary] = []
		for squad: int in state.squads:
			if state.squads[squad].owner == owner:
				units.append({"squad": squad, "name": state.squads[squad].name, "models": Combat.living(state, squad).size()})
		rosters.append({"owner": owner, "units": units, "official_legality_validated": false})
	state.match_manifest = {"schema_version": 1, "scenario": scenario_id, "rules_implementation": Combat.PACK_ID,
		"content_hash": state.pack_hash, "battlefield": Battlefield.ID, "mission": Combat.Objectives.TRAINING,
		"manual_allocation": effective.manual_allocation, "varied_equipment": effective.varied_equipment, "first_player": 1, "rosters": rosters}
	if effective.core_stratagems: state.match_manifest.core_stratagems = Combat.Stratagems.ID
	if effective.movement_rerolls: state.match_manifest.movement_rerolls = Combat.Stratagems.REROLL_ID
	if effective.attack_rerolls: state.match_manifest.attack_rerolls = Combat.Stratagems.ATTACK_REROLL_ID
	if effective.save_rerolls: state.match_manifest.save_rerolls = Combat.Stratagems.SAVE_REROLL_ID
	if effective.damage_rerolls: state.match_manifest.damage_rerolls = Combat.Stratagems.DAMAGE_REROLL_ID
	if effective.hazard_rerolls: state.match_manifest.hazard_rerolls = Combat.Stratagems.HAZARD_REROLL_ID
	if effective.escape_rerolls: state.match_manifest.escape_rerolls = Combat.Stratagems.ESCAPE_REROLL_ID
	if effective.count_rerolls: state.match_manifest.count_rerolls = Combat.Stratagems.COUNT_REROLL_ID
	if options.get("objective_secured", false): state.match_manifest.objective_secured = Combat.ObjectiveSecured.ID
	if options.get("implacable_eradication", false): state.match_manifest.implacable_eradication = Combat.ImplacableEradication.ID
	if options.get("hail_of_bolts", false): state.match_manifest.hail_of_bolts = Combat.HailOfBolts.ID
	if options.get("oath_of_moment", false): state.match_manifest.oath_of_moment = Combat.OathOfMoment.ID
	if options.get("reanimation_protocols", false): state.match_manifest.reanimation_protocols = Combat.Reanimation.ID
	if options.get("combat_doctrines", false):
		state.match_manifest.combat_doctrines = Combat.Doctrines.ID
		var detachment := str(options.get("marine_detachment", "gladius"))
		if detachment != "gladius": state.match_manifest.marine_detachment = detachment
	if options.get("awakened_dynasty", false): state.match_manifest.awakened_dynasty = Combat.Awakened.ID
	if options.get("unit_abilities", false): state.match_manifest.unit_abilities = Combat.UnitAbilities.ID
	if Combat.DetachmentStratagems.enabled(state): state.match_manifest.detachment_stratagems = Combat.DetachmentStratagems.ID
	if not reports.is_empty():
		if reports[1].selection.schema_version == 2 or reports[2].selection.schema_version == 2:
			state.match_manifest.capabilities = Training.Capabilities.ID
		state.match_manifest.scenario = "saved-army-training-v1"
		state.match_manifest.saved_armies = state.saved_army_setup.duplicate(true)
		state.match_manifest.training_points = state.training_points.duplicate()
		state.match_manifest.official_legality_validated = false
	if options.get("checked_rosters", false):
		state.match_manifest.official_legality_validated = false
		state.match_manifest.rules_source_status = Combat.RosterValidation.CURRENT_SOURCE_STATUS
	if options.get("official_mission", false):
		state.match_manifest.mission = Combat.Mission.ID
		state.match_manifest.battlefield = Combat.Mission.ID
		state.match_manifest.official_mission = Combat.Mission.ID
		state.match_manifest.first_player = "post-deployment-roll-off"
	if options.get("checked_rosters", false):
		state.roster_validation.full_match_certified = false
		state.match_manifest.checked_rosters = {"implementation": Combat.RosterValidation.ID, "digest": Combat.RosterValidation.digest(), "construction": state.roster_validation.armies.duplicate(true), "full_match_certified": false, "official_legality_validated": false, "source_status": Combat.RosterValidation.CURRENT_SOURCE_STATUS, "scope": "Saved Gladius/Awakened roster snapshot on the selected CA 2026-27 board; legacy MFM 1.6 prices remain attached to old lists, while supported rules use Wahapedia 11e and overall coverage is partial."}
	state.pack_hash = var_to_str(state.match_manifest).sha256_text()
