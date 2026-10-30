extends SceneTree
const F = preload("res://tests/all_units_fixture.gd")
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Catalog = preload("res://scripts/edition_11/army_capabilities.gd")
const Roster = preload("res://scripts/edition_11/roster_validation.gd")
const Equipment = preload("res://scripts/edition_11/equipment.gd")
const A = F.C.UnitAbilities
const C = F.C
const WEAPONS := {
	"defensive-array": {"melee": false, "name": "Defensive Array", "range_inches": 24.0, "attacks": 12, "skill": 3, "strength": 5, "ap": -1, "damage": 1, "keywords": {"rapid-fire": 12}},
	"twin-heavy-onslaught-gatling-cannon": {"melee": false, "name": "Twin Heavy Onslaught Gatling Cannon", "range_inches": 24.0, "attacks": 12, "skill": 3, "strength": 6, "ap": -1, "damage": 1, "keywords": {"twin-linked": true, "sustained-hits": 2, "devastating-wounds": true}, "target_restricted_traits": {"sustained-hits": ["MONSTER", "VEHICLE"], "devastating-wounds": ["MONSTER", "VEHICLE"]}},
	"armoured-hull": {"melee": true, "name": "Armoured Hull", "range_inches": 0.0, "attacks": 3, "skill": 4, "strength": 6, "ap": 0, "damage": 1, "keywords": {}}
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
	var weapons: Array = state.units[model].melee_weapons if melee else state.units[model].ranged_weapons
	var actual: Dictionary = weapons.filter(func(w: Dictionary) -> bool: return w.id == weapon_id)[0].profiles.standard
	var selected := Equipment.select(state, model, melee, weapon_id, "standard")
	var matches := true
	for field: String in ["name", "range_inches", "attacks", "skill", "strength", "ap", "damage", "keywords"]:
		if actual.get(field) != expected.get(field) or selected.get("stats", {}).get(field) != expected.get(field): matches = false
	if actual.get("target_restricted_traits", {}) != expected.get("target_restricted_traits", {}): matches = false
	check(matches and str(selected.get("error", "")).is_empty(), "%s matches the export and is selectable through Equipment" % weapon_id)
	var old_phase: String = state.phase
	var old_active: int = int(state.active)
	var old_positions := {}
	for member: int in C.living(state, squad) + C.living(state, target): old_positions[member] = state.units[member].position
	state.phase = "fight" if melee else "shooting"
	state.active = int(state.squads[squad].owner)
	for member: int in C.living(state, squad): state.units[member].position = Vector2.ZERO
	var target_models: Array[int] = C.living(state, target)
	for index in range(target_models.size()): state.units[target_models[index]].position = Vector2(1, 0) if melee and index == 0 else Vector2(6, index * 3)
	var plan := C.AttackPlan.prepare(state, squad, melee, [{"model": model, "target": target, "amount": int(expected.attacks) if melee else 1, "weapon": weapon_id, "profile": "standard"}], true)
	check(str(plan.get("error", "")).is_empty() and plan.get("batches", []).size() == 1, "%s routes through AttackPlan" % weapon_id)
	state.phase = old_phase
	state.active = old_active
	for member: int in old_positions: state.units[member].position = old_positions[member]

func _initialize() -> void: call_deferred("run")

func run() -> void:
	var profile := Profiles.profile("gladiator-reaper")
	check(profile.get("source_book_id") == "000000139" and profile.get("source_datasheet_id") == "000001667" and profile.get("source_export_updated_at") == "2026-10-16T21:03:46+03:00", "Gladiator Reaper cites the pinned Wahapedia e11 export")
	check(profile.get("points_by_models", {}) == {1: 165} and profile.get("third_plus_points_by_models", {}) == {1: 185} and profile.get("max_supported_copies") == 3 and is_equal_approx(profile.get("base_radius_inches", 0.0), 50.0 / 25.4), "Source one-model size, first-two/third-plus prices and 100 mm base are recorded")
	check(profile.stats == {"movement_inches": 10, "toughness": 10, "save_target": 3, "wounds": 12, "leadership_target": 6, "objective_control": 3, "invulnerable_target": 0} and profile.keywords.has("FRAME") and profile.keywords.has("SMOKE"), "Model characteristics and datasheet keywords match local rows")
	var keywords: Array = profile.keywords.duplicate(); keywords.sort()
	var expected_keywords := ["ADEPTUS ASTARTES", "FRAME", "IMPERIUM", "SMOKE", "VEHICLE"]; expected_keywords.sort()
	check(profile.models == 1 and keywords == expected_keywords, "One-model composition and all exported keywords match the source")
	check(profile.ranged.size() == 2 and profile.ranged[0].id == "defensive-array" and profile.ranged[1].id == "twin-heavy-onslaught-gatling-cannon" and profile.melee[0].id == "armoured-hull", "Uniform default loadout matches the source with all three physical weapon profiles")
	check(Catalog.SPECS.has("gladiator-reaper") and Roster.POINTS["gladiator-reaper"].sizes == {1: 165} and Roster.POINTS["gladiator-reaper"].third_plus_sizes == {1: 185}, "The local construction catalog uses source copy-tier prices")
	var three := Catalog.admit({"schema_version": 2, "faction": "Space Marines", "category": "custom", "points_limit": 10000, "entries": [{"definition_id": "40kdc:11e:adeptus-astartes:gladiator-reaper", "models": 1, "copies": 3}]})
	var four := Catalog.admit({"schema_version": 2, "faction": "Space Marines", "category": "custom", "points_limit": 10000, "entries": [{"definition_id": "40kdc:11e:adeptus-astartes:gladiator-reaper", "models": 1, "copies": 4}]})
	check(three.get("error", "").is_empty() and three.get("total", -1) == 515 and not four.get("error", "").is_empty(), "Three-copy cap and 165/165/185 source tiers are enforced")

	var lists := F.current_marine_selections()
	for owner in [1, 2]: lists[owner].entries.append({"definition_id": "40kdc:11e:adeptus-astartes:gladiator-reaper", "models": 1, "copies": 1})
	var state := F.P.initial_state({"unit_abilities": true, "combat_doctrines": true, "reanimation_protocols": true, "awakened_dynasty": true, "core_stratagems": true, "manual_allocation": false}, lists)
	check(not state.has("error"), "Gladiator Reaper passes local roster admission and materializes")
	if state.has("error"):
		print(state)
		quit(1)
		return
	var model := -1
	var squad := -1
	for id: int in state.units:
		if state.units[id].owner == 1 and A.identity(state.units[id]) == "gladiator-reaper":
			model = id
			squad = int(state.units[id].squad)
			break
	var normal_target := find_squad(state, 2, "intercessor-squad")
	check(find_squad(state, 2, "gladiator-reaper") >= 0, "The enemy roster also admits the current-catalog Gladiator Reaper")
	check(model >= 0 and state.squads[squad].training_cost == 165 and A.has(state, squad, "reaping-tally") and A.has(state, squad, "damaged-4") and A.has(state, squad, "deadly-demise-d3"), "Reaper, Damaged 4 and Deadly Demise D3 abilities materialize")
	check(state.units[model].ranged_weapons.map(func(w: Dictionary) -> String: return w.id) == ["defensive-array", "twin-heavy-onslaught-gatling-cannon"] and state.units[model].melee_weapons[0].id == "armoured-hull", "All default source weapons are attached to the model")
	state.mission.stage = "battle"
	state.deployment.complete = true
	for weapon_id: String in WEAPONS: check_weapon_path(state, squad, model, normal_target, weapon_id, WEAPONS[weapon_id])
	var defensive: Dictionary = state.units[model].ranged_weapons[0].profiles.standard
	var tally_profile := A.weapon(state, model, normal_target, defensive, false)
	check(defensive.ap == -1 and tally_profile.ap == -2, "Reaping Tally improves AP by one against a non-Monster/non-Vehicle target without mutating the source weapon")
	var cannon: Dictionary = state.units[model].ranged_weapons[1].profiles.standard
	var ordinary_cannon := A.weapon(state, model, normal_target, cannon, false)
	check(ordinary_cannon.ap == -2 and ordinary_cannon.keywords.get("sustained-hits", 0) == 2 and ordinary_cannon.keywords.get("devastating-wounds", false), "Reaping Tally and the cannon's conditional traits apply against an eligible target")
	state.unit_abilities.setup_players = [1, 2]
	state.unit_abilities.battle_players = [1, 2]
	state.unit_abilities.phase_key = C.UnitActions.key(state)
	state.phase = "shooting"
	state.active = 1
	state.units[model].position = Vector2.ZERO
	for member: int in C.living(state, normal_target): state.units[member].position = Vector2(6, 0)
	var ordinary_plan := C.AttackPlan.prepare(state, squad, false, [{"model": model, "target": normal_target, "amount": 1, "weapon": "twin-heavy-onslaught-gatling-cannon", "profile": "standard"}], true)
	check(ordinary_plan.error.is_empty() and ordinary_plan.batches[0].weapon.ap == -2 and ordinary_plan.batches[0].weapon.keywords.get("sustained-hits", 0) == 2 and ordinary_plan.batches[0].weapon.keywords.get("devastating-wounds", false), "Reaping Tally and conditional cannon traits survive into the prepared attack")
	for id: int in state.units:
		if state.units[id].squad == normal_target: state.units[id].keywords.append("VEHICLE")
	var vehicle_cannon := A.weapon(state, model, normal_target, cannon, false)
	check(vehicle_cannon.ap == -1 and not vehicle_cannon.keywords.has("sustained-hits") and not vehicle_cannon.keywords.get("devastating-wounds", false), "Against a Vehicle, Reaping Tally and both non-Monster/Vehicle cannon traits are excluded")
	var vehicle_target := find_squad(state, 2, "gladiator-reaper")
	for member: int in C.living(state, vehicle_target): state.units[member].position = Vector2(6, 0)
	var vehicle_plan := C.AttackPlan.prepare(state, squad, false, [{"model": model, "target": vehicle_target, "amount": 1, "weapon": "twin-heavy-onslaught-gatling-cannon", "profile": "standard"}], true)
	check(vehicle_plan.error.is_empty() and vehicle_plan.batches[0].weapon.ap == -1 and not vehicle_plan.batches[0].weapon.keywords.has("sustained-hits") and not vehicle_plan.batches[0].weapon.keywords.get("devastating-wounds", false), "Vehicle target restriction is enforced in the prepared attack")
	for id: int in state.units:
		if state.units[id].squad == normal_target:
			state.units[id].keywords.erase("VEHICLE")
			state.units[id].keywords.append("MONSTER")
	var monster_cannon := A.weapon(state, model, normal_target, cannon, false)
	check(monster_cannon.ap == -1 and not monster_cannon.keywords.has("sustained-hits") and not monster_cannon.keywords.get("devastating-wounds", false), "Against a Monster, Reaping Tally and the cannon's restricted traits are also excluded")
	check(A.weapon(state, model, normal_target, state.units[model].melee_weapons[0].profiles.standard, true).ap == 0, "Reaping Tally does not modify melee attacks")
	state.units[model].wounds = 4
	check(A.damaged_attack_penalty(state, model) == -1, "Damaged 4 applies the source hit penalty at four remaining wounds")
	state.units[model].wounds = 5
	check(A.damaged_attack_penalty(state, model) == 0, "Damaged 4 does not apply above its threshold")
	print("Current Gladiator Reaper checks: %d failures" % failures)
	quit(1 if failures else 0)
