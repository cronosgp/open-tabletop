extends SceneTree
const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Army = preload("res://scripts/edition_11/army_capabilities.gd")
const Contact = preload("res://scripts/edition_11/contact_movement.gd")
const Morale = preload("res://scripts/edition_11/morale.gd")
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
	var result := {"reiver": -1, "reiver_model": -1, "lieutenant": -1, "enemy": -1, "enemy_models": []}
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
	return result

func option(state: Dictionary, player: int, action: String, target: int = -999, value: String = "") -> Dictionary:
	for item: Dictionary in C.unit_choices(state, player):
		if item.action == action and (target == -999 or item.target == target) and (value.is_empty() or item.value == value): return item
	return {}

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
	if not grav.is_empty(): check(C.unit_action(state, 1, grav, Vector2.ZERO, state.revision).is_empty() and C.UnitAbilities.every_model_has(state, found.reiver, "deep-strike"), "Equipped Grav-chutes grant Deep Strike to the unit")
	if not grapnel.is_empty(): check(C.unit_action(state, 1, grapnel, Vector2.ZERO, state.revision).is_empty() and C.UnitAbilities.every_model_has(state, found.reiver, "grapnel-launchers"), "Grapnel Launchers are active on the equipped unit")
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
	var test_choice := option(fight, 1, "fearsome-assault", fight_units.enemy, "roll")
	check(not test_choice.is_empty(), "Every enemy unit engaged with Reivers must take its Battle-shock test")
	if not test_choice.is_empty():
		var test_error := C.unit_action(fight, 1, test_choice, Vector2.ZERO, fight.revision, func() -> int: return 1)
		check(test_error.is_empty() and fight.squads[fight_units.enemy].battle_shocked and not fight.has("fearsome_assault"), "Fearsome Assault applies its -1 roll modifier and Battle-shocks a failed target")
		check(fight.last_fearsome_assault.size() == 1 and fight.last_fearsome_assault[0].modifier == -1 and fight.last_fearsome_assault[0].modified_total == 1, "The modified dice total is preserved in the resolution audit")
	var persists := make_state()
	var persist_units := find(persists)
	for unit: int in C.living(persists, persist_units.reiver): persists.units[unit].position = Vector2(-2, (unit % 5 - 2) * 0.5)
	for unit: int in C.living(persists, persist_units.enemy): persists.units[unit].position = Vector2(1.0, (unit % 5 - 2) * 0.5)
	persists.squads[persist_units.enemy].battle_shocked = true
	persists.phase = "charge"
	var start := C.advance_phase(persists, 1, persists.revision, func() -> int: return 6)
	var pass_choice := option(persists, 1, "fearsome-assault", persist_units.enemy, "roll")
	if not pass_choice.is_empty(): C.unit_action(persists, 1, pass_choice, Vector2.ZERO, persists.revision, func() -> int: return 6)
	check(start.is_empty() and not pass_choice.is_empty() and persists.squads[persist_units.enemy].battle_shocked, "Passing Fearsome Assault does not clear a Battle-shock condition already in effect")
	print("Reiver Squad checks: %d failures" % failures)
	quit(1 if failures else 0)
