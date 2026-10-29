extends SceneTree
const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Catalog = preload("res://scripts/edition_11/army_capabilities.gd")
const Roster = preload("res://scripts/edition_11/roster_validation.gd")
const Groups = preload("res://scripts/edition_11/defender_groups.gd")
const Equipment = preload("res://scripts/edition_11/equipment.gd")
const MatchCommands = preload("res://scripts/edition_11/match_command_service.gd")
const PublicUnitCommand = preload("res://tests/public_unit_command.gd")
var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func find_model(state: Dictionary, owner: int, identity: String) -> int:
	for model: int in state.units:
		if state.units[model].owner == owner and C.UnitAbilities.identity(state.units[model]) == identity: return model
	return -1

func find_squad(state: Dictionary, owner: int, identity: String, models: int = -1) -> int:
	var candidates: Dictionary = {}
	for model: int in state.units:
		if state.units[model].owner == owner and C.UnitAbilities.identity(state.units[model]) == identity:
			candidates[int(state.units[model].squad)] = true
	for candidate: int in candidates:
		if models < 0 or C.living(state, candidate).size() == models: return candidate
	return -1

func find_choice(state: Dictionary, player: int, action: String, model: int, value: String) -> Dictionary:
	for option: Dictionary in C.UnitActions.choices(state, player):
		if option.action == action and option.model == model and option.value == value: return option
	return {}

func apply_choice(state: Dictionary, player: int, action: String, model: int, value: String) -> String:
	var option := find_choice(state, player, action, model, value)
	if option.is_empty(): return "Choice not offered: %s=%s" % [action, value]
	var result: Dictionary = PublicUnitCommand.submit(state, player, option, Vector2.ZERO, func() -> int: return 6)
	return str(result.get("error", ""))

func choices_for(state: Dictionary, player: int, action: String, model: int) -> Array[String]:
	var values: Array[String] = []
	for option: Dictionary in C.UnitActions.choices(state, player):
		if option.action == action and option.model == model: values.append(str(option.value))
	return values

func current_marine_selections() -> Dictionary:
	var result := F.current_marine_selections()
	result[1].entries.append({"definition_id": "40kdc:11e:adeptus-astartes:lieutenant", "models": 1, "copies": 1})
	result[1].entries.append({"definition_id": "40kdc:11e:adeptus-astartes:heavy-intercessor-squad", "models": 5, "copies": 1})
	return result

func fresh() -> Dictionary:
	return F.P.initial_state({"unit_abilities": true, "reanimation_protocols": true, "combat_doctrines": true, "awakened_dynasty": true, "core_stratagems": true, "attack_rerolls": true, "manual_allocation": false}, current_marine_selections())

func place_attack_board(state: Dictionary, model: int, target: int, melee: bool) -> void:
	state.terrain.areas = []
	for candidate: int in state.units:
		state.units[candidate].position = Vector2(-20, -15) if state.units[candidate].owner == 1 else Vector2(20, 15)
	state.units[model].position = Vector2.ZERO
	var target_models: Array[int] = C.living(state, target)
	for index: int in range(target_models.size()):
		state.units[target_models[index]].position = Vector2(1.8 if melee else 5.0, index * 2.5)

func check_attack_profile(state: Dictionary, model: int, squad: int, target: int, melee: bool, weapon_id: String, profile_id: String) -> void:
	var selected := Equipment.select(state, model, melee, weapon_id, profile_id)
	check(not selected.has("error"), "Equipped Lieutenant exposes %s/%s to AttackPlan" % [weapon_id, profile_id])
	if selected.has("error"): return
	var previous_phase: String = str(state.phase)
	var previous_active: int = int(state.active)
	var previous_fight_actor: int = int(state.get("fight_actor", -1))
	var previous_fight_step: String = str(state.get("fight_step", ""))
	place_attack_board(state, model, target, melee)
	state.phase = "fight" if melee else "shooting"
	state.active = 1
	state.fight_actor = 1
	state.fight_step = "attacks"
	var amount := int(selected.stats.attacks) if melee else 1
	var plan: Dictionary = C.AttackPlan.prepare(state, squad, melee, [{"model": model, "target": target, "amount": amount, "weapon": weapon_id, "profile": profile_id}], false)
	check(plan.get("error", "").is_empty(), "Lieutenant %s/%s passes the actual AttackPlan: %s" % [weapon_id, profile_id, plan.get("error", "")])
	if plan.get("error", "").is_empty() and plan.get("batches", []).size() == 1:
		var batch: Dictionary = plan.batches[0]
		var sources: Array = batch.context.get("attack_sources", [])
		check(not sources.is_empty() and sources[0].weapon == weapon_id, "AttackPlan retains the selected Lieutenant weapon source")
		check(batch.weapon.skill == selected.stats.skill and batch.weapon.strength == selected.stats.strength and batch.weapon.ap == selected.stats.ap and batch.weapon.damage == selected.stats.damage, "AttackPlan preserves %s/%s source characteristics" % [weapon_id, profile_id])
		check(batch.weapon.keywords.get("lethal-hits", false) and batch.context.get("use_lethal_hits", false), "Tactical Precision reaches %s/%s against a non-MONSTER/non-VEHICLE unit" % [weapon_id, profile_id])
		if not melee and profile_id == "supercharge": check(plan.hazardous_count == 1, "Plasma Pistol supercharge reaches the hazardous attack declaration")
	state.phase = previous_phase
	state.active = previous_active
	state.fight_actor = previous_fight_actor
	state.fight_step = previous_fight_step

func pass_initial_doctrine(state: Dictionary, player: int) -> String:
	var decision := C.Doctrines.pending_decision(state)
	for option: Dictionary in decision.get("legal_options", []):
		if str(option.get("value", "")) != "none": continue
		var result: Dictionary = MatchCommands.execute(state, player, {"kind": MatchCommands.SELECT_DOCTRINE, "doctrine": "none", "decision_id": str(decision.get("decision_id", "")), "option_id": str(option.get("id", "")), "revision": int(state.revision)})
		return str(result.get("error", ""))
	return "No projected no-doctrine option."

func _initialize() -> void: call_deferred("run")

func run() -> void:
	var profile := Profiles.profile("lieutenant")
	check(profile.source_book_id == "000000139" and profile.source_datasheet_id == "000001346" and profile.source_export_updated_at == "2026-10-16T21:03:46+03:00", "Lieutenant identity follows the local Wahapedia e11 export")
	check(profile.points_by_models == {1: 50} and profile.base_size_source_mm == 40, "Lieutenant cost and base match the source")
	check(profile.stats == {"movement_inches": 6, "toughness": 5, "save_target": 3, "wounds": 4, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 0}, "Lieutenant characteristics match the source")
	check(profile.keywords.has("ADEPTUS ASTARTES") and profile.keywords.has("TACTICUS") and profile.keywords.has("EXPLOSIVES"), "Lieutenant source keywords are present")
	check(Catalog.SPECS.get("lieutenant", {}).get("current_reference", false) and Roster.POINTS.get("lieutenant", {}).get("sizes", {}) == {1: 50}, "Lieutenant uses the current local price authority")
	var catalog_row := Catalog.current_catalog_choice({"id": "40kdc:11e:adeptus-astartes:lieutenant", "edition": "11e", "faction": "Space Marines", "options": [{"models": 1, "cost": 50}]})
	check(catalog_row.get("id", "") == "40kdc:11e:adeptus-astartes:lieutenant" and catalog_row.get("options", []).size() == 1 and catalog_row.options[0].cost == 50, "Lieutenant enters the consolidated current construction catalog")
	var package_options: Array[String] = ["default", "heavy-bolt-pistol", "power-weapon", "heavy-pistol-power-weapon", "plasma-pistol", "heavy-pistol-plasma-pistol", "power-fist", "heavy-pistol-power-fist", "neo-volkite"]
	var fists_options: Array[String] = ["ceramite-fists", "power-weapon", "power-fist"]
	check(profile.options.ranged_packages == package_options and profile.options.fists_replacements == fists_options and profile.options.storm_shield_requires == "neo-volkite", "All five Wahapedia option rows normalize to nine ranged packages, three fists states and the Neo-volkite shield condition")
	check(Profiles.lieutenant_weapons("default", "ceramite-fists", true).is_empty() and Profiles.lieutenant_weapons("heavy-pistol-plasma-pistol", "power-fist", true).is_empty(), "Storm Shield combinations outside Neo-volkite are rejected")
	var state: Dictionary = fresh()
	check(not state.has("error"), "Prepared match initializes from current Space Marines catalogs without the legacy starter snapshot")
	if state.has("error"):
		print(state.error)
		quit(1)
		return
	state.awakened_dynasty.pending.clear()
	var model := find_model(state, 1, "lieutenant")
	var squad: int = state.units[model].squad if model >= 0 else -1
	var target := find_squad(state, 2, "intercessor-squad", 10)
	check(model >= 0 and target >= 0, "Current-catalog match contains the Lieutenant and a ten-model enemy Intercessor unit")
	if model < 0 or target < 0:
		print("Lieutenant local checks: %d failures" % failures)
		quit(1)
		return
	var initial_profile_cost: int = int(state.training_points[1])
	var unsupported := {"action": "lieutenant-ranged-loadout", "model": model, "target": squad, "value": "invented-package"}
	var before_unsupported := var_to_bytes(state)
	var unsupported_result := PublicUnitCommand.submit(state, 1, unsupported)
	check(not str(unsupported_result.get("error", "")).is_empty() and before_unsupported == var_to_bytes(state), "Unsupported Lieutenant equipment is rejected without state mutation")
	var shield_without_package := {"action": "lieutenant-storm-shield", "model": model, "target": squad, "value": "on"}
	var before_shield := var_to_bytes(state)
	var shield_result := PublicUnitCommand.submit(state, 1, shield_without_package)
	check(not str(shield_result.get("error", "")).is_empty() and before_shield == var_to_bytes(state), "Storm Shield cannot be submitted before selecting Neo-volkite")
	check(C.UnitAbilities.has(state, squad, "support") and C.UnitAbilities.has(state, squad, "combat-doctrines") and C.UnitAbilities.has(state, squad, "tactical-precision") and C.UnitAbilities.has(state, squad, "demi-company-commander"), "Lieutenant Support, Combat Doctrines and both datasheet abilities are registered")
	check(choices_for(state, 1, "lieutenant-ranged-loadout", model) == package_options.slice(1), "Army preparation offers every non-default source ranged package")
	check(choices_for(state, 1, "lieutenant-melee-loadout", model) == ["power-weapon", "power-fist"] and choices_for(state, 1, "lieutenant-storm-shield", model).is_empty(), "Preparation exposes both independent Ceramite Fists replacements and no premature shield")
	var planned_ranged: Dictionary = {}
	var planned_melee: Dictionary = {}
	for package: String in package_options:
		var current_package := str(state.units[model].get("lieutenant_weapon_package", "default"))
		if current_package != package:
			var available_packages: Array[String] = []
			for candidate: String in package_options:
				if candidate != current_package: available_packages.append(candidate)
			check(choices_for(state, 1, "lieutenant-ranged-loadout", model) == available_packages, "Preparation presents all and only other source ranged packages from %s" % current_package)
			check(apply_choice(state, 1, "lieutenant-ranged-loadout", model, package).is_empty(), "Source ranged package is selectable: " + package)
		for fists_choice: String in fists_options:
			var current_fists := str(state.units[model].get("lieutenant_fists_replacement", "ceramite-fists"))
			if current_fists != fists_choice:
				var available_fists: Array[String] = []
				for candidate: String in fists_options:
					if candidate != current_fists: available_fists.append(candidate)
				check(choices_for(state, 1, "lieutenant-melee-loadout", model) == available_fists, "Preparation presents every other Ceramite Fists replacement")
				check(apply_choice(state, 1, "lieutenant-melee-loadout", model, fists_choice).is_empty(), "Ceramite Fists replacement is selectable: " + fists_choice)
			var shield_modes: Array[bool] = [false]
			if package == "neo-volkite": shield_modes.append(true)
			for shield_enabled: bool in shield_modes:
				var current_shield := bool(state.units[model].get("lieutenant_storm_shield", false))
				if package == "neo-volkite":
					var expected_shield_choices: Array[String] = ["off" if current_shield else "on"]
					check(choices_for(state, 1, "lieutenant-storm-shield", model) == expected_shield_choices, "Neo-volkite alone offers the current Storm Shield toggle")
					if current_shield != shield_enabled:
						check(apply_choice(state, 1, "lieutenant-storm-shield", model, "on" if shield_enabled else "off").is_empty(), "Storm Shield toggle resolves through preparation")
				else:
					check(choices_for(state, 1, "lieutenant-storm-shield", model).is_empty() and not current_shield, "Other ranged packages neither offer nor retain Storm Shield")
				var expected_weapons := Profiles.lieutenant_weapons(package, fists_choice, shield_enabled)
				check(not expected_weapons.is_empty() and state.units[model].ranged_weapons == expected_weapons.ranged and state.units[model].melee_weapons == expected_weapons.melee, "Materialized Lieutenant weapons match package %s / fists %s / shield %s" % [package, fists_choice, str(shield_enabled)])
				check(int(state.training_points[1]) == initial_profile_cost, "Wargear option changes do not alter the Lieutenant's 50-point roster cost")
				var defense := Groups.profile(state, model)
				check(defense.error.is_empty() and defense.invulnerable_target == (4 if shield_enabled else 0) and C.UnitAbilities.has(state, squad, "storm-shield") == shield_enabled, "Only an equipped Storm Shield grants this model a 4+ invulnerable save")
				for weapon_choice: Dictionary in Equipment.choices(state, model, false):
					var attack_key := "%s:%s" % [weapon_choice.weapon, weapon_choice.profile]
					if not planned_ranged.has(attack_key):
						check_attack_profile(state, model, squad, target, false, str(weapon_choice.weapon), str(weapon_choice.profile))
						planned_ranged[attack_key] = true
				for weapon_choice: Dictionary in Equipment.choices(state, model, true):
					var attack_key := "%s:%s" % [weapon_choice.weapon, weapon_choice.profile]
					if not planned_melee.has(attack_key):
						check_attack_profile(state, model, squad, target, true, str(weapon_choice.weapon), str(weapon_choice.profile))
						planned_melee[attack_key] = true
	check(planned_ranged.size() == 6 and planned_melee.size() == 3, "Every distinct source ranged profile and melee weapon reached AttackPlan")
	check(apply_choice(state, 1, "lieutenant-ranged-loadout", model, "default").is_empty(), "Switching away from Neo-volkite restores the default ranged package")
	check(not state.units[model].get("lieutenant_storm_shield", false) and Groups.profile(state, model).invulnerable_target == 0 and not C.UnitAbilities.has(state, squad, "storm-shield"), "Leaving Neo-volkite removes its conditional shield effect")
	check(apply_choice(state, 1, "lieutenant-ranged-loadout", model, "plasma-pistol").is_empty(), "Plasma Pistol package is selectable for profile-exclusivity check")
	place_attack_board(state, model, target, false)
	state.phase = "shooting"
	var both_plasma_modes := C.AttackPlan.prepare(state, squad, false, [{"model": model, "target": target, "amount": 1, "weapon": "plasma-pistol", "profile": "standard"}, {"model": model, "target": target, "amount": 1, "weapon": "plasma-pistol", "profile": "supercharge"}], false)
	check(not both_plasma_modes.get("error", "").is_empty(), "One Plasma Pistol cannot use both profiles in the same attack declaration")
	state.units[C.living(state, target)[0]].keywords.append("MONSTER")
	var monster_plan := C.AttackPlan.prepare(state, squad, false, [{"model": model, "target": target, "amount": 1, "weapon": "bolt-pistol", "profile": "standard"}], false)
	check(monster_plan.get("error", "").is_empty() and not monster_plan.batches[0].weapon.keywords.get("lethal-hits", false), "Tactical Precision excludes MONSTER targets in an actual attack plan")
	state.units[C.living(state, target)[0]].keywords.erase("MONSTER")
	state.units[C.living(state, target)[0]].keywords.append("VEHICLE")
	var vehicle_plan := C.AttackPlan.prepare(state, squad, false, [{"model": model, "target": target, "amount": 1, "weapon": "bolt-pistol", "profile": "standard"}], false)
	check(vehicle_plan.get("error", "").is_empty() and not vehicle_plan.batches[0].weapon.keywords.get("lethal-hits", false), "Tactical Precision excludes VEHICLE targets in an actual attack plan")
	var ability_state: Dictionary = fresh()
	ability_state.awakened_dynasty.pending.clear()
	var lieutenant: int = find_model(ability_state, 1, "lieutenant")
	var captain: int = find_model(ability_state, 1, "captain")
	var lieutenant_bodyguard: int = find_squad(ability_state, 1, "intercessor-squad", 10)
	var captain_bodyguard: int = find_squad(ability_state, 1, "intercessor-squad", 5)
	var unsupported_bodyguard: int = find_squad(ability_state, 1, "heavy-intercessor-squad", 5)
	check(lieutenant >= 0 and captain >= 0 and lieutenant_bodyguard >= 0 and captain_bodyguard >= 0 and unsupported_bodyguard >= 0, "Prepared force contains a Captain, Lieutenant and source-allowed and disallowed bodyguards")
	if lieutenant >= 0 and captain >= 0 and lieutenant_bodyguard >= 0 and captain_bodyguard >= 0 and unsupported_bodyguard >= 0:
		check(C.UnitActions.attachment_allowed(ability_state, lieutenant, lieutenant_bodyguard) and not C.UnitActions.attachment_allowed(ability_state, lieutenant, unsupported_bodyguard), "Lieutenant Support admits Intercessors and rejects an unlisted Heavy Intercessor target")
		C.UnitActions.attach(ability_state, lieutenant, lieutenant_bodyguard)
		C.UnitActions.attach(ability_state, captain, captain_bodyguard)
		ability_state.phase = "command"
		ability_state.active = 1
		ability_state.turn = 3
		ability_state.round = 2
		ability_state.unit_abilities.setup_players = [1, 2]
		ability_state.unit_abilities.phase_key = C.UnitActions.key(ability_state)
		check(ability_state.units[lieutenant].squad == lieutenant_bodyguard and ability_state.units[captain].squad == captain_bodyguard, "Publicly admitted Leader attachments materialize on their selected bodyguard units")
		check(pass_initial_doctrine(ability_state, 1).is_empty(), "Initial Combat Doctrine decision resolves through its public command")
		var acumen := find_choice(ability_state, 1, "acumen", captain, "assault")
		var acumen_result := PublicUnitCommand.submit(ability_state, 1, acumen) if not acumen.is_empty() else {"error": "Captain Strategic Acumen choice is unavailable."}
		check(str(acumen_result.get("error", "")).is_empty() and C.Doctrines.active_for(ability_state, captain_bodyguard) == "assault", "Captain Strategic Acumen activates the selected doctrine")
		var demi := find_choice(ability_state, 1, "demi", lieutenant, "assault")
		var demi_result := PublicUnitCommand.submit(ability_state, 1, demi) if not demi.is_empty() else {"error": "Demi-company Commander response is unavailable."}
		check(str(demi_result.get("error", "")).is_empty() and C.Doctrines.active_for(ability_state, lieutenant_bodyguard) == "assault", "Demi-company Commander copies the Captain's selected doctrine to the Lieutenant's attached unit")
		check(find_choice(ability_state, 1, "demi", lieutenant, "assault").is_empty(), "Demi-company Commander cannot be repeated for the same unit this turn")
	print("Lieutenant local checks: %d failures" % failures)
	quit(1 if failures else 0)
