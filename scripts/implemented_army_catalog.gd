extends Node
## Construction catalog from reconciled local runtime profiles; never reads API caches.
signal changed(message: String)
const Roster = preload("res://scripts/army_roster.gd")
const Capabilities = preload("res://scripts/edition_11/army_capabilities.gd")
const Current = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const StormlanceEnhancements = preload("res://scripts/edition_11/stormlance_enhancements.gd")
var cache_directory := "" # Compatibility only; no cache is loaded or written.
var edition := "11e"
var catalog: Dictionary = {}
var busy := false
var excluded: Dictionary = {}

func select_edition(value: String) -> String:
	edition = value
	catalog = {}
	excluded.clear()
	if value != "11e":
		changed.emit("Construction uses the consolidated local e11 catalog only. Older lists are preserved as drafts.")
		return "Only the local e11 construction catalog is available."
	var units: Array[Dictionary] = []
	for identity: String in Capabilities.SPECS:
		var spec: Dictionary = Capabilities.SPECS[identity]
		if not spec.get("current_reference", false):
			excluded[identity] = "Historical profile; current reconciliation is outside this catalog."
			continue
		if spec.get("validation_status", "") in ["tests_written_not_run", "local_checks_pending", "implemented_local_checks_pending"]:
			excluded[identity] = "Local validation pending."
			continue
		var profile := Current.profile(identity)
		if profile.is_empty() or profile.get("points_by_models", {}).is_empty():
			excluded[identity] = "Current profile or supported composition missing."
			continue
		var id := "40kdc:11e:%s:%s" % [spec.folder, identity]
		var resolved := Capabilities.resolve(spec.faction, id)
		if not resolved.get("error", "").is_empty():
			excluded[identity] = resolved.error
			continue
		var options: Array[Dictionary] = []
		var sizes: Array = profile.points_by_models.keys()
		sizes.sort()
		for models: int in sizes:
			var option := {"models": models, "cost": profile.points_by_models[models]}
			if profile.get("third_plus_points_by_models", {}).has(models): option.third_plus_cost = profile.third_plus_points_by_models[models]
			options.append(option)
		units.append({"id": id, "source_id": identity, "name": profile.name, "edition": "11e", "faction": spec.faction, "role": Roster.role(profile.get("keywords", [])), "source_digest": Current.digest(), "options": options, "scope": "Reconciled local runtime profile; complete army legality and final network validation remain outside this catalog."})
	units.sort_custom(func(a: Dictionary, b: Dictionary): return str(a.name).naturalnocasecmp_to(str(b.name)) < 0)
	var eligible_identities: Array[String] = []
	for unit: Dictionary in units: eligible_identities.append(str(unit.id))
	var enhancements: Array[Dictionary] = StormlanceEnhancements.catalog_records(eligible_identities)
	catalog = {"schema_version": 1, "edition": "11e", "provider": "Consolidated local runtime", "fetched_at": "local", "units": units, "enhancements": enhancements, "digest": Roster.catalog_digest(units, enhancements)}
	changed.emit("Local e11 catalog · %d available datasheets · pending and historical profiles excluded." % units.size())
	return ""

func refresh() -> void: select_edition(edition)
func cancel() -> void: pass

func contains(identity: String) -> bool:
	return not lookup(identity).is_empty()

func lookup(identity: String) -> Dictionary:
	for unit: Dictionary in catalog.get("units", []):
		if identity == str(unit.id): return unit.duplicate(true)
	return {}

func supports_size(identity: String, models: int) -> bool:
	var unit := lookup(identity)
	for option: Dictionary in unit.get("options", []):
		if int(option.models) == models: return true
	return false
