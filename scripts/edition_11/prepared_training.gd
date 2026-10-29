extends RefCounted
## Versioned custom setup; does not claim legal official army construction.
const Combat = preload("res://scripts/edition_11/combat_scenario.gd")
const Battlefield = preload("res://scripts/edition_11/test_battlefield.gd")
const Deployment = preload("res://scripts/edition_11/deployment.gd")
const Training = preload("res://scripts/edition_11/training_roster.gd")
const MatchManifest = preload("res://scripts/edition_11/match_manifest.gd")
const CurrentMarineProfiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const ChapterRules = preload("res://scripts/edition_11/chapter_rules.gd")
const StormlanceEnhancements = preload("res://scripts/edition_11/stormlance_enhancements.gd")
const ID := "prepared-objective-training-v2"

static func force_disposition_error(reports: Dictionary, force_dispositions: Dictionary) -> String:
	if force_dispositions.is_empty(): return ""
	if force_dispositions.size() != 2: return "Select one available Force Disposition for each checked roster."
	for owner in [1, 2]:
		var report: Variant = reports.get(owner, {})
		var construction: Dictionary = report.get("construction", {}) if report is Dictionary else {}
		var roster_detachments: Array = construction.get("detachments", [])
		var available: Array = roster_detachments[0].get("force_dispositions", []) if not roster_detachments.is_empty() and roster_detachments[0] is Dictionary else []
		var selected := str(force_dispositions.get(owner, force_dispositions.get(str(owner), "")))
		if selected not in available: return "Player %d's Force Disposition is not available from the selected checked-roster detachment." % owner
	return ""

static func initial_state(options: Dictionary = {}, selections: Dictionary = {}, current_marine_templates: bool = false, defer_secondary_target_check: bool = false) -> Dictionary:
	var marine_detachment := str(options.get("marine_detachment", "gladius" if options.get("combat_doctrines", false) else "none"))
	var marine_detachments: Dictionary = options.get("marine_detachments", {}).duplicate(true)
	if marine_detachments.is_empty(): marine_detachments = {1: marine_detachment, 2: marine_detachment}
	var marine_chapter_selections := {1: "", 2: ""}
	if options.has("marine_chapters"):
		if not options.marine_chapters is Dictionary: return {"error": "Chapter selections must be a per-player map."}
		for owner: Variant in options.marine_chapters:
			if int(owner) not in [1, 2]: return {"error": "Choose a Chapter context for Player 1 or Player 2."}
		marine_chapter_selections = ChapterRules.normalize_assignments(options.marine_chapters)
		for owner in [1, 2]:
			var chapter := str(marine_chapter_selections[owner])
			if not chapter.is_empty() and not CurrentMarineProfiles.CHAPTER_KEYWORD_NAMES.has(chapter):
				return {"error": "Choose a recognized Space Marine Chapter for Player %d." % owner}
			if not chapter.is_empty() and not options.get("unit_abilities", false):
				return {"error": "Chapter context requires current unit abilities to be enabled."}
	for owner: Variant in marine_detachments:
		if int(owner) not in [1, 2] or str(marine_detachments[owner]) not in Combat.Doctrines.DETACHMENTS: return {"error": "Choose a supported Space Marine detachment for each player."}
	for owner in [1, 2]:
		if not marine_detachments.has(owner) and not marine_detachments.has(str(owner)): marine_detachments[owner] = marine_detachment
	var terrain_layout := str(options.get("terrain_layout", Combat.Terrain.DEFAULT_LAYOUT))
	var primary_mission := str(options.get("primary_mission", "battlefield-dominance"))
	var primary_missions := {1: primary_mission, 2: primary_mission}
	if options.has("primary_missions"):
		if not options.primary_missions is Dictionary: return {"error": "Primary missions must be selected for Player 1 and Player 2."}
		for raw_owner: Variant in options.primary_missions:
			var owner := int(raw_owner)
			var selected_primary := str(options.primary_missions[raw_owner])
			if owner not in [1, 2]: return {"error": "Choose a primary mission for Player 1 or Player 2."}
			if not Combat.Mission.PRIMARY_MISSIONS.has(selected_primary): return {"error": "Select a supported 11th-edition primary mission for Player %d." % owner}
			primary_missions[owner] = selected_primary
		primary_mission = str(primary_missions[1])
	var primary_overrides := {1: true, 2: true}
	if options.has("primary_overrides"):
		if not options.primary_overrides is Dictionary: return {"error": "Primary override modes must be selected for Player 1 and Player 2."}
		for raw_owner: Variant in options.primary_overrides:
			var owner := int(raw_owner)
			if owner not in [1, 2] or typeof(options.primary_overrides[raw_owner]) != TYPE_BOOL: return {"error": "Each primary override mode must be a Boolean for Player 1 or Player 2."}
			primary_overrides[owner] = bool(options.primary_overrides[raw_owner])
	var secondary_pair := str(options.get("secondary_pair", Combat.Mission.DEFAULT_SECONDARY_PAIR))
	var force_dispositions: Dictionary = {}
	if options.has("force_dispositions"):
		if not options.force_dispositions is Dictionary: return {"error": "Force Dispositions must be selected for Player 1 and Player 2."}
		force_dispositions = options.force_dispositions.duplicate(true)
	var sealed_force_disposition_reveal: Variant = options.get("sealed_force_disposition_reveal", false)
	if typeof(sealed_force_disposition_reveal) != TYPE_BOOL: return {"error": "Sealed Force Disposition reveal must be a Boolean match option."}
	if sealed_force_disposition_reveal and (not options.get("official_mission", false) or not options.get("checked_rosters", false) or not force_dispositions.is_empty() or primary_overrides != {1: false, 2: false}):
		return {"error": "Sealed Force Disposition reveal requires the checked Chapter Approved profile, no preselected Force Dispositions and matchup defaults for both players."}
	if sealed_force_disposition_reveal and marine_detachments.values().any(func(value: Variant) -> bool: return str(value) == "vow-sworn-crusaders"):
		return {"error": "The sealed Force Disposition flow has no supported primary-card defaults for Purge the Foe; choose direct primary missions instead."}
	if not force_dispositions.is_empty() and (not options.get("official_mission", false) or not options.get("checked_rosters", false)):
		return {"error": "Force Disposition choices require the checked Chapter Approved roster profile."}
	var terrain_profile := Combat.Terrain.layout(terrain_layout)
	if terrain_profile.has("error"): return {"error": str(terrain_profile.error)}
	if options.get("official_mission", false) and not Combat.Terrain.is_event_layout(terrain_layout): return {"error": "Select a supported 11th-edition Event Companion terrain layout."}
	if options.get("official_mission", false):
		for owner in [1, 2]:
			if not Combat.Mission.PRIMARY_MISSIONS.has(str(primary_missions[owner])): return {"error": "Select a supported 11th-edition Chapter Approved primary mission for Player %d." % owner}
	if options.get("official_mission", false) and not Combat.Mission.SECONDARY_PAIRS.has(secondary_pair): return {"error": "Select a supported 11th-edition fixed secondary pair."}
	if marine_detachment not in Combat.Doctrines.DETACHMENTS: return {"error": "Unsupported Space Marine detachment: " + marine_detachment}
	if not options.get("combat_doctrines", false) and marine_detachments.values().any(func(value: Variant) -> bool: return str(value) != "none"): return {"error": "Select Space Marine detachments only with 11e Combat Doctrines enabled."}
	for selected_detachment: Variant in marine_detachments.values():
		if selected_detachment == "fist-of-the-god-emperor" and not options.get("unit_abilities", false): return {"error": "Fist of the God-Emperor requires current unit abilities enabled for Crusader Squad's Righteous Zeal Surge and the Purge and Sanctify rule."}
		if selected_detachment == "vow-sworn-crusaders" and not options.get("unit_abilities", false): return {"error": "Vow-sworn Crusaders requires current unit abilities enabled for its bounded Templar Vows implementation and Black Templars Chapter context."}
		if selected_detachment == "spearpoint-task-force" and not options.get("unit_abilities", false): return {"error": "Spearpoint Task Force requires current unit abilities enabled for Suboden Khan's end-of-Fight-phase move."}
		if selected_detachment == "darkflight-pursuit" and not options.get("unit_abilities", false): return {"error": "Darkflight Pursuit requires current unit abilities enabled for its Dark Angels Chapter context and conditional Ravenwing keywords."}
		if selected_detachment == "inner-circle-task-force" and not options.get("unit_abilities", false): return {"error": "Inner Circle Task Force requires current unit abilities enabled for its Dark Angels Chapter context and conditional Deathwing keywords."}
		if selected_detachment == "medusa-wrath" and not options.get("unit_abilities", false): return {"error": "Medusa's Wrath requires current unit abilities enabled for its Iron Hands Chapter context."}
		if selected_detachment == "blade-of-ultramar" and not options.get("unit_abilities", false): return {"error": "Blade of Ultramar requires current unit abilities enabled for its Ultramarines Chapter context and Marneus Calgar rule."}
		if options.get("checked_rosters", false) and selected_detachment not in ["gladius", "fist-of-the-god-emperor", "vow-sworn-crusaders"]: return {"error": "The checked-roster snapshot supports Gladius and bounded Black Templars Fist/Vow-sworn profiles only."}
		if options.get("official_mission", false) and selected_detachment not in ["gladius", "fist-of-the-god-emperor", "vow-sworn-crusaders"]: return {"error": "This Space Marine detachment is not reconciled for the selected CA mission."}
	if options.get("combat_doctrines", false) and options.get("oath_of_moment", false): return {"error": "11e Combat Doctrines replaces the historical Oath of Moment profile; these options cannot be combined."}
	for key: Variant in options:
		if key in ["marine_detachment", "marine_detachments", "marine_chapters", "terrain_layout", "primary_mission", "primary_missions", "primary_overrides", "secondary_pair", "force_dispositions", "sealed_force_disposition_reveal", "training_scenario_id"]: continue
		if key not in ["manual_allocation", "varied_equipment", "core_stratagems", "movement_rerolls", "attack_rerolls", "save_rerolls", "damage_rerolls", "hazard_rerolls", "count_rerolls", "objective_secured", "implacable_eradication", "escape_rerolls", "hail_of_bolts", "oath_of_moment", "reanimation_protocols", "combat_doctrines", "awakened_dynasty", "unit_abilities", "official_mission", "checked_rosters"]: return {"error": "Unsupported match option: " + str(key)}
		if not options[key] is bool: return {"error": "Match options must be boolean: " + str(key)}
	if options.get("unit_abilities", false) and (options.get("hail_of_bolts", false) or options.get("objective_secured", false) or options.get("oath_of_moment", false)): return {"error": "Current datasheets cannot combine with historical Hail of Bolts, Objective Secured or Oath profiles."}
	if options.get("official_mission", false):
		for required in ["unit_abilities", "combat_doctrines", "reanimation_protocols", "awakened_dynasty", "core_stratagems"]:
			if not options.get(required, false) and not (required == "core_stratagems" and options.get("checked_rosters", false)):
				return {"error": "The CA mission requires current unit, faction and core stratagem options."}
	if options.get("checked_rosters", false) and not options.get("official_mission", false): return {"error": "Checked rosters require the selected current CA mission."}
	if options.get("checked_rosters", false) and selections.is_empty(): selections = Combat.RosterValidation.defaults()
	var manual: bool = options.get("manual_allocation", true)
	var varied: bool = options.get("varied_equipment", false)
	if varied and options.get("unit_abilities", false): return {"error": "Current unit abilities use the documented fixed loadouts."}
	var core: bool = options.get("core_stratagems", false)
	var movement_rerolls: bool = options.get("movement_rerolls", false)
	var attack_rerolls: bool = options.get("attack_rerolls", false)
	var save_rerolls: bool = options.get("save_rerolls", false)
	var damage_rerolls: bool = options.get("damage_rerolls", false)
	var hazard_rerolls: bool = options.get("hazard_rerolls", false)
	var count_rerolls: bool = options.get("count_rerolls", false)
	var escape_rerolls: bool = options.get("escape_rerolls", false)
	if options.get("checked_rosters", false):
		core = true
		movement_rerolls = true
		attack_rerolls = true
		save_rerolls = true
		damage_rerolls = true
		hazard_rerolls = true
		count_rerolls = true
		escape_rerolls = true
	if (movement_rerolls or attack_rerolls or save_rerolls or damage_rerolls or hazard_rerolls or count_rerolls or escape_rerolls) and not core: return {"error": "Command Re-roll requires the core stratagems option."}
	var reports: Dictionary = {}
	if not selections.is_empty():
		if selections.size() != 2 or not selections.has(1) or not selections.has(2): return {"error": "Select both armies."}
		if varied: return {"error": "Saved lists use this training mode's fixed default weapons."}
		for owner in [1, 2]:
			var detachment_id := str(marine_detachments.get(owner, marine_detachments.get(str(owner), marine_detachment))) if options.get("combat_doctrines", false) else "none"
			var roster_context := {"marine_detachment": detachment_id}
			var is_marine_roster := selections[owner] is Dictionary and str(selections[owner].get("faction", "")) == "Space Marines"
			var report := Combat.RosterValidation.admit(selections[owner], detachment_id if is_marine_roster else "") if options.get("checked_rosters", false) else Training.admit(selections[owner], roster_context)
			if not report.error.is_empty(): return report
			for resolved: Dictionary in report.definitions.values() if report.has("definitions") else []:
				if resolved.get("requires_current_abilities", false) and not options.get("unit_abilities", false): return {"error": "This Marine profile requires current unit abilities to be enabled."}
			reports[owner] = report
			if options.get("combat_doctrines", false) and report.selection.faction == "Space Marines" and str(marine_detachments.get(owner, marine_detachments.get(str(owner), "none"))) == "none": return {"error": "11e Combat Doctrines requires a declared detachment for each Space Marine army."}
			for entry: Dictionary in report.selection.get("entries", []):
				var enhancement_id := str(entry.get("enhancement_id", ""))
				if enhancement_id != "":
					var enhancement: Dictionary = StormlanceEnhancements.RECORDS.get(enhancement_id, {})
					var assigned_detachment := str(marine_detachments.get(owner, marine_detachments.get(str(owner), marine_detachment)))
					if enhancement.is_empty() or str(enhancement.get("detachment", "")) != assigned_detachment:
						return {"error": "The selected enhancement requires its matching Space Marine detachment in the match setup."}
		if reports[1].selection.category != reports[2].selection.category or reports[1].selection.points_limit != reports[2].selection.points_limit:
			return {"error": "Players must choose the same category and points limit."}
	if options.get("official_mission", false) and not reports.is_empty():
		if reports[1].selection.faction != "Space Marines" or reports[2].selection.faction != "Necrons" or reports[1].selection.points_limit != 1000 or reports[1].selection.category != "incursion": return {"error": "This selected CA mission admits Space Marines P1 vs Necrons P2 with a 1000-point Incursion limit; prices and army legality remain reference data."}
	var disposition_error := force_disposition_error(reports, force_dispositions)
	if not disposition_error.is_empty(): return {"error": disposition_error}
	if force_dispositions.values().any(func(value: Variant) -> bool: return str(value) == "purge-the-foe") and primary_overrides != {1: true, 2: true}:
		return {"error": "Purge the Foe requires direct primary-mission selections for both players; its matchup defaults are not implemented."}
	var use_current_templates := current_marine_templates or _current_marine_setup(selections)
	var state := Battlefield.apply(Combat.initial_state(terrain_layout, Combat.Objectives.TRAINING, 2, manual, varied, use_current_templates))
	if state.has("error"): return state
	if core: Combat.Stratagems.enable(state, movement_rerolls, attack_rerolls, save_rerolls, damage_rerolls, hazard_rerolls, count_rerolls, escape_rerolls)
	if not reports.is_empty():
		var original := state.duplicate(true)
		state.units = {}
		state.squads = {}
		for owner in [1, 2]:
			var report: Dictionary = reports[owner]
			var selection: Dictionary = report.selection
			if selection.schema_version == 2:
				_materialize_mixed(state, original, report, owner)
				continue
			for index in range(selection.copies):
				var squad: int = owner + index * 2
				state.squads[squad] = original.squads[report.template].duplicate(true)
				state.squads[squad].owner = owner
				state.squads[squad].name += " %d" % (index + 1)
				for model in range(selection.models):
					var unit: Dictionary = original.units[report.template * 100 + model].duplicate(true)
					unit.owner = owner
					unit.squad = squad
					unit.position = Vector2((-12.0 - floori(model / 5.0) * 1.5) if owner == 1 else (12.0 + floori(model / 5.0) * 1.5), (model % 5 - 2) * 1.3 + (-4.0 + index * 8.0 if selection.copies == 2 else 0.0))
					state.units[squad * 100 + model] = unit
		state.points_limit = reports[1].selection.points_limit
		state.battle_size = "Custom training"
		state.test_battlefield = "saved-army-training-43x43-v1"
		state.training_points = {1: reports[1].total, 2: reports[2].total}
		state.saved_army_setup = {"schema_version": 1, "options": {"manual_allocation": manual, "varied_equipment": false, "terrain_layout": terrain_layout},
			"armies": {1: reports[1].selection, 2: reports[2].selection}}
		state.saved_army_setup.options.marine_detachments = marine_detachments.duplicate(true)
		if marine_detachments.get(1, "") == marine_detachments.get(2, "") and marine_detachments.get(1, "") != "none": state.saved_army_setup.options.marine_detachment = marine_detachment
		if options.get("unit_abilities", false) and options.has("marine_chapters"): state.saved_army_setup.options.marine_chapters = marine_chapter_selections.duplicate(true)
		if core: state.saved_army_setup.options.core_stratagems = true
		if movement_rerolls: state.saved_army_setup.options.movement_rerolls = true
		if attack_rerolls: state.saved_army_setup.options.attack_rerolls = true
		if save_rerolls: state.saved_army_setup.options.save_rerolls = true
		if damage_rerolls: state.saved_army_setup.options.damage_rerolls = true
		if hazard_rerolls: state.saved_army_setup.options.hazard_rerolls = true
		if escape_rerolls: state.saved_army_setup.options.escape_rerolls = true
		if count_rerolls: state.saved_army_setup.options.count_rerolls = true
	if options.get("objective_secured", false):
		Combat.ObjectiveSecured.enable(state)
		if not reports.is_empty(): state.saved_army_setup.options.objective_secured = true
	if options.get("implacable_eradication", false):
		Combat.ImplacableEradication.enable(state)
		if not reports.is_empty(): state.saved_army_setup.options.implacable_eradication = true
	if options.get("hail_of_bolts", false):
		Combat.HailOfBolts.enable(state)
		if not reports.is_empty(): state.saved_army_setup.options.hail_of_bolts = true
	if options.get("oath_of_moment", false):
		Combat.OathOfMoment.enable(state)
		if not reports.is_empty(): state.saved_army_setup.options.oath_of_moment = true
	if options.get("reanimation_protocols", false):
		Combat.Reanimation.enable(state)
		if not reports.is_empty(): state.saved_army_setup.options.reanimation_protocols = true
	if options.get("combat_doctrines", false):
		Combat.Doctrines.enable(state, marine_detachments)
		if not reports.is_empty():
			state.saved_army_setup.options.combat_doctrines = true
			state.saved_army_setup.options.marine_detachments = marine_detachments.duplicate(true)
			if marine_detachments.get(1, "") == marine_detachments.get(2, ""): state.saved_army_setup.options.marine_detachment = marine_detachment
		if marine_detachments.values().any(func(value: Variant) -> bool: return str(value) == "gauntlet-task-force"):
			Combat.DetachmentStratagems.enable_gauntlet(state)
	if options.get("awakened_dynasty", false):
		Combat.Awakened.enable(state)
		if not reports.is_empty(): state.saved_army_setup.options.awakened_dynasty = true
	if options.get("unit_abilities", false):
		var loadout_error := _current_loadouts(state)
		if not loadout_error.is_empty(): return {"error": loadout_error}
		Combat.UnitAbilities.enable(state)
		if not reports.is_empty(): state.saved_army_setup.options.unit_abilities = true
		var needs_chapter_context := options.has("marine_chapters") or ChapterRules.has_current_reference_marines(state) or marine_detachments.values().any(func(value: Variant) -> bool: return ChapterRules.requires_chapter_context(str(value)))
		if needs_chapter_context:
			var chapter_result := ChapterRules.resolve_and_apply(state, marine_detachments, marine_chapter_selections)
			if not str(chapter_result.get("error", "")).is_empty(): return {"error": str(chapter_result.error)}
			if not reports.is_empty(): state.saved_army_setup.options.marine_chapters = chapter_result.selections.duplicate(true)
		if marine_detachments.values().any(func(value: Variant) -> bool: return str(value) == "inner-circle-task-force"):
			for owner in [1, 2]:
				if str(marine_detachments.get(owner, marine_detachments.get(str(owner), "none"))) == "inner-circle-task-force" and not Combat.OathOfMoment.marine_army(state, owner):
					return {"error": "Inner Circle Task Force currently requires a current-reference Space Marine roster for its selected player."}
			Combat.VowedTarget.enable(state)
		var unique_detachments: Array[String] = []
		for selected_detachment: Variant in marine_detachments.values():
			if str(selected_detachment) not in unique_detachments: unique_detachments.append(str(selected_detachment))
		for selected_detachment: String in unique_detachments:
			if selected_detachment == "gladius": Combat.DetachmentStratagems.enable_gladius(state)
			if selected_detachment == "fist-of-the-god-emperor": Combat.DetachmentStratagems.enable_fist(state)
			if selected_detachment == "assault-brethren": Combat.DetachmentStratagems.enable_assault_brethren(state)
			if selected_detachment == "tactical-brethren": Combat.DetachmentStratagems.enable_tactical_brethren(state)
			if selected_detachment == "devastator-brethren": Combat.DetachmentStratagems.enable_devastator_brethren(state)
			if selected_detachment == "stormlance": Combat.DetachmentStratagems.enable_stormlance(state)
			if selected_detachment == "ironclad-champions": Combat.DetachmentStratagems.enable_ironclad(state)
			if selected_detachment == "ironstorm-spearhead": Combat.DetachmentStratagems.enable_ironstorm(state)
			if selected_detachment == "spearpoint-task-force": Combat.DetachmentStratagems.enable_spearpoint(state)
			if selected_detachment == "wrath-of-the-rock": Combat.DetachmentStratagems.enable_wrath_of_the_rock(state)
			if selected_detachment == "inner-circle-task-force": Combat.DetachmentStratagems.enable_inner_circle(state)
			if selected_detachment == "medusa-wrath": Combat.DetachmentStratagems.enable_medusa_wrath(state)
			if selected_detachment == "vow-sworn-crusaders": Combat.DetachmentStratagems.enable_vow_sworn(state)
			if selected_detachment == "blade-of-ultramar": Combat.DetachmentStratagems.enable_blade_of_ultramar(state)
			if selected_detachment == "darkflight-pursuit": Combat.DetachmentStratagems.enable_darkflight(state)
			if selected_detachment == "terminator-storm-force": Combat.DetachmentStratagems.enable_terminator_storm(state)
			if selected_detachment == "tacticus-firestorm-force": Combat.DetachmentStratagems.enable_firestorm(state)
			if selected_detachment == "phobos-shock-force": Combat.DetachmentStratagems.enable_phobos_shock(state)
			if selected_detachment == "phobos-shadow-force": Combat.DetachmentStratagems.enable_phobos_shadow(state)
			if selected_detachment in ["gravis-linebreaker-force", "gravis-siege-force"]: Combat.DetachmentStratagems.enable_gravis(state, selected_detachment)
	if not options.get("unit_abilities", false) and ChapterRules.has_current_reference_marines(state):
		var resolved_chapter_result := ChapterRules.resolve_and_apply(state, marine_detachments, marine_chapter_selections)
		if not str(resolved_chapter_result.get("error", "")).is_empty(): return {"error": str(resolved_chapter_result.error)}
		if not reports.is_empty(): state.saved_army_setup.options.marine_chapters = resolved_chapter_result.selections.duplicate(true)
	for owner in [1, 2]:
		var assigned := str(marine_detachments.get(owner, marine_detachments.get(str(owner), "none")))
		var chapter_error := Combat.Doctrines.chapter_restriction_error(state, assigned, owner)
		if not chapter_error.is_empty(): return {"error": chapter_error}
	if options.get("official_mission", false):
		if secondary_pair == "engage-bring-it-down" and not defer_secondary_target_check and (not Combat.Mission.has_bring_it_down_roster_target(state, 1) or not Combat.Mission.has_bring_it_down_roster_target(state, 2)):
			return {"error": "Bring It Down requires each opposing roster to include at least one model with 10 or more Wounds."}
		if secondary_pair == "engage-grievous-blow" and not defer_secondary_target_check and (not Combat.Mission.has_grievous_blow_roster_target(state, 1) or not Combat.Mission.has_grievous_blow_roster_target(state, 2)):
			return {"error": "A Grievous Blow requires each opposing roster to include at least one unit with a starting strength of 13 or more models."}
		Combat.Mission.enable(state, terrain_layout, primary_mission, secondary_pair, primary_missions, force_dispositions, primary_overrides, bool(sealed_force_disposition_reveal))
		if not reports.is_empty():
			state.saved_army_setup.options.official_mission = true
			state.saved_army_setup.options.terrain_layout = terrain_layout
			state.saved_army_setup.options.primary_mission = primary_mission
			state.saved_army_setup.options.primary_missions = primary_missions.duplicate(true)
			state.saved_army_setup.options.primary_overrides = state.mission.primary_overrides.duplicate(true)
			if not force_dispositions.is_empty(): state.saved_army_setup.options.force_dispositions = force_dispositions.duplicate(true)
			if sealed_force_disposition_reveal: state.saved_army_setup.options.sealed_force_disposition_reveal = true
			state.saved_army_setup.options.secondary_pair = secondary_pair
	if options.get("checked_rosters", false):
		Combat.RosterValidation.enable(state, reports)
		state.saved_army_setup.options.checked_rosters = true
	var manifest_options := {
		"manual_allocation": manual, "varied_equipment": varied, "core_stratagems": core,
		"movement_rerolls": movement_rerolls, "attack_rerolls": attack_rerolls,
		"save_rerolls": save_rerolls, "damage_rerolls": damage_rerolls,
		"hazard_rerolls": hazard_rerolls, "escape_rerolls": escape_rerolls,
		"count_rerolls": count_rerolls, "terrain_layout": terrain_layout
	}
	if options.has("training_scenario_id"):
		if options.training_scenario_id != Training.Tactical.ID or not Training.Tactical.matches(state): return {"error": "The tactical scenario requires its versioned current Marine formations."}
		state.saved_army_setup.options.training_scenario_id = Training.Tactical.ID
	Combat.Doctrines.apply_detachment_roster_keywords(state)
	MatchManifest.seal(state, options, reports, manifest_options, ID)
	Deployment.begin(state)
	Combat.Awakened.begin_setup(state)
	return state

static func waiting(options: Dictionary) -> Dictionary:
	var state := initial_state(options, {}, true, true)
	if state.has("error"): return state
	if options.get("checked_rosters", false): state.erase("saved_army_setup")
	state.phase = "army_selection"
	state.pack_hash = (str(state.pack_hash) + ":saved-army-lobby-v1").sha256_text()
	state.ready_armies = []
	return state

static func from_setup(setup: Variant) -> Dictionary:
	if not setup is Dictionary or setup.size() != 3 or setup.get("schema_version") != 1 or not setup.get("options") is Dictionary or not setup.get("armies") is Dictionary: return {"error": "Invalid public training setup."}
	return initial_state(setup.options, setup.armies)

static func _current_marine_setup(selections: Dictionary) -> bool:
	if selections.size() != 2: return false
	for owner in [1, 2]:
		var selection: Variant = selections.get(owner, selections.get(str(owner), {}))
		if not selection is Dictionary or int(selection.get("schema_version", 0)) != 2 or str(selection.get("faction", "")) != "Space Marines": return false
	return true

static func _materialize_mixed(state: Dictionary, original: Dictionary, report: Dictionary, owner: int) -> void:
	var index := 0
	for entry: Dictionary in report.selection.entries:
		var resolved: Dictionary = report.definitions[entry.definition_id]
		var configuration_key := "%s:%02d:%s" % [entry.definition_id, int(entry.models), str(entry.get("enhancement_id", ""))]
		if entry.has("composition_choice_id"): configuration_key += ":" + str(entry.composition_choice_id)
		resolved = report.get("configurations", {}).get(configuration_key, resolved)
		var spec: Dictionary = resolved.spec
		for copy in range(entry.copies):
			var squad := owner + index * 2
			var group: Dictionary = original.squads[spec.template].duplicate(true)
			group.name = resolved.unit.name + " %d" % (copy + 1)
			group.training_cost = resolved.cost
			group.enhancement_id = str(entry.get("enhancement_id", ""))
			group.owner = owner
			group.faction = report.selection.faction
			group.starting_strength = int(entry.models)
			group.stats = resolved.unit.stats.duplicate(true)
			group.weapon = resolved.weapons.gun.duplicate(true)
			group.melee_weapon = resolved.weapons.blade.duplicate(true)
			group.disabled_abilities = resolved.unsupported_abilities.duplicate()
			state.squads[squad] = group
			var spacing: float = maxf(1.3, float(resolved.unit.base.radius_inches) * 2.0 + 0.1)
			if entry.definition_id == "40kdc:11e:adeptus-astartes:wolf-scouts": spacing = maxf(spacing, 60.0 / 25.4 + 0.1)
			var rows := 3 if int(entry.models) == 5 else 5
			for model in range(entry.models):
				var unit: Dictionary = original.units[int(spec.template) * 100].duplicate(true)
				unit.owner = owner
				unit.squad = squad
				unit.definition_id = entry.definition_id
				unit.enhancement_id = group.enhancement_id if model == 0 else ""
				if spec.get("current_reference", false): unit.sergeant = model == 0 and entry.definition_id not in ["40kdc:11e:adeptus-astartes:company-heroes", "40kdc:11e:adeptus-astartes:victrix-honour-guard", "40kdc:11e:adeptus-astartes:crusader-squad", "40kdc:11e:adeptus-astartes:sword-brethren-squad", "40kdc:11e:adeptus-astartes:fortis-kill-team", "40kdc:11e:adeptus-astartes:spectrus-kill-team", "40kdc:11e:adeptus-astartes:indomitor-kill-team", "40kdc:11e:adeptus-astartes:decimus-kill-team", "40kdc:11e:adeptus-astartes:talonstrike-kill-team", "40kdc:11e:adeptus-astartes:wolf-scouts"]
				if entry.definition_id == "40kdc:11e:adeptus-astartes:company-heroes": unit.company_heroes_model = model
				if entry.definition_id == "40kdc:11e:adeptus-astartes:grey-hunters": unit.grey_hunters_model = model
				if entry.definition_id == "40kdc:11e:adeptus-astartes:spectrus-kill-team": unit.spectrus_kill_team_model = model
				if entry.definition_id == "40kdc:11e:adeptus-astartes:fortis-kill-team":
					unit.fortis_kill_team_model = model
					unit.sergeant = model == 1
				if entry.definition_id == "40kdc:11e:adeptus-astartes:talonstrike-kill-team":
					unit.talonstrike_kill_team_model = model
					unit.sergeant = model == 0
					unit.talonstrike_sergeant_melee = "chainsword"
					unit.talonstrike_sergeant_ranged = "heavy-bolt-pistol"
					unit.talonstrike_intercessor_plasma_pistol = false
					unit.talonstrike_plasma_exterminator = false
				if entry.definition_id == "40kdc:11e:adeptus-astartes:decimus-kill-team":
					var decimus_roles: Array = resolved.get("decimus_roles", [])
					unit.decimus_kill_team_model = model
					unit.decimus_kill_team_role = str(decimus_roles[model]) if model < decimus_roles.size() else ""
					unit.sergeant = unit.decimus_kill_team_role == "sergeant"
				if entry.definition_id == "40kdc:11e:adeptus-astartes:indomitor-kill-team": unit.indomitor_kill_team_model = model
				if entry.definition_id == "40kdc:11e:adeptus-astartes:chaplain-grimaldus": unit.chaplain_grimaldus_model = model
				if entry.definition_id == "40kdc:11e:adeptus-astartes:victrix-honour-guard":
					unit.victrix_honour_guard_model = model
					var role_choices: Array = resolved.get("victrix_roles", [])
					if role_choices.is_empty():
						role_choices = ["chapter-ancient", "chapter-champion"]
						while role_choices.size() < int(entry.models): role_choices.append("victrix-honour-guard")
					if model < role_choices.size(): unit.victrix_honour_guard_role = str(role_choices[model])
				if entry.definition_id == "40kdc:11e:adeptus-astartes:wardens-of-ultramar": unit.wardens_model = model
				if entry.definition_id == "40kdc:11e:adeptus-astartes:crusader-squad": unit.crusader_squad_model = model
				if entry.definition_id == "40kdc:11e:adeptus-astartes:sword-brethren-squad": unit.sword_brethren_model = model
				if entry.definition_id == "40kdc:11e:adeptus-astartes:ravenwing-command-squad": unit.ravenwing_command_squad_model = model
				if entry.definition_id == "40kdc:11e:adeptus-astartes:wolf-scouts": unit.wolf_scouts_model = model
				if entry.definition_id == "40kdc:11e:adeptus-astartes:wolf-guard-headtakers":
					var headtaker_roles: Array = resolved.get("wolf_guard_headtaker_roles", [])
					unit.wolf_guard_headtaker_model = model
					unit.wolf_guard_headtaker_role = str(headtaker_roles[model]) if model < headtaker_roles.size() else ""
					unit.wolf_guard_headtaker_storm_shield = false
				unit.keywords = resolved.unit.keywords.duplicate()
				unit.movement = group.stats.movement_inches
				unit.wounds = int(group.stats.wounds)
				unit.max_wounds = int(group.stats.wounds)
				unit.radius = float(resolved.unit.base.radius_inches)
				unit.position = Vector2((-12.0 - floori(float(model) / rows) * spacing) if owner == 1 else (12.0 + floori(float(model) / rows) * spacing), (model % rows - (rows - 1) / 2.0) * spacing + (index - (report.unit_count - 1) / 2.0) * 7.0)
				if model == 0 and resolved.weapons.has("sergeant"):
					unit.melee_weapons = [{"id": "sergeant-power-weapon", "profiles": {"standard": resolved.weapons.sergeant.duplicate(true)}}]
				state.units[squad * 100 + model] = unit
			index += 1

static func _current_loadouts(state: Dictionary) -> String:
	var cache: Dictionary = {}
	var marine_profiles_used := false
	for model: int in state.units:
		var unit: Dictionary = state.units[model]
		var source := Combat.UnitAbilities.identity(unit)
		if source not in Combat.UnitAbilities.RULES: return "Unsupported current unit profile: " + source
		if str(unit.get("definition_id", "")).begins_with("40kdc:11e:adeptus-astartes:"):
			var marine_profile := CurrentMarineProfiles.profile(source)
			if marine_profile.is_empty(): return "No current-reference fixed loadout is recorded for " + source
			var squad: int = unit.squad
			state.squads[squad].stats = marine_profile.stats.duplicate(true)
			if marine_profile.has("points"): state.squads[squad].training_cost = int(marine_profile.get("points_by_models", {}).get(state.squads[squad].starting_strength, marine_profile.points))
			if not marine_profile.ranged.is_empty():
				var ranged_profiles: Dictionary = marine_profile.ranged[0].profiles
				state.squads[squad].weapon = ranged_profiles.values()[0].duplicate(true)
			else:
				state.squads[squad].weapon = {}
			if not marine_profile.melee.is_empty():
				var melee_profiles: Dictionary = marine_profile.melee[0].profiles
				state.squads[squad].melee_weapon = melee_profiles.values()[0].duplicate(true)
			else:
				state.squads[squad].melee_weapon = {}
			unit.keywords = marine_profile.keywords.duplicate()
			unit.movement = int(marine_profile.stats.movement_inches)
			unit.wounds = int(marine_profile.stats.wounds)
			unit.max_wounds = int(marine_profile.stats.wounds)
			if marine_profile.has("base_radius_inches"): unit.radius = float(marine_profile.base_radius_inches)
			unit.ranged_weapons = marine_profile.ranged.duplicate(true)
			unit.melee_weapons = marine_profile.melee.duplicate(true)
			if source in ["death-company-marines", "death-company-marines-with-jump-packs"]:
				unit.death_company_melee_package = "chainsword"
				unit.death_company_pistol_package = "heavy-bolt-pistol"
				unit.death_company_grenade_launcher = false
				var death_company_loadout := CurrentMarineProfiles.death_company_model_weapons(source)
				if death_company_loadout.is_empty(): return "No source-listed default loadout is recorded for " + source
				unit.ranged_weapons = death_company_loadout.ranged
				unit.melee_weapons = death_company_loadout.melee
			if marine_profile.has("transport"):
				unit.transport_profile = marine_profile.transport.duplicate(true)
			if marine_profile.has("core_abilities"):
				unit.core_abilities = marine_profile.core_abilities.duplicate(true)
			if source == "sternguard-veteran-squad" and unit.get("sergeant", false): unit.melee_weapons = [CurrentMarineProfiles.sternguard_melee("chain")]
			if source == "scout-squad":
				unit.scout_gun = "boltgun"
				unit.scout_blade = "combat-knife"
			if source == "intercessor-squad":
				unit.intercessor_melee_choice = "knives-and-fists"
				unit.intercessor_rifle_choice = "bolt-rifle"
				unit.intercessor_grenade_launcher = false
			if source == "deathwatch-veterans":
				unit.deathwatch_veteran_loadout = "default"
				unit.deathwatch_sergeant_ranged_loadout = "boltgun"
				unit.deathwatch_sergeant_melee_loadout = "power-weapon"
				unit.deathwatch_veteran_storm_shield = false
				var deathwatch_weapons := CurrentMarineProfiles.deathwatch_veteran_weapons(bool(unit.get("sergeant", false)))
				if deathwatch_weapons.is_empty(): return "Deathwatch Veterans requires its verified source-listed default loadout."
				unit.ranged_weapons = deathwatch_weapons.ranged
				unit.melee_weapons = deathwatch_weapons.melee
			if source == "blood-claws" and unit.get("sergeant", false):
				unit.blood_claws_pack_leader_pistol = "bolt-pistol"
				unit.blood_claws_pack_leader_melee = "chainsword"
				var blood_claws_weapons := CurrentMarineProfiles.blood_claws_pack_leader_weapons()
				if blood_claws_weapons.is_empty(): return "Blood Claws requires its source-listed Pack Leader default equipment."
				unit.ranged_weapons = blood_claws_weapons.ranged
				unit.melee_weapons = blood_claws_weapons.melee
			if source == "grey-hunters" and unit.get("sergeant", false):
				unit.grey_hunters_pack_leader_pistol = "bolt-pistol"
				unit.grey_hunters_pack_leader_melee = "chainsword"
				var grey_hunters_weapons := CurrentMarineProfiles.grey_hunters_pack_leader_weapons()
				if grey_hunters_weapons.is_empty(): return "Grey Hunters requires its source-listed Pack Leader default equipment."
				unit.ranged_weapons = grey_hunters_weapons.ranged
				unit.melee_weapons = grey_hunters_weapons.melee
			if source == "deathwatch-terminator-squad":
				unit.deathwatch_terminator_melee_package = "power-fist"
				unit.deathwatch_terminator_storm_shield = false
				unit.terminator_special_weapon = ""
			if source == "wolf-guard-terminators":
				unit.wolf_guard_terminator_loadout = "default"
				unit.wolf_guard_terminator_storm_shield = false
				var wolf_guard_weapons := CurrentMarineProfiles.wolf_guard_terminator_weapons()
				if wolf_guard_weapons.is_empty(): return "Wolf Guard Terminators requires its source-listed default equipment."
				unit.ranged_weapons = wolf_guard_weapons.ranged
				unit.melee_weapons = wolf_guard_weapons.melee
			if source == "thunderwolf-cavalry":
				unit.thunderwolf_cavalry_loadout = "default"
				unit.thunderwolf_cavalry_storm_shield = false
				var thunderwolf_weapons := CurrentMarineProfiles.thunderwolf_cavalry_weapons()
				if thunderwolf_weapons.is_empty(): return "Thunderwolf Cavalry requires its source-listed default equipment."
				unit.ranged_weapons = thunderwolf_weapons.ranged
				unit.melee_weapons = thunderwolf_weapons.melee
			if source in ["wulfen", "wulfen-with-storm-shields"]:
				var wulfen_loadout := "death-totem" if source == "wulfen" else "stormfrag-auto-launcher"
				unit.wulfen_loadout = wulfen_loadout
				unit.wulfen_death_totem = source == "wulfen"
				var wulfen_weapons := CurrentMarineProfiles.wulfen_weapons(wulfen_loadout) if source == "wulfen" else CurrentMarineProfiles.wulfen_storm_shields_weapons(wulfen_loadout)
				if wulfen_weapons.is_empty(): return "%s requires its source-listed default equipment." % marine_profile.name
				unit.ranged_weapons = wulfen_weapons.ranged
				unit.melee_weapons = wulfen_weapons.melee
			if source == "wolf-scouts":
				unit.wolf_scouts_loadout = "default"
				unit.wolf_scouts_haywire_mine = false
				var wolf_scout_model := int(unit.get("wolf_scouts_model", -1))
				var wolf_scout_count := int(state.squads[squad].get("starting_strength", 0))
				var wolf_scout_loadout := CurrentMarineProfiles.wolf_scouts_model_loadout(wolf_scout_model, wolf_scout_count)
				if wolf_scout_loadout.is_empty(): return "Wolf Scouts requires a source-priced 6- or 12-model mixed composition."
				unit.wolf_scouts_role = str(wolf_scout_loadout.role)
				var wolf_scout_stats: Dictionary = wolf_scout_loadout.stats
				unit.ranged_weapons = wolf_scout_loadout.ranged.duplicate(true)
				unit.melee_weapons = wolf_scout_loadout.melee.duplicate(true)
				unit.movement = int(wolf_scout_stats.movement_inches)
				unit.max_wounds = int(wolf_scout_stats.wounds)
				unit.wounds = unit.max_wounds
				unit.objective_control = int(wolf_scout_stats.objective_control)
				unit.leadership_target = int(wolf_scout_stats.leadership_target)
				unit.defense = {"toughness": wolf_scout_stats.toughness, "save_target": wolf_scout_stats.save_target, "invulnerable_target": wolf_scout_stats.invulnerable_target}
				unit.radius = float(wolf_scout_loadout.base_radius_inches)
			if source == "wolf-guard-headtakers":
				var headtaker_role := str(unit.get("wolf_guard_headtaker_role", ""))
				var headtaker_loadout := CurrentMarineProfiles.wolf_guard_headtaker_model_loadout(headtaker_role)
				if headtaker_loadout.is_empty(): return "Wolf Guard Headtakers requires the source-priced 3+3 or 6+6 model composition."
				unit.ranged_weapons = headtaker_loadout.ranged.duplicate(true)
				unit.melee_weapons = headtaker_loadout.melee.duplicate(true)
				unit.movement = int(headtaker_loadout.stats.movement_inches)
				unit.max_wounds = int(headtaker_loadout.stats.wounds)
				unit.wounds = unit.max_wounds
				unit.objective_control = int(headtaker_loadout.stats.objective_control)
				unit.leadership_target = int(headtaker_loadout.stats.leadership_target)
				unit.defense = {"toughness": headtaker_loadout.stats.toughness, "save_target": headtaker_loadout.stats.save_target, "invulnerable_target": headtaker_loadout.stats.invulnerable_target}
				unit.radius = float(headtaker_loadout.base_radius_inches)
			if source == "fortis-kill-team":
				unit.fortis_kill_team_sergeant_melee = "knives-and-fists"
				unit.fortis_kill_team_sergeant_ranged = "deathwatch-bolt-rifle"
				unit.fortis_kill_team_grenade_launcher = false
				unit.fortis_kill_team_plasma_pistol = false
				unit.fortis_kill_team_rocket_launcher = "superfrag"
			if source == "spectrus-kill-team":
				unit.spectrus_sniper_weapon = "bolt-sniper-rifle"
				unit.spectrus_knife_replaced = false
				unit.spectrus_helix_gauntlet = false
			if source == "decimus-kill-team":
				unit.decimus_gravis_weapon = "infernus-heavy-bolter"
				unit.decimus_storm_shield = false
				unit.decimus_plasma_incinerator = false
			if source == "indomitor-kill-team":
				unit.indomitor_auto_boltstorm = false
				unit.indomitor_heavy_bolter = false
				unit.indomitor_multi_melta = false
			if source in ["terminator-squad", "deathwing-terminator-squad"]:
				unit.terminator_melee_choice = "power-fist"
				unit.terminator_special_weapon = ""
				if source == "deathwing-terminator-squad": state.squads[squad].deathwing_terminator_watcher_equipped = false
			if source == "terminator-assault-squad":
				unit.terminator_assault_storm_shield = false
				unit.melee_weapons = [marine_profile.melee[0].duplicate(true)]
			if source == "deathwing-knights":
				var melee_choice := "great-weapon-of-the-unforgiven" if unit.get("sergeant", false) else "mace-of-absolution"
				var melee_weapon := CurrentMarineProfiles.deathwing_knight_melee_weapon(melee_choice)
				if melee_weapon.is_empty(): return "Deathwing Knights requires a source-listed melee profile for every model role."
				unit.deathwing_knight_melee = melee_choice
				unit.ranged_weapons = []
				unit.melee_weapons = [melee_weapon]
				state.squads[squad].deathwing_knights_watcher_equipped = false
			if source == "captain-on-bike":
				unit.captain_bike_plasma_pistol = false
				unit.captain_bike_thunder_hammer = false
				var bike_weapons := CurrentMarineProfiles.captain_bike_weapons()
				unit.ranged_weapons = bike_weapons.ranged
				unit.melee_weapons = bike_weapons.melee
			if source == "captain":
				unit.captain_ranged_loadout = "default"
				unit.captain_power_fist = false
				unit.relic_shield = false
				unit.max_wounds = 5
				var captain_weapons := CurrentMarineProfiles.captain_weapons()
				unit.ranged_weapons = captain_weapons.ranged
				unit.melee_weapons = captain_weapons.melee
			if source == "blood-angels-captain":
				unit.blood_angels_captain_pistol_package = "heavy-bolt-pistol"
				unit.blood_angels_captain_melee_package = "master-crafted-chainsword"
				var blood_angels_weapons := CurrentMarineProfiles.blood_angels_captain_weapons()
				unit.ranged_weapons = blood_angels_weapons.ranged
				unit.melee_weapons = blood_angels_weapons.melee
			if source == "lieutenant":
				unit.lieutenant_weapon_package = "default"
				unit.lieutenant_fists_replacement = "ceramite-fists"
				unit.lieutenant_storm_shield = false
				unit.erase("defense")
				var lieutenant_weapons := CurrentMarineProfiles.lieutenant_weapons()
				unit.ranged_weapons = lieutenant_weapons.ranged
				unit.melee_weapons = lieutenant_weapons.melee
			if source == "invader-atvs":
				unit.invader_atv_multi_melta = false
				unit.ranged_weapons = CurrentMarineProfiles.invader_atv_weapons()
			if source == "company-heroes":
				var model_index := int(unit.get("company_heroes_model", -1))
				var heroes_loadouts: Array = marine_profile.get("model_loadouts", [])
				if model_index < 0 or model_index >= heroes_loadouts.size(): return "Company Heroes requires one of its four source-defined model roles."
				var heroes_loadout: Dictionary = heroes_loadouts[model_index]
				unit.ranged_weapons = heroes_loadout.ranged
				unit.melee_weapons = heroes_loadout.melee
				unit.keywords = heroes_loadout.keywords
			if source == "talonstrike-kill-team":
				var talonstrike_index := int(unit.get("talonstrike_kill_team_model", -1))
				var talonstrike_loadout := CurrentMarineProfiles.talonstrike_kill_team_model_loadout(
					talonstrike_index,
					str(unit.get("talonstrike_sergeant_melee", "chainsword")),
					str(unit.get("talonstrike_sergeant_ranged", "heavy-bolt-pistol")),
					bool(unit.get("talonstrike_intercessor_plasma_pistol", false)),
					bool(unit.get("talonstrike_plasma_exterminator", false)))
				if talonstrike_loadout.is_empty(): return "Talonstrike Kill Team requires its source-defined Sergeant, Heavy Intercessors and Intercessors."
				var talonstrike_stats: Dictionary = talonstrike_loadout.stats
				unit.ranged_weapons = talonstrike_loadout.ranged
				unit.melee_weapons = talonstrike_loadout.melee
				unit.keywords = talonstrike_loadout.keywords
				unit.movement = int(talonstrike_stats.movement_inches)
				unit.max_wounds = int(talonstrike_stats.wounds)
				unit.wounds = unit.max_wounds
				unit.radius = float(talonstrike_loadout.base_radius_inches)
				unit.leadership_target = int(talonstrike_stats.leadership_target)
				unit.objective_control = int(talonstrike_stats.objective_control)
				unit.defense = {"toughness": talonstrike_stats.toughness, "save_target": talonstrike_stats.save_target, "invulnerable_target": talonstrike_stats.invulnerable_target}
			if source == "fortis-kill-team":
				var fortis_index := int(unit.get("fortis_kill_team_model", -1))
				var fortis_loadout := CurrentMarineProfiles.fortis_kill_team_model_loadout(fortis_index)
				if fortis_loadout.is_empty(): return "Fortis Kill Team requires its ten source-defined model roles and default wargear."
				unit.ranged_weapons = fortis_loadout.ranged
				unit.melee_weapons = fortis_loadout.melee
				unit.keywords = fortis_loadout.keywords
			if source == "decimus-kill-team":
				var decimus_role := str(unit.get("decimus_kill_team_role", ""))
				var decimus_loadout := CurrentMarineProfiles.decimus_kill_team_model_loadout(decimus_role, str(unit.get("decimus_gravis_weapon", "infernus-heavy-bolter")), bool(unit.get("decimus_storm_shield", false)), bool(unit.get("decimus_plasma_incinerator", false)))
				if decimus_loadout.is_empty(): return "Decimus Kill Team requires a supported source-defined role and loadout."
				var decimus_stats: Dictionary = decimus_loadout.stats
				unit.ranged_weapons = decimus_loadout.ranged
				unit.melee_weapons = decimus_loadout.melee
				unit.keywords = decimus_loadout.keywords
				unit.movement = int(decimus_stats.movement_inches)
				unit.max_wounds = int(decimus_stats.wounds)
				unit.wounds = unit.max_wounds
				unit.radius = float(decimus_loadout.base_radius_inches)
				unit.leadership_target = int(decimus_stats.leadership_target)
				unit.objective_control = int(decimus_stats.objective_control)
				unit.defense = {"toughness": decimus_stats.toughness, "save_target": decimus_stats.save_target, "invulnerable_target": 4 if decimus_loadout.storm_shield else decimus_stats.invulnerable_target}
			if source == "indomitor-kill-team":
				var indomitor_index := int(unit.get("indomitor_kill_team_model", -1))
				var indomitor_loadout := CurrentMarineProfiles.indomitor_kill_team_model_loadout(indomitor_index)
				if indomitor_loadout.is_empty(): return "Indomitor Kill Team requires its ten source-defined Heavy Intercessor models."
				var indomitor_stats: Dictionary = indomitor_loadout.stats
				unit.ranged_weapons = indomitor_loadout.ranged
				unit.melee_weapons = indomitor_loadout.melee
				unit.keywords = indomitor_loadout.keywords
				unit.movement = int(indomitor_stats.movement_inches)
				unit.max_wounds = int(indomitor_stats.wounds)
				unit.wounds = unit.max_wounds
				unit.radius = float(indomitor_loadout.base_radius_inches)
				unit.leadership_target = int(indomitor_stats.leadership_target)
				unit.objective_control = int(indomitor_stats.objective_control)
				unit.defense = {"toughness": indomitor_stats.toughness, "save_target": indomitor_stats.save_target, "invulnerable_target": indomitor_stats.invulnerable_target}
			if source == "spectrus-kill-team":
				var spectrus_index := int(unit.get("spectrus_kill_team_model", -1))
				var spectrus_loadout := CurrentMarineProfiles.spectrus_kill_team_model_loadout(spectrus_index, str(unit.get("spectrus_sniper_weapon", "bolt-sniper-rifle")), bool(unit.get("spectrus_knife_replaced", false)), bool(unit.get("spectrus_helix_gauntlet", false)))
				if spectrus_loadout.is_empty(): return "Spectrus Kill Team requires its ten source-defined Infiltrator roles and supported equipment."
				unit.ranged_weapons = spectrus_loadout.ranged
				unit.melee_weapons = spectrus_loadout.melee
				unit.keywords = spectrus_loadout.keywords
				unit.movement = int(spectrus_loadout.stats.movement_inches)
				unit.max_wounds = int(spectrus_loadout.stats.wounds)
				unit.wounds = unit.max_wounds
				unit.radius = float(spectrus_loadout.base_radius_inches)
				unit.leadership_target = int(spectrus_loadout.stats.leadership_target)
				unit.objective_control = int(spectrus_loadout.stats.objective_control)
				unit.defense = {"toughness": spectrus_loadout.stats.toughness, "save_target": spectrus_loadout.stats.save_target, "invulnerable_target": spectrus_loadout.stats.invulnerable_target}
				unit.helix_gauntlet = bool(spectrus_loadout.helix_gauntlet)
			if source == "chaplain-grimaldus":
				var grimaldus_index := int(unit.get("chaplain_grimaldus_model", -1))
				var grimaldus_loadouts: Array = marine_profile.get("model_loadouts", [])
				if grimaldus_index < 0 or grimaldus_index >= grimaldus_loadouts.size(): return "Chaplain Grimaldus requires one Chaplain and three source-defined Cenobyte Servitors."
				var grimaldus_loadout: Dictionary = grimaldus_loadouts[grimaldus_index]
				var grimaldus_stats: Dictionary = grimaldus_loadout.stats
				unit.chaplain_grimaldus_role = "chaplain" if grimaldus_index == 0 else "cenobyte"
				unit.keywords = grimaldus_loadout.keywords.duplicate()
				unit.ranged_weapons = grimaldus_loadout.ranged.duplicate(true)
				unit.melee_weapons = grimaldus_loadout.melee.duplicate(true)
				unit.radius = float(grimaldus_loadout.base_radius_inches)
				unit.movement = int(grimaldus_stats.movement_inches)
				unit.max_wounds = int(grimaldus_stats.wounds)
				unit.wounds = unit.max_wounds
				unit.leadership_target = int(grimaldus_stats.leadership_target)
				unit.objective_control = int(grimaldus_stats.objective_control)
				unit.defense = {"toughness": grimaldus_stats.toughness, "save_target": grimaldus_stats.save_target, "invulnerable_target": grimaldus_stats.invulnerable_target}
			if source == "victrix-honour-guard":
				var role := str(unit.get("victrix_honour_guard_role", ""))
				var guard_loadouts: Array = marine_profile.get("model_loadouts", [])
				var loadout_index: int = int({"chapter-ancient": 0, "chapter-champion": 1, "victrix-honour-guard": 2}.get(role, -1))
				if loadout_index < 0 or loadout_index >= guard_loadouts.size(): return "Victrix Honour Guard requires a supported source-defined model role."
				var guard_loadout: Dictionary = guard_loadouts[loadout_index]
				unit.ranged_weapons = guard_loadout.ranged
				unit.melee_weapons = guard_loadout.melee
				unit.keywords = guard_loadout.keywords
				unit.victrix_honour_guard_role = guard_loadout.role
			if source == "wardens-of-ultramar":
				var model_index := int(unit.get("wardens_model", -1))
				var wardens_loadouts: Array = marine_profile.get("model_loadouts", [])
				if model_index < 0 or model_index >= wardens_loadouts.size(): return "Wardens of Ultramar requires all six source-defined models."
				var wardens_loadout: Dictionary = wardens_loadouts[model_index]
				var wardens_stats: Dictionary = wardens_loadout.stats
				unit.ranged_weapons = wardens_loadout.ranged.duplicate(true)
				unit.melee_weapons = wardens_loadout.melee.duplicate(true)
				unit.radius = float(wardens_loadout.base_radius_inches)
				for keyword: String in wardens_loadout.get("keywords", []):
					if keyword not in unit.keywords: unit.keywords.append(keyword)
				unit.max_wounds = int(wardens_stats.wounds)
				unit.wounds = unit.max_wounds
				unit.objective_control = int(wardens_stats.objective_control)
				unit.leadership_target = int(wardens_stats.leadership_target)
				unit.defense = {"toughness": wardens_stats.toughness, "save_target": wardens_stats.save_target, "invulnerable_target": wardens_stats.invulnerable_target}
			if source == "crusader-squad":
				var crusader_model := int(unit.get("crusader_squad_model", -1))
				var crusader_loadout := CurrentMarineProfiles.crusader_squad_model_loadout(crusader_model, int(state.squads[squad].starting_strength))
				if crusader_loadout.is_empty(): return "Crusader Squad requires its source-defined 10- or 20-model Sword Brother, Neophyte and Initiate composition."
				var crusader_stats: Dictionary = crusader_loadout.stats
				unit.crusader_squad_role = crusader_loadout.role
				unit.crusader_squad_loadout = "default"
				unit.ranged_weapons = crusader_loadout.ranged.duplicate(true)
				unit.melee_weapons = crusader_loadout.melee.duplicate(true)
				unit.defense = {"toughness": crusader_stats.toughness, "save_target": crusader_stats.save_target, "invulnerable_target": crusader_stats.invulnerable_target}
			if source == "sword-brethren-squad":
				var sword_brethren_model := int(unit.get("sword_brethren_model", -1))
				var sword_brethren_loadout := CurrentMarineProfiles.sword_brethren_model_loadout(sword_brethren_model, int(state.squads[squad].starting_strength))
				if sword_brethren_loadout.is_empty(): return "Sword Brethren Squad requires a source-priced 4-, 5-, 9- or 10-model size."
				unit.sword_brethren_loadout = "default"
				unit.ranged_weapons = sword_brethren_loadout.ranged.duplicate(true)
				unit.melee_weapons = sword_brethren_loadout.melee.duplicate(true)
			if source == "execrator":
				unit.execrator_pistol_package = "absolvor-bolt-pistol"
				unit.execrator_mastercrafted_power_weapon = false
				var execrator_weapons := CurrentMarineProfiles.execrator_weapons()
				if execrator_weapons.is_empty(): return "Execrator requires a source-listed default weapon package."
				unit.ranged_weapons = execrator_weapons.ranged
				unit.melee_weapons = execrator_weapons.melee
			if source == "outrider-squad":
				unit.outrider_plasma_pistol = false
				unit.outrider_melee_choice = "chainsword"
				var outrider_weapons := CurrentMarineProfiles.outrider_weapons(false, "chainsword")
				unit.ranged_weapons = outrider_weapons.ranged
				unit.melee_weapons = outrider_weapons.melee
			if source == "ravenwing-black-knights":
				unit.black_knight_grenade_launcher = false
				var black_knight_weapons := CurrentMarineProfiles.ravenwing_black_knight_weapons()
				unit.ranged_weapons = black_knight_weapons.ranged
				unit.melee_weapons = black_knight_weapons.melee
			if source == "ravenwing-command-squad":
				var role_index := int(unit.get("ravenwing_command_squad_model", -1))
				var command_loadouts: Array = marine_profile.get("model_loadouts", [])
				if role_index < 0 or role_index >= command_loadouts.size(): return "Ravenwing Command Squad requires its three source-defined Ancient, Apothecary and Champion roles."
				var command_loadout: Dictionary = command_loadouts[role_index]
				unit.ravenwing_command_role = str(command_loadout.get("role", ""))
				unit.ravenwing_command_grenade_launcher = false
				unit.ranged_weapons = command_loadout.ranged.duplicate(true)
				unit.melee_weapons = command_loadout.melee.duplicate(true)
			if source == "ravenwing-darkshroud": unit.ravenwing_darkshroud_assault_cannon = false
			if source == "heavy-intercessor-squad":
				unit.heavy_intercessor_heavy_bolter = false
			if source == "brutalis-dreadnought":
				unit.brutalis_talons = false
				unit.brutalis_multi_melta = false
				var brutalis_weapons := CurrentMarineProfiles.brutalis_weapons()
				unit.ranged_weapons = brutalis_weapons.ranged
				unit.melee_weapons = brutalis_weapons.melee
			if source == "death-company-dreadnought":
				unit.death_company_twin_multi_melta = false
				unit.death_company_blood_talons = false
				var death_company_weapons := CurrentMarineProfiles.death_company_dreadnought_weapons()
				if death_company_weapons.is_empty(): return "Death Company Dreadnought requires its source-listed default weapon package."
				unit.ranged_weapons = death_company_weapons.ranged
				unit.melee_weapons = death_company_weapons.melee
			if source == "invictor-tactical-warsuit":
				unit.invictor_autocannon = false
				unit.ranged_weapons = CurrentMarineProfiles.invictor_weapons()
			if source == "desolation-squad":
				unit.desolation_rocket = "superfrag"
				unit.ranged_weapons = CurrentMarineProfiles.desolation_weapons()
			if source == "vanguard-veteran-squad-with-jump-packs":
				unit.vanguard_pistol = "heavy-bolt-pistol"
				unit.vanguard_melee = "default"
				unit.combat_shield = false
				var weapons := CurrentMarineProfiles.vanguard_veteran_weapons(unit.get("sergeant", false))
				unit.ranged_weapons = weapons.ranged
				unit.melee_weapons = weapons.melee
				if unit.get("sergeant", false): unit.vanguard_melee = "relic-blade"
			marine_profiles_used = true
			continue
		if not cache.has(source):
			var faction := "Necrons" if str(unit.definition_id).contains(":necrons:") else "Space Marines"
			cache[source] = Training.Capabilities.resolve(faction, unit.definition_id)
			if not cache[source].error.is_empty(): return cache[source].error
		var resolved: Dictionary = cache[source]
		var profiles := {"standard": resolved.weapons.gun.duplicate(true)}
		if source == "intercessor-squad":
			for weapon: Dictionary in resolved.unit.source_weapon_definitions:
				if weapon.id != resolved.spec.gun[0]: continue
				profiles = {}
				for profile: Dictionary in weapon.profiles:
					profiles[profile.name.to_snake_case()] = Training.Capabilities.weapon(resolved.unit, [weapon.id, profile.name])
		unit.ranged_weapons = [{"id": "primary", "profiles": profiles}]
		var secondary: Array = []
		match source:
			"captain": secondary = ["heavy-bolt-pistol-captain", "Heavy Bolt Pistol"]
			"lieutenant": secondary = ["bolt-pistol-lieutenant", "Bolt Pistol"]
			"heavy-intercessor-squad": secondary = ["bolt-pistol-heavy-intercessor-squad", "Bolt Pistol"]
			"intercessor-squad": secondary = ["bolt-pistol-intercessor-squad", "Bolt Pistol"]
		if not secondary.is_empty():
			var pistol := Training.Capabilities.weapon(resolved.unit, secondary)
			if pistol.is_empty(): return "Missing default pistol for " + source
			if source == "lieutenant": pistol.strength = 5
			unit.ranged_weapons.append({"id": "pistol", "profiles": {"standard": pistol}})
		unit.melee_weapons = [{"id": "melee", "profiles": {"standard": resolved.weapons.blade.duplicate(true)}}]
	if marine_profiles_used:
		state.pack_hash = str(state.get("pack_hash", "")) + ":" + CurrentMarineProfiles.ID + ":" + CurrentMarineProfiles.digest()
	return ""
