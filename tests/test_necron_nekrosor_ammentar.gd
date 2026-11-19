extends SceneTree

const F = preload("res://tests/all_units_fixture.gd")
const Profiles = preload("res://scripts/edition_11/current_reference_necron_profiles.gd")
const Army = preload("res://scripts/edition_11/army_capabilities.gd")
const Reanimation = preload("res://scripts/edition_11/reanimation_protocols.gd")
const UnitAbilities = preload("res://scripts/edition_11/unit_abilities.gd")
const UnitActions = preload("res://scripts/edition_11/unit_actions.gd")
const UnitPrevention = preload("res://scripts/edition_11/unit_prevention.gd")
const AttackPlan = preload("res://scripts/edition_11/attack_plan.gd")
const NekrosorAmmentar = preload("res://scripts/edition_11/nekrosor_ammentar.gd")

const AMMENTAR_ID := "40kdc:11e:necrons:nekrosor-ammentar"
const SKORPEKH_ID := "40kdc:11e:necrons:skorpekh-destroyers"
const WARRIORS_ID := "40kdc:11e:necrons:necron-warriors"
const NIGHTBRINGER_ID := "40kdc:11e:necrons:ctan-shard-of-the-nightbringer"
const MARINE_ID := "40kdc:11e:adeptus-astartes:intercessor-squad"

var failures := 0

func _initialize() -> void:
	call_deferred("run")

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func run() -> void:
	test_datasheet_facts_and_admission()
	test_protective_disciples_lone_operative()
	test_infectious_murder_madness()
	test_prophet_of_destruction()
	test_nullstone_field_generator()
	print("Necron Nekrosor Ammentar checks: %d failures" % failures)
	await process_frame
	quit(1 if failures else 0)

func test_datasheet_facts_and_admission() -> void:
	var ammentar := Profiles.profile("nekrosor-ammentar")
	check(ammentar.get("source_datasheet_id") == "000004186", "Nekrosor Ammentar ID matches 000004186")
	check(ammentar.get("points_by_models") == {1: 195}, "Nekrosor Ammentar points are 195 for 1 model")
	check(ammentar.get("base_size_source_mm") == 80, "Nekrosor Ammentar base is 80 mm")
	check(ammentar.get("stats") == {"movement_inches": 10, "toughness": 8, "save_target": 3, "wounds": 9, "leadership_target": 6, "objective_control": 3, "invulnerable_target": 4}, "Nekrosor Ammentar stats match source")
	for kw: String in ["NECRONS", "INFANTRY", "CHARACTER", "EPIC HERO", "DESTROYER CULT", "NEKROSOR AMMENTAR"]:
		check(kw in ammentar.get("keywords", []), "Nekrosor Ammentar has %s keyword" % kw)
	check(ammentar.get("max_supported_copies") == 1, "Nekrosor Ammentar has max_supported_copies == 1")

	var ranged: Array = ammentar.get("ranged", [])
	check(ranged.size() == 1, "Nekrosor Ammentar has 1 ranged weapon")
	var enmitic: Dictionary = ranged[0].get("profiles", {}).get("standard", {})
	check(enmitic == {"name": "Enmitic disintegrators", "range_inches": 18.0, "attacks": 4, "skill": 2, "strength": 6, "ap": -2, "damage": 1, "keywords": {"close-quarters": true, "ignores-cover": true, "sustained-hits": 2}}, "Enmitic disintegrators matches source")

	var melee: Array = ammentar.get("melee", [])
	check(melee.size() == 2, "Nekrosor Ammentar has 2 melee weapons")
	check(melee[0].get("profiles", {}).get("standard", {}) == {"name": "Unmaker Gauntlet", "range_inches": 0.0, "attacks": 6, "skill": 2, "strength": 10, "ap": -3, "damage": 3, "keywords": {}}, "Unmaker Gauntlet matches source")
	check(melee[1].get("profiles", {}).get("standard", {}) == {"name": "Blade tail and whip coils", "range_inches": 0.0, "attacks": 6, "skill": 2, "strength": 6, "ap": -1, "damage": 1, "keywords": {"extra-attacks": true}}, "Blade tail and whip coils matches source")

	check(ammentar.get("unsupported_abilities", []).is_empty(), "Unsupported abilities cleared")
	check(ammentar.get("pending_source_checks", []).is_empty(), "Pending source checks empty")

	var res := Army.resolve("Necrons", AMMENTAR_ID)
	check(res.get("error", "").is_empty(), "Nekrosor Ammentar resolves cleanly")
	check(int(res.get("cost", -1)) == 195 and int(res.get("models", -1)) == 1, "Cost is 195, models is 1")
	check(Reanimation.CHARACTER_WOUNDS.get(AMMENTAR_ID) == 9, "Reanimation character wounds is 9")
	check(Reanimation.PROFILE_MODEL_COUNTS.get(AMMENTAR_ID) == [1], "Reanimation profile model count is [1]")

func test_protective_disciples_lone_operative() -> void:
	var state: Dictionary = F.P.initial_state({"unit_abilities": true, "reanimation_protocols": true, "combat_doctrines": false, "core_stratagems": true, "manual_allocation": false}, {
		1: {"schema_version": 2, "faction": "Necrons", "category": "custom", "points_limit": 1000, "entries": [
			{"definition_id": AMMENTAR_ID, "models": 1, "copies": 1},
			{"definition_id": SKORPEKH_ID, "models": 3, "copies": 1},
			{"definition_id": WARRIORS_ID, "models": 10, "copies": 1}
		]},
		2: {"schema_version": 2, "faction": "Space Marines", "category": "custom", "points_limit": 1000, "entries": [
			{"definition_id": MARINE_ID, "models": 5, "copies": 1}
		]}
	})
	if state.has("error"): return

	var ammentar_model := -1
	var skorpekh_squad := -1
	var warriors_squad := -1
	for m: int in state.units:
		var d := str(state.units[m].get("definition_id", ""))
		if d == AMMENTAR_ID: ammentar_model = m
		elif d == SKORPEKH_ID and skorpekh_squad < 0: skorpekh_squad = int(state.units[m].get("squad", -1))
		elif d == WARRIORS_ID and warriors_squad < 0: warriors_squad = int(state.units[m].get("squad", -1))

	state.units[ammentar_model].position = Vector2(0.0, 0.0)
	for m: int in state.units:
		var sq := int(state.units[m].get("squad", -1))
		if sq == skorpekh_squad: state.units[m].position = Vector2(0.0, 30.0)
		elif sq == warriors_squad: state.units[m].position = Vector2(0.0, 3.5)

	check(not UnitAbilities.lone_operative_active(state, ammentar_model), "Non-Destroyer Cult Warriors within 3 inches do not grant Lone Operative")

	for m: int in state.units:
		if int(state.units[m].get("squad", -1)) == skorpekh_squad:
			state.units[m].position = Vector2(0.0, 4.0)
	check(UnitAbilities.lone_operative_active(state, ammentar_model), "Destroyer Cult unit within 3 inches grants Lone Operative")
	check(UnitAbilities.lone_operative_range(state, ammentar_model) == 12.0, "Lone Operative range is 12.0")

func test_infectious_murder_madness() -> void:
	var state: Dictionary = F.P.initial_state({"unit_abilities": true, "reanimation_protocols": true, "combat_doctrines": false, "core_stratagems": true, "manual_allocation": false}, {
		1: {"schema_version": 2, "faction": "Necrons", "category": "custom", "points_limit": 1000, "entries": [
			{"definition_id": AMMENTAR_ID, "models": 1, "copies": 1},
			{"definition_id": SKORPEKH_ID, "models": 3, "copies": 1},
			{"definition_id": WARRIORS_ID, "models": 10, "copies": 1},
			{"definition_id": NIGHTBRINGER_ID, "models": 1, "copies": 1}
		]},
		2: {"schema_version": 2, "faction": "Space Marines", "category": "custom", "points_limit": 1000, "entries": [
			{"definition_id": MARINE_ID, "models": 5, "copies": 2}
		]}
	})
	if state.has("error"): return

	var ammentar_model := -1
	var ammentar_squad := -1
	var skorpekh_squad := -1
	var skorpekh_model := -1
	var warriors_squad := -1
	var warrior_model := -1
	var ctan_squad := -1
	var ctan_model := -1
	var close_enemy := -1
	var far_enemy := -1
	for m: int in state.units:
		var u: Dictionary = state.units[m]
		var d := str(u.get("definition_id", ""))
		var sq := int(u.get("squad", -1))
		if d == AMMENTAR_ID:
			ammentar_model = m
			ammentar_squad = sq
		elif d == SKORPEKH_ID:
			if skorpekh_squad < 0: skorpekh_squad = sq
			if skorpekh_model < 0: skorpekh_model = m
		elif d == WARRIORS_ID:
			if warriors_squad < 0: warriors_squad = sq
			if warrior_model < 0: warrior_model = m
		elif d == NIGHTBRINGER_ID:
			ctan_squad = sq
			ctan_model = m
		elif d == MARINE_ID:
			if close_enemy < 0: close_enemy = sq
			elif sq != close_enemy and far_enemy < 0: far_enemy = sq

	state.units[ammentar_model].position = Vector2(0.0, 0.0)
	for m: int in state.units:
		var sq := int(state.units[m].get("squad", -1))
		if sq == warriors_squad: state.units[m].position = Vector2(0.0, 4.0)
		elif sq == skorpekh_squad: state.units[m].position = Vector2(4.0, 0.0)
		elif sq == ctan_squad: state.units[m].position = Vector2(-4.0, 0.0)
		elif sq == close_enemy: state.units[m].position = Vector2(0.0, 12.0)
		elif sq == far_enemy: state.units[m].position = Vector2(0.0, 20.0)

	# 1. Warriors (non-Destroyer Cult) within 6": Sustained Hits 1 ONLY against closest eligible target
	var warrior_weapon_id := str(state.units[warrior_model].get("ranged_weapons", [{}])[0].get("id", "primary"))
	var plan_close := AttackPlan.prepare(state, warriors_squad, false, [{"model": warrior_model, "target": close_enemy, "amount": 1, "weapon": warrior_weapon_id, "profile": "standard"}], false)
	check(plan_close.get("error", "").is_empty() and int(plan_close.batches[0].weapon.keywords.get("sustained-hits", 0)) == 1, "Warriors in aura gain Sustained Hits 1 against closest eligible target")
	var plan_far := AttackPlan.prepare(state, warriors_squad, false, [{"model": warrior_model, "target": far_enemy, "amount": 1, "weapon": warrior_weapon_id, "profile": "standard"}], false)
	check(plan_far.get("error", "").is_empty() and int(plan_far.batches[0].weapon.keywords.get("sustained-hits", 0)) == 0, "Warriors in aura do NOT gain Sustained Hits against non-closest target")

	# 2. Destroyer Cult (Skorpekh Destroyers) within 6": melee gets Sustained Hits 1 even if not closest
	for m: int in state.units:
		if int(state.units[m].get("squad", -1)) == far_enemy:
			state.units[m].position = Vector2(6.2, 0.0) # in engagement range of Skorpekh at (4.0, 0.0)
		elif int(state.units[m].get("squad", -1)) == skorpekh_squad and m != skorpekh_model:
			state.units[m].wounds = 0 # single active fighter for melee batch check
	var skorpekh_weapon_id := str(state.units[skorpekh_model].get("melee_weapons", [{}])[0].get("id", "primary"))
	var skorpekh_attacks := int(state.units[skorpekh_model].get("melee_weapons", [{}])[0].get("profiles", {}).get("standard", {}).get("attacks", 4))
	var plan_skorpekh := AttackPlan.prepare(state, skorpekh_squad, true, [{"model": skorpekh_model, "target": far_enemy, "amount": skorpekh_attacks, "weapon": skorpekh_weapon_id, "profile": "standard"}], false)
	check(plan_skorpekh.get("error", "").is_empty() and int(plan_skorpekh.batches[0].weapon.keywords.get("sustained-hits", 0)) == 1, "Destroyer Cult unit in aura gains Sustained Hits 1: " + str(plan_skorpekh.get("error", "")))

	# 3. Monster (Nightbringer) within 6" is excluded
	check(not NekrosorAmmentar.infectious_murder_madness_in_aura(state, ctan_squad), "Monster unit is excluded from Infectious Murder-madness")
	var ctan_weapon_id := str(state.units[ctan_model].get("ranged_weapons", [{}])[0].get("id", "primary"))
	var plan_ctan := AttackPlan.prepare(state, ctan_squad, false, [{"model": ctan_model, "target": close_enemy, "amount": 1, "weapon": ctan_weapon_id, "profile": "standard"}], false)
	check(plan_ctan.get("error", "").is_empty() and int(plan_ctan.batches[0].weapon.keywords.get("sustained-hits", 0)) == 0, "Monster unit does not gain Sustained Hits from aura")

	# 4. Ammentar's own Enmitic disintegrators keeps Sustained Hits 2
	var ammentar_weapon_id := str(state.units[ammentar_model].get("ranged_weapons", [{}])[0].get("id", "primary"))
	var plan_ammentar := AttackPlan.prepare(state, ammentar_squad, false, [{"model": ammentar_model, "target": close_enemy, "amount": 1, "weapon": ammentar_weapon_id, "profile": "standard"}], false)
	check(plan_ammentar.get("error", "").is_empty() and int(plan_ammentar.batches[0].weapon.keywords.get("sustained-hits", 0)) == 2, "Ammentar's Enmitic disintegrators preserves Sustained Hits 2: " + str(plan_ammentar.get("error", "")))

func test_prophet_of_destruction() -> void:
	var state: Dictionary = F.P.initial_state({"unit_abilities": true, "reanimation_protocols": true, "combat_doctrines": false, "core_stratagems": true, "manual_allocation": false}, {
		1: {"schema_version": 2, "faction": "Necrons", "category": "custom", "points_limit": 1000, "entries": [
			{"definition_id": AMMENTAR_ID, "models": 1, "copies": 1},
			{"definition_id": SKORPEKH_ID, "models": 3, "copies": 1},
			{"definition_id": WARRIORS_ID, "models": 10, "copies": 1}
		]},
		2: {"schema_version": 2, "faction": "Space Marines", "category": "custom", "points_limit": 1000, "entries": [
			{"definition_id": MARINE_ID, "models": 5, "copies": 1}
		]}
	})
	if state.has("error"): return

	var ammentar_model := -1
	var ammentar_squad := -1
	var skorpekh_squad := -1
	var skorpekh_model := -1
	var warriors_squad := -1
	var marine_squad := -1
	for m: int in state.units:
		var d := str(state.units[m].get("definition_id", ""))
		var sq := int(state.units[m].get("squad", -1))
		if d == AMMENTAR_ID: ammentar_model = m; ammentar_squad = sq
		elif d == SKORPEKH_ID:
			if skorpekh_squad < 0: skorpekh_squad = sq
			if skorpekh_model < 0: skorpekh_model = m
		elif d == WARRIORS_ID and warriors_squad < 0: warriors_squad = sq
		elif d == MARINE_ID and marine_squad < 0: marine_squad = sq

	state.phase = "fight"
	state.turn = 1
	state.active = 1
	state.units[ammentar_model].position = Vector2(0.0, 0.0)
	for m: int in state.units:
		var sq := int(state.units[m].get("squad", -1))
		if sq == skorpekh_squad: state.units[m].position = Vector2(0.0, 6.0)
		elif sq == warriors_squad: state.units[m].position = Vector2(6.0, 0.0)
		elif sq == marine_squad:
			state.units[m].position = Vector2(0.0, 2.0)
			state.units[m].wounds = 0 # enemy destroyed

	var opened := NekrosorAmmentar.open_prophet_of_destruction(state, ammentar_squad, [marine_squad], 5)
	check(opened, "Prophet of Destruction window opens when Ammentar destroys an enemy unit")

	var choices := UnitActions.choices(state, 1)
	var select_opts := choices.filter(func(c: Dictionary) -> bool: return c.get("action", "") == NekrosorAmmentar.PROPHET_SELECT)
	check(select_opts.size() == 1 and int(select_opts[0].get("target", -1)) == skorpekh_squad, "Only friendly Destroyer Cult unit within 9 inches is offered")

	var apply_res := UnitActions.apply(state, 1, select_opts[0], Vector2.ZERO, Callable())
	check(str(apply_res.get("error", "")).is_empty(), "Prophet of Destruction selection applies cleanly")
	check(NekrosorAmmentar.prophet_wound_reroll_active(state, skorpekh_squad), "Skorpekh Destroyers gain Prophet of Destruction Wound reroll 1s")

	# Expires when phase changes
	state.phase = "shooting"
	check(not NekrosorAmmentar.prophet_wound_reroll_active(state, skorpekh_squad), "Prophet of Destruction expires at end of phase")

func test_nullstone_field_generator() -> void:
	var state: Dictionary = F.P.initial_state({"unit_abilities": true, "reanimation_protocols": true, "combat_doctrines": false, "core_stratagems": true, "manual_allocation": false}, {
		1: {"schema_version": 2, "faction": "Necrons", "category": "custom", "points_limit": 1000, "entries": [
			{"definition_id": AMMENTAR_ID, "models": 1, "copies": 1},
			{"definition_id": WARRIORS_ID, "models": 10, "copies": 1}
		]},
		2: {"schema_version": 2, "faction": "Space Marines", "category": "custom", "points_limit": 1000, "entries": [
			{"definition_id": MARINE_ID, "models": 5, "copies": 1}
		]}
	})
	if state.has("error"): return

	var ammentar_model := -1
	var warriors_squad := -1
	var warrior_model := -1
	for m: int in state.units:
		var d := str(state.units[m].get("definition_id", ""))
		if d == AMMENTAR_ID: ammentar_model = m
		elif d == WARRIORS_ID:
			if warriors_squad < 0: warriors_squad = int(state.units[m].get("squad", -1))
			if warrior_model < 0: warrior_model = m

	state.units[ammentar_model].position = Vector2(0.0, 0.0)
	for m: int in state.units:
		if int(state.units[m].get("squad", -1)) == warriors_squad:
			state.units[m].position = Vector2(0.0, 4.0)

	var rules_in: Variant = UnitPrevention.rules(state, warrior_model)
	check(rules_in is Array and rules_in.any(func(r: Dictionary) -> bool: return r.get("target") == 5 and r.get("against") == "mortal"), "Nullstone grants FNP 5+ vs mortal wounds within 6 inches")
	check(rules_in is Array and rules_in.any(func(r: Dictionary) -> bool: return r.get("target") == 5 and r.get("against") == "psychic"), "Nullstone grants FNP 5+ vs Psychic Attacks within 6 inches")

	for m: int in state.units:
		if int(state.units[m].get("squad", -1)) == warriors_squad:
			state.units[m].position = Vector2(0.0, 12.0)

	var rules_out: Variant = UnitPrevention.rules(state, warrior_model)
	check(rules_out is Array and not rules_out.any(func(r: Dictionary) -> bool: return r.get("target") == 5 and r.get("against") == "mortal"), "Nullstone FNP 5+ inactive beyond 6 inches")
