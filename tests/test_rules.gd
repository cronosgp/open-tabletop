extends SceneTree

const Rules = preload("res://scripts/rules.gd")
var failures := 0

func check(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		failures += 1

func _initialize() -> void:
	var state: Dictionary = Rules.initial_state()
	check(Rules.validate_move(state, 1, 11, Vector2(-7, 0)) == "", "Legal move rejected")
	check(Rules.validate_move(state, 2, 21, Vector2(7, 0)) != "", "Wrong turn accepted")
	check(Rules.validate_move(state, 1, 21, Vector2(7, 0)) != "", "Opponent unit accepted")
	check(Rules.validate_move(state, 1, 11, Vector2(-5, 0)) != "", "Excess distance accepted")
	check(Rules.validate_move(state, 1, 11, Vector2(-16, 0)) != "", "Outside board accepted")
	check(Rules.validate_move(state, 1, 11, Vector2(NAN, 0)) != "", "NaN accepted")
	check(Rules.validate_move(state, 1, 11, Vector2(-12, 4)) != "", "Crossing another base accepted")
	state.units[11].position = Vector2(-5, 0)
	check(Rules.validate_move(state, 1, 11, Vector2(0, 0)) != "", "Terrain accepted")
	state.units[11].moved = true
	check(Rules.validate_move(state, 1, 11, Vector2(-6, 0)) != "", "Second move accepted")
	Rules.end_turn(state)
	check(state.active == 2 and not state.units[11].moved, "Turn transition failed")
	print("Rules checks complete: %d failures" % failures)
	quit(1 if failures else 0)
