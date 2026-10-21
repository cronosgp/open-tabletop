extends SceneTree

const Progression = preload("res://scripts/edition_11/phase_progression.gd")
var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func _initialize() -> void:
	check(Progression.PHASES == ["command", "movement", "shooting", "charge", "fight"], "The public phase list contains only player-facing battle phases")
	check(Progression.is_player_phase("movement") and not Progression.is_player_phase("start_turn") and not Progression.is_player_phase("end_turn"), "Turn-boundary bookkeeping is not exposed as a player-facing phase")
	check(Progression.contains("start_turn") and Progression.contains("end_turn") and Progression.contains("pre_battle"), "Internal progression tokens remain valid for existing match state")
	var ordinary := {"phase": "movement", "active": 1, "turn": 1, "round": 1, "first_player": 1}
	check(Progression.advance(ordinary).is_empty() and ordinary.phase == "shooting" and ordinary.turn == 1 and ordinary.active == 1, "Ordinary phase advance changed turn ownership")
	var pre_battle := {"phase": "pre_battle", "active": 1, "turn": 1, "round": 1, "first_player": 1}
	check(Progression.advance(pre_battle).is_empty() and pre_battle.phase == "start_turn" and pre_battle.turn == 1, "Pre-battle completion should enter the first turn without rolling it over")

	var end_first_turn := {"phase": "end_turn", "active": 1, "turn": 1, "round": 1, "first_player": 1,
		"squads": {1: {"set_up_this_turn": true, "moved": true, "shot": true, "moved_distance": 4.0, "charge_declared": true, "charged": true, "move_type": "advance", "advanced": true, "fell_back": true, "normal_moved_this_turn": true}},
		"units": {10: {"moved": true}}}
	check(Progression.advance(end_first_turn).is_empty() and end_first_turn.phase == "start_turn" and end_first_turn.active == 2 and end_first_turn.turn == 2 and end_first_turn.round == 1, "Turn rollover advanced the wrong player or round")
	check(not end_first_turn.squads[1].moved and not end_first_turn.squads[1].shot and end_first_turn.squads[1].move_type == "unselected" and not end_first_turn.units[10].moved, "Turn rollover did not reset action state")

	var end_round := {"phase": "end_turn", "active": 2, "turn": 2, "round": 1, "first_player": 1, "squads": {}, "units": {}}
	check(Progression.advance(end_round).is_empty() and end_round.active == 1 and end_round.turn == 3 and end_round.round == 2, "Round did not advance when the first player regained the turn")

	var invalid := {"phase": "deployment", "active": 1, "turn": 1, "round": 1, "squads": {}, "units": {}}
	check(not Progression.advance(invalid).is_empty() and invalid.phase == "deployment" and invalid.turn == 1, "Unknown phases must be rejected without mutating progression")

	print("Phase progression checks: %d failures" % failures)
	quit(0 if failures == 0 else 1)
