extends SceneTree

const F = preload("res://tests/all_units_fixture.gd")
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Catalog = preload("res://scripts/edition_11/army_capabilities.gd")
const LocalCatalog = preload("res://scripts/implemented_army_catalog.gd")
const Transport = preload("res://scripts/edition_11/transport_rules.gd")
const Equipment = preload("res://scripts/edition_11/equipment.gd")
const Geometry = preload("res://scripts/edition_11/contact_movement.gd")
const UnitActions = preload("res://scripts/edition_11/unit_actions.gd")
const PublicUnitCommand = preload("res://tests/public_unit_command.gd")
const A = preload("res://scripts/edition_11/unit_abilities.gd")
const Stratagems = preload("res://scripts/edition_11/stratagems.gd")
const UNIT := "rhino-primaris"
const UNIT_ID := "40kdc:11e:adeptus-astartes:rhino-primaris"

var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func selection() -> Dictionary:
	var result := F.current_marine_selections()
	result[1].category = "strike_force"
	result[1].points_limit = 2000
	result[2].category = "strike_force"
	result[2].points_limit = 2000
	result[1].entries.append({"definition_id": UNIT_ID, "models": 1, "copies": 3})
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

func models(state: Dictionary, identity: String, owner: int = -1) -> Array[int]:
	var result: Array[int] = []
	for model: int in state.get("units", {}):
		var unit: Dictionary = state.units[model]
		if A.identity(unit) != identity: continue
		if owner >= 0 and int(unit.get("owner", -1)) != owner: continue
		result.append(model)
	result.sort()
	return result

func squad_for_identity(state: Dictionary, identity: String, owner: int, strength: int = -1) -> int:
	for squad: int in state.get("squads", {}):
		if int(state.squads[squad].get("owner", -1)) != owner: continue
		if strength >= 0 and int(state.squads[squad].get("starting_strength", -1)) != strength: continue
		for model: int in state.units:
			if int(state.units[model].get("squad", -1)) == squad and A.identity(state.units[model]) == identity: return squad
	return -1

func weapon_profile(rows: Array, weapon_id: String, profile_name: String = "standard") -> Dictionary:
	for row: Dictionary in rows:
		if str(row.get("id", "")) == weapon_id:
			return row.get("profiles", {}).get(profile_name, {})
	return {}

func run() -> void:
	var profile := Profiles.profile(UNIT)
	check(profile.get("name") == "Rhino Primaris" and profile.get("source_book_id") == "000000356" and profile.get("source_datasheet_id") == "000000085" and profile.get("source_scope") == "Warhammer Legends", "The sheet binds to its exact Legends source identity")
	check(profile.get("source_snapshot_id") == Profiles.VERIFIED_EXPORT_SNAPSHOT_ID and profile.get("source_manifest_sha256") == Profiles.VERIFIED_EXPORT_MANIFEST_SHA256 and profile.get("source_slice_manifest_sha256") == Profiles.VERIFIED_EXPORT_SLICE_SHA256_BY_BOOK["000000356"], "The profile records the pinned local export snapshot and both manifest hashes")
	check(str(profile.get("source_retrieved_at_utc", "")).begins_with("2026-10-30T01:33:48") and profile.get("source_files", []).size() == 8, "The profile records its source retrieval time and all eight CSV checksums")
	check(profile.get("points_by_models", {}) == {1: 95} and profile.get("second_plus_points_by_models", {}) == {1: 95} and profile.get("third_plus_points_by_models", {}) == {1: 95} and profile.get("models") == 1 and profile.get("max_supported_copies") == 3, "All three source price tiers and the one-model composition match")
	check(profile.get("stats", {}) == {"movement_inches": 12, "toughness": 9, "save_target": 3, "wounds": 10, "leadership_target": 6, "objective_control": 3, "invulnerable_target": 0}, "Every characteristic matches the source model row")
	check(profile.get("keywords", []) == ["ADEPTUS ASTARTES", "TRANSPORT", "IMPERIUM", "SMOKE", "VEHICLE", "FRAME"] and "DEDICATED TRANSPORT" not in profile.get("keywords", []), "Source keywords are exact and do not add Dedicated Transport")
	check(profile.get("base_size_source") == "Use model" and is_equal_approx(float(profile.get("base_radius_inches", 0.0)), 60.0 / 25.4) and str(profile.get("geometry_scope", "")).contains("120 mm circular footprint proxy"), "Unspecified hull footprint stays labelled as a 120 mm geometry proxy")
	check(weapon_profile(profile.get("ranged", []), "twin-plasma-gun", "standard") == {"name": "Twin Plasma Gun - Standard", "range_inches": 24.0, "attacks": 1, "skill": 3, "strength": 7, "ap": -2, "damage": 1, "keywords": {"rapid-fire": 1, "twin-linked": true}}, "The standard Twin Plasma Gun profile is complete")
	check(weapon_profile(profile.get("ranged", []), "twin-plasma-gun", "supercharge") == {"name": "Twin Plasma Gun - Supercharge", "range_inches": 24.0, "attacks": 1, "skill": 3, "strength": 8, "ap": -3, "damage": 2, "keywords": {"rapid-fire": 1, "hazardous": true, "twin-linked": true}}, "The supercharged Twin Plasma Gun retains Hazardous and Twin-linked")
	check(weapon_profile(profile.get("melee", []), "armoured-tracks") == {"name": "Armoured Tracks", "range_inches": 0.0, "attacks": 3, "skill": 4, "strength": 6, "ap": 0, "damage": 1, "keywords": {}}, "The Armoured Tracks melee profile is complete")
	check(weapon_profile(profile.get("additional_weapon_profiles", {}).get("ranged", []), "hunter-killer-missile") == {"name": "Hunter-killer Missile", "range_inches": 48.0, "attacks": 1, "skill": 2, "strength": 14, "ap": -3, "damage": "D3+3", "keywords": {"one-shot": true}}, "The optional Hunter-killer Missile retains its One Shot rule and exact profile")
	check(profile.get("transport", {}).get("capacity") == 6 and profile.transport.get("required", []) == ["ADEPTUS ASTARTES", "INFANTRY"] and profile.transport.get("forbidden", []) == ["JUMP PACK", "GRAVIS", "CENTURION", "TERMINATOR"] and profile.transport.get("options", {}).get("add", []) == ["Hunter-killer Missile"], "Transport capacity, passenger keywords and equipment option match the source")
	check(profile.get("special_rules", []) == ["Combat Doctrines", "Deadly Demise D3", "Self-repair", "Orbital Comms Array"], "All and only the Rhino Primaris datasheet abilities are listed")
	check(profile.get("transport", {}).get("abilities", []).size() == 1 and profile.transport.abilities[0].get("name") == "Deadly Demise" and profile.transport.abilities[0].get("parameter") == "D3", "The transport rule record carries Deadly Demise D3 without inheriting Rhino abilities")

	var readiness := Catalog.construction_readiness_note(UNIT)
	check(readiness.contains("competitive events require organiser approval") and readiness.contains("95 points") and readiness.contains("120 mm circle proxy"), "Construction explains Legends use, source points and geometry limits")
	var catalog := LocalCatalog.new()
	root.add_child(catalog)
	check(catalog.select_edition("11e").is_empty(), "The consolidated 11e local catalog builds")
	var choice := catalog.lookup(UNIT_ID)
	check(not choice.is_empty() and choice.source_scope == "Warhammer Legends" and choice.options == [{"models": 1, "cost": 95, "second_plus_cost": 95, "third_plus_cost": 95}], "The source-bounded profile appears as a construction choice at only its three source prices")
	var roster := {"schema_version": 2, "faction": "Space Marines", "category": "strike_force", "points_limit": 2000, "entries": [{"definition_id": UNIT_ID, "models": 1, "copies": 3}]}
	var admitted := Catalog.admit(roster)
	check(admitted.get("error", "").is_empty() and admitted.total == 285 and admitted.unit_count == 3, "Three copies are admitted and cost 285 points in Strike Force")
	roster.entries[0].copies = 4
	check(not str(Catalog.admit(roster).get("error", "")).is_empty(), "A fourth copy is rejected by the Strike Force datasheet repetition limit")
	var incursion := roster.duplicate(true)
	incursion.category = "incursion"
	incursion.points_limit = 1000
	incursion.entries[0].copies = 2
	var incursion_admission := Catalog.admit(incursion)
	check(incursion_admission.get("error", "").is_empty() and incursion_admission.total == 190, "Two copies are admitted at the Incursion datasheet repetition limit")
	incursion.entries[0].copies = 3
	check(not str(Catalog.admit(incursion).get("error", "")).is_empty(), "Incursion rejects a third non-Battleline copy")
	catalog.free()

	var state := prepared()
	check(not state.has("error"), "The Rhino Primaris can be materialized from the local consolidated catalog: %s" % str(state.get("error", "")))
	if state.has("error"):
		quit(1)
		return
	var rhinos := models(state, UNIT, 1)
	check(rhinos.size() == 3, "All three admitted copies materialize as separate models")
	if rhinos.size() != 3:
		quit(1)
		return
	var first := rhinos[0]
	var second := rhinos[1]
	var third := rhinos[2]
	var first_squad := int(state.units[first].squad)
	var profile_in_state: Dictionary = Transport.profile(state, first)
	check(profile_in_state.get("capacity") == 6 and profile_in_state.get("forbidden", []) == ["JUMP PACK", "GRAVIS", "CENTURION", "TERMINATOR"], "The live transport exposes its six-space capacity and restrictions")
	check(Transport.is_transport(state, first) and Transport.datasheet_has_ability(state, first, "Deadly Demise") and A.deadly_demise_value(state, first) == "D3", "Transport identity and Deadly Demise D3 register on the live model")
	check(A.has(state, first_squad, "combat-doctrines") and A.has(state, first_squad, "transport-deadly-demise") and A.has(state, first_squad, "rhino-primaris-self-repair") and A.has(state, first_squad, "rhino-primaris-orbital-comms-array"), "Combat Doctrines and both datasheet rules register for the Rhino Primaris")
	check(not A.has(state, first_squad, "veiling-smoke") and not Transport.datasheet_has_ability(state, first, "Firing Deck") and not Transport.datasheet_has_ability(state, first, "Veiling Smoke"), "The shared Rhino profile's Firing Deck and Veiling Smoke are not inherited")
	check("SMOKE" in state.units[first].keywords and F.C.CoreReactions.keyword(state, first_squad, "SMOKE"), "The source SMOKE keyword remains usable for the shared Smoke stratagem")
	check(state.units[first].ranged_weapons.size() == 1 and weapon_profile(state.units[first].ranged_weapons, "twin-plasma-gun", "supercharge").keywords.get("hazardous", false), "The live default equipment contains the complete Twin Plasma Gun profiles")
	var optional_choices := UnitActions.choices(state, 1).filter(func(row: Dictionary) -> bool: return str(row.get("action", "")) == "transport-weapon-loadout" and int(row.get("model", -1)) == first)
	check(optional_choices.size() == 1 and str(optional_choices[0].get("value", "")).begins_with("hunter-killer-missile:on"), "Army preparation offers its one optional Hunter-killer Missile")
	if not optional_choices.is_empty():
		var selected := PublicUnitCommand.submit(state, 1, optional_choices[0], Vector2.ZERO, Callable())
		var missile := Equipment.select(state, first, false, "hunter-killer-missile", "standard")
		check(str(selected.get("error", "")).is_empty() and not missile.has("error") and missile.stats.keywords.get("one-shot", false), "The public preparation flow equips the optional One Shot missile")
	var five_squad := squad_for_identity(state, "intercessor-squad", 1, 5)
	var ten_squad := squad_for_identity(state, "intercessor-squad", 1, 10)
	check(five_squad >= 0 and ten_squad >= 0, "The fixture supplies 5- and 10-model Astartes Infantry passenger units")
	if five_squad >= 0:
		check(Transport.eligibility_error(state, first, five_squad).is_empty(), "A 5-model eligible Intercessor unit fits in the Rhino Primaris")
	if ten_squad >= 0:
		check(Transport.eligibility_error(state, first, ten_squad).contains("capacity"), "The 10-model Intercessor unit is blocked by the six-model capacity")
	if five_squad >= 0:
		var target_models := Geometry.alive(state, five_squad)
		var source_position: Vector2 = state.units[first].position
		var target_position := source_position + Vector2(float(state.units[first].radius + state.units[target_models[0]].radius) + 6.0, 0.0)
		for model: int in target_models: state.units[model].position = target_position
		state.units[second].position = source_position
		state.units[third].position = source_position + Vector2(100.0, 0.0)
		check(is_equal_approx(Geometry.distance_to_target(state, state.units[first], five_squad), 6.0) and A.orbital_comms_array_sources(state, 1, five_squad).size() == 2, "Orbital Comms uses the 6-inch edge-to-edge boundary and detects each eligible source")
		var rolls: Array[int] = [5, 4]
		var roller := func() -> int: return rolls.pop_front()
		state.phase = "shooting"
		state.cp[1] = 2
		var comms_error := Stratagems.consume(state, 1, five_squad, "fire-overwatch", roller)
		check(comms_error.is_empty() and state.cp[1] == 2 and state.unit_abilities.last_orbital_comms_array.get("gained", -1) == 1 and state.unit_abilities.last_orbital_comms_array.rolls.size() == 2, "Each nearby Rhino rolls after the targeted Stratagem and a 5+ refunds 1 CP")
		for model: int in target_models: state.units[model].position = source_position + Vector2(float(state.units[first].radius + state.units[target_models[0]].radius) + 6.1, 0.0)
		check(is_equal_approx(Geometry.distance_to_target(state, state.units[first], five_squad), 6.1) and A.orbital_comms_array_sources(state, 1, five_squad).is_empty(), "Orbital Comms correctly stops beyond six inches")
		for model: int in target_models: state.units[model].position = target_position
		for model: int in rhinos: state.units[model].wounds = 9
		state.units[second].on_battlefield = false
		state.units[second].embarked_transport = first
		state.units[third].owner = 2
		state.squads[int(state.units[third].squad)].owner = 2
		state.active = 1
		var healed_owner_one := A.start_command(state)
		check(state.units[first].wounds == 10 and healed_owner_one.any(func(row: Dictionary) -> bool: return int(row.get("model", -1)) == first), "Self-repair heals one lost wound during the owning player's Command phase")
		check(state.units[second].wounds == 9 and not healed_owner_one.any(func(row: Dictionary) -> bool: return int(row.get("model", -1)) == second), "Self-repair skips an embarked Rhino Primaris")
		check(state.units[third].wounds == 9 and not healed_owner_one.any(func(row: Dictionary) -> bool: return int(row.get("model", -1)) == third), "Self-repair does not heal the opposing player's Rhino on the active player's turn")
		state.active = 2
		var healed_owner_two := A.start_command(state)
		check(state.units[third].wounds == 10 and healed_owner_two.any(func(row: Dictionary) -> bool: return int(row.get("model", -1)) == third), "The Rhino Primaris repairs in its own player's Command phase")
		state.units[third].wounds = 0
		var destroyed_repair := A.start_command(state)
		check(state.units[third].wounds == 0 and not destroyed_repair.any(func(row: Dictionary) -> bool: return int(row.get("model", -1)) == third), "Self-repair does not restore a destroyed Rhino")
		state.active = 1
		var capped_repair := A.start_command(state)
		check(state.units[first].wounds == 10 and not capped_repair.any(func(row: Dictionary) -> bool: return int(row.get("model", -1)) == first), "Self-repair cannot exceed the source 10-wound maximum")

	print("Rhino Primaris Legends: %d failures" % failures)
	quit(1 if failures else 0)

func _initialize() -> void:
	call_deferred("run")
