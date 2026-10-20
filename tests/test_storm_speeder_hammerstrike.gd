extends SceneTree
const F = preload("res://tests/all_units_fixture.gd")
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Catalog = preload("res://scripts/edition_11/army_capabilities.gd")
const Roster = preload("res://scripts/edition_11/roster_validation.gd")
const Terrain = preload("res://scripts/edition_11/terrain.gd")
const A = F.C.UnitAbilities
var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func _initialize() -> void: call_deferred("run")

func run() -> void:
	var profile := Profiles.profile("storm-speeder-hammerstrike")
	check(profile.get("source_book_id") == "000000139" and profile.get("source_datasheet_id") == "000000114" and profile.get("source_export_updated_at") == "2026-10-16T21:03:46+03:00", "Hammerstrike cites the pinned Wahapedia e11 source row")
	check(profile.get("points_by_models", {}) == {1: 140} and profile.get("third_plus_points_by_models", {}) == {1: 150} and profile.get("max_supported_copies") == 3 and is_equal_approx(profile.get("base_radius_inches", 0.0), 45.0 / 25.4), "One-model size, 90 mm base and tiered costs match the source")
	check(profile.stats == {"movement_inches": 14, "toughness": 9, "save_target": 3, "wounds": 11, "leadership_target": 6, "objective_control": 3, "invulnerable_target": 0} and profile.keywords.has("FLY") and profile.keywords.has("RAVENWING"), "Characteristics and faction keywords match local extraction")
	check(profile.ranged.map(func(w: Dictionary) -> String: return w.id) == ["hammerstrike-missile-launcher", "krakstorm-grenade-launchers", "melta-destroyer"] and profile.melee[0].id == "armoured-impact", "All four uniform default weapons are represented")
	check(Catalog.SPECS.has("storm-speeder-hammerstrike") and Roster.POINTS["storm-speeder-hammerstrike"].sizes == {1: 140} and Roster.POINTS["storm-speeder-hammerstrike"].third_plus_sizes == {1: 150}, "Local construction catalog uses Hammerstrike source prices")
	var three := Catalog.admit({"schema_version": 2, "faction": "Space Marines", "category": "custom", "points_limit": 10000, "entries": [{"definition_id": "40kdc:11e:adeptus-astartes:storm-speeder-hammerstrike", "models": 1, "copies": 3}]})
	check(three.get("error", "").is_empty() and three.get("total", -1) == 430, "Three Hammerstrikes use 140/140/150 source prices")

	var lists := F.selections()
	lists[1].entries.append({"definition_id": "40kdc:11e:adeptus-astartes:storm-speeder-hammerstrike", "models": 1, "copies": 1})
	var state := F.P.initial_state({"checked_rosters": true, "official_mission": true, "unit_abilities": true, "combat_doctrines": true, "reanimation_protocols": true, "awakened_dynasty": true, "core_stratagems": true, "manual_allocation": false}, lists)
	check(not state.has("error"), "Hammerstrike passes local roster admission and materializes")
	if state.has("error"):
		print(state)
		quit(1)
		return
	var model := -1
	var squad := -1
	var target := -1
	for id: int in state.units:
		if state.units[id].owner == 1 and A.identity(state.units[id]) == "storm-speeder-hammerstrike":
			model = id
			squad = int(state.units[id].squad)
		if state.units[id].owner == 2:
			target = int(state.units[id].squad)
	check(model >= 0 and A.has(state, squad, "hammerstrike") and A.has(state, squad, "damaged-4") and A.has(state, squad, "deadly-demise-d3") and A.has(state, squad, "deep-strike"), "Hammerstrike, Damaged 4, Deadly Demise D3 and Deep Strike are admitted")
	check(state.units[model].ranged_weapons.size() == 3 and state.units[model].melee_weapons[0].id == "armoured-impact", "Materialized loadout contains three ranged weapons and Armoured Impact")
	state.terrain = {"id": "terrain-11e-hammerstrike-test", "areas": [{"name": "Ruin", "category": "dense", "bounds": Rect2(0, 0, 2, 2), "features": []}]}
	for id: int in state.units:
		if state.units[id].squad == target: state.units[id].position = Vector2(2.5, 1.0)
	var missile: Dictionary = state.units[model].ranged_weapons[0].profiles.standard
	var melee: Dictionary = state.units[model].melee_weapons[0].profiles.standard
	var overlapping := A.weapon(state, model, target, missile, false)
	check(Terrain.within(state.units.values().filter(func(u: Dictionary) -> bool: return int(u.squad) == target)[0], Rect2(0, 0, 2, 2)) and overlapping.keywords.get("sustained-hits", 0) == 1, "A target base overlapping terrain gains Sustained Hits 1, even with its centre outside")
	var launchers := A.weapon(state, model, target, state.units[model].ranged_weapons[1].profiles.standard, false)
	check(launchers.keywords.get("sustained-hits", 0) == 1, "The ability applies to every ranged profile")
	check(not A.weapon(state, model, target, melee, true).keywords.has("sustained-hits"), "Hammerstrike does not modify melee attacks")
	state.units[model].position = Vector2(1.0, 1.0)
	check(not A.weapon(state, model, squad, missile, false).keywords.has("sustained-hits"), "The ability only applies when targeting an enemy unit")
	for id: int in state.units:
		if state.units[id].squad == target: state.units[id].position = Vector2(3.5, 3.0)
	var outside := A.weapon(state, model, target, missile, false)
	check(not outside.keywords.has("sustained-hits"), "A target unit outside every terrain area receives no bonus")
	state.units[model].wounds = 4
	check(A.damaged_attack_penalty(state, model) == -1, "Damaged 4 applies with four wounds remaining")
	state.units[model].wounds = 5
	check(A.damaged_attack_penalty(state, model) == 0, "Damaged 4 does not apply above four wounds")
	print("Current Storm Speeder Hammerstrike checks: %d failures" % failures)
	quit(1 if failures else 0)
