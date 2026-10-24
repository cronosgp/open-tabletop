extends Control
## Original geometric UI symbols, authored for this project under its MIT license.
var kind := "Hits":
	set(value):
		kind = value
		queue_redraw()

func _ready() -> void:
	custom_minimum_size = Vector2(28, 28)
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func _draw() -> void:
	var ink := Color("e8cf8b")
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
		_:
			draw_rect(Rect2(center - Vector2.ONE * radius, Vector2.ONE * radius * 2), ink, false, 2)
			draw_circle(center, 2, ink, true, -1, true)
