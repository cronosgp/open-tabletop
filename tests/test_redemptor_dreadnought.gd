extends SceneTree
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Army = preload("res://scripts/edition_11/army_capabilities.gd")
const Abilities = preload("res://scripts/edition_11/unit_abilities.gd")
const PublicUnitCommand = preload("res://tests/public_unit_command.gd")
const Attacks = preload("res://scripts/edition_11/attack_sequence.gd")
const Demise = preload("res://scripts/edition_11/deadly_demise.gd")
const UnitActions = preload("res://scripts/edition_11/unit_actions.gd")
const F = preload("res://tests/all_units_fixture.gd")
var failures := 0
var dice: Array[int] = []

func check(ok: bool, message: String) -> void:
	if not ok: push_error(message); failures += 1

func roll_die() -> int:
	return dice.pop_front() if not dice.is_empty() else 1

func selection(copies: int = 1) -> Dictionary:
	return {"schema_version": 2, "faction": "Space Marines", "category": "incursion", "points_limit": 1000,
		"entries": [{"definition_id": "40kdc:11e:adeptus-astartes:redemptor-dreadnought", "models": 1, "copies": copies}]}

func run() -> void:
	var profile := Profiles.profile("redemptor-dreadnought")
	check(profile.source_book_id == "000000139" and profile.source_datasheet_id == "000002717" and profile.source_export_updated_at == "2026-10-16T21:03:46+03:00", "Redemptor profile cites the correct local Space Marines export")
	check(profile.points_by_models == {1: 170} and profile.third_plus_points_by_models == {1: 190} and profile.wargear_costs == {"macro-plasma-incinerator": 10}, "First, second, third-plus and Macro Plasma costs match the extraction")
	check(profile.stats == {"movement_inches": 8, "toughness": 10, "save_target": 2, "wounds": 12, "leadership_target": 6, "objective_control": 4, "invulnerable_target": 0} and profile.damaged_threshold == 4 and profile.base_radius_inches == 45.0 / 25.4, "Characteristics, Damaged 4 and 90 mm base match the sheet")
	check(profile.ranged.size() == 3 and profile.ranged[0].profiles.standard.name == "Fragstorm Grenade Launchers" and profile.ranged[1].profiles.standard.name == "Heavy Flamer" and profile.ranged[1].profiles.standard.skill == null and profile.ranged[2].profiles.standard.name == "Heavy Onslaught Gatling Cannon" and profile.melee[0].profiles.standard.name == "Redemptor Fist", "All default Redemptor weapons match the source, including the Torrent weapon's absent BS")
	check(profile.ranged[0].profiles.standard.keywords.blast == 2 and profile.ranged[1].profiles.standard.keywords.torrent and profile.ranged[2].profiles.standard.keywords == {"devastating-wounds": true, "sustained-hits": 2} and profile.ranged[2].profiles.standard.target_restricted_traits == {"devastating-wounds": ["MONSTER", "VEHICLE"], "sustained-hits": ["MONSTER", "VEHICLE"]}, "Default weapon traits include source target restrictions")
	var replacements := Profiles.redemptor_weapons(false, false, true, true)
	check(replacements.size() == 4 and replacements[0].id == "storm-bolters" and replacements[1].id == "onslaught-gatling-cannon" and replacements[2].profiles.standard.strength == 9 and replacements[2].profiles.supercharge.keywords.hazardous and replacements[3].profiles.standard.keywords["anti-fly"] == 2, "All optional weapon replacements and the optional Icarus pod are transcribed")
	var admitted := Army.admit(selection())
	check(admitted.error.is_empty() and admitted.total == 170, "Redemptor enters local construction at the extracted first/second cost")
	var three := Army.admit(selection(3))
	check(three.error.is_empty() and three.total == 530, "Third Redemptor copy uses the extracted 190-point price")
	var wounded := {"unit_abilities": {"implementation": Abilities.ID}, "units": {
		100: {"definition_id": "40kdc:11e:adeptus-astartes:redemptor-dreadnought", "wounds": 5},
		101: {"definition_id": "40kdc:11e:adeptus-astartes:redemptor-dreadnought", "wounds": 4},
		102: {"definition_id": "40kdc:11e:adeptus-astartes:captain", "wounds": 4}}}
	check(Abilities.damaged_attack_penalty(wounded, 100) == 0 and Abilities.damaged_attack_penalty(wounded, 101) == -1 and Abilities.damaged_attack_penalty(wounded, 102) == 0, "Damaged 4 applies to Redemptor attacks only at 1–4 remaining wounds")
	var defense := {"turn": 1, "round": 1, "phase": "shooting", "active": 1, "unit_abilities": {"implementation": Abilities.ID, "window": {}, "used": {}}, "units": {
		100: {"definition_id": "40kdc:11e:adeptus-astartes:redemptor-dreadnought", "squad": 1, "owner": 1, "wounds": 12, "max_wounds": 12, "keywords": ["VEHICLE"]},
		200: {"definition_id": "fixture:enemy", "squad": 2, "owner": 2, "wounds": 1, "max_wounds": 1, "keywords": ["INFANTRY"]}}, "squads": {1: {"owner": 1, "name": "Redemptor"}, 2: {"owner": 2, "name": "Enemy"}}}
	check(Abilities.defensive_wound_modifier(defense, 1, 11, 10) == -1 and Abilities.defensive_wound_modifier(defense, 1, 10, 10) == 0, "Duty Eternal subtracts 1 only when attacking Strength exceeds Toughness")
	var battle_selections := F.selections()
	for entry: Dictionary in battle_selections[1].entries:
		if entry.definition_id.ends_with(":assault-intercessor-squad"):
			entry.definition_id = "40kdc:11e:adeptus-astartes:redemptor-dreadnought"
			entry.models = 1
	var battle := F.P.initial_state({"unit_abilities": true, "combat_doctrines": true, "reanimation_protocols": true, "awakened_dynasty": true, "core_stratagems": true}, battle_selections)
	check(not battle.has("error"), "Redemptor materializes in a prepared mixed-army battle")
	if not battle.has("error"):
		var redemptor_squad := -1
		var redemptor_model := -1
		var shooter_squad := -1
		var shooter_model := -1
		for model: int in battle.units:
			var unit: Dictionary = battle.units[model]
			if Abilities.identity(unit) == "redemptor-dreadnought" and unit.wounds > 0:
				redemptor_squad = unit.squad
				redemptor_model = model
			elif unit.owner == 2 and unit.wounds > 0 and shooter_model == -1:
				shooter_squad = unit.squad
				shooter_model = model
		for model: int in battle.units:
			if battle.units[model].squad == redemptor_squad and model != redemptor_model: battle.units[model].wounds = 0
		if shooter_model >= 0 and redemptor_model >= 0:
			battle.phase = "shooting"
			battle.active = 2
			battle.mission.stage = "battle"
			battle.awakened_dynasty.pending = []
			battle.units[shooter_model].position = Vector2.ZERO
			battle.units[redemptor_model].position = Vector2(10.0, 0.0)
			battle.units[shooter_model].ranged_weapons = [{"id": "duty-test-cannon", "profiles": {"standard": {"name": "Test Cannon", "range_inches": 48.0, "attacks": 1, "skill": 3, "strength": 12, "ap": -1, "damage": 1, "keywords": {}}}}]
			var duty_plan := F.C.AttackPlan.prepare(battle, shooter_squad, false, [{"model": shooter_model, "target": redemptor_squad, "amount": 1, "weapon": "duty-test-cannon", "profile": "standard"}], true)
			check(duty_plan.get("error", "").is_empty() and duty_plan.batches.size() == 1 and duty_plan.batches[0].context.wound_modifier == -1, "Duty Eternal modifies the actual attack plan against the Redemptor")
			battle.active = 1
			battle.units[redemptor_model].wounds = 4
			var damaged_plan := F.C.AttackPlan.prepare(battle, redemptor_squad, false, [{"model": redemptor_model, "target": shooter_squad, "amount": 1, "weapon": "fragstorm-grenade-launchers", "profile": "standard"}], true)
			check(damaged_plan.get("error", "").is_empty() and damaged_plan.batches.size() == 1 and damaged_plan.batches[0].context.hit_modifier == -1, "Damaged 4 enters the Redemptor's actual shooting attack plan")
		else: check(false, "Battle fixture exposes both a Redemptor and a shooting model")
	defense.units[200].keywords = ["MONSTER", "VEHICLE"]
	var heavy_gun: Dictionary = profile.ranged[2].profiles.standard
	var restricted_gun := Abilities.weapon(defense, 100, 2, heavy_gun, false)
	check(not restricted_gun.keywords.has("devastating-wounds") and not restricted_gun.keywords.has("sustained-hits"), "Heavy Onslaught loses both conditional traits against MONSTER or VEHICLE targets")
	defense.units[200].keywords = ["INFANTRY"]
	var infantry_gun := Abilities.weapon(defense, 100, 2, heavy_gun, false)
	check(infantry_gun.keywords.get("devastating-wounds", false) and infantry_gun.keywords.get("sustained-hits", 0) == 2, "Heavy Onslaught retains Devastating Wounds and Sustained Hits 2 against other targets")
	var iCarus: Dictionary = replacements[3].profiles.standard
	var defender := {"toughness": 4, "save_target": 7, "invulnerable_target": 0, "wounds_per_model": 3, "remaining_wounds": [3]}
	dice = [3, 4, 5, 2, 3, 6, 4, 4, 4]
	var vs_fly := Attacks.roll_pool(iCarus, defender, {"target_keywords": ["FLY"], "target_model_count": 1, "target_engaged": false, "distance_inches": 12.0, "heavy_eligible": false}, roll_die)
	check(vs_fly.error.is_empty() and vs_fly.wounds == 3 and vs_fly.critical_wounds == 3, "Anti-Fly 2+ makes unmodified 2+ Wound rolls critical against FLY")
	dice = [3, 4, 5, 2, 3, 6, 4, 4]
	var vs_ground := Attacks.roll_pool(iCarus, defender, {"target_keywords": ["INFANTRY"], "target_model_count": 1, "target_engaged": false, "distance_inches": 12.0, "heavy_eligible": false}, roll_die)
	check(vs_ground.error.is_empty() and vs_ground.wounds == 2 and vs_ground.critical_wounds == 1, "Anti-Fly does not change Wound rolls against non-FLY targets")
	var demise_state := {"units": {100: {"definition_id": "40kdc:11e:adeptus-astartes:redemptor-dreadnought", "squad": 1, "wounds": 0}}, "squads": {1: {"owner": 1, "name": "Redemptor"}}, "unit_abilities": {"implementation": Abilities.ID, "window": {}}, "pending_attack": {}, "awakened_dynasty": {"owners": []}, "detachment_stratagems": {"destroyed": [], "revived": []}}
	dice = [5]
	var demise := Demise.begin(demise_state, [100], roll_die)
	check(demise.error.is_empty() and demise.complete and demise_state.last_deadly_demise.events.size() == 1 and not demise_state.last_deadly_demise.events[0].triggered, "Redemptor resolves its own Deadly Demise D3 trigger check")
	var exploded_state: Dictionary = demise_state.duplicate(true)
	dice = [6]
	var exploded := Demise.begin(exploded_state, [100], roll_die)
	check(exploded.error.is_empty() and exploded.complete and exploded_state.last_deadly_demise.events[0].triggered, "A Redemptor Dreadnought can trigger its extracted Deadly Demise D3 on a 6")
	var setup := {"test_winner": 0, "phase": "deployment", "turn": 1, "round": 1, "revision": 0, "active": 1, "events": [], "units": {100: {"definition_id": "40kdc:11e:adeptus-astartes:redemptor-dreadnought", "owner": 1, "squad": 1, "wounds": 12, "max_wounds": 12, "ranged_weapons": profile.ranged.duplicate(true)}},
		"squads": {1: {"owner": 1, "name": "Redemptor", "training_cost": 170}}, "unit_abilities": {"implementation": Abilities.ID, "setup_players": [], "window": {}, "used": {}, "doctrines": {}, "reserves": {}},
		"awakened_dynasty": {"pending": []}, "pending_attack": {}, "pending_hazard": {}, "stratagems": {"pending": {}}, "training_points": {1: 170}, "points_limit": 180,
		"roster_validation": {"armies": {1: {"total": 170, "points_limit": 180, "breakdown": [{"definition_id": "40kdc:11e:adeptus-astartes:redemptor-dreadnought", "total": 170, "wargear_cost": 0}]}}}}
	var choices := UnitActions.choices(setup, 1)
	var macro_choice: Dictionary = {}
	var iCarus_choice: Dictionary = {}
	for option: Dictionary in choices:
		if option.action == "redemptor-main" and option.value == "macro-plasma": macro_choice = option
		if option.action == "redemptor-icarus" and option.value == "on": iCarus_choice = option
	check(not macro_choice.is_empty() and not iCarus_choice.is_empty(), "Deployment preparation presents the source-listed Redemptor replacements")
	var too_expensive: Dictionary = setup.duplicate(true)
	too_expensive.training_points[1] = 175
	too_expensive.points_limit = 175
	var rejected := PublicUnitCommand.submit(too_expensive, 1, macro_choice, Vector2.ZERO, roll_die)
	check(not rejected.get("error", "").is_empty() and too_expensive.units[100].ranged_weapons[2].id == "heavy-onslaught-gatling-cannon", "A Macro Plasma choice that exceeds the roster points limit is rejected")
	var macro_result := PublicUnitCommand.submit(setup, 1, macro_choice, Vector2.ZERO, roll_die)
	var pod_result := PublicUnitCommand.submit(setup, 1, iCarus_choice, Vector2.ZERO, roll_die)
	check(macro_result.error.is_empty() and pod_result.error.is_empty() and setup.units[100].ranged_weapons.size() == 4 and setup.units[100].ranged_weapons[2].id == "macro-plasma-incinerator", "Legal setup choices equip the Macro Plasma and Icarus pod")
	check(setup.training_points[1] == 180 and setup.squads[1].training_cost == 180 and setup.roster_validation.armies[1].total == 180 and setup.roster_validation.armies[1].breakdown[0].wargear_cost == 10, "The paid Macro Plasma option updates both training and admitted roster points")
	var setup_choices := UnitActions.choices(setup, 1)
	var storm_bolters_choice: Dictionary = {}
	var onslaught_choice: Dictionary = {}
	for option: Dictionary in setup_choices:
		if option.action == "redemptor-fragstorm" and option.value == "storm-bolters": storm_bolters_choice = option
		if option.action == "redemptor-auxiliary" and option.value == "onslaught": onslaught_choice = option
	var storm_result := PublicUnitCommand.submit(setup, 1, storm_bolters_choice, Vector2.ZERO, roll_die) if not storm_bolters_choice.is_empty() else {"error": "missing Storm Bolters choice"}
	var gatling_result := PublicUnitCommand.submit(setup, 1, onslaught_choice, Vector2.ZERO, roll_die) if not onslaught_choice.is_empty() else {"error": "missing Onslaught choice"}
	check(storm_result.error.is_empty() and gatling_result.error.is_empty() and setup.units[100].ranged_weapons[0].id == "storm-bolters" and setup.units[100].ranged_weapons[1].id == "onslaught-gatling-cannon", "The remaining independent replacement options update the equipped weapons")
	print("Redemptor Dreadnought checks: %d failures" % failures)
	quit(0 if failures == 0 else 1)

func _initialize() -> void:
	call_deferred("run")
