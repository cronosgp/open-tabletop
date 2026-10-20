extends SceneTree
const F = preload("res://tests/all_units_fixture.gd")
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Catalog = preload("res://scripts/edition_11/army_capabilities.gd")
const Roster = preload("res://scripts/edition_11/roster_validation.gd")
const A = F.C.UnitAbilities
var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func _initialize() -> void: call_deferred("run")

func run() -> void:
	var profile := Profiles.profile("gladiator-reaper")
	check(profile.get("source_book_id") == "000000139" and profile.get("source_datasheet_id") == "000001667" and profile.get("source_export_updated_at") == "2026-10-16T21:03:46+03:00", "Gladiator Reaper cites the pinned Wahapedia e11 export")
	check(profile.get("points_by_models", {}) == {1: 165} and profile.get("third_plus_points_by_models", {}) == {1: 185} and profile.get("max_supported_copies") == 3 and is_equal_approx(profile.get("base_radius_inches", 0.0), 50.0 / 25.4), "Source one-model size, first-two/third-plus prices and 100 mm base are recorded")
	check(profile.stats == {"movement_inches": 10, "toughness": 10, "save_target": 3, "wounds": 12, "leadership_target": 6, "objective_control": 3, "invulnerable_target": 0} and profile.keywords.has("FRAME") and profile.keywords.has("SMOKE"), "Model characteristics and datasheet keywords match local rows")
	check(profile.ranged.size() == 2 and profile.ranged[0].id == "defensive-array" and profile.ranged[1].id == "twin-heavy-onslaught-gatling-cannon" and profile.melee[0].id == "armoured-hull", "Uniform default loadout matches the source with all three physical weapon profiles")
	check(Catalog.SPECS.has("gladiator-reaper") and Roster.POINTS["gladiator-reaper"].sizes == {1: 165} and Roster.POINTS["gladiator-reaper"].third_plus_sizes == {1: 185}, "The local construction catalog uses source copy-tier prices")
	var three := Catalog.admit({"schema_version": 2, "faction": "Space Marines", "category": "custom", "points_limit": 10000, "entries": [{"definition_id": "40kdc:11e:adeptus-astartes:gladiator-reaper", "models": 1, "copies": 3}]})
	check(three.get("error", "").is_empty() and three.get("total", -1) == 515, "Three Gladiator Reapers use 165/165/185 source prices")

	var lists := F.selections()
	lists[1].entries.append({"definition_id": "40kdc:11e:adeptus-astartes:gladiator-reaper", "models": 1, "copies": 1})
	var state := F.P.initial_state({"checked_rosters": true, "official_mission": true, "unit_abilities": true, "combat_doctrines": true, "reanimation_protocols": true, "awakened_dynasty": true, "core_stratagems": true, "manual_allocation": false}, lists)
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
	check(model >= 0 and state.squads[squad].training_cost == 165 and A.has(state, squad, "reaping-tally") and A.has(state, squad, "damaged-4") and A.has(state, squad, "deadly-demise-d3"), "Reaper, Damaged 4 and Deadly Demise D3 abilities materialize")
	check(state.units[model].ranged_weapons.map(func(w: Dictionary) -> String: return w.id) == ["defensive-array", "twin-heavy-onslaught-gatling-cannon"] and state.units[model].melee_weapons[0].id == "armoured-hull", "All default source weapons are attached to the model")
	var normal_target := -1
	for id: int in state.units:
		if state.units[id].owner == 2:
			normal_target = int(state.units[id].squad)
			break
	var defensive: Dictionary = state.units[model].ranged_weapons[0].profiles.standard
	var tally_profile := A.weapon(state, model, normal_target, defensive, false)
	check(defensive.ap == -1 and tally_profile.ap == -2, "Reaping Tally improves AP by one against a non-Monster/non-Vehicle target without mutating the source weapon")
	var cannon: Dictionary = state.units[model].ranged_weapons[1].profiles.standard
	var ordinary_cannon := A.weapon(state, model, normal_target, cannon, false)
	check(ordinary_cannon.ap == -2 and ordinary_cannon.keywords.get("sustained-hits", 0) == 2 and ordinary_cannon.keywords.get("devastating-wounds", false), "Reaping Tally and the cannon's conditional traits apply against an eligible target")
	for id: int in state.units:
		if state.units[id].squad == normal_target: state.units[id].keywords.append("VEHICLE")
	var vehicle_cannon := A.weapon(state, model, normal_target, cannon, false)
	check(vehicle_cannon.ap == -1 and not vehicle_cannon.keywords.has("sustained-hits") and not vehicle_cannon.keywords.get("devastating-wounds", false), "Against a Vehicle, Reaping Tally and both non-Monster/Vehicle cannon traits are excluded")
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
