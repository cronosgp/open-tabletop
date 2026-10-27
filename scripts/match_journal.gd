extends RefCounted
## Append-only public state history. Reading reconstructs data; never executes rules.
const Save = preload("res://scripts/match_save.gd")
const DIRECTORY := "user://matches/journals"
const MAX_BYTES := 64 * 1024 * 1024
const MAX_RECORD := 2 * 1024 * 1024
const COMPACT_TRIGGER_BYTES := 48 * 1024 * 1024
const COMPACT_TARGET_BYTES := 32 * 1024 * 1024
const MAX_RETAINED_ENTRIES := 1000
const ZERO := "0000000000000000000000000000000000000000000000000000000000000000"
var storage_directory := DIRECTORY
var id := ""
var entries: Array = []
var retired_ids: Array[String] = []
var observed: Dictionary = {}
var offset := 0
var tip := ZERO
var initial: Dictionary = {}
var pending_dice: Array = []
var cleanup_pending := false

static func digest(value: Variant) -> String:
	return var_to_bytes(value).hex_encode().sha256_text()

static func valid_id(value: Variant) -> bool:
	if not value is String or value.length() != 64: return false
	for character in value:
		if character not in "0123456789abcdef": return false
	return true

func reset(state: Dictionary) -> void:
	id = Crypto.new().generate_random_bytes(32).hex_encode()
	entries = []
	retired_ids = []
	cleanup_pending = false
	observed = {}
	initial = state.duplicate(true)
	offset = 0
	tip = ZERO
	pending_dice = []

func path() -> String:
	return storage_directory.path_join(id + ".journal")

func checkpoint() -> Dictionary:
	var reference := {"version": 1, "id": id, "count": entries.size(), "offset": offset, "hash": tip}
	if not retired_ids.is_empty(): reference.retired_ids = retired_ids.duplicate()
	return reference

## Copies a committed journal prefix to another slot under a fresh file identity.
## The hash chain does not depend on the storage filename, so the saved event
## history remains byte-for-byte verifiable while future writes stay isolated.
func copy_to_directory(destination_directory: String) -> Dictionary:
	if id.is_empty() or entries.is_empty(): return {"error": "Match history has not been initialized."}
	var source_path := path()
	var source := FileAccess.open(source_path, FileAccess.READ)
	if source == null: return {"error": "Match history is missing from the active save slot."}
	if source.get_length() != offset:
		source.close()
		return {"error": "Match history changed before the slot copy."}
	var bytes := source.get_buffer(source.get_length())
	source.close()
	if bytes.size() != offset: return {"error": "Match history could not be copied completely."}
	var error := DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(destination_directory))
	if error != OK: return {"error": error_string(error)}
	var copied_id := Crypto.new().generate_random_bytes(32).hex_encode()
	var destination_path := destination_directory.path_join(copied_id + ".journal")
	var temporary_path := destination_path + ".tmp"
	var destination := FileAccess.open(temporary_path, FileAccess.WRITE)
	if destination == null: return {"error": error_string(FileAccess.get_open_error())}
	destination.store_buffer(bytes)
	destination.flush()
	error = destination.get_error()
	destination.close()
	if error != OK:
		DirAccess.remove_absolute(ProjectSettings.globalize_path(temporary_path))
		return {"error": error_string(error)}
	error = DirAccess.rename_absolute(ProjectSettings.globalize_path(temporary_path), ProjectSettings.globalize_path(destination_path))
	if error != OK:
		DirAccess.remove_absolute(ProjectSettings.globalize_path(temporary_path))
		return {"error": error_string(error)}
	var copied_checkpoint := checkpoint()
	copied_checkpoint.id = copied_id
	return {"error": "", "id": copied_id, "checkpoint": copied_checkpoint}

func remove_copy(copied_id: String, directory: String) -> void:
	if not valid_id(copied_id): return
	var copied_path := directory.path_join(copied_id + ".journal")
	if FileAccess.file_exists(copied_path): DirAccess.remove_absolute(ProjectSettings.globalize_path(copied_path))

func roll(state: Dictionary, value: int) -> void:
	pending_dice.append({"sides": 6, "value": value, "revision": state.get("revision", 0), "phase": state.get("phase", "movement"), "active": state.get("active", 1)})

func capture(state: Dictionary) -> String:
	if id.is_empty(): reset(state)
	if entries.is_empty():
		var error := append(initial, [], "start")
		if not error.is_empty(): return error
	if digest(state) == digest(observed) and pending_dice.is_empty(): return ""
	var error := append(state, pending_dice, "update")
	if error.is_empty(): pending_dice = []
	return error

func append(state: Dictionary, dice: Array, kind: String) -> String:
	var patch: Dictionary = {}
	var removed: Array = []
	for key in state:
		if not observed.has(key) or state[key] != observed[key]: patch[key] = state[key].duplicate(true) if state[key] is Dictionary or state[key] is Array else state[key]
	for key in observed:
		if not state.has(key): removed.append(key)
	var messages: Array = []
	for event in state.get("events", []):
		if event not in observed.get("events", []): messages.append(event.get("message", ""))
	var changes: Array = []
	var results: Array = []
	if state.get("last_attack", {}) != observed.get("last_attack", {}):
		var attack: Dictionary = state.get("last_attack", {})
		for pool: Dictionary in attack.get("pools", []):
			results.append("%s • target %s\nHits %s • wounds %s • saves %s" % [pool.get("weapon_name", "Attack"), str(pool.get("target_squad", "—")), str(pool.get("hit_rolls", [])), str(pool.get("wound_rolls", [])), str(pool.get("save_rolls", []))])
			for damage: Dictionary in pool.get("damage_rolls", []):
				results.append("Damage %s: %s = %s" % [str(damage.get("expression", "")), str(damage.get("rolls", [])), str(damage.get("value", 0))])
			for prevention: Dictionary in pool.get("prevention_rolls", []):
				results.append("Feel No Pain: %s • %s prevenidos" % [str(prevention.get("rolls", [])), str(prevention.get("prevented", 0))])
		var hazard: Dictionary = attack.get("hazardous", {})
		if not hazard.get("rolls", []).is_empty(): results.append("Hazardous: %s • damage %s" % [str(hazard.rolls), str(hazard.get("total", 0))])
	for model in state.get("units", {}):
		var after: Dictionary = state.units[model]
		var before: Dictionary = observed.get("units", {}).get(model, {})
		if not before.is_empty():
			if before.get("position") != after.get("position"): changes.append("Model %s: %s → %s" % [str(model), str(before.get("position")), str(after.get("position"))])
			if before.get("wounds") != after.get("wounds"): changes.append("Model %s: wounds %s → %s" % [str(model), str(before.get("wounds")), str(after.get("wounds"))])
	var entry := {"version": 1, "sequence": entries.size() + 1, "previous": tip, "kind": kind, "utc": Time.get_datetime_string_from_system(true), "revision": state.get("revision", 0), "round": state.get("round", 0), "active": state.get("active", 1), "phase": state.get("phase", "movement"), "dice": dice.duplicate(true), "messages": messages, "changes": changes, "results": results, "patch": patch, "removed": removed, "state_hash": digest(state)}
	if not Save.safe(entry): return "Unsupported data type in match history."
	var bytes := var_to_bytes(entry)
	if bytes.size() > MAX_RECORD: return "A single match-history record exceeds the 2 MiB limit."
	if offset + bytes.size() + 68 > COMPACT_TRIGGER_BYTES:
		var compact_error := _compact()
		if not compact_error.is_empty(): return compact_error
		return append(state, dice, kind)
	var error := DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(storage_directory))
	if error != OK: return error_string(error)
	var file := FileAccess.open(path(), FileAccess.READ_WRITE if FileAccess.file_exists(path()) else FileAccess.WRITE_READ)
	if file == null: return error_string(FileAccess.get_open_error())
	# Never append past an uncommitted or incomplete tail.
	var on_disk_length := file.get_length()
	if on_disk_length != offset:
		file.close()
		if on_disk_length < offset: return "History on disk is shorter than the confirmed prefix; restore a valid save backup before continuing."
		var recovery_error := restore(checkpoint(), observed)
		if not recovery_error.is_empty(): return "Could not recover the confirmed history prefix: " + recovery_error
		return append(state, dice, kind)
	file.seek(offset)
	file.store_32(bytes.size())
	var hash := bytes.hex_encode().sha256_text()
	file.store_buffer(hash.to_ascii_buffer())
	file.store_buffer(bytes)
	file.flush()
	error = file.get_error()
	var end := file.get_position()
	file.close()
	if error != OK: return error_string(error)
	entries.append(entry)
	offset = end
	tip = hash
	observed = state.duplicate(true)
	return ""

func _compact(retain_limit: int = MAX_RETAINED_ENTRIES) -> String:
	if entries.size() < 2: return "Match history cannot compact its current starting record."
	var source := FileAccess.open(path(), FileAccess.READ)
	if source == null: return "Match history is missing before compaction."
	var source_length := source.get_length()
	source.close()
	if source_length != offset: return "Match history changed before compaction."
	var new_id := Crypto.new().generate_random_bytes(32).hex_encode()
	var target_path := storage_directory.path_join(new_id + ".journal")
	var temporary_path := target_path + ".tmp"
	var retained := mini(maxi(0, retain_limit), entries.size() - 1)
	var compacted: Dictionary = {}
	while true:
		compacted = _write_compacted_file(temporary_path, retained)
		if not str(compacted.get("error", "")).is_empty():
			if FileAccess.file_exists(temporary_path): DirAccess.remove_absolute(ProjectSettings.globalize_path(temporary_path))
			return str(compacted.error)
		if int(compacted.get("offset", MAX_BYTES + 1)) <= COMPACT_TARGET_BYTES: break
		if retained == 0:
			DirAccess.remove_absolute(ProjectSettings.globalize_path(temporary_path))
			return "The current match state cannot fit in a compacted history record."
		retained = int(retained / 2)
	var error := DirAccess.rename_absolute(ProjectSettings.globalize_path(temporary_path), ProjectSettings.globalize_path(target_path))
	if error != OK:
		DirAccess.remove_absolute(ProjectSettings.globalize_path(temporary_path))
		return "Could not commit compacted match history: " + error_string(error)
	var previous_id := id
	id = new_id
	add_retired_id(previous_id)
	entries = compacted.get("entries", [])
	initial = compacted.get("initial", {}).duplicate(true)
	observed = compacted.get("observed", {}).duplicate(true)
	offset = int(compacted.offset)
	tip = str(compacted.tip)
	return ""

func _write_compacted_file(temporary_path: String, retained_count: int) -> Dictionary:
	var cutoff := maxi(0, entries.size() - retained_count)
	var reconstructed: Dictionary = {}
	for index in range(cutoff):
		if not _apply_entry_patch(reconstructed, entries[index]): return {"error": "Match history contains an invalid patch before compaction."}
	var checkpoint_state := reconstructed.duplicate(true)
	if digest(observed) != digest(_state_after_entries(entries)):
		return {"error": "Match history state changed before compaction."}
	var compacted_count := int(entries[0].get("compacted_entries", 0))
	if str(entries[0].get("kind", "")) == "checkpoint":
		compacted_count += maxi(0, cutoff - 1)
	else:
		compacted_count += cutoff
	var checkpoint_entry := {
		"version": 1,
		"sequence": 1,
		"previous": ZERO,
		"kind": "checkpoint",
		"utc": Time.get_datetime_string_from_system(true),
		"revision": checkpoint_state.get("revision", 0),
		"round": checkpoint_state.get("round", 0),
		"active": checkpoint_state.get("active", 1),
		"phase": checkpoint_state.get("phase", "movement"),
		"dice": [],
		"messages": [],
		"changes": [],
		"results": [],
		"patch": checkpoint_state,
		"removed": [],
		"state_hash": digest(checkpoint_state),
		"compacted_entries": compacted_count,
	}
	var file := FileAccess.open(temporary_path, FileAccess.WRITE)
	if file == null: return {"error": "Could not open compacted match history: " + error_string(FileAccess.get_open_error())}
	var new_entries: Array[Dictionary] = []
	var previous := ZERO
	var first_result := _write_compacted_record(file, checkpoint_entry, 1, previous)
	if not str(first_result.get("error", "")).is_empty():
		file.close()
		return {"error": str(first_result.error)}
	new_entries.append(first_result.entry)
	previous = str(first_result.hash)
	for index in range(cutoff, entries.size()):
		var original: Dictionary = entries[index]
		if not _apply_entry_patch(reconstructed, original):
			file.close()
			return {"error": "Match history contains an invalid retained patch."}
		var rewritten := original.duplicate(true)
		rewritten.state_hash = digest(reconstructed)
		var record_result := _write_compacted_record(file, rewritten, new_entries.size() + 1, previous)
		if not str(record_result.get("error", "")).is_empty():
			file.close()
			return {"error": str(record_result.error)}
		new_entries.append(record_result.entry)
		previous = str(record_result.hash)
	if digest(reconstructed) != digest(observed):
		file.close()
		return {"error": "Compacted history did not reproduce the current match state."}
	file.flush()
	var write_error := file.get_error()
	var end := file.get_position()
	file.close()
	if write_error != OK: return {"error": error_string(write_error)}
	return {"error": "", "entries": new_entries, "offset": end, "tip": previous, "initial": checkpoint_state, "observed": reconstructed}

func _write_compacted_record(file: FileAccess, entry: Dictionary, sequence: int, previous: String) -> Dictionary:
	var rewritten := entry.duplicate(true)
	rewritten.sequence = sequence
	rewritten.previous = previous
	if not Save.safe(rewritten): return {"error": "Unsupported data type in compacted match history."}
	var bytes := var_to_bytes(rewritten)
	if bytes.size() > MAX_RECORD: return {"error": "A compacted match-history record exceeds the 2 MiB limit."}
	var hash := bytes.hex_encode().sha256_text()
	file.store_32(bytes.size())
	file.store_buffer(hash.to_ascii_buffer())
	file.store_buffer(bytes)
	var error := file.get_error()
	if error != OK: return {"error": error_string(error)}
	return {"error": "", "entry": rewritten, "hash": hash}

func _state_after_entries(records: Array) -> Dictionary:
	var result: Dictionary = {}
	for entry: Variant in records:
		if not entry is Dictionary or not _apply_entry_patch(result, entry): return {}
	return result

func _apply_entry_patch(state: Dictionary, entry: Dictionary) -> bool:
	var patch_value: Variant = entry.get("patch", null)
	var removed_value: Variant = entry.get("removed", null)
	if not patch_value is Dictionary or not removed_value is Array: return false
	for key: Variant in removed_value: state.erase(key)
	for key: Variant in patch_value:
		var value: Variant = patch_value[key]
		state[key] = value.duplicate(true) if value is Dictionary or value is Array else value
	return true

func add_retired_id(retired_id: String) -> void:
	if valid_id(retired_id) and retired_id != id and retired_id not in retired_ids:
		retired_ids.append(retired_id)
		cleanup_pending = true

func prune_retired_files() -> void:
	if not cleanup_pending or retired_ids.is_empty(): return
	var referenced: Dictionary = {}
	for slot in range(1, Save.SLOT_COUNT + 1):
		for save_path: String in [Save.slot_path(slot), Save.backup_path(slot)]:
			if not FileAccess.file_exists(save_path): continue
			var saved := Save.read_snapshot_file(save_path)
			if saved.has("error"): return
			var reference_value: Variant = saved.get("journal", {})
			if not reference_value is Dictionary: return
			var reference_id := str(reference_value.get("id", ""))
			if not reference_id.is_empty():
				if not valid_id(reference_id): return
				referenced[reference_id] = true
	var directories: Array[String] = [storage_directory]
	for slot in range(1, Save.SLOT_COUNT + 1):
		var directory := Save.journal_directory(slot)
		if directory not in directories: directories.append(directory)
	var unslotted_directory := "user://matches/journals/unslotted"
	if unslotted_directory not in directories: directories.append(unslotted_directory)
	var remaining: Array[String] = []
	var cleanup_failed := false
	for retired_id: String in retired_ids:
		if retired_id == id or referenced.has(retired_id):
			remaining.append(retired_id)
			continue
		var failed_to_remove := false
		for directory: String in directories:
			var retired_path := directory.path_join(retired_id + ".journal")
			if not FileAccess.file_exists(retired_path): continue
			var error := DirAccess.remove_absolute(ProjectSettings.globalize_path(retired_path))
			if error != OK:
				failed_to_remove = true
				break
		if failed_to_remove:
			remaining.append(retired_id)
			cleanup_failed = true
	retired_ids = remaining
	cleanup_pending = cleanup_failed

func restore(reference: Dictionary, state: Dictionary) -> String:
	if reference.is_empty():
		reset(state)
		return ""
	if reference.get("version") != 1 or not valid_id(reference.get("id")) or not valid_id(reference.get("hash")): return "Invalid history reference."
	if not reference.get("count") is int or not reference.get("offset") is int or reference.count < 1 or reference.offset < 68 or reference.offset > MAX_BYTES: return "Invalid history limits."
	var retired_value: Variant = reference.get("retired_ids", [])
	if not retired_value is Array: return "Invalid history cleanup reference."
	var restored_retired_ids: Array[String] = []
	for value: Variant in retired_value:
		if not value is String or not valid_id(value): return "Invalid history cleanup identity."
		if value not in restored_retired_ids: restored_retired_ids.append(value)
	var source := storage_directory.path_join(reference.id + ".journal")
	var file := FileAccess.open(source, FileAccess.READ)
	if file == null or file.get_length() < reference.offset: return "Match history is missing or incomplete."
	var loaded: Array = []
	var previous := ZERO
	var reconstructed: Dictionary = {}
	var base_state: Dictionary = {}
	while file.get_position() < reference.offset:
		if reference.offset - file.get_position() < 68: return "Truncated history record."
		var size := file.get_32()
		var hash := file.get_buffer(64).get_string_from_ascii()
		if size < 4 or size > MAX_RECORD or file.get_position() + size > reference.offset: return "Invalid record size."
		var bytes := file.get_buffer(size)
		if bytes.hex_encode().sha256_text() != hash: return "History is corrupted."
		var entry: Variant = bytes_to_var(bytes)
		if not entry is Dictionary or not Save.safe(entry) or entry.get("version") != 1 or entry.get("sequence") != loaded.size() + 1 or entry.get("previous") != previous or not entry.get("patch") is Dictionary or not entry.get("removed") is Array: return "Invalid history sequence."
		for key in entry.removed: reconstructed.erase(key)
		for key in entry.patch: reconstructed[key] = entry.patch[key]
		if digest(reconstructed) != entry.get("state_hash"): return "Inconsistent history state."
		if loaded.is_empty(): base_state = reconstructed.duplicate(true)
		loaded.append(entry)
		previous = hash
	if loaded.size() != reference.count or previous != reference.hash or digest(reconstructed) != digest(state): return "History does not match the save."
	var has_tail: bool = file.get_length() != reference.offset
	file.seek(0)
	var prefix := file.get_buffer(reference.offset) if has_tail else PackedByteArray()
	if has_tail and prefix.size() != reference.offset:
		file.close()
		return "Could not copy the complete confirmed history prefix."
	file.close()
	var restored_id: String = reference.id
	if has_tail:
		# Preserve orphaned records in the original file. Continue only the prefix
		# committed by the save, in a new file; no truncation or replay of actions.
		restored_id = Crypto.new().generate_random_bytes(32).hex_encode()
		var continuation_path := storage_directory.path_join(restored_id + ".journal")
		var continuation_temporary_path := continuation_path + ".tmp"
		var branch := FileAccess.open(continuation_temporary_path, FileAccess.WRITE)
		if branch == null: return "Could not create the history continuation."
		branch.store_buffer(prefix)
		branch.flush()
		var branch_error := branch.get_error()
		branch.close()
		if branch_error != OK:
			DirAccess.remove_absolute(ProjectSettings.globalize_path(continuation_temporary_path))
			return "Could not write the history continuation: " + error_string(branch_error)
		var rename_error := DirAccess.rename_absolute(ProjectSettings.globalize_path(continuation_temporary_path), ProjectSettings.globalize_path(continuation_path))
		if rename_error != OK:
			DirAccess.remove_absolute(ProjectSettings.globalize_path(continuation_temporary_path))
			return "Could not commit the history continuation: " + error_string(rename_error)
	id = restored_id
	entries = loaded
	retired_ids = restored_retired_ids
	cleanup_pending = not retired_ids.is_empty()
	if has_tail: add_retired_id(str(reference.id))
	observed = state.duplicate(true)
	initial = base_state
	offset = reference.offset
	tip = previous
	pending_dice = []
	return ""

func page(start: int = -1) -> Dictionary:
	var first := maxi(0, entries.size() - 20) if start < 0 else clampi(start, 0, maxi(0, entries.size() - 1))
	var items: Array = []
	for index in range(first, mini(entries.size(), first + 20)):
		var entry: Dictionary = entries[index].duplicate(true)
		var patch: Dictionary = entry.get("patch", {})
		var attack: Dictionary = patch.get("last_attack", {})
		if not attack.is_empty():
			var summary := {"pools": [], "hazardous": {"total": int(attack.get("hazardous", {}).get("total", 0))}}
			var squads: Dictionary = patch.get("squads", observed.get("squads", {}))
			for pool: Dictionary in attack.get("pools", []):
				var target := int(pool.get("target_squad", -1))
				var public_pool := {"weapon_name": str(pool.get("weapon_name", "Weapon")), "target_name": str(squads.get(target, {}).get("name", "Defending unit"))}
				for key: String in ["attacks", "hits", "wounds", "damage_applied", "models_destroyed", "prevented_wounds", "excess_damage_discarded"]:
					public_pool[key] = int(pool.get(key, 0))
				summary.pools.append(public_pool)
			entry.attack_summary = summary
		entry.erase("patch")
		entry.erase("removed")
		items.append(entry)
	var compacted_entries := int(entries[0].get("compacted_entries", 0)) if not entries.is_empty() else 0
	return {"items": items, "total": entries.size(), "start": first, "compacted_entries": compacted_entries}
