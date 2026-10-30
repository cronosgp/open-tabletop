extends SceneTree

const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const AbilityCatalog = preload("res://scripts/edition_11/unit_ability_catalog.gd")
const Catalog = preload("res://scripts/edition_11/army_capabilities.gd")
const Roster = preload("res://scripts/edition_11/roster_validation.gd")
const LeaderLinks = preload("res://scripts/edition_11/marine_leader_links.gd")
const SupportAttachments = preload("res://scripts/edition_11/support_attachments.gd")
const WeaponChecks = preload("res://tests/space_marine_datasheet_checks.gd")
const PublicUnitCommand = preload("res://tests/public_unit_command.gd")
const UNIT := "hellblaster-squad"
const UNIT_ID := "40kdc:11e:adeptus-astartes:hellblaster-squad"

var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func entry(identity: String, models: int = 1, copies: int = 1) -> Dictionary:
	return {"definition_id": "40kdc:11e:adeptus-astartes:" + identity, "models": models, "copies": copies}

func lists() -> Dictionary:
	var result := F.current_marine_selections()
	result[1].entries = [entry("captain"), entry("apothecary"), entry("intercessor-squad", 10), entry(UNIT, 5), entry(UNIT, 10)]
	result[2].entries = [entry("intercessor-squad", 5), entry("intercessor-squad", 10), entry(UNIT, 5), entry(UNIT, 10)]
	return result

func find_squad(state: Dictionary, owner: int, identity: String, strength: int = -1) -> int:
	for model: int in state.units:
		var unit: Dictionary = state.units[model]
		if int(unit.get("owner", -1)) != owner or C.UnitAbilities.identity(unit) != identity: continue
		var squad := int(unit.get("squad", -1))
		if strength >= 0 and int(state.squads[squad].get("starting_strength", -1)) != strength: continue
		return squad
	return -1

func model_for(state: Dictionary, squad: int, sergeant: bool) -> int:
	for model: int in C.living(state, squad):
		if bool(state.units[model].get("sergeant", false)) == sergeant: return model
	return -1

func fixture() -> Dictionary:
	var state := F.P.initial_state({
		"unit_abilities": true, "combat_doctrines": true, "reanimation_protocols": true,
		"awakened_dynasty": true, "core_stratagems": false, "manual_allocation": false
	}, lists())
	if state.has("error"): return state
	state.awakened_dynasty.pending = []
	state.unit_abilities.setup_players = []
	state.unit_abilities.battle_players = [1, 2]
	state.deployment.complete = true
	state.mission.stage = "battle"
	state.phase = "deployment"
	state.active = 1
	state.turn = 1
	state.round = 1
	state.cp = {1: 3, 2: 3}
	state.unit_abilities.phase_key = C.UnitActions.key(state)
	state.unit_abilities.window = {}
	state.terrain.areas = []
	for model: int in state.units:
		state.units[model].position = Vector2(-20, -15) if state.units[model].owner == 1 else Vector2(20, 15)
	var small := find_squad(state, 1, UNIT, 5)
	for model: int in C.living(state, small): state.units[model].position = Vector2.ZERO
	var enemy := find_squad(state, 2, "intercessor-squad", 10)
	for model: int in C.living(state, enemy): state.units[model].position = Vector2(8.0, 0.0)
	return state

func find_choice(state: Dictionary, owner: int, squad: int, value: String) -> Dictionary:
	for option: Dictionary in C.unit_choices(state, owner):
		if option.get("action", "") == "hellblaster-pistol" and int(option.get("target", -1)) == squad and option.get("value", "") == value:
			return option
	return {}

func test_weapons(state: Dictionary, squad: int, target: int) -> void:
	for model: int in C.living(state, squad):
		var loadout := {"ranged": state.units[model].ranged_weapons.duplicate(true), "melee": []}
		var issues: Array[String] = WeaponChecks.fixed_weapon_plan_failures(state, loadout, model, target)
		check(issues.is_empty(), "Default weapons and every Plasma Incinerator mode resolve through Equipment and AttackPlan: %s" % str(issues))
	var attacker_positions: Dictionary = {}
	var target_positions: Dictionary = {}
	for model: int in C.living(state, squad):
		attacker_positions[model] = state.units[model].position
		state.units[model].position = Vector2.ZERO
	for model: int in C.living(state, target):
		target_positions[model] = state.units[model].position
		state.units[model].position = Vector2(1.75, 0.0) if model == C.living(state, target)[0] else Vector2(25.0, 5.0 + float(model % 7))
	state.phase = "fight"
	state.active = int(state.squads[squad].owner)
	var fist_entries: Array[Dictionary] = []
	var fists_profile: Dictionary = Profiles.profile(UNIT).melee[0].profiles.standard
	for model: int in C.living(state, squad):
		fist_entries.append({"model": model, "target": target, "amount": C.UnitAbilities.melee_attack_count(state, model, fists_profile), "weapon": "ceramite-fists", "profile": "standard"})
	var fist_plan := C.AttackPlan.prepare(state, squad, true, fist_entries, true)
	check(fist_plan.get("error", "").is_empty() and fist_plan.get("batches", []).size() == 1 and fist_plan.batches[0].weapon.get("name", "") == "Ceramite Fists", "Every model's Ceramite Fists enter a legal melee AttackPlan: %s" % str(fist_plan.get("error", "")))
	for model: int in attacker_positions: state.units[model].position = attacker_positions[model]
	for model: int in target_positions: state.units[model].position = target_positions[model]
	state.phase = "deployment"
	state.active = 1
	state.unit_abilities.phase_key = C.UnitActions.key(state)

func test_thermal_appeasement(state: Dictionary, squad: int, sergeant: int, target: int) -> void:
	state.phase = "shooting"
	state.active = 1
	state.unit_abilities.phase_key = C.UnitActions.key(state)
	var shots: Array[Dictionary] = []
	for model: int in C.living(state, squad):
		var weapon := "plasma-pistol" if model == sergeant else "plasma-incinerator"
		shots.append({"model": model, "target": target, "amount": 1, "weapon": weapon, "profile": "supercharge"})
	var plan := C.AttackPlan.prepare(state, squad, false, shots, true)
	check(plan.get("error", "").is_empty() and plan.get("hazardous_count", 0) == 5 and plan.get("hazard_modifiers", []) == [1, 1, 1, 1, 1], "Rites applies +1 to four Incinerators and the Sergeant's Plasma Pistol in one legal activation")
	check(C.UnitAbilities.hazard_modifier(state, squad, "plasma-incinerator") == 1 and C.UnitAbilities.hazard_modifier(state, squad, "plasma-pistol") == 1, "Rites applies only to its two named plasma weapons")
	check(C.UnitAbilities.hazard_modifier(state, squad, "unrelated-plasma") == 0 and C.UnitAbilities.hazard_modifier(state, find_squad(state, 1, "captain"), "plasma-incinerator") == 0, "Rites does not modify unrelated weapons or other units")
	var pistol := [{"model": sergeant, "target": target, "amount": 1, "weapon": "plasma-pistol", "profile": "supercharge"}]
	var pistol_plan := C.AttackPlan.prepare(state, squad, false, pistol, true)
	check(pistol_plan.get("error", "").is_empty() and pistol_plan.get("hazard_modifiers", []) == [1], "The Sergeant's Plasma Pistol receives the same named Hazard modifier")
	var result := C.resolve_attack_plan(state, 1, squad * 100, shots, state.revision, false, true, func() -> int: return 2)
	var hazardous: Dictionary = state.get("last_attack", {}).get("hazardous", {})
	check(result.get("error", "").is_empty() and hazardous.get("rolls", []) == [2, 2, 2, 2, 2] and hazardous.get("total", -1) == 0, "Actual Incinerator and Plasma Pistol rolls of 2 succeed with Rites: %s" % str(result))
	check(C.Hazard.from_rolls(state, squad, [1, 2], [1, 1]).total == 1 and C.Hazard.from_rolls(state, squad, [2]).total == 1, "Raw Hazard 1 still fails, while an unrelated unmodified raw 2 still fails")

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var profile: Dictionary = Profiles.profile(UNIT)
	check(profile.get("name", "") == "Hellblaster Squad" and profile.get("source_book_id", "") == "000000139" and profile.get("source_datasheet_id", "") == "000002098" and profile.get("source_export_updated_at", "") == "2026-10-16T21:03:46+03:00", "Profile matches the common-book source identity and retained export stamp")
	check(profile.get("models", -1) == 5 and profile.get("points_by_models", {}) == {5: 115, 10: 230} and profile.get("third_plus_points_by_models", {}) == {5: 130, 10: 245}, "Five/ten model compositions and both source cost tiers match the export")
	check(is_equal_approx(float(profile.get("base_radius_inches", 0.0)), 16.0 / 25.4), "All models use the exported 32 mm base")
	check(profile.get("stats", {}) == {"movement_inches": 6, "toughness": 5, "save_target": 3, "wounds": 2, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 0}, "Shared Hellblaster characteristics match the source")
	var keywords: Array = profile.get("keywords", []).duplicate()
	keywords.sort()
	check(keywords == ["ADEPTUS ASTARTES", "EXPLOSIVES", "IMPERIUM", "INFANTRY", "TACTICUS"], "All five exported keywords are represented")
	check(profile.get("ranged", []).map(func(w: Dictionary) -> String: return str(w.get("id", ""))) == ["plasma-incinerator", "bolt-pistol"] and profile.get("melee", []).map(func(w: Dictionary) -> String: return str(w.get("id", ""))) == ["ceramite-fists"], "Every model starts with the sourced Plasma Incinerator, Bolt Pistol and Ceramite Fists")
	check(profile.ranged[0].profiles.standard == {"name": "Plasma Incinerator - Standard", "range_inches": 24.0, "attacks": 2, "skill": 3, "strength": 7, "ap": -2, "damage": 2, "keywords": {"assault": true, "rapid-fire": 1}}, "Standard Incinerator profile and traits match the export")
	check(profile.ranged[0].profiles.supercharge == {"name": "Plasma Incinerator - Supercharge", "range_inches": 24.0, "attacks": 2, "skill": 3, "strength": 8, "ap": -3, "damage": 2, "keywords": {"assault": true, "rapid-fire": 1, "hazardous": true}}, "Supercharge profile and Hazardous trait match the export")
	check(profile.ranged[1].profiles.standard == {"name": "Bolt Pistol", "range_inches": 12.0, "attacks": 1, "skill": 3, "strength": 5, "ap": -1, "damage": 1, "keywords": {"close-quarters": true}}, "Fixed Bolt Pistol matches the export")
	check(profile.melee[0].profiles.standard == {"name": "Ceramite Fists", "range_inches": 0.0, "attacks": 3, "skill": 3, "strength": 5, "ap": 0, "damage": 1, "keywords": {}}, "Fixed Ceramite Fists match the export")
	var plasma_pistol := Profiles.hellblaster_pistol(true)
	check(plasma_pistol.profiles.standard == {"name": "Plasma Pistol - Standard", "range_inches": 12.0, "attacks": 1, "skill": 3, "strength": 7, "ap": -2, "damage": 1, "keywords": {"close-quarters": true}}, "Optional Plasma Pistol standard profile matches the export")
	check(plasma_pistol.profiles.supercharge == {"name": "Plasma Pistol - Supercharge", "range_inches": 12.0, "attacks": 1, "skill": 3, "strength": 8, "ap": -3, "damage": 2, "keywords": {"close-quarters": true, "hazardous": true}}, "Optional Plasma Pistol supercharge profile matches the export")
	check(AbilityCatalog.RULES.get(UNIT, []) == ["rites-of-thermal-appeasement"], "Rites of Thermal Appeasement is registered on this datasheet")

	var state := fixture()
	check(not state.has("error"), "The prepared current-catalog fixture materializes Hellblasters: %s" % str(state.get("error", "")))
	if state.has("error"):
		print("Hellblaster checks: %d failures" % (failures + 1))
		quit(1)
		return
	var small := find_squad(state, 1, UNIT, 5)
	var large := find_squad(state, 1, UNIT, 10)
	var enemy_small := find_squad(state, 2, UNIT, 5)
	var enemy_large := find_squad(state, 2, UNIT, 10)
	var target := find_squad(state, 2, "intercessor-squad", 10)
	var support := find_squad(state, 1, "apothecary")
	check(small > 0 and large > 0 and enemy_small > 0 and enemy_large > 0 and target > 0 and support > 0, "Both sourced sizes materialize on both current Marine catalogs, with an enemy target and Apothecary")
	if small < 0 or large < 0 or enemy_small < 0 or enemy_large < 0 or target < 0 or support < 0:
		print("Hellblaster checks: %d failures" % (failures + 1))
		quit(1)
		return
	check(state.squads[small].training_cost == 115 and state.squads[large].training_cost == 230 and state.squads[enemy_small].training_cost == 115 and state.squads[enemy_large].training_cost == 230 and C.living(state, large).size() == 10 and C.living(state, enemy_large).size() == 10, "Both player catalogs retain exact 5/10 model sizes and first-two copy prices")
	check(is_equal_approx(float(state.units[model_for(state, small, true)].radius), 16.0 / 25.4), "Materialized Sergeant has the source base size")
	var catalog := Catalog.current_catalog_choice({"id": UNIT_ID, "edition": "11e", "faction": "Space Marines"})
	check(catalog.get("options", []) == [{"models": 5, "cost": 115, "third_plus_cost": 130}, {"models": 10, "cost": 230, "third_plus_cost": 245}], "Consolidated catalog exposes exact sizes and both cost tiers")
	check(Roster.POINTS[UNIT].get("sizes", {}) == {5: 115, 10: 230} and Roster.POINTS[UNIT].get("third_plus_sizes", {}) == {5: 130, 10: 245}, "Roster pricing preserves both source copy tiers")
	var two_copy_roster := {"schema_version": 2, "faction": "Space Marines", "category": "incursion", "points_limit": 1000, "entries": [entry("captain"), entry(UNIT, 5), entry(UNIT, 10)]}
	var two_copy_admission := C.RosterValidation.admit(two_copy_roster)
	check(two_copy_admission.get("error", "").is_empty(), "Incursion roster admits two source-sized Hellblaster copies: %s" % str(two_copy_admission))
	two_copy_roster.entries.append(entry(UNIT, 5))
	check(not str(C.RosterValidation.admit(two_copy_roster).get("error", "")).is_empty(), "Incursion roster rejects a third non-Battleline copy")
	check(Catalog.SPECS.get(UNIT, {}).get("validation_status", "") == "source_bounded_local_scope_passed_2026_10_28" and Catalog.SPECS.get(UNIT, {}).get("max_supported_copies", 0) == 2, "Catalog marks only the checked source-bounded scope and supported Incursion copy cap")

	var source_leaders: Array[String] = []
	for leader: String in LeaderLinks.TARGETS:
		if UNIT in LeaderLinks.TARGETS[leader]: source_leaders.append(leader)
	source_leaders.sort()
	check(source_leaders == ["ancient", "apothecary", "captain", "captain-titus", "chaplain", "librarian", "lieutenant"], "All seven common-book Leader/Support relation identities are retained: %s" % str(source_leaders))
	var source_supports: Array[String] = []
	for candidate: String in SupportAttachments.BODYGUARDS:
		if UNIT in SupportAttachments.BODYGUARDS[candidate]: source_supports.append(candidate)
	source_supports.sort()
	check(source_supports == ["ancient", "apothecary", "lieutenant", "sanguinary-priest"], "All common-book and source-reviewed Chapter Supported by links are retained: %s" % str(source_supports))
	check(C.UnitActions.attachment_allowed(state, support * 100, small), "The source-linked Apothecary can attach to a Hellblaster unit")

	test_weapons(state, small, target)
	var sergeant := model_for(state, small, true)
	var ordinary := model_for(state, small, false)
	var pistol_options := C.unit_choices(state, 1).filter(func(option: Dictionary) -> bool: return option.get("action", "") == "hellblaster-pistol" and int(option.get("target", -1)) == small)
	check(pistol_options.size() == 1 and int(pistol_options[0].get("model", -1)) == sergeant and pistol_options[0].get("value", "") == "plasma", "Preparation offers the free pistol replacement only to the Sergeant (count=%d, actor=%d, phase=%s)" % [pistol_options.size(), C.UnitActions.setup_actor(state), str(state.phase)])
	if pistol_options.is_empty():
		print("Hellblaster checks: %d failures" % (failures + 1))
		quit(1)
		return
	var selected: Dictionary = pistol_options[0]
	var wrong_owner_before := var_to_bytes(state)
	check(not PublicUnitCommand.error(state, 2, selected).is_empty() and wrong_owner_before == var_to_bytes(state), "The opposing player cannot change the Hellblaster Sergeant's pistol")
	var non_sergeant_choice := selected.duplicate(true)
	non_sergeant_choice.model = ordinary
	var wrong_model_before := var_to_bytes(state)
	check(not PublicUnitCommand.error(state, 1, non_sergeant_choice).is_empty() and wrong_model_before == var_to_bytes(state), "A non-Sergeant cannot receive the pistol replacement")
	var unsupported_choice := selected.duplicate(true)
	unsupported_choice.value = "plasma-supercharge"
	var invalid_value_before := var_to_bytes(state)
	check(not PublicUnitCommand.error(state, 1, unsupported_choice).is_empty() and invalid_value_before == var_to_bytes(state), "A forged pistol value cannot mutate the roster")
	check(PublicUnitCommand.error(state, 1, selected).is_empty() and state.units[sergeant].ranged_weapons[1].id == "plasma-pistol", "Public preparation command equips the Plasma Pistol")
	var with_plasma: Dictionary = {"ranged": state.units[sergeant].ranged_weapons.duplicate(true), "melee": []}
	var plasma_issues: Array[String] = WeaponChecks.fixed_weapon_plan_failures(state, with_plasma, sergeant, target)
	check(plasma_issues.is_empty(), "Both optional Plasma Pistol profiles resolve through Equipment and AttackPlan: %s" % str(plasma_issues))
	state.phase = "shooting"
	state.unit_abilities.phase_key = C.UnitActions.key(state)
	check(C.unit_choices(state, 1).all(func(option: Dictionary) -> bool: return option.get("action", "") != "hellblaster-pistol"), "Equipment cannot be changed after setup")
	test_thermal_appeasement(state, small, sergeant, target)
	state.phase = "deployment"
	state.active = 1
	state.unit_abilities.phase_key = C.UnitActions.key(state)
	var restore := find_choice(state, 1, small, "bolt")
	check(not restore.is_empty() and PublicUnitCommand.error(state, 1, restore).is_empty() and state.units[sergeant].ranged_weapons[1].id == "bolt-pistol", "The Sergeant can publicly restore the Bolt Pistol")
	print("Hellblaster checks: %d failures" % failures)
	quit(1 if failures else 0)
