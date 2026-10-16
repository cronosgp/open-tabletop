extends SceneTree
const C = preload("res://scripts/edition_11/combat_scenario.gd")
const A = C.Attacks
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
func weapon(attacks: int = 2) -> Dictionary:
	return {"name": "Devastating test", "attacks": attacks, "skill": 2, "strength": 8, "ap": -2, "damage": 3, "keywords": {"devastating-wounds": true}}
func defender() -> Dictionary:
	return {"toughness": 4, "save_target": 2, "invulnerable_target": 2, "wounds_per_model": 2, "remaining_wounds": [2, 2, 2]}
func resolve(w: Dictionary, d: Dictionary, dice: Array, context: Dictionary = {}) -> Dictionary:
	values = dice
	calls = 0
	return A.resolve(w, d, context, roll)
func fixture(random_damage: bool = false) -> Dictionary:
	var s := C.initial_state("legacy-solid-v1", C.Objectives.TRAINING, 2, true, true)
	for id: int in s.units:
		if id not in [100, 200, 201, 202, 400]: s.units[id].wounds = 0
	s.units[100].position = Vector2(-4, -8)
	for id in [200, 201, 202]:
		s.units[id].position = Vector2(-2 + (id - 200) * 1.5, -8)
		s.units[id].wounds = 2
		s.units[id].max_wounds = 2
	s.units[400].position = Vector2(10, -8)
	s.squads[2].stats.wounds = 2
	s.phase = "fight"
	s.fight_step = "attacks"
	s.fight_actor = 1
	s.squads[1].charged = true
	if random_damage:
		for instance: Dictionary in s.units[100].melee_weapons:
			if instance.id == "hammer": instance.profiles.standard.damage = "D6"
	return s
func plan() -> Array:
	return [{"model": 100, "target": 2, "amount": 3, "weapon": "hammer", "profile": "standard"}]
func begin(s: Dictionary, dice: Array) -> Dictionary:
	values = dice
	calls = 0
	return C.resolve_attack_plan(s, 1, 100, plan(), s.revision, true, true, roll)
func _initialize() -> void:
	var result := resolve(weapon(), defender(), [6, 6, 6, 6])
	check(result.error.is_empty() and calls == 4 and result.save_rolls.is_empty() and result.devastating_wounds == 2, "Critical wounds bypass armour and invulnerable saves")
	check(result.mortal_damage_applied == 4 and result.normal_damage_applied == 0 and result.excess_damage_discarded == 2 and result.remaining_wounds == [2] and result.unsaved == 0, "Each critical damages one model and excess is discarded")
	result = resolve(weapon(), defender(), [6, 6, 6, 3, 1])
	check(result.error.is_empty() and result.normal_damage_applied == 2 and result.mortal_damage_applied == 2 and result.save_rolls == [1], "Mixed normal and devastating wounds only roll normal saves")
	var w := weapon(1)
	w.keywords["lethal-hits"] = true
	result = resolve(w, defender(), [6, 1])
	check(result.error.is_empty() and result.devastating_wounds == 0 and result.wound_rolls.is_empty(), "Lethal automatic wound is not a critical wound")
	result = resolve(w, defender(), [6, 6], {"use_lethal_hits": false})
	check(result.error.is_empty() and result.devastating_wounds == 1, "Declining Lethal allows a critical wound")
	w = weapon(1)
	w.keywords["twin-linked"] = true
	result = resolve(w, defender(), [6, 1, 6])
	check(result.error.is_empty() and result.devastating_wounds == 1 and result.wound_rolls == [1, 6], "Twin-linked reroll can produce a critical wound")
	w = weapon(1)
	result = resolve(w, defender(), [6, 5, 1], {"wound_modifier": 1})
	check(result.error.is_empty() and result.devastating_wounds == 0, "Modified five is not a critical six")
	result = resolve(w, defender(), [6, 6], {"wound_modifier": -1})
	check(result.error.is_empty() and result.devastating_wounds == 1, "Unmodified six remains critical with negative modifier")
	w.keywords["torrent"] = true
	result = resolve(w, defender(), [6])
	check(result.error.is_empty() and result.devastating_wounds == 1, "Torrent can trigger Devastating Wounds")
	w.keywords = {"devastating-wounds": true, "sustained-hits": 1}
	result = resolve(w, defender(), [6, 6, 6])
	check(result.error.is_empty() and result.devastating_wounds == 2, "Sustained extra hits roll wounds independently")
	w = weapon(1)
	w.damage = "D6"
	result = resolve(w, defender(), [6, 6, 6])
	check(result.error.is_empty() and result.damage_rolls[0].value == 6 and result.excess_damage_discarded == 4, "Random mortal damage remains one packet per critical")
	var s := fixture()
	result = begin(s, [6, 6, 1, 6, 3, 1])
	check(result.error.is_empty() and s.pending_attack.current.steps[0].kind == "normal" and s.pending_attack.current.steps[1].kind == "devastating" and C.actor(s) == 2, "Defender allocates normal damage before mortal packets")
	var before := var_to_str(s)
	check(not C.allocate_damage(s, 1, 201, s.revision, roll).is_empty() and before == var_to_str(s), "Wrong player cannot allocate mortals or normal damage")
	check(C.allocate_damage(s, 2, 201, s.revision, roll).is_empty() and s.units[201].wounds == 0 and s.pending_attack.current.steps[s.pending_attack.current.cursor].kind == "devastating" and not s.squads[1].fought, "Normal damage finishes before defender chooses mortal recipient")
	check(C.allocate_damage(s, 2, 202, s.revision, roll).is_empty() and s.pending_attack.is_empty() and s.units[202].wounds == 0 and s.units[200].wounds == 2 and s.squads[1].fought, "Defender can select another model for one mortal packet without spill")
	check(s.last_attack.pools[0].allocations[1].kind == "devastating" and s.last_attack.pools[0].mortal_damage_applied == 2, "History distinguishes mortal and normal damage")
	s = fixture(true)
	result = begin(s, [6, 1, 1, 6])
	check(result.error.is_empty() and calls == 4 and s.pending_attack.current.steps[0].kind == "devastating", "Random D is not rolled before mortal recipient choice")
	before = var_to_str(s)
	values = [0]
	check(not C.allocate_damage(s, 2, 200, s.revision, roll).is_empty() and before == var_to_str(s), "Bad random mortal damage die preserves pending state")
	values = [6]
	check(C.allocate_damage(s, 2, 201, s.revision, roll).is_empty() and s.last_attack.pools[0].allocations[0].rolled_damage == 6 and s.units[200].wounds == 2, "Random mortal damage rolls after accepted choice")
	s = fixture()
	s.units[200].wounds = 1
	begin(s, [6, 1, 1, 6])
	check(C.Allocation.eligible(s) == [200], "Wounded recipient priority also applies to devastating mortal wounds")
	s = fixture()
	s.manual_allocation = false
	result = begin(s, [6, 6, 6, 3, 6, 6, 1])
	check(result.error.is_empty() and s.squads[1].fought and s.last_attack.pools[0].mortal_damage_applied == 4 and s.last_attack.pools[0].normal_damage_applied == 2, "Automatic assist resolves the imported hammer's normal and mortal damage")
	s = fixture(true)
	s.units[201].wounds = 0
	s.units[202].wounds = 0
	begin(s, [6, 6, 1, 3, 6, 1])
	values = [2]
	check(C.allocate_damage(s, 2, 200, s.revision, roll).is_empty() and s.pending_attack.is_empty() and calls == 7 and s.last_attack.pools[0].devastating_attacks_resolved == 0, "Unit destroyed by normal damage discards mortal attacks without extra damage dice")
	s = fixture()
	for instance: Dictionary in s.units[100].melee_weapons:
		if instance.id == "hammer": instance.profiles.standard.keywords.hazardous = true
	begin(s, [6, 1, 1, 6])
	check(s.pending_hazard.is_empty() and not s.squads[1].fought, "Hazard tests wait for defender's devastating damage choice")
	values = [2]
	check(C.allocate_damage(s, 2, 200, s.revision, roll).is_empty() and not s.pending_hazard.is_empty() and C.actor(s) == 1 and not s.squads[1].fought, "Hazardous owner allocation follows devastating wounds before fight completion")
	check(C.allocate_hazard(s, 1, 100, s.revision).is_empty() and s.squads[1].fought, "Last hazard completes the fight once")
	s = fixture()
	s.phase = "shooting"
	s.units[100].position = Vector2(-12, -8)
	s.units[100].ranged_weapons = [{"id": "test", "profiles": {"standard": weapon(1)}}]
	s.units[100].ranged_weapons[0].profiles.standard.range_inches = 30
	values = [6, 6]
	var ranged := [{"model": 100, "target": 2, "amount": 1, "weapon": "test", "profile": "standard"}]
	result = C.resolve_attack_plan(s, 1, 100, ranged, s.revision, false, true, roll)
	check(result.error.is_empty() and s.pending_attack.current.steps[0].kind == "devastating", "Ranged Devastating Wounds uses the same defended allocation lifecycle")
	print("Devastating Wounds checks: %d failures" % failures)
	quit(1 if failures else 0)
