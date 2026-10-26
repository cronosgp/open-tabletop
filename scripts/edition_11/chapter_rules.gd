extends RefCounted
## Resolves player Chapter context and applies current conditional Astartes keywords.
const CurrentMarineProfiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const AbilityCatalog = preload("res://scripts/edition_11/unit_ability_catalog.gd")
const Capabilities = preload("res://scripts/edition_11/capabilities.gd")
const ID := "space-marine-conditional-chapter-keywords-v1"
const DARK_ANGELS_DEATHWING_IDENTITIES := [
	"bladeguard-ancient",
	"bladeguard-veteran-squad",
	"sternguard-veteran-squad",
	"vanguard-veteran-squad-with-jump-packs",
	"land-raider",
	"land-raider-crusader",
	"land-raider-redeemer",
	"repulsor",
	"repulsor-executioner",
]
static var _profile_catalog: Dictionary = {}
static var _profile_catalog_ready := false


static func normalize_assignments(value: Variant) -> Dictionary:
	var source: Dictionary = value if value is Dictionary else {}
	var result := {1: "", 2: ""}
	for owner in [1, 2]:
		result[owner] = str(source.get(owner, source.get(str(owner), ""))).strip_edges().to_upper()
	return result


static func has_current_reference_marines(state: Dictionary) -> bool:
	for model: int in state.get("units", {}):
		var unit: Dictionary = state.units[model]
		var profile := _current_profile(AbilityCatalog.identity(unit))
		if not profile.is_empty() and "ADEPTUS ASTARTES" in profile.get("keywords", []):
			return true
	return false


static func resolve_and_apply(state: Dictionary, detachment_assignments: Dictionary, requested_value: Variant) -> Dictionary:
	var requested := normalize_assignments(requested_value)
	for owner in [1, 2]:
		var selected := str(requested[owner])
		if not selected.is_empty() and not CurrentMarineProfiles.CHAPTER_KEYWORD_NAMES.has(selected):
			return {"error": "Choose a recognized Space Marine Chapter for Player %d." % owner}

	var resolved := {1: "", 2: ""}
	for owner in [1, 2]:
		var represented: Array[String] = []
		var has_current_adeptus_astartes := false
		for model: int in state.units:
			var unit: Dictionary = state.units[model]
			if int(unit.get("owner", -1)) != owner:
				continue
			var identity := AbilityCatalog.identity(unit)
			var profile := _current_profile(identity)
			if profile.is_empty():
				continue
			var profile_keywords: Array = profile.get("keywords", [])
			if "ADEPTUS ASTARTES" not in profile_keywords:
				continue
			has_current_adeptus_astartes = true
			for chapter: String in CurrentMarineProfiles.chapter_keywords_for(profile_keywords):
				if chapter not in represented:
					represented.append(chapter)
		if represented.size() > 1:
			return {"error": "Player %d's current-reference roster contains more than one Space Marine Chapter." % owner}

		var selected := str(requested[owner])
		if not selected.is_empty() and not has_current_adeptus_astartes:
			return {"error": "Player %d's Chapter context requires a current-reference Adeptus Astartes roster." % owner}
		if not represented.is_empty() and not selected.is_empty() and selected != represented[0]:
			return {"error": "Player %d's selected Chapter conflicts with the roster's %s identity." % [owner, CurrentMarineProfiles.chapter_name(represented[0])]}

		var chapter := selected
		if chapter.is_empty() and not represented.is_empty():
			chapter = represented[0]
		var detachment := str(detachment_assignments.get(owner, detachment_assignments.get(str(owner), "none")))
		var required_chapter := ""
		if detachment in ["wrath-of-the-rock", "darkflight-pursuit", "inner-circle-task-force"]:
			required_chapter = "DARK ANGELS"
		elif detachment == "fist-of-the-god-emperor":
			required_chapter = "BLACK TEMPLARS"
		elif detachment == "spearpoint-task-force":
			required_chapter = "WHITE SCARS"
		elif detachment == "medusa-wrath":
			required_chapter = "IRON HANDS"
		elif detachment == "blade-of-ultramar":
			required_chapter = "ULTRAMARINES"
		if chapter.is_empty() and not required_chapter.is_empty():
			chapter = required_chapter
		elif not required_chapter.is_empty() and chapter != required_chapter:
			var detachment_names := {"blade-of-ultramar": "Blade of Ultramar", "medusa-wrath": "Medusa's Wrath", "wrath-of-the-rock": "Wrath of the Rock", "darkflight-pursuit": "Darkflight Pursuit", "inner-circle-task-force": "Inner Circle Task Force", "fist-of-the-god-emperor": "Fist of the God-Emperor", "spearpoint-task-force": "Spearpoint Task Force"}
			var detachment_name := str(detachment_names.get(detachment, "Space Marine detachment"))
			return {"error": "%s requires %s Chapter context for Player %d." % [detachment_name, CurrentMarineProfiles.chapter_name(required_chapter), owner]}
		if not chapter.is_empty() and not has_current_adeptus_astartes:
			return {"error": "Player %d's Chapter context requires a current-reference Adeptus Astartes roster." % owner}
		resolved[owner] = chapter

	for model: int in state.units:
		var unit: Dictionary = state.units[model]
		var owner := int(unit.get("owner", -1))
		if owner not in [1, 2]: continue
		var identity := AbilityCatalog.identity(unit)
		if identity.is_empty():
			continue
		var profile := _current_profile(identity)
		if profile.is_empty():
			continue
		var profile_keywords: Array = profile.get("keywords", [])
		if "ADEPTUS ASTARTES" not in profile_keywords:
			continue
		var keywords: Array = unit.get("keywords", []).duplicate()
		# The local export can expose Dark Angels rule keywords on shared profiles.
		# Normalize them out before applying the selected Chapter context.
	while "DEATHWING" in keywords:
		keywords.erase("DEATHWING")
	while "RAVENWING" in keywords:
		keywords.erase("RAVENWING")
		if str(resolved[owner]) == "DARK ANGELS" and ("TERMINATOR" in profile_keywords or "DREADNOUGHT" in profile_keywords or identity in DARK_ANGELS_DEATHWING_IDENTITIES):
			if "DEATHWING" not in keywords:
				keywords.append("DEATHWING")
		if str(resolved[owner]) == "DARK ANGELS" and ("MOUNTED" in profile_keywords or ("VEHICLE" in profile_keywords and "FLY" in profile_keywords)):
			if "RAVENWING" not in keywords:
				keywords.append("RAVENWING")
		unit.keywords = keywords
		state.units[model] = unit

	state.marine_chapters = resolved.duplicate(true)
	state.marine_chapter_selections = requested.duplicate(true)
	for owner in [1, 2]:
		if str(resolved[owner]) == "DARK ANGELS":
			Capabilities.admit(state, "marine-conditional-chapter-keywords", ID)
			break
	return {"error": "", "chapters": resolved, "selections": requested}


static func _current_profile(identity: String) -> Dictionary:
	if not _profile_catalog_ready:
		_profile_catalog = CurrentMarineProfiles.catalog()
		_profile_catalog_ready = true
	return _profile_catalog.get(identity, {})
