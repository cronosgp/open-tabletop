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
const WeaponChecks = preload("res://tests/space_marine_datasheet_checks.gd")
const Equipment = preload("res://scripts/edition_11/equipment.gd")
const LeaderLinks = preload("res://scripts/edition_11/marine_leader_links.gd")
const SupportAttachments = preload("res://scripts/edition_11/support_attachments.gd")
const UNIT := "land-speeder"
const UNIT_ID := "40kdc:11e:adeptus-astartes:land-speeder"

var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func lists(chapters: Dictionary = {}) -> Dictionary:
	var result := F.current_marine_selections()
	for owner: int in [1, 2]:
		result[owner].entries.append({"definition_id": UNIT_ID, "models": 1, "copies": 1})
		if owner == 2: result[owner].entries.append({"definition_id": "40kdc:11e:adeptus-astartes:captain", "models": 1, "copies": 1})
	return result

func fixture(chapters: Dictionary = {}) -> Dictionary:
	var options: Dictionary = {
		"checked_rosters": false, "official_mission": false, "unit_abilities": true,
		"combat_doctrines": true, "core_stratagems": true, "attack_rerolls": true,
		"manual_allocation": false
	}
	if not chapters.is_empty(): options.marine_chapters = chapters.duplicate(true)
	return F.P.initial_state(options, lists(chapters))

func purgation_fixture() -> Dictionary:
	var selections := F.selections()
	selections[1].entries.pop_back()
	selections[1].entries.append({"definition_id": UNIT_ID, "models": 1, "copies": 1})
	var state: Dictionary = F.P.initial_state({
		"checked_rosters": false, "official_mission": true, "terrain_layout": C.Mission.DEFAULT_TERRAIN_LAYOUT,
		"unit_abilities": true, "combat_doctrines": true, "reanimation_protocols": true,
		"awakened_dynasty": true, "core_stratagems": true,
		"manual_allocation": true
	}, selections)
	if state.has("error"): return state
	state.mission.stage = "battle"
	if not state.get("awakened_dynasty", {}).get("pending", []).is_empty():
		var attachment_error: String = C.select_awakened_attachment(state, 2, -1, int(state.revision))
		if not attachment_error.is_empty(): return {"error": attachment_error}
	return state

func squad(state: Dictionary, identity: String, owner: int = -1, occurrence: int = 0) -> int:
	var matches: Array[int] = []
	for model: int in state.units:
		var unit: Dictionary = state.units[model]
		if C.UnitAbilities.identity(unit) != identity: continue
		if owner >= 0 and int(unit.owner) != owner: continue
		var squad_id := int(unit.squad)
		if squad_id not in matches: matches.append(squad_id)
	return matches[occurrence] if occurrence < matches.size() else -1

func models(state: Dictionary, squad_id: int) -> Array[int]:
	var result: Array[int] = C.living(state, squad_id)
	result.sort()
	return result

func profile_weapon(profile: Dictionary, category: String, identity: String, profile_id: String = "standard", additional: bool = false) -> Dictionary:
	var rows: Array = profile.get(category, [])
	if additional: rows = profile.get("additional_weapon_profiles", {}).get(category, [])
	for weapon: Dictionary in rows:
		if str(weapon.get("id", "")) == identity:
			return weapon.get("profiles", {}).get(profile_id, {})
	return {}

func choice_for(choices: Array, action: String, target: int, value: String = "", model: int = -1) -> Dictionary:
	for candidate: Dictionary in choices:
		if str(candidate.get("action", "")) != action or int(candidate.get("target", -1)) != target: continue
		if model >= 0 and int(candidate.get("model", -1)) != model: continue
		if not value.is_empty() and str(candidate.get("value", "")) != value: continue
		return candidate
	return {}

func submit_choice(state: Dictionary, player: int, action: String, target: int, model: int = -1, point: Vector2 = Vector2.ZERO, roller: Callable = Callable()) -> Dictionary:
	var decision := PendingDecisions.current(state, ["unit-actions"])
	var projected: Dictionary = {}
	for option: Dictionary in decision.get("legal_options", []):
		if str(option.get("action", "")) == action and int(option.get("target", -1)) == target and int(option.get("model", -1)) == model:
			projected = option
			break
	if projected.is_empty(): return {"error": "The current decision does not project %s for target %d." % [action, target]}
	var selected: Dictionary = choice_for(C.UnitActions.choices(state, int(decision.get("priority_player_id", player))), action, target, "", model)
	if selected.is_empty(): return {"error": "UnitActions no longer offers the projected Purgation Run choice."}
	var payload := {"_decision_type": MatchCommands.UNIT_CHOICE_ENVELOPE, "decision_id": str(decision.get("decision_id", "")), "option_id": str(projected.get("id", "")), "choice": selected}
	return MatchCommands.execute(state, player, {"kind": MatchCommands.SELECT_UNIT_CHOICE, "revision": int(state.revision), "point": point, "choice": payload}, roller)

func chapter_keywords_do_not_leak(profile: Dictionary, base_state: Dictionary, speeder: int) -> void:
	var source_keywords: Array = profile.get("keywords", [])
	var base_model := models(base_state, speeder)[0]
	check(source_keywords.has("RAVENWING") and not base_state.units[base_model].get("keywords", []).has("RAVENWING"), "The exported RAVENWING keyword is contextual, not unconditional in prepared shared profiles")
	var dark_angels_state := fixture({1: "DARK ANGELS", 2: "DARK ANGELS"})
	var dark_speeder := squad(dark_angels_state, UNIT, 1)
	var dark_models := models(dark_angels_state, dark_speeder)
	check(not dark_angels_state.has("error") and not dark_models.is_empty() and dark_angels_state.units[dark_models[0]].keywords.has("RAVENWING"), "Dark Angels context grants RAVENWING to this VEHICLE with FLY")

func run() -> void:
	var profile := Profiles.profile(UNIT)
	check(profile.get("source_book_id") == "000000139" and profile.get("source_datasheet_id") == "000002711" and profile.get("source_export_updated_at") == "2026-10-16T21:03:46+03:00", "Land Speeder cites the pinned shared-book Wahapedia e11 datasheet")
	check(profile.get("points_by_models", {}) == {1: 105} and profile.get("third_plus_points_by_models", {}) == {1: 105} and profile.get("models") == 1 and profile.get("base_size_source_mm", []) == [105, 70] and str(profile.get("geometry_scope", "")).contains("proxy") and is_equal_approx(float(profile.get("base_radius_inches", 0.0)), 52.5 / 25.4), "One-model 105-point profile and 105 x 70 mm source base use an explicitly labelled bounding-circle proxy")
	check(profile.get("stats", {}) == {"movement_inches": 14, "toughness": 8, "save_target": 3, "wounds": 9, "leadership_target": 6, "objective_control": 3, "invulnerable_target": 0}, "M14/T8/Sv3+/W9/Ld6+/OC3 and no invulnerable save match the local rows")
	check(profile.get("keywords", []) == ["VEHICLE", "FRAME", "FLY", "IMPERIUM", "RAVENWING", "SPEEDER", "ADEPTUS ASTARTES"], "All exported keywords, including Chapter-contextual RAVENWING, are represented")
	check(profile_weapon(profile, "ranged", "multi-melta") == {"name": "Multi-melta", "range_inches": 18.0, "attacks": 2, "skill": 3, "strength": 10, "ap": -3, "damage": "D3+2", "keywords": {"melta": 3}}, "Multi-melta profile matches the export")
	check(profile_weapon(profile, "ranged", "onslaught-gatling-cannon") == {"name": "Onslaught Gatling Cannon", "range_inches": 24.0, "attacks": 8, "skill": 3, "strength": 5, "ap": -1, "damage": 1, "keywords": {"devastating-wounds": true}, "target_restricted_traits": {"devastating-wounds": ["MONSTER", "VEHICLE"]}}, "Onslaught profile and conditional Devastating Wounds match the export")
	check(profile_weapon(profile, "ranged", "stormfury-missile-launcher") == {"name": "Stormfury Missile Launcher", "range_inches": 48.0, "attacks": 1, "skill": 3, "strength": 10, "ap": -3, "damage": "D3+3", "keywords": {}}, "Stormfury Missile Launcher profile matches the export")
	check(profile_weapon(profile, "ranged", "pyrecannon", "standard", true) == {"name": "Pyrecannon", "range_inches": 12.0, "attacks": 4, "skill": 0, "strength": 6, "ap": -1, "damage": 1, "keywords": {"blast": 2, "torrent": true}}, "Optional Pyrecannon profile and traits match the export")
	check(profile_weapon(profile, "melee", "armoured-impact") == {"name": "Armoured Impact", "range_inches": 0.0, "attacks": 3, "skill": 4, "strength": 6, "ap": 0, "damage": 1, "keywords": {}}, "Armoured Impact profile matches the export")
	check(profile.get("ranged", []).map(func(w: Dictionary) -> String: return w.id) == ["multi-melta", "onslaught-gatling-cannon", "stormfury-missile-launcher"] and profile.get("melee", []).size() == 1 and profile.get("additional_weapon_profiles", {}).get("ranged", []).size() == 1, "The full default loadout and only source-listed replacement are represented")
	check(Catalog.SPECS.get(UNIT, {}).get("current_reference", false) and int(Catalog.SPECS.get(UNIT, {}).get("max_supported_copies", 0)) == 3 and Roster.POINTS.get(UNIT, {}).get("sizes", {}) == {1: 105} and Roster.POINTS.get(UNIT, {}).get("third_plus_sizes", {}) == {1: 105}, "The consolidated local catalog and roster price data match the one-model datasheet")
	var catalog_choice := Catalog.current_catalog_choice({"id": UNIT_ID, "edition": "11e", "faction": "Space Marines"})
	check(catalog_choice.get("options", []) == [{"models": 1, "cost": 105, "third_plus_cost": 105}], "The current catalog offers the source model count and unchanged later-copy price")
	var three_speeder_report := Catalog.admit({"schema_version": 2, "faction": "Space Marines", "category": "custom", "points_limit": 1000, "entries": [{"definition_id": UNIT_ID, "models": 1, "copies": 3}]})
	check(three_speeder_report.get("error", "").is_empty() and int(three_speeder_report.get("total", -1)) == 315, "Three custom-list copies remain at 105 points each")
	var leader_targets: Array[String] = []
	for identity: String in LeaderLinks.TARGETS:
		if UNIT in LeaderLinks.TARGETS[identity] and not SupportAttachments.BODYGUARDS.has(identity): leader_targets.append(identity)
	var support_targets: Array[String] = []
	for identity: String in SupportAttachments.BODYGUARDS:
		if UNIT in SupportAttachments.BODYGUARDS[identity]: support_targets.append(identity)
	check(leader_targets.is_empty() and support_targets.is_empty(), "The source sheet has no Leader or Supported by attachment links")

	var state := fixture()
	check(not state.has("error"), "Both players materialize Land Speeder and supporting units from the current Marine catalog: %s" % str(state.get("error", "")))
	if state.has("error"):
		print("Current Land Speeder checks: %d failures" % (failures + 1))
		quit(1)
		return
	var speeder := squad(state, UNIT, 1)
	var opponent_speeder := squad(state, UNIT, 2)
	var target := squad(state, "intercessor-squad", 2, 0)
	var model := models(state, speeder)[0]
	check(speeder > 0 and opponent_speeder > 0 and models(state, speeder).size() == 1 and models(state, opponent_speeder).size() == 1 and target > 0, "Both players' catalogs construct the one-model Land Speeder")
	chapter_keywords_do_not_leak(profile, state, speeder)
	check(C.UnitAbilities.has(state, speeder, "deep-strike") and C.UnitAbilities.has(state, speeder, "purgation-run"), "Deep Strike and Purgation Run materialize on the shared-book Land Speeder")
	var reserve_state: Dictionary = bytes_to_var(var_to_bytes(state))
	var reserve_speeder := squad(reserve_state, UNIT, 1)
	var reserve_choice := choice_for(C.UnitActions.choices(reserve_state, 1), "reserve", reserve_speeder)
	var reserve_result := PublicUnitCommand.submit(reserve_state, 1, reserve_choice)
	check(not reserve_choice.is_empty() and reserve_result.get("error", "").is_empty() and reserve_state.unit_abilities.reserves.get(reserve_speeder, {}).get("deep_strike", false) and models(reserve_state, reserve_speeder).is_empty(), "The public Strategic Reserves choice records the Land Speeder's Deep Strike method")

	var lists_for_traits := state
	for id: int in lists_for_traits.units: lists_for_traits.units[id].position = Vector2(-18, -14) if lists_for_traits.units[id].owner == 1 else Vector2(18, 14)
	lists_for_traits.units[model].position = Vector2.ZERO
	for target_model: int in models(state, target): state.units[target_model].position = Vector2(20, 0)
	var fixed_weapon_failures := WeaponChecks.fixed_weapon_plan_failures(state, profile, model, target)
	check(fixed_weapon_failures.is_empty(), "All default ranged and melee profiles resolve through Equipment and AttackPlan: %s" % str(fixed_weapon_failures))

	var setup_speeder := squad(state, UNIT, 1)
	var setup_model := models(state, setup_speeder)[0]
	var cannon_options := C.UnitActions.choices(state, 1)
	var pyrecannon_choice := choice_for(cannon_options, "land-speeder-cannon", setup_speeder, "pyrecannon", setup_model)
	var before_wrong_owner := var_to_bytes(state)
	var wrong_owner_result := PublicUnitCommand.submit(state, 2, pyrecannon_choice)
	check(not pyrecannon_choice.is_empty() and not str(wrong_owner_result.get("error", "")).is_empty() and before_wrong_owner == var_to_bytes(state), "A wrong player cannot change the Land Speeder cannon")
	var pyrecannon_result := PublicUnitCommand.submit(state, 1, pyrecannon_choice)
	var has_pyrecannon: bool = state.units[setup_model].ranged_weapons.any(func(w: Dictionary) -> bool: return w.id == "pyrecannon") and not state.units[setup_model].ranged_weapons.any(func(w: Dictionary) -> bool: return w.id == "onslaught-gatling-cannon")
	var pyrecannon_equipment: Dictionary = Equipment.select(state, setup_model, false, "pyrecannon", "standard")
	check(pyrecannon_result.get("error", "").is_empty() and has_pyrecannon and pyrecannon_equipment.get("error", "").is_empty() and pyrecannon_equipment.get("stats", {}) == profile_weapon(profile, "ranged", "pyrecannon", "standard", true), "The public option installs the Pyrecannon, whose profile resolves through Equipment")
	var onslaught_choice := choice_for(C.UnitActions.choices(state, 1), "land-speeder-cannon", setup_speeder, "onslaught", setup_model)
	var onslaught_result := PublicUnitCommand.submit(state, 1, onslaught_choice)
	var has_onslaught: bool = state.units[setup_model].ranged_weapons.any(func(w: Dictionary) -> bool: return w.id == "onslaught-gatling-cannon") and not state.units[setup_model].ranged_weapons.any(func(w: Dictionary) -> bool: return w.id == "pyrecannon")
	check(onslaught_result.get("error", "").is_empty() and has_onslaught and int(state.squads[setup_speeder].training_cost) == 105, "The reversible public choice restores the source cannon without changing unit cost")

	state = purgation_fixture()
	check(not state.has("error"), "The Purgation Run integration fixture uses the Marine-versus-Necron CA mission: %s" % str(state.get("error", "")))
	if state.has("error"):
		print("Current Land Speeder checks: %d failures" % (failures + 1))
		quit(1)
		return
	speeder = squad(state, UNIT, 1)
	target = squad(state, "necron-warriors", 2)
	model = models(state, speeder)[0]
	state.phase = "shooting"
	state.turn = 3
	state.active = 1
	state.unit_abilities.setup_players = [1, 2]
	state.unit_abilities.battle_players = [1, 2]
	state.deployment.complete = true
	state.mission.stage = "battle"
	state.unit_abilities.window = {}
	state.stratagems.attack_rerolls = false
	for id: int in state.units: state.units[id].position = Vector2(-18, -14) if state.units[id].owner == 1 else Vector2(18, 14)
	state.units[model].position = Vector2.ZERO
	for target_model: int in models(state, target): state.units[target_model].position = Vector2(20, 0)
	var enemy: int = models(state, target)[0]
	state.units[enemy].keywords.append("VEHICLE")
	var restricted: Dictionary = C.UnitAbilities.weapon(state, model, target, profile.ranged[1].profiles.standard, false)
	check(not restricted.keywords.has("devastating-wounds"), "Onslaught Gatling Cannon suppresses Devastating Wounds against VEHICLE")
	state.units[enemy].keywords.erase("VEHICLE")
	var unrestricted: Dictionary = C.UnitAbilities.weapon(state, model, target, profile.ranged[1].profiles.standard, false)
	check(unrestricted.keywords.has("devastating-wounds"), "Onslaught Gatling Cannon retains Devastating Wounds against other targets")
	var attack := MatchCommands.execute(state, 1, {"kind": MatchCommands.ATTACK_PLAN, "revision": state.revision, "attacker": model, "entries": [{"model": model, "target": target, "amount": 1, "weapon": "multi-melta", "profile": "standard"}], "melee": false, "use_lethal": true}, func() -> int: return 1)
	check(attack.get("error", "").is_empty() and state.squads[speeder].shot and state.unit_abilities.window.get("kind", "") == Purgation.WINDOW, "Completing a Land Speeder shooting action opens the optional Purgation Run decision: %s shot=%s window=%s" % [str(attack.get("error", "")), str(state.squads[speeder].shot), str(state.unit_abilities.window)])
	var attack_frame := C.ResolutionFrames.current(state)
	var attack_decision := C.UnitActions.pending_decision(state)
	check(attack_frame.get("kind", "") == "attack" and attack_frame.get("status", "") == "suspended" and attack_frame.get("resume_point", "") == "attack-post-resolution-choice", "Purgation Run suspends the completed attack frame")
	check(attack_decision.get("action_id", "") == attack_frame.get("action_id", "") and attack_decision.get("resume_frame_id", "") == attack_frame.get("frame_id", ""), "The Purgation Run decision identifies the attack continuation")
	state = bytes_to_var(var_to_bytes(state))
	attack_frame = C.ResolutionFrames.current(state)
	attack_decision = C.UnitActions.pending_decision(state)
	check(attack_frame.get("status", "") == "suspended" and attack_decision.get("resume_frame_id", "") == attack_frame.get("frame_id", ""), "The reaction and attack frame survive serialization")
	var pass_state: Dictionary = bytes_to_var(var_to_bytes(state))
	var pass_result := submit_choice(pass_state, 1, "purgation-pass", speeder)
	check(pass_result.get("error", "").is_empty() and pass_state.unit_abilities.window.is_empty() and not C.Actions.charge_blocked(pass_state, speeder) and C.ResolutionFrames.current(pass_state).is_empty(), "Declining the optional Purgation Run resumes the attack without a move or charge restriction")
	var before_close := var_to_bytes(state)
	check(not C.advance_phase(state, 1, state.revision).is_empty() and before_close == var_to_bytes(state), "The phase cannot close while the post-attack Purgation Run choice is pending")
	var purgation_decision := PendingDecisions.current(state, ["unit-actions"])
	var before_wrong_choice_owner := var_to_bytes(state)
	var wrong_purgation_owner := submit_choice(state, 2, "purgation-use", speeder)
	check(not str(wrong_purgation_owner.get("error", "")).is_empty() and before_wrong_choice_owner == var_to_bytes(state), "Only the Land Speeder's owner can answer its Purgation Run decision")
	state = bytes_to_var(var_to_bytes(state))
	var restored_purgation_decision := PendingDecisions.current(state, ["unit-actions"])
	check(restored_purgation_decision.get("decision_id", "") == purgation_decision.get("decision_id", "") and restored_purgation_decision.get("resume_frame_id", "") == attack_frame.get("frame_id", ""), "Purgation decision and attack-frame identities survive save/restore")
	var use_result := submit_choice(state, 1, "purgation-use", speeder, -1, Vector2.ZERO, func() -> int: return 3)
	check(use_result.get("error", "").is_empty() and state.unit_abilities.window.get("kind", "") == Purgation.PLACEMENT and int(state.unit_abilities.window.distance) == 3 and C.Actions.charge_blocked(state, speeder), "Using Purgation Run rolls D6, opens placement, and blocks charging through the end of the turn")
	check(C.ResolutionFrames.current(state).get("frame_id", "") == attack_frame.get("frame_id", "") and C.UnitActions.pending_decision(state).get("resume_frame_id", "") == attack_frame.get("frame_id", ""), "Purgation placement retains the suspended attack continuation")
	var place := choice_for(C.UnitActions.choices(state, 1), "purgation-place", speeder, "", model)
	var rejected_distance := Purgation.position_error(state, model, Vector2(4, 0))
	check(not rejected_distance.is_empty(), "A Purgation placement beyond the rolled D6 distance is rejected")
	var destination := Vector2.ZERO
	for candidate: Vector2 in [Vector2(2, 0), Vector2(-2, 0), Vector2(0, 2), Vector2(0, -2), Vector2(1.5, 1.5), Vector2(-1.5, -1.5)]:
		if Purgation.position_error(state, model, candidate).is_empty(): destination = candidate; break
	var placement_result := submit_choice(state, 1, "purgation-place", speeder, model, destination)
	var confirm_result := submit_choice(state, 1, "purgation-confirm", speeder)
	check(not place.is_empty() and placement_result.get("error", "").is_empty() and confirm_result.get("error", "").is_empty() and state.units[model].position.is_equal_approx(destination) and destination != Vector2.ZERO and state.squads[speeder].moved_distance <= 3.0 and state.squads[speeder].move_type == "normal", "Purgation Run confirms a legal Normal Move within the rolled distance")
	check(C.ResolutionFrames.current(state).is_empty(), "Completing the optional Purgation Run closes the same attack continuation")
	state.turn += 1
	check(not C.Actions.charge_blocked(state, speeder), "Purgation Run's charge restriction expires after the turn")
	print("Current Land Speeder checks: %d failures" % failures)
	quit(1 if failures else 0)

func _initialize() -> void:
	call_deferred("run")
