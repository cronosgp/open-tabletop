extends Node
## The public JSON endpoint documented by the ForceOrg Downloader project.
signal finished(result: Dictionary)
signal progress(received: int, total: int)
const URL := "https://forceorg-download.raikoh.workers.dev/ForceOrg.json"
const Assets = preload("res://scripts/local_models.gd")
var busy := false
var generation := 0
var request_node: HTTPRequest
var temporary := ""
var destination := "user://ForceOrg.json"

func start() -> String:
	if busy: return "The ForceOrg catalog is already downloading."
	generation += 1
	temporary = destination + ".%d-%d.part" % [get_instance_id(), generation]
	var error := DirAccess.make_dir_recursive_absolute(destination.get_base_dir())
	if error != OK: return "Cannot create the ForceOrg catalog directory."
	request_node = HTTPRequest.new()
	request_node.timeout = 60
	request_node.body_size_limit = Assets.MAX_BYTES
	request_node.max_redirects = 3
	request_node.use_threads = true
	request_node.download_file = temporary
	add_child(request_node)
	request_node.request_completed.connect(_response.bind(generation, temporary))
	busy = true
	error = request_node.request(URL)
	if error != OK:
		cancel()
		return "Cannot start the ForceOrg catalog download: " + error_string(error)
	return ""

func _response(result: int, code: int, _headers: PackedStringArray, _body: PackedByteArray, ticket: int, path: String) -> void:
	if ticket != generation: return
	if is_instance_valid(request_node):
		request_node.queue_free()
		request_node = null
	# Windows keeps the downloaded file open until the request is released.
	await get_tree().process_frame
	await get_tree().process_frame
	if ticket != generation:
		if FileAccess.file_exists(path): DirAccess.remove_absolute(path)
		return
	var issue := ""
	if result != HTTPRequest.RESULT_SUCCESS or code < 200 or code >= 300:
		issue = "ForceOrg catalog unavailable: HTTP %d / transport %d. Retry or choose a local JSON in Models." % [code, result]
	else:
		var scanned := Assets.scan(path)
		if not scanned.error.is_empty(): issue = "Invalid ForceOrg catalog: " + scanned.error
		elif scanned.entries.is_empty(): issue = "The ForceOrg catalog contains no model entries."
		else:
			var error := DirAccess.rename_absolute(path, destination)
			if error != OK: issue = "Cannot save the ForceOrg catalog: " + error_string(error)
	if FileAccess.file_exists(path): DirAccess.remove_absolute(path)
	busy = false
	finished.emit({"error": issue, "path": destination if issue.is_empty() else ""})

func cancel() -> void:
	generation += 1
	if is_instance_valid(request_node):
		request_node.cancel_request()
		request_node.queue_free()
		request_node = null
	if FileAccess.file_exists(temporary): DirAccess.remove_absolute(temporary)
	busy = false

func _process(_delta: float) -> void:
	if busy and is_instance_valid(request_node): progress.emit(request_node.get_downloaded_bytes(), request_node.get_body_size())

func _exit_tree() -> void:
	cancel()
