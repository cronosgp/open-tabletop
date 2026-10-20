extends SceneTree
const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const D = preload("res://scripts/edition_11/detachment_stratagems.gd")
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
	s.phase = "command"
	s.active = 1
	s.turn = 3
	s.round = 2
	s.unit_abilities.phase_key = C.UnitActions.key(s)
	s.combat_doctrines.selected_turn[1] = s.turn
	s.cp = {1:3,2:3}
	s.terrain.areas = []
	return s
func find_choice(s: Dictionary, player: int, squad: int, value: String) -> Dictionary:
	for choice: Dictionary in C.unit_choices(s,player):
		if choice.action == "detachment-stratagem" and choice.target == squad and choice.value == value: return choice
	return {}
func use(s: Dictionary, player: int, squad: int, value: String) -> String:
	return C.unit_action(s,player,find_choice(s,player,squad,value),Vector2.ZERO,s.revision,func() -> int: return 6)
func target_reaction(s: Dictionary, player: int, target: int, attacker: int, kind: String, stratagem: String = "") -> void:
	s.unit_abilities.window = {"kind": kind, "owners": [player], "squad": target, "attacker_squad": attacker, "stratagem": stratagem, "declaration": {"player": int(s.squads[attacker].owner), "squad": attacker, "entries": [{"target": target}]}}
func find_action(s: Dictionary, player: int, action: String, target: int) -> Dictionary:
	for choice: Dictionary in C.unit_choices(s,player):
		if choice.action == action and choice.target == target: return choice
	return {}
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var s := fixture()
	check(D.enabled(s) and D.enabled(F.fresh()),"Prepared training and checked-roster matches enable their declared stratagem effects")
	s.combat_doctrines.active[1] = "devastator"
	var uses := var_to_bytes(s.combat_doctrines.used)
	check(use(s,1,1,"assault").is_empty() and s.cp[1] == 2 and C.Doctrines.active_for(s,1) == "assault" and C.Doctrines.active_for(s,5) == "devastator","Adaptive spends one CP, replaces only target doctrine and leaves other units unchanged")
	check(var_to_bytes(s.combat_doctrines.used) == uses and not s.combat_doctrines.extra_used.get(1,false),"Stratagem does not consume army doctrine or Codex Discipline uses")
	s.squads[1].advanced = true
	check(C.Doctrines.charge_error(s,1).is_empty() and not C.Doctrines.weapon(s,1,s.squads[1].weapon,false).keywords.get("assault",false),"Assault override grants charge after Advance without stacking old Devastator")
	var before := var_to_bytes(s)
	check(not use(s,1,5,"tactical").is_empty() and var_to_bytes(s) == before,"Once-per-phase rejection is transactional")
	s.active = 2
	C.UnitAbilities.start_command(s)
	check(C.Doctrines.active_for(s,1) == "assault","Doctrine persists through opponent Command")
	s.active = 1
	C.UnitAbilities.start_command(s)
	check(C.UnitAbilities.doctrine(s,1).is_empty(),"Expires at next own Command")
	s = fixture()
	for model: int in s.units:
		if s.units[model].squad == 11: s.units[model].on_battlefield = false
	check(not find_choice(s,1,11,"tactical").is_empty(),"A living reserve unit can receive an army-targeted Command stratagem")
	s.cp[1] = 0
	check(find_choice(s,1,1,"tactical").is_empty(),"Insufficient CP cannot spend or advertise strategy")
	s.cp[1] = 2
	s.squads[1].battle_shocked = true
	check(find_choice(s,1,1,"tactical").is_empty() and find_choice(s,2,1,"tactical").is_empty(),"Battle-shocked/foreign targets rejected")
	s = fixture()
	s.stratagems.uses.append({"player":1,"squad":1,"stratagem":"command-re-roll","phase_key":C.UnitActions.key(s),"turn":s.turn})
	check(find_choice(s,1,1,"tactical").is_empty(),"One friendly stratagem per unit per phase shared with core usage")
	s = fixture()
	C.UnitActions.attach(s,600,4)
	s.phase = "fight"
	s.fight_actor = 1
	s.fight_selected = -1
	s.unit_abilities.phase_key = C.UnitActions.key(s)
	var profile: Dictionary = s.squads[4].melee_weapon.duplicate(true)
	check(use(s,2,4,D.HUNGRY).is_empty() and s.cp[2] == 2,"Either turn Fight allows eligible opponent-owned Hungry Void")
	var boosted := D.weapon(s,4,profile,profile,true)
	check(boosted.strength == profile.strength+1 and boosted.ap == profile.ap-1 and D.weapon(s,4,profile,profile,false) == profile,"Led bonus changes only melee S/AP without mutating base weapon")
	var improved: Dictionary = profile.duplicate(true)
	improved.ap -= 2
	check(D.weapon(s,4,profile,improved,true).ap == improved.ap,"AP improvement does not stack with a stronger improvement")
	var weaker: Dictionary = profile.duplicate(true)
	weaker.ap += 1
	check(D.weapon(s,4,profile,weaker,true).ap == profile.ap,"AP improvement preserves a separate worsening modifier")
	var selected := find_choice(s,2,4,D.HUNGRY)
	check(selected.is_empty() and not C.Stratagems.eligibility_error(s,2,4,"insane-bravery").is_empty(),"Detachment usage blocks repeat and another friendly core stratagem")
	s.units[600].wounds = 0
	check(D.weapon(s,4,profile,profile,true).ap == profile.ap-1,"Activated phase effect retains its led condition after leader death")
	s.turn += 1
	check(D.weapon(s,4,profile,profile,true) == profile,"Same-named next Fight phase cannot retain old effect")
	s = fixture()
	s.phase = "fight"
	s.unit_abilities.phase_key = C.UnitActions.key(s)
	s.fight_selected = 4
	check(find_choice(s,2,4,D.HUNGRY).is_empty(),"Already selected unit cannot receive Hungry Void")
	s.fight_selected = -1
	s.squads[4].fought = true
	check(find_choice(s,2,4,D.HUNGRY).is_empty(),"Already fought unit cannot receive Hungry Void")
	s.squads[4].fought = false
	check(use(s,2,4,D.HUNGRY).is_empty(),"Unled unit still receives strength bonus")
	profile = s.squads[4].melee_weapon.duplicate(true)
	boosted = D.weapon(s,4,profile,profile,true)
	check(boosted.strength == profile.strength+1 and boosted.ap == profile.ap,"Unled unit receives no AP bonus")
	s = fixture()
	C.UnitActions.attach(s,600,4)
	s.phase = "fight"
	s.unit_abilities.phase_key = C.UnitActions.key(s)
	s.unit_abilities.discount_armed[4] = s.round
	s.cp[2] = 0
	check(use(s,2,4,D.HUNGRY).is_empty() and s.cp[2] == 0 and s.unit_abilities.discounts[2] == s.round,"My Will Be Done discounts once and consumes its shared round use")
	# Actual attack preparation must freeze the modified profile, including mixed attached weapons.
	s.units[400].position = Vector2.ZERO
	s.units[100].position = Vector2(0.8,0)
	s.fight_step = "attacks"
	s.fight_actor = 2
	var rows: Array = []
	for model: int in D.G.alive(s,4):
		if model not in [400,600]: s.units[model].wounds = 0
	s.units[600].position = Vector2(0,0.8)
	for model in [400,600]:
		var choices := C.AttackPlan.Equipment.choices(s,model,true)
		for weapon: Dictionary in choices:
			if weapon.stats.keywords.get("extra-attacks",false): continue
			rows.append({"model":model,"target":1,"amount":int(weapon.stats.attacks),"weapon":weapon.weapon,"profile":weapon.profile})
			break
	var plan := C.AttackPlan.prepare(s,4,true,rows,true)
	check(plan.error.is_empty(),"Actual mixed attached melee plan admits buffed fixed weapons: " + str(plan.get("error", "")))
	if plan.error.is_empty():
		for batch: Dictionary in plan.batches: check(batch.weapon.strength >= 5,"Frozen attack batches include Hungry Void strength")
	s = fixture()
	s.phase = "shooting"
	s.unit_abilities.phase_key = C.UnitActions.key(s)
	var gun: Dictionary = s.squads[1].weapon.duplicate(true)
	s.squads[1].shot = true
	check(find_choice(s,1,1,D.STORM).is_empty() and not find_choice(s,1,5,D.STORM).is_empty(),"A unit that already shot cannot receive Storm")
	s.squads[1].shot = false
	check(use(s,1,1,D.STORM).is_empty() and s.cp[1] == 2,"Storm of Devastation spends one CP in the owner's Shooting phase")
	var stormed := D.weapon(s,1,gun,gun,false)
	check(stormed.keywords.get("ignores-cover",false) and not D.weapon(s,1,gun,gun,true).keywords.get("ignores-cover",false) and gun.keywords.get("ignores-cover",false) == false,"Storm grants Ignores Cover to ranged copies only")
	check(find_choice(s,1,5,D.STORM).is_empty() and find_choice(s,2,4,D.STORM).is_empty(),"Storm is once per phase and Marine-only")
	s = fixture()
	s.phase = "shooting"
	s.active = 2
	s.unit_abilities.phase_key = C.UnitActions.key(s)
	target_reaction(s,1,1,2,D.ARMOUR_WINDOW)
	var armour_choice := find_action(s,1,"armour-use",1)
	check(not armour_choice.is_empty(),"Armour of Contempt is offered to the Gladius player after an enemy targets its unit")
	gun = s.squads[4].weapon.duplicate(true)
	gun.ap = -2
	var armour_error := D.use_armour(s,1,1,2)
	check(armour_error.is_empty() and s.cp[1] == 2,"Armour of Contempt spends one CP and binds the declared attacker")
	var shielded := D.defend(s,2,1,gun)
	check(shielded.ap == -1 and D.defend(s,4,1,gun).ap == -2 and gun.ap == -2,"Armour worsens AP for the first attacking unit only and does not mutate the source profile")
	s = fixture()
	s.phase = "fight"
	s.fight_actor = 1
	s.fight_selected = 1
	s.squads[1].charged = true
	s.unit_abilities.phase_key = C.UnitActions.key(s)
	var blade: Dictionary = s.squads[1].melee_weapon.duplicate(true)
	check(use(s,1,1,D.MIGHT).is_empty() and D.weapon(s,1,blade,blade,true).keywords.get("lance",false) and D.lance_wound(s,1,D.weapon(s,1,blade,blade,true)),"Might of Angels grants Lance to charging melee")
	s.squads[1].charged = false
	check(not D.lance_wound(s,1,D.weapon(s,1,blade,blade,true)),"Lance does not add a wound bonus unless the unit Charged")
	s = fixture()
	s.phase = "movement"
	s.active = 2
	s.unit_abilities.phase_key = C.UnitActions.key(s)
	s.squads[4].advanced = true
	check(use(s,2,4,D.SUDDEN).is_empty() and D.weapon(s,4,s.squads[4].weapon,s.squads[4].weapon,false).keywords.get("assault",false),"Sudden Storm grants ranged Assault for the rest of the turn")
	s.turn += 1
	check(not D.weapon(s,4,s.squads[4].weapon,s.squads[4].weapon,false).keywords.get("assault",false),"Sudden Storm does not persist into the next turn")
	s = fixture()
	s.phase = "shooting"
	s.active = 2
	s.unit_abilities.phase_key = C.UnitActions.key(s)
	check(use(s,2,4,D.TYRANT).is_empty() and D.hit_policy(s,4,8.0,24.0) == "ones" and D.hit_policy(s,4,13.0,24.0) == "","Unled Conquering Tyrant re-rolls hit 1s only within half range")
	s.detachment_stratagems.tyrant[4].led = true
	check(D.hit_policy(s,4,8.0,24.0) == "failed","Led Conquering Tyrant re-rolls all failed hits within half range")
	s = fixture()
	s.phase = "fight"
	s.unit_abilities.phase_key = C.UnitActions.key(s)
	s.active = 2
	target_reaction(s,1,1,2,D.WORTHY_WINDOW,D.WORTHY)
	var worthy_choice := find_choice(s,1,1,D.WORTHY)
	var worthy_result := D.apply(s,1,worthy_choice,func() -> int: return 6)
	check(worthy_result.error.is_empty() and s.cp[1] == 2,"A Worthy Death spends one CP when the enemy declares an attack against the unit")
	s.units[101].wounds = 0
	var held := D.hold_destroyed(s,101,func() -> int: return 4)
	check(held.error.is_empty() and held.held and s.units[101].wounds == 1 and s.units[101].lingering,"A 4+ keeps the destroyed model on the battlefield")
	s.units[102].wounds = 0
	held = D.hold_destroyed(s,102,func() -> int: return 3)
	check(held.error.is_empty() and not held.held and s.units[102].wounds == 0,"A 3+ failure removes the model")
	s.squads[1].fought = true
	D.remove_lingering(s,1)
	check(s.units[101].wounds == 0 and not s.units[101].has("lingering"),"Lingering models are removed after the unit fights")
	s = fixture()
	C.Doctrines.enable(s,"assault-brethren")
	D.enable_assault_brethren(s)
	s.phase = "fight"
	s.active = 2
	s.unit_abilities.phase_key = C.UnitActions.key(s)
	s.combat_doctrines.active[1] = "assault"
	target_reaction(s,1,1,2,D.WORTHY_WINDOW,D.DUTY_IN_DEATH)
	var duty_choice := find_choice(s,1,1,D.DUTY_IN_DEATH)
	var duty_result := D.apply(s,1,duty_choice,func() -> int: return 6)
	check(duty_result.error.is_empty() and s.cp[1] == 2,"Duty in Death is offered from Assault Brethren when its unit is targeted")
	s.units[101].wounds = 0
	held = D.hold_destroyed(s,101,func() -> int: return 3)
	check(held.error.is_empty() and held.held and held.roll == 3 and held.modifier == 1 and s.units[101].lingering,"Assault Doctrine adds 1 to Duty in Death's casualty roll")
	target_reaction(s,1,5,2,D.WORTHY_WINDOW,D.DUTY_IN_DEATH)
	check(find_choice(s,1,5,D.DUTY_IN_DEATH).is_empty(),"Duty in Death cannot be reused during the same Fight phase")
	s.squads[1].fought = true
	D.remove_lingering(s,1)
	check(s.units[101].wounds == 0,"Duty in Death model is removed when its unit fights")
	s = fixture()
	C.Doctrines.enable(s,"assault-brethren")
	D.enable_assault_brethren(s)
	s.phase = "fight"
	s.fight_actor = 1
	s.fight_step = "attacks"
	s.squads[1].charged = true
	s.combat_doctrines.active[1] = "assault"
	var gene_choice := find_choice(s,1,1,D.GENE_WROUGHT_MIGHT)
	var gene_result := D.apply(s,1,gene_choice,func() -> int: return 6)
	var gene_base: Dictionary = s.squads[1].melee_weapon.duplicate(true)
	var gene_effect := D.weapon(s,1,gene_base,gene_base,true)
	check(gene_result.error.is_empty() and gene_effect.keywords.get("lance",false) and gene_effect.ap == gene_base.ap-1,"Gene-Wrought Might grants Lance and Assault Doctrine improves melee AP")
	s = fixture()
	C.Doctrines.enable(s,"assault-brethren")
	D.enable_assault_brethren(s)
	s.phase = "shooting"
	s.active = 2
	s.unit_abilities.phase_key = C.UnitActions.key(s)
	target_reaction(s,1,1,2,D.ARMOUR_WINDOW)
	armour_choice = find_action(s,1,"armour-use",1)
	armour_error = D.use_armour(s,1,1,2)
	check(armour_error.is_empty() and s.cp[1] == 2 and s.stratagems.uses.back().stratagem == D.ASSAULT_ARMOUR,"Assault Brethren Armour of Contempt uses its own source identity and binds the attacker")
	s = fixture()
	C.Doctrines.enable(s,"assault-brethren")
	D.enable_assault_brethren(s)
	s.phase = "fight"
	s.active = 2
	s.fight_actor = 2
	s.fight_step = "attacks"
	s.fight_selected = 2
	s.squads[2].charged = true
	s.units[200].position = Vector2.ZERO
	s.units[100].position = Vector2(1.2,0)
	var attack_choices := C.AttackPlan.Equipment.choices(s,200,true)
	if not attack_choices.is_empty():
		var melee_weapon: Dictionary = attack_choices[0]
		var declaration := [{"model":200,"target":1,"amount":int(melee_weapon.stats.attacks),"weapon":str(melee_weapon.weapon),"profile":str(melee_weapon.profile)}]
		var pending_attack := C.resolve_attack_plan(s,2,200,declaration,s.revision,true,true,func() -> int: return 6)
		check(pending_attack.error.is_empty() and s.unit_abilities.window.get("kind", "") == D.ARMOUR_WINDOW,"Fight attack declaration first offers Armour of Contempt: %s / %s" % [str(pending_attack.get("error", "")), str(s.unit_abilities.window)])
		var armour_pass := find_action(s,1,"armour-pass",1)
		var declined_armour := C.unit_action(s,1,armour_pass,Vector2.ZERO,s.revision,func() -> int: return 6)
		check(declined_armour.is_empty() and s.unit_abilities.window.get("kind", "") == D.WORTHY_WINDOW and s.unit_abilities.window.get("stratagem", "") == D.DUTY_IN_DEATH,"After Armour of Contempt is declined, Fight declaration offers Duty in Death: %s / %s" % [declined_armour, str(s.unit_abilities.window)])
		var actual_duty_choice := find_choice(s,1,1,D.DUTY_IN_DEATH)
		var actual_duty_error := C.unit_action(s,1,actual_duty_choice,Vector2.ZERO,s.revision,func() -> int: return 6)
		check(actual_duty_error.is_empty() and s.cp[1] == 2 and s.stratagems.uses.back().stratagem == D.DUTY_IN_DEATH,"Choosing Duty in Death resumes the pending melee attack and spends one CP: %s / CP %d" % [actual_duty_error, s.cp[1]])
	else:
		check(false,"Fixture provides a melee weapon to exercise the attack declaration reaction sequence")
	s = fixture()
	s.phase = "movement"
	s.active = 2
	s.unit_abilities.phase_key = C.UnitActions.key(s)
	for model: int in D.living(s,1): s.units[model].position = Vector2(4, 0)
	for model: int in D.living(s,4): s.units[model].position = Vector2(10, 0)
	D.record_move(s,4)
	check(not find_choice(s,1,1,D.TACTICS).is_empty(),"Responsive Tactics is offered after an enemy ends within 8 inches")
	check(use(s,1,1,D.TACTICS).is_empty() and s.detachment_stratagems.tactics[1].inches == 6 and s.unit_abilities.window.kind == "tactics","Responsive Tactics spends CP and rolls D6 for the reaction move")
	var origin: Vector2 = s.detachment_stratagems.tactics[1].origins[100]
	check(D.tactics_position_error(s,100,origin + Vector2(7,0)) != "","A reaction cannot exceed the rolled inches")
	check(D.tactics_position_error(s,100,origin + Vector2(2,0)).is_empty(),"A short unengaged reaction destination is legal")
	s = fixture()
	s.phase = "shooting"
	s.active = 1
	s.unit_abilities.phase_key = C.UnitActions.key(s)
	s.units[401].wounds = 0
	D.after_attacks(s,1,[4],1)
	check(not find_choice(s,2,4,D.UNDYING).is_empty(),"Undying Legions is offered after models are destroyed")
	check(use(s,2,4,D.UNDYING).is_empty() and C.Reanimation.pending(s).kind == "undying" and s.cp[2] == 2,"Undying Legions spends one CP and opens Reanimation")
	s = fixture()
	C.UnitActions.attach(s,600,4)
	s.phase = "movement"
	s.active = 2
	s.unit_abilities.phase_key = C.UnitActions.key(s)
	check(use(s,2,4,D.SUDDEN).is_empty(),"Led Sudden Storm is spent before the Advance roll")
	check(C.begin_movement(s,2,400,"advance",s.revision,func() -> int: return 2).is_empty() and C.Stratagems.pending(s).get("sudden",false),"Led Sudden Storm opens an Advance window without Command Re-roll")
	check(C.resolve_roll_reaction(s,2,4,"sudden-storm",s.revision,func() -> int: return 5).is_empty() and s.pending_move.bonus == 5 and s.cp[2] == 2,"Sudden Storm re-rolls the Advance D6 without extra CP")
	s = fixture()
	s.phase = "shooting"
	s.active = 1
	s.unit_abilities.phase_key = C.UnitActions.key(s)
	s.units[600].position = Vector2.ZERO
	for model: int in D.living(s,1): s.units[model].position = Vector2(4, 0)
	for model: int in D.living(s,2):
		s.units[model].wounds = 0
		s.units[model].position = Vector2.ZERO
	D.after_attacks(s,1,[2],5)
	check(not find_choice(s,2,6,D.VENGEFUL).is_empty(),"Vengeful Stars is offered after a nearby Necron unit is destroyed")
	check(use(s,2,6,D.VENGEFUL).is_empty() and C.actor(s) == 2 and D.vengeful_shooter(s,6),"Vengeful Stars spends CP and gives the Character the next shooting window")
	var vengeful_targets := C.AttackPlan.legal_targets(s,600,false)
	check(1 in vengeful_targets and vengeful_targets.size() == 1,"Vengeful Stars may only target the destroying unit: " + str(vengeful_targets))
	s = fixture()
	s.phase = "shooting"
	s.active = 1
	s.unit_abilities.phase_key = C.UnitActions.key(s)
	s.units[600].wounds = 0
	D.record_destroyed(s,600)
	s.unit_abilities.window = {"kind":"end","owners":[2]}
	check(not find_choice(s,2,6,D.ETERNAL).is_empty(),"Eternal Revenant is offered at the end of the phase")
	check(use(s,2,6,D.ETERNAL).is_empty() and s.unit_abilities.window.kind == "eternal" and s.cp[2] == 2,"Eternal Revenant spends one CP and opens set-up")
	var place := Vector2.ZERO
	check(D.eternal_position_error(s,600,place).is_empty(),"An unengaged Eternal Revenant destination is legal: " + D.eternal_position_error(s,600,place))
	s.unit_abilities.window.positions[600] = place
	check(D.confirm_eternal(s).error.is_empty() and s.units[600].wounds == maxi(1, ceili(float(s.units[600].max_wounds) / 2.0)) and s.units[600].position == place,"Eternal Revenant returns the Infantry Character at half wounds")
	print("Detachment stratagem checks: %d failures" % failures)
	quit(0 if failures == 0 else 1)
