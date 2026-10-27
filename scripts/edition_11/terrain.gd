extends RefCounted
## Terrain movement proxies and bounded cylindrical visibility proxies.
const Board = preload("res://scripts/rules.gd")
const Smoke = preload("res://scripts/edition_11/smokescreen.gd")
const Detection = preload("res://scripts/edition_11/detection_rules.gd")
const EPSILON := 0.001
const SIGHT_RADIUS := 0.5 / 25.4 # Half of the required 1mm sightline width.
const DEFAULT_LAYOUT := "terrain-11e-v1"
const MULTI_STOREY_PRACTICE_LAYOUT := "terrain-11e-multi-storey-practice-v1"
const TAKE_AND_HOLD_LAYOUTS := {
	"ca-2026-27-take-and-hold-mirror-a-v1": {"label": "Layout A", "image": "43_Take_and_Hold_vs_Take_and_Hold_Layout_A.png"},
	"ca-2026-27-take-and-hold-mirror-b-v1": {"label": "Layout B", "image": "44_Take_and_Hold_vs_Take_and_Hold_Layout_B.png"},
	"ca-2026-27-take-and-hold-mirror-c-v1": {"label": "Layout C", "image": "45_Take_and_Hold_vs_Take_and_Hold_Layout_C.png"}
}

static func event_layout_options() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for id: String in TAKE_AND_HOLD_LAYOUTS:
		var item: Dictionary = TAKE_AND_HOLD_LAYOUTS[id].duplicate(true)
		item.id = id
		result.append(item)
	return result

static func is_event_layout(id: String) -> bool:
	return TAKE_AND_HOLD_LAYOUTS.has(id)

static func event_layout_image_path(id: String) -> String:
	if not TAKE_AND_HOLD_LAYOUTS.has(id): return ""
	return ".tools/wahapedia/11e/event-layouts/take-and-hold-mirror/" + str(TAKE_AND_HOLD_LAYOUTS[id].image)

static func layout(id: String = DEFAULT_LAYOUT) -> Dictionary:
	if is_event_layout(id): return _event_companion_layout(id)
	if id == MULTI_STOREY_PRACTICE_LAYOUT: return _multi_storey_practice_layout()
	if id == "legacy-solid-v1":
		var areas: Array[Dictionary] = []
		for index in range(Board.TERRAIN.size()):
			var bounds: Rect2 = Board.TERRAIN[index]
			areas.append({"name": "Legacy obstacle", "category": "legacy", "bounds": bounds, "features": [{"bounds": bounds, "height": 1.5, "blocks_end": true}]})
		return {"id": id, "areas": areas}
	if id != DEFAULT_LAYOUT: return {"error": "Unknown terrain layout: " + id}
	return {"id": id, "areas": [
		{"name": "Central ruin", "category": "dense", "bounds": Rect2(-3, -2, 6, 4), "features": [
			{"bounds": Rect2(-3, -2, 6, 0.25), "height": 4.0, "blocks_end": true},
			{"bounds": Rect2(-3, -2, 0.25, 4), "height": 4.0, "blocks_end": true}], "surfaces": [{
			"id": "central-ruin-first-floor", "name": "Central ruin · first floor", "bounds": Rect2(-2.75, -1.75, 5.5, 3.5), "elevation": 3.0,
			"access_features": [0, 1], "requires_keywords": ["infantry", "beasts", "swarm", "fly"]}]},
		{"name": "Rubble", "category": "exposed", "bounds": Rect2(-11, 3, 4, 2), "features": [
			{"bounds": Rect2(-10, 3.8, 2, 0.25), "height": 0.2, "blocks_end": false}]},
		{"name": "Barricade", "category": "light", "bounds": Rect2(7, -5, 4, 2), "features": [
			{"bounds": Rect2(7, -4.1, 4, 0.2), "height": 1.0, "blocks_end": true}]}
	]}

static func _multi_storey_practice_layout() -> Dictionary:
	var profile: Dictionary = layout(DEFAULT_LAYOUT)
	if profile.has("error"): return profile
	var areas: Array = profile.get("areas", []).duplicate(true)
	if areas.is_empty(): return {"error": "The multi-storey practice layout requires the central ruin."}
	var central_ruin: Dictionary = areas[0]
	var features: Array = central_ruin.get("features", []).duplicate(true)
	for index in range(features.size()):
		if features[index] is Dictionary: features[index]["height"] = 6.0
	central_ruin["features"] = features
	var surfaces: Array = central_ruin.get("surfaces", []).duplicate(true)
	surfaces.append({
		"id": "central-ruin-second-floor",
		"name": "Central ruin · second floor",
		"bounds": Rect2(-2.25, -1.25, 4.5, 2.5),
		"elevation": 6.0,
		"access_features": [0, 1],
		"requires_keywords": ["infantry", "beasts", "swarm", "fly"]
	})
	central_ruin["surfaces"] = surfaces
	areas[0] = central_ruin
	profile["areas"] = areas
	profile["id"] = MULTI_STOREY_PRACTICE_LAYOUT
	return profile

static func _event_companion_layout(id: String) -> Dictionary:
	var areas: Array[Dictionary] = []
	match id:
		"ca-2026-27-take-and-hold-mirror-a-v1":
			areas = [
				_proxy_area("Northwest ruin", "dense", Rect2(-29, 16, 7, 5), [Rect2(-29, 16, 5, 0.35), Rect2(-29, 16, 0.35, 4)]),
				_proxy_area("Southwest ruin", "dense", Rect2(-29, -21, 7, 5), [Rect2(-29, -16.35, 5, 0.35), Rect2(-22.35, -20, 0.35, 4)]),
				_proxy_area("Northeast ruin", "dense", Rect2(22, 16, 7, 5), [Rect2(24, 16, 5, 0.35), Rect2(28.65, 16, 0.35, 4)]),
				_proxy_area("Southeast ruin", "dense", Rect2(22, -21, 7, 5), [Rect2(24, -16.35, 5, 0.35), Rect2(22, -20, 0.35, 4)]),
				_proxy_area("Northwest barricade", "light", Rect2(-29, -4, 6, 2), [Rect2(-29, -3.1, 6, 0.2)]),
				_proxy_area("Southeast barricade", "light", Rect2(23, 2, 6, 2), [Rect2(23, 2.9, 6, 0.2)])]
		"ca-2026-27-take-and-hold-mirror-b-v1":
			areas = [
				_proxy_area("Northwest ruin", "dense", Rect2(-29, 16, 7, 5), [Rect2(-24.35, 16, 0.35, 4), Rect2(-29, 20.65, 5, 0.35)]),
				_proxy_area("Southwest ruin", "dense", Rect2(-29, -21, 7, 5), [Rect2(-29, -20.65, 5, 0.35), Rect2(-22.35, -20, 0.35, 4)]),
				_proxy_area("Northeast ruin", "dense", Rect2(22, 16, 7, 5), [Rect2(22, 16, 5, 0.35), Rect2(26.65, 16, 0.35, 4)]),
				_proxy_area("Southeast ruin", "dense", Rect2(22, -21, 7, 5), [Rect2(28.65, -20, 0.35, 4), Rect2(24, -16.35, 5, 0.35)]),
				_proxy_area("West barricade", "light", Rect2(-29, -3, 6, 2), [Rect2(-29, -2.1, 6, 0.2)]),
				_proxy_area("East barricade", "light", Rect2(23, 5, 6, 2), [Rect2(23, 5.9, 6, 0.2)])]
		"ca-2026-27-take-and-hold-mirror-c-v1":
			areas = [
				_proxy_area("Northwest ruin", "dense", Rect2(-29, 16, 7, 5), [Rect2(-29, 16, 0.35, 4), Rect2(-28.65, 20.65, 5, 0.35)]),
				_proxy_area("Southwest ruin", "dense", Rect2(-29, -21, 7, 5), [Rect2(-29, -20.65, 5, 0.35), Rect2(-22.35, -20, 0.35, 4)]),
				_proxy_area("Northeast ruin", "dense", Rect2(22, 16, 7, 5), [Rect2(28.65, 16, 0.35, 4), Rect2(22, 16, 5, 0.35)]),
				_proxy_area("Southeast ruin", "dense", Rect2(22, -21, 7, 5), [Rect2(22, -20, 0.35, 4), Rect2(24, -16.35, 5, 0.35)]),
				_proxy_area("Northwest barricade", "light", Rect2(-29, -3, 6, 2), [Rect2(-29, -2.1, 6, 0.2)]),
				_proxy_area("Northeast barricade", "light", Rect2(23, -3, 6, 2), [Rect2(23, -2.1, 6, 0.2)])]
	return {"id": id, "areas": areas}

static func _proxy_area(area_name: String, category: String, bounds: Rect2, walls: Array[Rect2]) -> Dictionary:
	var features: Array[Dictionary] = []
	var height := 4.0 if category == "dense" else 1.0
	for wall: Rect2 in walls:
		features.append({"bounds": wall, "height": height, "blocks_end": true})
	var area := {"name": area_name, "category": category, "bounds": bounds, "features": features}
	if category == "dense" and not features.is_empty():
		var access_features: Array[int] = []
		for feature_index in range(features.size()): access_features.append(feature_index)
		var surface_id := "event-%s-first-floor" % area_name.to_lower().replace(" ", "-")
		area["surfaces"] = [{
			"id": surface_id,
			"name": "%s · first floor" % area_name,
			"bounds": bounds.grow(-0.35),
			"elevation": 3.0,
			"access_features": access_features,
			"requires_keywords": ["infantry", "beasts", "swarm", "fly"]
		}]
	return area

static func areas(state: Dictionary) -> Array:
	if state.has("terrain"): return state.terrain.areas
	return layout("legacy-solid-v1").areas

static func surfaces(state: Dictionary) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var terrain_areas := areas(state)
	for area_index in range(terrain_areas.size()):
		var area: Dictionary = terrain_areas[area_index]
		for value: Variant in area.get("surfaces", []):
			if not value is Dictionary: continue
			var surface: Dictionary = value.duplicate(true)
			surface["area_index"] = area_index
			surface["area_category"] = str(area.get("category", ""))
			result.append(surface)
	return result

static func can_end_on_surface(model: Dictionary, surface: Dictionary) -> bool:
	var allowed: Array = surface.get("requires_keywords", [])
	for keyword: Variant in allowed:
		if has_keyword(model, [str(keyword)]): return true
	return false

static func surface_contains(model: Dictionary, surface: Dictionary, position: Vector2) -> bool:
	var bounds: Rect2 = surface.get("bounds", Rect2())
	var radius := maxf(0.0, float(model.get("radius", 0.0)))
	var inner := Rect2(bounds.position + Vector2.ONE * radius, bounds.size - Vector2.ONE * radius * 2.0)
	return inner.size.x >= 0.0 and inner.size.y >= 0.0 \
		and position.x >= inner.position.x - EPSILON and position.x <= inner.end.x + EPSILON \
		and position.y >= inner.position.y - EPSILON and position.y <= inner.end.y + EPSILON

static func surface_at(state: Dictionary, model: Dictionary, position: Vector2, elevation: float) -> Dictionary:
	if absf(elevation) <= EPSILON: return {"id": "ground", "name": "Ground level", "elevation": 0.0}
	for surface: Dictionary in surfaces(state):
		if absf(float(surface.get("elevation", 0.0)) - elevation) <= EPSILON and can_end_on_surface(model, surface) and surface_contains(model, surface, position): return surface
	return {}

static func movement_surface_options(state: Dictionary, model: Dictionary) -> Array[Dictionary]:
	var options: Array[Dictionary] = [{"id": "ground", "name": "Ground level", "elevation": 0.0}]
	var surfaces_by_height: Dictionary = {}
	var surface_counts: Dictionary = {}
	for surface: Dictionary in surfaces(state):
		if not can_end_on_surface(model, surface): continue
		var elevation := float(surface.elevation)
		var height_key := roundi(elevation * 1000.0)
		surface_counts[height_key] = int(surface_counts.get(height_key, 0)) + 1
		if not surfaces_by_height.has(height_key): surfaces_by_height[height_key] = surface
	var height_keys: Array = surfaces_by_height.keys()
	height_keys.sort()
	for height_key: int in height_keys:
		var surface: Dictionary = surfaces_by_height[height_key]
		var elevation := float(surface.elevation)
		var name := str(surface.name)
		if int(surface_counts[height_key]) > 1: name = "First floor" if absf(elevation - 3.0) <= EPSILON else "Supported surface"
		options.append({"id": surface.id, "name": name, "elevation": elevation})
	return options

static func movement_distance(start: Vector2, start_elevation: float, destination: Vector2, destination_elevation: float, ignores_vertical: bool = false) -> float:
	var vertical := 0.0 if ignores_vertical else absf(destination_elevation - start_elevation)
	return start.distance_to(destination) + vertical

static func legacy(state: Dictionary) -> bool:
	return state.get("terrain", {}).get("id", "legacy-solid-v1") == "legacy-solid-v1"

static func has_keyword(model: Dictionary, keywords: Array[String]) -> bool:
	for keyword: String in model.get("keywords", []):
		if keyword.to_lower() in keywords: return true
	return false

static func squad_has_keyword(state: Dictionary, squad: int, keyword: String) -> bool:
	var members := _alive(state, squad)
	if members.is_empty(): return false
	for member: int in members:
		if has_keyword(state.units[member], [keyword.to_lower()]): return true
	return has_keyword(state.get("squads", {}).get(squad, {}), [keyword.to_lower()])

static func squad_can_fly(state: Dictionary, squad: int) -> bool:
	return squad_has_keyword(state, squad, "fly")

static func squad_has_hover(state: Dictionary, squad: int) -> bool:
	var squad_record: Dictionary = state.get("squads", {}).get(squad, {})
	if _record_has_hover(squad_record): return true
	for member: int in _alive(state, squad):
		if _record_has_hover(state.units[member]): return true
	return false

static func take_to_skies_penalty(state: Dictionary, squad: int, declared: bool) -> float:
	return 2.0 if declared and not squad_has_hover(state, squad) else 0.0

static func _record_has_hover(record: Dictionary) -> bool:
	if has_keyword(record, ["hover"]): return true
	if bool(record.get("hover", false)): return true
	for field in ["abilities", "core_abilities", "rules", "special_rules"]:
		var values: Variant = record.get(field, [])
		if values is String and values.strip_edges().to_lower() == "hover": return true
		if values is Dictionary:
			if values.has("hover") and bool(values.hover): return true
			for key: Variant in values:
				if str(key).strip_edges().to_lower() == "hover": return true
				var value: Variant = values[key]
				if value is Dictionary and str(value.get("id", value.get("name", value.get("title", "")))).strip_edges().to_lower() == "hover": return true
		if values is Array:
			for value: Variant in values:
				if value is String and value.strip_edges().to_lower() == "hover": return true
				if value is Dictionary and str(value.get("id", value.get("name", value.get("title", "")))).strip_edges().to_lower() == "hover": return true
	return false

static func take_to_skies_active(state: Dictionary, model_id: int) -> bool:
	if not state.get("units", {}).has(model_id): return false
	var model: Dictionary = state.units[model_id]
	if not has_keyword(model, ["fly"]): return false
	var squad := int(model.get("squad", -2))
	var pending_move: Dictionary = state.get("pending_move", {})
	if int(pending_move.get("squad", -1)) == squad and bool(pending_move.get("take_to_skies", false)): return true
	var pending_contact: Dictionary = state.get("pending_contact", {})
	return str(pending_contact.get("kind", "")) == "charge" and int(pending_contact.get("squad", -1)) == squad and bool(pending_contact.get("take_to_skies", false))

static func ignores_vertical_movement(state: Dictionary, model_id: int) -> bool:
	if not state.get("units", {}).has(model_id): return false
	var model: Dictionary = state.units[model_id]
	if take_to_skies_active(state, model_id): return true
	var squad := int(model.get("squad", -1))
	return bool(state.get("squads", {}).get(squad, {}).get("reiver_grapnel_launchers", false))

static func mobile_unit(state: Dictionary, model: int) -> bool:
	if has_keyword(state.units[model], ["mobile"]): return true
	var squad: int = state.units[model].squad
	var mobile: Dictionary = state.get("detachment_stratagems", {}).get("mobile", {}).get(squad, {})
	if mobile.get("phase_key", "") == "%d:%s" % [state.get("turn", -1), state.get("phase", "")]: return true
	for member: int in _alive(state, squad):
		if str(state.units[member].get("definition_id", "")).ends_with(":suboden-khan"): return true
	return false

static func within(model: Dictionary, bounds: Rect2) -> bool:
	return model.position.distance_to(model.position.clamp(bounds.position, bounds.end)) <= float(model.radius) + EPSILON

static func model_areas(state: Dictionary, model: int) -> Array[Dictionary]:
	var found: Array[Dictionary] = []
	for area: Dictionary in areas(state):
		if within(state.units[model], area.bounds): found.append(area)
	return found

static func segment_hits(first: Vector2, last: Vector2, rect: Rect2) -> bool:
	if rect.has_point(first) or rect.has_point(last): return true
	var corners: Array[Vector2] = [rect.position, Vector2(rect.end.x, rect.position.y), rect.end, Vector2(rect.position.x, rect.end.y)]
	for index in range(4):
		if Geometry2D.segment_intersects_segment(first, last, corners[index], corners[(index + 1) % 4]) != null: return true
	return false

static func movement_obstacles(state: Dictionary, model: int) -> Array[Rect2]:
	var blocked: Array[Rect2] = []
	if take_to_skies_active(state, model): return blocked
	var passes_dense := has_keyword(state.units[model], ["infantry", "beasts", "swarm"]) or mobile_unit(state, model)
	for area: Dictionary in areas(state):
		for feature: Dictionary in area.features:
			if area.category == "legacy" or (area.category == "dense" and not passes_dense and float(feature.height) > 2.0): blocked.append(feature.bounds)
	return blocked

static func _vertical_access_error(state: Dictionary, model: Dictionary, surface: Dictionary, destination: Vector2) -> String:
	var area_index := int(surface.get("area_index", -1))
	var terrain_areas := areas(state)
	if area_index < 0 or area_index >= terrain_areas.size(): return "This floor has no supported vertical access path."
	var area: Dictionary = terrain_areas[area_index]
	var access_features: Array = surface.get("access_features", [])
	var radius := maxf(0.0, float(model.get("radius", 0.0)))
	for feature_index: Variant in access_features:
		var index := int(feature_index)
		if index < 0 or index >= area.get("features", []).size(): continue
		var feature: Dictionary = area.features[index]
		if float(feature.get("height", 0.0)) <= 0.0: continue
		if segment_hits(model.position, destination, feature.bounds.grow(radius + 0.5 + EPSILON)): return ""
	return "A vertical move must stay within 1/2 inch horizontally of the ruin wall."

static func path_error(state: Dictionary, model: int, destination: Vector2, destination_elevation: float = -1.0) -> String:
	var unit: Dictionary = state.units[model]
	var current_elevation := float(unit.get("elevation", 0.0))
	var target_elevation := current_elevation if destination_elevation < 0.0 else destination_elevation
	if target_elevation < 0.0: return "Choose a supported battlefield elevation."
	var origin_surface := surface_at(state, unit, unit.position, current_elevation)
	if origin_surface.is_empty(): return "The model is not on a supported ground or terrain surface."
	var destination_surface := surface_at(state, unit, destination, target_elevation)
	if destination_surface.is_empty(): return "The base must finish wholly on ground level or an eligible terrain surface."
	if absf(target_elevation - current_elevation) <= EPSILON and current_elevation > EPSILON:
		if str(origin_surface.get("id", "")) != str(destination_surface.get("id", "")):
			return "This movement path cannot cross between disconnected upper floors."
	var vertical_access_features: Array[Rect2] = []
	if absf(target_elevation - current_elevation) > EPSILON and not take_to_skies_active(state, model):
		var access_surface: Dictionary = destination_surface if target_elevation > EPSILON else origin_surface
		var access_error := _vertical_access_error(state, unit, access_surface, destination)
		if not access_error.is_empty(): return access_error
		var access_area_index := int(access_surface.get("area_index", -1))
		var terrain_areas := areas(state)
		if access_area_index >= 0 and access_area_index < terrain_areas.size():
			var access_area: Dictionary = terrain_areas[access_area_index]
			for feature_index: Variant in access_surface.get("access_features", []):
				var index := int(feature_index)
				if index >= 0 and index < access_area.get("features", []).size():
					var access_feature: Dictionary = access_area.features[index]
					var access_bounds: Rect2 = access_feature.get("bounds", Rect2())
					if float(access_feature.get("height", 0.0)) > 0.0: vertical_access_features.append(access_bounds)
	var radius := maxf(0.0, float(unit.radius) - EPSILON)
	for obstacle: Rect2 in movement_obstacles(state, model):
		if obstacle in vertical_access_features: continue
		if segment_hits(unit.position, destination, obstacle.grow(radius)):
			if current_elevation > EPSILON: return "This model cannot move through an obstructing terrain feature on its current floor."
			return "This model cannot pass through that terrain feature at ground level."
	for area: Dictionary in areas(state):
		for feature: Dictionary in area.features:
			if feature.blocks_end and destination.distance_to(destination.clamp(feature.bounds.position, feature.bounds.end)) < radius:
				return "The base cannot finish inside a terrain wall or barricade."
	return ""

static func _alive(state: Dictionary, squad: int) -> Array[int]:
	var ids: Array[int] = []
	for id: int in state.units:
		if state.units[id].squad == squad and state.units[id].wounds > 0 and state.units[id].get("on_battlefield", true): ids.append(id)
	return ids

static func hidden(state: Dictionary, model: int) -> bool:
	if legacy(state) or state.units[model].wounds <= 0: return false
	var unit: Dictionary = state.units[model]
	if not has_keyword(unit, ["infantry", "beasts", "swarm"]): return false
	var shadow_hidden_key := "phobos-shadow-hidden:%d:%d" % [int(unit.squad), int(state.turn)]
	var shadow_masters_keeps_hidden := bool(state.get("unit_abilities", {}).get("used", {}).get(shadow_hidden_key, false))
	if int(state.squads[unit.squad].get("last_ranged_turn", -1)) >= int(state.turn) - 1 and not shadow_masters_keeps_hidden: return false
	for area: Dictionary in model_areas(state, model):
		if area.category in ["light", "dense"] and not area.features.is_empty(): return true
	return false

static func unit_hidden(state: Dictionary, squad: int) -> bool:
	if not state.get("squads", {}).has(squad): return false
	var models := _alive(state, squad)
	if models.is_empty(): return false
	for model: int in models:
		if not hidden(state, model): return false
	return true

static func _point_in_triangle(point: Vector2, triangle: Array[Vector2]) -> bool:
	return Geometry2D.is_point_in_polygon(point, PackedVector2Array(triangle))

static func _hull_hits(observer: Vector2, target: Dictionary, rect: Rect2) -> bool:
	# Convex hull of observing centre and target disk = tangent triangle + disk.
	# This certifies full visibility from that centre without sampling gaps.
	var radius: float = target.radius
	if target.position.distance_to(target.position.clamp(rect.position, rect.end)) <= radius: return true
	var delta: Vector2 = observer - target.position
	var square := delta.length_squared()
	if square <= radius * radius: return false
	var foot: Vector2 = target.position + delta * radius * radius / square
	var offset: Vector2 = delta.orthogonal() * radius * sqrt(square - radius * radius) / square
	var triangle: Array[Vector2] = [observer, foot + offset, foot - offset]
	for corner in [rect.position, Vector2(rect.end.x, rect.position.y), rect.end, Vector2(rect.position.x, rect.end.y)]:
		if _point_in_triangle(corner, triangle): return true
	for index in range(3):
		if segment_hits(triangle[index], triangle[(index + 1) % 3], rect): return true
	return false

static func _clip_segment_axis(start: float, delta: float, low: float, high: float, interval: Vector2) -> Vector2:
	if absf(delta) <= EPSILON:
		if start < low - EPSILON or start > high + EPSILON: return Vector2(-1.0, -1.0)
		return interval
	var first_t := (low - start) / delta
	var last_t := (high - start) / delta
	if first_t > last_t:
		var temporary := first_t
		first_t = last_t
		last_t = temporary
	var clipped := Vector2(maxf(interval.x, first_t), minf(interval.y, last_t))
	return Vector2(-1.0, -1.0) if clipped.x > clipped.y + EPSILON else clipped

static func _segment_rect_interval(first: Vector2, last: Vector2, rect: Rect2) -> Vector2:
	var delta := last - first
	var interval := _clip_segment_axis(first.x, delta.x, rect.position.x, rect.end.x, Vector2(0.0, 1.0))
	if interval.x < 0.0: return interval
	return _clip_segment_axis(first.y, delta.y, rect.position.y, rect.end.y, interval)

static func _feature_blocks_sightline(first: Vector2, last: Vector2, first_height: float, last_height: float, feature: Dictionary) -> bool:
	var height := float(feature.get("height", 0.0))
	if height <= 0.0: return false
	var bounds: Rect2 = feature.get("bounds", Rect2())
	var interval := _segment_rect_interval(first, last, bounds.grow(SIGHT_RADIUS))
	if interval.x < 0.0: return false
	var height_at_entry := lerpf(first_height, last_height, interval.x)
	var height_at_exit := lerpf(first_height, last_height, interval.y)
	return minf(height_at_entry, height_at_exit) <= height + SIGHT_RADIUS and maxf(height_at_entry, height_at_exit) >= -SIGHT_RADIUS

static func _elevated_sightline_clear(state: Dictionary, first: Dictionary, last: Dictionary, start: Vector2, end: Vector2, start_height: float, end_height: float) -> bool:
	for area: Dictionary in areas(state):
		if area.get("category", "") in ["light", "dense"] and not within(first, area.bounds) and not within(last, area.bounds) and segment_hits(start, end, area.bounds.grow(SIGHT_RADIUS)):
			return false
		for feature: Dictionary in area.get("features", []):
			if _feature_blocks_sightline(start, end, start_height, end_height, feature): return false
	return true

static func _elevated_pair(state: Dictionary, observer: int, target: int) -> Dictionary:
	var first: Dictionary = state.units[observer]
	var last: Dictionary = state.units[target]
	var first_elevation := float(first.get("elevation", 0.0))
	var last_elevation := float(last.get("elevation", 0.0))
	var first_surface := surface_at(state, first, first.position, first_elevation)
	var last_surface := surface_at(state, last, last.position, last_elevation)
	if first_surface.is_empty() or last_surface.is_empty():
		return {"visible": false, "fully_visible": false, "hidden": false, "detection": 15.0, "gone_to_ground": false,
			"unsupported_geometry": true, "geometry_error": "Ranged line of sight requires a supported ground or terrain surface."}
	var partially_blocked := false
	var dense_blocked := false
	var terrain_areas := areas(state)
	for area: Dictionary in terrain_areas:
		var own_area := within(first, area.bounds) or within(last, area.bounds)
		if area.get("category", "") in ["light", "dense"] and not own_area and _hull_hits(first.position, last, area.bounds.grow(SIGHT_RADIUS)):
			partially_blocked = true
		for feature: Dictionary in area.get("features", []):
			if float(feature.get("height", 0.0)) <= 0.0 or minf(first_elevation, last_elevation) > float(feature.height) + EPSILON: continue
			var bounds: Rect2 = feature.get("bounds", Rect2())
			if _hull_hits(first.position, last, bounds.grow(SIGHT_RADIUS)):
				partially_blocked = true
				if area.get("category", "") == "dense": dense_blocked = true
	var is_hidden := hidden(state, target)
	var grounded := is_hidden and dense_blocked
	var detection := Detection.detection_range(state, target, grounded)
	var distance: float = maxf(0.0, first.position.distance_to(last.position) - float(first.radius) - float(last.radius))
	if is_hidden and distance > detection + EPSILON:
		return {"visible": false, "fully_visible": false, "hidden": true, "detection": detection, "gone_to_ground": grounded}
	var side: Vector2 = (last.position - first.position).normalized().orthogonal()
	if side == Vector2.ZERO: side = Vector2.UP
	var first_heights: Array[float] = [first_elevation, first_elevation + maxf(0.0, float(first.get("sight_height", 1.3)))]
	var last_heights: Array[float] = [last_elevation, last_elevation + maxf(0.0, float(last.get("sight_height", 1.3)))]
	var visible := false
	# A clear sampled 3D ray is a visibility witness; no witness stays conservative.
	for first_offset in [0.0, -1.0, 1.0]:
		var start: Vector2 = first.position + side * float(first.radius) * first_offset
		for last_offset in [0.0, -1.0, 1.0]:
			var end: Vector2 = last.position + side * float(last.radius) * last_offset
			for start_height: float in first_heights:
				for end_height: float in last_heights:
					if _elevated_sightline_clear(state, first, last, start, end, start_height, end_height): visible = true
	return {"visible": visible, "fully_visible": visible and not partially_blocked, "hidden": is_hidden,
		"detection": detection, "gone_to_ground": grounded, "distance": distance}

static func pair(state: Dictionary, observer: int, target: int) -> Dictionary:
	var first: Dictionary = state.units[observer]
	var last: Dictionary = state.units[target]
	if absf(float(first.get("elevation", 0.0))) > EPSILON or absf(float(last.get("elevation", 0.0))) > EPSILON:
		if legacy(state): return {"visible": false, "fully_visible": false, "hidden": false, "detection": 15.0, "gone_to_ground": false, "unsupported_geometry": true, "geometry_error": "Elevated visibility is unavailable on this legacy terrain layout."}
		return _elevated_pair(state, observer, target)
	if legacy(state):
		var clear := true
		for area: Dictionary in areas(state):
			if segment_hits(first.position, last.position, area.bounds): clear = false
		return {"visible": clear, "fully_visible": clear, "hidden": false, "detection": 15.0, "gone_to_ground": false}
	var partially_blocked := false
	var dense_blocked := false
	for area: Dictionary in areas(state):
		var own_area := within(first, area.bounds) or within(last, area.bounds)
		if area.category in ["light", "dense"] and not own_area and _hull_hits(first.position, last, area.bounds.grow(SIGHT_RADIUS)):
			partially_blocked = true
		for feature: Dictionary in area.features:
			if float(feature.height) > 0 and _hull_hits(first.position, last, feature.bounds.grow(SIGHT_RADIUS)):
				partially_blocked = true
				if area.category == "dense": dense_blocked = true
	var is_hidden := hidden(state, target)
	var grounded := is_hidden and dense_blocked
	var detection := Detection.detection_range(state, target, grounded)
	var distance: float = maxf(0.0, first.position.distance_to(last.position) - float(first.radius) - float(last.radius))
	if is_hidden and distance > detection + EPSILON:
		return {"visible": false, "fully_visible": false, "hidden": true, "detection": detection, "gone_to_ground": grounded}
	var side: Vector2 = (last.position - first.position).normalized().orthogonal()
	if side == Vector2.ZERO: side = Vector2.UP
	var visible := false
	# A clear ray is a valid witness in the cylindrical proxy. No witness is
	# conservative, rather than claiming exact imported-mesh visibility.
	var ray_height := minf(float(first.get("sight_height", 1.3)), float(last.get("sight_height", 1.3)))
	for first_offset in [0.0, -1.0, 1.0]:
		for last_offset in [0.0, -1.0, 1.0]:
			var start: Vector2 = first.position + side * float(first.radius) * first_offset
			var end: Vector2 = last.position + side * float(last.radius) * last_offset
			var clear := true
			for area: Dictionary in areas(state):
				if area.category in ["light", "dense"] and not within(first, area.bounds) and not within(last, area.bounds) and segment_hits(start, end, area.bounds.grow(SIGHT_RADIUS)): clear = false
				for feature: Dictionary in area.features:
					if float(feature.height) >= ray_height and segment_hits(start, end, feature.bounds.grow(SIGHT_RADIUS)): clear = false
			if clear: visible = true
	return {"visible": visible, "fully_visible": visible and not partially_blocked, "hidden": is_hidden, "detection": detection, "gone_to_ground": grounded}

static func benefit_of_cover(state: Dictionary, observer: int, squad: int) -> bool:
	if legacy(state): return false
	var ids := _alive(state, squad)
	if ids.is_empty(): return false
	if Detection.stealth(state, squad) or Smoke.cover(state, observer, squad): return true
	for id: int in ids:
		var in_area := has_keyword(state.units[id], ["infantry", "beasts", "swarm"]) and not model_areas(state, id).is_empty()
		if not in_area and pair(state, observer, id).fully_visible: return false
	return true

static func targeting(state: Dictionary, observer: int, squad: int) -> Dictionary:
	var visible := false
	var unsupported_geometry := false
	var distance := INF
	for id: int in _alive(state, squad):
		var sight := pair(state, observer, id)
		visible = visible or sight.visible
		unsupported_geometry = unsupported_geometry or bool(sight.get("unsupported_geometry", false))
		distance = minf(distance, maxf(0.0, state.units[observer].position.distance_to(state.units[id].position) - float(state.units[observer].radius) - float(state.units[id].radius)))
	if unsupported_geometry: visible = false
	return {"visible": visible, "distance": distance, "cover": benefit_of_cover(state, observer, squad), "unsupported_geometry": unsupported_geometry}

static func _record_has_keyword(record: Dictionary, keyword: String) -> bool:
	for value: Variant in record.get("keywords", []):
		if str(value).strip_edges().to_upper() == keyword.to_upper(): return true
	return false

static func squad_has_keyword_case_insensitive(state: Dictionary, squad: int, keyword: String) -> bool:
	for model: int in _alive(state, squad):
		if _record_has_keyword(state.units[model], keyword): return true
	return false

static func plunging_fire_applies(state: Dictionary, observer: int, target: int, sight: Dictionary = {}) -> bool:
	if not state.get("units", {}).has(observer) or not state.get("squads", {}).has(target): return false
	var firing_model: Dictionary = state.units[observer]
	if _record_has_keyword(firing_model, "AIRCRAFT") or squad_has_keyword_case_insensitive(state, target, "AIRCRAFT"): return false
	var target_has_ground_model := false
	for model: int in _alive(state, target):
		if absf(float(state.units[model].get("elevation", 0.0))) <= EPSILON:
			target_has_ground_model = true
			break
	if not target_has_ground_model: return false
	var resolved_sight := sight if not sight.is_empty() else targeting(state, observer, target)
	if not bool(resolved_sight.get("visible", false)): return false
	var elevation := float(firing_model.get("elevation", 0.0))
	var surface := surface_at(state, firing_model, firing_model.position, elevation)
	var on_tall_surface := elevation >= 3.0 - EPSILON and not surface.is_empty() and str(surface.get("id", "")) != "ground"
	var towering_within_range := _record_has_keyword(firing_model, "TOWERING") and float(resolved_sight.get("distance", INF)) <= 12.0 + EPSILON
	return on_tall_surface or towering_within_range

static func visible_features(state: Dictionary, observer: int) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if not state.units.has(observer) or state.units[observer].wounds <= 0: return result
	var terrain_areas := areas(state)
	for area_index in range(terrain_areas.size()):
		var area: Dictionary = terrain_areas[area_index]
		for feature_index in range(area.get("features", []).size()):
			if _feature_visible(state, observer, area_index, feature_index):
				result.append({"area": area_index, "feature": feature_index, "label": "%s · section %d" % [str(area.get("name", "Terrain")), feature_index + 1]})
	return result

static func _feature_visible(state: Dictionary, observer: int, area_index: int, feature_index: int) -> bool:
	var terrain_areas := areas(state)
	if area_index < 0 or area_index >= terrain_areas.size(): return false
	var area: Dictionary = terrain_areas[area_index]
	var features: Array = area.get("features", [])
	if feature_index < 0 or feature_index >= features.size(): return false
	var rect: Rect2 = features[feature_index].bounds
	var center := rect.get_center()
	var samples: Array[Vector2] = [center, rect.position, Vector2(rect.end.x, rect.position.y), rect.end, Vector2(rect.position.x, rect.end.y),
		Vector2(center.x, rect.position.y), Vector2(rect.end.x, center.y), Vector2(center.x, rect.end.y), Vector2(rect.position.x, center.y)]
	var origin: Vector2 = state.units[observer].position
	for target: Vector2 in samples:
		var blocked := false
		for blocker_index in range(terrain_areas.size()):
			var blocker: Dictionary = terrain_areas[blocker_index]
			if blocker_index != area_index and blocker.category in ["light", "dense"] and not within(state.units[observer], blocker.bounds) and segment_hits(origin, target, blocker.bounds.grow(SIGHT_RADIUS)):
				blocked = true
				break
			for other_feature_index in range(blocker.get("features", []).size()):
				if blocker_index == area_index and other_feature_index == feature_index: continue
				var other: Dictionary = blocker.features[other_feature_index]
				if float(other.get("height", 0.0)) < float(state.units[observer].get("sight_height", 1.3)): continue
				if segment_hits(origin, target, other.bounds.grow(SIGHT_RADIUS)):
					blocked = true
					break
			if blocked: break
		if not blocked: return true
	return false
