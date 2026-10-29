extends RefCounted
## Local movement and Cluster Launcher rules for the source-bounded Corvus Blackstar.
const AbilityCatalog = preload("res://scripts/edition_11/unit_ability_catalog.gd")
const CoreReactions = preload("res://scripts/edition_11/core_reactions.gd")
const ID := "corvus-blackstar-movement-over-v1"
const WINDOW := "corvus-blackstar-cluster-launcher"
const MORTAL_WINDOW := "corvus-blackstar-cluster-launcher-mortal"

static func open_after_normal_move(state: Dictionary, squad: int, move_type: String, paths: Dictionary) -> bool:
	if move_type != "normal" or not state.get("squads", {}).has(squad): return false
	var source_model := -1
	for model: int in state.units:
		if int(state.units[model].get("squad", -1)) == squad and AbilityCatalog.identity(state.units[model]) == "corvus-blackstar" and int(state.units[model].get("wounds", 0)) > 0:
			source_model = model
			break
	if source_model < 0: return false
	var targets: Array[int] = []
	for target: int in state.squads:
		if int(state.squads[target].get("owner", -1)) == int(state.squads[squad].get("owner", -2)) or _living(state, target).is_empty(): continue
		if _moved_over_squad(state, squad, target, paths): targets.append(target)
	if targets.is_empty(): return false
	var previous: Dictionary = state.get("unit_abilities", {}).get("window", {}).duplicate(true)
	state.unit_abilities.window = {"kind": WINDOW, "stage": "target", "owners": [int(state.squads[squad].owner)], "squad": squad, "model": source_model, "eligible_targets": targets, "resume_window": previous}
	state.last_corvus_cluster_launcher = {"stage": "selection", "squad": squad, "model": source_model, "eligible_targets": targets.duplicate(), "rolls": [], "mortal_wounds": 0, "allocations": [], "remaining": 0}
	return true

static func _living(state: Dictionary, squad: int) -> Array[int]:
	var result: Array[int] = []
	for model: int in state.units:
		if int(state.units[model].get("squad", -1)) == squad and int(state.units[model].get("wounds", 0)) > 0 and bool(state.units[model].get("on_battlefield", true)):
			result.append(model)
	return result

static func _moved_over_squad(state: Dictionary, moved_squad: int, target_squad: int, paths: Dictionary) -> bool:
	for model: int in _living(state, moved_squad):
		var corvus_radius := float(state.units[model].get("radius", 60.0 / 25.4))
		for segment_value: Variant in paths.get(model, []):
			if not segment_value is Dictionary: continue
			var origin_value: Variant = segment_value.get("from", Vector2.ZERO)
			var destination_value: Variant = segment_value.get("to", Vector2.ZERO)
			if not origin_value is Vector2 or not destination_value is Vector2 or origin_value.distance_to(destination_value) <= 0.001: continue
			for enemy: int in _living(state, target_squad):
				var enemy_radius := float(state.units[enemy].get("radius", 0.0))
				var closest := Geometry2D.get_closest_point_to_segment(state.units[enemy].position, origin_value, destination_value)
				if closest.distance_to(state.units[enemy].position) <= corvus_radius + enemy_radius + 0.001: return true
	return false

static func choices(state: Dictionary, player: int) -> Array[Dictionary]:
	var window: Dictionary = state.get("unit_abilities", {}).get("window", {})
	if window.get("kind", "") != WINDOW or window.get("owners", []) != [player]: return []
	var squad := int(window.get("squad", -1))
	var model := int(window.get("model", -1))
	match str(window.get("stage", "target")):
		"target":
			var result: Array[Dictionary] = []
			for target_value: Variant in window.get("eligible_targets", []):
				var target := int(target_value)
				if not state.get("squads", {}).has(target) or _living(state, target).is_empty(): continue
				result.append({"label": "Corvus Blackstar %d: use Blackstar Cluster Launcher against %s (6D6; each 4+ causes 1 mortal wound)" % [model, str(state.squads[target].get("name", "enemy unit"))], "action": "corvus-cluster-target", "model": model, "target": target, "value": "target"})
			result.append({"label": "Corvus Blackstar %d: pass Blackstar Cluster Launcher" % model, "action": "corvus-cluster-pass", "model": model, "target": squad, "value": "pass"})
			return result
		"resume":
			return [{"label": "Corvus Blackstar %d: continue after Blackstar Cluster Launcher" % model, "action": "corvus-cluster-continue", "model": model, "target": squad, "value": "continue"}]
	return []

static func apply(state: Dictionary, player: int, selected: Dictionary, roller: Callable) -> Dictionary:
	var window: Dictionary = state.get("unit_abilities", {}).get("window", {})
	if window.get("kind", "") != WINDOW or window.get("owners", []) != [player] or selected not in choices(state, player): return {"error": "No matching Corvus Blackstar Cluster Launcher decision is pending."}
	match str(selected.get("action", "")):
		"corvus-cluster-pass", "corvus-cluster-continue":
			var previous: Dictionary = window.get("resume_window", {}).duplicate(true)
			state.unit_abilities.window = previous
			var record: Dictionary = state.get("last_corvus_cluster_launcher", {}).duplicate(true)
			record.stage = "complete" if selected.action == "corvus-cluster-pass" else "continued"
			state.last_corvus_cluster_launcher = record
			return {"error": "", "message": "Blackstar Cluster Launcher decision closed."}
		"corvus-cluster-target":
			var target := int(selected.get("target", -1))
			if target not in window.get("eligible_targets", []) or _living(state, target).is_empty(): return {"error": "Choose an enemy unit moved over by this Corvus Blackstar."}
			var rolls: Array[int] = []
			var mortal_wounds := 0
			for _die in range(6):
				var die: Variant = roller.call() if roller.is_valid() else randi_range(1, 6)
				if not die is int or die < 1 or die > 6: return {"error": "Blackstar Cluster Launcher dice must be integers from 1 to 6."}
				rolls.append(die)
				if die >= 4: mortal_wounds += 1
			var source_squad := int(window.get("squad", -1))
			var record := {"stage": "rolled", "squad": source_squad, "model": int(window.get("model", -1)), "target": target, "owner": player, "rolls": rolls, "mortal_wounds": mortal_wounds, "remaining": mortal_wounds, "allocations": [], "discarded": 0}
			state.last_corvus_cluster_launcher = record
			var resume := {"kind": WINDOW, "stage": "resume", "owners": [player], "squad": source_squad, "model": int(window.get("model", -1)), "resume_window": window.get("resume_window", {}).duplicate(true)}
			if mortal_wounds > 0:
				state.unit_abilities.window = {"kind": MORTAL_WINDOW, "owners": [int(state.squads[target].get("owner", -1))], "target": target, "resume_window": resume}
			else:
				state.unit_abilities.window = resume
			return {"error": "", "message": "Blackstar Cluster Launcher rolled %s: %d mortal wound(s)." % [str(rolls), mortal_wounds]}
	return {"error": "Unsupported Blackstar Cluster Launcher decision."}
