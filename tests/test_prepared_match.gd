extends SceneTree
const Prepared = preload("res://scripts/edition_11/prepared_training.gd")
const D = Prepared.Deployment
const C = Prepared.Combat
var failures := 0
func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1
func _initialize() -> void: call_deferred("run")
func run() -> void:
	check(Prepared.initial_state({"points": 500}).has("error") and Prepared.initial_state({"manual_allocation": 1}).has("error"), "Unknown/malformed configuration is rejected")
	var s := Prepared.initial_state()
	if s.has("error"):
		push_error(s.error)
		quit(1)
		return
	check(s.phase == "deployment" and D.current(s) == 1 and C.actor(s) == 1, "Prepared match begins before round 1")
	check(s.deployment.order == [1, 2, 3, 4] and s.match_manifest.rosters.size() == 2 and not s.roster_points_validated, "Fixed rosters and alternating order do not claim official legality")
	check(s.pack_hash == Prepared.initial_state().pack_hash and s.pack_hash != Prepared.initial_state({"manual_allocation": false}).pack_hash, "Manifest identity is stable and includes options")
	var before := var_to_str(s)
	check(not D.place(s, 2, 100, Vector2(-18, 0), 0).is_empty(), "Wrong player cannot deploy")
	check(not D.place(s, 1, 200, Vector2(-18, 0), 0).is_empty(), "Opponent model cannot deploy")
	check(not D.place(s, 1, 100, Vector2(NAN, 0), 0).is_empty(), "Non-finite placement rejected")
	check(not D.place(s, 1, 100, Vector2(-10.5, 0), 0).is_empty(), "Whole base must fit within zone")
	check(not D.confirm(s, 1, 0).is_empty(), "Unplaced preview cannot be confirmed")
	check(not C.advance_phase(s, 1, 0).is_empty() and not C.move(s, 1, 100, Vector2(-18, 0), 0).is_empty(), "Ordinary commands cannot bypass deployment")
	check(var_to_str(s) == before, "Rejected setup commands leave state unchanged")
	check(D.place(s, 1, 100, Vector2(-20, 0), 0).is_empty(), "Deployment ignores ordinary movement range")
	before = var_to_str(s)
	check(not D.place(s, 1, 101, Vector2(-20, 0), s.revision).is_empty(), "Placed bases cannot overlap")
	check(not D.preset(s, 1, 0).is_empty() and var_to_str(s) == before, "Stale setup request cannot change state")
	check(D.preset(s, 1, s.revision).is_empty() and not D.confirm(s, 1, s.revision).is_empty(), "Every position can be valid while unit coherency still blocks confirmation")
	check(D.place(s, 1, 100, Vector2(-12, -6.6), s.revision).is_empty() and D.confirm(s, 1, s.revision).is_empty(), "Corrected placement commits coherent unit")
	check(C.actor(s) == 2 and D.current(s) == 2, "Next deployment belongs to opponent")
	before = var_to_str(s)
	check(not D.place(s, 2, 200, Vector2(11.2, -4), s.revision).is_empty() and var_to_str(s) == before, "Deployment cannot finish in a barricade")
	for squad in [2, 3, 4]:
		var owner: int = s.squads[squad].owner
		check(D.preset(s, owner, s.revision).is_empty() and D.confirm(s, owner, s.revision).is_empty(), "Remaining preset unit deploys")
	check(s.phase == "start_turn" and s.round == 1 and s.turn == 1 and s.active == 1 and s.cp == {1: 0, 2: 0}, "No turn, command points or scoring occur during deployment")
	before = var_to_str(s)
	check(not D.place(s, 1, 100, Vector2(-18, 0), s.revision).is_empty() and var_to_str(s) == before, "Deployment commands cannot reposition after start")
	for step in range(100):
		if s.test_winner != 0: break
		check(C.advance_phase(s, C.actor(s), s.revision).is_empty(), "Prepared mission progresses without technical intervention")
	check(s.test_winner == -1 and s.mission.scored_rounds == [1, 2, 3, 4, 5], "Prepared setup reaches five-round scoring and a final result")
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	game._start_prepared_match()
	check(game.prepared_match and game.state.pack_hash == game._initial_state().pack_hash, "UI and host/rejoin factories agree")
	check(game.action_groups.deployment.container.visible and not game.action_groups.attack.container.visible and game.deployment_confirm_button.disabled, "Deployment exposes only its contextual controls")
	game.guides.preview(game.state, 100, true, 1, Vector2(-100, 100))
	check(not game.guides.hover_valid and game.guides.hover_mesh.get_surface_count() == 0, "Off-board cursor does not create an empty rendering surface")
	game._request_deployment_preset()
	check(not game.deployment_confirm_button.disabled and "5/5" in game.deployment_help.text, "Preset placement enables explicit confirmation")
	game._request_end()
	check(C.actor(game.state) == 2 and "player 2" in game.decision_label.text.to_lower(), "UI identifies next decision owner")
	game._start_objectives()
	check(not game.prepared_match and game.state.phase == "start_turn", "Existing exercises remain separate")
	print("Prepared match checks: %d failures" % failures)
	quit(0 if failures == 0 else 1)
