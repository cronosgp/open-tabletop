extends RefCounted
## Razorback and Relic Razorback post-shot target and turn-limited wound re-roll.
const MarineProfiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const UnitAbilities = preload("res://scripts/edition_11/unit_abilities.gd")

const WINDOW := "razorback-fire-support-target"
const ACTION := "razorback-fire-support-select"
const IDENTITIES := ["razorback", "relic-razorback"]

static func _has_fire_support_datasheet(state: Dictionary, squad: int) -> bool:
	if not state.get("squads", {}).has(squad): return false
	for model: int in state.get("units", {}):
		if int(state.units[model].get("squad", -1)) != squad: continue
		var identity := UnitAbilities.identity(state.units[model])
		if identity not in IDENTITIES: continue
		for ability: Dictionary in MarineProfiles.profile(identity).get("abilities", []):
			if str(ability.get("name", "")) == "Fire Support": return true
	return false

static func eligible_targets(state: Dictionary, source_squad: int, pools: Array) -> Array[int]:
	var targets: Array[int] = []
	if not UnitAbilities.enabled(state) or str(state.get("phase", "")) != "shooting" or not state.get("squads", {}).has(source_squad): return targets
	if int(state.squads[source_squad].get("owner", -1)) != int(state.get("active", -2)) or not UnitAbilities.has(state, source_squad, "razorback-fire-support"): return targets
	var used_key := "razorback-fire-support:%d:%d" % [source_squad, int(state.get("turn", -1))]
	if state.get("unit_abilities", {}).get("used", {}).get(used_key, false): return targets
	var owner := int(state.squads[source_squad].owner)
	for pool_value: Variant in pools:
		if not pool_value is Dictionary: continue
		var target := int(pool_value.get("target_squad", -1))
		if int(pool_value.get("hits", 0)) <= 0 or target < 0 or not state.squads.has(target) or int(state.squads[target].get("owner", -1)) == owner: continue
		if target not in targets: targets.append(target)
	targets.sort()
	return targets

static func open_after_shot(state: Dictionary, source_squad: int, pools: Array) -> bool:
	var targets := eligible_targets(state, source_squad, pools)
	if targets.is_empty(): return false
	var owner := int(state.squads[source_squad].owner)
	var used_key := "razorback-fire-support:%d:%d" % [source_squad, int(state.get("turn", -1))]
	state.unit_abilities.used[used_key] = true
	var previous: Dictionary = state.get("unit_abilities", {}).get("window", {}).duplicate(true)
	state.unit_abilities.window = {"kind": WINDOW, "owners": [owner], "source_squad": source_squad,
		"source_owner": owner, "target_squads": targets, "turn": int(state.get("turn", 0)),
		"phase": str(state.get("phase", "")), "resume_window": previous}
	return true

static func window_error(state: Dictionary) -> String:
	var window: Dictionary = state.get("unit_abilities", {}).get("window", {})
	if str(window.get("kind", "")) != WINDOW: return "There is no pending Razorback Fire Support decision."
	if str(state.get("phase", "")) != "shooting" or int(state.get("turn", -1)) != int(window.get("turn", -2)) or str(window.get("phase", "")) != "shooting":
		return "The Razorback Fire Support decision is stale outside its Shooting phase."
	var source := int(window.get("source_squad", -1))
	if not _has_fire_support_datasheet(state, source) or not state.get("squads", {}).has(source) or int(state.squads[source].get("owner", -1)) != int(window.get("source_owner", -2)):
		return "The source unit no longer matches a Razorback Fire Support datasheet."
	if int(state.get("active", -1)) != int(window.get("owners", [-2])[0]): return "Only the Razorback player's Shooting phase can resolve Fire Support."
	return ""

static func choices(state: Dictionary, player: int) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var window: Dictionary = state.get("unit_abilities", {}).get("window", {})
	if str(window.get("kind", "")) != WINDOW or window.get("owners", []) != [player] or not window_error(state).is_empty(): return result
	for target: int in window.get("target_squads", []):
		if not state.get("squads", {}).has(target) or int(state.squads[target].get("owner", -1)) == player: continue
		result.append({"label": "Fire Support: mark %s" % str(state.squads[target].get("name", "enemy unit")), "action": ACTION, "model": -1, "target": target, "value": ""})
	return result

static func apply(state: Dictionary, player: int, selected: Dictionary) -> Dictionary:
	if not window_error(state).is_empty(): return {"error": window_error(state)}
	if selected not in choices(state, player): return {"error": "Select an enemy unit hit by this Razorback's attacks."}
	var window: Dictionary = state.unit_abilities.window
	var source := int(window.source_squad)
	var target := int(selected.get("target", -1))
	if target not in window.get("target_squads", []) or not state.squads.has(target) or int(state.squads[target].get("owner", -1)) == player:
		return {"error": "Choose one enemy unit hit by this transport's attacks."}
	if not state.unit_abilities.has("fire_support_marks"): state.unit_abilities.fire_support_marks = {}
	state.unit_abilities.fire_support_marks[source] = {"target_squad": target, "turn": int(window.turn), "owner": player}
	state.unit_abilities.window = window.get("resume_window", {})
	return {"error": "", "message": "Fire Support marks %s for friendly units that disembarked from %s this turn." % [str(state.squads[target].get("name", "the selected unit")), str(state.squads[source].get("name", "the Razorback"))]}

static func applies_to_attack(state: Dictionary, attacker_squad: int, target_squad: int) -> bool:
	if not UnitAbilities.enabled(state) or not state.get("squads", {}).has(attacker_squad) or not state.get("squads", {}).has(target_squad): return false
	if not UnitAbilities.has_living_unit_keyword(state, attacker_squad, "ADEPTUS ASTARTES"): return false
	var owner := int(state.squads[attacker_squad].get("owner", -1))
	if int(state.squads[target_squad].get("owner", -1)) == owner: return false
	for source_value: Variant in state.get("unit_abilities", {}).get("fire_support_marks", {}):
		var source := int(source_value)
		var mark: Dictionary = state.unit_abilities.fire_support_marks[source_value]
		if int(mark.get("target_squad", -1)) != target_squad or int(mark.get("turn", -2)) != int(state.get("turn", -1)) or int(mark.get("owner", -2)) != owner: continue
		if not state.squads.has(source) or int(state.squads[source].get("owner", -1)) != owner: continue
		if int(state.squads[attacker_squad].get("disembarked_from_transport", -1)) != source or int(state.squads[attacker_squad].get("disembarked_turn", -2)) != int(state.get("turn", -1)): continue
		return true
	return false
