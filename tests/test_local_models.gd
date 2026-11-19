extends SceneTree
const Assets = preload("res://scripts/local_models.gd")
const ImportPanel = preload("res://scripts/model_import_panel.gd")
const ModelShowcase = preload("res://scripts/ui/model_showcase.gd")
const MarineProfiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
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
func _camera_motion_enabled() -> bool: return true
func _camera_motion_reduced() -> bool: return false
func _initialize() -> void: call_deferred("run")
func run() -> void:
	DirAccess.make_dir_recursive_absolute(ROOT)
	write(ROOT.path_join("mesh.obj"), OBJ)
	var save := {"ObjectStates": [{"Nickname": "Army", "ContainedObjects": [{"Nickname": "Duplicate", "GUID": "aaaaaa", "Transform": {"posX": 0, "posY": 0, "posZ": 0, "rotX": 0, "rotY": 0, "rotZ": 0, "scaleX": 1.5, "scaleY": 1.5, "scaleZ": 1.5}, "CustomMesh": {"MeshURL": "https://example.invalid/model", "DiffuseURL": "https://example.invalid/texture"}, "LuaScript": "error('must never run')", "States": {"2": {"Nickname": "Duplicate", "CustomAssetbundle": {"AssetbundleURL": "https://example.invalid/bundle"}}}}]}]}
	write(ROOT.path_join("ForceOrg.json"), JSON.stringify(save))
	var scanned := Assets.scan(ROOT)
	check(scanned.error.is_empty() and scanned.objects == 3 and scanned.entries.size() == 2, "Directory scan reads ForceOrg.json, containers and alternate states")
	check(scanned.entries[0].id != scanned.entries[1].id and scanned.entries[0].name == scanned.entries[1].name, "Duplicate names preserve distinct source identities")
	check(scanned.source_objects.is_empty() and not scanned.source_objects_included, "Normal scans avoid building the optional full-object inventory")
	var object_scan := Assets.scan(ROOT.path_join("ForceOrg.json"), true)
	var object_paths := {}
	for record: Dictionary in object_scan.source_objects: object_paths[record.path] = record
	check(object_scan.source_objects.size() == object_scan.objects and object_scan.objects == 3, "Optional inventory includes containers, visuals and alternate states exactly once")
	check(object_paths["ObjectStates/0/ContainedObjects/0"].parent_path == "ObjectStates/0" and object_paths["ObjectStates/0/ContainedObjects/0/States/2"].parent_path == "ObjectStates/0/ContainedObjects/0", "Object inventory preserves actual object parents across containment and states")
	var source_path := ROOT.path_join("ForceOrg.json")
	var source_fingerprint := FileAccess.get_sha256(source_path)
	var scan_cache_path := ProjectSettings.globalize_path("user://forceorg-scan-cache-v1.bin")
	var corrupt_scan_cache := FileAccess.open(scan_cache_path, FileAccess.WRITE)
	if corrupt_scan_cache != null:
		corrupt_scan_cache.store_var({"version": Assets.CATALOG_SCAN_CACHE_VERSION, "source": source_path, "fingerprint": source_fingerprint,
			"objects": 3, "embedded_objects": 0, "warnings": [], "entries": "corrupt catalog entries"}, false)
		corrupt_scan_cache.close()
	var recovered_scan := Assets.scan(ROOT)
	var repaired_cache_file := FileAccess.open(scan_cache_path, FileAccess.READ)
	var repaired_cache: Variant = repaired_cache_file.get_var(false) if repaired_cache_file != null else null
	if repaired_cache_file != null: repaired_cache_file.close()
	var cached_scan := Assets.scan(ROOT)
	check(recovered_scan.error.is_empty() and recovered_scan.entries.size() == scanned.entries.size() and cached_scan.entries.size() == scanned.entries.size(),
		"A malformed but readable local catalog cache is discarded, rebuilt from source and reused")
	check(repaired_cache is Dictionary and repaired_cache.get("entries", null) is Array and str(repaired_cache.get("fingerprint", "")) == source_fingerprint,
		"Cache recovery replaces the malformed record with a schema-valid source fingerprint")
	var grouped_save := {"ObjectStates": [
		{"GUID": "menu01", "LuaScript": "Ultramarines = getObjectFromGUID(\"abc123\")"},
		{"GUID": "abc123", "Nickname": "Intercessor", "CustomMesh": {"MeshURL": "https://example.invalid/grouped.obj"}}
	]}
	write(ROOT.path_join("ForceOrg-grouped.json"), JSON.stringify(grouped_save))
	var grouped_scan := Assets.scan(ROOT.path_join("ForceOrg-grouped.json"))
	check(grouped_scan.error.is_empty() and grouped_scan.entries.size() == 1 and grouped_scan.entries[0].get("source_group_hint", "") == "Ultramarines", "TTS menu group is preserved as a static paint-family hint without executing Lua")
	var painted := {"Nickname": "Example rifle", "CustomMesh": {"MeshURL": "body-a", "DiffuseURL": "shared-texture"}, "ColorDiffuse": {"r": 1, "g": 1, "b": 1}}
	var alternative := painted.duplicate(true)
	alternative.CustomMesh.MeshURL = "body-b"
	var material_family := Assets._static_material_family(painted)
	check(not material_family.is_empty() and material_family == Assets._static_material_family(alternative), "Different sculpts can share a complete static material family")
	alternative.ColorDiffuse.r = 0.5
	check(material_family != Assets._static_material_family(alternative), "Source tint differences separate material families")
	alternative = painted.duplicate(true)
	alternative.CustomMesh.DiffuseURL = "another-texture"
	check(material_family != Assets._static_material_family(alternative), "Different texture references separate material families")
	var assembly := {"CustomMesh": {"MeshURL": "base-a", "DiffuseURL": ""}, "ChildObjects": [painted]}
	var other_assembly := assembly.duplicate(true)
	other_assembly.CustomMesh.MeshURL = "base-b"
	check(Assets._static_material_family(assembly) != Assets._static_material_family(other_assembly), "Untextured parts require the same geometry as well as materials")
	check(Assets._static_material_family({"CustomMesh": {"MeshURL": "unpainted"}}).is_empty(), "An entirely untextured assembly has no inferred family")
	other_assembly = assembly.duplicate(true)
	other_assembly.ChildObjects.append({"CustomAssetbundle": {"AssetbundleURL": "unknown-materials"}})
	check(Assets._static_material_family(other_assembly).is_empty(), "Unknown bundle materials prevent family inference")
	other_assembly = assembly.duplicate(true)
	other_assembly.ChildObjects.append({"Name": "Cube"})
	check(Assets._static_material_family(other_assembly).is_empty(), "Unsupported built-in child materials prevent family inference")
	write(ROOT.path_join("ForceOrg-material-family.json"), JSON.stringify({"ObjectStates": [assembly]}))
	var material_scan := Assets.scan(ROOT.path_join("ForceOrg-material-family.json"))
	check(material_scan.error.is_empty() and not material_scan.entries[0].get("material_family_hint", "").is_empty() and material_scan.entries[0].get("source_group_hint", "").is_empty(), "Scanner stores derived families without inventing original source groups")
	check(Assets.visual_family_hint({"source_group_hint": "Ultramarines", "material_family_hint": material_family}) == "ultramarines", "An explicit source group takes priority over a derived family")
	var mesh_entry: Dictionary = scanned.entries[0] if scanned.entries[0].kind == "CustomMesh" else scanned.entries[1]
	check(is_equal_approx(float(mesh_entry.tts_scale), 1.5), "ForceOrg Transform scale is retained for tabletop sizing")
	var source_entry := mesh_entry.duplicate(true)
	source_entry.preserve_source_pose = true
	source_entry.root_transform = {"position": [50, 1, -32], "rotation": [0, 90, 0], "scale": [-2, 1, 3]}
	var source_plan := Assets.component_plan(source_entry)
	var source_records: Array = source_plan.components[0].transforms
	source_records.append({"position": [1, 2, 0], "rotation": [0, 0, 0], "scale": [1, 1, 1]})
	var source_transform := Assets.component_transform(source_records)
	check(source_transform.origin.is_equal_approx(Vector3(0, 2, 2)), "Root pose omits table translation and transforms child offsets in source-local axes")
	check(source_transform.basis.z.is_equal_approx(Vector3(3, 0, 0)) and source_transform.basis.determinant() < 0.0, "Root pose preserves nonuniform and signed scale")
	var unity_euler := Vector3(23.0, 41.0, 67.0)
	var euler_transform := Assets.component_transform([{"position": [0, 0, 0], "rotation": [unity_euler.x, unity_euler.y, unity_euler.z], "scale": [1, 1, 1]}])
	var expected_unity_rotation := Basis.from_euler(Vector3(deg_to_rad(unity_euler.x), deg_to_rad(unity_euler.y), deg_to_rad(unity_euler.z)), EULER_ORDER_ZXY)
	check(euler_transform.basis.is_equal_approx(expected_unity_rotation), "TTS root Euler rotations use Unity ZXY order instead of Godot's YXZ default")
	var fitted_asset := {"source_pose": true, "base_detection": "ring", "base_rim_coverage": true, "base_footprint": Vector2(3.0, 1.5)}
	var circle := {"base_radius_inches": 1.5}
	var ellipse := {"base_radius_inches": 1.5, "visual_base_axes_inches": Vector2(3.0, 1.5)}
	check(not Assets.visual_error_for_base(fitted_asset, circle).is_empty(), "An oval cannot be stretched to fit a circle")
	check(Assets.visual_error_for_base(fitted_asset, ellipse).is_empty(), "A source oval with the right aspect ratio fits both axes")
	var full_infantry := {"bounds": AABB(Vector3(-0.6, 0.0, -0.6), Vector3(1.2, 1.6, 1.2)), "source_pose": true, "base_detection": "ring", "base_rim_coverage": true, "base_footprint": Vector2.ONE * (32.0 / 25.4)}
	var infantry_fit := {"base_radius_inches": 16.0 / 25.4, "require_full_miniature": true}
	var head_only := full_infantry.duplicate()
	head_only.bounds = AABB(Vector3(-0.2, 0.0, -0.2), Vector3(0.4, 0.35, 0.4))
	check(Assets.visual_error_for_base(full_infantry, infantry_fit).is_empty(), "A complete Intercessor-sized infantry assembly passes the completeness gate")
	check(not Assets.visual_error_for_base(head_only, infantry_fit).is_empty(), "A head-sized infantry component is rejected before linking")
	var unguarded_visual := Assets.visual_error_for_base(head_only, {"base_radius_inches": 16.0 / 25.4})
	check(unguarded_visual.is_empty(), "The completeness gate is profile-scoped rather than a general height rule")
	var mesh := Assets.obj_mesh(ROOT.path_join("mesh.obj"))
	check(mesh.error.is_empty() and mesh.bounds.size.y == 3, "OBJ triangulation, negative indices and mixed optional UV data")
	var hull := mesh.duplicate()
	hull.source_pose = true
	var hull_settings := {"base_radius_inches": 1.0, "visual_hull_proxy": true}
	check(not Assets.visual_error_for_base(hull, hull_settings).is_empty(), "A hull requires explicit mount review")
	hull_settings.reviewed_hull_mount = {"scale": 2.0, "contact_offset": Vector3(0.25, 0.5, -0.25)}
	check(Assets.visual_error_for_base(hull, hull_settings).is_empty(), "A reviewed mount permits a baseless hull")
	var hull_visual := Assets.visual(hull, hull_settings)
	var mounted_geometry: Node3D = hull_visual.get_child(0)
	check(mounted_geometry.position.is_equal_approx(Vector3(-0.5, -1.0, 0.5)) and mounted_geometry.scale == Vector3.ONE * 2.0, "Reviewed hull contact maps to the board origin")
	check(hull_visual.get_meta("asset_base_footprint_inches") == Vector2.ZERO, "A reviewed hull retains the separate gameplay proxy")
	hull_visual.free()
	var packaged := Assets.prepare_glb(mesh, {"base_radius_inches": 1.0}, {"fixture": "synthetic OBJ"})
	check(packaged.error.is_empty(), "Static inspection package exports a local GLB: " + str(packaged.error))
	var rejected_package := Assets.prepare_glb(head_only.merged({"mesh": mesh.mesh, "fingerprint": "head-only-fixture"}), infantry_fit, {"fixture": "head-only OBJ"})
	check(not rejected_package.error.is_empty(), "A detached head cannot be frozen into a prepared GLB package")
	if packaged.error.is_empty():
		var document := GLTFDocument.new()
		var gltf_state := GLTFState.new()
		check(document.append_from_file(packaged.path, gltf_state) == OK and gltf_state.get_meshes().size() == 1, "Prepared GLB reopens with its expected mesh")
		var settings := {"base_radius_inches": 1.0}
		var prepared := Assets.load_prepared_glb(packaged.key, mesh.fingerprint, settings)
		check(not prepared.is_empty(), "Runtime cache loads a prepared GLB for its original fit")
		if not prepared.is_empty():
			var instance: Node3D = prepared.scene.instantiate()
			check(not instance.find_children("*", "MeshInstance3D").is_empty(), "Prepared scene retains visible meshes when instanced")
			instance.free()
		var package_panel := ImportPanel.new()
		package_panel.settings_path = ROOT.path_join("unused-package.cfg")
		root.add_child(package_panel)
		package_panel.mappings["prepared-fixture"] = {"path": ROOT.path_join("mesh.obj"), "fingerprint": mesh.fingerprint,
			"texture_fingerprint": mesh.texture_fingerprint, "prepared_key": packaged.key}
		var prepared_visual := package_panel.visual_for("prepared-fixture", 1.0)
		check(prepared_visual != null and not package_panel.cache.has("prepared-fixture"), "Match visual uses the GLB without parsing the original mesh")
		var prepared_visual_second := package_panel.visual_for("prepared-fixture", 1.0)
		var first_mesh_nodes: Array[Node] = prepared_visual.find_children("*", "MeshInstance3D", true, false) if prepared_visual != null else []
		var second_mesh_nodes: Array[Node] = prepared_visual_second.find_children("*", "MeshInstance3D", true, false) if prepared_visual_second != null else []
		var shared_cached_glb_mesh := first_mesh_nodes.size() == 1 and second_mesh_nodes.size() == 1 and first_mesh_nodes[0] != second_mesh_nodes[0] and (first_mesh_nodes[0] as MeshInstance3D).mesh == (second_mesh_nodes[0] as MeshInstance3D).mesh
		check(prepared_visual != null and prepared_visual_second != null and shared_cached_glb_mesh, "Separate miniature instances reuse the prepared GLB mesh resource without sharing scene nodes")
		if prepared_visual != null: prepared_visual.free()
		if prepared_visual_second != null: prepared_visual_second.free()
		var fallback_visual := package_panel.visual_for("prepared-fixture", 1.25)
		check(fallback_visual != null and package_panel.cache.has("prepared-fixture"), "A different match base falls back to the original mesh")
		if fallback_visual != null: fallback_visual.free()
		package_panel.free()
		check(Assets.load_prepared_glb(packaged.key, mesh.fingerprint, {"base_radius_inches": 1.25}).is_empty(), "A different base uses the source loader")
		write(ROOT.path_join("mesh.obj"), OBJ + "# changed source\n")
		check(Assets.load_prepared_glb(packaged.key, mesh.fingerprint, settings).is_empty(), "Changed source invalidates the prepared GLB")
		write(ROOT.path_join("mesh.obj"), OBJ)
	var oval_ring: Array[Vector3] = []
	for index in 64:
		var angle := TAU * float(index) / 64.0
		oval_ring.append(Vector3(3.0 + cos(angle) * 1.2, 0.0, -2.0 + sin(angle) * 0.7))
	oval_ring.append(Vector3(3.0, 3.0, -2.0))
	var oval_base := Assets._base_reference(oval_ring, AABB(Vector3(1.8, 0.0, -2.7), Vector3(2.4, 3.0, 1.4)))
	check(oval_base.detection == "ring" and absf(oval_base.size.x - 2.4) < 0.05 and absf(oval_base.size.y - 1.4) < 0.05, "Oval ring detection preserves its two dimensions")
	check(Vector2(oval_base.center.x, oval_base.center.y).distance_to(Vector2(3.0, -2.0)) < 0.05, "Base ring center follows the imported footprint instead of the full model bounds")
	var uneven_ring := oval_ring.duplicate()
	for index in 200:
		var angle := 0.2 + float(index) / 199.0 * 0.4
		uneven_ring.append(Vector3(3.0 + cos(angle) * 1.2, 0.0, -2.0 + sin(angle) * 0.7))
	var uneven_reference := Assets._base_reference(uneven_ring, AABB(Vector3(1.8, 0.0, -2.7), Vector3(2.4, 3.0, 1.4)))
	check(uneven_reference.center.distance_to(Vector2(3.0, -2.0)) < 0.05, "Nonuniform OBJ vertex density does not pull the detected base center")
	var offset_base_asset := {"bounds": AABB(Vector3.ZERO, Vector3(4.0, 3.0, 4.0)), "base_footprint": oval_base.size, "base_center": oval_base.center, "base_center_y": oval_base.center_y, "base_detection": "ring", "mesh": ArrayMesh.new()}
	var centered_visual := Assets.visual(offset_base_asset, {"base_radius_inches": 1.2, "scale": 1.0})
	var centered_geometry := centered_visual.get_child(0) as Node3D
	var centered_ring := centered_geometry.transform * Vector3(oval_base.center.x, oval_base.center_y, oval_base.center.y)
	check(centered_ring.length() * 25.4 <= 0.5, "Detected base center and underside align to the marker origin within 0.5 mm")
	centered_visual.free()
	var incomplete_ring: Array[Vector3] = []
	for index in 64:
		var angle := TAU * float(index) / 64.0
		if angle < deg_to_rad(30.0): continue
		incomplete_ring.append(Vector3(3.0 + cos(angle) * 1.2, 0.0, -2.0 + sin(angle) * 0.7))
	incomplete_ring.append(Vector3(3.0, 3.0, -2.0))
	var incomplete_reference := Assets._base_reference(incomplete_ring, AABB(Vector3(1.8, 0.0, -2.7), Vector3(2.4, 3.0, 1.4)))
	check(incomplete_reference.detection != "ring" and not bool(incomplete_reference.get("rim_coverage", false)), "An incomplete lower outline cannot claim a precise base-ring fit")
	var scenic_base: Array[Vector3] = []
	for index in 64:
		var angle := TAU * float(index) / 64.0
		scenic_base.append(Vector3(3.0 + cos(angle) * 1.2, 0.0, -2.0 + sin(angle) * 0.7))
	for x_index in range(-3, 4):
		for z_index in range(-3, 4):
			if float(x_index * x_index + z_index * z_index) / 9.0 <= 1.0:
				scenic_base.append(Vector3(3.0 + float(x_index) * 0.2, 0.0, -2.0 + float(z_index) * 0.1167))
	scenic_base.append(Vector3(3.0, 3.0, -2.0))
	var scenic_reference := Assets._base_reference(scenic_base, AABB(Vector3(1.8, 0.0, -2.7), Vector3(2.4, 3.0, 1.4)))
	check(scenic_reference.detection == "estimated-base" and absf(scenic_reference.size.x - 2.4) < 0.05, "Irregular scenic bases retain an estimated footprint without adding a duplicate proxy")
	var estimated_composite := Assets.composite_from_files([{"path": "synthetic-estimated-base", "asset": {"bounds": AABB(Vector3(-1.0, 0.0, -1.0), Vector3(2.0, 1.0, 2.0)), "base_footprint": Vector2.ONE, "base_center": Vector2(0.1, -0.2), "base_center_y": 0.0, "base_detection": "estimated-base", "fingerprint": "synthetic", "mesh": ArrayMesh.new()}}])
	check(estimated_composite.error.is_empty() and estimated_composite.base_detection == "estimated-base", "Composite models preserve estimated scenic-base confidence instead of upgrading it to a detected ring")
	var ring_part := {"path": "synthetic-ring", "asset": {"bounds": AABB(Vector3(-0.5, 0, -0.5), Vector3(1, 0.1, 1)), "base_footprint": Vector2.ONE, "base_center": Vector2(0.1, 0.2), "base_center_y": 0.0, "base_detection": "ring", "base_rim_coverage": true, "fingerprint": "ring", "mesh": ArrayMesh.new()}}
	var body_part := {"path": "synthetic-body-estimate", "asset": {"bounds": AABB(Vector3(-1, 0, -1), Vector3(2, 1.5, 2)), "base_footprint": Vector2.ONE * 2.0, "base_center": Vector2(-0.3, -0.4), "base_center_y": 0.0, "base_detection": "estimated-base", "fingerprint": "body", "mesh": ArrayMesh.new()}}
	for parts: Array in [[ring_part, body_part], [body_part, ring_part]]:
		var measured_composite := Assets.composite_from_files(parts)
		check(measured_composite.error.is_empty() and measured_composite.base_detection == "ring" and measured_composite.base_footprint.is_equal_approx(Vector2.ONE) and measured_composite.base_center.is_equal_approx(Vector2(0.1, 0.2)), "A measured complete rim wins over a larger body estimate regardless of component order")
	var contacts: Array[Vector3] = [Vector3(2.6, 0.0, -2.4), Vector3(3.4, 0.0, -2.4), Vector3(2.6, 0.0, -1.6), Vector3(3.4, 0.0, -1.6), Vector3(3.0, 3.0, -2.0)]
	var contact_base := Assets._base_reference(contacts, AABB(Vector3(2.6, 0.0, -2.4), Vector3(0.8, 3.0, 0.8)))
	check(contact_base.detection == "ground-contact" and contact_base.size == Vector2.ZERO and contact_base.center.distance_to(Vector2(3.0, -2.0)) < 0.05, "Irregular ground contacts are reported as an estimate, not a detected base")
	var per_model_base := ModelShowcase._base_spec({"base_size_source_mm": [28.5, 40, 28.5], "base_geometry": "per-model-circles", "base_radius_inches": 20.0 / 25.4})
	check(is_equal_approx(float(per_model_base.dimensions_mm.x), 40.0), "Representative miniature uses the largest configured per-model base")
	check(per_model_base.summary == "28.5 mm (2 models), 40 mm (1 model)", "Training Tools summarizes every required base diameter for a mixed-size datasheet")
	var adrax_base := ModelShowcase._base_spec(MarineProfiles.profile("adrax-agatone"))
	var aethon_base := ModelShowcase._base_spec(MarineProfiles.profile("aethon-shaan"))
	var ancient_base := ModelShowcase._base_spec(MarineProfiles.profile("ancient"))
	check(adrax_base.dimensions_mm == Vector2.ONE * 40.0 and not adrax_base.proxy, "Adrax marker uses the verified 40 mm datasheet base")
	check(aethon_base.dimensions_mm == Vector2.ONE * 50.0 and not aethon_base.proxy, "Aethon marker uses the verified 50 mm datasheet base")
	check(ancient_base.dimensions_mm == Vector2.ONE * 40.0 and not ancient_base.proxy, "Ancient marker uses the verified 40 mm datasheet base")
	var use_model_base := ModelShowcase._base_spec({"base_size_source": "Use model", "base_size_source_mm": 90, "base_radius_inches": 45.0 / 25.4})
	var undocumented_base := ModelShowcase._base_spec({"base_size_is_approximate": true, "base_size_source_mm": 80, "base_radius_inches": 40.0 / 25.4})
	check(use_model_base.proxy and undocumented_base.proxy, "Undimensioned and undocumented source bases stay visibly approximate")
	var oval_profile_base := ModelShowcase._base_spec({"base_size_source_mm": [90, 52], "base_geometry": "oval", "base_radius_inches": 45.0 / 25.4})
	check(oval_profile_base.shape == "oval" and oval_profile_base.dimensions_mm == Vector2(90, 52), "Datasheet oval dimensions remain distinct")
	var training_profiles := ModelShowcase.standard_profiles()
	var training_name_counts: Dictionary = {}
	for profile: Dictionary in training_profiles: training_name_counts[profile.name] = int(training_name_counts.get(profile.name, 0)) + 1
	var duplicate_identity_visible := false
	for profile: Dictionary in training_profiles:
		if int(training_name_counts.get(profile.name, 0)) > 1 and "DS " in str(profile.display_name): duplicate_identity_visible = true
	check(duplicate_identity_visible, "Training Tools labels repeated names with their exact datasheet ID")
	var import_panel := ImportPanel.new()
	import_panel.settings_path = ROOT.path_join("camera-preview.cfg")
	root.add_child(import_panel)
	var regular_intercessor_settings := import_panel._visual_settings({}, "40kdc:11e:adeptus-astartes:intercessor-squad", 16.0 / 25.4)
	var smaller_role_settings := import_panel._visual_settings({}, "40kdc:11e:adeptus-astartes:talonstrike-kill-team", 14.25 / 25.4)
	check(bool(regular_intercessor_settings.get("require_full_miniature", false)) and is_equal_approx(float(regular_intercessor_settings.base_radius_inches), 16.0 / 25.4), "Intercessor import validation uses the local infantry keyword and its 32 mm base")
	check(is_equal_approx(float(smaller_role_settings.base_radius_inches), 14.25 / 25.4), "The visual fitting path honors a per-miniature role's 28.5 mm override")
	import_panel.preview_asset = mesh
	import_panel.preview_root.add_child(Assets.visual(mesh, {"base_radius_inches": 1.0, "scale": 1.0, "tts_scale": 1.0}))
	import_panel.preview_motion_enabled = Callable(self, "_camera_motion_reduced")
	import_panel.preview_focus = Vector3(0.0, 2.0, 0.0)
	import_panel._preview_view("Reset fit")
	check(import_panel.preview_focus.is_zero_approx(), "Reset fit pivots the import camera on the fitted base center")
	import_panel._preview_view("Top")
	check(is_equal_approx(import_panel.preview_pitch, deg_to_rad(89.9)) and is_equal_approx(import_panel.preview_yaw, 0.0), "Top preset reaches its inspection angle immediately with reduced motion")
	import_panel._preview_view("Side")
	check(is_equal_approx(import_panel.preview_pitch, 0.0) and is_equal_approx(import_panel.preview_yaw, PI / 2.0), "Side preset reaches its inspection angle immediately with reduced motion")
	var part_asset: Dictionary = mesh.duplicate()
	part_asset.texture_fingerprint = "first-texture"
	var identity_part := {"name": "Body", "asset": part_asset, "transform": Transform3D.IDENTITY}
	import_panel.preview_asset = {"source_pose": true, "fingerprint": "mesh-and-first-texture", "parts": [identity_part]}
	var geometry_identity := import_panel._preview_geometry_identity()
	part_asset.texture_fingerprint = "second-texture"
	identity_part.asset = part_asset
	import_panel.preview_asset = {"source_pose": true, "fingerprint": "mesh-and-second-texture", "parts": [identity_part]}
	check(import_panel._preview_geometry_identity() == geometry_identity, "Texture arrival does not invalidate the import camera framing")
	import_panel.preview_motion_enabled = Callable(self, "_camera_motion_enabled")
	var camera_frames: Array[Vector3] = []
	for fps: int in [30, 60, 120]:
		import_panel.preview_focus = Vector3(0.0, 1.0, 0.0)
		import_panel.preview_focus_goal = Vector3.ZERO
		import_panel.preview_yaw = 0.0
		import_panel.preview_yaw_goal = 1.2
		import_panel.preview_pitch = 0.0
		import_panel.preview_pitch_goal = 0.7
		for frame in fps / 5: import_panel._advance_preview_view(1.0 / float(fps))
		camera_frames.append(Vector3(import_panel.preview_yaw, import_panel.preview_pitch, import_panel.preview_focus.y))
	check(camera_frames[0].distance_to(camera_frames[1]) < 0.0001 and camera_frames[1].distance_to(camera_frames[2]) < 0.0001, "Import view easing is consistent at 30, 60 and 120 FPS")
	import_panel.preview_motion_enabled = Callable(self, "_camera_motion_reduced")
	import_panel.preview_focus = Vector3(0.0, 1.0, 0.0)
	import_panel.preview_focus_goal = Vector3.ZERO
	import_panel._advance_preview_view(1.0 / 60.0)
	check(import_panel.preview_focus.is_zero_approx(), "Reduced motion removes the import camera easing")
	import_panel.free()
	check(ModelShowcase._inward_yaw(1) == 90.0 and ModelShowcase._inward_yaw(2) == -90.0, "Miniatures on both sides face inward from the documented +Z forward convention")
	var fitted := Assets.table_scale(mesh.bounds, {"scale": 1.0, "base_radius_inches": 0.63})
	check(mesh.base_detection == "ground-contact" and is_equal_approx(fitted, (0.63 * 2.0 * Assets.INFANTRY_HEIGHT_TO_BASE_RATIO) / mesh.bounds.size.y), "Without a detected ring, infantry visuals use the documented height normalization")
	var native := Assets.table_scale(mesh.bounds, {"scale": 1.0, "tts_scale": 1.5})
	check(is_equal_approx(native, 1.5), "Inch-range OBJ uses ForceOrg Transform scale when no datasheet base is supplied")
	var image := Image.create(4, 4, false, Image.FORMAT_RGBA8)
	image.fill(Color.RED)
	image.save_png(ROOT.path_join("diffuse.png"))
	var textured := Assets.obj_mesh(ROOT.path_join("mesh.obj"), ROOT.path_join("diffuse.png"))
	check(textured.error.is_empty() and textured.mesh.surface_get_material(0).albedo_texture != null, "Explicit local diffuse texture loads without editor import")
	Assets._image_texture_cache.clear()
	var worker := Thread.new()
	var worker_mapping := {"path": ROOT.path_join("mesh.obj"), "texture": ROOT.path_join("diffuse.png"), "fingerprint": textured.fingerprint, "texture_fingerprint": textured.texture_fingerprint}
	check(worker.start(Callable(Assets, "load_mapping_asset_for_worker").bind(worker_mapping)) == OK, "Background OBJ worker starts")
	while worker.is_alive(): await process_frame
	var background_asset: Dictionary = worker.wait_to_finish()
	check(background_asset.error.is_empty() and background_asset.get("pending_textures", []).size() == 1, "Background preparation parses mesh and decodes image without creating a GPU texture")
	background_asset = Assets.finalize_pending_textures(background_asset)
	check(background_asset.error.is_empty() and background_asset.mesh.surface_get_material(0).albedo_texture != null, "Main-thread texture finalization attaches the decoded image to its mesh")
	image.save_jpg(ROOT.path_join("extensionless-texture"))
	check(Assets.obj_mesh(ROOT.path_join("mesh.obj"), ROOT.path_join("extensionless-texture")).error.is_empty(), "Extensionless JPEG textures decode by content")
	image.save_jpg(ROOT.path_join("actually-jpeg.png"))
	check(Assets.obj_mesh(ROOT.path_join("mesh.obj"), ROOT.path_join("actually-jpeg.png")).error.is_empty(), "Mislabeled cached image extensions do not choose the wrong decoder")
	var stale_cache_owner := Node3D.new()
	var stale_texture_ref: WeakRef = weakref(stale_cache_owner)
	stale_cache_owner.free()
	var diffuse_fingerprint := FileAccess.get_sha256(ROOT.path_join("diffuse.png"))
	Assets._image_texture_cache[diffuse_fingerprint] = stale_texture_ref
	var stale_cache_result := Assets._load_image_texture(ROOT.path_join("diffuse.png"), "diffuse", true)
	check(stale_cache_result.error.is_empty() and stale_cache_result.get("image") is Image, "Expired weak texture cache entries reload the source image")
	Assets._image_texture_cache.clear()
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
	check(game.workshop_tabs.current_tab == 1 and game.sidebar_panel.position.x >= 16 and game.sidebar_panel.get_rect().end.x <= game.get_viewport().get_visible_rect().size.x - 16, "Long source entries stay within the centered unified workshop")
	var before := var_to_str(game.state)
	game.model_imports.scale_input.value = 1.2
	game.model_imports.rotation_input.value = 45
	game.model_imports.offset_input.value = 0.1
	game.model_imports.apply_mapping()
	var definition: String = game.state.units[100].definition_id
	check(game.model_imports.mappings.has(definition) and game.pieces[100].get_meta("imported_visual", false), "Applying a selected local visual renders the mapped unit type")
	check(game.model_imports._mapping_files_available(game.model_imports.mappings[definition]), "Fast preparation check accepts a saved mapping when all local files exist")
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
	check(game._save_snapshot().is_empty(), "Write a version-1 match checkpoint with a local visual")
	game._load_match()
	check(game.resume_succeeded and var_to_str(game.state) == before and game.pieces[100].get_meta("imported_visual", false), "The checkpoint resumes with the existing local model")
	var source_mesh := ROOT.path_join("mesh.obj")
	var parked_mesh := ROOT.path_join("parked-mesh.obj")
	var parked := DirAccess.rename_absolute(source_mesh, parked_mesh) == OK
	check(parked, "Temporarily remove the fixture model from its saved path")
	if parked:
		# A restarted process cannot reuse the mesh parsed before the file moved.
		game.model_imports.cache.erase(definition)
		game._load_match()
		check(game.resume_succeeded and var_to_str(game.state) == before and not game.pieces[100].get_meta("imported_visual", false), "The same checkpoint resumes with a placeholder when the local model is unavailable")
		check(DirAccess.rename_absolute(parked_mesh, source_mesh) == OK, "Restore the fixture model")
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

