extends SceneTree
const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const Equipment = preload("res://scripts/edition_11/equipment.gd")
const MatchCommandService = preload("res://scripts/edition_11/match_command_service.gd")
const ResolutionFrames = preload("res://scripts/edition_11/resolution_frame.gd")
const A = C.UnitAbilities
const U = C.UnitActions
var failures := 0
var dice_calls := 0
func six() -> int:
	dice_calls += 1
	return 6
func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1
func act(s: Dictionary, owner: int, action: String, model: int = -2, target: int = -2, value: String = "", point: Vector2 = Vector2.ZERO) -> String:
	for choice: Dictionary in C.unit_choices(s, owner):
		if choice.action == action and (model == -2 or choice.model == model) and (target == -2 or choice.target == target) and (value.is_empty() or choice.value == value):
			var decision := U.pending_decision(s)
			if not decision.is_empty():
				if int(decision.get("priority_player_id", -1)) != owner: return "The pending UnitActions choice belongs to another player."
				for projected: Dictionary in decision.get("legal_options", []):
					if str(projected.get("action", "")) == action and int(projected.get("model", -1)) == int(choice.get("model", -1)) and int(projected.get("target", -1)) == int(choice.get("target", -1)) and str(projected.get("value", "")) == str(choice.get("value", "")):
						var payload := {"_decision_type": MatchCommandService.UNIT_CHOICE_ENVELOPE, "decision_id": str(decision.get("decision_id", "")), "option_id": str(projected.get("id", "")), "choice": choice}
						var result: Dictionary = MatchCommandService.execute(s, owner, {"kind": MatchCommandService.SELECT_UNIT_CHOICE, "revision": int(s.get("revision", -1)), "point": point, "choice": payload}, six)
						return str(result.get("error", ""))
				return "The selected UnitActions option is not present in the pending decision."
			var result: Dictionary = MatchCommandService.execute(s, owner, {"kind": MatchCommandService.SELECT_UNIT_CHOICE, "revision": int(s.get("revision", -1)), "point": point, "choice": choice}, six)
			return str(result.get("error", ""))
	return "Missing choice: " + action
func submit_unit_choice(s: Dictionary, owner: int, action_id: String, model: int = -1, target: int = -1) -> Dictionary:
	var decision := U.pending_decision(s)
	if decision.is_empty() or int(decision.get("priority_player_id", -1)) != owner: return {"error": "No matching UnitActions decision for Player %d." % owner}
	var projected: Dictionary = {}
	for option: Dictionary in decision.get("legal_options", []):
		if str(option.get("action", "")) == action_id and int(option.get("model", -1)) == model and int(option.get("target", -1)) == target: projected = option; break
	var selected: Dictionary = {}
	for option: Dictionary in U.choices(s, owner):
		if str(option.get("action", "")) == action_id and int(option.get("model", -1)) == model and int(option.get("target", -1)) == target: selected = option; break
	if projected.is_empty() or selected.is_empty(): return {"error": "No current projected %s choice for target %d." % [action_id, target]}
	return MatchCommandService.execute(s, owner, {"kind": MatchCommandService.SELECT_UNIT_CHOICE, "revision": int(s.get("revision", -1)), "choice": {"_decision_type": MatchCommandService.UNIT_CHOICE_ENVELOPE, "decision_id": str(decision.get("decision_id", "")), "option_id": str(projected.get("id", "")), "choice": selected}}, six)
func submit_reanimation(s: Dictionary, owner: int, action_value: String, target: int, model: int = -1, point: Vector2 = Vector2.ZERO) -> Dictionary:
	var decision := C.Reanimation.pending_decision(s)
	if decision.is_empty() or int(decision.get("priority_player_id", -1)) != owner: return {"error": "No matching Reanimation decision for Player %d." % owner}
	var projected: Dictionary = {}
	for option: Dictionary in decision.get("legal_options", []):
		if str(option.get("value", "")) == action_value and int(option.get("target", -1)) == target and int(option.get("model", -1)) == model: projected = option; break
	if projected.is_empty(): return {"error": "No current Reanimation option %s for target %d/model %d." % [action_value, target, model]}
	var selected := {"action": "reanimation", "value": action_value, "target": target, "model": model}
	return MatchCommandService.execute(s, owner, {"kind": MatchCommandService.RESOLVE_REANIMATION, "revision": int(s.get("revision", -1)), "point": point, "choice": {"_decision_type": MatchCommandService.REANIMATION_DECISION_ENVELOPE, "decision_id": str(decision.get("decision_id", "")), "option_id": str(projected.get("id", "")), "choice": selected}}, six)
func prepared() -> Dictionary:
	var s := F.fresh()
	check(not s.has("error"), "All ten canonical profiles materialize")
	if s.has("error"): return {}
	for model: int in [300, 900]:
		check("TACTICUS" in s.units[model].keywords and "EXPLOSIVES" in s.units[model].keywords, "Current-reference Captain and Lieutenant retain their datasheet keywords before attachment")
	check(C.select_awakened_attachment(s, 2, 2, 0).is_empty(), "Overlord leads Immortals before other preparation")
	check(act(s, 1, "attach", 300, 7).is_empty(), "Captain leads current Intercessors")
	check(act(s, 1, "attach", 900, 1).is_empty(), "Lieutenant joins Assault Intercessors as Support")
	check(act(s, 1, "warlord", 300).is_empty() and act(s, 1, "setup-done").is_empty(), "Marine preparation includes Warlord and mandatory Support")
	check(act(s, 2, "attach", 800, 4).is_empty(), "Royal Warden leads Warriors")
	check(act(s, 2, "warlord", 600).is_empty() and act(s, 2, "setup-done").is_empty(), "Necron preparation finishes with legal pairings")
	s.phase = "shooting"
	s.active = 1
	s.turn = 3
	s.round = 2
	s.unit_abilities.phase_key = U.key(s)
	s.terrain.areas = []
	for model: int in s.units:
		var unit: Dictionary = s.units[model]
		unit.position = Vector2(-5 if unit.owner == 1 else 5, (model % 100) * 1.4)
	s.units[300].position = Vector2(-7, 1)
	s.units[900].position = Vector2(-7, 3)
	s.units[600].position = Vector2(7, 1)
	s.units[800].position = Vector2(7, 3)
	return s
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var s := prepared()
	if s.is_empty(): quit(1); return
	check("strategic-acumen" in s.squads[7].enabled_abilities and "tactical-precision" in s.squads[1].enabled_abilities and "my-will-be-done" in s.squads[2].enabled_abilities and "adaptive-strategy" in s.squads[4].enabled_abilities, "Attached unit capability metadata includes all component abilities")
	check(A.has(s, 7, "bolter-discipline") and A.has(s, 1, "tactical-precision") and A.has(s, 4, "adaptive-strategy"), "Live component abilities propagate into attachments")
	s.mission.objectives = [{"kind": "marker", "position": Vector2(-5, 0), "name": "Test", "controller": 1, "secured": 0}]
	check(A.hit_bonus(s, 7, 2, false) == 1 and A.hit_bonus(s, 7, 2, true) == 0, "Bolter Discipline is ranged in own Shooting, on objectives")
	s.squads[7].battle_shocked = true
	check(C.Actions.eligibility_error(s, 7).is_empty(), "Tactical Mainstay permits starting an action while Battle-shocked")
	C.Actions.start(s, 7, 0)
	check(not C.Actions.shooting_blocked(s, 7), "Tactical Mainstay action does not block shooting")
	s.squads[7].battle_shocked = false
	check(A.save_bonus(s, 5, Callable(C.Morale, "objective_control")) == 1, "Heavy Intercessors gain save bonus while within a controlled objective")
	s.squads[5].battle_shocked = true
	check(A.save_bonus(s, 5, Callable(C.Morale, "objective_control")) == 0, "Battle-shocked unit without positive OC is not controlling the objective")
	s.squads[5].battle_shocked = false
	var gun: Dictionary = Equipment.select(s, 1100, false).stats
	check(A.weapon(s, 1100, 2, gun, false).ap == gun.ap - 1, "Fury of the First improves AP within nine inches by unit distance")
	s.squads[1].charged = true
	var blade: Dictionary = Equipment.select(s, 900, true).stats
	var adjusted := A.weapon(s, 900, 2, blade, true)
	check(adjusted.strength == blade.strength + 1 and adjusted.ap == blade.ap - 1 and adjusted.keywords.get("lethal-hits", false), "Charged Assault ability and Support Lethal Hits apply to Lieutenant")
	s.units[200].keywords.append("VEHICLE")
	check(not A.weapon(s, 900, 2, blade, true).keywords.get("lethal-hits", false), "Tactical Precision excludes Monster/Vehicle units")
	s.units[200].keywords.erase("VEHICLE")
	check(A.damage(s, 600, 3) == 2 and A.damage(s, 600, 1) == 1 and A.damage(s, 200, 3) == 3, "Implacable Resilience applies to allocated Overlord attacks, minimum one")
	s.squads[4].fell_back = true
	check(C.Doctrines.shoot_after_fallback(s, 4) and C.Doctrines.charge_error(s, 4).is_empty(), "Adaptive Strategy permits shooting and charging after Fall Back")
	s.phase = "command"
	s.unit_abilities.phase_key = U.key(s)
	check(C.select_combat_doctrine(s, 1, "none", s.revision).is_empty(), "Army start-of-Command choice resolves before later Command abilities")
	check(act(s, 1, "acumen", 300, 7, "assault").is_empty() and C.Doctrines.active_for(s, 7) == "assault", "Strategic Acumen activates a local doctrine")
	check(act(s, 1, "demi", 900, 1).is_empty() and C.Doctrines.active_for(s, 1) == "assault", "Demi-company Commander copies the Captain's chosen doctrine")
	check(act(s, 1, "pass").is_empty(), "Demi-company reaction closes without advancing Command")
	A.start_command(s)
	check(A.doctrine(s, 7).is_empty() and A.doctrine(s, 1).is_empty(), "Local doctrines expire at next own Command")
	s.phase = "fight"
	s.unit_abilities.phase_key = U.key(s)
	s.fight_step = "attacks"
	s.fight_actor = 1
	s.squads[7].charged = true
	s.squads[7].fight_eligible = true
	check(act(s, 1, "finest", 300).is_empty(), "Finest Hour selects an eligible Captain unit to fight")
	var finest: Dictionary = Equipment.select(s, 300, true).stats
	check(finest.attacks == 9 and finest.keywords.get("devastating-wounds", false) and s.fight_selected == 7, "Finest Hour changes owned attack choices and locks selected fighter")
	check(not act(s, 1, "finest", 300).is_empty(), "Finest Hour cannot be reused")
	s = prepared()
	s.phase = "start_turn"
	s.unit_abilities.warlords[1] = 300
	var cp: int = s.cp[1]
	U.start_round(s)
	U.start_round(s)
	check(s.cp[1] == cp + 1, "Transhuman Strategist grants one CP per round for a living Captain Warlord")
	s.phase = "shooting"
	s.active = 2
	s.unit_abilities.phase_key = U.key(s)
	s.squads[4].battle_shocked = true
	s.unit_abilities.phase_key = "previous"
	U.reconcile(s)
	check(act(s, 2, "logic", 800, 4).is_empty() and not s.squads[4].battle_shocked, "Engrammatic Logic clears friendly Battle-shock at phase start")
	check(act(s, 2, "pass").is_empty() and not act(s, 2, "logic", 800, 4).is_empty(), "Logic is once per battle and closes its reaction window")
	s.units[201].wounds = 0
	s.unit_abilities.window = {}
	s.unit_abilities.end_done = ""
	s.unit_abilities.phase_key = U.key(s)
	s.resolution_frames = []
	var orb_close_error := C.advance_phase(s, 2, s.revision)
	var orb_end_decision := U.pending_decision(s)
	check(orb_close_error.is_empty() and orb_end_decision.get("timing", "") == "end-phase:shooting" and ResolutionFrames.current(s).get("kind", "") == "phase-close", "End of Shooting suspends the phase-close frame for the Necron owner's Resurrection Orb choice: " + orb_close_error)
	var orb_use := submit_unit_choice(s, 2, "orb", 600)
	check(str(orb_use.get("error", "")).is_empty() and C.Reanimation.pending(s).get("kind", "") == "orb" and s.unit_abilities.used.get("resurrect-turn:2", -1) == s.turn and s.unit_abilities.used.has("orb:2"), "Normalized Resurrection Orb choice records its once-per-turn use and starts Reanimation: " + str(orb_use.get("error", "")))
	var orb_legion_window := U.pending_decision(s)
	var orb_has_legion_reroll := false
	for option: Dictionary in orb_legion_window.get("legal_options", []):
		if str(option.get("action", "")) == "legion-keep": orb_has_legion_reroll = true
	var orb_keep := {"error": ""}
	if orb_has_legion_reroll: orb_keep = submit_unit_choice(s, 2, "legion-keep")
	var orb_reanimation_decision := C.Reanimation.pending_decision(s)
	check(str(orb_keep.get("error", "")).is_empty() and not orb_reanimation_decision.is_empty() and orb_reanimation_decision.get("timing", "") == "end-phase:shooting:reanimation" and orb_reanimation_decision.get("resume_frame_id", "") == ResolutionFrames.current(s).get("frame_id", ""), "Orb roll opens a phase-correct Reanimation decision linked to the same close frame: " + str(orb_keep.get("error", "")))
	var before_orb_close := var_to_bytes(s)
	var pending_orb_close_error := C.advance_phase(s, 2, s.revision)
	check(not pending_orb_close_error.is_empty() and before_orb_close == var_to_bytes(s), "Phase close cannot skip pending Orb Reanimation placement")
	var orb_suggest := submit_reanimation(s, 2, "suggest", 2)
	var orb_restored: Dictionary = bytes_to_var(var_to_bytes(s))
	var orb_confirm := submit_reanimation(orb_restored, 2, "confirm", 2)
	check(str(orb_suggest.get("error", "")).is_empty() and str(orb_confirm.get("error", "")).is_empty() and orb_restored.units[201].wounds > 0 and C.Reanimation.pending(orb_restored).is_empty() and ResolutionFrames.current(orb_restored).get("kind", "") == "phase-close", "Suggested model return survives save/restore and confirmation finishes Orb Reanimation while preserving phase close: " + str(orb_suggest.get("error", "")) + " / " + str(orb_confirm.get("error", "")))
	var orb_end_pass := submit_unit_choice(orb_restored, 2, "pass")
	check(str(orb_end_pass.get("error", "")).is_empty() and orb_restored.phase == "charge" and (ResolutionFrames.current(orb_restored).is_empty() or str(ResolutionFrames.current(orb_restored).get("action_id", "")) != "phase-close:%d:shooting" % int(orb_restored.turn)), "Passing the remaining end window resumes phase progression after Orb Reanimation: " + str(orb_end_pass.get("error", "")))
	check(s.unit_abilities.used.get("resurrect-turn:2", -1) == s.turn and s.unit_abilities.used.has("orb:2"), "Orb use and per-player turn limit are persisted")
	# Current Warriors have their optional free reroll before healing is assigned.
	s = prepared()
	s.active = 2
	s.phase = "command"
	s.units[401].wounds = 0
	C.Reanimation.start_command(s)
	C.Reanimation.open_end_command(s)
	check(C.Reanimation.roll_unit(s, 4, six).error.is_empty() and C.Reanimation.pending(s).current.reroll_pending, "Their Number is Legion pauses after initial roll")
	var before_decision := var_to_bytes(s)
	for action in ["place", "suggest", "reset", "confirm"]:
		check(not C.resolve_reanimation(s, 2, action, 4, 401, Vector2.ZERO, s.revision, six).is_empty() and var_to_bytes(s) == before_decision, "Placement requests cannot bypass the Legion roll decision")
	var calls_before := dice_calls
	check(act(s, 2, "legion-reroll").is_empty() and dice_calls == calls_before + 1 and not C.Reanimation.pending(s).current.get("reroll_pending", false), "Legion rerolls once and new result is mandatory")
	check(not act(s, 2, "legion-reroll").is_empty(), "Cannot reroll a reroll")
	s = prepared()
	s.active = 2
	s.phase = "command"
	s.unit_abilities.phase_key = U.key(s)
	for id in [200, 201, 202]: s.units[id].wounds = 0
	s.cp[2] = 0
	C.Reanimation.start_command(s)
	check(C.Stratagems.open_command(s), "Below-half unit opens Bravery decision even at zero CP")
	check(C.Stratagems.eligibility_error(s, 2, 2, "insane-bravery").is_empty() and not C.Stratagems.use_error(s, 2, 2, "insane-bravery", s.revision).is_empty(), "Potential discount admits window but requires explicit use choice")
	var discount_choice: Dictionary = {}
	for option: Dictionary in C.unit_choices(s, 2):
		if option.action == "discount" and option.target == 2: discount_choice = option
	var discount_decision := C.Stratagems.pending_decision(s)
	var discount_option: Dictionary = {}
	for option: Dictionary in discount_decision.get("legal_options", []):
		if int(option.get("target", -1)) == 2 and str(option.get("value", "")) == "my-will-be-done": discount_option = option
	var discount_envelope := {"_decision_type": MatchCommandService.STRATAGEM_DECISION_ENVELOPE, "decision_id": str(discount_decision.get("decision_id", "")), "option_id": str(discount_option.get("id", "")), "choice": {"action": "stratagem-reaction", "model": -1, "target": 2, "value": "my-will-be-done", "die": -1}}
	var before_discount_choice := var_to_bytes(s)
	var wrong_discount_owner := MatchCommandService.execute(s, 1, {"kind": MatchCommandService.COMMAND_REACTION, "revision": s.revision, "choice": discount_envelope}, six)
	var stale_discount_revision := MatchCommandService.execute(s, 2, {"kind": MatchCommandService.COMMAND_REACTION, "revision": s.revision - 1, "choice": discount_envelope}, six)
	var stale_discount_option := discount_envelope.duplicate(true)
	stale_discount_option.option_id = "stale-option"
	var stale_discount_choice := MatchCommandService.execute(s, 2, {"kind": MatchCommandService.COMMAND_REACTION, "revision": s.revision, "choice": stale_discount_option}, six)
	check(not discount_choice.is_empty() and not discount_option.is_empty() and not wrong_discount_owner.get("error", "").is_empty() and not stale_discount_revision.get("error", "").is_empty() and not stale_discount_choice.get("error", "").is_empty() and before_discount_choice == var_to_bytes(s), "Public My Will Be Done declaration rejects wrong-owner, stale-revision and stale-option commands unchanged")
	var discount_error := str(MatchCommandService.execute(s, 2, {"kind": MatchCommandService.COMMAND_REACTION, "revision": s.revision, "choice": discount_envelope}, six).get("error", ""))
	check(discount_error.is_empty(), "My Will Be Done can be chosen when the unit is targeted: " + discount_error)
	var bravery_decision := C.Stratagems.pending_decision(s)
	var bravery_option: Dictionary = {}
	for option: Dictionary in bravery_decision.get("legal_options", []):
		if int(option.get("target", -1)) == 2 and str(option.get("value", "")) == "insane-bravery": bravery_option = option
	var bravery_choice := {"action": "stratagem-reaction", "model": -1, "target": 2, "value": "insane-bravery", "die": -1}
	var bravery_envelope := {"_decision_type": MatchCommandService.STRATAGEM_DECISION_ENVELOPE, "decision_id": str(bravery_decision.get("decision_id", "")), "option_id": str(bravery_option.get("id", "")), "choice": bravery_choice}
	var before_wrong_bravery_owner := var_to_bytes(s)
	var wrong_bravery_owner := MatchCommandService.execute(s, 1, {"kind": MatchCommandService.COMMAND_REACTION, "choice": bravery_envelope, "revision": s.revision}, six)
	check(not str(wrong_bravery_owner.get("error", "")).is_empty() and var_to_bytes(s) == before_wrong_bravery_owner, "The opponent cannot submit or mutate the Insane Bravery decision")
	var bravery_result := MatchCommandService.execute(s, 2, {"kind": MatchCommandService.COMMAND_REACTION, "choice": bravery_envelope, "revision": s.revision}, six)
	check(str(bravery_result.get("error", "")).is_empty() and s.cp[2] == 0 and A.potential_discount(s, 2, 2) == 0, "Free Insane Bravery spends the army-wide once-per-round discount through the public command, not CP")
	# The real UI freezes the new option and restores choices and RNG.
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	game.state = game.PreparedTraining.initial_state({"unit_abilities": true})
	game.combat_enabled = true
	game.unit_abilities = true
	game.auto_models.button_pressed = false
	game.unit_abilities_choice.button_pressed = true
	game._reset_history()
	game._spawn_pieces()
	game._dismiss_home(1)
	check(A.enabled(game.state), "Real UI opens a current-abilities training match through the local starter scenario")
	var before: Dictionary = game.state.duplicate(true)
	var rng: int = game.rng.state
	game._save_match()
	game._load_match()
	check(game.state == before and game.rng.state == rng and game.unit_abilities, "Current ability setup survives real save/load")
	game.queue_free()
	await process_frame
	print("Current unit ability checks: %d failures" % failures)
	quit(1 if failures else 0)
