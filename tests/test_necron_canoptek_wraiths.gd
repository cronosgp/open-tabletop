extends SceneTree

const F = preload("res://tests/all_units_fixture.gd")
const Profiles = preload("res://scripts/edition_11/current_reference_necron_profiles.gd")
const Army = preload("res://scripts/edition_11/army_capabilities.gd")
const Reanimation = preload("res://scripts/edition_11/reanimation_protocols.gd")
const UnitActions = preload("res://scripts/edition_11/unit_actions.gd")
const NecronSavedEquipment = preload("res://scripts/edition_11/necron_saved_equipment.gd")
const CanoptekWraiths = preload("res://scripts/edition_11/canoptek_wraiths.gd")

const WRAITHS_ID := "40kdc:11e:necrons:canoptek-wraiths"
const MARINE_ID := "40kdc:11e:adeptus-astartes:intercessor-squad"

var failures := 0
var scripted_dice: Array[int] = []

func _initialize() -> void:
	call_deferred("run")

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func scripted_roller() -> int:
	if scripted_dice.is_empty(): return 4
	return scripted_dice.pop_front()

func run() -> void:
	test_datasheet_facts_and_admission()
	test_saved_equipment_and_preparation()
	test_wraith_form_normal_move()
	print("Necron Canoptek Wraiths checks: %d failures" % failures)
	await process_frame
	quit(1 if failures else 0)

func test_datasheet_facts_and_admission() -> void:
	var wraiths := Profiles.profile("canoptek-wraiths")
	check(wraiths.get("source_datasheet_id") == "000000546", "Canoptek Wraiths ID matches 000000546")
	check(wraiths.get("points_by_models") == {3: 95, 6: 220}, "Base points are 95/220 for 3/6 models")
	check(wraiths.get("base_size_source_mm") == 50, "Base size is 50 mm")
	check(wraiths.get("stats") == {"movement_inches": 10, "toughness": 6, "save_target": 3, "wounds": 4, "leadership_target": 8, "objective_control": 2, "invulnerable_target": 4}, "Stats match source")
	for kw: String in ["NECRONS", "BEASTS", "FLY", "CANOPTEK", "WRAITHS"]:
		check(kw in wraiths.get("keywords", []), "Has %s keyword" % kw)
	check(wraiths.get("unsupported_abilities", []).is_empty(), "Unsupported abilities cleared")
	check(wraiths.get("pending_source_checks", []).is_empty(), "Pending source checks empty")

	var res := Army.resolve("Necrons", WRAITHS_ID)
	check(res.get("error", "").is_empty() and int(res.get("cost", -1)) == 95 and int(res.get("models", -1)) == 3, "Default resolve is 3 models for 95")
	var roster3 := Army.admit({"schema_version": 2, "faction": "Necrons", "category": "custom", "points_limit": 1000, "entries": [{"definition_id": WRAITHS_ID, "models": 3, "copies": 2}]})
	var roster6 := Army.admit({"schema_version": 2, "faction": "Necrons", "category": "custom", "points_limit": 1000, "entries": [{"definition_id": WRAITHS_ID, "models": 6, "copies": 2}]})
	check(roster3.get("error", "").is_empty() and int(roster3.get("total", -1)) == 210, "3 models x2 copies costs 95 + 115 = 210 (got %s)" % str(roster3.get("total", -1)))
	check(roster6.get("error", "").is_empty() and int(roster6.get("total", -1)) == 460, "6 models x2 copies costs 220 + 240 = 460 (got %s)" % str(roster6.get("total", -1)))
	check(Reanimation.PROFILE_MODEL_COUNTS.get(WRAITHS_ID) == [3, 6], "Reanimation profile model counts are [3, 6]")

func test_saved_equipment_and_preparation() -> void:
	check(NecronSavedEquipment.supports(WRAITHS_ID), "NecronSavedEquipment supports Canoptek Wraiths")
	var defs := NecronSavedEquipment.defaults(WRAITHS_ID)
	check(defs == {"wraith_ranged": "none", "wraith_melee": "vicious-claws"}, "Defaults match source")
	check(NecronSavedEquipment.valid(WRAITHS_ID, {"wraith_ranged": "particle-caster", "wraith_melee": "whip-coils"}, 3), "Saved equipment validator accepts particle-caster + whip-coils")
	check(NecronSavedEquipment.valid(WRAITHS_ID, {"wraith_ranged": "transdimensional-beamer", "wraith_melee": "vicious-claws"}, 6), "Saved equipment validator accepts transdimensional-beamer + vicious-claws")
	check(not NecronSavedEquipment.valid(WRAITHS_ID, {"wraith_ranged": "invalid", "wraith_melee": "vicious-claws"}, 3), "Saved equipment validator rejects invalid ranged")

	var state: Dictionary = F.P.initial_state({"unit_abilities": true, "reanimation_protocols": true, "combat_doctrines": false, "core_stratagems": true, "manual_allocation": false}, {
		1: {"schema_version": 2, "faction": "Necrons", "category": "custom", "points_limit": 1000, "entries": [
			{"definition_id": WRAITHS_ID, "models": 3, "copies": 1}
		]},
		2: {"schema_version": 2, "faction": "Space Marines", "category": "custom", "points_limit": 1000, "entries": [
			{"definition_id": MARINE_ID, "models": 5, "copies": 1}
		]}
	})
	if state.has("error"):
		check(false, "Initial state failed: %s" % state.error)
		return
	var wraith_models: Array[int] = []
	for m: int in state.units:
		if str(state.units[m].get("definition_id", "")) == WRAITHS_ID: wraith_models.append(m)
	wraith_models.sort()
	check(wraith_models.size() == 3, "3 Wraith models spawned")

	var prep := UnitActions.choices(state, 1)
	var m0 := wraith_models[0]
	var ranged_opts := prep.filter(func(c: Dictionary) -> bool: return c.get("action", "") == "necron-wraiths-ranged" and int(c.get("model", -1)) == m0)
	var melee_opts := prep.filter(func(c: Dictionary) -> bool: return c.get("action", "") == "necron-wraiths-melee" and int(c.get("model", -1)) == m0)
	check(ranged_opts.size() == 2 and melee_opts.size() == 1, "Preparation offers ranged and melee switches for each Wraith")
	for c: Dictionary in ranged_opts:
		if str(c.get("value", "")) == "particle-caster":
			UnitActions.apply(state, 1, c, Vector2.ZERO, Callable())
			break
	if not melee_opts.is_empty():
		UnitActions.apply(state, 1, melee_opts[0], Vector2.ZERO, Callable())
	check(state.units[m0].ranged_weapons.size() == 1 and str(state.units[m0].ranged_weapons[0].get("id", "")) == "particle-caster", "Particle caster applied")
	check(bool(state.units[m0].ranged_weapons[0].get("profiles", {}).get("standard", {}).get("keywords", {}).get("close-quarters", false)), "Particle caster uses close-quarters instead of unsupported pistol")
	check(state.units[m0].melee_weapons.size() == 1 and str(state.units[m0].melee_weapons[0].get("id", "")) == "whip-coils", "Whip coils applied")

func test_wraith_form_normal_move() -> void:
	var state: Dictionary = F.P.initial_state({"unit_abilities": true, "reanimation_protocols": true, "combat_doctrines": false, "core_stratagems": true, "manual_allocation": false}, {
		1: {"schema_version": 2, "faction": "Necrons", "category": "custom", "points_limit": 1000, "entries": [
			{"definition_id": WRAITHS_ID, "models": 3, "copies": 1}
		]},
		2: {"schema_version": 2, "faction": "Space Marines", "category": "custom", "points_limit": 1000, "entries": [
			{"definition_id": MARINE_ID, "models": 5, "copies": 1}
		]}
	})
	if state.has("error"):
		check(false, "Initial state failed: %s" % state.error)
		return
	var wraith_models: Array[int] = []
	var marine_models: Array[int] = []
	for m: int in state.units:
		if int(state.units[m].owner) == 1: wraith_models.append(m)
		else: marine_models.append(m)
	wraith_models.sort()
	marine_models.sort()
	var w_squad := int(state.units[wraith_models[0]].squad)
	var m_squad := int(state.units[marine_models[0]].squad)
	for i in range(wraith_models.size()):
		state.units[wraith_models[i]].position = Vector2(20.0 + i * 2.0, 20.0)
	for i in range(marine_models.size()):
		state.units[marine_models[i]].position = Vector2(15.0, 20.0 + i * 1.5)
	state.phase = "movement"
	state.turn = 1
	state.active_player = 1

	var paths := {
		wraith_models[0]: [{"from": Vector2(10.0, 20.0), "to": Vector2(20.0, 20.0)}]
	}
	var opened := CanoptekWraiths.open_after_normal_move(state, w_squad, "normal", paths)
	check(opened, "Wraith Form window opens after normal move over enemy")
	var choices := UnitActions.choices(state, 1)
	var pick := choices.filter(func(c: Dictionary) -> bool: return c.get("action", "") == "wraith-form-target" and int(c.get("target", -1)) == m_squad)
	check(pick.size() == 1, "Wraith Form offers the moved-over enemy squad")
	scripted_dice = [4, 2, 6]
	var res := UnitActions.apply(state, 1, pick[0], Vector2.ZERO, Callable(self, "scripted_roller"))
	check(res.get("error", "").is_empty(), "Wraith Form apply succeeded")
	for _step in range(4):
		var alloc := UnitActions.choices(state, 2)
		if alloc.is_empty(): break
		UnitActions.apply(state, 2, alloc[0], Vector2.ZERO, Callable(self, "scripted_roller"))
	var remaining_wounds := 0
	for m: int in marine_models:
		remaining_wounds += maxi(0, int(state.units[m].wounds))
	check(remaining_wounds == 8, "2 mortal wounds dealt (4 and 6 on 3 dice) leaving 8/10 marine wounds (got %d)" % remaining_wounds)
