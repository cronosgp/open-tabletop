extends SceneTree

const Combat = preload("res://scripts/edition_11/combat_scenario.gd")
const UnitAbilities = preload("res://scripts/edition_11/unit_abilities.gd")

var failures := 0

func check(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		failures += 1

func six() -> int:
	return 6

func ctan_state() -> Dictionary:
	var state := Combat.initial_state("legacy-solid-v1")
	state.phase = "movement"
	for id: int in state.units:
		if id not in [100, 200]: state.units[id].wounds = 0
	state.units[100].definition_id = "40kdc:11e:necrons:transcendent-ctan"
	state.units[100].keywords = ["NECRONS", "MONSTER", "CHARACTER", "FLY", "TRANSCENDENT C’TAN"]
	state.units[100].movement = 8
	state.units[100].radius = 1.0
	state.units[100].max_wounds = 16
	state.units[100].wounds = 16
	state.units[100].position = Vector2(-10, -8)
	state.units[200].position = Vector2(-4, -8)
	UnitAbilities.enable(state)
	return state

func _initialize() -> void:
	var state := ctan_state()
	check(Combat.movement_choice_error(state, 1, 100, "transdimensional_advance", state.revision).is_empty(), "The enabled Transcendent C’tan can choose its special Advance")
	var ordinary_state := Combat.initial_state("legacy-solid-v1")
	ordinary_state.phase = "movement"
	UnitAbilities.enable(ordinary_state)
	check(not Combat.movement_choice_error(ordinary_state, 1, 100, "transdimensional_advance", ordinary_state.revision).is_empty(), "Transdimensional Advance is unavailable without the source ability")
	check(Combat.begin_movement(state, 1, 100, "transdimensional_advance", state.revision, six).is_empty(), "Transdimensional Displacement begins as an Advance")
	check(state.pending_move.get("move_type", "") == "advance" and state.pending_move.get("transdimensional_displacement", false) and state.pending_move.get("bonus", -1) == 6 and is_inf(Combat.movement_remaining(state, 100)), "Special Advance retains the D6 and removes the maximum distance")
	check(not Combat.move(state, 1, 100, state.units[200].position, state.revision).is_empty(), "Transdimensional movement cannot end overlapping an enemy base")
	check(Combat.move(state, 1, 100, Vector2(0, -8), state.revision).is_empty(), "Transdimensional path may cross the enemy model")
	check(not Combat.finish_movement(state, 1, state.revision).is_empty() and not state.pending_move.is_empty(), "The C’tan cannot confirm within 8 inches of an enemy unit")
	check(Combat.move(state, 1, 100, Vector2(8, -8), state.revision).is_empty() and Combat.finish_movement(state, 1, state.revision).is_empty(), "The C’tan can exceed Advance range and confirm more than 8 inches from the enemy")
	check(state.squads[1].advanced and is_equal_approx(float(state.squads[1].moved_distance), 18.0), "The unbounded move retains its Advance restrictions and measured path")
	var skies_state := ctan_state()
	skies_state.units[100].position = Vector2(-10, -4)
	skies_state.units[200].position = Vector2(-4, -4)
	check(Combat.begin_movement(skies_state, 1, 100, "transdimensional_advance", skies_state.revision, six, false, false, true).is_empty(), "Take to the Skies can be declared before the Transcendent C’tan’s Advance")
	check(skies_state.pending_move.get("take_to_skies", false), "Take to the Skies remains recorded on the pending Transcendent Advance")
	check(is_inf(Combat.movement_remaining(skies_state, 100)), "Take to the Skies does not restore a maximum distance")
	var skies_move_error := Combat.move(skies_state, 1, 100, Vector2(13, -4), skies_state.revision)
	check(skies_move_error.is_empty(), "Take to the Skies permits the unlimited Transcendent Advance through terrain: " + skies_move_error)
	check(Combat.finish_movement(skies_state, 1, skies_state.revision).is_empty(), "Combined Transdimensional Displacement and Take to the Skies confirms at a legal endpoint")
	print("Transdimensional Displacement checks complete: %d failures" % failures)
	quit(1 if failures > 0 else 0)
