extends SceneTree
const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const R = preload("res://scripts/edition_11/core_reactions.gd")
const Attacks = preload("res://scripts/edition_11/attack_sequence.gd")
var failures := 0
func check(ok: bool, message: String) -> void:
	if not ok: push_error(message); failures += 1
func fixture() -> Dictionary:
	var s := F.P.initial_state({"checked_rosters":true,"official_mission":true,"unit_abilities":true,"combat_doctrines":true,"reanimation_protocols":true,"awakened_dynasty":true,"core_stratagems":true},F.selections())
	s.awakened_dynasty.pending = []
	s.unit_abilities.setup_players = [1,2]
	s.unit_abilities.battle_players = [1,2]
	s.deployment.complete = true
	s.mission.stage = "battle"
	s.phase = "movement"
	s.active = 1
	s.turn = 3
	s.round = 2
	s.unit_abilities.phase_key = C.UnitActions.key(s)
	s.cp = {1:3,2:3}
	s.terrain.areas = []
	return s
func find_choice(s: Dictionary, player: int, squad: int, value: String) -> Dictionary:
	for choice: Dictionary in C.unit_choices(s, player):
		if choice.get("action", "") in ["core-stratagem", "overwatch-pass"] and choice.target == squad and str(choice.get("value", "")) == value: return choice
	return {}
func use(s: Dictionary, player: int, squad: int, value: String) -> String:
	return C.unit_action(s, player, find_choice(s, player, squad, value), Vector2.ZERO, s.revision)
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var snap_hit := Attacks.roll_pool({"skill": 3, "strength": 4, "ap": 0, "damage": 1, "attacks": 4, "keywords": {"lethal-hits": true, "sustained-hits": 1}}, {"toughness": 4, "save_target": 7, "invulnerable_target": 0, "wounds_per_model": 1, "remaining_wounds": [1,1,1,1]}, {"weapon_count": 1, "heavy_eligible": false, "snap_shooting": true, "hit_reroll": "failed", "use_lethal_hits": true}, func() -> int: return 6)
	check(snap_hit.error.is_empty() and snap_hit.hits == 4, "Snap shooting hits only on unmodified 6s and those hits are not critical")
	var snap_miss := Attacks.roll_pool({"skill": 2, "strength": 4, "ap": 0, "damage": 1, "attacks": 4, "keywords": {}}, {"toughness": 4, "save_target": 7, "invulnerable_target": 0, "wounds_per_model": 1, "remaining_wounds": [1]}, {"weapon_count": 1, "heavy_eligible": false, "snap_shooting": true}, func() -> int: return 5)
	check(snap_miss.error.is_empty() and snap_miss.hits == 0, "Unmodified 5s miss when snap shooting")
	var s := fixture()
	check(R.enabled(s) and C.Capabilities.supported("fire-overwatch") and C.Capabilities.enabled(s, "fire-overwatch"), "Checked matches enable the infantry core reactions")
	for model: int in C.living(s, 1): s.units[model].position = Vector2(0, 0)
	for model: int in C.living(s, 4): s.units[model].position = Vector2(8, 0)
	s.unit_abilities.window = {"kind": "end", "owners": [2]}
	check(not find_choice(s, 2, 4, R.OVERWATCH).is_empty(), "Fire Overwatch is offered at the end of the opponent Movement phase")
	check(use(s, 2, 4, R.OVERWATCH).is_empty() and s.cp[2] == 2 and C.actor(s) == 2 and R.overwatch_shooter(s, 4), "Overwatch spends 1 CP and gives the reacting unit the next shooting window")
	check(C.attack_window_error(s, 2, 400, s.revision, false).is_empty(), "Overwatch shooting is legal during Movement")
	check(not C.attack_window_error(s, 2, 400, s.revision, true).is_empty(), "Overwatch cannot be used as a melee attack")
	var targets := C.AttackPlan.legal_targets(s, 400, false)
	check(1 in targets, "Overwatch can see the moving enemy within 24 inches")
	var far := s.duplicate(true)
	far.units[400].position = Vector2(40, 0)
	check(not C.AttackPlan.legal_targets(far, 400, false).has(1), "Overwatch cannot pick a target beyond 24 inches")
	var prepared := C.AttackPlan.prepare(s, 4, false, C.AttackPlan.single_target(s, 4, 1, false), true)
	check(prepared.error.is_empty() and prepared.batches[0].context.get("snap_shooting", false) and prepared.batches[0].context.get("hit_reroll", "none") == "none", "Overwatch plans snap shooting without hit rerolls")
	s = fixture()
	s.phase = "charge"
	s.active = 1
	s.unit_abilities.phase_key = C.UnitActions.key(s)
	for model: int in C.living(s, 1): s.units[model].position = Vector2(0, 0)
	for model: int in C.living(s, 4): s.units[model].position = Vector2(8, 0)
	s.core_reactions.chargers = [1]
	s.squads[1].charge_declared = true
	s.unit_abilities.window = {"kind": "end", "owners": [2]}
	check(not find_choice(s, 2, 4, R.HEROIC).is_empty() and not find_choice(s, 2, 4, R.FRAY).is_empty(), "Both Heroic Intervention modes are offered at the end of the opponent Charge phase")
	check(use(s, 2, 4, R.HEROIC).is_empty() and s.cp[2] == 2 and C.actor(s) == 2 and R.heroic_charger(s, 2, 4), "Leap to Defend spends 1 CP and opens a charge for the reacting unit")
	var declared := C.declare_charge(s, 2, 400, s.revision, func() -> int: return 6)
	if not C.Stratagems.pending(s).is_empty(): check(C.resolve_roll_reaction(s, 2, 4, "", s.revision).is_empty(), "Leap charge window can be accepted")
	check(declared.error.is_empty() and int(s.pending_charge.get("maximum", 0)) == 12, "Leap to Defend uses a normal 2D6 charge")
	check(C.select_charge_target(s, 2, 100, s.revision).error.is_empty(), "Leap to Defend can target the unit that declared a charge")
	s = fixture()
	s.phase = "charge"
	s.active = 1
	s.unit_abilities.phase_key = C.UnitActions.key(s)
	for model: int in C.living(s, 1): s.units[model].position = Vector2(0, 0)
	for model: int in C.living(s, 4): s.units[model].position = Vector2(4, 0)
	s.unit_abilities.window = {"kind": "end", "owners": [2]}
	check(use(s, 2, 4, R.FRAY).is_empty() and s.cp[2] == 1, "Into the Fray costs 2 CP")
	var fray := C.declare_charge(s, 2, 400, s.revision, func() -> int: return 6)
	if not C.Stratagems.pending(s).is_empty(): check(C.resolve_roll_reaction(s, 2, 4, "", s.revision).is_empty(), "Fray charge window can be accepted")
	check(fray.error.is_empty() and int(s.pending_charge.get("maximum", 0)) == 6, "Into the Fray caps the charge roll at 6")
	s = fixture()
	s.phase = "fight"
	s.fight_step = "attacks"
	s.active = 1
	s.fight_actor = 1
	s.unit_abilities.phase_key = C.UnitActions.key(s)
	for model: int in C.living(s, 1): s.units[model].position = Vector2(0, 0)
	for model: int in C.living(s, 4): s.units[model].position = Vector2(1.2, 0)
	s.squads[1].fought = true
	s.squads[1].was_engaged = true
	s.squads[4].fought = false
	s.squads[4].was_engaged = true
	check(R.offer_counter(s, 1) and s.unit_abilities.window.kind == "counter" and C.actor(s) == 2, "Counteroffensive opens after an enemy unit fights in the opponent Fight phase")
	check(use(s, 2, 4, R.COUNTER).is_empty() and s.cp[2] == 1 and s.fight_selected == 4 and s.squads[4].fights_first, "Counteroffensive spends 2 CP and gives Fights First to the reacting unit")
	s = fixture()
	s.phase = "fight"
	s.fight_step = "attacks"
	s.active = 1
	s.fight_actor = 1
	s.fight_selected = -1
	s.unit_abilities.phase_key = C.UnitActions.key(s)
	s.squads[3].was_engaged = true
	s.squads[3].fought = false
	check(not find_choice(s, 1, 3, R.EPIC).is_empty(), "Epic Challenge is offered for a Character unit selected to fight")
	check(use(s, 1, 3, R.EPIC).is_empty() and s.cp[1] == 2 and s.fight_selected == 3, "Epic Challenge spends 1 CP and locks the Character unit")
	var melee: Dictionary = s.squads[3].melee_weapon.duplicate(true)
	var boosted := R.weapon(s, 300, melee, true)
	check(boosted.keywords.get("precision", false) and not R.weapon(s, 300, melee, false).keywords.get("precision", false), "Epic Challenge grants melee Precision only to the chosen Character model")
	print("Core reaction stratagem checks: %d failures" % failures)
	quit(0 if failures == 0 else 1)
