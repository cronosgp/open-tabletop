extends Control
## Original geometric UI symbols, authored for this project under its MIT license.
var kind := "Hits":
	set(value):
		kind = value
		custom_minimum_size = Vector2(36, 36) if value == "Blocked footprint" else Vector2(56, 28) if value == "Wounds remaining" else Vector2(28, 28)
		mouse_filter = Control.MOUSE_FILTER_STOP if value in ["Wounds remaining", "Destroyed"] else Control.MOUSE_FILTER_IGNORE
		queue_redraw()
var remaining := 0:
	set(value):
		remaining = maxi(0, value)
		queue_redraw()
var maximum := 1:
	set(value):
		maximum = maxi(1, value)
		queue_redraw()
var ink := Color("e8cf8b"):
	set(value):
		ink = value
		queue_redraw()

func _ready() -> void:
	focus_mode = Control.FOCUS_NONE
	kind = kind

func _draw() -> void:
	var center := size * 0.5
	var radius := minf(size.x, size.y) * 0.34
	match kind:
		"Hits":
			draw_arc(center, radius, 0, TAU, 32, ink, 2, true)
			for axis: Vector2 in [Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT, Vector2.UP]: draw_line(center + axis * radius * 0.65, center + axis * radius * 1.4, ink, 2, true)
		"Saves":
			var shield := PackedVector2Array([center + Vector2(-radius, -radius), center + Vector2(radius, -radius), center + Vector2(radius * 0.8, radius * 0.4), center + Vector2(0, radius), center + Vector2(-radius * 0.8, radius * 0.4), center + Vector2(-radius, -radius)])
			draw_polyline(shield, ink, 2, true)
		"Wounds":
			for index in 8:
				var direction := Vector2.from_angle(index * TAU / 8.0)
				draw_line(center + direction * radius * 0.4, center + direction * radius, ink, 2, true)
			draw_circle(center, radius * 0.2, ink, true, -1, true)
		"Damage":
			draw_polyline(PackedVector2Array([center + Vector2(0, -radius), center + Vector2(radius, 0), center + Vector2(0, radius), center + Vector2(-radius, 0), center + Vector2(0, -radius)]), ink, 2, true)
			draw_polyline(PackedVector2Array([center + Vector2(0, -radius), center + Vector2(-radius * 0.25, -radius * 0.1), center + Vector2(radius * 0.3, radius * 0.2), center + Vector2(0, radius)]), ink, 2, true)
		"Blocked footprint":
			var outline := PackedVector2Array()
			for step in 24:
				var angle := float(step) * TAU / 24.0
				outline.append(center + Vector2(cos(angle) * radius * 1.05, sin(angle) * radius * 0.62))
			outline.append(outline[0])
			draw_polyline(outline, ink, 2, true)
			draw_line(center + Vector2(-radius * 0.85, -radius * 0.85), center + Vector2(radius * 0.85, radius * 0.85), ink, 2, true)
		"Destroyed":
			draw_arc(center + Vector2(0, -radius * 0.55), radius * 0.32, 0, TAU, 16, ink, 2, true)
			draw_rect(Rect2(center + Vector2(-radius * 0.42, -radius * 0.12), Vector2(radius * 0.84, radius * 1.05)), ink, false, 2)
			draw_line(center + Vector2(-radius * 1.15, -radius * 1.15), center + Vector2(radius * 1.15, radius * 1.15), ink, 2, true)
			draw_line(center + Vector2(radius * 1.15, -radius * 1.15), center + Vector2(-radius * 1.15, radius * 1.15), ink, 2, true)
		"Wounds remaining":
			var segments := mini(maximum, 6)
			var filled := clampi(remaining, 0, segments)
			if maximum > 6:
				filled = 0 if remaining <= 0 else segments if remaining >= maximum else clampi(int(ceil(float(remaining) / float(maximum) * segments)), 1, segments - 1)
			var gap := 2.0
			var bar_width := maxf(size.x - 4.0, segments * 4.0)
			var segment_width := (bar_width - gap * float(segments - 1)) / float(segments)
			var top := center.y - 6.0
			for index in segments:
				var rect := Rect2(Vector2(2.0 + float(index) * (segment_width + gap), top), Vector2(segment_width, 12.0))
				if index < filled: draw_rect(rect, ink, true)
				else: draw_rect(rect, Color("8ea0ab"), false, 1.5)
		"Reroll":
			var arrow_radius := radius * 1.15
			var arrow_start := deg_to_rad(38.0)
			var arrow_end := deg_to_rad(315.0)
			draw_arc(center, arrow_radius, arrow_start, arrow_end, 32, ink, 2, true)
			var arrow_tip := center + Vector2.from_angle(arrow_end) * arrow_radius
			var radial := Vector2.from_angle(arrow_end)
			var tangent := Vector2.from_angle(arrow_end + PI * 0.5)
			draw_line(arrow_tip, arrow_tip - tangent * radius * 0.58 + radial * radius * 0.28, ink, 2, true)
			draw_line(arrow_tip, arrow_tip - tangent * radius * 0.58 - radial * radius * 0.28, ink, 2, true)
			var die_side := radius * 0.9
			draw_rect(Rect2(center - Vector2.ONE * die_side * 0.5, Vector2.ONE * die_side), ink, false, 2)
			draw_circle(center, radius * 0.14, ink, true, -1, true)
		_:
			draw_rect(Rect2(center - Vector2.ONE * radius, Vector2.ONE * radius * 2), ink, false, 2)
			draw_circle(center, 2, ink, true, -1, true)
