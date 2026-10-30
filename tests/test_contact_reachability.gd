extends SceneTree
const Combat = preload("res://scripts/edition_11/combat_scenario.gd")
const Proof = Combat.ContactActions.Reachability
const MovementPathfinder = preload("res://scripts/edition_11/movement_pathfinder.gd")
const Terrain = preload("res://scripts/edition_11/terrain.gd")
const HeresyRetribution = preload("res://scripts/edition_11/heresy_retribution.gd")
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
	var terrain_goal := {"kind": "rounded_rect", "bounds": Rect2(0, 0, 10, 10), "radius": 0.5}
	var support_anchor: Array[Dictionary] = [{"center": Vector2(14.1, 5), "radius": 0.0}]
	var old_goal_envelope := {"center": terrain_goal.bounds.get_center(),
		"radius": terrain_goal.bounds.size.length() * 0.5 + float(terrain_goal.radius)}
	var loose_goal_distance := maxf(0.0, old_goal_envelope.center.distance_to(support_anchor[0].center) - float(old_goal_envelope.radius))
	var exact_goal_distance := Proof._constraint_set_distance([terrain_goal], support_anchor)
	check(loose_goal_distance < 3.0 and exact_goal_distance > 3.0 and exact_goal_distance < 3.61,
		"Rounded terrain-goal distance proves the support anchor cannot be a 2-inch coherency neighbour where the old enclosing circle stayed ambiguous")
	check(is_equal_approx(exact_goal_distance, Proof._constraint_set_distance(support_anchor, [terrain_goal])),
		"Rounded terrain-goal distance is symmetric with the support model's reachable domain")
	var nearby_goal := {"center": Vector2(14.1, 5), "radius": 0.1}
	var single_goal_set: Array[Dictionary] = [terrain_goal]
	var combined_goal_set: Array[Dictionary] = [terrain_goal, nearby_goal]
	var anchor_set: Array[Dictionary] = support_anchor.duplicate()
	var single_focus_constraints: Array = [single_goal_set]
	var combined_focus_constraints: Array = [combined_goal_set]
	var anchor_constraints: Array = [anchor_set]
	var single_goal_constraints: Array[Array] = [single_focus_constraints, anchor_constraints]
	var combined_goal_constraints: Array[Array] = [combined_focus_constraints, anchor_constraints]
	var single_goal_bounds := Proof._pairwise_constraint_bounds(single_goal_constraints)
	var combined_goal_bounds := Proof._pairwise_constraint_bounds(combined_goal_constraints)
	check(is_equal_approx(single_goal_bounds[0][1], 3.6) and is_equal_approx(combined_goal_bounds[0][1], 0.0),
		"A nearby alternative target weakens only the combined target bound, not a per-target root")
	check(is_equal_approx(Proof._constraint_distance(
		{"kind": "rounded_rect", "bounds": Rect2(0, 0, -1, 10), "radius": 0.5}, support_anchor[0]), 0.0),
		"Malformed rounded goal geometry returns a non-certifying zero lower bound")
	# The goal is Euclidean-reachable, but going around the central terrain
	# cannot reach the 1-inch zone in 10 inches. Engagement remains reachable.
	var state := fixture()
	begin_charge(state)
	var before: Dictionary = state.duplicate(true)
	var prepared_context := Proof.make_certificate_context(state)
	var proof := Proof.certify_impossible(state, 100, [2], 1.0, Proof.BOX_LIMIT, prepared_context)
	var fresh_proof := Proof.certify_impossible(state, 100, [2], 1.0)
	check(proof.impossible and proof.reason == "terrain_route" and proof.lower_bound > 10.0, "Terrain detour was not certified")
	check(prepared_context.get("prepared_certificate_context", false) and prepared_context.get("geometry_ready", false)
		and fresh_proof.impossible == proof.impossible
		and fresh_proof.reason == proof.reason and is_equal_approx(float(fresh_proof.lower_bound), float(proof.lower_bound)),
		"A reused formation-geometry context preserves the standalone terrain-route certificate")
	check(state == before, "Proof search mutated match state")
	check(not Proof.certify_impossible(state, 100, [2], 2.0).impossible, "Engagement incorrectly waived after 1-inch exception")
	# Engagement at a different height has an unavoidable vertical movement
	# cost once the target is more than five inches above the origin.
	var vertical_state := fixture()
	vertical_state.terrain.areas = []
	vertical_state.units[100].position = Vector2.ZERO
	vertical_state.units[200].position = Vector2(0.5, 0)
	vertical_state.units[200].elevation = 8.0
	vertical_state.pending_contact = {"squad": 1, "kind": "charge", "maximum": 2.9,
		"origins": {100: Vector2.ZERO}, "origin_elevations": {100: 0.0}, "locked": {}, "engaged": {100: []}}
	var vertical_proof := Proof.certify_impossible(vertical_state, 100, [2], 2.0)
	check(vertical_proof.impossible and vertical_proof.reason == "terrain_route" and vertical_proof.lower_bound > 2.92,
		"The certificate ignored the minimum three-inch climb needed to enter Engagement Range")
	vertical_state.units[201].wounds = 1
	vertical_state.units[201].position = Vector2(0.5, 1.0)
	vertical_state.units[201].elevation = 0.0
	check(not Proof.certify_impossible(vertical_state, 100, [2], 2.0).impossible,
		"An unreachable high target waived an approach when another model in its unit was vertically reachable")
	vertical_state.units[201].wounds = 0
	vertical_state.pending_contact.maximum = 3.0
	check(not Proof.certify_impossible(vertical_state, 100, [2], 2.0).impossible,
		"The vertical lower bound rejected movement that fits within its certificate margin")
	vertical_state.units[100].keywords.append("fly")
	vertical_state.pending_contact.maximum = 2.9
	vertical_state.pending_contact.take_to_skies = true
	check(not Proof.certify_impossible(vertical_state, 100, [2], 2.0).impossible,
		"The vertical lower bound charged a FLY model whose Take to the Skies move ignores vertical distance")
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
	# The formation starts coherent across the 5-inch height band. Its focus
	# model can individually reach a higher target, but a locked ground anchor
	# cannot stay vertically coherent with any endpoint in that target band.
	var vertical_formation := fixture()
	vertical_formation.units[101].wounds = 2
	vertical_formation.squads[3] = vertical_formation.squads[2].duplicate(true)
	vertical_formation.units[300] = vertical_formation.units[200].duplicate(true)
	vertical_formation.units[300].squad = 3
	for id in [100, 101, 200, 300]:
		vertical_formation.units[id].radius = 0.5
		if not vertical_formation.units[id].keywords.has("infantry"):
			vertical_formation.units[id].keywords.append("infantry")
	vertical_formation.units[100].position = Vector2(-2.1, 0)
	vertical_formation.units[100].elevation = 5.0
	vertical_formation.units[101].position = Vector2.ZERO
	vertical_formation.units[101].elevation = 0.0
	vertical_formation.units[200].position = Vector2(1, 0)
	vertical_formation.units[200].elevation = 0.0
	vertical_formation.units[300].position = Vector2(-2.1, 0)
	vertical_formation.units[300].elevation = 15.0
	vertical_formation.terrain.areas = [{"name": "Stacked approach surfaces", "category": "ruin", "bounds": Rect2(-8, -8, 16, 16), "features": [], "surfaces": [
		{"id": "middle", "elevation": 5.0, "bounds": Rect2(-6, -6, 12, 12), "requires_keywords": ["infantry"], "access_features": []},
		{"id": "high", "elevation": 15.0, "bounds": Rect2(-6, -6, 12, 12), "requires_keywords": ["infantry"], "access_features": []}]}]
	check(Combat.Contact.coherent(vertical_formation, 1), "The vertical certificate fixture must start coherent")
	vertical_formation.pending_contact = {"squad": 1, "kind": "pile_in", "maximum": 6.0,
		"origins": {100: Vector2(-2.1, 0), 101: Vector2.ZERO}, "origin_elevations": {100: 5.0, 101: 0.0},
		"locked": {101: true}, "engaged": {100: [], 101: [2]}}
	var vertical_formation_proof := Proof.certify_impossible(vertical_formation, 100, [3], 2.0)
	check(vertical_formation_proof.impossible and vertical_formation_proof.reason == "coherent_placement",
		"The 2D coherency search failed to rule out a reachable enemy-height band disconnected from its locked anchor: %s" % str(vertical_formation_proof))
	var boundary_height_formation: Dictionary = vertical_formation.duplicate(true)
	boundary_height_formation.units[300].elevation = 10.0
	check(not Proof.certify_impossible(boundary_height_formation, 100, [3], 2.0).impossible,
		"The vertical coherency bound rejected a goal that can remain within five inches of its locked anchor")
	# A movable support model cannot spend its full move climbing if it must
	# preserve Engagement Range to a ground-level enemy.
	var retained_height_formation := fixture()
	retained_height_formation.units[101].wounds = 2
	retained_height_formation.squads[3] = retained_height_formation.squads[2].duplicate(true)
	retained_height_formation.units[300] = retained_height_formation.units[200].duplicate(true)
	retained_height_formation.units[300].squad = 3
	for id in [100, 101, 200, 300]: retained_height_formation.units[id].radius = 0.5
	retained_height_formation.units[100].position = Vector2.ZERO
	retained_height_formation.units[100].elevation = 5.0
	retained_height_formation.units[101].position = Vector2(2, 0)
	retained_height_formation.units[101].elevation = 0.0
	retained_height_formation.units[200].position = Vector2(3, 0)
	retained_height_formation.units[200].elevation = 0.0
	retained_height_formation.units[300].position = Vector2(0.5, 0)
	retained_height_formation.units[300].elevation = 20.0
	check(Combat.Contact.coherent(retained_height_formation, 1),
		"The retained-engagement height fixture must start coherent")
	retained_height_formation.pending_contact = {"squad": 1, "kind": "pile_in", "maximum": 10.0,
		"origins": {100: Vector2.ZERO, 101: Vector2(2, 0)}, "origin_elevations": {100: 5.0, 101: 0.0},
		"locked": {}, "engaged": {100: [], 101: [2]}}
	var retained_height_proof := Proof.certify_impossible(retained_height_formation, 100, [3], 2.0)
	check(retained_height_proof.impossible and retained_height_proof.reason == "coherent_placement",
		"A support model's retained ground-level engagement was ignored when checking vertical coherency with a high target: %s" % str(retained_height_proof))
	# Height domains are restricted to legal endpoint floors that intersect each
	# model's XY box. The high target is near enough horizontally, but the only
	# floor in its engagement-height band is ten inches up and outside the move.
	var unsupported_height_formation := fixture()
	unsupported_height_formation.units[101].wounds = 2
	unsupported_height_formation.squads[3] = unsupported_height_formation.squads[2].duplicate(true)
	unsupported_height_formation.units[300] = unsupported_height_formation.units[200].duplicate(true)
	unsupported_height_formation.units[300].squad = 3
	unsupported_height_formation.units[300].position = Vector2(2.0, 0.0)
	unsupported_height_formation.units[300].elevation = 10.0
	for id in [100, 101, 300]:
		unsupported_height_formation.units[id].radius = 0.5
		if not unsupported_height_formation.units[id].keywords.has("infantry"):
			unsupported_height_formation.units[id].keywords.append("infantry")
	unsupported_height_formation.units[100].position = Vector2.ZERO
	unsupported_height_formation.units[101].position = Vector2(-1.5, 0.0)
	unsupported_height_formation.terrain.areas = [{"name": "Raised target platform", "category": "ruin",
		"bounds": Rect2(-2, -2, 8, 4), "features": [], "surfaces": [
			{"id": "raised-target", "elevation": 10.0, "bounds": Rect2(-2, -2, 8, 4),
				"features": [], "access_features": [], "requires_keywords": ["infantry"]}]}]
	unsupported_height_formation.pending_contact = {"squad": 1, "kind": "pile_in", "maximum": 6.0,
		"origins": {100: Vector2.ZERO, 101: Vector2(-1.5, 0.0)},
		"origin_elevations": {100: 0.0, 101: 0.0}, "locked": {}, "engaged": {100: [], 101: []}}
	var unsupported_height_proof := Proof.certify_impossible(unsupported_height_formation, 100, [3], 2.0)
	check(unsupported_height_proof.impossible and unsupported_height_proof.reason == "coherent_placement",
		"A continuous height relaxation accepted an engagement height with no reachable legal floor: %s" % str(unsupported_height_proof))
	# A legal-height floor whose only listed access is beyond the whole move must
	# not keep an elevated engagement band alive in the formation certificate.
	var distant_access_formation: Dictionary = unsupported_height_formation.duplicate(true)
	distant_access_formation.units[300].position = Vector2(5.0, 0.0)
	distant_access_formation.terrain.areas = [{"name": "Distant access floor", "category": "ruin",
		"bounds": Rect2(4.0, -3.0, 22.0, 6.0),
		"features": [{"bounds": Rect2(20.0, -2.0, 1.0, 4.0), "height": 4.0, "blocks_end": true}],
		"surfaces": [{"id": "distant-access", "elevation": 5.0, "bounds": Rect2(4.0, -3.0, 22.0, 6.0),
			"features": [], "access_features": [0], "requires_keywords": ["infantry"]}]}]
	distant_access_formation.pending_contact.maximum = 6.0
	var distant_access_route := MovementPathfinder.new(distant_access_formation, 100, 6.0, "surge").distance_to(Vector2(5.0, 0.0), 5.0)
	var distant_access_proof := Proof.certify_impossible(distant_access_formation, 100, [3], 2.0)
	check(is_inf(distant_access_route) and distant_access_proof.impossible,
		"A floor whose required access is beyond movement remained a possible endpoint in the group certificate (route=%s proof=%s)" % [str(distant_access_route), str(distant_access_proof)])
	# A floor can be accessible from the origin yet still be impossible to reach
	# in the target region because its access lies far off the direct route.
	var bent_access_goal_state: Dictionary = unsupported_height_formation.duplicate(true)
	bent_access_goal_state.units[200].wounds = 0
	bent_access_goal_state.units[100].position = Vector2.ZERO
	bent_access_goal_state.units[100].elevation = 0.0
	bent_access_goal_state.units[300].position = Vector2(0.0, 10.0)
	bent_access_goal_state.units[300].elevation = 10.0
	bent_access_goal_state.terrain.areas = [{"name": "Access off the target route", "category": "ruin",
		"bounds": Rect2(-5.0, -5.0, 20.0, 20.0),
		"features": [{"bounds": Rect2(9.5, -0.25, 0.1, 0.5), "height": 4.0, "blocks_end": true}],
		"surfaces": [{"id": "off-route-access", "elevation": 5.0, "bounds": Rect2(-5.0, -5.0, 20.0, 20.0),
			"features": [], "access_features": [0], "requires_keywords": ["infantry"]}]}]
	bent_access_goal_state.pending_contact.maximum = 20.0
	var bent_access_goal: Dictionary = Proof._goal_disks(bent_access_goal_state, 100, [3], 2.0)[0]
	var bent_access_domain: Rect2 = Proof._goal_box(bent_access_goal)
	var bent_access_surfaces := Proof._surface_domain_index(
		bent_access_goal_state, 100, bent_access_goal_state.pending_contact, Terrain.surfaces(bent_access_goal_state))
	var bent_access_heights: Array[Vector2] = Proof._reachable_elevation_intervals(
		bent_access_goal_state, bent_access_goal_state.pending_contact, 100, bent_access_domain,
		bent_access_surfaces, bent_access_goal, [])
	var bent_height_preserved := false
	for interval: Vector2 in bent_access_heights:
		if interval.x <= 5.0 + 0.001 and interval.y >= 5.0 - 0.001: bent_height_preserved = true
	var bent_access_route := MovementPathfinder.new(bent_access_goal_state, 100, 20.0, "surge").distance_to(Vector2(2.0, 8.0), 5.0)
	check(not bent_height_preserved and is_inf(bent_access_route),
		"An off-route access zone kept an unreachable target height in the certificate (domain %s; route %.3f)" % [str(bent_access_heights), bent_access_route])
	var malformed_access_goal_state: Dictionary = bent_access_goal_state.duplicate(true)
	var malformed_access_areas: Array = malformed_access_goal_state.terrain.areas
	var malformed_access_area: Dictionary = malformed_access_areas[0]
	var malformed_access_surfaces: Array = malformed_access_area.surfaces
	malformed_access_surfaces[0]["access_features"] = "invalid access data"
	malformed_access_area.surfaces = malformed_access_surfaces
	malformed_access_areas[0] = malformed_access_area
	malformed_access_goal_state.terrain.areas = malformed_access_areas
	var malformed_access_domain: Dictionary = Proof._surface_domain_index(
		malformed_access_goal_state, 100, malformed_access_goal_state.pending_contact, Terrain.surfaces(malformed_access_goal_state))
	var malformed_access_heights: Array[Vector2] = Proof._reachable_elevation_intervals(
		malformed_access_goal_state, malformed_access_goal_state.pending_contact, 100, bent_access_domain,
		malformed_access_domain, bent_access_goal, [])
	var malformed_height_preserved := false
	for interval: Vector2 in malformed_access_heights:
		if interval.x <= 5.0 + 0.001 and interval.y >= 5.0 - 0.001: malformed_height_preserved = true
	check(malformed_access_domain.unknown and malformed_height_preserved,
		"Malformed access data narrowed the continuous safe fallback domain")
	# Descending onto a lower floor uses that destination's access feature, which
	# can be reachable even when the starting floor's access is far away. The
	# lower floor can then provide access to ground.
	var intermediate_access_state: Dictionary = unsupported_height_formation.duplicate(true)
	intermediate_access_state.units[100].position = Vector2(-0.5, 0.0)
	intermediate_access_state.units[100].elevation = 5.0
	intermediate_access_state.units[101].position = Vector2(-2.0, 0.0)
	intermediate_access_state.units[300].position = Vector2(0.0, 0.0)
	intermediate_access_state.units[300].elevation = 8.0
	intermediate_access_state.terrain.areas = [{"name": "Lower intermediate access", "category": "ruin",
		"bounds": Rect2(-4.0, -4.0, 28.0, 8.0),
		"features": [
			{"bounds": Rect2(20.0, -0.5, 1.0, 1.0), "height": 6.0, "blocks_end": true},
			{"bounds": Rect2(-0.25, 0.55, 0.5, 0.1), "height": 4.0, "blocks_end": true}],
		"surfaces": [
			{"id": "higher-access", "elevation": 5.0, "bounds": Rect2(-4.0, -4.0, 28.0, 8.0),
				"features": [], "access_features": [0], "requires_keywords": ["infantry"]},
			{"id": "lower-access", "elevation": 3.0, "bounds": Rect2(-4.0, -4.0, 8.0, 8.0),
				"features": [], "access_features": [1], "requires_keywords": ["infantry"]}]}]
	intermediate_access_state.pending_contact.maximum = 12.0
	intermediate_access_state.pending_contact.origins[100] = Vector2(-0.5, 0.0)
	intermediate_access_state.pending_contact.origins[101] = Vector2(-2.0, 0.0)
	intermediate_access_state.pending_contact.origin_elevations[100] = 5.0
	intermediate_access_state.pending_contact.origin_elevations[101] = 0.0
	var intermediate_surface_domain: Dictionary = Proof._surface_domain_index(
		intermediate_access_state, 100, intermediate_access_state.pending_contact, Terrain.surfaces(intermediate_access_state))
	var intermediate_height_domains: Array[Vector2] = Proof._reachable_elevation_intervals(
		intermediate_access_state, intermediate_access_state.pending_contact, 100, Rect2(-12, -12, 24, 24),
		intermediate_surface_domain, {"target_elevation": 8.0}, [])
	var all_intermediate_height_domains: Array[Vector2] = Proof._reachable_elevation_intervals(
		intermediate_access_state, intermediate_access_state.pending_contact, 100, Rect2(-12, -12, 24, 24),
		intermediate_surface_domain, {}, [])
	var lower_height_preserved := false
	var ground_height_preserved := false
	for interval: Vector2 in intermediate_height_domains:
		if interval.x <= 3.0 + 0.001 and interval.y >= 3.0 - 0.001: lower_height_preserved = true
	for interval: Vector2 in all_intermediate_height_domains:
		if interval.x <= 0.001 and interval.y >= -0.001: ground_height_preserved = true
	var lower_floor_route := MovementPathfinder.new(intermediate_access_state, 100, 12.0, "surge").distance_to(Vector2.ZERO, 3.0)
	var ground_route := MovementPathfinder.new(intermediate_access_state, 100, 12.0, "surge").distance_to(Vector2.ZERO, 0.0)
	check(lower_height_preserved and is_equal_approx(lower_floor_route, 2.5),
		"A reachable lower floor was discarded because the certificate used the distant starting-floor access (domain %s; route %.3f)" % [str(intermediate_height_domains), lower_floor_route])
	check(ground_height_preserved and not is_inf(ground_route) and ground_route <= 12.0,
		"A route via a nearer lower-floor access did not preserve ground in the relaxed domain (domain %s; route %.3f)" % [str(all_intermediate_height_domains), ground_route])
	# The focus model has a clear four-inch route into Engagement Range, but its
	# teammate cannot cross the wall within the same allowance to keep coherency.
	# A group proof must include route lower bounds for every supporting model.
	state = fixture()
	state.units[101].wounds = 2
	state.units[100].radius = 0.5
	state.units[101].radius = 0.5
	state.units[200].radius = 0.5
	state.units[100].position = Vector2(1.1, 0)
	state.units[101].position = Vector2(-1.1, 0)
	state.units[200].position = Vector2(7.5, 0)
	state.terrain.areas = [{"name": "Full-height wall", "category": "legacy", "bounds": Rect2(-0.5, -10, 1.0, 20), "features": [{"bounds": Rect2(-0.5, -10, 1.0, 20), "height": 3.0, "blocks_end": true}]}]
	state.pending_contact = {"squad": 1, "kind": "surge", "maximum": 4.0,
		"origins": {100: Vector2(1.1, 0), 101: Vector2(-1.1, 0)}, "locked": {}, "engaged": {100: [], 101: []}}
	var individual_route := MovementPathfinder.new(state, 100, 4.0, "surge").distance_to(Vector2(4.5, 0))
	proof = Proof.certify_impossible(state, 100, [2], 2.0)
	check(is_equal_approx(individual_route, 3.4) and proof.impossible and proof.reason == "coherent_placement",
		"A model's reachable engagement does not imply a coherent Surge placement when its teammate cannot route around a wall")
	var closest_formation: Dictionary = state.duplicate(true)
	closest_formation.units[100].position = Vector2(2.0, 0)
	closest_formation.units[101].position = Vector2(-1.0, 0)
	var surge_error := HeresyRetribution.enemy_target_end_error(state, closest_formation, 1, 2, 4.0)
	check(Combat.Contact.coherent(closest_formation, 1) and surge_error.is_empty(),
		"Surge accepts a coherent endpoint when individual movement reaches farther than any coherent formation can; error=%s" % surge_error)
	# Under-approximate each fixed Surge base blocker with a stepped union of
	# inscribed rectangles. It should prune more than the previous square while
	# remaining a lower bound for the physical circular blocker.
	state = fixture()
	state.terrain.areas = []
	state.units[100].radius = 0.5
	state.units[200].radius = 0.5
	state.units[100].position = Vector2(-5, 0)
	state.units[200].position = Vector2.ZERO
	state.pending_contact = {"squad": 1, "kind": "surge", "maximum": 12.0,
		"origins": {100: Vector2(-5, 0)}, "locked": {}, "engaged": {100: []}}
	var blocker_radius := float(state.units[100].radius) + float(state.units[200].radius)
	var inscribed_radius := blocker_radius - Proof.MOVEMENT_EPSILON - Proof.PADDING
	var half_extent := inscribed_radius / sqrt(2.0)
	var square_relaxation := Rect2(Vector2(-half_extent, -half_extent), Vector2.ONE * half_extent * 2.0)
	var blocker_rectangles := Proof._inscribed_circle_rectangles(Vector2.ZERO, inscribed_radius)
	var surge_obstacles := Proof._obstacles(float(state.units[100].radius), state, 100, true)
	var all_blocker_rectangles_present := blocker_rectangles.size() == Proof.SURGE_BLOCKER_SLICES
	var all_blocker_rectangles_inside_disk := all_blocker_rectangles_present
	for expected: Rect2 in blocker_rectangles:
		var found := false
		for obstacle: Rect2 in surge_obstacles:
			if (obstacle.position.distance_to(expected.position) <= 0.000001
				and obstacle.size.distance_to(expected.size) <= 0.000001):
				found = true
				break
		if not found: all_blocker_rectangles_present = false
		for corner: Vector2 in Proof._corners(expected):
			if corner.distance_to(Vector2.ZERO) > inscribed_radius + 0.000001:
				all_blocker_rectangles_inside_disk = false
	var terrain_only_obstacles := Proof._obstacles(float(state.units[100].radius), state, 100)
	var square_obstacles: Array[Rect2] = []
	square_obstacles.assign(terrain_only_obstacles)
	square_obstacles.append(square_relaxation)
	var square_circle_route := Proof._terrain_lower_bound_with_obstacles(
		Vector2(-5, 0), Rect2(Vector2(5, 0), Vector2.ZERO), square_obstacles)
	var relaxed_circle_route := Proof._terrain_lower_bound_with_obstacles(
		Vector2(-5, 0), Rect2(Vector2(5, 0), Vector2.ZERO), surge_obstacles)
	var exact_circle_route := (
		2.0 * sqrt(25.0 - blocker_radius * blocker_radius)
		+ 2.0 * blocker_radius * asin(blocker_radius / 5.0))
	var eight_slice_obstacles: Array[Rect2] = terrain_only_obstacles.duplicate()
	eight_slice_obstacles.append_array(Proof._inscribed_circle_rectangles(Vector2.ZERO, inscribed_radius, 8))
	var eight_slice_circle_route := Proof._terrain_lower_bound_with_obstacles(
		Vector2(-5, 0), Rect2(Vector2(5, 0), Vector2.ZERO), eight_slice_obstacles)
	check(all_blocker_rectangles_present and all_blocker_rectangles_inside_disk,
		"Surge route relaxation includes only inscribed rectangles for each fixed enemy-base blocker")
	check(relaxed_circle_route > square_circle_route + 0.01 and relaxed_circle_route > eight_slice_circle_route + 0.001
		and relaxed_circle_route < exact_circle_route,
		"Sixteen inscribed slices strengthen the previous eight-slice and square bounds without exceeding the exact circle route")
	var direct_goal := Rect2(Vector2(5, 4), Vector2.ZERO)
	var direct_route_bound := Proof._terrain_lower_bound_with_obstacles(Vector2(-5, 0), direct_goal, surge_obstacles)
	check(is_equal_approx(direct_route_bound, Vector2(-5, 0).distance_to(Vector2(5, 4))),
		"A visible direct segment to the nearest goal-box point returns its exact relaxed distance")
	var cutoff_wall: Array[Rect2] = [Rect2(Vector2(2, -2), Vector2(0.5, 4))]
	var no_route_vertices: Array[Vector2] = []
	var full_wall_route_bound := Proof._terrain_lower_bound_with_obstacles(
		Vector2.ZERO, Rect2(Vector2(5, 0), Vector2.ZERO), cutoff_wall)
	var movement_cutoff_bound := Proof._terrain_lower_bound_with_obstacles(
		Vector2.ZERO, Rect2(Vector2(5, 0), Vector2.ZERO), cutoff_wall, no_route_vertices, 4.0)
	check(is_equal_approx(movement_cutoff_bound, 5.0) and movement_cutoff_bound > 4.0
		and full_wall_route_bound > movement_cutoff_bound,
		"The movement-bounded certificate returns a straight-line lower bound above allowance instead of searching the longer wall route")
	print("Movement-budget route cutoff: lower bound %.4f; full wall-route bound %.4f; allowance 4.0000 inches" % [
		movement_cutoff_bound, full_wall_route_bound])
	var coherency_origin := Vector2(-5, 0)
	var coherency_goal := Rect2(Vector2(5, -1), Vector2(1, 2))
	var coherency_obstacles: Array[Rect2] = [Rect2(Vector2(-0.5, -2), Vector2(1, 4))]
	for index in range(11):
		coherency_obstacles.append(Rect2(Vector2(8 + index * 2, 10 + index), Vector2.ONE))
	var route_allowance := 10.0
	var certificate_cutoff := route_allowance + Proof.CERTIFICATE_MARGIN
	var relevant_coherency_obstacles := Proof._route_relevant_obstacles(
		coherency_origin, coherency_goal, coherency_obstacles, certificate_cutoff)
	var retained_coherency_vertices := Proof._obstacle_vertices(relevant_coherency_obstacles)
	var full_coherency_vertices := Proof._obstacle_vertices(coherency_obstacles)
	var full_coherency_route := Proof._terrain_lower_bound_with_obstacles(
		coherency_origin, coherency_goal, coherency_obstacles, full_coherency_vertices)
	var bounded_coherency_route := Proof._terrain_lower_bound_with_obstacles(
		coherency_origin, coherency_goal, coherency_obstacles, full_coherency_vertices, certificate_cutoff)
	var malformed_route_obstacles: Array[Rect2] = [Rect2(Vector2.ZERO, Vector2(-1, 1))]
	check(Proof._route_relevant_obstacles(coherency_origin, coherency_goal,
		malformed_route_obstacles, route_allowance).size() == 1,
		"Coherency route pruning retains malformed obstacle geometry")
	check(relevant_coherency_obstacles.size() == 1 and retained_coherency_vertices.size() == 4
		and full_coherency_vertices.size() == 48,
		"The movement-budget route filter removes eleven remote rectangles and their 44 visibility corners")
	check(bounded_coherency_route > certificate_cutoff and bounded_coherency_route <= full_coherency_route + 0.000001,
		"The bounded A* cutoff returns a safe lower bound above the movement allowance and certificate margin: bounded=%.4f full=%.4f" % [
			bounded_coherency_route, full_coherency_route])
	print("Coherency route cutoff: 11 obstacles and 44 vertices omitted; lower bound %.4f; full bound %.4f; allowance %.4f inches; certificate cutoff %.4f inches" % [
		bounded_coherency_route, full_coherency_route, route_allowance, certificate_cutoff])
	var rectangle_detour := Proof._terrain_lower_bound_with_obstacles(
		Vector2(-2, 0), Rect2(Vector2(2, 0), Vector2.ZERO), [Rect2(Vector2(-0.5, -1), Vector2(1, 2))])
	var exact_rectangle_detour := 2.0 * Vector2(-1.5, -1).length() + 1.0
	check(is_equal_approx(rectangle_detour, exact_rectangle_detour),
		"A* over the obstacle visibility graph preserves the exact shortest rectangle detour")
	# Obstacles outside every route ellipse within the move allowance cannot
	# affect the route. Ignore them before generating blocker-pair tangents.
	var clutter_state := fixture()
	clutter_state.board_size = Vector2(44, 30)
	clutter_state.terrain.areas = []
	clutter_state.units[100].radius = 0.5
	clutter_state.units[200].radius = 0.5
	clutter_state.units[100].position = Vector2(-5, 0)
	clutter_state.units[200].position = Vector2.ZERO
	var remote_obstacles: Array[Rect2] = []
	var remote_features: Array[Dictionary] = []
	for index in range(11):
		var remote_blocker: Dictionary = clutter_state.units[200].duplicate(true)
		var angle := deg_to_rad(30.0 + 30.0 * float(index))
		var remote_position: Vector2 = clutter_state.units[100].position + Vector2.from_angle(angle) * 10.0
		remote_blocker.position = remote_position
		clutter_state.units[300 + index] = remote_blocker
		var remote_bounds := Rect2(remote_position - Vector2.ONE * 0.1, Vector2.ONE * 0.2)
		remote_obstacles.append(remote_bounds)
		remote_features.append({"bounds": remote_bounds, "height": 4.0, "blocks_end": true})
	clutter_state.terrain.areas = [{"name": "Remote route clutter", "category": "legacy", "bounds": Rect2(-22, -15, 44, 30), "features": remote_features}]
	var clutter_pathfinder := MovementPathfinder.new(clutter_state, 100, 12.0, "surge")
	var all_route_blockers := clutter_pathfinder._model_blocking_circles(clutter_state.units[100].position)
	var relevant_route_blockers := clutter_pathfinder._route_relevant_blockers(Vector2(5, 0), all_route_blockers)
	var relevant_route_terrain := clutter_pathfinder._route_relevant_terrain_obstacles(
		Vector2(5, 0), remote_obstacles, float(clutter_state.units[100].radius) - 0.001 + 0.01)
	var malformed_blocker: Array[Dictionary] = [{"center": Vector2(INF, 0), "radius": 1.0}]
	check(clutter_pathfinder._route_relevant_blockers(Vector2(5, 0), malformed_blocker).size() == 1,
		"Route relevance pruning retains blockers with malformed geometry")
	var malformed_terrain: Array[Rect2] = [Rect2(0, 0, -1, 1)]
	check(clutter_pathfinder._route_relevant_terrain_obstacles(Vector2(5, 0), malformed_terrain, 0.5).size() == 1,
		"Route relevance pruning retains terrain with malformed geometry")
	var clutter_route := clutter_pathfinder.distance_to(Vector2(5, 0))
	var central_clearance := 0.0
	for blocker: Dictionary in all_route_blockers:
		if Vector2(blocker.center).distance_to(Vector2.ZERO) <= 0.000001: central_clearance = float(blocker.exact_radius)
	var central_exact_route := 2.0 * sqrt(25.0 - central_clearance * central_clearance) + 2.0 * central_clearance * asin(central_clearance / 5.0)
	var full_pair_checks := all_route_blockers.size() * (all_route_blockers.size() - 1) / 2
	var relevant_pair_checks := relevant_route_blockers.size() * (relevant_route_blockers.size() - 1) / 2
	check(all_route_blockers.size() == 12 and relevant_route_blockers.size() == 1
		and full_pair_checks == 66 and relevant_pair_checks == 0 and remote_obstacles.size() == 11 and relevant_route_terrain.is_empty(),
		"Route ellipse pruning reduces circle-pair checks from 66 to 0 and drops 44 unreachable terrain corners")
	check(not is_inf(clutter_route) and clutter_route <= 12.0 + 0.001 and clutter_route <= central_exact_route + 0.15
		and not clutter_pathfinder._visibility_graph_overflow,
		"The pruned graph preserves the legal central-circle detour without overflowing: route=%.4f exact=%.4f nodes=%d" % [clutter_route, central_exact_route, clutter_pathfinder._visibility_graph_nodes.size()])
	var ellipse_state: Dictionary = clutter_state.duplicate(true)
	var diagonal_blocker: Dictionary = ellipse_state.units[200].duplicate(true)
	diagonal_blocker.position = Vector2(0, 3.5)
	ellipse_state.units[400] = diagonal_blocker
	var ellipse_pathfinder := MovementPathfinder.new(ellipse_state, 100, 12.0, "surge")
	var ellipse_route := ellipse_pathfinder.distance_to(Vector2(5, 0))
	var ellipse_nodes_within_allowance := true
	for route_node: Vector2 in ellipse_pathfinder._visibility_graph_nodes:
		if Vector2(-5, 0).distance_to(route_node) + route_node.distance_to(Vector2(5, 0)) > 12.001:
			ellipse_nodes_within_allowance = false
	check(not is_inf(ellipse_route) and ellipse_route <= 12.0 + 0.001
		and ellipse_route <= central_exact_route + 0.15
		and ellipse_pathfinder._visibility_graph_ellipse_pruned_nodes > 0
		and ellipse_pathfinder._visibility_graph_ellipse_pruned_straight_edges + ellipse_pathfinder._visibility_graph_ellipse_pruned_arc_edges > 0
		and ellipse_nodes_within_allowance and not ellipse_pathfinder._visibility_graph_overflow,
		"Route-ellipse node and edge pruning discards over-budget candidates while preserving the central detour: route=%.4f exact=%.4f nodes=%d straight_edges=%d arcs=%d graph_nodes=%d" % [
			ellipse_route, central_exact_route, ellipse_pathfinder._visibility_graph_ellipse_pruned_nodes,
			ellipse_pathfinder._visibility_graph_ellipse_pruned_straight_edges,
			ellipse_pathfinder._visibility_graph_ellipse_pruned_arc_edges,
			ellipse_pathfinder._visibility_graph_nodes.size()])
	print("Route-ellipse pruning: %d nodes, %d straight edges and %d arcs omitted; %d graph nodes retained; route %.4f inches" % [
		ellipse_pathfinder._visibility_graph_ellipse_pruned_nodes,
		ellipse_pathfinder._visibility_graph_ellipse_pruned_straight_edges,
		ellipse_pathfinder._visibility_graph_ellipse_pruned_arc_edges,
		ellipse_pathfinder._visibility_graph_nodes.size(), ellipse_route])
	var dense_route_state := fixture()
	dense_route_state.terrain.areas = []
	dense_route_state.board_size = Vector2(44, 30)
	dense_route_state.units[100].position = Vector2(-10, 0)
	dense_route_state.units[200].position = Vector2(-2.2, -4.4)
	for row in range(5):
		for column in range(3):
			if row == 0 and column == 0: continue
			var dense_blocker_id := 300 + row * 3 + column
			var dense_blocker: Dictionary = dense_route_state.units[200].duplicate(true)
			dense_blocker.position = Vector2(-2.2 + column * 2.2, -4.4 + row * 2.2)
			dense_blocker.wounds = 2
			dense_route_state.units[dense_blocker_id] = dense_blocker
	var dense_pathfinder := MovementPathfinder.new(dense_route_state, 100, 24.0, "surge")
	var dense_route := dense_pathfinder.distance_to(Vector2(10, 0))
	check(dense_pathfinder._visibility_graph_overflow and not is_inf(dense_route)
		and absf(dense_route - 23.8052) <= 0.001
		and dense_pathfinder._fallback_route_expansions < dense_pathfinder._nodes.size()
		and dense_pathfinder._fallback_route_edge_checks < dense_pathfinder._nodes.size() * dense_pathfinder._nodes.size(),
		"The overflow fallback preserves the validated 15-blocker route while stopping directed A* early: route=%.4f nodes=%d expansions=%d checks=%d" % [
			dense_route, dense_pathfinder._nodes.size(), dense_pathfinder._fallback_route_expansions,
			dense_pathfinder._fallback_route_edge_checks])
	print("Dense route fallback: 15 blockers; route %.4f inches; fallback nodes %d; A* expanded %d nodes and validated %d edges" % [
		dense_route, dense_pathfinder._nodes.size(), dense_pathfinder._fallback_route_expansions,
		dense_pathfinder._fallback_route_edge_checks])
	var dense_closest := dense_pathfinder.closest_reachable_to_region(Rect2(Vector2(10, 0), Vector2.ZERO), 2.0)
	check(dense_pathfinder._visibility_graph_overflow and dense_closest.distance <= 0.001
		and dense_closest.route_distance <= 24.0 + 0.001
		and dense_pathfinder._fallback_route_expansions < dense_pathfinder._nodes.size()
		and dense_pathfinder._fallback_route_edge_checks < dense_pathfinder._nodes.size() * dense_pathfinder._nodes.size(),
		"Target-directed route search finds a legal closest point for the dense Surge target: gap=%.4f route=%.4f expansions=%d checks=%d" % [
			dense_closest.distance, dense_closest.route_distance, dense_pathfinder._fallback_route_expansions,
			dense_pathfinder._fallback_route_edge_checks])
	print("Dense target search: gap %.4f inches; route %.4f inches; A* expanded %d nodes and validated %d edges" % [
		dense_closest.distance, dense_closest.route_distance, dense_pathfinder._fallback_route_expansions,
		dense_pathfinder._fallback_route_edge_checks])
	var first_dense_target_edge_checks := dense_pathfinder._fallback_route_edge_checks
	var second_dense_closest := dense_pathfinder.closest_reachable_to_region(Rect2(Vector2(10, 1), Vector2.ZERO), 2.0)
	check(second_dense_closest.distance <= 0.001
		and second_dense_closest.route_distance <= 24.0 + 0.001
		and dense_pathfinder._fallback_route_edge_checks < first_dense_target_edge_checks,
		"Repeated dense target searches reuse validated route edges: first=%d second=%d" % [
			first_dense_target_edge_checks, dense_pathfinder._fallback_route_edge_checks])
	print("Repeated target search: gap %.4f inches; route %.4f inches; new edge validations %d (first target %d)" % [
		second_dense_closest.distance, second_dense_closest.route_distance,
		dense_pathfinder._fallback_route_edge_checks, first_dense_target_edge_checks])
	var overlap_vertices := Proof._rect_intersections(
		Rect2(Vector2(-2, -1), Vector2(2, 2)), Rect2(Vector2(-1, 0), Vector2(2, 2)))
	var has_first_overlap_vertex := false
	var has_second_overlap_vertex := false
	for point: Vector2 in overlap_vertices:
		has_first_overlap_vertex = has_first_overlap_vertex or point.distance_to(Vector2.ZERO) <= 0.000001
		has_second_overlap_vertex = has_second_overlap_vertex or point.distance_to(Vector2(-1, 1)) <= 0.000001
	check(has_first_overlap_vertex and has_second_overlap_vertex,
		"Relaxed route visibility graphs include rectangle-edge intersections")
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
