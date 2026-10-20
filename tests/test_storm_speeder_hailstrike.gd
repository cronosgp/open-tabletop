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
	var profile := Profiles.profile("storm-speeder-hailstrike")
	check(profile.get("source_book_id") == "000000139" and profile.get("source_datasheet_id") == "000000124" and profile.get("source_export_updated_at") == "2026-10-16T21:03:46+03:00", "Hailstrike cites its pinned Wahapedia e11 source row")
	check(profile.get("points_by_models", {}) == {1: 110} and profile.get("third_plus_points_by_models", {}) == {1: 120} and profile.get("max_supported_copies") == 3 and is_equal_approx(profile.get("base_radius_inches", 0.0), 45.0 / 25.4), "One-model size, 90 mm base and tiered costs match source")
	check(profile.stats == {"movement_inches": 14, "toughness": 9, "save_target": 3, "wounds": 11, "leadership_target": 6, "objective_control": 3, "invulnerable_target": 0} and profile.keywords.has("RAVENWING") and profile.keywords.has("FLY"), "Characteristics and datasheet keywords match local extraction")
	check(profile.ranged.map(func(w: Dictionary) -> String: return w.id) == ["fragstorm-grenade-launchers", "ironhail-heavy-stubber-array", "onslaught-gatling-cannon"] and profile.melee[0].id == "armoured-impact", "All fixed weapon profiles and traits are represented")
	check(profile.ranged[0].profiles.standard.keywords == {"blast": 2, "ignores-cover": true} and profile.ranged[1].profiles.standard.keywords == {"rapid-fire": 6, "ignores-cover": true}, "Grenade launcher and Ironhail traits match the source")
	check(profile.ranged[2].profiles.standard.keywords.get("ignores-cover", false) and profile.ranged[2].profiles.standard.target_restricted_traits == {"devastating-wounds": ["MONSTER", "VEHICLE"]}, "Onslaught Cannon keeps Ignores Cover and target-restricted Devastating Wounds")
	check(Catalog.SPECS.has("storm-speeder-hailstrike") and Roster.POINTS["storm-speeder-hailstrike"].sizes == {1: 110} and Roster.POINTS["storm-speeder-hailstrike"].third_plus_sizes == {1: 120}, "Local construction catalog publishes Hailstrike's point tiers")
	var three := Catalog.admit({"schema_version": 2, "faction": "Space Marines", "category": "custom", "points_limit": 10000, "entries": [{"definition_id": "40kdc:11e:adeptus-astartes:storm-speeder-hailstrike", "models": 1, "copies": 3}]})
	check(three.get("error", "").is_empty() and three.get("total", -1) == 340, "Three Hailstrikes use 110/110/120 source prices")

	var lists := F.selections()
	lists[1].entries.append({"definition_id": "40kdc:11e:adeptus-astartes:storm-speeder-hailstrike", "models": 1, "copies": 1})
	var state := F.P.initial_state({"checked_rosters": true, "official_mission": true, "unit_abilities": true, "combat_doctrines": true, "reanimation_protocols": true, "awakened_dynasty": true, "core_stratagems": true, "manual_allocation": false}, lists)
	check(not state.has("error"), "Hailstrike passes local roster admission and materializes")
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
	state.terrain.areas = [{"name": "Cover probe", "category": "exposed", "bounds": Rect2(5, -2, 4, 4), "features": []}]
	state.stratagems.attack_rerolls = false
	state.stratagems.hazard_rerolls = false
	var hailstrike := squad(state, "storm-speeder-hailstrike")
	var target := squad(state, "necron-warriors")
	var other := squad(state, "immortals")
	var intercessors := squad(state, "intercessor-squad")
	for model: int in state.units:
		state.units[model].position = Vector2(-20, -15) if state.units[model].owner == 1 else Vector2(20, 15)
	for friendly: int in [hailstrike, intercessors]:
		for model: int in C.living(state, friendly): state.units[model].position = Vector2.ZERO
	for enemy: int in [target, other]:
		for model: int in C.living(state, enemy): state.units[model].position = Vector2(7, 0)
	var model := hailstrike * 100
	check(C.UnitAbilities.has(state, hailstrike, "hailstrike") and C.UnitAbilities.has(state, hailstrike, "deep-strike") and C.UnitAbilities.has(state, hailstrike, "damaged-4") and C.UnitAbilities.has(state, hailstrike, "deadly-demise-d3"), "Hailstrike and shared vehicle abilities are admitted")
	var cannon: Dictionary = state.units[model].ranged_weapons[2].profiles.standard
	check(C.UnitAbilities.weapon(state, model, target, cannon, false).keywords.get("devastating-wounds", false), "Onslaught Cannon retains Devastating Wounds against an ordinary target")
	for enemy_model: int in C.living(state, target): state.units[enemy_model].keywords.append("VEHICLE")
	var vehicle_cannon := C.UnitAbilities.weapon(state, model, target, cannon, false)
	check(not vehicle_cannon.keywords.get("devastating-wounds", false) and vehicle_cannon.keywords.get("ignores-cover", false), "Onslaught Cannon drops its restricted trait against Vehicles but keeps Ignores Cover")
	for enemy_model: int in C.living(state, target): state.units[enemy_model].keywords.erase("VEHICLE")
	var plan := C.AttackPlan.prepare(state, hailstrike, false, entries(state, hailstrike, target, "fragstorm-grenade-launchers"), true)
	check(plan.error.is_empty() and plan.get("hailstrike", false) and plan.batches[0].context.benefit_of_cover == false, "Attack plan preserves the launcher's inherent Ignores Cover and Hailstrike follow-up")
	var hit_filter := state.duplicate(true)
	C.UnitAbilities.offer_cover_target(hit_filter, hailstrike, {"hailstrike": true}, {"pools": [{"target_squad": target, "hits": 1}, {"target_squad": other, "hits": 0}]}, false)
	check(hit_filter.unit_abilities.window.get("kind", "") == "hailstrike" and hit_filter.unit_abilities.window.targets == [target], "Only a living enemy unit hit by Hailstrike is offered for marking")
	var shot := C.resolve_attack_plan(state, 1, model, entries(state, hailstrike, target, "fragstorm-grenade-launchers"), state.revision, false, true, func() -> int: return 6)
	check(shot.error.is_empty() and state.unit_abilities.window.get("kind", "") == "hailstrike" and state.unit_abilities.window.targets == [target], "After its hit, Hailstrike offers the struck enemy as its mark")
	var choices := C.unit_choices(state, 1)
	check(choices.size() == 1 and choices[0].label.begins_with("Hailstrike:") and choices[0].target == target, "Decision prompt names Hailstrike and only offers hit enemy units")
	if not choices.is_empty(): check(C.unit_action(state, 1, choices[0], Vector2.ZERO, state.revision).is_empty(), "Player marks the enemy hit by the Hailstrike")
	var marine_gun: Dictionary = Profiles.profile("intercessor-squad").ranged[0].profiles.saturation
	var marine_attack := C.UnitAbilities.weapon(state, intercessors * 100, target, marine_gun, false)
	check(marine_attack.keywords.get("ignores-cover", false), "Friendly Adeptus Astartes ranged attacks ignore cover against the marked target")
	var baseline := state.duplicate(true)
	baseline.unit_abilities.cover_marks = {}
	var marked_plan := C.AttackPlan.prepare(state, intercessors, false, entries(state, intercessors, target, "bolt-rifle", "saturation"), true)
	var baseline_plan := C.AttackPlan.prepare(baseline, intercessors, false, entries(baseline, intercessors, target, "bolt-rifle", "saturation"), true)
	check(marked_plan.error.is_empty() and baseline_plan.error.is_empty() and marked_plan.batches[0].context.benefit_of_cover == false and baseline_plan.batches[0].context.benefit_of_cover, "Marked Hailstrike target loses cover benefit against subsequent Marine shooting")
	check(not C.UnitAbilities.weapon(state, intercessors * 100, other, marine_gun, false).keywords.get("ignores-cover", false), "Unmarked enemy units do not receive the benefit")
	check(not C.UnitAbilities.weapon(state, target * 100, target, marine_gun, false).keywords.get("ignores-cover", false), "Enemy units cannot use the friendly Hailstrike mark")
	check(not C.UnitAbilities.weapon(state, intercessors * 100, target, Profiles.profile("intercessor-squad").melee[0].profiles.standard, true).keywords.get("ignores-cover", false), "Hailstrike mark does not modify melee attacks")
	state.phase = "charge"
	check(not C.UnitAbilities.ignores_cover_mark(state, intercessors, target), "Hailstrike mark expires after the Shooting phase")
	print("Current Storm Speeder Hailstrike checks: %d failures" % failures)
	quit(1 if failures else 0)
