extends SceneTree
const Assets = preload("res://scripts/local_models.gd")
const ImportPanel = preload("res://scripts/model_import_panel.gd")
const ROOT = "res://.tools/cache-import-test"
const MESH_URL = "https://example.invalid/ugc/123456/ABCDEF/"
const IMAGE_URL = "https://example.invalid/ugc/456789/DIFFUSE/"
var failures := 0
func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1
func write(path: String, text: String) -> void:
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_string(text)
func _initialize() -> void: call_deferred("run")
func run() -> void:
	DirAccess.make_dir_recursive_absolute(ROOT.path_join("Models"))
	DirAccess.make_dir_recursive_absolute(ROOT.path_join("Images"))
	var duplicate := ROOT.path_join("Models/copy/") + Assets.cache_key(MESH_URL) + ".obj"
	if FileAccess.file_exists(duplicate): DirAccess.remove_absolute(duplicate)
	var mesh_path := ROOT.path_join("Models/") + Assets.cache_key(MESH_URL) + ".obj"
	var image_path := ROOT.path_join("Images/") + Assets.cache_key(IMAGE_URL) + ".png"
	write(mesh_path, "v 0 0 0\nv 1 0 0\nv 0 2 0\nf 1 2 3\n")
	var image := Image.create(4, 4, false, Image.FORMAT_RGBA8)
	image.fill(Color.GREEN)
	image.save_png(image_path)
	write(ROOT.path_join("Models/unrelated.obj"), "not the requested asset")
	var entry := {"kind": "CustomMesh", "references": {"MeshURL": MESH_URL, "DiffuseURL": IMAGE_URL}}
	var index := Assets.index_cache(ROOT)
	check(index.error.is_empty(), "Nested local cache indexes")
	var resolved := Assets.resolve_cache(entry, index)
	check(resolved.mesh.path == mesh_path and resolved.diffuse.path == image_path, "Full URL keys resolve mesh and diffuse in separate folders")
	check(Assets.cache_match("{verifycache}" + MESH_URL, index).path == mesh_path, "Verify-cache prefix is accepted without network access")
	check(Assets.cache_match("https://other.invalid/ABCDEF/", index).status == "missing", "Shared basename or ID alone is not enough to match")
	check(Assets.cache_match("file:///outside/model.obj", index).status == "missing", "Local source paths cannot escape selected cache lookup")
	var extensionless_url := "https://example.invalid/ugc/987654/EXTENSIONLESS/"
	write(ROOT.path_join("Models/") + Assets.cache_key(extensionless_url), "v 0 0 0\n")
	var extensionless := Assets.cache_match(extensionless_url, Assets.index_cache(ROOT))
	check(extensionless.status == "found", "Extensionless URL-derived cache names are supported")
	check(Assets.cache_match("https://example.invalid/" + "a".repeat(4096), index).status == "missing", "Excessive references reject bounded lookup")
	check(not Assets.resolve_cache({"kind": "CustomAssetbundle"}, index).error.is_empty(), "AssetBundles are not matched as OBJ")
	var panel := ImportPanel.new()
	panel.settings_path = ROOT.path_join("settings.cfg")
	root.add_child(panel)
	panel.catalog = {"entries": [entry]}
	panel.inventory.add_item("Synthetic cached model")
	panel.cache_path.text = ROOT
	panel.find_cached_files()
	check(not panel.preview_asset.is_empty() and panel.mesh_path.text == mesh_path and panel.texture_path.text == image_path, "Complete unique matches load the preview")
	var before := panel.mappings.duplicate(true)
	check(panel._save(panel.mappings), "Cache folder setting saves")
	var reload := ImportPanel.new()
	reload.settings_path = panel.settings_path
	root.add_child(reload)
	check(reload.cache_path.text == ROOT, "Cache folder persists across reload")
	DirAccess.make_dir_recursive_absolute(ROOT.path_join("Models/copy"))
	write(duplicate, "different content")
	panel.find_cached_files()
	check(panel.preview_asset.is_empty() and panel.mesh_path.text.is_empty() and "ambiguous" in panel.notice.text, "Duplicate candidates clear stale preview and require manual selection")
	check(panel.mappings == before, "Automatic lookup never changes mappings")
	panel.cache_path.text = ROOT.path_join("missing")
	panel.mesh_path.text = "stale.obj"
	panel.find_cached_files()
	check(panel.mesh_path.text.is_empty() and panel.preview_asset.is_empty(), "Invalid folder cannot retain an earlier object's files")
	var missing_image_entry := entry.duplicate(true)
	missing_image_entry.references.DiffuseURL = "https://example.invalid/uncached-image.png"
	panel.catalog.entries[0] = missing_image_entry
	DirAccess.remove_absolute(duplicate)
	panel.cache_path.text = ROOT
	panel.find_cached_files()
	check(panel.preview_asset.is_empty() and panel.texture_path.text.is_empty(), "A declared but absent texture does not silently become an untextured preview")
	panel.catalog.entries[0] = {"kind": "CustomMesh", "references": {"MeshURL": MESH_URL}}
	panel.find_cached_files()
	check(not panel.preview_asset.is_empty() and panel.texture_path.text.is_empty(), "Models without a declared diffuse reference may preview untextured")
	print("Local cache lookup checks: %d failures" % failures)
	quit(0 if failures == 0 else 1)
