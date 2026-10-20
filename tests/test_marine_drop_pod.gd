extends SceneTree
const F = preload("res://tests/all_units_fixture.gd")
const UnitActions = preload("res://scripts/edition_11/unit_actions.gd")
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Transport = preload("res://scripts/edition_11/transport_rules.gd")
var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func run() -> void:
	var state := F.fresh()
	var profile := Profiles.profile("drop-pod")
	state.squads[900] = {"owner": 1, "name": "Drop Pod", "starting_strength": 1, "training_cost": 60, "stats": profile.stats.duplicate(true), "moved": false, "move_type": "unselected"}
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
	var arrival := F.fresh()
	arrival.phase = "movement"
	arrival.active = 1
	arrival.round = 1
	arrival.erase("fearsome_assault")
	arrival.awakened_dynasty.pending = []
	var pod_profile := Profiles.profile("drop-pod")
	arrival.squads[900] = {"owner": 1, "name": "Drop Pod", "starting_strength": 1, "training_cost": 60, "stats": pod_profile.stats.duplicate(true), "moved": true, "move_type": "ingress"}
	arrival.units[9000] = {"owner": 1, "squad": 900, "definition_id": "40kdc:11e:adeptus-astartes:drop-pod", "position": Vector2(-15, 0), "radius": pod_profile.base_radius_inches, "keywords": pod_profile.keywords.duplicate(), "wounds": pod_profile.stats.wounds, "max_wounds": pod_profile.stats.wounds, "on_battlefield": true, "transport_profile": pod_profile.transport.duplicate(true)}
	arrival.squads[901] = {"owner": 1, "name": "Passenger One", "starting_strength": 1, "stats": {"movement_inches": 6}, "moved": false, "move_type": "unselected", "embarked_in": 900, "embarked_this_turn": -1}
	arrival.squads[902] = {"owner": 1, "name": "Passenger Two", "starting_strength": 1, "stats": {"movement_inches": 6}, "moved": false, "move_type": "unselected", "embarked_in": 900, "embarked_this_turn": -1}
	for passenger_model in [9010, 9020]:
		var passenger_squad: int = int(passenger_model / 10)
		arrival.units[passenger_model] = {"owner": 1, "squad": passenger_squad, "definition_id": "40kdc:11e:adeptus-astartes:assault-intercessor-squad", "position": Vector2(-14, 0), "radius": 0.1, "keywords": ["ADEPTUS ASTARTES", "INFANTRY", "TACTICUS"], "wounds": 2, "max_wounds": 2, "on_battlefield": false, "embarked_transport": 9000}
	arrival.squads[901].embarked_this_turn = -1
	arrival.squads[902].embarked_this_turn = -1
	arrival.squads[3] = {"owner": 2, "name": "Enemy", "starting_strength": 1, "stats": {}}
	arrival.units[30] = {"owner": 2, "squad": 3, "position": Vector2(-2, 0), "radius": 0.1, "wounds": 2, "on_battlefield": true}
	var integrated_arrival: Dictionary = arrival.duplicate(true)
	integrated_arrival.units[9000].on_battlefield = false
	integrated_arrival.squads[900].moved = false
	integrated_arrival.squads[900].move_type = "unselected"
	integrated_arrival.unit_abilities.reserves[900] = {"cost": 60, "source": "drop-pod-assault"}
	var ingress_start := UnitActions.apply(integrated_arrival, 1, {"action": "ingress", "model": -1, "target": 900, "value": ""}, Vector2.ZERO, func() -> int: return 6)
	check(ingress_start.get("error", "").is_empty(), "Drop Pod begins its own ingress during the first Movement phase")
	var ingress_place := UnitActions.apply(integrated_arrival, 1, {"action": "ingress-place", "model": 9000, "target": 900, "value": ""}, Vector2(-15, 0), func() -> int: return 6)
	check(ingress_place.get("error", "").is_empty(), "Drop Pod ingress accepts its preview position")
	var ingress_confirm := UnitActions.apply(integrated_arrival, 1, {"action": "ingress-confirm", "model": -1, "target": 900, "value": ""}, Vector2.ZERO, func() -> int: return 6)
	check(ingress_confirm.get("error", "").is_empty() and integrated_arrival.unit_abilities.transport_window.get("mandatory_drop_pod", false), "Confirming Drop Pod ingress immediately opens compulsory passenger disembarkation")
	var out_of_phase_arrival: Dictionary = arrival.duplicate(true)
	out_of_phase_arrival.active = 2
	check(Transport.begin_drop_pod_arrival(out_of_phase_arrival, 1, 9000, func() -> int: return 6).is_empty() and out_of_phase_arrival.unit_abilities.transport_window.get("player", -1) == 1, "Drop Pod Assault resolves compulsory disembarkation when the Pod is set up by an out-of-phase ingress")
	check(Transport.begin_drop_pod_arrival(arrival, 1, 9000, func() -> int: return 6).is_empty(), "Drop Pod arrival opens mandatory disembarkation for its first embarked unit")
	check(arrival.unit_abilities.transport_window.get("mandatory_drop_pod", false) and arrival.unit_abilities.transport_window.passenger_squad == 901, "Drop Pod passenger decision is marked mandatory and sequenced")
	check(not Transport._position_error(arrival, arrival.unit_abilities.transport_window, 9010, Vector2(-8, 0)).is_empty(), "Drop Pod passenger placement rejects a position within 8 inches of an enemy")
	check(Transport.apply(arrival, 1, {"action": "transport-disembark-place", "model": 9010, "target": 901}, Vector2(-12, 0)).is_empty(), "Drop Pod passenger can be placed beyond 8 inches from every enemy")
	check(Transport.apply(arrival, 1, {"action": "transport-disembark-confirm", "target": 901}, Vector2.ZERO, func() -> int: return 6).is_empty(), "First compulsory Drop Pod passenger completes its disembark move")
	check(arrival.unit_abilities.transport_window.get("passenger_squad", -1) == 902, "Drop Pod automatically opens the next embarked unit's disembark move")
	check(Transport.apply(arrival, 1, {"action": "transport-disembark-place", "model": 9020, "target": 902}, Vector2(-11.5, 0)).is_empty(), "Second Drop Pod passenger can be placed legally")
	check(Transport.apply(arrival, 1, {"action": "transport-disembark-confirm", "target": 902}, Vector2.ZERO, func() -> int: return 6).is_empty(), "Second compulsory Drop Pod passenger completes its disembark move")
	check(arrival.units[9000].get("drop_pod_deployment_complete", false) and arrival.unit_abilities.transport_window.is_empty(), "Deployment Complete is recorded after all passengers disembark")
	arrival.squads[903] = {"owner": 1, "name": "Late passenger", "starting_strength": 1, "stats": {"movement_inches": 6}}
	arrival.units[9030] = {"owner": 1, "squad": 903, "definition_id": "40kdc:11e:adeptus-astartes:assault-intercessor-squad", "position": Vector2(-12, 0), "radius": 0.1, "keywords": ["ADEPTUS ASTARTES", "INFANTRY", "TACTICUS"], "wounds": 2, "on_battlefield": true}
	check(Transport.eligibility_error(arrival, 9000, 903).contains("Deployment Complete"), "Completed Drop Pod cannot embark a later unit")
	print("Marine Drop Pod rules: %d failures" % failures)
	quit(1 if failures else 0)

func _initialize() -> void: call_deferred("run")
