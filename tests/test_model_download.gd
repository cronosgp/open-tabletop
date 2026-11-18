extends SceneTree
const Download = preload("res://scripts/model_download.gd")
var failures := 0
var result: Dictionary = {}
var conversion_failure: Dictionary = {}
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
	var shutdown_partial := ROOT.path_join("interrupted-owned.part")
	var shutdown_conversion := ROOT.path_join("interrupted-conversion")
	var shutdown_result := ROOT.path_join("interrupted-conversion.result.json")
	DirAccess.make_dir_recursive_absolute(shutdown_conversion)
	write(shutdown_partial, "incomplete download")
	write(shutdown_conversion.path_join("partial.obj"), "incomplete conversion")
	write(shutdown_result, "incomplete result")
	var interrupted := Download.new()
	root.add_child(interrupted)
	interrupted.jobs = [{"temporary": shutdown_partial, "directory": ROOT, "kind": "mesh", "url": "https://example.invalid/interrupted"}]
	interrupted.busy = true
	interrupted.converter_output_path = shutdown_conversion
	interrupted.converter_result_path = shutdown_result
	interrupted.queue_free()
	await process_frame
	var after_shutdown := Download.Assets.cache_match("https://example.invalid/interrupted", Download.Assets.index_cache(ROOT))
	check(not is_instance_valid(interrupted) and not FileAccess.file_exists(shutdown_partial) and not DirAccess.dir_exists_absolute(shutdown_conversion) and not FileAccess.file_exists(shutdown_result)
		and after_shutdown.status == "missing", "Closing during asset preparation removes owned partial outputs and leaves no cache hit to link after restart")
	var crash_directory := ProjectSettings.globalize_path(ROOT.path_join("abrupt-%d" % OS.get_process_id()))
	DirAccess.make_dir_recursive_absolute(crash_directory)
	var kept_model := crash_directory.path_join("already-imported.obj")
	write(kept_model, "preserve existing imported model")
	var child_output: Array = []
	var child_args := PackedStringArray(["--headless", "--path", ProjectSettings.globalize_path("res://"), "--script", "res://tests/fixtures/model_download_crash_writer.gd", "--", crash_directory])
	var child_exit := OS.execute(OS.get_executable_path(), child_args, child_output, true)
	var ready_path := crash_directory.path_join("crash-ready.json")
	var crash_marker: Dictionary = {}
	var ready_file := FileAccess.open(ready_path, FileAccess.READ)
	if ready_file != null:
		var ready_parser := JSON.new()
		if ready_parser.parse(ready_file.get_as_text()) == OK and ready_parser.data is Dictionary:
			crash_marker = ready_parser.data
		ready_file.close()
	var crashed_partial := str(crash_marker.get("temporary", ""))
	var crashed_conversion := str(crash_marker.get("conversion_directory", ""))
	var crashed_result := str(crash_marker.get("conversion_result", ""))
	check(not crash_marker.has("error") and "Abrupt interruption fixture ready" in "\n".join(child_output) and FileAccess.file_exists(crashed_partial)
		and DirAccess.dir_exists_absolute(crashed_conversion) and FileAccess.file_exists(crashed_result),
		"A separate process leaves a download, conversion directory and result when terminated abruptly (exit %d): %s" % [child_exit, str(child_output)])
	var recovery := Download.new()
	root.add_child(recovery)
	await process_frame
	var recovered_cache := Download.Assets.cache_match("https://example.invalid/mesh", Download.Assets.index_cache(crash_directory))
	var crash_journal := ProjectSettings.globalize_path("user://forceorg-model-download-recovery/session-%d-%s-2.json" % [int(crash_marker.get("pid", -1)), str(crash_marker.get("token", ""))])
	check(not FileAccess.file_exists(crashed_partial) and not DirAccess.dir_exists_absolute(crashed_conversion) and not FileAccess.file_exists(crashed_result)
		and not FileAccess.file_exists(crash_journal) and FileAccess.file_exists(kept_model) and recovered_cache.status == "missing",
		"A new downloader removes only journaled outputs from the dead process and preserves existing imports")
	DirAccess.remove_absolute(ready_path)
	var failed_bundle_url := "https://example.invalid/conversion-failure"
	var failed_bundle_dir := ROOT.path_join("failed-conversion")
	var failed_bundle_partial := ROOT.path_join("failed-conversion.part")
	var failed_bundle_result_path := failed_bundle_dir + ".result.json"
	DirAccess.make_dir_recursive_absolute(failed_bundle_dir)
	write(failed_bundle_dir.path_join("partial.obj"), "incomplete conversion")
	write(failed_bundle_partial, "downloaded bundle")
	write(failed_bundle_result_path, "{\"error\":\"synthetic conversion rejection\"}")
	var failed_conversion := Download.new()
	root.add_child(failed_conversion)
	failed_conversion.finished.connect(func(value: Dictionary): conversion_failure = value)
	failed_conversion.jobs = [{"temporary": failed_bundle_partial, "directory": ROOT, "kind": "bundle", "url": failed_bundle_url}]
	failed_conversion.busy = true
	failed_conversion.converter_output_path = failed_bundle_dir
	failed_conversion.converter_result_path = failed_bundle_result_path
	failed_conversion.conversion_results[failed_bundle_url] = {"output_path": failed_bundle_dir, "preserved": false}
	failed_conversion._finish({"error": "Unity bundle conversion failed: synthetic conversion rejection"})
	var failed_bundle_cache := Download.Assets.cache_match(failed_bundle_url, Download.Assets.index_cache(ROOT))
	check("synthetic conversion rejection" in str(conversion_failure.get("error", "")) and not FileAccess.file_exists(failed_bundle_partial)
		and not DirAccess.dir_exists_absolute(failed_bundle_dir) and not FileAccess.file_exists(failed_bundle_result_path) and failed_bundle_cache.status == "missing",
		"Failed bundle conversion reports the cause, removes owned temporary output and publishes no cache hit")
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
