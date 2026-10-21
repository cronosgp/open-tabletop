extends SceneTree
const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const Geometry = preload("res://scripts/edition_11/contact_movement.gd")
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Catalog = preload("res://scripts/edition_11/army_capabilities.gd")
const Roster = preload("res://scripts/edition_11/roster_validation.gd")
var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func entry(faction: String, identity: String, models: int) -> Dictionary:
	return {"definition_id": "40kdc:11e:%s:%s" % [faction, identity], "models": models, "copies": 1}

func find_squad(state: Dictionary, owner: int, identity: String, occurrence: int = 0) -> int:
	var matches: Array[int] = []
	for squad: int in state.squads:
		if state.squads[squad].owner != owner: continue
		var ids: Array[int] = Geometry.alive(state, squad)
		if not ids.is_empty() and C.UnitAbilities.identity(state.units[ids[0]]) == identity: matches.append(squad)
	return matches[occurrence] if occurrence < matches.size() else -1

func models(state: Dictionary, squad: int) -> Array[int]:
	var result: Array[int] = Geometry.alive(state, squad)
	result.sort()
	return result

func choice_for(options: Array, action: String, model: int, value: String) -> Dictionary:
	for option: Dictionary in options:
		if option.action == action and option.model == model and option.value == value: return option
	return {}

func _initialize() -> void: call_deferred("run")

func run() -> void:
	var profile := Profiles.profile("invader-atvs")
	check(profile.source_book_id == "000000139" and profile.source_datasheet_id == "000004247" and profile.source_export_updated_at == "2026-10-16T21:03:46+03:00", "Invader ATVs use the pinned local Wahapedia shared-book extraction")
	check(profile.points_by_models == {1: 65, 2: 130} and profile.third_plus_points_by_models == {1: 75, 2: 140} and profile.wargear_costs == {"multi-melta": 5}, "Source model-count, third-plus, and per-Multi-melta prices are recorded")
	check(profile.stats == {"movement_inches": 10, "toughness": 6, "save_target": 3, "wounds": 8, "leadership_target": 6, "objective_control": 2, "invulnerable_target": 0}, "Invader ATV model characteristics match the local extraction")
	check(profile.keywords == ["VEHICLE", "MOUNTED", "RAVENWING", "IMPERIUM", "FRAME", "ADEPTUS ASTARTES"], "Invader ATV source keywords are preserved")
	check(profile.ranged.map(func(weapon: Dictionary) -> String: return weapon.id) == ["bolt-pistol", "onslaught-gatling-cannon", "twin-bolt-rifle"] and profile.ranged[1].profiles.standard.target_restricted_traits["devastating-wounds"] == ["MONSTER", "VEHICLE"], "Default guns and Onslaught Gatling Cannon target restriction are preserved")
	check(profile.additional_weapon_profiles.ranged[0].profiles.standard.keywords.melta == 3 and profile.melee[0].profiles.standard.attacks == 4, "Optional Multi-melta and Armoured Impact match source weapon profiles")
	check(Catalog.SPECS.get("invader-atvs", {}).get("current_reference", false) and Roster.POINTS["invader-atvs"].sizes == {1: 65, 2: 130}, "Local catalog admits source model counts and default prices")
	var third_plus := Catalog.admit({"schema_version": 2, "faction": "Space Marines", "category": "custom", "points_limit": 10000, "entries": [entry("adeptus-astartes", "invader-atvs", 2), entry("adeptus-astartes", "invader-atvs", 2), entry("adeptus-astartes", "invader-atvs", 2)]})
	check(third_plus.error.is_empty() and third_plus.total == 400, "Third Invader ATVs use the local 140-point third-plus price")

	var lists := F.selections()
	lists[1].entries = [entry("adeptus-astartes", "invader-atvs", 2)]
	lists[2].entries = [entry("necrons", "immortals", 5), entry("necrons", "necron-warriors", 10)]
	var state: Dictionary = F.P.initial_state({"checked_rosters": false, "official_mission": false, "unit_abilities": true, "combat_doctrines": true, "core_stratagems": true, "reanimation_protocols": true, "awakened_dynasty": true, "manual_allocation": false}, lists)
	check(not state.has("error"), "Current Invader ATVs materialize from the local fixed profile")
	if state.has("error"):
		print(state.error)
		quit(1)
		return
	var atv_squad := find_squad(state, 1, "invader-atvs")
	var target_squad := find_squad(state, 2, "immortals")
	var other_enemy_squad := find_squad(state, 2, "necron-warriors")
	var atvs := models(state, atv_squad)
	var targets := models(state, target_squad)
	var other_enemies := models(state, other_enemy_squad)
	check(atvs.size() == 2 and C.UnitAbilities.has(state, atv_squad, "aggressive-reconnaissance"), "Both models receive their source loadout and Aggressive Reconnaissance")
	for index: int in atvs.size(): state.units[atvs[index]].position = Vector2(0, float(index))
	for index: int in targets.size(): state.units[targets[index]].position = Vector2(14.0 + float(index) * 0.15, 0)
	for index: int in other_enemies.size(): state.units[other_enemies[index]].position = Vector2(45.0 + float(index), 0)
	state.terrain.areas = []
	state.phase = "deployment"
	state.unit_abilities.setup_players = [2]
	state.awakened_dynasty.pending = []
	var setup := C.UnitActions.choices(state, 1)
	var multi_one := choice_for(setup, "invader-atv-gun", atvs[0], "multi-melta")
	var multi_two := choice_for(setup, "invader-atv-gun", atvs[1], "multi-melta")
	check(not multi_one.is_empty() and C.unit_action(state, 1, multi_one, Vector2.ZERO, state.revision).is_empty(), "The first ATV can replace its cannon with a Multi-melta")
	setup = C.UnitActions.choices(state, 1)
	multi_two = choice_for(setup, "invader-atv-gun", atvs[1], "multi-melta")
	check(not multi_two.is_empty() and C.unit_action(state, 1, multi_two, Vector2.ZERO, state.revision).is_empty(), "Each ATV can independently replace its cannon")
	check(state.squads[atv_squad].training_cost == 140 and state.units[atvs[0]].ranged_weapons[1].profiles.standard.keywords.melta == 3 and state.units[atvs[1]].ranged_weapons[1].id == "multi-melta", "Two optional Multi-meltas add ten points and replace the cannons")
	setup = C.UnitActions.choices(state, 1)
	var restore := choice_for(setup, "invader-atv-gun", atvs[0], "onslaught")
	check(not restore.is_empty() and C.unit_action(state, 1, restore, Vector2.ZERO, state.revision).is_empty() and state.squads[atv_squad].training_cost == 135, "Restoring one cannon removes one Multi-melta cost")

	state.phase = "shooting"
	state.active = 1
	state.turn = 1
	state.combat_doctrines.selected_turn[1] = 1
	check(C.UnitAbilities.aggressive_reconnaissance_active(state, atv_squad, target_squad), "The source ability applies while the enemy target has no nearby allied enemy unit")
	var plan: Dictionary = C.AttackPlan.prepare(state, atv_squad, false, [{"model": atvs[0], "target": target_squad, "weapon": "onslaught-gatling-cannon", "profile": "standard", "amount": 1}], false)
	check(plan.error.is_empty() and plan.batches.size() == 1 and int(plan.batches[0].context.get("wound_modifier", 0)) == 1, "Aggressive Reconnaissance freezes +1 to wound in the ranged attack context")
	state.units[other_enemies[0]].position = Vector2(18.0, 0)
	check(not C.UnitAbilities.aggressive_reconnaissance_active(state, atv_squad, target_squad), "A second enemy unit within 6 inches removes the isolated-target bonus")
	plan = C.AttackPlan.prepare(state, atv_squad, false, [{"model": atvs[0], "target": target_squad, "weapon": "onslaught-gatling-cannon", "profile": "standard", "amount": 1}], false)
	check(plan.error.is_empty() and plan.batches.size() == 1 and int(plan.batches[0].context.get("wound_modifier", 0)) == 0, "The attack context loses the bonus when the target has a nearby enemy unit")
	state.phase = "overwatch"
	check(not C.UnitAbilities.aggressive_reconnaissance_active(state, atv_squad, target_squad), "Shooting-phase-only Aggressive Reconnaissance does not grant an Overwatch bonus")

	print("Invader ATVs local checks: %d failures" % failures)
	quit(1 if failures else 0)
