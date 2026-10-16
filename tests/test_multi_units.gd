extends SceneTree
const Combat = preload("res://scripts/edition_11/combat_scenario.gd")
var failures := 0
func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1
func six() -> int: return 6
func fixture() -> Dictionary:
	var state := Combat.initial_state("legacy-solid-v1", Combat.Objectives.TRAINING, 2)
	for id: int in state.units:
		if id not in [100, 200, 300, 400]: state.units[id].wounds = 0
	state.units[100].position = Vector2(-8, -8)
	state.units[200].position = Vector2(-6, -8)
	state.units[300].position = Vector2(-8, 8)
	state.units[400].position = Vector2(-6, 8)
	state.phase = "charge"
	return state
func skip(state: Dictionary, squad: int) -> String:
	return Combat.advance_phase(state, Combat.actor(state), state.revision, six, squad)
func _initialize() -> void:
	var state := Combat.initial_state(Combat.Terrain.DEFAULT_LAYOUT, Combat.Objectives.TRAINING, 2)
	check(state.squads.size() == 4 and Combat.living_owner(state, 1).size() == 10 and Combat.living_owner(state, 2).size() == 20, "Two real units per player")
	check(state.squads[3].owner == 1 and state.squads[4].owner == 2, "Unit identity independent from owner")
	check(state.pack_hash != Combat.initial_state(Combat.Terrain.DEFAULT_LAYOUT, Combat.Objectives.TRAINING).pack_hash, "Roster size participates in compatibility hash")
	for squad: int in state.squads: check(Combat.Contact.coherent(state, squad), "Initial multi-unit coherency")
	check(Combat.initial_state(Combat.Terrain.DEFAULT_LAYOUT, "elimination", 3).has("error"), "Unsupported exercise size rejected")
	state = fixture()
	state.squads[3].charged = true
	check(skip(state, -1).is_empty() and state.fight_step == "pile_in", "Begin multi-unit Fight")
	check(Combat.FightQueue.choices(state, 1) == [1, 3], "Both friendly pile-in choices")
	check(skip(state, 3).is_empty() and Combat.actor(state) == 1, "Active player resolves all own pile-ins first")
	var before := var_to_str(state)
	check(not Combat.begin_contact_move(state, 1, 300, "pile_in", state.revision).is_empty() and before == var_to_str(state), "Unit cannot pile in twice")
	check(skip(state, 1).is_empty() and Combat.actor(state) == 2, "Pile-in passes to opponent after all active units")
	skip(state, 4)
	skip(state, 2)
	check(state.fight_step == "attacks" and Combat.actor(state) == 1 and Combat.FightQueue.choices(state, 1) == [3], "Charging third unit has mandatory priority")
	before = var_to_str(state)
	check(not Combat.fight(state, 1, 100, 200, state.revision, six).error.is_empty() and before == var_to_str(state), "Same-owner unit cannot bypass Fights First")
	check(Combat.fight(state, 1, 300, 400, state.revision, six).error.is_empty() and Combat.actor(state) == 2, "Fight uses third unit and alternates owner")
	check(Combat.fight(state, 2, 400, 300, state.revision, six).error.is_empty() and Combat.actor(state) == 1, "Opponent chooses between remaining units")
	Combat.fight(state, 1, 100, 200, state.revision, six)
	Combat.fight(state, 2, 200, 100, state.revision, six)
	check(state.fight_step == "consolidate" and Combat.actor(state) == 1, "Consolidation starts after all eligible units fought")
	skip(state, 3)
	check(Combat.actor(state) == 1 and Combat.FightQueue.choices(state, 1) == [1], "Consolidation is once per unit, active army first")
	skip(state, 1)
	check(Combat.actor(state) == 2, "Opponent receives all consolidation choices")
	skip(state, 4)
	skip(state, 2)
	check(state.fight_step == "complete", "Fight complete after four consolidation decisions")
	state = fixture()
	state.units[200].position = Vector2(-4, -8)
	state.units[400].position = Vector2(-4, -6.7)
	state.phase = "fight"
	state.fight_step = "consolidate"
	state.fight_actor = 1
	state.squads[1].fight_eligible = true
	state.squads[1].fought = true
	check(Combat.begin_contact_move(state, 1, 100, "consolidate", 0).is_empty(), "Begin consolidation contacting multiple units")
	check(Combat.stage_contact_move(state, 1, 100, Vector2(-5.5, -7.4), state.revision).is_empty(), "Multi-contact path")
	check(Combat.finish_contact_move(state, 1, state.revision).is_empty() and state.reaction_queue == [2, 4], "Every unfought contacted unit queues a mandatory reaction")
	check(Combat.FightQueue.choices(state, 2) == [2, 4] and state.squads[4].fight_eligible, "Opponent may choose order among reactions")
	check(Combat.fight(state, 2, 400, 100, state.revision, six).error.is_empty() and state.reaction_queue == [2] and state.fight_step == "consolidation_reaction", "First reaction preserves remaining queue")
	before = var_to_str(state)
	check(not skip(state, 2).is_empty() and before == var_to_str(state), "Mandatory engaged reaction cannot be skipped")
	check(Combat.fight(state, 2, 200, 100, state.revision, six).error.is_empty() and state.reaction_queue.is_empty() and state.fight_step == "consolidate" and Combat.actor(state) == 2, "Last reaction resumes consolidation without repeating mover")
	state = fixture()
	state.phase = "fight"
	state.fight_step = "attacks"
	state.fight_actor = 1
	state.units[200].position = Vector2(-4, -8)
	state.units[400].position = Vector2(-4, 8)
	state.squads[1].charged = true
	state.squads[3].charged = true
	check(Combat.begin_contact_move(state, 1, 100, "overrun", 0).is_empty(), "Choose overrun unit")
	Combat.stage_contact_move(state, 1, 100, Vector2(-7, -8), state.revision)
	check(Combat.finish_contact_move(state, 1, state.revision).is_empty() and state.fight_selected == 1, "Overrun commits activation to moved unit")
	before = var_to_str(state)
	check(not Combat.fight(state, 1, 300, 400, state.revision, six).error.is_empty() and before == var_to_str(state), "Cannot switch unit after overrun")
	check(Combat.fight(state, 1, 100, 200, state.revision, six).error.is_empty() and Combat.FightQueue.choices(state, 1) == [3], "Remaining charging unit retains priority after locked activation")
	state = fixture()
	state.mission = {"id": "elimination", "objectives": []}
	state.phase = "shooting"
	state.units[200].position = Vector2(1, -8)
	state.squads[1].weapon = {"name": "Test", "attacks": 1, "skill": 2, "strength": 10, "ap": -6, "damage": 10, "range_inches": 30, "keywords": {}}
	check(Combat.shoot(state, 1, 100, 200, 0, true, six).error.is_empty() and state.units[200].wounds == 0 and state.test_winner == 0, "Destroying one unit does not eliminate an army with another survivor")
	state = fixture()
	state.phase = "fight"
	state.fight_step = "attacks"
	state.fight_actor = 1
	state.units[200].position = Vector2(0, -8)
	state.units[400].position = Vector2(0, 8)
	state.squads[1].charged = true
	state.squads[3].charged = true
	check(skip(state, 3).is_empty() and state.squads[3].fought and Combat.actor(state) == 1 and Combat.FightQueue.choices(state, 1) == [1], "Several Fights First units continue with same army when opponent has none")
	check(skip(state, 1).is_empty() and state.fight_step == "consolidate", "Unengaged units resolve selected fights without guessing another unit")
	state = fixture()
	state.phase = "fight"
	state.fight_step = "consolidation_reaction"
	state.fight_actor = 2
	state.reaction_queue = [2]
	state.squads[2].fight_eligible = true
	state.squads[4].fight_eligible = true
	before = var_to_str(state)
	check(not Combat.fight(state, 2, 400, 300, state.revision, six).error.is_empty() and before == var_to_str(state), "Unrelated eligible unit cannot bypass mandatory reaction queue")
	state.reaction_queue = [2, 4]
	state.units[200].wounds = 0
	Combat._resume_consolidation(state)
	check(state.reaction_queue == [4] and Combat.FightQueue.choices(state, 2) == [4], "Dead units are pruned from reaction queue")
	print("Multiple-unit checks: %d failures" % failures)
	quit(0 if failures == 0 else 1)
