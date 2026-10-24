extends SceneTree
const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const D = preload("res://scripts/edition_11/detachment_stratagems.gd")
const MatchCommandService = preload("res://scripts/edition_11/match_command_service.gd")
const ResolutionFrames = preload("res://scripts/edition_11/resolution_frame.gd")
var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func fixture() -> Dictionary:
	var lists := F.selections()
	lists[1].entries = [
		{"definition_id": "40kdc:11e:adeptus-astartes:outrider-squad", "models": 3, "copies": 1},
		{"definition_id": "40kdc:11e:adeptus-astartes:intercessor-squad", "models": 5, "copies": 1}
	]
	var state: Dictionary = F.P.initial_state({"checked_rosters": false, "official_mission": false, "unit_abilities": true, "combat_doctrines": true, "reanimation_protocols": true, "awakened_dynasty": true, "core_stratagems": true, "manual_allocation": false}, lists)
	state.awakened_dynasty.pending = []
	state.unit_abilities.setup_players = [1, 2]
	state.unit_abilities.battle_players = [1, 2]
	state.deployment.complete = true
	state.mission.stage = "battle"
	state.phase = "command"
	state.active = 1
	state.turn = 3
	state.round = 2
	state.combat_doctrines.selected_turn[1] = state.turn
	state.unit_abilities.phase_key = C.UnitActions.key(state)
	C.Doctrines.enable(state, "spearpoint-task-force")
	D.enable_spearpoint(state)
	state.cp[1] = 3
	state.cp[2] = 3
	return state

func first_model(state: Dictionary, squad: int) -> int:
	for model: int in state.units:
		if state.units[model].squad == squad and state.units[model].wounds > 0: return model
	return -1

func first_squad(state: Dictionary, owner: int) -> int:
	for squad: int in state.squads:
		if state.squads[squad].owner == owner: return squad
	return -1

func find_squad(state: Dictionary, owner: int, identity: String) -> int:
	for squad: int in state.squads:
		if state.squads[squad].owner != owner: continue
		for model: int in D.living(state, squad):
			if C.UnitAbilities.identity(state.units[model]) == identity: return squad
	return -1

func submit_choice(state: Dictionary, player: int, action: String, target: int = -1, model: int = -1, value: String = "", roller: Callable = Callable()) -> Dictionary:
	var decision := C.UnitActions.pending_decision(state)
	if decision.is_empty() or int(decision.get("priority_player_id", -1)) != player: return {"error": "No matching UnitActions decision for Player %d." % player}
	var option: Dictionary = {}
	for candidate: Dictionary in decision.get("legal_options", []):
		if str(candidate.get("action", "")) == action and int(candidate.get("target", -1)) == target and int(candidate.get("model", -1)) == model and str(candidate.get("value", "")) == value:
			option = candidate
			break
	if option.is_empty(): return {"error": "Decision does not offer %s/%s for target %d/model %d." % [action, value, target, model]}
	var choice: Dictionary = {}
	for candidate: Dictionary in C.UnitActions.choices(state, player):
		if str(candidate.get("action", "")) == action and int(candidate.get("target", -1)) == target and int(candidate.get("model", -1)) == model and str(candidate.get("value", "")) == value:
			choice = candidate
			break
	if choice.is_empty(): return {"error": "UnitActions no longer offers %s/%s." % [action, value]}
	return MatchCommandService.execute(state, player, {"kind": MatchCommandService.SELECT_UNIT_CHOICE, "revision": int(state.get("revision", -1)), "choice": {"_decision_type": MatchCommandService.UNIT_CHOICE_ENVELOPE, "decision_id": str(decision.get("decision_id", "")), "option_id": str(option.get("id", "")), "choice": choice}}, roller)

func _initialize() -> void: call_deferred("run")

func run() -> void:
	var s := fixture()
	var outriders := find_squad(s, 1, "outrider-squad")
	s.phase = "fight"
	s.fight_actor = 1
	s.fight_step = "attacks"
	s.fight_selected = outriders
	s.squads[outriders].charged = true
	var spear_use := D.apply(s, 1, {"target": outriders, "model": -1, "value": D.SPEAR_THRUST, "mode": "both"})
	var blade: Dictionary = s.squads[outriders].melee_weapon.duplicate(true)
	var empowered := D.weapon(s, outriders, blade, blade, true)
	check(D.spearpoint_mounted(s, outriders) and spear_use.error.is_empty() and s.cp[1] == 2 and empowered.keywords.get("lethal-hits", false) and empowered.keywords.get("lance", false), "Mounted Outriders receive both Spear Thrust and Sabre Swing melee traits")
	check(not D.weapon(s, outriders, blade, blade, false).keywords.get("lance", false), "Spear Thrust and Sabre Swing does not change ranged attacks")

	s = fixture()
	outriders = find_squad(s, 1, "outrider-squad")
	s.phase = "movement"
	s.active = 1
	var model := first_model(s, outriders)
	var first_dense_wall := Rect2(-1, -2, 1, 4)
	var second_dense_wall := Rect2(2, -2, 1, 4)
	s.terrain.areas = [{"name": "Separated Dense walls", "category": "dense", "bounds": Rect2(-1, -2, 4, 4), "features": [{"bounds": first_dense_wall, "height": 4.0, "blocks_end": true}, {"bounds": second_dense_wall, "height": 4.0, "blocks_end": true}]}]
	s.units[model].position = Vector2(-5, 0)
	var blocked_path := C.Terrain.path_error(s, model, Vector2(5, 0))
	var flawless_begin := C.begin_movement(s, 1, model, "normal", s.revision)
	check(flawless_begin.is_empty(), "Mounted movement opens the Flawless Riders decision: " + flawless_begin + " / " + str(s.unit_abilities.window))
	var flawless_choice: Dictionary = {}
	for option: Dictionary in C.unit_choices(s,1):
		if option.get("action", "") == "detachment-stratagem" and option.get("target", -1) == outriders and option.get("value", "") == D.FLAWLESS_RIDERS: flawless_choice = option
	var flawless_decision := C.UnitActions.pending_decision(s)
	var flawless_restore: Dictionary = bytes_to_var(var_to_bytes(s))
	var restored_flawless_decision := C.UnitActions.pending_decision(flawless_restore)
	check(flawless_decision.get("priority_player_id", -1) == 1 and restored_flawless_decision.get("decision_id", "") == flawless_decision.get("decision_id", ""), "Flawless Riders Movement decision survives save and restore for the selected player")
	var flawless_result := submit_choice(flawless_restore, 1, "detachment-stratagem", outriders, -1, D.FLAWLESS_RIDERS) if not flawless_choice.is_empty() else {"error": "Flawless Riders was not projected into the pending movement decision."}
	var flawless_error := str(flawless_result.get("error", ""))
	s = flawless_restore
	check(flawless_error.is_empty() and s.cp[1] == 2 and D.mobile_active(s, outriders), "Flawless Riders spends 1 CP, grants Mobile and resumes the selected move: " + flawless_error + " / " + str(flawless_choice))
	var mobile_wall_path_error := C.Terrain.path_error(s, model, Vector2(5, 0))
	var mobile_wall_endpoint_error := C.Terrain.path_error(s, model, Vector2(0, 0))
	var crosses_both_walls := C.Terrain.segment_hits(s.units[model].position, Vector2(5, 0), first_dense_wall.grow(float(s.units[model].radius) - 0.001)) and C.Terrain.segment_hits(s.units[model].position, Vector2(5, 0), second_dense_wall.grow(float(s.units[model].radius) - 0.001))
	check(not blocked_path.is_empty() and C.Terrain.mobile_unit(s, model) and mobile_wall_path_error.is_empty() and crosses_both_walls, "Flawless Riders Mobile status permits its Outrider to pass through two separated Dense wall features")
	check(not mobile_wall_endpoint_error.is_empty() and mobile_wall_endpoint_error.contains("finish inside"), "Mobile still cannot finish inside a Solid Dense wall")

	s = fixture()
	outriders = find_squad(s, 1, "outrider-squad")
	var charge_target := first_squad(s, 2)
	var charge_enemy_model := first_model(s, charge_target)
	var charge_models := D.living(s, outriders)
	for index in range(charge_models.size()): s.units[charge_models[index]].position = Vector2(-5, float(index - 1) * 1.4)
	var charge_origins := {}
	for charge_model: int in charge_models: charge_origins[charge_model] = s.units[charge_model].position
	var target_models := D.living(s, charge_target)
	for index in range(target_models.size()): s.units[target_models[index]].position = Vector2(25, 20 + float(index))
	for index in range(mini(charge_models.size(), target_models.size())): s.units[target_models[index]].position = Vector2(5, float(index - 1) * 1.5)
	charge_enemy_model = target_models[0]
	var dense_wall := Rect2(-1, -12, 2, 24)
	s.terrain.areas = [{"name": "Dense wall", "category": "dense", "bounds": dense_wall, "features": [{"bounds": dense_wall, "height": 4.0, "blocks_end": true}]}]
	s.phase = "charge"
	s.active = 1
	model = charge_models[1]
	var charge_wall_before := C.Terrain.path_error(s, model, Vector2(5, 0))
	var charge_declaration := C.declare_charge(s, 1, model, s.revision, func() -> int: return 6)
	var charge_window_ok: bool = charge_declaration.error.is_empty() and s.unit_abilities.window.get("kind", "") == D.UNSTOPPABLE_WINDOW
	var charge_mobile_error := "No Flawless Riders declaration window."
	var charge_flow_error := ""
	if charge_window_ok:
		var flawless_charge_choice := {}
		for option: Dictionary in C.unit_choices(s, 1):
			if option.get("action", "") == "detachment-stratagem" and option.get("value", "") == D.FLAWLESS_RIDERS: flawless_charge_choice = option
		if flawless_charge_choice.is_empty(): charge_mobile_error = "Flawless Riders was not offered for the charge declaration."
		else:
			var charge_mobile_result := submit_choice(s, 1, "detachment-stratagem", outriders, -1, D.FLAWLESS_RIDERS, func() -> int: return 6)
			charge_mobile_error = str(charge_mobile_result.get("error", ""))
	if charge_mobile_error.is_empty() and not C.Stratagems.pending(s).is_empty():
		var charge_decision := C.Stratagems.pending_decision(s)
		var accept_charge_option: Dictionary = {}
		for option: Dictionary in charge_decision.get("legal_options", []):
			if int(option.get("target", -1)) == outriders and str(option.get("value", "")) == "" and int(option.get("details", {}).get("die", -1)) == -1: accept_charge_option = option
		var accept_charge_choice := {"action": "stratagem-reaction", "model": -1, "target": outriders, "value": "", "die": -1}
		var accept_charge_envelope := {"_decision_type": MatchCommandService.STRATAGEM_DECISION_ENVELOPE, "decision_id": str(charge_decision.get("decision_id", "")), "option_id": str(accept_charge_option.get("id", "")), "choice": accept_charge_choice}
		var before_wrong_charge_owner := var_to_bytes(s)
		var wrong_charge_owner := MatchCommandService.execute(s, 2, {"kind": MatchCommandService.COMMAND_REACTION, "choice": accept_charge_envelope, "revision": s.revision}, func() -> int: return 6)
		check(not str(wrong_charge_owner.get("error", "")).is_empty() and var_to_bytes(s) == before_wrong_charge_owner, "The opponent cannot accept or mutate the Charge roll decision")
		var accepted_charge := MatchCommandService.execute(s, 1, {"kind": MatchCommandService.COMMAND_REACTION, "choice": accept_charge_envelope, "revision": s.revision}, func() -> int: return 6)
		charge_flow_error = str(accepted_charge.get("error", ""))
	if charge_flow_error.is_empty() and s.pending_charge.is_empty(): charge_flow_error = "Charge roll did not produce a pending target choice."
	var charge_result := {"error": charge_flow_error}
	if charge_flow_error.is_empty(): charge_result = C.charge(s, 1, charge_enemy_model, s.revision)
	var charged_bases_clear := true
	var crossed_dense_wall := false
	for index in range(charge_models.size()):
		for other_index in range(index + 1, charge_models.size()):
			var first: int = charge_models[index]
			var second: int = charge_models[other_index]
			if s.units[first].position.distance_to(s.units[second].position) < float(s.units[first].radius) + float(s.units[second].radius) - 0.001: charged_bases_clear = false
	for charge_model: int in charge_models:
		if not C.Terrain.segment_hits(charge_origins[charge_model], s.units[charge_model].position, dense_wall.grow(float(s.units[charge_model].radius) - 0.001)): continue
		var charge_probe := s.duplicate(true)
		charge_probe.units[charge_model].position = charge_origins[charge_model]
		if C.Terrain.path_error(charge_probe, charge_model, s.units[charge_model].position).is_empty(): crossed_dense_wall = true
	check(not charge_wall_before.is_empty() and charge_declaration.error.is_empty() and charge_mobile_error.is_empty() and charge_flow_error.is_empty() and charge_result.error.is_empty() and s.squads[outriders].charged and D.mobile_active(s, outriders) and charged_bases_clear and crossed_dense_wall, "Flawless Riders grants Mobile through the real Charge declaration and forces a legal Dense-wall crossing while preserving non-overlapping bases in the charge: " + str(charge_declaration) + " / " + charge_mobile_error + " / " + charge_flow_error + " / " + str(charge_result))

	s = fixture()
	var intercessors := find_squad(s, 1, "intercessor-squad")
	s.phase = "movement"
	s.active = 1
	model = first_model(s, intercessors)
	var lethality_begin := C.begin_movement(s, 1, model, "advance", s.revision, func() -> int: return 2)
	check(lethality_begin.is_empty(), "Advance opens the Mobile Lethality decision: " + lethality_begin + " / " + str(s.unit_abilities.window))
	var lethality_choice: Dictionary = {}
	for option: Dictionary in C.unit_choices(s,1):
		if option.get("action", "") == "detachment-stratagem" and option.get("target", -1) == intercessors and option.get("value", "") == D.MOBILE_LETHALITY: lethality_choice = option
	var lethality_result := submit_choice(s, 1, "detachment-stratagem", intercessors, -1, D.MOBILE_LETHALITY, func() -> int: return 2) if not lethality_choice.is_empty() else {"error": "Mobile Lethality was not projected into the pending movement decision."}
	var lethality_error := str(lethality_result.get("error", ""))
	s.squads[intercessors].fell_back = true
	var gun: Dictionary = s.squads[intercessors].weapon.duplicate(true)
	var assault_gun := D.weapon(s, intercessors, gun, gun, false)
	check(lethality_error.is_empty() and s.cp[1] == 2 and D.mobile_lethality_active(s, intercessors) and assault_gun.keywords.get("assault", false) and C.Doctrines.shoot_after_fallback(s, intercessors), "Mobile Lethality grants ranged Assault and shooting after Fall Back for this turn: " + lethality_error + " / " + str(lethality_choice))

	s = fixture()
	outriders = find_squad(s, 1, "outrider-squad")
	s.phase = "shooting"
	s.active = 2
	s.terrain.areas = []
	var shooting_enemy := first_squad(s, 2)
	for living_model: int in s.units:
		if s.units[living_model].wounds <= 0: continue
		s.units[living_model].on_battlefield = true
		if s.units[living_model].owner == 2: s.units[living_model].position = Vector2(28, 10 + float(living_model % 3) * 1.2)
		elif s.units[living_model].squad == outriders: s.units[living_model].position = Vector2(20, 10 + float(living_model % 3) * 1.2)
	var enemy_attacker := first_model(s, shooting_enemy)
	var attack_choices: Array = C.AttackPlan.Equipment.choices(s, enemy_attacker, false)
	var ranged_choice: Dictionary = {}
	for candidate: Dictionary in attack_choices:
		if outriders in C.AttackPlan.legal_targets(s, enemy_attacker, false, str(candidate.weapon), str(candidate.profile)):
			ranged_choice = candidate
			break
	var evasive_entries: Array = []
	var evasive_attack_result: Dictionary = {"error": "No legal ranged profile can target the mounted unit."}
	if not ranged_choice.is_empty():
		evasive_entries = [{"model": enemy_attacker, "target": outriders, "amount": 1, "weapon": ranged_choice.weapon, "profile": ranged_choice.profile}]
		evasive_attack_result = MatchCommandService.execute(s, 2, {"kind": MatchCommandService.ATTACK_PLAN, "revision": s.revision, "attacker": enemy_attacker, "entries": evasive_entries, "melee": false, "use_lethal": false}, func() -> int: return 6)
	var evasive_decision := C.UnitActions.pending_decision(s)
	var evasive_frame := ResolutionFrames.current(s)
	var before_evasive_close := var_to_str(s)
	var evasive_close_error := C.advance_phase(s, 2, s.revision)
	var evasive_restore: Dictionary = bytes_to_var(var_to_bytes(s))
	var restored_evasive_decision := C.UnitActions.pending_decision(evasive_restore)
	var restored_evasive_frame_id := str(ResolutionFrames.current(evasive_restore).get("frame_id", ""))
	var evasive_result := submit_choice(evasive_restore, 1, "evasive-use", outriders, -1, "", func() -> int: return 6)
	var resumed_evasive_plan := C.AttackPlan.prepare(evasive_restore, shooting_enemy, false, evasive_entries, true)
	var evasive_modifier := int(resumed_evasive_plan.get("batches", [{}])[0].get("context", {}).get("wound_modifier", 0)) if resumed_evasive_plan.get("error", "").is_empty() and not resumed_evasive_plan.get("batches", []).is_empty() else 0
	var evasive_debug := {"spearpoint": D.spearpoint_mounted(s, outriders), "attack_error": evasive_attack_result.get("error", ""), "actor": evasive_decision.get("priority_player_id", -1), "decision_id": evasive_decision.get("decision_id", ""), "restored_decision_id": restored_evasive_decision.get("decision_id", ""), "frame_id": evasive_frame.get("frame_id", ""), "resume_frame_id": evasive_decision.get("resume_frame_id", ""), "restored_frame_id": restored_evasive_frame_id, "close_error": evasive_close_error, "state_unchanged": var_to_str(s) == before_evasive_close, "choice_error": evasive_result.get("error", ""), "cp": evasive_restore.cp[1], "active": D.evasive_active(evasive_restore, outriders), "modifier": evasive_modifier, "shot": evasive_restore.squads[shooting_enemy].shot, "final_frame": ResolutionFrames.current(evasive_restore)}
	check(evasive_debug.spearpoint and str(evasive_debug.attack_error).is_empty() and int(evasive_debug.actor) == 1 and str(evasive_debug.resume_frame_id) == str(evasive_debug.frame_id) and not str(evasive_debug.close_error).is_empty() and bool(evasive_debug.state_unchanged) and str(evasive_debug.decision_id) == str(evasive_debug.restored_decision_id) and str(evasive_debug.frame_id) == str(evasive_debug.restored_frame_id) and str(evasive_debug.choice_error).is_empty() and int(evasive_debug.cp) == 2 and bool(evasive_debug.active) and int(evasive_debug.modifier) == -1 and bool(evasive_debug.shot) and Dictionary(evasive_debug.final_frame).is_empty(), "Evasive Manoeuvres resumes the serialized real attack through the normalized defender choice and applies -1 to Wound: " + str(evasive_debug))

	s = fixture()
	outriders = find_squad(s, 1, "outrider-squad")
	s.phase = "fight"
	s.active = 2
	s.fight_actor = 2
	s.fight_step = "complete"
	s.squads[outriders].fight_eligible = true
	s.squads[outriders].fought = true
	s.squads[outriders].training_cost = 100
	s.board_size = Vector2(60, 44)
	for positioned_model: int in s.units:
		if s.units[positioned_model].wounds <= 0: continue
		s.units[positioned_model].on_battlefield = true
		var x := 5.0 if s.units[positioned_model].owner == 1 else 40.0
		s.units[positioned_model].position = Vector2(x, 5.0 + float(positioned_model % 3) * 3.0)
	s.unit_abilities.window = {}
	s.unit_abilities.end_done = ""
	s.unit_abilities.phase_key = C.UnitActions.key(s)
	s.resolution_frames = []
	var withdraw_close_error := C.advance_phase(s, 2, s.revision)
	var withdraw_decision := C.UnitActions.pending_decision(s)
	check(withdraw_close_error.is_empty() and withdraw_decision.get("priority_player_id", -1) == 2 and ResolutionFrames.current(s).get("kind", "") == "phase-close", "Withdraw and Regroup opens in the ordered Fight-end window under phase close: " + withdraw_close_error)
	var first_end_pass := submit_choice(s, 2, "pass")
	withdraw_decision = C.UnitActions.pending_decision(s)
	check(str(first_end_pass.get("error", "")).is_empty() and withdraw_decision.get("priority_player_id", -1) == 1 and ResolutionFrames.current(s).get("kind", "") == "phase-close", "Player 2 can decline earlier end choices and hand the same phase-close continuation to the Spearpoint player: " + str(first_end_pass.get("error", "")))
	var withdraw_use := submit_choice(s, 1, "detachment-stratagem", outriders, -1, D.WITHDRAW_AND_REGROUP)
	var withdrawn := true
	for reserve_model: int in D.living(s, outriders):
		if s.units[reserve_model].get("on_battlefield", true): withdrawn = false
	check(str(withdraw_use.get("error", "")).is_empty() and s.cp[1] == 2 and s.unit_abilities.reserves.has(outriders) and withdrawn and s.unit_abilities.window.get("kind", "") == "end" and ResolutionFrames.current(s).get("kind", "") == "phase-close", "The public decision spends 1 CP, places the eligible Mounted unit in reserves and retains the end window: " + str(withdraw_use.get("error", "")))
	var withdraw_restored: Dictionary = bytes_to_var(var_to_bytes(s))
	var withdraw_pass := submit_choice(withdraw_restored, 1, "pass")
	check(str(withdraw_pass.get("error", "")).is_empty() and withdraw_restored.phase == "end_turn" and (ResolutionFrames.current(withdraw_restored).is_empty() or str(ResolutionFrames.current(withdraw_restored).get("action_id", "")) != "phase-close:%d:fight" % int(s.turn)), "Passing the remaining end choice resumes Fight close after save/restore: " + str(withdraw_pass.get("error", "")))

	s = fixture()
	intercessors = find_squad(s, 1, "intercessor-squad")
	s.phase = "movement"
	s.active = 2
	var enemy_squad := first_squad(s, 2)
	for enemy_model: int in D.living(s, enemy_squad): s.units[enemy_model].position = Vector2(4, 0)
	for friendly_model: int in D.living(s, intercessors): s.units[friendly_model].position = Vector2.ZERO
	D.record_move(s, enemy_squad)
	var opened_hunters_window := D.open_movement_reaction(s, enemy_squad)
	var hunters_decision := C.UnitActions.pending_decision(s)
	var hunters_restore: Dictionary = bytes_to_var(var_to_bytes(s))
	var restored_hunters_decision := C.UnitActions.pending_decision(hunters_restore)
	check(opened_hunters_window and hunters_decision.get("priority_player_id", -1) == 1 and restored_hunters_decision.get("decision_id", "") == hunters_decision.get("decision_id", ""), "Hunter's Instincts response opens through the movement trigger, belongs to the Spearpoint player and keeps its decision identity after save and restore")
	var hunters_use := submit_choice(hunters_restore, 1, "detachment-stratagem", intercessors, -1, D.HUNTERS_INSTINCTS, func() -> int: return 2)
	check(str(hunters_use.get("error", "")).is_empty() and hunters_restore.cp[1] == 2 and hunters_restore.unit_abilities.window.get("kind", "") == "tactics" and hunters_restore.detachment_stratagems.tactics.get(intercessors, {}).get("inches", 0) == 5, "The normalized Hunter's Instincts response spends 1 CP and opens its D3+3 Normal Move: " + str(hunters_use))

	print("Spearpoint stratagem checks: %d failures" % failures)
	quit(0 if failures == 0 else 1)
