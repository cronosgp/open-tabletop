extends SceneTree
const Feedback = preload("res://scripts/ui/attack_feedback.gd")
var failures := 0
func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var fx := Feedback.new()
	root.add_child(fx)
	var state := {"units": {100: {"squad": 1, "position": Vector2(-4, 0), "wounds": 2}, 200: {"squad": 2, "position": Vector2(4, 0), "wounds": 0}}, "events": []}
	fx.sync(state, true, true)
	state.last_attack = {"message": "Attack complete", "assignments": [{"model": 100, "target": 2}], "pools": [{"target_squad": 2, "damage_applied": 2}]}
	state.events.append({"message": "Attack complete"})
	var before := var_to_str(state)
	fx.sync(state, true, true)
	check(fx.bursts == 1 and fx.get_child_count() == 1, "Completed attack creates one target cue including eliminated targets")
	check(var_to_str(state) == before, "Feedback preserves authoritative record")
	fx.sync(state, true, true)
	state.events.append({"message": "Another action"})
	fx.sync(state, true, true)
	check(fx.bursts == 1, "Refresh and unrelated events do not replay a result")
	state.events.append({"message": "Attack complete"})
	fx.sync(state, true, true)
	check(fx.bursts == 2, "Identical consecutive attacks are distinguished by completion event")
	fx.sync(state, false, true)
	check(fx.get_child_count() == 0, "Reduced motion clears cues")
	state.events.append({"message": "Attack complete"})
	fx.sync(state, false, true)
	fx.sync(state, true, true)
	check(fx.bursts == 2, "Re-enabling does not replay skipped result")
	fx.reset()
	fx.sync(state, true, true)
	check(fx.get_child_count() == 0, "Restore establishes baseline without replay")
	state.events.append({"message": "Attack complete"})
	fx.sync(state, true, false)
	fx.sync(state, true, true)
	check(fx.get_child_count() == 0, "Hidden workspace consumes cue without replay")
	state.pending_attack = {"active": true}
	state.events.append({"message": "Attack complete"})
	fx.sync(state, true, true)
	check(fx.get_child_count() == 0, "Pending allocation does not produce a completed cue")
	state.erase("pending_attack")
	state.events.append({"message": "Attack complete"})
	fx.sync(state, true, true)
	await create_timer(0.95).timeout
	check(fx.get_child_count() == 0, "Cue expires automatically")
	print("Attack feedback checks: %d failures" % failures)
	quit(0 if failures == 0 else 1)
