extends SceneTree

const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const AttackSequence = preload("res://scripts/edition_11/attack_sequence.gd")
const Catalog = preload("res://scripts/edition_11/army_capabilities.gd")
const Roster = preload("res://scripts/edition_11/roster_validation.gd")
const AbilityCatalog = preload("res://scripts/edition_11/unit_ability_catalog.gd")
const Registry = preload("res://scripts/edition_11/capabilities.gd")
const LeaderLinks = preload("res://scripts/edition_11/marine_leader_links.gd")
const LeaderCatalog = preload("res://scripts/edition_11/leader_catalog.gd")
const PublicUnitCommand = preload("res://tests/public_unit_command.gd")
const WeaponChecks = preload("res://tests/space_marine_datasheet_checks.gd")
const UNIT := "asmodai"
const UNIT_ID := "40kdc:11e:adeptus-astartes:asmodai"
const A = C.UnitAbilities

var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func reroll_value() -> int:
	return 3

func entry(identity: String, models_count: int = 1, enhancement_id: String = "") -> Dictionary:
	var result := {"definition_id": "40kdc:11e:adeptus-astartes:" + identity, "models": models_count, "copies": 1}
	if not enhancement_id.is_empty(): result.enhancement_id = enhancement_id
	return result

func selections() -> Dictionary:
	return {
		1: {"schema_version": 2, "faction": "Space Marines", "category": "custom", "points_limit": 1000, "entries": [entry(UNIT), entry("inner-circle-companions", 3)]},
		2: {"schema_version": 2, "faction": "Space Marines", "category": "custom", "points_limit": 1000, "entries": [entry("captain"), entry("judiciar"), entry("intercessor-squad", 5)]}
	}

func fixture() -> Dictionary:
	return F.P.initial_state({"checked_rosters": false, "official_mission": false, "unit_abilities": true, "combat_doctrines": true, "core_stratagems": true, "attack_rerolls": true, "manual_allocation": false, "marine_chapters": {1: "DARK ANGELS", 2: "DARK ANGELS"}}, selections())

func models(state: Dictionary, identity: String, owner: int) -> Array[int]:
	var result: Array[int] = []
	for model: int in state.get("units", {}):
		var unit: Dictionary = state.units[model]
		if int(unit.get("owner", -1)) == owner and A.identity(unit) == identity: result.append(model)
	result.sort()
	return result

func squad_for(state: Dictionary, identity: String, owner: int) -> int:
	var found := models(state, identity, owner)
	return int(state.units[found[0]].squad) if not found.is_empty() else -1

func choice_for(state: Dictionary, player: int, action: String, model: int = -1, target: int = -1, value: String = "") -> Dictionary:
	for option: Dictionary in C.UnitActions.choices(state, player):
		if str(option.get("action", "")) != action: continue
		if model >= 0 and int(option.get("model", -1)) != model: continue
		if target >= 0 and int(option.get("target", -1)) != target: continue
		if not value.is_empty() and str(option.get("value", "")) != value: continue
		return option
	return {}

func planned_hit_reroll(state: Dictionary, attacker: int, target: int, melee: bool, weapon_id: String, profile_id: String) -> Dictionary:
	var isolated: Dictionary = state.duplicate(true)
	var attacker_squad := int(isolated.units[attacker].squad)
	var owner := int(isolated.units[attacker].owner)
	var target_models: Array[int] = C.living(isolated, target)
	if target_models.is_empty(): return {"error": "Target unit has no living models."}
	isolated.units[attacker].position = Vector2.ZERO
	isolated.units[target_models[0]].position = Vector2(1.75 if melee else 10.0, 0.0)
	isolated.phase = "fight" if melee else "shooting"
	isolated.active = owner
	isolated.unit_abilities.phase_key = C.UnitActions.key(isolated)
	var weapon: Dictionary = {}
	for candidate: Dictionary in isolated.units[attacker].get("melee_weapons" if melee else "ranged_weapons", []):
		if str(candidate.get("id", "")) == weapon_id:
			weapon = candidate
			break
	if weapon.is_empty() or not weapon.get("profiles", {}).has(profile_id): return {"error": "Selected weapon profile is missing."}
	var attacks: Variant = weapon.profiles[profile_id].get("attacks", 1)
	var amount := int(attacks) if attacks is int else 1
	var plan := C.AttackPlan.prepare(isolated, attacker_squad, melee, [{"model": attacker, "target": target, "amount": amount, "weapon": weapon_id, "profile": profile_id}], true)
	if not str(plan.get("error", "")).is_empty(): return plan
	if plan.get("batches", []).is_empty(): return {"error": "AttackPlan did not produce an attack batch."}
	return {"error": "", "hit_reroll": str(plan.batches[0].context.get("hit_reroll", "none")), "plan": plan}

func run() -> void:
	var profile := Profiles.profile(UNIT)
	check(profile.get("source_book_id") == "000000023" and profile.get("source_datasheet_id") == "000000225" and profile.get("source_export_updated_at") == "2026-10-21 16:06:23 GMT+3", "Asmodai cites the pinned Dark Angels App identity")
	check(profile.get("points_by_models", {}) == {1: 80} and profile.get("max_supported_copies", 0) == 1, "The one-model 80-point Epic Hero profile and single-copy limit match the export")
	check(profile.get("base_size_source_mm") == 50 and is_equal_approx(float(profile.get("base_radius_inches", 0.0)), 25.0 / 25.4), "The 50 mm source base is represented as the runtime circle")
	check(profile.get("stats", {}) == {"movement_inches": 6, "toughness": 5, "save_target": 3, "wounds": 4, "leadership_target": 5, "objective_control": 1, "invulnerable_target": 4}, "M6/T5/Sv3+/W4/Ld5+/OC1 and 4+ invulnerable save match the export")
	check(profile.get("keywords", []) == ["ADEPTUS ASTARTES", "DARK ANGELS", "INFANTRY", "CHARACTER", "EPIC HERO", "CHAPLAIN", "TACTICUS", "IMPERIUM", "EXPLOSIVES", "DEATHWING"], "Every source keyword, including Chapter and Deathwing, is represented")
	check(profile.get("default_loadout_by_role", {}).get("Asmodai", {}) == {"Heavy Bolt Pistol": 1, "Crozius Arcanum and Power Weapon": 1}, "The fixed source loadout is represented")
	check(profile.get("ranged", []).size() == 1 and profile.ranged[0].profiles.standard == {"name": "Heavy Bolt Pistol", "range_inches": 18.0, "attacks": 1, "skill": 2, "strength": 5, "ap": -1, "damage": 1, "keywords": {"close-quarters": true}}, "Heavy Bolt Pistol preserves its source profile")
	check(profile.get("melee", []).size() == 1 and profile.melee[0].profiles.strike == {"name": "Crozius Arcanum and Power Weapon - Strike", "range_inches": 0.0, "attacks": 5, "skill": 2, "strength": 6, "ap": -2, "damage": 2, "keywords": {"precision": true}} and profile.melee[0].profiles.sweep == {"name": "Crozius Arcanum and Power Weapon - Sweep", "range_inches": 0.0, "attacks": 8, "skill": 2, "strength": 5, "ap": -2, "damage": 1, "keywords": {"cleave": 1}}, "Both Crozius Arcanum and Power Weapon profiles preserve their source fields")
	check(AbilityCatalog.RULES.get(UNIT, []) == ["leader", "combat-doctrines", "transhuman-strategist", "exemplar-of-hate", "feared-interrogator"], "Leader, Combat Doctrines, Warlord CP and both datasheet abilities are assigned")
	for ability: String in ["exemplar-of-hate", "feared-interrogator"]:
		var capability: Dictionary = Registry.KNOWN.get(ability, {})
		check(capability.get("category", "") == Registry.CATEGORY_UNIT and capability.get("supported", false) and capability.get("source_status", "").contains("20261021T130623Z"), "%s has aligned source and ability metadata" % ability)
	check(Catalog.SPECS.get(UNIT, {}).get("current_reference", false) and Roster.POINTS.get(UNIT, {}).get("cost", -1) == 80 and Roster.POINTS.get(UNIT, {}).get("max_supported_copies", 0) == 1, "Asmodai is in the current construction and roster-price catalogs")
	var current_choice := Catalog.current_catalog_choice({"id": UNIT_ID, "edition": "11e", "faction": "Space Marines"})
	check(current_choice.get("options", []) == [{"models": 1, "cost": 80}], "The local construction catalog exposes Asmodai at 80 points: %s" % str(current_choice.get("options", [])))
	var two_incursion := Catalog.admit({"schema_version": 2, "faction": "Space Marines", "category": "incursion", "points_limit": 1000, "entries": [entry(UNIT), entry(UNIT)]})
	check(not two_incursion.get("error", "").is_empty(), "Incursion rejects a second Asmodai copy")
	var resolved := Catalog.resolve("Space Marines", UNIT_ID)
	check(resolved.get("error", "").is_empty() and resolved.get("unit", {}).get("base", {}) == {"shape": "circle", "radius_inches": 25.0 / 25.4}, "Runtime construction resolves the exported base: %s" % str(resolved))

	var expected_targets: Array[String] = ["inner-circle-companions", "bladeguard-veteran-squad", "infernus-squad", "intercessor-squad", "assault-intercessor-squad", "hellblaster-squad", "sternguard-veteran-squad"]
	check(LeaderLinks.targets(UNIT).size() == expected_targets.size() and expected_targets.all(func(target: String) -> bool: return target in LeaderLinks.targets(UNIT)), "Asmodai retains all seven source-listed Leader targets")
	check(LeaderCatalog.ATTACHMENTS.get(UNIT_ID, []).size() == expected_targets.size(), "The current attachment catalog includes Asmodai's available targets")

	var state := fixture()
	check(not state.has("error"), "Both Dark Angels rosters materialize Asmodai and his bodyguard: %s" % str(state.get("error", "")))
	if state.has("error"):
		print("Asmodai checks: %d failures" % (failures + 1))
		quit(1)
		return
	var asmodai_models := models(state, UNIT, 1)
	var companion_models := models(state, "inner-circle-companions", 1)
	var target_captains := models(state, "captain", 2)
	var far_characters := models(state, "judiciar", 2)
	var enemy_intercessors := models(state, "intercessor-squad", 2)
	check(asmodai_models.size() == 1 and companion_models.size() == 3 and target_captains.size() == 1 and far_characters.size() == 1 and enemy_intercessors.size() == 5, "The test rosters materialize all source profiles for ability boundaries")
	if asmodai_models.is_empty() or companion_models.is_empty() or target_captains.is_empty() or far_characters.is_empty() or enemy_intercessors.is_empty():
		print("Asmodai checks: %d failures" % (failures + 1))
		quit(1)
		return
	var asmodai_model := asmodai_models[0]
	var companion_squad := squad_for(state, "inner-circle-companions", 1)
	state.phase = "deployment"
	state.active = 1
	var warlord_choice := choice_for(state, 1, "warlord", asmodai_model)
	check(not warlord_choice.is_empty(), "Asmodai is available for Warlord designation")
	if not warlord_choice.is_empty():
		var cp_before := int(state.cp[1])
		var warlord_result := PublicUnitCommand.submit(state, 1, warlord_choice)
		state.active = 1
		C.UnitActions.start_round(state)
		C.UnitActions.start_round(state)
		check(warlord_result.get("error", "").is_empty() and int(state.unit_abilities.warlords.get(1, -1)) == asmodai_model and state.cp[1] == cp_before + 1, "Transhuman Strategist grants Asmodai's Warlord CP once per battle round")
	var attach_choice := choice_for(state, 1, "attach", asmodai_model, companion_squad)
	var attach_result := PublicUnitCommand.submit(state, 1, attach_choice)
	check(not attach_choice.is_empty() and attach_result.get("error", "").is_empty() and int(state.units[asmodai_model].squad) == companion_squad, "Asmodai joins Inner Circle Companions through the public Leader command")
	check("DEATHWING" in state.units[asmodai_model].get("keywords", []), "Dark Angels context retains Asmodai's conditional Deathwing keyword")
	var weapon_failures: Array[String] = WeaponChecks.fixed_weapon_plan_failures(state, profile, asmodai_model, squad_for(state, "intercessor-squad", 2))
	check(weapon_failures.is_empty(), "Every Asmodai weapon profile resolves through Equipment and AttackPlan: %s" % str(weapon_failures))
	var melee_plan := planned_hit_reroll(state, companion_models[0], squad_for(state, "intercessor-squad", 2), true, "calibanite-greatsword", "sweep")
	check(melee_plan.get("error", "").is_empty() and melee_plan.get("hit_reroll", "") == "all", "Exemplar of Hate grants all melee Hit re-rolls in AttackPlan")
	var exemplar_hits: Array[int] = [6, 1]
	var exemplar_rerolls := AttackSequence.reroll_hit_pool(exemplar_hits, 2, 0, {"hit_reroll": "all"}, AttackSequence.Dice.new(Callable(self, "reroll_value")))
	check(exemplar_rerolls.size() == 2 and exemplar_hits == [3, 3], "Exemplar of Hate can re-roll successful and failed melee Hit rolls")
	var ranged_plan := planned_hit_reroll(state, companion_models[0], squad_for(state, "intercessor-squad", 2), false, "heavy-bolt-pistol", "standard")
	check(ranged_plan.get("error", "").is_empty() and ranged_plan.get("hit_reroll", "none") == "none", "Exemplar of Hate does not grant ranged Hit re-rolls")

	state.units[asmodai_model].position = Vector2.ZERO
	state.units[target_captains[0]].position = Vector2(3.0, 0.0)
	state.units[far_characters[0]].position = Vector2(8.0, 0.0)
	for enemy_model: int in enemy_intercessors: state.units[enemy_model].position = Vector2(0.0, 4.0 + float(enemy_model % 3) * 0.5)
	state.phase = "charge"
	state.active = 1
	var transition := C.advance_phase(state, 1, state.revision, func() -> int: return 1)
	var pending: Dictionary = state.get("feared-interrogator", {})
	check(transition.is_empty() and state.phase == "fight" and pending.get("targets", []) == [squad_for(state, "captain", 2)], "Fight-phase start targets only the enemy CHARACTER unit within 6 inches")
	check(C.UnitActions.actor(state) == 1 and C.UnitActions.pending_decision(state).get("resume_frame_id", "") != "", "Feared Interrogator opens a persisted phase-start decision")
	var restored: Dictionary = bytes_to_var(var_to_bytes(state))
	check(C.UnitActions.pending_decision(restored).get("decision_id", "") == C.UnitActions.pending_decision(state).get("decision_id", ""), "The mandatory CHARACTER Battle-shock window survives serialization")
	var roll_choice := choice_for(state, 1, "feared-interrogator", -1, squad_for(state, "captain", 2), "roll")
	var roll_result := PublicUnitCommand.submit(state, 1, roll_choice, Vector2.ZERO, func() -> int: return 1)
	check(roll_result.get("error", "").is_empty() and state.squads[squad_for(state, "captain", 2)].battle_shocked, "The -1 Leadership modifier resolves at the public command boundary")
	check(state.get("last_feared_interrogator", [{}])[0].get("modifier", 0) == -1 and state.get("feared-interrogator", {}).is_empty() and C.ResolutionFrames.current(state).is_empty(), "The failed test is recorded and the Fight phase can continue")

	var tempered_selections := {
		1: {"schema_version": 2, "faction": "Space Marines", "category": "custom", "points_limit": 1000, "entries": [entry(UNIT)]},
		2: {"schema_version": 2, "faction": "Space Marines", "category": "custom", "points_limit": 1000, "entries": [entry("captain-on-bike", 1, "000010155003")]}
	}
	var tempered := F.P.initial_state({"checked_rosters": false, "official_mission": false, "unit_abilities": true, "combat_doctrines": true, "core_stratagems": true, "manual_allocation": false, "marine_detachment": "wrath-of-the-rock", "marine_chapters": {1: "DARK ANGELS", 2: "DARK ANGELS"}}, tempered_selections)
	check(not tempered.has("error"), "The Tempered in Battle regression fixture materializes both Chapter characters: %s" % str(tempered.get("error", "")))
	if not tempered.has("error"):
		var tempered_asmodai := models(tempered, UNIT, 1)
		var tempered_target := models(tempered, "captain-on-bike", 2)
		check(tempered_asmodai.size() == 1 and tempered_target.size() == 1, "The optional reroll fixture has one Asmodai and an enemy Character carrying Tempered in Battle")
		if not tempered_asmodai.is_empty() and not tempered_target.is_empty():
			var target_model: int = tempered_target[0]
			var target_squad: int = int(tempered.units[target_model].squad)
			tempered.units[target_model].enhancement_id = "000010155002"
			tempered.squads[target_squad].enhancement_id = "000010155002"
			tempered.units[tempered_asmodai[0]].position = Vector2.ZERO
			tempered.units[target_model].position = Vector2(3.0, 0.0)
			tempered.squads[target_squad].battle_shocked = true
			if tempered.has("mission"): tempered.mission.stage = "battle"
			tempered.phase = "charge"
			tempered.active = 1
			var tempered_start := C.advance_phase(tempered, 1, tempered.revision, func() -> int: return 6)
			var tempered_roll := choice_for(tempered, 1, "feared-interrogator", -1, target_squad, "roll")
			var tempered_roll_result := PublicUnitCommand.submit(tempered, 1, tempered_roll, Vector2.ZERO, func() -> int: return 2)
			check(tempered_start.is_empty() and not tempered_roll.is_empty() and tempered_roll_result.get("error", "").is_empty(), "Feared Interrogator rolls the enemy Character before offering its aura reroll: %s" % str(tempered_roll_result.get("error", "")))
			var target_decision := C.UnitActions.pending_decision(tempered)
			check(target_decision.get("priority_player_id", -1) == 2 and target_decision.get("legal_options", []).any(func(option: Dictionary) -> bool: return option.get("value", "") == "tempered-in-battle"), "The tested Character's controller receives the optional reroll decision")
			var tempered_restore: Dictionary = bytes_to_var(var_to_bytes(tempered))
			var reroll_choice := choice_for(tempered_restore, 2, "feared-interrogator", -1, target_squad, "tempered-in-battle")
			var reroll_result := PublicUnitCommand.submit(tempered_restore, 2, reroll_choice, Vector2.ZERO, func() -> int: return 6)
			var final_fear_result: Dictionary = tempered_restore.get("last_feared_interrogator", [{}])[0]
			check(reroll_result.get("error", "").is_empty() and final_fear_result.get("passed", false) and tempered_restore.squads[target_squad].battle_shocked, "The passing reroll preserves Battle-shock that was already in effect: %s" % str(reroll_result.get("error", "")))
			check(final_fear_result.get("rerolled_from", []) == [2, 2] and final_fear_result.get("rolls", []) == [6, 6] and C.ResolutionFrames.current(tempered_restore).is_empty(), "The rerolled result is audited and resumes the Fight-phase continuation")

	if failures == 0: print("Asmodai checks: passed")
	else: print("Asmodai checks: %d failures" % failures)
	quit(0 if failures == 0 else 1)

func _initialize() -> void:
	call_deferred("run")
