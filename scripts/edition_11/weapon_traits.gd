extends RefCounted
## Selection-time weapon traits. Target keywords are frozen before casualties.

static func extra(stats: Dictionary) -> bool:
	return stats.get("keywords", {}).get("extra-attacks", false) == true

static func heavy_model(model: Dictionary) -> bool:
	for keyword: Variant in model.get("keywords", []):
		if str(keyword).strip_edges().to_upper() in ["MONSTER", "VEHICLE"]: return true
	return false

static func heavy_unit(state: Dictionary, squad: int) -> bool:
	var keywords := target_keywords(state, squad)
	return "MONSTER" in keywords or "VEHICLE" in keywords

static func target_keywords(state: Dictionary, squad: int) -> Array[String]:
	var result: Array[String] = []
	for model: Dictionary in state.units.values():
		if model.squad != squad or model.wounds <= 0: continue
		for keyword: Variant in model.get("keywords", []):
			var normalized := str(keyword).strip_edges().to_upper()
			if normalized not in result: result.append(normalized)
	return result

static func hunter_error(stats: Dictionary, keywords: Variant) -> String:
	if not stats.get("keywords", {}).has("hunter"): return ""
	var required: Variant = stats.keywords.hunter
	if not required is Array or required.is_empty() or required.size() > 32: return "Hunter requires a nonempty list of target keywords."
	for keyword: Variant in required:
		if not keyword is String or keyword.strip_edges().is_empty() or keyword.length() > 100: return "Invalid Hunter target keyword."
	if not keywords is Array: return "Hunter requires target keywords at declaration."
	for keyword: String in required:
		for actual: Variant in keywords:
			if actual is String and actual.strip_edges().to_upper() == keyword.strip_edges().to_upper(): return ""
	return "Hunter profile requires a target with one of: " + ", ".join(required)

static func import_keywords(entries: Array) -> Dictionary:
	var result: Dictionary = {}
	for item: Dictionary in entries:
		var keyword: String = item.get("keyword_id", "")
		var allowed := ["target_keyword"] if keyword == "hunter" else (["value"] if keyword in ["rapid-fire", "sustained-hits", "blast"] else [])
		for parameter: String in item.get("parameters", {}):
			if parameter not in allowed: result["unsupported-parameters:" + keyword] = true
		if keyword == "hunter":
			if not result.has(keyword): result[keyword] = []
			var target: Variant = item.get("parameters", {}).get("target_keyword")
			if not target is String or target.strip_edges().is_empty(): result[keyword] = null
			elif result[keyword] is Array and target not in result[keyword]: result[keyword].append(target)
		else:
			result[keyword] = item.get("parameters", {}).get("value", true) if keyword in ["rapid-fire", "sustained-hits", "blast"] else true
	return result

static func import_profile(profile: Dictionary) -> Dictionary:
	var result := import_keywords(profile.get("keywords", []))
	var restrictions: Variant = profile.get("target_restrictions", {})
	if not restrictions is Dictionary:
		result["unsupported-target-restriction"] = true
		return result
	for key: String in restrictions:
		if key != "required_keywords_any": result["unsupported-target-restriction"] = true
	if restrictions.has("required_keywords_any"):
		var required: Variant = restrictions.required_keywords_any
		if not result.has("hunter"): result.hunter = required
		elif not required is Array or not result.hunter is Array:
			result["unsupported-target-restriction"] = true
		else:
			var declared: Array = []
			var structured: Array = []
			for item: Variant in result.hunter: declared.append(str(item).strip_edges().to_upper())
			for item: Variant in required: structured.append(str(item).strip_edges().to_upper())
			declared.sort()
			structured.sort()
			if declared != structured: result["unsupported-target-restriction"] = true
	return result
