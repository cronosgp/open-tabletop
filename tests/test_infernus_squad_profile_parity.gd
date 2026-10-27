extends SceneTree

const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Catalog = preload("res://scripts/edition_11/army_capabilities.gd")

var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func run() -> void:
	var profile := Profiles.profile("infernus-squad")
	check(profile.points_by_models == {5: 95, 10: 190} and profile.third_plus_points_by_models == {5: 105, 10: 200}, "Both first-two and third-plus costs match the local export")
	check(profile.models == 5 and profile.base_radius_inches == 16.0 / 25.4, "Five-to-ten model composition and 32 mm base match the local export")
	check(profile.stats == {
		"movement_inches": 6,
		"toughness": 5,
		"save_target": 3,
		"wounds": 2,
		"leadership_target": 6,
		"objective_control": 1,
		"invulnerable_target": 0
	}, "Characteristics match the local export")
	check(profile.keywords == ["INFANTRY", "EXPLOSIVES", "IMPERIUM", "TACTICUS", "ADEPTUS ASTARTES"], "Keywords match the local export")
	check(profile.ranged.size() == 2 and profile.ranged[0].profiles.standard == {
		"name": "Pyreblaster",
		"range_inches": 12.0,
		"attacks": 3,
		"skill": 3,
		"strength": 5,
		"ap": -1,
		"damage": 1,
		"keywords": {"torrent": true, "blast": 1}
	}, "Pyreblaster matches every exported characteristic")
	if profile.ranged.size() == 2:
		check(profile.ranged[1].profiles.standard == {
			"name": "Bolt Pistol",
			"range_inches": 12.0,
			"attacks": 1,
			"skill": 3,
			"strength": 5,
			"ap": -1,
			"damage": 1,
			"keywords": {"close-quarters": true}
		}, "Bolt Pistol matches every exported characteristic")
	check(profile.melee.size() == 1 and profile.melee[0].profiles.standard == {
		"name": "Ceramite Fists",
		"range_inches": 0.0,
		"attacks": 3,
		"skill": 3,
		"strength": 5,
		"ap": 0,
		"damage": 1,
		"keywords": {}
	}, "Ceramite Fists match every exported characteristic")
	var catalog := Catalog.current_catalog_choice({"id": "40kdc:11e:adeptus-astartes:infernus-squad", "edition": "11e", "faction": "Space Marines"})
	check(catalog.get("options", []) == [
		{"models": 5, "cost": 95, "third_plus_cost": 105},
		{"models": 10, "cost": 190, "third_plus_cost": 200}
	], "Construction catalog exposes both source-sized options and the third-plus costs")
	print("Infernus Squad local source profile parity: %d failures" % failures)
	quit(1 if failures else 0)

func _initialize() -> void:
	call_deferred("run")
