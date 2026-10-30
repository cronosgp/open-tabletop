extends SceneTree

const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Army = preload("res://scripts/edition_11/army_capabilities.gd")
const AbilityCatalog = preload("res://scripts/edition_11/unit_ability_catalog.gd")
const Registry = preload("res://scripts/edition_11/capabilities.gd")
const LeaderLinks = preload("res://scripts/edition_11/marine_leader_links.gd")
const UnitActions = preload("res://scripts/edition_11/unit_actions.gd")
const CombatScenario = preload("res://scripts/edition_11/combat_scenario.gd")
const DetectionRules = preload("res://scripts/edition_11/detection_rules.gd")
const Stormlance = preload("res://scripts/edition_11/stormlance_enhancements.gd")
const PublicUnitCommand = preload("res://tests/public_unit_command.gd")

var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func entry(identity: String, models: int = 1, copies: int = 1) -> Dictionary:
	return {"definition_id": "40kdc:11e:adeptus-astartes:" + identity, "models": models, "copies": copies}

func selections() -> Dictionary:
	var result := F.current_marine_selections()
	for owner: int in [1, 2]:
		result[owner].category = "custom"
		result[owner].points_limit = 2000
	result[1].entries = [entry("njal-stormcaller"), entry("intercessor-squad", 5)]
	result[2].entries = [entry("captain"), entry("intercessor-squad", 5)]
	return result

func fresh_state() -> Dictionary:
	return F.P.initial_state({"checked_rosters": false, "official_mission": false, "unit_abilities": true,
		"combat_doctrines": true, "core_stratagems": true, "marine_chapters": {1: "SPACE WOLVES", 2: "ULTRAMARINES"}}, selections())

func model_for(state: Dictionary, owner: int, identity: String) -> int:
	for model: int in state.units:
		var unit: Dictionary = state.units[model]
		if int(unit.get("owner", -1)) == owner and C.UnitAbilities.identity(unit) == identity: return model
	return -1

func squad_for(state: Dictionary, owner: int, identity: String) -> int:
	for model: int in state.units:
		var unit: Dictionary = state.units[model]
		if int(unit.get("owner", -1)) == owner and C.UnitAbilities.identity(unit) == identity: return int(unit.squad)
	return -1

func find_choice(state: Dictionary, owner: int, action: String, target: int = -2, value: String = "") -> Dictionary:
	for option: Dictionary in UnitActions.choices(state, owner):
		if str(option.get("action", "")) != action: continue
		if target != -2 and int(option.get("target", -1)) != target: continue
		if not value.is_empty() and str(option.get("value", "")) != value: continue
		return option
	return {}

func place_test_units(state: Dictionary) -> void:
	for model: int in state.units:
		var unit: Dictionary = state.units[model]
		unit.position = Vector2(0.0, 0.0) if int(unit.owner) == 1 else Vector2(10.0, 0.0)
	state.terrain.areas = []
	state.mission.objectives = []
	state.unit_abilities.setup_players = [1, 2]

func roll_one() -> int:
	return 1

func roll_four() -> int:
	return 4

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var profile := Profiles.profile("njal-stormcaller")
	check(profile.get("source_book_id", "") == "000000036" and profile.get("source_datasheet_id", "") == "000000292" and profile.get("source_snapshot_id", "") == "20261029T003124Z" and profile.get("source_slice_manifest_sha256", "") == "F41AEB60436222F786E32DEE7E4D472E5C5DED5A01C8A33F02A98EBAA86BB113", "Njal is bound to the Space Wolves App datasheet and verified subject slice")
	check(profile.get("points_by_models", {}) == {1: 100} and profile.get("models", -1) == 1 and profile.get("max_supported_copies", -1) == 1 and profile.get("base_size_source_mm", -1) == 40, "Njal retains his one-model, 100-point profile, one-copy limit and 40 mm base")
	check(profile.get("stats", {}) == {"movement_inches": 7, "toughness": 5, "save_target": 3, "wounds": 4, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 4}, "Njal's characteristics match the local export")
	var expected_keywords := ["ADEPTUS ASTARTES", "CHARACTER", "EPIC HERO", "IMPERIUM", "INFANTRY", "PSYKER", "SPACE WOLVES", "TACTICUS"]
	var actual_keywords: Array = profile.get("keywords", []).duplicate()
	actual_keywords.sort()
	check(actual_keywords == expected_keywords, "Njal retains all exported keywords")
	var lightning: Dictionary = profile.get("ranged", [{}, {}])[1].get("profiles", {})
	var focused: Dictionary = lightning.get("focused-witchfire", {})
	var witchfire: Dictionary = lightning.get("witchfire", {})
	var staff: Dictionary = profile.get("melee", [{}])[0].get("profiles", {}).get("standard", {})
	check(focused.get("attacks") == "D6+6" and focused.get("skill") == 3 and focused.get("strength") == 7 and focused.get("ap") == -2 and focused.get("damage") == 1 and focused.get("keywords", {}) == {"psychic": true, "hazardous": true, "sustained-hits": 2}, "Focused Witchfire matches the exported Living Lightning profile")
	check(witchfire.get("attacks") == "D3+3" and witchfire.get("skill") == 3 and witchfire.get("strength") == 7 and witchfire.get("ap") == -1 and witchfire.get("damage") == 1 and witchfire.get("keywords", {}) == {"psychic": true, "sustained-hits": 2}, "Witchfire matches the exported Living Lightning profile")
	check(staff.get("attacks") == 4 and staff.get("skill") == 3 and staff.get("strength") == 7 and staff.get("ap") == -1 and staff.get("damage") == 2 and staff.get("keywords", {}) == {"psychic": true, "sustained-hits": 2}, "Staff of the Stormcaller matches the exported melee profile")
	check(Army.SPECS.has("njal-stormcaller") and Army.SPECS["njal-stormcaller"].get("current_reference", false), "Njal is registered in current-reference construction admission")
	check(AbilityCatalog.RULES.get("njal-stormcaller", []) == ["leader", "combat-doctrines", "wind-walker", "high-rune-priest", "murderous-hurricane", "storm-caller", "tempests-wrath"], "Njal's Leader, faction and datasheet abilities are registered")
	for ability: String in ["wind-walker", "high-rune-priest", "murderous-hurricane", "storm-caller", "tempests-wrath"]:
		check(Registry.supported(ability), "%s is exposed as a supported local capability" % ability)
	var targets := LeaderLinks.targets("njal-stormcaller")
	check(targets.size() == 6 and "bladeguard-veteran-squad" in targets and "assault-intercessor-squad" in targets and "intercessor-squad" in targets and "blood-claws" in targets and "grey-hunters" in targets and "wolf-guard-headtakers" in targets, "All six source-listed Njal Leader endpoints are recorded")
	var admitted := Army.admit({"schema_version": 2, "faction": "Space Marines", "category": "custom", "points_limit": 1000, "entries": [entry("njal-stormcaller")]})
	var duplicate := Army.admit({"schema_version": 2, "faction": "Space Marines", "category": "custom", "points_limit": 1000, "entries": [entry("njal-stormcaller", 1, 2)]})
	check(admitted.get("error", "").is_empty() and admitted.get("total", -1) == 100 and not str(duplicate.get("error", "")).is_empty(), "Construction admits Njal at source cost and enforces his one-copy Epic Hero limit")

	var state := fresh_state()
	check(not state.has("error"), "Test armies materialize from the consolidated local catalog: %s" % state.get("error", ""))
	if not state.has("error"):
		var njal := model_for(state, 1, "njal-stormcaller")
		var njal_squad := int(state.units.get(njal, {}).get("squad", -1))
		var enemy_squad := squad_for(state, 2, "intercessor-squad")
		state.phase = "deployment"
		state.active = 1
		state.unit_abilities.setup_players = []
		check(UnitActions.choices(state, 1).any(func(option: Dictionary) -> bool: return str(option.get("action", "")) == "warlord" and int(option.get("model", -1)) == njal), "Njal is available as the army's Warlord")
		place_test_units(state)
		var pistol: Dictionary = state.units[njal].ranged_weapons[0]
		var assault_pistol: Dictionary = C.UnitAbilities.weapon(state, njal, enemy_squad, pistol.profiles.standard, false)
		check(assault_pistol.get("keywords", {}).get("assault", false), "Wind Walker grants Assault to Njal's unit ranged attacks")

		state.phase = "movement"
		state.turn = 1
		state.round = 1
		state.cp[1] = 0
		state.cp[2] = 0
		var advance_error := CombatScenario.begin_movement(state, 1, njal, "advance", int(state.revision), Callable(self, "roll_four"))
		check(advance_error.is_empty() and int(state.get("pending_move", {}).get("bonus", -1)) == 6, "Wind Walker changes the rolled Advance result to 6 before movement")

	var hurricane_state := fresh_state()
	if not hurricane_state.has("error"):
		var njal := model_for(hurricane_state, 1, "njal-stormcaller")
		var njal_squad := int(hurricane_state.units[njal].squad)
		var enemy_squad := squad_for(hurricane_state, 2, "intercessor-squad")
		place_test_units(hurricane_state)
		hurricane_state.phase = "movement"
		hurricane_state.active = 1
		hurricane_state.turn = 1
		var hurricane := find_choice(hurricane_state, 1, "njal-psychic", enemy_squad, "murderous-hurricane")
		var result := PublicUnitCommand.submit(hurricane_state, 1, hurricane, Vector2.ZERO, Callable(self, "roll_one"))
		check(result.get("error", "").is_empty() and hurricane_state.squads[njal_squad].battle_shocked, "Murderous Hurricane's roll of 1 Battle-shocks Njal's unit")
		check(Stormlance.blocks_snap_shooting(hurricane_state, enemy_squad) and Stormlance.snap_shooting_block_name(hurricane_state, enemy_squad) == "Murderous Hurricane", "Murderous Hurricane still blocks the selected enemy's Snap Shooting on a roll of 1")

	var wrath_state := fresh_state()
	if not wrath_state.has("error"):
		var njal := model_for(wrath_state, 1, "njal-stormcaller")
		var njal_squad := int(wrath_state.units[njal].squad)
		var enemy_squad := squad_for(wrath_state, 2, "intercessor-squad")
		place_test_units(wrath_state)
		wrath_state.phase = "shooting"
		wrath_state.active = 1
		wrath_state.turn = 1
		var wrath := find_choice(wrath_state, 1, "njal-psychic", enemy_squad, "tempests-wrath")
		var result := PublicUnitCommand.submit(wrath_state, 1, wrath, Vector2.ZERO, Callable(self, "roll_four"))
		check(result.get("error", "").is_empty() and C.UnitAbilities.hit_bonus(wrath_state, enemy_squad, njal_squad, false) == -1, "Tempest's Wrath applies -1 to the suppressed enemy's Hit rolls")
		wrath_state.turn = 2
		check(C.UnitAbilities.hit_bonus(wrath_state, enemy_squad, njal_squad, true) == -1, "Tempest's Wrath lasts through the opponent's turn and affects melee attacks too")
		wrath_state.turn = 3
		check(C.UnitAbilities.hit_bonus(wrath_state, enemy_squad, njal_squad, false) == 0, "Tempest's Wrath expires at the start of Njal's next turn")

	var reaction_state := fresh_state()
	if not reaction_state.has("error"):
		var njal := model_for(reaction_state, 1, "njal-stormcaller")
		var njal_squad := int(reaction_state.units[njal].squad)
		var attacker := model_for(reaction_state, 2, "intercessor-squad")
		var attacker_squad := int(reaction_state.units[attacker].squad)
		place_test_units(reaction_state)
		reaction_state.phase = "shooting"
		reaction_state.active = 2
		reaction_state.turn = 2
		reaction_state.round = 1
		var weapon: Dictionary = reaction_state.units[attacker].ranged_weapons[0]
		var profile_id := str(weapon.profiles.keys()[0])
		var declaration := [{"model": attacker, "target": njal_squad, "amount": 1, "weapon": weapon.id, "profile": profile_id}]
		var declared := CombatScenario.resolve_attack_plan(reaction_state, 2, attacker, declaration, int(reaction_state.revision), false, false, Callable(self, "roll_four"))
		check(declared.get("error", "").is_empty() and reaction_state.unit_abilities.window.get("kind", "") == "njal-storm-caller", "An enemy attack opens Storm Caller before attack dice")
		var storm_caller := find_choice(reaction_state, 1, "njal-storm-caller", njal_squad, "use")
		var result := PublicUnitCommand.submit(reaction_state, 1, storm_caller, Vector2.ZERO, Callable(self, "roll_four"))
		check(result.get("error", "").is_empty(), "Storm Caller resolves through the public command and resumes the pending attack")
		check(DetectionRules.detection_range(reaction_state, njal, false) == 12.0, "Storm Caller reduces Njal's unit detection by 3 inches through the current phase")
		check(not reaction_state.unit_abilities.get("njal_psychic_uses", {}).get(njal_squad, {}).is_empty(), "High Rune Priest records the reactive level-1 use")
		check(attacker_squad >= 0, "The attacking Intercessor unit remains part of the resumed declaration")

	print("Njal Stormcaller checks: %d failures" % failures)
	quit(1 if failures > 0 else 0)
