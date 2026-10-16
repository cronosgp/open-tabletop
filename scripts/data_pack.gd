extends RefCounted
## Local-only reader for our own pack format. External services are optional tooling.

static func load_pack(directory: String) -> Dictionary:
	var manifest_file := FileAccess.open(directory.path_join("manifest.json"), FileAccess.READ)
	if manifest_file == null:
		return {"error": "Cannot open manifest."}
	var manifest: Variant = JSON.parse_string(manifest_file.get_as_text())
	if not manifest is Dictionary or manifest.get("schema_version") != 1:
		return {"error": "Unsupported pack schema."}
	for key in ["id", "edition", "implementation", "units_sha256"]:
		if not manifest.get(key) is String or manifest[key].is_empty():
			return {"error": "Missing manifest field: " + key}
	var path := directory.path_join("units.json")
	if not FileAccess.file_exists(path) or FileAccess.get_sha256(path) != manifest.units_sha256:
		return {"error": "Unit content hash mismatch."}
	var units: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	if not units is Array or units.is_empty():
		return {"error": "Expected a nonempty unit array."}
	var ids: Dictionary = {}
	for unit: Variant in units:
		if not unit is Dictionary:
			return {"error": "Invalid unit record."}
		if not unit.get("id") is String or unit.id.is_empty() or ids.has(unit.id):
			return {"error": "Missing or duplicate unit ID."}
		if not unit.get("name") is String or not unit.get("stats") is Dictionary:
			return {"error": "Invalid unit identity or stats."}
		ids[unit.id] = true
	return {"manifest": manifest, "units": units, "error": ""}

static func playable_error(pack: Dictionary) -> String:
	if not pack.get("error", "Invalid pack").is_empty():
		return pack.get("error", "Invalid pack")
	# This allowlist represents implemented code, never a provider's capability claim.
	if pack.manifest.implementation != "prototype-movement-v1" or pack.manifest.edition != "demo":
		return "This edition's rules are not implemented; reference data only."
	for unit: Dictionary in pack.units:
		if unit.get("playable") != true or not unit.get("unsupported_rules", []).is_empty():
			return "Unit contains unsupported mechanics."
		var movement: Variant = unit.stats.get("movement_inches")
		if not (movement is float or movement is int) or not is_finite(movement) or movement <= 0:
			return "Unit requires a valid movement characteristic."
		var base: Variant = unit.get("base")
		if not base is Dictionary or base.get("shape") != "circle":
			return "Unsupported base geometry."
		var radius: Variant = base.get("radius_inches")
		if not (radius is float or radius is int) or not is_finite(radius) or radius <= 0:
			return "Unit requires a valid base radius."
	return ""
