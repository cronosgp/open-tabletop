extends SceneTree
const Training = preload("res://scripts/edition_11/training_roster.gd")
const Matcher = preload("res://scripts/forceorg_matcher.gd")
const Assets = preload("res://scripts/local_models.gd")
const ImportPanel = preload("res://scripts/model_import_panel.gd")
var failures := 0
const DIR := "res://.tools/local-armies-models"
func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1
func write(path: String, content: String) -> void:
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_string(content)
func _initialize() -> void: call_deferred("run")
func run() -> void:
	DirAccess.make_dir_recursive_absolute(DIR)
	var presets := Training.presets()
	check(presets.size() == 7, "Seven offline presets include the Overlord-led training list")
	for list: Dictionary in presets:
		check(Training.inspect(list).error.is_empty() and list.points_limit == 500, "Default lists pass real canonical admission")
	presets[0].entries.clear()
	check(not Training.presets()[0].entries.is_empty(), "Preset edits cannot mutate future defaults")
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	game.auto_models.button_pressed = false
	check(game._picked_army(1).faction == "Space Marines" and game._picked_army(2).faction == "Necrons", "Fresh launch preselects two different ready armies")
	check(game.army_builder.store.active().lists.is_empty(), "Showing defaults does not silently populate the profile")
	game._start_saved_match()
	check(game.state.phase == "deployment" and game.state.units.size() == 30, "One local action starts both default armies without LAN consent")
	game._save_selected_army(1)
	var saved: Dictionary = game.army_builder.store.active().lists[0]
	check(not saved.id.begins_with("preset:") and Training.inspect(saved).error.is_empty(), "Save copy generates an editable independent profile entry")
	var previous := var_to_str(game.state)
	game.saved_army_pickers[2].select(0)
	game._start_saved_match()
	check(var_to_str(game.state) == previous, "An incomplete setup preserves the current match")
	game.saved_army_pickers[2].select(1)
	game._start_saved_match()
	check(game.state.squads[1].faction == game.state.squads[2].faction, "Local setup supports mirror matches")
	var definition: String = Training.definition("Space Marines").unit.id
	var mesh_url := "https://example.invalid/intercessor.obj"
	var entry := {"name": "Primaris Intercessor", "path": "ObjectStates/0", "kind": "CustomMesh", "references": {"MeshURL": mesh_url}}
	var bad: Dictionary = entry.duplicate(true)
	bad.name = "Assault Intercessor"
	check(not Matcher.choose(definition, [bad]).error.is_empty(), "Assault models cannot be selected for regular Intercessors")
	bad = entry.duplicate(true)
	bad.child_components = 2
	check(not Matcher.choose(definition, [bad]).error.is_empty(), "Composite base objects never auto-link as a complete miniature")
	bad = entry.duplicate(true)
	bad.references.MeshURL = "https://example.invalid/other.obj"
	check(Matcher.choose(definition, [entry, bad]).entry == Matcher.choose(definition, [bad, entry]).entry, "Visual variant selection is independent of catalog order")
	write(DIR.path_join(Assets.cache_key(mesh_url) + ".obj"), "v 0 0 0\nv 1 0 0\nv 0 2 0\nf 1 2 3\n")
	var source := DIR.path_join("ForceOrg.json")
	write(source, JSON.stringify({"ObjectStates": [{"Nickname": "Primaris Intercessor", "CustomMesh": {"MeshURL": mesh_url}}]}))
	var panel := ImportPanel.new()
	panel.settings_path = DIR.path_join("models.cfg")
	root.add_child(panel)
	panel.source_path.text = source
	panel.download_path.text = DIR
	var before := var_to_str(game.state)
	panel.prepare_armies([definition, "unsupported:captain"])
	for frame in range(8): await process_frame
	check(panel.mappings.has(definition) and not panel.downloader.busy and not panel.automatic_running, "Cached OBJ auto-links without HTTP or pawn selection")
	check("No visual alias" in panel.download_status.text, "Unsupported profiles have a recoverable per-model status")
	check(var_to_str(game.state) == before, "Visual preparation does not alter gameplay")
	var restored := ImportPanel.new()
	restored.settings_path = panel.settings_path
	root.add_child(restored)
	check(restored.source_path.text == source and restored.mappings.has(definition), "Catalog and links survive restart")
	var visual := restored.visual_for(definition)
	check(visual != null, "Restored automatic link renders a real mesh")
	if visual != null: visual.free()
	var mapping: Dictionary = panel.mappings[definition].duplicate(true)
	panel.prepare_armies([definition])
	check(panel.mappings[definition] == mapping and "Reused saved model" in panel.download_status.text, "Existing visual choices are preserved and reused")
	panel.automatic_running = true
	panel.automatic_queue = [{"definition": "old"}]
	var old_generation: int = panel.automatic_generation
	panel.cancel_automatic()
	panel._next_automatic(old_generation)
	check(panel.automatic_queue.is_empty() and panel.mappings[definition] == mapping, "Cancellation and stale queue callbacks preserve links")
	panel.automatic_running = true
	panel.automatic_current = {"definition": "failed:unit", "entry": entry}
	panel._finish_automatic_item({"error": "HTTP 404"})
	for frame in range(3): await process_frame
	check(not panel.mappings.has("failed:unit") and panel.mappings[definition] == mapping and "HTTP 404" in panel.download_status.text, "A failed download reports its reason without damaging earlier links")
	write(DIR.path_join("invalid.obj"), "<html>unavailable</html>")
	panel.automatic_running = true
	panel.automatic_current = {"definition": "invalid:unit", "entry": entry}
	panel._finish_automatic_item({"error": "", "mesh": DIR.path_join("invalid.obj"), "texture": ""})
	for frame in range(3): await process_frame
	check(not panel.mappings.has("invalid:unit") and panel.mappings[definition] == mapping, "HTTP success with invalid OBJ cannot create a visual link")
	var verified := {"name": "necron warrior reaper / component 1", "kind": "CustomMesh", "path": "ObjectStates/0/ChildObjects/0", "references": {"MeshURL": Matcher.VERIFIED_NECRON_BODY}}
	check(Matcher.choose(Training.definition("Necrons").unit.id, [verified]).error.is_empty(), "The previously verified Necron body can render over the board base")
	print("Local armies and automatic models: %d failures" % failures)
	quit(0 if failures == 0 else 1)
