extends SceneTree

const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Army = preload("res://scripts/edition_11/army_capabilities.gd")
const AbilityCatalog = preload("res://scripts/edition_11/unit_ability_catalog.gd")
const Registry = preload("res://scripts/edition_11/capabilities.gd")
const LeaderLinks = preload("res://scripts/edition_11/marine_leader_links.gd")
const UnitActions = preload("res://scripts/edition_11/unit_actions.gd")
const CombatDoctrines = preload("res://scripts/edition_11/combat_doctrines.gd")

var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func entry(identity: String, models: int = 1, copies: int = 1) -> Dictionary:
	return {"definition_id": "40kdc:11e:adeptus-astartes:" + identity, "models": models, "copies": copies}

func selections(include_blood_claws: bool = true) -> Dictionary:
	var result := F.current_marine_selections()
	for owner: int in [1, 2]:
		result[owner].category = "custom"
		result[owner].points_limit = 2000
	result[1].entries = [entry("ragnar-blackmane")]
	if include_blood_claws: result[1].entries.append(entry("blood-claws", 10))
	result[1].entries.append(entry("intercessor-squad", 5))
	result[2].entries = [entry("captain"), entry("intercessor-squad", 5)]
	return result

func fresh_state(include_blood_claws: bool = true) -> Dictionary:
	return F.P.initial_state({"checked_rosters": false, "official_mission": false, "unit_abilities": true,
		"combat_doctrines": true, "core_stratagems": true, "marine_chapters": {1: "SPACE WOLVES", 2: "ULTRAMARINES"}}, selections(include_blood_claws))

func model_for(state: Dictionary, owner: int, identity: String) -> int:
	for model: int in state.units:
		var unit: Dictionary = state.units[model]
		if int(unit.get("owner", -1)) == owner and C.UnitAbilities.identity(unit) == identity: return model
	return -1

func models_for(state: Dictionary, owner: int, identity: String) -> Array[int]:
	var result: Array[int] = []
	for model: int in state.units:
		var unit: Dictionary = state.units[model]
		if int(unit.get("owner", -1)) == owner and C.UnitAbilities.identity(unit) == identity: result.append(model)
	return result

func squad_for(state: Dictionary, owner: int, identity: String) -> int:
	var model := model_for(state, owner, identity)
	return int(state.units.get(model, {}).get("squad", -1))

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var profile := Profiles.profile("ragnar-blackmane")
	check(profile.get("source_book_id", "") == "000000036" and profile.get("source_datasheet_id", "") == "000000285" and profile.get("source_snapshot_id", "") == "20261029T003124Z" and profile.get("source_slice_manifest_sha256", "") == "5286C01DE5055F9D64992C43612387119BAA3F0F48851F284250A079626B18C2", "Ragnar is bound to the Space Wolves App and verified subject slice")
	check(profile.get("points_by_models", {}) == {1: 100} and profile.get("models", -1) == 1 and profile.get("max_supported_copies", -1) == 1 and profile.get("base_size_source_mm", -1) == 40, "Ragnar retains his one-model, 100-point profile, one-copy limit and 40 mm base")
	check(profile.get("stats", {}) == {"movement_inches": 7, "toughness": 5, "save_target": 3, "wounds": 5, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 4}, "Ragnar's characteristics match the current export")
	var expected_keywords := ["ADEPTUS ASTARTES", "CAPTAIN", "CHARACTER", "EPIC HERO", "EXPLOSIVES", "IMPERIUM", "INFANTRY", "SPACE WOLVES", "TACTICUS"]
	var actual_keywords: Array = profile.get("keywords", []).duplicate()
	actual_keywords.sort()
	check(actual_keywords == expected_keywords, "All source-listed Ragnar keywords are retained")
	var pistol: Dictionary = profile.get("ranged", [{}])[0].get("profiles", {}).get("standard", {})
	var frostfang: Dictionary = profile.get("melee", [{}])[0].get("profiles", {}).get("standard", {})
	check(pistol.get("range_inches") == 12.0 and pistol.get("attacks") == 1 and pistol.get("skill") == 2 and pistol.get("strength") == 5 and pistol.get("ap") == -1 and pistol.get("damage") == 1, "Bolt Pistol profile matches the export")
	check(frostfang.get("attacks") == 8 and frostfang.get("skill") == 2 and frostfang.get("strength") == 6 and frostfang.get("ap") == -3 and frostfang.get("damage") == 2 and frostfang.get("keywords", {}) == {"sustained-hits": 1}, "Frostfang retains its exported profile and Sustained Hits 1")
	check(Army.SPECS.has("ragnar-blackmane") and Army.SPECS["ragnar-blackmane"].get("current_reference", false), "Ragnar is registered for current-reference construction")
	check(AbilityCatalog.RULES.get("ragnar-blackmane", []) == ["leader", "combat-doctrines", "transhuman-strategist", "battle-lust", "war-howl"], "Leader, Combat Doctrines, Transhuman Strategist and both datasheet abilities are registered")
	check(Registry.supported("battle-lust") and Registry.supported("war-howl"), "Both Ragnar datasheet abilities are exposed as supported capabilities")
	var targets := LeaderLinks.targets("ragnar-blackmane")
	check(targets == ["wolf-guard-headtakers", "blood-claws"] and not Army.SPECS.has("wolf-guard-headtakers"), "Both source Leader endpoints are recorded while Headtakers remains unavailable for construction")
	var admitted := Army.admit({"schema_version": 2, "faction": "Space Marines", "category": "custom", "points_limit": 1000, "entries": [entry("ragnar-blackmane")]})
	var duplicate := Army.admit({"schema_version": 2, "faction": "Space Marines", "category": "custom", "points_limit": 1000, "entries": [entry("ragnar-blackmane", 1, 2)]})
	check(admitted.get("error", "").is_empty() and admitted.get("total", -1) == 100 and not str(duplicate.get("error", "")).is_empty(), "Construction admits Ragnar at source cost and enforces his Epic Hero limit")

	var state := fresh_state()
	check(not state.has("error"), "Ragnar and both available bodyguard profiles materialize from the local catalog: %s" % state.get("error", ""))
	if not state.has("error"):
		var ragnar := model_for(state, 1, "ragnar-blackmane")
		var squad := int(state.units.get(ragnar, {}).get("squad", -1))
		var enemy := squad_for(state, 2, "intercessor-squad")
		var warlord_choice := UnitActions.choices(state, 1).any(func(option: Dictionary) -> bool: return str(option.get("action", "")) == "warlord" and int(option.get("model", -1)) == ragnar)
		check(warlord_choice, "Ragnar is eligible to be Warlord for Transhuman Strategist")
		var original_frostfang: Dictionary = state.units[ragnar].melee_weapons[0].profiles.standard
		check(C.UnitAbilities.melee_attack_count(state, ragnar, original_frostfang) == 8, "Battle-lust does not apply before Ragnar's unit charges")
		state.squads[squad].charged = true
		var charged_frostfang: Dictionary = C.UnitAbilities.weapon(state, ragnar, enemy, original_frostfang, true)
		check(charged_frostfang.attacks == 10 and C.UnitAbilities.melee_attack_count(state, ragnar, original_frostfang) == 10, "Battle-lust adds two attacks to Ragnar alone after a Charge move")
		state.squads[squad].charged = false
		var blood_claws := models_for(state, 1, "blood-claws")
		for model: int in blood_claws: state.units[model].squad = squad
		var blood_claw_weapon: Dictionary = Profiles.profile("blood-claws").melee[0].profiles.standard
		var howled_frostfang: Dictionary = C.UnitAbilities.weapon(state, ragnar, enemy, original_frostfang, true)
		var howled_chainsword: Dictionary = C.UnitAbilities.weapon(state, blood_claws[0], enemy, blood_claw_weapon, true)
		check(howled_frostfang.strength == 7 and howled_frostfang.keywords.get("sustained-hits", 0) == 1, "War Howl grants +1 Strength and Sustained Hits 1 to Ragnar while leading Blood Claws")
		check(howled_chainsword.strength == 6 and howled_chainsword.keywords.get("sustained-hits", 0) == 1, "War Howl also grants its melee bonuses to Blood Claw bodyguards")
		check(C.UnitAbilities.melee_attack_count(state, blood_claws[0], blood_claw_weapon) == 4, "Battle-lust does not grant Ragnar's extra attacks to the attached unit")

	var headtaker_state := fresh_state(false)
	check(not headtaker_state.has("error"), "Headtaker attachment boundary fixture starts from admitted profiles")
	if not headtaker_state.has("error"):
		var ragnar := model_for(headtaker_state, 1, "ragnar-blackmane")
		var bodyguard_squad := squad_for(headtaker_state, 1, "intercessor-squad")
		headtaker_state.units[ragnar].squad = bodyguard_squad
		for model: int in models_for(headtaker_state, 1, "intercessor-squad"):
			headtaker_state.units[model].definition_id = "40kdc:11e:adeptus-astartes:wolf-guard-headtakers"
		headtaker_state.squads[bodyguard_squad].advanced = true
		check(CombatDoctrines.charge_error(headtaker_state, bodyguard_squad).is_empty(), "War Howl preserves Charge eligibility after an Advance when Ragnar leads the source-listed Headtakers target")
		for model: int in models_for(headtaker_state, 1, "wolf-guard-headtakers"):
			headtaker_state.units[model].definition_id = "40kdc:11e:adeptus-astartes:intercessor-squad"
		check(not CombatDoctrines.charge_error(headtaker_state, bodyguard_squad).is_empty(), "War Howl's Advance/Charge exception is limited to Wolf Guard Headtakers")

	print("Ragnar Blackmane checks: %d failures" % failures)
	quit(0 if failures == 0 else 1)
