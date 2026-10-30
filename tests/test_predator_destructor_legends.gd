extends SceneTree

const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Army = preload("res://scripts/edition_11/army_capabilities.gd")
const Capabilities = preload("res://scripts/edition_11/capabilities.gd")
const Equipment = preload("res://scripts/edition_11/equipment.gd")
const Catalog = preload("res://scripts/implemented_army_catalog.gd")
const PublicUnitCommand = preload("res://tests/public_unit_command.gd")

const UNIT := "predator-destructor"
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
	result[2].entries = [entry("intercessor-squad", 5)]
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

func find_choice(state: Dictionary, model: int, category: int, value: String) -> Dictionary:
	for option: Dictionary in C.UnitActions.choices(state, 1):
		if str(option.get("action", "")) == "predator-destructor-loadout" and int(option.get("model", -1)) == model and int(option.get("target", -1)) == category and str(option.get("value", "")) == value:
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
	check(profile.get("source_book_id", "") == "000000356" and profile.get("source_datasheet_id", "") == "000002715"
		and profile.get("source_snapshot_id", "") == Profiles.VERIFIED_EXPORT_SNAPSHOT_ID
		and profile.get("source_manifest_sha256", "") == Profiles.VERIFIED_EXPORT_MANIFEST_SHA256
		and profile.get("source_slice_manifest_sha256", "") == "d0164c9bf5035b95d88f0a3a1c297bc88dbaf5b565f2a1ba195928be3d3ceb5c",
		"Predator Destructor retains its current 11e Legends source identity and verified-export provenance")
	check(profile.get("source_scope", "") == "Warhammer Legends" and profile.get("source_url", "").ends_with("/Predator-Destructor"),
		"The source URL and Legends scope are explicit")
	check(profile.get("points_by_models", {}) == {1: 140} and profile.get("third_plus_points_by_models", {}) == {1: 150}
		and profile.get("models", 0) == 1 and profile.get("max_supported_copies", 0) == 3 and profile.get("damaged_threshold", 0) == 4,
		"One-model composition, first/second and third-plus prices, copy cap and Damaged 4 match the source")
	check(profile.get("stats", {}) == {"movement_inches": 10, "toughness": 10, "save_target": 3, "wounds": 11, "leadership_target": 6, "objective_control": 3, "invulnerable_target": 0},
		"All Predator Destructor characteristics match the source")
	check(profile.get("base_size_source", "") == "Use model" and profile.get("base_geometry", "") == "circular-model-footprint-proxy"
		and str(profile.get("geometry_scope", "")).contains("60 mm") and str(profile.get("geometry_scope", "")).contains("not certified"),
		"The source's unspecified footprint is clearly labeled as a 60 mm proxy")
	check(profile.get("keywords", []) == ["ADEPTUS ASTARTES", "VEHICLE", "FRAME", "IMPERIUM", "SMOKE"]
		and profile.get("default_loadout_by_role", {}).get("Predator Destructor", {}) == {"Armoured Tracks": 1, "Lascannon": 2, "Predator Autocannon": 1},
		"Source keywords and every default weapon are recorded")
	check(profile.get("special_rules", []) == ["Combat Doctrines", "Deadly Demise D3", "Damaged 4", "Destructor"]
		and C.UnitAbilities.RULES.get(UNIT, []) == ["combat-doctrines", "deadly-demise-d3", "damaged-4", "predator-destructor"],
		"The common Vehicle rules and Predator Destructor rule are registered")
	check(Capabilities.supported("predator-destructor"), "Destructor is present in capability metadata")
	check(Army.SPECS.get(UNIT, {}).get("source_scope", "") == "Warhammer Legends" and Army.SPECS[UNIT].get("max_supported_copies", 0) == 3,
		"The construction catalog labels Legends status and its Strike Force copy ceiling")

	var default_weapons := Profiles.predator_destructor_weapons()
	check(default_weapons.ranged.size() == 3 and default_weapons.ranged[0].id == "lascannon" and default_weapons.ranged[1].id == "lascannon"
		and default_weapons.ranged[2].id == "predator-autocannon" and default_weapons.melee[0].id == "armoured-tracks",
		"The generated default profile carries two sponson Lascannons, the Predator Autocannon and Armoured Tracks")
	check(default_weapons.ranged[0].profiles.standard == {"name": "Lascannon", "range_inches": 48.0, "attacks": 1, "skill": 3, "strength": 12, "ap": -3, "damage": "D3+3", "keywords": {}},
		"The sponson Lascannon matches its full source profile")
	check(default_weapons.ranged[2].profiles.standard == {"name": "Predator Autocannon", "range_inches": 48.0, "attacks": 4, "skill": 3, "strength": 9, "ap": -1, "damage": 3, "keywords": {"rapid-fire": 2}},
		"The Predator Autocannon matches its full source profile")
	check(default_weapons.melee[0].profiles.standard == {"name": "Armoured Tracks", "range_inches": 0.0, "attacks": 3, "skill": 4, "strength": 6, "ap": 0, "damage": 1, "keywords": {}},
		"Armoured Tracks match the source profile")
	var expected_optional := {
		"heavy-bolter": {"name": "Heavy Bolter", "range_inches": 36.0, "attacks": 3, "skill": 3, "strength": 5, "ap": -1, "damage": 2, "keywords": {"rapid-fire": 2, "sustained-hits": 1}},
		"hunter-killer-missile": {"name": "Hunter-killer Missile", "range_inches": 48.0, "attacks": 1, "skill": 2, "strength": 14, "ap": -3, "damage": "D3+3", "keywords": {"one-shot": true}},
		"storm-bolter": {"name": "Storm Bolter", "range_inches": 24.0, "attacks": 2, "skill": 3, "strength": 5, "ap": -1, "damage": 1, "keywords": {"rapid-fire": 2}}
	}
	for weapon_id: String in expected_optional:
		var weapon := Profiles.additional_weapon(UNIT, "ranged", weapon_id)
		check(not weapon.is_empty() and weapon.profiles.standard == expected_optional[weapon_id], "%s matches its full source profile and traits" % weapon_id)
	var fully_equipped := Profiles.predator_destructor_weapons(true, true, true)
	check(fully_equipped.ranged.size() == 5 and fully_equipped.ranged[0].id == "heavy-bolter" and fully_equipped.ranged[1].id == "heavy-bolter"
		and fully_equipped.ranged[2].id == "predator-autocannon" and fully_equipped.ranged[3].id == "hunter-killer-missile" and fully_equipped.ranged[4].id == "storm-bolter",
		"The two sponson replacements and both optional weapons can be equipped together")

	var provider = Catalog.new()
	root.add_child(provider)
	check(provider.select_edition("11e").is_empty(), "Predator Destructor is available from the consolidated local catalog")
	var unit_entry := provider.lookup(UNIT_ID)
	check(unit_entry.get("source_scope", "") == "Warhammer Legends" and unit_entry.get("options", []) == [{"models": 1, "cost": 140, "third_plus_cost": 150}]
		and unit_entry.get("scope", "").contains("competitive events require organiser approval") and unit_entry.get("scope", "").contains("60 mm circle proxy"),
		"Construction shows both point tiers, Legends event conditions and the footprint proxy")
	var three_copies := Army.admit({"schema_version": 2, "faction": "Space Marines", "category": "strike_force", "points_limit": 2000, "entries": [entry(UNIT), entry(UNIT), entry(UNIT)]})
	var four_copies := Army.admit({"schema_version": 2, "faction": "Space Marines", "category": "strike_force", "points_limit": 2000, "entries": [entry(UNIT), entry(UNIT), entry(UNIT), entry(UNIT)]})
	check(three_copies.get("error", "").is_empty() and three_copies.get("total", -1) == 430 and not str(four_copies.get("error", "")).is_empty(),
		"Strike Force uses 140/140/150 points and enforces the three-copy limit")

	var setup_state := fresh()
	check(not setup_state.has("error"), "The current catalog materializes Predator Destructor for preparation: %s" % setup_state.get("error", ""))
	if setup_state.has("error"):
		provider.free()
		quit(1)
		return
	var predator_squad := find_squad(setup_state, 1, UNIT)
	var predator_models := models_for(setup_state, predator_squad)
	check(predator_squad >= 0 and predator_models.size() == 1 and setup_state.units[predator_models[0]].ranged_weapons.size() == 3,
		"The selected model materializes with the complete printed default weapons")
	if predator_models.size() == 1:
		var model := predator_models[0]
		setup_state.phase = "deployment"
		setup_state.active = 1
		setup_state.unit_abilities.setup_players = []
		for category: int in [0, 1, 2]:
			var selected := find_choice(setup_state, model, category, "on")
			var result := PublicUnitCommand.submit(setup_state, 1, selected)
			check(not selected.is_empty() and str(result.get("error", "")).is_empty(), "The public preparation flow exposes and applies Predator option category %d" % category)
		check(setup_state.units[model].get("predator_destructor_heavy_bolters", false)
			and setup_state.units[model].get("predator_destructor_hunter_killer_missile", false)
			and setup_state.units[model].get("predator_destructor_storm_bolter", false)
			and setup_state.units[model].ranged_weapons.size() == 5,
			"Preparation applies the paired Heavy Bolter replacement and both optional weapons")
		var restore := find_choice(setup_state, model, 0, "off")
		var restore_result := PublicUnitCommand.submit(setup_state, 1, restore)
		check(not restore.is_empty() and str(restore_result.get("error", "")).is_empty()
			and setup_state.units[model].ranged_weapons[0].id == "lascannon" and setup_state.units[model].ranged_weapons[1].id == "lascannon"
			and setup_state.units[model].ranged_weapons.size() == 5,
			"Restoring the sponson Lascannons preserves both independent optional weapons")
	provider.free()

	var battle := fresh()
	check(not battle.has("error"), "Predator Destructor battle fixture materializes")
	if battle.has("error"):
		quit(1)
		return
	var squad := find_squad(battle, 1, UNIT)
	var model := models_for(battle, squad)[0]
	var target := find_squad(battle, 2, "intercessor-squad")
	for current_model: int in battle.units:
		battle.units[current_model].position = Vector2(-18.0, 12.0) if int(battle.units[current_model].owner) == 1 else Vector2(18.0, 12.0)
	var infantry_plan := C.AttackPlan.prepare(battle, squad, false, [{"model": model, "target": target, "amount": 1, "weapon": "predator-autocannon", "profile": "standard"}], true)
	set_squad_keyword(battle, target, "INFANTRY", false)
	set_squad_keyword(battle, target, "VEHICLE", true)
	var non_infantry_plan := C.AttackPlan.prepare(battle, squad, false, [{"model": model, "target": target, "amount": 1, "weapon": "predator-autocannon", "profile": "standard"}], true)
	var melee_target_model: int = models_for(battle, target)[0]
	var melee_target_position: Vector2 = battle.units[melee_target_model].position
	battle.units[melee_target_model].position = Vector2(-15.8, 12.0)
	var melee_plan := C.AttackPlan.prepare(battle, squad, true, [{"model": model, "target": target, "amount": 3, "weapon": "armoured-tracks", "profile": "standard"}], true)
	battle.units[melee_target_model].position = melee_target_position
	check(infantry_plan.get("error", "").is_empty() and int(infantry_plan.batches[0].weapon.ap) == -2
		and non_infantry_plan.get("error", "").is_empty() and int(non_infantry_plan.batches[0].weapon.ap) == -1
		and melee_plan.get("error", "").is_empty() and int(melee_plan.batches[0].weapon.ap) == 0,
		"Destructor improves ranged AP by 1 against INFANTRY only; ranged non-Infantry and melee retain printed AP: infantry=%s, other=%s, melee=%s" % [str(infantry_plan), str(non_infantry_plan), str(melee_plan)])

	if failures == 0: print("Predator Destructor Legends checks: 0 failures")
	else: push_error("Predator Destructor Legends checks: %d failures" % failures)
	quit(1 if failures else 0)
