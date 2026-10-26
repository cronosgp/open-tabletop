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
var technical := CheckButton.new()
var event_scroll := ScrollContainer.new()
var event_cards := VBoxContainer.new()
var current_selection := -1
var checkpoint_note := ""

func _ready() -> void:
	var help := Label.new()
	help.text = "Events and D6 rolls in the order they occurred.\nViewing history does not change the match."
	help.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	add_child(help)
	var row := HBoxContainer.new()
	add_child(row)
	previous = Button.new()
	previous.text = "Previous"
	previous.pressed.connect(func(): page_requested.emit(maxi(0, first - 20)))
	row.add_child(previous)
	next = Button.new()
	next.text = "Next"
	next.pressed.connect(func(): page_requested.emit(first + 20))
	row.add_child(next)
	var refresh := Button.new()
	refresh.text = "Latest"
	refresh.pressed.connect(func(): page_requested.emit(-1))
	row.add_child(refresh)
	summary = Label.new()
	summary.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	add_child(summary)
	technical.text = "Show technical record"
	technical.toggled.connect(func(expanded: bool):
		detail.visible = expanded
		event_scroll.visible = not expanded
		_select(current_selection)
	)
	add_child(technical)
	list = ItemList.new()
	list.custom_minimum_size = Vector2(400, 120)
	list.size_flags_vertical = Control.SIZE_FILL
	list.item_selected.connect(_select)
	add_child(list)
	event_scroll.custom_minimum_size = Vector2(400, 180)
	event_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	event_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(event_scroll)
	event_cards.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	event_cards.add_theme_constant_override("separation", 10)
	event_scroll.add_child(event_cards)
	detail = TextEdit.new()
	detail.editable = false
	detail.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY
	detail.custom_minimum_size = Vector2(400, 180)
	detail.size_flags_vertical = Control.SIZE_EXPAND_FILL
	detail.add_theme_color_override("font_readonly_color", Color("e3e5e8"))
	add_child(detail)
	detail.visible = false
	show_page({"items": [], "start": 0, "total": 0})

func show_page(page: Dictionary) -> void:
	items = page.items
	first = page.start
	total = page.total
	summary.text = "Records %d–%d of %d" % [first + 1 if total > 0 else 0, first + items.size(), total]
	var compacted_entries := int(page.get("compacted_entries", 0))
	if compacted_entries > 0:
		summary.text += "\nEarlier history was compacted after %d records." % compacted_entries
	summary.tooltip_text = ""
	var checkpoint: Dictionary = page.get("checkpoint", {})
	checkpoint_note = ""
	if not checkpoint.is_empty():
		var tip := str(checkpoint.get("hash", ""))
		var short_tip := tip.substr(0, 12) if tip.length() >= 12 else tip
		checkpoint_note = "Journal chain tip #%d • %s" % [int(checkpoint.get("count", 0)), short_tip]
		summary.tooltip_text = "Current journal chain tip. The matching saved checkpoint verifies the recorded prefix when the save is resumed. Full tip: %s" % tip
	if not page.get("notice", "").is_empty(): summary.text += "\n" + page.notice
	previous.disabled = first <= 0
	next.disabled = first + items.size() >= total
	list.clear()
	for entry: Dictionary in items:
		var phase_name := str(entry.get("phase", "Match")).replace("_", " ").capitalize()
		var preview := _entry_preview(entry)
		var row := list.add_item("R%d · P%d · %s · %s" % [int(entry.get("round", 0)), int(entry.get("active", 0)), phase_name, preview])
		list.set_item_tooltip(row, _entry_tooltip(entry))
	if items.is_empty():
		current_selection = -1
		for card: Node in event_cards.get_children(): card.free()
		detail.text = "No records available. History begins when the match is saved or the first action is taken."
		_event_card("No recorded events", detail.text)
	else:
		list.select(items.size() - 1)
		_select(items.size() - 1)

func _select(index: int) -> void:
	if index < 0 or index >= items.size(): return
	current_selection = index
	var entry: Dictionary = items[index]
	var messages: Array = entry.get("messages", [])
	for card: Node in event_cards.get_children(): card.free()
	var attack_record: Dictionary = entry.get("attack_summary", entry.get("patch", {}).get("last_attack", {}))
	if not attack_record.is_empty():
		for pool: Dictionary in attack_record.get("pools", []):
			_event_card("%s → %s" % [str(pool.get("weapon_name", "Weapon")), str(pool.get("target_name", _squad_name(entry.get("patch", {}).get("squads", {}), int(pool.get("target_squad", -1)))))], "Hits %d · Wounds %d\n%d damage applied · %d models destroyed\n%d wounds prevented · %d excess damage discarded" % [int(pool.get("hits", 0)), int(pool.get("wounds", 0)), int(pool.get("damage_applied", 0)), int(pool.get("models_destroyed", 0)), int(pool.get("prevented_wounds", 0)), int(pool.get("excess_damage_discarded", 0))])
		var hazard: Dictionary = attack_record.get("hazardous", {})
		if int(hazard.get("total", 0)) > 0: _event_card("Hazardous · attacking unit", "%d mortal wounds generated before prevention" % int(hazard.total))
	else:
		var event_context := "Round %s · %s · Player %s active" % [str(entry.get("round", "—")), str(entry.get("phase", "Match")).replace("_", " ").capitalize(), str(entry.get("active", "—"))]
		_event_card(event_context, "Shared context for the events below." if not messages.is_empty() else "Match state recorded.")
		for message: Variant in messages:
			var text := str(message).strip_edges()
			if text.is_empty(): continue
			var heading := _event_heading(text)
			_event_card(heading, "" if heading == text else text)
	var lines: Array[String] = ["RECORD #%d  •  %s UTC" % [entry.sequence, entry.utc], "Round %s  ·  Player %s active  ·  %s  ·  revision %s" % [str(entry.get("round", "—")), str(entry.get("active", "—")), str(entry.get("phase", "—")).replace("_", " ").capitalize(), str(entry.get("revision", "—"))]]
	if entry.kind == "start": lines.append("Match history begins here.")
	elif entry.kind == "checkpoint": lines.append("History checkpoint. %d earlier records were compacted to keep the journal bounded." % int(entry.get("compacted_entries", 0)))
	if not messages.is_empty():
		lines.append("\nEVENTS")
		for message in messages: lines.append("• " + str(message))
	var changes: Array = entry.get("changes", [])
	if not changes.is_empty():
		lines.append("\nMODEL / STATE CHANGES")
		for change in changes: lines.append("• " + str(change))
	var patch: Dictionary = entry.get("patch", {})
	var attack: Dictionary = patch.get("last_attack", {})
	if not attack.is_empty(): _append_attack_details(lines, attack, patch.get("squads", {}))
	var results: Array = entry.get("results", [])
	if not results.is_empty() and attack.is_empty():
		lines.append("\nRESULT DETAILS")
		for result in results: lines.append("• " + str(result))
	if not entry.get("dice", []).is_empty():
		lines.append("\nD6 ROLL ORDER  •  recorded values only")
		for index_d6 in range(entry.dice.size()):
			var die: Dictionary = entry.dice[index_d6]
			lines.append("%d. D%d → %d  ·  %s  ·  Player %s  ·  revision %s" % [index_d6 + 1, int(die.get("sides", 6)), int(die.get("value", 0)), str(die.get("phase", "—")).replace("_", " ").capitalize(), str(die.get("active", "—")), str(die.get("revision", "—"))])
	detail.text = "\n".join(lines)
	if technical.button_pressed and not checkpoint_note.is_empty(): detail.text += "\n\n" + checkpoint_note

func _entry_preview(entry: Dictionary) -> String:
	var messages: Array = entry.get("messages", [])
	for message: Variant in messages:
		var text := str(message).strip_edges()
		if text.is_empty(): continue
		return _event_heading(text)
	var attack_record: Dictionary = entry.get("attack_summary", entry.get("patch", {}).get("last_attack", {}))
	if not attack_record.is_empty():
		var pools: Array = attack_record.get("pools", [])
		if not pools.is_empty():
			var pool: Dictionary = pools[0]
			return "%s → %s" % [str(pool.get("weapon_name", "Weapon")), str(pool.get("target_name", "Target"))]
		return "Attack recorded"
	var kind := str(entry.get("kind", "")).capitalize()
	return kind if not kind.is_empty() else "Recorded state"

func _entry_tooltip(entry: Dictionary) -> String:
	var messages: Array = entry.get("messages", [])
	var lines: Array[String] = []
	for message: Variant in messages:
		var text := str(message).strip_edges()
		if not text.is_empty(): lines.append(text)
	if lines.is_empty(): lines.append(_entry_preview(entry))
	var dice_count := entry.get("dice", []).size()
	if dice_count > 0: lines.append("%d recorded dice. Open the technical record for the D6 order." % dice_count)
	return "\n".join(lines)

func _event_heading(message: String) -> String:
	var trimmed := message.strip_edges()
	var sentence := trimmed.find(". ")
	if sentence > 12 and sentence <= 88: return trimmed.substr(0, sentence + 1)
	if trimmed.length() <= 88: return trimmed
	return trimmed.substr(0, 85) + "…"

func _event_card(title: String, body: String) -> void:
	var panel := PanelContainer.new()
	var style := StyleBoxFlat.new()
	style.bg_color = Color("18232c")
	style.set_corner_radius_all(6)
	style.content_margin_left = 12
	style.content_margin_right = 12
	style.content_margin_top = 10
	style.content_margin_bottom = 10
	panel.add_theme_stylebox_override("panel", style)
	event_cards.add_child(panel)
	var column := VBoxContainer.new()
	panel.add_child(column)
	for text: String in [title, body]:
		var label := Label.new()
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		label.add_theme_font_size_override("font_size", 17 if text == title else 16)
		label.add_theme_color_override("font_color", Color("edcf8b") if text == title else Color("d9e2e6"))
		label.text = text
		if not text.is_empty(): column.add_child(label)

func _append_attack_details(lines: Array[String], attack: Dictionary, squads: Dictionary) -> void:
	lines.append("\nATTACK RESOLUTION")
	lines.append(str(attack.get("message", "Attack recorded.")))
	var assignments: Array = attack.get("assignments", [])
	if not assignments.is_empty():
		lines.append("Models that attacked / target assignments:")
		for assignment: Dictionary in assignments:
			var model := int(assignment.get("model", -1))
			var target := int(assignment.get("target", -1))
			var target_name := _squad_name(squads, target)
			var weapon := str(assignment.get("weapon", assignment.get("weapon_name", "")))
			var profile := str(assignment.get("profile", ""))
			var label := "Model %d → %s" % [model, target_name]
			if not weapon.is_empty(): label += " · " + weapon
			if not profile.is_empty(): label += " / " + profile
			if assignment.has("amount"): label += " · %s assigned" % str(assignment.amount)
			lines.append("• " + label)
	var pools: Array = attack.get("pools", [])
	for pool_index in range(pools.size()):
		var pool: Dictionary = pools[pool_index]
		lines.append("Pool %d · %s → %s" % [pool_index + 1, str(pool.get("weapon_name", "Weapon")), _squad_name(squads, int(pool.get("target_squad", -1)))])
		var totals: Array[String] = []
		for key: String in ["attacks", "hits", "wounds", "unsaved", "save_count", "damage_applied", "models_destroyed", "prevented_wounds", "excess_damage_discarded"]:
			if pool.has(key): totals.append("%s %s" % [key.replace("_", " ").capitalize(), str(pool[key])])
		if not totals.is_empty(): lines.append("  " + "  ·  ".join(totals))
		for key: String in ["attack_count_rolls", "hit_rolls", "wound_rolls", "save_rolls", "final_hit_rolls", "final_wound_rolls"]:
			if pool.has(key): lines.append("  %s: %s" % [key.replace("_", " ").capitalize(), str(pool[key])])
		for damage: Dictionary in pool.get("damage_rolls", []):
			lines.append("  Damage %s: D6 %s → %s" % [str(damage.get("expression", "")), str(damage.get("rolls", [])), str(damage.get("value", "—"))])
		for prevention: Dictionary in pool.get("prevention_rolls", []):
			if prevention.get("rolls", []).is_empty(): continue
			lines.append("  " + _prevention_summary(prevention))
	var hazardous: Dictionary = attack.get("hazardous", {})
	if not hazardous.is_empty() and not hazardous.get("rolls", []).is_empty():
		lines.append("Hazardous: D6 %s → %s wounds" % [str(hazardous.rolls), str(hazardous.get("total", 0))])
	for prevention: Dictionary in hazardous.get("prevention", []):
		if not prevention.get("rolls", []).is_empty(): lines.append("  " + _prevention_summary(prevention))

func _prevention_summary(prevention: Dictionary) -> String:
	var rolls: Array = prevention.get("rolls", [])
	var outcomes: Array = prevention.get("roll_outcomes", [])
	var faces: Array[String] = []
	var classified := 0
	for index in range(rolls.size()):
		var value := int(rolls[index])
		var face := str(value)
		if index < outcomes.size() and outcomes[index] is Dictionary:
			var outcome: Dictionary = outcomes[index]
			if int(outcome.get("roll", -1)) == value:
				face += "✓" if outcome.get("success", false) else "×"
				classified += 1
		faces.append(face)
	var note := "Feel No Pain %d+: D6 %s · %d wounds prevented" % [int(prevention.get("target", 0)), ", ".join(faces), int(prevention.get("prevented", 0))]
	var missing_outcomes := rolls.size() - classified
	if missing_outcomes == 1: note += " · 1 per-die outcome unavailable"
	elif missing_outcomes > 1: note += " · %d per-die outcomes unavailable" % missing_outcomes
	return note

func _squad_name(squads: Dictionary, squad_id: int) -> String:
	var squad: Dictionary = squads.get(squad_id, squads.get(str(squad_id), {}))
	return str(squad.get("name", "Unit %d" % squad_id))
