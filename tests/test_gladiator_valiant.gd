extends SceneTree
const F = preload("res://tests/all_units_fixture.gd")
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Catalog = preload("res://scripts/edition_11/army_capabilities.gd")
const Roster = preload("res://scripts/edition_11/roster_validation.gd")
const Geometry = preload("res://scripts/edition_11/contact_movement.gd")
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
	var profile := Profiles.profile("gladiator-valiant")
	check(profile.get("source_book_id") == "000000139" and profile.get("source_datasheet_id") == "000001825" and profile.get("source_export_updated_at") == "2026-10-16T21:03:46+03:00", "Gladiator Valiant cites its pinned local Wahapedia e11 row")
	check(profile.get("points_by_models", {}) == {1: 165} and profile.get("third_plus_points_by_models", {}) == {1: 185} and profile.get("max_supported_copies") == 3 and is_equal_approx(profile.get("base_radius_inches", 0.0), 50.0 / 25.4), "Source one-model size, 100 mm base and tiered costs are represented")
	check(profile.stats == {"movement_inches": 10, "toughness": 10, "save_target": 3, "wounds": 12, "leadership_target": 6, "objective_control": 3, "invulnerable_target": 0} and profile.keywords.has("VEHICLE") and profile.keywords.has("SMOKE"), "Characteristics and non-faction keywords match the local rows")
	check(profile.ranged.map(func(w: Dictionary) -> String: return w.id) == ["defensive-array", "multi-melta-left", "multi-melta-right", "twin-las-talon"] and profile.melee[0].id == "armoured-hull", "The two physical Multi-meltas are represented as separate selectable weapons")
	check(profile.ranged[0].profiles.standard.keywords == {"rapid-fire": 6} and profile.ranged[1].profiles.standard.keywords == {"melta": 3} and profile.ranged[2].profiles.standard.keywords == {"melta": 3} and profile.ranged[3].profiles.standard.keywords == {"twin-linked": true}, "Rapid Fire, both Melta profiles and Twin-linked match the source")
	check(Catalog.SPECS.has("gladiator-valiant") and Roster.POINTS["gladiator-valiant"].sizes == {1: 165} and Roster.POINTS["gladiator-valiant"].third_plus_sizes == {1: 185}, "Valiant is admitted using local source point tiers")
	var three := Catalog.admit({"schema_version": 2, "faction": "Space Marines", "category": "custom", "points_limit": 10000, "entries": [{"definition_id": "40kdc:11e:adeptus-astartes:gladiator-valiant", "models": 1, "copies": 3}]})
	check(three.get("error", "").is_empty() and three.get("total", -1) == 515, "Three Gladiator Valiants use 165/165/185 source prices")

	var lists := F.selections()
	lists[1].entries.append({"definition_id": "40kdc:11e:adeptus-astartes:gladiator-valiant", "models": 1, "copies": 1})
	var state := F.P.initial_state({"checked_rosters": true, "official_mission": true, "unit_abilities": true, "combat_doctrines": true, "reanimation_protocols": true, "awakened_dynasty": true, "core_stratagems": true, "manual_allocation": false}, lists)
	check(not state.has("error"), "Valiant passes local roster admission and materializes")
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
	var valiant := squad(state, "gladiator-valiant")
	var close_target := squad(state, "necron-warriors")
	var far_target := squad(state, "immortals")
	for model: int in state.units: state.units[model].position = Vector2(-20, -15) if state.units[model].owner == 1 else Vector2(20, 15)
	for model: int in C.living(state, valiant): state.units[model].position = Vector2.ZERO
	for model: int in C.living(state, close_target): state.units[model].position = Vector2(10, 0)
	for model: int in C.living(state, far_target): state.units[model].position = Vector2(30, 0)
	var model := valiant * 100
	check(C.UnitAbilities.has(state, valiant, "priority-target-acquisition") and C.UnitAbilities.has(state, valiant, "damaged-4") and C.UnitAbilities.has(state, valiant, "deadly-demise-d3"), "Priority Target Acquisition and shared vehicle abilities materialize")
	check(state.units[model].ranged_weapons.map(func(w: Dictionary) -> String: return w.id) == ["defensive-array", "multi-melta-left", "multi-melta-right", "twin-las-talon"], "The model receives every default ranged weapon instance")
	for weapon_index in range(profile.ranged.size()):
		var source_weapon: Dictionary = profile.ranged[weapon_index].profiles.standard
		var close_weapon := C.UnitAbilities.weapon(state, model, close_target, source_weapon, false)
		var far_weapon := C.UnitAbilities.weapon(state, model, far_target, source_weapon, false)
		check(close_weapon.strength == source_weapon.strength + 1, "Priority Target Acquisition grants +1 Strength to each ranged profile within 12 inches")
		check(far_weapon.strength == source_weapon.strength, "The Valiant's Strength bonus stops beyond 12 inches")
		check(source_weapon.strength == profile.ranged[weapon_index].profiles.standard.strength, "Target-based Strength modification does not mutate the source profile")
	var far_model: int = C.living(state, far_target)[0]
	var base_edges := float(state.units[model].radius) + float(state.units[far_model].radius)
	for target_model: int in C.living(state, far_target): state.units[target_model].position = Vector2(12.0 + base_edges, 0)
	var boundary := C.UnitAbilities.weapon(state, model, far_target, profile.ranged[3].profiles.standard, false)
	check(is_equal_approx(Geometry.distance_to_target(state, state.units[model], far_target), 12.0) and boundary.strength == 11, "The bonus applies at the 12-inch base-edge boundary")
	for target_model: int in C.living(state, far_target): state.units[target_model].position = Vector2(12.02 + base_edges, 0)
	var beyond_boundary := C.UnitAbilities.weapon(state, model, far_target, profile.ranged[3].profiles.standard, false)
	check(beyond_boundary.strength == 10, "The bonus stops immediately beyond the 12-inch base-edge boundary")
	var melee_source: Dictionary = profile.melee[0].profiles.standard
	var melee_weapon := C.UnitAbilities.weapon(state, model, close_target, melee_source, true)
	check(melee_weapon.strength == melee_source.strength, "Priority Target Acquisition does not modify melee attacks")
	var close_plan := C.AttackPlan.prepare(state, valiant, false, entries(state, valiant, close_target, "twin-las-talon"), true)
	var far_plan := C.AttackPlan.prepare(state, valiant, false, entries(state, valiant, far_target, "twin-las-talon"), true)
	check(close_plan.error.is_empty() and close_plan.batches[0].weapon.strength == 11, "Prepared ranged attacks carry the +1 Strength into combat resolution")
	check(far_plan.error.is_empty() and far_plan.batches[0].weapon.strength == 10, "Prepared attacks beyond 12 inches use the unmodified weapon Strength")
	print("Current Gladiator Valiant checks: %d failures" % failures)
	quit(1 if failures else 0)
