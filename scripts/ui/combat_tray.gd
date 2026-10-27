extends PanelContainer
## Read-only combat presentation. Skip/replay/speed never submit gameplay commands.
const AttackFeedback = preload("res://scripts/ui/attack_feedback.gd")
const DicePipFace = preload("res://scripts/ui/dice_pip_face.gd")
const Attacks = preload("res://scripts/edition_11/attack_sequence.gd")
var heading := Label.new()
var context_label := Label.new()
var stage_label := Label.new()
var stage_icon = preload("res://scripts/ui/combat_symbol.gd").new()
var dice := HFlowContainer.new()
var summary := Label.new()
var die_detail := Label.new()
var skip := Button.new()
var replay := Button.new()
var speed := OptionButton.new()
var stages := OptionButton.new()
var sequence: Tween
var signature := ""
var observed := false
var groups: Array[Dictionary] = []
var final_text := ""
var animation_enabled := true
var current_group := -1
var stage_row := HBoxContainer.new()
var dice_scroll := ScrollContainer.new()
var die_detail_panel := PanelContainer.new()
var die_detail_content := VBoxContainer.new()
var die_detail_heading := Label.new()
var die_detail_scroll := ScrollContainer.new()
var expand_button := Button.new()
var focused_die_button: Button
var expanded := true
var collapse_when_settled := false
var sound := AudioStreamPlayer.new()
var sound_enabled := true

func _ready() -> void:
	add_child(sound)
	sound.volume_db = -20
	# Original short UI cue; no samples, third-party content or gameplay RNG.
	var wave := AudioStreamWAV.new()
	wave.format = AudioStreamWAV.FORMAT_16_BITS
	wave.mix_rate = 22050
	var samples := PackedByteArray()
	samples.resize(1764 * 2)
	for index in 1764:
		var time := float(index) / wave.mix_rate
		var amplitude := sin(TAU * (340.0 * time - 900.0 * time * time)) * exp(-time * 65.0)
		samples.encode_s16(index * 2, int(amplitude * 18000))
	wave.data = samples
	sound.stream = wave
	var style := StyleBoxFlat.new()
	style.bg_color = Color("101a22", 0.98)
	style.border_color = Color("d9aa4f")
	style.set_border_width_all(1)
	style.set_corner_radius_all(8)
	style.content_margin_left = 14
	style.content_margin_right = 14
	style.content_margin_top = 10
	style.content_margin_bottom = 10
	add_theme_stylebox_override("panel", style)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 5)
	add_child(column)
	heading.add_theme_font_size_override("font_size", 18)
	heading.add_theme_color_override("font_color", Color("f2df83"))
	var title_row := HBoxContainer.new()
	heading.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_row.add_child(heading)
	expand_button.text = "Hide dice"
	expand_button.pressed.connect(func(): _set_expanded(not expanded))
	title_row.add_child(expand_button)
	column.add_child(title_row)
	context_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	context_label.max_lines_visible = 2
	context_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	context_label.add_theme_font_size_override("font_size", 15)
	column.add_child(context_label)
	var detail_column := VBoxContainer.new()
	detail_column.add_theme_constant_override("separation", 5)
	stages.fit_to_longest_item = false
	stages.item_selected.connect(func(index: int):
		collapse_when_settled = false
		finish()
		_set_expanded(true)
		_show_group(index, true)
	)
	detail_column.add_child(stages)
	stage_label.add_theme_font_size_override("font_size", 17)
	stage_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	stage_label.max_lines_visible = 3
	stage_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	stage_row.add_child(stage_icon)
	stage_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	stage_row.add_child(stage_label)
	detail_column.add_child(stage_row)
	dice_scroll.custom_minimum_size.y = 72
	dice_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	dice_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	dice_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	column.add_child(dice_scroll)
	dice_scroll.add_child(detail_column)
	dice.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	dice.add_theme_constant_override("h_separation", 6)
	dice.add_theme_constant_override("v_separation", 6)
	detail_column.add_child(dice)
	die_detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	# Keep long per-die descriptions in their own bounded scroll area.
	die_detail.max_lines_visible = -1
	die_detail.add_theme_font_size_override("font_size", 13)
	die_detail.add_theme_color_override("font_color", Color("d4e0e4"))
	die_detail.visible = false
	die_detail.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	die_detail_heading.text = "SELECTED DIE · Press Enter/Accept to read; use arrows or Page Up/Down; Esc returns."
	die_detail_heading.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	die_detail_heading.add_theme_font_size_override("font_size", 12)
	die_detail_heading.add_theme_color_override("font_color", Color("9fb2c1"))
	var die_detail_style := StyleBoxFlat.new()
	die_detail_style.bg_color = Color("17232b")
	die_detail_style.border_color = Color("536874")
	die_detail_style.set_border_width_all(1)
	die_detail_style.set_corner_radius_all(4)
	die_detail_panel.add_theme_stylebox_override("panel", die_detail_style)
	die_detail_content.add_theme_constant_override("separation", 3)
	die_detail_panel.add_child(die_detail_content)
	die_detail_content.add_child(die_detail_heading)
	die_detail_panel.visible = false
	die_detail_scroll.custom_minimum_size.y = 56
	die_detail_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	die_detail_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	die_detail_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	die_detail_scroll.focus_mode = Control.FOCUS_ALL
	die_detail_scroll.tooltip_text = "Focus this area, then use Up/Down, Page Up/Down, Home or End to read the full result."
	die_detail_scroll.gui_input.connect(_handle_die_detail_scroll_input)
	die_detail_scroll.focus_entered.connect(func(): die_detail_style.border_color = Color("f2df83"))
	die_detail_scroll.focus_exited.connect(func(): die_detail_style.border_color = Color("536874"))
	die_detail_scroll.visible = false
	die_detail_content.add_child(die_detail_scroll)
	column.add_child(die_detail_panel)
	die_detail_scroll.add_child(die_detail)
	summary.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	summary.add_theme_font_size_override("font_size", 15)
	summary.max_lines_visible = 4
	summary.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	column.add_child(summary)
	var controls := HFlowContainer.new()
	column.add_child(controls)
	for option: String in ["Normal", "Fast", "Reduced motion"]: speed.add_item(option)
	speed.tooltip_text = "Presentation speed only. Every rules decision still requires its owner's choice."
	speed.item_selected.connect(func(_index: int): finish())
	controls.add_child(speed)
	skip.text = "Skip animation"
	skip.tooltip_text = "Finish this presentation now. The recorded result and any pending decision remain unchanged."
	skip.pressed.connect(finish)
	controls.add_child(skip)
	replay.text = "Replay recorded dice"
	replay.tooltip_text = "Show the already recorded dice and result again. This does not reroll or change the match."
	replay.pressed.connect(func(): play())
	controls.add_child(replay)
	visible = false

func reset() -> void:
	if sequence != null: sequence.kill()
	signature = ""
	observed = false
	visible = false
	stages.disabled = false
	groups.clear()

func sync(state: Dictionary, window: Dictionary, enabled: bool, presenting: bool) -> void:
	animation_enabled = enabled
	var last: Dictionary = state.get("last_attack", {})
	var pending_roll: bool = not window.is_empty() and window.get("kind", "") != "before_battle_shock"
	var allocation: Dictionary = state.get("pending_attack", {}).get("current", {})
	var next_key := ""
	if pending_roll: next_key = "roll:" + str(hash(var_to_str(window)))
	elif not allocation.is_empty(): next_key = "allocation:" + str(hash(var_to_str(allocation)))
	elif not last.is_empty(): next_key = "completed:" + AttackFeedback.record_key(state)
	visible = presenting and not next_key.is_empty()
	if next_key.is_empty():
		observed = true
		signature = ""
		if sequence != null: sequence.kill()
		stages.disabled = false
		groups.clear()
		return
	if next_key == signature:
		if not enabled and sequence != null and sequence.is_running(): finish()
		return
	var animate := observed and not signature.is_empty()
	var followed_decision := signature.begins_with("roll:") or signature.begins_with("allocation:")
	# The first action after an empty baseline is animated; restored state is stable.
	if observed and signature.is_empty(): animate = true
	observed = true
	signature = next_key
	if sequence != null: sequence.kill()
	groups.clear()
	if next_key.is_empty(): return
	if pending_roll:
		var names := {"after_hit_roll": "Hits", "after_wound_roll": "Wounds", "after_save_roll": "Saves", "after_damage_roll": "Damage", "after_attack_count_roll": "Attack count", "after_hazardous_roll": "Hazardous", "after_transport_hazard_roll": "Transport Hazard", "after_escape_roll": "Escape hazards", "after_advance_roll": "Advance", "after_charge_roll": "Charge"}
		heading.text = "Player %d decides" % int(window.get("player", 0))
		context_label.text = "Recorded roll · optional re-roll in Command"
		var squad := int(window.get("squad", -1))
		if state.get("squads", {}).has(squad): context_label.text = str(state.squads[squad].name)
		var current: Dictionary = state.get("pending_attack", {}).get("current", {})
		var attack_state: Dictionary = state.get("pending_attack", {})
		var roll_result: Dictionary = current.get("result", {})
		var checkpoint: Dictionary = current.get("checkpoint", {})
		var note := "Inspect the dice, then keep or re-roll in Command."
		if window.kind == "after_hit_roll" and roll_result.has("effective_skill"): note = "Skill %d+ · modifier %+d" % [int(roll_result.effective_skill), int(roll_result.get("hit_modifier", 0))]
		elif window.kind == "after_wound_roll" and roll_result.has("wound_target"): note = "Target %d+ · modifier %+d" % [int(roll_result.wound_target), int(roll_result.get("wound_modifier", 0))]
		if window.kind == "after_hit_roll" and checkpoint.has("effective_skill"):
			note = "Skill %d+ · modifier %+d" % [int(checkpoint.effective_skill), int(checkpoint.get("hit_modifier", 0))]
			roll_result = {"effective_skill": checkpoint.effective_skill, "hit_modifier": checkpoint.get("hit_modifier", 0), "snap_shooting": checkpoint.get("context", {}).get("snap_shooting", false), "snap_hit_threshold": checkpoint.get("context", {}).get("snap_hit_threshold", 6), "plunging_fire": checkpoint.get("context", {}).get("plunging_fire", false)}
		elif window.kind == "after_wound_roll" and checkpoint.has("weapon") and checkpoint.has("defender"):
			note = "Base target %d+ · modifier %+d" % [Attacks.wound_target(int(checkpoint.weapon.strength), int(checkpoint.defender.toughness)), int(checkpoint.get("context", {}).get("wound_modifier", 0))]
		elif window.kind == "after_attack_count_roll": note = "%s → %d attacks" % [str(window.get("expression", "Attack count")), int(window.get("total", 0))]
		elif window.kind == "after_damage_roll": note = "%s = %d damage before prevention" % [str(window.get("expression", "Damage")), int(window.get("value", 0))]
		elif window.kind == "after_transport_hazard_roll":
			var transport_window: Dictionary = state.get("unit_abilities", {}).get("transport_window", {})
			note = "%d mortal wounds currently pending before allocation." % int(transport_window.get("hazard_total", 0))
		if window.kind == "after_hit_roll" and bool(roll_result.get("snap_shooting", false)): note += " · Snap Shooting: unmodified %d+" % int(roll_result.get("snap_hit_threshold", 6))
		if window.kind == "after_hit_roll" and bool(roll_result.get("plunging_fire", false)): note += " · Plunging Fire: BS +1"
		var weapon: Dictionary = current.get("weapon", checkpoint.get("weapon", {}))
		var context_squad := squad
		if not attack_state.is_empty() and not current.is_empty(): context_squad = int(attack_state.get("squad", squad))
		context_label.text = str(state.squads.get(context_squad, {}).get("name", "Player %d" % int(window.get("player", 0))))
		if not weapon.is_empty():
			context_label.text += " · " + str(weapon.get("name", "Weapon"))
			var target_squad := int(current.get("target", window.get("target", -1)))
			context_label.text += " → " + str(state.squads.get(target_squad, {}).get("name", "Target"))
		groups.append({"name": names.get(str(window.kind), "Dice"), "rolls": window.get("rolls", []).duplicate(), "note": note, "pool": roll_result.duplicate(true), "decision_pending": true, "damage_expression": str(window.get("expression", "")), "damage_value": int(window.get("value", -1))})
		final_text = "Keep result · 0 CP. Re-rolling is optional."
		if window.kind == "after_save_roll": final_text = "Saves await confirmation. Keep result · 0 CP, or re-roll."
	elif not allocation.is_empty():
		animate = false
		heading.text = "Attack in progress"
		context_label.text = str(state.squads.get(allocation.get("target", -1), {}).get("name", "Defending unit"))
		if allocation.has("weapon"): context_label.text = str(allocation.weapon.get("name", "Weapon")) + " → " + context_label.text
		var result: Dictionary = allocation.get("result", {})
		_add_pool(result)
		final_text = "Resolve the highlighted decision in Command."
		if allocation.get("phase", "") in ["damage", "damage_decision", "damage_ability"]:
			var cursor := int(allocation.get("cursor", 0))
			var steps: Array = allocation.get("steps", [])
			if cursor < steps.size() and steps[cursor].get("kind", "") == "normal":
				for group: Dictionary in groups:
					if group.name == "Saves": group.note = "Save failed · AP %+d · allocation required" % int(allocation.get("weapon", {}).get("ap", 0))
				final_text = "Save failed · choose a recipient in Command."
				if allocation.get("phase", "") != "damage": final_text = "Save failed · confirm the damage decision in Command."
				final_text += "\n%d damage applied so far; this attack's damage is still pending." % int(result.get("damage_applied", 0))
	else:
		heading.text = "Attack resolved"
		var weapons: Array[String] = []
		var damage := 0
		var destroyed := 0
		var passed := 0
		var failed := 0
		var saves_recorded := false
		var unallocated := 0
		var attackers: Array[String] = []
		var units: Dictionary = state.get("units", {})
		for assignment: Dictionary in last.get("assignments", []):
			var model_id := int(assignment.get("model", -1))
			if not units.has(model_id): continue
			var attacker_squad := int(units[model_id].get("squad", -1))
			var attacker_name := str(state.squads.get(attacker_squad, {}).get("name", ""))
			if not attacker_name.is_empty() and attacker_name not in attackers: attackers.append(attacker_name)
		for pool: Dictionary in last.get("pools", []):
			var weapon := str(pool.get("weapon_name", "Weapon"))
			var target := str(state.squads.get(pool.get("target_squad", -1), {}).get("name", "Target"))
			var description := weapon + " → " + target
			if description not in weapons: weapons.append(description)
			_add_pool(pool)
			damage += int(pool.get("damage_applied", 0))
			destroyed += int(pool.get("models_destroyed", 0))
			if pool.has("saves_passed"):
				saves_recorded = true
				passed += int(pool.saves_passed)
				failed += int(pool.get("unsaved", 0))
				unallocated += maxi(0, pool.get("save_rolls", []).size() - int(pool.saves_passed) - int(pool.get("unsaved", 0)))
		context_label.text = " · ".join(weapons)
		if not attackers.is_empty():
			var source_label := "Attacker" if attackers.size() == 1 else "Attackers"
			var source_text := "%s: %s" % [source_label, ", ".join(attackers)]
			context_label.text = source_text if context_label.text.is_empty() else source_text + "\n" + context_label.text
		final_text = "%d damage applied · %d models destroyed" % [damage, destroyed]
		if saves_recorded and passed + failed > 0:
			var save_text := "Saves: %d passed · %d failed" % [passed, failed]
			if unallocated > 0: save_text += " · %d not allocated" % unallocated
			final_text = save_text + "\n" + final_text
			if passed > 0 and failed == 0 and damage == 0 and unallocated == 0: final_text = "Saved · no damage applied\n" + save_text
		var hazard: Dictionary = last.get("hazardous", {})
		if not hazard.get("rolls", []).is_empty():
			groups.append({"name": "Hazardous", "rolls": hazard.rolls.duplicate(), "note": "%d mortal wounds generated against the attacking unit" % int(hazard.get("total", 0))})
			final_text += "\nHazardous: %d mortal wounds generated" % int(hazard.get("total", 0))
		for prevention: Dictionary in hazard.get("prevention", []): _add_prevention_group(prevention)
	if groups.is_empty(): groups.append({"name": "No dice to reveal", "rolls": [], "note": "Follow the current decision in Command."})
	collapse_when_settled = not pending_roll and allocation.is_empty()
	_set_expanded(true)
	stages.clear()
	for index: int in groups.size(): stages.add_item("%d · %s" % [index + 1, groups[index].name])
	context_label.tooltip_text = context_label.text
	if animate and presenting: play(groups.size() - 1 if followed_decision and not pending_roll else 0, collapse_when_settled)
	else: finish()

func _add_pool(pool: Dictionary) -> void:
	for spec: Array in [["Hits", "final_hit_rolls", "hit_rolls"], ["Wounds", "final_wound_rolls", "wound_rolls"], ["Saves", "save_rolls", "save_rolls"]]:
		var rolls: Array = pool.get(spec[1], pool.get(spec[2], []))
		if rolls.is_empty(): continue
		var note := "Recorded results"
		if spec[0] == "Hits" and pool.has("effective_skill"):
			note = "Skill %d+ · modifier %+d" % [int(pool.effective_skill), int(pool.get("hit_modifier", 0))]
			if bool(pool.get("snap_shooting", false)): note += " · Snap Shooting: unmodified %d+" % int(pool.get("snap_hit_threshold", 6))
			if bool(pool.get("plunging_fire", false)): note += " · Plunging Fire: BS +1"
		elif spec[0] == "Wounds" and pool.has("wound_target"): note = "Target %d+ · modifier %+d" % [int(pool.wound_target), int(pool.get("wound_modifier", 0))]
		elif spec[0] == "Saves" and pool.has("saves_passed"):
			note = "%d passed · %d failed and allocated" % [int(pool.saves_passed), int(pool.get("unsaved", 0))]
		var outcome_key := "hit_outcomes" if spec[0] == "Hits" else "wound_outcomes" if spec[0] == "Wounds" else "save_outcomes"
		groups.append({"name": spec[0], "rolls": rolls.duplicate(), "outcomes": pool.get(outcome_key, []).duplicate(true), "outcome_data_present": pool.has(outcome_key), "note": note, "pool": pool.duplicate(true)})
	var damage_dice: Array = []
	var damage_values: Array[String] = []
	var damage_details: Array[Dictionary] = []
	var allocations: Array = pool.get("allocations", [])
	for record: Dictionary in pool.get("damage_rolls", []):
		var record_rolls: Array = record.get("rolls", [])
		damage_dice.append_array(record_rolls)
		damage_values.append(str(record.get("value", 0)))
		var packet_index := damage_values.size()
		var allocation: Dictionary = allocations[packet_index - 1] if packet_index <= allocations.size() else {}
		for _die_index in range(record_rolls.size()):
			var detail := {"packet": packet_index, "expression": str(record.get("expression", "Damage")), "value": int(record.get("value", 0))}
			if not allocation.is_empty():
				var prevention: Dictionary = allocation.get("prevention", {})
				detail.applied = int(allocation.get("damage", 0))
				detail.prevented = int(prevention.get("prevented", 0))
				detail.discarded = int(allocation.get("discarded", 0))
			damage_details.append(detail)
	if not damage_values.is_empty(): groups.append({"name": "Damage", "rolls": damage_dice, "die_details": damage_details, "note": "Before prevention: " + ", ".join(damage_values)})
	for prevention: Dictionary in pool.get("prevention_rolls", []):
		_add_prevention_group(prevention)
	var retention: Array = pool.get("casualty_retention_rolls", [])
	if not retention.is_empty():
		var retention_dice: Array[int] = []
		var retention_notes: Array[String] = []
		for record: Dictionary in retention:
			retention_dice.append(int(record.get("roll", 0)))
			var outcome := "remained on the battlefield" if bool(record.get("kept", false)) else "was removed"
			retention_notes.append("%s · model %d: D6 %d %+d = %d, %s" % [str(record.get("rule_name", "Model retention")), int(record.get("model", -1)), int(record.get("roll", 0)), int(record.get("modifier", 0)), int(record.get("total", 0)), outcome])
		groups.append({"name": "Casualty retention", "rolls": retention_dice, "note": "\n".join(retention_notes)})

func _add_prevention_group(prevention: Dictionary) -> void:
	if prevention.get("rolls", []).is_empty(): return
	groups.append({"name": "Feel No Pain", "rolls": prevention.rolls.duplicate(), "outcomes": prevention.get("roll_outcomes", []).duplicate(true), "outcome_data_present": prevention.has("roll_outcomes"), "note": "%d+ · %d prevented" % [int(prevention.get("target", 0)), int(prevention.get("prevented", 0))], "pool": prevention.duplicate(true)})

func play(start_index: int = 0, collapse_after: bool = false) -> void:
	if sequence != null: sequence.kill()
	if groups.is_empty(): return
	collapse_when_settled = collapse_after
	_set_expanded(true)
	if not animation_enabled or speed.selected == 2: finish(); return
	var multiplier := 0.35 if speed.selected == 1 else 1.0
	summary.text = "Recorded dice · presentation only"
	summary.tooltip_text = summary.text
	skip.visible = true
	replay.visible = false
	stages.disabled = true
	sequence = create_tween()
	sequence.tween_interval(0.25 * multiplier)
	for index in range(start_index, groups.size()):
		if groups[index].rolls.is_empty():
			sequence.tween_callback(_show_group.bind(index, true, true))
			sequence.tween_interval(0.45 * multiplier)
			continue
		sequence.tween_callback(_show_group.bind(index, false, true))
		sequence.tween_interval(0.65 * multiplier)
		sequence.tween_callback(_show_group.bind(index, true, true))
		sequence.tween_interval(0.45 * multiplier)
	sequence.tween_callback(_settle)

func finish() -> void:
	if sequence != null: sequence.kill()
	_settle()

func _settle() -> void:
	stages.disabled = false
	if groups.is_empty(): return
	_show_group(groups.size() - 1, true)
	summary.text = final_text
	summary.tooltip_text = final_text
	skip.visible = false
	replay.visible = true
	if collapse_when_settled: _set_expanded(false)

func _set_expanded(show_dice: bool) -> void:
	expanded = show_dice
	stages.visible = expanded
	stage_row.visible = expanded
	dice_scroll.visible = expanded
	die_detail_scroll.visible = expanded and not die_detail.text.is_empty()
	die_detail.visible = die_detail_scroll.visible
	die_detail_panel.visible = die_detail_scroll.visible
	expand_button.text = "Hide dice" if expanded else "Show dice"

func _show_group(index: int, reveal: bool, animate_faces: bool = false) -> void:
	current_group = index
	stages.select(index)
	# A new stage begins with its selector, label and first results in view.
	dice_scroll.scroll_vertical = 0
	if die_detail_scroll.has_focus(): expand_button.grab_focus()
	focused_die_button = null
	for child in dice.get_children(): child.free()
	die_detail.text = ""
	die_detail.visible = false
	die_detail_scroll.visible = false
	die_detail_panel.visible = false
	var group: Dictionary = groups[index]
	if reveal and sound_enabled and sequence != null and sequence.is_running(): sound.play()
	stage_icon.kind = str(group.name)
	var count_note := " · %d D6" % group.rolls.size() if not group.rolls.is_empty() else (" · fixed result" if group.name == "Damage" else "")
	stage_label.text = "%s%s\n%s" % [group.name, count_note, group.note if reveal else "Revealing recorded dice…"]
	stage_label.tooltip_text = str(group.note)
	var rolls: Array = group.rolls
	var successful := 0
	var classified := 0
	var outcomes: Array = group.get("outcomes", [])
	var save_thresholds: Array[String] = []
	for die_index in range(rolls.size()):
		var value: int = int(rolls[die_index])
		var face := Button.new()
		face.custom_minimum_size = Vector2(46, 52)
		face.focus_mode = Control.FOCUS_ALL
		var contents := VBoxContainer.new()
		contents.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		contents.offset_left = 3
		contents.offset_top = 2
		contents.offset_right = -3
		contents.offset_bottom = -2
		contents.mouse_filter = Control.MOUSE_FILTER_IGNORE
		contents.add_theme_constant_override("separation", 0)
		contents.alignment = BoxContainer.ALIGNMENT_CENTER
		var face_text := Label.new()
		face_text.text = str(value) if reveal else "·"
		face_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		face_text.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		face_text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		face_text.add_theme_font_size_override("font_size", 20)
		face_text.add_theme_color_override("font_color", Color("f2eee0"))
		face_text.mouse_filter = Control.MOUSE_FILTER_IGNORE
		contents.add_child(face_text)
		var pips := DicePipFace.new()
		pips.value = value if reveal else 0
		pips.custom_minimum_size = Vector2(20, 20)
		pips.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		pips.visible = reveal
		contents.add_child(pips)
		face.add_child(contents)
		var die_style := StyleBoxFlat.new()
		die_style.bg_color = Color("263540")
		die_style.border_color = Color("82939d")
		die_style.set_border_width_all(1)
		die_style.set_corner_radius_all(5)
		die_style.content_margin_left = 4
		die_style.content_margin_right = 4
		face.add_theme_stylebox_override("normal", die_style)
		face.add_theme_stylebox_override("pressed", die_style)
		var hover_style := die_style.duplicate() as StyleBoxFlat
		hover_style.border_color = Color("c4d4dc")
		hover_style.set_border_width_all(2)
		face.add_theme_stylebox_override("hover", hover_style)
		var focus_style := die_style.duplicate() as StyleBoxFlat
		focus_style.border_color = Color("f2df83")
		focus_style.set_border_width_all(3)
		face.add_theme_stylebox_override("focus", focus_style)
		var inspection := _die_inspection_text(group, die_index, value) if reveal else "Recorded die · awaiting reveal."
		face.tooltip_text = inspection
		if reveal:
			face.focus_entered.connect(_on_die_button_focus.bind(face, inspection))
			face.pressed.connect(_focus_die_detail.bind(inspection, face))
		if reveal and die_index < outcomes.size() and outcomes[die_index] is Dictionary:
			var outcome: Dictionary = outcomes[die_index]
			if int(outcome.get("roll", -1)) == value:
				var passed: bool = outcome.get("success", false)
				var critical: bool = outcome.get("critical", false)
				if passed: successful += 1
				classified += 1
				face_text.text += "★" if critical else ("✓" if passed else "×")
				face_text.add_theme_color_override("font_color", Color("f2df83") if critical else (Color("96dfb3") if passed else Color("f2a59b")))
				if group.name == "Saves":
					var save_text := "Save roll %d %s" % [value, "passed" if passed else "failed"]
					if outcome.has("armour_target"):
						var armour_note := "Armour %d+ after AP %+d" % [int(outcome.armour_target), int(outcome.get("ap", 0))]
						if int(outcome.get("bonus", 0)) != 0: armour_note += " and save modifier %+d" % int(outcome.bonus)
						save_text += " · " + armour_note + " · an unmodified 1 always fails"
						var invulnerable_target := int(outcome.get("invulnerable_target", 0))
						if invulnerable_target > 0:
							save_text += " or Invulnerable %d+" % invulnerable_target
						var threshold_note := armour_note
						if invulnerable_target > 0: threshold_note += " or Invulnerable %d+" % invulnerable_target
						if threshold_note not in save_thresholds: save_thresholds.append(threshold_note)
					face.tooltip_text = save_text
		dice.add_child(face)
		if animate_faces and animation_enabled and speed.selected != 2:
			face.pivot_offset = Vector2(23, 26)
			if reveal:
				face.scale = Vector2(0.84, 0.84)
				face.create_tween().tween_property(face, "scale", Vector2.ONE, 0.24).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
			else:
				face.modulate.a = 0.45
				var pulse := face.create_tween().set_loops()
				pulse.tween_property(face, "modulate:a", 1.0, 0.2)
				pulse.tween_property(face, "modulate:a", 0.45, 0.2)
	if reveal and group.name == "Hits" and classified > 0: stage_label.text += " · %d/%d successful hits" % [successful, classified]
	if reveal and group.name == "Wounds" and classified > 0:
		stage_label.text += " · %d/%d successful wound rolls · %d wounds total" % [successful, classified, int(group.get("pool", {}).get("wounds", 0))]
	if reveal and group.name == "Saves" and classified > 0:
		stage_label.text += " · %d/%d resolved · %d passed · %d failed" % [classified, rolls.size(), successful, classified - successful]
		if not save_thresholds.is_empty(): stage_label.text += " · " + "; ".join(save_thresholds)
		stage_label.tooltip_text += "\n" + "; ".join(save_thresholds) + "\nAn unmodified 1 always fails."
	if reveal and group.name == "Feel No Pain" and classified > 0:
		stage_label.text += " · %d/%d wounds prevented" % [successful, classified]
	if rolls.is_empty():
		var fixed := Label.new()
		fixed.text = "Fixed value · no roll" if group.name == "Damage" else "No recorded dice at this step"
		dice.add_child(fixed)

func _show_die_detail(description: String) -> void:
	die_detail.text = description
	die_detail_scroll.scroll_vertical = 0
	die_detail_scroll.visible = expanded and not description.is_empty()
	die_detail.visible = die_detail_scroll.visible
	die_detail_panel.visible = die_detail_scroll.visible

func _on_die_button_focus(button: Button, description: String) -> void:
	focused_die_button = button
	_show_die_detail(description)

func _focus_die_detail(description: String, source_button: Button) -> void:
	focused_die_button = source_button
	_show_die_detail(description)
	if die_detail_scroll.visible: die_detail_scroll.grab_focus()

func _handle_die_detail_scroll_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if is_instance_valid(focused_die_button) and focused_die_button.is_visible_in_tree():
			focused_die_button.grab_focus()
		else:
			expand_button.grab_focus()
		die_detail_scroll.accept_event()
		return
	var scroll_delta := 0
	var page_size := maxi(24, int(die_detail_scroll.size.y * 0.75))
	if event.is_action_pressed("ui_up"):
		scroll_delta = -24
	elif event.is_action_pressed("ui_down"):
		scroll_delta = 24
	elif event is InputEventKey:
		var key_event := event as InputEventKey
		if not key_event.pressed or key_event.echo: return
		match key_event.keycode:
			KEY_PAGEUP: scroll_delta = -page_size
			KEY_PAGEDOWN: scroll_delta = page_size
			KEY_HOME: die_detail_scroll.scroll_vertical = 0
			KEY_END:
				var scroll_bar := die_detail_scroll.get_v_scroll_bar()
				die_detail_scroll.scroll_vertical = maxi(0, int(scroll_bar.max_value - scroll_bar.page))
			_: return
	else:
		return
	if scroll_delta != 0:
		die_detail_scroll.scroll_vertical = maxi(0, die_detail_scroll.scroll_vertical + scroll_delta)
	die_detail_scroll.accept_event()

func _die_inspection_text(group: Dictionary, index: int, value: int) -> String:
	var rolls: Array = group.get("rolls", [])
	var description := "%s · die %d of %d · D6: %d" % [str(group.get("name", "Dice")), index + 1, rolls.size(), value]
	var pool: Dictionary = group.get("pool", {})
	var outcomes: Array = group.get("outcomes", [])
	var has_outcome := index < outcomes.size() and outcomes[index] is Dictionary and int(outcomes[index].get("roll", -1)) == value
	if has_outcome:
		var outcome: Dictionary = outcomes[index]
		var result := "critical success" if outcome.get("critical", false) else ("success" if outcome.get("success", false) else "failure")
		description += "\nRecorded outcome: " + result + "."
		if group.get("name", "") == "Hits" and pool.has("effective_skill"):
			description += " Target %d+ · modifier %+d." % [int(pool.effective_skill), int(pool.get("hit_modifier", 0))]
			if bool(pool.get("snap_shooting", false)): description += " Snap Shooting requires an unmodified %d+." % int(pool.get("snap_hit_threshold", 6))
			if bool(pool.get("plunging_fire", false)): description += " Plunging Fire improved BS by 1."
		elif group.get("name", "") == "Wounds" and pool.has("wound_target"):
			description += " Target %d+ · modifier %+d." % [int(pool.wound_target), int(pool.get("wound_modifier", 0))]
		elif group.get("name", "") == "Saves" and outcome.has("armour_target"):
			var threshold := "Armour %d+ after AP %+d" % [int(outcome.armour_target), int(outcome.get("ap", 0))]
			if int(outcome.get("bonus", 0)) != 0: threshold += " and save modifier %+d" % int(outcome.bonus)
			var invulnerable_target := int(outcome.get("invulnerable_target", 0))
			if invulnerable_target > 0: threshold += " or Invulnerable %d+" % invulnerable_target
			description += " " + threshold + "; an unmodified 1 always fails."
		elif group.get("name", "") == "Feel No Pain":
			description += " Feel No Pain %d+: a successful roll prevents one wound." % int(pool.get("target", 0))
	elif group.get("name", "") == "Damage":
		var damage_details: Array = group.get("die_details", [])
		if index < damage_details.size():
			var damage_detail: Dictionary = damage_details[index]
			description += "\nDamage packet %d · %s = %d before prevention." % [int(damage_detail.get("packet", 0)), str(damage_detail.get("expression", "Damage")), int(damage_detail.get("value", 0))]
			if damage_detail.has("applied"):
				description += " Applied %d wounds; %d prevented; %d excess discarded." % [int(damage_detail.applied), int(damage_detail.prevented), int(damage_detail.discarded)]
		elif int(group.get("damage_value", -1)) >= 0:
			description += "\nDamage %s = %d before prevention." % [str(group.get("damage_expression", "Damage")), int(group.damage_value)]
		else:
			description += "\nRecorded damage-stage face; no pass/fail classification applies."
	elif group.get("name", "") == "Saves":
		if group.get("decision_pending", false): description += "\nSave outcomes are finalized after this reroll decision and allocation."
		elif group.get("outcome_data_present", false): description += "\nThis save has not been processed yet."
		else: description += "\nNo per-die save outcome was stored with this older result."
	elif group.get("name", "") in ["Hits", "Wounds"]:
		if group.get("decision_pending", false): description += "\nStage outcomes are finalized after this reroll decision."
		elif group.get("outcome_data_present", false): description += "\nNo matching per-die outcome record is available for this face."
		else: description += "\nNo per-die outcome was stored with this older result."
	elif group.get("name", "") == "Feel No Pain":
		if group.get("outcome_data_present", false): description += "\nNo matching per-die prevention result is available for this face."
		else: description += "\nNo per-die prevention result was stored with this older result."
		var prevention_note := str(group.get("note", ""))
		if not prevention_note.is_empty(): description += " " + prevention_note + "."
	else:
		description += "\nRaw recorded face; this stage has no pass/fail marker."
		var note := str(group.get("note", ""))
		if not note.is_empty(): description += " " + note + "."
	return description
