extends RefCounted
const C = preload("res://scripts/edition_11/combat_scenario.gd")
static func state(precision: bool = false, devastating: bool = false, manual: bool = true, terrain: String = "legacy-solid-v1") -> Dictionary:
	var s := C.initial_state(terrain, C.Objectives.TRAINING, 2, manual)
	for id: int in s.units:
		if id not in [100, 200, 201, 202, 203, 400]: s.units[id].wounds = 0
	s.units[100].position = Vector2(-12, -8)
	s.units[400].position = Vector2(10, -8)
	for id in [200, 201, 202, 203]: s.units[id].position = Vector2(-2 + (id - 200) * 1.5, -8)
	s.units[200].max_wounds = 2
	s.units[200].wounds = 1
	s.units[200].defense = {"toughness": 4, "save_target": 4}
	s.units[201].max_wounds = 3
	s.units[201].wounds = 3
	s.units[201].defense = {"toughness": 5, "save_target": 2}
	s.units[202].max_wounds = 4
	s.units[202].wounds = 4
	s.units[202].defense = {"toughness": 8, "save_target": 3}
	s.units[202].keywords.append("Character")
	s.units[203].max_wounds = 2
	s.units[203].wounds = 1
	s.units[203].defense = {"toughness": 6, "save_target": 5}
	s.units[203].keywords.append("Character")
	s.squads[2].attached = true
	s.phase = "shooting"
	var keywords: Dictionary = {}
	if precision: keywords.precision = true
	if devastating: keywords["devastating-wounds"] = true
	s.squads[1].weapon = {"name": "Mixed defense test", "attacks": 2, "skill": 2, "strength": 8, "ap": 0, "damage": 2, "range_inches": 30, "keywords": keywords}
	return s
