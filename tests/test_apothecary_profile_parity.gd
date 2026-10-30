extends SceneTree

const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Catalog = preload("res://scripts/edition_11/army_capabilities.gd")
const AbilityCatalog = preload("res://scripts/edition_11/unit_ability_catalog.gd")

var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func run() -> void:
	var profile := Profiles.profile("apothecary")
	check(profile.get("source_book_id") == "000000139" and profile.get("source_datasheet_id") == "000002773" and profile.get("source_export_updated_at") == "2026-10-16T21:03:46+03:00", "Apothecary identity follows the pinned Wahapedia e11 export")
	check(profile.get("points_by_models", {}) == {1: 45} and profile.get("models") == 1 and is_equal_approx(profile.get("base_radius_inches", 0.0), 20.0 / 25.4), "Fixed composition, cost and 40 mm base match local source data")
	check(profile.get("stats", {}) == {"movement_inches": 6, "toughness": 5, "save_target": 3, "wounds": 4, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 0}, "Apothecary characteristics match the local export")
	check(profile.get("keywords", []) == ["INFANTRY", "CHARACTER", "IMPERIUM", "TACTICUS", "ADEPTUS ASTARTES"], "Apothecary preserves the exported shared datasheet keywords")
	check(profile.get("ranged", []).size() == 1 and profile.get("melee", []).size() == 2 and profile.get("additional_weapon_profiles", {}).is_empty(), "The fixed loadout has one ranged profile, two melee profiles and no equipment options")
	if profile.get("ranged", []).size() == 1:
		check(profile.ranged[0].get("id") == "absolvor-bolt-pistol" and profile.ranged[0].profiles.standard == {
			"name": "Absolvor Bolt Pistol",
			"range_inches": 18.0,
			"attacks": 1,
			"skill": 3,
			"strength": 5,
			"ap": -2,
			"damage": 2,
			"keywords": {"close-quarters": true}
		}, "Absolvor Bolt Pistol matches every exported characteristic")
	if profile.get("melee", []).size() == 2:
		check(profile.melee[0].get("id") == "servo-armature" and profile.melee[0].profiles.standard == {
			"name": "Servo-armature",
			"range_inches": 0.0,
			"attacks": 4,
			"skill": 3,
			"strength": 5,
			"ap": 0,
			"damage": 1,
			"keywords": {}
		}, "Servo-armature matches every exported characteristic")
		check(profile.melee[1].get("id") == "reductor-pistol" and profile.melee[1].profiles.standard == {
			"name": "Reductor Pistol",
			"range_inches": 0.0,
			"attacks": 1,
			"skill": 3,
			"strength": 5,
			"ap": -4,
			"damage": 2,
			"keywords": {"extra-attacks": true}
		}, "Reductor Pistol matches every exported characteristic, including Extra Attacks")
	check(AbilityCatalog.RULES.get("apothecary", []) == ["support", "narthecium"], "The runtime registers the Apothecary Support role and Narthecium")
	var catalog_choice := Catalog.current_catalog_choice({"id": "40kdc:11e:adeptus-astartes:apothecary", "edition": "11e", "faction": "Space Marines"})
	check(catalog_choice.get("id") == "40kdc:11e:adeptus-astartes:apothecary" and catalog_choice.get("options", []) == [{"models": 1, "cost": 45}], "Current construction exposes the fixed one-model, 45-point Apothecary")
	print("Apothecary local source profile parity: %d failures" % failures)
	quit(1 if failures else 0)

func _initialize() -> void:
	call_deferred("run")
