extends SceneTree
const P = preload("res://scripts/edition_11/prepared_training.gd")
const C = P.Combat
const S = C.Stratagems
const W = C.Allocation.RollWindows
var values: Array = []
var count := 0
func die() -> int:
	count += 1
	return values.pop_front() if not values.is_empty() else 1
func fixture() -> Dictionary:
	var state := C.initial_state("legacy-solid-v1", C.Objectives.TRAINING, 2)
	S.enable(state, false, false, false, false, false, true)
	state.phase = "shooting"
	state.cp = {1: 4, 2: 4}
	for id: int in state.units:
		if id not in [100, 200, 201, 300, 400]: state.units[id].wounds = 0
		state.units[id].position = Vector2(-12 if state.units[id].owner == 1 else -2, -8 if id < 300 else 8)
	state.squads[1].weapon = {"name": "Count checkpoint", "attacks": "D3+1", "skill": 2, "strength": 10, "ap": -6, "damage": 1, "range_inches": 30, "keywords": {}}
	return state
func begin(state: Dictionary) -> void:
	assert(C.shoot(state, 1, 100, 200, state.revision, true, die).error.is_empty())
func react(state: Dictionary, use: bool = false, index: int = 0) -> String:
	return C.resolve_attack_reaction(state, 1, 1, "command-re-roll" if use else "", state.revision, index, die)
func _initialize() -> void: call_deferred("run")
func run() -> void:
	assert(P.initial_state({"count_rerolls": true}).has("error"))
	assert(P.initial_state({"core_stratagems": true}).pack_hash == P.initial_state({"core_stratagems": true, "count_rerolls": false}).pack_hash)
	assert(P.initial_state({"core_stratagems": true}).pack_hash != P.initial_state({"core_stratagems": true, "count_rerolls": true}).pack_hash)
	var state := fixture()
	values = [6, 1, 1, 1]
	begin(state)
	assert(count == 1 and S.pending(state).kind == "after_attack_count_roll" and S.pending(state).total == 4)
	assert(state.pending_attack.current.checkpoint.hit_rolls.is_empty() and state.units[200].wounds == 1)
	var before := var_to_bytes(state)
	assert(not C.allocate_damage(state, 2, 200, state.revision, die).is_empty())
	assert(not C.advance_phase(state, 1, state.revision, die).is_empty())
	assert(not C.resolve_attack_reaction(state, 2, 1, "command-re-roll", state.revision, 0, die).is_empty())
	assert(not C.resolve_attack_reaction(state, 1, 3, "command-re-roll", state.revision, 0, die).is_empty())
	assert(not C.resolve_attack_reaction(state, 1, 1, "command-re-roll", 0, 0, die).is_empty())
	assert(not react(state, true, 1).is_empty() and before == var_to_bytes(state) and count == 1)
	assert(not C.resolve_attack_reaction(state, 1, 1, "command-re-roll", state.revision, 0, func(): return 0).is_empty() and before == var_to_bytes(state))
	state = bytes_to_var(var_to_bytes(state))
	assert(react(state, true).is_empty() and state.cp[1] == 3 and state.pending_attack.is_empty() and state.squads[1].shot)
	assert(state.last_attack.pools[0].attacks == 2 and state.last_attack.pools[0].hit_rolls == [1, 1])
	assert(state.last_attack.pools[0].dice_history == [6, 1, 1, 1] and count == 4)
	assert(not react(state, true).is_empty())
	# Flattened die index maps to its source, preserving all other dice and bonuses.
	var weapon: Dictionary = fixture().squads[1].weapon.duplicate(true)
	weapon.attacks = "2D3+1"
	var defender := {"toughness": 4, "save_target": 3, "wounds_per_model": 2, "remaining_wounds": [2]}
	var context := {"attack_sources": [{"model": 100, "weapon": "one", "expression": "2D3+1", "bonus": 2}, {"model": 101, "weapon": "two", "expression": "2D3+1", "bonus": 3}]}
	values = [6, 4, 2, 6, 6]
	var checkpoint := W.begin(weapon, defender, context, die, true)
	assert(checkpoint.generated.count == 16 and checkpoint.generated.rolls == [6, 4, 2, 6])
	checkpoint = W.reroll(checkpoint, 2, checkpoint.revision, die)
	assert(checkpoint.generated.count == 18 and checkpoint.generated.rolls == [6, 4, 6, 6])
	assert(checkpoint.generated.records[0].total == 8 and checkpoint.generated.records[1].total == 10)
	weapon.attacks = "D3+1"
	weapon.keywords = {"rapid-fire": 1, "blast": true}
	values = [6, 2, 6]
	checkpoint = W.begin(weapon, defender, {"weapon_count": 2, "distance_inches": 10.0, "target_model_count": 10}, die, true)
	assert(checkpoint.generated.count == 12)
	checkpoint = W.reroll(checkpoint, 1, checkpoint.revision, die)
	assert(checkpoint.generated.count == 14 and checkpoint.generated.records[0].bonus == 3 and checkpoint.generated.records[1].bonus == 3)
	values = [6, 1]
	checkpoint = W.begin(weapon, defender, {"target_model_count": 10, "distance_inches": 10.0, "attack_sources": [{"model": 100, "weapon": "fixed", "expression": 2, "bonus": 1}, {"model": 101, "weapon": "random", "expression": "D6+1", "bonus": 2}]}, die, true)
	assert(checkpoint.generated.count == 12 and W.eligible(checkpoint) == [0])
	checkpoint = W.reroll(checkpoint, 0, checkpoint.revision, die)
	assert(checkpoint.generated.count == 7 and checkpoint.generated.records[0].total == 3 and checkpoint.generated.records[1].rolls == [1])
	state = fixture()
	state.squads[1].weapon.keywords = {"torrent": true}
	values = [6, 1, 1, 1]
	begin(state)
	assert(react(state, true).is_empty() and state.last_attack.pools[0].attacks == 2 and state.last_attack.pools[0].hit_rolls.is_empty())
	# Keeping generation still permits a hit re-roll if that option is enabled.
	state = fixture()
	state.stratagems.attack_rerolls = true
	values = [1, 1, 1]
	begin(state)
	assert(react(state).is_empty() and state.cp[1] == 4 and S.pending(state).kind == "after_hit_roll")
	assert(react(state, true).is_empty() and state.cp[1] == 3 and state.stratagems.uses.size() == 1)
	for reason in ["fixed", "cp", "shock", "phase"]:
		state = fixture()
		if reason == "fixed": state.squads[1].weapon.attacks = 2
		if reason == "cp": state.cp[1] = 0
		if reason == "shock": state.squads[1].battle_shocked = true
		if reason == "phase": state.stratagems.uses.append({"player": 1, "squad": 3, "stratagem": "command-re-roll", "phase_key": S.phase_key(state), "turn": state.turn})
		values = [1, 1, 1]
		begin(state)
		assert(S.pending(state).is_empty() and state.pending_attack.is_empty())
	# Actual lab profile is selectable without editing source or moving to Fight.
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	game.count_reroll_choice.button_pressed = true
	game._start_allocation_practice()
	assert(game.count_rerolls and game.core_stratagems and game.state.cp == {1: 2, 2: 2})
	game._apply_attack_plan(1, 100, [{"model": 100, "target": 2, "weapon": "practice", "profile": "random-attacks", "amount": 1}], 0, false, true)
	assert(S.pending(game.state).kind == "after_attack_count_roll" and game.reaction_die.visible and not game.reaction_use.disabled)
	assert(S.pending(game.state).expression == "D3+1" and "D3+1" in game.reaction_die.get_item_text(0))
	var snapshot := var_to_bytes(game.state)
	var rng_state: int = game.rng.state
	game._save_match()
	game._load_match(false)
	assert(game.count_rerolls and snapshot == var_to_bytes(game.state) and rng_state == game.rng.state)
	game._request_use_reaction()
	assert(game.state.cp[1] == 1 and game.state.stratagems.uses.size() == 1)
	game.queue_free()
	await process_frame
	print("ATTACK COUNT REROLLS: PASS")
	quit()
