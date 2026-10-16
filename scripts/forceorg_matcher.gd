extends RefCounted
## Visual-only aliases for playable profiles. Never infer game rules from model names.
## This Necron body was visually verified in docs/model-import-validation.md.
## Its parent is a separate base; the board already supplies the gameplay base.
const VERIFIED_NECRON_BODY = "https://steamusercontent-a.akamaihd.net/ugc/1344838192475887657/22D8862FB1ED4E13B18FDC6F3CA44A064C13D17C/"
static func choose(definition: String, entries: Array) -> Dictionary:
	var token := ""
	if definition.ends_with(":intercessor-squad"): token = "intercessor"
	elif definition.ends_with(":necron-warriors"): token = "necron warrior"
	elif definition.ends_with(":terminator-squad"): token = "terminator"
	elif definition.ends_with(":immortals"): token = "immortal"
	if token.is_empty(): return {"error": "No visual alias for " + definition}
	var candidates: Array[Dictionary] = []
	var seen: Dictionary = {}
	for entry: Dictionary in entries:
		var name := str(entry.get("name", "")).to_lower().replace("_", " ").replace("-", " ")
		if token not in name or "base" in name or "assault" in name or "heavy" in name or "jump" in name: continue
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
	if candidates.is_empty(): return {"error": "No compatible complete OBJ for " + token + ". Select a model manually in Models."}
	# Different paint schemes are equivalent visual variants; use a stable choice.
	candidates.sort_custom(func(a: Dictionary, b: Dictionary): return a.key < b.key if a.rank == b.rank else a.rank < b.rank)
	return {"error": "", "entry": candidates[0].entry.duplicate(true), "variants": candidates.size()}

