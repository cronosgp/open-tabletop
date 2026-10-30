extends SceneTree

const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Army = preload("res://scripts/edition_11/army_capabilities.gd")
const AbilityCatalog = preload("res://scripts/edition_11/unit_ability_catalog.gd")
const Registry = preload("res://scripts/edition_11/capabilities.gd")
const LeaderLinks = preload("res://scripts/edition_11/marine_leader_links.gd")
const UnitActions = preload("res://scripts/edition_11/unit_actions.gd")
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
	result[1].entries = [entry("ulrik-the-slayer"), entry("intercessor-squad", 5)]
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
	var model := model_for(state, owner, identity)
	return int(state.units.get(model, {}).get("squad", -1))

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
		unit.position = Vector2.ZERO if int(unit.owner) == 1 else Vector2(0.8, 0.0)
	state.terrain.areas = []
	state.mission.objectives = []
	state.unit_abilities.setup_players = []

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var profile := Profiles.profile("ulrik-the-slayer")
	check(profile.get("source_book_id", "") == "000000036" and profile.get("source_datasheet_id", "") == "000000297" and profile.get("source_snapshot_id", "") == "20261029T003124Z" and profile.get("source_slice_manifest_sha256", "") == "d7e1cd38ee48ed72c881e42652e3cf185056736f1e373f625411e1e250dda764", "Ulrik is bound to the Space Wolves App datasheet and verified local source slice")
	check(profile.get("points_by_models", {}) == {1: 90} and profile.get("models", -1) == 1 and profile.get("max_supported_copies", -1) == 1 and profile.get("base_size_source_mm", -1) == 32, "Ulrik retains his one-model, 90-point profile, one-copy limit and 32 mm base")
	check(profile.get("stats", {}) == {"movement_inches": 7, "toughness": 5, "save_target": 3, "wounds": 4, "leadership_target": 5, "objective_control": 1, "invulnerable_target": 4}, "Ulrik's characteristics match the local export")
	var expected_keywords := ["ADEPTUS ASTARTES", "CHARACTER", "EPIC HERO", "EXPLOSIVES", "IMPERIUM", "INFANTRY", "SPACE WOLVES", "WOLF PRIEST"]
	var actual_keywords: Array = profile.get("keywords", []).duplicate()
	actual_keywords.sort()
	check(actual_keywords == expected_keywords, "All source-listed Ulrik keywords are retained")
	var pistol: Dictionary = profile.get("ranged", [{}])[0].get("profiles", {})
	var crozius: Dictionary = profile.get("melee", [{}])[0].get("profiles", {}).get("standard", {})
	check(pistol.get("standard", {}).get("skill") == 2 and pistol.standard.get("strength") == 7 and pistol.standard.get("ap") == -2 and pistol.standard.get("damage") == 1, "Standard Plasma Pistol profile matches the source")
	check(pistol.get("supercharge", {}).get("skill") == 2 and pistol.supercharge.get("strength") == 8 and pistol.supercharge.get("ap") == -3 and pistol.supercharge.get("damage") == 2 and pistol.supercharge.get("keywords", {}).get("hazardous", false), "Supercharge profile retains its source stats and Hazardous")
	check(crozius.get("attacks") == 5 and crozius.get("skill") == 2 and crozius.get("strength") == 6 and crozius.get("ap") == -2 and crozius.get("damage") == 2 and crozius.get("keywords", {}) == {"anti-monster": 4, "anti-vehicle": 4}, "Artificer Crozius Arcanum matches its source profile")
	check(Army.SPECS.has("ulrik-the-slayer") and Army.SPECS["ulrik-the-slayer"].get("current_reference", false), "Ulrik is registered for current-reference construction")
	check(AbilityCatalog.RULES.get("ulrik-the-slayer", []) == ["leader", "combat-doctrines", "transhuman-strategist", "slayer-s-oath", "oathbound"], "Leader, Combat Doctrines, Transhuman Strategist and both datasheet abilities are registered")
	check(Registry.supported("slayer-s-oath") and Registry.supported("oathbound"), "Both Ulrik abilities are exposed as supported local capabilities")
	var targets := LeaderLinks.targets("ulrik-the-slayer")
	check(targets == ["grey-hunters", "assault-intercessor-squad", "wolf-guard-headtakers", "blood-claws", "bladeguard-veteran-squad", "intercessor-squad"] and Army.SPECS.get("wolf-guard-headtakers", {}).get("current_reference", false), "All six source-listed Leader endpoints are recorded in source order and reconciled Headtakers is selectable")
	var admitted := Army.admit({"schema_version": 2, "faction": "Space Marines", "category": "custom", "points_limit": 1000, "entries": [entry("ulrik-the-slayer")]})
	var duplicate := Army.admit({"schema_version": 2, "faction": "Space Marines", "category": "custom", "points_limit": 1000, "entries": [entry("ulrik-the-slayer", 1, 2)]})
	check(admitted.get("error", "").is_empty() and admitted.get("total", -1) == 90 and not str(duplicate.get("error", "")).is_empty(), "Construction admits Ulrik at source cost and enforces his Epic Hero limit")

	var state := fresh_state()
	check(not state.has("error"), "Ulrik's test armies materialize from the consolidated current catalog: %s" % state.get("error", ""))
	if not state.has("error"):
		var ulrik := model_for(state, 1, "ulrik-the-slayer")
		var squad := int(state.units.get(ulrik, {}).get("squad", -1))
		var enemy_character := squad_for(state, 2, "captain")
		var enemy_infantry := squad_for(state, 2, "intercessor-squad")
		state.phase = "deployment"
		state.active = 1
		check(UnitActions.choices(state, 1).any(func(option: Dictionary) -> bool: return str(option.get("action", "")) == "warlord" and int(option.get("model", -1)) == ulrik), "Ulrik is eligible to be Warlord for Transhuman Strategist")
		place_test_units(state)
		state.phase = "start_turn"
		state.turn = 1
		state.round = 1
		state.active = int(state.get("first_player", 1))
		var candidates := C.UnitAbilities.slayer_oath_targets(state, 1)
		check(enemy_character in candidates and enemy_infantry not in candidates, "Slayer's Oath only offers living enemy CHARACTER, MONSTER or VEHICLE units")
		var oath := find_choice(state, 1, "slayer-oath", enemy_character, "initial")
		check(not oath.is_empty(), "The start-of-round declaration offers the eligible enemy Character")
		if not oath.is_empty():
			var submitted := PublicUnitCommand.submit(state, 1, oath, Vector2.ZERO)
			check(submitted.get("error", "").is_empty() and C.UnitAbilities.slayer_oath_target(state, squad) == enemy_character, "The public command records the selected Slayer's Oath target")
			check(C.UnitAbilities.slayer_oath_resolved(state, squad), "The first-round Slayer's Oath decision is recorded once")

		state.phase = "fight"
		state.turn = 1
		state.unit_abilities.weapon_skill_characteristic_modifiers.squads[squad] = {"WS": -1}
		state.unit_abilities.tempests_wrath_targets[squad] = {"owner": 2, "source_squad": enemy_character, "expires_turn": 3}
		var crozius_weapon: Dictionary = state.units[ulrik].melee_weapons[0]
		var marked := C.AttackPlan.prepare(state, squad, true, [{"model": ulrik, "target": enemy_character, "amount": 5, "weapon": crozius_weapon.id, "profile": "standard"}], false)
		check(marked.get("error", "").is_empty(), "Ulrik can prepare the marked melee attack: %s" % marked.get("error", ""))
		if marked.get("error", "").is_empty():
			var context: Dictionary = marked.batches[0].context
			check(marked.batches[0].weapon.skill == 2, "Slayer's Oath ignores a negative WS modifier against its target")
			check(context.get("hit_modifier", 0) == 1 and context.get("wound_modifier", 0) == 1, "Oathbound keeps its +1 Hit bonus and grants +1 to Wound against the mark despite a negative Hit modifier")
		var unmarked := C.AttackPlan.prepare(state, squad, true, [{"model": ulrik, "target": enemy_infantry, "amount": 5, "weapon": crozius_weapon.id, "profile": "standard"}], false)
		check(unmarked.get("error", "").is_empty(), "Ulrik can prepare melee attacks against other enemy units")
		if unmarked.get("error", "").is_empty():
			check(unmarked.batches[0].weapon.skill == 3 and unmarked.batches[0].context.get("hit_modifier", 0) == 0 and unmarked.batches[0].context.get("wound_modifier", 0) == 0, "Oathbound does not grant Slayer's Oath benefits against an unmarked target")

	var pass_state := fresh_state()
	if not pass_state.has("error"):
		var ulrik := model_for(pass_state, 1, "ulrik-the-slayer")
		var squad := int(pass_state.units[ulrik].squad)
		place_test_units(pass_state)
		pass_state.phase = "start_turn"
		pass_state.turn = 1
		pass_state.round = 1
		pass_state.active = int(pass_state.get("first_player", 1))
		var skip := find_choice(pass_state, 1, "slayer-oath", squad, "pass-initial")
		var skipped := PublicUnitCommand.submit(pass_state, 1, skip, Vector2.ZERO)
		check(skipped.get("error", "").is_empty() and C.UnitAbilities.slayer_oath_resolved(pass_state, squad) and C.UnitAbilities.slayer_oath_target(pass_state, squad) == -1, "The player can explicitly skip Slayer's Oath without leaving a pending declaration")

	print("Ulrik the Slayer checks: %d failures" % failures)
	quit(0 if failures == 0 else 1)
