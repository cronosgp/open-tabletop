extends SceneTree
const Combat = preload("res://scripts/edition_11/combat_scenario.gd")
var failures := 0
func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1
func fixture() -> Dictionary:
	var state := Combat.initial_state(Combat.Terrain.DEFAULT_LAYOUT, Combat.Objectives.TRAINING)
	for id: int in state.units:
		if id not in [100, 200]: state.units[id].wounds = 0
	state.units[100].position = Vector2(5, 0)
	state.units[200].position = Vector2(12, 8)
	state.phase = "fight"
	state.fight_step = "consolidate"
	state.fight_actor = 1
	state.squads[1].fight_eligible = true
	state.squads[1].fought = true
	return state
func begin(state: Dictionary, objective: int = 0) -> String:
	return Combat.begin_contact_move(state, 1, 100, "consolidate", state.revision, [], objective)
func _initialize() -> void:
	var state := fixture()
	check(begin(state).is_empty() and state.pending_contact.kind == "consolidate_objective" and state.pending_contact.objective == 0, "Objective mode selected when no enemy within 3 inches")
	check(Combat.stage_contact_move(state, 1, 100, Vector2(3.5, 0), state.revision).is_empty(), "Move into ruin objective")
	check(Combat.finish_contact_move(state, 1, state.revision).is_empty() and state.pending_contact.is_empty(), "Objective consolidation confirms")
	check(state.mission.objectives[0].controller == 0, "Consolidation alone does not capture before end of phase")
	check(Combat.advance_phase(state, Combat.actor(state), state.revision).is_empty() and state.mission.objectives[0].controller == 1, "End Fight control captures objective")
	state = fixture()
	check(begin(state).is_empty(), "Begin cancel fixture")
	Combat.stage_contact_move(state, 1, 100, Vector2(4, 0), state.revision)
	var before := var_to_str(state)
	check(not Combat.finish_contact_move(state, 1, state.revision).is_empty() and before == var_to_str(state), "Closer but reachable out-of-range endpoint rejected without mutation")
	check(Combat.finish_contact_move(state, 1, state.revision, true).is_empty() and state.units[100].position == Vector2(5, 0), "Cancel restores objective move")
	state = fixture()
	before = var_to_str(state)
	check(not begin(state, 99).is_empty() and var_to_str(state) == before, "Invalid objective rejected atomically")
	state.units[200].position = Vector2(8, 0)
	before = var_to_str(state)
	check(not begin(state).is_empty() and before == var_to_str(state), "Nearby enemy mode takes priority")
	state.units[200].position = Vector2(6.8, 0)
	check(not begin(state).is_empty(), "Ongoing engagement takes priority")
	state = fixture()
	state.units[100].position = Vector2(6.7, 0)
	check(not begin(state).is_empty(), "Objective beyond 3-inch base-edge selection range rejected")
	state = fixture()
	state.squads[1].fight_eligible = false
	check(not begin(state).is_empty(), "Ineligible squad cannot consolidate")
	state = fixture()
	state.units[101].wounds = 2
	state.units[101].position = Vector2(7, 0)
	check(begin(state).is_empty(), "Unit with distant member can begin")
	check(Combat.stage_contact_move(state, 1, 100, Vector2(3.5, 0), state.revision).is_empty(), "Front model reaches objective")
	check(Combat.stage_contact_move(state, 1, 101, Vector2(5.5, 0), state.revision).is_empty(), "Distant model approaches")
	check(Combat.finish_contact_move(state, 1, state.revision).is_empty(), "Member unable to reach within 3 inches may finish closer while unit reaches objective")
	state = fixture()
	state.units[200].position = Vector2(0.5, 0)
	check(begin(state).is_empty(), "Enemy initially outside 3-inch selection radius")
	Combat.stage_contact_move(state, 1, 100, Vector2(3.5, 0), state.revision)
	check(not Combat.finish_contact_move(state, 1, state.revision).is_empty(), "Objective consolidation cannot finish engaged")
	state = fixture()
	state.units[100].position = Vector2(2, 0)
	check(begin(state).is_empty(), "Model already within objective can consolidate")
	Combat.stage_contact_move(state, 1, 100, Vector2(2, 1), state.revision)
	check(Combat.finish_contact_move(state, 1, state.revision).is_empty(), "Within-range model can reposition without strict closer requirement")
	print("Objective consolidation: %d failures" % failures)
	quit(0 if failures == 0 else 1)
