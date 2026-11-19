extends SceneTree

const F = preload("res://tests/all_units_fixture.gd")
const Profiles = preload("res://scripts/edition_11/current_reference_necron_profiles.gd")
const Army = preload("res://scripts/edition_11/army_capabilities.gd")
const Reanimation = preload("res://scripts/edition_11/reanimation_protocols.gd")
const UnitAbilities = preload("res://scripts/edition_11/unit_abilities.gd")
const UnitActions = preload("res://scripts/edition_11/unit_actions.gd")
const Morale = preload("res://scripts/edition_11/morale.gd")
const SilentKing = preload("res://scripts/edition_11/silent_king.gd")
const RosterValidation = preload("res://scripts/edition_11/roster_validation.gd")

const SK_ID := "40kdc:11e:necrons:the-silent-king"
const WARRIORS_ID := "40kdc:11e:necrons:necron-warriors"
const OVERLORD_ID := "40kdc:11e:necrons:overlord"
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
	test_composite_unit_auras_damaged_and_menhirs()
	print("Necron The Silent King checks: %d failures" % failures)
	await process_frame
	quit(1 if failures else 0)

func test_datasheet_facts_and_admission() -> void:
	var sk := Profiles.profile("the-silent-king")
	check(sk.get("source_datasheet_id") == "000002360", "The Silent King ID matches 000002360")
	check(sk.get("points_by_models") == {3: 420}, "Points are 420 for 3 models")
	check(sk.get("base_size_source_mm") == 100, "Szarekh base size is 100 mm")
	check(sk.get("unsupported_abilities", []).is_empty(), "Unsupported abilities cleared")
	check(sk.get("pending_source_checks", []).is_empty(), "Pending source checks empty")

	var res := Army.resolve("Necrons", SK_ID)
	check(res.get("error", "").is_empty() and int(res.get("cost", -1)) == 420 and int(res.get("models", -1)) == 3, "Resolves to 3 models for 420")
	check(Reanimation.PROFILE_MODEL_COUNTS.get(SK_ID) == [3], "Reanimation profile model count is [3]")

func test_composite_unit_auras_damaged_and_menhirs() -> void:
	var state: Dictionary = F.P.initial_state({"unit_abilities": true, "reanimation_protocols": true, "combat_doctrines": false, "core_stratagems": true, "manual_allocation": false}, {
		1: {"schema_version": 2, "faction": "Necrons", "category": "custom", "points_limit": 1000, "entries": [
			{"definition_id": SK_ID, "models": 3, "copies": 1},
			{"definition_id": OVERLORD_ID, "models": 1, "copies": 1},
			{"definition_id": WARRIORS_ID, "models": 10, "copies": 1}
		]},
		2: {"schema_version": 2, "faction": "Space Marines", "category": "custom", "points_limit": 1000, "entries": [
			{"definition_id": MARINE_ID, "models": 5, "copies": 1}
		]}
	})
	if state.has("error"):
		check(false, "Initial state failed: %s" % state.error)
		return
	var szarekh := -1
	var menhirs: Array[int] = []
	var overlord := -1
	var warriors_squad := -1
	for m: int in state.units:
		var u: Dictionary = state.units[m]
		var did := str(u.get("definition_id", ""))
		if did == SK_ID:
			if str(u.get("silent_king_role", "")) == "szarekh": szarekh = m
			else: menhirs.append(m)
		elif did == OVERLORD_ID:
			overlord = m
		elif did == WARRIORS_ID:
			warriors_squad = int(u.squad)
		elif int(u.owner) == 2:
			u.position = Vector2(30.0, 20.0)
	menhirs.sort()
	check(szarekh >= 0 and menhirs.size() == 2, "Spawned 1 Szarekh and 2 Triarchal Menhirs")
	check(int(state.units[szarekh].wounds) == 16 and int(state.units[menhirs[0]].wounds) == 5, "Szarekh has 16W and Menhirs have 5W")
	check(UnitAbilities.deadly_demise_value(state, szarekh) == "D6+3" and UnitAbilities.deadly_demise_value(state, menhirs[0]) == null, "Deadly Demise D6+3 applies to Szarekh model only")

	# Position Szarekh and Warriors within 6"
	state.units[szarekh].position = Vector2(10.0, 10.0)
	state.units[menhirs[0]].position = Vector2(11.5, 10.0)
	state.units[menhirs[1]].position = Vector2(8.5, 10.0)
	for m: int in state.units:
		if int(state.units[m].squad) == warriors_squad:
			state.units[m].position = Vector2(12.5, 10.0)

	# SUPREME COMMANDER: Overlord cannot be Warlord while Silent King is in army
	RosterValidation.enable(state, {1: {"construction": {}}, 2: {"construction": {}}})
	state.unit_abilities.warlords = {1: overlord}
	check(not RosterValidation.seal(state, 1).is_empty(), "SUPREME COMMANDER rejects non-Silent King Warlord")
	state.unit_abilities.warlords = {1: szarekh}
	check(RosterValidation.seal(state, 1).is_empty(), "SUPREME COMMANDER accepts Szarekh as Warlord")

	# The Silent King Ld aura (+1 Ld -> target -1, Warriors 7+ -> 6+)
	var ld_res := Morale.leadership(state, warriors_squad)
	check(int(ld_res.get("target", -1)) == 6, "The Silent King improves friendly Necrons Leadership within 6\" from 7+ to 6+ (got %s)" % str(ld_res))

	# Triarch Abilities in Command phase
	state.phase = "command"
	state.round = 1
	state.active = 1
	state.unit_abilities.window = {"kind": "start", "owners": [1]}
	var triarch := UnitActions.choices(state, 1).filter(func(c: Dictionary) -> bool: return c.get("action", "") == "silent-king-triarch")
	check(triarch.size() == 3, "Command phase offers all 3 Triarch Abilities")
	for c: Dictionary in triarch:
		if str(c.get("value", "")) == "relentless-march":
			UnitActions.apply(state, 1, c, Vector2.ZERO, Callable())
			break
	check(SilentKing.movement_bonus(state, warriors_squad) == 2.0, "Relentless March grants +2\" Move within 6\"")

	# Round 2: switch to Phaeron of the Blades (+1S melee & Charge reroll)
	state.round = 2
	var triarch2 := UnitActions.choices(state, 1).filter(func(c: Dictionary) -> bool: return c.get("action", "") == "silent-king-triarch")
	for c: Dictionary in triarch2:
		if str(c.get("value", "")) == "phaeron-of-the-blades":
			UnitActions.apply(state, 1, c, Vector2.ZERO, Callable())
			break
	check(SilentKing.blades_aura_active(state, warriors_squad) and SilentKing.charge_reroll_active(state, warriors_squad), "Phaeron of the Blades active in round 2")

	# Damaged 1-6: Szarekh at 6W -> -1 Hit and halved melee attacks (12 -> 6)
	state.units[szarekh].wounds = 6
	check(UnitAbilities.damaged_attack_penalty(state, szarekh) == -1 and UnitAbilities.damaged_attack_penalty(state, menhirs[0]) == -1, "Damaged 1-6 applies -1 Hit to entire unit")
	var melee_count := UnitAbilities.melee_attack_count(state, szarekh, state.units[szarekh].melee_weapons[0].profiles.standard)
	check(melee_count == 6, "Damaged 1-6 halves Szarekh's melee attacks from 12 to 6 (got %d)" % melee_count)

	# TRIARCHAL MENHIRS: destroying Szarekh destroys remaining Menhirs
	state.units[szarekh].wounds = 0
	var extra := SilentKing.enforce_menhirs(state, [szarekh])
	check(extra.size() == 2 and int(state.units[menhirs[0]].wounds) == 0 and int(state.units[menhirs[1]].wounds) == 0, "Destroying Szarekh destroys remaining Triarchal Menhirs")
