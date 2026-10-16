extends SceneTree
const C = preload("res://scripts/edition_11/combat_scenario.gd")
const Plan = C.AttackPlan
var failures := 0
func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1
func row(weapon: String, profile: String, target: int) -> Dictionary:
	return {"model": 100, "weapon": weapon, "profile": profile, "target": target, "amount": 1}
func fixture() -> Dictionary:
	var s := C.initial_state("legacy-solid-v1", C.Objectives.TRAINING, 2, false, true)
	for id: int in s.units:
		if id not in [100, 200, 300, 400]: s.units[id].wounds = 0
	s.units[100].position = Vector2(-4, -8)
	s.units[200].position = Vector2(-2, -8)
	s.units[300].position = Vector2(5, -8)
	s.units[400].position = Vector2(7, -8)
	s.phase = "shooting"
	return s
func _initialize() -> void:
	var s := fixture()
	s.units[100].keywords = ["Vehicle"]
	check(Plan.legal_targets(s, 100, false, "rifle", "focused") == [2], "Engaged vehicle can shoot its engaged infantry, not another engaged infantry")
	var prepared := Plan.prepare(s, 1, false, [row("rifle", "focused", 2)], true)
	check(prepared.error.is_empty() and prepared.batches[0].context.hit_modifier == -1, "Engaged heavy weapon loses Heavy bonus and takes close-quarters penalty")
	prepared = Plan.prepare(s, 1, false, [row("plasma", "standard", 2), row("rifle", "saturation", 2)], true)
	check(prepared.error.is_empty() and prepared.batches[0].context.hit_modifier == 0 and prepared.batches[1].context.hit_modifier == -1, "Vehicle sidearm exemption and CQ penalty exemption apply per weapon")
	s.units[400].keywords = ["Monster"]
	check(Plan.legal_targets(s, 100, false, "rifle", "focused") == [2, 4], "Vehicle can target another engaged Monster/Vehicle")
	prepared = Plan.prepare(s, 1, false, [row("rifle", "focused", 4)], true)
	check(prepared.error.is_empty() and prepared.batches[0].context.hit_modifier == -1, "Stacked penalties are capped at final minus one")
	s.units[100].ranged_weapons.append({"id": "blast", "profiles": {"standard": {"name": "Blast fixture", "attacks": 1, "skill": 3, "strength": 4, "ap": 0, "damage": 1, "range_inches": 30, "keywords": {"blast": true}}}})
	check(Plan.legal_targets(s, 100, false, "blast", "standard").is_empty(), "Blast still cannot target any engaged unit")
	s.units[100].position = Vector2(-12, -8)
	prepared = Plan.prepare(s, 1, false, [row("rifle", "focused", 4)], true)
	check(prepared.error.is_empty() and prepared.batches[0].context.hit_modifier == 0, "Stationary Heavy bonus offsets penalty shooting an engaged vehicle")
	prepared = Plan.prepare(s, 1, false, [row("rifle", "saturation", 4)], true)
	check(prepared.error.is_empty() and prepared.batches[0].context.hit_modifier == -1, "Unengaged shooter takes penalty against engaged vehicle")
	s.units[100].keywords = ["Infantry"]
	check(Plan.legal_targets(s, 100, false, "rifle", "saturation") == [2, 4], "Unengaged infantry can shoot an engaged vehicle and unengaged infantry")
	s.units[100].position = Vector2(-4, -8)
	check(Plan.legal_targets(s, 100, false, "rifle", "saturation").is_empty() and Plan.legal_targets(s, 100, false, "plasma", "standard") == [2], "Infantry remains CQ-only while engaged")
	s.units[200].keywords = ["Vehicle"]
	prepared = Plan.prepare(s, 1, false, [row("plasma", "standard", 2)], true)
	check(prepared.error.is_empty() and prepared.batches[0].context.hit_modifier == 0, "Engaged CQ against engaged vehicle ignores target penalty")
	s.squads[1].advanced = true
	s.units[100].keywords = ["Monster"]
	check(Plan.legal_targets(s, 100, false, "rifle", "saturation").is_empty(), "Engaged Monster cannot close-quarters shoot after Advance")
	print("Monster/Vehicle shooting checks: %d failures" % failures)
	quit(1 if failures else 0)
