extends SceneTree
var failures := 0
const OBJ := "v -1 0 -1\nv 1 0 -1\nv 0 3 0\nv 0 0 1\nf 1 2 3\nf 2 4 3\nf 4 1 3\nf 1 4 2\n"
func _initialize() -> void: call_deferred("run")
func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1
func mapping(path: String) -> Dictionary:
	return {"path":path,"texture":"","fingerprint":FileAccess.get_sha256(path),"texture_fingerprint":"","scale":1.0,"rotation":0.0,"offset":0.0}
func settle(importer) -> void:
	var deadline := Time.get_ticks_msec() + 10000
	while importer.visual_preparation_busy and Time.get_ticks_msec() < deadline: await process_frame
	check(not importer.visual_preparation_busy, "Background preview work finishes within the local fixture deadline")
func run() -> void:
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game._skip_first_run_model_setup()
	game._open_menu_section(3)
	var builder = game.army_builder
	var importer = game.model_imports
	DirAccess.make_dir_recursive_absolute("user://async-preview")
	var large := "user://async-preview/large.obj"
	var small := "user://async-preview/small.obj"
	var file := FileAccess.open(large, FileAccess.WRITE)
	file.store_string(OBJ + "# parsing fixture padding\n".repeat(14000))
	file.close()
	file = FileAccess.open(small, FileAccess.WRITE)
	file.store_string(OBJ)
	file.close()
	var first := "40kdc:11e:adeptus-astartes:intercessor-squad"
	var second := "40kdc:11e:adeptus-astartes:aggressor-squad"
	importer.mappings = {first:mapping(large),second:mapping(small)}
	importer.cache.clear()
	builder._new_empty()
	builder.draft.entries = [builder.Roster.entry(builder.source.lookup(first),0),builder.Roster.entry(builder.source.lookup(second),0)]
	builder._render_draft()
	var before := var_to_str(builder.draft)
	check(builder.preview_busy and importer.visual_preparation_busy and "Loading" in builder.miniature_preview.caption.text, "A large local preview yields with explicit loading feedback")
	builder._select_entry(1)
	check(builder.preview_entry.unit_id == second and builder.miniature_preview.imported, "A later lightweight selection remains immediately usable")
	await settle(importer)
	await process_frame
	check(builder.preview_entry.unit_id == second and second.get_slice(":",3) != first.get_slice(":",3) and builder.miniature_preview.title.text == "Roster · " + str(builder.draft.entries[1].name), "Late completion cannot replace the newer roster selection")
	check(var_to_str(builder.draft) == before and importer.catalog.is_empty(), "Previewing preserves roster data and does not eagerly parse the appearance catalog")
	builder._select_entry(0)
	await settle(importer)
	await process_frame
	check(builder.miniature_preview.imported and not builder.preview_busy, "The requested large model is displayed after background parsing")
	var catalog_entries: Array = []
	for index in 513: catalog_entries.append({"visual_category": "base"})
	importer.catalog = {"entries": catalog_entries}
	builder._open_entry_appearance()
	check(importer.visual_preparation_busy and builder.visual_slot_controls.is_empty(), "A large appearance catalog yields before matching and shows its loading state")
	builder.editor_tabs.current_tab = 0
	await settle(importer)
	await process_frame
	check(builder.visual_slot_controls.is_empty(), "Late appearance matching does not repopulate a closed inspector tab")
	builder._open_entry_appearance()
	await settle(importer)
	await process_frame
	check(builder.visual_slot_controls.size() == 2, "Reopening Appearance completes the current request and retains both assignment scopes")
	builder.editor_tabs.current_tab = 0
	importer.settings_path = "user://async-preview/local-models.cfg"
	importer.mesh_path.text = small
	importer.texture_path.text = ""
	importer.load_preview()
	# A reviewed source-pose fixture uses the same conversion/admission boundary.
	importer.preview_asset.source_pose = true
	importer.preview_asset.base_detection = "ring"
	importer.preview_asset.base_rim_coverage = true
	importer.preview_asset.base_footprint = Vector2.ONE * (32.0 / 25.4)
	importer._update_preview()
	var mapping_before := var_to_str(importer.mappings)
	importer.apply_mapping()
	check(importer.package_busy and importer.visual_preparation_busy and "Preparing" in importer.notice.text, "Source-pose linking yields while its GLB is prepared with visible busy feedback")
	importer.scale_input.value = 1.2
	await settle(importer)
	await process_frame
	check(not importer.package_busy and var_to_str(importer.mappings) == mapping_before and "not linked" in importer.notice.text, "Changing fit during conversion cannot install an obsolete mapping")
	importer.scale_input.value = 1.0
	importer.apply_mapping()
	await settle(importer)
	await process_frame
	check(importer.mappings[first].has("prepared_key") and not importer.package_busy, "Current source-pose conversion persists its verified package and unit mapping")
	var source_file := "user://async-preview/catalog.json"
	file = FileAccess.open(source_file, FileAccess.WRITE)
	file.store_string(JSON.stringify({"ObjectStates": [{"Nickname": "Intercessor", "CustomMesh": {"MeshURL": "https://example.invalid/no-download.obj"}}]}))
	file.close()
	var previous_catalog: Dictionary = importer.catalog
	importer.source_path.text = source_file
	importer.scan_source_async()
	check(importer.source_scan_busy and importer.visual_preparation_busy and "Scanning" in importer.inventory_status.text, "Explicit source scanning yields with visible status and no downloads")
	importer.source_path.text = "user://async-preview/different.json"
	await settle(importer)
	await process_frame
	check(importer.catalog == previous_catalog and not importer.source_scan_busy, "An obsolete source scan preserves the existing catalog")
	importer.source_path.text = source_file
	importer.scan_source_async()
	await settle(importer)
	await process_frame
	check(importer.catalog.entries.size() == 1 and importer.inventory.item_count == 1 and not importer.source_scan_busy, "A current source scan installs and displays its local entries")
	game.first_run_model_setup_finished = false
	game._accept_first_run_model_catalog(source_file)
	check(importer.visual_preparation_busy and not game.first_run_model_setup_finished, "First-run catalog selection waits for its background scan")
	game._skip_first_run_model_setup()
	await settle(importer)
	await process_frame
	check(game.first_run_model_setup_finished and not game.auto_models.button_pressed, "Late first-run scanning cannot override Continue without models or enable downloads")
	importer.mappings[first] = mapping(large)
	importer.cache.erase(first)
	builder._preview_entry(builder.draft.entries[0])
	builder._close_editor()
	await settle(importer)
	check(builder.preview_entry.is_empty() and not builder.editor.visible, "Closing the editor invalidates its pending preview without reviving it")
	builder._resume_draft()
	importer.cache.erase(first)
	builder._select_entry(0)
	game.queue_free()
	await process_frame
	print("Asynchronous miniature preview checks: %d failures" % failures)
	quit(0 if failures == 0 else 1)
