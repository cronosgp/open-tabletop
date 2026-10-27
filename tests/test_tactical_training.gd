extends SceneTree
const Training = preload("res://scripts/edition_11/training_roster.gd")
const PublicChoice = preload("res://tests/public_unit_command.gd")
const Commands = preload("res://scripts/edition_11/match_command_service.gd")
const Decisions = preload("res://scripts/edition_11/pending_decision_registry.gd")
const Deployment = preload("res://scripts/edition_11/deployment.gd")
const AttackPlan = preload("res://scripts/edition_11/attack_plan.gd")
const Frames = preload("res://scripts/edition_11/resolution_frame.gd")
var failures := 0
var pending_recovery_checked := false

func _initialize() -> void: call_deferred("run")
func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func run() -> void:
	check("leader ability" in Training.Tactical.opportunity_status([{"action": "acumen"}]), "The tactical opportunity cue recognizes a legal leader ability")
	check("CP stratagem" in Training.Tactical.opportunity_status([{"action": "core-stratagem"}]), "The tactical opportunity cue recognizes a legal CP stratagem")
	check("Bladeguard stance" in Training.Tactical.opportunity_status([{"action": "bladeguard"}]), "The tactical opportunity cue recognizes a legal Bladeguard stance")
	var combined_opportunity := Training.Tactical.opportunity_status([{"action": "spiritual-leader"}, {"action": "detachment-stratagem"}])
	check("leader ability" in combined_opportunity and "CP stratagem" in combined_opportunity, "The tactical opportunity cue combines legal leader and CP opportunities")
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	game.match_save_path = "user://matches/tactical-test-%s.save" % Time.get_ticks_usec()
	game.match_journal_directory = "user://matches/journals/tactical-test-%s" % Time.get_ticks_usec()
	game.main_menu.guided_button.pressed.emit()
	check(game.saved_army_mode and game.guided_first_session, "The initial action starts the tactical match")
	check(game.manual_allocation and game.defender_choice.button_pressed and game.state.get("manual_allocation", false), "Guided entry retains defender-owned recipient selection through match materialization")
	check(game.state.get("training_points", {}) == {1: 290, 2: 235}, "Points come from the current asymmetric formations")
	check(game.state.units.size() == 20 and game.state.squads.size() == 6, "All six distinct formations materialize")
	check(game.marine_detachments == {1: "gladius", 2: "gladius"}, "Both seats use Gladius")
	check(game.core_stratagems and game.combat_doctrines and game.unit_abilities, "Abilities, doctrines and Core stratagems are enabled")
	check(not game.awakened_dynasty and not game.reanimation_protocols and not game.oath_of_moment and not game.hail_of_bolts, "Historical options remain disabled")
	check(game.state.board_size == Vector2(43, 43) and game.state.mission.rounds == 5, "The training retains its explicit field and five-round mission")
	check(str(game.state.match_manifest.get("scenario", "")) == Training.Tactical.ID, "The tactical scenario has a distinct versioned manifest identity")
	var before := var_to_str(game.state)
	game._refresh_first_session_guide()
	game._refresh_decision()
	check(var_to_str(game.state) == before and "TACTICAL TIP" in game.first_session_guide.text, "Tips observe state without mutating it")
	check(game.first_session_experiments.visible and "OPTIONAL EXPERIMENTS" in game.first_session_experiments.text and "CURRENT WINDOW: PREPARATION" in game.first_session_experiments.text and "READY NOW" not in game.first_session_experiments.text and "[COMMAND]" in game.first_session_experiments.text and "[SHOOTING]" in game.first_session_experiments.text and "[CHARGE / FIGHT]" in game.first_session_experiments.text and "stratagem" in game.first_session_experiments.text.to_lower() and "supercharged" in game.first_session_experiments.text.to_lower(), "Tactical guidance exposes the current window and phase-labelled optional ability, stratagem, plasma and stance experiments without claiming an unavailable opportunity")
	var initial_experiments := Training.Tactical.experiment_progress(game.state)
	check(not initial_experiments.leader and not initial_experiments.stratagem and not initial_experiments.plasma and not initial_experiments.bladeguard and "PROGRESS: 0 / 4 observed" in game.first_session_experiments.text and "DONE = observed" in game.first_session_experiments.text and "[OPEN] [COMMAND]" in game.first_session_experiments.text, "The tactical checklist starts empty, explains its status labels and marks each optional experiment as open")
	check(not game.tactical_opportunity_label.visible, "The command-panel opportunity cue stays hidden during preparation")
	check("290" in game.main_menu.training_summary.text and "235" in game.main_menu.training_summary.text and "Practice:" in game.main_menu.training_summary.text and "stratagems" in game.main_menu.training_summary.text and "Hazardous" in game.main_menu.training_summary.text and "stances" in game.main_menu.training_summary.text, "The title screen discloses both totals and the four practice opportunities")
	# Exercise both leader associations through projected commands, without editing state.
	for owner: int in [1, 2]:
		var leader := -1
		var target := -1
		var leader_slug := "captain" if owner == 1 else "chaplain"
		var target_slug := "intercessor-squad" if owner == 1 else "assault-intercessor-squad"
		for model: int in game.state.units:
			var unit: Dictionary = game.state.units[model]
			if unit.owner != owner: continue
			if str(unit.definition_id).ends_with(":" + leader_slug): leader = model
			if str(unit.definition_id).ends_with(":" + target_slug): target = int(unit.squad)
		check(leader >= 0 and target >= 0, "Each force contains its intended leader and bodyguard")
		for action: String in ["warlord", "attach", "setup-done"]:
			var selected: Dictionary = {}
			for choice: Dictionary in game.Combat.unit_choices(game.state, owner):
				if str(choice.action) == action and (action == "setup-done" or (int(choice.model) == leader and (action != "attach" or int(choice.target) == target))):
					selected = choice
					break
			check(not selected.is_empty(), "The intended %s declaration is offered to P%d" % [action, owner])
			if selected.is_empty(): break
			var unchanged := var_to_str(game.state)
			check(not PublicChoice.error(game.state, 3 - owner, selected).is_empty() and var_to_str(game.state) == unchanged, "The opponent cannot submit another army's preparation")
			var result := PublicChoice.submit(game.state, owner, selected)
			check(str(result.get("error", "")).is_empty(), "The public command accepts %s: %s" % [action, str(result)])
	# Save the admitted prepared state using the real game persistence path.
	game._reset_history()
	var saved: Dictionary = game.state.duplicate(true)
	var random_state: int = game.rng.state
	check(game._save_snapshot().is_empty(), "The tactical match writes an isolated save")
	game._load_match()
	check(game.resume_succeeded and game.state == saved and game.rng.state == random_state, "Resume preserves exact tactical state and RNG")
	check(game.guided_first_session and Training.Tactical.matches(game.state), "Resuming the tactical formation restores contextual guidance")
	for step in range(8):
		if Deployment.current(game.state) < 0: break
		var owner := Deployment.actor(game.state)
		game._apply_deployment(owner, game.state.revision, false)
		var revision: int = game.state.revision
		game._apply_deployment(owner, revision, true)
		check(game.state.revision > revision, "Each unit confirms its legal deployment preview")
	check(game.state.deployment.complete, "Both distinct forces finish deployment")
	var moved := false
	var fired := false
	var used_gladius := false
	var opportunity_checked := false
	for step in range(400):
		if game.state.test_winner != 0: break
		if resolve_pending(game): continue
		if game.state.phase == "command" and int(game.state.active) == 1 and not used_gladius:
			if not opportunity_checked:
				game._refresh_first_session_guide()
				game._refresh_decision()
				check("READY NOW" in game.first_session_experiments.text, "The tactical guide marks a legal leader or CP opportunity when one is available")
				check(game.tactical_opportunity_label.visible and "READY NOW" in game.tactical_opportunity_label.text, "The command panel repeats the live legal opportunity")
				opportunity_checked = true
			for choice: Dictionary in game.Combat.unit_choices(game.state, 1):
				if str(choice.action) != "detachment-stratagem" or str(choice.value) != "devastator": continue
				var cp_before: int = game.state.cp[1]
				var result := PublicChoice.submit(game.state, 1, choice, Vector2.ZERO, game._d6)
				used_gladius = str(result.get("error", "")).is_empty() and int(game.state.cp[1]) < cp_before
				check(used_gladius, "Adaptive Strategy spends its real CP cost through the public command")
				break
			if used_gladius: continue
		if game.state.phase == "movement" and int(game.state.active) == 1 and not moved:
			for model: int in game.state.units:
				var unit: Dictionary = game.state.units[model]
				if int(unit.owner) != 1 or not str(unit.definition_id).ends_with(":intercessor-squad"): continue
				var origin: Vector2 = unit.position
				game._apply_move(1, model, origin + Vector2(2, 0), game.state.revision)
				game._apply_finish_movement(1, game.state.revision, false)
				moved = unit.position != origin and game.state.pending_move.is_empty()
				break
			check(moved, "A real Normal Move completes through the live command flow")
			continue
		if game.state.phase == "shooting" and int(game.state.active) == 1 and not fired:
			for attacker: int in game.state.units:
				var unit: Dictionary = game.state.units[attacker]
				if int(unit.owner) != 1 or int(unit.wounds) <= 0: continue
				for target: int in AttackPlan.legal_targets(game.state, attacker, false):
					var entries: Array = AttackPlan.single_target(game.state, int(unit.squad), target, false)
					if entries.is_empty(): continue
					var revision: int = game.state.revision
					game._apply_attack_plan(1, attacker, entries, revision, false, false)
					fired = game.state.revision > revision
					if fired: break
				if fired: break
			if fired: continue
		var revision: int = game.state.revision
		game._apply_end(game.Combat.actor(game.state), revision)
		if game.state.revision == revision:
			check(false, "The tactical lifecycle has an unresolved blocker: " + str(game.status.text))
			break
	check(fired and not game.state.get("last_attack", {}).is_empty(), "The tactical lifecycle resolves a real ranged attack")
	check(game.state.test_winner != 0 and game.state.mission.scored_rounds.size() == 5, "The tactical match reaches its five-round result through public commands")
	check(used_gladius and pending_recovery_checked and opportunity_checked, "The lifecycle includes a paid Gladius stratagem, a visible legal opportunity and persisted decision continuation")
	game._refresh_first_session_guide()
	check(Training.Tactical.experiment_progress(game.state).stratagem and "PROGRESS: 1 / 4 observed" in game.first_session_experiments.text and "[DONE] [COMMAND / REACTION]" in game.first_session_experiments.text, "A used stratagem persists as one completed tactical experiment in the guided checklist")
	var post_experiment_progress: Dictionary = game.state.get("training_experiments", {}).duplicate(true)
	var post_experiment_rng: int = game.rng.state
	check(game._save_snapshot().is_empty(), "A post-experiment tactical save writes the checklist state")
	game._load_match()
	game._refresh_first_session_guide()
	check(game.resume_succeeded and game.state.get("training_experiments", {}) == post_experiment_progress and game.rng.state == post_experiment_rng and "PROGRESS: 1 / 4 observed" in game.first_session_experiments.text, "Resume preserves observed experiment progress and its checklist presentation")
	game._set_training_swap(true)
	game._start_guided_first_session()
	check(game.state.get("training_points", {}) == {1: 235, 2: 290}, "Swapping sides reverses forces without changing their composition")
	check(game._picked_army(1).id == Training.Tactical.ASSAULT_ID and game._picked_army(2).id == Training.Tactical.FIRE_ID, "The selected lists agree with swapped ownership")
	print("Tactical training checks: %d failures" % failures)
	game.free()
	await process_frame
	quit(0 if failures == 0 else 1)

func resolve_pending(game: Node) -> bool:
	var decision := Decisions.current(game.state, ["unit-actions", "combat-doctrines", "stratagems", "damage-allocation", "coherency"])
	if decision.is_empty(): return false
	var owner := int(decision.priority_player_id)
	if not pending_recovery_checked and not Frames.current(game.state).is_empty():
		var expected_state: Dictionary = game.state.duplicate(true)
		var expected_frame := Frames.current(game.state).duplicate(true)
		var expected_rng: int = game.rng.state
		check(game._save_snapshot().is_empty(), "A real pending tactical decision can be saved")
		game._load_match()
		var restored := Decisions.current(game.state, [str(decision.source)])
		pending_recovery_checked = restored == decision and Frames.current(game.state) == expected_frame and game.state == expected_state and game.rng.state == expected_rng
		check(pending_recovery_checked, "Recovery preserves exact decision, continuation, state and RNG")
	var option: Dictionary = {}
	for candidate: Dictionary in decision.legal_options:
		var action := str(candidate.action)
		if action in ["pass", "battle-done"] or action.ends_with("-pass") or (str(decision.source) in ["combat-doctrines", "stratagems"] and str(candidate.value).is_empty()) or (str(decision.source) == "combat-doctrines" and str(candidate.value) == "none"):
			option = candidate
			break
	if option.is_empty() and str(decision.source) in ["damage-allocation", "coherency"]: option = decision.legal_options[0]
	if option.is_empty(): return false
	var result: Dictionary
	match str(decision.source):
		"unit-actions":
			game._refresh()
			if decision.get("pass_allowed", false) and game.unit_decline_button.visible:
				for index in range(game.unit_action_picker.item_count):
					check(game.unit_action_picker.get_item_metadata(index) != game.unit_decline_choice, "The dedicated neutral action is not duplicated in the ability picker")
				var cp_before: Dictionary = game.state.cp.duplicate()
				var revision_before: int = game.state.revision
				game.unit_decline_button.pressed.emit()
				check(game.state.cp == cp_before and game.state.revision > revision_before, "The explicit decline button resumes the tactical decision without spending CP")
				return game.state.revision > revision_before
			var selected: Dictionary = {}
			for raw: Dictionary in game.Combat.unit_choices(game.state, owner):
				if str(raw.action) == str(option.action) and int(raw.get("model", -1)) == int(option.model) and int(raw.get("target", -1)) == int(option.target) and str(raw.get("value", "")) == str(option.value):
					selected = raw
					break
			result = PublicChoice.submit(game.state, owner, selected, Vector2.ZERO, game._d6)
		"combat-doctrines": result = Commands.execute(game.state, owner, {"kind": Commands.SELECT_DOCTRINE, "revision": game.state.revision, "doctrine": option.value, "decision_id": decision.decision_id, "option_id": option.id})
		"stratagems":
			game._refresh()
			check(game.reaction_roll.is_visible_in_tree() and not game.reaction_roll.disabled and "0 CP" in game.reaction_roll.text, "The real tactical reaction exposes a visible zero-CP alternative (%s, owner %d, actor %d, visible %s, disabled %s, text %s)" % [str(game.Combat.Stratagems.pending(game.state).get("kind", "")), owner, game._local_player(), str(game.reaction_roll.is_visible_in_tree()), str(game.reaction_roll.disabled), game.reaction_roll.text])
			var cp_before: Dictionary = game.state.cp.duplicate()
			var revision_before: int = game.state.revision
			game.reaction_roll.pressed.emit()
			check(game.state.cp == cp_before and game.state.revision > revision_before, "Keeping the real tactical result through the UI spends no CP and resumes the pending action (revision %d → %d, CP %s → %s, feedback %s)" % [revision_before, game.state.revision, str(cp_before), str(game.state.cp), game.status.text])
			return game.state.revision > revision_before
		"damage-allocation": result = Commands.execute(game.state, owner, {"kind": Commands.ALLOCATE_DAMAGE, "revision": game.state.revision, "model": option.model, "decision_id": decision.decision_id, "option_id": option.id}, game._d6)
		"coherency": result = Commands.execute(game.state, owner, {"kind": Commands.REMOVE_COHERENCY, "revision": game.state.revision, "model": option.model, "decision_id": decision.decision_id, "option_id": option.id})
	check(str(result.get("error", "")).is_empty(), "The pending tactical choice resolves: " + str(result))
	return str(result.get("error", "")).is_empty()
