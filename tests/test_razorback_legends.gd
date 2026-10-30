extends SceneTree

const F = preload("res://tests/all_units_fixture.gd")
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Army = preload("res://scripts/edition_11/army_capabilities.gd")
const TransportRules = preload("res://scripts/edition_11/transport_rules.gd")
const RazorbackFireSupport = preload("res://scripts/edition_11/razorback_fire_support.gd")
const UnitAbilities = preload("res://scripts/edition_11/unit_abilities.gd")
const UnitActions = preload("res://scripts/edition_11/unit_actions.gd")
const ArmyCatalog = preload("res://scripts/implemented_army_catalog.gd")
const Combat = F.C

const RAZORBACK_ID := "40kdc:11e:adeptus-astartes:razorback"
const RELIC_RAZORBACK_ID := "40kdc:11e:adeptus-astartes:relic-razorback"
const INTERCESSOR_ID := "40kdc:11e:adeptus-astartes:intercessor-squad"

var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func selections() -> Dictionary:
	var result := F.current_marine_selections()
	for owner: int in [1, 2]:
		result[owner].category = "strike_force"
		result[owner].points_limit = 2000
	result[1].entries.append({"definition_id": RAZORBACK_ID, "models": 1, "copies": 1})
	result[1].entries.append({"definition_id": RELIC_RAZORBACK_ID, "models": 1, "copies": 1})
	return result

func build_state() -> Dictionary:
	return F.P.initial_state({"checked_rosters": false, "official_mission": false, "unit_abilities": true, "combat_doctrines": true, "core_stratagems": true}, selections())

func models_for(state: Dictionary, identity: String, owner: int = 1) -> Array[int]:
	var result: Array[int] = []
	for model: int in state.units:
		if UnitAbilities.identity(state.units[model]) == identity and int(state.units[model].owner) == owner: result.append(model)
	result.sort()
	return result

func squads_for(state: Dictionary, identity: String, owner: int = 1) -> Array[int]:
	var result: Array[int] = []
	for model: int in models_for(state, identity, owner):
		var squad := int(state.units[model].squad)
		if squad not in result: result.append(squad)
	return result

func intercessor_squad_with_size(state: Dictionary, owner: int, model_count: int) -> int:
	for squad: int in squads_for(state, "intercessor-squad", owner):
		if TransportRules.models(state, squad).size() == model_count: return squad
	return -1

func names(items: Array) -> Array[String]:
	var result: Array[String] = []
	for item: Dictionary in items:
		result.append(str(item.get("profiles", {}).get("standard", {}).get("name", "")))
	result.sort()
	return result

func check_weapon(profile: Dictionary, name: String, expected: Dictionary, identity: String) -> void:
	var found := false
	for section: String in ["ranged", "melee"]:
		for weapon: Dictionary in profile.get(section, []):
			for data: Dictionary in weapon.get("profiles", {}).values():
				if str(data.get("name", "")) == name:
					check(data == expected, "%s %s profile matches source characteristics and keywords: %s" % [identity, name, str(data)])
					found = true
		for weapon: Dictionary in profile.get("additional_weapon_profiles", {}).get(section, []):
			for data: Dictionary in weapon.get("profiles", {}).values():
				if str(data.get("name", "")) == name:
					check(data == expected, "%s %s option profile matches source characteristics and keywords: %s" % [identity, name, str(data)])
					found = true
	check(found, "%s contains the source weapon profile %s" % [identity, name])

func test_source_profiles() -> void:
	var expected_hashes := {
		"Datasheets.csv": "45df2602251657c5713b341dbe70127630a76a657c43525703b3b19c6cb9d469",
		"Datasheets_abilities.csv": "182b80e44d7f4ae1025a71d8ff3776c33bcc58d8b2e1709cf26448f356e51b1d",
		"Datasheets_keywords.csv": "5e1d811ca8b5a92427a2b5a33fe6f731e7ef877fc08a6761e02822402a3561a8",
		"Datasheets_models.csv": "4647792360285babac2fc5ef5adf2708397f47f455fbaa0773491a96aa7a3da5",
		"Datasheets_models_cost.csv": "0236376fcb947a8c9e4883df7af0f38a0923b11d8d907035e5e9e47c52446de8",
		"Datasheets_options.csv": "44a652d49f7e93d6f7acaae805d907b3ce156cbd14c1db7fe35fd66712f4a0fe",
		"Datasheets_unit_composition.csv": "b980856c29676675f81abfbbcc1161ad64253f15925df21c8968cd8bbaca13e7",
		"Datasheets_wargear.csv": "13e3e6d1e0c4114e41d1cc9c80fe94e8d0e37b628b9af5625d88aeba0c7cbe9d"
	}
	var razorback := Profiles.profile("razorback")
	var relic := Profiles.profile("relic-razorback")
	for pair: Dictionary in [{"id": "razorback", "sheet": "000000129", "points": 95, "profile": razorback}, {"id": "relic-razorback", "sheet": "000002720", "points": 105, "profile": relic}]:
		var identity := str(pair.id)
		var profile: Dictionary = pair.profile
		check(profile.get("source_book_id") == "000000356" and profile.get("source_datasheet_id") == str(pair.sheet) and profile.get("source_scope") == "Warhammer Legends", "%s binds to its exact current Space Marines Legends sheet" % identity)
		check(profile.get("source_snapshot_id") == Profiles.VERIFIED_EXPORT_SNAPSHOT_ID and profile.get("source_manifest_sha256") == Profiles.VERIFIED_EXPORT_MANIFEST_SHA256 and profile.get("source_slice_manifest_sha256") == Profiles.VERIFIED_EXPORT_SLICE_SHA256_BY_BOOK["000000356"], "%s binds to the verified local export and Legends slice" % identity)
		var actual_hashes: Dictionary = {}
		for file: Dictionary in profile.get("source_files", []): actual_hashes[str(file.name)] = str(file.sha256)
		var hashes_match := actual_hashes.size() == expected_hashes.size()
		var hash_mismatches: Array[String] = []
		for file_name: String in expected_hashes:
			if str(actual_hashes.get(file_name, "")) != str(expected_hashes[file_name]):
				hashes_match = false
				hash_mismatches.append("%s: %s != %s" % [file_name, str(actual_hashes.get(file_name, "")), str(expected_hashes[file_name])])
		check(hashes_match, "%s records all eight exact source CSV hashes: %s" % [identity, "; ".join(hash_mismatches)])
		check(profile.get("points_by_models", {}) == {1: int(pair.points)} and profile.get("second_plus_points_by_models", {}) == {1: int(pair.points)} and profile.get("third_plus_points_by_models", {}) == {1: int(pair.points)} and profile.get("max_supported_copies") == 6, "%s uses the source one-model price at all three tiers and supports the six-copy Strike Force ceiling" % identity)
		check(Army.standard_unit_copy_limit("incursion", profile.get("keywords", [])) == 4 and Army.standard_unit_copy_limit("strike_force", profile.get("keywords", [])) == 6, "%s follows the Dedicated Transport copy cap in both standard game sizes" % identity)
		check(profile.get("models") == 1 and profile.get("stats", {}) == {"movement_inches": 12, "toughness": 9, "save_target": 3, "wounds": 10, "leadership_target": 6, "objective_control": 2, "invulnerable_target": 0}, "%s has the exact one-model composition and characteristics" % identity)
		check(profile.get("keywords", []) == ["ADEPTUS ASTARTES", "SMOKE", "FRAME", "VEHICLE", "DEDICATED TRANSPORT", "TRANSPORT", "IMPERIUM"], "%s includes all source keywords in source order" % identity)
		check(profile.get("default_loadout_by_role", {}).get(profile.name, {}) == {"Armoured Tracks": 1, "Twin Heavy Bolter": 1}, "%s starts with the complete source loadout" % identity)
		check(profile.get("base_size_source") == "Use model" and profile.get("base_geometry") == "circular-model-footprint-proxy" and profile.get("geometry_scope", "").contains("120 mm") and profile.get("geometry_scope", "").contains("not certified"), "%s labels the 120 mm footprint as an uncertified proxy" % identity)
		var transport: Dictionary = profile.get("transport", {})
		check(transport.get("capacity") == 6 and transport.get("required") == ["ADEPTUS ASTARTES", "INFANTRY"] and transport.get("forbidden", []).size() == 4, "%s carries up to six eligible Astartes Infantry and has four forbidden model classes" % identity)
		check(UnitAbilities.TRANSPORT_DEADLY_DEMISE.get(identity) == "D3" and profile.get("abilities", []).any(func(ability: Dictionary) -> bool: return ability.get("name", "") == "Deadly Demise" and ability.get("parameter", "") == "D3"), "%s registers its source Deadly Demise D3 profile" % identity)
		check(profile.get("abilities", []).any(func(ability: Dictionary) -> bool: return ability.get("name", "") == "Fire Support" and str(ability.get("text", "")).contains("re-roll Wound rolls")), "%s carries its Fire Support effect text" % identity)
		check(profile.get("special_rules", []) == ["Combat Doctrines", "Deadly Demise D3", "Fire Support"], "%s registers all source and faction abilities" % identity)
		if identity == "relic-razorback":
			check(profile.abilities[2].get("source_name", "") == "Fire Supprt" and profile.abilities[2].get("source_name_note", "").contains("normalized"), "The Relic export typo is preserved in provenance while runtime uses Fire Support")
	check(razorback.get("source_datasheet_id") != relic.get("source_datasheet_id"), "Razorback and Relic Razorback remain distinct datasheets")

	check_weapon(razorback, "Twin Heavy Bolter", {"name": "Twin Heavy Bolter", "range_inches": 36.0, "attacks": 3, "skill": 3, "strength": 5, "ap": -1, "damage": 2, "keywords": {"rapid-fire": 2, "sustained-hits": 1, "twin-linked": true}}, "razorback")
	check_weapon(razorback, "Twin Lascannon", {"name": "Twin Lascannon", "range_inches": 48.0, "attacks": 1, "skill": 3, "strength": 12, "ap": -3, "damage": "D3+3", "keywords": {"twin-linked": true}}, "razorback")
	check_weapon(razorback, "Hunter-killer Missile", {"name": "Hunter-killer Missile", "range_inches": 48.0, "attacks": 1, "skill": 2, "strength": 14, "ap": -3, "damage": "D3+3", "keywords": {"one-shot": true}}, "razorback")
	check_weapon(razorback, "Storm Bolter", {"name": "Storm Bolter", "range_inches": 24.0, "attacks": 2, "skill": 3, "strength": 5, "ap": -1, "damage": 1, "keywords": {"rapid-fire": 2}}, "razorback")
	check_weapon(relic, "Multi-melta", {"name": "Multi-melta", "range_inches": 18.0, "attacks": 2, "skill": 3, "strength": 10, "ap": -3, "damage": "D3+2", "keywords": {"melta": 3}}, "relic-razorback")
	check_weapon(relic, "Twin Assault Cannon", {"name": "Twin Assault Cannon", "range_inches": 24.0, "attacks": 6, "skill": 3, "strength": 6, "ap": -2, "damage": 1, "keywords": {"twin-linked": true, "sustained-hits": 1}}, "relic-razorback")
	check_weapon(relic, "Twin Lascannon", {"name": "Twin Lascannon", "range_inches": 48.0, "attacks": 1, "skill": 3, "strength": 12, "ap": -3, "damage": "D3+3", "keywords": {"twin-linked": true}}, "relic-razorback")
	check_weapon(relic, "Hunter-killer Missile", {"name": "Hunter-killer Missile", "range_inches": 48.0, "attacks": 1, "skill": 2, "strength": 14, "ap": -3, "damage": "D3+3", "keywords": {"one-shot": true}}, "relic-razorback")
	check_weapon(relic, "Storm Bolter", {"name": "Storm Bolter", "range_inches": 24.0, "attacks": 2, "skill": 3, "strength": 5, "ap": -1, "damage": 1, "keywords": {"rapid-fire": 2}}, "relic-razorback")
	for profile: Dictionary in [razorback, relic]:
		check_weapon(profile, "Armoured Tracks", {"name": "Armoured Tracks", "range_inches": 0.0, "attacks": 3, "skill": 4, "strength": 6, "ap": 0, "damage": 1, "keywords": {}}, str(profile.name))
	check(names(razorback.ranged + razorback.additional_weapon_profiles.ranged) == ["Hunter-killer Missile", "Storm Bolter", "Twin Heavy Bolter", "Twin Lascannon"], "The Razorback exposes all four legal ranged weapon profiles")
	check(names(relic.ranged + relic.additional_weapon_profiles.ranged) == ["Hunter-killer Missile", "Multi-melta", "Storm Bolter", "Twin Assault Cannon", "Twin Heavy Bolter", "Twin Lascannon"], "The Relic Razorback exposes all six legal ranged weapon profiles")
	var standard_group: Dictionary = razorback.transport.options.replacement_groups["primary-weapon"]
	var relic_group: Dictionary = relic.transport.options.replacement_groups["primary-weapon"]
	check(standard_group.get("choices", {}).keys() == ["twin-lascannon"], "Razorback replacement offers only its source-listed Twin Lascannon")
	check(relic_group.get("choices", {}).size() == 3 and relic_group.choices.has("twin-lascannon") and relic_group.choices.has("multi-melta") and relic_group.choices.has("twin-assault-cannon"), "Relic Razorback replacement offers all three source-listed alternatives")
	check(razorback.transport.options.add == ["Hunter-killer Missile", "Storm Bolter"] and relic.transport.options.add == ["Hunter-killer Missile", "Storm Bolter"], "Both sheets expose optional missile and storm bolter without invented wargear")

func test_construction_and_loadouts(state: Dictionary) -> void:
	var catalog := ArmyCatalog.new()
	check(catalog.select_edition("11e").is_empty(), "The consolidated current-reference construction catalog loads")
	for identity: String in ["razorback", "relic-razorback"]:
		var record: Array = catalog.catalog.units.filter(func(unit: Dictionary) -> bool: return str(unit.get("source_id", "")) == identity)
		check(record.size() == 1 and catalog.excluded.get(identity, "").is_empty(), "%s is selectable after its source-bounded checks" % identity)
		if record.size() == 1:
			check(record[0].get("options", []) == [{"models": 1, "cost": 95 if identity == "razorback" else 105, "second_plus_cost": 95 if identity == "razorback" else 105, "third_plus_cost": 95 if identity == "razorback" else 105}], "%s catalog preserves each copy-tier price" % identity)
		var readiness_note := str(Army.current_catalog_choice({"id": "40kdc:11e:adeptus-astartes:" + identity, "edition": "11e", "faction": "Space Marines"}).get("construction_scope", ""))
		check(readiness_note.contains("up to 4 copies in Incursion") and readiness_note.contains("6 in Strike Force"), "%s construction guidance shows its source-standard copy limits" % identity)
	catalog.free()
	var razorbacks := models_for(state, "razorback")
	var relics := models_for(state, "relic-razorback")
	check(razorbacks.size() == 1 and relics.size() == 1, "The prepared roster materializes one model of each distinct datasheet")
	if razorbacks.size() != 1 or relics.size() != 1: return
	var razorback: int = razorbacks[0]
	var relic: int = relics[0]
	var weapon_choices := TransportRules.transport_weapon_loadout_choices(state, 1)
	var standard_choices: Array = weapon_choices.filter(func(option: Dictionary) -> bool: return int(option.model) == razorback)
	var relic_choices: Array = weapon_choices.filter(func(option: Dictionary) -> bool: return int(option.model) == relic)
	check(standard_choices.size() == 3 and relic_choices.size() == 5, "Army Preparation exposes two optional weapons and each sheet's valid primary replacements")
	check(standard_choices.any(func(option: Dictionary) -> bool: return option.value == "group:primary-weapon:twin-lascannon"), "Razorback offers its sole legal primary replacement")
	check(relic_choices.any(func(option: Dictionary) -> bool: return option.value == "group:primary-weapon:multi-melta") and relic_choices.any(func(option: Dictionary) -> bool: return option.value == "group:primary-weapon:twin-assault-cannon"), "Relic Razorback offers both special primary replacement alternatives")
	for transport_model: int in [razorback, relic]:
		var before := int(state.training_points.get(1, 0))
		for option_value: String in ["hunter-killer-missile:on", "storm-bolter:on"]:
			check(TransportRules.configure_optional_transport_weapon(state, transport_model, option_value).is_empty(), "Army Preparation equips the listed option %s" % option_value)
		check(state.training_points.get(1, 0) == before, "The source-listed optional transport weapons do not add points")
		check(state.units[transport_model].ranged_weapons.any(func(weapon: Dictionary) -> bool: return weapon.id == "hunter-killer-missile") and state.units[transport_model].ranged_weapons.any(func(weapon: Dictionary) -> bool: return weapon.id == "storm-bolter"), "Optional choices are installed in the actual transport weapon inventory")
	check(TransportRules.configure_optional_transport_weapon(state, razorback, "group:primary-weapon:twin-lascannon").is_empty(), "Razorback accepts its legal primary replacement")
	check(state.units[razorback].ranged_weapons.any(func(weapon: Dictionary) -> bool: return weapon.id == "twin-lascannon") and not state.units[razorback].ranged_weapons.any(func(weapon: Dictionary) -> bool: return weapon.id == "twin-heavy-bolter"), "Replacing the default Twin Heavy Bolter removes it and installs a Twin Lascannon")
	for replacement: String in ["multi-melta", "twin-assault-cannon", "twin-lascannon"]:
		check(TransportRules.configure_optional_transport_weapon(state, relic, "group:primary-weapon:" + replacement).is_empty(), "Relic Razorback accepts the legal primary choice %s" % replacement)
		check(state.units[relic].ranged_weapons.any(func(weapon: Dictionary) -> bool: return weapon.id == replacement), "Relic Razorback live inventory updates to %s" % replacement)
		check(TransportRules.configure_optional_transport_weapon(state, relic, "group:primary-weapon:default").is_empty(), "Relic Razorback can restore its default primary weapon")
	check(not TransportRules.configure_optional_transport_weapon(state, razorback, "group:primary-weapon:multi-melta").is_empty(), "The standard Razorback rejects Relic-only primary weapons")
	check(not TransportRules.configure_optional_transport_weapon(state, razorback, "unknown-weapon:on").is_empty(), "The transport rejects weapon identifiers outside the source choices")

	var five := intercessor_squad_with_size(state, 1, 5)
	var ten := intercessor_squad_with_size(state, 1, 10)
	check(five >= 0 and ten >= 0, "Five- and ten-model Infantry test formations are present")
	if five >= 0 and ten >= 0:
		check(TransportRules.capacity_cost(state, five, Profiles.profile("razorback").transport) == 5 and TransportRules.eligibility_error(state, razorback, five).is_empty(), "Five eligible Astartes Infantry occupy five of the Razorback's six spaces")
		check(TransportRules.capacity_cost(state, ten, Profiles.profile("razorback").transport) == 10 and TransportRules.eligibility_error(state, razorback, ten).contains("not have enough remaining capacity"), "A ten-model Infantry unit cannot exceed the six-space capacity")
		var first_passenger := TransportRules.models(state, five)[0]
		state.units[first_passenger].keywords.append("JUMP PACK")
		check(TransportRules.eligibility_error(state, razorback, five).contains("cannot carry JUMP PACK"), "The transport rejects a passenger model with a forbidden Jump Pack keyword")
		state.units[first_passenger].keywords.erase("JUMP PACK")
		var enemy_five := intercessor_squad_with_size(state, 2, 5)
		check(TransportRules.eligibility_error(state, razorback, enemy_five).contains("friendly transport"), "A passenger from the opponent's army cannot embark")
	return

func test_fire_support_and_disembark(state: Dictionary) -> void:
	var razorbacks := models_for(state, "razorback")
	var relics := models_for(state, "relic-razorback")
	var passenger_squad := intercessor_squad_with_size(state, 1, 5)
	var target_squad := intercessor_squad_with_size(state, 2, 5)
	var missed_squad := intercessor_squad_with_size(state, 2, 10)
	check(razorbacks.size() == 1 and relics.size() == 1 and passenger_squad >= 0 and target_squad >= 0 and missed_squad >= 0, "Fire Support scenario resolves its source, passengers and both enemy candidates")
	if razorbacks.size() != 1 or relics.size() != 1 or passenger_squad < 0 or target_squad < 0 or missed_squad < 0: return
	var razorback: int = razorbacks[0]
	var relic: int = relics[0]
	var source_squad := int(state.units[razorback].squad)
	state.terrain = {"id": "razorback-empty-test-board", "areas": []}
	state.units[razorback].position = Vector2(0, 0)
	for model: int in state.units:
		if int(state.units[model].owner) == 2:
			state.units[model].position = Vector2(12.0 if int(state.units[model].squad) == target_squad else 18.0, float(model % 5) * 1.4)
		elif int(state.units[model].squad) != passenger_squad and int(state.units[model].squad) != source_squad and int(state.units[model].squad) != int(state.units[relic].squad):
			state.units[model].on_battlefield = false
	state.phase = "deployment"
	check(TransportRules.start_embark(state, 1, razorback, passenger_squad).is_empty(), "A complete eligible five-model unit can start embarked in the transport")
	state.turn = 1
	state.phase = "movement"
	state.active = 1
	var disembark_error := TransportRules.begin_disembark(state, 1, razorback, passenger_squad, "tactical")
	check(disembark_error.is_empty(), "Passengers can begin a legal Tactical Disembark: " + disembark_error)
	if not disembark_error.is_empty(): return
	var passenger_models := TransportRules.models(state, passenger_squad)
	var offsets: Array[float] = [-2.6, -1.3, 0.0, 1.3, 2.6]
	for index in range(passenger_models.size()):
		var model := passenger_models[index]
		var point := Vector2(3.1, offsets[index])
		var place_error := TransportRules.apply(state, 1, {"action": "transport-disembark-place", "model": model, "target": passenger_squad, "value": ""}, point)
		check(place_error.is_empty(), "A passenger base can be placed within the transport's movement limit: " + place_error)
	var confirm_error := TransportRules.apply(state, 1, {"action": "transport-disembark-confirm", "model": -1, "target": passenger_squad, "value": ""}, Vector2.ZERO)
	check(confirm_error.is_empty() and int(state.squads[passenger_squad].get("disembarked_from_transport", -1)) == source_squad and int(state.squads[passenger_squad].get("disembarked_turn", -1)) == 1, "Completing the normal disembark records its exact transport and turn: " + confirm_error)
	if not confirm_error.is_empty(): return
	check(UnitAbilities.has(state, source_squad, "razorback-fire-support") and UnitAbilities.deadly_demise_value(state, razorback) == "D3" and UnitAbilities.deadly_demise_value(state, relic) == "D3", "Both transport identities register Fire Support and Deadly Demise D3")
	state.phase = "shooting"
	state.active = 1
	state.unit_abilities.window = {}
	var hit_pools: Array = [{"target_squad": target_squad, "hits": 1}, {"target_squad": missed_squad, "hits": 0}]
	check(RazorbackFireSupport.eligible_targets(state, source_squad, hit_pools) == [target_squad], "Only an enemy unit hit by the Razorback's attacks is eligible for the mark")
	check(RazorbackFireSupport.open_after_shot(state, source_squad, hit_pools), "After its shot, the Razorback opens its Fire Support target decision")
	var target_choices := UnitActions.choices(state, 1).filter(func(option: Dictionary) -> bool: return str(option.get("action", "")) == RazorbackFireSupport.ACTION)
	check(target_choices.size() == 1 and int(target_choices[0].target) == target_squad, "The action flow offers exactly the enemy unit actually hit")
	if target_choices.size() != 1: return
	var apply_result := RazorbackFireSupport.apply(state, 1, target_choices[0])
	check(str(apply_result.get("error", "")).is_empty() and int(state.unit_abilities.fire_support_marks[source_squad].target_squad) == target_squad, "The player can resolve and persist the source-bound target mark")
	check(not RazorbackFireSupport.open_after_shot(state, source_squad, hit_pools), "The same transport cannot open a second Fire Support decision in that turn")
	var other_transport_squad := int(state.units[relic].squad)
	state.squads[passenger_squad].disembarked_from_transport = other_transport_squad
	check(not RazorbackFireSupport.applies_to_attack(state, passenger_squad, target_squad), "The wound re-roll does not apply when the passenger left the other transport")
	state.squads[passenger_squad].disembarked_from_transport = source_squad
	state.squads[passenger_squad].disembarked_turn = 0
	check(not RazorbackFireSupport.applies_to_attack(state, passenger_squad, target_squad), "The wound re-roll expires when the passenger disembarked on a different turn")
	state.squads[passenger_squad].disembarked_turn = 1
	state.units[relic].position = Vector2(-8, 0)
	state.phase = "shooting"
	var entries: Array = Combat.AttackPlan.single_target(state, passenger_squad, target_squad, false)
	var prepared: Dictionary = Combat.AttackPlan.prepare(state, passenger_squad, false, entries, true)
	var batch: Dictionary = {}
	for candidate: Dictionary in prepared.get("batches", []):
		if candidate.get("context", {}).get("free_wound_reroll_source", "") == "Fire Support": batch = candidate
	check(prepared.get("error", "").is_empty() and not batch.is_empty(), "Intercessor attacks against the marked target receive the Fire Support re-roll in the actual attack plan: " + str(prepared.get("error", "")))
	if batch.is_empty(): return
	check(batch.context.get("free_wound_reroll", false) and batch.context.get("free_wound_reroll_source", "") == "Fire Support", "Fire Support grants optional individual Wound re-rolls rather than a forced re-roll")
	state.pending_attack = {"player": 1, "current": {"checkpoint": {"phase": "wound", "context": batch.context.duplicate(true), "effective_wounds": [6, 2], "rerolled_wounds": []}}}
	state.unit_abilities.window = {"kind": "wound", "owners": [1]}
	var wound_choices := UnitActions.choices(state, 1).filter(func(option: Dictionary) -> bool: return str(option.get("action", "")) == "wound-reroll" and str(option.get("label", "")).begins_with("Fire Support:"))
	check(wound_choices.size() == 2 and wound_choices.any(func(option: Dictionary) -> bool: return int(option.get("target", -1)) == 0) and wound_choices.any(func(option: Dictionary) -> bool: return int(option.get("target", -1)) == 1), "The attack window lets the player choose whether to re-roll each eligible Wound die")

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	test_source_profiles()
	var state := build_state()
	check(not state.has("error"), "A current-reference roster with both Razorback datasheets materializes: " + str(state.get("error", "")))
	if not state.has("error"):
		test_construction_and_loadouts(state)
		test_fire_support_and_disembark(state)
	print("Razorback Legends checks: %d failures" % failures)
	quit(1 if failures else 0)
