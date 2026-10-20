extends SceneTree
## Current Wahapedia e11 scope: fixed infantry profiles and their admitted attachments.
const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const A = C.UnitAbilities
const U = C.UnitActions
const E = preload("res://scripts/edition_11/equipment.gd")
var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func fresh() -> Dictionary:
	var s := F.fresh()
	s.awakened_dynasty.pending = []
	s.unit_abilities.setup_players = [1, 2]
	s.phase = "shooting"
	s.active = 1
	s.turn = 3
	s.round = 2
	s.unit_abilities.phase_key = U.key(s)
	s.terrain.areas = []
	for model: int in s.units:
		s.units[model].position = Vector2(-20, -10) if s.units[model].owner == 1 else Vector2(20, 10)
	return s

func act(s: Dictionary, action: String, model: int = -2, target: int = -2, value: String = "") -> String:
	for choice: Dictionary in C.unit_choices(s, 1):
		if choice.action == action and (model == -2 or choice.model == model) and (target == -2 or choice.target == target) and (value.is_empty() or choice.value == value):
			return C.unit_action(s, 1, choice, Vector2.ZERO, s.revision, func() -> int: return 6)
	return "No eligible choice: " + action

func marker(s: Dictionary, owner: int = 1) -> void:
	s.mission.objectives = [{"kind": "marker", "position": Vector2.ZERO, "name": "Boundary objective", "controller": owner, "secured": 0}]

func _initialize() -> void:
	var s := fresh()
	U.attach(s, 300, 7)
	# Attachment rebuilds pre-battle deployment; enter the phase under test afterwards.
	s.phase = "shooting"
	s.unit_abilities.phase_key = U.key(s)
	marker(s)
	s.units[700].position = Vector2.ZERO
	check(A.hit_bonus(s, 7, 2, false) == 1, "Bolter Discipline propagates from live Intercessors to attached unit")
	s.active = 2
	check(A.hit_bonus(s, 7, 2, false) == 0, "Bolter Discipline is unavailable in opponent Shooting")
	s.active = 1
	check(A.hit_bonus(s, 7, 2, true) == 0, "Bolter Discipline never modifies melee")
	s.units[700].position = Vector2(-20, -10)
	s.units[200].position = Vector2.ZERO
	check(A.hit_bonus(s, 7, 2, false) == 1, "Target objective proximity also qualifies Bolter Discipline")
	s.squads[7].battle_shocked = true
	check(C.Actions.eligibility_error(s, 7).is_empty(), "Tactical Mainstay permits action eligibility despite Battle-shock")
	s.squads[7].advanced = true
	check(not C.Actions.eligibility_error(s, 7).is_empty(), "Mainstay does not waive the Advance action restriction")
	s.squads[7].advanced = false
	s.squads[7].fell_back = true
	check(not C.Actions.eligibility_error(s, 7).is_empty(), "Mainstay does not waive the Fall Back action restriction")
	s.squads[7].fell_back = false
	s.squads[7].battle_shocked = false
	C.Actions.start(s, 7, 0)
	check(not C.Actions.shooting_blocked(s, 7) and C.Actions.charge_blocked(s, 7), "Mainstay removes action shooting restriction but not charge restriction")
	for id: int in range(700, 705): s.units[id].wounds = 0
	check(A.hit_bonus(s, 7, 2, false) == 0 and s.units[300].wounds > 0, "Surviving Captain does not retain destroyed Intercessors' ability")
	check(C.Actions.shooting_blocked(s, 7), "Captain without surviving Intercessors no longer has Mainstay shooting exception")

	s = fresh()
	marker(s)
	s.units[500].position = Vector2.ZERO
	check(A.save_bonus(s, 5) == 1, "Heavy Intercessors benefit while controlling objective")
	s.mission.objectives[0].controller = 2
	check(A.save_bonus(s, 5) == 0, "Proximity to enemy-controlled objective does not grant save bonus")
	s.mission.objectives[0].controller = 1
	for id: int in range(500, 505): s.units[id].objective_control = 0
	check(A.save_bonus(s, 5) == 0, "Zero-OC unit cannot satisfy controlling-unit requirement")

	s = fresh()
	U.attach(s, 900, 1)
	var blade: Dictionary = E.select(s, 900, true).stats
	var original := var_to_bytes(blade)
	s.squads[1].charged = true
	var changed := A.weapon(s, 900, 2, blade, true)
	check(changed.strength == blade.strength + 1 and changed.ap == blade.ap - 1 and changed.keywords.get("lethal-hits", false), "Assault charge bonus and Lieutenant Lethal Hits combine on attached Lieutenant")
	check(var_to_bytes(blade) == original, "Ability modifiers do not mutate the base weapon")
	s.squads[1].charged = false
	changed = A.weapon(s, 900, 2, blade, true)
	check(changed.strength == blade.strength and changed.ap == blade.ap, "Targeted Intercession requires a charge this turn")
	s.squads[1].charged = true
	for id: int in range(100, 105): s.units[id].wounds = 0
	changed = A.weapon(s, 900, 2, blade, true)
	check(changed.strength == blade.strength and changed.ap == blade.ap and changed.keywords.get("lethal-hits", false), "After bodyguards die, Lieutenant keeps own ability but loses Assault Intercessors' source")
	s.units[100].wounds = 2
	s.units[900].wounds = 0
	changed = A.weapon(s, 100, 2, E.select(s, 100, true).stats, true)
	check(not changed.keywords.get("lethal-hits", false), "Bodyguard does not retain dead Lieutenant's Lethal Hits")
	s.units[900].wounds = 4
	s.units[200].keywords.append("MONSTER")
	check(not A.weapon(s, 900, 2, blade, true).keywords.get("lethal-hits", false), "Tactical Precision excludes a target unit with Monster keyword")

	s = fresh()
	s.units[1100].position = Vector2.ZERO
	var offset: float = s.units[1100].radius + s.units[200].radius
	s.units[200].position = Vector2(9.0 + offset, 0)
	var gun: Dictionary = E.select(s, 1100, false).stats
	check(A.weapon(s, 1100, 2, gun, false).ap == gun.ap - 1, "Fury of the First includes exact nine-inch base-edge boundary")
	s.units[200].position.x += 0.01
	check(A.weapon(s, 1100, 2, gun, false).ap == gun.ap, "Fury of the First excludes targets beyond nine-inch tolerance")

	s = fresh()
	U.attach(s, 300, 7)
	U.attach(s, 900, 1)
	s.phase = "command"
	s.unit_abilities.phase_key = U.key(s)
	check(C.select_combat_doctrine(s, 1, "none", s.revision).is_empty(), "Resolve initial army doctrine decision")
	check(act(s, "acumen", 300, 7, "assault").is_empty(), "Captain selects local doctrine through public command")
	var restored: Dictionary = bytes_to_var(var_to_bytes(s))
	check(U.pending(restored).get("kind", "") == "demi" and act(restored, "demi", 900, 1).is_empty(), "Serialized Captain trigger preserves Lieutenant reaction")
	check(not act(restored, "demi", 900, 1).is_empty(), "Demi-company Commander cannot be repeated in same turn")
	check(act(restored, "pass").is_empty(), "Close reaction window")
	check(not act(restored, "acumen", 300, 7, "tactical").is_empty(), "Captain cannot use Strategic Acumen twice in own Command")
	restored.active = 2
	A.start_command(restored)
	check(A.doctrine(restored, 7) == "assault" and A.doctrine(restored, 1) == "assault", "Local doctrines persist through opponent Command")
	restored.active = 1
	A.start_command(restored)
	check(A.doctrine(restored, 7).is_empty() and A.doctrine(restored, 1).is_empty(), "Both doctrines expire at next own Command")

	s = fresh()
	U.attach(s, 300, 7)
	s.phase = "fight"
	s.fight_step = "attacks"
	s.fight_actor = 1
	s.squads[7].charged = true
	s.unit_abilities.phase_key = U.key(s)
	check(act(s, "finest", 300, 7).is_empty(), "Finest Hour requires and locks an eligible fighting unit")
	check(E.select(s, 300, true).stats.attacks == 9 and E.select(s, 700, true).stats.attacks == 3, "Finest Hour changes Captain attacks only, not attached Intercessors")
	s.turn += 1
	check(E.select(s, 300, true).stats.attacks == 6, "Finest Hour active attack bonus does not leak into later turns")
	check(not act(s, "finest", 300, 7).is_empty(), "Finest Hour once-per-battle use survives turn changes")
	print("Marine ability boundary checks: %d failures" % failures)
	quit(1 if failures else 0)
