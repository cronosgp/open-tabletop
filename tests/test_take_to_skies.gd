extends SceneTree

const Combat = preload("res://scripts/edition_11/combat_scenario.gd")
const MatchCommands = preload("res://scripts/edition_11/match_command_service.gd")

var failures := 0

func check(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		failures += 1

func six() -> int: return 6
func three() -> int: return 3

func fixture(phase: String, flying: bool = true, hover: bool = false, enemy_x: float = -4.0) -> Dictionary:
	var state := Combat.initial_state()
	state.phase = phase
	state.active = 1
	for id: int in state.units:
		if id not in [100, 101, 200]: state.units[id].wounds = 0
	state.units[100].position = Vector2(-15, -8)
	state.units[101].position = Vector2(-15, -6.5)
	state.units[200].position = Vector2(enemy_x, -8)
	state.units[100].movement = 12
	state.units[101].movement = 12
	if flying:
		state.units[100].keywords.append("FLY")
		state.units[101].keywords.append("FLY")
	if hover: state.units[100].core_abilities = ["Hover"]
	return state

func _initialize() -> void:
	var state := fixture("movement", false, false, -10.0)
	var before := var_to_str(state)
	var illegal := MatchCommands.execute(state, 1, {"kind": MatchCommands.BEGIN_MOVEMENT, "model": 100, "move_type": "normal", "revision": state.revision, "take_to_skies": true}, six)
	check(not str(illegal.get("error", "")).is_empty() and var_to_str(state) == before,
		"A non-FLY unit cannot declare Take to the Skies or change match state")
	var ordinary_begin := MatchCommands.execute(state, 1, {"kind": MatchCommands.BEGIN_MOVEMENT, "model": 100, "move_type": "normal", "revision": state.revision}, six)
	var ordinary_path_error := Combat.move(state, 1, 100, Vector2(-5, -8), state.revision)
	check(str(ordinary_begin.get("error", "")).is_empty() and not ordinary_path_error.is_empty(),
		"An ordinary move cannot pass through an enemy model base")

	state = fixture("movement", true, false, -10.0)
	var skies_begin := MatchCommands.execute(state, 1, {"kind": MatchCommands.BEGIN_MOVEMENT, "model": 100, "move_type": "normal", "revision": state.revision, "take_to_skies": true}, six)
	check(str(skies_begin.get("error", "")).is_empty() and state.pending_move.get("take_to_skies", false)
		and is_equal_approx(float(state.pending_move.get("take_to_skies_penalty", -1.0)), 2.0)
		and is_equal_approx(Combat.movement_remaining(state, 100), 10.0)
		and Combat.Terrain.take_to_skies_active(state, 100) and Combat.Terrain.take_to_skies_active(state, 101),
		"A FLY unit records its declaration and applies the two-inch penalty to each model before movement")
	var skies_path_error := Combat.move(state, 1, 100, Vector2(-5, -8), state.revision)
	check(skies_path_error.is_empty() and state.pending_move.paths.get(100, []).size() == 1,
		"A declared FLY move can cross an enemy model while staying within the reduced maximum distance")

	state = fixture("movement", true)
	state.units[100].position = Vector2(-5, 0)
	state.units[101].position = Vector2(-5, 2)
	state.units[200].position = Vector2(15, 0)
	state.units[100].keywords = ["VEHICLE", "FLY"]
	state.units[101].keywords = ["VEHICLE", "FLY"]
	var dense_begin := MatchCommands.execute(state, 1, {"kind": MatchCommands.BEGIN_MOVEMENT, "model": 100, "move_type": "normal", "revision": state.revision}, six)
	var ordinary_terrain_error := Combat.move(state, 1, 100, Vector2(-1, 0), state.revision)
	check(str(dense_begin.get("error", "")).is_empty() and not ordinary_terrain_error.is_empty(),
		"A non-Infantry FLY model without the declaration cannot cross a dense ruin wall")
	state = fixture("movement", true)
	state.units[100].position = Vector2(-5, 0)
	state.units[101].position = Vector2(-5, 2)
	state.units[200].position = Vector2(15, 0)
	state.units[100].keywords = ["VEHICLE", "FLY"]
	state.units[101].keywords = ["VEHICLE", "FLY"]
	var skies_terrain_begin := MatchCommands.execute(state, 1, {"kind": MatchCommands.BEGIN_MOVEMENT, "model": 100, "move_type": "normal", "revision": state.revision, "take_to_skies": true}, six)
	var skies_terrain_error := Combat.move(state, 1, 100, Vector2(-1, 0), state.revision)
	check(str(skies_terrain_begin.get("error", "")).is_empty() and skies_terrain_error.is_empty(),
		"A declared FLY model can cross a dense ruin wall on the default 11e terrain layout")

	state = fixture("movement", true)
	state.units[100].position = Vector2(-5, 0)
	state.units[101].position = Vector2(-5, 2)
	state.units[200].position = Vector2(15, 0)
	state.units[100].movement = 6
	state.units[101].movement = 6
	var vertical_begin := MatchCommands.execute(state, 1, {"kind": MatchCommands.BEGIN_MOVEMENT, "model": 100, "move_type": "normal", "revision": state.revision, "take_to_skies": true}, six)
	var vertical_error := Combat.move(state, 1, 100, Vector2(-1, 0), state.revision, 3.0)
	check(str(vertical_begin.get("error", "")).is_empty() and vertical_error.is_empty()
		and is_equal_approx(float(state.pending_move.get("take_to_skies_penalty", -1.0)), 2.0)
		and state.pending_move.paths.get(100, []).size() == 1,
		"Take to the Skies ignores the three-inch vertical cost while retaining horizontal cost and the reduced move limit")

	state = fixture("movement", true, true)
	var hover_begin := MatchCommands.execute(state, 1, {"kind": MatchCommands.BEGIN_MOVEMENT, "model": 100, "move_type": "normal", "revision": state.revision, "take_to_skies": true}, six)
	check(str(hover_begin.get("error", "")).is_empty() and is_zero_approx(float(state.pending_move.get("take_to_skies_penalty", -1.0)))
		and is_equal_approx(Combat.movement_remaining(state, 100), 12.0),
		"HOVER preserves the full movement allowance while the unit takes to the skies")

	state = fixture("movement", true)
	var advance_begin := MatchCommands.execute(state, 1, {"kind": MatchCommands.BEGIN_MOVEMENT, "model": 100, "move_type": "advance", "revision": state.revision, "take_to_skies": true}, three)
	check(str(advance_begin.get("error", "")).is_empty() and int(state.pending_move.get("bonus", -1)) == 3
		and bool(state.pending_move.get("take_to_skies", false))
		and is_equal_approx(Combat.movement_remaining(state, 100), 13.0),
		"The Advance is rolled after declaration, then uses movement plus the D6 minus two inches")

	state = fixture("charge", true, false, -5.5)
	var charge_begin := MatchCommands.execute(state, 1, {"kind": MatchCommands.CHARGE_ROLL, "model": 100, "revision": state.revision, "take_to_skies": true}, six)
	check(str(charge_begin.get("error", "")).is_empty() and int(state.pending_charge.get("maximum", -1)) == 10
		and bool(state.pending_charge.get("take_to_skies", false)),
		"A FLY Charge is rolled after declaration and its target range uses the reduced maximum")
	var charge_target := MatchCommands.execute(state, 1, {"kind": MatchCommands.CHARGE_TARGET, "target": 200, "revision": state.revision}, six)
	var charge_move := Combat.begin_contact_move(state, 1, 100, "charge", state.revision)
	check(str(charge_target.get("error", "")).is_empty() and charge_move.is_empty()
		and bool(state.pending_contact.get("take_to_skies", false)) and Combat.Terrain.take_to_skies_active(state, 100),
		"The declaration persists from Charge roll and target selection into contact placement")

	state = fixture("charge", true, false, -3.0)
	var shortened_charge := MatchCommands.execute(state, 1, {"kind": MatchCommands.CHARGE_ROLL, "model": 100, "revision": state.revision, "take_to_skies": true}, six)
	check(str(shortened_charge.get("error", "")).is_empty() and state.pending_charge.is_empty() and "failed" in str(shortened_charge.get("message", "")).to_lower(),
		"A target beyond the reduced Take to the Skies distance cannot be selected for the Charge")

	state = fixture("charge", true, true, -3.0)
	var hover_charge := MatchCommands.execute(state, 1, {"kind": MatchCommands.CHARGE_ROLL, "model": 100, "revision": state.revision, "take_to_skies": true}, six)
	check(str(hover_charge.get("error", "")).is_empty() and int(state.pending_charge.get("maximum", -1)) == 12,
		"HOVER removes the Take to the Skies Charge-distance penalty")

	print("Take to the Skies checks complete: %d failures" % failures)
	quit(1 if failures else 0)
