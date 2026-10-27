extends RefCounted
## Builds the immutable identity for a prepared match.
## Kept separate from match setup so lobby, saves and transport can share one contract.
const Battlefield = preload("res://scripts/edition_11/test_battlefield.gd")
const TrainingCapabilities = preload("res://scripts/edition_11/army_capabilities.gd")
const RulesetIdentity = preload("res://scripts/edition_11/ruleset_identity.gd")
const Mission = preload("res://scripts/edition_11/chapter_approved.gd")
const Objectives = preload("res://scripts/edition_11/objectives.gd")
const Stratagems = preload("res://scripts/edition_11/stratagems.gd")
const ObjectiveSecured = preload("res://scripts/edition_11/objective_secured.gd")
const ImplacableEradication = preload("res://scripts/edition_11/implacable_eradication.gd")
const HailOfBolts = preload("res://scripts/edition_11/hail_of_bolts.gd")
const OathOfMoment = preload("res://scripts/edition_11/oath_of_moment.gd")
const Reanimation = preload("res://scripts/edition_11/reanimation_protocols.gd")
const Doctrines = preload("res://scripts/edition_11/combat_doctrines.gd")
const Awakened = preload("res://scripts/edition_11/awakened_dynasty.gd")
const UnitAbilities = preload("res://scripts/edition_11/unit_abilities.gd")
const DetachmentStratagems = preload("res://scripts/edition_11/detachment_stratagems.gd")
const RosterValidation = preload("res://scripts/edition_11/roster_validation.gd")
const ChapterRules = preload("res://scripts/edition_11/chapter_rules.gd")

static func seal(state: Dictionary, options: Dictionary, reports: Dictionary, effective: Dictionary, scenario_id: String) -> void:
	var rosters: Array[Dictionary] = []
	for owner in [1, 2]:
		var units: Array[Dictionary] = []
		for squad: int in state.squads:
			if state.squads[squad].owner == owner:
				var living_models := 0
				for model: int in state.units:
					if state.units[model].squad == squad and state.units[model].wounds > 0 and state.units[model].get("on_battlefield", true): living_models += 1
				units.append({"squad": squad, "name": state.squads[squad].name, "models": living_models})
		rosters.append({"owner": owner, "units": units, "official_legality_validated": false})
	state.match_manifest = {"schema_version": 1, "scenario": scenario_id, "rules_implementation": RulesetIdentity.PACK_ID,
		"content_hash": state.pack_hash, "battlefield": Battlefield.ID, "mission": Objectives.TRAINING,
		"manual_allocation": effective.manual_allocation, "varied_equipment": effective.varied_equipment, "first_player": 1, "rosters": rosters}
	var terrain_layout := str(effective.get("terrain_layout", ""))
	if not terrain_layout.is_empty(): state.match_manifest.terrain_layout = terrain_layout
	if effective.core_stratagems: state.match_manifest.core_stratagems = Stratagems.ID
	if effective.movement_rerolls: state.match_manifest.movement_rerolls = Stratagems.REROLL_ID
	if effective.attack_rerolls: state.match_manifest.attack_rerolls = Stratagems.ATTACK_REROLL_ID
	if effective.save_rerolls: state.match_manifest.save_rerolls = Stratagems.SAVE_REROLL_ID
	if effective.damage_rerolls: state.match_manifest.damage_rerolls = Stratagems.DAMAGE_REROLL_ID
	if effective.hazard_rerolls: state.match_manifest.hazard_rerolls = Stratagems.HAZARD_REROLL_ID
	if effective.escape_rerolls: state.match_manifest.escape_rerolls = Stratagems.ESCAPE_REROLL_ID
	if effective.count_rerolls: state.match_manifest.count_rerolls = Stratagems.COUNT_REROLL_ID
	if options.get("objective_secured", false): state.match_manifest.objective_secured = ObjectiveSecured.ID
	if options.get("implacable_eradication", false): state.match_manifest.implacable_eradication = ImplacableEradication.ID
	if options.get("hail_of_bolts", false): state.match_manifest.hail_of_bolts = HailOfBolts.ID
	if options.get("oath_of_moment", false): state.match_manifest.oath_of_moment = OathOfMoment.ID
	if options.get("reanimation_protocols", false): state.match_manifest.reanimation_protocols = Reanimation.ID
	if options.get("combat_doctrines", false):
		state.match_manifest.combat_doctrines = Doctrines.ID
		var detachments: Dictionary = options.get("marine_detachments", {}).duplicate(true)
		if detachments.is_empty():
			var detachment := str(options.get("marine_detachment", "gladius"))
			detachments = {1: detachment, 2: detachment}
		state.match_manifest.marine_detachments = detachments
		if detachments.get(1, detachments.get("1", "")) == detachments.get(2, detachments.get("2", "")):
			var common := str(detachments.get(1, detachments.get("1", "gladius")))
			if common != "gladius": state.match_manifest.marine_detachment = common
	if state.has("marine_chapters"):
		state.match_manifest.marine_chapter_rules = ChapterRules.ID
		state.match_manifest.marine_chapters = state.marine_chapters.duplicate(true)
		state.match_manifest.marine_chapter_selections = state.get("marine_chapter_selections", {1: "", 2: ""}).duplicate(true)
	if options.get("awakened_dynasty", false): state.match_manifest.awakened_dynasty = Awakened.ID
	if options.get("unit_abilities", false): state.match_manifest.unit_abilities = UnitAbilities.ID
	if DetachmentStratagems.enabled(state): state.match_manifest.detachment_stratagems = DetachmentStratagems.ID
	if not reports.is_empty():
		if reports[1].selection.schema_version == 2 or reports[2].selection.schema_version == 2:
			state.match_manifest.capabilities = TrainingCapabilities.ID
		state.match_manifest.scenario = str(options.get("training_scenario_id", "saved-army-training-v1"))
		state.match_manifest.saved_armies = state.saved_army_setup.duplicate(true)
		state.match_manifest.training_points = state.training_points.duplicate()
		state.match_manifest.official_legality_validated = false
	if options.get("checked_rosters", false):
		state.match_manifest.official_legality_validated = false
		state.match_manifest.rules_source_status = RosterValidation.CURRENT_SOURCE_STATUS
	if options.get("official_mission", false):
		state.match_manifest.mission = Mission.ID
		state.match_manifest.battlefield = Mission.ID
		state.match_manifest.official_mission = Mission.ID
		state.match_manifest.primary_mission = Mission.primary_id(state, 1)
		state.match_manifest.primary_missions = Mission.primary_assignments(state)
		var primary_overrides: Dictionary = state.mission.get("primary_overrides", {1: true, 2: true})
		var primary_selection_modes: Dictionary = state.mission.get("primary_selection_modes", {})
		state.match_manifest.primary_overrides = primary_overrides.duplicate(true)
		state.match_manifest.primary_selection_modes = primary_selection_modes.duplicate(true)
		state.match_manifest.primary_selection_mode = str(state.mission.get("primary_selection_mode", "direct-selection"))
		if options.get("sealed_force_disposition_reveal", false): state.match_manifest.sealed_force_disposition_reveal = true
		var force_dispositions := Mission.force_disposition_assignments(state)
		if not force_dispositions.is_empty():
			state.match_manifest.force_dispositions = force_dispositions
		state.match_manifest.secondary_pair = str(options.get("secondary_pair", Mission.DEFAULT_SECONDARY_PAIR))
		state.match_manifest.terrain_layout = str(options.get("terrain_layout", Mission.DEFAULT_TERRAIN_LAYOUT))
		state.match_manifest.first_player = "post-deployment-roll-off"
	if options.get("checked_rosters", false):
		state.roster_validation.full_match_certified = false
		state.match_manifest.checked_rosters = {"implementation": RosterValidation.ID, "digest": RosterValidation.digest(), "construction": state.roster_validation.armies.duplicate(true), "full_match_certified": false, "official_legality_validated": false, "source_status": RosterValidation.CURRENT_SOURCE_STATUS, "scope": "Saved Gladius/Awakened roster snapshot on the selected CA 2026-27 board; legacy MFM 1.6 prices remain attached to old lists, while supported rules use Wahapedia 11e and overall coverage is partial."}
	if str(options.get("training_scenario_id", "")) == "marine-tactical-training-v1":
		# Presentation metadata is persisted with the match so the optional practice
		# checklist can survive save/resume without changing rules resolution.
		state.training_experiments = {"standard_plasma": false, "supercharged_plasma": false, "hazardous": false}
	state.pack_hash = var_to_str(state.match_manifest).sha256_text()
