extends SceneTree

const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Catalog = preload("res://scripts/edition_11/army_capabilities.gd")
const Roster = preload("res://scripts/edition_11/roster_validation.gd")
const AbilityCatalog = preload("res://scripts/edition_11/unit_ability_catalog.gd")
const Registry = preload("res://scripts/edition_11/capabilities.gd")
const LeaderLinks = preload("res://scripts/edition_11/marine_leader_links.gd")
const LeaderCatalog = preload("res://scripts/edition_11/leader_catalog.gd")
const SupportLinks = preload("res://scripts/edition_11/support_attachments.gd")
const PublicUnitCommand = preload("res://tests/public_unit_command.gd")
const WeaponChecks = preload("res://tests/space_marine_datasheet_checks.gd")
const UNIT := "inner-circle-companions"
const UNIT_ID := "40kdc:11e:adeptus-astartes:inner-circle-companions"
const A = C.UnitAbilities
const U = C.UnitActions

var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func entry(identity: String, models: int, copies: int = 1) -> Dictionary:
	return {"definition_id": "40kdc:11e:adeptus-astartes:" + identity, "models": models, "copies": copies}

func selections() -> Dictionary:
	var result := {}
	for owner: int in [1, 2]:
		var entries: Array = [entry(UNIT, 3), entry("captain", 1)]
		if owner == 1:
			entries.append(entry("apothecary", 1))
		else:
			entries.append(entry("intercessor-squad", 5))
		result[owner] = {"schema_version": 2, "faction": "Space Marines", "category": "custom", "points_limit": 1000, "entries": entries}
	return result

func fixture() -> Dictionary:
	var state: Dictionary = F.P.initial_state({
		"checked_rosters": false, "official_mission": false, "unit_abilities": true,
		"combat_doctrines": true, "core_stratagems": true, "attack_rerolls": true,
		"manual_allocation": false, "marine_chapters": {1: "DARK ANGELS", 2: "DARK ANGELS"}
	}, selections())
	if state.has("error"): return state
	state.phase = "deployment"
	state.active = 1
	return state

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

func choice_for(state: Dictionary, player: int, action: String, model: int = -1, target: int = -1) -> Dictionary:
	for option: Dictionary in U.choices(state, player):
		if str(option.get("action", "")) != action: continue
		if model >= 0 and int(option.get("model", -1)) != model: continue
		if target >= 0 and int(option.get("target", -1)) != target: continue
		return option
	return {}

func planned_hit_modifier(state: Dictionary, attacker: int, target: int, melee: bool, weapon_id: String, profile_id: String) -> Dictionary:
	var isolated: Dictionary = state.duplicate(true)
	var attacker_squad := int(isolated.units[attacker].squad)
	var owner := int(isolated.units[attacker].owner)
	for sibling: int in C.living(isolated, attacker_squad):
		if sibling != attacker: isolated.units[sibling].wounds = 0
	var target_models: Array[int] = C.living(isolated, target)
	if target_models.is_empty(): return {"error": "Target unit has no living models."}
	isolated.units[attacker].position = Vector2.ZERO
	isolated.units[target_models[0]].position = Vector2(1.75 if melee else 10.0, 0.0)
	isolated.phase = "fight" if melee else "shooting"
	isolated.active = owner
	isolated.unit_abilities.phase_key = U.key(isolated)
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
	return {"error": "", "hit_modifier": int(plan.batches[0].context.get("hit_modifier", 0)), "plan": plan}

func run() -> void:
	var profile := Profiles.profile(UNIT)
	check(profile.get("source_book_id") == "000000023" and profile.get("source_datasheet_id") == "000003698" and profile.get("source_export_updated_at") == "2026-10-21 16:06:23 GMT+3", "Inner Circle Companions cites the pinned 11e Dark Angels App identity")
	check(profile.get("points_by_models", {}) == {3: 90, 6: 180} and profile.get("third_plus_points_by_models", {}) == {3: 105, 6: 195}, "The 3/6-model sizes and first/second versus third-plus prices match the export")
	check(profile.get("base_size_source_mm") == 40 and is_equal_approx(float(profile.get("base_radius_inches", 0.0)), 20.0 / 25.4), "The 40 mm source base is represented as the runtime circle")
	check(profile.get("stats", {}) == {"movement_inches": 6, "toughness": 5, "save_target": 3, "wounds": 3, "leadership_target": 6, "objective_control": 2, "invulnerable_target": 0}, "M6/T5/Sv3+/W3/Ld6+/OC2 and no invulnerable save match the export")
	check(profile.get("keywords", []) == ["ADEPTUS ASTARTES", "DARK ANGELS", "INFANTRY", "TACTICUS", "IMPERIUM", "DEATHWING"], "Every source keyword, including Chapter and Deathwing, is represented")
	check(profile.get("default_loadout_by_role", {}).get("Inner Circle Companions", {}) == {"Calibanite Greatsword": 1, "Heavy Bolt Pistol": 1}, "Every model receives the fixed source loadout")
	check(profile.get("ranged", []).size() == 1 and profile.ranged[0].profiles.standard == {"name": "Heavy Bolt Pistol", "range_inches": 18.0, "attacks": 1, "skill": 3, "strength": 5, "ap": -1, "damage": 1, "keywords": {"close-quarters": true}}, "Heavy Bolt Pistol preserves its source profile")
	check(profile.get("melee", []).size() == 1 and profile.melee[0].id == "calibanite-greatsword" and profile.melee[0].profiles.sweep == {"name": "Calibanite Greatsword - Sweep", "range_inches": 0.0, "attacks": 5, "skill": 3, "strength": 6, "ap": -2, "damage": 1, "keywords": {"sustained-hits": 2}} and profile.melee[0].profiles.strike == {"name": "Calibanite Greatsword - Strike", "range_inches": 0.0, "attacks": 4, "skill": 3, "strength": 6, "ap": -2, "damage": 2, "keywords": {"lethal-hits": true}}, "Both Calibanite Greatsword profiles retain their source Lethal Hits and Sustained Hits traits")
	check(AbilityCatalog.RULES.get(UNIT, []) == ["combat-doctrines", "stealth", "braziers-of-judgement", "emnity-for-the-unworthy"], "Combat Doctrines and both datasheet abilities are assigned to the unit")
	for ability: String in ["braziers-of-judgement", "emnity-for-the-unworthy"]:
		var capability: Dictionary = Registry.KNOWN.get(ability, {})
		check(capability.get("category", "") == Registry.CATEGORY_UNIT and capability.get("supported", false) and capability.get("validation_status", "") == "source_bounded_local_scope_passed_2026_10_28", "%s has aligned source and validation metadata" % ability)
	check(Catalog.SPECS.get(UNIT, {}).get("current_reference", false) and Catalog.SPECS.get(UNIT, {}).get("validation_status", "") == "source_bounded_local_scope_passed_2026_10_28" and Roster.POINTS.get(UNIT, {}).get("sizes", {}) == {3: 90, 6: 180} and Roster.POINTS.get(UNIT, {}).get("third_plus_sizes", {}) == {3: 105, 6: 195}, "The current catalog and roster price map include both source sizes and tiers")
	var catalog_choice := Catalog.current_catalog_choice({"id": UNIT_ID, "edition": "11e", "faction": "Space Marines"})
	var options_by_models: Dictionary = {}
	for option: Dictionary in catalog_choice.get("options", []): options_by_models[int(option.models)] = option
	check(options_by_models == {3: {"models": 3, "cost": 90, "third_plus_cost": 105}, 6: {"models": 6, "cost": 180, "third_plus_cost": 195}}, "The construction catalog exposes both sizes and third-plus prices")
	var two_incursion := Catalog.admit({"schema_version": 2, "faction": "Space Marines", "category": "incursion", "points_limit": 1000, "entries": [entry(UNIT, 3, 2)]})
	var three_incursion := Catalog.admit({"schema_version": 2, "faction": "Space Marines", "category": "incursion", "points_limit": 1000, "entries": [entry(UNIT, 3, 3)]})
	var three_strike_force := Catalog.admit({"schema_version": 2, "faction": "Space Marines", "category": "strike_force", "points_limit": 2000, "entries": [entry(UNIT, 3, 3)]})
	check(two_incursion.get("error", "").is_empty() and int(two_incursion.get("total", -1)) == 180 and not str(three_incursion.get("error", "")).is_empty(), "Incursion admits two copies at 90 points and rejects a third")
	check(three_strike_force.get("error", "").is_empty() and int(three_strike_force.get("total", -1)) == 285, "Strike Force applies the 105-point third-copy tier")
	var resolved := Catalog.resolve("Space Marines", UNIT_ID)
	check(resolved.get("error", "").is_empty() and resolved.get("unit", {}).get("base", {}) == {"shape": "circle", "radius_inches": 20.0 / 25.4}, "Runtime construction resolves the exported base")

	var source_leaders: Array[String] = ["judiciar", "ancient", "chaplain", "lieutenant", "librarian", "captain", "apothecary", "lazarus", "ezekiel", "asmodai", "azrael"]
	for leader: String in source_leaders:
		check(UNIT in LeaderLinks.targets(leader), "The Chapter Leader map retains source relation %s → Inner Circle Companions" % leader)
	for support: String in ["judiciar", "ancient", "lieutenant", "apothecary"]:
		check(UNIT in SupportLinks.BODYGUARDS.get(support, []), "%s receives the Chapter target in the Support attachment map" % support)
	check(UNIT_ID in LeaderCatalog.ATTACHMENTS.get("40kdc:11e:adeptus-astartes:captain", []) and UNIT_ID in LeaderCatalog.ATTACHMENTS.get("40kdc:11e:adeptus-astartes:apothecary", []), "Leader catalog retains the current Captain and Apothecary Chapter target")

	var state := fixture()
	check(not state.has("error"), "Both Dark Angels rosters materialize the source-listed unit: %s" % str(state.get("error", "")))
	if state.has("error"):
		print("Inner Circle Companions checks: %d failures" % (failures + 1))
		quit(1)
		return
	var companions := models(state, UNIT, 1)
	var enemy_companions := models(state, UNIT, 2)
	var squad := squad_for(state, UNIT, 1)
	var enemy_character := models(state, "captain", 2)
	var enemy_intercessors := models(state, "intercessor-squad", 2)
	check(companions.size() == 3 and models(state, UNIT, 2).size() == 3 and int(state.squads[squad].training_cost) == 90, "Both players materialize the exact three-model 90-point unit")
	var defaults_ok := not companions.is_empty()
	for model: int in companions:
		if state.units[model].ranged_weapons.map(func(w: Dictionary) -> String: return w.id) != ["heavy-bolt-pistol"] or state.units[model].melee_weapons.map(func(w: Dictionary) -> String: return w.id) != ["calibanite-greatsword"]: defaults_ok = false
	check(defaults_ok and not companions.is_empty() and "DEATHWING" in state.units[companions[0]].get("keywords", []), "Every model receives its fixed weapons and Dark Angels Chapter context retains DEATHWING")
	check(A.has(state, squad, "combat-doctrines") and A.has(state, squad, "stealth") and A.every_model_has(state, squad, "stealth"), "Combat Doctrines and unit-wide Stealth are admitted for every companion")
	var apothecary := models(state, "apothecary", 1)
	var captain := models(state, "captain", 1)
	var leader_choice := choice_for(state, 1, "attach", captain[0], squad) if not captain.is_empty() else {}
	var leader_result := PublicUnitCommand.submit(state, 1, leader_choice)
	var support_choice := choice_for(state, 1, "attach", apothecary[0], squad) if not apothecary.is_empty() else {}
	var support_result := PublicUnitCommand.submit(state, 1, support_choice)
	check(not leader_choice.is_empty() and leader_result.get("error", "").is_empty() and int(state.units[captain[0]].squad) == squad, "Source-listed Captain attachment uses the public preparation command")
	check(not support_choice.is_empty() and support_result.get("error", "").is_empty() and int(state.units[apothecary[0]].squad) == squad and state.units[apothecary[0]].get("attachment_role", "") == "support", "Source-listed Apothecary Support attachment can join the Captain's unit through the public command")
	var weapon_failures: Array[String] = WeaponChecks.fixed_weapon_plan_failures(state, profile, companions[1], squad_for(state, "intercessor-squad", 2))
	check(weapon_failures.is_empty(), "All fixed weapon profiles resolve through Equipment and AttackPlan: %s" % str(weapon_failures))

	if not enemy_character.is_empty():
		var ranged_weapon: String = str(state.units[companions[0]].ranged_weapons[0].id)
		var ranged_bonus := planned_hit_modifier(state, companions[0], int(state.units[enemy_character[0]].squad), false, ranged_weapon, "standard")
		check(ranged_bonus.get("error", "").is_empty() and int(ranged_bonus.get("hit_modifier", 0)) == 1, "Emnity for the Unworthy grants +1 to the actual ranged AttackPlan against a CHARACTER")
	if not enemy_intercessors.is_empty():
		var intercessor_melee: Dictionary = state.units[enemy_intercessors[0]].melee_weapons[0]
		var melee_profile: String = str(intercessor_melee.profiles.keys()[0])
		var incoming_melee := planned_hit_modifier(state, enemy_intercessors[0], squad, true, str(intercessor_melee.id), melee_profile)
		check(incoming_melee.get("error", "").is_empty() and int(incoming_melee.get("hit_modifier", 0)) == -1, "Braziers of Judgement gives enemy melee attacks -1 to Hit in AttackPlan")
	if not enemy_companions.is_empty():
		var incoming_ranged := planned_hit_modifier(state, companions[0], squad_for(state, UNIT, 2), false, "heavy-bolt-pistol", "standard")
		check(incoming_ranged.get("error", "").is_empty() and int(incoming_ranged.get("hit_modifier", 0)) == 0, "Braziers' melee penalty does not leak into ranged AttackPlans: %s" % str(incoming_ranged))
	var six_state: Dictionary = state.duplicate(true)
	var six_selection := selections()
	six_selection[1].entries = [entry(UNIT, 6)]
	six_selection[2].entries = [entry(UNIT, 6)]
	six_state = F.P.initial_state({"checked_rosters": false, "unit_abilities": true, "combat_doctrines": true, "marine_chapters": {1: "DARK ANGELS", 2: "DARK ANGELS"}}, six_selection)
	check(not six_state.has("error") and models(six_state, UNIT, 1).size() == 6 and int(six_state.squads[squad_for(six_state, UNIT, 1)].training_cost) == 180, "Six-model unit size materializes at its source cost")
	if failures == 0: print("Inner Circle Companions checks: passed")
	else: print("Inner Circle Companions checks: %d failures" % failures)
	quit(0 if failures == 0 else 1)

func _initialize() -> void:
	call_deferred("run")
