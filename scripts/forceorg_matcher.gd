extends RefCounted
## Visual-only aliases for playable profiles. Never infer game rules from model names.
## This Necron body was visually verified in docs/data/model-import-validation.md.
## Its parent is a separate base; the board already supplies the gameplay base.
const VERIFIED_NECRON_BODY = "https://steamusercontent-a.akamaihd.net/ugc/1344838192475887657/22D8862FB1ED4E13B18FDC6F3CA44A064C13D17C/"
static func choose(definition: String, entries: Array) -> Dictionary:
	if not supported_definition(definition): return {"error": "No visual alias for " + definition, "variants": 0, "options": []}
	var options := variants(definition, entries)
	if options.is_empty(): return {"error": "No compatible complete OBJ for " + definition + ". Select a model manually in Models.", "variants": 0, "options": []}
	return {"error": "", "entry": options[0], "variants": options.size(), "options": options}

static func supported_definition(definition: String) -> bool:
	for suffix in [":intercessor-squad", ":assault-intercessor-squad", ":heavy-intercessor-squad", ":necron-warriors", ":terminator-squad", ":immortals"]:
		if definition.ends_with(suffix): return true
	return false

static func variants(definition: String, entries: Array) -> Array[Dictionary]:
	var token := ""
	if definition.ends_with(":intercessor-squad"): token = "intercessor"
	elif definition.ends_with(":assault-intercessor-squad"): token = "assault intercessor"
	elif definition.ends_with(":heavy-intercessor-squad"): token = "heavy intercessor"
	elif definition.ends_with(":necron-warriors"): token = "necron warrior"
	elif definition.ends_with(":terminator-squad"): token = "terminator"
	elif definition.ends_with(":immortals"): token = "immortal"
	if token.is_empty(): return []
	var candidates: Array[Dictionary] = []
	var seen: Dictionary = {}
	for entry: Dictionary in entries:
		var name := str(entry.get("name", "")).to_lower().replace("_", " ").replace("-", " ")
		if token not in name or "base" in name or "jump" in name: continue
		if token == "intercessor" and ("assault" in name or "heavy" in name): continue
		if token == "terminator" and ("captain" in name or "librarian" in name or "chaplain" in name or "chaos" in name or "blightlord" in name or "deathshroud" in name or "scarab occult" in name): continue
		var refs: Dictionary = entry.get("references", {})
		var verified_body: bool = token == "necron warrior" and refs.get("MeshURL", "") == VERIFIED_NECRON_BODY
		# Composite transforms/materials are not supported by the single-OBJ renderer.
		if entry.get("kind") != "CustomMesh" or int(entry.get("child_components", 0)) > 0: continue
		if ("/ChildObjects/" in str(entry.get("path", "")) or "component" in name) and not verified_body: continue
		if str(refs.get("MeshURL", "")).is_empty() or not str(refs.get("NormalURL", "")).is_empty(): continue
		var identity := JSON.stringify([refs.get("MeshURL", ""), refs.get("DiffuseURL", "")])
		if seen.has(identity): continue
		seen[identity] = true
		var rank := 0 if name.strip_edges() in [token, token + "s", "primaris " + token] else 1
		if token == "immortal" and "gauss" in name: rank = -1
		if verified_body: rank = -1
		candidates.append({"rank": rank, "key": identity, "entry": entry})
	if candidates.is_empty(): return []
	# Different paint schemes are equivalent visual variants; use a stable choice.
	candidates.sort_custom(func(a: Dictionary, b: Dictionary): return a.key < b.key if a.rank == b.rank else a.rank < b.rank)
	var result: Array[Dictionary] = []
	for candidate: Dictionary in candidates:
		var entry: Dictionary = candidate.entry.duplicate(true)
		entry.variant_id = candidate.key.sha256_text()
		result.append(entry)
	return result

