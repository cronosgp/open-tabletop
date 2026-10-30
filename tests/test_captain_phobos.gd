extends SceneTree
const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const P = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Army = preload("res://scripts/edition_11/army_capabilities.gd")
const Equipment = preload("res://scripts/edition_11/equipment.gd")
const A = C.UnitAbilities
const Fluidity = preload("res://scripts/edition_11/tactical_fluidity.gd")
const Detection = preload("res://scripts/edition_11/detection_rules.gd")
const MatchCommandService = preload("res://scripts/edition_11/match_command_service.gd")
const ResolutionFrames = preload("res://scripts/edition_11/resolution_frame.gd")
const PublicUnitCommand = preload("res://tests/public_unit_command.gd")
var failures := 0
func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1
func six() -> int: return 6
func selections() -> Dictionary:
	var result := F.current_marine_selections()
	for owner in [1, 2]:
		result[owner].entries = [
			{"definition_id": "40kdc:11e:adeptus-astartes:captain-in-phobos-armour", "models": 1, "copies": 1},
			{"definition_id": "40kdc:11e:adeptus-astartes:infiltrator-squad", "models": 5, "copies": 1}]
	return result
func fixture() -> Dictionary:
	var state := F.P.initial_state({"unit_abilities": true, "reanimation_protocols": true, "combat_doctrines": true, "awakened_dynasty": true, "core_stratagems": true}, selections())
	if state.has("error"): return state
	state.phase = "shooting"
	state.active = 1
	state.turn = 3
	state.round = 2
	state.mission.stage = "battle"
	state.unit_abilities.setup_players = [1, 2]
	state.unit_abilities.battle_players = [1, 2]
	state.unit_abilities.window = {}
	state.unit_abilities.end_done = ""
	state.awakened_dynasty.pending = []
	state.terrain.areas = []
	for model: int in state.units: state.units[model].position = Vector2(-18, -12) if state.units[model].owner == 1 else Vector2(18, 12)
	return state
func model_for(state: Dictionary, identity: String, owner: int = 1) -> int:
	for model: int in state.units:
		if state.units[model].owner == owner and A.identity(state.units[model]) == identity: return model
	return -1
func choose(state: Dictionary, owner: int, action: String, target: int = -1) -> Dictionary:
	for row: Dictionary in C.unit_choices(state, owner):
		if row.action == action and (target < 0 or row.target == target): return row
	return {}
func choose_model(state: Dictionary, owner: int, action: String, model: int) -> Dictionary:
	for row: Dictionary in C.unit_choices(state, owner):
		if row.action == action and row.model == model: return row
	return {}
func choose_value(state: Dictionary, owner: int, action: String, model: int, value: String) -> Dictionary:
	for row: Dictionary in C.unit_choices(state, owner):
		if row.action == action and row.model == model and row.value == value: return row
	return {}
func act(state: Dictionary, owner: int, action: String, target: int, point: Vector2 = Vector2.ZERO) -> String:
	var row := choose(state, owner, action, target)
	if row.is_empty(): return "missing choice: " + action
	var error := PublicUnitCommand.error(state, owner, row, point, six)
	if not error.is_empty(): print(action, " failed: ", error)
	return error
func submit_public_choice(state: Dictionary, owner: int, action_id: String, target: int = -1, model: int = -1, point: Vector2 = Vector2.ZERO, value: String = "") -> Dictionary:
	var decision := C.UnitActions.pending_decision(state)
	var selected: Dictionary = {}
	for candidate: Dictionary in C.unit_choices(state, owner):
		if str(candidate.get("action", "")) == action_id and int(candidate.get("target", -1)) == target and int(candidate.get("model", -1)) == model and (value.is_empty() or str(candidate.get("value", "")) == value):
			selected = candidate
			break
	if selected.is_empty(): return {"error": "UnitActions no longer offers %s for target %d/model %d." % [action_id, target, model]}
	if decision.is_empty():
		return MatchCommandService.execute(state, owner, {"kind": MatchCommandService.SELECT_UNIT_CHOICE, "revision": int(state.get("revision", -1)), "point": point, "choice": selected}, six)
	if int(decision.get("priority_player_id", -1)) != owner: return {"error": "No matching UnitActions decision for Player %d." % owner}
	var projected: Dictionary = {}
	for candidate: Dictionary in decision.get("legal_options", []):
		if str(candidate.get("action", "")) == action_id and int(candidate.get("target", -1)) == target and int(candidate.get("model", -1)) == model and (value.is_empty() or str(candidate.get("value", "")) == value):
			projected = candidate
			break
	if projected.is_empty(): return {"error": "The pending decision does not offer %s for target %d/model %d." % [action_id, target, model]}
	return MatchCommandService.execute(state, owner, {"kind": MatchCommandService.SELECT_UNIT_CHOICE, "revision": int(state.get("revision", -1)), "point": point, "choice": {"_decision_type": MatchCommandService.UNIT_CHOICE_ENVELOPE, "decision_id": str(decision.get("decision_id", "")), "option_id": str(projected.get("id", "")), "choice": selected}}, six)

func submit_doctrine(state: Dictionary, owner: int, doctrine: String) -> Dictionary:
	var decision := C.Doctrines.pending_decision(state)
	if decision.is_empty() or int(decision.get("priority_player_id", -1)) != owner: return {"error": "No matching Combat Doctrine decision belongs to Player %d." % owner}
	for option: Dictionary in decision.get("legal_options", []):
		if str(option.get("action", "")) != "combat-doctrine" or str(option.get("value", "")) != doctrine: continue
		return MatchCommandService.execute(state, owner, {"kind": MatchCommandService.SELECT_DOCTRINE, "revision": int(state.get("revision", -1)), "doctrine": doctrine, "decision_id": str(decision.get("decision_id", "")), "option_id": str(option.get("id", ""))}, six)
	return {"error": "The current Combat Doctrine decision does not offer %s." % doctrine}

func check_weapon_plan(state: Dictionary, model: int, target_squad: int, weapon: Dictionary, melee: bool) -> void:
	var living_targets: Array[int] = C.living(state, target_squad)
	if living_targets.is_empty():
		check(false, "%s has a living target for its AttackPlan" % str(weapon.get("id", "weapon")))
		return
	var target_model: int = living_targets[0]
	var prior_phase: String = str(state.phase)
	var prior_active: int = int(state.active)
	var old_attacker_position: Vector2 = state.units[model].position
	var old_target_position: Vector2 = state.units[target_model].position
	state.units[model].position = Vector2.ZERO
	state.units[target_model].position = Vector2(1.75, 0.0) if melee else Vector2(10.0, 0.0)
	state.phase = "fight" if melee else "shooting"
	state.active = 1
	var weapon_id := str(weapon.get("id", ""))
	var expected: Dictionary = weapon.get("profiles", {}).get("standard", {})
	var selected: Dictionary = Equipment.select(state, model, melee, weapon_id, "standard")
	check(str(selected.get("error", "")).is_empty() and selected.get("stats", {}) == expected, "%s enters Equipment with its exact source profile: %s" % [weapon_id, str(selected.get("error", ""))])
	if str(selected.get("error", "")).is_empty():
		var amount := int(expected.get("attacks", 1)) if melee else 1
		var plan: Dictionary = C.AttackPlan.prepare(state, int(state.units[model].squad), melee, [{"model": model, "target": target_squad, "amount": amount, "weapon": weapon_id, "profile": "standard"}], true)
		check(str(plan.get("error", "")).is_empty() and plan.get("batches", []).size() == 1, "%s routes through AttackPlan: %s" % [weapon_id, str(plan.get("error", ""))])
	state.phase = prior_phase
	state.active = prior_active
	state.unit_abilities.phase_key = C.UnitActions.key(state)
	state.units[model].position = old_attacker_position
	state.units[target_model].position = old_target_position

func _initialize() -> void: call_deferred("run")
func run() -> void:
	var s := fixture()
	if s.has("error"):
		print(s)
		check(false, "Phobos Captain admitted into local roster")
		quit(1)
		return
	var captain := model_for(s, "captain-in-phobos-armour")
	var squad := int(s.units[captain].squad)
	var profile := P.profile("captain-in-phobos-armour")
	var catalog_resolution: Dictionary = Army.resolve("Space Marines", "40kdc:11e:adeptus-astartes:captain-in-phobos-armour")
	check(catalog_resolution.get("error", "").is_empty() and int(catalog_resolution.get("cost", -1)) == 75 and catalog_resolution.get("unsupported_abilities", []).is_empty(), "Captain resolves at the source cost with no blocked abilities in the consolidated local catalog")
	check(profile.points == 75 and profile.source_datasheet_id == "000002701" and profile.stats.wounds == 5 and profile.stats.objective_control == 1 and profile.stats.invulnerable_target == 4 and "CAPTAIN" in profile.keywords, "Captain profile, local source identity, cost, stats, save or keywords mismatch")
	check(profile.ranged[0].profiles.standard.keywords.precision and profile.melee[0].profiles.standard.keywords.get("sustained-hits", 0) == 1, "Instigator Carbine or Combat Knife traits missing")
	check(A.has(s, squad, "leader") and A.has(s, squad, "deep-strike") and A.has(s, squad, "tactical-fluidity") and A.has(s, squad, "strategic-acumen") and A.has(s, squad, "transhuman-strategist") and A.scout_distance(s, squad) == 6, "Captain abilities not admitted")
	check(Detection.infiltrators(s, squad) and Detection.stealth(s, squad), "Captain Infiltrators or Stealth keyword effect missing")
	for owner in [1, 2]:
		var owner_captain := model_for(s, "captain-in-phobos-armour", owner)
		check(owner_captain >= 0, "Player %d materializes Captain in Phobos Armour from the current catalog" % owner)
		if owner_captain < 0: continue
		var owner_squad: int = int(s.units[owner_captain].squad)
		check(s.squads[owner_squad].get("stats", {}) == profile.stats and s.units[owner_captain].get("keywords", []) == profile.keywords, "Player %d receives the complete source characteristics and keywords" % owner)
		check(A.has(s, owner_squad, "deep-strike") and A.scout_distance(s, owner_squad) == 6 and Detection.infiltrators(s, owner_squad) and Detection.stealth(s, owner_squad), "Player %d receives Deep Strike, Scouts 6, Infiltrators and Stealth" % owner)
		var linked_model := model_for(s, "infiltrator-squad", owner)
		var linked_squad := int(s.units[linked_model].squad) if linked_model >= 0 else -1
		check(linked_squad >= 0 and C.UnitActions.attachment_allowed(s, owner_captain, linked_squad), "Player %d Captain can lead the source-linked Infiltrator Squad" % owner)
	for weapon: Dictionary in profile.get("ranged", []): check_weapon_plan(s, captain, int(s.units[model_for(s, "infiltrator-squad", 2)].squad), weapon, false)
	for weapon: Dictionary in profile.get("melee", []): check_weapon_plan(s, captain, int(s.units[model_for(s, "infiltrator-squad", 2)].squad), weapon, true)
	s.phase = "deployment"
	s.unit_abilities.setup_players = []
	check(C.UnitActions.attachment_allowed(s, captain, int(s.units[model_for(s, "infiltrator-squad")].squad)), "Captain Leader pairing missing")
	check(not choose_model(s, 1, "warlord", captain).is_empty(), "Captain Warlord choice missing")
	s.phase = "command"
	s.unit_abilities.phase_key = C.UnitActions.key(s)
	check(str(submit_doctrine(s, 1, "none").get("error", "")).is_empty(), "Start-of-Command doctrine command failed")
	var acumen := choose_value(s, 1, "acumen", captain, "assault")
	var acumen_result := submit_public_choice(s, 1, "acumen", squad, captain, Vector2.ZERO, "assault")
	check(not acumen.is_empty() and str(acumen_result.get("error", "")).is_empty() and C.Doctrines.active_for(s, squad) == "assault", "Captain Strategic Acumen failed to activate a doctrine: " + str(acumen_result.get("error", "")))
	var demi_pass := choose(s, 1, "pass")
	var demi_pass_result := submit_public_choice(s, 1, "pass") if not demi_pass.is_empty() else {"error": "No pass choice is available."}
	check(str(demi_pass_result.get("error", "")).is_empty(), "Post-doctrine end-of-Command decision passes through the normalized command: " + str(demi_pass_result.get("error", "")))
	s.phase = "start_turn"
	s.unit_abilities.warlords = {1: captain}
	var cp_before: int = s.cp[1]
	C.UnitActions.start_round(s)
	check(s.cp[1] == cp_before + 1, "Captain Warlord did not gain its once-per-round CP")
	# After the unit shoots, use its once-per-round D6 Normal Move.
	s.phase = "shooting"
	s.unit_abilities.setup_players = [1, 2]
	var target_model := model_for(s, "infiltrator-squad", 2)
	var target_squad: int = int(s.units[target_model].squad)
	for index in range(C.living(s, target_squad).size()):
		var target_member: int = C.living(s, target_squad)[index]
		s.units[target_member].position = Vector2(-8, -12 + float(index) * 1.0)
	var shot := C.resolve_attack_plan(s, 1, captain, [{"model": captain, "target": target_squad, "amount": 1, "weapon": str(s.units[captain].ranged_weapons[0].id), "profile": "standard"}], s.revision, false, true, six)
	check(shot.error.is_empty() and s.squads[squad].shot and s.unit_abilities.window.get("kind", "") == Fluidity.WINDOW, "A completed Captain shooting action opens the Tactical Fluidity decision: result=%s shot=%s window=%s" % [str(shot), str(s.squads[squad].get("shot", false)), str(s.unit_abilities.window)])
	var attack_frame := C.ResolutionFrames.current(s)
	var attack_decision := C.UnitActions.pending_decision(s)
	check(attack_frame.get("kind", "") == "attack" and attack_frame.get("status", "") == "suspended" and attack_decision.get("resume_frame_id", "") == attack_frame.get("frame_id", ""), "Tactical Fluidity decision retains the completed attack frame")
	var before_close := var_to_bytes(s)
	check(not C.advance_phase(s, 1, s.revision).is_empty() and before_close == var_to_bytes(s), "Phase close cannot skip Tactical Fluidity")
	check(C.UnitActions.actor(s) == 1 and not choose(s, 1, "fluidity-use", squad).is_empty(), "Post-shot Tactical Fluidity window missing")
	var use_decision_id := str(C.UnitActions.pending_decision(s).get("decision_id", ""))
	var wrong_owner_before := var_to_bytes(s)
	var wrong_owner_use := submit_public_choice(s, 2, "fluidity-use", squad)
	check(not str(wrong_owner_use.get("error", "")).is_empty() and wrong_owner_before == var_to_bytes(s), "Opponent cannot activate the Captain's Tactical Fluidity decision")
	var use_result := submit_public_choice(s, 1, "fluidity-use", squad)
	check(str(use_result.get("error", "")).is_empty(), "Normalized Tactical Fluidity D6 choice failed: " + str(use_result.get("error", "")))
	check(C.ResolutionFrames.current(s).get("frame_id", "") == attack_frame.get("frame_id", ""), "Tactical Fluidity placement step retains the same attack frame")
	check(s.unit_abilities.window.distance == 6 and str(C.UnitActions.pending_decision(s).get("decision_id", "")) != use_decision_id, "Tactical Fluidity opens a new placement decision after the D6 roll")
	var placement_save: Dictionary = bytes_to_var(var_to_bytes(s))
	var placement_decision_id := str(C.UnitActions.pending_decision(placement_save).get("decision_id", ""))
	var placement_frame_id := str(C.ResolutionFrames.current(placement_save).get("frame_id", ""))
	var early_close_before := var_to_bytes(placement_save)
	check(not C.advance_phase(placement_save, 1, placement_save.revision).is_empty() and early_close_before == var_to_bytes(placement_save), "Phase close remains blocked during the normalized Tactical Fluidity placement")
	var fluidity_model := int(placement_save.unit_abilities.window.positions.keys()[0])
	var wrong_owner_place := submit_public_choice(placement_save, 2, "fluidity-place", squad, fluidity_model, Vector2(-16, -12))
	check(not str(wrong_owner_place.get("error", "")).is_empty() and str(C.UnitActions.pending_decision(placement_save).get("decision_id", "")) == placement_decision_id, "Opponent cannot mutate the Tactical Fluidity placement decision")
	var preview_result := submit_public_choice(placement_save, 1, "fluidity-place", squad, fluidity_model, Vector2(-16, -12))
	var confirm_result := submit_public_choice(placement_save, 1, "fluidity-confirm", squad)
	check(str(preview_result.get("error", "")).is_empty() and str(confirm_result.get("error", "")).is_empty() and placement_save.units[captain].position == Vector2(-16, -12), "Normalized Tactical Fluidity Normal Move confirmation failed: " + str(preview_result.get("error", "")) + " / " + str(confirm_result.get("error", "")))
	check(placement_frame_id == str(attack_frame.get("frame_id", "")), "Tactical Fluidity placement resumes the same suspended attack frame")
	Fluidity.open_after_shot(placement_save, squad)
	check(placement_save.unit_abilities.window.is_empty(), "Tactical Fluidity reused in the same battle round")
	# A separate trigger at the end of the opposing Fight phase permits Fall Back.
	s = fixture()
	captain = model_for(s, "captain-in-phobos-armour")
	squad = int(s.units[captain].squad)
	var enemy := model_for(s, "infiltrator-squad", 2)
	s.units[captain].position = Vector2.ZERO
	s.units[enemy].position = Vector2(1.8, 0)
	s.phase = "fight"
	s.active = 2
	s.fight_actor = 2
	s.fight_step = "complete"
	s.unit_abilities.window = {}
	s.unit_abilities.end_done = ""
	s.unit_abilities.phase_key = C.UnitActions.key(s)
	s.resolution_frames = []
	check(squad in Fluidity.end_fight_squads(s, 1), "Engaged Captain's unit was not eligible for end-of-Fight Tactical Fluidity")
	var close_error := C.advance_phase(s, 2, s.revision)
	var end_decision := C.UnitActions.pending_decision(s)
	check(close_error.is_empty() and end_decision.get("timing", "") == "end-phase:fight" and ResolutionFrames.current(s).get("kind", "") == "phase-close", "Fight close suspends its phase-close frame for the normalized Tactical Fluidity decision: " + close_error)
	if C.UnitActions.actor(s) == 2:
		var opponent_pass := submit_public_choice(s, 2, "pass")
		check(str(opponent_pass.get("error", "")).is_empty() and C.UnitActions.actor(s) == 1, "Opponent can pass its earlier end-of-Fight choices before Tactical Fluidity: " + str(opponent_pass.get("error", "")))
	else:
		check(C.UnitActions.actor(s) == 1, "Captain receives the end-of-Fight Tactical Fluidity decision when the opponent has no earlier choices")
	var fluidity_start := submit_public_choice(s, 1, "fluidity-end", squad)
	var phase_close_frame_id := str(ResolutionFrames.current(s).get("frame_id", ""))
	check(str(fluidity_start.get("error", "")).is_empty() and s.unit_abilities.window.get("kind", "") == Fluidity.WINDOW and phase_close_frame_id.begins_with("phase-close:"), "Normalized Tactical Fluidity choice opens its Fall Back subchoice under the same phase-close frame: " + str(fluidity_start.get("error", "")))
	var fluidity_use := submit_public_choice(s, 1, "fluidity-use", squad)
	check(str(fluidity_use.get("error", "")).is_empty() and s.unit_abilities.window.get("kind", "") == Fluidity.PLACEMENT and s.unit_abilities.window.distance == 6, "Normalized subchoice starts the six-inch Fall Back placement: " + str(fluidity_use.get("error", "")))
	var placement_restored: Dictionary = bytes_to_var(var_to_bytes(s))
	var before_pending_close := var_to_bytes(placement_restored)
	var pending_close_error := C.advance_phase(placement_restored, 1, placement_restored.revision)
	check(not pending_close_error.is_empty() and before_pending_close == var_to_bytes(placement_restored) and str(ResolutionFrames.current(placement_restored).get("frame_id", "")) == phase_close_frame_id, "Phase close cannot skip the serialized Tactical Fluidity placement")
	var move_model := int(placement_restored.unit_abilities.window.positions.keys()[0])
	var move_preview := submit_public_choice(placement_restored, 1, "fluidity-place", squad, move_model, Vector2(-2, 0))
	var move_confirm := submit_public_choice(placement_restored, 1, "fluidity-confirm", squad)
	check(str(move_preview.get("error", "")).is_empty() and str(move_confirm.get("error", "")).is_empty() and placement_restored.squads[squad].fell_back and not C._engaged(placement_restored, squad) and placement_restored.unit_abilities.window.get("kind", "") == "end" and str(ResolutionFrames.current(placement_restored).get("frame_id", "")) == phase_close_frame_id, "Tactical Fluidity confirms a legal Fall Back, returns to the end window and keeps the same phase-close frame: " + str(move_preview.get("error", "")) + " / " + str(move_confirm.get("error", "")))
	var final_end_pass := submit_public_choice(placement_restored, 1, "pass")
	check(str(final_end_pass.get("error", "")).is_empty() and placement_restored.phase == "end_turn" and (ResolutionFrames.current(placement_restored).is_empty() or str(ResolutionFrames.current(placement_restored).get("action_id", "")) != "phase-close:%d:fight" % int(placement_restored.turn)), "Passing after the Fall Back resumes Fight close: " + str(final_end_pass.get("error", "")))
	print("Captain in Phobos Armour checks: %d failures" % failures)
	quit(1 if failures else 0)
