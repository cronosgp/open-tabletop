extends SceneTree

const Combat = preload("res://scripts/edition_11/combat_scenario.gd")
var failures := 0
var calls := 0
var rolls: Array[int] = []

func check(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		failures += 1

func roll() -> int:
	calls += 1
	return rolls.pop_front() if not rolls.is_empty() else 0

func six() -> int: return 6

func fresh(engaged: bool = false) -> Dictionary:
	var state := Combat.initial_state("legacy-solid-v1")
	state.phase = "movement"
	for id: int in state.units:
		if id not in [100, 101, 200]: state.units[id].wounds = 0
	state.units[100].position = Vector2(-10, -8)
	state.units[101].position = Vector2(-10, -6.5)
	state.units[200].position = Vector2(-8.5, -8) if engaged else Vector2(8, -8)
	return state

func retreat_positions(state: Dictionary) -> void:
	check(Combat.move(state, 1, 100, Vector2(-5, -8), state.revision) == "", "Escape path through enemy base rejected")
	check(Combat.move(state, 1, 101, Vector2(-5, -6.5), state.revision) == "", "Second escaping model rejected")

func _initialize() -> void:
	var state := fresh()
	var before: Dictionary = state.duplicate(true)
	rolls = [4]
	check(not Combat.begin_movement(state, 2, 100, "advance", 0, roll).is_empty() and calls == 0, "Wrong owner rolled Advance")
	check(not Combat.begin_movement(state, 1, 100, "teleport", 0, roll).is_empty() and state == before, "Unknown move accepted")
	check(not Combat.begin_movement(state, 1, 100, "advance", 0).is_empty() and state == before, "Missing Advance dice changed state")
	rolls = [7]
	check(not Combat.begin_movement(state, 1, 100, "advance", 0, roll).is_empty() and state == before, "Invalid Advance dice changed state")
	rolls = [4]
	check(Combat.begin_movement(state, 1, 100, "advance", 0, roll) == "", "Advance rejected")
	check(state.pending_move.bonus == 4 and is_equal_approx(Combat.movement_remaining(state, 100), 10), "Advance bonus not applied to model budget")
	check(is_equal_approx(Combat.movement_remaining(state, 101), 10), "Squadmate missing Advance bonus")
	var used := calls
	check(not Combat.begin_movement(state, 1, 100, "advance", state.revision, roll).is_empty() and calls == used, "Advance rerolled during pending move")
	check(not Combat.advance_phase(state, 1, state.revision).is_empty(), "Advance skipped confirmation")
	check(Combat.move(state, 1, 100, Vector2(-5, -8), state.revision) == "", "Advance segment rejected")
	check(Combat.move(state, 1, 100, Vector2(-10, -8), state.revision) == "", "Advance accumulated budget rejected")
	check(is_zero_approx(Combat.movement_remaining(state, 100)), "Advance backtracking bypassed budget")
	check(Combat.finish_movement(state, 1, state.revision, true) == "", "Advance reset rejected")
	check(state.pending_move.bonus == 4 and not state.pending_move.is_empty() and calls == used, "Reset forgot Advance roll")
	check(Combat.finish_movement(state, 1, state.revision) == "" and state.squads[1].advanced, "Zero-distance Advance did not retain restrictions")
	check(not Combat.can_start_action(state, 1), "Advanced squad can start an action")
	state.phase = "shooting"
	check(state.squads[1].weapon.keywords.get("assault", false), "Imported Assault keyword discarded")
	check(Combat.shoot(state, 1, 100, 200, state.revision, true, six).error == "", "Assault shooting after Advance rejected")
	state.squads[1].shot = false
	state.squads[1].weapon.keywords.erase("assault")
	before = state.duplicate(true)
	check(not Combat.shoot(state, 1, 100, 200, state.revision, true, six).error.is_empty() and state == before, "Non-Assault shot after Advance accepted")
	state.phase = "charge"
	check(not Combat.declare_charge(state, 1, 100, state.revision, six).error.is_empty(), "Advanced squad charged")
	state.phase = "end_turn"
	check(Combat.advance_phase(state, 1, state.revision) == "" and not state.squads[1].advanced, "Advance restriction survived end of turn")
	# Ordered Retreat avoids enemy bases, can be chosen only while engaged.
	state = fresh()
	check(not Combat.begin_movement(state, 1, 100, "ordered_retreat", 0).is_empty(), "Unengaged Fall Back accepted")
	state = fresh(true)
	check(not Combat.begin_movement(state, 1, 100, "advance", 0, six).is_empty(), "Engaged Advance accepted")
	check(Combat.begin_movement(state, 1, 100, "ordered_retreat", 0) == "", "Ordered Retreat rejected")
	check(not Combat.move(state, 1, 100, Vector2(-5, -8), state.revision).is_empty(), "Ordered Retreat crossed an enemy base")
	check(not Combat.finish_movement(state, 1, state.revision).is_empty(), "Fall Back finished engaged")
	for id in [100, 101]:
		check(Combat.move(state, 1, id, state.units[id].position + Vector2(-4, 0), state.revision) == "", "Ordered Retreat away from enemy rejected")
	check(Combat.finish_movement(state, 1, state.revision) == "" and state.squads[1].fell_back, "Fall Back flags missing")
	check(not Combat.can_start_action(state, 1), "Retreating squad can start an action")
	state.phase = "shooting"
	check(not Combat.shoot(state, 1, 100, 200, state.revision, true, six).error.is_empty(), "Retreating squad shot with Assault")
	state.phase = "charge"
	check(not Combat.declare_charge(state, 1, 100, state.revision, six).error.is_empty(), "Retreating squad charged")
	# Desperate Escape is optional while steady, mandatory while battle-shocked.
	state = fresh(true)
	state.squads[1].battle_shocked = true
	check(not Combat.begin_movement(state, 1, 100, "ordered_retreat", 0).is_empty(), "Battle-shocked Ordered Retreat accepted")
	state.squads[1].battle_shocked = false
	before = state.duplicate(true)
	rolls = [1, 7]
	check(not Combat.begin_movement(state, 1, 100, "desperate_escape", 0, roll).is_empty() and state == before, "Bad hazard provider partially selected escape")
	rolls = [2, 3]
	check(Combat.begin_movement(state, 1, 100, "desperate_escape", 0, roll) == "", "Steady unit cannot choose Desperate Escape")
	check(state.pending_move.hazard_remaining == 1 and state.pending_move.hazard_rolls == [2, 3], "Hazard threshold must fail 1-2 only")
	check(not Combat.move(state, 1, 100, Vector2(-5, -8), state.revision).is_empty(), "Moved before resolving hazard wounds")
	check(not Combat.allocate_escape_wound(state, 2, 100, state.revision).is_empty(), "Opponent allocated escape wound")
	check(Combat.allocate_escape_wound(state, 1, 101, state.revision) == "" and state.units[101].wounds == 1 and state.units[100].wounds == 2, "Chosen model did not take hazard wound")
	check(not Combat.move(state, 1, 100, state.units[200].position, state.revision).is_empty(), "Desperate Escape ended on enemy base")
	check(not Combat.move(state, 1, 100, Vector2(-16, -8), state.revision).is_empty(), "Desperate Escape crossed battlefield boundary")
	retreat_positions(state)
	before = state.duplicate(true)
	rolls = [1, 7]
	check(not Combat.finish_movement(state, 1, state.revision, false, roll).is_empty() and state == before, "Bad post-escape morale partially committed move")
	rolls = [1, 1]
	check(Combat.finish_movement(state, 1, state.revision, false, roll) == "" and state.squads[1].battle_shocked and state.squads[1].fell_back, "Post-escape battle-shock missing")
	# Wounded-model priority and casualty persistence survive placement resets.
	state = fresh(true)
	state.units[100].wounds = 1
	state.squads[1].battle_shocked = true
	rolls = [1, 2]
	check(Combat.begin_movement(state, 1, 100, "desperate_escape", 0, roll) == "", "Battle-shocked escape rejected")
	check(not Combat.allocate_escape_wound(state, 1, 101, state.revision).is_empty(), "Ignored wounded-model allocation priority")
	check(Combat.allocate_escape_wound(state, 1, 100, state.revision) == "" and state.units[100].wounds == 0, "Wounded model not destroyed")
	check(Combat.allocate_escape_wound(state, 1, 101, state.revision) == "", "Remaining wound not allocated")
	check(Combat.finish_movement(state, 1, state.revision, true) == "" and state.units[100].wounds == 0 and state.units[101].wounds == 1 and state.pending_move.hazard_remaining == 0, "Reset revived casualties or hazard rolls")
	check(Combat.move(state, 1, 101, Vector2(-5, -6.5), state.revision) == "", "Survivor could not escape")
	check(Combat.finish_movement(state, 1, state.revision) == "" and state.squads[1].battle_shocked, "Already shocked escape demanded another morale roll")
	# An impossible Fall Back can fail without trapping the phase or refunding casualties.
	state = fresh(true)
	rolls = [1, 6]
	Combat.begin_movement(state, 1, 100, "desperate_escape", 0, roll)
	check(not Combat.abandon_fall_back(state, 1, state.revision).is_empty(), "Abandon bypassed hazard damage")
	Combat.allocate_escape_wound(state, 1, 100, state.revision)
	Combat.move(state, 1, 100, Vector2(-5, -8), state.revision)
	check(Combat.abandon_fall_back(state, 1, state.revision) == "" and state.units[100].wounds == 1 and state.units[100].position == Vector2(-10, -8) and state.pending_move.is_empty(), "Failed Fall Back did not restore positions and retain damage")
	check(not state.squads[1].fell_back and state.squads[1].move_type == "failed_fall_back", "Failed move was counted as a completed Fall Back")
	check(not Combat.begin_movement(state, 1, 100, "desperate_escape", state.revision, roll).is_empty(), "Failed move could reroll or select another move")
	check(Combat.advance_phase(state, 1, state.revision) == "", "Failed Fall Back left phase locked")
	# Hazards can destroy the entire unit; no pending operation may soft-lock it.
	state = fresh(true)
	state.units[100].wounds = 1
	state.units[101].wounds = 0
	rolls = [1]
	Combat.begin_movement(state, 1, 100, "desperate_escape", 0, roll)
	check(Combat.allocate_escape_wound(state, 1, 100, state.revision) == "" and state.pending_move.is_empty() and state.test_winner == 2, "Escape wipeout did not finish elimination exercise")
	# Explicit and implicit stationary selections consume no dice or movement.
	state = fresh(true)
	check(Combat.begin_movement(state, 1, 100, "stationary", 0) == "" and state.squads[1].move_type == "stationary", "Engaged unit cannot remain stationary")
	check(not Combat.move(state, 1, 100, Vector2(-14, -8), state.revision).is_empty(), "Stationary squad activated twice")
	state = fresh()
	check(Combat.advance_phase(state, 1, 0) == "" and state.squads[1].move_type == "stationary", "Skipped unit not marked stationary")
	print("Movement type checks complete: %d failures" % failures)
	quit(1 if failures else 0)
