extends SceneTree
const Prepared = preload("res://scripts/edition_11/prepared_training.gd")
const C = Prepared.Combat
const S = C.Stratagems
var rolls := 0
func die() -> int:
	rolls += 1
	return 1
func fixture() -> Dictionary:
	var state := Prepared.initial_state({"core_stratagems": true})
	state.phase = "command"
	state.cp = {1: 2, 2: 2}
	for squad in [1, 3]:
		for model in C.living(state, squad).slice(2): state.units[model].wounds = 0
	return state
func _initialize() -> void: call_deferred("run")
func run() -> void:
	assert(not Prepared.initial_state().has("stratagems"))
	assert(Prepared.initial_state().pack_hash != Prepared.initial_state({"core_stratagems": true}).pack_hash)
	assert(Prepared.initial_state({"core_stratagems": 1}).has("error"))
	var roster = preload("res://scripts/edition_11/training_roster.gd")
	var marine: Dictionary = roster.inspect(roster.template("Space Marines", "training", 500).list).selection
	var necron: Dictionary = roster.inspect(roster.template("Necrons", "training", 500).list).selection
	var configured := Prepared.initial_state({"core_stratagems": true}, {1: marine, 2: necron})
	assert(configured.saved_army_setup.options.core_stratagems and Prepared.from_setup(configured.saved_army_setup).pack_hash == configured.pack_hash)
	var state := fixture()
	assert(C.advance_phase(state, 1, 0, die).is_empty())
	assert(state.phase == "command" and rolls == 0 and state.cp[1] == 2 and S.pending(state).remaining == [1, 3])
	var command_close_frame := C.ResolutionFrames.current(state)
	assert(command_close_frame.get("kind", "") == "phase-close" and command_close_frame.get("action_id", "") == "phase-close:%d:command" % state.turn and command_close_frame.get("status", "") == "suspended")
	var reaction_decision := S.pending_decision(state)
	assert(reaction_decision.get("resume_frame_id", "") == command_close_frame.get("frame_id", "") and reaction_decision.get("action_id", "") == command_close_frame.get("action_id", ""))
	var restored: Dictionary = bytes_to_var(var_to_bytes(state))
	var restored_decision := S.pending_decision(restored)
	assert(C.ResolutionFrames.current(restored) == command_close_frame and not S.pending(restored).is_empty())
	assert(restored_decision.get("decision_id", "") == reaction_decision.get("decision_id", "") and restored_decision.get("legal_options", []) == reaction_decision.get("legal_options", []) and restored_decision.get("priority_player_id", -1) == reaction_decision.get("priority_player_id", -1) and restored_decision.get("resume_frame_id", "") == reaction_decision.get("resume_frame_id", ""))
	assert(not C.PhaseCloseGate.close_request_error(restored, 1, restored.revision).is_empty())
	assert("pending decision" in C.PhaseCloseGate.close_request_error(state, 1, state.revision))
	var original := var_to_bytes(state)
	assert(not C.advance_phase(state, 1, state.revision, die).is_empty())
	assert(not C.move(state, 1, 100, Vector2(-10, 0), state.revision).is_empty())
	assert(not C.resolve_command_reaction(state, 2, 1, "insane-bravery", state.revision, die).is_empty())
	assert(not C.resolve_command_reaction(state, 1, 2, "insane-bravery", state.revision, die).is_empty())
	assert(not C.resolve_command_reaction(state, 1, 1, "unknown", state.revision, die).is_empty())
	assert(not C.resolve_command_reaction(state, 1, 1, "insane-bravery", -1, die).is_empty())
	assert(var_to_bytes(state) == original and rolls == 0)
	state.cp[1] = 0
	assert(not S.use_error(state, 1, 1, "insane-bravery", state.revision).is_empty())
	state.cp[1] = 2
	state.squads[1].battle_shocked = true
	assert(not S.use_error(state, 1, 1, "insane-bravery", state.revision).is_empty())
	state.squads[1].battle_shocked = false
	state.squads[1].stats.leadership_target = null
	assert(not C.resolve_command_reaction(state, 1, 1, "insane-bravery", state.revision, die).is_empty() and state.cp[1] == 2)
	state.squads[1].stats.leadership_target = 6
	assert(C.resolve_command_reaction(state, 1, 3, "insane-bravery", state.revision, die).is_empty())
	assert(state.cp[1] == 1 and state.cp[2] == 2 and rolls == 0 and state.stratagems.uses.size() == 1)
	assert(S.pending(state).remaining == [1] and state.last_morale[0].automatic)
	assert(not S.use_error(state, 1, 1, "insane-bravery", state.revision).is_empty())
	original = var_to_bytes(state)
	assert(not C.resolve_command_reaction(state, 1, 1, "", state.revision, func(): return 0).is_empty())
	assert(var_to_bytes(state) == original)
	assert(C.resolve_command_reaction(state, 1, 1, "", state.revision, die).is_empty())
	assert(state.phase == "movement" and rolls == 2 and state.squads[1].battle_shocked and state.last_morale.size() == 2 and C.ResolutionFrames.current(state).is_empty())
	assert(state.cp[1] == 1 and state.stratagems.uses.size() == 1)
	# The once-per-battle restriction survives a later Command phase.
	state.turn += 2
	state.phase = "command"
	state.cp[1] = 5
	assert(C.advance_phase(state, 1, state.revision, die).is_empty())
	assert(not S.use_error(state, 1, 3, "insane-bravery", state.revision).is_empty())
	# UI, save, pending-window restoration and no dice on automatic success.
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	game.stratagem_choice.button_pressed = true
	game._start_prepared_match()
	game.state = fixture()
	game._reset_history()
	game._request_end()
	assert(game.action_groups.reaction.container.visible and game.end_button.disabled and not game.reaction_use.disabled)
	var random_state: int = game.rng.state
	game._load_match()
	assert(not S.pending(game.state).is_empty() and game.rng.state == random_state and game.core_stratagems)
	game._request_command_reaction("insane-bravery")
	assert(game.rng.state == random_state and game.state.cp[1] == 1)
	game._load_match()
	assert(game.state.stratagems.uses.size() == 1 and game.state.cp[1] == 1)
	var config_before: Dictionary = game._save_config().duplicate(true)
	var state_before: Dictionary = game.state.duplicate(true)
	game._start_objectives(10)
	assert(game._save_config() == config_before and game.state == state_before)
	# Explicit migration of pre-option saves keeps the old state/hash unchanged.
	game._start_objectives()
	var config: Dictionary = game._save_config()
	config.erase("core_stratagems")
	assert(game.MatchSave.write(game.state, config, game.rng.state, {}).is_empty())
	game._load_match()
	assert(not game.core_stratagems and not game.state.has("stratagems"))
	game.saved_army_mode = true
	game.mode = "client"
	game.submitted_army = necron
	game.receive_state(configured)
	assert(game.mode == "local" and not game.state.has("stratagems"))
	assert("stratagem option" in game.status.text)
	print("STRATAGEM WINDOWS: PASS")
	game.free()
	quit()

