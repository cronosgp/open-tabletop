extends SceneTree

const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")

var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func run() -> void:
	var profile := Profiles.profile("techmarine")
	check(profile.source_book_id == "000000139" and profile.source_datasheet_id == "000000140", "Techmarine maps to the shared Space Marines datasheet")
	check(profile.points_by_models == {1: 55} and profile.models == 1 and profile.base_radius_inches == 20.0 / 25.4, "Cost, composition and 40 mm base match the local export")
	check(profile.stats == {
		"movement_inches": 6,
		"toughness": 5,
		"save_target": 2,
		"wounds": 4,
		"leadership_target": 6,
		"objective_control": 1,
		"invulnerable_target": 0
	}, "Characteristics match the local export")
	check(profile.keywords == ["INFANTRY", "CHARACTER", "TACTICUS", "EXPLOSIVES", "IMPERIUM", "ADEPTUS ASTARTES"], "Keywords match the local export")
	check(profile.ranged.size() == 2 and profile.ranged[0].profiles.standard == {
		"name": "Forge Bolter",
		"range_inches": 24.0,
		"attacks": 3,
		"skill": 2,
		"strength": 5,
		"ap": -1,
		"damage": 2,
		"keywords": {"sustained-hits": 1}
	}, "Forge Bolter matches every exported characteristic")
	if profile.ranged.size() == 2:
		check(profile.ranged[1].profiles.standard == {
			"name": "Grav-pistol",
			"range_inches": 12.0,
			"attacks": 2,
			"skill": 2,
			"strength": 2,
			"ap": -1,
			"damage": 3,
			"keywords": {"anti-vehicle": 2, "close-quarters": true}
		}, "Grav-pistol matches every exported characteristic")
	check(profile.melee.size() == 1 and profile.melee[0].profiles.standard == {
		"name": "Omnissian Power Axe and Servo-arm",
		"range_inches": 0.0,
		"attacks": 5,
		"skill": 3,
		"strength": 6,
		"ap": -2,
		"damage": 2,
		"keywords": {}
	}, "Omnissian Power Axe and Servo-arm match every exported characteristic")
	check(profile.get("additional_weapon_profiles", {}).is_empty(), "No selectable Techmarine weapon options exist in the local export")
	print("Techmarine local source profile parity: %d failures" % failures)
	quit(1 if failures else 0)

func _initialize() -> void:
	call_deferred("run")
