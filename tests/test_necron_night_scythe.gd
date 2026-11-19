extends SceneTree

const F = preload("res://tests/all_units_fixture.gd")
const Profiles = preload("res://scripts/edition_11/current_reference_necron_profiles.gd")
const Army = preload("res://scripts/edition_11/army_capabilities.gd")
const Reanimation = preload("res://scripts/edition_11/reanimation_protocols.gd")
const UnitActions = preload("res://scripts/edition_11/unit_actions.gd")
const TransportRules = preload("res://scripts/edition_11/transport_rules.gd")
const NightScythe = preload("res://scripts/edition_11/night_scythe.gd")

const SCYTHE_ID := "40kdc:11e:necrons:night-scythe"
const IMMORTALS_ID := "40kdc:11e:necrons:immortals"
const WRAITHS_ID := "40kdc:11e:necrons:canoptek-wraiths"
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
	test_transport_quantum_invader_and_invasion_beams()
	print("Necron Night Scythe checks: %d failures" % failures)
	await process_frame
	quit(1 if failures else 0)

func test_datasheet_facts_and_admission() -> void:
	var ns := Profiles.profile("night-scythe")
	check(ns.get("source_datasheet_id") == "000000544", "Night Scythe ID matches 000000544")
	check(ns.get("points_by_models") == {1: 125}, "Points are 125 for 1 model")
	check(ns.get("base_size_source_mm") == 92, "Base size is 92 mm (120x92mm flying base)")
	check(ns.get("stats") == {"movement_inches": 14, "toughness": 9, "save_target": 3, "wounds": 12, "leadership_target": 7, "objective_control": 0, "invulnerable_target": 0}, "Stats match source")
	for kw: String in ["NECRONS", "VEHICLE", "FLY", "TRANSPORT", "NIGHT SCYTHE"]:
		check(kw in ns.get("keywords", []), "Has %s keyword" % kw)
	check(ns.get("unsupported_abilities", []).is_empty(), "Unsupported abilities cleared")
	check(ns.get("pending_source_checks", []).is_empty(), "Pending source checks empty")

	var res := Army.resolve("Necrons", SCYTHE_ID)
	check(res.get("error", "").is_empty() and int(res.get("cost", -1)) == 125 and int(res.get("models", -1)) == 1, "Resolves to 1 model for 125")
	check(Reanimation.PROFILE_MODEL_COUNTS.get(SCYTHE_ID) == [1], "Reanimation profile model count is [1]")

func test_transport_quantum_invader_and_invasion_beams() -> void:
	var state: Dictionary = F.P.initial_state({"unit_abilities": true, "reanimation_protocols": true, "combat_doctrines": false, "core_stratagems": true, "manual_allocation": false}, {
		1: {"schema_version": 2, "faction": "Necrons", "category": "custom", "points_limit": 1000, "entries": [
			{"definition_id": SCYTHE_ID, "models": 1, "copies": 1},
			{"definition_id": IMMORTALS_ID, "models": 5, "copies": 1},
			{"definition_id": WRAITHS_ID, "models": 3, "copies": 1}
		]},
		2: {"schema_version": 2, "faction": "Space Marines", "category": "custom", "points_limit": 1000, "entries": [
			{"definition_id": MARINE_ID, "models": 5, "copies": 1}
		]}
	})
	if state.has("error"):
		check(false, "Initial state failed: %s" % state.error)
		return
	var ns_model := -1
	var ns_squad := -1
	var imm_models: Array[int] = []
	var wraith_squad := -1
	for m: int in state.units:
		var did := str(state.units[m].get("definition_id", ""))
		if did == SCYTHE_ID:
			ns_model = m
			ns_squad = int(state.units[m].squad)
		elif did == IMMORTALS_ID:
			imm_models.append(m)
		elif did == WRAITHS_ID:
			wraith_squad = int(state.units[m].squad)
		elif int(state.units[m].owner) == 2:
			state.units[m].position = Vector2(30.0, 20.0)
	imm_models.sort()
	var imm_squad := int(state.units[imm_models[0]].squad)

	# Transport eligibility: 1 Necrons Infantry unit allowed, Beasts (Wraiths) forbidden
	check(TransportRules.is_transport(state, ns_model), "Night Scythe is a recognized transport")
	check(TransportRules.eligibility_error(state, ns_model, imm_squad).is_empty(), "Immortals (Necrons Infantry) can embark in Night Scythe")
	check(not TransportRules.eligibility_error(state, ns_model, wraith_squad).is_empty(), "Wraiths (Beasts) cannot embark in Night Scythe")

	# Quantum Invader: ingress allowed in round 1
	state.round = 1
	check(UnitActions.ingress_round_allowed(state, ns_squad), "Quantum Invader allows Reserves ingress in battle round 1")
	state.round = 3
	check(UnitActions.ingress_round_allowed(state, ns_squad), "Quantum Invader allows Reserves ingress in battle round 3")

	# Invasion Beams: end of Fight phase embark wholly within 6"
	state.units[ns_model].position = Vector2(10.0, 10.0)
	for i in range(imm_models.size()):
		state.units[imm_models[i]].position = Vector2(12.0 + i * 0.6, 10.0)
	state.phase = "fight"
	state.turn = 1
	state.active = 1
	var choices := NightScythe.invasion_beams_choices(state, 1)
	check(choices.size() == 1 and int(choices[0].get("target", -1)) == imm_squad, "Invasion Beams offers embarking nearby unengaged Immortals at end of Fight phase")
	var res := NightScythe.apply_invasion_beams(state, 1, choices[0])
	check(res.get("error", "").is_empty(), "Invasion Beams embark succeeded")
	check(TransportRules.squad_embarked(state, imm_squad), "Immortals are now embarked inside Night Scythe")
	check(NightScythe.invasion_beams_choices(state, 1).is_empty(), "Invasion Beams no longer available once Night Scythe is occupied")
