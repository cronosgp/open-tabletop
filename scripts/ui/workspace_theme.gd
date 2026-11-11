extends RefCounted
## Shared Imperial Dataslate presentation for workspaces and match chrome.
## Presentation only; no rules or state ownership.
const Icons = preload("res://scripts/ui/dataslate_icons.gd")

const BASE := Color("0b0c0e")
const SURFACE := Color("121418")
const ELEVATED := Color("1a1c20")
const HOVER := Color("24262c")
const GOLD := Color("c9a227")
const GOLD_HIGHLIGHT := Color("e8c547")
const TEXT := Color("f4ede0")
const MUTED := Color("b8a98a")
const BORDER := Color("5c5338")
const EXIT_ACCENT := Color("8b2e2e")

## Horizontal / vertical content margins matching the title-menu ActionButton.
const BUTTON_PAD_H := 18
const BUTTON_PAD_V := 12

static func box(color: Color, border: Color = BORDER, padding_h: int = 10, border_width: int = 1, radius: int = 2, padding_v: int = -1) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.border_color = border
	style.set_border_width_all(border_width)
	style.set_corner_radius_all(radius)
	var vertical := padding_h if padding_v < 0 else padding_v
	style.content_margin_left = padding_h
	style.content_margin_right = padding_h
	style.content_margin_top = vertical
	style.content_margin_bottom = vertical
	return style

static func button_box(color: Color, border: Color, border_width: int = 2) -> StyleBoxFlat:
	return box(color, border, BUTTON_PAD_H, border_width, 2, BUTTON_PAD_V)

static func create() -> Theme:
	var result := Theme.new()
	result.default_font_size = 16
	for type in ["Label", "Button", "OptionButton", "CheckBox", "LineEdit", "TextEdit", "ItemList", "TabContainer", "MenuButton"]:
		result.set_color("font_color", type, TEXT)
	result.set_stylebox("panel", "PanelContainer", box(SURFACE, GOLD, 12, 2, 2))
	var normal := button_box(ELEVATED, GOLD, 2)
	var hover := button_box(HOVER, GOLD_HIGHLIGHT, 2)
	var pressed := button_box(HOVER.darkened(0.08), GOLD, 2)
	var disabled := button_box(BASE, BORDER, 2)
	var focus := button_box(Color(0, 0, 0, 0), GOLD_HIGHLIGHT, 2)
	focus.set_border_width_all(2)
	for type in ["Button", "OptionButton", "MenuButton"]:
		result.set_stylebox("normal", type, normal)
		result.set_stylebox("hover", type, hover)
		result.set_stylebox("pressed", type, pressed)
		result.set_stylebox("disabled", type, disabled)
		result.set_color("font_disabled_color", type, MUTED.darkened(0.25))
		result.set_stylebox("focus", type, focus)
		result.set_constant("icon_max_width", type, 20)
		result.set_constant("h_separation", type, 8)
	# ActionButton: same chrome as the title-menu secondary buttons.
	result.set_type_variation("ActionButton", "Button")
	for state in ["normal", "hover", "pressed", "disabled", "focus"]:
		result.set_stylebox(state, "ActionButton", result.get_stylebox(state, "Button"))
	for color_name in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color"]:
		result.set_color(color_name, "ActionButton", TEXT)
	result.set_color("font_disabled_color", "ActionButton", MUTED.darkened(0.25))
	result.set_constant("icon_max_width", "ActionButton", 20)
	result.set_constant("h_separation", "ActionButton", 8)
	# PrimaryButton: gold fill shared with the title menu.
	result.set_type_variation("PrimaryButton", "Button")
	result.set_stylebox("normal", "PrimaryButton", button_box(GOLD, GOLD_HIGHLIGHT, 3))
	result.set_stylebox("hover", "PrimaryButton", button_box(GOLD_HIGHLIGHT, GOLD_HIGHLIGHT, 3))
	result.set_stylebox("pressed", "PrimaryButton", button_box(GOLD.darkened(0.12), GOLD, 3))
	result.set_stylebox("focus", "PrimaryButton", button_box(GOLD, GOLD_HIGHLIGHT, 3))
	result.set_stylebox("disabled", "PrimaryButton", disabled)
	for color_name in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color"]:
		result.set_color(color_name, "PrimaryButton", BASE)
	result.set_color("font_disabled_color", "PrimaryButton", BASE.lightened(0.25))
	result.set_constant("icon_max_width", "PrimaryButton", 20)
	result.set_constant("h_separation", "PrimaryButton", 8)
	# MatchPrimaryAction aliases PrimaryButton for the decision footer.
	result.set_type_variation("MatchPrimaryAction", "Button")
	for state in ["normal", "hover", "pressed", "focus", "disabled"]:
		result.set_stylebox(state, "MatchPrimaryAction", result.get_stylebox(state, "PrimaryButton"))
	for color_name in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color", "font_disabled_color"]:
		result.set_color(color_name, "MatchPrimaryAction", result.get_color(color_name, "PrimaryButton"))
	for type in ["LineEdit", "TextEdit", "ItemList"]:
		result.set_stylebox("normal" if type != "ItemList" else "panel", type, box(BASE, BORDER, 8, 1, 2))
		result.set_stylebox("focus", type, box(BASE, GOLD, 8, 2, 2))
	result.set_stylebox("selected", "ItemList", box(HOVER, GOLD, 8, 2, 2))
	result.set_stylebox("selected_focus", "ItemList", box(HOVER, GOLD_HIGHLIGHT, 8, 2, 2))
	result.set_stylebox("hovered", "ItemList", box(ELEVATED, BORDER, 8, 1, 2))
	result.set_constant("v_separation", "ItemList", 12)
	result.set_stylebox("panel", "TabContainer", box(SURFACE, GOLD, 8, 2, 2))
	for type in ["TabContainer", "TabBar"]:
		result.set_stylebox("tab_selected", type, box(HOVER, GOLD, 8, 2, 2))
		result.set_stylebox("tab_unselected", type, box(BASE, BORDER, 8, 1, 2))
	result.set_constant("separation", "VBoxContainer", 12)
	result.set_constant("separation", "HBoxContainer", 8)
	return result

static func apply_action(button: Button) -> void:
	if button == null:
		return
	button.theme_type_variation = &"ActionButton"
	_clear_button_overrides(button)

static func apply_primary(button: Button) -> void:
	if button == null:
		return
	button.theme_type_variation = &"PrimaryButton"
	_clear_button_overrides(button)

static func primary(button: Button) -> void:
	apply_primary(button)

static func _clear_button_overrides(button: Button) -> void:
	for state in ["normal", "hover", "pressed", "disabled", "focus"]:
		button.remove_theme_stylebox_override(state)
	for color_name in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color", "font_disabled_color"]:
		button.remove_theme_color_override(color_name)

static func heading(parent: Node, text: String) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_color_override("font_color", GOLD)
	label.add_theme_font_size_override("font_size", 14)
	parent.add_child(label)
	return label

static func decorate_button(button: BaseButton, icon_key: String = "", make_primary: bool = false) -> void:
	if button == null:
		return
	# MenuButton keeps its own theme type; only plain Buttons take Action/Primary variations.
	if button is Button and not (button is MenuButton) and not (button is OptionButton) and not (button is CheckButton):
		if make_primary:
			apply_primary(button as Button)
		else:
			apply_action(button as Button)
	if not icon_key.is_empty():
		Icons.apply(button, icon_key)
