extends SceneTree
const Transport = preload("res://scripts/edition_11/transport_rules.gd")
const DeadlyDemise = preload("res://scripts/edition_11/deadly_demise.gd")
const Abilities = preload("res://scripts/edition_11/unit_abilities.gd")
const UnitActions = preload("res://scripts/edition_11/unit_actions.gd")
const PhaseCloseGate = preload("res://scripts/edition_11/phase_close_gate.gd")
const MatchCommands = preload("res://scripts/edition_11/match_command_service.gd")
const PendingDecisions = preload("res://scripts/edition_11/pending_decision_registry.gd")
const ResolutionFrames = preload("res://scripts/edition_11/resolution_frame.gd")
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
		"phase": "shooting", "active": 2, "turn": 1, "round": 1, "revision": 0, "events": [], "board_size": Vector2(48, 36),
		"terrain": {"id": "terrain-11e-v1", "areas": []},
		"unit_abilities": {"implementation": Abilities.ID, "window": {}, "transport_window": {}, "used": {}},
		"pending_attack": {"pools": [{"allocations": [{"model": 100}]}], "deadly_demise_checked": false, "forward_assault_checked": true, "squad": 3, "player": 2, "entries": [], "melee": false, "prepared": {"batches": [], "targets": [1], "hazardous_count": 0}, "index": 0, "current": {}, "damage": 0, "killed": 1}, "pending_deadly_demise": {}, "detachment_stratagems": {},
		"squads": {
			1: {"owner": 1, "name": "Rhino", "starting_strength": 1, "stats": profile.stats.duplicate(true)},
			2: {"owner": 1, "name": "Assault Intercessors", "starting_strength": 5, "stats": {"movement_inches": 6, "toughness": 4, "save_target": 3, "wounds": 2, "leadership_target": 6, "objective_control": 2}, "moved": true, "move_type": "normal", "set_up_this_turn": false},
			3: {"owner": 2, "name": "Attacking unit", "starting_strength": 1, "stats": {"movement_inches": 6, "toughness": 4, "save_target": 3, "wounds": 2, "leadership_target": 6, "objective_control": 2}}
		},
		"units": {
			100: {"owner": 1, "squad": 1, "definition_id": "40kdc:11e:adeptus-astartes:rhino", "position": Vector2(0, 0), "radius": 2.36, "keywords": profile.keywords.duplicate(), "wounds": 0, "on_battlefield": true, "transport_profile": profile.transport.duplicate(true)},
		}
	}
	for index in range(5):
		var model := 200 + index
		state.units[model] = {"owner": 1, "squad": 2, "definition_id": "40kdc:11e:adeptus-astartes:assault-intercessor-squad", "position": Vector2(0, 0), "radius": 0.1, "keywords": ["ADEPTUS ASTARTES", "INFANTRY", "TACTICUS"], "wounds": 2, "max_wounds": 2, "on_battlefield": false, "embarked_transport": 100}
	return state

func submit_transport_choice(state: Dictionary, player: int, option_index: int, point: Vector2 = Vector2.ZERO) -> Dictionary:
	var decision := PendingDecisions.current(state, ["unit-actions"])
	var options: Array = decision.get("legal_options", [])
	if option_index < 0 or option_index >= options.size(): return {"error": "Requested Emergency Disembark option is not projected."}
	var option: Dictionary = options[option_index]
	var choice: Dictionary = {}
	for candidate: Dictionary in UnitActions.choices(state, player):
		if str(candidate.get("action", "")) == str(option.get("action", "")) and int(candidate.get("model", -1)) == int(option.get("model", -1)) and int(candidate.get("target", -1)) == int(option.get("target", -1)) and str(candidate.get("value", "")) == str(option.get("value", "")):
			choice = candidate
			break
	if choice.is_empty(): return {"error": "Emergency Disembark no longer offers the projected choice."}
	return MatchCommands.execute(state, player, {
		"kind": MatchCommands.SELECT_UNIT_CHOICE,
		"revision": int(state.get("revision", -1)),
		"point": point,
		"choice": {
			"_decision_type": MatchCommands.UNIT_CHOICE_ENVELOPE,
			"decision_id": str(decision.get("decision_id", "")),
			"option_id": str(option.get("id", "")),
			"choice": choice
		}
	}, func() -> int: return 6)

func run() -> void:
	var state := make_state()
	state.squads[2].embarked_in = 100
	state.squads[2].embarked_this_turn = 0
	var started := Combat._finish_pending_attack(state, func() -> int: return 1)
	check(started.error.is_empty() and not started.complete, "Destroying a transport opens its mandatory passenger Emergency Disembark before finishing destruction")
	check(state.unit_abilities.transport_window.stage == "hazard" and state.unit_abilities.transport_window.hazard_rolls == [1, 1, 1, 1, 1] and state.unit_abilities.window.get("kind", "") == Transport.EMERGENCY_WINDOW, "Emergency Disembark opens its registered reaction window and rolls one Hazard die per embarked model")
	check(state.unit_abilities.window.owners == [1], "The passenger owner allocates Hazard mortal wounds even when the opponent is the active player")
	var decision := PendingDecisions.current(state, ["unit-actions"])
	var attack_frame := ResolutionFrames.current(state)
	check(decision.get("source", "") == "unit-actions" and decision.get("priority_player_id", -1) == 1 and decision.get("resume_frame_id", "") == attack_frame.get("frame_id", ""), "Emergency Disembark exposes a passenger-owned normalized decision linked to the suspended attack")
	check(attack_frame.get("kind", "") == "attack" and attack_frame.get("status", "") == "suspended" and attack_frame.get("resume_point", "") == "attack-destroyed-model-reactions", "The suspended attack remains the authoritative continuation during emergency transport resolution")
	var before_wrong_owner := var_to_bytes(state)
	var wrong_owner := submit_transport_choice(state, 2, 0)
	check(not str(wrong_owner.get("error", "")).is_empty() and var_to_bytes(state) == before_wrong_owner, "Another player cannot submit the projected Emergency Disembark choice or mutate the suspended attack")
	var transport_window: Dictionary = state.unit_abilities.transport_window.duplicate(true)
	var restored: Dictionary = bytes_to_var(var_to_bytes(state))
	var restored_decision := PendingDecisions.current(restored, ["unit-actions"])
	var restored_frame := ResolutionFrames.current(restored)
	check(restored.unit_abilities.transport_window == transport_window and restored_decision.get("decision_id", "") == decision.get("decision_id", "") and restored_decision.get("resume_frame_id", "") == attack_frame.get("frame_id", "") and restored_frame.get("frame_id", "") == attack_frame.get("frame_id", ""), "Save and restore preserves the Emergency Disembark decision and exact suspended attack identity")
	check("transport" in PhaseCloseGate.close_request_error(restored, 2, restored.revision), "A restored Emergency Disembark allocation still blocks phase close")
	state = restored
	for _index in range(5):
		var options: Array = PendingDecisions.current(state, ["unit-actions"]).get("legal_options", [])
		check(not options.is_empty() and options[0].action == "transport-disembark-hazard-allocate", "Hazard failure requires a passenger mortal-wound allocation")
		if options.is_empty(): break
		var result := submit_transport_choice(state, 1, 0)
		check(str(result.get("error", "")).is_empty(), "Emergency Hazard mortal wound resolves through the normalized command and local Feel No Pain prevention: " + str(result))
	check(state.unit_abilities.transport_window.stage == "placement" and state.unit_abilities.window.owners == [2], "The active player takes over for Emergency Disembark placement after allocation")
	var placement_decision := PendingDecisions.current(state, ["unit-actions"])
	check(placement_decision.get("priority_player_id", -1) == 2 and placement_decision.get("resume_frame_id", "") == attack_frame.get("frame_id", ""), "Placement priority changes to the active player without losing the attack continuation")
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
		var options: Array = PendingDecisions.current(state, ["unit-actions"]).get("legal_options", [])
		var option_index := -1
		for option_position in range(options.size()):
			var option: Dictionary = options[option_position]
			if str(option.get("action", "")) == "transport-disembark-place" and int(option.get("model", -1)) == survivors[index]:
				option_index = option_position
				break
		var place_result := submit_transport_choice(state, 2, option_index, positions[index + 2])
		check(str(place_result.get("error", "")).is_empty(), "Emergency Disembark accepts a coherent, unengaged position within 6 inches through the normalized command: " + str(place_result))
	check(Transport.confirm_error(state).is_empty(), "All surviving models are placed in coherency")
	var confirm_options: Array = PendingDecisions.current(state, ["unit-actions"]).get("legal_options", [])
	var confirm_index := -1
	for option_position in range(confirm_options.size()):
		if str(confirm_options[option_position].get("action", "")) == "transport-disembark-confirm":
			confirm_index = option_position
			break
	var confirmed := submit_transport_choice(state, 2, confirm_index)
	check(str(confirmed.get("error", "")).is_empty(), "Emergency Disembark confirms through the normalized command and resumes the attack: " + str(confirmed))
	check(state.pending_deadly_demise.is_empty() and state.units[100].get("on_battlefield", true) == false, "The transport is removed only after passengers finish, then the destruction queue resumes")
	check(state.squads[2].battle_shocked and state.squads[2].get("cannot_charge_until_turn", -1) == 1 and state.units[survivors[0]].on_battlefield, "Emergency survivors are Battle-shocked, cannot charge this turn and return to the battlefield")
	check(ResolutionFrames.current(state).is_empty(), "Completing Emergency Disembark settles the suspended attack frame after its destruction effects")
	print("Marine transport destruction: %d failures" % failures)
	quit(1 if failures else 0)

func _initialize() -> void: call_deferred("run")
