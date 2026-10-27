extends SceneTree

const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")

var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func run() -> void:
	var profile := Profiles.profile("judiciar")
	check(profile.points_by_models == {1: 50} and profile.models == 1 and profile.base_radius_inches == 20.0 / 25.4, "Cost, composition and 40 mm base match the local export")
	check(profile.stats == {
		"movement_inches": 6,
		"toughness": 5,
		"save_target": 3,
		"wounds": 4,
		"leadership_target": 6,
		"objective_control": 1,
		"invulnerable_target": 0,
		"melee_invulnerable_target": 4
	}, "Characteristics and melee-only invulnerable save match the local export")
	check(profile.keywords == ["INFANTRY", "CHARACTER", "IMPERIUM", "TACTICUS", "ADEPTUS ASTARTES"], "Keywords match the local export")
	check(profile.ranged.size() == 1 and profile.ranged[0].profiles.standard == {
		"name": "Absolvor Bolt Pistol",
		"range_inches": 18.0,
		"attacks": 1,
		"skill": 3,
		"strength": 5,
		"ap": -2,
		"damage": 2,
		"keywords": {"close-quarters": true}
	}, "Absolvor Bolt Pistol matches every exported characteristic")
	check(profile.melee.size() == 1 and profile.melee[0].profiles.standard == {
		"name": "Executioner Relic Blade",
		"range_inches": 0.0,
		"attacks": 5,
		"skill": 2,
		"strength": 7,
		"ap": -2,
		"damage": 2,
		"keywords": {"precision": true, "devastating-wounds": true}
	}, "Executioner Relic Blade matches every exported characteristic")
	check(profile.get("additional_weapon_profiles", {}).is_empty(), "No selectable Judiciar weapon options exist in the local export")
	print("Judiciar local source profile parity: %d failures" % failures)
	quit(1 if failures else 0)

func _initialize() -> void:
	call_deferred("run")
