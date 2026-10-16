extends SceneTree
const P = preload("res://scripts/edition_11/prepared_training.gd")
const C = P.Combat
const S = C.Stratagems
var values: Array = []
var count := 0
func die() -> int:
	count += 1
	return values.pop_front() if not values.is_empty() else 6
func fixture() -> Dictionary:
	var state := C.initial_state("legacy-solid-v1", C.Objectives.TRAINING, 2, false, true)
	S.enable(state, false, false, false, false, true)
	state.phase = "shooting"
	state.cp = {1: 4, 2: 4}
	for id: int in state.units:
		if id not in [100, 101, 200, 201, 400]: state.units[id].wounds = 0
		state.units[id].position = Vector2(-12 if state.units[id].owner == 1 else -2, -8 + (id % 100) * 1.5)
	return state
func begin(state: Dictionary) -> void:
	assert(C.resolve_attack_plan(state, 1, 100, [{"model": 100, "target": 2, "weapon": "plasma", "profile": "supercharge", "amount": 1}], state.revision, false, true, die).error.is_empty())
func react(state: Dictionary, use: bool = false, index: int = 0) -> String:
	return C.resolve_hazard_reaction(state, 1, 1, "command-re-roll" if use else "", state.revision, index, die)
func _initialize() -> void: call_deferred("run")
func run() -> void:
	assert(P.initial_state({"hazard_rerolls": true}).has("error"))
	assert(P.initial_state({"core_stratagems": true}).pack_hash == P.initial_state({"core_stratagems": true, "hazard_rerolls": false}).pack_hash)
	assert(P.initial_state({"core_stratagems": true}).pack_hash != P.initial_state({"core_stratagems": true, "hazard_rerolls": true}).pack_hash)
	var state := fixture()
	values = [1, 1, 6]
	begin(state)
	assert(count == 2 and S.pending(state).kind == "after_hazardous_roll" and not state.squads[1].shot)
	assert(state.units[100].wounds == 2 and state.pending_hazard.resolved.hazardous.allocations.is_empty())
	var before := var_to_bytes(state)
	assert(not C.allocate_hazard(state, 1, 100, state.revision, die).is_empty())
	assert(not C.advance_phase(state, 1, state.revision, die).is_empty())
	assert(not C.resolve_hazard_reaction(state, 2, 1, "command-re-roll", state.revision, 0, die).is_empty())
	assert(not C.resolve_hazard_reaction(state, 1, 3, "command-re-roll", state.revision, 0, die).is_empty())
	assert(not C.resolve_hazard_reaction(state, 1, 1, "command-re-roll", 0, 0, die).is_empty())
	assert(not react(state, true, 1).is_empty() and count == 2 and before == var_to_bytes(state))
	assert(not C.resolve_hazard_reaction(state, 1, 1, "command-re-roll", state.revision, 0, func(): return 7).is_empty())
	assert(before == var_to_bytes(state))
	state = bytes_to_var(var_to_bytes(state))
	assert(react(state, true).is_empty() and state.cp[1] == 3 and state.pending_hazard.is_empty() and state.squads[1].shot)
	assert(state.last_attack.hazardous.rolls == [6] and state.last_attack.hazardous.rerolls == [{"index": 0, "original": 1, "replacement": 6}])
	assert(not react(state, true).is_empty() and count == 3)
	# All-pass results can become failures; no FNP is rolled until allocation.
	state = fixture()
	state.units[100].feel_no_pain = [{"target": 5, "against": "mortal"}]
	values = [1, 6, 1, 6]
	var start := count
	begin(state)
	assert(state.pending_hazard.remaining == 0 and not S.pending(state).is_empty())
	assert(react(state, true).is_empty() and count - start == 3 and state.pending_hazard.remaining == 1)
	assert(state.units[100].wounds == 2 and state.pending_hazard.resolved.hazardous.get("prevention", []).is_empty())
	assert(C.allocate_hazard(state, 1, 100, state.revision, die).is_empty())
	assert(count - start == 4 and state.units[100].wounds == 2 and state.last_attack.hazardous.prevention[0].prevented == 1)
	# Accepting the batch is free and does not reroll the original dice.
	state = fixture()
	values = [1, 2]
	begin(state)
	start = count
	assert(react(state).is_empty() and count == start and state.cp[1] == 4 and state.pending_hazard.remaining == 1)
	assert(not react(state, true).is_empty())
	assert(C.allocate_hazard(state, 1, 101, state.revision, die).is_empty() and state.squads[1].shot)
	# Heavy-unit multiplier is recalculated without selecting a recipient early.
	state = fixture()
	state.units[100].keywords = ["VEHICLE"]
	state.units[101].keywords = ["MONSTER"]
	values = [1, 6, 1]
	begin(state)
	assert(react(state, true).is_empty() and state.pending_hazard.remaining == 3 and state.pending_hazard.resolved.hazardous.failures == 1)
	# Only the selected die changes in a multi-weapon batch.
	state = fixture()
	state.units[101].ranged_weapons.append(state.units[100].ranged_weapons[1].duplicate(true))
	values = [1, 1, 1, 2, 6]
	var rows := [{"model": 100, "target": 2, "weapon": "plasma", "profile": "supercharge", "amount": 1}, {"model": 101, "target": 2, "weapon": "plasma", "profile": "supercharge", "amount": 1}]
	assert(C.resolve_attack_plan(state, 1, 100, rows, 0, false, true, die).error.is_empty())
	assert(S.pending(state).rolls == [1, 2] and react(state, true, 1).is_empty())
	assert(state.pending_hazard.resolved.hazardous.rolls == [1, 6] and state.pending_hazard.remaining == 1)
	assert(C.allocate_hazard(state, 1, 101, state.revision, die).is_empty() and state.last_attack.hazardous.rolls == [1, 6])
	# Manual defender allocation completes before the weapon owner's hazard choice.
	state = fixture()
	state.manual_allocation = true
	values = [6, 6, 1, 1, 6]
	begin(state)
	assert(not state.pending_attack.is_empty() and S.pending(state).is_empty())
	assert(C.allocate_damage(state, 2, 200, state.revision, die).is_empty())
	assert(state.units[200].wounds == 0 and S.pending(state).kind == "after_hazardous_roll")
	assert(react(state, true).is_empty() and state.pending_hazard.is_empty() and state.squads[1].shot)
	for reason in ["cp", "shock", "phase"]:
		state = fixture()
		if reason == "cp": state.cp[1] = 0
		if reason == "shock": state.squads[1].battle_shocked = true
		if reason == "phase": state.stratagems.uses.append({"player": 1, "squad": 3, "stratagem": "command-re-roll", "phase_key": S.phase_key(state), "turn": state.turn})
		values = [1, 1]
		begin(state)
		assert(S.pending(state).is_empty() and state.pending_hazard.remaining == 1)
	# Real prepared mode, curated plasma, save and UI decision.
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	game.hazard_reroll_choice.button_pressed = true
	game.equipment_choice.button_pressed = true
	game._start_prepared_match()
	game.state.phase = "shooting"
	game.state.cp[1] = 2
	for id: int in game.state.units:
		if id not in [100, 200, 300, 400]: game.state.units[id].wounds = 0
		game.state.units[id].position = Vector2(-12 if game.state.units[id].owner == 1 else -2, -8 if id < 300 else 8)
	game._apply_attack_plan(1, 100, [{"model": 100, "target": 2, "weapon": "plasma", "profile": "supercharge", "amount": 1}], 0, false, true)
	assert(S.pending(game.state).kind == "after_hazardous_roll" and game.reaction_die.visible and not game.reaction_use.disabled)
	var snapshot := var_to_bytes(game.state)
	var rng_state: int = game.rng.state
	game._save_match()
	game._load_match(false)
	assert(game.hazard_rerolls and snapshot == var_to_bytes(game.state) and rng_state == game.rng.state)
	game._request_use_reaction()
	assert(game.state.cp[1] == 1 and game.state.stratagems.uses.size() == 1)
	game.queue_free()
	await process_frame
	print("HAZARDOUS REROLLS: PASS")
	quit()
