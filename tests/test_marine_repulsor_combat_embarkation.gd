extends SceneTree
const F = preload("res://tests/all_units_fixture.gd")
const Combat = preload("res://scripts/edition_11/combat_scenario.gd")
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const UnitAbilities = preload("res://scripts/edition_11/unit_abilities.gd")
const Transport = preload("res://scripts/edition_11/transport_rules.gd")
var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func make_state() -> Dictionary:
	var state := F.fresh()
	state.units.clear()
	state.squads.clear()
	var profile := Profiles.profile("repulsor")
	state.squads[1] = {"owner": 1, "name": "Charging unit", "starting_strength": 1, "stats": {"movement_inches": 6}, "charged": false}
	state.units[100] = {"owner": 1, "squad": 1, "position": Vector2(0, 0), "radius": 0.1, "keywords": ["INFANTRY"], "wounds": 2, "max_wounds": 2, "on_battlefield": true}
	state.squads[2] = {"owner": 2, "name": "Declared target", "starting_strength": 1, "stats": {"movement_inches": 6}, "charged": false}
	state.units[200] = {"owner": 2, "squad": 2, "position": Vector2(7.5, 0), "radius": 0.1, "keywords": ["ADEPTUS ASTARTES", "INFANTRY", "TACTICUS"], "wounds": 2, "max_wounds": 2, "on_battlefield": true}
	state.squads[3] = {"owner": 2, "name": "Replacement target", "starting_strength": 1, "stats": {"movement_inches": 6}, "charged": false}
	state.units[300] = {"owner": 2, "squad": 3, "position": Vector2(10.5, 0), "radius": 0.1, "keywords": ["INFANTRY"], "wounds": 2, "max_wounds": 2, "on_battlefield": true}
	state.squads[4] = {"owner": 2, "name": "Engaged target", "starting_strength": 1, "stats": {"movement_inches": 6}, "charged": false}
	state.units[400] = {"owner": 2, "squad": 4, "position": Vector2(1.5, 0), "radius": 0.1, "keywords": ["ADEPTUS ASTARTES", "INFANTRY", "TACTICUS"], "wounds": 2, "max_wounds": 2, "on_battlefield": true}
	state.squads[90] = {"owner": 2, "name": "Repulsor", "starting_strength": 1, "stats": profile.stats.duplicate(true), "moved": false, "move_type": "stationary"}
	state.units[9000] = {"owner": 2, "squad": 90, "definition_id": "40kdc:11e:adeptus-astartes:repulsor", "position": Vector2(4.8, 0), "radius": profile.base_radius_inches, "keywords": profile.keywords.duplicate(), "wounds": profile.stats.wounds, "max_wounds": profile.stats.wounds, "on_battlefield": true, "transport_profile": profile.transport.duplicate(true)}
	UnitAbilities.enable(state)
	state.awakened_dynasty.pending = []
	state.erase("fearsome_assault")
	state.phase = "charge"
	state.active = 1
	state.turn = 1
	state.pending_charge = {"squad": 1, "maximum": 12, "rolls": [6, 6], "targets": [2, 4]}
	return state

func run() -> void:
	var state := make_state()
	check(Transport._combat_embarkation_candidates(state, 2).size() == 1 and Transport._combat_embarkation_candidates(state, 2)[0].passenger_squad == 2, "Repulsor offers only the unengaged, in-range, datasheet-eligible Astartes target")
	state.squads[2].set_up_this_turn = true
	check(Transport._combat_embarkation_candidates(state, 2).is_empty(), "A unit set up this turn is not eligible to embark in response to a charge")
	state.squads[2].set_up_this_turn = false
	var begin_error := Combat.begin_contact_move(state, 1, 100, "charge", state.revision)
	check(begin_error.is_empty() and state.pending_contact.is_empty() and state.unit_abilities.window.get("kind", "") == Transport.COMBAT_EMBARKATION_WINDOW, "Starting charge placement opens the Repulsor reaction before any models move")
	check(Combat.actor(state) == 2, "Defending player owns the Repulsor reaction window")
	var options := Combat.unit_choices(state, 2)
	var embark_options := options.filter(func(option: Dictionary) -> bool: return option.action == "repulsor-combat-embarkation-embark")
	var pass_options := options.filter(func(option: Dictionary) -> bool: return option.action == "repulsor-combat-embarkation-pass")
	if embark_options.is_empty() or pass_options.is_empty():
		print("Repulsor choices debug: " + str(options))
		print("Repulsor Combat Embarkation: %d failures" % (failures + 1))
		quit(1)
		return
	var embark: Dictionary = embark_options[0]
	var decline: Dictionary = pass_options[0]
	var passed := state.duplicate(true)
	var pass_error := Combat.unit_action(passed, 2, decline, Vector2.ZERO, passed.revision)
	check(pass_error.is_empty(), "Defender can pass on the optional Repulsor reaction")
	check(passed.unit_abilities.window.is_empty() and passed.pending_charge.combat_embarkation_resolved and passed.units[200].on_battlefield, "Passing closes the reaction without changing the target")
	var embark_error := Combat.unit_action(state, 2, embark, Vector2.ZERO, state.revision)
	check(embark_error.is_empty(), "Defender can embark the selected charge target in its Repulsor")
	check(not state.units[200].on_battlefield and state.units[200].embarked_transport == 9000 and state.pending_charge.targets == [4], "Embarking removes the target from the battlefield and from the charge target list")
	check(not Combat.charge_target_error(state, 1, 200, state.revision).is_empty(), "An embarked unit cannot be reselected as a charge target")
	check(Combat.select_charge_target(state, 1, 300, state.revision).error.is_empty(), "Charging unit can select a new target after the reaction")
	check(Combat.begin_contact_move(state, 1, 100, "charge", state.revision).is_empty() and not state.pending_contact.is_empty() and state.unit_abilities.window.is_empty(), "Resolved reaction does not repeat and the revised charge can proceed to placement")
	print("Repulsor Combat Embarkation: %d failures" % failures)
	quit(1 if failures else 0)

func _initialize() -> void: call_deferred("run")
