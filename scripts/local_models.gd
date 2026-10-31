extends RefCounted
## Local visual data only. Never executes TTS scripts or imports gameplay geometry.
const MAX_BYTES := 64 * 1024 * 1024
const MAX_OBJECTS := 100000
const MAX_OBJ_ATTRIBUTES := 1000000
const MAX_OBJ_TRIANGLE_VERTICES := 1000000
static var _image_texture_cache: Dictionary = {}
const MM_PER_INCH := 25.4
const DEFAULT_INFANTRY_BASE_MM := 32.0
const INFANTRY_BASE_DIAMETER_LIMIT_IN := 1.72
const INFANTRY_HEIGHT_TO_BASE_RATIO := 1.35

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
		if internal_transforms is Array: transforms.append_array(internal_transforms.duplicate(true))
		output.append({"path": mesh_path, "texture": "", "normal": "", "transforms": transforms, "name": str(source_part.get("name", component.get("name", "Model"))), "bundle_url": str(component.get("bundle_url", "")), "bundle_dependency_urls": expected_dependency_urls.duplicate(), "warnings": source_part.get("warnings", [])} )
	return {"error": "", "parts": output}

static func component_plan(entry: Dictionary) -> Dictionary:
	var specs: Array[Dictionary] = []
	if entry.get("components") is Array:
		specs.assign(entry.components)
	else:
		if int(entry.get("child_components", 0)) > 0: return {"error": "The composite parts were not scanned. Scan the ForceOrg catalog again before importing."}
		specs.append({"path": str(entry.get("path", "")), "kind": str(entry.get("kind", "")), "references": entry.get("references", {}).duplicate(true), "transforms": [], "base_candidate": false})
	var parts: Array[Dictionary] = []
	for spec: Dictionary in specs:
		var kind := str(spec.get("kind", ""))
		if kind not in ["CustomMesh", "CustomAssetbundle"] or bool(spec.get("base_candidate", false)): continue
		var references: Dictionary = spec.get("references", {})
		var mesh_url := str(references.get("MeshURL", "")).strip_edges().trim_prefix("{verifycache}")
		var bundle_url := str(references.get("AssetbundleURL", "")).strip_edges().trim_prefix("{verifycache}")
		var secondary_bundle_url := str(references.get("AssetbundleSecondaryURL", "")).strip_edges().trim_prefix("{verifycache}")
		if bundle_url.is_empty(): bundle_url = secondary_bundle_url
		if kind == "CustomMesh" and mesh_url.is_empty(): continue # Empty wrapper nodes only carry transforms.
		if kind == "CustomAssetbundle" and bundle_url.is_empty(): continue
		var bundle_dependency_url := secondary_bundle_url if secondary_bundle_url != bundle_url else ""
		parts.append({"path": str(spec.get("path", "")), "name": str(spec.get("name", entry.get("name", "Model"))), "kind": kind, "bundle_url": bundle_url, "bundle_dependency_url": bundle_dependency_url, "references": references.duplicate(true), "transforms": spec.get("transforms", []).duplicate(true)})
	if parts.is_empty(): return {"error": "No compatible OBJ mesh or Unity model bundle references were found in this object."}
	return {"error": "", "components": parts}

static func read_text(path: String) -> Dictionary:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null: return {"error": "Cannot read local file: " + path}
	if file.get_length() > MAX_BYTES: return {"error": "File exceeds the 64 MiB import limit."}
	if 0 in file.get_buffer(mini(256, file.get_length())): return {"error": "Binary file unsupported here. Select a JSON save or text OBJ mesh, not an AssetBundle."}
	file.seek(0)
	return {"error": "", "text": file.get_as_text()}

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

static func scan(path: String) -> Dictionary:
	if DirAccess.dir_exists_absolute(path): path = path.path_join("ForceOrg.json")
	var source := read_text(path)
	if not source.error.is_empty(): return source
	var parser := JSON.new()
	if parser.parse(source.text) != OK: return {"error": "Invalid JSON at line %d: %s" % [parser.get_error_line(), parser.get_error_message()]}
	if not parser.data is Dictionary or not parser.data.get("ObjectStates") is Array: return {"error": "Expected a TTS save or saved object with an ObjectStates array."}
	var pending: Array = []
	for index in range(parser.data.ObjectStates.size()): pending.append({"object": parser.data.ObjectStates[index], "path": "ObjectStates/%d" % index})
	var entries: Array[Dictionary] = []
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
		if obj.get("LuaScript") is String and "objectJSONs" in obj.LuaScript:
			var embedded := static_model_objects(obj.LuaScript)
			if not embedded.error.is_empty(): warnings.append(next.path + ": " + embedded.error)
			embedded_bytes += int(embedded.bytes)
			if embedded_bytes > MAX_BYTES: return {"error": "Total embedded catalog exceeds the 64 MiB limit."}
			embedded_count += embedded.objects.size()
			for index in range(embedded.objects.size()): pending.append({"object": embedded.objects[index], "path": next.path + "/LuaScript/objectJSONs/%d" % index})
		for field in ["ContainedObjects", "AttachedObjects", "ChildObjects"]:
			if obj.has(field):
				if not obj[field] is Array: return {"error": "Invalid " + field + " at " + next.path}
				for index in range(obj[field].size()):
					var child := {"object": obj[field][index], "path": next.path + "/%s/%d" % [field, index]}
					if field == "ChildObjects":
						child.inherited_name = label + " / component %d" % (index + 1)
						child.inherited_credit = credit
					pending.append(child)
		if obj.has("States"):
			if not obj.States is Dictionary: return {"error": "Invalid alternate states at " + next.path}
			for key: String in obj.States: pending.append({"object": obj.States[key], "path": next.path + "/States/" + key})
		for field in ["CustomMesh", "CustomAssetbundle"]:
			if not obj.has(field): continue
			if not obj[field] is Dictionary: return {"error": "Invalid " + field + " at " + next.path}
			var refs: Dictionary = {}
			for key in ["MeshURL", "DiffuseURL", "NormalURL", "ColliderURL", "AssetbundleURL", "AssetbundleSecondaryURL"]:
				if obj[field].has(key):
					if not obj[field][key] is String: return {"error": "Invalid asset reference at " + next.path}
					refs[key] = obj[field][key]
			var children: Array = obj.get("ChildObjects", []) if obj.get("ChildObjects", []) is Array else []
			var entry := {"id": (path + ":" + next.path + ":" + field).sha256_text(), "name": label, "path": next.path, "guid": str(obj.get("GUID", "")), "kind": field, "references": refs, "credit": credit, "child_components": children.size(), "tts_scale": _tts_scale(obj)}
			if not children.is_empty(): entry.components = _component_specs(obj, next.path)
			entries.append(entry)
	entries.reverse()
	return {"error": "", "source": path, "fingerprint": source.text.sha256_text(), "entries": entries, "objects": count, "embedded_objects": embedded_count, "warnings": warnings}

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
	for record: Variant in records:
		if not record is Dictionary: continue
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
			rotation_basis = Basis.from_euler(euler)
		var local := Transform3D(rotation_basis.scaled(scale), position)
		result = result * local
	return result

static func composite_from_files(parts: Array, settings: Dictionary = {}) -> Dictionary:
	if parts.is_empty(): return {"error": "No downloaded OBJ components are available for this model."}
	var rendered_parts: Array[Dictionary] = []
	var combined_bounds := AABB()
	var has_bounds := false
	var base_footprint := Vector2.ZERO
	var base_center := Vector2.ZERO
	var base_center_y := 0.0
	var base_size := 0.0
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
			part_asset = obj_mesh(path, texture, normal, true)
			if not str(part_asset.get("error", "")).is_empty(): return {"error": str(item.get("name", "Component")) + ": " + str(part_asset.error)}
			loaded_by_path[identity] = part_asset
		var transform_records: Array = item.get("transforms", [])
		var part_transform := component_transform(transform_records)
		var world_bounds: AABB = part_asset.bounds * part_transform
		combined_bounds = world_bounds if not has_bounds else combined_bounds.merge(world_bounds)
		has_bounds = true
		var footprint: Vector2 = part_asset.get("base_footprint", Vector2.ZERO)
		if maxf(footprint.x, footprint.y) > base_size:
			var local_center: Vector2 = part_asset.get("base_center", Vector2(part_asset.bounds.get_center().x, part_asset.bounds.get_center().z))
			var center_3d := part_transform * Vector3(local_center.x, part_asset.bounds.position.y, local_center.y)
			var diameter := maxf(footprint.x, footprint.y) * maxf(part_transform.basis.x.length(), part_transform.basis.z.length())
			base_size = diameter
			base_footprint = Vector2.ONE * diameter
			base_center = Vector2(center_3d.x, center_3d.z)
			base_center_y = center_3d.y
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
		base_center = Vector2(combined_bounds.get_center().x, combined_bounds.get_center().z)
		base_center_y = combined_bounds.position.y
	var horizontal_size := maxf(combined_bounds.size.x, combined_bounds.size.z)
	if base_size > 0.05 and horizontal_size > 0.05 and combined_bounds.size.y / horizontal_size < 0.12:
		return {"error": "OBJ assembly contains only a flat base and no miniature body."}
	return {"error": "", "parts": rendered_parts, "bounds": combined_bounds, "base_footprint": base_footprint, "base_center": base_center, "base_center_y": base_center_y, "fingerprint": ",".join(signatures).sha256_text()}

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
	return float(ordered[int(round((ordered.size() - 1) * portion))])

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
	if x_values.size() < 12: return {}
	var center := Vector2(_percentile(x_values, 0.5), _percentile(z_values, 0.5))
	var radii: Array[float] = []
	for index in range(x_values.size()): radii.append(Vector2(x_values[index], z_values[index]).distance_to(center))
	var inner_radius := _percentile(radii, 0.25)
	var outer_radius := _percentile(radii, 0.75)
	if inner_radius < 0.04 or outer_radius / inner_radius > 2.0: return {}
	# The middle radial band ignores a staff tip or a few stray lowest vertices.
	var diameter := outer_radius * 2.0
	var horizontal_size := maxf(bounds.size.x, bounds.size.z)
	# Reject small circular details (for example a wheel or scenic socket) as
	# miniature bases. They would otherwise scale an entire vehicle many times
	# larger than its hull to match the datasheet base.
	if horizontal_size > 0.00001 and diameter / horizontal_size < 0.15: return {}
	return {"size": Vector2(diameter, diameter), "center": center}

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

static func visual_error_for_base(asset: Dictionary, settings: Dictionary) -> String:
	var radius := float(settings.get("base_radius_inches", 0.0))
	if radius <= 0.01: return ""
	var footprint: Vector2 = asset.get("base_footprint", Vector2.ZERO)
	if maxf(footprint.x, footprint.y) > 0.00001: return ""
	var diameter := radius * 2.0
	if diameter > INFANTRY_BASE_DIAMETER_LIMIT_IN: return ""
	var bounds: AABB = asset.get("bounds", AABB())
	if bounds.size.y <= 0.00001: return ""
	var normalized_footprint := maxf(bounds.size.x, bounds.size.z) * INFANTRY_HEIGHT_TO_BASE_RATIO / bounds.size.y
	if normalized_footprint > 3.5:
		return "Model bounds are too wide for an infantry-base visual and would sit outside its base. Choose another OBJ variant or adjust it manually."
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

static func _load_image_texture(path: String, purpose: String) -> Dictionary:
	if path.is_empty(): return {"error": "", "texture": null, "fingerprint": ""}
	if not FileAccess.file_exists(path): return {"error": "Cannot find the selected local %s image." % purpose, "texture": null, "fingerprint": ""}
	var texture_file := FileAccess.open(path, FileAccess.READ)
	if texture_file == null or texture_file.get_length() > MAX_BYTES: return {"error": "Cannot read %s image or it exceeds 64 MiB." % purpose, "texture": null, "fingerprint": ""}
	var fingerprint := FileAccess.get_sha256(path)
	var cached: Variant = _image_texture_cache.get(fingerprint)
	if cached is WeakRef:
		var cached_texture: Variant = cached.get_ref()
		if cached_texture is Texture2D: return {"error": "", "texture": cached_texture, "fingerprint": fingerprint}
	var data := texture_file.get_buffer(texture_file.get_length())
	var image := Image.new()
	var error := ERR_FILE_UNRECOGNIZED
	if data.size() >= 8 and data.slice(0, 8) == PackedByteArray([137, 80, 78, 71, 13, 10, 26, 10]): error = image.load_png_from_buffer(data)
	elif data.size() >= 3 and data[0] == 255 and data[1] == 216 and data[2] == 255: error = image.load_jpg_from_buffer(data)
	elif data.size() >= 12 and data.slice(0, 4).get_string_from_ascii() == "RIFF" and data.slice(8, 12).get_string_from_ascii() == "WEBP": error = image.load_webp_from_buffer(data)
	if error != OK: return {"error": "Cannot decode %s image as PNG, JPEG or WebP." % purpose, "texture": null, "fingerprint": ""}
	if image.get_width() > 8192 or image.get_height() > 8192: return {"error": "%s image exceeds 8192 pixels per side." % purpose.capitalize(), "texture": null, "fingerprint": ""}
	var texture := ImageTexture.create_from_image(image)
	if not fingerprint.is_empty():
		if _image_texture_cache.size() >= 512:
			for key: Variant in _image_texture_cache.keys():
				var weak_texture: Variant = _image_texture_cache[key]
				if not weak_texture is WeakRef or weak_texture.get_ref() == null: _image_texture_cache.erase(key)
				if _image_texture_cache.size() < 384: break
			if _image_texture_cache.size() >= 512: _image_texture_cache.erase(_image_texture_cache.keys()[0])
		_image_texture_cache[fingerprint] = weakref(texture)
	return {"error": "", "texture": texture, "fingerprint": fingerprint}

static func _load_obj_materials(path: String, obj_text: String, texture_override: String, normal_override: String = "") -> Dictionary:
	var materials: Dictionary = {"": {"color": Color("d6d2c6"), "diffuse": "", "normal": "", "roughness": 0.85}}
	var libraries: Array[String] = []
	var warnings: Array[String] = []
	for line: String in obj_text.split("\n"):
		var clean := line.split("#", true, 1)[0].strip_edges()
		if not clean.begins_with("mtllib "): continue
		var name := clean.trim_prefix("mtllib ").strip_edges()
		if not name.is_empty() and name not in libraries: libraries.append(name)
	if libraries.is_empty():
		var sibling := path.get_basename() + ".mtl"
		if FileAccess.file_exists(sibling): libraries.append(path.get_file().get_basename() + ".mtl")
	for library: String in libraries:
		var library_path := _safe_model_sidecar(path, library)
		if library_path.is_empty(): return {"error": "OBJ material library contains an unsafe path."}
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
	return {"error": "", "materials": materials, "warnings": warnings}

static func obj_mesh(path: String, texture_path: String = "", normal_path: String = "", allow_flat_component: bool = false) -> Dictionary:
	var source := read_text(path)
	if not source.error.is_empty(): return source
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
	var material_result := _load_obj_materials(path, source.text, texture_path, normal_path)
	if not str(material_result.get("error", "")).is_empty(): return material_result
	var mesh := ArrayMesh.new()
	var texture_fingerprints: Array[String] = []
	for material_name: String in faces_by_material:
		var faces: Array = faces_by_material[material_name]
		if faces.is_empty(): continue
		var spec: Dictionary = material_result.materials.get(material_name, material_result.materials[""])
		var material := StandardMaterial3D.new()
		material.albedo_color = spec.get("color", Color("d6d2c6"))
		material.roughness = float(spec.get("roughness", 0.85))
		var diffuse := _load_image_texture(str(spec.get("diffuse", "")), "diffuse")
		if not str(diffuse.get("error", "")).is_empty(): return diffuse
		if diffuse.get("texture") is Texture2D: material.albedo_texture = diffuse.texture
		if not str(diffuse.get("fingerprint", "")).is_empty(): texture_fingerprints.append(str(diffuse.fingerprint))
		var normal := _load_image_texture(str(spec.get("normal", "")), "normal map")
		if not str(normal.get("error", "")).is_empty(): return normal
		if normal.get("texture") is Texture2D:
			material.normal_enabled = true
			material.normal_texture = normal.texture
			texture_fingerprints.append(str(normal.fingerprint))
		var surface := SurfaceTool.new()
		surface.begin(Mesh.PRIMITIVE_TRIANGLES)
		for face: Array in faces:
			for index in range(1, face.size() - 1):
				# OBJ is counterclockwise; Godot front faces are clockwise.
				for corner: Array in [face[0], face[index + 1], face[index]]:
					surface.set_uv(uvs[corner[1]] if corner[1] >= 0 else Vector2.ZERO)
					if has_vertex_colors: surface.set_color(vertex_colors[corner[0]])
					surface.add_vertex(vertices[corner[0]])
		surface.generate_normals()
		surface.set_material(material)
		surface.commit(mesh)
	var bounds := mesh.get_aabb()
	if bounds.size.y < 0.00001 and not allow_flat_component: return {"error": "Model has no usable vertical height."}
	var base_reference := _base_reference(vertices, bounds)
	if not texture_path.is_empty() and texture_fingerprints.is_empty(): texture_fingerprints.append(FileAccess.get_sha256(texture_path))
	return {"error": "", "mesh": mesh, "bounds": bounds, "base_footprint": base_reference.get("size", Vector2.ZERO), "base_center": base_reference.get("center", Vector2(bounds.get_center().x, bounds.get_center().z)), "fingerprint": source.text.sha256_text(), "texture_fingerprint": ",".join(texture_fingerprints).sha256_text() if not texture_fingerprints.is_empty() else "", "warnings": material_result.get("warnings", [])}

static func visual(asset: Dictionary, settings: Dictionary) -> Node3D:
	var root := Node3D.new()
	var bounds: AABB = asset.bounds
	var factor: float = table_scale(bounds, settings, asset.get("base_footprint", Vector2.ZERO))
	var base_center: Vector2 = asset.get("base_center", Vector2(bounds.get_center().x, bounds.get_center().z))
	var origin_y := float(asset.get("base_center_y", bounds.position.y))
	var geometry := Node3D.new()
	geometry.scale = Vector3.ONE * factor
	geometry.position = -Vector3(base_center.x, origin_y, base_center.y) * factor
	root.add_child(geometry)
	if asset.get("parts") is Array:
		for item: Dictionary in asset.parts:
			var component := Node3D.new()
			component.transform = item.get("transform", Transform3D.IDENTITY)
			var part_model := MeshInstance3D.new()
			part_model.mesh = item.asset.mesh
			component.add_child(part_model)
			geometry.add_child(component)
	else:
		var model := MeshInstance3D.new()
		model.mesh = asset.mesh
		geometry.add_child(model)
	root.rotation_degrees.y = float(settings.get("rotation", 0.0))
	root.position.y = float(settings.get("offset", 0.0))
	return root
