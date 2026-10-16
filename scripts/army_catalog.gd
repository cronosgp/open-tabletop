extends Node
## Explicit, bounded OpenHammer refresh. Cached catalogs are never match authority.
signal changed(message: String)
const Roster = preload("res://scripts/army_roster.gd")
const API := "https://openhammer-api-production.up.railway.app"
var cache_directory := "user://army-catalogs"
var edition := "11e"
var catalog: Dictionary = {}
var busy := false
var generation := 0
var request_node: HTTPRequest
var stage := ""
var expected := 0
var expected_factions := 0
var received_bytes := 0
var pending: Array[Dictionary] = []
var seen: Dictionary = {}

func cache_path() -> String: return cache_directory.path_join(edition + ".json")

func select_edition(value: String) -> String:
	if value not in Roster.EDITIONS: return "Edition unavailable."
	if busy: return "Cancel the refresh before changing the edition."
	edition = value
	catalog = {}
	if not FileAccess.file_exists(cache_path()):
		changed.emit("Refresh the catalog to load all factions and units for this edition.")
		return ""
	var loaded := Roster.read_json(cache_path(), 33554432)
	var error: String = loaded.error
	if error.is_empty(): error = Roster.catalog_error(loaded.data)
	if error.is_empty() and loaded.data.edition != edition: error = "The cache belongs to another edition."
	if not error.is_empty():
		changed.emit(error + " Refresh to get a new copy.")
		return error
	catalog = loaded.data
	changed.emit("Offline catalog loaded: %d units • %s" % [catalog.units.size(), catalog.fetched_at])
	return ""

func refresh() -> void:
	if busy: return
	busy = true
	generation += 1
	stage = "stats"
	pending = []
	seen = {}
	received_bytes = 0
	changed.emit("Fetching catalog " + edition + "…")
	_fetch("/stats")

func cancel() -> void:
	if not busy: return
	generation += 1
	_release()
	busy = false
	pending = []
	changed.emit("Refresh cancelled; previous catalog preserved.")

func _release() -> void:
	if is_instance_valid(request_node):
		request_node.cancel_request()
		request_node.queue_free()
	request_node = null

func _fetch(endpoint: String) -> void:
	request_node = HTTPRequest.new()
	request_node.timeout = 30
	request_node.body_size_limit = 16777216
	request_node.max_redirects = 0
	add_child(request_node)
	request_node.request_completed.connect(_response.bind(generation))
	var result := request_node.request(API + "/v1/" + edition + endpoint, ["Accept: application/json"])
	if result != OK: _fail("Could not start the request: " + error_string(result))

func _fail(message: String) -> void:
	_release()
	busy = false
	pending = []
	changed.emit(message + " The previous catalog was preserved.")

func _response(result: int, code: int, _headers: PackedStringArray, body: PackedByteArray, token: int) -> void:
	if not busy or token != generation: return
	_release()
	if result != HTTPRequest.RESULT_SUCCESS or code != 200:
		_fail("Connection/HTTP error %d. Try refreshing again." % code)
		return
	received_bytes += body.size()
	if received_bytes > 33554432:
		_fail("The catalog exceeds 32 MiB.")
		return
	var parsed := JSON.new()
	if parsed.parse(body.get_string_from_utf8()) != OK:
		_fail("The API returned invalid JSON.")
		return
	if stage == "stats":
		if not parsed.data is Dictionary or not Roster.integer(parsed.data.get("total_units"), 1, 10000) or not Roster.integer(parsed.data.get("total_factions"), 1, 200):
			_fail("The API did not provide catalog coverage information.")
			return
		expected = int(parsed.data.total_units)
		expected_factions = int(parsed.data.total_factions)
		stage = "units"
	else:
		if not parsed.data is Array or parsed.data.is_empty() or parsed.data.size() > 500:
			_fail("An empty or invalid unit page arrived before the catalog was complete.")
			return
		for record: Variant in parsed.data:
			var normalized := Roster.normalize(record, edition)
			if not normalized.error.is_empty():
				_fail(normalized.error)
				return
			if seen.has(normalized.unit.id):
				_fail("Pagination returned a duplicate unit; the catalog may have changed during the request.")
				return
			seen[normalized.unit.id] = true
			pending.append(normalized.unit)
		if pending.size() > expected:
			_fail("Catalog coverage changed during refresh.")
			return
	if pending.size() < expected:
		changed.emit("Loading %s: %d/%d units…" % [edition, pending.size(), expected])
		_fetch("/units?limit=500&offset=%d&sort_by=name" % pending.size())
		return
	var factions: Dictionary = {}
	for unit: Dictionary in pending: factions[unit.faction] = true
	if factions.size() != expected_factions:
		_fail("Faction counts do not match the received catalog.")
		return
	var candidate := {"schema_version": 1, "edition": edition, "provider": "OpenHammer", "url": API,
		"fetched_at": Time.get_datetime_string_from_system(true) + "Z", "units": pending.duplicate(true),
		"digest": Roster.catalog_digest(pending), "factions": factions.keys()}
	var error := Roster.catalog_error(candidate)
	if error.is_empty(): error = Roster.write_json(cache_path(), candidate, 33554432)
	if not error.is_empty():
		_fail(error)
		return
	catalog = candidate
	pending = []
	busy = false
	changed.emit("Catalog refreshed: %d factions • %d units. Available offline." % [factions.size(), catalog.units.size()])
