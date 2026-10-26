extends RefCounted
## Optional read-only Wahapedia e11 text. The source is never bundled in the game.

const PROJECT_ROOT := "res://.tools/wahapedia/11e/space-marines"
const USER_ROOT := "user://rules/wahapedia/11e/space-marines"
const SOURCE_PAGE := "https://wahapedia.ru/wh40k11ed/the-rules/data-export/"
const SPACE_MARINES_DATASHEET_PREFIX := "https://wahapedia.ru/wh40k11ed/factions/space-marines/"
const REQUIRED_FILES := ["Datasheets.csv", "Datasheets_abilities.csv", "Abilities.csv"]
const REQUIRED_COLUMNS := {
	"Datasheets.csv": ["id", "faction_id", "link"],
	"Datasheets_abilities.csv": ["datasheet_id", "line", "ability_id", "model", "name", "description", "type", "parameter"],
	"Abilities.csv": ["id", "name", "description", "faction_id"],
}
const HTML_ENTITIES := {
	"&nbsp;": " ", "&#39;": "'", "&rsquo;": "’", "&lsquo;": "‘",
	"&rdquo;": "”", "&ldquo;": "“", "&ndash;": "–", "&mdash;": "—",
	"&hellip;": "…", "&bull;": "•", "&times;": "×",
}

static var loaded := false
static var sheets: Dictionary = {}
static var provenance := ""
static var warning := ""
static var issue := "Optional Wahapedia 11e reference text is not installed. Implemented scope remains available."
static var _block_breaks: RegEx
static var _list_items: RegEx
static var _tags: RegEx
static var _checksum_pattern: RegEx
static var _html_entity_pattern: RegEx
static var _datasheet_identity_pattern: RegEx
static var _snapshot_id_pattern: RegEx
static var _utc_timestamp_pattern: RegEx


static func for_identity(identity: String) -> Dictionary:
	if not loaded:
		_load_snapshot()
	var key := identity.strip_edges().to_lower()
	var abilities: Array = sheets.get(key, [])
	var message := issue
	if message.is_empty() and abilities.is_empty():
		if sheets.has(key):
			message = "No ability entries are listed for this datasheet in the verified local 11e export."
		else:
			message = "No ability entry matches this model in the verified local 11e export."
	var snapshot_complete := loaded and issue.is_empty() and warning.is_empty()
	return {"abilities": abilities.duplicate(true), "source": provenance, "warning": warning, "snapshot_complete": snapshot_complete, "issue": message}


## Exposed for deterministic local tests. Invalid external data never falls back
## to a project copy, because that would hide the user's broken installation.
static func load_from_roots(user_root: String, project_root: String) -> Dictionary:
	var external := _latest_snapshot(user_root, "user")
	if external.has("error"):
		return _failure(str(external.error))
	if not external.is_empty():
		return _read_snapshot(str(external.path), str(external.snapshot_id), "user")
	var bundled := _latest_snapshot(project_root, "project")
	if bundled.has("error"):
		return _failure(str(bundled.error))
	if not bundled.is_empty():
		return _read_snapshot(str(bundled.path), str(bundled.snapshot_id), "project")
	return {
		"sheets": {},
		"source": "",
		"warning": "",
		"snapshot_complete": false,
		"issue": "Optional Wahapedia 11e reference text is not installed. Implemented scope remains available.",
	}


static func reset_cache_for_tests() -> void:
	_clear_cache()


static func _clear_cache() -> void:
	loaded = false
	sheets.clear()
	provenance = ""
	warning = ""
	issue = "Optional Wahapedia 11e reference text is not installed. Implemented scope remains available."


static func reload() -> void:
	_clear_cache()
	_load_snapshot()


static func _load_snapshot() -> void:
	var result := load_from_roots(USER_ROOT, PROJECT_ROOT)
	sheets = result.get("sheets", {})
	provenance = str(result.get("source", ""))
	warning = str(result.get("warning", ""))
	issue = str(result.get("issue", ""))
	loaded = true


static func _latest_snapshot(root: String, origin: String) -> Dictionary:
	var directory := DirAccess.open(root)
	if directory == null:
		var absolute_root := ProjectSettings.globalize_path(root)
		if DirAccess.dir_exists_absolute(absolute_root):
			return {"error": "The %s Wahapedia reference folder exists but cannot be opened." % origin}
		if FileAccess.file_exists(root):
			return {"error": "The %s Wahapedia reference path exists but is not a folder." % origin}
		return {}
	var candidates := directory.get_directories()
	if candidates.is_empty():
		var files := directory.get_files()
		if not files.is_empty():
			return {"error": "The %s Wahapedia reference folder contains files but no <snapshot-id> subfolder." % origin}
		return {}
	var timestamp_ids := true
	for candidate_id: String in candidates:
		if _has_timestamp_snapshot_id_shape(candidate_id) and not _is_timestamp_snapshot_id(candidate_id):
			return {"error": "The %s Wahapedia reference folder contains an invalid UTC timestamp snapshot identity." % origin}
		if not _is_timestamp_snapshot_id(candidate_id): timestamp_ids = false
	var snapshot_id := ""
	if timestamp_ids:
		candidates.sort()
		snapshot_id = candidates[-1]
	else:
		var newest_timestamp := ""
		for candidate_id: String in candidates:
			var manifest_path := root.path_join(candidate_id).path_join("manifest.json")
			if not FileAccess.file_exists(manifest_path):
				return {"error": "The newest %s Wahapedia snapshot cannot be determined because a snapshot manifest is missing." % origin}
			var manifest_value: Variant = JSON.parse_string(FileAccess.get_file_as_string(manifest_path))
			if not manifest_value is Dictionary:
				return {"error": "The newest %s Wahapedia snapshot cannot be determined because a snapshot manifest is unreadable." % origin}
			var retrieved_at := str(manifest_value.get("retrieved_at_utc", ""))
			if not _is_utc_timestamp(retrieved_at):
				return {"error": "The newest %s Wahapedia snapshot cannot be determined because a manifest has no valid UTC retrieval time." % origin}
			if retrieved_at > newest_timestamp or (retrieved_at == newest_timestamp and candidate_id > snapshot_id):
				newest_timestamp = retrieved_at
				snapshot_id = candidate_id
	return {"snapshot_id": snapshot_id, "path": root.path_join(snapshot_id)}


static func _has_timestamp_snapshot_id_shape(value: String) -> bool:
	if _snapshot_id_pattern == null:
		_snapshot_id_pattern = RegEx.new()
		_snapshot_id_pattern.compile("^[0-9]{8}T[0-9]{6}Z$")
	return _snapshot_id_pattern.search(value) != null


static func _is_timestamp_snapshot_id(value: String) -> bool:
	if not _has_timestamp_snapshot_id_shape(value): return false
	var timestamp := "%s-%s-%sT%s:%s:%sZ" % [value.substr(0, 4), value.substr(4, 2), value.substr(6, 2), value.substr(9, 2), value.substr(11, 2), value.substr(13, 2)]
	return _is_utc_timestamp(timestamp)


static func _is_utc_timestamp(value: String) -> bool:
	if _utc_timestamp_pattern == null:
		_utc_timestamp_pattern = RegEx.new()
		_utc_timestamp_pattern.compile("^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z$")
	if _utc_timestamp_pattern.search(value) == null: return false
	var year := int(value.substr(0, 4))
	var month := int(value.substr(5, 2))
	var day := int(value.substr(8, 2))
	var hour := int(value.substr(11, 2))
	var minute := int(value.substr(14, 2))
	var second := int(value.substr(17, 2))
	if year < 1 or month < 1 or month > 12 or hour > 23 or minute > 59 or second > 59: return false
	var days_in_month: Array[int] = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
	var leap_year := year % 400 == 0 or (year % 4 == 0 and year % 100 != 0)
	if month == 2 and leap_year: days_in_month[1] = 29
	return day >= 1 and day <= days_in_month[month - 1]


static func _read_snapshot(folder: String, expected_id: String, origin: String) -> Dictionary:
	var manifest_path := folder.path_join("manifest.json")
	if not FileAccess.file_exists(manifest_path):
		return _failure("The %s Wahapedia 11e snapshot has no manifest.json." % origin)
	var manifest_value: Variant = JSON.parse_string(FileAccess.get_file_as_string(manifest_path))
	if not manifest_value is Dictionary:
		return _failure("The %s Wahapedia 11e snapshot manifest is unreadable." % origin)
	var manifest: Dictionary = manifest_value
	if int(manifest.get("manifest_schema_version", -1)) != 1:
		return _failure("The %s Wahapedia 11e snapshot uses an unsupported manifest schema." % origin)
	if str(manifest.get("provider", "")) != "wahapedia" or str(manifest.get("edition", "")) != "11e":
		return _failure("The %s snapshot is not a Wahapedia 11th-edition export." % origin)
	if str(manifest.get("faction_context", "")) != "space-marines":
		return _failure("The %s snapshot is not scoped to Space Marines." % origin)
	if str(manifest.get("source_page", "")) != SOURCE_PAGE:
		return _failure("The %s snapshot names an unexpected Wahapedia source page." % origin)
	if str(manifest.get("snapshot_id", "")) != expected_id:
		return _failure("The %s snapshot folder and manifest identities do not match." % origin)
	if not _is_utc_timestamp(str(manifest.get("retrieved_at_utc", ""))) or str(manifest.get("specification_revision", "")).is_empty():
		return _failure("The %s snapshot does not record a valid UTC retrieval time and export revision." % origin)

	var files_value: Variant = manifest.get("files", null)
	if not files_value is Array:
		return _failure("The %s snapshot manifest has no file-integrity list." % origin)
	var hashes: Dictionary = {}
	for value: Variant in files_value:
		if not value is Dictionary:
			return _failure("The %s snapshot manifest contains an invalid file entry." % origin)
		var entry: Dictionary = value
		var filename := str(entry.get("filename", ""))
		var expected_hash := str(entry.get("sha256", "")).to_lower()
		if filename.is_empty() or filename in [".", "..", "manifest.json"] or filename.get_file() != filename or "/" in filename or "\\" in filename:
			return _failure("The %s snapshot manifest contains an unsafe filename." % origin)
		if hashes.has(filename):
			return _failure("The %s snapshot manifest repeats a file entry." % origin)
		if _valid_sha256(expected_hash) == false:
			return _failure("The %s snapshot manifest has an invalid SHA-256 entry." % origin)
		hashes[filename] = expected_hash
	for filename: String in REQUIRED_FILES:
		if not hashes.has(filename):
			return _failure("The %s snapshot does not record %s." % [origin, filename])
	for filename: String in hashes:
		var path := folder.path_join(filename)
		if not FileAccess.file_exists(path):
			return _failure("The %s Wahapedia snapshot is missing %s, which is listed in its manifest." % [origin, filename])
		if FileAccess.get_sha256(path).to_lower() != str(hashes[filename]):
			return _failure("The %s Wahapedia snapshot failed its SHA-256 integrity check for %s." % [origin, filename])

	var datasheets_result := _parse_table(folder.path_join("Datasheets.csv"), REQUIRED_COLUMNS["Datasheets.csv"])
	if not str(datasheets_result.error).is_empty():
		return _failure("The %s Datasheets.csv could not be read: %s" % [origin, datasheets_result.error])
	var relations_result := _parse_table(folder.path_join("Datasheets_abilities.csv"), REQUIRED_COLUMNS["Datasheets_abilities.csv"])
	if not str(relations_result.error).is_empty():
		return _failure("The %s Datasheets_abilities.csv could not be read: %s" % [origin, relations_result.error])
	var shared_result := _parse_table(folder.path_join("Abilities.csv"), REQUIRED_COLUMNS["Abilities.csv"])
	if not str(shared_result.error).is_empty():
		return _failure("The %s Abilities.csv could not be read: %s" % [origin, shared_result.error])

	var all_datasheet_ids: Dictionary = {}
	var marine_identities: Dictionary = {}
	var marine_identity_ids: Dictionary = {}
	for row: Dictionary in datasheets_result.rows:
		var datasheet_id := str(row.get("id", ""))
		if datasheet_id.is_empty() or all_datasheet_ids.has(datasheet_id):
			return _failure("The %s datasheet table contains an empty or duplicate identity." % origin)
		all_datasheet_ids[datasheet_id] = true
		if str(row.get("faction_id", "")) != "SM":
			continue
		var identity := _identity_from_link(str(row.get("link", "")))
		if identity.is_empty():
			return _failure("The %s Space Marines datasheet %s has no usable identity link at the canonical Wahapedia 11e route." % [origin, datasheet_id])
		if marine_identity_ids.has(identity):
			return _failure("The %s Space Marines export maps more than one datasheet to the same identity." % origin)
		marine_identities[datasheet_id] = identity
		marine_identity_ids[identity] = true

	var shared: Dictionary = {}
	for row: Dictionary in shared_result.rows:
		var ability_id := str(row.get("id", ""))
		if ability_id.is_empty():
			return _failure("The %s shared ability table contains an empty identity." % origin)
		if shared.has(ability_id):
			var previous: Dictionary = shared[ability_id]
			if str(previous.get("name", "")) != str(row.get("name", "")) or str(previous.get("description", "")) != str(row.get("description", "")):
				return _failure("The %s export contains conflicting definitions for a shared ability identity." % origin)
		else:
			shared[ability_id] = row

	var resolved: Dictionary = {}
	var orphan_relations: Array[String] = []
	for identity: String in marine_identity_ids:
		resolved[identity] = []
	for relation_index in range(relations_result.rows.size()):
		var row: Dictionary = relations_result.rows[relation_index]
		var datasheet_id := str(row.get("datasheet_id", ""))
		if datasheet_id.is_empty():
			return _failure("The %s ability relation record %d has no datasheet identity." % [origin, relation_index + 1])
		if not all_datasheet_ids.has(datasheet_id):
			orphan_relations.append("record %d references %s" % [relation_index + 1, datasheet_id])
			continue
		if not marine_identities.has(datasheet_id):
			continue
		var ability_id := str(row.get("ability_id", ""))
		var common: Dictionary = shared.get(ability_id, {}) if not ability_id.is_empty() else {}
		var name := str(row.get("name", ""))
		if name.is_empty():
			name = str(common.get("name", ""))
		var description := str(row.get("description", ""))
		if description.is_empty():
			description = str(common.get("description", ""))
		var plain_name := _plain(name)
		var plain_description := _plain(description)
		var plain_type := _plain(str(row.get("type", "")))
		var plain_model := _plain(str(row.get("model", "")))
		var plain_parameter := _plain(str(row.get("parameter", "")))
		for displayed_value: String in [plain_name, plain_description, plain_type, plain_model, plain_parameter]:
			if _has_unresolved_html_entity(displayed_value):
				return _failure("The %s ability relation record %d for datasheet %s contains an unsupported HTML entity." % [origin, relation_index + 1, datasheet_id])
		if plain_name.is_empty() or plain_description.is_empty():
			return _failure("The %s export has an unresolved Space Marines ability name or description." % origin)
		var identity: String = marine_identities[datasheet_id]
		if not resolved.has(identity):
			resolved[identity] = []
		resolved[identity].append({
			"name": plain_name,
			"text": plain_description,
			"type": plain_type,
			"model": plain_model,
			"parameter": plain_parameter,
		})

	var revision := str(manifest.get("specification_revision", ""))
	var source := "Wahapedia 11e · %s snapshot %s · retrieved %s · export revision %s" % ["user" if origin == "user" else "project", expected_id, str(manifest.get("retrieved_at_utc", "unknown")), revision]
	var warning := ""
	if not orphan_relations.is_empty():
		var examples: Array[String] = []
		for index in range(min(3, orphan_relations.size())):
			examples.append(orphan_relations[index])
		var additional := orphan_relations.size() - examples.size()
		var suffix := " and %d more" % additional if additional > 0 else ""
		var relation_word := "relation" if orphan_relations.size() == 1 else "relations"
		var verb := "points" if orphan_relations.size() == 1 else "point"
		warning = "Incomplete export: %d ability %s %s to datasheet IDs missing from Datasheets.csv. Skipped %s%s. The entries below may omit abilities." % [orphan_relations.size(), relation_word, verb, "; ".join(examples), suffix]
	return {"sheets": resolved, "source": source, "warning": warning, "snapshot_complete": orphan_relations.is_empty(), "issue": ""}


static func _parse_table(path: String, required_columns: Array) -> Dictionary:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {"rows": [], "error": "file could not be opened"}
	var text := file.get_as_text().replace("\r\n", "\n").replace("\r", "\n")
	file.close()
	var lines := text.split("\n", true)
	if lines.is_empty() or str(lines[0]).is_empty():
		return {"rows": [], "error": "header is empty"}
	var columns := _split_pipe(str(lines[0]).trim_prefix("\ufeff"))
	var trailing_column := not columns.is_empty() and columns[-1].is_empty()
	if trailing_column:
		columns.pop_back()
	if columns.is_empty():
		return {"rows": [], "error": "header has no columns"}
	var known_columns: Dictionary = {}
	for column: String in columns:
		if column.is_empty() or known_columns.has(column):
			return {"rows": [], "error": "header has an empty or duplicate column"}
		known_columns[column] = true
	for required: Variant in required_columns:
		if not known_columns.has(str(required)):
			return {"rows": [], "error": "header is missing a required column"}

	var rows: Array[Dictionary] = []
	var pending: Array[String] = []
	var expected_width := columns.size() + (1 if trailing_column else 0)
	for line_index in range(1, lines.size()):
		var cells := _split_pipe(str(lines[line_index]))
		var empty_line := true
		for cell: String in cells:
			if not cell.is_empty():
				empty_line = false
				break
		# Empty physical lines outside a record are padding; within a pending
		# multiline cell they are source content and must remain intact.
		if empty_line and pending.is_empty():
			continue
		if not pending.is_empty():
			pending[-1] += "\n" + cells[0]
			for cell_index in range(1, cells.size()):
				pending.append(cells[cell_index])
			cells = pending.duplicate()
		if cells.size() < expected_width and not str(cells[-1]).is_empty():
			pending = cells.duplicate()
			continue
		pending.clear()
		if trailing_column:
			if cells.is_empty() or not cells[-1].is_empty():
				return {"rows": [], "error": "record has a malformed trailing delimiter at line %d" % [line_index + 1]}
			cells.pop_back()
		if cells.size() != columns.size():
			return {"rows": [], "error": "record has the wrong number of columns at line %d" % [line_index + 1]}
		if str(cells[0]).is_empty():
			return {"rows": [], "error": "record has an empty identity at line %d" % [line_index + 1]}
		var row: Dictionary = {}
		for column_index in range(columns.size()):
			row[columns[column_index]] = cells[column_index]
		rows.append(row)
	if not pending.is_empty():
		return {"rows": [], "error": "the last record is incomplete"}
	if rows.is_empty():
		return {"rows": [], "error": "table has no records"}
	return {"rows": rows, "error": ""}


static func _split_pipe(line: String) -> Array[String]:
	var cells: Array[String] = []
	for cell: String in line.split("|", true):
		cells.append(cell)
	return cells


static func _identity_from_link(link: String) -> String:
	var clean := link.strip_edges()
	if not clean.begins_with(SPACE_MARINES_DATASHEET_PREFIX): return ""
	var slug := clean.trim_prefix(SPACE_MARINES_DATASHEET_PREFIX).split("?", true, 1)[0].split("#", true, 1)[0].trim_suffix("/")
	if slug.is_empty() or "/" in slug or "\\" in slug: return ""
	if _datasheet_identity_pattern == null:
		_datasheet_identity_pattern = RegEx.new()
		_datasheet_identity_pattern.compile("^[A-Za-z0-9][A-Za-z0-9_-]*$")
	if _datasheet_identity_pattern.search(slug) == null: return ""
	return slug.to_lower()


static func _valid_sha256(value: String) -> bool:
	if _checksum_pattern == null:
		_checksum_pattern = RegEx.new()
		_checksum_pattern.compile("^[0-9a-f]{64}$")
	return _checksum_pattern.search(value) != null


static func _has_unresolved_html_entity(value: String) -> bool:
	if _html_entity_pattern == null:
		_html_entity_pattern = RegEx.new()
		_html_entity_pattern.compile("&(?:[A-Za-z][A-Za-z0-9]*|#[^;\\s]+);")
	return _html_entity_pattern.search(value) != null


static func _plain(html: String) -> String:
	if _block_breaks == null:
		_block_breaks = RegEx.new()
		_block_breaks.compile("(?i)<br\\b[^>]*>|</p>|</div>|</h[1-6]>|</tr>|</ul>|</ol>")
		_list_items = RegEx.new()
		_list_items.compile("(?i)<li\\b[^>]*>")
		_tags = RegEx.new()
		_tags.compile("<[^>]*>")
	var text := _block_breaks.sub(html, "\n", true)
	text = _list_items.sub(text, "• ", true)
	text = text.replace("</li>", "\n").replace("</td>", " ")
	text = _tags.sub(text, "", true).xml_unescape()
	for entity: String in HTML_ENTITIES:
		text = text.replace(entity, str(HTML_ENTITIES[entity]))
	return text.strip_edges()


static func _failure(message: String) -> Dictionary:
	return {"sheets": {}, "source": "", "warning": "", "snapshot_complete": false, "issue": message}
