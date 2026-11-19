extends SceneTree

const F = preload("res://tests/all_units_fixture.gd")
const Profiles = preload("res://scripts/edition_11/current_reference_necron_profiles.gd")
const Army = preload("res://scripts/edition_11/army_capabilities.gd")
const Reanimation = preload("res://scripts/edition_11/reanimation_protocols.gd")
const UnitActions = preload("res://scripts/edition_11/unit_actions.gd")
const TrazynTheInfinite = preload("res://scripts/edition_11/trazyn_the_infinite.gd")

const TRAZYN_ID := "40kdc:11e:necrons:trazyn-the-infinite"
const OVERLORD_ID := "40kdc:11e:necrons:overlord"
const SKORPEKH_LORD_ID := "40kdc:11e:necrons:skorpekh-lord"
const IMOTEKH_ID := "40kdc:11e:necrons:imotekh-the-stormlord"
const WARRIORS_ID := "40kdc:11e:necrons:necron-warriors"
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
	test_ancient_collector_sticky_objective()
	test_surrogate_hosts()
	print("Necron Trazyn the Infinite checks: %d failures" % failures)
	await process_frame
	quit(1 if failures else 0)

func test_datasheet_facts_and_admission() -> void:
	var trazyn := Profiles.profile("trazyn-the-infinite")
	check(trazyn.get("source_datasheet_id") == "000000532", "Trazyn ID matches 000000532")
	check(trazyn.get("points_by_models") == {1: 60}, "Trazyn points are 60 for 1 model")
	check(trazyn.get("base_size_source_mm") == 25, "Trazyn base is 25 mm")
	check(trazyn.get("stats") == {"movement_inches": 5, "toughness": 5, "save_target": 2, "wounds": 6, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 4}, "Trazyn stats match source")
	for kw: String in ["NECRONS", "NOBLE", "EPIC HERO", "CHARACTER", "INFANTRY", "TRAZYN THE INFINITE"]:
		check(kw in trazyn.get("keywords", []), "Trazyn has %s keyword" % kw)
	check(trazyn.get("max_supported_copies") == 1, "Trazyn has max_supported_copies == 1")
	check(trazyn.get("ranged", []).is_empty(), "Trazyn has no ranged weapons")
	var melee: Array = trazyn.get("melee", [])
	check(melee.size() == 1 and melee[0].get("profiles", {}).get("standard", {}) == {"name": "Empathic Obliterator", "range_inches": 0.0, "attacks": 4, "skill": 2, "strength": 7, "ap": 0, "damage": "D3", "keywords": {"sustained-hits": "D3"}}, "Empathic Obliterator matches source")
	check(trazyn.get("source_bodyguard_datasheet_ids", []) == ["000000534", "000000536", "000000535"], "Trazyn bodyguard IDs match Warriors, Lychguard, Immortals")
	check(trazyn.get("unsupported_abilities", []).is_empty(), "Unsupported abilities cleared")
	check(trazyn.get("pending_source_checks", []).is_empty(), "Pending source checks empty")

	var res := Army.resolve("Necrons", TRAZYN_ID)
	check(res.get("error", "").is_empty(), "Trazyn resolves cleanly")
	check(int(res.get("cost", -1)) == 60 and int(res.get("models", -1)) == 1, "Cost is 60, models is 1")
	check(Reanimation.CHARACTER_WOUNDS.get(TRAZYN_ID) == 6, "Reanimation character wounds is 6")
	check(Reanimation.PROFILE_MODEL_COUNTS.get(TRAZYN_ID) == [1], "Reanimation profile model count is [1]")

func test_ancient_collector_sticky_objective() -> void:
	var state: Dictionary = F.P.initial_state({"unit_abilities": true, "reanimation_protocols": true, "combat_doctrines": false, "core_stratagems": true, "manual_allocation": false}, {
		1: {"schema_version": 2, "faction": "Necrons", "category": "custom", "points_limit": 1000, "entries": [
			{"definition_id": TRAZYN_ID, "models": 1, "copies": 1},
			{"definition_id": WARRIORS_ID, "models": 10, "copies": 1}
		]},
		2: {"schema_version": 2, "faction": "Space Marines", "category": "custom", "points_limit": 1000, "entries": [
			{"definition_id": MARINE_ID, "models": 5, "copies": 1}
		]}
	})
	if state.has("error"): return

	var trazyn_model := -1
	var warriors_squad := -1
	for m: int in state.units:
		var d := str(state.units[m].get("definition_id", ""))
		if d == TRAZYN_ID: trazyn_model = m
		elif d == WARRIORS_ID and warriors_squad < 0: warriors_squad = int(state.units[m].get("squad", -1))

	state.mission = {
		"objectives": [
			{"name": "Obj 1", "kind": "point", "position": Vector2(0.0, 0.0), "elevation": 0.0, "controller": 1, "secured": 0}
		]
	}
	# 1. Standalone Trazyn does not trigger Ancient Collector
	var orig_phase := str(state.phase)
	state.phase = "command"
	state.active = 1
	state.turn = 1
	state.units[trazyn_model].position = Vector2(0.0, 0.0)
	var standalone_note := TrazynTheInfinite.secure_controlled_objectives(state)
	check(standalone_note.is_empty() and int(state.mission.objectives[0].secured) == 0, "Standalone Trazyn does not secure objective")

	# 2. Attached as Leader to Warriors during setup -> secures objective at end of Command phase
	state.phase = orig_phase
	var attach_choices := UnitActions.choices(state, 1).filter(func(c: Dictionary) -> bool:
		return c.get("action", "") == "attach" and int(c.get("model", -1)) == trazyn_model and int(c.get("target", -1)) == warriors_squad
	)
	check(not attach_choices.is_empty(), "Trazyn can attach to Warriors")
	if not attach_choices.is_empty():
		UnitActions.apply(state, 1, attach_choices[0], Vector2.ZERO, Callable())
	state.phase = "command"
	for m: int in state.units:
		if int(state.units[m].get("squad", -1)) == warriors_squad:
			state.units[m].position = Vector2(0.0, 0.0)
	var attached_note := TrazynTheInfinite.secure_controlled_objectives(state)
	check(not attached_note.is_empty() and int(state.mission.objectives[0].secured) == 1, "Leading Trazyn secures controlled objective at end of Command phase")

func test_surrogate_hosts() -> void:
	var state: Dictionary = F.P.initial_state({"unit_abilities": true, "reanimation_protocols": true, "combat_doctrines": false, "core_stratagems": true, "manual_allocation": false}, {
		1: {"schema_version": 2, "faction": "Necrons", "category": "custom", "points_limit": 1000, "entries": [
			{"definition_id": TRAZYN_ID, "models": 1, "copies": 1},
			{"definition_id": OVERLORD_ID, "models": 1, "copies": 1},
			{"definition_id": SKORPEKH_LORD_ID, "models": 1, "copies": 1},
			{"definition_id": IMOTEKH_ID, "models": 1, "copies": 1},
			{"definition_id": WARRIORS_ID, "models": 10, "copies": 1}
		]},
		2: {"schema_version": 2, "faction": "Space Marines", "category": "custom", "points_limit": 1000, "entries": [
			{"definition_id": MARINE_ID, "models": 5, "copies": 1}
		]}
	})
	if state.has("error"): return

	var trazyn_model := -1
	var overlord_model := -1
	var skorpekh_lord_model := -1
	var imotekh_model := -1
	var warriors_squad := -1
	for m: int in state.units:
		var d := str(state.units[m].get("definition_id", ""))
		if d == TRAZYN_ID: trazyn_model = m
		elif d == OVERLORD_ID: overlord_model = m
		elif d == SKORPEKH_LORD_ID: skorpekh_lord_model = m
		elif d == IMOTEKH_ID: imotekh_model = m
		elif d == WARRIORS_ID and warriors_squad < 0: warriors_squad = int(state.units[m].get("squad", -1))

	# Attach Overlord to Warriors before battle
	var attach_overlord := UnitActions.choices(state, 1).filter(func(c: Dictionary) -> bool:
		return c.get("action", "") == "attach" and int(c.get("model", -1)) == overlord_model and int(c.get("target", -1)) == warriors_squad
	)
	check(not attach_overlord.is_empty(), "Overlord can attach to Warriors")
	if not attach_overlord.is_empty():
		UnitActions.apply(state, 1, attach_overlord[0], Vector2.ZERO, Callable())

	# Position models on battlefield
	state.units[trazyn_model].position = Vector2(-10.0, 0.0)
	state.units[trazyn_model].wounds = 4 # Damaged Trazyn should keep 4 wounds
	state.units[overlord_model].position = Vector2(12.0, 5.0)
	state.units[skorpekh_lord_model].position = Vector2(0.0, 10.0)
	state.units[imotekh_model].position = Vector2(0.0, -10.0)

	state.phase = "command"
	state.active = 1
	state.turn = 1
	UnitActions.reconcile(state)

	var choices := UnitActions.choices(state, 1)
	var surrogate_opts := choices.filter(func(c: Dictionary) -> bool: return c.get("action", "") == TrazynTheInfinite.SURROGATE_ACTION)
	check(surrogate_opts.size() == 1 and int(surrogate_opts[0].get("target", -1)) == overlord_model, "Only Overlord is eligible for Surrogate Hosts (Skorpekh Lord and Epic Hero Imotekh excluded)")

	var apply_res := UnitActions.apply(state, 1, surrogate_opts[0], Vector2.ZERO, Callable())
	check(str(apply_res.get("error", "")).is_empty(), "Surrogate Hosts applies cleanly")
	check(int(state.units[overlord_model].wounds) == 0 and not bool(state.units[overlord_model].on_battlefield), "Replaced Overlord is destroyed")
	check(state.units[trazyn_model].position == Vector2(12.0, 5.0), "Trazyn is placed at Overlord's position")
	check(int(state.units[trazyn_model].wounds) == 4, "Trazyn retains his remaining 4 wounds")
	check(int(state.units[trazyn_model].squad) == warriors_squad and str(state.units[trazyn_model].get("attachment_role", "")) == "leader", "Trazyn takes over as Leader of Overlord's Warriors unit")
	check(TrazynTheInfinite.surrogate_choices(state, 1).is_empty(), "Surrogate Hosts cannot be used twice in the same Command phase")
