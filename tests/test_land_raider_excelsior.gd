extends SceneTree

const F = preload("res://tests/all_units_fixture.gd")
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const TransportRules = preload("res://scripts/edition_11/transport_rules.gd")
const UnitAbilities = preload("res://scripts/edition_11/unit_abilities.gd")
const UNIT := "land-raider-excelsior"
const UNIT_ID := "40kdc:11e:adeptus-astartes:land-raider-excelsior"
var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func selection(copies: int = 2) -> Dictionary:
	var result := F.current_marine_selections()
	result[1].entries.append({"definition_id": UNIT_ID, "models": 1, "copies": copies})
	return result

func models_for(state: Dictionary) -> Array[int]:
	var result: Array[int] = []
	for model: int in state.units:
		if UnitAbilities.identity(state.units[model]) == UNIT and int(state.units[model].owner) == 1: result.append(model)
	result.sort()
	return result

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var profile := Profiles.profile(UNIT)
	check(profile.get("source_book_id") == "000000356" and profile.get("source_datasheet_id") == "000000067" and profile.get("source_scope") == "Warhammer Legends", "The profile is the Space Marines Legends Land Raider Excelsior datasheet")
	check(profile.get("source_snapshot_id") == Profiles.VERIFIED_EXPORT_SNAPSHOT_ID and profile.get("source_manifest_sha256") == Profiles.VERIFIED_EXPORT_MANIFEST_SHA256 and profile.get("source_slice_manifest_sha256") == Profiles.VERIFIED_EXPORT_SLICE_SHA256_BY_BOOK["000000356"], "The profile binds to the verified local export and Legends slice")
	check(profile.get("points_by_models", {}) == {1: 250} and profile.get("second_plus_points_by_models", {}) == {1: 250} and profile.get("third_plus_points_by_models", {}) == {1: 250} and profile.get("max_supported_copies") == 3, "All three source cost tiers and the ordinary three-copy limit are represented")
	check(profile.get("stats", {}) == {"movement_inches": 10, "toughness": 12, "save_target": 2, "wounds": 16, "leadership_target": 6, "objective_control": 5, "invulnerable_target": 5}, "Every fixed characteristic matches the verified export")
	check(profile.get("keywords", []) == ["ADEPTUS ASTARTES", "SMOKE", "IMPERIUM", "TRANSPORT", "FRAME", "VEHICLE"], "All six source keywords are represented without adding an unsupported Chapter keyword")
	check(profile.get("default_loadout_by_role", {}).get("Land Raider Excelsior", {}) == {"Armoured Tracks": 1, "Godhammer Lascannon": 2, "Grav-cannon": 1}, "The fixed default wargear matches the source sheet")
	check(profile.get("ranged", []).size() == 3 and profile.ranged[0].profiles.standard.attacks == 2 and profile.ranged[1].profiles.standard.attacks == 2 and profile.ranged[2].profiles.standard.keywords == {"anti-vehicle": 2}, "The two separate Godhammer Lascannons and Anti-Vehicle Grav-cannon have complete profiles")
	check(profile.get("melee", []).size() == 1 and profile.melee[0].profiles.standard == {"name": "Armoured Tracks", "range_inches": 0.0, "attacks": 6, "skill": 4, "strength": 8, "ap": 0, "damage": 1, "keywords": {}}, "Armoured Tracks retains all six source weapon fields")
	var additions: Array = profile.get("additional_weapon_profiles", {}).get("ranged", [])
	check(additions.size() == 4 and additions.any(func(w: Dictionary) -> bool: return w.id == "combi-weapon" and w.profiles.size() == 3), "All four optional weapon identities and all three Combi-weapon profiles are stored")
	check(profile.get("transport", {}).get("capacity") == 12 and profile.transport.double_space == ["JUMP PACK", "GRAVIS", "TERMINATOR"] and profile.transport.triple_space == ["CENTURION"], "The transport capacity counts Jump Pack, Gravis and Terminator models twice and Centurions three times")
	check(profile.get("transport", {}).get("options", {}).get("add", []) == ["Multi-melta", "Hunter-killer Missile", "Storm Bolter", "Combi-weapon - Damnatus"], "Only the four source-listed optional weapons are selectable")
	check(profile.get("special_rules", []) == ["Combat Doctrines", "Damaged 5", "Deadly Demise D6", "Rites of Battle"], "All four source ability records are exposed to the game rules layer")
	check(profile.get("geometry_scope", "").contains("60 mm") and profile.get("geometry_scope", "").contains("not certified"), "The unspecified physical footprint remains explicitly disclosed as a 60 mm proxy")

	var choices := F.current_marine_selections()
	choices[1].entries = [
		{"definition_id": UNIT_ID, "models": 1, "copies": 2},
		{"definition_id": "40kdc:11e:adeptus-astartes:centurion-devastator-squad", "models": 3, "copies": 1},
		{"definition_id": "40kdc:11e:adeptus-astartes:captain-in-gravis-armour", "models": 1, "copies": 1}]
	var state: Dictionary = F.P.initial_state({"checked_rosters": false, "official_mission": false, "unit_abilities": true, "combat_doctrines": true, "core_stratagems": true}, choices)
	check(not state.has("error"), "The Legends profile materializes in the current Marine preparation catalog: " + str(state.get("error", "")))
	if state.has("error"):
		quit(1)
	if state.has("error"):
		quit(1)
	state.phase = "deployment"
	state.active = 1
	var models := models_for(state)
	check(models.size() == 2 and models.all(func(model: int) -> bool: return TransportRules.is_transport(state, model)), "Both admitted copies instantiate as transports")
	var centurion_models: Array[int] = []
	var gravis_model := -1
	for model: int in state.units:
		match UnitAbilities.identity(state.units[model]):
			"centurion-devastator-squad": centurion_models.append(model)
			"captain-in-gravis-armour": gravis_model = model
	if not centurion_models.is_empty():
		check(TransportRules.capacity_cost(state, int(state.units[centurion_models[0]].squad), profile.transport) == 9, "Each of the three Centurion models occupies three spaces")
	else:
		check(false, "The current catalog materializes the source-listed Centurion passenger profile")
	if gravis_model >= 0:
		check(TransportRules.capacity_cost(state, int(state.units[gravis_model].squad), profile.transport) == 2, "A Gravis model occupies two transport spaces")
	else:
		check(false, "The current catalog materializes the source-listed Gravis passenger profile")
	if models.size() == 2:
		var first := int(models[0])
		var second := int(models[1])
		var option_choices := TransportRules.transport_weapon_loadout_choices(state, 1)
		for option: String in ["Multi-melta", "Hunter-killer Missile", "Storm Bolter", "Combi-weapon - Damnatus"]:
			check(option_choices.any(func(choice: Dictionary) -> bool: return int(choice.model) == first and str(choice.label).contains(option)), "Preparation exposes the source-listed optional %s" % option)
		for option: String in ["multi-melta:on", "hunter-killer-missile:on", "storm-bolter:on", "combi-weapon:on"]:
			check(TransportRules.configure_optional_transport_weapon(state, first, option).is_empty(), "Preparation accepts valid option %s" % option)
		var ranged: Array = state.units[first].get("ranged_weapons", [])
		check(ranged.any(func(w: Dictionary) -> bool: return w.id == "combi-weapon" and w.profiles.size() == 3), "The selected Combi-weapon keeps all three attack profiles in the live inventory")
		check(UnitAbilities.has(state, int(state.units[first].squad), "rites-of-battle") and UnitAbilities.discount(state, 1, int(state.units[first].squad)) == 1, "Rites of Battle opens the once-per-round CP discount on its own target unit")
		check(UnitAbilities.deadly_demise_value(state, first) == "D6", "Deadly Demise uses the source D6 parameter")
		state.cp[1] = 1
		F.C.Stratagems.consume(state, 1, int(state.units[first].squad), "command-re-roll")
		check(state.cp[1] == 1 and int(state.unit_abilities.used.get("rites-of-battle:1", -1)) == state.round, "A one-CP Stratagem is reduced to zero and records the army-wide use for this battle round")
		check(UnitAbilities.discount(state, 1, int(state.units[second].squad)) == 0, "A second Excelsior cannot discount another Stratagem in the same battle round")
		state.round += 1
		check(UnitAbilities.discount(state, 1, int(state.units[second].squad)) == 1, "The army-wide Rites of Battle use refreshes in the next battle round")
		check(UnitAbilities.damaged_attack_penalty(state, first) == 0, "Damaged does not apply above its five-wound threshold")
		state.units[first].wounds = 5
		check(UnitAbilities.damaged_attack_penalty(state, first) == -1, "Damaged applies the source -1 Hit modifier at five wounds remaining")

	print("Land Raider Excelsior Legends: %d failures" % failures)
	quit(1 if failures else 0)
