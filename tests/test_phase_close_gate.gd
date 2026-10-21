extends SceneTree
const Combat = preload("res://scripts/edition_11/combat_scenario.gd")
const Gate = preload("res://scripts/edition_11/phase_close_gate.gd")
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
	check(Gate.close_request_error(state, 1, state.revision).is_empty(), "An authorized command can request phase close when no work is pending")
	var suspended_action := ResolutionFrames.begin(state, "unit-action", "movement:1:1:command", "movement-reaction")
	ResolutionFrames.suspend(state, str(suspended_action.frame_id), "movement-reaction")
	check("suspended action" in Gate.close_request_error(state, 1, state.revision), "An unresolved action frame blocks phase close even when its specialized pending record is missing")
	state.resolution_frames = [{"kind": "phase-close", "action_id": "phase-close:1:command", "status": "suspended"}]
	check("active resolution frame is invalid" in Gate.close_request_error(state, 1, state.revision), "A partial phase-close frame cannot bypass the close gate")
	state.resolution_frames = []
	var close_frame := ResolutionFrames.begin(state, "phase-close", "phase-close:1:command", "resume")
	check(not close_frame.is_empty() and Gate.close_request_error(state, 1, state.revision).is_empty(), "The matching phase-close continuation can re-enter the gate to resume")
	ResolutionFrames.complete(state, str(close_frame.frame_id))
	check("action window" in Gate.command_error(state, 2, state.revision), "A player without command priority cannot act")
	check("State changed" in Gate.command_error(state, 1, state.revision - 1), "A stale revision is rejected before command execution")

	state.pending_contact = {"squad": 1}
	check("contact movement" in Gate.close_request_error(state, 1, state.revision), "Contact movement blocks phase close until confirmed or cancelled")
	state = fixture()
	state.pending_move = {"squad": 1}
	check("movement" in Gate.close_request_error(state, 1, state.revision), "Squad movement blocks phase close until confirmed or cancelled")
	state = fixture()
	Combat.UnitAbilities.enable(state)
	state.unit_abilities.transport_window = {"kind": "disembark", "stage": "placement", "player": 1}
	check("transport" in Gate.close_request_error(state, 1, state.revision), "Pending transport placement blocks phase close")
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
	check("reactive shooting" in Gate.close_request_error(state, 2, state.revision), "A reactive shooting opportunity blocks phase close until resolved")
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
