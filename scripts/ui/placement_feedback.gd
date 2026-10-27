extends PanelContainer
## Screen-space feedback projected from a miniature; never validates rules.
var model := -1
var destination := Vector2.ZERO
var destination_elevation := 0.0
var message := ""
var heading := "Placement blocked"
var recovery := "Choose another destination."
var pinned := false
var destination_marker := false
var text_label := Label.new()
var content := HBoxContainer.new()
var card_symbol = preload("res://scripts/ui/combat_symbol.gd").new()
var marker = preload("res://scripts/ui/combat_symbol.gd").new()

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var style := StyleBoxFlat.new()
	style.bg_color = Color("241b20", 0.98)
	style.border_color = Color("ed998d")
	style.set_border_width_all(1)
	style.set_corner_radius_all(6)
	style.content_margin_left = 12
	style.content_margin_right = 12
	style.content_margin_top = 8
	style.content_margin_bottom = 8
	add_theme_stylebox_override("panel", style)
	text_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	text_label.custom_minimum_size.x = 260
	text_label.add_theme_font_size_override("font_size", 16)
	text_label.add_theme_color_override("font_color", Color("ffe7df"))
	text_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	text_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", 8)
	content.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card_symbol.kind = "Blocked footprint"
	card_symbol.ink = Color("ff766d")
	card_symbol.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	content.add_child(card_symbol)
	content.add_child(text_label)
	add_child(content)
	marker.kind = "Blocked footprint"
	marker.ink = Color("ff766d")
	marker.mouse_filter = Control.MOUSE_FILTER_IGNORE
	marker.z_index = 10
	marker.tooltip_text = "Rejected placement destination"
	var overlay := get_parent()
	if overlay != null: overlay.add_child(marker)
	marker.visible = false
	visible = false

func show_reason(id: int, target: Vector2, reason: String, retain: bool = false, mark_destination: bool = true, target_elevation: float = 0.0, error_code: String = "", recovery_text: String = "") -> void:
	model = id
	destination = target
	destination_elevation = target_elevation
	message = reason
	var inferred := _details_from_reason(reason) if error_code.is_empty() or recovery_text.is_empty() else {}
	var resolved_code := error_code if not error_code.is_empty() else str(inferred.get("error_code", ""))
	heading = _heading_for_error(resolved_code)
	recovery = recovery_text if not recovery_text.is_empty() else str(inferred.get("recovery", "Choose another destination."))
	pinned = retain
	destination_marker = mark_destination
	text_label.text = _feedback_text()
	custom_minimum_size.x = 284.0
	visible = not reason.is_empty()

func clear() -> void:
	visible = false
	message = ""
	heading = "Placement blocked"
	recovery = "Choose another destination."
	model = -1
	destination_elevation = 0.0
	pinned = false
	destination_marker = false
	marker.visible = false

func place(camera: Camera3D, world: Vector3, base_world: Vector3, base_radius: float, bounds: Rect2) -> void:
	if not visible:
		marker.visible = false
		return
	var behind_camera := camera.is_position_behind(world)
	var point := camera.unproject_position(world) if not behind_camera else bounds.get_center()
	var outside_board_view := behind_camera or not bounds.has_point(point)
	var direction := point - bounds.get_center()
	if behind_camera:
		var camera_local := camera.to_local(world)
		direction = Vector2(camera_local.x, -camera_local.y)
		if direction.length_squared() < 0.01: direction = Vector2.DOWN
		text_label.text = "Model behind camera\n" + _feedback_text()
	elif outside_board_view:
		if direction.length_squared() < 0.01: direction = Vector2.UP
		text_label.text = "Model outside board view · %s\n%s" % [_direction_name(direction), _feedback_text()]
	else:
		text_label.text = _feedback_text()

	var inset := Vector2(minf(12.0, bounds.size.x * 0.05), minf(12.0, bounds.size.y * 0.05))
	var safe_position := bounds.position + inset
	var safe_end := bounds.end - inset
	var safe_size := safe_end - safe_position
	if safe_size.x <= 0.0 or safe_size.y <= 0.0:
		safe_position = bounds.position
		safe_end = bounds.end
		safe_size = safe_end - safe_position
	if safe_size.x <= 0.0 or safe_size.y <= 0.0:
		visible = false
		_place_destination_marker(camera, bounds)
		return

	custom_minimum_size.x = minf(284.0, safe_size.x)
	var panel_style := get_theme_stylebox("panel")
	var horizontal_chrome := panel_style.get_minimum_size().x if panel_style != null else 0.0
	var symbol_width := card_symbol.get_combined_minimum_size().x + 8.0
	var available_text_width := safe_size.x - horizontal_chrome - symbol_width
	if available_text_width <= 1.0:
		visible = false
		_place_destination_marker(camera, bounds)
		return
	text_label.custom_minimum_size.x = maxf(1.0, minf(260.0, available_text_width))
	var panel_size := get_combined_minimum_size()
	panel_size.x = minf(maxf(panel_size.x, minf(284.0, safe_size.x)), safe_size.x)
	panel_size.y = maxf(panel_size.y, 1.0)
	if panel_size.y > safe_size.y:
		visible = false
		_place_destination_marker(camera, bounds)
		return
	size = panel_size
	var max_position := Vector2(maxf(safe_position.x, safe_end.x - panel_size.x), maxf(safe_position.y, safe_end.y - panel_size.y))
	var wanted: Vector2
	if outside_board_view:
		var ray := direction.normalized()
		var half_bounds := safe_size * 0.5
		var distance_x := half_bounds.x / absf(ray.x) if absf(ray.x) > 0.001 else INF
		var distance_y := half_bounds.y / absf(ray.y) if absf(ray.y) > 0.001 else INF
		var edge_point := (safe_position + safe_end) * 0.5 + ray * minf(distance_x, distance_y)
		wanted = edge_point - panel_size * 0.5
	else:
		wanted = _clear_position_around_base(camera, point, panel_size, base_world, base_radius, safe_position, max_position)
	position = _clamp_position(wanted, safe_position, max_position)
	_place_destination_marker(camera, bounds)

func _clear_position_around_base(camera: Camera3D, point: Vector2, panel_size: Vector2, base_world: Vector3, base_radius: float, safe_position: Vector2, max_position: Vector2) -> Vector2:
	var preferred := point - Vector2(panel_size.x * 0.5, panel_size.y + 18.0)
	var candidates: Array[Vector2] = [
		preferred,
		point + Vector2(-panel_size.x * 0.5, 18.0),
		point - Vector2(panel_size.x + 18.0, panel_size.y * 0.5),
		point + Vector2(18.0, -panel_size.y * 0.5),
		safe_position,
		Vector2(max_position.x, safe_position.y),
		Vector2(safe_position.x, max_position.y),
		max_position,
	]
	var excluded := _project_base_bounds(camera, base_world, base_radius)
	for candidate: Vector2 in candidates:
		var clamped := _clamp_position(candidate, safe_position, max_position)
		if excluded.size == Vector2.ZERO or not Rect2(clamped, panel_size).intersects(excluded):
			return clamped
	return _clamp_position(preferred, safe_position, max_position)

func _project_base_bounds(camera: Camera3D, base_world: Vector3, base_radius: float) -> Rect2:
	if camera.is_position_behind(base_world): return Rect2()
	var radius := maxf(absf(base_radius), 0.4)
	var points: Array[Vector2] = []
	for offset: Vector3 in [Vector3(-radius, 0.0, -radius), Vector3(-radius, 0.0, radius), Vector3(radius, 0.0, -radius), Vector3(radius, 0.0, radius)]:
		var corner := base_world + offset
		if not camera.is_position_behind(corner): points.append(camera.unproject_position(corner))
	if points.is_empty(): return Rect2()
	var minimum := points[0]
	var maximum := points[0]
	for projected: Vector2 in points:
		minimum = minimum.min(projected)
		maximum = maximum.max(projected)
	var padding := Vector2(10.0, 10.0)
	return Rect2(minimum - padding, maximum - minimum + padding * 2.0)

func _clamp_position(candidate: Vector2, safe_position: Vector2, max_position: Vector2) -> Vector2:
	return Vector2(clampf(candidate.x, safe_position.x, max_position.x), clampf(candidate.y, safe_position.y, max_position.y))

func _feedback_text() -> String:
	return "%s · %s\n%s" % [heading, message, recovery]

func _heading_for_error(error_code: String) -> String:
	match error_code:
		"exceeds_movement", "exceeds_contact_allowance": return "Movement limit reached"
		"terrain_blocked": return "Terrain blocks the route"
		"path_blocked", "base_blocks_path": return "Route blocked"
		"destination_overlap": return "Bases overlap"
		"invalid_destination": return "Invalid destination"
		"unsupported_elevation": return "Unsupported battlefield height"
		"model_unavailable": return "Model unavailable"
		"model_locked_in_contact": return "Model cannot move during contact"
		"unchanged_destination": return "Choose another position"
		"squad_not_coherent": return "Squad coherency needs attention"
		"engaged_after_move": return "Move must end unengaged"
		"pending_escape_wounds": return "Wounds still need allocation"
		"pending_unit_ability": return "Decision required before movement"
		"movement_unavailable": return "Move unavailable now"
		"movement_resolution_failed", "movement_continuation_unavailable": return "Move could not be completed"
		"contact_target_unavailable": return "Contact target unavailable"
		"contact_approach_blocked": return "Contact approach requirement not met"
		"contact_distance_unmet": return "Required approach distance not reached"
		"engagement_not_retained": return "Started engagement must remain"
		"unselected_enemy_engagement": return "Charge engages an unselected enemy"
		"selected_target_not_engaged", "contact_not_reached": return "Required Engagement Range not reached"
		"objective_range_unavailable", "outside_objective_range": return "Objective range not reached"
		"objective_not_closer": return "Moved models must approach the objective"
		"objective_consolidation_engaged": return "Objective consolidation must end unengaged"
		"contact_blocked": return "Contact move blocked"
		"wrong_owner": return "Not your model"
		"wrong_phase", "command_blocked": return "Move unavailable now"
		"model_in_reserves": return "Model is in reserves"
		"engaged_normal_move": return "Squad is engaged"
		"outside_battlefield": return "Outside the battlefield"
		_: return "Placement blocked"

func _details_from_reason(reason: String) -> Dictionary:
	var normalized := reason.to_lower()
	if normalized.begins_with("exceeds movement:"):
		return {"error_code": "exceeds_movement", "recovery": "Choose a destination within the remaining movement allowance."}
	if normalized.begins_with("contact placement needs "):
		return {"error_code": "exceeds_contact_allowance", "recovery": "Choose a closer contact position within the remaining allowance."}
	if normalized == "invalid destination.":
		return {"error_code": "invalid_destination", "recovery": "Choose a point on the battlefield."}
	if normalized == "choose a supported battlefield elevation.":
		return {"error_code": "unsupported_elevation", "recovery": "Select one of the listed battlefield heights."}
	if normalized == "choose a different destination.":
		return {"error_code": "unchanged_destination", "recovery": "Choose a new position or height."}
	if normalized == "select a living model in the moving squad.":
		return {"error_code": "model_unavailable", "recovery": "Select an eligible model in the active contact move."}
	if normalized == "models in base contact cannot move during pile-in or ongoing consolidation.":
		return {"error_code": "model_locked_in_contact", "recovery": "Keep this model in place and reposition another eligible model."}
	if normalized == "bases cannot overlap at the destination.":
		return {"error_code": "destination_overlap", "recovery": "Choose a free destination that leaves space between bases."}
	if normalized == "you cannot move an opponent's miniature.":
		return {"error_code": "wrong_owner", "recovery": "Select a model you control."}
	if normalized == "moves are allowed only in the movement phase.":
		return {"error_code": "wrong_phase", "recovery": "Wait until the Movement phase."}
	if normalized.begins_with("reserved models must arrive"):
		return {"error_code": "model_in_reserves", "recovery": "Use the unit's ingress action to enter the battlefield."}
	if normalized == "an engaged squad cannot make a normal move.":
		return {"error_code": "engaged_normal_move", "recovery": "Choose Fall Back or remain stationary."}
	if normalized == "squad is not in coherency. reposition its models or cancel movement.":
		return {"error_code": "squad_not_coherent", "recovery": "Reposition the squad until it meets coherency, then confirm or reset placement."}
	if normalized == "the moving squad must finish as one coherent group.":
		return {"error_code": "squad_not_coherent", "recovery": "Reposition the squad until it meets coherency, then confirm or cancel the move."}
	if normalized == "the move must end unengaged. reposition its models or reset placement.":
		return {"error_code": "engaged_after_move", "recovery": "Reposition the squad to finish unengaged, or reset placement."}
	if normalized == "allocate escape mortal wounds before confirming.":
		return {"error_code": "pending_escape_wounds", "recovery": "Finish allocating the pending escape wounds, then confirm movement."}
	if normalized == "resolve target augury web before confirming this unit's move.":
		return {"error_code": "pending_unit_ability", "recovery": "Resolve the Vehicle ability choice, then confirm movement."}
	if normalized == "no pending squad movement.":
		return {"error_code": "movement_unavailable", "recovery": "Begin or resume a move before confirming placement."}
	if normalized == "no pending contact movement.":
		return {"error_code": "movement_unavailable", "recovery": "Begin or resume a contact move before confirming placement."}
	if normalized == "a selected contact target is no longer on the board.":
		return {"error_code": "contact_target_unavailable", "recovery": "Choose an available contact target or cancel the move."}
	if normalized == "each required model must finish closer to its contact target.":
		return {"error_code": "contact_approach_blocked", "recovery": "Reposition each required model closer to its contact target, or cancel the move."}
	if normalized.begins_with("finish within "):
		return {"error_code": "contact_distance_unmet", "recovery": "Reposition the model to meet the required distance, or cancel the move."}
	if normalized == "a model must retain each enemy unit it started engaged with.":
		return {"error_code": "engagement_not_retained", "recovery": "Reposition this model within Engagement Range of every unit it started engaged with."}
	if normalized == "a charge cannot finish engaged with an unselected enemy unit.":
		return {"error_code": "unselected_enemy_engagement", "recovery": "Reposition the charging squad so it is not engaged with an unselected enemy unit."}
	if normalized == "the squad must finish engaged with every selected target.":
		return {"error_code": "selected_target_not_engaged", "recovery": "Reposition the squad into Engagement Range of each selected target."}
	if normalized == "the pile-in or ongoing consolidation must finish engaged.":
		return {"error_code": "contact_not_reached", "recovery": "Reposition the squad to finish in Engagement Range, or cancel the move."}
	if normalized == "moved models must finish within objective range; an obstacle/coherency exception is not certified for this objective.":
		return {"error_code": "objective_range_unavailable", "recovery": "Reposition the models into range of the objective, or cancel the move."}
	if normalized == "moved models outside objective range must finish closer to the selected objective.":
		return {"error_code": "objective_not_closer", "recovery": "Reposition each model closer to the selected objective, or cancel the move."}
	if normalized == "objective consolidation must finish unengaged.":
		return {"error_code": "objective_consolidation_engaged", "recovery": "Reposition the squad to finish outside Engagement Range, or cancel the move."}
	if normalized == "the squad must finish within range of the selected objective.":
		return {"error_code": "outside_objective_range", "recovery": "Move the squad into range of the selected objective, or cancel the move."}
	if normalized == "the base must stay on the battlefield.":
		return {"error_code": "outside_battlefield", "recovery": "Choose a destination inside the battlefield edge."}
	if normalized.begins_with("the base cannot cross terrain, a blocking enemy base") or normalized.begins_with("contact movement crosses an enemy base"):
		return {"error_code": "path_blocked", "recovery": "Choose a clear route that stays on the battlefield."}
	if normalized.contains("terrain") or normalized.contains("floor") or normalized.contains("surface") or normalized.contains("wall") or normalized.contains("barricade"):
		return {"error_code": "terrain_blocked", "recovery": "Choose a route around the terrain feature."}
	if normalized.contains("enemy base") or normalized.contains("board edge") or normalized.contains("battlefield"):
		return {"error_code": "path_blocked", "recovery": "Choose a clear route that stays on the battlefield."}
	return {}

func _place_destination_marker(camera: Camera3D, bounds: Rect2) -> void:
	marker.visible = false
	if not destination_marker or not destination.is_finite() or bounds.size.x < 36.0 or bounds.size.y < 36.0: return
	var target_world := Vector3(destination.x, destination_elevation + 0.12, destination.y)
	var behind_camera := camera.is_position_behind(target_world)
	var point := camera.unproject_position(target_world) if not behind_camera else bounds.get_center()
	var safe_bounds := bounds.grow(-18.0)
	if safe_bounds.size.x < 36.0 or safe_bounds.size.y < 36.0: safe_bounds = bounds
	var outside_view := behind_camera or not safe_bounds.has_point(point)
	if outside_view:
		var direction := point - safe_bounds.get_center()
		if behind_camera:
			var camera_local := camera.to_local(target_world)
			direction = Vector2(camera_local.x, -camera_local.y)
		if direction.length_squared() < 0.01: direction = Vector2.DOWN
		var ray := direction.normalized()
		var half_bounds := safe_bounds.size * 0.5
		var distance_x := half_bounds.x / absf(ray.x) if absf(ray.x) > 0.001 else INF
		var distance_y := half_bounds.y / absf(ray.y) if absf(ray.y) > 0.001 else INF
		point = safe_bounds.get_center() + ray * minf(distance_x, distance_y)
	var marker_size := marker.custom_minimum_size
	var max_position := safe_bounds.end - marker_size
	marker.position = Vector2(clampf(point.x - marker_size.x * 0.5, safe_bounds.position.x, max_position.x), clampf(point.y - marker_size.y * 0.5, safe_bounds.position.y, max_position.y))
	marker.visible = true

func _direction_name(direction: Vector2) -> String:
	if direction.length_squared() < 0.01: return "nearby"
	var names: Array[String] = ["right", "lower right", "below", "lower left", "left", "upper left", "above", "upper right"]
	var octant := posmod(roundi(direction.angle() / (PI / 4.0)), names.size())
	return names[octant]
