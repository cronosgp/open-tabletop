extends SceneTree

const F = preload("res://tests/all_units_fixture.gd")
const Profiles = preload("res://scripts/edition_11/current_reference_necron_profiles.gd")
const Army = preload("res://scripts/edition_11/army_capabilities.gd")
const Reanimation = preload("res://scripts/edition_11/reanimation_protocols.gd")
const UnitAbilities = preload("res://scripts/edition_11/unit_abilities.gd")
const UnitActions = preload("res://scripts/edition_11/unit_actions.gd")
const Morale = preload("res://scripts/edition_11/morale.gd")
const NecronSavedEquipment = preload("res://scripts/edition_11/necron_saved_equipment.gd")

const CCB_ID := "40kdc:11e:necrons:catacomb-command-barge"
const WARRIORS_ID := "40kdc:11e:necrons:necron-warriors"
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
	if scripted_dice.is_empty(): return 4
	return scripted_dice.pop_front()

func run() -> void:
	test_datasheet_facts_and_admission()
	test_saved_equipment_and_preparation()
	test_carrier_wave_and_quantum_shielding()
	test_resurrection_orb()
	print("Necron Catacomb Command Barge checks: %d failures" % failures)
	await process_frame
	quit(1 if failures else 0)

func test_datasheet_facts_and_admission() -> void:
	var ccb := Profiles.profile("catacomb-command-barge")
	check(ccb.get("source_datasheet_id") == "000000533", "Catacomb Command Barge ID matches 000000533")
	check(ccb.get("points_by_models") == {1: 120}, "Points are 120 for 1 model")
	check(ccb.get("base_size_source_mm") == 60, "Base size is 60 mm")
	check(ccb.get("stats") == {"movement_inches": 10, "toughness": 8, "save_target": 3, "wounds": 9, "leadership_target": 6, "objective_control": 3, "invulnerable_target": 4}, "Stats match source")
	for kw: String in ["NECRONS", "VEHICLE", "CHARACTER", "NOBLE", "FLY", "FRAME", "CATACOMB COMMAND BARGE"]:
		check(kw in ccb.get("keywords", []), "Has %s keyword" % kw)
	check(ccb.get("unsupported_abilities", []).is_empty(), "Unsupported abilities cleared")
	check(ccb.get("pending_source_checks", []).is_empty(), "Pending source checks empty")

	var res := Army.resolve("Necrons", CCB_ID)
	check(res.get("error", "").is_empty(), "Catacomb Command Barge resolves cleanly")
	check(int(res.get("cost", -1)) == 120 and int(res.get("models", -1)) == 1, "Cost is 120, models is 1")
	check(Reanimation.CHARACTER_WOUNDS.get(CCB_ID) == 9, "Reanimation character wounds is 9")
	check(Reanimation.PROFILE_MODEL_COUNTS.get(CCB_ID) == [1], "Reanimation profile model count is [1]")

func test_saved_equipment_and_preparation() -> void:
	check(NecronSavedEquipment.supports(CCB_ID), "NecronSavedEquipment supports Catacomb Command Barge")
	var defs := NecronSavedEquipment.defaults(CCB_ID)
	check(defs == {"ccb_cannon": "gauss-cannon", "ccb_melee": "staff-of-light", "ccb_wargear": "none"}, "Defaults match source")
	check(NecronSavedEquipment.valid(CCB_ID, {"ccb_cannon": "tesla-cannon", "ccb_melee": "overlords-blade", "ccb_wargear": "resurrection-orb"}, 1), "Saved equipment validator accepts custom loadout")
	check(not NecronSavedEquipment.valid(CCB_ID, {"ccb_cannon": "invalid", "ccb_melee": "staff-of-light", "ccb_wargear": "none"}, 1), "Saved equipment validator rejects invalid cannon")

	# Preparation choices in unlocked match
	var state: Dictionary = F.P.initial_state({"unit_abilities": true, "reanimation_protocols": true, "combat_doctrines": false, "core_stratagems": true, "manual_allocation": false}, {
		1: {"schema_version": 2, "faction": "Necrons", "category": "custom", "points_limit": 1000, "entries": [
			{"definition_id": CCB_ID, "models": 1, "copies": 1}
		]},
		2: {"schema_version": 2, "faction": "Space Marines", "category": "custom", "points_limit": 1000, "entries": [
			{"definition_id": MARINE_ID, "models": 5, "copies": 1}
		]}
	})
	if state.has("error"): return
	var ccb_model := -1
	for m: int in state.units:
		if str(state.units[m].get("definition_id", "")) == CCB_ID: ccb_model = m
	var prep := UnitActions.choices(state, 1)
	var cannon_opts := prep.filter(func(c: Dictionary) -> bool: return c.get("action", "") == "necron-ccb-cannon")
	var melee_opts := prep.filter(func(c: Dictionary) -> bool: return c.get("action", "") == "necron-ccb-melee")
	var wargear_opts := prep.filter(func(c: Dictionary) -> bool: return c.get("action", "") == "necron-ccb-wargear")
	check(cannon_opts.size() == 1 and melee_opts.size() == 1 and wargear_opts.size() == 1, "Preparation offers all 3 option switches")
	if not cannon_opts.is_empty(): UnitActions.apply(state, 1, cannon_opts[0], Vector2.ZERO, Callable())
	if not melee_opts.is_empty(): UnitActions.apply(state, 1, melee_opts[0], Vector2.ZERO, Callable())
	if not wargear_opts.is_empty(): UnitActions.apply(state, 1, wargear_opts[0], Vector2.ZERO, Callable())
	check(str(state.units[ccb_model].ranged_weapons[0].get("id", "")) == "tesla-cannon-command-barge", "Tesla cannon applied")
	check(str(state.units[ccb_model].melee_weapons[0].get("id", "")) == "overlords-blade-command-barge", "Overlord's blade applied")
	check("resurrection-orb" in state.units[ccb_model].get("wargear", []), "Resurrection Orb wargear applied")

func test_carrier_wave_and_quantum_shielding() -> void:
	var state: Dictionary = F.P.initial_state({"unit_abilities": true, "reanimation_protocols": true, "combat_doctrines": false, "core_stratagems": true, "manual_allocation": false}, {
		1: {"schema_version": 2, "faction": "Necrons", "category": "custom", "points_limit": 1000, "entries": [
			{"definition_id": CCB_ID, "models": 1, "copies": 1},
			{"definition_id": WARRIORS_ID, "models": 10, "copies": 1}
		]},
		2: {"schema_version": 2, "faction": "Space Marines", "category": "custom", "points_limit": 1000, "entries": [
			{"definition_id": MARINE_ID, "models": 5, "copies": 1}
		]}
	})
	if state.has("error"): return
	var ccb_model := -1
	var ccb_squad := -1
	var warriors_squad := -1
	var warrior_model := -1
	var marine_model := -1
	for m: int in state.units:
		var u: Dictionary = state.units[m]
		var d := str(u.get("definition_id", ""))
		if d == CCB_ID: ccb_model = m; ccb_squad = int(u.get("squad", -1))
		elif d == WARRIORS_ID:
			if warriors_squad < 0: warriors_squad = int(u.get("squad", -1))
			if warrior_model < 0: warrior_model = m
		elif d == MARINE_ID and marine_model < 0: marine_model = m

	state.units[ccb_model].position = Vector2(0.0, 0.0)
	for m: int in state.units:
		if int(state.units[m].get("squad", -1)) == warriors_squad:
			state.units[m].position = Vector2(0.0, 4.0)
	state.units[marine_model].position = Vector2(4.0, 0.0)

	# Carrier Wave: Warriors OC 2 -> 3 within 6"; Marine OC unchanged; Warriors outside 6" -> 2
	check(Morale.objective_control(state, warrior_model) == 3, "Carrier Wave adds +1 OC to friendly Necrons within 6 inches")
	check(Morale.objective_control(state, marine_model) == 2, "Carrier Wave does not affect enemy units")
	for m: int in state.units:
		if int(state.units[m].get("squad", -1)) == warriors_squad:
			state.units[m].position = Vector2(0.0, 12.0)
	check(Morale.objective_control(state, warrior_model) == 2, "Carrier Wave inactive beyond 6 inches")

	# Advanced Quantum Shielding: -1 to Wound when S > T (T=8)
	check(UnitAbilities.defensive_wound_modifier(state, ccb_squad, 9, 8, false) == -1, "Advanced Quantum Shielding gives -1 to Wound when S > T")
	check(UnitAbilities.defensive_wound_modifier(state, ccb_squad, 8, 8, false) == 0, "Advanced Quantum Shielding does not trigger when S <= T")

func test_resurrection_orb() -> void:
	var state: Dictionary = F.P.initial_state({"unit_abilities": true, "reanimation_protocols": true, "combat_doctrines": false, "core_stratagems": true, "manual_allocation": false}, {
		1: {"schema_version": 2, "faction": "Necrons", "category": "custom", "points_limit": 1000, "entries": [
			{"definition_id": CCB_ID, "models": 1, "copies": 1},
			{"definition_id": WARRIORS_ID, "models": 10, "copies": 1}
		]},
		2: {"schema_version": 2, "faction": "Space Marines", "category": "custom", "points_limit": 1000, "entries": [
			{"definition_id": MARINE_ID, "models": 5, "copies": 1}
		]}
	})
	if state.has("error"): return
	var ccb_model := -1
	var warriors_squad := -1
	var warrior_model := -1
	for m: int in state.units:
		var u: Dictionary = state.units[m]
		var d := str(u.get("definition_id", ""))
		if d == CCB_ID: ccb_model = m
		elif d == WARRIORS_ID:
			if warriors_squad < 0: warriors_squad = int(u.get("squad", -1))
			if warrior_model < 0: warrior_model = m

	state.units[ccb_model].position = Vector2(0.0, 0.0)
	for m: int in state.units:
		if int(state.units[m].get("squad", -1)) == warriors_squad:
			state.units[m].position = Vector2(0.0, 4.0)
	# Wound one warrior to 0 so Reanimation can return it
	state.units[warrior_model].wounds = 0

	state.phase = "shooting"
	state.active = 1
	state.turn = 1
	UnitActions.reconcile(state)

	# Without Resurrection Orb equipped -> not available
	check(not UnitActions.orb_available(state, 1), "Resurrection Orb not available when not equipped")

	# Equip Resurrection Orb
	state.units[ccb_model].ccb_wargear = "resurrection-orb"
	state.units[ccb_model].wargear = ["resurrection-orb"]
	check(UnitActions.orb_available(state, 1), "Resurrection Orb available when equipped and Warriors within 6 inches")

	state.unit_abilities.window = {"kind": "end", "owners": [1]}
	var end_choices := UnitActions.choices(state, 1)
	var orb_opts := end_choices.filter(func(c: Dictionary) -> bool: return c.get("action", "") == "orb" and int(c.get("target", -1)) == warriors_squad)
	check(orb_opts.size() == 1, "Resurrection Orb targets friendly Warriors within 6 inches")
	if not orb_opts.is_empty():
		scripted_dice = [4] # D6 = 4 wounds healed
		var orb_res := UnitActions.apply(state, 1, orb_opts[0], Vector2.ZERO, Callable(self, "scripted_roller"))
		check(str(orb_res.get("error", "")).is_empty(), "Resurrection Orb applies cleanly: " + str(orb_res.get("error", "")))
		check(not UnitActions.orb_available(state, 1), "Resurrection Orb cannot be used twice")
