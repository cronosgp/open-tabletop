extends RefCounted

const VERSION := 1
const MAX_BYTES := 16 * 1024 * 1024
const PATH := "user://matches/current.save"
const SLOT_COUNT := 5

static func slot_path(slot: int) -> String:
	if slot < 1 or slot > SLOT_COUNT: return ""
	if slot == 1: return PATH
	return "user://matches/slots/slot-%02d.save" % slot

static func journal_directory(slot: int) -> String:
	if slot < 1 or slot > SLOT_COUNT: return ""
	if slot == 1: return "user://matches/journals"
	return "user://matches/journals/slot-%02d" % slot

static func slot_has_file(slot: int) -> bool:
	var path := slot_path(slot)
	return not path.is_empty() and _save_file_exists(path)

static func backup_path(slot: int) -> String:
	var path := slot_path(slot)
	return path + ".bak" if not path.is_empty() else ""

static func read_backup(slot: int) -> Dictionary:
	var path := backup_path(slot)
	if path.is_empty(): return {"error": "Choose a valid local save slot."}
	return _read_file(path)

## Reads exactly this file; journal cleanup uses it to retain every snapshot reference.
static func read_snapshot_file(path: String) -> Dictionary:
	return _read_file(path)

static func existing_slots() -> Array[int]:
	var result: Array[int] = []
	for slot in range(1, SLOT_COUNT + 1):
		if slot_has_file(slot): result.append(slot)
	return result

static func slot_records() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for slot in range(1, SLOT_COUNT + 1):
		var path := slot_path(slot)
		var backup := backup_path(slot)
		var primary_exists := FileAccess.file_exists(path)
		var backup_exists := FileAccess.file_exists(backup)
		var record := {"slot": slot, "path": path, "exists": primary_exists or backup_exists, "valid": false, "recovered_from_backup": false, "modified": FileAccess.get_modified_time(path) if primary_exists else (FileAccess.get_modified_time(backup) if backup_exists else 0), "summary": "Empty slot", "error": ""}
		if record.exists:
			var saved := read(path)
			if saved.has("error"):
				record.error = str(saved.error)
				record.summary = "Save cannot be read. You can overwrite this slot from an active local match."
			else:
				record.valid = true
				record.recovered_from_backup = bool(saved.get("recovered_from_backup", false))
				if record.recovered_from_backup:
					record.modified = FileAccess.get_modified_time(backup) if backup_exists else record.modified
					record.error = str(saved.get("primary_error", "The primary save is unavailable."))
					record.summary = "Recovered backup · " + _slot_summary(saved)
				else:
					record.summary = _slot_summary(saved)
		result.append(record)
	return result

static func _save_file_exists(path: String) -> bool:
	return FileAccess.file_exists(path) or FileAccess.file_exists(path + ".bak")

static func _slot_summary(saved: Dictionary) -> String:
	var state: Dictionary = saved.get("state", {})
	var mission_value: Variant = state.get("mission", {})
	var mission: Dictionary = mission_value if mission_value is Dictionary else {}
	var manifest_value: Variant = state.get("match_manifest", {})
	var manifest: Dictionary = manifest_value if manifest_value is Dictionary else {}
	var round_number := int(state.get("round", 1))
	var active_player := int(state.get("active", 1))
	var decision_player := int(saved.get("decision_player", -1))
	var phase := str(state.get("phase", "unknown")).replace("_", " ").capitalize()
	var mission_name := str(mission.get("name", ""))
	if mission_name.is_empty():
		mission_name = str(state.get("scenario", manifest.get("scenario_id", "Local match"))).replace("-", " ").capitalize()
	var turn_summary := "Player %d's turn" % active_player
	if decision_player > 0 and decision_player != active_player:
		turn_summary += " · Player %d decides" % decision_player
	return "%s · Round %d · %s · %s" % [mission_name, round_number, turn_summary, phase]

static func safe(value: Variant, depth: int = 0) -> bool:
	if depth > 64: return false
	match typeof(value):
		TYPE_NIL, TYPE_BOOL, TYPE_INT, TYPE_STRING, TYPE_STRING_NAME, TYPE_PACKED_BYTE_ARRAY, TYPE_PACKED_STRING_ARRAY, TYPE_PACKED_INT32_ARRAY, TYPE_PACKED_INT64_ARRAY:
			return true
		TYPE_FLOAT:
			return is_finite(value)
		TYPE_VECTOR2, TYPE_VECTOR3:
			return value.is_finite()
		TYPE_RECT2:
			return value.position.is_finite() and value.size.is_finite()
		TYPE_COLOR:
			return is_finite(value.r) and is_finite(value.g) and is_finite(value.b) and is_finite(value.a)
		TYPE_PACKED_FLOAT32_ARRAY, TYPE_PACKED_FLOAT64_ARRAY:
			for item: float in value:
				if not is_finite(item): return false
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

static func write(snapshot: Dictionary, config: Dictionary, random_state: int, draft: Dictionary, path: String = PATH, session: Dictionary = {}, journal: Dictionary = {}, previous_save: Dictionary = {}, decision_player: int = -1) -> String:
	var payload := {"version": VERSION, "state": snapshot, "config": config, "rng_state": random_state, "attack_draft": draft, "session": session, "journal": journal}
	if decision_player in [1, 2]: payload.decision_player = decision_player
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
	var temporary_path := path + ".tmp"
	if FileAccess.file_exists(path):
		var prior := previous_save
		if prior.is_empty(): prior = _read_file(path)
		if not prior.has("error") and not bool(prior.get("recovered_from_backup", false)):
			error = DirAccess.copy_absolute(ProjectSettings.globalize_path(path), ProjectSettings.globalize_path(path + ".bak"))
			if error != OK:
				DirAccess.remove_absolute(ProjectSettings.globalize_path(temporary_path))
				return "Could not preserve the previous match save: " + error_string(error)
	error = DirAccess.rename_absolute(ProjectSettings.globalize_path(temporary_path), ProjectSettings.globalize_path(path))
	return "" if error == OK else error_string(error)

static func read(path: String = PATH) -> Dictionary:
	var primary := read_snapshot_file(path)
	if not primary.has("error"): return primary
	# A save from a newer build is valid data that this build cannot interpret;
	# loading an older backup would silently roll the player back.
	if str(primary.get("error", "")) == "Incompatible save version.": return primary
	var backup_path := path + ".bak"
	if not FileAccess.file_exists(backup_path): return primary
	var backup := read_snapshot_file(backup_path)
	if backup.has("error"):
		return {"error": "%s Previous backup could not be read: %s" % [str(primary.error), str(backup.error)]}
	backup.recovered_from_backup = true
	backup.primary_error = str(primary.error)
	return backup

static func _read_file(path: String) -> Dictionary:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null: return {"error": "No saved match is available."}
	var file_length := file.get_length()
	if file_length > MAX_BYTES + 64 or file_length < 68:
		file.close()
		return {"error": "Invalid match file size."}
	var digest := file.get_buffer(64).get_string_from_ascii()
	var bytes := file.get_buffer(file_length - 64)
	file.close()
	if bytes.hex_encode().sha256_text() != digest: return {"error": "Match file is corrupted."}
	var value: Variant = bytes_to_var(bytes)
	if not value is Dictionary or not safe(value): return {"error": "Invalid match file."}
	if value.get("version") != VERSION: return {"error": "Incompatible save version."}
	for key in ["state", "config", "attack_draft"]:
		if not value.get(key) is Dictionary: return {"error": "Saved match is incomplete."}
	if not value.get("rng_state") is int: return {"error": "Invalid random-number generator state."}
	if value.has("decision_player") and (not value.decision_player is int or int(value.decision_player) not in [1, 2]): return {"error": "Invalid saved decision owner."}
	return value

