extends RefCounted
## Local visual data only. Never executes TTS scripts or imports gameplay geometry.
const MAX_BYTES := 64 * 1024 * 1024
const MAX_OBJECTS := 100000
const MAX_VERTICES := 300000
const MM_PER_INCH := 25.4
const DEFAULT_INFANTRY_BASE_MM := 32.0

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
	downloaded_name.compile("^[a-f0-9]{64}-[a-f0-9]{16}\\.(?:obj|png)$")
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
					if downloaded_name.search(name) != null: keys.append(name.substr(0, 64))
					if name.get_extension().to_lower() in ["obj", "png", "jpg", "jpeg", "webp"]:
						var stem := cache_key(name.get_basename())
						if stem not in keys: keys.append(stem)
					for key: String in keys:
						if not names.has(key): names[key] = []
						names[key].append(path)
			name = directory.get_next()
		directory.list_dir_end()
	return {"error": "", "names": names, "files": count, "root": root}

static func cache_match(reference: String, index: Dictionary, image: bool = false) -> Dictionary:
	var key := cache_key(reference.strip_edges())
	if key.length() < 12 or not (reference.begins_with("https://") or reference.begins_with("http://") or reference.begins_with("{verifycache}http")):
		return {"status": "missing", "path": "", "candidates": []}
	var candidates: Array[String] = []
	for match_key: String in [key, reference.strip_edges().trim_prefix("{verifycache}").sha256_text()]:
		for path: String in index.get("names", {}).get(match_key, []):
			var extension := path.get_extension().to_lower()
			var allowed := ["png", "jpg", "jpeg", "webp"] if image else ["obj"]
			if (extension.is_empty() or extension in allowed) and path not in candidates: candidates.append(path)
	candidates.sort()
	return {"status": "found" if candidates.size() == 1 else ("ambiguous" if candidates.size() > 1 else "missing"), "path": candidates[0] if candidates.size() == 1 else "", "candidates": candidates}

static func resolve_cache(entry: Dictionary, index: Dictionary) -> Dictionary:
	if entry.get("kind", "") != "CustomMesh": return {"error": "AssetBundle unsupported: select a compatible local OBJ manually."}
	var references: Dictionary = entry.get("references", {})
	var mesh := cache_match(str(references.get("MeshURL", "")), index)
	var diffuse := cache_match(str(references.get("DiffuseURL", "")), index, true)
	return {"error": "", "mesh": mesh, "diffuse": diffuse, "diffuse_required": not str(references.get("DiffuseURL", "")).is_empty()}

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
			entries.append({"id": (path + ":" + next.path + ":" + field).sha256_text(), "name": label, "path": next.path, "guid": str(obj.get("GUID", "")), "kind": field, "references": refs, "credit": credit, "child_components": obj.get("ChildObjects", []).size(), "tts_scale": _tts_scale(obj)})
	entries.reverse()
	return {"error": "", "source": path, "fingerprint": source.text.sha256_text(), "entries": entries, "objects": count, "embedded_objects": embedded_count, "warnings": warnings}

static func _tts_scale(obj: Dictionary) -> float:
	if not obj.get("Transform") is Dictionary: return 1.0
	var transform: Dictionary = obj.Transform
	for key in ["scaleX", "scaleY", "scaleZ"]:
		var value: Variant = transform.get(key, 1.0)
		if not (value is float or value is int) or not is_finite(float(value)) or float(value) < 0.01 or float(value) > 20.0:
			return 1.0
	return float(transform.scaleX)

static func table_scale(bounds: AABB, settings: Dictionary) -> float:
	var user := float(settings.get("scale", 1.0))
	if not is_finite(user) or user <= 0.0: user = 1.0
	var radius := float(settings.get("base_radius_inches", 0.0))
	var footprint := maxf(bounds.size.x, bounds.size.z)
	if radius > 0.01 and footprint > 0.00001:
		return (radius * 2.0) / footprint * user
	var tts := float(settings.get("tts_scale", 1.0))
	if not is_finite(tts) or tts <= 0.0: tts = 1.0
	if bounds.size.y > 0.05 and bounds.size.y < 8.0 and footprint > 0.05 and footprint < 8.0:
		return tts * user
	if footprint > 0.00001:
		return (DEFAULT_INFANTRY_BASE_MM / MM_PER_INCH) / footprint * user
	return user

static func _index(value: String, size: int) -> int:
	if not value.is_valid_int(): return -1
	var index := int(value)
	if index == 0: return -1
	return index - 1 if index > 0 and index <= size else (size + index if index < 0 and -index <= size else -1)

static func obj_mesh(path: String, texture_path: String = "") -> Dictionary:
	var source := read_text(path)
	if not source.error.is_empty(): return source
	var vertices: Array[Vector3] = []
	var uvs: Array[Vector2] = []
	var normals: Array[Vector3] = []
	var faces: Array = []
	var triangle_vertices := 0
	for line: String in source.text.split("\n"):
		var words := line.split("#", true, 1)[0].replace("\t", " ").strip_edges().split(" ", false)
		if words.is_empty(): continue
		if words[0] in ["v", "vn", "vt"]:
			var needed := 2 if words[0] == "vt" else 3
			if words.size() < needed + 1: return {"error": "Incomplete OBJ vertex, normal or UV."}
			for index in range(1, needed + 1):
				if not words[index].is_valid_float() or not is_finite(float(words[index])) or absf(float(words[index])) > 1000000: return {"error": "Invalid or excessive OBJ coordinate."}
			if words[0] == "v": vertices.append(Vector3(float(words[1]), float(words[2]), float(words[3])))
			elif words[0] == "vn": normals.append(Vector3(float(words[1]), float(words[2]), float(words[3])))
			else: uvs.append(Vector2(float(words[1]), 1.0 - float(words[2])))
			if vertices.size() + normals.size() + uvs.size() > MAX_VERTICES: return {"error": "OBJ source exceeds the 300,000 attribute limit."}
		elif words[0] == "f":
			if words.size() < 4 or words.size() > 65: return {"error": "OBJ faces require 3–64 vertices."}
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
			if triangle_vertices > MAX_VERTICES: return {"error": "OBJ exceeds the 300,000 triangle-vertex limit."}
			faces.append(face)
	if faces.is_empty(): return {"error": "No OBJ mesh faces found. AssetBundles require a compatible model; they cannot be read as OBJ."}
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	for face: Array in faces:
		for index in range(1, face.size() - 1):
			# OBJ is counterclockwise; Godot front faces are clockwise.
			for corner: Array in [face[0], face[index + 1], face[index]]:
				surface.set_uv(uvs[corner[1]] if corner[1] >= 0 else Vector2.ZERO)
				surface.add_vertex(vertices[corner[0]])
	surface.generate_normals()
	var material := StandardMaterial3D.new()
	material.albedo_color = Color("d6d2c6")
	material.roughness = 0.85
	if not texture_path.is_empty():
		if not FileAccess.file_exists(texture_path): return {"error": "Cannot find the selected local diffuse texture."}
		var texture_file := FileAccess.open(texture_path, FileAccess.READ)
		if texture_file == null or texture_file.get_length() > MAX_BYTES: return {"error": "Cannot read texture or texture exceeds 64 MiB."}
		var data := texture_file.get_buffer(texture_file.get_length())
		var image := Image.new()
		var error := ERR_FILE_UNRECOGNIZED
		if data.size() >= 8 and data.slice(0, 8) == PackedByteArray([137, 80, 78, 71, 13, 10, 26, 10]): error = image.load_png_from_buffer(data)
		elif data.size() >= 3 and data[0] == 255 and data[1] == 216 and data[2] == 255: error = image.load_jpg_from_buffer(data)
		elif data.size() >= 12 and data.slice(0, 4).get_string_from_ascii() == "RIFF" and data.slice(8, 12).get_string_from_ascii() == "WEBP": error = image.load_webp_from_buffer(data)
		if error != OK: return {"error": "Cannot decode local diffuse texture as PNG, JPEG or WebP."}
		if image.get_width() > 8192 or image.get_height() > 8192: return {"error": "Texture exceeds 8192 pixels per side."}
		material.albedo_texture = ImageTexture.create_from_image(image)
		material.albedo_color = Color.WHITE
	surface.set_material(material)
	var mesh := surface.commit()
	var bounds := mesh.get_aabb()
	if bounds.size.y < 0.00001: return {"error": "Model has no usable vertical height."}
	return {"error": "", "mesh": mesh, "bounds": bounds, "fingerprint": source.text.sha256_text(), "texture_fingerprint": FileAccess.get_sha256(texture_path) if not texture_path.is_empty() else ""}

static func visual(asset: Dictionary, settings: Dictionary) -> Node3D:
	var root := Node3D.new()
	var model := MeshInstance3D.new()
	model.mesh = asset.mesh
	var bounds: AABB = asset.bounds
	var factor: float = table_scale(bounds, settings)
	model.scale = Vector3.ONE * factor
	model.position = -Vector3(bounds.get_center().x, bounds.position.y, bounds.get_center().z) * factor
	root.add_child(model)
	root.rotation_degrees.y = float(settings.get("rotation", 0.0))
	root.position.y = float(settings.get("offset", 0.0))
	return root
