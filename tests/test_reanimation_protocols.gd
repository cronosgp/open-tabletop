extends SceneTree
const P = preload("res://scripts/edition_11/prepared_training.gd")
const C = P.Combat
const R = C.Reanimation
const Save = preload("res://scripts/match_save.gd")
const MatchCommands = preload("res://scripts/edition_11/match_command_service.gd")
var failures := 0
class Dice:
	extends RefCounted
	var calls := 0
	var value := 6
	func roll() -> int:
		calls += 1
		return value
func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1
func fixture(stratagems: bool = false) -> Dictionary:
	var state := C.initial_state("legacy-solid-v1", C.Objectives.TRAINING, 2, false, true)
	state.terrain.areas = []
	state.active = 2
	state.turn = 2
	for id: int in state.units:
		state.units[id].position = Vector2(-10 if state.units[id].owner == 1 else 5, -5 if id < 300 else 5) + Vector2((id % 100) / 5, (id % 5) * 1.3)
	R.enable(state)
	if stratagems: C.Stratagems.enable(state)
	C.advance_phase(state, 2, state.revision)
	return state
func decide(state: Dictionary, action: String, squad: int = 2, model: int = -1, point: Vector2 = Vector2.ZERO, roller: Callable = Callable()) -> String:
	return C.resolve_reanimation(state, 2, action, squad, model, point, state.revision, roller)
func _initialize() -> void: call_deferred("run")
func run() -> void:
	check(P.initial_state().pack_hash == P.initial_state({"reanimation_protocols": false}).pack_hash, "Disabled identity remains compatible")
	check(P.initial_state().pack_hash != P.initial_state({"reanimation_protocols": true}).pack_hash and P.initial_state({"reanimation_protocols": 1}).has("error"), "Explicit boolean option freezes match identity")
	var dice := Dice.new()
	var state := fixture()
	for id in [201, 202, 203]: state.units[id].wounds = 0
	var original: Dictionary = state.units[201].duplicate(true)
	check(C.advance_phase(state, 2, state.revision, dice.roll).is_empty() and dice.calls == 0 and R.pending(state).remaining == [2, 4], "End of own Command queues every living Necron unit after morale")
	var reanimation_decision := R.pending_decision(state)
	var roll_squads: Array[int] = []
	for option: Dictionary in reanimation_decision.get("legal_options", []):
		if option.value == "roll": roll_squads.append(int(option.target))
	check(not reanimation_decision.is_empty() and int(reanimation_decision.priority_player_id) == 2 and roll_squads == [2, 4], "Reanimation projects the eligible remaining units under one decision owner")
	check(not C.advance_phase(state, 2, state.revision).is_empty() and not C.begin_movement(state, 2, 200, "normal", state.revision).is_empty(), "Mandatory window blocks unrelated commands")
	var before := var_to_bytes(state)
	var missing_decision := MatchCommands.execute(state, 2, {"kind": MatchCommands.RESOLVE_REANIMATION, "choice": {"action": "reanimation", "model": -1, "target": 2, "value": "roll"}, "point": Vector2.ZERO, "revision": state.revision}, dice.roll)
	check(not missing_decision.error.is_empty() and before == var_to_bytes(state) and dice.calls == 0, "A Reanimation projection rejects an unidentified roll without mutation or dice")
	var roll_option_id := str(reanimation_decision.legal_options[0].id)
	var invalid_decision := MatchCommands.execute(state, 2, {"kind": MatchCommands.RESOLVE_REANIMATION, "choice": {"_decision_type": MatchCommands.REANIMATION_DECISION_ENVELOPE, "decision_id": reanimation_decision.decision_id, "option_id": "invalid-option", "choice": {"action": "reanimation", "model": -1, "target": 2, "value": "roll"}}, "point": Vector2.ZERO, "revision": state.revision}, dice.roll)
	check(not invalid_decision.error.is_empty() and before == var_to_bytes(state) and dice.calls == 0, "A Reanimation projection rejects an option outside the current window")
	check(not roll_option_id.is_empty(), "Reanimation roll choices have stable option IDs")
	check(not C.resolve_reanimation(state, 1, "roll", 2, -1, Vector2.ZERO, state.revision, dice.roll).is_empty(), "Opponent cannot roll")
	check(not C.resolve_reanimation(state, 2, "roll", 2, -1, Vector2.ZERO, -1, dice.roll).is_empty(), "Stale revision rejected")
	check(not decide(state, "bogus", 2, -1, Vector2.ZERO, dice.roll).is_empty() and not decide(state, "roll", 1, -1, Vector2.ZERO, dice.roll).is_empty(), "Unknown action and foreign unit rejected before dice")
	check(before == var_to_bytes(state) and dice.calls == 0, "Invalid commands leave state and dice untouched")
	check(decide(state, "roll", 2, -1, Vector2.ZERO, dice.roll).is_empty() and dice.calls == 1 and R.pending(state).current.slots == 3, "D6 six becomes D3 three once")
	var placement_decision := R.pending_decision(state)
	var placement_models: Array[int] = []
	for option: Dictionary in placement_decision.get("legal_options", []):
		if option.value == "place": placement_models.append(int(option.model))
	check(not placement_decision.is_empty() and placement_models == [201, 202, 203], "Reanimation exposes destroyed troop placement intents while keeping coordinates rule-validated")
	check(not decide(state, "roll", 2, -1, Vector2.ZERO, dice.roll).is_empty() and dice.calls == 1, "Cannot reroll a pending unit")
	check(not decide(state, "confirm").is_empty(), "Cannot confirm unassigned return attempts")
	check(not decide(state, "place", 2, 201, Vector2(INF, 0)).is_empty() and not decide(state, "place", 2, 201, Vector2(16, 0)).is_empty(), "Nonfinite and off-board bases rejected")
	check(not decide(state, "place", 2, 201, state.units[200].position).is_empty(), "Base overlap rejected")
	check(not decide(state, "place", 2, 100, Vector2.ZERO).is_empty(), "Enemy model cannot return")
	check(decide(state, "suggest").is_empty() and R.pending(state).current.placements.size() == 3, "Suggestion stages valid positions")
	check(state.units[201].wounds == 0 and state.units[201].position == original.position and state.cp == {1: 1, 2: 1}, "Preview does not alter wounds, equipment, positions or CP")
	var preview := state.duplicate(true)
	check(decide(state, "reset").is_empty() and R.pending(state).current.raw_roll == 6 and dice.calls == 1, "Reset retains original roll")
	state = preview
	check(decide(state, "confirm").is_empty() and C.living(state, 2).size() == 10 and state.phase == "command", "Confirmation restores models and waits for other units")
	check(state.units[201].ranged_weapons == original.ranged_weapons and state.units[201].definition_id == original.definition_id, "Original model equipment and identity preserved")
	check(decide(state, "roll", 4, -1, Vector2.ZERO, dice.roll).is_empty() and state.phase == "movement" and dice.calls == 2 and state.cp == {1: 1, 2: 1}, "Intact unit still rolls; last activation finishes Command exactly once")
	check(R.pending(state).is_empty() and state.reanimation.last_results.size() == 2 and state.reanimation.last_results[1].discarded == 3, "Reports include unused healing")
	for raw in range(1, 7):
		state = fixture()
		state.units[201].wounds = 0
		C.advance_phase(state, 2, state.revision, dice.roll)
		dice.value = raw
		check(decide(state, "roll", 2, -1, Vector2.ZERO, dice.roll).is_empty() and R.pending(state).current.budget == ceili(raw / 2.0) and R.pending(state).current.slots == 1, "D3 conversion and starting strength cap")
		check(decide(state, "unplaceable", 2, 201).is_empty() and not decide(state, "unplaceable", 2, 201).is_empty(), "Explicit failure declaration consumes one attempt")
		check(decide(state, "confirm").is_empty() and state.units[201].wounds == 0 and R.pending(state).results[0].unplaced == [201], "Unplaceable model remains destroyed and report records declaration")
	dice.value = 6
	state = fixture()
	for id in range(201, 210): state.units[id].wounds = 0
	C.advance_phase(state, 2, state.revision, dice.roll)
	decide(state, "roll", 2, -1, Vector2.ZERO, dice.roll)
	check(decide(state, "place", 2, 201, state.units[200].position + Vector2(2.5, 0)).is_empty(), "Legal return anchored to phase-entry survivor")
	check(not decide(state, "place", 2, 202, state.units[200].position + Vector2(5, 0)).is_empty(), "Returned model cannot extend original anchor chain")
	state.units[100].position = state.units[200].position + Vector2(4.5, 0)
	check(not R.position_error(state, 201, state.units[200].position + Vector2(2.5, 0)).is_empty(), "Cannot create engagement with a new enemy unit")
	state.units[100].position = state.units[200].position + Vector2(2, 0)
	R.pending(state).current.engaged = [1]
	check(R.position_error(state, 201, state.units[200].position + Vector2(2.5, 1.5)).is_empty(), "Return may engage a unit already engaged before activation")
	state = fixture()
	for id in range(201, 210): state.units[id].wounds = 0
	C.advance_phase(state, 2, state.revision, dice.roll)
	decide(state, "roll", 2, -1, Vector2.ZERO, dice.roll)
	var destination: Vector2 = state.units[200].position + Vector2(-2, 0)
	state.terrain.areas = [{"category": "legacy", "bounds": Rect2(destination - Vector2.ONE, Vector2(2, 2)), "features": [{"bounds": Rect2(destination - Vector2(0.1, 0.1), Vector2(0.2, 0.2)), "blocks_end": true, "height": 2.0}]}]
	check(not decide(state, "place", 2, 201, destination).is_empty(), "Returned base cannot finish inside terrain")
	state.terrain.areas = [{"category": "legacy", "bounds": Rect2(4, -7, 0.2, 4), "features": [{"bounds": Rect2(4, -7, 0.2, 4), "blocks_end": true, "height": 2.0}]}]
	check(decide(state, "place", 2, 201, destination).is_empty(), "Setup does not require traversing a movement path from corpse position")
	state.terrain.areas = []
	state.units[209].wounds = 1
	state.units[209].position = Vector2(-9, -5)
	check(not R.position_error(state, 201, destination).is_empty(), "Return must be within 9 inches of every living unit member")
	state = fixture()
	for id: int in C.living(state, 2): state.units[id].definition_id = "40kdc:11e:necrons:immortals"
	state.units[201].wounds = 0
	C.advance_phase(state, 2, state.revision, dice.roll)
	check(decide(state, "roll", 2, -1, Vector2.ZERO, dice.roll).is_empty() and decide(state, "suggest").is_empty() and decide(state, "confirm").is_empty() and state.units[201].wounds == 1, "Pure Immortals use the same one-wound return flow")
	state = fixture()
	state.units[201].wounds = 0
	C.advance_phase(state, 2, state.revision, dice.roll)
	before = var_to_bytes(state)
	dice.value = 0
	check(not decide(state, "roll", 2, -1, Vector2.ZERO, dice.roll).is_empty() and before == var_to_bytes(state), "Invalid D6 provider cannot partially mutate the window")
	dice.value = 6
	state = fixture()
	state.active = 1
	R.start_command(state)
	check(C.advance_phase(state, 1, state.revision).is_empty() and R.pending(state).is_empty(), "Enemy faction's Command does not activate Necron healing")
	state = fixture()
	state.squads[2].attached = true
	before = var_to_bytes(state)
	check(not C.advance_phase(state, 2, state.revision, dice.roll).is_empty() and before == var_to_bytes(state), "Unsupported attachment fails before morale or mutation")
	state = fixture()
	state.units[200].max_wounds = 2
	check(not C.advance_phase(state, 2, state.revision, dice.roll).is_empty(), "Unverified troop wound profile is blocked")
	state = fixture()
	for id: int in C.living(state, 2): state.units[id].wounds = 0
	check(C.advance_phase(state, 2, state.revision).is_empty() and R.pending(state).remaining == [4], "Destroyed unit never activates")
	state = fixture()
	for id in range(201, 210): state.units.erase(id)
	state.units[200].definition_id = R.OVERLORD
	state.units[200].max_wounds = 6
	state.units[200].wounds = 4
	state.squads[2].starting_strength = 1
	C.advance_phase(state, 2, state.revision, dice.roll)
	check(decide(state, "roll", 2, -1, Vector2.ZERO, dice.roll).is_empty() and state.units[200].wounds == 6 and R.pending(state).results[0].discarded == 1, "Living standalone Overlord heals without exceeding full wounds")
	state = fixture(true)
	for id in range(201, 210): state.units[id].wounds = 0
	check(C.advance_phase(state, 2, state.revision).is_empty() and not C.Stratagems.pending(state).is_empty() and R.pending(state).is_empty(), "Battle-shock decision precedes Reanimation")
	check(C.resolve_command_reaction(state, 2, 2, "", state.revision, dice.roll).is_empty() and not R.pending(state).is_empty(), "Completed Battle-shock opens Reanimation")
	var morale_calls := dice.calls
	decide(state, "roll", 2, -1, Vector2.ZERO, dice.roll)
	decide(state, "suggest")
	decide(state, "confirm")
	decide(state, "roll", 4, -1, Vector2.ZERO, dice.roll)
	check(state.phase == "movement" and dice.calls == morale_calls + 2 and not state.squads[2].battle_shocked, "Morale is not repeated after last activation")
	# Real UI, autosave and preview preservation.
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	game.auto_models.button_pressed = false
	game.reanimation_protocols_choice.button_pressed = true
	game._start_prepared_match()
	game.state = fixture()
	game.state.units[201].wounds = 0
	game._spawn_pieces()
	game._reset_history()
	game._request_end()
	check(game.action_groups.reanimation.container.visible and game.reanimation_roll.visible and game.end_button.disabled, "Mandatory window has visible focused controls")
	game._request_reanimation("roll")
	game._request_reanimation("suggest")
	check(game.pieces[201].visible and game.state.units[201].wounds == 0, "Preview renders destroyed model without changing its wounds")
	var saved_state: Dictionary = game.state.duplicate(true)
	var saved_rng: int = game.rng.state
	# fixture uses legacy pack identity; save against a genuine prepared initial state instead.
	game._start_prepared_match()
	game.state.phase = "start_turn"
	game.state.active = 2
	game.state.turn = 2
	game.state.terrain.areas = []
	game.state.units[201].wounds = 0
	C.advance_phase(game.state, 2, game.state.revision)
	game._reset_history()
	game._request_end()
	game._request_reanimation("roll")
	game._request_reanimation("suggest")
	saved_state = game.state.duplicate(true)
	saved_rng = game.rng.state
	game._save_match()
	game._load_match()
	check(game.state == saved_state and game.rng.state == saved_rng and game.reanimation_protocols and game.pieces[201].visible, "Pending roll and placements survive save/load without reroll")
	game._start_objectives()
	game._save_match()
	var old := Save.read()
	old.config.erase("reanimation_protocols")
	Save.write(old.state, old.config, old.rng_state, old.attack_draft, Save.PATH, old.session, old.journal)
	game._load_match()
	check(not game.reanimation_protocols and not game.state.has("reanimation"), "Legacy saves default to disabled")
	old.config.reanimation_protocols = true
	Save.write(old.state, old.config, old.rng_state, old.attack_draft, Save.PATH, old.session, old.journal)
	before = var_to_bytes(game.state)
	game._load_match()
	check(before == var_to_bytes(game.state) and "Reanimation" in game.status.text, "Conflicting save flag rejected")
	game.queue_free()
	await process_frame
	print("REANIMATION: %d failures" % failures)
	quit(0 if failures == 0 else 1)
