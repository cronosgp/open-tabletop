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
	var profile := Profiles.profile("company-heroes")
	check(profile.get("source_book_id") == "000000139" and profile.get("source_datasheet_id") == "000002772" and profile.get("source_export_updated_at") == "2026-10-16T21:03:46+03:00", "Company Heroes points to the pinned Wahapedia e11 export")
	check(profile.get("models") == 4 and profile.get("points_by_models", {}) == {4: 125} and profile.get("third_plus_points_by_models", {}) == {4: 145} and is_equal_approx(profile.get("base_radius_inches", 0.0), 20.0 / 25.4), "Fixed 4-model composition, copy-tier prices and 40 mm base radius match local source data")
	check(profile.get("stats", {}) == {"movement_inches": 6, "toughness": 5, "save_target": 3, "wounds": 4, "leadership_target": 6, "objective_control": 2, "invulnerable_target": 0}, "Shared characteristics match all four source model rows")
	check(Catalog.SPECS.has("company-heroes") and Roster.POINTS.get("company-heroes", {}).get("third_plus_sizes", {}) == {4: 145}, "Company Heroes are selectable with Wahapedia copy-tier prices")
	var three := Catalog.admit({"schema_version": 2, "faction": "Space Marines", "category": "custom", "points_limit": 10000, "entries": [{"definition_id": "40kdc:11e:adeptus-astartes:company-heroes", "models": 4, "copies": 3}]})
	check(three.get("error", "").is_empty() and three.get("total", -1) == 395, "Third Company Heroes copy charges 145 points after two at 125")
	var source_loadouts: Array[Dictionary] = []
	for index in range(4): source_loadouts.append(Profiles.company_heroes_model_loadout(index))
	check(source_loadouts.map(func(row: Dictionary) -> String: return row.role) == ["ancient", "company-champion", "bolt-rifle-veteran", "heavy-bolter-veteran"], "The four model roles keep their exported composition order")
	check(source_loadouts[0].ranged.size() == 2 and source_loadouts[1].melee[0].id == "master-crafted-power-weapon" and source_loadouts[3].ranged[1].id == "master-crafted-heavy-bolter", "Source-listed model-specific weapon loadouts are represented independently")

	var lists := F.selections()
	lists[1].entries.append({"definition_id": "40kdc:11e:adeptus-astartes:company-heroes", "models": 4, "copies": 1})
	var state := F.P.initial_state({"checked_rosters": true, "official_mission": true, "unit_abilities": true, "combat_doctrines": true, "reanimation_protocols": true, "awakened_dynasty": true, "core_stratagems": true, "manual_allocation": false}, lists)
	check(not state.has("error"), "Company Heroes pass local checked-roster admission and materialize")
	if state.has("error"):
		print(state)
		quit(1)
		return
	var squad := -1
	var models: Array[int] = []
	for model: int in state.units:
		var unit: Dictionary = state.units[model]
		if unit.owner == 1 and A.identity(unit) == "company-heroes":
			squad = int(unit.squad)
			models.append(model)
	models.sort()
	check(models.size() == 4 and state.squads[squad].training_cost == 125 and A.has(state, squad, "raise-the-banner") and A.has(state, squad, "command-squad"), "Four-man unit, source cost and both datasheet abilities materialize")
	var roles := []
	for model in models:
		var unit: Dictionary = state.units[model]
		roles.append(unit.get("company_heroes_model", -1))
		check(not unit.get("sergeant", false), "No Company Heroes model is incorrectly marked as a Sergeant")
		check(unit.get("melee_weapons", []).size() == 1 and unit.get("ranged_weapons", []).size() == source_loadouts[int(unit.company_heroes_model)].ranged.size(), "Each model receives its own exported weapons")
		check(unit.keywords.has("ANCIENT") == (int(unit.company_heroes_model) == 0) and unit.keywords.has("CHAMPION") == (int(unit.company_heroes_model) == 1), "Ancient and Champion model keywords remain scoped to their source rows")
	check(roles == [0, 1, 2, 3], "All source-defined role assignments survive list materialization")
	check(A.defensive_wound_modifier(state, squad, 6, 5) == -1 and A.defensive_wound_modifier(state, squad, 5, 5) == -1, "Command Squad reduces Wound rolls without an attack-Strength threshold")
	state.phase = "movement"
	state.turn = 3
	state.round = 2
	state.active = 1
	state.mission.stage = "battle"
	state.awakened_dynasty.pending = []
	state.deployment.complete = true
	state.unit_abilities.setup_players = [1, 2]
	state.unit_abilities.battle_players = [1, 2]
	state.unit_abilities.window = {}
	state.unit_abilities.phase_key = F.C.UnitActions.key(state)
	state.unit_abilities.setup_players = [1, 2]
	state.unit_abilities.battle_players = [1, 2]
	state.unit_abilities.window = {}
	state.unit_abilities.phase_key = F.C.UnitActions.key(state)
	state.mission.objectives = [{"name": "Company Banner", "kind": "marker", "position": Vector2.ZERO, "controller": 0, "secured": 0, "levels": {1: 0, 2: 0}}]
	for model: int in state.units:
		state.units[model].on_battlefield = true
		state.units[model].position = Vector2(0, 0) if state.units[model].squad == squad else Vector2(20, 20)
	var roll_one := func() -> int: return 1
	check(state.mission.objectives[0].secured == 0 and F.C.advance_phase(state, 1, state.revision, roll_one).is_empty() and state.mission.objectives[0].secured == 1, "Company Heroes secure the objective at the end of their own Movement phase")
	print("Company Heroes current source profile: %d failures" % failures)
	quit(1 if failures else 0)
