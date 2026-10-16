extends SceneTree
const Combat = preload("res://scripts/edition_11/combat_scenario.gd")
var failures := 0
var dice_calls := 0
var dice_values: Array[int] = []
func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1
func six() -> int:
	dice_calls += 1
	return 6
func supplied() -> int:
	dice_calls += 1
	return dice_values.pop_front() if not dice_values.is_empty() else 0
func fixture(melee: bool) -> Dictionary:
	var state := Combat.initial_state("legacy-solid-v1", Combat.Objectives.TRAINING, 2)
	for id: int in state.units:
		if id not in [100, 101, 200, 400]: state.units[id].wounds = 0
	state.units[100].position = Vector2(-8, -8)
	state.units[101].position = Vector2(-8, -6)
	state.units[200].position = Vector2(-6, -8)
	state.units[400].position = Vector2(-6, -6)
	state.phase = "fight" if melee else "shooting"
	state.fight_step = "attacks"
	state.fight_actor = 1
	state.squads[1].charged = melee
	if not melee:
		state.units[100].position = Vector2(-12, -8)
		state.units[101].position = Vector2(-10, -8)
		state.units[200].position = Vector2(-2, -8)
		state.units[400].position = Vector2(1, -8)
	return state
func melee_plan() -> Array:
	return [{"model": 100, "target": 4, "amount": 2}, {"model": 100, "target": 2, "amount": 1}, {"model": 101, "target": 2, "amount": 2}, {"model": 101, "target": 4, "amount": 1}]
func ranged_plan() -> Array:
	return [{"model": 100, "target": 4, "amount": 1}, {"model": 101, "target": 2, "amount": 1}]
func resolve(state: Dictionary, entries: Array, melee: bool) -> Dictionary:
	return Combat.resolve_attack_plan(state, 1, 100, entries, state.revision, melee, true, six)
func _initialize() -> void:
	var state := fixture(true)
	check(state.squads[1].melee_weapon.attacks == 3, "Melee fixture uses three attacks per model")
	var result := resolve(state, melee_plan(), true)
	check(result.error.is_empty() and result.pools.size() == 2 and result.pools[0].target_squad == 4 and result.pools[1].target_squad == 2, "Resolve all pools for declared targets in player order")
	check(result.pools[0].attacks == 3 and result.pools[1].attacks == 3 and state.squads[1].fought and state.last_attack.assignments == melee_plan(), "Split melee conserves all attacks and records assignments")
	var before := var_to_str(state)
	check(not resolve(state, melee_plan(), true).error.is_empty() and before == var_to_str(state), "Multi-target attack consumes one fight activation")
	for invalid in [[], [{"model": 100, "target": 2, "amount": 3}], [{"model": 100, "target": 2, "amount": 4}], [{"model": 100, "target": 2, "amount": 0}], [{"model": 100, "target": 2, "amount": 1.0}], [{"model": 200, "target": 2, "amount": 1}], ["bad"]]:
		state = fixture(true)
		before = var_to_str(state)
		dice_calls = 0
		check(not resolve(state, invalid, true).error.is_empty() and before == var_to_str(state) and dice_calls == 0, "Malformed/incomplete melee rejected before dice: " + str(invalid))
	state = fixture(true)
	var plan := melee_plan()
	plan.append(plan[0].duplicate())
	dice_calls = 0
	check(not resolve(state, plan, true).error.is_empty() and dice_calls == 0, "Duplicate rows rejected")
	state = fixture(false)
	result = resolve(state, ranged_plan(), false)
	check(result.error.is_empty() and state.squads[1].shot and state.squads[1].last_ranged_turn == state.turn and result.pools.size() == 2, "Two guns target different units and consume one shooting activation")
	state = fixture(false)
	plan = ranged_plan()
	plan.append({"model": 100, "target": 2, "amount": 1})
	dice_calls = 0
	check(not resolve(state, plan, false).error.is_empty() and dice_calls == 0, "One ranged weapon cannot split across targets")
	state = fixture(false)
	check(resolve(state, [{"model": 100, "target": 2, "amount": 1}], false).error.is_empty(), "Ranged model may choose not to shoot")
	state = fixture(false)
	state.squads[4].stats.toughness = -1
	before = var_to_str(state)
	dice_calls = 0
	check(not resolve(state, ranged_plan(), false).error.is_empty() and dice_calls == 0 and before == var_to_str(state), "Invalid later defender rejected before any pool rolls")
	state = fixture(false)
	state.squads[1].weapon.attacks = 1
	state.squads[1].weapon.keywords = {}
	dice_values = [6, 6, 6, 0]
	before = var_to_str(state)
	result = Combat.resolve_attack_plan(state, 1, 100, ranged_plan(), 0, false, true, supplied)
	check(not result.error.is_empty() and before == var_to_str(state), "Bad dice in later pool roll back all damage, activation and history")
	state = fixture(true)
	state.units[400].position = Vector2(8, 8)
	dice_calls = 0
	check(not resolve(state, melee_plan(), true).error.is_empty() and dice_calls == 0, "Melee target must engage each assigning model")
	state = fixture(false)
	state.units[400].position = Vector2(14, 8)
	dice_calls = 0
	check(not resolve(state, ranged_plan(), false).error.is_empty() and dice_calls == 0, "Out-of-range target invalidates whole plan")
	state = fixture(false)
	before = var_to_str(state)
	check(not Combat.resolve_attack_plan(state, 2, 100, ranged_plan(), 0, false, true, six).error.is_empty() and before == var_to_str(state), "Wrong owner cannot resolve plan")
	check(not Combat.resolve_attack_plan(state, 1, 100, ranged_plan(), -1, false, true, six).error.is_empty() and before == var_to_str(state), "Stale plan rejected")
	state = fixture(false)
	state.units[100].position = Vector2(-5, -8)
	state.units[101].position = Vector2(-10, -8)
	state.units[200].position = Vector2(0, -8)
	state.units[201].wounds = 1
	state.units[201].position = Vector2(1, -8)
	state.units[202].wounds = 1
	state.units[202].position = Vector2(6, -8)
	state.squads[1].weapon = {"name": "Snapshot test", "attacks": 1, "skill": 2, "strength": 10, "ap": -6, "damage": 1, "range_inches": 12, "keywords": {"rapid-fire": 1}}
	result = resolve(state, [{"model": 100, "target": 2, "amount": 1}, {"model": 101, "target": 2, "amount": 1}], false)
	check(result.error.is_empty() and result.pools.size() == 2 and result.pools[0].attacks == 2 and result.pools[1].attacks == 1 and state.units[202].wounds == 0, "Range/Rapid Fire snapshot remains valid after front casualties move surviving unit out of range")
	state = fixture(false)
	state.squads[1].weapon = {"name": "No redirect", "attacks": 1, "skill": 2, "strength": 10, "ap": -6, "damage": 1, "range_inches": 30, "keywords": {}}
	result = resolve(state, [{"model": 100, "target": 2, "amount": 1}, {"model": 101, "target": 2, "amount": 1}], false)
	check(result.error.is_empty() and state.units[200].wounds == 0 and state.units[400].wounds == 1, "Excess attacks against a destroyed target never redirect to another unit")
	print("Attack plan checks: %d failures" % failures)
	quit(0 if failures == 0 else 1)
