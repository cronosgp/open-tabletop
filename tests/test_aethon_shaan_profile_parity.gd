extends SceneTree

const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")

var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func run() -> void:
	var profile := Profiles.profile("aethon-shaan")
	check(profile.source_book_id == "000000139" and profile.source_datasheet_id == "000004148", "Aethon maps to the shared Space Marines datasheet")
	check(profile.points_by_models == {1: 105} and profile.models == 1 and profile.base_radius_inches == 25.0 / 25.4, "Aethon's cost, composition and 50 mm base match the local export")
	check(profile.stats == {
		"movement_inches": 14,
		"toughness": 5,
		"save_target": 3,
		"wounds": 5,
		"leadership_target": 6,
		"objective_control": 1,
		"invulnerable_target": 4
	}, "Aethon's characteristics match the local export")
	check(profile.keywords == ["INFANTRY", "CHARACTER", "EPIC HERO", "CHAPTER MASTER", "JUMP PACK", "FLY", "TACTICUS", "SMOKE", "EXPLOSIVES", "IMPERIUM", "ADEPTUS ASTARTES", "RAVEN GUARD"], "Aethon's keywords match the local export")
	check(profile.ranged.size() == 1 and profile.ranged[0].profiles.standard == {
		"name": "Heavy Bolt Pistol",
		"range_inches": 18.0,
		"attacks": 1,
		"skill": 2,
		"strength": 5,
		"ap": -1,
		"damage": 1,
		"keywords": {"close-quarters": true}
	}, "Aethon's Heavy Bolt Pistol matches every exported characteristic")
	check(profile.melee.size() == 1, "Claws of Severax are represented")
	if profile.melee.size() == 1:
		check(profile.melee[0].profiles.standard == {
			"name": "Claws of Severax",
			"range_inches": 0.0,
			"attacks": 7,
			"skill": 2,
			"strength": 5,
			"ap": -2,
			"damage": 2,
			"keywords": {"twin-linked": true, "sustained-hits": 2},
			"target_restricted_traits": {"sustained-hits": ["MONSTER", "VEHICLE"]}
		}, "Claws of Severax match the exported profile and restricted Sustained Hits targets")
	check(profile.get("additional_weapon_profiles", {}).is_empty(), "The local export has no selectable Aethon weapon options")
	print("Aethon Shaan local source profile parity: %d failures" % failures)
	quit(1 if failures else 0)

func _initialize() -> void:
	call_deferred("run")
