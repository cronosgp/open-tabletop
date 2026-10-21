extends SceneTree
const P = preload("res://scripts/edition_11/prepared_training.gd")
const C = P.Combat
const S = C.Stratagems
var values: Array = []
var count := 0
var failures := 0
func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1
func die() -> int:
	count += 1
	return values.pop_front() if not values.is_empty() else 6
func fixture(enabled: bool = true) -> Dictionary:
	var state := C.initial_state("legacy-solid-v1")
	S.enable(state, true, false, false, false, false, false, enabled)
	state.phase = "movement"
	state.cp = {1: 4, 2: 4}
	for id: int in state.units:
		if id not in [100, 101, 200, 201]: state.units[id].wounds = 0
	state.units[100].position = Vector2(-10, -8)
	state.units[101].position = Vector2(-10, -6.5)
	state.units[200].position = Vector2(-8.5, -8)
	state.units[201].position = Vector2(-8.5, -6.5)
	return state
func begin(state: Dictionary) -> void:
	check(C.begin_movement(state, 1, 100, "desperate_escape", state.revision, die).is_empty(), "Escape starts")
func react(state: Dictionary, use: bool = false, index: int = 0) -> String:
	return C.resolve_escape_reaction(state, 1, 1, "command-re-roll" if use else "", state.revision, index, die)
func _initialize() -> void: call_deferred("run")
func run() -> void:
	check(P.initial_state({"escape_rerolls": true}).has("error"), "Escape re-roll requires core stratagems")
	check(P.initial_state({"core_stratagems": true, "escape_rerolls": 1}).has("error"), "Public options are strict booleans")
	check(P.initial_state({"core_stratagems": true}).pack_hash == P.initial_state({"core_stratagems": true, "escape_rerolls": false}).pack_hash, "Disabled setups retain their identity")
	check(P.initial_state({"core_stratagems": true}).pack_hash != P.initial_state({"core_stratagems": true, "escape_rerolls": true}).pack_hash, "Enabled capability has a distinct identity")
	var marine := P.Training.inspect(P.Training.Capabilities.reference_army("Space Marines").list)
	var necron := P.Training.inspect(P.Training.Capabilities.reference_army("Necrons").list)
	var prepared := P.initial_state({"unit_abilities": true, "core_stratagems": true, "escape_rerolls": true}, {1: marine.selection, 2: necron.selection})
	check(prepared.saved_army_setup.options.escape_rerolls and P.from_setup(prepared.saved_army_setup).pack_hash == prepared.pack_hash, "Saved-list setup freezes and reconstructs the option")
	var state := fixture()
	values = [1, 6, 6]
	begin(state)
	check(count == 2 and S.pending(state).kind == "after_escape_roll" and S.pending(state).eligible == [0, 1], "Pool pauses after original hazards")
	check(state.units[100].wounds == 2 and state.pending_move.spent.is_empty(), "No wounds or movement before decision")
	var before := var_to_bytes(state)
	for error: String in [C.move(state, 1, 100, Vector2(-12, -8), state.revision), C.allocate_escape_wound(state, 1, 100, state.revision), C.finish_movement(state, 1, state.revision, true), C.abandon_fall_back(state, 1, state.revision), C.advance_phase(state, 1, state.revision)]:
		check(not error.is_empty(), "Other actions are blocked")
	check(not C.resolve_escape_reaction(state, 2, 1, "command-re-roll", state.revision, 0, die).is_empty(), "Opponent cannot choose")
	check(not C.resolve_escape_reaction(state, 1, 3, "command-re-roll", state.revision, 0, die).is_empty(), "Wrong squad rejected")
	check(not C.resolve_escape_reaction(state, 1, 1, "command-re-roll", 0, 0, die).is_empty(), "Stale revision rejected")
	check(not C.resolve_escape_reaction(state, 1, 1, "insane-bravery", state.revision, 0, die).is_empty(), "Wrong stratagem rejected")
	check(not react(state, true, -1).is_empty() and not react(state, true, 2).is_empty(), "Invalid indices rejected")
	check(count == 2 and before == var_to_bytes(state), "Rejected commands consume neither state nor dice")
	check(not C.resolve_escape_reaction(state, 1, 1, "command-re-roll", state.revision, 0, func(): return 7).is_empty() and before == var_to_bytes(state), "Invalid die provider cannot commit CP or state")
	state = bytes_to_var(var_to_bytes(state))
	check(react(state, true).is_empty() and count == 3 and state.cp[1] == 3, "Exactly one replacement costs one CP")
	check(state.pending_move.hazard_rolls == [6, 6] and state.pending_move.hazard_remaining == 0 and S.pending(state).is_empty(), "New pool releases placement")
	check(state.last_command_roll.original_rolls == [1, 6] and state.last_command_roll.rolls == [6, 6], "Final result retains the original pool")
	check(not react(state, true).is_empty(), "No second or late replacement")
	check(C.finish_movement(state, 1, state.revision, true).is_empty() and state.pending_move.hazard_rolls == [6, 6] and state.cp[1] == 3, "Reset keeps hazards and CP spent")
	check(C.abandon_fall_back(state, 1, state.revision).is_empty() and state.squads[1].moved, "Abandoning consumes the move")
	check(not C.begin_movement(state, 1, 100, "desperate_escape", state.revision, die).is_empty(), "Cannot reroll by selecting escape again")
	# Passing dice can be selected, and worse replacements are mandatory.
	state = fixture()
	state.units[100].feel_no_pain = [{"target": 5, "against": "mortal"}]
	values = [6, 6, 1, 6]
	var start := count
	begin(state)
	check(state.pending_move.hazard_remaining == 0 and not S.pending(state).is_empty(), "All-success pools still offer a decision")
	check(react(state, true, 1).is_empty() and count == start + 3 and state.pending_move.hazard_rolls == [6, 1] and state.pending_move.hazard_remaining == 1, "Only selected success becomes a failure")
	check(state.units[100].wounds == 2, "Prevention not rolled during replacement")
	check(C.allocate_escape_wound(state, 1, 100, state.revision, die).is_empty() and count == start + 4 and state.units[100].wounds == 2, "FNP occurs only after the decision")
	state = fixture()
	values = [1, 2]
	begin(state)
	start = count
	check(react(state).is_empty() and count == start and state.cp[1] == 4 and state.pending_move.hazard_remaining == 2, "Accept is free and does not roll again")
	check(C.allocate_escape_wound(state, 1, 101, state.revision).is_empty() and state.units[101].wounds == 1, "Allocation resumes normally")
	check(not react(state, true).is_empty(), "No reroll after allocation")
	# Shared hazard multiplier is captured before any casualties.
	state = fixture()
	state.units[100].keywords = ["VEHICLE"]
	state.units[101].keywords = ["MONSTER"]
	values = [6, 6, 1]
	begin(state)
	check(react(state, true).is_empty() and state.pending_move.hazard_remaining == 3, "All-heavy unit suffers three wounds per failed hazard")
	for reason: String in ["disabled", "cp", "shock", "phase", "unit"]:
		state = fixture(reason != "disabled")
		if reason == "cp": state.cp[1] = 0
		if reason == "shock": state.squads[1].battle_shocked = true
		if reason in ["phase", "unit"]: state.stratagems.uses.append({"player": 1, "squad": 3 if reason == "phase" else 1, "stratagem": "command-re-roll" if reason == "phase" else "insane-bravery", "phase_key": S.phase_key(state), "turn": state.turn})
		values = [1, 6]
		begin(state)
		check(S.pending(state).is_empty() and state.pending_move.hazard_remaining == 1, "Ineligible pool continues automatically: " + reason)
		check(not react(state, true).is_empty(), "No late request for ineligible unit")
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	game.auto_models.button_pressed = false
	game.escape_reroll_choice.button_pressed = true
	game._start_prepared_match()
	check(game.escape_rerolls and game.core_stratagems and game.state.match_manifest.escape_rerolls == S.ESCAPE_REROLL_ID, "UI configures the versioned capability")
	# Keep a real prepared setup identity while staging a movement fixture.
	game.state.phase = "movement"
	game.state.cp[1] = 4
	for id: int in game.state.units:
		if id not in [100, 101, 200, 201, 300, 400]: game.state.units[id].wounds = 0
	for id in [100, 101, 200, 201]: game.state.units[id].position = fixture().units[id].position
	game._reset_history()
	game._apply_begin_movement(1, 100, "desperate_escape", game.state.revision)
	check(game.reaction_die.visible and game.reaction_die.item_count == 2 and "Desperate Escape hazards" in game.reaction_help.text, "UI offers the escape die selector")
	var snapshot := var_to_bytes(game.state)
	var rng_state: int = game.rng.state
	game._save_match()
	game._load_match(false)
	check(game.escape_rerolls and game.escape_reroll_choice.button_pressed and var_to_bytes(game.state) == snapshot and game.rng.state == rng_state, "Pending pool and RNG survive save/resume")
	game._request_use_reaction()
	check(game.state.cp[1] == 3 and game.state.stratagems.uses.size() == 1 and game.state.last_command_roll.kind == "after_escape_roll", "UI dispatches the correct escape reaction")
	var dice_count := 0
	for entry: Dictionary in game.journal.entries: dice_count += entry.dice.size()
	check(dice_count == 3, "Journal records two originals and one replacement")
	game.escape_reroll_choice.button_pressed = false
	game._start_prepared_match()
	game._save_match()
	var old: Dictionary = game.MatchSave.read()
	old.config.erase("escape_rerolls")
	check(game.MatchSave.write(old.state, old.config, old.rng_state, old.attack_draft, game.MatchSave.PATH, old.session, old.journal).is_empty(), "Build old-config fixture")
	game._load_match()
	check(not game.escape_rerolls and not game.state.stratagems.get("escape_rerolls", false), "Old saves default to disabled")
	old.config.escape_rerolls = true
	game.MatchSave.write(old.state, old.config, old.rng_state, old.attack_draft, game.MatchSave.PATH, old.session, old.journal)
	snapshot = var_to_bytes(game.state)
	game._load_match()
	check(var_to_bytes(game.state) == snapshot and "Desperate Escape" in game.status.text, "Conflicting save flag cannot replace the match")
	game.saved_army_mode = true
	game.escape_rerolls = false
	game.mode = "client"
	game.receive_state(prepared)
	check(game.mode == "local" and not game.escape_rerolls and not game.state.stratagems.get("escape_rerolls", false) and "different" in game.status.text.to_lower(), "Conflicting peer settings are rejected before changing the local match")
	game.queue_free()
	await process_frame
	if failures == 0: print("ESCAPE REROLLS: PASS")
	quit(0 if failures == 0 else 1)
