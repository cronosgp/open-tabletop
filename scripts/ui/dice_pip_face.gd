extends Control
## Original project-owned D6 face drawing, shared by combat results and reroll choices.

var value := 1:
	set(next_value):
		value = clampi(next_value, 0, 6)
		queue_redraw()

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func _draw() -> void:
	if value < 1: return
	var bounds := Rect2(Vector2(1, 1), size - Vector2(2, 2))
	var ink := Color("20272d")
	draw_rect(bounds, Color("f2eee0"), true)
	draw_rect(bounds, ink, false, 1.5, true)
	var positions: Array[Vector2] = [
		Vector2(0.25, 0.25), Vector2(0.5, 0.25), Vector2(0.75, 0.25),
		Vector2(0.25, 0.5), Vector2(0.5, 0.5), Vector2(0.75, 0.5),
		Vector2(0.25, 0.75), Vector2(0.5, 0.75), Vector2(0.75, 0.75)
	]
	var active_pips: Array[int] = []
	match value:
		1: active_pips = [4]
		2: active_pips = [0, 8]
		3: active_pips = [0, 4, 8]
		4: active_pips = [0, 2, 6, 8]
		5: active_pips = [0, 2, 4, 6, 8]
		6: active_pips = [0, 2, 3, 5, 6, 8]
	for pip: int in active_pips:
		draw_circle(size * positions[pip], minf(size.x, size.y) * 0.075, ink, true, -1.0, true)
