extends RefCounted
## Core Rules §§01.07, 08.03, 15.01–15.04; no provisional faction abilities.
const Morale = preload("res://scripts/edition_11/morale.gd")
const ID := "core-stratagem-windows-v1"
const REROLL_ID := "command-reroll-movement-v1"
const ATTACK_REROLL_ID := "command-reroll-hit-wound-v1"
const COUNT_REROLL_ID := "command-reroll-attack-count-v1"
const HAZARD_REROLL_ID := "command-reroll-weapon-hazard-v1"
const ESCAPE_REROLL_ID := "command-reroll-escape-hazard-v1"
const DAMAGE_REROLL_ID := "command-reroll-damage-v1"
const SAVE_REROLL_ID := "command-reroll-save-v1"
const SUPPORTED := {"insane-bravery": {"cost": 1, "window": "before_battle_shock", "phase": "command", "once_per_battle": true},
	"command-re-roll": {"cost": 1, "windows": ["after_advance_roll", "after_charge_roll", "after_hit_roll", "after_wound_roll", "after_save_roll", "after_damage_roll", "after_hazardous_roll", "after_attack_count_roll", "after_escape_roll"], "once_per_battle": false}}

static func enable(state: Dictionary, movement_rerolls: bool = false, attack_rerolls: bool = false, save_rerolls: bool = false, damage_rerolls: bool = false, hazard_rerolls: bool = false, count_rerolls: bool = false, escape_rerolls: bool = false) -> Dictionary:
	if state.has("error") or state.has("stratagems"): return state
	state.stratagems = {"implementation": ID, "pending": {}, "uses": [], "command_done_turn": -1}
	state.pack_hash = (str(state.pack_hash) + ID).sha256_text()
	state.scope = "Core stratagem supported: Insane Bravery before Command battle-shock only. " + str(state.get("scope", "")).replace("stratagems,", "other stratagems,")
	if movement_rerolls:
		state.stratagems.movement_rerolls = true
		state.pack_hash = (str(state.pack_hash) + REROLL_ID).sha256_text()
		state.scope = "Command Re-roll supported for Advance and Charge rolls only. " + state.scope
	if attack_rerolls:
		state.stratagems.attack_rerolls = true
		state.pack_hash = (str(state.pack_hash) + ATTACK_REROLL_ID).sha256_text()
		state.scope = "Command Re-roll also supported for hit and wound pools, before subsequent rolls. " + state.scope
	if save_rerolls:
		state.stratagems.save_rerolls = true
		state.pack_hash = (str(state.pack_hash) + SAVE_REROLL_ID).sha256_text()
		state.scope = "Command Re-roll supported for save pools before sorting and damage. " + state.scope
	if damage_rerolls:
		state.stratagems.damage_rerolls = true
		state.pack_hash = (str(state.pack_hash) + DAMAGE_REROLL_ID).sha256_text()
		state.scope = "Command Re-roll supported for one random damage die before prevention and casualties. " + state.scope
	if hazard_rerolls:
		state.stratagems.hazard_rerolls = true
		state.pack_hash = (str(state.pack_hash) + HAZARD_REROLL_ID).sha256_text()
		state.scope = "Command Re-roll supported for weapon Hazardous tests before mortal wound allocation. Desperate Escape hazard re-rolls remain unsupported. " + state.scope
	if count_rerolls:
		state.stratagems.count_rerolls = true
		state.pack_hash = (str(state.pack_hash) + COUNT_REROLL_ID).sha256_text()
		state.scope = "Command Re-roll supported for random attack counts before hit rolls. " + state.scope
	if escape_rerolls:
		state.stratagems.escape_rerolls = true
		state.pack_hash = (str(state.pack_hash) + ESCAPE_REROLL_ID).sha256_text()
		state.scope = "Command Re-roll supported for Desperate Escape hazard rolls before mortal wound allocation or movement. " + state.scope.replace("Desperate Escape hazard re-rolls remain unsupported. ", "")
	return state

static func pending(state: Dictionary) -> Dictionary:
	return state.get("stratagems", {}).get("pending", {})

static func phase_key(state: Dictionary) -> String:
	return "%d:%s" % [state.turn, state.phase]

static func open_command(state: Dictionary) -> bool:
	if not state.has("stratagems") or state.stratagems.command_done_turn == state.turn: return false
	var remaining: Array[int] = []
	for squad: int in state.squads:
		if Morale.needs_command_roll(state, squad): remaining.append(squad)
	remaining.sort()
	if remaining.is_empty():
		state.stratagems.command_done_turn = state.turn
		return false
	state.stratagems.pending = {"kind": "before_battle_shock", "player": state.active, "phase_key": phase_key(state), "remaining": remaining, "results": []}
	return true

static func choice_error(state: Dictionary, player: int, squad: int, revision: int) -> String:
	var window := pending(state)
	if window.is_empty(): return "There is no pending decision window."
	if revision != state.revision: return "O estado mudou; sincronize antes de decidir."
	if state.get("test_winner", 0) != 0: return "The match has ended."
	if window.phase_key != phase_key(state) or player != window.player: return "This decision belongs to the player shown in the window."
	if window.kind not in ["after_hit_roll", "after_wound_roll", "after_save_roll", "after_damage_roll", "after_hazardous_roll", "after_attack_count_roll"] and player != state.active: return "This decision belongs to the active player."
	if not state.squads.has(squad) or state.squads[squad].owner != player or Morale.living(state, squad).is_empty(): return "Select one of your living units."
	if window.kind == "before_battle_shock":
		if state.phase != "command" or squad not in window.remaining or not Morale.needs_command_roll(state, squad): return "Select a unit that still needs this test."
	elif window.kind in ["after_advance_roll", "after_charge_roll"]:
		if not state.stratagems.get("movement_rerolls", false) or squad != window.squad: return "This roll belongs to another unit or ability."
		if state.phase != ("movement" if window.kind == "after_advance_roll" else "charge"): return "A fase da rolagem mudou."
	elif window.kind in ["after_hit_roll", "after_wound_roll"]:
		if not state.stratagems.get("attack_rerolls", false) or squad != window.squad or state.get("pending_attack", {}).is_empty(): return "This decision does not match the pending attack."
	elif window.kind == "after_save_roll":
		if not state.stratagems.get("save_rerolls", false) or squad != window.squad or state.get("pending_attack", {}).is_empty(): return "This decision does not match the pending save."
	elif window.kind == "after_damage_roll":
		if not state.stratagems.get("damage_rerolls", false) or squad != window.squad or state.get("pending_attack", {}).is_empty(): return "This decision does not match the pending damage roll."
	elif window.kind == "after_hazardous_roll":
		if not state.stratagems.get("hazard_rerolls", false) or squad != window.squad or state.get("pending_hazard", {}).is_empty(): return "This decision does not match the pending Hazardous pool."
	elif window.kind == "after_attack_count_roll":
		if not state.stratagems.get("count_rerolls", false) or squad != window.squad or state.get("pending_attack", {}).is_empty(): return "This decision does not match the pending attack generation."
	elif window.kind == "after_escape_roll":
		if not state.stratagems.get("escape_rerolls", false) or squad != window.squad or state.phase != "movement": return "This decision does not match Desperate Escape."
		var draft: Dictionary = state.get("pending_move", {})
		if draft.get("squad", -1) != squad or draft.get("move_type", "") != "desperate_escape" or draft.get("hazard_rolls", []) != window.rolls or not draft.get("spent", {}).is_empty(): return "Escape allocation or movement has already started."
	else: return "This decision window is not implemented."
	return ""

static func use_error(state: Dictionary, player: int, squad: int, stratagem: String, revision: int) -> String:
	var error := choice_error(state, player, squad, revision)
	if not error.is_empty(): return error
	if stratagem not in SUPPORTED: return "Stratagem is not implemented in this window."
	var rule: Dictionary = SUPPORTED[stratagem]
	if pending(state).kind not in rule.get("windows", [rule.get("window", "")]): return "Stratagem unavailable in this window."
	return eligibility_error(state, player, squad, stratagem)

static func eligibility_error(state: Dictionary, player: int, squad: int, stratagem: String) -> String:
	if stratagem not in SUPPORTED: return "Stratagem is not implemented in this window."
	if not state.has("stratagems"): return "Core stratagems are disabled."
	if stratagem == "command-re-roll" and not (state.stratagems.get("movement_rerolls", false) or state.stratagems.get("attack_rerolls", false) or state.stratagems.get("save_rerolls", false) or state.stratagems.get("damage_rerolls", false) or state.stratagems.get("hazard_rerolls", false) or state.stratagems.get("count_rerolls", false) or state.stratagems.get("escape_rerolls", false)): return "Command Re-roll is disabled."
	if not state.squads.has(squad) or state.squads[squad].owner != player: return "Invalid stratagem target."
	if not Morale.can_target_with_friendly_stratagem(state, squad): return "A Battle-shocked unit cannot be targeted by friendly stratagems."
	var rule: Dictionary = SUPPORTED[stratagem]
	if state.cp.get(player, 0) < rule.cost: return "CP insuficiente: este estratagema custa 1 CP."
	for use: Dictionary in state.stratagems.uses:
		if use.player != player: continue
		if use.stratagem == stratagem and rule.once_per_battle: return "You have already used Insane Bravery this battle."
		if use.phase_key == phase_key(state):
			if use.stratagem == stratagem: return "This stratagem has already been used this phase."
			if use.squad == squad: return "This unit has already been targeted by another stratagem this phase."
	return ""

static func open_roll(state: Dictionary, player: int, squad: int, kind: String, rolls: Array, draft: Dictionary = {}) -> bool:
	if not state.get("stratagems", {}).get("movement_rerolls", false) or not eligibility_error(state, player, squad, "command-re-roll").is_empty(): return false
	state.stratagems.pending = {"kind": kind, "player": player, "squad": squad, "phase_key": phase_key(state), "rolls": rolls.duplicate(), "draft": draft.duplicate(true)}
	return true

static func consume(state: Dictionary, player: int, squad: int, stratagem: String) -> void:
	# Internal operation, called only after all command/effect validation succeeds.
	state.cp[player] -= int(SUPPORTED[stratagem].cost)
	state.stratagems.uses.append({"player": player, "squad": squad, "stratagem": stratagem, "phase_key": phase_key(state), "turn": state.turn})
