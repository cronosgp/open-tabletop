extends SceneTree

const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")

var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func run() -> void:
	var profile := Profiles.profile("captain-in-phobos-armour")
	check(profile.source_book_id == "000000139" and profile.source_datasheet_id == "000002701", "Captain in Phobos Armour maps to the shared Space Marines datasheet")
	check(profile.points_by_models == {1: 75} and profile.models == 1 and profile.base_radius_inches == 20.0 / 25.4, "Cost, composition and 40 mm base match the local export")
	check(profile.stats == {
		"movement_inches": 8,
		"toughness": 4,
		"save_target": 3,
		"wounds": 5,
		"leadership_target": 6,
		"objective_control": 1,
		"invulnerable_target": 4
	}, "Characteristics match the local export")
	check(profile.keywords == ["INFANTRY", "CHARACTER", "CAPTAIN", "EXPLOSIVES", "IMPERIUM", "PHOBOS", "ADEPTUS ASTARTES"], "Keywords match the local export")
	check(profile.ranged.size() == 2 and profile.ranged[0].profiles.standard == {
		"name": "Instigator Bolt Carbine",
		"range_inches": 24.0,
		"attacks": 1,
		"skill": 2,
		"strength": 4,
		"ap": -2,
		"damage": 2,
		"keywords": {"precision": true}
	}, "Instigator Bolt Carbine matches every exported characteristic")
	if profile.ranged.size() == 2:
		check(profile.ranged[1].profiles.standard == {
			"name": "Bolt Pistol",
			"range_inches": 12.0,
			"attacks": 1,
			"skill": 2,
			"strength": 5,
			"ap": -1,
			"damage": 1,
			"keywords": {"close-quarters": true}
		}, "Bolt Pistol matches every exported characteristic")
	check(profile.melee.size() == 1, "Combat Knife is represented")
	if profile.melee.size() == 1:
		check(profile.melee[0].profiles.standard == {
			"name": "Combat Knife",
			"range_inches": 0.0,
			"attacks": 6,
			"skill": 2,
			"strength": 5,
			"ap": -1,
			"damage": 1,
			"keywords": {"precision": true, "sustained-hits": 1}
		}, "Combat Knife matches every exported characteristic")
	check(profile.get("additional_weapon_profiles", {}).is_empty(), "No selectable Captain weapon options exist in the local export")
	print("Captain in Phobos Armour local source profile parity: %d failures" % failures)
	quit(1 if failures else 0)

func _initialize() -> void:
	call_deferred("run")
