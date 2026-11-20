extends RefCounted
## Unified 11th-edition Muster Your Army legality validator for Space Marines and Necrons.
## Pure rules-layer module: zero UI or node dependencies.

const A = preload("res://scripts/edition_11/army_capabilities.gd")
const Roster = preload("res://scripts/army_roster.gd")
const DetachmentCatalog = preload("res://scripts/edition_11/detachment_catalog.gd")
const ChapterRules = preload("res://scripts/edition_11/chapter_rules.gd")
const CurrentMarines = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const CurrentNecrons = preload("res://scripts/edition_11/current_reference_necron_profiles.gd")
const Supports = preload("res://scripts/edition_11/support_attachments.gd")
const StormlanceEnhancements = preload("res://scripts/edition_11/stormlance_enhancements.gd")
const UnitAbilities = preload("res://scripts/edition_11/unit_abilities.gd")
const UnitAbilityCatalog = preload("res://scripts/edition_11/unit_ability_catalog.gd")
const SavedEquipment = preload("res://scripts/edition_11/saved_equipment_profiles.gd")

const ID := "army-legality-11e-v1"
const MAX_ENHANCEMENTS_PER_ARMY := 3
const LEGACY_CANNOT_BE_WARLORD_SLUGS := ["murderfang"]
const SUPREME_COMMANDER_SLUGS := ["roboute-guilliman", "lion-eljonson", "the-silent-king"]

static func current_profile_for_entry(faction: String, slug: String) -> Dictionary:
	return A.current_reference_profile(faction, slug)

static func evaluate_selection(selection_or_report: Dictionary, context: Dictionary = {}) -> Dictionary:
	var errors: Array[String] = []
	var warnings: Array[String] = []
	var checks: Array[Dictionary] = []
	var legality_mode := str(context.get("legality_mode", "matched_play"))
	var detachments := _resolve_detachments(selection_or_report, context)
	var marine_detachment := str(detachments[0].get("id", "none")) if not detachments.is_empty() else str(context.get("marine_detachment", "none"))

	var report: Dictionary = selection_or_report
	if not report.has("definitions") or not report.has("selection"):
		var roster_ctx := {"marine_detachment": marine_detachment}
		report = A.admit(selection_or_report, A.MATCH_UNIT_CAP, roster_ctx)
	if not str(report.get("error", "")).is_empty():
		errors.append(str(report.error))
		return _result(false, errors, warnings, checks, report)

	var selection: Dictionary = report.get("selection", {})
	var faction := str(selection.get("faction", ""))
	var category := str(selection.get("category", "incursion"))
	var points_limit := int(selection.get("points_limit", 1000))
	var entries: Array = selection.get("entries", [])
	var total := int(report.get("total", 0))

	# 1. Points limit
	var points_ok := total <= points_limit and not entries.is_empty()
	if entries.is_empty():
		errors.append("Roster must contain at least one unit.")
	elif total > points_limit:
		errors.append("Roster exceeds the %s points limit: %d / %d pts." % [category.replace("_", " ").capitalize(), total, points_limit])
	checks.append({"id": "POINTS_LIMIT", "label": "Points budget (%d / %d)" % [total, points_limit], "ok": points_ok})

	# 2. Detachment DP budget & Chapter lock
	var dp_err := DetachmentCatalog.dp_error(detachments, category)
	if not dp_err.is_empty():
		errors.append(dp_err)
	if detachments.size() > 1 and bool(context.get("require_single_detachment_runtime", true)):
		errors.append("Match execution currently supports one detachment per army.")
	checks.append({"id": "DETACHMENT_DP_BUDGET", "label": "Detachment DP budget", "ok": dp_err.is_empty()})

	# 3. Per-entry checks: Warlord eligibility, Supreme Commander, Enhancements, Chapter, Legends, Transports
	var warlord_eligible_count := 0
	var supreme_commanders: Array[String] = []
	var enhancement_count := 0
	var seen_enhancements: Dictionary = {}
	var seen_chapters: Array[String] = []
	var dedicated_transport_copies := 0
	var embarkable_infantry_copies := 0
	var legends_units: Array[String] = []

	for entry: Dictionary in entries:
		var definition_id := str(entry.get("definition_id", ""))
		var slug := definition_id.get_slice(":", 3)
		var copies := int(entry.get("copies", 1))
		var resolved: Dictionary = report.get("definitions", {}).get(definition_id, {})
		var profile := current_profile_for_entry(faction, slug)
		var keywords: Array = profile.get("keywords", resolved.get("unit", {}).get("keywords", []))
		var upper_keywords := str(keywords).to_upper()

		if "CHARACTER" in upper_keywords:
			if slug not in LEGACY_CANNOT_BE_WARLORD_SLUGS:
				warlord_eligible_count += copies
		if slug in SUPREME_COMMANDER_SLUGS or "SUPREME COMMANDER" in upper_keywords:
			if slug not in supreme_commanders:
				supreme_commanders.append(slug)

		var enhancement_id := str(entry.get("enhancement_id", ""))
		if not enhancement_id.is_empty():
			enhancement_count += copies
			if "EPIC HERO" in upper_keywords:
				errors.append("Epic Hero %s cannot be given an Enhancement." % slug)
			if seen_enhancements.has(enhancement_id):
				errors.append("Duplicate Enhancement selected: %s." % enhancement_id)
			seen_enhancements[enhancement_id] = true
			var enh_detachment := str(StormlanceEnhancements.RECORDS.get(enhancement_id, {}).get("detachment", ""))
			if not detachments.is_empty() and not enh_detachment.is_empty():
				var allowed_ids: Array[String] = []
				for det: Dictionary in detachments:
					allowed_ids.append(str(det.get("id", "")))
				if enh_detachment not in allowed_ids:
					errors.append("Enhancement %s requires the %s detachment." % [enhancement_id, enh_detachment])

		if faction == "Space Marines":
			for ch: String in CurrentMarines.chapter_keywords(slug):
				if ch not in seen_chapters:
					seen_chapters.append(ch)

		if str(A.SPECS.get(slug, {}).get("source_scope", "")) == "Warhammer Legends":
			legends_units.append(str(resolved.get("unit", {}).get("name", slug)))

		if "DEDICATED TRANSPORT" in upper_keywords:
			dedicated_transport_copies += copies
		elif "INFANTRY" in upper_keywords and "VEHICLE" not in upper_keywords and "MONSTER" not in upper_keywords:
			embarkable_infantry_copies += copies

		if slug in ["decimus-kill-team", "crusader-squad"]:
			warnings.append("%s retains Wahapedia runtime points (which differ from MFM v1.0)." % str(resolved.get("unit", {}).get("name", slug)))

	if warlord_eligible_count == 0:
		errors.append("Army must include at least one Warlord-eligible Character.")
	checks.append({"id": "WARLORD_ELIGIBLE_CHARACTER", "label": "Warlord-eligible Character", "ok": warlord_eligible_count > 0})

	var sc_ok := supreme_commanders.size() <= 1
	if not sc_ok:
		errors.append("Roster cannot include multiple conflicting Supreme Commanders (%s)." % ", ".join(supreme_commanders))
	checks.append({"id": "SUPREME_COMMANDER_CONFLICT", "label": "Supreme Commander uniqueness", "ok": sc_ok})

	var enh_ok := enhancement_count <= MAX_ENHANCEMENTS_PER_ARMY
	if not enh_ok:
		errors.append("An army can include at most %d Enhancements (selected %d)." % [MAX_ENHANCEMENTS_PER_ARMY, enhancement_count])
	checks.append({"id": "ENHANCEMENT_ARMY_CAP", "label": "Enhancements (%d / %d max)" % [enhancement_count, MAX_ENHANCEMENTS_PER_ARMY], "ok": enh_ok})

	var chapter_ok := seen_chapters.size() <= 1
	if not chapter_ok:
		errors.append("Space Marines army cannot include units from multiple Chapters (%s)." % ", ".join(seen_chapters))
	for det: Dictionary in detachments:
		var req_chapter := str(det.get("required_chapter", ""))
		if not req_chapter.is_empty() and not seen_chapters.is_empty() and seen_chapters[0] != req_chapter:
			chapter_ok = false
			errors.append("%s requires %s Chapter units (found %s)." % [str(det.get("name", det.get("id", ""))), CurrentMarines.chapter_name(req_chapter), CurrentMarines.chapter_name(seen_chapters[0])])
	checks.append({"id": "CHAPTER_CONFLICT", "label": "Single Chapter & detachment lock", "ok": chapter_ok})

	# 4. Support-to-Bodyguard matching
	var support_err := Supports.matching_error(entries)
	if not support_err.is_empty():
		errors.append(support_err)
	checks.append({"id": "SUPPORT_BODYGUARD_MATCH", "label": "Support & bodyguard pairs", "ok": support_err.is_empty()})

	# 5. Dedicated Transport passenger feasibility
	var transport_ok := dedicated_transport_copies <= embarkable_infantry_copies
	if not transport_ok:
		errors.append("Every Dedicated Transport requires at least one compatible embarkable Infantry unit (%d transport(s), %d Infantry unit(s))." % [dedicated_transport_copies, embarkable_infantry_copies])
	checks.append({"id": "DEDICATED_TRANSPORT_PASSENGER", "label": "Dedicated Transport passengers", "ok": transport_ok})

	# 6. Warhammer Legends gate
	var legends_ok := true
	if not legends_units.is_empty():
		if legality_mode == "matched_play":
			legends_ok = false
			errors.append("Warhammer Legends units are not permitted in Matched Play: %s." % ", ".join(legends_units))
		else:
			warnings.append("Warhammer Legends units included (Casual/Legends mode): %s." % ", ".join(legends_units))
	checks.append({"id": "LEGENDS_MODE_GATE", "label": "Legends game-mode gate", "ok": legends_ok})

	return _result(errors.is_empty(), errors, warnings, checks, report)

static func evaluate_draft(list: Variant, context: Dictionary = {}) -> Dictionary:
	var schema_err := Roster.validate(list)
	if not schema_err.is_empty():
		return _result(false, [schema_err], [], [], {})
	if str(list.get("edition", "")) != "11e":
		return _result(false, ["Full 11e legality requires an 11th-edition list."], [], [], {})
	if bool(list.get("allow_allies", false)):
		return _result(false, ["Allies are not supported in current 11e army legality."], [], [], {})
	var faction := str(list.get("faction", ""))
	if faction not in ["Space Marines", "Necrons"]:
		return _result(false, ["Army legality currently supports Space Marines and Necrons only."], [], [], {})
	var entries: Array[Dictionary] = []
	for item: Dictionary in list.get("entries", []):
		if str(item.get("faction", "")) != faction:
			return _result(false, ["Mixed factions are not supported."], [], [], {})
		var selected := {"definition_id": A.canonical_id(faction, str(item.get("unit_id", ""))), "models": int(item.get("models", 0)), "copies": int(item.get("copies", 1))}
		if str(item.get("enhancement_id", "")) != "":
			selected.enhancement_id = str(item.enhancement_id)
		if item.has("composition_choice_id"):
			selected.composition_choice_id = str(item.composition_choice_id)
		if SavedEquipment.supports(str(item.get("unit_id", ""))):
			var saved_loadouts: Array = []
			for copy_index in range(int(item.get("copies", 1))):
				saved_loadouts.append(Roster.model_equipment_loadouts(item, copy_index) if SavedEquipment.is_model_scoped(str(item.get("unit_id", ""))) else Roster.model_equipment(item, copy_index, 0))
			selected.saved_model_loadouts = saved_loadouts
		entries.append(selected)
	var selection := {"schema_version": 2, "faction": faction, "category": str(list.get("category", "incursion")), "points_limit": int(list.get("points_limit", 1000)), "entries": entries}
	return evaluate_selection(selection, context)

static func seal_formations(state: Dictionary, player: int, options: Dictionary = {}) -> Dictionary:
	var errors: Array[String] = []
	var warlord_model := int(state.get("unit_abilities", {}).get("warlords", {}).get(player, -1))
	var units: Dictionary = state.get("units", {})
	if not units.has(warlord_model) or int(units[warlord_model].get("owner", -1)) != player or "CHARACTER" not in str(units[warlord_model].get("keywords", [])).to_upper():
		errors.append("Declare a friendly faction Character as Warlord before completing setup.")
	else:
		var warlord_slug := str(units[warlord_model].get("definition_id", "")).get_slice(":", 3)
		if warlord_slug in LEGACY_CANNOT_BE_WARLORD_SLUGS or UnitAbilities.cannot_be_warlord(state, warlord_model):
			errors.append("The selected model cannot be your Warlord.")
		for unit: Dictionary in units.values():
			if int(unit.get("owner", -1)) != player:
				continue
			var u_slug := str(unit.get("definition_id", "")).get_slice(":", 3)
			if u_slug in SUPREME_COMMANDER_SLUGS and u_slug != warlord_slug:
				errors.append("%s (SUPREME COMMANDER) must be your Warlord." % str(unit.get("name", u_slug)))

	var calgar_in_army := false
	for unit: Dictionary in units.values():
		if int(unit.get("owner", -1)) == player and str(unit.get("definition_id", "")).get_slice(":", 3) == "marneus-calgar":
			calgar_in_army = true
			break
	for unit: Dictionary in units.values():
		if int(unit.get("owner", -1)) != player:
			continue
		var u_slug := str(unit.get("definition_id", "")).get_slice(":", 3)
		if Supports.is_support_identity(u_slug, calgar_in_army) and str(unit.get("attachment_role", "")) != "support":
			errors.append("Every Support must be attached to a legal bodyguard.")
			break

	# Dedicated Transport non-empty check
	if bool(options.get("require_occupied_dedicated_transports", true)):
		var transport_has_passenger: Dictionary = {}
		for unit: Dictionary in units.values():
			var embarked_in := int(unit.get("embarked_in", -1))
			if embarked_in >= 0:
				transport_has_passenger[embarked_in] = true
		for model_id: int in units:
			var unit: Dictionary = units[model_id]
			if int(unit.get("owner", -1)) != player:
				continue
			if "DEDICATED TRANSPORT" in str(unit.get("keywords", [])).to_upper() and not transport_has_passenger.has(model_id):
				errors.append("Dedicated Transport %s cannot start the battle empty." % str(unit.get("name", model_id)))

	# Reserves limits: combined <= 50% points_limit; non-Deep-Strike Strategic Reserves <= 25% points_limit
	var points_limit := int(state.get("points_limit", 1000))
	var combined_reserves_pts := 0
	var strategic_reserves_pts := 0
	var reserves_map: Dictionary = state.get("unit_abilities", {}).get("reserves", {})
	for squad_id: Variant in reserves_map:
		var squad_dict: Dictionary = state.get("squads", {}).get(int(squad_id), {})
		if int(squad_dict.get("owner", -1)) != player:
			continue
		var rec: Dictionary = reserves_map[squad_id]
		var cost := int(rec.get("cost", 0))
		combined_reserves_pts += cost
		if not bool(rec.get("deep_strike", false)) and str(rec.get("source", "")) == "strategic-reserves":
			strategic_reserves_pts += cost
	if combined_reserves_pts > points_limit / 2:
		errors.append("Combined Reserves (%d pts) exceed half of the battle points limit (%d pts)." % [combined_reserves_pts, points_limit / 2])
	if strategic_reserves_pts > points_limit / 4:
		errors.append("Strategic Reserves (%d pts) exceed 25%% of the battle points limit (%d pts)." % [strategic_reserves_pts, points_limit / 4])

	return {"ok": errors.is_empty(), "errors": errors, "warlord": warlord_model}

static func _resolve_detachments(selection_or_report: Dictionary, context: Dictionary) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var faction := str(selection_or_report.get("selection", selection_or_report).get("faction", context.get("faction", "")))
	if context.has("detachments") and context.detachments is Array:
		for item: Variant in context.detachments:
			if item is Dictionary:
				result.append(item)
			elif item is String:
				var det := DetachmentCatalog.detachment_for(faction, str(item))
				if not det.is_empty():
					result.append(det)
		return result
	var det_id := str(context.get("detachment_id", context.get("marine_detachment", "")))
	var det := DetachmentCatalog.detachment_for(faction, det_id)
	if not det.is_empty():
		result.append(det)
	return result

static func _result(valid: bool, errors: Array[String], warnings: Array[String], checks: Array[Dictionary], report: Dictionary) -> Dictionary:
	return {
		"valid": valid,
		"error": errors[0] if not errors.is_empty() else "",
		"errors": errors,
		"warnings": warnings,
		"checks": checks,
		"report": report,
	}
