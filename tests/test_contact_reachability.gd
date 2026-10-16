extends SceneTree
const Combat = preload("res://scripts/edition_11/combat_scenario.gd")
const Proof = Combat.ContactActions.Reachability
var failures := 0
func check(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		failures += 1
func five() -> int: return 5

func fixture() -> Dictionary:
	var state := Combat.initial_state("legacy-solid-v1")
	for id: int in state.units:
		if id not in [100, 200]: state.units[id].wounds = 0
	state.phase = "charge"
	state.units[100].position = Vector2(-5, 0)
	state.units[200].position = Vector2(5, 0)
	return state

func begin_charge(state: Dictionary) -> void:
	check(Combat.declare_charge(state, 1, 100, state.revision, five).error == "", "Charge declaration failed")
	check(Combat.select_charge_target(state, 1, 200, state.revision).error == "", "Charge target failed")
	check(Combat.begin_contact_move(state, 1, 100, "charge", state.revision) == "", "Charge draft failed")

func coherent_fixture() -> Dictionary:
	var state := fixture()
	for id in [101, 102]: state.units[id].wounds = 2
	state.squads[3] = state.squads[2].duplicate(true)
	state.units[300] = state.units[200].duplicate(true)
	state.units[300].squad = 3
	state.units[100].position = Vector2(0, -8)
	state.units[101].position = Vector2(-3, -8)
	state.units[102].position = Vector2(-4, -6.5)
	state.units[200].position = Vector2(state.units[100].radius + state.units[200].radius, -8)
	state.units[300].position = Vector2(-6.9, -6.5)
	state.phase = "fight"
	state.fight_step = "pile_in"
	return state

func _initialize() -> void:
	# The goal is Euclidean-reachable, but going around the central terrain
	# cannot reach the 1-inch zone in 10 inches. Engagement remains reachable.
	var state := fixture()
	begin_charge(state)
	var before: Dictionary = state.duplicate(true)
	var proof := Proof.certify_impossible(state, 100, [2], 1.0)
	check(proof.impossible and proof.reason == "terrain_route" and proof.lower_bound > 10.0, "Terrain detour was not certified")
	check(state == before, "Proof search mutated match state")
	check(not Proof.certify_impossible(state, 100, [2], 2.0).impossible, "Engagement incorrectly waived after 1-inch exception")
	check(Combat.stage_contact_move(state, 1, 100, Vector2(-3.64, 2.64), state.revision) == "", "First detour segment rejected")
	check(Combat.stage_contact_move(state, 1, 100, Vector2(3.3, 2.64), state.revision) == "", "Second detour segment rejected")
	check(Combat.finish_contact_move(state, 1, state.revision) == "" and state.squads[1].charged, "Proven legal obstacle exception rejected")
	check(state.last_contact_proofs.size() == 1 and state.last_contact_proofs[0].gap == 1.0, "Accepted exception missing audit certificate")
	# A second charging model can engage the unit, but this model still has
	# its own engagement duty after the 1-inch duty was proved impossible.
	state = fixture()
	state.units[101].wounds = 2
	state.units[101].position = Vector2(-5, 2)
	begin_charge(state)
	Combat.stage_contact_move(state, 1, 100, Vector2(-3.64, 2.64), state.revision)
	Combat.stage_contact_move(state, 1, 100, Vector2(2, 2.64), state.revision)
	Combat.stage_contact_move(state, 1, 101, Vector2(-3.64, 2.64), state.revision)
	check(Combat.stage_contact_move(state, 1, 101, Vector2(3.64, 2.64), state.revision) == "", "Front model could not traverse around the obstacle")
	Combat.stage_contact_move(state, 1, 101, Vector2(4.1, 2), state.revision)
	before = state.duplicate(true)
	var engagement_error := Combat.finish_contact_move(state, 1, state.revision)
	check("within 2" in engagement_error and state == before, "1-inch exception incorrectly waived reachable engagement: " + engagement_error)
	# Spending the budget on an inefficient route does not justify an exception.
	state = fixture()
	state.units[100].position = Vector2(-5, -3.5)
	state.units[200].position = Vector2(5, -3.5)
	begin_charge(state)
	check(not Proof.certify_impossible(state, 100, [2], 1.0).impossible, "Open approach falsely certified impossible")
	Combat.stage_contact_move(state, 1, 100, Vector2(2.2, -3.5), state.revision)
	before = state.duplicate(true)
	check(not Combat.finish_contact_move(state, 1, state.revision).is_empty() and state == before, "Reachable approach accepted or rejected confirmation changed state")
	# Alternative target models must all be checked; a blocked one does not
	# justify waiving approach to another visible/reachable model in that unit.
	state = fixture()
	state.units[201].wounds = 1
	state.units[201].position = Vector2(-5, 4)
	begin_charge(state)
	check(not Proof.certify_impossible(state, 100, [2], 1.0).impossible, "Reachable second target model was ignored")
	# A locked model anchors coherency. The other engaged model must retain
	# its enemy, so there is no possible bridge if the middle model engages.
	state = coherent_fixture()
	check(Combat.Contact.coherent(state, 1), "Coherency fixture starts disconnected")
	check(Combat.begin_contact_move(state, 1, 101, "pile_in", 0) == "", "Pile-in fixture could not start")
	proof = Proof.certify_impossible(state, 101, [3], 2.0)
	check(proof.impossible and proof.reason == "coherent_placement", "Global coherent-placement exception was not proved")
	check(Combat.stage_contact_move(state, 1, 101, Vector2(-3.1, -8), state.revision) == "", "Closer coherent placement rejected")
	check(Combat.finish_contact_move(state, 1, state.revision) == "", "Proven coherency exception rejected")
	check(state.last_contact_proofs.size() == 1 and state.last_contact_proofs[0].reason == "coherent_placement", "Coherency certificate missing")
	# Overlapping bounding boxes alone cannot decide this diagonal case;
	# retained-engagement disks prove that no coherent bridge can exist.
	state = coherent_fixture()
	state.units[300].position.x = -6.45
	Combat.begin_contact_move(state, 1, 101, "pile_in", 0)
	proof = Proof.certify_impossible(state, 101, [3], 2.0)
	check(proof.impossible and proof.nodes >= 1, "Circular-domain coherent-placement proof failed: " + str(proof))
	Combat.stage_contact_move(state, 1, 101, Vector2(-3.1, -8), state.revision)
	check(Combat.finish_contact_move(state, 1, state.revision) == "", "Circular-domain proof did not permit a valid exception")
	# If that anchor is actually movable, a bridge may be rearranged. Never
	# freeze teammates at their submitted positions when proving impossibility.
	state = coherent_fixture()
	state.units[200].position.x += 0.1
	Combat.begin_contact_move(state, 1, 101, "pile_in", 0)
	check(not Proof.certify_impossible(state, 101, [3], 2.0).impossible, "Movable teammate frozen at its submitted position")
	# Known complete legal arrangements must never receive an impossibility
	# certificate, even when teammates need to move together to remain coherent.
	for start_x in [-8.0, -10.0, -12.0]:
		state = fixture()
		state.units[101].wounds = 2
		state.units[100].position = Vector2(start_x, -8)
		state.units[101].position = Vector2(start_x, -6.5)
		state.units[200].position = Vector2(start_x + 5, -8)
		begin_charge(state)
		check(not Proof.certify_impossible(state, 100, [2], 1.0).impossible, "A known coherent reachable arrangement was certified impossible")
		for id in [100, 101]:
			check(Combat.stage_contact_move(state, 1, id, state.units[id].position + Vector2(3.6, 0), state.revision) == "", "Known witness path rejected")
		check(Combat.finish_contact_move(state, 1, state.revision) == "", "Known witness arrangement rejected")
	# A strict work limit is an unknown outcome, never a proof of impossibility.
	state = coherent_fixture()
	Combat.begin_contact_move(state, 1, 101, "pile_in", 0)
	proof = Proof.certify_impossible(state, 101, [3], 2.0, 0)
	check(not proof.impossible and proof.reason == "search_limit", "Search exhaustion waived a rule")
	# Rectangle corner relaxation must not block a circular base's rounded
	# corner route: every generated obstacle corner stays inside the dilation.
	var radius := 0.63
	for obstacle: Rect2 in Proof._obstacles(radius):
		var contained := false
		for terrain: Rect2 in Combat.Movement.TERRAIN:
			var all_inside := true
			for corner: Vector2 in Proof._corners(obstacle):
				if Proof._point_distance(corner, terrain) > radius + 0.00001: all_inside = false
			if all_inside: contained = true
		check(contained, "Proof obstacle exceeded the physical circular-base dilation")
	print("Contact reachability certificates: %d failures" % failures)
	quit(1 if failures else 0)
