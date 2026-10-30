extends SceneTree

const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Army = preload("res://scripts/edition_11/army_capabilities.gd")
const Capabilities = preload("res://scripts/edition_11/capabilities.gd")
const Catalog = preload("res://scripts/implemented_army_catalog.gd")
const Whirlwind = preload("res://scripts/edition_11/whirlwind_punishing_bombardment.gd")
const MarineEnhancements = preload("res://scripts/edition_11/stormlance_enhancements.gd")
const PublicUnitCommand = preload("res://tests/public_unit_command.gd")

const UNIT := "whirlwind"
const UNIT_ID := "40kdc:11e:adeptus-astartes:" + UNIT
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
		result[owner].entries = [entry("intercessor-squad", 5)]
	result[1].entries = [entry(UNIT), entry("intercessor-squad", 5)]
	result[2].entries = [entry("intercessor-squad", 5), entry("the-sanguinor")]
	return result

func fresh() -> Dictionary:
	return F.P.initial_state({"checked_rosters": false, "unit_abilities": true, "combat_doctrines": true,
		"core_stratagems": false, "manual_allocation": false}, selections())

func find_squad(state: Dictionary, owner: int, identity: String) -> int:
	for model: int in state.units:
		var unit: Dictionary = state.units[model]
		if int(unit.get("owner", -1)) == owner and C.UnitAbilities.identity(unit) == identity:
			return int(unit.get("squad", -1))
	return -1

func models_for(state: Dictionary, squad: int) -> Array[int]:
	var result: Array[int] = []
	for model: int in state.units:
		if int(state.units[model].get("squad", -1)) == squad: result.append(model)
	result.sort()
	return result

func find_choice(state: Dictionary, player: int, action: String, target: int = -1, model: int = -1, value: String = "") -> Dictionary:
	for option: Dictionary in C.UnitActions.choices(state, player):
		if str(option.get("action", "")) == action and int(option.get("target", -1)) == target and int(option.get("model", -1)) == model and str(option.get("value", "")) == value:
			return option
	return {}

func set_squad_keyword(state: Dictionary, squad: int, keyword: String, enabled: bool) -> void:
	for model: int in C.living(state, squad):
		var keywords: Array = state.units[model].keywords
		if enabled and keyword not in keywords: keywords.append(keyword)
		elif not enabled: keywords.erase(keyword)

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var profile := Profiles.profile(UNIT)
	check(profile.get("source_book_id", "") == "000000356" and profile.get("source_datasheet_id", "") == "000002727"
		and profile.get("source_snapshot_id", "") == Profiles.VERIFIED_EXPORT_SNAPSHOT_ID
		and profile.get("source_manifest_sha256", "") == Profiles.VERIFIED_EXPORT_MANIFEST_SHA256
		and profile.get("source_slice_manifest_sha256", "") == "d0164c9bf5035b95d88f0a3a1c297bc88dbaf5b565f2a1ba195928be3d3ceb5c",
		"Whirlwind retains the current 11e Legends identity and verified-export provenance")
	check(profile.get("source_scope", "") == "Warhammer Legends" and profile.get("source_url", "").ends_with("/Whirlwind"),
		"The source URL and Warhammer Legends scope are explicit")
	check(profile.get("points_by_models", {}) == {1: 175} and profile.get("second_plus_points_by_models", {}) == {1: 195}
		and profile.get("third_plus_points_by_models", {}) == {1: 195} and profile.get("models", 0) == 1
		and profile.get("max_supported_copies", 0) == 3 and profile.get("damaged_threshold", 0) == 4,
		"One-model composition, first/second-plus point tiers, copy cap and Damaged 4 match the source")
	check(profile.get("stats", {}) == {"movement_inches": 10, "toughness": 10, "save_target": 3, "wounds": 11, "leadership_target": 6, "objective_control": 3, "invulnerable_target": 0},
		"Every Whirlwind characteristic matches the verified export")
	check(profile.get("base_size_source", "") == "Use model" and profile.get("base_geometry", "") == "circular-model-footprint-proxy"
		and str(profile.get("geometry_scope", "")).contains("60 mm") and str(profile.get("geometry_scope", "")).contains("not certified"),
		"The unspecified footprint is labelled as a 60 mm proxy, not source geometry")
	check(profile.get("keywords", []) == ["ADEPTUS ASTARTES", "VEHICLE", "FRAME", "IMPERIUM", "SMOKE"]
		and profile.get("default_loadout_by_role", {}).get("Whirlwind", {}) == {"Armoured Tracks": 1, "Whirlwind Vengeance Launcher": 1},
		"The source keywords and mandatory default equipment are recorded")
	check(profile.get("special_rules", []) == ["Combat Doctrines", "Deadly Demise D3", "Damaged 4", "Punishing Bombardment"]
		and C.UnitAbilities.RULES.get(UNIT, []) == ["combat-doctrines", "deadly-demise-d3", "damaged-4", "punishing-bombardment"],
		"Common Vehicle abilities and Punishing Bombardment are registered")
	check(Capabilities.supported("punishing-bombardment"), "Punishing Bombardment appears in capability metadata")
	check(Army.SPECS.get(UNIT, {}).get("source_scope", "") == "Warhammer Legends" and Army.SPECS[UNIT].get("max_supported_copies", 0) == 3,
		"Construction records Legends status and its maximum copy cap")

	var default_weapons := Profiles.whirlwind_weapons()
	check(default_weapons.ranged.size() == 1 and default_weapons.ranged[0].id == "whirlwind-vengeance-launcher"
		and default_weapons.melee.size() == 1 and default_weapons.melee[0].id == "armoured-tracks",
		"The default loadout contains the Vengeance Launcher and Armoured Tracks")
	check(default_weapons.ranged[0].profiles.standard == {"name": "Whirlwind Vengeance Launcher", "range_inches": 72.0, "attacks": 6, "skill": 3, "strength": 8, "ap": -2, "damage": 2, "keywords": {"indirect-fire": true, "blast": 2}},
		"Vengeance Launcher characteristics and both weapon traits match the source")
	check(default_weapons.melee[0].profiles.standard == {"name": "Armoured Tracks", "range_inches": 0.0, "attacks": 3, "skill": 4, "strength": 6, "ap": 0, "damage": 1, "keywords": {}},
		"Armoured Tracks characteristic matches the source")
	var missile := Profiles.additional_weapon(UNIT, "ranged", "hunter-killer-missile")
	var bolter := Profiles.additional_weapon(UNIT, "ranged", "storm-bolter")
	check(missile.profiles.standard == {"name": "Hunter-killer Missile", "range_inches": 48.0, "attacks": 1, "skill": 2, "strength": 14, "ap": -3, "damage": "D3+3", "keywords": {"one-shot": true}}
		and bolter.profiles.standard == {"name": "Storm Bolter", "range_inches": 24.0, "attacks": 2, "skill": 3, "strength": 5, "ap": -1, "damage": 1, "keywords": {"rapid-fire": 2}},
		"Both optional weapon profiles and their source traits match")
	var fully_equipped := Profiles.whirlwind_weapons(true, true)
	check(fully_equipped.ranged.size() == 3 and fully_equipped.ranged[0].id == "whirlwind-vengeance-launcher"
		and fully_equipped.ranged[1].id == "hunter-killer-missile" and fully_equipped.ranged[2].id == "storm-bolter",
		"Both independent optional weapons can be equipped with the mandatory launcher")

	var provider := Catalog.new()
	root.add_child(provider)
	check(provider.select_edition("11e").is_empty(), "Whirlwind is available from the consolidated local catalog")
	var catalog_row := provider.lookup(UNIT_ID)
	check(catalog_row.get("source_scope", "") == "Warhammer Legends"
		and catalog_row.get("options", []) == [{"models": 1, "cost": 175, "second_plus_cost": 195, "third_plus_cost": 195}]
		and catalog_row.get("scope", "").contains("competitive events require organiser approval")
		and catalog_row.get("scope", "").contains("60 mm circle proxy"),
		"Construction publishes first/second-plus cost tiers and both legality and footprint conditions")
	var three_copies := Army.admit({"schema_version": 2, "faction": "Space Marines", "category": "strike_force", "points_limit": 2000, "entries": [entry(UNIT), entry(UNIT), entry(UNIT)]})
	var four_copies := Army.admit({"schema_version": 2, "faction": "Space Marines", "category": "strike_force", "points_limit": 2000, "entries": [entry(UNIT), entry(UNIT), entry(UNIT), entry(UNIT)]})
	check(three_copies.get("error", "").is_empty() and three_copies.get("total", -1) == 565 and not str(four_copies.get("error", "")).is_empty(),
		"Strike Force charges 175/195/195 and rejects the fourth copy")

	var setup_state := fresh()
	check(not setup_state.has("error"), "The current catalog materializes Whirlwind for preparation: %s" % setup_state.get("error", ""))
	if setup_state.has("error"):
		provider.free()
		quit(1)
		return
	var whirlwind_squad := find_squad(setup_state, 1, UNIT)
	var whirlwind_models := models_for(setup_state, whirlwind_squad)
	check(whirlwind_squad >= 0 and whirlwind_models.size() == 1 and setup_state.units[whirlwind_models[0]].ranged_weapons.size() == 1,
		"The selected model materializes with only its mandatory Vengeance Launcher")
	if whirlwind_models.size() == 1:
		var model := whirlwind_models[0]
		setup_state.phase = "deployment"
		setup_state.active = 1
		setup_state.unit_abilities.setup_players = []
		for category: int in [0, 1]:
			var selected := find_choice(setup_state, 1, "whirlwind-loadout", 0 if category == 0 else 1, model, "on")
			var result := PublicUnitCommand.submit(setup_state, 1, selected)
			check(not selected.is_empty() and str(result.get("error", "")).is_empty(), "Public preparation applies optional weapon category %d" % category)
		check(setup_state.units[model].get("whirlwind_hunter_killer_missile", false)
			and setup_state.units[model].get("whirlwind_storm_bolter", false) and setup_state.units[model].ranged_weapons.size() == 3,
			"Preparation materializes the optional missile and Storm Bolter")
		var restore_missile := find_choice(setup_state, 1, "whirlwind-loadout", 0, model, "off")
		var restore_result := PublicUnitCommand.submit(setup_state, 1, restore_missile)
		check(not restore_missile.is_empty() and str(restore_result.get("error", "")).is_empty()
			and not setup_state.units[model].get("whirlwind_hunter_killer_missile", true)
			and setup_state.units[model].get("whirlwind_storm_bolter", false)
			and setup_state.units[model].ranged_weapons.size() == 2,
			"The missile can be removed without disturbing the independent Storm Bolter")

	var battle := fresh()
	check(not battle.has("error"), "Whirlwind attack fixture materializes")
	if battle.has("error"):
		provider.free()
		quit(1)
		return
	var source := find_squad(battle, 1, UNIT)
	var target := find_squad(battle, 2, "intercessor-squad")
	var sanguinor := find_squad(battle, 2, "the-sanguinor")
	battle.active = 1
	battle.phase = "shooting"
	for model: int in battle.units:
		battle.units[model].position = Vector2(-18.0, 12.0) if int(battle.units[model].owner) == 1 else Vector2(18.0, 12.0)
	var source_model := models_for(battle, source)[0]
	var attack_plan := C.AttackPlan.prepare(battle, source, false, [{"model": source_model, "target": target, "amount": 1, "weapon": "whirlwind-vengeance-launcher", "profile": "standard"}], true)
	check(attack_plan.get("error", "").is_empty() and bool(attack_plan.batches[0].weapon.keywords.get("indirect-fire", false))
		and int(profile.ranged[0].profiles.standard.keywords.get("blast", 0)) == 2 and int(attack_plan.batches[0].count) == 8,
		"The source profile keeps Indirect Fire and Blast 2; AttackPlan adds two Blast attacks to the six base attacks")
	var hit_pool := {"target_squad": target, "weapon_name": "Whirlwind Vengeance Launcher", "hits": 2}
	check(Whirlwind.eligible_targets(battle, source, [hit_pool]) == [target]
		and Whirlwind.eligible_targets(battle, source, [{"target_squad": target, "weapon_name": "Whirlwind Vengeance Launcher", "hits": 0}]).is_empty()
		and Whirlwind.eligible_targets(battle, source, [{"target_squad": target, "weapon_name": "Storm Bolter", "hits": 2}]).is_empty(),
		"The ability requires a Vengeance Launcher hit and ignores misses or hits from another gun")
	set_squad_keyword(battle, target, "INFANTRY", false)
	set_squad_keyword(battle, target, "VEHICLE", true)
	check(Whirlwind.eligible_targets(battle, source, [hit_pool]).is_empty(), "A non-INFANTRY target cannot be selected")
	set_squad_keyword(battle, target, "VEHICLE", false)
	set_squad_keyword(battle, target, "INFANTRY", true)

	battle.phase = "shooting"
	battle.active = 1
	battle.unit_abilities.window = {"kind": "counter", "owners": [1]}
	var committed := C._commit_finished_attack(battle, source, 1, [], false, {"targets": [target]}, {"killed": 0, "damage": 0, "pools": [hit_pool]}, func() -> int: return 1)
	check(committed.get("error", "").is_empty() and battle.unit_abilities.window.get("kind", "") == Whirlwind.TARGET_WINDOW
		and battle.unit_abilities.window.get("resume_window", {}).get("kind", "") == "counter",
		"Completing the Whirlwind's Shooting action opens target selection and preserves a stacked reaction")
	var target_choice := find_choice(battle, 1, Whirlwind.TARGET_ACTION, target)
	check(C.UnitActions.actor(battle) == 1 and not C.UnitActions.pending_decision(battle).is_empty()
		and not PublicUnitCommand.error(battle, 2, target_choice).is_empty(),
		"The public decision belongs to the Whirlwind player; the opponent cannot select the target")
	var dice: Array[int] = [1, 1, 4, 4]
	var roller := func() -> int: return dice.pop_front() if not dice.is_empty() else 1
	var selected_target := PublicUnitCommand.submit(battle, 1, target_choice, Vector2.ZERO, roller)
	check(str(selected_target.get("error", "")).is_empty() and battle.unit_abilities.window.get("kind", "") == Whirlwind.REROLL_WINDOW
		and C.UnitActions.actor(battle) == 2 and not battle.squads[target].battle_shocked
		and battle.unit_abilities.window.get("current_result", {}).get("passed", true) == false,
		"A failed initial test opens the target controller's available Aura of Fervour re-roll decision")
	check(MarineEnhancements.leadership_reroll_available(battle, target), "The Battle-shock test has a legal Sanguinor reroll source in range")
	var wrong_owner_choice := find_choice(battle, 2, Whirlwind.REROLL_ACTION, target, -1, "reroll")
	check(not wrong_owner_choice.is_empty() and not PublicUnitCommand.error(battle, 1, wrong_owner_choice).is_empty(),
		"Only the tested unit's controller may choose the Leadership re-roll")
	var reroll_choice := find_choice(battle, 2, Whirlwind.REROLL_ACTION, target, -1, "reroll")
	var reroll_result := PublicUnitCommand.submit(battle, 2, reroll_choice, Vector2.ZERO, roller)
	check(str(reroll_result.get("error", "")).is_empty() and not battle.squads[target].battle_shocked
		and battle.last_morale.size() == 1 and battle.last_morale[0].get("rerolled_from", []) == [1, 1]
		and battle.last_morale[0].get("reroll_source", "") == "Aura of Fervour"
		and battle.unit_abilities.window.get("kind", "") == "counter",
		"The public reroll applies its passing result and restores the previous decision window")

	var no_reroll_state := fresh()
	var no_reroll_source := find_squad(no_reroll_state, 1, UNIT)
	var no_reroll_target := find_squad(no_reroll_state, 2, "intercessor-squad")
	for model: int in no_reroll_state.units:
		no_reroll_state.units[model].position = Vector2(-18.0, 12.0) if int(no_reroll_state.units[model].owner) == 1 else Vector2(18.0, 12.0)
	var no_reroll_source_model := models_for(no_reroll_state, no_reroll_source)[0]
	var no_reroll_pool := {"target_squad": no_reroll_target, "weapon_name": "Whirlwind Vengeance Launcher", "hits": 1}
	no_reroll_state.phase = "shooting"
	no_reroll_state.active = 1
	no_reroll_state.units[models_for(no_reroll_state, find_squad(no_reroll_state, 2, "the-sanguinor"))[0]].position = Vector2(0, 18)
	var no_reroll_commit := C._commit_finished_attack(no_reroll_state, no_reroll_source, 1, [], false, {"targets": [no_reroll_target]}, {"killed": 0, "damage": 0, "pools": [no_reroll_pool]}, func() -> int: return 1)
	var no_reroll_choice := find_choice(no_reroll_state, 1, Whirlwind.TARGET_ACTION, no_reroll_target)
	var failed_test_dice: Array[int] = [1, 2]
	var failed_test_roller := func() -> int: return failed_test_dice.pop_front() if not failed_test_dice.is_empty() else 1
	var no_reroll_result := PublicUnitCommand.submit(no_reroll_state, 1, no_reroll_choice, Vector2.ZERO, failed_test_roller)
	check(no_reroll_commit.get("error", "").is_empty() and str(no_reroll_result.get("error", "")).is_empty()
		and no_reroll_state.squads[no_reroll_target].battle_shocked
		and no_reroll_state.unit_abilities.window.is_empty(),
		"Without a reroll aura, Punishing Bombardment immediately applies a failed Battle-shock test")
	provider.free()

	if failures == 0: print("Whirlwind Legends checks: 0 failures")
	else: push_error("Whirlwind Legends checks: %d failures" % failures)
	quit(1 if failures else 0)
