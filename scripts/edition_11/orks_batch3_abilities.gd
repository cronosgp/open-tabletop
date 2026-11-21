extends RefCounted
## Orks Batch 3 (9 datasheets) datasheet abilities:
## Ghazghkull Thraka, Boss Snikrot, Nazdreg, Zodgrod Wortsnagga, Mozrog Skragbad,
## Wazdakka Gutsmek, Painboss, Beastboss on Squigosaur, Squighog Boyz.
const AbilityCatalog = preload("res://scripts/edition_11/unit_ability_catalog.gd")
const OrksWaaagh = preload("res://scripts/edition_11/orks_waaagh.gd")

static func _within_aura(state: Dictionary, squad: int, ability_name: String, range_inches: float) -> bool:
	var sources: Array[int] = []
	for id: int in state.get("units", {}):
		var u: Dictionary = state.units[id]
		if int(u.get("wounds", 0)) <= 0 or not u.get("on_battlefield", true): continue
		var sq := int(u.get("squad", -1))
		if int(state.get("squads", {}).get(sq, {}).get("owner", -2)) != int(state.get("squads", {}).get(squad, {}).get("owner", -1)): continue
		if AbilityCatalog.has(state, sq, ability_name):
			sources.append(id)
	if sources.is_empty(): return false
	for id: int in state.get("units", {}):
		var u: Dictionary = state.units[id]
		if int(u.get("squad", -1)) != squad or int(u.get("wounds", 0)) <= 0 or not u.get("on_battlefield", true): continue
		for sid: int in sources:
			var su: Dictionary = state.units[sid]
			var dist := Vector2(u.position).distance_to(Vector2(su.position)) - float(u.get("radius", 0.0)) - float(su.get("radius", 0.0))
			if dist <= range_inches + 0.001:
				return true
	return false

static func makari_hoist_banner(state: Dictionary, player: int, source_squad: int, target_squads: Array) -> Dictionary:
	if not AbilityCatalog.has(state, source_squad, "makari-hoist-dat-banner"):
		return {"error": "Unit lacks Makari, Hoist Dat Banner!."}
	var round_num := int(state.get("battle_round", 1))
	if target_squads.size() > round_num:
		return {"error": "Cannot select more units than the current battle round."}
	if not OrksWaaagh.spend_token(state, player, "makari-banner-army", 1, 1):
		return {"error": "Makari, Hoist Dat Banner! already used this battle."}
	for tsq: Variant in target_squads:
		var sq := int(tsq)
		if OrksWaaagh.is_ork_squad(state, sq) and int(state.squads[sq].get("owner", -1)) == player:
			OrksWaaagh.set_riled_up(state, sq, int(state.get("turn", 1)) + 1, "makari-banner")
	return {"error": ""}

static func prophet_melee_bonus(state: Dictionary, squad: int, melee: bool) -> int:
	if not melee or not OrksWaaagh.is_ork_squad(state, squad): return 0
	return 1 if _within_aura(state, squad, "prophet-of-da-great-waaagh", 6.0) else 0

static func thundering_stampede_charge_bonus(state: Dictionary, squad: int) -> int:
	var is_bs := false
	for id: int in state.get("units", {}):
		var u: Dictionary = state.units[id]
		if int(u.get("squad", -1)) == squad and int(u.get("wounds", 0)) > 0:
			for k: Variant in u.get("keywords", []):
				if str(k).strip_edges().to_upper() == "BEAST SNAGGA": is_bs = true
	if not is_bs: return 0
	return 1 if _within_aura(state, squad, "thundering-stampede", 6.0) else 0

static func da_bigger_dey_iz_reroll(state: Dictionary, squad: int, target_squad: int, melee: bool) -> String:
	if not melee or not AbilityCatalog.has(state, squad, "da-bigger-dey-iz"): return "none"
	for id: int in state.get("units", {}):
		var u: Dictionary = state.units[id]
		if int(u.get("squad", -1)) != target_squad or int(u.get("wounds", 0)) <= 0: continue
		for k: Variant in u.get("keywords", []):
			if str(k).strip_edges().to_upper() in ["MONSTER", "VEHICLE"]: return "all"
	return "none"

static func hardy_bioniks_wound_modifier(state: Dictionary, target_squad: int, strength: int, toughness: int) -> int:
	if strength > toughness and AbilityCatalog.has(state, target_squad, "hardy-bioniks"):
		return -1
	return 0

static func brutal_impact_damage_bonus(state: Dictionary, squad: int) -> int:
	if AbilityCatalog.has(state, squad, "brutal-impact") and bool(state.get("squads", {}).get(squad, {}).get("charged", false)):
		return 1
	return 0

static func super_runts_bonus(state: Dictionary, squad: int, weapon_name: String) -> bool:
	return AbilityCatalog.has(state, squad, "super-runts") and weapon_name.to_lower() == "scavenged shivs"

static func push_dat_bit_back_in(state: Dictionary, player: int, painboss_squad: int, target_squad: int) -> Dictionary:
	if not AbilityCatalog.has(state, painboss_squad, "push-dat-bit-back-in"):
		return {"error": "Unit lacks Push Dat Bit Back In."}
	if not OrksWaaagh.spend_token(state, painboss_squad, "push-dat-bit-back-in", 1, 1):
		return {"error": "Grot Orderly token already used."}
	var remaining := 3
	var healed := 0
	for id: int in state.get("units", {}):
		var u: Dictionary = state.units[id]
		if int(u.get("squad", -1)) != target_squad or int(u.get("wounds", 0)) <= 0: continue
		var missing := int(u.get("max_wounds", u.wounds)) - int(u.wounds)
		if missing > 0 and remaining > 0:
			var d := mini(missing, remaining)
			u.wounds = int(u.wounds) + d
			healed += d
			remaining -= d
	return {"error": "", "healed": healed}
