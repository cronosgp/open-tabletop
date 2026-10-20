extends RefCounted
## A recorded local summary. Does not calculate or certify a winner.

const DIRECTORY := "user://matches/results"

static func build(state: Dictionary, checkpoint: Dictionary = {}) -> Dictionary:
	var winner := int(state.get("test_winner", 0))
	if winner not in [-1, 1, 2]: return {"error": "This match has no recorded final result."}
	var mission: Dictionary = state.get("mission", {})
	var record := {
		"schema_version": 1, "winner": winner,
		"scenario": str(mission.get("name", "Elimination exercise")),
		"round": int(state.get("round", 0)), "revision": int(state.get("revision", 0)),
		"pack_hash": str(state.get("pack_hash", "")),
		"history_id": str(checkpoint.get("id", "")),
		"scope": "Recorded experimental e11 result. Not a full rules or army-legality certificate.",
		"scores": {}, "armies": {"P1": [], "P2": []}
	}
	if state.get("rules_practice", false): record.scenario = "Synthetic rules lab"
	if mission.has("scores"):
		record.scores = {"P1": int(mission.scores.get(1, 0)), "P2": int(mission.scores.get(2, 0))}
	for squad: Dictionary in state.get("squads", {}).values():
		var owner := int(squad.get("owner", 0))
		if owner in [1, 2]: record.armies["P%d" % owner].append(str(squad.get("name", "Unit")))
	record.id = JSON.stringify(record).sha256_text()
	return record

static func text(record: Dictionary) -> String:
	if record.has("error"): return str(record.error)
	var outcome := "Draw" if record.winner == -1 else "Player %d wins" % record.winner
	var lines: Array[String] = ["Open Tabletop — recorded result", outcome, "%s · Round %d" % [record.scenario, record.round]]
	if not record.scores.is_empty(): lines.append("P1 %d VP · P2 %d VP" % [record.scores.P1, record.scores.P2])
	for owner: String in ["P1", "P2"]: lines.append(owner + ": " + ", ".join(record.armies[owner]))
	lines.append(record.scope)
	return "\n".join(lines)

static func save(record: Dictionary, directory: String = DIRECTORY) -> Dictionary:
	if record.has("error") or record.get("schema_version") != 1: return {"error": "No result is available to save."}
	var id := str(record.get("id", ""))
	if id.length() != 64 or not id.is_valid_hex_number(): return {"error": "Invalid result identifier."}
	var error := DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(directory))
	if error != OK: return {"error": "Could not create the local result directory (%d)." % error}
	var path := directory.path_join(id + ".json")
	if FileAccess.file_exists(path):
		if FileAccess.get_file_as_string(path) != JSON.stringify(record, "\t"): return {"error": "The existing result file differs. It was kept; this result could not be saved."}
		return {"error": "", "path": ProjectSettings.globalize_path(path)}
	var temporary := path + ".tmp"
	var file := FileAccess.open(temporary, FileAccess.WRITE)
	if file == null: return {"error": "Could not open the local result file."}
	file.store_string(JSON.stringify(record, "\t"))
	file.flush()
	error = file.get_error()
	file.close()
	if error != OK: return {"error": "Could not write the local result file (%d)." % error}
	error = DirAccess.rename_absolute(ProjectSettings.globalize_path(temporary), ProjectSettings.globalize_path(path))
	if error != OK: return {"error": "Could not finish saving the local result (%d)." % error}
	return {"error": "", "path": ProjectSettings.globalize_path(path)}
