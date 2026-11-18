extends SceneTree

const Combat = preload("res://scripts/edition_11/combat_scenario.gd")
const MatchCommands = preload("res://scripts/edition_11/match_command_service.gd")
const PurgationRun = preload("res://scripts/edition_11/purgation_run.gd")

var failures := 0

func check(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		failures += 1

func six() -> int:
	return 6

func fixture(blocker_owner: int = 2, mover_keywords: Array = ["VEHICLE"], blocker_keywords: Array = ["INFANTRY"]) -> Dictionary:
	var state := Combat.initial_state()
	state.phase = "movement"
	state.active = 1
	state.board_size = Vector2(30, 20)
	for id: int in state.units:
		if id not in [100, 200]: state.units[id].wounds = 0
	state.units[100].position = Vector2(-10, -8)
	state.units[100].movement = 12
	state.units[100].keywords = mover_keywords.duplicate()
	state.units[200].position = Vector2(-5, -8)
	state.units[200].owner = blocker_owner
	state.units[200].keywords = blocker_keywords.duplicate()
	return state

func begin_move(state: Dictionary, move_type: String = "normal") -> Dictionary:
	return MatchCommands.execute(state, 1, {
		"kind": MatchCommands.BEGIN_MOVEMENT,
		"model": 100,
		"move_type": move_type,
		"revision": state.revision
	}, six)

func _initialize() -> void:
	var destination := Vector2(0, -8)
	var state := fixture()
	var begin := begin_move(state)
	var move_error := Combat.move(state, 1, 100, destination, state.revision)
	check(str(begin.get("error", "")).is_empty() and move_error.is_empty()
		and state.units[100].position.is_equal_approx(destination),
		"A VEHICLE Normal Move passes through an enemy ordinary model and reaches a free endpoint: begin=%s move=%s" % [str(begin), move_error])

	state = fixture()
	begin = begin_move(state, "advance")
	move_error = Combat.move(state, 1, 100, destination, state.revision)
	check(str(begin.get("error", "")).is_empty() and move_error.is_empty(),
		"A MONSTER/VEHICLE Advance uses the same model-passage permission")

	state = fixture(2, ["MONSTER"], ["VEHICLE"])
	begin = begin_move(state)
	var blocked_large := Combat.validate_move_result(state, 1, 100, destination, state.revision)
	check(str(begin.get("error", "")).is_empty() and str(blocked_large.get("code", "")) == "path_blocked",
		"A MONSTER/VEHICLE Normal Move cannot cross another MONSTER/VEHICLE base")

	state = fixture(1, ["VEHICLE"], ["MONSTER"])
	begin = begin_move(state)
	var blocked_friendly_large := Combat.validate_move_result(state, 1, 100, destination, state.revision)
	check(str(begin.get("error", "")).is_empty() and str(blocked_friendly_large.get("code", "")) == "path_blocked",
		"The special Normal Move permission does not let a VEHICLE pass through a friendly MONSTER")
	check(not Combat.Contact.clear_path(state, 100, destination, 12.0, false, false, -1.0, "normal"),
		"A Normal Move cannot pass through a friendly MONSTER or VEHICLE")
	check(Combat.Contact.clear_path(state, 100, destination, 12.0, false, false, -1.0, "charge"),
		"Other move types retain the source FAQ permission for MONSTER/VEHICLE models to pass through friendly units")

	state = fixture(1, ["VEHICLE"], ["INFANTRY"])
	check(Combat.Contact.clear_path(state, 100, destination, 12.0, false, false, -1.0, "normal"),
		"A VEHICLE Normal Move can pass through a friendly ordinary model")

	state = fixture(2, ["INFANTRY"], ["INFANTRY"])
	begin = begin_move(state)
	var blocked_ordinary := Combat.validate_move_result(state, 1, 100, destination, state.revision)
	check(str(begin.get("error", "")).is_empty() and str(blocked_ordinary.get("code", "")) == "path_blocked",
		"An ordinary model cannot inherit the MONSTER/VEHICLE permission to pass through an enemy model")
	state = fixture(2, ["INFANTRY"], ["VEHICLE"])
	check(not Combat.Contact.clear_path(state, 100, destination, 12.0, false, false, -1.0, "normal"),
		"An ordinary model remains blocked by an enemy MONSTER or VEHICLE base")

	state = fixture()
	begin = begin_move(state)
	var overlapping_destination := Combat.validate_move_result(state, 1, 100, Vector2(-5, -8), state.revision)
	check(str(begin.get("error", "")).is_empty() and str(overlapping_destination.get("code", "")) == "destination_overlap",
		"Passage through an ordinary enemy model does not allow ending a move on its base")

	state = fixture()
	check(not Combat.Contact.clear_path(state, 100, destination, 12.0, false, false, -1.0, "charge"),
		"The Normal/Advance passage rule does not extend to a Charge move")

	state = fixture()
	state["unit_abilities"] = {"window": {
		"kind": PurgationRun.PLACEMENT,
		"positions": {100: state.units[100].position},
		"origins": {100: state.units[100].position},
		"distance": 12
	}}
	var purgation_error := PurgationRun.position_error(state, 100, destination)
	check(purgation_error.is_empty(),
		"Purgation Run applies the same Normal Move passage rule to the Land Speeder")

	print("MONSTER/VEHICLE model-passage checks complete: %d failures" % failures)
	quit(1 if failures else 0)
