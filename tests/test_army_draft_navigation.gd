extends SceneTree
var failures := 0
func _initialize() -> void: call_deferred("run")
func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1
func find_button(node: Node, text: String) -> Button:
	if node is Button and node.text == text: return node
	for child in node.get_children():
		var found := find_button(child, text)
		if found != null: return found
	return null

func run() -> void:
	var builder = load("res://scripts/army_builder_panel.gd").new()
	builder.storage_path = "user://draft-navigation/profiles.json"
	root.add_child(builder)
	builder._new_empty()
	builder.draft.entries.append(builder.Roster.entry(builder.source.lookup("40kdc:11e:adeptus-astartes:intercessor-squad"), 0))
	builder._render_draft()
	builder.name_input.text = "Original saved army"
	check(builder._save(), "Seed a saved army through production persistence")
	var original_id: String = builder.draft.id
	builder.notes.text = "Unsaved equipment plan"
	builder.name_input.text = "Working revision"
	builder._changed()
	var working := var_to_str(builder.draft)
	builder._close_editor()
	check(builder.resume_draft_button.visible, "Library exposes its retained unsaved draft")
	builder._edit_saved_list()
	check(builder.editor.visible and builder.dirty and var_to_str(builder.draft) == working, "Editing the same army resumes its unsaved revision instead of reloading old data")
	builder._close_editor()
	find_button(builder.overview, "New army").pressed.emit()
	check(builder.unsaved_dialog.visible and var_to_str(builder.draft) == working, "New army asks before replacing unsaved edits")
	builder.unsaved_dialog.get_cancel_button().pressed.emit()
	check(not builder.unsaved_dialog.visible and builder.editor.visible and var_to_str(builder.draft) == working, "Keep editing closes the prompt and preserves the complete draft (dialog %s, editor %s, unchanged %s)" % [str(builder.unsaved_dialog.visible), str(builder.editor.visible), str(var_to_str(builder.draft) == working)])
	builder._request_editor_action(builder._new_empty)
	var path: String = builder.store.path
	var blocker := FileAccess.open("user://draft-navigation/blocker", FileAccess.WRITE)
	blocker.store_string("Intentional storage failure")
	blocker.close()
	builder.store.path = "user://draft-navigation/blocker/lists.json"
	builder.unsaved_dialog.custom_action.emit(&"save")
	check(builder.unsaved_dialog.visible and builder.dirty and var_to_str(builder.draft) == working and "could not be saved" in builder.unsaved_dialog.dialog_text, "A failed Save draft never executes the destructive continuation")
	builder.store.path = path
	builder.unsaved_dialog.custom_action.emit(&"save")
	var stored: Dictionary = builder.store.active().lists[0]
	check(not builder.unsaved_dialog.visible and builder.draft.entries.is_empty() and stored.id == original_id and stored.name == "Working revision" and stored.notes == "Unsaved equipment plan", "Successful Save draft persists the revision before creating a new army")
	builder.name_input.text = "Draft to discard explicitly"
	builder._changed()
	builder._close_editor()
	find_button(builder.overview, "New army").pressed.emit()
	builder.unsaved_dialog.get_ok_button().pressed.emit()
	check(builder.editor.visible and builder.draft.name != "Draft to discard explicitly" and builder.store.active().lists.size() == 1, "Explicit discard replaces only the session draft and preserves saved armies")
	builder.dirty = false
	builder._close_editor()
	builder.selected_saved_id = original_id
	builder._ask_delete()
	check(builder.delete_dialog.visible and builder.store.active().lists.size() == 1, "Delete confirmation does not remove a saved army before confirmation")
	builder.delete_dialog.get_cancel_button().pressed.emit()
	check(builder.store.active().lists.size() == 1, "Cancelling delete preserves the saved army")
	builder._ask_delete()
	builder.delete_dialog.get_ok_button().pressed.emit()
	check(builder.store.active().lists.is_empty(), "Confirmed delete removes only the selected saved army")
	print("Army draft navigation checks: %d failures" % failures)
	builder.queue_free()
	await process_frame
	quit(0 if failures == 0 else 1)
