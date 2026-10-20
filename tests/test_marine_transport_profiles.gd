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

func _initialize() -> void: call_deferred("run")

func run() -> void:
	var expected := {
		"land-raider": ["000000065", 14, 245, 265],
		"land-raider-crusader": ["000000066", 16, 230, 250],
		"drop-pod": ["000000087", 12, 60, 70],
		"land-raider-redeemer": ["000002173", 14, 245, 265],
		"impulsor": ["000002568", 7, 70, 80],
		"repulsor": ["000002721", 14, 190, 210],
		"repulsor-executioner": ["000002722", 7, 260, 280],
		"rhino": ["000002723", 12, 70, 80],
	}
	var catalog := Profiles.catalog()
	for identity: String in expected:
		var profile: Dictionary = Profiles.profile(identity)
		var record: Array = expected[identity]
		check(not profile.is_empty() and profile.source_book_id == "000000139" and profile.source_datasheet_id == record[0] and profile.source_export_updated_at == "2026-10-16T21:03:46+03:00", "%s retains its local Wahapedia book, sheet and revision" % identity)
		check(profile.models == 1 and profile.points_by_models.get(1, -1) == record[2] and profile.third_plus_points_by_models.get(1, -1) == record[3], "%s base and later-copy prices match the local export" % identity)
		check(profile.transport.capacity == record[1] and profile.transport.required == ["ADEPTUS ASTARTES", "INFANTRY"], "%s transport capacity and required keywords match its datasheet" % identity)
		check(profile.stats.has("toughness") and profile.stats.has("wounds") and profile.stats.has("save_target") and profile.keywords.has("TRANSPORT"), "%s fixed characteristics and TRANSPORT keyword are captured" % identity)
		check(catalog.has(identity), "%s appears in the source-backed profile inventory" % identity)
	var impulsor := Profiles.profile("impulsor")
	check(impulsor.stats.wounds is int and impulsor.stats.invulnerable_target is int and impulsor.ranged[0].profiles.standard.attacks is int and impulsor.ranged[0].profiles.standard.ap is int and impulsor.additional_weapon_profiles.ranged[1].profiles.standard.attacks is int, "Imported transport characteristics, default weapons and optional weapon profiles use integer combat stats")
	check(Profiles.profile("land-raider").ranged.size() == 3 and Profiles.profile("land-raider").ranged[0].profiles.standard.strength == 12, "Land Raider default weapons preserve both Godhammer Lascannons and source strength")
	check(Profiles.profile("impulsor").additional_weapon_profiles.ranged.any(func(w: Dictionary) -> bool: return w.id == "bellicatus-missile-array" and w.profiles.size() == 3), "Impulsor Bellicatus Missile Array keeps all three source profiles")
	check(Profiles.profile("repulsor-executioner").additional_weapon_profiles.ranged.any(func(w: Dictionary) -> bool: return w.id == "macro-plasma-incinerator" and w.profiles.has("supercharge")), "Executioner replacement preserves Standard and Supercharge profiles")
	check(Profiles.profile("drop-pod").transport.forbidden == ["GRAVIS", "JUMP PACK", "TERMINATOR"], "Drop Pod restrictions remain datasheet-specific")
	check(Profiles.profile("land-raider").transport.double_space == ["GRAVIS", "TERMINATOR"] and Profiles.profile("rhino").transport.double_space.is_empty(), "Double-capacity model classes are specific to each transport")
	check(has_transport_ability(Profiles.profile("land-raider"), "Assault Ramp") and has_transport_ability(Profiles.profile("land-raider"), "Power of the Machine Spirit"), "Land Raider source abilities remain attached to its transport record")
	check(has_transport_ability(Profiles.profile("land-raider-crusader"), "Fury of the Machine Spirit") and has_transport_ability(Profiles.profile("land-raider-redeemer"), "Wrath of the Machine Spirit"), "Crusader and Redeemer retain their distinct attack abilities")
	check(has_transport_ability(Profiles.profile("drop-pod"), "Drop Pod Assault") and has_transport_ability(Profiles.profile("drop-pod"), "Deployment Complete"), "Drop Pod deployment restrictions remain in the source record")
	check(has_transport_ability(Profiles.profile("impulsor"), "Rapid Disembarkation") and has_transport_ability(Profiles.profile("repulsor"), "Combat Embarkation"), "Impulsor and Repulsor retain their distinct transport rules")
	check(has_transport_ability(Profiles.profile("repulsor-executioner"), "Executioner") and has_transport_ability(Profiles.profile("rhino"), "Veiling Smoke (Once per phase, per unit)"), "Executioner and Rhino retain their distinct source abilities")
	print("Marine transport profiles: %d failures" % failures)
	quit(1 if failures else 0)
