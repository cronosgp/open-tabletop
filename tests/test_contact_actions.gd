extends SceneTree
const Combat = preload("res://scripts/edition_11/combat_scenario.gd")
var failures := 0
func check(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		failures += 1
func three() -> int: return 3
func six() -> int: return 6

func fixture() -> Dictionary:
	var state := Combat.initial_state("legacy-solid-v1")
	for id: int in state.units:
		if id not in [100, 200]: state.units[id].wounds = 0
	state.units[100].position = Vector2(-8, -8)
	state.units[200].position = Vector2(-3, -8)
	state.phase = "charge"
	return state

func choose_charge(state: Dictionary) -> void:
	check(Combat.declare_charge(state, 1, 100, state.revision, three).error == "", "Charge declaration failed")
	check(Combat.select_charge_target(state, 1, 200, state.revision).error == "", "Charge target selection failed")
	check(Combat.begin_contact_move(state, 1, 100, "charge", state.revision) == "", "Manual charge could not begin")

func _initialize() -> void:
	var state := fixture()
	check(not Combat.begin_contact_move(state, 1, 100, "charge", 0).is_empty(), "Charge placement before dice accepted")
	choose_charge(state)
	var origin: Vector2 = state.units[100].position
	check(not Combat.advance_phase(state, 1, state.revision).is_empty(), "Phase skipped a draft contact move")
	check(not Combat.stage_contact_move(state, 2, 100, Vector2(-7, -8), state.revision).is_empty(), "Opponent placed charging model")
	check(not Combat.stage_contact_move(state, 1, 200, Vector2(-4, -8), state.revision).is_empty(), "Enemy model moved as charger")
	check(not Combat.stage_contact_move(state, 1, 100, Vector2(NAN, 0), state.revision).is_empty(), "Non-finite contact destination accepted")
	check(not Combat.stage_contact_move(state, 1, 100, Vector2(-3, -8), state.revision).is_empty(), "Charge crossed enemy base")
	check(Combat.stage_contact_move(state, 1, 100, Vector2(-8, -6), state.revision) == "", "First routed segment rejected")
	check(Combat.stage_contact_move(state, 1, 100, Vector2(-4.4, -6), state.revision) == "", "Second routed segment rejected")
	check(not Combat.stage_contact_move(state, 1, 100, Vector2(-4.4, -5), state.revision).is_empty(), "Segment exceeded accumulated charge budget")
	check(not Combat.finish_contact_move(state, 1, state.revision).is_empty(), "Reachable within-one-inch charge requirement ignored")
	check(not Combat.select_charge_target(state, 1, 200, state.revision).error.is_empty(), "Targets changed during placement")
	check(Combat.finish_contact_move(state, 1, state.revision, true) == "" and state.units[100].position == origin and state.pending_charge.maximum == 6, "Charge cancellation lost origin or dice")
	check(not Combat.declare_charge(state, 1, 100, state.revision, six).error.is_empty(), "Manual placement cancellation granted reroll")
	Combat.begin_contact_move(state, 1, 100, "charge", state.revision)
	Combat.stage_contact_move(state, 1, 100, Vector2(-8, -6), state.revision)
	Combat.stage_contact_move(state, 1, 100, Vector2(-4.4, -7.5), state.revision)
	check(Combat.finish_contact_move(state, 1, state.revision) == "" and state.squads[1].charged, "Legal multi-segment charge rejected")
	check(state.pending_contact.is_empty() and state.pending_charge.is_empty(), "Confirmed charge left pending data")
	Combat.advance_phase(state, 1, state.revision)
	check(state.fight_step == "pile_in", "Fight did not start with pile-in")
	Combat.begin_contact_move(state, 1, 100, "pile_in", state.revision)
	var radii: float = state.units[100].radius + state.units[200].radius
	var contact := Vector2(-3 - radii, -8)
	check(Combat.stage_contact_move(state, 1, 100, contact, state.revision) == "", "Pile-in into base contact rejected")
	check(not Combat.fight(state, 1, 100, 200, state.revision, six).error.is_empty(), "Attacked during pending pile-in")
	check(Combat.finish_contact_move(state, 1, state.revision) == "" and state.fight_actor == 2, "Confirmed pile-in did not give opponent their window")
	Combat.begin_contact_move(state, 2, 200, "pile_in", state.revision)
	check(not Combat.stage_contact_move(state, 2, 200, Vector2(-2.5, -8), state.revision).is_empty(), "Base-contact model moved during pile-in")
	check(Combat.finish_contact_move(state, 2, state.revision) == "" and state.fight_step == "attacks", "Stationary pile-in completion rejected")
	check(not Combat.begin_contact_move(state, 1, 100, "overrun", state.revision).is_empty(), "Engaged-at-start squad received overrun move")
	check(Combat.fight(state, 1, 100, 200, state.revision, six).error == "", "Charger could not fight")
	check(Combat.fight(state, 2, 200, 100, state.revision, six).error == "", "Defender could not fight")
	Combat.begin_contact_move(state, 1, 100, "consolidate", state.revision)
	check(not Combat.stage_contact_move(state, 1, 100, contact + Vector2(-0.2, 0), state.revision).is_empty(), "Base-contact model moved during ongoing consolidation")
	check(Combat.finish_contact_move(state, 1, state.revision) == "" and state.fight_actor == 2, "Consolidation did not advance window")
	# Additional overrun pile-in engages a new foe before this squad attacks.
	state = fixture()
	state.phase = "fight"
	state.fight_step = "attacks"
	state.squads[1].charged = true
	check(Combat.begin_contact_move(state, 1, 100, "overrun", 0) == "", "Eligible overrun rejected")
	Combat.stage_contact_move(state, 1, 100, Vector2(-6.1, -8), state.revision)
	check(Combat.finish_contact_move(state, 1, state.revision) == "" and state.squads[1].overrun_used and state.squads[2].fight_eligible, "Overrun did not grant enemy fight eligibility")
	check(not Combat.begin_contact_move(state, 1, 100, "overrun", state.revision).is_empty(), "Second overrun allowed")
	# Engaging consolidation forces an immediate enemy fight and resumes afterwards.
	state = fixture()
	state.units[200].position = Vector2(-4, -8)
	state.phase = "fight"
	state.fight_step = "consolidate"
	state.squads[1].fight_eligible = true
	state.squads[1].fought = true
	check(Combat.begin_contact_move(state, 1, 100, "consolidate", 0) == "", "Engaging consolidation rejected")
	Combat.stage_contact_move(state, 1, 100, Vector2(-7, -8), state.revision)
	check(Combat.finish_contact_move(state, 1, state.revision) == "" and state.fight_step == "consolidation_reaction" and Combat.actor(state) == 2, "Newly contacted enemy did not receive mandatory fight")
	check(not Combat.advance_phase(state, 2, state.revision).is_empty(), "Consolidation reaction fight skipped")
	check(Combat.fight(state, 2, 200, 100, state.revision, six).error == "" and state.fight_step == "consolidate" and Combat.actor(state) == 2, "Enemy fight did not resume consolidation order")
	# Multiple charge targets: final engagement with an unselected unit is illegal.
	state = fixture()
	state.squads[3] = state.squads[2].duplicate(true)
	state.units[300] = state.units[200].duplicate(true)
	state.units[300].squad = 3
	state.units[300].position = Vector2(-3, -6)
	choose_charge(state)
	Combat.stage_contact_move(state, 1, 100, Vector2(-4.4, -7.5), state.revision)
	check(not Combat.finish_contact_move(state, 1, state.revision).is_empty(), "Charge engaged an undeclared enemy unit")
	Combat.finish_contact_move(state, 1, state.revision, true)
	check(Combat.select_charge_target(state, 1, 300, state.revision).error == "" and state.pending_charge.targets.size() == 2, "Could not select multiple charge targets")
	Combat.begin_contact_move(state, 1, 100, "charge", state.revision)
	Combat.stage_contact_move(state, 1, 100, Vector2(-4.4, -7), state.revision)
	check(Combat.finish_contact_move(state, 1, state.revision) == "", "Legal multi-target charge rejected")
	# Coherency remains a whole-unit condition while individual paths are editable.
	state = fixture()
	state.units[101].wounds = 2
	state.units[101].position = Vector2(-8, -6.5)
	choose_charge(state)
	Combat.stage_contact_move(state, 1, 100, Vector2(-4.4, -8), state.revision)
	check("coherent" in Combat.finish_contact_move(state, 1, state.revision), "Contact move split a coherent squad")
	# A model engaged with two units must retain both engagements.
	state = fixture()
	state.units[100].position = Vector2(-6, -8)
	state.squads[3] = state.squads[2].duplicate(true)
	state.units[300] = state.units[200].duplicate(true)
	state.units[300].squad = 3
	state.units[300].position = Vector2(-9, -8)
	state.phase = "fight"
	state.fight_step = "pile_in"
	Combat.begin_contact_move(state, 1, 100, "pile_in", 0)
	Combat.stage_contact_move(state, 1, 100, Vector2(-5.7, -8), state.revision)
	check("retain" in Combat.finish_contact_move(state, 1, state.revision), "Pile-in discarded an existing engagement")
	# Missing objective support must fail visibly rather than invent a move.
	state = fixture()
	state.phase = "fight"
	state.fight_step = "consolidate"
	state.squads[1].fight_eligible = true
	check(not Combat.begin_contact_move(state, 1, 100, "consolidate", 0).is_empty(), "Objective consolidation silently accepted without objectives")
	print("Manual contact movement checks complete: %d failures" % failures)
	quit(1 if failures else 0)
