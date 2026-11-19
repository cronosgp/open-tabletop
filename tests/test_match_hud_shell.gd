extends SceneTree
const Hud = preload("res://scripts/ui/combat_hud.gd")
const Footer = preload("res://scripts/ui/decision_footer.gd")
const Roster = preload("res://scripts/ui/army_roster.gd")
var failures := 0
var camera_requests := 0
var command_requests := 0
func _initialize() -> void: call_deferred("run")
func check(ok: bool, message: String) -> void:
	if not ok:
		failures += 1
		push_error(message)
func run() -> void:
	var hud := Hud.new()
	root.add_child(hud)
	hud.set_steps("movement",1,1,2)
	hud.set_score_text("P1 2 VP · 3 CP   P2 4 VP · 1 CP")
	hud.decision_label.text = "Choose a reaction or decline to resume movement."
	check(hud.round_label.text == "R1 · P1 turn" and hud.round_label.text_overrun_behavior == TextServer.OVERRUN_NO_TRIMMING and hud.round_label.custom_minimum_size.x > 40.0 and hud.round_label.custom_minimum_size.x + 0.5 >= hud.round_label.get_minimum_size().x and hud.owner_label.text == "PLAYER 2 DECIDES", "Turn owner and reaction decision owner have separate visible labels")
	check(hud.round_label.get_parent() != hud.objective_label.get_parent() and hud.command_panel_button.get_parent() == hud.objective_label.get_parent() and hud.objective_label.text_overrun_behavior == TextServer.OVERRUN_NO_TRIMMING, "Phase chips stay on their own row from the score and action buttons")
	check(hud.owner_label.get_parent() is VBoxContainer and hud.owner_label.get_parent() == hud.decision_label.get_parent() and hud.owner_label.text_overrun_behavior == TextServer.OVERRUN_NO_TRIMMING, "The decision owner sits above the instruction and keeps its full text")
	check(hud.round_label.get_parent() is HFlowContainer and hud.step_labels.movement.get_parent() == hud.round_label.get_parent() and hud.step_labels.movement.text_overrun_behavior == TextServer.OVERRUN_NO_TRIMMING, "Phase chips wrap with the turn caption instead of forcing one rigid row")
	var roster := Roster.new()
	root.add_child(roster)
	var long_name := "Assault Intercessor Squad with Jump Packs"
	roster.present({"units": {7: {"owner": 1, "squad": 3, "wounds": 2, "max_wounds": 2, "on_battlefield": true, "definition_id": "space-marines:assault-intercessor-squad"}}, "squads": {3: {"name": long_name, "battle_shocked": false}}}, 7, 1)
	var roster_row: Button = roster._model_rows[7]
	check(long_name in roster.get_child(1).get_child(1).text and roster_row.text_overrun_behavior == TextServer.OVERRUN_NO_TRIMMING and roster_row.clip_text == false and "Assault Intercessor" in roster_row.text, "Roster rows keep the full unit and model names")
	roster.queue_free()
	check(hud.decision_label.max_lines_visible != 0 and "resume movement" in hud.decision_label.text, "The complete current instruction remains visible")
	check(hud.tools_button.focus_mode == Control.FOCUS_ALL, "Secondary tools are keyboard/gamepad focusable")
	check(hud.step_labels.values().all(func(control):return control is Label), "Phase progress labels cannot dispatch a phase advance")
	hud.set_focus_available(true)
	hud.focus_requested.connect(func():camera_requests += 1)
	hud._refresh_tools_menu()
	var popup := hud.tools_button.get_popup()
	var focus_index := popup.get_item_index(Hud.Tool.FOCUS)
	check(focus_index >= 0 and not popup.is_item_disabled(focus_index), "The overflow menu retains camera focus")
	popup.id_pressed.emit(Hud.Tool.FOCUS)
	hud.set_focus_available(false)
	popup.id_pressed.emit(Hud.Tool.FOCUS)
	check(camera_requests == 1, "Tools forwards the existing camera signal exactly once")
	hud._format_step_captions(true)
	check(hud.step_labels.movement.text == "Move", "The compact rail shortens its phase captions")
	hud._format_step_captions(false)
	check(hud.step_labels.movement.text == "2 Move · NOW", "The wide rail restores the current phase caption")
	hud.set_complete(1)
	hud._format_step_captions(true)
	check(hud.step_labels.movement.text == "Move" and hud.owner_label.text == "RECORDED RESULT", "Resizing a completed match preserves its result header")
	var host := VBoxContainer.new()
	root.add_child(host)
	var source := Button.new()
	source.text = "Confirm the current allocation"
	source.custom_minimum_size = Vector2(90,40)
	host.add_child(source)
	source.pressed.connect(func():command_requests += 1)
	var footer := Footer.new()
	root.add_child(footer)
	source.disabled = true
	footer.present(source,[],"Choose an eligible model first.",true)
	check(footer.is_ancestor_of(source) and source.disabled and footer.reason.visible and "eligible" in footer.reason.text, "Pinned actions retain the actual disabled command and adjacent validator reason")
	footer.restore()
	check(source.get_parent() == host and source.custom_minimum_size == Vector2(90,40), "Restoring an action preserves its original owner and geometry")
	source.disabled = false
	footer.present(source,[],"",true)
	source.pressed.emit()
	footer.restore()
	footer.present(source,[],"",true)
	source.pressed.emit()
	check(command_requests == 2 and not footer.reason.visible, "Moving the existing action never duplicates its command subscription")
	var reaction := "Armour of Contempt: worsen the attacker's AP by 1 against Assault Intercessor Squad 1 (1 CP)"
	footer.custom_minimum_size = Vector2(280, 0)
	footer.present(source, [], "", true, reaction)
	check(footer.choice.visible and footer.choice.text == reaction and footer.choice.text_overrun_behavior == TextServer.OVERRUN_NO_TRIMMING and footer.choice.autowrap_mode == TextServer.AUTOWRAP_WORD_SMART and not footer.choice.text.contains("…"), "The pinned reaction choice keeps the complete label")
	footer.present(null, [], "", true, reaction)
	check(not footer.visible and footer.choice.text.is_empty(), "Clearing the action also clears the pinned choice")
	footer.present(source, [], "", true)
	footer.restore()
	footer.queue_free()
	host.queue_free()
	hud.queue_free()
	await process_frame
	print("Match HUD shell checks: %d failures" % failures)
	quit(0 if failures == 0 else 1)
