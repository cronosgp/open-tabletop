extends SceneTree
const ImportPanel = preload("res://scripts/model_import_panel.gd")
const Assets = preload("res://scripts/local_models.gd")
const DEFINITION := "40kdc:11e:adeptus-astartes:intercessor-squad"
const DIRECTORY := "user://automatic-preparation"
class OfflineTransfer:
	extends Node
	var busy := false
	var attempts := 0
	func cancel() -> void: busy = false
	func start(_entry: Dictionary, _path: String) -> String:
		attempts += 1
		return "Unexpected transfer in an offline test."
var failures := 0
func _initialize() -> void: call_deferred("run")
func check(ok: bool, message: String) -> void:
	if not ok:
		failures += 1
		push_error(message)
func write(path: String, content: String) -> void:
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_string(content)
	file.close()
func settle(panel) -> void:
	var deadline := Time.get_ticks_msec() + 10000
	while (panel.automatic_running or panel.visual_preparation_busy) and Time.get_ticks_msec() < deadline: await process_frame
	check(not panel.automatic_running and not panel.visual_preparation_busy, "Local planning finishes within the fixture deadline")
	await process_frame
func run() -> void:
	DirAccess.make_dir_recursive_absolute(DIRECTORY)
	var mesh := DIRECTORY.path_join("mesh.obj")
	write(mesh, "v -0.5 0 -0.5\nv 0.5 0 -0.5\nv 0 1 0\nv 0 0 0.5\nf 1 2 3\nf 1 3 4\nf 2 4 3\n")
	var mapping := {"path":mesh,"texture":"","fingerprint":FileAccess.get_sha256(mesh),"texture_fingerprint":""}
	var source := DIRECTORY.path_join("ForceOrg.json")
	write(source, JSON.stringify({"ObjectStates":[{"Nickname":"Intercessor","CustomMesh":{"MeshURL":"https://example.invalid/never-request.obj"}}]}) + " ".repeat(150000))
	var panel = ImportPanel.new()
	panel.settings_path = DIRECTORY.path_join("settings.cfg")
	root.add_child(panel)
	var offline := OfflineTransfer.new()
	panel.add_child(offline)
	panel.downloader = offline
	panel.source_path.text = source
	panel.download_path.text = DIRECTORY
	panel.mappings = {DEFINITION:mapping.duplicate(true)}
	var variant := mapping.duplicate(true)
	variant.definition = DEFINITION
	panel.variant_mappings = {"saved-local":variant}
	var requests := {DEFINITION:{"count":0,"manual":["saved-local"]}}
	var completions := {"count":0}
	panel.automatic_finished.connect(func(_ready: int, _total: int, _summary: String): completions.count += 1)
	var before := var_to_str(panel.mappings)
	check(panel.prepare_armies([DEFINITION],false,false,requests), "Accept a large-source batch with already-local requested visuals")
	check(panel.automatic_running and panel.visual_preparation_busy and completions.count == 0, "Large planning yields before emitting completion")
	panel.cancel_automatic()
	panel.prepare_armies([DEFINITION],false,false,requests)
	await settle(panel)
	check(completions.count == 1 and panel.automatic_ready == 1 and panel.automatic_appearance_ready == 1 and panel.automatic_appearance_total == 1, "Only the retried generation completes with the existing local default and appearance")
	check(var_to_str(panel.mappings) == before and offline.attempts == 0, "Planning and cancellation preserve mappings and perform no external requests")
	var config_before := FileAccess.get_sha256(panel.settings_path)
	panel.prepare_armies([DEFINITION],false,false,requests)
	panel.source_path.text = DIRECTORY.path_join("changed.json")
	await settle(panel)
	check(completions.count == 2 and panel.automatic_appearance_ready == 0 and panel.automatic_appearance_total == 1 and "source changed" in panel.download_status.text, "A changed source cannot claim that unplanned appearances are ready")
	check(FileAccess.get_sha256(panel.settings_path) == config_before, "An obsolete plan never overwrites the saved source or mappings")
	var damaged := DIRECTORY.path_join("damaged.json")
	write(damaged, "{broken" + " ".repeat(150000))
	panel.source_path.text = damaged
	panel.prepare_armies([DEFINITION],false,false,requests)
	await settle(panel)
	check(completions.count == 3 and panel.automatic_ready == 1 and panel.automatic_appearance_ready == 0 and panel.automatic_appearance_total == 1, "Catalog failure distinguishes reused defaults from unresolved requested appearances")
	check(var_to_str(panel.mappings) == before and offline.attempts == 0, "A failed planning batch preserves old links without falling back to HTTP")
	panel.source_path.text = source
	panel.prepare_armies([DEFINITION])
	check(not panel.automatic_running and completions.count == 4 and panel.automatic_ready == 1, "The all-saved no-appearance fast path retains immediate reuse semantics")
	var large_mesh := DIRECTORY.path_join("large.obj")
	write(large_mesh, FileAccess.get_file_as_string(mesh) + "# local parsing fixture\n".repeat(7000))
	var local_result := {"error":"","mesh":large_mesh,"texture":""}
	panel.automatic_running = true
	panel.automatic_current = {"definition":DEFINITION,"entry":{"name":"Large local fixture"}}
	panel._finish_automatic_item(local_result)
	check(panel.visual_preparation_busy, "Heavy cached batch items yield before main-thread installation")
	panel.cancel_automatic()
	await settle(panel)
	check(completions.count == 4 and var_to_str(panel.mappings) == before, "Cancelling cached-item parsing cannot complete or replace a saved mapping")
	panel.variant_current = {"variant_id":"cancelled-variant","name":"Large local variant"}
	panel.variant_download_definition = DEFINITION
	panel.variant_download_active = true
	panel._finish_variant_download(local_result)
	check(panel.visual_preparation_busy, "Heavy cached appearance parsing yields as well")
	panel.cancel_automatic()
	await settle(panel)
	check(not panel.variant_mappings.has("cancelled-variant") and offline.attempts == 0, "A late cancelled appearance cannot be saved or trigger another transfer")
	panel.source_path.text = DIRECTORY
	panel.prepare_armies([DEFINITION],false,false,requests)
	check(panel.visual_preparation_busy, "A directory source uses background planning for its large ForceOrg.json")
	panel.queue_free()
	await process_frame
	print("Automatic model preparation checks: %d failures" % failures)
	quit(0 if failures == 0 else 1)
