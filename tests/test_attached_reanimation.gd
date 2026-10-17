extends SceneTree
const F = preload("res://tests/awakened_fixture.gd")
const C = F.C
const R = C.Reanimation
var failures := 0
var calls := 0
func six() -> int:
	calls += 1
	return 6
func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1
func fresh(bodyguard: int = 4) -> Dictionary:
	var s := F.fresh({"awakened_dynasty": true, "reanimation_protocols": true})
	check(C.select_awakened_attachment(s, 2, bodyguard, 0).is_empty(), "Combined options allow attachment")
	F.combat(s)
	s.phase = "command"
	R.start_command(s)
	check(R.phase_error(s).is_empty() and R.open_end_command(s), "Attached unit enters own Command healing queue")
	return s
func _initialize() -> void:
	var s := fresh()
	s.units[600].wounds = 4
	s.units[400].wounds = 0
	s.units[401].wounds = 0
	check(R.roll_unit(s, 4, six).error.is_empty(), "Roll attached unit once")
	check(R.pending(s).current.healed == {600: 2} and R.pending(s).current.slots == 1, "D3 three heals two Overlord wounds before one troop return")
	check(s.units[600].wounds == 4 and s.units[400].wounds == 0, "Healing and returns remain staged together")
	check(R.suggest(s).error.is_empty(), "Mixed healing has a valid return preview")
	var restored: Dictionary = bytes_to_var(var_to_bytes(s))
	check(R.reset_preview(restored).error.is_empty() and R.pending(restored).current.healed == {600: 2} and calls == 1, "Serialized preview reset retains reserved healing and consumes no dice")
	check(R.suggest(restored).error.is_empty() and R.confirm_unit(restored).error.is_empty(), "Restored preview can commit")
	check(restored.units[600].wounds == 6 and C.living(restored, 4).size() == 10 and R.pending(restored).results[0].discarded == 0, "One shared budget applied exactly once")
	s = fresh()
	for id in range(400, 410): s.units[id].wounds = 0
	check(F.A.hit_bonus(s, 4) == 1 and s.squads[4].starting_strength == 11, "e11 leader keeps ability and combined strength after bodyguard destruction")
	check(R.roll_unit(s, 4, six).error.is_empty() and R.pending(s).current.slots == 3, "Living leader can anchor three revived bodyguards")
	check(R.suggest(s).error.is_empty() and R.confirm_unit(s).error.is_empty() and C.living(s, 4).size() == 4, "Wiped bodyguard component returns to original attached unit")
	s = fresh(2)
	s.units[600].wounds = 0
	s.units[200].wounds = 0
	check(R.roll_unit(s, 2, six).error.is_empty() and 600 not in R.returnable(s), "Destroyed Character cannot be revived by unit healing")
	check(R.suggest(s).error.is_empty() and R.confirm_unit(s).error.is_empty() and s.units[600].wounds == 0 and F.A.hit_bonus(s, 2) == 0, "Immortals return without reviving the Overlord or its bonus")
	s = fresh()
	s.units[600].wounds = 1
	s.units[400].wounds = 0
	check(R.roll_unit(s, 4, six).error.is_empty() and R.pending(s).current.is_empty() and s.units[600].wounds == 4 and s.units[400].wounds == 0, "Insufficient budget heals only leader and performs no return")
	print("Attached Reanimation checks: %d failures" % failures)
	quit(1 if failures else 0)
