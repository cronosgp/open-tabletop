extends SceneTree
## Recover missing standard-profile links from existing local caches only.
## Dry run by default; --apply backs up the original config before saving.
const Assets = preload("res://scripts/local_models.gd")
const Matcher = preload("res://scripts/forceorg_matcher.gd")
const ImportPanel = preload("res://scripts/model_import_panel.gd")
const Showcase = preload("res://scripts/ui/model_showcase.gd")

func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	var apply := "--apply" in args
	var settings_path := "user://local-models.cfg"
	var output := ""
	for index in range(args.size()):
		if args[index] in ["--settings", "--output"]:
			if index + 1 >= args.size():
				push_error("Missing argument value."); quit(1); return
			if args[index] == "--settings": settings_path = args[index + 1]
			else: output = args[index + 1]
	var cfg := ConfigFile.new()
	if cfg.load(settings_path) != OK or cfg.get_value("models", "version", 0) != 1 or not cfg.get_value("models", "mappings", {}) is Dictionary:
		push_error("Cannot read version-1 local model settings."); quit(1); return
	var original_hash := FileAccess.get_sha256(settings_path)
	var original: Dictionary = cfg.get_value("models", "mappings")
	var next := original.duplicate(true)
	var scanned := Assets.scan(str(cfg.get_value("paths", "source", "")))
	if not str(scanned.get("error", "")).is_empty():
		push_error(str(scanned.error)); quit(1); return
	var indexes: Array[Dictionary] = []
	for key: String in ["cache", "downloads"]:
		var path := str(cfg.get_value("paths", key, ""))
		if path.is_empty(): continue
		var cache_index := Assets.index_cache(path)
		if str(cache_index.get("error", "")).is_empty(): indexes.append({"path": path, "index": cache_index})
	var panel := ImportPanel.new()
	var rows: Array[Dictionary] = []
	var recovered := 0
	for profile: Dictionary in Showcase.standard_profiles():
		var definition := str(profile.definition)
		# Preserve existing records, including malformed ones, for separate review.
		if original.has(definition): continue
		var row := {"definition": definition, "status": "unresolved", "failures": {}}
		var options := Matcher.variants(definition, scanned.entries)
		row["candidate_count"] = options.size()
		for option: Dictionary in options:
			for cache_index: Dictionary in indexes:
				var candidate := _candidate(panel, definition, option, cache_index.index, scanned)
				var issue := str(candidate.get("error", ""))
				if not issue.is_empty():
					row.failures[issue] = int(row.failures.get(issue, 0)) + 1
					continue
				next[definition] = candidate.mapping
				row.merge({"status": "recoverable", "name": option.get("name", ""), "source_path": option.get("path", ""), "guid": option.get("guid", ""), "cache": cache_index.path, "parts": candidate.mapping.parts.size(), "fingerprint": candidate.mapping.fingerprint, "reviewed_visual_alias": Matcher._is_reviewed_alias_entry(definition, option)}, true)
				recovered += 1
				break
			if row.status == "recoverable": break
		rows.append(row)
		print("%s: %s" % [definition, row.status])
	var report := {"settings": ProjectSettings.globalize_path(settings_path), "before_sha256": original_hash, "source_sha256": scanned.get("fingerprint", ""), "standard_profiles": Showcase.standard_profiles().size(), "missing_before": rows.size(), "recoverable": recovered, "missing_after": rows.size() - recovered, "applied": false, "network_used": false, "scope": "Local file, fingerprint and base-fit checks; no sculpt, visible equipment, facing or rules certification.", "profiles": rows}
	var issue := ""
	if apply and recovered > 0:
		issue = _save_recovery(cfg, settings_path, original_hash, next, report)
	panel.free()
	if not output.is_empty():
		var file := FileAccess.open(output, FileAccess.WRITE)
		if file == null:
			push_error("Cannot write reconciliation report."); quit(1); return
		file.store_string(JSON.stringify(report, "  "))
		file.close()
	print(JSON.stringify({"missing_before": rows.size(), "recoverable": recovered, "missing_after": rows.size() - recovered, "applied": report.applied, "error": issue}))
	if not issue.is_empty(): push_error(issue)
	quit(0 if issue.is_empty() and recovered == rows.size() else 1)

func _candidate(panel: VBoxContainer, definition: String, option: Dictionary, cache_index: Dictionary, scanned: Dictionary) -> Dictionary:
	var entry := option.duplicate(true)
	entry["preserve_source_pose"] = true
	var resolved := Assets.resolve_cache(entry, cache_index)
	if not str(resolved.get("error", "")).is_empty(): return {"error": resolved.error}
	var cached: Dictionary = panel._cached_component_files(resolved)
	if not str(cached.get("error", "")).is_empty(): return {"error": cached.error}
	if cached.parts.is_empty(): return {"error": "No cached mesh parts."}
	var asset := Assets.composite_from_files(cached.parts, {"defer_texture_upload": true})
	if not str(asset.get("error", "")).is_empty(): return {"error": asset.error}
	var mapping := {"path": str(cached.parts[0].path), "texture": str(cached.parts[0].get("texture", "")), "parts": cached.parts, "entry": entry, "scale": 1.0, "rotation": 180.0, "offset": 0.0, "tts_scale": float(entry.get("tts_scale", 1.0)), "fingerprint": asset.fingerprint, "texture_fingerprint": asset.get("texture_fingerprint", ""), "source": scanned.get("source", ""), "source_fingerprint": scanned.get("fingerprint", ""), "import_mode": "forceorg-source-pose-pilot"}
	if not panel._mapping_files_available(mapping): return {"error": "Missing files or unresolved bundle dependencies."}
	var fit_issue := Assets.visual_error_for_base(asset, panel._visual_settings(mapping, definition, 0.0))
	if not fit_issue.is_empty(): return {"error": fit_issue}
	return {"error": "", "mapping": mapping}

func _save_recovery(cfg: ConfigFile, path: String, expected_hash: String, next: Dictionary, report: Dictionary) -> String:
	# Reject concurrent changes rather than overwriting another app's settings.
	if FileAccess.get_sha256(path) != expected_hash: return "Settings changed during reconciliation; rerun against the current file."
	var absolute := ProjectSettings.globalize_path(path)
	var backup := absolute + ".before-reconciliation-" + str(Time.get_ticks_usec()) + ".bak"
	if DirAccess.copy_absolute(absolute, backup) != OK: return "Could not create settings backup."
	report["backup"] = backup
	var temporary := absolute + ".reconcile.tmp"
	# Insert new entries into the original text. Re-encoding the full config can
	# round existing transforms, even when their dictionaries were not edited.
	var original: Dictionary = cfg.get_value("models", "mappings")
	var original_text := FileAccess.get_file_as_string(absolute)
	var section_pattern := RegEx.create_from_string("(?m)^\\[models\\]\\r?$")
	var section_match := section_pattern.search(original_text)
	if section_match == null: return "Cannot locate the models section."
	var end := original_text.find("\n[", section_match.get_end())
	if end < 0: end = original_text.length()
	var field_pattern := RegEx.create_from_string("(?m)^mappings[ \\t]*=[ \\t]*\\{")
	var fields := field_pattern.search_all(original_text.substr(section_match.get_end(), end - section_match.get_end()))
	if fields.size() != 1: return "Cannot uniquely locate the mappings dictionary."
	var position := section_match.get_end() + fields[0].get_end()
	var additions: Array[String] = []
	for definition: String in next:
		if not original.has(definition): additions.append(var_to_str(definition) + ": " + var_to_str(next[definition]))
	var insertion := "\n" + ",\n".join(additions) + (",\n" if not original.is_empty() else "\n")
	var updated := original_text.substr(0, position) + insertion + original_text.substr(position)
	var expected := ConfigFile.new()
	if expected.parse(updated) != OK: return "Could not encode recovery settings."
	var file := FileAccess.open(temporary, FileAccess.WRITE)
	if file == null: return "Could not write temporary settings."
	file.store_string(updated)
	file.close()
	var reread := ConfigFile.new()
	if reread.load(temporary) != OK or reread.encode_to_text() != expected.encode_to_text(): return "Temporary settings failed serialization read-back."
	var saved: Dictionary = reread.get_value("models", "mappings", {})
	for definition: String in original:
		if not saved.has(definition) or saved[definition] != original[definition]: return "An existing mapping changed during serialization."
	if FileAccess.get_sha256(path) != expected_hash: return "Settings changed before replacement; original left in place."
	if DirAccess.rename_absolute(temporary, absolute) != OK: return "Could not replace settings; backup retained."
	if reread.load(absolute) != OK or reread.encode_to_text() != expected.encode_to_text(): return "Saved settings failed read-back; restore the recorded backup."
	report["applied"] = true
	report["after_sha256"] = FileAccess.get_sha256(absolute)
	return ""
