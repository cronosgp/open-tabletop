extends SceneTree

const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")

var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func run() -> void:
	var profile := Profiles.profile("ballistus-dreadnought")
	check(profile.source_book_id == "000000139" and profile.source_datasheet_id == "000000091", "Ballistus maps to the shared Space Marines datasheet")
	check(profile.points_by_models == {1: 150} and profile.third_plus_points_by_models == {1: 170} and profile.models == 1, "Ballistus first/second and third-plus costs and composition match the local export")
	check(profile.stats == {
		"movement_inches": 8,
		"toughness": 10,
		"save_target": 2,
		"wounds": 12,
		"leadership_target": 6,
		"objective_control": 4,
		"invulnerable_target": 0
	}, "Ballistus characteristics match the local export")
	check(profile.damaged_threshold == 4, "Ballistus Damaged threshold matches the linked core ability parameter")
	check(profile.keywords == ["DREADNOUGHT", "IMPERIUM", "WALKER", "DEATHWING", "VEHICLE", "ADEPTUS ASTARTES"], "Ballistus keywords match the local export")
	check(profile.ranged.size() == 3 and profile.melee.size() == 1, "All fixed ranged and melee weapons are represented")
	if profile.ranged.size() == 3:
		check(profile.ranged[0].profiles.standard == {
			"name": "Ballistus Lascannon",
			"range_inches": 48.0,
			"attacks": 2,
			"skill": 3,
			"strength": 12,
			"ap": -3,
			"damage": "D3+3",
			"keywords": {}
		}, "Ballistus Lascannon matches every exported characteristic")
		check(profile.ranged[1].profiles.frag == {
			"name": "Ballistus Missile Launcher - Frag",
			"range_inches": 48.0,
			"attacks": "D6+6",
			"skill": 3,
			"strength": 5,
			"ap": -1,
			"damage": 1,
			"keywords": {"blast": 2}
		}, "Ballistus Frag profile matches every exported characteristic")
		check(profile.ranged[1].profiles.krak == {
			"name": "Ballistus Missile Launcher - Krak",
			"range_inches": 48.0,
			"attacks": 2,
			"skill": 3,
			"strength": 10,
			"ap": -2,
			"damage": "D3+3",
			"keywords": {}
		}, "Ballistus Krak profile matches every exported characteristic")
		check(profile.ranged[2].profiles.standard == {
			"name": "Storm Bolters",
			"range_inches": 24.0,
			"attacks": 4,
			"skill": 3,
			"strength": 5,
			"ap": -1,
			"damage": 1,
			"keywords": {"rapid-fire": 4}
		}, "Storm Bolters match every exported characteristic")
	if profile.melee.size() == 1:
		check(profile.melee[0].profiles.standard == {
			"name": "Armoured Feet",
			"range_inches": 0.0,
			"attacks": 5,
			"skill": 3,
			"strength": 7,
			"ap": 0,
			"damage": 1,
			"keywords": {}
		}, "Armoured Feet match every exported characteristic")
	check(profile.get("additional_weapon_profiles", {}).is_empty(), "The local export has no selectable Ballistus weapon options")
	print("Ballistus Dreadnought local source profile parity: %d failures" % failures)
	quit(1 if failures else 0)

func _initialize() -> void:
	call_deferred("run")
