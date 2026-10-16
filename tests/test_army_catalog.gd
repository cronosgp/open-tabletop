extends SceneTree
const R = preload("res://scripts/army_roster.gd")
const F = preload("res://tests/fixtures/army_catalog_fixture.gd")
const Catalog = preload("res://scripts/army_catalog.gd")
class FakeSource extends "res://scripts/army_catalog.gd":
	var urls: Array[String] = []
	func _fetch(endpoint: String) -> void: urls.append(endpoint)
var failures := 0
func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1
func body(value: Variant) -> PackedByteArray: return JSON.stringify(value).to_utf8_buffer()
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var normalized: Dictionary = R.normalize(F.raw()[0], "11e").unit
	check(normalized.options == [{"models": 5, "cost": 80}, {"models": 10, "cost": 150}], "Use only explicit base/variant costs, never linear per-model extrapolation")
	var invalid: Dictionary = F.raw()[0].duplicate(true)
	invalid.composition = {"min_models": 10, "max_models": 5}
	invalid.points.variants = []
	check(R.normalize(invalid, "11e").unit.options == [{"models": 0, "cost": null}], "Broken composition cannot silently invent a priced size")
	invalid = F.raw()[0].duplicate(true)
	invalid.points.variants = [{"models": 5, "points": 99}]
	check(R.normalize(invalid, "11e").unit.options[0].cost == null, "Conflicting source costs remain unknown")
	check(not R.normalize({"id": "missing"}, "11e").error.is_empty(), "Reject malformed source identities")
	var source := FakeSource.new()
	source.cache_directory = "res://.tools/army-catalog-test"
	root.add_child(source)
	source.refresh()
	check(source.busy and source.urls == ["/stats"], "Refresh is explicit and starts with coverage")
	source._response(0, 200, [], body({"total_units": 3, "total_factions": 2}), source.generation)
	check(source.urls[-1] == "/units?limit=500&offset=0&sort_by=name", "Pagination begins at zero")
	var records := F.raw()
	source._response(0, 200, [], body(records.slice(0, 2)), source.generation)
	check(source.catalog.is_empty() and source.urls[-1] == "/units?limit=500&offset=2&sort_by=name", "Partial pages never replace a catalog")
	source._response(0, 200, [], body(records.slice(2)), source.generation)
	check(not source.busy and source.catalog.units.size() == 3 and R.catalog_error(source.catalog).is_empty(), "All pages validate before atomic cache commit")
	var cached := Catalog.new()
	cached.cache_directory = source.cache_directory
	root.add_child(cached)
	check(cached.select_edition("11e").is_empty() and cached.catalog.digest == source.catalog.digest, "Fresh offline instance loads the entire validated cache")
	var previous := var_to_str(source.catalog)
	var disk := FileAccess.get_file_as_string(source.cache_path())
	source.refresh()
	source._response(0, 200, [], body({"total_units": 3, "total_factions": 2}), source.generation)
	source._response(0, 200, [], body([records[0], records[0]]), source.generation)
	check(not source.busy and var_to_str(source.catalog) == previous and FileAccess.get_file_as_string(source.cache_path()) == disk, "Duplicate/unstable pages preserve the old cache and data")
	source.refresh()
	var generation: int = source.generation
	source.cancel()
	source._response(0, 200, [], body(records), generation)
	check(not source.busy and var_to_str(source.catalog) == previous, "Cancelled refresh ignores late callbacks")
	source.refresh()
	source._response(0, 503, [], body({}), source.generation)
	check(var_to_str(source.catalog) == previous, "Service errors keep offline data usable")
	var broken := source.catalog.duplicate(true)
	broken.units[0].options[0].cost = 999
	check(not R.catalog_error(broken).is_empty(), "Changed cache fails its content digest")
	print("Army catalog checks: %d failures" % failures)
	quit(0 if failures == 0 else 1)
