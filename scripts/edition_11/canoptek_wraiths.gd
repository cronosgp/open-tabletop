extends RefCounted
## Source-bounded Canoptek Wraiths (000000546): Wraith Form.
const AbilityCatalog = preload("res://scripts/edition_11/unit_ability_catalog.gd")

const IDENTITY := "canoptek-wraiths"
const WINDOW := "canoptek-wraith-form"
const MORTAL_WINDOW := "canoptek-wraith-form-mortal"

static func _living(state: Dictionary, squad: int) -> Array[int]:
	var result: Array[int] = []
	for model: int in state.get("units", {}):
		var u: Dictionary = state.units[model]
		if int(u.get("squad", -1)) == squad and int(u.get("wounds", 0)) > 0 and bool(u.get("on_battlefield", true)):
			result.append(model)
	result.sort()
	return result

static func _moved_over_squad(state: Dictionary, moved_squad: int, target_squad: int, paths: Dictionary) -> bool:
	for model: int in _living(state, moved_squad):
		var wraith_radius := float(state.units[model].get("radius", 50.0 / 50.8))
		for segment_value: Variant in paths.get(model, []):
			if not segment_value is Dictionary: continue
			var origin_value: Variant = segment_value.get("from", Vector2.ZERO)
			var destination_value: Variant = segment_value.get("to", Vector2.ZERO)
			if not origin_value is Vector2 or not destination_value is Vector2 or origin_value.distance_to(destination_value) <= 0.001: continue
			for enemy: int in _living(state, target_squad):
				var enemy_radius := float(state.units[enemy].get("radius", 0.0))
				var closest := Geometry2D.get_closest_point_to_segment(state.units[enemy].position, origin_value, destination_value)
				if closest.distance_to(state.units[enemy].position) <= wraith_radius + enemy_radius + 0.001:
					return true
	return false

## Wraith Form:
## Each time this unit ends a Normal move, you can select one enemy unit it moved over
## during that move and roll one D6 for each model in this unit: for each 4+,
## that enemy unit suffers 1 mortal wound.
static func open_after_normal_move(state: Dictionary, squad: int, move_type: String, paths: Dictionary) -> bool:
	if move_type != "normal" or not state.get("squads", {}).has(squad): return false
	var living := _living(state, squad)
	var source_model := -1
	for model: int in living:
		if AbilityCatalog.identity(state.units[model]) == IDENTITY:
			source_model = model
			break
	if source_model < 0: return false
	var targets: Array[int] = []
	for target: int in state.squads:
		if int(state.squads[target].get("owner", -1)) == int(state.squads[squad].get("owner", -2)) or _living(state, target).is_empty(): continue
		if _moved_over_squad(state, squad, target, paths): targets.append(target)
	if targets.is_empty(): return false
	var previous: Dictionary = state.get("unit_abilities", {}).get("window", {}).duplicate(true)
	state.unit_abilities.window = {
		"kind": WINDOW,
		"stage": "target",
		"owners": [int(state.squads[squad].owner)],
		"squad": squad,
		"model": source_model,
		"eligible_targets": targets,
		"resume_window": previous
	}
	state.last_wraith_form = {
		"stage": "selection",
		"squad": squad,
		"model": source_model,
		"eligible_targets": targets.duplicate(),
		"rolls": [],
		"mortal_wounds": 0,
		"allocations": [],
		"remaining": 0
	}
	return true

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
				result.append({
					"label": "Wraith Form %d: roll %dD6 against %s (4+ = 1 mortal wound)" % [squad, _living(state, squad).size(), str(state.squads[target].get("name", "enemy unit"))],
					"action": "wraith-form-target",
					"model": model,
					"target": target,
					"value": "target"
				})
			result.append({
				"label": "Wraith Form %d: pass" % squad,
				"action": "wraith-form-pass",
				"model": model,
				"target": squad,
				"value": "pass"
			})
			return result
		"resume":
			return [{
				"label": "Wraith Form %d: continue" % squad,
				"action": "wraith-form-continue",
				"model": model,
				"target": squad,
				"value": "continue"
			}]
	return []

static func apply(state: Dictionary, player: int, selected: Dictionary, roller: Callable) -> Dictionary:
	var window: Dictionary = state.get("unit_abilities", {}).get("window", {})
	if window.get("kind", "") != WINDOW or window.get("owners", []) != [player] or selected not in choices(state, player):
		return {"error": "No matching Wraith Form decision is pending."}
	match str(selected.get("action", "")):
		"wraith-form-pass", "wraith-form-continue":
			state.unit_abilities.window = window.get("resume_window", {}).duplicate(true)
			var record: Dictionary = state.get("last_wraith_form", {}).duplicate(true)
			record.stage = "complete" if selected.action == "wraith-form-pass" else "continued"
			state.last_wraith_form = record
			return {"error": "", "message": "Wraith Form decision closed."}
		"wraith-form-target":
			var target := int(selected.get("target", -1))
			if target not in window.get("eligible_targets", []) or _living(state, target).is_empty():
				return {"error": "Choose an enemy unit moved over by Canoptek Wraiths."}
			var source_squad := int(window.get("squad", -1))
			var die_count := _living(state, source_squad).size()
			var rolls: Array[int] = []
			var mortal_wounds := 0
			for _die in range(die_count):
				var die: Variant = roller.call() if roller.is_valid() else randi_range(1, 6)
				if not die is int or die < 1 or die > 6:
					return {"error": "Wraith Form dice must be integers from 1 to 6."}
				rolls.append(die)
				if die >= 4: mortal_wounds += 1
			state.last_wraith_form = {
				"stage": "rolled",
				"squad": source_squad,
				"model": int(window.get("model", -1)),
				"target": target,
				"owner": player,
				"rolls": rolls,
				"mortal_wounds": mortal_wounds,
				"remaining": mortal_wounds,
				"allocations": [],
				"discarded": 0
			}
			var resume := {
				"kind": WINDOW,
				"stage": "resume",
				"owners": [player],
				"squad": source_squad,
				"model": int(window.get("model", -1)),
				"resume_window": window.get("resume_window", {}).duplicate(true)
			}
			if mortal_wounds > 0:
				state.unit_abilities.window = {
					"kind": MORTAL_WINDOW,
					"owners": [int(state.squads[target].get("owner", -1))],
					"target": target,
					"resume_window": resume
				}
			else:
				state.unit_abilities.window = resume
			return {"error": "", "message": "Wraith Form rolled %s: %d mortal wound(s)." % [str(rolls), mortal_wounds]}
	return {"error": "Unsupported Wraith Form decision."}
