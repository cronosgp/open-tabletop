extends Node
## Explicit player-initiated downloads of one selected OBJ and optional image.
signal finished(result: Dictionary)
signal progress(received: int, total: int, label: String)
const Assets = preload("res://scripts/local_models.gd")
var busy := false
var jobs: Array[Dictionary] = []
var position_index := 0
var generation := 0
var request_node: HTTPRequest
var elapsed := 0.0

static func url_error(url: String) -> String:
	var pattern := RegEx.new()
	pattern.compile("^https://[A-Za-z0-9.-]+(?::[0-9]+)?(?:/[^\\s]*)?$")
	if url.length() > 4096 or pattern.search(url) == null: return "The model requires a valid HTTPS URL to download."
	return ""

static func plan(entry: Dictionary) -> Dictionary:
	if entry.get("kind", "") != "CustomMesh": return {"error": "This Unity bundle cannot be imported as OBJ."}
	var refs: Dictionary = entry.get("references", {})
	var result: Array[Dictionary] = []
	for item: Array in [["MeshURL", "mesh", "Malha OBJ"], ["DiffuseURL", "texture", "Textura"]]:
		var url := str(refs.get(item[0], "")).strip_edges().trim_prefix("{verifycache}")
		if url.is_empty() and item[1] == "texture": continue
		var error := url_error(url)
		if not error.is_empty(): return {"error": str(item[2]) + ": " + error}
		result.append({"url": url, "kind": item[1], "label": item[2]})
	return {"error": "", "jobs": result}

func start(entry: Dictionary, directory: String) -> String:
	if busy: return "A download is already in progress."
	var prepared := plan(entry)
	if not prepared.error.is_empty(): return prepared.error
	if directory.strip_edges().is_empty(): return "Choose a folder for the models."
	var error := DirAccess.make_dir_recursive_absolute(directory)
	if error != OK: return "Could not create the download folder: " + error_string(error)
	jobs.assign(prepared.jobs)
	generation += 1
	position_index = 0
	for index in range(jobs.size()):
		jobs[index].temporary = directory.path_join(".model-%d-%d-%d.part" % [get_instance_id(), generation, index])
		jobs[index].directory = directory
	busy = true
	_next()
	return ""

func _next() -> void:
	if not busy: return
	if position_index >= jobs.size():
		_complete_files()
		return
	var job: Dictionary = jobs[position_index]
	request_node = HTTPRequest.new()
	request_node.timeout = 45
	request_node.body_size_limit = Assets.MAX_BYTES
	request_node.max_redirects = 3
	request_node.use_threads = true
	request_node.download_file = job.temporary
	add_child(request_node)
	request_node.request_completed.connect(_response.bind(generation), CONNECT_ONE_SHOT)
	progress.emit(0, -1, job.label)
	var error := request_node.request(job.url)
	if error != OK: _finish({"error": "Could not start the download: " + error_string(error)})

func _response(result: int, code: int, _headers: PackedStringArray, _body: PackedByteArray, token: int) -> void:
	if not busy or token != generation: return
	if is_instance_valid(request_node):
		request_node.queue_free()
		request_node = null
	# Release the native download handle before validation/cleanup on Windows.
	await get_tree().process_frame
	await get_tree().process_frame
	if not busy or token != generation: return
	if result != HTTPRequest.RESULT_SUCCESS:
		_finish({"error": "Download interrupted (error %d). Check your connection and try again." % result})
		return
	if code < 200 or code >= 300:
		_finish({"error": "The server returned HTTP %d. The file was not imported." % code})
		return
	var file := FileAccess.open(jobs[position_index].temporary, FileAccess.READ)
	if file == null or file.get_length() == 0 or file.get_length() > Assets.MAX_BYTES:
		_finish({"error": "File is empty, unreadable, or larger than 64 MiB."})
		return
	file.close()
	position_index += 1
	if busy and token == generation: _next()

func _complete_files() -> void:
	var mesh := ""
	var texture := ""
	for job: Dictionary in jobs:
		if job.kind == "mesh": mesh = job.temporary
		else: texture = job.temporary
	var asset := Assets.obj_mesh(mesh, texture)
	if not asset.error.is_empty():
		_finish({"error": "Files downloaded but are incompatible: " + asset.error})
		return
	var paths := {"mesh": "", "texture": ""}
	for job: Dictionary in jobs:
		# Content-versioned names preserve existing files on failed/cancelled updates.
		var filename: String = job.url.sha256_text() + "-" + FileAccess.get_sha256(job.temporary).substr(0, 16) + (".obj" if job.kind == "mesh" else ".png")
		var target: String = str(job.directory).path_join(filename)
		if FileAccess.file_exists(target):
			if FileAccess.get_sha256(target) != FileAccess.get_sha256(job.temporary):
				_finish({"error": "Conflicting local file. Choose another download folder."})
				return
		else:
			var error := DirAccess.rename_absolute(job.temporary, target)
			if error != OK:
				_finish({"error": "Could not save the file: " + error_string(error)})
				return
		paths[job.kind] = target
	_finish({"error": "", "mesh": paths.mesh, "texture": paths.texture})

func cancel() -> void:
	if not busy: return
	generation += 1
	_finish({"error": "Download cancelled. No mappings were changed.", "cancelled": true})

func _finish(result: Dictionary) -> void:
	if is_instance_valid(request_node):
		request_node.cancel_request()
		request_node.queue_free()
		request_node = null
	for job: Dictionary in jobs:
		if FileAccess.file_exists(job.temporary): DirAccess.remove_absolute(job.temporary)
	busy = false
	finished.emit(result)

func _process(delta: float) -> void:
	if not busy or not is_instance_valid(request_node): return
	elapsed += delta
	if elapsed < 0.1: return
	elapsed = 0
	progress.emit(request_node.get_downloaded_bytes(), request_node.get_body_size(), jobs[position_index].label)

func _exit_tree() -> void:
	if busy:
		for connection: Dictionary in finished.get_connections(): finished.disconnect(connection.callable)
		cancel()
