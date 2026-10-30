extends SceneTree

const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const AbilityCatalog = preload("res://scripts/edition_11/unit_ability_catalog.gd")
const Equipment = preload("res://scripts/edition_11/equipment.gd")
const Catalog = preload("res://scripts/edition_11/army_capabilities.gd")
const Roster = preload("res://scripts/edition_11/roster_validation.gd")
const LeaderLinks = preload("res://scripts/edition_11/marine_leader_links.gd")
const SupportAttachments = preload("res://scripts/edition_11/support_attachments.gd")
const WeaponChecks = preload("res://tests/space_marine_datasheet_checks.gd")
const PublicUnitCommand = preload("res://tests/public_unit_command.gd")
const UNIT := "eradicator-squad-with-melta-rifles"
const UNIT_ID := "40kdc:11e:adeptus-astartes:eradicator-squad-with-melta-rifles"
const BIOLOGIS_ID := "40kdc:11e:adeptus-astartes:apothecary-biologis"
const INTERCESSOR_ID := "40kdc:11e:adeptus-astartes:intercessor-squad"

var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func entry(identity: String, models: int = 1, copies: int = 1) -> Dictionary:
	return {"definition_id": "40kdc:11e:adeptus-astartes:" + identity, "models": models, "copies": copies}

func lists() -> Dictionary:
	var result := F.current_marine_selections()
	result[1].entries = [entry("apothecary-biologis"), entry(UNIT, 3), entry(UNIT, 6)]
	result[2].entries = [entry("intercessor-squad", 5), entry("intercessor-squad", 10)]
	return result

func find_squad(state: Dictionary, owner: int, identity: String, strength: int = -1) -> int:
	for model: int in state.units:
		var unit: Dictionary = state.units[model]
		if int(unit.get("owner", -1)) != owner or C.UnitAbilities.identity(unit) != identity: continue
		var squad := int(unit.get("squad", -1))
		if strength >= 0 and int(state.squads[squad].get("starting_strength", -1)) != strength: continue
		return squad
	return -1

func models_in_squad(state: Dictionary, squad: int) -> Array[int]:
	var result: Array[int] = []
	for model: int in C.living(state, squad): result.append(model)
	result.sort()
	return result

func model_for(state: Dictionary, squad: int, sergeant: bool) -> int:
	for model: int in models_in_squad(state, squad):
		if bool(state.units[model].get("sergeant", false)) == sergeant: return model
	return -1

func fixture() -> Dictionary:
	var state := F.P.initial_state({
		"unit_abilities": true,
		"combat_doctrines": true,
		"reanimation_protocols": true,
		"awakened_dynasty": true,
		"core_stratagems": true,
		"manual_allocation": false
	}, lists())
	if state.has("error"): return state
	state.awakened_dynasty.pending = []
	state.mission.stage = "battle"
	state.deployment.complete = true
	state.phase = "deployment"
	state.turn = 1
	state.round = 1
	state.active = 1
	state.unit_abilities.setup_players = [2]
	state.unit_abilities.battle_players = [1, 2]
	state.unit_abilities.phase_key = C.UnitActions.key(state)
	state.unit_abilities.window = {}
	state.terrain.areas = []
	for model: int in state.units:
		state.units[model].position = Vector2(-18, -12) if state.units[model].owner == 1 else Vector2(18, 12)
	return state

func set_target_keyword(state: Dictionary, squad: int, keyword: String, enabled: bool) -> void:
	for model: int in C.living(state, squad):
		var keywords: Array = state.units[model].keywords
		if enabled and keyword not in keywords: keywords.append(keyword)
		if not enabled: keywords.erase(keyword)

func prepare_attack(state: Dictionary, squad: int, model: int, target: int, weapon: String, profile: String, distance: float) -> Dictionary:
	var old_phase := str(state.phase)
	var old_active := int(state.active)
	var old_attacker_position: Vector2 = state.units[model].position
	var old_target_positions := {}
	for target_model: int in C.living(state, target): old_target_positions[target_model] = state.units[target_model].position
	state.phase = "shooting"
	state.active = int(state.squads[squad].owner)
	state.units[model].position = Vector2.ZERO
	var first_target: int = C.living(state, target)[0]
	state.units[first_target].position = Vector2(float(state.units[model].radius) + float(state.units[first_target].radius) + distance, 0)
	for target_model: int in C.living(state, target):
		if target_model != first_target: state.units[target_model].position = Vector2(25.0, 5.0 + float(target_model % 7))
	var plan := C.AttackPlan.prepare(state, squad, false, [{"model": model, "target": target, "amount": 1, "weapon": weapon, "profile": profile}], true)
	state.phase = old_phase
	state.active = old_active
	state.units[model].position = old_attacker_position
	for target_model: int in old_target_positions: state.units[target_model].position = old_target_positions[target_model]
	return plan

func legal_targets_at_range(state: Dictionary, model: int, target: int, weapon: String, profile: String) -> Array[int]:
	var old_phase := str(state.phase)
	var old_active := int(state.active)
	var old_attacker_position: Vector2 = state.units[model].position
	var old_target_positions := {}
	for target_model: int in C.living(state, target): old_target_positions[target_model] = state.units[target_model].position
	state.phase = "shooting"
	state.active = int(state.units[model].owner)
	state.units[model].position = Vector2.ZERO
	var first_target: int = C.living(state, target)[0]
	state.units[first_target].position = Vector2(float(state.units[model].radius) + float(state.units[first_target].radius) + 8.0, 0)
	for target_model: int in C.living(state, target):
		if target_model != first_target: state.units[target_model].position = Vector2(25.0, 5.0 + float(target_model % 7))
	var result := C.AttackPlan.legal_targets(state, model, false, weapon, profile)
	state.phase = old_phase
	state.active = old_active
	state.units[model].position = old_attacker_position
	for target_model: int in old_target_positions: state.units[target_model].position = old_target_positions[target_model]
	return result

func choice_for(state: Dictionary, squad: int, model: int, value: String) -> Dictionary:
	for selected: Dictionary in C.unit_choices(state, 1):
		if selected.get("action", "") == "eradicator-melta" and int(selected.get("model", -1)) == model and int(selected.get("target", -1)) == squad and selected.get("value", "") == value:
			return selected
	return {}

func test_total_obliteration_reroll() -> void:
	var state := fixture()
	if state.has("error"):
		check(false, "Total Obliteration reroll fixture materializes")
		return
	var squad := find_squad(state, 1, UNIT, 3)
	var target := find_squad(state, 2, "intercessor-squad", 10)
	var model := model_for(state, squad, false)
	var target_model: int = C.living(state, target)[0]
	state.phase = "shooting"
	state.active = 1
	state.units[model].position = Vector2.ZERO
	state.units[target_model].position = Vector2(float(state.units[model].radius) + float(state.units[target_model].radius) + 8.0, 0)
	for other: int in C.living(state, target):
		if other != target_model: state.units[other].position = Vector2(25.0, 5.0 + float(other % 7))
	var dice: Array[int] = [3, 2, 1, 1, 3]
	var roller := func() -> int: return dice.pop_front() if not dice.is_empty() else 1
	var result := C.resolve_attack_plan(state, 1, model, [{"model": model, "target": target, "amount": 1, "weapon": "melta-rifle", "profile": "standard"}], state.revision, false, true, roller)
	var reroll_choices: Array = C.unit_choices(state, 1).filter(func(choice: Dictionary) -> bool: return choice.get("action", "") == "damage-reroll" and choice.get("value", "") == "Total Obliteration")
	check(result.get("error", "").is_empty() and state.unit_abilities.window.get("kind", "") == "damage-reroll" and reroll_choices.size() == 1, "Successful ranged attack exposes the optional Total Obliteration Damage re-roll: %s" % str(result))
	if reroll_choices.is_empty(): return
	var before_wrong_owner := var_to_bytes(state)
	check(not PublicUnitCommand.error(state, 2, reroll_choices[0]).is_empty() and before_wrong_owner == var_to_bytes(state), "Opponent cannot submit Total Obliteration's Damage re-roll")
	var reroll_result := PublicUnitCommand.submit(state, 1, reroll_choices[0], Vector2.ZERO, func() -> int: return 3)
	check(reroll_result.get("error", "").is_empty() and state.unit_abilities.window.get("kind", "") != "damage-reroll", "Projected re-roll resolves through the public command route")

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var profile: Dictionary = Profiles.profile(UNIT)
	check(profile.get("name", "") == "Eradicator Squad with Melta Rifles" and profile.get("source_book_id", "") == "000000139" and profile.get("source_datasheet_id", "") == "000004249" and profile.get("source_export_updated_at", "") == "2026-10-16T21:03:46+03:00", "Profile is pinned to the verified common-book export identity and source stamp")
	check(profile.get("models", -1) == 3 and profile.get("points_by_models", {}) == {3: 100, 6: 200} and profile.get("third_plus_points_by_models", {}) == {3: 120, 6: 220}, "Three/six model sizes and first/second plus third-plus costs match the export")
	check(is_equal_approx(float(profile.get("base_radius_inches", 0.0)), 20.0 / 25.4), "Every model uses the exported 40 mm base")
	check(profile.get("stats", {}) == {"movement_inches": 5, "toughness": 6, "save_target": 3, "wounds": 3, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 0}, "Shared Eradicator characteristics match the pinned export")
	var keywords: Array = profile.get("keywords", []).duplicate()
	keywords.sort()
	check(keywords == ["ADEPTUS ASTARTES", "EXPLOSIVES", "GRAVIS", "IMPERIUM", "INFANTRY"], "All five exported keywords are preserved")
	check(profile.get("ranged", []).size() == 2 and profile.ranged[0].id == "melta-rifle" and profile.ranged[1].id == "bolt-pistol" and profile.get("melee", []).size() == 1 and profile.melee[0].id == "ceramite-fists", "Fixed Melta Rifle, Bolt Pistol and Ceramite Fists loadout matches the export")
	check(AbilityCatalog.RULES.get(UNIT, []) == ["total-obliteration"], "Total Obliteration is the only registered datasheet ability")

	var state := fixture()
	check(not state.has("error"), "Both current Marine catalogs materialize the Eradicators, Biologis and enemy targets")
	if state.has("error"):
		print("Melta Rifle Eradicator checks: %d failures" % (failures + 1))
		quit(1)
		return
	var small := find_squad(state, 1, UNIT, 3)
	var large := find_squad(state, 1, UNIT, 6)
	var support := find_squad(state, 1, "apothecary-biologis")
	var target := find_squad(state, 2, "intercessor-squad", 10)
	var small_models := models_in_squad(state, small)
	var large_models := models_in_squad(state, large)
	check(small > 0 and large > 0 and support > 0 and target > 0 and small_models.size() == 3 and large_models.size() == 6, "Both source sizes and the linked Support/target units materialize")
	if small < 0 or large < 0 or target < 0: quit(1); return
	check(state.squads[small].training_cost == 100 and state.squads[large].training_cost == 200 and state.units[small_models[0]].radius == 20.0 / 25.4, "Materialized roster retains source prices and base size")
	check(C.UnitActions.attachment_allowed(state, support * 100, small) and C.UnitActions.attachment_allowed(state, support * 100, large), "Apothecary Biologis can attach to both source compositions")
	var catalog := Catalog.current_catalog_choice({"id": UNIT_ID, "edition": "11e", "faction": "Space Marines"})
	check(catalog.get("options", []) == [{"models": 3, "cost": 100, "third_plus_cost": 120}, {"models": 6, "cost": 200, "third_plus_cost": 220}], "Current catalog offers only the two sourced compositions and cost tiers")
	check(Roster.POINTS[UNIT].get("sizes", {}) == {3: 100, 6: 200} and Roster.POINTS[UNIT].get("third_plus_sizes", {}) == {3: 120, 6: 220}, "Roster validation retains the source prices")
	var two_copy_roster := {"schema_version": 2, "faction": "Space Marines", "category": "incursion", "points_limit": 1000, "entries": [entry("apothecary-biologis"), entry(UNIT, 3), entry(UNIT, 6)]}
	var two_copy_admission := C.RosterValidation.admit(two_copy_roster)
	check(two_copy_admission.get("error", "").is_empty() and int(two_copy_admission.get("total", -1)) == 360, "Checked Incursion roster admits two source-sized copies: %s" % str(two_copy_admission))
	two_copy_roster.entries.append(entry(UNIT, 3))
	check(not str(C.RosterValidation.admit(two_copy_roster).get("error", "")).is_empty(), "Checked roster rejects a third non-Battleline copy")
	two_copy_roster.entries.pop_back()
	var source_leaders: Array[String] = []
	for leader: String in LeaderLinks.TARGETS:
		if leader != "apothecary-biologis" and UNIT in LeaderLinks.TARGETS[leader]: source_leaders.append(leader)
	source_leaders.sort()
	check(source_leaders == ["captain-in-gravis-armour", "iron-father-feirros", "marneus-calgar", "tor-garadon", "vulkan-hestan"], "All five exported Leader links are present")
	check(UNIT in SupportAttachments.BODYGUARDS.get("apothecary-biologis", []), "Separate Support map preserves the Biologis link")
	check(C.UnitAbilities.has(state, small, "total-obliteration") and not C.UnitAbilities.has(state, support, "total-obliteration"), "Total Obliteration is assigned to Eradicator units only")

	var bolt_pistol: Dictionary = profile.ranged[1].profiles.standard
	var fists: Dictionary = profile.melee[0].profiles.standard
	set_target_keyword(state, target, "VEHICLE", true)
	for model: int in small_models:
		var model_profile := {"ranged": state.units[model].ranged_weapons.duplicate(true), "melee": state.units[model].melee_weapons.duplicate(true)}
		var fixed_failures: Array[String] = WeaponChecks.fixed_weapon_plan_failures(state, model_profile, model, target)
		check(fixed_failures.is_empty(), "Default Melta Rifle, Hunter, Bolt Pistol and Ceramite Fists resolve through Equipment/AttackPlan: %s" % str(fixed_failures))
	check(Equipment.select(state, small_models[0], false, "bolt-pistol", "standard").get("stats", {}) == bolt_pistol and Equipment.select(state, small_models[0], true, "ceramite-fists", "standard").get("stats", {}) == fists, "Fixed pistol and melee profiles exactly match the export")
	var rifle: Dictionary = profile.ranged[0]
	check(rifle.profiles.standard == {"name": "Melta Rifle", "range_inches": 18.0, "attacks": 1, "skill": 3, "strength": 10, "ap": -3, "damage": "D3+2", "keywords": {"melta": 2}}, "Standard Melta Rifle profile matches all exported characteristics and traits")
	check(rifle.profiles.hunter == {"name": "Melta Rifle - Hunter", "range_inches": 18.0, "attacks": 1, "skill": 2, "strength": 12, "ap": -3, "damage": "D3+2", "keywords": {"melta": 2, "hunter": ["Monster", "Vehicle"]}}, "Hunter profile matches export and retains its target restriction")
	var multi := Profiles.eradicator_ranged(true)
	check(multi.get("id", "") == "multi-melta" and multi.profiles.standard == {"name": "Multi-melta", "range_inches": 18.0, "attacks": 2, "skill": 3, "strength": 10, "ap": -3, "damage": "D3+2", "keywords": {"melta": 3}}, "Standard Multi-melta profile matches all exported characteristics and traits")
	check(multi.profiles.hunter == {"name": "Multi-melta - Hunter", "range_inches": 18.0, "attacks": 2, "skill": 2, "strength": 12, "ap": -3, "damage": "D3+2", "keywords": {"melta": 3, "hunter": ["Monster", "Vehicle"]}}, "Multi-melta Hunter profile matches its target restriction")

	var ordinary_model: int = model_for(state, small, false)
	var sergeant: int = model_for(state, small, true)
	check(ordinary_model > 0 and sergeant > 0 and C.UnitActions.eradicator_model_label(state, sergeant) == "Eradicator Sergeant" and C.UnitActions.eradicator_model_label(state, ordinary_model).begins_with("Eradicator "), "Equipment choices identify the Sergeant and numbered ordinary models")
	set_target_keyword(state, target, "VEHICLE", false)
	check(not legal_targets_at_range(state, ordinary_model, target, "melta-rifle", "hunter").has(target), "Hunter profile cannot target an unqualified Intercessor unit")
	set_target_keyword(state, target, "VEHICLE", true)
	check(legal_targets_at_range(state, ordinary_model, target, "melta-rifle", "hunter").has(target), "Hunter profile can target a VEHICLE")
	set_target_keyword(state, target, "VEHICLE", false)
	set_target_keyword(state, target, "MONSTER", true)
	check(legal_targets_at_range(state, ordinary_model, target, "melta-rifle", "hunter").has(target), "Hunter profile can target a MONSTER")
	set_target_keyword(state, target, "MONSTER", false)

	var close_plan := prepare_attack(state, small, ordinary_model, target, "melta-rifle", "standard", 9.0)
	var far_plan := prepare_attack(state, small, ordinary_model, target, "melta-rifle", "standard", 9.1)
	check(close_plan.get("error", "").is_empty() and close_plan.batches[0].weapon.damage == "D3+4", "At exactly half range, Melta 2 increases damage from D3+2 to D3+4: %s" % str(close_plan))
	check(far_plan.get("error", "").is_empty() and far_plan.batches[0].weapon.damage == "D3+2", "Beyond half range, the source Melta damage remains D3+2: %s" % str(far_plan))
	check(close_plan.batches[0].context.get("free_damage_reroll", false) and not close_plan.batches[0].weapon.keywords.has("melta"), "Total Obliteration grants a ranged Damage re-roll while attack planning consumes the Melta trait")
	state.units[ordinary_model].position = Vector2.ZERO
	state.units[C.living(state, target)[0]].position = Vector2(1.75, 0)
	state.phase = "fight"
	var melee_plan := C.AttackPlan.prepare(state, small, true, [{"model": ordinary_model, "target": target, "amount": 3, "weapon": "ceramite-fists", "profile": "standard"}], true)
	check(melee_plan.get("error", "").is_empty() and not melee_plan.batches[0].context.get("free_damage_reroll", false), "Total Obliteration does not grant a melee Damage re-roll")
	state.phase = "deployment"
	state.unit_abilities.phase_key = C.UnitActions.key(state)
	test_total_obliteration_reroll()

	var three_models := models_in_squad(state, small)
	var six_models := models_in_squad(state, large)
	var three_options := C.unit_choices(state, 1).filter(func(choice: Dictionary) -> bool: return choice.get("action", "") == "eradicator-melta" and int(choice.get("target", -1)) == small and choice.get("value", "") == "multi")
	var six_options := C.unit_choices(state, 1).filter(func(choice: Dictionary) -> bool: return choice.get("action", "") == "eradicator-melta" and int(choice.get("target", -1)) == large and choice.get("value", "") == "multi")
	check(three_options.size() == 3 and six_options.size() == 6, "One Multi-melta may be selected per three-model group, with every eligible carrier offered")
	check(three_options.all(func(choice: Dictionary) -> bool: return str(choice.get("label", "")) == "Equip Multi-melta"), "Compact player-facing choice text names the replacement weapon")
	var selected := choice_for(state, small, sergeant, "multi")
	var wrong_owner_before := var_to_bytes(state)
	check(not selected.is_empty() and not PublicUnitCommand.error(state, 2, selected).is_empty() and wrong_owner_before == var_to_bytes(state), "Opponent cannot submit the Eradicator equipment choice")
	check(PublicUnitCommand.error(state, 1, selected).is_empty() and state.units[sergeant].ranged_weapons[0].id == "multi-melta" and state.units[sergeant].multi_melta, "Public preparation command equips the Sergeant with a Multi-melta")
	var cap_options := C.unit_choices(state, 1).filter(func(choice: Dictionary) -> bool: return choice.get("action", "") == "eradicator-melta" and int(choice.get("target", -1)) == small and choice.get("value", "") == "multi")
	check(cap_options.size() == 0 and C.unit_choices(state, 1).any(func(choice: Dictionary) -> bool: return choice.get("action", "") == "eradicator-melta" and int(choice.get("model", -1)) == sergeant and choice.get("value", "") == "rifle" and str(choice.get("label", "")) == "Restore Melta Rifle"), "Three-model copy exposes restoration and blocks a second Multi-melta")
	var second_model := ordinary_model
	var malformed := {"action": "eradicator-melta", "model": second_model, "target": small, "value": "multi"}
	var over_cap_before := var_to_bytes(state)
	check(not str(C.UnitActions.apply(state, 1, malformed, Vector2.ZERO, Callable()).get("error", "")).is_empty() and over_cap_before == var_to_bytes(state), "Direct over-cap choice is rejected without changing state")
	var malformed_value := {"action": "eradicator-melta", "model": second_model, "target": small, "value": "heavy-bolter"}
	var malformed_before := var_to_bytes(state)
	check(not str(C.UnitActions.apply(state, 1, malformed_value, Vector2.ZERO, Callable()).get("error", "")).is_empty() and malformed_before == var_to_bytes(state), "Unsupported equipment value is rejected without changing state")
	var restore := choice_for(state, small, sergeant, "rifle")
	check(not restore.is_empty() and PublicUnitCommand.error(state, 1, restore).is_empty() and state.units[sergeant].ranged_weapons[0].id == "melta-rifle" and not state.units[sergeant].multi_melta, "Public preparation command can restore the Melta Rifle")
	var large_first := model_for(state, large, true)
	var large_choice := choice_for(state, large, large_first, "multi")
	check(not large_choice.is_empty() and PublicUnitCommand.error(state, 1, large_choice).is_empty(), "Six-model copy permits its first Multi-melta")
	var large_second := -1
	for candidate: int in six_models:
		if candidate != large_first: large_second = candidate; break
	var large_choice_second := choice_for(state, large, large_second, "multi")
	check(not large_choice_second.is_empty() and PublicUnitCommand.error(state, 1, large_choice_second).is_empty(), "Six-model copy permits its second Multi-melta")
	var large_cap_options := C.unit_choices(state, 1).filter(func(choice: Dictionary) -> bool: return choice.get("action", "") == "eradicator-melta" and int(choice.get("target", -1)) == large and choice.get("value", "") == "multi")
	check(large_cap_options.size() == 0, "Six-model copy blocks a third Multi-melta")
	set_target_keyword(state, target, "VEHICLE", true)
	var multi_failures: Array[String] = WeaponChecks.fixed_weapon_plan_failures(state, {"ranged": state.units[large_first].ranged_weapons.duplicate(true), "melee": state.units[large_first].melee_weapons.duplicate(true)}, large_first, target)
	check(multi_failures.is_empty(), "Both Multi-melta profiles resolve through Equipment/AttackPlan: %s" % str(multi_failures))

	var two_copy_catalog := Catalog.admit(two_copy_roster)
	check(two_copy_catalog.get("error", "").is_empty(), "Two current sourced copies remain constructible")
	check(Catalog.SPECS.get(UNIT, {}).get("current_reference", false) and Catalog.SPECS.get(UNIT, {}).get("validation_status", "") == "source_bounded_local_scope_passed_2026_10_28" and Catalog.SPECS.get(UNIT, {}).get("max_supported_copies", 0) == 2, "Melta Rifle Eradicators remain in the consolidated catalog with bounded evidence and Incursion copy metadata")
	print("Melta Rifle Eradicator checks: %d failures" % failures)
	quit(1 if failures else 0)
