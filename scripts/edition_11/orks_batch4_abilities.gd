extends RefCounted
## Orks Batch 4 (10 datasheets) datasheet abilities:
## Warbikers, Wartrakks, Deffkoptas, Deffkilla Wartrike, Warbuggies,
## Rukkatrukk Squigbuggies, Mek Gunz, Big Mek Dakkarig, Deff Dread, Killa Kans.
const AbilityCatalog = preload("res://scripts/edition_11/unit_ability_catalog.gd")
const OrksWaaagh = preload("res://scripts/edition_11/orks_waaagh.gd")

static func high_speed_carnage_active(state: Dictionary, squad: int, melee: bool) -> bool:
	return melee and AbilityCatalog.has(state, squad, "high-speed-carnage") and bool(state.get("squads", {}).get(squad, {}).get("charged", false))

static func fuel_mixa_grot_advance_bonus(state: Dictionary, squad: int) -> int:
	return 1 if AbilityCatalog.has(state, squad, "fuel-mixa-grot") else 0

static func mark_busted(state: Dictionary, target_squad: int) -> void:
	OrksWaaagh.ensure_state(state)
	if not state.orks.has("busted_targets"): state.orks.busted_targets = {}
	state.orks.busted_targets[target_squad] = int(state.get("turn", 1))

static func is_busted_for(state: Dictionary, attacker_squad: int, target_squad: int) -> bool:
	if int(state.get("orks", {}).get("busted_targets", {}).get(target_squad, -1)) != int(state.get("turn", -2)):
		return false
	for id: int in state.get("units", {}):
		var u: Dictionary = state.units[id]
		if int(u.get("squad", -1)) == attacker_squad and int(u.get("wounds", 0)) > 0:
			for k: Variant in u.get("keywords", []):
				if str(k).strip_edges().to_upper() == "SPEED FREEKS": return true
	return false

static func mark_covered_in_squigs(state: Dictionary, target_squad: int) -> void:
	OrksWaaagh.ensure_state(state)
	if not state.orks.has("squig_covered"): state.orks.squig_covered = {}
	state.orks.squig_covered[target_squad] = int(state.get("turn", 1)) + 1

static func covered_in_squigs_penalty(state: Dictionary, attacker_squad: int) -> int:
	return -1 if int(state.get("orks", {}).get("squig_covered", {}).get(attacker_squad, -1)) >= int(state.get("turn", 1)) else 0

static func even_more_dakka_active(state: Dictionary, squad: int, melee: bool) -> bool:
	return not melee and AbilityCatalog.has(state, squad, "even-more-dakka") and OrksWaaagh.is_riled_up(state, squad)

static func blitz_dem_gitz_bonus(state: Dictionary, squad: int, target_squad: int, weapon_name: String, melee: bool) -> int:
	if melee or weapon_name.to_lower() != "blitzkannon" or not AbilityCatalog.has(state, squad, "blitz-dem-gitz"):
		return 0
	for id: int in state.get("units", {}):
		var u: Dictionary = state.units[id]
		if int(u.get("squad", -1)) == target_squad and int(u.get("wounds", 0)) > 0:
			for k: Variant in u.get("keywords", []):
				if str(k).strip_edges().to_upper() in ["MONSTER", "VEHICLE"]: return 0
	return 6

static func dread_ard_damage_reduction(state: Dictionary, target_squad: int) -> int:
	return 1 if AbilityCatalog.has(state, target_squad, "dread-ard") else 0

static func spiteful_power_trip_hit_bonus(state: Dictionary, squad: int, target_squad: int) -> int:
	if not AbilityCatalog.has(state, squad, "spiteful-power-trip"): return 0
	for id: int in state.get("units", {}):
		var u: Dictionary = state.units[id]
		if int(u.get("squad", -1)) == target_squad and int(u.get("wounds", 0)) > 0:
			if int(u.get("stats", {}).get("toughness", state.get("squads", {}).get(target_squad, {}).get("stats", {}).get("toughness", 0))) >= 7:
				return 0
	return 1

static func get_back_in_da_race(state: Dictionary, player: int, source_squad: int, target_squad: int) -> Dictionary:
	if not AbilityCatalog.has(state, source_squad, "get-back-in-da-race"):
		return {"error": "Unit lacks Get Back in da Race!."}
	OrksWaaagh.ensure_state(state)
	var round_num := int(state.get("battle_round", 1))
	var key := "%d:%d" % [player, round_num]
	if bool(state.orks.get("get_back_in_race_rounds", {}).get(key, false)):
		return {"error": "Get Back in da Race! already used this battle round."}
	var is_sf := false
	for id: int in state.get("units", {}):
		var u: Dictionary = state.units[id]
		if int(u.get("squad", -1)) == target_squad and int(u.get("wounds", 0)) > 0:
			for k: Variant in u.get("keywords", []):
				if str(k).strip_edges().to_upper() == "SPEED FREEKS": is_sf = true
	if not is_sf or int(state.squads[target_squad].get("owner", -1)) != player:
		return {"error": "Select a friendly SPEED FREEKS unit."}
	if not state.orks.has("get_back_in_race_rounds"): state.orks.get_back_in_race_rounds = {}
	state.orks.get_back_in_race_rounds[key] = true
	state.squads[target_squad].battle_shocked = false
	OrksWaaagh.set_riled_up(state, target_squad, int(state.get("turn", 1)) + 1, "get-back-in-da-race")
	return {"error": ""}
