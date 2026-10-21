extends SceneTree
const P = preload("res://scripts/edition_11/prepared_training.gd")
const C = P.Combat
const S = C.Stratagems
const R = C.Attacks.RandomStat
var values: Array = []
var count := 0
func die() -> int:
	count += 1
	return values.pop_front() if not values.is_empty() else 6
func fixture(manual: bool = false) -> Dictionary:
	var state := C.initial_state("legacy-solid-v1", C.Objectives.TRAINING, 2, manual)
	S.enable(state, false, false, false, true)
	state.phase = "shooting"
	state.cp = {1: 4, 2: 4}
	for id: int in state.units:
		if id not in [100, 200, 201, 300, 400]: state.units[id].wounds = 0
		state.units[id].position = Vector2(-12 if state.units[id].owner == 1 else -2, -8 if id < 300 else 8)
	for id in [200, 201]:
		state.units[id].max_wounds = 10
		state.units[id].wounds = 10
	state.squads[1].weapon = {"name": "Damage checkpoint", "attacks": 1, "skill": 2, "strength": 10, "ap": -6, "damage": "D3+1", "range_inches": 30, "keywords": {}}
	return state
func begin(state: Dictionary) -> void:
	assert(C.shoot(state, 1, 100, 200, state.revision, true, die).error.is_empty())
func react(state: Dictionary, use: bool = false, index: int = 0) -> String:
	return C.resolve_attack_reaction(state, 1, 1, "command-re-roll" if use else "", state.revision, index, die)
func _initialize() -> void: call_deferred("run")
func run() -> void:
	assert(P.initial_state({"damage_rerolls": true}).has("error"))
	assert(P.initial_state({"core_stratagems": true}).pack_hash == P.initial_state({"core_stratagems": true, "damage_rerolls": false}).pack_hash)
	assert(P.initial_state({"core_stratagems": true}).pack_hash != P.initial_state({"core_stratagems": true, "damage_rerolls": true}).pack_hash)
	values = [6, 4, 1]
	var rolled := R.roll("2D3+2", die)
	var replaced := R.replace_die(rolled, 0, die)
	assert(rolled.value == 7 and rolled.rolls == [6, 4] and replaced.value == 5 and replaced.rolls == [1, 4])
	assert(not R.replace_die(replaced, 1, die).error.is_empty())
	var state := fixture(true)
	state.units[200].feel_no_pain = [{"target": 5, "against": "any"}]
	values = [6, 6, 1, 6, 1, 6, 1]
	var start := count
	begin(state)
	assert(count - start == 3 and S.pending(state).is_empty() and C.actor(state) == 2)
	assert(C.allocate_damage(state, 2, 200, state.revision, die).is_empty())
	assert(count - start == 4 and S.pending(state).kind == "after_damage_roll" and C.actor(state) == 1)
	assert(state.pending_attack.current.pending_damage.model == 200 and state.pending_attack.current.pending_damage.rolled.value == 4)
	assert(state.units[200].wounds == 10 and state.pending_attack.current.result.prevention_rolls.is_empty())
	var before := var_to_bytes(state)
	assert(not C.allocate_damage(state, 2, 201, state.revision, die).is_empty())
	assert(not C.resolve_attack_reaction(state, 2, 1, "command-re-roll", state.revision, 0, die).is_empty())
	assert(not C.resolve_attack_reaction(state, 1, 3, "command-re-roll", state.revision, 0, die).is_empty())
	assert(not C.resolve_attack_reaction(state, 1, 1, "command-re-roll", 0, 0, die).is_empty())
	assert(not react(state, true, -1).is_empty() and not react(state, true, 1).is_empty())
	assert(before == var_to_bytes(state) and count - start == 4)
	assert(not C.resolve_attack_reaction(state, 1, 1, "command-re-roll", state.revision, 0, func(): return 7).is_empty())
	assert(before == var_to_bytes(state))
	values = [1, 0]
	assert(not react(state, true).is_empty() and before == var_to_bytes(state))
	# A rejected downstream FNP result cannot confirm CP or the damage replacement.
	values = [1, 6, 1]
	var accepted_start := count
	state = bytes_to_var(var_to_bytes(state))
	assert(react(state, true).is_empty())
	assert(state.cp == {1: 3, 2: 4} and state.pending_attack.is_empty() and state.units[200].wounds == 9 and state.units[201].wounds == 10)
	assert(state.last_command_roll.value == 2 and state.last_attack.pools[0].prevented_wounds == 1)
	assert(state.last_attack.pools[0].dice_history == [6, 6, 1, 6, 1, 6, 1] and count - accepted_start == 3)
	before = var_to_bytes(state)
	assert(not react(state, true).is_empty() and before == var_to_bytes(state))
	# Keeping a result spends no CP and never rolls damage again.
	state = fixture()
	values = [6, 6, 1, 6]
	begin(state)
	start = count
	assert(react(state).is_empty() and count == start and state.units[200].wounds == 6 and state.cp[1] == 4)
	# Fixed damage, no CP, Battle-shock or a phase use never opens this window.
	for reason in ["fixed", "cp", "shock", "phase"]:
		state = fixture()
		if reason == "fixed": state.squads[1].weapon.damage = 2
		if reason == "cp": state.cp[1] = 0
		if reason == "shock": state.squads[1].battle_shocked = true
		if reason == "phase": state.stratagems.uses.append({"player": 1, "squad": 3, "stratagem": "command-re-roll", "phase_key": S.phase_key(state), "turn": state.turn})
		begin(state)
		assert(S.pending(state).is_empty() and state.pending_attack.is_empty())
	# Devastating Wounds use the same random-damage checkpoint before mortal FNP.
	state = fixture()
	state.squads[1].weapon.keywords = {"devastating-wounds": true}
	state.units[200].feel_no_pain = [{"target": 5, "against": "mortal"}]
	values = [6, 6, 6, 1, 6, 1]
	begin(state)
	assert(state.pending_attack.current.steps[0].kind == "devastating" and state.units[200].wounds == 10)
	assert(react(state, true).is_empty() and state.units[200].wounds == 9 and state.last_attack.pools[0].mortal_damage_applied == 1)
	# The real synthetic lab exposes D3 without modifying the starter armies.
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	game.damage_reroll_choice.button_pressed = true
	game._start_allocation_practice()
	assert(game.damage_rerolls and game.core_stratagems and game.state.cp == {1: 2, 2: 2})
	assert(game.state.get("rules_practice", false) and "SYNTHETIC RULES LAB" in game.session_label.tooltip_text)
	game.rng.seed = 42
	game._apply_attack(1, 100, 200, 0, true)
	game._request_skip_precision()
	for attempt in range(15):
		if not S.pending(game.state).is_empty() or game.state.pending_attack.is_empty(): break
		var eligible: Array = C.Allocation.eligible(game.state)
		assert(not eligible.is_empty())
		var identity: Dictionary = game._damage_decision_identity(eligible[0])
		game._apply_allocate_damage(C.actor(game.state), eligible[0], game.state.revision, identity.decision_id, identity.option_id)
	assert(S.pending(game.state).kind == "after_damage_roll" and game.reaction_die.visible and not game.reaction_use.disabled)
	var snapshot := var_to_bytes(game.state)
	var rng_state: int = game.rng.state
	game._save_match()
	game._load_match(false)
	assert(game.damage_rerolls and snapshot == var_to_bytes(game.state) and rng_state == game.rng.state)
	game._request_use_reaction()
	assert(game.state.cp[1] == 1 and game.state.stratagems.uses.size() == 1)
	game.queue_free()
	await process_frame
	print("DAMAGE REROLLS: PASS")
	quit()
