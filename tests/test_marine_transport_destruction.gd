extends SceneTree
const Transport = preload("res://scripts/edition_11/transport_rules.gd")
const DeadlyDemise = preload("res://scripts/edition_11/deadly_demise.gd")
const UnitActions = preload("res://scripts/edition_11/unit_actions.gd")
const F = preload("res://tests/all_units_fixture.gd")
const Combat = F.C
var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func make_state() -> Dictionary:
	var profile := preload("res://scripts/edition_11/current_reference_marine_profiles.gd").profile("rhino")
	var state := {
		"phase": "shooting", "active": 2, "turn": 1, "revision": 0, "events": [], "board_size": Vector2(48, 36),
		"terrain": {"id": "terrain-11e-v1", "areas": []},
		"unit_abilities": {"window": {}, "transport_window": {}},
		"pending_attack": {"pools": [{"allocations": [{"model": 100}]}], "deadly_demise_checked": false, "squad": 3, "player": 2, "entries": [], "melee": false, "prepared": {}, "damage": 0, "killed": 1}, "pending_deadly_demise": {}, "detachment_stratagems": {},
		"squads": {
			1: {"owner": 1, "name": "Rhino", "starting_strength": 1, "stats": profile.stats.duplicate(true)},
			2: {"owner": 1, "name": "Assault Intercessors", "starting_strength": 5, "stats": {"movement_inches": 6, "toughness": 4, "save_target": 3, "wounds": 2, "leadership_target": 6, "objective_control": 2}, "moved": true, "move_type": "normal", "set_up_this_turn": false}
		},
		"units": {
			100: {"owner": 1, "squad": 1, "definition_id": "40kdc:11e:adeptus-astartes:rhino", "position": Vector2(0, 0), "radius": 2.36, "keywords": profile.keywords.duplicate(), "wounds": 0, "on_battlefield": true, "transport_profile": profile.transport.duplicate(true)},
		}
	}
	for index in range(5):
		var model := 200 + index
		state.units[model] = {"owner": 1, "squad": 2, "definition_id": "40kdc:11e:adeptus-astartes:assault-intercessor-squad", "position": Vector2(0, 0), "radius": 0.1, "keywords": ["ADEPTUS ASTARTES", "INFANTRY", "TACTICUS"], "wounds": 2, "max_wounds": 2, "on_battlefield": false, "embarked_transport": 100}
	return state

func run() -> void:
	var state := make_state()
	state.squads[2].embarked_in = 100
	state.squads[2].embarked_this_turn = 0
	var started := Combat._finish_pending_attack(state, func() -> int: return 1)
	check(started.error.is_empty() and not started.complete, "Destroying a transport opens its mandatory passenger Emergency Disembark before finishing destruction")
	check(state.unit_abilities.transport_window.stage == "hazard" and state.unit_abilities.transport_window.hazard_rolls == [1, 1, 1, 1, 1], "Emergency Disembark rolls one Hazard die per embarked model")
	check(state.unit_abilities.window.owners == [1], "The passenger owner allocates Hazard mortal wounds even when the opponent is the active player")
	for _index in range(5):
		var options := Transport.choices(state, 1)
		check(not options.is_empty() and options[0].action == "transport-disembark-hazard-allocate", "Hazard failure requires a passenger mortal-wound allocation")
		if options.is_empty(): break
		var error := Transport.apply(state, 1, options[0], Vector2.ZERO, func() -> int: return 6)
		check(error.is_empty(), "Emergency Hazard mortal wound resolves through local Feel No Pain prevention")
	check(state.unit_abilities.transport_window.stage == "placement" and state.unit_abilities.window.owners == [2], "The active player takes over for Emergency Disembark placement after allocation")
	state.squads[4] = {"owner": 2, "name": "Engaged enemy", "starting_strength": 1, "stats": {}}
	state.units[300] = {"owner": 2, "squad": 4, "position": Vector2(4.0, 0), "radius": 0.2, "wounds": 2, "on_battlefield": true}
	var emergency_window: Dictionary = state.unit_abilities.transport_window
	check(not Transport._position_error(state, emergency_window, 200, Vector2(2.46, 0)).is_empty(), "Emergency setup cannot engage an enemy while an unengaged option is being checked")
	var engaged_window: Dictionary = emergency_window.duplicate(true)
	engaged_window.allow_engaged = true
	check(Transport._position_error(state, engaged_window, 200, Vector2(2.46, 0)).is_empty(), "Emergency setup may engage an enemy when no unengaged placement is possible")
	state.units.erase(300)
	state.squads.erase(4)
	var positions: Array[Vector2] = [Vector2(2.44, -0.4), Vector2(2.46, -0.2), Vector2(2.46, 0), Vector2(2.46, 0.2), Vector2(2.44, 0.4)]
	var survivors := Transport.models(state, 2)
	for index in range(survivors.size()):
		var option := {"action": "transport-disembark-place", "model": survivors[index], "target": 2, "value": ""}
		var place_error := Transport.apply(state, 2, option, positions[index + 2])
		check(place_error.is_empty(), "Emergency Disembark accepts a coherent, unengaged position within 6 inches: " + place_error)
	check(Transport.confirm_error(state).is_empty(), "All surviving models are placed in coherency")
	var confirmed := UnitActions.apply(state, 2, {"action": "transport-disembark-confirm", "model": -1, "target": 2, "value": ""}, Vector2.ZERO, func() -> int: return 6)
	check(confirmed.get("error", "").is_empty() and confirmed.get("resume_attack", false), "Emergency Disembark confirms through the unit-action dispatcher and resumes the attack")
	check(state.pending_deadly_demise.is_empty() and state.units[100].get("on_battlefield", true) == false, "The transport is removed only after passengers finish, then the destruction queue resumes")
	check(state.squads[2].battle_shocked and state.squads[2].get("cannot_charge_until_turn", -1) == 1 and state.units[survivors[0]].on_battlefield, "Emergency survivors are Battle-shocked, cannot charge this turn and return to the battlefield")
	print("Marine transport destruction: %d failures" % failures)
	quit(1 if failures else 0)

func _initialize() -> void: call_deferred("run")
