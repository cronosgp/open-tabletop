extends SceneTree
const F = preload("res://tests/all_units_fixture.gd")
const P = F.P
const C = F.C
const M = C.Mission
const G = preload("res://scripts/edition_11/contact_movement.gd")
const Actions = preload("res://scripts/edition_11/actions.gd")
const MatchCommandService = preload("res://scripts/edition_11/match_command_service.gd")
const PendingDecisions = preload("res://scripts/edition_11/pending_decision_registry.gd")
var failures := 0
var dice: Array[int] = []
var calls := 0
func check(ok: bool, message: String) -> void:
	if not ok: push_error(message); failures += 1
func _initialize() -> void: call_deferred("run")
func die() -> int:
	calls += 1
	return dice.pop_front() if not dice.is_empty() else 6
func fresh() -> Dictionary:
	return P.initial_state({"official_mission": true, "unit_abilities": true, "combat_doctrines": true, "reanimation_protocols": true, "awakened_dynasty": true, "core_stratagems": true}, F.selections())
func pick(s: Dictionary, player: int, action: String, model: int = -2, target: int = -2) -> Dictionary:
	for selected: Dictionary in C.unit_choices(s, player):
		if selected.action == action and (model == -2 or selected.model == model) and (target == -2 or selected.target == target): return selected
	return {}
func submit_choice(s: Dictionary, player: int, selected: Dictionary, revision: int = -2147483648) -> Dictionary:
	var decision := PendingDecisions.current(s, ["mission-preparation", "unit-actions"])
	var payload := selected
	if not decision.is_empty():
		if int(decision.get("priority_player_id", -1)) != player: return {"error": "The current preparation choice belongs to another player."}
		var projected: Dictionary = {}
		for option: Dictionary in decision.get("legal_options", []):
			if str(option.get("action", "")) == str(selected.get("action", "")) and int(option.get("model", -1)) == int(selected.get("model", -1)) and int(option.get("target", -1)) == int(selected.get("target", -1)) and str(option.get("value", "")) == str(selected.get("value", "")): projected = option; break
		if projected.is_empty(): return {"error": "The selected preparation choice is not in the current projection."}
		payload = {"_decision_type": MatchCommandService.UNIT_CHOICE_ENVELOPE, "decision_id": str(decision.get("decision_id", "")), "option_id": str(projected.get("id", "")), "choice": selected}
	return MatchCommandService.execute(s, player, {"kind": MatchCommandService.SELECT_UNIT_CHOICE, "choice": payload, "point": Vector2.ZERO, "revision": int(s.revision) if revision == -2147483648 else revision}, die)
func act(s: Dictionary, player: int, action: String, model: int = -2, target: int = -2) -> String:
	var selected := pick(s, player, action, model, target)
	if selected.is_empty(): return "Unavailable: " + action
	return str(submit_choice(s, player, selected).get("error", ""))
func choose_no_doctrine(s: Dictionary) -> String:
	var decision := C.Doctrines.pending_decision(s)
	for option: Dictionary in decision.get("legal_options", []):
		if str(option.get("value", "")) != "none": continue
		var result := MatchCommandService.execute(s, int(decision.get("priority_player_id", -1)), {"kind": MatchCommandService.SELECT_DOCTRINE, "doctrine": "none", "decision_id": str(decision.get("decision_id", "")), "option_id": str(option.get("id", "")), "revision": int(s.revision)})
		return str(result.get("error", ""))
	return "No projected no-doctrine option."
func run() -> void:
	check(P.initial_state({"official_mission": true}).has("error"), "Official mission requires current rule options")
	check(P.initial_state({"official_mission": true, "terrain_layout": "layout-I"}).has("error"), "Historical layout identifiers are not accepted as 11e layouts")
	var layout_b := P.initial_state({"official_mission": true, "unit_abilities": true, "combat_doctrines": true, "reanimation_protocols": true, "awakened_dynasty": true, "core_stratagems": true, "terrain_layout": "ca-2026-27-take-and-hold-mirror-b-v1"}, F.selections())
	check(not layout_b.has("error") and layout_b.mission.id == M.ID and layout_b.mission.terrain_layout == "ca-2026-27-take-and-hold-mirror-b-v1" and layout_b.terrain.id == layout_b.mission.terrain_layout and layout_b.match_manifest.terrain_layout == layout_b.mission.terrain_layout, "Selected 11e layout stays in mission and peer identity")
	dice = [6]
	check(act(layout_b, 1, "mission-terrain").is_empty() and layout_b.mission.terrain_layout == "ca-2026-27-take-and-hold-mirror-b-v1" and layout_b.mission.id == M.ID, "Central objective roll preserves the selected terrain and mission")
	calls = 0
	dice.clear()
	var s := fresh()
	check(not s.has("error"), "Ten types enter the selected mission")
	if s.has("error"): quit(1); return
	check(s.board_size == Vector2(60, 44) and M.enabled(s) and s.match_manifest.mission == M.ID and not s.roster_points_validated, "Official mission identity/board do not certify reference points")
	check(s.pack_hash == fresh().pack_hash and s.pack_hash != F.fresh().pack_hash, "Mission selection freezes into public identity")
	for primary_id: String in M.PRIMARY_MISSIONS:
		var selected_primary := P.initial_state({"official_mission": true, "primary_mission": primary_id, "unit_abilities": true, "combat_doctrines": true, "reanimation_protocols": true, "awakened_dynasty": true, "core_stratagems": true}, F.selections())
		check(not selected_primary.has("error") and M.primary_id(selected_primary) == primary_id and selected_primary.match_manifest.primary_mission == primary_id, "Primary mission selection is valid and part of match identity: " + primary_id)
	# Meatgrinder: current-turn kills, previous-turn friendly losses, and opponent home.
	var meatgrinder := s.duplicate(true)
	meatgrinder.mission.primary_id = "meatgrinder"
	meatgrinder.mission.attacker = 1; meatgrinder.mission.defender = 2
	meatgrinder.phase = "end_turn"; meatgrinder.active = 1; meatgrinder.round = 2; meatgrinder.turn = 3
	var enemy_squad := -1
	for squad: int in meatgrinder.squads:
		if meatgrinder.squads[squad].owner == 2 and not G.alive(meatgrinder, squad).is_empty(): enemy_squad = squad; break
	M.start_turn(meatgrinder)
	for model: int in G.alive(meatgrinder, enemy_squad): meatgrinder.units[model].wounds = 0
	for objective: Dictionary in meatgrinder.mission.objectives:
		if objective.role == "expansion" or objective.role == "defender": objective.controller = 1
	M.score(meatgrinder)
	check(enemy_squad >= 0 and meatgrinder.mission.primary[1] == 13, "Meatgrinder scores current kills, kill advantage, and opponent home at end of turn")
	var round_one_meatgrinder := s.duplicate(true)
	round_one_meatgrinder.mission.primary_id = "meatgrinder"
	round_one_meatgrinder.mission.attacker = 1; round_one_meatgrinder.mission.defender = 2
	round_one_meatgrinder.phase = "end_turn"; round_one_meatgrinder.active = 1; round_one_meatgrinder.round = 1
	for objective: Dictionary in round_one_meatgrinder.mission.objectives:
		if objective.role == "defender": objective.controller = 1
	M.score(round_one_meatgrinder)
	check(round_one_meatgrinder.mission.primary[1] == 0, "Meatgrinder's opponent-home bonus is not available before battle round two")
	# Reconnaissance Sweep: four-quarter score, destroyed units, and uncapped end-battle timing.
	var recon := s.duplicate(true)
	recon.mission.primary_id = "reconnaissance-sweep"
	recon.phase = "end_turn"; recon.active = 1; recon.round = 2; recon.turn = 3
	for squad: int in recon.squads:
		if recon.squads[squad].owner != 1: continue
		for model: int in G.alive(recon, squad): recon.units[model].wounds = 0
	var quarter_points := [Vector2(-10, -10), Vector2(10, -10), Vector2(-10, 10), Vector2(10, 10)]
	var used_quarters := 0
	var recon_quarter_squads: Array[int] = []
	for squad: int in recon.squads:
		if recon.squads[squad].owner != 1 or used_quarters >= 4: continue
		var squad_models: Array[int] = []
		for model: int in recon.units:
			if recon.units[model].squad == squad: squad_models.append(model)
		if squad_models.is_empty(): continue
		var first_model: int = squad_models[0]
		if used_quarters == 0: recon.squads[squad].battle_shocked = true
		if used_quarters == 1: recon.units[first_model].keywords.append("AIRCRAFT")
		recon.units[first_model].wounds = 1
		recon.units[first_model].position = quarter_points[used_quarters]
		recon_quarter_squads.append(squad)
		used_quarters += 1
	M.start_turn(recon)
	var recon_enemy := -1
	for squad: int in recon.squads:
		if recon.squads[squad].owner == 2 and not G.alive(recon, squad).is_empty(): recon_enemy = squad; break
	for model: int in G.alive(recon, recon_enemy): recon.units[model].wounds = 0
	var recon_turn_losses := M._turn_losses(recon)
	M.score(recon)
	check(used_quarters == 4 and M.quarters(recon, 1) == 2 and M.quarters(recon, 1, false) == 4 and recon.mission.primary[1] == 7, "Reconnaissance Sweep counts Battle-shocked and AIRCRAFT units in four-quarter VP, unlike Engage on All Fronts")
	var recon_reserves := recon.duplicate(true)
	var reserve_model: int = G.alive(recon_reserves, recon_quarter_squads[0])[0]
	recon_reserves.units[reserve_model].on_battlefield = false
	check(M.quarters(recon_reserves, 1, false) == 3, "Units outside the battlefield do not count toward table-quarter scoring")
	var recon_battle_end := s.duplicate(true)
	recon_battle_end.mission.primary_id = "reconnaissance-sweep"
	recon_battle_end.phase = "end_turn"; recon_battle_end.active = 1; recon_battle_end.first_player = 2; recon_battle_end.round = 5; recon_battle_end.turn = 10
	recon_battle_end.mission.primary[1] = 20
	recon_battle_end.mission.round_points["5:1:primary"] = 15
	recon_battle_end.mission.battle_ready = {1: false, 2: false}
	for squad: int in recon_battle_end.squads:
		for model: int in G.alive(recon_battle_end, squad):
			recon_battle_end.units[model].position.x = 15.0 if recon_battle_end.squads[squad].owner == 1 else -15.0
	var recon_ended := M.score(recon_battle_end)
	check(recon_battle_end.mission.primary[1] == 20 and recon_battle_end.mission.primary[2] == 0, "Reconnaissance Sweep end-battle bonus is blocked while enemy units remain wholly in each player's territory")
	var recon_clear_territory := recon_battle_end.duplicate(true)
	recon_clear_territory.mission.scored = []
	recon_clear_territory.mission.primary = {1: 20, 2: 20}
	recon_clear_territory.mission.round_points["5:1:primary"] = 15
	recon_clear_territory.mission.round_points["5:2:primary"] = 15
	for squad: int in recon_clear_territory.squads:
		for model: int in G.alive(recon_clear_territory, squad):
			recon_clear_territory.units[model].position.x = -15.0 if recon_clear_territory.squads[squad].owner == 1 else 15.0
	var recon_clear_ended := M.score(recon_clear_territory)
	check(recon_clear_territory.mission.primary[1] == 30 and recon_clear_territory.mission.primary[2] == 30 and recon_clear_ended, "Reconnaissance Sweep awards 10VP to both players when enemy units are outside their territory, ignoring the per-round cap but respecting the match cap")
	# Secure Asset: exclude home objectives and require explicit action completion.
	var secure := s.duplicate(true)
	secure.mission.primary_id = "secure-asset"; secure.mission.actions = ["secure-asset"]
	secure.mission.attacker = 1; secure.mission.defender = 2
	secure.phase = "shooting"; secure.active = 1; secure.round = 2; secure.turn = 3
	var asset_squad := -1
	for squad: int in secure.squads:
		if secure.squads[squad].owner == 1 and not G.alive(secure, squad).is_empty(): asset_squad = squad; break
	var asset_model: int = G.alive(secure, asset_squad)[0]
	var expansion_index := -1
	var home_index := -1
	for objective_index in range(secure.mission.objectives.size()):
		var objective: Dictionary = secure.mission.objectives[objective_index]
		if objective.role == "expansion" and expansion_index < 0: expansion_index = objective_index
		if objective.role == "attacker": home_index = objective_index
	secure.units[asset_model].position = secure.mission.objectives[expansion_index].bounds.get_center()
	secure.mission.objectives[expansion_index].controller = 1
	secure.mission.objectives[home_index].controller = 1
	check(Actions.start_error(secure, asset_squad, home_index) == "Secure Asset cannot target your home objective.", "Secure Asset rejects the player's home objective")
	check(Actions.start_error(secure, asset_squad, expansion_index).is_empty(), "Secure Asset accepts a controlled non-home objective")
	secure.squads[asset_squad].shot = true
	check("already shot" in Actions.start_error(secure, asset_squad, expansion_index), "Secure Asset follows the core rule that a unit cannot start an action after shooting")
	secure.squads[asset_squad].shot = false
	Actions.start(secure, asset_squad, expansion_index)
	Actions.complete_end_turn(secure)
	secure.phase = "end_turn"
	M.score(secure)
	check(secure.mission.asset_secured_turn[1] == secure.turn and secure.mission.primary[1] >= 4, "Secure Asset scores only after an explicit successful action")
	var before := var_to_bytes(s)
	var selection := pick(s, 1, "mission-terrain")
	var foreign_mission_choice := submit_choice(s, 2, selection)
	var stale_mission_choice := submit_choice(s, 1, selection, -1)
	check(not str(foreign_mission_choice.get("error", "")).is_empty() and not str(stale_mission_choice.get("error", "")).is_empty() and calls == 0 and var_to_bytes(s) == before, "Foreign/stale mission choices consume no dice and change nothing")
	check(not C.select_awakened_attachment(s, 2, 4, s.revision).is_empty() and not C.Deployment.preset(s, 1, s.revision).is_empty(), "Preparation cannot be bypassed by attachment/deployment commands")
	var mission_decision := M.pending_decision(s)
	check(mission_decision.get("source", "") == "mission-preparation" and mission_decision.get("priority_player_id", -1) == 1 and mission_decision.get("legal_options", []).size() == 1, "Mission setup exposes its current choice as a normalized decision")
	var mission_decision_id: String = mission_decision.decision_id
	var restored_mission: Dictionary = bytes_to_var(var_to_bytes(s))
	var restored_mission_decision := M.pending_decision(restored_mission)
	check(restored_mission_decision.get("decision_id", "") == mission_decision_id and restored_mission_decision.get("legal_options", []) == mission_decision.legal_options, "Serialized mission preparation retains its decision identity and legal options")
	var mission_only := C.initial_state()
	M.enable(mission_only)
	mission_only.phase = "pre_battle"
	var restored_close_error: String = C.PhaseCloseGate.close_request_error(mission_only, 1, mission_only.revision)
	check("mission preparation" in restored_close_error, "A pending mission-preparation choice blocks phase close")
	s = restored_mission
	mission_decision = restored_mission_decision
	var mission_option: Dictionary = mission_decision.legal_options[0]
	var mission_choice := pick(s, 1, "mission-terrain")
	var mission_before := var_to_bytes(s)
	var rejected_mission: Dictionary = MatchCommandService.execute(s, 1, {"kind": MatchCommandService.SELECT_UNIT_CHOICE, "choice": {"_decision_type": MatchCommandService.UNIT_CHOICE_ENVELOPE, "decision_id": mission_decision.decision_id, "option_id": "stale-option", "choice": mission_choice}, "revision": s.revision}, die)
	check(not rejected_mission.error.is_empty() and var_to_bytes(s) == mission_before and calls == 0, "Stale mission decision options are rejected transactionally")
	dice = [6]
	var accepted_mission: Dictionary = MatchCommandService.execute(s, 1, {"kind": MatchCommandService.SELECT_UNIT_CHOICE, "choice": {"_decision_type": MatchCommandService.UNIT_CHOICE_ENVELOPE, "decision_id": mission_decision.decision_id, "option_id": mission_option.id, "choice": mission_choice}, "revision": s.revision}, die)
	check(accepted_mission.error.is_empty() and s.mission.objectives.size() == 6, "A current mission decision option rolls two central terrain objectives")
	dice = [3, 3]
	check(act(s, 1, "mission-roles").is_empty() and s.mission.stage == "roles-roll", "Tied roll-off repeats without selecting a winner")
	dice = [2, 5]
	check(act(s, 1, "mission-roles").is_empty() and C.actor(s) == 2, "Roll-off winner controls role choice")
	check(act(s, 2, "mission-side", -2, 2).is_empty() and s.mission.defender == 1 and s.deployment.order[0] == 1 and s.deployment.zones[2] == Rect2(-30, -22, 18, 44), "Defender deploys first; roles select the correct full-size zones")
	check(act(s, 1, "mission-ready", -2, 1).is_empty() and act(s, 2, "mission-ready", -2, 0).is_empty() and s.mission.scores == {1: 0, 2: 0}, "Declared painting bonus is delayed until battle end")
	check(C.select_awakened_attachment(s, 2, -1, s.revision).is_empty(), "Existing Overlord setup follows mission declarations")
	check(act(s, 1, "attach", 900, 1).is_empty() and act(s, 1, "warlord", 300).is_empty() and act(s, 1, "reserve", -2, 11).is_empty(), "Current formations integrate with mission setup")
	var public := M.public_state(s, 2)
	check(public.unit_abilities.reserves.is_empty() and public.units[1100].on_battlefield and 11 in public.deployment.order and public.events.is_empty() and s.unit_abilities.reserves.has(11), "Unrevealed enemy reserves are absent from state, deployment omissions and events sent to guest")
	check(M.public_state(s, 1).unit_abilities.reserves.has(11), "Owner retains its own private declaration")
	check(act(s, 1, "setup-done").is_empty() and act(s, 2, "warlord", 600).is_empty() and act(s, 2, "setup-done").is_empty(), "Both players commit formations")
	check(M.public_state(s, 2) == s and not s.units[1100].on_battlefield and 11 not in s.deployment.order, "Both commitments reveal reserves and freeze deployment")
	while s.phase == "deployment":
		var player := C.Deployment.actor(s)
		var preset_result := MatchCommandService.execute(s, player, {"kind": MatchCommandService.DEPLOYMENT_PRESET, "revision": int(s.revision)})
		var error := str(preset_result.get("error", ""))
		if error.is_empty():
			var confirm_result := MatchCommandService.execute(s, player, {"kind": MatchCommandService.DEPLOYMENT_CONFIRM, "revision": int(s.revision)})
			error = str(confirm_result.get("error", ""))
		check(error.is_empty(), "Coherent mission preview deploys: " + error)
		if not error.is_empty(): quit(1); return
	check(s.phase == "mission_first_turn" and s.cp == {1: 0, 2: 0}, "First-turn roll follows deployment, before CP or pre-battle rules")
	dice = [1, 6]
	check(act(s, 1, "mission-first").is_empty() and s.first_player == 2 and s.active == 2 and s.turn == 1 and s.round == 1, "Player two can take the first turn")
	while C.UnitActions.battle_actor(s) > 0:
		var start_battle_owner := C.UnitActions.battle_actor(s)
		var battle_done_error := act(s, start_battle_owner, "battle-done")
		check(battle_done_error.is_empty(), "Start-of-battle declarations close through the current owner's choice: " + battle_done_error)
		if not battle_done_error.is_empty(): break
	var cp_fixture := s.duplicate(true)
	var cp_advance_result := MatchCommandService.execute(cp_fixture, 2, {"kind": MatchCommandService.ADVANCE_PHASE, "revision": int(cp_fixture.revision)}, die)
	check(str(cp_advance_result.get("error", "")).is_empty() and cp_fixture.cp == {1: 2, 2: 1}, "Captain round-start CP is granted when player two takes the first turn: %s, cp=%s" % [str(cp_advance_result.get("error", "")), str(cp_fixture.cp)])
	var scored := s.duplicate(true)
	scored.phase = "command"; scored.round = 2; scored.turn = 3
	for objective: Dictionary in scored.mission.objectives: objective.controller = 2
	check(not M.score(scored) and scored.mission.primary[2] == 15, "Cumulative home bonus is bounded by 15 primary VP per round")
	M.score(scored)
	check(scored.mission.primary[2] == 15, "Repeating a checkpoint never repeats VP")
	scored.phase = "end_turn"
	M.score(scored)
	check(scored.mission.primary[2] == 15, "Early-round end-turn bonus shares the same round cap")
	scored.round = 5; scored.turn = 9; scored.phase = "command"
	M.score(scored)
	check(scored.mission.primary[2] == 15, "Fifth-round primary is deferred for both players")
	scored.phase = "end_turn"
	M.score(scored)
	check(scored.mission.primary[2] == 30 and scored.test_winner == 0, "First player scores fifth-round primary at turn end without ending the battle")
	var capped := s.duplicate(true)
	capped.phase = "command"; capped.round = 3; capped.turn = 5
	capped.mission.primary[2] = 44; capped.mission.scores[2] = 44
	for objective: Dictionary in capped.mission.objectives: objective.controller = 2
	M.score(capped)
	check(capped.mission.primary[2] == 45 and capped.mission.scores[2] == 45, "Primary cannot exceed the match cap even when every objective scores")
	capped = s.duplicate(true)
	capped.phase = "end_turn"
	capped.mission.cards[1].assassination = 19
	capped.mission.secondary[1] = 19; capped.mission.scores[1] = 19
	capped.units[600].wounds = 0
	M.score(capped)
	check(capped.mission.cards[1].assassination == 20 and capped.mission.secondary[1] == 20, "An actual Character death cannot exceed its Fixed card's match cap")
	# Independent quarter geometry: an attached unit must fit as one whole unit.
	var geo := s.duplicate(true)
	for unit: Dictionary in geo.units.values(): unit.wounds = 0
	for row in [{"id": 100, "p": Vector2(-10,-10)}, {"id": 300, "p": Vector2(10,-10)}, {"id": 500, "p": Vector2(-10,10)}, {"id": 700, "p": Vector2(10,10)}]:
		geo.units[row.id].wounds = 1; geo.units[row.id].position = row.p
	check(M.quarters(geo, 1) == 4, "Four distinct living units cover four quarters")
	geo.units[900].wounds = 1; geo.units[900].position = Vector2(10,10)
	check(M.quarters(geo, 1) == 3, "Attached Support across a boundary invalidates its whole unit's quarter")
	geo.squads[5].battle_shocked = true
	check(M.quarters(geo, 1) == 2, "Battle-shocked units do not count for Engage")
	var deaths := s.duplicate(true)
	deaths.phase = "end_turn"
	deaths.units[300].wounds = 0
	deaths.units[600].wounds = 0
	M.score(deaths)
	check(deaths.mission.cards[1].assassination == 4 and deaths.mission.cards[2].assassination == 4, "Fixed Assassination scores model deaths for both players, including W4+ bonus")
	deaths.turn += 1
	M.score(deaths)
	check(deaths.mission.cards[1].assassination == 4, "Dead Characters are not scored again on the next turn")
	# Actual public phase loop, both armies wiped: still play all ten turns.
	for unit: Dictionary in s.units.values(): unit.wounds = 0
	var seen: Array[int] = []
	for step in range(180):
		if s.test_winner != 0: break
		if s.phase == "start_turn": seen.append(s.active)
		var error := ""
		if C.Doctrines.needs_choice(s): error = choose_no_doctrine(s)
		elif not pick(s, C.actor(s), "battle-done").is_empty(): error = act(s, C.actor(s), "battle-done")
		elif not pick(s, C.actor(s), "pass").is_empty(): error = act(s, C.actor(s), "pass")
		else:
			var advance_result := MatchCommandService.execute(s, C.actor(s), {"kind": MatchCommandService.ADVANCE_PHASE, "revision": int(s.revision)}, die)
			error = str(advance_result.get("error", ""))
		check(error.is_empty(), "Full mission progresses after wipeout: " + error)
		if not error.is_empty(): break
	check(s.turn == 10 and s.round == 5 and s.test_winner == 1 and seen == [2,1,2,1,2,1,2,1,2,1] and s.mission.scores == {1: 18, 2: 8}, "Five full rounds preserve randomized turn order; wipeout does not replace VP victory; painting bonus applies once")
	before = var_to_bytes(s)
	check(not C.advance_phase(s, 1, s.revision, die).is_empty() and var_to_bytes(s) == before, "Finished battle cannot score or gain CP again")
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	game.auto_models.button_pressed = false
	game.unit_abilities_choice.button_pressed = true
	game.combat_doctrines_choice.button_pressed = true
	game.awakened_dynasty_choice.button_pressed = true
	game.reanimation_protocols_choice.button_pressed = true
	game.stratagem_choice.button_pressed = true
	game.official_mission_choice.button_pressed = true
	game._select_official_primary_mission("secure-asset")
	game._select_official_terrain_layout("ca-2026-27-take-and-hold-mirror-b-v1")
	game._refresh_official_layout_preview()
	var preview_cached := FileAccess.file_exists(C.Terrain.event_layout_image_path("ca-2026-27-take-and-hold-mirror-b-v1"))
	if preview_cached:
		check(game.official_layout_preview.texture != null and "Terrain preview only" in game.official_layout_preview_status.text, "Cached 11e preview loads with terrain-only mission note")
	else:
		check(game.official_layout_preview.texture == null and "not cached" in game.official_layout_preview_status.text, "Optional 11e preview cache is not required for mission setup")
	var selected_layout_index: int = game.official_layout_choice.selected
	var selected_layout_id := str(game.official_layout_choice.get_item_metadata(selected_layout_index))
	game.official_layout_choice.set_item_metadata(selected_layout_index, "uncached-layout")
	game._refresh_official_layout_preview()
	check(game.official_layout_preview.texture == null and "not cached" in game.official_layout_preview_status.text, "Missing source diagram shows the playable proxy placeholder")
	game.official_layout_choice.set_item_metadata(selected_layout_index, selected_layout_id)
	game._refresh_official_layout_preview()
	game._start_prepared_match()
	check(game.official_mission and M.enabled(game.state) and M.primary_id(game.state) == "secure-asset" and game.state.mission.terrain_layout == "ca-2026-27-take-and-hold-mirror-b-v1" and game.action_groups.unit.container.visible and not game.action_groups.awakened.container.visible and "Mission preparation" in game.decision_label.text, "UI applies selected mission and focuses required preparation")
	game._apply_unit_action(1, pick(game.state, 1, "mission-terrain"), Vector2.ZERO, game.state.revision)
	var saved: Dictionary = game.state.duplicate(true)
	var rng_state: int = game.rng.state
	game._save_match()
	game.state = F.fresh()
	game._load_match()
	check(game.state == saved and game.rng.state == rng_state and game.official_mission and game.official_mission_choice.button_pressed and game._selected_official_primary_mission() == "secure-asset" and M.primary_id(game.state) == "secure-asset" and game._selected_official_terrain_layout() == "ca-2026-27-take-and-hold-mirror-b-v1", "Real save/load preserves pending mission stage, primary mission, dice, and terrain layout")
	print("Chapter Approved checks: %d failures" % failures)
	game.free()
	for frame in range(5): await process_frame
	quit(0 if failures == 0 else 1)
