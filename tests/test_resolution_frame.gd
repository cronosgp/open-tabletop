extends SceneTree

const ResolutionFrames = preload("res://scripts/edition_11/resolution_frame.gd")
var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func _initialize() -> void:
	var state := {"turn": 2, "phase": "movement", "revision": 9}
	var parent := ResolutionFrames.begin(state, "phase-close", "phase-close:2:movement", "after-end-window")
	check(parent.status == "resolving" and parent.kind == "phase-close" and parent.resume_point == "after-end-window", "A continuation frame records its workflow and resume point")
	check(ResolutionFrames.suspend(state, str(parent.frame_id), "after-reaction-choice").is_empty(), "The active continuation frame can suspend on a decision")
	var suspended := ResolutionFrames.current(state)
	check(suspended.status == "suspended" and suspended.resume_point == "after-reaction-choice", "Suspension state is persisted in the match state")
	var resumed := ResolutionFrames.begin(state, "phase-close", "phase-close:2:movement", "after-reaction-choice")
	check(resumed.frame_id == parent.frame_id and resumed.status == "resolving" and state.resolution_frames.size() == 1, "Resuming the same workflow reuses its persisted frame")
	var child := ResolutionFrames.begin(state, "nested-reaction", "reaction:fire-overwatch", "after-reaction-shot")
	check(child.parent_frame_id == parent.frame_id and child.frame_id != parent.frame_id, "Nested work is linked to its parent frame")
	var before_out_of_order_close := var_to_str(state)
	check(not ResolutionFrames.complete(state, str(parent.frame_id)).is_empty() and var_to_str(state) == before_out_of_order_close, "A parent frame cannot complete before its child and failure is non-mutating")
	check(ResolutionFrames.complete(state, str(child.frame_id)).is_empty() and ResolutionFrames.current(state).frame_id == parent.frame_id, "Completing nested work restores the parent continuation")
	check(ResolutionFrames.complete(state, str(parent.frame_id)).is_empty() and ResolutionFrames.current(state).is_empty(), "Completing the parent empties the continuation stack")
	check(ResolutionFrames.begin(state, "", "bad", "resume").is_empty(), "Malformed continuation frames fail closed")
	check(ResolutionFrames.begin({"resolution_frames": "corrupt"}, "phase-close", "bad-state", "resume").is_empty(), "A malformed persisted frame stack fails closed")
	check(ResolutionFrames.begin({"resolution_frames": ["corrupt"]}, "phase-close", "bad-entry", "resume").is_empty(), "A malformed entry inside the persisted frame stack fails closed")
	check(ResolutionFrames.current({"resolution_frames": [{"kind": "phase-close", "action_id": "phase-close:2:movement", "status": "suspended"}]}).is_empty(), "A partial frame record cannot be treated as a resumable continuation")
	var malformed_parent := parent.duplicate(true)
	malformed_parent.frame_id = ""
	check(not ResolutionFrames.suspend({"resolution_frames": [malformed_parent]}, "").is_empty(), "A malformed persisted frame cannot be mutated")
	print("Resolution frame checks: %d failures" % failures)
	quit(0 if failures == 0 else 1)
