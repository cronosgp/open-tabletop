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
const Prevention = preload("res://scripts/edition_11/unit_prevention.gd")
const WoundPrevention = preload("res://scripts/edition_11/wound_prevention.gd")
const PublicUnitCommand = preload("res://tests/public_unit_command.gd")
const WeaponChecks = preload("res://tests/space_marine_datasheet_checks.gd")
const UNIT := "lazarus"
const UNIT_ID := "40kdc:11e:adeptus-astartes:lazarus"
const A = C.UnitAbilities

var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func entry(identity: String, models: int = 1, copies: int = 1) -> Dictionary:
	return {"definition_id": "40kdc:11e:adeptus-astartes:" + identity, "models": models, "copies": copies}

func selections() -> Dictionary:
	return {
		1: {"schema_version": 2, "faction": "Space Marines", "category": "custom", "points_limit": 1000, "entries": [entry(UNIT), entry("inner-circle-companions", 3)]},
		2: {"schema_version": 2, "faction": "Space Marines", "category": "custom", "points_limit": 1000, "entries": [entry("intercessor-squad", 5)]}
	}

func fixture() -> Dictionary:
	return F.P.initial_state({"checked_rosters": false, "official_mission": false, "unit_abilities": true,
		"combat_doctrines": true, "core_stratagems": true, "attack_rerolls": true,
		"manual_allocation": false, "marine_chapters": {1: "DARK ANGELS", 2: "DARK ANGELS"}}, selections())

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
	for option: Dictionary in C.UnitActions.choices(state, player):
		if str(option.get("action", "")) != action: continue
		if model >= 0 and int(option.get("model", -1)) != model: continue
		if target >= 0 and int(option.get("target", -1)) != target: continue
		return option
	return {}

func run() -> void:
	var profile := Profiles.profile(UNIT)
	check(profile.get("source_book_id") == "000000023" and profile.get("source_datasheet_id") == "000002296" and profile.get("source_export_updated_at") == "2026-10-21 16:06:23 GMT+3", "Lazarus cites the pinned Dark Angels App source identity")
	check(profile.get("points_by_models", {}) == {1: 80} and profile.get("max_supported_copies", 0) == 1 and profile.get("base_size_source_mm") == 40, "The one-model 80-point Epic Hero profile, unique-copy limit and 40 mm base match the export")
	check(profile.get("stats", {}) == {"movement_inches": 6, "toughness": 5, "save_target": 3, "wounds": 5, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 4}, "Lazarus characteristics and 4+ invulnerable save match the export")
	check(profile.get("keywords", []) == ["ADEPTUS ASTARTES", "DARK ANGELS", "INFANTRY", "CAPTAIN", "TACTICUS", "IMPERIUM", "DEATHWING", "EXPLOSIVES", "EPIC HERO", "CHARACTER"], "Every source keyword is represented in the profile")
	check(profile.get("default_loadout_by_role", {}).get("Lazarus", {}) == {"Bolt Pistol": 1, "Enmity's Edge": 1}, "Lazarus's fixed source loadout is represented")
	check(profile.get("ranged", []).size() == 1 and profile.ranged[0].profiles.standard == {"name": "Bolt Pistol", "range_inches": 12.0, "attacks": 1, "skill": 2, "strength": 5, "ap": -1, "damage": 1, "keywords": {"close-quarters": true}}, "Bolt Pistol preserves its exported profile")
	check(profile.get("melee", []).size() == 1 and profile.melee[0].profiles.standard == {"name": "Enmity's Edge", "range_inches": 0.0, "attacks": 6, "skill": 2, "strength": 6, "ap": -3, "damage": 2, "keywords": {"anti-psyker": 2}}, "Enmity's Edge preserves Anti-Psyker 2+")
	check(AbilityCatalog.RULES.get(UNIT, []) == ["leader", "combat-doctrines", "transhuman-strategist", "intractable-will", "the-spiritshield-helm"], "Leader, Combat Doctrines, Warlord CP and both datasheet abilities are assigned")
	for ability: String in ["intractable-will", "the-spiritshield-helm"]:
		var capability: Dictionary = Registry.KNOWN.get(ability, {})
		check(capability.get("category", "") == Registry.CATEGORY_UNIT and capability.get("supported", false) and capability.get("source_status", "").contains("20261021T130623Z"), "%s has current source and aligned capability metadata" % ability)
	check(Catalog.SPECS.get(UNIT, {}).get("current_reference", false) and Roster.POINTS.get(UNIT, {}).get("cost", -1) == 80 and Roster.POINTS.get(UNIT, {}).get("max_supported_copies", 0) == 1, "Lazarus is in the current construction and roster-price catalogs")
	var current_choice := Catalog.current_catalog_choice({"id": UNIT_ID, "edition": "11e", "faction": "Space Marines"})
	check(current_choice.get("options", []) == [{"models": 1, "cost": 80}], "The local construction catalog exposes Lazarus at 80 points")
	var duplicate := Catalog.admit({"schema_version": 2, "faction": "Space Marines", "category": "incursion", "points_limit": 1000, "entries": [entry(UNIT), entry(UNIT)]})
	check(not str(duplicate.get("error", "")).is_empty(), "Incursion rejects a second Lazarus copy")
	var resolved := Catalog.resolve("Space Marines", UNIT_ID)
	check(resolved.get("error", "").is_empty() and resolved.get("unit", {}).get("base", {}) == {"shape": "circle", "radius_inches": 20.0 / 25.4}, "Runtime construction resolves the exported 40 mm base")

	var expected_targets: Array[String] = ["inner-circle-companions", "infernus-squad", "sternguard-veteran-squad", "intercessor-squad", "assault-intercessor-squad", "hellblaster-squad", "bladeguard-veteran-squad"]
	check(LeaderLinks.targets(UNIT).size() == expected_targets.size() and expected_targets.all(func(target: String) -> bool: return target in LeaderLinks.targets(UNIT)), "All seven source-listed Leader targets are available")
	check(LeaderCatalog.ATTACHMENTS.get(UNIT_ID, []).size() == expected_targets.size(), "The current attachment catalog includes all Lazarus targets")

	var state := fixture()
	check(not state.has("error"), "Lazarus and both Marine rosters materialize from current profiles: %s" % str(state.get("error", "")))
	if state.has("error"):
		print("Lazarus checks: %d failures" % (failures + 1))
		quit(1)
		return
	var lazarus_models := models(state, UNIT, 1)
	var companion_models := models(state, "inner-circle-companions", 1)
	var enemy_models := models(state, "intercessor-squad", 2)
	check(lazarus_models.size() == 1 and companion_models.size() == 3 and enemy_models.size() == 5, "The test rosters materialize Lazarus, Inner Circle Companions and the opposing unit")
	if lazarus_models.is_empty() or companion_models.size() != 3 or enemy_models.is_empty():
		print("Lazarus checks: %d failures" % (failures + 1))
		quit(1)
		return
	var lazarus_model: int = lazarus_models[0]
	var companion_squad := squad_for(state, "inner-circle-companions", 1)
	state.phase = "deployment"
	state.active = 1
	var warlord_choice := choice_for(state, 1, "warlord", lazarus_model)
	check(not warlord_choice.is_empty(), "Lazarus is available for Warlord designation")
	if not warlord_choice.is_empty():
		var cp_before := int(state.cp[1])
		var warlord_result := PublicUnitCommand.submit(state, 1, warlord_choice)
		state.active = 1
		C.UnitActions.start_round(state)
		C.UnitActions.start_round(state)
		check(warlord_result.get("error", "").is_empty() and int(state.unit_abilities.warlords.get(1, -1)) == lazarus_model and state.cp[1] == cp_before + 1, "Transhuman Strategist grants Lazarus's Warlord CP once per battle round")
	var attach_choice := choice_for(state, 1, "attach", lazarus_model, companion_squad)
	var attach_result := PublicUnitCommand.submit(state, 1, attach_choice)
	check(not attach_choice.is_empty() and attach_result.get("error", "").is_empty() and int(state.units[lazarus_model].squad) == companion_squad, "Lazarus joins Inner Circle Companions through the public Leader command")
	check("DEATHWING" in state.units[lazarus_model].get("keywords", []), "Dark Angels context applies Lazarus's Deathwing keyword")
	for failure: String in WeaponChecks.fixed_weapon_plan_failures(state, profile, lazarus_model, squad_for(state, "intercessor-squad", 2)):
		check(false, "Lazarus source weapon plan: " + failure)
	var lazarus_fnp: Array = Prevention.rules(state, lazarus_model)
	check(lazarus_fnp == [{"target": 3, "against": "psychic"}, {"target": 3, "against": "mortal"}], "The Spiritshield Helm grants only the two source Feel No Pain conditions")
	check(Prevention.rules(state, companion_models[0]) == lazarus_fnp, "The Spiritshield Helm protection extends to attached bodyguards")
	var psychic_fnp := WoundPrevention.resolve(1, 5, lazarus_fnp, "normal", func() -> int: return 3, "psychic")
	var mortal_fnp := WoundPrevention.resolve(1, 5, lazarus_fnp, "mortal", func() -> int: return 3)
	var normal_wound := WoundPrevention.resolve(1, 5, lazarus_fnp, "normal", Callable())
	check(psychic_fnp.error.is_empty() and psychic_fnp.prevented == 1 and mortal_fnp.error.is_empty() and mortal_fnp.prevented == 1, "The 3+ prevention applies to psychic and mortal wounds")
	check(normal_wound.error.is_empty() and normal_wound.lost == 1 and normal_wound.target == 0, "The Spiritshield Helm does not prevent ordinary wounds")

	var failed_state: Dictionary = state.duplicate(true)
	var squad_model: int = companion_models[0]
	failed_state.phase = "fight"
	failed_state.squads[companion_squad].fought = false
	failed_state.units[squad_model].wounds = 0
	var failed_roll: Dictionary = C.DetachmentStratagems.hold_destroyed(failed_state, squad_model, func() -> int: return 3)
	check(failed_roll.get("error", "").is_empty() and not failed_roll.get("held", false) and failed_roll.get("roll", 0) == 3 and failed_state.units[squad_model].wounds == 0, "Intractable Will fails on an unmodified 3")
	var retained_state: Dictionary = state.duplicate(true)
	var retained_model: int = companion_models[1]
	retained_state.phase = "fight"
	retained_state.squads[companion_squad].fought = false
	retained_state.units[retained_model].wounds = 0
	var retained: Dictionary = C.DetachmentStratagems.hold_destroyed(retained_state, retained_model, func() -> int: return 4)
	check(retained.get("error", "").is_empty() and retained.get("held", false) and retained.get("rule_name", "") == "Intractable Will" and retained_state.units[retained_model].wounds == 1, "Intractable Will retains a destroyed bodyguard model on 4+")
	C.DetachmentStratagems.remove_lingering(retained_state, squad_for(retained_state, "intercessor-squad", 2))
	check(retained_state.units[retained_model].wounds == 1, "A different unit fighting does not remove the retained bodyguard")
	C.DetachmentStratagems.remove_lingering(retained_state, companion_squad)
	check(retained_state.units[retained_model].wounds == 0 and not retained_state.units[retained_model].get("lazarus_intractable_lingering", false), "The model is removed when Lazarus's unit fights")
	var phase_end_state: Dictionary = state.duplicate(true)
	var phase_end_model: int = companion_models[2]
	phase_end_state.phase = "fight"
	phase_end_state.squads[companion_squad].fought = false
	phase_end_state.units[phase_end_model].wounds = 0
	var phase_end_hold: Dictionary = C.DetachmentStratagems.hold_destroyed(phase_end_state, phase_end_model, func() -> int: return 6)
	C.DetachmentStratagems.remove_lingering(phase_end_state)
	check(phase_end_hold.get("held", false) and phase_end_state.units[phase_end_model].wounds == 0, "A retained model is removed at Fight-phase end")
	var outside_window: Dictionary = state.duplicate(true)
	outside_window.phase = "shooting"
	outside_window.units[companion_models[0]].wounds = 0
	check(not C.DetachmentStratagems.hold_destroyed(outside_window, companion_models[0], func() -> int: return 4).get("held", false), "Intractable Will does not trigger outside the Fight phase")
	var already_fought: Dictionary = state.duplicate(true)
	already_fought.phase = "fight"
	already_fought.squads[companion_squad].fought = true
	already_fought.units[companion_models[0]].wounds = 0
	check(not C.DetachmentStratagems.hold_destroyed(already_fought, companion_models[0], func() -> int: return 4).get("held", false), "Intractable Will does not trigger after the unit has fought")

	if failures == 0: print("Lazarus checks: passed")
	else: print("Lazarus checks: %d failures" % failures)
	quit(0 if failures == 0 else 1)

func _initialize() -> void:
	call_deferred("run")
