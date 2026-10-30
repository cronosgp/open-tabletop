extends SceneTree
## Exports source identities, roster-cost tiers and construction options for offline audits.
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Army = preload("res://scripts/edition_11/army_capabilities.gd")

func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() != 2 or args[0] != "--output":
		push_error("Expected --output <JSON path>")
		quit(1)
		return
	var profiles: Dictionary = Profiles.catalog()
	var records: Array[Dictionary] = []
	var missing: Array[String] = []
	var seen_ids := {}
	for identity: String in profiles:
		var profile: Dictionary = profiles[identity]
		var source_points: Dictionary = profile.get("source_roster_points", profile)
		var construction_choice := Army.current_catalog_choice({
			"id": "40kdc:11e:adeptus-astartes:" + identity,
			"edition": "11e",
			"faction": "Space Marines"
		})
		var source_id := str(profile.get("source_datasheet_id", profile.get("datasheet_id", "")))
		var source_book_id := str(profile.get("source_book_id", ""))
		if source_id.is_empty() or source_book_id.is_empty():
			missing.append(identity)
			continue
		if seen_ids.has(source_id):
			push_error("Duplicate Marine source ID %s for %s and %s" % [source_id, seen_ids[source_id], identity])
			quit(1)
			return
		seen_ids[source_id] = identity
		records.append({
			"source_datasheet_id": source_id,
			"source_book_id": source_book_id,
			"source_name": str(profile.get("name", "")),
			"identity": identity,
			"construction_options": construction_choice.get("options", []),
			"source_roster_points": {
				"points_by_models": source_points.get("points_by_models", {}),
				"second_plus_points_by_models": source_points.get("second_plus_points_by_models", {}),
				"third_plus_points_by_models": source_points.get("third_plus_points_by_models", {}),
				"fourth_plus_points_by_models": source_points.get("fourth_plus_points_by_models", {})
			}
		})
	records.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return a.source_datasheet_id < b.source_datasheet_id)
	var output_path := ProjectSettings.globalize_path(args[1])
	DirAccess.make_dir_recursive_absolute(output_path.get_base_dir())
	var file := FileAccess.open(output_path, FileAccess.WRITE)
	if file == null:
		push_error("Could not write runtime identity map to " + output_path)
		quit(1)
		return
	file.store_string(JSON.stringify({"profile_count": profiles.size(), "missing_source_ids": missing, "profiles": records}, "\t"))
	file.close()
	print("Exported %d runtime Space Marine identities; %d profiles lack source metadata" % [records.size(), missing.size()])
	quit(1 if not missing.is_empty() else 0)
