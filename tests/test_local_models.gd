extends SceneTree
const Assets = preload("res://scripts/local_models.gd")
const ImportPanel = preload("res://scripts/model_import_panel.gd")
var failures := 0
const ROOT = "res://.tools/model-import-test"
const OBJ = "v -1 0 -1\nv 1 0 -1\nv 1 0 1\nv -1 0 1\nv 0 3 0\nvt 0 0\nvt 1 0\nvt 1 1\nf 1/1 2/2 5/3\nf 2 3 5\nf -3 -2 -1\nf 4 1 5\nf 4 3 2 1\n"
func write(path: String, content: String) -> void:
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_string(content)
func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1
func _initialize() -> void: call_deferred("run")
func run() -> void:
	DirAccess.make_dir_recursive_absolute(ROOT)
	write(ROOT.path_join("mesh.obj"), OBJ)
	var save := {"ObjectStates": [{"Nickname": "Army", "ContainedObjects": [{"Nickname": "Duplicate", "GUID": "aaaaaa", "CustomMesh": {"MeshURL": "https://example.invalid/model", "DiffuseURL": "https://example.invalid/texture"}, "LuaScript": "error('must never run')", "States": {"2": {"Nickname": "Duplicate", "CustomAssetbundle": {"AssetbundleURL": "https://example.invalid/bundle"}}}}]}]}
	write(ROOT.path_join("ForceOrg.json"), JSON.stringify(save))
	var scanned := Assets.scan(ROOT)
	check(scanned.error.is_empty() and scanned.objects == 3 and scanned.entries.size() == 2, "Directory scan reads ForceOrg.json, containers and alternate states")
	check(scanned.entries[0].id != scanned.entries[1].id and scanned.entries[0].name == scanned.entries[1].name, "Duplicate names preserve distinct source identities")
	var mesh := Assets.obj_mesh(ROOT.path_join("mesh.obj"))
	check(mesh.error.is_empty() and mesh.bounds.size.y == 3, "OBJ triangulation, negative indices and mixed optional UV data")
	var image := Image.create(4, 4, false, Image.FORMAT_RGBA8)
	image.fill(Color.RED)
	image.save_png(ROOT.path_join("diffuse.png"))
	var textured := Assets.obj_mesh(ROOT.path_join("mesh.obj"), ROOT.path_join("diffuse.png"))
	check(textured.error.is_empty() and textured.mesh.surface_get_material(0).albedo_texture != null, "Explicit local diffuse texture loads without editor import")
	image.save_jpg(ROOT.path_join("extensionless-texture"))
	check(Assets.obj_mesh(ROOT.path_join("mesh.obj"), ROOT.path_join("extensionless-texture")).error.is_empty(), "Extensionless JPEG textures decode by content")
	image.save_jpg(ROOT.path_join("actually-jpeg.png"))
	check(Assets.obj_mesh(ROOT.path_join("mesh.obj"), ROOT.path_join("actually-jpeg.png")).error.is_empty(), "Mislabeled cached image extensions do not choose the wrong decoder")
	write(ROOT.path_join("bad.obj"), "v 0 0 0\nf 1 2 3\n")
	check(not Assets.obj_mesh(ROOT.path_join("bad.obj")).error.is_empty(), "Invalid indices reject")
	write(ROOT.path_join("bad.obj"), "v nan 0 0\n")
	check(not Assets.obj_mesh(ROOT.path_join("bad.obj")).error.is_empty(), "Non-finite coordinates reject")
	write(ROOT.path_join("bad.json"), "{broken")
	check(not Assets.scan(ROOT.path_join("bad.json")).error.is_empty(), "Malformed JSON rejects")
	write(ROOT.path_join("bad.json"), JSON.stringify({"ObjectStates": [{"CustomMesh": {"MeshURL": 17}}]}))
	check(not Assets.scan(ROOT.path_join("bad.json")).error.is_empty(), "Non-string source references reject")
	check(not Assets.obj_mesh(ROOT.path_join("mesh.obj"), ROOT.path_join("missing.png")).error.is_empty(), "Missing requested texture rejects")
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	for frame in range(4): await process_frame
	var baseline_width: float = game.sidebar_panel.size.x
	game._start_allocation_practice()
	game.model_imports.settings_path = ROOT.path_join("settings.cfg")
	game.model_imports.mappings = {}
	game.model_imports.cache = {}
	game.model_imports.source_path.text = ROOT.path_join("ForceOrg.json")
	game.model_imports.scan_source()
	game.model_imports.mesh_path.text = ROOT.path_join("mesh.obj")
	game.model_imports.load_preview()
	game.match_tabs.current_tab = 2
	for frame in range(4): await process_frame
	check(game.sidebar_panel.size.x <= baseline_width, "Long source entries do not expand the sidebar over the board")
	var before := var_to_str(game.state)
	game.model_imports.scale_input.value = 1.2
	game.model_imports.rotation_input.value = 45
	game.model_imports.offset_input.value = 0.1
	game.model_imports.apply_mapping()
	var definition: String = game.state.units[100].definition_id
	check(game.model_imports.mappings.has(definition) and game.pieces[100].get_meta("imported_visual", false), "Applying a selected local visual renders the mapped unit type")
	check(var_to_str(game.state) == before and is_equal_approx(game.pieces[100].position.y, 0.04), "Visual mapping leaves all gameplay state intact and the base on the board")
	game.model_imports.apply_mapping()
	check(not "Could not save" in game.model_imports.notice.text, "Existing settings can be replaced")
	var reloaded := ImportPanel.new()
	reloaded.settings_path = ROOT.path_join("settings.cfg")
	root.add_child(reloaded)
	check(reloaded.mappings.has(definition) and reloaded.mappings[definition].rotation == 45, "Mappings and transforms survive reload")
	var visual := reloaded.visual_for(definition)
	check(visual != null, "Reloaded local model can be instantiated")
	if visual != null: visual.free()
	write(ROOT.path_join("mesh.obj"), OBJ + "# changed\n")
	var fresh := ImportPanel.new()
	fresh.settings_path = ROOT.path_join("settings.cfg")
	root.add_child(fresh)
	check(fresh.visual_for(definition) == null and "changed" in fresh.notice.text, "Changed files fall back pending explicit preview and reassignment")
	check(fresh.visual_for("unmapped-peer") == null, "Unmapped peers retain placeholders")
	var missing := ImportPanel.new()
	missing.settings_path = ROOT.path_join("unused.cfg")
	root.add_child(missing)
	missing.mappings[definition] = game.model_imports.mappings[definition].duplicate(true)
	missing.mappings[definition].path = ROOT.path_join("missing.obj")
	check(missing.visual_for(definition) == null, "A saved mapping with an absent mesh returns a placeholder")
	var invalid := ConfigFile.new()
	invalid.set_value("models", "version", 1)
	invalid.set_value("models", "mappings", {definition: {"path": "missing.obj", "scale": -2, "rotation": 0, "offset": 0}})
	invalid.save(ROOT.path_join("invalid.cfg"))
	var bad_settings := ImportPanel.new()
	bad_settings.settings_path = ROOT.path_join("invalid.cfg")
	root.add_child(bad_settings)
	check(bad_settings.mappings.is_empty(), "Invalid saved transforms are ignored")
	game.model_imports.remove_mapping()
	check(not game.pieces[100].get_meta("imported_visual", false) and var_to_str(game.state) == before, "Removal restores placeholders without gameplay changes")
	print("Local ForceOrg model checks: %d failures" % failures)
	quit(0 if failures == 0 else 1)

