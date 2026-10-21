extends SceneTree
const P = preload("res://scripts/edition_11/prepared_training.gd")
const C = P.Combat
const S = C.Stratagems
var values: Array = []
var count := 0
func die() -> int:
	count += 1
	return values.pop_front() if not values.is_empty() else 6
func fixture(phase: String) -> Dictionary:
	var state := C.initial_state("legacy-solid-v1", "elimination", 2)
	S.enable(state, true)
	state.phase = phase
	state.cp = {1: 4, 2: 4}
	for model in state.units:
		if model not in [100, 200, 300, 400]: state.units[model].wounds = 0
	for model in [100, 300]: state.units[model].position = Vector2(-8, -8 if model == 100 else 8)
	for model in [200, 400]: state.units[model].position = Vector2(-3, -8 if model == 200 else 8)
	return state
func _initialize() -> void: call_deferred("run")
func run() -> void:
	assert(P.initial_state({"movement_rerolls": true}).has("error"))
	assert(P.initial_state({"core_stratagems": true}).pack_hash != P.initial_state({"core_stratagems": true, "movement_rerolls": true}).pack_hash)
	assert(P.initial_state({"core_stratagems": true}).pack_hash == P.initial_state({"core_stratagems": true, "movement_rerolls": false}).pack_hash)
	var state := fixture("movement")
	values = [6, 1]
	assert(C.begin_movement(state, 1, 100, "advance", 0, die).is_empty())
	assert(state.pending_move.is_empty() and S.pending(state).rolls == [6] and count == 1)
	var decision := S.pending_decision(state)
	assert(decision.get("action_id", null) == "movement:1:1:movement" and decision.get("resume_frame_id", null) == state.resolution_frames.back().frame_id and state.resolution_frames.back().status == "suspended")
	var accept_option := ""
	var reroll_option := ""
	for option: Dictionary in decision.get("legal_options", []):
		if option.value == "": accept_option = str(option.id)
		if option.value == "command-re-roll": reroll_option = str(option.id)
	assert(not decision.is_empty() and int(decision.priority_player_id) == 1 and not accept_option.is_empty() and not reroll_option.is_empty() and accept_option != reroll_option)
	var before := var_to_bytes(state)
	assert(not C.move(state, 1, 100, Vector2(-7, -8), state.revision).is_empty())
	assert(not C.advance_phase(state, 1, state.revision, die).is_empty())
	assert(not C.resolve_command_reaction(state, 1, 1, "insane-bravery", state.revision, die).is_empty())
	assert(not C.resolve_roll_reaction(state, 2, 1, "command-re-roll", state.revision, die).is_empty())
	assert(not C.resolve_roll_reaction(state, 1, 3, "command-re-roll", state.revision, die).is_empty())
	assert(not C.resolve_roll_reaction(state, 1, 1, "insane-bravery", state.revision, die).is_empty())
	assert(not C.resolve_roll_reaction(state, 1, 1, "command-re-roll", 0, die).is_empty())
	assert(var_to_bytes(state) == before and count == 1)
	assert(C.resolve_roll_reaction(state, 1, 1, "command-re-roll", state.revision, die).is_empty())
	assert(count == 2 and state.pending_move.bonus == 1 and state.cp[1] == 3 and S.pending(state).is_empty())
	assert(state.resolution_frames.size() == 1 and state.resolution_frames.back().status == "resolving" and state.resolution_frames.back().resume_point == "movement-placement")
	assert(state.last_command_roll.original_rolls == [6] and state.last_command_roll.rolls == [1])
	assert(C.move(state, 1, 100, Vector2(-7, -8), state.revision).is_empty())
	assert(C.finish_movement(state, 1, state.revision, true).is_empty())
	assert(state.pending_move.bonus == 1 and state.units[100].position == Vector2(-8, -8))
	assert(not C.resolve_roll_reaction(state, 1, 1, "command-re-roll", state.revision, die).is_empty())
	assert(C.finish_movement(state, 1, state.revision).is_empty())
	assert(state.resolution_frames.is_empty())
	values = [4]
	assert(C.begin_movement(state, 1, 300, "advance", state.revision, die).is_empty())
	assert(S.pending(state).is_empty() and state.pending_move.bonus == 4 and state.cp[1] == 3)
	# A failed original charge can be rerolled in full before failure is applied.
	state = fixture("charge")
	values = [1, 1, 6, 6]
	var start := count
	assert(C.declare_charge(state, 1, 100, 0, die).error.is_empty())
	assert(S.pending(state).rolls == [1, 1] and state.pending_charge.is_empty())
	var charge_decision := S.pending_decision(state)
	assert(charge_decision.get("action_id", "").begins_with("charge:1:1:charge") and charge_decision.get("resume_frame_id", "") == state.resolution_frames.back().frame_id and state.resolution_frames.back().status == "suspended")
	assert(not C.select_charge_target(state, 1, 200, state.revision).error.is_empty())
	assert(C.resolve_roll_reaction(state, 1, 1, "command-re-roll", state.revision, die).is_empty())
	assert(count - start == 4 and state.pending_charge.rolls == [6, 6] and state.pending_charge.maximum == 12 and state.cp[1] == 3)
	assert(state.resolution_frames.size() == 1 and state.resolution_frames.back().status == "resolving" and state.resolution_frames.back().resume_point == "charge-target-selection")
	assert(C.select_charge_target(state, 1, 200, state.revision).error.is_empty())
	assert(C.decline_charge(state, 1, state.revision).is_empty() and state.resolution_frames.is_empty())
	assert(not C.resolve_roll_reaction(state, 1, 1, "command-re-roll", state.revision, die).is_empty())
	# A worse charge result is mandatory; it cannot be replaced by the original.
	state = fixture("charge")
	values = [6, 6, 1, 1]
	assert(C.declare_charge(state, 1, 100, 0, die).error.is_empty())
	assert(C.resolve_roll_reaction(state, 1, 1, "command-re-roll", state.revision, die).is_empty())
	assert(state.pending_charge.is_empty() and state.squads[1].charge_declared and state.cp[1] == 3)
	assert(not C.declare_charge(state, 1, 100, state.revision, die).error.is_empty())
	# Accepting uses neither dice nor CP and does not consume the phase allowance.
	state = fixture("charge")
	values = [3, 3]
	assert(C.declare_charge(state, 1, 100, 0, die).error.is_empty())
	start = count
	assert(C.resolve_roll_reaction(state, 1, 1, "", state.revision).is_empty())
	assert(count == start and state.cp[1] == 4 and state.stratagems.uses.is_empty() and state.pending_charge.maximum == 6)
	assert(C.decline_charge(state, 1, state.revision).is_empty())
	values = [3, 3]
	assert(C.declare_charge(state, 1, 300, state.revision, die).error.is_empty() and not S.pending(state).is_empty())
	# Invalid host dice cannot commit a debit, result, or use ledger entry.
	before = var_to_bytes(state)
	assert(not C.resolve_roll_reaction(state, 1, 3, "command-re-roll", state.revision, func(): return 0).is_empty())
	assert(var_to_bytes(state) == before)
	# No CP or battle-shock means no optional reroll window.
	for shocked in [false, true]:
		state = fixture("movement")
		state.cp[1] = 4 if shocked else 0
		state.squads[1].battle_shocked = shocked
		values = [2]
		assert(C.begin_movement(state, 1, 100, "advance", 0, die).is_empty())
		assert(S.pending(state).is_empty() and state.pending_move.bonus == 2)
	# The same player may use Command Re-roll in a later phase.
	state = fixture("charge")
	state.stratagems.uses.append({"player": 1, "squad": 1, "stratagem": "command-re-roll", "phase_key": "1:movement", "turn": 1})
	values = [3, 3]
	assert(C.declare_charge(state, 1, 100, 0, die).error.is_empty() and not S.pending(state).is_empty())
	# UI and save restore a pending roll without repeating the original dice.
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	game.reroll_choice.button_pressed = true
	game._start_prepared_match()
	assert(game.core_stratagems and game.movement_rerolls)
	game.state.phase = "movement"
	game.state.cp[1] = 4
	game._reset_history()
	game._apply_begin_movement(1, 100, "advance", 0)
	var random_state: int = game.rng.state
	var original: int = S.pending(game.state).rolls[0]
	assert(game.action_groups.reaction.container.visible and "Command Re-roll" in game.reaction_use.text)
	game.guides.preview(game.state, 100, true, 1, Vector2(-10, -4))
	assert(not game.guides.hover_valid and game.guides.current_range == 0 and game.guides.static_vertices == 0)
	game._load_match()
	assert(game.movement_rerolls and game.rng.state == random_state and S.pending(game.state).rolls == [original])
	game._request_command_reaction("")
	assert(game.rng.state == random_state and game.state.pending_move.bonus == original and game.state.cp[1] == 4)
	var used_dice := 0
	for entry in game.journal.entries: used_dice += entry.dice.size()
	assert(used_dice == 1)
	# Previous Insane Bravery saves remain compatible with the new option absent.
	game.reroll_choice.button_pressed = false
	game._start_prepared_match()
	assert(game._save_snapshot().is_empty())
	var config: Dictionary = game._save_config()
	config.erase("movement_rerolls")
	config.erase("attack_rerolls")
	config.erase("save_rerolls")
	config.erase("damage_rerolls")
	config.erase("hazard_rerolls")
	config.erase("count_rerolls")
	var identity: String = game.state.pack_hash
	assert(game.MatchSave.write(game.state, config, game.rng.state, {}, game.MatchSave.PATH, {}, game.journal.checkpoint()).is_empty())
	game._load_match()
	assert(game.core_stratagems and not game.movement_rerolls and game.state.pack_hash == identity)
	var roster = preload("res://scripts/edition_11/training_roster.gd")
	var marine: Dictionary = roster.inspect(roster.template("Space Marines", "training", 500).list).selection
	var necron: Dictionary = roster.inspect(roster.template("Necrons", "training", 500).list).selection
	var configured := P.initial_state({"core_stratagems": true, "movement_rerolls": true}, {1: marine, 2: necron})
	assert(P.from_setup(configured.saved_army_setup).pack_hash == configured.pack_hash)
	game.saved_army_mode = true
	game.mode = "client"
	game.submitted_army = necron
	game.receive_state(configured)
	assert(game.mode == "local" and not game.movement_rerolls and "Command Re-roll" in game.status.text)
	print("MOVEMENT REROLLS: PASS")
	game.free()
	quit()
