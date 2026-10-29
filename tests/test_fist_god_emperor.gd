extends SceneTree

const Prepared = preload("res://scripts/edition_11/prepared_training.gd")
const ArmyCapabilities = preload("res://scripts/edition_11/army_capabilities.gd")
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Enhancements = preload("res://scripts/edition_11/stormlance_enhancements.gd")
const Surge = preload("res://scripts/edition_11/crusader_surge.gd")
const HeresyRetribution = preload("res://scripts/edition_11/heresy_retribution.gd")
const MovementPathfinder = preload("res://scripts/edition_11/movement_pathfinder.gd")
const MovementGeometry = preload("res://scripts/edition_11/contact_movement.gd")
const Terrain = preload("res://scripts/edition_11/terrain.gd")
const Objectives = preload("res://scripts/edition_11/objectives.gd")
const PublicUnitCommand = preload("res://tests/public_unit_command.gd")
const C = Prepared.Combat
const D = C.DetachmentStratagems
const FIST := "fist-of-the-god-emperor"
var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func army(faction: String, identity: String, models: int, enhancement_id: String = "") -> Dictionary:
	var prefix := "adeptus-astartes" if faction == "Space Marines" else "necrons"
	return {"schema_version": 2, "faction": faction, "category": "training", "points_limit": 500,
		"entries": [{"definition_id": "40kdc:11e:%s:%s" % [prefix, identity], "models": models, "copies": 1, "enhancement_id": enhancement_id}]}

func fresh_fist(enhancement_id: String = "", identity: String = "crusader-squad", models: int = 10) -> Dictionary:
	var selections := {
		1: army("Space Marines", identity, models, enhancement_id),
		2: army("Necrons", "necron-warriors", 10)
	}
	return Prepared.initial_state({
		"manual_allocation": false,
		"core_stratagems": true,
		"unit_abilities": true,
		"combat_doctrines": true,
		"marine_detachments": {1: FIST, 2: "none"},
		"marine_chapters": {1: "BLACK TEMPLARS"}
	}, selections)

func squad_for(state: Dictionary, owner: int, identity: String = "") -> int:
	for squad: int in state.get("squads", {}):
		if int(state.squads[squad].get("owner", -1)) != owner: continue
		if identity.is_empty(): return squad
		for model: int in C.living(state, squad):
			if C.UnitAbilities.identity(state.units[model]) == identity: return squad
	return -1

func prepare_battle(state: Dictionary, phase: String, active: int) -> void:
	state.phase = phase
	state.active = active
	state.turn = 3
	state.round = 2
	state.deployment.complete = true
	state.mission.stage = "battle"
	state.unit_abilities.setup_done = true
	state.unit_abilities.setup_players = [1, 2]
	state.unit_abilities.battle_players = [1, 2]
	state.unit_abilities.window = {}
	state.unit_abilities.phase_key = C.UnitActions.key(state)
	state.pending_move = {}
	state.pending_contact = {}
	state.pending_attack = {}
	state.resolution_frames = []
	state.terrain.areas = []
	state.cp[1] = 3
	state.cp[2] = 3

func choice_for(state: Dictionary, player: int, action: String, target: int = -1, value: String = "", model: int = -1) -> Dictionary:
	for choice: Dictionary in C.UnitActions.choices(state, player):
		if str(choice.get("action", "")) == action and int(choice.get("target", -1)) == target and str(choice.get("value", "")) == value and int(choice.get("model", -1)) == model:
			return choice
	return {}

func submit(state: Dictionary, player: int, action: String, target: int = -1, value: String = "", model: int = -1, point: Vector2 = Vector2.ZERO, roller: Callable = Callable(), destination_elevation: float = -1.0) -> Dictionary:
	var choice := choice_for(state, player, action, target, value, model)
	if choice.is_empty(): return {"error": "No projected %s choice for target %d/value %s/model %d." % [action, target, value, model]}
	return PublicUnitCommand.submit(state, player, choice, point, roller, "", "", destination_elevation)

func dead_by_enemy_shot(state: Dictionary) -> void:
	var squad := squad_for(state, 1, "crusader-squad")
	var shooter := squad_for(state, 2)
	var dead := C.living(state, squad)[0]
	state.units[dead].wounds = 0
	Surge.open_after_enemy_shot(state, shooter, [{"target_squad": squad, "models_destroyed": 1, "allocations": [{"model": dead, "wounds_before": 2, "wounds_after": 0}]}])

func test_surge_routes() -> void:
	var portal_contacts := MovementPathfinder._segment_rect_contact_points(
		Vector2(-2.0, 0.25), Vector2(2.0, 0.25), Rect2(-0.5, -0.5, 1.0, 1.0))
	var exact_portal_entry := false
	var exact_portal_exit := false
	for point: Vector2 in portal_contacts:
		if point.distance_to(Vector2(-0.5, 0.25)) <= Terrain.EPSILON: exact_portal_entry = true
		if point.distance_to(Vector2(0.5, 0.25)) <= Terrain.EPSILON: exact_portal_exit = true
	check(exact_portal_entry and exact_portal_exit,
		"Segment-to-portal projection retains exact entry and exit points between sampled access candidates")
	var portal := Rect2(0.0, 0.0, 2.0, 2.0)
	var route_nodes: Array[Vector2] = [Vector2(-2.0, 0.0), Vector2(-2.0, 2.0), Vector2(2.0, 0.0)]
	var multi_waypoint_contacts: Array[Vector2] = []
	MovementPathfinder._append_route_portal_contacts(
		multi_waypoint_contacts, route_nodes, Vector2(-2.0, 0.0), 10.0, portal)
	var exact_multi_waypoint_contact := false
	for point: Vector2 in multi_waypoint_contacts:
		if point.distance_to(Vector2(0.0, 1.0)) <= Terrain.EPSILON:
			exact_multi_waypoint_contact = true
			break
	check(exact_multi_waypoint_contact,
		"Portal candidates include an exact contact on a route edge between two non-origin waypoints")
	var remote_waypoint_contacts: Array[Vector2] = []
	MovementPathfinder._append_route_portal_contacts(
		remote_waypoint_contacts, [Vector2(4.0, 0.0), Vector2(10.0, 0.0)], Vector2.ZERO, 6.0, Rect2(5.0, -1.0, 2.0, 2.0))
	var in_budget_remote_contact := false
	var over_budget_remote_contact := false
	for point: Vector2 in remote_waypoint_contacts:
		if point.distance_to(Vector2(5.0, 0.0)) <= Terrain.EPSILON: in_budget_remote_contact = true
		if point.distance_to(Vector2(7.0, 0.0)) <= Terrain.EPSILON: over_budget_remote_contact = true
	check(in_budget_remote_contact and not over_budget_remote_contact,
		"A remote route waypoint does not hide a portal contact reached within the movement budget")
	var circle_portal_contacts := MovementPathfinder._circle_rect_intersections(
		Vector2(-0.5, 1.0), 1.25, Rect2(0.0, 0.0, 2.0, 2.0))
	var lower_circle_portal_contact := false
	var upper_circle_portal_contact := false
	for point: Vector2 in circle_portal_contacts:
		if point.distance_to(Vector2(0.25, 0.0)) <= Terrain.EPSILON: lower_circle_portal_contact = true
		if point.distance_to(Vector2(0.25, 2.0)) <= Terrain.EPSILON: upper_circle_portal_contact = true
	check(lower_circle_portal_contact and upper_circle_portal_contact,
		"Access-zone candidates include exact circle intersections with both horizontal portal edges")
	var state := fresh_fist()
	if state.has("error"):
		check(false, "Surge route checks initialize a current-reference battle")
		return
	prepare_battle(state, "shooting", 2)
	var friendly_squad := squad_for(state, 1, "crusader-squad")
	var enemy_squad := squad_for(state, 2)
	var mover := C.living(state, friendly_squad)[0]
	var blocker := C.living(state, friendly_squad)[1]
	var enemy_models := C.living(state, enemy_squad)
	if enemy_models.size() < 3:
		check(false, "Surge route fixture contains three enemy bases for multi-blocker coverage")
		return
	var enemy: int = enemy_models[0]
	var second_enemy: int = enemy_models[1]
	var third_enemy: int = enemy_models[2]
	for model: int in state.units: state.units[model].wounds = 0
	state.units[mover].wounds = 1
	state.units[blocker].wounds = 1
	state.units[enemy].wounds = 1
	state.units[mover].position = Vector2(-4, 0)
	state.units[blocker].position = Vector2(0, 0)
	state.units[enemy].position = Vector2(10, 0)
	var straight_through_friendly := MovementPathfinder.new(state, mover, 8.0, "surge").distance_to(Vector2(4, 0))
	check(is_equal_approx(straight_through_friendly, 8.0), "Surge routes may pass through friendly bases where the movement rules permit it")
	state.units[enemy].position = Vector2(0, 0)
	var around_enemy := MovementPathfinder.new(state, mover, 12.5, "surge").distance_to(Vector2(4, 0))
	check(not is_inf(around_enemy) and around_enemy > 8.0 and around_enemy <= 12.5, "Surge routes go around blocking enemy bases and measure the detour")
	state.units[blocker].wounds = 0
	var diagonal_axis := Vector2.RIGHT.rotated(deg_to_rad(7.5))
	state.units[mover].position = -diagonal_axis * 4.0
	state.units[enemy].position = Vector2.ZERO
	var combined_radius := float(state.units[mover].radius) + float(state.units[enemy].radius)
	var exact_circle_route := 2.0 * sqrt(16.0 - combined_radius * combined_radius) + 2.0 * combined_radius * asin(combined_radius / 4.0)
	var tangent_route := MovementPathfinder.new(state, mover, exact_circle_route + 0.008, "surge").distance_to(diagonal_axis * 4.0)
	check(not is_inf(tangent_route) and tangent_route >= exact_circle_route - 0.0001 and tangent_route <= exact_circle_route + 0.008,
		"Analytic clearance-bound tangents keep the single-circle detour within 0.008 inches of the exact route (got %.5f; exact %.5f)" % [tangent_route, exact_circle_route])
	var board_half := Vector2(state.get("board_size", Vector2.ZERO)) / 2.0
	var exact_radius := combined_radius + 0.01
	var edge_center_y := board_half.y - float(state.units[mover].radius) - exact_radius * 0.5
	var edge_offset := exact_radius * 0.25
	state.units[mover].position = Vector2(-2.0, edge_center_y + edge_offset)
	state.units[enemy].position = Vector2(0.0, edge_center_y)
	var endpoint_radius := Vector2(2.0, edge_offset).length()
	var endpoint_angle := atan2(edge_offset, 2.0)
	var tangent_angle := acos(exact_radius / endpoint_radius)
	var upper_arc := PI - 2.0 * endpoint_angle - 2.0 * tangent_angle
	var tangent_legs := 2.0 * sqrt(endpoint_radius * endpoint_radius - exact_radius * exact_radius)
	var upper_edge_route := tangent_legs + exact_radius * upper_arc
	var edge_destination := Vector2(2.0, edge_center_y + edge_offset)
	var off_board_route := MovementPathfinder.new(state, mover, upper_edge_route + 0.008, "surge").distance_to(edge_destination)
	var in_bounds_route := MovementPathfinder.new(state, mover, upper_edge_route + 1.0, "surge").distance_to(edge_destination)
	check(is_inf(off_board_route), "The short upper circular arc is rejected when its base path leaves the battlefield")
	check(not is_inf(in_bounds_route) and in_bounds_route >= upper_edge_route + 0.01 and in_bounds_route <= upper_edge_route + 1.0,
		"The analytic route finds a short in-bounds detour after rejecting the off-board arc (got %.5f; off-board %.5f)" % [in_bounds_route, upper_edge_route])
	state.units[mover].position = -diagonal_axis * 5.0
	state.units[enemy].position = Vector2.ZERO
	var tangent_objective_route := MovementPathfinder.new(state, mover, 10.19, "surge").closest_reachable_to_region(
		Rect2(diagonal_axis * 5.0, Vector2.ZERO), 0.5)
	check(float(tangent_objective_route.distance) <= 0.001 and float(tangent_objective_route.route_distance) <= 10.19,
		"Solo Surge reaches a circular objective region by taking the tangent route around a blocking base")
	state.units[mover].position = -diagonal_axis * 4.0
	var pair_first_center := -diagonal_axis * 1.5
	var pair_second_center := diagonal_axis * 1.5
	var pair_nodes := MovementPathfinder._circle_pair_tangents(
		{"center": pair_first_center, "radius": combined_radius + 0.02},
		{"center": pair_second_center, "radius": combined_radius + 0.02})
	var tangent_pair_verified := false
	for pair: Dictionary in pair_nodes:
		var line := Vector2(pair.second) - Vector2(pair.first)
		var first_normal := (Vector2(pair.first) - pair_first_center).normalized()
		var second_normal := (Vector2(pair.second) - pair_second_center).normalized()
		if absf(line.dot(first_normal)) <= 0.0001 and absf(line.dot(second_normal)) <= 0.0001:
			tangent_pair_verified = true
			break
	check(tangent_pair_verified, "Pairwise circular waypoints are geometrically tangent to both blocking bases")
	state.units[mover].position = -diagonal_axis * 5.0
	state.units[enemy].position = pair_first_center
	state.units[second_enemy].wounds = 1
	state.units[second_enemy].position = pair_second_center
	var pair_start_leg := 3.5
	var pair_clearance_radius := combined_radius + 0.01
	var exact_pair_route := (
		2.0 * sqrt(pair_start_leg * pair_start_leg - pair_clearance_radius * pair_clearance_radius) + 3.0
		+ 2.0 * pair_clearance_radius * (PI / 2.0 - acos(pair_clearance_radius / pair_start_leg)))
	var multi_blocker_route := MovementPathfinder.new(state, mover, exact_pair_route + 0.008, "surge").distance_to(diagonal_axis * 5.0)
	check(not is_inf(multi_blocker_route) and multi_blocker_route >= exact_pair_route - 0.001 and multi_blocker_route <= exact_pair_route + 0.008,
		"Surge routes navigate two diagonal blockers within 0.008 inches of the analytic clearance-bound route")
	for phase_degrees in range(1, 15):
		var phase_axis := Vector2.RIGHT.rotated(deg_to_rad(float(phase_degrees)))
		state.units[mover].position = -phase_axis * 5.0
		state.units[enemy].position = -phase_axis * 1.5
		state.units[second_enemy].position = phase_axis * 1.5
		var phase_route := MovementPathfinder.new(state, mover, exact_pair_route + 0.008, "surge").distance_to(phase_axis * 5.0)
		check(not is_inf(phase_route) and phase_route >= exact_pair_route - 0.001 and phase_route <= exact_pair_route + 0.008,
			"Two-blocker route remains near the analytic bound at a %d-degree waypoint phase (got %.5f; exact %.5f)" % [phase_degrees, phase_route, exact_pair_route])
	state.units[mover].position = Vector2(-5.0, 0.0)
	state.units[enemy].position = Vector2(-0.75, 0.0)
	state.units[second_enemy].position = Vector2.ZERO
	state.units[third_enemy].wounds = 1
	state.units[third_enemy].position = Vector2(0.75, 0.0)
	var triple_clearance_radius := combined_radius + 0.01
	var triple_tangent_distance := 4.25
	var triple_arc_sweep := PI / 2.0 - acos(triple_clearance_radius / triple_tangent_distance)
	var exact_three_blocker_route := 2.0 * sqrt(triple_tangent_distance * triple_tangent_distance - triple_clearance_radius * triple_clearance_radius) + 2.0 * triple_clearance_radius * triple_arc_sweep + 1.5
	var three_blocker_route := MovementPathfinder.new(state, mover, 20.0, "surge").distance_to(Vector2(5.0, 0.0))
	check(not is_inf(three_blocker_route) and three_blocker_route >= exact_three_blocker_route - 0.001 and three_blocker_route <= exact_three_blocker_route + 0.008,
		"Surge routes around three overlapping bases within 0.008 inches of the analytic clearance bound (got %.5f; exact %.5f)" % [three_blocker_route, exact_three_blocker_route])
	var three_blocker_overrun := MovementPathfinder.new(state, mover, three_blocker_route - 0.02, "surge").distance_to(Vector2(5.0, 0.0))
	check(is_inf(three_blocker_overrun), "A three-blocker detour is rejected when its route exceeds the movement allowance")
	state.units[second_enemy].wounds = 0
	state.units[third_enemy].wounds = 0
	state.units[mover].position = Vector2(-4, 0)
	state.units[enemy].position = Vector2(3, 2)
	var tangent_wall := Rect2(-0.5, -1.0, 1.0, 2.0)
	state.terrain.areas = [{"name": "Tangent wall", "category": "legacy", "bounds": tangent_wall,
		"features": [{"bounds": tangent_wall, "height": 2.0, "blocks_end": true}]}]
	var wall_expansion := maxf(0.0, float(state.units[mover].radius) - 0.001) + 0.01
	var expanded_wall := tangent_wall.grow(wall_expansion)
	var wall_corner := Vector2(expanded_wall.end.x, expanded_wall.position.y)
	var safe_circle_radius := (combined_radius + 0.01) / cos(PI / 24.0)
	var wall_circle_tangents := MovementPathfinder._circle_tangent_points(wall_corner, state.units[enemy].position, safe_circle_radius)
	var mixed_obstacle_route := MovementPathfinder.new(state, mover, 10.0, "surge")
	mixed_obstacle_route._build_graph()
	var has_wall_circle_tangent := false
	for tangent: Vector2 in wall_circle_tangents:
		for route_node: Vector2 in mixed_obstacle_route._nodes:
			if tangent.distance_to(route_node) <= 0.001:
				has_wall_circle_tangent = true
				break
		if has_wall_circle_tangent: break
	check(has_wall_circle_tangent, "The fallback waypoint graph connects terrain-corner candidates to nearby circular blockers with tangent nodes")
	var mixed_circle: Dictionary = mixed_obstacle_route._model_blocking_circles(state.units[mover].position)[0]
	var destination := Vector2(6, 2)
	var lower_left_corner := Vector2(expanded_wall.position.x, expanded_wall.position.y)
	var exact_mixed_route := INF
	for first_tangent: Vector2 in MovementPathfinder._circle_tangent_points(wall_corner, mixed_circle.center, mixed_circle.radius):
		for last_tangent: Vector2 in MovementPathfinder._circle_tangent_points(destination, mixed_circle.center, mixed_circle.radius):
			var first_angle := (first_tangent - Vector2(mixed_circle.center)).angle()
			var last_angle := (last_tangent - Vector2(mixed_circle.center)).angle()
			var arc_sweep := minf(fposmod(last_angle - first_angle, TAU), fposmod(first_angle - last_angle, TAU))
			var candidate_route: float = state.units[mover].position.distance_to(lower_left_corner) + lower_left_corner.distance_to(wall_corner)
			candidate_route += wall_corner.distance_to(first_tangent) + float(mixed_circle.radius) * arc_sweep + last_tangent.distance_to(destination)
			exact_mixed_route = minf(exact_mixed_route, candidate_route)
	var mixed_visibility_pathfinder := MovementPathfinder.new(state, mover, 20.0, "surge")
	var mixed_visibility_route := mixed_visibility_pathfinder.distance_to(destination)
	var visibility_graph_has_wall_circle_tangent := false
	for tangent: Vector2 in wall_circle_tangents:
		for route_node: Vector2 in mixed_visibility_pathfinder._visibility_graph_nodes:
			if tangent.distance_to(route_node) <= 0.001:
				visibility_graph_has_wall_circle_tangent = true
				break
		if visibility_graph_has_wall_circle_tangent: break
	check(visibility_graph_has_wall_circle_tangent, "The ground visibility graph includes tangent nodes from terrain corners to circular blockers")
	check(not is_inf(mixed_visibility_route) and mixed_visibility_route <= exact_mixed_route + 0.03,
		"Ground visibility routing finds the constructed terrain-corner-to-circle tangent route within 0.03 inches (got %.5f; reference %.5f)" % [mixed_visibility_route, exact_mixed_route])
	var route_state_before_joined_obstacles: Dictionary = state.duplicate(true)
	for model_id: int in state.units: state.units[model_id].wounds = 0
	state.units[mover].wounds = 1
	state.units[enemy].wounds = 1
	state.units[second_enemy].wounds = 1
	state.units[mover].radius = 0.5
	state.units[enemy].radius = 0.5
	state.units[second_enemy].radius = 0.5
	state.units[mover].position = Vector2(-4, 0)
	state.units[enemy].position = Vector2(0, 2.5)
	state.units[second_enemy].position = Vector2(0, -2.5)
	var joined_obstacle_wall := Rect2(-0.5, -1.0, 1.0, 2.0)
	state.terrain.areas = [{"name": "Joined obstacle wall", "category": "legacy", "bounds": joined_obstacle_wall,
		"features": [{"bounds": joined_obstacle_wall, "height": 2.0, "blocks_end": true}]}]
	var joined_obstacle_route := MovementPathfinder.new(state, mover, 20.0, "surge").distance_to(Vector2(4, 0))
	check(not is_inf(joined_obstacle_route) and joined_obstacle_route > 8.0 and joined_obstacle_route <= 20.0,
		"Surge finds a validated route around a terrain wall joined to two circular blockers")
	state = route_state_before_joined_obstacles
	state.units[enemy].position = Vector2(10, 0)
	state.units[blocker].wounds = 0
	state.terrain.areas = [{"name": "Route wall", "category": "legacy", "bounds": Rect2(-1, -1, 2, 2), "features": [{"bounds": Rect2(-1, -1, 2, 2), "height": 2.0, "blocks_end": true}]}]
	var around_wall := MovementPathfinder.new(state, mover, 10.0, "surge").distance_to(Vector2(4, 0))
	var before_limit := MovementPathfinder.new(state, mover, 8.5, "surge").distance_to(Vector2(4, 0))
	check(not is_inf(around_wall) and around_wall > 8.0 and around_wall <= 10.0, "Surge routes go around blocking terrain while keeping every segment clear")
	var expected_wall_expansion := maxf(0.0, float(state.units[mover].radius) - 0.001) + 0.01
	var wall_corner_dx := 3.0 - expected_wall_expansion
	var wall_corner_dy := 1.0 + expected_wall_expansion
	var exact_wall_route := 2.0 * sqrt(wall_corner_dx * wall_corner_dx + wall_corner_dy * wall_corner_dy) + 2.0 + 2.0 * expected_wall_expansion
	check(around_wall >= exact_wall_route - 0.001 and around_wall <= exact_wall_route + 0.03,
		"Ground-level terrain routing stays within 0.03 inches of the analytic expanded-rectangle path (got %.5f; exact %.5f)" % [around_wall, exact_wall_route])
	check(is_inf(before_limit), "Surge route length cannot exceed the rolled movement distance")
	var can_reach_target := HeresyRetribution._can_reach_engagement(state, mover, enemy_squad, 10.0)
	var closest_reachable := HeresyRetribution._closest_reachable_distance(state, mover, enemy_squad, 10.0)
	check(not can_reach_target and not is_inf(closest_reachable) and closest_reachable < 14.0, "Surge target reachability and closest legal end position account for wall detours")
	state.unit_abilities.window = {"kind": Surge.PLACEMENT, "owners": [1], "queue": [friendly_squad], "queue_index": 0, "squad": friendly_squad, "distance": 10.0, "target_type": "enemy", "surge_target": enemy_squad, "origins": {mover: Vector2(-4, 0)}, "positions": {mover: Vector2(-4, 0)}}
	var surge_wall_error := Surge.position_error_for_model(state, mover, Vector2(4, 0))
	check(surge_wall_error.is_empty(), "Righteous Zeal accepts a legal destination reached by routing around a wall: " + surge_wall_error)
	state.unit_abilities.window = {"kind": HeresyRetribution.WINDOW, "owners": [1], "squad": friendly_squad, "surge_target": enemy_squad, "distance": 10.0, "origins": {mover: Vector2(-4, 0)}, "positions": {mover: Vector2(-4, 0)}}
	var heresy_wall_error := HeresyRetribution.position_error_for_model(state, mover, Vector2(4, 0))
	check(heresy_wall_error.is_empty(), "Heresy Begets Retribution accepts a legal destination reached by routing around a wall: " + heresy_wall_error)
	state.units[enemy].wounds = 0
	state.mission.objectives = [{"name": "Purge objective", "kind": "marker", "position": Vector2(12, 0), "controller": 0, "secured": 0}]
	var objective_route := MovementPathfinder.new(state, mover, 10.0, "surge")
	var objective_endpoint_allowed := func(candidate: Vector2) -> bool:
		var endpoint_state: Dictionary = state.duplicate(false)
		var endpoint_units: Dictionary = state.units.duplicate(false)
		var endpoint_model: Dictionary = state.units[mover].duplicate(false)
		endpoint_model.position = candidate
		endpoint_units[mover] = endpoint_model
		endpoint_state["units"] = endpoint_units
		return not HeresyRetribution._engaged_with_other_enemy_at(endpoint_state, mover, -1)
	var objective_exclusion_circles := HeresyRetribution._enemy_engagement_exclusion_circles(state, mover)
	var objective_best := objective_route.closest_reachable_to_region(
		Rect2(Vector2(12, 0), Vector2.ZERO), float(state.units[mover].radius) + Objectives.MARKER_RADIUS, Callable(), objective_exclusion_circles)
	check(not is_inf(float(objective_best.distance)) and float(objective_best.route_distance) <= 10.001 and float(objective_best.distance) > 3.0,
		"Purge route search finds the closest reachable point after a wall detour when objective range is out of reach")
	var objective_projected: Dictionary = state.duplicate(true)
	objective_projected.units[mover].position = Vector2(objective_best.point)
	var objective_end_error := Surge._target_end_error(state, objective_projected, friendly_squad,
		{"target_type": "objective", "objective": 0, "distance": 10.0})
	check(objective_end_error.is_empty(), "Purge and Sanctify accepts the closest reachable wall-detour endpoint")
	state.terrain.areas = []
	state.units[enemy].wounds = 1
	state.units[enemy].position = Vector2(6, 1.5)
	state.units[mover].position = Vector2(-4, 0)
	var safe_exclusion_circles := HeresyRetribution._enemy_engagement_exclusion_circles(state, mover)
	var safe_endpoint := MovementPathfinder.new(state, mover, 8.0, "surge").closest_reachable_to_region(
		Rect2(Vector2(12, 0), Vector2.ZERO), float(state.units[mover].radius) + Objectives.MARKER_RADIUS, Callable(), safe_exclusion_circles)
	check(not is_inf(float(safe_endpoint.get("distance", INF))) and float(safe_endpoint.get("route_distance", INF)) < 8.0 and objective_endpoint_allowed.call(Vector2(safe_endpoint.get("point", Vector2.ZERO))),
		"Purge and Sanctify finds the furthest safe endpoint when the maximum endpoint would engage another enemy")
	var safe_projection: Dictionary = state.duplicate(true)
	safe_projection.units[mover].position = safe_endpoint.get("point", state.units[mover].position)
	var safe_end_error := Surge._target_end_error(state, safe_projection, friendly_squad,
		{"target_type": "objective", "objective": 0, "distance": 8.0})
	check(safe_end_error.is_empty(), "Purge and Sanctify accepts the best shorter endpoint outside another enemy's Engagement Range")
	var route_test_state: Dictionary = state.duplicate(true)
	state.units[mover].wounds = 1
	state.units[blocker].wounds = 1
	state.units[enemy].wounds = 0
	state.units[mover].radius = 0.5
	state.units[blocker].radius = 0.5
	state.units[mover].position = Vector2(1.1, 0)
	state.units[blocker].position = Vector2(-1.1, 0)
	state.terrain.areas = [{"name": "Formation wall", "category": "legacy", "bounds": Rect2(-0.5, -10, 1.0, 20), "features": [{"bounds": Rect2(-0.5, -10, 1.0, 20), "height": 3.0, "blocks_end": true}]}]
	state.mission.objectives = [{"name": "Purge objective", "kind": "marker", "position": Vector2(8, 0), "controller": 0, "secured": 0}]
	var coherent_objective_projection: Dictionary = state.duplicate(true)
	coherent_objective_projection.units[mover].position = Vector2(2.0, 0)
	coherent_objective_projection.units[blocker].position = Vector2(-1.0, 0)
	var coherent_objective_error := Surge._target_end_error(state, coherent_objective_projection, friendly_squad,
		{"target_type": "objective", "objective": 0, "distance": 4.0})
	check(C.Contact.coherent(coherent_objective_projection, friendly_squad) and coherent_objective_error.is_empty(),
		"Purge and Sanctify accepts the closest objective endpoint supported by the full coherent formation")
	state.units[mover].position = Vector2(2.0, 0)
	state.units[blocker].position = Vector2(-1.0, 0)
	state.unit_abilities.window = {"kind": Surge.PLACEMENT, "owners": [1], "queue": [friendly_squad], "queue_index": 0,
		"squad": friendly_squad, "distance": 4.0, "target_type": "objective", "objective": 0,
		"origins": {mover: Vector2(2.0, 0), blocker: Vector2(-1.0, 0)},
		"positions": {mover: Vector2(2.0, 0), blocker: Vector2(-1.0, 0)}}
	var stationary_objective_error := Surge.position_error_for_model(state, mover, Vector2(2.0, 0))
	check(stationary_objective_error.is_empty(),
		"Purge and Sanctify preview permits a model already at the closest endpoint allowed by coherency: " + stationary_objective_error)
	var stationary_objective_end_error := Surge._target_end_error(state, state.duplicate(true), friendly_squad,
		{"target_type": "objective", "objective": 0, "distance": 4.0, "origins": state.unit_abilities.window.origins})
	check(stationary_objective_end_error.is_empty(), "Purge and Sanctify confirms a stationary model when the full formation cannot get it closer: " + stationary_objective_end_error)
	var less_close_projection: Dictionary = state.duplicate(true)
	less_close_projection.units[mover].position = Vector2(1.9, 0)
	less_close_projection.units[blocker].position = Vector2(-1.0, 0)
	var less_close_error := Surge._target_end_error(state, less_close_projection, friendly_squad,
		{"target_type": "objective", "objective": 0, "distance": 4.0})
	check(C.Contact.coherent(less_close_projection, friendly_squad) and not less_close_error.is_empty(),
		"Purge and Sanctify rejects an endpoint when coherency permits the focus model to get closer")
	state.mission.objectives[0] = {"name": "Purge ruin", "kind": "terrain", "bounds": Rect2(7, -1, 2, 2), "controller": 0, "secured": 0}
	var terrain_objective_error := Surge._target_end_error(state, coherent_objective_projection, friendly_squad,
		{"target_type": "objective", "objective": 0, "distance": 4.0})
	check(terrain_objective_error.is_empty(), "Purge and Sanctify checks the closest coherent endpoint against a terrain objective region")
	state.terrain.areas = []
	state.units[mover].position = Vector2.ZERO
	state.units[blocker].position = Vector2(-1, 0)
	state.mission.objectives[0] = {"name": "Purge objective", "kind": "marker", "position": Vector2(10, 0), "controller": 0, "secured": 0}
	var range_projection: Dictionary = state.duplicate(true)
	range_projection.units[mover].position = Vector2(4, 0)
	range_projection.units[blocker].position = Vector2(3.5, 0)
	var range_error := Surge._target_end_error(state, range_projection, friendly_squad,
		{"target_type": "objective", "objective": 0, "distance": 8.0})
	check(not Objectives.in_range(range_projection.units[mover], state.mission.objectives[0]) and not range_error.is_empty(),
		"Purge and Sanctify requires objective range when the full formation can reach it")
	var high_objective := {"name": "Upper Purge objective", "kind": "marker", "position": Vector2.ZERO,
		"elevation": 20.0, "controller": 0, "secured": 0}
	var high_range_goals := Surge._objective_goal_regions(state.units[mover], high_objective, true)
	var high_closest_goals := Surge._objective_goal_regions(state.units[mover], high_objective, false, 1.0)
	check(high_range_goals.size() == 1 and is_equal_approx(float(high_range_goals[0].get("target_elevation", -1.0)), 20.0)
		and high_closest_goals.size() == 1 and not high_closest_goals[0].has("target_elevation"),
		"Marker objective height constrains the range goal but not the horizontal closest-distance goal")
	state.units[mover].position = Vector2.ZERO
	state.units[blocker].position = Vector2(-1, 0)
	state.units[mover].elevation = 0.0
	state.units[blocker].elevation = 0.0
	var high_objective_formation := HeresyRetribution.surge_coherency_state(state, friendly_squad, 10.0,
		{mover: Vector2.ZERO, blocker: Vector2(-1, 0)})
	check(Surge._objective_impossible_in_formation(high_objective_formation, mover, high_objective, true),
		"A 10-inch coherent Surge was not proved unable to enter range of a marker 20 inches above both starting models")
	state.unit_abilities.window = {"kind": Surge.PLACEMENT, "owners": [1], "queue": [friendly_squad], "queue_index": 0,
		"squad": friendly_squad, "distance": 8.0, "target_type": "objective", "objective": 0,
		"origins": {mover: Vector2.ZERO, blocker: Vector2(-1, 0)},
		"positions": {mover: Vector2.ZERO, blocker: Vector2(-1, 0)}}
	check(Surge.position_error_for_model(state, mover, Vector2(4, 0)).is_empty(),
		"Purge and Sanctify preview defers objective-range validation until the full formation is confirmed")
	state = route_test_state
	var narrow_gap_circles: Array[Dictionary] = [
		{"center": Vector2(-1.15, sqrt(1.0 - 0.05 * 0.05)), "radius": 1.0},
		{"center": Vector2(1.5, sqrt(2.75)), "radius": 3.0},
	]
	var narrow_gap_filter := func(candidate: Vector2) -> bool:
		for circle: Dictionary in narrow_gap_circles:
			if candidate.distance_to(Vector2(circle.center)) <= float(circle.radius) + 0.001: return false
		return true
	var narrow_gap_route := MovementPathfinder.new(state, mover, 8.0, "surge")
	var sampled_gap := narrow_gap_route.closest_reachable_to_region(
		Rect2(Vector2(20, 0), Vector2.ZERO), 0.0, narrow_gap_filter)
	var exact_gap := MovementPathfinder.new(state, mover, 8.0, "surge").closest_reachable_to_region(
		Rect2(Vector2(20, 0), Vector2.ZERO), 0.0, Callable(), narrow_gap_circles)
	check(float(exact_gap.route_distance) > float(sampled_gap.route_distance) + 0.1
		and narrow_gap_filter.call(Vector2(exact_gap.point)),
		"Exact exclusion-circle intervals find a narrow legal endpoint gap that bounded predicate samples miss")

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var source_profile := Profiles.profile("crusader-squad")
	check(not source_profile.is_empty() and str(source_profile.get("source_datasheet_id", "")) == "000002799" and source_profile.get("points_by_models", {}).get(10, -1) == 160 and source_profile.get("points_by_models", {}).get(20, -1) == 305, "Crusader Squad identity, model counts and points use the verified 11e local export")
	var same_chapter_army := army("Space Marines", "castellan", 1)
	same_chapter_army.entries.append({"definition_id": "40kdc:11e:adeptus-astartes:intercessor-squad", "models": 5, "copies": 1})
	var same_chapter_state := Prepared.initial_state({"manual_allocation": false, "core_stratagems": true, "unit_abilities": true, "combat_doctrines": true, "marine_detachments": {1: FIST, 2: "none"}, "marine_chapters": {1: "BLACK TEMPLARS"}}, {1: same_chapter_army, 2: army("Necrons", "necron-warriors", 10)})
	check(not same_chapter_state.has("error"), "Fist of the God-Emperor admits shared Codex Astartes profiles under Black Templars Chapter context")
	var mixed_chapter_army := army("Space Marines", "castellan", 1)
	mixed_chapter_army.entries.append({"definition_id": "40kdc:11e:adeptus-astartes:azrael", "models": 1, "copies": 1})
	var mixed_chapter_state := Prepared.initial_state({"manual_allocation": false, "core_stratagems": true, "unit_abilities": true, "combat_doctrines": true, "marine_detachments": {1: FIST, 2: "none"}, "marine_chapters": {1: "BLACK TEMPLARS"}}, {1: mixed_chapter_army, 2: army("Necrons", "necron-warriors", 10)})
	check(str(mixed_chapter_state.get("error", "")).contains("Chapter"), "Fist of the God-Emperor rejects a current-reference roster that mixes Black Templars and Dark Angels")
	var neophyte := Profiles.crusader_squad_model_loadout(1, 10)
	var initiate := Profiles.crusader_squad_model_loadout(5, 10)
	check(neophyte.get("role", "") == "Neophyte" and neophyte.stats.toughness == 4 and initiate.get("role", "") == "Initiate" and initiate.stats.toughness == 5 and not Profiles.crusader_squad_model_loadout(19, 20).is_empty(), "Crusader Squad assigns export-defined Sword Brother, Neophyte and Initiate profiles for valid compositions")
	check(not Enhancements.valid_for("40kdc:11e:adeptus-astartes:crusader-squad", Enhancements.OATHBOUND_EXEMPLAR, FIST), "Oathbound Exemplar remains unavailable to Crusader Squad because it is not linked in the verified export")
	var oathbound_state := fresh_fist(Enhancements.OATHBOUND_EXEMPLAR, "castellan", 1)
	check(not oathbound_state.has("error"), "Prepared Fist match admits the export-linked Castellan with Oathbound Exemplar: %s" % str(oathbound_state.get("error", "")))
	if not oathbound_state.has("error"):
		var oathbound_squad := squad_for(oathbound_state, 1, "castellan")
		prepare_battle(oathbound_state, "shooting", 1)
		oathbound_state.squads[oathbound_squad].advanced = true
		check(Enhancements.oathbound_exemplar_active(oathbound_state, oathbound_squad) and C.Actions.eligibility_error(oathbound_state, oathbound_squad).is_empty(), "Oathbound Exemplar lets an Advanced Castellan unit start an otherwise eligible action")
		oathbound_state.squads[oathbound_squad].advanced = false
		oathbound_state.squads[oathbound_squad].fell_back = true
		check(C.Actions.eligibility_error(oathbound_state, oathbound_squad).is_empty(), "Oathbound Exemplar lets a Castellan unit that Fell Back start an otherwise eligible action")
		oathbound_state.squads[oathbound_squad].fell_back = false
		oathbound_state.squads[oathbound_squad].advanced = true
		oathbound_state.squads[oathbound_squad].battle_shocked = true
		check(not C.Actions.eligibility_error(oathbound_state, oathbound_squad).is_empty(), "Oathbound Exemplar does not bypass the Battle-shock action gate")
	var unenhanced_state := fresh_fist("", "castellan", 1)
	if not unenhanced_state.has("error"):
		var unenhanced_squad := squad_for(unenhanced_state, 1, "castellan")
		prepare_battle(unenhanced_state, "shooting", 1)
		unenhanced_state.squads[unenhanced_squad].advanced = true
		check(not C.Actions.eligibility_error(unenhanced_state, unenhanced_squad).is_empty(), "An Advanced Crusader Squad without Oathbound Exemplar remains ineligible to start an action")
	var righteous_army := army("Space Marines", "crusader-squad", 10, Enhancements.RIGHTEOUS_FERVOUR)
	var enhancement_admission := ArmyCapabilities.admit(righteous_army)
	check(str(enhancement_admission.get("error", "")).is_empty() and int(enhancement_admission.get("total", 0)) == 175 and Enhancements.valid_for("40kdc:11e:adeptus-astartes:crusader-squad", Enhancements.RIGHTEOUS_FERVOUR, FIST), "Righteous Fervour follows its source-linked Crusader Squad eligibility and adds 15 points")
	var missing_abilities := Prepared.initial_state({"combat_doctrines": true, "marine_detachment": FIST}, {1: righteous_army, 2: army("Necrons", "necron-warriors", 10)})
	check(missing_abilities.has("error"), "Prepared Fist matches require current unit abilities")
	var state := fresh_fist(Enhancements.RIGHTEOUS_FERVOUR)
	check(not state.has("error"), "Prepared Fist match admits a current-reference Crusader Squad with its linked enhancement: %s" % str(state.get("error", "")))
	if state.has("error"):
		print("Fist of the God-Emperor checks: %d failures" % (failures + 1))
		quit(1)
		return
	var crusaders := squad_for(state, 1, "crusader-squad")
	var enemy := squad_for(state, 2)
	check(crusaders > 0 and C.UnitAbilities.has(state, crusaders, "righteous-zeal") and Enhancements.righteous_fervour_active(state, crusaders), "Prepared Crusader Squad carries Righteous Zeal and the active Righteous Fervour effect")

	prepare_battle(state, "movement", 1)
	state.squads[crusaders].moved = false
	var first_model := C.living(state, crusaders)[0]
	var advance_error := C.begin_movement(state, 1, first_model, "advance", int(state.revision), func() -> int: return 2)
	var advance_window := C.Stratagems.pending(state)
	check(advance_error.is_empty() and advance_window.get("righteous_fervour", false), "An eligible Advance opens the Righteous Fervour post-roll option")
	var cp_before: int = state.cp[1]
	var reroll_error := C.resolve_roll_reaction(state, 1, crusaders, "righteous-fervour", int(state.revision), func() -> int: return 5)
	check(reroll_error.is_empty() and int(state.pending_move.get("bonus", 0)) == 5 and int(state.cp[1]) == cp_before, "Righteous Fervour replaces the Advance D6 once for no CP")

	state = fresh_fist("")
	if not state.has("error"):
		crusaders = squad_for(state, 1, "crusader-squad")
		enemy = squad_for(state, 2)
		prepare_battle(state, "command", 1)
		var unused_doctrine := ""
		for doctrine: String in C.Doctrines.available(state, 1): unused_doctrine = doctrine; break
		var doctrine_choices := D.choices(state, 1)
		var doctrine_choice: Dictionary = {}
		for candidate: Dictionary in doctrine_choices:
			if str(candidate.get("value", "")) == D.FIST_DOCTRINAL_FLEXIBILITY and str(candidate.get("details", {}).get("doctrine", "")) == unused_doctrine: doctrine_choice = candidate; break
		var doctrine_result := D.apply(state, 1, doctrine_choice) if not doctrine_choice.is_empty() else {"error": "Doctrinal Flexibility choice unavailable."}
		check(str(doctrine_result.get("error", "")).is_empty() and str(C.UnitAbilities.doctrine(state, crusaders)) == unused_doctrine and unused_doctrine not in C.Doctrines.available(state, 1), "Doctrinal Flexibility assigns one unused doctrine to the Crusader Squad and consumes that army use")

		prepare_battle(state, "shooting", 2)
		dead_by_enemy_shot(state)
		check(C.UnitActions.actor(state) == 1 and C.UnitActions.pending(state).get("kind", "") == Surge.WINDOW, "Destroying a model in enemy Shooting opens Righteous Zeal for the defending Crusader Squad")
		var use_result := submit(state, 1, "crusader-surge-use", crusaders, "", -1, Vector2.ZERO, func() -> int: return 4)
		check(str(use_result.get("error", "")).is_empty() and C.UnitActions.pending(state).get("kind", "") == Surge.TARGET_WINDOW and int(C.UnitActions.pending(state).distance) == 5, "Righteous Zeal rolls D6+1 and transfers control to closest-target selection")
		var enemy_choice: Dictionary = {}
		for candidate: Dictionary in C.UnitActions.choices(state, 1):
			if str(candidate.get("action", "")) == "crusader-surge-enemy" and int(candidate.get("enemy_target", -1)) == enemy: enemy_choice = candidate; break
		var enemy_result := PublicUnitCommand.submit(state, 1, enemy_choice, Vector2.ZERO) if not enemy_choice.is_empty() else {"error": "No closest enemy Surge target was offered."}
		check(str(enemy_result.get("error", "")).is_empty() and C.UnitActions.pending(state).get("kind", "") == Surge.PLACEMENT, "The owner can select the closest enemy and enter Surge placement")
		if C.UnitActions.pending(state).get("kind", "") == Surge.PLACEMENT:
			var placed_model := int(C.UnitActions.pending(state).positions.keys()[0])
			var too_far := Surge.position_error_for_model(state, placed_model, Vector2(C.UnitActions.pending(state).origins[placed_model]) + Vector2(6, 0))
			check(not too_far.is_empty(), "Righteous Zeal rejects destinations beyond the D6+1 roll")
			var confirm_choices := C.UnitActions.choices(state, 1)
			check(confirm_choices.any(func(row: Dictionary) -> bool: return str(row.get("action", "")) == "crusader-surge-confirm"), "Surge placement exposes an explicit confirmation step")

	state = fresh_fist("")
	if not state.has("error"):
		crusaders = squad_for(state, 1, "crusader-squad")
		prepare_battle(state, "shooting", 2)
		dead_by_enemy_shot(state)
		state.mission.objectives = [{"name": "Purge objective", "kind": "marker", "position": Vector2(-12, 0), "controller": 0, "secured": 0}]
		var use_objective := submit(state, 1, "crusader-surge-use", crusaders, "", -1, Vector2.ZERO, func() -> int: return 3)
		var objective_rows := C.UnitActions.choices(state, 1)
		check(str(use_objective.get("error", "")).is_empty() and objective_rows.any(func(row: Dictionary) -> bool: return str(row.get("action", "")) == "crusader-surge-objective" and str(row.get("label", "")).begins_with("Purge and Sanctify")), "Purge and Sanctify offers the closest objective as a Surge destination")
		var objective_result := submit(state, 1, "crusader-surge-objective", crusaders, "0")
		check(str(objective_result.get("error", "")).is_empty() and str(C.UnitActions.pending(state).get("target_type", "")) == "objective", "The objective choice opens the Purge and Sanctify placement path")

	state = fresh_fist("")
	if not state.has("error"):
		crusaders = squad_for(state, 1, "crusader-squad")
		enemy = squad_for(state, 2)
		prepare_battle(state, "shooting", 2)
		state.unit_abilities.window = {"kind": D.SHOOTING_REACTION_WINDOW, "owners": [1], "squad": crusaders, "declaration": {"kind": "attack", "player": 2, "squad": enemy, "melee": false, "entries": [{"target": crusaders}]}, "can_angels_defiant": true}
		var angels_choice := choice_for(state, 1, "angels-defiant-use", crusaders, D.FIST_ANGELS_DEFIANT)
		var angels_result := C.UnitActions.apply(state, 1, angels_choice, Vector2.ZERO, Callable()) if not angels_choice.is_empty() else {"error": "Angels Defiant was not offered."}
		check(str(angels_result.get("error", "")).is_empty() and D.angels_defiant_wound_modifier(state, enemy, crusaders, 6, 5) == -1 and D.angels_defiant_wound_modifier(state, enemy, crusaders, 5, 5) == 0, "Angels Defiant binds -1 to Wound to the declared stronger enemy attack only")
		D.clear_angels_defiant(state, enemy)
		check(D.angels_defiant_wound_modifier(state, enemy, crusaders, 6, 5) == 0, "Angels Defiant expires after the saved attack sequence")

	state = fresh_fist("")
	if not state.has("error"):
		crusaders = squad_for(state, 1, "crusader-squad")
		prepare_battle(state, "fight", 1)
		state.fight_actor = 1
		state.fight_step = "attacks"
		state.fight_selected = -1
		state.squads[crusaders].charged = true
		var avowed := D.choices(state, 1).filter(func(row: Dictionary) -> bool: return str(row.get("value", "")) == D.FIST_AVOWED_DESTRUCTION and str(row.get("mode", "")) == "lethal")
		var avowed_result := D.apply(state, 1, avowed[0]) if not avowed.is_empty() else {"error": "Avowed Destruction choice unavailable."}
		var base_profile: Dictionary = state.units[C.living(state, crusaders)[0]].melee_weapons[0].profiles.standard.duplicate(true)
		var buffed_profile := D.weapon(state, crusaders, base_profile, base_profile, true)
		check(str(avowed_result.get("error", "")).is_empty() and buffed_profile.keywords.get("lethal-hits", false), "Avowed Destruction grants the selected melee keyword for the Fight phase")

	test_surge_routes()
	test_elevated_visibility_routes()
	test_surge_cross_surface_placement()
	test_surge_cross_surface_access_gap()
	test_surge_multiple_surface_transitions()
	test_surge_multilevel_solo_objective_closest()
	test_surge_three_surface_transitions()
	test_surge_ground_intermediate_surface_route()
	test_surge_same_floor_ground_detour()
	test_surge_same_height_surface_transition()
	test_duplicate_surface_ids_do_not_connect_platforms()

	print("Fist of the God-Emperor checks: %d failures" % failures)
	quit(0 if failures == 0 else 1)

func test_elevated_visibility_routes() -> void:
	var state := fresh_fist()
	if state.has("error"):
		check(false, "Elevated route checks initialize a current-reference battle")
		return
	prepare_battle(state, "shooting", 2)
	var friendly_squad := squad_for(state, 1, "crusader-squad")
	var enemy_squad := squad_for(state, 2)
	var mover := C.living(state, friendly_squad)[0]
	var enemies := C.living(state, enemy_squad)
	if enemies.size() < 2:
		check(false, "Elevated route fixture contains two enemy bases")
		return
	var blocker: int = enemies[0]
	var second_blocker: int = enemies[1]
	for model_id: int in state.units: state.units[model_id].wounds = 0
	state.units[mover].wounds = 1
	state.units[blocker].wounds = 1
	state.units[second_blocker].wounds = 1
	state.units[mover].radius = 0.5
	state.units[blocker].radius = 0.5
	state.units[second_blocker].radius = 0.5
	state.units[mover].position = Vector2(-2.5, 0.0)
	state.units[mover].elevation = 3.0
	state.units[blocker].position = Vector2(0.0, 0.0)
	state.units[blocker].elevation = 3.0
	state.units[second_blocker].position = Vector2(0.0, 3.0)
	state.units[second_blocker].elevation = 3.0
	var wall := Rect2(-0.2, -0.5, 0.4, 1.0)
	var elevated_floor := {"id": "elevated-route-test", "name": "Elevated route test", "bounds": Rect2(-8.0, -5.0, 16.0, 10.0),
		"elevation": 3.0, "access_features": [0], "requires_keywords": ["infantry"]}
	state.terrain.areas = [{"name": "Elevated route terrain", "category": "legacy", "bounds": Rect2(-8.0, -5.0, 16.0, 10.0),
		"features": [{"bounds": wall, "height": 4.0, "blocks_end": true}], "surfaces": [elevated_floor]}]
	var elevated_pathfinder := MovementPathfinder.new(state, mover, 7.0, "surge")
	var elevated_route := elevated_pathfinder.distance_to(Vector2(2.5, 0.0))
	check(not is_inf(elevated_route) and elevated_route > 5.0 and elevated_route <= 7.0,
		"Same-floor visibility routing finds a validated wall/base detour within the configured 7-inch movement allowance (got %.5f)" % elevated_route)
	var graph_nodes_fit_floor := not elevated_pathfinder._visibility_graph_nodes.is_empty()
	for route_node: Vector2 in elevated_pathfinder._visibility_graph_nodes:
		if not Terrain.surface_contains(state.units[mover], elevated_floor, route_node): graph_nodes_fit_floor = false
	check(graph_nodes_fit_floor, "Every elevated visibility node keeps the whole base on the mover's source floor")
	var disconnected_floor := elevated_floor.duplicate(true)
	disconnected_floor.id = "other-elevated-route-test"
	disconnected_floor.bounds = Rect2(9.0, -5.0, 8.0, 10.0)
	state.terrain.areas[0].surfaces.append(disconnected_floor)
	var disconnected_route := MovementPathfinder.new(state, mover, 20.0, "surge").distance_to(Vector2(12.0, 0.0))
	check(is_inf(disconnected_route), "Same-height routing does not connect a disconnected surface through a visibility-graph edge")

	state.units[second_blocker].position = Vector2(0.5, 0.0)
	state.terrain.areas[0].surfaces = [{"id": "narrow-elevated-route-test", "name": "Narrow elevated route test",
		"bounds": Rect2(-5.0, -0.6, 10.0, 1.2), "elevation": 3.0, "access_features": [], "requires_keywords": ["infantry"]}]
	var blocked_narrow_route := MovementPathfinder.new(state, mover, 20.0, "surge").distance_to(Vector2(4.0, 0.0))
	check(is_inf(blocked_narrow_route), "Elevated routing rejects a detour whose base would leave a narrow floor with no listed vertical access")
	check(not MovementPathfinder.new(state, mover, 20.0, "surge")._circle_arc_fits_current_surface(
		Vector2.ZERO, 1.01, 0.0, PI, false), "An elevated arc that exits the base-fit surface bounds is rejected")

func test_surge_cross_surface_placement() -> void:
	var state := fresh_fist()
	if state.has("error"):
		check(false, "Cross-surface Surge placement initializes a current-reference battle")
		return
	prepare_battle(state, "shooting", 2)
	var crusaders := squad_for(state, 1, "crusader-squad")
	var enemy_squad := squad_for(state, 2)
	var crusader_models := C.living(state, crusaders)
	var enemy_models := C.living(state, enemy_squad)
	if crusader_models.size() < 2 or enemy_models.is_empty():
		check(false, "Cross-surface Surge fixture has a surviving mover and a target")
		return
	for model: int in state.units: state.units[model].wounds = 0
	var casualty: int = crusader_models[0]
	var mover: int = crusader_models[1]
	var enemy: int = enemy_models[0]
	state.units[mover].wounds = 1
	state.units[enemy].wounds = 1
	state.units[mover].position = Vector2(-2.0, 0.0)
	state.units[mover].elevation = 0.0
	state.units[enemy].position = Vector2(4.7, 0.0)
	state.units[enemy].elevation = 0.0
	var access_wall := Rect2(-0.2, -0.5, 0.4, 1.0)
	var upper_floor := {"id": "surge-access-floor", "name": "Surge access floor", "bounds": Rect2(-5.0, -5.0, 15.0, 10.0),
		"elevation": 3.0, "access_features": [0], "requires_keywords": ["infantry"]}
	state.terrain.areas = [{"name": "Surge access ruin", "category": "legacy", "bounds": Rect2(-5.0, -5.0, 15.0, 10.0),
		"features": [{"bounds": access_wall, "height": 4.0, "blocks_end": true}], "surfaces": [upper_floor]}]
	Surge.open_after_enemy_shot(state, enemy_squad, [{"target_squad": crusaders, "models_destroyed": 1,
		"allocations": [{"model": casualty, "wounds_before": 1, "wounds_after": 0}]}])
	var use_result := submit(state, 1, "crusader-surge-use", crusaders, "", -1, Vector2.ZERO, func() -> int: return 6)
	var enemy_choice: Dictionary = {}
	for option: Dictionary in C.UnitActions.choices(state, 1):
		if str(option.get("action", "")) == "crusader-surge-enemy" and int(option.get("enemy_target", -1)) == enemy_squad: enemy_choice = option; break
	var target_result := PublicUnitCommand.submit(state, 1, enemy_choice) if not enemy_choice.is_empty() else {"error": "No closest enemy target was offered."}
	var placement_window: Dictionary = C.UnitActions.pending(state)
	var rolled_distance := float(placement_window.get("distance", 0.0))
	placement_window.distance = 6.0
	var vertical_overrun := Surge.position_error_for_model(state, mover, Vector2(1.8, 0.0), 3.0)
	placement_window.distance = rolled_distance
	var place_result := submit(state, 1, "crusader-surge-place", crusaders, "", mover, Vector2(1.8, 0.0), Callable(), 3.0)
	check(not vertical_overrun.is_empty(), "Cross-floor Surge distance includes the 3-inch elevation change")
	check(str(use_result.get("error", "")).is_empty() and str(target_result.get("error", "")).is_empty() and str(place_result.get("error", "")).is_empty(),
		"The public Surge command accepts a measured move through a listed ruin access path onto an eligible upper surface (use: %s; target: %s; placement: %s)" % [str(use_result.get("error", "")), str(target_result.get("error", "")), str(place_result.get("error", ""))])
	if str(place_result.get("error", "")).is_empty():
		check(is_equal_approx(float(C.UnitActions.pending(state).get("elevations", {}).get(mover, -1.0)), 3.0) and is_equal_approx(float(state.units[mover].get("elevation", -1.0)), 0.0),
			"An upper-floor destination stays a preview and records its elevation without moving the live model")
		var confirm_result := submit(state, 1, "crusader-surge-confirm", crusaders)
		check(str(confirm_result.get("error", "")).is_empty() and is_equal_approx(float(state.units[mover].get("elevation", -1.0)), 3.0) and state.units[mover].position == Vector2(1.8, 0.0),
			"Confirming Surge commits both the selected endpoint and its surface elevation")

func test_surge_cross_surface_access_gap() -> void:
	var state := fresh_fist()
	if state.has("error"):
		check(false, "Cross-surface access-gap routing initializes a current-reference battle")
		return
	prepare_battle(state, "shooting", 2)
	var crusaders := squad_for(state, 1, "crusader-squad")
	var enemy_squad := squad_for(state, 2)
	var movers := C.living(state, crusaders)
	var enemies := C.living(state, enemy_squad)
	if movers.size() < 1 or enemies.size() < 3:
		check(false, "Cross-surface access-gap fixture has one mover and three blocking bases")
		return
	for model: int in state.units: state.units[model].wounds = 0
	var mover: int = movers[0]
	state.units[mover].wounds = 1
	state.units[mover].radius = 0.25
	state.units[mover].position = Vector2(-3.0, 0.0)
	state.units[mover].elevation = 0.0
	var blockers: Array[Vector2] = [Vector2(2.0, 0.0), Vector2(1.5, 1.3), Vector2(1.5, -1.3)]
	for index in range(blockers.size()):
		var blocker: int = enemies[index]
		state.units[blocker].wounds = 1
		state.units[blocker].radius = 0.25
		state.units[blocker].position = blockers[index]
		state.units[blocker].elevation = 0.0
	var access_wall := Rect2(-0.2, -0.5, 0.4, 1.0)
	var upper_floor := {"id": "surge-narrow-access-floor", "name": "Surge narrow access floor", "bounds": Rect2(-5.0, -5.0, 15.0, 10.0),
		"elevation": 3.0, "access_features": [0], "requires_keywords": ["infantry"]}
	var remote_access_wall := Rect2(-4.5, 2.5, 0.4, 0.4)
	var remote_floor := {"id": "surge-disconnected-same-height-floor", "name": "Surge disconnected floor", "bounds": Rect2(-5.0, 2.0, 4.0, 3.0),
		"elevation": 3.0, "access_features": [1], "requires_keywords": ["infantry"]}
	state.terrain.areas = [{"name": "Surge narrow access ruin", "category": "legacy", "bounds": Rect2(-5.0, -5.0, 15.0, 10.0),
		"features": [{"bounds": access_wall, "height": 4.0, "blocks_end": true},
			{"bounds": remote_access_wall, "height": 4.0, "blocks_end": true}], "surfaces": [upper_floor, remote_floor]}]
	var projection_state: Dictionary = state.duplicate(true)
	projection_state.units[mover].position = Vector2(-3.0, 0.371)
	for blocker_index in range(enemies.size()): projection_state.units[enemies[blocker_index]].wounds = 0
	projection_state.units[enemies[0]].wounds = 1
	projection_state.units[enemies[0]].position = Vector2(2.0, 0.0)
	var projection_surface: Dictionary = Terrain.surfaces(projection_state)[0]
	var projection_pathfinder := MovementPathfinder.new(projection_state, mover, 12.0, "surge")
	var projection_points := projection_pathfinder._vertical_surface_access_points(projection_surface, Vector2(4.0, 0.0), 3.0)
	var access_zone: Rect2 = Rect2(upper_floor.bounds.position + Vector2.ONE * 0.25, upper_floor.bounds.size - Vector2.ONE * 0.5) \
		.intersection(access_wall.grow(0.25 + 0.5 + Terrain.EPSILON))
	var boundary_state: Dictionary = projection_state.duplicate(true)
	boundary_state.units[enemies[0]].position = Vector2(1.0, 0.0)
	var boundary_pathfinder := MovementPathfinder.new(boundary_state, mover, 12.0, "surge")
	var boundary_blockers := boundary_pathfinder._model_blocking_circles(boundary_state.units[mover].position)
	var exact_blocker_portal_contacts := MovementPathfinder._circle_rect_intersections(
		Vector2(boundary_blockers[0].center), float(boundary_blockers[0].radius), access_zone)
	var portal_contact_in_surface_query := false
	var boundary_surface_points := boundary_pathfinder._vertical_surface_access_points(
		projection_surface, Vector2(4.0, 0.0), 3.0)
	for expected_contact: Vector2 in exact_blocker_portal_contacts:
		for candidate: Vector2 in boundary_surface_points:
			if candidate.distance_to(expected_contact) <= Terrain.EPSILON:
				portal_contact_in_surface_query = true
				break
		if portal_contact_in_surface_query: break
	var direct_boundary_pathfinder := MovementPathfinder.new(boundary_state, mover, 12.0, "surge")
	direct_boundary_pathfinder._build_waypoint_nodes()
	direct_boundary_pathfinder._add_vertical_access_nodes(
		boundary_state.units[mover].position, 0, 3.0, Rect2(Vector2(4.0, 0.0), Vector2.ZERO))
	var portal_contact_in_direct_graph := false
	for expected_contact: Vector2 in exact_blocker_portal_contacts:
		for candidate: Vector2 in direct_boundary_pathfinder._nodes:
			if candidate.distance_to(expected_contact) <= Terrain.EPSILON:
				portal_contact_in_direct_graph = true
				break
		if portal_contact_in_direct_graph: break
	check(not exact_blocker_portal_contacts.is_empty() and portal_contact_in_surface_query and portal_contact_in_direct_graph,
		"Direct and composed access queries include exact blocker-circle intersections on the portal boundary")
	var exact_projection := Vector2(clampf(projection_state.units[mover].position.x, access_zone.position.x, access_zone.end.x),
		clampf(projection_state.units[mover].position.y, access_zone.position.y, access_zone.end.y))
	var projection_found := false
	for point: Vector2 in projection_points:
		if point.distance_to(exact_projection) <= Terrain.EPSILON:
			projection_found = true
			break
	check(projection_found, "Cross-surface candidates include the exact nearest access point projected from the mover")
	var direct_segment_contacts := MovementPathfinder._segment_rect_intersection_points(
		projection_state.units[mover].position, Vector2(4.0, 0.0), access_zone)
	var segment_contact_in_surface_query := false
	for expected_contact: Vector2 in direct_segment_contacts:
		for candidate: Vector2 in projection_points:
			if candidate.distance_to(expected_contact) <= Terrain.EPSILON:
				segment_contact_in_surface_query = true
				break
		if segment_contact_in_surface_query: break
	var direct_segment_pathfinder := MovementPathfinder.new(projection_state, mover, 12.0, "surge")
	direct_segment_pathfinder._build_waypoint_nodes()
	direct_segment_pathfinder._add_vertical_access_nodes(
		projection_state.units[mover].position, 0, 3.0, Rect2(Vector2(4.0, 0.0), Vector2.ZERO))
	var segment_contact_in_direct_graph := false
	for expected_contact: Vector2 in direct_segment_contacts:
		for candidate: Vector2 in direct_segment_pathfinder._nodes:
			if candidate.distance_to(expected_contact) <= Terrain.EPSILON:
				segment_contact_in_direct_graph = true
				break
		if segment_contact_in_direct_graph: break
	check(not direct_segment_contacts.is_empty() and segment_contact_in_surface_query and segment_contact_in_direct_graph,
		"Direct and composed cross-surface queries include exact origin-to-goal segment contacts on the access portal")
	var route_projection_pathfinder := MovementPathfinder.new(projection_state, mover, 12.0, "surge")
	route_projection_pathfinder._build_waypoint_nodes()
	var route_projection_points := route_projection_pathfinder._vertical_surface_access_points(
		projection_surface, Vector2(4.0, 0.0), 3.0)
	var unsampled_route_projection_found := false
	for route_anchor: Vector2 in route_projection_pathfinder._nodes:
		var route_projection := MovementPathfinder._clamp_point_to_rect(route_anchor, access_zone)
		var present_in_sampled_points := false
		for sampled_point: Vector2 in projection_points:
			if sampled_point.distance_to(route_projection) <= Terrain.EPSILON:
				present_in_sampled_points = true
				break
		if present_in_sampled_points: continue
		for projected_point: Vector2 in route_projection_points:
			if projected_point.distance_to(route_projection) <= Terrain.EPSILON:
				unsampled_route_projection_found = true
				break
		if unsampled_route_projection_found: break
	check(unsampled_route_projection_found,
		"Cross-surface candidates project a source-surface route waypoint onto the access zone between fixed edge samples")
	var fixed_projection_anchors: Array[Vector2] = [access_zone.position, Vector2(access_zone.end.x, access_zone.position.y),
		access_zone.end, Vector2(access_zone.position.x, access_zone.end.y),
		MovementPathfinder._clamp_point_to_rect(projection_state.units[mover].position, access_zone),
		MovementPathfinder._clamp_point_to_rect(Vector2(4.0, 0.0), access_zone)]
	var projected_route_tangent_found := false
	var route_projection_blockers := route_projection_pathfinder._model_blocking_circles(projection_state.units[mover].position)
	for route_anchor: Vector2 in route_projection_pathfinder._nodes:
		var route_projection := MovementPathfinder._clamp_point_to_rect(route_anchor, access_zone)
		var is_fixed_projection := false
		for fixed_anchor: Vector2 in fixed_projection_anchors:
			if route_projection.distance_to(fixed_anchor) <= Terrain.EPSILON:
				is_fixed_projection = true
				break
		if is_fixed_projection: continue
		for blocker: Dictionary in route_projection_blockers:
			for tangent: Vector2 in MovementPathfinder._circle_tangent_points(
				route_projection, Vector2(blocker.center), float(blocker.radius)):
				for candidate: Vector2 in route_projection_points:
					if candidate.distance_to(tangent) <= Terrain.EPSILON:
						projected_route_tangent_found = true
						break
				if projected_route_tangent_found: break
		if projected_route_tangent_found: break
	check(projected_route_tangent_found,
		"Cross-surface access candidates add blocker tangents from projected source-route waypoints")
	var finite_goal := Rect2(Vector2(4.0, 3.0), Vector2(0.5, 0.5))
	var goal_projection_points := projection_pathfinder._vertical_surface_access_points(
		projection_surface, finite_goal.get_center(), 3.0, finite_goal, 0.1, false)
	var nearest_goal_point := Vector2(clampf(access_zone.get_center().x, finite_goal.position.x, finite_goal.end.x),
		clampf(access_zone.get_center().y, finite_goal.position.y, finite_goal.end.y))
	var exact_goal_projection := Vector2(clampf(nearest_goal_point.x, access_zone.position.x, access_zone.end.x),
		clampf(nearest_goal_point.y, access_zone.position.y, access_zone.end.y))
	var goal_projection_found := false
	for point: Vector2 in goal_projection_points:
		if point.distance_to(exact_goal_projection) <= Terrain.EPSILON:
			goal_projection_found = true
			break
	check(goal_projection_found, "Cross-surface candidates include the exact access point nearest to a finite objective region")
	var direct_projection_pathfinder := MovementPathfinder.new(projection_state, mover, 12.0, "surge")
	direct_projection_pathfinder._build_waypoint_nodes()
	direct_projection_pathfinder._add_vertical_access_nodes(
		projection_state.units[mover].position, 0, 3.0, Rect2(Vector2(4.0, 0.0), Vector2.ZERO))
	var direct_projection_found := false
	for point: Vector2 in direct_projection_pathfinder._nodes:
		if point.distance_to(exact_projection) <= Terrain.EPSILON:
			direct_projection_found = true
			break
	check(direct_projection_found,
		"Direct cross-surface route graphs include the exact mover projection in a narrow access zone")
	var direct_mover_tangent_found := false
	for blocker: Dictionary in direct_projection_pathfinder._model_blocking_circles(projection_state.units[mover].position):
		for tangent: Vector2 in MovementPathfinder._circle_tangent_points(
			exact_projection, Vector2(blocker.center), float(blocker.radius)):
			for point: Vector2 in direct_projection_pathfinder._nodes:
				if point.distance_to(tangent) <= Terrain.EPSILON:
					direct_mover_tangent_found = true
					break
			if direct_mover_tangent_found: break
		if direct_mover_tangent_found: break
	check(direct_mover_tangent_found,
		"Direct cross-surface graphs add exact blocker tangents from the mover access projection")
	var direct_corner_tangent_found := false
	var access_corners: Array[Vector2] = [access_zone.position, Vector2(access_zone.end.x, access_zone.position.y),
		access_zone.end, Vector2(access_zone.position.x, access_zone.end.y)]
	for corner: Vector2 in access_corners:
		for blocker: Dictionary in direct_projection_pathfinder._model_blocking_circles(projection_state.units[mover].position):
			for tangent: Vector2 in MovementPathfinder._circle_tangent_points(
				corner, Vector2(blocker.center), float(blocker.radius)):
				for point: Vector2 in direct_projection_pathfinder._nodes:
					if point.distance_to(tangent) <= Terrain.EPSILON:
						direct_corner_tangent_found = true
						break
				if direct_corner_tangent_found: break
			if direct_corner_tangent_found: break
		if direct_corner_tangent_found: break
	check(direct_corner_tangent_found,
		"Direct cross-surface graphs add exact blocker tangents from access-zone corners")
	var direct_projected_route_tangent_found := false
	for route_anchor: Vector2 in route_projection_pathfinder._nodes:
		var route_projection := MovementPathfinder._clamp_point_to_rect(route_anchor, access_zone)
		var is_fixed_projection := false
		for fixed_anchor: Vector2 in fixed_projection_anchors:
			if route_projection.distance_to(fixed_anchor) <= Terrain.EPSILON:
				is_fixed_projection = true
				break
		if is_fixed_projection: continue
		for blocker: Dictionary in route_projection_blockers:
			for tangent: Vector2 in MovementPathfinder._circle_tangent_points(
				route_projection, Vector2(blocker.center), float(blocker.radius)):
				for point: Vector2 in direct_projection_pathfinder._nodes:
					if point.distance_to(tangent) <= Terrain.EPSILON:
						direct_projected_route_tangent_found = true
						break
				if direct_projected_route_tangent_found: break
		if direct_projected_route_tangent_found: break
	check(direct_projected_route_tangent_found,
		"Direct cross-surface route graphs add blocker tangents from projected source-route waypoints")
	var budget_state: Dictionary = projection_state.duplicate(true)
	budget_state.terrain.areas[0].surfaces[0].elevation = 8.0
	var budget_pathfinder := MovementPathfinder.new(budget_state, mover, 12.0, "surge")
	budget_pathfinder._build_waypoint_nodes()
	var nodes_before_budgeted_access := budget_pathfinder._nodes.size()
	var added_over_budget_access := budget_pathfinder._add_vertical_access_nodes(
		budget_state.units[mover].position, 0, 8.0, Rect2(Vector2(4.0, 0.0), Vector2.ZERO))
	check(not added_over_budget_access and budget_pathfinder._nodes.size() == nodes_before_budgeted_access,
		"Cross-surface access candidates are pruned when the origin-to-access-to-goal lower bound exceeds movement")
	var exact_destination := Vector2(4.0, 0.371)
	var direct_destination_pathfinder := MovementPathfinder.new(projection_state, mover, 12.0, "surge")
	direct_destination_pathfinder._build_waypoint_nodes()
	direct_destination_pathfinder._add_vertical_access_nodes(
		projection_state.units[mover].position, 0, 3.0, Rect2(exact_destination, Vector2.ZERO))
	var exact_destination_projection := Vector2(clampf(exact_destination.x, access_zone.position.x, access_zone.end.x),
		clampf(exact_destination.y, access_zone.position.y, access_zone.end.y))
	var direct_destination_found := false
	for point: Vector2 in direct_destination_pathfinder._nodes:
		if point.distance_to(exact_destination_projection) <= Terrain.EPSILON:
			direct_destination_found = true
			break
	check(direct_destination_found,
		"Direct cross-surface route graphs include the exact access point nearest the requested destination")
	var finite_direct_goal := Rect2(Vector2(4.0, 0.3), Vector2(0.5, 0.2))
	var direct_goal_pathfinder := MovementPathfinder.new(projection_state, mover, 12.0, "surge")
	direct_goal_pathfinder._build_waypoint_nodes()
	direct_goal_pathfinder._add_vertical_access_nodes(
		projection_state.units[mover].position, 0, 3.0, finite_direct_goal)
	var nearest_direct_goal_point := Vector2(clampf(access_zone.get_center().x, finite_direct_goal.position.x, finite_direct_goal.end.x),
		clampf(access_zone.get_center().y, finite_direct_goal.position.y, finite_direct_goal.end.y))
	var finite_goal_projection := Vector2(clampf(nearest_direct_goal_point.x, access_zone.position.x, access_zone.end.x),
		clampf(nearest_direct_goal_point.y, access_zone.position.y, access_zone.end.y))
	var direct_goal_found := false
	for point: Vector2 in direct_goal_pathfinder._nodes:
		if point.distance_to(finite_goal_projection) <= Terrain.EPSILON:
			direct_goal_found = true
			break
	check(direct_goal_found,
		"Direct cross-surface route graphs include the exact access point nearest a finite goal region")
	var direct_goal_tangent_found := false
	for blocker: Dictionary in direct_goal_pathfinder._model_blocking_circles(projection_state.units[mover].position):
		for tangent: Vector2 in MovementPathfinder._circle_tangent_points(
			finite_goal_projection, Vector2(blocker.center), float(blocker.radius)):
			for point: Vector2 in direct_goal_pathfinder._nodes:
				if point.distance_to(tangent) <= Terrain.EPSILON:
					direct_goal_tangent_found = true
					break
			if direct_goal_tangent_found: break
		if direct_goal_tangent_found: break
	check(direct_goal_tangent_found,
		"Direct cross-surface graphs add exact blocker tangents from the finite-goal access projection")
	var all_surface_access := MovementPathfinder.new(state, mover, 12.0, "surge")
	all_surface_access._build_waypoint_nodes()
	all_surface_access._add_vertical_access_nodes(state.units[mover].position, 32)
	var remote_fit_bounds := Rect2(remote_floor.bounds.position + Vector2.ONE * 0.25,
		remote_floor.bounds.size - Vector2.ONE * 0.5)
	var remote_access_zone := remote_fit_bounds.intersection(remote_access_wall.grow(0.25 + 0.5 + Terrain.EPSILON))
	var remote_access_candidate := Vector2(remote_access_zone.end.x, remote_access_zone.get_center().y)
	var all_surface_contains_remote_access := false
	for point: Vector2 in all_surface_access._nodes:
		if point.distance_to(remote_access_candidate) <= Terrain.EPSILON:
			all_surface_contains_remote_access = true
			break
	var targeted_surface_access := MovementPathfinder.new(state, mover, 12.0, "surge")
	targeted_surface_access._build_waypoint_nodes()
	targeted_surface_access._add_vertical_access_nodes(state.units[mover].position, 32, 3.0, Rect2(Vector2(4.0, 0.0), Vector2.ZERO))
	var targeted_contains_remote_access := false
	for point: Vector2 in targeted_surface_access._nodes:
		if point.distance_to(remote_access_candidate) <= Terrain.EPSILON:
			targeted_contains_remote_access = true
			break
	check(all_surface_contains_remote_access and not targeted_contains_remote_access,
		"A target-scoped cross-surface graph omits the explicit access candidate on a disconnected floor outside the goal region")
	var projected_gap_pathfinder := MovementPathfinder.new(state, mover, 12.0, "surge")
	projected_gap_pathfinder._build_waypoint_nodes()
	var access_gap_projection_added := projected_gap_pathfinder._add_vertical_access_nodes(
		state.units[mover].position, 0, 3.0, Rect2(Vector2(4.0, 0.0), Vector2.ZERO))
	var projected_gap_route := projected_gap_pathfinder._distance_to_waypoint_graph(
		Vector2(4.0, 0.0), projected_gap_pathfinder._model_blocking_circles(state.units[mover].position), 3.0)
	check(access_gap_projection_added and not is_inf(projected_gap_route) and projected_gap_route <= 12.0,
		"Route-waypoint access projections resolve the narrow cross-surface gap before edge subdivision")
	var pathfinder := MovementPathfinder.new(state, mover, 12.0, "surge")
	var route := pathfinder.distance_to(Vector2(4.0, 0.0), 3.0)
	check(not is_inf(route) and route > 10.0 and route <= 12.0,
		"Cross-surface routing finds a valid narrow vertical-access gap around three blocking bases (got %.5f)" % route)
	var closest_pathfinder := MovementPathfinder.new(state, mover, 12.0, "surge")
	var closest := closest_pathfinder.closest_reachable_to_region(Rect2(Vector2(4.0, 0.0), Vector2.ZERO), 0.0, Callable(), [], 3.0)
	check(is_zero_approx(float(closest.get("distance", INF))) and float(closest.get("route_distance", INF)) <= 12.0,
		"A fresh cross-surface closest-endpoint query recovers the narrow access gap")
	var coarse_pathfinder := MovementPathfinder.new(state, mover, 12.0, "surge")
	coarse_pathfinder._build_waypoint_nodes()
	coarse_pathfinder._add_vertical_access_nodes(state.units[mover].position)
	var beyond_budget_region := Rect2(Vector2(7.0, -3.0), Vector2.ZERO)
	var coarse_closest: Dictionary = coarse_pathfinder._closest_reachable_to_region_on_current_graph(beyond_budget_region, 0.0, Callable(), [], 3.0)
	var refined_closest := MovementPathfinder.new(state, mover, 12.0, "surge").closest_reachable_to_region(
		beyond_budget_region, 0.0, Callable(), [], 3.0)
	check(not is_inf(float(coarse_closest.distance)) and float(refined_closest.distance) + 1.0 < float(coarse_closest.distance)
		and float(refined_closest.route_distance) <= 12.0,
		"Adaptive cross-surface refinement improves a finite but suboptimal closest endpoint (coarse %.3f; refined %.3f)" % [float(coarse_closest.distance), float(refined_closest.distance)])

func test_surge_multiple_surface_transitions() -> void:
	var state := fresh_fist()
	if state.has("error"):
		check(false, "Multi-surface Surge routing initializes a current-reference battle")
		return
	prepare_battle(state, "shooting", 2)
	var crusaders := squad_for(state, 1, "crusader-squad")
	var enemy_squad := squad_for(state, 2)
	var crusader_models := C.living(state, crusaders)
	var enemy_models := C.living(state, enemy_squad)
	if crusader_models.size() < 3 or enemy_models.is_empty():
		check(false, "Multi-surface Surge fixture has two movers, a casualty and an enemy target")
		return
	for model: int in state.units: state.units[model].wounds = 0
	var first_mover: int = crusader_models[0]
	var second_mover: int = crusader_models[1]
	var casualty: int = crusader_models[2]
	var enemy: int = enemy_models[0]
	for model: int in [first_mover, second_mover, enemy]:
		state.units[model].wounds = 1
		state.units[model].radius = 0.25
	state.units[first_mover].position = Vector2(-0.7, 0.0)
	state.units[second_mover].position = Vector2(-0.7, 0.5)
	state.units[enemy].position = Vector2(10.0, 10.0)
	state.units[first_mover].elevation = 0.0
	state.units[second_mover].elevation = 0.0
	state.units[enemy].elevation = 0.0
	var first_wall := Rect2(-0.1, -50.0, 0.2, 100.0)
	var second_wall := Rect2(0.45, 0.25, 0.05, 0.05)
	var first_floor := {"id": "surge-first-floor", "name": "Surge first floor", "bounds": Rect2(-2.0, -2.0, 8.0, 4.0),
		"elevation": 1.0, "access_features": [0], "requires_keywords": ["infantry"]}
	var second_floor := {"id": "surge-second-floor", "name": "Surge second floor", "bounds": Rect2(-2.0, -2.0, 8.0, 4.0),
		"elevation": 2.0, "access_features": [1], "requires_keywords": ["infantry"]}
	state.terrain.areas = [{"name": "Two-stage Surge ruin", "category": "legacy", "bounds": Rect2(-2.0, -50.0, 8.0, 100.0),
		"features": [{"bounds": first_wall, "height": 4.0, "blocks_end": true},
			{"bounds": second_wall, "height": 4.0, "blocks_end": true}], "surfaces": [first_floor, second_floor]}]
	var first_transition := Vector2(0.4, -0.6)
	var first_destination := Vector2(3.0, 0.0)
	var second_transition := Vector2(0.4, 1.1)
	var second_destination := Vector2(3.0, 0.5)
	var first_transition_state: Dictionary = state.duplicate(true)
	var first_leg := MovementGeometry.clear_path(state, first_mover, first_transition, 6.0, false, false, 1.0, "surge")
	first_transition_state.units[first_mover].position = first_transition
	first_transition_state.units[first_mover].elevation = 1.0
	var second_leg := MovementGeometry.clear_path(first_transition_state, first_mover, first_destination, 6.0, false, false, 2.0, "surge")
	var direct_leg := MovementGeometry.clear_path(state, first_mover, first_destination, 6.0, false, false, 2.0, "surge")
	var composed_distance := Terrain.movement_distance(state.units[first_mover].position, 0.0, first_transition, 1.0) \
		+ Terrain.movement_distance(first_transition, 1.0, first_destination, 2.0)
	var route := MovementPathfinder.new(state, first_mover, 6.0, "surge").distance_to(first_destination, 2.0)
	check(first_leg and second_leg and not direct_leg and composed_distance < 6.0,
		"A 6-inch Surge consists of two individually legal vertical-access segments (first %s; second %s; direct %s; composed %.3f)" % [str(first_leg), str(second_leg), str(direct_leg), composed_distance])
	check(not is_inf(route) and route <= composed_distance + 0.05,
		"Surge routing finds the valid two-transition route through both floors within 6 inches (got %.3f; composed %.3f)" % [route, composed_distance])
	var closest := MovementPathfinder.new(state, first_mover, 6.0, "surge").closest_reachable_to_region(
		Rect2(first_destination, Vector2.ZERO), 0.0, Callable(), [], 2.0)
	check(is_zero_approx(float(closest.get("distance", INF))) and float(closest.get("route_distance", INF)) <= composed_distance + 0.05,
		"Closest-region routing reaches the second-floor target through two transitions within 6 inches (gap %.3f; route %.3f)" % [float(closest.get("distance", INF)), float(closest.get("route_distance", INF))])
	var second_transition_state: Dictionary = state.duplicate(true)
	var second_first_leg := MovementGeometry.clear_path(state, second_mover, second_transition, 6.0, false, false, 1.0, "surge")
	second_transition_state.units[second_mover].position = second_transition
	second_transition_state.units[second_mover].elevation = 1.0
	var second_second_leg := MovementGeometry.clear_path(second_transition_state, second_mover, second_destination, 6.0, false, false, 2.0, "surge")
	var second_direct_leg := MovementGeometry.clear_path(state, second_mover, second_destination, 6.0, false, false, 2.0, "surge")
	check(second_first_leg and second_second_leg and not second_direct_leg,
		"The adjacent formation member also has two legal access segments where direct movement is blocked")
	Surge.open_after_enemy_shot(state, enemy_squad, [{"target_squad": crusaders, "models_destroyed": 1,
		"allocations": [{"model": casualty, "wounds_before": 1, "wounds_after": 0}]}])
	var use_result := submit(state, 1, "crusader-surge-use", crusaders, "", -1, Vector2.ZERO, func() -> int: return 5)
	state.mission.objectives = [{"name": "Upper Purge objective", "kind": "marker", "position": Vector2(4.0, 0.25), "elevation": 2.0, "controller": 0, "secured": 0}]
	var objective_choice := choice_for(state, 1, "crusader-surge-objective", crusaders, "0")
	var target_result: Dictionary = PublicUnitCommand.submit(state, 1, objective_choice) if not objective_choice.is_empty() else {"error": "No Purge and Sanctify objective was offered."}
	var first_placement := submit(state, 1, "crusader-surge-place", crusaders, "", first_mover, first_destination, Callable(), 2.0)
	var second_placement := submit(state, 1, "crusader-surge-place", crusaders, "", second_mover, second_destination, Callable(), 2.0)
	check(str(use_result.get("error", "")).is_empty() and str(target_result.get("error", "")).is_empty()
		and str(first_placement.get("error", "")).is_empty() and str(second_placement.get("error", "")).is_empty(),
		"The public Purge and Sanctify flow previews two two-transition routes to an upper-floor objective (use: %s; target: %s; first: %s; second: %s)" % [str(use_result.get("error", "")), str(target_result.get("error", "")), str(first_placement.get("error", "")), str(second_placement.get("error", ""))])
	check(is_equal_approx(float(state.units[first_mover].elevation), 0.0) and is_equal_approx(float(state.units[second_mover].elevation), 0.0),
		"Both multilevel moves remain previews until the full formation is confirmed")
	var confirm_result := submit(state, 1, "crusader-surge-confirm", crusaders)
	check(str(confirm_result.get("error", "")).is_empty() and state.units[first_mover].position == first_destination
		and state.units[second_mover].position == second_destination and is_equal_approx(float(state.units[first_mover].elevation), 2.0)
		and is_equal_approx(float(state.units[second_mover].elevation), 2.0) and bool(state.squads[crusaders].get("moved", false)),
		"Purge and Sanctify commits both two-transition endpoints after validating objective range and formation coherency (confirm: %s)" % str(confirm_result.get("error", "")))

func test_surge_multilevel_solo_objective_closest() -> void:
	var state := fresh_fist()
	if state.has("error"):
		check(false, "Multilevel solo objective routing initializes a current-reference battle")
		return
	prepare_battle(state, "shooting", 2)
	var crusaders := squad_for(state, 1, "crusader-squad")
	var movers := C.living(state, crusaders)
	if movers.is_empty():
		check(false, "Multilevel solo objective fixture has a living Crusader")
		return
	for model: int in state.units: state.units[model].wounds = 0
	var mover: int = movers[0]
	state.units[mover].wounds = 1
	state.units[mover].radius = 0.25
	state.units[mover].position = Vector2(-0.7, 0.0)
	state.units[mover].elevation = 0.0
	var first_wall := Rect2(-0.1, -50.0, 0.2, 100.0)
	var second_wall := Rect2(0.45, 0.25, 0.05, 0.05)
	var first_floor := {"id": "solo-first-floor", "name": "Solo first floor", "bounds": Rect2(-2.0, -2.0, 8.0, 4.0),
		"elevation": 1.0, "access_features": [0], "requires_keywords": ["infantry"]}
	var second_floor := {"id": "solo-second-floor", "name": "Solo second floor", "bounds": Rect2(-2.0, -2.0, 8.0, 4.0),
		"elevation": 2.0, "access_features": [1], "requires_keywords": ["infantry"]}
	state.terrain.areas = [{"name": "Solo two-stage ruin", "category": "legacy", "bounds": Rect2(-2.0, -50.0, 8.0, 100.0),
		"features": [{"bounds": first_wall, "height": 4.0, "blocks_end": true},
			{"bounds": second_wall, "height": 4.0, "blocks_end": true}], "surfaces": [first_floor, second_floor]}]
	var objective := {"name": "Distant upper objective", "kind": "marker", "position": Vector2(5.4, 0.25), "elevation": 2.0, "controller": 0, "secured": 0}
	state.mission.objectives = [objective]
	var target_region := Rect2(Vector2(objective.position), Vector2.ZERO)
	var target_radius := float(state.units[mover].radius) + Objectives.MARKER_RADIUS
	var closest := MovementPathfinder.new(state, mover, 4.0, "surge").closest_reachable_to_region(
		target_region, target_radius, Callable(), [], 2.0)
	var closest_gap := float(closest.get("distance", INF))
	var closest_route := float(closest.get("route_distance", INF))
	check(not is_inf(closest_gap) and closest_gap > 3.03 and closest_route <= 4.0 + Terrain.EPSILON,
		"The multilevel closest-region query returns the best partial point when Purge objective range is unreachable (gap %.3f; route %.3f)" % [closest_gap, closest_route])
	var finish: Dictionary = state.units[mover].duplicate(true)
	finish.position = Vector2(closest.get("point", state.units[mover].position))
	finish.elevation = float(closest.get("elevation", -1.0))
	var surface := Terrain.surface_at(state, finish, finish.position, finish.elevation)
	var solo_error := Surge._solo_objective_end_error(state, mover, finish, objective, 4.0)
	check(not surface.is_empty() and not Objectives.in_range(finish, objective) and Objectives.distance(finish, objective) <= closest_gap + 0.08
		and solo_error.is_empty(),
		"Solo Purge and Sanctify accepts its closest legal two-transition endpoint (surface: %s; error: %s)" % [str(surface.get("name", "")), solo_error])

func test_surge_three_surface_transitions() -> void:
	var state := fresh_fist()
	if state.has("error"):
		check(false, "Three-transition Surge routing initializes a current-reference battle")
		return
	prepare_battle(state, "shooting", 2)
	var crusaders := squad_for(state, 1, "crusader-squad")
	var movers := C.living(state, crusaders)
	if movers.is_empty():
		check(false, "Three-transition Surge fixture has a living mover")
		return
	for model: int in state.units: state.units[model].wounds = 0
	var mover: int = movers[0]
	state.units[mover].wounds = 1
	state.units[mover].radius = 0.25
	state.units[mover].position = Vector2(-0.7, 0.0)
	state.units[mover].elevation = 0.0
	var first_wall := Rect2(-0.1, -50.0, 0.2, 100.0)
	var second_wall := Rect2(0.45, 0.25, 0.05, 0.05)
	var third_wall := Rect2(1.15, 0.25, 0.05, 0.05)
	var first_floor := {"id": "surge-level-one", "name": "Surge level one", "bounds": Rect2(-2.0, -2.0, 8.0, 4.0),
		"elevation": 1.0, "access_features": [0], "requires_keywords": ["infantry"]}
	var second_floor := {"id": "surge-level-two", "name": "Surge level two", "bounds": Rect2(-2.0, -2.0, 8.0, 4.0),
		"elevation": 2.0, "access_features": [1], "requires_keywords": ["infantry"]}
	var third_floor := {"id": "surge-level-three", "name": "Surge level three", "bounds": Rect2(-2.0, -2.0, 8.0, 4.0),
		"elevation": 3.0, "access_features": [2], "requires_keywords": ["infantry"]}
	state.terrain.areas = [{"name": "Three-stage Surge ruin", "category": "legacy", "bounds": Rect2(-2.0, -50.0, 8.0, 100.0),
		"features": [{"bounds": first_wall, "height": 4.0, "blocks_end": true},
			{"bounds": second_wall, "height": 4.0, "blocks_end": true},
			{"bounds": third_wall, "height": 4.0, "blocks_end": true}], "surfaces": [first_floor, second_floor, third_floor]}]
	var first_transition := Vector2(0.4, -0.1)
	var second_transition := Vector2(1.2, -0.1)
	var destination := Vector2(3.0, 0.0)
	var first_state: Dictionary = state.duplicate(true)
	var first_leg := MovementGeometry.clear_path(state, mover, first_transition, 7.0, false, false, 1.0, "surge")
	first_state.units[mover].position = first_transition
	first_state.units[mover].elevation = 1.0
	var second_state: Dictionary = first_state.duplicate(true)
	var second_leg := MovementGeometry.clear_path(first_state, mover, second_transition, 7.0, false, false, 2.0, "surge")
	second_state.units[mover].position = second_transition
	second_state.units[mover].elevation = 2.0
	var third_leg := MovementGeometry.clear_path(second_state, mover, destination, 7.0, false, false, 3.0, "surge")
	var direct_leg := MovementGeometry.clear_path(state, mover, destination, 7.0, false, false, 3.0, "surge")
	var composed_distance := Terrain.movement_distance(Vector2(-0.7, 0.0), 0.0, first_transition, 1.0) \
		+ Terrain.movement_distance(first_transition, 1.0, second_transition, 2.0) \
		+ Terrain.movement_distance(second_transition, 2.0, destination, 3.0)
	var route := MovementPathfinder.new(state, mover, 7.0, "surge").distance_to(destination, 3.0)
	var closest := MovementPathfinder.new(state, mover, 7.0, "surge").closest_reachable_to_region(
		Rect2(destination, Vector2.ZERO), 0.0, Callable(), [], 3.0)
	check(first_leg and second_leg and third_leg and not direct_leg and composed_distance < 7.0,
		"A 7-inch Surge can use three individually legal vertical segments when direct movement is blocked (composed %.3f)" % composed_distance)
	check(not is_inf(route) and route <= composed_distance + 0.05,
		"The route search composes three floor transitions within 7 inches (route %.3f; composed %.3f)" % [route, composed_distance])
	check(is_zero_approx(float(closest.get("distance", INF))) and float(closest.get("route_distance", INF)) <= composed_distance + 0.05,
		"The closest-region search also composes three floor transitions (gap %.3f; route %.3f)" % [float(closest.get("distance", INF)), float(closest.get("route_distance", INF))])

func test_surge_ground_intermediate_surface_route() -> void:
	var state := fresh_fist()
	if state.has("error"):
		check(false, "Ground-intermediate Surge routing initializes a current-reference battle")
		return
	prepare_battle(state, "shooting", 2)
	var crusaders := squad_for(state, 1, "crusader-squad")
	var movers := C.living(state, crusaders)
	if movers.is_empty():
		check(false, "Ground-intermediate Surge fixture has a living mover")
		return
	for model: int in state.units: state.units[model].wounds = 0
	var mover: int = movers[0]
	state.units[mover].wounds = 1
	state.units[mover].radius = 0.25
	state.units[mover].position = Vector2(-0.7, 0.0)
	state.units[mover].elevation = 1.0
	var source_wall := Rect2(-0.1, -50.0, 0.2, 100.0)
	var destination_wall := Rect2(1.0, 0.25, 0.05, 0.05)
	var source_floor := {"id": "surge-source-floor", "name": "Surge source floor", "bounds": Rect2(-2.0, -2.0, 6.0, 4.0),
		"elevation": 1.0, "access_features": [0], "requires_keywords": ["infantry"]}
	var destination_floor := {"id": "surge-destination-floor", "name": "Surge destination floor", "bounds": Rect2(-2.0, -2.0, 6.0, 4.0),
		"elevation": 2.0, "access_features": [1], "requires_keywords": ["infantry"]}
	state.terrain.areas = [{"name": "Ground-intermediate Surge ruin", "category": "legacy", "bounds": Rect2(-2.0, -50.0, 6.0, 100.0),
		"features": [{"bounds": source_wall, "height": 4.0, "blocks_end": true},
			{"bounds": destination_wall, "height": 4.0, "blocks_end": true}], "surfaces": [source_floor, destination_floor]}]
	var ground_transition := Vector2(0.8, 0.0)
	var destination := Vector2(3.0, 0.0)
	var ground_state: Dictionary = state.duplicate(true)
	var descend_leg := MovementGeometry.clear_path(state, mover, ground_transition, 7.0, false, false, 0.0, "surge")
	ground_state.units[mover].position = ground_transition
	ground_state.units[mover].elevation = 0.0
	var ascend_leg := MovementGeometry.clear_path(ground_state, mover, destination, 7.0, false, false, 2.0, "surge")
	var direct_leg := MovementGeometry.clear_path(state, mover, destination, 7.0, false, false, 2.0, "surge")
	var composed_distance := Terrain.movement_distance(state.units[mover].position, 1.0, ground_transition, 0.0) \
		+ Terrain.movement_distance(ground_transition, 0.0, destination, 2.0)
	var route := MovementPathfinder.new(state, mover, 7.0, "surge").distance_to(destination, 2.0)
	var closest := MovementPathfinder.new(state, mover, 7.0, "surge").closest_reachable_to_region(
		Rect2(destination, Vector2.ZERO), 0.0, Callable(), [], 2.0)
	check(descend_leg and ascend_leg and not direct_leg and composed_distance < 7.0,
		"A legal route can descend to ground and ascend through a different ruin access (down %s; up %s; direct %s; total %.3f)" % [str(descend_leg), str(ascend_leg), str(direct_leg), composed_distance])
	check(not is_inf(route) and route <= composed_distance + 0.05,
		"Exact-destination routing composes the ground transition (route %.3f; composed %.3f)" % [route, composed_distance])
	var closest_point := Vector2(closest.get("point", Vector2.ZERO))
	var destination_surface := Terrain.surface_at(state, state.units[mover], closest_point, 2.0)
	check(is_zero_approx(float(closest.get("distance", INF))) and float(closest.get("route_distance", INF)) <= composed_distance + 0.05
		and not destination_surface.is_empty(),
		"Closest-region routing composes the ground transition and ends on the requested floor (gap %.3f; route %.3f; surface %s)" % [float(closest.get("distance", INF)), float(closest.get("route_distance", INF)), str(destination_surface.get("name", ""))])

func test_surge_same_floor_ground_detour() -> void:
	var state := fresh_fist()
	if state.has("error"):
		check(false, "Same-floor ground-detour Surge initializes a current-reference battle")
		return
	prepare_battle(state, "shooting", 2)
	var crusaders := squad_for(state, 1, "crusader-squad")
	var enemy_squad := squad_for(state, 2)
	var members := C.living(state, crusaders)
	if members.size() < 2 or enemy_squad < 0:
		check(false, "Same-floor ground-detour fixture has Crusaders and an enemy shooter")
		return
	var mover: int = members[0]
	var allocations: Array[Dictionary] = []
	for model: int in members:
		if model == mover: continue
		var wounds_before := int(state.units[model].get("wounds", 1))
		state.units[model].wounds = 0
		allocations.append({"model": model, "wounds_before": wounds_before, "wounds_after": 0})
	state.units[mover].wounds = 1
	state.units[mover].radius = 0.25
	state.units[mover].position = Vector2(-0.5, 0.0)
	state.units[mover].elevation = 1.8
	var destination := Vector2(0.5, 0.0)
	var upper_floor := {"id": "same-floor-detour", "name": "Same-floor detour", "bounds": Rect2(-1.0, -0.5, 2.0, 1.0),
		"elevation": 1.8, "access_features": [0, 2], "requires_keywords": ["infantry"]}
	state.terrain.areas = [{"name": "Platform split by a full-height wall", "category": "legacy", "bounds": Rect2(-1.0, -1.0, 2.0, 2.0),
		"features": [
			{"bounds": Rect2(-1.05, -0.2, 0.1, 0.4), "height": 4.0, "blocks_end": true},
			{"bounds": Rect2(-0.05, -0.5, 0.1, 1.0), "height": 4.0, "blocks_end": true},
			{"bounds": Rect2(0.95, -0.2, 0.1, 0.4), "height": 4.0, "blocks_end": true}], "surfaces": [upper_floor]}]
	state.mission.objectives = [{"name": "Same-floor Purge objective", "kind": "marker", "position": destination,
		"elevation": 1.8, "controller": 0, "secured": 0}]
	var direct_leg := MovementGeometry.clear_path(state, mover, destination, 7.0, false, false, 1.8, "surge")
	var exact_route := MovementPathfinder.new(state, mover, 7.0, "surge").distance_to(destination, 1.8)
	var closest := MovementPathfinder.new(state, mover, 7.0, "surge").closest_reachable_to_region(
		Rect2(destination, Vector2.ZERO), 0.0, Callable(), [], 1.8)
	check(not direct_leg and not is_inf(exact_route) and exact_route <= 7.0
		and is_zero_approx(float(closest.get("distance", INF))) and float(closest.get("route_distance", INF)) <= 7.0,
		"Exact and closest-region routes can descend, detour around the split platform and return to the same floor (direct %s; route %.3f; closest %.3f)" % [str(direct_leg), exact_route, float(closest.get("route_distance", INF))])
	Surge.open_after_enemy_shot(state, enemy_squad, [{"target_squad": crusaders, "models_destroyed": allocations.size(), "allocations": allocations}])
	var use_result := submit(state, 1, "crusader-surge-use", crusaders, "", -1, Vector2.ZERO, func() -> int: return 6)
	var objective_result := submit(state, 1, "crusader-surge-objective", crusaders, "0")
	var original_position: Vector2 = state.units[mover].position
	var placement_result := submit(state, 1, "crusader-surge-place", crusaders, "", mover, destination, Callable(), 1.8)
	check(str(use_result.get("error", "")).is_empty() and int(C.UnitActions.pending(state).get("distance", 0)) == 7
		and str(objective_result.get("error", "")).is_empty() and str(placement_result.get("error", "")).is_empty()
		and state.units[mover].position == original_position,
		"Purge and Sanctify previews the same-floor ground detour within a D6+1 Surge without changing live position (use: %s; objective: %s; placement: %s)" % [str(use_result.get("error", "")), str(objective_result.get("error", "")), str(placement_result.get("error", ""))])
	var confirm_result := submit(state, 1, "crusader-surge-confirm", crusaders)
	check(str(confirm_result.get("error", "")).is_empty() and state.units[mover].position == destination
		and is_equal_approx(float(state.units[mover].elevation), 1.8),
		"Purge and Sanctify commits a destination back on the same upper surface after confirming the composed route (confirm: %s)" % str(confirm_result.get("error", "")))

func test_surge_same_height_surface_transition() -> void:
	var state := fresh_fist()
	if state.has("error"):
		check(false, "Same-height surface-transition Surge routing initializes a current-reference battle")
		return
	prepare_battle(state, "shooting", 2)
	var crusaders := squad_for(state, 1, "crusader-squad")
	var movers := C.living(state, crusaders)
	var enemy_squad := squad_for(state, 2)
	var enemy_models := C.living(state, enemy_squad)
	if movers.size() < 3 or enemy_models.is_empty():
		check(false, "Same-height surface-transition fixture has a casualty, two surviving movers and a shooter")
		return
	for model: int in state.units: state.units[model].wounds = 0
	var casualty: int = movers[0]
	var mover: int = movers[1]
	var second_mover: int = movers[2]
	var enemy: int = enemy_models[0]
	state.units[mover].wounds = 1
	state.units[second_mover].wounds = 1
	for model: int in [mover, second_mover]:
		state.units[model].radius = 0.25
		state.units[model].elevation = 1.0
	state.units[mover].position = Vector2(-1.5, -0.5)
	state.units[second_mover].position = Vector2(-1.5, 0.5)
	var source_floor := {"id": "same-height-source-floor", "name": "Same-height source floor", "bounds": Rect2(-2.0, -2.0, 2.0, 4.0),
		"elevation": 1.0, "access_features": [0], "requires_keywords": ["infantry"]}
	var destination_floor := {"id": "same-height-destination-floor", "name": "Same-height destination floor", "bounds": Rect2(1.0, -2.0, 2.0, 4.0),
		"elevation": 1.0, "access_features": [1], "requires_keywords": ["infantry"]}
	state.terrain.areas = [{"name": "Same-height separated platforms", "category": "legacy", "bounds": Rect2(-4.0, -4.0, 8.0, 8.0),
		"features": [{"bounds": Rect2(-0.45, -0.2, 0.1, 0.4), "height": 4.0, "blocks_end": true},
			{"bounds": Rect2(1.45, -0.2, 0.1, 0.4), "height": 4.0, "blocks_end": true}],
		"surfaces": [source_floor, destination_floor]}]
	var ground_transition := Vector2(-0.8, 0.0)
	var destination := Vector2(2.2, 0.0)
	var descend := MovementPathfinder.new(state, mover, 7.0, "surge").distance_to(ground_transition, 0.0)
	var ground_state: Dictionary = state.duplicate(true)
	ground_state.units[mover].position = ground_transition
	ground_state.units[mover].elevation = 0.0
	var ascend := MovementPathfinder.new(ground_state, mover, 7.0, "surge").distance_to(destination, 1.0)
	var direct := MovementGeometry.clear_path(state, mover, destination, 7.0, false, false, 1.0, "surge")
	var route := MovementPathfinder.new(state, mover, 7.0, "surge").distance_to(destination, 1.0)
	var closest := MovementPathfinder.new(state, mover, 7.0, "surge").closest_reachable_to_region(
		Rect2(destination, Vector2.ZERO), 0.0, Callable(), [], 1.0)
	var closest_surface := Terrain.surface_at(state, state.units[mover], Vector2(closest.get("point", Vector2.ZERO)), 1.0)
	var composed_distance := descend + ascend
	check(not is_inf(descend) and not is_inf(ascend) and not direct,
		"Separate same-height floors reject the direct segment but allow legal descent and ascent (down %.3f; up %.3f; direct %s)" % [descend, ascend, str(direct)])
	check(not is_inf(route) and route <= composed_distance + 0.05,
		"Exact route search composes the ground detour between same-height floors (route %.3f; composed %.3f)" % [route, composed_distance])
	check(is_zero_approx(float(closest.get("distance", INF))) and float(closest.get("route_distance", INF)) <= composed_distance + 0.05
		and str(closest_surface.get("id", "")) == str(destination_floor.id),
		"Closest-region search reaches the requested same-height floor through ground (gap %.3f; route %.3f; surface %s)" % [float(closest.get("distance", INF)), float(closest.get("route_distance", INF)), str(closest_surface.get("id", ""))])
	var objective_region := Rect2(Vector2(2.0, -0.5), Vector2(0.5, 1.0))
	var closest_region := MovementPathfinder.new(state, mover, 7.0, "surge").closest_reachable_to_region(
		objective_region, 0.25, Callable(), [], 1.0)
	var closest_region_surface := Terrain.surface_at(state, state.units[mover], Vector2(closest_region.get("point", Vector2.ZERO)), 1.0)
	check(is_zero_approx(float(closest_region.get("distance", INF))) and float(closest_region.get("route_distance", INF)) <= 7.0 + 0.001
		and str(closest_region_surface.get("id", "")) == str(destination_floor.id),
		"Finite objective-region search finds a reachable endpoint on the separate same-height platform (gap %.3f; route %.3f; surface %s)" % [float(closest_region.get("distance", INF)), float(closest_region.get("route_distance", INF)), str(closest_region_surface.get("id", ""))])
	state.units[enemy].wounds = 1
	state.units[enemy].position = Vector2(7.0, 7.0)
	state.mission.objectives = [{"name": "Separated upper platform", "kind": "terrain", "bounds": Rect2(2.0, -0.5, 0.5, 1.0)}]
	Surge.open_after_enemy_shot(state, enemy_squad, [{"target_squad": crusaders, "models_destroyed": 1,
		"allocations": [{"model": casualty, "wounds_before": 1, "wounds_after": 0}]}])
	var use_result := submit(state, 1, "crusader-surge-use", crusaders, "", -1, Vector2.ZERO, func() -> int: return 6)
	var objective_result := submit(state, 1, "crusader-surge-objective", crusaders, "0")
	var first_place_result := submit(state, 1, "crusader-surge-place", crusaders, "", mover, Vector2(2.2, -0.25), Callable(), 1.0)
	var second_place_result := submit(state, 1, "crusader-surge-place", crusaders, "", second_mover, Vector2(2.2, 0.25), Callable(), 1.0)
	var preview_unchanged: bool = state.units[mover].position == Vector2(-1.5, -0.5) \
		and state.units[second_mover].position == Vector2(-1.5, 0.5) \
		and is_equal_approx(float(state.units[mover].elevation), 1.0) \
		and is_equal_approx(float(state.units[second_mover].elevation), 1.0)
	var confirm_result := submit(state, 1, "crusader-surge-confirm", crusaders)
	check(str(use_result.get("error", "")).is_empty() and str(objective_result.get("error", "")).is_empty()
		and str(first_place_result.get("error", "")).is_empty() and str(second_place_result.get("error", "")).is_empty() and preview_unchanged,
		"Public Purge and Sanctify previews both same-height platform routes, preserves live positions and keeps the pair coherent (use: %s; objective: %s; first: %s; second: %s)" % [str(use_result.get("error", "")), str(objective_result.get("error", "")), str(first_place_result.get("error", "")), str(second_place_result.get("error", ""))])
	check(str(confirm_result.get("error", "")).is_empty() and state.units[mover].position == Vector2(2.2, -0.25)
		and state.units[second_mover].position == Vector2(2.2, 0.25)
		and is_equal_approx(float(state.units[mover].elevation), 1.0)
		and is_equal_approx(float(state.units[second_mover].elevation), 1.0) and MovementGeometry.coherent(state, crusaders),
		"Confirming the public Surge commits both routes on the same-height destination platform and preserves coherency (error: %s)" % str(confirm_result.get("error", "")))

func test_duplicate_surface_ids_do_not_connect_platforms() -> void:
	var state := fresh_fist()
	if state.has("error"):
		check(false, "Duplicate-surface identity fixture initializes a current-reference battle")
		return
	prepare_battle(state, "shooting", 2)
	var crusaders := squad_for(state, 1, "crusader-squad")
	var movers := C.living(state, crusaders)
	if movers.is_empty():
		check(false, "Duplicate-surface identity fixture has a living Crusader")
		return
	for model: int in state.units: state.units[model].wounds = 0
	var mover: int = movers[0]
	state.units[mover].wounds = 1
	state.units[mover].radius = 0.25
	state.units[mover].position = Vector2(-8.0, 0.0)
	state.units[mover].elevation = 1.0
	var first_floor := {"id": "reused-floor-id", "name": "First disconnected floor", "bounds": Rect2(-10.0, -4.0, 4.0, 8.0),
		"elevation": 1.0, "access_features": [], "requires_keywords": ["infantry"]}
	var second_floor := {"id": "reused-floor-id", "name": "Second disconnected floor", "bounds": Rect2(-2.0, -4.0, 4.0, 8.0),
		"elevation": 1.0, "access_features": [], "requires_keywords": ["infantry"]}
	var third_floor := {"id": "reused-floor-id", "name": "Third disconnected floor", "bounds": Rect2(6.0, -4.0, 4.0, 8.0),
		"elevation": 1.0, "access_features": [], "requires_keywords": ["infantry"]}
	state.terrain.areas = [
		{"name": "Duplicate floor ids in one area", "category": "legacy", "bounds": Rect2(-10.0, -4.0, 12.0, 8.0),
			"features": [], "surfaces": [first_floor, second_floor]},
		{"name": "Duplicate floor id in another area", "category": "legacy", "bounds": Rect2(6.0, -4.0, 4.0, 8.0),
			"features": [], "surfaces": [third_floor]}]
	var origin_surface := Terrain.surface_at(state, state.units[mover], state.units[mover].position, 1.0)
	var same_area_destination := Vector2(0.0, 0.0)
	var same_area_surface := Terrain.surface_at(state, state.units[mover], same_area_destination, 1.0)
	var cross_area_destination := Vector2(8.0, 0.0)
	var cross_area_surface := Terrain.surface_at(state, state.units[mover], cross_area_destination, 1.0)
	var pathfinder := MovementPathfinder.new(state, mover, 20.0, "surge")
	var same_area_route := pathfinder.distance_to(same_area_destination, 1.0)
	var cross_area_route := pathfinder.distance_to(cross_area_destination, 1.0)
	var same_area_transition := pathfinder._region_requires_surface_transition(Rect2(same_area_destination, Vector2.ZERO), 0.0, 1.0)
	var cross_area_transition := pathfinder._region_requires_surface_transition(Rect2(cross_area_destination, Vector2.ZERO), 0.0, 1.0)
	check(not origin_surface.is_empty() and not same_area_surface.is_empty() and not cross_area_surface.is_empty()
		and not Terrain.same_surface(origin_surface, same_area_surface) and not Terrain.same_surface(origin_surface, cross_area_surface),
		"Surface identity distinguishes repeated ids within one area and across terrain areas")
	check(not MovementGeometry.clear_path(state, mover, same_area_destination, 20.0, false, false, 1.0, "surge")
		and not MovementGeometry.clear_path(state, mover, cross_area_destination, 20.0, false, false, 1.0, "surge")
		and not Terrain.path_error(state, mover, same_area_destination, 1.0).is_empty()
		and not Terrain.path_error(state, mover, cross_area_destination, 1.0).is_empty()
		and is_inf(same_area_route) and is_inf(cross_area_route) and same_area_transition and cross_area_transition,
		"Same-height duplicate-id floors cannot be crossed directly or treated as one surface within or across areas")
