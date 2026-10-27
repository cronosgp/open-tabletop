extends SceneTree
const Combat = preload("res://scripts/edition_11/combat_scenario.gd")
const Gate = preload("res://scripts/edition_11/phase_close_gate.gd")
const MatchCommandService = preload("res://scripts/edition_11/match_command_service.gd")
const DetachmentStratagems = preload("res://scripts/edition_11/detachment_stratagems.gd")
const ResolutionFrames = preload("res://scripts/edition_11/resolution_frame.gd")
var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func fixture() -> Dictionary:
	var state := Combat.initial_state()
	state.phase = "command"
	return state

func _initialize() -> void:
	var state := fixture()
	state.stratagems = {"pending": "malformed"}
	check(Combat.MatchActor.pending_state_error(state).contains("stratagem decision state is invalid"), "Shared match-state validation catches malformed pending decisions before actor projection")
	check(Combat.MatchActor.player(state) == -1, "Malformed pending decisions do not grant an action actor")
	state = fixture()
	state.deployment = "malformed"
	check(Combat.MatchActor.pending_state_error(state).contains("deployment decision state is invalid"), "Shared match-state validation catches malformed deployment state before actor projection")
	state = fixture()
	state.deployment = {"order": [1, 2], "index": 2, "complete": true}
	check(Combat.MatchActor.pending_state_error(state).is_empty() and Combat.MatchActor.player(state) == 1, "A completed deployment may retain its exhausted order index while battle progression continues")
	state.deployment.complete = false
	check(Combat.MatchActor.pending_state_error(state).contains("deployment order is invalid"), "An exhausted deployment order cannot be treated as complete when its completion flag is false")
	state = fixture()
	state.core_reactions = "malformed"
	check(Combat.MatchActor.pending_state_error(state).contains("reaction decision state is invalid"), "Shared match-state validation catches malformed core reaction state before actor projection")
	state = fixture()
	state.detachment_stratagems = "malformed"
	check(Combat.MatchActor.pending_state_error(state).contains("detachment reaction state is invalid"), "Shared match-state validation catches malformed detachment reaction state before actor projection")
	state = fixture()
	state.command_battle_shock = "malformed"
	check(Combat.MatchActor.pending_state_error(state).contains("Command Battle-shock decision state is invalid"), "Shared match-state validation catches malformed Command Battle-shock state before unit-action projection")
	state = fixture()
	state.fearsome_assault = "malformed"
	check(Combat.MatchActor.pending_state_error(state).contains("Fearsome Assault decision state is invalid"), "Shared match-state validation catches malformed Fearsome Assault state before unit-action projection")
	state = fixture()
	state.detachment_stratagems = {"adamantine_pending": "malformed"}
	check(Combat.MatchActor.pending_state_error(state).contains("detachment reaction state is invalid"), "Shared match-state validation catches malformed Adamantine Terror state before unit-action projection")
	state = fixture()
	state.pending_deadly_demise = "malformed"
	check("destruction resolution state is invalid" in Gate.command_error(state, 1, state.revision), "Commands reject malformed destruction state before resolving other gates")
	check("destruction resolution state is invalid" in Gate.close_request_error(state, 1, state.revision), "Phase close rejects malformed destruction state before resolving other gates")
	state = fixture()
	state.pending_hazard = "malformed"
	check("Hazardous allocation state is invalid" in Gate.command_error(state, 1, state.revision), "Commands reject malformed Hazardous allocation state")
	check("Hazardous allocation state is invalid" in Gate.close_request_error(state, 1, state.revision), "Phase close rejects malformed Hazardous allocation state")
	state = fixture()
	state.pending_attack = "malformed"
	check("damage allocation state is invalid" in Gate.command_error(state, 1, state.revision), "Commands reject malformed damage allocation state before projecting decisions")
	check("damage allocation state is invalid" in Gate.close_request_error(state, 1, state.revision), "Phase close rejects malformed damage allocation state")
	state = fixture()
	state.stratagems = {"pending": "malformed"}
	var malformed_stratagem_before := var_to_str(state)
	check("stratagem decision state is invalid" in Gate.command_error(state, 1, state.revision), "Commands reject a malformed stratagem window before projecting decisions")
	check("stratagem decision state is invalid" in Gate.close_request_error(state, 1, state.revision), "Phase close rejects malformed stratagem state before projection")
	var malformed_reaction := MatchCommandService.execute(state, 1, {"kind": MatchCommandService.COMMAND_REACTION, "revision": state.revision, "choice": {}})
	check("stratagem decision state is invalid" in str(malformed_reaction.get("error", "")), "The public reaction dispatcher rejects malformed stratagem state without reading its window")
	check(var_to_str(state) == malformed_stratagem_before, "Rejecting malformed stratagem state leaves the match unchanged")
	state = fixture()
	state.reanimation = {"pending": "malformed"}
	var malformed_reanimation_before := var_to_str(state)
	check("Reanimation state is invalid" in Gate.command_error(state, 1, state.revision), "Commands reject malformed Reanimation state before projecting decisions")
	check("Reanimation state is invalid" in Gate.close_request_error(state, 1, state.revision), "Phase close rejects malformed Reanimation state before projection")
	var malformed_reanimation := MatchCommandService.execute(state, 1, {"kind": MatchCommandService.RESOLVE_REANIMATION, "revision": state.revision, "choice": {}})
	check("Reanimation state is invalid" in str(malformed_reanimation.get("error", "")), "The public Reanimation dispatcher rejects malformed persisted state before reading its window")
	check(var_to_str(state) == malformed_reanimation_before, "Rejecting malformed Reanimation state leaves the match unchanged")
	state = fixture()
	state.combat_doctrines = "malformed"
	var malformed_doctrine := MatchCommandService.execute(state, 1, {"kind": MatchCommandService.SELECT_DOCTRINE, "revision": state.revision, "doctrine": "none"})
	check("combat doctrines decision state is invalid" in str(malformed_doctrine.get("error", "")), "The doctrine dispatcher rejects malformed state before decision projection")
	state = fixture()
	state.oath_of_moment = "malformed"
	var malformed_oath := MatchCommandService.execute(state, 1, {"kind": MatchCommandService.SELECT_OATH_TARGET, "revision": state.revision, "target": -1})
	check("oath of moment decision state is invalid" in str(malformed_oath.get("error", "")), "The Oath dispatcher rejects malformed state before decision projection")
	state = fixture()
	state.awakened_dynasty = "malformed"
	var malformed_attachment := MatchCommandService.execute(state, 1, {"kind": MatchCommandService.SELECT_AWAKENED_ATTACHMENT, "revision": state.revision, "bodyguard": -1})
	check("awakened attachment decision state is invalid" in str(malformed_attachment.get("error", "")), "The attachment dispatcher rejects malformed state before decision projection")
	state = fixture()
	state.mission = "malformed"
	var malformed_mission := MatchCommandService.execute(state, 1, {"kind": MatchCommandService.SELECT_UNIT_CHOICE, "revision": state.revision, "choice": {"action": "pass"}})
	check("mission preparation decision state is invalid" in str(malformed_mission.get("error", "")), "The unit-choice dispatcher rejects malformed mission state before projection")
	state = fixture()
	state.unit_abilities = "malformed"
	check("unit ability state is invalid" in Gate.close_request_error(state, 1, state.revision), "Phase close validates unit ability state before reading transport or detection windows")
	state = fixture()
	Combat.UnitAbilities.enable(state)
	state.unit_abilities.reserves = "malformed"
	check(Combat.MatchActor.pending_state_error(state).contains("unit ability state is invalid") and Combat.MatchActor.player(state) == -1, "Malformed reserve maps fail closed before actor or Rapid Ingress projection")
	state = fixture()
	Combat.UnitAbilities.enable(state)
	state.unit_abilities.transport_window = "malformed"
	check("transport resolution state is invalid" in Gate.close_request_error(state, 1, state.revision), "Phase close validates transport state before querying its pending window")
	state = fixture()
	state.pending_deadly_demise = {"queue": [100], "queue_cursor": 0, "transport_queue": [], "transport_cursor": 0, "packets": [], "packet_cursor": 0}
	check("destruction effects" in Gate.command_error(state, 1, state.revision), "An unresolved destruction chain blocks commands even if its decision window is missing")
	check("destruction effects" in Gate.close_request_error(state, 1, state.revision), "An unresolved destruction chain blocks phase close even if its decision window is missing")
	var restored_destruction: Dictionary = bytes_to_var(var_to_bytes(state))
	check("destruction effects" in Gate.close_request_error(restored_destruction, 1, restored_destruction.revision), "A restored destruction chain still blocks phase close without relying on its visible choice window")
	state = fixture()
	check(Gate.close_request_error(state, 1, state.revision).is_empty(), "An authorized command can request phase close when no work is pending")
	state.phase = "movement"
	var no_choice_close_error := Combat.advance_phase(state, 1, state.revision)
	check(no_choice_close_error.is_empty() and state.phase == "shooting", "A phase with no eligible choices advances automatically")
	check(ResolutionFrames.current(state).is_empty(), "A no-choice phase close completes its temporary continuation frame")
	state = fixture()
	var suspended_action := ResolutionFrames.begin(state, "unit-action", "movement:1:1:command", "movement-reaction")
	ResolutionFrames.suspend(state, str(suspended_action.frame_id), "movement-reaction")
	check("pending action or decision" in Gate.command_error(state, 1, state.revision), "An unresolved action frame blocks unrelated commands even when its specialized pending record is missing")
	check("suspended action" in Gate.close_request_error(state, 1, state.revision), "An unresolved action frame blocks phase close even when its specialized pending record is missing")
	state.resolution_frames = [{"kind": "phase-close", "action_id": "phase-close:1:command", "status": "suspended"}]
	check("active resolution frame is invalid" in Gate.command_error(state, 1, state.revision), "A malformed resolution-frame stack blocks unrelated commands")
	check("active resolution frame is invalid" in Gate.close_request_error(state, 1, state.revision), "A partial phase-close frame cannot bypass the close gate")
	state.resolution_frames = []
	var close_frame := ResolutionFrames.begin(state, "phase-close", "phase-close:1:command", "resume")
	ResolutionFrames.suspend(state, str(close_frame.frame_id), "resume")
	check("pending action or decision" in Gate.command_error(state, 1, state.revision), "A valid phase-close continuation still blocks unrelated commands")
	check(not close_frame.is_empty() and Gate.close_request_error(state, 1, state.revision).is_empty(), "The matching phase-close continuation can re-enter the gate to resume")
	ResolutionFrames.complete(state, str(close_frame.frame_id))
	check("action window" in Gate.command_error(state, 2, state.revision), "A player without command priority cannot act")
	check("State changed" in Gate.command_error(state, 1, state.revision - 1), "A stale revision is rejected before command execution")
	state = fixture()
	state.phase = "movement"
	state.pending_move = {"squad": 1}
	check("pending movement" in Gate.command_error(state, 1, state.revision), "An orphaned movement draft blocks unrelated commands even without its frame")
	check(Gate.command_error(state, 1, state.revision, "movement:%d:%d:%s" % [state.turn, 1, state.phase]).is_empty(), "Admission allows only the matching Movement continuation for an older draft")
	state = fixture()
	state.phase = "charge"
	state.pending_charge = {"squad": 1}
	check("pending Charge" in Gate.command_error(state, 1, state.revision), "An orphaned rolled Charge blocks unrelated commands even without its frame")
	check(Gate.command_error(state, 1, state.revision, "charge:%d:%d:%s" % [state.turn, 1, state.phase]).is_empty(), "Admission allows only the matching Charge continuation for an older roll")
	state = fixture()
	state.phase = "movement"
	Combat.UnitAbilities.enable(state)
	Combat.Stratagems.enable(state)
	Combat.CoreReactions.enable(state)
	state.core_reactions.overwatch = {"phase_key": Combat.CoreReactions.phase_key(state), "player": 2}
	var reaction_close_frame := ResolutionFrames.begin(state, "phase-close", "phase-close:%d:%s" % [state.turn, state.phase], "core-reaction")
	ResolutionFrames.suspend(state, str(reaction_close_frame.frame_id), "core-reaction")
	check("pending action or decision" in Gate.command_error(state, 2, state.revision), "Core reaction ownership alone cannot admit an unrelated command through an active frame")
	check(Gate.command_error(state, 2, state.revision, str(reaction_close_frame.action_id)).is_empty(), "A matching phase-close identity can authorize a validated reaction continuation")
	state = fixture()
	state.phase = "fight"
	state.pending_contact = {"kind": "pile_in", "squad": 1, "resolution_action_id": "contact:%d:%s:%d:%s" % [state.turn, state.phase, 1, "pile_in"]}
	check("pending contact movement" in Gate.command_error(state, 1, state.revision), "An orphaned contact draft blocks unrelated commands even without its frame")
	check(Gate.command_error(state, 1, state.revision, str(state.pending_contact.resolution_action_id)).is_empty(), "Admission allows only the matching contact continuation for an older draft")

	state.pending_contact = {"squad": 1}
	check("contact movement" in Gate.close_request_error(state, 1, state.revision), "Contact movement blocks phase close until confirmed or cancelled")
	state.pending_contact = "malformed"
	check("contact movement state is invalid" in Combat.finish_contact_move(state, 1, state.revision), "Contact handlers reject malformed drafts before reading their fields")
	check("contact movement state is invalid" in Gate.close_request_error(state, 1, state.revision), "Phase close rejects malformed contact drafts before reading their fields")
	state = fixture()
	state.pending_move = {"squad": 1}
	check("movement" in Gate.close_request_error(state, 1, state.revision), "Squad movement blocks phase close until confirmed or cancelled")
	state.phase = "movement"
	state.pending_move = "malformed"
	check("movement state is invalid" in Combat.finish_movement(state, 1, state.revision), "Movement handlers reject malformed drafts before reading their fields")
	check("movement state is invalid" in Gate.close_request_error(state, 1, state.revision), "Phase close rejects malformed movement drafts before reading their fields")
	state.phase = "charge"
	state.pending_move = {}
	state.pending_charge = "malformed"
	check("Charge state is invalid" in Combat.decline_charge(state, 1, state.revision), "Charge handlers reject malformed rolls before reading their fields")
	check("Charge state is invalid" in Gate.close_request_error(state, 1, state.revision), "Phase close rejects malformed Charge drafts before reading their fields")
	state = fixture()
	Combat.UnitAbilities.enable(state)
	state.unit_abilities.transport_window = {"kind": "disembark", "stage": "placement", "player": 1}
	check("transport" in Gate.command_error(state, 1, state.revision), "An orphaned transport window blocks ordinary commands even when its mirrored choice projection is absent")
	check("transport" in Gate.close_request_error(state, 1, state.revision), "Pending transport placement blocks phase close")
	var restored_transport: Dictionary = bytes_to_var(var_to_bytes(state))
	check("transport" in Gate.command_error(restored_transport, 1, restored_transport.revision), "A restored orphaned transport window still blocks ordinary commands")
	state = fixture()
	Combat.UnitAbilities.enable(state)
	state.unit_abilities.window = {"kind": "unprojected-choice"}
	var invalid_choice_before := var_to_str(state)
	check("invalid pending unit ability" in Gate.command_error(state, 1, state.revision), "A malformed ability window without an owner fails closed for ordinary commands")
	check("invalid pending unit ability" in Gate.close_request_error(state, 1, state.revision), "A malformed ability window without an owner fails closed for phase close")
	check(var_to_str(state) == invalid_choice_before, "Rejecting an unprojected choice leaves the match unchanged")
	state.unit_abilities.window = {"kind": "unrecognized-choice", "owners": [1]}
	check(Combat.UnitActions.choices(state, 1).is_empty(), "An unknown ability-window kind does not become a generic decline option")
	check("invalid pending unit ability" in Gate.command_error(state, 1, state.revision), "An ability window without a supported choice projection fails closed for ordinary commands")
	check("invalid pending unit ability" in Gate.close_request_error(state, 1, state.revision), "An ability window without a supported choice projection fails closed for phase close")
	state.unit_abilities.window = "malformed"
	var malformed_window_command := MatchCommandService.execute(state, 1, {"kind": MatchCommandService.SELECT_UNIT_CHOICE, "revision": state.revision, "choice": {"action": "pass"}})
	check("unit ability choice state is invalid" in str(malformed_window_command.get("error", "")), "The public unit-choice command rejects a malformed window before projecting decisions")
	check(typeof(state.unit_abilities.window) == TYPE_STRING and state.unit_abilities.window == "malformed", "The rejected public command leaves malformed unit-choice state untouched")
	state.unit_abilities.window = {"kind": "end", "owners": "malformed"}
	var malformed_owners_command := MatchCommandService.execute(state, 1, {"kind": MatchCommandService.SELECT_UNIT_CHOICE, "revision": state.revision, "choice": {"action": "pass"}})
	check("invalid pending unit ability" in str(malformed_owners_command.get("error", "")), "The public unit-choice command rejects malformed decision owners before projection")
	state.unit_abilities.window.owners = [3]
	check("invalid pending unit ability" in Gate.command_error(state, 1, state.revision), "An ability window with an invalid player owner also fails closed")
	state.unit_abilities.window.owners = [1, 3]
	var mixed_owners_before := var_to_str(state)
	check("invalid pending unit ability" in Gate.command_error(state, 1, state.revision), "A mixed valid and invalid owner list fails closed for commands")
	check("invalid pending unit ability" in Gate.close_request_error(state, 1, state.revision), "A mixed valid and invalid owner list fails closed for phase close")
	check(var_to_str(state) == mixed_owners_before, "Rejecting a mixed-owner window leaves match state unchanged")
	state.unit_abilities.window.owners = [1, 1]
	check("invalid pending unit ability" in Gate.command_error(state, 1, state.revision), "Duplicate decision owners fail closed")
	state.unit_abilities.window = {"owners": [1]}
	check("invalid pending unit ability" in Gate.command_error(state, 1, state.revision), "An ability window without a decision kind fails closed")
	state = fixture()
	Combat.UnitAbilities.enable(state)
	state.phase = "movement"
	state.unit_abilities.window = {"kind": "end", "owners": [2]}
	var pending_choice_before := var_to_str(state)
	var pending_choice := Combat.UnitActions.pending_decision(state)
	var advance_error := Combat.advance_phase(state, 2, int(state.revision))
	check(pending_choice.priority_player_id == 2 and Combat.actor(state) == 2, "The opponent owns an open end-of-phase decision window")
	check(not advance_error.is_empty() and "unit ability choices" in advance_error, "The current phase cannot advance before the opponent resolves or declines its choice")
	check(var_to_str(state) == pending_choice_before, "A blocked phase-close request leaves the match state unchanged")
	state = fixture()
	state.phase = "charge"
	state.pending_charge = {"squad": 1}
	check("rolled charge" in Gate.close_request_error(state, 1, state.revision), "A rolled charge blocks phase close until resolved or declined")
	state = fixture()
	state.pending_attack = {"squad": 1}
	var pending_attack_before := var_to_str(state)
	check("damage allocation" in Gate.close_request_error(state, 1, state.revision), "Pending attack damage allocation blocks phase close")
	check(var_to_str(state) == pending_attack_before, "A blocked attack-allocation close request leaves the match state unchanged")
	var restored_attack: Dictionary = bytes_to_var(var_to_bytes(state))
	check("damage allocation" in Gate.close_request_error(restored_attack, 1, restored_attack.revision), "Serialized pending attack allocation continues to block phase close")
	state = fixture()
	state.pending_hazard = {"squad": 1}
	var pending_hazard_before := var_to_str(state)
	check("Hazardous mortal-wound allocation" in Gate.close_request_error(state, 1, state.revision), "Pending Hazardous allocation blocks phase close")
	check(var_to_str(state) == pending_hazard_before, "A blocked Hazardous close request leaves the match state unchanged")
	var restored_hazard: Dictionary = bytes_to_var(var_to_bytes(state))
	check("Hazardous mortal-wound allocation" in Gate.close_request_error(restored_hazard, 1, restored_hazard.revision), "Serialized Hazardous allocation continues to block phase close")

	state = fixture()
	Combat.UnitAbilities.enable(state)
	Combat.Stratagems.enable(state)
	Combat.CoreReactions.enable(state)
	state.phase = "movement"
	state.core_reactions.overwatch = {"phase_key": Combat.CoreReactions.phase_key(state), "player": 2}
	check("Fire Overwatch" in Gate.close_request_error(state, 2, state.revision), "An eligible Core reaction blocks phase close")
	state = fixture()
	state.phase = "shooting"
	DetachmentStratagems.enable_devastator_brethren(state)
	state.detachment_stratagems.hail_of_vengeance_pending = {"phase_key": DetachmentStratagems.phase_key(state), "player": 2, "attacker": 1, "victims": [2]}
	check(DetachmentStratagems.vengeful_actor(state) == 2, "Reactive shooting transfers command priority to the opponent")
	var before_reactive_close := var_to_str(state)
	check("unit ability choices" in Gate.close_request_error(state, 2, state.revision), "The normalized reactive shooting decision blocks phase close until resolved")
	check(var_to_str(state) == before_reactive_close, "A blocked reactive close request leaves the match state unchanged")
	state = fixture()
	state.phase = "movement"
	state.cp[1] = 3
	Combat.Stratagems.enable(state, true)
	state.stratagems.pending = {"kind": "after_advance_roll", "player": 1, "squad": 1, "phase_key": Combat.Stratagems.phase_key(state), "rolls": [4], "draft": {"squad": 1}}
	var stratagem_decision := Combat.Stratagems.pending_decision(state)
	var before_stratagem_close := var_to_str(state)
	check(not stratagem_decision.is_empty() and Combat.actor(state) == 1, "The current roll reaction projection supplies command priority")
	check("pending decision" in Gate.close_request_error(state, 1, state.revision), "A projected roll reaction blocks phase close")
	check(var_to_str(state) == before_stratagem_close, "A blocked projected reaction leaves the match state unchanged")
	state = fixture()
	state.phase = "unknown"
	check("unknown phase" in Gate.progression_error(state), "Unknown phases cannot pass the progression gate")
	state = fixture()
	state.phase = "end_turn"
	state.units[100].position += Vector2(20, 0)
	check("coherency casualties" in Gate.progression_error(state), "An incoherent squad blocks turn close until casualties are selected")

	print("Phase-close gate checks: %d failures" % failures)
	quit(0 if failures == 0 else 1)
