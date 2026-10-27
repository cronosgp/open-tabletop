extends RefCounted
## Persisted LIFO continuation frames for work paused by a player decision.

static func begin(state: Dictionary, kind: String, action_id: String, resume_point: String) -> Dictionary:
	if kind.is_empty() or action_id.is_empty() or resume_point.is_empty(): return {}
	var raw_frames: Variant = state.get("resolution_frames", [])
	if typeof(raw_frames) != TYPE_ARRAY: return {}
	var frames: Array = raw_frames
	if not _valid_stack(frames): return {}
	if not frames.is_empty():
		var top_value: Variant = frames[frames.size() - 1]
		if typeof(top_value) != TYPE_DICTIONARY: return {}
		var top: Dictionary = top_value
		if str(top.get("kind", "")) == kind and str(top.get("action_id", "")) == action_id:
			top.status = "resolving"
			top.resume_point = resume_point
			frames[frames.size() - 1] = top
			state["resolution_frames"] = frames
			return top
	var parent_frame_id := ""
	if not frames.is_empty():
		var parent_value: Variant = frames.back()
		if typeof(parent_value) != TYPE_DICTIONARY: return {}
		parent_frame_id = str(parent_value.get("frame_id", ""))
	var turn := int(state.get("turn", 0))
	var phase := str(state.get("phase", ""))
	var revision := int(state.get("revision", -1))
	var frame_id := "%s:%d:%s:%s:%d" % [kind, turn, phase, action_id.sha256_text().substr(0, 12), revision]
	var frame := {
		"schema_version": 1,
		"frame_id": frame_id,
		"parent_frame_id": parent_frame_id,
		"action_id": action_id,
		"kind": kind,
		"status": "resolving",
		"phase": phase,
		"turn": turn,
		"resume_point": resume_point,
		"created_revision": revision
	}
	frames.append(frame)
	state["resolution_frames"] = frames
	return frame

static func suspend(state: Dictionary, frame_id: String, resume_point: String = "") -> String:
	var raw_frames: Variant = state.get("resolution_frames", [])
	if typeof(raw_frames) != TYPE_ARRAY: return "The resolution-frame stack is invalid."
	var frames: Array = raw_frames
	if not _valid_stack(frames): return "The resolution-frame stack is invalid."
	if frames.is_empty():
		return "Only the active resolution frame can be suspended."
	var index := frames.size() - 1
	var top_value: Variant = frames[index]
	if typeof(top_value) != TYPE_DICTIONARY: return "The active resolution frame is invalid."
	var top: Dictionary = top_value
	if str(top.get("frame_id", "")) != frame_id: return "Only the active resolution frame can be suspended."
	top.status = "suspended"
	if not resume_point.is_empty(): top.resume_point = resume_point
	frames[index] = top
	state["resolution_frames"] = frames
	return ""

static func complete(state: Dictionary, frame_id: String) -> String:
	var raw_frames: Variant = state.get("resolution_frames", [])
	if typeof(raw_frames) != TYPE_ARRAY: return "The resolution-frame stack is invalid."
	var frames: Array = raw_frames
	if not _valid_stack(frames): return "The resolution-frame stack is invalid."
	if frames.is_empty():
		return "Only the active resolution frame can be completed."
	var top_value: Variant = frames[frames.size() - 1]
	if typeof(top_value) != TYPE_DICTIONARY: return "The active resolution frame is invalid."
	if str(top_value.get("frame_id", "")) != frame_id: return "Only the active resolution frame can be completed."
	frames.pop_back()
	state["resolution_frames"] = frames
	return ""

static func current(state: Dictionary) -> Dictionary:
	var raw_frames: Variant = state.get("resolution_frames", [])
	if typeof(raw_frames) != TYPE_ARRAY: return {}
	var frames: Array = raw_frames
	if frames.is_empty(): return {}
	if not _valid_stack(frames): return {}
	var top_value: Variant = frames.back()
	return top_value.duplicate(true) if typeof(top_value) == TYPE_DICTIONARY else {}

static func _valid_stack(frames: Array) -> bool:
	var expected_parent := ""
	for value: Variant in frames:
		if typeof(value) != TYPE_DICTIONARY: return false
		var frame: Dictionary = value
		if int(frame.get("schema_version", -1)) != 1: return false
		if str(frame.get("frame_id", "")).is_empty() or str(frame.get("action_id", "")).is_empty() or str(frame.get("kind", "")).is_empty(): return false
		if str(frame.get("phase", "")).is_empty() or str(frame.get("resume_point", "")).is_empty(): return false
		if str(frame.get("status", "")) not in ["resolving", "suspended"]: return false
		if not frame.has("turn") or not frame.has("created_revision"): return false
		if str(frame.get("parent_frame_id", "")) != expected_parent: return false
		expected_parent = str(frame.frame_id)
	return true
