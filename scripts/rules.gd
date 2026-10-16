extends RefCounted
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

static func validate_move(state: Dictionary, player: int, id: int, target: Vector2) -> String:
	if not is_finite(target.x) or not is_finite(target.y):
		return "Invalid destination."
	if not state.units.has(id):
		return "Select a miniature."
	var unit: Dictionary = state.units[id]
	if state.active != player or unit.owner != player:
		return "Only the active player's miniatures can move."
	if unit.moved:
		return "This miniature has already moved this turn."
	var origin: Vector2 = unit.position
	var radius: float = unit.radius
	if origin.distance_to(target) > float(unit.movement):
		return "Movement exceeds %.2f prototype units." % unit.movement
	if absf(target.x) > half_board(state).x - radius or absf(target.y) > half_board(state).y - radius:
		return "The base must stay on the battlefield."
	# Swept base check: straight-line moves cannot cross terrain or other bases.
	for rect: Rect2 in TERRAIN:
		var expanded: Rect2 = rect.grow(radius)
		if expanded.has_point(target) or expanded.has_point(origin):
			return "Terrain blocks this move."
		var corners := [expanded.position, Vector2(expanded.end.x, expanded.position.y), expanded.end, Vector2(expanded.position.x, expanded.end.y)]
		for edge in range(4):
			if Geometry2D.segment_intersects_segment(origin, target, corners[edge], corners[(edge + 1) % 4]) != null:
				return "Terrain blocks this move."
	for other_id: int in state.units:
		if other_id == id:
			continue
		var other_position: Vector2 = state.units[other_id].position
		var closest := Geometry2D.get_closest_point_to_segment(other_position, origin, target)
		if closest.distance_to(other_position) < radius + float(state.units[other_id].radius):
			return "Another base blocks this move."
	return ""

static func end_turn(state: Dictionary) -> void:
	state.active = 3 - state.active
	state.turn += 1
	for id: int in state.units:
		state.units[id].moved = false
