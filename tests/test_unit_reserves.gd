extends SceneTree
const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const U = C.UnitActions
const MatchCommands = preload("res://scripts/edition_11/match_command_service.gd")
const ResolutionFrames = preload("res://scripts/edition_11/resolution_frame.gd")
var failures := 0
func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1
func submit_choice(s: Dictionary, owner: int, selected: Dictionary, point: Vector2 = Vector2.ZERO) -> Dictionary:
	var decision := U.pending_decision(s)
	var projected: Dictionary = {}
	for option: Dictionary in decision.get("legal_options", []):
		if str(option.get("action", "")) == str(selected.get("action", "")) and int(option.get("model", -1)) == int(selected.get("model", -1)) and int(option.get("target", -1)) == int(selected.get("target", -1)) and str(option.get("value", "")) == str(selected.get("value", "")):
			projected = option
			break
	var payload := selected
	if not projected.is_empty(): payload = {"_decision_type": MatchCommands.UNIT_CHOICE_ENVELOPE, "decision_id": str(decision.get("decision_id", "")), "option_id": str(projected.get("id", "")), "choice": selected}
	return MatchCommands.execute(s, owner, {"kind": MatchCommands.SELECT_UNIT_CHOICE, "choice": payload, "point": point, "revision": int(s.revision)})
func act(s: Dictionary, owner: int, action: String, model: int = -2, target: int = -2, point: Vector2 = Vector2.ZERO) -> String:
	for selected: Dictionary in C.unit_choices(s, owner):
		if selected.action == action and (model == -2 or selected.model == model) and (target == -2 or selected.target == target): return str(submit_choice(s, owner, selected, point).get("error", ""))
	return "Unavailable: " + action
func fresh() -> Dictionary:
	var s := F.fresh()
	check(not s.has("error"), "Ten-unit reserve fixture admitted")
	C.select_awakened_attachment(s, 2, -1, 0)
	check(act(s, 1, "attach", 900, 1).is_empty(), "Support assigned")
	check(act(s, 1, "warlord", 300).is_empty(), "Marine Warlord assigned")
	var before := var_to_bytes(s)
	check(not act(s, 1, "reserve", -1, 1).is_empty() and before == var_to_bytes(s), "Only eligible Deep Strike units can use this reserve workflow")
	check(act(s, 1, "reserve", -1, 11).is_empty(), "Terminator unit enters reserves within half-limit")
	check(C.living(s, 11).is_empty() and s.units[1100].wounds == 3 and not s.units[1100].on_battlefield and 11 not in s.deployment.order, "Reserves preserve wounds but leave board and deployment order")
	check(act(s, 1, "setup-done").is_empty() and act(s, 2, "warlord", 600).is_empty() and act(s, 2, "setup-done").is_empty(), "Both preparations complete")
	s.phase = "start_turn"
	s.deployment.complete = true
	var battle_decision := U.pending_decision(s)
	check(U.battle_actor(s) == 1 and battle_decision.get("source", "") == "unit-actions" and int(battle_decision.get("priority_player_id", -1)) == 1 and not battle_decision.get("legal_options", []).is_empty(), "Start-of-battle declarations expose a normalized choice for the acting player")
	var battle_decision_id: String = battle_decision.decision_id
	var before_battle_close := var_to_bytes(s)
	check(not C.advance_phase(s, 1, s.revision).is_empty() and var_to_bytes(s) == before_battle_close, "A pending start-of-battle choice blocks phase progression without mutation")
	var restored_battle: Dictionary = bytes_to_var(var_to_bytes(s))
	var restored_battle_decision := U.pending_decision(restored_battle)
	check(restored_battle_decision.get("decision_id", "") == battle_decision_id and restored_battle_decision.get("legal_options", []) == battle_decision.legal_options and U.battle_actor(restored_battle) == 1, "Serialized start-of-battle choice retains its identity, options and decision owner")
	s = restored_battle
	check(act(s, 1, "homer", -1, 11, Vector2(-8, -6)).is_empty(), "Homer is declared at battle start after deployment, including a reserve unit")
	check(act(s, 1, "battle-done").is_empty() and U.battle_actor(s) == -1, "Optional start-of-battle window closes")
	for model: int in s.units:
		if not s.units[model].get("on_battlefield", true): continue
		s.units[model].position = Vector2(-15 if s.units[model].owner == 1 else 15, 10 + (model % 5) * 1.7 if s.units[model].owner == 1 else -10 + (model % 5) * 1.7)
	return s
func _initialize() -> void:
	var irrelevant_reserve_state := C.initial_state()
	C.UnitAbilities.enable(irrelevant_reserve_state)
	irrelevant_reserve_state.phase = "movement"
	irrelevant_reserve_state.round = 2
	irrelevant_reserve_state.turn = 3
	irrelevant_reserve_state.active = 1
	irrelevant_reserve_state.unit_abilities.reserves = {1: {"cost": 100, "source": "strategic-reserves"}}
	irrelevant_reserve_state.unit_abilities.phase_key = U.key(irrelevant_reserve_state)
	irrelevant_reserve_state.unit_abilities.end_done = ""
	for model: int in irrelevant_reserve_state.units:
		if irrelevant_reserve_state.units[model].squad == 1: irrelevant_reserve_state.units[model].on_battlefield = false
	var irrelevant_reserve_close := C.advance_phase(irrelevant_reserve_state, 1, irrelevant_reserve_state.revision)
	check(irrelevant_reserve_close.is_empty() and irrelevant_reserve_state.phase == "shooting", "A reserve unit owned by the active player does not open an opponent-only Rapid Ingress window")
	check(U.pending(irrelevant_reserve_state).is_empty() and ResolutionFrames.current(irrelevant_reserve_state).is_empty(), "No ineligible Rapid Ingress choice leaves a pending window or phase-close frame")
	var no_core_ingress_state := C.initial_state()
	C.UnitAbilities.enable(no_core_ingress_state)
	no_core_ingress_state.phase = "movement"
	no_core_ingress_state.round = 2
	no_core_ingress_state.active = 2
	no_core_ingress_state.unit_abilities.reserves[1] = {"cost": 100, "source": "strategic-reserves"}
	no_core_ingress_state.unit_abilities.homers[1] = {"objective": 0}
	check(U.rapid_ingress_squads(no_core_ingress_state, 1).is_empty() and not U.open_end(no_core_ingress_state), "A reserve or Teleport Homer does not create Rapid Ingress without the opted-in Stratagems container")
	var cp_ingress_state := fresh()
	cp_ingress_state.phase = "movement"
	cp_ingress_state.active = 2
	cp_ingress_state.round = 2
	cp_ingress_state.turn = 4
	cp_ingress_state.unit_abilities.phase_key = U.key(cp_ingress_state)
	cp_ingress_state.unit_abilities.window = {"kind": "end", "owners": [1]}
	cp_ingress_state.unit_abilities.end_done = ""
	cp_ingress_state.unit_abilities.reserves[11] = {"cost": 100, "source": "strategic-reserves"}
	for model: int in cp_ingress_state.units:
		if cp_ingress_state.units[model].squad == 11: cp_ingress_state.units[model].on_battlefield = false
	cp_ingress_state.unit_abilities.homers.erase(11)
	cp_ingress_state.cp[1] = 1
	var cp_ingress_choices: Array = U.choices(cp_ingress_state, 1)
	check(U.rapid_ingress_squads(cp_ingress_state, 1) == [11] and cp_ingress_choices.any(func(option: Dictionary) -> bool: return option.get("action", "") == "ingress" and int(option.get("target", -1)) == 11), "A legal reserve owned by the opponent still opens its 1 CP Rapid Ingress option: eligible=%s choices=%s owner=%s cp=%s" % [str(U.rapid_ingress_squads(cp_ingress_state, 1)), str(cp_ingress_choices), str(cp_ingress_state.squads.get(11, {}).get("owner", -1)), str(cp_ingress_state.cp.get(1, -1))])
	var s := fresh()
	s.phase = "movement"
	s.unit_abilities.phase_key = U.key(s)
	check(not act(s, 1, "ingress", -1, 11).is_empty(), "No first-round ingress")
	check(not C.begin_movement(s, 1, 1100, "normal", s.revision).is_empty() and not C.attack_window_error(s, 1, 1100, s.revision, false).is_empty(), "Reserved models cannot move or attack on the board")
	s.round = 2
	s.turn = 3
	s.unit_abilities.phase_key = U.key(s)
	check(act(s, 1, "ingress", -1, 11).is_empty(), "Own Movement permits second-round Deep Strike")
	check(U.pending(s).get("kind", "") == "ingress", "Reserve arrival preview uses the registered ingress window kind")
	var ingress_frame := ResolutionFrames.current(s)
	check(ingress_frame.get("kind", "") == "unit-action" and ingress_frame.get("status", "") == "suspended", "Reserve ingress preview suspends a persisted action frame")
	var cancelled_ingress: Dictionary = bytes_to_var(var_to_bytes(s))
	check(act(cancelled_ingress, 1, "ingress-cancel").is_empty() and ResolutionFrames.current(cancelled_ingress).is_empty() and U.pending(cancelled_ingress).is_empty(), "Cancelling ingress closes its frame and restores the prior unit-action window")
	var window: Dictionary = U.pending(s).duplicate(true)
	check(not act(s, 1, "ingress-place", 1100, 11, Vector2(30, 0)).is_empty() and U.pending(s) == window, "Off-board ingress rejected transactionally")
	check(not act(s, 1, "ingress-place", 1100, 11, s.units[200].position).is_empty(), "Enemy overlap/within eight inches rejected")
	check(not act(s, 1, "ingress-confirm").is_empty(), "Cannot confirm missing model positions")
	for index in range(5):
		check(act(s, 1, "ingress-place", 1100 + index, 11, Vector2(-8 + (index % 3) * 1.7, -6 + (index / 3) * 1.7)).is_empty(), "Each reserved model can stage legal arrival")
	check(C.living(s, 11).is_empty() and U.pending(s).positions.size() == 5, "Ingress positions remain previews until confirmation")
	var restored: Dictionary = bytes_to_var(var_to_bytes(s))
	check(ResolutionFrames.current(restored).get("frame_id", "") == ingress_frame.get("frame_id", "") and act(restored, 1, "ingress-confirm").is_empty() and C.living(restored, 11).size() == 5 and restored.squads[11].set_up_this_turn and ResolutionFrames.current(restored).is_empty(), "Serialized ingress preview commits coherently, marks setup and completes its frame")
	check(not C.begin_movement(restored, 1, 1100, "normal", restored.revision).is_empty(), "Arriving units cannot make another Movement move")
	s = fresh()
	s.phase = "movement"
	s.active = 2
	s.round = 2
	s.turn = 4
	s.unit_abilities.phase_key = U.key(s)
	s.unit_abilities.window = {}
	s.unit_abilities.end_done = ""
	s.resolution_frames = []
	s.cp[1] = 0
	var close_error := C.advance_phase(s, 2, s.revision)
	check(close_error.is_empty() and s.unit_abilities.window.get("kind", "") == "end" and ResolutionFrames.current(s).get("kind", "") == "phase-close", "Closing the opponent Movement phase opens its end windows under a phase-close continuation: " + close_error)
	# Necron Orb optional window precedes non-active player's reaction.
	check(act(s, 2, "pass").is_empty(), "Active player's end-phase abilities resolve first")
	var homer_ingress_error := act(s, 1, "homer-ingress", -1, 11)
	check(homer_ingress_error.is_empty(), "Homer grants zero-CP Rapid Ingress: " + homer_ingress_error)
	var homer_ingress_frame := ResolutionFrames.current(s)
	check(homer_ingress_frame.get("kind", "") == "unit-action" and homer_ingress_frame.get("parent_frame_id", "") != "" and ResolutionFrames.current(s).get("status", "") == "suspended", "Opponent Rapid Ingress nests beneath a suspended phase-close continuation")
	for index in range(5): act(s, 1, "ingress-place", 1100 + index, 11, Vector2((index % 3) * 1.7, (index / 3) * 1.7))
	check(not act(s, 1, "ingress-confirm").is_empty(), "Homer arrival unit must be within three inches")
	for index in range(5): check(act(s, 1, "ingress-place", 1100 + index, 11, Vector2(-8 + (index % 3) * 1.7, -6 + (index / 3) * 1.7)).is_empty(), "Homer positions stage")
	check(act(s, 1, "ingress-confirm").is_empty() and s.cp[1] == 0 and not s.unit_abilities.homers.has(11) and ResolutionFrames.current(s).get("frame_id", "") == homer_ingress_frame.get("parent_frame_id", "") and ResolutionFrames.current(s).get("status", "") == "suspended", "Homer is consumed once, ingress closes, and the phase-close continuation remains suspended for phase-close resumption")
	check(s.stratagems.uses[-1].stratagem == "rapid-ingress", "Rapid Ingress enters the shared stratagem use journal")
	s = fresh()
	s.units[200].position = Vector2(-8, -6)
	U.reconcile(s)
	check(s.unit_abilities.homers.has(11), "Proximity alone does not remove Homer before an enemy move ends")
	U.end_move(s, 2)
	check(not s.unit_abilities.homers.has(11), "Enemy ending a move within one inch removes Homer")
	s.round = 4
	U.reconcile(s)
	check(s.units[1100].wounds == 0 and s.unit_abilities.reserves.is_empty(), "Unarrived reserves are destroyed after round three")
	print("Unit reserves checks: %d failures" % failures)
	quit(1 if failures else 0)
