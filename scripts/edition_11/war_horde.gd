extends RefCounted
## Orks War Horde detachment (000000852, Orks App v1.2):
## Get Stuck In, 4 Enhancements, and 6 Stratagems.
const OrksWaaagh = preload("res://scripts/edition_11/orks_waaagh.gd")

const DETACHMENT_ID := "war-horde"
const SOURCE_DETACHMENT_ID := "000000852"

const ENHANCEMENTS := {
	"headwoppas-killchoppa": {"name": "Headwoppa's Killchoppa", "cost": 15, "source_id": "000000852002"},
	"da-boss-is-watchin": {"name": "Da Boss is Watchin'", "cost": 25, "source_id": "000000852003"},
	"kunnin-but-brutal": {"name": "Kunnin' But Brutal", "cost": 20, "source_id": "000000852004"},
	"follow-me-ladz": {"name": "Follow Me Ladz", "cost": 20, "source_id": "000000852005"}
}

const STRATAGEMS := {
	"fungus-fuel-injection": {"name": "FUNGUS-FUEL INJECTION", "cost": 1, "phase": "movement", "source_id": "000000852006"},
	"breakin-heads": {"name": "BREAKIN' HEADS", "cost": 1, "phase": "any", "source_id": "000000852007"},
	"close-range-dakka": {"name": "CLOSE-RANGE DAKKA", "cost": 1, "phase": "shooting", "source_id": "000000852008"},
	"mow-em-down": {"name": "MOW 'EM DOWN", "cost": 1, "phase": "fight", "source_id": "000000852009"},
	"orks-is-never-beaten": {"name": "ORKS IS NEVER BEATEN", "cost": 1, "phase": "fight", "source_id": "000000852010"},
	"hit-em-harder": {"name": "HIT 'EM HARDER", "cost": 1, "phase": "fight", "source_id": "000000852011"}
}

static func is_war_horde(state: Dictionary, player: int) -> bool:
	var det := str(state.get("detachments", {}).get(player, ""))
	if det.is_empty():
		det = str(state.get("combat_doctrines", {}).get("detachments", {}).get(player, ""))
	return det == DETACHMENT_ID

static func get_stuck_in_active(state: Dictionary, squad: int, melee: bool) -> bool:
	if not melee or not state.get("squads", {}).has(squad): return false
	var owner := int(state.squads[squad].get("owner", -1))
	return is_war_horde(state, owner) and OrksWaaagh.is_ork_squad(state, squad)

static func enhancement_move_bonus(state: Dictionary, squad: int) -> int:
	if not state.get("squads", {}).has(squad): return 0
	for id: int in state.get("units", {}):
		var unit: Dictionary = state.units[id]
		if int(unit.get("squad", -1)) != squad or int(unit.get("wounds", 0)) <= 0: continue
		if str(unit.get("enhancement", "")) == "follow-me-ladz": return 2
	return 0

static func enhancement_shoot_and_charge_after_fallback(state: Dictionary, squad: int) -> bool:
	if not state.get("squads", {}).has(squad): return false
	for id: int in state.get("units", {}):
		var unit: Dictionary = state.units[id]
		if int(unit.get("squad", -1)) != squad or int(unit.get("wounds", 0)) <= 0: continue
		if str(unit.get("enhancement", "")) == "kunnin-but-brutal": return true
	return false

static func enhancement_charge_ap_bonus(state: Dictionary, model_id: int, melee: bool) -> int:
	if not melee or not state.get("units", {}).has(model_id): return 0
	var unit: Dictionary = state.units[model_id]
	if str(unit.get("enhancement", "")) != "headwoppas-killchoppa": return 0
	var squad := int(unit.get("squad", -1))
	if bool(state.get("squads", {}).get(squad, {}).get("charged", false)): return 1
	return 0

static func stratagem_move_bonus(state: Dictionary, squad: int) -> int:
	var buff: Dictionary = state.get("orks", {}).get("fungus_fuel", {}).get(squad, {})
	return 2 if int(buff.get("turn", -1)) == int(state.get("turn", -2)) else 0

static func close_range_dakka_active(state: Dictionary, squad: int) -> bool:
	var buff: Dictionary = state.get("orks", {}).get("close_range_dakka", {}).get(squad, {})
	return int(buff.get("turn", -1)) == int(state.get("turn", -2))

static func mow_em_down_active(state: Dictionary, squad: int) -> bool:
	var buff: Dictionary = state.get("orks", {}).get("mow_em_down", {}).get(squad, {})
	return int(buff.get("turn", -1)) == int(state.get("turn", -2))

static func hit_em_harder_active(state: Dictionary, squad: int) -> bool:
	var buff: Dictionary = state.get("orks", {}).get("hit_em_harder", {}).get(squad, {})
	return int(buff.get("turn", -1)) == int(state.get("turn", -2))

static func orks_is_never_beaten_active(state: Dictionary, squad: int) -> bool:
	var buff: Dictionary = state.get("orks", {}).get("orks_is_never_beaten", {}).get(squad, {})
	return int(buff.get("turn", -1)) == int(state.get("turn", -2))

static func apply_melee_weapon_bonuses(state: Dictionary, squad: int, model_id: int, profile: Dictionary) -> void:
	if get_stuck_in_active(state, squad, true):
		profile.keywords["sustained-hits"] = maxi(int(profile.keywords.get("sustained-hits", 0)), 1)
	if mow_em_down_active(state, squad):
		profile.keywords["cleave"] = int(profile.keywords.get("cleave", 0)) + 1
	if hit_em_harder_active(state, squad):
		profile.keywords["lethal-hits"] = true
	var ap_bonus := enhancement_charge_ap_bonus(state, model_id, true)
	if ap_bonus != 0:
		profile.ap = int(profile.get("ap", 0)) - ap_bonus

static func apply_ranged_weapon_bonuses(state: Dictionary, squad: int, profile: Dictionary) -> void:
	if OrksWaaagh.riled_up_assault(state, squad):
		profile.keywords["assault"] = true
	if close_range_dakka_active(state, squad):
		profile.keywords["rapid-fire"] = int(profile.keywords.get("rapid-fire", 0)) + 1
