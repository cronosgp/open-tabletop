extends RefCounted

const VERSION := 1
const MAX_BYTES := 16 * 1024 * 1024
const PATH := "user://matches/current.save"

static func safe(value: Variant, depth: int = 0) -> bool:
	if depth > 64: return false
	match typeof(value):
		TYPE_NIL, TYPE_BOOL, TYPE_INT, TYPE_FLOAT, TYPE_STRING, TYPE_STRING_NAME, TYPE_VECTOR2, TYPE_VECTOR3, TYPE_RECT2, TYPE_COLOR, TYPE_PACKED_BYTE_ARRAY, TYPE_PACKED_STRING_ARRAY, TYPE_PACKED_INT32_ARRAY, TYPE_PACKED_INT64_ARRAY, TYPE_PACKED_FLOAT32_ARRAY, TYPE_PACKED_FLOAT64_ARRAY:
			return true
		TYPE_ARRAY:
			for item in value:
				if not safe(item, depth + 1): return false
			return true
		TYPE_DICTIONARY:
			for key in value:
				if typeof(key) not in [TYPE_INT, TYPE_STRING, TYPE_STRING_NAME] or not safe(value[key], depth + 1): return false
			return true
	return false

static func write(snapshot: Dictionary, config: Dictionary, random_state: int, draft: Dictionary, path: String = PATH, session: Dictionary = {}, journal: Dictionary = {}) -> String:
	var payload := {"version": VERSION, "state": snapshot, "config": config, "rng_state": random_state, "attack_draft": draft, "session": session, "journal": journal}
	if not safe(payload): return "The match contains an unsupported data type."
	var bytes := var_to_bytes(payload)
	if bytes.size() > MAX_BYTES: return "The match exceeds the save limit."
	var directory := ProjectSettings.globalize_path(path.get_base_dir())
	var error := DirAccess.make_dir_recursive_absolute(directory)
	if error != OK: return error_string(error)
	var file := FileAccess.open(path + ".tmp", FileAccess.WRITE)
	if file == null: return error_string(FileAccess.get_open_error())
	file.store_buffer(bytes.hex_encode().sha256_text().to_ascii_buffer())
	file.store_buffer(bytes)
	file.flush()
	error = file.get_error()
	file.close()
	if error != OK: return error_string(error)
	error = DirAccess.rename_absolute(ProjectSettings.globalize_path(path + ".tmp"), ProjectSettings.globalize_path(path))
	return "" if error == OK else error_string(error)

static func read(path: String = PATH) -> Dictionary:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null: return {"error": "No saved match is available."}
	if file.get_length() > MAX_BYTES + 64 or file.get_length() < 68: return {"error": "Invalid match file size."}
	var digest := file.get_buffer(64).get_string_from_ascii()
	var bytes := file.get_buffer(file.get_length() - 64)
	if bytes.hex_encode().sha256_text() != digest: return {"error": "Match file is corrupted."}
	var value: Variant = bytes_to_var(bytes)
	if not value is Dictionary or not safe(value): return {"error": "Invalid match file."}
	if value.get("version") != VERSION: return {"error": "Incompatible save version."}
	for key in ["state", "config", "attack_draft"]:
		if not value.get(key) is Dictionary: return {"error": "Saved match is incomplete."}
	if not value.get("rng_state") is int: return {"error": "Invalid random-number generator state."}
	return value

