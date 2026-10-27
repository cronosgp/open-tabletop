extends RefCounted
## Test adapter for exercising UnitActions through the same public boundary as the match UI.
const Commands = preload("res://scripts/edition_11/match_command_service.gd")
const PendingDecisions = preload("res://scripts/edition_11/pending_decision_registry.gd")

static func submit(state: Dictionary, player: int, selected: Dictionary, point: Vector2 = Vector2.ZERO, roller: Callable = Callable(), decision_id: String = "", option_id: String = "") -> Dictionary:
	if selected.is_empty(): return {"error": "No UnitActions choice was selected."}
	var command_choice := selected
	var decision := PendingDecisions.current(state, ["unit-actions"])
	if not decision.is_empty():
		var projected: Dictionary = {}
		for candidate: Dictionary in decision.get("legal_options", []):
			if str(candidate.get("action", "")) == str(selected.get("action", "")) and int(candidate.get("model", -1)) == int(selected.get("model", -1)) and int(candidate.get("target", -1)) == int(selected.get("target", -1)) and str(candidate.get("value", "")) == str(selected.get("value", "")):
				projected = candidate
				break
		if projected.is_empty(): return {"error": "The selected choice is not in the current UnitActions decision."}
		command_choice = {
			"_decision_type": Commands.UNIT_CHOICE_ENVELOPE,
			"decision_id": decision_id if not decision_id.is_empty() else str(decision.get("decision_id", "")),
			"option_id": option_id if not option_id.is_empty() else str(projected.get("id", "")),
			"choice": selected
		}
	return Commands.execute(state, player, {"kind": Commands.SELECT_UNIT_CHOICE, "revision": int(state.get("revision", -1)), "point": point, "choice": command_choice}, roller)

static func error(state: Dictionary, player: int, selected: Dictionary, point: Vector2 = Vector2.ZERO, roller: Callable = Callable()) -> String:
	return str(submit(state, player, selected, point, roller).get("error", ""))
