extends RefCounted
const DetachmentStratagems = preload("res://scripts/edition_11/detachment_stratagems.gd")
## Current fixed-loadout construction checks; never full match certification.
const Supports = preload("res://scripts/edition_11/support_attachments.gd")
const CurrentMarines = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const A = preload("res://scripts/edition_11/army_capabilities.gd")
const R = preload("res://scripts/army_roster.gd")
const Registry = preload("res://scripts/edition_11/capabilities.gd")
const ID := "incursion-fixed-rosters-mfm1.6-2026-10-25-v34-land-speeder-vengeance"
const CURRENT_SOURCE_STATUS := "wahapedia_e11_coverage_partial"
const CHECKED_MAX_SQUADS := 12
const SOURCES := {"Space Marines": {"url": "https://mfm.warhammer-community.com/en/space-marines", "version": "1.6", "sha256": "af280e710928f49d6c22775ae48fa9a5fe78de7560cf2c6712eb6d48a885c5e5"}, "Necrons": {"url": "https://mfm.warhammer-community.com/en/necrons", "version": "1.6", "sha256": "8ff758aedca89d8ea98c3912048b572b8d6ae2a5f66477a811973b91e505ee94"}}
const DETACHMENTS := {
	"Space Marines": {"id": "gladius-task-force", "name": "Gladius Task Force", "dp": 3, "force_dispositions": ["priority-assets", "take-and-hold"]},
	"Necrons": {"id": "awakened-dynasty", "name": "Awakened Dynasty", "dp": 3, "force_dispositions": ["take-and-hold", "priority-assets"]}
}
const CAPTURED_REFERENCE_POINTS := {
  "necron-warriors": {
    "cost": 85,
    "models": 10,
    "battleline": true
  },
  "immortals": {
    "cost": 65,
    "models": 5,
    "battleline": true
  },
  "overlord": {
    "cost": 90,
    "models": 1,
    "battleline": false,
    "character": true
  },
  "royal-warden": {
    "cost": 50,
    "models": 1,
    "battleline": false,
    "character": true
  }
}
static var POINTS: Dictionary = _build_points()

static func _build_points() -> Dictionary:
	var result := CAPTURED_REFERENCE_POINTS.duplicate(true)
	var profiles: Dictionary = CurrentMarines.catalog()
	for slug: String in profiles:
		var profile: Dictionary = profiles[slug]
		if not A.SPECS.get(slug, {}).get("current_reference", false) or not profile.has("points"): continue
		if result.has(slug):
			push_error("Duplicate current and captured point authority: " + slug)
			return {}
		var record := {"cost": int(profile.points), "models": int(profile.models), "sizes": profile.points_by_models.duplicate(true), "battleline": "BATTLELINE" in profile.keywords, "source": str(profile.get("points_source", "wahapedia-e11-2026-10-19"))}
		if profile.has("third_plus_points_by_models"): record.third_plus_sizes = profile.third_plus_points_by_models.duplicate(true)
		if profile.has("wargear_costs"): record.wargear_costs = profile.wargear_costs.duplicate(true)
		if profile.has("max_supported_copies"): record.max_supported_copies = int(profile.max_supported_copies)
		if "CHARACTER" in profile.keywords: record.character = true
		if slug in Supports.BODYGUARDS: record.support = true
		result[slug] = record
	return result

static func digest() -> String:
	return var_to_str({"id": ID, "points": POINTS, "support_links": Supports.BODYGUARDS, "conditional_support_links": Supports.CONDITIONAL_BODYGUARDS, "detachments": DETACHMENTS, "sources": SOURCES, "detachment_stratagems": DetachmentStratagems.ID}).sha256_text()

static func enabled(s: Dictionary) -> bool:
	return s.get("roster_validation", {}).get("implementation", "") == ID and s.roster_validation.get("digest", "") == digest()

static func dp_error(detachments: Array, allowance: int = 2) -> String:
	if detachments.is_empty(): return "Select a detachment."
	var seen: Array = []
	var total := 0
	for item: Variant in detachments:
		if not item is Dictionary or not item.get("id") is String or not R.integer(item.get("dp"), 1, 3): return "Invalid detachment."
		if item.id in seen: return "A detachment cannot be selected twice."
		seen.append(item.id)
		total += int(item.dp)
	if total > allowance and not (allowance == 2 and detachments.size() == 1 and total == 3): return "Incursion allows 2 DP, or one 3DP detachment as the only detachment."
	return ""

static func inspect(list: Variant) -> Dictionary:
	var error := R.validate(list)
	if not error.is_empty(): return {"error": error}
	if list.edition != "11e": return {"error": "Checked rosters require edition 11."}
	if list.get("allow_allies", false): return {"error": "Checked rosters do not admit allies."}
	for key in ["enhancements", "detachments", "wargear", "warlord", "attachments"]:
		if list.has(key): return {"error": "This fixed-roster profile cannot silently ignore custom " + key + ". Use the documented fixed loadouts and in-match formation declarations."}
	var entries: Array = []
	for entry: Dictionary in list.entries:
		if entry.faction != list.faction: return {"error": "Checked rosters require one faction."}
		for key in ["enhancements", "wargear", "upgrades"]:
			if entry.has(key): return {"error": "Unsupported explicit equipment/enhancement selection: " + key}
		entries.append({"definition_id": A.canonical_id(list.faction, entry.unit_id), "models": entry.models, "copies": entry.copies})
	var report := admit({"schema_version": 2, "faction": list.faction, "category": list.category, "points_limit": list.points_limit, "entries": entries})
	if report.error.is_empty(): report.saved_reference_points = R.summary(list).points
	return report

static func admit(selection: Variant) -> Dictionary:
	if not selection is Dictionary or selection.size() != 5 or selection.get("schema_version") != 2: return {"error": "Checked rosters require canonical mixed-list selections."}
	if selection.get("category") != "incursion" or not R.integer(selection.get("points_limit"), 1000, 1000): return {"error": "Checked rosters currently support 1000-point Incursion only."}
	if selection.get("faction") not in DETACHMENTS: return {"error": "Checked rosters support Space Marines and Necrons only."}
	# Validate and canonicalize known fixed profiles without using historical prices.
	var unpriced: Dictionary = selection.duplicate(true)
	unpriced.category = "custom"
	unpriced.points_limit = 100000
	var report := A.admit(unpriced, CHECKED_MAX_SQUADS)
	if not report.error.is_empty(): return report
	report.selection.category = "incursion"
	report.selection.points_limit = 1000
	var total := 0
	var characters := 0
	var breakdown: Array = []
	var sheet_counts: Dictionary = {}
	for entry: Dictionary in report.selection.entries:
		var slug: String = entry.definition_id.get_slice(":", 3)
		if not POINTS.has(slug): return {"error": "No captured MFM 1.6 reference price for " + slug}
		var price: Dictionary = POINTS[slug]
		var sizes: Dictionary = price.get("sizes", {int(price.models): int(price.cost)})
		if not sizes.has(entry.models): return {"error": "Unsupported current composition: " + slug}
		sheet_counts[slug] = int(sheet_counts.get(slug, 0)) + int(entry.copies)
		if sheet_counts[slug] > (4 if price.battleline else 2): return {"error": "Incursion repetition limit exceeded: " + slug + " (2 per datasheet; 4 Battleline)."}
		var unit_cost: int = sizes[entry.models]
		var subtotal: int = unit_cost * entry.copies
		total += subtotal
		if price.get("character", false): characters += int(entry.copies)
		report.definitions[entry.definition_id].cost = unit_cost
		var configuration_key := "%s:%02d:%s" % [entry.definition_id, int(entry.models), str(entry.get("enhancement_id", ""))]
		if not report.configurations.has(configuration_key): return {"error": "Resolved roster configuration is missing: " + configuration_key}
		report.configurations[configuration_key].cost = unit_cost
		breakdown.append({"definition_id": entry.definition_id, "models": entry.models, "copies": entry.copies, "unit_cost": unit_cost, "points_source": price.get("source", "official-mfm-1.6-observed-2026-10-17"), "total": subtotal, "wargear_cost": 0})
	if characters == 0: return {"error": "A current roster requires a faction Character as Warlord."}
	var attachment_error := Supports.matching_error(report.selection.entries)
	if not attachment_error.is_empty(): return {"error": attachment_error}
	if total > 1000: return {"error": "The list exceeds the captured MFM 1.6 Incursion reference: %d/1000." % total}
	var detachments: Array = [DETACHMENTS[selection.faction].duplicate(true)]
	var error := dp_error(detachments)
	if not error.is_empty(): return {"error": error}
	report.total = total
	report.warnings = []
	report.construction = {"points_verified": true, "points_snapshot": "Reference prices: original MFM 1.6 (observed 2026-10-17) plus Wahapedia e11 additions (2026-10-18); see per-entry points_source", "source_status": CURRENT_SOURCE_STATUS, "total": total, "points_limit": 1000, "breakdown": breakdown, "detachments": detachments, "dp_allowance": 2, "single_3dp_exception": true, "enhancements": [], "fixed_wargear": true, "formations_verified": false, "full_match_certified": false}
	return report

static func enable(s: Dictionary, reports: Dictionary) -> void:
	var armies := {}
	for player in [1, 2]: armies[player] = reports[player].construction.duplicate(true)
	s.roster_validation = {"implementation": ID, "digest": digest(), "sources": SOURCES.duplicate(true), "source_status": CURRENT_SOURCE_STATUS, "armies": armies, "full_match_certified": false}
	s.roster_points_validated = true
	DetachmentStratagems.enable(s)
	Registry.admit(s, "checked-incursion-rosters", ID)

static func seal(s: Dictionary, player: int) -> String:
	if not enabled(s): return ""
	var model: int = s.unit_abilities.get("warlords", {}).get(player, -1)
	if not s.units.has(model) or s.units[model].owner != player or "CHARACTER" not in str(s.units[model].keywords).to_upper(): return "Declare a friendly faction Character as Warlord before completing the checked roster."
	var calgar_in_army := false
	for unit: Dictionary in s.units.values():
		if unit.owner == player and str(unit.get("definition_id", "")).get_slice(":", 3) == "marneus-calgar": calgar_in_army = true
	for unit: Dictionary in s.units.values():
		if unit.owner == player and Supports.is_support_identity(str(unit.get("definition_id", "")).get_slice(":", 3), calgar_in_army) and unit.get("attachment_role", "") != "support": return "Every Support must be attached to a legal bodyguard."
	s.roster_validation.armies[player].formations_verified = true
	s.roster_validation.armies[player].warlord = model
	return ""

static func summary(s: Dictionary) -> String:
	if not enabled(s): return ""
	var parts: Array[String] = []
	for player in [1, 2]:
		var army: Dictionary = s.roster_validation.armies[player]
		parts.append("P%d %d/1000 pts | %s, 3DP exception | formations %s" % [player, army.total, army.detachments[0].name, "checked" if army.formations_verified else "pending"])
	return "MFM 1.6 legacy price snapshot\n" + "\n".join(parts) + "\nWahapedia e11 is the rules source; supported datasheets are partial and full army legality is not certified."

static func preset(faction: String) -> Dictionary:
	if faction not in DETACHMENTS: return {"error": "Unsupported checked faction."}
	var list := R.new_list("11e", faction, "incursion", 1000)
	list.id = "preset:checked-mfm16:" + faction
	list.name = "MFM 1.6 starter (290 pts) - " + faction
	list.pricing_source = ID
	list.catalog_digest = digest()
	list.notes = "Current fixed-loadout construction profile, Incursion 1000-point limit. No enhancements. Gladius/Awakened only. Choose Warlord and Support attachments before deployment. Other rules remain incomplete."
	for slug: String in (["captain", "intercessor-squad", "heavy-intercessor-squad"] if faction == "Space Marines" else ["overlord", "necron-warriors", "immortals", "royal-warden"]):
		var folder := "adeptus-astartes" if faction == "Space Marines" else "necrons"
		var resolved := A.resolve(faction, "40kdc:11e:%s:%s" % [folder, slug])
		if not resolved.error.is_empty(): return resolved
		list.entries.append({"unit_id": resolved.unit.id, "name": resolved.unit.name, "edition": "11e", "faction": faction, "role": R.role(resolved.unit.keywords), "models": POINTS[slug].models, "cost": POINTS[slug].cost, "copies": 1, "source_digest": digest()})
	return {"error": "", "list": list}

static func marine_incursion_list() -> Dictionary:
	var list := R.new_list("11e", "Space Marines", "incursion", 1000)
	list.id = "preset:checked-mfm16-1000:Space Marines"
	list.name = "MFM 1.6 Incursion 930 pts - Space Marines"
	list.pricing_source = ID
	list.catalog_digest = digest()
	list.notes = "Checked Gladius Incursion list using admitted fixed loadouts: Captain Warlord, four Heavy Intercessor Squads and two Terminator Squads (930/1000). Lieutenant is omitted because Support currently requires an Intercessor/Assault bodyguard. Pair with the 880-point Awakened list under the same 1,000-point ceiling."
	var composition := {"captain": 1, "heavy-intercessor-squad": 4, "terminator-squad": 2}
	for slug: String in composition:
		var resolved := A.resolve("Space Marines", "40kdc:11e:adeptus-astartes:" + slug)
		if not resolved.error.is_empty(): return resolved
		list.entries.append({"unit_id": resolved.unit.id, "name": resolved.unit.name, "edition": "11e", "faction": "Space Marines", "role": R.role(resolved.unit.keywords), "models": POINTS[slug].models, "cost": POINTS[slug].cost, "copies": int(composition[slug]), "source_digest": digest()})
	return {"error": "", "list": list}

static func necron_incursion_list() -> Dictionary:
	var list := R.new_list("11e", "Necrons", "incursion", 1000)
	list.id = "preset:checked-mfm16-1000:Necrons"
	list.name = "MFM 1.6 Incursion 880 pts - Necrons"
	list.pricing_source = ID
	list.catalog_digest = digest()
	list.notes = "Checked Awakened Incursion list using admitted fixed loadouts: two Overlords, two Royal Wardens, four Warrior squads and four Immortal squads (880/1000). This is the current datasheet repetition ceiling; 1,000 points still needs more admitted Necron types."
	var composition := {"overlord": 2, "royal-warden": 2, "necron-warriors": 4, "immortals": 4}
	for slug: String in composition:
		var resolved := A.resolve("Necrons", "40kdc:11e:necrons:" + slug)
		if not resolved.error.is_empty(): return resolved
		list.entries.append({"unit_id": resolved.unit.id, "name": resolved.unit.name, "edition": "11e", "faction": "Necrons", "role": R.role(resolved.unit.keywords), "models": POINTS[slug].models, "cost": POINTS[slug].cost, "copies": int(composition[slug]), "source_digest": digest()})
	return {"error": "", "list": list}

static func defaults() -> Dictionary:
	return {1: inspect(preset("Space Marines").list).selection, 2: inspect(preset("Necrons").list).selection}

static func selection_digest(selection: Dictionary) -> String:
	var report := admit(selection)
	return (JSON.stringify(report.selection) + digest()).sha256_text() if report.error.is_empty() else ""
