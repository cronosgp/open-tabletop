extends SceneTree

const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Catalog = preload("res://scripts/edition_11/army_capabilities.gd")
const Roster = preload("res://scripts/edition_11/roster_validation.gd")
const DeadlyDemise = preload("res://scripts/edition_11/deadly_demise.gd")
const UNIT := "typhon"
const UNIT_ID := "40kdc:11e:adeptus-astartes:typhon"
const A = C.UnitAbilities
const U = C.UnitActions

var failures := 0

func _initialize() -> void:
	call_deferred("run")

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

func choice_for(state: Dictionary, player: int, action: String, model: int, target: int, value: String) -> Dictionary:
	for option: Dictionary in U.choices(state, player):
		if str(option.get("action", "")) == action and int(option.get("model", -1)) == model and int(option.get("target", -1)) == target and str(option.get("value", "")) == value:
			return option
	return {}

func weapon_entry(loadout: Dictionary, category: String, weapon_id: String) -> Dictionary:
	for row: Dictionary in loadout.get(category, []):
		if str(row.get("id", "")) == weapon_id: return row
	return {}

func attack_plan(state: Dictionary, model: int, squad: int, target: int, weapon: String, melee: bool = false) -> Dictionary:
	return C.AttackPlan.prepare(state, squad, melee, [{"model": model, "target": target, "amount": 1, "weapon": weapon, "profile": "standard"}], false)

func run() -> void:
	var profile := Profiles.profile(UNIT)
	check(profile.get("source_book_id") == "000000356" and profile.get("source_datasheet_id") == "000000093" and profile.get("source_url", "").ends_with("/Typhon"), "The profile identifies the current Typhon Legends source sheet")
	check(profile.get("source_snapshot_id") == Profiles.VERIFIED_EXPORT_SNAPSHOT_ID and profile.get("source_manifest_sha256") == Profiles.VERIFIED_EXPORT_MANIFEST_SHA256 and profile.get("source_slice_manifest_sha256") == Profiles.VERIFIED_EXPORT_SLICE_SHA256_BY_BOOK["000000356"], "The profile records the verified local export provenance")
	check(profile.get("points_by_models", {}) == {1: 320} and profile.get("models") == 1 and profile.get("max_supported_copies") == 3 and profile.get("damaged_threshold") == 6, "The one-model cost, copy ceiling and Damaged 6 threshold are source-bounded")
	check(profile.get("base_size_source", "") == "Use model" and profile.get("base_geometry", "") == "circular-model-footprint-proxy" and str(profile.get("geometry_scope", "")).contains("60 mm") and str(profile.get("geometry_scope", "")).contains("not certified"), "The source's unspecified physical footprint is disclosed as a labelled proxy")
	check(profile.get("stats", {}) == {"movement_inches": 10, "toughness": 12, "save_target": 2, "wounds": 18, "leadership_target": 6, "objective_control": 6, "invulnerable_target": 0}, "All Typhon characteristics match the verified local export")
	check(profile.get("keywords", []) == ["ADEPTUS ASTARTES", "FRAME", "VEHICLE", "IMPERIUM", "SMOKE"], "All source keywords, including SMOKE, are represented")
	check(profile.get("default_loadout_by_role", {}).get("Typhon", {}) == {"Armoured Tracks": 1, "Dreadhammer Siege Cannon": 1}, "The source default loadout contains only the Siege Cannon and tracks")
	check(profile.get("special_rules", []) == ["Combat Doctrines", "Deadly Demise D6", "Damaged 6", "Sunderer of Fortresses"], "All source datasheet abilities are listed")
	var defaults := Profiles.typhon_weapons()
	check(defaults.get("ranged", []).size() == 1 and defaults.ranged[0].get("id", "") == "dreadhammer-siege-cannon", "The Dreadhammer Siege Cannon is the only default ranged weapon")
	check(defaults.get("melee", []).size() == 1 and defaults.melee[0].get("id", "") == "armoured-tracks", "Armoured Tracks is the default melee weapon")
	check(weapon_entry(defaults, "ranged", "dreadhammer-siege-cannon").profiles.standard == {"name": "Dreadhammer Siege Cannon", "range_inches": 24.0, "attacks": "D6+6", "skill": 3, "strength": 14, "ap": -3, "damage": "D3+3", "keywords": {"blast": 1}}, "The Siege Cannon preserves its complete export profile")
	check(weapon_entry(defaults, "melee", "armoured-tracks").profiles.standard == {"name": "Armoured Tracks", "range_inches": 0.0, "attacks": 6, "skill": 4, "strength": 8, "ap": 0, "damage": 1, "keywords": {}}, "Armoured Tracks preserves its complete export profile")
	var additions: Array = profile.get("additional_weapon_profiles", {}).get("ranged", [])
	check(additions.size() == 5, "All five source optional weapon profiles are stored")
	check(additions.any(func(row: Dictionary) -> bool: return row.id == "heavy-bolter" and row.profiles.standard == {"name": "Heavy Bolter", "range_inches": 36.0, "attacks": 3, "skill": 3, "strength": 5, "ap": -1, "damage": 2, "keywords": {"rapid-fire": 2, "sustained-hits": 1}}), "The Heavy Bolter preserves Rapid Fire 2 and Sustained Hits 1")
	check(additions.any(func(row: Dictionary) -> bool: return row.id == "heavy-flamer" and row.profiles.standard == {"name": "Heavy Flamer", "range_inches": 12.0, "attacks": 3, "skill": null, "strength": 5, "ap": -1, "damage": 1, "keywords": {"torrent": true, "blast": 2}}), "The Heavy Flamer preserves automatic hits, Torrent and Blast 2")
	check(additions.any(func(row: Dictionary) -> bool: return row.id == "lascannon" and row.profiles.standard == {"name": "Lascannon", "range_inches": 48.0, "attacks": 1, "skill": 3, "strength": 12, "ap": -3, "damage": "D3+3", "keywords": {}}), "The Lascannon preserves its full source profile")
	check(additions.any(func(row: Dictionary) -> bool: return row.id == "multi-melta" and row.profiles.standard == {"name": "Multi-melta", "range_inches": 18.0, "attacks": 2, "skill": 3, "strength": 10, "ap": -3, "damage": "D3+2", "keywords": {"melta": 3}}), "The Multi-melta preserves Melta 3 and its complete profile")
	check(additions.any(func(row: Dictionary) -> bool: return row.id == "storm-bolter" and row.profiles.standard == {"name": "Storm Bolter", "range_inches": 24.0, "attacks": 2, "skill": 3, "strength": 5, "ap": -1, "damage": 1, "keywords": {"rapid-fire": 2}}), "The Storm Bolter preserves Rapid Fire 2")
	check(Profiles.typhon_weapons("bad", "none").is_empty() and Profiles.typhon_weapons("none", "invented").is_empty(), "The loadout helper rejects all options absent from the datasheet")
	var legal_combinations := 0
	for sponsons: String in ["none", "two-heavy-bolters", "two-lascannons"]:
		for hull_weapon: String in ["none", "heavy-bolter", "heavy-flamer", "multi-melta", "storm-bolter"]:
			var loadout := Profiles.typhon_weapons(sponsons, hull_weapon)
			var pair_id := "heavy-bolter" if sponsons == "two-heavy-bolters" else "lascannon"
			var expected_pair_count := 2 if sponsons != "none" else 0
			if hull_weapon == pair_id: expected_pair_count += 1
			var actual_pair_count: int = loadout.ranged.filter(func(row: Dictionary) -> bool: return row.id == pair_id).size() if not loadout.is_empty() else 0
			check(not loadout.is_empty() and loadout.ranged.size() == 1 + int(hull_weapon != "none") + 2 * int(sponsons != "none") and actual_pair_count == expected_pair_count, "The independent Typhon options form a legal %s/%s loadout" % [sponsons, hull_weapon])
			if not loadout.is_empty(): legal_combinations += 1
	check(legal_combinations == 15, "All 15 legal combinations of optional sponsons and hull weapon are represented")
	var default_labels := Catalog.construction_readiness_note(UNIT)
	check(default_labels.contains("competitive events require organiser approval") and default_labels.contains("60 mm circular footprint proxy"), "Legends event restrictions and proxy geometry are visible in readiness metadata")
	check(Catalog.current_catalog_choice({"id": UNIT_ID, "edition": "11e", "faction": "Space Marines"}).get("options", []) == [{"models": 1, "cost": 320}], "The current catalog offers the source-priced Typhon")
	check(Roster.POINTS.get(UNIT, {}).get("sizes", {}) == {1: 320}, "Roster validation applies the source cost")
	var admitted := Catalog.admit({"schema_version": 2, "faction": "Space Marines", "category": "strike_force", "points_limit": 2000, "entries": [{"definition_id": UNIT_ID, "models": 1, "copies": 3}]})
	check(admitted.get("error", "").is_empty(), "Three Typhons are admitted at the configured Strike Force copy limit")
	var over_limit := Catalog.admit({"schema_version": 2, "faction": "Space Marines", "category": "strike_force", "points_limit": 2000, "entries": [{"definition_id": UNIT_ID, "models": 1, "copies": 4}]})
	check(not str(over_limit.get("error", "")).is_empty(), "A fourth Typhon is rejected by the repetition limit")

	var state := prepared()
	check(not state.has("error"), "Typhon materializes from the current local catalog: %s" % str(state.get("error", "")))
	if state.has("error"):
		quit(1)
		return
	var typhon_models := models(state, UNIT, 1)
	check(typhon_models.size() == 1, "One Typhon model enters the match")
	if typhon_models.is_empty():
		quit(1)
		return
	var model := typhon_models[0]
	var squad := int(state.units[model].squad)
	check(A.has(state, squad, "combat-doctrines") and A.has(state, squad, "deadly-demise-d6") and A.deadly_demise_value(state, model) == "D6" and A.has(state, squad, "damaged-6") and A.has(state, squad, "sunderer-of-fortresses"), "Combat Doctrines, Deadly Demise D6, Damaged 6 and Sunderer register on the live unit")
	check(C.CoreReactions.keyword(state, squad, "SMOKE"), "The source SMOKE keyword enables the shared Smokescreen gate")
	check(state.units[model].ranged_weapons.size() == 1 and state.units[model].melee_weapons.size() == 1 and state.units[model].get("typhon_sponsons") == "none" and state.units[model].get("typhon_hull_weapon") == "none", "The live unit starts with only source default equipment")
	var sponson_choice := choice_for(state, 1, "typhon-sponsons", model, squad, "two-heavy-bolters")
	var hull_choice := choice_for(state, 1, "typhon-hull-weapon", model, squad, "multi-melta")
	check(not sponson_choice.is_empty() and C.unit_action(state, 1, sponson_choice, Vector2.ZERO, state.revision).is_empty(), "Preparation accepts two source-listed Heavy Bolter sponsons")
	check(not hull_choice.is_empty() and C.unit_action(state, 1, hull_choice, Vector2.ZERO, state.revision).is_empty(), "The independent hull weapon choice accepts a Multi-melta")
	check(state.units[model].ranged_weapons.size() == 4 and state.units[model].ranged_weapons.filter(func(row: Dictionary) -> bool: return row.id == "heavy-bolter").size() == 2 and state.units[model].ranged_weapons.any(func(row: Dictionary) -> bool: return row.id == "multi-melta"), "Both option groups add exact source weapon counts without replacing the Siege Cannon")
	var invalid := {"action": "typhon-sponsons", "model": model, "target": squad, "value": "twin-lascannon"}
	check(not C.unit_action(state, 1, invalid, Vector2.ZERO, state.revision).is_empty(), "The public preparation action rejects an unlisted sponson choice")
	var lascannon_pair := choice_for(state, 1, "typhon-sponsons", model, squad, "two-lascannons")
	var flamer_choice := choice_for(state, 1, "typhon-hull-weapon", model, squad, "heavy-flamer")
	check(not lascannon_pair.is_empty() and C.unit_action(state, 1, lascannon_pair, Vector2.ZERO, state.revision).is_empty() and state.units[model].ranged_weapons.filter(func(row: Dictionary) -> bool: return row.id == "lascannon").size() == 2, "Preparation selects the alternative pair of two Lascannons")
	check(not flamer_choice.is_empty() and C.unit_action(state, 1, flamer_choice, Vector2.ZERO, state.revision).is_empty() and state.units[model].ranged_weapons.any(func(row: Dictionary) -> bool: return row.id == "heavy-flamer"), "The second option remains independent and can select a Heavy Flamer")
	var restore_sponsons := choice_for(state, 1, "typhon-sponsons", model, squad, "none")
	var restore_hull := choice_for(state, 1, "typhon-hull-weapon", model, squad, "none")
	check(not restore_sponsons.is_empty() and C.unit_action(state, 1, restore_sponsons, Vector2.ZERO, state.revision).is_empty(), "The optional sponson pair can be removed during preparation")
	check(not restore_hull.is_empty() and C.unit_action(state, 1, restore_hull, Vector2.ZERO, state.revision).is_empty() and state.units[model].ranged_weapons.size() == 1, "The optional hull weapon can be removed, restoring the exact default loadout")

	var enemy_squad := -1
	for candidate: int in state.squads:
		if int(state.squads[candidate].get("owner", -1)) == 2:
			enemy_squad = candidate
			break
	for target_model: int in state.units:
		if int(state.units[target_model].get("squad", -1)) == enemy_squad: state.units[target_model].position = Vector2(10.0, 0.0)
	state.units[model].position = Vector2.ZERO
	state.phase = "shooting"
	state.active = 1
	for target_model: int in state.units:
		if int(state.units[target_model].get("squad", -1)) == enemy_squad: state.units[target_model].keywords = ["VEHICLE"]
	var vehicle_plan := attack_plan(state, model, squad, enemy_squad, "dreadhammer-siege-cannon")
	check(vehicle_plan.get("error", "").is_empty() and vehicle_plan.get("batches", []).size() == 1 and vehicle_plan.batches[0].weapon.strength == 15 and vehicle_plan.batches[0].weapon.damage == "D3+4", "Sunderer gives all ranged attacks +1 Strength and Damage against a VEHICLE")
	var bolter_state := state.duplicate(true)
	bolter_state.units[model].ranged_weapons = Profiles.typhon_weapons("none", "heavy-bolter").ranged
	var bolter_plan := attack_plan(bolter_state, model, squad, enemy_squad, "heavy-bolter")
	check(bolter_plan.get("error", "").is_empty() and bolter_plan.batches[0].weapon.strength == 6 and bolter_plan.batches[0].weapon.damage == 3, "Sunderer also modifies an optional Heavy Bolter against VEHICLE")
	for target_model: int in state.units:
		if int(state.units[target_model].get("squad", -1)) == enemy_squad: state.units[target_model].keywords = ["FORTIFICATION"]
	var fortification_plan := attack_plan(state, model, squad, enemy_squad, "dreadhammer-siege-cannon")
	check(fortification_plan.get("error", "").is_empty() and fortification_plan.batches[0].weapon.strength == 16 and fortification_plan.batches[0].weapon.damage == "D3+5", "Sunderer gives +2 Strength and Damage against FORTIFICATION")
	var tracks: Dictionary = weapon_entry(Profiles.typhon_weapons(), "melee", "armoured-tracks").profiles.standard
	var melee_weapon: Dictionary = A.weapon(state, model, enemy_squad, tracks, true)
	check(melee_weapon.strength == 8 and melee_weapon.damage == 1, "Sunderer does not modify the Typhon's melee attack")
	state.units[model].wounds = 7
	check(A.damaged_attack_penalty(state, model) == 0, "Damaged 6 does not apply above six wounds")
	var above_threshold_plan := attack_plan(state, model, squad, enemy_squad, "dreadhammer-siege-cannon")
	check(above_threshold_plan.get("error", "").is_empty() and int(above_threshold_plan.batches[0].context.get("hit_modifier", 0)) == 0, "The live attack plan has no Damaged hit penalty above six remaining wounds")
	state.units[model].wounds = 6
	check(A.damaged_attack_penalty(state, model) == -1, "Damaged 6 applies at the exact threshold")
	var at_threshold_plan := attack_plan(state, model, squad, enemy_squad, "dreadhammer-siege-cannon")
	check(at_threshold_plan.get("error", "").is_empty() and int(at_threshold_plan.batches[0].context.get("hit_modifier", 0)) == -1, "The live attack plan applies -1 to Hit at the Damaged 6 threshold")
	state.units[model].wounds = 1
	check(A.damaged_attack_penalty(state, model) == -1, "Damaged 6 continues through the last remaining wound")
	state.units[model].wounds = 0
	check(A.damaged_attack_penalty(state, model) == 0, "A destroyed model no longer makes attacks and receives no Damaged modifier")
	var demise_state := state.duplicate(true)
	for target_model: int in demise_state.units:
		if int(demise_state.units[target_model].get("squad", -1)) == enemy_squad: demise_state.units[target_model].position = Vector2(5.0, 0.0)
	var demise := DeadlyDemise.begin(demise_state, [model], func() -> int: return 6)
	var pending_demise: Dictionary = demise_state.get("pending_deadly_demise", {})
	check(demise.get("error", "").is_empty() and pending_demise.get("events", []).size() == 1 and pending_demise.events[0].get("expression", "") == "D6" and pending_demise.get("packets", []).size() == 1 and pending_demise.packets[0].get("roll", {}).get("expression", "") == "D6", "A destroyed Typhon enters the shared Deadly Demise D6 trigger and mortal-wound sequence")

	if failures == 0:
		print("Typhon checks passed")
	else:
		print("Typhon checks: %d failures" % failures)
	quit(1 if failures > 0 else 0)
