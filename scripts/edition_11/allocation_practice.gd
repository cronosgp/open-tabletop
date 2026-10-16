extends RefCounted
## Explicit synthetic rules lab. No datasheet legality or faction abilities claimed.
const C = preload("res://scripts/edition_11/combat_scenario.gd")
static func initial_state(damage_rerolls: bool = false, count_rerolls: bool = false) -> Dictionary:
	var s := C.initial_state(C.Terrain.DEFAULT_LAYOUT, C.Objectives.TRAINING, 2, true, true)
	if s.has("error"): return s
	for id: int in s.units:
		if id not in [100, 200, 201, 202, 203, 300, 400]: s.units[id].wounds = 0
	s.units[100].position = Vector2(-12, -8)
	s.units[300].position = Vector2(-12, 8)
	s.units[400].position = Vector2(12, 8)
	for id in [200, 201, 202, 203]: s.units[id].position = Vector2(-2 + (id - 200) * 1.5, -8)
	s.squads[2].name = "Synthetic mixed allocation group"
	s.squads[2].starting_strength = 4
	for squad in [1, 3, 4]: s.squads[squad].starting_strength = 1
	s.squads[2].attached = true
	for id in [200, 201]: s.units[id].attachment_role = "bodyguard"
	s.units[200].max_wounds = 2
	s.units[200].wounds = 1
	s.units[200].defense = {"toughness": 4, "save_target": 4}
	s.units[201].max_wounds = 3
	s.units[201].wounds = 3
	s.units[201].defense = {"toughness": 5, "save_target": 2}
	s.units[201].feel_no_pain = [{"target": 5, "against": "any"}]
	for id in [202, 203]:
		s.units[id].attachment_role = "leader" if id == 202 else "support"
		s.units[id].keywords.append("Character")
		s.units[id].objective_control = 1
		s.units[id].leadership_target = 6
		s.units[id].max_wounds = 4 if id == 202 else 2
		s.units[id].wounds = s.units[id].max_wounds
		s.units[id].defense = {"toughness": 8, "save_target": 3, "invulnerable_target": 5}
	s.units[100].ranged_weapons = [{"id": "practice", "profiles": {"standard": {"name": "Synthetic Precision / Devastating rifle", "attacks": 4, "skill": 3, "strength": 8, "ap": -1, "damage": "D3", "range_inches": 30, "keywords": {"precision": true, "devastating-wounds": true}}}}]
	s.units[100].melee_weapons = [{"id": "blade", "profiles": {"standard": {"name": "Synthetic random-A blade", "attacks": "D3+1", "skill": 3, "strength": 6, "ap": -1, "damage": 2, "keywords": {}}}}, {"id": "extra", "profiles": {"standard": {"name": "Synthetic extra blade", "attacks": 1, "skill": 3, "strength": 4, "ap": 0, "damage": 1, "keywords": {"extra-attacks": true}}}}]
	s.phase = "shooting"
	s.rules_practice = true
	s.pack_hash = (str(s.pack_hash) + "synthetic-allocation-practice-v1").sha256_text()
	if count_rerolls:
		var profile: Dictionary = s.units[100].ranged_weapons[0].profiles.standard.duplicate(true)
		profile.attacks = "D3+1"
		profile.name = "Synthetic random-A practice rifle"
		s.units[100].ranged_weapons[0].profiles["random-attacks"] = profile
	if damage_rerolls or count_rerolls:
		C.Stratagems.enable(s, false, false, false, damage_rerolls, false, count_rerolls)
		s.cp = {1: 2, 2: 2}
		s.scope = "Synthetic lab starts with 2 CP per player to practice random characteristic decisions. " + s.scope
	return s
