extends RefCounted
## Editable contact moves on the flat circular-base exercise board.
const Geometry = preload("res://scripts/edition_11/contact_movement.gd")
const Reachability = preload("res://scripts/edition_11/contact_reachability.gd")
const Objectives = preload("res://scripts/edition_11/objectives.gd")
const Terrain = preload("res://scripts/edition_11/terrain.gd")
const EPSILON := 0.001
const VALIDATED := "contact_validation_complete"

static func enemies(state: Dictionary, squad: int, maximum: float = INF) -> Array[int]:
	var targets: Array[int] = []
	for enemy: int in state.squads:
		if state.squads[enemy].owner == state.squads[squad].owner: continue
		for id: int in Geometry.alive(state, squad):
			if Geometry.distance_to_target_at_height(state, state.units[id], enemy) <= maximum + EPSILON:
				targets.append(enemy)
				break
	return targets

static func draft(state: Dictionary, squad: int, kind: String, targets: Array[int], maximum: float) -> Dictionary:
	var origins: Dictionary = {}
	var origin_elevations: Dictionary = {}
	var engaged: Dictionary = {}
	var locked: Dictionary = {}
	for id: int in Geometry.alive(state, squad):
		origins[id] = state.units[id].position
		origin_elevations[id] = float(state.units[id].get("elevation", 0.0))
		engaged[id] = []
		for enemy: int in enemies(state, squad):
			var distance := Geometry.distance_to_target_at_height(state, state.units[id], enemy)
			if distance <= 2.0 + EPSILON: engaged[id].append(enemy)
			if distance <= EPSILON and kind != "charge":
				for enemy_model: int in Geometry.alive(state, enemy):
					if absf(float(state.units[id].get("elevation", 0.0)) - float(state.units[enemy_model].get("elevation", 0.0))) <= EPSILON and Geometry.edge(state.units[id], state.units[enemy_model]) <= EPSILON:
						locked[id] = true
						break
	return {"squad": squad, "kind": kind, "targets": targets.duplicate(), "maximum": maximum, "origins": origins, "origin_elevations": origin_elevations, "spent": {}, "engaged": engaged, "locked": locked}

static func remaining(state: Dictionary, model: int) -> float:
	var move: Dictionary = state.get("pending_contact", {})
	if move.is_empty() or not move.origins.has(model) or move.locked.has(model): return 0.0
	return maxf(0.0, float(move.maximum) - float(move.spent.get(model, 0.0)))

static func _segment_validation_result(code: String, reason: String = "", recovery: String = "") -> Dictionary:
	return {"valid": reason.is_empty(), "code": "valid" if reason.is_empty() else code, "reason": reason, "recovery": recovery}

static func validate_segment_result(state: Dictionary, model: int, destination: Vector2, destination_elevation: float = -1.0) -> Dictionary:
	var move: Dictionary = state.get("pending_contact", {})
	if move.is_empty() or not move.origins.has(model) or not state.units.has(model) or state.units[model].wounds <= 0: return _segment_validation_result("model_unavailable", "Select a living model in the moving squad.", "Select an eligible model in the active contact move.")
	if not destination.is_finite(): return _segment_validation_result("invalid_destination", "Invalid destination.", "Choose a point on the battlefield.")
	if move.locked.has(model): return _segment_validation_result("model_locked_in_contact", "Models in base contact cannot move during pile-in or ongoing consolidation.", "Keep this model in place and reposition another eligible model.")
	var origin_elevation := float(state.units[model].get("elevation", 0.0))
	var target_elevation := origin_elevation if destination_elevation < 0.0 else destination_elevation
	if not is_finite(target_elevation) or target_elevation < 0.0: return _segment_validation_result("unsupported_elevation", "Choose a supported battlefield elevation.", "Select one of the listed battlefield heights.")
	if state.units[model].position.distance_to(destination) <= EPSILON and absf(target_elevation - origin_elevation) <= EPSILON: return _segment_validation_result("unchanged_destination", "Choose a different destination.", "Choose a new position or height.")
	var allowance := remaining(state, model)
	var distance := Terrain.movement_distance(state.units[model].position, origin_elevation, destination, target_elevation, Terrain.ignores_vertical_movement(state, model))
	if distance > allowance + EPSILON: return _segment_validation_result("exceeds_contact_allowance", "Contact placement needs %.2f inches; %.2f remain." % [distance, allowance], "Choose a closer contact position within the remaining allowance.")
	var terrain_error := Terrain.path_error(state, model, destination, target_elevation)
	if not terrain_error.is_empty(): return _segment_validation_result("terrain_blocked", terrain_error, "Choose a route around the terrain feature.")
	if not Geometry.clear_path(state, model, destination, allowance, false, false, target_elevation): return _segment_validation_result("path_blocked", "Contact movement crosses an enemy base or leaves the battlefield.", "Choose a clear route that stays on the battlefield.")
	for other: int in state.units:
		if other == model or state.units[other].wounds <= 0 or not state.units[other].get("on_battlefield", true): continue
		if absf(target_elevation - float(state.units[other].get("elevation", 0.0))) > EPSILON: continue
		if destination.distance_to(state.units[other].position) < float(state.units[model].radius) + float(state.units[other].radius) - EPSILON:
			return _segment_validation_result("destination_overlap", "Bases cannot overlap at the destination.", "Choose a free destination that leaves space between bases.")
	return _segment_validation_result("valid")

static func validate_segment(state: Dictionary, model: int, destination: Vector2, destination_elevation: float = -1.0) -> String:
	return str(validate_segment_result(state, model, destination, destination_elevation).get("reason", "Contact validation failed."))

static func restore(state: Dictionary) -> void:
	for id: int in state.pending_contact.origins:
		state.units[id].position = state.pending_contact.origins[id]
		state.units[id].elevation = float(state.pending_contact.get("origin_elevations", {}).get(id, state.units[id].get("elevation", 0.0)))
	state.pending_contact.spent = {}

static func final_error(state: Dictionary) -> String:
	return final_validation(state).error

static func final_validation(state: Dictionary) -> Dictionary:
	var proofs: Array[Dictionary] = []
	var details: Array[Dictionary] = []
	var primary_model: Array[int] = []
	var result := _final_error(state, proofs, details, primary_model)
	# GDScript runtime failures can return the default empty String. An empty
	# result must not accidentally grant a contact move or waive an approach.
	var error := "" if result == VALIDATED else result
	if result.is_empty(): error = "Contact validation did not complete; the move was not accepted."
	var error_details := _final_error_details(error)
	return {"valid": error.is_empty(), "code": "valid" if error.is_empty() else str(error_details.code), "error": error, "proofs": proofs, "recovery": str(error_details.recovery), "details": details, "primary_model": primary_model[0] if not primary_model.is_empty() else -1}

static func _final_error_details(error: String) -> Dictionary:
	if error.is_empty(): return {"code": "valid", "recovery": ""}
	if error == "The moving squad must finish as one coherent group.":
		return {"code": "squad_not_coherent", "recovery": "Reposition the squad until it meets coherency, then confirm or cancel the move."}
	if error == "A selected contact target is no longer on the board.":
		return {"code": "contact_target_unavailable", "recovery": "Choose an available contact target or cancel the move."}
	if error == "Each required model must finish closer to its contact target.":
		return {"code": "contact_approach_blocked", "recovery": "Reposition each required model closer to its contact target, or cancel the move."}
	if error.begins_with("Finish within "):
		return {"code": "contact_distance_unmet", "recovery": "Reposition the model to meet the required distance, or cancel the move."}
	if error == "A model must retain each enemy unit it started engaged with.":
		return {"code": "engagement_not_retained", "recovery": "Reposition this model within Engagement Range of every unit it started engaged with."}
	if error == "A charge cannot finish engaged with an unselected enemy unit.":
		return {"code": "unselected_enemy_engagement", "recovery": "Reposition the charging squad so it is not engaged with an unselected enemy unit."}
	if error == "The squad must finish engaged with every selected target.":
		return {"code": "selected_target_not_engaged", "recovery": "Reposition the squad into Engagement Range of each selected target."}
	if error == "The pile-in or ongoing consolidation must finish engaged.":
		return {"code": "contact_not_reached", "recovery": "Reposition the squad to finish in Engagement Range, or cancel the move."}
	if error == "Moved models must finish within objective range; an obstacle/coherency exception is not certified for this objective.":
		return {"code": "objective_range_unavailable", "recovery": "Reposition the models into range of the objective, or cancel the move."}
	if error == "Moved models outside objective range must finish closer to the selected objective.":
		return {"code": "objective_not_closer", "recovery": "Reposition each model closer to the selected objective, or cancel the move."}
	if error == "Objective consolidation must finish unengaged.":
		return {"code": "objective_consolidation_engaged", "recovery": "Reposition the squad to finish outside Engagement Range, or cancel the move."}
	if error == "The squad must finish within range of the selected objective.":
		return {"code": "outside_objective_range", "recovery": "Move the squad into range of the selected objective, or cancel the move."}
	return {"code": "contact_blocked", "recovery": "Reposition the models or cancel the contact move."}

static func _final_error(state: Dictionary, proofs: Array[Dictionary], details: Array[Dictionary], primary_model: Array[int]) -> String:
	var move: Dictionary = state.pending_contact
	if not Geometry.coherent(state, move.squad): return "The moving squad must finish as one coherent group."
	if move.kind == "consolidate_objective": return _objective_error(state)
	for target: int in move.targets:
		if Geometry.alive(state, target).is_empty(): return "A selected contact target is no longer on the board."
	var model_failures: Array[Dictionary] = []
	var primary_model_error := ""
	for id: int in move.origins:
		var model: Dictionary = state.units[id]
		var origin: Dictionary = model.duplicate(true)
		origin.position = move.origins[id]
		origin.elevation = float(move.get("origin_elevations", {}).get(id, origin.get("elevation", 0.0)))
		var moved: bool = float(move.spent.get(id, 0.0)) > EPSILON
		var closest := INF
		var final_distance := INF
		var closer_to_charge_target := false
		var approach_targets: Array[int] = []
		for target: int in move.targets:
			closest = minf(closest, Geometry.distance_to_target_at_height(state, origin, target))
		if move.kind == "charge":
			approach_targets.assign(move.targets)
			for target: int in move.targets:
				var distance := Geometry.distance_to_target_at_height(state, model, target)
				final_distance = minf(final_distance, distance)
				if distance < Geometry.distance_to_target_at_height(state, origin, target) - EPSILON: closer_to_charge_target = true
		elif moved:
			# A tie permits either of the equally closest selected units.
			for target: int in move.targets:
				if Geometry.distance_to_target_at_height(state, origin, target) <= closest + EPSILON:
					approach_targets.append(target)
					final_distance = minf(final_distance, Geometry.distance_to_target_at_height(state, model, target))
		var model_error := ""
		if move.kind == "charge" or moved:
			if (move.kind == "charge" and not closer_to_charge_target) or (move.kind != "charge" and final_distance >= closest - EPSILON):
				model_error = "Each required model must finish closer to its contact target."
			else:
				# Charge has two independent duties: an impossible 1-inch approach
				# never waives a still-possible engagement approach.
				var thresholds: Array[float] = [2.0]
				if move.kind == "charge": thresholds.push_front(1.0)
				for required: float in thresholds:
					if final_distance <= required + EPSILON or closest > float(move.maximum) + required + EPSILON: continue
					var proof := Reachability.certify_impossible(state, id, approach_targets, required)
					if not proof.impossible:
						model_error = "Finish within %.0f inches. No obstacle/coherency exception was proved (bounded analysis); reposition or cancel the move." % required
						break
					proof["model"] = id
					proof["gap"] = required
					proofs.append(proof)
		if model_error.is_empty() and move.kind != "charge":
			for enemy: int in move.engaged[id]:
				if Geometry.distance_to_target_at_height(state, model, enemy) > 2.0 + EPSILON:
					model_error = "A model must retain each enemy unit it started engaged with."
					break
		if not model_error.is_empty():
			model_failures.append({"model": id, "reason": model_error})
			if primary_model_error.is_empty():
				primary_model_error = model_error
				primary_model.append(id)
	if not primary_model_error.is_empty():
		if model_failures.size() > 1:
			for failure: Dictionary in model_failures:
				if int(failure.model) == primary_model[0]: continue
				details.append(failure.duplicate(true))
		return primary_model_error
	var engaged := enemies(state, move.squad, 2.0)
	if move.kind == "charge":
		for enemy: int in engaged:
			if enemy not in move.targets: return "A charge cannot finish engaged with an unselected enemy unit."
	if move.kind in ["charge", "consolidate_engaging"]:
		for target: int in move.targets:
			if target not in engaged: return "The squad must finish engaged with every selected target."
	elif engaged.is_empty(): return "The pile-in or ongoing consolidation must finish engaged."
	return VALIDATED

static func _objective_error(state: Dictionary) -> String:
	var move: Dictionary = state.pending_contact
	var objective: Dictionary = state.mission.objectives[move.objective]
	var within := false
	for id: int in move.origins:
		var model: Dictionary = state.units[id]
		within = within or Objectives.in_range(model, objective)
		if float(move.spent.get(id, 0.0)) <= EPSILON: continue
		if Objectives.in_range(model, objective): continue
		var origin: Dictionary = model.duplicate(true)
		origin.position = move.origins[id]
		origin.elevation = float(move.get("origin_elevations", {}).get(id, origin.get("elevation", 0.0)))
		var gap := Objectives.distance(origin, objective)
		var needed := maxf(0.0, gap - (3.0 if objective.kind == "marker" else 0.0))
		if needed <= float(move.maximum) + EPSILON:
			return "Moved models must finish within objective range; an obstacle/coherency exception is not certified for this objective."
		if Objectives.distance(model, objective) >= gap - EPSILON: return "Moved models outside objective range must finish closer to the selected objective."
	if not enemies(state, move.squad, 2.0).is_empty(): return "Objective consolidation must finish unengaged."
	if not within: return "The squad must finish within range of the selected objective."
	return VALIDATED
