extends VBoxContainer
signal page_requested(start: int)
var first := 0
var total := 0
var items: Array = []
var summary: Label
var list: ItemList
var detail: TextEdit
var previous: Button
var next: Button

func _ready() -> void:
	var help := Label.new()
	help.text = "Events and D6 rolls in the order they occurred.\nViewing history does not change the match."
	help.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	add_child(help)
	var row := HBoxContainer.new()
	add_child(row)
	previous = Button.new()
	previous.text = "Anteriores"
	previous.pressed.connect(func(): page_requested.emit(maxi(0, first - 20)))
	row.add_child(previous)
	next = Button.new()
	next.text = "Next"
	next.pressed.connect(func(): page_requested.emit(first + 20))
	row.add_child(next)
	var refresh := Button.new()
	refresh.text = "Mais recentes"
	refresh.pressed.connect(func(): page_requested.emit(-1))
	row.add_child(refresh)
	summary = Label.new()
	summary.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	add_child(summary)
	list = ItemList.new()
	list.custom_minimum_size = Vector2(400, 120)
	list.item_selected.connect(_select)
	add_child(list)
	detail = TextEdit.new()
	detail.editable = false
	detail.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY
	detail.custom_minimum_size = Vector2(400, 210)
	detail.add_theme_color_override("font_readonly_color", Color("e3e5e8"))
	add_child(detail)
	show_page({"items": [], "start": 0, "total": 0})

func show_page(page: Dictionary) -> void:
	items = page.items
	first = page.start
	total = page.total
	summary.text = "Registros %d–%d de %d" % [first + 1 if total > 0 else 0, first + items.size(), total]
	if not page.get("notice", "").is_empty(): summary.text += "\n" + page.notice
	previous.disabled = first <= 0
	next.disabled = first + items.size() >= total
	list.clear()
	for entry: Dictionary in items:
		list.add_item("#%d • R%d • P%d • %s • %d D6" % [entry.sequence, entry.round, entry.active, entry.phase, entry.dice.size()])
	if items.is_empty():
		detail.text = "No records available. History begins when the match is saved or the first action is taken."
	else:
		list.select(items.size() - 1)
		_select(items.size() - 1)

func _select(index: int) -> void:
	if index < 0 or index >= items.size(): return
	var entry: Dictionary = items[index]
	var lines: Array[String] = ["#%d • %s UTC • revision %d" % [entry.sequence, entry.utc, entry.revision]]
	if entry.kind == "start": lines.append("Match history begins here.")
	for message in entry.messages: lines.append(str(message))
	for change in entry.changes: lines.append(str(change))
	for result in entry.get("results", []): lines.append(str(result))
	if not entry.dice.is_empty():
		lines.append("D6 na ordem em que foram rolados:")
		for index_d6 in range(entry.dice.size()):
			var die: Dictionary = entry.dice[index_d6]
			lines.append("%d. %d • %s • active player %d" % [index_d6 + 1, die.value, die.phase, die.active])
	detail.text = "\n".join(lines)
