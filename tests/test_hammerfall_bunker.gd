extends SceneTree

const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Army = preload("res://scripts/edition_11/army_capabilities.gd")
const Capabilities = preload("res://scripts/edition_11/capabilities.gd")
const Catalog = preload("res://scripts/implemented_army_catalog.gd")
const Fortifications = preload("res://scripts/edition_11/fortification_rules.gd")
const UNIT_ID := "40kdc:11e:adeptus-astartes:hammerfall-bunker"
const SOURCE_ID := "hammerfall-bunker"

var failures := 0
var dice_calls := 0

func _initialize() -> void:
	call_deferred("run")

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
		result[owner].entries = [entry("intercessor-squad", 5), entry("intercessor-squad", 10)]
	result[1].entries.append(entry(SOURCE_ID))
	return result

func battle() -> Dictionary:
	return F.P.initial_state({"checked_rosters": false, "unit_abilities": true, "combat_doctrines": true, "core_stratagems": true}, selections())

func model_for(state: Dictionary, owner: int, identity: String) -> int:
	for model: int in state.units:
		if int(state.units[model].get("owner", -1)) == owner and C.UnitAbilities.identity(state.units[model]) == identity: return model
	return -1

func squads_for(state: Dictionary, owner: int, identity: String, size: int = -1) -> Array[int]:
	var result: Array[int] = []
	for model: int in state.units:
		var unit: Dictionary = state.units[model]
		if int(unit.get("owner", -1)) != owner or C.UnitAbilities.identity(unit) != identity: continue
		var squad := int(unit.get("squad", -1))
		if size >= 0 and C.living(state, squad).size() != size: continue
		if squad not in result: result.append(squad)
	result.sort()
	return result

func choice_for(state: Dictionary, action: String, model: int, value: String = "") -> Dictionary:
	for choice: Dictionary in C.UnitActions.choices(state, 1):
		if str(choice.get("action", "")) == action and int(choice.get("model", -1)) == model and (value.is_empty() or str(choice.get("value", "")) == value): return choice
	return {}

func fixed_die() -> int:
	dice_calls += 1
	return 1

func test_source_and_admission() -> void:
	var profile := Profiles.profile(SOURCE_ID)
	check(profile.get("source_book_id", "") == "000000356" and profile.get("source_datasheet_id", "") == "000000097" and profile.get("source_scope", "") == "Warhammer Legends", "The profile binds to the Hammerfall Bunker Legends datasheet")
	check(profile.get("source_snapshot_id", "") == Profiles.VERIFIED_EXPORT_SNAPSHOT_ID and profile.get("source_retrieved_at_utc", "") == "2026-10-30T01:33:48.347556+00:00" and profile.get("source_export_updated_at", "") == Profiles.VERIFIED_EXPORT_UPDATED_AT, "The profile records the verified local export identity and retrieval time")
	check(profile.get("source_manifest_sha256", "") == Profiles.VERIFIED_EXPORT_MANIFEST_SHA256 and profile.get("source_slice_manifest_sha256", "") == Profiles.VERIFIED_EXPORT_SLICE_SHA256_BY_BOOK["000000356"], "The parent export and exact Legends slice hashes are recorded")
	var expected_files := {
		"Datasheets.csv": "45df2602251657c5713b341dbe70127630a76a657c43525703b3b19c6cb9d469",
		"Datasheets_abilities.csv": "182b80e44d7f4ae1025a71d8ff3776c33bcc58d8b2e1709cf26448f356e51b1d",
		"Datasheets_keywords.csv": "5e1d811ca8b5a92427a2b5a33fe6f731e7ef877fc08a6761e02822402a3561a8",
		"Datasheets_models.csv": "4647792360285babac2fc5ef5adf2708397f47f455fbaa0773491a96aa7a3da5",
		"Datasheets_models_cost.csv": "0236376fcb947a8c9e4883df7af0f38a0923b11d8d907035e5e9e47c52446de8",
		"Datasheets_options.csv": "44a652d49f7e93d6f7acaae805d907b3ce156cbd14c1db7fe35fd66712f4a0fe",
		"Datasheets_unit_composition.csv": "b980856c29676675f81abfbbcc1161ad64253f15925df21c8968cd8bbaca13e7",
		"Datasheets_wargear.csv": "13e3e6d1e0c4114e41d1cc9c80fe94d8e0e37b628b9af5625d88aeba0c7cbe9d"
	}
	var actual_files: Dictionary = {}
	for record: Dictionary in profile.get("source_files", []): actual_files[str(record.get("name", ""))] = str(record.get("sha256", ""))
	var files_match := actual_files.size() == expected_files.size()
	var file_mismatches: Array[String] = []
	for filename: String in expected_files:
		if str(actual_files.get(filename, "")) != str(expected_files[filename]):
			files_match = false
			file_mismatches.append(filename + " actual=" + str(actual_files.get(filename, "")) + " expected=" + str(expected_files[filename]))
	check(files_match, "The eight source-filtered table hashes match the verified Legends slice: " + str(file_mismatches))
	check(profile.get("points_by_models", {}) == {1: 175} and profile.get("second_plus_points_by_models", {}) == {1: 175} and profile.get("third_plus_points_by_models", {}) == {1: 175}, "All three source price tiers are 175 points for one model")
	check(profile.get("models", 0) == 1 and profile.get("stats", {}) == {"movement_inches": 0, "toughness": 12, "save_target": 2, "wounds": 14, "leadership_target": 6, "objective_control": 0, "invulnerable_target": 0}, "Composition and all seven characteristics match the source")
	check(profile.get("keywords", []) == ["ADEPTUS ASTARTES", "VEHICLE", "FORTIFICATION", "FRAME", "IMPERIUM"], "All source keywords are preserved in order")
	check(profile.get("default_loadout_by_role", {}).get("Hammerfall Bunker", {}) == {"Hammerfall Heavy Bolter Array": 1, "Hammerfall Missile Launcher": 1}, "The default source loadout is complete")
	check(profile.get("base_size_source", "") == "Use model" and profile.get("base_radius_inches", 0.0) == 60.0 / 25.4 and str(profile.get("geometry_scope", "")).contains("120 mm") and str(profile.get("geometry_scope", "")).contains("not certified"), "The source-unspecified footprint remains an explicit, non-certified interaction proxy")
	check(profile.get("options", {}).get("replacement_groups", {}).get("heavy-weapon-array", {}).get("choices", {}).has("hammerfall-heavy-flamer-array"), "The only source-listed heavy array replacement is present")
	check(profile.get("special_rules", []) == ["Combat Doctrines", "Deadly Demise D6", "Damaged 5", "Ceramite Cover", "Defensive Array", "Fortification"], "All six source/faction abilities are recorded")
	check(Army.SPECS.get(SOURCE_ID, {}).get("validation_status", "") == "source_bounded_local_rules_passed_placement_partial_2026_10_30" and Army.SPECS[SOURCE_ID].get("max_supported_copies", 0) == 3, "The profile retains its precise local readiness boundary and copy ceiling")
	check(C.UnitAbilities.RULES.get(SOURCE_ID, []) == ["combat-doctrines", "damaged-5", "deadly-demise-d6", "ceramite-cover", "defensive-array", "fortification"], "All source abilities are attached to this identity")
	for ability: String in ["ceramite-cover", "defensive-array", "fortification", "deadly-demise-d6", "damaged-5"]:
		check(Capabilities.supported(ability), "%s is present in the capability registry" % ability)

	var catalog := Catalog.new()
	check(catalog.select_edition("11e").is_empty(), "Hammerfall is published through the consolidated local 11e catalog")
	var sheet := catalog.lookup(UNIT_ID)
	check(sheet.get("source_scope", "") == "Warhammer Legends" and sheet.get("options", []) == [{"models": 1, "cost": 175, "second_plus_cost": 175, "third_plus_cost": 175}] and str(sheet.get("scope", "")).contains("competitive events require organiser approval") and str(sheet.get("scope", "")).contains("120 mm"), "Construction exposes its exact price, Legends/event approval and placement boundary: " + str(sheet))
	catalog.free()
	var incursion_two := Army.admit({"schema_version": 2, "faction": "Space Marines", "category": "incursion", "points_limit": 1000, "entries": [entry(SOURCE_ID, 1, 2)]})
	var incursion_three := Army.admit({"schema_version": 2, "faction": "Space Marines", "category": "incursion", "points_limit": 1000, "entries": [entry(SOURCE_ID, 1, 3)]})
	var strike_three := Army.admit({"schema_version": 2, "faction": "Space Marines", "category": "strike_force", "points_limit": 2000, "entries": [entry(SOURCE_ID, 1, 3)]})
	var strike_four := Army.admit({"schema_version": 2, "faction": "Space Marines", "category": "strike_force", "points_limit": 2000, "entries": [entry(SOURCE_ID, 1, 4)]})
	check(incursion_two.get("error", "").is_empty() and incursion_two.get("total", -1) == 350 and not str(incursion_three.get("error", "")).is_empty(), "Incursion admits two Hammerfalls for 350 points and rejects a third")
	check(strike_three.get("error", "").is_empty() and strike_three.get("total", -1) == 525 and not str(strike_four.get("error", "")).is_empty(), "Strike Force admits three Hammerfalls for 525 points and rejects a fourth")

func test_weapon_loadout_and_damage(state: Dictionary, bunker_model: int, bunker_squad: int, enemy_squad: int) -> void:
	var profile := Profiles.profile(SOURCE_ID)
	check(profile.get("ranged", []).size() == 2 and profile.get("additional_weapon_profiles", {}).get("ranged", []).size() == 1 and profile.get("melee", []).is_empty(), "Both fixed ranged weapons, replacement and absence of melee are represented")
	var bolter: Dictionary = profile.ranged[0].profiles.standard
	var flamer: Dictionary = profile.additional_weapon_profiles.ranged[0].profiles.standard
	var superfrag: Dictionary = profile.ranged[1].profiles.superfrag
	var superkrak: Dictionary = profile.ranged[1].profiles.superkrak
	check(bolter == {"name": "Hammerfall Heavy Bolter Array", "range_inches": 36.0, "attacks": 6, "skill": 4, "strength": 5, "ap": -1, "damage": 2, "keywords": {"sustained-hits": 1, "rapid-fire": 2, "twin-linked": true}}, "Heavy Bolter Array matches all source characteristics and weapon keywords")
	check(flamer == {"name": "Hammerfall Heavy Flamer Array", "range_inches": 12.0, "attacks": 6, "skill": null, "strength": 5, "ap": -1, "damage": 1, "keywords": {"twin-linked": true, "torrent": true, "blast": 2}}, "Heavy Flamer Array replacement has Torrent, Twin-linked and Blast 2")
	check(superfrag == {"name": "Hammerfall Missile Launcher - Superfrag", "range_inches": 48.0, "attacks": 7, "skill": 4, "strength": 5, "ap": -1, "damage": 1, "keywords": {"blast": 1}} and superkrak == {"name": "Hammerfall Missile Launcher - Superkrak", "range_inches": 48.0, "attacks": 2, "skill": 4, "strength": 10, "ap": -2, "damage": "D3+3", "keywords": {}}, "Both selectable missile profiles match the source")
	var default_choice := choice_for(state, "hammerfall-loadout", bunker_model)
	check(default_choice.get("value", "") == "heavy-flamer" and state.units[bunker_model].ranged_weapons.any(func(weapon: Dictionary) -> bool: return weapon.get("id", "") == "hammerfall-heavy-bolter-array"), "Army Preparation offers the Heavy Flamer replacement while the default bolter is equipped")
	var before_points := int(state.get("training_points", {}).get(1, 0))
	var replaced := C.UnitActions.apply(state, 1, default_choice, Vector2.ZERO, Callable())
	check(replaced.get("error", "").is_empty() and state.units[bunker_model].ranged_weapons.any(func(weapon: Dictionary) -> bool: return weapon.get("id", "") == "hammerfall-heavy-flamer-array") and not state.units[bunker_model].ranged_weapons.any(func(weapon: Dictionary) -> bool: return weapon.get("id", "") == "hammerfall-heavy-bolter-array"), "The legal preparation choice replaces the array without leaving both weapons equipped")
	check(int(state.get("training_points", {}).get(1, 0)) == before_points, "The no-cost replacement does not alter the roster total")
	var restore_choice := choice_for(state, "hammerfall-loadout", bunker_model, "heavy-bolter")
	var restored := C.UnitActions.apply(state, 1, restore_choice, Vector2.ZERO, Callable())
	check(restored.get("error", "").is_empty() and state.units[bunker_model].ranged_weapons.any(func(weapon: Dictionary) -> bool: return weapon.get("id", "") == "hammerfall-heavy-bolter-array"), "Army Preparation can restore the default Heavy Bolter Array")
	state.phase = "shooting"
	state.active = 1
	state.unit_abilities.window = {}
	state.units[bunker_model].position = Vector2.ZERO
	var targets := C.living(state, enemy_squad)
	for index: int in targets.size(): state.units[targets[index]].position = Vector2(20.0 + float(index) * 1.2, 5.0)
	var bolter_attack := C.AttackPlan.prepare(state, bunker_squad, false, [{"model": bunker_model, "target": enemy_squad, "amount": 1, "weapon": "hammerfall-heavy-bolter-array", "profile": "standard"}], true)
	var frag_attack := C.AttackPlan.prepare(state, bunker_squad, false, [{"model": bunker_model, "target": enemy_squad, "amount": 1, "weapon": "hammerfall-missile-launcher", "profile": "superfrag"}], true)
	var krak_attack := C.AttackPlan.prepare(state, bunker_squad, false, [{"model": bunker_model, "target": enemy_squad, "amount": 1, "weapon": "hammerfall-missile-launcher", "profile": "superkrak"}], true)
	check(bolter_attack.get("error", "").is_empty() and bolter_attack.get("batches", []).size() == 1 and bolter_attack.batches[0].weapon.name == "Hammerfall Heavy Bolter Array", "Heavy Bolter Array resolves through the standard AttackPlan")
	check(frag_attack.get("error", "").is_empty() and frag_attack.get("batches", []).size() == 1 and frag_attack.batches[0].weapon.attacks == 9 and frag_attack.batches[0].context.attack_sources[0].bonus == 2, "Superfrag resolves through AttackPlan with Blast 1 and two bonus attacks against ten models: " + str(frag_attack))
	check(krak_attack.get("error", "").is_empty() and krak_attack.batches[0].weapon.damage == "D3+3" and krak_attack.batches[0].weapon.strength == 10, "Superkrak resolves through AttackPlan with its source Damage and Strength")
	check(C.UnitAbilities.deadly_demise_value(state, bunker_model) == "D6", "Hammerfall registers Deadly Demise D6")
	state.units[bunker_model].wounds = 6
	check(C.UnitAbilities.damaged_attack_penalty(state, bunker_model) == 0, "Damaged 5 does not apply at six wounds")
	state.units[bunker_model].wounds = 5
	check(C.UnitAbilities.damaged_attack_penalty(state, bunker_model) == -1, "Damaged 5 applies through the shared attack path at five wounds")

func test_fortification_and_cover(state: Dictionary, bunker_model: int, bunker_squad: int, friendly_squad: int, target_squad: int) -> void:
	state.units[bunker_model].wounds = 14
	var bunker_radius := float(state.units[bunker_model].get("radius", 0.0))
	var target_models := C.living(state, target_squad)
	for index: int in target_models.size(): state.units[target_models[index]].position = Vector2(3.2, float(index) * 3.0)
	state.units[bunker_model].position = Vector2.ZERO
	var only_fort_engagement := Fortifications.target_engaged_only_with_hammerfall_fortifications(state, target_squad, 1)
	check(bunker_radius > 2.3 and only_fort_engagement, "The enemy target is in Engagement Range of the Hammerfall and only FORTIFICATION units (radius=%f, bunker=%s, target=%s)" % [bunker_radius, str(state.units[bunker_model].get("keywords", [])), str(state.units[target_models[0]].get("position", Vector2.ZERO))])
	state.phase = "shooting"
	state.active = 1
	state.unit_abilities.window = {}
	var fortification_attack := C.AttackPlan.prepare(state, bunker_squad, false, [{"model": bunker_model, "target": target_squad, "amount": 1, "weapon": "hammerfall-heavy-bolter-array", "profile": "standard"}], true)
	check(fortification_attack.get("error", "").is_empty() and fortification_attack.get("batches", []).size() == 1 and int(fortification_attack.get("batches", [{}])[0].get("context", {}).get("hit_modifier", 0)) == -1, "Fortification makes its engaged enemy a legal ranged target and applies -1 to Hit: " + str(fortification_attack))
	if not fortification_attack.get("batches", []).is_empty():
		var heavy_bolter: Dictionary = {}
		for weapon: Dictionary in state.units[bunker_model].ranged_weapons:
			if str(weapon.get("id", "")) == "hammerfall-heavy-bolter-array": heavy_bolter = weapon
		check(not heavy_bolter.is_empty(), "The synthetic Close-quarters modifier is applied to the Hammerfall Heavy Bolter Array fixture")
		if not heavy_bolter.is_empty(): heavy_bolter.profiles.standard.keywords["close-quarters"] = true
		var close_attack := C.AttackPlan.prepare(state, bunker_squad, false, [{"model": bunker_model, "target": target_squad, "amount": 1, "weapon": "hammerfall-heavy-bolter-array", "profile": "standard"}], true)
		check(close_attack.get("error", "").is_empty() and int(close_attack.get("batches", [{}])[0].get("context", {}).get("hit_modifier", -99)) == 0, "A CLOSE-QUARTERS ranged attack ignores the Fortification -1 Hit modifier: " + str(close_attack))
		if not heavy_bolter.is_empty(): heavy_bolter.profiles.standard.keywords.erase("close-quarters")
	var extra_friendly := C.living(state, friendly_squad)[1]
	state.units[extra_friendly].position = Vector2(4.5, 8.0)
	check(not Fortifications.target_engaged_only_with_hammerfall_fortifications(state, target_squad, 1), "A non-Fortification enemy engagement disables the Fortification target exception")
	state.units[extra_friendly].position = Vector2(30.0, 0.0)

	# Put the Hammerfall between an enemy shooter and a friendly target to verify Ceramite Cover.
	var enemy_attacker := C.living(state, squads_for(state, 2, "intercessor-squad", 10)[0])[0]
	state.units[enemy_attacker].position = Vector2(-8.0, 0.0)
	state.units[bunker_model].position = Vector2.ZERO
	for index: int in target_models.size(): state.units[target_models[index]].position = Vector2(6.0, 3.0 + float(index) * 2.0)
	state.units[target_models[0]].position = Vector2(6.0, 0.0)
	check(Fortifications.ceramite_cover(state, enemy_attacker, target_squad) and C.Terrain.benefit_of_cover(state, enemy_attacker, target_squad), "Ceramite Cover grants cover when the Hammerfall proxy obstructs the attacker's view of the target")

func test_fall_back_and_overwatch(state: Dictionary, bunker_model: int, bunker_squad: int, enemy_squad: int) -> void:
	state.units[bunker_model].position = Vector2.ZERO
	var enemy_model := C.living(state, enemy_squad)[0]
	for index: int in C.living(state, enemy_squad).size(): state.units[C.living(state, enemy_squad)[index]].position = Vector2(3.2, float(index) * 3.0)
	state.squads[enemy_squad].battle_shocked = false
	check(Fortifications.fall_back_hazard_auto_pass(state, enemy_squad), "Non-Battle-shocked enemy engaged only with a Hammerfall automatically passes Fall Back hazards")
	state.squads[enemy_squad].battle_shocked = true
	check(not Fortifications.fall_back_hazard_auto_pass(state, enemy_squad), "Battle-shocked enemies do not receive the automatic Hazard pass")
	state.squads[enemy_squad].battle_shocked = false
	state.phase = "movement"
	state.active = 2
	dice_calls = 0
	var fallback_error := C.begin_movement(state, 2, enemy_model, "desperate_escape", int(state.get("revision", -1)), Callable(self, "fixed_die"))
	check(fallback_error.is_empty() and bool(state.pending_move.get("fortification_hazard_auto_pass", false)) and state.pending_move.get("hazard_rolls", []).is_empty() and int(state.pending_move.get("hazard_remaining", -1)) == 0 and dice_calls == 0, "A legal Fall Back auto-passes without rolling or assigning mortal wounds: " + fallback_error + " / " + str(state.get("pending_move", {})))
	check(not state.get("events", []).is_empty() and str(state.events.back()).contains("automatically pass"), "The log explains that the Fortification ability auto-passed the Hazard rolls")

	state.phase = "movement"
	state.active = 2
	state.cp = {1: 3, 2: 3}
	state.unit_abilities.window = {"kind": "end", "owners": [1]}
	state.core_reactions.overwatch = {}
	for index: int in C.living(state, enemy_squad).size(): state.units[C.living(state, enemy_squad)[index]].position = Vector2(8.0, 10.0 + float(index) * 1.2)
	check(C.CoreReactions.cost_of(state, 1, bunker_squad, C.CoreReactions.OVERWATCH) == 0 and C.CoreReactions.cost_of(state, 1, int(state.units[model_for(state, 1, "intercessor-squad")].squad), C.CoreReactions.OVERWATCH) == 1, "Defensive Array makes only the Hammerfall's Overwatch use free")
	var choices: Array = C.CoreReactions.choices(state, 1).filter(func(option: Dictionary) -> bool: return int(option.get("target", -1)) == bunker_squad and str(option.get("value", "")) == C.CoreReactions.OVERWATCH)
	check(not choices.is_empty() and str(choices[0].get("label", "")).contains("0 CP"), "The Fire Overwatch choice displays zero CP for Defensive Array")
	state.stratagems.uses.append({"player": 1, "squad": int(state.units[model_for(state, 1, "intercessor-squad")].squad), "stratagem": C.CoreReactions.OVERWATCH, "phase_key": C.CoreReactions.phase_key(state), "turn": state.turn})
	check(C.CoreReactions.error(state, 1, bunker_squad, C.CoreReactions.OVERWATCH).is_empty(), "Defensive Array permits Overwatch after another friendly unit has used it")
	var free_use := C.CoreReactions.apply(state, 1, {"value": C.CoreReactions.OVERWATCH, "target": bunker_squad, "model": -1})
	check(free_use.get("error", "").is_empty() and state.cp.get(1, -1) == 3, "Defensive Array's additional Overwatch spends no CP: " + str(free_use) + " / CP " + str(state.cp))
	check(not C.CoreReactions.error(state, 1, bunker_squad, C.CoreReactions.OVERWATCH).is_empty(), "Defensive Array remains limited to once per phase on the Hammerfall itself")
	var ordinary_squad := int(state.units[model_for(state, 1, "intercessor-squad")].squad)
	check(not C.CoreReactions.error(state, 1, ordinary_squad, C.CoreReactions.OVERWATCH).is_empty(), "A prior Hammerfall use does not grant another normal Overwatch use")

func test_deadly_demise(state: Dictionary, bunker_model: int, enemy_squad: int) -> void:
	var demise := state.duplicate(true)
	for model: int in demise.units: demise.units[model].position = Vector2(-20.0, -20.0)
	demise.units[bunker_model].position = Vector2.ZERO
	var enemy_models := C.living(demise, enemy_squad)
	for index: int in enemy_models.size(): demise.units[enemy_models[index]].position = Vector2(5.0, float(index) * 2.0)
	demise.units[bunker_model].wounds = 0
	var explosion := C.DeadlyDemise.begin(demise, [bunker_model], func() -> int: return 6)
	var pending: Dictionary = demise.get("pending_deadly_demise", {})
	var events: Array = pending.get("events", [])
	var event: Dictionary = events[0] if not events.is_empty() else {}
	var packets: Array = pending.get("packets", [])
	var packet: Dictionary = packets[0] if not packets.is_empty() else {}
	check(explosion.get("error", "").is_empty() and not explosion.get("complete", true) and event.get("expression", "") == "D6" and event.get("triggered", false) and packets.size() == 1 and packet.get("roll", {}).get("expression", "") == "D6" and int(packet.get("remaining", 0)) == 6, "A destroyed Hammerfall opens its source D6 Deadly Demise packet through the shared resolver: " + str(explosion) + " / " + str(packets))

func run() -> void:
	test_source_and_admission()
	var state := battle()
	if state.has("error"):
		check(false, "Hammerfall and Intercessors build in a battle: " + str(state.error))
		quit(1)
		return
	var bunker_model := model_for(state, 1, SOURCE_ID)
	var bunker_squad := int(state.units[bunker_model].get("squad", -1)) if bunker_model >= 0 else -1
	var friendly_squads := squads_for(state, 1, "intercessor-squad", 5)
	var target_squads := squads_for(state, 2, "intercessor-squad", 5)
	var enemy_ten := squads_for(state, 2, "intercessor-squad", 10)
	check(bunker_model >= 0 and bunker_squad >= 0 and not friendly_squads.is_empty() and not target_squads.is_empty() and not enemy_ten.is_empty(), "The materialized roster includes the Hammerfall and the needed 5/10-model Intercessors")
	if bunker_model < 0 or bunker_squad < 0 or friendly_squads.is_empty() or target_squads.is_empty() or enemy_ten.is_empty():
		quit(1)
		return
	check(C.UnitAbilities.has(state, bunker_squad, "combat-doctrines") and C.UnitAbilities.has(state, bunker_squad, "defensive-array") and C.UnitAbilities.has(state, bunker_squad, "fortification"), "The Hammerfall's faction and datasheet abilities are live in battle state")
	test_weapon_loadout_and_damage(state, bunker_model, bunker_squad, enemy_ten[0])
	test_fortification_and_cover(state, bunker_model, bunker_squad, friendly_squads[0], target_squads[0])
	test_deadly_demise(state, bunker_model, target_squads[0])
	state = battle()
	bunker_model = model_for(state, 1, SOURCE_ID)
	bunker_squad = int(state.units[bunker_model].get("squad", -1)) if bunker_model >= 0 else -1
	test_fall_back_and_overwatch(state, bunker_model, bunker_squad, squads_for(state, 2, "intercessor-squad", 5)[0])
	print("Hammerfall Bunker source-bounded local checks: %d failures" % failures)
	quit(1 if failures else 0)
