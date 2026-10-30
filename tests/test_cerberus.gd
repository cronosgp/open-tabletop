extends SceneTree

const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Catalog = preload("res://scripts/edition_11/army_capabilities.gd")
const Roster = preload("res://scripts/edition_11/roster_validation.gd")
const DeadlyDemise = preload("res://scripts/edition_11/deadly_demise.gd")
const UNIT := "cerberus"
const UNIT_ID := "40kdc:11e:adeptus-astartes:cerberus"
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
	var state: Dictionary = F.P.initial_state({
		"checked_rosters": false, "official_mission": false, "unit_abilities": true,
		"combat_doctrines": true, "core_stratagems": true, "attack_rerolls": true,
		"manual_allocation": false
	}, selection())
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
	check(profile.get("source_book_id") == "000000356" and profile.get("source_datasheet_id") == "000001153", "The profile identifies Cerberus in the verified Space Marines Legends book")
	check(profile.get("source_snapshot_id") == Profiles.VERIFIED_EXPORT_SNAPSHOT_ID and profile.get("source_manifest_sha256") == Profiles.VERIFIED_EXPORT_MANIFEST_SHA256 and profile.get("source_slice_manifest_sha256") == Profiles.VERIFIED_EXPORT_SLICE_SHA256_BY_BOOK["000000356"], "The profile records its verified export provenance")
	check(profile.get("points_by_models", {}) == {1: 270} and profile.get("models") == 1 and profile.get("max_supported_copies") == 3, "The one-model 270-point cost and copy ceiling match the source")
	check(profile.get("base_size_source", "") == "Use model" and str(profile.get("geometry_scope", "")).contains("60 mm circular footprint proxy"), "The source-defined footprint limitation and labelled proxy are disclosed")
	check(profile.get("stats", {}) == {"movement_inches": 10, "toughness": 12, "save_target": 2, "wounds": 18, "leadership_target": 6, "objective_control": 6, "invulnerable_target": 0}, "All Cerberus characteristics match the local export")
	check(profile.get("keywords", []) == ["ADEPTUS ASTARTES", "FRAME", "IMPERIUM", "VEHICLE", "SMOKE"], "All source keywords are represented")
	check(profile.get("default_loadout_by_role", {}).get("Cerberus", {}) == {"Armoured Tracks": 1, "Cerberus Neutron Pulse Array": 1}, "The source default loadout contains only the tracks and pulse array")
	var main := Profiles.cerberus_weapons()
	check(main.get("ranged", []).size() == 1 and main.ranged[0].get("id", "") == "cerberus-neutron-pulse-array" and main.ranged[0].profiles.standard == {"name": "Cerberus Neutron Pulse Array", "range_inches": 48.0, "attacks": 3, "skill": 3, "strength": 16, "ap": -3, "damage": "D3+6", "keywords": {"twin-linked": true}}, "The fixed neutron pulse array matches its complete export profile")
	check(main.get("melee", []).size() == 1 and main.melee[0].profiles.standard == {"name": "Armoured Tracks", "range_inches": 0.0, "attacks": 6, "skill": 4, "strength": 8, "ap": 0, "damage": 1, "keywords": {}}, "Armoured Tracks matches its complete export profile")
	var all_options := Profiles.cerberus_weapons("multi-melta", "two-heavy-bolters")
	check(all_options.get("ranged", []).size() == 4 and all_options.ranged.filter(func(row: Dictionary) -> bool: return row.get("id", "") == "heavy-bolter").size() == 2 and all_options.ranged.any(func(row: Dictionary) -> bool: return row.get("id", "") == "multi-melta"), "The optional weapon and pair groups can be equipped independently")
	var lascannon_pair := Profiles.cerberus_weapons("heavy-flamer", "two-lascannons")
	check(lascannon_pair.get("ranged", []).filter(func(row: Dictionary) -> bool: return row.get("id", "") == "lascannon").size() == 2 and lascannon_pair.ranged.any(func(row: Dictionary) -> bool: return row.get("id", "") == "heavy-flamer"), "The legal alternative pair adds two Lascannons without replacing the optional weapon group")
	check(Profiles.cerberus_weapons("twin-lascannon", "none").is_empty() and Profiles.cerberus_weapons("none", "twin-lascannon").is_empty(), "The loadout helper rejects replacements absent from the datasheet")
	var additions: Array = profile.get("additional_weapon_profiles", {}).get("ranged", [])
	check(additions.size() == 5 and additions.any(func(row: Dictionary) -> bool: return row.id == "heavy-bolter" and row.profiles.standard == {"name": "Heavy Bolter", "range_inches": 36.0, "attacks": 3, "skill": 3, "strength": 5, "ap": -1, "damage": 2, "keywords": {"rapid-fire": 2, "sustained-hits": 1}}), "The optional Heavy Bolter keeps Rapid Fire 2 and Sustained Hits 1")
	check(additions.any(func(row: Dictionary) -> bool: return row.id == "heavy-flamer" and row.profiles.standard == {"name": "Heavy Flamer", "range_inches": 12.0, "attacks": 3, "skill": null, "strength": 5, "ap": -1, "damage": 1, "keywords": {"blast": 2, "torrent": true}}), "The Heavy Flamer keeps its Torrent and Blast 2 rules and automatic Hit characteristic")
	check(additions.any(func(row: Dictionary) -> bool: return row.id == "multi-melta" and row.profiles.standard == {"name": "Multi-melta", "range_inches": 18.0, "attacks": 2, "skill": 3, "strength": 10, "ap": -3, "damage": "D3+2", "keywords": {"melta": 3}}), "The Multi-melta matches its full profile and Melta 3")
	check(additions.any(func(row: Dictionary) -> bool: return row.id == "storm-bolter" and row.profiles.standard == {"name": "Storm Bolter", "range_inches": 24.0, "attacks": 2, "skill": 3, "strength": 5, "ap": -1, "damage": 1, "keywords": {"rapid-fire": 2}}), "The Storm Bolter matches its full profile and Rapid Fire 2")
	check(additions.any(func(row: Dictionary) -> bool: return row.id == "lascannon" and row.profiles.standard == {"name": "Lascannon", "range_inches": 48.0, "attacks": 1, "skill": 3, "strength": 12, "ap": -3, "damage": "D3+3", "keywords": {}}), "The Lascannon option matches its complete source profile")
	check(Catalog.construction_readiness_note(UNIT).contains("competitive events require organiser approval") and Catalog.construction_readiness_note(UNIT).contains("exact physical clearance is not certified"), "The Legends event-use and geometry boundaries are published")
	check(Catalog.current_catalog_choice({"id": UNIT_ID, "edition": "11e", "faction": "Space Marines"}).get("options", []) == [{"models": 1, "cost": 270}], "The consolidated catalog exposes the source-priced one-model unit")
	check(Roster.POINTS.get(UNIT, {}).get("sizes", {}) == {1: 270}, "Roster validation applies the source cost")
	var admitted := Catalog.admit({"schema_version": 2, "faction": "Space Marines", "category": "strike_force", "points_limit": 2000, "entries": [{"definition_id": UNIT_ID, "models": 1, "copies": 3}]})
	check(admitted.get("error", "").is_empty(), "The source-legal three-copy ceiling can be admitted in Strike Force")
	var over_limit := Catalog.admit({"schema_version": 2, "faction": "Space Marines", "category": "strike_force", "points_limit": 2000, "entries": [{"definition_id": UNIT_ID, "models": 1, "copies": 4}]})
	check(not str(over_limit.get("error", "")).is_empty(), "A fourth Cerberus is rejected by the repetition limit")

	var state := prepared()
	check(not state.has("error"), "Cerberus materializes from the current local catalog: %s" % str(state.get("error", "")))
	if state.has("error"):
		print("Cerberus checks: %d failures" % (failures + 1))
		quit(1)
		return
	var cerberus_models := models(state, UNIT, 1)
	check(cerberus_models.size() == 1, "A single Cerberus model enters the match")
	if cerberus_models.is_empty():
		print("Cerberus checks: %d failures" % (failures + 1))
		quit(1)
		return
	var model: int = cerberus_models[0]
	var squad := int(state.units[model].squad)
	check(A.has(state, squad, "deadly-demise-d6") and A.deadly_demise_value(state, model) == "D6" and A.has(state, squad, "combat-doctrines") and A.has(state, squad, "atomantic-arc-reactor"), "Deadly Demise D6, Combat Doctrines and Atomantic Arc-reactor are registered")
	check(state.units[model].ranged_weapons.size() == 1 and state.units[model].get("cerberus_optional_weapon") == "none" and state.units[model].get("cerberus_optional_pair") == "none", "The match starts with only the source default weapons")
	var optional_weapon_choice := choice_for(state, 1, "cerberus-optional-weapon", model, squad, "heavy-flamer")
	var optional_pair_choice := choice_for(state, 1, "cerberus-optional-pair", model, squad, "two-lascannons")
	check(not optional_weapon_choice.is_empty() and C.unit_action(state, 1, optional_weapon_choice, Vector2.ZERO, state.revision).is_empty(), "Army preparation accepts one source-listed optional weapon")
	check(not optional_pair_choice.is_empty() and C.unit_action(state, 1, optional_pair_choice, Vector2.ZERO, state.revision).is_empty(), "Army preparation independently accepts one source-listed optional pair")
	check(state.units[model].ranged_weapons.size() == 4 and state.units[model].ranged_weapons.filter(func(row: Dictionary) -> bool: return row.get("id", "") == "lascannon").size() == 2 and state.units[model].ranged_weapons.any(func(row: Dictionary) -> bool: return row.get("id", "") == "heavy-flamer"), "The chosen weapons replace no default weapon and materialize with exact counts")
	var invalid_choice := {"action": "cerberus-optional-pair", "model": model, "target": squad, "value": "twin-lascannon"}
	check(not C.unit_action(state, 1, invalid_choice, Vector2.ZERO, state.revision).is_empty(), "A non-datasheet pair is rejected by the public preparation command")
	var restore_weapon := choice_for(state, 1, "cerberus-optional-weapon", model, squad, "none")
	var restore_pair := choice_for(state, 1, "cerberus-optional-pair", model, squad, "none")
	check(not restore_weapon.is_empty() and C.unit_action(state, 1, restore_weapon, Vector2.ZERO, state.revision).is_empty(), "The optional weapon can be removed during preparation")
	check(not restore_pair.is_empty() and C.unit_action(state, 1, restore_pair, Vector2.ZERO, state.revision).is_empty() and state.units[model].ranged_weapons.size() == 1, "The optional pair can be removed, restoring the exact default loadout")

	var enemy_squad := -1
	for enemy: int in state.squads:
		if int(state.squads[enemy].get("owner", -1)) == 2:
			enemy_squad = enemy
			break
	for target_model: int in state.units:
		if int(state.units[target_model].get("squad", -1)) == enemy_squad: state.units[target_model].position = Vector2(4, 0)
	state.units[model].position = Vector2.ZERO
	state.phase = "shooting"
	state.active = 1
	var stationary_plan := C.AttackPlan.prepare(state, squad, false, [{"model": model, "target": enemy_squad, "amount": 1, "weapon": "cerberus-neutron-pulse-array", "profile": "standard"}], false)
	check(stationary_plan.get("error", "").is_empty() and stationary_plan.get("batches", []).size() == 1 and stationary_plan.batches[0].weapon.keywords.get("lethal-hits", false), "A stationary unit gains Lethal Hits on the neutron pulse array only")
	var moved_state := state.duplicate(true)
	moved_state.squads[squad].moved_distance = 1.0
	var moved_plan := C.AttackPlan.prepare(moved_state, squad, false, [{"model": model, "target": enemy_squad, "amount": 1, "weapon": "cerberus-neutron-pulse-array", "profile": "standard"}], false)
	check(moved_plan.get("error", "").is_empty() and not moved_plan.batches[0].weapon.keywords.get("lethal-hits", false), "Movement during the turn suppresses Atomantic Arc-reactor")
	var set_up_state := state.duplicate(true)
	set_up_state.squads[squad].set_up_this_turn = true
	var set_up_plan := C.AttackPlan.prepare(set_up_state, squad, false, [{"model": model, "target": enemy_squad, "amount": 1, "weapon": "cerberus-neutron-pulse-array", "profile": "standard"}], false)
	check(set_up_plan.get("error", "").is_empty() and not set_up_plan.batches[0].weapon.keywords.get("lethal-hits", false), "Setting up this turn suppresses the stationary ability")
	for marker: String in ["advanced", "fell_back"]:
		var special_move_state := state.duplicate(true)
		special_move_state.squads[squad][marker] = true
		check(not C.AttackPlan._stationary(special_move_state, squad), "%s during the turn suppresses Atomantic Arc-reactor" % marker.capitalize())
	var model_moved_state := state.duplicate(true)
	model_moved_state.units[model].moved = true
	var model_moved_plan := C.AttackPlan.prepare(model_moved_state, squad, false, [{"model": model, "target": enemy_squad, "amount": 1, "weapon": "cerberus-neutron-pulse-array", "profile": "standard"}], false)
	check(model_moved_plan.get("error", "").is_empty() and not model_moved_plan.batches[0].weapon.keywords.get("lethal-hits", false), "A moved model suppresses the stationary ability")
	var bolter_state := state.duplicate(true)
	bolter_state.units[model].ranged_weapons = Profiles.cerberus_weapons("heavy-bolter", "none").ranged
	var bolter_plan := C.AttackPlan.prepare(bolter_state, squad, false, [{"model": model, "target": enemy_squad, "amount": 1, "weapon": "heavy-bolter", "profile": "standard"}], false)
	check(bolter_plan.get("error", "").is_empty() and bolter_plan.get("batches", []).size() == 1 and not bolter_plan.batches[0].weapon.keywords.get("lethal-hits", false), "The stationary rule leaves the optional Heavy Bolter unchanged")

	state.units[model].wounds = 0
	var demise := DeadlyDemise.begin(state, [model], func() -> int: return 6)
	check(demise.get("error", "").is_empty() and not state.get("pending_deadly_demise", {}).is_empty(), "Destroyed Cerberus enters the shared Deadly Demise sequence")
	if not state.get("pending_deadly_demise", {}).is_empty():
		var pending: Dictionary = state.pending_deadly_demise
		check(pending.get("events", []).size() == 1 and pending.events[0].get("expression", "") == "D6" and pending.get("packets", []).size() == 1 and pending.packets[0].get("roll", {}).get("expression", "") == "D6" and pending.packets[0].get("remaining", 0) == 6, "Deadly Demise uses an unmodified trigger 6 and rolls six mortal wounds per affected unit")

	if failures == 0:
		print("Cerberus checks passed")
	else:
		print("Cerberus checks: %d failures" % failures)
	quit(1 if failures > 0 else 0)
