extends SceneTree

const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const Profiles = preload("res://scripts/edition_11/current_reference_necron_profiles.gd")
const Army = preload("res://scripts/edition_11/army_capabilities.gd")
const AbilityCatalog = preload("res://scripts/edition_11/unit_ability_catalog.gd")
const LeaderCatalog = preload("res://scripts/edition_11/leader_catalog.gd")
const Reanimation = preload("res://scripts/edition_11/reanimation_protocols.gd")
const UnitAbilities = preload("res://scripts/edition_11/unit_abilities.gd")
const UnitActions = preload("res://scripts/edition_11/unit_actions.gd")
const LordOfTheStorm = preload("res://scripts/edition_11/lord_of_the_storm.gd")
const ContactMovement = preload("res://scripts/edition_11/contact_movement.gd")

const IMOTEKH_ID := "40kdc:11e:necrons:imotekh-the-stormlord"
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
	test_leader_attachment_and_warlord()
	test_grand_strategist()
	test_lord_of_the_storm_offer_decline_and_range()
	test_lord_of_the_storm_damage_and_lock()
	test_reanimation_protocols()
	print("Necron Imotekh checks: %d failures" % failures)
	await process_frame
	quit(1 if failures else 0)

func test_datasheet_facts_and_admission() -> void:
	var imotekh := Profiles.profile("imotekh-the-stormlord")
	check(imotekh.get("source_datasheet_id") == "000000522", "Imotekh ID matches 000000522")
	check(imotekh.get("points_by_models") == {1: 100}, "Imotekh points are 100 for 1 model")
	check(imotekh.get("base_size_source_mm") == 40, "Imotekh base is 40 mm")
	check(imotekh.get("stats") == {"movement_inches": 5, "toughness": 5, "save_target": 2, "wounds": 6, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 4}, "Imotekh stats match source (4++ invulnerable save)")
	check("EPIC HERO" in imotekh.get("keywords", []), "Imotekh has EPIC HERO keyword")
	check("NOBLE" in imotekh.get("keywords", []), "Imotekh has NOBLE keyword")
	check("CHARACTER" in imotekh.get("keywords", []), "Imotekh has CHARACTER keyword")
	check(imotekh.get("max_supported_copies") == 1, "Imotekh has max_supported_copies == 1")

	# Weapons
	var ranged_weapons: Array = imotekh.get("ranged", [])
	check(ranged_weapons.size() == 2, "Imotekh has 2 ranged weapon profiles")
	var gauntlet: Dictionary = ranged_weapons[0].get("profiles", {}).get("standard", {})
	check(gauntlet == {"name": "Gauntlet of Fire", "range_inches": 12.0, "attacks": "D6", "skill": "-", "strength": 5, "ap": -1, "damage": 1, "keywords": {"ignores-cover": true, "torrent": true}}, "Gauntlet of Fire matches source")
	var staff_ranged: Dictionary = ranged_weapons[1].get("profiles", {}).get("standard", {})
	check(staff_ranged == {"name": "Staff of the Destroyer", "range_inches": 18.0, "attacks": 3, "skill": 2, "strength": 6, "ap": -3, "damage": 2, "keywords": {}}, "Staff of the Destroyer ranged matches source")

	var melee_weapons: Array = imotekh.get("melee", [])
	check(melee_weapons.size() == 1, "Imotekh has 1 melee weapon profile")
	var staff_melee: Dictionary = melee_weapons[0].get("profiles", {}).get("standard", {})
	check(staff_melee == {"name": "Staff of the Destroyer", "range_inches": 0.0, "attacks": 4, "skill": 2, "strength": 6, "ap": -3, "damage": 2, "keywords": {"devastating-wounds": true}}, "Staff of the Destroyer melee matches source")

	# Abilities
	check(imotekh.get("source_ability_names", []) == ["Leader", "Reanimation Protocols", "Grand Strategist", "Lord of the Storm"], "Source ability names match")
	check(imotekh.get("supported_rule_ids", []) == ["leader", "reanimation-protocols", "grand-strategist", "lord-of-the-storm"], "Supported rule IDs match")
	check(imotekh.get("unsupported_abilities", []).is_empty(), "Unsupported abilities is cleared")
	check(imotekh.get("pending_source_checks", []).is_empty(), "Pending source checks is empty")
	check(imotekh.get("source_profile_readiness", "") == "source_bounded_local_scope_passed_2026_11_12", "Profile readiness is source-bounded passed")

	# Leader targets
	check(imotekh.get("source_bodyguard_datasheet_ids", []) == ["000000534", "000000536", "000000535"], "Bodyguard IDs match Warriors, Lychguard, Immortals")

	# Admission check
	var res := Army.resolve("Necrons", IMOTEKH_ID)
	check(res.get("error", "").is_empty(), "Imotekh resolves cleanly for construction")
	check(int(res.get("cost", -1)) == 100 and int(res.get("models", -1)) == 1, "Cost is 100, models is 1")
	var spec: Dictionary = Army.SPECS.get("imotekh-the-stormlord", {})
	check(spec.get("max_supported_copies", 0) == 1, "Army specs enforces Epic Hero 1-copy limit")

func test_leader_attachment_and_warlord() -> void:
	var state: Dictionary = F.P.initial_state({"unit_abilities": true, "reanimation_protocols": true, "combat_doctrines": false, "core_stratagems": true, "manual_allocation": false}, {
		1: {"schema_version": 2, "faction": "Necrons", "category": "custom", "points_limit": 1000, "entries": [
			{"definition_id": IMOTEKH_ID, "models": 1, "copies": 1},
			{"definition_id": WARRIORS_ID, "models": 10, "copies": 1},
			{"definition_id": IMMORTALS_ID, "models": 5, "copies": 1},
			{"definition_id": LYCHGUARD_ID, "models": 5, "copies": 1}
		]},
		2: {"schema_version": 2, "faction": "Space Marines", "category": "custom", "points_limit": 1000, "entries": [
			{"definition_id": MARINE_ID, "models": 5, "copies": 1}
		]}
	})
	check(not state.has("error"), "Fixture with Imotekh and 3 bodyguards initializes")
	if state.has("error"): return

	var imotekh_model := -1
	var warriors_squad := -1
	var immortals_squad := -1
	var lychguard_squad := -1
	for m: int in state.units:
		var u: Dictionary = state.units[m]
		var def := str(u.get("definition_id", ""))
		if def == IMOTEKH_ID: imotekh_model = m
		elif def == WARRIORS_ID and warriors_squad < 0: warriors_squad = int(u.get("squad", -1))
		elif def == IMMORTALS_ID and immortals_squad < 0: immortals_squad = int(u.get("squad", -1))
		elif def == LYCHGUARD_ID and lychguard_squad < 0: lychguard_squad = int(u.get("squad", -1))

	check(imotekh_model >= 0, "Imotekh model exists")

	# Shared Leader catalog checks
	var leader_targets: Array = LeaderCatalog.ATTACHMENTS.get(IMOTEKH_ID, [])
	check(WARRIORS_ID in leader_targets, "LeaderCatalog allows Imotekh -> Warriors")
	check(IMMORTALS_ID in leader_targets, "LeaderCatalog allows Imotekh -> Immortals")
	check(LYCHGUARD_ID in leader_targets, "LeaderCatalog allows Imotekh -> Lychguard")

	# UnitActions choices during setup
	var setup_choices := UnitActions.choices(state, 1)

	# Warlord choice
	var warlord_options := setup_choices.filter(func(c: Dictionary) -> bool: return c.get("action", "") == "warlord" and int(c.get("model", -1)) == imotekh_model)
	check(not warlord_options.is_empty(), "Imotekh is offered as Warlord choice during setup")
	var warlord_res := UnitActions.apply(state, 1, warlord_options[0], Vector2.ZERO, Callable())
	check(str(warlord_res.get("error", "")).is_empty(), "Imotekh Warlord applied cleanly")
	check(state.unit_abilities.warlords.get(1, -1) == imotekh_model, "Imotekh is recorded as Player 1 Warlord")

	# Attachment choices to all three bodyguards
	var attach_war := setup_choices.filter(func(c: Dictionary) -> bool: return c.get("action", "") == "attach" and int(c.get("model", -1)) == imotekh_model and int(c.get("target", -1)) == warriors_squad)
	var attach_imm := setup_choices.filter(func(c: Dictionary) -> bool: return c.get("action", "") == "attach" and int(c.get("model", -1)) == imotekh_model and int(c.get("target", -1)) == immortals_squad)
	var attach_lych := setup_choices.filter(func(c: Dictionary) -> bool: return c.get("action", "") == "attach" and int(c.get("model", -1)) == imotekh_model and int(c.get("target", -1)) == lychguard_squad)
	check(not attach_war.is_empty(), "Imotekh can attach to Necron Warriors")
	check(not attach_imm.is_empty(), "Imotekh can attach to Immortals")
	check(not attach_lych.is_empty(), "Imotekh can attach to Lychguard")

	# Execute attachment to Lychguard
	var attach_res := UnitActions.apply(state, 1, attach_lych[0], Vector2.ZERO, Callable())
	check(str(attach_res.get("error", "")).is_empty(), "Attachment applied cleanly via UnitActions.apply")
	check(state.units[imotekh_model].get("attachment_role", "") == "leader", "Imotekh has attachment_role == leader")
	check(state.squads[lychguard_squad].attached, "Lychguard squad is marked attached")
	check(UnitAbilities.noble_leading(state, lychguard_squad), "Imotekh is a NOBLE leading Lychguard")

func test_grand_strategist() -> void:
	var state: Dictionary = F.P.initial_state({"unit_abilities": true, "reanimation_protocols": true, "combat_doctrines": false, "core_stratagems": true, "manual_allocation": false}, {
		1: {"schema_version": 2, "faction": "Necrons", "category": "custom", "points_limit": 1000, "entries": [
			{"definition_id": IMOTEKH_ID, "models": 1, "copies": 1}
		]},
		2: {"schema_version": 2, "faction": "Space Marines", "category": "custom", "points_limit": 1000, "entries": [
			{"definition_id": MARINE_ID, "models": 5, "copies": 1}
		]}
	})
	if state.has("error"): return

	var imotekh_model := -1
	for m: int in state.units:
		if str(state.units[m].get("definition_id", "")) == IMOTEKH_ID: imotekh_model = m

	# Set phase to command, active to player 1
	state.phase = "command"
	state.active = 1
	state.turn = 1
	state.cp = {1: 0, 2: 0}

	# 1. Imotekh on battlefield -> gains 1 CP
	var gained := UnitAbilities.resolve_grand_strategist(state)
	check(gained == 1 and state.cp[1] == 1, "Grand Strategist grants 1 CP at start of Command phase on battlefield")

	# Second call in same turn does not grant another CP (once per Command phase check)
	var gained_again := UnitAbilities.resolve_grand_strategist(state)
	check(gained_again == 0 and state.cp[1] == 1, "Grand Strategist does not double-fire in same turn")

	# 2. Imotekh destroyed -> 0 CP
	state.turn = 3 # Player 1's next turn
	state.units[imotekh_model].wounds = 0
	var cp_before := int(state.cp[1])
	var gained_dead := UnitAbilities.resolve_grand_strategist(state)
	check(gained_dead == 0 and state.cp[1] == cp_before, "Grand Strategist does not fire when Imotekh is destroyed")

	# 3. Imotekh in reserves / off battlefield -> 0 CP
	state.units[imotekh_model].wounds = 6
	state.units[imotekh_model].on_battlefield = false
	state.turn = 5
	var gained_reserves := UnitAbilities.resolve_grand_strategist(state)
	check(gained_reserves == 0 and state.cp[1] == cp_before, "Grand Strategist does not fire when Imotekh is in reserves / not on battlefield")

	# 4. Opponent's Command phase -> 0 CP for Player 1
	state.units[imotekh_model].on_battlefield = true
	state.active = 2
	state.turn = 6
	var gained_opp := UnitAbilities.resolve_grand_strategist(state)
	check(gained_opp == 0 and state.cp[1] == cp_before, "Grand Strategist does not fire during opponent's Command phase")

func test_lord_of_the_storm_offer_decline_and_range() -> void:
	var state: Dictionary = F.P.initial_state({"unit_abilities": true, "reanimation_protocols": true, "combat_doctrines": false, "core_stratagems": true, "manual_allocation": false}, {
		1: {"schema_version": 2, "faction": "Necrons", "category": "custom", "points_limit": 1000, "entries": [
			{"definition_id": IMOTEKH_ID, "models": 1, "copies": 1}
		]},
		2: {"schema_version": 2, "faction": "Space Marines", "category": "custom", "points_limit": 1000, "entries": [
			{"definition_id": MARINE_ID, "models": 5, "copies": 2}
		]}
	})
	if state.has("error"): return

	var imotekh_model := -1
	var marine_squads: Array[int] = []
	for m: int in state.units:
		var u: Dictionary = state.units[m]
		if str(u.get("definition_id", "")) == IMOTEKH_ID: imotekh_model = m
		elif str(u.get("definition_id", "")) == MARINE_ID:
			var sq := int(u.get("squad", -1))
			if sq not in marine_squads: marine_squads.append(sq)

	var close_squad := marine_squads[0]
	var far_squad := marine_squads[1]

	# Position Imotekh at (0, 0)
	state.units[imotekh_model].position = Vector2(0.0, 0.0)

	# Position close_squad within 12" (center at (0, 8), base radius ~0.63", edge gap ~6.6")
	for m: int in state.units:
		if int(state.units[m].get("squad", -1)) == close_squad:
			state.units[m].position = Vector2(0.0, 8.0)

	# Position far_squad beyond 12" (center at (0, 20), edge gap ~18.6")
	for m: int in state.units:
		if int(state.units[m].get("squad", -1)) == far_squad:
			state.units[m].position = Vector2(0.0, 20.0)

	# Test 12" range inclusion and exclusion
	var in_range_targets := LordOfTheStorm._targets(state, imotekh_model)
	check(close_squad in in_range_targets, "Enemy unit within 12 inches is included in targets")
	check(far_squad not in in_range_targets, "Enemy unit beyond 12 inches is excluded from targets")

	# Test offer and decline
	state.phase = "command"
	state.active = 1
	state.turn = 1
	state.unit_abilities.window = {"kind": "end", "owners": [1]}

	var choices := LordOfTheStorm.choices(state, 1)
	var use_opt := choices.filter(func(c: Dictionary) -> bool: return c.get("action", "") == LordOfTheStorm.ACTION)
	var decline_opt := choices.filter(func(c: Dictionary) -> bool: return c.get("action", "") == LordOfTheStorm.DECLINE)
	check(not use_opt.is_empty(), "Lord of the Storm use is offered in end window")
	check(not decline_opt.is_empty(), "Lord of the Storm decline is offered in end window")

	# Decline ability
	var decline_res := LordOfTheStorm.apply(state, 1, decline_opt[0], Callable())
	check(str(decline_res.get("error", "")).is_empty(), "Lord of the Storm declines cleanly")
	check(not bool(state.unit_abilities.used.get("lord-of-the-storm:%d" % imotekh_model, false)), "Declining does not mark once-per-battle as used")

	# In next turn, Lord of the Storm is offered again
	state.turn = 3
	state.unit_abilities.window = {"kind": "end", "owners": [1]}
	check(LordOfTheStorm.available(state, 1), "Lord of the Storm is available again in next Command phase after being declined")

func test_lord_of_the_storm_damage_and_lock() -> void:
	var state: Dictionary = F.P.initial_state({"unit_abilities": true, "reanimation_protocols": true, "combat_doctrines": false, "core_stratagems": true, "manual_allocation": false}, {
		1: {"schema_version": 2, "faction": "Necrons", "category": "custom", "points_limit": 1000, "entries": [
			{"definition_id": IMOTEKH_ID, "models": 1, "copies": 1}
		]},
		2: {"schema_version": 2, "faction": "Space Marines", "category": "custom", "points_limit": 1000, "entries": [
			{"definition_id": MARINE_ID, "models": 5, "copies": 1}
		]}
	})
	if state.has("error"): return

	var imotekh_model := -1
	var marine_squad := -1
	var marine_models: Array[int] = []
	for m: int in state.units:
		var u: Dictionary = state.units[m]
		if str(u.get("definition_id", "")) == IMOTEKH_ID: imotekh_model = m
		elif str(u.get("definition_id", "")) == MARINE_ID:
			marine_models.append(m)
			if marine_squad < 0: marine_squad = int(u.get("squad", -1))

	state.units[imotekh_model].position = Vector2(0.0, 0.0)
	for m: int in marine_models:
		state.units[m].position = Vector2(0.0, 5.0)

	state.phase = "command"
	state.active = 1
	state.turn = 1
	state.unit_abilities.window = {"kind": "end", "owners": [1]}

	# Case 1: D6 roll of 1 -> no damage
	scripted_dice = [1]
	var choice_action := {"action": LordOfTheStorm.ACTION, "model": imotekh_model, "target": -1}
	var res_1 := LordOfTheStorm.resolve(state, 1, choice_action, Callable(self, "scripted_roller"))
	check(res_1.get("complete", false) and res_1.get("error", "").is_empty(), "Roll of 1 completes without mortal wounds")
	check(bool(state.unit_abilities.used.get("lord-of-the-storm:%d" % imotekh_model, false)), "Lord of the Storm is locked once-per-battle")

	# Cannot use again
	check(not LordOfTheStorm.available(state, 1), "Cannot use Lord of the Storm again after use")
	var second_attempt := LordOfTheStorm.resolve(state, 1, choice_action, Callable(self, "scripted_roller"))
	check(not str(second_attempt.get("error", "")).is_empty(), "Second attempt is rejected")

	# Reset used flag for damage calculation tests
	state.unit_abilities.used.erase("lord-of-the-storm:%d" % imotekh_model)

	# Case 2: D6 roll of 3 (in 2-5) -> D3 mortal wounds (roll 4 on D6 -> D3 = 2)
	# D6=3, then D3 die=4 -> D3=2 mortal wounds
	scripted_dice = [3, 4]
	var res_2 := LordOfTheStorm.resolve(state, 1, choice_action, Callable(self, "scripted_roller"))
	check(not res_2.get("complete", true) and str(res_2.get("error", "")).is_empty(), "Roll of 3 creates mortal wound allocation packet")
	check(state.unit_abilities.window.get("kind", "") == LordOfTheStorm.MORTAL_WINDOW, "Window transitioned to MORTAL_WINDOW")
	var pending: Dictionary = state.pending_lord_of_the_storm
	check(pending.packets[0].mortal_wounds == 2, "2 mortal wounds caused on D6=3, D3=2")

	# Allocate mortal wounds
	var alloc_choices := LordOfTheStorm.allocation_choices(state, 2)
	check(not alloc_choices.is_empty(), "Defending player has allocation choices")
	# Allocate 1 mortal wound to marine_models[0]
	var alloc_1 := LordOfTheStorm.allocate(state, 2, alloc_choices[0], Callable(self, "scripted_roller"))
	check(str(alloc_1.get("error", "")).is_empty(), "First mortal wound allocated cleanly")
	check(state.units[marine_models[0]].wounds == 1, "Marine wound reduced from 2 to 1")

	# Allocate 2nd mortal wound to marine_models[0] (destroying it)
	alloc_choices = LordOfTheStorm.allocation_choices(state, 2)
	var alloc_2 := LordOfTheStorm.allocate(state, 2, alloc_choices[0], Callable(self, "scripted_roller"))
	check(str(alloc_2.get("error", "")).is_empty(), "Second mortal wound allocated cleanly")
	check(state.units[marine_models[0]].wounds == 0, "Marine model destroyed")
	check(state.get("pending_lord_of_the_storm", {}).is_empty(), "All mortal wounds allocated; sequence complete")
	check(state.unit_abilities.window.get("kind", "") == "end", "Window returned to resume_window (end)")

	# Case 3: D6 roll of 6 -> D3+3 mortal wounds (roll 2 on D6 -> D3 = 1 -> D3+3 = 4)
	state.unit_abilities.used.erase("lord-of-the-storm:%d" % imotekh_model)
	scripted_dice = [6, 2] # D6=6, D3 roll=2 -> D3=1 + 3 = 4 mortal wounds
	var res_3 := LordOfTheStorm.resolve(state, 1, choice_action, Callable(self, "scripted_roller"))
	check(not res_3.get("complete", true) and str(res_3.get("error", "")).is_empty(), "Roll of 6 creates D3+3 mortal wound packet")
	var pending_3: Dictionary = state.pending_lord_of_the_storm
	check(pending_3.packets[0].mortal_wounds == 4, "4 mortal wounds caused on D6=6, D3=1+3")

func test_reanimation_protocols() -> void:
	var state: Dictionary = F.P.initial_state({"unit_abilities": true, "reanimation_protocols": true, "combat_doctrines": false, "core_stratagems": true, "manual_allocation": false}, {
		1: {"schema_version": 2, "faction": "Necrons", "category": "custom", "points_limit": 1000, "entries": [
			{"definition_id": IMOTEKH_ID, "models": 1, "copies": 1},
			{"definition_id": LYCHGUARD_ID, "models": 5, "copies": 1}
		]},
		2: {"schema_version": 2, "faction": "Space Marines", "category": "custom", "points_limit": 1000, "entries": [
			{"definition_id": MARINE_ID, "models": 5, "copies": 1}
		]}
	})
	if state.has("error"): return

	# 1. Wound map and model size registration
	check(Reanimation.CHARACTER_WOUNDS.get(IMOTEKH_ID) == 6, "Imotekh character wounds is 6")
	check(Reanimation.PROFILE_MODEL_COUNTS.get(IMOTEKH_ID) == [1], "Imotekh profile model count is [1]")

	var imotekh_model := -1
	var lychguard_squad := -1
	for m: int in state.units:
		var u: Dictionary = state.units[m]
		if str(u.get("definition_id", "")) == IMOTEKH_ID: imotekh_model = m
		elif str(u.get("definition_id", "")) == LYCHGUARD_ID and lychguard_squad < 0: lychguard_squad = int(u.get("squad", -1))

	var imotekh_squad := int(state.units[imotekh_model].get("squad", -1))

	# 2. Living single-model character reanimation
	check(Reanimation.supported_unit(state, imotekh_squad), "Imotekh standalone is a supported Reanimation unit")

	# Wound Imotekh to 3 wounds remaining and test healing
	state.units[imotekh_model].wounds = 3
	Reanimation.enable(state)
	state.reanimation.anchors = {imotekh_squad: []}
	state.reanimation.pending = {"player": 1, "remaining": [imotekh_squad], "current": {}, "results": []}
	# Script die roll of 4 (D3 = 2 wounds healed) -> Imotekh should be at 5 wounds
	scripted_dice = []
	var prep := Reanimation._prepare_healing(state, imotekh_squad, 4, Callable(self, "scripted_roller"))
	check(prep.get("error", "").is_empty() and state.units[imotekh_model].wounds == 5, "Reanimation heals wounded Imotekh by 2 wounds (from 3 to 5)")

	# 3. Attached leader reanimation coverage
	UnitActions.attach(state, imotekh_model, lychguard_squad)
	check(Reanimation._supported_attachment(state, lychguard_squad), "Imotekh attached to Lychguard is a supported Reanimation attachment")
