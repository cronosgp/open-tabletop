extends SceneTree
const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const D = preload("res://scripts/edition_11/detachment_stratagems.gd")
const MatchCommandService = preload("res://scripts/edition_11/match_command_service.gd")
var failures := 0
func check(ok: bool, message: String) -> void:
	if not ok: push_error(message); failures += 1
func fixture() -> Dictionary:
	var s := F.P.initial_state({"checked_rosters":true,"official_mission":true,"terrain_layout":C.Mission.DEFAULT_TERRAIN_LAYOUT,"unit_abilities":true,"combat_doctrines":true,"reanimation_protocols":true,"awakened_dynasty":true,"core_stratagems":true},F.selections())
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
	var selected := find_choice(s,player,squad,value)
	if selected.is_empty(): return "Detachment stratagem choice unavailable."
	var decision := C.UnitActions.pending_decision(s)
	if not decision.is_empty():
		for projected: Dictionary in decision.get("legal_options", []):
			if str(projected.get("action", "")) == "detachment-stratagem" and int(projected.get("target", -1)) == squad and int(projected.get("model", -1)) == int(selected.get("model", -1)) and str(projected.get("value", "")) == value:
				var payload := {"_decision_type": MatchCommandService.UNIT_CHOICE_ENVELOPE, "decision_id": str(decision.get("decision_id", "")), "option_id": str(projected.get("id", "")), "choice": selected}
				var result: Dictionary = MatchCommandService.execute(s, player, {"kind": MatchCommandService.SELECT_UNIT_CHOICE, "revision": int(s.revision), "choice": payload}, func() -> int: return 6)
				return str(result.get("error", ""))
		return "Detachment stratagem choice is not present in the pending decision."
	var result: Dictionary = MatchCommandService.execute(s, player, {"kind": MatchCommandService.SELECT_UNIT_CHOICE, "choice": selected, "point": Vector2.ZERO, "revision": int(s.revision)}, func() -> int: return 6)
	return str(result.get("error", ""))
func submit_choice(s: Dictionary, player: int, action_id: String, target: int = -1, model: int = -1, value: String = "", point: Vector2 = Vector2.ZERO) -> Dictionary:
	var decision := C.UnitActions.pending_decision(s)
	if decision.is_empty() or int(decision.get("priority_player_id", -1)) != player: return {"error": "No matching UnitActions decision for Player %d." % player}
	var projected: Dictionary = {}
	for option: Dictionary in decision.get("legal_options", []):
		if str(option.get("action", "")) == action_id and int(option.get("target", -1)) == target and int(option.get("model", -1)) == model and str(option.get("value", "")) == value: projected = option; break
	var selected: Dictionary = {}
	for option: Dictionary in C.UnitActions.choices(s, player):
		if str(option.get("action", "")) == action_id and int(option.get("target", -1)) == target and int(option.get("model", -1)) == model and str(option.get("value", "")) == value: selected = option; break
	if projected.is_empty() or selected.is_empty(): return {"error": "No current projected %s choice for target %d/model %d." % [action_id, target, model]}
	return MatchCommandService.execute(s, player, {"kind": MatchCommandService.SELECT_UNIT_CHOICE, "revision": int(s.revision), "point": point, "choice": {"_decision_type": MatchCommandService.UNIT_CHOICE_ENVELOPE, "decision_id": str(decision.get("decision_id", "")), "option_id": str(projected.get("id", "")), "choice": selected}}, func() -> int: return 6)
func submit_reanimation(s: Dictionary, player: int, value: String, target: int, model: int = -1, point: Vector2 = Vector2.ZERO) -> Dictionary:
	var decision := C.Reanimation.pending_decision(s)
	if decision.is_empty() or int(decision.get("priority_player_id", -1)) != player: return {"error": "No matching Reanimation decision for Player %d." % player}
	var projected: Dictionary = {}
	for option: Dictionary in decision.get("legal_options", []):
		if str(option.get("value", "")) == value and int(option.get("target", -1)) == target and int(option.get("model", -1)) == model: projected = option; break
	if projected.is_empty(): return {"error": "No projected Reanimation option %s for target %d/model %d." % [value, target, model]}
	var selected := {"action": "reanimation", "value": value, "target": target, "model": model}
	return MatchCommandService.execute(s, player, {"kind": MatchCommandService.RESOLVE_REANIMATION, "revision": int(s.revision), "point": point, "choice": {"_decision_type": MatchCommandService.REANIMATION_DECISION_ENVELOPE, "decision_id": str(decision.get("decision_id", "")), "option_id": str(projected.get("id", "")), "choice": selected}}, func() -> int: return 6)
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
	var adaptive_choice := find_choice(s, 1, 1, "assault")
	var adaptive_before_wrong_owner := var_to_bytes(s)
	var adaptive_wrong_owner: Dictionary = MatchCommandService.execute(s, 2, {"kind": MatchCommandService.SELECT_UNIT_CHOICE, "choice": adaptive_choice, "point": Vector2.ZERO, "revision": int(s.revision)}, func() -> int: return 6)
	check(not str(adaptive_wrong_owner.get("error", "")).is_empty() and var_to_bytes(s) == adaptive_before_wrong_owner, "The opponent cannot submit an immediate detachment stratagem choice")
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
	var hungry_choice := find_choice(s, 2, 4, D.HUNGRY)
	var hungry_before_wrong_owner := var_to_bytes(s)
	var hungry_wrong_owner: Dictionary = MatchCommandService.execute(s, 1, {"kind": MatchCommandService.SELECT_UNIT_CHOICE, "choice": hungry_choice, "point": Vector2.ZERO, "revision": int(s.revision)}, func() -> int: return 6)
	check(not str(hungry_wrong_owner.get("error", "")).is_empty() and var_to_bytes(s) == hungry_before_wrong_owner, "The active Fight actor cannot spend the opponent's Hungry Void stratagem")
	var hungry_before_stale := var_to_bytes(s)
	var hungry_stale_revision: Dictionary = MatchCommandService.execute(s, 2, {"kind": MatchCommandService.SELECT_UNIT_CHOICE, "choice": hungry_choice, "point": Vector2.ZERO, "revision": int(s.revision) - 1}, func() -> int: return 6)
	check(not str(hungry_stale_revision.get("error", "")).is_empty() and var_to_bytes(s) == hungry_before_stale, "An out-of-turn Hungry Void command cannot bypass revision validation")
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
		var declined_armour_result := submit_choice(s,1,"armour-pass",1)
		var declined_armour := str(declined_armour_result.get("error", ""))
		check(declined_armour.is_empty() and s.unit_abilities.window.get("kind", "") == D.WORTHY_WINDOW and s.unit_abilities.window.get("stratagem", "") == D.DUTY_IN_DEATH,"After Armour of Contempt is declined, Fight declaration offers Duty in Death: %s / %s" % [declined_armour, str(s.unit_abilities.window)])
		var actual_duty_decision := C.UnitActions.pending_decision(s)
		var actual_duty_frame_id := str(actual_duty_decision.get("resume_frame_id", ""))
		var blocked_duty_close := C.advance_phase(s, 2, s.revision)
		var restored_duty: Dictionary = bytes_to_var(var_to_bytes(s))
		var restored_duty_decision := C.UnitActions.pending_decision(restored_duty)
		check(actual_duty_decision.get("priority_player_id", -1) == 1 and not actual_duty_frame_id.is_empty() and not blocked_duty_close.is_empty() and restored_duty_decision.get("decision_id", "") == actual_duty_decision.get("decision_id", "") and str(C.ResolutionFrames.current(restored_duty).get("frame_id", "")) == actual_duty_frame_id,"Duty in Death is defender-owned, blocks Fight close and retains the suspended attack frame through save and restore: " + blocked_duty_close)
		var actual_duty_result := submit_choice(restored_duty,1,"detachment-stratagem",1,-1,D.DUTY_IN_DEATH)
		check(str(actual_duty_result.get("error", "")).is_empty() and restored_duty.cp[1] == 2 and restored_duty.stratagems.uses.back().stratagem == D.DUTY_IN_DEATH and restored_duty.unit_abilities.window.is_empty() and (not restored_duty.pending_attack.is_empty() or not restored_duty.pending_contact.is_empty()),"The normalized Duty in Death choice spends one CP and resumes its pending melee attack: " + str(actual_duty_result.get("error", "")) + " / CP " + str(restored_duty.cp[1]))
	else:
		check(false,"Fixture provides a melee weapon to exercise the attack declaration reaction sequence")
	s = fixture()
	s.phase = "fight"
	s.active = 2
	s.fight_actor = 2
	s.fight_step = "attacks"
	s.fight_selected = 2
	s.squads[2].charged = true
	s.units[200].position = Vector2.ZERO
	s.units[100].position = Vector2(1.2,0)
	var worthy_attack_choices := C.AttackPlan.Equipment.choices(s,200,true)
	if not worthy_attack_choices.is_empty():
		var worthy_melee_weapon: Dictionary = worthy_attack_choices[0]
		var worthy_attack_entries := [{"model":200,"target":1,"amount":int(worthy_melee_weapon.stats.attacks),"weapon":str(worthy_melee_weapon.weapon),"profile":str(worthy_melee_weapon.profile)}]
		var worthy_attack_command := MatchCommandService.execute(s,2,{"kind":MatchCommandService.ATTACK_PLAN,"revision":s.revision,"attacker":200,"entries":worthy_attack_entries,"melee":true,"use_lethal":false},func() -> int: return 6)
		var worthy_armour_response := submit_choice(s,1,"armour-pass",1) if str(worthy_attack_command.get("error","")).is_empty() and s.unit_abilities.window.get("kind","") == D.ARMOUR_WINDOW else {"error":str(worthy_attack_command.get("error","No Armour response opened."))}
		var worthy_pending_decision := C.UnitActions.pending_decision(s)
		var worthy_pending_frame := str(worthy_pending_decision.get("resume_frame_id",""))
		var worthy_blocked_close := C.advance_phase(s,2,s.revision)
		var worthy_attack_restore: Dictionary = bytes_to_var(var_to_bytes(s))
		var worthy_restored_decision := C.UnitActions.pending_decision(worthy_attack_restore)
		check(str(worthy_armour_response.get("error","")).is_empty() and s.unit_abilities.window.get("stratagem","") == D.WORTHY and worthy_pending_decision.get("priority_player_id",-1) == 1 and not worthy_pending_frame.is_empty() and not worthy_blocked_close.is_empty() and worthy_restored_decision.get("decision_id","") == worthy_pending_decision.get("decision_id","") and str(C.ResolutionFrames.current(worthy_attack_restore).get("frame_id","")) == worthy_pending_frame,"A Worthy Death opens after the public melee declaration and Armour pass, remains defender-owned, blocks Fight close and survives save/restore: " + str(worthy_armour_response.get("error","")))
		var worthy_attack_response := submit_choice(worthy_attack_restore,1,"detachment-stratagem",1,-1,D.WORTHY)
		check(str(worthy_attack_response.get("error","")).is_empty() and worthy_attack_restore.cp[1] == 2 and worthy_attack_restore.stratagems.uses.back().stratagem == D.WORTHY and worthy_attack_restore.unit_abilities.window.is_empty(),"The normalized A Worthy Death response spends CP and resumes the actual pending melee declaration: " + str(worthy_attack_response.get("error","")))
	else:
		check(false,"Fixture provides a melee weapon to exercise the public A Worthy Death attack declaration")
	s = fixture()
	s.phase = "movement"
	s.active = 2
	var enemy_index := 0
	for model: int in s.units:
		if int(s.units[model].squad) == 1: s.units[model].position = Vector2.ZERO
		if int(s.units[model].squad) == 4:
			s.units[model].position = Vector2(10.0 + float(enemy_index % 4) * 2.0, float(enemy_index / 4) * 2.0 - 2.0)
			enemy_index += 1
		if int(s.units[model].squad) not in [1, 4]: s.units[model].position = Vector2(15,15)
	var moved_model := D.living(s,4)[0]
	var movement_error := C.begin_movement(s,2,moved_model,"normal",s.revision)
	if movement_error.is_empty():
		for model: int in D.living(s,4):
			movement_error = C.move(s,2,model,s.units[model].position + Vector2(-3,0),s.revision)
			if not movement_error.is_empty(): break
	if movement_error.is_empty(): movement_error = C.finish_movement(s,2,s.revision)
	var response := C.UnitActions.pending_decision(s)
	var responsive_choice := find_choice(s,1,1,D.TACTICS)
	check(movement_error.is_empty() and C.UnitActions.actor(s) == 1 and response.get("priority_player_id",-1) == 1 and not responsive_choice.is_empty() and not s.resolution_frames.is_empty(),"Ending an enemy move within 8 inches opens a player-owned Responsive Tactics decision on the same suspended movement frame: %s" % movement_error)
	var serialized_reaction: Dictionary = bytes_to_var(var_to_bytes(s))
	check(C.UnitActions.actor(serialized_reaction) == 1 and C.UnitActions.pending_decision(serialized_reaction).get("resume_frame_id", "") == response.get("resume_frame_id", ""),"Post-move detachment reaction retains its owner and frame after local save/resume")
	var reactive_use := submit_choice(s,1,"detachment-stratagem",1,-1,D.TACTICS)
	check(str(reactive_use.get("error", "")).is_empty() and s.unit_abilities.window.get("kind", "") == "tactics" and s.unit_abilities.window.get("trigger", -1) == 4 and C.UnitActions.actor(s) == 1,"Responsive Tactics opens placement nested over the triggering move decision")
	var tactics_origin: Vector2 = s.detachment_stratagems.tactics[1].origins[100]
	check(s.detachment_stratagems.tactics[1].inches == 6 and D.tactics_position_error(s,100,tactics_origin + Vector2(7,0)) != "" and D.tactics_position_error(s,100,tactics_origin + Vector2(2,0)).is_empty(),"The public reaction rolls D6 and enforces its maximum placement distance")
	var tactics_cancel := find_action(s,1,"tactics-cancel",-1)
	var tactics_cancel_result := submit_choice(s,1,"tactics-cancel")
	check(str(tactics_cancel_result.get("error", "")).is_empty() and C.UnitActions.actor(s) == 1 and s.unit_abilities.window.get("kind", "") == D.MOVEMENT_REACTION_WINDOW,"Cancelling placement returns to the explicit post-move response window: %s / actor %d / window %s" % [str(tactics_cancel_result.get("error", "")), C.UnitActions.actor(s), str(s.unit_abilities.window)])
	var decline_reaction := find_action(s,1,"detachment-movement-pass",4)
	var decline_result := submit_choice(s,1,"detachment-movement-pass",4)
	check(str(decline_result.get("error", "")).is_empty() and C.UnitActions.actor(s) < 0 and s.resolution_frames.is_empty(),"Passing after placement closes the post-move decision and completes its movement frame: %s / actor %d / frames %s" % [str(decline_result.get("error", "")), C.UnitActions.actor(s), str(s.resolution_frames)])
	s = fixture()
	s.phase = "shooting"
	s.active = 1
	s.unit_abilities.phase_key = C.UnitActions.key(s)
	s.units[401].wounds = 0
	var undying_attack := C.ResolutionFrames.begin(s, "attack", "attack:undying-test", "attack-finalization")
	D.after_attacks(s,1,[4],1)
	var undying_frame_error := C._complete_attack_resolution_frame(s, "attack:undying-test")
	var undying_decision := C.UnitActions.pending_decision(s)
	check(not undying_attack.is_empty() and undying_frame_error.is_empty() and undying_decision.get("timing", "") == "post-attack:shooting:undying-legions" and undying_decision.get("priority_player_id", -1) == 2 and C.actor(s) == 2 and C.ResolutionFrames.current(s).get("status", "") == "suspended","Undying Legions is projected to the Necron player and suspends the resolved shooting attack: " + undying_frame_error)
	var premature_undying_close := C.advance_phase(s, 1, s.revision)
	check(not premature_undying_close.is_empty(),"The shooting phase cannot close during the post-attack Undying Legions reaction")
	var undying_use := submit_choice(s, 2, "detachment-stratagem", 4, -1, D.UNDYING)
	var undying_keep := {"error": ""}
	if C.Reanimation.pending(s).get("current", {}).get("reroll_pending", false): undying_keep = submit_choice(s, 2, "legion-keep")
	var saved_undying: Dictionary = bytes_to_var(var_to_bytes(s))
	var undying_reanimation_decision := C.Reanimation.pending_decision(s)
	check(str(undying_use.get("error", "")).is_empty() and str(undying_keep.get("error", "")).is_empty() and C.Reanimation.pending(saved_undying).get("kind", "") == "undying" and s.cp[2] == 2 and undying_reanimation_decision.get("timing", "") == "post-destruction:shooting:reanimation" and C.ResolutionFrames.current(saved_undying).get("status", "") == "suspended","Undying Legions spends one CP and exposes normalized Reanimation while preserving its suspended attack through save/restore: use=" + str(undying_use.get("error", "")) + " keep=" + str(undying_keep.get("error", "")) + " timing=" + str(undying_reanimation_decision.get("timing", "")))
	s = saved_undying
	var undying_suggest := submit_reanimation(s, 2, "suggest", 4)
	var placement_error := str(undying_suggest.get("error", ""))
	if not placement_error.is_empty():
		for model: int in C.Reanimation.returnable(s):
			if C.Reanimation.pending(s).current.get("placements", {}).size() + C.Reanimation.pending(s).current.get("unplaced", []).size() >= int(C.Reanimation.pending(s).current.get("slots", 0)): break
			var unplaceable := submit_reanimation(s, 2, "unplaceable", 4, model)
			if not str(unplaceable.get("error", "")).is_empty(): placement_error = str(unplaceable.get("error", "")); break
	var undying_confirm := submit_reanimation(s, 2, "confirm", 4)
	check(placement_error.is_empty(),"Reanimation placement is resolved by a legal deterministic suggestion or a valid unplaceable declaration: " + placement_error)
	check(str(undying_confirm.get("error", "")).is_empty() and C.Reanimation.pending(s).is_empty() and s.phase == "shooting" and s.resolution_frames.is_empty(),"Completing Undying Legions resumes and completes its attack frame without advancing the Shooting phase: " + str(undying_confirm.get("error", "")))
	s = fixture()
	C.UnitActions.attach(s, 600, 4)
	s.phase = "shooting"
	s.active = 1
	s.unit_abilities.phase_key = C.UnitActions.key(s)
	s.units[600].wounds = 2
	s.units[401].wounds = 0
	C.ResolutionFrames.begin(s, "attack", "attack:undying-empty", "attack-finalization")
	D.after_attacks(s, 1, [4], 1)
	C._complete_attack_resolution_frame(s, "attack:undying-empty")
	var empty_reroll_frame := C.UnitActions.pending_decision(s)
	var empty_reroll_use := submit_choice(s, 2, "detachment-stratagem", 4, -1, D.UNDYING)
	var legion_reroll_decision := C.UnitActions.pending_decision(s)
	var empty_reroll_keep := submit_choice(s, 2, "legion-keep")
	check(empty_reroll_frame.get("priority_player_id", -1) == 2 and legion_reroll_decision.get("timing", "") == "post-destruction:shooting:reanimation-reroll" and str(empty_reroll_use.get("error", "")).is_empty() and str(empty_reroll_keep.get("error", "")).is_empty() and C.Reanimation.pending(s).is_empty() and s.phase == "shooting" and s.resolution_frames.is_empty(),"Their Number is Legion uses a normalized reroll decision, and an immediately completed Undying Reanimation does not advance the phase")
	s = fixture()
	C.UnitActions.attach(s,600,4)
	s.phase = "movement"
	s.active = 2
	s.unit_abilities.phase_key = C.UnitActions.key(s)
	check(use(s,2,4,D.SUDDEN).is_empty(),"Led Sudden Storm is spent before the Advance roll")
	check(C.begin_movement(s,2,400,"advance",s.revision,func() -> int: return 2).is_empty() and C.Stratagems.pending(s).get("sudden",false),"Led Sudden Storm opens an Advance window without Command Re-roll")
	var sudden_decision := C.Stratagems.pending_decision(s)
	var sudden_option: Dictionary = {}
	for option: Dictionary in sudden_decision.get("legal_options", []):
		if int(option.get("target", -1)) == 4 and str(option.get("value", "")) == "sudden-storm": sudden_option = option
	var sudden_choice := {"action": "stratagem-reaction", "model": -1, "target": 4, "value": "sudden-storm", "die": -1}
	var sudden_envelope := {"_decision_type": MatchCommandService.STRATAGEM_DECISION_ENVELOPE, "decision_id": str(sudden_decision.get("decision_id", "")), "option_id": str(sudden_option.get("id", "")), "choice": sudden_choice}
	var before_wrong_sudden_owner := var_to_bytes(s)
	var wrong_sudden_owner := MatchCommandService.execute(s, 1, {"kind": MatchCommandService.COMMAND_REACTION, "choice": sudden_envelope, "revision": s.revision}, func() -> int: return 5)
	check(not str(wrong_sudden_owner.get("error", "")).is_empty() and var_to_bytes(s) == before_wrong_sudden_owner,"The opponent cannot submit or mutate the Sudden Storm Advance decision")
	var sudden_result := MatchCommandService.execute(s, 2, {"kind": MatchCommandService.COMMAND_REACTION, "choice": sudden_envelope, "revision": s.revision}, func() -> int: return 5)
	check(str(sudden_result.get("error", "")).is_empty() and s.pending_move.bonus == 5 and s.cp[2] == 2,"Sudden Storm re-rolls the Advance D6 through the public command without extra CP")
	s = fixture()
	s.phase = "shooting"
	s.active = 1
	s.unit_abilities.phase_key = C.UnitActions.key(s)
	s.units[600].position = Vector2.ZERO
	for model: int in D.living(s,1): s.units[model].position = Vector2(4, 0)
	for model: int in D.living(s,2):
		s.units[model].wounds = 0
		s.units[model].position = Vector2.ZERO
	var shot_frame := C.ResolutionFrames.begin(s,"attack","attack:vengeful-test","attack-finalization")
	check(not shot_frame.is_empty(),"The original shooting attack has a persisted resolution frame")
	D.after_attacks(s,1,[2],5)
	var complete_vengeful := C._complete_attack_resolution_frame(s,"attack:vengeful-test")
	check(complete_vengeful.is_empty(),"Finishing the original shot opens the reactive shooting continuation")
	var vengeful_decision := C.UnitActions.pending_decision(s)
	check(vengeful_decision.get("source","") == "unit-actions" and vengeful_decision.get("timing","") == "shooting:post-shot-reaction" and str(vengeful_decision.get("resume_frame_id","")) == str(C.ResolutionFrames.current(s).get("frame_id","")),"Hail of Vengeance exposes its normalized decision and continuation frame")
	check(not C.PhaseCloseGate.close_request_error(s,1,s.revision).is_empty(),"The pending Vengeful reaction blocks phase close")
	var serialized_vengeful: Dictionary = bytes_to_var(var_to_bytes(s))
	check(str(C.UnitActions.pending_decision(serialized_vengeful).get("resume_frame_id","")) == str(vengeful_decision.get("resume_frame_id","")),"The Vengeful continuation survives state serialization")
	check(not find_choice(s,2,6,D.VENGEFUL).is_empty(),"Vengeful Stars is offered after a nearby Necron unit is destroyed")
	var vengeful_frame_id := str(vengeful_decision.get("resume_frame_id",""))
	var normalized_vengeful_use := submit_choice(s,2,"detachment-stratagem",6,-1,D.VENGEFUL)
	check(str(normalized_vengeful_use.get("error","")).is_empty() and C.actor(s) == 2 and D.vengeful_shooter(s,6) and str(C.ResolutionFrames.current(s).get("frame_id","")) == vengeful_frame_id,"Vengeful Stars selection uses the normalized command and keeps the same continuation for the Character's reactive shooting window")
	s = bytes_to_var(var_to_bytes(s))
	var vengeful_targets := C.AttackPlan.legal_targets(s,600,false)
	check(1 in vengeful_targets and vengeful_targets.size() == 1,"Vengeful Stars may only target the destroying unit: " + str(vengeful_targets))
	var normalized_vengeful_pass := submit_choice(s,2,"vengeful-pass",6)
	check(str(normalized_vengeful_pass.get("error","")).is_empty() and C.ResolutionFrames.current(s).is_empty() and D.vengeful_actor(s) == -1,"Declining Vengeful Stars through the normalized command after save/restore completes its persisted continuation")
	s = fixture()
	s.phase = "shooting"
	s.active = 1
	s.unit_abilities.phase_key = C.UnitActions.key(s)
	s.units[600].position = Vector2(6,6)
	for model: int in D.living(s,1): s.units[model].position = Vector2(12,0)
	for model: int in D.living(s,3): s.units[model].wounds = 0
	s.units[300].wounds = s.units[300].max_wounds
	s.units[300].position = Vector2.ZERO
	for model: int in D.living(s,2):
		s.units[model].wounds = 0
		s.units[model].position = Vector2(6,0)
	s.units[200].wounds = 1
	s.stratagems.save_rerolls = false
	s.stratagems.attack_rerolls = false
	s.manual_allocation = true
	var original_rolls: Array[int] = [6,6,6,6,1,1]
	var original_roller := func() -> int: return original_rolls.pop_front() if not original_rolls.is_empty() else 1
	var original_vengeful_attack := MatchCommandService.execute(s,1,{"kind":MatchCommandService.ATTACK_PLAN,"revision":s.revision,"attacker":300,"entries":[{"model":300,"target":2,"amount":1,"weapon":"master-crafted-bolter","profile":"standard"}],"melee":false,"use_lethal":false},original_roller)
	check(str(original_vengeful_attack.get("error","" )).is_empty(),"The Marine Captain declares the Necron unit's destroying attack through the public attack-plan command: " + str(original_vengeful_attack.get("error","")))
	var original_allocation_steps := 0
	var original_allocation_errors: Array[String] = []
	while not s.pending_attack.is_empty() and original_allocation_steps < 20:
		var original_allocation := C.Allocation.pending_decision(s)
		var original_options: Array = original_allocation.get("legal_options", [])
		if original_options.is_empty():
			original_allocation_errors.append("The original attack exposed no normalized damage-allocation option.")
			break
		var original_option: Dictionary = original_options[0]
		var original_step := MatchCommandService.execute(s,int(original_allocation.get("priority_player_id",-1)),{"kind":MatchCommandService.ALLOCATE_DAMAGE,"model":int(original_option.get("model",-1)),"revision":s.revision,"decision_id":str(original_allocation.get("decision_id","")),"option_id":str(original_option.get("id",""))},original_roller)
		if not str(original_step.get("error","" )).is_empty(): original_allocation_errors.append(str(original_step.error)); break
		original_allocation_steps += 1
	check(s.pending_attack.is_empty() and s.units[200].wounds <= 0 and original_allocation_errors.is_empty(),"The Necron unit is actually destroyed by the public attack and defender-owned allocation: " + str(original_allocation_errors))
	check(D.vengeful_actor(s) == 2,"Vengeful Stars becomes eligible from the real destroyed-unit event near the Overlord")
	var vengeful_shot_choice := submit_choice(s,2,"detachment-stratagem",6,-1,D.VENGEFUL)
	var reaction_frame_id := str(C.ResolutionFrames.current(s).get("frame_id", ""))
	check(str(vengeful_shot_choice.get("error","")).is_empty() and D.vengeful_actor(s) == 2 and C.actor(s) == 2 and D.vengeful_shooter(s,6),"The Vengeful choice opens Player 2's reactive shooting before its shot: " + str(vengeful_shot_choice.get("error","")) + " owner=" + str(D.vengeful_actor(s)))
	var vengeful_shot := MatchCommandService.execute(s,2,{"kind":MatchCommandService.SHOOT,"revision":s.revision,"attacker":600,"target":300,"use_lethal":false},func() -> int: return 6)
	check(str(vengeful_shot_choice.get("error","")).is_empty() and str(vengeful_shot.get("error","")).is_empty(),"Vengeful Stars declares its bound reactive shot through the public SHOOT command: " + str(vengeful_shot.get("error","")))
	if not s.pending_attack.is_empty():
		var stratagem_decision := C.Stratagems.pending_decision(s)
		var attack_frame := C.ResolutionFrames.current(s)
		check(stratagem_decision.get("source", "") == "stratagems" and stratagem_decision.get("priority_player_id", -1) == 1 and attack_frame.get("kind", "") == "attack" and attack_frame.get("parent_frame_id", "") == reaction_frame_id and stratagem_decision.get("resume_frame_id", "") == attack_frame.get("frame_id", ""), "Vengeful's shot nests the defending player's save-roll decision under the selected Shooting continuation")
		var saved_stratagem_decision_id := str(stratagem_decision.get("decision_id", ""))
		var saved_stratagem_options: Array = stratagem_decision.get("legal_options", []).duplicate(true)
		s = bytes_to_var(var_to_bytes(s))
		stratagem_decision = C.Stratagems.pending_decision(s)
		check(stratagem_decision.get("decision_id", "") == saved_stratagem_decision_id and stratagem_decision.get("legal_options", []) == saved_stratagem_options and C.ResolutionFrames.current(s).get("parent_frame_id", "") == reaction_frame_id, "The nested Vengeful save decision and both frames survive serialization")
		var accept_save_roll: Dictionary = {}
		for option: Dictionary in stratagem_decision.get("legal_options", []):
			if str(option.get("value", "")) == "": accept_save_roll = option; break
		var accept_save_choice := {"action": "stratagem-reaction", "model": -1, "target": int(accept_save_roll.get("target", -1)), "value": "", "die": int(accept_save_roll.get("details", {}).get("die", -1))}
		var accept_save_envelope := {"_decision_type": MatchCommandService.STRATAGEM_DECISION_ENVELOPE, "decision_id": str(stratagem_decision.get("decision_id", "")), "option_id": str(accept_save_roll.get("id", "")), "choice": accept_save_choice}
		var accept_save_result := MatchCommandService.execute(s, 1, {"kind": MatchCommandService.COMMAND_REACTION, "revision": s.revision, "choice": accept_save_envelope}, func() -> int: return 6)
		check(not accept_save_roll.is_empty() and str(accept_save_result.get("error", "")).is_empty(), "The Vengeful attack's pending save-roll reaction resumes from its serialized decision: " + str(accept_save_result.get("error", "")))
		var allocation_decision := C.Allocation.pending_decision(s)
		var attack_frame_after_roll := C.ResolutionFrames.current(s)
		if not allocation_decision.is_empty():
			check(allocation_decision.get("source", "") == "damage-allocation" and attack_frame_after_roll.get("kind", "") == "attack" and attack_frame_after_roll.get("parent_frame_id", "") == reaction_frame_id, "Any resulting defender allocation remains nested under Vengeful's reaction")
			var allocation_errors: Array[String] = []
			var allocation_steps := 0
			while not s.pending_attack.is_empty() and allocation_steps < 20:
				allocation_decision = C.Allocation.pending_decision(s)
				var legal_options: Array = allocation_decision.get("legal_options", [])
				if legal_options.is_empty():
					allocation_errors.append("No projected damage-allocation option remained.")
					break
				var selected_allocation: Dictionary = legal_options[0]
				var allocation_result := MatchCommandService.execute(s, int(allocation_decision.get("priority_player_id", -1)), {"kind": MatchCommandService.ALLOCATE_DAMAGE, "model": int(selected_allocation.get("model", -1)), "revision": s.revision, "decision_id": str(allocation_decision.get("decision_id", "")), "option_id": str(selected_allocation.get("id", ""))}, func() -> int: return 6)
				if not str(allocation_result.get("error", "")).is_empty(): allocation_errors.append(str(allocation_result.error)); break
				allocation_steps += 1
			check(allocation_errors.is_empty() and s.pending_attack.is_empty() and allocation_steps > 0, "The defender resolves Vengeful's damage through normalized allocation: " + str(allocation_errors))
	check(D.vengeful_actor(s) == -1 and C.ResolutionFrames.current(s).is_empty() and s.squads[6].shot,"Resolving Vengeful Stars and its defender-owned save decision consumes the Character unit's Shooting activation and closes both frames")
	s = fixture()
	s.phase = "shooting"
	s.active = 1
	s.unit_abilities.phase_key = C.UnitActions.key(s)
	s.units[600].wounds = 0
	D.record_destroyed(s,600)
	s.unit_abilities.window = {}
	s.unit_abilities.end_done = ""
	s.resolution_frames = []
	var eternal_close_error := C.advance_phase(s,1,s.revision)
	var eternal_frame := C.ResolutionFrames.current(s)
	var eternal_decision := C.UnitActions.pending_decision(s)
	check(eternal_close_error.is_empty() and eternal_decision.get("timing", "") == "end-phase:shooting" and eternal_decision.get("priority_player_id", -1) == 2 and eternal_frame.get("kind", "") == "phase-close","Eternal Revenant opens as the Necron player's normalized end-of-phase choice under phase close: " + eternal_close_error)
	var eternal_use := submit_choice(s,2,"detachment-stratagem",6,600,D.ETERNAL)
	check(str(eternal_use.get("error", "")).is_empty() and s.unit_abilities.window.get("kind", "") == "eternal" and s.cp[2] == 2 and s.unit_abilities.window.get("resume_window", {}).get("kind", "") == "end" and C.ResolutionFrames.current(s).get("frame_id", "") == eternal_frame.get("frame_id", ""),"Eternal Revenant spends 1 CP, opens set-up and retains the original end window and phase-close frame: " + str(eternal_use.get("error", "")))
	var place := Vector2.ZERO
	check(D.eternal_position_error(s,600,place).is_empty(),"An unengaged Eternal Revenant destination is legal: " + D.eternal_position_error(s,600,place))
	var before_eternal_close := var_to_bytes(s)
	var pending_eternal_close := C.advance_phase(s,2,s.revision)
	check(not pending_eternal_close.is_empty() and before_eternal_close == var_to_bytes(s),"Phase close cannot skip Eternal Revenant placement")
	var eternal_place := submit_choice(s,2,"eternal-place",6,600,"",place)
	var eternal_restored: Dictionary = bytes_to_var(var_to_bytes(s))
	var eternal_confirm := submit_choice(eternal_restored,2,"eternal-confirm",6,600)
	var resumed_end_decision := C.UnitActions.pending_decision(eternal_restored)
	check(str(eternal_place.get("error", "")).is_empty() and str(eternal_confirm.get("error", "")).is_empty() and eternal_restored.units[600].wounds == maxi(1, ceili(float(eternal_restored.units[600].max_wounds) / 2.0)) and eternal_restored.units[600].position == place and eternal_restored.unit_abilities.window.get("kind", "") == "end" and resumed_end_decision.get("resume_frame_id", "") == eternal_frame.get("frame_id", "") and resumed_end_decision.get("pass_allowed", false),"Eternal Revenant returns at half wounds, restores the end-choice window after save/restore and keeps the phase-close frame: " + str(eternal_place.get("error", "")) + " / " + str(eternal_confirm.get("error", "")))
	var eternal_pass := submit_choice(eternal_restored,2,"pass")
	check(str(eternal_pass.get("error", "")).is_empty() and eternal_restored.phase == "charge" and (C.ResolutionFrames.current(eternal_restored).is_empty() or str(C.ResolutionFrames.current(eternal_restored).get("action_id", "")) != "phase-close:%d:shooting" % int(eternal_restored.turn)),"Passing remaining end-phase choices after Eternal Revenant resumes phase progression: " + str(eternal_pass.get("error", "")))
	print("Detachment stratagem checks: %d failures" % failures)
	quit(0 if failures == 0 else 1)
