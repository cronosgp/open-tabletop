extends SceneTree
const C = preload("res://scripts/edition_11/combat_scenario.gd")
var failures := 0
var values: Array = []
var calls := 0
func roll() -> int:
	calls += 1
	return values.pop_front() if not values.is_empty() else 1
func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1
func fixture(manual: bool = false) -> Dictionary:
	var s := C.initial_state("legacy-solid-v1", "elimination", 2, manual, true)
	for id: int in s.units:
		if id not in [100, 101, 200, 201, 400]: s.units[id].wounds = 0
	s.units[100].position = Vector2(-12, -8)
	s.units[101].position = Vector2(-10, -8)
	s.units[200].position = Vector2(-2, -8)
	s.units[201].position = Vector2(0, -8)
	s.units[400].position = Vector2(4, -8)
	s.phase = "shooting"
	return s
func row(model: int, target: int, weapon: String, profile: String) -> Dictionary:
	return {"model": model, "target": target, "weapon": weapon, "profile": profile, "amount": 1}
func plasma(s: Dictionary) -> Dictionary:
	return C.resolve_attack_plan(s, 1, 100, [row(100, 2, "plasma", "supercharge")], s.revision, false, true, roll)
func _initialize() -> void:
	var s := fixture()
	values = [1, 2] # Miss, failed hazard.
	calls = 0
	check(plasma(s).error.is_empty() and calls == 2 and s.pending_hazard.remaining == 1 and not s.squads[1].shot, "Miss still requires one hazard per selected weapon and defers completion")
	check(C.actor(s) == 1 and C.Hazard.eligible(s) == [100, 101], "Owner chooses any eligible member, including a model without the weapon")
	var before := var_to_str(s)
	check(not C.allocate_hazard(s, 2, 100, s.revision).is_empty() and not C.allocate_hazard(s, 1, 200, s.revision).is_empty() and not C.allocate_hazard(s, 1, 101, -1).is_empty() and before == var_to_str(s), "Wrong owner, enemy and stale choices do not mutate")
	check(not C.advance_phase(s, 1, s.revision).is_empty() and before == var_to_str(s), "Activation cannot advance while hazards pending")
	check(C.allocate_hazard(s, 1, 101, s.revision).is_empty() and s.units[101].wounds == 1 and s.units[100].wounds == 2 and s.squads[1].shot and s.pending_hazard.is_empty() and calls == 2, "One wound without reroll or bearer restriction")
	check(s.last_attack.hazardous.rolls == [2] and s.last_attack.hazardous.allocations == [101], "Completion records hazard dice and recipients")
	check(not C.allocate_hazard(s, 1, 101, s.revision).is_empty(), "No double allocation")
	s = fixture()
	values = [1, 3]
	check(plasma(s).error.is_empty() and s.pending_hazard.is_empty() and s.squads[1].shot and s.last_attack.hazardous.failures == 0, "Three passes hazard")
	s = fixture()
	values = [1, 0]
	before = var_to_str(s)
	check(not plasma(s).error.is_empty() and before == var_to_str(s), "Invalid hazard rolls reject complete attack transaction")
	s = fixture(true)
	values = [6, 6, 1]
	check(plasma(s).error.is_empty() and not s.pending_attack.is_empty() and s.pending_hazard.is_empty(), "Manual defender resolves damage before hazard tests")
	before = var_to_str(s)
	values = [0]
	check(not C.allocate_damage(s, 2, 200, s.revision, roll).is_empty() and before == var_to_str(s), "Bad hazard die retains final pending defender choice")
	values = [1]
	check(C.allocate_damage(s, 2, 200, s.revision, roll).is_empty() and s.pending_attack.is_empty() and not s.pending_hazard.is_empty() and C.actor(s) == 1, "Control returns from defender to weapon owner for hazards")
	s.units[101].wounds = 1
	check(C.Hazard.eligible(s) == [101], "Wounded non-character takes priority")
	s.units[101].keywords.append("CHARACTER")
	check(C.Hazard.eligible(s) == [100], "Healthy non-character precedes wounded character")
	s.units[100].keywords.append("CHARACTER")
	check(C.Hazard.eligible(s) == [101], "Wounded character priority if only characters remain")
	# Heavy hazard damage spills one mortal at a time, stopping at unit destruction.
	s = fixture()
	s.units[100].keywords = ["VEHICLE"]
	s.units[101].keywords = ["MONSTER"]
	values = [1, 1]
	check(plasma(s).error.is_empty() and s.pending_hazard.remaining == 3, "All MONSTER/VEHICLE unit suffers three mortals per failure")
	C.allocate_hazard(s, 1, 101, s.revision)
	C.allocate_hazard(s, 1, 101, s.revision)
	C.allocate_hazard(s, 1, 100, s.revision)
	check(s.units[101].wounds == 0 and s.units[100].wounds == 1 and s.pending_hazard.is_empty(), "Three mortals allocated separately across models")
	s = fixture()
	s.units[101].wounds = 0
	s.units[100].wounds = 1
	s.units[100].keywords = ["VEHICLE"]
	values = [1, 1]
	plasma(s)
	C.allocate_hazard(s, 1, 100, s.revision)
	check(s.pending_hazard.is_empty() and s.last_attack.hazardous.discarded == 2 and s.test_winner == 2, "Discard excess on unit death and finish elimination")
	s = fixture()
	s.units[201].wounds = 0
	var extra: Dictionary = s.units[100].ranged_weapons[1].duplicate(true)
	extra.profiles.supercharge.damage = 3
	s.units[101].ranged_weapons.append(extra)
	values = [6, 6, 1, 1, 2]
	calls = 0
	var rows := [row(100, 2, "plasma", "supercharge"), row(101, 2, "plasma", "supercharge")]
	var result := C.resolve_attack_plan(s, 1, 100, rows, 0, false, true, roll)
	check(result.error.is_empty() and calls == 5 and s.pending_hazard.remaining == 2 and s.pending_hazard.resolved.pools.size() == 1, "Selected weapon whose target died still contributes a hazard roll")
	s = fixture()
	for id in [101, 201, 400]: s.units[id].wounds = 0
	s.units[100].wounds = 1
	values = [6, 6, 1, 1]
	plasma(s)
	check(s.test_winner == 0, "Elimination waits until hazard allocation finishes")
	C.allocate_hazard(s, 1, 100, s.revision)
	check(s.test_winner == -1, "Mutual elimination produces draw")
	s = C.initial_state("legacy-solid-v1", C.Objectives.TRAINING, 2)
	for id: int in s.units:
		if id not in [100, 200, 400]: s.units[id].wounds = 0
	s.units[100].position = Vector2(0, -8)
	s.units[200].position = Vector2(1.5, -8)
	s.units[400].position = Vector2(-1.5, -8)
	s.phase = "fight"
	s.fight_step = "consolidation_reaction"
	s.fight_actor = 1
	s.reaction_queue = [1]
	s.squads[1].fight_eligible = true
	s.squads[1].melee_weapon = {"name": "Hazardous split fixture", "attacks": 2, "skill": 2, "strength": 4, "ap": 0, "damage": 1, "keywords": {"hazardous": true}}
	var split := [{"model": 100, "target": 2, "amount": 1}, {"model": 100, "target": 4, "amount": 1}]
	values = [1, 1, 2]
	calls = 0
	result = C.resolve_attack_plan(s, 1, 100, split, 0, true, true, roll)
	check(result.error.is_empty() and calls == 3 and s.pending_hazard.remaining == 1 and not s.squads[1].fought and s.reaction_queue == [1], "Melee split counts one weapon and delays reaction queue")
	C.allocate_hazard(s, 1, 100, s.revision)
	check(s.pending_hazard.is_empty() and s.squads[1].fought and s.reaction_queue.is_empty(), "Last hazard resumes reaction queue once")
	# Per-model Close-quarters selection, Advance and engagement.
	s = fixture()
	var mixed := [row(100, 2, "plasma", "standard"), row(100, 2, "rifle", "saturation")]
	check(not C.AttackPlan.prepare(s, 1, false, mixed, true).error.is_empty(), "Cannot mix CQ and other ranged weapons on one infantry model")
	mixed[1] = row(101, 2, "rifle", "saturation")
	check(C.AttackPlan.prepare(s, 1, false, mixed, true).error.is_empty(), "Different models can choose different weapon categories")
	s.units[100].position = Vector2(-4, -8)
	check(C.AttackPlan.legal_targets(s, 100, false, "plasma", "standard") == [2] and C.AttackPlan.legal_targets(s, 100, false, "rifle", "saturation").is_empty(), "Engaged infantry uses CQ only against engaged enemy unit")
	s.squads[1].advanced = true
	check(C.AttackPlan.legal_targets(s, 100, false, "plasma", "standard").is_empty(), "Engaged CQ unavailable after Advance")
	print("Hazardous checks: %d failures" % failures)
	quit(1 if failures else 0)
