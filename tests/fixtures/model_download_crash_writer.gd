extends SceneTree

const Download = preload("res://scripts/model_download.gd")

func _initialize() -> void:
	call_deferred("run")

func write_json(path: String, value: Dictionary) -> void:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null: return
	file.store_string(JSON.stringify(value))
	file.close()

func run() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() != 1:
		quit(2)
		return
	var directory := str(args[0])
	var downloader := Download.new()
	root.add_child(downloader)
	downloader.jobs = [{"url": "https://example.invalid/mesh", "kind": "mesh", "directory": directory}]
	if not downloader._begin_recovery_session():
		write_json(directory.path_join("crash-ready.json"), {"error": "download recovery journal could not be written"})
		quit(3)
		return
	var temporary := str(downloader.jobs[0].temporary)
	var conversion_directory := directory.path_join(".forceorg-convert-%d-%s-0" % [downloader.recovery_pid, downloader.recovery_token])
	var conversion_result := conversion_directory + ".result.json"
	downloader.converter_output_path = conversion_directory
	downloader.converter_result_path = conversion_result
	if not downloader._register_recovery_path(conversion_directory) or not downloader._register_recovery_path(conversion_result):
		write_json(directory.path_join("crash-ready.json"), {"error": "conversion recovery journal could not be written"})
		quit(4)
		return
	var partial := FileAccess.open(temporary, FileAccess.WRITE)
	if partial == null:
		write_json(directory.path_join("crash-ready.json"), {"error": "partial file could not be written"})
		quit(5)
	partial.store_string("interrupted mesh download")
	partial.close()
	DirAccess.make_dir_recursive_absolute(conversion_directory)
	var conversion := FileAccess.open(conversion_directory.path_join("partial.obj"), FileAccess.WRITE)
	if conversion != null:
		conversion.store_string("interrupted bundle conversion")
		conversion.close()
	var result := FileAccess.open(conversion_result, FileAccess.WRITE)
	if result != null:
		result.store_string("incomplete conversion result")
		result.close()
	downloader.busy = true
	write_json(directory.path_join("crash-ready.json"), {
		"pid": downloader.recovery_pid,
		"token": downloader.recovery_token,
		"temporary": temporary,
		"conversion_directory": conversion_directory,
		"conversion_result": conversion_result
	})
	print("Abrupt interruption fixture ready")
	OS.kill(OS.get_process_id())
	quit(6)
