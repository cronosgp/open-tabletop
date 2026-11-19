extends SceneTree
## Offline source/index audit. Does not download or certify miniature geometry.
const Assets = preload("res://scripts/local_models.gd")
const Matcher = preload("res://scripts/forceorg_matcher.gd")
const Marines = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Necrons = preload("res://scripts/edition_11/current_reference_necron_profiles.gd")

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() not in [4, 5] or args[0] != "--source" or args[2] != "--output" or (args.size() == 5 and args[4] != "--index-only"):
		push_error("Expected --source <local TTS save> --output <local JSON report> [--index-only]")
		quit(2)
		return
	var scanned := Assets.scan(args[1])
	if not str(scanned.get("error", "")).is_empty():
		push_error(str(scanned.error))
		quit(1)
		return
	var indexed := 0
	var index_only := args.size() == 5
	var expected_indexed := 0
	var index_sha256 := ""
	for index_path: String in ["user://forceorg_visual_index.json", "res://.tools/forceorg-model-table/catalog_v2/runtime_visual_index.json"]:
		if not FileAccess.file_exists(index_path): continue
		var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(index_path))
		if not parsed is Dictionary or parsed.get("schema_version") != 1 or not parsed.get("sources") is Dictionary: continue
		var source_rows: Variant = parsed.sources.get(str(scanned.fingerprint), {})
		if source_rows is Dictionary and not source_rows.is_empty():
			expected_indexed = source_rows.size()
			index_sha256 = FileAccess.get_sha256(index_path)
			break
	for entry: Dictionary in scanned.entries:
		if entry.has("visual_definitions"): indexed += 1
	if indexed == 0:
		push_error("No generated index entries matched this exact save. Export/copy the current local index first.")
		quit(1)
		return
	var rows: Array[Dictionary] = []
	var counts := {}
	var specs: Array[Dictionary] = []
	if not index_only: specs.assign([{"prefix": "40kdc:11e:adeptus-astartes:", "catalog": Marines.catalog()}, {"prefix": "40kdc:11e:necrons:", "catalog": Necrons.catalog()}])
	for spec: Dictionary in specs:
		for identity: String in spec.catalog:
			var definition := str(spec.prefix) + identity
			var chosen := Matcher.choose(definition, scanned.entries)
			var entry: Dictionary = chosen.get("entry", {})
			var kind := "no_source_choice"
			if str(chosen.get("error", "")).is_empty():
				kind = "indexed_label_association" if definition in entry.get("visual_definitions", []) else "existing_visual_alias" if bool(chosen.get("visual_alias", false)) else "existing_name_match"
			counts[kind] = int(counts.get(kind, 0)) + 1
			rows.append({"definition_id": definition, "name": str(spec.catalog[identity].get("name", "")),
				"status": kind, "choice_count": int(chosen.get("variants", 0)),
				"chosen_label": str(entry.get("name", "")), "tts_path": str(entry.get("path", "")),
				"guid": str(entry.get("guid", "")), "source_group_hint": str(entry.get("source_group_hint", "")),
				"error": str(chosen.get("error", ""))})
			if rows.size() % 24 == 0: print("Audited %d current profile source choices" % rows.size())
	rows.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return str(a.definition_id) < str(b.definition_id))
	var output_path := ProjectSettings.globalize_path(args[3])
	DirAccess.make_dir_recursive_absolute(output_path.get_base_dir())
	var file := FileAccess.open(output_path, FileAccess.WRITE)
	if file == null:
		push_error("Could not write source-choice report")
		quit(1)
		return
	file.store_string(JSON.stringify({"scope": "offline source/index/matcher choices; no downloads, geometry import or visual certification",
		"index_only": index_only, "source_sha256": scanned.fingerprint, "visual_index_sha256": index_sha256,
		"indexed_entries": indexed, "expected_indexed_entries": expected_indexed, "parser_warnings": scanned.get("warnings", []),
		"runtime_identities": rows.size(), "status_counts": counts, "profiles": rows}, "\t"))
	file.close()
	print("Source-choice audit: %d/%d indexed occurrences; %d identities; %s" % [indexed, expected_indexed, rows.size(), JSON.stringify(counts)])
	var ok: bool = indexed == expected_indexed and scanned.get("warnings", []).is_empty()
	if not ok: push_error("Source/index coverage differs or the source parser reported warnings; inspect the local report.")
	quit(0 if ok else 1)
