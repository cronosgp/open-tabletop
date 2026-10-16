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
	var record := {"Name": "Custom_Model", "Nickname": "Test miniature ]]", "Description": "Original fixture credit", "CustomMesh": {"MeshURL": "https://example.invalid/test"}}
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
	check(scanned.error.is_empty() and scanned.embedded_objects == 1 and scanned.entries[0].credit == record.Description and "objectJSONs" in scanned.entries[0].path, "Scanner retains embedded source identity and credits")
	file = FileAccess.open("res://.tools/catalog-test/children.json", FileAccess.WRITE)
	file.store_string(JSON.stringify({"ObjectStates": [{"Nickname": "Parent miniature", "Description": "Parent credit", "ChildObjects": [{"Name": "Custom_Model", "Nickname": null, "CustomMesh": {"MeshURL": "https://example.invalid/component"}}]}]}))
	file.close()
	var children := Assets.scan("res://.tools/catalog-test/children.json")
	check(children.error.is_empty() and children.entries[0].name == "Parent miniature / component 1" and children.entries[0].credit == "Parent credit", "Child meshes without names inherit a searchable parent identity and credit")
	var panel := ImportPanel.new()
	panel.settings_path = "res://.tools/catalog-test/settings.cfg"
	root.add_child(panel)
	panel.catalog = {"entries": []}
	for index in range(260): panel.catalog.entries.append({"name": "Model %d" % index, "path": str(index), "kind": "CustomMesh", "references": {}, "id": str(index)})
	panel._populate_inventory()
	check(panel.inventory.item_count == 200, "Large catalogs bound the displayed list")
	panel.inventory_filter.text = "Model 259"
	panel.inventory_filter.text_changed.emit(panel.inventory_filter.text)
	check(panel.inventory.item_count == 1 and panel._selected_entry().id == "259", "Filtered selection resolves the original catalog identity beyond the first page")
	panel.inventory_filter.text = "not in catalog"
	panel.inventory_filter.text_changed.emit(panel.inventory_filter.text)
	check(panel.inventory.item_count == 0 and panel.preview_asset.is_empty(), "No-match search clears old model candidates")
	panel.catalog.entries = [{"name": "Ripper Swarm", "path": "first", "kind": "CustomMesh", "references": {}, "id": "one"}, {"name": "Ripper Swarm", "path": "second", "kind": "CustomMesh", "references": {}, "id": "two"}]
	panel.inventory_filter.text = "Ripper"
	panel._populate_inventory()
	check("Option 1/2" in panel.inventory.get_item_text(0) and not "CustomMesh" in panel.inventory.get_item_text(0) and not "first" in panel.inventory.get_item_text(0), "Picker uses readable names and disambiguates repeated entries without raw paths")
	check(panel._entry_title({"name": "32mm", "kind": "CustomMesh"}).begins_with("Base:"), "Named bases are identifiable")
	check("Part 1" in panel._entry_title({"name": "Necron / component 1", "kind": "CustomMesh"}), "Child components have a readable label")
	print("Static ForceOrg catalog checks: %d failures" % failures)
	quit(0 if failures == 0 else 1)
