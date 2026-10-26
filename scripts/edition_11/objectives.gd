extends RefCounted
## Core control rules; scoring below belongs to an explicit custom training mission.
const Terrain = preload("res://scripts/edition_11/terrain.gd")
const TRAINING := "objective-training-v1"
const MARKER_RADIUS := 20.0 / 25.4

static func setup(terrain: Dictionary, mission_id: String) -> Dictionary:
	if mission_id == "elimination": return {"id": mission_id, "objectives": []}
	if mission_id != TRAINING: return {"error": "Unknown mission: " + mission_id}
	var objectives: Array[Dictionary] = []
	for area: Dictionary in terrain.areas:
		objectives.append({"name": area.name, "kind": "terrain", "bounds": area.bounds, "controller": 0, "secured": 0, "levels": {1: 0, 2: 0}})
	return {"id": mission_id, "name": "Custom objective training", "rounds": 5, "points_per_objective": 1,
		"scores": {1: 0, 2: 0}, "scored_rounds": [], "objectives": objectives, "actions": ["training-secure"]}

static func in_range(model: Dictionary, objective: Dictionary) -> bool:
	if model.wounds <= 0 or not model.get("on_battlefield", true): return false
	if objective.kind == "terrain": return Terrain.within(model, objective.bounds)
	return maxf(0.0, model.position.distance_to(objective.position) - float(model.radius) - MARKER_RADIUS) <= 3.0 + Terrain.EPSILON and absf(float(model.get("elevation", 0.0)) - float(objective.get("elevation", 0.0))) <= 5.0 + Terrain.EPSILON

static func distance(model: Dictionary, objective: Dictionary) -> float:
	if objective.kind == "terrain":
		return maxf(0.0, model.position.distance_to(model.position.clamp(objective.bounds.position, objective.bounds.end)) - float(model.radius))
	return maxf(0.0, model.position.distance_to(objective.position) - float(model.radius) - MARKER_RADIUS)

static func consolidation_candidates(state: Dictionary, squad: int) -> Array[int]:
	var result: Array[int] = []
	var objectives: Array = state.get("mission", {}).get("objectives", [])
	for index in range(objectives.size()):
		for id: int in state.units:
			var objective: Dictionary = objectives[index]
			var vertical_distance := absf(float(state.units[id].get("elevation", 0.0)) - float(objective.get("elevation", 0.0)))
			if state.units[id].squad == squad and state.units[id].wounds > 0 and state.units[id].get("on_battlefield", true) and vertical_distance <= 5.0 + Terrain.EPSILON and distance(state.units[id], objective) <= 3.0 + Terrain.EPSILON:
				result.append(index)
				break
	return result

static func levels(state: Dictionary, objective: Dictionary, control_value: Callable) -> Dictionary:
	var result := {1: 0, 2: 0}
	for id: int in state.units:
		if in_range(state.units[id], objective): result[state.units[id].owner] += int(control_value.call(state, id))
	return result

static func resolve_control(state: Dictionary, control_value: Callable) -> void:
	for objective: Dictionary in state.get("mission", {}).get("objectives", []):
		var totals := levels(state, objective, control_value)
		objective.levels = totals
		var secured: int = objective.secured
		if secured != 0 and totals[3 - secured] <= totals[secured]:
			objective.controller = secured
		else:
			objective.secured = 0
			objective.controller = 1 if totals[1] > totals[2] else 2 if totals[2] > totals[1] else 0
		# Keep the squads that contributed to this phase's final control result.
		# Triggered rules can refer to a unit's control in the previous phase after
		# the unit itself has been destroyed.
		objective.last_controlled_squads = controlling_squads(state, objective, control_value)

static func controlling_squads(state: Dictionary, objective: Dictionary, control_value: Callable) -> Array[int]:
	var result: Array[int] = []
	for id: int in state.units:
		var model: Dictionary = state.units[id]
		if model.owner == objective.controller and in_range(model, objective) and int(control_value.call(state, id)) > 0 and model.squad not in result:
			result.append(model.squad)
	return result

static func record_previous_phase_control(state: Dictionary) -> void:
	# Called only after a phase's end decisions finish, so any-phase reactions in
	# the next phase can still inspect the previous phase's actual control state.
	for objective: Dictionary in state.get("mission", {}).get("objectives", []):
		var controlled_value: Variant = objective.get("last_controlled_squads", [])
		objective.previous_phase_controlled_squads = controlled_value.duplicate() if controlled_value is Array else []

static func secure(state: Dictionary, index: int, player: int) -> String:
	# Internal effect for future verified ability/mission handlers, never a player command.
	var objectives: Array = state.get("mission", {}).get("objectives", [])
	if player not in [1, 2] or index < 0 or index >= objectives.size(): return "Invalid objective effect."
	if objectives[index].controller != player: return "Only a controlled objective can be secured."
	objectives[index].secured = player
	return ""

static func secure_by_stratagem(state: Dictionary, index: int, player: int) -> String:
	# In Sacrifice, Victory can secure a marker using its own destruction trigger,
	# including a marker the destroyed squad controlled in the prior phase.
	var objectives: Array = state.get("mission", {}).get("objectives", [])
	if player not in [1, 2] or index < 0 or index >= objectives.size(): return "Invalid objective effect."
	objectives[index].controller = player
	objectives[index].secured = player
	return ""

static func training(state: Dictionary) -> bool:
	return state.get("mission", {}).get("id", "elimination") == TRAINING

static func score_round(state: Dictionary) -> String:
	if not training(state) or state.round in state.mission.scored_rounds: return ""
	var gained := {1: 0, 2: 0}
	for objective: Dictionary in state.mission.objectives:
		if objective.controller != 0: gained[objective.controller] += state.mission.points_per_objective
	for player in [1, 2]: state.mission.scores[player] += gained[player]
	state.mission.scored_rounds.append(state.round)
	var message := "Training round %d: +%d / +%d VP; total %d / %d." % [state.round, gained[1], gained[2], state.mission.scores[1], state.mission.scores[2]]
	if state.round >= state.mission.rounds:
		state.test_winner = 1 if state.mission.scores[1] > state.mission.scores[2] else 2 if state.mission.scores[2] > state.mission.scores[1] else -1
		message += " Training finished: " + ("draw." if state.test_winner == -1 else "player %d wins." % state.test_winner)
	return message
