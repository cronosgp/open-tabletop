extends SceneTree

const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Catalog = preload("res://scripts/edition_11/army_capabilities.gd")
const Roster = preload("res://scripts/edition_11/roster_validation.gd")
const AircraftRules = preload("res://scripts/edition_11/aircraft_rules.gd")
const ContactActions = preload("res://scripts/edition_11/contact_actions.gd")
const HeresyRetribution = preload("res://scripts/edition_11/heresy_retribution.gd")
const MovementRules = preload("res://scripts/rules.gd")
const PublicUnitCommand = preload("res://tests/public_unit_command.gd")
const UNIT := "nephilim-jetfighter"
const UNIT_ID := "40kdc:11e:adeptus-astartes:nephilim-jetfighter"
const A = C.UnitAbilities
const U = C.UnitActions

var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func selection() -> Dictionary:
	var result := F.current_marine_selections()
	result[1].entries.append({"definition_id": UNIT_ID, "models": 1, "copies": 1})
	return result

func prepared() -> Dictionary:
	var options := {
		"checked_rosters": false, "official_mission": false, "unit_abilities": true,
		"combat_doctrines": true, "core_stratagems": true, "attack_rerolls": true,
		"manual_allocation": false, "marine_chapters": {1: "DARK ANGELS"}
	}
	var state: Dictionary = F.P.initial_state(options, selection())
	if state.has("error"): return state
	state.phase = "deployment"
	state.active = 1
	return state

func models(state: Dictionary, identity: String, owner: int) -> Array[int]:
	var result: Array[int] = []
	for model: int in state.get("units", {}):
		var unit: Dictionary = state.units[model]
		if int(unit.get("owner", -1)) == owner and A.identity(unit) == identity: result.append(model)
	result.sort()
	return result

func choice_for(state: Dictionary, player: int, action: String, model: int = -1, target: int = -1, value: String = "") -> Dictionary:
	for option: Dictionary in U.choices(state, player):
		if str(option.get("action", "")) == action and int(option.get("model", -1)) == model and int(option.get("target", -1)) == target and str(option.get("value", "")) == value:
			return option
	return {}

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var profile := Profiles.profile(UNIT)
	check(profile.get("source_book_id") == "000000023" and profile.get("source_datasheet_id") == "000000239", "The profile identifies Nephilim Jetfighter in the Dark Angels App")
	check(profile.get("points_by_models", {}) == {1: 200} and profile.get("models") == 1 and profile.get("max_supported_copies") == 3, "The source composition, price and local copy cap are recorded")
	check(profile.get("base_size_source_mm", []) == [120, 92] and profile.get("base_geometry", "") == "oval" and str(profile.get("geometry_scope", "")).contains("60 mm bounding-circle proxy"), "The 120 by 92 mm oval is identified and the proxy footprint is labelled")
	check(profile.get("stats", {}) == {"movement_inches": 0, "toughness": 8, "save_target": 3, "wounds": 11, "leadership_target": 6, "objective_control": 0, "invulnerable_target": 5}, "The fixed Aircraft characteristics match the local export")
	check(profile.get("keywords", []) == ["ADEPTUS ASTARTES", "DARK ANGELS", "VEHICLE", "AIRCRAFT", "RAVENWING", "FLY", "IMPERIUM"], "All seven datasheet keywords are represented")
	var weapons: Array = profile.get("ranged", [])
	check(weapons.size() == 3 and weapons.any(func(row: Dictionary) -> bool: return row.get("id", "") == "avenger-mega-bolter" and row.profiles.standard == {"name": "Avenger Mega Bolter", "range_inches": 36.0, "attacks": 10, "skill": 3, "strength": 5, "ap": -1, "damage": 2, "keywords": {"sustained-hits": 1}}), "Avenger Mega Bolter profile and Sustained Hits match the export")
	check(weapons.any(func(row: Dictionary) -> bool: return row.get("id", "") == "blacksword-missiles" and row.profiles.standard == {"name": "Blacksword Missiles", "range_inches": 36.0, "attacks": 2, "skill": 3, "strength": 8, "ap": -2, "damage": "D3+2", "keywords": {"anti-fly": 2}}), "Blacksword Missiles retain their Anti-Fly 2+ profile")
	check(weapons.any(func(row: Dictionary) -> bool: return row.get("id", "") == "twin-heavy-bolter" and row.profiles.standard.keywords == {"twin-linked": true, "rapid-fire": 2, "sustained-hits": 1}), "The Twin Heavy Bolter retains all three weapon abilities")
	check(profile.get("additional_weapon_profiles", {}).get("ranged", []).size() == 1 and profile.additional_weapon_profiles.ranged[0].profiles.standard == {"name": "Nephilim Lascannons", "range_inches": 48.0, "attacks": 2, "skill": 3, "strength": 12, "ap": -3, "damage": "D3+3", "keywords": {}}, "The replacement Lascannons profile matches the export")
	check(profile.get("melee", []).size() == 1 and profile.melee[0].profiles.standard == {"name": "Armoured Hull", "range_inches": 0.0, "attacks": 3, "skill": 4, "strength": 6, "ap": 0, "damage": 1, "keywords": {}}, "Armoured Hull matches the export")
	check(Catalog.SPECS.get(UNIT, {}).get("validation_status", "") == "source_bounded_local_scope_passed_2026_10_28", "Admission status matches the scoped local checks")
	check(Catalog.current_catalog_choice({"id": UNIT_ID, "edition": "11e", "faction": "Space Marines"}).get("options", []) == [{"models": 1, "cost": 200}], "The consolidated local catalog exposes the 200-point choice")
	check(Roster.POINTS.get(UNIT, {}).get("sizes", {}) == {1: 200}, "Roster validation shares the source points")
	var allowed := Catalog.admit({"schema_version": 2, "faction": "Space Marines", "category": "custom", "points_limit": 3000, "entries": [{"definition_id": UNIT_ID, "models": 1, "copies": 3}]})
	var excess := Catalog.admit({"schema_version": 2, "faction": "Space Marines", "category": "custom", "points_limit": 3000, "entries": [{"definition_id": UNIT_ID, "models": 1, "copies": 4}]})
	check(allowed.get("error", "").is_empty() and int(allowed.get("total", -1)) == 600 and not str(excess.get("error", "")).is_empty(), "The catalog accepts three copies and rejects a fourth")

	var state := prepared()
	check(not state.has("error"), "The admitted Nephilim materializes in a current-catalog match: %s" % str(state.get("error", "")))
	if state.has("error"):
		print("Nephilim Jetfighter checks: %d failures" % (failures + 1))
		quit(1)
		return
	var aircraft_models := models(state, UNIT, 1)
	check(aircraft_models.size() == 1, "The match contains one Nephilim Jetfighter")
	if aircraft_models.is_empty():
		print("Nephilim Jetfighter checks: %d failures" % (failures + 1))
		quit(1)
		return
	var model: int = aircraft_models[0]
	var squad := int(state.units[model].squad)
	check(A.has(state, squad, "damaged-3") and A.has(state, squad, "deadly-demise-d3") and A.deadly_demise_value(state, model) == "D3" and A.has(state, squad, "combat-doctrines") and A.has(state, squad, "lightning-fast-manoeuvres"), "Damaged 3, Deadly Demise D3, Combat Doctrines and Lightning-fast Manoeuvres are registered")
	check(A.damaged_attack_penalty(state, model) == 0, "Damaged 3 does not penalize a full-health model")
	state.units[model].wounds = 3
	check(A.damaged_attack_penalty(state, model) == -1, "Damaged 3 penalizes attacks at three remaining wounds")
	state.units[model].wounds = 4
	check(A.damaged_attack_penalty(state, model) == 0, "Damaged 3 ends above the three-wound threshold")
	check(A.defensive_wound_modifier(state, squad, 4, 8, false) == -1 and A.defensive_wound_modifier(state, squad, 16, 8, false) == -1, "Lightning-fast Manoeuvres subtracts one from ranged Wound rolls at any Strength")
	check(A.defensive_wound_modifier(state, squad, 16, 8, true) == 0, "Lightning-fast Manoeuvres does not modify melee Wound rolls")

	var loadout_choice := choice_for(state, 1, "nephilim-jetfighter-loadout", model, squad, "lascannons")
	var loadout_result := C.unit_action(state, 1, loadout_choice, Vector2.ZERO, state.revision)
	check(not loadout_choice.is_empty() and loadout_result.is_empty() and state.units[model].get("nephilim_lascannons", false), "Army preparation accepts the Nephilim Lascannons replacement")
	check(state.units[model].ranged_weapons.size() == 3 and state.units[model].ranged_weapons.any(func(item: Dictionary) -> bool: return item.get("id", "") == "nephilim-lascannons"), "The replacement swaps Twin Heavy Bolter for Nephilim Lascannons")
	var restore_choice := choice_for(state, 1, "nephilim-jetfighter-loadout", model, squad, "twin-heavy-bolter")
	var restore_result := C.unit_action(state, 1, restore_choice, Vector2.ZERO, state.revision)
	check(not restore_choice.is_empty() and restore_result.is_empty() and not state.units[model].get("nephilim_lascannons", false), "The public preparation choice restores the Twin Heavy Bolter")

	var movement_state := {
		"active": 1, "board_size": Vector2(36.0, 24.0),
		"squads": {1: {"owner": 1}, 2: {"owner": 2}},
		"units": {
			1: {"position": Vector2(-3.0, 7.0), "radius": 0.6, "movement": 6.0, "owner": 1, "moved": false, "squad": 1, "wounds": 1, "on_battlefield": true},
			2: {"position": Vector2.ZERO + Vector2(0.0, 7.0), "radius": 60.0 / 25.4, "owner": 2, "squad": 2, "wounds": 1, "on_battlefield": true, "keywords": ["AIRCRAFT"]}
		}
	}
	var move_through_aircraft := MovementRules.validate_move_result(movement_state, 1, 1, Vector2(3.0, 7.0))
	var overlap_aircraft := MovementRules.validate_move_result(movement_state, 1, 1, Vector2(1.0, 7.0))
	check(move_through_aircraft.get("valid", false), "A normal move may pass through an AIRCRAFT base")
	check(overlap_aircraft.get("code", "") == "destination_overlap", "A model may pass through an AIRCRAFT but cannot end overlapping its base")

	var fight_state := {
		"units": {
			1: {"position": Vector2(4.0, 7.0), "radius": 0.5, "owner": 1, "squad": 1, "wounds": 1, "on_battlefield": true, "keywords": ["INFANTRY"]},
			2: {"position": Vector2(0.0, 7.0), "radius": 60.0 / 25.4, "owner": 2, "squad": 2, "wounds": 1, "on_battlefield": true, "keywords": ["AIRCRAFT", "FLY"]},
			3: {"position": Vector2(10.0, 7.0), "radius": 0.5, "owner": 2, "squad": 3, "wounds": 1, "on_battlefield": true, "keywords": ["INFANTRY"]},
			4: {"position": Vector2(12.0, 7.0), "radius": 0.5, "owner": 2, "squad": 4, "wounds": 1, "on_battlefield": true, "keywords": ["INFANTRY", "FLY"]}
		},
		"squads": {1: {"owner": 1}, 2: {"owner": 2}, 3: {"owner": 2}, 4: {"owner": 2}}
	}
	check(C.FightQueue.engaged(fight_state, 1), "A geometric Aircraft engagement remains an engagement for fight eligibility")
	check(not C._engaged_for_normal_advance(fight_state, 1), "Engagement solely with an Aircraft does not prevent a Normal or Advance move")
	check(not AircraftRules.may_fight_in_melee(fight_state, 1, 2) and AircraftRules.may_fight_in_melee(fight_state, 1, 4), "Only FLY models can fight an AIRCRAFT target")
	check(not AircraftRules.may_fight_in_melee(fight_state, 2, 1) and AircraftRules.may_fight_in_melee(fight_state, 2, 4), "An AIRCRAFT can make melee attacks only against FLY targets")
	check(not AircraftRules.may_charge_target(fight_state, 1, 2) and AircraftRules.may_charge_target(fight_state, 4, 2) and not AircraftRules.may_charge_target(fight_state, 2, 1), "Charge declarations enforce both Aircraft restrictions")
	check(HeresyRetribution._closest_enemy_targets(fight_state, 1) == [3], "A non-FLY Surge ignores Aircraft when choosing its closest enemy target")
	var contact_targets := ContactActions.enemies(fight_state, 1)
	check(2 not in contact_targets and contact_targets == [3, 4], "A non-FLY contact move ignores Aircraft while retaining eligible ground and FLY targets")

	var reserves_state := prepared()
	var reserve_aircraft: int = models(reserves_state, UNIT, 1)[0]
	var reserve_squad := int(reserves_state.units[reserve_aircraft].squad)
	check(AircraftRules.force_reserves(reserves_state, 1).is_empty(), "Mandatory Aircraft placement succeeds within the half-army reserve limit")
	check(reserves_state.unit_abilities.reserves.get(reserve_squad, {}).get("source", "") == "aircraft" and not reserves_state.units[reserve_aircraft].on_battlefield and reserve_squad not in reserves_state.deployment.order, "The Aircraft enters Strategic Reserves and leaves battlefield deployment")
	reserves_state.phase = "movement"
	reserves_state.active = 2
	reserves_state.round = 2
	reserves_state.cp[1] = 1
	check(reserve_squad not in U.rapid_ingress_squads(reserves_state, 1), "Rapid Ingress excludes AIRCRAFT even when CP and reserve eligibility are present")
	reserves_state.phase = "movement"
	reserves_state.active = 1
	reserves_state.round = 3
	reserves_state.board_size = Vector2(36.0, 24.0)
	reserves_state.deployment.complete = true
	for other: int in reserves_state.units:
		if int(reserves_state.units[other].owner) == 1: reserves_state.units[other].position = Vector2(-14.0, 8.0)
		else: reserves_state.units[other].position = Vector2(-14.0, -8.0)
	var ingress_choice := choice_for(reserves_state, 1, "ingress", -1, reserve_squad)
	check(not ingress_choice.is_empty(), "The owner can make the Aircraft's own Movement-phase ingress from round 2")
	var ingress_error := str(PublicUnitCommand.submit(reserves_state, 1, ingress_choice).get("error", ""))
	var ingress_model_choice := choice_for(reserves_state, 1, "ingress-place", reserve_aircraft, reserve_squad)
	var ingress_place_error := str(PublicUnitCommand.submit(reserves_state, 1, ingress_model_choice, Vector2(12.0, 0.0)).get("error", ""))
	var confirm_choice := choice_for(reserves_state, 1, "ingress-confirm")
	var ingress_confirm_error := str(PublicUnitCommand.submit(reserves_state, 1, confirm_choice).get("error", ""))
	check(ingress_error.is_empty() and ingress_place_error.is_empty() and ingress_confirm_error.is_empty() and reserves_state.units[reserve_aircraft].on_battlefield and reserves_state.unit_abilities.ingress_history.get(reserve_squad, false), "The Aircraft enters from a battlefield edge and records its first ingress: choice=%s start=%s place=%s confirm=%s window=%s" % [str(ingress_choice), ingress_error, ingress_place_error, ingress_confirm_error, str(reserves_state.unit_abilities.get("window", {}))])
	reserves_state.phase = "end_turn"
	reserves_state.active = 2
	check(AircraftRules.return_at_end_of_opponent_turn(reserves_state) == [reserve_squad] and not reserves_state.units[reserve_aircraft].on_battlefield, "An on-board Aircraft returns to reserves at the end of the opponent's turn")
	check(reserves_state.unit_abilities.reserves.get(reserve_squad, {}).get("has_ingressed", false), "The reserve record remembers that this Aircraft has already ingressed")
	reserves_state.round = 4
	U.reconcile(reserves_state)
	check(reserves_state.units[reserve_aircraft].wounds > 0 and reserves_state.unit_abilities.reserves.has(reserve_squad), "An Aircraft that has ingressed survives the round-three reserve cutoff")

	if failures == 0:
		print("Nephilim Jetfighter checks passed")
	else:
		print("Nephilim Jetfighter checks: %d failures" % failures)
	quit(1 if failures > 0 else 0)
