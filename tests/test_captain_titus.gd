extends SceneTree
const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Catalog = preload("res://scripts/edition_11/army_capabilities.gd")
const Roster = preload("res://scripts/edition_11/roster_validation.gd")
const Geometry = preload("res://scripts/edition_11/contact_movement.gd")
const AttackPlan = preload("res://scripts/edition_11/attack_plan.gd")
const AttackSequence = preload("res://scripts/edition_11/attack_sequence.gd")
var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func entry(faction: String, identity: String, count: int) -> Dictionary:
	return {"definition_id": "40kdc:11e:%s:%s" % [faction, identity], "models": count, "copies": 1}

func find_squad(state: Dictionary, owner: int, identity: String) -> int:
	for squad: int in state.squads:
		if state.squads[squad].owner != owner: continue
		var members: Array[int] = Geometry.alive(state, squad)
		if not members.is_empty() and C.UnitAbilities.identity(state.units[members[0]]) == identity: return squad
	return -1

func find_model(state: Dictionary, owner: int, identity: String) -> int:
	for model: int in state.units:
		if state.units[model].owner == owner and C.UnitAbilities.identity(state.units[model]) == identity: return model
	return -1

func selected(state: Dictionary, player: int, action: String, model: int, target: int) -> Dictionary:
	for option: Dictionary in C.UnitActions.choices(state, player):
		if option.action == action and option.model == model and option.target == target: return option
	return {}

func _initialize() -> void: call_deferred("run")

func run() -> void:
	var profile := Profiles.profile("captain-titus")
	check(profile.source_book_id == "000000139" and profile.source_datasheet_id == "000004187" and profile.source_export_updated_at == "2026-10-16T21:03:46+03:00", "Titus is sourced from the local Wahapedia e11 export")
	check(profile.points_by_models == {1: 115} and profile.max_supported_copies == 1 and profile.base_size_source_mm == 40, "Titus source cost, unique Epic Hero composition and base match")
	check(profile.stats == {"movement_inches": 6, "toughness": 5, "save_target": 3, "wounds": 6, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 4}, "Titus characteristics match the export")
	check(profile.ranged[1].profiles.standard == {"name": "Master-crafted Bolter", "range_inches": 24.0, "attacks": 2, "skill": 2, "strength": 5, "ap": -1, "damage": 2, "keywords": {"assault": true, "rapid-fire": 1, "heavy": true}}, "Titus bolter retains its source profile")
	check(profile.melee[0].profiles.standard.keywords == {"anti-non-monster-vehicle": 2}, "Titus chainsword uses Anti 2+ against targets without Monster or Vehicle")
	check(Catalog.SPECS.get("captain-titus", {}).get("current_reference", false) and Roster.POINTS.get("captain-titus", {}).get("sizes", {}) == {1: 115}, "Titus is admitted at the extracted 115 points")

	var lists := F.selections()
	lists[1].entries = [entry("adeptus-astartes", "captain-titus", 1)]
	lists[2].entries = [entry("necrons", "necron-warriors", 10)]
	var state: Dictionary = F.P.initial_state({"unit_abilities": true, "combat_doctrines": true, "core_stratagems": true, "reanimation_protocols": true, "awakened_dynasty": true, "manual_allocation": false}, lists)
	check(not state.has("error"), "Captain Titus and an infantry target materialize")
	if state.has("error"):
		print(state.error)
		quit(1)
		return
	var model := find_model(state, 1, "captain-titus")
	var squad := find_squad(state, 1, "captain-titus")
	var target := find_squad(state, 2, "necron-warriors")
	var target_model := Geometry.alive(state, target)[0]
	check(C.UnitAbilities.has(state, squad, "press-the-attack") and C.UnitAbilities.has(state, squad, "righteous-fury") and C.UnitAbilities.has(state, squad, "honour-of-ultramar") and C.UnitAbilities.has(state, squad, "feel-no-pain-5"), "Titus datasheet and core abilities register")
	state.phase = "fight"
	state.fight_step = "attacks"
	state.fight_actor = 1
	state.active = 1
	state.squads[squad].charged = true
	state.units[model].position = Vector2.ZERO
	state.units[target_model].position = Vector2(1.5, 0)
	var fury := selected(state, 1, "righteous-fury", model, squad)
	check(not fury.is_empty(), "Righteous Fury is offered when Titus is selected to fight")
	var activated := C.UnitActions.apply(state, 1, fury, Vector2.ZERO, func() -> int: return 6)
	check(activated.error.is_empty() and state.unit_abilities.used.get("righteous-active:%d" % squad, false), "Righteous Fury activates once and selects Titus to fight")
	var chainsword: Dictionary = profile.melee[0].profiles.standard
	var press := C.UnitAbilities.weapon(state, model, target, chainsword, true)
	check(press.strength == 6 and press.keywords.get("sustained-hits", 0) == 1, "Righteous Fury adds Strength and Press the Attack grants Sustained Hits 1 against Infantry")
	var target_vehicle := state.duplicate(true)
	for enemy: int in Geometry.alive(target_vehicle, target):
		if "VEHICLE" not in target_vehicle.units[enemy].keywords: target_vehicle.units[enemy].keywords.append("VEHICLE")
	var vehicle_weapon := C.UnitAbilities.weapon(target_vehicle, model, target, chainsword, true)
	check(vehicle_weapon.keywords.get("anti-non-monster-vehicle", 0) == 2 and not vehicle_weapon.keywords.has("sustained-hits"), "Anti profile is retained but Press the Attack does not grant Sustained Hits against Vehicle targets")
	target_vehicle.combat_doctrines.active[1] = "assault"
	vehicle_weapon = C.UnitAbilities.weapon(target_vehicle, model, target, chainsword, true)
	check(vehicle_weapon.keywords.get("sustained-hits", 0) == 1, "Assault Doctrine grants Press the Attack Sustained Hits against Monster/Vehicle targets")

	state.units[model].wounds = 2
	var committed := C._commit_finished_attack(state, squad, 1, [], true, {"targets": [target]}, {"killed": 1, "damage": 0, "pools": []}, func() -> int: return 6)
	check(committed.error.is_empty() and state.units[model].wounds == 6 and state.unit_abilities.last_titus_heal.roll.expression == "2D3", "Righteous Fury heals 2D3 after Titus destroys an enemy model this phase")
	check(not state.unit_abilities.used.has("righteous-active:%d" % squad) and state.unit_abilities.used.has("righteous-used:1"), "Righteous Fury ends after Titus fights and remains used for the battle")
	var second_activation_state := state.duplicate(true)
	second_activation_state.squads[squad].fought = false
	second_activation_state.fight_step = "attacks"
	second_activation_state.fight_actor = 1
	second_activation_state.fight_selected = -1
	check(selected(second_activation_state, 1, "righteous-fury", model, squad).is_empty(), "Righteous Fury is not offered again during the same battle")
	var repeat_fury := C.UnitActions.apply(state, 1, fury, Vector2.ZERO, func() -> int: return 3)
	check(not repeat_fury.error.is_empty(), "Righteous Fury is limited to once per battle per army")
	var d3_heal_state := state.duplicate(true)
	d3_heal_state.squads[squad].fought = false
	d3_heal_state.fight_step = "attacks"
	d3_heal_state.fight_actor = 1
	d3_heal_state.units[model].wounds = 2
	d3_heal_state.unit_abilities.used["righteous-active:%d" % squad] = true
	var d3_heal := C._commit_finished_attack(d3_heal_state, squad, 1, [], true, {"targets": []}, {"killed": 0, "damage": 0, "pools": []}, func() -> int: return 6)
	check(d3_heal.error.is_empty() and d3_heal_state.units[model].wounds == 5 and d3_heal_state.unit_abilities.last_titus_heal.roll.expression == "D3", "Righteous Fury heals D3 when Titus destroyed no enemy model this phase")

	var anti_weapon: Dictionary = chainsword.duplicate(true)
	anti_weapon.attacks = 1
	var anti_target := {"toughness": 10, "save_target": 3, "invulnerable_target": 0, "wounds_per_model": 5, "remaining_wounds": [5], "prevention": [[]]}
	var anti_non_vehicle := AttackSequence.roll_pool(anti_weapon, anti_target, {"target_keywords": ["INFANTRY"], "defer_saves": true}, func() -> int: return 2)
	var anti_vehicle := AttackSequence.roll_pool(anti_weapon, anti_target, {"target_keywords": ["VEHICLE"], "defer_saves": true}, func() -> int: return 2)
	check(anti_non_vehicle.error.is_empty() and anti_non_vehicle.critical_wounds == 1, "Anti-non-Monster/Vehicle 2+ produces a critical wound against Infantry")
	check(anti_vehicle.error.is_empty() and anti_vehicle.wounds == 0, "Anti-non-Monster/Vehicle does not apply against Vehicle targets")

	var honour_state := state.duplicate(true)
	honour_state.phase = "fight"
	honour_state.squads[squad].fought = false
	honour_state.units[model].wounds = 0
	var honour := C.DetachmentStratagems.hold_destroyed(honour_state, model, func() -> int: return 2)
	check(honour.error.is_empty() and honour.held and honour.roll == 2 and honour_state.units[model].wounds == 1, "Honour of Ultramar keeps Titus on a 2+ before he has fought")
	C.DetachmentStratagems.remove_lingering(honour_state, target)
	check(honour_state.units[model].wounds == 1, "A different unit fighting does not remove Titus before his unit fights")
	C.DetachmentStratagems.remove_lingering(honour_state, squad)
	check(honour_state.units[model].wounds == 0 and not honour_state.units[model].get("titus_honour_lingering", false), "Titus is removed after his unit fights")
	var phase_end_state := state.duplicate(true)
	phase_end_state.phase = "fight"
	phase_end_state.squads[squad].fought = false
	phase_end_state.units[model].wounds = 0
	var phase_end_save := C.DetachmentStratagems.hold_destroyed(phase_end_state, model, func() -> int: return 2)
	C.DetachmentStratagems.remove_lingering(phase_end_state)
	check(phase_end_save.held and phase_end_state.units[model].wounds == 0, "A retained Titus is removed when the Fight phase ends")
	var failed_honour := state.duplicate(true)
	failed_honour.phase = "fight"
	failed_honour.squads[squad].fought = false
	failed_honour.units[model].wounds = 0
	var failed_roll := C.DetachmentStratagems.hold_destroyed(failed_honour, model, func() -> int: return 1)
	check(failed_roll.error.is_empty() and not failed_roll.held and failed_honour.units[model].wounds == 0, "Honour of Ultramar fails on an unmodified 1")

	print("Captain Titus local checks: %d failures" % failures)
	quit(1 if failures else 0)
