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
const WeaponChecks = preload("res://tests/space_marine_datasheet_checks.gd")
const PublicUnitCommand = preload("res://tests/public_unit_command.gd")
const UNIT := "commander-dante"
const UNIT_ID := "40kdc:11e:adeptus-astartes:commander-dante"
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
		1: {"schema_version": 2, "faction": "Space Marines", "category": "custom", "points_limit": 1000, "entries": [entry(UNIT), entry("sanguinary-guard", 3), entry("assault-intercessors-with-jump-packs", 5), entry("vanguard-veteran-squad-with-jump-packs", 5)]},
		2: {"schema_version": 2, "faction": "Space Marines", "category": "custom", "points_limit": 1000, "entries": [entry("captain"), entry("intercessor-squad", 5), entry("judiciar"), entry("chaplain")]}
	}

func fixture() -> Dictionary:
	return F.P.initial_state({"checked_rosters": false, "official_mission": false, "unit_abilities": true, "combat_doctrines": true, "core_stratagems": true, "manual_allocation": false, "marine_chapters": {1: "BLOOD ANGELS", 2: "BLOOD ANGELS"}}, selections())

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

func run() -> void:
	var profile := Profiles.profile(UNIT)
	check(profile.get("source_book_id") == "000000021" and profile.get("source_datasheet_id") == "000000151" and profile.get("source_snapshot_id") == "20261021T130623Z", "Dante cites the pinned Blood Angels datasheet identity and export snapshot")
	check(profile.get("points_by_models", {}) == {1: 140} and profile.get("max_supported_copies", 0) == 1, "The one-model, 140-point Epic Hero profile has the correct single-copy cap")
	check(profile.get("stats", {}) == {"movement_inches": 12, "toughness": 5, "save_target": 2, "wounds": 6, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 4}, "Dante's characteristics match the local export")
	check("BLOOD ANGELS" in profile.get("keywords", []) and "CHAPTER MASTER" in profile.get("keywords", []) and "JUMP PACK" in profile.get("keywords", []) and "EPIC HERO" in profile.get("keywords", []), "The source Chapter, Epic Hero, Chapter Master and Jump Pack keywords are represented")
	check(profile.get("ranged", []).size() == 1 and profile.ranged[0].profiles.standard == {"name": "Perdition Pistol", "range_inches": 9.0, "attacks": 1, "skill": 2, "strength": 10, "ap": -3, "damage": "D3+2", "keywords": {"sustained-hits": 1, "melta": 2, "close-quarters": true}}, "Perdition Pistol retains its full source profile")
	check(profile.get("melee", []).size() == 1 and profile.melee[0].profiles.standard == {"name": "The Axe Mortalis", "range_inches": 0.0, "attacks": 8, "skill": 2, "strength": 8, "ap": -3, "damage": 2, "keywords": {"lethal-hits": true}}, "The Axe Mortalis retains its full source profile")
	check(AbilityCatalog.RULES.get(UNIT, []) == ["deep-strike", "leader", "combat-doctrines", "transhuman-strategist", "death-mask-of-sanguinius", "warden-of-the-imperium-nihilus"], "Dante's source abilities are assigned to his runtime profile")
	for ability: String in ["death-mask-of-sanguinius", "warden-of-the-imperium-nihilus"]:
		var capability: Dictionary = Registry.KNOWN.get(ability, {})
		check(capability.get("category", "") == Registry.CATEGORY_UNIT and capability.get("supported", false) and capability.get("source_status", "").contains("20261021T130623Z") and capability.get("validation_status", "") == "source_bounded_local_scope_passed_2026_10_28", "%s has aligned source and locally validated capability metadata" % ability)
	check(Catalog.SPECS.get(UNIT, {}).get("current_reference", false) and Roster.POINTS.get(UNIT, {}).get("cost", -1) == 140 and Roster.POINTS.get(UNIT, {}).get("max_supported_copies", 0) == 1, "Dante is in the current construction and roster price catalogs")
	var current_choice := Catalog.current_catalog_choice({"id": UNIT_ID, "edition": "11e", "faction": "Space Marines"})
	check(current_choice.get("options", []) == [{"models": 1, "cost": 140}], "The local current catalog exposes Dante at the verified 140-point price")
	var duplicate_admission := Catalog.admit({"schema_version": 2, "faction": "Space Marines", "category": "incursion", "points_limit": 1000, "entries": [entry(UNIT), entry(UNIT)]})
	check(not str(duplicate_admission.get("error", "")).is_empty(), "Incursion admission rejects a second Commander Dante copy")
	var expected_targets: Array[String] = ["assault-intercessors-with-jump-packs", "vanguard-veteran-squad-with-jump-packs", "sanguinary-guard"]
	check(LeaderLinks.targets(UNIT).size() == expected_targets.size() and expected_targets.all(func(target: String) -> bool: return target in LeaderLinks.targets(UNIT)), "Dante retains all three source-listed Leader targets")
	check(LeaderCatalog.ATTACHMENTS.get(UNIT_ID, []).size() == expected_targets.size(), "Dante's current attachment catalog exposes each available source endpoint")

	var state := fixture()
	check(not state.has("error"), "Both Blood Angels context rosters materialize Dante, bodyguard endpoints and test targets: %s" % str(state.get("error", "")))
	if state.has("error"):
		print("Commander Dante checks: %d failures" % (failures + 1))
		quit(1)
		return
	var dante_models := models(state, UNIT, 1)
	var enemy_captains := models(state, "captain", 2)
	var enemy_intercessors := models(state, "intercessor-squad", 2)
	var boundary_characters := models(state, "judiciar", 2)
	var outside_characters := models(state, "chaplain", 2)
	check(dante_models.size() == 1 and enemy_captains.size() == 1 and enemy_intercessors.size() == 5 and boundary_characters.size() == 1 and outside_characters.size() == 1, "The local interaction fixture contains Dante, an enemy Character, a non-Character unit and Characters at/over the 6-inch boundary")
	if dante_models.is_empty() or enemy_captains.is_empty() or enemy_intercessors.is_empty() or boundary_characters.is_empty() or outside_characters.is_empty():
		print("Commander Dante checks: %d failures" % (failures + 1))
		quit(1)
		return
	var dante := dante_models[0]
	state.phase = "deployment"
	state.active = 1
	var warlord_choice := choice_for(state, 1, "warlord", dante)
	check(not warlord_choice.is_empty(), "Transhuman Strategist makes Dante eligible to be the Warlord")
	if not warlord_choice.is_empty():
		state.cp[1] = 3
		var cp_before := int(state.cp[1])
		var warlord_result := PublicUnitCommand.submit(state, 1, warlord_choice)
		C.UnitActions.start_round(state)
		C.UnitActions.start_round(state)
		check(warlord_result.get("error", "").is_empty() and int(state.unit_abilities.warlords.get(1, -1)) == dante and int(state.cp[1]) == cp_before + 1, "Dante can be assigned as Warlord and Transhuman Strategist grants its once-per-round CP through the public flow")
	var guard_squad := squad_for(state, "sanguinary-guard", 1)
	var attach_choice := choice_for(state, 1, "attach", dante, guard_squad)
	var attach_result := PublicUnitCommand.submit(state, 1, attach_choice)
	check(not attach_choice.is_empty() and attach_result.get("error", "").is_empty() and int(state.units[dante].squad) == guard_squad, "Dante joins Sanguinary Guard through the source-listed Leader link")
	state.unit_abilities.doctrines[guard_squad] = {"doctrine": "devastator"}
	var dante_doctrines := C.Doctrines.active_doctrines_for(state, guard_squad)
	check("devastator" in dante_doctrines and "assault" in dante_doctrines and "tactical" in dante_doctrines, "Dante's attached unit keeps Assault and Tactical alongside another active doctrine")
	var weapon_failures: Array[String] = WeaponChecks.fixed_weapon_plan_failures(state, profile, dante, squad_for(state, "captain", 2))
	check(weapon_failures.is_empty(), "Both fixed weapons resolve through Equipment and AttackPlan: %s" % str(weapon_failures))

	state.units[dante].position = Vector2.ZERO
	state.units[enemy_captains[0]].position = Vector2(3.0, 0.0)
	state.units[boundary_characters[0]].position = Vector2(state.units[dante].radius + state.units[boundary_characters[0]].radius + 6.0, 0.0)
	state.units[outside_characters[0]].position = Vector2(state.units[dante].radius + state.units[outside_characters[0]].radius + 6.05, 0.0)
	for index: int in range(enemy_intercessors.size()): state.units[enemy_intercessors[index]].position = Vector2(0.0, 3.0 + float(index) * 0.35)
	state.phase = "charge"
	state.active = 1
	var transition := C.advance_phase(state, 1, state.revision, func() -> int: return 1)
	var target_squads: Array = state.get("death-mask-of-sanguinius", {}).get("targets", [])
	var expected_squads: Array[int] = [squad_for(state, "captain", 2), squad_for(state, "intercessor-squad", 2), squad_for(state, "judiciar", 2)]
	expected_squads.sort()
	check(transition.is_empty() and state.phase == "fight" and target_squads == expected_squads, "Fight-phase start includes a Character exactly 6 inches away and non-Characters, and excludes the unit just beyond range")
	check(C.UnitActions.pending_decision(state).get("priority_player_id", -1) == 1 and C.UnitActions.pending_decision(state).get("resume_frame_id", "") != "", "Death Mask opens an actor-owned, persisted Fight-phase decision")
	var restored: Dictionary = bytes_to_var(var_to_bytes(state))
	check(C.UnitActions.pending_decision(restored).get("decision_id", "") == C.UnitActions.pending_decision(state).get("decision_id", ""), "The Death Mask decision survives save and restore")
	for target: int in expected_squads:
		var roll_choice := choice_for(restored, 1, "death-mask-of-sanguinius", -1, target, "roll")
		var roll_result := PublicUnitCommand.submit(restored, 1, roll_choice, Vector2.ZERO, func() -> int: return 1)
		check(not roll_choice.is_empty() and str(roll_result.get("error", "")).is_empty() and restored.squads[target].battle_shocked, "Death Mask applies the -1 Battle-shock test to eligible target %s" % restored.squads[target].name)
	var last_results: Array = restored.get("last_death_mask_of_sanguinius", [])
	check(last_results.size() == expected_squads.size() and last_results.all(func(result: Dictionary) -> bool: return int(result.get("modifier", 0)) == -1) and restored.get("death-mask-of-sanguinius", {}).is_empty() and C.ResolutionFrames.current(restored).is_empty(), "All tests are recorded with their modifier before the Fight phase resumes")

	if failures == 0: print("Commander Dante checks: passed")
	else: print("Commander Dante checks: %d failures" % failures)
	quit(0 if failures == 0 else 1)

func _initialize() -> void:
	call_deferred("run")
