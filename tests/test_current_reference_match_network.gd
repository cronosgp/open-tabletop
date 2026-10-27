extends SceneTree

const Deployment = preload("res://scripts/edition_11/deployment.gd")
const UnitActions = preload("res://scripts/edition_11/unit_actions.gd")
const MatchSave = preload("res://scripts/match_save.gd")
const AttackPlan = preload("res://scripts/edition_11/attack_plan.gd")
const LIST_ID := "reference:core-v2:Space Marines"
const TacticalActions = preload("res://tests/tactical_network_actions.gd")
const CheckpointBarrier = preload("res://tests/network_checkpoint_barrier.gd")

var game: Node
var save_path := ""
var journal_directory := ""
var is_host := false
var cross_machine_test := false
var pending_overwatch_recovery_done := false
var tactical_profile := "--tactical-profile-test" in OS.get_cmdline_user_args()
var tactical_actions: RefCounted
var checkpoint_barrier: Node
var guest_placement_feedback_checked := false

func check_tactical_progress_tracker(label: String) -> bool:
	if not tactical_profile: return true
	var expected := {"standard_plasma": false, "supercharged_plasma": false, "hazardous": false}
	var observed: Variant = game.state.get("training_experiments", {})
	if observed != expected:
		push_error("Tactical network checkpoint %s lost or changed the initial experiment tracker: %s" % [label, str(observed)])
		return false
	return true

func requested_host_address() -> String:
	for argument in OS.get_cmdline_user_args():
		if str(argument).begins_with("--host-address="):
			var address := str(argument).trim_prefix("--host-address=").strip_edges()
			if not address.is_empty(): return address
	return "127.0.0.1"

func _initialize() -> void:
	call_deferred("run")

func wait_for(predicate: Callable, label: String, seconds: float = 150.0) -> bool:
	var deadline := Time.get_ticks_msec() + int(seconds * 1000.0)
	var last_status := ""
	var trace_recovery := label.contains("recover") or label.contains("reclaims") or label.contains("rejoin") or label.contains("disconnect")
	while Time.get_ticks_msec() < deadline:
		if predicate.call():
			if trace_recovery: print("NETWORK CHECKPOINT READY: role=%s t=%d label=%s revision=%d" % ["host" if is_host else "client", Time.get_ticks_msec(), label, int(game.state.get("revision", -1))])
			return true
		if trace_recovery:
			var observed_status := "%s|%s|%s|%d|%d" % [str(game.mode), game.status.text, str(game.state.get("phase", "")), int(game.guest_id), game.pending_seats.size()]
			if observed_status != last_status:
				last_status = observed_status
				print("NETWORK WAIT: %s role=%s t=%d mode=%s phase=%s guest=%d pending=%d status=%s" % [label, "host" if is_host else "client", Time.get_ticks_msec(), game.mode, str(game.state.get("phase", "")), game.guest_id, game.pending_seats.size(), game.status.text])
		await create_timer(0.05).timeout
	var pending_summary := str({
		"actor": game.Combat.actor(game.state),
		"active": game.state.get("active", -1),
		"unit_actor": game.Combat.UnitActions.actor(game.state),
		"pending_move": not game.state.get("pending_move", {}).is_empty(),
		"pending_decision": game.Combat.UnitActions.pending_decision(game.state).get("source", ""),
		"frames": game.state.get("resolution_frames", []).size(),
		"guest": game.guest_id,
	})
	push_error("Current-reference host/client timeout (%s): role=%s phase=%s revision=%s ready=%s network=%s status=%s details=%s" % [label, "host" if is_host else "client", str(game.state.get("phase", "")), str(game.state.get("revision", -1)), str(game.state.get("ready_armies", [])), str(game.network_army_status.text), game.status.text, pending_summary])
	return false

func watch_guest_disconnect() -> Dictionary:
	# Reconnection may happen between timer polls. Observe the actual edge rather
	# than requiring a transient guest_id == 0 to remain visible for 50 ms.
	var observed := {"disconnected": game.guest_id == 0}
	if not observed.disconnected:
		game.multiplayer.peer_disconnected.connect(func(_peer: int): observed.disconnected = true, CONNECT_ONE_SHOT)
	return observed

func setup_game() -> void:
	var run_id := str(Time.get_ticks_usec())
	save_path = "user://matches/qa-current-reference-loopback-%s.save" % run_id
	journal_directory = "user://matches/journals/qa-current-reference-loopback-%s" % run_id
	game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	checkpoint_barrier = CheckpointBarrier.new()
	checkpoint_barrier.name = "NetworkCheckpointBarrier"
	checkpoint_barrier.game = game
	root.add_child(checkpoint_barrier)
	game.session_transport.peer_connected.connect(func(peer: int): trace_transport("peer_connected", peer))
	game.session_transport.peer_disconnected.connect(func(peer: int): trace_transport("peer_disconnected", peer))
	game.session_transport.connected_to_server.connect(func(): trace_transport("connected_to_server"))
	game.session_transport.server_disconnected.connect(func(): trace_transport("server_disconnected"))
	game.session_transport.connection_failed.connect(func(): trace_transport("connection_failed"))
	game.match_save_path = save_path
	game.match_journal_directory = journal_directory
	game.address.text = requested_host_address()
	game.auto_models.button_pressed = false
	game.saved_training_consent.button_pressed = true
	game.unit_abilities_choice.set_pressed_no_signal(true)
	for option in [game.defender_choice, game.equipment_choice, game.combat_doctrines_choice, game.awakened_dynasty_choice, game.reroll_choice, game.attack_reroll_choice, game.save_reroll_choice, game.damage_reroll_choice, game.hazard_reroll_choice, game.escape_reroll_choice, game.count_reroll_choice, game.objective_secured_choice, game.implacable_eradication_choice, game.hail_of_bolts_choice, game.oath_of_moment_choice, game.official_mission_choice, game.checked_rosters_choice]:
		option.set_pressed_no_signal(false)
	game.stratagem_choice.set_pressed_no_signal(true)
	if tactical_profile:
		game.marine_detachment_choice.select(0)
		game.marine_detachment_choice_p2.select(0)
		for option in [game.combat_doctrines_choice, game.reroll_choice, game.attack_reroll_choice, game.save_reroll_choice, game.damage_reroll_choice, game.hazard_reroll_choice, game.escape_reroll_choice, game.count_reroll_choice]: option.set_pressed_no_signal(true)
	game._start_saved_match(false)
	if tactical_profile: tactical_actions = TacticalActions.new(self)

func trace_transport(event: String, peer: int = 0) -> void:
	# Record lifecycle facts only; never print seat proofs, nonces or credentials.
	print("NETWORK TRANSPORT: role=%s t=%d event=%s peer=%d mode=%s guest=%d pending=%d status=%s" % ["host" if is_host else "client", Time.get_ticks_msec(), event, peer, game.mode, game.guest_id, game.pending_seats.size(), game.status.text])

func select_reference_list(owner: int) -> bool:
	if tactical_profile: return tactical_actions.select_reference_list(owner)
	var picker: OptionButton = game.saved_army_pickers[owner]
	for index in range(picker.item_count):
		var item: Variant = picker.get_item_metadata(index)
		if item is Dictionary and str(item.get("id", "")) == LIST_ID:
			game._network_army_selected(index)
			return true
	return false

func submit_setup(owner: int) -> bool:
	if tactical_profile: return await tactical_actions.submit_setup(owner)
	if game.mode == "client":
		game._request_setup_finish()
		return true
	for choice: Dictionary in UnitActions.choices(game.state, owner):
		if str(choice.get("action", "")) != "setup-done": continue
		var revision: int = game.state.revision
		var payload: Dictionary = game._unit_choice_payload(choice)
		game._apply_unit_action(owner, payload, Vector2.ZERO, revision)
		return game.state.revision > revision
	return false

func deploy_one_unit(owner: int) -> bool:
	if Deployment.actor(game.state) != owner: return false
	var squad: int = Deployment.current(game.state)
	if not tactical_profile and owner == 1 and squad == 5:
		# P1 places its first Terminator squad in the nearby Rubble objective.
		# Each model still goes through the authoritative deployment command.
		for model: int in game.Combat.living(game.state, squad):
			var place_revision: int = game.state.revision
			var destination: Vector2 = game.state.units[model].position + Vector2(0.7, 0)
			if game.mode == "client": game.request_move.rpc_id(1, model, destination, place_revision)
			else: game._apply_move(owner, model, destination, place_revision)
			if game.mode == "client":
				if not await wait_for(func(): return game.state.revision > place_revision, "P1 objective deployment placement"): return false
			elif game.state.revision <= place_revision or game.state.units[model].position != destination:
				push_error("P1 Terminator deployment into Rubble was rejected for model %d." % model)
				return false
	else:
		var preview_revision: int = game.state.revision
		game._request_deployment_preset()
		if game.mode == "client":
			if not await wait_for(func(): return game.state.revision > preview_revision, "deployment preview from host"): return false
		elif game.state.revision <= preview_revision:
			push_error("Deployment preview rejected for P%d: phase=%s actor=%d setup=%d status=%s" % [owner, str(game.state.phase), Deployment.actor(game.state), UnitActions.setup_actor(game.state), game.status.text])
			return false
		if game.mode == "client" and not guest_placement_feedback_checked:
			if not await check_guest_placement_feedback(squad): return false
	var revision: int = game.state.revision
	var committed_before: int = game.state.deployment.committed.size()
	game._request_end()
	if game.mode == "client":
		if not await wait_for(func(): return game.state.deployment.committed.size() > committed_before, "deployment confirmation from host"): return false
	elif game.state.revision <= revision:
		push_error("Deployment confirmation rejected for P%d: actor=%d status=%s" % [owner, Deployment.actor(game.state), game.status.text])
		return false
	return true

func check_guest_placement_feedback(squad: int) -> bool:
	var models: Array[int] = game.Combat.living(game.state, squad)
	if models.is_empty(): return false
	var model := models[0]
	var destination := Vector2(1000, 1000)
	var expected := Deployment.position_error(game.state, model, destination)
	if expected.is_empty():
		push_error("The guest rejection fixture must request an invalid destination.")
		return false
	game._dismiss_home(1)
	game._clear_placement_feedback()
	var before: Dictionary = game.state.duplicate(true)
	var rng_before: int = game.rng.state
	game.request_move.rpc_id(1, model, destination, int(game.state.revision))
	if not await wait_for(func(): return game.placement_feedback.message == expected, "guest receives authoritative placement reason"): return false
	if game.state != before or game.rng.state != rng_before:
		push_error("Rejected guest placement changed synchronized state or local RNG.")
		return false
	if not game.placement_feedback.is_visible_in_tree() or game.placement_feedback.model != model or game.placement_feedback.destination != destination or not game.placement_feedback.pinned or not game.placement_reason.visible or expected not in game.placement_reason.text:
		push_error("Guest placement rejection did not expose the same reason at the model and command card.")
		return false
	var revision: int = game.state.revision
	var legal_destination: Vector2 = game.state.units[model].position
	game.request_move.rpc_id(1, model, legal_destination, revision)
	if not await wait_for(func(): return game.state.revision > revision and game.placement_feedback.message.is_empty(), "guest corrects rejected placement"): return false
	if game.state.units[model].position != legal_destination or game.placement_reason.visible:
		push_error("Accepted guest placement left stale rejection feedback.")
		return false
	guest_placement_feedback_checked = true
	print("GUEST PLACEMENT FEEDBACK: PASS; model=%d; rejection preserved state; correction cleared both UI reasons" % model)
	return true

func submit_unit_choice(owner: int, action: String) -> bool:
	for choice: Dictionary in UnitActions.choices(game.state, owner):
		if str(choice.get("action", "")) != action and not (tactical_profile and action == "pass" and str(choice.get("action", "")).ends_with("-pass")): continue
		var revision: int = game.state.revision
		var payload: Dictionary = game._unit_choice_payload(choice)
		if game.mode == "client": game.request_unit_action.rpc_id(1, payload, Vector2.ZERO, revision)
		else: game._apply_unit_action(owner, payload, Vector2.ZERO, revision)
		return await wait_for(func(): return game.state.revision > revision, "%s choice from P%d" % [action, owner])
	return false

func complete_deployment(owner: int) -> bool:
	for step in range(16):
		if Deployment.current(game.state) < 0: return true
		var revision: int = game.state.revision
		var actor: int = Deployment.actor(game.state)
		if actor == owner:
			if not await deploy_one_unit(owner): return false
		else:
			if not await wait_for(func(): return game.state.revision > revision, "opponent deployment command"):
				return false
	return Deployment.current(game.state) < 0

func advance_one_player_step(owner: int) -> bool:
	if game.mode == "client": await create_timer(0.1).timeout
	var reaction_decision: Dictionary = game.Combat.UnitActions.pending_decision(game.state)
	var overwatch_open: bool = reaction_decision.get("legal_options", []).any(func(option: Dictionary) -> bool: return option.get("action", "") == "core-stratagem" and option.get("value", "") == "fire-overwatch")
	if overwatch_open:
		var revision_before_recovery: int = game.state.revision
		var state_before_recovery: Dictionary = game.state.duplicate(true)
		var decision_id_before_recovery := str(reaction_decision.get("decision_id", ""))
		if not pending_overwatch_recovery_done:
			if is_host:
				checkpoint_barrier.expect("pending-overwatch", state_before_recovery)
				var disconnected := watch_guest_disconnect()
				var save_error: String = game._save_snapshot()
				if not save_error.is_empty():
					push_error("Host failed to save the pending Fire Overwatch checkpoint: " + save_error)
					return false
				var checkpoint := MatchSave.read(save_path)
				if checkpoint.has("error") or checkpoint.state != state_before_recovery or checkpoint.rng_state != game.rng.state or checkpoint.journal != game.journal.checkpoint():
					push_error("Pending Fire Overwatch save does not preserve match state, RNG and journal.")
					return false
				if not await wait_for(func(): return disconnected.disconnected, "guest disconnect during pending Fire Overwatch"):
					return false
				if not await wait_for(func(): return game.guest_id != 0, "guest reclaims seat during pending Fire Overwatch"):
					return false
				if not await wait_for(func(): return checkpoint_barrier.arrived, "guest verifies recovered Fire Overwatch snapshot"):
					return false
			else:
				game._offline("Testing recovery during the opponent's pending Fire Overwatch decision")
				if not await wait_for(func(): return game.mode == "local", "pending Fire Overwatch guest disconnect"):
					return false
				game.address.text = requested_host_address()
				game._join()
				# Require the actual authenticated snapshot, not transient UI feedback.
				if not await wait_for(func(): return game.mode == "client" and game.state == state_before_recovery, "pending Fire Overwatch seat recovery"):
					return false
				if not select_reference_list(2):
					push_error("Guest cannot resubmit its locked list after pending Fire Overwatch recovery.")
					return false
				game._submit_saved_army()
				if not await wait_for(func(): return game.state.get("revision", -1) == state_before_recovery.get("revision", -2), "pending Fire Overwatch snapshot recovery"):
					return false
				if game.state != state_before_recovery:
					push_error("Guest did not receive the exact serialized Fire Overwatch state.")
					return false
			var restored_decision: Dictionary = game.Combat.UnitActions.pending_decision(game.state)
			if str(restored_decision.get("decision_id", "")) != decision_id_before_recovery or restored_decision.get("legal_options", []) != reaction_decision.get("legal_options", []) or int(restored_decision.get("priority_player_id", -1)) != int(reaction_decision.get("priority_player_id", -2)) or str(restored_decision.get("resume_frame_id", "")) != str(reaction_decision.get("resume_frame_id", "")):
				push_error("Fire Overwatch decision identity, choices, owner or suspended phase-close frame changed after recovery.")
				return false
			if is_host:
				checkpoint_barrier.release_guest()
			else:
				checkpoint_barrier.arrive("pending-overwatch", game.state)
				if not await wait_for(func(): return checkpoint_barrier.released == "pending-overwatch", "host verifies recovered Fire Overwatch snapshot"): return false
			pending_overwatch_recovery_done = true
		var decision_owner := int(reaction_decision.get("priority_player_id", -1))
		if decision_owner == owner:
			if not await submit_unit_choice(owner, "pass"): return false
			return true
		return await wait_for(func(): return game.state.revision > revision_before_recovery, "opponent resolves recovered Fire Overwatch")

	var decision_owner: int = UnitActions.battle_actor(game.state)
	var action := "battle-done"
	if decision_owner <= 0:
		decision_owner = UnitActions.actor(game.state)
		action = "pass"
	if decision_owner <= 0:
		var doctrine: Dictionary = game.Combat.Doctrines.pending_decision(game.state)
		if not doctrine.is_empty():
			var doctrine_owner := int(doctrine.priority_player_id)
			var doctrine_revision: int = game.state.revision
			if doctrine_owner == owner:
				var option: Dictionary = doctrine.legal_options[0]
				if game.mode == "client": game.request_combat_doctrine.rpc_id(1, str(option.value), str(doctrine.decision_id), str(option.id), doctrine_revision)
				else: game._apply_combat_doctrine(owner, str(option.value), str(doctrine.decision_id), str(option.id), doctrine_revision)
			return await wait_for(func(): return game.state.revision > doctrine_revision, "doctrine choice")
		var reaction: Dictionary = game.Combat.Stratagems.pending_decision(game.state)
		if not reaction.is_empty():
			var reaction_revision: int = game.state.revision
			if int(reaction.priority_player_id) == owner:
				for option: Dictionary in reaction.legal_options:
					if not str(option.value).is_empty(): continue
					var payload: Dictionary = game._stratagem_choice_payload(int(option.target), "", int(option.get("details", {}).get("die", -1)))
					if game.mode == "client": game.request_command_reaction.rpc_id(1, payload, reaction_revision)
					else: game._apply_command_reaction(owner, payload, reaction_revision)
					break
			return await wait_for(func(): return game.state.revision > reaction_revision, "attack-roll reaction")
		decision_owner = game.Combat.actor(game.state)
		action = "end"
	if decision_owner <= 0: return false
	var revision: int = game.state.revision
	if decision_owner == owner:
		if action == "end":
			game._request_end()
		elif not await submit_unit_choice(owner, action): return false
		if action == "end":
			var end_result := await wait_for(func(): return game.state.revision > revision, "phase close from P%d" % owner)
			return end_result
		return true
	return await wait_for(func(): return game.state.revision > revision, "opponent phase/decision command")

func advance_to_movement(owner: int) -> bool:
	for step in range(48):
		if str(game.state.get("phase", "")) == "movement": return true
		if not await advance_one_player_step(owner): return false
	return str(game.state.get("phase", "")) == "movement"

func advance_to_shooting(owner: int) -> bool:
	for step in range(48):
		if str(game.state.get("phase", "")) == "shooting" and game.Combat.actor(game.state) == 1: return true
		# The host commits the P1 ranged attack immediately after entering Shooting.
		# A client can receive the Shooting snapshot and the resolved attack in the
		# same frame, so the later authoritative attack is an equivalent checkpoint.
		if not is_host and not game.state.get("last_attack", {}).get("pools", []).is_empty(): return true
		if not await advance_one_player_step(owner): return false
	return str(game.state.get("phase", "")) == "shooting" and game.Combat.actor(game.state) == 1

func commit_host_ranged_attack() -> bool:
	if tactical_profile: return tactical_actions.commit_host_ranged_attack()
	for attacker: int in game.state.units:
		var unit: Dictionary = game.state.units[attacker]
		if int(unit.owner) != 1 or int(unit.wounds) <= 0: continue
		for target in AttackPlan.legal_targets(game.state, attacker, false):
			var entries: Array = AttackPlan.single_target(game.state, int(unit.squad), int(target), false)
			if entries.is_empty(): continue
			var revision: int = game.state.revision
			game._apply_attack_plan(1, attacker, entries, revision, false, false)
			if game.state.revision > revision and bool(game.state.squads[unit.squad].shot):
				return not game.state.get("last_attack", {}).get("pools", []).is_empty()
	return false

func complete_match(owner: int) -> bool:
	for step in range(180):
		if int(game.state.get("test_winner", 0)) != 0: return true
		if not await advance_one_player_step(owner): return false
	return int(game.state.get("test_winner", 0)) != 0

func run() -> void:
	is_host = "--host-test" in OS.get_cmdline_user_args()
	print("NETWORK LIFECYCLE START: role=%s tactical=%s instance=%d args=%s" % ["host" if is_host else "client", tactical_profile, get_instance_id(), str(OS.get_cmdline_user_args())])
	cross_machine_test = "--cross-machine-test" in OS.get_cmdline_user_args()
	setup_game()
	if is_host:
		game._host()
		if not await wait_for(func(): return game.guest_id != 0, "authenticated player 2", 600.0):
			finish(1)
			return
		if not select_reference_list(1):
			push_error("Host cannot select the current Space Marines reference list.")
			finish(1)
			return
		game._submit_saved_army()
	else:
		game._join()
		if not await wait_for(func(): return game.mode == "client" and game.status.text == "State synchronized with host.", "authenticated seat sync"):
			finish(1)
			return
		if not select_reference_list(2):
			push_error("Guest cannot select the current Space Marines reference list.")
			finish(1)
			return
		game._submit_saved_army()

	if not await wait_for(func(): return game.state.get("phase", "") == "deployment", "both current lists admitted"):
		finish(1)
		return
	var expected_points := {1: 290, 2: 235} if tactical_profile else {1: 550, 2: 550}
	if game.state.get("training_points", {}) != expected_points or game.state.get("units", {}).size() != (20 if tactical_profile else 40) or game.state.get("mission", {}).get("id", "") != "objective-training-v1":
		push_error("Host/client roster or mission does not match the bounded local slice.")
		finish(1)
		return
	if not check_tactical_progress_tracker("admission"):
		finish(1)
		return

	if is_host:
		if not await submit_setup(1):
			push_error("Host cannot finish current-ability setup.")
			finish(1)
			return
		if not await wait_for(func(): return UnitActions.setup_actor(game.state) == 2, "guest setup turn"):
			finish(1)
			return
	else:
		if not await wait_for(func(): return UnitActions.setup_actor(game.state) == 2, "guest setup turn"):
			finish(1)
			return
		if not await submit_setup(2):
			push_error("Guest cannot finish current-ability setup.")
			finish(1)
			return
	if not await wait_for(func(): return UnitActions.setup_actor(game.state) <= 0, "both players finish current-ability setup"):
		finish(1)
		return
	print("NETWORK SETUP COMPLETE: role=%s revision=%d" % ["host" if is_host else "client", game.state.revision])

	var our_seat := 1 if is_host else 2
	if not await wait_for(func(): return game.state.get("phase", "") == "deployment" and Deployment.actor(game.state) == our_seat, "first deployment seat"):
		finish(1)
		return
	if not await deploy_one_unit(our_seat):
		push_error("Player %d cannot deploy through the live match command flow." % our_seat)
		finish(1)
		return
	if not await wait_for(func(): return game.state.get("deployment", {}).get("committed", []).size() >= 2, "both seats deployed"):
		finish(1)
		return
	print("NETWORK RECOVERY CHECKPOINT: role=%s revision=%d guest=%d" % ["host" if is_host else "client", game.state.revision, game.guest_id])

	if our_seat == 2:
		print("NETWORK GUEST RECOVERY: disconnecting")
		var saved_roster: Dictionary = game.state.duplicate(true)
		game._offline("Testing authenticated recovery of the current-reference host/guest match")
		if not await wait_for(func(): return game.mode == "local", "guest disconnect"):
			finish(1)
			return
		game.address.text = requested_host_address()
		game._join()
		print("NETWORK GUEST RECOVERY: join requested")
		# Deliberately exceed the former one-second host delay. Snapshot recovery
		# and verification are acknowledged; elapsed time is not a protocol.
		await create_timer(2.0).timeout
		if not await wait_for(func(): return game.mode == "client" and game.state == saved_roster, "rejoined seat sync"):
			finish(1)
			return
		if not select_reference_list(2):
			push_error("Guest cannot resubmit its locked list after reconnecting.")
			finish(1)
			return
		game._submit_saved_army()
		if not await wait_for(func(): return game.state.get("revision", -1) == saved_roster.get("revision", -2), "restored deployment snapshot"):
			finish(1)
			return
		if game.state != saved_roster:
			push_error("Rejoined guest did not receive the exact current-reference match state.")
			finish(1)
			return
		if not check_tactical_progress_tracker("guest-rejoin"):
			finish(1)
			return
		game.request_history_page.rpc_id(1, 0)
		if not await wait_for(func(): return game.history_panel.total > 0, "host battle history after reconnect"):
			finish(1)
			return
		checkpoint_barrier.arrive("deployment", game.state)
		if not await wait_for(func(): return checkpoint_barrier.released == "deployment", "host acknowledges deployment recovery"):
			finish(1)
			return
		if not await wait_for(func(): return game.state.get("deployment", {}).get("committed", []).size() >= 3, "host resumes deployment after guest reconnect"):
			finish(1)
			return
		if not await wait_for(func(): return Deployment.actor(game.state) == 2, "guest deployment turn after recovery"):
			finish(1)
			return
		if not await deploy_one_unit(2):
			push_error("Reconnected guest cannot deploy through the live match command flow.")
			finish(1)
			return
		if not await wait_for(func(): return game.state.get("deployment", {}).get("committed", []).size() >= 4, "guest command accepted after recovery"):
			finish(1)
			return
		if not await complete_deployment(2):
			push_error("Reconnected guest could not finish alternating deployment.")
			finish(1)
			return
	else:
		var disconnected := watch_guest_disconnect()
		checkpoint_barrier.expect("deployment", game.state)
		print("NETWORK HOST RECOVERY: watching disconnect; already=%s" % disconnected.disconnected)
		var save_error: String = game._save_snapshot()
		if not save_error.is_empty():
			push_error("Host failed to save the current-reference match checkpoint: " + save_error)
			finish(1)
			return
		var saved := MatchSave.read(save_path)
		if saved.has("error") or saved.state != game.state or saved.rng_state != game.rng.state or saved.journal != game.journal.checkpoint():
			push_error("Host save does not preserve the deployed reference match, RNG state and journal.")
			finish(1)
			return
		if not check_tactical_progress_tracker("host-save"):
			finish(1)
			return
		if not await wait_for(func(): return disconnected.disconnected, "guest disconnect after saved checkpoint"):
			finish(1)
			return
		if not await wait_for(func(): return game.guest_id != 0, "guest reclaims its authenticated seat"):
			finish(1)
			return
		if not await wait_for(func(): return checkpoint_barrier.arrived, "guest verifies deployment recovery and history"):
			finish(1)
			return
		checkpoint_barrier.release_guest()
		if not await deploy_one_unit(1):
			push_error("Host cannot resume deployment after guest recovery.")
			finish(1)
			return
		if not await wait_for(func(): return game.state.get("deployment", {}).get("committed", []).size() >= 4, "guest command accepted after recovery"):
			finish(1)
			return
		if not await complete_deployment(1):
			push_error("Host could not finish alternating deployment after recovery.")
			finish(1)
			return

	if not await advance_to_movement(our_seat):
		push_error("The recovered network match did not reach its first Movement phase.")
		finish(1)
		return
	if is_host:
		var moving_model := -1
		for model: int in game.state.units:
			var unit: Dictionary = game.state.units[model]
			if int(unit.owner) == 1 and str(unit.get("definition_id", "")).get_slice(":", 3) == "intercessor-squad" and int(unit.wounds) > 0:
				moving_model = model
				break
		if moving_model < 0:
			push_error("The host cannot find the P1 Intercessor for the network movement action.")
			finish(1)
			return
		var origin: Vector2 = game.state.units[moving_model].position
		var revision: int = game.state.revision
		game._apply_move(1, moving_model, origin + Vector2(2, 0), revision)
		if game.state.revision <= revision or game.state.units[moving_model].position == origin:
			push_error("The live network match rejected the bounded legal Normal Move.")
			finish(1)
			return
		revision = game.state.revision
		game._apply_finish_movement(1, revision, false)
		if game.state.revision <= revision:
			push_error("The live network match did not complete the Intercessor movement activation.")
			finish(1)
			return
	if not await advance_to_shooting(our_seat):
		push_error("The recovered network match did not reach P1 Shooting.")
		finish(1)
		return
	var attack_revision: int = game.state.revision
	if is_host:
		if not await commit_host_ranged_attack():
			push_error("The host could not commit a legal ranged attack through the live match command flow.")
			finish(1)
			return
		if game.state.revision <= attack_revision:
			push_error("The host's ranged attack did not advance the authoritative match revision.")
			finish(1)
			return
	else:
		if not tactical_profile and game.state.get("last_attack", {}).get("pools", []).is_empty():
			if not await wait_for(func(): return game.state.revision > attack_revision and not game.state.get("last_attack", {}).get("pools", []).is_empty(), "host ranged attack synchronization"):
				finish(1)
				return
	if tactical_profile:
		for step in range(80):
			if not game.state.get("last_attack", {}).get("pools", []).is_empty(): break
			if not await advance_one_player_step(our_seat):
				finish(1)
				return
	if game.state.get("last_attack", {}).get("pools", []).is_empty():
		push_error("The synchronized network state is missing its resolved ranged attack.")
		finish(1)
		return
	if not await complete_match(our_seat):
		push_error("The saved network match did not reach its five-round result.")
		finish(1)
		return
	if not pending_overwatch_recovery_done:
		push_error("The bounded network profile never exercised recovery during a pending Fire Overwatch decision.")
		finish(1)
		return
	if game.state.get("mission", {}).get("scored_rounds", []).size() != 5 or (not tactical_profile and (int(game.state.get("test_winner", 0)) != 1 or game.state.get("mission", {}).get("scores", {}) != {1: 5, 2: 0})):
		push_error("The network match did not score P1's held Rubble objective 5–0 through all five rounds.")
		finish(1)
		return
	if not check_tactical_progress_tracker("completed-match"):
		finish(1)
		return
	if is_host:
		var final_save_error: String = game._save_snapshot()
		if not final_save_error.is_empty():
			push_error("Host failed to save the completed host/client match: " + final_save_error)
			finish(1)
			return
		var final_saved := MatchSave.read(save_path)
		if final_saved.has("error") or final_saved.state != game.state or final_saved.rng_state != game.rng.state or final_saved.journal != game.journal.checkpoint():
			push_error("Host completion save does not preserve the final match, RNG state and journal.")
			finish(1)
			return
		checkpoint_barrier.expect("completed-match", game.state)
		if not await wait_for(func(): return checkpoint_barrier.arrived, "guest completed final-state assertions", 120.0):
			finish(1)
			return
		var completed_guest_disconnect := watch_guest_disconnect()
		checkpoint_barrier.release_guest()
		if not await wait_for(func(): return completed_guest_disconnect.disconnected, "guest receives completion confirmation and closes", 120.0):
			finish(1)
			return
	else:
		checkpoint_barrier.arrive("completed-match", game.state)
		if not await wait_for(func(): return checkpoint_barrier.released == "completed-match", "host confirms exact completed state", 120.0):
			finish(1)
			return

	if not is_host and not guest_placement_feedback_checked:
		push_error("The guest placement rejection/recovery UI path was not exercised.")
		finish(1)
		return
	print("%s %s: PASS; revision=%d; committed=%d; points=%s; score=%s; winner=%d" % ["TACTICAL" if tactical_profile else "CURRENT-REFERENCE", "HOST" if is_host else "CLIENT", game.state.revision, game.state.deployment.committed.size(), str(game.state.training_points), str(game.state.mission.scores), int(game.state.test_winner)])
	print("FINAL STATE SHA-256 (canonical): " + CheckpointBarrier.digest(game.state))
	finish(0)

func finish(code: int) -> void:
	if checkpoint_barrier != null and is_instance_valid(checkpoint_barrier):
		checkpoint_barrier.game = null
		checkpoint_barrier.set_process(false)
	if game != null and is_instance_valid(game):
		game.multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()
		game.queue_free()
		await game.tree_exited
		await process_frame
	quit(code)
