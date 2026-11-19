extends RefCounted
## Local process marker for a persisted match checkpoint. Save data stays in its slot.

const Save = preload("res://scripts/match_save.gd")
const DIRECTORY := "user://matches/recovery"
const PREFIX := "session-"
const SUFFIX := ".checkpoint"

static func mark(slot: int, journal_id: String, revision: int) -> void:
	if Save.slot_path(slot).is_empty() or journal_id.is_empty() or revision < 0: return
	if DirAccess.make_dir_recursive_absolute(DIRECTORY) != OK: return
	var path := _path(OS.get_process_id())
	var temporary := path + ".tmp"
	var file := FileAccess.open(temporary, FileAccess.WRITE)
	if file == null: return
	file.store_string(JSON.stringify({"slot": slot, "journal": journal_id, "revision": revision}))
	file.flush()
	var error := file.get_error()
	file.close()
	if error == OK: DirAccess.rename_absolute(temporary, path)

static func dismiss(pid: int) -> void:
	if pid > 0: DirAccess.remove_absolute(_path(pid))

static func find() -> Dictionary:
	var directory := DirAccess.open(DIRECTORY)
	if directory == null: return {}
	var result := {}
	var newest := -1
	for filename: String in directory.get_files():
		if not filename.begins_with(PREFIX) or not filename.ends_with(SUFFIX): continue
		var id := filename.trim_prefix(PREFIX).trim_suffix(SUFFIX)
		if not id.is_valid_int() or int(id) <= 0 or _process_may_be_running(int(id)): continue
		var path := _path(int(id))
		var modified := FileAccess.get_modified_time(path)
		if modified < newest: continue
		var file := FileAccess.open(path, FileAccess.READ)
		if file == null or file.get_length() > 1024: continue
		var marker: Variant = JSON.parse_string(file.get_as_text())
		if not marker is Dictionary: continue
		var raw_slot: Variant = marker.get("slot", 0)
		var raw_revision: Variant = marker.get("revision", -1)
		if not (raw_slot is float or raw_slot is int) or not (raw_revision is float or raw_revision is int): continue
		var slot := int(raw_slot)
		var revision := int(raw_revision)
		var slot_path := Save.slot_path(slot)
		var journal_id := str(marker.get("journal", ""))
		if slot_path.is_empty() or journal_id.is_empty() or revision < 0: continue
		var saved := Save.read(slot_path)
		if saved.has("error") or not saved.get("journal", {}) is Dictionary or saved.journal.get("id", "") != journal_id: continue
		result = {"pid": int(id), "slot": slot, "revision": revision, "saved": saved}
		newest = modified
	return result

static func _path(pid: int) -> String:
	return DIRECTORY.path_join("%s%d%s" % [PREFIX, pid, SUFFIX])

static func _process_may_be_running(pid: int) -> bool:
	if pid == OS.get_process_id(): return true
	# Godot's process query only tracks children created by that instance.
	if OS.get_name() == "Windows":
		var rows := []
		var tasklist := OS.get_environment("SystemRoot").path_join("System32/tasklist.exe")
		var code := OS.execute(tasklist, ["/FI", "PID eq %d" % pid, "/FO", "CSV", "/NH"], rows)
		return code != 0 or (not rows.is_empty() and str(rows[0]).contains(",\"%d\"," % pid))
	if OS.get_name() == "Linux" and DirAccess.dir_exists_absolute("/proc/self"):
		return DirAccess.dir_exists_absolute("/proc/%d" % pid)
	# An unknown process state must not claim an interruption.
	return true
