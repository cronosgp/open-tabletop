extends SceneTree
const F = preload("res://tests/fixtures/weapon_selection_fixture.gd")
const C = F.C
const Plan = C.AttackPlan
var failures := 0
var calls := 0
func miss() -> int:
	calls += 1
	return 1
func six() -> int: return 6
func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1
func prepare(s: Dictionary, rows: Array) -> Dictionary:
	return Plan.prepare(s, 1, true, rows, true)
func _initialize() -> void:
	var s := F.state()
	var hunter: Dictionary = F.weapons().chain.profiles.hunter
	check(hunter.keywords.hunter == ["Monster", "Vehicle"], "Both imported Hunter alternatives survive import")
	check(Plan.legal_targets(s, 100, true, "chain", "hunter") == [4], "Hunter Vehicle matches, Infantry does not")
	s.units[400].keywords = ["monster"]
	check(Plan.legal_targets(s, 100, true, "chain", "hunter") == [4], "Hunter alternatives are OR, case-insensitive exact keywords")
	s.units[400].keywords = ["Monster Hunter"]
	check(Plan.legal_targets(s, 100, true, "chain", "hunter").is_empty(), "Hunter does not substring-match names")
	s.units[401].keywords = ["Monster"]
	check(Plan.legal_targets(s, 100, true, "chain", "hunter").is_empty(), "Destroyed models do not grant target keywords")
	s.units[401].wounds = 1
	check(Plan.legal_targets(s, 100, true, "chain", "hunter") == [4], "Unit keywords include all surviving members")
	s = F.state()
	var rows := F.plan()
	var choices := Plan.Equipment.choices(s, 100, true)
	check(choices[-1].label != choices[-2].label and "weapon 2" in choices[-1].label, "Identical physical Extra Attacks weapons have distinct UI labels")
	var prepared := prepare(s, rows)
	check(prepared.error.is_empty() and prepared.batches.size() == 2 and prepared.batches[1].weapon.attacks == 2, "One ordinary and both Extra Attacks weapons, identical extras pool")
	check(prepared.batches[0].weapon.keywords.is_empty() and prepared.batches[1].weapon.keywords.is_empty(), "Selection-only mechanics expand before attack pooling")
	s.units[400].keywords = ["Infantry"]
	check(Plan.resolve(s, prepared, miss).error.is_empty(), "Hunter legality is frozen with the accepted declaration")
	s = F.state()
	var shortcut := Plan.single_target(s, 1, 2, true)
	check(shortcut.size() == 3 and prepare(s, shortcut).error.is_empty(), "Quick melee attack includes first ordinary and all eligible extras")
	for bad: Array in [[F.row("chain", "hunter", 3, 2), F.row("servo", "standard", 1), F.row("servo-two", "standard", 1)], [F.row("chain", "hunter", 3, 4)], [F.row("servo", "standard", 1), F.row("servo-two", "standard", 1)], [F.row("chain", "standard", 2), F.row("knives", "standard", 3), F.row("servo", "standard", 1), F.row("servo-two", "standard", 1)], [F.row("chain", "hunter", 2, 4), F.row("servo", "standard", 1), F.row("servo-two", "standard", 1)]]:
		s = F.state()
		calls = 0
		var before := var_to_str(s)
		var result := C.resolve_attack_plan(s, 1, 100, bad, 0, true, true, miss)
		check(not result.error.is_empty() and calls == 0 and var_to_str(s) == before, "Illegal Hunter target, omitted weapon, multiple ordinary or wrong A rejected before dice")
	s = F.state()
	s.units[100].melee_weapons = [F.weapons().servo]
	check(prepare(s, [F.row("servo", "standard", 1)]).error.is_empty(), "Extra-only inventory can fight without an ordinary weapon")
	s = F.state()
	s.units[100].melee_weapons = [F.weapons().chain, F.weapons().servo]
	s.units[100].melee_weapons[0].profiles.erase("standard")
	s.units[400].keywords = ["Infantry"]
	check(prepare(s, [F.row("servo", "standard", 1)]).error.is_empty(), "Extra-only attacks permitted when ordinary Hunter weapon has no legal target")
	s = F.state()
	s.units[200].keywords.append("Monster")
	rows = [F.row("chain", "hunter", 1), F.row("chain", "hunter", 2, 4), F.row("servo", "standard", 1), F.row("servo-two", "standard", 1, 4)]
	prepared = prepare(s, rows)
	check(prepared.error.is_empty() and prepared.targets == [2, 4], "Ordinary and extra weapon targets split independently")
	F.instance(s, "servo").profiles.standard.keywords.hazardous = true
	prepared = prepare(s, rows)
	check(prepared.error.is_empty() and prepared.hazardous_count == 1, "Hazardous still counts physical extra weapon once")
	s = F.state()
	F.instance(s, "servo").profiles.other = F.instance(s, "servo").profiles.standard.duplicate(true)
	F.instance(s, "servo").profiles.other.keywords.erase("extra-attacks")
	check(not prepare(s, F.plan()).error.is_empty(), "Ambiguous ordinary/extra profiles of one instance are blocked")
	var malformed := hunter.duplicate(true)
	for required: Variant in [true, [], [""], [2], null]:
		malformed.keywords.hunter = required
		check(not C.Attacks._validate(malformed, Plan.defender(s, 4), {"target_keywords": ["Vehicle"]}).is_empty(), "Malformed Hunter data is blocked")
	var imported := C.Attacks.Traits.import_profile({"keywords": [{"keyword_id": "hunter", "parameters": {"target_keyword": "Vehicle"}}], "target_restrictions": {"required_keywords_any": ["Monster"]}})
	check(imported.has("unsupported-target-restriction"), "Conflicting imported target restrictions are blocked")
	imported = C.Attacks.Traits.import_keywords([{"keyword_id": "sustained-hits", "parameters": {"value": 1, "excluded_target_keywords": ["Monster"]}}])
	check(imported.has("unsupported-parameters:sustained-hits"), "Unimplemented conditional parameters are not silently dropped")
	s = F.state(true)
	s.squads[2].stats.save_target = 7
	s.squads[4].stats.save_target = 7
	var result := C.resolve_attack_plan(s, 1, 100, F.plan(), 0, true, true, six)
	check(result.error.is_empty() and C.actor(s) == 2 and not s.pending_attack.is_empty() and not s.squads[1].fought, "Extra and Hunter plans integrate with defender-selected allocation")
	while not s.pending_attack.is_empty():
		var eligible := C.Allocation.eligible(s)
		check(C.allocate_damage(s, 2, eligible[0], s.revision, six).is_empty(), "Allocate next selected weapon damage")
	check(s.squads[1].fought and s.last_attack.assignments == F.plan() and s.last_attack.pools.size() == 2, "All selected weapons finish one activation and retain assignments")
	print("Hunter/Extra Attacks checks: %d failures" % failures)
	quit(1 if failures else 0)


