extends SceneTree
const ResultPanel = preload("res://scripts/ui/match_result_panel.gd")
var failures := 0
func _initialize() -> void: call_deferred("run")
func check(ok: bool, message: String) -> void:
	if not ok:
		failures += 1
		push_error(message)
func run() -> void:
	var panel := ResultPanel.new()
	root.add_child(panel)
	panel.show_result({"winner": 1, "scores": {"P1": 12, "P2": 9}, "scenario": "Tactical training", "round": 5}, true, "Uses the admitted starting armies and match options.")
	check(panel.title.text_overrun_behavior == TextServer.OVERRUN_NO_TRIMMING and panel.title.text == "PLAYER 1 WINS", "The result title keeps its full text")
	check(panel.rematch_note.text_overrun_behavior == TextServer.OVERRUN_NO_TRIMMING and "admitted starting armies" in panel.rematch_note.text, "The rematch note keeps its full text")
	check(panel.rematch_button.clip_text == false and panel.rematch_button.text_overrun_behavior == TextServer.OVERRUN_NO_TRIMMING and "Rematch · same armies" in panel.rematch_button.text, "The rematch action keeps its full label")
	print("Match result panel UI checks: %d failures" % failures)
	panel.queue_free()
	await process_frame
	quit(0 if failures == 0 else 1)
