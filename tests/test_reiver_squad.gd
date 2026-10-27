extends SceneTree
const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Army = preload("res://scripts/edition_11/army_capabilities.gd")
const Contact = preload("res://scripts/edition_11/contact_movement.gd")
const Morale = preload("res://scripts/edition_11/morale.gd")
const MatchCommandService = preload("res://scripts/edition_11/match_command_service.gd")
var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func selections() -> Dictionary:
	var result := F.selections()
	result[1].entries = [
		{"definition_id": "40kdc:11e:adeptus-astartes:reiver-squad", "models": 5, "copies": 1},
		{"definition_id": "40kdc:11e:adeptus-astartes:intercessor-squad", "models": 5, "copies": 1},
		{"definition_id": "40kdc:11e:adeptus-astartes:lieutenant-in-phobos-armour", "models": 1, "copies": 1}]
	result[2].entries = [{"definition_id": "40kdc:11e:necrons:necron-warriors", "models": 10, "copies": 1}]
	return result

func make_state() -> Dictionary:
	var state := F.P.initial_state({"unit_abilities": true, "reanimation_protocols": true, "combat_doctrines": true, "awakened_dynasty": true, "core_stratagems": true, "manual_allocation": false}, selections())
	if not state.has("error"):
		state.mission.stage = "battle"
		state.awakened_dynasty.pending = []
	return state

func find(state: Dictionary) -> Dictionary:
	var result := {"reiver": -1, "reiver_model": -1, "lieutenant": -1, "enemy": -1, "enemy_models": [], "marine_enemy": -1, "tempered_bearer": -1}
	for model: int in state.units:
		var unit: Dictionary = state.units[model]
		match C.UnitAbilities.identity(unit):
			"reiver-squad":
				result.reiver = unit.squad
				if result.reiver_model == -1: result.reiver_model = model
			"lieutenant-in-phobos-armour": result.lieutenant = model
			"necron-warriors":
				result.enemy = unit.squad
				result.enemy_models.append(model)
			"captain-on-bike":
				result.tempered_bearer = model
				result.marine_enemy = unit.squad
	return result

func option(state: Dictionary, player: int, action: String, target: int = -999, value: String = "") -> Dictionary:
	for item: Dictionary in C.unit_choices(state, player):
		if item.action == action and (target == -999 or item.target == target) and (value.is_empty() or item.value == value): return item
	return {}

func submit_normalized_choice(state: Dictionary, player: int, selected: Dictionary, roller: Callable = Callable(), decision_id: String = "", option_id: String = "") -> Dictionary:
	var decision := C.UnitActions.pending_decision(state)
	if decision.is_empty(): return {"error": "No UnitActions decision is open."}
	var projected: Dictionary = {}
	for option: Dictionary in decision.get("legal_options", []):
		if str(option.get("action", "")) == str(selected.get("action", "")) and int(option.get("model", -1)) == int(selected.get("model", -1)) and int(option.get("target", -1)) == int(selected.get("target", -1)) and str(option.get("value", "")) == str(selected.get("value", "")): projected = option; break
	if projected.is_empty(): return {"error": "The selected option is not in the current projected decision."}
	return MatchCommandService.execute(state, player, {"kind": MatchCommandService.SELECT_UNIT_CHOICE, "revision": int(state.revision), "choice": {"_decision_type": MatchCommandService.UNIT_CHOICE_ENVELOPE, "decision_id": decision_id if not decision_id.is_empty() else str(decision.get("decision_id", "")), "option_id": option_id if not option_id.is_empty() else str(projected.get("id", "")), "choice": selected}}, roller)

func _initialize() -> void:
	var profile := Profiles.profile("reiver-squad")
	check(profile.source_book_id == "000000139" and profile.source_datasheet_id == "000002718" and profile.source_export_updated_at == "2026-10-16T21:03:46+03:00", "Reiver Squad is linked to the extracted shared-book datasheet")
	check(profile.points_by_models == {5: 85, 10: 165} and profile.stats == {"movement_inches": 8, "toughness": 4, "save_target": 3, "wounds": 2, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 0}, "5/10 source costs and Reiver characteristics match the local export")
	check(profile.ranged.size() == 2 and profile.ranged[0].profiles.standard.name == "Bolt Carbine" and profile.ranged[0].profiles.standard.keywords == {"precision": true, "assault": true} and profile.ranged[1].profiles.standard.name == "Special-issue Bolt Pistol" and profile.melee[0].profiles.standard.name == "Monomolecular Combat Knife" and profile.melee[0].profiles.standard.keywords == {"precision": true}, "All fixed Reiver weapon profiles and traits match the local export")
	var five := Army.admit({"schema_version": 2, "faction": "Space Marines", "category": "incursion", "points_limit": 1000, "entries": [{"definition_id": "40kdc:11e:adeptus-astartes:reiver-squad", "models": 5, "copies": 1}]})
	var ten := Army.admit({"schema_version": 2, "faction": "Space Marines", "category": "incursion", "points_limit": 1000, "entries": [{"definition_id": "40kdc:11e:adeptus-astartes:reiver-squad", "models": 10, "copies": 1}]})
	check(five.error.is_empty() and five.total == 85 and ten.error.is_empty() and ten.total == 165, "Both source Reiver formations use the extracted prices")
	var state := make_state()
	check(not state.has("error"), "Reiver Squad and its Phobos/Necron test units materialize")
	if state.has("error"):
		print("Reiver Squad checks: %d failures" % (failures + 1))
		quit(1)
		return
	var found := find(state)
	check(found.reiver >= 0 and found.enemy >= 0 and found.lieutenant >= 0 and found.enemy_models.size() == 10, "Reiver, linked Leader and complete target unit materialize")
	check(C.UnitAbilities.every_model_has(state, found.reiver, "scouts-6") and C.UnitAbilities.scout_distance(state, found.reiver) == 6, "Every Reiver model provides Scouts 6")
	check(not C.UnitAbilities.every_model_has(state, found.reiver, "deep-strike"), "Reivers do not gain Deep Strike without Grav-chutes")
	check(C.UnitActions.attachment_allowed(state, found.lieutenant, found.reiver), "Phobos Lieutenant Leader/Support link is admitted for Reivers")
	state.phase = "deployment"
	state.unit_abilities.setup_players = []
	var grav := option(state, 1, "reiver-grav-chutes", found.reiver, "on")
	var grapnel := option(state, 1, "reiver-grapnel-launchers", found.reiver, "on")
	check(not grav.is_empty() and not grapnel.is_empty(), "Both source-listed unit-level equipment choices appear during setup")
	var prep_decision := C.UnitActions.pending_decision(state)
	var before_reiver_loadout := var_to_bytes(state)
	var wrong_owner_loadout := submit_normalized_choice(state, 2, grav)
	var stale_loadout := submit_normalized_choice(state, 1, grav, Callable(), str(prep_decision.get("decision_id", "")), "stale-option")
	check(not wrong_owner_loadout.get("error", "").is_empty() and not stale_loadout.get("error", "").is_empty() and before_reiver_loadout == var_to_bytes(state), "Wrong-owner and stale Reiver loadout choices are rejected unchanged")
	if not grav.is_empty(): check(submit_normalized_choice(state, 1, grav).get("error", "").is_empty() and C.UnitAbilities.every_model_has(state, found.reiver, "deep-strike"), "Equipped Grav-chutes grant Deep Strike to the unit through the public command")
	if not grapnel.is_empty(): check(submit_normalized_choice(state, 1, grapnel).get("error", "").is_empty() and C.UnitAbilities.every_model_has(state, found.reiver, "grapnel-launchers"), "Grapnel Launchers are active on the equipped unit through the public command")
	var reserve := option(state, 1, "reserve", found.reiver)
	check(not reserve.is_empty(), "Reiver Squad is eligible for Strategic Reserves through Scouts and its selected Deep Strike option")
	var movement := make_state()
	var moved := find(movement)
	var model: int = int(moved.reiver_model)
	var enemy_model: int = moved.enemy_models[0]
	movement.units[model].position = Vector2(-10, 8)
	movement.units[enemy_model].position = Vector2(0, 8)
	check(not Contact.clear_path(movement, model, Vector2(10, 8), 21.0), "Unequipped Reivers cannot move through an enemy model")
	movement.squads[moved.reiver].reiver_grapnel_launchers = true
	check(Contact.clear_path(movement, model, Vector2(10, 8), 21.0), "Grapnel Launchers permit a move path through models while preserving the endpoint")
	var aura := make_state()
	var aura_units := find(aura)
	var reiver_model: int = aura_units.reiver_model
	var near_model: int = aura_units.enemy_models[0]
	var far_model: int = aura_units.enemy_models[9]
	aura.units[reiver_model].position = Vector2(-2, 8)
	aura.units[near_model].position = Vector2(1.5, 8)
	aura.units[far_model].position = Vector2(8, 8)
	check(Contact.edge(aura.units[reiver_model], aura.units[near_model]) <= 3.0 and Contact.edge(aura.units[reiver_model], aura.units[far_model]) > 3.0, "Aura fixture checks model-to-model range on either side of the 3-inch threshold")
	var enemy_oc: int = int(aura.squads[aura_units.enemy].stats.objective_control)
	check(Morale.objective_control(aura, near_model) == maxi(0, enemy_oc - 1) and Morale.objective_control(aura, far_model) == enemy_oc, "Terror Troops reduces only enemy models within 3 inches by 1 OC")
	var fight := make_state()
	var fight_units := find(fight)
	for unit: int in C.living(fight, fight_units.reiver): fight.units[unit].position = Vector2(-2, (unit % 5 - 2) * 0.5)
	for unit: int in C.living(fight, fight_units.enemy): fight.units[unit].position = Vector2(1.0, (unit % 5 - 2) * 0.5)
	fight.phase = "charge"
	fight.active = 1
	var transition := C.advance_phase(fight, 1, fight.revision, func() -> int: return 1)
	check(transition.is_empty() and fight.phase == "fight" and fight.has("fearsome_assault") and C.UnitActions.actor(fight) == 1, "Fearsome Assault opens as a mandatory Fight-phase-start window before the Fight sequence")
	var fearsome_frame := C.ResolutionFrames.current(fight)
	var fearsome_decision := C.UnitActions.pending_decision(fight)
	check(fearsome_frame.get("kind", "") == "phase-start" and fearsome_frame.get("status", "") == "suspended" and fearsome_decision.get("resume_frame_id", "") == fearsome_frame.get("frame_id", ""), "Fearsome Assault decision carries a persisted Fight-phase-start continuation")
	var fearsome_restore: Dictionary = bytes_to_var(var_to_bytes(fight))
	check(C.ResolutionFrames.current(fearsome_restore) == fearsome_frame and C.UnitActions.pending_decision(fearsome_restore).get("resume_frame_id", "") == fearsome_frame.get("frame_id", ""), "Fearsome Assault continuation survives state serialization")
	var blocked_close := C.advance_phase(fight, 1, fight.revision)
	check(not blocked_close.is_empty() and fight.phase == "fight" and C.ResolutionFrames.current(fight) == fearsome_frame, "Fight phase cannot close while Fearsome Assault is unresolved")
	var test_choice := option(fight, 1, "fearsome-assault", fight_units.enemy, "roll")
	check(not test_choice.is_empty(), "Every enemy unit engaged with Reivers must take its Battle-shock test")
	if not test_choice.is_empty():
		var normalized_test := submit_normalized_choice(fight, 1, test_choice, func() -> int: return 1)
		check(str(normalized_test.get("error", "")).is_empty() and fight.squads[fight_units.enemy].battle_shocked and not fight.has("fearsome_assault") and C.ResolutionFrames.current(fight).is_empty(), "Normalized Fearsome Assault applies its -1 roll modifier, Battle-shocks a failed target and completes its continuation: " + str(normalized_test.get("error", "")))
		check(fight.last_fearsome_assault.size() == 1 and fight.last_fearsome_assault[0].modifier == -1 and fight.last_fearsome_assault[0].modified_total == 1, "The modified dice total is preserved in the resolution audit")
	var persists := make_state()
	var persist_units := find(persists)
	for unit: int in C.living(persists, persist_units.reiver): persists.units[unit].position = Vector2(-2, (unit % 5 - 2) * 0.5)
	for unit: int in C.living(persists, persist_units.enemy): persists.units[unit].position = Vector2(1.0, (unit % 5 - 2) * 0.5)
	persists.squads[persist_units.enemy].battle_shocked = true
	persists.phase = "charge"
	var start := C.advance_phase(persists, 1, persists.revision, func() -> int: return 6)
	var pass_choice := option(persists, 1, "fearsome-assault", persist_units.enemy, "roll")
	var normalized_persist_choice := submit_normalized_choice(persists, 1, pass_choice, func() -> int: return 6)
	check(start.is_empty() and not pass_choice.is_empty() and str(normalized_persist_choice.get("error", "")).is_empty() and persists.squads[persist_units.enemy].battle_shocked, "Normalized Fearsome Assault preserves a Battle-shock condition already in effect: " + str(normalized_persist_choice.get("error", "")))
	var tempered_armies := {
		1: {"schema_version": 2, "faction": "Space Marines", "category": "training", "points_limit": 500, "entries": [{"definition_id": "40kdc:11e:adeptus-astartes:reiver-squad", "models": 5, "copies": 1}]},
		2: {"schema_version": 2, "faction": "Space Marines", "category": "training", "points_limit": 500, "entries": [{"definition_id": "40kdc:11e:adeptus-astartes:captain-on-bike", "models": 1, "copies": 1, "enhancement_id": "000010155003"}]}}
	var tempered_fearsome := F.P.initial_state({"unit_abilities": true, "combat_doctrines": true, "marine_detachment": "wrath-of-the-rock", "core_stratagems": true, "manual_allocation": false}, tempered_armies)
	var tempered_units := find(tempered_fearsome)
	check(tempered_units.marine_enemy > 0 and tempered_units.tempered_bearer >= 0, "Fearsome Assault fixture has an Astartes target carrying the aura")
	if tempered_units.marine_enemy > 0 and tempered_units.tempered_bearer >= 0:
		tempered_fearsome.units[tempered_units.tempered_bearer].enhancement_id = "000010155002"
		tempered_fearsome.squads[tempered_fearsome.units[tempered_units.tempered_bearer].squad].enhancement_id = "000010155002"
		for reiver: int in C.living(tempered_fearsome, tempered_units.reiver): tempered_fearsome.units[reiver].position = Vector2(-2, (reiver % 5 - 2) * 0.5)
		for target_model: int in C.living(tempered_fearsome, tempered_units.marine_enemy): tempered_fearsome.units[target_model].position = Vector2(1, (target_model % 5 - 2) * 0.5)
		for necron: int in C.living(tempered_fearsome, tempered_units.enemy): tempered_fearsome.units[necron].position = Vector2(15, 10 + (necron % 5) * 0.5)
		tempered_fearsome.phase = "charge"
		var start_tempered := C.advance_phase(tempered_fearsome, 1, tempered_fearsome.revision, func() -> int: return 6)
		var roll_tempered := option(tempered_fearsome, 1, "fearsome-assault", tempered_units.marine_enemy, "roll")
		var normalized_tempered_roll := submit_normalized_choice(tempered_fearsome, 1, roll_tempered, func() -> int: return 2)
		var current_result_error := str(normalized_tempered_roll.get("error", "No Fearsome Assault roll option was offered."))
		var pending_result: Dictionary = tempered_fearsome.get("fearsome_assault", {}).get("current_result", {})
		check(start_tempered.is_empty() and current_result_error.is_empty(), "Fearsome Assault begins and rolls with the aura fixture: " + start_tempered + " " + current_result_error)
		check(not pending_result.is_empty() and pending_result.get("rolls", []) == [2, 2] and not tempered_fearsome.squads[tempered_units.marine_enemy].battle_shocked and C.UnitActions.actor(tempered_fearsome) == 2, "The result waits unapplied for the target unit's controller to decide")
		var temper_decision := C.UnitActions.pending_decision(tempered_fearsome)
		var keep_choice := option(tempered_fearsome, 2, "fearsome-assault", tempered_units.marine_enemy, "keep")
		var reroll_choice := option(tempered_fearsome, 2, "fearsome-assault", tempered_units.marine_enemy, "tempered-in-battle")
		check(temper_decision.get("priority_player_id", -1) == 2 and not keep_choice.is_empty() and not reroll_choice.is_empty(), "The normalized Leadership decision offers keep and the aura reroll to the tested unit's owner")
		var tempered_restore: Dictionary = bytes_to_var(var_to_bytes(tempered_fearsome))
		check(C.UnitActions.pending_decision(tempered_restore).get("decision_id", "") == temper_decision.get("decision_id", "") and C.ResolutionFrames.current(tempered_restore).get("status", "") == "suspended", "The reroll decision and Fight-start frame survive serialization")
		var blocked := C.advance_phase(tempered_restore, 1, tempered_restore.revision)
		check(not blocked.is_empty() and not tempered_restore.squads[tempered_units.marine_enemy].battle_shocked, "Fight phase close remains blocked until the Leadership result is decided")
		var normalized_reroll := submit_normalized_choice(tempered_restore, 2, reroll_choice, func() -> int: return 6)
		var reroll_error := str(normalized_reroll.get("error", ""))
		check(reroll_error.is_empty(), "The tested unit's controller can reroll both dice with Tempered in Battle: " + reroll_error)
		check(tempered_restore.squads[tempered_units.marine_enemy].battle_shocked == false and tempered_restore.get("last_fearsome_assault", [{}])[0].get("rerolled_from", []) == [2, 2] and tempered_restore.last_fearsome_assault[0].get("rolls", []) == [6, 6] and C.ResolutionFrames.current(tempered_restore).is_empty(), "A passing reroll is recorded and completes the Fearsome Assault continuation")
	print("Reiver Squad checks: %d failures" % failures)
	quit(1 if failures else 0)
