extends SceneTree

const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Catalog = preload("res://scripts/edition_11/army_capabilities.gd")
const Roster = preload("res://scripts/edition_11/roster_validation.gd")
const AircraftRules = preload("res://scripts/edition_11/aircraft_rules.gd")
const PublicUnitCommand = preload("res://tests/public_unit_command.gd")
const UNIT := "stormhawk-interceptor"
const UNIT_ID := "40kdc:11e:adeptus-astartes:stormhawk-interceptor"
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
	check(profile.get("source_book_id") == "000000356" and profile.get("source_datasheet_id") == "000000084", "The profile identifies the Stormhawk Interceptor from the verified Legends App")
	check(profile.get("source_snapshot_id") == Profiles.VERIFIED_EXPORT_SNAPSHOT_ID and profile.get("source_manifest_sha256") == Profiles.VERIFIED_EXPORT_MANIFEST_SHA256, "The source profile records the verified local snapshot and manifest")
	check(profile.get("points_by_models", {}) == {1: 155} and profile.get("models") == 1 and profile.get("max_supported_copies") == 3, "The one-model 155-point source cost and local copy ceiling are recorded")
	check(profile.get("base_size_source_mm", []) == [120, 92] and profile.get("base_geometry", "") == "oval" and str(profile.get("geometry_scope", "")).contains("60 mm bounding-circle proxy"), "The exact oval base and its bounded simulation proxy are both disclosed")
	check(profile.get("stats", {}) == {"movement_inches": 0, "toughness": 9, "save_target": 3, "wounds": 10, "leadership_target": 6, "objective_control": 0, "invulnerable_target": 0}, "The fixed Aircraft characteristics match the local export")
	check(profile.get("keywords", []) == ["ADEPTUS ASTARTES", "VEHICLE", "SMOKE", "RAVENWING", "IMPERIUM", "FLY", "AIRCRAFT"], "All seven datasheet keywords are represented")
	check(profile.get("default_loadout_by_role", {}).get("Stormhawk Interceptor", {}) == {"Armoured Hull": 1, "Las-talon": 1, "Skyhammer Missile Launcher": 1, "Twin Assault Cannon": 1}, "The default loadout matches the local export")
	var weapons := Profiles.stormhawk_interceptor_weapons()
	check(weapons.size() == 3 and weapons.any(func(row: Dictionary) -> bool: return row.get("id", "") == "las-talon" and row.profiles.standard == {"name": "Las-talon", "range_inches": 36.0, "attacks": 2, "skill": 3, "strength": 10, "ap": -3, "damage": "D3+3", "keywords": {}}), "The default Las-talon profile matches the export")
	check(weapons.any(func(row: Dictionary) -> bool: return row.get("id", "") == "skyhammer-missile-launcher" and row.profiles.standard.keywords == {"anti-fly": 2}), "The default Skyhammer retains Anti-Fly 2+")
	check(weapons.any(func(row: Dictionary) -> bool: return row.get("id", "") == "twin-assault-cannon" and row.profiles.standard.keywords == {"twin-linked": true, "sustained-hits": 1}), "The Twin Assault Cannon retains Twin-linked and Sustained Hits 1")
	var melee: Array = profile.get("melee", [])
	check(melee.size() == 1 and melee[0].profiles.standard == {"name": "Armoured Hull", "range_inches": 0.0, "attacks": 3, "skill": 4, "strength": 6, "ap": 0, "damage": 1, "keywords": {}}, "Armoured Hull matches the export")
	var icarus_weapons := Profiles.stormhawk_interceptor_weapons(true)
	check(icarus_weapons.any(func(row: Dictionary) -> bool: return row.get("id", "") == "icarus-stormcannon" and row.profiles.standard == {"name": "Icarus Stormcannon", "range_inches": 48.0, "attacks": 6, "skill": 3, "strength": 7, "ap": -1, "damage": 2, "keywords": {"anti-fly": 2}}), "The Icarus Stormcannon replacement matches its full profile")
	var heavy_bolter_weapons := Profiles.stormhawk_interceptor_weapons(false, "twin-heavy-bolter")
	check(heavy_bolter_weapons.any(func(row: Dictionary) -> bool: return row.get("id", "") == "twin-heavy-bolter" and row.profiles.standard == {"name": "Twin Heavy Bolter", "range_inches": 36.0, "attacks": 3, "skill": 3, "strength": 5, "ap": -1, "damage": 2, "keywords": {"twin-linked": true, "rapid-fire": 2, "sustained-hits": 1}}), "The Twin Heavy Bolter replacement keeps all three weapon rules")
	var typhoon_weapons := Profiles.stormhawk_interceptor_weapons(false, "typhoon-missile-launcher")
	var typhoon: Dictionary = typhoon_weapons.filter(func(row: Dictionary) -> bool: return row.get("id", "") == "typhoon-missile-launcher")[0]
	check(typhoon.profiles.krak == {"name": "Typhoon Missile Launcher - Krak", "range_inches": 48.0, "attacks": 2, "skill": 3, "strength": 10, "ap": -2, "damage": "D3+3", "keywords": {}}, "Typhoon Krak matches the local weapon export")
	check(typhoon.profiles.frag == {"name": "Typhoon Missile Launcher - Frag", "range_inches": 48.0, "attacks": 6, "skill": 3, "strength": 4, "ap": -1, "damage": 1, "keywords": {"blast": 2}}, "Typhoon Frag retains Blast 2")
	check(Catalog.SPECS.get(UNIT, {}).get("validation_status", "") == "source_bounded_local_scope_passed_2026_10_30" and Catalog.construction_readiness_note(UNIT).contains("exact physical base clearance is not certified"), "Catalog publishes the locally complete profile and discloses the exact-base geometry limit")
	check(Catalog.current_catalog_choice({"id": UNIT_ID, "edition": "11e", "faction": "Space Marines"}).get("options", []) == [{"models": 1, "cost": 155}], "The consolidated local catalog exposes the 155-point configuration")
	check(Roster.POINTS.get(UNIT, {}).get("sizes", {}) == {1: 155}, "Roster validation uses the same source price")
	var allowed := Catalog.admit({"schema_version": 2, "faction": "Space Marines", "category": "incursion", "points_limit": 1000, "entries": [{"definition_id": UNIT_ID, "models": 1, "copies": 1}]})
	check(allowed.get("error", "").is_empty(), "One Stormhawk is admitted for an Incursion roster")

	var state := prepared()
	check(not state.has("error"), "The admitted Stormhawk materializes in a current-catalog match: %s" % str(state.get("error", "")))
	if state.has("error"):
		print("Stormhawk Interceptor checks: %d failures" % (failures + 1))
		quit(1)
		return
	var aircraft_models := models(state, UNIT, 1)
	check(aircraft_models.size() == 1, "The match contains one Stormhawk Interceptor")
	if aircraft_models.is_empty():
		print("Stormhawk Interceptor checks: %d failures" % (failures + 1))
		quit(1)
		return
	var model: int = aircraft_models[0]
	var squad := int(state.units[model].squad)
	check(A.has(state, squad, "deadly-demise-d3") and A.deadly_demise_value(state, model) == "D3" and A.has(state, squad, "combat-doctrines") and A.has(state, squad, "interceptor"), "Deadly Demise D3, Combat Doctrines and Interceptor are registered")

	var primary_choice := choice_for(state, 1, "stormhawk-primary-loadout", model, squad, "icarus-stormcannon")
	var primary_result := C.unit_action(state, 1, primary_choice, Vector2.ZERO, state.revision)
	check(not primary_choice.is_empty() and primary_result.is_empty() and state.units[model].get("stormhawk_icarus_stormcannon", false), "Army preparation accepts the Icarus Stormcannon replacement")
	check(state.units[model].ranged_weapons.any(func(row: Dictionary) -> bool: return row.get("id", "") == "icarus-stormcannon") and not state.units[model].ranged_weapons.any(func(row: Dictionary) -> bool: return row.get("id", "") == "las-talon"), "The Icarus choice replaces the Las-talon without duplicating it")
	var restore_primary := choice_for(state, 1, "stormhawk-primary-loadout", model, squad, "las-talon")
	check(not restore_primary.is_empty() and C.unit_action(state, 1, restore_primary, Vector2.ZERO, state.revision).is_empty(), "Army preparation can restore the Las-talon")
	var heavy_choice := choice_for(state, 1, "stormhawk-missile-loadout", model, squad, "twin-heavy-bolter")
	check(not heavy_choice.is_empty() and C.unit_action(state, 1, heavy_choice, Vector2.ZERO, state.revision).is_empty(), "Army preparation accepts the Twin Heavy Bolter replacement")
	check(state.units[model].ranged_weapons.any(func(row: Dictionary) -> bool: return row.get("id", "") == "twin-heavy-bolter") and not state.units[model].ranged_weapons.any(func(row: Dictionary) -> bool: return row.get("id", "") == "skyhammer-missile-launcher"), "The Twin Heavy Bolter replaces the Skyhammer Missile Launcher")
	var typhoon_choice := choice_for(state, 1, "stormhawk-missile-loadout", model, squad, "typhoon-missile-launcher")
	check(not typhoon_choice.is_empty() and C.unit_action(state, 1, typhoon_choice, Vector2.ZERO, state.revision).is_empty(), "Army preparation accepts the Typhoon Missile Launcher replacement")
	var equipped_typhoon: Dictionary = state.units[model].ranged_weapons.filter(func(row: Dictionary) -> bool: return row.get("id", "") == "typhoon-missile-launcher")[0]
	check(equipped_typhoon.get("profiles", {}).has("krak") and equipped_typhoon.profiles.has("frag"), "The equipped Typhoon launcher presents both selectable profiles")
	var restore_missile := choice_for(state, 1, "stormhawk-missile-loadout", model, squad, "skyhammer-missile-launcher")
	check(not restore_missile.is_empty() and C.unit_action(state, 1, restore_missile, Vector2.ZERO, state.revision).is_empty(), "Army preparation can restore the default Skyhammer launcher")

	var enemy_squads: Array[int] = []
	for enemy_squad: int in state.squads:
		if int(state.squads[enemy_squad].get("owner", -1)) == 2: enemy_squads.append(enemy_squad)
	var fly_target := enemy_squads[0] if enemy_squads.size() > 0 else -1
	var ground_target := enemy_squads[1] if enemy_squads.size() > 1 else -1
	if fly_target >= 0:
		for target_model: int in state.units:
			if int(state.units[target_model].get("squad", -1)) == fly_target and "FLY" not in state.units[target_model].get("keywords", []): state.units[target_model].keywords.append("FLY")
	var twin_cannon: Dictionary = state.units[model].ranged_weapons.filter(func(row: Dictionary) -> bool: return row.get("id", "") == "twin-assault-cannon")[0].profiles.standard
	check(fly_target >= 0 and ground_target >= 0 and A.hit_bonus(state, squad, fly_target, false, model, twin_cannon) == 1, "Interceptor adds +1 to ranged hit rolls against FLY (ability=%s target_fly=%s bonus=%s targets=%s)" % [str(A.has(state, squad, "interceptor")), str(A.has_target_keyword(state, fly_target, "FLY")), str(A.hit_bonus(state, squad, fly_target, false, model, twin_cannon)), str(enemy_squads)])
	check(ground_target >= 0 and A.hit_bonus(state, squad, ground_target, false, model, twin_cannon) == 0, "Interceptor does not modify ranged attacks against non-FLY")
	check(fly_target >= 0 and A.hit_bonus(state, squad, fly_target, true, model, {}) == 0, "Interceptor does not modify melee attacks")
	check(AircraftRules.force_reserves(state, 1).is_empty() and not state.units[model].get("on_battlefield", true), "The mandatory Aircraft Strategic Reserves placement resolves")

	if failures == 0:
		print("Stormhawk Interceptor checks passed")
	else:
		print("Stormhawk Interceptor checks: %d failures" % failures)
	quit(1 if failures > 0 else 0)
