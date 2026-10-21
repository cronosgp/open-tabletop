extends RefCounted
## Normalized, read-only projection of a specialized pending-choice workflow.
const ResolutionFrames = preload("res://scripts/edition_11/resolution_frame.gd")

static func create(state: Dictionary, source: String, timing: String, owner: int, options: Array, pass_allowed: bool) -> Dictionary:
	if owner not in [1, 2] or source.is_empty() or timing.is_empty() or options.is_empty(): return {}
	var legal_options: Array[Dictionary] = []
	for index in range(options.size()):
		var option: Variant = options[index]
		if not option is Dictionary or str(option.get("action", "")).is_empty(): return {}
		var action := str(option.action)
		var model := int(option.get("model", -1))
		var target := int(option.get("target", -1))
		var value := str(option.get("value", ""))
		var key := "%s|%d|%d|%s|%d" % [action, model, target, value, index]
		var details: Dictionary = option.get("details", {})
		if not details.is_empty(): key += "|" + var_to_str(details)
		var projected := {
			"id": key.sha256_text().substr(0, 20),
			"label": str(option.get("label", action)),
			"action": action,
			"model": model,
			"target": target,
			"value": value
		}
		if not details.is_empty(): projected.details = details.duplicate(true)
		legal_options.append(projected)
	var turn := int(state.get("turn", 0))
	var phase := str(state.get("phase", ""))
	var revision := int(state.get("revision", -1))
	var manifest: Dictionary = state.get("match_manifest", {})
	var rules_profile_id := str(manifest.get("rules_profile_id", "warhammer-40k-11e"))
	var rules_profile_version := str(manifest.get("rules_implementation", ""))
	var decision_id := "%s:%d:%s:%d:%d" % [source, turn, phase, revision, owner]
	var frame := ResolutionFrames.current(state)
	return {
		"schema_version": 1,
		"decision_id": decision_id,
		# This projection predates domain event IDs. Keep the field explicitly absent
		# instead of treating a state revision as an event identifier.
		"source_event_id": null,
		"action_id": str(frame.get("action_id", "")) if not frame.is_empty() else null,
		"source": source,
		"timing": timing,
		"priority_player_id": owner,
		"legal_options": legal_options,
		"pass_allowed": pass_allowed,
		"close_policy": "pass-or-select" if pass_allowed else "select-required",
		"resume_frame_id": str(frame.get("frame_id", "")) if not frame.is_empty() else null,
		"rules_profile_id": rules_profile_id,
		"rules_profile_version": rules_profile_version
	}
