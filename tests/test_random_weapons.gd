extends SceneTree
const Combat = preload("res://scripts/edition_11/combat_scenario.gd")
const A = preload("res://scripts/edition_11/attack_sequence.gd")
var failures := 0
var calls := 0
var values: Array = []
func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1
func roll() -> int:
	calls += 1
	return values.pop_front() if not values.is_empty() else 1
func _initialize() -> void:
	for expression in ["D3", "D6", "2D6+3", 2]:
		check(A.RandomStat.spec(expression).error.is_empty(), "Supported characteristic")
	for expression in ["0D6", "21D6", "D4", "D6-1", "D6+9999", -1, "print(1)"]:
		check(not A.RandomStat.spec(expression).error.is_empty(), "Reject invalid expression")
	values = [1, 2, 3, 4, 5, 6]
	var converted: Array = []
	for index in range(6): converted.append(A.RandomStat.roll("D3", roll).value)
	check(converted == [1, 1, 2, 2, 3, 3], "D3 conversion")
	var w := {"attacks": "D3", "skill": 3, "strength": 4, "ap": 0, "damage": "D6", "keywords": {"blast": 2}}
	for size in [4, 5, 9, 10]:
		values = [1, 6]
		var generated := A.generate_attacks(w, {"weapon_count": 2, "target_model_count": size}, roll)
		check(generated.count == 4 + 4 * floori(float(size) / 5.0) and generated.records.size() == 2, "Blast X and independent A per weapon")
	var state := Combat.initial_state("legacy-solid-v1", "elimination", 1, true)
	state.phase = "shooting"
	for id: int in state.units:
		state.units[id].position = Vector2(-12, -8) if id < 200 else Vector2(-2 + (id - 200), -8)
	state.squads[1].weapon = {"name": "Random", "attacks": 1, "skill": 2, "strength": 10, "ap": -6, "damage": "D6", "range_inches": 30, "keywords": {}}
	for id: int in state.units:
		if id in range(101, 105): state.units[id].wounds = 0
	values = [6, 6, 1]
	calls = 0
	var result := Combat.shoot(state, 1, 100, 200, 0, true, roll)
	check(result.error.is_empty() and calls == 3 and not state.pending_attack.is_empty(), "Damage is not rolled before recipient choice")
	var before := var_to_str(state)
	check(not Combat.allocate_damage(state, 1, 200, state.revision, roll).is_empty() and calls == 3 and var_to_str(state) == before, "Invalid choice reveals no damage")
	values = [0]
	check(not Combat.allocate_damage(state, 2, 200, state.revision, roll).is_empty() and var_to_str(state) == before, "Bad damage die leaves pending choice intact")
	values = [6]
	check(Combat.allocate_damage(state, 2, 200, state.revision, roll).is_empty() and state.units[200].wounds == 0 and state.units[201].wounds == 1, "Random damage does not spill")
	check(state.last_attack.pools[0].allocations[0].rolled_damage == 6, "Damage result persisted")
	state = Combat.initial_state("legacy-solid-v1")
	state.squads[1].weapon.attacks = "D3"
	for id: int in state.units:
		state.units[id].position = Vector2(-12, -8) if id < 200 else Vector2(-2, -8)
	var prepared := Combat.AttackPlan.prepare(state, 1, false, [{"model": 100, "target": 2, "amount": 1}], true)
	check(prepared.error.is_empty() and prepared.batches[0].context.attack_sources[0].expression == "D3", "Ranged random A survives plan preparation")
	w.keywords = {}
	w.attacks = 1
	w.ap = 0
	values = [6, 6, 6]
	calls = 0
	var saved := A.resolve(w, {"toughness": 4, "save_target": 3, "wounds_per_model": 1, "remaining_wounds": [1]}, {}, roll)
	check(saved.error.is_empty() and calls == 3 and saved.damage_rolls.is_empty(), "Successful save never rolls random damage")
	w.keywords = {"unknown-mechanic": true}
	check(not A._validate(w, {"toughness": 4, "save_target": 3, "wounds_per_model": 1, "remaining_wounds": [1]}, {}).is_empty(), "Unsupported keyword stays blocked")
	print("Random weapons: %d failures" % failures)
	quit(1 if failures else 0)

