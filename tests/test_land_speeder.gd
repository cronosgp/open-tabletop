extends SceneTree
const F = preload("res://tests/all_units_fixture.gd")
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Catalog = preload("res://scripts/edition_11/army_capabilities.gd")
const Roster = preload("res://scripts/edition_11/roster_validation.gd")
const Purgation = preload("res://scripts/edition_11/purgation_run.gd")
const C = F.C
var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func squad(state: Dictionary, identity: String) -> int:
	for model: int in state.units:
		if C.UnitAbilities.identity(state.units[model]) == identity: return int(state.units[model].squad)
	return -1

func _initialize() -> void: call_deferred("run")

func run() -> void:
	var profile := Profiles.profile("land-speeder")
	check(profile.get("source_book_id") == "000000139" and profile.get("source_datasheet_id") == "000002711" and profile.get("source_export_updated_at") == "2026-10-16T21:03:46+03:00", "Land Speeder cites the pinned local Wahapedia e11 datasheet")
	check(profile.points_by_models == {1: 105} and profile.models == 1 and is_equal_approx(profile.base_radius_inches, 52.5 / 25.4), "Land Speeder composition, cost and documented oval-base proxy are represented")
	check(profile.stats == {"movement_inches": 14, "toughness": 8, "save_target": 3, "wounds": 9, "leadership_target": 6, "objective_control": 3, "invulnerable_target": 0}, "Land Speeder characteristics match the local rows")
	check(profile.ranged.map(func(w: Dictionary) -> String: return w.id) == ["multi-melta", "onslaught-gatling-cannon", "stormfury-missile-launcher"] and profile.melee[0].id == "armoured-impact", "Land Speeder fixed weapons match the extracted loadout")
	check(profile.ranged[0].profiles.standard.keywords == {"melta": 3} and profile.ranged[1].profiles.standard.attacks == 8 and profile.ranged[1].profiles.standard.target_restricted_traits == {"devastating-wounds": ["MONSTER", "VEHICLE"]} and profile.ranged[2].profiles.standard.damage == "D3+3", "Melta, restricted Devastating Wounds and missile Damage are represented")
	check(profile.additional_weapon_profiles.ranged[0].id == "pyrecannon" and profile.additional_weapon_profiles.ranged[0].profiles.standard.keywords == {"blast": 2, "torrent": true}, "Pyrecannon replacement profile preserves Blast 2 and Torrent")
	check(Catalog.SPECS.has("land-speeder") and Roster.POINTS["land-speeder"].sizes == {1: 105}, "Land Speeder enters local roster admission at the extracted cost")
	var lists := F.selections()
	lists[1].entries.append({"definition_id": "40kdc:11e:adeptus-astartes:land-speeder", "models": 1, "copies": 1})
	var state := F.P.initial_state({"checked_rosters": true, "official_mission": true, "unit_abilities": true, "combat_doctrines": true, "reanimation_protocols": true, "awakened_dynasty": true, "core_stratagems": true, "manual_allocation": false}, lists)
	check(not state.has("error"), "Land Speeder selection materializes in local runtime")
	if state.has("error"):
		print(state)
		quit(1)
		return
	var setup_speeder := squad(state, "land-speeder")
	var setup_model := C.living(state, setup_speeder)[0]
	var pyrecannon_result: Dictionary = C.UnitActions.apply(state, 1, {"action": "land-speeder-cannon", "model": setup_model, "target": setup_speeder, "value": "pyrecannon"}, Vector2.ZERO, func() -> int: return 1)
	var has_pyrecannon: bool = state.units[setup_model].ranged_weapons.any(func(w: Dictionary) -> bool: return w.id == "pyrecannon") and not state.units[setup_model].ranged_weapons.any(func(w: Dictionary) -> bool: return w.id == "onslaught-gatling-cannon")
	var onslaught_result: Dictionary = C.UnitActions.apply(state, 1, {"action": "land-speeder-cannon", "model": setup_model, "target": setup_speeder, "value": "onslaught"}, Vector2.ZERO, func() -> int: return 1)
	var has_onslaught: bool = state.units[setup_model].ranged_weapons.any(func(w: Dictionary) -> bool: return w.id == "onslaught-gatling-cannon") and not state.units[setup_model].ranged_weapons.any(func(w: Dictionary) -> bool: return w.id == "pyrecannon")
	check(pyrecannon_result.error.is_empty() and has_pyrecannon and onslaught_result.error.is_empty() and has_onslaught, "Army preparation can swap the Onslaught Gatling Cannon for Pyrecannon and restore it")
	state.phase = "shooting"
	state.turn = 3
	state.active = 1
	state.unit_abilities.setup_players = [1, 2]
	state.unit_abilities.battle_players = [1, 2]
	state.awakened_dynasty.pending = []
	state.deployment.complete = true
	state.mission.stage = "battle"
	state.unit_abilities.window = {}
	state.stratagems.attack_rerolls = false
	var speeder := squad(state, "land-speeder")
	var target := squad(state, "necron-warriors")
	var model := C.living(state, speeder)[0]
	for id: int in state.units: state.units[id].position = Vector2(-18, -14) if state.units[id].owner == 1 else Vector2(18, 14)
	state.units[model].position = Vector2.ZERO
	for id: int in C.living(state, target): state.units[id].position = Vector2(20, 0)
	check(C.UnitAbilities.has(state, speeder, "deep-strike") and C.UnitAbilities.has(state, speeder, "purgation-run"), "Deep Strike and Purgation Run materialize on the Land Speeder")
	var enemy: int = C.living(state, target)[0]
	state.units[enemy].keywords.append("VEHICLE")
	var restricted: Dictionary = C.UnitAbilities.weapon(state, model, target, profile.ranged[1].profiles.standard, false)
	check(not restricted.keywords.has("devastating-wounds"), "Onslaught Gatling Cannon suppresses Devastating Wounds against VEHICLE")
	state.units[enemy].keywords.erase("VEHICLE")
	var unrestricted: Dictionary = C.UnitAbilities.weapon(state, model, target, profile.ranged[1].profiles.standard, false)
	check(unrestricted.keywords.has("devastating-wounds"), "Onslaught Gatling Cannon retains Devastating Wounds against other targets")
	var attack := C.resolve_attack_plan(state, 1, model, [{"model": model, "target": target, "amount": 1, "weapon": "multi-melta", "profile": "standard"}], state.revision, false, true, func() -> int: return 1)
	check(attack.error.is_empty() and state.squads[speeder].shot and state.unit_abilities.window.get("kind", "") == Purgation.WINDOW, "Completing the Land Speeder shooting action opens the Purgation Run decision")
	var use: Dictionary = C.unit_choices(state, 1).filter(func(choice: Dictionary) -> bool: return choice.action == "purgation-use")[0]
	var use_error := C.unit_action(state, 1, use, Vector2.ZERO, state.revision, func() -> int: return 3)
	check(use_error.is_empty() and state.unit_abilities.window.get("kind", "") == Purgation.PLACEMENT and int(state.unit_abilities.window.distance) == 3 and C.Actions.charge_blocked(state, speeder), "Using Purgation Run rolls D6, opens movement placement and blocks charging this turn")
	var place: Dictionary = C.unit_choices(state, 1).filter(func(choice: Dictionary) -> bool: return choice.action == "purgation-place")[0]
	var destination := Vector2.ZERO
	for candidate: Vector2 in [Vector2(2, 0), Vector2(-2, 0), Vector2(0, 2), Vector2(0, -2), Vector2(1.5, 1.5), Vector2(-1.5, -1.5)]:
		if Purgation.position_error(state, model, candidate).is_empty():
			destination = candidate
			break
	var placement_error := C.unit_action(state, 1, place, destination, state.revision)
	var confirm: Dictionary = C.unit_choices(state, 1).filter(func(choice: Dictionary) -> bool: return choice.action == "purgation-confirm")[0]
	var confirm_error := C.unit_action(state, 1, confirm, Vector2.ZERO, state.revision)
	check(placement_error.is_empty() and confirm_error.is_empty() and state.units[model].position.is_equal_approx(destination) and destination != Vector2.ZERO and state.squads[speeder].moved_distance <= 3.0 and state.squads[speeder].move_type == "normal", "Purgation Run confirms a legal Normal Move within the rolled distance")
	state.turn += 1
	check(not C.Actions.charge_blocked(state, speeder), "Purgation Run charge restriction expires after the turn")
	print("Current Land Speeder checks: %d failures" % failures)
	quit(1 if failures else 0)
