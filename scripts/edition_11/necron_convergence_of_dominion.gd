extends RefCounted

const Geometry = preload("res://scripts/edition_11/contact_movement.gd")
const AbilityCatalog = preload("res://scripts/edition_11/unit_ability_catalog.gd")
const Fortifications = preload("res://scripts/edition_11/fortification_rules.gd")
const REANIMATION_NODES_RANGE := 6.0
const SETUP_RANGE := 12.0
const EPSILON := 0.001
const IDENTITY := "convergence-of-dominion"

static func _has_keyword(unit: Dictionary, keyword: String) -> bool:
	for value: Variant in unit.get("keywords", []):
		if str(value).strip_edges().to_upper() == keyword.to_upper(): return true
	return false

static func _identity(unit: Dictionary) -> String:
	return str(unit.get("definition_id", "")).get_slice(":", 3)

static func _unit_on_battlefield(state: Dictionary, squad: int) -> bool:
	if not state.get("squads", {}).has(squad) or state.get("unit_abilities", {}).get("reserves", {}).has(squad): return false
	var models := Geometry.alive(state, squad)
	if models.is_empty(): return false
	for model: int in models:
		var unit: Dictionary = state.units[model]
		if not bool(unit.get("on_battlefield", true)) or int(unit.get("embarked_transport", -1)) >= 0: return false
	return true

static func _convergence_models(state: Dictionary, squad: int) -> Array[int]:
	var result: Array[int] = []
	for model: int in Geometry.alive(state, squad):
		if _identity(state.units[model]) == IDENTITY: result.append(model)
	result.sort()
	return result

static func reanimation_nodes_grants(state: Dictionary, target_squad: int) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if not AbilityCatalog.enabled(state) or not _unit_on_battlefield(state, target_squad): return result
	var target_owner := int(state.squads[target_squad].get("owner", -1))
	for target_model: int in Geometry.alive(state, target_squad):
		var target: Dictionary = state.units[target_model]
		if not _has_keyword(target, "NECRONS") or not _has_keyword(target, "INFANTRY"): return result
	for source_squad: int in state.get("squads", {}):
		if int(state.squads[source_squad].get("owner", -2)) != target_owner: continue
		for source_model: int in AbilityCatalog.sources(state, source_squad, "reanimation-nodes"):
			if not _unit_on_battlefield(state, source_squad): continue
			if Geometry.distance_to_target(state, state.units[source_model], target_squad) > REANIMATION_NODES_RANGE + EPSILON: continue
			return [{"target": 6, "against": "any"}]
	return result

static func _wholly_within_other(first: Dictionary, second: Dictionary) -> bool:
	return first.position.distance_to(second.position) + float(first.get("radius", 0.0)) <= float(second.get("radius", 0.0)) + SETUP_RANGE + EPSILON

static func uses_separated_setup(state: Dictionary, squad: int) -> bool:
	return AbilityCatalog.enabled(state) and not AbilityCatalog.sources(state, squad, "convergence-deployment").is_empty() and not _convergence_models(state, squad).is_empty()

static func setup_error(state: Dictionary, squad: int) -> String:
	if not AbilityCatalog.enabled(state) or AbilityCatalog.sources(state, squad, "convergence-deployment").is_empty(): return ""
	var models := _convergence_models(state, squad)
	if models.is_empty(): return ""
	if models.size() == 1: return "The local Convergence deployment text requires every Starstele to be wholly within 12 inches of one other model from its unit. It does not resolve a one-model unit, so that composition stays unresolved."
	for model: int in models:
		var paired := false
		for other: int in models:
			if other == model: continue
			if _wholly_within_other(state.units[model], state.units[other]): paired = true
		if not paired: return "Each Convergence Starstele must be set up wholly within 12 inches of one other Starstele from its unit."
	return ""

static func split_after_setup(state: Dictionary, squad: int) -> void:
	if not setup_error(state, squad).is_empty(): return
	var models := _convergence_models(state, squad)
	if models.size() < 2 or not state.get("squads", {}).has(squad): return
	var original: Dictionary = state.squads[squad]
	var owner := int(original.get("owner", -1))
	var base_name := str(original.get("name", "Convergence of Dominion"))
	var next_squad := 0
	for existing: int in state.squads: next_squad = maxi(next_squad, existing)
	var created: Array[int] = [squad]
	original.name = "%s Starstele %d" % [base_name, models[0]]
	original.starting_strength = 1
	original.convergence_split = true
	original.attached = false
	for index in range(1, models.size()):
		next_squad += 1
		var model: int = models[index]
		var separated: Dictionary = original.duplicate(true)
		separated.name = "%s Starstele %d" % [base_name, model]
		separated.starting_strength = 1
		separated.training_cost = 0
		separated.convergence_split = true
		separated.attached = false
		separated.components = [{"squad": next_squad, "role": "bodyguard", "name": separated.name, "starting_strength": 1}]
		state.units[model].squad = next_squad
		state.squads[next_squad] = separated
		created.append(next_squad)
		var deployment: Dictionary = state.get("deployment", {})
		if not deployment.is_empty() and not deployment.get("committed", []).has(next_squad): deployment.committed.append(next_squad)
	original.components = [{"squad": squad, "role": "bodyguard", "name": original.name, "starting_strength": 1}]
	state.squads[squad] = original
	if not state.has("unit_abilities") or typeof(state.unit_abilities) != TYPE_DICTIONARY: state.unit_abilities = {}
	if not state.unit_abilities.has("convergence_splits"): state.unit_abilities.convergence_splits = {}
	state.unit_abilities.convergence_splits[str(squad)] = {"owner": owner, "squads": created.duplicate(), "models": models.duplicate()}

static func ancient_cover(state: Dictionary, attacking_squad: int, target_model: int) -> bool:
	if not AbilityCatalog.enabled(state) or not state.get("units", {}).has(target_model) or not state.get("squads", {}).has(attacking_squad): return false
	var attackers := Geometry.alive(state, attacking_squad)
	if attackers.is_empty() or int(state.units[target_model].get("wounds", 0)) <= 0: return false
	var target: Dictionary = state.units[target_model]
	for source_squad: int in state.squads:
		if source_squad == attacking_squad: continue
		var blockers := AbilityCatalog.sources(state, source_squad, "ancient-cover")
		if blockers.is_empty() or not _unit_on_battlefield(state, source_squad): continue
		var blocks_every := true
		for attacker_id: int in attackers:
			var blocked := false
			for blocker_id: int in blockers:
				if Fortifications.blocks_line_of_sight(state.units[attacker_id], target, state.units[blocker_id]):
					blocked = true
					break
			if not blocked:
				blocks_every = false
				break
		if blocks_every: return true
	return false

static func _squads_engaged(state: Dictionary, first_squad: int, second_squad: int) -> bool:
	for first_id: int in Geometry.alive(state, first_squad):
		for second_id: int in Geometry.alive(state, second_squad):
			if Geometry.within_engagement(state.units[first_id], state.units[second_id]): return true
	return false

static func _army_has_fortification_rule(state: Dictionary, army_owner: int) -> bool:
	for source_squad: int in state.get("squads", {}):
		if int(state.squads[source_squad].get("owner", -2)) != army_owner: continue
		if not AbilityCatalog.sources(state, source_squad, "convergence-fortification").is_empty() and _unit_on_battlefield(state, source_squad): return true
	return false

static func engaged_only_with_army_fortifications(state: Dictionary, target_squad: int, army_owner: int) -> bool:
	if not AbilityCatalog.enabled(state) or not state.get("squads", {}).has(target_squad) or not _army_has_fortification_rule(state, army_owner): return false
	var found := false
	for other_squad: int in state.squads:
		if other_squad == target_squad or not _squads_engaged(state, target_squad, other_squad): continue
		var members := Geometry.alive(state, other_squad)
		if members.is_empty(): continue
		if int(state.squads[other_squad].get("owner", -2)) != army_owner or not _has_keyword(state.units[members[0]], "FORTIFICATION"): return false
		found = true
	return found

static func fortification_ranged_exception(state: Dictionary, target_squad: int, shooter_owner: int) -> bool:
	return engaged_only_with_army_fortifications(state, target_squad, shooter_owner)

static func fortification_hit_penalty(state: Dictionary, target_squad: int, shooter_owner: int, weapon: Dictionary) -> bool:
	if not fortification_ranged_exception(state, target_squad, shooter_owner): return false
	var keywords: Dictionary = weapon.get("keywords", {})
	return not bool(keywords.get("close-quarters", false)) and not bool(keywords.get("pistol", false))

static func battle_shocked_ordered_retreat_allowed(state: Dictionary, fleeing_squad: int) -> bool:
	if not state.get("squads", {}).has(fleeing_squad) or not bool(state.squads[fleeing_squad].get("battle_shocked", false)): return false
	return engaged_only_with_army_fortifications(state, fleeing_squad, 3 - int(state.squads[fleeing_squad].get("owner", -1)))

static func _moves_over(start: Vector2, finish: Vector2, point: Vector2, clearance: float) -> bool:
	var delta := finish - start
	var length_squared := delta.length_squared()
	if length_squared <= EPSILON: return false
	var along := (point - start).dot(delta) / length_squared
	if along <= EPSILON: return false
	along = minf(along, 1.0)
	return point.distance_to(start + delta * along) < clearance - EPSILON

static func _segment_crosses_enemy(state: Dictionary, mover: Dictionary, finish: Vector2, finish_elevation: float) -> bool:
	for other_id: int in state.get("units", {}):
		var other: Dictionary = state.units[other_id]
		if int(other.get("owner", -1)) == int(mover.get("owner", -2)) or int(other.get("wounds", 0)) <= 0 or not bool(other.get("on_battlefield", true)): continue
		if absf(finish_elevation - float(other.get("elevation", 0.0))) > 5.0 + EPSILON and absf(float(mover.get("elevation", 0.0)) - float(other.get("elevation", 0.0))) > 5.0 + EPSILON: continue
		var clearance := float(mover.get("radius", 0.0)) + float(other.get("radius", 0.0))
		if _moves_over(mover.position, finish, other.position, clearance): return true
	return false

static func crossing_models(state: Dictionary, squad: int) -> Array[int]:
	var result: Array[int] = []
	var pending: Dictionary = state.get("pending_move", {})
	var paths: Dictionary = pending.get("paths", {})
	for model: int in Geometry.alive(state, squad):
		var steps: Array = paths.get(model, [])
		for step: Variant in steps:
			if not step is Dictionary: continue
			var finish: Vector2 = step.get("to", state.units[model].position)
			var projected: Dictionary = state.units[model].duplicate(true)
			projected.position = step.get("from", projected.position)
			projected.elevation = float(step.get("from_elevation", projected.get("elevation", 0.0)))
			if _segment_crosses_enemy(state, projected, finish, float(step.get("to_elevation", projected.elevation))):
				result.append(model)
				break
	result.sort()
	return result
