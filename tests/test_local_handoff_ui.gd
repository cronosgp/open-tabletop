extends SceneTree
const Handoff = preload("res://scripts/ui/local_player_handoff.gd")
var failures := 0
func _initialize() -> void: call_deferred("run")
func check(ok: bool, message: String) -> void:
	if not ok:
		failures += 1
		push_error(message)
func run() -> void:
	var handoff := Handoff.new()
	root.add_child(handoff)
	handoff.show_for_player(2, "Round 1 · Movement")
	check(handoff.visible and handoff.receiving_player == 2, "Handoff names the receiving player")
	check(handoff.instructions.text_overrun_behavior == TextServer.OVERRUN_NO_TRIMMING and "Pass the controls to Player 2" in handoff.instructions.text, "The handoff keeps the full player instruction")
	check(handoff.context_label.text_overrun_behavior == TextServer.OVERRUN_NO_TRIMMING and handoff.context_label.text == "Round 1 · Movement", "The handoff keeps the full decision context")
	check(handoff.ready_button.clip_text == false and handoff.ready_button.text_overrun_behavior == TextServer.OVERRUN_NO_TRIMMING and handoff.ready_button.text == "Continue as Player 2", "The continue action keeps its full label")
	print("Local handoff UI checks: %d failures" % failures)
	handoff.queue_free()
	await process_frame
	quit(0 if failures == 0 else 1)
