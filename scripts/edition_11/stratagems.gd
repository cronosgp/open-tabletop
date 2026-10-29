extends RefCounted
const UnitAbilities = preload("res://scripts/edition_11/unit_abilities.gd")
## Core Rules §§01.07, 08.03, 15.01–15.12; reaction cards live in core_reactions.gd.
const Morale = preload("res://scripts/edition_11/morale.gd")
const ReactionState = preload("res://scripts/edition_11/core_reaction_state.gd")
const StormlanceEnhancements = preload("res://scripts/edition_11/stormlance_enhancements.gd")
const Doctrines = preload("res://scripts/edition_11/combat_doctrines.gd")
const PendingDecision = preload("res://scripts/edition_11/pending_decision.gd")
const ID := "core-stratagem-windows-v1"
const REROLL_ID := "command-reroll-movement-v1"
const ATTACK_REROLL_ID := "command-reroll-hit-wound-v1"
const COUNT_REROLL_ID := "command-reroll-attack-count-v1"
const HAZARD_REROLL_ID := "command-reroll-hazard-pools-v2"
const ESCAPE_REROLL_ID := "command-reroll-escape-hazard-v1"
const DAMAGE_REROLL_ID := "command-reroll-damage-v1"
const SAVE_REROLL_ID := "command-reroll-save-v1"
const DEATHWATCH_TERMINATUS_BATTLE_SHOCK := "after_deathwatch_terminatus_battle_shock_roll"
const SUPPORTED := {"insane-bravery": {"cost": 1, "window": "before_battle_shock", "phase": "command", "once_per_battle": true},
	"command-re-roll": {"cost": 1, "windows": ["after_advance_roll", "after_charge_roll", "after_hit_roll", "after_wound_roll", "after_save_roll", "after_damage_roll", "after_hazardous_roll", "after_transport_hazard_roll", "after_attack_count_roll", "after_escape_roll"], "once_per_battle": false},
	"fire-overwatch": {"cost": 1, "window": "end_movement", "once_per_battle": false},
	"heroic-intervention": {"cost": 1, "window": "end_charge", "once_per_battle": false},
	"counteroffensive": {"cost": 2, "window": "after_enemy_fights", "once_per_battle": false},
	"epic-challenge": {"cost": 1, "window": "selected_to_fight", "once_per_battle": false},
	"crushing-impact": {"cost": 1, "window": "immediately_after_monster_or_vehicle_charge", "once_per_battle": false},
	"explosives": {"cost": 1, "window": "own_shooting_before_shooting", "once_per_battle": false}}

static func enable(state: Dictionary, movement_rerolls: bool = false, attack_rerolls: bool = false, save_rerolls: bool = false, damage_rerolls: bool = false, hazard_rerolls: bool = false, count_rerolls: bool = false, escape_rerolls: bool = false) -> Dictionary:
	if state.has("error") or state.has("stratagems"): return state
	state.stratagems = {"implementation": ID, "pending": {}, "uses": [], "command_done_turn": -1}
	state.pack_hash = (str(state.pack_hash) + ID).sha256_text()
	state.scope = "Core stratagem supported: Insane Bravery before Command battle-shock only. " + str(state.get("scope", "")).replace("stratagems,", "other stratagems,")
	ReactionState.enable(state)
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
		state.scope = "Command Re-roll supported for Hazard rolls from weapons and transport disembarkation before mortal-wound allocation. Desperate Escape uses its separately gated hazard re-roll. " + state.scope
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

## Common read-only view for roll and Battle-shock reaction windows.
## choice_error/use_error and the specialized resolvers remain authoritative.
static func pending_decision(state: Dictionary) -> Dictionary:
	var window := pending(state)
	if window.is_empty(): return {}
	for required: String in ["revision", "squads", "units", "cp", "active", "turn", "phase"]:
		if not state.has(required): return {}
	var owner := int(window.get("player", -1))
	if owner not in [1, 2]: return {}
	var squads: Array = window.get("remaining", []) if window.get("kind", "") == "before_battle_shock" else [int(window.get("squad", -1))]
	var options: Array[Dictionary] = []
	for squad_value: Variant in squads:
		var squad := int(squad_value)
		if not choice_error(state, owner, squad, int(state.get("revision", -1))).is_empty(): continue
		var accept_label := "Roll Battle-shock normally" if window.kind == "before_battle_shock" else "Accept the current result"
		options.append(_decision_option(accept_label, squad, "", -1))
		if window.kind == "before_battle_shock":
			if use_error(state, owner, squad, "insane-bravery", int(state.get("revision", -1))).is_empty():
				options.append(_decision_option("Insane Bravery: pass without rolling", squad, "insane-bravery", -1))
			if UnitAbilities.potential_discount(state, owner, squad) > 0 and UnitAbilities.discount(state, owner, squad) == 0:
				options.append(_decision_option("My Will Be Done: reduce Insane Bravery by 1 CP", squad, "my-will-be-done", -1))
			continue
		if window.kind in ["after_battle_shock_roll", "after_escape_battle_shock_roll", DEATHWATCH_TERMINATUS_BATTLE_SHOCK]:
			if StormlanceEnhancements.leadership_reroll_available(state, squad):
				options.append(_decision_option("%s: re-roll both dice" % StormlanceEnhancements.leadership_reroll_name(state, squad), squad, "tempered-in-battle", -1))
			continue
		var stratagems: Array[String] = []
		if use_error(state, owner, squad, "command-re-roll", int(state.get("revision", -1))).is_empty(): stratagems.append("command-re-roll")
		if window.kind == "after_advance_roll":
			if window.get("bestial_fury", false): stratagems.append("bestial-fury")
			if window.get("overcharged_engines", false): stratagems.append("overcharged-engines")
			if window.get("sudden", false): stratagems.append("sudden-storm")
			if window.get("supercharged", false): stratagems.append("supercharged-engines")
			if window.get("honour_vigilance", false): stratagems.append("honour-of-vigilance")
			if window.get("wrath_chapter", false): stratagems.append("wrath-of-the-chapter")
			if window.get("stormseers_wisdom", false): stratagems.append("stormseers-wisdom")
			if window.get("righteous_fervour", false) and StormlanceEnhancements.righteous_fervour_active(state, squad): stratagems.append("righteous-fervour")
		elif window.kind == "after_charge_roll":
			if window.get("bestial_fury", false): stratagems.append("bestial-fury")
			if window.get("valour", false): stratagems.append("unstoppable-valour")
			if window.get("master_shadows", false): stratagems.append("master-shadows")
			if window.get("lord_of_the_ravenwing", false): stratagems.append("lord-of-the-ravenwing")
			if window.get("linebreaker_onslaught", false): stratagems.append("linebreaker-onslaught")
			if window.get("deathwatch_terminatus_assault", false): stratagems.append("deathwatch-terminatus-assault")
		var die_options: Array = window.get("eligible", []) if window.kind in ["after_hit_roll", "after_wound_roll", "after_save_roll", "after_damage_roll", "after_hazardous_roll", "after_transport_hazard_roll", "after_attack_count_roll", "after_escape_roll"] else [-1]
		for stratagem: String in stratagems:
			for die_value: Variant in die_options:
				var label := "%s · %s" % [stratagem, "all dice" if int(die_value) < 0 else "die %d" % (int(die_value) + 1)]
				if stratagem == "linebreaker-onslaught": label = "Linebreaker Onslaught · re-roll both Charge dice"
				elif stratagem == "overcharged-engines": label = "Overcharged Engines · re-roll the Advance"
				elif stratagem == "bestial-fury": label = "Bestial Fury · re-roll the %s roll" % ("Advance" if window.kind == "after_advance_roll" else "Charge")
				options.append(_decision_option(label, squad, stratagem, int(die_value)))
	if options.is_empty(): return {}
	return PendingDecision.create(state, "stratagems", "reaction:%s" % str(window.get("kind", "")), owner, options, true)

static func _decision_option(label: String, squad: int, stratagem: String, die: int) -> Dictionary:
	return {"label": label, "action": "stratagem-reaction", "model": -1, "target": squad, "value": stratagem, "details": {"die": die}}

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
	if window.kind not in ["after_hit_roll", "after_wound_roll", "after_save_roll", "after_damage_roll", "after_hazardous_roll", "after_transport_hazard_roll", "after_attack_count_roll", DEATHWATCH_TERMINATUS_BATTLE_SHOCK] and player != state.active and not (window.kind == "after_charge_roll" and ReactionState.heroic_charger(state, player, squad)): return "This decision belongs to the active player."
	var has_living_model := not Morale.living(state, squad).is_empty()
	if window.kind == "after_transport_hazard_roll":
		has_living_model = false
		for model: int in state.units:
			if int(state.units[model].get("squad", -1)) == squad and int(state.units[model].get("wounds", 0)) > 0:
				has_living_model = true
				break
	if not state.squads.has(squad) or state.squads[squad].owner != player or not has_living_model: return "Select one of your living units."
	if window.kind == "before_battle_shock":
		if state.phase != "command" or squad not in window.remaining or not Morale.needs_command_roll(state, squad): return "Select a unit that still needs this test."
	elif window.kind == "after_battle_shock_roll":
		if state.phase != "command" or squad != int(window.get("squad", -1)) or squad not in window.get("remaining", []) or window.get("current_result", {}).is_empty():
			return "This Leadership result is no longer pending."
	elif window.kind == "after_escape_battle_shock_roll":
		var draft: Dictionary = state.get("pending_move", {})
		if state.phase != "movement" or draft.get("move_type", "") != "desperate_escape" or int(draft.get("squad", -1)) != squad or int(window.get("squad", -1)) != squad or window.get("current_result", {}).is_empty():
			return "This Desperate Escape Leadership result is no longer pending."
	elif window.kind == DEATHWATCH_TERMINATUS_BATTLE_SHOCK:
		if state.phase != "charge" or int(window.get("squad", -1)) != squad or window.get("current_result", {}).is_empty(): return "This Deathwatch Terminatus Assault Battle-shock result is no longer pending."
	elif window.kind in ["after_advance_roll", "after_charge_roll"]:
		if squad != window.squad: return "This roll belongs to another unit or ability."
		if window.kind == "after_charge_roll" and not (state.stratagems.get("movement_rerolls", false) or window.get("valour", false) or window.get("master_shadows", false) or window.get("lord_of_the_ravenwing", false) or window.get("linebreaker_onslaught", false) or window.get("deathwatch_terminatus_assault", false) or window.get("bestial_fury", false)): return "This roll belongs to another unit or ability."
		if window.kind == "after_charge_roll" and window.get("lord_of_the_ravenwing", false) and not StormlanceEnhancements.lord_of_the_ravenwing_active(state, squad): return "Lord of the Ravenwing is no longer active for this Charge."
		if window.kind == "after_charge_roll" and window.get("linebreaker_onslaught", false) and not StormlanceEnhancements.linebreaker_onslaught_active(state, squad): return "Linebreaker Onslaught is no longer active for this Charge."
		if window.kind == "after_advance_roll" and not (state.stratagems.get("movement_rerolls", false) or window.get("overcharged_engines", false) or window.get("sudden", false) or window.get("supercharged", false) or window.get("honour_vigilance", false) or window.get("wrath_chapter", false) or window.get("stormseers_wisdom", false) or window.get("righteous_fervour", false) or window.get("bestial_fury", false)): return "This roll belongs to another unit or ability."
		if window.kind == "after_advance_roll" and window.get("righteous_fervour", false) and not StormlanceEnhancements.righteous_fervour_active(state, squad): return "Righteous Fervour is no longer active for this Advance."
		if state.phase != ("movement" if window.kind == "after_advance_roll" else "charge"): return "A fase da rolagem mudou."
	elif window.kind in ["after_hit_roll", "after_wound_roll"]:
		if not state.stratagems.get("attack_rerolls", false) or squad != window.squad or state.get("pending_attack", {}).is_empty(): return "This decision does not match the pending attack."
	elif window.kind == "after_save_roll":
		if not state.stratagems.get("save_rerolls", false) or squad != window.squad or state.get("pending_attack", {}).is_empty(): return "This decision does not match the pending save."
	elif window.kind == "after_damage_roll":
		if not state.stratagems.get("damage_rerolls", false) or squad != window.squad or state.get("pending_attack", {}).is_empty(): return "This decision does not match the pending damage roll."
	elif window.kind == "after_hazardous_roll":
		if not state.stratagems.get("hazard_rerolls", false) or squad != window.squad or state.get("pending_hazard", {}).is_empty(): return "This decision does not match the pending Hazardous pool."
	elif window.kind == "after_transport_hazard_roll":
		var transport_window: Dictionary = state.get("unit_abilities", {}).get("transport_window", {})
		if not state.stratagems.get("hazard_rerolls", false) or squad != int(window.get("squad", -1)) or transport_window.is_empty() or transport_window.get("stage", "") != "hazard-reroll" or int(transport_window.get("passenger_squad", -1)) != squad or transport_window.get("hazard_rolls", []) != window.get("rolls", []):
			return "This decision does not match the pending transport Hazard pool."
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
	if stratagem == "overcharged-engines":
		var window := pending(state)
		return "Overcharged Engines Advance re-roll is not available." if window.kind != "after_advance_roll" or not window.get("overcharged_engines", false) else ""
	if stratagem not in SUPPORTED: return "Stratagem is not implemented in this window."
	var rule: Dictionary = SUPPORTED[stratagem]
	if pending(state).kind not in rule.get("windows", [rule.get("window", "")]): return "Stratagem unavailable in this window."
	if stratagem == "command-re-roll" and pending(state).kind in ["after_advance_roll", "after_charge_roll"] and not state.stratagems.get("movement_rerolls", false): return "Command Re-roll is disabled for Advance and Charge rolls."
	if state.cp.get(player, 0) < int(rule.cost) - UnitAbilities.discount(state, player, squad): return "Choose My Will Be Done or pay the normal CP cost."
	return eligibility_error(state, player, squad, stratagem)

static func eligibility_error(state: Dictionary, player: int, squad: int, stratagem: String) -> String:
	if stratagem not in SUPPORTED: return "Stratagem is not implemented in this window."
	if not state.has("stratagems"): return "Core stratagems are disabled."
	if stratagem == "command-re-roll" and not (state.stratagems.get("movement_rerolls", false) or state.stratagems.get("attack_rerolls", false) or state.stratagems.get("save_rerolls", false) or state.stratagems.get("damage_rerolls", false) or state.stratagems.get("hazard_rerolls", false) or state.stratagems.get("count_rerolls", false) or state.stratagems.get("escape_rerolls", false)): return "Command Re-roll is disabled."
	if not state.squads.has(squad) or state.squads[squad].owner != player: return "Invalid stratagem target."
	if not Morale.can_target_with_friendly_stratagem(state, squad): return "A Battle-shocked unit cannot be targeted by friendly stratagems."
	var rule: Dictionary = SUPPORTED[stratagem]
	if state.cp.get(player, 0) < int(rule.cost) - UnitAbilities.potential_discount(state, player, squad): return "CP insuficiente: este estratagema custa %d CP." % int(rule.cost)
	for use: Dictionary in state.stratagems.uses:
		if use.player != player: continue
		if use.stratagem == stratagem and rule.once_per_battle: return "You have already used Insane Bravery this battle."
		if use.phase_key == phase_key(state):
			if use.stratagem == stratagem: return "This stratagem has already been used this phase."
			if use.squad == squad: return "This unit has already been targeted by another stratagem this phase."
	return ""

static func open_roll(state: Dictionary, player: int, squad: int, kind: String, rolls: Array, draft: Dictionary = {}, wrath_chapter: bool = false) -> bool:
	var master_shadows: bool = kind == "after_charge_roll" and UnitAbilities.master_shadows_active(state, squad)
	var lord_of_the_ravenwing: bool = kind == "after_charge_roll" and StormlanceEnhancements.lord_of_the_ravenwing_active(state, squad)
	var linebreaker_onslaught: bool = kind == "after_charge_roll" and StormlanceEnhancements.linebreaker_onslaught_active(state, squad)
	var deathwatch_terminatus_assault: bool = kind == "after_charge_roll" and UnitAbilities.has(state, squad, "deathwatch-terminatus-assault")
	var supercharged: bool = kind == "after_advance_roll" and StormlanceEnhancements.active(state, squad, StormlanceEnhancements.SUPERCHARGED)
	var honour_vigilance: bool = kind == "after_advance_roll" and Doctrines.has_doctrine(state, squad, "devastator") and StormlanceEnhancements.honour_of_vigilance_active(state, squad)
	var stormseers_wisdom: bool = kind == "after_advance_roll" and StormlanceEnhancements.stormseers_wisdom_active(state, squad)
	var righteous_fervour: bool = kind == "after_advance_roll" and StormlanceEnhancements.righteous_fervour_active(state, squad)
	var bestial_fury: bool = UnitAbilities.has(state, squad, "bestial-fury")
	var overcharged_engines: bool = kind == "after_advance_roll" and UnitAbilities.has(state, squad, "overcharged-engines")
	var command_reroll: bool = state.get("stratagems", {}).get("movement_rerolls", false) and eligibility_error(state, player, squad, "command-re-roll").is_empty()
	if not command_reroll and not overcharged_engines and not master_shadows and not lord_of_the_ravenwing and not linebreaker_onslaught and not deathwatch_terminatus_assault and not supercharged and not honour_vigilance and not wrath_chapter and not stormseers_wisdom and not righteous_fervour and not bestial_fury: return false
	if not state.has("stratagems"): state.stratagems = {"pending": {}, "uses": [], "command_done_turn": -1}
	state.stratagems.pending = {"kind": kind, "player": player, "squad": squad, "phase_key": phase_key(state), "rolls": rolls.duplicate(), "draft": draft.duplicate(true), "master_shadows": master_shadows, "lord_of_the_ravenwing": lord_of_the_ravenwing, "linebreaker_onslaught": linebreaker_onslaught, "deathwatch_terminatus_assault": deathwatch_terminatus_assault, "supercharged": supercharged, "honour_vigilance": honour_vigilance, "wrath_chapter": wrath_chapter, "stormseers_wisdom": stormseers_wisdom, "righteous_fervour": righteous_fervour, "bestial_fury": bestial_fury, "overcharged_engines": overcharged_engines}
	return true

static func consume(state: Dictionary, player: int, squad: int, stratagem: String) -> void:
	# Internal operation, called only after all command/effect validation succeeds.
	state.cp[player] -= maxi(0, int(SUPPORTED[stratagem].cost) - UnitAbilities.discount(state, player, squad))
	UnitAbilities.consume_discount(state, player, squad)
	state.stratagems.uses.append({"player": player, "squad": squad, "stratagem": stratagem, "phase_key": phase_key(state), "turn": state.turn})
