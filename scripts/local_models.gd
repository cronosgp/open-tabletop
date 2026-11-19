extends RefCounted
## Local visual data only. Never executes TTS scripts or imports gameplay geometry.
const MAX_BYTES := 64 * 1024 * 1024
const MAX_OBJECTS := 100000
# Bump when the pre-index scanner entry format changes; indexed links stay uncached.
const CATALOG_SCAN_CACHE_VERSION := 1
const CATALOG_SCAN_CACHE_PATH := "user://forceorg-scan-cache-v1.bin"
const CATALOG_SCAN_CACHE_MAX_BYTES := 128 * 1024 * 1024
const MAX_OBJ_ATTRIBUTES := 1000000
const MAX_OBJ_TRIANGLE_VERTICES := 1000000
static var _image_texture_cache: Dictionary = {}
static var _profiling_enabled := false
static var _profile_metrics: Dictionary = {}
static var _profile_mutex := Mutex.new()
const MM_PER_INCH := 25.4
const DEFAULT_INFANTRY_BASE_MM := 32.0
const INFANTRY_BASE_DIAMETER_LIMIT_IN := 1.72
const INFANTRY_HEIGHT_TO_BASE_RATIO := 1.35
const COMPLETE_INFANTRY_MIN_HEIGHT_TO_BASE_RATIO := 0.65
const HULL_VISUAL_FIT_VERSION := 2

static func set_profiling_enabled(enabled: bool) -> void:
	_profile_mutex.lock()
	if _profiling_enabled == enabled:
		_profile_mutex.unlock()
		return
	_profiling_enabled = enabled
	if enabled: _profile_metrics.clear()
	_profile_mutex.unlock()

static func get_profile_metrics() -> Dictionary:
	_profile_mutex.lock()
	var result := _profile_metrics.duplicate(true)
	_profile_mutex.unlock()
	return result

static func record_profile_duration(stage: String, elapsed_ms: float, byte_count: int = 0) -> void:
	if not is_finite(elapsed_ms) or elapsed_ms < 0.0: return
	_profile_mutex.lock()
	if not _profiling_enabled:
		_profile_mutex.unlock()
		return
	var metric: Dictionary = _profile_metrics.get(stage, {"count": 0, "total_ms": 0.0, "bytes": 0})
	metric["count"] = int(metric.get("count", 0)) + 1
	metric["total_ms"] = float(metric.get("total_ms", 0.0)) + elapsed_ms
	metric["bytes"] = int(metric.get("bytes", 0)) + maxi(0, byte_count)
	_profile_metrics[stage] = metric
	_profile_mutex.unlock()

static func _record_profile_metric(stage: String, elapsed_usec: int, byte_count: int = 0) -> void:
	record_profile_duration(stage, float(elapsed_usec) / 1000.0, byte_count)

static func cache_key(value: String) -> String:
	if value.length() > 4096: return ""
	var result := ""
	value = value.trim_prefix("{verifycache}")
	for character: String in value.to_lower():
		if (character >= "a" and character <= "z") or (character >= "0" and character <= "9"): result += character
	return result

static func index_cache(root: String) -> Dictionary:
	if not DirAccess.dir_exists_absolute(root): return {"error": "Choose an existing local TTS Mods/cache directory."}
	var downloaded_name := RegEx.new()
	downloaded_name.compile("^([a-f0-9]{64})-[a-f0-9]{16}\\.(?:obj|png|unity3d|bundle\\.json)$")
	var pending: Array = [{"path": root, "depth": 0}]
	var names: Dictionary = {}
	var count := 0
	var directories := 0
	while not pending.is_empty():
		var next: Dictionary = pending.pop_back()
		var directory := DirAccess.open(next.path)
		if directory == null: return {"error": "Cannot read cache directory: " + next.path}
		directories += 1
		if directories > 2048: return {"error": "Cache scan exceeds 2,048 directories. Choose a smaller folder."}
		if directory.list_dir_begin() != OK: return {"error": "Cannot list cache directory: " + next.path}
		var name := directory.get_next()
		while not name.is_empty():
			var path: String = str(next.path).path_join(name)
			if not name.begins_with(".") and not directory.is_link(name):
				if directory.current_is_dir():
					if next.depth >= 8: return {"error": "Cache scan exceeds eight directory levels. Choose a smaller folder."}
					pending.append({"path": path, "depth": next.depth + 1})
				else:
					count += 1
					if count > 50000: return {"error": "Cache scan exceeds 50,000 files. Choose a smaller folder."}
					var keys: Array[String] = [cache_key(name)]
					var downloaded_match := downloaded_name.search(name)
					if downloaded_match != null: keys.append(downloaded_match.get_string(1))
					if name.get_extension().to_lower() in ["obj", "png", "jpg", "jpeg", "webp"]:
						var stem := cache_key(name.get_basename())
						if stem not in keys: keys.append(stem)
					for key: String in keys:
						if not names.has(key): names[key] = []
						names[key].append(path)
			name = directory.get_next()
		directory.list_dir_end()
	return {"error": "", "names": names, "files": count, "root": root}

static func cache_match(reference: String, index: Dictionary, image: bool = false, bundle: bool = false) -> Dictionary:
	var key := cache_key(reference.strip_edges())
	if key.length() < 12 or not (reference.begins_with("https://") or reference.begins_with("http://") or reference.begins_with("{verifycache}http")):
		return {"status": "missing", "path": "", "candidates": []}
	var candidates: Array[String] = []
	for match_key: String in [key, reference.strip_edges().trim_prefix("{verifycache}").sha256_text()]:
		for path: String in index.get("names", {}).get(match_key, []):
			var extension := path.get_extension().to_lower()
			var allowed := ["png", "jpg", "jpeg", "webp"] if image else (["json"] if bundle else ["obj"])
			if (extension.is_empty() or extension in allowed) and path not in candidates: candidates.append(path)
	candidates.sort()
	return {"status": "found" if candidates.size() == 1 else ("ambiguous" if candidates.size() > 1 else "missing"), "path": candidates[0] if candidates.size() == 1 else "", "candidates": candidates}

static func resolve_cache(entry: Dictionary, index: Dictionary) -> Dictionary:
	var planned := component_plan(entry)
	if not planned.error.is_empty(): return planned
	var dependency_urls_by_bundle: Dictionary = {}
	for component: Dictionary in planned.components:
		if str(component.get("kind", "CustomMesh")) != "CustomAssetbundle": continue
		var bundle_url := str(component.get("bundle_url", ""))
		if not dependency_urls_by_bundle.has(bundle_url): dependency_urls_by_bundle[bundle_url] = []
		var dependency_url := str(component.get("bundle_dependency_url", ""))
		if not dependency_url.is_empty() and dependency_url not in dependency_urls_by_bundle[bundle_url]: dependency_urls_by_bundle[bundle_url].append(dependency_url)
	var resolved_parts: Array[Dictionary] = []
	for component: Dictionary in planned.components:
		var references: Dictionary = component.references
		if str(component.get("kind", "CustomMesh")) == "CustomAssetbundle":
			var bundle_url := str(component.get("bundle_url", ""))
			component["bundle_dependency_urls"] = dependency_urls_by_bundle.get(bundle_url, []).duplicate()
			var marker := cache_match(bundle_url, index, false, true)
			var matching_paths: Array[String] = []
			var matching_parts_by_path: Dictionary = {}
			for marker_candidate: String in marker.get("candidates", []):
				var cached_candidate := bundle_cache_parts(marker_candidate, component)
				if str(cached_candidate.get("error", "")).is_empty():
					matching_paths.append(marker_candidate)
					matching_parts_by_path[marker_candidate] = cached_candidate.parts
			if matching_paths.size() != 1:
				if not marker.get("candidates", []).is_empty(): marker.status = "ambiguous" if matching_paths.size() > 1 else "invalid"
				resolved_parts.append({"component": component, "bundle": marker, "bundle_parts": [], "diffuse_required": false})
				continue
			marker.status = "found"
			marker.path = matching_paths[0]
			resolved_parts.append({"component": component, "bundle": marker, "bundle_parts": matching_parts_by_path[marker.path], "diffuse_required": false})
			continue
		var mesh := cache_match(str(references.get("MeshURL", "")), index)
		var diffuse := cache_match(str(references.get("DiffuseURL", "")), index, true)
		var normal := cache_match(str(references.get("NormalURL", "")), index, true)
		resolved_parts.append({"component": component, "mesh": mesh, "diffuse": diffuse, "normal": normal, "diffuse_required": not str(references.get("DiffuseURL", "")).is_empty(), "normal_required": not str(references.get("NormalURL", "")).is_empty()})
	if resolved_parts.is_empty(): return {"error": "No compatible OBJ mesh references were found in this object."}
	var first: Dictionary = resolved_parts[0]
	return {"error": "", "parts": resolved_parts, "mesh": first.get("mesh", {}), "bundle": first.get("bundle", {}), "diffuse": first.get("diffuse", {}), "diffuse_required": bool(first.get("diffuse_required", false))}

static func _safe_relative_model_path(value: String) -> bool:
	var path := value.replace("\\", "/")
	return not path.is_empty() and not path.begins_with("/") and not path.contains(":") and ".." not in path.split("/")

static func _path_is_within(root: String, path: String) -> bool:
	var normalized_root := root.simplify_path().replace("\\", "/").trim_suffix("/").to_lower()
	var normalized_path := path.simplify_path().replace("\\", "/").to_lower()
	return normalized_path == normalized_root or normalized_path.begins_with(normalized_root + "/")

static func bundle_cache_parts(marker_path: String, component: Dictionary) -> Dictionary:
	var marker_file := FileAccess.open(marker_path, FileAccess.READ)
	if marker_file == null: return {"error": "Cannot read converted bundle cache index.", "parts": []}
	var parser := JSON.new()
	var status := parser.parse(marker_file.get_as_text())
	marker_file.close()
	if status != OK or not parser.data is Dictionary: return {"error": "Converted bundle cache index is invalid.", "parts": []}
	var directory := str(parser.data.get("directory", ""))
	if not _safe_relative_model_path(directory): return {"error": "Converted bundle cache index contains an unsafe path.", "parts": []}
	var root := marker_path.get_base_dir().simplify_path()
	var bundle_root := root.path_join(directory).simplify_path()
	if not _path_is_within(root, bundle_root): return {"error": "Converted bundle is outside its cache folder.", "parts": []}
	var manifest_path := bundle_root.path_join("manifest.json")
	var manifest_file := FileAccess.open(manifest_path, FileAccess.READ)
	if manifest_file == null: return {"error": "Converted bundle manifest is missing.", "parts": []}
	var manifest_parser := JSON.new()
	status = manifest_parser.parse(manifest_file.get_as_text())
	manifest_file.close()
	if status != OK or not manifest_parser.data is Dictionary: return {"error": "Converted bundle manifest is invalid.", "parts": []}
	var source_parts: Variant = manifest_parser.data.get("parts", null)
	if not source_parts is Array or source_parts.is_empty() or source_parts.size() > 256: return {"error": "Converted bundle manifest has an invalid part count.", "parts": []}
	if not bool(manifest_parser.data.get("dependencies_complete", str(component.get("bundle_dependency_url", "")).is_empty())):
		return {"error": "Converted bundle is missing one or more declared material dependencies.", "parts": []}
	var expected_dependency_urls: Array = component.get("bundle_dependency_urls", [])
	if expected_dependency_urls.is_empty() and not str(component.get("bundle_dependency_url", "")).is_empty(): expected_dependency_urls.append(str(component.bundle_dependency_url))
	var loaded_dependency_urls: Variant = parser.data.get("loaded_dependency_urls", null)
	if loaded_dependency_urls is Array:
		for loaded_dependency: Variant in loaded_dependency_urls:
			if str(loaded_dependency) not in expected_dependency_urls:
				return {"error": "Converted bundle cache uses a different material dependency.", "parts": []}
		if not loaded_dependency_urls.is_empty() and expected_dependency_urls.is_empty():
			return {"error": "Converted bundle cache uses an undeclared material dependency.", "parts": []}
	elif not expected_dependency_urls.is_empty():
		return {"error": "Converted bundle cache does not identify its material dependencies.", "parts": []}
	var output: Array[Dictionary] = []
	for source_part: Variant in source_parts:
		if not source_part is Dictionary: return {"error": "Converted bundle manifest contains an invalid part.", "parts": []}
		var relative_mesh := str(source_part.get("mesh", "")).replace("\\", "/")
		if not _safe_relative_model_path(relative_mesh): return {"error": "Converted bundle manifest contains an unsafe mesh path.", "parts": []}
		var mesh_path := bundle_root.path_join(relative_mesh).simplify_path()
		if not _path_is_within(bundle_root, mesh_path) or not FileAccess.file_exists(mesh_path): return {"error": "Converted bundle mesh is missing or outside its folder.", "parts": []}
		var warnings: Variant = source_part.get("warnings", [])
		if warnings is Array:
			for warning: Variant in warnings:
				var warning_text := str(warning)
				if warning_text.begins_with("External CAB dependency ") or warning_text.begins_with("External CAB texture ") or warning_text.begins_with("Declared Unity AssetBundle dependency "):
					return {"error": "Converted bundle is missing one or more declared material dependencies.", "parts": []}
		var transforms: Array = component.get("transforms", []).duplicate(true)
		var internal_transforms: Variant = source_part.get("transforms", [])
		if internal_transforms is Array:
			var normalized_internal_transforms: Array = internal_transforms.duplicate(true)
			_neutralize_bundle_root_position(normalized_internal_transforms)
			transforms.append_array(normalized_internal_transforms)
		output.append({"path": mesh_path, "texture": "", "normal": "", "transforms": transforms, "name": str(source_part.get("name", component.get("name", "Model"))), "bundle_url": str(component.get("bundle_url", "")), "bundle_dependency_urls": expected_dependency_urls.duplicate(), "warnings": source_part.get("warnings", [])} )
	return {"error": "", "parts": output}

static func _neutralize_bundle_root_position(transforms: Array) -> void:
	# AssetBundle roots can retain their authoring-scene placement (often several
	# feet from zero). ForceOrg supplies the tabletop/component pose separately,
	# so keep the Unity root rotation/scale but remove its staging offset.
	for value: Variant in transforms:
		if not value is Dictionary or not value.get("rotation_quaternion", []) is Array: continue
		var position: Array = value.get("position", [])
		if position.size() < 3: continue
		value.position = [0.0, 0.0, 0.0]
		return

static func component_plan(entry: Dictionary) -> Dictionary:
	var specs: Array[Dictionary] = []
	if entry.get("components") is Array:
		specs.assign(entry.components)
	else:
		if int(entry.get("child_components", 0)) > 0: return {"error": "The composite parts were not scanned. Scan the ForceOrg catalog again before importing."}
		specs.append({"path": str(entry.get("path", "")), "kind": str(entry.get("kind", "")), "references": entry.get("references", {}).duplicate(true), "transforms": [], "base_candidate": false})
	var parts: Array[Dictionary] = []
	var preserve_pose := bool(entry.get("preserve_source_pose", false)) and entry.has("root_transform")
	for spec: Dictionary in specs:
		var kind := str(spec.get("kind", ""))
		if kind not in ["CustomMesh", "CustomAssetbundle"] or (not preserve_pose and bool(spec.get("base_candidate", false))): continue
		var references: Dictionary = spec.get("references", {})
		var mesh_url := str(references.get("MeshURL", "")).strip_edges().trim_prefix("{verifycache}")
		var bundle_url := str(references.get("AssetbundleURL", "")).strip_edges().trim_prefix("{verifycache}")
		var secondary_bundle_url := str(references.get("AssetbundleSecondaryURL", "")).strip_edges().trim_prefix("{verifycache}")
		if bundle_url.is_empty(): bundle_url = secondary_bundle_url
		if kind == "CustomMesh" and mesh_url.is_empty(): continue # Empty wrapper nodes only carry transforms.
		if kind == "CustomAssetbundle" and bundle_url.is_empty(): continue
		var bundle_dependency_url := secondary_bundle_url if secondary_bundle_url != bundle_url else ""
		var transforms: Array = spec.get("transforms", []).duplicate(true)
		if preserve_pose:
			var root: Dictionary = entry.root_transform.duplicate(true)
			root.position = [0.0, 0.0, 0.0]
			root.source_pose = true
			transforms.push_front(root)
		parts.append({"path": str(spec.get("path", "")), "name": str(spec.get("name", entry.get("name", "Model"))), "kind": kind, "bundle_url": bundle_url, "bundle_dependency_url": bundle_dependency_url, "references": references.duplicate(true), "transforms": transforms})
	if parts.is_empty(): return {"error": "No compatible OBJ mesh or Unity model bundle references were found in this object."}
	return {"error": "", "components": parts}

static func read_text(path: String) -> Dictionary:
	var started_usec := Time.get_ticks_usec()
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null: return {"error": "Cannot read local file: " + path}
	var byte_count := file.get_length()
	if byte_count > MAX_BYTES:
		file.close()
		return {"error": "File exceeds the 64 MiB import limit."}
	if 0 in file.get_buffer(mini(256, byte_count)):
		file.close()
		return {"error": "Binary file unsupported here. Select a JSON save or text OBJ mesh, not an AssetBundle."}
	file.seek(0)
	var text := file.get_as_text()
	file.close()
	_record_profile_metric("file_read", Time.get_ticks_usec() - started_usec, byte_count)
	return {"error": "", "text": text}

static func static_model_objects(script: String) -> Dictionary:
	# ForceOrg Model Saver stores JSON literals in objectJSONs. Read only that
	# literal table; never evaluate Lua, expressions, concatenation or functions.
	var marker := RegEx.new()
	marker.compile("(?m)^\\s*(?:local\\s+)?objectJSONs\\s*=\\s*\\{")
	var found := marker.search(script)
	if found == null: return {"error": "", "objects": [], "bytes": 0}
	var cursor := found.get_end()
	var records: Array[Dictionary] = []
	var bytes := 0
	while cursor < script.length():
		while cursor < script.length() and script[cursor] in [" ", "\t", "\r", "\n", ","]: cursor += 1
		if script.substr(cursor, 2) == "--":
			var newline := script.find("\n", cursor)
			if newline < 0: break
			cursor = newline + 1
			continue
		if cursor >= script.length(): break
		if script[cursor] == "}": return {"error": "", "objects": records, "bytes": bytes}
		if script[cursor] != "[": return {"error": "Nonliteral objectJSONs table requires TTS; no Lua was executed.", "objects": [], "bytes": 0}
		cursor += 1
		var equals := ""
		while cursor < script.length() and script[cursor] == "=" and equals.length() < 8:
			equals += "="
			cursor += 1
		if cursor >= script.length() or script[cursor] != "[": return {"error": "Unsupported objectJSONs string delimiter.", "objects": [], "bytes": 0}
		cursor += 1
		var end := script.find("]" + equals + "]", cursor)
		if end < 0: return {"error": "Unterminated objectJSONs JSON literal.", "objects": [], "bytes": 0}
		var text := script.substr(cursor, end - cursor)
		bytes += text.length()
		if bytes > MAX_BYTES or records.size() >= MAX_OBJECTS: return {"error": "Embedded model catalog exceeds import limits.", "objects": [], "bytes": 0}
		var parser := JSON.new()
		if parser.parse(text) != OK or not parser.data is Dictionary: return {"error": "Invalid embedded object JSON; table was skipped.", "objects": [], "bytes": 0}
		records.append(parser.data)
		cursor = end + equals.length() + 2
	return {"error": "Unterminated objectJSONs table.", "objects": [], "bytes": 0}

static func scan(path: String, include_source_objects: bool = false) -> Dictionary:
	if DirAccess.dir_exists_absolute(path): path = path.path_join("ForceOrg.json")
	var source := read_text(path)
	if not source.error.is_empty(): return source
	var source_hash: String = source.text.sha256_text()
	if not include_source_objects:
		var cached := _load_scan_cache(path, source_hash)
		if not cached.is_empty(): return cached
	var parser := JSON.new()
	if parser.parse(source.text) != OK: return {"error": "Invalid JSON at line %d: %s" % [parser.get_error_line(), parser.get_error_message()]}
	if not parser.data is Dictionary or not parser.data.get("ObjectStates") is Array: return {"error": "Expected a TTS save or saved object with an ObjectStates array."}
	var source_groups := _source_group_hints(parser.data.ObjectStates)
	var pending: Array = []
	for index in range(parser.data.ObjectStates.size()): pending.append({"object": parser.data.ObjectStates[index], "path": "ObjectStates/%d" % index})
	var entries: Array[Dictionary] = []
	var source_objects: Array[Dictionary] = []
	var count := 0
	var embedded_count := 0
	var embedded_bytes := 0
	var warnings: Array[String] = []
	while not pending.is_empty():
		var next: Dictionary = pending.pop_back()
		if not next.object is Dictionary: return {"error": "Invalid object at " + next.path}
		var obj: Dictionary = next.object
		var label: String = obj.get("Nickname", "") if obj.get("Nickname", "") is String else ""
		label = label.strip_edges()
		if label.is_empty(): label = next.get("inherited_name", str(obj.get("Name", "Unnamed object")))
		var credit: String = obj.get("Description", "") if obj.get("Description", "") is String else ""
		if credit.is_empty(): credit = next.get("inherited_credit", "")
		count += 1
		if count > MAX_OBJECTS: return {"error": "Save exceeds the 100,000 object limit."}
		if include_source_objects:
			var asset_kinds: Array[String] = []
			for asset_kind: String in ["CustomMesh", "CustomAssetbundle", "CustomImage", "CustomDeck"]:
				if obj.has(asset_kind): asset_kinds.append(asset_kind)
			source_objects.append({"path": next.path, "parent_path": str(next.get("parent_path", "")),
				"guid": str(obj.get("GUID", "")), "label": label,
				"source_label": obj.get("Nickname", "") if obj.get("Nickname", "") is String else "",
				"tts_type": str(obj.get("Name", "")), "asset_kinds": asset_kinds})
		if obj.get("LuaScript") is String and "objectJSONs" in obj.LuaScript:
			var embedded := static_model_objects(obj.LuaScript)
			if not embedded.error.is_empty(): warnings.append(next.path + ": " + embedded.error)
			embedded_bytes += int(embedded.bytes)
			if embedded_bytes > MAX_BYTES: return {"error": "Total embedded catalog exceeds the 64 MiB limit."}
			embedded_count += embedded.objects.size()
			for index in range(embedded.objects.size()): pending.append({"object": embedded.objects[index], "path": next.path + "/LuaScript/objectJSONs/%d" % index, "parent_path": next.path})
		for field in ["ContainedObjects", "AttachedObjects", "ChildObjects"]:
			if obj.has(field):
				if not obj[field] is Array: return {"error": "Invalid " + field + " at " + next.path}
				for index in range(obj[field].size()):
					var child := {"object": obj[field][index], "path": next.path + "/%s/%d" % [field, index], "parent_path": next.path}
					if field == "ChildObjects":
						child.inherited_name = label + " / component %d" % (index + 1)
						child.inherited_credit = credit
					pending.append(child)
		if obj.has("States"):
			if not obj.States is Dictionary: return {"error": "Invalid alternate states at " + next.path}
			for key: String in obj.States: pending.append({"object": obj.States[key], "path": next.path + "/States/" + key, "parent_path": next.path})
		for field in ["CustomMesh", "CustomAssetbundle"]:
			if not obj.has(field): continue
			if not obj[field] is Dictionary: return {"error": "Invalid " + field + " at " + next.path}
			var refs: Dictionary = {}
			for key in ["MeshURL", "DiffuseURL", "NormalURL", "ColliderURL", "AssetbundleURL", "AssetbundleSecondaryURL"]:
				if obj[field].has(key):
					if not obj[field][key] is String: return {"error": "Invalid asset reference at " + next.path}
					refs[key] = obj[field][key]
			var children: Array = obj.get("ChildObjects", []) if obj.get("ChildObjects", []) is Array else []
			var entry := {"id": (path + ":" + next.path + ":" + field).sha256_text(), "name": label, "path": next.path, "guid": str(obj.get("GUID", "")), "kind": field, "references": refs, "credit": credit, "child_components": children.size(), "tts_scale": _tts_scale(obj), "root_transform": _transform_record(obj.get("Transform", {}))}
			var path_parts := str(next.path).split("/")
			if path_parts.size() > 1 and source_groups.has(path_parts[1]): entry.source_group_hint = str(source_groups[path_parts[1]])
			if not children.is_empty(): entry.components = _component_specs(obj, next.path)
			var material_family := _static_material_family(obj)
			if not material_family.is_empty(): entry.material_family_hint = material_family
			entries.append(entry)
	entries.reverse()
	var scanned := {"error": "", "source": path, "fingerprint": source_hash, "entries": entries,
		"objects": count, "embedded_objects": embedded_count, "warnings": warnings,
		"source_objects": source_objects, "source_objects_included": include_source_objects}
	if not include_source_objects: _write_scan_cache(scanned)
	_apply_visual_index(entries, source_hash, warnings)
	return scanned

## Cache only the parsed static catalog. Regenerate source-gated visual links on every load.
static func _load_scan_cache(source_path: String, source_hash: String) -> Dictionary:
	if not FileAccess.file_exists(CATALOG_SCAN_CACHE_PATH): return {}
	var started_usec := Time.get_ticks_usec()
	var file := FileAccess.open(CATALOG_SCAN_CACHE_PATH, FileAccess.READ)
	if file == null: return {}
	var byte_count := file.get_length()
	if byte_count <= 0 or byte_count > CATALOG_SCAN_CACHE_MAX_BYTES:
		file.close()
		return {}
	var data: Variant = file.get_var(false)
	file.close()
	if not data is Dictionary: return {}
	if int(data.get("version", -1)) != CATALOG_SCAN_CACHE_VERSION \
		or str(data.get("source", "")) != source_path \
		or str(data.get("fingerprint", "")) != source_hash \
		or not data.get("entries", []) is Array \
		or not data.get("warnings", []) is Array \
		or int(data.get("objects", -1)) < 0 \
		or int(data.get("objects", -1)) > MAX_OBJECTS \
		or int(data.get("embedded_objects", -1)) < 0 \
		or int(data.get("embedded_objects", -1)) > MAX_OBJECTS \
		or data.entries.size() > MAX_OBJECTS * 2:
		return {}
	var entries: Array[Dictionary] = []
	for value: Variant in data.entries:
		if not value is Dictionary \
			or not value.get("id", "") is String \
			or not value.get("name", "") is String \
			or not value.get("path", "") is String \
			or not value.get("kind", "") is String \
			or not value.get("references", {}) is Dictionary:
			return {}
		entries.append(value)
	var warnings: Array[String] = []
	for value: Variant in data.warnings: warnings.append(str(value))
	var result := {"error": "", "source": source_path, "fingerprint": source_hash,
		"entries": entries, "objects": int(data.objects),
		"embedded_objects": int(data.embedded_objects), "warnings": warnings,
		"source_objects": [], "source_objects_included": false}
	_apply_visual_index(entries, source_hash, warnings)
	_record_profile_metric("catalog_scan_cache_read", Time.get_ticks_usec() - started_usec, byte_count)
	return result

static func _write_scan_cache(scanned: Dictionary) -> void:
	var started_usec := Time.get_ticks_usec()
	var directory := CATALOG_SCAN_CACHE_PATH.get_base_dir()
	var error := DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(directory))
	if error != OK: return
	var temporary := CATALOG_SCAN_CACHE_PATH + ".tmp"
	var file := FileAccess.open(temporary, FileAccess.WRITE)
	if file == null: return
	file.store_var({
		"version": CATALOG_SCAN_CACHE_VERSION,
		"source": scanned.get("source", ""),
		"fingerprint": scanned.get("fingerprint", ""),
		"objects": scanned.get("objects", 0),
		"embedded_objects": scanned.get("embedded_objects", 0),
		"warnings": scanned.get("warnings", []),
		"entries": scanned.get("entries", [])
	}, false)
	file.flush()
	var write_error := file.get_error()
	var byte_count := file.get_position()
	file.close()
	var temporary_absolute := ProjectSettings.globalize_path(temporary)
	var cache_absolute := ProjectSettings.globalize_path(CATALOG_SCAN_CACHE_PATH)
	if write_error != OK or byte_count > CATALOG_SCAN_CACHE_MAX_BYTES:
		DirAccess.remove_absolute(temporary_absolute)
		return
	if FileAccess.file_exists(CATALOG_SCAN_CACHE_PATH): DirAccess.remove_absolute(cache_absolute)
	error = DirAccess.rename_absolute(temporary_absolute, cache_absolute)
	if error != OK:
		DirAccess.remove_absolute(temporary_absolute)
		return
	_record_profile_metric("catalog_scan_cache_write", Time.get_ticks_usec() - started_usec, byte_count)

## A candidate filter, not paint certification. Original source groups stay intact.
static func visual_family_hint(entry: Dictionary) -> String:
	var declared := str(entry.get("source_group_hint", "")).strip_edges().to_lower()
	return declared if not declared.is_empty() else str(entry.get("material_family_hint", ""))

static func _static_material_family(obj: Dictionary) -> String:
	var pending: Array[Dictionary] = [{"object": obj, "depth": 0}]
	var materials: Dictionary = {}
	var textured := false
	var visited := 0
	while not pending.is_empty():
		var next: Dictionary = pending.pop_back()
		visited += 1
		if visited > 256 or int(next.depth) > 24: return ""
		var part: Dictionary = next.object
		# Bundle materials are not available until conversion. Do not guess them.
		if part.has("CustomAssetbundle"): return ""
		if not part.has("CustomMesh"): return ""
		if part.has("CustomMesh"):
			if not part.CustomMesh is Dictionary: return ""
			var mesh: Dictionary = part.CustomMesh
			var geometry := str(mesh.get("MeshURL", ""))
			if geometry.is_empty(): return ""
			var diffuse := str(mesh.get("DiffuseURL", ""))
			textured = textured or not diffuse.is_empty()
			var material := {"diffuse": diffuse, "normal": mesh.get("NormalURL", ""),
				"tint": part.get("ColorDiffuse", {"r": 1.0, "g": 1.0, "b": 1.0}),
				"shader": mesh.get("CustomShader", {}), "material_index": mesh.get("MaterialIndex", 0)}
			# Untextured bases/accessories must retain their exact geometry as well.
			if diffuse.is_empty(): material.geometry = geometry
			materials[JSON.stringify(material)] = true
		var children: Variant = part.get("ChildObjects", [])
		if not children is Array: return ""
		for child: Variant in children:
			if not child is Dictionary: return ""
			pending.append({"object": child, "depth": int(next.depth) + 1})
	if not textured: return ""
	var keys := materials.keys()
	keys.sort()
	return "materials-v1:" + JSON.stringify(keys).sha256_text()

## Optional local, generated label associations. No catalog or model is fetched.
static func _apply_visual_index(entries: Array[Dictionary], source_hash: String, warnings: Array[String]) -> void:
	for index_path: String in ["user://forceorg_visual_index.json", "res://.tools/forceorg-model-table/catalog_v2/runtime_visual_index.json"]:
		if not FileAccess.file_exists(index_path): continue
		var loaded := read_text(index_path)
		if not str(loaded.get("error", "")).is_empty():
			warnings.append("Local visual index could not be read: " + index_path)
			continue
		var parsed: Variant = JSON.parse_string(loaded.text)
		if not parsed is Dictionary or parsed.get("schema_version") != 1 or not parsed.get("sources") is Dictionary:
			warnings.append("Unsupported local visual index: " + index_path)
			continue
		var source_index: Variant = parsed.sources.get(source_hash, {})
		if not source_index is Dictionary or source_index.is_empty(): continue
		for entry: Dictionary in entries:
			var metadata: Variant = source_index.get(str(entry.get("path", "")), {})
			if not metadata is Dictionary or metadata.is_empty(): continue
			if metadata.get("label", "") != entry.get("name", "") or metadata.get("guid", "") != entry.get("guid", ""): continue
			if not metadata.get("definitions") is Array or not metadata.get("weapons") is Array: continue
			entry["visual_definitions"] = metadata.definitions.duplicate()
			entry["visual_weapons"] = metadata.weapons.duplicate()
			entry["visual_model_role"] = str(metadata.get("model_role", ""))
			if metadata.get("role_constraints", {}) is Dictionary: entry["visual_role_constraints"] = metadata.get("role_constraints", {}).duplicate(true)
			if metadata.get("weapon_aliases", {}) is Dictionary: entry["visual_weapon_aliases"] = metadata.get("weapon_aliases", {}).duplicate(true)
			if metadata.get("datasheets", []) is Array: entry["visual_datasheets"] = metadata.get("datasheets", []).duplicate(true)
			entry["visual_category"] = str(metadata.get("category", "miniature"))
			if str(entry.get("source_group_hint", "")).is_empty(): entry["source_group_hint"] = str(metadata.get("source_group", ""))
		return

## Recover the ForceOrg menu's chapter/group labels from static TTS Lua text.
## The script is parsed as a string; it is never executed.
static func _source_group_hints(roots: Array) -> Dictionary:
	var guid_to_group: Dictionary = {}
	var pattern := RegEx.new()
	if pattern.compile("([A-Za-z][A-Za-z0-9_]*)\\s*=\\s*getObjectFromGUID\\(\\\"([0-9a-fA-F]{6})\\\"\\)") != OK: return {}
	for root_value: Variant in roots:
		if not root_value is Dictionary: continue
		var script: Variant = root_value.get("LuaScript", "")
		if not script is String: continue
		for match: RegExMatch in pattern.search_all(script):
			var group := match.get_string(1)
			var camel_case := RegEx.new()
			if camel_case.compile("([a-z0-9])([A-Z])") == OK: group = camel_case.sub(group, "$1 $2", true)
			guid_to_group[match.get_string(2).to_lower()] = group.replace("_", " ").strip_edges()
	var result: Dictionary = {}
	for index: int in roots.size():
		var root: Variant = roots[index]
		if not root is Dictionary: continue
		var guid := str(root.get("GUID", "")).to_lower()
		if guid_to_group.has(guid): result[str(index)] = str(guid_to_group[guid])
	return result

static func _component_specs(root: Dictionary, root_path: String) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	_append_component_specs(root, root_path, [], result, true, 0)
	return result

static func _append_component_specs(obj: Dictionary, path: String, transforms: Array, result: Array[Dictionary], is_root: bool, depth: int) -> void:
	if depth > 24 or result.size() >= 256: return
	for kind: String in ["CustomMesh", "CustomAssetbundle"]:
		if not obj.get(kind) is Dictionary: continue
		var source_refs: Dictionary = obj[kind]
		var references: Dictionary = {}
		for key: String in ["MeshURL", "DiffuseURL", "NormalURL", "ColliderURL", "AssetbundleURL", "AssetbundleSecondaryURL"]:
			if source_refs.get(key) is String: references[key] = source_refs[key]
		var has_children: bool = obj.get("ChildObjects", []) is Array and not obj.get("ChildObjects", []).is_empty()
		var mesh_url := str(references.get("MeshURL", "")).trim_suffix("/")
		var collider_url := str(references.get("ColliderURL", "")).trim_suffix("/")
		var base_candidate := is_root and has_children and float(source_refs.get("TypeIndex", 0.0)) == 1.0 and mesh_url == collider_url and str(references.get("DiffuseURL", "")).is_empty()
		result.append({"path": path, "name": str(obj.get("Nickname", obj.get("Name", "Component"))), "kind": kind, "references": references, "transforms": transforms.duplicate(true), "base_candidate": base_candidate})
	for field: String in ["ChildObjects"]:
		if not obj.get(field) is Array: continue
		for index in range(obj[field].size()):
			var child: Variant = obj[field][index]
			if not child is Dictionary: continue
			var child_transforms: Array = transforms.duplicate(true)
			child_transforms.append(_transform_record(child.get("Transform", {})))
			_append_component_specs(child, path + "/%s/%d" % [field, index], child_transforms, result, false, depth + 1)

static func _transform_record(value: Variant) -> Dictionary:
	var source: Dictionary = value if value is Dictionary else {}
	var position := Vector3(float(source.get("posX", 0.0)), float(source.get("posY", 0.0)), float(source.get("posZ", 0.0)))
	var rotation := Vector3(float(source.get("rotX", 0.0)), float(source.get("rotY", 0.0)), float(source.get("rotZ", 0.0)))
	var scale := Vector3(float(source.get("scaleX", 1.0)), float(source.get("scaleY", 1.0)), float(source.get("scaleZ", 1.0)))
	for component: float in [position.x, position.y, position.z, rotation.x, rotation.y, rotation.z, scale.x, scale.y, scale.z]:
		if not is_finite(component) or absf(component) > 10000.0: return {"position": [0.0, 0.0, 0.0], "rotation": [0.0, 0.0, 0.0], "scale": [1.0, 1.0, 1.0]}
	return {"position": [position.x, position.y, position.z], "rotation": [rotation.x, rotation.y, rotation.z], "scale": [scale.x, scale.y, scale.z]}

static func component_transform(records: Array) -> Transform3D:
	var result := Transform3D.IDENTITY
	var preserve_pose := false
	for record: Variant in records:
		if not record is Dictionary: continue
		preserve_pose = preserve_pose or bool(record.get("source_pose", false))
		var position_values: Array = record.get("position", [0.0, 0.0, 0.0])
		var rotation_values: Array = record.get("rotation", [0.0, 0.0, 0.0])
		var quaternion_values: Array = record.get("rotation_quaternion", [])
		var scale_values: Array = record.get("scale", [1.0, 1.0, 1.0])
		if position_values.size() < 3 or (rotation_values.size() < 3 and quaternion_values.size() < 4) or scale_values.size() < 3: continue
		var position := Vector3(float(position_values[0]), float(position_values[1]), float(position_values[2]))
		var scale := Vector3(float(scale_values[0]), float(scale_values[1]), float(scale_values[2]))
		var rotation_basis := Basis.IDENTITY
		if quaternion_values.size() >= 4:
			var rotation := Quaternion(float(quaternion_values[0]), float(quaternion_values[1]), float(quaternion_values[2]), float(quaternion_values[3]))
			if not is_finite(rotation.x) or not is_finite(rotation.y) or not is_finite(rotation.z) or not is_finite(rotation.w) or rotation.length_squared() < 0.000001: continue
			rotation_basis = Basis(rotation.normalized())
		else:
			var euler := Vector3(deg_to_rad(float(rotation_values[0])), deg_to_rad(float(rotation_values[1])), deg_to_rad(float(rotation_values[2])))
			# TTS serializes these angles from Unity Transform data. Unity composes
			# Euler rotations in ZXY order, while Godot defaults to YXZ.
			rotation_basis = Basis.from_euler(euler, EULER_ORDER_ZXY)
		var scaled_basis := rotation_basis.scaled_local(scale) if preserve_pose else rotation_basis.scaled(scale)
		var local := Transform3D(scaled_basis, position)
		result = result * local
	return result

static func composite_from_files(parts: Array, settings: Dictionary = {}) -> Dictionary:
	var started_usec := Time.get_ticks_usec()
	if parts.is_empty(): return {"error": "No downloaded OBJ components are available for this model."}
	var rendered_parts: Array[Dictionary] = []
	var combined_bounds := AABB()
	var has_bounds := false
	var base_footprint := Vector2.ZERO
	var base_center := Vector2.ZERO
	var base_center_y := 0.0
	var base_size := 0.0
	var base_confidence := 0
	var base_heading := 0.0
	var base_detection := "ground-contact"
	var base_rim_coverage := false
	var preserve_pose := false
	var signatures: Array[String] = []
	for item: Variant in parts:
		if not item is Dictionary: return {"error": "Invalid component metadata."}
	var loaded_by_path: Dictionary = {}
	for item: Dictionary in parts:
		var path := str(item.get("path", ""))
		var texture := str(item.get("texture", ""))
		var normal := str(item.get("normal", ""))
		var identity := path + "\n" + texture + "\n" + normal
		var supplied_asset: Variant = item.get("asset", {})
		var part_asset: Dictionary = supplied_asset if supplied_asset is Dictionary else {}
		if part_asset.is_empty(): part_asset = loaded_by_path.get(identity, {})
		if part_asset.is_empty():
			part_asset = obj_mesh(path, texture, normal, true, bool(settings.get("defer_texture_upload", false)))
			if not str(part_asset.get("error", "")).is_empty(): return {"error": str(item.get("name", "Component")) + ": " + str(part_asset.error)}
			loaded_by_path[identity] = part_asset
		var transform_records: Array = item.get("transforms", [])
		if not transform_records.is_empty() and transform_records[0] is Dictionary:
			preserve_pose = preserve_pose or bool(transform_records[0].get("source_pose", false))
		var part_transform := component_transform(transform_records)
		if preserve_pose and absf(part_transform.basis.determinant()) < 0.000000001:
			return {"error": "A source component has a collapsed transform."}
		var world_bounds: AABB = part_transform * part_asset.bounds if preserve_pose else part_asset.bounds * part_transform
		combined_bounds = world_bounds if not has_bounds else combined_bounds.merge(world_bounds)
		has_bounds = true
		var footprint: Vector2 = part_asset.get("base_footprint", Vector2.ZERO)
		if maxf(footprint.x, footprint.y) > 0.0:
			var local_center: Vector2 = part_asset.get("base_center", Vector2(part_asset.bounds.get_center().x, part_asset.bounds.get_center().z))
			var center_3d := part_transform * Vector3(local_center.x, float(part_asset.get("base_center_y", part_asset.bounds.position.y)), local_center.y)
			var x_axis := Vector2(part_transform.basis.x.x, part_transform.basis.x.z) * footprint.x
			var z_axis := Vector2(part_transform.basis.z.x, part_transform.basis.z.z) * footprint.y
			var transformed_footprint := Vector2(absf(x_axis.x) + absf(z_axis.x), absf(x_axis.y) + absf(z_axis.y))
			var heading := 0.0
			if preserve_pose:
				# Singular values give the ellipse axes, independent of its yaw.
				var trace := x_axis.length_squared() + z_axis.length_squared()
				var determinant := x_axis.cross(z_axis)
				var major := sqrt(maxf(0.0, (trace + sqrt(maxf(0.0, trace * trace - 4.0 * determinant * determinant))) * 0.5))
				transformed_footprint = Vector2(major, absf(determinant) / major) if major > 0.00001 else Vector2.ZERO
				var plane_normal := part_transform.basis.z.cross(part_transform.basis.x).normalized()
				if plane_normal.y < 0.0: plane_normal = -plane_normal
				if plane_normal.y < 0.999 or not part_asset.get("base_rim_coverage", false):
					transformed_footprint = Vector2.ZERO
				var xx := x_axis.x * x_axis.x + z_axis.x * z_axis.x
				var zz := x_axis.y * x_axis.y + z_axis.y * z_axis.y
				var xz := x_axis.x * x_axis.y + z_axis.x * z_axis.y
				heading = atan2(2.0 * xz, xx - zz) * 0.5
			var confidence := 2 if part_asset.get("base_detection") == "ring" and bool(part_asset.get("base_rim_coverage", false)) else 1
			var candidate_size := maxf(transformed_footprint.x, transformed_footprint.y)
			# A body's estimated contact outline must not override a measured base
			# rim just because a weapon/stance makes the estimate larger.
			if candidate_size > 0.0 and (confidence > base_confidence or (confidence == base_confidence and candidate_size > base_size)):
				base_confidence = confidence
				base_size = maxf(transformed_footprint.x, transformed_footprint.y)
				base_footprint = transformed_footprint
				base_center = Vector2(center_3d.x, center_3d.z)
				base_center_y = center_3d.y
				base_heading = heading
				base_detection = str(part_asset.get("base_detection", "ground-contact"))
				base_rim_coverage = bool(part_asset.get("base_rim_coverage", false))
		var part_warnings: Array[String] = []
		for warning: Variant in item.get("warnings", []):
			var item_warning := str(warning).strip_edges()
			if not item_warning.is_empty() and item_warning not in part_warnings: part_warnings.append(item_warning)
		for warning: Variant in part_asset.get("warnings", []):
			var asset_warning := str(warning).strip_edges()
			if not asset_warning.is_empty() and asset_warning not in part_warnings: part_warnings.append(asset_warning)
		item["warnings"] = part_warnings
		rendered_parts.append({"asset": part_asset, "transform": part_transform, "name": str(item.get("name", "Component")), "warnings": part_warnings})
		signatures.append(str(part_asset.get("fingerprint", "")) + ":" + str(part_asset.get("texture_fingerprint", "")))
	if not has_bounds: return {"error": "The composite has no usable mesh bounds."}
	if base_size <= 0.00001:
		var contact_centers: Array[Vector2] = []
		var lowest_contact_y := INF
		for item: Dictionary in rendered_parts:
			var part_asset: Dictionary = item.asset
			var part_transform: Transform3D = item.transform
			var local_center: Vector2 = part_asset.get("base_center", Vector2(part_asset.bounds.get_center().x, part_asset.bounds.get_center().z))
			var local_y := float(part_asset.get("base_center_y", part_asset.bounds.position.y))
			var world_center := part_transform * Vector3(local_center.x, local_y, local_center.y)
			if world_center.y < lowest_contact_y - 0.03:
				lowest_contact_y = world_center.y
				contact_centers.clear()
			if world_center.y <= lowest_contact_y + 0.03: contact_centers.append(Vector2(world_center.x, world_center.z))
		if not contact_centers.is_empty():
			base_center = Vector2.ZERO
			for center: Vector2 in contact_centers: base_center += center
			base_center /= float(contact_centers.size())
			base_center_y = lowest_contact_y
		else:
			base_center = Vector2(combined_bounds.get_center().x, combined_bounds.get_center().z)
			base_center_y = combined_bounds.position.y
	var horizontal_size := maxf(combined_bounds.size.x, combined_bounds.size.z)
	if base_size > 0.05 and horizontal_size > 0.05 and combined_bounds.size.y / horizontal_size < 0.12:
		return {"error": "OBJ assembly contains only a flat base and no miniature body."}
	_record_profile_metric("composite_assembly", Time.get_ticks_usec() - started_usec)
	return {"error": "", "parts": rendered_parts, "bounds": combined_bounds, "base_footprint": base_footprint, "base_center": base_center, "base_center_y": base_center_y, "base_detection": base_detection, "base_rim_coverage": base_rim_coverage, "base_heading": base_heading, "source_pose": preserve_pose, "fingerprint": ",".join(signatures).sha256_text()}

static func _tts_scale(obj: Dictionary) -> float:
	if not obj.get("Transform") is Dictionary: return 1.0
	var transform: Dictionary = obj.Transform
	for key in ["scaleX", "scaleY", "scaleZ"]:
		var value: Variant = transform.get(key, 1.0)
		if not (value is float or value is int) or not is_finite(float(value)) or float(value) < 0.01 or float(value) > 20.0:
			return 1.0
	return float(transform.scaleX)

static func _percentile(values: Array[float], portion: float) -> float:
	var ordered: Array = values.duplicate()
	ordered.sort()
	if ordered.is_empty(): return 0.0
	var offset := clampf(portion, 0.0, 1.0) * float(ordered.size() - 1)
	var lower := int(floor(offset))
	var upper := int(ceil(offset))
	return lerpf(float(ordered[lower]), float(ordered[upper]), offset - float(lower))

static func _base_reference(vertices: Array[Vector3], bounds: AABB) -> Dictionary:
	if vertices.is_empty() or bounds.size.y <= 0.00001: return {}
	# TTS OBJ models often include their own round base. Use its bottom ring
	# instead of weapons, staves or backpacks to size and place the miniature.
	var band := maxf(0.015, minf(0.05, bounds.size.y * 0.025))
	var x_values: Array[float] = []
	var z_values: Array[float] = []
	for vertex: Vector3 in vertices:
		if vertex.y > bounds.position.y + band: continue
		x_values.append(vertex.x)
		z_values.append(vertex.z)
	if x_values.is_empty():
		return {"size": Vector2.ZERO, "center": Vector2(bounds.get_center().x, bounds.get_center().z), "center_y": bounds.position.y, "detection": "ground-contact"}
	# Vertex density is not uniform in converted OBJ files: triangulated top
	# surfaces can outnumber vertices along the base edge and pull the median
	# away from the physical footprint center. Use the footprint extents for its
	# origin; size remains percentile-trimmed below to resist isolated outliers.
	var center := Vector2(
		(_percentile(x_values, 0.0) + _percentile(x_values, 1.0)) * 0.5,
		(_percentile(z_values, 0.0) + _percentile(z_values, 1.0)) * 0.5
	)
	if x_values.size() < 12:
		return {"size": Vector2.ZERO, "center": center, "center_y": bounds.position.y, "detection": "ground-contact"}
	var x_size := _percentile(x_values, 0.99) - _percentile(x_values, 0.01)
	var z_size := _percentile(z_values, 0.99) - _percentile(z_values, 0.01)
	if minf(x_size, z_size) < 0.08:
		return {"size": Vector2.ZERO, "center": center, "center_y": bounds.position.y, "detection": "ground-contact"}
	var half_size := Vector2(x_size, z_size) * 0.5
	var normalized_radii: Array[float] = []
	var rim_sectors := 0
	for index in range(x_values.size()):
		var dx := (x_values[index] - center.x) / half_size.x
		var dz := (z_values[index] - center.y) / half_size.y
		var radius := sqrt(dx * dx + dz * dz)
		normalized_radii.append(radius)
		if radius >= 0.85 and radius <= 1.15:
			var sector := floori(fposmod(atan2(dz, dx), TAU) * 12.0 / TAU) % 12
			rim_sectors |= 1 << sector
	var inner_radius := _percentile(normalized_radii, 0.25)
	var outer_radius := _percentile(normalized_radii, 0.75)
	var aspect_ratio := maxf(x_size, z_size) / minf(x_size, z_size)
	var ring_contour := inner_radius >= 0.70 and outer_radius <= 1.35 and outer_radius / maxf(inner_radius, 0.00001) <= 1.65
	var horizontal_size := maxf(bounds.size.x, bounds.size.z)
	var footprint_ratio := maxf(x_size, z_size) / maxf(horizontal_size, 0.00001)
	# Reject small circular details (for example a wheel or scenic socket) as
	# miniature bases. They would otherwise scale an entire vehicle many times
	# larger than its hull to match the datasheet base.
	if aspect_ratio > 3.2 or footprint_ratio < 0.15:
		return {"size": Vector2.ZERO, "center": center, "center_y": bounds.position.y, "detection": "ground-contact"}
	if ring_contour and rim_sectors == 0xfff:
		return {"size": Vector2(x_size, z_size), "center": center, "center_y": bounds.position.y, "detection": "ring", "rim_coverage": rim_sectors == 0xfff}
	# A scenic oval base may have an irregular or solid top surface rather than
	# an identifiable rim. Retain it as an estimate so the table does not place
	# a second proxy underneath it. Sparse foot contacts still use a profile proxy.
	if x_values.size() >= 20 and minf(x_size, z_size) >= 0.20 and footprint_ratio >= 0.25:
		return {"size": Vector2(x_size, z_size), "center": center, "center_y": bounds.position.y, "detection": "estimated-base"}
	return {"size": Vector2.ZERO, "center": center, "center_y": bounds.position.y, "detection": "ground-contact"}

static func table_scale(bounds: AABB, settings: Dictionary, base_footprint: Vector2 = Vector2.ZERO) -> float:
	var user := float(settings.get("scale", 1.0))
	if not is_finite(user) or user <= 0.0: user = 1.0
	var radius := float(settings.get("base_radius_inches", 0.0))
	var footprint := maxf(bounds.size.x, bounds.size.z)
	var model_base_diameter := maxf(base_footprint.x, base_footprint.y)
	if radius > 0.01 and footprint > 0.00001:
		var base_diameter := radius * 2.0
		if model_base_diameter > 0.00001:
			return base_diameter / model_base_diameter * user
		# If the OBJ contains only the body, use the expected infantry height
		# instead of shrinking it to fit a wide accessory.
		if base_diameter <= INFANTRY_BASE_DIAMETER_LIMIT_IN and bounds.size.y > 0.00001:
			return (base_diameter * INFANTRY_HEIGHT_TO_BASE_RATIO) / bounds.size.y * user
		return base_diameter / footprint * user
	if model_base_diameter > 0.00001:
		return (DEFAULT_INFANTRY_BASE_MM / MM_PER_INCH) / model_base_diameter * user
	var tts := float(settings.get("tts_scale", 1.0))
	if not is_finite(tts) or tts <= 0.0: tts = 1.0
	if bounds.size.y > 0.05 and bounds.size.y < 8.0 and footprint > 0.05 and footprint < 8.0:
		return tts * user
	if footprint > 0.00001:
		return (DEFAULT_INFANTRY_BASE_MM / MM_PER_INCH) / footprint * user
	return user

static func _visual_base_axes(settings: Dictionary) -> Vector2:
	var diameter := float(settings.get("base_radius_inches", 0.0)) * 2.0
	return settings.get("visual_base_axes_inches", Vector2(diameter, diameter))

static func has_reviewed_hull_mount(asset: Dictionary, settings: Dictionary) -> bool:
	if not asset.get("source_pose", false) or not settings.get("visual_hull_proxy", false): return false
	var mount: Variant = settings.get("reviewed_hull_mount")
	if not mount is Dictionary: return false
	var scale: Variant = mount.get("scale")
	var offset: Variant = mount.get("contact_offset")
	return (scale is float or scale is int) and is_finite(float(scale)) and float(scale) >= 0.01 and float(scale) <= 20.0 and offset is Vector3 and offset.is_finite() and offset.abs().length() <= 35.0

static func visual_error_for_base(asset: Dictionary, settings: Dictionary) -> String:
	var radius := float(settings.get("base_radius_inches", 0.0))
	if bool(settings.get("require_full_miniature", false)):
		var complete_bounds: AABB = asset.get("bounds", AABB())
		var completeness_issue := _complete_miniature_height_error(complete_bounds.size.y, settings)
		if not completeness_issue.is_empty(): return completeness_issue
	if radius <= 0.01: return ""
	var footprint: Vector2 = asset.get("base_footprint", Vector2.ZERO)
	if bool(asset.get("source_pose", false)):
		if settings.get("visual_hull_proxy", false):
			return "" if has_reviewed_hull_mount(asset, settings) else "Review the hull mount in Adjust before linking this model."
		if asset.get("base_detection") != "ring" or not bool(asset.get("base_rim_coverage", false)) or minf(footprint.x, footprint.y) <= 0.00001:
			return "The source pose needs a reviewed base mount. Use the built-in miniature or try another sculpt."
		var target := _visual_base_axes(settings)
		var fitted_minor := minf(footprint.x, footprint.y) / maxf(footprint.x, footprint.y) * target.x
		if absf(target.y - fitted_minor) * MM_PER_INCH > 0.5:
			return "The source rim does not fit both target base axes within 0.5 mm."
		# A valid ring can still belong to a loose assembly whose other pieces are
		# scattered across the table. Reject extreme infantry outliers so the
		# automatic importer can try another variant before saving a broken pose.
		var target_diameter := maxf(target.x, target.y)
		var assembly_bounds: AABB = asset.get("bounds", AABB())
		var assembly_span := maxf(assembly_bounds.size.x, assembly_bounds.size.z)
		if target_diameter <= 1.8 and assembly_span > target_diameter * 4.0:
			return "The model parts extend too far from the detected infantry base; try another variant or review its pose."
	if maxf(footprint.x, footprint.y) > 0.00001: return ""
	var diameter := radius * 2.0
	if diameter > INFANTRY_BASE_DIAMETER_LIMIT_IN: return ""
	var bounds: AABB = asset.get("bounds", AABB())
	if bounds.size.y <= 0.00001: return ""
	var normalized_footprint := maxf(bounds.size.x, bounds.size.z) * INFANTRY_HEIGHT_TO_BASE_RATIO / bounds.size.y
	if normalized_footprint > 3.5:
		return "Model bounds are too wide for an infantry-base visual and would sit outside its base. Choose another OBJ variant or adjust it manually."
	return ""

static func _complete_miniature_height_error(height_inches: float, settings: Dictionary) -> String:
	if not bool(settings.get("require_full_miniature", false)): return ""
	var target_axes := _visual_base_axes(settings)
	var target_minor := minf(target_axes.x, target_axes.y)
	# This is a conservative presentation check for infantry profiles. A mesh
	# whose full vertical span is shorter than roughly two thirds of its base
	# may be a detached head/part rather than a complete miniature. It is a
	# fallback gate, not a sculpt-height rule or a replacement for preview.
	if target_minor > 0.01 and height_inches < target_minor * COMPLETE_INFANTRY_MIN_HEIGHT_TO_BASE_RATIO:
		return "This visual is too short for a complete infantry miniature and may be a detached head or part. Choose a complete assembly or use the built-in model."
	return ""

static func _index(value: String, size: int) -> int:
	if not value.is_valid_int(): return -1
	var index := int(value)
	if index == 0: return -1
	return index - 1 if index > 0 and index <= size else (size + index if index < 0 and -index <= size else -1)

static func _safe_model_sidecar(model_path: String, reference: String) -> String:
	var normalized := reference.strip_edges().replace("\\", "/")
	if normalized.is_empty() or normalized.begins_with("/") or ":" in normalized: return ""
	for segment: String in normalized.split("/"):
		if segment == "..": return ""
	return model_path.get_base_dir().path_join(normalized)

static func _load_image_texture(path: String, purpose: String, defer_upload: bool = false) -> Dictionary:
	if path.is_empty(): return {"error": "", "texture": null, "image": null, "fingerprint": ""}
	if not FileAccess.file_exists(path): return {"error": "Cannot find the selected local %s image." % purpose, "texture": null, "fingerprint": ""}
	var read_started_usec := Time.get_ticks_usec()
	var texture_file := FileAccess.open(path, FileAccess.READ)
	if texture_file == null: return {"error": "Cannot read %s image or it exceeds 64 MiB." % purpose, "texture": null, "image": null, "fingerprint": ""}
	var byte_count := texture_file.get_length()
	if byte_count > MAX_BYTES:
		texture_file.close()
		return {"error": "Cannot read %s image or it exceeds 64 MiB." % purpose, "texture": null, "image": null, "fingerprint": ""}
	var fingerprint := FileAccess.get_sha256(path)
	var cached: Variant = _image_texture_cache.get(fingerprint)
	if cached is WeakRef:
		var cached_texture: Variant = cached.get_ref()
		if cached_texture is Texture2D:
			texture_file.close()
			_record_profile_metric("texture_file_read", Time.get_ticks_usec() - read_started_usec, byte_count)
			return {"error": "", "texture": cached_texture, "image": null, "fingerprint": fingerprint}
	var data := texture_file.get_buffer(texture_file.get_length())
	texture_file.close()
	_record_profile_metric("texture_file_read", Time.get_ticks_usec() - read_started_usec, byte_count)
	var image := Image.new()
	var error := ERR_FILE_UNRECOGNIZED
	var decode_started_usec := Time.get_ticks_usec()
	if data.size() >= 8 and data.slice(0, 8) == PackedByteArray([137, 80, 78, 71, 13, 10, 26, 10]): error = image.load_png_from_buffer(data)
	elif data.size() >= 3 and data[0] == 255 and data[1] == 216 and data[2] == 255: error = image.load_jpg_from_buffer(data)
	elif data.size() >= 12 and data.slice(0, 4).get_string_from_ascii() == "RIFF" and data.slice(8, 12).get_string_from_ascii() == "WEBP": error = image.load_webp_from_buffer(data)
	_record_profile_metric("texture_decode", Time.get_ticks_usec() - decode_started_usec)
	if error != OK: return {"error": "Cannot decode %s image as PNG, JPEG or WebP." % purpose, "texture": null, "image": null, "fingerprint": ""}
	if image.get_width() > 8192 or image.get_height() > 8192: return {"error": "%s image exceeds 8192 pixels per side." % purpose.capitalize(), "texture": null, "image": null, "fingerprint": ""}
	if defer_upload: return {"error": "", "texture": null, "image": image, "fingerprint": fingerprint}
	var texture := ImageTexture.create_from_image(image)
	_cache_image_texture(fingerprint, texture)
	return {"error": "", "texture": texture, "image": null, "fingerprint": fingerprint}

static func _cache_image_texture(fingerprint: String, texture: Texture2D) -> void:
	if fingerprint.is_empty() or texture == null: return
	if _image_texture_cache.size() >= 512:
		for key: Variant in _image_texture_cache.keys():
			var weak_texture: Variant = _image_texture_cache[key]
			if not weak_texture is WeakRef or weak_texture.get_ref() == null: _image_texture_cache.erase(key)
			if _image_texture_cache.size() < 384: break
	if _image_texture_cache.size() >= 512: _image_texture_cache.erase(_image_texture_cache.keys()[0])
	_image_texture_cache[fingerprint] = weakref(texture)

static func finalize_pending_textures(asset: Dictionary) -> Dictionary:
	if asset.is_empty() or not str(asset.get("error", "")).is_empty(): return asset
	if asset.get("parts") is Array:
		var finalized_parts: Array[Dictionary] = []
		for item: Variant in asset.parts:
			if not item is Dictionary: continue
			var finalized_item: Dictionary = item.duplicate()
			if finalized_item.get("asset") is Dictionary:
				finalized_item.asset = finalize_pending_textures(finalized_item.asset)
				if not str(finalized_item.asset.get("error", "")).is_empty(): return finalized_item.asset
			finalized_parts.append(finalized_item)
		asset.parts = finalized_parts
		return asset
	var pending: Variant = asset.get("pending_textures", [])
	if not pending is Array: return asset
	for item: Variant in pending:
		if not item is Dictionary or not item.get("material") is Material or not item.get("image") is Image: continue
		var fingerprint := str(item.get("fingerprint", ""))
		var texture: Texture2D
		var cached: Variant = _image_texture_cache.get(fingerprint)
		if cached is WeakRef and cached.get_ref() is Texture2D:
			texture = cached.get_ref()
		else:
			var upload_started_usec := Time.get_ticks_usec()
			texture = ImageTexture.create_from_image(item.image)
			_record_profile_metric("texture_upload", Time.get_ticks_usec() - upload_started_usec)
			_cache_image_texture(fingerprint, texture)
		item.material.set(str(item.get("property", "albedo_texture")), texture)
	asset.erase("pending_textures")
	return asset

static func _load_obj_materials(path: String, obj_text: String, texture_override: String, normal_override: String = "") -> Dictionary:
	var materials: Dictionary = {"": {"color": Color("d6d2c6"), "diffuse": "", "normal": "", "roughness": 0.85}}
	var libraries: Array[String] = []
	var warnings: Array[String] = []
	var inputs := {}
	for line: String in obj_text.split("\n"):
		var clean := line.split("#", true, 1)[0].strip_edges()
		if not clean.begins_with("mtllib "): continue
		var name := clean.trim_prefix("mtllib ").strip_edges()
		if not name.is_empty() and name not in libraries: libraries.append(name)
	var implicit_library := libraries.is_empty()
	if implicit_library:
		libraries.append(path.get_file().get_basename() + ".mtl")
	for library: String in libraries:
		var library_path := _safe_model_sidecar(path, library)
		if library_path.is_empty(): return {"error": "OBJ material library contains an unsafe path."}
		inputs[library_path] = _package_file_hash(library_path)
		if implicit_library and not FileAccess.file_exists(library_path): continue
		var material_source := read_text(library_path)
		if not material_source.error.is_empty():
			if not FileAccess.file_exists(library_path):
				var missing_note := "OBJ material library %s is missing; using the declared texture or default material." % library
				if missing_note not in warnings: warnings.append(missing_note)
				continue
			return {"error": "Cannot read OBJ material library %s: %s" % [library, material_source.error]}
		var current_name := ""
		for line: String in material_source.text.split("\n"):
			var words := line.split("#", true, 1)[0].replace("\t", " ").strip_edges().split(" ", false)
			if words.is_empty(): continue
			if words[0] == "newmtl":
				current_name = " ".join(words.slice(1)).strip_edges()
				if current_name.is_empty(): return {"error": "OBJ material library contains an unnamed material."}
				materials[current_name] = {"color": Color.WHITE, "diffuse": "", "normal": "", "roughness": 0.85}
			elif not materials.has(current_name): continue
			elif words[0] == "Kd" and words.size() >= 4:
				var rgb: Array[float] = []
				for index in range(1, 4):
					if not words[index].is_valid_float() or not is_finite(float(words[index])): return {"error": "OBJ material has an invalid diffuse color."}
					rgb.append(clampf(float(words[index]), 0.0, 1.0))
				materials[current_name].color = Color(rgb[0], rgb[1], rgb[2])
			elif words[0] == "Ns" and words.size() >= 2 and words[1].is_valid_float():
				materials[current_name].roughness = clampf(1.0 - sqrt(clampf(float(words[1]), 0.0, 1000.0) / 1000.0), 0.04, 1.0)
			elif words[0] in ["map_Kd", "map_kd"] and words.size() >= 2:
				materials[current_name].diffuse = _safe_model_sidecar(library_path, words[-1])
			elif words[0] in ["map_Bump", "map_bump", "bump", "norm", "map_Kn", "map_kn"] and words.size() >= 2:
				materials[current_name].normal = _safe_model_sidecar(library_path, words[-1])
			if (words[0] in ["map_Kd", "map_kd", "map_Bump", "map_bump", "bump", "norm", "map_Kn", "map_kn"]):
				var sidecar := str(materials[current_name].get("diffuse", "")) if words[0] in ["map_Kd", "map_kd"] else str(materials[current_name].get("normal", ""))
				if sidecar.is_empty(): return {"error": "OBJ material contains an unsafe texture path."}
	for material_name: String in materials:
		if not texture_override.is_empty(): materials[material_name].diffuse = texture_override
		if not normal_override.is_empty(): materials[material_name].normal = normal_override
	return {"error": "", "materials": materials, "warnings": warnings, "inputs": inputs}

static func obj_mesh(path: String, texture_path: String = "", normal_path: String = "", allow_flat_component: bool = false, defer_texture_upload: bool = false) -> Dictionary:
	var source := read_text(path)
	if not source.error.is_empty(): return source
	var parse_started_usec := Time.get_ticks_usec()
	var vertices: Array[Vector3] = []
	var vertex_colors: Array[Color] = []
	var uvs: Array[Vector2] = []
	var normals: Array[Vector3] = []
	var faces_by_material: Dictionary = {"": []}
	var active_material := ""
	var has_vertex_colors := false
	var triangle_vertices := 0
	for line: String in source.text.split("\n"):
		var words := line.split("#", true, 1)[0].replace("\t", " ").strip_edges().split(" ", false)
		if words.is_empty(): continue
		if words[0] in ["v", "vn", "vt"]:
			var needed := 2 if words[0] == "vt" else 3
			if words.size() < needed + 1: return {"error": "Incomplete OBJ vertex, normal or UV."}
			var value_count := 6 if words[0] == "v" and words.size() >= 7 else needed
			for index in range(1, value_count + 1):
				if not words[index].is_valid_float() or not is_finite(float(words[index])) or absf(float(words[index])) > 1000000: return {"error": "Invalid or excessive OBJ coordinate."}
			if words[0] == "v":
				vertices.append(Vector3(float(words[1]), float(words[2]), float(words[3])))
				var color := Color.WHITE
				if value_count == 6:
					color = Color(float(words[4]), float(words[5]), float(words[6]))
					has_vertex_colors = true
				vertex_colors.append(color)
			elif words[0] == "vn": normals.append(Vector3(float(words[1]), float(words[2]), float(words[3])))
			else: uvs.append(Vector2(float(words[1]), 1.0 - float(words[2])))
			if vertices.size() + normals.size() + uvs.size() > MAX_OBJ_ATTRIBUTES: return {"error": "OBJ source exceeds the 1,000,000 attribute limit."}
		elif words[0] == "usemtl":
			active_material = " ".join(words.slice(1)).strip_edges()
			if not faces_by_material.has(active_material): faces_by_material[active_material] = []
		elif words[0] == "f":
			if words.size() < 4 or words.size() > MAX_OBJ_TRIANGLE_VERTICES / 3 + 3: return {"error": "OBJ face exceeds the supported triangle-vertex limit."}
			var face: Array = []
			for token: String in words.slice(1):
				var parts := token.split("/", true)
				if parts.size() > 3: return {"error": "Invalid OBJ face."}
				var v := _index(parts[0], vertices.size())
				var uv := _index(parts[1], uvs.size()) if parts.size() > 1 and not parts[1].is_empty() else -1
				var n := _index(parts[2], normals.size()) if parts.size() > 2 and not parts[2].is_empty() else -1
				if v < 0 or (parts.size() > 1 and not parts[1].is_empty() and uv < 0) or (parts.size() > 2 and not parts[2].is_empty() and n < 0): return {"error": "OBJ face references a missing vertex, UV or normal."}
				face.append([v, uv, n])
			triangle_vertices += (face.size() - 2) * 3
			if triangle_vertices > MAX_OBJ_TRIANGLE_VERTICES: return {"error": "OBJ exceeds the 1,000,000 triangle-vertex limit."}
			faces_by_material[active_material].append(face)
	var has_faces := false
	for material_faces: Array in faces_by_material.values():
		if not material_faces.is_empty(): has_faces = true
	if not has_faces: return {"error": "No OBJ mesh faces found."}
	_record_profile_metric("obj_parse", Time.get_ticks_usec() - parse_started_usec)
	var material_result := _load_obj_materials(path, source.text, texture_path, normal_path)
	if not str(material_result.get("error", "")).is_empty(): return material_result
	var mesh_build_started_usec := Time.get_ticks_usec()
	var mesh := ArrayMesh.new()
	var texture_fingerprints: Array[String] = []
	var inputs: Dictionary = material_result.inputs
	inputs[path] = source.text.sha256_text()
	var pending_textures: Array[Dictionary] = []
	for material_name: String in faces_by_material:
		var faces: Array = faces_by_material[material_name]
		if faces.is_empty(): continue
		var spec: Dictionary = material_result.materials.get(material_name, material_result.materials[""])
		var material := StandardMaterial3D.new()
		material.albedo_color = spec.get("color", Color("d6d2c6"))
		material.roughness = float(spec.get("roughness", 0.85))
		var diffuse := _load_image_texture(str(spec.get("diffuse", "")), "diffuse", defer_texture_upload)
		if not str(diffuse.get("error", "")).is_empty(): return diffuse
		if diffuse.get("texture") is Texture2D: material.albedo_texture = diffuse.texture
		elif diffuse.get("image") is Image: pending_textures.append({"material": material, "property": "albedo_texture", "image": diffuse.image, "fingerprint": str(diffuse.get("fingerprint", ""))})
		if not str(diffuse.get("fingerprint", "")).is_empty():
			texture_fingerprints.append(str(diffuse.fingerprint))
			inputs[spec.diffuse] = diffuse.fingerprint
		var normal := _load_image_texture(str(spec.get("normal", "")), "normal map", defer_texture_upload)
		if not str(normal.get("error", "")).is_empty(): return normal
		if normal.get("texture") is Texture2D:
			material.normal_enabled = true
			material.normal_texture = normal.texture
			texture_fingerprints.append(str(normal.fingerprint))
		elif normal.get("image") is Image:
			material.normal_enabled = true
			pending_textures.append({"material": material, "property": "normal_texture", "image": normal.image, "fingerprint": str(normal.get("fingerprint", ""))})
			texture_fingerprints.append(str(normal.fingerprint))
		var authored_normals := true
		for face: Array in faces:
			for corner: Array in face:
				if corner[2] < 0 or not normals[corner[2]].is_finite() or normals[corner[2]].is_zero_approx():
					authored_normals = false
					break
			if not authored_normals: break
		if not str(normal.get("fingerprint", "")).is_empty(): inputs[spec.normal] = normal.fingerprint
		var surface := SurfaceTool.new()
		surface.begin(Mesh.PRIMITIVE_TRIANGLES)
		for face: Array in faces:
			for index in range(1, face.size() - 1):
				# OBJ is counterclockwise; Godot front faces are clockwise.
				for corner: Array in [face[0], face[index + 1], face[index]]:
					if authored_normals: surface.set_normal(normals[corner[2]].normalized())
					surface.set_uv(uvs[corner[1]] if corner[1] >= 0 else Vector2.ZERO)
					if has_vertex_colors: surface.set_color(vertex_colors[corner[0]])
					surface.add_vertex(vertices[corner[0]])
		if not authored_normals: surface.generate_normals()
		if material.normal_enabled: surface.generate_tangents()
		surface.set_material(material)
		surface.commit(mesh)
	var bounds := mesh.get_aabb()
	if bounds.size.y < 0.00001 and not allow_flat_component: return {"error": "Model has no usable vertical height."}
	var base_reference := _base_reference(vertices, bounds)
	if not texture_path.is_empty() and texture_fingerprints.is_empty(): texture_fingerprints.append(FileAccess.get_sha256(texture_path))
	_record_profile_metric("mesh_build", Time.get_ticks_usec() - mesh_build_started_usec)
	return {"error": "", "mesh": mesh, "bounds": bounds, "base_footprint": base_reference.get("size", Vector2.ZERO), "base_center": base_reference.get("center", Vector2(bounds.get_center().x, bounds.get_center().z)), "base_center_y": float(base_reference.get("center_y", bounds.position.y)), "base_detection": str(base_reference.get("detection", "ground-contact")), "base_rim_coverage": base_reference.get("rim_coverage", false), "fingerprint": source.text.sha256_text(), "texture_fingerprint": ",".join(texture_fingerprints).sha256_text() if not texture_fingerprints.is_empty() else "", "warnings": material_result.get("warnings", []), "pending_textures": pending_textures, "inputs": inputs}

static func load_mapping_asset_for_worker(mapping: Dictionary) -> Dictionary:
	if mapping.get("parts") is Array and not mapping.parts.is_empty():
		return composite_from_files(mapping.parts, {"defer_texture_upload": true})
	return obj_mesh(str(mapping.get("path", "")), str(mapping.get("texture", "")), str(mapping.get("normal", "")), false, true)

static func visual(asset: Dictionary, settings: Dictionary) -> Node3D:
	var root := Node3D.new()
	var bounds: AABB = asset.bounds
	var fit_settings := settings
	if bool(asset.get("source_pose", false)):
		fit_settings = settings.duplicate()
		fit_settings.scale = 1.0
		fit_settings.tts_scale = 1.0
	var factor := table_scale(bounds, fit_settings, asset.get("base_footprint", Vector2.ZERO))
	if bool(asset.get("source_pose", false)) and fit_settings.has("visual_base_axes_inches"):
		var source_axes: Vector2 = asset.get("base_footprint", Vector2.ZERO)
		if maxf(source_axes.x, source_axes.y) > 0.00001:
			factor = _visual_base_axes(fit_settings).x / maxf(source_axes.x, source_axes.y)
	var base_center: Vector2 = asset.get("base_center", Vector2(bounds.get_center().x, bounds.get_center().z))
	var origin_y := float(asset.get("base_center_y", bounds.position.y))
	var base_footprint: Vector2 = asset.get("base_footprint", Vector2.ZERO)
	var alignment := str(asset.get("base_detection", "ground-contact"))
	if not bool(asset.get("source_pose", false)) and bool(settings.get("visual_hull_proxy", false)):
		# "Use model" has no physical base diameter. Flat vehicle undersides can
		# resemble scenic bases to the contact detector, so preserve the source
		# tabletop scale and leave the rules interaction proxy independent.
		var user_scale := float(settings.get("scale", 1.0))
		if not is_finite(user_scale) or user_scale <= 0.0: user_scale = 1.0
		var source_scale := float(settings.get("tts_scale", 1.0))
		if not is_finite(source_scale) or source_scale <= 0.0: source_scale = 1.0
		factor = source_scale * user_scale
		base_footprint = Vector2.ZERO
		alignment = "source-model-size"
	elif has_reviewed_hull_mount(asset, settings):
		var mount: Dictionary = settings.reviewed_hull_mount
		var offset: Vector3 = mount.contact_offset
		factor = float(mount.scale)
		base_center += Vector2(offset.x, offset.z)
		origin_y += offset.y
		base_footprint = Vector2.ZERO
		alignment = "reviewed-hull-mount"
	root.set_meta("asset_base_footprint_inches", base_footprint * factor)
	root.set_meta("base_alignment_method", alignment)
	root.set_meta("uniform_scale", factor)
	root.set_meta("base_center_offset_inches", Vector2.ZERO)
	var geometry := Node3D.new()
	geometry.scale = Vector3.ONE * factor
	geometry.position = -Vector3(base_center.x, origin_y, base_center.y) * factor
	root.add_child(geometry)
	if asset.get("parts") is Array:
		for item: Dictionary in asset.parts:
			var component := Node3D.new()
			component.transform = item.get("transform", Transform3D.IDENTITY)
			component.name = str(item.get("name", "Component")).validate_node_name()
			var part_model := MeshInstance3D.new()
			part_model.mesh = item.asset.mesh
			component.add_child(part_model)
			geometry.add_child(component)
	else:
		var model := MeshInstance3D.new()
		model.mesh = asset.mesh
		geometry.add_child(model)
	root.rotation_degrees.y = float(settings.get("rotation", 0.0))
	root.position.y = 0.0 if bool(asset.get("source_pose", false)) else float(settings.get("offset", 0.0))
	return root

## Serialize the approved mount and record the files used to build it.
static func prepare_glb(asset: Dictionary, settings: Dictionary, provenance: Dictionary) -> Dictionary:
	var completeness_issue := _complete_miniature_height_error((asset.get("bounds", AABB()) as AABB).size.y, settings)
	if not completeness_issue.is_empty(): return {"error": completeness_issue}
	var scene := visual(asset, settings)
	scene.name = "Miniature"
	var scene_footprint: Vector2 = scene.get_meta("asset_base_footprint_inches")
	var alignment := str(scene.get_meta("base_alignment_method"))
	# The board uses inches and glTF uses metres.
	scene.scale = Vector3.ONE * 0.0254
	var source_parts: Array[Dictionary] = []
	var inputs: Dictionary = asset.get("inputs", {}).duplicate()
	for part: Dictionary in asset.get("parts", []):
		var part_asset: Dictionary = part.asset
		inputs.merge(part_asset.get("inputs", {}))
		source_parts.append({"name": part.name, "mesh_sha256": part_asset.get("fingerprint", ""),
			"textures_sha256": part_asset.get("texture_fingerprint", ""), "warnings": part.get("warnings", [])})
	var gltf := GLTFDocument.new()
	var gltf_state := GLTFState.new()
	var result := gltf.append_from_scene(scene, gltf_state)
	var expected := _glb_mesh_layout(scene)
	scene.free()
	if result != OK or expected.is_empty(): return {"error": "The mounted model could not be serialized as GLB."}
	var bytes := gltf.generate_buffer(gltf_state)
	if bytes.size() < 12 or bytes.size() > MAX_BYTES or bytes.decode_u32(0) != 0x46546c67:
		return {"error": "The prepared GLB is invalid or exceeds 64 MiB."}
	var round_trip := _decode_prepared_glb(bytes)
	if round_trip == null: return {"error": "The prepared GLB could not be read back."}
	var actual := _glb_mesh_layout(round_trip)
	round_trip.free()
	if actual.size() != expected.size():
		return {"error": "GLB conversion changed the number of mounted mesh parts."}
	for part_index in expected.size():
		var source_transform: Transform3D = expected[part_index].transform
		var converted_transform: Transform3D = actual[part_index].transform
		if not source_transform.is_equal_approx(converted_transform):
			return {"error": "GLB conversion changed a mounted part transform."}
		if expected[part_index].surfaces != actual[part_index].surfaces:
			return {"error": "GLB conversion changed a mounted part's material slots."}
	var manifest := {"version": 3, "source": provenance, "parts": source_parts,
		"inputs": inputs, "fit": _package_fit(settings), "asset_fingerprint": asset.get("fingerprint", ""),
		"source_height_inches": float(asset.get("bounds", AABB()).size.y),
		"fitted_axes": [float(scene_footprint.x), float(scene_footprint.y)],
		"alignment": alignment,
		"source_axes": str(asset.get("base_footprint", Vector2.ZERO)),
		"source_center": str(asset.get("base_center", Vector2.ZERO)),
		"source_underside": asset.get("base_center_y", 0.0),
		"target_axes_inches": str(_visual_base_axes(settings)), "mount_yaw_degrees": settings.get("rotation", 0.0)}
	var context := HashingContext.new()
	context.start(HashingContext.HASH_SHA256)
	context.update(bytes)
	manifest.glb_sha256 = context.finish().hex_encode()
	var manifest_json := JSON.stringify(manifest, "  ", true, true)
	var directory := "user://prepared-miniatures".path_join(manifest_json.sha256_text())
	var path := directory.path_join("miniature.glb")
	var index := directory.path_join("manifest.json")
	if FileAccess.get_sha256(path) == manifest.glb_sha256 and FileAccess.get_sha256(index) == manifest_json.sha256_text():
		return {"error": "", "path": ProjectSettings.globalize_path(path), "key": manifest_json.sha256_text()}
	if DirAccess.make_dir_recursive_absolute(directory) != OK:
		return {"error": "Could not create the local GLB package directory."}
	for output: Array in [[path, bytes], [index, manifest_json.to_utf8_buffer()]]:
		var staging := str(output[0]) + ".partial"
		var file := FileAccess.open(staging, FileAccess.WRITE)
		if file == null: return {"error": "Could not write the local GLB package."}
		file.store_buffer(output[1])
		file.close()
		if DirAccess.rename_absolute(staging, output[0]) != OK:
			return {"error": "Could not publish the local GLB package."}
	return {"error": "", "path": ProjectSettings.globalize_path(path), "key": manifest_json.sha256_text()}

static func _package_fit(settings: Dictionary) -> Array:
	var axes := _visual_base_axes(settings)
	var fit: Array = [axes.x, axes.y, float(settings.get("rotation", 0.0)), bool(settings.get("visual_hull_proxy", false))]
	if fit[3]:
		# Invalidate only hull packages made before the interaction proxy stopped
		# determining the source model's visual scale.
		var user_scale := float(settings.get("scale", 1.0))
		if not is_finite(user_scale) or user_scale <= 0.0: user_scale = 1.0
		var source_scale := float(settings.get("tts_scale", 1.0))
		if not is_finite(source_scale) or source_scale <= 0.0: source_scale = 1.0
		fit.append_array([HULL_VISUAL_FIT_VERSION, user_scale, source_scale])
		if has_reviewed_hull_mount({"source_pose": true}, settings):
			var mount: Dictionary = settings.reviewed_hull_mount
			var offset: Vector3 = mount.contact_offset
			fit.append_array([float(mount.scale), offset.x, offset.y, offset.z])
	return fit

static func _package_file_hash(path: String) -> String:
	if not FileAccess.file_exists(path): return ""
	var size := FileAccess.get_size(path)
	return FileAccess.get_sha256(path) if size >= 0 and size <= MAX_BYTES else "oversize"

static func load_prepared_glb(key: String, fingerprint: String, settings: Dictionary) -> Dictionary:
	if key.length() != 64 or not key.is_valid_hex_number(): return {}
	var directory := "user://prepared-miniatures".path_join(key)
	var manifest_path := directory.path_join("manifest.json")
	if not FileAccess.file_exists(manifest_path): return {}
	var index := read_text(manifest_path)
	if not index.error.is_empty() or index.text.sha256_text() != key: return {}
	var manifest: Variant = JSON.parse_string(index.text)
	if not manifest is Dictionary or manifest.get("version") != 3 or manifest.get("asset_fingerprint") != fingerprint: return {}
	var source_height: Variant = manifest.get("source_height_inches", null)
	if not (source_height is float or source_height is int) or not is_finite(float(source_height)): return {}
	if not _complete_miniature_height_error(float(source_height), settings).is_empty(): return {}
	var recorded_fit: Variant = manifest.get("fit")
	var current_fit := _package_fit(settings)
	if not recorded_fit is Array or recorded_fit.size() != current_fit.size(): return {}
	for component in current_fit.size():
		var recorded: Variant = recorded_fit[component]
		var current: Variant = current_fit[component]
		if current is bool:
			if not recorded is bool or recorded != current: return {}
		elif not (recorded is float or recorded is int) or absf(float(recorded) - float(current)) > 0.000000001:
			return {}
	var inputs: Variant = manifest.get("inputs")
	if not inputs is Dictionary or inputs.is_empty() or inputs.size() > 2048: return {}
	var input_bytes := 0
	for path: String in inputs:
		input_bytes += maxi(0, FileAccess.get_size(path)) if FileAccess.file_exists(path) else 0
		if input_bytes > MAX_BYTES * 4 or inputs[path] == "oversize" or inputs[path] != _package_file_hash(path): return {}
	var path := directory.path_join("miniature.glb")
	if not FileAccess.file_exists(path) or FileAccess.get_size(path) > MAX_BYTES: return {}
	var bytes := FileAccess.get_file_as_bytes(path)
	if bytes.size() < 20 or bytes.decode_u32(0) != 0x46546c67: return {}
	var digest := HashingContext.new()
	digest.start(HashingContext.HASH_SHA256)
	digest.update(bytes)
	if digest.finish().hex_encode() != manifest.get("glb_sha256"): return {}
	var generated := _decode_prepared_glb(bytes)
	if generated == null: return {}
	var packed := PackedScene.new()
	var error := packed.pack(generated)
	generated.free()
	if error != OK: return {}
	var axes: Array = manifest.get("fitted_axes", [])
	if axes.size() != 2: return {}
	return {"scene": packed, "fit": _package_fit(settings), "axes": Vector2(axes[0], axes[1]), "alignment": str(manifest.get("alignment", ""))}

static func _decode_prepared_glb(bytes: PackedByteArray) -> Node3D:
	if bytes.size() < 20: return null
	var json_size := bytes.decode_u32(12)
	if bytes.decode_u32(16) != 0x4e4f534a or json_size > bytes.size() - 20: return null
	var gltf_json: Variant = JSON.parse_string(bytes.slice(20, 20 + json_size).get_string_from_utf8())
	if not gltf_json is Dictionary: return null
	for section: String in ["buffers", "images"]:
		for resource: Variant in gltf_json.get(section, []):
			if not resource is Dictionary or resource.has("uri"): return null
	for section: String in ["animations", "skins", "cameras"]:
		if not gltf_json.get(section, []).is_empty(): return null
	var document := GLTFDocument.new()
	var state := GLTFState.new()
	if document.append_from_buffer(bytes, "", state) != OK: return null
	return document.generate_scene(state) as Node3D

static func _glb_mesh_layout(root: Node3D, parent_transform: Transform3D = Transform3D.IDENTITY) -> Array[Dictionary]:
	var mounted := parent_transform * root.transform
	var layout: Array[Dictionary] = []
	if root is MeshInstance3D and root.mesh != null:
		layout.append({"transform": mounted, "surfaces": root.mesh.get_surface_count()})
	for child: Node in root.get_children():
		if child is Node3D:
			layout.append_array(_glb_mesh_layout(child, mounted))
	return layout
