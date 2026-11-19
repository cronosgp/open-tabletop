extends SceneTree
## Complete bounded static-object inventory, including non-mesh scenery/accessories.
const Assets = preload("res://scripts/local_models.gd")

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() != 2:
		push_error("Expected <local TTS save> <output under res://.tools/>")
		quit(2)
		return
	var output := ProjectSettings.globalize_path(args[1]).simplify_path().replace("\\", "/")
	var local_root := ProjectSettings.globalize_path("res://.tools/").simplify_path().replace("\\", "/").trim_suffix("/")
	if not output.begins_with(local_root + "/"):
		push_error("Third-party object inventories must remain under the ignored .tools directory.")
		quit(2)
		return
	var scanned := Assets.scan(args[0], true)
	if not str(scanned.get("error", "")).is_empty() or not scanned.get("warnings", []).is_empty():
		push_error("Incomplete static object scan: " + str(scanned.get("error", "")) + " " + str(scanned.get("warnings", [])))
		quit(1)
		return
	var reread := Assets.read_text(args[0])
	if not str(reread.get("error", "")).is_empty() or str(reread.get("text", "")).sha256_text() != scanned.fingerprint:
		push_error("Source changed during object inventory export.")
		quit(1)
		return
	DirAccess.make_dir_recursive_absolute(output.get_base_dir())
	var file := FileAccess.open(output, FileAccess.WRITE)
	if file == null:
		push_error("Cannot write local object inventory.")
		quit(1)
		return
	file.store_string(JSON.stringify({"schema_version": 1, "source_sha256": scanned.fingerprint,
		"source": args[0], "scanned_object_count": scanned.objects, "visual_entry_count": scanned.entries.size(),
		"embedded_object_count": scanned.embedded_objects, "warnings": scanned.warnings,
		"scope": "bounded static TTS objects; no Lua execution, downloads or rendering certification",
		"objects": scanned.source_objects}))
	file.close()
	print("OBJECT INVENTORY: %d objects; %d visual entries" % [scanned.objects, scanned.entries.size()])
	quit(0)
