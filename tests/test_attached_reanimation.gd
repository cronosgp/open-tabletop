extends SceneTree
const F = preload("res://tests/awakened_fixture.gd")
const C = F.C
const R = C.Reanimation
const ResolutionFrames = preload("res://scripts/edition_11/resolution_frame.gd")
const PhaseCloseGate = preload("res://scripts/edition_11/phase_close_gate.gd")
const MatchCommandService = preload("res://scripts/edition_11/match_command_service.gd")
const PendingDecisions = preload("res://scripts/edition_11/pending_decision_registry.gd")
var failures := 0
var calls := 0
func six() -> int:
	calls += 1
	return 6
func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func submit_projected_choice(state: Dictionary, player: int, selected: Dictionary) -> Dictionary:
	var decision := PendingDecisions.current(state, ["unit-actions"])
	if decision.is_empty() or int(decision.get("priority_player_id", -1)) != player: return {"error": "No UnitActions decision belongs to Player %d." % player}
	var projected: Dictionary = {}
	for option: Dictionary in decision.get("legal_options", []):
		if str(option.get("action", "")) == str(selected.get("action", "")) and int(option.get("model", -1)) == int(selected.get("model", -1)) and int(option.get("target", -1)) == int(selected.get("target", -1)):
			projected = option
			break
	if projected.is_empty(): return {"error": "Selected choice is not in the current UnitActions projection."}
	return MatchCommandService.execute(state, player, {"kind": MatchCommandService.SELECT_UNIT_CHOICE, "revision": int(state.get("revision", -1)), "choice": {"_decision_type": MatchCommandService.UNIT_CHOICE_ENVELOPE, "decision_id": str(decision.get("decision_id", "")), "option_id": str(projected.get("id", "")), "choice": selected}}, six)
func fresh(bodyguard: int = 4) -> Dictionary:
	var s := F.fresh({"awakened_dynasty": true, "reanimation_protocols": true})
	check(C.select_awakened_attachment(s, 2, bodyguard, 0).is_empty(), "Combined options allow attachment")
	F.combat(s)
	s.phase = "command"
	R.start_command(s)
	check(R.phase_error(s).is_empty() and R.open_end_command(s), "Attached unit enters own Command healing queue")
	return s
func _initialize() -> void:
	var s := fresh()
	s.units[600].wounds = 4
	s.units[400].wounds = 0
	s.units[401].wounds = 0
	check(R.roll_unit(s, 4, six).error.is_empty(), "Roll attached unit once")
	check(R.accept_roll(s, false, six).error.is_empty(), "Accept Their Number is Legion before allocating returned models")
	check(R.pending(s).current.healed == {600: 2} and R.pending(s).current.slots == 1, "D3 three heals two Overlord wounds before one troop return")
	check(s.units[600].wounds == 4 and s.units[400].wounds == 0, "Healing and returns remain staged together")
	check(R.suggest(s).error.is_empty(), "Mixed healing has a valid return preview")
	var restored: Dictionary = bytes_to_var(var_to_bytes(s))
	check(R.reset_preview(restored).error.is_empty() and R.pending(restored).current.healed == {600: 2} and calls == 1, "Serialized preview reset retains reserved healing and consumes no dice")
	check(R.suggest(restored).error.is_empty() and R.confirm_unit(restored).error.is_empty(), "Restored preview can commit")
	check(restored.units[600].wounds == 6 and C.living(restored, 4).size() == 10 and R.pending(restored).results[0].discarded == 0, "One shared budget applied exactly once")
	s = fresh()
	for id in range(400, 410): s.units[id].wounds = 0
	check(F.A.hit_bonus(s, 4) == 1 and s.squads[4].starting_strength == 11, "e11 leader keeps ability and combined strength after bodyguard destruction")
	check(R.roll_unit(s, 4, six).error.is_empty() and R.pending(s).current.slots == 3, "Living leader can anchor three revived bodyguards")
	check(R.suggest(s).error.is_empty() and R.confirm_unit(s).error.is_empty() and C.living(s, 4).size() == 4, "Wiped bodyguard component returns to original attached unit")
	s = fresh(2)
	s.units[600].wounds = 0
	s.units[200].wounds = 0
	check(R.roll_unit(s, 2, six).error.is_empty() and 600 not in R.returnable(s), "Destroyed Character cannot be revived by unit healing")
	check(R.suggest(s).error.is_empty() and R.confirm_unit(s).error.is_empty() and s.units[600].wounds == 0 and F.A.hit_bonus(s, 2) == 0, "Immortals return without reviving the Overlord or its bonus")
	s = fresh()
	s.units[600].wounds = 1
	s.units[400].wounds = 0
	check(R.roll_unit(s, 4, six).error.is_empty() and R.accept_roll(s, false, six).error.is_empty() and R.pending(s).current.is_empty() and s.units[600].wounds == 4 and s.units[400].wounds == 0, "Insufficient budget heals only leader and performs no return")
	var closing := F.fresh({"reanimation_protocols": true})
	check(C.select_awakened_attachment(closing, 2, 4, closing.revision).is_empty(), "Phase-close fixture admits its Overlord attachment")
	F.combat(closing)
	closing.phase = "command"
	R.start_command(closing)
	closing.reanimation.morale_turn = closing.turn
	var close_error := C.advance_phase(closing, 2, closing.revision, six)
	var reanimation_frame := ResolutionFrames.current(closing)
	check(close_error.is_empty() and not R.pending(closing).is_empty() and reanimation_frame.get("kind", "") == "phase-close" and reanimation_frame.get("status", "") == "suspended" and reanimation_frame.get("resume_point", "") == "resume-after-reanimation-decision", "End-of-Command Reanimation suspends the phase-close continuation frame")
	check(not PhaseCloseGate.close_request_error(closing, 2, closing.revision).is_empty(), "The open Reanimation decision still blocks phase close")
	var reanimation_decision := R.pending_decision(closing)
	var restored_closing: Dictionary = bytes_to_var(var_to_bytes(closing))
	var restored_reanimation_decision := R.pending_decision(restored_closing)
	check(restored_reanimation_decision.get("decision_id", "") == reanimation_decision.get("decision_id", "") and restored_reanimation_decision.get("resume_frame_id", "") == reanimation_frame.get("frame_id", "") and ResolutionFrames.current(restored_closing) == reanimation_frame, "Serialized end-of-Command Reanimation retains its decision and phase-close continuation")
	check(not PhaseCloseGate.close_request_error(restored_closing, 2, restored_closing.revision).is_empty(), "Restored Reanimation decision continues to block phase close")
	closing = restored_closing
	reanimation_frame = ResolutionFrames.current(closing)
	closing.reanimation.pending = {}
	closing.reanimation.done_turn[closing.active] = closing.turn
	closing.revision += 1
	close_error = C.advance_phase(closing, 2, closing.revision, six)
	var end_frame := ResolutionFrames.current(closing)
	check(close_error.is_empty() and closing.phase == "command" and end_frame.get("kind", "") == "phase-close" and end_frame.get("status", "") == "suspended" and end_frame.get("resume_point", "") == "resume-after-end-of-phase-decision", "Resolved Reanimation resumes into the remaining end-of-phase window")
	var end_owner := C.UnitActions.actor(closing)
	var end_pass: Dictionary = {}
	for option: Dictionary in C.unit_choices(closing, end_owner):
		if option.action == "pass": end_pass = option
	check(end_owner == 2 and not end_pass.is_empty(), "The remaining end-of-phase owner can decline its choices")
	if not end_pass.is_empty():
		var before_wrong_owner := var_to_bytes(closing)
		var wrong_owner := submit_projected_choice(closing, 1, end_pass)
		check(not str(wrong_owner.get("error", "")).is_empty() and var_to_bytes(closing) == before_wrong_owner, "The other player cannot decline the remaining Reanimation end window")
		var end_pass_result := submit_projected_choice(closing, end_owner, end_pass)
		close_error = str(end_pass_result.get("error", ""))
	check(close_error.is_empty() and closing.phase == "movement" and ResolutionFrames.current(closing).is_empty(), "Declining the remaining end-of-phase choice completes the phase-close frame")
	print("Attached Reanimation checks: %d failures" % failures)
	quit(1 if failures else 0)
