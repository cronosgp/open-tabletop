extends SceneTree
const C = preload("res://scripts/edition_11/combat_scenario.gd")
var failures := 0
func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1
func two() -> int: return 2
func fixture() -> Dictionary:
	var s := C.initial_state("legacy-solid-v1", C.Objectives.TRAINING, 2)
	for id in range(301, 305): s.units[id].wounds = 0
	s.squads[3].starting_strength = 1
	s.units[300].keywords.append("Character")
	s.units[300].max_wounds = 4
	s.units[300].wounds = 4
	s.squads[3].stats.toughness = 8
	s.squads[3].stats.save_target = 2
	s.squads[3].stats.leadership_target = 4
	s.squads[3].stats.objective_control = 1
	s.squads[3].weapon.name = "Leader-specific practice weapon"
	return s
func _initialize() -> void:
	var s := fixture()
	var before := var_to_str(s)
	check(not C.Attachments.form_practice_unit(s, 1, 2).is_empty() and var_to_str(s) == before, "Enemy attachment rejected transactionally")
	check(not C.Attachments.form_practice_unit(s, 1, 1).is_empty() and var_to_str(s) == before, "Duplicate component rejected")
	var hash_before: String = s.pack_hash
	var guard_toughness: int = s.squads[1].stats.toughness
	check(C.Attachments.form_practice_unit(s, 1, 3).is_empty() and s.squads[1].starting_strength == 6 and not s.squads.has(3) and s.units[300].squad == 1, "Leader and bodyguards form one unit with combined starting strength")
	check(s.pack_hash != hash_before and s.units[300].attachment_role == "leader" and s.units[100].attachment_role == "bodyguard", "Attachment identity enters match compatibility and preserves roles")
	check(C.AttackPlan.defender(s, 1).toughness == guard_toughness and C.Allocation.Groups.profile(s, 300).save_target == 2, "Bodyguard Toughness and character's own save retained")
	check(C.Morale.roll_battle_shock(s, 1, two).passed and C.Morale.objective_control(s, 300) == 1 and C.Morale.objective_control(s, 100) == 2, "Best living Leadership and individual OC are respected")
	check(s.units[300].ranged_weapons[0].profiles.default.name == "Leader-specific practice weapon" and s.units[100].ranged_weapons[0].profiles.default.name != "Leader-specific practice weapon", "Component weapon inventories are materialized independently before source squad is removed")
	for id in range(100, 105): s.units[id].wounds = 0
	check(C.AttackPlan.defender(s, 1).toughness == 8 and C.living(s, 1) == [300] and s.squads[1].starting_strength == 6, "Last bodyguard death does not split the attached unit or reset strength")
	s.units[300].wounds = 0
	check(C.living(s, 1).is_empty(), "Attached unit is destroyed only after its last member")
	s = fixture()
	s.revision = 1
	before = var_to_str(s)
	check(not C.Attachments.form_practice_unit(s, 1, 3).is_empty() and before == var_to_str(s), "Cannot attach during a live match")
	print("Attached unit checks: %d failures" % failures)
	quit(1 if failures else 0)
