extends SceneTree

const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Catalog = preload("res://scripts/edition_11/army_capabilities.gd")
const Roster = preload("res://scripts/edition_11/roster_validation.gd")
const DeadlyDemise = preload("res://scripts/edition_11/deadly_demise.gd")
const UNIT := "falchion"
const UNIT_ID := "40kdc:11e:adeptus-astartes:falchion"
const A = C.UnitAbilities
const U = C.UnitActions

var failures := 0

func _initialize() -> void:
	call_deferred("run")

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func selection(copies: int = 1) -> Dictionary:
	var result := F.current_marine_selections()
	result[1].entries.append({"definition_id": UNIT_ID, "models": 1, "copies": copies})
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
	check(profile.get("source_book_id") == "000000356" and profile.get("source_datasheet_id") == "000001666" and profile.get("source_scope") == "Warhammer Legends" and profile.get("source_url", "").ends_with("/Falchion"), "The profile identifies the exact Space Marines Legends Falchion sheet")
	check(profile.get("source_snapshot_id") == Profiles.VERIFIED_EXPORT_SNAPSHOT_ID and profile.get("source_manifest_sha256") == Profiles.VERIFIED_EXPORT_MANIFEST_SHA256 and profile.get("source_slice_manifest_sha256") == Profiles.VERIFIED_EXPORT_SLICE_SHA256_BY_BOOK["000000356"], "The profile records verified local export provenance")
	check(profile.get("points_by_models", {}) == {1: 420} and profile.get("second_plus_points_by_models", {}) == {1: 420} and profile.get("third_plus_points_by_models", {}) == {1: 420} and profile.get("max_supported_copies") == 3, "All three one-model price tiers and the three-copy limit are represented")
	check(profile.get("stats", {}) == {"movement_inches": 9, "toughness": 13, "save_target": 2, "wounds": 24, "leadership_target": 6, "objective_control": 8, "invulnerable_target": 0}, "All Falchion characteristics match the verified export")
	check(profile.get("keywords", []) == ["ADEPTUS ASTARTES", "FRAME", "SMOKE", "IMPERIUM", "TITANIC", "VEHICLE"], "All source keywords are represented")
	check(profile.get("default_loadout_by_role", {}).get("Falchion", {}) == {"Armoured Tracks": 1, "Quad Lascannon": 2, "Twin Falchion Volcano Cannon": 1, "Twin Heavy Bolter": 1}, "Default wargear matches the source sheet")
	check(profile.get("special_rules", []) == ["Combat Doctrines", "Deadly Demise D6+2", "Damaged 8", "Titan-killer"], "All four source abilities are represented")
	check(profile.get("base_size_source", "") == "Use model" and profile.get("base_geometry", "") == "circular-model-footprint-proxy" and str(profile.get("geometry_scope", "")).contains("60 mm") and str(profile.get("geometry_scope", "")).contains("not certified"), "The undefined physical footprint is transparently represented by a labelled proxy")

	var defaults := Profiles.falchion_weapons()
	check(defaults.get("ranged", []).size() == 4 and defaults.get("melee", []).size() == 1, "The default loadout contains the four source ranged rows and Armoured Tracks")
	check(weapon_entry(defaults, "ranged", "twin-falchion-volcano-cannon").profiles.standard == {"name": "Twin Falchion Volcano Cannon", "range_inches": 120.0, "attacks": "D3+1", "skill": 3, "strength": 24, "ap": -4, "damage": 12, "keywords": {"blast": 1, "twin-linked": true}}, "The Volcano Cannon preserves its full profile")
	check(defaults.ranged.filter(func(row: Dictionary) -> bool: return str(row.id).begins_with("quad-lascannon")).size() == 2 and weapon_entry(defaults, "ranged", "quad-lascannon").profiles.standard == {"name": "Quad Lascannon", "range_inches": 48.0, "attacks": 4, "skill": 3, "strength": 12, "ap": -3, "damage": "D3+3", "keywords": {}}, "Both source Quad Lascannons have full profiles")
	check(weapon_entry(defaults, "ranged", "twin-heavy-bolter").profiles.standard == {"name": "Twin Heavy Bolter", "range_inches": 36.0, "attacks": 3, "skill": 3, "strength": 5, "ap": -1, "damage": 2, "keywords": {"rapid-fire": 2, "twin-linked": true, "sustained-hits": 1}}, "The Twin Heavy Bolter preserves all weapon rules")
	check(weapon_entry(defaults, "melee", "armoured-tracks").profiles.standard == {"name": "Armoured Tracks", "range_inches": 0.0, "attacks": 6, "skill": 4, "strength": 8, "ap": 0, "damage": 1, "keywords": {}}, "Armoured Tracks preserves all melee characteristics")
	var additions: Array = profile.get("additional_weapon_profiles", {}).get("ranged", [])
	check(additions.size() == 8, "All eight additional source ranged weapon identities are stored")
	check(additions.any(func(row: Dictionary) -> bool: return row.id == "heavy-bolter" and row.profiles.standard == {"name": "Heavy Bolter", "range_inches": 36.0, "attacks": 3, "skill": 3, "strength": 5, "ap": -1, "damage": 2, "keywords": {"rapid-fire": 2, "sustained-hits": 1}}), "Heavy Bolter profile includes Sustained Hits 1")
	check(additions.any(func(row: Dictionary) -> bool: return row.id == "heavy-flamer" and row.profiles.standard == {"name": "Heavy Flamer", "range_inches": 12.0, "attacks": 3, "skill": null, "strength": 5, "ap": -1, "damage": 1, "keywords": {"torrent": true, "blast": 2}}), "Heavy Flamer has automatic hits, Torrent and Blast 2")
	check(additions.any(func(row: Dictionary) -> bool: return row.id == "laser-destroyer" and row.profiles.standard == {"name": "Laser Destroyer", "range_inches": 72.0, "attacks": 2, "skill": 3, "strength": 14, "ap": -3, "damage": "D6+3", "keywords": {"heavy": true}}), "Laser Destroyer preserves its Heavy profile")
	check(additions.any(func(row: Dictionary) -> bool: return row.id == "multi-melta" and row.profiles.standard == {"name": "Multi-melta", "range_inches": 18.0, "attacks": 2, "skill": 3, "strength": 10, "ap": -3, "damage": "D3+2", "keywords": {"melta": 3}}), "Multi-melta preserves Melta 3")
	check(additions.any(func(row: Dictionary) -> bool: return row.id == "storm-bolter" and row.profiles.standard.keywords == {"rapid-fire": 2}), "Storm Bolter preserves Rapid Fire 2")
	check(additions.any(func(row: Dictionary) -> bool: return row.id == "twin-heavy-flamer" and row.profiles.standard == {"name": "Twin Heavy Flamer", "range_inches": 12.0, "attacks": 3, "skill": null, "strength": 5, "ap": -1, "damage": 1, "keywords": {"blast": 2, "twin-linked": true, "torrent": true}}), "Twin Heavy Flamer preserves Torrent, Blast and Twin-linked")
	check(Profiles.falchion_weapons("invalid").is_empty() and Profiles.falchion_weapons("none", "invalid").is_empty() and Profiles.falchion_weapons("none", "quad-lascannons", "invalid").is_empty(), "The loadout helper rejects every unlisted option")
	var combinations := 0
	for optional_weapon: String in ["none", "heavy-bolter", "heavy-flamer", "multi-melta", "storm-bolter"]:
		for main_armament: String in ["quad-lascannons", "laser-destroyers"]:
			for twin_replacement: String in ["twin-heavy-bolter", "twin-heavy-flamer"]:
				var loadout := Profiles.falchion_weapons(optional_weapon, main_armament, twin_replacement)
				var expected_main := "quad-lascannon" if main_armament == "quad-lascannons" else "laser-destroyer"
				var expected_twin := twin_replacement
				check(not loadout.is_empty() and loadout.ranged.size() == 4 + int(optional_weapon != "none") and loadout.ranged.filter(func(row: Dictionary) -> bool: return str(row.id).begins_with(expected_main)).size() == 2 and loadout.ranged.any(func(row: Dictionary) -> bool: return row.id == expected_twin), "Each independent option combination remains a complete legal loadout")
				if not loadout.is_empty(): combinations += 1
	check(combinations == 20, "All 20 source-listed Falchion loadout combinations are available")
	var readiness := Catalog.construction_readiness_note(UNIT)
	check(readiness.contains("competitive events require organiser approval") and readiness.contains("60 mm circle proxy"), "The Legends event rule and footprint proxy appear in the readiness note")
	var catalog_choice := Catalog.current_catalog_choice({"id": UNIT_ID, "edition": "11e", "faction": "Space Marines"})
	check(catalog_choice.get("options", []).size() == 1 and catalog_choice.options[0] == {"models": 1, "cost": 420, "second_plus_cost": 420, "third_plus_cost": 420}, "The current catalog offers all source price tiers for the Falchion")
	check(Roster.POINTS.get(UNIT, {}).get("sizes", {}) == {1: 420}, "Roster validation applies the source cost")
	var admitted := Catalog.admit({"schema_version": 2, "faction": "Space Marines", "category": "strike_force", "points_limit": 2000, "entries": [{"definition_id": UNIT_ID, "models": 1, "copies": 3}]})
	check(admitted.get("error", "").is_empty(), "Three Falchions are admitted at the ordinary copy limit")
	var over_limit := Catalog.admit({"schema_version": 2, "faction": "Space Marines", "category": "strike_force", "points_limit": 2000, "entries": [{"definition_id": UNIT_ID, "models": 1, "copies": 4}]})
	check(not str(over_limit.get("error", "")).is_empty(), "A fourth Falchion is rejected by the repetition limit")

	var state := prepared()
	check(not state.has("error"), "The Falchion materializes from the current Marine catalog: %s" % str(state.get("error", "")))
	if state.has("error"):
		quit(1)
		return
	var falchion_models := models(state, UNIT, 1)
	check(falchion_models.size() == 1, "The admitted Falchion materializes as one model")
	if falchion_models.is_empty():
		quit(1)
		return
	var model := falchion_models[0]
	var squad := int(state.units[model].squad)
	check(A.has(state, squad, "combat-doctrines") and A.has(state, squad, "deadly-demise-d6-plus-two") and A.deadly_demise_value(state, model) == "D6+2" and A.has(state, squad, "damaged-8") and A.has(state, squad, "titan-killer"), "All Falchion rules register on the live catalog unit")
	check(C.CoreReactions.keyword(state, squad, "SMOKE"), "The source SMOKE keyword enables the shared Smokescreen gate")
	check(state.units[model].ranged_weapons.size() == 4 and state.units[model].melee_weapons.size() == 1, "The live unit starts with its exact default weapons")
	var optional_choice := choice_for(state, 1, "falchion-optional-weapon", model, squad, "multi-melta")
	var main_choice := choice_for(state, 1, "falchion-main-armament", model, squad, "laser-destroyers")
	var twin_choice := choice_for(state, 1, "falchion-twin-replacement", model, squad, "twin-heavy-flamer")
	check(not optional_choice.is_empty() and C.unit_action(state, 1, optional_choice, Vector2.ZERO, state.revision).is_empty(), "The public preparation choice adds one optional Multi-melta")
	check(not main_choice.is_empty() and C.unit_action(state, 1, main_choice, Vector2.ZERO, state.revision).is_empty(), "The public preparation choice replaces both Quad Lascannons with Laser Destroyers")
	check(not twin_choice.is_empty() and C.unit_action(state, 1, twin_choice, Vector2.ZERO, state.revision).is_empty(), "The public preparation choice replaces the Twin Heavy Bolter with its source-listed Twin Heavy Flamer")
	check(state.units[model].ranged_weapons.size() == 5 and state.units[model].ranged_weapons.filter(func(row: Dictionary) -> bool: return str(row.id).begins_with("laser-destroyer")).size() == 2 and state.units[model].ranged_weapons.any(func(row: Dictionary) -> bool: return row.id == "twin-heavy-flamer") and state.units[model].ranged_weapons.any(func(row: Dictionary) -> bool: return row.id == "multi-melta"), "All three selected loadout choices update the live weapon array")
	var invalid := {"action": "falchion-main-armament", "model": model, "target": squad, "value": "twin-lascannons"}
	check(not C.unit_action(state, 1, invalid, Vector2.ZERO, state.revision).is_empty(), "The public action rejects an unlisted main armament")

	var enemy_squad := -1
	for candidate: int in state.squads:
		if int(state.squads[candidate].get("owner", -1)) == 2:
			enemy_squad = candidate
			break
	check(enemy_squad >= 0, "The fixture includes an opposing unit for target-gated rules")
	if enemy_squad < 0:
		quit(1)
		return
	for target_model: int in state.units:
		if int(state.units[target_model].get("squad", -1)) == enemy_squad:
			state.units[target_model].position = Vector2(10.0, 0.0)
			state.units[target_model].keywords = ["MONSTER"]
		state.units[target_model].position = Vector2(20.0, 0.0)
	state.units[model].position = Vector2.ZERO
	for target_model: int in state.units:
		if int(state.units[target_model].get("squad", -1)) == enemy_squad: state.units[target_model].position = Vector2(10.0, 0.0)
	state.phase = "shooting"
	state.active = 1
	var monster_plan := attack_plan(state, model, squad, enemy_squad, "twin-falchion-volcano-cannon")
	check(monster_plan.get("error", "").is_empty() and monster_plan.get("batches", []).size() == 1 and monster_plan.batches[0].weapon.keywords.get("devastating-wounds", false), "Titan-killer grants Devastating Wounds to the Twin Falchion Volcano Cannon against MONSTER")
	for target_model: int in state.units:
		if int(state.units[target_model].get("squad", -1)) == enemy_squad: state.units[target_model].keywords = ["VEHICLE"]
	var vehicle_plan := attack_plan(state, model, squad, enemy_squad, "twin-falchion-volcano-cannon")
	check(vehicle_plan.get("error", "").is_empty() and vehicle_plan.batches[0].weapon.keywords.get("devastating-wounds", false), "Titan-killer grants Devastating Wounds against VEHICLE")
	for target_model: int in state.units:
		if int(state.units[target_model].get("squad", -1)) == enemy_squad: state.units[target_model].keywords = ["INFANTRY"]
	var infantry_plan := attack_plan(state, model, squad, enemy_squad, "twin-falchion-volcano-cannon")
	check(infantry_plan.get("error", "").is_empty() and not infantry_plan.batches[0].weapon.keywords.get("devastating-wounds", false), "Titan-killer does not affect Volcano Cannon attacks against other targets")
	for target_model: int in state.units:
		if int(state.units[target_model].get("squad", -1)) == enemy_squad: state.units[target_model].keywords = ["MONSTER"]
	var lascannon_plan := attack_plan(state, model, squad, enemy_squad, "laser-destroyer")
	check(lascannon_plan.get("error", "").is_empty() and not lascannon_plan.batches[0].weapon.keywords.get("devastating-wounds", false), "Titan-killer does not modify a different ranged weapon")
	state.units[model].wounds = 9
	check(A.damaged_attack_penalty(state, model) == 0, "Damaged 8 does not apply above eight wounds")
	var above_threshold := attack_plan(state, model, squad, enemy_squad, "twin-falchion-volcano-cannon")
	check(above_threshold.get("error", "").is_empty() and int(above_threshold.batches[0].context.get("hit_modifier", 0)) == 0, "The live attack plan has no Damaged penalty above eight wounds")
	state.units[model].wounds = 8
	check(A.damaged_attack_penalty(state, model) == -1, "Damaged 8 applies at the exact threshold")
	var at_threshold := attack_plan(state, model, squad, enemy_squad, "twin-falchion-volcano-cannon")
	check(at_threshold.get("error", "").is_empty() and int(at_threshold.batches[0].context.get("hit_modifier", 0)) == -1, "The live attack plan applies -1 to Hit at eight wounds")
	state.units[model].wounds = 1
	check(A.damaged_attack_penalty(state, model) == -1, "Damaged 8 continues through the last remaining wound")
	state.units[model].wounds = 0
	check(A.damaged_attack_penalty(state, model) == 0, "A destroyed Falchion no longer receives the Damaged modifier")
	var demise_state := state.duplicate(true)
	for target_model: int in demise_state.units:
		if int(demise_state.units[target_model].get("squad", -1)) == enemy_squad: demise_state.units[target_model].position = Vector2(5.0, 0.0)
	var rolls := [6, 3]
	var demise := DeadlyDemise.begin(demise_state, [model], func() -> int: return int(rolls.pop_front()))
	var pending: Dictionary = demise_state.get("pending_deadly_demise", {})
	check(demise.get("error", "").is_empty() and pending.get("events", []).size() == 1 and pending.events[0].get("expression", "") == "D6+2" and pending.get("packets", []).size() == 1 and pending.packets[0].get("roll", {}).get("expression", "") == "D6+2" and int(pending.packets[0].get("remaining", 0)) == 5, "A 6 on the trigger resolves a separate D6+2 mortal-wound packet for a unit within 6 inches")

	if failures == 0:
		print("Falchion checks passed")
	else:
		print("Falchion checks: %d failures" % failures)
	quit(1 if failures > 0 else 0)
