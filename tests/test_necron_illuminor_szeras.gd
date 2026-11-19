extends SceneTree

const F = preload("res://tests/all_units_fixture.gd")
const Profiles = preload("res://scripts/edition_11/current_reference_necron_profiles.gd")
const Army = preload("res://scripts/edition_11/army_capabilities.gd")
const AbilityCatalog = preload("res://scripts/edition_11/unit_ability_catalog.gd")
const Reanimation = preload("res://scripts/edition_11/reanimation_protocols.gd")
const UnitAbilities = preload("res://scripts/edition_11/unit_abilities.gd")
const UnitActions = preload("res://scripts/edition_11/unit_actions.gd")
const UnitPrevention = preload("res://scripts/edition_11/unit_prevention.gd")
const Attacks = preload("res://scripts/edition_11/attack_sequence.gd")
const AttackPlan = preload("res://scripts/edition_11/attack_plan.gd")
const IlluminorSzeras = preload("res://scripts/edition_11/illuminor_szeras.gd")
const ContactMovement = preload("res://scripts/edition_11/contact_movement.gd")

const SZERAS_ID := "40kdc:11e:necrons:illuminor-szeras"
const WARRIORS_ID := "40kdc:11e:necrons:necron-warriors"
const IMMORTALS_ID := "40kdc:11e:necrons:immortals"
const LYCHGUARD_ID := "40kdc:11e:necrons:lychguard"
const MARINE_ID := "40kdc:11e:adeptus-astartes:intercessor-squad"

var failures := 0
var scripted_dice: Array[int] = []

func _initialize() -> void:
	call_deferred("run")

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func scripted_roller() -> int:
	if scripted_dice.is_empty():
		return 3
	return scripted_dice.pop_front()

func run() -> void:
	test_datasheet_facts_and_admission()
	test_feel_no_pain()
	test_warlord_eligibility()
	test_lone_operative()
	test_mechanical_augmentation_aura_attacks()
	test_mechanical_augmentation_incoming_ap()
	test_atomic_energy_manipulator()
	test_reanimation_protocols()
	print("Necron Illuminor Szeras checks: %d failures" % failures)
	await process_frame
	quit(1 if failures else 0)

func test_datasheet_facts_and_admission() -> void:
	var szeras := Profiles.profile("illuminor-szeras")
	check(szeras.get("source_datasheet_id") == "000002092", "Illuminor Szeras ID matches 000002092")
	check(szeras.get("points_by_models") == {1: 175}, "Illuminor Szeras points are 175 for 1 model")
	check(szeras.get("base_size_source_mm") == 80, "Illuminor Szeras base is 80 mm")
	check(szeras.get("stats") == {"movement_inches": 8, "toughness": 8, "save_target": 2, "wounds": 9, "leadership_target": 6, "objective_control": 3, "invulnerable_target": 4}, "Illuminor Szeras stats match source (4++ invulnerable save, 9 wounds)")
	check("EPIC HERO" in szeras.get("keywords", []), "Illuminor Szeras has EPIC HERO keyword")
	check("CHARACTER" in szeras.get("keywords", []), "Illuminor Szeras has CHARACTER keyword")
	check("CRYPTEK" in szeras.get("keywords", []), "Illuminor Szeras has CRYPTEK keyword")
	check("INFANTRY" in szeras.get("keywords", []), "Illuminor Szeras has INFANTRY keyword")
	check("NECRONS" in szeras.get("keywords", []), "Illuminor Szeras has NECRONS keyword")
	check(szeras.get("max_supported_copies") == 1, "Illuminor Szeras has max_supported_copies == 1")

	# Weapons
	var ranged_weapons: Array = szeras.get("ranged", [])
	check(ranged_weapons.size() == 1, "Illuminor Szeras has 1 ranged weapon profile")
	var lance_ranged: Dictionary = ranged_weapons[0].get("profiles", {}).get("standard", {})
	check(lance_ranged == {"name": "Eldritch lance", "range_inches": 36.0, "attacks": 3, "skill": 3, "strength": 9, "ap": -3, "damage": 3, "keywords": {}}, "Eldritch lance ranged matches source")

	var melee_weapons: Array = szeras.get("melee", [])
	check(melee_weapons.size() == 2, "Illuminor Szeras has 2 melee weapon profiles")
	var lance_melee: Dictionary = melee_weapons[0].get("profiles", {}).get("standard", {})
	check(lance_melee == {"name": "Eldritch lance", "range_inches": 0.0, "attacks": 4, "skill": 3, "strength": 9, "ap": -3, "damage": 3, "keywords": {}}, "Eldritch lance melee matches source")
	var legs_melee: Dictionary = melee_weapons[1].get("profiles", {}).get("standard", {})
	check(legs_melee == {"name": "Impaling legs", "range_inches": 0.0, "attacks": 4, "skill": 3, "strength": 6, "ap": -1, "damage": 1, "keywords": {"extra-attacks": true}}, "Impaling legs melee matches source with Extra Attacks")

	# Abilities
	check(szeras.get("source_ability_names", []) == ["Feel No Pain 4+", "Reanimation Protocols", "Illuminor", "Mechanical Augmentation (Aura)", "Atomic Energy Manipulator"], "Source ability names match")
	check(szeras.get("supported_rule_ids", []) == ["feel-no-pain-4", "reanimation-protocols", "illuminor", "mechanical-augmentation", "atomic-energy-manipulator"], "Supported rule IDs match")
	check(szeras.get("unsupported_abilities", []).is_empty(), "Unsupported abilities is cleared")
	check(szeras.get("pending_source_checks", []).is_empty(), "Pending source checks is empty")
	check(szeras.get("source_profile_readiness", "") == "source_bounded_local_scope_passed_2026_11_12", "Profile readiness is source-bounded passed")

	# No Leader targets
	check(szeras.get("source_bodyguard_datasheet_ids", []).is_empty(), "Bodyguard IDs are empty (no Leader ability)")

	# Admission check
	var res := Army.resolve("Necrons", SZERAS_ID)
	check(res.get("error", "").is_empty(), "Illuminor Szeras resolves cleanly for construction")
	check(int(res.get("cost", -1)) == 175 and int(res.get("models", -1)) == 1, "Cost is 175, models is 1")
	var spec: Dictionary = Army.SPECS.get("illuminor-szeras", {})
	check(spec.get("max_supported_copies", 0) == 1, "Army specs enforces Epic Hero 1-copy limit")

func test_feel_no_pain() -> void:
	var state: Dictionary = F.P.initial_state({"unit_abilities": true, "reanimation_protocols": true, "combat_doctrines": false, "core_stratagems": true, "manual_allocation": false}, {
		1: {"schema_version": 2, "faction": "Necrons", "category": "custom", "points_limit": 1000, "entries": [
			{"definition_id": SZERAS_ID, "models": 1, "copies": 1}
		]},
		2: {"schema_version": 2, "faction": "Space Marines", "category": "custom", "points_limit": 1000, "entries": [
			{"definition_id": MARINE_ID, "models": 5, "copies": 1}
		]}
	})
	if state.has("error"): return

	var szeras_model := -1
	for m: int in state.units:
		if str(state.units[m].get("definition_id", "")) == SZERAS_ID: szeras_model = m

	check(szeras_model >= 0, "Szeras model exists in fixture")

	# 1. Prevention rules for Szeras contains FNP 4+
	var rules: Variant = UnitPrevention.rules(state, szeras_model)
	check(rules is Array and rules.any(func(r: Dictionary) -> bool: return r.get("target") == 4 and r.get("against") == "any"), "Szeras has Feel No Pain 4+ prevention rule")

	# 2. Wound prevention resolution: 4+ ignores damage
	scripted_dice = [3, 4]
	var prev_fail := Attacks.Prevention.resolve(1, 9, rules, "normal", Callable(self, "scripted_roller"))
	check(int(prev_fail.get("prevented", -1)) == 0 and int(prev_fail.get("lost", -1)) == 1, "Roll of 3 fails Feel No Pain 4+")

	var prev_pass := Attacks.Prevention.resolve(1, 9, rules, "normal", Callable(self, "scripted_roller"))
	check(int(prev_pass.get("prevented", -1)) == 1 and int(prev_pass.get("lost", -1)) == 0, "Roll of 4 succeeds Feel No Pain 4+")

func test_warlord_eligibility() -> void:
	var state: Dictionary = F.P.initial_state({"unit_abilities": true, "reanimation_protocols": true, "combat_doctrines": false, "core_stratagems": true, "manual_allocation": false}, {
		1: {"schema_version": 2, "faction": "Necrons", "category": "custom", "points_limit": 1000, "entries": [
			{"definition_id": SZERAS_ID, "models": 1, "copies": 1},
			{"definition_id": WARRIORS_ID, "models": 10, "copies": 1}
		]},
		2: {"schema_version": 2, "faction": "Space Marines", "category": "custom", "points_limit": 1000, "entries": [
			{"definition_id": MARINE_ID, "models": 5, "copies": 1}
		]}
	})
	if state.has("error"): return

	var szeras_model := -1
	for m: int in state.units:
		if str(state.units[m].get("definition_id", "")) == SZERAS_ID: szeras_model = m

	var setup_choices := UnitActions.choices(state, 1)

	# Warlord choice offered
	var warlord_options := setup_choices.filter(func(c: Dictionary) -> bool: return c.get("action", "") == "warlord" and int(c.get("model", -1)) == szeras_model)
	check(not warlord_options.is_empty(), "Illuminor Szeras is offered as Warlord choice during setup")
	var warlord_res := UnitActions.apply(state, 1, warlord_options[0], Vector2.ZERO, Callable())
	check(str(warlord_res.get("error", "")).is_empty(), "Illuminor Szeras Warlord applied cleanly")
	check(state.unit_abilities.warlords.get(1, -1) == szeras_model, "Szeras recorded as Player 1 Warlord")

	# No attach choices for Szeras (not a Leader)
	var attach_options := setup_choices.filter(func(c: Dictionary) -> bool: return c.get("action", "") == "attach" and int(c.get("model", -1)) == szeras_model)
	check(attach_options.is_empty(), "Illuminor Szeras has no attachment options (not a Leader)")

func test_lone_operative() -> void:
	var state: Dictionary = F.P.initial_state({"unit_abilities": true, "reanimation_protocols": true, "combat_doctrines": false, "core_stratagems": true, "manual_allocation": false}, {
		1: {"schema_version": 2, "faction": "Necrons", "category": "custom", "points_limit": 1000, "entries": [
			{"definition_id": SZERAS_ID, "models": 1, "copies": 1},
			{"definition_id": WARRIORS_ID, "models": 10, "copies": 1}
		]},
		2: {"schema_version": 2, "faction": "Space Marines", "category": "custom", "points_limit": 1000, "entries": [
			{"definition_id": MARINE_ID, "models": 5, "copies": 1}
		]}
	})
	if state.has("error"): return

	var szeras_model := -1
	var warriors_squad := -1
	var marine_squad := -1
	for m: int in state.units:
		var u: Dictionary = state.units[m]
		if str(u.get("definition_id", "")) == SZERAS_ID: szeras_model = m
		elif str(u.get("definition_id", "")) == WARRIORS_ID and warriors_squad < 0: warriors_squad = int(u.get("squad", -1))
		elif str(u.get("definition_id", "")) == MARINE_ID and marine_squad < 0: marine_squad = int(u.get("squad", -1))

	# Position Szeras at (0, 0)
	state.units[szeras_model].position = Vector2(0.0, 0.0)

	# 1. Alone on battlefield (Warriors far away at (50, 50))
	for m: int in state.units:
		if int(state.units[m].get("squad", -1)) == warriors_squad:
			state.units[m].position = Vector2(50.0, 50.0)
		elif int(state.units[m].get("squad", -1)) == marine_squad:
			state.units[m].position = Vector2(50.0, -50.0)

	check(not UnitAbilities.lone_operative_active(state, szeras_model), "Lone Operative inactive when Szeras is alone on battlefield")
	check(UnitAbilities.lone_operative_range(state, szeras_model) == 0.0, "Lone Operative range is 0 when inactive")

	# 2. Friendly Necrons unit within 3"
	# Szeras 80mm base (radius ~1.57"), Warriors 32mm base (radius ~0.63")
	# Center at (0, 4.0) -> edge distance = 4.0 - 1.57 - 0.63 = 1.80" <= 3.0"
	for m: int in state.units:
		if int(state.units[m].get("squad", -1)) == warriors_squad:
			state.units[m].position = Vector2(0.0, 4.0)

	check(UnitAbilities.lone_operative_active(state, szeras_model), "Lone Operative active when within 3 inches of friendly Necrons unit")
	check(UnitAbilities.lone_operative_range(state, szeras_model) == 12.0, "Lone Operative range is 12.0 when active")

	# 3. Friendly Necrons unit beyond 3"
	# Center at (0, 6.0) -> edge distance = 6.0 - 1.57 - 0.63 = 3.80" > 3.0"
	for m: int in state.units:
		if int(state.units[m].get("squad", -1)) == warriors_squad:
			state.units[m].position = Vector2(0.0, 6.0)

	check(not UnitAbilities.lone_operative_active(state, szeras_model), "Lone Operative inactive when friendly Necrons unit is beyond 3 inches")

	# 4. Enemy unit nearby does not trigger Lone Operative
	for m: int in state.units:
		if int(state.units[m].get("squad", -1)) == marine_squad:
			state.units[m].position = Vector2(0.0, 3.0)

	check(not UnitAbilities.lone_operative_active(state, szeras_model), "Enemy unit within 3 inches does not grant Lone Operative")

	# 5. Destroyed friendly unit within 3" does not grant Lone Operative
	for m: int in state.units:
		if int(state.units[m].get("squad", -1)) == warriors_squad:
			state.units[m].position = Vector2(0.0, 4.0)
			state.units[m].wounds = 0

	check(not UnitAbilities.lone_operative_active(state, szeras_model), "Destroyed friendly Necrons unit within 3 inches does not grant Lone Operative")

func test_mechanical_augmentation_aura_attacks() -> void:
	var state: Dictionary = F.P.initial_state({"unit_abilities": true, "reanimation_protocols": true, "combat_doctrines": false, "core_stratagems": true, "manual_allocation": false}, {
		1: {"schema_version": 2, "faction": "Necrons", "category": "custom", "points_limit": 1000, "entries": [
			{"definition_id": SZERAS_ID, "models": 1, "copies": 1},
			{"definition_id": WARRIORS_ID, "models": 10, "copies": 1},
			{"definition_id": LYCHGUARD_ID, "models": 5, "copies": 1}
		]},
		2: {"schema_version": 2, "faction": "Space Marines", "category": "custom", "points_limit": 1000, "entries": [
			{"definition_id": MARINE_ID, "models": 5, "copies": 1}
		]}
	})
	if state.has("error"): return

	var szeras_model := -1
	var warriors_squad := -1
	var lychguard_squad := -1
	var marine_squad := -1
	var warrior_model := -1
	var lychguard_model := -1
	for m: int in state.units:
		var u: Dictionary = state.units[m]
		if str(u.get("definition_id", "")) == SZERAS_ID: szeras_model = m
		elif str(u.get("definition_id", "")) == WARRIORS_ID:
			if warriors_squad < 0: warriors_squad = int(u.get("squad", -1))
			if warrior_model < 0: warrior_model = m
		elif str(u.get("definition_id", "")) == LYCHGUARD_ID:
			if lychguard_squad < 0: lychguard_squad = int(u.get("squad", -1))
			if lychguard_model < 0: lychguard_model = m
		elif str(u.get("definition_id", "")) == MARINE_ID and marine_squad < 0: marine_squad = int(u.get("squad", -1))

	state.units[szeras_model].position = Vector2(0.0, 0.0)

	# Position Marines within 24" range (at (0, 15.0))
	for m: int in state.units:
		if int(state.units[m].get("squad", -1)) == marine_squad:
			state.units[m].position = Vector2(0.0, 15.0)

	# 1. Friendly Battleline unit (Warriors) within 3"
	for m: int in state.units:
		if int(state.units[m].get("squad", -1)) == warriors_squad:
			state.units[m].position = Vector2(0.0, 4.0) # ~1.8" edge distance

	check(IlluminorSzeras.mechanical_augmentation_applies(state, warriors_squad), "Mechanical Augmentation applies to friendly Battleline unit within range")

	# Check attack AP improvement via UnitAbilities.weapon
	var original_weapon := {"name": "Gauss flayer", "range_inches": 24.0, "attacks": 1, "skill": 4, "strength": 4, "ap": 0, "damage": 1, "keywords": {}}
	var modified_weapon := UnitAbilities.weapon(state, warrior_model, marine_squad, original_weapon, false)
	check(int(modified_weapon.ap) == -1, "Mechanical Augmentation improves Gauss flayer AP from 0 to -1")

	# Check full AttackPlan preparation
	var warrior_weapon_id := str(state.units[warrior_model].get("ranged_weapons", [{}])[0].get("id", "primary"))
	var plan := AttackPlan.prepare(state, warriors_squad, false, [{"model": warrior_model, "target": marine_squad, "amount": 1, "weapon": warrior_weapon_id, "profile": "standard"}], false)
	check(plan.get("error", "").is_empty(), "Attack plan prepares cleanly for Warriors: " + str(plan.get("error", "")))
	if plan.get("batches", []).size() > 0:
		var batch: Dictionary = plan.batches[0]
		check(int(batch.weapon.ap) == -1, "Batch weapon has improved AP (-1) from Mechanical Augmentation")

	# 2. Friendly non-Battleline unit (Lychguard) within 3"
	for m: int in state.units:
		if int(state.units[m].get("squad", -1)) == lychguard_squad:
			state.units[m].position = Vector2(0.0, 4.0)

	check(not IlluminorSzeras.mechanical_augmentation_applies(state, lychguard_squad), "Mechanical Augmentation does not apply to non-Battleline unit (Lychguard)")
	var lychguard_blade := {"name": "Warscythe", "range_inches": 0.0, "attacks": 3, "skill": 3, "strength": 8, "ap": -3, "damage": 2, "keywords": {}}
	var unmodified_blade := UnitAbilities.weapon(state, lychguard_model, marine_squad, lychguard_blade, true)
	check(int(unmodified_blade.ap) == -3, "Lychguard Warscythe AP remains unchanged (-3)")

	# 3. Friendly Battleline unit beyond 3"
	for m: int in state.units:
		if int(state.units[m].get("squad", -1)) == warriors_squad:
			state.units[m].position = Vector2(0.0, 7.0) # ~4.8" edge distance

	check(not IlluminorSzeras.mechanical_augmentation_applies(state, warriors_squad), "Mechanical Augmentation does not apply to Battleline unit outside range")
	var outside_weapon := UnitAbilities.weapon(state, warrior_model, marine_squad, original_weapon, false)
	check(int(outside_weapon.ap) == 0, "Gauss flayer AP remains 0 outside aura range")

	# 4. Szeras dead -> aura ceases to apply
	for m: int in state.units:
		if int(state.units[m].get("squad", -1)) == warriors_squad:
			state.units[m].position = Vector2(0.0, 4.0)
	state.units[szeras_model].wounds = 0
	check(not IlluminorSzeras.mechanical_augmentation_applies(state, warriors_squad), "Mechanical Augmentation inactive when Szeras is destroyed")

func test_mechanical_augmentation_incoming_ap() -> void:
	var state: Dictionary = F.P.initial_state({"unit_abilities": true, "reanimation_protocols": true, "combat_doctrines": false, "core_stratagems": true, "manual_allocation": false}, {
		1: {"schema_version": 2, "faction": "Necrons", "category": "custom", "points_limit": 1000, "entries": [
			{"definition_id": SZERAS_ID, "models": 1, "copies": 1},
			{"definition_id": WARRIORS_ID, "models": 10, "copies": 1},
			{"definition_id": LYCHGUARD_ID, "models": 5, "copies": 1}
		]},
		2: {"schema_version": 2, "faction": "Space Marines", "category": "custom", "points_limit": 1000, "entries": [
			{"definition_id": MARINE_ID, "models": 5, "copies": 1}
		]}
	})
	if state.has("error"): return

	var szeras_model := -1
	var warriors_squad := -1
	var lychguard_squad := -1
	var marine_squad := -1
	var marine_model := -1
	for m: int in state.units:
		var u: Dictionary = state.units[m]
		if str(u.get("definition_id", "")) == SZERAS_ID: szeras_model = m
		elif str(u.get("definition_id", "")) == WARRIORS_ID and warriors_squad < 0: warriors_squad = int(u.get("squad", -1))
		elif str(u.get("definition_id", "")) == LYCHGUARD_ID and lychguard_squad < 0: lychguard_squad = int(u.get("squad", -1))
		elif str(u.get("definition_id", "")) == MARINE_ID:
			if marine_squad < 0: marine_squad = int(u.get("squad", -1))
			if marine_model < 0: marine_model = m

	state.units[szeras_model].position = Vector2(0.0, 0.0)
	for m: int in state.units:
		if int(state.units[m].get("squad", -1)) == warriors_squad:
			state.units[m].position = Vector2(0.0, 4.0)

	# 1. Incoming attack against friendly Battleline unit inside range:
	# AP -1 worsened by 1 -> AP 0
	var bolt_rifle := {"name": "Bolt rifle", "range_inches": 24.0, "attacks": 2, "skill": 3, "strength": 4, "ap": -1, "damage": 1, "keywords": {}}
	var defended_rifle := UnitAbilities.defend(state, marine_squad, warriors_squad, bolt_rifle)
	check(int(defended_rifle.ap) == 0, "Mechanical Augmentation worsens incoming Bolt rifle AP from -1 to 0")

	# AP -3 worsened by 1 -> AP -2
	var plasma := {"name": "Plasma incinerator", "range_inches": 24.0, "attacks": 2, "skill": 3, "strength": 7, "ap": -3, "damage": 1, "keywords": {}}
	var defended_plasma := UnitAbilities.defend(state, marine_squad, warriors_squad, plasma)
	check(int(defended_plasma.ap) == -2, "Mechanical Augmentation worsens incoming Plasma AP from -3 to -2")

	# AP 0 worsened by 1 -> remains AP 0 (capped at 0)
	var autogun := {"name": "Autogun", "range_inches": 24.0, "attacks": 1, "skill": 4, "strength": 3, "ap": 0, "damage": 1, "keywords": {}}
	var defended_autogun := UnitAbilities.defend(state, marine_squad, warriors_squad, autogun)
	check(int(defended_autogun.ap) == 0, "Mechanical Augmentation worsens incoming AP 0 to 0 (capped at 0)")

	# Full AttackPlan preparation: Marine attacking Warriors
	# Position marine within range of Warriors
	for m: int in state.units:
		if int(state.units[m].get("squad", -1)) == marine_squad:
			state.units[m].position = Vector2(0.0, 8.0)
	var plan := AttackPlan.prepare(state, marine_squad, false, [{"model": marine_model, "target": warriors_squad, "amount": 1, "weapon": "bolt-rifle", "profile": "focused_fire"}], false)
	check(plan.get("error", "").is_empty(), "Attack plan prepares cleanly for Marine attacking Warriors")
	if plan.get("batches", []).size() > 0:
		var batch: Dictionary = plan.batches[0]
		check(int(batch.weapon.ap) == 0, "Batch weapon has worsened AP (0 from -1) against Battleline unit in aura")

	# 2. Incoming attack against friendly non-Battleline unit (Lychguard) inside range:
	for m: int in state.units:
		if int(state.units[m].get("squad", -1)) == lychguard_squad:
			state.units[m].position = Vector2(0.0, 4.0)
	var undefended_rifle := UnitAbilities.defend(state, marine_squad, lychguard_squad, bolt_rifle)
	check(int(undefended_rifle.ap) == -1, "Incoming AP against non-Battleline unit (Lychguard) is not worsened")

	# 3. Incoming attack against Battleline unit outside range:
	for m: int in state.units:
		if int(state.units[m].get("squad", -1)) == warriors_squad:
			state.units[m].position = Vector2(0.0, 8.0) # > 3" from Szeras
	var distant_defended := UnitAbilities.defend(state, marine_squad, warriors_squad, bolt_rifle)
	check(int(distant_defended.ap) == -1, "Incoming AP against Battleline unit outside aura is not worsened")

func test_atomic_energy_manipulator() -> void:
	var state: Dictionary = F.P.initial_state({"unit_abilities": true, "reanimation_protocols": true, "combat_doctrines": false, "core_stratagems": true, "manual_allocation": false}, {
		1: {"schema_version": 2, "faction": "Necrons", "category": "custom", "points_limit": 1000, "entries": [
			{"definition_id": SZERAS_ID, "models": 1, "copies": 1},
			{"definition_id": WARRIORS_ID, "models": 10, "copies": 1}
		]},
		2: {"schema_version": 2, "faction": "Space Marines", "category": "custom", "points_limit": 1000, "entries": [
			{"definition_id": MARINE_ID, "models": 5, "copies": 1}
		]}
	})
	if state.has("error"): return

	var szeras_model := -1
	var warriors_squad := -1
	for m: int in state.units:
		var u: Dictionary = state.units[m]
		if str(u.get("definition_id", "")) == SZERAS_ID: szeras_model = m
		elif str(u.get("definition_id", "")) == WARRIORS_ID and warriors_squad < 0: warriors_squad = int(u.get("squad", -1))

	state.units[szeras_model].position = Vector2(0.0, 0.0)

	# Position Warriors at edge distance ~4.5" (center at (0, 6.7))
	# Szeras r~1.57", Warriors r~0.63" -> edge distance = 6.7 - 2.2 = 4.5"
	for m: int in state.units:
		if int(state.units[m].get("squad", -1)) == warriors_squad:
			state.units[m].position = Vector2(0.0, 6.7)

	# 1. Base range is 3.0" -> Warriors at 4.5" are outside range
	check(IlluminorSzeras.mechanical_augmentation_range(state, szeras_model) == 3.0, "Initial aura range is 3.0 inches")
	check(not IlluminorSzeras.mechanical_augmentation_applies(state, warriors_squad), "Warriors at 4.5 inches are outside 3-inch base aura")

	# 2. Fight phase with 0 kills -> range does not increment
	state.phase = "fight"
	state.turn = 1
	var no_kill_res := IlluminorSzeras.resolve_atomic_energy_manipulator(state)
	check(no_kill_res.is_empty(), "No range change when 0 models destroyed")
	check(IlluminorSzeras.mechanical_augmentation_range(state, szeras_model) == 3.0, "Range remains 3.0 inches after 0 kills")

	# 3. Fight phase with 1 kill by Szeras -> range increments to 6.0"
	IlluminorSzeras.record_kill(state, szeras_model, 1)
	check(IlluminorSzeras.kills_this_phase(state, szeras_model) == 1, "Kills this phase recorded as 1")
	var kill_res_1 := IlluminorSzeras.resolve_atomic_energy_manipulator(state)
	check(kill_res_1.size() == 1 and kill_res_1[0].get("new_range") == 6.0, "Atomic Energy Manipulator increases range to 6.0 inches after a kill")
	check(IlluminorSzeras.mechanical_augmentation_range(state, szeras_model) == 6.0, "Range is now 6.0 inches")

	# Warriors at 4.5" are now INSIDE the expanded 6.0" aura!
	check(IlluminorSzeras.mechanical_augmentation_applies(state, warriors_squad), "Warriors at 4.5 inches are now inside 6-inch aura")

	# 4. Next Fight phase (turn 3): 2 kills by Szeras -> range increments to 9.0"
	state.turn = 3
	IlluminorSzeras.record_kill(state, szeras_model, 2)
	var kill_res_2 := IlluminorSzeras.resolve_atomic_energy_manipulator(state)
	check(kill_res_2.size() == 1 and kill_res_2[0].get("new_range") == 9.0, "Atomic Energy Manipulator increases range from 6.0 to 9.0 inches")
	check(IlluminorSzeras.mechanical_augmentation_range(state, szeras_model) == 9.0, "Range is now 9.0 inches")

	# 5. Next Fight phase (turn 5): 1 kill -> range increments to 12.0"
	state.turn = 5
	IlluminorSzeras.record_kill(state, szeras_model, 1)
	var kill_res_3 := IlluminorSzeras.resolve_atomic_energy_manipulator(state)
	check(kill_res_3.size() == 1 and kill_res_3[0].get("new_range") == 12.0, "Atomic Energy Manipulator increases range from 9.0 to 12.0 inches")
	check(IlluminorSzeras.mechanical_augmentation_range(state, szeras_model) == 12.0, "Range is now 12.0 inches")

	# 6. Next Fight phase (turn 7): 1 kill -> range caps at 12.0"
	state.turn = 7
	IlluminorSzeras.record_kill(state, szeras_model, 1)
	var kill_res_4 := IlluminorSzeras.resolve_atomic_energy_manipulator(state)
	check(kill_res_4.size() == 1 and kill_res_4[0].get("new_range") == 12.0, "Atomic Energy Manipulator caps range at 12.0 inches")
	check(IlluminorSzeras.mechanical_augmentation_range(state, szeras_model) == 12.0, "Range remains capped at 12.0 inches")

func test_reanimation_protocols() -> void:
	var state: Dictionary = F.P.initial_state({"unit_abilities": true, "reanimation_protocols": true, "combat_doctrines": false, "core_stratagems": true, "manual_allocation": false}, {
		1: {"schema_version": 2, "faction": "Necrons", "category": "custom", "points_limit": 1000, "entries": [
			{"definition_id": SZERAS_ID, "models": 1, "copies": 1}
		]},
		2: {"schema_version": 2, "faction": "Space Marines", "category": "custom", "points_limit": 1000, "entries": [
			{"definition_id": MARINE_ID, "models": 5, "copies": 1}
		]}
	})
	if state.has("error"): return

	# 1. Wound map and model size registration
	check(Reanimation.CHARACTER_WOUNDS.get(SZERAS_ID) == 9, "Szeras character wounds is 9")
	check(Reanimation.PROFILE_MODEL_COUNTS.get(SZERAS_ID) == [1], "Szeras profile model count is [1]")

	var szeras_model := -1
	for m: int in state.units:
		if str(state.units[m].get("definition_id", "")) == SZERAS_ID: szeras_model = m

	var szeras_squad := int(state.units[szeras_model].get("squad", -1))

	# 2. Living single-model character reanimation
	check(Reanimation.supported_unit(state, szeras_squad), "Szeras standalone is a supported Reanimation unit")

	# Wound Szeras to 5 wounds remaining and test healing
	state.units[szeras_model].wounds = 5
	Reanimation.enable(state)
	state.reanimation.anchors = {szeras_squad: []}
	state.reanimation.pending = {"player": 1, "remaining": [szeras_squad], "current": {}, "results": []}
	# Script die roll of 4 (D3 = 2 wounds healed) -> Szeras should be at 7 wounds
	scripted_dice = []
	var prep := Reanimation._prepare_healing(state, szeras_squad, 4, Callable(self, "scripted_roller"))
	check(prep.get("error", "").is_empty() and state.units[szeras_model].wounds == 7, "Reanimation heals wounded Szeras by 2 wounds (from 5 to 7)")
