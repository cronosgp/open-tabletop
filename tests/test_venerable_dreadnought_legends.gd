extends SceneTree

const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Catalog = preload("res://scripts/edition_11/army_capabilities.gd")
const Roster = preload("res://scripts/edition_11/roster_validation.gd")
const DeadlyDemise = preload("res://scripts/edition_11/deadly_demise.gd")
const UNIT := "venerable-dreadnought-legends"
const UNIT_ID := "40kdc:11e:adeptus-astartes:venerable-dreadnought-legends"
const A = C.UnitAbilities
const U = C.UnitActions
const Geometry = preload("res://scripts/edition_11/contact_movement.gd")

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
	var state: Dictionary = F.P.initial_state({
		"checked_rosters": false, "official_mission": false, "unit_abilities": true,
		"combat_doctrines": true, "core_stratagems": true, "attack_rerolls": true,
		"manual_allocation": false
	}, selection())
	if state.has("error"): return state
	state.phase = "deployment"
	state.active = 1
	return state

func unit_models(state: Dictionary, identity: String, owner: int) -> Array[int]:
	var result: Array[int] = []
	for model: int in state.get("units", {}):
		var unit: Dictionary = state.units[model]
		if int(unit.get("owner", -1)) == owner and A.identity(unit) == identity: result.append(model)
	result.sort()
	return result

func squad_of(state: Dictionary, identity: String, owner: int) -> int:
	var found := unit_models(state, identity, owner)
	return int(state.units[found[0]].get("squad", -1)) if not found.is_empty() else -1

func choice_for(state: Dictionary, player: int, action: String, model: int, target: int, value: String) -> Dictionary:
	for option: Dictionary in U.choices(state, player):
		if str(option.get("action", "")) == action and int(option.get("model", -1)) == model and int(option.get("target", -1)) == target and str(option.get("value", "")) == value:
			return option
	return {}

func weapon_entry(loadout: Dictionary, category: String, weapon_id: String) -> Dictionary:
	for row: Dictionary in loadout.get(category, []):
		if str(row.get("id", "")) == weapon_id: return row
	return {}

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var profile := Profiles.profile(UNIT)
	check(profile.get("source_book_id") == "000000356" and profile.get("source_datasheet_id") == "000000120" and profile.get("source_scope") == "Warhammer Legends", "The separate Legends profile identifies source datasheet 000000120")
	check(profile.get("source_snapshot_id") == Profiles.VERIFIED_EXPORT_SNAPSHOT_ID and profile.get("source_manifest_sha256") == Profiles.VERIFIED_EXPORT_MANIFEST_SHA256 and profile.get("source_slice_manifest_sha256") == Profiles.VERIFIED_EXPORT_SLICE_SHA256_BY_BOOK["000000356"], "The profile records the verified local export provenance")
	check(profile.get("points_by_models", {}) == {1: 165} and profile.get("models") == 1 and profile.get("max_supported_copies") == 3, "The fixed 165-point model and local copy ceiling match the source-bounded catalog")
	check(profile.get("base_size_source_mm") == 60 and is_equal_approx(float(profile.get("base_radius_inches", 0.0)), 30.0 / 25.4), "The exact 60 mm source base is represented")
	check(profile.get("stats", {}) == {"movement_inches": 6, "toughness": 9, "save_target": 2, "wounds": 8, "leadership_target": 6, "objective_control": 3, "invulnerable_target": 0}, "All model characteristics match the verified export")
	check(profile.get("keywords", []) == ["ADEPTUS ASTARTES", "IMPERIUM", "DEATHWING", "VEHICLE", "WALKER", "DREADNOUGHT", "SMOKE"], "All source keywords, including DREADNOUGHT and SMOKE, are represented")
	check(profile.get("default_loadout_by_role", {}).get("Venerable Dreadnought", {}) == {"Armoured Feet": 1, "Assault Cannon": 1, "Dreadnought Fist": 1, "Storm Bolter": 1}, "The four-weapon default loadout matches the sheet")
	check(profile.get("special_rules", []) == ["Combat Doctrines", "Deadly Demise 1", "Wisdom of the Ancients"], "All source abilities are listed")
	check(Profiles.profile("venerable-dreadnought").get("source_datasheet_id") == "000002801", "The existing Space Wolves Venerable Dreadnought remains a distinct source profile")

	var defaults := Profiles.venerable_dreadnought_legends_weapons()
	check(defaults.get("ranged", []).size() == 2 and weapon_entry(defaults, "ranged", "assault-cannon").profiles.standard == {"name": "Assault Cannon", "range_inches": 24.0, "attacks": 6, "skill": 3, "strength": 6, "ap": -2, "damage": 1, "keywords": {"sustained-hits": 1}} and weapon_entry(defaults, "ranged", "storm-bolter").profiles.standard == {"name": "Storm Bolter", "range_inches": 24.0, "attacks": 2, "skill": 3, "strength": 5, "ap": -1, "damage": 1, "keywords": {"rapid-fire": 2}}, "The default Assault Cannon and Storm Bolter preserve their complete source profiles")
	check(defaults.get("melee", []).size() == 2 and weapon_entry(defaults, "melee", "armoured-feet").profiles.standard == {"name": "Armoured Feet", "range_inches": 0.0, "attacks": 5, "skill": 3, "strength": 6, "ap": 0, "damage": 1, "keywords": {}} and weapon_entry(defaults, "melee", "dreadnought-fist").profiles.standard == {"name": "Dreadnought Fist", "range_inches": 0.0, "attacks": 5, "skill": 3, "strength": 12, "ap": -2, "damage": 3, "keywords": {}}, "Both melee weapons preserve their complete source profiles")
	var additions: Array = profile.get("additional_weapon_profiles", {}).get("ranged", [])
	check(additions.size() == 9, "All nine optional ranged weapon identities are stored once despite being available in two groups")
	var inferno := additions.filter(func(row: Dictionary) -> bool: return row.id == "dreadnought-inferno-cannon")
	var plasma := additions.filter(func(row: Dictionary) -> bool: return row.id == "heavy-plasma-cannon")
	var missile := additions.filter(func(row: Dictionary) -> bool: return row.id == "missile-launcher")
	var twin_heavy_flamers := additions.filter(func(row: Dictionary) -> bool: return row.id == "twin-heavy-flamer")
	check(inferno.size() == 1 and inferno[0].profiles.standard == {"name": "Dreadnought Inferno Cannon", "range_inches": 12.0, "attacks": 7, "skill": null, "strength": 6, "ap": -1, "damage": 1, "keywords": {"blast": 2, "torrent": true}}, "The Inferno Cannon's automatic hits, Blast 2 and Torrent are retained")
	check(plasma.size() == 1 and plasma[0].profiles.standard.keywords == {"blast": 1, "heavy": true} and plasma[0].profiles.supercharge.keywords == {"hazardous": true, "blast": 1, "heavy": true}, "Both Heavy Plasma profiles retain Heavy, Blast and the supercharge Hazardous trait")
	check(missile.size() == 1 and missile[0].profiles.frag.keywords == {"blast": 1, "heavy": true} and missile[0].profiles.krak.damage == "D3+3", "Both Missile Launcher profiles preserve their distinct Heavy/Blast and Krak damage data")
	check(twin_heavy_flamers.size() == 1 and twin_heavy_flamers[0].profiles.standard.keywords == {"blast": 2, "twin-linked": true, "torrent": true}, "Twin Heavy Flamer retains all three source weapon traits")
	var legal_combinations := 0
	for primary: String in ["assault-cannon", "dreadnought-inferno-cannon", "heavy-plasma-cannon", "multi-melta", "twin-autocannon", "twin-heavy-bolter", "twin-heavy-flamer", "twin-lascannon"]:
		for package: String in ["fist-and-storm-bolter", "heavy-flamer-and-fist", "missile-launcher", "twin-autocannon"]:
			var loadout := Profiles.venerable_dreadnought_legends_weapons(primary, package)
			check(loadout.get("ranged", []).size() == 2 and loadout.get("melee", []).size() == (1 if package in ["missile-launcher", "twin-autocannon"] else 2), "The source-independent option groups produce a complete %s/%s loadout" % [primary, package])
			if primary == "twin-autocannon" and package == "twin-autocannon":
				check(loadout.ranged.filter(func(row: Dictionary) -> bool: return row.id == "twin-autocannon").size() == 2, "The two independent source groups can legally select Twin Autocannon twice")
			legal_combinations += 1
	check(legal_combinations == 32, "All 32 combinations from the independent eight-choice and four-choice groups are legal")
	check(Profiles.venerable_dreadnought_legends_weapons("invented", "missile-launcher").is_empty() and Profiles.venerable_dreadnought_legends_weapons("assault-cannon", "invented").is_empty(), "Unknown and off-sheet weapon choices are rejected")

	var choice := Catalog.current_catalog_choice({"id": UNIT_ID, "edition": "11e", "faction": "Space Marines"})
	check(choice.get("options", []) == [{"models": 1, "cost": 165}] and str(choice.get("scope", "")).contains("Warhammer Legends"), "Current construction publishes the exact source size, cost and Legends scope")
	check(str(Catalog.construction_readiness_note(UNIT)).contains("organiser approval") and str(Catalog.construction_readiness_note(UNIT)).contains("separate 165-point"), "The catalogue labels casual Legends use and organiser approval clearly")
	check(Roster.POINTS.get(UNIT, {}).get("sizes", {}) == {1: 165}, "Roster validation applies the source cost")
	var admitted := Catalog.admit({"schema_version": 2, "faction": "Space Marines", "category": "strike_force", "points_limit": 2000, "entries": [{"definition_id": UNIT_ID, "models": 1, "copies": 3}]})
	check(admitted.get("error", "").is_empty(), "Three Legends copies fit the configured Strike Force repetition limit")
	var over_limit := Catalog.admit({"schema_version": 2, "faction": "Space Marines", "category": "strike_force", "points_limit": 2000, "entries": [{"definition_id": UNIT_ID, "models": 1, "copies": 4}]})
	check(not str(over_limit.get("error", "")).is_empty(), "A fourth copy is rejected by the repetition limit")

	var state := prepared()
	check(not state.has("error"), "The Legends profile materializes from the current catalog: %s" % str(state.get("error", "")))
	if state.has("error"):
		quit(1)
		return
	var models := unit_models(state, UNIT, 1)
	check(models.size() == 1, "One Venerable Dreadnought Legends model enters the match separately from the Space Wolves datasheet")
	if models.is_empty():
		quit(1)
		return
	var model := models[0]
	var squad := int(state.units[model].squad)
	check(state.units[model].ranged_weapons.size() == 2 and state.units[model].melee_weapons.size() == 2 and state.units[model].get("venerable_dreadnought_legends_primary") == "assault-cannon", "Battle setup starts with both source default ranged weapons and melee weapons")
	check(A.has(state, squad, "deadly-demise-1") and A.deadly_demise_value(state, model) == "1" and A.has(state, squad, "combat-doctrines") and A.has(state, squad, "wisdom-of-the-ancients") and C.CoreReactions.keyword(state, squad, "SMOKE"), "Deadly Demise 1, Combat Doctrines, Wisdom and Smoke are registered")
	var primary_options := ["assault-cannon", "dreadnought-inferno-cannon", "heavy-plasma-cannon", "multi-melta", "twin-autocannon", "twin-heavy-bolter", "twin-heavy-flamer", "twin-lascannon"]
	for primary: String in primary_options:
		if primary == "assault-cannon": continue
		var option := choice_for(state, 1, "venerable-dreadnought-legends-primary", model, squad, primary)
		check(not option.is_empty() and C.unit_action(state, 1, option, Vector2.ZERO, state.revision).is_empty() and str(state.units[model].venerable_dreadnought_legends_primary) == primary, "Preparation selects source-listed primary replacement %s" % primary)
	var package_options := ["fist-and-storm-bolter", "heavy-flamer-and-fist", "missile-launcher", "twin-autocannon"]
	for package: String in package_options:
		if package == "fist-and-storm-bolter": continue
		var option := choice_for(state, 1, "venerable-dreadnought-legends-package", model, squad, package)
		check(not option.is_empty() and C.unit_action(state, 1, option, Vector2.ZERO, state.revision).is_empty() and str(state.units[model].venerable_dreadnought_legends_package) == package, "Preparation selects source-listed replacement package %s" % package)
	var invalid := {"action": "venerable-dreadnought-legends-package", "model": model, "target": squad, "value": "crushing-feet"}
	check(not C.unit_action(state, 1, invalid, Vector2.ZERO, state.revision).is_empty(), "The public preparation action rejects off-sheet replacement choices")
	var restore_primary := choice_for(state, 1, "venerable-dreadnought-legends-primary", model, squad, "assault-cannon")
	var restore_package := choice_for(state, 1, "venerable-dreadnought-legends-package", model, squad, "fist-and-storm-bolter")
	check(not restore_primary.is_empty() and C.unit_action(state, 1, restore_primary, Vector2.ZERO, state.revision).is_empty() and not restore_package.is_empty() and C.unit_action(state, 1, restore_package, Vector2.ZERO, state.revision).is_empty(), "Both option groups can be restored to the exact source default")
	check(state.units[model].ranged_weapons.any(func(row: Dictionary) -> bool: return row.id == "assault-cannon") and state.units[model].ranged_weapons.any(func(row: Dictionary) -> bool: return row.id == "storm-bolter") and state.units[model].melee_weapons.any(func(row: Dictionary) -> bool: return row.id == "armoured-feet") and state.units[model].melee_weapons.any(func(row: Dictionary) -> bool: return row.id == "dreadnought-fist"), "Restoration rebuilds all four default weapons")

	var infantry_squad := squad_of(state, "intercessor-squad", 1)
	var infantry_models := Geometry.alive(state, infantry_squad)
	var enemy_squad := squad_of(state, "intercessor-squad", 2)
	var enemy_models := Geometry.alive(state, enemy_squad)
	check(infantry_squad >= 0 and not infantry_models.is_empty() and enemy_squad >= 0 and not enemy_models.is_empty(), "The fixture contains friendly and enemy Infantry units")
	if infantry_squad >= 0 and not infantry_models.is_empty() and enemy_squad >= 0 and not enemy_models.is_empty():
		var shooter := infantry_models[0]
		for other: int in infantry_models:
			if other != shooter: state.units[other].wounds = 0
		state.units[model].position = Vector2.ZERO
		state.units[shooter].position = Vector2(3.0, 0.0)
		check(A.wisdom_of_the_ancients_active(state, infantry_squad), "The Legends source supplies Wisdom of the Ancients within the exact 6-inch base-edge aura")
		for enemy: int in enemy_models: state.units[enemy].position = Vector2(15.0, 0.0)
		state.phase = "shooting"
		state.active = 1
		var weapon: Dictionary = state.units[shooter].ranged_weapons[0]
		var plan := C.AttackPlan.prepare(state, infantry_squad, false, [{"model": shooter, "target": enemy_squad, "amount": 1, "weapon": str(weapon.id), "profile": str(weapon.profiles.keys()[0])}], false)
		check(plan.get("error", "").is_empty() and plan.get("batches", []).size() == 1 and plan.batches[0].context.get("hit_reroll", "none") == "ones", "Wisdom from this separate Legends source enters the real ranged AttackPlan")
		state.units[model].wounds = 0
		check(not A.wisdom_of_the_ancients_active(state, infantry_squad), "A destroyed Legends source no longer grants the aura")
		state.units[model].wounds = int(profile.stats.wounds)

	state.units[model].wounds = 0
	var demise := DeadlyDemise.begin(state, [model], func() -> int: return 6)
	var pending: Dictionary = state.get("pending_deadly_demise", {})
	check(demise.get("error", "").is_empty() and pending.get("events", []).size() == 1 and pending.events[0].get("expression", "") == "1", "The new profile triggers its source Deadly Demise 1 entry in the shared destruction sequence")

	if failures == 0:
		print("Venerable Dreadnought Legends checks passed")
	else:
		print("Venerable Dreadnought Legends checks: %d failures" % failures)
	quit(1 if failures > 0 else 0)
