extends SceneTree
const Download = preload("res://scripts/model_download.gd")
var failures := 0
var result: Dictionary = {}
const ROOT = "res://.tools/download-test"
func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1
func write(path: String, text: String) -> void:
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_string(text)
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var downloader := Download.new()
	root.add_child(downloader)
	downloader.finished.connect(func(value: Dictionary): result = value)
	check(not Download.plan({"kind": "CustomAssetbundle"}).error.is_empty(), "Unsupported bundles do not download")
	check(not Download.url_error("file:///private/file.obj").is_empty() and not Download.url_error("https://user:secret@example.com/model").is_empty(), "Non-HTTPS and credential URLs reject")
	var entry := {"kind": "CustomMesh", "references": {"MeshURL": "https://example.invalid/mesh", "DiffuseURL": "https://example.invalid/image"}}
	check(Download.plan(entry).jobs.size() == 2, "Explicit selection plans only mesh and diffuse")
	check(not downloader.start({"kind": "CustomMesh", "references": {}}, ROOT).is_empty() and not downloader.busy, "Missing mesh rejects before starting a request")
	DirAccess.make_dir_recursive_absolute(ROOT)
	var partial := ROOT.path_join("owned.part")
	write(partial, "temporary")
	downloader.jobs = [{"temporary": partial, "directory": ROOT, "kind": "mesh", "url": "https://example.invalid/mesh"}]
	downloader.busy = true
	downloader.cancel()
	check(result.get("cancelled", false) and not FileAccess.file_exists(partial) and not downloader.busy, "Cancellation removes only owned partial files and completes")
	var previous := result.duplicate(true)
	downloader._response(HTTPRequest.RESULT_SUCCESS, 200, [], [], downloader.generation - 1)
	check(result == previous, "Late callbacks after cancellation are ignored")
	write(partial, "<html>not a mesh</html>")
	downloader.jobs[0].temporary = partial
	downloader.busy = true
	downloader.position_index = 0
	await downloader._response(HTTPRequest.RESULT_SUCCESS, 404, [], [], downloader.generation)
	check("HTTP 404" in result.error and not FileAccess.file_exists(partial), "HTTP failures do not promote a download")
	write(partial, "<html>not a mesh</html>")
	downloader.busy = true
	downloader._complete_files()
	check("incompatible" in result.error and not FileAccess.file_exists(partial), "Invalid content rejects before permanent file promotion")
	write(partial, "v 0 0 0\nv 1 0 0\nv 0 2 0\nf 1 2 3\n")
	downloader.busy = true
	downloader._complete_files()
	check(result.error.is_empty() and FileAccess.file_exists(result.mesh) and result.texture.is_empty(), "Valid OBJ promotes to a content-versioned file")
	check(not FileAccess.file_exists(partial), "Completed download leaves no partial file")
	var permanent: String = result.mesh
	write(partial, "v 0 0 0\nv 1 0 0\nv 0 2 0\nf 1 2 3\n")
	downloader.busy = true
	downloader._complete_files()
	check(result.error.is_empty() and result.mesh == permanent, "Identical content reuses its local version without overwriting")
	var matched := Download.Assets.cache_match("https://example.invalid/mesh", Download.Assets.index_cache(ROOT))
	check(matched.status == "found" and matched.path == permanent, "Downloaded library files can be rediscovered without TTS")
	write(partial, "incomplete")
	downloader.busy = true
	await downloader._response(HTTPRequest.RESULT_BODY_SIZE_LIMIT_EXCEEDED, 200, [], [], downloader.generation)
	check(not result.error.is_empty() and not FileAccess.file_exists(partial), "Oversized transfer failure cleans its partial file")
	print("Model download checks: %d failures" % failures)
	quit(0 if failures == 0 else 1)
