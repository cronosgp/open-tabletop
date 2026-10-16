extends RefCounted
## Editable contact moves on the flat circular-base exercise board.
const Geometry = preload("res://scripts/edition_11/contact_movement.gd")
const Reachability = preload("res://scripts/edition_11/contact_reachability.gd")
const Objectives = preload("res://scripts/edition_11/objectives.gd")
const EPSILON := 0.001
const VALIDATED := "contact_validation_complete"

static func enemies(state: Dictionary, squad: int, maximum: float = INF) -> Array[int]:
	var targets: Array[int] = []
	for enemy: int in state.squads:
		if state.squads[enemy].owner == state.squads[squad].owner: continue
		for id: int in Geometry.alive(state, squad):
			if Geometry.distance_to_target(state, state.units[id], enemy) <= maximum + EPSILON:
				targets.append(enemy)
				break
	return targets

static func draft(state: Dictionary, squad: int, kind: String, targets: Array[int], maximum: float) -> Dictionary:
	var origins: Dictionary = {}
	var engaged: Dictionary = {}
	var locked: Dictionary = {}
	for id: int in Geometry.alive(state, squad):
		origins[id] = state.units[id].position
		engaged[id] = []
		for enemy: int in enemies(state, squad):
			var distance := Geometry.distance_to_target(state, state.units[id], enemy)
			if distance <= 2.0 + EPSILON: engaged[id].append(enemy)
			if distance <= EPSILON and kind != "charge": locked[id] = true
	return {"squad": squad, "kind": kind, "targets": targets.duplicate(), "maximum": maximum, "origins": origins, "spent": {}, "engaged": engaged, "locked": locked}

static func remaining(state: Dictionary, model: int) -> float:
	var move: Dictionary = state.get("pending_contact", {})
	if move.is_empty() or not move.origins.has(model) or move.locked.has(model): return 0.0
	return maxf(0.0, float(move.maximum) - float(move.spent.get(model, 0.0)))

static func validate_segment(state: Dictionary, model: int, destination: Vector2) -> String:
	var move: Dictionary = state.get("pending_contact", {})
	if move.is_empty() or not move.origins.has(model) or state.units[model].wounds <= 0: return "Select a living model in the moving squad."
	if not destination.is_finite(): return "Invalid destination."
	if move.locked.has(model): return "Models in base contact cannot move during pile-in or ongoing consolidation."
	if state.units[model].position.distance_to(destination) <= EPSILON: return "Choose a different destination."
	if not Geometry.clear_path(state, model, destination, remaining(state, model)): return "Contact movement exceeds its budget or crosses terrain, an enemy base, or the board edge."
	for other: int in state.units:
		if other == model or state.units[other].wounds <= 0: continue
		if destination.distance_to(state.units[other].position) < float(state.units[model].radius) + float(state.units[other].radius) - EPSILON:
			return "Bases cannot overlap at the destination."
	return ""

static func restore(state: Dictionary) -> void:
	for id: int in state.pending_contact.origins:
		state.units[id].position = state.pending_contact.origins[id]
	state.pending_contact.spent = {}

static func final_error(state: Dictionary) -> String:
	return final_validation(state).error

static func final_validation(state: Dictionary) -> Dictionary:
	var proofs: Array[Dictionary] = []
	var result := _final_error(state, proofs)
	# GDScript runtime failures can return the default empty String. An empty
	# result must not accidentally grant a contact move or waive an approach.
	var error := "" if result == VALIDATED else result
	if result.is_empty(): error = "Contact validation did not complete; the move was not accepted."
	return {"error": error, "proofs": proofs}

static func _final_error(state: Dictionary, proofs: Array[Dictionary]) -> String:
	var move: Dictionary = state.pending_contact
	if not Geometry.coherent(state, move.squad): return "The moving squad must finish as one coherent group."
	if move.kind == "consolidate_objective": return _objective_error(state)
	for target: int in move.targets:
		if Geometry.alive(state, target).is_empty(): return "A selected contact target is no longer on the board."
	for id: int in move.origins:
		var model: Dictionary = state.units[id]
		var origin: Dictionary = model.duplicate(true)
		origin.position = move.origins[id]
		var moved: bool = float(move.spent.get(id, 0.0)) > EPSILON
		var closest := INF
		var final_distance := INF
		var closer_to_charge_target := false
		var approach_targets: Array[int] = []
		for target: int in move.targets:
			closest = minf(closest, Geometry.distance_to_target(state, origin, target))
		if move.kind == "charge":
			approach_targets.assign(move.targets)
			for target: int in move.targets:
				var distance := Geometry.distance_to_target(state, model, target)
				final_distance = minf(final_distance, distance)
				if distance < Geometry.distance_to_target(state, origin, target) - EPSILON: closer_to_charge_target = true
		elif moved:
			# A tie permits either of the equally closest selected units.
			for target: int in move.targets:
				if Geometry.distance_to_target(state, origin, target) <= closest + EPSILON:
					approach_targets.append(target)
					final_distance = minf(final_distance, Geometry.distance_to_target(state, model, target))
		if move.kind == "charge" or moved:
			if (move.kind == "charge" and not closer_to_charge_target) or (move.kind != "charge" and final_distance >= closest - EPSILON): return "Each required model must finish closer to its contact target."
			# Charge has two independent duties: an impossible 1-inch approach
			# never waives a still-possible engagement approach.
			var thresholds: Array[float] = [2.0]
			if move.kind == "charge": thresholds.push_front(1.0)
			for required: float in thresholds:
				if final_distance <= required + EPSILON or closest > float(move.maximum) + required + EPSILON: continue
				var proof := Reachability.certify_impossible(state, id, approach_targets, required)
				if not proof.impossible:
					return "Finish within %.0f inches. No obstacle/coherency exception was proved (bounded analysis); reposition or cancel the move." % required
				proof["model"] = id
				proof["gap"] = required
				proofs.append(proof)
		if move.kind != "charge":
			for enemy: int in move.engaged[id]:
				if Geometry.distance_to_target(state, model, enemy) > 2.0 + EPSILON: return "A model must retain each enemy unit it started engaged with."
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
		var gap := Objectives.distance(origin, objective)
		var needed := maxf(0.0, gap - (3.0 if objective.kind == "marker" else 0.0))
		if needed <= float(move.maximum) + EPSILON:
			return "Moved models must finish within objective range; an obstacle/coherency exception is not certified for this objective."
		if Objectives.distance(model, objective) >= gap - EPSILON: return "Moved models outside objective range must finish closer to the selected objective."
	if not enemies(state, move.squad, 2.0).is_empty(): return "Objective consolidation must finish unengaged."
	if not within: return "The squad must finish within range of the selected objective."
	return VALIDATED
