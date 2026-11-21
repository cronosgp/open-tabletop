extends RefCounted
## Orks Batch 1 (11 datasheets) datasheet abilities:
## Boyz, Beast Snagga Boyz, Gretchin, Nobz, Meganobz, Warboss,
## Warboss in Mega Armour, Bigboss, Bannernob, Runtherd, Painboy.
const AbilityCatalog = preload("res://scripts/edition_11/unit_ability_catalog.gd")
const OrksWaaagh = preload("res://scripts/edition_11/orks_waaagh.gd")

static func ammo_runt_active(state: Dictionary, squad: int, model_id: int) -> bool:
	var buff: Dictionary = state.get("orks", {}).get("ammo_runts", {}).get(squad, {})
	if int(buff.get("turn", -1)) != int(state.get("turn", -2)): return false
	if str(buff.get("phase", "")) != str(state.get("phase", "")): return false
	if bool(buff.get("model_only", false)):
		return int(buff.get("model_id", -1)) == model_id
	return true

static func activate_ammo_runt(state: Dictionary, squad: int, model_id: int = -1) -> Dictionary:
	var is_boss := model_id >= 0 and AbilityCatalog.has(state, squad, "boss-ammo-runt")
	if not is_boss and not AbilityCatalog.has(state, squad, "ammo-runts"):
		return {"error": "Unit does not have Ammo Runts."}
	var token_id := "boss-ammo-runt" if is_boss else "ammo-runts"
	if not OrksWaaagh.spend_token(state, squad, token_id, 1, 1):
		return {"error": "Ammo Runt has already been used this battle."}
	if not state.orks.has("ammo_runts"): state.orks.ammo_runts = {}
	state.orks.ammo_runts[squad] = {
		"turn": int(state.get("turn", 1)),
		"phase": str(state.get("phase", "shooting")),
		"model_only": is_boss,
		"model_id": model_id
	}
	return {"error": ""}

static func intimidating_motivation_available(state: Dictionary, player: int) -> bool:
	OrksWaaagh.ensure_state(state)
	var round_num := int(state.get("battle_round", 1))
	return not bool(state.orks.get("intimidating_motivation_rounds", {}).get("%d:%d" % [player, round_num], false))

static func use_intimidating_motivation(state: Dictionary, player: int, source_squad: int, target_squad: int) -> Dictionary:
	if not AbilityCatalog.has(state, source_squad, "intimidating-motivation"):
		return {"error": "Source unit lacks Intimidating Motivation."}
	if not intimidating_motivation_available(state, player):
		return {"error": "Intimidating Motivation already used this battle round."}
	if not OrksWaaagh.is_ork_squad(state, target_squad) or int(state.squads[target_squad].get("owner", -1)) != player:
		return {"error": "Select a friendly ORKS unit."}
	var round_num := int(state.get("battle_round", 1))
	if not state.orks.has("intimidating_motivation_rounds"): state.orks.intimidating_motivation_rounds = {}
	state.orks.intimidating_motivation_rounds["%d:%d" % [player, round_num]] = true
	state.squads[target_squad].battle_shocked = false
	OrksWaaagh.set_riled_up(state, target_squad, int(state.get("turn", 1)) + 1, "intimidating-motivation")
	return {"error": ""}

static func melee_hit_bonus(state: Dictionary, squad: int) -> int:
	var bonus := 0
	if AbilityCatalog.has(state, squad, "sumfin-to-prove"):
		bonus += 1
	if AbilityCatalog.has(state, squad, "krumpin-time") and OrksWaaagh.is_riled_up(state, squad):
		bonus += 1
	return bonus

static func ranged_hit_bonus(state: Dictionary, squad: int, model_id: int) -> int:
	return 1 if ammo_runt_active(state, squad, model_id) else 0

static func tide_of_muscle_active(state: Dictionary, squad: int, melee: bool) -> bool:
	return melee and AbilityCatalog.has(state, squad, "tide-of-muscle") and bool(state.get("squads", {}).get(squad, {}).get("charged", false))

static func arrogant_invulnerability_ap(state: Dictionary, target_squad: int, ap: int) -> int:
	if AbilityCatalog.has(state, target_squad, "arrogant-invulnerability") and ap < 0:
		return mini(0, ap + 1)
	return ap

static func might_is_right_active(state: Dictionary, squad: int, model_id: int, melee: bool) -> bool:
	if not melee or not state.get("units", {}).has(model_id): return false
	if AbilityCatalog.identity(state.units[model_id]) != "warboss": return false
	return AbilityCatalog.has(state, squad, "might-is-right") and bool(state.get("squads", {}).get(squad, {}).get("charged", false))

static func waaagh_banner_charge_bonus(state: Dictionary, squad: int) -> int:
	return 1 if AbilityCatalog.has(state, squad, "waaagh-banner") else 0

static func downtrodden_transport_slots(gretchin_models: int) -> int:
	return ceili(float(maxi(0, gretchin_models)) / 2.0)

static func mobbed_battleshock_penalty(state: Dictionary, charger_squad: int, target_squad: int) -> int:
	if not AbilityCatalog.has(state, charger_squad, "mobbed"): return 0
	var is_heavy := false
	var count := 0
	for id: int in state.get("units", {}):
		var u: Dictionary = state.units[id]
		if int(u.get("wounds", 0)) <= 0: continue
		if int(u.get("squad", -1)) == charger_squad: count += 1
		elif int(u.get("squad", -1)) == target_squad:
			for kw: Variant in u.get("keywords", []):
				if str(kw).strip_edges().to_upper() in ["MONSTER", "VEHICLE"]: is_heavy = true
	if not is_heavy: return 0
	return -2 if count >= 13 else -1

static func krushin_impetus_mortal_wounds(engaged_models: int, roller: Callable) -> int:
	var mw := 0
	for _i in range(maxi(0, engaged_models)):
		if int(roller.call()) >= 3:
			mw += 1
	return mw

static func thatll_learn_ya(state: Dictionary, squad: int, roller: Callable) -> Dictionary:
	if not AbilityCatalog.has(state, squad, "thatll-learn-ya"):
		return {"error": "Unit lacks That'll Learn Ya."}
	if not bool(state.get("squads", {}).get(squad, {}).get("battle_shocked", false)):
		return {"error": "Unit is not Battle-shocked."}
	var gretchin_ids: Array[int] = []
	for id: int in state.get("units", {}):
		var u: Dictionary = state.units[id]
		if int(u.get("squad", -1)) == squad and int(u.get("wounds", 0)) > 0 and AbilityCatalog.identity(u) == "gretchin":
			gretchin_ids.append(id)
	if gretchin_ids.size() < 4:
		return {"error": "Unit needs at least 4 Gretchin models."}
	var round_num := int(state.get("battle_round", 1))
	if not OrksWaaagh.spend_token(state, squad, "thatll-learn-ya-r%d" % round_num, 1, 1):
		return {"error": "That'll Learn Ya already used this battle round."}
	var d3 := clampi(ceili(float(int(roller.call())) / 2.0), 1, 3)
	var slain := mini(d3, gretchin_ids.size())
	for i in range(slain):
		state.units[gretchin_ids[i]].wounds = 0
	state.squads[squad].battle_shocked = false
	return {"error": "", "slain": slain}

static func crude_surgery_heal(state: Dictionary, squad: int, use_grot_orderly: bool = false, roller: Callable = Callable()) -> Dictionary:
	if not AbilityCatalog.has(state, squad, "crude-surgery"):
		return {"error": "Unit lacks Crude Surgery."}
	var heal_amount := 3
	if use_grot_orderly:
		if not AbilityCatalog.has(state, squad, "catch-dat-red-bit"):
			return {"error": "Unit lacks Catch Dat Red Bit."}
		if not OrksWaaagh.spend_token(state, squad, "catch-dat-red-bit", 1, 1):
			return {"error": "Grot Orderly token already used."}
		heal_amount += clampi(ceili(float(int(roller.call())) / 2.0), 1, 3)
	var healed := 0
	for id: int in state.get("units", {}):
		var u: Dictionary = state.units[id]
		if int(u.get("squad", -1)) != squad or int(u.get("wounds", 0)) <= 0: continue
		var missing := int(u.get("max_wounds", u.wounds)) - int(u.wounds)
		if missing > 0 and heal_amount > 0:
			var delta := mini(missing, heal_amount)
			u.wounds = int(u.wounds) + delta
			healed += delta
			heal_amount -= delta
	return {"error": "", "healed": healed}
