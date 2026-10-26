extends RefCounted
## Per-model Leadership/OC overrides support preconfigured attached units.
const Ancient = preload("res://scripts/edition_11/ancient_rules.gd")
const Geometry = preload("res://scripts/edition_11/contact_movement.gd")
const UnitAbilities = preload("res://scripts/edition_11/unit_abilities.gd")
const FightQueue = preload("res://scripts/edition_11/fight_queue.gd")
const MarineEnhancements = preload("res://scripts/edition_11/stormlance_enhancements.gd")
const AncientFury = preload("res://scripts/edition_11/medusa_ancient_fury.gd")

static func living(state: Dictionary, squad: int) -> Array[int]:
	var ids: Array[int] = []
	for id: int in state.units:
		if state.units[id].squad == squad and state.units[id].wounds > 0: ids.append(id)
	return ids

static func at_half_strength(state: Dictionary, squad: int) -> bool:
	var ids := living(state, squad)
	if ids.is_empty(): return false
	var starting: int = state.squads[squad].starting_strength
	if starting == 1:
		return int(state.units[ids[0]].wounds) * 2 <= int(state.units[ids[0]].max_wounds)
	return ids.size() * 2 <= starting

static func below_half_strength(state: Dictionary, squad: int) -> bool:
	var ids := living(state, squad)
	if ids.is_empty(): return false
	var starting: int = int(state.squads[squad].starting_strength)
	if starting == 1:
		return int(state.units[ids[0]].wounds) * 2 < int(state.units[ids[0]].max_wounds)
	return ids.size() * 2 < starting

static func needs_command_roll(state: Dictionary, squad: int) -> bool:
	return state.squads[squad].owner == state.active and not living(state, squad).is_empty() and (state.squads[squad].battle_shocked or at_half_strength(state, squad))

static func objective_control(state: Dictionary, id: int) -> int:
	if not state.units.has(id) or state.units[id].wounds <= 0 or not state.units[id].get("on_battlefield", true): return 0
	var squad: Dictionary = state.squads[state.units[id].squad]
	if squad.battle_shocked: return 0
	var value := int(state.units[id].get("objective_control", squad.stats.objective_control)) + Ancient.honour(state, state.units[id].squad) + AncientFury.objective_control_bonus(state, int(state.units[id].squad))
	var lion_will: Dictionary = state.get("detachment_stratagems", {}).get("lion_will", {}).get(state.units[id].squad, {})
	if int(lion_will.get("turn", -1)) == int(state.get("turn", -2)) and int(lion_will.get("owner", -1)) == int(state.units[id].get("owner", -2)): value += 1
	var for_the_emperor: Dictionary = state.get("detachment_stratagems", {}).get("for_the_emperor", {}).get(state.units[id].squad, {})
	if int(for_the_emperor.get("turn", -1)) == int(state.get("turn", -2)) and int(for_the_emperor.get("owner", -1)) == int(state.units[id].get("owner", -2)): value += 1
	if MarineEnhancements.standard_bearer(state, id): value += 1
	if MarineEnhancements.active(state, int(state.units[id].squad), MarineEnhancements.IMMOVABLE_CONQUERORS): value += 1
	if UnitAbilities.seeker_of_the_unfound_active(state, id): value += 9
	if terror_troops_applies(state, id): value -= 1
	if lord_of_pyroclasts_applies(state, id): value -= 1
	return maxi(0, value)

static func lord_of_pyroclasts_applies(state: Dictionary, target: int) -> bool:
	if not state.get("unit_abilities", {}).has("implementation"): return false
	var enemy := int(state.units[target].squad)
	for source: int in state.units:
		var adrax: Dictionary = state.units[source]
		if adrax.wounds <= 0 or not adrax.get("on_battlefield", true) or adrax.owner == state.units[target].owner: continue
		if not UnitAbilities.has(state, int(adrax.squad), "lord-of-the-pyroclasts"): continue
		if FightQueue.engaged(state, enemy) and _unit_engaged_with(state, int(adrax.squad), enemy): return true
	return false

static func _unit_engaged_with(state: Dictionary, left: int, right: int) -> bool:
	for model: int in Geometry.alive(state, left):
		for target: int in Geometry.alive(state, right):
			if Geometry.within_engagement(state.units[model], state.units[target]): return true
	return false

static func terror_troops_applies(state: Dictionary, target: int) -> bool:
	if not state.get("unit_abilities", {}).has("implementation"): return false
	var defender: Dictionary = state.units[target]
	for source: int in state.units:
		var reiver: Dictionary = state.units[source]
		if reiver.wounds <= 0 or not reiver.get("on_battlefield", true) or reiver.owner == defender.owner: continue
		if str(reiver.get("definition_id", "")).get_slice(":", 3) != "reiver-squad": continue
		if reiver.squad not in state.squads or defender.squad not in state.squads: continue
		if Geometry.edge(reiver, defender) <= 3.0 + Geometry.EPSILON: return true
	return false

static func can_start_action(state: Dictionary, squad: int) -> bool:
	# Morale gate only; phase, move type and action-specific gates are separate.
	return not living(state, squad).is_empty() and not state.squads[squad].battle_shocked

static func can_target_with_friendly_stratagem(state: Dictionary, squad: int) -> bool:
	return not living(state, squad).is_empty() and not state.squads[squad].battle_shocked

static func resolve_command(state: Dictionary, roller: Callable) -> Dictionary:
	# Build results first: a bad dice provider must not partially change morale.
	var results: Array[Dictionary] = []
	for squad: int in state.squads:
		if not needs_command_roll(state, squad): continue
		var result := roll_battle_shock(state, squad, roller)
		if not result.error.is_empty(): return result
		results.append(result)
	return {"error": "", "results": results}

static func leadership(state: Dictionary, squad: int) -> Dictionary:
	var target: Variant = null
	for model: int in living(state, squad):
		var leadership: Variant = state.units[model].get("leadership_target", state.squads[squad].stats.get("leadership_target"))
		if not (leadership is int or leadership is float) or not is_finite(leadership) or leadership != floor(leadership) or leadership < 2 or leadership > 12: return {"error": "Unresolved model Leadership characteristic."}
		if UnitAbilities.seeker_of_the_unfound_active(state, model): leadership = mini(int(leadership), 5)
		if MarineEnhancements.standard_bearer(state, model): leadership = maxi(2, int(leadership) - 1)
		leadership = mini(12, int(leadership) + AncientFury.leadership_bonus(state, squad))
		target = leadership if target == null else mini(int(target), int(leadership))
	if not (target is int or target is float) or not is_finite(target) or target != floor(target) or target < 2 or target > 12:
		return {"error": "Battle-shock requires a resolved Leadership characteristic."}
	return {"error": "", "target": int(target)}

static func roll_battle_shock(state: Dictionary, squad: int, roller: Callable, modifier: int = 0) -> Dictionary:
	var profile := leadership(state, squad)
	if not profile.error.is_empty(): return profile
	if not roller.is_valid(): return {"error": "Battle-shock requires host dice."}
	var rolls: Array[int] = []
	for die in range(2):
		var value: Variant = roller.call()
		if not value is int or value < 1 or value > 6: return {"error": "Dice provider must return an integer from 1 to 6."}
		rolls.append(value)
	return {"error": "", "squad": squad, "rolls": rolls, "target": profile.target, "modifier": modifier, "modified_total": rolls[0] + rolls[1] + modifier, "passed": rolls[0] + rolls[1] + modifier >= profile.target}
