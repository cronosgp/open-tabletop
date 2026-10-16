extends SceneTree
const F = preload("res://tests/fixtures/mixed_defenders.gd")
const C = F.C
var failures := 0
var values: Array = []
var calls := 0
func roll() -> int:
	calls += 1
	return values.pop_front() if not values.is_empty() else 0
func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1
func begin(s: Dictionary, dice: Array) -> Dictionary:
	values = dice
	calls = 0
	return C.shoot(s, 1, 100, 200, 0, true, roll)
func choose(s: Dictionary, model: int, player: int = 2) -> String:
	return C.allocate_damage(s, player, model, s.revision, roll)
func finish_order(s: Dictionary) -> void:
	for step in range(10):
		if s.pending_attack.is_empty() or s.pending_attack.current.phase != "order": break
		var options := C.Allocation.eligible(s)
		check(choose(s, options[0]).is_empty(), "Declare next valid allocation group")
func _initialize() -> void:
	var s := F.state()
	check(C.AttackPlan.defender(s, 2).toughness == 5, "Attached unit uses highest surviving bodyguard toughness")
	check(not C.Attacks.resolve(s.squads[1].weapon, C.AttackPlan.defender(s, 2), {}, roll).error.is_empty() and calls == 0, "Isolated single-group resolver cannot silently flatten mixed defenses")
	s.squads[2].attached = false
	check(C.AttackPlan.defender(s, 2).toughness == 8, "Unattached mixed unit uses highest toughness")
	s.squads[2].attached = true
	s.units[201].attachment_role = "support"
	check(C.AttackPlan.defender(s, 2).toughness == 4, "Non-character support is not mistaken for bodyguard")
	s = F.state()
	var result := begin(s, [6, 6, 3, 6, 1, 6])
	check(result.error.is_empty() and calls == 4 and s.pending_attack.current.phase == "order" and s.pending_attack.current.result.save_rolls.is_empty(), "Mixed groups choose order before save dice are revealed")
	check(C.Allocation.eligible(s) == [200], "Wounded non-character group first")
	var before := var_to_str(s)
	check(not choose(s, 202).is_empty() and not choose(s, 201).is_empty() and before == var_to_str(s) and calls == 4, "Invalid early character/healthy group cannot reveal saves")
	check(choose(s, 200).is_empty() and C.Allocation.eligible(s) == [201], "Other non-character group follows wounded group")
	check(choose(s, 201).is_empty() and C.Allocation.eligible(s) == [203], "Wounded character precedes healthy character")
	check(choose(s, 203).is_empty() and C.Allocation.eligible(s) == [202], "Characters have separate groups")
	check(choose(s, 202).is_empty() and calls == 6 and s.pending_attack.current.phase == "damage", "Save pool rolls once only after complete group declaration")
	check(choose(s, 200).is_empty() and s.pending_attack.is_empty() and s.units[201].wounds == 3 and s.units[202].wounds == 4, "Current group changes after destruction; later saves use next group's profile")
	s = F.state()
	s.units[202].wounds = 0
	s.units[203].wounds = 0
	s.units[200].max_wounds = 1
	s.units[200].wounds = 1
	s.units[200].defense.save_target = 2
	s.units[201].defense.save_target = 5
	s.squads[1].weapon.damage = 1
	begin(s, [6, 6, 3, 3, 1, 3])
	finish_order(s)
	choose(s, 200)
	check(not s.pending_attack.is_empty() and C.Allocation.eligible(s) == [201], "A later save that would pass old group can fail the next group")
	choose(s, 201)
	check(s.units[201].wounds == 2 and s.last_attack.pools[0].unsaved == 2, "Second group takes its own failed save")
	s = F.state(true, true)
	begin(s, [6, 6, 3, 6, 6])
	check(C.actor(s) == 1 and s.pending_attack.current.phase == "precision" and C.Allocation.eligible(s) == [202, 203] and calls == 4, "Attacker selects visible character before defender order and saves")
	before = var_to_str(s)
	check(not choose(s, 202, 2).is_empty() and not choose(s, 200, 1).is_empty() and before == var_to_str(s), "Defender cannot choose Precision and attacker cannot choose bodyguard")
	check(choose(s, 202, 1).is_empty() and C.actor(s) == 2, "Precision control hands to defender")
	finish_order(s)
	check(s.pending_attack.current.steps[s.pending_attack.current.cursor].kind == "devastating" and C.Allocation.eligible(s) == [202], "Precision redirects devastating mortals to surviving selected character")
	choose(s, 202)
	check(s.units[202].wounds == 2 and s.units[200].wounds == 1 and s.last_attack.pools[0].precision_model == 202, "Chosen character receives mortal packet without damaging wounded bodyguard")
	s = F.state(true, true)
	s.units[202].wounds = 1
	begin(s, [6, 6, 3, 6, 1])
	choose(s, 202, 1)
	finish_order(s)
	check(C.Allocation.eligible(s) == [202], "Normal Precision damage first targets selected character")
	choose(s, 202)
	check(C.Allocation.eligible(s) == [200], "After character dies, devastating mortals return to normal non-character priority")
	choose(s, 200)
	check(s.units[202].wounds == 0 and s.units[200].wounds == 0 and s.squads[1].shot, "Precision and mortal fallback complete one activation")
	s = F.state(true, false, false)
	begin(s, [6, 6, 3, 3, 1, 1])
	check(s.pending_attack.current.phase == "precision", "Automatic defender assist still allows attacker Precision decision")
	check(choose(s, -1, 1).is_empty() and s.pending_attack.is_empty() and s.squads[1].shot and s.last_attack.pools[0].precision_model == -1, "Attacker may decline Precision; automatic group assist then resolves")
	s = F.state(true)
	s.units[202].position = Vector2(0, 0)
	var prepared := C.AttackPlan.prepare(s, 1, false, C.AttackPlan.single_target(s, 1, 2, false), true)
	check(not prepared.error.is_empty() or 202 not in C.Allocation.Groups.precision_candidates(s, prepared.batches[0]), "Blocked character is not eligible for Precision")
	s = F.state()
	s.units[200].wounds = 0
	s.units[201].wounds = 0
	check(C.AttackPlan.defender(s, 2).toughness == 8 and C.living(s, 2) == [202, 203], "After bodyguards die, characters remain one attached unit using their highest toughness")
	print("Mixed defenders/Precision checks: %d failures" % failures)
	quit(1 if failures else 0)
