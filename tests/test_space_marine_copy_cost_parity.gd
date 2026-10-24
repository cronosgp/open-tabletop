extends SceneTree

const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Catalog = preload("res://scripts/edition_11/army_capabilities.gd")

var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func run() -> void:
	var cases := [
		{"identity": "victrix-honour-guard", "models": [3, 6], "first": [120, 250], "third": [150, 280]},
		{"identity": "bladeguard-veteran-squad", "models": [3, 6], "first": [90, 180], "third": [110, 200]},
		{"identity": "sternguard-veteran-squad", "models": [5, 10], "first": [105, 210], "third": [120, 225]},
		{"identity": "eradicator-squad-with-melta-rifles", "models": [3, 6], "first": [100, 200], "third": [120, 220]},
		{"identity": "eradicator-squad-with-heavy-bolters", "models": [3, 6], "first": [100, 215], "third": [130, 245]},
		{"identity": "hellblaster-squad", "models": [5, 10], "first": [115, 230], "third": [130, 245]},
		{"identity": "assault-intercessors-with-jump-packs", "models": [5, 10], "first": [95, 190], "third": [105, 200]},
	]
	for item: Dictionary in cases:
		var profile: Dictionary = Profiles.profile(item.identity)
		var expected_first := {item.models[0]: item.first[0], item.models[1]: item.first[1]}
		var expected_third := {item.models[0]: item.third[0], item.models[1]: item.third[1]}
		check(profile.points_by_models == expected_first, "%s first-two-unit costs match the local export" % item.identity)
		check(profile.get("third_plus_points_by_models", {}) == expected_third, "%s third-plus costs match the local export" % item.identity)
		var catalog := Catalog.current_catalog_choice({
			"id": "40kdc:11e:adeptus-astartes:" + item.identity,
			"edition": "11e",
			"faction": "Space Marines"
		})
		var expected_options := [
			{"models": item.models[0], "cost": item.first[0], "third_plus_cost": item.third[0]},
			{"models": item.models[1], "cost": item.first[1], "third_plus_cost": item.third[1]}
		]
		check(catalog.get("options", []) == expected_options, "%s construction catalog publishes both source copy tiers" % item.identity)
	print("Space Marine local copy-cost parity: %d failures" % failures)
	quit(1 if failures else 0)

func _initialize() -> void:
	call_deferred("run")
