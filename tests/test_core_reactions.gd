extends SceneTree
const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const R = preload("res://scripts/edition_11/core_reactions.gd")
const Attacks = preload("res://scripts/edition_11/attack_sequence.gd")
const MatchCommands = preload("res://scripts/edition_11/match_command_service.gd")
const PhaseCloseGate = preload("res://scripts/edition_11/phase_close_gate.gd")
const PendingDecisions = preload("res://scripts/edition_11/pending_decision_registry.gd")
const ResolutionFrames = preload("res://scripts/edition_11/resolution_frame.gd")
var failures := 0
func check(ok: bool, message: String) -> void:
	if not ok: push_error(message); failures += 1
func fixture() -> Dictionary:
	var s := F.P.initial_state({"checked_rosters":true,"official_mission":true,"unit_abilities":true,"combat_doctrines":true,"reanimation_protocols":true,"awakened_dynasty":true,"core_stratagems":true},F.selections())
	s.awakened_dynasty.pending = []
	s.unit_abilities.setup_players = [1,2]
	s.unit_abilities.battle_players = [1,2]
	s.deployment.complete = true
	s.mission.stage = "battle"
	s.phase = "movement"
	s.active = 1
	s.turn = 3
	s.round = 2
	s.unit_abilities.phase_key = C.UnitActions.key(s)
	s.cp = {1:3,2:3}
	s.terrain.areas = []
	return s
func find_choice(s: Dictionary, player: int, squad: int, value: String) -> Dictionary:
	for choice: Dictionary in C.unit_choices(s, player):
		if choice.get("action", "") in ["core-stratagem", "overwatch-pass"] and choice.target == squad and str(choice.get("value", "")) == value: return choice
	return {}
func use(s: Dictionary, player: int, squad: int, value: String) -> String:
	var selected := find_choice(s, player, squad, value)
	if selected.is_empty(): return "Unavailable: " + value
	var result := MatchCommands.execute(s, player, {"kind": MatchCommands.SELECT_UNIT_CHOICE, "choice": selected, "point": Vector2.ZERO, "revision": int(s.revision)})
	return str(result.get("error", ""))
func submit_choice(s: Dictionary, player: int, selected: Dictionary) -> Dictionary:
	var decision := PendingDecisions.current(s, ["unit-actions"])
	if decision.is_empty() or int(decision.get("priority_player_id", -1)) != player: return {"error": "No matching UnitActions decision for Player %d." % player}
	var projected: Dictionary = {}
	for option: Dictionary in decision.get("legal_options", []):
		if str(option.get("action", "")) == str(selected.get("action", "")) and int(option.get("model", -1)) == int(selected.get("model", -2)) and int(option.get("target", -1)) == int(selected.get("target", -2)) and str(option.get("value", "")) == str(selected.get("value", "")):
			projected = option
			break
	if projected.is_empty(): return {"error": "The current normalized decision does not contain the selected Core Reaction."}
	return MatchCommands.execute(s, player, {"kind": MatchCommands.SELECT_UNIT_CHOICE, "revision": int(s.revision), "choice": {"_decision_type": MatchCommands.UNIT_CHOICE_ENVELOPE, "decision_id": str(decision.get("decision_id", "")), "option_id": str(projected.get("id", "")), "choice": selected}})
func accept_roll(s: Dictionary, player: int, squad: int) -> Dictionary:
	var decision := C.Stratagems.pending_decision(s)
	var projected: Dictionary = {}
	for option: Dictionary in decision.get("legal_options", []):
		if int(option.get("target", -1)) == squad and str(option.get("value", "")) == "" and int(option.get("details", {}).get("die", -1)) == -1: projected = option
	if projected.is_empty(): return {"error": "The pending Charge decision does not offer acceptance."}
	var choice := {"action": "stratagem-reaction", "model": -1, "target": squad, "value": "", "die": -1}
	var envelope := {"_decision_type": MatchCommands.STRATAGEM_DECISION_ENVELOPE, "decision_id": str(decision.get("decision_id", "")), "option_id": str(projected.get("id", "")), "choice": choice}
	return MatchCommands.execute(s, player, {"kind": MatchCommands.COMMAND_REACTION, "choice": envelope, "revision": int(s.revision)})
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var snap_hit := Attacks.roll_pool({"skill": 3, "strength": 4, "ap": 0, "damage": 1, "attacks": 4, "keywords": {"lethal-hits": true, "sustained-hits": 1}}, {"toughness": 4, "save_target": 7, "invulnerable_target": 0, "wounds_per_model": 1, "remaining_wounds": [1,1,1,1]}, {"weapon_count": 1, "heavy_eligible": false, "snap_shooting": true, "hit_reroll": "failed", "use_lethal_hits": true}, func() -> int: return 6)
	check(snap_hit.error.is_empty() and snap_hit.hits == 4, "Snap shooting hits only on unmodified 6s and those hits are not critical")
	var snap_miss := Attacks.roll_pool({"skill": 2, "strength": 4, "ap": 0, "damage": 1, "attacks": 4, "keywords": {}}, {"toughness": 4, "save_target": 7, "invulnerable_target": 0, "wounds_per_model": 1, "remaining_wounds": [1]}, {"weapon_count": 1, "heavy_eligible": false, "snap_shooting": true}, func() -> int: return 5)
	check(snap_miss.error.is_empty() and snap_miss.hits == 0, "Unmodified 5s miss when snap shooting")
	var s := fixture()
	check(R.enabled(s) and C.Capabilities.supported("fire-overwatch") and C.Capabilities.enabled(s, "fire-overwatch"), "Checked matches enable the infantry core reactions")
	for model: int in C.living(s, 1): s.units[model].position = Vector2(0, 0)
	for model: int in C.living(s, 4): s.units[model].position = Vector2(8, 0)
	var fire_overwatch_close_error := C.advance_phase(s, 1, int(s.revision))
	var fire_overwatch_frame := ResolutionFrames.current(s)
	check(fire_overwatch_close_error.is_empty() and s.phase == "movement" and fire_overwatch_frame.status == "suspended", "End of Movement opens an eligible core reaction window and suspends its close")
	check(not find_choice(s, 2, 4, R.OVERWATCH).is_empty(), "Fire Overwatch is offered at the end of the opponent Movement phase")
	var decision := PendingDecisions.current(s, ["unit-actions"])
	var selected_overwatch := find_choice(s, 2, 4, R.OVERWATCH)
	var overwatch_option_id := ""
	for option: Dictionary in decision.get("legal_options", []):
		if option.get("action", "") == selected_overwatch.get("action", "") and int(option.get("target", -1)) == int(selected_overwatch.get("target", -2)) and str(option.get("value", "")) == R.OVERWATCH:
			overwatch_option_id = str(option.get("id", ""))
	var decision_before_wrong_owner := var_to_str(s)
	var wrong_owner_result := MatchCommands.execute(s, 1, {"kind": MatchCommands.SELECT_UNIT_CHOICE,
		"choice": {"_decision_type": MatchCommands.UNIT_CHOICE_ENVELOPE, "decision_id": decision.get("decision_id", ""), "option_id": overwatch_option_id, "choice": selected_overwatch},
		"point": Vector2.ZERO, "revision": int(s.revision)})
	check(decision.get("source", "") == "unit-actions" and int(decision.get("priority_player_id", -1)) == 2 and decision.legal_options.size() > 0 and C.actor(s) == 2 and decision.get("resume_frame_id", "") == fire_overwatch_frame.frame_id, "The opponent owns the normalized Fire Overwatch decision linked to phase close")
	check(not wrong_owner_result.get("error", "").is_empty() and var_to_str(s) == decision_before_wrong_owner, "The active player cannot resolve the opponent's reaction decision")
	check(not PhaseCloseGate.close_request_error(s, 2, int(s.revision)).is_empty(), "Phase close stays blocked while the Fire Overwatch decision is open")
	var overwatch_result := MatchCommands.execute(s, 2, {"kind": MatchCommands.SELECT_UNIT_CHOICE,
		"choice": {"_decision_type": MatchCommands.UNIT_CHOICE_ENVELOPE, "decision_id": decision.get("decision_id", ""), "option_id": overwatch_option_id, "choice": selected_overwatch},
		"point": Vector2.ZERO, "revision": int(s.revision)})
	check(overwatch_result.get("error", "").is_empty() and s.cp[2] == 2 and R.overwatch_shooter(s, 4) and ResolutionFrames.current(s).status == "suspended", "The identified reaction spends CP, resumes with its shooting action and retains the phase-close frame")
	check(not PhaseCloseGate.close_request_error(s, 2, int(s.revision)).is_empty(), "The pending Overwatch attack still blocks phase close after the reaction is selected")
	check(C.attack_window_error(s, 2, 400, s.revision, false).is_empty(), "Overwatch shooting is legal during Movement")
	check(not C.attack_window_error(s, 2, 400, s.revision, true).is_empty(), "Overwatch cannot be used as a melee attack")
	var targets := C.AttackPlan.legal_targets(s, 400, false)
	check(1 in targets, "Overwatch can see the moving enemy within 24 inches")
	var far := s.duplicate(true)
	far.units[400].position = Vector2(40, 0)
	check(not C.AttackPlan.legal_targets(far, 400, false).has(1), "Overwatch cannot pick a target beyond 24 inches")
	var prepared := C.AttackPlan.prepare(s, 4, false, C.AttackPlan.single_target(s, 4, 1, false), true)
	check(prepared.error.is_empty() and prepared.batches[0].context.get("snap_shooting", false) and prepared.batches[0].context.get("hit_reroll", "none") == "none", "Overwatch plans snap shooting without hit rerolls")
	var framed_state := fixture()
	for model: int in C.living(framed_state, 1): framed_state.units[model].position = Vector2(0, 0)
	for model: int in C.living(framed_state, 4): framed_state.units[model].position = Vector2(8, 0)
	var close_error := C.advance_phase(framed_state, 1, int(framed_state.revision))
	var close_frame := ResolutionFrames.current(framed_state)
	var close_decision := PendingDecisions.current(framed_state, ["unit-actions"])
	check(close_error.is_empty() and framed_state.phase == "movement" and close_frame.status == "suspended", "The real phase-close flow suspends on its open reaction window")
	check(close_decision.get("resume_frame_id", "") == close_frame.frame_id and close_decision.get("action_id", "") == close_frame.action_id, "The opponent's reaction decision links to the persisted phase-close continuation")
	var restored_framed_state: Dictionary = bytes_to_var(var_to_bytes(framed_state))
	var restored_close_decision := PendingDecisions.current(restored_framed_state, ["unit-actions"])
	check(ResolutionFrames.current(restored_framed_state) == close_frame and restored_close_decision.get("decision_id", "") == close_decision.get("decision_id", "") and restored_close_decision.get("legal_options", []) == close_decision.get("legal_options", []) and restored_close_decision.get("priority_player_id", -1) == close_decision.get("priority_player_id", -2) and restored_close_decision.get("resume_frame_id", "") == close_frame.get("frame_id", ""), "Serialized Fire Overwatch retains its decision, legal options, owner and phase-close continuation")
	check(not PhaseCloseGate.close_request_error(restored_framed_state, 2, int(restored_framed_state.revision)).is_empty(), "Restored Fire Overwatch still blocks phase close")
	var pass_choice: Dictionary = {}
	for choice: Dictionary in C.unit_choices(restored_framed_state, 2):
		if choice.get("action", "") == "pass": pass_choice = choice
	var pass_option_id := ""
	for option: Dictionary in restored_close_decision.get("legal_options", []):
		if option.get("action", "") == pass_choice.get("action", "") and int(option.get("target", -1)) == int(pass_choice.get("target", -2)):
			pass_option_id = str(option.get("id", ""))
	var pass_result := MatchCommands.execute(restored_framed_state, 2, {"kind": MatchCommands.SELECT_UNIT_CHOICE,
		"choice": {"_decision_type": MatchCommands.UNIT_CHOICE_ENVELOPE, "decision_id": restored_close_decision.get("decision_id", ""), "option_id": pass_option_id, "choice": pass_choice},
		"point": Vector2.ZERO, "revision": int(restored_framed_state.revision)})
	check(not pass_option_id.is_empty() and pass_result.get("error", "").is_empty() and restored_framed_state.phase == "shooting" and ResolutionFrames.current(restored_framed_state).is_empty(), "Resolving the restored opponent pass resumes and completes the phase-close frame")
	s = fixture()
	s.phase = "charge"
	s.active = 1
	s.unit_abilities.phase_key = C.UnitActions.key(s)
	for model: int in C.living(s, 1): s.units[model].position = Vector2(0, 0)
	for model: int in C.living(s, 4): s.units[model].position = Vector2(8, 0)
	s.core_reactions.chargers = [1]
	s.squads[1].charge_declared = true
	var heroic_close_error := C.advance_phase(s, 1, int(s.revision))
	var heroic_frame := ResolutionFrames.current(s)
	var heroic_decision := PendingDecisions.current(s, ["unit-actions"])
	check(heroic_close_error.is_empty() and heroic_decision.get("timing", "") == "end-phase:charge" and heroic_frame.get("kind", "") == "phase-close" and heroic_frame.get("status", "") == "suspended", "End of Charge opens a normalized Heroic Intervention choice under phase close: " + heroic_close_error)
	check(not find_choice(s, 2, 4, R.HEROIC).is_empty() and not find_choice(s, 2, 4, R.FRAY).is_empty(), "Both Heroic Intervention modes are offered at the end of the opponent Charge phase")
	var heroic_choice := find_choice(s, 2, 4, R.HEROIC)
	var heroic_use := submit_choice(s, 2, heroic_choice)
	check(str(heroic_use.get("error", "")).is_empty() and s.cp[2] == 2 and C.actor(s) == 2 and R.heroic_charger(s, 2, 4) and ResolutionFrames.current(s).get("frame_id", "") == heroic_frame.get("frame_id", ""), "Public Leap to Defend spends 1 CP, opens a charge and retains the phase-close frame: " + str(heroic_use.get("error", "")))
	check(not PhaseCloseGate.close_request_error(s, 2, int(s.revision)).is_empty(), "The pending Heroic Intervention charge blocks Charge close")
	var declared := C.declare_charge(s, 2, 400, s.revision, func() -> int: return 6)
	if not C.Stratagems.pending(s).is_empty():
		var before_wrong_leap_owner := var_to_bytes(s)
		var wrong_leap_owner := accept_roll(s, 1, 4)
		check(not str(wrong_leap_owner.get("error", "")).is_empty() and var_to_bytes(s) == before_wrong_leap_owner, "The active player cannot accept the responder's Leap charge decision")
		var accepted_leap_charge := accept_roll(s, 2, 4)
		check(str(accepted_leap_charge.get("error", "")).is_empty(), "Leap charge roll resumes through the common match command")
	check(declared.error.is_empty() and int(s.pending_charge.get("maximum", 0)) == 12, "Leap to Defend uses a normal 2D6 charge")
	check(C.select_charge_target(s, 2, 100, s.revision).error.is_empty(), "Leap to Defend can target the unit that declared a charge")
	s = fixture()
	s.phase = "charge"
	s.active = 1
	s.unit_abilities.phase_key = C.UnitActions.key(s)
	for model: int in C.living(s, 1): s.units[model].position = Vector2(0, 0)
	for model: int in C.living(s, 4): s.units[model].position = Vector2(4, 0)
	var fray_close_error := C.advance_phase(s, 1, int(s.revision))
	var fray_frame := ResolutionFrames.current(s)
	var fray_decision := PendingDecisions.current(s, ["unit-actions"])
	check(fray_close_error.is_empty() and fray_decision.get("timing", "") == "end-phase:charge" and fray_frame.get("kind", "") == "phase-close" and fray_frame.get("status", "") == "suspended", "End of Charge opens Into the Fray under the persisted phase-close continuation: " + fray_close_error)
	var fray_choice := find_choice(s, 2, 4, R.FRAY)
	var fray_use := submit_choice(s, 2, fray_choice)
	check(str(fray_use.get("error", "")).is_empty() and s.cp[2] == 1 and R.heroic_charger(s, 2, 4) and ResolutionFrames.current(s).get("frame_id", "") == fray_frame.get("frame_id", ""), "Normalized Into the Fray spends 2 CP, opens its capped charge and retains phase close: " + str(fray_use.get("error", "")))
	check(not PhaseCloseGate.close_request_error(s, 2, int(s.revision)).is_empty(), "Into the Fray's pending charge blocks phase close")
	var fray := C.declare_charge(s, 2, 400, s.revision, func() -> int: return 6)
	if not C.Stratagems.pending(s).is_empty():
		var accepted_fray_charge := accept_roll(s, 2, 4)
		check(str(accepted_fray_charge.get("error", "")).is_empty(), "Into the Fray charge roll resumes through the common match command")
	check(fray.error.is_empty() and int(s.pending_charge.get("maximum", 0)) == 6, "Into the Fray caps the charge roll at 6")
	s = fixture()
	s.phase = "fight"
	s.fight_step = "attacks"
	s.active = 1
	s.fight_actor = 1
	s.unit_abilities.phase_key = C.UnitActions.key(s)
	for model: int in C.living(s, 1): s.units[model].position = Vector2(0, 0)
	for model: int in C.living(s, 4): s.units[model].position = Vector2(1.2, 0)
	s.squads[1].fought = true
	s.squads[1].was_engaged = true
	s.squads[4].fought = false
	s.squads[4].was_engaged = true
	var prior_attack := ResolutionFrames.begin(s, "attack", "fight-attack:1:1", "resolve-fight-attack")
	check(R.offer_counter(s, 1) and s.unit_abilities.window.kind == "counter" and C.actor(s) == 2, "Counteroffensive opens after an enemy unit fights in the opponent Fight phase")
	C._event(s, "Opponent may use Counteroffensive or decline.")
	check(ResolutionFrames.current(s).get("frame_id", "") == prior_attack.get("frame_id", ""), "Attack frame remains the active parent until its continuation completes")
	check(C._complete_attack_resolution_frame(s, str(prior_attack.get("action_id", ""))).is_empty(), "Finished attack transfers to the Counteroffensive continuation")
	var counter_frame := ResolutionFrames.current(s)
	var counter_decision := PendingDecisions.current(s, ["unit-actions"])
	check(counter_frame.get("kind", "") == "fight" and counter_frame.get("status", "") == "suspended" and counter_decision.get("resume_frame_id", "") == counter_frame.get("frame_id", ""), "Counteroffensive decision carries a persisted Fight continuation")
	check("pending unit ability choices" in PhaseCloseGate.close_request_error(s, 2, s.revision), "Pending Counteroffensive blocks Fight progression")
	var counter_restore: Dictionary = bytes_to_var(var_to_bytes(s))
	var restored_counter_decision := PendingDecisions.current(counter_restore, ["unit-actions"])
	var counter_choice: Dictionary = {}
	for option: Dictionary in C.unit_choices(counter_restore, 2):
		if option.get("action", "") == "core-stratagem" and str(option.get("value", "")) == R.COUNTER: counter_choice = option
	var counter_option_id := ""
	for option: Dictionary in restored_counter_decision.get("legal_options", []):
		if option.get("action", "") == counter_choice.get("action", "") and int(option.get("target", -1)) == int(counter_choice.get("target", -2)) and str(option.get("value", "")) == R.COUNTER: counter_option_id = str(option.get("id", ""))
	check(ResolutionFrames.current(counter_restore) == counter_frame and restored_counter_decision.get("decision_id", "") == counter_decision.get("decision_id", "") and restored_counter_decision.get("resume_frame_id", "") == counter_frame.get("frame_id", ""), "Counteroffensive decision and continuation survive state serialization")
	var before_wrong_counter_owner := var_to_str(counter_restore)
	var wrong_counter_owner := MatchCommands.execute(counter_restore, 1, {"kind": MatchCommands.SELECT_UNIT_CHOICE, "revision": counter_restore.revision, "choice": {"_decision_type": MatchCommands.UNIT_CHOICE_ENVELOPE, "decision_id": restored_counter_decision.get("decision_id", ""), "option_id": counter_option_id, "choice": counter_choice}})
	check(not str(wrong_counter_owner.get("error", "")).is_empty() and var_to_str(counter_restore) == before_wrong_counter_owner, "The non-priority player cannot spend Counteroffensive or mutate the suspended Fight")
	var counter_result := submit_choice(counter_restore, 2, counter_choice)
	check(str(counter_result.get("error", "")).is_empty() and counter_restore.cp[2] == 1 and counter_restore.fight_selected == 4 and counter_restore.squads[4].fights_first and ResolutionFrames.current(counter_restore).is_empty(), "Normalized Counteroffensive spends 2 CP, gives Fights First and completes its continuation: " + str(counter_result.get("error", "")))
	s = fixture()
	s.phase = "fight"
	s.fight_step = "attacks"
	s.active = 1
	s.fight_actor = 1
	s.unit_abilities.phase_key = C.UnitActions.key(s)
	for model: int in C.living(s, 1): s.units[model].position = Vector2(0, 0)
	for model: int in C.living(s, 4): s.units[model].position = Vector2(1.2, 0)
	s.squads[1].fought = true
	s.squads[1].was_engaged = true
	s.squads[4].fought = false
	s.squads[4].was_engaged = true
	R.offer_counter(s, 1)
	C._event(s, "Opponent may use Counteroffensive or decline.")
	var decline: Dictionary = {}
	for option: Dictionary in C.unit_choices(s, 2):
		if option.get("action", "") == "pass": decline = option
	var counter_decline := submit_choice(s, 2, decline) if not decline.is_empty() else {"error": "Counteroffensive pass was not projected."}
	check(str(counter_decline.get("error", "")).is_empty() and ResolutionFrames.current(s).is_empty(), "Declining Counteroffensive through the normalized command resumes and completes the Fight continuation: " + str(counter_decline.get("error", "")))
	s = fixture()
	s.phase = "fight"
	s.fight_step = "attacks"
	s.active = 1
	s.fight_actor = 1
	s.fight_selected = -1
	s.unit_abilities.phase_key = C.UnitActions.key(s)
	s.squads[3].was_engaged = true
	s.squads[3].fought = false
	check(not find_choice(s, 1, 3, R.EPIC).is_empty(), "Epic Challenge is offered for a Character unit selected to fight")
	check(use(s, 1, 3, R.EPIC).is_empty() and s.cp[1] == 2 and s.fight_selected == 3, "Epic Challenge spends 1 CP and locks the Character unit")
	var melee: Dictionary = s.squads[3].melee_weapon.duplicate(true)
	var boosted := R.weapon(s, 300, melee, true)
	check(boosted.keywords.get("precision", false) and not R.weapon(s, 300, melee, false).keywords.get("precision", false), "Epic Challenge grants melee Precision only to the chosen Character model")
	print("Core reaction stratagem checks: %d failures" % failures)
	quit(0 if failures == 0 else 1)
