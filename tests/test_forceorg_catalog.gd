extends SceneTree
const Assets = preload("res://scripts/local_models.gd")
const ImportPanel = preload("res://scripts/model_import_panel.gd")
var failures := 0
func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var record := {"Name": "Custom_Model", "Nickname": "Test miniature ]]", "Description": "Original fixture credit", "Transform": {"scaleX": 1.0, "scaleY": 1.0, "scaleZ": 1.0}, "CustomMesh": {"MeshURL": "https://example.invalid/test"}}
	var literal := JSON.stringify(record)
	var script := "function onLoad() error('must never run') end\nobjectJSONs = {\n-- literal data only\n[=[" + literal + "]=],\n}\n"
	var result := Assets.static_model_objects(script)
	check(result.error.is_empty() and result.objects.size() == 1 and result.objects[0].Nickname == record.Nickname, "Static JSON long strings parse without executing surrounding Lua")
	result = Assets.static_model_objects("objectJSONs = { dangerous_function() }")
	check(not result.error.is_empty() and result.objects.is_empty(), "Expressions reject the complete table rather than evaluating or partially importing it")
	result = Assets.static_model_objects("objectJSONs = { [[broken json]] }")
	check(not result.error.is_empty(), "Malformed embedded JSON is reported")
	DirAccess.make_dir_recursive_absolute("res://.tools/catalog-test")
	var file := FileAccess.open("res://.tools/catalog-test/source.json", FileAccess.WRITE)
	file.store_string(JSON.stringify({"ObjectStates": [{"Name": "Tile", "LuaScript": script}]}))
	file.close()
	var scanned := Assets.scan("res://.tools/catalog-test/source.json")
	check(scanned.error.is_empty() and scanned.embedded_objects == 1 and scanned.entries[0].credit == record.Description and "objectJSONs" in scanned.entries[0].path and is_equal_approx(float(scanned.entries[0].tts_scale), 1.0), "Scanner retains embedded source identity, credits and Transform scale")
	file = FileAccess.open("res://.tools/catalog-test/children.json", FileAccess.WRITE)
	file.store_string(JSON.stringify({"ObjectStates": [{"Nickname": "Parent miniature", "Description": "Parent credit", "ChildObjects": [{"Name": "Custom_Model", "Nickname": null, "CustomMesh": {"MeshURL": "https://example.invalid/component"}}]}]}))
	file.close()
	var children := Assets.scan("res://.tools/catalog-test/children.json")
	check(children.error.is_empty() and children.entries[0].name == "Parent miniature / component 1" and children.entries[0].credit == "Parent credit", "Child meshes without names inherit a searchable parent identity and credit")
	var definition := "40kdc:11e:adeptus-astartes:intercessor-squad"
	var matcher := preload("res://scripts/forceorg_matcher.gd")
	var first := {"name": "Intercessor", "kind": "CustomMesh", "references": {"MeshURL": "https://example.invalid/mesh1", "DiffuseURL": "https://example.invalid/blue"}}
	var repaint := first.duplicate(true)
	repaint.references.DiffuseURL = "https://example.invalid/red"
	var second := first.duplicate(true)
	second.references.MeshURL = "https://example.invalid/mesh2"
	var options := matcher.variants(definition, [first, repaint, second])
	check(options.size() == 3 and matcher.geometry_identity(first) == matcher.geometry_identity(repaint), "Repaints remain manually selectable without counting as distinct sculpts")
	var repeated_source_one := first.duplicate(true)
	repeated_source_one.guid = "aaaaaa"
	repeated_source_one.path = "ObjectStates/1/LuaScript/objectJSONs/1"
	var repeated_source_two := first.duplicate(true)
	repeated_source_two.guid = "bbbbbb"
	repeated_source_two.path = "ObjectStates/2/LuaScript/objectJSONs/2"
	var repeated_sources := matcher.variants(definition, [repeated_source_one, repeated_source_two])
	check(repeated_sources.size() == 2 and repeated_sources[0].variant_id != repeated_sources[1].variant_id, "Repeated same-name TTS entries retain separate GUID/path identities")
	check(matcher.geometry_identity(repeated_sources[0]) == matcher.geometry_identity(repeated_sources[1]), "Repeated TTS identities still deduplicate to one automatic sculpt geometry")
	var selection_panel := ImportPanel.new()
	var chosen := selection_panel._requested_variants(options, 2, [])
	check(chosen.size() == 2 and matcher.geometry_identity(chosen[0]) != matcher.geometry_identity(chosen[1]), "Automatic appearances choose distinct sculpt geometry")
	var manual := selection_panel._requested_variants(options, 0, [options[1].variant_id])
	check(manual.size() == 1 and manual[0].variant_id == options[1].variant_id, "Preparing a manual assignment requests that exact catalog variant")
	var variant_root := "res://.tools/catalog-test/appearance-cache"
	DirAccess.make_dir_recursive_absolute(variant_root)
	var sculpt := "v -0.5 0 -0.5\nv 0.5 0 -0.5\nv 0 1 0\nv 0 0 0.5\nf 1 2 3\nf 1 3 4\nf 2 4 3\n"
	var sources: Array[Dictionary] = []
	for mesh_name: String in ["model1", "model2"]:
		var url := "https://example.invalid/" + mesh_name
		var mesh_file := FileAccess.open(variant_root.path_join(Assets.cache_key(url) + ".obj"), FileAccess.WRITE)
		mesh_file.store_string(sculpt)
		mesh_file.close()
		sources.append({"Name": "Custom_Model", "Nickname": "Intercessor", "CustomMesh": {"MeshURL": url}})
	var source_file := FileAccess.open(variant_root.path_join("source.json"), FileAccess.WRITE)
	source_file.store_string(JSON.stringify({"ObjectStates": sources}))
	source_file.close()
	selection_panel.settings_path = variant_root.path_join("fixture-%d.cfg" % OS.get_process_id())
	root.add_child(selection_panel)
	selection_panel.source_path.text = variant_root.path_join("source.json")
	selection_panel.download_path.text = variant_root
	var requested := {definition: {"count": 2, "manual": []}}
	check(selection_panel.prepare_armies([definition], false, false, requested), "Match preparation accepts automatic appearance slots")
	for frame in 30:
		if not selection_panel.automatic_running: break
		await process_frame
	var slot_one := selection_panel.automatic_variant_for(definition, 0)
	var slot_two := selection_panel.automatic_variant_for(definition, 1)
	check(not slot_one.is_empty() and not slot_two.is_empty() and slot_one != slot_two, "Match preparation loads two distinct cached variants without network access")
	selection_panel.free()
	var panel := ImportPanel.new()
	panel.settings_path = "res://.tools/catalog-test/settings.cfg"
	root.add_child(panel)
	panel.catalog = {"entries": []}
	for index in range(260): panel.catalog.entries.append({"name": "Model %d" % index, "path": str(index), "kind": "CustomMesh", "references": {}, "id": str(index)})
	panel._populate_inventory()
	check(panel.inventory.item_count == 200, "Large catalogs bound the displayed list")
	panel.inventory_filter.text = "Model 259"
	panel.inventory_filter.text_changed.emit(panel.inventory_filter.text)
	await panel.inventory_search_timer.timeout
	check(panel.inventory.item_count == 1 and panel._selected_entry().id == "259", "Filtered selection resolves the original catalog identity beyond the first page")
	panel.inventory_filter.text = "not in catalog"
	panel.inventory_filter.text_changed.emit(panel.inventory_filter.text)
	await panel.inventory_search_timer.timeout
	check(panel.inventory.item_count == 0 and panel.preview_asset.is_empty(), "No-match search clears old model candidates")
	panel.catalog.entries = [{"name": "Ripper Swarm", "path": "first", "kind": "CustomMesh", "references": {}, "id": "one", "guid": "aaaaaa"}, {"name": "Ripper Swarm", "path": "second", "kind": "CustomMesh", "references": {}, "id": "two", "guid": "bbbbbb"}]
	panel.inventory_filter.text = "Ripper"
	panel._populate_inventory()
	check("Option 1/2" in panel.inventory.get_item_text(0) and "GUID aaaaaa" in panel.inventory.get_item_text(0) and not "CustomMesh" in panel.inventory.get_item_text(0) and not "first" in panel.inventory.get_item_text(0), "Picker uses readable names and disambiguates repeated entries by TTS GUID")
	panel.catalog.entries = [{"name": "Intercessor / component 1", "path": "ObjectStates/1/ChildObjects/0", "kind": "CustomMesh", "references": {}, "id": "part", "guid": "cccccc"}]
	panel.inventory_filter.text = "Intercessor"
	panel._populate_inventory()
	check("not the complete miniature" in panel.selected_description.text, "Component picker explains how to select the complete parent assembly")
	check(panel._entry_title({"name": "32mm", "kind": "CustomMesh"}).begins_with("Base:"), "Named bases are identifiable")
	check("Part 1" in panel._entry_title({"name": "Necron / component 1", "kind": "CustomMesh"}), "Child components have a readable label")
	print("Static ForceOrg catalog checks: %d failures" % failures)
	quit(0 if failures == 0 else 1)
