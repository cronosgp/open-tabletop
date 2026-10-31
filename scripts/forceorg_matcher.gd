extends RefCounted
## Visual-only aliases for playable profiles. Never infer game rules from model names.
## This Necron body was visually verified in docs/data/model-import-validation.md.
## Its parent is a separate base; the board already supplies the gameplay base.
const VERIFIED_NECRON_BODY = "https://steamusercontent-a.akamaihd.net/ugc/1344838192475887657/22D8862FB1ED4E13B18FDC6F3CA44A064C13D17C/"
const Assets = preload("res://scripts/local_models.gd")
const PROFILE_NAME_OVERRIDES := {
	"adrax-agatone": "Adrax Agatone Salamanders",
	"mephiston": "Chief Librarian Mephiston",
	"emperor-s-champion": "Emperor’s Champion",
	"eradicator-squad-with-melta-rifles": "Eradicator Squad with Melta Rifles",
	"black-templars-gladiator-lancer": "Gladiator Lancer",
	"black-templars-gladiator-reaper": "Gladiator Reaper",
	"black-templars-gladiator-valiant": "Gladiator Valiant",
	"black-templars-impulsor": "Impulsor",
	"invader-atvs": "Invader ATVs",
	"kor-sarro-khan": "Kor’sarro Khan",
	"nephilim-jetfighter": "Nephilim Jetfighter",
	"marneus-calgar": "Marneus Calgar",
	"black-templars-repulsor": "Repulsor",
	"black-templars-repulsor-executioner": "Repulsor Executioner",
	"ravenwing-dark-talon": "Ravenwing Dark Talon"
}
## Reviewed visual-only fallbacks for profiles without a compatible exact-named OBJ.
## These choices affect appearance only; they do not change datasheets or army rules.
const PROFILE_VISUAL_ALIASES := {
	"adrax-agatone": ["Salamanders Captain"],
	"asmodai": ["Asmodai (Old Model)", "Asmodai"],
	"astorath": ["Astorath the Grim"],
	"belial": ["Belial - Grandmaster Of The Deathwing"],
	"caanok-var": ["Caanok Vaar"],
	"captain-on-bike": ["Ravenwing Captain on Bike"],
	"captain-titus": ["Wardens Of Ultramar - Captain Titus"],
	"deathwatch-terminator-squad": ["Deathwatch Terminator Captain with Power Fist"],
	"decimus-kill-team": ["Deathwatch Veteran"],
	"eradicator-squad-with-heavy-bolters": ["Primaris Eradicator w/Heavy Melta Rifle"],
	"fortis-kill-team": ["Intercessor"],
	"indomitor-kill-team": ["Heavy Intercessor 1"],
	"kaius-konorius": ["Primaris Captain"],
	"land-speeder": ["Land Speeder - Blood Angels"],
	"land-speeder-vengeance": ["Landspeeder Vengeance"],
	"marshal": ["Black Templars Marshal"],
	"nephilim-jetfighter": ["Ultramarine Stormtalon Gunship"],
	"spectrus-kill-team": ["Infiltrator"],
	"suboden-khan": ["Khan on Bike"],
	"talonstrike-kill-team": ["Assault Intercessor with Jump Pack 4"],
	"wardens-of-ultramar": ["Wardens Of Ultramar - Veteran Sergeant Metaurus"],
	"ravenwing-dark-talon": ["Ultramarine Stormtalon Gunship"],
	"wolf-guard-headtakers": ["Headtakers"],
	"wulfen-with-storm-shields": ["Wulfen - Thunderhammer & Stormshield"]
}
static var _names_loaded := false
static var _profile_names: Dictionary = {}

static func choose(definition: String, entries: Array) -> Dictionary:
	if not supported_definition(definition): return {"error": "No visual alias for " + definition, "variants": 0, "options": [], "visual_alias": false}
	var options := variants(definition, entries)
	if options.is_empty(): return {"error": "No compatible complete OBJ for " + definition + ". Select a model manually in Models.", "variants": 0, "options": [], "visual_alias": uses_reviewed_visual_alias(definition)}
	return {"error": "", "entry": options[0], "variants": options.size(), "options": options, "visual_alias": _is_reviewed_alias_entry(definition, options[0])}

static func uses_reviewed_visual_alias(definition: String) -> bool:
	if not definition.begins_with("40kdc:11e:"): return false
	var identity_parts := definition.split(":")
	var identity: String = identity_parts[-1] if not identity_parts.is_empty() else definition
	return PROFILE_VISUAL_ALIASES.has(identity)

static func supported_definition(definition: String) -> bool:
	if not definition.begins_with("40kdc:11e:"): return false
	if not _profile_alias_names(definition).is_empty(): return true
	if not _profile_name(definition).is_empty(): return true
	for suffix in [":intercessor-squad", ":assault-intercessor-squad", ":heavy-intercessor-squad", ":necron-warriors", ":terminator-squad", ":immortals", ":hellblaster-squad", ":bladeguard-veteran-squad", ":captain", ":chaplain"]:
		if definition.ends_with(suffix): return true
	return false

static func variants(definition: String, entries: Array) -> Array[Dictionary]:
	var exact_alias_names := _profile_alias_names(definition)
	var preferred_profile_name := _profile_name(definition)
	if not preferred_profile_name.is_empty():
		var preferred := _named_profile_variants(preferred_profile_name, entries)
		if not preferred.is_empty():
			var identities: Dictionary = {}
			for entry: Dictionary in preferred: identities[str(entry.get("variant_id", ""))] = true
			for fallback: Dictionary in _exact_named_variants(exact_alias_names, entries):
				if not identities.has(str(fallback.get("variant_id", ""))): preferred.append(fallback)
			return preferred
	if not exact_alias_names.is_empty(): return _exact_named_variants(exact_alias_names, entries)
	var token := ""
	if definition.ends_with(":intercessor-squad"): token = "intercessor"
	elif definition.ends_with(":assault-intercessor-squad"): token = "assault intercessor"
	elif definition.ends_with(":heavy-intercessor-squad"): token = "heavy intercessor"
	elif definition.ends_with(":necron-warriors"): token = "necron warrior"
	elif definition.ends_with(":terminator-squad"): token = "terminator"
	elif definition.ends_with(":immortals"): token = "immortal"
	elif definition.ends_with(":hellblaster-squad"): token = "hellblaster"
	elif definition.ends_with(":bladeguard-veteran-squad"): token = "bladeguard"
	elif definition.ends_with(":captain"): token = "captain"
	elif definition.ends_with(":chaplain"): token = "chaplain"
	if token.is_empty():
		var profile_name := _profile_name(definition)
		if profile_name.is_empty(): return []
		return _named_profile_variants(profile_name, entries)
	var candidates: Array[Dictionary] = []
	var seen: Dictionary = {}
	var expected_tokens := _name_tokens(_profile_name(definition))
	if expected_tokens.is_empty(): expected_tokens = _name_tokens(token)
	for entry: Dictionary in entries:
		var name := str(entry.get("name", "")).to_lower().replace("_", " ").replace("-", " ")
		if token not in name or "base" in name or "jump" in name: continue
		if token == "intercessor" and ("assault" in name or "heavy" in name): continue
		if token == "bladeguard" and "ancient" in name: continue
		if token == "captain":
			var rejected_captain_variant := false
			for phrase in ["terminator", "gravis", "phobos", "bike", "death company", "titus", "calgar", "lysander", "sicarius", "helbrecht", "artemis", "garadon"]:
				if phrase in name:
					rejected_captain_variant = true
					break
			if rejected_captain_variant: continue
		if token == "chaplain":
			var rejected_chaplain_variant := false
			for phrase in ["terminator", "bike", "death company", "grimaldus", "ulrik", "asmodai", "astorath", "lemartes"]:
				if phrase in name:
					rejected_chaplain_variant = true
					break
			if rejected_chaplain_variant: continue
		if token == "terminator" and ("captain" in name or "librarian" in name or "chaplain" in name or "chaos" in name or "blightlord" in name or "deathshroud" in name or "scarab occult" in name): continue
		var refs: Dictionary = entry.get("references", {})
		var verified_body: bool = token == "necron warrior" and refs.get("MeshURL", "") == VERIFIED_NECRON_BODY
		if ("/ChildObjects/" in str(entry.get("path", "")) or "component" in name) and not verified_body: continue
		var candidate_tokens := _name_tokens(str(entry.get("name", "")))
		var family_match := candidate_tokens == expected_tokens or (token == "immortal" and "immortal" in candidate_tokens and "gauss" in candidate_tokens)
		if not family_match and not verified_body: continue
		var plan := Assets.component_plan(entry)
		if not str(plan.get("error", "")).is_empty(): continue
		var identity := _asset_identity(entry, plan.components)
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

static func _is_reviewed_alias_entry(definition: String, entry: Dictionary) -> bool:
	var aliases := _profile_alias_names(definition)
	return str(entry.get("name", "")).strip_edges().to_lower() in aliases

static func _profile_alias_names(definition: String) -> Array[String]:
	var identity_parts := definition.split(":")
	var identity: String = identity_parts[-1] if not identity_parts.is_empty() else definition
	if PROFILE_VISUAL_ALIASES.has(identity):
		var reviewed: Array[String] = []
		for name: String in PROFILE_VISUAL_ALIASES[identity]: reviewed.append(name.to_lower())
		return reviewed
	if definition.ends_with(":death-company-marines-with-jump-packs"):
		return ["death company (jump) - chainsword", "death company marines with jump packs - eviscerator"]
	if definition.ends_with(":death-company-marines"): return ["death company - chainsword"]
	if definition.ends_with(":desolation-squad"): return ["primaris desolation squad sergeant"]
	if definition.ends_with(":scout-squad"): return ["scout bolter"]
	return []

static func _exact_named_variants(names: Array[String], entries: Array) -> Array[Dictionary]:
	var candidates: Array[Dictionary] = []
	var seen: Dictionary = {}
	for entry: Dictionary in entries:
		var normalized_name := str(entry.get("name", "")).strip_edges().to_lower()
		var name_rank := names.find(normalized_name)
		if name_rank < 0: continue
		if "component" in str(entry.get("name", "")).to_lower(): continue
		var plan := Assets.component_plan(entry)
		if not str(plan.get("error", "")).is_empty(): continue
		var identity := _asset_identity(entry, plan.components)
		if seen.has(identity):
			var existing_index := int(seen[identity])
			if name_rank < int(candidates[existing_index].rank): candidates[existing_index].rank = name_rank
			continue
		seen[identity] = candidates.size()
		candidates.append({"rank": name_rank, "key": identity, "entry": entry})
	candidates.sort_custom(func(a: Dictionary, b: Dictionary): return str(a.key) < str(b.key) if a.rank == b.rank else a.rank < b.rank)
	var result: Array[Dictionary] = []
	for candidate: Dictionary in candidates:
		var entry: Dictionary = candidate.entry.duplicate(true)
		entry.variant_id = str(candidate.key).sha256_text()
		result.append(entry)
	return result

static func _named_profile_variants(profile_name: String, entries: Array) -> Array[Dictionary]:
	var target_tokens := _name_tokens(profile_name)
	if target_tokens.is_empty(): return []
	var candidates: Array[Dictionary] = []
	var seen: Dictionary = {}
	for entry: Dictionary in entries:
		if "component" in str(entry.get("name", "")).to_lower(): continue
		var entry_name := str(entry.get("name", ""))
		var candidate_tokens := _name_tokens(entry_name)
		var exact := candidate_tokens == target_tokens
		if not exact: continue
		var plan := Assets.component_plan(entry)
		if not str(plan.get("error", "")).is_empty(): continue
		var identity := _asset_identity(entry, plan.components)
		if seen.has(identity): continue
		seen[identity] = true
		candidates.append({"rank": 0 if exact else 1, "key": identity, "entry": entry})
	var has_exact := false
	for candidate: Dictionary in candidates:
		if int(candidate.rank) == 0: has_exact = true
	if has_exact:
		var exact_candidates: Array[Dictionary] = []
		for candidate: Dictionary in candidates:
			if int(candidate.rank) == 0: exact_candidates.append(candidate)
		candidates = exact_candidates
	candidates.sort_custom(func(a: Dictionary, b: Dictionary): return a.key < b.key if a.rank == b.rank else a.rank < b.rank)
	var result: Array[Dictionary] = []
	for candidate: Dictionary in candidates:
		var entry: Dictionary = candidate.entry.duplicate(true)
		entry.variant_id = str(candidate.key).sha256_text()
		result.append(entry)
	return result

static func _name_tokens(value: String) -> Array[String]:
	var normalized := value.to_lower().replace("’", "'").replace("-", " ")
	for punctuation: String in ["'", ".", ",", ":", "(", ")"]: normalized = normalized.replace(punctuation, " ")
	var tokens: Array[String] = []
	for token_value: String in normalized.split(" ", false):
		var token := token_value.strip_edges()
		if token in ["squad", "team", "with", "the", "and", "of", "in", "on", "armour", "armor"]: continue
		if token == "primaris" or token == "master": continue
		if token == "atvs": token = "atv"
		if token.length() > 4 and token.ends_with("s"): token = token.trim_suffix("s")
		if not token.is_empty() and token not in tokens: tokens.append(token)
	tokens.sort()
	return tokens

static func _asset_identity(entry: Dictionary, components: Array) -> String:
	var references: Array = []
	for component: Dictionary in components:
		var refs: Dictionary = component.get("references", {})
		references.append([refs.get("MeshURL", ""), refs.get("DiffuseURL", ""), refs.get("NormalURL", ""), refs.get("AssetbundleURL", ""), refs.get("AssetbundleSecondaryURL", ""), component.get("transforms", [])])
	if references.is_empty():
		var refs: Dictionary = entry.get("references", {})
		references.append([refs.get("MeshURL", ""), refs.get("DiffuseURL", ""), refs.get("NormalURL", ""), refs.get("AssetbundleURL", ""), refs.get("AssetbundleSecondaryURL", "")])
	return JSON.stringify(references)

static func _profile_name(definition: String) -> String:
	var identity_parts := definition.split(":")
	var identity: String = identity_parts[-1] if not identity_parts.is_empty() else definition
	if not _names_loaded:
		_names_loaded = true
		var path := "res://data/imported/starter-11e-v1/adeptus-astartes/units.json"
		if FileAccess.file_exists(path):
			var parser := JSON.new()
			if parser.parse(FileAccess.get_file_as_string(path)) == OK and parser.data is Array:
				for unit: Variant in parser.data:
					if unit is Dictionary: _profile_names[str(unit.get("id", ""))] = str(unit.get("name", ""))
	var override := str(PROFILE_NAME_OVERRIDES.get(identity, ""))
	if not override.is_empty(): return override
	if _profile_names.has(definition): return str(_profile_names[definition])
	return ""

