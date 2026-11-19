extends SceneTree
## Exports identity-only links to current runtime profiles for a local visual review table.
## This does not claim that every rule or match interaction in a profile is implemented.

const MarineProfiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const NecronProfiles = preload("res://scripts/edition_11/current_reference_necron_profiles.gd")
const VisualMatcher = preload("res://scripts/forceorg_matcher.gd")

func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() != 2 or args[0] != "--output":
		push_error("Expected --output <JSON path>")
		quit(2)
		return
	var rows: Array[Dictionary] = []
	_append_catalog(rows, MarineProfiles.catalog(), "40kdc:11e:adeptus-astartes:", "Space Marines")
	_append_catalog(rows, NecronProfiles.catalog(), "40kdc:11e:necrons:", "Necrons")
	rows.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		if str(a.get("source_datasheet_id", "")) != str(b.get("source_datasheet_id", "")):
			return str(a.get("source_datasheet_id", "")) < str(b.get("source_datasheet_id", ""))
		return str(a.get("definition_id", "")) < str(b.get("definition_id", ""))
	)
	var seen: Dictionary = {}
	for row: Dictionary in rows:
		var source_id := str(row.get("source_datasheet_id", ""))
		if source_id.is_empty():
			push_error("A runtime profile has no source datasheet identity: " + str(row.get("definition_id", "")))
			quit(1)
			return
		if seen.has(source_id):
			push_error("A source datasheet maps to multiple runtime profiles: " + source_id)
			quit(1)
			return
		seen[source_id] = true
	var output_path := ProjectSettings.globalize_path(args[1])
	var dir_error := DirAccess.make_dir_recursive_absolute(output_path.get_base_dir())
	if dir_error != OK and dir_error != ERR_ALREADY_EXISTS:
		push_error("Could not create output directory for " + output_path)
		quit(1)
		return
	var file := FileAccess.open(output_path, FileAccess.WRITE)
	if file == null:
		push_error("Could not write runtime profile identity map to " + output_path)
		quit(1)
		return
	file.store_string(JSON.stringify({"profile_count": rows.size(), "profiles": rows,
		"visual_alias_registry_sha256": FileAccess.get_sha256("res://scripts/forceorg_matcher.gd"),
		"visual_alias_policy": "Existing reviewed presentation fallbacks; not datasheet identity or equipment certification."}, "\t"))
	file.close()
	print("Exported %d current Marine and Necron runtime profile identities to %s" % [rows.size(), output_path])
	quit(0)

func _append_catalog(rows: Array[Dictionary], catalog: Dictionary, prefix: String, runtime_catalog: String) -> void:
	for identity: String in catalog:
		var profile: Dictionary = catalog[identity]
		rows.append({
			"definition_id": prefix + identity,
			"runtime_catalog": runtime_catalog,
			"profile_identity": identity,
			"profile_name": str(profile.get("name", "")),
			"source_datasheet_id": str(profile.get("source_datasheet_id", profile.get("datasheet_id", ""))),
			"source_book_id": str(profile.get("source_book_id", "")),
			"source_snapshot_id": str(profile.get("source_snapshot_id", "")),
			"source_manifest_sha256": str(profile.get("source_manifest_sha256", "")),
			"source_scope": str(profile.get("source_scope", "")),
			"visual_fallback_labels": VisualMatcher._profile_alias_names(prefix + identity),
		})
