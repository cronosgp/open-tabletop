extends SceneTree

const Combat = preload("res://scripts/edition_11/combat_scenario.gd")
const MatchCommands = preload("res://scripts/edition_11/match_command_service.gd")

var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var doctrine_state: Dictionary = Combat.initial_state()
	if doctrine_state.has("error"):
		check(false, "Match command service fixture loads: " + str(doctrine_state.error))
		quit(1)
		return
	doctrine_state.phase = "command"
	Combat.Doctrines.enable(doctrine_state)
	var doctrine_decision := Combat.Doctrines.pending_decision(doctrine_state)
	var no_doctrine_option := ""
	for option: Dictionary in doctrine_decision.legal_options:
		if option.value == "none": no_doctrine_option = str(option.id)
	var doctrine_revision := int(doctrine_state.revision)
	var doctrine_result := MatchCommands.execute(doctrine_state, 1, {
		"kind": MatchCommands.SELECT_DOCTRINE,
		"doctrine": "none",
		"decision_id": doctrine_decision.decision_id,
		"option_id": no_doctrine_option,
		"revision": doctrine_revision
	})
	check(doctrine_result.error.is_empty() and doctrine_result.message.begins_with("No doctrine"), "Doctrine command returns a presentation-neutral success result")
	check(doctrine_state.combat_doctrines.selected_turn.get(1, -1) == doctrine_state.turn and doctrine_state.revision > doctrine_revision, "Doctrine command applies the authoritative rule transition and journal event")

	var stale_state: Dictionary = Combat.initial_state()
	stale_state.phase = "command"
	Combat.Doctrines.enable(stale_state)
	var stale_decision := Combat.Doctrines.pending_decision(stale_state)
	var stale_option_id := ""
	for option: Dictionary in stale_decision.legal_options:
		if option.value == "none": stale_option_id = str(option.id)
	var before_stale := var_to_str(stale_state)
	var stale_result := MatchCommands.execute(stale_state, 1, {
		"kind": MatchCommands.SELECT_DOCTRINE,
		"doctrine": "none",
		"decision_id": stale_decision.decision_id,
		"option_id": stale_option_id,
		"revision": int(stale_state.revision) - 1
	})
	check(not stale_result.error.is_empty() and var_to_str(stale_state) == before_stale, "Stale match command is rejected without mutating match state")
	var missing_doctrine_envelope := MatchCommands.execute(stale_state, 1, {"kind": MatchCommands.SELECT_DOCTRINE, "doctrine": "none", "revision": int(stale_state.revision)})
	check(not missing_doctrine_envelope.error.is_empty() and var_to_str(stale_state) == before_stale, "A projected doctrine choice rejects a missing decision identity")
	var invalid_doctrine_option := MatchCommands.execute(stale_state, 1, {"kind": MatchCommands.SELECT_DOCTRINE, "doctrine": "none", "decision_id": stale_decision.decision_id, "option_id": "invalid-option", "revision": int(stale_state.revision)})
	check(not invalid_doctrine_option.error.is_empty() and var_to_str(stale_state) == before_stale, "A projected doctrine choice rejects an option ID outside the current legal set")

	var movement_state: Dictionary = Combat.initial_state()
	movement_state.phase = "movement"
	var advance_result := MatchCommands.execute(movement_state, 1, {
		"kind": MatchCommands.ADVANCE_PHASE,
		"revision": int(movement_state.revision),
		"model": -1
	})
	check(advance_result.error.is_empty() and movement_state.phase == "shooting", "Phase advancement executes through the match command service")
	check(advance_result.message.begins_with("Phase: shooting"), "Phase advancement returns its UI message without using UI nodes")

	var move_state: Dictionary = Combat.initial_state()
	move_state.phase = "movement"
	var begin_move_result := MatchCommands.execute(move_state, 1, {
		"kind": MatchCommands.BEGIN_MOVEMENT,
		"model": 100,
		"move_type": "normal",
		"revision": int(move_state.revision)
	})
	check(begin_move_result.error.is_empty() and not move_state.pending_move.is_empty(), "Movement declaration executes and creates its placement draft")
	check(begin_move_result.message.begins_with("Movement selected"), "Movement declaration returns its context-specific feedback")
	var finish_move_result := MatchCommands.execute(move_state, 1, {
		"kind": MatchCommands.FINISH_MOVEMENT,
		"revision": int(move_state.revision),
		"cancel": true
	})
	check(finish_move_result.error.is_empty() and move_state.pending_move.is_empty(), "Movement cancellation executes and clears its draft")
	check(finish_move_result.message == "Pending movement cancelled.", "Movement cancellation preserves its feedback")

	var charge_state: Dictionary = Combat.initial_state()
	charge_state.phase = "charge"
	charge_state.pending_charge = {"squad": 1}
	var decline_result := MatchCommands.execute(charge_state, 1, {
		"kind": MatchCommands.CHARGE_ROLL,
		"revision": int(charge_state.revision),
		"decline": true
	})
	check(decline_result.error.is_empty() and charge_state.pending_charge.is_empty(), "Declining a pending charge executes through the service")
	check(decline_result.message == "Charge finished without movement.", "Charge decline keeps its contextual feedback")

	var invalid_contact_state: Dictionary = Combat.initial_state()
	invalid_contact_state.phase = "movement"
	var before_invalid_contact := var_to_str(invalid_contact_state)
	var invalid_contact_result := MatchCommands.execute(invalid_contact_state, 1, {
		"kind": MatchCommands.BEGIN_CONTACT,
		"model": 100,
		"move_kind": "pile_in",
		"revision": int(invalid_contact_state.revision),
		"targets": [],
		"objective": -1
	})
	check(not str(invalid_contact_result.get("error", "")).is_empty() and var_to_str(invalid_contact_state) == before_invalid_contact, "Invalid contact movement is rejected without mutating match state")

	var invalid_attack_state: Dictionary = Combat.initial_state()
	invalid_attack_state.phase = "movement"
	var before_invalid_attack := var_to_str(invalid_attack_state)
	var invalid_shoot_result := MatchCommands.execute(invalid_attack_state, 1, {
		"kind": MatchCommands.SHOOT,
		"attacker": 100,
		"target": 200,
		"revision": int(invalid_attack_state.revision),
		"use_lethal": false
	}, func() -> int: return 4)
	check(not invalid_shoot_result.error.is_empty() and var_to_str(invalid_attack_state) == before_invalid_attack, "Shooting outside its legal phase is rejected without mutating match state")
	var invalid_attack_plan_result := MatchCommands.execute(invalid_attack_state, 1, {
		"kind": MatchCommands.ATTACK_PLAN,
		"attacker": 100,
		"entries": [],
		"revision": int(invalid_attack_state.revision),
		"melee": false,
		"use_lethal": false
	}, func() -> int: return 4)
	check(not invalid_attack_plan_result.error.is_empty() and var_to_str(invalid_attack_state) == before_invalid_attack, "Attack plans outside their legal phase are rejected without mutating match state")
	var invalid_fight_result := MatchCommands.execute(invalid_attack_state, 1, {
		"kind": MatchCommands.FIGHT,
		"attacker": 100,
		"target": 200,
		"revision": int(invalid_attack_state.revision)
	}, func() -> int: return 4)
	check(not invalid_fight_result.error.is_empty() and var_to_str(invalid_attack_state) == before_invalid_attack, "Fights outside their legal phase are rejected without mutating match state")

	var decision_state: Dictionary = Combat.initial_state()
	Combat.UnitAbilities.enable(decision_state)
	decision_state.phase = "fight"
	decision_state.squads[3] = decision_state.squads[2].duplicate(true)
	decision_state.squads[3].name = "Second reaction unit"
	decision_state.unit_abilities.window = {"kind": "bladeguard", "owners": [2], "remaining": [2, 3], "declaration": {}}
	var decision := Combat.UnitActions.pending_decision(decision_state)
	var selected_choice: Dictionary = {}
	for option: Dictionary in Combat.UnitActions.choices(decision_state, 2):
		if option.get("action", "") == "bladeguard" and option.get("value", "") == "attack": selected_choice = option
	var before_missing_envelope := var_to_str(decision_state)
	var missing_envelope_result := MatchCommands.execute(decision_state, 2, {
		"kind": MatchCommands.SELECT_UNIT_CHOICE,
		"choice": selected_choice,
		"point": Vector2.ZERO,
		"revision": int(decision_state.revision)
	})
	check(not missing_envelope_result.error.is_empty() and var_to_str(decision_state) == before_missing_envelope, "A projected decision rejects a choice without its current decision identity")
	var decision_envelope := {"_decision_type": MatchCommands.UNIT_CHOICE_ENVELOPE, "decision_id": decision.decision_id, "option_id": "invalid-option", "choice": selected_choice}
	var before_invalid_option := var_to_str(decision_state)
	var invalid_option_result := MatchCommands.execute(decision_state, 2, {
		"kind": MatchCommands.SELECT_UNIT_CHOICE,
		"choice": decision_envelope,
		"point": Vector2.ZERO,
		"revision": int(decision_state.revision)
	})
	check(not invalid_option_result.error.is_empty() and var_to_str(decision_state) == before_invalid_option, "A projected decision rejects an option ID outside the current legal set")
	var legal_option_id := ""
	for option: Dictionary in decision.legal_options:
		if option.action == selected_choice.action and option.value == selected_choice.value: legal_option_id = str(option.id)
	decision_envelope.option_id = legal_option_id
	var accepted_choice_result := MatchCommands.execute(decision_state, 2, {
		"kind": MatchCommands.SELECT_UNIT_CHOICE,
		"choice": decision_envelope,
		"point": Vector2.ZERO,
		"revision": int(decision_state.revision)
	})
	check(accepted_choice_result.error.is_empty() and decision_state.unit_abilities.window.remaining == [3], "A current decision and legal option identity authorize the specialized rule choice")
	var before_replayed_choice := var_to_str(decision_state)
	var replayed_choice_result := MatchCommands.execute(decision_state, 2, {
		"kind": MatchCommands.SELECT_UNIT_CHOICE,
		"choice": decision_envelope,
		"point": Vector2.ZERO,
		"revision": int(decision_state.revision)
	})
	check(not replayed_choice_result.error.is_empty() and var_to_str(decision_state) == before_replayed_choice, "A choice envelope from the previous revision cannot be replayed")

	var extracted_command_state: Dictionary = Combat.initial_state()
	var extracted_commands: Array[Dictionary] = [
		{"kind": MatchCommands.PLACE_MODEL, "model": -1, "destination": Vector2.ZERO, "revision": -1},
		{"kind": MatchCommands.DEPLOYMENT_PRESET, "revision": -1},
		{"kind": MatchCommands.DEPLOYMENT_CONFIRM, "revision": -1},
		{"kind": MatchCommands.ALLOCATE_DAMAGE, "model": -1, "revision": -1},
		{"kind": MatchCommands.REMOVE_COHERENCY, "model": -1, "revision": -1},
		{"kind": MatchCommands.COMMAND_REACTION, "squad": -1, "stratagem": "", "revision": -1},
		{"kind": MatchCommands.SELECT_OATH_TARGET, "target": -1, "revision": -1},
		{"kind": MatchCommands.RESOLVE_REANIMATION, "action": "invalid", "squad": -1, "model": -1, "point": Vector2.ZERO, "revision": -1},
		{"kind": MatchCommands.SELECT_AWAKENED_ATTACHMENT, "bodyguard": -1, "revision": -1},
	]
	for command: Dictionary in extracted_commands:
		var before_extracted_command := var_to_str(extracted_command_state)
		var extracted_result := MatchCommands.execute(extracted_command_state, 1, command, func() -> int: return 4)
		check(not str(extracted_result.get("error", "")).is_empty() and var_to_str(extracted_command_state) == before_extracted_command, "Extracted gameplay command %s fails closed without mutation" % str(command.kind))

	var reaction_state: Dictionary = Combat.initial_state()
	reaction_state.phase = "movement"
	reaction_state.cp[1] = 3
	Combat.Stratagems.enable(reaction_state, true)
	reaction_state.stratagems.pending = {"kind": "after_advance_roll", "player": 1, "squad": 1, "phase_key": Combat.Stratagems.phase_key(reaction_state), "rolls": [4], "draft": {"squad": 1}, "sudden": false, "supercharged": false, "honour_vigilance": false, "wrath_chapter": false, "stormseers_wisdom": false}
	var reaction_decision := Combat.Stratagems.pending_decision(reaction_state)
	check(not reaction_decision.is_empty() and int(reaction_decision.priority_player_id) == 1 and reaction_decision.legal_options.size() >= 2, "Roll reaction exposes accept and eligible re-roll options through the common projection")
	var accept_option_id := ""
	for option: Dictionary in reaction_decision.legal_options:
		if option.value == "": accept_option_id = str(option.id)
	var reaction_choice := {"action": "stratagem-reaction", "model": -1, "target": 1, "value": "", "die": -1}
	var before_unidentified_reaction := var_to_str(reaction_state)
	var unidentified_reaction := MatchCommands.execute(reaction_state, 1, {"kind": MatchCommands.COMMAND_REACTION, "choice": reaction_choice, "revision": int(reaction_state.revision)})
	check(not unidentified_reaction.error.is_empty() and var_to_str(reaction_state) == before_unidentified_reaction, "A reaction projection rejects an unidentified choice without mutation")
	var reaction_envelope := {"_decision_type": MatchCommands.STRATAGEM_DECISION_ENVELOPE, "decision_id": reaction_decision.decision_id, "option_id": accept_option_id, "choice": reaction_choice}
	reaction_state.revision = int(reaction_state.revision) + 1
	var before_replayed_reaction := var_to_str(reaction_state)
	var replayed_reaction := MatchCommands.execute(reaction_state, 1, {"kind": MatchCommands.COMMAND_REACTION, "choice": reaction_envelope, "revision": int(reaction_state.revision)})
	check(not replayed_reaction.error.is_empty() and var_to_str(reaction_state) == before_replayed_reaction, "A reaction option from an earlier revision cannot be replayed")

	var before_unknown := var_to_str(movement_state)
	var unknown_result := MatchCommands.execute(movement_state, 1, {"kind": "unregistered"})
	check(not unknown_result.error.is_empty() and var_to_str(movement_state) == before_unknown, "Unknown match command fails closed")
	print("Match command service checks: %d failures" % failures)
	quit(0 if failures == 0 else 1)
