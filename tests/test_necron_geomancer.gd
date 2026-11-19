extends SceneTree

const F = preload("res://tests/all_units_fixture.gd")
const Profiles = preload("res://scripts/edition_11/current_reference_necron_profiles.gd")
const Army = preload("res://scripts/edition_11/army_capabilities.gd")
const Reanimation = preload("res://scripts/edition_11/reanimation_protocols.gd")
const UnitAbilities = preload("res://scripts/edition_11/unit_abilities.gd")
const UnitActions = preload("res://scripts/edition_11/unit_actions.gd")
const Geomancer = preload("res://scripts/edition_11/geomancer.gd")
const CombatScenario = preload("res://scripts/edition_11/combat_scenario.gd")
const Supports = preload("res://scripts/edition_11/support_attachments.gd")

const GEOMANCER_ID := "40kdc:11e:necrons:geomancer"
const WARRIORS_ID := "40kdc:11e:necrons:necron-warriors"
const IMMORTALS_ID := "40kdc:11e:necrons:immortals"
const MACROCYTES_ID := "40kdc:11e:necrons:canoptek-macrocytes"
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
	test_support_attachment_and_vanguard_protocols()
	test_tectonic_reverberations_pinned()
	test_obelisk_node_control_reserve_exclusion()
	test_reanimation_protocols()
	print("Necron Geomancer checks: %d failures" % failures)
	await process_frame
	quit(1 if failures else 0)

func test_datasheet_facts_and_admission() -> void:
	var geo := Profiles.profile("geomancer")
	check(geo.get("source_datasheet_id") == "000004178", "Geomancer ID matches 000004178")
	check(geo.get("points_by_models") == {1: 75}, "Geomancer points are 75 for 1 model")
	check(geo.get("base_size_source_mm") == 50, "Geomancer base is 50 mm")
	check(geo.get("stats") == {"movement_inches": 8, "toughness": 4, "save_target": 4, "wounds": 4, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 0}, "Geomancer stats match source")
	for kw: String in ["NECRONS", "INFANTRY", "CHARACTER", "CRYPTEK", "GEOMANCER"]:
		check(kw in geo.get("keywords", []), "Geomancer has %s keyword" % kw)

	var ranged: Array = geo.get("ranged", [])
	check(ranged.size() == 1, "Geomancer has 1 ranged weapon entry")
	var beam: Dictionary = ranged[0].get("profiles", {}).get("reverberating_beam", {})
	check(beam == {"name": "Tremorglaive – reverberating beam", "range_inches": 18.0, "attacks": 2, "skill": 4, "strength": 8, "ap": -2, "damage": 2, "keywords": {"melta": 2}}, "Tremorglaive reverberating beam matches source")
	var pulse: Dictionary = ranged[0].get("profiles", {}).get("shock_wave_pulse", {})
	check(pulse == {"name": "Tremorglaive – shock wave pulse", "range_inches": 18.0, "attacks": "D6+2", "skill": "-", "strength": 4, "ap": 0, "damage": 1, "keywords": {"ignores-cover": true, "torrent": true}}, "Tremorglaive shock wave pulse matches source")

	var melee: Array = geo.get("melee", [])
	check(melee.size() == 1, "Geomancer has 1 melee weapon entry")
	var glaive_melee: Dictionary = melee[0].get("profiles", {}).get("standard", {})
	check(glaive_melee == {"name": "Tremorglaive", "range_inches": 0.0, "attacks": 2, "skill": 4, "strength": 8, "ap": -2, "damage": 2, "keywords": {}}, "Tremorglaive melee matches source")

	check(geo.get("source_bodyguard_datasheet_ids", []) == ["000000534", "000000535", "000004176"], "Geomancer bodyguard IDs match Warriors, Immortals, Canoptek Macrocytes")
	check(geo.get("unsupported_abilities", []).is_empty(), "Unsupported abilities cleared")
	check(geo.get("pending_source_checks", []).is_empty(), "Pending source checks empty")

	var res := Army.resolve("Necrons", GEOMANCER_ID)
	check(res.get("error", "").is_empty(), "Geomancer resolves cleanly for construction")
	check(int(res.get("cost", -1)) == 75 and int(res.get("models", -1)) == 1, "Cost is 75, models is 1")

	check(not Supports.matching_error([{"definition_id": GEOMANCER_ID, "models": 1, "copies": 1}]).is_empty(), "Standalone Geomancer without eligible bodyguard is rejected by Support matching")
	check(Supports.matching_error([{"definition_id": GEOMANCER_ID, "models": 1, "copies": 1}, {"definition_id": WARRIORS_ID, "models": 10, "copies": 1}]).is_empty(), "Geomancer + Necron Warriors passes Support matching")
	check(Supports.matching_error([{"definition_id": GEOMANCER_ID, "models": 1, "copies": 1}, {"definition_id": IMMORTALS_ID, "models": 5, "copies": 1}]).is_empty(), "Geomancer + Immortals passes Support matching")
	check(Supports.matching_error([{"definition_id": GEOMANCER_ID, "models": 1, "copies": 1}, {"definition_id": MACROCYTES_ID, "models": 5, "copies": 1}]).is_empty(), "Geomancer + Canoptek Macrocytes passes Support matching")

func test_support_attachment_and_vanguard_protocols() -> void:
	# 1. Attached to Warriors -> no Scouts 8"
	var state_warriors: Dictionary = F.P.initial_state({"unit_abilities": true, "reanimation_protocols": true, "combat_doctrines": false, "core_stratagems": true, "manual_allocation": false}, {
		1: {"schema_version": 2, "faction": "Necrons", "category": "custom", "points_limit": 1000, "entries": [
			{"definition_id": GEOMANCER_ID, "models": 1, "copies": 1},
			{"definition_id": WARRIORS_ID, "models": 10, "copies": 1}
		]},
		2: {"schema_version": 2, "faction": "Space Marines", "category": "custom", "points_limit": 1000, "entries": [
			{"definition_id": MARINE_ID, "models": 5, "copies": 1}
		]}
	})
	check(not state_warriors.has("error"), "Geomancer + Warriors state initializes cleanly")
	if not state_warriors.has("error"):
		var geo_model := -1
		var warriors_squad := -1
		for m: int in state_warriors.units:
			var d := str(state_warriors.units[m].get("definition_id", ""))
			if d == GEOMANCER_ID: geo_model = m
			elif d == WARRIORS_ID and warriors_squad < 0: warriors_squad = int(state_warriors.units[m].get("squad", -1))
		var attach_choices := UnitActions.choices(state_warriors, 1).filter(func(c: Dictionary) -> bool:
			return c.get("action", "") == "attach" and int(c.get("model", -1)) == geo_model and int(c.get("target", -1)) == warriors_squad
		)
		check(not attach_choices.is_empty(), "Geomancer can attach as Support to Necron Warriors")
		if not attach_choices.is_empty():
			var apply_res := UnitActions.apply(state_warriors, 1, attach_choices[0], Vector2.ZERO, Callable())
			check(str(apply_res.get("error", "")).is_empty(), "Geomancer attaches to Warriors cleanly")
			check(UnitAbilities.scout_distance(state_warriors, warriors_squad) == 0, "Geomancer attached to Warriors does not have Scouts 8")

	# 2. Attached to Canoptek Macrocytes -> Vanguard Protocols grants Scouts 8"
	var state_macro: Dictionary = F.P.initial_state({"unit_abilities": true, "reanimation_protocols": true, "combat_doctrines": false, "core_stratagems": true, "manual_allocation": false}, {
		1: {"schema_version": 2, "faction": "Necrons", "category": "custom", "points_limit": 1000, "entries": [
			{"definition_id": GEOMANCER_ID, "models": 1, "copies": 1},
			{"definition_id": MACROCYTES_ID, "models": 5, "copies": 1}
		]},
		2: {"schema_version": 2, "faction": "Space Marines", "category": "custom", "points_limit": 1000, "entries": [
			{"definition_id": MARINE_ID, "models": 5, "copies": 1}
		]}
	})
	check(not state_macro.has("error"), "Geomancer + Canoptek Macrocytes state initializes cleanly")
	if not state_macro.has("error"):
		var geo_model := -1
		var macro_squad := -1
		for m: int in state_macro.units:
			var d := str(state_macro.units[m].get("definition_id", ""))
			if d == GEOMANCER_ID: geo_model = m
			elif d == MACROCYTES_ID and macro_squad < 0: macro_squad = int(state_macro.units[m].get("squad", -1))
		var attach_choices := UnitActions.choices(state_macro, 1).filter(func(c: Dictionary) -> bool:
			return c.get("action", "") == "attach" and int(c.get("model", -1)) == geo_model and int(c.get("target", -1)) == macro_squad
		)
		check(not attach_choices.is_empty(), "Geomancer can attach as Support to Canoptek Macrocytes")
		if not attach_choices.is_empty():
			var apply_res := UnitActions.apply(state_macro, 1, attach_choices[0], Vector2.ZERO, Callable())
			check(str(apply_res.get("error", "")).is_empty(), "Geomancer attaches to Canoptek Macrocytes cleanly")
			check(Geomancer.vanguard_protocols_active(state_macro, geo_model), "Vanguard Protocols active when attached to Canoptek Macrocytes")
			check(UnitAbilities.scout_distance(state_macro, macro_squad) == 8, "Attached Geomancer + Canoptek Macrocytes unit has Scouts 8 inches")

func test_tectonic_reverberations_pinned() -> void:
	var state: Dictionary = F.P.initial_state({"unit_abilities": true, "reanimation_protocols": true, "combat_doctrines": false, "core_stratagems": true, "manual_allocation": false}, {
		1: {"schema_version": 2, "faction": "Necrons", "category": "custom", "points_limit": 1000, "entries": [
			{"definition_id": GEOMANCER_ID, "models": 1, "copies": 1},
			{"definition_id": WARRIORS_ID, "models": 10, "copies": 1}
		]},
		2: {"schema_version": 2, "faction": "Space Marines", "category": "custom", "points_limit": 1000, "entries": [
			{"definition_id": MARINE_ID, "models": 5, "copies": 1}
		]}
	})
	if state.has("error"): return

	var geo_model := -1
	var marine_squad := -1
	var marine_model := -1
	for m: int in state.units:
		var u: Dictionary = state.units[m]
		if str(u.get("definition_id", "")) == GEOMANCER_ID: geo_model = m
		elif str(u.get("definition_id", "")) == MARINE_ID:
			if marine_squad < 0: marine_squad = int(u.get("squad", -1))
			if marine_model < 0: marine_model = m

	state.phase = "movement"
	state.active = 1
	state.turn = 1
	state.units[geo_model].position = Vector2(0.0, 0.0)

	# Enemy beyond 18" -> not offered
	for m: int in state.units:
		if int(state.units[m].get("squad", -1)) == marine_squad:
			state.units[m].position = Vector2(0.0, 25.0)
	check(Geomancer.tectonic_choices(state, 1).is_empty(), "Tectonic Reverberations not offered beyond 18 inches")

	# Enemy within 18" -> offered
	for m: int in state.units:
		if int(state.units[m].get("squad", -1)) == marine_squad:
			state.units[m].position = Vector2(0.0, 12.0)
	var choices := Geomancer.tectonic_choices(state, 1)
	check(choices.size() == 1 and int(choices[0].get("target", -1)) == marine_squad, "Tectonic Reverberations offered for visible enemy within 18 inches")

	# Apply pin
	var res := UnitActions.apply(state, 1, choices[0], Vector2.ZERO, Callable())
	check(str(res.get("error", "")).is_empty(), "Tectonic Reverberations applies cleanly")
	check(Geomancer.is_pinned(state, marine_squad), "Enemy unit is pinned")
	check(is_equal_approx(CombatScenario.movement_remaining(state, marine_model), 4.0), "Pinned enemy Move characteristic reduced by 2 (6 -> 4 inches)")
	check(UnitAbilities.charge_modifier(state, marine_squad) == -2, "Pinned enemy Charge roll modifier is -2")
	check(Geomancer.tectonic_choices(state, 1).is_empty(), "Tectonic Reverberations cannot be used twice in the same Movement phase")

	# Persists during opponent's turn
	state.active = 2
	state.turn = 2
	state.phase = "movement"
	UnitActions.reconcile(state)
	check(Geomancer.is_pinned(state, marine_squad), "Pinned persists during opponent's Movement phase")

	# Expires at start of Geomancer owner's next Movement phase
	state.active = 1
	state.turn = 3
	state.phase = "movement"
	UnitActions.reconcile(state)
	check(not Geomancer.is_pinned(state, marine_squad), "Pinned expires at the start of owner's next Movement phase")
	check(is_equal_approx(CombatScenario.movement_remaining(state, marine_model), 6.0), "Enemy Move characteristic restored to 6 inches")
	check(UnitAbilities.charge_modifier(state, marine_squad) == 0, "Enemy Charge modifier restored to 0")

func test_obelisk_node_control_reserve_exclusion() -> void:
	var state: Dictionary = F.P.initial_state({"unit_abilities": true, "reanimation_protocols": true, "combat_doctrines": false, "core_stratagems": true, "manual_allocation": false}, {
		1: {"schema_version": 2, "faction": "Necrons", "category": "custom", "points_limit": 1000, "entries": [
			{"definition_id": GEOMANCER_ID, "models": 1, "copies": 1},
			{"definition_id": WARRIORS_ID, "models": 10, "copies": 1}
		]},
		2: {"schema_version": 2, "faction": "Space Marines", "category": "custom", "points_limit": 1000, "entries": [
			{"definition_id": MARINE_ID, "models": 5, "copies": 1}
		]}
	})
	if state.has("error"): return

	var geo_model := -1
	var marine_squad := -1
	var marine_model := -1
	for m: int in state.units:
		var u: Dictionary = state.units[m]
		if str(u.get("definition_id", "")) == GEOMANCER_ID: geo_model = m
		elif str(u.get("definition_id", "")) == MARINE_ID:
			if marine_squad < 0: marine_squad = int(u.get("squad", -1))
			if marine_model < 0: marine_model = m

	state.units[geo_model].position = Vector2(0.0, 0.0)
	state.mission = {
		"objectives": [
			{"name": "Obj 1", "kind": "point", "position": Vector2(0.0, 0.0), "elevation": 0.0, "controller": 1}
		]
	}
	check(Geomancer.obelisk_node_control_active(state, geo_model), "Obelisk Node Control active when Geomancer is within range of controlled objective")

	# Put Marine squad in Reserves and open an ingress window
	state.round = 3
	state.phase = "movement"
	state.active = 2
	for m: int in state.units:
		if int(state.units[m].get("squad", -1)) == marine_squad:
			state.units[m].on_battlefield = false
	state.unit_abilities.window = {"kind": "ingress", "squad": marine_squad, "deep_strike": true, "positions": {}}

	# 10" away (edge distance ~ 10 - 0.98 - 0.63 = 8.39" <= 12") -> blocked
	var near_err := UnitActions.ingress_position_error(state, marine_model, Vector2(0.0, 10.0))
	check("12 inches" in near_err, "Reserve setup within 12 inches of Geomancer on controlled objective is blocked: " + near_err)

	# 16" away (edge distance ~ 16 - 0.98 - 0.63 = 14.39" > 12") -> allowed
	var far_err := UnitActions.ingress_position_error(state, marine_model, Vector2(0.0, 16.0))
	check(far_err.is_empty(), "Reserve setup beyond 12 inches is allowed: " + far_err)

	# Objective controlled by opponent -> Obelisk Node Control inactive, 10" allowed (> 8" normal Deep Strike)
	state.mission.objectives[0].controller = 2
	check(not Geomancer.obelisk_node_control_active(state, geo_model), "Obelisk Node Control inactive when objective is not controlled by Geomancer owner")
	var unguarded_err := UnitActions.ingress_position_error(state, marine_model, Vector2(0.0, 10.0))
	check(unguarded_err.is_empty(), "Reserve setup at 10 inches allowed when objective is not controlled: " + unguarded_err)

func test_reanimation_protocols() -> void:
	check(Reanimation.CHARACTER_WOUNDS.get(GEOMANCER_ID) == 4, "Geomancer character wounds is 4")
	check(Reanimation.PROFILE_MODEL_COUNTS.get(GEOMANCER_ID) == [1], "Geomancer profile model count is [1]")
