extends SceneTree

const Combat = preload("res://scripts/edition_11/combat_scenario.gd")
const Contact = preload("res://scripts/edition_11/contact_movement.gd")
var failures := 0
var dice_calls := 0
var successes := 0

func check(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		failures += 1

func two() -> int: return 2
func one() -> int: return 1
func six() -> int: return 6
func bad_dice() -> int: return 7
func damage() -> int:
	dice_calls += 1
	return 6 if dice_calls <= successes else 1

func fixture() -> Dictionary:
	var state := Combat.initial_state("legacy-solid-v1")
	if state.has("error"): return state
	for id: int in Combat.living(state, 1): state.units[id].position = Vector2(-6 + (id - 100) * 1.5, -9)
	for id: int in Combat.living(state, 2):
		var index: int = id - 200
		state.units[id].position = Vector2(-6 + (index % 5) * 1.5, -4.5 + floori(index / 5.0) * 1.5)
	state.phase = "charge"
	return state

func ready_fight() -> Dictionary:
	var state := fixture()
	Combat.declare_charge(state, 1, 100, state.revision, two)
	var result := Combat.charge(state, 1, 200, state.revision)
	check(result.error == "", "Supported charge plan rejected: " + result.error)
	Combat.advance_phase(state, 1, state.revision)
	return state

func _initialize() -> void:
	var state := fixture()
	if state.has("error"):
		push_error(state.error)
		quit(1)
		return
	check(Contact.coherent(state, 1) and Contact.coherent(state, 2), "Fixture must be coherent")
	check(not Combat.charge(state, 1, 200, state.revision).error.is_empty(), "Selected charge target before roll")
	check(not Combat.declare_charge(state, 2, 200, state.revision, six).error.is_empty(), "Wrong player declared charge")
	check(not Combat.declare_charge(state, 1, 100, state.revision, bad_dice).error.is_empty() and not state.squads[1].charge_declared, "Invalid host dice consumed charge")
	var origin: Vector2 = state.units[100].position
	var result := Combat.declare_charge(state, 1, 100, state.revision, one)
	check(result.error == "" and state.pending_charge.is_empty() and state.squads[1].charge_declared, "Failed roll must consume declaration")
	check(state.units[100].position == origin, "Failed charge moved a model")
	check(not Combat.declare_charge(state, 1, 100, state.revision, six).error.is_empty(), "Failed charge rerolled for free")
	state = fixture()
	Combat.declare_charge(state, 1, 100, state.revision, two)
	check(not state.pending_charge.is_empty() and state.pending_charge.maximum == 4, "Host roll not retained for target selection")
	check(not Combat.advance_phase(state, 1, state.revision).is_empty(), "Pending charge skipped")
	check(not Combat.charge(state, 1, 200, state.revision - 1).error.is_empty(), "Stale charge accepted")
	check(Combat.decline_charge(state, 1, state.revision) == "" and state.pending_charge.is_empty(), "Charge decline failed")
	check(not Combat.declare_charge(state, 1, 100, state.revision, six).error.is_empty(), "Declined charge rerolled")
	state = ready_fight()
	check(state.squads[1].charged and Combat._engaged(state, 1), "Successful charge must engage and grant priority")
	check(Contact.coherent(state, 1), "Charge broke coherency")
	for id: int in Combat.living(state, 1):
		check(Contact.distance_to_target(state, state.units[id], 2) <= 1.001, "Reachable charging model did not finish within 1 inch")
	check(state.fight_step == "pile_in" and Combat.actor(state) == 1, "Active player must decide pile-in first")
	check(not Combat.fight(state, 1, 100, 200, state.revision, six).error.is_empty(), "Attacked before pile-in step ended")
	Combat.advance_phase(state, 1, state.revision)
	check(Combat.actor(state) == 2, "Defender cannot make optional pile-in decision")
	Combat.advance_phase(state, 2, state.revision)
	check(state.fight_step == "attacks" and Combat.actor(state) == 1 and state.fight_priority == "first", "Charging unit must fight first")
	check(not Combat.advance_phase(state, 1, state.revision).is_empty(), "Mandatory engaged fight skipped")
	check(not Combat.fight(state, 2, 200, 100, state.revision, six).error.is_empty(), "Defender bypassed Fights First")
	result = Combat.fight(state, 1, 100, 200, state.revision, six)
	check(result.error == "" and state.squads[1].fought and Combat.actor(state) == 2, "Defender not given an attack window")
	check(not Combat.fight(state, 1, 100, 200, state.revision, six).error.is_empty(), "Squad fought twice")
	result = Combat.fight(state, 2, 200, 100, state.revision, six)
	check(result.error == "" and state.fight_step == "consolidate" and Combat.actor(state) == 1, "Defender melee did not finish attack step")
	Combat.advance_phase(state, 1, state.revision)
	check(Combat.actor(state) == 2, "Defender consolidation decision missing")
	Combat.advance_phase(state, 2, state.revision)
	check(state.fight_step == "complete", "Fight step did not complete")
	Combat.advance_phase(state, 1, state.revision)
	Combat.advance_phase(state, 1, state.revision)
	check(state.active == 2 and not state.squads[1].charged, "Charging priority leaked into next turn")
	# Neither side charged: 11e starts remaining combats with the active player.
	state.phase = "fight"
	Combat._begin_fight(state)
	Combat.advance_phase(state, 2, state.revision)
	Combat.advance_phase(state, 1, state.revision)
	check(state.fight_priority == "remaining" and Combat.actor(state) == 2, "Used 10e defender-first ordering instead of 11e")
	# Melee casualties persist, and a dead enemy cannot retaliate.
	state = ready_fight()
	Combat.advance_phase(state, 1, state.revision)
	Combat.advance_phase(state, 2, state.revision)
	successes = 2 * int(state.squads[1].melee_weapon.attacks) * Combat.living(state, 1).size()
	dice_calls = 0
	result = Combat.fight(state, 1, 100, 200, state.revision, damage)
	check(result.error == "" and Combat.living(state, 2).is_empty() and state.test_winner == 1, "Melee casualties not persisted")
	check(not Combat.fight(state, 2, 200, 100, state.revision, six).error.is_empty(), "Destroyed squad retaliated")
	# Warriors can charge as a two-file squad; individual placements prevent overlap.
	state = fixture()
	state.active = 2
	Combat.declare_charge(state, 2, 200, state.revision, six)
	result = Combat.charge(state, 2, 100, state.revision)
	check(result.error == "" and Contact.coherent(state, 2), "Two-file Warrior charge failed: " + result.error)
	var members := Combat.living(state, 2)
	for id: int in members:
		for other: int in members:
			if id != other:
				check(state.units[id].position.distance_to(state.units[other].position) >= state.units[id].radius + state.units[other].radius - 0.001, "Charging friendly bases overlap")
	# Losing engaged front models can leave a still-eligible unit unengaged.
	state = fixture()
	var rng := RandomNumberGenerator.new()
	rng.seed = 42
	var roller := func(): return rng.randi_range(1, 6)
	Combat.declare_charge(state, 1, 100, state.revision, roller)
	Combat.charge(state, 1, 200, state.revision)
	Combat.advance_phase(state, 1, state.revision)
	Combat.advance_phase(state, 1, state.revision)
	Combat.advance_phase(state, 2, state.revision)
	Combat.fight(state, 1, 100, 200, state.revision, roller)
	check(not Combat._engaged(state, 2) and Combat.actor(state) == 2, "Unengaged survivor lost fight eligibility")
	check(Combat.advance_phase(state, 2, state.revision) == "" and state.squads[2].fought, "Optional overrun movement cannot be declined")
	# Enemy colliders and terrain are still enforced by charge movement.
	state = fixture()
	check(not Contact.clear_path(state, 100, state.units[200].position, 12), "Charge crossed an enemy base")
	check(not Contact.clear_path(state, 100, Vector2(0, 0), 12), "Charge crossed solid terrain")
	print("Charge and melee checks complete: %d failures" % failures)
	quit(1 if failures else 0)
