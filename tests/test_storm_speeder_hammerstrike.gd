extends SceneTree
const F = preload("res://tests/all_units_fixture.gd")
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Catalog = preload("res://scripts/edition_11/army_capabilities.gd")
const Roster = preload("res://scripts/edition_11/roster_validation.gd")
const Terrain = preload("res://scripts/edition_11/terrain.gd")
const Equipment = preload("res://scripts/edition_11/equipment.gd")
const C = F.C
const A = F.C.UnitAbilities
const WEAPONS := {
	"hammerstrike-missile-launcher": {"melee": false, "name": "Hammerstrike Missile Launcher", "range_inches": 36.0, "attacks": 2, "skill": 3, "strength": 10, "ap": -3, "damage": "D3+2", "keywords": {}},
	"krakstorm-grenade-launchers": {"melee": false, "name": "Krakstorm Grenade Launchers", "range_inches": 18.0, "attacks": 2, "skill": 3, "strength": 9, "ap": -1, "damage": 2, "keywords": {}},
	"melta-destroyer": {"melee": false, "name": "Melta Destroyer", "range_inches": 18.0, "attacks": 3, "skill": 3, "strength": 10, "ap": -3, "damage": "D3+2", "keywords": {"melta": 3}},
	"armoured-impact": {"melee": true, "name": "Armoured Impact", "range_inches": 0.0, "attacks": 3, "skill": 4, "strength": 6, "ap": 0, "damage": 1, "keywords": {}}
}
var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func find_squad(state: Dictionary, owner: int, identity: String) -> int:
	for model: int in state.units:
		if int(state.units[model].owner) == owner and A.identity(state.units[model]) == identity:
			return int(state.units[model].squad)
	return -1

func check_weapon_path(state: Dictionary, squad: int, model: int, target: int, weapon_id: String, expected: Dictionary) -> void:
	var melee: bool = expected.melee
	var actual: Dictionary = state.units[model].melee_weapons[0].profiles.standard if melee else state.units[model].ranged_weapons.filter(func(w: Dictionary) -> bool: return w.id == weapon_id)[0].profiles.standard
	var selected := Equipment.select(state, model, melee, weapon_id, "standard")
	var matches := true
	var selected_stats: Dictionary = selected.get("stats", {})
	for field: String in ["name", "range_inches", "attacks", "skill", "strength", "ap", "damage", "keywords"]:
		if actual.get(field) != expected.get(field) or selected_stats.get(field) != expected.get(field): matches = false
	if actual.get("target_restricted_traits", {}) != expected.get("target_restricted_traits", {}): matches = false
	check(matches, "%s matches every exported weapon field and trait" % weapon_id)
	check(str(selected.get("error", "")).is_empty(), "%s is selectable through Equipment" % weapon_id)
	var old_phase: String = state.phase
	var old_active: int = int(state.active)
	var old_positions := {}
	for member: int in C.living(state, squad) + C.living(state, target): old_positions[member] = state.units[member].position
	state.phase = "fight" if melee else "shooting"
	state.active = int(state.squads[squad].owner)
	var source_models: Array[int] = C.living(state, squad)
	var target_models: Array[int] = C.living(state, target)
	for member: int in source_models: state.units[member].position = Vector2.ZERO
	for index in range(target_models.size()): state.units[target_models[index]].position = Vector2(1, 0) if melee and index == 0 else Vector2(6, index * 3)
	var plan := F.C.AttackPlan.prepare(state, squad, melee, [{"model": model, "target": target, "amount": int(expected.attacks) if melee else 1, "weapon": weapon_id, "profile": "standard"}], true)
	check(str(plan.get("error", "")).is_empty() and plan.get("batches", []).size() == 1, "%s routes through AttackPlan" % weapon_id)
	state.phase = old_phase
	state.active = old_active
	for member: int in old_positions: state.units[member].position = old_positions[member]

func _initialize() -> void: call_deferred("run")

func run() -> void:
	var profile := Profiles.profile("storm-speeder-hammerstrike")
	check(profile.get("source_book_id") == "000000139" and profile.get("source_datasheet_id") == "000000114" and profile.get("source_export_updated_at") == "2026-10-16T21:03:46+03:00", "Hammerstrike cites the pinned Wahapedia e11 source row")
	check(profile.get("points_by_models", {}) == {1: 140} and profile.get("third_plus_points_by_models", {}) == {1: 150} and profile.get("max_supported_copies") == 3 and is_equal_approx(profile.get("base_radius_inches", 0.0), 45.0 / 25.4), "One-model size, 90 mm base and tiered costs match the source")
	check(profile.stats == {"movement_inches": 14, "toughness": 9, "save_target": 3, "wounds": 11, "leadership_target": 6, "objective_control": 3, "invulnerable_target": 0} and profile.keywords.has("FLY") and profile.keywords.has("RAVENWING"), "Characteristics and faction keywords match local extraction")
	var keywords: Array = profile.keywords.duplicate(); keywords.sort()
	var expected_keywords := ["ADEPTUS ASTARTES", "FLY", "FRAME", "IMPERIUM", "RAVENWING", "SPEEDER", "VEHICLE"]; expected_keywords.sort()
	check(profile.models == 1 and keywords == expected_keywords, "One-model composition and all exported keywords match the source")
	check(profile.ranged.map(func(w: Dictionary) -> String: return w.id) == ["hammerstrike-missile-launcher", "krakstorm-grenade-launchers", "melta-destroyer"] and profile.melee[0].id == "armoured-impact", "All four uniform default weapons are represented")
	check(Catalog.SPECS.has("storm-speeder-hammerstrike") and Roster.POINTS["storm-speeder-hammerstrike"].sizes == {1: 140} and Roster.POINTS["storm-speeder-hammerstrike"].third_plus_sizes == {1: 150}, "Local construction catalog uses Hammerstrike source prices")
	var three := Catalog.admit({"schema_version": 2, "faction": "Space Marines", "category": "custom", "points_limit": 10000, "entries": [{"definition_id": "40kdc:11e:adeptus-astartes:storm-speeder-hammerstrike", "models": 1, "copies": 3}]})
	var four := Catalog.admit({"schema_version": 2, "faction": "Space Marines", "category": "custom", "points_limit": 10000, "entries": [{"definition_id": "40kdc:11e:adeptus-astartes:storm-speeder-hammerstrike", "models": 1, "copies": 4}]})
	check(three.get("error", "").is_empty() and three.get("total", -1) == 430 and not four.get("error", "").is_empty(), "Three-copy cap and 140/140/150 source tiers are enforced")

	var lists := F.current_marine_selections()
	for owner in [1, 2]: lists[owner].entries.append({"definition_id": "40kdc:11e:adeptus-astartes:storm-speeder-hammerstrike", "models": 1, "copies": 1})
	var state := F.P.initial_state({"unit_abilities": true, "combat_doctrines": true, "reanimation_protocols": true, "awakened_dynasty": true, "core_stratagems": true, "manual_allocation": false}, lists)
	check(not state.has("error"), "Hammerstrike passes local roster admission and materializes")
	if state.has("error"):
		print(state)
		quit(1)
		return
	var model := -1
	var squad := -1
	for id: int in state.units:
		if state.units[id].owner == 1 and A.identity(state.units[id]) == "storm-speeder-hammerstrike":
			model = id
			squad = int(state.units[id].squad)
	var target := find_squad(state, 2, "intercessor-squad")
	check(find_squad(state, 2, "storm-speeder-hammerstrike") >= 0, "The enemy list also admits the current-catalog Hammerstrike")
	check(model >= 0 and A.has(state, squad, "hammerstrike") and A.has(state, squad, "damaged-4") and A.has(state, squad, "deadly-demise-d3") and A.has(state, squad, "deep-strike"), "Hammerstrike, Damaged 4, Deadly Demise D3 and Deep Strike are admitted")
	check(state.units[model].ranged_weapons.size() == 3 and state.units[model].melee_weapons[0].id == "armoured-impact", "Materialized loadout contains three ranged weapons and Armoured Impact")
	state.mission.stage = "battle"
	state.deployment.complete = true
	for weapon_id: String in WEAPONS: check_weapon_path(state, squad, model, target, weapon_id, WEAPONS[weapon_id])
	state.terrain = {"id": "terrain-11e-hammerstrike-test", "areas": [{"name": "Ruin", "category": "dense", "bounds": Rect2(0, 0, 2, 2), "features": []}]}
	for id: int in state.units:
		if state.units[id].squad == target: state.units[id].position = Vector2(2.5, 1.0)
	var missile: Dictionary = state.units[model].ranged_weapons[0].profiles.standard
	var melee: Dictionary = state.units[model].melee_weapons[0].profiles.standard
	var overlapping := A.weapon(state, model, target, missile, false)
	check(Terrain.within(state.units.values().filter(func(u: Dictionary) -> bool: return int(u.squad) == target)[0], Rect2(0, 0, 2, 2)) and overlapping.keywords.get("sustained-hits", 0) == 1, "A target base overlapping terrain gains Sustained Hits 1, even with its centre outside")
	state.unit_abilities.setup_players = [1, 2]
	state.unit_abilities.battle_players = [1, 2]
	state.unit_abilities.phase_key = C.UnitActions.key(state)
	state.phase = "shooting"
	state.active = 1
	state.units[model].position = Vector2(1, 1)
	var hammer_plan := C.AttackPlan.prepare(state, squad, false, [{"model": model, "target": target, "amount": 1, "weapon": "hammerstrike-missile-launcher", "profile": "standard"}], true)
	check(hammer_plan.error.is_empty() and hammer_plan.batches[0].weapon.keywords.get("sustained-hits", 0) == 1, "Hammerstrike applies its terrain bonus in the prepared ranged attack")
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
