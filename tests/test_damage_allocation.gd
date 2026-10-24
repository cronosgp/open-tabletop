extends SceneTree
const Combat = preload("res://scripts/edition_11/combat_scenario.gd")
const MatchCommands = preload("res://scripts/edition_11/match_command_service.gd")
var failures := 0
var calls := 0
var values: Array[int] = []
func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1
func six() -> int:
	calls += 1
	return 6
func supplied() -> int:
	calls += 1
	return values.pop_front() if not values.is_empty() else 0
func fixture(attacks: int = 3, damage: int = 1) -> Dictionary:
	var state := Combat.initial_state("legacy-solid-v1", Combat.Objectives.TRAINING, 2, true)
	for id: int in state.units:
		if id not in [100, 200, 201, 202, 400]: state.units[id].wounds = 0
	state.units[100].position = Vector2(-12, -8)
	state.units[200].position = Vector2(-2, -8)
	state.units[201].position = Vector2(0, -8)
	state.units[202].position = Vector2(2, -8)
	state.units[400].position = Vector2(5, -8)
	state.phase = "shooting"
	state.squads[2].stats.wounds = 2
	for id in [200, 201, 202]:
		state.units[id].wounds = 2
		state.units[id].max_wounds = 2
	state.squads[1].weapon = {"name": "Allocation test", "attacks": attacks, "skill": 2, "strength": 10, "ap": -6, "damage": damage, "range_inches": 30, "keywords": {}}
	return state
func begin(state: Dictionary, roller: Callable = six) -> Dictionary:
	return Combat.shoot(state, 1, 100, 200, state.revision, true, roller)
func allocate(state: Dictionary, model: int) -> String:
	var decision := Combat.Allocation.pending_decision(state)
	var option_id := ""
	for option: Dictionary in decision.get("legal_options", []):
		if int(option.get("model", -1)) == model: option_id = str(option.get("id", "")); break
	var result := MatchCommands.execute(state, Combat.actor(state), {"kind": MatchCommands.ALLOCATE_DAMAGE, "model": model, "revision": state.revision, "decision_id": str(decision.get("decision_id", "")), "option_id": option_id}, six)
	return str(result.get("error", ""))
func _initialize() -> void:
	var state := fixture()
	check(state.pack_hash != Combat.initial_state("legacy-solid-v1", Combat.Objectives.TRAINING, 2).pack_hash, "Allocation mode participates in compatibility hash")
	check(begin(state).error.is_empty() and Combat.actor(state) == 2 and not state.squads[1].shot and state.units[201].wounds == 2, "Attack pauses after rolls, before damage/activation, for defender")
	var allocation_decision := Combat.Allocation.pending_decision(state)
	var projected_models: Array[int] = []
	for option: Dictionary in allocation_decision.get("legal_options", []):
		projected_models.append(int(option.model))
	check(not allocation_decision.is_empty() and allocation_decision.priority_player_id == 2 and projected_models == [200, 201, 202], "Damage allocation exposes current defenders and priority through the shared decision projection")
	var allocation_decision_id: String = allocation_decision.decision_id
	state = bytes_to_var(var_to_bytes(state))
	allocation_decision = Combat.Allocation.pending_decision(state)
	check(allocation_decision.get("decision_id", "") == allocation_decision_id and allocation_decision.get("priority_player_id", -1) == 2 and allocation_decision.get("legal_options", []).size() == 3 and Combat.actor(state) == 2, "Serialized damage-allocation decision retains its identity, legal models and defender priority")
	var interrupted_allocation: Dictionary = state.duplicate(true)
	interrupted_allocation.pending_deadly_demise = {"queue": [100], "queue_cursor": 0, "packets": [], "packet_cursor": 0}
	var interrupted_decision := Combat.Allocation.pending_decision(interrupted_allocation)
	var interrupted_option: Dictionary = interrupted_decision.legal_options[0]
	var interrupted_before := var_to_str(interrupted_allocation)
	var interrupted_result := MatchCommands.execute(interrupted_allocation, Combat.actor(interrupted_allocation), {"kind": MatchCommands.ALLOCATE_DAMAGE, "model": int(interrupted_option.model), "revision": interrupted_allocation.revision, "decision_id": str(interrupted_decision.decision_id), "option_id": str(interrupted_option.id)}, six)
	check("destruction effects" in interrupted_result.error and interrupted_before == var_to_str(interrupted_allocation), "Damage allocation cannot bypass a pending destruction chain with a missing decision projection")
	var unrelated_unit_choice := MatchCommands.execute(interrupted_allocation, Combat.actor(interrupted_allocation), {"kind": MatchCommands.SELECT_UNIT_CHOICE, "choice": {"action": "pass"}, "revision": interrupted_allocation.revision}, six)
	check("destruction effects" in unrelated_unit_choice.error and interrupted_before == var_to_str(interrupted_allocation), "The unit-choice dispatcher also blocks when destruction work has no projected choice")
	var before := var_to_str(state)
	var rolled := calls
	check(not Combat.advance_phase(state, 2, state.revision).is_empty() and before == var_to_str(state), "Defender cannot advance phase while allocating")
	check(not Combat.allocate_damage(state, 1, 201, state.revision, six).is_empty() and before == var_to_str(state), "Attacker cannot allocate opponent damage")
	check(not Combat.allocate_damage(state, 2, 400, state.revision, six).is_empty() and before == var_to_str(state), "Wrong target unit rejected")
	check(not Combat.allocate_damage(state, 2, 201, -1, six).is_empty() and before == var_to_str(state) and calls == rolled, "Stale choice rejected without rerolling")
	var missing_identity := MatchCommands.execute(state, 2, {"kind": MatchCommands.ALLOCATE_DAMAGE, "model": 201, "revision": state.revision}, six)
	check(not missing_identity.error.is_empty() and before == var_to_str(state) and calls == rolled, "A projected damage allocation rejects a missing decision identity without mutation")
	check(allocate(state, 201).is_empty() and state.units[201].wounds == 1 and state.units[200].wounds == 2, "Defender chooses a model other than lowest ID")
	check(Combat.Allocation.eligible(state) == [201], "Wounded model becomes mandatory")
	before = var_to_str(state)
	check(not allocate(state, 200).is_empty() and before == var_to_str(state), "Cannot spread damage over healthy models")
	check(allocate(state, 201).is_empty() and state.units[201].wounds == 0 and Combat.Allocation.eligible(state) == [200, 202], "Choose freely again after wounded model destroyed")
	check(allocate(state, 202).is_empty() and state.pending_attack.is_empty() and state.squads[1].shot and state.units[202].wounds == 1 and Combat.actor(state) == 1, "Last choice completes attack once and restores acting player")
	check(state.last_attack.pools[0].allocations[0].model == 201 and state.last_attack.pools[0].damage_applied == 3 and state.last_attack.pools[0].models_destroyed == 1, "Result records exact model choices and damage")
	before = var_to_str(state)
	check(not allocate(state, 200).is_empty() and before == var_to_str(state), "Finished attack cannot allocate twice")
	state = fixture(2, 5)
	begin(state)
	allocate(state, 202)
	allocate(state, 200)
	check(state.units[202].wounds == 0 and state.units[200].wounds == 0 and state.units[201].wounds == 2 and state.last_attack.pools[0].excess_damage_discarded == 6, "Excess damage never spills into another model")
	state = fixture(1)
	state.squads[1].weapon.ap = 0
	check(begin(state).error.is_empty() and state.pending_attack.is_empty() and state.squads[1].shot and state.last_attack.pools[0].damage_applied == 0, "All successful saves complete automatically")
	state = fixture(3)
	state.squads[1].weapon.ap = 0
	values = [6, 6, 6, 6, 6, 6, 5, 1, 3]
	check(begin(state, supplied).error.is_empty() and state.pending_attack.current.failed_rolls == [1, 3], "Failed saves offered lowest first, successful saves skipped")
	state = fixture(1)
	state.units[201].wounds = 1
	begin(state)
	check(Combat.Allocation.eligible(state) == [201], "Existing wounded-model priority preserved")
	state = fixture(1)
	state.units[101].wounds = 2
	state.units[101].position = Vector2(-10, -8)
	var plan := [{"model": 100, "target": 2, "amount": 1}, {"model": 101, "target": 4, "amount": 1}]
	check(Combat.resolve_attack_plan(state, 1, 100, plan, 0, false, true, six).error.is_empty(), "Begin multi-target pending attack")
	before = var_to_str(state)
	check(not Combat.allocate_damage(state, 2, 201, state.revision, func(): return 0).is_empty() and before == var_to_str(state), "Later-pool dice failure rejects last choice transaction without losing previous state")
	check(allocate(state, 201).is_empty() and state.pending_attack.current.target == 4 and not state.squads[1].shot, "Next target rolls only after first pool allocated")
	check(allocate(state, 400).is_empty() and state.pending_attack.is_empty() and state.last_attack.targets == [2, 4], "All target allocations complete one attack plan")
	state = fixture(3)
	state.phase = "fight"
	state.fight_step = "consolidation_reaction"
	state.fight_actor = 1
	state.reaction_queue = [1]
	state.squads[1].fight_eligible = true
	state.units[100].position = Vector2(-4, -8)
	state.squads[1].melee_weapon = state.squads[1].weapon.duplicate(true)
	check(Combat.fight(state, 1, 100, 200, 0, six).error.is_empty() and state.reaction_queue == [1], "Reaction remains pending while defender allocates melee damage")
	allocate(state, 201)
	allocate(state, 201)
	allocate(state, 200)
	check(state.pending_attack.is_empty() and state.squads[1].fought and state.reaction_queue.is_empty(), "Reaction queue resumes only after final allocation")
	print("Defender allocation checks: %d failures" % failures)
	quit(0 if failures == 0 else 1)
