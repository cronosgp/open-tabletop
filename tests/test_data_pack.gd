extends SceneTree

const Pack = preload("res://scripts/data_pack.gd")
var failures := 0

func check(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		failures += 1

func _initialize() -> void:
	var pack: Dictionary = Pack.load_pack("res://data/packs/demo")
	check(pack.error == "", "Demo pack failed integrity validation")
	check(Pack.playable_error(pack) == "", "Demo pack is not playable")
	var original_hash: String = pack.manifest.units_sha256
	pack.manifest.edition = "11e"
	check(Pack.playable_error(pack) != "", "Unimplemented edition allowed")
	pack.manifest.edition = "demo"
	pack.units[0].unsupported_rules = ["unimplemented effect"]
	check(Pack.playable_error(pack) != "", "Unsupported ability allowed")
	pack.units[0].unsupported_rules = []
	pack.units[0].base = null
	check(Pack.playable_error(pack) != "", "Missing geometry allowed")
	check(not Pack.load_pack("res://data/missing").error.is_empty(), "Missing pack allowed")
	var temporary := "user://pack-integrity-test"
	DirAccess.make_dir_recursive_absolute(temporary)
	var file := FileAccess.open(temporary.path_join("units.json"), FileAccess.WRITE)
	file.store_string("[]")
	file.close()
	file = FileAccess.open(temporary.path_join("manifest.json"), FileAccess.WRITE)
	file.store_string(JSON.stringify({"schema_version": 1, "id": "test", "edition": "demo", "implementation": "prototype-movement-v1", "units_sha256": original_hash}))
	file.close()
	check(Pack.load_pack(temporary).error == "Unit content hash mismatch.", "Tampered pack allowed")
	var arguments := OS.get_cmdline_user_args()
	if not arguments.is_empty():
		var imported: Dictionary = Pack.load_pack(arguments[0])
		check(imported.error == "", "Imported pack could not be read offline")
		check(not Pack.playable_error(imported).is_empty(), "Reference pack allowed in an enforced match")
	print("Data pack checks complete: %d failures" % failures)
	quit(1 if failures else 0)
