extends SceneTree

const Combat = preload("res://scripts/edition_11/combat_scenario.gd")
const PendingDecision = preload("res://scripts/edition_11/pending_decision.gd")

var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func _initialize() -> void:
	var state := Combat.initial_state()
	state.phase = "movement"
	Combat.UnitAbilities.enable(state)
	state.match_manifest = {"rules_implementation": "ruleset-test-v1"}
	state.unit_abilities.window = {"kind": "end", "owners": [2], "resume_window": {"kind": "phase-close"}}
	var before := var_to_str(state)
	var decision := Combat.UnitActions.phase_decision(state)
	var repeated := Combat.UnitActions.phase_decision(state)
	check(not decision.is_empty() and decision.schema_version == 1, "End-of-phase pending choice is projected to the shared decision schema")
	check(decision.priority_player_id == 2 and decision.source == "unit-actions" and decision.timing == "end-phase:movement", "Decision keeps the authorized owner, source and rules timing")
	check(decision.pass_allowed and decision.close_policy == "pass-or-select", "Optional end-of-phase effects allow an explicit pass")
	check(decision.rules_profile_id == "warhammer-40k-11e" and decision.rules_profile_version == "ruleset-test-v1", "Decision separates its rules profile from the implementation version")
	check(decision.source_event_id == null, "Projection does not invent a domain event ID from the state revision")
	check(decision.resume_frame_id == null, "Projection does not invent an ID for an unpersisted resume frame")
	check(decision.legal_options.any(func(option: Dictionary) -> bool: return option.action == "pass"), "The common option list includes the server-computed pass option")
	check(decision.decision_id == repeated.decision_id and var_to_str(state) == before, "Decision identity is stable while read-only projection leaves state untouched")
	check(Combat.actor(state) == decision.priority_player_id, "Command priority consumes the normalized end-of-phase decision owner")
	state.revision += 1
	var next_revision_decision := Combat.UnitActions.phase_decision(state)
	check(next_revision_decision.decision_id != decision.decision_id, "A new match revision receives a distinct decision identity")
	state.unit_abilities.window = {"kind": "start", "owners": [2]}
	var start_decision := Combat.UnitActions.phase_decision(state)
	check(start_decision.timing == "start-phase:movement" and start_decision.priority_player_id == 2, "Phase-start ability windows use the same normalized decision contract")
	check(start_decision.pass_allowed and start_decision.legal_options.any(func(option: Dictionary) -> bool: return option.action == "pass"), "Phase-start optional effects expose the same explicit pass behavior")
	for phase: String in ["command", "movement", "shooting", "charge", "fight"]:
		for kind: String in ["start", "end"]:
			for owner: int in [1, 2]:
				var probe := state.duplicate(true)
				probe.phase = phase
				probe.unit_abilities.window = {"kind": kind, "owners": [owner]}
				var snapshot := var_to_str(probe)
				var projected := Combat.UnitActions.pending_decision(probe)
				check(not projected.is_empty() and Combat.actor(probe) == projected.priority_player_id, "Phase ownership agrees with the complete projection for %s/%s/P%d" % [phase, kind, owner])
				check(var_to_str(probe) == snapshot, "Priority queries do not mutate a phase window or its options")
	var malformed := state.duplicate(true)
	malformed.unit_abilities.window = {"kind": "end", "owners": [3]}
	check(Combat.actor(malformed) == -1, "The phase-owner shortcut cannot bypass invalid-owner admission")
	malformed.unit_abilities.window = {"kind": "unknown-phase-window", "owners": [2]}
	check(Combat.actor(malformed) == -1, "An unknown window still fails closed before priority projection")
	state.unit_abilities.window = {"kind": "bladeguard", "owners": [2], "remaining": [1]}
	var specialized_decision := Combat.UnitActions.pending_decision(state)
	check(specialized_decision.source == "unit-actions" and specialized_decision.timing == "movement:bladeguard", "Specialized ability windows use the shared decision projection")
	check(specialized_decision.priority_player_id == 2 and specialized_decision.pass_allowed, "The projection carries the ability owner and explicit decline option")
	check(specialized_decision.legal_options.any(func(option: Dictionary) -> bool: return option.action == "bladeguard" and option.value == "attack"), "The projection exposes rule-computed ability options")
	check(Combat.actor(state) == specialized_decision.priority_player_id, "Command priority uses the shared projection for specialized ability windows")
	var doctrine_state: Dictionary = state.duplicate(true)
	doctrine_state.phase = "command"
	Combat.Doctrines.enable(doctrine_state)
	var doctrine_decision := Combat.Doctrines.pending_decision(doctrine_state)
	check(not doctrine_decision.is_empty() and doctrine_decision.source == "combat-doctrines", "Combat Doctrine setup choices use the shared decision projection")
	check(doctrine_decision.priority_player_id == doctrine_state.active and not doctrine_decision.pass_allowed and doctrine_decision.close_policy == "select-required", "Doctrine choice is required and remains owned by the active Marine player")
	check(doctrine_decision.legal_options.any(func(option: Dictionary) -> bool: return option.value == "none") and doctrine_decision.legal_options.any(func(option: Dictionary) -> bool: return option.value in Combat.Doctrines.ORDER), "Doctrine projection exposes only no-doctrine and currently available choices")
	check(Combat.actor(doctrine_state) == doctrine_decision.priority_player_id, "Match command priority consumes the normalized doctrine decision owner")
	doctrine_state.unit_abilities.window = {"kind": "start", "owners": [2]}
	check(Combat.actor(doctrine_state) == doctrine_decision.priority_player_id, "Combat Doctrine retains priority over a phase-start unit window")
	check(PendingDecision.create(state, "", "end-phase:movement", 2, [{"action": "pass"}], true).is_empty(), "Malformed decision envelopes fail closed")

	print("Pending decision checks: %d failures" % failures)
	quit(0 if failures == 0 else 1)
