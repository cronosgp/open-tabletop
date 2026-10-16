extends SceneTree
const P = preload("res://scripts/edition_11/prepared_training.gd")
const C = P.Combat
const S = C.Stratagems
var count := 0
var values: Array = []
func die() -> int:
	count += 1
	return values.pop_front() if not values.is_empty() else 6
func fixture(manual: bool = false) -> Dictionary:
	var state := C.initial_state("legacy-solid-v1", C.Objectives.TRAINING, 2, manual)
	S.enable(state, false, true)
	state.phase = "shooting"
	state.cp = {1: 4, 2: 4}
	for id: int in state.units:
		if id not in [100, 200, 201, 300, 400]: state.units[id].wounds = 0
	state.units[100].position = Vector2(-12, -8)
	state.units[200].position = Vector2(-2, -8)
	state.units[201].position = Vector2(0, -8)
	state.units[300].position = Vector2(-12, 8)
	state.units[400].position = Vector2(-2, 8)
	state.squads[1].weapon = {"name": "Checkpoint fixture", "attacks": 2, "skill": 3, "strength": 4, "ap": 0, "damage": 1, "range_inches": 30, "keywords": {}}
	return state
func begin(state: Dictionary) -> void:
	assert(C.shoot(state, 1, 100, 200, state.revision, true, die).error.is_empty())
func react(state: Dictionary, use: bool = false, index: int = 0) -> String:
	return C.resolve_attack_reaction(state, 1, 1, "command-re-roll" if use else "", state.revision, index, die)
func _initialize() -> void: call_deferred("run")
func run() -> void:
	assert(P.initial_state({"attack_rerolls": true}).has("error"))
	assert(P.initial_state({"core_stratagems": true}).pack_hash == P.initial_state({"core_stratagems": true, "attack_rerolls": false}).pack_hash)
	assert(P.initial_state({"core_stratagems": true}).pack_hash != P.initial_state({"core_stratagems": true, "attack_rerolls": true}).pack_hash)
	var state := fixture()
	values = [6, 6, 1, 6, 1]
	begin(state)
	assert(count == 2 and S.pending(state).kind == "after_hit_roll" and not state.squads[1].shot)
	var before := var_to_bytes(state)
	assert(not C.allocate_damage(state, 2, 200, state.revision, die).is_empty())
	assert(not C.advance_phase(state, 1, state.revision, die).is_empty())
	assert(not C.resolve_attack_reaction(state, 2, 1, "command-re-roll", state.revision, 0, die).is_empty())
	assert(not C.resolve_attack_reaction(state, 1, 3, "command-re-roll", state.revision, 0, die).is_empty())
	assert(not C.resolve_attack_reaction(state, 1, 1, "command-re-roll", 0, 0, die).is_empty())
	assert(not react(state, true, 99).is_empty())
	assert(var_to_bytes(state) == before and count == 2)
	assert(not C.resolve_attack_reaction(state, 1, 1, "command-re-roll", state.revision, 0, func(): return 7).is_empty())
	assert(var_to_bytes(state) == before)
	assert(react(state, true).is_empty())
	assert(state.cp[1] == 3 and S.pending(state).is_empty() and state.pending_attack.is_empty())
	assert(state.last_attack.pools[0].hit_rolls == [1, 6] and state.last_command_roll.rolls == [1, 6])
	assert(state.last_attack.pools[0].dice_history == [6, 6, 1, 6, 1] and state.stratagems.uses.size() == 1)
	before = var_to_bytes(state)
	assert(not react(state, true).is_empty() and var_to_bytes(state) == before)
	assert(C.shoot(state, 1, 300, 400, state.revision, true, die).error.is_empty())
	assert(S.pending(state).is_empty() and state.cp[1] == 3 and state.stratagems.uses.size() == 1)
	# Keeping hits opens wounds without spending CP or revealing saves.
	state = fixture(true)
	values = [6, 6, 6, 6, 1, 1]
	var start := count
	begin(state)
	assert(react(state).is_empty())
	assert(count - start == 4 and S.pending(state).kind == "after_wound_roll" and state.cp[1] == 4)
	state = bytes_to_var(var_to_bytes(state))
	assert(react(state, true, 1).is_empty())
	assert(state.cp[1] == 3 and state.pending_attack.current.phase == "damage" and C.actor(state) == 2)
	assert(state.pending_attack.current.result.wounds == 1)
	assert(C.allocate_damage(state, 2, 200, state.revision, die).is_empty())
	assert(state.pending_attack.is_empty() and state.squads[1].shot)
	# No CP or shocked attacker passes through without a reaction.
	for shocked in [false, true]:
		state = fixture()
		state.squads[1].battle_shocked = shocked
		state.cp[1] = 4 if shocked else 0
		begin(state)
		assert(S.pending(state).is_empty() and state.pending_attack.is_empty())
	# An inactive player's Fight activation still owns its hit/wound choices.
	state = fixture()
	state.active = 2
	state.phase = "fight"
	state.fight_step = "consolidation_reaction"
	state.fight_actor = 1
	state.reaction_queue = [1]
	state.squads[1].fight_eligible = true
	state.units[100].position = state.units[200].position + Vector2(-0.9, 0)
	assert(C.fight(state, 1, 100, 200, state.revision, die).error.is_empty())
	assert(C.actor(state) == 1 and react(state, true).is_empty())
	# The actual UI persists a pending pool and its RNG, then resumes it.
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	game.attack_reroll_choice.button_pressed = true
	game._start_prepared_match()
	assert(game.attack_rerolls and game.core_stratagems and not game.movement_rerolls)
	game.state.phase = "shooting"
	game.state.deployment = {}
	game.state.cp = {1: 4, 2: 4}
	for id: int in game.state.units:
		game.state.units[id].position = Vector2(-12 if game.state.units[id].owner == 1 else -2, -8 + (id % 100) * 1.3)
	assert(C.shoot(game.state, 1, 100, 200, game.state.revision, true, game._d6).error.is_empty())
	game._refresh()
	assert(game.reaction_die.visible and game.reaction_die.item_count > 0 and game.allocate_button.disabled)
	var snapshot := var_to_bytes(game.state)
	var rng_state: int = game.rng.state
	game._save_match()
	game._load_match(false)
	assert(game.attack_rerolls and var_to_bytes(game.state) == snapshot and game.rng.state == rng_state)
	game._request_use_reaction()
	assert(game.state.cp[1] == 3 and game.state.stratagems.uses.size() == 1)
	var roster = preload("res://scripts/edition_11/training_roster.gd")
	var marine: Dictionary = roster.inspect(roster.template("Space Marines", "training", 500).list).selection
	var necron: Dictionary = roster.inspect(roster.template("Necrons", "training", 500).list).selection
	var configured := P.initial_state({"core_stratagems": true, "attack_rerolls": true}, {1: marine, 2: necron})
	assert(P.from_setup(configured.saved_army_setup).pack_hash == configured.pack_hash)
	game.attack_rerolls = false
	game.saved_army_mode = true
	game.mode = "client"
	game.submitted_army = necron
	game.receive_state(configured)
	assert(game.mode == "local" and not game.attack_rerolls and "attack re-roll settings" in game.status.text)
	game.queue_free()
	await process_frame
	print("ATTACK REROLLS: PASS")
	quit()
