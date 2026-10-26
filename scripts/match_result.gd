extends RefCounted
## A recorded local summary. Does not calculate or certify a winner.

const DIRECTORY := "user://matches/results"

static func build(state: Dictionary, checkpoint: Dictionary = {}) -> Dictionary:
	var winner := int(state.get("test_winner", 0))
	if winner not in [-1, 1, 2]: return {"error": "This match has no recorded final result."}
	var mission: Dictionary = state.get("mission", {})
	var record := {
		"schema_version": 3, "winner": winner,
		"scenario": str(mission.get("name", "Elimination exercise")),
		"round": int(state.get("round", 0)), "revision": int(state.get("revision", 0)),
		"pack_hash": str(state.get("pack_hash", "")),
		"history_id": str(checkpoint.get("id", "")),
		"scope": "Recorded experimental e11 result. Not a full rules or army-legality certificate.",
		"scores": {}, "mission_details": _mission_details(mission, state.get("events", [])), "armies": {"P1": [], "P2": []}
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
	var scores: Dictionary = record.get("scores", {})
	if not scores.is_empty(): lines.append("P1 %d VP · P2 %d VP" % [int(scores.get("P1", 0)), int(scores.get("P2", 0))])
	lines.append_array(_mission_lines(record.get("mission_details", {})))
	var armies: Dictionary = record.get("armies", {})
	for owner: String in ["P1", "P2"]:
		var names: Array[String] = []
		for unit_name: Variant in armies.get(owner, []): names.append(str(unit_name))
		lines.append(owner + ": " + ", ".join(names))
	lines.append(str(record.get("scope", "Recorded result.")))
	return "\n".join(lines)

static func details_text(record: Dictionary) -> String:
	var lines := _mission_lines(record.get("mission_details", {}))
	lines.append(str(record.get("scope", "Recorded result.")))
	lines.append("Pack: " + str(record.get("pack_hash", "")))
	lines.append("History: " + str(record.get("history_id", "")))
	return "\n".join(lines)

static func _mission_details(mission: Dictionary, match_events: Array = []) -> Dictionary:
	if not mission.has("scores") and not mission.has("objectives") and not mission.has("primary") and not mission.has("secondary"):
		return {}
	var result: Dictionary = {}
	for key: String in ["name", "primary_id", "primary_ids", "primary_names", "force_dispositions", "force_disposition_names", "primary_selection_mode", "secondary_pair_id", "deployment", "rounds", "points_per_objective"]:
		if mission.has(key): result[key] = mission[key]
	for category: String in ["primary", "secondary"]:
		var totals: Dictionary = mission.get(category, {})
		if not totals.is_empty(): result[category] = {"P1": int(totals.get(1, 0)), "P2": int(totals.get(2, 0))}
	var card_totals: Dictionary = mission.get("cards", {})
	var p1_cards: Dictionary = card_totals.get(1, {})
	var p2_cards: Dictionary = card_totals.get(2, {})
	var secondary_breakdown: Array[Dictionary] = []
	for card_id: String in mission.get("secondary_cards", []):
		secondary_breakdown.append({
			"name": _secondary_name(card_id),
			"P1": int(p1_cards.get(card_id, 0)),
			"P2": int(p2_cards.get(card_id, 0)),
		})
	if not secondary_breakdown.is_empty(): result["secondary_breakdown"] = secondary_breakdown
	var scoring_events := _recent_scoring_events(mission.get("log", []))
	if not scoring_events.is_empty(): result["recent_scoring_events"] = scoring_events
	if str(mission.get("id", "")) == "objective-training-v1":
		var training_round_events := _recent_training_round_events(match_events)
		if not training_round_events.is_empty(): result["training_round_events"] = training_round_events
	var objectives: Array[Dictionary] = []
	for objective: Dictionary in mission.get("objectives", []):
		var levels: Dictionary = objective.get("levels", {})
		objectives.append({
			"name": str(objective.get("name", "Objective")),
			"role": str(objective.get("role", "")),
			"controller": int(objective.get("controller", 0)),
			"secured": int(objective.get("secured", 0)),
			"p1_oc": int(levels.get(1, 0)),
			"p2_oc": int(levels.get(2, 0)),
		})
	if not objectives.is_empty(): result["objectives"] = objectives
	return result

static func _mission_lines(mission: Dictionary) -> Array[String]:
	var lines: Array[String] = []
	if mission.is_empty(): return lines
	var name := str(mission.get("name", ""))
	if not name.is_empty(): lines.append("Mission: " + name)
	if mission.has("primary"):
		var primary: Dictionary = mission.primary
		var primary_names: Dictionary = mission.get("primary_names", {})
		if not primary_names.is_empty():
			lines.append("Primary missions: P1 %s · P2 %s" % [str(primary_names.get(1, primary_names.get("1", "Primary"))), str(primary_names.get(2, primary_names.get("2", "Primary")))])
		var force_disposition_names: Dictionary = mission.get("force_disposition_names", {})
		if not force_disposition_names.is_empty():
			lines.append("Force Dispositions: P1 %s · P2 %s" % [str(force_disposition_names.get(1, force_disposition_names.get("1", "Unknown"))), str(force_disposition_names.get(2, force_disposition_names.get("2", "Unknown")))])
			lines.append("Primary cards were selected directly and may override the disposition matchup.")
		lines.append("Primary VP: P1 %d · P2 %d" % [int(primary.get("P1", 0)), int(primary.get("P2", 0))])
	if mission.has("secondary"):
		var secondary: Dictionary = mission.secondary
		lines.append("Secondary VP: P1 %d · P2 %d" % [int(secondary.get("P1", 0)), int(secondary.get("P2", 0))])
	var secondary_breakdown: Array = mission.get("secondary_breakdown", [])
	if not secondary_breakdown.is_empty():
		lines.append("Secondary card VP:")
		for card: Dictionary in secondary_breakdown:
			lines.append("%s: P1 %d · P2 %d VP" % [str(card.get("name", "Secondary")), int(card.get("P1", 0)), int(card.get("P2", 0))])
	var scoring_events: Array = mission.get("recent_scoring_events", [])
	if not scoring_events.is_empty():
		lines.append("Recent scoring events (newest first):")
		for event_text: String in scoring_events: lines.append("• " + event_text)
	var training_round_events: Array = mission.get("training_round_events", [])
	if not training_round_events.is_empty():
		lines.append("Recent objective-training round scores (newest first):")
		for event_text: String in training_round_events: lines.append("• " + event_text)
	if mission.has("points_per_objective"):
		lines.append("Custom objective scoring: %d VP per controlled objective at the end of a battle round." % int(mission.points_per_objective))
	var objectives: Array = mission.get("objectives", [])
	if not objectives.is_empty():
		lines.append("Final resolved objective control:")
		for objective: Dictionary in objectives:
			var controller := int(objective.get("controller", 0))
			var control_text := "Neutral" if controller == 0 else "Player %d" % controller
			var secured := int(objective.get("secured", 0))
			if secured in [1, 2]: control_text += " · Secured for Player %d" % secured
			var role := str(objective.get("role", ""))
			var label := str(objective.get("name", "Objective"))
			if not role.is_empty(): label += " (%s)" % role.capitalize()
			lines.append("%s: %s · P1 OC %d / P2 OC %d" % [label, control_text, int(objective.get("p1_oc", 0)), int(objective.get("p2_oc", 0))])
		lines.append("Control and OC are the recorded final phase values; the recorded winner still comes from the match result.")
	return lines

static func _secondary_name(card_id: String) -> String:
	match card_id:
		"engage-on-all-fronts": return "Engage on All Fronts"
		"assassination": return "Assassination"
		"bring-it-down": return "Bring It Down"
		"a-grievous-blow": return "A Grievous Blow"
		"secure-no-mans-land": return "Secure No Man's Land"
		"no-prisoners": return "No Prisoners"
		"behind-enemy-lines": return "Behind Enemy Lines"
		"centre-ground": return "Centre Ground"
		"display-of-might": return "Display of Might"
		"overwhelming-force": return "Overwhelming Force"
		"outflank": return "Outflank"
		"forward-position": return "Forward Position"
		"defend-stronghold": return "Defend Stronghold"
		"a-tempting-target": return "A Tempting Target"
		_: return card_id.replace("-", " ").capitalize()

static func _recent_scoring_events(mission_log: Array) -> Array[String]:
	var events: Array[String] = []
	for index in range(mission_log.size() - 1, -1, -1):
		var event_text := str(mission_log[index])
		if " VP" not in event_text: continue
		events.append(event_text)
		if events.size() >= 5: break
	return events

static func _recent_training_round_events(match_events: Array) -> Array[String]:
	var events: Array[String] = []
	for index in range(match_events.size() - 1, -1, -1):
		var event: Dictionary = match_events[index]
		var message := str(event.get("message", ""))
		if not message.begins_with("Training round "): continue
		events.append(message)
		if events.size() >= 5: break
	return events

static func saved_records(directory: String = DIRECTORY) -> Array[Dictionary]:
	var report := saved_records_report(directory)
	var entries: Array[Dictionary] = []
	var scanned_records: Variant = report.get("records", [])
	if typeof(scanned_records) != TYPE_ARRAY: return entries
	for entry: Variant in scanned_records:
		if typeof(entry) == TYPE_DICTIONARY: entries.append(entry)
	return entries

static func saved_records_report(directory: String = DIRECTORY) -> Dictionary:
	var entries: Array[Dictionary] = []
	var source := DirAccess.open(directory)
	if source == null:
		var absolute_directory := ProjectSettings.globalize_path(directory)
		return {
			"records": entries,
			"json_files": 0,
			"ignored_files": 0,
			"unreadable": DirAccess.dir_exists_absolute(absolute_directory) or FileAccess.file_exists(absolute_directory),
		}
	var json_files := 0
	var ignored_files := 0
	var invalid_files: Array[Dictionary] = []
	for filename: String in source.get_files():
		if filename.get_extension().to_lower() != "json": continue
		json_files += 1
		var path := directory.path_join(filename)
		var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
		var issue := _saved_record_issue(parsed, filename)
		if not issue.is_empty():
			ignored_files += 1
			invalid_files.append({"filename": filename, "reason": issue})
			continue
		entries.append({"record": parsed, "saved_at": FileAccess.get_modified_time(path)})
	entries.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		var a_time := int(a.get("saved_at", 0))
		var b_time := int(b.get("saved_at", 0))
		if a_time == b_time: return str(a.record.id) > str(b.record.id)
		return a_time > b_time
	)
	return {"records": entries, "json_files": json_files, "ignored_files": ignored_files, "invalid_files": invalid_files, "unreadable": false}

static func _valid_saved_record(value: Variant, filename: String) -> bool:
	return _saved_record_issue(value, filename).is_empty()

static func _saved_record_issue(value: Variant, filename: String) -> String:
	if typeof(value) != TYPE_DICTIONARY: return "This file is not a result object."
	var record: Dictionary = value
	var version: Variant = record.get("schema_version", 0)
	if not _is_integer_number(version) or int(version) not in [1, 2, 3]: return "Unsupported result format."
	var id: Variant = record.get("id", "")
	if typeof(id) != TYPE_STRING or id != filename.get_basename() or str(id).length() != 64 or not str(id).is_valid_hex_number(): return "The filename does not match a valid result ID."
	if int(version) in [1, 3] and not _content_identity_matches(record): return "The saved contents do not match this result's SHA-256 ID."
	if not _is_integer_number(record.get("winner", null)) or int(record.winner) not in [-1, 1, 2]: return "The result has a missing or invalid winner."
	if typeof(record.get("scenario", null)) != TYPE_STRING or not _is_integer_number(record.get("round", null)): return "The result is missing its scenario or round."
	if typeof(record.get("scope", null)) != TYPE_STRING: return "The result is missing its scope label."
	var scores: Variant = record.get("scores", {})
	var armies: Variant = record.get("armies", {})
	var mission_details: Variant = record.get("mission_details", {})
	if typeof(scores) != TYPE_DICTIONARY or typeof(armies) != TYPE_DICTIONARY or typeof(mission_details) != TYPE_DICTIONARY: return "The result summary has malformed score, army or mission data."
	for owner: String in ["P1", "P2"]:
		var army: Variant = armies.get(owner, null)
		if typeof(army) != TYPE_ARRAY: return "The result has a malformed army summary."
		for unit_name: Variant in army:
			if typeof(unit_name) != TYPE_STRING: return "The result has a malformed army summary."
		if not scores.is_empty() and not _is_integer_number(scores.get(owner, null)): return "The result has malformed victory-point totals."
	for key: String in ["primary", "secondary"]:
		if mission_details.has(key) and typeof(mission_details[key]) != TYPE_DICTIONARY: return "The result has malformed mission totals."
	for key: String in ["secondary_breakdown", "objectives"]:
		if not mission_details.has(key): continue
		if typeof(mission_details[key]) != TYPE_ARRAY: return "The result has malformed objective details."
		for entry: Variant in mission_details[key]:
			if typeof(entry) != TYPE_DICTIONARY: return "The result has malformed objective details."
	for key: String in ["recent_scoring_events", "training_round_events"]:
		if not mission_details.has(key): continue
		if typeof(mission_details[key]) != TYPE_ARRAY: return "The result has malformed scoring history."
		for entry: Variant in mission_details[key]:
			if typeof(entry) != TYPE_STRING: return "The result has malformed scoring history."
	return ""

static func _content_identity_matches(record: Dictionary) -> bool:
	var identity := str(record.get("id", ""))
	var content := record.duplicate(true)
	content.erase("id")
	return identity.length() == 64 and JSON.stringify(_normalize_identity_numbers(content)).sha256_text() == identity

static func _normalize_identity_numbers(value: Variant) -> Variant:
	if typeof(value) == TYPE_FLOAT and _is_integer_number(value): return int(value)
	if typeof(value) == TYPE_DICTIONARY:
		var normalized: Dictionary = {}
		for key: Variant in value:
			normalized[key] = _normalize_identity_numbers(value[key])
		return normalized
	if typeof(value) == TYPE_ARRAY:
		var normalized: Array = []
		for entry: Variant in value:
			normalized.append(_normalize_identity_numbers(entry))
		return normalized
	return value

static func _is_integer_number(value: Variant) -> bool:
	if typeof(value) == TYPE_INT: return true
	if typeof(value) != TYPE_FLOAT: return false
	return float(value) == floor(float(value))

static func save(record: Dictionary, directory: String = DIRECTORY) -> Dictionary:
	if record.has("error") or record.get("schema_version") != 3: return {"error": "No result is available to save."}
	var id := str(record.get("id", ""))
	if id.length() != 64 or not id.is_valid_hex_number(): return {"error": "Invalid result identifier."}
	if not _content_identity_matches(record): return {"error": "The result contents do not match their identifier."}
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
