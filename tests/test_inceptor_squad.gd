extends SceneTree
const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const Equipment = preload("res://scripts/edition_11/equipment.gd")
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Army = preload("res://scripts/edition_11/army_capabilities.gd")
const Catalog = preload("res://scripts/implemented_army_catalog.gd")
const RosterValidation = preload("res://scripts/edition_11/roster_validation.gd")
const MatchCommandService = preload("res://scripts/edition_11/match_command_service.gd")
const ResolutionFrames = preload("res://scripts/edition_11/resolution_frame.gd")
const PublicUnitCommand = preload("res://tests/public_unit_command.gd")
var failures := 0

const EXPECTED_WEAPONS := {
	"assault-bolters:standard": {"range_inches": 18.0, "attacks": 3, "skill": 3, "strength": 5, "ap": -1, "damage": 2, "keywords": {"assault": true, "twin-linked": true, "sustained-hits": 2, "close-quarters": true}},
	"plasma-exterminators:standard": {"range_inches": 18.0, "attacks": 2, "skill": 3, "strength": 7, "ap": -2, "damage": 2, "keywords": {"assault": true, "twin-linked": true, "close-quarters": true}},
	"plasma-exterminators:supercharge": {"range_inches": 18.0, "attacks": 2, "skill": 3, "strength": 8, "ap": -3, "damage": 3, "keywords": {"assault": true, "twin-linked": true, "close-quarters": true, "hazardous": true}},
	"ceramite-fists:standard": {"range_inches": 0.0, "attacks": 3, "skill": 3, "strength": 5, "ap": 0, "damage": 1, "keywords": {}}
}

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func selections(inceptor_models: int = 3) -> Dictionary:
	var result := F.current_marine_selections()
	result[1].entries = [{"definition_id": "40kdc:11e:adeptus-astartes:inceptor-squad", "models": inceptor_models, "copies": 1}]
	result[2].entries = [{"definition_id": "40kdc:11e:adeptus-astartes:intercessor-squad", "models": 5, "copies": 1}]
	return result

func find(state: Dictionary) -> Dictionary:
	var result := {"squad": -1, "models": [], "enemy": -1, "enemy_models": []}
	for id: int in state.units:
		var unit: Dictionary = state.units[id]
		match C.UnitAbilities.identity(unit):
			"inceptor-squad":
				result.squad = unit.squad
				result.models.append(id)
			"intercessor-squad":
				result.enemy = unit.squad
				result.enemy_models.append(id)
	return result

func place_test_units(state: Dictionary, found: Dictionary, enemy_x: float) -> void:
	for id: int in state.units:
		var unit: Dictionary = state.units[id]
		if unit.owner == 1 and unit.squad == found.squad:
			unit.position = Vector2(-12, 20.0 + float(id % 3) - 1)
		elif unit.owner == 2:
			unit.position = Vector2(enemy_x - 12.0, 20.0 + float(id % 5) - 2)

func check_attack_profile(state: Dictionary, squad: int, model: int, target: int, melee: bool, weapon_id: String, profile_name: String = "standard") -> Dictionary:
	var expected_key := "%s:%s" % [weapon_id, profile_name]
	var selected: Dictionary = Equipment.select(state, model, melee, weapon_id, profile_name)
	check(selected.get("error", "").is_empty(), "The Inceptor model exposes %s/%s to Equipment" % [weapon_id, profile_name])
	if not selected.get("error", "").is_empty(): return {}
	var expected: Dictionary = EXPECTED_WEAPONS[expected_key]
	for field in ["range_inches", "attacks", "skill", "strength", "ap", "damage"]:
		check(selected.stats.get(field) == expected[field], "%s/%s matches source %s" % [weapon_id, profile_name, field])
	check(selected.stats.get("keywords", {}) == expected.keywords, "%s/%s matches its complete source keyword profile" % [weapon_id, profile_name])
	var previous_phase: String = str(state.phase)
	var previous_positions: Dictionary = {}
	var entries: Array[Dictionary] = []
	if melee:
		state.phase = "fight"
		var target_models: Array[int] = C.living(state, target)
		if not target_models.is_empty():
			var contact_position: Vector2 = state.units[target_models[0]].position
			for attacker: int in C.living(state, squad):
				previous_positions[attacker] = state.units[attacker].position
				state.units[attacker].position = contact_position
				var melee_weapon: Dictionary = Equipment.select(state, attacker, true, weapon_id, profile_name)
				if not melee_weapon.has("error"):
					entries.append({"model": attacker, "target": target, "amount": int(melee_weapon.stats.attacks), "weapon": weapon_id, "profile": profile_name})
	else:
		entries.append({"model": model, "target": target, "amount": 1, "weapon": weapon_id, "profile": profile_name})
	var plan: Dictionary = C.AttackPlan.prepare(state, squad, melee, entries, true)
	state.phase = previous_phase
	for attacker: int in previous_positions: state.units[attacker].position = previous_positions[attacker]
	check(plan.get("error", "").is_empty() and plan.get("batches", []).size() == 1, "%s/%s routes through AttackPlan: %s" % [weapon_id, profile_name, plan.get("error", "")])
	if plan.get("error", "").is_empty() and plan.get("batches", []).size() == 1:
		var sources: Array = plan.batches[0].context.get("attack_sources", [])
		check(not sources.is_empty() and str(sources[0].get("weapon", "")) == weapon_id, "AttackPlan retains the correct weapon source for %s/%s" % [weapon_id, profile_name])
	return plan

func option(state: Dictionary, player: int, action: String, target: int = -999, value: String = "") -> Dictionary:
	for item: Dictionary in C.unit_choices(state, player):
		if item.action == action and (target == -999 or item.target == target) and (value.is_empty() or item.value == value): return item
	return {}

func model_option(state: Dictionary, player: int, action: String, target: int, model: int, value: String) -> Dictionary:
	for item: Dictionary in C.unit_choices(state, player):
		if item.action == action and item.target == target and item.model == model and item.value == value: return item
	return {}

func submit_choice(state: Dictionary, player: int, action_id: String, target: int = -1) -> Dictionary:
	var decision := C.UnitActions.pending_decision(state)
	if decision.is_empty() or int(decision.get("priority_player_id", -1)) != player: return {"error": "No matching UnitActions decision for Player %d." % player}
	var option_projection: Dictionary = {}
	for candidate: Dictionary in decision.get("legal_options", []):
		if str(candidate.get("action", "")) == action_id and int(candidate.get("target", -1)) == target:
			option_projection = candidate
			break
	if option_projection.is_empty(): return {"error": "The pending decision does not offer %s for target %d." % [action_id, target]}
	var choice := option(state, player, action_id, target)
	if choice.is_empty(): return {"error": "UnitActions no longer offers %s for target %d." % [action_id, target]}
	return MatchCommandService.execute(state, player, {"kind": MatchCommandService.SELECT_UNIT_CHOICE, "revision": int(state.get("revision", -1)), "choice": {"_decision_type": MatchCommandService.UNIT_CHOICE_ENVELOPE, "decision_id": str(decision.get("decision_id", "")), "option_id": str(option_projection.get("id", "")), "choice": choice}})

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var profile := Profiles.profile("inceptor-squad")
	check(profile.source_book_id == "000000139" and profile.source_datasheet_id == "000000125" and profile.source_export_updated_at == "2026-10-16T21:03:46+03:00", "Inceptor Squad links to the local shared-book Wahapedia datasheet")
	check(profile.models == 3 and profile.points_by_models == {3: 130, 6: 260} and profile.third_plus_points_by_models == {3: 150, 6: 280} and is_equal_approx(profile.base_radius_inches, 20.0 / 25.4), "The 3/6-model composition, first-two and third-plus costs, and 40 mm base match the export")
	check(profile.stats == {"movement_inches": 10, "toughness": 6, "save_target": 3, "wounds": 3, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 0} and profile.keywords.size() == 6 and "INFANTRY" in profile.keywords and "GRAVIS" in profile.keywords and "JUMP PACK" in profile.keywords and "IMPERIUM" in profile.keywords and "FLY" in profile.keywords and "ADEPTUS ASTARTES" in profile.keywords, "Inceptor characteristics and full keyword set match the export")
	var assault: Dictionary = profile.ranged[0].profiles.standard
	var plasma_standard: Dictionary = profile.additional_weapon_profiles.ranged[0].profiles.standard
	var plasma_supercharge: Dictionary = profile.additional_weapon_profiles.ranged[0].profiles.supercharge
	check(assault.name == "Assault Bolters" and assault.keywords == {"assault": true, "twin-linked": true, "sustained-hits": 2, "close-quarters": true}, "Default Assault Bolters preserve all extracted weapon traits")
	check(plasma_standard.strength == 7 and plasma_standard.ap == -2 and plasma_standard.damage == 2 and plasma_supercharge.strength == 8 and plasma_supercharge.ap == -3 and plasma_supercharge.damage == 3 and plasma_supercharge.keywords.hazardous, "Both Plasma Exterminator profiles match the local export")
	check(Army.SPECS["inceptor-squad"].get("current_reference", false), "Inceptor is admitted as a current local profile")
	var catalog := Catalog.new()
	root.add_child(catalog)
	catalog.select_edition("11e")
	check(catalog.contains("40kdc:11e:adeptus-astartes:inceptor-squad"), "Consolidated local construction catalog exposes the checked Inceptor profile")
	catalog.queue_free()
	await process_frame
	check(RosterValidation.POINTS["inceptor-squad"].sizes == {3: 130, 6: 260} and RosterValidation.POINTS["inceptor-squad"].third_plus_sizes == {3: 150, 6: 280}, "Roster checks resolve source Inceptor costs")
	var invalid := Army.admit({"schema_version": 2, "faction": "Space Marines", "category": "incursion", "points_limit": 1000, "entries": [{"definition_id": "40kdc:11e:adeptus-astartes:inceptor-squad", "models": 5, "copies": 1}]})
	check(not invalid.error.is_empty(), "Unsupported Inceptor squad size is rejected")
	var repeated := Army.admit({"schema_version": 2, "faction": "Space Marines", "category": "incursion", "points_limit": 1000, "entries": [{"definition_id": "40kdc:11e:adeptus-astartes:inceptor-squad", "models": 3, "copies": 3}]})
	check(repeated.error.is_empty() and repeated.total == 410, "Third Inceptor unit uses its source 150-point cost")
	var six := Army.admit({"schema_version": 2, "faction": "Space Marines", "category": "incursion", "points_limit": 1000, "entries": [{"definition_id": "40kdc:11e:adeptus-astartes:inceptor-squad", "models": 6, "copies": 1}]})
	check(six.error.is_empty() and six.total == 260, "The source six-model Inceptor composition is admitted at 260 points")
	var state := F.P.initial_state({"unit_abilities": true, "reanimation_protocols": true, "combat_doctrines": true, "awakened_dynasty": true, "core_stratagems": true, "manual_allocation": false}, selections())
	check(not state.has("error"), "Inceptor Squad and Intercessor target materialize with current Marine catalogs")
	if state.has("error"):
		print("Inceptor Squad checks: %d failures" % (failures + 1))
		quit(1)
		return
	var found := find(state)
	check(found.models.size() == 3 and C.UnitAbilities.every_model_has(state, found.squad, "deep-strike") and C.UnitAbilities.has(state, found.squad, "meteoric-descent") and C.UnitAbilities.has(state, found.squad, "parabolic-jetleap"), "All Inceptors carry Deep Strike and both datasheet abilities")
	for model: int in found.models:
		check(state.units[model].ranged_weapons[0].id == "assault-bolters" and state.units[model].melee_weapons[0].id == "ceramite-fists", "Every model starts with the source default loadout")
	var six_state := F.P.initial_state({"unit_abilities": true, "reanimation_protocols": true, "combat_doctrines": true, "awakened_dynasty": true, "core_stratagems": true, "manual_allocation": false}, selections(6))
	var six_found := find(six_state)
	check(not six_state.has("error") and six_found.models.size() == 6, "The source six-model composition materializes from the current catalog")
	state.phase = "deployment"
	state.unit_abilities.setup_players = []
	var offered_plasma_models: Array[int] = []
	for candidate: Dictionary in C.unit_choices(state, 1):
		if candidate.action == "inceptor-loadout" and candidate.target == found.squad and candidate.value == "plasma": offered_plasma_models.append(int(candidate.model))
	offered_plasma_models.sort()
	var expected_plasma_models: Array[int] = []
	for model: int in found.models: expected_plasma_models.append(model)
	expected_plasma_models.sort()
	check(offered_plasma_models == expected_plasma_models, "Setup offers an individual Plasma replacement choice for every Inceptor model")
	var plasma_choice := model_option(state, 1, "inceptor-loadout", found.squad, found.models[0], "plasma")
	check(not plasma_choice.is_empty(), "Setup presents the selected model's Plasma replacement")
	if not plasma_choice.is_empty():
		for model: int in found.models:
			var isolated_state: Dictionary = bytes_to_var(var_to_bytes(state))
			var individual_plasma := model_option(isolated_state, 1, "inceptor-loadout", found.squad, model, "plasma")
			check(not individual_plasma.is_empty() and PublicUnitCommand.error(isolated_state, 1, individual_plasma).is_empty(), "Each Inceptor can independently choose Plasma Exterminators")
			for other: int in found.models:
				check(isolated_state.units[other].ranged_weapons[0].id == ("plasma-exterminators" if other == model else "assault-bolters"), "An individual Plasma choice changes only its selected Inceptor")
		check(PublicUnitCommand.error(state, 1, plasma_choice).is_empty(), "The source Plasma replacement is accepted through the public command")
		for model: int in found.models:
			if model == plasma_choice.model: check(state.units[model].ranged_weapons[0].id == "plasma-exterminators" and state.units[model].ranged_weapons[0].profiles.supercharge.keywords.hazardous, "Selected model uses Plasma Exterminators and preserves Hazardous")
			else: check(state.units[model].ranged_weapons[0].id == "assault-bolters", "Other models retain their Assault Bolters, allowing the source's individual replacement choice")
	state.phase = "shooting"
	state.active = 1
	place_test_units(state, found, 0)
	for model: int in found.models:
		if model == plasma_choice.model:
			check_attack_profile(state, found.squad, model, found.enemy, false, "plasma-exterminators", "standard")
			check_attack_profile(state, found.squad, model, found.enemy, false, "plasma-exterminators", "supercharge")
		else:
			check_attack_profile(state, found.squad, model, found.enemy, false, "assault-bolters")
		check_attack_profile(state, found.squad, model, found.enemy, true, "ceramite-fists")
	state.squads[found.squad].move_type = "ingress"
	check(C.UnitAbilities.hit_bonus(state, found.squad, found.enemy, false) == 1 and C.UnitAbilities.hit_bonus(state, found.squad, found.enemy, true) == 0, "Meteoric Descent grants ranged +1 Hit only after an Ingress move this turn")
	var ingress_plan := check_attack_profile(state, found.squad, found.models[0], found.enemy, false, str(state.units[found.models[0]].ranged_weapons[0].id), str(state.units[found.models[0]].ranged_weapons[0].profiles.keys()[0]))
	check(not ingress_plan.get("batches", []).is_empty() and int(ingress_plan.batches[0].context.get("hit_modifier", 0)) == (1 if state.units[found.models[0]].ranged_weapons[0].id == "plasma-exterminators" or state.squads[found.squad].move_type == "ingress" else 0), "Meteoric Descent reaches the ranged AttackPlan context after Ingress")
	state.phase = "fight"
	state.active = 2
	check(C.UnitAbilities.hit_bonus(state, found.squad, found.enemy, false) == 1, "Meteoric Descent also applies to ranged attacks made out of phase during the Ingress turn")
	state.squads[found.squad].move_type = "normal"
	check(C.UnitAbilities.hit_bonus(state, found.squad, found.enemy, false) == 0, "Meteoric Descent does not remain after a non-Ingress move")
	state.phase = "fight"
	state.active = 2
	state.fight_actor = 2
	state.fight_step = "complete"
	state.unit_abilities.window = {}
	state.unit_abilities.end_done = ""
	state.unit_abilities.phase_key = C.UnitActions.key(state)
	state.resolution_frames = []
	for model: int in found.models: state.units[model].position = Vector2(-12, float((model % 3) - 1))
	for model: int in found.enemy_models: state.units[model].position = Vector2(14, float((model % 5) - 2))
	state.units[found.enemy_models[0]].position = state.units[found.models[0]].position + Vector2(0.1, 0.0)
	check(C.UnitActions.parabolic_jetleap_squads(state, 1).is_empty(), "Engaged Inceptors cannot use Parabolic Jetleap")
	state.units[found.enemy_models[0]].position = Vector2(14, -2)
	state.unit_abilities.end_done = ""
	var close_error := C.advance_phase(state, 2, state.revision)
	var end_decision := C.UnitActions.pending_decision(state)
	check(close_error.is_empty() and end_decision.get("timing", "") == "end-phase:fight" and ResolutionFrames.current(state).get("kind", "") == "phase-close", "Opponent Fight close suspends its phase-close frame for the Inceptor owner's normalized Parabolic Jetleap decision: " + close_error)
	var attempts := 0
	while attempts < 2 and not end_decision.is_empty() and int(end_decision.get("priority_player_id", -1)) != 1:
		var priority_player := int(end_decision.get("priority_player_id", -1))
		var declined := submit_choice(state, priority_player, "pass")
		if not str(declined.get("error", "")).is_empty(): break
		end_decision = C.UnitActions.pending_decision(state)
		attempts += 1
	var jetleap_error := "No Parabolic Jetleap decision for Player 1."
	if int(end_decision.get("priority_player_id", -1)) == 1:
		var jetleap := submit_choice(state, 1, "parabolic-jetleap", found.squad)
		jetleap_error = str(jetleap.get("error", ""))
	check(jetleap_error.is_empty() and state.unit_abilities.reserves.has(found.squad) and ResolutionFrames.current(state).get("kind", "") == "phase-close", "Public Parabolic Jetleap choice places the squad in Strategic Reserves and retains phase close: " + jetleap_error)
	if state.unit_abilities.reserves.has(found.squad):
		for model: int in found.models: check(not state.units[model].on_battlefield, "Every Inceptor leaves the battlefield together")
		var restored: Dictionary = bytes_to_var(var_to_bytes(state))
		var pass_end := submit_choice(restored, 1, "pass")
		check(str(pass_end.get("error", "")).is_empty() and (ResolutionFrames.current(restored).is_empty() or str(ResolutionFrames.current(restored).get("action_id", "")) != "phase-close:%d:fight" % int(state.turn)), "Passing after save/restore resumes Fight close: " + str(pass_end.get("error", "")))
		state = restored
		state.phase = "movement"
		state.active = 1
		state.round = 2
		state.unit_abilities.window = {}
		check(not option(state, 1, "ingress", found.squad).is_empty(), "Reserved Inceptors may use the shared Deep Strike Ingress flow on their turn")
	print("Inceptor Squad checks: %d failures" % failures)
	quit(1 if failures else 0)
