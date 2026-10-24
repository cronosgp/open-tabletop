extends SceneTree

const Deployment = preload("res://scripts/edition_11/deployment.gd")
const UnitActions = preload("res://scripts/edition_11/unit_actions.gd")
const Objectives = preload("res://scripts/edition_11/objectives.gd")
const AttackPlan = preload("res://scripts/edition_11/attack_plan.gd")

var failures := 0

func _initialize() -> void:
	call_deferred("run")

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func run() -> void:
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	var run_id := str(Time.get_ticks_usec())
	game.match_save_path = "user://matches/vertical-slice-%s.save" % run_id
	game.match_journal_directory = "user://matches/journals/vertical-slice-%s" % run_id
	game.rng.seed = 1040001
	game.auto_models.button_pressed = false
	game.unit_abilities_choice.set_pressed_no_signal(true)
	for option in [game.combat_doctrines_choice, game.awakened_dynasty_choice, game.reanimation_protocols_choice, game.stratagem_choice, game.reroll_choice, game.attack_reroll_choice, game.save_reroll_choice, game.damage_reroll_choice, game.hazard_reroll_choice, game.escape_reroll_choice, game.count_reroll_choice, game.official_mission_choice, game.checked_rosters_choice]:
		option.set_pressed_no_signal(false)
	game._start_saved_match()
	check(game.saved_army_mode and game.state.get("phase") == "deployment", "Saved-army setup starts the current-catalog local match")
	check(game.state.get("training_points", {}) == {1: 550, 2: 550}, "Both seats use the 550-point current Space Marines practice list")
	check(game.state.get("points_limit", 0) == 1000 and not game.state.get("roster_points_validated", true), "The 1000-point training ceiling does not claim army legality")
	check(game.state.get("mission", {}).get("id", "") == Objectives.TRAINING and game.state.get("mission", {}).get("rounds", 0) == 5, "The match uses the explicit five-round custom objective mission")
	check(game.state.get("test_battlefield", "") == "saved-army-training-43x43-v1" and game.state.get("board_size") == Vector2(43, 43), "The match uses the bounded 43-by-43 training battlefield")
	check(game.state.get("units", {}).size() == 40 and game.state.get("squads", {}).size() == 8, "The two reference lists materialize as eight five-model squads")
	if failures > 0:
		finish(game)
		return

	# Use the in-game preparation, deployment and phase commands for the bounded sample.
	while UnitActions.setup_actor(game.state) > 0:
		var owner := UnitActions.setup_actor(game.state)
		if not submit_choice(game, owner, "setup-done"):
			check(false, "Both players can finish the current-ability preparation step")
			finish(game)
			return
	for _step in range(12):
		if Deployment.current(game.state) < 0: break
		var owner := Deployment.actor(game.state)
		var squad := Deployment.current(game.state)
		if owner == 1 and squad == 5:
			# Put P1's first Terminator squad in the nearby Rubble objective using
			# legal per-model deployment commands, so the match exercises scoring.
			for model: int in game.Combat.living(game.state, squad):
				var place_revision: int = game.state.revision
				var destination: Vector2 = game.state.units[model].position + Vector2(0.7, 0)
				game._apply_move(owner, model, destination, place_revision)
				check(game.state.revision > place_revision and game.state.units[model].position == destination, "A P1 Terminator accepts its legal in-zone deployment position")
				if failures > 0:
					finish(game)
					return
		else:
			var preview_revision: int = game.state.revision
			game._apply_deployment(owner, preview_revision, false)
			if game.state.revision == preview_revision:
				check(false, "The current unit accepts its deployment preview (P%d squad %d: %s)" % [owner, squad, game.status.text])
				finish(game)
				return
		var revision: int = game.state.revision
		game._apply_deployment(owner, revision, true)
		if game.state.revision == revision:
			check(false, "The deployed unit commits through the match command flow")
			finish(game)
			return
	check(Deployment.current(game.state) == -1 and game.state.get("deployment", {}).get("complete", false), "All four units complete alternating deployment")

	for _step in range(40):
		if game.state.get("phase", "") == "movement": break
		var battle_owner := UnitActions.battle_actor(game.state)
		if battle_owner > 0:
			if not submit_choice(game, battle_owner, "battle-done"):
				check(false, "Optional Terminator Teleport Homer declarations can be skipped")
				finish(game)
				return
			continue
		var decision_owner := UnitActions.actor(game.state)
		if decision_owner > 0:
			if not submit_choice(game, decision_owner, "pass"):
				check(false, "An optional current-unit decision can be declined")
				finish(game)
				return
			continue
		var revision: int = game.state.revision
		game._apply_end(game.Combat.actor(game.state), revision)
	check(game.state.get("phase", "") == "movement", "Deployment and start-of-battle flow reaches the first Movement phase")
	if failures > 0:
		finish(game)
		return

	# Commit a real legal Normal move before saving, so resume covers a live
	# gameplay action rather than only a deployment snapshot.
	var moving_model := -1
	var moving_squad := -1
	for model: int in game.state.units:
		var unit: Dictionary = game.state.units[model]
		if int(unit.owner) == 1 and str(unit.get("definition_id", "")).get_slice(":", 3) == "intercessor-squad" and unit.wounds > 0:
			moving_model = model
			moving_squad = int(unit.squad)
			break
	check(moving_model >= 0, "The reference list includes a current Intercessor unit")
	if moving_model >= 0:
		var origin: Vector2 = game.state.units[moving_model].position
		game._apply_move(1, moving_model, origin + Vector2(2, 0), game.state.revision)
		check(game.state.units[moving_model].position != origin, "A legal model move is committed before the save checkpoint")
		game._apply_finish_movement(1, game.state.revision, false)
		check(bool(game.state.squads[moving_squad].moved) and game.state.get("pending_move", {}).is_empty(), "The unit completes movement and clears its draft")
	# Resolve one real ranged attack through the authoritative command service
	# before checkpointing. The deployment previews put this bounded profile in
	# range; fail the slice if the legal target cannot be found.
	for _step in range(8):
		if game.state.get("phase", "") == "shooting" and game.Combat.actor(game.state) == 1: break
		var decision_owner := UnitActions.actor(game.state)
		if decision_owner > 0:
			if not submit_choice(game, decision_owner, "pass"):
				check(false, "Optional decisions resolve before the first shooting activation")
				finish(game)
				return
		else:
			var revision: int = game.state.revision
			game._apply_end(game.Combat.actor(game.state), revision)
	check(game.state.get("phase", "") == "shooting" and game.Combat.actor(game.state) == 1, "The first turn reaches P1 Shooting after the committed Normal Move")
	var attack_committed := false
	if game.state.get("phase", "") == "shooting":
		for attacker: int in game.state.units:
			var unit: Dictionary = game.state.units[attacker]
			if int(unit.owner) != 1 or int(unit.wounds) <= 0: continue
			for target in AttackPlan.legal_targets(game.state, attacker, false):
				var entries: Array = AttackPlan.single_target(game.state, int(unit.squad), int(target), false)
				if entries.is_empty(): continue
				var revision: int = game.state.revision
				game._apply_attack_plan(1, attacker, entries, revision, false, false)
				if game.state.revision > revision and bool(game.state.squads[unit.squad].shot):
					attack_committed = true
					break
			if attack_committed: break
		check(attack_committed, "P1 commits a legal ranged attack through the live match command service")
		check(not game.state.get("last_attack", {}).is_empty() and game.state.last_attack.get("pools", []).size() > 0, "The shooting activation records a resolved attack pool")
	if failures > 0:
		finish(game)
		return

	var saved_state: Dictionary = game.state.duplicate(true)
	var saved_rng: int = game.rng.state
	var save_error: String = game._save_snapshot()
	check(save_error.is_empty(), "The bounded match and event journal save to an isolated local slot")
	if not save_error.is_empty():
		push_error("Save detail: " + save_error)
		finish(game)
		return
	game.state = {}
	game._load_match()
	check(game.resume_compatible and game.resume_succeeded, "The normal local compatibility and resume flow accepts the saved match")
	check(game.state == saved_state and game.rng.state == saved_rng, "Resume restores the exact match state and random continuation")
	check(game.journal.checkpoint().count >= 1, "Resume restores the match history checkpoint")
	if failures > 0:
		finish(game)
		return

	# Finish all five rounds through the authoritative match command service.
	for _step in range(160):
		if int(game.state.get("test_winner", 0)) != 0: break
		var battle_owner := UnitActions.battle_actor(game.state)
		if battle_owner > 0:
			if not submit_choice(game, battle_owner, "battle-done"):
				check(false, "Remaining optional battle-start declarations resolve")
				break
			continue
		var decision_owner := UnitActions.actor(game.state)
		if decision_owner > 0:
			if not submit_choice(game, decision_owner, "pass"):
				check(false, "Remaining optional unit decisions resolve or block with a visible failure")
				break
			continue
		var phase_before: String = game.state.get("phase", "")
		var revision: int = game.state.revision
		game._apply_end(game.Combat.actor(game.state), revision)
		if game.state.revision == revision:
			check(false, "The current phase advances without an unresolved blocker (%s)" % phase_before)
			break
	check(game.state.get("test_winner", 0) == 1 and game.state.get("mission", {}).get("scored_rounds", []).size() == 5 and game.state.get("mission", {}).get("scores", {}) == {1: 5, 2: 0}, "The resumed match scores the held Rubble objective 5–0 through all five rounds")
	check(game.state.get("mission", {}).get("id", "") == Objectives.TRAINING and game.state.get("test_battlefield", "") == "saved-army-training-43x43-v1", "Completion retains the original mission and battlefield identity")
	print("LOCAL MATCH VERTICAL SLICE: %d failures; winner=%s; score=%s; rounds=%s" % [failures, str(game.state.get("test_winner", 0)), str(game.state.get("mission", {}).get("scores", {})), str(game.state.get("mission", {}).get("scored_rounds", []))])
	finish(game)

func submit_choice(game: Node, owner: int, action: String) -> bool:
	for choice: Dictionary in UnitActions.choices(game.state, owner):
		if str(choice.get("action", "")) != action: continue
		var revision: int = game.state.revision
		game._apply_unit_action(owner, game._unit_choice_payload(choice), Vector2.ZERO, revision)
		return game.state.revision > revision
	return false

func finish(game: Node) -> void:
	game.queue_free()
	for _frame in range(2): await process_frame
	quit(0 if failures == 0 else 1)
