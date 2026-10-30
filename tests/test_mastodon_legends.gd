extends SceneTree

const F = preload("res://tests/all_units_fixture.gd")
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const TransportRules = preload("res://scripts/edition_11/transport_rules.gd")
const UnitAbilities = preload("res://scripts/edition_11/unit_abilities.gd")
const DeadlyDemise = preload("res://scripts/edition_11/deadly_demise.gd")
const Combat = F.C
const UNIT := "mastodon"
const UNIT_ID := "40kdc:11e:adeptus-astartes:mastodon"
const DREADNOUGHT_ID := "40kdc:11e:adeptus-astartes:dreadnought"
const INTERCESSORS_ID := "40kdc:11e:adeptus-astartes:intercessor-squad"
var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func selections(dreadnoughts: int = 0, intercessor_squads: int = 0) -> Dictionary:
	var result := F.current_marine_selections()
	for owner: int in [1, 2]:
		result[owner].category = "strike_force"
		result[owner].points_limit = 2000
	result[1].entries = [{"definition_id": UNIT_ID, "models": 1, "copies": 1}]
	if dreadnoughts > 0: result[1].entries.append({"definition_id": DREADNOUGHT_ID, "models": 1, "copies": dreadnoughts})
	if intercessor_squads > 0: result[1].entries.append({"definition_id": INTERCESSORS_ID, "models": 10, "copies": intercessor_squads})
	return result

func build_state(dreadnoughts: int = 0, intercessor_squads: int = 0) -> Dictionary:
	return F.P.initial_state({"checked_rosters": false, "official_mission": false, "unit_abilities": true, "combat_doctrines": true, "core_stratagems": true}, selections(dreadnoughts, intercessor_squads))

func models_for(state: Dictionary, identity: String, owner: int = 1) -> Array[int]:
	var result: Array[int] = []
	for model: int in state.units:
		if UnitAbilities.identity(state.units[model]) == identity and int(state.units[model].owner) == owner: result.append(model)
	result.sort()
	return result

func squads_for(state: Dictionary, identity: String, owner: int = 1) -> Array[int]:
	var result: Array[int] = []
	for model: int in models_for(state, identity, owner):
		var squad := int(state.units[model].squad)
		if squad not in result: result.append(squad)
	return result

func mastodon_attack_plan(state: Dictionary, model: int, target_squad: int) -> Dictionary:
	return Combat.AttackPlan.prepare(state, int(state.units[model].squad), false, [{"model": model, "target": target_squad, "amount": 1, "weapon": "siege-melta-array", "profile": "standard"}], false)

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var profile := Profiles.profile(UNIT)
	check(profile.get("source_book_id") == "000000356" and profile.get("source_datasheet_id") == "000001189" and profile.get("source_scope") == "Warhammer Legends", "The profile is the current Space Marines Legends Mastodon datasheet")
	check(profile.get("source_snapshot_id") == Profiles.VERIFIED_EXPORT_SNAPSHOT_ID and profile.get("source_manifest_sha256") == Profiles.VERIFIED_EXPORT_MANIFEST_SHA256 and profile.get("source_slice_manifest_sha256") == Profiles.VERIFIED_EXPORT_SLICE_SHA256_BY_BOOK["000000356"], "The profile binds to the verified local export and exact Legends slice")
	check(profile.get("source_files", []).size() == 8 and profile.get("points_by_models", {}) == {1: 540} and profile.get("second_plus_points_by_models", {}) == {1: 540} and profile.get("third_plus_points_by_models", {}) == {1: 540}, "All eight source CSV hashes and all three 540-point copy tiers are represented")
	check(profile.get("stats", {}) == {"movement_inches": 9, "toughness": 14, "save_target": 2, "wounds": 30, "leadership_target": 6, "objective_control": 12, "invulnerable_target": 0}, "All fixed characteristics match the export")
	check(profile.get("keywords", []) == ["ADEPTUS ASTARTES", "TITANIC", "SMOKE", "IMPERIUM", "VEHICLE", "FRAME", "TRANSPORT"], "All seven source keywords are represented")
	check(profile.get("default_loadout_by_role", {}).get("Mastodon", {}) == {"Armoured Tracks": 1, "Heavy Flamer": 2, "Lascannon": 2, "Siege Melta Array": 1, "Skyreaper Battery": 1}, "The model starts with its complete source default loadout")
	check(profile.get("ranged", []).size() == 6 and profile.get("additional_weapon_profiles", {}).get("ranged", []).size() == 12 and profile.get("melee", []).size() == 1, "All default and replacement weapon identities are present")
	check(profile.ranged[0].profiles.standard == {"name": "Heavy Flamer", "range_inches": 12.0, "attacks": 3, "skill": null, "strength": 5, "ap": -1, "damage": 1, "keywords": {"blast": 2, "torrent": true}}, "Heavy Flamer profile matches all source fields")
	check(profile.ranged[4].profiles.standard == {"name": "Siege Melta Array", "range_inches": 24.0, "attacks": 6, "skill": 3, "strength": 10, "ap": -3, "damage": "D3+2", "keywords": {"melta": 3}}, "Siege Melta Array profile matches all source fields")
	check(profile.ranged[5].profiles.standard == {"name": "Skyreaper Battery", "range_inches": 48.0, "attacks": 8, "skill": 3, "strength": 7, "ap": -1, "damage": 2, "keywords": {"anti-fly": 4}}, "Skyreaper Battery profile matches all source fields")
	check(profile.melee[0].profiles.standard == {"name": "Armoured Tracks", "range_inches": 0.0, "attacks": 6, "skill": 4, "strength": 8, "ap": 0, "damage": 1, "keywords": {}}, "Armoured Tracks matches its source profile")
	var transport: Dictionary = profile.get("transport", {})
	check(transport.get("capacity") == 45 and transport.get("required") == ["ADEPTUS ASTARTES"] and transport.get("required_any") == ["INFANTRY"] and transport.get("required_any_groups") == ["DREADNOUGHT"], "Capacity, faction, Infantry and the source-named Dreadnought passenger exception are explicit")
	check(transport.get("double_space") == ["JUMP PACK", "GRAVIS", "TERMINATOR"] and transport.get("triple_space") == ["CENTURION"] and transport.get("identity_groups", {}).get("DREADNOUGHT", {}).get("capacity_by_wounds", false) and transport.get("max_models_by_identity_group") == {"DREADNOUGHT": 2}, "All passenger multipliers, Dreadnought W cost and the two-model limit are encoded by current Dreadnought identities")
	var groups: Dictionary = transport.get("options", {}).get("replacement_groups", {})
	check(groups.size() == 2 and groups.get("heavy-flamers", {}).get("choices", {}).size() == 3 and groups.get("lascannons", {}).get("choices", {}).size() == 3, "Both source option groups expose all three mutually exclusive packages")
	check(profile.get("special_rules", []) == ["Combat Doctrines", "Damaged 10", "Deadly Demise 2D6", "Inviolable Transport"], "All datasheet and faction abilities enter the local rules gate")
	check(profile.get("geometry_scope", "").contains("interaction testing only") and profile.geometry_scope.contains("not certified"), "The unspecified giant hull footprint is explicitly not represented as certified")

	var state := build_state(3)
	check(not state.has("error"), "The Mastodon and three Dreadnought profiles materialize in a legal Strike Force test roster: " + str(state.get("error", "")))
	if state.has("error"):
		quit(1)
		return
	state.phase = "deployment"
	state.active = 1
	var mastodons := models_for(state, UNIT)
	var dreads := models_for(state, "dreadnought")
	check(mastodons.size() == 1 and dreads.size() == 3 and TransportRules.is_transport(state, mastodons[0]), "The local catalog materializes one Mastodon and the selected Dreadnoughts")
	if mastodons.size() == 1:
		var mastodon: int = mastodons[0]
		check(UnitAbilities.has(state, int(state.units[mastodon].squad), "inviolable-transport") and UnitAbilities.deadly_demise_value(state, mastodon) == "2D6", "Inviolable Transport and source-listed Deadly Demise 2D6 are registered")
		check(UnitAbilities.damaged_attack_penalty(state, mastodon) == 0, "Damaged 10 is inactive above its threshold")
		state.units[mastodon].wounds = 11
		check(UnitAbilities.damaged_attack_penalty(state, mastodon) == 0, "Damaged 10 is inactive at eleven wounds")
		state.units[mastodon].wounds = 10
		check(UnitAbilities.damaged_attack_penalty(state, mastodon) == -1, "Damaged 10 applies at exactly ten wounds")
		state.units[mastodon].wounds = 1
		check(UnitAbilities.damaged_attack_penalty(state, mastodon) == -1, "Damaged 10 applies down to one remaining wound")
		state.units[mastodon].wounds = 0
		check(UnitAbilities.damaged_attack_penalty(state, mastodon) == 0, "A destroyed Mastodon does not make attacks")
		state.units[mastodon].wounds = 30
		check(UnitAbilities.damage(state, mastodon, 1) == 1 and UnitAbilities.damage(state, mastodon, 3) == 2 and UnitAbilities.damage(state, mastodon, 3, "mortal") == 3, "Inviolable Transport reduces normal attack damage by one to a minimum of one, not mortal wounds")
		check(TransportRules.capacity_cost(state, int(state.units[dreads[0]].squad), transport) == int(state.units[dreads[0]].max_wounds), "A Dreadnought uses its W characteristic as transport space: %d vs %d; keywords=%s" % [TransportRules.capacity_cost(state, int(state.units[dreads[0]].squad), transport), int(state.units[dreads[0]].max_wounds), str(state.units[dreads[0]].keywords)])
		var loadout_choices := TransportRules.transport_weapon_loadout_choices(state, 1)
		check(loadout_choices.any(func(choice: Dictionary) -> bool: return int(choice.model) == mastodon and str(choice.label).contains("2 Heavy Bolters")), "Preparation offers the source-listed multi-choice packages")
		check(TransportRules.configure_optional_transport_weapon(state, mastodon, "group:heavy-flamers:heavy-bolters").is_empty(), "A Heavy Bolter package replaces both default Heavy Flamers")
		check(state.units[mastodon].ranged_weapons.any(func(weapon: Dictionary) -> bool: return weapon.id == "mastodon-hb-for-flamers-left") and not state.units[mastodon].ranged_weapons.any(func(weapon: Dictionary) -> bool: return weapon.id == "mastodon-heavy-flamer-left"), "The selected first package updates the live weapon inventory")
		check(TransportRules.configure_optional_transport_weapon(state, mastodon, "group:lascannons:volkite-culverins").is_empty(), "The independent Lascannon package accepts Volkite Culverins")
		check(state.units[mastodon].ranged_weapons.any(func(weapon: Dictionary) -> bool: return weapon.id == "mastodon-volkite-for-lascannons-left") and state.units[mastodon].ranged_weapons.any(func(weapon: Dictionary) -> bool: return weapon.id == "mastodon-hb-for-flamers-left"), "Independent replacements coexist in the configured live loadout")
		check(TransportRules.configure_optional_transport_weapon(state, mastodon, "group:heavy-flamers:default").is_empty() and state.units[mastodon].ranged_weapons.any(func(weapon: Dictionary) -> bool: return weapon.id == "mastodon-heavy-flamer-left"), "The original default group can be restored")
		var dreadnought_eligibility_error := TransportRules.eligibility_error(state, mastodon, int(state.units[dreads[0]].squad))
		check(dreadnought_eligibility_error.is_empty(), "The Mastodon may carry a source-listed Dreadnought model: %s; identity=%s; groups=%s" % [dreadnought_eligibility_error, UnitAbilities.identity(state.units[dreads[0]]), str(transport.get("identity_groups", {}))])
		var first_embark_error := TransportRules.start_embark(state, 1, mastodon, int(state.units[dreads[0]].squad))
		check(first_embark_error.is_empty(), "A Dreadnought can embark through the public transport path: " + first_embark_error)
		var second_dreadnought_eligibility_error := TransportRules.eligibility_error(state, mastodon, int(state.units[dreads[1]].squad))
		check(second_dreadnought_eligibility_error.is_empty(), "The second Dreadnought model is permitted: " + second_dreadnought_eligibility_error)
		var second_embark_error := TransportRules.start_embark(state, 1, mastodon, int(state.units[dreads[1]].squad))
		check(second_embark_error.is_empty(), "The second Dreadnought embarks: " + second_embark_error)
		var third_dreadnought_error := TransportRules.eligibility_error(state, mastodon, int(state.units[dreads[2]].squad))
		check(third_dreadnought_error.contains("no more than 2 Dreadnought models"), "A third Dreadnought model is rejected by the source limit: " + third_dreadnought_error)

	var capacity_state := build_state(2, 3)
	check(not capacity_state.has("error"), "A six-unit capacity fixture materializes")
	if not capacity_state.has("error"):
		capacity_state.phase = "deployment"
		capacity_state.active = 1
		var capacity_mastodon := models_for(capacity_state, UNIT)[0]
		var capacity_dreads := models_for(capacity_state, "dreadnought")
		var infantry_squads := squads_for(capacity_state, "intercessor-squad")
		for index in range(2):
			var embark_error := TransportRules.start_embark(capacity_state, 1, capacity_mastodon, int(capacity_state.units[capacity_dreads[index]].squad))
			check(embark_error.is_empty(), "Each permitted Dreadnought consumes its source W capacity: " + embark_error)
		for index in range(2):
			var infantry_embark_error := TransportRules.start_embark(capacity_state, 1, capacity_mastodon, infantry_squads[index])
			check(infantry_embark_error.is_empty(), "A complete eligible Infantry unit embarks within remaining capacity: " + infantry_embark_error)
		var over_capacity_error := TransportRules.eligibility_error(capacity_state, capacity_mastodon, infantry_squads[2])
		check(over_capacity_error.contains("not have enough remaining capacity"), "The shared 45-space pool rejects an over-capacity passenger: " + over_capacity_error)

	var demise_state := build_state()
	var destroyed_mastodon := models_for(demise_state, UNIT)[0]
	var hit_test_state := build_state()
	var hit_test_mastodon := models_for(hit_test_state, UNIT)[0]
	var hit_test_target := squads_for(hit_test_state, "intercessor-squad", 2)[0]
	hit_test_state.phase = "shooting"
	hit_test_state.active = 1
	hit_test_state.units[hit_test_mastodon].position = Vector2(4, 4)
	for model: int in hit_test_state.units:
		if int(hit_test_state.units[model].squad) == hit_test_target: hit_test_state.units[model].position = Vector2(12, 4)
	hit_test_state.units[hit_test_mastodon].wounds = 11
	var undamaged_plan := mastodon_attack_plan(hit_test_state, hit_test_mastodon, hit_test_target)
	var undamaged_batches: Array = undamaged_plan.get("batches", [])
	var undamaged_hit_modifier := int(undamaged_batches[0].context.get("hit_modifier", 0)) if not undamaged_batches.is_empty() else -999
	check(undamaged_plan.get("error", "").is_empty() and undamaged_hit_modifier > -999, "The live Mastodon attack plan prepares above ten wounds: %s" % str(undamaged_plan.get("error", "")))
	hit_test_state.units[hit_test_mastodon].wounds = 10
	var damaged_plan := mastodon_attack_plan(hit_test_state, hit_test_mastodon, hit_test_target)
	var damaged_batches: Array = damaged_plan.get("batches", [])
	var damaged_hit_modifier := int(damaged_batches[0].context.get("hit_modifier", 0)) if not damaged_batches.is_empty() else -999
	check(damaged_plan.get("error", "").is_empty() and damaged_hit_modifier == undamaged_hit_modifier - 1, "The live Mastodon attack plan applies exactly one extra -1 Hit modifier at the Damaged 10 threshold: %d to %d; context=%s; helper=%d; %s" % [undamaged_hit_modifier, damaged_hit_modifier, str(damaged_batches[0].context if not damaged_batches.is_empty() else {}), UnitAbilities.damaged_attack_penalty(hit_test_state, hit_test_mastodon), str(damaged_plan.get("error", ""))])
	for model: int in demise_state.units: demise_state.units[model].position = Vector2.ZERO
	demise_state.units[destroyed_mastodon].wounds = 0
	var demise_begin := DeadlyDemise.begin(demise_state, [destroyed_mastodon], func() -> int: return 6)
	check(str(demise_begin.get("error", "")).is_empty() and not bool(demise_begin.get("complete", false)), "The public Deadly Demise resolver opens the Mastodon's on-destruction effect")
	var demise_events: Array = demise_state.get("pending_deadly_demise", {}).get("events", [])
	check(demise_events.size() == 1 and demise_events[0].get("expression", "") == "2D6" and demise_events[0].get("triggered", false), "The destroyed Mastodon preserves its 2D6 source value through the common trigger resolver")
	var demise_packets: Array = demise_state.get("pending_deadly_demise", {}).get("packets", [])
	check(not demise_packets.is_empty() and demise_packets.all(func(packet: Dictionary) -> bool: return packet.get("roll", {}).get("expression", "") == "2D6" and int(packet.get("roll", {}).get("value", 0)) == 12), "Each affected unit receives its separate 2D6 mortal-wound packet")

	print("Mastodon Legends: %d failures" % failures)
	quit(1 if failures else 0)
