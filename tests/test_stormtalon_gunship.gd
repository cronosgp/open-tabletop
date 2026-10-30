extends SceneTree

const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Catalog = preload("res://scripts/edition_11/army_capabilities.gd")
const Roster = preload("res://scripts/edition_11/roster_validation.gd")
const AircraftRules = preload("res://scripts/edition_11/aircraft_rules.gd")
const UNIT := "stormtalon-gunship"
const UNIT_ID := "40kdc:11e:adeptus-astartes:stormtalon-gunship"
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
	check(profile.get("source_book_id") == "000000356" and profile.get("source_datasheet_id") == "000001190", "The profile identifies the Stormtalon Gunship in the verified Legends App")
	check(profile.get("source_snapshot_id") == Profiles.VERIFIED_EXPORT_SNAPSHOT_ID and profile.get("source_manifest_sha256") == Profiles.VERIFIED_EXPORT_MANIFEST_SHA256, "The profile records its verified local snapshot and manifest")
	check(profile.get("points_by_models", {}) == {1: 165} and profile.get("models") == 1 and profile.get("max_supported_copies") == 3, "The one-model 165-point source cost and supported copy ceiling are recorded")
	check(profile.get("base_size_source_mm", []) == [120, 92] and profile.get("base_geometry", "") == "oval" and str(profile.get("geometry_scope", "")).contains("60 mm bounding-circle proxy"), "The source oval base and bounded simulation proxy are disclosed")
	check(profile.get("stats", {}) == {"movement_inches": 0, "toughness": 8, "save_target": 3, "wounds": 10, "leadership_target": 6, "objective_control": 0, "invulnerable_target": 0}, "All Stormtalon characteristics match the verified local export")
	check(profile.get("keywords", []) == ["ADEPTUS ASTARTES", "RAVENWING", "FLY", "VEHICLE", "AIRCRAFT", "IMPERIUM"], "All six source keywords are represented")
	check(profile.get("default_loadout_by_role", {}).get("Stormtalon Gunship", {}) == {"Armoured Hull": 1, "Skyhammer Missile Launcher": 1, "Twin Assault Cannon": 1}, "The default loadout matches the source sheet")
	var default_weapons := Profiles.stormtalon_gunship_weapons()
	check(default_weapons.size() == 2 and default_weapons.any(func(row: Dictionary) -> bool: return row.get("id", "") == "skyhammer-missile-launcher" and row.profiles.standard == {"name": "Skyhammer Missile Launcher", "range_inches": 48.0, "attacks": 3, "skill": 3, "strength": 8, "ap": -1, "damage": 2, "keywords": {"twin-linked": true, "anti-fly": 2}}), "The Skyhammer profile and its Twin-linked and Anti-Fly rules match the export")
	check(default_weapons.any(func(row: Dictionary) -> bool: return row.get("id", "") == "twin-assault-cannon" and row.profiles.standard == {"name": "Twin Assault Cannon", "range_inches": 24.0, "attacks": 6, "skill": 3, "strength": 6, "ap": -2, "damage": 1, "keywords": {"twin-linked": true, "sustained-hits": 1}}), "The Twin Assault Cannon profile matches the export")
	var heavy_bolter := Profiles.stormtalon_gunship_weapons("twin-heavy-bolter")
	check(heavy_bolter.any(func(row: Dictionary) -> bool: return row.get("id", "") == "twin-heavy-bolter" and row.profiles.standard == {"name": "Twin Heavy Bolter", "range_inches": 36.0, "attacks": 3, "skill": 3, "strength": 5, "ap": -1, "damage": 2, "keywords": {"twin-linked": true, "rapid-fire": 2, "sustained-hits": 1}}), "The Twin Heavy Bolter replacement retains all source weapon rules")
	var twin_lascannon := Profiles.stormtalon_gunship_weapons("twin-lascannon")
	check(twin_lascannon.any(func(row: Dictionary) -> bool: return row.get("id", "") == "twin-lascannon" and row.profiles.standard == {"name": "Twin Lascannon", "range_inches": 48.0, "attacks": 1, "skill": 3, "strength": 12, "ap": -3, "damage": "D3+3", "keywords": {"twin-linked": true}}), "The Twin Lascannon replacement matches its complete source profile")
	var typhoon := Profiles.stormtalon_gunship_weapons("typhoon-missile-launcher")
	check(typhoon.any(func(row: Dictionary) -> bool: return row.get("id", "") == "typhoon-missile-launcher" and row.profiles.krak == {"name": "Typhoon Missile Launcher - Krak", "range_inches": 48.0, "attacks": 2, "skill": 3, "strength": 10, "ap": -2, "damage": "D3+3", "keywords": {}} and row.profiles.frag == {"name": "Typhoon Missile Launcher - Frag", "range_inches": 48.0, "attacks": 6, "skill": 3, "strength": 4, "ap": -1, "damage": 1, "keywords": {"blast": 2}}), "The Typhoon replacement has both complete firing profiles")
	check(Profiles.stormtalon_gunship_weapons("icarus-stormcannon").is_empty(), "The loadout helper rejects replacements absent from the Stormtalon datasheet")
	check(profile.get("melee", []).size() == 1 and profile.melee[0].profiles.standard == {"name": "Armoured Hull", "range_inches": 0.0, "attacks": 3, "skill": 4, "strength": 6, "ap": 0, "damage": 1, "keywords": {}}, "Armoured Hull matches its melee export row")
	check(Catalog.SPECS.get(UNIT, {}).get("validation_status", "") == "source_bounded_local_scope_passed_2026_10_30" and Catalog.construction_readiness_note(UNIT).contains("exact physical base clearance is not certified") and Catalog.construction_readiness_note(UNIT).contains("competitive events require organiser approval"), "The catalog publishes the local scope and discloses geometry and event-use boundaries")
	check(Catalog.current_catalog_choice({"id": UNIT_ID, "edition": "11e", "faction": "Space Marines"}).get("options", []) == [{"models": 1, "cost": 165}], "The consolidated catalog exposes the source-priced configuration")
	check(Roster.POINTS.get(UNIT, {}).get("sizes", {}) == {1: 165}, "Roster validation applies the verified 165-point cost")
	var admitted := Catalog.admit({"schema_version": 2, "faction": "Space Marines", "category": "incursion", "points_limit": 1000, "entries": [{"definition_id": UNIT_ID, "models": 1, "copies": 1}]})
	check(admitted.get("error", "").is_empty(), "The local roster builder admits the correctly priced Stormtalon")

	var state := prepared()
	check(not state.has("error"), "The admitted Stormtalon materializes in a current-catalog match: %s" % str(state.get("error", "")))
	if state.has("error"):
		print("Stormtalon Gunship checks: %d failures" % (failures + 1))
		quit(1)
		return
	var aircraft := models(state, UNIT, 1)
	check(aircraft.size() == 1, "A one-model Stormtalon is created in the match")
	if aircraft.is_empty():
		print("Stormtalon Gunship checks: %d failures" % (failures + 1))
		quit(1)
		return
	var model: int = aircraft[0]
	var squad := int(state.units[model].squad)
	check(A.has(state, squad, "deadly-demise-d3") and A.deadly_demise_value(state, model) == "D3" and A.has(state, squad, "combat-doctrines") and A.has(state, squad, "strafing-run"), "Deadly Demise D3, Combat Doctrines and Strafing Run are registered")
	var heavy_choice := choice_for(state, 1, "stormtalon-loadout", model, squad, "twin-heavy-bolter")
	check(not heavy_choice.is_empty() and C.unit_action(state, 1, heavy_choice, Vector2.ZERO, state.revision).is_empty(), "Army preparation accepts the Twin Heavy Bolter replacement")
	check(state.units[model].ranged_weapons.any(func(row: Dictionary) -> bool: return row.get("id", "") == "twin-heavy-bolter") and not state.units[model].ranged_weapons.any(func(row: Dictionary) -> bool: return row.get("id", "") == "skyhammer-missile-launcher"), "The Twin Heavy Bolter replaces the default Skyhammer")
	var lascannon_choice := choice_for(state, 1, "stormtalon-loadout", model, squad, "twin-lascannon")
	check(not lascannon_choice.is_empty() and C.unit_action(state, 1, lascannon_choice, Vector2.ZERO, state.revision).is_empty(), "Army preparation accepts the Twin Lascannon replacement")
	var typhoon_choice := choice_for(state, 1, "stormtalon-loadout", model, squad, "typhoon-missile-launcher")
	check(not typhoon_choice.is_empty() and C.unit_action(state, 1, typhoon_choice, Vector2.ZERO, state.revision).is_empty(), "Army preparation accepts the Typhoon Missile Launcher replacement")
	var equipped_typhoon: Dictionary = state.units[model].ranged_weapons.filter(func(row: Dictionary) -> bool: return row.get("id", "") == "typhoon-missile-launcher")[0]
	check(equipped_typhoon.profiles.has("krak") and equipped_typhoon.profiles.has("frag"), "The equipped Typhoon presents both source firing modes")
	var restore_choice := choice_for(state, 1, "stormtalon-loadout", model, squad, "skyhammer-missile-launcher")
	check(not restore_choice.is_empty() and C.unit_action(state, 1, restore_choice, Vector2.ZERO, state.revision).is_empty(), "Army preparation can restore the default Skyhammer")

	var enemy_squads: Array[int] = []
	for enemy_squad: int in state.squads:
		if int(state.squads[enemy_squad].get("owner", -1)) == 2: enemy_squads.append(enemy_squad)
	var fly_target := enemy_squads[0] if enemy_squads.size() > 0 else -1
	var ground_target := enemy_squads[1] if enemy_squads.size() > 1 else -1
	if fly_target >= 0:
		for target_model: int in state.units:
			if int(state.units[target_model].get("squad", -1)) == fly_target and "FLY" not in state.units[target_model].get("keywords", []): state.units[target_model].keywords.append("FLY")
	state.phase = "shooting"
	state.active = 1
	state.units[model].position = Vector2.ZERO
	for target_model: int in state.units:
		if int(state.units[target_model].get("squad", -1)) in [fly_target, ground_target]: state.units[target_model].position = Vector2(12.0, 0.0)
	var cannon: Dictionary = state.units[model].ranged_weapons.filter(func(row: Dictionary) -> bool: return row.get("id", "") == "twin-assault-cannon")[0].profiles.standard
	check(ground_target >= 0 and A.hit_bonus(state, squad, ground_target, false, model, cannon) == 1, "Strafing Run adds +1 to ranged Hit rolls against non-FLY units")
	check(fly_target >= 0 and A.hit_bonus(state, squad, fly_target, false, model, cannon) == 0, "Strafing Run does not modify ranged Hit rolls against FLY units")
	check(ground_target >= 0 and A.hit_bonus(state, squad, ground_target, true, model, {}) == 0, "Strafing Run does not modify melee Hit rolls")
	if ground_target >= 0 and fly_target >= 0:
		var ground_plan := C.AttackPlan.prepare(state, squad, false, [{"model": model, "target": ground_target, "amount": 1, "weapon": "twin-assault-cannon", "profile": "standard"}], false)
		var fly_plan := C.AttackPlan.prepare(state, squad, false, [{"model": model, "target": fly_target, "amount": 1, "weapon": "twin-assault-cannon", "profile": "standard"}], false)
		check(ground_plan.get("error", "").is_empty() and int(ground_plan.get("batches", [{}])[0].get("context", {}).get("hit_modifier", 0)) == 1, "The declared AttackPlan receives Strafing Run against the ground target")
		check(fly_plan.get("error", "").is_empty() and int(fly_plan.get("batches", [{}])[0].get("context", {}).get("hit_modifier", 0)) == 0, "The declared AttackPlan does not apply Strafing Run against the FLY target")
	check(AircraftRules.force_reserves(state, 1).is_empty() and not state.units[model].get("on_battlefield", true), "The mandatory Aircraft Strategic Reserves placement resolves")

	if failures == 0:
		print("Stormtalon Gunship checks passed")
	else:
		print("Stormtalon Gunship checks: %d failures" % failures)
	quit(1 if failures > 0 else 0)
