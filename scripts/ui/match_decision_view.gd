extends RefCounted
## Presentation snapshot of the rules service's current decision.

const SOURCES := [
	"mission-preparation", "awakened-attachment", "reanimation", "combat-doctrines",
	"unit-actions", "oath-of-moment", "vowed-target", "stratagems",
	"damage-allocation", "coherency", "escape-wounds",
]

static func describe(state: Dictionary, actor: int, decision: Dictionary, instruction: String) -> Dictionary:
	var turn_player := int(state.get("active", 0))
	var source := str(decision.get("source", ""))
	var timing := str(decision.get("timing", ""))
	var kind := ""
	if source == "stratagems":
		kind = "Dice decision"
	elif source == "damage-allocation":
		kind = "Allocation"
		if bool(decision.get("pass_allowed", false)): kind = "Optional choice"
	elif not decision.is_empty():
		if actor != turn_player and not timing.contains("preparation") and state.get("phase", "") != "deployment":
			kind = "Optional reaction" if bool(decision.get("pass_allowed", false)) else "Reaction"
		elif bool(decision.get("pass_allowed", false)):
			kind = "Optional choice"
		else:
			kind = "Required choice"
	var view := {
		"turn_player": turn_player,
		"decision_player": actor,
		"decision_id": str(decision.get("decision_id", "")),
		"source": source,
		"timing": timing,
		"kind": kind,
		"instruction": instruction,
	}
	view.make_read_only()
	return view
