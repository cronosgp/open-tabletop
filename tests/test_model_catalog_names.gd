extends SceneTree

const Matcher = preload("res://scripts/forceorg_matcher.gd")
const Marines = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Necrons = preload("res://scripts/edition_11/current_reference_necron_profiles.gd")
var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		failures += 1
		push_error(message)

func _initialize() -> void:
	check(not FileAccess.file_exists("res://data/imported/starter-11e-v1/adeptus-astartes/units.json"), "This suite requires a clean current-catalog fixture without the historical starter pack")
	var checked := 0
	for spec: Dictionary in [{"prefix": "40kdc:11e:adeptus-astartes:", "catalog": Marines.catalog()}, {"prefix": "40kdc:11e:necrons:", "catalog": Necrons.catalog()}]:
		for identity: String in spec.catalog:
			var definition := str(spec.prefix) + identity
			check(Matcher.supported_definition(definition), "Current visual identity is recognized without legacy data: " + definition)
			check(not Matcher._profile_name(definition).is_empty(), "Current visual identity has a local profile name: " + definition)
			checked += 1
	var entry := {"name": "Doomsday Ark", "kind": "CustomMesh", "references": {"MeshURL": "https://example.invalid/ark"}, "path": "ObjectStates/1"}
	check(Matcher.choose("40kdc:11e:necrons:doomsday-ark", [entry]).get("error", "").is_empty(), "A current profile can resolve a miniature from its current name alone")
	print("CURRENT MODEL CATALOG NAMES: %d identities, %d failures" % [checked, failures])
	quit(0 if failures == 0 else 1)
