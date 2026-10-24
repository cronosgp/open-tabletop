extends SceneTree
const F = preload("res://tests/all_units_fixture.gd")
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Catalog = preload("res://scripts/edition_11/army_capabilities.gd")
const Roster = preload("res://scripts/edition_11/roster_validation.gd")
const Purgation = preload("res://scripts/edition_11/purgation_run.gd")
const C = F.C
const MatchCommands = preload("res://scripts/edition_11/match_command_service.gd")
const PendingDecisions = preload("res://scripts/edition_11/pending_decision_registry.gd")
const PublicUnitCommand = preload("res://tests/public_unit_command.gd")
var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func squad(state: Dictionary, identity: String) -> int:
	for model: int in state.units:
		if C.UnitAbilities.identity(state.units[model]) == identity: return int(state.units[model].squad)
	return -1

func submit_choice(state: Dictionary, player: int, action: String, target: int, model: int = -1, point: Vector2 = Vector2.ZERO, roller: Callable = Callable()) -> Dictionary:
	var decision := PendingDecisions.current(state, ["unit-actions"])
	var projected: Dictionary = {}
	for option: Dictionary in decision.get("legal_options", []):
		if str(option.get("action", "")) == action and int(option.get("target", -1)) == target and int(option.get("model", -1)) == model:
			projected = option
			break
	if projected.is_empty(): return {"error": "The current decision does not project %s for target %d." % [action, target]}
	var selected: Dictionary = {}
	for option: Dictionary in C.UnitActions.choices(state, int(decision.get("priority_player_id", player))):
		if str(option.get("action", "")) == action and int(option.get("target", -1)) == target and int(option.get("model", -1)) == model:
			selected = option
			break
	if selected.is_empty(): return {"error": "UnitActions no longer offers the projected Purgation Run choice."}
	var payload := {"_decision_type": MatchCommands.UNIT_CHOICE_ENVELOPE, "decision_id": str(decision.get("decision_id", "")), "option_id": str(projected.get("id", "")), "choice": selected}
	return MatchCommands.execute(state, player, {"kind": MatchCommands.SELECT_UNIT_CHOICE, "revision": int(state.revision), "point": point, "choice": payload}, roller)

func _initialize() -> void: call_deferred("run")

func run() -> void:
	var profile := Profiles.profile("land-speeder")
	check(profile.get("source_book_id") == "000000139" and profile.get("source_datasheet_id") == "000002711" and profile.get("source_export_updated_at") == "2026-10-16T21:03:46+03:00", "Land Speeder cites the pinned local Wahapedia e11 datasheet")
	check(profile.points_by_models == {1: 105} and profile.models == 1 and is_equal_approx(profile.base_radius_inches, 52.5 / 25.4), "Land Speeder composition, cost and documented oval-base proxy are represented")
	check(profile.stats == {"movement_inches": 14, "toughness": 8, "save_target": 3, "wounds": 9, "leadership_target": 6, "objective_control": 3, "invulnerable_target": 0}, "Land Speeder characteristics match the local rows")
	check(profile.ranged.map(func(w: Dictionary) -> String: return w.id) == ["multi-melta", "onslaught-gatling-cannon", "stormfury-missile-launcher"] and profile.melee[0].id == "armoured-impact", "Land Speeder fixed weapons match the extracted loadout")
	check(profile.ranged[0].profiles.standard.keywords == {"melta": 3} and profile.ranged[1].profiles.standard.attacks == 8 and profile.ranged[1].profiles.standard.target_restricted_traits == {"devastating-wounds": ["MONSTER", "VEHICLE"]} and profile.ranged[2].profiles.standard.damage == "D3+3", "Melta, restricted Devastating Wounds and missile Damage are represented")
	check(profile.additional_weapon_profiles.ranged[0].id == "pyrecannon" and profile.additional_weapon_profiles.ranged[0].profiles.standard.keywords == {"blast": 2, "torrent": true}, "Pyrecannon replacement profile preserves Blast 2 and Torrent")
	check(Catalog.SPECS.has("land-speeder") and Roster.POINTS["land-speeder"].sizes == {1: 105}, "Land Speeder enters local roster admission at the extracted cost")
	var lists := F.selections()
	lists[1].entries.append({"definition_id": "40kdc:11e:adeptus-astartes:land-speeder", "models": 1, "copies": 1})
	var state := F.P.initial_state({"checked_rosters": true, "official_mission": true, "unit_abilities": true, "combat_doctrines": true, "reanimation_protocols": true, "awakened_dynasty": true, "core_stratagems": true, "manual_allocation": false}, lists)
	check(not state.has("error"), "Land Speeder selection materializes in local runtime")
	if state.has("error"):
		print(state)
		quit(1)
		return
	state.mission.stage = "battle"
	state.awakened_dynasty.pending = []
	var setup_speeder := squad(state, "land-speeder")
	var setup_model := C.living(state, setup_speeder)[0]
	var pyrecannon_choice: Dictionary = {}
	for candidate: Dictionary in C.UnitActions.choices(state, 1):
		if candidate.get("action", "") == "land-speeder-cannon" and candidate.get("value", "") == "pyrecannon": pyrecannon_choice = candidate
	var pyrecannon_result: Dictionary = PublicUnitCommand.submit(state, 1, pyrecannon_choice, Vector2.ZERO, func() -> int: return 1)
	var has_pyrecannon: bool = state.units[setup_model].ranged_weapons.any(func(w: Dictionary) -> bool: return w.id == "pyrecannon") and not state.units[setup_model].ranged_weapons.any(func(w: Dictionary) -> bool: return w.id == "onslaught-gatling-cannon")
	var onslaught_choice: Dictionary = {}
	for candidate: Dictionary in C.UnitActions.choices(state, 1):
		if candidate.get("action", "") == "land-speeder-cannon" and candidate.get("value", "") == "onslaught": onslaught_choice = candidate
	var onslaught_result: Dictionary = PublicUnitCommand.submit(state, 1, onslaught_choice, Vector2.ZERO, func() -> int: return 1)
	var has_onslaught: bool = state.units[setup_model].ranged_weapons.any(func(w: Dictionary) -> bool: return w.id == "onslaught-gatling-cannon") and not state.units[setup_model].ranged_weapons.any(func(w: Dictionary) -> bool: return w.id == "pyrecannon")
	check(pyrecannon_result.error.is_empty() and has_pyrecannon and onslaught_result.error.is_empty() and has_onslaught, "Army preparation can swap the Onslaught Gatling Cannon for Pyrecannon and restore it: %s / %s" % [str(pyrecannon_result.get("error", "")), str(onslaught_result.get("error", ""))])
	state.phase = "shooting"
	state.turn = 3
	state.active = 1
	state.unit_abilities.setup_players = [1, 2]
	state.unit_abilities.battle_players = [1, 2]
	state.awakened_dynasty.pending = []
	state.deployment.complete = true
	state.mission.stage = "battle"
	state.unit_abilities.window = {}
	state.stratagems.attack_rerolls = false
	var speeder := squad(state, "land-speeder")
	var target := squad(state, "necron-warriors")
	var model := C.living(state, speeder)[0]
	for id: int in state.units: state.units[id].position = Vector2(-18, -14) if state.units[id].owner == 1 else Vector2(18, 14)
	state.units[model].position = Vector2.ZERO
	for id: int in C.living(state, target): state.units[id].position = Vector2(20, 0)
	check(C.UnitAbilities.has(state, speeder, "deep-strike") and C.UnitAbilities.has(state, speeder, "purgation-run"), "Deep Strike and Purgation Run materialize on the Land Speeder")
	var enemy: int = C.living(state, target)[0]
	state.units[enemy].keywords.append("VEHICLE")
	var restricted: Dictionary = C.UnitAbilities.weapon(state, model, target, profile.ranged[1].profiles.standard, false)
	check(not restricted.keywords.has("devastating-wounds"), "Onslaught Gatling Cannon suppresses Devastating Wounds against VEHICLE")
	state.units[enemy].keywords.erase("VEHICLE")
	var unrestricted: Dictionary = C.UnitAbilities.weapon(state, model, target, profile.ranged[1].profiles.standard, false)
	check(unrestricted.keywords.has("devastating-wounds"), "Onslaught Gatling Cannon retains Devastating Wounds against other targets")
	var attack := MatchCommands.execute(state, 1, {"kind": MatchCommands.ATTACK_PLAN, "revision": state.revision, "attacker": model, "entries": [{"model": model, "target": target, "amount": 1, "weapon": "multi-melta", "profile": "standard"}], "melee": false, "use_lethal": true}, func() -> int: return 1)
	check(attack.error.is_empty() and state.squads[speeder].shot and state.unit_abilities.window.get("kind", "") == Purgation.WINDOW, "Completing the Land Speeder shooting action opens the Purgation Run decision")
	var attack_frame := C.ResolutionFrames.current(state)
	var attack_decision := C.UnitActions.pending_decision(state)
	check(attack_frame.get("kind", "") == "attack" and attack_frame.get("status", "") == "suspended" and attack_frame.get("resume_point", "") == "attack-post-resolution-choice", "Purgation Run suspends the completed attack frame")
	check(attack_decision.get("action_id", "") == attack_frame.get("action_id", "") and attack_decision.get("resume_frame_id", "") == attack_frame.get("frame_id", ""), "Purgation Run decision identifies the attack continuation")
	state = bytes_to_var(var_to_bytes(state))
	attack_frame = C.ResolutionFrames.current(state)
	attack_decision = C.UnitActions.pending_decision(state)
	check(attack_frame.get("status", "") == "suspended" and attack_decision.get("resume_frame_id", "") == attack_frame.get("frame_id", ""), "Post-attack reaction and frame survive serialization")
	var before_close := var_to_bytes(state)
	check(not C.advance_phase(state, 1, state.revision).is_empty() and before_close == var_to_bytes(state), "Phase close cannot skip the post-attack Purgation Run choice")
	var use: Dictionary = C.unit_choices(state, 1).filter(func(choice: Dictionary) -> bool: return choice.action == "purgation-use")[0]
	var purgation_decision := PendingDecisions.current(state, ["unit-actions"])
	var before_wrong_owner := var_to_bytes(state)
	var wrong_owner_result := submit_choice(state, 2, "purgation-use", speeder)
	check(not str(wrong_owner_result.get("error", "")).is_empty() and var_to_bytes(state) == before_wrong_owner, "The shooting attacker cannot submit or mutate the Land Speeder's Purgation choice")
	state = bytes_to_var(var_to_bytes(state))
	var restored_purgation_decision := PendingDecisions.current(state, ["unit-actions"])
	check(restored_purgation_decision.get("decision_id", "") == purgation_decision.get("decision_id", "") and restored_purgation_decision.get("resume_frame_id", "") == attack_frame.get("frame_id", ""), "Purgation decision and attack frame identities survive save/restore")
	var use_error := str(submit_choice(state, 1, "purgation-use", speeder, -1, Vector2.ZERO, func() -> int: return 3).get("error", ""))
	check(use_error.is_empty() and state.unit_abilities.window.get("kind", "") == Purgation.PLACEMENT and int(state.unit_abilities.window.distance) == 3 and C.Actions.charge_blocked(state, speeder), "Using Purgation Run rolls D6 through the normalized command, opens placement and blocks charging this turn")
	check(C.ResolutionFrames.current(state).get("frame_id", "") == attack_frame.get("frame_id", "") and C.UnitActions.pending_decision(state).get("resume_frame_id", "") == attack_frame.get("frame_id", ""), "Purgation Run placement retains the same attack continuation")
	var place: Dictionary = C.unit_choices(state, 1).filter(func(choice: Dictionary) -> bool: return choice.action == "purgation-place")[0]
	var destination := Vector2.ZERO
	for candidate: Vector2 in [Vector2(2, 0), Vector2(-2, 0), Vector2(0, 2), Vector2(0, -2), Vector2(1.5, 1.5), Vector2(-1.5, -1.5)]:
		if Purgation.position_error(state, model, candidate).is_empty():
			destination = candidate
			break
	var placement_error := str(submit_choice(state, 1, "purgation-place", speeder, model, destination).get("error", ""))
	var confirm: Dictionary = C.unit_choices(state, 1).filter(func(choice: Dictionary) -> bool: return choice.action == "purgation-confirm")[0]
	var confirm_error := str(submit_choice(state, 1, "purgation-confirm", speeder).get("error", ""))
	check(placement_error.is_empty() and confirm_error.is_empty() and state.units[model].position.is_equal_approx(destination) and destination != Vector2.ZERO and state.squads[speeder].moved_distance <= 3.0 and state.squads[speeder].move_type == "normal", "Purgation Run confirms a legal Normal Move within the rolled distance")
	check(C.ResolutionFrames.current(state).is_empty(), "Completing Purgation Run closes the same attack continuation")
	state.turn += 1
	check(not C.Actions.charge_blocked(state, speeder), "Purgation Run charge restriction expires after the turn")
	print("Current Land Speeder checks: %d failures" % failures)
	quit(1 if failures else 0)
