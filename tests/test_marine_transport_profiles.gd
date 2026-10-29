extends SceneTree
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func has_transport_ability(profile: Dictionary, name: String) -> bool:
	for ability: Dictionary in profile.get("transport", {}).get("abilities", []):
		if str(ability.get("name", "")) == name: return true
	return false

func transport_ability(profile: Dictionary, name: String) -> Dictionary:
	for ability: Dictionary in profile.get("transport", {}).get("abilities", []):
		if str(ability.get("name", "")) == name: return ability
	return {}

func _initialize() -> void: call_deferred("run")

func run() -> void:
	var expected := {
		"land-raider": ["000000065", 14, 245, 265, null, 265],
		"land-raider-crusader": ["000000066", 16, 230, 250, null, 250],
		"drop-pod": ["000000087", 12, 60, 60, 70, null],
		"land-raider-redeemer": ["000002173", 14, 245, 265, null, 265],
		"impulsor": ["000002568", 7, 70, 70, 80, null],
		"repulsor": ["000002721", 14, 190, 210, null, null],
		"repulsor-executioner": ["000002722", 7, 260, 280, null, null],
		"rhino": ["000002723", 12, 70, 70, 80, null],
	}
	var catalog := Profiles.catalog()
	for identity: String in expected:
		var profile: Dictionary = Profiles.profile(identity)
		var record: Array = expected[identity]
		var second_cost: Variant = profile.get("second_plus_points_by_models", {}).get(1)
		check(not profile.is_empty() and profile.source_book_id == "000000139" and profile.source_datasheet_id == record[0] and profile.source_export_updated_at == "2026-10-21T16:06:23+03:00" and profile.source_snapshot_id == "20261021T130623Z", "%s retains its local Wahapedia book, sheet, revision and snapshot" % identity)
		check(profile.models == 1 and profile.points_by_models.get(1, -1) == record[2] and profile.third_plus_points_by_models.get(1, -1) == record[3] and profile.get("fourth_plus_points_by_models", {}).get(1) == record[4], "%s first, third and fourth-plus prices match the local export" % identity)
		check(second_cost == record[5], "%s preserves a separately sourced second-plus price when the datasheet defines one" % identity)
		check(profile.transport.capacity == record[1] and profile.transport.required == ["ADEPTUS ASTARTES", "INFANTRY"], "%s transport capacity and required keywords match its datasheet" % identity)
		check(profile.stats.has("toughness") and profile.stats.has("wounds") and profile.stats.has("save_target") and profile.keywords.has("TRANSPORT"), "%s fixed characteristics and TRANSPORT keyword are captured" % identity)
		check(profile.get("common_book_leader_support_links", []).is_empty(), "%s has no common-book Leader or Support relation in the local source export" % identity)
		check(catalog.has(identity), "%s appears in the source-backed profile inventory" % identity)
	check(Profiles.transport_profiles().size() == 8 and Profiles.transport_profiles().get("drop-pod", {}).source_files.size() == 23, "Transport prices retain verified source snapshot file hashes")
	var impulsor := Profiles.profile("impulsor")
	check(impulsor.base_size_source == "100mm" and impulsor.base_geometry == "circle" and impulsor.geometry_scope == "Wahapedia specifies a 100 mm diameter circle; runtime uses the corresponding circular footprint.", "Impulsor geometry follows the current source's explicit circular diameter rather than the vehicle proxy default")
	for identity: String in ["repulsor", "repulsor-executioner"]:
		var exact_circle := Profiles.profile(identity)
		check(exact_circle.base_size_source == "100mm" and exact_circle.base_size_source_mm == 100 and exact_circle.base_geometry == "circle" and exact_circle.geometry_scope == "Wahapedia specifies a 100 mm diameter circle; runtime uses the corresponding circular footprint.", "%s uses its source-listed 100 mm circular footprint" % exact_circle.name)
	for identity: String in ["land-raider", "land-raider-crusader", "land-raider-redeemer", "rhino"]:
		var proxy := Profiles.profile(identity)
		check(proxy.base_size_source == "Use model" and "proxy" in str(proxy.base_geometry) and "exact source footprint is outside" in str(proxy.geometry_scope), "%s keeps its explicitly labelled footprint proxy" % proxy.name)
	var impulsor_firing_deck := transport_ability(impulsor, "Firing Deck")
	var impulsor_deadly_demise := transport_ability(impulsor, "Deadly Demise")
	check(impulsor_firing_deck.get("parameter", "") == "7" and impulsor_deadly_demise.get("parameter", "") == "D3", "Impulsor Core ability parameters are joined from their exported ability identities")
	check(impulsor.stats.wounds is int and impulsor.stats.invulnerable_target is int and impulsor.ranged[0].profiles.standard.attacks is int and impulsor.ranged[0].profiles.standard.ap is int and impulsor.additional_weapon_profiles.ranged[1].profiles.standard.attacks is int, "Imported transport characteristics, default weapons and optional weapon profiles use integer combat stats")
	check(Profiles.profile("land-raider").ranged.size() == 3 and Profiles.profile("land-raider").ranged[0].profiles.standard.strength == 12, "Land Raider default weapons preserve both Godhammer Lascannons and source strength")
	check(Profiles.profile("impulsor").additional_weapon_profiles.ranged.any(func(w: Dictionary) -> bool: return w.id == "bellicatus-missile-array" and w.profiles.size() == 3), "Impulsor Bellicatus Missile Array keeps all three source profiles")
	check(Profiles.profile("repulsor-executioner").additional_weapon_profiles.ranged.any(func(w: Dictionary) -> bool: return w.id == "macro-plasma-incinerator" and w.profiles.has("supercharge")), "Executioner replacement preserves Standard and Supercharge profiles")
	for identity: String in ["repulsor", "repulsor-executioner"]:
		var cannon: Dictionary = {}
		for weapon: Dictionary in Profiles.profile(identity).ranged:
			if weapon.id == "heavy-onslaught-gatling-cannon": cannon = weapon.profiles.standard
		check(not cannon.is_empty() and cannon.get("target_restricted_traits", {}) == {"devastating-wounds": ["MONSTER", "VEHICLE"], "sustained-hits": ["MONSTER", "VEHICLE"]}, "%s preserves both source target restrictions on its Heavy Onslaught Gatling Cannon" % identity)
	check(Profiles.profile("drop-pod").transport.forbidden == ["GRAVIS", "JUMP PACK", "TERMINATOR"], "Drop Pod restrictions remain datasheet-specific")
	check(Profiles.profile("land-raider").transport.double_space == ["GRAVIS", "TERMINATOR"] and Profiles.profile("rhino").transport.double_space.is_empty(), "Double-capacity model classes are specific to each transport")
	check(has_transport_ability(Profiles.profile("land-raider"), "Assault Ramp") and has_transport_ability(Profiles.profile("land-raider"), "Power of the Machine Spirit"), "Land Raider source abilities remain attached to its transport record")
	check(has_transport_ability(Profiles.profile("land-raider-crusader"), "Fury of the Machine Spirit") and has_transport_ability(Profiles.profile("land-raider-redeemer"), "Wrath of the Machine Spirit"), "Crusader and Redeemer retain their distinct attack abilities")
	for identity: String in ["land-raider", "land-raider-crusader", "land-raider-redeemer", "repulsor", "repulsor-executioner"]:
		var vehicle := Profiles.profile(identity)
		check(transport_ability(vehicle, "Damaged").get("parameter", "") == "6" and transport_ability(vehicle, "Deadly Demise").get("parameter", "") == "D6", "%s retains the source Damaged and Deadly Demise parameters" % vehicle.name)
		check(vehicle.transport.forbidden == ["JUMP PACK"] and vehicle.transport.double_space == ["GRAVIS", "TERMINATOR"], "%s retains its source transport exclusions and double occupancy" % vehicle.name)
	var rhino := Profiles.profile("rhino")
	check(transport_ability(rhino, "Deadly Demise").get("parameter", "") == "D3" and transport_ability(rhino, "Firing Deck").get("parameter", "") == "2", "Rhino retains its source Deadly Demise D3 and Firing Deck 2 parameters")
	check(rhino.transport.forbidden == ["GRAVIS", "JUMP PACK", "TERMINATOR"] and rhino.transport.double_space.is_empty(), "Rhino keeps its source-specific passenger exclusions without double occupancy")
	var land_raider_source_tier: Dictionary = Profiles.profile("land-raider").get("source_cost_sections", {}).get("second_plus", {})
	var crusader_source_tier: Dictionary = Profiles.profile("land-raider-crusader").get("source_cost_sections", {}).get("second_plus", {})
	var redeemer_source_tier: Dictionary = Profiles.profile("land-raider-redeemer").get("source_cost_sections", {}).get("second_plus", {})
	check(int(land_raider_source_tier.get("1", -1)) == 265 and int(crusader_source_tier.get("1", -1)) == 250 and int(redeemer_source_tier.get("1", -1)) == 265, "The three Land Raider pages retain their exact first-copy and second-plus source sections")
	check(has_transport_ability(Profiles.profile("drop-pod"), "Drop Pod Assault") and has_transport_ability(Profiles.profile("drop-pod"), "Deployment Complete"), "Drop Pod deployment restrictions remain in the source record")
	check(has_transport_ability(Profiles.profile("impulsor"), "Rapid Disembarkation") and has_transport_ability(Profiles.profile("repulsor"), "Combat Embarkation"), "Impulsor and Repulsor retain their distinct transport rules")
	check(has_transport_ability(Profiles.profile("repulsor-executioner"), "Executioner") and has_transport_ability(Profiles.profile("rhino"), "Veiling Smoke (Once per phase, per unit)"), "Executioner and Rhino retain their distinct source abilities")
	print("Marine transport profiles: %d failures" % failures)
	quit(1 if failures else 0)
