extends RefCounted
## Hammer of Wrath: post-charge target choice and mortal-wound resolution.
const Geometry = preload("res://scripts/edition_11/contact_movement.gd")
const Abilities = preload("res://scripts/edition_11/unit_abilities.gd")
const Reactions = preload("res://scripts/edition_11/core_reactions.gd")
const DetachmentStratagems = preload("res://scripts/edition_11/detachment_stratagems.gd")
const ID := "hammer-of-wrath"
const MORTAL_WINDOW := "hammer-of-wrath-mortal"
const ARMOURED_IMPACT_MORTAL := "gravis-armoured-impact-mortal"

static func engaged_models(state: Dictionary, squad: int, target: int) -> Array[int]:
	var result: Array[int] = []
	for model: int in Geometry.alive(state, squad):
		for enemy: int in Geometry.alive(state, target):
			if Geometry.within_engagement(state.units[model], state.units[enemy]):
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
	if not state.has("unit_abilities") or not state.squads.has(squad) or state.squads[squad].owner != player: return false
	var ability_targets := eligible_targets(state, squad)
	state.unit_abilities.window = {"kind": ID, "owners": [player], "squad": squad, "targets": ability_targets, "armoured_impact_targets": [], "wrath_targets": []}
	var impact_targets: Array[int] = []
	if DetachmentStratagems.gravis_unit(state, squad):
		for target: int in state.squads:
			if state.squads[target].owner == player or engaged_models(state, squad, target).is_empty(): continue
			if DetachmentStratagems.error(state, player, squad, DetachmentStratagems.GRAVIS_LINEBREAKER_ARMOURED_IMPACT, -1, -1, target).is_empty(): impact_targets.append(target)
	var wrath_targets: Array[int] = []
	if DetachmentStratagems.inner_circle_deathwing_unit(state, player, squad):
		for target: int in state.squads:
			if state.squads[target].owner == player or engaged_models(state, squad, target).is_empty(): continue
			if DetachmentStratagems.error(state, player, squad, DetachmentStratagems.INNER_CIRCLE_WRATH_OF_THE_LION, -1, -1, target).is_empty(): wrath_targets.append(target)
	if ability_targets.is_empty() and impact_targets.is_empty() and wrath_targets.is_empty():
		state.unit_abilities.window = {}
		return false
	state.unit_abilities.window.armoured_impact_targets = impact_targets
	state.unit_abilities.window.wrath_targets = wrath_targets
	return true

static func choices(state: Dictionary, player: int) -> Array:
	var window: Dictionary = state.get("unit_abilities", {}).get("window", {})
	if window.get("kind", "") != ID or window.get("owners", []).is_empty() or window.owners[0] != player: return []
	var result: Array = [{"label": "Skip optional post-charge effects", "action": "hammer-of-wrath-pass", "model": -1, "target": -1, "value": "pass"}]
	for target: int in window.get("targets", []):
		var count := engaged_models(state, int(window.squad), target).size()
		if count > 0: result.append({"label": "Hammer of Wrath: resolve against %s (%d engaged models)" % [state.squads[target].name, count], "action": ID, "model": -1, "target": target, "value": ID})
	for target: int in window.get("armoured_impact_targets", []):
		var count := engaged_models(state, int(window.squad), target).size()
		if count > 0:
			var cost := maxi(0, 1 - Abilities.discount(state, player, int(window.squad)))
			result.append({"label": "Armoured Impact: roll %d D6 against %s (%d CP)" % [count, state.squads[target].name, cost], "action": "gravis-armoured-impact", "model": -1, "target": int(window.squad), "value": DetachmentStratagems.GRAVIS_LINEBREAKER_ARMOURED_IMPACT, "details": {"enemy_squad": target}})
	for target: int in window.get("wrath_targets", []):
		var count := engaged_models(state, int(window.squad), target).size()
		if count > 0:
			var cost := maxi(0, 1 - Abilities.discount(state, player, int(window.squad)))
			result.append({"label": "Wrath of the Lion: roll %d D6 against %s (1 mortal wound on 3+, maximum 6; %d CP)" % [count, state.squads[target].name, cost], "action": "inner-circle-wrath-of-the-lion", "model": -1, "target": int(window.squad), "value": DetachmentStratagems.INNER_CIRCLE_WRATH_OF_THE_LION, "details": {"enemy_squad": target}})
	return result

static func skip(state: Dictionary, player: int, selected: Dictionary) -> String:
	if selected not in choices(state, player) or selected.action != "hammer-of-wrath-pass": return "Choose a Hammer of Wrath target or skip the ability."
	var squad := int(state.unit_abilities.window.get("squad", -1))
	state.unit_abilities.window = {}
	if state.squads.has(squad): Reactions.charge_completed(state, player, squad)
	return ""

static func resolve(state: Dictionary, player: int, selected: Dictionary, roller: Callable) -> Dictionary:
	if str(selected.get("action", "")) == "gravis-armoured-impact": return resolve_armoured_impact(state, player, selected, roller)
	if str(selected.get("action", "")) == "inner-circle-wrath-of-the-lion": return resolve_wrath_of_the_lion(state, player, selected, roller)
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
		Reactions.charge_completed(state, player, squad)
	else:
		state.unit_abilities.window = {"kind": MORTAL_WINDOW, "owners": [state.squads[target].owner], "target": target}
	return {"error": ""}

static func resolve_armoured_impact(state: Dictionary, player: int, selected: Dictionary, roller: Callable) -> Dictionary:
	if selected not in choices(state, player): return {"error": "Choose a living enemy unit engaged with your Gravis Linebreaker unit."}
	if not roller.is_valid(): return {"error": "Armoured Impact requires the host's D6 provider."}
	var window: Dictionary = state.unit_abilities.window
	var squad := int(window.get("squad", -1))
	var details: Dictionary = selected.get("details", {})
	var target := int(details.get("enemy_squad", -1))
	var models := engaged_models(state, squad, target)
	if models.is_empty(): return {"error": "No living Gravis model from this unit is engaged with the selected enemy."}
	var failure := DetachmentStratagems.error(state, player, squad, DetachmentStratagems.GRAVIS_LINEBREAKER_ARMOURED_IMPACT, -1, -1, target)
	if not failure.is_empty(): return {"error": failure}
	var rolls: Array[int] = []
	var mortal_wounds := 0
	for _model: int in models:
		var die: Variant = roller.call()
		if not die is int or die < 1 or die > 6: return {"error": "Armoured Impact dice must be integers from 1 to 6."}
		rolls.append(die)
		if die >= 3: mortal_wounds += 1
	var applied := DetachmentStratagems.apply(state, player, selected, roller)
	if not str(applied.get("error", "")).is_empty(): return applied
	state.last_gravis_armoured_impact = {"squad": squad, "target": target, "models": models.duplicate(), "rolls": rolls, "mortal_wounds": mortal_wounds, "remaining": mortal_wounds, "allocations": [], "discarded": 0}
	if mortal_wounds == 0:
		state.unit_abilities.window = {}
		Reactions.charge_completed(state, player, squad)
	else:
		state.unit_abilities.window = {"kind": ARMOURED_IMPACT_MORTAL, "owners": [state.squads[target].owner], "target": target}
	var result_text := "%d mortal wound%s" % [mortal_wounds, "" if mortal_wounds == 1 else "s"]
	return {"error": "", "message": "Armoured Impact rolled %s; %s against %s." % [str(rolls), result_text, state.squads[target].name]}

static func resolve_wrath_of_the_lion(state: Dictionary, player: int, selected: Dictionary, roller: Callable) -> Dictionary:
	if selected not in choices(state, player): return {"error": "Choose a living enemy unit engaged with your charging Deathwing unit."}
	if not roller.is_valid(): return {"error": "Wrath of the Lion requires the host's D6 provider."}
	var window: Dictionary = state.unit_abilities.window
	var squad := int(window.get("squad", -1))
	var details: Dictionary = selected.get("details", {})
	var target := int(details.get("enemy_squad", -1))
	var models := engaged_models(state, squad, target)
	if models.is_empty(): return {"error": "No living Deathwing model from this unit is engaged with the selected enemy."}
	var rolls: Array[int] = []
	var mortal_wounds := 0
	for _model: int in models:
		var die: Variant = roller.call()
		if not die is int or die < 1 or die > 6: return {"error": "Wrath of the Lion dice must be integers from 1 to 6."}
		rolls.append(die)
		if die >= 3: mortal_wounds = mini(6, mortal_wounds + 1)
	var applied := DetachmentStratagems.apply(state, player, selected, roller)
	if not str(applied.get("error", "")).is_empty(): return applied
	state.last_wrath_of_the_lion = {"squad": squad, "target": target, "models": models.duplicate(), "rolls": rolls, "mortal_wounds": mortal_wounds, "remaining": mortal_wounds, "allocations": [], "discarded": 0}
	if mortal_wounds == 0:
		state.unit_abilities.window = {}
		Reactions.charge_completed(state, player, squad)
	else:
		state.unit_abilities.window = {"kind": Reactions.WRATH_OF_THE_LION_MORTAL, "owners": [state.squads[target].owner], "target": target}
	var result_text := "%d mortal wound%s" % [mortal_wounds, "" if mortal_wounds == 1 else "s"]
	return {"error": "", "message": "Wrath of the Lion rolled %s; %s against %s." % [str(rolls), result_text, state.squads[target].name]}

