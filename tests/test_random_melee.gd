extends SceneTree
const F = preload("res://tests/fixtures/weapon_selection_fixture.gd")
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
func _initialize() -> void:
	var s := F.state()
	F.instance(s, "chain").profiles.hunter.attacks = "D3"
	var rows := F.plan()
	rows[0].amount = 1
	var prepared := C.AttackPlan.prepare(s, 1, true, rows, true)
	check(prepared.error.is_empty() and prepared.batches[0].context.attack_sources[0].expression == "D3", "Random melee A stays unresolved until gather attack dice")
	values = [6, 1, 1, 1, 1, 1]
	var result := C.resolve_attack_plan(s, 1, 100, rows, 0, true, true, roll)
	check(result.error.is_empty() and calls == 6 and result.pools[0].attacks == 3 and result.pools[1].attacks == 2, "Random ordinary weapon and fixed Extra Attacks generate independently")
	s = F.state()
	F.instance(s, "chain").profiles.hunter.attacks = "D3"
	rows = F.plan()
	calls = 0
	var before := var_to_str(s)
	check(not C.resolve_attack_plan(s, 1, 100, rows, 0, true, true, roll).error.is_empty() and calls == 0 and var_to_str(s) == before, "Client cannot supply a generated A count")
	rows[0].amount = 1
	rows.append(F.row("chain", "hunter", 1, 2))
	s.units[200].keywords.append("Monster")
	check(not C.AttackPlan.prepare(s, 1, true, rows, true).error.is_empty(), "Random melee split declaration remains explicitly restricted")
	s = F.state()
	s.units[100].melee_weapons = [F.weapons().servo]
	F.instance(s, "servo").profiles.standard.attacks = "D6+1"
	var shortcut := C.AttackPlan.single_target(s, 1, 2, true)
	check(shortcut.size() == 1 and shortcut[0].amount == 1 and C.AttackPlan.prepare(s, 1, true, shortcut, true).error.is_empty(), "Extra-only random melee weapon works through quick attack")
	print("Random melee checks: %d failures" % failures)
	quit(1 if failures else 0)
