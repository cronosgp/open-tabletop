extends SceneTree
const F = preload("res://tests/all_units_fixture.gd")
const P = F.P
const C = F.C
const D = C.DetachmentStratagems
const MatchCommandService = preload("res://scripts/edition_11/match_command_service.gd")
const Enhancements = preload("res://scripts/edition_11/stormlance_enhancements.gd")
const Army = preload("res://scripts/edition_11/army_capabilities.gd")
var failures := 0
var scripted_rolls: Array[int] = []

func scripted_die() -> int:
	return scripted_rolls.pop_front() if not scripted_rolls.is_empty() else 6

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func prepared(enhancement_id: String = "") -> Dictionary:
	var selections := F.selections()
	if not enhancement_id.is_empty(): selections[1].entries[1].enhancement_id = enhancement_id
	var s := P.initial_state({"unit_abilities": true, "reanimation_protocols": true, "combat_doctrines": true, "awakened_dynasty": true, "core_stratagems": true, "marine_detachment": Enhancements.DEVASTATOR_BRETHREN}, selections)
	if s.has("error"): return s
	s.terrain.areas = []
	s.unit_abilities.setup_players = [1, 2]
	s.unit_abilities.battle_players = [1, 2]
	s.awakened_dynasty.setup_done = true
	s.awakened_dynasty.pending = []
	s.deployment.complete = true
	s.mission.stage = "battle"
	s.phase = "command"
	s.active = 1
	s.turn = 3
	s.round = 2
	s.unit_abilities.phase_key = C.UnitActions.key(s)
	s.cp = {1: 3, 2: 3}
	return s

func roster(source: String, enhancement_id: String) -> Dictionary:
	return {"schema_version": 2, "faction": "Space Marines", "category": "training", "points_limit": 500,
		"entries": [{"definition_id": "40kdc:11e:adeptus-astartes:" + source, "models": 1, "copies": 1, "enhancement_id": enhancement_id}]}

func choice_for(s: Dictionary, player: int, value: String, target: int = -1) -> Dictionary:
	for choice: Dictionary in D.choices(s, player):
		if str(choice.get("value", "")) == value and (target < 0 or int(choice.get("target", -1)) == target): return choice
	return {}

func submit_choice(s: Dictionary, player: int, action_id: String, target: int = -1, model: int = -1, value: String = "") -> Dictionary:
	var decision := C.UnitActions.pending_decision(s)
	if decision.is_empty() or int(decision.get("priority_player_id", -1)) != player: return {"error": "No matching UnitActions decision for Player %d." % player}
	var projected: Dictionary = {}
	for option: Dictionary in decision.get("legal_options", []):
		if str(option.get("action", "")) == action_id and int(option.get("target", -1)) == target and int(option.get("model", -1)) == model and str(option.get("value", "")) == value: projected = option; break
	var selected: Dictionary = {}
	for option: Dictionary in C.UnitActions.choices(s, player):
		if str(option.get("action", "")) == action_id and int(option.get("target", -1)) == target and int(option.get("model", -1)) == model and str(option.get("value", "")) == value: selected = option; break
	if projected.is_empty() or selected.is_empty(): return {"error": "No current projected %s choice for target %d/model %d." % [action_id, target, model]}
	return MatchCommandService.execute(s, player, {"kind": MatchCommandService.SELECT_UNIT_CHOICE, "revision": int(s.revision), "choice": {"_decision_type": MatchCommandService.UNIT_CHOICE_ENVELOPE, "decision_id": str(decision.get("decision_id", "")), "option_id": str(projected.get("id", "")), "choice": selected}}, scripted_die)

func _initialize() -> void:
	var captain := "40kdc:11e:adeptus-astartes:captain"
	check(Enhancements.valid_for(captain, Enhancements.MASTER_FORGED_FIREARMS, Enhancements.DEVASTATOR_BRETHREN), "Master-forged Firearms matches the Captain source eligibility row")
	check(Enhancements.valid_for(captain, Enhancements.HONOUR_OF_VIGILANCE, Enhancements.DEVASTATOR_BRETHREN), "Honour of Vigilance matches the Captain source eligibility row")
	var firearm_admission: Dictionary = Army.admit(roster("captain", Enhancements.MASTER_FORGED_FIREARMS))
	var honour_admission: Dictionary = Army.admit(roster("captain", Enhancements.HONOUR_OF_VIGILANCE))
	check(firearm_admission.get("error", "").is_empty() and firearm_admission.total == 105, "Master-forged Firearms adds its 15-point local cost")
	check(honour_admission.get("error", "").is_empty() and honour_admission.total == 110, "Honour of Vigilance adds its 20-point local cost")

	var s := prepared(Enhancements.MASTER_FORGED_FIREARMS)
	check(not s.has("error") and s.units[300].get("enhancement_id", "") == Enhancements.MASTER_FORGED_FIREARMS, "Master-forged Firearms is assigned to the eligible bearer in prepared match state")
	var weapon := {"attacks": "D6", "strength": 4, "ap": -1, "damage": "D3", "keywords": {"psychic": false}}
	var improved := C.AttackPlan._enhancement_weapon(s, 300, weapon, false)
	check(improved.attacks == "D6+1" and improved.strength == 5 and improved.ap == -2 and improved.damage == "D3+1", "Master-forged Firearms improves ranged A, S, AP and D by one")
	var psychic := weapon.duplicate(true)
	psychic.keywords.psychic = true
	var psychic_result := C.AttackPlan._enhancement_weapon(s, 300, psychic, false)
	check(psychic_result == psychic, "Master-forged Firearms excludes Psychic attacks")

	s = prepared(Enhancements.HONOUR_OF_VIGILANCE)
	s.combat_doctrines.active[1] = "devastator"
	var honour_weapon := C.AttackPlan._enhancement_weapon(s, 300, weapon, false)
	check(honour_weapon.keywords.get("lethal-hits", false), "Honour of Vigilance grants Lethal Hits to its unit's ranged attacks")
	s.phase = "movement"
	var opened := C.Stratagems.open_roll(s, 1, 3, "after_advance_roll", [2], {"squad": 3, "move_type": "advance", "bonus": 2})
	check(opened and C.Stratagems.pending(s).get("honour_vigilance", false), "Honour of Vigilance opens an Advance re-roll while Devastator Doctrine is active")
	var before_cp := int(s.cp[1])
	var honour_decision := C.Stratagems.pending_decision(s)
	var honour_option: Dictionary = {}
	for option: Dictionary in honour_decision.get("legal_options", []):
		if int(option.get("target", -1)) == 3 and str(option.get("value", "")) == "honour-of-vigilance": honour_option = option
	var honour_choice := {"action": "stratagem-reaction", "model": -1, "target": 3, "value": "honour-of-vigilance", "die": -1}
	var honour_envelope := {"_decision_type": MatchCommandService.STRATAGEM_DECISION_ENVELOPE, "decision_id": str(honour_decision.get("decision_id", "")), "option_id": str(honour_option.get("id", "")), "choice": honour_choice}
	var before_wrong_honour_owner := var_to_bytes(s)
	var wrong_honour_owner := MatchCommandService.execute(s, 2, {"kind": MatchCommandService.COMMAND_REACTION, "choice": honour_envelope, "revision": s.revision}, func() -> int: return 5)
	check(not str(wrong_honour_owner.get("error", "")).is_empty() and var_to_bytes(s) == before_wrong_honour_owner, "The opponent cannot submit or mutate Honour of Vigilance's Advance decision")
	var honour_result := MatchCommandService.execute(s, 1, {"kind": MatchCommandService.COMMAND_REACTION, "choice": honour_envelope, "revision": s.revision}, func() -> int: return 5)
	check(str(honour_result.get("error", "")).is_empty() and int(s.pending_move.bonus) == 5 and int(s.cp[1]) == before_cp, "Honour of Vigilance replaces the Advance die through the public command without spending CP")

	s = prepared()
	s.phase = "shooting"
	s.combat_doctrines.active[1] = "devastator"
	var storm := choice_for(s, 1, D.STORM_OF_FIRE, 1)
	var storm_result := D.apply(s, 1, storm)
	var profile := {"attacks": 2, "strength": 4, "ap": -1, "damage": 1, "keywords": {}}
	var storm_profile := D.weapon(s, 1, profile, profile, false)
	check(storm_result.get("error", "").is_empty() and storm_profile.keywords.get("ignores-cover", false) and storm_profile.ap == -2, "Storm of Fire grants Ignores Cover and +1 AP with Devastator Doctrine")
	s = prepared()
	s.phase = "shooting"
	storm = choice_for(s, 1, D.STORM_OF_FIRE, 1)
	storm_result = D.apply(s, 1, storm)
	storm_profile = D.weapon(s, 1, profile, profile, false)
	check(storm_result.get("error", "").is_empty() and storm_profile.keywords.get("ignores-cover", false) and storm_profile.ap == -1, "Storm of Fire grants Ignores Cover without the doctrine AP bonus")

	s = prepared()
	s.phase = "shooting"
	s.active = 2
	s.units[100].wounds = 0
	var hail_frame := C.ResolutionFrames.begin(s, "attack", "attack:hail-test", "attack-finalization")
	D.after_attacks(s, 2, [1], 1, {}, {})
	var pending_hail: Dictionary = s.detachment_stratagems.get("hail_of_vengeance_pending", {})
	var complete_hail := C._complete_attack_resolution_frame(s, "attack:hail-test")
	var hail_decision := C.UnitActions.pending_decision(s)
	check(not hail_frame.is_empty() and complete_hail.is_empty() and hail_decision.get("source", "") == "unit-actions" and hail_decision.get("priority_player_id", -1) == 1 and hail_decision.get("timing", "") == "shooting:vengeful-reaction", "Hail of Vengeance is exposed as the defending player's normalized post-attack decision")
	check(not C.PhaseCloseGate.close_request_error(s, 2, s.revision).is_empty() and str(hail_decision.get("resume_frame_id", "")) == str(C.ResolutionFrames.current(s).get("frame_id", "")), "The Hail decision blocks phase close and retains the suspended attack continuation")
	var hail := submit_choice(s, 1, "detachment-stratagem", 1, -1, D.HAIL_OF_VENGEANCE)
	check(pending_hail.get("victims", []).has(1) and str(hail.get("error", "")).is_empty() and s.cp[1] == 1, "Hail of Vengeance is offered through the normalized command after a model is destroyed and costs 2 CP")
	check(D.vengeful_actor(s) == 1 and D.vengeful_shooter(s, 1) and int(s.detachment_stratagems.hail_of_vengeance.attacker) == 2, "Hail of Vengeance opens shooting for the damaged unit, bound to the enemy shooter")
	check(D.reactive_shooting_target(s, 1) == 2, "Hail of Vengeance exposes its attacker as the only legal reaction-shot target")
	var hail_attack_error := C.attack_window_error(s, 1, 101, s.revision, false)
	check(hail_attack_error.is_empty(), "Hail of Vengeance lets the damaged unit shoot during the opponent's Shooting phase: " + hail_attack_error)
	var hail_frame_id := str(hail_decision.get("resume_frame_id", ""))
	check(str(C.ResolutionFrames.current(s).get("frame_id", "")) == hail_frame_id and C.actor(s) == 1, "Choosing Hail keeps the same continuation suspended for the reaction shot")
	s = bytes_to_var(var_to_bytes(s))
	var restored_hail_decision := C.UnitActions.pending_decision(s)
	check(str(restored_hail_decision.get("resume_frame_id", "")) == hail_frame_id and D.vengeful_shooter(s, 1), "The Hail reaction and suspended frame survive state serialization")
	var hail_pass := submit_choice(s, 1, "vengeful-pass")
	check(str(hail_pass.get("error", "")).is_empty() and C.ResolutionFrames.current(s).is_empty() and D.vengeful_actor(s) == -1, "Passing Hail after save/restore closes the reaction continuation")

	s = prepared()
	s.phase = "shooting"
	s.active = 2
	s.units[100].wounds = 1
	s.units[100].position = Vector2(4, 0)
	s.units[200].position = Vector2.ZERO
	for model: int in D.living(s, 2):
		if model != 200: s.units[model].wounds = 0
		s.units[model].position = Vector2.ZERO
	for model: int in D.living(s, 1): s.units[model].position = Vector2(4, 0)
	s.stratagems.save_rerolls = false
	scripted_rolls = [6, 6, 1, 1]
	var triggering_shot := MatchCommandService.execute(s, 2, {"kind": MatchCommandService.SHOOT, "revision": s.revision, "attacker": 200, "target": 100, "use_lethal": false}, scripted_die)
	if s.unit_abilities.window.get("kind", "") == D.ARMOUR_WINDOW:
		var armour_decline := submit_choice(s, 1, "armour-pass", 1)
		check(str(armour_decline.get("error", "")).is_empty(), "The targeted Devastator Brethren unit can decline Armour of Contempt before the triggering shot")
	var incoming_allocation_errors: Array[String] = []
	var incoming_allocation_steps := 0
	while not s.pending_attack.is_empty() and incoming_allocation_steps < 10:
		var incoming_decision := C.Allocation.pending_decision(s)
		var incoming_options: Array = incoming_decision.get("legal_options", [])
		if incoming_options.is_empty():
			incoming_allocation_errors.append("No projected incoming-damage choice remained.")
			break
		var incoming_option: Dictionary = incoming_options[0]
		var incoming_result := MatchCommandService.execute(s, int(incoming_decision.get("priority_player_id", -1)), {"kind": MatchCommandService.ALLOCATE_DAMAGE, "model": int(incoming_option.get("model", -1)), "revision": s.revision, "decision_id": str(incoming_decision.get("decision_id", "")), "option_id": str(incoming_option.get("id", ""))}, scripted_die)
		if not str(incoming_result.get("error", "")).is_empty(): incoming_allocation_errors.append(str(incoming_result.error)); break
		incoming_allocation_steps += 1
	check(str(triggering_shot.get("error", "")).is_empty() and incoming_allocation_errors.is_empty() and incoming_allocation_steps > 0 and s.pending_attack.is_empty() and s.units[100].wounds == 0 and not D.living(s, 1).is_empty(), "The real enemy attack and normalized defender allocation destroy one Hail-eligible model: " + str(incoming_allocation_errors))
	check(D.vengeful_actor(s) == 1 and not C.UnitActions.pending_decision(s).is_empty() and C.ResolutionFrames.current(s).get("kind", "") == "shooting-reaction", "Actual destruction opens the defending player's Hail decision and persisted reaction frame")
	var actual_hail_pending: Dictionary = s.detachment_stratagems.get("hail_of_vengeance_pending", {})
	check(actual_hail_pending.get("victims", []).has(1) and int(actual_hail_pending.get("attacker", -1)) == 2 and not choice_for(s, 1, D.HAIL_OF_VENGEANCE, 1).is_empty(), "The real attack binds Hail to its shooter and exposes the surviving damaged unit")
	var hail_shot_choice := submit_choice(s, 1, "detachment-stratagem", 1, -1, D.HAIL_OF_VENGEANCE)
	check(str(hail_shot_choice.get("error", "")).is_empty() and s.detachment_stratagems.get("hail_of_vengeance_pending", {}).is_empty() and D.vengeful_shooter(s, 1), "The defending player selects Hail through the normalized command")
	s.units[101].position = Vector2.ZERO
	s.units[200].position = Vector2(5, 0)
	var hail_shot := MatchCommandService.execute(s, 1, {"kind": MatchCommandService.SHOOT, "revision": s.revision, "attacker": 101, "target": 200, "use_lethal": false}, func() -> int: return 6)
	check(str(hail_shot_choice.get("error", "")).is_empty() and str(hail_shot.get("error", "")).is_empty(), "Hail of Vengeance completes a real reactive shot through the public SHOOT command: " + str(hail_shot.get("error", "")))
	check(D.vengeful_actor(s) == -1 and C.ResolutionFrames.current(s).is_empty() and s.squads[1].shot, "Resolving the Hail shot consumes the damaged unit's Shooting activation and closes its continuation")

	s = prepared()
	s.phase = "shooting"
	s.active = 2
	s.unit_abilities.window = {"kind": D.ARMOUR_WINDOW, "owners": [1], "squad": 1, "attacker_squad": 2, "declaration": {"player": 2, "squad": 2, "entries": [{"target": 1}]}}
	var armour_error := D.use_armour(s, 1, 1, 2)
	check(armour_error.is_empty() and s.cp[1] == 2 and s.stratagems.uses.back().stratagem == D.DEVASTATOR_ARMOUR, "Devastator Brethren Armour of Contempt spends 1 CP and retains its source-card identity")
	print("Devastator Brethren checks: %d failures" % failures)
	quit(1 if failures else 0)
