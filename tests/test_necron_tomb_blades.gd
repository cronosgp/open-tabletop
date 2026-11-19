extends SceneTree

const F = preload("res://tests/all_units_fixture.gd")
const Profiles = preload("res://scripts/edition_11/current_reference_necron_profiles.gd")
const Army = preload("res://scripts/edition_11/army_capabilities.gd")
const Reanimation = preload("res://scripts/edition_11/reanimation_protocols.gd")
const UnitAbilities = preload("res://scripts/edition_11/unit_abilities.gd")
const UnitActions = preload("res://scripts/edition_11/unit_actions.gd")
const NecronSavedEquipment = preload("res://scripts/edition_11/necron_saved_equipment.gd")
const TacticalFluidity = preload("res://scripts/edition_11/tactical_fluidity.gd")

const TB_ID := "40kdc:11e:necrons:tomb-blades"
const MARINE_ID := "40kdc:11e:adeptus-astartes:intercessor-squad"

var failures := 0

func _initialize() -> void:
	call_deferred("run")

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func run() -> void:
	test_datasheet_facts_and_admission()
	test_saved_equipment_wargear_and_preparation()
	test_evasion_engrams_after_shot()
	print("Necron Tomb Blades checks: %d failures" % failures)
	await process_frame
	quit(1 if failures else 0)

func test_datasheet_facts_and_admission() -> void:
	var tb := Profiles.profile("tomb-blades")
	check(tb.get("source_datasheet_id") == "000000548", "Tomb Blades ID matches 000000548")
	check(tb.get("points_by_models") == {3: 70, 6: 140}, "1st-2nd copy points are 70/140 for 3/6 models")
	check(tb.get("third_plus_points_by_models") == {3: 80, 6: 150}, "3rd+ copy points are 80/150 for 3/6 models")
	check(tb.get("base_size_source_mm") == 32, "Base size is 32 mm")
	check(tb.get("stats") == {"movement_inches": 12, "toughness": 5, "save_target": 4, "wounds": 2, "leadership_target": 7, "objective_control": 2, "invulnerable_target": 0}, "Stats match source")
	for kw: String in ["NECRONS", "MOUNTED", "FLY", "TOMB BLADES"]:
		check(kw in tb.get("keywords", []), "Has %s keyword" % kw)
	check(tb.get("unsupported_abilities", []).is_empty(), "Unsupported abilities cleared")
	check(tb.get("pending_source_checks", []).is_empty(), "Pending source checks empty")

	var res := Army.resolve("Necrons", TB_ID)
	check(res.get("error", "").is_empty() and int(res.get("cost", -1)) == 70 and int(res.get("models", -1)) == 3, "Default resolve is 3 models for 70")
	var roster3 := Army.admit({"schema_version": 2, "faction": "Necrons", "category": "custom", "points_limit": 1000, "entries": [{"definition_id": TB_ID, "models": 3, "copies": 3}]})
	check(roster3.get("error", "").is_empty() and int(roster3.get("total", -1)) == 220, "3 models x3 copies costs 70 + 70 + 80 = 220 (got %s)" % str(roster3.get("total", -1)))
	check(Reanimation.PROFILE_MODEL_COUNTS.get(TB_ID) == [3, 6], "Reanimation profile model counts are [3, 6]")

func test_saved_equipment_wargear_and_preparation() -> void:
	check(NecronSavedEquipment.supports(TB_ID), "NecronSavedEquipment supports Tomb Blades")
	var defs := NecronSavedEquipment.defaults(TB_ID)
	check(defs == {"tomb_blade_ranged": "twin-gauss-blaster", "tomb_blade_shieldvanes": "none", "tomb_blade_optic": "none"}, "Defaults match source")
	check(NecronSavedEquipment.valid(TB_ID, {"tomb_blade_ranged": "particle-beamer", "tomb_blade_shieldvanes": "shieldvanes", "tomb_blade_optic": "nebuloscope"}, 3), "Validator accepts particle-beamer + shieldvanes + nebuloscope")
	check(NecronSavedEquipment.valid(TB_ID, {"tomb_blade_ranged": "twin-tesla-carbine", "tomb_blade_shieldvanes": "none", "tomb_blade_optic": "shadowloom"}, 6), "Validator accepts twin-tesla-carbine + shadowloom")
	check(not NecronSavedEquipment.valid(TB_ID, {"tomb_blade_ranged": "invalid", "tomb_blade_shieldvanes": "none", "tomb_blade_optic": "none"}, 3), "Validator rejects invalid ranged")

	var state: Dictionary = F.P.initial_state({"unit_abilities": true, "reanimation_protocols": true, "combat_doctrines": false, "core_stratagems": true, "manual_allocation": false}, {
		1: {"schema_version": 2, "faction": "Necrons", "category": "custom", "points_limit": 1000, "entries": [
			{"definition_id": TB_ID, "models": 3, "copies": 1}
		]},
		2: {"schema_version": 2, "faction": "Space Marines", "category": "custom", "points_limit": 1000, "entries": [
			{"definition_id": MARINE_ID, "models": 5, "copies": 1}
		]}
	})
	if state.has("error"):
		check(false, "Initial state failed: %s" % state.error)
		return
	var tb_models: Array[int] = []
	for m: int in state.units:
		if str(state.units[m].get("definition_id", "")) == TB_ID: tb_models.append(m)
	tb_models.sort()
	check(tb_models.size() == 3, "3 Tomb Blade models spawned")
	var tb_squad := int(state.units[tb_models[0]].squad)
	check(UnitAbilities.scout_distance(state, tb_squad) == 9, "Tomb Blades have Scouts 9\"")
	check(not UnitAbilities.every_model_has(state, tb_squad, "stealth"), "No Stealth without Shadowloom")

	# Equip Shadowloom on all 3 models, Shieldvanes on model 0, Nebuloscope on model 0 then switch back to Shadowloom
	for m: int in tb_models:
		var prep := UnitActions.choices(state, 1)
		for c: Dictionary in prep:
			if int(c.get("model", -1)) == m and c.get("action", "") == "necron-tomb-blades-optic" and c.get("value", "") == "shadowloom":
				UnitActions.apply(state, 1, c, Vector2.ZERO, Callable())
				break
	check(UnitAbilities.every_model_has(state, tb_squad, "stealth"), "Stealth granted when every model has Shadowloom")

	var m0 := tb_models[0]
	var prep0 := UnitActions.choices(state, 1)
	for c: Dictionary in prep0:
		if int(c.get("model", -1)) == m0 and c.get("action", "") == "necron-tomb-blades-shieldvanes" and c.get("value", "") == "shieldvanes":
			UnitActions.apply(state, 1, c, Vector2.ZERO, Callable())
		elif int(c.get("model", -1)) == m0 and c.get("action", "") == "necron-tomb-blades-ranged" and c.get("value", "") == "twin-tesla-carbine":
			UnitActions.apply(state, 1, c, Vector2.ZERO, Callable())
		elif int(c.get("model", -1)) == m0 and c.get("action", "") == "necron-tomb-blades-optic" and c.get("value", "") == "nebuloscope":
			UnitActions.apply(state, 1, c, Vector2.ZERO, Callable())
	check(int(state.units[m0].movement) == 8 and int(state.units[m0].defense.save_target) == 3, "Shieldvanes sets Move 8\" and Save 3+")
	check(str(state.units[m0].ranged_weapons[0].get("id", "")) == "source-ranged-3", "Twin tesla carbine applied")
	check(bool(state.units[m0].ranged_weapons[0].get("profiles", {}).get("standard", {}).get("keywords", {}).get("ignores-cover", false)), "Nebuloscope grants Ignores Cover")
	check(not UnitAbilities.every_model_has(state, tb_squad, "stealth"), "Stealth lost when model 0 switches from Shadowloom to Nebuloscope")

func test_evasion_engrams_after_shot() -> void:
	var state: Dictionary = F.P.initial_state({"unit_abilities": true, "reanimation_protocols": true, "combat_doctrines": false, "core_stratagems": true, "manual_allocation": false}, {
		1: {"schema_version": 2, "faction": "Necrons", "category": "custom", "points_limit": 1000, "entries": [
			{"definition_id": TB_ID, "models": 3, "copies": 1}
		]},
		2: {"schema_version": 2, "faction": "Space Marines", "category": "custom", "points_limit": 1000, "entries": [
			{"definition_id": MARINE_ID, "models": 5, "copies": 1}
		]}
	})
	if state.has("error"):
		check(false, "Initial state failed: %s" % state.error)
		return
	var tb_models: Array[int] = []
	for m: int in state.units:
		if int(state.units[m].owner) == 1: tb_models.append(m)
		else: state.units[m].position = Vector2(30.0, 20.0)
	tb_models.sort()
	var tb_squad := int(state.units[tb_models[0]].squad)
	for i in range(tb_models.size()):
		state.units[tb_models[i]].position = Vector2(10.0 + i * 1.5, 10.0)
	state.phase = "shooting"
	state.turn = 1
	state.active = 1
	state.active_player = 1
	state.squads[tb_squad].shot = true

	TacticalFluidity.open_after_shot(state, tb_squad)
	var choices := UnitActions.choices(state, 1)
	var use_opt := choices.filter(func(c: Dictionary) -> bool: return c.get("action", "") == "fluidity-use")
	check(use_opt.size() == 1 and "Evasion Engrams" in str(use_opt[0].get("label", "")), "Evasion Engrams offers 6\" Normal move after shooting")
	var res := UnitActions.apply(state, 1, use_opt[0], Vector2.ZERO, Callable())
	check(res.get("error", "").is_empty(), "Evasion Engrams use succeeded")
	check(int(state.squads[tb_squad].get("cannot_charge_until_turn", -1)) == 1, "Evasion Engrams prevents charging this turn")
	var window: Dictionary = state.unit_abilities.get("window", {})
	check(int(window.get("distance", -1)) == 6, "Evasion Engrams move distance is 6\"")
