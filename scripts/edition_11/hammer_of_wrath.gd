extends RefCounted
## Hammer of Wrath: post-charge target choice and mortal-wound resolution.
const Geometry = preload("res://scripts/edition_11/contact_movement.gd")
const Abilities = preload("res://scripts/edition_11/unit_abilities.gd")
const Reactions = preload("res://scripts/edition_11/core_reactions.gd")
const ID := "hammer-of-wrath"
const MORTAL_WINDOW := "hammer-of-wrath-mortal"

static func engaged_models(state: Dictionary, squad: int, target: int) -> Array[int]:
	var result: Array[int] = []
	for model: int in Geometry.alive(state, squad):
		for enemy: int in Geometry.alive(state, target):
			if Geometry.edge(state.units[model], state.units[enemy]) <= 2.001:
				result.append(model)
				break
	return result

static func eligible_targets(state: Dictionary, squad: int) -> Array[int]:
	var result: Array[int] = []
	if not Abilities.has(state, squad, ID): return result
	for target: int in state.squads:
		if state.squads[target].owner == state.squads[squad].owner: continue
		if not Geometry.alive(state, target).is_empty() and not engaged_models(state, squad, target).is_empty(): result.append(target)
	result.sort()
	return result

static func charge_completed(state: Dictionary, player: int, squad: int) -> bool:
	if state.squads[squad].owner != player: return false
	var targets := eligible_targets(state, squad)
	if targets.is_empty(): return false
	state.unit_abilities.window = {"kind": ID, "owners": [player], "squad": squad, "targets": targets}
	return true

static func choices(state: Dictionary, player: int) -> Array:
	var window: Dictionary = state.get("unit_abilities", {}).get("window", {})
	if window.get("kind", "") != ID or window.get("owners", []).is_empty() or window.owners[0] != player: return []
	var result: Array = [{"label": "Skip Hammer of Wrath", "action": "hammer-of-wrath-pass", "model": -1, "target": -1, "value": "pass"}]
	for target: int in window.get("targets", []):
		var count := engaged_models(state, int(window.squad), target).size()
		if count > 0: result.append({"label": "Hammer of Wrath: resolve against %s (%d engaged models)" % [state.squads[target].name, count], "action": ID, "model": -1, "target": target, "value": ID})
	return result

static func skip(state: Dictionary, player: int, selected: Dictionary) -> String:
	if selected not in choices(state, player) or selected.action != "hammer-of-wrath-pass": return "Choose a Hammer of Wrath target or skip the ability."
	state.unit_abilities.window = {}
	return ""

static func resolve(state: Dictionary, player: int, selected: Dictionary, roller: Callable) -> Dictionary:
	if selected not in choices(state, player): return {"error": "Choose an enemy unit currently engaged with this charging unit."}
	if not roller.is_valid(): return {"error": "Hammer of Wrath requires the host's D6 provider."}
	var window: Dictionary = state.unit_abilities.window
	var squad: int = int(window.squad)
	var target: int = int(selected.target)
	var models := engaged_models(state, squad, target)
	if models.is_empty(): return {"error": "No living model from this unit is engaged with the selected enemy."}
	var rolls: Array[int] = []
	var mortal_wounds := 0
	for _model: int in models:
		var die: Variant = roller.call()
		if not die is int or die < 1 or die > 6: return {"error": "Hammer of Wrath dice must be integers from 1 to 6."}
		rolls.append(die)
		if die >= 4: mortal_wounds += 1
	state.last_hammer_of_wrath = {"squad": squad, "target": target, "models": models.duplicate(), "rolls": rolls, "mortal_wounds": mortal_wounds, "remaining": mortal_wounds, "allocations": [], "discarded": 0}
	if mortal_wounds == 0:
		state.unit_abilities.window = {}
	else:
		state.unit_abilities.window = {"kind": MORTAL_WINDOW, "owners": [state.squads[target].owner], "target": target}
	return {"error": ""}

