extends SceneTree
## Export a local, visual-only catalog from a TTS save using the project's bounded parser.
## Weapon labels remain hints unless the existing reviewed matcher recognizes the assembly.

const LocalModels = preload("res://scripts/local_models.gd")
const ForceOrgMatcher = preload("res://scripts/forceorg_matcher.gd")
const INTERCESSOR_ID := "40kdc:11e:adeptus-astartes:intercessor-squad"
const INTERCESSOR_DATASHEET_ID := "000001157"
const WEAPON_PHRASES: Array[Array] = [
	["macro plasma incinerator", "macro-plasma-incinerator"],
	["heavy onslaught gatling cannon", "heavy-onslaught-gatling-cannon"],
	["master crafted bolt rifle", "master-crafted-bolt-rifle"],
	["stalker bolt rifle", "stalker-bolt-rifle"],
	["auto bolt rifle", "auto-bolt-rifle"],
	["heavy bolt rifle", "heavy-bolt-rifle"],
	["twin assault cannon", "twin-assault-cannon"],
	["twin heavy bolter", "twin-heavy-bolter"],
	["twin lascannon", "twin-lascannon"],
	["plasma incinerator", "plasma-incinerator"],
	["boltstorm gauntlet", "boltstorm-gauntlet"],
	["heavy bolt pistol", "heavy-bolt-pistol"],
	["thunder hammer", "thunder-hammer"],
	["grenade launcher", "grenade-launcher"],
	["plasma pistol", "plasma-pistol"],
	["power sword", "power-sword"],
	["power weapon", "power-weapon"],
	["power fist", "power-fist"],
	["heavy bolter", "heavy-bolter"],
	["heavy flamer", "heavy-flamer"],
	["multi melta", "multi-melta"],
	["missile launcher", "missile-launcher"],
	["plasma cannon", "plasma-cannon"],
	["assault bolter", "assault-bolter"],
	["fragstorm grenade launcher", "fragstorm-grenade-launcher"],
	["storm bolter", "storm-bolter"],
	["combi weapon", "combi-weapon"],
	["bolt rifle", "bolt-rifle"],
	["bolt carbine", "bolt-carbine"],
	["bolt pistol", "bolt-pistol"],
	["chainsword", "chainsword"],
	["auto melta", "auto-melta"],
	["melta rifle", "melta-rifle"],
	["assault cannon", "assault-cannon"],
	["lascannon", "lascannon"],
	["gatling cannon", "gatling-cannon"],
	["power klaw", "power-klaw"],
]
const WEAPON_ABBREVIATIONS: Array[Array] = [
	["auto br", "auto-bolt-rifle", "intercessor"],
	["stalker br", "stalker-bolt-rifle", "intercessor"],
	["gl", "grenade-launcher", ""],
	["ps", "power-sword", ""],
	["pf", "power-fist", ""],
	["pp", "plasma-pistol", ""],
	["th", "thunder-hammer", ""],
	["bp", "bolt-pistol", ""],
	["cs", "chainsword", ""],
	["ck", "combat-knife", ""],
	["pw", "power-weapon", ""],
	["ss", "storm-shield", ""],
	["lc", "lightning-claws", ""],
	["br", "bolt-rifle", "intercessor"],
]
const COLUMNS := [
	"source_save", "save_sha256", "entry_id", "state_group_path", "state_key", "state_count",
	"tts_path", "guid", "source_group_hint", "variant_label", "model_family_hint", "visual_weapon_hints",
	"asset_kind", "asset_fingerprint", "component_count", "component_names", "component_pose_data",
	"root_transform", "tts_scale", "e11_datasheet_id", "e11_definition_id", "e11_model_role",
	"e11_equipment_signature", "mapping_status", "review_note"
]

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() < 2:
		push_error("Usage: Godot --headless --path . --script res://tools/export_forceorg_visual_table.gd -- <TTS save.json> <output.csv>")
		quit(2)
		return
	var source_path := str(args[0])
	var output_path := ProjectSettings.globalize_path(str(args[1]))
	var result: Dictionary = LocalModels.scan(source_path)
	if not str(result.get("error", "")).is_empty():
		push_error("TTS scan failed: " + str(result.error))
		quit(1)
		return
	var entries: Array = result.get("entries", [])
	var group_index := _load_root_group_hints(source_path)
	if str(group_index.get("fingerprint", "")) != str(result.get("fingerprint", "")):
		push_error("The TTS save changed during scanning. Save or close TTS and rerun the export so model rows and menu groups come from the same snapshot.")
		quit(1)
		return
	var root_group_hints: Dictionary = group_index.get("groups", {})
	var visual_entries: Array[Dictionary] = []
	for value: Variant in entries:
		if not value is Dictionary: continue
		var entry: Dictionary = value
		if "/ChildObjects/" in str(entry.get("path", "")): continue
		visual_entries.append(entry)
	visual_entries.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return str(a.get("path", "")) < str(b.get("path", "")))

	var reviewed_roles: Dictionary = {}
	for entry: Dictionary in ForceOrgMatcher.intercessor_sergeant_variants(INTERCESSOR_ID, visual_entries):
		reviewed_roles[str(entry.get("path", ""))] = str(entry.get("visual_role", ""))
	for entry: Dictionary in ForceOrgMatcher.intercessor_grenadier_variants(INTERCESSOR_ID, visual_entries):
		reviewed_roles[str(entry.get("path", ""))] = str(entry.get("visual_role", ""))

	var state_counts: Dictionary = {}
	for entry: Dictionary in visual_entries:
		var group_path := _state_group_path(str(entry.get("path", "")))
		state_counts[group_path] = int(state_counts.get(group_path, 0)) + 1

	var parent := output_path.get_base_dir()
	var dir_error := DirAccess.make_dir_recursive_absolute(parent)
	if dir_error != OK and dir_error != ERR_ALREADY_EXISTS:
		push_error("Could not create output directory: " + parent)
		quit(1)
		return
	var file := FileAccess.open(output_path, FileAccess.WRITE)
	if file == null:
		push_error("Could not open CSV output: " + output_path)
		quit(1)
		return
	file.store_csv_line(PackedStringArray(COLUMNS))
	var reviewed_count := 0
	var variant_groups: Dictionary = {}
	for entry: Dictionary in visual_entries:
		var path := str(entry.get("path", ""))
		var group_hint := _source_group_hint(path, root_group_hints)
		var role := str(reviewed_roles.get(path, ""))
		var signature := ""
		var status := "visual_candidate_rules_unreviewed"
		var note := "TTS name and parts are visual evidence only; verify equipment against the local 11e profile before use."
		var datasheet_id := ""
		var definition_id := ""
		if not role.is_empty():
			datasheet_id = INTERCESSOR_DATASHEET_ID
			definition_id = INTERCESSOR_ID
			status = "reviewed_visual_alias_current_profile"
			note = "Existing reviewed Intercessor visual alias; role/equipment signature is presentation-only and tied to the local 11e profile."
			if role.begins_with("intercessor-sergeant:"):
				signature = role.trim_prefix("intercessor-sergeant:")
			reviewed_count += 1
		var components: Array = entry.get("components", []) if entry.get("components", []) is Array else []
		var names: Array[String] = []
		var pose_data: Array[Dictionary] = []
		for component_value: Variant in components:
			if not component_value is Dictionary: continue
			var component: Dictionary = component_value
			var component_name := str(component.get("name", "Component"))
			if bool(component.get("base_candidate", false)): component_name += " [base candidate]"
			names.append(component_name)
			pose_data.append({
				"name": str(component.get("name", "Component")),
				"kind": str(component.get("kind", "")),
				"asset_fingerprint": _references_fingerprint(component.get("references", {})),
				"local_transforms": component.get("transforms", []),
				"base_candidate": bool(component.get("base_candidate", false))
			})
		var refs: Variant = entry.get("references", {})
		var fingerprint := _asset_fingerprint(entry, components)
		var hints := _weapon_hints(str(entry.get("name", "")))
		var family_hint := _family_hint(str(entry.get("name", "")))
		var variant_key := JSON.stringify([family_hint, hints, fingerprint]).sha256_text()
		if not variant_groups.has(variant_key):
			variant_groups[variant_key] = {
				"variant_key": variant_key, "model_family_hint": family_hint,
				"representative_label": str(entry.get("name", "")), "visual_weapon_hints": "|".join(hints),
				"asset_kind": str(entry.get("kind", "")), "asset_fingerprint": fingerprint,
				"component_count": components.size(), "source_occurrences": [], "source_group_hints": [],
				"e11_datasheet_id": datasheet_id, "e11_definition_id": definition_id,
				"e11_model_role": role, "e11_equipment_signature": signature,
				"mapping_status": status
			}
		var grouped: Dictionary = variant_groups[variant_key]
		var occurrences: Array = grouped["source_occurrences"]
		occurrences.append({"tts_path": path, "guid": str(entry.get("guid", "")), "label": str(entry.get("name", "")), "state_key": _state_key(path), "source_group_hint": group_hint})
		grouped["source_occurrences"] = occurrences
		var source_groups: Array = grouped["source_group_hints"]
		if not group_hint.is_empty() and not source_groups.has(group_hint): source_groups.append(group_hint)
		source_groups.sort()
		grouped["source_group_hints"] = source_groups
		variant_groups[variant_key] = grouped
		var row := [
			str(result.get("source", "")).get_file(), str(result.get("fingerprint", "")), str(entry.get("id", "")),
			_state_group_path(path), _state_key(path), str(state_counts.get(_state_group_path(path), 1)),
			path, str(entry.get("guid", "")), group_hint, str(entry.get("name", "")), family_hint, "|".join(hints),
			str(entry.get("kind", "")), fingerprint, str(components.size()), " | ".join(names), JSON.stringify(pose_data),
			JSON.stringify(entry.get("root_transform", {})), str(entry.get("tts_scale", 1.0)), datasheet_id,
			definition_id, role, signature, status, note
		]
		var cells: PackedStringArray = []
		for value: Variant in row: cells.append(str(value))
		file.store_csv_line(cells)
	file.flush()
	file.close()
	var variants_path := output_path.trim_suffix(".csv") + "_variants.csv"
	if not _write_variant_index(variants_path, variant_groups, str(result.get("source", "")).get_file(), str(result.get("fingerprint", ""))):
		push_error("Could not write deduplicated model/weapon index: " + variants_path)
		quit(1)
		return
	print("ForceOrg visual table exported: %s" % output_path)
	print("Deduplicated visual variants exported: %s" % variants_path)
	print("Source SHA-256: %s" % str(result.get("fingerprint", "")))
	print("Parsed objects: %d; visual rows: %d; distinct visual variants: %d; reviewed Intercessor links: %d; state groups: %d" % [int(result.get("objects", 0)), visual_entries.size(), variant_groups.size(), reviewed_count, state_counts.size()])
	print("Embedded objects: %d; parser warnings: %d" % [int(result.get("embedded_objects", 0)), (result.get("warnings", []) as Array).size()])
	print("TTS source-group hints resolved: %d model roots" % root_group_hints.size())
	quit(0)

func _write_variant_index(path: String, groups: Dictionary, source_name: String, source_hash: String) -> bool:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null: return false
	file.store_csv_line(PackedStringArray([
		"source_save", "save_sha256", "variant_key", "source_group_hints", "model_family_hint", "representative_label", "visual_weapon_hints", "asset_kind",
		"asset_fingerprint", "component_count", "source_occurrence_count", "source_occurrences",
		"e11_datasheet_id", "e11_definition_id", "e11_model_role", "e11_equipment_signature", "mapping_status"
	]))
	var keys: Array = groups.keys()
	keys.sort_custom(func(a: String, b: String) -> bool:
		var left: Dictionary = groups[a]
		var right: Dictionary = groups[b]
		var left_name := str(left.get("model_family_hint", "")) + "|" + str(left.get("visual_weapon_hints", "")) + "|" + str(left.get("representative_label", ""))
		var right_name := str(right.get("model_family_hint", "")) + "|" + str(right.get("visual_weapon_hints", "")) + "|" + str(right.get("representative_label", ""))
		return left_name < right_name
	)
	for key: String in keys:
		var item: Dictionary = groups[key]
		var occurrences: Array = item.get("source_occurrences", [])
		var occurrence_text := JSON.stringify(occurrences)
		var row := [
			source_name, source_hash, str(item.get("variant_key", "")), "|".join(item.get("source_group_hints", [])), str(item.get("model_family_hint", "")),
			str(item.get("representative_label", "")), str(item.get("visual_weapon_hints", "")),
			str(item.get("asset_kind", "")), str(item.get("asset_fingerprint", "")),
			str(item.get("component_count", 0)), str(occurrences.size()), occurrence_text,
			str(item.get("e11_datasheet_id", "")), str(item.get("e11_definition_id", "")),
			str(item.get("e11_model_role", "")), str(item.get("e11_equipment_signature", "")),
			str(item.get("mapping_status", ""))
		]
		var cells: PackedStringArray = []
		for value: Variant in row: cells.append(str(value))
		file.store_csv_line(cells)
	file.flush()
	file.close()
	return true

func _state_group_path(path: String) -> String:
	var marker := "/States/"
	var index := path.find(marker)
	return path.substr(0, index) if index >= 0 else path

func _state_key(path: String) -> String:
	var marker := "/States/"
	var index := path.rfind(marker)
	if index < 0: return "base"
	return path.substr(index + marker.length())

func _load_root_group_hints(source_path: String) -> Dictionary:
	var file := FileAccess.open(source_path, FileAccess.READ)
	if file == null: return {"fingerprint": "", "groups": {}}
	var source_text := file.get_as_text()
	var parser := JSON.new()
	if parser.parse(source_text) != OK or not parser.data is Dictionary: return {"fingerprint": "", "groups": {}}
	var roots: Variant = parser.data.get("ObjectStates", [])
	if not roots is Array: return {"fingerprint": source_text.sha256_text(), "groups": {}}
	var guid_to_group: Dictionary = {}
	var mapping_pattern := RegEx.new()
	if mapping_pattern.compile("([A-Za-z][A-Za-z0-9_]*)\\s*=\\s*getObjectFromGUID\\(\\\"([0-9a-fA-F]{6})\\\"\\)") != OK: return {"fingerprint": source_text.sha256_text(), "groups": {}}
	for root_value: Variant in roots:
		if not root_value is Dictionary: continue
		var script: Variant = root_value.get("LuaScript", "")
		if not script is String: continue
		for match: RegExMatch in mapping_pattern.search_all(script):
			guid_to_group[match.get_string(2).to_lower()] = _prettify_group_name(match.get_string(1))
	var result: Dictionary = {}
	for index: int in roots.size():
		var root: Variant = roots[index]
		if not root is Dictionary: continue
		var guid := str(root.get("GUID", "")).to_lower()
		if guid_to_group.has(guid): result[str(index)] = str(guid_to_group[guid])
	return {"fingerprint": source_text.sha256_text(), "groups": result}

func _source_group_hint(path: String, root_group_hints: Dictionary) -> String:
	var path_parts := path.split("/")
	if path_parts.size() < 3 or path_parts[0] != "ObjectStates": return ""
	return str(root_group_hints.get(path_parts[1], ""))

func _prettify_group_name(value: String) -> String:
	var camel_case := RegEx.new()
	if camel_case.compile("([a-z0-9])([A-Z])") == OK: value = camel_case.sub(value, "$1 $2", true)
	return value.replace("_", " ").strip_edges()

func _normalized_label(value: String) -> String:
	var normalized := value.to_lower().replace("’", "'")
	for punctuation: String in ["/", "-", "_", ".", ",", ":", "(", ")"]:
		normalized = normalized.replace(punctuation, " ")
	while "  " in normalized: normalized = normalized.replace("  ", " ")
	return normalized.strip_edges()

func _weapon_hints(value: String) -> Array[String]:
	var normalized := _normalized_label(value)
	var padded := " " + normalized + " "
	var result: Array[String] = []
	for pair: Array in WEAPON_PHRASES:
		var phrase := str(pair[0])
		var padded_phrase := " " + phrase + " "
		if padded.contains(padded_phrase):
			result.append(str(pair[1]))
			padded = padded.replace(padded_phrase, " ")
	for pair: Array in _weapon_abbreviation_matches(value):
		var hint := str(pair[1])
		if not result.has(hint): result.append(hint)
		padded = padded.replace(" " + str(pair[0]) + " ", " ")
	return result

func _weapon_abbreviation_matches(value: String) -> Array[Array]:
	var normalized := " " + _normalized_label(value) + " "
	var has_intercessor_context := normalized.contains(" intercessor ") or normalized.contains(" intersessor ")
	var result: Array[Array] = []
	for pair: Array in WEAPON_ABBREVIATIONS:
		var required_context := str(pair[2])
		if required_context == "intercessor" and not has_intercessor_context: continue
		var phrase := " " + str(pair[0]) + " "
		if not normalized.contains(phrase): continue
		result.append(pair)
		normalized = normalized.replace(phrase, " ")
	return result

func _family_hint(value: String) -> String:
	var normalized := _normalized_label(value)
	var padded := " " + normalized + " "
	for pair: Array in WEAPON_PHRASES:
		padded = padded.replace(" " + str(pair[0]) + " ", " ")
	for pair: Array in _weapon_abbreviation_matches(value):
		padded = padded.replace(" " + str(pair[0]) + " ", " ")
	for filler: String in [" with ", " and ", " w "]:
		padded = padded.replace(filler, " ")
	while "  " in padded: padded = padded.replace("  ", " ")
	return padded.strip_edges()

func _references_fingerprint(value: Variant) -> String:
	return JSON.stringify(value).sha256_text() if value is Dictionary else "".sha256_text()

func _asset_fingerprint(entry: Dictionary, components: Array) -> String:
	var identity: Dictionary = {"kind": entry.get("kind", ""), "references": entry.get("references", {})}
	if not components.is_empty(): identity["components"] = components
	return JSON.stringify(identity).sha256_text()
