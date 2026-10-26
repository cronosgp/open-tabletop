extends SceneTree

const Reference = preload("res://scripts/ui/local_ability_reference.gd")
const UnitDatasheet = preload("res://scripts/ui/unit_datasheet.gd")

var failures := 0

func _initialize() -> void:
	call_deferred("run")

func check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error(message)

func run() -> void:
	var fixture_root := "user://local-ability-reference-test"
	_remove_tree(fixture_root)
	var project_root := fixture_root.path_join("project")
	var user_root := fixture_root.path_join("rules/wahapedia/11e/space-marines")
	_write_snapshot(project_root, "local-snapshot")
	var local := Reference.load_from_roots(fixture_root.path_join("empty-user"), project_root)
	check("project snapshot local-snapshot" in str(local.source), "The project-local reference is used when no external snapshot is installed")
	check(local.issue.is_empty() and local.sheets.has("hellblaster-squad"), "The project snapshot resolves a Space Marines identity")
	var local_abilities: Array = local.sheets.get("hellblaster-squad", [])
	check(local_abilities.size() == 2, "A shared ability row is resolved once and a local multiline row is retained")
	if local_abilities.size() == 2:
		check("• Choice — alpha" in str(local_abilities[0].text), "Shared ability text keeps list structure, entities and Unicode characters")
		check("continued line" in str(local_abilities[1].text), "A multiline source record stays inside its description field")
		check(local_abilities[1].type == "Datasheet" and local_abilities[1].parameter == "", "Ability type and empty parameter fields remain distinct")
	Reference.reset_cache_for_tests()
	Reference.sheets = local.sheets
	Reference.provenance = str(local.source)
	Reference.issue = ""
	Reference.loaded = true
	check("No ability entry matches" in str(Reference.for_identity("unknown-model").issue), "An unmatched identity produces an explicit issue")
	Reference.reset_cache_for_tests()

	_write_snapshot(user_root, "user-snapshot")
	var preferred := Reference.load_from_roots(user_root, project_root)
	check("user snapshot user-snapshot" in str(preferred.source), "A verified user snapshot takes precedence over the project source")
	check(preferred.issue.is_empty() and preferred.sheets.has("hellblaster-squad"), "The preferred external snapshot fully resolves its data")
	var file_user_root := fixture_root.path_join("user-root-is-file")
	var root_file := FileAccess.open(file_user_root, FileAccess.WRITE)
	root_file.store_string("not a directory")
	root_file.close()
	var invalid_root := Reference.load_from_roots(file_user_root, project_root)
	check(invalid_root.sheets.is_empty() and "not a folder" in str(invalid_root.issue), "An external source path that is a file fails explicitly without project fallback")
	var ordered_root := fixture_root.path_join("ordered-snapshots")
	_write_snapshot(ordered_root, "z-older", false, false, "2026-10-20T00:00:00Z")
	_write_snapshot(ordered_root, "a-newer", false, false, "2026-10-24T00:00:00Z")
	var newest := Reference.load_from_roots(fixture_root.path_join("no-user"), ordered_root)
	check("snapshot a-newer" in str(newest.source), "Multiple snapshots are selected by UTC retrieval time rather than folder-name order")
	var invalid_time_root := fixture_root.path_join("invalid-snapshot-time")
	_write_snapshot(invalid_time_root, "snapshot", false, false, "not-a-utc-time")
	var invalid_time := Reference.load_from_roots(fixture_root.path_join("no-user"), invalid_time_root)
	check(invalid_time.sheets.is_empty() and "valid utc retrieval time" in str(invalid_time.issue).to_lower(), "An invalid retrieval timestamp blocks source display")

	var external_file := user_root.path_join("user-snapshot/Abilities.csv")
	var tampered := FileAccess.open(external_file, FileAccess.WRITE)
	tampered.store_string("tampered after manifest\n")
	tampered.close()
	var invalid_external := Reference.load_from_roots(user_root, project_root)
	check(invalid_external.sheets.is_empty() and str(invalid_external.source).is_empty(), "An invalid external source does not expose partial data")
	check("integrity" in str(invalid_external.issue).to_lower() and "local-snapshot" not in str(invalid_external.issue), "An invalid external source reports an error without hiding behind project fallback")

	var malformed_root := fixture_root.path_join("malformed")
	_write_snapshot(malformed_root, "malformed-snapshot", true)
	var malformed := Reference.load_from_roots(fixture_root.path_join("no-user"), malformed_root)
	check(malformed.sheets.is_empty() and "wrong number of columns" in str(malformed.issue), "Malformed records fail the whole source load")

	var conflict_root := fixture_root.path_join("conflicting")
	_write_snapshot(conflict_root, "conflicting-snapshot", false, true)
	var conflicting := Reference.load_from_roots(fixture_root.path_join("no-user"), conflict_root)
	check(conflicting.sheets.is_empty() and "conflicting definitions" in str(conflicting.issue), "Conflicting shared ability IDs are explicit source errors")

	var absent := Reference.load_from_roots(fixture_root.path_join("no-user"), fixture_root.path_join("no-project"))
	check("not installed" in str(absent.issue).to_lower(), "An absent optional export explains why source text is unavailable")
	var inspector := UnitDatasheet.new()
	root.add_child(inspector)
	inspector.present({
		"name": "Intercessor Squad",
		"identity": "Model 1 · 2/2 wounds remaining",
		"attributes": [],
		"ranged": [],
		"melee": [],
		"ability_source_issue": absent.issue,
		"abilities": [{"name": "Implemented example", "text": "The supported match-profile effect."}],
	})
	var rendered := _label_text(inspector)
	check("not installed" in rendered.to_lower() and "IMPLEMENTED SCOPE" in rendered and "The supported match-profile effect." in rendered, "The inspector separates unavailable source text from implemented scope")
	inspector.queue_free()
	await process_frame
	_remove_tree(fixture_root)
	print("Local ability reference checks: %d failure(s)" % failures)
	quit(1 if failures > 0 else 0)

func _write_snapshot(root_path: String, snapshot_id: String, malformed: bool = false, conflict: bool = false, retrieved_at_utc: String = "2026-10-24T00:00:00Z") -> void:
	var folder := root_path.path_join(snapshot_id)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
	var datasheets := "id|faction_id|link|\n000000001|SM|https://wahapedia.ru/wh40k11ed/factions/space-marines/hellblaster-squad|\n"
	var relation_header := "datasheet_id|line|ability_id|model|name|description|type|parameter|\n"
	var shared_relation := "|".join(["000000001", "1", "000000010", "", "", "", "Datasheet", ""]) + "|\n"
	var multiline_relation := "000000001|2|000000011||Local drill|<p>Line one\ncontinued <b>line</b>|Datasheet||\n"
	var relations := relation_header + shared_relation
	if malformed:
		relations += "000000001|3|000000012||\n"
	else:
		relations += multiline_relation
	var shared_text := "<ul><li class=\"x\">Choice &mdash; alpha</li></ul>"
	var common := "id|name|legend|faction_id|description|\n"
	common += "000000010|Shared drill||SM|%s|\n" % shared_text
	common += "000000010|Shared drill||OTHER|%s|\n" % ("Conflicting definition" if conflict else shared_text)
	common += "000000011|Local drill|||A fallback definition|\n"
	var tables := {"Datasheets.csv": datasheets, "Datasheets_abilities.csv": relations, "Abilities.csv": common}
	var files: Array[Dictionary] = []
	for filename: String in tables:
		var path := folder.path_join(filename)
		var file := FileAccess.open(path, FileAccess.WRITE)
		file.store_string(str(tables[filename]))
		file.close()
		files.append({"filename": filename, "sha256": FileAccess.get_sha256(path)})
	var manifest := {
		"manifest_schema_version": 1,
		"provider": "wahapedia",
		"edition": "11e",
		"faction_context": "space-marines",
		"source_page": "https://wahapedia.ru/wh40k11ed/the-rules/data-export/",
		"snapshot_id": snapshot_id,
		"retrieved_at_utc": retrieved_at_utc,
		"specification_revision": "fixture-revision",
		"files": files,
	}
	var manifest_file := FileAccess.open(folder.path_join("manifest.json"), FileAccess.WRITE)
	manifest_file.store_string(JSON.stringify(manifest))
	manifest_file.close()

func _label_text(node: Node) -> String:
	var result := str(node.text) if node is Label else ""
	for child: Node in node.get_children():
		result += "\n" + _label_text(child)
	return result

func _remove_tree(path: String) -> void:
	var directory := DirAccess.open(path)
	if directory == null:
		return
	for filename: String in directory.get_files():
		DirAccess.remove_absolute(ProjectSettings.globalize_path(path.path_join(filename)))
	for dirname: String in directory.get_directories():
		_remove_tree(path.path_join(dirname))
	directory = null
	DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
