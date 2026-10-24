extends SceneTree

const Prepared = preload("res://scripts/edition_11/prepared_training.gd")
const ArmyCapabilities = preload("res://scripts/edition_11/army_capabilities.gd")
const Enhancements = preload("res://scripts/edition_11/stormlance_enhancements.gd")
const MatchCommandService = preload("res://scripts/edition_11/match_command_service.gd")
const C = Prepared.Combat

var dice: Array[int] = [2, 1, 6, 6, 6, 2, 1, 6, 6]
var dice_index := 0
var failures := 0

func die() -> int:
	var result := dice[dice_index]
	dice_index += 1
	return result

func choose_no_doctrine(state: Dictionary, player: int) -> String:
	var decision := C.Doctrines.pending_decision(state)
	for option: Dictionary in decision.get("legal_options", []):
		if str(option.get("value", "")) != "none": continue
		var result := MatchCommandService.execute(state, player, {"kind": MatchCommandService.SELECT_DOCTRINE, "doctrine": "none", "decision_id": str(decision.get("decision_id", "")), "option_id": str(option.get("id", "")), "revision": int(state.revision)})
		return str(result.get("error", ""))
	return "No projected no-doctrine option."

func submit_stratagem_choice(state: Dictionary, player: int, target: int, value: String) -> Dictionary:
	var decision := C.Stratagems.pending_decision(state)
	var projected: Dictionary = {}
	for option: Dictionary in decision.get("legal_options", []):
		if int(option.get("target", -1)) == target and str(option.get("value", "")) == value and int(option.get("details", {}).get("die", -1)) == -1: projected = option; break
	if projected.is_empty(): return {"error": "The current roll decision does not offer %s." % value}
	var choice := {"action": "stratagem-reaction", "model": -1, "target": target, "value": value, "die": -1}
	var envelope := {"_decision_type": MatchCommandService.STRATAGEM_DECISION_ENVELOPE, "decision_id": str(decision.get("decision_id", "")), "option_id": str(projected.get("id", "")), "choice": choice}
	return MatchCommandService.execute(state, player, {"kind": MatchCommandService.COMMAND_REACTION, "choice": envelope, "revision": int(state.revision)}, Callable(self, "die"))

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var identity := "40kdc:11e:adeptus-astartes:captain-on-bike"
	var options := Enhancements.catalog_records([identity])
	check(Enhancements.valid_for(identity, Enhancements.TEMPERED_IN_BATTLE, Enhancements.WRATH_OF_THE_ROCK), "Tempered in Battle is available to an eligible Astartes bearer under Wrath of the Rock")
	var catalog_exposes_tempered := false
	for record: Dictionary in options:
		if record.get("id", "") == Enhancements.TEMPERED_IN_BATTLE: catalog_exposes_tempered = true
	check(catalog_exposes_tempered, "The completed enhancement is exposed in the local construction catalog")

	var own_army := {
		"schema_version": 2,
		"faction": "Space Marines",
		"category": "training",
		"points_limit": 500,
		"entries": [
			{"definition_id": identity, "models": 1, "copies": 1, "enhancement_id": Enhancements.TEMPERED_IN_BATTLE},
			{"definition_id": "40kdc:11e:adeptus-astartes:outrider-squad", "models": 3, "copies": 1, "enhancement_id": ""}
		]
	}
	var invalid_army: Dictionary = own_army.duplicate(true)
	invalid_army.entries[0].enhancement_id = Enhancements.TEMPERED_IN_BATTLE
	check(ArmyCapabilities.admit(own_army).error.is_empty(), "Roster admission accepts the completed enhancement for an eligible bearer")
	var enemy_army := {
		"schema_version": 2,
		"faction": "Space Marines",
		"category": "training",
		"points_limit": 500,
		"entries": [{"definition_id": "40kdc:11e:adeptus-astartes:storm-speeder-hailstrike", "models": 1, "copies": 1, "enhancement_id": ""}]
	}
	var state := Prepared.initial_state({"manual_allocation": false, "core_stratagems": true, "unit_abilities": true, "combat_doctrines": true, "marine_detachments": {1: Enhancements.WRATH_OF_THE_ROCK, 2: Enhancements.WRATH_OF_THE_ROCK}}, {1: own_army, 2: enemy_army})
	check(not state.has("error"), "A prepared Wrath match materializes with Tempered in Battle admitted")
	if state.has("error"):
		print("Tempered in Battle checks: %d failures" % (failures + 1))
		quit(1)
		return

	var bearer_squad := -1
	var bearer_model := -1
	var target_squad := -1
	var enemy_squad := -1
	for squad: int in state.squads:
		var living_models := C.living(state, squad)
		var def_id := str(state.units[living_models[0]].get("definition_id", "")) if not living_models.is_empty() else ""
		if def_id.ends_with(":captain-on-bike"):
			bearer_squad = squad
			bearer_model = C.living(state, squad)[0]
		elif def_id.ends_with(":outrider-squad"):
			target_squad = squad
		elif state.squads[squad].owner == 2:
			enemy_squad = squad
	check(bearer_squad > 0 and bearer_model >= 0 and target_squad > 0 and enemy_squad > 0, "The expected Astartes bearer, test unit and opponent are materialized")
	if bearer_squad < 0 or bearer_model < 0 or target_squad < 0 or enemy_squad < 0:
		print("Tempered in Battle checks: %d failures" % failures)
		quit(1)
		return

	state.units[bearer_model].position = Vector2.ZERO
	for model: int in C.living(state, target_squad):
		state.units[model].position = Vector2(2, 0)
	for model: int in C.living(state, target_squad).slice(1): state.units[model].wounds = 0
	check(Enhancements.tempered_in_battle_active(state, target_squad), "The assigned bearer grants the aura to an Astartes unit within 6 inches")
	state.units[bearer_model].position = Vector2(-12, 0)
	check(not Enhancements.tempered_in_battle_active(state, target_squad), "The aura checks base-edge distance and is inactive beyond 6 inches")
	state.units[bearer_model].position = Vector2.ZERO

	state.phase = "command"
	state.active = 1
	state.turn = 1
	state.revision = 0
	state.unit_abilities.phase_key = C.UnitActions.key(state)
	var close_result := MatchCommandService.execute(state, 1, {"kind": MatchCommandService.ADVANCE_PHASE, "revision": int(state.revision)}, die)
	var close_error := str(close_result.get("error", ""))
	if C.Doctrines.needs_choice(state):
		var doctrine_error := choose_no_doctrine(state, 1)
		if doctrine_error.is_empty():
			close_result = MatchCommandService.execute(state, 1, {"kind": MatchCommandService.ADVANCE_PHASE, "revision": int(state.revision)}, die)
			close_error = str(close_result.get("error", ""))
	check(close_error.is_empty(), "Command close opens the normal pre-test decision: " + close_error)
	check(C.Stratagems.pending(state).get("kind", "") == "before_battle_shock", "The Command phase resolves its existing pre-roll choice first")
	var roll_result := submit_stratagem_choice(state, 1, target_squad, "")
	check(str(roll_result.get("error", "")).is_empty(), "The active player rolls the Leadership test through the public command: " + str(roll_result.get("error", "")))
	check(C.Stratagems.pending(state).get("kind", "") == "after_battle_shock_roll" and not state.squads[target_squad].battle_shocked, "The current result is held for an optional aura decision before applying Battle-shock")
	var decision := C.Stratagems.pending_decision(state)
	var reroll_option := false
	for option: Dictionary in decision.get("legal_options", []):
		if option.get("value", "") == "tempered-in-battle": reroll_option = true
	check(reroll_option and decision.get("priority_player_id", -1) == 1, "The normalized decision offers the free reroll to the unit's controller")
	var frame := C.ResolutionFrames.current(state)
	var restored: Dictionary = bytes_to_var(var_to_bytes(state))
	var restored_decision := C.Stratagems.pending_decision(restored)
	check(restored_decision.get("decision_id", "") == decision.get("decision_id", "") and restored_decision.get("legal_options", []) == decision.get("legal_options", []) and C.ResolutionFrames.current(restored) == frame, "The Leadership decision and Command phase-close frame survive serialization")
	var before_close := var_to_bytes(restored)
	check(not C.advance_phase(restored, 1, restored.revision, die).is_empty() and var_to_bytes(restored) == before_close, "The pending reroll still blocks phase close without mutation")
	state = restored
	var before_wrong_reroll_owner := var_to_bytes(state)
	var wrong_reroll_owner := submit_stratagem_choice(state, 2, target_squad, "tempered-in-battle")
	check(not str(wrong_reroll_owner.get("error", "")).is_empty() and var_to_bytes(state) == before_wrong_reroll_owner, "The opponent cannot submit or mutate Tempered in Battle's Command decision")
	var reroll_result := submit_stratagem_choice(state, 1, target_squad, "tempered-in-battle")
	check(str(reroll_result.get("error", "")).is_empty(), "Tempered in Battle re-rolls the complete 2D6 Leadership roll through the public command: " + str(reroll_result.get("error", "")))
	check(dice_index == 4 and state.last_morale.size() == 1 and state.last_morale[0].get("rerolled_from", []) == [2, 1] and state.last_morale[0].rolls == [6, 6] and state.last_morale[0].passed, "The replacement result is recorded and determines the Battle-shock outcome")
	check(not state.squads[target_squad].battle_shocked and state.phase == "movement" and C.ResolutionFrames.current(state).is_empty(), "Command close resumes after the reroll and applies the passing result")

	var escape_model: int = C.living(state, target_squad)[0]
	var enemy_model: int = C.living(state, enemy_squad)[0]
	state.units[bearer_model].position = Vector2(-4, -3)
	state.units[escape_model].position = Vector2(2, -8)
	state.units[enemy_model].position = Vector2(3, -8)
	check(C.begin_movement(state, 1, escape_model, "desperate_escape", state.revision, die).is_empty(), "A steady engaged unit can declare Desperate Escape")
	check(C.Stratagems.pending(state).is_empty() and state.pending_move.get("hazard_remaining", 0) == 0, "The non-hazardous escape roll proceeds to placement")
	var escape_move_error := C.move(state, 1, escape_model, Vector2(-7, -8), state.revision)
	check(escape_move_error.is_empty(), "The Outrider can move clear of Engagement Range: " + escape_move_error)
	var escape_finish := C.finish_movement(state, 1, state.revision, false, die)
	check(escape_finish.is_empty(), "Escape confirmation opens the Leadership reroll decision: " + escape_finish)
	var escape_decision := C.Stratagems.pending_decision(state)
	var escape_reroll_offered := false
	for option: Dictionary in escape_decision.get("legal_options", []):
		if option.get("value", "") == "tempered-in-battle": escape_reroll_offered = true
	check(escape_reroll_offered and C.Stratagems.pending(state).get("kind", "") == "after_escape_battle_shock_roll", "Desperate Escape suspends before applying the Leadership result and offers the aura reroll: " + str(C.Stratagems.pending(state)) + " decision=" + str(escape_decision) + " pending_move=" + str(state.pending_move) + " morale=" + str(state.last_morale))
	var escape_frame := C.ResolutionFrames.current(state)
	var escape_restored: Dictionary = bytes_to_var(var_to_bytes(state))
	var escape_restored_decision := C.Stratagems.pending_decision(escape_restored)
	check(escape_restored_decision.get("decision_id", "") == escape_decision.get("decision_id", "") and escape_restored_decision.get("legal_options", []) == escape_decision.get("legal_options", []) and C.ResolutionFrames.current(escape_restored) == escape_frame and escape_frame.get("status", "") == "suspended", "The escape decision and movement continuation survive serialization")
	var before_escape_close := var_to_bytes(escape_restored)
	check(not C.advance_phase(escape_restored, 1, escape_restored.revision, die).is_empty() and var_to_bytes(escape_restored) == before_escape_close, "The Desperate Escape reroll blocks phase close without mutation")
	state = escape_restored
	var before_wrong_escape_owner := var_to_bytes(state)
	var wrong_escape_owner := submit_stratagem_choice(state, 2, target_squad, "tempered-in-battle")
	check(not str(wrong_escape_owner.get("error", "")).is_empty() and var_to_bytes(state) == before_wrong_escape_owner, "The opponent cannot submit or mutate the Desperate Escape morale decision")
	var escape_reroll_result := submit_stratagem_choice(state, 1, target_squad, "tempered-in-battle")
	check(str(escape_reroll_result.get("error", "")).is_empty(), "The controller resolves Tempered in Battle and resumes movement through the public command: " + str(escape_reroll_result.get("error", "")))
	check(state.phase == "movement" and state.squads[target_squad].fell_back and state.squads[target_squad].moved and state.pending_move.is_empty(), "The confirmed Desperate Escape completes after the Leadership decision")
	check(state.last_morale.size() == 1 and state.last_morale[0].get("rerolled_from", []) == [2, 1] and state.last_morale[0].rolls == [6, 6] and not state.squads[target_squad].battle_shocked and C.ResolutionFrames.current(state).is_empty(), "The replacement Leadership result is recorded and the movement frame completes")
	var no_core_state: Dictionary = state.duplicate(true)
	no_core_state.phase = "command"
	no_core_state.active = 1
	no_core_state.erase("stratagems")
	no_core_state.squads[target_squad].battle_shocked = false
	no_core_state.unit_abilities.phase_key = C.UnitActions.key(no_core_state)
	var no_core_error := C.advance_phase(no_core_state, 1, no_core_state.revision, func() -> int: return 2)
	var no_core_decision := C.UnitActions.pending_decision(no_core_state)
	check(no_core_error.is_empty() and C.UnitActions.actor(no_core_state) == 1 and no_core_decision.get("source", "") == "unit-actions", "The no-Core-Stratagem Command fallback suspends for the tested unit's reroll decision: " + no_core_error)
	check(not no_core_state.squads[target_squad].battle_shocked and not C.ResolutionFrames.current(no_core_state).is_empty(), "The no-Core-Stratagem result remains unapplied under a saved phase-close frame")
	var no_core_restore: Dictionary = bytes_to_var(var_to_bytes(no_core_state))
	var no_core_reroll: Dictionary = {}
	for option: Dictionary in C.unit_choices(no_core_restore, 1):
		if option.get("action", "") == "command-battle-shock-decision" and option.get("value", "") == "tempered-in-battle": no_core_reroll = option
	check(not no_core_reroll.is_empty(), "The serialized fallback offers the eligible full Leadership re-roll")
	if not no_core_reroll.is_empty():
		no_core_decision = C.UnitActions.pending_decision(no_core_restore)
		var projected_reroll: Dictionary = {}
		for option: Dictionary in no_core_decision.get("legal_options", []):
			if option.get("action", "") == "command-battle-shock-decision" and option.get("value", "") == "tempered-in-battle": projected_reroll = option; break
		var before_fallback_close := var_to_bytes(no_core_restore)
		var blocked_fallback_close := C.advance_phase(no_core_restore, 1, no_core_restore.revision, die)
		check(not blocked_fallback_close.is_empty() and var_to_bytes(no_core_restore) == before_fallback_close, "The suspended fallback decision blocks a premature phase close without mutation")
		var normalized_fallback_reroll := MatchCommandService.execute(no_core_restore, 1, {"kind": MatchCommandService.SELECT_UNIT_CHOICE, "revision": no_core_restore.revision, "choice": {"_decision_type": MatchCommandService.UNIT_CHOICE_ENVELOPE, "decision_id": str(no_core_decision.get("decision_id", "")), "option_id": str(projected_reroll.get("id", "")), "choice": no_core_reroll}}, func() -> int: return 6)
		check(not projected_reroll.is_empty() and str(normalized_fallback_reroll.get("error", "")).is_empty() and no_core_restore.phase == "movement" and C.UnitActions.pending(no_core_restore).is_empty() and C.UnitActions.pending_decision(no_core_restore).is_empty() and C.ResolutionFrames.current(no_core_restore).is_empty(), "The normalized fallback reroll applies and completes its Command continuation: " + str(normalized_fallback_reroll.get("error", "")))

	print("Tempered in Battle checks: %d failures" % failures)
	quit(0 if failures == 0 else 1)
