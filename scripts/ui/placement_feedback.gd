extends PanelContainer
## Screen-space feedback projected from a miniature; never validates rules.
var model := -1
var destination := Vector2.ZERO
var message := ""
var pinned := false
var text_label := Label.new()

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
	add_child(text_label)
	visible = false

func show_reason(id: int, target: Vector2, reason: String, retain: bool = false) -> void:
	model = id
	destination = target
	message = reason
	pinned = retain
	text_label.text = "Blocked · " + reason + "\nChoose another destination."
	size = Vector2(284, 0)
	visible = not reason.is_empty()

func clear() -> void:
	visible = false
	message = ""
	model = -1
	pinned = false

func place(camera: Camera3D, world: Vector3, bounds: Rect2) -> void:
	if not visible: return
	var point := bounds.get_center() if camera.is_position_behind(world) else camera.unproject_position(world)
	var wanted := point - Vector2(size.x / 2.0, size.y + 30.0)
	position = Vector2(clampf(wanted.x, bounds.position.x, maxf(bounds.position.x, bounds.end.x - size.x)), clampf(wanted.y, bounds.position.y, maxf(bounds.position.y, bounds.end.y - size.y)))
