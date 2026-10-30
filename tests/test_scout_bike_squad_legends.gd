extends SceneTree

const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Army = preload("res://scripts/edition_11/army_capabilities.gd")
const PublicUnitCommand = preload("res://tests/public_unit_command.gd")
const ScoutMoves = preload("res://scripts/edition_11/scout_moves.gd")
const Equipment = preload("res://scripts/edition_11/equipment.gd")
const WeaponChecks = preload("res://tests/space_marine_datasheet_checks.gd")
const UNIT := "scout-bike-squad"
const A = C.UnitAbilities
const U = C.UnitActions

var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func entry(identity: String, models: int, copies: int = 1) -> Dictionary:
	return {"definition_id": "40kdc:11e:adeptus-astartes:" + identity, "models": models, "copies": copies}

func selections(model_count: int = 3) -> Dictionary:
	var result := F.current_marine_selections()
	for owner: int in [1, 2]:
		result[owner].category = "custom"
		result[owner].points_limit = 3000
		result[owner].entries = [entry(UNIT, model_count), entry("intercessor-squad", 5)]
	return result

func fixture(model_count: int = 3) -> Dictionary:
	var options := {"checked_rosters": false, "official_mission": false, "unit_abilities": true, "combat_doctrines": true, "core_stratagems": true, "attack_rerolls": true, "manual_allocation": false}
	var state: Dictionary = F.P.initial_state(options, selections(model_count))
	if not state.has("error"):
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

func choice_for(state: Dictionary, player: int, action: String, model: int = -1, target: int = -1, value: String = "") -> Dictionary:
	for option: Dictionary in U.choices(state, player):
		if str(option.get("action", "")) != action: continue
		if model >= 0 and int(option.get("model", -1)) != model: continue
		if target >= 0 and int(option.get("target", -1)) != target: continue
		if not value.is_empty() and str(option.get("value", "")) != value: continue
		return option
	return {}

func submit(state: Dictionary, player: int, action: String, model: int, target: int, value: String = "", point: Vector2 = Vector2.ZERO) -> Dictionary:
	var selected := choice_for(state, player, action, model, target, value)
	if selected.is_empty(): return {"error": "Unavailable: " + action + " / " + value}
	return PublicUnitCommand.submit(state, player, selected, point)

func expected_weapon(name: String, range_inches: float, attacks: Variant, skill: Variant, strength: int, ap: int, damage: Variant, keywords: Dictionary) -> Dictionary:
	return {"name": name, "range_inches": range_inches, "attacks": attacks, "skill": skill, "strength": strength, "ap": ap, "damage": damage, "keywords": keywords}

func equipped_profile(state: Dictionary, model: int) -> Dictionary:
	var result := Profiles.profile(UNIT)
	result.ranged = state.units[model].get("ranged_weapons", []).duplicate(true)
	result.melee = state.units[model].get("melee_weapons", []).duplicate(true)
	return result

func weapon_plan_failures_for_model(state: Dictionary, squad: int, model: int, target: int) -> Array[String]:
	var isolated: Dictionary = state.duplicate(true)
	for sibling: int in C.living(isolated, squad):
		if sibling != model: isolated.units[sibling].wounds = 0
	var target_models: Array[int] = C.living(isolated, target)
	if target_models.is_empty(): return ["target has no living models"]
	isolated.units[model].position = Vector2.ZERO
	isolated.units[target_models[0]].position = Vector2(2.5, 0.0)
	return WeaponChecks.fixed_weapon_plan_failures(isolated, equipped_profile(isolated, model), model, target)

func run() -> void:
	var profile := Profiles.profile(UNIT)
	check(profile.get("source_book_id") == "000000356" and profile.get("source_datasheet_id") == "000000137" and profile.get("source_scope") == "Warhammer Legends" and profile.get("source_snapshot_id") == "wahapedia-e11-live-refresh-final-user-readiness-20261030T013229Z" and profile.get("source_retrieved_at_utc") == "2026-10-30T01:33:48.347556+00:00" and profile.get("source_export_updated_at") == "2026-10-28T23:48:19+03:00", "Scout Bike Squad cites the verified Wahapedia 11e Legends identity, retrieval time and export revision")
	check(profile.get("source_manifest_sha256") == "12ac4ca99c29456195287d9a2c947fdea0c4c8fd659b5bfa3a7a829ede87283e" and profile.get("source_slice_manifest_sha256") == "d0164c9bf5035b95d88f0a3a1c297bc88dbaf5b565f2a1ba195928be3d3ceb5c", "The parent and Legends slice manifests are pinned by hash")
	var source_hashes := {}
	for source_file: Dictionary in profile.get("source_files", []): source_hashes[source_file.get("name", "")] = source_file.get("sha256", "")
	var expected_source_hashes := {"Datasheets.csv": "45df2602251657c5713b341dbe70127630a76a657c43525703b3b19c6cb9d469", "Datasheets_abilities.csv": "182b80e44d7f4ae1025a71d8ff3776c33bcc58d8b2e1709cf26448f356e51b1d", "Datasheets_keywords.csv": "5e1d811ca8b5a92427a2b5a33fe6f731e7ef877fc08a6761e02822402a3561a8", "Datasheets_models.csv": "4647792360285babac2fc5ef5adf2708397f47f455fbaa0773491a96aa7a3da5", "Datasheets_models_cost.csv": "0236376fcb947a8c9e4883df7af0f38a0923b11d8d907035e5e9e47c52446de8", "Datasheets_options.csv": "44a652d49f7e93d6f7acaae805d907b3ce156cbd14c1db7fe35fd66712f4a0fe", "Datasheets_unit_composition.csv": "b980856c29676675f81abfbbcc1161ad64253f15925df21c8968cd8bbaca13e7", "Datasheets_wargear.csv": "13e3e6d1e0c4114e41d1cc9c80fe94d8e0e37b628b9af5625d88aeba0c7cbe9d"}
	check(source_hashes == expected_source_hashes, "All eight raw source-file SHA-256 values are stored on the profile")
	check(profile.get("points_by_models", {}) == {3: 75, 6: 150} and profile.get("second_plus_points_by_models", {}) == {3: 75, 6: 150} and profile.get("third_plus_points_by_models", {}) == {3: 75, 6: 150}, "Both source compositions retain all three 75/150-point copy tiers")
	check(profile.get("source_unit_composition", {}) == {3: {"Scout Biker Sergeant": 1, "Scout Biker": 2}, 6: {"Scout Biker Sergeant": 1, "Scout Biker": 5}}, "The one-Sergeant and two-to-five Biker compositions match the export")
	check(profile.get("base_size_source_mm", []) == [75, 25] and profile.get("base_geometry") == "oval" and is_equal_approx(float(profile.get("base_radius_inches", 0.0)), 37.5 / 25.4) and "proxy" in str(profile.get("geometry_scope", "")), "The 75 x 25 mm oval is disclosed as a labelled 75 mm circular collision proxy")
	check(profile.get("stats", {}) == {"movement_inches": 12, "toughness": 5, "save_target": 4, "wounds": 3, "leadership_target": 6, "objective_control": 2, "invulnerable_target": 0}, "Both source model roles use M12/T5/Sv4+/W3/Ld6+/OC2 with no invulnerable save")
	check(profile.get("keywords", []) == ["ADEPTUS ASTARTES", "MOUNTED", "IMPERIUM", "EXPLOSIVES", "SMOKE", "RAVENWING"], "All source keywords are retained for conditional Dark Angels context handling")
	check(profile.get("default_loadout_by_role", {}).get("Scout Biker Sergeant") == profile.get("default_loadout_by_role", {}).get("Scout Biker"), "Both roles start with Bolt Pistol, Combat Knife, Shotgun and Twin Boltgun")
	check(profile.ranged.map(func(w: Dictionary) -> String: return w.id) == ["bolt-pistol", "shotgun", "twin-boltgun"] and profile.melee.map(func(w: Dictionary) -> String: return w.id) == ["combat-knife"], "The default profile represents the complete fixed wargear")
	check(profile.ranged[0].profiles.standard == {"name": "Bolt Pistol", "range_inches": 12.0, "attacks": 1, "skill": 3, "strength": 5, "ap": -1, "damage": 1, "keywords": {"close-quarters": true}} and profile.ranged[1].profiles.standard == {"name": "Shotgun", "range_inches": 18.0, "attacks": 2, "skill": 3, "strength": 4, "ap": -1, "damage": 1, "keywords": {"assault": true, "blast": 1}}, "Bolt Pistol and Shotgun preserve the exported profiles and traits")
	check(profile.ranged[2].profiles.standard == {"name": "Twin Boltgun", "range_inches": 24.0, "attacks": 2, "skill": 3, "strength": 5, "ap": -1, "damage": 1, "keywords": {"rapid-fire": 1, "twin-linked": true}} and profile.melee[0].profiles.standard == {"name": "Combat Knife", "range_inches": 0.0, "attacks": 3, "skill": 3, "strength": 4, "ap": -1, "damage": 1, "keywords": {}}, "Twin Boltgun and Combat Knife preserve the exported profiles and traits")
	check(profile.additional_weapon_profiles.ranged.size() == 8 and profile.additional_weapon_profiles.melee.size() == 4, "All source-listed ranged and melee replacement groups are present")
	var extras: Dictionary = profile.additional_weapon_profiles
	check(extras.ranged[0].profiles.standard.keywords == {"rapid-fire": 1} and extras.ranged[1].profiles.damnatus.keywords == {"melta": 2} and extras.ranged[1].profiles.infernus.keywords == {"torrent": true, "blast": 1} and extras.ranged[1].profiles.purgatus.damage == 2, "Boltgun and all three Combi-weapon profiles match the source traits")
	check(extras.ranged[2].profiles.standard.keywords == {"anti-vehicle": 2, "close-quarters": true} and extras.ranged[3].profiles.frag.keywords == {"blast": 1} and extras.ranged[3].profiles.krak.keywords == {"rapid-fire": 1}, "Grav-pistol and both Grenade Launcher profiles match the source traits")
	check(extras.ranged[4].profiles.standard.keywords == {"torrent": true, "close-quarters": true} and extras.ranged[5].profiles.standard.keywords == {"melta": 2, "close-quarters": true} and extras.ranged[6].profiles.supercharge.keywords == {"hazardous": true, "close-quarters": true} and extras.ranged[7].profiles.standard.keywords == {"rapid-fire": 2}, "Hand Flamer, Inferno Pistol, Plasma Pistol and Storm Bolter retain their source traits")
	var expected_ranged := {
		"boltgun": {"standard": expected_weapon("Boltgun", 24.0, 1, 3, 5, -1, 1, {"rapid-fire": 1})},
		"combi-weapon": {
			"damnatus": expected_weapon("Combi-weapon - Damnatus", 12.0, 1, 3, 9, -3, "D3+2", {"melta": 2}),
			"infernus": expected_weapon("Combi-weapon - Infernus", 12.0, 3, 0, 4, 0, 1, {"torrent": true, "blast": 1}),
			"purgatus": expected_weapon("Combi-weapon - Purgatus", 24.0, 2, 3, 7, -2, 2, {})},
		"grav-pistol": {"standard": expected_weapon("Grav-pistol", 12.0, 2, 3, 2, -1, 3, {"anti-vehicle": 2, "close-quarters": true})},
		"grenade-launcher": {
			"frag": expected_weapon("Grenade Launcher - Frag", 24.0, 4, 4, 4, -1, 1, {"blast": 1}),
			"krak": expected_weapon("Grenade Launcher - Krak", 24.0, 1, 4, 10, -2, 3, {"rapid-fire": 1})},
		"hand-flamer": {"standard": expected_weapon("Hand Flamer", 9.0, 3, 0, 4, 0, 1, {"torrent": true, "close-quarters": true})},
		"inferno-pistol": {"standard": expected_weapon("Inferno Pistol", 9.0, 1, 3, 8, -3, "D3+2", {"melta": 2, "close-quarters": true})},
		"plasma-pistol": {
			"standard": expected_weapon("Plasma Pistol - Standard", 12.0, 1, 3, 7, -2, 1, {"close-quarters": true}),
			"supercharge": expected_weapon("Plasma Pistol - Supercharge", 12.0, 1, 3, 8, -3, 2, {"hazardous": true, "close-quarters": true})},
		"storm-bolter": {"standard": expected_weapon("Storm Bolter", 24.0, 2, 3, 5, -1, 1, {"rapid-fire": 2})}}
	var expected_melee := {
		"chainsword": {"standard": expected_weapon("Chainsword", 0.0, 4, 3, 4, -1, 1, {})},
		"power-fist": {"standard": expected_weapon("Power Fist", 0.0, 2, 3, 8, -2, 2, {})},
		"power-weapon": {"standard": expected_weapon("Power Weapon", 0.0, 4, 3, 4, -2, 1, {})},
		"thunder-hammer": {"standard": expected_weapon("Thunder Hammer", 0.0, 3, 4, 8, -2, 3, {"devastating-wounds": true})}}
	var optional_profiles_complete: bool = expected_ranged.size() == extras.ranged.size() and expected_melee.size() == extras.melee.size()
	for weapon: Dictionary in extras.ranged:
		if expected_ranged.get(str(weapon.get("id", "")), {}) != weapon.get("profiles", {}): optional_profiles_complete = false
	for weapon: Dictionary in extras.melee:
		if expected_melee.get(str(weapon.get("id", "")), {}) != weapon.get("profiles", {}): optional_profiles_complete = false
	check(optional_profiles_complete, "All 16 optional weapon profiles match their source characteristics, damage and traits")
	var ability_names: Array[String] = []
	for ability: Dictionary in profile.get("abilities", []): ability_names.append(str(ability.get("name", "")))
	check(ability_names == ["Scouts", "Combat Doctrines", "Outflank"] and A.RULES.get(UNIT, []) == ["scouts-9", "combat-doctrines", "outflank"], "Core, faction and datasheet abilities are registered")
	for count: int in [3, 6]:
		var admitted := Army.admit({"schema_version": 2, "faction": "Space Marines", "category": "incursion", "points_limit": 1000, "entries": [entry(UNIT, count)]})
		check(str(admitted.get("error", "")).is_empty() and int(admitted.get("total", -1)) == (75 if count == 3 else 150), "%d-model profile is selectable at its source price: %s" % [count, str(admitted)])
	for count: int in [2, 4, 5, 7]:
		var rejected := Army.admit({"schema_version": 2, "faction": "Space Marines", "category": "incursion", "points_limit": 1000, "entries": [entry(UNIT, count)]})
		check(not str(rejected.get("error", "")).is_empty(), "The unpriced or source-illegal %d-model composition remains blocked" % count)
	var incursion_two := Army.admit({"schema_version": 2, "faction": "Space Marines", "category": "incursion", "points_limit": 1000, "entries": [entry(UNIT, 3, 2)]})
	var incursion_three := Army.admit({"schema_version": 2, "faction": "Space Marines", "category": "incursion", "points_limit": 1000, "entries": [entry(UNIT, 3, 3)]})
	var strike_three := Army.admit({"schema_version": 2, "faction": "Space Marines", "category": "strike_force", "points_limit": 2000, "entries": [entry(UNIT, 3, 3)]})
	check(str(incursion_two.get("error", "")).is_empty() and not str(incursion_three.get("error", "")).is_empty() and str(strike_three.get("error", "")).is_empty(), "The mounted non-Battleline repeat gate permits two copies in Incursion and three in Strike Force: %s / %s / %s" % [str(incursion_two), str(incursion_three), str(strike_three)])
	var construction_note := Army.construction_readiness_note(UNIT)
	check(construction_note.contains("Warhammer Legends") and construction_note.contains("competitive events require organiser approval") and construction_note.contains("75 x 25 mm oval") and construction_note.contains("75 mm bounding-circle proxy"), "Construction shows the Legends event boundary and oval-base proxy")

	var state := fixture()
	var bikes := models(state, UNIT, 1)
	var bike_squad := squad_for(state, UNIT, 1)
	var target_squad := squad_for(state, "intercessor-squad", 2)
	check(not state.has("error") and bikes.size() == 3 and bike_squad > 0 and target_squad > 0 and int(state.squads[bike_squad].training_cost) == 75, "The three-model datasheet materializes for both players at 75 points")
	if bikes.size() == 3:
		var defaults_match := true
		for model: int in bikes:
			if state.units[model].get("ranged_weapons", []).map(func(w: Dictionary) -> String: return w.id) != ["bolt-pistol", "shotgun", "twin-boltgun"] or state.units[model].get("melee_weapons", []).map(func(w: Dictionary) -> String: return w.id) != ["combat-knife"]: defaults_match = false
		check(defaults_match and state.units[bikes[0]].get("sergeant", false) and not state.units[bikes[1]].get("sergeant", false), "One Sergeant and two Bikers materialize with exact source-default weapons")
		check(A.has(state, bike_squad, "outflank") and A.scout_distance(state, bike_squad) == 9, "Outflank and the 9-inch Scout movement parameter attach to the unit")
		check("RAVENWING" not in state.units[bikes[0]].get("keywords", []), "The conditional RAVENWING keyword is removed outside Dark Angels context")
		var default_profiles_resolve := true
		for melee: bool in [false, true]:
			var weapons: Array = profile.melee if melee else profile.ranged
			for weapon: Dictionary in weapons:
				for profile_id: String in weapon.profiles:
					var selected := Equipment.select(state, bikes[1], melee, str(weapon.id), profile_id)
					if str(selected.get("error", "")).is_empty() and selected.get("stats", {}) == weapon.profiles[profile_id]: continue
					default_profiles_resolve = false
		check(default_profiles_resolve, "Every default weapon profile resolves to its source stats through Equipment")
		var default_attack_failures := weapon_plan_failures_for_model(state, bike_squad, bikes[1], target_squad)
		check(default_attack_failures.is_empty(), "The complete default loadout produces legal attack plans: %s" % str(default_attack_failures))
		print("Scout Bike source data and construction checks passed")

		var wrong_state: Dictionary = state.duplicate(true)
		var before_wrong_owner := var_to_bytes(wrong_state)
		var wrong_owner_choice := choice_for(wrong_state, 1, "scout-bike-grenade-launcher", bikes[1], bike_squad, "on")
		var wrong_owner := PublicUnitCommand.submit(wrong_state, 2, wrong_owner_choice)
		check(not wrong_owner_choice.is_empty() and not str(wrong_owner.get("error", "")).is_empty() and before_wrong_owner == var_to_bytes(wrong_state), "Another player cannot alter Scout Bike wargear")

		var six_state := fixture(6)
		var six_bikes := models(six_state, UNIT, 1)
		var six_squad := squad_for(six_state, UNIT, 1)
		var six_default_cost := int(six_state.squads[six_squad].training_cost)
		var launchers_applied := true
		for model: int in six_bikes:
			var result := submit(six_state, 1, "scout-bike-grenade-launcher", model, six_squad, "on")
			if not str(result.get("error", "")).is_empty() or six_state.units[model].ranged_weapons[2].id != "grenade-launcher": launchers_applied = false
		check(launchers_applied and six_bikes.size() == 6 and six_state.units[six_bikes[0]].get("sergeant", false) and int(six_state.squads[six_squad].training_cost) == six_default_cost, "Any number of models, including the Sergeant, may freely replace Twin Boltguns with Grenade Launchers")
		var combined_sergeant_option := submit(six_state, 1, "scout-bike-sergeant-option", six_bikes[0], six_squad, "thunder-hammer")
		var sergeant_ranged_ids: Array = six_state.units[six_bikes[0]].ranged_weapons.map(func(w: Dictionary) -> String: return str(w.get("id", "")))
		var sergeant_melee_ids: Array = six_state.units[six_bikes[0]].melee_weapons.map(func(w: Dictionary) -> String: return str(w.get("id", "")))
		check(str(combined_sergeant_option.get("error", "")).is_empty() and "grenade-launcher" in sergeant_ranged_ids and "thunder-hammer" in sergeant_melee_ids and int(six_state.squads[six_squad].training_cost) == six_default_cost, "The Sergeant may take a Thunder Hammer while independently carrying the optional Grenade Launcher")
		var launcher_profiles_resolve := true
		for profile_id: String in ["frag", "krak"]:
			var selected_launcher := Equipment.select(six_state, six_bikes[1], false, "grenade-launcher", profile_id)
			if str(selected_launcher.get("error", "")).is_empty() and selected_launcher.get("stats", {}) == Profiles.profile(UNIT).additional_weapon_profiles.ranged[3].profiles[profile_id]: continue
			launcher_profiles_resolve = false
		check(launcher_profiles_resolve, "Both Grenade Launcher profiles resolve to their source stats through Equipment")
		var launcher_attack_failures := weapon_plan_failures_for_model(six_state, six_squad, six_bikes[1], squad_for(six_state, "intercessor-squad", 2))
		check(launcher_attack_failures.is_empty(), "Both Grenade Launcher modes produce legal attack plans: %s" % str(launcher_attack_failures))
		var combined_attack_failures := weapon_plan_failures_for_model(six_state, six_squad, six_bikes[0], squad_for(six_state, "intercessor-squad", 2))
		check(combined_attack_failures.is_empty(), "The combined Grenade Launcher and Sergeant melee replacement produce legal attack plans: %s" % str(combined_attack_failures))
		var restore_launcher := submit(six_state, 1, "scout-bike-grenade-launcher", six_bikes[1], six_squad, "off")
		check(str(restore_launcher.get("error", "")).is_empty() and six_state.units[six_bikes[1]].ranged_weapons[2].id == "twin-boltgun", "A Biker can restore its Twin Boltgun")

		for option: String in ["boltgun", "combi-weapon", "chainsword", "grav-pistol", "hand-flamer", "inferno-pistol", "plasma-pistol", "power-fist", "power-weapon", "storm-bolter", "thunder-hammer"]:
			var option_state: Dictionary = state.duplicate(true)
			var result := submit(option_state, 1, "scout-bike-sergeant-option", bikes[0], bike_squad, option)
			var fitted := Profiles.scout_bike_squad_weapons(false, option)
			var selected_weapon_id := option
			var melee_option := option in ["chainsword", "power-fist", "power-weapon", "thunder-hammer"]
			if option == "plasma-pistol":
				for profile_name: String in ["standard", "supercharge"]:
					var selected_plasma := Equipment.select(option_state, bikes[0], false, selected_weapon_id, profile_name)
					if not str(selected_plasma.get("error", "")).is_empty(): fitted = {}
			elif option == "combi-weapon":
				for profile_name: String in ["damnatus", "infernus", "purgatus"]:
					var selected_combi := Equipment.select(option_state, bikes[0], false, selected_weapon_id, profile_name)
					if not str(selected_combi.get("error", "")).is_empty(): fitted = {}
			else:
				var selected_weapon := Equipment.select(option_state, bikes[0], melee_option, selected_weapon_id, "standard")
				if not str(selected_weapon.get("error", "")).is_empty(): fitted = {}
			var selected_profile_matches: bool = str(result.get("error", "")).is_empty() and not fitted.is_empty() and option_state.units[bikes[0]].ranged_weapons == fitted.ranged and option_state.units[bikes[0]].melee_weapons == fitted.melee
			if selected_profile_matches:
				var selected_weapons: Array = fitted.melee if melee_option else fitted.ranged
				for weapon: Dictionary in selected_weapons:
					for profile_id: String in weapon.profiles:
						var selected_variant := Equipment.select(option_state, bikes[0], melee_option, str(weapon.id), profile_id)
						if str(selected_variant.get("error", "")).is_empty() and selected_variant.get("stats", {}) == weapon.profiles[profile_id]: continue
						selected_profile_matches = false
			check(selected_profile_matches, "Sergeant replacement %s is legal and every selected weapon profile matches its source stats" % option)
			if option == "combi-weapon":
				var combi_failures := weapon_plan_failures_for_model(option_state, bike_squad, bikes[0], target_squad)
				check(combi_failures.is_empty(), "All three Combi-weapon modes produce legal attack plans: %s" % str(combi_failures))
		var restore_pistol := submit(state, 1, "scout-bike-sergeant-option", bikes[0], bike_squad, "boltgun")
		var restore_result := submit(state, 1, "scout-bike-sergeant-option", bikes[0], bike_squad, "bolt-pistol")
		check(str(restore_pistol.get("error", "")).is_empty() and str(restore_result.get("error", "")).is_empty() and state.units[bikes[0]].ranged_weapons[0].id == "bolt-pistol", "The Sergeant can restore its default Bolt Pistol after a free replacement")
		var ordinary_biker_replacement := choice_for(state, 1, "scout-bike-sergeant-option", bikes[1], bike_squad, "boltgun")
		var reject_regular_biker := PublicUnitCommand.submit(state, 1, {"action": "scout-bike-sergeant-option", "model": bikes[1], "target": bike_squad, "value": "boltgun"})
		check(ordinary_biker_replacement.is_empty() and not str(reject_regular_biker.get("error", "")).is_empty(), "Regular Bikers cannot take Sergeant-only replacements")

	var scout_state: Dictionary = state.duplicate(true)
	var scout_models := models(scout_state, UNIT, 1)
	var scout_squad := squad_for(scout_state, UNIT, 1)
	for model: int in scout_state.units:
		if scout_state.units[model].owner == 1: scout_state.units[model].position = Vector2(7, 0)
		else: scout_state.units[model].position = Vector2(20, 0)
	scout_state.board_size = Vector2(43, 44)
	scout_state.deployment = {"zones": {1: Rect2(-21.5, -22, 11, 44), 2: Rect2(10.5, -22, 11, 44)}, "complete": true}
	for index: int in range(scout_models.size()): scout_state.units[scout_models[index]].position = Vector2(-16, (index - 1) * 4.0)
	scout_state.phase = "pre_battle"
	scout_state.first_player = 1
	ScoutMoves.begin(scout_state)
	var scout_move := choice_for(scout_state, 1, "scout-move", -1, scout_squad)
	var move_started := PublicUnitCommand.submit(scout_state, 1, scout_move) if not scout_move.is_empty() else {"error": "missing Scout move"}
	var too_far := PublicUnitCommand.submit(scout_state, 1, choice_for(scout_state, 1, "scout-place", scout_models[0], scout_squad), Vector2(-6.9, -4.0))
	var placements_ok := true
	for index: int in range(scout_models.size()):
		var result := PublicUnitCommand.submit(scout_state, 1, choice_for(scout_state, 1, "scout-place", scout_models[index], scout_squad), Vector2(-7, (index - 1) * 4.0))
		if not str(result.get("error", "")).is_empty(): placements_ok = false
	var scout_confirm := choice_for(scout_state, 1, "scout-confirm", -1, scout_squad)
	var move_confirmed := PublicUnitCommand.submit(scout_state, 1, scout_confirm) if not scout_confirm.is_empty() else {"error": "missing confirmation"}
	check(not scout_move.is_empty() and str(move_started.get("error", "")).is_empty() and not str(too_far.get("error", "")).is_empty() and placements_ok and str(move_confirmed.get("error", "")).is_empty() and scout_state.phase == "pre_battle", "Scouts 9 enables a legal pre-battle move of exactly nine inches and rejects a longer move: %s / %s / %s / %s / %s / phase=%s" % [str(scout_move), str(move_started), str(too_far), str(placements_ok), str(move_confirmed), scout_state.phase])

	var ingress_state: Dictionary = state.duplicate(true)
	var ingress_models := models(ingress_state, UNIT, 1)
	var ingress_squad := squad_for(ingress_state, UNIT, 1)
	for model: int in ingress_state.units:
		if ingress_state.units[model].owner == 2: ingress_state.units[model].position = Vector2(20, 0)
	for model: int in ingress_models: ingress_state.units[model].on_battlefield = false
	ingress_state.board_size = Vector2(60, 44)
	ingress_state.deployment = {"zones": {1: Rect2(-30, -22, 11, 44), 2: Rect2(19, -22, 11, 44)}, "complete": true}
	ingress_state.unit_abilities.reserves[ingress_squad] = {"cost": 75, "source": "strategic-reserves", "deep_strike": false}
	ingress_state.phase = "movement"
	ingress_state.active = 1
	ingress_state.round = 2
	ingress_state.turn = 3
	ingress_state.unit_abilities.phase_key = U.key(ingress_state)
	var ingress_choice := choice_for(ingress_state, 1, "ingress", -1, ingress_squad)
	var ingress_started := PublicUnitCommand.submit(ingress_state, 1, ingress_choice) if not ingress_choice.is_empty() else {"error": "missing ingress"}
	var edge_reject := PublicUnitCommand.submit(ingress_state, 1, choice_for(ingress_state, 1, "ingress-place", ingress_models[0], ingress_squad), Vector2(22, -4.0))
	var near_enemy_reject := PublicUnitCommand.submit(ingress_state, 1, choice_for(ingress_state, 1, "ingress-place", ingress_models[0], ingress_squad), Vector2(25, 0))
	for model: int in ingress_state.units:
		if ingress_state.units[model].owner == 2: ingress_state.units[model].position = Vector2(10, 15)
	var enemy_safe := true
	for index: int in range(ingress_models.size()):
		var result := PublicUnitCommand.submit(ingress_state, 1, choice_for(ingress_state, 1, "ingress-place", ingress_models[index], ingress_squad), Vector2(25, (index - 1) * 4.0))
		if not str(result.get("error", "")).is_empty(): enemy_safe = false
	var ingress_confirm := choice_for(ingress_state, 1, "ingress-confirm")
	var ingress_result := PublicUnitCommand.submit(ingress_state, 1, ingress_confirm) if not ingress_confirm.is_empty() else {"error": "missing confirmation"}
	check(not ingress_choice.is_empty() and str(ingress_started.get("error", "")).is_empty() and str(edge_reject.get("error", "")).contains("within 6 inches") and str(near_enemy_reject.get("error", "")).contains("more than 8 inches") and enemy_safe and str(ingress_result.get("error", "")).is_empty() and C.living(ingress_state, ingress_squad).size() == 3, "Outflank permits early ingress inside the enemy deployment zone but keeps edge and more-than-eight-inch enemy spacing")

	print("Scout Bike Squad Legends checks: %d failures" % failures)
	quit(1 if failures else 0)

func _initialize() -> void:
	call_deferred("run")
