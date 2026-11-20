extends RefCounted
## Authoritative catalog of implemented Space Marine and Necron detachments, DP costs, and Force Dispositions.
## Values transcribed from verified local Wahapedia 11e Detachments.csv (sha256 d323c5cc7e025ba8c3c004805fedf1adfbf0126305a770e448287d6280b4c536).

const ChapterRules = preload("res://scripts/edition_11/chapter_rules.gd")

const SOURCE_FILE := "Detachments.csv"
const SOURCE_SHA256 := "d323c5cc7e025ba8c3c004805fedf1adfbf0126305a770e448287d6280b4c536"

const DP_ALLOWANCE := {
	"training": 2,
	"incursion": 2,
	"strike_force": 4,
	"onslaught": 6,
	"custom": 6,
}

const MARINE_DETACHMENTS := {
	"gladius": {"id": "gladius", "alias": "gladius-task-force", "source_id": "000000750", "name": "Gladius Task Force", "dp": 3, "force_dispositions": ["priority-assets", "take-and-hold"]},
	"gladius-task-force": {"id": "gladius", "alias": "gladius-task-force", "source_id": "000000750", "name": "Gladius Task Force", "dp": 3, "force_dispositions": ["priority-assets", "take-and-hold"]},
	"ironstorm-spearhead": {"id": "ironstorm-spearhead", "source_id": "000000794", "name": "Ironstorm Spearhead", "dp": 1, "force_dispositions": ["purge-the-foe"]},
	"stormlance": {"id": "stormlance", "alias": "stormlance-task-force", "source_id": "000000796", "name": "Stormlance Task Force", "dp": 1, "force_dispositions": ["reconnaissance"]},
	"inner-circle-task-force": {"id": "inner-circle-task-force", "source_id": "000000835", "name": "Inner Circle Task Force", "dp": 1, "force_dispositions": ["priority-assets"]},
	"wrath-of-the-rock": {"id": "wrath-of-the-rock", "source_id": "000001059", "name": "Wrath of the Rock", "dp": 2, "force_dispositions": ["take-and-hold"]},
	"spearpoint-task-force": {"id": "spearpoint-task-force", "source_id": "000001119", "name": "Spearpoint Task Force", "dp": 2, "force_dispositions": ["reconnaissance"]},
	"blade-of-ultramar": {"id": "blade-of-ultramar", "source_id": "000001120", "name": "Blade of Ultramar", "dp": 3, "force_dispositions": ["priority-assets", "take-and-hold"]},
	"darkflight-pursuit": {"id": "darkflight-pursuit", "source_id": "000001205", "name": "Darkflight Pursuit", "dp": 1, "force_dispositions": ["reconnaissance"]},
	"vow-sworn-crusaders": {"id": "vow-sworn-crusaders", "source_id": "000001230", "name": "Vow-sworn Crusaders", "dp": 2, "force_dispositions": ["purge-the-foe"]},
	"fist-of-the-god-emperor": {"id": "fist-of-the-god-emperor", "source_id": "000001231", "name": "Fist of the God-Emperor", "dp": 1, "force_dispositions": ["take-and-hold"]},
	"medusa-wrath": {"id": "medusa-wrath", "source_id": "000001232", "name": "Medusa's Wrath", "dp": 2, "force_dispositions": ["purge-the-foe"]},
	"gauntlet-task-force": {"id": "gauntlet-task-force", "source_id": "000001233", "name": "Gauntlet Task Force", "dp": 1, "force_dispositions": ["reconnaissance"]},
	"phobos-shadow-force": {"id": "phobos-shadow-force", "source_id": "000001234", "name": "Phobos Shadow Force", "dp": 1, "force_dispositions": ["disruption"]},
	"tacticus-attack-force": {"id": "tacticus-attack-force", "source_id": "000001235", "name": "Tacticus Attack Force", "dp": 1, "force_dispositions": ["take-and-hold"]},
	"phobos-shock-force": {"id": "phobos-shock-force", "source_id": "000001236", "name": "Phobos Shock Force", "dp": 1, "force_dispositions": ["disruption"]},
	"terminator-storm-force": {"id": "terminator-storm-force", "source_id": "000001237", "name": "Terminator Storm Force", "dp": 1, "force_dispositions": ["priority-assets"]},
	"assault-brethren": {"id": "assault-brethren", "source_id": "000001238", "name": "Assault Brethren", "dp": 1, "force_dispositions": ["take-and-hold"]},
	"gravis-linebreaker-force": {"id": "gravis-linebreaker-force", "source_id": "000001239", "name": "Gravis Linebreaker Force", "dp": 1, "force_dispositions": ["take-and-hold"]},
	"devastator-brethren": {"id": "devastator-brethren", "source_id": "000001240", "name": "Devastator Brethren", "dp": 1, "force_dispositions": ["purge-the-foe"]},
	"gravis-siege-force": {"id": "gravis-siege-force", "source_id": "000001241", "name": "Gravis Siege Force", "dp": 1, "force_dispositions": ["take-and-hold"]},
	"tactical-brethren": {"id": "tactical-brethren", "source_id": "000001242", "name": "Tactical Brethren", "dp": 1, "force_dispositions": ["priority-assets"]},
	"ironclad-champions": {"id": "ironclad-champions", "source_id": "000001243", "name": "Ironclad Champions", "dp": 1, "force_dispositions": ["priority-assets"]},
	"tacticus-firestorm-force": {"id": "tacticus-firestorm-force", "source_id": "000001244", "name": "Tacticus Firestorm Force", "dp": 1, "force_dispositions": ["priority-assets"]},
}

const NECRON_DETACHMENTS := {
	"awakened-dynasty": {"id": "awakened-dynasty", "source_id": "000000756", "name": "Awakened Dynasty", "dp": 3, "force_dispositions": ["take-and-hold", "priority-assets"]},
}

static func dp_allowance(category: String) -> int:
	return int(DP_ALLOWANCE.get(category, 2))

static func detachment_for(faction: String, selected_id: String = "") -> Dictionary:
	var key := selected_id.strip_edges().to_lower()
	if faction == "Space Marines":
		if key in ["", "none"]:
			key = "gladius"
		var record: Dictionary = MARINE_DETACHMENTS.get(key, {})
		if record.is_empty():
			return {}
		var result := record.duplicate(true)
		var required_chapter := ChapterRules.required_chapter_for_detachment(str(result.id))
		if not required_chapter.is_empty():
			result.required_chapter = required_chapter
		return result
	if faction == "Necrons":
		if key in ["", "none"]:
			key = "awakened-dynasty"
		return NECRON_DETACHMENTS.get(key, {}).duplicate(true)
	return {}

static func all_for_faction(faction: String) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var seen: Dictionary = {}
	var table: Dictionary = MARINE_DETACHMENTS if faction == "Space Marines" else (NECRON_DETACHMENTS if faction == "Necrons" else {})
	for key: String in table:
		var record: Dictionary = table[key]
		var canonical_id := str(record.get("id", key))
		if seen.has(canonical_id):
			continue
		seen[canonical_id] = true
		result.append(detachment_for(faction, canonical_id))
	return result

static func dp_error(detachments: Array, category: String = "incursion") -> String:
	if detachments.is_empty():
		return "Select a detachment."
	var allowance := dp_allowance(category)
	var seen: Dictionary = {}
	var total := 0
	for item: Variant in detachments:
		if not item is Dictionary or not item.get("id") is String:
			return "Invalid detachment."
		var dp_val: Variant = item.get("dp")
		if not (dp_val is int or (dp_val is float and dp_val == floor(dp_val))) or int(dp_val) < 1 or int(dp_val) > 3:
			return "Invalid detachment DP cost."
		var det_id := str(item.id)
		if seen.has(det_id):
			return "A detachment cannot be selected twice."
		seen[det_id] = true
		total += int(dp_val)
	if total > allowance and not (category == "incursion" and detachments.size() == 1 and total == 3):
		if category == "incursion":
			return "Incursion allows 2 DP, or one 3 DP detachment as the only detachment."
		return "%s allows at most %d DP (selected %d DP)." % [category.replace("_", " ").capitalize(), allowance, total]
	return ""
