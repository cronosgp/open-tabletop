extends SceneTree
const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
var failures := 0
var rolls: Array[int] = []
func die() -> int: return rolls.pop_front() if not rolls.is_empty() else 1
func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1
func fixture(alive: Array[int], active: int = 1) -> Dictionary:
	var s := F.fresh()
	s.awakened_dynasty.pending = []
	s.unit_abilities.setup_players = [1, 2]
	s.phase = "shooting"
	s.turn = 3
	s.round = 2
	s.active = active
	s.unit_abilities.phase_key = C.UnitActions.key(s)
	s.terrain.areas = []
	s.stratagems.attack_rerolls = false
	for model: int in s.units:
		if model not in alive: s.units[model].wounds = 0
	return s
func gun(s: Dictionary, model: int, damage: int, ap: int) -> void:
	s.units[model].ranged_weapons = [{"id": "test-cannon", "profiles": {"standard": {"name": "Synthetic allocation probe", "attacks": 1, "skill": 2, "strength": 10, "ap": ap, "damage": damage, "range_inches": 24, "keywords": {}}}}]
func _initialize() -> void:
	var s := fixture([700, 600])
	s.units[700].position = Vector2.ZERO
	s.units[600].position = Vector2(5, 0)
	gun(s, 700, 3, -6)
	rolls = [6, 6, 1]
	var attack := C.resolve_attack_plan(s, 1, 700, [{"model": 700, "target": 6, "amount": 1}], s.revision, false, true, die)
	check(attack.error.is_empty() and s.units[600].wounds == 4, "Actual failed save allocates D3 attack as two wounds to Overlord")
	s = fixture([500, 600], 2)
	s.units[600].position = Vector2.ZERO
	s.units[500].position = Vector2(5, 0)
	s.mission.objectives = [{"kind": "marker", "position": Vector2(5, 0), "name": "Controlled marker", "controller": 1, "secured": 0}]
	gun(s, 600, 1, 0)
	rolls = [6, 6, 2]
	attack = C.resolve_attack_plan(s, 2, 600, [{"model": 600, "target": 5, "amount": 1}], s.revision, false, true, die)
	check(attack.error.is_empty() and s.units[500].wounds == 3, "Heavy Intercessor save roll two succeeds with +1 while controlling objective")
	s.squads[6].shot = false
	s.squads[5].battle_shocked = true
	rolls = [6, 6, 2]
	attack = C.resolve_attack_plan(s, 2, 600, [{"model": 600, "target": 5, "amount": 1}], s.revision, false, true, die)
	check(attack.error.is_empty() and s.units[500].wounds == 2, "Same save fails when Battle-shock removes controlling-unit condition")
	s = F.fresh()
	s.awakened_dynasty.pending = []
	C.UnitActions.attach(s, 900, 1)
	s.unit_abilities.setup_players = [1, 2]
	s.phase = "shooting"
	s.active = 1
	s.units[900].position = Vector2.ZERO
	s.units[600].position = Vector2(5, 0)
	s.terrain.areas = []
	var plan := C.AttackPlan.prepare(s, 1, false, [{"model": 900, "target": 6, "amount": 1}], false)
	check(plan.error.is_empty() and plan.batches[0].weapon.keywords.get("lethal-hits", false) and plan.batches[0].context.use_lethal_hits, "Current Tactical Precision cannot be disabled through historical training toggle")
	s.units[600].keywords.append("MONSTER")
	plan = C.AttackPlan.prepare(s, 1, false, [{"model": 900, "target": 6, "amount": 1}], true)
	check(plan.error.is_empty() and not plan.batches[0].weapon.keywords.get("lethal-hits", false), "Monster exclusion reaches actual prepared attack context")
	s = F.fresh()
	s.awakened_dynasty.pending = []
	C.UnitActions.attach(s, 300, 7)
	s.unit_abilities.setup_players = [1, 2]
	s.phase = "fight"
	s.turn = 3
	s.active = 1
	s.terrain.areas = []
	for model: int in s.units:
		if model not in [300, 700, 200, 400]: s.units[model].wounds = 0
	s.units[300].position = Vector2.ZERO
	s.units[700].position = Vector2(-1.5, 0)
	s.units[200].position = Vector2(0, 1.7)
	s.units[400].position = Vector2(1.7, 0)
	s.unit_abilities.used["finest-active:300"] = s.turn
	plan = C.AttackPlan.prepare(s, 7, true, [{"model": 300, "target": 2, "amount": 4}, {"model": 300, "target": 4, "amount": 5}, {"model": 700, "target": 2, "amount": 3}], true)
	var captain_attacks := 0
	if plan.error.is_empty():
		for batch: Dictionary in plan.batches:
			for source: Dictionary in batch.context.attack_sources:
				if source.model == 300:
					captain_attacks += int(source.expression)
					check(batch.weapon.keywords.get("devastating-wounds", false), "Finest Hour freezes Devastating Wounds in each split pool")
	check(plan.error.is_empty() and captain_attacks == 9, "Split-target Finest Hour adds three attacks once per weapon, not per target")
	s = fixture([200, 700], 2)
	s.units[200].position = Vector2.ZERO
	s.units[700].position = Vector2(5, 0)
	s.mission.objectives = [{"kind": "marker", "position": Vector2(5, 0), "name": "Wound target marker", "controller": 1, "secured": 0}]
	gun(s, 200, 1, 0)
	rolls = [4, 4]
	attack = C.resolve_attack_plan(s, 2, 200, [{"model": 200, "target": 7, "amount": 1}], s.revision, false, true, die)
	check(attack.error.is_empty() and C.UnitActions.pending(s).get("kind", "") == "wound", "Objective target opens a free Implacable wound decision before saves")
	var reroll: Dictionary = {}
	for selected: Dictionary in C.unit_choices(s, 2):
		if selected.action == "wound-reroll": reroll = selected
	check(not reroll.is_empty() and s.pending_attack.current.checkpoint.effective_wounds == [4], "Successful wound rolls can also be selected for Implacable Eradication")
	rolls = [6]
	check(C.unit_action(s, 2, reroll, Vector2.ZERO, s.revision, die).is_empty() and s.pending_attack.current.checkpoint.effective_wounds == [6] and s.cp[2] == 0, "Free wound reroll replaces a success without CP")
	var snapshot := var_to_bytes(s)
	check(not C.unit_action(s, 2, reroll, Vector2.ZERO, s.revision, die).is_empty() and snapshot == var_to_bytes(s), "A re-rolled wound cannot be re-rolled again")
	var restored: Dictionary = bytes_to_var(snapshot)
	rolls = [1]
	var keep: Dictionary = C.unit_choices(restored, 2)[0]
	check(keep.action == "wound-finish" and C.unit_action(restored, 2, keep, Vector2.ZERO, restored.revision, die).is_empty() and restored.units[700].wounds == 1, "Serialized Implacable choice resumes saves and damage once")
	print("Current unit combat checks: %d failures" % failures)
	quit(1 if failures else 0)
