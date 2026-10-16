extends SceneTree

const Combat = preload("res://scripts/edition_11/combat_scenario.gd")
var failures := 0

func check(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		failures += 1

func fresh() -> Dictionary:
	var state := Combat.initial_state("legacy-solid-v1")
	state.phase = "movement"
	return state

func _initialize() -> void:
	var state := fresh()
	var other: Vector2 = state.units[101].position
	check(Combat.move(state, 1, 100, Vector2(-13, -4), state.revision) == "", "Individual movement rejected")
	check(state.units[101].position == other, "Squadmate moved with selected miniature")
	check(is_equal_approx(Combat.movement_remaining(state, 100), 5.0), "Selected model budget incorrect")
	check(is_equal_approx(Combat.movement_remaining(state, 101), 6.0), "Squadmate budget consumed")
	check(not Combat.advance_phase(state, 1, state.revision).is_empty(), "Phase advanced with unresolved movement")
	check(not Combat.finish_movement(state, 2, state.revision).is_empty(), "Opponent confirmed movement")
	check(not Combat.finish_movement(state, 1, state.revision - 1).is_empty(), "Stale confirmation accepted")
	check(Combat.finish_movement(state, 1, state.revision) == "", "Coherent move not confirmed")
	check(state.squads[1].moved and state.pending_move.is_empty(), "Activation not completed")
	check(not Combat.move(state, 1, 101, Vector2(-13, -2), state.revision).is_empty(), "Committed squad activated again")
	check(Combat.advance_phase(state, 1, state.revision) == "", "Confirmed squad could not advance phase")
	state = fresh()
	check(Combat.move(state, 1, 100, Vector2(-12.8, -4), state.revision) == "", "First segment rejected")
	check(Combat.move(state, 1, 100, Vector2(-12.8, -6), state.revision) == "", "Second segment rejected")
	check(not Combat.finish_movement(state, 1, state.revision).is_empty(), "Incoherent squad confirmed")
	check(not state.pending_move.is_empty(), "Failed coherency check discarded editable movement")
	check(Combat.move(state, 1, 101, Vector2(-12, -4), state.revision) == "", "Squadmate cannot repair coherency")
	for id in [102, 103, 104]:
		check(Combat.move(state, 1, id, state.units[id].position + Vector2(0, -2), state.revision) == "", "Could not reconnect the rest of the squad")
	check(Combat.finish_movement(state, 1, state.revision) == "", "Repaired squad could not confirm")
	check(is_equal_approx(state.squads[1].moved_distance, 2.8), "Heavy must use longest accumulated model path")
	state = fresh()
	check(Combat.move(state, 1, 100, Vector2(-12, -8), state.revision) == "", "Long first segment rejected")
	check(not Combat.move(state, 1, 100, Vector2(-12, -5), state.revision).is_empty(), "Backtracking bypassed accumulated movement budget")
	check(Combat.move(state, 1, 100, Vector2(-12, -6), state.revision) == "", "Remaining segment rejected")
	check(is_zero_approx(Combat.movement_remaining(state, 100)), "Movement did not exhaust at six inches")
	check(Combat.finish_movement(state, 1, state.revision, true) == "", "Cancellation failed")
	check(state.units[100].position == Vector2(-12, -4) and not state.units[100].moved and not state.squads[1].moved, "Cancellation failed to restore the original state")
	check(is_equal_approx(Combat.movement_remaining(state, 100), 6), "Cancellation did not restore the uncommitted budget")
	check(not Combat.finish_movement(state, 1, state.revision).is_empty(), "Empty movement could be confirmed")
	state = fresh()
	check(not Combat.move(state, 1, 100, state.units[101].position, state.revision).is_empty(), "Friendly bases overlapped at destination")
	check(Combat.move(state, 1, 100, Vector2(-13.3, 1), state.revision) == "", "Legal path through friendly models rejected")
	Combat.finish_movement(state, 1, state.revision, true)
	check(not Combat.move(state, 1, 104, Vector2(-8, 4), state.revision).is_empty(), "Individual movement crossed solid terrain")
	check(not Combat.move(state, 1, 100, Vector2(-16, -4), state.revision).is_empty(), "Base left the board")
	check(not Combat.move(state, 1, 100, Vector2(NAN, -4), state.revision).is_empty(), "Non-finite destination accepted")
	state.units[200].position = Vector2(-7, -4)
	check(Combat.move(state, 1, 100, Vector2(-9, -4), state.revision) == "", "Staged segment cannot enter engagement range")
	check(not Combat.finish_movement(state, 1, state.revision).is_empty(), "Normal move finished engaged")
	check(Combat.move(state, 1, 100, Vector2(-12, -4), state.revision) == "", "Model could not leave engagement during a draft")
	check(Combat.finish_movement(state, 1, state.revision) == "", "Unengaged final position rejected after temporary engagement")
	# A straight path may pass within 2 inches if it avoids enemy bases and ends clear.
	state = fresh()
	for id: int in state.units:
		if id not in [100, 200]: state.units[id].wounds = 0
	state.units[100].position = Vector2(-13, -8)
	state.units[200].position = Vector2(-10, -6)
	check(Combat.move(state, 1, 100, Vector2(-7, -8), state.revision) == "", "Legal transit through enemy engagement rejected")
	check(Combat.finish_movement(state, 1, state.revision) == "", "Legal transit could not be confirmed")
	# Check connectivity separately from neighbour and diameter conditions.
	var split := {"units": {}}
	for index in range(4):
		split.units[index] = {"squad": 1, "wounds": 1, "radius": 0.5, "position": Vector2([0, 1, 6, 7][index], 0)}
	check(not Combat.Contact.coherent(split, 1), "Disconnected pairs accepted as coherent")
	split.units[2].position = Vector2(3.5, 0)
	split.units[3].position = Vector2(5, 0)
	check(Combat.Contact.coherent(split, 1), "Contiguous chain rejected")
	print("Individual movement checks complete: %d failures" % failures)
	quit(1 if failures else 0)
