extends RefCounted
## Bounded 11e Inner Circle Task Force detachment rule.
const Objectives = preload("res://scripts/edition_11/objectives.gd")
const Marines = preload("res://scripts/edition_11/oath_of_moment.gd")
const UnitAbilities = preload("res://scripts/edition_11/unit_abilities.gd")
const PendingDecision = preload("res://scripts/edition_11/pending_decision.gd")
const Capabilities = preload("res://scripts/edition_11/capabilities.gd")
const ID := "inner-circle-vowed-target-e11-v1"
const DETACHMENT := "inner-circle-task-force"
const SOURCE := "https://wahapedia.ru/wh40k11ed/factions/space-marines/"


static func enable(state: Dictionary) -> void:
	var owners: Array[int] = []
	for player in [1, 2]:
		if not Marines.marine_army(state, player) or _detachment_for(state, player) != DETACHMENT:
			continue
		var chapters: Dictionary = state.get("marine_chapters", {})
		if str(chapters.get(player, chapters.get(str(player), ""))) != "DARK ANGELS":
			continue
		owners.append(player)
	state.vowed_target = {"implementation": ID, "owners": owners, "objectives": {}, "selected_turn": {}}
	if not owners.is_empty(): Capabilities.admit(state, "vowed-target", ID)


static func enabled(state: Dictionary, player: int = -1) -> bool:
	if state.get("vowed_target", {}).get("implementation", "") != ID:
		return false
	var owners: Array = state.vowed_target.get("owners", [])
	if player >= 0 and player not in owners:
		return false
	if player >= 0:
		var chapters: Dictionary = state.get("marine_chapters", {})
		return _detachment_for(state, player) == DETACHMENT and str(chapters.get(player, chapters.get(str(player), ""))) == "DARK ANGELS"
	return not owners.is_empty()


static func objective_indices(state: Dictionary) -> Array[int]:
	var result: Array[int] = []
	var mission: Dictionary = state.get("mission", {})
	var raw_objectives: Variant = mission.get("objectives", [])
	if not raw_objectives is Array:
		return result
	for index in range(raw_objectives.size()):
		if raw_objectives[index] is Dictionary:
			result.append(index)
	return result


static func start_command(state: Dictionary) -> void:
	var player := int(state.get("active", -1))
	if not enabled(state, player):
		return
	state.vowed_target.objectives.erase(player)


static func needs_choice(state: Dictionary) -> bool:
	var player := int(state.get("active", -1))
	return enabled(state, player) and int(state.get("test_winner", 0)) == 0 and str(state.get("phase", "")) == "command" and int(state.vowed_target.get("selected_turn", {}).get(player, -1)) != int(state.get("turn", -2)) and not objective_indices(state).is_empty()


static func pending_decision(state: Dictionary) -> Dictionary:
	if not needs_choice(state):
		return {}
	var player := int(state.active)
	var options: Array[Dictionary] = []
	var objectives: Array = state.get("mission", {}).get("objectives", [])
	for index in objective_indices(state):
		var objective: Dictionary = objectives[index]
		options.append({"label": "Vowed Target: %s" % str(objective.get("name", "Objective %d" % (index + 1))), "action": "vowed-target", "target": index})
	options.append({"label": "Do not select a Vowed objective this Command phase", "action": "vowed-target-pass", "target": -1})
	return PendingDecision.create(state, "vowed-target", "command-phase:vowed-target", player, options, false)


static func choice_error(state: Dictionary, player: int, objective_index: int, revision: int) -> String:
	if not needs_choice(state):
		return "No Vowed Target objective selection is pending."
	if revision != int(state.get("revision", -1)):
		return "State changed; synchronize before selecting the Vowed objective."
	if player != int(state.get("active", -1)):
		return "Only the active Dark Angels player selects the Vowed objective."
	if objective_index != -1 and objective_index not in objective_indices(state):
		return "Select an objective currently on the battlefield, or skip Vowed Target."
	return ""


static func select_objective(state: Dictionary, player: int, objective_index: int) -> void:
	state.vowed_target.selected_turn[player] = int(state.get("turn", 0))
	if objective_index == -1:
		state.vowed_target.objectives.erase(player)
	else:
		state.vowed_target.objectives[player] = objective_index


static func selected_objective(state: Dictionary, player: int) -> int:
	if not enabled(state, player):
		return -1
	var index := int(state.vowed_target.get("objectives", {}).get(player, -1))
	return index if index in objective_indices(state) else -1


static func owners_of_objective(state: Dictionary, objective_index: int) -> Array[int]:
	var result: Array[int] = []
	for player in [1, 2]:
		if selected_objective(state, player) == objective_index:
			result.append(player)
	return result


static func bonus(state: Dictionary, attacker_squad: int, target_squad: int) -> bool:
	if not state.get("squads", {}).has(attacker_squad) or not state.get("squads", {}).has(target_squad):
		return false
	var player := int(state.squads[attacker_squad].get("owner", -1))
	if int(state.squads[target_squad].get("owner", -1)) == player or not enabled(state, player):
		return false
	if not _deathwing_infantry(state, attacker_squad):
		return false
	return target_in_vowed_range(state, player, target_squad)


static func target_in_vowed_range(state: Dictionary, player: int, target_squad: int) -> bool:
	if not state.get("squads", {}).has(target_squad) or int(state.squads[target_squad].get("owner", -1)) == player or not enabled(state, player):
		return false
	var objective_index := selected_objective(state, player)
	if objective_index < 0:
		return false
	var objective: Dictionary = state.mission.objectives[objective_index]
	for model: int in state.units:
		var unit: Dictionary = state.units[model]
		if int(unit.get("squad", -1)) == target_squad and Objectives.in_range(unit, objective):
			return true
	return false


static func _deathwing_infantry(state: Dictionary, squad: int) -> bool:
	if not state.get("squads", {}).has(squad):
		return false
	# Attached units use the combined keywords of their living models, matching
	# the shared unit-keyword query used by the rest of the combat rules.
	return (
		UnitAbilities.has_target_keyword(state, squad, "ADEPTUS ASTARTES")
		and UnitAbilities.has_target_keyword(state, squad, "DEATHWING")
		and UnitAbilities.has_target_keyword(state, squad, "INFANTRY")
	)


static func _detachment_for(state: Dictionary, player: int) -> String:
	var doctrines: Dictionary = state.get("combat_doctrines", {})
	var assignments: Dictionary = doctrines.get("detachments", {})
	return str(assignments.get(player, assignments.get(str(player), doctrines.get("detachment", "none"))))
