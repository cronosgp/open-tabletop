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
const PublicUnitCommand = preload("res://tests/public_unit_command.gd")
const WeaponChecks = preload("res://tests/space_marine_datasheet_checks.gd")
const UNIT := "belial"
const UNIT_ID := "40kdc:11e:adeptus-astartes:belial"
const A = C.UnitAbilities

var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func entry(identity: String, models_count: int = 1) -> Dictionary:
	return {"definition_id": "40kdc:11e:adeptus-astartes:" + identity, "models": models_count, "copies": 1}

func selections() -> Dictionary:
	return {
		1: {"schema_version": 2, "faction": "Space Marines", "category": "custom", "points_limit": 1000, "entries": [entry(UNIT), entry("terminator-squad", 5)]},
		2: {"schema_version": 2, "faction": "Space Marines", "category": "custom", "points_limit": 1000, "entries": [entry("captain"), entry("intercessor-squad", 5)]}
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

func option(state: Dictionary, player: int, action: String, model: int = -1, target: int = -1, value: String = "") -> Dictionary:
	for item: Dictionary in C.UnitActions.choices(state, player):
		if str(item.get("action", "")) != action: continue
		if model >= 0 and int(item.get("model", -1)) != model: continue
		if target >= 0 and int(item.get("target", -1)) != target: continue
		if not value.is_empty() and str(item.get("value", "")) != value: continue
		return item
	return {}

func weapon(profile: Dictionary, category: String, identity: String) -> Dictionary:
	for item: Dictionary in profile.get(category, []):
		if str(item.get("id", "")) == identity: return item.get("profiles", {}).get("standard", {})
	return {}

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var profile := Profiles.profile(UNIT)
	check(profile.get("source_book_id") == "000000023" and profile.get("source_datasheet_id") == "000000219" and profile.get("source_export_updated_at") == "2026-10-21 16:06:23 GMT+3", "Belial identifies the pinned Dark Angels App datasheet")
	check(profile.get("points_by_models", {}) == {1: 100} and profile.get("models") == 1 and profile.get("max_supported_copies", 0) == 1, "Belial's one-model, 100-point Epic Hero composition and copy cap match the export")
	check(profile.get("base_size_source_mm") == 50 and is_equal_approx(float(profile.get("base_radius_inches", 0.0)), 25.0 / 25.4), "Belial uses the source 50 mm base")
	check(profile.get("stats", {}) == {"movement_inches": 5, "toughness": 6, "save_target": 2, "wounds": 6, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 4}, "M5/T6/Sv2+/W6/Ld6+/OC1 and 4+ invulnerable save match the export")
	check(profile.get("keywords", []) == ["ADEPTUS ASTARTES", "DARK ANGELS", "INFANTRY", "CAPTAIN", "CHARACTER", "EPIC HERO", "TERMINATOR", "DEATHWING", "IMPERIUM"], "All datasheet and faction keywords are represented")
	check(profile.get("default_loadout_by_role", {}).get("Belial", {}) == {"Master-crafted Storm Bolter": 1, "The Sword of Silence": 1}, "Belial's fixed source loadout is represented")
	check(weapon(profile, "ranged", "master-crafted-storm-bolter") == {"name": "Master-crafted Storm Bolter", "range_inches": 24.0, "attacks": 2, "skill": 2, "strength": 5, "ap": -1, "damage": 2, "keywords": {"precision": true}}, "Master-crafted Storm Bolter preserves its exported profile and Precision")
	check(weapon(profile, "melee", "the-sword-of-silence") == {"name": "The Sword of Silence", "range_inches": 0.0, "attacks": 6, "skill": 2, "strength": 6, "ap": -3, "damage": 2, "keywords": {}}, "The Sword of Silence preserves its exported profile")
	check(AbilityCatalog.RULES.get(UNIT, []) == ["leader", "deep-strike", "combat-doctrines", "transhuman-strategist", "grand-master-of-the-deathwing", "strikes-of-retribution"], "Core, Army and datasheet abilities are assigned")
	for ability: String in ["grand-master-of-the-deathwing", "strikes-of-retribution"]:
		var capability: Dictionary = Registry.KNOWN.get(ability, {})
		check(capability.get("category", "") == Registry.CATEGORY_UNIT and capability.get("supported", false) and capability.get("source_status", "").contains("20261021T130623Z") and capability.get("validation_status", "") == "source_bounded_local_scope_passed_2026_10_28", "%s has current source and aligned capability metadata" % ability)
	check(Catalog.SPECS.get(UNIT, {}).get("current_reference", false) and Roster.POINTS.get(UNIT, {}).get("cost", -1) == 100 and Roster.POINTS.get(UNIT, {}).get("max_supported_copies", 0) == 1, "Belial is in the current construction and roster-price catalogs")
	var current_choice := Catalog.current_catalog_choice({"id": UNIT_ID, "edition": "11e", "faction": "Space Marines"})
	check(current_choice.get("options", []) == [{"models": 1, "cost": 100}], "The current construction catalog exposes Belial at 100 points after targeted validation")
	var excess := Catalog.admit({"schema_version": 2, "faction": "Space Marines", "category": "custom", "points_limit": 3000, "entries": [entry(UNIT), entry(UNIT)]})
	check(not str(excess.get("error", "")).is_empty(), "The local catalog rejects a second Belial")

	var expected_targets: Array[String] = ["terminator-assault-squad", "terminator-squad", "deathwing-knights", "deathwing-terminator-squad"]
	check(LeaderLinks.targets(UNIT).size() == expected_targets.size() and expected_targets.all(func(target: String) -> bool: return target in LeaderLinks.targets(UNIT)), "Belial retains all four source-listed Leader targets")
	var catalog_targets: Array = LeaderCatalog.ATTACHMENTS.get(UNIT_ID, [])
	check(catalog_targets.size() == expected_targets.size(), "The attachment catalog includes all four source-listed targets")
	check(expected_targets.all(func(target: String) -> bool: return target in LeaderLinks.targets(UNIT)), "The compact Leader relation list retains all four targets")
	check(expected_targets.all(func(target: String) -> bool: return "40kdc:11e:adeptus-astartes:" + target in catalog_targets), "Leader attachment catalog includes all four fully qualified source-listed targets")
	check(Catalog.SPECS.get("terminator-squad", {}).get("current_reference", false) and Catalog.SPECS.get("terminator-assault-squad", {}).get("current_reference", false), "The two currently implemented Leader targets are selectable")
	check(Catalog.SPECS.get("deathwing-knights", {}).get("current_reference", false) and Catalog.SPECS.get("deathwing-terminator-squad", {}).get("current_reference", false), "Both Deathwing bodyguard datasheets are selectable targets")

	var state := fixture()
	check(not state.has("error"), "Belial and both current Marine rosters materialize: %s" % str(state.get("error", "")))
	if state.has("error"):
		print("Belial checks: %d failures" % (failures + 1))
		quit(1)
		return
	var belial_models := models(state, UNIT, 1)
	var terminators := models(state, "terminator-squad", 1)
	var enemy_captains := models(state, "captain", 2)
	var enemy_intercessors := models(state, "intercessor-squad", 2)
	check(belial_models.size() == 1 and terminators.size() == 5 and enemy_captains.size() == 1 and enemy_intercessors.size() == 5, "The local match contains Belial, five Terminators, an enemy Character and a non-Character target")
	if belial_models.is_empty() or terminators.is_empty() or enemy_captains.is_empty() or enemy_intercessors.is_empty():
		print("Belial checks: %d failures" % (failures + 1))
		quit(1)
		return
	var belial: int = belial_models[0]
	var belial_squad := int(state.units[belial].squad)
	var terminator_squad := int(state.units[terminators[0]].squad)
	var enemy_character_squad := int(state.units[enemy_captains[0]].squad)
	var enemy_noncharacter_squad := int(state.units[enemy_intercessors[0]].squad)
	var warlord_choice := option(state, 1, "warlord", belial)
	check(not warlord_choice.is_empty(), "Belial is available for Warlord designation")
	if not warlord_choice.is_empty():
		var cp_before := int(state.cp[1])
		var warlord_result := PublicUnitCommand.submit(state, 1, warlord_choice)
		state.active = 1
		C.UnitActions.start_round(state)
		C.UnitActions.start_round(state)
		check(warlord_result.get("error", "").is_empty() and int(state.unit_abilities.warlords.get(1, -1)) == belial and state.cp[1] == cp_before + 1, "Transhuman Strategist grants one Command point for Belial as Warlord each battle round")
	var attach_choice := option(state, 1, "attach", belial, terminator_squad)
	var attach_result := PublicUnitCommand.submit(state, 1, attach_choice)
	check(not attach_choice.is_empty() and attach_result.get("error", "").is_empty() and int(state.units[belial].squad) == terminator_squad, "Belial attaches to a source-listed Terminator Squad through the public Leader action")
	check("DEATHWING" in state.units[belial].get("keywords", []) and A.has(state, terminator_squad, "grand-master-of-the-deathwing"), "Dark Angels context and Belial's Deathwing ability survive attachment")
	var weapon_failures := WeaponChecks.fixed_weapon_plan_failures(state, profile, belial, enemy_character_squad)
	check(weapon_failures.is_empty(), "Both fixed Belial weapons resolve through Equipment and AttackPlan: %s" % str(weapon_failures))

	var bodyguard := int(terminators[0])
	state.terrain.areas = []
	for model: int in state.units:
		if int(state.units[model].get("owner", -1)) == 1: state.units[model].position = Vector2(-8, 0)
		elif A.identity(state.units[model]) == "captain": state.units[model].position = Vector2(0, 0)
		else: state.units[model].position = Vector2(8, 0)
	state.phase = "shooting"
	state.active = 1
	var ranged_character := C.AttackPlan.prepare(state, terminator_squad, false, [{"model": bodyguard, "target": enemy_character_squad, "amount": 1, "weapon": "storm-bolter", "profile": "standard"}], true)
	var ranged_noncharacter := C.AttackPlan.prepare(state, terminator_squad, false, [{"model": bodyguard, "target": enemy_noncharacter_squad, "amount": 1, "weapon": "storm-bolter", "profile": "standard"}], true)
	check(ranged_character.get("error", "").is_empty() and ranged_character.get("batches", []).size() == 1 and int(ranged_character.batches[0].context.get("wound_modifier", 0)) == 1, "Grand Master of the Deathwing grants +1 to Wound for an attached Terminator's ranged attack against a CHARACTER")
	check(ranged_noncharacter.get("error", "").is_empty() and ranged_noncharacter.get("batches", []).size() == 1 and int(ranged_noncharacter.batches[0].context.get("wound_modifier", 0)) == 0, "Grand Master of the Deathwing does not modify ranged attacks against a non-CHARACTER unit")

	state.phase = "fight"
	state.units[bodyguard].position = Vector2(-1.2, 0)
	var character_rows: Array = C.AttackPlan.single_target(state, terminator_squad, enemy_character_squad, true).filter(func(row: Dictionary) -> bool: return int(row.get("model", -1)) == bodyguard)
	var character_attack := C.AttackPlan.prepare(state, terminator_squad, true, [character_rows[0]] if not character_rows.is_empty() else [], true)
	check(character_attack.get("error", "").is_empty() and character_attack.get("batches", []).size() == 1 and int(character_attack.batches[0].context.get("wound_modifier", 0)) == 1, "Grand Master of the Deathwing grants +1 to Wound for an attached Terminator's melee attack against a CHARACTER")
	state.units[enemy_captains[0]].position = Vector2(8, 0)
	for model: int in enemy_intercessors: state.units[model].position = Vector2(0, 0)
	var ordinary_rows: Array = C.AttackPlan.single_target(state, terminator_squad, enemy_noncharacter_squad, true).filter(func(row: Dictionary) -> bool: return int(row.get("model", -1)) == bodyguard)
	var ordinary_attack := C.AttackPlan.prepare(state, terminator_squad, true, [ordinary_rows[0]] if not ordinary_rows.is_empty() else [], true)
	check(ordinary_attack.get("error", "").is_empty() and ordinary_attack.get("batches", []).size() == 1 and int(ordinary_attack.batches[0].context.get("wound_modifier", 0)) == 0, "Grand Master of the Deathwing does not modify attacks against a non-CHARACTER unit")

	var failed_state: Dictionary = state.duplicate(true)
	failed_state.phase = "fight"
	failed_state.squads[terminator_squad].fought = false
	failed_state.units[belial].wounds = 0
	var failed_roll: Dictionary = C.DetachmentStratagems.hold_destroyed(failed_state, belial, func() -> int: return 1)
	check(failed_roll.get("error", "").is_empty() and not failed_roll.get("held", false) and failed_roll.get("rule", "") == "strikes-of-retribution" and failed_state.units[belial].wounds == 0, "Strikes of Retribution fails on an unmodified 1")

	var retained_state: Dictionary = state.duplicate(true)
	retained_state.phase = "fight"
	retained_state.squads[terminator_squad].fought = false
	retained_state.units[belial].wounds = 0
	var retained: Dictionary = C.DetachmentStratagems.hold_destroyed(retained_state, belial, func() -> int: return 2)
	check(retained.get("error", "").is_empty() and retained.get("held", false) and retained.get("rule_name", "") == "Strikes of Retribution" and retained_state.units[belial].wounds == 1, "Strikes of Retribution retains Belial on an unmodified 2+")
	C.DetachmentStratagems.remove_lingering(retained_state, enemy_character_squad)
	check(retained_state.units[belial].wounds == 1, "Another unit fighting does not remove retained Belial")
	C.DetachmentStratagems.remove_lingering(retained_state, terminator_squad)
	check(retained_state.units[belial].wounds == 0 and not retained_state.units[belial].get("belial_strikes_lingering", false), "Belial is removed after his unit fights")

	var phase_end_state: Dictionary = state.duplicate(true)
	phase_end_state.phase = "fight"
	phase_end_state.squads[terminator_squad].fought = false
	phase_end_state.units[belial].wounds = 0
	var phase_end_hold: Dictionary = C.DetachmentStratagems.hold_destroyed(phase_end_state, belial, func() -> int: return 6)
	C.DetachmentStratagems.remove_lingering(phase_end_state)
	check(phase_end_hold.get("held", false) and phase_end_state.units[belial].wounds == 0, "Retained Belial is removed at Fight-phase end")

	var bodyguard_state: Dictionary = state.duplicate(true)
	bodyguard_state.phase = "fight"
	bodyguard_state.squads[terminator_squad].fought = false
	bodyguard_state.units[bodyguard].wounds = 0
	var bodyguard_destroyed: Dictionary = C.DetachmentStratagems.hold_destroyed(bodyguard_state, bodyguard, func() -> int: return 6)
	check(not bodyguard_destroyed.get("held", false), "Strikes of Retribution does not retain a destroyed Terminator bodyguard")

	var outside_window: Dictionary = state.duplicate(true)
	outside_window.phase = "shooting"
	outside_window.units[belial].wounds = 0
	check(not C.DetachmentStratagems.hold_destroyed(outside_window, belial, func() -> int: return 6).get("held", false), "Strikes of Retribution does not trigger outside the Fight phase")
	var already_fought: Dictionary = state.duplicate(true)
	already_fought.phase = "fight"
	already_fought.squads[terminator_squad].fought = true
	already_fought.units[belial].wounds = 0
	check(not C.DetachmentStratagems.hold_destroyed(already_fought, belial, func() -> int: return 6).get("held", false), "Strikes of Retribution does not trigger after Belial's unit has fought")

	if failures == 0: print("Belial source-bounded local checks passed")
	else: print("Belial checks: %d failures" % failures)
	quit(1 if failures else 0)
