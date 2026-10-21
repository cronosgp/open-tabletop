extends RefCounted
## Explicit admission to partial training, never certification of official armies.
const Checked = preload("res://scripts/edition_11/roster_validation.gd")
const Capabilities = preload("res://scripts/edition_11/army_capabilities.gd")
const Pack = preload("res://scripts/data_pack.gd")
const Roster = preload("res://scripts/army_roster.gd")
const CurrentMarines = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const DIRECTORY := "res://data/imported/starter-11e-v1"
const SPECS := {
	"Space Marines": {"folder": "adeptus-astartes", "source": "intercessor-squad", "models": 5, "template": 1,
		"aliases": ["40kdc:11e:adeptus-astartes:intercessor-squad", "openhammer:11e:Space%20Marines:8da0-4570-c3c-819f"]},
	"Necrons": {"folder": "necrons", "source": "necron-warriors", "models": 10, "template": 2,
		"aliases": ["40kdc:11e:necrons:necron-warriors", "openhammer:11e:Necrons:58e9-5212-f5a6-c12d"]}}

static func definition(faction: String) -> Dictionary:
	if not SPECS.has(faction): return {"error": "Training supports only Space Marines / Intercessors and Necrons / Warriors."}
	var spec: Dictionary = SPECS[faction]
	var pack := Pack.load_pack(DIRECTORY.path_join(spec.folder))
	if not pack.error.is_empty(): return {"error": "Prepare o pacote starter fixado: " + pack.error}
	for unit: Dictionary in pack.units:
		if unit.source_id != spec.source: continue
		for price: Dictionary in unit.get("points", []):
			if price.get("models") == spec.models and not price.has("models_max") and Roster.integer(price.get("cost"), 1):
				return {"error": "", "unit": unit, "models": spec.models, "cost": int(price.cost), "pack_hash": pack.manifest.units_sha256, "template": spec.template}
	return {"error": "Training profile, size, or cost is unresolved in the local pack."}

static func inspect(list: Variant) -> Dictionary:
	var error := Roster.validate(list)
	if not error.is_empty(): return {"error": error}
	if list.edition != "11e": return {"error": "The training engine only uses the implemented 11th edition pack."}
	var resolved := definition(list.faction)
	if not resolved.error.is_empty(): return resolved
	var spec: Dictionary = SPECS[list.faction]
	var mixed := false
	var requested := 0
	for entry: Dictionary in list.entries:
		requested += int(entry.copies)
		if entry.unit_id not in spec.aliases or entry.get("enhancement_id", "") != "": mixed = true
	if mixed or requested > 2:
		var entries: Array[Dictionary] = []
		for entry: Dictionary in list.entries:
			if entry.faction != list.faction: return {"error": "Mixed factions are unsupported in core-profile training."}
			var selected := {"definition_id": resolved.unit.id if entry.unit_id in spec.aliases else entry.unit_id, "models": int(entry.models), "copies": int(entry.copies)}
			if entry.get("enhancement_id", "") != "": selected.enhancement_id = str(entry.enhancement_id)
			entries.append(selected)
		var report := Capabilities.admit({"schema_version": 2, "faction": list.faction, "entries": entries, "category": list.category, "points_limit": int(list.points_limit)})
		if report.error.is_empty(): report.saved_reference_points = Roster.summary(list).points
		return report
	var count := 0
	for entry: Dictionary in list.entries:
		if entry.unit_id not in spec.aliases or entry.faction != list.faction:
			return {"error": "Unit is not implemented in this training mode: " + entry.name}
		if entry.models != spec.models:
			return {"error": "%s: training supports %d models per unit; the list specifies %d. Composition was not changed automatically." % [resolved.unit.name, spec.models, entry.models]}
		count += int(entry.copies)
	if count not in [1, 2]: return {"error": "Choose one or two units per player for this training mode."}
	var selection := {"schema_version": 1, "faction": list.faction, "definition_id": resolved.unit.id,
		"models": resolved.models, "copies": count, "category": list.category, "points_limit": int(list.points_limit)}
	var report := admit(selection)
	if report.error.is_empty(): report.saved_reference_points = Roster.summary(list).points
	return report

static func admit(selection: Variant) -> Dictionary:
	if selection is Dictionary and selection.get("schema_version") == 2: return Capabilities.admit(selection)
	if not selection is Dictionary or selection.size() != 7: return {"error": "Invalid public army selection."}
	for key: String in ["faction", "definition_id", "category"]:
		if not selection.get(key) is String: return {"error": "Invalid selection identity."}
	if selection.get("schema_version") != 1 or not Roster.integer(selection.get("copies"), 1, 2) or not Roster.integer(selection.get("models"), 1, 1000): return {"error": "Invalid training quantity."}
	if selection.category not in Roster.LIMITS or not Roster.integer(selection.get("points_limit"), 100, 100000): return {"error": "Invalid training budget."}
	if selection.category != "custom" and selection.points_limit != Roster.LIMITS[selection.category]: return {"error": "Category and points limit do not match."}
	var resolved := definition(selection.faction)
	if not resolved.error.is_empty(): return resolved
	if selection.definition_id != resolved.unit.id or selection.models != resolved.models: return {"error": "Profile or composition is unsupported in this training mode."}
	var total: int = resolved.cost * int(selection.copies)
	if total > selection.points_limit: return {"error": "The list exceeds the training-pack budget: %d/%d." % [total, selection.points_limit]}
	# Only this minimal, canonical selection is shared; profile names, notes and prices are private.
	var canonical := {"schema_version": 1, "faction": str(selection.faction), "definition_id": str(selection.definition_id),
		"models": int(selection.models), "copies": int(selection.copies), "category": str(selection.category), "points_limit": int(selection.points_limit)}
	return {"error": "", "selection": canonical, "total": total, "unit_cost": resolved.cost, "pack_hash": resolved.pack_hash,
		"template": resolved.template, "unsupported_abilities": resolved.unit.get("unsupported_rules", []).duplicate()}

## Admission for a new match. Historical training and unreconciled profiles may
## still be inspected or used to reconstruct old saves, but cannot enter new
## construction through this boundary.
static func admit_current_catalog(list: Variant) -> Dictionary:
	var report := Capabilities.admit(list) if list is Dictionary and list.get("schema_version") == 2 and not list.has("edition") else inspect(list)
	if not report.get("error", "").is_empty(): return report
	if int(report.selection.get("schema_version", 0)) != 2:
		return {"error": "This saved list uses a historical training profile and remains a legacy draft."}
	for resolved: Dictionary in report.get("definitions", {}).values():
		if not resolved.get("spec", {}).get("current_reference", false):
			return {"error": "This saved list contains historical profiles and remains a legacy draft."}
	return report

static func digest(selection: Dictionary) -> String:
	var report := admit(selection)
	return JSON.stringify(report.selection).sha256_text() if report.error.is_empty() else ""

static func template(faction: String, category: String, limit: int) -> Dictionary:
	var resolved := definition(faction)
	if not resolved.error.is_empty(): return resolved
	var list := Roster.new_list("11e", faction, category, limit)
	list.name = "Training-compatible — " + faction
	list.pricing_source = "starter-training-v1"
	list.catalog_digest = resolved.pack_hash
	list.notes = "Partial training: fixed default weapons. Unit and faction abilities and official legality are not validated."
	for index in range(2):
		list.entries.append({"unit_id": resolved.unit.id, "name": resolved.unit.name, "edition": "11e", "faction": faction,
			"role": "Linha de batalha", "models": resolved.models, "cost": resolved.cost, "copies": 1, "source_digest": resolved.pack_hash})
	return {"error": "", "list": list}

static func reprice(list: Dictionary) -> Dictionary:
	var report := inspect(list)
	if not report.error.is_empty(): return report
	var updated := list.duplicate(true)
	updated.pricing_source = "starter-training-v1"
	updated.catalog_digest = definition(updated.faction).pack_hash if report.selection.schema_version == 2 else report.pack_hash
	for entry: Dictionary in updated.entries:
		if report.selection.schema_version == 2:
			var spec: Dictionary = SPECS[updated.faction]
			var identity: String = definition(updated.faction).unit.id if entry.unit_id in spec.aliases else Capabilities.canonical_id(updated.faction, entry.unit_id)
			var resolved: Dictionary = report.definitions[identity]
			if resolved.spec.get("current_reference", false):
				var profile := CurrentMarines.profile(identity.get_slice(":", 3))
				entry.cost = int(profile.get("points_by_models", {}).get(int(entry.models), resolved.cost))
				var tiered: Dictionary = profile.get("third_plus_points_by_models", {})
				if tiered.has(int(entry.models)): entry.third_plus_cost = int(tiered[int(entry.models)])
				else: entry.erase("third_plus_cost")
			else: entry.cost = resolved.cost
			entry.source_digest = resolved.pack_hash
		else:
			entry.cost = report.unit_cost
			entry.source_digest = report.pack_hash
	return {"error": "", "list": updated}

## Built-ins are independent copies, never inserted into a profile implicitly.
static func presets(checked: bool = false) -> Array[Dictionary]:
	var lists: Array[Dictionary] = []
	# New-match choices come only from the current local Space Marine catalog.
	# Historical starter and MFM-derived profiles remain available through their
	# explicit legacy loading paths; they are not fresh construction presets.
	var reference := Capabilities.reference_army("Space Marines")
	if reference.error.is_empty() and inspect(reference.list).error.is_empty(): lists.append(reference.list)
	return lists

static func awakened_reference() -> Dictionary:
	var list := Roster.new_list("11e", "Necrons", "training", 500)
	list.id = "preset:necrons-awakened-v1"
	list.name = "Necrons • Overlord + Warriors + Immortals"
	list.pricing_source = "starter-training-v1"
	list.notes = "Command Protocols training; enable Awakened Dynasty and declare the Overlord attachment before deployment. Other rules and full legality are pending."
	for source: String in ["overlord", "necron-warriors", "immortals"]:
		var resolved := Capabilities.resolve("Necrons", "40kdc:11e:necrons:" + source)
		if not resolved.error.is_empty(): return resolved
		list.catalog_digest = resolved.pack_hash
		list.entries.append({"unit_id": resolved.unit.id, "name": resolved.unit.name, "edition": "11e", "faction": "Necrons", "role": Roster.role(resolved.unit.keywords), "models": resolved.models, "cost": resolved.cost, "copies": 1, "source_digest": resolved.pack_hash})
	return {"error": "", "list": list}
