extends SceneTree
const Combat = preload("res://scripts/edition_11/combat_scenario.gd")
const Actions = Combat.Actions
var failures := 0
func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1
func six() -> int: return 6
func fixture() -> Dictionary:
	var state := Combat.initial_state(Combat.Terrain.DEFAULT_LAYOUT, Combat.Objectives.TRAINING)
	for id: int in state.units:
		if id not in [100, 200]: state.units[id].wounds = 0
	state.units[100].position = Vector2(2, 0)
	state.units[200].position = Vector2(10, 0)
	state.phase = "shooting"
	Combat.Objectives.resolve_control(state)
	return state
func start(state: Dictionary) -> String:
	return Combat.start_action(state, 1, 100, 0, state.revision)
func _initialize() -> void:
	var state := fixture()
	check(start(state).is_empty() and not state.squads[1].action.is_empty(), "Start custom action on controlled objective")
	var before := var_to_str(state)
	check(not start(state).is_empty() and var_to_str(state) == before, "Repeat start rejected atomically")
	check(not Combat.shoot(state, 1, 100, 200, state.revision, true, six).error.is_empty() and before == var_to_str(state), "Action prevents shooting without dice/state mutation")
	check(Combat.advance_phase(state, 1, state.revision).is_empty(), "Action survives end Shooting")
	before = var_to_str(state)
	check(not Combat.declare_charge(state, 1, 100, state.revision, six).error.is_empty() and before == var_to_str(state), "Action prevents declaring charge")
	check(Combat.advance_phase(state, 1, state.revision).is_empty(), "Advance through Charge")
	check(Combat.advance_phase(state, 1, state.revision).is_empty() and state.phase == "end_turn", "Unengaged Fight advances to End of Turn")
	check(state.squads[1].action.is_empty() and state.squads[1].last_action.status == "completed" and state.mission.objectives[0].secured == 1, "Completion secures objective at End of Turn")
	check(Actions.shooting_blocked(state, 1) and Actions.charge_blocked(state, 1), "Restrictions persist after completion until turn ends")
	check(Combat.advance_phase(state, 1, state.revision).is_empty() and not Actions.charge_blocked(state, 1), "Restrictions expire next turn")
	for gate in ["battle_shocked", "advanced", "fell_back"]:
		state = fixture()
		state.squads[1][gate] = true
		check(not start(state).is_empty(), "Eligibility gate: " + gate)
	state = fixture()
	state.squads[1].stats.objective_control = 0
	check(not start(state).is_empty(), "Zero OC cannot start action")
	for keyword in ["AIRCRAFT", "FORTIFICATION"]:
		state = fixture()
		state.units[100].keywords = [keyword]
		check(not start(state).is_empty(), "Forbidden action keyword: " + keyword)
	state = fixture()
	state.units[200].position = Vector2(4, 0)
	check(not start(state).is_empty(), "Engaged non-Titanic cannot start")
	state.units[100].keywords = ["TITANIC"]
	check(start(state).is_empty() and not Actions.shooting_blocked(state, 1) and Actions.charge_blocked(state, 1), "Titanic exemption permits engagement and shooting but no charge")
	state = fixture()
	state.squads[1].shot = true
	check(not start(state).is_empty(), "Training action excludes units that already shot")
	state = fixture()
	before = var_to_str(state)
	check(not Combat.start_action(state, 2, 100, 0, 0).is_empty() and before == var_to_str(state), "Wrong player rejected")
	check(not Combat.start_action(state, 1, 200, 0, 0).is_empty() and before == var_to_str(state), "Opponent model rejected")
	check(not Combat.start_action(state, 1, 100, 99, 0).is_empty() and before == var_to_str(state), "Invalid target rejected")
	check(not Combat.start_action(state, 1, 100, 0, -1).is_empty() and before == var_to_str(state), "Stale action rejected")
	state.phase = "movement"
	check(not start(state).is_empty(), "Wrong start phase rejected")
	state = fixture()
	state.mission.actions = []
	check(not start(state).is_empty(), "Unavailable action rejected")
	for reason in ["shock", "destroyed", "left"]:
		state = fixture()
		start(state)
		if reason == "shock": state.squads[1].battle_shocked = true
		elif reason == "destroyed": state.units[100].wounds = 0
		else: state.units[100].on_battlefield = false
		Actions.reconcile(state)
		check(state.squads[1].action.is_empty() and state.squads[1].last_action.status == "failed" and Actions.charge_blocked(state, 1), "Interruption retains turn restrictions: " + reason)
	state = fixture()
	start(state)
	state.phase = "movement" # Exercise the future forced/out-of-phase movement hook.
	check(Combat.move(state, 1, 100, Vector2(2, 1), state.revision).is_empty(), "Draft move after action")
	check(Combat.finish_movement(state, 1, state.revision, true).is_empty() and not state.squads[1].action.is_empty(), "Cancelled draft does not fail action")
	Combat.move(state, 1, 100, Vector2(2, 1), state.revision)
	check(Combat.finish_movement(state, 1, state.revision).is_empty() and state.squads[1].last_action.status == "failed", "Committed normal move fails action")
	state = fixture()
	start(state)
	state.phase = "fight"
	state.fight_step = "consolidate"
	state.fight_actor = 1
	state.squads[1].fight_eligible = true
	state.squads[1].fought = true
	check(Combat.begin_contact_move(state, 1, 100, "consolidate", state.revision, [], 0).is_empty(), "Begin consolidation while acting")
	Combat.stage_contact_move(state, 1, 100, Vector2(2, 1), state.revision)
	check(Combat.finish_contact_move(state, 1, state.revision).is_empty() and not state.squads[1].action.is_empty(), "Consolidation does not interrupt action")
	state = fixture()
	start(state)
	state.units[100].position = Vector2(6, 0)
	Combat.Objectives.resolve_control(state)
	Actions.complete_end_turn(state)
	check(state.squads[1].last_action.status == "failed" and state.mission.objectives[0].secured == 0, "Training completion requires control and range")
	state = fixture()
	start(state)
	Actions.complete_end_turn(state)
	before = var_to_str(state)
	Actions.complete_end_turn(state)
	check(before == var_to_str(state), "Action completion is idempotent")
	state = fixture()
	state.squads[3] = state.squads[1].duplicate(true)
	state.units[300] = state.units[100].duplicate(true)
	state.units[300].squad = 3
	state.units[300].position = Vector2(1, 1)
	start(state)
	before = var_to_str(state)
	check(not Combat.start_action(state, 1, 300, 0, state.revision).is_empty() and before == var_to_str(state), "Army use limit includes a different eligible unit")
	state = fixture()
	start(state)
	state.phase = "fight"
	state.fight_step = "pile_in"
	state.fight_actor = 1
	state.units[200].position = Vector2(4, 0)
	check(Combat.begin_contact_move(state, 1, 100, "pile_in", state.revision).is_empty(), "Acting unit may pile in after becoming engaged")
	check(Combat.stage_contact_move(state, 1, 100, Vector2(2.5, 0), state.revision).is_empty(), "Pile-in action fixture path")
	check(Combat.finish_contact_move(state, 1, state.revision).is_empty() and not state.squads[1].action.is_empty(), "Pile-in and becoming engaged do not interrupt action")
	state = fixture()
	start(state)
	state.phase = "movement"
	check(Combat.begin_movement(state, 1, 100, "normal", state.revision).is_empty(), "Start explicit zero-distance normal move")
	check(Combat.finish_movement(state, 1, state.revision).is_empty() and state.squads[1].last_action.status == "failed", "Confirmed zero-distance move still interrupts action")
	print("Action checks: %d failures" % failures)
	quit(0 if failures == 0 else 1)
