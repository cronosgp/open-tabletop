extends RefCounted
## Orks Batch 5 & 6 (13 datasheets) abilities:
## Trukk, Battlewagon, Gunwagon, Hunta Rig, Kill Rig, Big'ed Bossbunka,
## Gorkanaut, Morkanaut, Stompa, Blitza-bommer, Burna-bommer, Dakkajet, Wazbom Blastajet.
const AbilityCatalog = preload("res://scripts/edition_11/unit_ability_catalog.gd")
const OrksWaaagh = preload("res://scripts/edition_11/orks_waaagh.gd")

static func hit_reroll_ones(state: Dictionary, squad: int, melee: bool) -> String:
	if not melee and (AbilityCatalog.has(state, squad, "mobile-arsenal") or AbilityCatalog.has(state, squad, "big-an-shooty")):
		return "ones"
	if melee and AbilityCatalog.has(state, squad, "big-an-stompy"):
		return "ones"
	return "none"

static func mobile_fortress_damage_reduction(state: Dictionary, target_squad: int, melee: bool) -> int:
	if not melee and AbilityCatalog.has(state, target_squad, "mobile-fortress"):
		return 1
	return 0

static func fully_loaded_butchery_bonus(state: Dictionary, squad: int, weapon_name: String, embarked_models: int) -> int:
	if weapon_name.to_lower() != "butcha boyz" or not AbilityCatalog.has(state, squad, "fully-loaded-butchery"):
		return 0
	return mini(22, maxi(0, embarked_models) * 2)

static func idol_of_belligerence_disembark(state: Dictionary, transport_squad: int, passenger_squad: int) -> void:
	if AbilityCatalog.has(state, transport_squad, "idol-of-belligerence"):
		OrksWaaagh.set_riled_up(state, passenger_squad, int(state.get("turn", 1)) + 1, "idol-of-belligerence")

static func strafing_run_hit_bonus(state: Dictionary, squad: int, target_squad: int, melee: bool) -> int:
	if melee or not AbilityCatalog.has(state, squad, "strafing-run"): return 0
	for id: int in state.get("units", {}):
		var u: Dictionary = state.units[id]
		if int(u.get("squad", -1)) == target_squad and int(u.get("wounds", 0)) > 0:
			for k: Variant in u.get("keywords", []):
				if str(k).strip_edges().to_upper() == "FLY": return 0
	return 1

static func go_fer_da_weak_spot_wound_bonus(state: Dictionary, squad: int, target_squad: int, melee: bool) -> int:
	if melee or not AbilityCatalog.has(state, squad, "go-fer-da-weak-spot"): return 0
	for id: int in state.get("units", {}):
		var u: Dictionary = state.units[id]
		if int(u.get("squad", -1)) == target_squad and int(u.get("wounds", 0)) > 0:
			for k: Variant in u.get("keywords", []):
				if str(k).strip_edges().to_upper() in ["MONSTER", "VEHICLE"]: return 1
	return 0

static func boom_bomb_mortal_wounds(roll: int, d3_roll: int) -> int:
	var d3 := clampi(ceili(float(d3_roll) / 2.0), 1, 3)
	if roll <= 3: return d3
	if roll <= 5: return 3
	return d3 + 3

static func burna_bomb(state: Dictionary, bomber_squad: int, target_squad: int, roll: int, d3_roll: int) -> Dictionary:
	if not AbilityCatalog.has(state, bomber_squad, "burna-bomb"):
		return {"error": "Unit lacks Burna Bomb."}
	if roll < 2:
		return {"error": "", "hit": false, "mortal_wounds": 0}
	var d3 := clampi(ceili(float(d3_roll) / 2.0), 1, 3)
	OrksWaaagh.ensure_state(state)
	if not state.orks.has("burna_bombed"): state.orks.burna_bombed = {}
	state.orks.burna_bombed[target_squad] = int(state.get("turn", 1)) + 1
	return {"error": "", "hit": true, "mortal_wounds": d3}

static func is_burna_bombed(state: Dictionary, target_squad: int) -> bool:
	return int(state.get("orks", {}).get("burna_bombed", {}).get(target_squad, -1)) >= int(state.get("turn", 1))
