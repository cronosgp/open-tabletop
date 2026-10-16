extends SceneTree
const P = preload("res://scripts/edition_11/prepared_training.gd")
const C = P.Combat
const S = C.Stratagems
var values: Array = []
var count := 0
func die() -> int:
	count += 1
	return values.pop_front() if not values.is_empty() else 6
func fixture(manual: bool = true) -> Dictionary:
	var state := C.initial_state("legacy-solid-v1", C.Objectives.TRAINING, 2, manual)
	S.enable(state, false, false, true)
	state.phase = "shooting"
	state.cp = {1: 4, 2: 4}
	for id: int in state.units:
		if id not in [100, 200, 201, 300, 400]: state.units[id].wounds = 0
		state.units[id].position = Vector2(-12 if state.units[id].owner == 1 else -2, -8 if id < 300 else 8)
	state.squads[1].weapon = {"name": "Save checkpoint", "attacks": 2, "skill": 2, "strength": 10, "ap": 0, "damage": "D3", "range_inches": 30, "keywords": {}}
	return state
func begin(state: Dictionary) -> void:
	assert(C.shoot(state, 1, 100, 200, state.revision, true, die).error.is_empty())
func react(state: Dictionary, use: bool = false, index: int = 0) -> String:
	return C.resolve_attack_reaction(state, 2, 2, "command-re-roll" if use else "", state.revision, index, die)
func _initialize() -> void: call_deferred("run")
func run() -> void:
	assert(P.initial_state({"save_rerolls": true}).has("error"))
	assert(P.initial_state({"core_stratagems": true}).pack_hash == P.initial_state({"core_stratagems": true, "save_rerolls": false}).pack_hash)
	assert(P.initial_state({"core_stratagems": true}).pack_hash != P.initial_state({"core_stratagems": true, "save_rerolls": true}).pack_hash)
	var state := fixture()
	values = [6, 6, 6, 6, 1, 6, 6]
	begin(state)
	assert(count == 6 and S.pending(state).kind == "after_save_roll" and S.pending(state).rolls == [1, 6])
	assert(C.actor(state) == 2 and state.pending_attack.current.steps.is_empty())
	assert(state.pending_attack.current.result.damage_rolls.is_empty() and state.units[200].wounds == 1)
	var before := var_to_bytes(state)
	assert(not C.allocate_damage(state, 2, 200, state.revision, die).is_empty())
	assert(not C.advance_phase(state, 1, state.revision, die).is_empty())
	assert(not C.resolve_attack_reaction(state, 1, 2, "command-re-roll", state.revision, 0, die).is_empty())
	assert(not C.resolve_attack_reaction(state, 2, 4, "command-re-roll", state.revision, 0, die).is_empty())
	assert(not C.resolve_attack_reaction(state, 2, 2, "command-re-roll", 0, 0, die).is_empty())
	assert(not react(state, true, -1).is_empty() and not react(state, true, 2).is_empty())
	assert(before == var_to_bytes(state) and count == 6)
	assert(not C.resolve_attack_reaction(state, 2, 2, "command-re-roll", state.revision, 0, func(): return 0).is_empty())
	assert(before == var_to_bytes(state))
	state = bytes_to_var(var_to_bytes(state))
	assert(react(state, true).is_empty() and count == 7)
	assert(state.cp == {1: 4, 2: 3} and state.pending_attack.is_empty() and state.squads[1].shot)
	assert(state.last_attack.pools[0].save_rolls == [6, 6] and state.last_attack.pools[0].save_rerolls == [{"index": 0, "original": 1, "replacement": 6}])
	assert(state.last_attack.pools[0].dice_history == [6, 6, 6, 6, 1, 6, 6] and state.units[200].wounds == 1)
	before = var_to_bytes(state)
	assert(not react(state, true).is_empty() and before == var_to_bytes(state))
	assert(C.shoot(state, 1, 300, 400, state.revision, true, die).error.is_empty())
	assert(S.pending(state).is_empty() and state.cp[2] == 3)
	# A worse replacement is sorted before damage; recipient/damage remain pending.
	state = fixture()
	values = [6, 6, 6, 6, 6, 6, 1, 2]
	begin(state)
	var start := count
	assert(react(state, true, 1).is_empty() and count == start + 1)
	assert(state.last_command_roll.rolls == [6, 1] and state.pending_attack.current.result.save_rolls == [1, 6])
	assert(state.pending_attack.current.steps[0].save_roll == 1 and state.pending_attack.current.result.damage_rolls.is_empty())
	assert(C.allocate_damage(state, 2, 201, state.revision, die).is_empty())
	assert(state.units[201].wounds == 0 and state.units[200].wounds == 1 and state.pending_attack.is_empty())
	assert(state.last_attack.pools[0].damage_rolls[0].rolls == [2] and state.cp[2] == 3)
	# Accepting is free and cannot reopen the same save batch.
	state = fixture()
	values = [6, 6, 6, 6, 1, 6]
	begin(state)
	start = count
	assert(react(state).is_empty() and count == start and state.cp[2] == 4 and state.stratagems.uses.is_empty())
	assert(not react(state, true).is_empty() and count == start)
	# Sorting happens after replacement, before mixed-profile groups take damage.
	state = fixture(false)
	state.units[200].defense = {"save_target": 2}
	state.units[201].defense = {"save_target": 6}
	values = [6, 6, 6, 6, 2, 6, 1, 1, 1]
	begin(state)
	assert(S.pending(state).rolls == [2, 6] and state.units[200].wounds == 1 and state.units[201].wounds == 1)
	assert(react(state, true, 1).is_empty())
	assert(state.units[200].wounds == 0 and state.units[201].wounds == 0 and state.last_attack.pools[0].save_rolls == [1, 2])
	# Invulnerable saves still apply to the replacement despite high AP.
	state = fixture(false)
	state.squads[1].weapon.ap = -6
	for id in [200, 201]: state.units[id].defense = {"save_target": 7, "invulnerable_target": 4}
	values = [6, 6, 6, 6, 3, 4, 4]
	begin(state)
	assert(react(state, true).is_empty())
	assert(state.pending_attack.is_empty() and state.units[200].wounds == 1 and state.units[201].wounds == 1)
	# No CP, Battle-shock and a phase use by the defender suppress the window.
	for reason in ["cp", "shock", "phase"]:
		state = fixture()
		if reason == "cp": state.cp[2] = 0
		if reason == "shock": state.squads[2].battle_shocked = true
		if reason == "phase": state.stratagems.uses.append({"player": 2, "squad": 4, "stratagem": "command-re-roll", "phase_key": S.phase_key(state), "turn": state.turn})
		begin(state)
		assert(S.pending(state).is_empty())
	# Mortal packets from Devastating Wounds generate no saving dice/window.
	state = fixture(false)
	state.squads[1].weapon.keywords = {"devastating-wounds": true}
	begin(state)
	assert(S.pending(state).is_empty() and state.pending_attack.is_empty() and state.last_attack.pools[0].save_rolls.is_empty())
	# Both sides can use Command Re-roll in the same phase, once each.
	state = fixture(false)
	state.stratagems.attack_rerolls = true
	values = [6, 6, 6, 6, 6, 1, 6, 6]
	begin(state)
	assert(S.pending(state).player == 1)
	assert(C.resolve_attack_reaction(state, 1, 1, "command-re-roll", state.revision, 0, die).is_empty())
	assert(S.pending(state).kind == "after_save_roll" and S.pending(state).player == 2)
	assert(react(state, true).is_empty() and state.cp == {1: 3, 2: 3} and state.stratagems.uses.size() == 2)
	# UI/save restores a defender decision with the original dice and exact RNG.
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	game.save_reroll_choice.button_pressed = true
	game.defender_choice.button_pressed = false
	game._start_prepared_match()
	assert(game.save_rerolls and game.core_stratagems and not game.attack_rerolls)
	game.state.phase = "shooting"
	game.state.cp = {1: 4, 2: 4}
	for id: int in game.state.units:
		if id not in [100, 200, 300, 400]: game.state.units[id].wounds = 0
		game.state.units[id].position = Vector2(-12 if game.state.units[id].owner == 1 else -2, -8 if id < 300 else 8)
	game.state.squads[1].weapon = {"name": "UI save", "attacks": 2, "skill": 2, "strength": 10, "ap": 0, "damage": "D3", "range_inches": 30, "keywords": {}}
	var probe := RandomNumberGenerator.new()
	for candidate in range(1, 1000):
		probe.seed = candidate
		if probe.randi_range(1, 6) >= 5 and probe.randi_range(1, 6) >= 5 and probe.randi_range(1, 6) >= 5 and probe.randi_range(1, 6) >= 5:
			game.rng.seed = candidate
			break
	game._apply_attack(1, 100, 200, game.state.revision, true)
	assert(S.pending(game.state).kind == "after_save_roll" and game._local_player() == 2)
	assert(game.reaction_die.visible and game.reaction_die.item_count == 2 and not game.reaction_use.disabled)
	var snapshot := var_to_bytes(game.state)
	var rng_state: int = game.rng.state
	game._save_match()
	game._load_match(false)
	assert(game.save_rerolls and snapshot == var_to_bytes(game.state) and rng_state == game.rng.state)
	game._request_use_reaction()
	assert(game.state.cp[2] == 3 and game.state.stratagems.uses.size() == 1)
	game.queue_free()
	await process_frame
	print("SAVE REROLLS: PASS")
	quit()
