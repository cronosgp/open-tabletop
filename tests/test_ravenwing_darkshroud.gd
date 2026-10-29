extends SceneTree

const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Catalog = preload("res://scripts/edition_11/army_capabilities.gd")
const Roster = preload("res://scripts/edition_11/roster_validation.gd")
const Detection = preload("res://scripts/edition_11/detection_rules.gd")
const AttackPlan = preload("res://scripts/edition_11/attack_plan.gd")
const Equipment = preload("res://scripts/edition_11/equipment.gd")
const PublicUnitCommand = preload("res://tests/public_unit_command.gd")
const UNIT := "ravenwing-darkshroud"
const UNIT_ID := "40kdc:11e:adeptus-astartes:ravenwing-darkshroud"
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

func squads(state: Dictionary, identity: String, owner: int) -> Array[int]:
	var result: Array[int] = []
	for model: int in models(state, identity, owner):
		var squad := int(state.units[model].squad)
		if squad not in result: result.append(squad)
	return result

func place(state: Dictionary, squad: int, position: Vector2) -> void:
	for model: int in state.units:
		if int(state.units[model].get("squad", -1)) == squad: state.units[model].position = position

func choice_for(state: Dictionary, player: int, action: String, model: int, target: int, value: String) -> Dictionary:
	for option: Dictionary in U.choices(state, player):
		if str(option.get("action", "")) == action and int(option.get("model", -1)) == model and int(option.get("target", -1)) == target and str(option.get("value", "")) == value:
			return option
	return {}

func weapon(profile: Dictionary, category: String, identity: String, additional: bool = false) -> Dictionary:
	var rows: Array = profile.get(category, [])
	if additional: rows = profile.get("additional_weapon_profiles", {}).get(category, [])
	for item: Dictionary in rows:
		if str(item.get("id", "")) == identity: return item.get("profiles", {}).get("standard", {})
	return {}

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var profile := Profiles.profile(UNIT)
	check(profile.get("source_book_id") == "000000023" and profile.get("source_datasheet_id") == "000000238" and profile.get("source_export_updated_at") == "2026-10-21T16:06:23+03:00", "The profile identifies Ravenwing Darkshroud's pinned Dark Angels App row")
	check(profile.get("points_by_models", {}) == {1: 80} and profile.get("models") == 1 and profile.get("base_size_source", "").begins_with("Large Flying Base"), "The 1-model, 80-point composition keeps its base dimensions explicitly unresolved")
	check(profile.get("stats", {}) == {"movement_inches": 14, "toughness": 8, "save_target": 3, "wounds": 10, "leadership_target": 6, "objective_control": 3, "invulnerable_target": 5}, "M14/T8/Sv3+/W10/Ld6+/OC3/5++ match the source export")
	check(profile.get("keywords", []) == ["VEHICLE", "SPEEDER", "FRAME", "FLY", "RAVENWING", "IMPERIUM", "ADEPTUS ASTARTES", "DARK ANGELS"], "All datasheet and faction keywords are represented")
	check(weapon(profile, "ranged", "heavy-bolter") == {"name": "Heavy Bolter", "range_inches": 36.0, "attacks": 3, "skill": 3, "strength": 5, "ap": -1, "damage": 2, "keywords": {"rapid-fire": 2, "sustained-hits": 1}}, "The default Heavy Bolter profile and traits match the export")
	check(weapon(profile, "ranged", "assault-cannon", true) == {"name": "Assault Cannon", "range_inches": 24.0, "attacks": 6, "skill": 3, "strength": 6, "ap": -2, "damage": 1, "keywords": {"sustained-hits": 1}}, "The Heavy Bolter replacement profile matches the export")
	check(weapon(profile, "melee", "armoured-hull") == {"name": "Armoured Hull", "range_inches": 0.0, "attacks": 3, "skill": 4, "strength": 6, "ap": 0, "damage": 1, "keywords": {}}, "Armoured Hull matches the export")
	check(Catalog.SPECS.get(UNIT, {}).get("current_reference", false) and Catalog.SPECS.get(UNIT, {}).get("validation_status", "") == "source_bounded_local_scope_passed_2026_10_28", "The tested profile is admitted as a current reference sheet")
	var catalog_entry := Catalog.current_catalog_choice({"id": UNIT_ID, "edition": "11e", "faction": "Space Marines"})
	check(catalog_entry.get("options", []) == [{"models": 1, "cost": 80}], "The construction catalog exposes the source composition and price")
	var point_record: Dictionary = Roster.POINTS.get(UNIT, {})
	check(point_record.get("sizes", {}) == {1: 80}, "Roster validation shares the source price")
	var allowed := Catalog.admit({"schema_version": 2, "faction": "Space Marines", "category": "custom", "points_limit": 3000, "entries": [{"definition_id": UNIT_ID, "models": 1, "copies": 3}]})
	var excess := Catalog.admit({"schema_version": 2, "faction": "Space Marines", "category": "custom", "points_limit": 3000, "entries": [{"definition_id": UNIT_ID, "models": 1, "copies": 4}]})
	check(allowed.get("error", "").is_empty() and int(allowed.get("total", -1)) == 240 and not str(excess.get("error", "")).is_empty(), "The local catalog admits up to three 80-point copies and rejects a fourth")

	var state := prepared()
	check(not state.has("error"), "The current catalog materializes both Marine rosters and the Dark Angels unit: %s" % str(state.get("error", "")))
	if state.has("error"):
		print("Ravenwing Darkshroud checks: %d failures" % (failures + 1))
		quit(1)
		return
	var darkshrouds := models(state, UNIT, 1)
	var marines := squads(state, "intercessor-squad", 1)
	var enemy_marines := squads(state, "intercessor-squad", 2)
	check(darkshrouds.size() == 1 and marines.size() == 2 and not enemy_marines.is_empty(), "The match has one Darkshroud, two friendly Intercessors and opposing Intercessors")
	if darkshrouds.is_empty() or marines.size() < 2 or enemy_marines.is_empty():
		print("Ravenwing Darkshroud checks: %d failures" % (failures + 1))
		quit(1)
		return
	var model: int = darkshrouds[0]
	var squad := int(state.units[model].squad)
	check(A.has(state, squad, "deep-strike") and A.every_model_has(state, squad, "deep-strike") and A.has(state, squad, "deadly-demise-d3") and A.deadly_demise_value(state, model) == "D3" and A.has(state, squad, "combat-doctrines"), "Deep Strike, Deadly Demise D3 and Combat Doctrines are registered")
	check(A.lone_operative_active(state, model) and A.lone_operative_range(state, model) == 15.0, "Lone Operative uses the source 15-inch boundary")
	check("RAVENWING" in state.units[model].keywords and "DARK ANGELS" in state.units[model].keywords, "Dark Angels Chapter context retains the source Ravenwing keywords")

	place(state, squad, Vector2.ZERO)
	place(state, marines[0], Vector2(7.4, 0.0))
	place(state, marines[1], Vector2(8.1, 0.0))
	place(state, enemy_marines[0], Vector2(7.4, 0.0))
	check(Detection.stealth(state, marines[0]) and not Detection.stealth(state, marines[1]), "Icon of Old Caliban grants Stealth inside 6 inches and ends outside the boundary")
	check(not Detection.stealth(state, enemy_marines[0]), "The Darkshroud aura does not grant Stealth to the opposing army")
	var saved_chapter: String = str(state.marine_chapters.get(1, ""))
	state.marine_chapters[1] = ""
	check(not Detection.stealth(state, marines[0]), "The aura excludes shared Astartes profiles without Dark Angels Chapter context")
	state.marine_chapters[1] = saved_chapter

	state.phase = "shooting"
	state.active = 2
	var attacker: int = C.living(state, enemy_marines[0])[0]
	place(state, enemy_marines[0], Vector2(14.9, 0.0))
	var legal_between_12_and_15 := AttackPlan.legal_targets(state, attacker, false, "bolt-rifle", "focused_fire")
	check(squad in legal_between_12_and_15, "A ranged attacker between 12 and 15 inches can target the standalone Darkshroud")
	place(state, enemy_marines[0], Vector2(16.9, 0.0))
	var beyond_15 := AttackPlan.legal_targets(state, attacker, false, "bolt-rifle", "focused_fire")
	check(squad not in beyond_15, "The Darkshroud cannot be targeted beyond its 15-inch Lone Operative boundary")
	state.active = 1
	var heavy_bolter_targets := AttackPlan.legal_targets(state, model, false, "heavy-bolter", "standard")
	check(not heavy_bolter_targets.is_empty(), "The default Heavy Bolter resolves legal ranged targets through AttackPlan")

	state.phase = "deployment"
	state.active = 1
	var cannon_choice := choice_for(state, 1, "ravenwing-darkshroud-cannon", model, squad, "assault-cannon")
	var wrong_owner_result := PublicUnitCommand.submit(state, 2, cannon_choice)
	var assault_cannon_result := PublicUnitCommand.submit(state, 1, cannon_choice)
	check(not str(wrong_owner_result.get("error", "")).is_empty() and assault_cannon_result.get("error", "").is_empty(), "The public setup command rejects the opposing player and accepts the Heavy Bolter replacement")
	check(state.units[model].ranged_weapons.map(func(item: Dictionary) -> String: return str(item.get("id", ""))) == ["assault-cannon"] and Equipment.select(state, model, false, "assault-cannon", "standard").get("error", "").is_empty(), "The selected Assault Cannon replaces the Heavy Bolter and resolves through Equipment")
	state.phase = "shooting"
	var assault_cannon_targets := AttackPlan.legal_targets(state, model, false, "assault-cannon", "standard")
	check(not assault_cannon_targets.is_empty(), "The selected Assault Cannon resolves legal ranged targets through AttackPlan")
	state.phase = "deployment"
	var restore_choice := choice_for(state, 1, "ravenwing-darkshroud-cannon", model, squad, "heavy-bolter")
	var restore_result := PublicUnitCommand.submit(state, 1, restore_choice)
	check(restore_result.get("error", "").is_empty() and state.units[model].ranged_weapons.map(func(item: Dictionary) -> String: return str(item.get("id", ""))) == ["heavy-bolter"], "The public setup choice restores the default Heavy Bolter")

	if failures == 0:
		print("Ravenwing Darkshroud checks passed")
	else:
		print("Ravenwing Darkshroud checks: %d failures" % failures)
	quit(1 if failures > 0 else 0)
