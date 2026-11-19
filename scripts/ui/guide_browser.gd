extends VBoxContainer
## Search and topic navigation over the maintained guide copy supplied by main.gd.
const WorkspaceTheme = preload("res://scripts/ui/workspace_theme.gd")
var source_text := ""
var topics: Array[Dictionary] = []
var search := LineEdit.new()
var navigation := ItemList.new()
var article := RichTextLabel.new()

func _ready() -> void:
	theme = WorkspaceTheme.create()
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	search.placeholder_text = "Search guide topics and instructions"
	search.clear_button_enabled = true
	add_child(search)
	var body := HBoxContainer.new()
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_child(body)
	navigation.custom_minimum_size = Vector2(220, 320)
	navigation.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_child(navigation)
	article.bbcode_enabled = true
	article.selection_enabled = true
	article.focus_mode = Control.FOCUS_ALL
	article.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	article.custom_minimum_size.y = 320
	body.add_child(article)
	for block in source_text.split("\n\n", false):
		var plain := block.substr(block.find("[b]") + 3)
		var title := plain.substr(0, plain.find("[/b]"))
		topics.append({"title": title, "text": block})
	search.text_changed.connect(func(_text: String): _filter())
	navigation.item_selected.connect(_select)
	_filter()

func _filter() -> void:
	navigation.clear()
	for topic in topics:
		if not search.text.strip_edges().is_empty() and search.text.to_lower() not in str(topic.text).to_lower(): continue
		navigation.add_item(topic.title)
		navigation.set_item_metadata(navigation.item_count - 1, topic.text)
	if navigation.item_count > 0:
		navigation.select(0)
		_select(0)
	else: article.text = "No matching topics. Clear the search or try another word."

func _select(index: int) -> void:
	article.text = navigation.get_item_metadata(index)
	article.scroll_to_line(0)
