extends VBoxContainer
## Keyboard-accessible reference for the weapon abilities already defined by KeywordGlossary.

const KeywordGlossary = preload("res://scripts/edition_11/keyword_glossary.gd")

var _toggle: Button
var _content: RichTextLabel

func _ready() -> void:
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_toggle = Button.new()
	_toggle.text = "Show weapon ability glossary"
	_toggle.tooltip_text = "Browse Core Rules summaries for recognized weapon traits. Match support still determines which effects are resolved."
	_toggle.toggle_mode = true
	_toggle.focus_mode = Control.FOCUS_ALL
	_toggle.toggled.connect(_set_expanded)
	add_child(_toggle)

	_content = RichTextLabel.new()
	_content.bbcode_enabled = false
	_content.fit_content = true
	_content.scroll_active = false
	_content.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_content.focus_mode = Control.FOCUS_ALL
	_content.selection_enabled = true
	_content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_content.text = KeywordGlossary.describe_supported_weapon_glossary()
	_content.visible = false
	add_child(_content)

func _set_expanded(expanded: bool) -> void:
	_content.visible = expanded
	_toggle.text = "Hide weapon ability glossary" if expanded else "Show weapon ability glossary"
