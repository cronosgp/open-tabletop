extends RefCounted
## Deterministic turn and phase sequencing. Rule effects stay in the match orchestrator.

## Player-facing phases in the current match loop.
const PHASES := ["command", "movement", "shooting", "charge", "fight"]
## Internal progression steps retained in the serialized `phase` field for now.
## These are bookkeeping boundaries, not selectable or player-facing phases.
const PROGRESSION_STEPS := ["start_turn", "command", "movement", "shooting", "charge", "fight", "end_turn"]
const PRE_BATTLE := "pre_battle"

static func is_player_phase(phase: String) -> bool:
	return phase in PHASES

static func contains(phase: String) -> bool:
	return phase == PRE_BATTLE or phase in PROGRESSION_STEPS

static func ends_turn(phase: String) -> bool:
	return phase == "end_turn"

## Advance only the progression fields. Callers resolve phase-specific effects first.
static func advance(state: Dictionary) -> String:
	var current := str(state.get("phase", ""))
	if current == PRE_BATTLE:
		state.phase = PROGRESSION_STEPS[0]
		return ""
	var index := PROGRESSION_STEPS.find(current)
	if index < 0: return "Cannot advance an unknown phase: %s." % current
	if index < PROGRESSION_STEPS.size() - 1:
		state.phase = PROGRESSION_STEPS[index + 1]
		return ""

	state.active = 3 - int(state.active)
	state.turn = int(state.get("turn", 0)) + 1
	if state.active == state.get("first_player", 1): state.round = int(state.get("round", 0)) + 1
	state.phase = PROGRESSION_STEPS[0]
	_reset_turn_state(state)
	return ""

static func _reset_turn_state(state: Dictionary) -> void:
	for squad: int in state.get("squads", {}):
		state.squads[squad].set_up_this_turn = false
		state.squads[squad].moved = false
		state.squads[squad].shot = false
		state.squads[squad].moved_distance = 0.0
		state.squads[squad].charge_declared = false
		state.squads[squad].charged = false
		state.squads[squad].move_type = "unselected"
		state.squads[squad].advanced = false
		state.squads[squad].fell_back = false
		state.squads[squad].normal_moved_this_turn = false
	for id: int in state.get("units", {}): state.units[id].moved = false
