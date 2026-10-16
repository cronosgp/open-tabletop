extends RefCounted
const Roster = preload("res://scripts/army_roster.gd")
var path: String
var error := ""
var data: Dictionary

func _init(storage_path: String = "user://profiles/army-lists.json") -> void:
	path = storage_path
	data = {"schema_version": 1, "active": "local", "profiles": [{"id": "local", "name": "Local Player", "lists": []}]}
	if not FileAccess.file_exists(path): return
	var loaded := Roster.read_json(path)
	if not loaded.error.is_empty():
		error = loaded.error
		return
	error = validate_bank(loaded.data)
	if error.is_empty(): data = loaded.data

static func validate_bank(bank: Variant) -> String:
	if not bank is Dictionary or bank.get("schema_version") != 1 or not bank.get("active") is String or not bank.get("profiles") is Array: return "Incompatible profile format; file preserved."
	if bank.profiles.is_empty() or bank.profiles.size() > 30: return "Invalid profile count."
	var ids: Dictionary = {}
	for profile: Variant in bank.profiles:
		if not profile is Dictionary or not profile.get("id") is String or not profile.get("name") is String or not profile.get("lists") is Array: return "Invalid profile."
		if profile.id.is_empty() or ids.has(profile.id) or profile.name.is_empty() or profile.name.length() > 80 or profile.lists.size() > 200: return "Invalid profile identifier or size."
		ids[profile.id] = true
		var lists: Dictionary = {}
		for list: Variant in profile.lists:
			var issue := Roster.validate(list)
			if not issue.is_empty(): return issue
			if list.id.is_empty() or lists.has(list.id): return "Invalid list identifier."
			lists[list.id] = true
	return "" if ids.has(bank.active) else "Active profile is missing."

func active() -> Dictionary:
	for profile: Dictionary in data.profiles:
		if profile.id == data.active: return profile
	return {}

func commit(candidate: Dictionary) -> String:
	if not error.is_empty(): return error
	var issue := validate_bank(candidate)
	if not issue.is_empty(): return issue
	issue = Roster.write_json(path, candidate)
	if issue.is_empty(): data = candidate.duplicate(true)
	return issue

func create_profile(name: String) -> String:
	if name.strip_edges().is_empty() or name.length() > 80: return "Give the profile a name of up to 80 characters."
	var candidate := data.duplicate(true)
	var id := Crypto.new().generate_random_bytes(16).hex_encode()
	candidate.profiles.append({"id": id, "name": name.strip_edges(), "lists": []})
	candidate.active = id
	return commit(candidate)

func select_profile(id: String) -> String:
	var candidate := data.duplicate(true)
	candidate.active = id
	return commit(candidate)

func save_list(list: Dictionary) -> Dictionary:
	var issue := Roster.validate(list)
	if not issue.is_empty(): return {"error": issue}
	var saved := list.duplicate(true)
	if saved.id.is_empty(): saved.id = Crypto.new().generate_random_bytes(16).hex_encode()
	var candidate := data.duplicate(true)
	for profile: Dictionary in candidate.profiles:
		if profile.id != candidate.active: continue
		var found := false
		for index in range(profile.lists.size()):
			if profile.lists[index].id == saved.id:
				profile.lists[index] = saved
				found = true
		if not found: profile.lists.append(saved)
	issue = commit(candidate)
	return {"error": issue, "list": saved.duplicate(true)} if issue.is_empty() else {"error": issue}

func delete_list(id: String) -> String:
	var candidate := data.duplicate(true)
	for profile: Dictionary in candidate.profiles:
		if profile.id == candidate.active:
			profile.lists = profile.lists.filter(func(list: Dictionary): return list.id != id)
	return commit(candidate)
