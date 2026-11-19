extends SceneTree

const Profiles = preload("res://scripts/edition_11/current_reference_necron_profiles.gd")
const Army = preload("res://scripts/edition_11/army_capabilities.gd")
const AbilityCatalog = preload("res://scripts/edition_11/unit_ability_catalog.gd")
const SupportLinks = preload("res://scripts/edition_11/support_attachments.gd")
const LeaderCatalog = preload("res://scripts/edition_11/leader_catalog.gd")
const AttackPlan = preload("res://scripts/edition_11/attack_plan.gd")
const Reanimation = preload("res://scripts/edition_11/reanimation_protocols.gd")
const UnitAbilities = preload("res://scripts/edition_11/unit_abilities.gd")
const UnitActions = preload("res://scripts/edition_11/unit_actions.gd")
const UnitPrevention = preload("res://scripts/edition_11/unit_prevention.gd")
const DefenderGroups = preload("res://scripts/edition_11/defender_groups.gd")
const Detection = preload("res://scripts/edition_11/detection_rules.gd")
const TacticalFluidity = preload("res://scripts/edition_11/tactical_fluidity.gd")
const CoreReactions = preload("res://scripts/edition_11/core_reactions.gd")
const Morale = preload("res://scripts/edition_11/morale.gd")
const Actions = preload("res://scripts/edition_11/actions.gd")

const ORIKAN_ID := "40kdc:11e:necrons:orikan-the-diviner"
const PLASMANCER_ID := "40kdc:11e:necrons:plasmancer"
const TECHNOMANCER_ID := "40kdc:11e:necrons:technomancer"
const PSYCHOMANCER_ID := "40kdc:11e:necrons:psychomancer"
const CHRONOMANCER_ID := "40kdc:11e:necrons:chronomancer"
const WARRIORS_ID := "40kdc:11e:necrons:necron-warriors"
const IMMORTALS_ID := "40kdc:11e:necrons:immortals"
const WRAITHS_ID := "40kdc:11e:necrons:canoptek-wraiths"
const INTERCESSOR_ID := "40kdc:11e:adeptus-astartes:intercessor-squad"

var failures := 0

func mock_roller(rolls: Array) -> Callable:
	var queue := rolls.duplicate()
	return func(_sides: int = 6) -> int:
		return int(queue.pop_front()) if not queue.is_empty() else 1

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	test_datasheet_facts_and_admission()
	test_support_links_and_reanimation()
	test_plasmancer_rules()
	test_technomancer_rules()
	test_psychomancer_rules()
	test_chronomancer_rules()
	test_orikan_rules()
	print("Necron Crypteks checks: %d failures" % failures)
	await process_frame
	quit(1 if failures else 0)

func test_datasheet_facts_and_admission() -> void:
	# 1. Orikan the Diviner (000000530)
	var orikan := Profiles.profile("orikan-the-diviner")
	check(orikan.get("source_datasheet_id") == "000000530", "Orikan datasheet ID is 000000530")
	check(orikan.get("points_by_models") == {1: 90}, "Orikan points are 90 for 1 model")
	check(orikan.get("base_size_source_mm") == 40, "Orikan base is 40 mm")
	check(orikan.get("stats") == {
		"movement_inches": 5, "toughness": 4, "save_target": 4, "wounds": 4,
		"leadership_target": 6, "objective_control": 1, "invulnerable_target": 4
	}, "Orikan stats match source (4W, 4++ invuln)")
	check(orikan.get("keywords") == ["NECRONS", "INFANTRY", "CHARACTER", "EPIC HERO", "CRYPTEK", "CHRONOMANCER", "ORIKAN THE DIVINER"], "Orikan keywords match source")
	var staff: Dictionary = orikan.get("melee", [{}])[0].get("profiles", {}).get("standard", {})
	check(staff == {
		"name": "Staff of Tomorrow", "range_inches": 0.0, "attacks": 2, "skill": 3,
		"strength": 4, "ap": -3, "damage": "D3", "keywords": {"devastating-wounds": true}
	}, "Orikan melee weapon is Staff of Tomorrow")
	check(orikan.get("supported_rule_ids") == ["support", "reanimation-protocols", "master-chronomancer", "the-stars-are-right"], "Orikan supported rules match local scope")
	check(orikan.get("unsupported_abilities", []).is_empty() and orikan.get("pending_source_checks", []).is_empty()
		and orikan.get("source_profile_readiness") == "source_bounded_local_scope_passed_2026_11_12", "Orikan profile readiness is complete")
	var orikan_admit := Army.admit({"schema_version": 2, "faction": "Necrons", "category": "custom", "points_limit": 1000, "entries": [{"definition_id": ORIKAN_ID, "models": 1, "copies": 1}]})
	check(str(orikan_admit.get("error", "")).is_empty() and int(orikan_admit.get("total", -1)) == 90, "Orikan is admitted to construction at 90 points")
	var orikan_dup := Army.admit({"schema_version": 2, "faction": "Necrons", "category": "custom", "points_limit": 1000, "entries": [{"definition_id": ORIKAN_ID, "models": 1, "copies": 2}]})
	check(not str(orikan_dup.get("error", "")).is_empty(), "Orikan Epic Hero duplicate is rejected by admission")

	# 2. Plasmancer (000002108)
	var plasmancer := Profiles.profile("plasmancer")
	check(plasmancer.get("source_datasheet_id") == "000002108", "Plasmancer datasheet ID is 000002108")
	check(plasmancer.get("points_by_models") == {1: 60}, "Plasmancer points are 60 for 1 model")
	check(plasmancer.get("base_size_source_mm") == 32, "Plasmancer base is 32 mm")
	check(plasmancer.get("stats") == {
		"movement_inches": 5, "toughness": 4, "save_target": 4, "wounds": 4,
		"leadership_target": 6, "objective_control": 1, "invulnerable_target": 0
	}, "Plasmancer stats match source (4W, Sv 4+)")
	check(plasmancer.get("keywords") == ["NECRONS", "INFANTRY", "CHARACTER", "CRYPTEK", "PLASMANCER"], "Plasmancer keywords match source")
	var plasmic_ranged: Dictionary = plasmancer.get("ranged", [{}])[0].get("profiles", {}).get("standard", {})
	var plasmic_melee: Dictionary = plasmancer.get("melee", [{}])[0].get("profiles", {}).get("standard", {})
	check(plasmic_ranged == {
		"name": "Plasmic lance", "range_inches": 18.0, "attacks": 3, "skill": 4,
		"strength": 7, "ap": -3, "damage": 2, "keywords": {}
	}, "Plasmancer ranged weapon is Plasmic lance")
	check(plasmic_melee == {
		"name": "Plasmic lance", "range_inches": 0.0, "attacks": 2, "skill": 4,
		"strength": 7, "ap": -3, "damage": 2, "keywords": {}
	}, "Plasmancer melee weapon is Plasmic lance")
	check(plasmancer.get("supported_rule_ids") == ["support", "reanimation-protocols", "harbinger-of-destruction", "living-lightning"], "Plasmancer supported rules match local scope")
	check(plasmancer.get("unsupported_abilities", []).is_empty() and plasmancer.get("pending_source_checks", []).is_empty()
		and plasmancer.get("source_profile_readiness") == "source_bounded_local_scope_passed_2026_11_12", "Plasmancer profile readiness is complete")
	var plasmancer_admit := Army.admit({"schema_version": 2, "faction": "Necrons", "category": "custom", "points_limit": 1000, "entries": [{"definition_id": PLASMANCER_ID, "models": 1, "copies": 1}]})
	check(str(plasmancer_admit.get("error", "")).is_empty() and int(plasmancer_admit.get("total", -1)) == 60, "Plasmancer is admitted to construction at 60 points")

	# 3. Technomancer (000002352)
	var technomancer := Profiles.profile("technomancer")
	check(technomancer.get("source_datasheet_id") == "000002352", "Technomancer datasheet ID is 000002352")
	check(technomancer.get("points_by_models") == {1: 80}, "Technomancer 1st unit points are 80")
	check(technomancer.get("second_plus_points_by_models") == {1: 90}, "Technomancer 2nd+ unit points are 90")
	check(technomancer.get("third_plus_points_by_models") == {1: 90}, "Technomancer 3rd+ unit points are 90")
	check(technomancer.get("base_size_source_mm") == 50, "Technomancer base is 50 mm")
	check(technomancer.get("stats") == {
		"movement_inches": 10, "toughness": 4, "save_target": 4, "wounds": 4,
		"leadership_target": 6, "objective_control": 1, "invulnerable_target": 0
	}, "Technomancer stats match source (10\" Fly, 4W)")
	check(technomancer.get("keywords") == ["NECRONS", "FLY", "INFANTRY", "CHARACTER", "CRYPTEK", "TECHNOMANCER"], "Technomancer keywords match source")
	var techno_ranged: Dictionary = technomancer.get("ranged", [{}])[0].get("profiles", {}).get("standard", {})
	var techno_melee: Dictionary = technomancer.get("melee", [{}])[0].get("profiles", {}).get("standard", {})
	check(techno_ranged == {
		"name": "Staff of light", "range_inches": 18.0, "attacks": 3, "skill": 4,
		"strength": 5, "ap": -2, "damage": 1, "keywords": {}
	}, "Technomancer ranged weapon is Staff of light")
	check(techno_melee == {
		"name": "Staff of light", "range_inches": 0.0, "attacks": 2, "skill": 4,
		"strength": 5, "ap": -2, "damage": 1, "keywords": {}
	}, "Technomancer melee weapon is Staff of light")
	check(technomancer.get("supported_rule_ids") == ["support", "reanimation-protocols", "rites-of-reanimation", "technomancer"], "Technomancer supported rules match local scope")
	check(technomancer.get("unsupported_abilities", []).is_empty() and technomancer.get("pending_source_checks", []).is_empty()
		and technomancer.get("source_profile_readiness") == "source_bounded_local_scope_passed_2026_11_12", "Technomancer profile readiness is complete")
	var technomancer_admit := Army.admit({"schema_version": 2, "faction": "Necrons", "category": "custom", "points_limit": 1000, "entries": [{"definition_id": TECHNOMANCER_ID, "models": 1, "copies": 1}]})
	check(str(technomancer_admit.get("error", "")).is_empty() and int(technomancer_admit.get("total", -1)) == 80, "Technomancer 1st unit is admitted at 80 points")
	var technomancer_two := Army.admit({"schema_version": 2, "faction": "Necrons", "category": "custom", "points_limit": 1000, "entries": [{"definition_id": TECHNOMANCER_ID, "models": 1, "copies": 2}]})
	check(str(technomancer_two.get("error", "")).is_empty() and int(technomancer_two.get("total", -1)) == 170, "Technomancer two units cost 80 + 90 = 170 points")

	# 4. Psychomancer (000002353)
	var psychomancer := Profiles.profile("psychomancer")
	check(psychomancer.get("source_datasheet_id") == "000002353", "Psychomancer datasheet ID is 000002353")
	check(psychomancer.get("points_by_models") == {1: 65}, "Psychomancer points are 65 for 1 model")
	check(psychomancer.get("base_size_source_mm") == 40, "Psychomancer base is 40 mm")
	check(psychomancer.get("stats") == {
		"movement_inches": 5, "toughness": 4, "save_target": 4, "wounds": 4,
		"leadership_target": 6, "objective_control": 1, "invulnerable_target": 0
	}, "Psychomancer stats match source (4W, Sv 4+)")
	check(psychomancer.get("keywords") == ["NECRONS", "PSYCHOMANCER", "INFANTRY", "CHARACTER", "CRYPTEK"], "Psychomancer keywords match source")
	var abyssal_ranged: Dictionary = psychomancer.get("ranged", [{}])[0].get("profiles", {}).get("standard", {})
	var abyssal_melee: Dictionary = psychomancer.get("melee", [{}])[0].get("profiles", {}).get("standard", {})
	check(abyssal_ranged == {
		"name": "Abyssal lance", "range_inches": 18.0, "attacks": 1, "skill": 4,
		"strength": 6, "ap": -3, "damage": 3, "keywords": {}
	}, "Psychomancer ranged weapon is Abyssal lance")
	check(abyssal_melee == {
		"name": "Abyssal lance", "range_inches": 0.0, "attacks": 1, "skill": 4,
		"strength": 6, "ap": -3, "damage": 3, "keywords": {}
	}, "Psychomancer melee weapon is Abyssal lance")
	check(psychomancer.get("supported_rule_ids") == ["support", "reanimation-protocols", "nightmare-shroud", "harbinger-of-despair"], "Psychomancer supported rules match local scope")
	check(psychomancer.get("unsupported_abilities", []).is_empty() and psychomancer.get("pending_source_checks", []).is_empty()
		and psychomancer.get("source_profile_readiness") == "source_bounded_local_scope_passed_2026_11_12", "Psychomancer profile readiness is complete")
	var psychomancer_admit := Army.admit({"schema_version": 2, "faction": "Necrons", "category": "custom", "points_limit": 1000, "entries": [{"definition_id": PSYCHOMANCER_ID, "models": 1, "copies": 1}]})
	check(str(psychomancer_admit.get("error", "")).is_empty() and int(psychomancer_admit.get("total", -1)) == 65, "Psychomancer is admitted to construction at 65 points")

	# 5. Chronomancer (000002354)
	var chronomancer := Profiles.profile("chronomancer")
	check(chronomancer.get("source_datasheet_id") == "000002354", "Chronomancer datasheet ID is 000002354")
	check(chronomancer.get("points_by_models") == {1: 70}, "Chronomancer 1st unit points are 70")
	check(chronomancer.get("second_plus_points_by_models") == {1: 80}, "Chronomancer 2nd+ unit points are 80")
	check(chronomancer.get("third_plus_points_by_models") == {1: 80}, "Chronomancer 3rd+ unit points are 80")
	check(chronomancer.get("base_size_source_mm") == 40, "Chronomancer base is 40 mm")
	check(chronomancer.get("stats") == {
		"movement_inches": 5, "toughness": 4, "save_target": 4, "wounds": 4,
		"leadership_target": 6, "objective_control": 1, "invulnerable_target": 4
	}, "Chronomancer stats match source (4W, 4++ invuln)")
	check(chronomancer.get("keywords") == ["NECRONS", "CHARACTER", "INFANTRY", "CHRONOMANCER", "CRYPTEK"], "Chronomancer keywords match source")
	var aeon_ranged: Dictionary = chronomancer.get("ranged", [{}])[0].get("profiles", {}).get("standard", {})
	var aeon_melee: Dictionary = chronomancer.get("melee", [{}])[0].get("profiles", {}).get("standard", {})
	check(aeon_ranged == {
		"name": "Aeonstave", "range_inches": 18.0, "attacks": "D6", "skill": 4,
		"strength": 5, "ap": -1, "damage": 1, "keywords": {"blast": true}
	}, "Chronomancer ranged weapon is Aeonstave")
	check(aeon_melee == {
		"name": "Aeonstave", "range_inches": 0.0, "attacks": 3, "skill": 4,
		"strength": 5, "ap": -1, "damage": 1, "keywords": {}
	}, "Chronomancer melee weapon is Aeonstave")
	check(chronomancer.get("supported_rule_ids") == ["support", "reanimation-protocols", "stealth", "timesplinter-mantle", "chronometron"], "Chronomancer supported rules match local scope")
	check(chronomancer.get("unsupported_abilities", []).is_empty() and chronomancer.get("pending_source_checks", []).is_empty()
		and chronomancer.get("source_profile_readiness") == "source_bounded_local_scope_passed_2026_11_12", "Chronomancer profile readiness is complete")
	var chronomancer_admit := Army.admit({"schema_version": 2, "faction": "Necrons", "category": "custom", "points_limit": 1000, "entries": [{"definition_id": CHRONOMANCER_ID, "models": 1, "copies": 1}]})
	check(str(chronomancer_admit.get("error", "")).is_empty() and int(chronomancer_admit.get("total", -1)) == 70, "Chronomancer 1st unit is admitted at 70 points")
	var chronomancer_two := Army.admit({"schema_version": 2, "faction": "Necrons", "category": "custom", "points_limit": 1000, "entries": [{"definition_id": CHRONOMANCER_ID, "models": 1, "copies": 2}]})
	check(str(chronomancer_two.get("error", "")).is_empty() and int(chronomancer_two.get("total", -1)) == 150, "Chronomancer two units cost 70 + 80 = 150 points")

func test_support_links_and_reanimation() -> void:
	# Check SupportLinks.BODYGUARDS for all 5 Crypteks
	check(SupportLinks.BODYGUARDS.get("orikan-the-diviner", []) == ["necron-warriors", "immortals"], "Orikan bodyguards are Warriors and Immortals")
	check(SupportLinks.BODYGUARDS.get("plasmancer", []) == ["necron-warriors", "immortals"], "Plasmancer bodyguards are Warriors and Immortals")
	check(SupportLinks.BODYGUARDS.get("technomancer", []) == ["necron-warriors", "immortals", "canoptek-wraiths"], "Technomancer bodyguards include Warriors, Immortals, Wraiths")
	check(SupportLinks.BODYGUARDS.get("psychomancer", []) == ["necron-warriors", "immortals"], "Psychomancer bodyguards are Warriors and Immortals")
	check(SupportLinks.BODYGUARDS.get("chronomancer", []) == ["necron-warriors", "immortals"], "Chronomancer bodyguards are Warriors and Immortals")

	# Check standalone Reanimation Protocols admission
	for id in [ORIKAN_ID, PLASMANCER_ID, TECHNOMANCER_ID, PSYCHOMANCER_ID, CHRONOMANCER_ID]:
		var state := {
			"squads": {1: {"owner": 1, "attached": false}},
			"units": {101: {"owner": 1, "squad": 1, "definition_id": id, "wounds": 3, "max_wounds": 4, "elevation": 0.0}}
		}
		check(Reanimation.supported_unit(state, 1), "Standalone Cryptek %s is supported for Reanimation Protocols" % id)

	# Check attached Cryptek Support + Bodyguard
	var attached_state := {
		"squads": {1: {"owner": 1, "attached": true, "starting_strength": 6, "components": [{"role": "support", "definition_id": TECHNOMANCER_ID}, {"role": "bodyguard", "definition_id": IMMORTALS_ID}]}},
		"units": {
			101: {"owner": 1, "squad": 1, "definition_id": TECHNOMANCER_ID, "attachment_role": "support", "wounds": 4, "max_wounds": 4, "elevation": 0.0, "keywords": ["CRYPTEK"]}
		}
	}
	for i in range(1, 6):
		attached_state.units[101 + i] = {
			"owner": 1, "squad": 1, "definition_id": IMMORTALS_ID, "attachment_role": "bodyguard", "wounds": 1, "max_wounds": 1, "elevation": 0.0, "keywords": ["INFANTRY"]
		}
	check(Reanimation.supported_unit(attached_state, 1), "Attached Technomancer + Immortals unit is supported for Reanimation")

func test_plasmancer_rules() -> void:
	# 1. Harbinger of Destruction: Critical Hit on unmodified 5+ for ranged attacks while leading
	var state := {
		"active": 1, "phase": "shooting", "turn": 1, "round": 1, "cp": {1: 0, 2: 0},
		"pending_move": {}, "pending_contact": {},
		"board_size": Vector2(44, 30),
		"terrain": {"id": "clear", "areas": []},
		"unit_abilities": {"implementation": AbilityCatalog.ID, "window": {}, "used": {}, "doctrines": {}, "anchors": {}},
		"squads": {
			1: {"owner": 1, "name": "Plasmancer Unit", "attached": false, "starting_strength": 1, "charged": false, "advanced": false, "shot": false, "stats": {"toughness": 4, "save_target": 4, "wounds": 4, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 0}},
			2: {"owner": 2, "name": "Target Squad", "attached": false, "starting_strength": 1, "charged": false, "advanced": false, "shot": false, "stats": {"toughness": 4, "save_target": 3, "wounds": 2, "leadership_target": 6, "objective_control": 2, "invulnerable_target": 0}}
		},
		"units": {
			101: {
				"owner": 1, "squad": 1, "definition_id": PLASMANCER_ID, "wounds": 4, "max_wounds": 4,
				"position": Vector2(0, 0), "radius": 32.0 / 50.8,
				"ranged_weapons": Profiles.profile("plasmancer").get("ranged", []).duplicate(true),
				"melee_weapons": Profiles.profile("plasmancer").get("melee", []).duplicate(true),
				"keywords": ["NECRONS", "CHARACTER", "CRYPTEK", "PLASMANCER"]
			},
			201: {
				"owner": 2, "squad": 2, "definition_id": INTERCESSOR_ID, "wounds": 2, "max_wounds": 2,
				"position": Vector2(10, 0), "radius": 32.0 / 50.8,
				"keywords": ["INFANTRY"]
			}
		},
		"revision": 1
	}

	# Unattached Plasmancer: critical hit threshold is 6
	var unattached_plan := AttackPlan.prepare(state, 1, false, [{"model": 101, "target": 2, "amount": 1, "weapon": "plasmic-lance", "profile": "standard"}], false)
	check(str(unattached_plan.get("error", "")).is_empty() and unattached_plan.batches[0].context.get("critical_hit_threshold", 6) == 6, "Unattached Plasmancer has normal 6 critical hit threshold")

	# Attached Plasmancer leading Warriors: critical hit threshold is 5
	state.squads[1].attached = true
	state.squads[1].components = [{"role": "support", "definition_id": PLASMANCER_ID}, {"role": "bodyguard", "definition_id": WARRIORS_ID}]
	state.units[101].attachment_role = "support"
	state.units[102] = {
		"owner": 1, "squad": 1, "definition_id": WARRIORS_ID, "attachment_role": "bodyguard", "wounds": 1, "max_wounds": 1,
		"position": Vector2(1, 0), "radius": 32.0 / 50.8, "keywords": ["INFANTRY"]
	}
	check(UnitAbilities.leading(state, 1, "harbinger-of-destruction"), "Attached Plasmancer is leading for Harbinger of Destruction")
	var attached_plan := AttackPlan.prepare(state, 1, false, [{"model": 101, "target": 2, "amount": 1, "weapon": "plasmic-lance", "profile": "standard"}], false)
	check(str(attached_plan.get("error", "")).is_empty() and int(attached_plan.batches[0].context.get("critical_hit_threshold", 6)) == 5, "Harbinger of Destruction grants 5+ Critical Hits to ranged attacks while leading")

	# 2. Living Lightning: 18" visible range, 4D6, 4+ mortal wound, Lone Operative exclusion >12"
	var choices := UnitActions.choices(state, 1)
	var living_lightning_choice: Dictionary = {}
	for c in choices:
		if c.action == "living-lightning": living_lightning_choice = c
	check(not living_lightning_choice.is_empty(), "Living Lightning is offered in own Shooting phase within 18 inches")

	# Check Lone Operative > 12" exclusion
	state.units[201].definition_id = "40kdc:11e:adeptus-astartes:lieutenant-with-combi-weapon"
	state.units[201].keywords = ["INFANTRY", "CHARACTER", "LIEUTENANT"]
	check(UnitAbilities.lone_operative(state, 2), "Target squad 2 has Lone Operative")
	state.units[201].position = Vector2(14, 0) # 14 inches away (between 12" and 18")
	var choices_lone_far := UnitActions.choices(state, 1)
	var has_lone_far := choices_lone_far.any(func(c: Dictionary) -> bool: return c.action == "living-lightning")
	check(not has_lone_far, "Living Lightning is not offered against Lone Operative beyond 12 inches")

	state.units[201].position = Vector2(10, 0) # 10 inches away (<=12")
	var choices_lone_near := UnitActions.choices(state, 1)
	var has_lone_near := choices_lone_near.any(func(c: Dictionary) -> bool: return c.action == "living-lightning")
	check(has_lone_near, "Living Lightning is offered against Lone Operative within 12 inches")

	# Apply Living Lightning with fixed dice [4, 5, 2, 6] -> 3 mortal wounds
	var fixed_roller := mock_roller([4, 5, 2, 6])
	var apply_ll := UnitActions.apply(state, 1, {"action": "living-lightning", "model": 101, "target": 2}, Vector2.ZERO, fixed_roller)
	check(str(apply_ll.get("error", "")).is_empty(), "Living Lightning applies successfully")
	check(state.unit_abilities.window.get("kind", "") == CoreReactions.LIVING_LIGHTNING_MORTAL, "Living Lightning opens LIVING_LIGHTNING_MORTAL window")
	check(state.last_living_lightning.get("mortal_wounds", 0) == 3, "Living Lightning rolls [4, 5, 2, 6] score 3 mortal wounds")

	# Allocate mortal wound
	var alloc_choices := UnitActions.choices(state, 2)
	check(alloc_choices.size() > 0 and alloc_choices[0].action == "mortal-allocate", "Defender can allocate Living Lightning mortal wounds")
	var alloc_res := UnitActions.apply(state, 2, alloc_choices[0], Vector2.ZERO, mock_roller([1]))
	check(str(alloc_res.get("error", "")).is_empty() and state.units[201].wounds == 1, "Allocating mortal wound reduces target wounds to 1")

func test_technomancer_rules() -> void:
	# 1. Rites of Reanimation: Feel No Pain 5+ for models in led unit
	var state := {
		"active": 1, "phase": "movement", "turn": 1, "round": 1, "cp": {1: 0, 2: 0},
		"pending_move": {}, "pending_contact": {},
		"board_size": Vector2(44, 30),
		"terrain": {"id": "clear", "areas": []},
		"unit_abilities": {"implementation": AbilityCatalog.ID, "window": {}, "used": {}, "doctrines": {}, "anchors": {}},
		"squads": {
			1: {"owner": 1, "name": "Technomancer Unit", "attached": true, "starting_strength": 2, "charged": false, "components": [{"role": "support", "definition_id": TECHNOMANCER_ID}, {"role": "bodyguard", "definition_id": WRAITHS_ID}], "stats": {"toughness": 6, "save_target": 3, "wounds": 4, "leadership_target": 8, "objective_control": 2, "invulnerable_target": 4}}
		},
		"units": {
			101: {"owner": 1, "squad": 1, "definition_id": TECHNOMANCER_ID, "attachment_role": "support", "wounds": 4, "max_wounds": 4, "position": Vector2(0, 0), "radius": 50.0 / 50.8, "keywords": ["NECRONS", "CHARACTER", "CRYPTEK", "TECHNOMANCER"]},
			102: {"owner": 1, "squad": 1, "definition_id": WRAITHS_ID, "attachment_role": "bodyguard", "wounds": 4, "max_wounds": 4, "position": Vector2(1, 0), "radius": 50.0 / 50.8, "keywords": ["NECRONS", "CANOPTEK", "WRAITHS"]}
		},
		"revision": 1
	}

	check(UnitAbilities.leading(state, 1, "rites-of-reanimation"), "Technomancer is leading attached Canoptek Wraiths")
	var fnp_rules = UnitPrevention.rules(state, 102)
	var has_fnp_5 := false
	for r in fnp_rules:
		if r.get("target") == 5 and r.get("against") == "any": has_fnp_5 = true
	check(has_fnp_5, "Rites of Reanimation grants Feel No Pain 5+ to models in the led unit")

	# 2. Technomancer model repair: at end of Movement phase, heal friendly NECRONS model within 6" for D3 lost wounds
	state.units[102].wounds = 2 # Lost 2 wounds
	var repair_choices := UnitActions.technomancer_repair_choices(state, 1)
	check(repair_choices.size() == 1 and repair_choices[0].model == 101 and repair_choices[0].target == 102, "Technomancer repair choice offered for wounded model 102 within 6 inches")

	# Check open_end opens window with end
	state.unit_abilities.end_done = ""
	check(UnitActions.open_end(state), "End window opens at end of Movement phase when Technomancer can repair")
	check(state.unit_abilities.window.get("kind", "") == "end", "End-phase window opened")

	# Apply repair with fixed D3 roll of 2 -> heals 2 wounds back to 4
	var repair_res := UnitActions.apply(state, 1, repair_choices[0], Vector2.ZERO, mock_roller([4])) # 4 on D6 -> D3 value 2
	check(str(repair_res.get("error", "")).is_empty() and state.units[102].wounds == 4, "Technomancer repairs model 102 from 2 to 4 wounds")
	check(UnitActions.technomancer_repair_choices(state, 1).is_empty(), "Repaired model or used Technomancer cannot be repaired again this turn")

func test_psychomancer_rules() -> void:
	# 1. Nightmare Shroud (Aura): In opponent's Command phase, enemy unit within 6" below Starting Strength tests Battle-shock at -1
	var state := {
		"active": 2, "phase": "command", "turn": 2, "round": 1, "cp": {1: 0, 2: 0},
		"pending_move": {}, "pending_contact": {},
		"board_size": Vector2(44, 30),
		"terrain": {"id": "clear", "areas": []},
		"unit_abilities": {"implementation": AbilityCatalog.ID, "window": {}, "used": {}, "doctrines": {}, "anchors": {}},
		"squads": {
			1: {"owner": 1, "name": "Psychomancer Squad", "attached": false, "starting_strength": 1, "charged": false, "battle_shocked": false, "stats": {"toughness": 4, "save_target": 4, "wounds": 4, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 0}},
			2: {"owner": 2, "name": "Enemy Marine Squad", "attached": false, "starting_strength": 5, "charged": false, "battle_shocked": false, "stats": {"toughness": 4, "save_target": 3, "wounds": 2, "leadership_target": 6, "objective_control": 2, "invulnerable_target": 0}}
		},
		"units": {
			101: {"owner": 1, "squad": 1, "definition_id": PSYCHOMANCER_ID, "wounds": 4, "max_wounds": 4, "position": Vector2(0, 0), "radius": 40.0 / 50.8, "keywords": ["NECRONS", "CHARACTER", "CRYPTEK", "PSYCHOMANCER"]},
			201: {"owner": 2, "squad": 2, "definition_id": INTERCESSOR_ID, "wounds": 2, "max_wounds": 2, "position": Vector2(3, 0), "radius": 32.0 / 50.8, "keywords": ["INFANTRY"]},
			202: {"owner": 2, "squad": 2, "definition_id": INTERCESSOR_ID, "wounds": 2, "max_wounds": 2, "position": Vector2(4, 0), "radius": 32.0 / 50.8, "keywords": ["INFANTRY"]},
			203: {"owner": 2, "squad": 2, "definition_id": INTERCESSOR_ID, "wounds": 2, "max_wounds": 2, "position": Vector2(5, 0), "radius": 32.0 / 50.8, "keywords": ["INFANTRY"]},
			204: {"owner": 2, "squad": 2, "definition_id": INTERCESSOR_ID, "wounds": 2, "max_wounds": 2, "position": Vector2(6, 0), "radius": 32.0 / 50.8, "keywords": ["INFANTRY"]}
		},
		"revision": 1
	}

	# Starting strength is 5, living models is 4 (below Starting Strength, but not at half strength 4*2 > 5)
	check(Morale.below_starting_strength(state, 2) and not Morale.at_half_strength(state, 2), "Unit is Below Starting Strength but not Below Half-strength")
	check(Morale.nightmare_shroud_applies(state, 2), "Nightmare Shroud applies to enemy unit within 6\" that is below Starting Strength")
	check(Morale.command_battle_shock_modifier(state, 2) == -1, "Nightmare Shroud grants -1 to Command Battle-shock test")
	check(Morale.needs_command_roll(state, 2), "Unit requires Command Battle-shock test due to Nightmare Shroud")

	# 2. Harbinger of Despair: once per turn at start of Command/Movement/Shooting/Charge/Fight phase, enemy unit within 18" tests Battle-shock at -1
	state.active = 1
	state.phase = "movement"
	var despair_choices := UnitActions.harbinger_of_despair_choices(state, 1)
	check(despair_choices.size() == 1 and despair_choices[0].model == 101 and despair_choices[0].target == 2, "Harbinger of Despair offered against enemy squad within 18 inches")
	# Roll dice [3, 3] = 6 with -1 modifier = 5 against Ld 6+ -> failed!
	var despair_roller := mock_roller([3, 3])
	var despair_res := UnitActions.apply(state, 1, despair_choices[0], Vector2.ZERO, despair_roller)
	check(str(despair_res.get("error", "")).is_empty(), "Harbinger of Despair applied successfully")
	check(state.squads[2].battle_shocked, "Failing Battle-shock test at -1 makes target unit Battle-shocked")
	check(UnitActions.harbinger_of_despair_choices(state, 1).is_empty(), "Harbinger of Despair cannot be used again this turn")

func test_chronomancer_rules() -> void:
	# 1. Timesplinter Mantle: Unit has Stealth and melee attacks targeting unit have -1 to Hit
	var state := {
		"active": 2, "phase": "fight", "turn": 1, "round": 1, "cp": {1: 0, 2: 0},
		"pending_move": {}, "pending_contact": {},
		"board_size": Vector2(44, 30),
		"terrain": {"id": "clear", "areas": []},
		"unit_abilities": {"implementation": AbilityCatalog.ID, "window": {}, "used": {}, "doctrines": {}, "anchors": {}},
		"squads": {
			1: {"owner": 1, "name": "Chronomancer Unit", "attached": true, "starting_strength": 2, "charged": false, "components": [{"role": "support", "definition_id": CHRONOMANCER_ID}, {"role": "bodyguard", "definition_id": WARRIORS_ID}], "stats": {"toughness": 4, "save_target": 4, "wounds": 4, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 4}},
			2: {"owner": 2, "name": "Attacking Intercessors", "attached": false, "starting_strength": 5, "charged": false, "stats": {"toughness": 4, "save_target": 3, "wounds": 2, "leadership_target": 6, "objective_control": 2, "invulnerable_target": 0}}
		},
		"units": {
			101: {"owner": 1, "squad": 1, "definition_id": CHRONOMANCER_ID, "attachment_role": "support", "wounds": 4, "max_wounds": 4, "position": Vector2(0, 0), "radius": 40.0 / 50.8, "keywords": ["NECRONS", "CHARACTER", "CRYPTEK", "CHRONOMANCER"]},
			102: {"owner": 1, "squad": 1, "definition_id": WARRIORS_ID, "attachment_role": "bodyguard", "wounds": 1, "max_wounds": 1, "position": Vector2(2, 0), "radius": 32.0 / 50.8, "keywords": ["INFANTRY"]},
			201: {"owner": 2, "squad": 2, "definition_id": INTERCESSOR_ID, "wounds": 2, "max_wounds": 2, "position": Vector2(0, 1), "radius": 32.0 / 50.8, "melee_weapons": [{"id": "close-combat-weapon", "profiles": {"standard": {"name": "Close combat weapon", "range_inches": 0.0, "attacks": 3, "skill": 3, "strength": 4, "ap": 0, "damage": 1, "keywords": {}}}}], "keywords": ["INFANTRY"]}
		},
		"revision": 1
	}

	# Stealth check for attached unit
	check(Detection.stealth(state, 1), "Chronomancer grants unit-wide Stealth via Timesplinter Mantle")
	# Melee hit modifier check against the unit
	var melee_hit_mod := UnitAbilities.hit_bonus(state, 2, 1, true, 201, {})
	check(melee_hit_mod == -1, "Timesplinter Mantle applies -1 to incoming melee hit rolls")

	# 2. Chronometron: after shooting while unengaged, Normal Move up to 5", cannot charge that turn
	state.active = 1
	state.phase = "shooting"
	state.squads[1].shot = true
	state.units[201].position = Vector2(10, 10) # Unengaged
	check(TacticalFluidity.chronometron_eligible(state, 1, 1), "Chronomancer unit is eligible for Chronometron after shooting while unengaged")

	TacticalFluidity.open_after_shot(state, 1)
	check(state.unit_abilities.window.get("kind", "") == TacticalFluidity.WINDOW and state.unit_abilities.window.get("source", "") == "chronometron", "Chronometron window opened after shooting")

	var fluid_choices := TacticalFluidity.choices(state, 1)
	var use_chronometron: Dictionary = {}
	for fc in fluid_choices:
		if fc.action == "fluidity-use": use_chronometron = fc
	check(not use_chronometron.is_empty(), "Chronometron Normal Move choice is offered")

	var use_res := TacticalFluidity.apply(state, 1, use_chronometron, Vector2.ZERO, Callable())
	check(str(use_res.get("error", "")).is_empty() and state.unit_abilities.window.get("kind", "") == TacticalFluidity.PLACEMENT and int(state.unit_abilities.window.get("distance", 0)) == 5, "Chronometron use advances to PLACEMENT window with 5 inches move distance")

	# Place models and confirm move
	var confirm_choice := {"action": "fluidity-confirm", "target": 1}
	var confirm_res := TacticalFluidity.apply(state, 1, confirm_choice, Vector2.ZERO, Callable())
	check(str(confirm_res.get("error", "")).is_empty(), "Chronometron move confirmed successfully")
	check(state.squads[1].get("cannot_charge_until_turn", -1) == 1, "Chronometron marks cannot_charge_until_turn for this turn")
	check(Actions.charge_blocked(state, 1), "Unit cannot declare a charge this turn after using Chronometron")

func test_orikan_rules() -> void:
	# 1. Master Chronomancer: 4+ invulnerable save for models in led unit
	var state := {
		"active": 1, "phase": "fight", "turn": 1, "round": 1, "cp": {1: 0, 2: 0},
		"pending_move": {}, "pending_contact": {},
		"board_size": Vector2(44, 30),
		"terrain": {"id": "clear", "areas": []},
		"unit_abilities": {"implementation": AbilityCatalog.ID, "window": {}, "used": {}, "doctrines": {}, "anchors": {}},
		"squads": {
			1: {"owner": 1, "name": "Orikan Unit", "attached": true, "starting_strength": 2, "charged": false, "components": [{"role": "support", "definition_id": ORIKAN_ID}, {"role": "bodyguard", "definition_id": WARRIORS_ID}], "stats": {"toughness": 4, "save_target": 4, "wounds": 4, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 4}},
			2: {"owner": 2, "name": "Enemy Unit", "attached": false, "starting_strength": 5, "charged": false, "stats": {"toughness": 4, "save_target": 3, "wounds": 2, "leadership_target": 6, "objective_control": 2, "invulnerable_target": 0}}
		},
		"units": {
			101: {"owner": 1, "squad": 1, "definition_id": ORIKAN_ID, "attachment_role": "support", "wounds": 4, "max_wounds": 4, "position": Vector2(0, 0), "radius": 40.0 / 50.8, "keywords": ["NECRONS", "CHARACTER", "EPIC HERO", "CRYPTEK", "CHRONOMANCER", "ORIKAN THE DIVINER"]},
			102: {"owner": 1, "squad": 1, "definition_id": WARRIORS_ID, "attachment_role": "bodyguard", "wounds": 1, "max_wounds": 1, "position": Vector2(1, 0), "radius": 32.0 / 50.8, "keywords": ["INFANTRY"]},
			201: {"owner": 2, "squad": 2, "definition_id": INTERCESSOR_ID, "wounds": 2, "max_wounds": 2, "position": Vector2(0, 1), "radius": 32.0 / 50.8, "keywords": ["INFANTRY"]}
		},
		"revision": 1
	}

	var warrior_defense := DefenderGroups.profile(state, 102, false)
	check(int(warrior_defense.get("invulnerable_target", 0)) == 4, "Master Chronomancer grants 4+ invulnerable save to Necron Warriors while Orikan is leading")

	# 2. The Stars Are Right: once per battle at start of Fight phase, triple Attacks (2 -> 6) and Strength (4 -> 12), all successful wounds are Critical Wounds
	var stars_choices := UnitActions.the_stars_are_right_choices(state, 1)
	check(stars_choices.size() == 1 and stars_choices[0].model == 101, "The Stars Are Right choice is offered at start of Fight phase")

	var stars_res := UnitActions.apply(state, 1, stars_choices[0], Vector2.ZERO, Callable())
	check(str(stars_res.get("error", "")).is_empty(), "The Stars Are Right applied successfully")
	check(UnitAbilities.the_stars_are_right_active(state, 101), "The Stars Are Right is active for Orikan in this Fight phase")

	# Staff of Tomorrow weapon stats check
	var orikan_prof := Profiles.profile("orikan-the-diviner")
	var staff_weap: Dictionary = orikan_prof.melee[0].profiles.standard
	var modified_staff := UnitAbilities.weapon(state, 101, 2, staff_weap, true)
	check(modified_staff.attacks == 6, "The Stars Are Right triples Staff of Tomorrow Attacks: 2 -> 6")
	check(modified_staff.strength == 12, "The Stars Are Right triples Staff of Tomorrow Strength: 4 -> 12")
	check(UnitAbilities.melee_attack_count(state, 101, staff_weap) == 6, "melee_attack_count reflects tripled attacks (6)")

	# Attack plan with Staff of Tomorrow using active Stars Are Right
	var fight_state := {
		"active": 1, "phase": "fight", "turn": 1, "round": 1, "cp": {1: 0, 2: 0},
		"pending_move": {}, "pending_contact": {},
		"board_size": Vector2(44, 30),
		"terrain": {"id": "clear", "areas": []},
		"unit_abilities": {"implementation": AbilityCatalog.ID, "window": {}, "used": {"the-stars-are-right:101": true, "the-stars-are-right-active:101:1:fight": true}, "doctrines": {}, "anchors": {}},
		"squads": {
			1: {"owner": 1, "name": "Orikan Standalone", "attached": false, "starting_strength": 1, "charged": false, "stats": {"toughness": 4, "save_target": 4, "wounds": 4, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 4}},
			2: {"owner": 2, "name": "Enemy Unit", "attached": false, "starting_strength": 1, "charged": false, "stats": {"toughness": 4, "save_target": 3, "wounds": 2, "leadership_target": 6, "objective_control": 2, "invulnerable_target": 0}}
		},
		"units": {
			101: {"owner": 1, "squad": 1, "definition_id": ORIKAN_ID, "wounds": 4, "max_wounds": 4, "position": Vector2(0, 0), "radius": 40.0 / 50.8, "keywords": ["NECRONS", "CHARACTER", "EPIC HERO", "CRYPTEK", "CHRONOMANCER", "ORIKAN THE DIVINER"], "melee_weapons": Profiles.profile("orikan-the-diviner").melee.duplicate(true)},
			201: {"owner": 2, "squad": 2, "definition_id": INTERCESSOR_ID, "wounds": 2, "max_wounds": 2, "position": Vector2(0, 1), "radius": 32.0 / 50.8, "keywords": ["INFANTRY"], "melee_weapons": []}
		},
		"revision": 1
	}
	var fight_plan := AttackPlan.prepare(fight_state, 1, true, [{"model": 101, "target": 2, "amount": 6, "weapon": "staff-of-tomorrow", "profile": "standard"}], false)
	check(str(fight_plan.get("error", "")).is_empty(), "AttackPlan prepared with Staff of Tomorrow")
	check(bool(fight_plan.batches[0].context.get("successful_wounds_are_critical", false)), "successful_wounds_are_critical context is set")
