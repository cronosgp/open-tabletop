extends SceneTree

const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")

var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func run() -> void:
	var profile := Profiles.profile("cato-sicarius")
	check(profile.source_book_id == "000000139" and profile.source_datasheet_id == "000004184", "Cato maps to the shared Space Marines datasheet")
	check(profile.points == 115 and profile.points_by_models == {1: 115} and profile.models == 1, "Cato's cost and composition match the local export")
	check(profile.stats == {
		"movement_inches": 6,
		"toughness": 5,
		"save_target": 2,
		"wounds": 5,
		"leadership_target": 6,
		"objective_control": 1,
		"invulnerable_target": 4
	}, "Cato's characteristics match the local export")
	check(profile.keywords == ["INFANTRY", "CHARACTER", "EPIC HERO", "EXPLOSIVES", "IMPERIUM", "TACTICUS", "ADEPTUS ASTARTES", "ULTRAMARINES"], "Cato's faction and unit keywords match the local export")
	check(profile.ranged.size() == 1 and profile.ranged[0].profiles.standard == {
		"name": "Artisan Plasma Pistol",
		"range_inches": 12.0,
		"attacks": 1,
		"skill": 2,
		"strength": 8,
		"ap": -3,
		"damage": 2,
		"keywords": {"close-quarters": true}
	}, "Cato's ranged weapon matches every exported characteristic")
	check(profile.melee.size() == 3, "All three Talassarian Tempest Blade profiles are represented")
	if profile.melee.size() == 3:
		var expected := [
			{"name": "Talassarian Tempest Blade - Strike", "range_inches": 0.0, "attacks": 4, "skill": 2, "strength": 6, "ap": -3, "damage": 3, "keywords": {"devastating-wounds": true}},
			{"name": "Talassarian Tempest Blade - Coup de Grace", "range_inches": 0.0, "attacks": 6, "skill": 2, "strength": 5, "ap": -2, "damage": 2, "keywords": {"precision": true}},
			{"name": "Talassarian Tempest Blade - Sweep", "range_inches": 0.0, "attacks": 9, "skill": 2, "strength": 5, "ap": -2, "damage": 1, "keywords": {"sustained-hits": 1}}
		]
		for index in range(expected.size()):
			check(profile.melee[index].profiles.standard == expected[index], "Tempest Blade profile %d matches the local export" % (index + 1))
	check(profile.get("additional_weapon_profiles", {}).is_empty(), "No unrepresented selectable weapon options exist in the local export")
	print("Cato local source profile parity: %d failures" % failures)
	quit(1 if failures else 0)

func _initialize() -> void:
	call_deferred("run")
