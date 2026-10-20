extends RefCounted
## Reiver Squad abilities sourced from the local Wahapedia e11 extract.
const Geometry = preload("res://scripts/edition_11/contact_movement.gd")
const Abilities = preload("res://scripts/edition_11/unit_abilities.gd")
const Morale = preload("res://scripts/edition_11/morale.gd")
const FEARSOME := "fearsome-assault"

static func begin_fight(state: Dictionary) -> bool:
	if state.phase != "fight" or not Abilities.enabled(state): return false
	var targets: Array[int] = []
	for source_squad: int in state.squads:
		if not Abilities.has(state, source_squad, FEARSOME): continue
		var sources := Geometry.alive(state, source_squad)
		for target_squad: int in state.squads:
			if state.squads[target_squad].owner == state.squads[source_squad].owner or Geometry.alive(state, target_squad).is_empty(): continue
			var engaged := false
			for source: int in sources:
				if Geometry.distance_to_target(state, state.units[source], target_squad) <= 2.0 + Geometry.EPSILON:
					engaged = true
					break
			if engaged and target_squad not in targets: targets.append(target_squad)
	targets.sort()
	if targets.is_empty():
		state.erase("fearsome_assault")
		return false
	state.fearsome_assault = {"owner": state.active, "targets": targets, "results": []}
	return true

static func choices(state: Dictionary, player: int) -> Array:
	var pending: Dictionary = state.get("fearsome_assault", {})
	if pending.is_empty() or int(pending.get("owner", -1)) != player: return []
	var result: Array[Dictionary] = []
	for squad: int in pending.get("targets", []):
		if not state.squads.has(squad) or Geometry.alive(state, squad).is_empty(): continue
		result.append({"label": "Fearsome Assault: roll Battle-shock for %s (-1 to the roll)" % state.squads[squad].name, "action": FEARSOME, "model": -1, "target": squad, "value": "roll"})
	return result

static func resolve(state: Dictionary, player: int, selected: Dictionary, roller: Callable) -> Dictionary:
	if selected not in choices(state, player): return {"error": "Fearsome Assault requires each eligible enemy unit to take its Battle-shock test."}
	var target: int = int(selected.target)
	var result := Morale.roll_battle_shock(state, target, roller, -1)
	if not result.error.is_empty(): return result
	var was_battle_shocked: bool = state.squads[target].battle_shocked
	state.squads[target].battle_shocked = was_battle_shocked or not result.passed
	result["source"] = FEARSOME
	result["modifier"] = -1
	result["modified_total"] = int(result.rolls[0]) + int(result.rolls[1]) - 1
	if not state.fearsome_assault.has("results"): state.fearsome_assault.results = []
	state.fearsome_assault.results.append(result.duplicate(true))
	state.fearsome_assault.targets.erase(target)
	var complete: bool = state.fearsome_assault.targets.is_empty()
	if complete:
		state.last_fearsome_assault = state.fearsome_assault.results.duplicate(true)
		state.erase("fearsome_assault")
	var message := "Fearsome Assault: %s rolled %s (-1 = %d vs Leadership %d) — %s." % [state.squads[target].name, str(result.rolls), int(result.modified_total), int(result.target), "passed" if result.passed else "Battle-shocked"]
	return {"error": "", "result": result, "complete": complete, "message": message}
