extends SceneTree
const F = preload("res://tests/all_units_fixture.gd")
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Catalog = preload("res://scripts/edition_11/army_capabilities.gd")
const Roster = preload("res://scripts/edition_11/roster_validation.gd")
const C = F.C
var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func squad(state: Dictionary, name: String) -> int:
	for model: int in state.units:
		if C.UnitAbilities.identity(state.units[model]) == name: return int(state.units[model].squad)
	return -1

func entries(state: Dictionary, source: int, target: int, weapon: String, profile: String = "standard") -> Array:
	var result: Array = []
	for model: int in C.living(state, source): result.append({"model": model, "target": target, "amount": 1, "weapon": weapon, "profile": profile})
	return result

func _initialize() -> void: call_deferred("run")

func run() -> void:
	var profile := Profiles.profile("storm-speeder-thunderstrike")
	check(profile.get("source_book_id") == "000000139" and profile.get("source_datasheet_id") == "000001610" and profile.get("source_export_updated_at") == "2026-10-16T21:03:46+03:00", "Thunderstrike cites its local Wahapedia e11 row")
	check(profile.get("points_by_models", {}) == {1: 140} and profile.get("third_plus_points_by_models", {}) == {1: 150} and profile.get("max_supported_copies") == 3 and is_equal_approx(profile.get("base_radius_inches", 0.0), 45.0 / 25.4), "One-model size, base and tiered costs match the source")
	check(profile.stats == {"movement_inches": 14, "toughness": 9, "save_target": 3, "wounds": 11, "leadership_target": 6, "objective_control": 3, "invulnerable_target": 0} and profile.keywords.has("VEHICLE") and profile.keywords.has("FLY"), "Characteristics and unit keywords match the extraction")
	check(profile.ranged.map(func(w: Dictionary) -> String: return w.id) == ["stormfury-missile-launcher", "thunderstrike-icarus-rocket-pod", "thunderstrike-las-talon"] and profile.melee[0].id == "armoured-impact", "Every fixed weapon is in the local profile")
	check(profile.ranged[1].profiles.standard.keywords == {"anti-fly": 2}, "Icarus rocket pod keeps Anti-Fly 2+")
	check(Catalog.SPECS.has("storm-speeder-thunderstrike") and Roster.POINTS["storm-speeder-thunderstrike"].sizes == {1: 140} and Roster.POINTS["storm-speeder-thunderstrike"].third_plus_sizes == {1: 150}, "Thunderstrike is admitted with source copy tiers")
	var three := Catalog.admit({"schema_version": 2, "faction": "Space Marines", "category": "custom", "points_limit": 10000, "entries": [{"definition_id": "40kdc:11e:adeptus-astartes:storm-speeder-thunderstrike", "models": 1, "copies": 3}]})
	check(three.get("error", "").is_empty() and three.get("total", -1) == 430, "Three Thunderstrikes use 140/140/150 source prices")

	var lists := F.selections()
	lists[1].entries.append({"definition_id": "40kdc:11e:adeptus-astartes:storm-speeder-thunderstrike", "models": 1, "copies": 1})
	var state := F.P.initial_state({"checked_rosters": true, "official_mission": true, "unit_abilities": true, "combat_doctrines": true, "reanimation_protocols": true, "awakened_dynasty": true, "core_stratagems": true, "manual_allocation": false}, lists)
	check(not state.has("error"), "Thunderstrike is materialized by local roster admission")
	if state.has("error"):
		print(state)
		quit(1)
		return
	state.awakened_dynasty.pending = []
	state.unit_abilities.setup_players = [1, 2]
	state.unit_abilities.battle_players = [1, 2]
	state.deployment.complete = true
	state.mission.stage = "battle"
	state.phase = "shooting"
	state.turn = 3
	state.round = 2
	state.active = 1
	state.unit_abilities.phase_key = C.UnitActions.key(state)
	state.unit_abilities.window = {}
	state.stratagems.attack_rerolls = false
	state.stratagems.hazard_rerolls = false
	var speeder := squad(state, "storm-speeder-thunderstrike")
	var monster_target := squad(state, "necron-warriors")
	var ordinary_target := squad(state, "immortals")
	var intercessors := squad(state, "intercessor-squad")
	for model: int in state.units: state.units[model].position = Vector2(-20, -15) if state.units[model].owner == 1 else Vector2(20, 15)
	for friendly: int in [speeder, intercessors]:
		for model: int in C.living(state, friendly): state.units[model].position = Vector2.ZERO
	for enemy: int in [monster_target, ordinary_target]:
		for model: int in C.living(state, enemy): state.units[model].position = Vector2(7, 0)
	for model: int in C.living(state, monster_target): state.units[model].keywords.append("VEHICLE")
	var model := speeder * 100
	check(C.UnitAbilities.has(state, speeder, "thunderstrike") and C.UnitAbilities.has(state, speeder, "shattered-defences") and C.UnitAbilities.has(state, speeder, "deep-strike") and C.UnitAbilities.has(state, speeder, "damaged-4") and C.UnitAbilities.has(state, speeder, "deadly-demise-d3"), "Thunderstrike and shared vehicle abilities are admitted")
	var vehicle_plan := C.AttackPlan.prepare(state, speeder, false, entries(state, speeder, monster_target, "stormfury-missile-launcher"), true)
	var ordinary_plan := C.AttackPlan.prepare(state, speeder, false, entries(state, speeder, ordinary_target, "stormfury-missile-launcher"), true)
	check(vehicle_plan.error.is_empty() and vehicle_plan.batches[0].context.get("wound_modifier", 0) == 1, "Thunderstrike grants +1 to wound against VEHICLE targets")
	check(ordinary_plan.error.is_empty() and ordinary_plan.batches[0].context.get("wound_modifier", 0) == 0, "Thunderstrike does not modify attacks against ordinary targets")
	var melee_state := state.duplicate(true)
	for enemy_model: int in C.living(melee_state, monster_target): melee_state.units[enemy_model].position = Vector2(0.8, 0)
	var melee_entries := entries(melee_state, speeder, monster_target, "armoured-impact")
	melee_entries[0].amount = 3
	var melee_plan := C.AttackPlan.prepare(melee_state, speeder, true, melee_entries, true)
	check(melee_plan.error.is_empty() and melee_plan.batches[0].context.get("wound_modifier", 0) == 0, "Thunderstrike does not modify melee attacks")
	var filter_state := state.duplicate(true)
	C.UnitAbilities.offer_cover_target(filter_state, speeder, {"shattered_defences": true}, {"pools": [{"target_squad": monster_target, "hits": 1}, {"target_squad": ordinary_target, "hits": 1}]}, false)
	check(filter_state.unit_abilities.window.get("kind", "") == "shattered-defences" and filter_state.unit_abilities.window.targets == [monster_target], "Shattered Defences only offers a hit MONSTER or VEHICLE")
	var shot := C.resolve_attack_plan(state, 1, model, entries(state, speeder, monster_target, "stormfury-missile-launcher"), state.revision, false, true, func() -> int: return 6)
	check(shot.error.is_empty() and state.unit_abilities.window.get("kind", "") == "shattered-defences" and state.unit_abilities.window.targets == [monster_target], "After shooting, Thunderstrike offers its hit Vehicle for marking")
	var choices := C.unit_choices(state, 1)
	check(choices.size() == 1 and choices[0].label.begins_with("Shattered Defences:") and choices[0].target == monster_target, "Shattered Defences prompt identifies the effect and valid target")
	if not choices.is_empty(): check(C.unit_action(state, 1, choices[0], Vector2.ZERO, state.revision).is_empty(), "Player marks the Vehicle hit by the Thunderstrike")
	var marine_gun: Dictionary = Profiles.profile("intercessor-squad").ranged[0].profiles.saturation
	var marked := C.UnitAbilities.weapon(state, intercessors * 100, monster_target, marine_gun, false)
	var unmarked := C.UnitAbilities.weapon(state, intercessors * 100, ordinary_target, marine_gun, false)
	var enemy_attack := C.UnitAbilities.weapon(state, monster_target * 100, monster_target, marine_gun, false)
	var melee := C.UnitAbilities.weapon(state, intercessors * 100, monster_target, Profiles.profile("intercessor-squad").melee[0].profiles.standard, true)
	check(marked.ap == marine_gun.ap - 1 and unmarked.ap == marine_gun.ap and enemy_attack.ap == marine_gun.ap and melee.ap == Profiles.profile("intercessor-squad").melee[0].profiles.standard.ap, "Only friendly Astartes ranged attacks against the mark gain +1 AP")
	state.phase = "charge"
	check(not C.UnitAbilities.shattered_defences_mark(state, intercessors, monster_target), "Shattered Defences mark expires after the Shooting phase")
	print("Current Storm Speeder Thunderstrike checks: %d failures" % failures)
	quit(1 if failures else 0)
