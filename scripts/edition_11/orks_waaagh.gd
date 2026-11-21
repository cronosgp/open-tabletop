extends RefCounted
## Orks 11e faction rules: Waaagh! (riled up / War Cry), Da Boss, Unstable Energies, and consumable tokens.
const AbilityCatalog = preload("res://scripts/edition_11/unit_ability_catalog.gd")

static func ensure_state(state: Dictionary) -> void:
	if not state.has("orks") or not state.orks is Dictionary:
		state.orks = {}
	if not state.orks.has("war_cry_used") or not state.orks.war_cry_used is Dictionary:
		state.orks.war_cry_used = {}
	if not state.orks.has("da_boss_rounds") or not state.orks.da_boss_rounds is Dictionary:
		state.orks.da_boss_rounds = {}
	if not state.orks.has("psyker_used") or not state.orks.psyker_used is Dictionary:
		state.orks.psyker_used = {}
	if not state.orks.has("tokens_used") or not state.orks.tokens_used is Dictionary:
		state.orks.tokens_used = {}

static func is_ork_squad(state: Dictionary, squad: int) -> bool:
	if not state.get("squads", {}).has(squad): return false
	for id: int in state.get("units", {}):
		var unit: Dictionary = state.units[id]
		if int(unit.get("squad", -1)) != squad or int(unit.get("wounds", 0)) <= 0: continue
		for kw: Variant in unit.get("keywords", []):
			if str(kw).strip_edges().to_upper() == "ORKS": return true
	return false

static func has_waaagh(state: Dictionary, squad: int) -> bool:
	return is_ork_squad(state, squad) and AbilityCatalog.has(state, squad, "waaagh")

static func can_reroll_advance(state: Dictionary, squad: int) -> bool:
	return has_waaagh(state, squad)

static func set_riled_up(state: Dictionary, squad: int, until_turn: int, source: String = "war-cry") -> void:
	if not state.get("squads", {}).has(squad): return
	var existing: Dictionary = state.squads[squad].get("riled_up", {})
	var best_turn := maxi(int(existing.get("until_turn", -1)), until_turn)
	state.squads[squad].riled_up = {"until_turn": best_turn, "source": source}

static func is_riled_up(state: Dictionary, squad: int) -> bool:
	if not state.get("squads", {}).has(squad): return false
	if AbilityCatalog.has(state, squad, "super-runts") or AbilityCatalog.has(state, squad, "waaagh-effigy"): return true
	var current_turn := int(state.get("turn", 1))
	var entry: Variant = state.squads[squad].get("riled_up", {})
	if entry is Dictionary and int(entry.get("until_turn", -1)) >= current_turn:
		return true
	return false

static func riled_up_invulnerable(state: Dictionary, squad: int) -> int:
	return 5 if is_riled_up(state, squad) else 0

static func riled_up_assault(state: Dictionary, squad: int) -> bool:
	return is_riled_up(state, squad)

static func riled_up_charge_after_advance(state: Dictionary, squad: int) -> bool:
	return is_riled_up(state, squad)

static func war_cry_available(state: Dictionary, player: int) -> bool:
	ensure_state(state)
	if bool(state.orks.war_cry_used.get(player, false)): return false
	if str(state.get("phase", "")) != "command": return false
	for squad: int in state.get("squads", {}):
		if int(state.squads[squad].get("owner", -1)) != player: continue
		if has_waaagh(state, squad): return true
	return false

static func call_war_cry(state: Dictionary, player: int) -> Dictionary:
	if not war_cry_available(state, player):
		return {"error": "War Cry is not available for this player."}
	ensure_state(state)
	state.orks.war_cry_used[player] = true
	var until_turn := int(state.get("turn", 1)) + 1
	var affected: Array[int] = []
	for squad: int in state.get("squads", {}):
		if int(state.squads[squad].get("owner", -1)) != player: continue
		if has_waaagh(state, squad):
			set_riled_up(state, squad, until_turn, "war-cry")
			affected.append(squad)
	return {"error": "", "affected_squads": affected, "until_turn": until_turn}

static func warlord_has_da_boss(state: Dictionary, player: int) -> bool:
	var warlord_squad := int(state.get("warlords", {}).get(player, -1))
	if warlord_squad < 0 or not state.get("squads", {}).has(warlord_squad): return false
	for id: int in state.get("units", {}):
		var unit: Dictionary = state.units[id]
		if int(unit.get("squad", -1)) != warlord_squad or int(unit.get("wounds", 0)) <= 0: continue
		if AbilityCatalog.has(state, warlord_squad, "da-boss"): return true
	return false

static func apply_da_boss_round_cp(state: Dictionary, battle_round: int) -> Dictionary:
	ensure_state(state)
	var granted := {}
	if bool(state.orks.da_boss_rounds.get(battle_round, false)): return granted
	state.orks.da_boss_rounds[battle_round] = true
	for player in [0, 1]:
		if warlord_has_da_boss(state, player):
			if state.has("cp") and state.cp is Dictionary:
				state.cp[player] = int(state.cp.get(player, 0)) + 1
			granted[player] = 1
	return granted

static func psyker_level(state: Dictionary, squad: int) -> int:
	if not AbilityCatalog.has(state, squad, "unstable-energies"): return 0
	return 1

static func psyker_budget_remaining(state: Dictionary, squad: int, battle_round: int = -1) -> int:
	var level := psyker_level(state, squad)
	if level <= 0: return 0
	ensure_state(state)
	var round_num := battle_round if battle_round >= 0 else int(state.get("battle_round", 1))
	var key := "%d:%d" % [round_num, squad]
	return maxi(0, level - int(state.orks.psyker_used.get(key, 0)))

static func spend_psyker_level(state: Dictionary, squad: int, cost: int = 1, battle_round: int = -1) -> bool:
	if cost <= 0 or psyker_budget_remaining(state, squad, battle_round) < cost: return false
	ensure_state(state)
	var round_num := battle_round if battle_round >= 0 else int(state.get("battle_round", 1))
	var key := "%d:%d" % [round_num, squad]
	state.orks.psyker_used[key] = int(state.orks.psyker_used.get(key, 0)) + cost
	return true

static func token_remaining(state: Dictionary, squad: int, token_id: String, max_per_battle: int, max_per_turn: int = 1) -> int:
	ensure_state(state)
	var battle_key := "%d:%s" % [squad, token_id]
	var used_battle := int(state.orks.tokens_used.get(battle_key, 0))
	if used_battle >= max_per_battle: return 0
	var turn_key := "%d:%d:%s" % [int(state.get("turn", 1)), squad, token_id]
	var used_turn := int(state.orks.tokens_used.get(turn_key, 0))
	if used_turn >= max_per_turn: return 0
	return mini(max_per_battle - used_battle, max_per_turn - used_turn)

static func spend_token(state: Dictionary, squad: int, token_id: String, max_per_battle: int, max_per_turn: int = 1) -> bool:
	if token_remaining(state, squad, token_id, max_per_battle, max_per_turn) <= 0: return false
	ensure_state(state)
	var battle_key := "%d:%s" % [squad, token_id]
	var turn_key := "%d:%d:%s" % [int(state.get("turn", 1)), squad, token_id]
	state.orks.tokens_used[battle_key] = int(state.orks.tokens_used.get(battle_key, 0)) + 1
	state.orks.tokens_used[turn_key] = int(state.orks.tokens_used.get(turn_key, 0)) + 1
	return true
