extends SceneTree
const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Army = preload("res://scripts/edition_11/army_capabilities.gd")
const Equipment = preload("res://scripts/edition_11/equipment.gd")
const Geometry = preload("res://scripts/edition_11/contact_movement.gd")
const Detection = preload("res://scripts/edition_11/detection_rules.gd")
const Abilities = preload("res://scripts/edition_11/unit_abilities.gd")
const MatchCommandService = preload("res://scripts/edition_11/match_command_service.gd")
const ResolutionFrames = preload("res://scripts/edition_11/resolution_frame.gd")

var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func entry(identity: String, models: int = 1) -> Dictionary:
	return {"definition_id": "40kdc:11e:adeptus-astartes:%s" % identity, "models": models, "copies": 1}

func find_squad(state: Dictionary, owner: int, identity: String) -> int:
	for squad: int in state.squads:
		if state.squads[squad].owner != owner: continue
		for model: int in Geometry.alive(state, squad):
			if Abilities.identity(state.units[model]) == identity: return squad
	return -1

func find_model(state: Dictionary, owner: int, identity: String) -> int:
	for model: int in state.units:
		if state.units[model].owner == owner and Abilities.identity(state.units[model]) == identity: return model
	return -1

func action(state: Dictionary, player: int, action_id: String, target: int = -1, model: int = -1) -> Dictionary:
	for option: Dictionary in C.UnitActions.choices(state, player):
		if option.action == action_id and (target < 0 or option.target == target) and (model < 0 or option.model == model): return option
	return {}

func submit_choice(state: Dictionary, player: int, action_id: String, target: int = -1, model: int = -1) -> Dictionary:
	var decision := C.UnitActions.pending_decision(state)
	if decision.is_empty() or int(decision.get("priority_player_id", -1)) != player: return {"error": "No matching UnitActions decision for Player %d." % player}
	var option_projection: Dictionary = {}
	for candidate: Dictionary in decision.get("legal_options", []):
		if str(candidate.get("action", "")) == action_id and int(candidate.get("target", -1)) == target and (model < 0 or int(candidate.get("model", -1)) == model):
			option_projection = candidate
			break
	if option_projection.is_empty(): return {"error": "The pending decision does not offer %s for target %d." % [action_id, target]}
	var choice := action(state, player, action_id, target, model)
	if choice.is_empty(): return {"error": "UnitActions no longer offers %s for target %d." % [action_id, target]}
	return MatchCommandService.execute(state, player, {"kind": MatchCommandService.SELECT_UNIT_CHOICE, "revision": int(state.get("revision", -1)), "choice": {"_decision_type": MatchCommandService.UNIT_CHOICE_ENVELOPE, "decision_id": str(decision.get("decision_id", "")), "option_id": str(option_projection.get("id", "")), "choice": choice}})

func make_state(attach_shrike: bool = true) -> Dictionary:
	var lists := F.current_marine_selections()
	for owner in [1, 2]:
		lists[owner].entries = [entry("kayvaan-shrike"), entry("assault-intercessors-with-jump-packs", 5), entry("vanguard-veteran-squad-with-jump-packs", 5), entry("intercessor-squad", 5)]
	var state: Dictionary = F.P.initial_state({"checked_rosters": false, "official_mission": false, "unit_abilities": true, "combat_doctrines": true, "core_stratagems": true, "reanimation_protocols": true, "awakened_dynasty": true, "manual_allocation": false}, lists)
	if state.has("error"): return state
	state.awakened_dynasty.pending = []
	state.unit_abilities.setup_players = []
	var model := find_model(state, 1, "kayvaan-shrike")
	var veterans := find_squad(state, 1, "vanguard-veteran-squad-with-jump-packs")
	if attach_shrike and veterans >= 0: C.UnitActions.attach(state, model, veterans)
	state.mission.stage = "battle"
	return state

func check_weapon_plan(state: Dictionary, weapon: Dictionary, melee: bool) -> void:
	var model := find_model(state, 1, "kayvaan-shrike")
	var squad := find_squad(state, 1, "kayvaan-shrike")
	var target_squad := find_squad(state, 2, "intercessor-squad")
	var target_models: Array[int] = Geometry.alive(state, target_squad)
	if model < 0 or squad < 0 or target_squad < 0 or target_models.is_empty():
		check(false, "Shrike's %s attack has current-catalog attacker and target units" % str(weapon.get("id", "weapon")))
		return
	var target_model: int = target_models[0]
	var old_phase: String = str(state.phase)
	var old_active: int = int(state.active)
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
		var plan: Dictionary = C.AttackPlan.prepare(state, squad, melee, [{"model": model, "target": target_squad, "amount": amount, "weapon": weapon_id, "profile": "standard"}], true)
		check(str(plan.get("error", "")).is_empty() and plan.get("batches", []).size() == 1, "%s routes through AttackPlan: %s" % [weapon_id, str(plan.get("error", ""))])
	state.phase = old_phase
	state.active = old_active
	state.unit_abilities.phase_key = C.UnitActions.key(state)
	state.units[model].position = old_attacker_position
	state.units[target_model].position = old_target_position

func _initialize() -> void: call_deferred("run")

func run() -> void:
	var profile := Profiles.profile("kayvaan-shrike")
	check(profile.source_book_id == "000000139" and profile.source_datasheet_id == "000002708" and profile.source_export_updated_at == "2026-10-16T21:03:46+03:00", "Shrike profile identifies the local shared-book Wahapedia record")
	check(profile.points == 95 and profile.models == 1 and profile.base_size_source_mm == 40 and profile.stats == {"movement_inches": 12, "toughness": 4, "save_target": 3, "wounds": 5, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 4}, "Shrike points, base and characteristics match the local export")
	var catalog_resolution: Dictionary = Army.resolve("Space Marines", "40kdc:11e:adeptus-astartes:kayvaan-shrike")
	check(catalog_resolution.get("error", "").is_empty() and int(catalog_resolution.get("cost", -1)) == 95 and catalog_resolution.get("unsupported_abilities", []).is_empty(), "Shrike resolves from the current local catalog at source cost with no blocked abilities")
	var one_shrike := Army.admit({"schema_version": 2, "faction": "Space Marines", "category": "incursion", "points_limit": 1000, "entries": [{"definition_id": "40kdc:11e:adeptus-astartes:kayvaan-shrike", "models": 1, "copies": 1}]})
	var two_shrikes := Army.admit({"schema_version": 2, "faction": "Space Marines", "category": "incursion", "points_limit": 1000, "entries": [{"definition_id": "40kdc:11e:adeptus-astartes:kayvaan-shrike", "models": 1, "copies": 2}]})
	check(one_shrike.get("error", "").is_empty() and int(one_shrike.get("total", -1)) == 95 and not str(two_shrikes.get("error", "")).is_empty(), "One Epic Hero Shrike is admitted and a duplicate is rejected")
	check(profile.ranged[0].profiles.standard.range_inches == 18.0 and profile.ranged[0].profiles.standard.keywords == {"precision": true, "close-quarters": true} and profile.melee[0].profiles.standard.attacks == 7 and profile.melee[0].profiles.standard.keywords == {"precision": true, "twin-linked": true}, "Blackout and Raven's Talons retain their exported weapon traits")
	check(profile.keywords == ["INFANTRY", "CHARACTER", "CAPTAIN", "EPIC HERO", "PHOBOS", "SMOKE", "JUMP PACK", "IMPERIUM", "FLY", "EXPLOSIVES", "ADEPTUS ASTARTES", "RAVEN GUARD"], "Shrike profile retains all exported keywords")
	var state := make_state()
	check(not state.has("error"), "Shrike fixture materializes")
	if state.has("error"):
		print(state.error)
		quit(1)
		return
	var model := find_model(state, 1, "kayvaan-shrike")
	var squad: int = state.units[model].squad
	for owner in [1, 2]:
		var owner_model := find_model(state, owner, "kayvaan-shrike")
		check(owner_model >= 0, "Player %d materializes Shrike from the current Space Marines catalog" % owner)
		if owner_model >= 0:
			var owner_squad: int = int(state.units[owner_model].squad)
			var owner_unit: Dictionary = state.units[owner_model]
			var owner_stats: Dictionary = state.squads[owner_squad].get("stats", {}).duplicate(true)
			if owner_unit.has("attachment_role"):
				var defense: Dictionary = owner_unit.get("defense", {})
				owner_stats = {"movement_inches": owner_unit.get("movement", -1), "toughness": defense.get("toughness", -1), "save_target": defense.get("save_target", -1), "wounds": owner_unit.get("max_wounds", -1), "leadership_target": owner_unit.get("leadership_target", -1), "objective_control": owner_unit.get("objective_control", -1), "invulnerable_target": defense.get("invulnerable_target", -1)}
			check(owner_stats == profile.stats and owner_unit.get("keywords", []) == profile.keywords, "Player %d receives Shrike's source profile and keywords" % owner)
			check(Abilities.has(state, owner_squad, "deep-strike") and Abilities.has(state, owner_squad, "lone-operative") and Abilities.has(state, owner_squad, "echo-of-the-ravenspire"), "Player %d receives Shrike's current ability mapping" % owner)
	var jump_veterans := find_squad(state, 1, "vanguard-veteran-squad-with-jump-packs")
	var jump_intercessors := find_squad(state, 1, "assault-intercessors-with-jump-packs")
	var intercessors := find_squad(state, 1, "intercessor-squad")
	var standalone := make_state(false)
	var standalone_model := find_model(standalone, 1, "kayvaan-shrike")
	var standalone_veterans := find_squad(standalone, 1, "vanguard-veteran-squad-with-jump-packs")
	var standalone_jumps := find_squad(standalone, 1, "assault-intercessors-with-jump-packs")
	var standalone_intercessors := find_squad(standalone, 1, "intercessor-squad")
	check(Abilities.has(state, squad, "deep-strike") and Abilities.every_model_has(state, squad, "deep-strike") and Abilities.has(state, squad, "lone-operative") and Abilities.has(state, squad, "trifold-path-of-shadow") and Abilities.has(state, squad, "echo-of-the-ravenspire"), "Shrike's abilities register and his attached Jump Pack unit retains Deep Strike")
	check(C.UnitActions.attachment_allowed(standalone, standalone_model, standalone_veterans) and C.UnitActions.attachment_allowed(standalone, standalone_model, standalone_jumps), "Shrike can lead both exact source-listed Jump Pack bodyguards")
	check(not C.UnitActions.attachment_allowed(standalone, standalone_model, standalone_intercessors), "Shrike cannot lead an unlisted non-Jump Pack Intercessor Squad")
	check(Detection.stealth(state, squad) and Detection.detection_range(state, model, true) == 9.0, "Trifold Path grants unit-wide Stealth and -3 inches to grounded detection range")
	check(not Abilities.lone_operative_active(state, model), "Lone Operative is disabled while Shrike leads an attached unit")
	check(Abilities.has(state, squad, "transhuman-strategist"), "Shrike has Transhuman Strategist")
	check(Abilities.lone_operative_active(standalone, standalone_model), "Shrike has Lone Operative while he is not attached")
	for weapon: Dictionary in profile.get("ranged", []): check_weapon_plan(standalone, weapon, false)
	for weapon: Dictionary in profile.get("melee", []): check_weapon_plan(standalone, weapon, true)
	var warlord_choice := action(standalone, 1, "warlord")
	check(not warlord_choice.is_empty() and warlord_choice.model == standalone_model, "Shrike is eligible to be declared Warlord")
	if not warlord_choice.is_empty():
		var before_wrong_warlord_owner := var_to_bytes(standalone)
		var wrong_warlord_owner := submit_choice(standalone, 2, "warlord", -1, standalone_model)
		check(not str(wrong_warlord_owner.get("error", "")).is_empty() and var_to_bytes(standalone) == before_wrong_warlord_owner, "The opponent cannot submit or mutate Shrike's immediate Warlord choice")
		var warlord_result := submit_choice(standalone, 1, "warlord", -1, standalone_model)
		check(str(warlord_result.get("error", "")).is_empty(), "Shrike can be recorded as Warlord through the public command")
		standalone.first_player = 1
		var cp_before: int = standalone.cp[1]
		C.UnitActions.start_round(standalone)
		check(standalone.cp[1] == cp_before + 1, "Transhuman Strategist grants 1 CP when Shrike is Warlord")
	state.phase = "fight"
	state.active = 2
	state.fight_step = "complete"
	state.fight_actor = 2
	state.unit_abilities.window = {}
	state.unit_abilities.end_done = ""
	state.unit_abilities.phase_key = C.UnitActions.key(state)
	state.resolution_frames = []
	var echo_candidates := C.UnitActions.echo_ravenspire_squads(state, 1)
	check(squad in echo_candidates, "Echo of the Ravenspire is available at the end of the opponent's Fight phase when unengaged")
	var close_error := C.advance_phase(state, 2, state.revision)
	var end_decision := C.UnitActions.pending_decision(state)
	check(close_error.is_empty() and end_decision.get("timing", "") == "end-phase:fight" and ResolutionFrames.current(state).get("kind", "") == "phase-close", "Opponent Fight close suspends its phase-close frame for the normalized Echo of the Ravenspire decision: " + close_error)
	var attempts := 0
	while attempts < 2 and not end_decision.is_empty() and int(end_decision.get("priority_player_id", -1)) != 1:
		var priority_player := int(end_decision.get("priority_player_id", -1))
		var declined := submit_choice(state, priority_player, "pass")
		if not str(declined.get("error", "")).is_empty(): break
		end_decision = C.UnitActions.pending_decision(state)
		attempts += 1
	var echo_error := "No Echo of the Ravenspire decision for Player 1."
	if int(end_decision.get("priority_player_id", -1)) == 1:
		var echo_use := submit_choice(state, 1, "echo-of-ravenspire", squad)
		echo_error = str(echo_use.get("error", ""))
	check(echo_error.is_empty() and state.unit_abilities.reserves.has(squad) and ResolutionFrames.current(state).get("kind", "") == "phase-close", "Public Echo of the Ravenspire choice places the unit in reserves and retains phase close: " + echo_error)
	check(state.unit_abilities.reserves.has(squad) and state.unit_abilities.reserves[squad].get("source", "") == "echo-of-ravenspire" and Geometry.alive(state, squad).all(func(id: int) -> bool: return not state.units[id].get("on_battlefield", true)), "Echo records reserve source and removes every model from the battlefield")
	if state.unit_abilities.reserves.has(squad):
		var restored: Dictionary = bytes_to_var(var_to_bytes(state))
		var pass_end := submit_choice(restored, 1, "pass")
		check(str(pass_end.get("error", "")).is_empty() and (ResolutionFrames.current(restored).is_empty() or str(ResolutionFrames.current(restored).get("action_id", "")) != "phase-close:%d:fight" % int(state.turn)), "Passing after save/restore resumes Fight close: " + str(pass_end.get("error", "")))
	var engaged := make_state()
	var engaged_model := find_model(engaged, 1, "kayvaan-shrike")
	var engaged_squad: int = engaged.units[engaged_model].squad
	var enemy_model := Geometry.alive(engaged, find_squad(engaged, 2, "intercessor-squad"))[0]
	engaged.units[enemy_model].position = engaged.units[engaged_model].position
	engaged.phase = "fight"
	engaged.active = 2
	check(engaged_squad not in C.UnitActions.echo_ravenspire_squads(engaged, 1), "Echo of the Ravenspire is unavailable while the unit is engaged")
	print("Kayvaan Shrike profile checks: %d failures" % failures)
	quit(1 if failures else 0)
