extends RefCounted

const AircraftRules = preload("res://scripts/edition_11/aircraft_rules.gd")
## Original demonstration rules. No official edition is implemented yet.
const PACK_ID := "prototype-movement-v1"
const Pack = preload("res://scripts/data_pack.gd")
const PACK_DIRECTORY := "res://data/packs/demo"
const HALF_BOARD := Vector2(15, 10)

static func half_board(state: Dictionary) -> Vector2:
	return state.get("board_size", HALF_BOARD * 2.0) / 2.0
const TERRAIN := [Rect2(-3, -2, 6, 4), Rect2(-11, 3, 4, 2), Rect2(7, -5, 4, 2)]

static func initial_state() -> Dictionary:
	var pack: Dictionary = Pack.load_pack(PACK_DIRECTORY)
	var error: String = Pack.playable_error(pack)
	if not error.is_empty():
		push_error("Cannot load demo pack: " + error)
		return {}
	var profile: Dictionary = pack.units[0]
	var units: Dictionary = {}
	for side in [1, 2]:
		for index in range(3):
			var id: int = side * 10 + index
			units[id] = {"owner": side, "position": Vector2(-12 if side == 1 else 12, (index - 1) * 3), "moved": false, "definition_id": profile.id, "movement": profile.stats.movement_inches, "radius": profile.base.radius_inches}
	return {"pack": PACK_ID, "pack_hash": pack.manifest.units_sha256, "turn": 1, "active": 1, "units": units}

static func _movement_validation_result(code: String, reason: String = "", recovery: String = "") -> Dictionary:
	return {"valid": reason.is_empty(), "code": "valid" if reason.is_empty() else code, "reason": reason, "recovery": recovery}

static func validate_move_result(state: Dictionary, player: int, id: int, target: Vector2) -> Dictionary:
	if not is_finite(target.x) or not is_finite(target.y):
		return _movement_validation_result("invalid_destination", "Invalid destination.", "Choose a point on the battlefield.")
	if not state.units.has(id):
		return _movement_validation_result("model_unavailable", "Select a miniature.", "Select one of your models.")
	var unit: Dictionary = state.units[id]
	if state.active != player or unit.owner != player:
		return _movement_validation_result("wrong_owner", "Only the active player's miniatures can move.", "Select a model you control on your turn.")
	if unit.moved:
		return _movement_validation_result("model_already_moved", "This miniature has already moved this turn.", "Choose a model that has not moved yet.")
	var origin: Vector2 = unit.position
	var radius: float = unit.radius
	if origin.distance_to(target) > float(unit.movement):
		return _movement_validation_result("exceeds_movement", "Movement exceeds %.2f prototype units." % unit.movement, "Choose a closer destination within the movement allowance.")
	if absf(target.x) > half_board(state).x - radius or absf(target.y) > half_board(state).y - radius:
		return _movement_validation_result("outside_battlefield", "The base must stay on the battlefield.", "Choose a destination inside the battlefield edge.")
	# Swept base check: straight-line moves cannot cross terrain or other bases.
	for rect: Rect2 in TERRAIN:
		var expanded: Rect2 = rect.grow(radius)
		if expanded.has_point(target) or expanded.has_point(origin):
			return _movement_validation_result("terrain_blocked", "Terrain blocks this move.", "Choose a route around the terrain.")
		var corners := [expanded.position, Vector2(expanded.end.x, expanded.position.y), expanded.end, Vector2(expanded.position.x, expanded.end.y)]
		for edge in range(4):
			if Geometry2D.segment_intersects_segment(origin, target, corners[edge], corners[(edge + 1) % 4]) != null:
				return _movement_validation_result("terrain_blocked", "Terrain blocks this move.", "Choose a route around the terrain.")
	for other_id: int in state.units:
		if other_id == id:
			continue
		var other: Dictionary = state.units[other_id]
		var other_position: Vector2 = other.position
		if AircraftRules.is_aircraft(state, int(other.get("squad", -1))):
			if target.distance_to(other_position) < radius + float(other.radius):
				return _movement_validation_result("destination_overlap", "A model cannot end its move overlapping an AIRCRAFT base.", "Choose a free destination beyond the AIRCRAFT base.")
			continue
		var closest := Geometry2D.get_closest_point_to_segment(other_position, origin, target)
		if closest.distance_to(other_position) < radius + float(other.radius):
			return _movement_validation_result("base_blocks_path", "Another base blocks this move.", "Choose a clear route around the other base.")
	return _movement_validation_result("valid")

static func validate_move(state: Dictionary, player: int, id: int, target: Vector2) -> String:
	return str(validate_move_result(state, player, id, target).get("reason", "Movement validation failed."))

static func end_turn(state: Dictionary) -> void:
	state.active = 3 - state.active
	state.turn += 1
	for id: int in state.units:
		state.units[id].moved = false
