extends SceneTree
const F = preload("res://tests/all_units_fixture.gd")
const P = F.P
const C = F.C
const M = C.Mission
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
func act(s: Dictionary, player: int, action: String, model: int = -2, target: int = -2) -> String:
	return C.unit_action(s, player, pick(s, player, action, model, target), Vector2.ZERO, s.revision, die)
func run() -> void:
	check(P.initial_state({"official_mission": true}).has("error"), "Official mission requires current rule options")
	var s := fresh()
	check(not s.has("error"), "Ten types enter the selected mission")
	if s.has("error"): quit(1); return
	check(s.board_size == Vector2(60, 44) and M.enabled(s) and s.match_manifest.mission == M.ID and not s.roster_points_validated, "Official mission identity/board do not certify reference points")
	check(s.pack_hash == fresh().pack_hash and s.pack_hash != F.fresh().pack_hash, "Mission selection freezes into public identity")
	var before := var_to_bytes(s)
	var selection := pick(s, 1, "mission-terrain")
	check(not C.unit_action(s, 2, selection, Vector2.ZERO, s.revision, die).is_empty() and not C.unit_action(s, 1, selection, Vector2.ZERO, -1, die).is_empty() and calls == 0 and var_to_bytes(s) == before, "Foreign/stale mission choices consume no dice and change nothing")
	check(not C.select_awakened_attachment(s, 2, 4, s.revision).is_empty() and not C.Deployment.preset(s, 1, s.revision).is_empty(), "Preparation cannot be bypassed by attachment/deployment commands")
	dice = [6]
	check(act(s, 1, "mission-terrain").is_empty() and s.mission.objectives.size() == 6, "Six selects two central terrain objectives")
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
		var error := C.Deployment.preset(s, player, s.revision)
		if error.is_empty(): error = C.Deployment.confirm(s, player, s.revision)
		check(error.is_empty(), "Coherent mission preview deploys: " + error)
		if not error.is_empty(): quit(1); return
	check(s.phase == "mission_first_turn" and s.cp == {1: 0, 2: 0}, "First-turn roll follows deployment, before CP or pre-battle rules")
	dice = [1, 6]
	check(act(s, 1, "mission-first").is_empty() and s.first_player == 2 and s.active == 2 and s.turn == 1 and s.round == 1, "Player two can take the first turn")
	check(act(s, 1, "battle-done").is_empty(), "Homer declaration follows first-turn selection")
	var cp_fixture := s.duplicate(true)
	check(C.advance_phase(cp_fixture, 2, cp_fixture.revision, die).is_empty() and cp_fixture.cp == {1: 2, 2: 1}, "Captain round-start CP is granted when player two takes the first turn")
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
		if C.Doctrines.needs_choice(s): error = C.select_combat_doctrine(s, s.active, "none", s.revision)
		elif not pick(s, C.actor(s), "pass").is_empty(): error = act(s, C.actor(s), "pass")
		else: error = C.advance_phase(s, C.actor(s), s.revision, die)
		check(error.is_empty(), "Full mission progresses after wipeout: " + error)
		if not error.is_empty(): break
	check(s.turn == 10 and s.round == 5 and s.test_winner == 1 and seen == [2,1,2,1,2,1,2,1,2,1] and s.mission.scores == {1: 18, 2: 8}, "Five full rounds preserve randomized turn order; wipeout does not replace VP victory; painting bonus applies once")
	before = var_to_bytes(s)
	check(not C.advance_phase(s, 1, s.revision, die).is_empty() and var_to_bytes(s) == before, "Finished battle cannot score or gain CP again")
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	game.auto_models.button_pressed = false
	game.official_mission_choice.button_pressed = true
	for player in [1,2]: F.populate(game, player)
	game._start_saved_match()
	check(game.official_mission and M.enabled(game.state) and game.action_groups.unit.container.visible and not game.action_groups.awakened.container.visible and "Mission preparation" in game.decision_label.text, "UI focuses the required mission choice")
	game._apply_unit_action(1, pick(game.state, 1, "mission-terrain"), Vector2.ZERO, game.state.revision)
	var saved: Dictionary = game.state.duplicate(true)
	var rng_state: int = game.rng.state
	game._save_match()
	game.state = F.fresh()
	game._load_match()
	check(game.state == saved and game.rng.state == rng_state and game.official_mission and game.official_mission_choice.button_pressed, "Real save/load preserves pending mission stage, dice and frozen option")
	print("Chapter Approved checks: %d failures" % failures)
	quit(0 if failures == 0 else 1)
