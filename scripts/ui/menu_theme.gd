extends RefCounted
## Imperial Dataslate title-menu tokens. Presentation only; no match authority.

const BACKGROUND := Color("0b0c0e")
const PANEL := Color("121418")
const BUTTON_FILL := Color("1a1c20")
const BUTTON_HOVER := Color("24262c")
const GOLD := Color("c9a227")
const GOLD_HIGHLIGHT := Color("e8c547")
const TEXT := Color("f4ede0")
const TEXT_SECONDARY := Color("b8a98a")
const PRIMARY_TEXT := Color("0b0c0e")
const EXIT_ACCENT := Color("8b2e2e")

static func box(bg: Color, border: Color, padding_h: int = 18, padding_v: int = 12, border_width: int = 2, radius: int = 2) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg
	style.border_color = border
	style.set_border_width_all(border_width)
	style.set_corner_radius_all(radius)
	style.content_margin_left = padding_h
	style.content_margin_right = padding_h
	style.content_margin_top = padding_v
	style.content_margin_bottom = padding_v
	return style

static func create() -> Theme:
	var result := Theme.new()
	result.default_font_size = 16
	for type in ["Label", "Button", "CheckBox"]:
		result.set_color("font_color", type, TEXT)
	result.set_color("font_color", "Label", TEXT)
	result.set_color("font_shadow_color", "Label", Color(0, 0, 0, 0.35))
	result.set_stylebox("panel", "PanelContainer", box(PANEL, GOLD, 24, 20, 2, 2))
	var normal := box(BUTTON_FILL, GOLD, 18, 12, 2, 2)
	var hover := box(BUTTON_HOVER, GOLD_HIGHLIGHT, 18, 12, 2, 2)
	var pressed := box(BUTTON_HOVER.darkened(0.08), GOLD, 18, 12, 2, 2)
	var focus := box(Color(0, 0, 0, 0), GOLD_HIGHLIGHT, 18, 12, 2, 2)
	var disabled := box(BACKGROUND, Color("394048"), 18, 12, 2, 2)
	for type in ["Button"]:
		result.set_stylebox("normal", type, normal)
		result.set_stylebox("hover", type, hover)
		result.set_stylebox("pressed", type, pressed)
		result.set_stylebox("focus", type, focus)
		result.set_stylebox("disabled", type, disabled)
		result.set_color("font_color", type, TEXT)
		result.set_color("font_hover_color", type, TEXT)
		result.set_color("font_pressed_color", type, TEXT)
		result.set_color("font_focus_color", type, TEXT)
		result.set_color("font_disabled_color", type, TEXT_SECONDARY.darkened(0.2))
	var primary := box(GOLD, GOLD_HIGHLIGHT, 18, 12, 3, 2)
	var primary_hover := box(GOLD_HIGHLIGHT, GOLD_HIGHLIGHT, 18, 12, 3, 2)
	var primary_pressed := box(GOLD.darkened(0.12), GOLD, 18, 12, 3, 2)
	var primary_focus := box(GOLD, GOLD_HIGHLIGHT, 18, 12, 3, 2)
	result.set_type_variation("ActionButton", "Button")
	result.set_stylebox("normal", "ActionButton", normal)
	result.set_stylebox("hover", "ActionButton", hover)
	result.set_stylebox("pressed", "ActionButton", pressed)
	result.set_stylebox("focus", "ActionButton", focus)
	result.set_stylebox("disabled", "ActionButton", disabled)
	result.set_color("font_color", "ActionButton", TEXT)
	result.set_color("font_hover_color", "ActionButton", TEXT)
	result.set_color("font_pressed_color", "ActionButton", TEXT)
	result.set_color("font_focus_color", "ActionButton", TEXT)
	result.set_color("font_disabled_color", "ActionButton", TEXT_SECONDARY.darkened(0.2))
	result.set_type_variation("PrimaryButton", "Button")
	result.set_stylebox("normal", "PrimaryButton", primary)
	result.set_stylebox("hover", "PrimaryButton", primary_hover)
	result.set_stylebox("pressed", "PrimaryButton", primary_pressed)
	result.set_stylebox("focus", "PrimaryButton", primary_focus)
	result.set_stylebox("disabled", "PrimaryButton", disabled)
	result.set_color("font_color", "PrimaryButton", PRIMARY_TEXT)
	result.set_color("font_hover_color", "PrimaryButton", PRIMARY_TEXT)
	result.set_color("font_pressed_color", "PrimaryButton", PRIMARY_TEXT)
	result.set_color("font_focus_color", "PrimaryButton", PRIMARY_TEXT)
	result.set_color("font_disabled_color", "PrimaryButton", PRIMARY_TEXT.lightened(0.25))
	result.set_type_variation("ToolbarButton", "Button")
	var tool_normal := box(BUTTON_FILL, GOLD, 12, 8, 1, 2)
	var tool_hover := box(BUTTON_HOVER, GOLD_HIGHLIGHT, 12, 8, 1, 2)
	result.set_stylebox("normal", "ToolbarButton", tool_normal)
	result.set_stylebox("hover", "ToolbarButton", tool_hover)
	result.set_stylebox("pressed", "ToolbarButton", tool_hover)
	result.set_stylebox("focus", "ToolbarButton", box(Color(0, 0, 0, 0), GOLD_HIGHLIGHT, 12, 8, 2, 2))
	result.set_stylebox("disabled", "ToolbarButton", disabled)
	result.set_color("font_color", "ToolbarButton", TEXT)
	result.set_color("font_hover_color", "ToolbarButton", TEXT)
	result.set_color("font_focus_color", "ToolbarButton", TEXT)
	result.set_type_variation("ExitButton", "Button")
	# Match ToolbarButton content margins so Exit lines up with Armies/Guide padding.
	var exit_normal := box(BUTTON_FILL, EXIT_ACCENT, 12, 8, 1, 2)
	var exit_hover := box(Color("2a1616"), Color("c45a5a"), 12, 8, 1, 2)
	result.set_stylebox("normal", "ExitButton", exit_normal)
	result.set_stylebox("hover", "ExitButton", exit_hover)
	result.set_stylebox("pressed", "ExitButton", exit_hover)
	result.set_stylebox("focus", "ExitButton", box(Color(0, 0, 0, 0), Color("c45a5a"), 12, 8, 2, 2))
	result.set_stylebox("disabled", "ExitButton", disabled)
	result.set_color("font_color", "ExitButton", TEXT)
	result.set_color("font_hover_color", "ExitButton", TEXT)
	result.set_color("font_focus_color", "ExitButton", TEXT)
	result.set_type_variation("SubtleCheck", "CheckBox")
	var subtle_normal := box(Color(0, 0, 0, 0), Color("5c5338"), 10, 4, 1, 2)
	var subtle_hover := box(Color("14161a"), Color("8a7a4a"), 10, 4, 1, 2)
	var subtle_pressed := box(Color("181a1e"), GOLD, 10, 4, 1, 2)
	result.set_stylebox("normal", "SubtleCheck", subtle_normal)
	result.set_stylebox("hover", "SubtleCheck", subtle_hover)
	result.set_stylebox("pressed", "SubtleCheck", subtle_pressed)
	result.set_stylebox("hover_pressed", "SubtleCheck", subtle_pressed)
	result.set_stylebox("focus", "SubtleCheck", box(Color(0, 0, 0, 0), GOLD_HIGHLIGHT, 10, 4, 1, 2))
	result.set_color("font_color", "SubtleCheck", TEXT_SECONDARY)
	result.set_color("font_hover_color", "SubtleCheck", TEXT)
	result.set_color("font_pressed_color", "SubtleCheck", TEXT)
	result.set_color("font_focus_color", "SubtleCheck", TEXT)
	result.set_constant("icon_max_width", "Button", 22)
	result.set_constant("h_separation", "Button", 10)
	result.set_constant("separation", "VBoxContainer", 18)
	result.set_constant("separation", "HBoxContainer", 10)
	return result

static func apply_action(button: Button) -> void:
	button.theme_type_variation = &"ActionButton"

static func apply_primary(button: Button) -> void:
	button.theme_type_variation = &"PrimaryButton"

static func apply_toolbar(button: Button) -> void:
	button.theme_type_variation = &"ToolbarButton"

static func apply_exit(button: Button) -> void:
	button.theme_type_variation = &"ExitButton"

static func apply_subtle_check(button: CheckBox) -> void:
	button.theme_type_variation = &"SubtleCheck"
