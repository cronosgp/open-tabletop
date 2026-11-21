extends RefCounted
## Visual-only aliases for playable profiles. Never infer game rules from model names.
## This Necron body was visually verified in docs/data/model-import-validation.md.
## Its parent is a separate base; the board already supplies the gameplay base.
const VERIFIED_NECRON_BODY = "https://steamusercontent-a.akamaihd.net/ugc/1344838192475887657/22D8862FB1ED4E13B18FDC6F3CA44A064C13D17C/"
const Assets = preload("res://scripts/local_models.gd")
const CurrentMarines = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const CurrentNecrons = preload("res://scripts/edition_11/current_reference_necron_profiles.gd")
const CurrentOrks = preload("res://scripts/edition_11/current_reference_orks_profiles.gd")
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
	"land-raider-excelsior": ["Ultramarine Land Raider"],
	"land-speeder": ["Land Speeder - Blood Angels"],
	"land-speeder-vengeance": ["Landspeeder Vengeance"],
	"marshal": ["Black Templars Marshal"],
	"nephilim-jetfighter": ["Ultramarine Stormtalon Gunship"],
	"spectrus-kill-team": ["Infiltrator"],
	"relic-razorback": ["Razorback Lascannon"],
	"suboden-khan": ["Khan on Bike"],
	"talonstrike-kill-team": ["Assault Intercessor with Jump Pack 4"],
	"wardens-of-ultramar": ["Wardens Of Ultramar - Veteran Sergeant Metaurus"],
	"ravenwing-dark-talon": ["Ultramarine Stormtalon Gunship"],
	"wolf-guard-headtakers": ["Headtakers"],
	"wulfen-with-storm-shields": ["Wulfen - Thunderhammer & Stormshield"]
}
## Reviewed TTS labels for complete Intercessor Sergeant assemblies. Keys mirror
## the two presentation-only weapon choices used by the current setup controls.
const INTERCESSOR_SERGEANT_VARIANT_NAMES := {
	"bolt-rifle|knives-and-fists": ["Intercessors Sgt w/ Bolt Rifle", "Intercessor Sgt w/ Bolt Rifle", "Intercessor Sergeant - Bolt Rifle", "Intercessor Sergeant - BR"],
	"bolt-rifle|power-weapon": ["Intercessors Sgt w/ Bolt Rifle and Power Sword", "Intercessor Sgt w/ Bolt Rifle and Power Sword", "Intercessor Sergeant - Bolt Rifle and Power Sword", "Intercessor Sergeant - BR - PS"],
	"bolt-rifle|thunder-hammer": ["Intercessors Sgt w/ Bolt Rifle and Thunder Hammer", "Intercessor Sgt w/ Bolt Rifle and Thunder Hammer", "Intercessor Sgt with hammer n rifle", "Intercessor Sergeant - Bolt Rifle and Thunder Hammer"],
	"plasma-pistol|chainsword": ["Intercessors Sgt w/ Plasma Pistol and Chainsword", "Intercessors Sgt w/ Plasma Pistol and  Chainsword", "Intercessor Sgt w/ Plasma Pistol and Chainsword"],
	"plasma-pistol|power-weapon": ["Intercessors Sgt w/ Plasma Pistol and Power Sword", "Intercessor Sgt w/ Plasma Pistol and Power Sword"],
	"plasma-pistol|power-fist": ["Intercessors Sgt w/ Plasma Pistol and Power Fist", "Intercessor Sgt w/ Plasma Pistol and Power Fist"],
	"plasma-pistol|thunder-hammer": ["Intercessors Sgt w/ Plasma Pistol and Thunder Hammer", "Intercessor Sgt w/ Plasma Pistol and Thunder Hammer"]
}
const INTERCESSOR_SERGEANT_DEFAULT_ROLE := "intercessor-sergeant:default"
const INTERCESSOR_GRENADIER_ROLE := "intercessor-model:grenade-launcher"
const INTERCESSOR_GRENADIER_VARIANT_NAMES := ["Intercessor w/ Grenade Launcher", "Intercessor Grenadier"]
static var _names_loaded := false
static var _profile_names: Dictionary = {}
static var _profile_model_roles: Dictionary = {}

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
	for suffix in [":intercessor-squad", ":assault-intercessor-squad", ":heavy-intercessor-squad", ":aggressor-squad", ":necron-warriors", ":terminator-squad", ":immortals", ":hellblaster-squad", ":bladeguard-veteran-squad", ":captain", ":chaplain"]:
		if definition.ends_with(suffix): return true
	return false

static func variants(definition: String, entries: Array) -> Array[Dictionary]:
	entries = entries.filter(func(entry: Dictionary) -> bool: return entry.get("visual_category", "miniature") == "miniature")
	var result := _base_variants(definition, entries)
	# Generated associations supplement the old aliases without redefining rules.
	for entry: Dictionary in equipment_variants(definition, entries):
		var replaced := false
		for index in range(result.size()):
			if result[index].get("variant_id", "") == entry.variant_id:
				result[index] = entry
				replaced = true
				break
		if not replaced: result.append(entry)
	var known: Dictionary = {}
	for entry: Dictionary in result: known[str(entry.get("variant_id", ""))] = true
	for role_entry: Dictionary in intercessor_sergeant_variants(definition, entries):
		var identity := str(role_entry.get("variant_id", ""))
		if identity.is_empty(): continue
		if known.has(identity):
			for index in range(result.size()):
				if result[index].get("variant_id", "") == identity: result[index] = role_entry
			continue
		known[identity] = true
		result.append(role_entry)
	for role_entry: Dictionary in intercessor_grenadier_variants(definition, entries):
		var identity := str(role_entry.get("variant_id", ""))
		if identity.is_empty(): continue
		if known.has(identity):
			for index in range(result.size()):
				if result[index].get("variant_id", "") == identity: result[index] = role_entry
			continue
		known[identity] = true
		result.append(role_entry)
	return result

static func equipment_variants(definition: String, entries: Array) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var known := {}
	for entry: Dictionary in entries:
		if definition not in entry.get("visual_definitions", []): continue
		if entry.get("visual_category", "miniature") != "miniature" or "/ChildObjects/" in str(entry.get("path", "")): continue
		var plan := Assets.component_plan(entry)
		if not _complete_visual_source(entry, plan): continue
		var identity := _source_variant_identity(entry, plan.components).sha256_text()
		if known.has(identity): continue
		known[identity] = true
		var option := entry.duplicate(true)
		option.variant_id = identity
		if not option.get("visual_weapons", []).is_empty() or not str(option.get("visual_model_role", "")).is_empty() or option.get("visual_role_constraints", {}).has(definition):
			option.visual_role = "equipment:" + definition
		result.append(option)
	result.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return str(a.variant_id) < str(b.variant_id))
	return result

static func weapon_term(value: String) -> String:
	var normalized := _normalized_visual_label(value).replace("_", " ").replace("+", " ")
	while "  " in normalized: normalized = normalized.replace("  ", " ")
	return normalized.strip_edges().replace(" ", "-")

## Match the equipped instances, not a transient attack mode or a UI label.
static func equipment_visual_score(entry: Dictionary, definition: String, unit: Dictionary) -> int:
	return int(equipment_visual_assessment(entry, definition, unit).get("score", -1))

## Describes how much trustworthy local metadata agrees with a saved model loadout.
## Confidence is evidence coverage, not a probability or a claim about sculpt parity.
static func equipment_visual_assessment(entry: Dictionary, definition: String, unit: Dictionary) -> Dictionary:
	var assessment := {
		"score": -1,
		"confidence": "unverified",
		"role_match": false,
		"matched_weapons": [],
		"configured_weapons": [],
		"coverage": 0.0,
		"rationale": "No applicable local equipment or role evidence is available."
	}
	if definition not in entry.get("visual_definitions", []): return assessment
	var role := str(entry.get("visual_model_role", ""))
	if role == "sergeant" and not bool(unit.get("sergeant", false)):
		assessment.confidence = "conflict"
		assessment.rationale = "The catalog role is for a Sergeant, but the saved model is not a Sergeant."
		return assessment
	var role_bonus := 1 if role == "sergeant" else 0
	var constraints: Dictionary = entry.get("visual_role_constraints", {})
	var role_recorded := role == "sergeant"
	if constraints.has(definition):
		var constraint: Dictionary = constraints[definition]
		role_recorded = true
		if str(constraint.get("status", "")) in ["unresolved_model_role", "ambiguous_model_role"]:
			assessment.rationale = "The catalog model-role evidence is unresolved, so it cannot confirm compatibility."
			return assessment
		var actual_roles := model_roles(unit)
		var matched := false
		for expected: String in constraint.get("roles", []):
			for actual: String in actual_roles:
				if _model_role_matches(expected, actual): matched = true
		if not matched:
			assessment.confidence = "conflict"
			assessment.rationale = "The recorded catalog model role does not match the saved model role."
			return assessment
		role_bonus = 2
	elif not role.is_empty() and role != "sergeant":
		role_recorded = true
		var matched := false
		for actual: String in model_roles(unit):
			if _model_role_matches(role, actual): matched = true
		if not matched:
			assessment.confidence = "conflict"
			assessment.rationale = "The recorded catalog model role does not match the saved model role."
			return assessment
		role_bonus = 2
	elif not role.is_empty():
		role_recorded = true
		role_bonus = 1
	var equipped := {}
	for key: String in ["ranged_weapons", "melee_weapons"]:
		for weapon: Dictionary in unit.get(key, []):
			if not str(weapon.get("name", "")).is_empty(): equipped[weapon_term(str(weapon.name))] = true
			for profile: Dictionary in weapon.get("profiles", {}).values():
				var name := str(profile.get("name", ""))
				# Profile modes do not represent additional physical weapons.
				for separator: String in [" – ", " — ", " - "]:
					name = name.split(separator)[0]
				if not name.is_empty(): equipped[weapon_term(name)] = true
	var configured_weapons: Array = equipped.keys()
	configured_weapons.sort()
	assessment.configured_weapons = configured_weapons
	assessment.role_match = role_recorded
	var weapons: Array = entry.get("visual_weapons", [])
	var aliases: Dictionary = entry.get("visual_weapon_aliases", {}).get(definition, {})
	var matched_weapons := {}
	for hint: Variant in weapons:
		var term := weapon_term(str(hint))
		if definition.ends_with(":intercessor-squad") and term == "grenade-launcher" and equipped.has("astartes-grenade-launcher"):
			term = "astartes-grenade-launcher"
		if not equipped.has(term):
			term = weapon_term(str(aliases.get(term, "")))
			if term.is_empty() or not equipped.has(term):
				assessment.confidence = "conflict"
				assessment.rationale = "A recorded catalog weapon hint does not match the saved physical weapons."
				assessment.score = -1
				return assessment
		matched_weapons[term] = true
	var matched_list: Array = matched_weapons.keys()
	matched_list.sort()
	assessment.matched_weapons = matched_list
	assessment.score = matched_list.size() * 10 + role_bonus
	if not matched_list.is_empty() and not configured_weapons.is_empty():
		assessment.coverage = float(matched_list.size()) / float(configured_weapons.size())
		if matched_list.size() == configured_weapons.size():
			assessment.confidence = "strong"
			assessment.rationale = "Catalog weapon hints cover all %d saved physical weapon%s." % [configured_weapons.size(), "" if configured_weapons.size() == 1 else "s"]
		else:
			assessment.confidence = "partial"
			assessment.rationale = "Catalog weapon hints cover %d of %d saved physical weapons." % [matched_list.size(), configured_weapons.size()]
	elif role_recorded:
		assessment.confidence = "role_only"
		assessment.rationale = "The catalog role matches, but no saved weapon is confirmed by weapon hints."
	else:
		assessment.confidence = "unverified"
		assessment.rationale = "No matching saved weapon or model-role evidence is recorded."
	return assessment

static func _model_role_matches(expected: String, actual: String) -> bool:
	var wanted := _name_tokens(expected)
	var present := _name_tokens(actual)
	if wanted.is_empty() or present.is_empty(): return false
	# Runtime role keys can be shorter than the source model name (e.g.
	# 'cenobyte' / 'Cenobyte Servitor'); both are bounded by the same datasheet.
	var wanted_present := true
	for token: String in wanted:
		if token not in present: wanted_present = false
	var present_wanted := true
	for token: String in present:
		if token not in wanted: present_wanted = false
	return wanted_present or present_wanted

static func model_roles(unit: Dictionary) -> Array[String]:
	var roles: Array[String] = []
	for key: String in unit:
		if key == "attachment_role" or not (key.ends_with("_role") or key == "model_role"): continue
		if unit[key] is String and not str(unit[key]).is_empty(): roles.append(str(unit[key]))
	if not roles.is_empty(): return roles
	_load_current_profile_names()
	var indexed_roles: Array = _profile_model_roles.get(str(unit.get("definition_id", "")), [])
	for key: String in unit:
		if not key.ends_with("_model") or not unit[key] is int: continue
		var index := int(unit[key])
		if index >= 0 and index < indexed_roles.size():
			for name: String in indexed_roles[index]:
				if not name.is_empty() and name not in roles: roles.append(name)
	if bool(unit.get("sergeant", false)) and "sergeant" not in roles: roles.append("sergeant")
	if roles.is_empty():
		var name := str(_profile_names.get(str(unit.get("definition_id", "")), ""))
		if not name.is_empty(): roles.append(name)
	return roles

static func _base_variants(definition: String, entries: Array) -> Array[Dictionary]:
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
		var identity := _source_variant_identity(entry, plan.components)
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

static func intercessor_sergeant_visual_role(unit: Dictionary) -> String:
	if not bool(unit.get("sergeant", false)) or not str(unit.get("definition_id", "")).ends_with(":intercessor-squad"): return ""
	var key := "%s|%s" % [str(unit.get("intercessor_rifle_choice", "bolt-rifle")), str(unit.get("intercessor_melee_choice", "knives-and-fists"))]
	return "intercessor-sergeant:" + key if INTERCESSOR_SERGEANT_VARIANT_NAMES.has(key) else INTERCESSOR_SERGEANT_DEFAULT_ROLE

static func intercessor_model_visual_role(unit: Dictionary) -> String:
	if not str(unit.get("definition_id", "")).ends_with(":intercessor-squad"): return ""
	if bool(unit.get("sergeant", false)): return intercessor_sergeant_visual_role(unit)
	if bool(unit.get("intercessor_grenade_launcher", false)): return INTERCESSOR_GRENADIER_ROLE
	return ""

static func intercessor_grenadier_variants(definition: String, entries: Array) -> Array[Dictionary]:
	if not definition.ends_with(":intercessor-squad"): return []
	var result: Array[Dictionary] = []
	var seen: Dictionary = {}
	for alias: String in INTERCESSOR_GRENADIER_VARIANT_NAMES:
		var expected_label := _normalized_visual_label(alias)
		for entry: Dictionary in entries:
			if _normalized_visual_label(str(entry.get("name", ""))) != expected_label: continue
			if "/ChildObjects/" in str(entry.get("path", "")): continue
			var plan := Assets.component_plan(entry)
			if not _complete_visual_source(entry, plan): continue
			var identity := _source_variant_identity(entry, plan.components)
			var family_key := str(entry.get("source_group_hint", "")).to_lower().strip_edges() + "|" + geometry_identity(entry)
			if seen.has(family_key): continue
			seen[family_key] = true
			var role_entry: Dictionary = entry.duplicate(true)
			role_entry["variant_id"] = identity.sha256_text()
			role_entry["visual_role"] = INTERCESSOR_GRENADIER_ROLE
			result.append(role_entry)
	return result

static func intercessor_sergeant_variants(definition: String, entries: Array) -> Array[Dictionary]:
	if not definition.ends_with(":intercessor-squad"): return []
	var result: Array[Dictionary] = []
	var seen: Dictionary = {}
	var roles: Array = INTERCESSOR_SERGEANT_VARIANT_NAMES.keys()
	roles.sort()
	for loadout_key: String in roles:
		var aliases: Array = INTERCESSOR_SERGEANT_VARIANT_NAMES[loadout_key]
		for entry: Dictionary in entries:
			var label := _normalized_visual_label(str(entry.get("name", "")))
			var matches := false
			for alias: String in aliases:
				if label == _normalized_visual_label(alias):
					matches = true
					break
			if not matches or "/ChildObjects/" in str(entry.get("path", "")): continue
			var plan := Assets.component_plan(entry)
			if not _complete_visual_source(entry, plan): continue
			var identity := _source_variant_identity(entry, plan.components)
			var variant_id := identity.sha256_text()
			var family_key := str(entry.get("source_group_hint", "")).to_lower().strip_edges() + "|" + loadout_key + "|" + geometry_identity(entry)
			if seen.has(family_key): continue
			seen[family_key] = true
			var role_entry: Dictionary = entry.duplicate(true)
			role_entry["variant_id"] = variant_id
			role_entry["visual_role"] = "intercessor-sergeant:" + loadout_key
			result.append(role_entry)
	return result

static func _complete_visual_source(entry: Dictionary, plan: Dictionary) -> bool:
	if not str(plan.get("error", "")).is_empty(): return false
	var planned: Array = plan.get("components", [])
	var source: Variant = entry.get("components", null)
	if not source is Array: return int(entry.get("child_components", 0)) == 0 and planned.size() == 1
	var renderable_count := 0
	for component: Variant in source:
		if not component is Dictionary: return false
		if bool(component.get("base_candidate", false)) and not bool(entry.get("preserve_source_pose", false)): continue
		var kind := str(component.get("kind", ""))
		var refs: Dictionary = component.get("references", {})
		if kind == "CustomMesh" and not str(refs.get("MeshURL", "")).strip_edges().trim_prefix("{verifycache}").is_empty(): renderable_count += 1
		elif kind == "CustomAssetbundle" and (not str(refs.get("AssetbundleURL", "")).strip_edges().trim_prefix("{verifycache}").is_empty() or not str(refs.get("AssetbundleSecondaryURL", "")).strip_edges().trim_prefix("{verifycache}").is_empty()): renderable_count += 1
	return renderable_count > 0 and renderable_count == planned.size()

static func _normalized_visual_label(value: String) -> String:
	var normalized := value.to_lower().replace("’", "'").replace("&", " and ").replace("/", " ").replace("-", " ")
	for punctuation: String in ["'", ".", ",", ":", "(", ")"]: normalized = normalized.replace(punctuation, " ")
	var words: Array[String] = []
	for word: String in normalized.split(" ", false): words.append(word.strip_edges())
	return " ".join(words)

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
		var identity := _source_variant_identity(entry, plan.components)
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
		var identity := _source_variant_identity(entry, plan.components)
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

static func geometry_identity(entry: Dictionary) -> String:
	var geometry: Array = []
	var plan := Assets.component_plan(entry)
	for component: Dictionary in plan.get("components", []):
		var refs: Dictionary = component.references
		geometry.append([refs.get("MeshURL", ""), refs.get("AssetbundleURL", ""), component.get("transforms", [])])
	return JSON.stringify(geometry).sha256_text()

static func paint_reference(entry: Dictionary) -> String:
	var plan := Assets.component_plan(entry)
	var components: Array = plan.get("components", [])
	if components.size() != 1 or components[0].kind != "CustomMesh": return ""
	return str(components[0].references.get("DiffuseURL", ""))

static func _asset_identity(entry: Dictionary, components: Array) -> String:
	var references: Array = []
	for component: Dictionary in components:
		var refs: Dictionary = component.get("references", {})
		references.append([refs.get("MeshURL", ""), refs.get("DiffuseURL", ""), refs.get("NormalURL", ""), refs.get("AssetbundleURL", ""), refs.get("AssetbundleSecondaryURL", ""), component.get("transforms", [])])
	if references.is_empty():
		var refs: Dictionary = entry.get("references", {})
		references.append([refs.get("MeshURL", ""), refs.get("DiffuseURL", ""), refs.get("NormalURL", ""), refs.get("AssetbundleURL", ""), refs.get("AssetbundleSecondaryURL", "")])
	return JSON.stringify(references)

static func _source_variant_identity(entry: Dictionary, components: Array) -> String:
	# Keep distinct TTS objects selectable even when they reuse the same mesh
	# references. Geometry identity still deduplicates those objects for the
	# automatic distinct-sculpt pool.
	var guid := str(entry.get("guid", "")).strip_edges()
	var path := str(entry.get("path", "")).strip_edges()
	var source := ""
	if not guid.is_empty() or not path.is_empty():
		source = JSON.stringify([guid, path, str(entry.get("name", "")), str(entry.get("kind", ""))])
	else:
		source = str(entry.get("id", ""))
	if source.is_empty(): return _asset_identity(entry, components)
	return JSON.stringify([source, _asset_identity(entry, components)])

static func _profile_name(definition: String) -> String:
	var identity_parts := definition.split(":")
	var identity: String = identity_parts[-1] if not identity_parts.is_empty() else definition
	_load_current_profile_names()
	var override := str(PROFILE_NAME_OVERRIDES.get(identity, ""))
	if not override.is_empty(): return override
	if _profile_names.has(definition): return str(_profile_names[definition])
	return ""

static func _load_current_profile_names() -> void:
	if _names_loaded: return
	_names_loaded = true
	for spec: Dictionary in [{"prefix": "40kdc:11e:adeptus-astartes:", "catalog": CurrentMarines.catalog()}, {"prefix": "40kdc:11e:necrons:", "catalog": CurrentNecrons.catalog()}, {"prefix": "40kdc:11e:orks:", "catalog": CurrentOrks.catalog()}]:
		for identity: String in spec.catalog:
			var definition := str(spec.prefix) + identity
			var profile: Dictionary = spec.catalog[identity]
			_profile_names[definition] = str(profile.get("name", ""))
			var roles: Array = []
			for loadout: Dictionary in profile.get("model_loadouts", []):
				roles.append([str(loadout.get("source_model_name", "")), str(loadout.get("role", ""))])
			_profile_model_roles[definition] = roles

