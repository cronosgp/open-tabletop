extends SceneTree

const F = preload("res://tests/all_units_fixture.gd")
const Profiles = preload("res://scripts/edition_11/current_reference_necron_profiles.gd")
const Army = preload("res://scripts/edition_11/army_capabilities.gd")
const Reanimation = preload("res://scripts/edition_11/reanimation_protocols.gd")
const UnitActions = preload("res://scripts/edition_11/unit_actions.gd")
const TransportRules = preload("res://scripts/edition_11/transport_rules.gd")
const GhostArk = preload("res://scripts/edition_11/ghost_ark.gd")

const ARK_ID := "40kdc:11e:necrons:ghost-ark"
const WARRIORS_ID := "40kdc:11e:necrons:necron-warriors"
const IMMORTALS_ID := "40kdc:11e:necrons:immortals"
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
	test_transport_capacity_and_restrictions()
	test_repair_barge()
	print("Necron Ghost Ark checks: %d failures" % failures)
	await process_frame
	quit(1 if failures else 0)

func test_datasheet_facts_and_admission() -> void:
	var ark := Profiles.profile("ghost-ark")
	check(ark.get("source_datasheet_id") == "000000543", "Ghost Ark ID matches 000000543")
	check(ark.get("points_by_models") == {1: 100}, "Points are 100 for 1 model")
	check(ark.get("base_size_source_mm") == 60, "Base size is 60 mm")
	check(ark.get("stats") == {"movement_inches": 10, "toughness": 9, "save_target": 3, "wounds": 14, "leadership_target": 7, "objective_control": 3, "invulnerable_target": 4}, "Stats match source")
	for kw: String in ["NECRONS", "VEHICLE", "FLY", "FRAME", "TRANSPORT", "GHOST ARK", "DEDICATED TRANSPORT"]:
		check(kw in ark.get("keywords", []), "Has %s keyword" % kw)
	check(ark.get("unsupported_abilities", []).is_empty(), "Unsupported abilities cleared")
	check(ark.get("pending_source_checks", []).is_empty(), "Pending source checks empty")

	var res := Army.resolve("Necrons", ARK_ID)
	check(res.get("error", "").is_empty() and int(res.get("cost", -1)) == 100 and int(res.get("models", -1)) == 1, "Resolves to 1 model for 100")
	check(Reanimation.PROFILE_MODEL_COUNTS.get(ARK_ID) == [1], "Reanimation profile model count is [1]")

func test_transport_capacity_and_restrictions() -> void:
	var state: Dictionary = F.P.initial_state({"unit_abilities": true, "reanimation_protocols": true, "combat_doctrines": false, "core_stratagems": true, "manual_allocation": false}, {
		1: {"schema_version": 2, "faction": "Necrons", "category": "custom", "points_limit": 1000, "entries": [
			{"definition_id": ARK_ID, "models": 1, "copies": 1},
			{"definition_id": WARRIORS_ID, "models": 10, "copies": 1},
			{"definition_id": IMMORTALS_ID, "models": 5, "copies": 1}
		]},
		2: {"schema_version": 2, "faction": "Space Marines", "category": "custom", "points_limit": 1000, "entries": [
			{"definition_id": MARINE_ID, "models": 5, "copies": 1}
		]}
	})
	if state.has("error"):
		check(false, "Initial state failed: %s" % state.error)
		return
	var ark_model := -1
	var warriors_squad := -1
	var immortals_squad := -1
	for m: int in state.units:
		var did := str(state.units[m].get("definition_id", ""))
		if did == ARK_ID: ark_model = m
		elif did == WARRIORS_ID: warriors_squad = int(state.units[m].squad)
		elif did == IMMORTALS_ID: immortals_squad = int(state.units[m].squad)
	check(TransportRules.is_transport(state, ark_model), "Ghost Ark is a recognized transport")
	check(TransportRules.eligibility_error(state, ark_model, warriors_squad).is_empty(), "10 Necron Warriors can embark in Ghost Ark")
	check(not TransportRules.eligibility_error(state, ark_model, immortals_squad).is_empty(), "Immortals cannot embark in Ghost Ark")
	var start_err := TransportRules.start_embark(state, 1, ark_model, warriors_squad)
	check(start_err.is_empty(), "Necron Warriors start embarked cleanly (err=%s)" % start_err)
	check(TransportRules.squad_embarked(state, warriors_squad), "Warriors marked embarked")

func test_repair_barge() -> void:
	var state: Dictionary = F.P.initial_state({"unit_abilities": true, "reanimation_protocols": true, "combat_doctrines": false, "core_stratagems": true, "manual_allocation": false}, {
		1: {"schema_version": 2, "faction": "Necrons", "category": "custom", "points_limit": 1000, "entries": [
			{"definition_id": ARK_ID, "models": 1, "copies": 1},
			{"definition_id": WARRIORS_ID, "models": 10, "copies": 1}
		]},
		2: {"schema_version": 2, "faction": "Space Marines", "category": "custom", "points_limit": 1000, "entries": [
			{"definition_id": MARINE_ID, "models": 5, "copies": 1}
		]}
	})
	if state.has("error"):
		check(false, "Initial state failed: %s" % state.error)
		return
	var ark_model := -1
	var warriors_models: Array[int] = []
	var marine_squad := -1
	for m: int in state.units:
		var did := str(state.units[m].get("definition_id", ""))
		if did == ARK_ID: ark_model = m
		elif did == WARRIORS_ID: warriors_models.append(m)
		elif int(state.units[m].owner) == 2: marine_squad = int(state.units[m].squad)
	warriors_models.sort()
	var warriors_squad := int(state.units[warriors_models[0]].squad)
	state.units[ark_model].position = Vector2(10.0, 10.0)
	for i in range(warriors_models.size()):
		state.units[warriors_models[i]].position = Vector2(12.5 + (i % 5) * 0.5, 10.0 + floori(float(i) / 5.0) * 0.5)
	# Kill 2 Warriors as if enemy Marine squad just attacked
	state.units[warriors_models[0]].wounds = 0
	state.units[warriors_models[1]].wounds = 0
	state.phase = "shooting"
	state.turn = 1
	state.active = 2
	state.active_player = 2

	var opened := GhostArk.open_after_enemy_attacks(state, marine_squad, [{"target_squad": warriors_squad, "damage": 2, "models_destroyed": 2, "allocations": []}])
	check(opened, "Repair Barge opens after enemy unit finishes attacks within 3\"")
	var choices := UnitActions.choices(state, 1)
	var use_opt := choices.filter(func(c: Dictionary) -> bool: return c.get("action", "") == "ghost-ark-repair-barge-use")
	check(use_opt.size() == 1, "Repair Barge offers Reanimation Protocols for wounded Necron Warriors")
	scripted_dice = [4, 4]
	var res := UnitActions.apply(state, 1, use_opt[0], Vector2.ZERO, Callable(self, "scripted_roller"))
	check(res.get("error", "").is_empty(), "Repair Barge Reanimation roll succeeded: %s" % str(res.get("error", "")))
	# Confirm / finish pending reanimation placement if needed
	for _step in range(6):
		var c := UnitActions.choices(state, 1)
		if c.is_empty(): break
		var confirm := c.filter(func(x: Dictionary) -> bool: return x.get("action", "") == "reanimation-confirm" or x.get("action", "") == "reanimation-accept")
		if not confirm.is_empty():
			UnitActions.apply(state, 1, confirm[0], Vector2.ZERO, Callable(self, "scripted_roller"))
		else:
			UnitActions.apply(state, 1, c[0], Vector2(12.5, 10.0), Callable(self, "scripted_roller"))
	# Cannot trigger a second time this turn
	var opened_again := GhostArk.open_after_enemy_attacks(state, marine_squad, [{"target_squad": warriors_squad, "damage": 1, "models_destroyed": 1, "allocations": []}])
	check(not opened_again, "Repair Barge cannot be used twice in the same turn")
