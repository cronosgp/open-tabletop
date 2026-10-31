extends Node
## Downloads and locally validates ForceOrg OBJ assemblies and supported Unity bundles.
signal finished(result: Dictionary)
signal progress(received: int, total: int, label: String)
const Assets = preload("res://scripts/local_models.gd")
var busy := false
var jobs: Array[Dictionary] = []
var active_components: Array[Dictionary] = []
var position_index := 0
var generation := 0
var request_node: HTTPRequest
var elapsed := 0.0
var conversion_started := false
var conversion_queue: Array[Dictionary] = []
var conversion_results: Dictionary = {}
var converter_pid := -1
var converter_stdio: FileAccess
var converter_stderr: FileAccess
var converter_job: Dictionary = {}
var converter_output_path := ""
var converter_result_path := ""
var converter_elapsed := 0.0

static func url_error(url: String) -> String:
	var pattern := RegEx.new()
	pattern.compile("^https://[A-Za-z0-9.-]+(?::[0-9]+)?(?:/[^\\s]*)?$")
	if url.length() > 4096 or pattern.search(url) == null: return "The model requires a valid HTTPS URL to download."
	return ""

static func plan(entry: Dictionary) -> Dictionary:
	var prepared := Assets.component_plan(entry)
	if not prepared.error.is_empty(): return prepared
	var parts: Array[Dictionary] = []
	var result: Array[Dictionary] = []
	var seen_jobs: Dictionary = {}
	for component: Dictionary in prepared.components:
		var references: Dictionary = component.references
		var component_kind := str(component.get("kind", "CustomMesh"))
		var mesh_url := str(references.get("MeshURL", "")).strip_edges().trim_prefix("{verifycache}")
		var texture_url := str(references.get("DiffuseURL", "")).strip_edges().trim_prefix("{verifycache}")
		var normal_url := str(references.get("NormalURL", "")).strip_edges().trim_prefix("{verifycache}")
		var bundle_url := str(component.get("bundle_url", "")).strip_edges().trim_prefix("{verifycache}")
		var bundle_dependency_url := str(component.get("bundle_dependency_url", "")).strip_edges().trim_prefix("{verifycache}")
		var specs: Array = [[mesh_url, "mesh", "OBJ mesh"], [texture_url, "texture", "diffuse texture"], [normal_url, "normal", "normal map"]]
		if component_kind == "CustomAssetbundle":
			specs = [[bundle_url, "bundle", "Unity model bundle"]]
			if not bundle_dependency_url.is_empty(): specs.append([bundle_dependency_url, "bundle_dependency", "Unity material dependency"])
		for spec: Array in specs:
			var url := str(spec[0])
			var job_kind := str(spec[1])
			if url.is_empty() and job_kind in ["texture", "normal", "bundle_dependency"]: continue
			var error := url_error(url)
			if not error.is_empty(): return {"error": str(spec[2]) + ": " + error}
			var identity := job_kind + "\n" + url
			if seen_jobs.has(identity): continue
			seen_jobs[identity] = true
			result.append({"url": url, "kind": job_kind, "label": str(spec[2]) + " • " + str(component.get("name", "model"))})
		parts.append({"path": str(component.get("path", "")), "name": str(component.get("name", "Model")), "kind": component_kind, "references": references.duplicate(true), "transforms": component.get("transforms", []).duplicate(true), "mesh_url": mesh_url, "texture_url": texture_url, "normal_url": normal_url, "bundle_url": bundle_url, "bundle_dependency_url": bundle_dependency_url})
	return {"error": "", "jobs": result, "components": parts}

func start(entry: Dictionary, directory: String) -> String:
	if busy: return "A download is already in progress."
	var prepared := plan(entry)
	if not prepared.error.is_empty(): return prepared.error
	for job: Dictionary in prepared.jobs:
		if str(job.get("kind", "")) == "bundle" and not FileAccess.file_exists(_converter_path()):
			return "This model uses a Unity bundle. Install the optional ForceOrg bundle converter in user://forceorg-converter and retry."
	if directory.strip_edges().is_empty(): return "Choose a folder for the models."
	var error := DirAccess.make_dir_recursive_absolute(directory)
	if error != OK: return "Could not create the download folder: " + error_string(error)
	jobs.assign(prepared.jobs)
	active_components.assign(prepared.components)
	generation += 1
	position_index = 0
	conversion_started = false
	conversion_queue.clear()
	conversion_results.clear()
	converter_job = {}
	converter_output_path = ""
	converter_result_path = ""
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
	var completed_job: Dictionary = jobs[position_index]
	if result != HTTPRequest.RESULT_SUCCESS:
		if str(completed_job.get("kind", "")) == "bundle_dependency":
			if FileAccess.file_exists(str(completed_job.get("temporary", ""))): DirAccess.remove_absolute(str(completed_job.temporary))
			position_index += 1
			if busy and token == generation: _next()
			return
		_finish({"error": "Download interrupted (error %d). Check your connection and try again." % result})
		return
	if code < 200 or code >= 300:
		if str(completed_job.get("kind", "")) == "bundle_dependency":
			if FileAccess.file_exists(str(completed_job.get("temporary", ""))): DirAccess.remove_absolute(str(completed_job.temporary))
			position_index += 1
			if busy and token == generation: _next()
			return
		_finish({"error": "The server returned HTTP %d. The file was not imported." % code})
		return
	var file := FileAccess.open(jobs[position_index].temporary, FileAccess.READ)
	if file == null or file.get_length() == 0 or file.get_length() > Assets.MAX_BYTES:
		if file != null: file.close()
		if str(completed_job.get("kind", "")) == "bundle_dependency":
			if FileAccess.file_exists(str(completed_job.get("temporary", ""))): DirAccess.remove_absolute(str(completed_job.temporary))
			position_index += 1
			if busy and token == generation: _next()
			return
		_finish({"error": "File is empty, unreadable, or larger than 64 MiB."})
		return
	file.close()
	position_index += 1
	if busy and token == generation: _next()

func _complete_files() -> void:
	if not conversion_started:
		for job: Dictionary in jobs:
			if str(job.kind) != "bundle": continue
			var bundle_dependencies: Array[String] = []
			for component: Dictionary in active_components:
				if str(component.get("bundle_url", "")) != str(job.url): continue
				var dependency_url := str(component.get("bundle_dependency_url", ""))
				if not dependency_url.is_empty() and dependency_url not in bundle_dependencies: bundle_dependencies.append(dependency_url)
			job["dependency_urls"] = bundle_dependencies
			conversion_queue.append(job)
		conversion_started = true
		if not conversion_queue.is_empty():
			_start_next_bundle_conversion()
			return
	_finalize_files()

func _converter_path() -> String:
	var executable := "forceorg-bundle-converter.exe" if OS.get_name() == "Windows" else "forceorg-bundle-converter"
	return ProjectSettings.globalize_path("user://forceorg-converter").path_join(executable)

func _start_next_bundle_conversion() -> void:
	if not busy: return
	if conversion_queue.is_empty():
		_finalize_files()
		return
	var executable := _converter_path()
	if not FileAccess.file_exists(executable):
		_finish({"error": "This model uses a Unity bundle. Install the optional ForceOrg bundle converter in user://forceorg-converter and retry."})
		return
	converter_job = conversion_queue.pop_front()
	converter_output_path = str(converter_job.directory).path_join(".forceorg-convert-%d-%d-%d" % [get_instance_id(), generation, conversion_results.size()])
	converter_result_path = converter_output_path + ".result.json"
	converter_elapsed = 0.0
	var arguments := PackedStringArray(["--input", str(converter_job.temporary), "--output", converter_output_path, "--result", converter_result_path])
	for dependency_url: String in converter_job.get("dependency_urls", []):
		var dependency_path := ""
		for job: Dictionary in jobs:
			if str(job.get("kind", "")) == "bundle_dependency" and str(job.get("url", "")) == dependency_url:
				dependency_path = str(job.get("temporary", ""))
				break
		if dependency_path.is_empty() or not FileAccess.file_exists(dependency_path): continue
		arguments.append("--dependency")
		arguments.append(dependency_path)
	var launched: Dictionary = OS.execute_with_pipe(executable, arguments, false)
	if not launched.has("pid") or int(launched.get("pid", -1)) <= 0:
		_finish({"error": "Could not start the Unity bundle converter. Check its installation and permissions."})
		return
	converter_pid = int(launched.pid)
	converter_stdio = launched.get("stdio")
	converter_stderr = launched.get("stderr")
	progress.emit(0, -1, "Converting Unity model bundle • " + str(converter_job.get("label", "model")))

func _poll_bundle_conversion() -> void:
	if converter_pid <= 0 or OS.is_process_running(converter_pid): return
	converter_pid = -1
	if converter_stdio != null:
		converter_stdio.close()
		converter_stdio = null
	if converter_stderr != null:
		converter_stderr.close()
		converter_stderr = null
	var result_file := FileAccess.open(converter_result_path, FileAccess.READ)
	if result_file == null:
		_finish({"error": "The Unity bundle converter stopped without a result file."})
		return
	var result_parser := JSON.new()
	var parse_status := result_parser.parse(result_file.get_as_text())
	result_file.close()
	if parse_status != OK or not result_parser.data is Dictionary:
		_finish({"error": "The Unity bundle converter returned an invalid result."})
		return
	var converter_result: Dictionary = result_parser.data
	if not str(converter_result.get("error", "")).is_empty():
		_finish({"error": "Unity bundle conversion failed: " + str(converter_result.error)})
		return
	var manifest_path := converter_output_path.path_join("manifest.json")
	var manifest_file := FileAccess.open(manifest_path, FileAccess.READ)
	if manifest_file == null:
		_finish({"error": "The Unity bundle converter did not create a manifest."})
		return
	var manifest_parser := JSON.new()
	parse_status = manifest_parser.parse(manifest_file.get_as_text())
	manifest_file.close()
	if parse_status != OK or not manifest_parser.data is Dictionary:
		_finish({"error": "The Unity bundle converter created an invalid manifest."})
		return
	var parts: Variant = manifest_parser.data.get("parts", null)
	if not parts is Array or parts.is_empty() or parts.size() > 256:
		_finish({"error": "The Unity bundle contains no supported rendered parts."})
		return
	for part: Variant in parts:
		if not part is Dictionary:
			_finish({"error": "The Unity bundle manifest contains an invalid part."})
			return
		var relative_mesh := str(part.get("mesh", "")).replace("\\", "/")
		if relative_mesh.is_empty() or relative_mesh.begins_with("/") or relative_mesh.contains(":") or ".." in relative_mesh.split("/"):
			_finish({"error": "The Unity bundle manifest contains an unsafe model path."})
			return
		if not FileAccess.file_exists(converter_output_path.path_join(relative_mesh)):
			_finish({"error": "The Unity bundle manifest references a missing model part."})
			return
	var url := str(converter_job.url)
	var conversion_hash := str(manifest_parser.data.get("conversion_sha256", manifest_parser.data.get("source_sha256", "")))
	if conversion_hash.length() != 64:
		_finish({"error": "The Unity bundle converter returned an invalid content fingerprint."})
		return
	var dependency_hashes: Array = manifest_parser.data.get("dependency_sha256", [])
	var dependency_candidate_urls: Array[String] = converter_job.get("dependency_urls", []).duplicate()
	var loaded_dependency_urls: Array[String] = []
	for dependency_url: String in dependency_candidate_urls:
		for job: Dictionary in jobs:
			if str(job.get("kind", "")) != "bundle_dependency" or str(job.get("url", "")) != dependency_url: continue
			if not FileAccess.file_exists(str(job.get("temporary", ""))): continue
			if FileAccess.get_sha256(str(job.temporary)) in dependency_hashes and dependency_url not in loaded_dependency_urls:
				loaded_dependency_urls.append(dependency_url)
			break
	conversion_results[url] = {"output_path": converter_output_path, "parts": parts, "bundle_hash": conversion_hash, "dependency_candidate_urls": dependency_candidate_urls, "loaded_dependency_urls": loaded_dependency_urls, "dependencies_complete": bool(manifest_parser.data.get("dependencies_complete", false)), "preserved": false}
	converter_output_path = ""
	if FileAccess.file_exists(converter_result_path): DirAccess.remove_absolute(converter_result_path)
	converter_result_path = ""
	converter_job = {}
	_start_next_bundle_conversion()

func _finalize_files() -> void:
	var components_to_import := active_components.duplicate(true)
	if components_to_import.is_empty():
		var mesh_url := ""
		var texture_url := ""
		var bundle_url := ""
		for job: Dictionary in jobs:
			if str(job.kind) == "mesh" and mesh_url.is_empty(): mesh_url = str(job.url)
			elif str(job.kind) == "texture" and texture_url.is_empty(): texture_url = str(job.url)
			elif str(job.kind) == "bundle" and bundle_url.is_empty(): bundle_url = str(job.url)
		if not mesh_url.is_empty(): components_to_import.append({"kind": "CustomMesh", "mesh_url": mesh_url, "texture_url": texture_url, "normal_url": "", "transforms": [], "name": "Model"})
		elif not bundle_url.is_empty(): components_to_import.append({"kind": "CustomAssetbundle", "bundle_url": bundle_url, "transforms": [], "name": "Model"})
	var temporary_by_reference: Dictionary = {}
	for job: Dictionary in jobs: temporary_by_reference[str(job.kind) + "\n" + str(job.url)] = str(job.temporary)
	var resolved_parts: Array[Dictionary] = []
	for component: Dictionary in components_to_import:
		if str(component.get("kind", "CustomMesh")) == "CustomAssetbundle":
			var bundle_url := str(component.get("bundle_url", ""))
			var converted: Dictionary = conversion_results.get(bundle_url, {})
			if converted.is_empty():
				_finish({"error": "The Unity bundle conversion result is unavailable for " + str(component.get("name", "model")) + "."})
				return
			for exported_part: Dictionary in converted.parts:
				var relative_mesh := str(exported_part.get("mesh", ""))
				var mesh := str(converted.output_path).path_join(relative_mesh)
				var combined_transforms: Array = component.get("transforms", []).duplicate(true)
				combined_transforms.append_array(exported_part.get("transforms", []).duplicate(true))
				var asset := Assets.obj_mesh(mesh, "", "", true)
				if not asset.error.is_empty():
					_finish({"error": "Downloaded component is incompatible: " + str(exported_part.get("name", component.get("name", "Model"))) + " — " + asset.error})
					return
				resolved_parts.append({"path": mesh, "relative_mesh": relative_mesh, "bundle_url": bundle_url, "bundle_dependency_url": str(component.get("bundle_dependency_url", "")), "texture": "", "normal": "", "transforms": combined_transforms, "name": str(exported_part.get("name", component.get("name", "Model"))), "fingerprint": asset.fingerprint, "texture_fingerprint": asset.texture_fingerprint, "warnings": exported_part.get("warnings", []), "asset": asset})
		else:
			var mesh_url := str(component.get("mesh_url", ""))
			var texture_url := str(component.get("texture_url", ""))
			var normal_url := str(component.get("normal_url", ""))
			var mesh := str(temporary_by_reference.get("mesh\n" + mesh_url, ""))
			var texture := str(temporary_by_reference.get("texture\n" + texture_url, "")) if not texture_url.is_empty() else ""
			var normal := str(temporary_by_reference.get("normal\n" + normal_url, "")) if not normal_url.is_empty() else ""
			var asset := Assets.obj_mesh(mesh, texture, normal)
			if not asset.error.is_empty():
				_finish({"error": "Downloaded component is incompatible: " + str(component.get("name", "Model")) + " — " + asset.error})
				return
			resolved_parts.append({"path": mesh, "texture": texture, "normal": normal, "transforms": component.get("transforms", []), "name": component.get("name", "Model"), "mesh_url": mesh_url, "texture_url": texture_url, "normal_url": normal_url, "fingerprint": asset.fingerprint, "texture_fingerprint": asset.texture_fingerprint, "warnings": asset.get("warnings", []), "asset": asset})
	var assembly := Assets.composite_from_files(resolved_parts)
	if not assembly.error.is_empty():
		_finish({"error": "Downloaded model cannot be assembled: " + assembly.error})
		return
	var permanent_by_reference: Dictionary = {}
	var permanent_bundle_dirs: Dictionary = {}
	for job: Dictionary in jobs:
		# Content-versioned names preserve older assets and never publish an unvalidated file.
		var extension: String = {"mesh": ".obj", "texture": ".png", "normal": ".png", "bundle": ".unity3d", "bundle_dependency": ".unity3d"}.get(str(job.kind), ".bin")
		var filename: String = job.url.sha256_text() + "-" + FileAccess.get_sha256(job.temporary).substr(0, 16) + extension
		var target: String = str(job.directory).path_join(filename)
		if FileAccess.file_exists(target):
			if FileAccess.get_sha256(target) != FileAccess.get_sha256(job.temporary):
				_finish({"error": "Conflicting local file. Choose another download folder."})
				return
			DirAccess.remove_absolute(job.temporary)
		else:
			var error := DirAccess.rename_absolute(job.temporary, target)
			if error != OK:
				_finish({"error": "Could not save the file: " + error_string(error)})
				return
		permanent_by_reference[str(job.kind) + "\n" + str(job.url)] = target
		if str(job.kind) == "bundle":
			var converted: Dictionary = conversion_results[str(job.url)]
			var bundle_root := str(job.directory).path_join("forceorg-bundles")
			var make_root_error := DirAccess.make_dir_recursive_absolute(bundle_root)
			if make_root_error != OK:
				_finish({"error": "Could not create the converted bundle folder: " + error_string(make_root_error)})
				return
			var converted_target := bundle_root.path_join(job.url.sha256_text() + "-" + str(converted.bundle_hash).substr(0, 16) + ".bundle")
			if DirAccess.dir_exists_absolute(converted_target):
				if not FileAccess.file_exists(converted_target.path_join("manifest.json")):
					_finish({"error": "A conflicting converted bundle already exists."})
					return
				_remove_generated_directory(str(converted.output_path))
			else:
				var move_error := DirAccess.rename_absolute(str(converted.output_path), converted_target)
				if move_error != OK:
					_finish({"error": "Could not save the converted model: " + error_string(move_error)})
					return
			converted.output_path = converted_target
			converted.preserved = true
			permanent_bundle_dirs[str(job.url)] = converted_target
			var marker := {"version": 1, "bundle_url": str(job.url), "directory": "forceorg-bundles/" + converted_target.get_file(), "bundle_hash": converted.bundle_hash, "part_count": converted.parts.size(), "dependency_candidate_urls": converted.get("dependency_candidate_urls", []), "loaded_dependency_urls": converted.get("loaded_dependency_urls", []), "dependencies_complete": converted.get("dependencies_complete", false)}
			var marker_path := str(job.directory).path_join(job.url.sha256_text() + "-" + str(converted.bundle_hash).substr(0, 16) + ".bundle.json")
			var marker_file := FileAccess.open(marker_path, FileAccess.WRITE)
			if marker_file == null:
				_finish({"error": "Could not save the converted model cache index."})
				return
			marker_file.store_string(JSON.stringify(marker))
			marker_file.close()
	for component_index in range(resolved_parts.size()):
		if resolved_parts[component_index].has("bundle_url"):
			resolved_parts[component_index].path = str(permanent_bundle_dirs.get(str(resolved_parts[component_index].bundle_url), "")).path_join(str(resolved_parts[component_index].relative_mesh))
		else:
			resolved_parts[component_index].path = str(permanent_by_reference.get("mesh\n" + str(resolved_parts[component_index].mesh_url), ""))
			if not str(resolved_parts[component_index].texture_url).is_empty(): resolved_parts[component_index].texture = str(permanent_by_reference.get("texture\n" + str(resolved_parts[component_index].texture_url), ""))
			if not str(resolved_parts[component_index].normal_url).is_empty(): resolved_parts[component_index].normal = str(permanent_by_reference.get("normal\n" + str(resolved_parts[component_index].normal_url), ""))
	var first: Dictionary = resolved_parts[0]
	for part: Dictionary in resolved_parts: part.erase("asset")
	_finish({"error": "", "mesh": str(first.get("path", "")), "texture": str(first.get("texture", "")), "parts": resolved_parts, "fingerprint": assembly.fingerprint, "asset": assembly})

func _remove_generated_directory(path: String) -> void:
	if path.is_empty() or not DirAccess.dir_exists_absolute(path): return
	var directory := DirAccess.open(path)
	if directory == null: return
	if directory.list_dir_begin() != OK: return
	var name := directory.get_next()
	while not name.is_empty():
		var child := path.path_join(name)
		if directory.current_is_dir() and not directory.is_link(name):
			_remove_generated_directory(child)
		else:
			DirAccess.remove_absolute(child)
		name = directory.get_next()
	directory.list_dir_end()
	DirAccess.remove_absolute(path)

func cancel() -> void:
	if not busy: return
	generation += 1
	_finish({"error": "Download cancelled. No mappings were changed.", "cancelled": true})

func _finish(result: Dictionary) -> void:
	if converter_pid > 0:
		OS.kill(converter_pid)
		converter_pid = -1
	if converter_stdio != null:
		converter_stdio.close()
		converter_stdio = null
	if converter_stderr != null:
		converter_stderr.close()
		converter_stderr = null
	if is_instance_valid(request_node):
		request_node.cancel_request()
		request_node.queue_free()
		request_node = null
	for job: Dictionary in jobs:
		if FileAccess.file_exists(job.temporary): DirAccess.remove_absolute(job.temporary)
	if not converter_output_path.is_empty(): _remove_generated_directory(converter_output_path)
	if not converter_result_path.is_empty() and FileAccess.file_exists(converter_result_path): DirAccess.remove_absolute(converter_result_path)
	for converted: Variant in conversion_results.values():
		if converted is Dictionary and not bool(converted.get("preserved", false)):
			_remove_generated_directory(str(converted.get("output_path", "")))
	busy = false
	active_components.clear()
	conversion_queue.clear()
	conversion_results.clear()
	converter_job = {}
	converter_output_path = ""
	converter_result_path = ""
	finished.emit(result)

func _process(delta: float) -> void:
	if not busy: return
	if converter_pid > 0:
		converter_elapsed += delta
		if converter_elapsed >= 0.5:
			converter_elapsed = 0.0
			progress.emit(0, -1, "Converting Unity model bundle • " + str(converter_job.get("label", "model")))
		if not OS.is_process_running(converter_pid): _poll_bundle_conversion()
		return
	if not is_instance_valid(request_node): return
	elapsed += delta
	if elapsed < 0.1: return
	elapsed = 0
	progress.emit(request_node.get_downloaded_bytes(), request_node.get_body_size(), jobs[position_index].label)

func _exit_tree() -> void:
	if busy:
		for connection: Dictionary in finished.get_connections(): finished.disconnect(connection.callable)
		cancel()
