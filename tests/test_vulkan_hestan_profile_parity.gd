extends SceneTree

const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")

var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func run() -> void:
	var profile := Profiles.profile("vulkan-hestan")
	check(profile.source_book_id == "000000139" and profile.source_datasheet_id == "000002726", "Vulkan maps to the shared Space Marines datasheet")
	check(profile.points == 105 and profile.points_by_models == {1: 105} and profile.models == 1, "Vulkan's cost and composition match the local export")
	check(profile.stats == {
		"movement_inches": 6,
		"toughness": 5,
		"save_target": 2,
		"wounds": 5,
		"leadership_target": 6,
		"objective_control": 1,
		"invulnerable_target": 4
	}, "Vulkan's characteristics match the local export")
	check(profile.keywords == ["INFANTRY", "CHARACTER", "EPIC HERO", "EXPLOSIVES", "IMPERIUM", "TACTICUS", "ADEPTUS ASTARTES", "SALAMANDERS"], "Vulkan's faction and unit keywords match the local export")
	check(profile.ranged.size() == 2, "Both exported ranged weapons are represented")
	if profile.ranged.size() == 2:
		check(profile.ranged[0].profiles.standard == {
			"name": "Bolt Pistol",
			"range_inches": 12.0,
			"attacks": 1,
			"skill": 2,
			"strength": 5,
			"ap": -1,
			"damage": 1,
			"keywords": {"close-quarters": true}
		}, "Vulkan's Bolt Pistol matches every exported characteristic")
		check(profile.ranged[1].profiles.standard == {
			"name": "Gauntlet of the Forge",
			"range_inches": 12.0,
			"attacks": "D6+3",
			"skill": 0,
			"strength": 6,
			"ap": -1,
			"damage": 1,
			"keywords": {"torrent": true, "close-quarters": true}
		}, "Gauntlet of the Forge matches every exported characteristic")
	check(profile.melee.size() == 1, "The exported melee weapon is represented")
	if profile.melee.size() == 1:
		check(profile.melee[0].profiles.standard == {
			"name": "Spear of Vulkan",
			"range_inches": 0.0,
			"attacks": 6,
			"skill": 2,
			"strength": 7,
			"ap": -2,
			"damage": 2,
			"keywords": {"devastating-wounds": true}
		}, "Spear of Vulkan matches every exported characteristic")
	check(profile.get("additional_weapon_profiles", {}).is_empty(), "No unrepresented selectable weapon options exist in the local export")
	print("Vulkan He'stan local source profile parity: %d failures" % failures)
	quit(1 if failures else 0)

func _initialize() -> void:
	call_deferred("run")
