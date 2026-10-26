extends VBoxContainer
## Structured view of the selected model's existing match profile.
signal reference_folder_requested
signal reference_reload_requested
signal reference_folder_copy_requested

var last_model: Dictionary = {}
var reference_folder_status: Label
var reference_folder_copy_button: Button
var source_toggle_button: Button
var source_content: VBoxContainer
var source_rule_count := 0
var source_profile_key := ""
var source_expanded := false
var source_expansion_user_set := false
var source_status_note := ""

static func fill_stats(grid: GridContainer, attributes: Array, columns: int) -> void:
	grid.columns = columns
	grid.add_theme_constant_override("h_separation", 8)
	grid.add_theme_constant_override("v_separation", 6)
	for child in grid.get_children(): child.free()
	for attribute: Dictionary in attributes:
		var cell := VBoxContainer.new()
		cell.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		cell.add_theme_constant_override("separation", 0)
		var label := Label.new()
		label.text = str(attribute.label)
		label.add_theme_font_size_override("font_size", 12)
		label.add_theme_color_override("font_color", Color("a5b6c2"))
		cell.add_child(label)
		var value := Label.new()
		value.text = str(attribute.value)
		value.add_theme_font_size_override("font_size", 19)
		value.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		cell.add_child(value)
		cell.tooltip_text = str(attribute.get("help", attribute.label))
		grid.add_child(cell)

func present(model: Dictionary) -> void:
	var next_profile_key := _source_profile_key(model)
	if next_profile_key != source_profile_key:
		source_profile_key = next_profile_key
		source_expanded = false
		source_expansion_user_set = false
	if model == last_model: return
	last_model = model.duplicate(true)
	reference_folder_status = null
	reference_folder_copy_button = null
	source_toggle_button = null
	source_content = null
	source_rule_count = 0
	source_status_note = ""
	for child in get_children(): child.free()
	add_theme_constant_override("separation", 12)
	_label(str(model.name), 24, Color("f2df83"))
	_label(str(model.identity), 16)
	_label("Scroll: Page Up/Down · Home/End · Escape returns.", 12, Color("9fb2c1"))
	var keywords: Array[String] = []
	for keyword: Variant in model.get("keywords", []):
		var value := str(keyword).strip_edges()
		if not value.is_empty() and value not in keywords: keywords.append(value)
	if not keywords.is_empty():
		_label("KEYWORDS", 16, Color("f2df83"))
		_label(" · ".join(keywords), 14, Color("9fd1da"))
		var conditional_chapter_keywords: Array[String] = model.get("conditional_chapter_keywords", [])
		if not conditional_chapter_keywords.is_empty():
			_label("Dark Angels context grants: " + " · ".join(conditional_chapter_keywords), 13, Color("e5be79"))
	var stats := GridContainer.new()
	add_child(stats)
	fill_stats(stats, model.attributes, 6)
	if not str(model.get("conditions", "")).is_empty(): _label(str(model.conditions), 16, Color("e5be79"))
	for section: String in ["ranged", "melee"]:
		var weapons: Array = model.get(section, [])
		if weapons.is_empty(): continue
		add_child(HSeparator.new())
		_label("RANGED WEAPONS" if section == "ranged" else "MELEE WEAPONS", 17, Color("f2df83"))
		for weapon: Dictionary in weapons:
			var profile := VBoxContainer.new()
			profile.add_theme_constant_override("separation", 5)
			profile.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			add_child(profile)
			var profile_name := Label.new()
			profile_name.text = str(weapon.get("name", "Weapon profile"))
			profile_name.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			profile_name.add_theme_font_size_override("font_size", 15)
			profile_name.add_theme_color_override("font_color", Color("edf1f2"))
			profile.add_child(profile_name)
			var stats := GridContainer.new()
			stats.columns = 3
			stats.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			stats.add_theme_constant_override("h_separation", 8)
			stats.add_theme_constant_override("v_separation", 4)
			profile.add_child(stats)
			var headings := ["Range", "Attacks", "WS" if section == "melee" else "BS", "Strength", "AP", "Damage"]
			var values: Array = [weapon.get("range", "—"), weapon.get("attacks", "—"), weapon.get("skill", "—"), weapon.get("strength", "—"), weapon.get("ap", "—"), weapon.get("damage", "—")]
			for index in range(headings.size()):
				var stat := VBoxContainer.new()
				stat.add_theme_constant_override("separation", 0)
				stat.size_flags_horizontal = Control.SIZE_EXPAND_FILL
				var label := Label.new()
				label.text = str(headings[index])
				label.add_theme_font_size_override("font_size", 12)
				label.add_theme_color_override("font_color", Color("9fb2c1"))
				label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
				stat.add_child(label)
				var value := Label.new()
				value.text = str(values[index])
				value.add_theme_font_size_override("font_size", 16)
				value.add_theme_color_override("font_color", Color("edf1f2"))
				value.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
				stat.add_child(value)
				stats.add_child(stat)
			var weapon_keywords := str(weapon.get("keywords", ""))
			if not weapon_keywords.is_empty():
				var keyword_label := Label.new()
				keyword_label.text = weapon_keywords
				keyword_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
				keyword_label.add_theme_font_size_override("font_size", 14)
				keyword_label.add_theme_color_override("font_color", Color("9fd1da"))
				profile.add_child(keyword_label)
	var abilities: Array = model.get("abilities", [])
	if not abilities.is_empty():
		add_child(HSeparator.new())
		_label("IMPLEMENTED SCOPE", 17, Color("f2df83"))
		for ability: Dictionary in abilities:
			_label(str(ability.name), 17, Color("9fd1da"))
			_label(str(ability.text), 16)
	var rules: Array = model.get("ability_rules", [])
	var source := str(model.get("ability_source", ""))
	var source_issue := str(model.get("ability_source_issue", ""))
	var source_warning := str(model.get("ability_source_warning", ""))
	if not source_warning.is_empty():
		source_status_note = "incomplete"
	elif not source_issue.is_empty():
		source_status_note = "unavailable" if "not installed" in source_issue.to_lower() else "error"
	if not rules.is_empty() or not source.is_empty() or not source_issue.is_empty() or not source_warning.is_empty():
		if (not source_issue.is_empty() or not source_warning.is_empty()) and not source_expansion_user_set:
			source_expanded = true
		add_child(HSeparator.new())
		_label("SOURCE RULES", 17, Color("f2df83"))
		source_rule_count = rules.size()
		source_toggle_button = Button.new()
		source_toggle_button.toggle_mode = true
		source_toggle_button.button_pressed = source_expanded
		source_toggle_button.text = _source_toggle_text(source_rule_count, source_expanded)
		source_toggle_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		source_toggle_button.tooltip_text = "Show optional local reference text and status. This does not change the match."
		add_child(source_toggle_button)
		source_content = VBoxContainer.new()
		source_content.add_theme_constant_override("separation", 8)
		source_content.visible = source_expanded
		add_child(source_content)
		source_toggle_button.toggled.connect(func(expanded: bool) -> void:
			source_expanded = expanded
			source_expansion_user_set = true
			source_content.visible = expanded
			source_toggle_button.text = _source_toggle_text(source_rule_count, expanded)
		)
		_label_in(source_content, "Source text is informational; it does not establish runtime support. See Implemented Scope when listed.", 13, Color("9fb2c1"))
		if not source.is_empty(): _label_in(source_content, source, 13, Color("9fb2c1"))
		if not source_issue.is_empty(): _label_in(source_content, source_issue, 14, Color("e5be79"))
		if not source_warning.is_empty(): _label_in(source_content, source_warning, 14, Color("e5be79"))
		if not rules.is_empty():
			for rule: Dictionary in rules:
				_label_in(source_content, str(rule.name), 18, Color("9fd1da"))
				var context: Array[String] = []
				for key: String in ["type", "model", "parameter"]:
					if not str(rule.get(key, "")).is_empty(): context.append(str(rule[key]))
				if not context.is_empty(): _label_in(source_content, " · ".join(context), 13, Color("9fb2c1"))
				_label_in(source_content, str(rule.text) if not str(rule.text).is_empty() else "Rule text is missing from this local export.", 16)
		elif source.is_empty():
			_label_in(source_content, "Copy a verified snapshot into user://rules/wahapedia/11e/space-marines/<snapshot-id>. Cross-file gaps appear as an incomplete-export warning.", 13, Color("9fb2c1"))
		var source_actions := VBoxContainer.new()
		source_actions.add_theme_constant_override("separation", 8)
		var open_folder := Button.new()
		open_folder.text = "Open local reference folder"
		open_folder.custom_minimum_size.y = 38
		open_folder.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		open_folder.tooltip_text = "Open the optional local Wahapedia snapshot folder. No data is downloaded."
		open_folder.pressed.connect(func(): reference_folder_requested.emit())
		source_actions.add_child(open_folder)
		var reload_reference := Button.new()
		reload_reference.text = "Reload local reference"
		reload_reference.custom_minimum_size.y = 38
		reload_reference.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		reload_reference.tooltip_text = "Revalidate and read the local snapshot again. This does not change the match."
		reload_reference.pressed.connect(func(): reference_reload_requested.emit())
		source_actions.add_child(reload_reference)
		reference_folder_copy_button = Button.new()
		reference_folder_copy_button.text = "Copy local reference folder path"
		reference_folder_copy_button.custom_minimum_size.y = 38
		reference_folder_copy_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		reference_folder_copy_button.tooltip_text = "Copy the user-data folder path so you can open or paste it manually."
		reference_folder_copy_button.visible = false
		reference_folder_copy_button.pressed.connect(func(): reference_folder_copy_requested.emit())
		source_actions.add_child(reference_folder_copy_button)
		source_content.add_child(source_actions)
		reference_folder_status = Label.new()
		reference_folder_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		reference_folder_status.add_theme_font_size_override("font_size", 13)
		reference_folder_status.add_theme_color_override("font_color", Color("9fb2c1"))
		reference_folder_status.visible = false
		source_content.add_child(reference_folder_status)
	_label("Match profile · effects depend on this match's supported rules and settings.", 13, Color("9fb2c1"))

func set_reference_folder_status(message: String, offer_path_copy: bool = false) -> void:
	if reference_folder_copy_button != null:
		reference_folder_copy_button.visible = offer_path_copy
	if reference_folder_status != null:
		reference_folder_status.text = message
		reference_folder_status.visible = not message.is_empty()
		if not message.is_empty():
			source_expanded = true
			source_expansion_user_set = true
			if source_content != null: source_content.visible = true
			if source_toggle_button != null:
				source_toggle_button.button_pressed = true
				source_toggle_button.text = _source_toggle_text(source_rule_count, true)

func _label(text: String, font_size: int, color := Color("edf1f2")) -> void:
	_label_in(self, text, font_size, color)

func _label_in(parent: Node, text: String, font_size: int, color := Color("edf1f2")) -> Label:
	var label := Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	parent.add_child(label)
	return label

func _source_profile_key(model: Dictionary) -> String:
	var identity := str(model.get("identity", ""))
	var separator := identity.find(" · ")
	var stable_identity := identity.substr(0, separator) if separator >= 0 else identity
	return "%s::%s" % [str(model.get("name", "")), stable_identity]

func _source_toggle_text(rule_count: int, expanded: bool) -> String:
	var section_name := "source status"
	if rule_count > 0:
		section_name = "source reference (%d)" % rule_count
	if not source_status_note.is_empty(): section_name += " · " + source_status_note
	return ("Hide " if expanded else "Show ") + section_name
