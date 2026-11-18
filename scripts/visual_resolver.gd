extends RefCounted
## Resolve local miniature appearance without changing rules or saved equipment.
## Candidate order is authored by the visual catalog and never establishes legality.

static func resolve(
	manual_variant: String,
	equipment_variants: Array[String],
	unit_variant: String,
	palette_variant: String,
	automatic_variants: Array[String],
	probe: Callable,
	default_variant: String = "",
	default_probe: Callable = Callable()
) -> Dictionary:
	var attempted: Dictionary = {}
	var warnings: Array[String] = []
	var attempts: Array[Dictionary] = []
	if not manual_variant.is_empty():
		var manual_result := _probe(manual_variant, "manual_override", "Saved per-model appearance", probe, attempted, attempts)
		if bool(manual_result.get("ready", false)):
			manual_result["warnings"] = warnings
			manual_result["attempts"] = attempts
			return manual_result
		warnings.append(_saved_choice_warning("per-model appearance", manual_result))
	for identity: String in equipment_variants:
		var equipment_result := _probe(identity, "equipment_match", "Local variant metadata matches this model's configured equipment and role", probe, attempted, attempts)
		if bool(equipment_result.get("ready", false)):
			equipment_result["warnings"] = warnings
			equipment_result["attempts"] = attempts
			return equipment_result
	for choice: Dictionary in [
		{"id": unit_variant, "source": "unit_appearance", "rationale": "Saved appearance for this unit copy"},
		{"id": palette_variant, "source": "army_palette", "rationale": "Saved army palette appearance"}
	]:
		var identity := str(choice.get("id", ""))
		if identity.is_empty(): continue
		var saved_result := _probe(identity, str(choice.source), str(choice.rationale), probe, attempted, attempts)
		if bool(saved_result.get("ready", false)):
			saved_result["warnings"] = warnings
			saved_result["attempts"] = attempts
			return saved_result
		var saved_name := "unit appearance" if str(choice.source) == "unit_appearance" else "army palette appearance"
		warnings.append(_saved_choice_warning(saved_name, saved_result))
	for identity: String in automatic_variants:
		var automatic_result := _probe(identity, "automatic_unit", "Available local miniature for this datasheet", probe, attempted, attempts)
		if bool(automatic_result.get("ready", false)):
			automatic_result["warnings"] = warnings
			automatic_result["attempts"] = attempts
			return automatic_result
	if not default_variant.is_empty():
		var default_result := _probe(default_variant, "datasheet_default", "Saved local default miniature for this datasheet", default_probe, attempted, attempts)
		if bool(default_result.get("ready", false)):
			default_result["warnings"] = warnings
			default_result["attempts"] = attempts
			return default_result
	if not warnings.is_empty():
		warnings.append("A built-in miniature remains visible until a local sculpt is available.")
	var blocking_state := ""
	for attempt: Dictionary in attempts:
		if str(attempt.get("source", "")) in ["manual_override", "unit_appearance", "army_palette"]:
			blocking_state = str(attempt.get("availability", "missing"))
			break
	return {
		"variant_id": "",
		"source": "built_in",
		"availability": "placeholder",
		"fallback": "built_in",
		"blocking_availability": blocking_state,
		"rationale": "No compatible local visual is ready; rules equipment and gameplay are unchanged.",
		"ready": false,
		"visual": null,
		"warnings": warnings,
		"attempts": attempts,
	}

static func _probe(identity: String, source: String, rationale: String, probe: Callable, attempted: Dictionary, attempts: Array[Dictionary]) -> Dictionary:
	var attempt_key := source + ":" + identity if source == "datasheet_default" else identity
	if identity.is_empty() or attempted.has(attempt_key): return {"ready": false, "availability": "missing", "reason": "This candidate has no usable local identity."}
	attempted[attempt_key] = true
	var result: Variant = {"ready": false, "availability": "missing", "reason": "The local appearance could not be loaded."}
	if probe.is_valid(): result = probe.call(identity)
	var assessment: Dictionary = {}
	if result is Dictionary:
		assessment = result.duplicate(true)
	elif result is Node3D:
		assessment = {"ready": true, "availability": "ready", "visual": result}
	if bool(assessment.get("ready", false)) and assessment.get("visual") is Node3D:
		var candidate := {
			"variant_id": identity,
			"source": source,
			"availability": str(assessment.get("availability", "ready")),
			"rationale": rationale,
			"ready": true,
			"visual": assessment.visual,
			"reason": "",
		}
		attempts.append(_attempt_record(identity, source, candidate))
		return candidate
	var availability := str(assessment.get("availability", assessment.get("state", "missing")))
	if availability not in ["download_pending", "downloading", "missing", "conversion_failed"]: availability = "missing"
	var failed := {
		"variant_id": identity,
		"source": source,
		"availability": availability,
		"rationale": rationale,
		"ready": false,
		"visual": null,
		"reason": str(assessment.get("reason", "The local appearance could not be loaded.")),
	}
	attempts.append(_attempt_record(identity, source, failed))
	return failed

static func _attempt_record(identity: String, source: String, result: Dictionary) -> Dictionary:
	return {
		"variant_id": identity,
		"source": source,
		"availability": str(result.get("availability", "missing")),
		"reason": str(result.get("reason", "")),
	}

static func _saved_choice_warning(label: String, result: Dictionary) -> String:
	var state := str(result.get("availability", "missing"))
	var reason := str(result.get("reason", ""))
	var warning := "The saved %s is %s; the saved choice is preserved." % [label, state.replace("_", " ")]
	if not reason.is_empty(): warning += " " + reason
	return warning
