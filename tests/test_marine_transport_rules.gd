extends SceneTree
const Transport = preload("res://scripts/edition_11/transport_rules.gd")
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Actions = preload("res://scripts/edition_11/actions.gd")
var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func make_state(identity: String, transport_owner: int = 1) -> Dictionary:
	var profile := Profiles.profile(identity)
	return {
		"phase": "movement", "active": 1, "turn": 1, "board_size": Vector2(48, 36), "terrain": {"id": "terrain-11e-v1", "areas": []},
		"squads": {
			1: {"owner": transport_owner, "name": profile.name, "starting_strength": 1, "stats": profile.stats.duplicate(true), "moved": false, "move_type": "stationary", "set_up_this_turn": false},
			2: {"owner": 1, "name": "Assault Intercessors", "starting_strength": 5, "stats": {"movement_inches": 6}, "moved": true, "move_type": "normal", "set_up_this_turn": false},
			3: {"owner": 1, "name": "Gravis passengers", "starting_strength": 5, "stats": {"movement_inches": 5}, "moved": true, "move_type": "normal", "set_up_this_turn": false},
		},
		"units": {
			100: {"owner": transport_owner, "squad": 1, "definition_id": "40kdc:11e:adeptus-astartes:%s" % identity, "position": Vector2(0, 0), "radius": 0.8, "keywords": profile.keywords.duplicate(), "wounds": profile.stats.wounds, "on_battlefield": true, "transport_profile": profile.transport.duplicate(true)},
		},
	}

func add_passengers(state: Dictionary, squad: int, keywords: Array, positions: Array = []) -> void:
	for index in range(5):
		var position: Vector2 = positions[index] if index < positions.size() else Vector2(1.2 + index * 0.1, 0)
		state.units[squad * 100 + index] = {"owner": 1, "squad": squad, "definition_id": "40kdc:11e:adeptus-astartes:assault-intercessor-squad", "position": position, "radius": 0.1, "keywords": keywords.duplicate(), "wounds": 2, "on_battlefield": true}

func run() -> void:
	var rhino := make_state("rhino")
	add_passengers(rhino, 2, ["ADEPTUS ASTARTES", "INFANTRY", "TACTICUS"])
	check(Transport.embark_error(rhino, 1, 100, 2).is_empty(), "Rhino accepts a friendly eligible unit after its move within 3 inches")
	check(Transport.embark(rhino, 1, 100, 2).is_empty(), "Embark action resolves for the complete unit")
	check(Transport.occupied_capacity(rhino, 100) == 5 and not rhino.units[200].on_battlefield and rhino.units[204].embarked_transport == 100, "Embarking removes every passenger model from the battlefield and accounts capacity")
	check(not Transport.eligibility_error(rhino, 100, 3).is_empty(), "No unembarked passenger squad is silently included in capacity")

	var impulsor := make_state("impulsor")
	add_passengers(impulsor, 2, ["ADEPTUS ASTARTES", "INFANTRY", "GRAVIS"])
	check(Transport.capacity_cost(impulsor, 2, impulsor.units[100].transport_profile) == 10, "Impulsor occupancy counts each Gravis model as two spaces")
	check(not Transport.eligibility_error(impulsor, 100, 2).is_empty(), "Impulsor rejects a Gravis unit that exceeds its seven-space capacity")

	var land_raider := make_state("land-raider")
	add_passengers(land_raider, 2, ["ADEPTUS ASTARTES", "INFANTRY", "TERMINATOR"])
	check(Transport.capacity_cost(land_raider, 2, land_raider.units[100].transport_profile) == 10 and Transport.eligibility_error(land_raider, 100, 2).is_empty(), "Land Raider carries Terminators at double capacity within fourteen spaces")
	land_raider.units[200].position = Vector2(5, 0)
	check(Transport.embark_error(land_raider, 1, 100, 2).contains("within 3 inches"), "Movement embark requires every passenger model within 3 inches")
	land_raider.units[200].position = Vector2(1, 0)
	land_raider.squads[2].move_type = "stationary"
	check(Transport.embark_error(land_raider, 1, 100, 2).contains("after making"), "A unit that remained stationary cannot embark")
	land_raider.squads[2].move_type = "normal"
	land_raider.squads[2].set_up_this_turn = true
	check(Transport.embark_error(land_raider, 1, 100, 2).contains("set up on the battlefield this turn"), "A unit set up this turn cannot embark")

	var drop_pod := make_state("drop-pod")
	add_passengers(drop_pod, 2, ["ADEPTUS ASTARTES", "INFANTRY", "GRAVIS"])
	check(Transport.eligibility_error(drop_pod, 100, 2).contains("cannot carry GRAVIS"), "Drop Pod enforces its source-specific Gravis restriction")

	var disembark := make_state("rhino")
	disembark["board_size"] = Vector2(48, 36)
	disembark["terrain"] = {"id": "terrain-11e-v1", "areas": []}
	disembark["unit_abilities"] = {"transport_window": {}}
	add_passengers(disembark, 2, ["ADEPTUS ASTARTES", "INFANTRY", "TACTICUS"])
	check(Transport.embark(disembark, 1, 100, 2).is_empty(), "Test passenger squad embarks before disembark choices")
	disembark.squads[2].embarked_this_turn = 0
	check(Transport.occupied_capacity(disembark, 100) == 5 and Transport.disembark_choices(disembark, 1).size() == 1 and Transport.disembark_choices(disembark, 1)[0].value == "tactical", "Stationary transport offers Tactical Disembark to a unit not embarked this turn")
	disembark.squads[1].move_type = "normal"
	check(Transport.disembark_choices(disembark, 1).size() == 1 and Transport.disembark_choices(disembark, 1)[0].value == "rapid", "A transport that made a Normal move requires Rapid Disembark")
	var rapid_choice := Transport.disembark_choices(disembark, 1)[0]
	check(Transport.apply(disembark, 1, rapid_choice, Vector2.ZERO, func() -> int: return 6).is_empty(), "Rapid Disembark resolves its mandatory Hazard rolls and opens a placement window")
	var positions: Array[Vector2] = [Vector2(1.45, 0), Vector2(1.70, 0), Vector2(1.95, 0), Vector2(2.20, 0), Vector2(2.45, 0)]
	for index in range(5):
		var model := 200 + index
		var place := {"action": "transport-disembark-place", "model": model, "target": 2, "value": ""}
		check(Transport.apply(disembark, 1, place, positions[index]).is_empty(), "Disembark placement accepts legal wholly-within, non-overlapping model position %d" % model)
	check(Transport.confirm_error(disembark).is_empty(), "A complete coherently placed squad can confirm disembarkation")
	check(Transport.apply(disembark, 1, {"action": "transport-disembark-confirm"}, Vector2.ZERO).is_empty(), "Disembark confirmation restores every model to the battlefield")
	check(disembark.units[200].on_battlefield and not disembark.units[200].has("embarked_transport") and disembark.squads[2].get("disembarked_turn", -1) == 1 and disembark.squads[2].moved and Actions.charge_blocked(disembark, 2), "Rapid Disembark sets up the unit, prevents charging this turn and consumes its move")
	var hazard_disembark := make_state("rhino")
	hazard_disembark["unit_abilities"] = {"transport_window": {}, "window": {}}
	add_passengers(hazard_disembark, 2, ["ADEPTUS ASTARTES", "INFANTRY", "TACTICUS"])
	check(Transport.embark(hazard_disembark, 1, 100, 2).is_empty(), "Hazard test unit embarks")
	hazard_disembark.squads[2].embarked_this_turn = 0
	var hazard_start := Transport.apply(hazard_disembark, 1, Transport.disembark_choices(hazard_disembark, 1)[0], Vector2.ZERO, func() -> int: return 1)
	check(hazard_start.is_empty() and hazard_disembark.unit_abilities.transport_window.hazard_rolls == [1, 1, 1, 1, 1] and hazard_disembark.unit_abilities.transport_window.stage == "hazard", "Disembark makes one mandatory Hazard roll per passenger model before placement")
	for _index in range(5):
		var hazard_choices := Transport.choices(hazard_disembark, 1)
		if hazard_choices.is_empty(): break
		check(Transport.apply(hazard_disembark, 1, hazard_choices[0], Vector2.ZERO).is_empty(), "Failed disembark Hazard roll allocates a mortal wound")
	check(hazard_disembark.unit_abilities.transport_window.get("stage", "") == "placement", "Disembark placement starts after all failed Hazard rolls are allocated")
	var hazard_survivors := Transport.models(hazard_disembark, 2)
	for index in range(hazard_survivors.size()):
		check(Transport.apply(hazard_disembark, 1, {"action": "transport-disembark-place", "model": hazard_survivors[index]}, Vector2(1.4 + index * 0.25, 0)).is_empty(), "Survivors can be placed after disembark Hazard")
	check(Transport.apply(hazard_disembark, 1, {"action": "transport-disembark-confirm"}, Vector2.ZERO).is_empty() and hazard_disembark.unit_abilities.window.is_empty(), "Normal Disembark closes its Hazard actor window after confirmation")
	var combat_disembark := make_state("rhino")
	combat_disembark["board_size"] = Vector2(48, 36)
	combat_disembark["terrain"] = {"id": "blocked-tactical-zone", "areas": [{"name": "Transport enclosure", "category": "ruin", "bounds": Rect2(-4, -4, 8, 8), "features": [{"bounds": Rect2(-4, -4, 8, 8), "height": 4.0, "blocks_end": true}]}]}
	combat_disembark["unit_abilities"] = {"transport_window": {}, "window": {}}
	add_passengers(combat_disembark, 2, ["ADEPTUS ASTARTES", "INFANTRY", "TACTICUS"])
	check(Transport.embark(combat_disembark, 1, 100, 2).is_empty(), "Combat Disembark test unit embarks")
	combat_disembark.squads[2].embarked_this_turn = 0
	combat_disembark.squads[4] = {"owner": 2, "name": "Enemy in contact", "starting_strength": 1, "stats": {}}
	combat_disembark.units[400] = {"owner": 2, "squad": 4, "position": Vector2(2.7, 0), "radius": 0.1, "wounds": 2, "on_battlefield": true}
	var combat_choices := Transport.disembark_choices(combat_disembark, 1)
	check(combat_choices.size() == 1 and combat_choices[0].value == "combat", "When Tactical setup is impossible, Combat Disembark is mandatory")
	check(Transport.apply(combat_disembark, 1, combat_choices[0], Vector2.ZERO, func() -> int: return 6).is_empty(), "Combat Disembark starts after the mandatory Hazard rolls")
	var combat_window: Dictionary = combat_disembark.unit_abilities.transport_window
	check(Transport._position_error(combat_disembark, combat_window, 200, Vector2(4.9, 0)).is_empty(), "Combat Disembark may engage an enemy already engaged with its transport")
	var combat_positions: Array[Vector2] = [Vector2(4.9, 0), Vector2(5.15, 0), Vector2(5.4, 0), Vector2(5.65, 0), Vector2(5.9, 0)]
	for index in range(5):
		check(Transport.apply(combat_disembark, 1, {"action": "transport-disembark-place", "model": 200 + index, "target": 2, "value": ""}, combat_positions[index]).is_empty(), "Combat Disembark accepts legal positions within 6 inches")
	check(Transport.apply(combat_disembark, 1, {"action": "transport-disembark-confirm"}, Vector2.ZERO).is_empty(), "Combat Disembark confirmation succeeds")
	check(combat_disembark.squads[2].battle_shocked and combat_disembark.squads[2].get("cannot_charge_until_turn", -1) == 1 and Actions.charge_blocked(combat_disembark, 2), "Combat Disembark applies Battle-shock and prevents charging this turn")
	var assault_ramp := make_state("land-raider")
	assault_ramp["unit_abilities"] = {"transport_window": {}, "window": {}}
	add_passengers(assault_ramp, 2, ["ADEPTUS ASTARTES", "INFANTRY", "TACTICUS"])
	check(Transport.embark(assault_ramp, 1, 100, 2).is_empty(), "Assault Ramp passengers embark")
	assault_ramp.squads[2].embarked_this_turn = 0
	assault_ramp.squads[1].move_type = "normal"
	var ramp_modes := Transport.disembark_choices(assault_ramp, 1).map(func(choice: Dictionary) -> String: return str(choice.value))
	check("rapid" in ramp_modes and "assault" in ramp_modes, "Land Raider offers its source-listed Assault Disembark alongside mandatory Rapid Disembark")
	var ramp_choice: Dictionary = Transport.disembark_choices(assault_ramp, 1).filter(func(choice: Dictionary) -> bool: return str(choice.value) == "assault")[0]
	check(Transport.apply(assault_ramp, 1, ramp_choice, Vector2.ZERO, func() -> int: return 6).is_empty(), "Assault Ramp uses its 3-inch setup and permits the normal charge eligibility")
	for index in range(5):
		check(Transport.apply(assault_ramp, 1, {"action": "transport-disembark-place", "model": 200 + index}, Vector2(1.0 + index * 0.25, 0)).is_empty(), "Assault Ramp model position is legal")
	check(Transport.apply(assault_ramp, 1, {"action": "transport-disembark-confirm"}, Vector2.ZERO).is_empty() and not Actions.charge_blocked(assault_ramp, 2), "Assault Ramp does not impose a charge restriction")
	var impulsor_shock := make_state("impulsor")
	impulsor_shock["unit_abilities"] = {"transport_window": {}, "window": {}}
	add_passengers(impulsor_shock, 2, ["ADEPTUS ASTARTES", "INFANTRY", "TACTICUS"])
	check(Transport.embark(impulsor_shock, 1, 100, 2).is_empty(), "Impulsor passengers embark")
	impulsor_shock.squads[2].embarked_this_turn = 0
	impulsor_shock.squads[1].move_type = "advance"
	var shock_modes := Transport.disembark_choices(impulsor_shock, 1)
	check(shock_modes.size() == 1 and shock_modes[0].value == "shock", "Impulsor offers Shock Disembark after Advance")
	check(Transport.apply(impulsor_shock, 1, shock_modes[0], Vector2.ZERO, func() -> int: return 6).is_empty(), "Shock Disembark is allowed after the Impulsor Advances")
	for index in range(5):
		check(Transport.apply(impulsor_shock, 1, {"action": "transport-disembark-place", "model": 200 + index}, Vector2(1.0 + index * 0.25, 0)).is_empty(), "Shock Disembark model position is legal")
	check(Transport.apply(impulsor_shock, 1, {"action": "transport-disembark-confirm"}, Vector2.ZERO).is_empty() and Actions.charge_blocked(impulsor_shock, 2), "Shock Disembark prevents charges for the rest of the turn")
	print("Marine transport core rules: %d failures" % failures)
	quit(1 if failures else 0)

func _initialize() -> void: call_deferred("run")
