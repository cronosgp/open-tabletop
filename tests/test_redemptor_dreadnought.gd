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

func selection(copies: int = 1, category: String = "incursion") -> Dictionary:
	return {"schema_version": 2, "faction": "Space Marines", "category": category, "points_limit": 2000 if category == "strike_force" else 1000,
		"entries": [{"definition_id": "40kdc:11e:adeptus-astartes:redemptor-dreadnought", "models": 1, "copies": copies}]}

func run() -> void:
	var profile := Profiles.profile("redemptor-dreadnought")
	check(profile.source_book_id == "000000139" and profile.source_datasheet_id == "000002717" and profile.source_export_updated_at == "2026-10-16T21:03:46+03:00", "Redemptor profile cites the correct local Space Marines export")
	check(profile.points_by_models == {1: 170} and profile.third_plus_points_by_models == {1: 190} and profile.wargear_costs == {"macro-plasma-incinerator": 10}, "First, second, third-plus and Macro Plasma costs match the extraction")
	check(profile.stats == {"movement_inches": 8, "toughness": 10, "save_target": 2, "wounds": 12, "leadership_target": 6, "objective_control": 4, "invulnerable_target": 0} and profile.damaged_threshold == 4 and profile.base_radius_inches == 45.0 / 25.4, "Characteristics, Damaged 4 and 90 mm base match the sheet")
	check(profile.ranged.size() == 3 and profile.ranged[0].profiles.standard.name == "Fragstorm Grenade Launchers" and profile.ranged[1].profiles.standard.name == "Heavy Flamer" and profile.ranged[1].profiles.standard.skill == null and profile.ranged[2].profiles.standard.name == "Heavy Onslaught Gatling Cannon" and profile.melee[0].profiles.standard.name == "Redemptor Fist", "All default Redemptor weapons match the source, including the Torrent weapon's absent BS")
	check(profile.ranged[0].profiles.standard.keywords.blast == 2 and profile.ranged[1].profiles.standard.keywords.torrent and profile.ranged[2].profiles.standard.keywords == {"devastating-wounds": true, "sustained-hits": 2} and profile.ranged[2].profiles.standard.target_restricted_traits == {"devastating-wounds": ["MONSTER", "VEHICLE"], "sustained-hits": ["MONSTER", "VEHICLE"]}, "Default weapon traits include source target restrictions")
	var replacements := Profiles.redemptor_weapons(false, false, true, true)
	check(replacements.size() == 4 and replacements[0].id == "storm-bolters" and replacements[1].id == "onslaught-gatling-cannon" and replacements[2].profiles.standard.strength == 9 and replacements[2].profiles.supercharge.keywords.hazardous and replacements[3].profiles.standard.keywords["anti-fly"] == 2 and Profiles.profile("redemptor-dreadnought").additional_weapon_profiles.heavy_flamer.profiles.standard.skill == null, "All optional weapon replacements, the Icarus pod, and the Heavy Flamer's absent BS are transcribed")
	var admitted := Army.admit(selection())
	check(admitted.error.is_empty() and admitted.total == 170, "Redemptor enters local construction at the extracted first/second cost")
	var three := Army.admit(selection(3, "strike_force"))
	check(three.error.is_empty() and three.total == 530, "Third Redemptor copy uses the extracted 190-point price in Strike Force")
	var four := Army.admit(selection(4, "strike_force"))
	check(not four.error.is_empty(), "The fourth Redemptor copy is rejected by the Strike Force three-copy limit")
	var wounded := {"unit_abilities": {"implementation": Abilities.ID}, "units": {
		100: {"definition_id": "40kdc:11e:adeptus-astartes:redemptor-dreadnought", "wounds": 5},
		101: {"definition_id": "40kdc:11e:adeptus-astartes:redemptor-dreadnought", "wounds": 4},
		102: {"definition_id": "40kdc:11e:adeptus-astartes:captain", "wounds": 4}}}
	check(Abilities.damaged_attack_penalty(wounded, 100) == 0 and Abilities.damaged_attack_penalty(wounded, 101) == -1 and Abilities.damaged_attack_penalty(wounded, 102) == 0, "Damaged 4 applies to Redemptor attacks only at 1–4 remaining wounds")
	var defense := {"turn": 1, "round": 1, "phase": "shooting", "active": 1, "unit_abilities": {"implementation": Abilities.ID, "window": {}, "used": {}}, "units": {
		100: {"definition_id": "40kdc:11e:adeptus-astartes:redemptor-dreadnought", "squad": 1, "owner": 1, "wounds": 12, "max_wounds": 12, "keywords": ["VEHICLE"]},
		200: {"definition_id": "fixture:enemy", "squad": 2, "owner": 2, "wounds": 1, "max_wounds": 1, "keywords": ["INFANTRY"]}}, "squads": {1: {"owner": 1, "name": "Redemptor"}, 2: {"owner": 2, "name": "Enemy"}}}
	check(Abilities.defensive_wound_modifier(defense, 1, 11, 10) == -1 and Abilities.defensive_wound_modifier(defense, 1, 10, 10) == 0, "Duty Eternal subtracts 1 only when attacking Strength exceeds Toughness")
	var battle_selections := F.current_marine_selections()
	battle_selections[1].entries = [
		{"definition_id": "40kdc:11e:adeptus-astartes:redemptor-dreadnought", "models": 1, "copies": 1},
		{"definition_id": "40kdc:11e:adeptus-astartes:intercessor-squad", "models": 5, "copies": 1}]
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
			check("DEATHWING" not in battle.units[redemptor_model].keywords, "The export-projected Deathwing keyword is removed outside Dark Angels context")
			battle.phase = "shooting"
			battle.active = 2
			battle.mission.stage = "battle"
			battle.deployment.complete = true
			battle.terrain.areas = []
			battle.awakened_dynasty.pending = []
			battle.board_size = Vector2(43, 44)
			for model: int in battle.units:
				if model != shooter_model and model != redemptor_model: battle.units[model].wounds = 0
			battle.units[shooter_model].position = Vector2.ZERO
			battle.units[redemptor_model].position = Vector2(10.0, 0.0)
			battle.units[shooter_model].ranged_weapons = [{"id": "duty-test-cannon", "profiles": {"standard": {"name": "Test Cannon", "range_inches": 48.0, "attacks": 1, "skill": 3, "strength": 12, "ap": -1, "damage": 1, "keywords": {}}}}]
			battle.phase = "command"
			battle.active = 1
			var doctrine_error := F.C.select_combat_doctrine(battle, 1, "devastator", battle.revision)
			check(doctrine_error.is_empty() and F.C.Doctrines.has_doctrine(battle, redemptor_squad, "devastator"), "The Redemptor participates in its army's Combat Doctrines selection")
			battle.phase = "shooting"
			battle.units[redemptor_model].ranged_weapons = Profiles.redemptor_weapons()
			battle.squads[redemptor_squad].advanced = true
			var doctrine_plan := F.C.AttackPlan.prepare(battle, redemptor_squad, false, [{"model": redemptor_model, "target": shooter_squad, "amount": 1, "weapon": "heavy-flamer", "profile": "standard"}], true)
			check(doctrine_plan.get("error", "").is_empty() and doctrine_plan.get("batches", []).size() == 1, "The Redemptor's Devastator Doctrine Assault keyword keeps Heavy Flamer shooting eligible after Advance")
			battle.squads[redemptor_squad].advanced = false
			var duty_plan := F.C.AttackPlan.prepare(battle, shooter_squad, false, [{"model": shooter_model, "target": redemptor_squad, "amount": 1, "weapon": "duty-test-cannon", "profile": "standard"}], true)
			check(duty_plan.get("error", "").is_empty() and duty_plan.get("batches", []).size() == 1 and duty_plan.batches[0].context.wound_modifier == -1, "Duty Eternal modifies the actual attack plan against the Redemptor: %s (shooter %d / target %d; legal targets %s)" % [str(duty_plan.get("error", "")), shooter_squad, redemptor_squad, str(F.C.AttackPlan.legal_targets(battle, shooter_model, false, "duty-test-cannon", "standard"))])
			battle.active = 1
			battle.units[redemptor_model].wounds = 4
			var damaged_plan := F.C.AttackPlan.prepare(battle, redemptor_squad, false, [{"model": redemptor_model, "target": shooter_squad, "amount": 1, "weapon": "fragstorm-grenade-launchers", "profile": "standard"}], true)
			check(damaged_plan.get("error", "").is_empty() and damaged_plan.batches.size() == 1 and damaged_plan.batches[0].context.hit_modifier == -1, "Damaged 4 enters the Redemptor's actual shooting attack plan")
			battle.units[redemptor_model].wounds = 12
			var expected_profiles := {
				"fragstorm-grenade-launchers:standard": {"strength": 4, "skill": 3, "ap": -1, "damage": 1, "hazardous": false},
				"storm-bolters:standard": {"strength": 5, "skill": 3, "ap": -1, "damage": 1, "hazardous": false},
				"heavy-flamer:standard": {"strength": 5, "skill": null, "ap": -1, "damage": 1, "hazardous": false},
				"onslaught-gatling-cannon:standard": {"strength": 5, "skill": 3, "ap": -1, "damage": 1, "hazardous": false},
				"heavy-onslaught-gatling-cannon:standard": {"strength": 6, "skill": 3, "ap": -1, "damage": 1, "hazardous": false},
				"macro-plasma-incinerator:standard": {"strength": 9, "skill": 3, "ap": -3, "damage": 2, "hazardous": false},
				"macro-plasma-incinerator:supercharge": {"strength": 10, "skill": 3, "ap": -4, "damage": 3, "hazardous": true},
				"icarus-rocket-pod:standard": {"strength": 6, "skill": 3, "ap": -1, "damage": 2, "hazardous": false}
			}
			var package_profile_checks := 0
			for combination in range(16):
				var package := Profiles.redemptor_weapons((combination & 1) == 0, (combination & 2) == 0, (combination & 4) != 0, (combination & 8) != 0)
				battle.units[redemptor_model].ranged_weapons = package
				for weapon: Dictionary in package:
					for profile_id: String in weapon.profiles:
						var expectation: Dictionary = expected_profiles.get("%s:%s" % [weapon.id, profile_id], {})
						var attack_plan := F.C.AttackPlan.prepare(battle, redemptor_squad, false, [{"model": redemptor_model, "target": shooter_squad, "amount": 1, "weapon": weapon.id, "profile": profile_id}], true)
						var valid_plan: bool = attack_plan.get("error", "").is_empty() and attack_plan.get("batches", []).size() == 1
						var batch: Dictionary = attack_plan.batches[0] if valid_plan else {}
						check(not expectation.is_empty() and valid_plan and batch.weapon.strength == expectation.strength and batch.weapon.skill == expectation.skill and batch.weapon.ap == expectation.ap and batch.weapon.damage == expectation.damage, "Every Redemptor loadout/profile routes source stats into AttackPlan (%s:%s): %s" % [weapon.id, profile_id, str(attack_plan.get("error", ""))])
						check(int(attack_plan.get("hazardous_count", 0)) == (1 if expectation.get("hazardous", false) else 0), "AttackPlan retains Hazardous only for the supercharged Macro Plasma profile (%s:%s)" % [weapon.id, profile_id])
						package_profile_checks += 1
			check(package_profile_checks == 64, "All 16 legal independent Redemptor weapon packages expose their source profiles through AttackPlan")
			battle.units[redemptor_model].ranged_weapons = Profiles.redemptor_weapons(true, true, true, false)
			var both_plasma_modes := F.C.AttackPlan.prepare(battle, redemptor_squad, false, [
				{"model": redemptor_model, "target": shooter_squad, "amount": 1, "weapon": "macro-plasma-incinerator", "profile": "standard"},
				{"model": redemptor_model, "target": shooter_squad, "amount": 1, "weapon": "macro-plasma-incinerator", "profile": "supercharge"}], true)
			check(not both_plasma_modes.get("error", "").is_empty(), "One Macro Plasma Incinerator cannot select Standard and Supercharge in the same attack plan")
			var target_keywords: Array = battle.units[shooter_model].keywords.duplicate()
			battle.units[redemptor_model].ranged_weapons = Profiles.redemptor_weapons()
			for restricted_keyword: String in ["MONSTER", "VEHICLE"]:
				battle.units[shooter_model].keywords = target_keywords.duplicate()
				battle.units[shooter_model].keywords.append(restricted_keyword)
				var restricted_plan := F.C.AttackPlan.prepare(battle, redemptor_squad, false, [{"model": redemptor_model, "target": shooter_squad, "amount": 1, "weapon": "heavy-onslaught-gatling-cannon", "profile": "standard"}], true)
				var conditional_plan_valid: bool = restricted_plan.get("error", "").is_empty() and restricted_plan.get("batches", []).size() == 1
				if conditional_plan_valid:
					var restricted_keywords: Dictionary = restricted_plan.batches[0].weapon.keywords
					check(not restricted_keywords.has("devastating-wounds") and not restricted_keywords.has("sustained-hits"), "Heavy Onslaught conditional traits are absent in AttackPlan against %s" % restricted_keyword)
				else: check(false, "The Redemptor Heavy Onslaught remains targetable against %s: %s" % [restricted_keyword, str(restricted_plan.get("error", ""))])
			battle.units[shooter_model].keywords = target_keywords
			battle.phase = "fight"
			battle.units[shooter_model].position = Vector2.ZERO
			battle.units[redemptor_model].position = Vector2(2.5, 0.0)
			var fist_plan := F.C.AttackPlan.prepare(battle, redemptor_squad, true, [{"model": redemptor_model, "target": shooter_squad, "amount": 5, "weapon": "redemptor-fist", "profile": "standard"}], true)
			check(fist_plan.get("error", "").is_empty() and fist_plan.get("batches", []).size() == 1 and fist_plan.batches[0].weapon.strength == 12 and fist_plan.batches[0].weapon.ap == -3 and fist_plan.batches[0].weapon.damage == "D3+3", "Redemptor Fist routes all five attacks through the legal Fight-phase AttackPlan")
			battle.phase = "shooting"
			battle.active = 2
			battle.units[redemptor_model].position = Vector2(5.0, 0.0)
			battle.units[redemptor_model].wounds = 1
			for model: int in F.C.living(battle, shooter_squad):
				battle.units[model].position = Vector2(float(model - shooter_model) * 0.2, 0.0)
			var shooter_wounds_before := int(battle.units[shooter_model].wounds)
			var lethal_attack := [{"model": shooter_model, "target": redemptor_squad, "amount": 1, "weapon": "duty-test-cannon", "profile": "standard"}]
			dice = [6, 6, 1, 6, 1]
			var lethal_result := F.C.resolve_attack_plan(battle, 2, shooter_model, lethal_attack, battle.revision, false, true, roll_die)
			if lethal_result.get("error", "").is_empty() and not battle.pending_attack.is_empty():
				var destroy_error := F.C.allocate_damage(battle, 1, redemptor_model, battle.revision, roll_die)
				check(destroy_error.is_empty(), "Destroying the Redemptor in a live Shooting attack enters its destruction sequence")
			check(lethal_result.get("error", "").is_empty() and battle.units[redemptor_model].wounds == 0 and not battle.pending_attack.is_empty() and not battle.pending_deadly_demise.is_empty(), "A destroyed Redemptor suspends the attack for its actual Deadly Demise packet")
			if not battle.pending_deadly_demise.is_empty():
				var packet: Dictionary = battle.pending_deadly_demise.packets[battle.pending_deadly_demise.packet_cursor]
				var demise_choices := F.C.unit_choices(battle, 2)
				check(packet.get("roll", {}).get("expression", "") == "D3" and int(packet.target) == shooter_squad and int(packet.owner) == 2 and int(packet.remaining) == 1 and demise_choices.size() == 1 and demise_choices[0].action == "deadly-demise-allocate", "Redemptor's 6-triggered Deadly Demise D3 reaches its nearby enemy through owner-allocated mortal wounds: %s; choices=%s" % [str(packet), str(demise_choices)])
				var before_wrong_owner := var_to_bytes(battle)
				var wrong_owner_result := PublicUnitCommand.submit(battle, 1, demise_choices[0], Vector2.ZERO, roll_die)
				check(not str(wrong_owner_result.get("error", "")).is_empty() and var_to_bytes(battle) == before_wrong_owner, "The Redemptor Deadly Demise allocation rejects the wrong player without state mutation")
				var allocation_result := PublicUnitCommand.submit(battle, 2, demise_choices[0], Vector2.ZERO, roll_die)
				check(str(allocation_result.get("error", "")).is_empty() and battle.pending_deadly_demise.is_empty() and battle.pending_attack.is_empty() and int(battle.units[shooter_model].wounds) == shooter_wounds_before - 1 and battle.last_deadly_demise.events[0].triggered, "Public Deadly Demise allocation finishes the Redemptor's attack and applies one mortal wound")
		else: check(false, "Battle fixture exposes both a Redemptor and a shooting model")
	var dark_angles_selections := F.current_marine_selections()
	dark_angles_selections[1].entries = [{"definition_id": "40kdc:11e:adeptus-astartes:redemptor-dreadnought", "models": 1, "copies": 1}]
	var dark_angles_battle := F.P.initial_state({"unit_abilities": true, "combat_doctrines": true, "marine_chapters": {1: "DARK ANGELS"}}, dark_angles_selections)
	var dark_angles_redemptor := -1
	for model: int in dark_angles_battle.get("units", {}):
		if Abilities.identity(dark_angles_battle.units[model]) == "redemptor-dreadnought": dark_angles_redemptor = model
	check(not dark_angles_battle.has("error") and dark_angles_redemptor >= 0 and "DEATHWING" in dark_angles_battle.units[dark_angles_redemptor].keywords, "Dark Angels chapter context restores the Redemptor's conditional Deathwing keyword")
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
