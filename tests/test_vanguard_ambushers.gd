extends SceneTree
const Capabilities = preload("res://scripts/edition_11/capabilities.gd")
const AttackPlan = preload("res://scripts/edition_11/attack_plan.gd")
const AttackSequence = preload("res://scripts/edition_11/attack_sequence.gd")
var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func six() -> int:
	return 6

func _initialize() -> void:
	var original_supported: bool = Capabilities.supported("vanguard-ambushers")
	var state := {
		"phase": "shooting",
		"turn": 5,
		"combat_doctrines": {
			"detachment": "phobos-shock-force",
			"vanguard_ambushers": {7: 5},
		},
	}
	check(not original_supported, "Vanguard Ambushers is blocked pending local validation")
	check(AttackPlan.vanguard_wound_reroll(state, 7, false) == "none", "Blocked capability cannot grant a Shooting reroll")

	check(AttackPlan._vanguard_wound_reroll(state, 7, false) == "ones", "A current-turn mark grants only Wound rerolls of 1 in Shooting")
	state.phase = "fight"
	check(AttackPlan._vanguard_wound_reroll(state, 7, true) == "ones", "A current-turn mark also grants Wound rerolls of 1 in Fight")
	state.phase = "command"
	check(AttackPlan._vanguard_wound_reroll(state, 7, false) == "none" and AttackPlan._vanguard_wound_reroll(state, 7, true) == "none", "The mark does not apply outside Shooting and Fight")
	state.phase = "shooting"
	state.turn = 6
	check(AttackPlan._vanguard_wound_reroll(state, 7, false) == "none", "The mark expires after its turn")
	state.turn = 5
	state.combat_doctrines.vanguard_ambushers.erase(7)
	check(AttackPlan._vanguard_wound_reroll(state, 7, false) == "none", "An unmarked unit gets no reroll")
	state.combat_doctrines.vanguard_ambushers[7] = 5
	state.combat_doctrines.detachment = "gladius"
	check(AttackPlan._vanguard_wound_reroll(state, 7, false) == "none", "A mark cannot activate outside Phobos Shock Force")

	var weapon := {"keywords": {}}
	var context := {"wound_reroll": "ones"}
	check(AttackSequence.reroll_wound(1, 4, 0, weapon, context), "The wound reroll predicate accepts a natural 1")
	check(not AttackSequence.reroll_wound(2, 4, 0, weapon, context), "The wound reroll predicate rejects values other than 1")
	var hits: Array[int] = [1, 2]
	var hit_changes := AttackSequence.reroll_hit_pool(hits, 4, 0, context, AttackSequence.Dice.new(Callable(self, "six")))
	check(hit_changes.is_empty() and hits == [1, 2], "A Wound reroll setting does not reroll Hits")

	print("Vanguard Ambushers checks: %d failures" % failures)
	quit(0 if failures == 0 else 1)
