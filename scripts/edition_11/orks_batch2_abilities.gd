extends RefCounted
## Orks Batch 2 (11 datasheets) datasheet abilities:
## Breaka Boyz, Tankbustas, Flash Gitz, Kommandos, Stormboyz, Big Mek,
## Big Mek in Mega Armour, Big Mek with Shokk Attack Gun, Mek, Weirdboy, Beastboss.
const AbilityCatalog = preload("res://scripts/edition_11/unit_ability_catalog.gd")
const OrksWaaagh = preload("res://scripts/edition_11/orks_waaagh.gd")

static func trophy_hunters_charge_bonus(state: Dictionary, squad: int) -> int:
	return 1 if AbilityCatalog.has(state, squad, "trophy-hunters") else 0

static func use_bomb_squig(state: Dictionary, squad: int, roller: Callable) -> Dictionary:
	var is_twice := AbilityCatalog.has(state, squad, "bomb-squigs")
	var is_once := AbilityCatalog.has(state, squad, "bomb-squig")
	if not is_twice and not is_once:
		return {"error": "Unit does not have Bomb Squigs."}
	var max_battle := 2 if is_twice else 1
	if not OrksWaaagh.spend_token(state, squad, "bomb-squigs", max_battle, 1):
		return {"error": "No Bomb Squig tokens remaining."}
	var roll := int(roller.call())
	if roll < 3:
		return {"error": "", "hit": false, "mortal_wounds": 0}
	var mw := clampi(ceili(float(int(roller.call())) / 2.0), 1, 3)
	return {"error": "", "hit": true, "mortal_wounds": mw}

static func finderz_keeperz_ap_bonus(state: Dictionary, squad: int, target_squad: int, melee: bool) -> int:
	if melee or not AbilityCatalog.has(state, squad, "finderz-keeperz"): return 0
	for sq in [squad, target_squad]:
		for id: int in state.get("units", {}):
			var u: Dictionary = state.units[id]
			if int(u.get("squad", -1)) != sq or int(u.get("wounds", 0)) <= 0: continue
			for obj: Variant in state.get("objectives", []):
				if obj is Dictionary and Vector2(u.position).distance_to(Vector2(obj.get("position", Vector2.ZERO))) <= float(obj.get("radius", 3.0)) + float(u.get("radius", 0.0)) + 0.001:
					return 1
	return 0

static func hit_bonus(state: Dictionary, squad: int, melee: bool) -> int:
	var bonus := 0
	if AbilityCatalog.has(state, squad, "dodge-dis"):
		bonus += 1
	var clever: Dictionary = state.get("orks", {}).get("clever_know_wotz", {}).get(squad, {})
	if int(clever.get("until_turn", -1)) >= int(state.get("turn", 1)):
		bonus += 1
	return bonus

static func apply_ranged_traits(state: Dictionary, squad: int, profile: Dictionary) -> void:
	if AbilityCatalog.has(state, squad, "kustom-dakka"):
		profile.keywords["ignores-cover"] = true
	if AbilityCatalog.has(state, squad, "more-dakka"):
		profile.keywords["ignores-cover"] = true
		if OrksWaaagh.is_riled_up(state, squad):
			profile.keywords["sustained-hits"] = maxi(1, int(profile.keywords.get("sustained-hits", 0)))

static func activate_rokkit_charge(state: Dictionary, squad: int) -> Dictionary:
	if not AbilityCatalog.has(state, squad, "rokkit-charge"):
		return {"error": "Unit lacks Rokkit Charge."}
	if not bool(state.get("squads", {}).get(squad, {}).get("charged", false)):
		return {"error": "Rokkit Charge requires a charge move this turn."}
	OrksWaaagh.ensure_state(state)
	if not state.orks.has("rokkit_charge"): state.orks.rokkit_charge = {}
	state.orks.rokkit_charge[squad] = {"turn": int(state.get("turn", 1))}
	return {"error": ""}

static func rokkit_charge_active(state: Dictionary, squad: int, melee: bool) -> bool:
	if not melee: return false
	var buff: Dictionary = state.get("orks", {}).get("rokkit_charge", {}).get(squad, {})
	return int(buff.get("turn", -1)) == int(state.get("turn", -2))

static func fix_dat_armour_up(state: Dictionary, squad: int) -> Dictionary:
	if not AbilityCatalog.has(state, squad, "fix-dat-armour-up"):
		return {"error": "Unit lacks Fix Dat Armour Up."}
	if not OrksWaaagh.spend_token(state, squad, "fix-dat-armour-up", 1, 1):
		return {"error": "Grot Oiler token already used."}
	var remaining := 3
	var healed := 0
	for id: int in state.get("units", {}):
		var u: Dictionary = state.units[id]
		if int(u.get("squad", -1)) != squad or int(u.get("wounds", 0)) <= 0: continue
		var missing := int(u.get("max_wounds", u.wounds)) - int(u.wounds)
		if missing > 0 and remaining > 0:
			var d := mini(missing, remaining)
			u.wounds = int(u.wounds) + d
			healed += d
			remaining -= d
	return {"error": "", "healed": healed}

static func clever_know_wotz(state: Dictionary, mek_squad: int, target_squad: int, roller: Callable) -> Dictionary:
	if not AbilityCatalog.has(state, mek_squad, "clever-know-wotz"):
		return {"error": "Unit lacks Clever Know-wotz."}
	var target_model := -1
	for id: int in state.get("units", {}):
		var u: Dictionary = state.units[id]
		if int(u.get("squad", -1)) != target_squad or int(u.get("wounds", 0)) <= 0: continue
		var kws := []
		for k: Variant in u.get("keywords", []): kws.append(str(k).strip_edges().to_upper())
		if "ORKS" in kws and "VEHICLE" in kws and "AIRCRAFT" not in kws and "TITANIC" not in kws:
			target_model = id
			break
	if target_model < 0:
		return {"error": "Select a friendly ORKS VEHICLE (non-AIRCRAFT, non-TITANIC)."}
	var d3 := clampi(ceili(float(int(roller.call())) / 2.0), 1, 3)
	var u: Dictionary = state.units[target_model]
	var healed := mini(d3, int(u.get("max_wounds", u.wounds)) - int(u.wounds))
	u.wounds = int(u.wounds) + healed
	OrksWaaagh.ensure_state(state)
	if not state.orks.has("clever_know_wotz"): state.orks.clever_know_wotz = {}
	state.orks.clever_know_wotz[target_squad] = {"until_turn": int(state.get("turn", 1)) + 1}
	return {"error": "", "healed": healed}

static func keep_huntin(state: Dictionary, player: int, source_squad: int, target_squad: int) -> Dictionary:
	if not AbilityCatalog.has(state, source_squad, "keep-huntin"):
		return {"error": "Unit lacks Keep Huntin'!."}
	OrksWaaagh.ensure_state(state)
	var round_num := int(state.get("battle_round", 1))
	var key := "%d:%d" % [player, round_num]
	if bool(state.orks.get("keep_huntin_rounds", {}).get(key, false)):
		return {"error": "Keep Huntin'! already used this battle round."}
	var is_beast_snagga := false
	for id: int in state.get("units", {}):
		var u: Dictionary = state.units[id]
		if int(u.get("squad", -1)) == target_squad and int(u.get("wounds", 0)) > 0:
			for k: Variant in u.get("keywords", []):
				if str(k).strip_edges().to_upper() == "BEAST SNAGGA": is_beast_snagga = true
	if not is_beast_snagga or int(state.squads[target_squad].get("owner", -1)) != player:
		return {"error": "Select a friendly BEAST SNAGGA unit."}
	if not state.orks.has("keep_huntin_rounds"): state.orks.keep_huntin_rounds = {}
	state.orks.keep_huntin_rounds[key] = true
	state.squads[target_squad].battle_shocked = false
	OrksWaaagh.set_riled_up(state, target_squad, int(state.get("turn", 1)) + 1, "keep-huntin")
	return {"error": ""}
