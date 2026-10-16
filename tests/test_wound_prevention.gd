extends SceneTree
const C = preload("res://scripts/edition_11/combat_scenario.gd")
const P = C.Attacks.Prevention
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
	var rules := [{"target": 5, "against": "any"}]
	values = [6, 1, 1]
	var result := P.resolve(3, 2, rules, "normal", roll)
	check(result.error.is_empty() and result.lost == 2 and result.prevented == 1 and result.rolls == [6, 1, 1] and result.discarded == 0, "FNP applies to the full damage until death, not capped starting wounds")
	values = [1, 1, 6]
	result = P.resolve(3, 2, rules, "mortal", roll)
	check(result.lost == 2 and result.discarded == 1 and values == [6], "No prevention rolls for excess packet damage after death")
	values = [5, 6, 5]
	result = P.resolve(3, 1, rules, "mortal", roll)
	check(result.lost == 0 and result.prevented == 3, "Mortal prevention can preserve the chosen model through all packet wounds")
	values = [4]
	result = P.resolve(1, 2, [{"target": 6, "against": "any"}, {"target": 4, "against": "mortal"}], "mortal", roll)
	check(result.prevented == 1 and result.rolls == [4], "Best applicable FNP used once, not stacked")
	result = P.resolve(1, 2, [{"target": 2, "against": "mortal"}], "normal", roll)
	check(result.lost == 1 and result.rolls.is_empty(), "Conditional FNP does not protect other damage types")
	for invalid: Variant in [true, [{"target": 1, "against": "any"}], [{"target": 5, "against": "psychic"}], [{"target": 5, "against": "any", "extra": true}]]:
		check(not P.validate(invalid).is_empty(), "Malformed or unsupported prevention rules fail closed")
	var s := C.initial_state("legacy-solid-v1", C.Objectives.TRAINING, 2, true)
	for id: int in s.units:
		if id not in [100, 200, 201, 400]: s.units[id].wounds = 0
	s.units[100].position = Vector2(-12, -8)
	s.units[200].position = Vector2(-2, -8)
	s.units[201].position = Vector2(0, -8)
	s.units[400].position = Vector2(10, -8)
	s.phase = "shooting"
	s.squads[2].stats.wounds = 2
	for id in [200, 201]:
		s.units[id].wounds = 2
		s.units[id].max_wounds = 2
		s.units[id].feel_no_pain = rules
	s.squads[1].weapon = {"name": "FNP test", "attacks": 1, "skill": 2, "strength": 8, "ap": -6, "damage": 3, "range_inches": 30, "keywords": {}}
	values = [6, 6, 1]
	check(C.shoot(s, 1, 100, 200, 0, true, roll).error.is_empty(), "FNP target plan accepted")
	var before := var_to_str(s)
	values = [6, 0]
	check(not C.allocate_damage(s, 2, 201, s.revision, roll).is_empty() and before == var_to_str(s), "Invalid later FNP die does not partially allocate or mutate")
	values = [6, 1, 1]
	check(C.allocate_damage(s, 2, 201, s.revision, roll).is_empty() and s.units[201].wounds == 0 and s.last_attack.pools[0].prevented_wounds == 1 and s.units[200].wounds == 2, "Manual allocation records prevented wounds with no spill")
	var w: Dictionary = s.squads[1].weapon.duplicate(true)
	values = [6, 6, 1, 6, 1, 1]
	result = C.Attacks.resolve(w, {"toughness": 4, "save_target": 4, "wounds_per_model": 2, "remaining_wounds": [2, 2], "prevention": [rules, []]}, {}, roll)
	check(result.error.is_empty() and result.prevented_wounds == 1 and result.remaining_wounds == [2], "Automatic allocation retains prevention profile alignment")
	w.keywords["devastating-wounds"] = true
	values = [6, 6, 6, 6, 6]
	result = C.Attacks.resolve(w, {"toughness": 4, "save_target": 4, "wounds_per_model": 2, "remaining_wounds": [2], "prevention": [rules]}, {}, roll)
	check(result.error.is_empty() and result.mortal_damage_applied == 0 and result.prevented_wounds == 3, "Devastating mortal packet can be prevented")
	s.squads[1].shot = false
	s.squads[1].weapon.damage = "D3"
	values = [6, 6, 1]
	check(C.shoot(s, 1, 100, 200, s.revision, true, roll).error.is_empty(), "Declare random damage into a prevention model")
	values = [6, 6, 1, 1]
	check(C.allocate_damage(s, 2, 200, s.revision, roll).is_empty() and s.last_attack.pools[0].dice_history == [6, 6, 1, 6, 6, 1, 1], "History records random damage before Feel No Pain rolls in chronological order")
	s.pending_hazard = {"player": 1, "squad": 1, "remaining": 1, "resolved": {"hazardous": {"allocations": []}}}
	s.units[100].feel_no_pain = rules
	values = [0]
	before = var_to_str(s)
	check(not C.allocate_hazard(s, 1, 100, s.revision, roll).is_empty() and before == var_to_str(s), "Hazard prevention failure leaves state unchanged")
	# Keep the hazard pending after one prevented wound to avoid synthetic completion metadata.
	s.pending_hazard.remaining = 2
	values = [6]
	check(C.allocate_hazard(s, 1, 100, s.revision, roll).is_empty() and s.units[100].wounds == 2 and s.pending_hazard.remaining == 1 and s.pending_hazard.resolved.hazardous.prevention[0].prevented == 1, "Hazard mortal is consumed even when prevented")
	print("Wound prevention checks: %d failures" % failures)
	quit(1 if failures else 0)
