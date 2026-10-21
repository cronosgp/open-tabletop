extends SceneTree
const Assets = preload("res://scripts/local_models.gd")
var failures := 0
func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	game._dismiss_home(3)
	check(game.match_tabs.is_tab_hidden(2) and game.workshop_tabs.is_ancestor_of(game.army_builder) and game.workshop_tabs.is_ancestor_of(game.model_imports), "Army and import share one workspace")
	check(game.sidebar_panel.size.x > 900 and not game.action_groups.phase.container.visible, "Workspace is wide and hides match phase actions")
	game.army_builder._new_empty()
	game.army_builder._new_training()
	game.army_builder._select_entry(0)
	var item: Dictionary = game.army_builder.draft.entries[0]
	check(game.model_imports._definition() == item.unit_id, "Import target follows the roster entry instead of a battlefield model")
	check(not game.army_builder.miniature_preview.imported and "Default placeholder" in game.army_builder.miniature_preview.caption.text, "Missing local model is labeled as placeholder")
	var path := "res://.tools/workshop-preview-fixture.obj"
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_string("v -1 0 -1\nv 1 0 -1\nv 0 3 0\nv 0 0 1\nf 1 2 3\nf 2 4 3\nf 4 1 3\nf 1 4 2\n")
	file.close()
	var asset := Assets.obj_mesh(path)
	check(asset.error.is_empty(), "Local fixture mesh loads")
	game.model_imports.mappings[item.unit_id] = {"path": path, "fingerprint": asset.fingerprint, "texture_fingerprint": asset.texture_fingerprint, "scale": 1.0}
	var before := var_to_str(game.army_builder.draft)
	game.army_builder._preview_entry(item)
	check(game.army_builder.miniature_preview.imported and game.army_builder.miniature_preview.visual.get_child_count() > 0, "Preview instantiates the actual mapped local mesh")
	check(var_to_str(game.army_builder.draft) == before, "Preview leaves composition and points unchanged")
	var builder = game.army_builder
	builder.preview_model_input.value = 3
	var match_before := var_to_str(game.state)
	var roster_before := var_to_str(builder.draft)
	var link_dirty: bool = builder.dirty
	game.workshop_tabs.current_tab = 1
	game.model_imports.mesh_path.text = path
	game.model_imports.texture_path.text = ""
	game.model_imports.load_preview()
	game.model_imports.apply_mapping()
	check(game.model_imports.linked_unit_button.visible and builder.preview_slot == 2, "Successful local link offers return and preserves inspected miniature")
	check(var_to_str(game.state) == match_before and var_to_str(builder.draft) == roster_before and builder.dirty == link_dirty, "Linking appearance changes neither match nor roster composition")
	game.model_imports.linked_unit_button.pressed.emit()
	check(game.workshop_tabs.current_tab == 0 and builder.miniature_preview.imported, "Explicit return shows the linked roster model")
	game.model_imports.mesh_path.text = path + ".changed"
	game.model_imports.apply_mapping()
	check(not game.model_imports.linked_unit_button.visible and game.model_imports.mappings.has(item.unit_id), "Rejected stale preview clears return feedback without deleting saved link")
	game.model_imports.mesh_path.text = path
	game.model_imports.apply_mapping()
	builder._preview_entry({})
	game.model_imports._process(0)
	check(not game.model_imports.linked_unit_button.visible, "Changing target clears linked-unit shortcut")
	builder._preview_entry(item)
	item.copies = 2
	builder._ensure_visual_slots(item)
	item.visual_variants[1] = "preview-fixture-variant"
	game.model_imports.variant_mappings["preview-fixture-variant"] = {"path": path, "fingerprint": asset.fingerprint, "texture_fingerprint": asset.texture_fingerprint, "scale": 2.0}
	game.model_imports.variant_cache["preview-fixture-variant"] = asset
	builder._preview_entry(item)
	var first_scale: Vector3 = builder.miniature_preview.visual.get_child(0).scale
	before = var_to_str(builder.draft)
	var dirty_before: bool = builder.dirty
	builder.preview_model_input.value = 2
	check(builder.preview_slot == 1 and builder.miniature_preview.visual.get_child(0).scale.is_equal_approx(first_scale * 2), "Preview selector displays the distinct assigned local variant")
	builder.preview_model_input.value = int(item.models) + 1
	check("Unit 2 · model 1" in builder.miniature_preview.caption.text, "Preview identifies copy boundaries")
	builder.appearance_button.pressed.emit()
	check(builder.visual_copy_picker.selected == 1, "Appearance opens the copy being inspected")
	check(var_to_str(builder.draft) == before and builder.dirty == dirty_before, "Inspection changes neither assignments nor unsaved status")
	var unknown := item.duplicate(true)
	unknown.models = 0
	builder._preview_entry(unknown)
	check(not builder.preview_model_input.visible and "Composition pending" in builder.miniature_preview.caption.text, "Unknown composition does not invent model slots")
	game.match_tabs.current_tab = 2
	check(game.match_tabs.current_tab == 3 and game.workshop_tabs.current_tab == 1, "Legacy import shortcut redirects to unified window")
	game.army_builder._new_empty()
	check(game.army_builder.preview_entry.is_empty(), "Empty draft clears prior import context")
	check(not game.army_builder.appearance_button.visible, "Empty draft has no appearance action")
	var fixture := preload("res://tests/fixtures/army_catalog_fixture.gd").catalog()
	var panel = game.army_builder
	panel.source.catalog = fixture
	panel.draft = panel.Roster.new_list("11e", "Space Marines")
	panel.draft.entries.append(panel.Roster.entry(fixture.units[0], 0))
	panel._render_draft()
	panel.unit_picker.clear()
	panel.unit_picker.add_item(fixture.units[1].name)
	panel.unit_picker.set_item_metadata(0, fixture.units[1])
	panel._select_unit(0)
	check("90 pts added" in panel.addition_summary.text and "170 /" in panel.addition_summary.text, "Candidate summary adds existing roster points to the proposed unit")
	var addition_before := var_to_str(panel.draft)
	var context_before: String = game.model_imports._definition()
	panel.copies.value = 2
	check("180 pts added" in panel.addition_summary.text and "260 /" in panel.addition_summary.text, "Copy count updates projected total")
	check(var_to_str(panel.draft) == addition_before and game.model_imports._definition() == context_before, "Candidate preview changes neither roster nor import context")
	var cost: Variant = panel.selected_unit.options[0].cost
	panel.selected_unit.options[0].cost = null
	panel._refresh_addition_summary()
	check("cost unconfirmed" in panel.addition_summary.text and "partial" in panel.addition_summary.text, "Unknown candidate cost stays explicitly partial")
	panel.selected_unit.options[0].cost = cost
	panel.draft.points_limit = 100
	panel._refresh_addition_summary()
	check("over budget" in panel.addition_summary.text and not panel.add_button.disabled, "Over-budget addition remains a clearly labeled draft option")
	panel.draft.points_limit = 1000
	panel.query.text = "not-a-fixture-name"
	panel._filter_units()
	check(panel.selected_unit.is_empty() and panel.add_button.disabled and "Select a unit" in panel.addition_summary.text, "Filtering clears stale candidate totals and submission")
	panel.query.text = ""
	panel._filter_units()
	panel.unit_picker.clear()
	panel.unit_picker.add_item(fixture.units[1].name)
	panel.unit_picker.set_item_metadata(0, fixture.units[1])
	panel._select_unit(0)
	panel.copies.value = 1
	panel.editor_tabs.current_tab = 1
	panel._add()
	check(panel.selected_entry_index == 1 and panel.editor_tabs.current_tab == 0 and panel.preview_entry.unit_id == fixture.units[1].id, "Adding selects the new distinct unit and returns to roster")
	panel.appearance_button.pressed.emit()
	check(panel.editor_tabs.current_tab == 2 and panel.visual_copy_picker.item_count == 1, "Appearance shortcut opens controls for the selected new unit")
	check(panel._save(), "Save the two-entry fixture")
	check(panel.save_status.text == "✓ Saved locally" and panel.notice.text.is_empty(), "Successful save has a current status without duplicate prose")
	check(panel.selected_entry_index == 1 and panel.preview_entry.unit_id == fixture.units[1].id and game.model_imports._definition() == fixture.units[1].id, "Save preserves selected model and import target instead of switching to first unit")
	panel.name_input.text = ""
	panel._changed()
	check(panel.save_button.disabled and "Give the list a name" in panel.save_status.text, "Blocked save exposes the existing validator reason")
	panel.name_input.text = "Save recovery fixture"
	panel._changed()
	check(not panel.save_button.disabled and panel.save_status.text == "Unsaved changes", "Editing clears stale saved/blocked presentation")
	var original_path: String = panel.store.path
	var blocker_path := "res://.tools/workshop-save-blocker-%d" % OS.get_process_id()
	var blocker := FileAccess.open(blocker_path, FileAccess.WRITE)
	blocker.store_string("Intentional write-failure fixture")
	blocker.close()
	panel.store.path = blocker_path.path_join("list.json")
	var draft_before := var_to_str(panel.draft)
	var bank_before := var_to_str(panel.store.data)
	panel._save_copy()
	check(var_to_str(panel.draft) == draft_before and var_to_str(panel.store.data) == bank_before and panel.name_input.text == panel.draft.name, "Failed save-copy preserves draft and profile bank")
	check("Save failed" in panel.save_status.text and not panel.save_button.disabled, "Write failure stays distinguishable and retry remains available")
	panel.store.path = original_path
	check(panel._save() and panel.save_status.text == "✓ Saved locally", "Retry succeeds after storage is restored")
	panel._close_editor()
	check(not panel.appearance_button.visible, "Saved overview hides editing-only appearance action")
	var stored_before := var_to_str(panel.store.data)
	panel.preview_model_input.value = 2
	check(var_to_str(panel.store.data) == stored_before, "Saved overview preview never writes appearance assignments")
	game.match_tabs.current_tab = 1
	check(game.sidebar_panel.size.x < 500, "Play restores the compact sidebar")
	print("Army workshop UI checks: %d failures" % failures)
	quit(0 if failures == 0 else 1)
