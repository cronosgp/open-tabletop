extends SceneTree
const CatalogDownload = preload("res://scripts/forceorg_catalog_download.gd")
var failures := 0
var last: Dictionary = {}
const DIR := "res://.tools/catalog-transfer"
func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1
func write(path: String, content: String) -> void:
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_string(content)
func _initialize() -> void: call_deferred("run")
func run() -> void:
	DirAccess.make_dir_recursive_absolute(DIR)
	var download := CatalogDownload.new()
	root.add_child(download)
	download.destination = DIR.path_join("ForceOrg.json")
	download.finished.connect(func(result: Dictionary): last = result)
	var path := DIR.path_join("transfer.part")
	write(download.destination, "original catalog")
	write(path, "<html>error</html>")
	download.busy = true
	await download._response(HTTPRequest.RESULT_SUCCESS, 200, [], [], download.generation, path)
	check(not last.error.is_empty() and FileAccess.get_file_as_string(download.destination) == "original catalog" and not FileAccess.file_exists(path), "Invalid catalog cannot replace the existing source")
	write(path, "missing")
	download.busy = true
	await download._response(HTTPRequest.RESULT_SUCCESS, 404, [], [], download.generation, path)
	check("HTTP 404" in last.error and not FileAccess.file_exists(path), "HTTP catalog failures report an actionable error and clean up")
	write(path, JSON.stringify({"ObjectStates": [{"Nickname": "Intercessor", "CustomMesh": {"MeshURL": "https://example.invalid/model"}}]}))
	download.busy = true
	await download._response(HTTPRequest.RESULT_SUCCESS, 200, [], [], download.generation, path)
	check(last.error.is_empty() and last.path == download.destination and not download.busy, "A valid catalog is promoted atomically")
	var contents := FileAccess.get_file_as_string(download.destination)
	var previous := last.duplicate(true)
	await download._response(HTTPRequest.RESULT_SUCCESS, 200, [], [], download.generation - 1, path)
	check(last == previous and FileAccess.get_file_as_string(download.destination) == contents, "A stale catalog callback cannot replace the active source")
	write(path, "partial")
	download.temporary = path
	download.busy = true
	download.cancel()
	check(not download.busy and not FileAccess.file_exists(path) and FileAccess.get_file_as_string(download.destination) == contents, "Catalog cancellation preserves the saved source")
	print("ForceOrg catalog download: %d failures" % failures)
	quit(0 if failures == 0 else 1)
