extends SceneTree

const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")

var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func run() -> void:
	var profile := Profiles.profile("captain-in-gravis-armour")
	check(profile.points_by_models == {1: 90} and profile.models == 1 and profile.base_radius_inches == 20.0 / 25.4, "Cost, composition and 40 mm base match the local export")
	check(profile.stats == {
		"movement_inches": 5,
		"toughness": 6,
		"save_target": 3,
		"wounds": 6,
		"leadership_target": 6,
		"objective_control": 1,
		"invulnerable_target": 4
	}, "Characteristics match the local export")
	check(profile.keywords == ["INFANTRY", "CAPTAIN", "CHARACTER", "EXPLOSIVES", "GRAVIS", "IMPERIUM", "ADEPTUS ASTARTES"], "Keywords match the local export")
	check(profile.ranged.size() == 1 and profile.ranged[0].profiles.standard == {
		"name": "Master-crafted Heavy Bolt Rifle",
		"range_inches": 30.0,
		"attacks": 2,
		"skill": 2,
		"strength": 6,
		"ap": -1,
		"damage": 3,
		"keywords": {"heavy": true, "assault": true, "rapid-fire": 1}
	}, "Default Master-crafted Heavy Bolt Rifle matches every exported characteristic")
	check(profile.melee.size() == 1 and profile.melee[0].profiles.standard == {
		"name": "Master-crafted Power Weapon",
		"range_inches": 0.0,
		"attacks": 6,
		"skill": 2,
		"strength": 6,
		"ap": -2,
		"damage": 2,
		"keywords": {}
	}, "Default Master-crafted Power Weapon matches every exported characteristic")
	var choices := {
		"blade": {"name": "Relic Blade", "attacks": 2, "strength": 6, "ap": -2},
		"chainsword": {"name": "Relic Chainsword", "attacks": 3, "strength": 5, "ap": -1},
		"fist": {"name": "Relic Power Fist", "attacks": 1, "strength": 8, "ap": -2}
	}
	for mode: String in choices:
		var loadout := Profiles.gravis_captain_weapons(mode)
		check(loadout.ranged.size() == 1 and loadout.ranged[0].profiles.standard == {
			"name": "Boltstorm Gauntlet",
			"range_inches": 12.0,
			"attacks": 3,
			"skill": 2,
			"strength": 5,
			"ap": -1,
			"damage": 1,
			"keywords": {"close-quarters": true}
		}, "%s loadout Boltstorm Gauntlet matches every exported characteristic" % mode)
		check(loadout.melee.size() == 2, "%s loadout retains gauntlet and relic melee weapons" % mode)
		if loadout.melee.size() == 2:
			check(loadout.melee[0].profiles.standard == {
				"name": "Boltstorm Gauntlet",
				"range_inches": 0.0,
				"attacks": 5,
				"skill": 2,
				"strength": 8,
				"ap": -2,
				"damage": 2,
				"keywords": {}
			}, "%s loadout melee gauntlet matches the export" % mode)
			var relic: Dictionary = choices[mode]
			check(loadout.melee[1].profiles.standard == {
				"name": relic.name,
				"range_inches": 0.0,
				"attacks": relic.attacks,
				"skill": 2,
				"strength": relic.strength,
				"ap": relic.ap,
				"damage": 2,
				"keywords": {"extra-attacks": true}
			}, "%s relic matches its exported profile" % mode)
	var default_loadout := Profiles.gravis_captain_weapons("rifle")
	check(default_loadout.ranged == profile.ranged and default_loadout.melee == profile.melee, "Rifle choice preserves the exported default loadout")
	print("Captain in Gravis Armour local source profile parity: %d failures" % failures)
	quit(1 if failures else 0)

func _initialize() -> void:
	call_deferred("run")
