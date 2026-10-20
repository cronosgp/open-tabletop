extends RefCounted
## Alternating unit placement for the custom prepared-training scenario.
const Geometry = preload("res://scripts/edition_11/contact_movement.gd")
const Terrain = preload("res://scripts/edition_11/terrain.gd")
const ScoutMoves = preload("res://scripts/edition_11/scout_moves.gd")
const TransportRules = preload("res://scripts/edition_11/transport_rules.gd")
const EPSILON := 0.001

static func begin(state: Dictionary) -> void:
	var half: Vector2 = state.board_size / 2.0
	var order: Array[int] = []
	var sides := {1: [], 2: []}
	for squad: int in state.squads:
		if not state.get("unit_abilities", {}).get("reserves", {}).has(squad) and not TransportRules.squad_embarked(state, squad): sides[state.squads[squad].owner].append(squad)
	sides[1].sort()
	sides[2].sort()
	var defender: int = state.get("mission", {}).get("defender", 1)
	if defender not in [1, 2]: defender = 1
	for index in range(maxi(sides[1].size(), sides[2].size())):
		for owner in [defender, 3 - defender]:
			if index < sides[owner].size(): order.append(sides[owner][index])
	state.deployment = {"order": order, "index": 0, "placed": {}, "committed": [],
		"zones": {1: Rect2(-half.x, -half.y, 11, half.y * 2), 2: Rect2(half.x - 11, -half.y, 11, half.y * 2)}, "complete": false}
	if state.get("mission", {}).get("id", "") == "ca-2026-27-dominance-hammer-fixed-v1" and state.mission.defender > 0:
		state.deployment.zones = {state.mission.attacker: Rect2(-30, -22, 18, 44), state.mission.defender: Rect2(12, -22, 18, 44)}
	state.phase = "deployment"

static func current(state: Dictionary) -> int:
	var setup: Dictionary = state.get("deployment", {})
	if setup.is_empty() or setup.complete or setup.order.is_empty(): return -1
	return int(setup.order[setup.index])

static func actor(state: Dictionary) -> int:
	var squad := current(state)
	return int(state.squads[squad].owner) if squad >= 0 else int(state.active)

static func command_error(state: Dictionary, player: int, revision: int) -> String:
	if state.get("mission", {}).get("stage", "formations") in ["terrain", "roles-roll", "roles-choice", "battle-ready"]: return "Resolve mission preparation before deployment."
	if not state.get("awakened_dynasty", {}).get("pending", []).is_empty(): return "Finish Overlord attachment declarations before deployment."
	if state.get("unit_abilities", {}).get("implementation", "") != "" and state.unit_abilities.get("setup_players", []).size() < 2: return "Finish both players unit ability preparations before deployment."
	if state.get("phase", "") != "deployment" or current(state) < 0: return "No deployment is pending."
	if player != actor(state): return "Wait for the other player's deployment."
	if revision != state.revision: return "State changed; refresh deployment before trying again."
	return ""

static func position_error(state: Dictionary, model: int, position: Vector2) -> String:
	if not position.is_finite(): return "Invalid deployment coordinates."
	if not state.units.has(model) or state.units[model].squad != current(state) or state.units[model].wounds <= 0:
		return "Select a living model from the unit currently deploying."
	var unit: Dictionary = state.units[model]
	var radius: float = unit.radius
	var zone: Rect2 = state.deployment.zones[unit.owner]
	var inside_zone := position.x - radius >= zone.position.x - EPSILON and position.x + radius <= zone.end.x + EPSILON and position.y - radius >= zone.position.y - EPSILON and position.y + radius <= zone.end.y + EPSILON
	if not inside_zone:
		if not Terrain.Detection.infiltrators(state, unit.squad): return "The entire base must fit inside your deployment zone."
		if absf(position.x) + radius > state.board_size.x / 2.0 + EPSILON or absf(position.y) + radius > state.board_size.y / 2.0 + EPSILON: return "The entire base must fit on the battlefield."
		var enemy_zone: Rect2 = state.deployment.zones[3 - unit.owner]
		if position.distance_to(position.clamp(enemy_zone.position, enemy_zone.end)) - radius <= 8.0 + EPSILON: return "Infiltrators must be more than 8 inches from the enemy deployment zone."
		for enemy: int in state.units:
			var other: Dictionary = state.units[enemy]
			if other.owner == unit.owner or other.wounds <= 0 or not other.get("on_battlefield", true): continue
			if other.squad not in state.deployment.committed and not state.deployment.placed.has(enemy): continue
			if position.distance_to(other.position) - radius - float(other.radius) <= 8.0 + EPSILON: return "Infiltrators must be more than 8 inches from deployed enemy units."
	for id: int in state.units:
		if id == model or state.units[id].wounds <= 0 or not state.units[id].get("on_battlefield", true): continue
		if state.units[id].squad not in state.deployment.committed and not state.deployment.placed.has(id): continue
		if position.distance_to(state.units[id].position) < radius + float(state.units[id].radius) - EPSILON:
			return "Deployment bases cannot overlap."
	# Placement has no movement path or distance budget; check only its endpoint.
	var projected := state.duplicate(true)
	projected.units[model].position = position
	return Terrain.path_error(projected, model, position)

static func place(state: Dictionary, player: int, model: int, position: Vector2, revision: int) -> String:
	var error := command_error(state, player, revision)
	if error.is_empty(): error = position_error(state, model, position)
	if not error.is_empty(): return error
	state.units[model].position = position
	state.deployment.placed[model] = true
	_event(state, "Player %d placed model %d for deployment." % [player, model])
	return ""

static func preset(state: Dictionary, player: int, revision: int) -> String:
	var error := command_error(state, player, revision)
	if not error.is_empty(): return error
	var candidate := state.duplicate(true)
	for id: int in Geometry.alive(candidate, current(candidate)): candidate.deployment.placed[id] = true
	for id: int in Geometry.alive(candidate, current(candidate)):
		error = position_error(candidate, id, candidate.units[id].position)
		if not error.is_empty(): return error
	state.deployment.placed = candidate.deployment.placed
	_event(state, "Player %d accepted the current unit's preview positions." % player)
	return ""

static func confirm_error(state: Dictionary) -> String:
	var squad := current(state)
	if squad < 0: return "No deployment is pending."
	for id: int in Geometry.alive(state, squad):
		if not state.deployment.placed.has(id): return "Place every model, or accept the unit's preview positions first."
		var error := position_error(state, id, state.units[id].position)
		if not error.is_empty(): return error
	for id: int in state.units:
		if str(state.units[id].get("definition_id", "")).get_slice(":", 3) == "vulkan-hestan" and state.units[id].get("on_battlefield", true) and state.deployment.placed.has(id) and state.get("unit_abilities", {}).get("implementation", "") != "" and not state.unit_abilities.get("seeker_objectives", {}).has(id): return "Resolve Vulkan He’stan’s Seeker of the Unfound objective choice before confirming deployment."
	if not Geometry.coherent(state, squad): return "Restore unit coherency before confirming deployment."
	return ""

static func confirm(state: Dictionary, player: int, revision: int) -> String:
	var error := command_error(state, player, revision)
	if error.is_empty(): error = confirm_error(state)
	if not error.is_empty(): return error
	var squad := current(state)
	state.deployment.committed.append(squad)
	state.deployment.index += 1
	if state.deployment.index == state.deployment.order.size():
		state.deployment.complete = true
		state.phase = "mission_first_turn" if state.get("mission", {}).get("id", "") == "ca-2026-27-dominance-hammer-fixed-v1" else "pre_battle"
		if state.phase == "pre_battle": ScoutMoves.begin(state)
	_event(state, "Deployment complete. Roll off for first turn." if state.phase == "mission_first_turn" else "Deployment complete. Player 1 starts round 1." if state.deployment.complete else "Unit deployed; player %d places the next unit." % actor(state))
	return ""

static func _event(state: Dictionary, message: String) -> void:
	state.revision += 1
	state.events.append({"revision": state.revision, "message": message})
	if state.events.size() > 30: state.events.pop_front()
