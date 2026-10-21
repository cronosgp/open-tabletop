extends SceneTree

const MatchActor = preload("res://scripts/edition_11/match_actor.gd")
const Combat = preload("res://scripts/edition_11/combat_scenario.gd")

var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func base_state() -> Dictionary:
	return {"phase": "shooting", "active": 1, "turn": 1, "round": 1, "test_winner": 0,
		"squads": {10: {"owner": 1}, 20: {"owner": 2}}, "units": {}}

func _initialize() -> void:
	var ordinary := base_state()
	check(MatchActor.player(ordinary) == 1 and Combat.actor(ordinary) == 1, "Normal priority follows the active player through the public combat facade")

	var defending := base_state()
	defending.pending_attack = {"player": 1, "current": {"phase": "damage", "target": 20}}
	check(MatchActor.player(defending) == 2, "Damage allocation priority transfers to the target unit's owner")

	var precision := base_state()
	precision.pending_attack = {"player": 1, "current": {"phase": "precision", "target": 20}}
	check(MatchActor.player(precision) == 1, "Precision selection stays with the attacking player")

	var hazardous := base_state()
	hazardous.pending_hazard = {"player": 1}
	check(MatchActor.player(hazardous) == 1, "Hazardous allocation priority transfers to the weapon owner")

	var decision := base_state()
	decision.stratagems = {"pending": {"player": 2, "kind": "after_hit_roll"}}
	check(MatchActor.player(decision) == 2, "An open reaction decision takes priority over the active turn")

	print("Match actor checks: %d failures" % failures)
	quit(0 if failures == 0 else 1)
