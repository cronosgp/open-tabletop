extends SceneTree

const Combat = preload("res://scripts/edition_11/combat_scenario.gd")
const Morale = Combat.Morale
const PendingDecisions = preload("res://scripts/edition_11/pending_decision_registry.gd")
const MatchCommandService = preload("res://scripts/edition_11/match_command_service.gd")
const ResolutionFrames = preload("res://scripts/edition_11/resolution_frame.gd")
var failures := 0
var calls := 0

func check(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		failures += 1

func one() -> int:
	calls += 1
	return 1

func six() -> int:
	calls += 1
	return 6

func bad() -> int: return 7

func half_warriors() -> Dictionary:
	var state := Combat.initial_state("legacy-solid-v1")
	state.active = 2
	state.phase = "command"
	# Exercise the CommandBattleShock compatibility path that runs without stratagem state.
	state.erase("stratagems")
	for id in range(205, 210): state.units[id].wounds = 0
	return state

func split_squad(state: Dictionary, squad: int) -> void:
	var members := Combat.living(state, squad)
	for index in range(members.size()):
		state.units[members[index]].position = Vector2(-12 + index * 1.2, -8 if squad == 1 else 8)
	state.units[members.back()].position += Vector2(0, -6 if squad == 1 else 6)

func _initialize() -> void:
	var state := half_warriors()
	if state.has("error"):
		push_error(state.error)
		quit(1)
		return
	check(Morale.at_half_strength(state, 2), "Exactly half strength must test")
	check(not Morale.at_half_strength(state, 1), "Full-strength squad considered half strength")
	check(not Morale.needs_command_roll(state, 1), "Opponent tested during active player's command")
	var before: Dictionary = state.duplicate(true)
	var missing_dice_error := Combat.advance_phase(state, 2, 0)
	check(not missing_dice_error.is_empty() and state == before, "Missing host dice changed state")
	check(not Combat.advance_phase(state, 2, 0, bad).is_empty() and state == before, "Invalid dice changed state")
	check(not Combat.advance_phase(state, 1, 0, one).is_empty() and calls == 0, "Wrong player consumed dice")
	check(Combat.advance_phase(state, 2, 0, one) == "", "Required battle-shock could not resolve")
	check(calls == 2 and state.phase == "movement" and state.squads[2].battle_shocked, "Failed roll not applied exactly once")
	check(state.last_morale[0].rolls == [1, 1], "Dice not retained in authoritative state")
	check(Morale.objective_control(state, 200) == 0, "Battle-shocked model retains OC")
	check(not Morale.can_start_action(state, 2) and not Morale.can_target_with_friendly_stratagem(state, 2), "Battle-shock eligibility gates missing")
	check(not Combat.advance_phase(state, 2, 0, six).is_empty() and calls == 2, "Stale command rerolled battle-shock")
	# Battle-shock persists through turns, including the opponent's command.
	state.active = 1
	state.turn += 1
	state.phase = "command"
	check(Combat.advance_phase(state, 1, state.revision, six) == "" and calls == 2 and state.squads[2].battle_shocked, "Opponent's command cleared morale")
	state.active = 2
	state.turn += 1
	state.phase = "command"
	# Recovery is required even if models are restored above half strength.
	state.units[205].wounds = 1
	var recovery_error := Combat.advance_phase(state, 2, state.revision, six)
	check(recovery_error == "" and not state.squads[2].battle_shocked, "Passing command roll did not recover morale: %s / turn=%d pending=%s" % [recovery_error, int(state.turn), str(state.get("command_battle_shock", {}))])
	check(Morale.objective_control(state, 200) == int(state.squads[2].stats.objective_control), "Recovery did not restore OC")
	check(Morale.can_start_action(state, 2) and Morale.can_target_with_friendly_stratagem(state, 2), "Recovery did not restore morale eligibility")
	# Equality succeeds; odd starting strength uses the correct boundary.
	state = half_warriors()
	state.squads[2].stats.leadership_target = 2
	check(Combat.advance_phase(state, 2, 0, one) == "" and not state.squads[2].battle_shocked, "Leadership equality must pass")
	state.units[102].wounds = 0
	state.units[103].wounds = 0
	check(not Morale.at_half_strength(state, 1), "Three of five is above half strength")
	state.units[104].wounds = 0
	check(Morale.at_half_strength(state, 1), "Two of five is below half strength")
	# One-model units use wounds, and destroyed units never test.
	state.squads[1].starting_strength = 1
	for id in [101, 102, 103, 104]: state.units[id].wounds = 0
	state.units[100].wounds = 1
	check(Morale.at_half_strength(state, 1), "Single model half wounds boundary")
	state.units[100].wounds = 2
	check(not Morale.at_half_strength(state, 1), "Full-wound single model tested")
	state.units[100].wounds = 0
	state.squads[1].battle_shocked = true
	state.active = 1
	check(not Morale.needs_command_roll(state, 1) and Morale.objective_control(state, 100) == 0, "Destroyed unit tested or retained OC")
	# Owning players choose removals; no phase skip or automatic casualty choice.
	state = Combat.initial_state("legacy-solid-v1")
	state.phase = "end_turn"
	split_squad(state, 1)
	split_squad(state, 2)
	check(Combat.actor(state) == 1, "Turn owner must resolve their incoherent squad first")
	var coherency_decision := PendingDecisions.current(state, ["coherency"])
	check(coherency_decision.get("source", "") == "coherency" and int(coherency_decision.get("priority_player_id", -1)) == 1 and not coherency_decision.get("pass_allowed", true), "End-of-turn coherency projects a required decision for the owning player")
	check(coherency_decision.get("legal_options", []).any(func(option: Dictionary) -> bool: return option.get("action", "") == "remove-coherency-model" and int(option.get("model", -1)) == 104), "Coherency decision options identify living casualties from the current incoherent squad")
	var serialized_coherency: Dictionary = bytes_to_var(var_to_bytes(state))
	var restored_coherency_decision := PendingDecisions.current(serialized_coherency, ["coherency"])
	check(restored_coherency_decision.get("decision_id", "") == coherency_decision.get("decision_id", "") and restored_coherency_decision.get("legal_options", []) == coherency_decision.get("legal_options", []), "Coherency decision identity and options are deterministic after serialization")
	before = state.duplicate(true)
	check(not Combat.advance_phase(state, 1, 0).is_empty() and state == before, "Advancing silently chose coherency casualties")
	check(not Combat.remove_for_coherency(state, 2, 209, 0).is_empty(), "Opponent bypassed removal window")
	check(not Combat.remove_for_coherency(state, 1, 200, 0).is_empty(), "Opponent model removed")
	var selected_casualty: Dictionary = coherency_decision.legal_options.filter(func(option: Dictionary) -> bool: return int(option.get("model", -1)) == 104)[0]
	var stale_coherency := MatchCommandService.execute(state, 1, {"kind": MatchCommandService.REMOVE_COHERENCY, "model": 104, "revision": state.revision, "decision_id": coherency_decision.decision_id, "option_id": "stale-option"})
	check(not stale_coherency.get("error", "").is_empty() and state == before, "A stale coherency option is rejected without mutation")
	var selected_result := MatchCommandService.execute(state, 1, {"kind": MatchCommandService.REMOVE_COHERENCY, "model": 104, "revision": state.revision, "decision_id": coherency_decision.decision_id, "option_id": selected_casualty.id})
	check(selected_result.get("error", "").is_empty() and state.units[104].wounds == 0 and state.units[103].wounds > 0, "The projected coherency casualty is removed through the shared command path")
	check(Combat.actor(state) == 2 and state.active == 1, "Opponent's out-of-turn removal window missing")
	check(not Combat.remove_for_coherency(state, 2, 209, 0).is_empty(), "Stale coherency removal accepted")
	var opponent_decision := PendingDecisions.current(state, ["coherency"])
	var opponent_option: Dictionary = opponent_decision.legal_options.filter(func(option: Dictionary) -> bool: return int(option.get("model", -1)) == 209)[0]
	var stale_owner_option := MatchCommandService.execute(state, 2, {"kind": MatchCommandService.REMOVE_COHERENCY, "model": 209, "revision": state.revision, "decision_id": coherency_decision.decision_id, "option_id": selected_casualty.id})
	check(not stale_owner_option.get("error", "").is_empty(), "A superseded coherency decision cannot be reused by the next player")
	var opponent_result := MatchCommandService.execute(state, 2, {"kind": MatchCommandService.REMOVE_COHERENCY, "model": 209, "revision": state.revision, "decision_id": opponent_decision.decision_id, "option_id": opponent_option.id})
	check(opponent_result.get("error", "").is_empty(), "The opponent can resolve its own projected coherency casualty")
	check(Combat.actor(state) == 1 and Combat.incoherent_squad(state) == -1, "Turn control not returned after coherency")
	check(Combat.advance_phase(state, 1, state.revision) == "" and state.active == 2, "Resolved turn cannot finish")
	check(not Combat.remove_for_coherency(state, 2, 208, state.revision).is_empty(), "Coherency removal outside End of Turn accepted")
	# Entering End of Turn with mandatory casualties suspends a phase-close frame.
	state = Combat.initial_state("legacy-solid-v1")
	state.phase = "fight"
	state.fight_step = "complete"
	split_squad(state, 1)
	split_squad(state, 2)
	check(Combat.advance_phase(state, 1, state.revision) == "" and state.phase == "end_turn", "Fight could not enter End of Turn")
	var coherency_frame := ResolutionFrames.current(state)
	var entering_end_turn_decision := PendingDecisions.current(state, ["coherency"])
	var coherency_frame_id := str(coherency_frame.get("frame_id", ""))
	check(coherency_frame.get("kind", "") == "phase-close" and coherency_frame.get("status", "") == "suspended" and coherency_frame.get("resume_point", "") == "end-turn-coherency-casualties", "End-of-Turn incoherency suspends its phase-close continuation")
	check(str(entering_end_turn_decision.get("resume_frame_id", "")) == coherency_frame_id, "Coherency decision links to the suspended end-turn frame")
	var serialized_end_turn: Dictionary = bytes_to_var(var_to_bytes(state))
	var restored_end_turn_frame := ResolutionFrames.current(serialized_end_turn)
	var restored_end_turn_decision := PendingDecisions.current(serialized_end_turn, ["coherency"])
	check(restored_end_turn_frame.get("status", "") == "suspended" and str(restored_end_turn_frame.get("frame_id", "")) == coherency_frame_id and restored_end_turn_decision.get("decision_id", "") == entering_end_turn_decision.get("decision_id", ""), "End-of-Turn casualty decision restores with the same suspended continuation")
	check(not Combat.advance_phase(state, 1, state.revision).is_empty(), "End Turn advanced past coherency casualties")
	var first_coherency_option: Dictionary = entering_end_turn_decision.legal_options.filter(func(option: Dictionary) -> bool: return int(option.get("model", -1)) == 104)[0]
	var first_coherency_result := MatchCommandService.execute(state, 1, {"kind": MatchCommandService.REMOVE_COHERENCY, "model": int(first_coherency_option.model), "revision": state.revision, "decision_id": entering_end_turn_decision.decision_id, "option_id": first_coherency_option.id})
	check(first_coherency_result.get("error", "").is_empty() and Combat.actor(state) == 2 and ResolutionFrames.current(state).get("status", "") == "suspended", "First player's casualty keeps the same frame pending for the other player: %s" % str(first_coherency_result))
	var second_coherency_decision := PendingDecisions.current(state, ["coherency"])
	var second_coherency_option: Dictionary = second_coherency_decision.legal_options.filter(func(option: Dictionary) -> bool: return int(option.get("model", -1)) == 209)[0]
	var second_coherency_result := MatchCommandService.execute(state, 2, {"kind": MatchCommandService.REMOVE_COHERENCY, "model": int(second_coherency_option.model), "revision": state.revision, "decision_id": second_coherency_decision.decision_id, "option_id": second_coherency_option.id})
	coherency_frame = ResolutionFrames.current(state)
	check(second_coherency_result.get("error", "").is_empty() and Combat.incoherent_squad(state) == -1 and coherency_frame.get("status", "") == "resolving" and str(coherency_frame.get("frame_id", "")) == coherency_frame_id, "Final coherency casualty resumes the original turn-close frame: %s, frame=%s, remaining=%d" % [str(second_coherency_result), str(coherency_frame), Combat.incoherent_squad(state)])
	var end_turn_close_error := Combat.advance_phase(state, 1, state.revision)
	check(end_turn_close_error.is_empty() and state.active == 2 and state.phase == "start_turn" and ResolutionFrames.current(state).is_empty(), "Turn-close continuation completes after the mandatory coherency choices: %s" % end_turn_close_error)
	print("Morale and coherency checks complete: %d failures" % failures)
	quit(1 if failures else 0)
