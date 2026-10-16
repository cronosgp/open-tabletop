extends RefCounted
const R = preload("res://scripts/army_roster.gd")
static func raw() -> Array:
	return [
		{"id": "line", "name": "Test Line", "faction": "Space Marines", "composition": {"min_models": 5, "max_models": 10}, "points": {"base": 80, "variants": [{"models": 10, "points": 150}]}, "keywords": ["Battleline"]},
		{"id": "leader", "name": "Test Leader", "faction": "Space Marines", "composition": {"min_models": 1, "max_models": 1}, "points": {"base": 90}, "keywords": ["Character"]},
		{"id": "other", "name": "Test Other", "faction": "Necrons", "composition": {"min_models": 10, "max_models": 20}, "points": {"base": 100}, "keywords": ["Battleline"]}
	]
static func catalog() -> Dictionary:
	var units: Array[Dictionary] = []
	for record: Dictionary in raw(): units.append(R.normalize(record, "11e").unit)
	return {"schema_version": 1, "edition": "11e", "fetched_at": "fixture", "digest": R.catalog_digest(units), "units": units}
