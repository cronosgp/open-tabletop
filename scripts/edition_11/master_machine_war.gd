extends RefCounted
## Master of the Machine War from the Medusa's Wrath enhancement.

const Geometry = preload("res://scripts/edition_11/contact_movement.gd")
const MarineEnhancements = preload("res://scripts/edition_11/stormlance_enhancements.gd")
const Targeting = preload("res://scripts/edition_11/terrain.gd")
const Vehicles = preload("res://scripts/edition_11/techmarine.gd")

const CHOICES := ["devastator", "tactical"]

static func _use_key(player: int, turn: int) -> String:
	return "master-machine-war:%d:%d" % [player, turn]

static func _valid_target(state: Dictionary, player: int, source: int, squad: int) -> bool:
	if not state.get("squads", {}).has(squad) or int(state.squads[squad].get("owner", -1)) != player: return false
	var members := Geometry.alive(state, squad)
	if members.is_empty(): return false
	var vehicle := false
	for model: int in members:
		if Vehicles.astartes_vehicle(state.units[model]):
			vehicle = true
			break
	if not vehicle or not state.get("units", {}).has(source): return false
	var sight := Targeting.targeting(state, source, squad)
	return bool(sight.get("visible", false)) and float(sight.get("distance", INF)) <= 6.001

static func choices(state: Dictionary, player: int, available_doctrines: Array[String]) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if state.get("phase", "") != "movement" or int(state.get("active", -1)) != player: return result
	var used: Dictionary = state.get("marine_enhancements", {}).get("master_machine_war_used", {})
	var turn := int(state.get("turn", 0))
	if used.get(_use_key(player, turn), false): return result
	for source: int in state.get("units", {}):
		var bearer: Dictionary = state.units[source]
		if int(bearer.get("owner", -1)) != player or int(bearer.get("wounds", 0)) <= 0 or not bearer.get("on_battlefield", true): continue
		if not MarineEnhancements.master_of_the_machine_war_bearer(state, source): continue
		for squad: int in state.get("squads", {}):
			if not _valid_target(state, player, source, squad): continue
			for doctrine: String in available_doctrines:
				if doctrine not in CHOICES: continue
				result.append({"label": "Master of the Machine War: %s Doctrine for %s" % ["Devastator" if doctrine == "devastator" else "Tactical", str(state.squads[squad].get("name", "Vehicle unit"))],
					"action": "master-machine-war", "model": source, "target": squad, "value": doctrine})
	return result

static func apply(state: Dictionary, player: int, selected: Dictionary, available_doctrines: Array[String]) -> Dictionary:
	var source := int(selected.get("model", -1))
	var squad := int(selected.get("target", -1))
	var doctrine := str(selected.get("value", ""))
	if state.get("phase", "") != "movement" or int(state.get("active", -1)) != player:
		return {"error": "Master of the Machine War is used in your Movement phase."}
	if not state.get("units", {}).has(source): return {"error": "Select the living bearer of Master of the Machine War."}
	var bearer: Dictionary = state.units[source]
	if int(bearer.get("owner", -1)) != player or int(bearer.get("wounds", 0)) <= 0 or not bearer.get("on_battlefield", true) or not MarineEnhancements.master_of_the_machine_war_bearer(state, source):
		return {"error": "Master of the Machine War requires its living Adeptus Astartes bearer on the battlefield."}
	var used: Dictionary = state.get("marine_enhancements", {}).get("master_machine_war_used", {})
	if used.get(_use_key(player, int(state.get("turn", 0))), false): return {"error": "Master of the Machine War has already been used this Movement phase."}
	if doctrine not in CHOICES or doctrine not in available_doctrines: return {"error": "Choose an available Devastator or Tactical Doctrine."}
	if not _valid_target(state, player, source, squad): return {"error": "Choose a visible friendly Adeptus Astartes Vehicle unit within 6 inches of the bearer."}
	if not state.has("marine_enhancements"): state.marine_enhancements = {}
	if not state.marine_enhancements.has("master_machine_war_targets"): state.marine_enhancements.master_machine_war_targets = {}
	if not state.marine_enhancements.has("master_machine_war_used"): state.marine_enhancements.master_machine_war_used = {}
	var expires_turn := int(state.get("turn", 0)) + 2
	state.marine_enhancements.master_machine_war_targets[squad] = {"owner": player, "source": source, "doctrine": doctrine,
		"activated_turn": int(state.get("turn", 0)), "expires_turn": expires_turn}
	state.marine_enhancements.master_machine_war_used[_use_key(player, int(state.get("turn", 0)))] = true
	var doctrine_name := "Devastator" if doctrine == "devastator" else "Tactical"
	return {"error": "", "message": "%s Doctrine is active for %s until the start of your next Command phase." % [doctrine_name, str(state.squads[squad].get("name", "Vehicle unit"))]}
