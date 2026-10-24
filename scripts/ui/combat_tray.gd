extends PanelContainer
## Read-only combat presentation. Skip/replay/speed never submit gameplay commands.
const Attacks = preload("res://scripts/edition_11/attack_sequence.gd")
const AttackFeedback = preload("res://scripts/ui/attack_feedback.gd")
var heading := Label.new()
var context_label := Label.new()
var stage_label := Label.new()
var stage_icon = preload("res://scripts/ui/combat_symbol.gd").new()
var dice := HFlowContainer.new()
var summary := Label.new()
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
var expand_button := Button.new()
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
	stages.fit_to_longest_item = false
	stages.item_selected.connect(func(index: int):
		collapse_when_settled = false
		finish()
		_set_expanded(true)
		_show_group(index, true)
	)
	column.add_child(stages)
	stage_label.add_theme_font_size_override("font_size", 17)
	stage_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	stage_label.max_lines_visible = 3
	stage_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	stage_row.add_child(stage_icon)
	stage_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	stage_row.add_child(stage_label)
	column.add_child(stage_row)
	var scroll := dice_scroll
	scroll.custom_minimum_size.y = 64
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	column.add_child(scroll)
	dice.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	dice.add_theme_constant_override("h_separation", 6)
	dice.add_theme_constant_override("v_separation", 6)
	scroll.add_child(dice)
	summary.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	summary.add_theme_font_size_override("font_size", 15)
	column.add_child(summary)
	var controls := HFlowContainer.new()
	column.add_child(controls)
	for option: String in ["Normal", "Fast", "Reduced motion"]: speed.add_item(option)
	speed.tooltip_text = "Presentation speed only. Every rules decision still requires its owner's choice."
	speed.item_selected.connect(func(_index: int): finish())
	controls.add_child(speed)
	skip.text = "Skip animation"
	skip.pressed.connect(finish)
	controls.add_child(skip)
	replay.text = "Replay recorded dice"
	replay.pressed.connect(func(): play())
	controls.add_child(replay)
	visible = false

func reset() -> void:
	if sequence != null: sequence.kill()
	signature = ""
	observed = false
	visible = false
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
		var names := {"after_hit_roll": "Hits", "after_wound_roll": "Wounds", "after_save_roll": "Saves", "after_damage_roll": "Damage", "after_attack_count_roll": "Attack count", "after_hazardous_roll": "Hazardous", "after_escape_roll": "Escape hazards", "after_advance_roll": "Advance", "after_charge_roll": "Charge"}
		heading.text = "Player %d decides" % int(window.get("player", 0))
		context_label.text = "Recorded roll · optional re-roll in Command"
		var squad := int(window.get("squad", -1))
		if state.get("squads", {}).has(squad): context_label.text = str(state.squads[squad].name)
		var current: Dictionary = state.get("pending_attack", {}).get("current", {})
		var roll_result: Dictionary = current.get("result", {})
		var checkpoint: Dictionary = current.get("checkpoint", {})
		var note := "Inspect the dice, then keep or re-roll in Command."
		if window.kind == "after_hit_roll" and roll_result.has("effective_skill"): note = "Skill %d+ · modifier %+d" % [int(roll_result.effective_skill), int(roll_result.get("hit_modifier", 0))]
		elif window.kind == "after_wound_roll" and roll_result.has("wound_target"): note = "Target %d+ · modifier %+d" % [int(roll_result.wound_target), int(roll_result.get("wound_modifier", 0))]
		if window.kind == "after_hit_roll" and checkpoint.has("effective_skill"):
			note = "Skill %d+ · modifier %+d" % [int(checkpoint.effective_skill), int(checkpoint.get("hit_modifier", 0))]
			roll_result = {"effective_skill": checkpoint.effective_skill, "hit_modifier": checkpoint.get("hit_modifier", 0), "snap_shooting": checkpoint.get("context", {}).get("snap_shooting", false)}
		elif window.kind == "after_wound_roll" and checkpoint.has("weapon") and checkpoint.has("defender"):
			note = "Base target %d+ · modifier %+d" % [Attacks.wound_target(int(checkpoint.weapon.strength), int(checkpoint.defender.toughness)), int(checkpoint.get("context", {}).get("wound_modifier", 0))]
		elif window.kind == "after_attack_count_roll": note = "%s → %d attacks" % [str(window.get("expression", "Attack count")), int(window.get("total", 0))]
		elif window.kind == "after_damage_roll": note = "%s = %d damage before prevention" % [str(window.get("expression", "Damage")), int(window.get("value", 0))]
		var weapon: Dictionary = current.get("weapon", checkpoint.get("weapon", {}))
		if not weapon.is_empty():
			context_label.text += " · " + str(weapon.get("name", "Weapon"))
			context_label.text += " → " + str(state.squads.get(current.get("target", -1), {}).get("name", "Target"))
		groups.append({"name": names.get(str(window.kind), "Dice"), "rolls": window.get("rolls", []).duplicate(), "note": note, "pool": roll_result.duplicate(true)})
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
		final_text = "%d damage applied · %d models destroyed" % [damage, destroyed]
		if saves_recorded and passed + failed > 0:
			var save_text := "Saves: %d passed · %d failed" % [passed, failed]
			if unallocated > 0: save_text += " · %d not allocated" % unallocated
			final_text = save_text + "\n" + final_text
			if passed > 0 and failed == 0 and damage == 0 and unallocated == 0: final_text = "Saved · no damage applied\n" + save_text
		var hazard: Dictionary = last.get("hazardous", {})
		if not hazard.get("rolls", []).is_empty():
			groups.append({"name": "Hazardous", "rolls": hazard.rolls.duplicate(), "note": "%d mortal wounds generated against the attacking unit" % int(hazard.get("total", 0))})
			final_text += " · Hazardous: %d mortal wounds generated" % int(hazard.get("total", 0))
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
		if spec[0] == "Hits" and pool.has("effective_skill"): note = "Skill %d+ · modifier %+d" % [int(pool.effective_skill), int(pool.get("hit_modifier", 0))]
		elif spec[0] == "Wounds" and pool.has("wound_target"): note = "Target %d+ · modifier %+d" % [int(pool.wound_target), int(pool.get("wound_modifier", 0))]
		elif spec[0] == "Saves" and pool.has("saves_passed"):
			note = "%d passed · %d failed and allocated" % [int(pool.saves_passed), int(pool.get("unsaved", 0))]
		groups.append({"name": spec[0], "rolls": rolls.duplicate(), "note": note, "pool": pool.duplicate(true)})
	var damage_dice: Array = []
	var damage_values: Array[String] = []
	for record: Dictionary in pool.get("damage_rolls", []):
		damage_dice.append_array(record.get("rolls", []))
		damage_values.append(str(record.get("value", 0)))
	if not damage_values.is_empty(): groups.append({"name": "Damage", "rolls": damage_dice, "note": "Before prevention: " + ", ".join(damage_values)})
	for prevention: Dictionary in pool.get("prevention_rolls", []):
		if not prevention.get("rolls", []).is_empty(): groups.append({"name": "Feel No Pain", "rolls": prevention.rolls.duplicate(), "note": "%d+ · %d prevented" % [int(prevention.get("target", 0)), int(prevention.get("prevented", 0))]})

func play(start_index: int = 0, collapse_after: bool = false) -> void:
	if sequence != null: sequence.kill()
	if groups.is_empty(): return
	collapse_when_settled = collapse_after
	_set_expanded(true)
	if not animation_enabled or speed.selected == 2: finish(); return
	var multiplier := 0.35 if speed.selected == 1 else 1.0
	summary.text = "Recorded dice · presentation only"
	skip.visible = true
	replay.visible = false
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
	if groups.is_empty(): return
	_show_group(groups.size() - 1, true)
	summary.text = final_text
	skip.visible = false
	replay.visible = true
	if collapse_when_settled: _set_expanded(false)

func _set_expanded(show_dice: bool) -> void:
	expanded = show_dice
	stages.visible = expanded
	stage_row.visible = expanded
	dice_scroll.visible = expanded
	expand_button.text = "Hide dice" if expanded else "Show dice"

func _show_group(index: int, reveal: bool, animate_faces: bool = false) -> void:
	current_group = index
	stages.select(index)
	for child in dice.get_children(): child.free()
	var group: Dictionary = groups[index]
	if reveal and sound_enabled and sequence != null and sequence.is_running(): sound.play()
	stage_icon.kind = str(group.name)
	var count_note := " · %d D6" % group.rolls.size() if not group.rolls.is_empty() else (" · fixed result" if group.name == "Damage" else "")
	stage_label.text = "%s%s\n%s" % [group.name, count_note, group.note if reveal else "Revealing recorded dice…"]
	stage_label.tooltip_text = str(group.note)
	var rolls: Array = group.rolls
	var successful := 0
	for value: int in rolls:
		var face := Label.new()
		face.custom_minimum_size = Vector2(42, 44)
		face.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		face.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		face.add_theme_font_size_override("font_size", 24)
		face.text = str(value) if reveal else "·"
		face.add_theme_color_override("font_color", Color("f2eee0"))
		var die_style := StyleBoxFlat.new()
		die_style.bg_color = Color("263540")
		die_style.border_color = Color("82939d")
		die_style.set_border_width_all(1)
		die_style.set_corner_radius_all(5)
		die_style.content_margin_left = 4
		die_style.content_margin_right = 4
		face.add_theme_stylebox_override("normal", die_style)
		var pool: Dictionary = group.get("pool", {})
		if reveal and group.name == "Hits" and not pool.is_empty():
			var hit: bool = group.name == "Hits"
			var target := int(pool.get("effective_skill" if hit else "wound_target", 6))
			var modifier := int(pool.get("hit_modifier" if hit else "wound_modifier", 0))
			var passed := Attacks.successful_roll(value, target, modifier)
			if hit and pool.get("snap_shooting", false): passed = value == 6
			if passed: successful += 1
			face.text += "✓" if passed else "×"
			face.add_theme_font_size_override("font_size", 20)
			face.add_theme_color_override("font_color", Color("96dfb3") if passed else Color("f2a59b"))
		dice.add_child(face)
		if animate_faces and animation_enabled and speed.selected != 2:
			face.pivot_offset = Vector2(21, 22)
			if reveal:
				face.scale = Vector2(0.84, 0.84)
				face.create_tween().tween_property(face, "scale", Vector2.ONE, 0.24).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
			else:
				face.modulate.a = 0.45
				var pulse := face.create_tween().set_loops()
				pulse.tween_property(face, "modulate:a", 1.0, 0.2)
				pulse.tween_property(face, "modulate:a", 0.45, 0.2)
	if reveal and group.name == "Hits" and not group.get("pool", {}).is_empty(): stage_label.text += " · %d/%d successful rolls" % [successful, rolls.size()]
	if reveal and group.name == "Wounds" and not group.get("pool", {}).is_empty(): stage_label.text += " · %d wounds generated" % int(group.pool.get("wounds", 0))
	if rolls.is_empty():
		var fixed := Label.new()
		fixed.text = "Fixed value · no roll" if group.name == "Damage" else "No recorded dice at this step"
		dice.add_child(fixed)
