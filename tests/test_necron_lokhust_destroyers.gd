extends SceneTree

const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const Profiles = preload("res://scripts/edition_11/current_reference_necron_profiles.gd")
const Army = preload("res://scripts/edition_11/army_capabilities.gd")
const AbilityCatalog = preload("res://scripts/edition_11/unit_ability_catalog.gd")
const AttackPlan = preload("res://scripts/edition_11/attack_plan.gd")
const Reanimation = preload("res://scripts/edition_11/reanimation_protocols.gd")
const UnitAbilities = preload("res://scripts/edition_11/unit_abilities.gd")
const UnitActions = preload("res://scripts/edition_11/unit_actions.gd")

const LOKHUST_ID := "40kdc:11e:necrons:lokhust-destroyers"
const MARINE_ID := "40kdc:11e:adeptus-astartes:intercessor-squad"

var failures := 0

func _initialize() -> void:
	call_deferred("run")

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func run() -> void:
	var profile := Profiles.profile("lokhust-destroyers")
	check(profile.get("source_datasheet_id", "") == "000002359" and profile.get("points_by_models", {}) == {1: 40, 2: 55, 3: 80, 6: 190} and profile.get("third_plus_points_by_models", {}) == {1: 70, 2: 85, 3: 110, 6: 220}, "Lokhust Destroyers retain App v1.2 priced sizes including third-plus 6 models at 220")
	check(profile.get("supported_rule_ids", []) == ["reanimation-protocols", "hard-wired-for-destruction"] and profile.get("unsupported_abilities", []).is_empty() and profile.get("pending_source_checks", []).is_empty(), "Hard-wired for Destruction is admitted within the local scope")
	var one := Army.admit({"schema_version": 2, "faction": "Necrons", "category": "custom", "points_limit": 1000, "entries": [{"definition_id": LOKHUST_ID, "models": 1, "copies": 1}]})
	var six := Army.admit({"schema_version": 2, "faction": "Necrons", "category": "custom", "points_limit": 1000, "entries": [{"definition_id": LOKHUST_ID, "models": 6, "copies": 1}]})
	var third_six := Army.admit({"schema_version": 2, "faction": "Necrons", "category": "custom", "points_limit": 2000, "entries": [{"definition_id": LOKHUST_ID, "models": 6, "copies": 3}]})
	var blocked := Army.admit({"schema_version": 2, "faction": "Necrons", "category": "custom", "points_limit": 1000, "entries": [{"definition_id": LOKHUST_ID, "models": 4, "copies": 1}]})
	check(str(one.get("error", "")).is_empty() and int(one.get("total", -1)) == 40 and str(six.get("error", "")).is_empty() and int(six.get("total", -1)) == 190, "1- and 6-model Lokhust Destroyers admit at source first-copy prices")
	check(str(third_six.get("error", "")).is_empty() and int(third_six.get("total", -1)) == 600, "Three 6-model copies cost 190+190+220")
	check(not str(blocked.get("error", "")).is_empty(), "Unpriced 4-model Lokhust size stays out of construction")
	check(AbilityCatalog.RULES.get("lokhust-destroyers", []) == ["reanimation-protocols", "hard-wired-for-destruction"], "Ability catalog binds Reanimation and Hard-wired for Destruction")

	var state: Dictionary = F.P.initial_state({"unit_abilities": true, "reanimation_protocols": true, "combat_doctrines": false, "core_stratagems": false, "manual_allocation": true}, {
		1: {"schema_version": 2, "faction": "Necrons", "category": "custom", "points_limit": 1000, "entries": [{"definition_id": LOKHUST_ID, "models": 1, "copies": 1}]},
		2: {"schema_version": 2, "faction": "Space Marines", "category": "custom", "points_limit": 1000, "entries": [
			{"definition_id": MARINE_ID, "models": 5, "copies": 1},
			{"definition_id": MARINE_ID, "models": 5, "copies": 1}
		]}
	})
	if state.has("error"):
		check(false, "Lokhust fixture admits: " + str(state.get("error", "")))
		quit(1)
		return
	state.terrain = {"id": "terrain-11e-v1", "areas": []}
	state.unit_abilities.setup_players = []
	var lokhust_model := -1
	var enemy_squads: Array[int] = []
	for model: int in state.get("units", {}):
		var identity := UnitAbilities.identity(state.units[model])
		if identity == "lokhust-destroyers": lokhust_model = model
		elif identity == "intercessor-squad":
			var squad := int(state.units[model].get("squad", -1))
			if squad not in enemy_squads: enemy_squads.append(squad)
	enemy_squads.sort()
	check(lokhust_model >= 0 and enemy_squads.size() == 2, "Lokhust and two Marine squads materialize")
	if lokhust_model < 0 or enemy_squads.size() < 2:
		quit(1)
		return
	var squad := int(state.units[lokhust_model].get("squad", -1))
	check(Reanimation.supported_unit(state, squad), "Lokhust Destroyers can activate Reanimation Protocols")
	UnitActions.reconcile(state)
	state.phase = "shooting"
	state.active = 1
	state.turn = 1
	state.units[lokhust_model].position = Vector2.ZERO
	for model: int in state.units:
		var unit_squad := int(state.units[model].get("squad", -1))
		if unit_squad == enemy_squads[0]: state.units[model].position = Vector2(12.0, 0.0)
		elif unit_squad == enemy_squads[1]: state.units[model].position = Vector2(20.0, 0.0)
	state.mission = {"objectives": [{"name": "A", "kind": "marker", "position": Vector2(12.0, 0.0), "controller": 2, "secured": 0, "levels": {1: 0, 2: 0}}]}
	var gun_id := str(state.units[lokhust_model].ranged_weapons[0].get("id", ""))
	var closest := AttackPlan.prepare(state, squad, false, [{"model": lokhust_model, "target": enemy_squads[0], "amount": 1, "weapon": gun_id, "profile": "standard"}], true)
	var farther := AttackPlan.prepare(state, squad, false, [{"model": lokhust_model, "target": enemy_squads[1], "amount": 1, "weapon": gun_id, "profile": "standard"}], true)
	check(str(closest.get("error", "")).is_empty() and str(closest.get("batches", [{}])[0].get("context", {}).get("hit_reroll", "")) == "all", "Closest eligible target on an enemy-held objective re-rolls all Hit rolls")
	check(str(farther.get("error", "")).is_empty() and str(farther.get("batches", [{}])[0].get("context", {}).get("hit_reroll", "none")) in ["none", ""], "A farther eligible target does not receive Hard-wired Hit re-rolls")

	if failures == 0:
		print("Lokhust Destroyers scoped local checks: passed")
		quit(0)
	else:
		print("Lokhust Destroyers checks: %d failures" % failures)
		quit(1)
