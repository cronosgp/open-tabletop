extends SceneTree
const F = preload("res://tests/all_units_fixture.gd")
const Army = preload("res://scripts/edition_11/army_capabilities.gd")
const Abilities = preload("res://scripts/edition_11/unit_abilities.gd")
const UnitActions = preload("res://scripts/edition_11/unit_actions.gd")
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Transport = preload("res://scripts/edition_11/transport_rules.gd")
const ResolutionFrames = preload("res://scripts/edition_11/resolution_frame.gd")
const PendingDecisions = preload("res://scripts/edition_11/pending_decision_registry.gd")
const MatchCommands = preload("res://scripts/edition_11/match_command_service.gd")
const PhaseCloseGate = preload("res://scripts/edition_11/phase_close_gate.gd")
var failures := 0

func fresh_current() -> Dictionary:
	return F.P.initial_state({"unit_abilities": true, "reanimation_protocols": true, "combat_doctrines": true, "awakened_dynasty": true, "core_stratagems": true, "attack_rerolls": true, "manual_allocation": false}, F.current_marine_selections())

func current_drop_pod_selections() -> Dictionary:
	var selections := F.current_marine_selections()
	for owner in [1, 2]:
		selections[owner].entries.append({"definition_id": "40kdc:11e:adeptus-astartes:drop-pod", "models": 1, "copies": 1})
	return selections

func current_drop_pod_model(state: Dictionary, owner: int) -> int:
	for model: int in state.units:
		if int(state.units[model].get("owner", -1)) == owner and Abilities.identity(state.units[model]) == "drop-pod": return model
	return -1

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func submit_transport_choice(state: Dictionary, player: int, action: String, model: int, target: int, point: Vector2 = Vector2.ZERO) -> Dictionary:
	var decision := PendingDecisions.current(state, ["unit-actions"])
	var choice: Dictionary = {}
	for option: Dictionary in UnitActions.choices(state, player):
		if str(option.get("action", "")) == action and int(option.get("model", -1)) == model and int(option.get("target", -1)) == target:
			choice = option
			break
	if choice.is_empty(): return {"error": "Transport rules no longer offer the projected Drop Pod choice."}
	if decision.is_empty():
		return MatchCommands.execute(state, player, {"kind": MatchCommands.SELECT_UNIT_CHOICE, "revision": int(state.get("revision", -1)), "point": point, "choice": choice}, func() -> int: return 6)
	var projected: Dictionary = {}
	for option: Dictionary in decision.get("legal_options", []):
		if str(option.get("action", "")) == action and int(option.get("model", -1)) == model and int(option.get("target", -1)) == target:
			projected = option
			break
	if projected.is_empty(): return {"error": "The current Drop Pod decision does not offer %s for model %d/target %d." % [action, model, target]}
	return MatchCommands.execute(state, player, {"kind": MatchCommands.SELECT_UNIT_CHOICE, "revision": int(state.get("revision", -1)), "point": point, "choice": {"_decision_type": MatchCommands.UNIT_CHOICE_ENVELOPE, "decision_id": str(decision.get("decision_id", "")), "option_id": str(projected.get("id", "")), "choice": choice}}, func() -> int: return 6)

func run() -> void:
	var profile := Profiles.profile("drop-pod")
	var expected_keywords := ["ADEPTUS ASTARTES", "DEDICATED TRANSPORT", "FRAME", "IMPERIUM", "TRANSPORT", "VEHICLE"]
	var actual_keywords: Array = profile.get("keywords", []).duplicate()
	actual_keywords.sort()
	check(profile.get("source_book_id", "") == "000000139" and profile.get("source_datasheet_id", "") == "000000087" and profile.get("source_snapshot_id", "") == "20261021T130623Z", "Drop Pod maps to the pinned shared-book Wahapedia source row")
	check(profile.get("models", 0) == 1 and profile.get("points_by_models", {}) == {1: 60} and profile.get("third_plus_points_by_models", {}) == {1: 60} and profile.get("fourth_plus_points_by_models", {}) == {1: 70}, "Composition and first-through-fourth-plus costs match the verified export")
	check(profile.get("stats", {}) == {"movement_inches": 0, "toughness": 7, "save_target": 3, "wounds": 8, "leadership_target": 6, "objective_control": 0, "invulnerable_target": 0}, "Every Drop Pod characteristic matches the export, including its non-numeric movement and OC as zero")
	check(actual_keywords == expected_keywords and is_equal_approx(float(profile.get("base_radius_inches", 0.0)), 40.0 / 25.4), "All source keywords match; the 80 mm circle is explicitly only the local proxy for custom geometry")
	check(profile.get("ranged", []).is_empty() and profile.get("melee", []).is_empty() and profile.get("transport", {}).get("capacity", 0) == 12 and profile.transport.get("required", []) == ["ADEPTUS ASTARTES", "INFANTRY"] and profile.transport.get("forbidden", []) == ["GRAVIS", "JUMP PACK", "TERMINATOR"], "No weapon is invented and transport capacity and exclusions match the sheet")
	check(Army.SPECS.get("drop-pod", {}).get("max_supported_copies", 0) == 4, "Local admission ceiling reaches the first fourth-plus priced unit")
	var four_pods := Army.admit({"schema_version": 2, "faction": "Space Marines", "category": "custom", "points_limit": 1000, "entries": [{"definition_id": "40kdc:11e:adeptus-astartes:drop-pod", "models": 1, "copies": 4}]})
	var five_pods := Army.admit({"schema_version": 2, "faction": "Space Marines", "category": "custom", "points_limit": 1000, "entries": [{"definition_id": "40kdc:11e:adeptus-astartes:drop-pod", "models": 1, "copies": 5}]})
	check(four_pods.get("error", "").is_empty() and int(four_pods.get("total", -1)) == 250 and not five_pods.get("error", "").is_empty(), "Local admission prices three Drop Pods at 60 and the fourth at 70, then enforces its four-copy ceiling")
	var catalog_resolution := Army.resolve("Space Marines", "40kdc:11e:adeptus-astartes:drop-pod")
	check(catalog_resolution.get("error", "").is_empty() and catalog_resolution.get("cost", -1) == 60 and catalog_resolution.get("unsupported_abilities", []).is_empty(), "Drop Pod resolves from the consolidated current local catalog with no unsupported source abilities")
	var materialized := F.P.initial_state({"unit_abilities": true, "combat_doctrines": true, "reanimation_protocols": true, "awakened_dynasty": true, "core_stratagems": true, "manual_allocation": false}, current_drop_pod_selections())
	check(not materialized.has("error"), "Both sides admit the current-catalog Drop Pod profile: " + str(materialized.get("error", "")))
	if not materialized.has("error"):
		for owner in [1, 2]:
			var model := current_drop_pod_model(materialized, owner)
			check(model >= 0, "Player %d materializes a current-catalog Drop Pod" % owner)
			if model < 0: continue
			var squad: int = int(materialized.units[model].get("squad", -1))
			var unit: Dictionary = materialized.units[model]
			check(materialized.squads[squad].get("stats", {}) == profile.stats, "Player %d has the exact source characteristics" % owner)
			check(unit.get("keywords", []) == profile.keywords and unit.get("transport_profile", {}) == profile.transport, "Player %d has the exact source keywords and transport data" % owner)
			check(unit.get("ranged_weapons", []).is_empty() and unit.get("melee_weapons", []).is_empty() and Abilities.has(materialized, squad, "deep-strike") and Abilities.has(materialized, squad, "transport-deadly-demise"), "Player %d receives the empty loadout, Deep Strike and Deadly Demise 1" % owner)
	var state := fresh_current()
	state.squads[900] = {"owner": 1, "name": "Drop Pod", "starting_strength": 1, "training_cost": 60, "stats": profile.stats.duplicate(true), "moved": false, "move_type": "unselected", "battle_shocked": false}
	state.units[9000] = {"owner": 1, "squad": 900, "definition_id": "40kdc:11e:adeptus-astartes:drop-pod", "position": Vector2.ZERO, "radius": profile.base_radius_inches, "keywords": profile.keywords.duplicate(), "wounds": profile.stats.wounds, "max_wounds": profile.stats.wounds, "on_battlefield": true, "transport_profile": profile.transport.duplicate(true)}
	state.deployment.order.append(900)
	var capped_state: Dictionary = state.duplicate(true)
	capped_state.points_limit = 100
	check(UnitActions._reserve_required_drop_pods(capped_state, 1).contains("half-army"), "Mandatory Drop Pod reserves obey the half-army Strategic Reserves cap")
	check(not capped_state.unit_abilities.reserves.has(900), "A Drop Pod is not reserved after the points cap rejects its placement")
	var reserve_error := UnitActions._reserve_required_drop_pods(state, 1)
	check(reserve_error.is_empty(), "Drop Pod Assault automatically reserves the Drop Pod during army preparation")
	check(state.unit_abilities.reserves.has(900) and state.unit_abilities.reserves[900].source == "drop-pod-assault" and not state.units[9000].on_battlefield and 900 not in state.deployment.order, "Mandatory reservation removes the Drop Pod from deployment and records its reserve cost")
	state.phase = "movement"
	state.active = 1
	state.round = 1
	state.erase("fearsome_assault")
	state.awakened_dynasty.pending = []
	var choices := UnitActions.choices(state, 1)
	var first_turn_ingress := false
	for option: Dictionary in choices:
		if option.action == "ingress" and int(option.target) == 900 and str(option.label).begins_with("Drop Pod Assault ingress:"): first_turn_ingress = true
	check(first_turn_ingress, "Drop Pod Assault permits its own ingress during the owner's first Movement phase")
	state.round = 1
	state.active = 2
	check(UnitActions.choices(state, 1).all(func(option: Dictionary) -> bool: return not (option.action == "ingress" and int(option.target) == 900)), "Drop Pod's first-turn ingress is not offered in the opponent's Movement phase")
	var arrival := fresh_current()
	arrival.phase = "movement"
	arrival.active = 1
	arrival.round = 1
	arrival.erase("fearsome_assault")
	arrival.awakened_dynasty.pending = []
	for model: int in arrival.units: arrival.units[model].on_battlefield = false
	var pod_profile := Profiles.profile("drop-pod")
	arrival.squads[900] = {"owner": 1, "name": "Drop Pod", "starting_strength": 1, "training_cost": 60, "stats": pod_profile.stats.duplicate(true), "moved": true, "move_type": "ingress", "battle_shocked": false}
	arrival.units[9000] = {"owner": 1, "squad": 900, "definition_id": "40kdc:11e:adeptus-astartes:drop-pod", "position": Vector2(-15, 0), "radius": pod_profile.base_radius_inches, "keywords": pod_profile.keywords.duplicate(), "wounds": pod_profile.stats.wounds, "max_wounds": pod_profile.stats.wounds, "on_battlefield": true, "transport_profile": pod_profile.transport.duplicate(true)}
	arrival.squads[901] = {"owner": 1, "name": "Passenger One", "starting_strength": 1, "stats": {"movement_inches": 6}, "moved": false, "move_type": "unselected", "embarked_in": 900, "embarked_this_turn": -1, "battle_shocked": false}
	arrival.squads[902] = {"owner": 1, "name": "Passenger Two", "starting_strength": 1, "stats": {"movement_inches": 6}, "moved": false, "move_type": "unselected", "embarked_in": 900, "embarked_this_turn": -1, "battle_shocked": false}
	for passenger_model in [9010, 9020]:
		var passenger_squad: int = int(passenger_model / 10)
		arrival.units[passenger_model] = {"owner": 1, "squad": passenger_squad, "definition_id": "40kdc:11e:adeptus-astartes:assault-intercessor-squad", "position": Vector2(-14, 0), "radius": 0.1, "keywords": ["ADEPTUS ASTARTES", "INFANTRY", "TACTICUS"], "wounds": 2, "max_wounds": 2, "on_battlefield": false, "embarked_transport": 9000}
	arrival.squads[901].embarked_this_turn = -1
	arrival.squads[902].embarked_this_turn = -1
	arrival.squads[9500] = {"owner": 2, "name": "Enemy", "starting_strength": 1, "stats": {}, "battle_shocked": false}
	arrival.units[95000] = {"owner": 2, "squad": 9500, "position": Vector2(-2, 0), "radius": 0.1, "wounds": 2, "on_battlefield": true}
	arrival.units[9010].wounds = 1
	var integrated_arrival: Dictionary = arrival.duplicate(true)
	integrated_arrival.units[9000].on_battlefield = false
	integrated_arrival.squads[900].moved = false
	integrated_arrival.squads[900].move_type = "unselected"
	integrated_arrival.unit_abilities.reserves[900] = {"cost": 60, "source": "drop-pod-assault"}
	var ingress_start := submit_transport_choice(integrated_arrival, 1, "ingress", -1, 900)
	check(ingress_start.get("error", "").is_empty(), "Drop Pod begins its own ingress during the first Movement phase: " + str(ingress_start.get("error", "")))
	var ingress_frame := ResolutionFrames.current(integrated_arrival)
	check(ingress_frame.get("kind", "") == "unit-action" and ingress_frame.get("status", "") == "suspended", "Drop Pod ingress preview suspends its own persisted action frame")
	var restored_ingress: Dictionary = bytes_to_var(var_to_bytes(integrated_arrival))
	check(ResolutionFrames.current(restored_ingress).get("frame_id", "") == ingress_frame.get("frame_id", "") and restored_ingress.unit_abilities.window.get("resolution_frame_id", "") == ingress_frame.get("frame_id", ""), "Ingress preview save/resume preserves its frame before Drop Pod arrival")
	integrated_arrival = restored_ingress
	var ingress_place := submit_transport_choice(integrated_arrival, 1, "ingress-place", 9000, 900, Vector2(-15, 0))
	check(ingress_place.get("error", "").is_empty(), "Drop Pod ingress accepts its preview position: " + str(ingress_place.get("error", "")))
	var ingress_confirm := submit_transport_choice(integrated_arrival, 1, "ingress-confirm", -1, -1)
	var arrival_frame := ResolutionFrames.current(integrated_arrival)
	var frame_stack: Array = integrated_arrival.get("resolution_frames", [])
	check(ingress_confirm.get("error", "").is_empty() and integrated_arrival.unit_abilities.get("transport_window", {}).get("mandatory_drop_pod", false) and arrival_frame.get("kind", "") == "transport-drop-pod-assault" and frame_stack.size() == 2 and frame_stack[0].get("frame_id", "") == ingress_frame.get("frame_id", ""), "Confirming Drop Pod ingress nests compulsory passenger disembarkation under the ingress continuation: " + str(ingress_confirm.get("error", "")))
	var pod_decision := PendingDecisions.current(integrated_arrival, ["unit-actions"])
	check(pod_decision.get("priority_player_id", -1) == 1 and pod_decision.get("resume_frame_id", "") == arrival_frame.get("frame_id", "") and not PhaseCloseGate.close_request_error(integrated_arrival, 1, integrated_arrival.revision).is_empty(), "Mandatory passenger placement exposes its owner decision and keeps phase close blocked under the nested frame")
	var pod_restore: Dictionary = bytes_to_var(var_to_bytes(integrated_arrival))
	var restored_pod_decision := PendingDecisions.current(pod_restore, ["unit-actions"])
	check(restored_pod_decision.get("decision_id", "") == pod_decision.get("decision_id", "") and ResolutionFrames.current(pod_restore).get("frame_id", "") == arrival_frame.get("frame_id", ""), "Drop Pod passenger decision and nested frame keep their identities through save/restore")
	integrated_arrival = pod_restore
	var wrong_pod_owner := submit_transport_choice(integrated_arrival, 2, "transport-disembark-place", 9010, 901, Vector2(-12, 0))
	check(not str(wrong_pod_owner.get("error", "")).is_empty(), "The mandatory Drop Pod placement cannot be submitted by the opponent")
	check(str(submit_transport_choice(integrated_arrival, 1, "transport-disembark-place", 9010, 901, Vector2(-12, 0)).get("error", "")).is_empty(), "The first nested Drop Pod passenger can be placed through the normalized command")
	check(str(submit_transport_choice(integrated_arrival, 1, "transport-disembark-confirm", -1, 901).get("error", "")).is_empty(), "The first nested passenger advances to the second through the normalized command")
	check(int(integrated_arrival.unit_abilities.transport_window.get("passenger_squad", -1)) == 902 and ResolutionFrames.current(integrated_arrival).get("frame_id", "") == arrival_frame.get("frame_id", ""), "The next mandatory passenger retains the same Drop Pod continuation")
	check(str(submit_transport_choice(integrated_arrival, 1, "transport-disembark-place", 9020, 902, Vector2(-11.5, 0)).get("error", "")).is_empty(), "The second nested Drop Pod passenger can be placed through the normalized command")
	check(str(submit_transport_choice(integrated_arrival, 1, "transport-disembark-confirm", -1, 902).get("error", "")).is_empty() and ResolutionFrames.current(integrated_arrival).is_empty(), "Completing Drop Pod Assault closes its frame and the parent ingress frame through the normalized command")
	var out_of_phase_arrival: Dictionary = arrival.duplicate(true)
	out_of_phase_arrival.active = 2
	check(Transport.begin_drop_pod_arrival(out_of_phase_arrival, 1, 9000, func() -> int: return 6).is_empty() and out_of_phase_arrival.unit_abilities.transport_window.get("player", -1) == 1, "Drop Pod Assault resolves compulsory disembarkation when the Pod is set up by an out-of-phase ingress")
	check(Transport.begin_drop_pod_arrival(arrival, 1, 9000, func() -> int: return 1).is_empty(), "Drop Pod arrival opens mandatory disembarkation for its first embarked unit")
	check(arrival.unit_abilities.transport_window.get("mandatory_drop_pod", false) and arrival.unit_abilities.transport_window.passenger_squad == 901, "Drop Pod passenger decision is marked mandatory and sequenced")
	var pod_frame := ResolutionFrames.current(arrival)
	check(pod_frame.get("kind", "") == "transport-drop-pod-assault" and arrival.unit_abilities.transport_window.get("resolution_frame_id", "") == pod_frame.get("frame_id", ""), "Mandatory passenger placement exposes its persisted Drop Pod action frame")
	var restored_arrival: Dictionary = bytes_to_var(var_to_bytes(arrival))
	check(ResolutionFrames.current(restored_arrival).get("frame_id", "") == pod_frame.get("frame_id", "") and restored_arrival.unit_abilities.transport_window.get("resolution_frame_id", "") == pod_frame.get("frame_id", ""), "Saving and restoring compulsory disembarkation preserves the frame across the choice")
	arrival = restored_arrival
	var rapid_disembark_options := Transport.choices(arrival, 1)
	check(rapid_disembark_options.size() == 1 and rapid_disembark_options[0].get("action", "") == "transport-disembark-place" and arrival.unit_abilities.transport_window.get("hazard_rolls", []).is_empty(), "Drop Pod Assault uses Rapid Disembark without Emergency Disembark Hazard rolls")
	var first_passenger_error := "Expected one Drop Pod passenger placement choice."
	if rapid_disembark_options.size() == 1:
		first_passenger_error = Transport.apply(arrival, 1, rapid_disembark_options[0], Vector2(-12, 0))
		if first_passenger_error.is_empty(): first_passenger_error = Transport.apply(arrival, 1, {"action": "transport-disembark-confirm", "target": 901}, Vector2.ZERO)
	check(first_passenger_error.is_empty(), "The first Drop Pod passenger places and confirms under its mandatory continuation: " + first_passenger_error)
	check(arrival.unit_abilities.transport_window.get("passenger_squad", -1) == 902 and ResolutionFrames.current(arrival).get("frame_id", "") == pod_frame.get("frame_id", ""), "The next mandatory passenger retains the same Drop Pod continuation")
	check(not Transport._position_error(arrival, arrival.unit_abilities.transport_window, 9020, Vector2(-8, 0)).is_empty(), "Drop Pod passenger placement rejects a position within 8 inches of an enemy")
	check(Transport.apply(arrival, 1, {"action": "transport-disembark-place", "model": 9020, "target": 902}, Vector2(-11.5, 0)).is_empty(), "Remaining Drop Pod passenger can be placed beyond 8 inches from every enemy")
	check(Transport.apply(arrival, 1, {"action": "transport-disembark-confirm", "target": 902}, Vector2.ZERO, func() -> int: return 6).is_empty(), "Remaining compulsory Drop Pod passenger completes its disembark move")
	check(arrival.units[9000].get("drop_pod_deployment_complete", false) and arrival.unit_abilities.transport_window.is_empty() and ResolutionFrames.current(arrival).is_empty(), "Deployment Complete is recorded and the continuation closes after all passengers disembark")
	arrival.squads[903] = {"owner": 1, "name": "Late passenger", "starting_strength": 1, "stats": {"movement_inches": 6}}
	arrival.units[9030] = {"owner": 1, "squad": 903, "definition_id": "40kdc:11e:adeptus-astartes:assault-intercessor-squad", "position": Vector2(-12, 0), "radius": 0.1, "keywords": ["ADEPTUS ASTARTES", "INFANTRY", "TACTICUS"], "wounds": 2, "on_battlefield": true}
	check(Transport.eligibility_error(arrival, 9000, 903).contains("Deployment Complete"), "Completed Drop Pod cannot embark a later unit")
	print("Marine Drop Pod rules: %d failures" % failures)
	quit(1 if failures else 0)

func _initialize() -> void: call_deferred("run")
