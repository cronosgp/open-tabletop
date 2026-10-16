extends RefCounted
## Per-model Leadership/OC overrides support preconfigured attached units.

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

static func needs_command_roll(state: Dictionary, squad: int) -> bool:
	return state.squads[squad].owner == state.active and not living(state, squad).is_empty() and (state.squads[squad].battle_shocked or at_half_strength(state, squad))

static func objective_control(state: Dictionary, id: int) -> int:
	if not state.units.has(id) or state.units[id].wounds <= 0: return 0
	var squad: Dictionary = state.squads[state.units[id].squad]
	return 0 if squad.battle_shocked else int(state.units[id].get("objective_control", squad.stats.objective_control))

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
		target = leadership if target == null else mini(int(target), int(leadership))
	if not (target is int or target is float) or not is_finite(target) or target != floor(target) or target < 2 or target > 12:
		return {"error": "Battle-shock requires a resolved Leadership characteristic."}
	return {"error": "", "target": int(target)}

static func roll_battle_shock(state: Dictionary, squad: int, roller: Callable) -> Dictionary:
	var profile := leadership(state, squad)
	if not profile.error.is_empty(): return profile
	if not roller.is_valid(): return {"error": "Battle-shock requires host dice."}
	var rolls: Array[int] = []
	for die in range(2):
		var value: Variant = roller.call()
		if not value is int or value < 1 or value > 6: return {"error": "Dice provider must return an integer from 1 to 6."}
		rolls.append(value)
	return {"error": "", "squad": squad, "rolls": rolls, "target": profile.target, "passed": rolls[0] + rolls[1] >= profile.target}
