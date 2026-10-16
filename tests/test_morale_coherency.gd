extends SceneTree

const Combat = preload("res://scripts/edition_11/combat_scenario.gd")
const Morale = Combat.Morale
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
	check(not Combat.advance_phase(state, 2, 0).is_empty() and state == before, "Missing host dice changed state")
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
	state.phase = "command"
	check(Combat.advance_phase(state, 1, state.revision, six) == "" and calls == 2 and state.squads[2].battle_shocked, "Opponent's command cleared morale")
	state.active = 2
	state.phase = "command"
	# Recovery is required even if models are restored above half strength.
	state.units[205].wounds = 1
	check(Combat.advance_phase(state, 2, state.revision, six) == "" and not state.squads[2].battle_shocked, "Passing command roll did not recover morale")
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
	before = state.duplicate(true)
	check(not Combat.advance_phase(state, 1, 0).is_empty() and state == before, "Advancing silently chose coherency casualties")
	check(not Combat.remove_for_coherency(state, 2, 209, 0).is_empty(), "Opponent bypassed removal window")
	check(not Combat.remove_for_coherency(state, 1, 200, 0).is_empty(), "Opponent model removed")
	check(Combat.remove_for_coherency(state, 1, 104, 0) == "" and state.units[103].wounds > 0, "Selected casualty was not respected")
	check(Combat.actor(state) == 2 and state.active == 1, "Opponent's out-of-turn removal window missing")
	check(not Combat.remove_for_coherency(state, 2, 209, 0).is_empty(), "Stale coherency removal accepted")
	check(Combat.remove_for_coherency(state, 2, 209, state.revision) == "", "Opponent could not remove chosen model")
	check(Combat.actor(state) == 1 and Combat.incoherent_squad(state) == -1, "Turn control not returned after coherency")
	check(Combat.advance_phase(state, 1, state.revision) == "" and state.active == 2, "Resolved turn cannot finish")
	check(not Combat.remove_for_coherency(state, 2, 208, state.revision).is_empty(), "Coherency removal outside End of Turn accepted")
	print("Morale and coherency checks complete: %d failures" % failures)
	quit(1 if failures else 0)
