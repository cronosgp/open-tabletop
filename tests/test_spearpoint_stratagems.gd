extends SceneTree
const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const D = preload("res://scripts/edition_11/detachment_stratagems.gd")
var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func fixture() -> Dictionary:
	var lists := F.selections()
	lists[1].entries = [
		{"definition_id": "40kdc:11e:adeptus-astartes:outrider-squad", "models": 3, "copies": 1},
		{"definition_id": "40kdc:11e:adeptus-astartes:intercessor-squad", "models": 5, "copies": 1}
	]
	var state: Dictionary = F.P.initial_state({"checked_rosters": false, "official_mission": false, "unit_abilities": true, "combat_doctrines": true, "reanimation_protocols": true, "awakened_dynasty": true, "core_stratagems": true, "manual_allocation": false}, lists)
	state.awakened_dynasty.pending = []
	state.unit_abilities.setup_players = [1, 2]
	state.unit_abilities.battle_players = [1, 2]
	state.deployment.complete = true
	state.mission.stage = "battle"
	state.phase = "command"
	state.active = 1
	state.turn = 3
	state.round = 2
	state.combat_doctrines.selected_turn[1] = state.turn
	state.unit_abilities.phase_key = C.UnitActions.key(state)
	C.Doctrines.enable(state, "spearpoint-task-force")
	D.enable_spearpoint(state)
	state.cp[1] = 3
	state.cp[2] = 3
	return state

func first_model(state: Dictionary, squad: int) -> int:
	for model: int in state.units:
		if state.units[model].squad == squad and state.units[model].wounds > 0: return model
	return -1

func first_squad(state: Dictionary, owner: int) -> int:
	for squad: int in state.squads:
		if state.squads[squad].owner == owner: return squad
	return -1

func find_squad(state: Dictionary, owner: int, identity: String) -> int:
	for squad: int in state.squads:
		if state.squads[squad].owner != owner: continue
		for model: int in D.living(state, squad):
			if C.UnitAbilities.identity(state.units[model]) == identity: return squad
	return -1

func _initialize() -> void: call_deferred("run")

func run() -> void:
	var s := fixture()
	var outriders := find_squad(s, 1, "outrider-squad")
	s.phase = "fight"
	s.fight_actor = 1
	s.fight_step = "attacks"
	s.fight_selected = outriders
	s.squads[outriders].charged = true
	var spear_use := D.apply(s, 1, {"target": outriders, "model": -1, "value": D.SPEAR_THRUST, "mode": "both"})
	var blade: Dictionary = s.squads[outriders].melee_weapon.duplicate(true)
	var empowered := D.weapon(s, outriders, blade, blade, true)
	check(D.spearpoint_mounted(s, outriders) and spear_use.error.is_empty() and s.cp[1] == 2 and empowered.keywords.get("lethal-hits", false) and empowered.keywords.get("lance", false), "Mounted Outriders receive both Spear Thrust and Sabre Swing melee traits")
	check(not D.weapon(s, outriders, blade, blade, false).keywords.get("lance", false), "Spear Thrust and Sabre Swing does not change ranged attacks")

	s = fixture()
	outriders = find_squad(s, 1, "outrider-squad")
	s.phase = "movement"
	s.active = 1
	var model := first_model(s, outriders)
	var flawless_begin := C.begin_movement(s, 1, model, "normal", s.revision)
	check(flawless_begin.is_empty(), "Mounted movement opens the Flawless Riders decision: " + flawless_begin + " / " + str(s.unit_abilities.window))
	var flawless_result := D.apply(s, 1, {"target": outriders, "model": -1, "value": D.FLAWLESS_RIDERS})
	var flawless_error: String = C.begin_movement(s, 1, model, "normal", s.revision, Callable(), false, true) if flawless_result.error.is_empty() else str(flawless_result.error)
	check(flawless_error.is_empty() and s.cp[1] == 2 and D.mobile_active(s, outriders), "Flawless Riders spends 1 CP, grants Mobile and resumes the selected move: " + flawless_error + " / " + str(flawless_result))

	s = fixture()
	var intercessors := find_squad(s, 1, "intercessor-squad")
	s.phase = "movement"
	s.active = 1
	model = first_model(s, intercessors)
	var lethality_begin := C.begin_movement(s, 1, model, "advance", s.revision, func() -> int: return 2)
	check(lethality_begin.is_empty(), "Advance opens the Mobile Lethality decision: " + lethality_begin + " / " + str(s.unit_abilities.window))
	var lethality_result := D.apply(s, 1, {"target": intercessors, "model": -1, "value": D.MOBILE_LETHALITY})
	var lethality_error: String = C.begin_movement(s, 1, model, "advance", s.revision, func() -> int: return 2, false, true) if lethality_result.error.is_empty() else str(lethality_result.error)
	s.squads[intercessors].fell_back = true
	var gun: Dictionary = s.squads[intercessors].weapon.duplicate(true)
	var assault_gun := D.weapon(s, intercessors, gun, gun, false)
	check(lethality_error.is_empty() and s.cp[1] == 2 and D.mobile_lethality_active(s, intercessors) and assault_gun.keywords.get("assault", false) and C.Doctrines.shoot_after_fallback(s, intercessors), "Mobile Lethality grants ranged Assault and shooting after Fall Back for this turn: " + lethality_error + " / " + str(lethality_result))

	s = fixture()
	outriders = find_squad(s, 1, "outrider-squad")
	s.phase = "shooting"
	s.active = 2
	s.terrain.areas = []
	var shooting_enemy := first_squad(s, 2)
	for living_model: int in s.units:
		if s.units[living_model].wounds <= 0: continue
		s.units[living_model].on_battlefield = true
		if s.units[living_model].owner == 2: s.units[living_model].position = Vector2(28, 10 + float(living_model % 3) * 1.2)
		elif s.units[living_model].squad == outriders: s.units[living_model].position = Vector2(20, 10 + float(living_model % 3) * 1.2)
	s.unit_abilities.window = {"kind": "mounted-shooting-reaction", "owners": [1], "squad": outriders, "attacker_squad": shooting_enemy, "declaration": {"player": 2, "squad": shooting_enemy, "entries": [{"target": outriders}]}}
	var evasive_error := D.use_evasive_manoeuvres(s, 1, outriders)
	var enemy_attacker := first_model(s, shooting_enemy)
	var attack_choices: Array = C.AttackPlan.Equipment.choices(s, enemy_attacker, false)
	var evasive_modifier := 0
	var evasive_plan_debug := "no ranged weapons"
	var ranged_choice: Dictionary = {}
	for candidate: Dictionary in attack_choices:
		if outriders in C.AttackPlan.legal_targets(s, enemy_attacker, false, str(candidate.weapon), str(candidate.profile)):
			ranged_choice = candidate
			break
	if not ranged_choice.is_empty():
		var enemy_plan := C.AttackPlan.prepare(s, shooting_enemy, false, [{"model": enemy_attacker, "target": outriders, "amount": 1, "weapon": ranged_choice.weapon, "profile": ranged_choice.profile}], true)
		evasive_plan_debug = str(enemy_plan)
		if enemy_plan.error.is_empty() and not enemy_plan.batches.is_empty(): evasive_modifier = int(enemy_plan.batches[0].context.wound_modifier)
	check(D.spearpoint_mounted(s, outriders) and evasive_error.is_empty() and s.cp[1] == 2 and D.evasive_active(s, outriders) and evasive_modifier == -1, "Evasive Manoeuvres spends CP before dice and applies -1 to Wound in the attack plan: " + evasive_error + " / " + evasive_plan_debug)

	s = fixture()
	outriders = find_squad(s, 1, "outrider-squad")
	s.phase = "fight"
	s.active = 2
	s.unit_abilities.window = {"kind": "end", "owners": [1]}
	var withdraw_use := D.apply(s, 1, {"target": outriders, "model": -1, "value": D.WITHDRAW_AND_REGROUP})
	var withdrawn := true
	for reserve_model: int in D.living(s, outriders):
		if s.units[reserve_model].get("on_battlefield", true): withdrawn = false
	check(withdraw_use.error.is_empty() and s.cp[1] == 2 and s.unit_abilities.reserves.has(outriders) and withdrawn, "Withdraw and Regroup moves the eligible Mounted unit into Strategic Reserves")

	s = fixture()
	intercessors = find_squad(s, 1, "intercessor-squad")
	s.phase = "movement"
	s.active = 2
	var enemy_squad := first_squad(s, 2)
	for enemy_model: int in D.living(s, enemy_squad): s.units[enemy_model].position = Vector2(4, 0)
	for friendly_model: int in D.living(s, intercessors): s.units[friendly_model].position = Vector2.ZERO
	D.record_move(s, enemy_squad)
	var hunters_use := D.apply(s, 1, {"target": intercessors, "model": -1, "value": D.HUNTERS_INSTINCTS}, func() -> int: return 2)
	check(hunters_use.error.is_empty() and s.cp[1] == 2 and s.unit_abilities.window.get("kind", "") == "tactics" and s.detachment_stratagems.tactics.get(intercessors, {}).get("inches", 0) == 5, "Hunter's Instincts reacts within 8 inches and opens a D3+3 Normal Move: " + str(hunters_use))

	print("Spearpoint stratagem checks: %d failures" % failures)
	quit(0 if failures == 0 else 1)
