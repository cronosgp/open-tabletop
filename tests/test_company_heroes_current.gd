extends SceneTree
const F = preload("res://tests/all_units_fixture.gd")
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Catalog = preload("res://scripts/edition_11/army_capabilities.gd")
const Roster = preload("res://scripts/edition_11/roster_validation.gd")
const Equipment = preload("res://scripts/edition_11/equipment.gd")
const C = F.C
const A = F.C.UnitAbilities
var failures := 0

const EXPECTED_WEAPONS := {
	"master-crafted-bolt-pistol": {"range_inches": 12.0, "attacks": 1, "skill": 3, "strength": 5, "ap": -1, "damage": 2, "keywords": {"close-quarters": true}},
	"master-crafted-bolt-rifle": {"range_inches": 24.0, "attacks": 2, "skill": 3, "strength": 5, "ap": -1, "damage": 2, "keywords": {"assault": true, "rapid-fire": 1}},
	"master-crafted-heavy-bolter": {"range_inches": 36.0, "attacks": 4, "skill": 3, "strength": 6, "ap": -1, "damage": 2, "keywords": {"assault": true, "rapid-fire": 2, "heavy": true, "sustained-hits": 1}},
	"combat-knife": {"range_inches": 0.0, "attacks": 5, "skill": 3, "strength": 5, "ap": -1, "damage": 1, "keywords": {}},
	"master-crafted-power-weapon": {"range_inches": 0.0, "attacks": 6, "skill": 2, "strength": 6, "ap": -2, "damage": 2, "keywords": {"precision": true}}
}

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func check_attack_profile(state: Dictionary, squad: int, target: int, model: int, melee: bool, weapon_id: String) -> void:
	var selected: Dictionary = Equipment.select(state, model, melee, weapon_id, "standard")
	check(selected.get("error", "").is_empty(), "%s is available from this source model's equipment" % weapon_id)
	if not selected.get("error", "").is_empty(): return
	var expected: Dictionary = EXPECTED_WEAPONS[weapon_id]
	for field in ["range_inches", "attacks", "skill", "strength", "ap", "damage"]:
		check(selected.stats.get(field) == expected[field], "%s preserves source %s in the model's equipment profile" % [weapon_id, field])
	check(selected.stats.get("keywords", {}) == expected.keywords, "%s retains its complete source weapon traits in the model's equipment profile" % weapon_id)
	var previous_phase: String = str(state.phase)
	var previous_position: Vector2 = state.units[model].position
	if melee:
		state.phase = "fight"
		var target_models: Array[int] = C.living(state, target)
		if not target_models.is_empty(): state.units[model].position = state.units[target_models[0]].position
	var attack_amount := int(selected.stats.attacks) if melee else 1
	var plan: Dictionary = C.AttackPlan.prepare(state, squad, melee, [{"model": model, "target": target, "amount": attack_amount, "weapon": weapon_id, "profile": "standard"}], true)
	state.phase = previous_phase
	state.units[model].position = previous_position
	check(plan.get("error", "").is_empty() and plan.get("batches", []).size() == 1, "%s for model %d reaches AttackPlan: %s" % [weapon_id, model, plan.get("error", "")])
	if not plan.get("error", "").is_empty() or plan.get("batches", []).size() != 1: return
	var batch: Dictionary = plan.batches[0]
	var sources: Array = batch.context.get("attack_sources", [])
	check(not sources.is_empty() and str(sources[0].get("weapon", "")) == weapon_id, "AttackPlan retains the correct model-specific %s source" % weapon_id)
	if weapon_id == "master-crafted-power-weapon": check(batch.weapon.keywords.get("precision", false), "Company Champion's Power Weapon reaches AttackPlan with Precision")

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
	check(profile.get("keywords", []) == ["INFANTRY", "EXPLOSIVES", "IMPERIUM", "TACTICUS", "ADEPTUS ASTARTES"], "The shared profile exposes only the datasheet's all-model keywords")

	var lists := F.current_marine_selections()
	lists[1].entries.append({"definition_id": "40kdc:11e:adeptus-astartes:company-heroes", "models": 4, "copies": 1})
	var checked_roster := Roster.admit(lists[1])
	check(checked_roster.get("error", "").is_empty(), "Company Heroes pass local fixed-roster admission")
	var state := F.P.initial_state({"unit_abilities": true, "combat_doctrines": true, "reanimation_protocols": true, "awakened_dynasty": true, "core_stratagems": true, "manual_allocation": false}, lists)
	check(not state.has("error"), "Company Heroes materialize in the isolated current-catalog match fixture")
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
	var captain_model := -1
	for model: int in state.units:
		if state.units[model].owner == 1 and A.identity(state.units[model]) == "captain": captain_model = model
	check(captain_model >= 0 and C.UnitActions.attachment_allowed(state, captain_model, squad), "The source-linked Captain can attach to Company Heroes in the current runtime state")
	var roles := []
	var expected_ranged := [
		["master-crafted-bolt-pistol", "master-crafted-bolt-rifle"],
		["master-crafted-bolt-pistol"],
		["master-crafted-bolt-pistol", "master-crafted-bolt-rifle"],
		["master-crafted-bolt-pistol", "master-crafted-heavy-bolter"]
	]
	var expected_melee := [["combat-knife"], ["master-crafted-power-weapon"], ["combat-knife"], ["combat-knife"]]
	for model in models:
		var unit: Dictionary = state.units[model]
		var role_index := int(unit.get("company_heroes_model", -1))
		roles.append(role_index)
		check(not unit.get("sergeant", false), "No Company Heroes model is incorrectly marked as a Sergeant")
		check(unit.get("melee_weapons", []).map(func(weapon: Dictionary) -> String: return weapon.id) == expected_melee[role_index] and unit.get("ranged_weapons", []).map(func(weapon: Dictionary) -> String: return weapon.id) == expected_ranged[role_index], "Role %d receives the exact model-specific source weapons" % role_index)
		check(unit.keywords.has("ANCIENT") == (role_index == 0) and unit.keywords.has("CHARACTER") == (role_index == 0) and unit.keywords.has("CHAMPION") == (role_index == 1), "Ancient, Character and Champion keywords stay on their source-listed model %d: %s" % [role_index, str(unit.keywords)])
		for keyword in ["INFANTRY", "EXPLOSIVES", "IMPERIUM", "TACTICUS", "ADEPTUS ASTARTES"]:
			check(unit.keywords.has(keyword), "All Company Heroes models carry the shared %s keyword" % keyword)
	check(roles == [0, 1, 2, 3], "All source-defined role assignments survive list materialization")
	check(A.defensive_wound_modifier(state, squad, 6, 5) == -1 and A.defensive_wound_modifier(state, squad, 5, 5) == -1, "Command Squad reduces Wound rolls without an attack-Strength threshold")
	var enemy_squad := -1
	var enemy_model := -1
	for model: int in state.units:
		var unit: Dictionary = state.units[model]
		if unit.owner == 2 and A.identity(unit) == "intercessor-squad" and enemy_squad < 0:
			enemy_squad = int(unit.squad)
			enemy_model = model
	for model: int in state.units:
		var unit: Dictionary = state.units[model]
		unit.position = Vector2.ZERO if unit.owner == 1 and unit.squad == squad else Vector2(8, 0) if unit.owner == 2 and unit.squad == enemy_squad else Vector2(20, 20)
	state.phase = "shooting"
	state.active = 1
	for model in models:
		var company_model: Dictionary = state.units[model]
		for weapon: Dictionary in company_model.ranged_weapons: check_attack_profile(state, squad, enemy_squad, model, false, str(weapon.id))
		for weapon: Dictionary in company_model.melee_weapons: check_attack_profile(state, squad, enemy_squad, model, true, str(weapon.id))
	state.active = 2
	var incoming_plan: Dictionary = C.AttackPlan.prepare(state, enemy_squad, false, [{"model": enemy_model, "target": squad, "amount": 1, "weapon": "bolt-rifle", "profile": "saturation"}], true)
	check(incoming_plan.get("error", "").is_empty() and incoming_plan.get("batches", []).size() == 1 and int(incoming_plan.batches[0].context.get("wound_modifier", 0)) == -1, "Command Squad applies its unconditional -1 to Wound in the real incoming Intercessor AttackPlan")
	check(A.defensive_wound_modifier(state, enemy_squad, 5, 5) == 0, "Command Squad does not protect a different unit")
	state.active = 1
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
	state.mission.objectives = [
		{"name": "Company Banner", "kind": "marker", "position": Vector2.ZERO, "controller": 0, "secured": 0, "levels": {1: 0, 2: 0}},
		{"name": "Distant Objective", "kind": "marker", "position": Vector2(50, 50), "controller": 0, "secured": 0, "levels": {1: 0, 2: 0}}
	]
	for model: int in state.units:
		state.units[model].on_battlefield = true
		state.units[model].position = Vector2(0, 0) if state.units[model].squad == squad else Vector2(20, 20)
	var roll_one := func() -> int: return 1
	check(state.mission.objectives[0].secured == 0 and F.C.advance_phase(state, 1, state.revision, roll_one).is_empty() and state.mission.objectives[0].secured == 1 and state.mission.objectives[1].secured == 0, "Raise the Banner secures the objective controlled by Company Heroes at Movement end, but leaves the distant objective unsecured")
	print("Company Heroes current source profile: %d failures" % failures)
	quit(1 if failures else 0)
