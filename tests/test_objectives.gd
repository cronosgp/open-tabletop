extends SceneTree
const Combat = preload("res://scripts/edition_11/combat_scenario.gd")
const Objectives = Combat.Objectives
var failures := 0
func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1
func six() -> int: return 6
func fixture() -> Dictionary:
	var state := Combat.initial_state(Combat.Terrain.DEFAULT_LAYOUT, Objectives.TRAINING)
	for id: int in state.units:
		if id not in [100, 200]: state.units[id].wounds = 0
	state.units[100].position = Vector2(1, 0)
	state.units[200].position = Vector2(12, 0)
	state.squads[1].stats.objective_control = 2
	state.squads[2].stats.objective_control = 2
	return state
func _initialize() -> void:
	var state := fixture()
	var objective: Dictionary = state.mission.objectives[0]
	check(objective.controller == 0, "Objectives start uncontrolled even with models in range")
	check(state.pack_hash != Combat.initial_state().pack_hash, "Mission identity participates in peer compatibility")
	check(Combat.initial_state(Combat.Terrain.DEFAULT_LAYOUT, "unknown").has("error"), "Unknown mission rejected")
	state.phase = "movement"
	check(Combat.advance_phase(state, 1, 0).is_empty() and objective.controller == 1, "Phase boundary captures terrain objective")
	state.units[200].position = Vector2(2, 0)
	Objectives.resolve_control(state, Callable(Combat.Morale, "objective_control"))
	check(objective.controller == 0 and objective.levels == {1: 2, 2: 2}, "Equal OC yields neutral objective")
	state.squads[2].battle_shocked = true
	Objectives.resolve_control(state, Callable(Combat.Morale, "objective_control"))
	check(objective.controller == 1 and objective.levels[2] == 0, "Battle-shocked model contributes zero")
	check(Objectives.secure(state, 0, 2) != "" and Objectives.secure(state, 0, 1).is_empty(), "Secure requires current control")
	state.squads[2].battle_shocked = false
	Objectives.resolve_control(state, Callable(Combat.Morale, "objective_control"))
	check(objective.controller == 1 and objective.secured == 1, "Secured owner keeps control at equal positive OC")
	state.squads[2].battle_shocked = true
	state.units[100].position = Vector2(-12, 0)
	Objectives.resolve_control(state, Callable(Combat.Morale, "objective_control"))
	check(objective.controller == 1 and objective.secured == 1 and Objectives.controlling_squads(state, objective, Callable(Combat.Morale, "objective_control")).is_empty(), "Secured control persists at zero OC without controlling units")
	state.squads[2].battle_shocked = false
	Objectives.resolve_control(state, Callable(Combat.Morale, "objective_control"))
	check(objective.controller == 2 and objective.secured == 0, "Greater enemy OC removes secured status")
	state.units[100].position = Vector2(1, 0)
	state.units[200].wounds = 0
	Objectives.resolve_control(state, Callable(Combat.Morale, "objective_control"))
	check(Objectives.controlling_squads(state, objective, Callable(Combat.Morale, "objective_control")) == [1], "Only living positive-OC in-range squads control")
	var marker := {"kind": "marker", "position": Vector2.ZERO}
	var model: Dictionary = state.units[100].duplicate(true)
	model.position = Vector2(3 + Objectives.MARKER_RADIUS + model.radius, 0)
	check(Objectives.in_range(model, marker), "Marker range measured to edge of 40mm disk")
	model.position.x += 0.01
	check(not Objectives.in_range(model, marker), "Marker outside 3-inch edge boundary")
	model.position = Vector2.ZERO
	model.elevation = 5.01
	check(not Objectives.in_range(model, marker), "Marker vertical limit")
	state = fixture()
	state.phase = "command"
	state.squads[1].battle_shocked = true
	check(Combat.advance_phase(state, 1, 0, six).is_empty() and state.mission.objectives[0].controller == 1, "Command morale resolves before control")
	var before := var_to_str(state)
	check(not Combat.advance_phase(state, 2, state.revision, six).is_empty() and before == var_to_str(state), "Wrong player cannot trigger control or points")
	check(not Combat.advance_phase(state, 1, 0, six).is_empty() and before == var_to_str(state), "Stale request leaves mission unchanged")
	state.phase = "movement"
	state.pending_move = {"squad": 1}
	before = var_to_str(state)
	check(not Combat.advance_phase(state, 1, state.revision).is_empty() and before == var_to_str(state), "Unconfirmed movement cannot capture or score")
	state.pending_move = {}
	state.phase = "end_turn"
	state.active = 2
	check(Combat.advance_phase(state, 2, state.revision).is_empty() and state.mission.scores[1] == 1 and state.round == 2, "Round end scores once and advances")
	check(Objectives.score_round(state) != "", "Next round can score through internal trigger")
	check(Objectives.score_round(state).is_empty() and state.mission.scores[1] == 2, "Round scoring idempotent")
	state = fixture()
	state.round = 5
	state.active = 2
	state.phase = "end_turn"
	Objectives.resolve_control(state, Callable(Combat.Morale, "objective_control"))
	check(Combat.advance_phase(state, 2, 0).is_empty() and state.test_winner == 1 and state.round == 5, "Fifth round ends with points victory")
	before = var_to_str(state)
	check(not Combat.advance_phase(state, 2, state.revision).is_empty() and var_to_str(state) == before, "Finished mission rejects further scoring")
	state = fixture()
	for id: int in state.units: state.units[id].wounds = 0
	state.round = 5
	state.active = 2
	state.phase = "end_turn"
	check(Combat.advance_phase(state, 2, 0).is_empty() and state.test_winner == -1, "Empty battlefield completes as draw")
	state = fixture()
	for id: int in state.units: state.units[id].wounds = 0
	var steps := 0
	while state.test_winner == 0 and steps < 100:
		var error := Combat.advance_phase(state, Combat.actor(state), state.revision, six)
		check(error.is_empty(), "Full five-round mission advances: " + error)
		if not error.is_empty(): break
		steps += 1
	check(state.test_winner == -1 and state.round == 5 and state.mission.scored_rounds == [1, 2, 3, 4, 5], "Complete phase sequence scores exactly five rounds without an elimination early exit")
	print("Objective checks complete: %d failures" % failures)
	quit(0 if failures == 0 else 1)
