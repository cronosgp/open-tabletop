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
func reserve_declaration_state() -> Dictionary:
	var state := F.fresh()
	check(not state.has("error"), "Ten-unit reserve fixture admitted")
	C.select_awakened_attachment(state, 2, -1, 0)
	check(act(state, 1, "attach", 900, 1).is_empty(), "Support assigned")
	check(act(state, 1, "warlord", 300).is_empty(), "Marine Warlord assigned")
	return state
func round_two_ingress_state() -> Dictionary:
	var state := fresh()
	state.phase = "movement"
	state.round = 2
	state.turn = 3
	state.active = 1
	state.unit_abilities.phase_key = U.key(state)
	return state
func fresh() -> Dictionary:
	var s := reserve_declaration_state()
	check(act(s, 1, "reserve", -1, 11).is_empty(), "Terminator unit enters reserves within the combined half-limit")
	check(s.unit_abilities.reserves.get(11, {}).get("deep_strike", false), "The reserve record preserves the unit's Deep Strike placement method")
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
	var ordinary_reserve_state := reserve_declaration_state()
	var fortification_state: Dictionary = bytes_to_var(var_to_bytes(ordinary_reserve_state))
	for model: int in fortification_state.units:
		if int(fortification_state.units[model].get("squad", -1)) == 1 and "FORTIFICATION" not in fortification_state.units[model].get("keywords", []): fortification_state.units[model].keywords.append("FORTIFICATION")
	var before_fortification := var_to_bytes(fortification_state)
	check(act(fortification_state, 1, "reserve", -1, 1).begins_with("Unavailable:") and before_fortification == var_to_bytes(fortification_state), "Fortifications cannot be declared in Strategic Reserves")
	check(act(ordinary_reserve_state, 1, "reserve", -1, 7).is_empty(), "Non-Deep-Strike Intercessor unit can be declared in Strategic Reserves")
	check(not ordinary_reserve_state.unit_abilities.reserves[7].deep_strike and ordinary_reserve_state.unit_abilities.reserves[7].source == "strategic-reserves" and C.living(ordinary_reserve_state, 7).is_empty() and 7 not in ordinary_reserve_state.deployment.order, "Ordinary Strategic Reserves preserve their ingress method and leave deployment")
	check(act(ordinary_reserve_state, 1, "reserve", -1, 11).is_empty(), "Combined ordinary and Deep Strike reserves remain within the half-army cap")
	var reserve_points := int(ordinary_reserve_state.unit_abilities.reserves[7].cost) + int(ordinary_reserve_state.unit_abilities.reserves[11].cost)
	check(reserve_points <= int(ordinary_reserve_state.points_limit) / 2, "Combined pre-battle reserve cost stays within 50% of the configured points limit")
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
	var deep_strike_zone_state := round_two_ingress_state()
	check(act(deep_strike_zone_state, 1, "ingress", -1, 11).is_empty(), "Deep Strike unit opens its own Movement ingress window")
	var enemy_zone: Rect2 = deep_strike_zone_state.deployment.zones[2]
	var deep_strike_zone_positions := [Vector2(14, 10), Vector2(15.7, 10), Vector2(17.4, 10), Vector2(14, 11.7), Vector2(15.7, 11.7)]
	for index in range(deep_strike_zone_positions.size()):
		var position: Vector2 = deep_strike_zone_positions[index]
		var model := 1100 + index
		var radius := float(deep_strike_zone_state.units[model].radius)
		check(position.x - radius >= enemy_zone.position.x and position.x + radius <= enemy_zone.end.x and position.y - radius >= enemy_zone.position.y and position.y + radius <= enemy_zone.end.y, "Deep Strike fixture places each entire base inside the enemy deployment zone")
		check(act(deep_strike_zone_state, 1, "ingress-place", model, 11, position).is_empty(), "Deep Strike permits a legal more-than-eight-inch arrival inside the enemy deployment zone")
	check(act(deep_strike_zone_state, 1, "ingress-confirm").is_empty() and C.living(deep_strike_zone_state, 11).size() == 5, "Deep Strike enemy-zone formation confirms as a complete unit")
	var strategic_zone_state := round_two_ingress_state()
	strategic_zone_state.unit_abilities.reserves[11].deep_strike = false
	check(act(strategic_zone_state, 1, "ingress", -1, 11).is_empty(), "Strategic Reserves unit opens the same ingress workflow")
	var strategic_zone_error := act(strategic_zone_state, 1, "ingress-place", 1100, 11, Vector2(16, 14))
	check(strategic_zone_error.contains("opponent's deployment zone before battle round 3") and U.pending(strategic_zone_state).positions.is_empty(), "Strategic Reserves reject the same valid-edge opponent-zone arrival before round three")
	var strategic_round_three_state := round_two_ingress_state()
	strategic_round_three_state.unit_abilities.reserves[11].deep_strike = false
	strategic_round_three_state.round = 3
	strategic_round_three_state.turn = 5
	strategic_round_three_state.unit_abilities.phase_key = U.key(strategic_round_three_state)
	check(act(strategic_round_three_state, 1, "ingress", -1, 11).is_empty(), "Strategic Reserves remain eligible to ingress during battle round three")
	var strategic_round_three_positions := [Vector2(16, 14), Vector2(17.7, 14), Vector2(19.4, 14), Vector2(16, 12.3), Vector2(17.7, 12.3)]
	for index in range(strategic_round_three_positions.size()):
		var strategic_position: Vector2 = strategic_round_three_positions[index]
		var strategic_position_error := act(strategic_round_three_state, 1, "ingress-place", 1100 + index, 11, strategic_position)
		check(strategic_position_error.is_empty(), "Strategic Reserves can enter the opponent deployment zone from a legal battlefield edge in round three: " + strategic_position_error)
	check(act(strategic_round_three_state, 1, "ingress-confirm").is_empty() and C.living(strategic_round_three_state, 11).size() == 5, "Round-three Strategic Reserves enemy-zone formation confirms as a complete unit")
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
