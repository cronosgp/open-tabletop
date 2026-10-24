extends SceneTree
const F = preload("res://tests/all_units_fixture.gd")
const Combat = preload("res://scripts/edition_11/combat_scenario.gd")
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const UnitAbilities = preload("res://scripts/edition_11/unit_abilities.gd")
const Transport = preload("res://scripts/edition_11/transport_rules.gd")
const PendingDecisions = preload("res://scripts/edition_11/pending_decision_registry.gd")
const MatchCommands = preload("res://scripts/edition_11/match_command_service.gd")
const PhaseCloseGate = preload("res://scripts/edition_11/phase_close_gate.gd")
const ResolutionFrames = preload("res://scripts/edition_11/resolution_frame.gd")
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

func submit_choice(state: Dictionary, player: int, choice: Dictionary) -> Dictionary:
	var decision := PendingDecisions.current(state, ["unit-actions"])
	if decision.is_empty(): return {"error": "No Repulsor Combat Embarkation decision is pending."}
	var projected: Dictionary = {}
	for option: Dictionary in decision.get("legal_options", []):
		if str(option.get("action", "")) == str(choice.get("action", "")) and int(option.get("model", -1)) == int(choice.get("model", -1)) and int(option.get("target", -1)) == int(choice.get("target", -1)) and str(option.get("value", "")) == str(choice.get("value", "")):
			projected = option
			break
	if projected.is_empty(): return {"error": "The current Repulsor decision does not offer this choice."}
	return MatchCommands.execute(state, player, {"kind": MatchCommands.SELECT_UNIT_CHOICE, "revision": int(state.get("revision", -1)), "choice": {"_decision_type": MatchCommands.UNIT_CHOICE_ENVELOPE, "decision_id": str(decision.get("decision_id", "")), "option_id": str(projected.get("id", "")), "choice": choice}}, func() -> int: return 6)

func run() -> void:
	var state := make_state()
	check(Transport._combat_embarkation_candidates(state, 2).size() == 1 and Transport._combat_embarkation_candidates(state, 2)[0].passenger_squad == 2, "Repulsor offers only the unengaged, in-range, datasheet-eligible Astartes target")
	state.squads[2].set_up_this_turn = true
	check(Transport._combat_embarkation_candidates(state, 2).is_empty(), "A unit set up this turn is not eligible to embark in response to a charge")
	state.squads[2].set_up_this_turn = false
	var begin_result := MatchCommands.execute(state, 1, {"kind": MatchCommands.BEGIN_CONTACT, "model": 100, "move_kind": "charge", "revision": state.revision})
	var begin_error := str(begin_result.get("error", ""))
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
	var decision := PendingDecisions.current(state, ["unit-actions"])
	check(decision.get("priority_player_id", -1) == 2 and not decision.is_empty(), "Normalized Repulsor reaction belongs to the defending player")
	var charge_frame := ResolutionFrames.current(state)
	var saved_charge: Dictionary = bytes_to_var(var_to_bytes(state))
	var restored_charge_frame := ResolutionFrames.current(saved_charge)
	var restored_decision := PendingDecisions.current(saved_charge, ["unit-actions"])
	check(charge_frame.get("kind", "") == "unit-action" and charge_frame.get("status", "") == "suspended" and charge_frame.get("resume_point", "") == "charge-target-reaction" and decision.get("resume_frame_id", "") == charge_frame.get("frame_id", ""), "Repulsor response is linked to the suspended charge-placement continuation")
	check(restored_charge_frame == charge_frame and restored_decision.get("decision_id", "") == decision.get("decision_id", "") and restored_decision.get("legal_options", []) == decision.get("legal_options", []) and restored_decision.get("resume_frame_id", "") == charge_frame.get("frame_id", ""), "Repulsor decision and charge continuation preserve their identities through save/restore")
	state = saved_charge
	options = Combat.unit_choices(state, 2)
	embark_options = options.filter(func(option: Dictionary) -> bool: return option.action == "repulsor-combat-embarkation-embark")
	pass_options = options.filter(func(option: Dictionary) -> bool: return option.action == "repulsor-combat-embarkation-pass")
	decision = PendingDecisions.current(state, ["unit-actions"])
	embark = embark_options[0]
	decline = pass_options[0]
	var before_wrong_owner := var_to_bytes(state)
	var wrong_owner := submit_choice(state, 1, embark)
	check(not str(wrong_owner.get("error", "")).is_empty() and before_wrong_owner == var_to_bytes(state), "Charging player cannot mutate the Repulsor response")
	var stale_option: Dictionary = decision.legal_options.filter(func(option: Dictionary) -> bool: return option.action == embark.action and option.target == embark.target)[0]
	var stale_command_choice := {"_decision_type": MatchCommands.UNIT_CHOICE_ENVELOPE, "decision_id": str(decision.decision_id), "option_id": "stale-option", "choice": embark}
	var stale_option_before := var_to_bytes(state)
	var stale_option_result := MatchCommands.execute(state, 2, {"kind": MatchCommands.SELECT_UNIT_CHOICE, "revision": state.revision, "choice": stale_command_choice})
	check(not stale_option.is_empty() and not str(stale_option_result.get("error", "")).is_empty() and stale_option_before == var_to_bytes(state), "Repulsor response rejects an obsolete option ID without mutation")
	check(not PhaseCloseGate.close_request_error(state, 1, state.revision).is_empty(), "Charge phase close remains blocked while the transport response is pending")
	var passed := state.duplicate(true)
	var pass_result := submit_choice(passed, 2, decline)
	check(str(pass_result.get("error", "")).is_empty(), "Defender can pass on the optional Repulsor reaction")
	check(passed.unit_abilities.window.is_empty() and passed.pending_charge.combat_embarkation_resolved and passed.units[200].on_battlefield and ResolutionFrames.current(passed).get("frame_id", "") == charge_frame.get("frame_id", "") and ResolutionFrames.current(passed).get("status", "") == "suspended", "Passing closes the reaction without changing its target or charge continuation")
	var embark_result := submit_choice(state, 2, embark)
	check(str(embark_result.get("error", "")).is_empty(), "Defender can embark the selected charge target in its Repulsor")
	check(not state.units[200].on_battlefield and state.units[200].embarked_transport == 9000 and state.pending_charge.targets == [4] and ResolutionFrames.current(state).get("frame_id", "") == charge_frame.get("frame_id", "") and ResolutionFrames.current(state).get("status", "") == "suspended", "Embarking removes the target while preserving the charge continuation")
	var invalid_embarked_target := MatchCommands.execute(state, 1, {"kind": MatchCommands.CHARGE_TARGET, "target": 200, "revision": state.revision})
	check(not str(invalid_embarked_target.get("error", "")).is_empty(), "An embarked unit cannot be reselected as a charge target")
	var revised_target := MatchCommands.execute(state, 1, {"kind": MatchCommands.CHARGE_TARGET, "target": 300, "revision": state.revision})
	check(str(revised_target.get("error", "")).is_empty(), "Charging unit can select a new target through the public command")
	var revised_placement := MatchCommands.execute(state, 1, {"kind": MatchCommands.BEGIN_CONTACT, "model": 100, "move_kind": "charge", "revision": state.revision})
	check(str(revised_placement.get("error", "")).is_empty() and not state.pending_contact.is_empty() and state.unit_abilities.window.is_empty() and ResolutionFrames.current(state).get("frame_id", "") == charge_frame.get("frame_id", "") and ResolutionFrames.current(state).get("status", "") == "suspended" and ResolutionFrames.current(state).get("resume_point", "") == "charge-placement", "Resolved reaction does not repeat; the same charge frame resumes and suspends again for placement")
	print("Repulsor Combat Embarkation: %d failures" % failures)
	quit(1 if failures else 0)

func _initialize() -> void: call_deferred("run")
