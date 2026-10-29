extends SceneTree

const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Catalog = preload("res://scripts/edition_11/army_capabilities.gd")
const AbilityCatalog = preload("res://scripts/edition_11/unit_ability_catalog.gd")
const Registry = preload("res://scripts/edition_11/capabilities.gd")
const Links = preload("res://scripts/edition_11/marine_leader_links.gd")
const Geometry = preload("res://scripts/edition_11/contact_movement.gd")
const PublicUnitCommand = preload("res://tests/public_unit_command.gd")
const DatasheetChecks = preload("res://tests/space_marine_datasheet_checks.gd")
const UNIT := "castellan"
const UNIT_ID := "40kdc:11e:adeptus-astartes:castellan"

var failures := 0

func _initialize() -> void:
	call_deferred("run")

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func entry(identity: String, models_count: int = 1) -> Dictionary:
	return {"definition_id": "40kdc:11e:adeptus-astartes:" + identity, "models": models_count, "copies": 1}

func selections() -> Dictionary:
	return {
		1: {"schema_version": 2, "faction": "Space Marines", "category": "custom", "points_limit": 1000, "entries": [entry(UNIT), entry("intercessor-squad", 5)]},
		2: {"schema_version": 2, "faction": "Space Marines", "category": "custom", "points_limit": 1000, "entries": [entry(UNIT), entry("intercessor-squad", 5)]}
	}

func fixture() -> Dictionary:
	var state: Dictionary = F.P.initial_state({
		"checked_rosters": false, "official_mission": false, "unit_abilities": true,
		"combat_doctrines": true, "core_stratagems": true, "attack_rerolls": true,
		"manual_allocation": false, "marine_chapters": {1: "BLACK TEMPLARS", 2: "BLACK TEMPLARS"}
	}, selections())
	if state.has("error"): return state
	state.phase = "deployment"
	state.active = 1
	state.turn = 1
	state.round = 1
	return state

func model_for(state: Dictionary, owner: int, identity: String) -> int:
	for model: int in state.units:
		if int(state.units[model].get("owner", -1)) == owner and C.UnitAbilities.identity(state.units[model]) == identity: return model
	return -1

func option(state: Dictionary, player: int, action: String, value: String = "", target: int = -1, model: int = -1) -> Dictionary:
	for candidate: Dictionary in C.UnitActions.choices(state, player):
		if str(candidate.get("action", "")) != action: continue
		if not value.is_empty() and str(candidate.get("value", "")) != value: continue
		if target >= 0 and int(candidate.get("target", -1)) != target: continue
		if model >= 0 and int(candidate.get("model", -1)) != model: continue
		return candidate
	return {}

func run() -> void:
	var profile := Profiles.profile(UNIT)
	check(profile.get("source_book_id") == "000000162" and profile.get("source_datasheet_id") == "000002793" and profile.get("source_snapshot_id") == "20261021T130623Z", "Castellan profile cites the pinned Black Templars App export")
	check(profile.get("source_manifest_sha256") == "169db99791a91582fd043902303e73c4af83ec63e96c01817ce52cb5ce4deccf" and profile.get("source_slice_manifest_sha256") == "8a6d9529ae553b06203cdb2b6c8f1edd736f2a737ba1c215d2241bd1cdfb5bbe", "Castellan profile records both verified manifest hashes")
	check(profile.get("points_by_models", {}) == {1: 75} and profile.get("models", 0) == 1 and profile.get("base_size_source_mm", 0) == 40, "The 75-point one-model profile and 40 mm base match the export")
	check(profile.get("stats", {}) == {"movement_inches": 6, "toughness": 5, "save_target": 3, "wounds": 4, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 0}, "Castellan characteristics match the export")
	check(profile.get("keywords", []) == ["INFANTRY", "CHARACTER", "LIEUTENANT", "EXPLOSIVES", "IMPERIUM", "TACTICUS", "ADEPTUS ASTARTES", "BLACK TEMPLARS"], "All source datasheet and faction keywords are present")
	check(profile.ranged[0].id == "combi-weapon" and profile.ranged[0].profiles.keys().size() == 3 and profile.ranged[0].profiles.has("purgatus") and profile.ranged[0].profiles.has("damnatus") and profile.ranged[0].profiles.has("infernus"), "Combi-weapon exposes the three source profiles")
	check(profile.melee[0].id == "master-crafted-power-weapon" and profile.melee[0].profiles.standard.keywords.get("lethal-hits", false), "Master-crafted Power Weapon matches the source profile")
	check(profile.options.get("ranged_packages", []) == ["combi-weapon", "heavy-bolt-pistol"] and profile.options.get("melee_packages", []) == ["master-crafted-power-weapon", "chainsword"], "The two source-listed free replacement choices are registered")
	check(Catalog.SPECS.get(UNIT, {}).get("current_reference", false) and C.RosterValidation.POINTS.get(UNIT, {}).get("cost", -1) == 75, "Current construction and point catalogs admit the Castellan at 75 points")
	check(Catalog.current_catalog_choice({"id": UNIT_ID, "edition": "11e", "faction": "Space Marines"}).get("options", []) == [{"models": 1, "cost": 75}], "The consolidated local catalog exposes the single-model profile")
	check(AbilityCatalog.RULES.get(UNIT, []).has("vehement-aggression") and Registry.KNOWN.get("vehement-aggression", {}).get("supported", false), "Vehement Aggression is registered as a supported local capability")
	check(Links.CHAPTER_TARGETS.get(UNIT, []) == ["assault-intercessor-squad", "bladeguard-veteran-squad", "company-heroes", "infernus-squad", "intercessor-squad", "sternguard-veteran-squad", "crusader-squad", "sword-brethren-squad"], "All eight source-listed Support targets are recorded")

	var state := fixture()
	if state.has("error"):
		check(false, "Both-player current-catalog Black Templars fixture materializes: %s" % str(state.get("error", "")))
	else:
		var castellan := model_for(state, 1, UNIT)
		var opponent_castellan := model_for(state, 2, UNIT)
		var friendly_squad := int(state.units[castellan].squad)
		var bodyguard := model_for(state, 1, "intercessor-squad")
		var bodyguard_squad := int(state.units[bodyguard].squad)
		var enemy_model := model_for(state, 2, "intercessor-squad")
		var enemy_squad := int(state.units[enemy_model].squad)
		check(castellan >= 0 and opponent_castellan >= 0 and bodyguard >= 0 and enemy_model >= 0, "Both players materialize current-catalog Castellans and Intercessors")
		for failure: String in DatasheetChecks.fixed_weapon_plan_failures(state, profile, castellan, enemy_squad): check(false, "Castellan default weapon plan: " + failure)
		check(C.UnitActions.attachment_allowed(state, castellan, bodyguard_squad), "Castellan can Support a source-listed Intercessor unit")
		check(not C.UnitActions.attachment_allowed(state, castellan, enemy_squad), "Castellan cannot Support an enemy unit")

		var ranged_choice := option(state, 1, "castellan-ranged-loadout", "heavy-bolt-pistol", friendly_squad, castellan)
		var melee_choice := option(state, 1, "castellan-melee-loadout", "chainsword", friendly_squad, castellan)
		check(not ranged_choice.is_empty() and not melee_choice.is_empty(), "Army preparation exposes both source-listed replacements")
		var wrong_owner_before := var_to_bytes(state)
		var wrong_owner := PublicUnitCommand.submit(state, 2, ranged_choice)
		check(not str(wrong_owner.get("error", "")).is_empty() and wrong_owner_before == var_to_bytes(state), "The opposing player cannot change the Castellan's equipment")
		var ranged_result := PublicUnitCommand.submit(state, 1, ranged_choice)
		var melee_result := PublicUnitCommand.submit(state, 1, melee_choice)
		check(ranged_result.get("error", "").is_empty() and state.units[castellan].ranged_weapons[0].id == "heavy-bolt-pistol", "The Heavy Bolt Pistol replacement is applied through the public command")
		check(melee_result.get("error", "").is_empty() and state.units[castellan].melee_weapons[0].id == "chainsword", "The Chainsword replacement is applied through the public command")
		var restore_ranged := option(state, 1, "castellan-ranged-loadout", "combi-weapon", friendly_squad, castellan)
		var restore_melee := option(state, 1, "castellan-melee-loadout", "master-crafted-power-weapon", friendly_squad, castellan)
		check(not restore_ranged.is_empty() and not restore_melee.is_empty(), "The equipment menu exposes both default loadouts for restoration")
		PublicUnitCommand.submit(state, 1, restore_ranged)
		PublicUnitCommand.submit(state, 1, restore_melee)
		check(state.units[castellan].ranged_weapons[0].id == "combi-weapon" and state.units[castellan].melee_weapons[0].id == "master-crafted-power-weapon", "Both default weapons are restored without a points change")

		var attach := option(state, 1, "attach", "", bodyguard_squad, castellan)
		var attach_result := PublicUnitCommand.submit(state, 1, attach)
		check(not attach.is_empty() and attach_result.get("error", "").is_empty() and int(state.units[castellan].squad) == bodyguard_squad, "Castellan attaches to the Intercessors through the public preparation command")
		friendly_squad = bodyguard_squad
		state.phase = "fight"
		state.fight_step = "attacks"
		state.fight_actor = 1
		state.active = 1
		state.squads[friendly_squad].charged = true
		state.units[castellan].position = Vector2.ZERO
		state.units[enemy_model].position = Vector2(1.5, 0)

		var failed_state: Dictionary = state.duplicate(true)
		var failed_choice := option(failed_state, 1, "vehement-aggression", "", friendly_squad, castellan)
		check(not failed_choice.is_empty(), "Vehement Aggression is offered when the attached Castellan's unit is selected to fight")
		var wrong_fight_before := var_to_bytes(failed_state)
		var wrong_fight := PublicUnitCommand.submit(failed_state, 2, failed_choice, Vector2.ZERO, func() -> int: return 1)
		check(not str(wrong_fight.get("error", "")).is_empty() and wrong_fight_before == var_to_bytes(failed_state), "The opponent cannot activate Vehement Aggression")
		var failed_roll := PublicUnitCommand.submit(failed_state, 1, failed_choice, Vector2.ZERO, func() -> int: return 1)
		var failed_record: Dictionary = failed_state.unit_abilities.used.get("vehement-aggression:%d" % friendly_squad, {})
		check(failed_roll.get("error", "").is_empty() and failed_record.get("rolls", []) == [1, 1] and int(failed_record.get("target", 0)) == 6 and not failed_record.get("passed", true), "A Leadership 6+ result of 2 fails and is saved")
		check(not failed_state.squads[friendly_squad].battle_shocked, "The Leadership test does not cause Battle-shock")
		var melee_declaration := [{"model": castellan, "target": enemy_squad, "amount": 6, "weapon": "master-crafted-power-weapon", "profile": "standard"}]
		var failed_melee := C.AttackPlan.prepare(failed_state, friendly_squad, true, melee_declaration, true)
		check(failed_melee.error.is_empty() and failed_melee.batches[0].context.get("hit_reroll", "none") == "ones" and failed_melee.batches[0].context.get("wound_reroll", "none") == "none", "A failed test grants only melee Hit re-rolls of 1")
		check(option(failed_state, 1, "vehement-aggression", "", friendly_squad, castellan).is_empty(), "The Castellan cannot test twice during the same Fight activation")
		var repeated := C.UnitActions.apply(failed_state, 1, failed_choice, Vector2.ZERO, func() -> int: return 1)
		check(not str(repeated.get("error", "")).is_empty(), "A repeated Leadership test is rejected")

		var passed_state: Dictionary = state.duplicate(true)
		var passed_choice := option(passed_state, 1, "vehement-aggression", "", friendly_squad, castellan)
		var passed_roll := PublicUnitCommand.submit(passed_state, 1, passed_choice, Vector2.ZERO, func() -> int: return 3)
		var passed_record: Dictionary = passed_state.unit_abilities.used.get("vehement-aggression:%d" % friendly_squad, {})
		check(passed_roll.get("error", "").is_empty() and passed_record.get("rolls", []) == [3, 3] and passed_record.get("passed", false), "A Leadership 6+ result of 6 passes and is saved")
		var passed_melee := C.AttackPlan.prepare(passed_state, friendly_squad, true, melee_declaration, true)
		check(passed_melee.error.is_empty() and passed_melee.batches[0].context.get("hit_reroll", "none") == "ones" and passed_melee.batches[0].context.get("wound_reroll", "none") == "ones", "A successful test grants melee Hit and Wound re-rolls of 1")
		var ranged_state: Dictionary = passed_state.duplicate(true)
		ranged_state.units[castellan].ranged_weapons = Profiles.castellan_weapons("heavy-bolt-pistol", "master-crafted-power-weapon").ranged
		var ranged_declaration := [{"model": castellan, "target": enemy_squad, "amount": 1, "weapon": "heavy-bolt-pistol", "profile": "standard"}]
		var ranged_plan := C.AttackPlan.prepare(ranged_state, friendly_squad, false, ranged_declaration, true)
		check(ranged_plan.error.is_empty() and ranged_plan.batches[0].context.get("hit_reroll", "none") == "none" and ranged_plan.batches[0].context.get("wound_reroll", "none") == "none", "Vehement Aggression does not modify ranged attacks")
		var restored: Dictionary = bytes_to_var(var_to_bytes(passed_state))
		check(C.UnitAbilities.vehement_aggression_result(restored, friendly_squad).get("passed", false), "The result survives state serialization for its selected Fight activation")
		restored.fight_selected = -1
		check(C.UnitAbilities.vehement_aggression_result(restored, friendly_squad).is_empty(), "Vehement Aggression stops affecting attacks when that Fight activation ends")
		var committed_state: Dictionary = passed_state.duplicate(true)
		var committed := C._commit_finished_attack(committed_state, friendly_squad, 1, melee_declaration, true, passed_melee, {"killed": 0, "damage": 0, "pools": []}, func() -> int: return 1)
		check(committed.get("error", "").is_empty() and not committed_state.unit_abilities.used.has("vehement-aggression:%d" % friendly_squad), "Finishing the unit's Fight activation clears Vehement Aggression")
		var empty_fight_state: Dictionary = passed_state.duplicate(true)
		C._finish_empty_fight(empty_fight_state, 1, friendly_squad)
		check(not empty_fight_state.unit_abilities.used.has("vehement-aggression:%d" % friendly_squad), "Finishing an empty fight clears Vehement Aggression")

		var aura_state: Dictionary = state.duplicate(true)
		var aura_source_id := 1
		for existing_model: int in aura_state.units: aura_source_id = maxi(aura_source_id, existing_model + 1)
		var aura_source_model: Dictionary = aura_state.units[castellan].duplicate(true)
		aura_source_model["definition_id"] = "40kdc:11e:adeptus-astartes:the-sanguinor"
		aura_source_model["keywords"] = ["ADEPTUS ASTARTES", "BLOOD ANGELS", "CHARACTER", "EPIC HERO"]
		aura_source_model["wounds"] = 7
		aura_source_model["position"] = aura_state.units[castellan].position
		aura_state.units[aura_source_id] = aura_source_model
		check(preload("res://scripts/edition_11/sanguinor.gd").aura_of_fervour_active(aura_state, friendly_squad), "Aura of Fervour reaches the Castellan's attached Adeptus Astartes unit")
		var aura_choice := option(aura_state, 1, "vehement-aggression", "", friendly_squad, castellan)
		var first_dice: Array[int] = [1, 1]
		var aura_roll := PublicUnitCommand.submit(aura_state, 1, aura_choice, Vector2.ZERO, func() -> int: return first_dice.pop_front())
		var aura_reroll := option(aura_state, 1, "vehement-aggression-reroll", "reroll", friendly_squad)
		check(aura_roll.get("error", "").is_empty() and C.UnitActions.pending(aura_state).get("kind", "") == "vehement-aggression-reroll" and str(aura_reroll.get("label", "")).begins_with("Aura of Fervour"), "Aura of Fervour exposes the keep-or-reroll decision for Vehement Aggression")
		var replacement_dice: Array[int] = [3, 3]
		var aura_reroll_result := PublicUnitCommand.submit(aura_state, 1, aura_reroll, Vector2.ZERO, func() -> int: return replacement_dice.pop_front())
		var aura_record: Dictionary = aura_state.unit_abilities.used.get("vehement-aggression:%d" % friendly_squad, {})
		check(aura_reroll_result.get("error", "").is_empty() and aura_record.get("rolls", []) == [3, 3] and aura_record.get("rerolled_from", []) == [1, 1] and aura_record.get("reroll_source", "") == "Aura of Fervour" and aura_record.get("passed", false), "Vehement Aggression persists the replaced dice and records Aura of Fervour as their source")

	if failures == 0: print("Castellan local checks: passed")
	else: print("Castellan local checks: %d failures" % failures)
	quit(0 if failures == 0 else 1)
