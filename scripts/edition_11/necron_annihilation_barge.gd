extends RefCounted
## Annihilation Barge datasheet 000000553, Necrons App v1.2.
const UnitAbilities = preload("res://scripts/edition_11/unit_abilities.gd")
const Geometry = preload("res://scripts/edition_11/contact_movement.gd")
const RandomStat = preload("res://scripts/edition_11/random_characteristic.gd")
const EPSILON := 0.001

static func _unit_edge_distance(state: Dictionary, left: int, right: int) -> float:
	var distance := INF
	for left_model: int in Geometry.alive(state, left):
		for right_model: int in Geometry.alive(state, right):
			distance = minf(distance, Geometry.edge(state.units[left_model], state.units[right_model]))
	return distance

static func _uses_twin_tesla_destructor(batch: Dictionary) -> bool:
	for source: Variant in batch.get("context", {}).get("attack_sources", []):
		if not source is Dictionary: continue
		var weapon_id := str(source.get("weapon", ""))
		if weapon_id in ["source-ranged-3", "twin-tesla-destructor"]: return true
		var label := str(source.get("label", "")).to_lower()
		if label == "twin tesla destructor": return true
	var profile_name := str(batch.get("weapon", {}).get("name", "")).to_lower()
	return "twin tesla destructor" in profile_name

## Rolls Malevolent Arcing's target-selection dice after target assignments are fixed,
## before any attacks resolve. The returned records are saved in the attack frame.
static func prepare(state: Dictionary, squad: int, prepared: Dictionary, roller: Callable) -> Dictionary:
	var effects: Array[Dictionary] = []
	if not UnitAbilities.enabled(state) or not state.get("squads", {}).has(squad): return {"error": "", "effects": effects}
	var models := Geometry.alive(state, squad)
	if models.is_empty() or UnitAbilities.identity(state.units[models[0]]) != "annihilation-barge" or not UnitAbilities.has(state, squad, "malevolent-arcing"):
		return {"error": "", "effects": effects}
	var owner := int(state.squads[squad].get("owner", -1))
	var seen_targets: Dictionary = {}
	for batch: Dictionary in prepared.get("batches", []):
		if not _uses_twin_tesla_destructor(batch): continue
		var target := int(batch.get("target", -1))
		if seen_targets.has(target) or not state.get("squads", {}).has(target): continue
		seen_targets[target] = true
		var affected: Array[int] = [target]
		var target_owner := int(state.squads[target].get("owner", -1))
		var adjacent: Array[int] = []
		for other: int in state.squads:
			if other == target or int(state.squads[other].get("owner", -2)) != target_owner: continue
			if Geometry.alive(state, other).is_empty(): continue
			if _unit_edge_distance(state, target, other) <= 3.0 + EPSILON: adjacent.append(other)
		adjacent.sort()
		affected.append_array(adjacent)
		var rolls: Array[Dictionary] = []
		for affected_squad: int in affected:
			if int(state.squads[affected_squad].get("owner", -1)) == owner: continue
			var die := RandomStat.roll("D6", roller)
			if not str(die.get("error", "")).is_empty(): return die
			rolls.append({"target": affected_squad, "roll": int(die.value), "struck": int(die.value) >= 5})
		effects.append({"after_target": target, "source_squad": squad, "rolls": rolls})
	return {"error": "", "effects": effects}
