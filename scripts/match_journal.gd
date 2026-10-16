extends RefCounted
## Append-only public state history. Reading reconstructs data; never executes rules.
const Save = preload("res://scripts/match_save.gd")
const DIRECTORY := "user://matches/journals"
const MAX_BYTES := 64 * 1024 * 1024
const MAX_RECORD := 2 * 1024 * 1024
const ZERO := "0000000000000000000000000000000000000000000000000000000000000000"
var id := ""
var entries: Array = []
var observed: Dictionary = {}
var offset := 0
var tip := ZERO
var initial: Dictionary = {}
var pending_dice: Array = []

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
	observed = {}
	initial = state.duplicate(true)
	offset = 0
	tip = ZERO
	pending_dice = []

func path() -> String:
	return DIRECTORY.path_join(id + ".journal")

func checkpoint() -> Dictionary:
	return {"version": 1, "id": id, "count": entries.size(), "offset": offset, "hash": tip}

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
	if bytes.size() > MAX_RECORD or offset + bytes.size() + 68 > MAX_BYTES: return "Match history file limit reached."
	var error := DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(DIRECTORY))
	if error != OK: return error_string(error)
	var file := FileAccess.open(path(), FileAccess.READ_WRITE if FileAccess.file_exists(path()) else FileAccess.WRITE_READ)
	if file == null: return error_string(FileAccess.get_open_error())
	# Never append past an uncommitted or incomplete tail.
	if file.get_length() != offset: return "History on disk changed; resume the save to create a safe continuation."
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

func restore(reference: Dictionary, state: Dictionary) -> String:
	if reference.is_empty():
		reset(state)
		return ""
	if reference.get("version") != 1 or not valid_id(reference.get("id")) or not valid_id(reference.get("hash")): return "Invalid history reference."
	if not reference.get("count") is int or not reference.get("offset") is int or reference.count < 1 or reference.offset < 68 or reference.offset > MAX_BYTES: return "Invalid history limits."
	var source := DIRECTORY.path_join(reference.id + ".journal")
	var file := FileAccess.open(source, FileAccess.READ)
	if file == null or file.get_length() < reference.offset: return "Match history is missing or incomplete."
	var loaded: Array = []
	var previous := ZERO
	var reconstructed: Dictionary = {}
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
		loaded.append(entry)
		previous = hash
	if loaded.size() != reference.count or previous != reference.hash or digest(reconstructed) != digest(state): return "History does not match the save."
	var has_tail: bool = file.get_length() != reference.offset
	file.seek(0)
	var prefix := file.get_buffer(reference.offset) if has_tail else PackedByteArray()
	file.close()
	var restored_id: String = reference.id
	if has_tail:
		# Preserve orphaned records in the original file. Continue only the prefix
		# committed by the save, in a new file; no truncation or replay of actions.
		restored_id = Crypto.new().generate_random_bytes(32).hex_encode()
		var branch := FileAccess.open(DIRECTORY.path_join(restored_id + ".journal"), FileAccess.WRITE)
		if branch == null: return "Could not create the history continuation."
		branch.store_buffer(prefix)
		branch.flush()
		if branch.get_error() != OK: return "Could not write the history continuation."
		branch.close()
	id = restored_id
	entries = loaded
	observed = state.duplicate(true)
	initial = state.duplicate(true)
	offset = reference.offset
	tip = previous
	pending_dice = []
	return ""

func page(start: int = -1) -> Dictionary:
	var first := maxi(0, entries.size() - 20) if start < 0 else clampi(start, 0, maxi(0, entries.size() - 1))
	var items: Array = []
	for index in range(first, mini(entries.size(), first + 20)):
		var entry: Dictionary = entries[index].duplicate(true)
		entry.erase("patch")
		entry.erase("removed")
		items.append(entry)
	return {"items": items, "total": entries.size(), "start": first}
