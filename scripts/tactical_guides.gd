extends Node3D
## Local-only distance guides. Host validation remains authoritative.

const Combat = preload("res://scripts/edition_11/combat_scenario.gd")
const Rules = preload("res://scripts/rules.gd")
const Contact = preload("res://scripts/edition_11/contact_movement.gd")
const GREEN := Color(0.2, 0.95, 0.65, 0.9)
const BLUE := Color(0.25, 0.65, 1.0, 0.9)
const ORANGE := Color(1.0, 0.6, 0.18, 0.9)
const RED := Color(1.0, 0.25, 0.3, 0.9)
const WHITE := Color(1.0, 0.95, 0.7, 1.0)
var board := PackedVector2Array()
var static_mesh := ImmediateMesh.new()
var hover_mesh := ImmediateMesh.new()
var material := StandardMaterial3D.new()
var caption := "Select a miniature to see its ranges."
var hover_caption := ""
var hover_error := ""
var hover_error_code := ""
var hover_recovery := ""
var current_range := 0.0
var hover_valid := false
var targets: Dictionary = {}
var static_vertices := 0

func _ready() -> void:
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.vertex_color_use_as_albedo = true
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	for mesh: ImmediateMesh in [static_mesh, hover_mesh]:
		var instance := MeshInstance3D.new()
		instance.mesh = mesh
		instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		add_child(instance)

func _polygon(mesh: ImmediateMesh, points: PackedVector2Array, color: Color, height: float = 0.045) -> void:
	for clipped: PackedVector2Array in Geometry2D.intersect_polygons(points, board):
		var indices := Geometry2D.triangulate_polygon(clipped)
		mesh.surface_set_color(color)
		mesh.surface_set_normal(Vector3.UP)
		for index: int in indices:
			mesh.surface_add_vertex(Vector3(clipped[index].x, height, clipped[index].y))
			if mesh == static_mesh: static_vertices += 1

func _disk(mesh: ImmediateMesh, center: Vector2, radius: float, color: Color, height: float = 0.045) -> void:
	if radius <= 0.001: return
	var points := PackedVector2Array()
	for index in range(96): points.append(center + Vector2.from_angle(index * TAU / 96.0) * radius)
	_polygon(mesh, points, color, height)

func _ring(mesh: ImmediateMesh, center: Vector2, radius: float, color: Color, width: float = 0.06, height: float = 0.06) -> void:
	if radius <= 0.001: return
	for index in range(96):
		var a := Vector2.from_angle(index * TAU / 96.0)
		var b := Vector2.from_angle((index + 1) * TAU / 96.0)
		_polygon(mesh, PackedVector2Array([center + a * radius, center + b * radius, center + b * maxf(0.0, radius - width), center + a * maxf(0.0, radius - width)]), color, height)

func _line(mesh: ImmediateMesh, first: Vector2, second: Vector2, color: Color, width: float = 0.055, height: float = 0.07) -> void:
	if first.distance_to(second) < 0.001: return
	var normal := (second - first).normalized().orthogonal() * width / 2.0
	_polygon(mesh, PackedVector2Array([first + normal, second + normal, second - normal, first - normal]), color, height)

func _range(center: Vector2, distance: float, color: Color) -> void:
	var fill := color
	fill.a = 0.14
	_disk(static_mesh, center, distance, fill)
	_ring(static_mesh, center, distance, color)

func _set_board(state: Dictionary) -> void:
	var half := Rules.half_board(state)
	board = PackedVector2Array([Vector2(-half.x, -half.y), Vector2(half.x, -half.y), half, Vector2(-half.x, half.y)])

func rebuild(state: Dictionary, selected: int, combat: bool, player: int) -> void:
	_set_board(state)
	static_mesh.clear_surfaces()
	hover_mesh.clear_surfaces()
	static_vertices = 0
	current_range = 0.0
	targets.clear()
	hover_caption = ""
	hover_error = ""
	hover_error_code = ""
	hover_recovery = ""
	caption = "Select a miniature to see its ranges."
	if combat and Combat.Mission.actor(state) > 0:
		caption = "Mission preparation: resolve the roll or declaration in Play before continuing."
		return
	if combat and Combat.UnitActions.actor(state) > 0:
		caption = "Unit ability decision: resolve or decline in Play. Placement previews must be confirmed as a whole unit."
		if Combat.UnitActions.pending(state).get("kind", "") == "wound": caption = "Implacable Eradication: choose free wound rerolls in Play, then keep the remaining rolls to continue to saves."
		return
	if combat and not Combat.Reanimation.pending(state).is_empty():
		caption = "Reanimation: choose a destroyed model and preview its return in Play."
		return
	if combat and Combat.Awakened.needs_setup(state):
		caption = "Awakened Dynasty: declare Overlord attachments in Play before deployment."
		return
	if combat and Combat.Doctrines.needs_choice(state):
		caption = "Combat Doctrines: choose a doctrine or no doctrine in Play."
		return
	if combat and Combat.OathOfMoment.needs_choice(state):
		caption = "Oath of Moment: choose an enemy unit in Play before continuing Command."
		return
	if combat and not Combat.Stratagems.pending(state).is_empty():
		caption = "Decision pending • player %d\nResolve the decision in Play to unlock the next action step." % Combat.actor(state)
		return
	if not state.units.has(selected) or state.units[selected].get("wounds", 1) <= 0: return
	var unit: Dictionary = state.units[selected]
	if not unit.get("on_battlefield", true):
		caption = "This unit is in strategic reserves. Use an ingress choice in Play to enter the battlefield."
		return
	static_mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLES, material)
	_ring(static_mesh, unit.position, float(unit.radius) + 0.16, WHITE, 0.10)
	if not combat:
		current_range = 0.0 if unit.moved else float(unit.movement)
		_range(unit.position, current_range, GREEN)
		caption = "Model %d • movement %.2f units\nGreen: distance limit. Destination still checks terrain and bases." % [selected, current_range]
	elif state.phase == "deployment":
		caption = "Deployment • player %d\nPlace the selected unit inside its outlined zone; bases must fit and cannot overlap. Confirm each coherent unit before the next one deploys." % Combat.actor(state)
	elif not state.get("pending_hazard", {}).is_empty():
		caption = "Hazardous mortal wounds\nSelect an eligible model in your unit, then allocate one wound. The weapon bearer is not required."
		for id: int in Combat.Hazard.eligible(state): _ring(static_mesh, state.units[id].position, float(state.units[id].radius) + 0.18, GREEN, 0.09)
	elif not state.get("pending_attack", {}).is_empty():
		caption = "Defender damage allocation\nSelect an eligible model, then use the allocation button. Wounded models must receive damage first."
		var current: Dictionary = state.pending_attack.current
		if current.phase == "precision": caption = "Precision\nAttacker: select a visible character, or decline Precision."
		elif current.phase == "order": caption = "Defender allocation order\nSelect one model from the group you want next. Wounded non-character groups go first; characters go last."
		elif current.steps[current.cursor].kind == "devastating": caption = "Devastating Wounds • no save\nChoose one eligible model for this critical wound. Excess mortal wounds from this attack are discarded."
		for id: int in Combat.Allocation.eligible(state): _ring(static_mesh, state.units[id].position, float(state.units[id].radius) + 0.18, GREEN, 0.09)
	elif not state.pending_contact.is_empty():
		current_range = Combat.ContactActions.remaining(state, selected)
		_range(unit.position, current_range, ORANGE)
		caption = "%s • model %d • %.2f inches remaining\nPlace models individually, then confirm.\nFinal approach, engagement and coherency are checked on confirmation." % [state.pending_contact.kind.replace("_", " "), selected, current_range]
		if state.pending_contact.locked.has(selected): caption += "\nThis model is locked in base contact."
		if state.pending_contact.kind == "consolidate_objective": caption += "\nObjective: " + state.mission.objectives[state.pending_contact.objective].name + "; finish unengaged and within range."
	else:
		var phase: String = state.phase
		var squad: Dictionary = state.squads[unit.squad]
		if phase == "movement":
			current_range = Combat.movement_remaining(state, selected)
			_range(unit.position, current_range, GREEN)
			var spent: float = state.pending_move.get("spent", {}).get(selected, 0.0) if state.pending_move.get("squad", -1) == unit.squad else 0.0
			var maximum := current_range + spent
			var take_to_skies_penalty: float = state.pending_move.get("take_to_skies_penalty", 0.0) if state.pending_move.get("squad", -1) == unit.squad else 0.0
			var take_to_skies_note := "\nTake to the Skies: -2 inches." if take_to_skies_penalty > 0.0 else ("\nTake to the Skies: HOVER ignores the 2-inch reduction." if state.pending_move.get("squad", -1) == unit.squad and state.pending_move.get("take_to_skies", false) else "")
			caption = "Model %d • %.2f / %.2f inches remaining\nGreen: movement limit • links: coherency.\nTerrain and bases are checked at the cursor.%s\nPlace miniatures, then confirm the squad." % [selected, current_range, maximum, take_to_skies_note]
			if state.pending_move.get("move_type", "") == "desperate_escape": caption += "\nDesperate Escape permits crossing enemy bases; destinations must be free."
			var coherent := Contact.coherent(state, unit.squad)
			caption += "\nSquad coherency: " + ("ready" if coherent else "needs repositioning before confirmation")
			for id: int in Combat.living(state, unit.squad):
				var nearest := -1
				var closest := INF
				for other: int in Combat.living(state, unit.squad):
					if id == other: continue
					var distance := Contact.edge(state.units[id], state.units[other])
					if distance < closest:
						closest = distance
						nearest = other
				if nearest >= 0: _line(static_mesh, state.units[id].position, state.units[nearest].position, GREEN if closest <= 2.001 else RED)
				if id != selected and Contact.edge(unit, state.units[id]) > 9.001: _line(static_mesh, unit.position, state.units[id].position, RED)
			if not state.pending_move.is_empty() and state.pending_move.origins.has(selected):
				_ring(static_mesh, state.pending_move.origins[selected], float(unit.radius), Color(1, 1, 1, 0.5))
		elif phase in ["shooting", "charge", "fight"]:
			var color := BLUE if phase == "shooting" else ORANGE
			var equipped := Combat.AttackPlan.Equipment.select(state, selected, false)
			current_range = float(equipped.stats.range_inches) if phase == "shooting" and not equipped.has("error") else 12.0 if phase == "charge" else 2.0
			if phase == "charge" and not state.pending_charge.is_empty() and state.pending_charge.squad == unit.squad:
				current_range = minf(12.0, state.pending_charge.maximum)
			_range(unit.position, current_range + float(unit.radius), color)
			caption = "Model %d • %s range %.2f inches from base\n" % [selected, phase, current_range]
			if phase == "shooting" and state.get("varied_equipment", false): caption += "Default equipped profile. Use the planner to select another weapon/profile.\n"
			if phase == "shooting" and Combat.Actions.shooting_blocked(state, unit.squad): caption += "Action started: shooting unavailable until turn end.\n"
			if phase == "charge" and Combat.Actions.charge_blocked(state, unit.squad): caption += "Action started: charges unavailable until turn end.\n"
			caption += "Blue: weapon reach from this miniature.\nGreen target: visible and in range.\nRed target: blocked or beyond range.\nThe squad fires with all eligible models." if phase == "shooting" else "Orange: target-distance guide.\nTargets use the whole squad's distance.\nCharge placement must also be valid." if phase == "charge" else "Orange: engagement reach.\nOnly engaged models contribute attacks.\nFollow the acting-player window."
			for id: int in state.units:
				var target: Dictionary = state.units[id]
				if target.owner == unit.owner or target.wounds <= 0: continue
				var distance := Contact.edge(unit, target)
				if phase == "charge":
					distance = INF
					for member: int in Combat.living(state, unit.squad): distance = minf(distance, Contact.edge(state.units[member], target))
				var in_range: bool = distance <= current_range + 0.001
				var visibility: Dictionary = Combat.Terrain.pair(state, selected, id) if phase == "shooting" else {}
				var clear: bool = phase != "shooting" or visibility.visible
				var cover: bool = phase == "shooting" and Combat.Terrain.benefit_of_cover(state, selected, target.squad)
				targets[id] = {"in_range": in_range, "clear_line": clear, "distance": distance, "cover": cover, "hidden": visibility.get("hidden", false), "detection": visibility.get("detection", 15.0)}
				var tint := GREEN if in_range and clear else RED
				if phase == "charge" and in_range: tint = ORANGE
				if (phase == "shooting" and Combat.Actions.shooting_blocked(state, unit.squad)) or (phase == "charge" and Combat.Actions.charge_blocked(state, unit.squad)): tint = RED
				_ring(static_mesh, target.position, float(target.radius) + 0.12, tint, 0.08)
		else:
			caption = "Model %d selected. Range guides appear in Movement, Shooting, Charge and Fight." % selected
		if unit.owner != player: caption += "\nInspecting the opponent's miniature."
	static_mesh.surface_end()

func preview(state: Dictionary, selected: int, combat: bool, player: int, destination: Variant, destination_elevation: float = -1.0) -> void:
	_set_board(state)
	hover_mesh.clear_surfaces()
	hover_valid = false
	hover_caption = ""
	hover_error = ""
	hover_error_code = ""
	hover_recovery = ""
	if combat and Combat.UnitActions.actor(state) > 0: return
	if combat and not Combat.Reanimation.pending(state).is_empty(): return
	if combat and Combat.Awakened.needs_setup(state): return
	if combat and Combat.Doctrines.needs_choice(state): return
	if combat and Combat.OathOfMoment.needs_choice(state): return
	if combat and not Combat.Stratagems.pending(state).is_empty(): return
	if destination == null or not destination is Vector2 or not state.units.has(selected): return
	var unit: Dictionary = state.units[selected]
	if unit.get("wounds", 1) <= 0 or not unit.get("on_battlefield", true): return
	if combat and state.phase == "deployment":
		var error := Combat.Deployment.command_error(state, player, state.revision)
		if error.is_empty(): error = Combat.Deployment.position_error(state, selected, destination)
		hover_valid = error.is_empty()
		hover_error = error
		hover_error_code = "valid" if hover_valid else "deployment_blocked"
		hover_recovery = "" if hover_valid else "Choose another deployment position."
		if not hover_valid and hover_error.is_empty(): hover_error = "Deployment validation did not complete."
		hover_caption = "Valid deployment position" if hover_valid else error
		var half := Rules.half_board(state)
		if not destination.is_finite() or absf(destination.x) >= half.x + float(unit.radius) - 0.001 or absf(destination.y) >= half.y + float(unit.radius) - 0.001: return
		hover_mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLES, material)
		_ring(hover_mesh, destination, float(unit.radius), GREEN if hover_valid else RED)
		hover_mesh.surface_end()
		return
	if combat and (not state.get("pending_attack", {}).is_empty() or not state.get("pending_hazard", {}).is_empty()):
		hover_caption = "Damage allocation: choose an eligible model and use the allocation button."
		return
	if combat and not state.pending_contact.is_empty():
		if unit.owner != player: return
		var error: String = Combat._command_error(state, player, state.revision)
		var contact_validation: Dictionary
		if not error.is_empty():
			contact_validation = {"valid": false, "code": "command_blocked", "reason": error, "recovery": "Resolve the current decision before placing a model."}
		else:
			contact_validation = Combat.ContactActions.validate_segment_result(state, selected, destination, destination_elevation)
		hover_valid = bool(contact_validation.get("valid", false))
		hover_error = str(contact_validation.get("reason", "Contact validation failed."))
		hover_error_code = str(contact_validation.get("code", "contact_blocked"))
		hover_recovery = str(contact_validation.get("recovery", "Choose another destination or cancel the move."))
		if not hover_valid and hover_error.is_empty(): hover_error = "Contact validation did not complete."
		var contact_current_elevation := float(unit.get("elevation", 0.0))
		var contact_target_elevation := contact_current_elevation if destination_elevation < 0.0 else destination_elevation
		var contact_ignores_vertical := Combat.Terrain.ignores_vertical_movement(state, selected)
		var contact_distance := Combat.Terrain.movement_distance(unit.position, contact_current_elevation, destination, contact_target_elevation, contact_ignores_vertical)
		hover_caption = "%.2f inches required: %s" % [contact_distance, "valid contact segment; confirm the squad to check final conditions" if hover_valid else hover_error]
		var tint := ORANGE if hover_valid else RED
		hover_mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLES, material)
		_line(hover_mesh, unit.position, destination, tint, 0.055, (contact_current_elevation + contact_target_elevation) * 0.5 + 0.07)
		_ring(hover_mesh, destination, float(unit.radius), tint, 0.06, contact_target_elevation + 0.06)
		hover_mesh.surface_end()
		return
	if combat and state.phase != "movement":
		var target_id := -1
		var closest := 1.0
		for id: int in targets:
			var distance: float = destination.distance_to(state.units[id].position)
			if distance < closest:
				closest = distance
				target_id = id
		if target_id < 0: return
		var info: Dictionary = targets[target_id]
		hover_valid = info.in_range and info.clear_line
		var action_blocked: bool = (state.phase == "shooting" and Combat.Actions.shooting_blocked(state, unit.squad)) or (state.phase == "charge" and Combat.Actions.charge_blocked(state, unit.squad))
		if action_blocked: hover_valid = false
		var tint := (ORANGE if state.phase == "charge" else GREEN) if hover_valid else RED
		hover_caption = "Target %d • %.2f inches • %s" % [target_id, info.distance, "distance check passed" if hover_valid else "blocked by terrain" if not info.clear_line else "beyond range"]
		if action_blocked: hover_caption = "Action started: %s unavailable until turn end." % state.phase
		if info.get("cover", false): hover_caption += "\nTarget squad has cover against this model: BS worsens by 1."
		if info.get("hidden", false): hover_caption += "\nHidden • detection %.0f inches." % info.detection
		hover_mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLES, material)
		_line(hover_mesh, unit.position, state.units[target_id].position, tint, 0.08)
		_ring(hover_mesh, state.units[target_id].position, float(state.units[target_id].radius) + 0.18, tint, 0.10)
		hover_mesh.surface_end()
		return
	if unit.owner != player: return
	var movement_current_elevation := float(unit.get("elevation", 0.0))
	var movement_target_elevation := movement_current_elevation if destination_elevation < 0.0 else destination_elevation
	var movement_validation: Dictionary = Combat.validate_move_result(state, player, selected, destination, state.revision, movement_target_elevation) if combat else Rules.validate_move_result(state, player, selected, destination)
	hover_valid = bool(movement_validation.get("valid", false))
	hover_error = str(movement_validation.get("reason", "Movement validation failed."))
	hover_error_code = str(movement_validation.get("code", "movement_blocked"))
	hover_recovery = str(movement_validation.get("recovery", "Choose another destination or cancel the move."))
	if not hover_valid and hover_error.is_empty(): hover_error = "Movement validation did not complete."
	var tint := GREEN if hover_valid else RED
	var movement_distance := unit.position.distance_to(destination)
	if combat:
		var movement_ignores_vertical := Combat.Terrain.ignores_vertical_movement(state, selected)
		movement_distance = Combat.Terrain.movement_distance(unit.position, movement_current_elevation, destination, movement_target_elevation, movement_ignores_vertical)
	hover_caption = "%.2f inches required: %s" % [movement_distance, "valid movement segment" if hover_valid else hover_error]
	if combat and hover_valid:
		var projected: Dictionary = state.duplicate(true)
		projected.units[selected].position = destination
		projected.units[selected].elevation = movement_target_elevation
		if not Contact.coherent(projected, unit.squad):
			tint = ORANGE
			hover_caption += " — squad will need repositioning before confirmation"
		if Combat._engaged(projected, unit.squad):
			tint = ORANGE
			hover_caption += " — move must finish unengaged"
	hover_mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLES, material)
	var line_height := (movement_current_elevation + movement_target_elevation) * 0.5 + 0.07 if combat else 0.07
	var ring_height := movement_target_elevation + 0.06 if combat else 0.06
	_line(hover_mesh, unit.position, destination, tint, 0.07, line_height)
	var fill := tint
	fill.a = 0.28
	_disk(hover_mesh, destination, float(unit.radius), fill, ring_height - 0.015)
	_ring(hover_mesh, destination, float(unit.radius), tint, 0.08, ring_height)
	hover_mesh.surface_end()
