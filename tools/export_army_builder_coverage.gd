extends SceneTree
## Audit admitted construction choices only; absence of a saved schema is not proof of fixed equipment.
const Catalog = preload("res://scripts/implemented_army_catalog.gd")
const Roster = preload("res://scripts/army_roster.gd")
const Capabilities = preload("res://scripts/edition_11/army_capabilities.gd")

func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() != 2 or args[0] != "--output":
		push_error("Expected --output <JSON path>")
		quit(1)
		return
	var catalog := Catalog.new()
	var error := catalog.select_edition("11e")
	if not error.is_empty():
		push_error(error)
		catalog.free()
		quit(1)
		return
	var records: Array[Dictionary] = []
	for unit: Dictionary in catalog.catalog.units:
		var identity := str(unit.source_id)
		var profile := Capabilities.current_reference_profile(str(unit.faction), identity)
		var fields: Array[String] = []
		var option_keys: Array[String] = []
		var source_option_kinds: Array[String] = []
		for source_option: Variant in profile.get("source_options", []):
			if source_option is Dictionary and str(source_option.get("kind", "")) != "":
				var kind := str(source_option.kind)
				if kind not in source_option_kinds: source_option_kinds.append(kind)
		for option: Dictionary in unit.options:
			var item := Roster.entry(unit, unit.options.find(option), 1)
			for model_index in range(int(item.models)):
				for field: String in Roster.model_equipment(item, 0, model_index):
					if field not in fields: fields.append(field)
			if not item.get("unit_equipment_by_copy_id", {}).is_empty():
				for copy_id: String in item.unit_equipment_by_copy_id:
					for field: String in item.unit_equipment_by_copy_id[copy_id]:
						if field not in fields: fields.append(field)
		for key: String in profile:
			if "option" in key or "loadout" in key or "composition" in key: option_keys.append(key)
		fields.sort()
		option_keys.sort()
		records.append({"identity": identity, "faction": unit.faction,
			"source_datasheet_id": profile.get("source_datasheet_id", profile.get("datasheet_id", "")),
			"source_book_id": profile.get("source_book_id", ""),
			"source_digest": unit.source_digest, "source_scope": unit.source_scope,
			"source_snapshot_id": profile.get("source_snapshot_id", "not_recorded_on_runtime_profile"),
			"source_export_updated_at": profile.get("source_export_updated_at", "not_recorded_on_runtime_profile"),
			"source_manifest_sha256": profile.get("source_manifest_sha256", "not_recorded_on_runtime_profile"),
			"source_verified_against_snapshot_id": profile.get("source_verified_against_snapshot_id", ""),
			"source_verified_against_export_updated_at": profile.get("source_verified_against_export_updated_at", ""),
			"source_verified_against_manifest_sha256": profile.get("source_verified_against_manifest_sha256", ""),
			"source_verified_against_slice_manifest_sha256": profile.get("source_verified_against_slice_manifest_sha256", ""),
			"saved_fields": fields, "option_metadata_keys": option_keys, "source_option_kinds": source_option_kinds,
			"status": "saved_schema_present_review_scope" if not fields.is_empty() else "migration_review_required",
			"editor": "not_audited", "admission": "not_audited", "materialization": "not_audited",
			"setup_suppression": "not_audited", "disk_restart": "not_audited", "live_ui": "not_audited"})
	var output := ProjectSettings.globalize_path(args[1])
	DirAccess.make_dir_recursive_absolute(output.get_base_dir())
	var file := FileAccess.open(output, FileAccess.WRITE)
	if file == null:
		catalog.free()
		quit(1)
		return
	file.store_string(JSON.stringify({"schema_version": 1, "records": records, "excluded": catalog.excluded,
		"scope": "Current consolidated local construction catalog; schema discovery only, not source or runtime certification."}, "\t"))
	file.close()
	print("Exported %d admitted construction profiles" % records.size())
	catalog.free()
	quit()
