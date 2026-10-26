extends RefCounted
## Scenario composition and presentation only; existing rules remain authoritative.
const Catalog = preload("res://scripts/edition_11/army_capabilities.gd")
const Roster = preload("res://scripts/army_roster.gd")
const ID := "marine-tactical-training-v1"
const FIRE_ID := "preset:marine-tactical-v1:fire"
const ASSAULT_ID := "preset:marine-tactical-v1:assault"

static func army(assault: bool = false) -> Dictionary:
	var list := Roster.new_list("11e", "Space Marines", "custom", 1000)
	list.id = ASSAULT_ID if assault else FIRE_ID
	list.name = "Close Assault" if assault else "Fire and Manoeuvre"
	list.pricing_source = "local-reference-profiles"
	list.notes = "Gladius tactical training; fixed default loadouts, no enhancements. Asymmetric practice forces; competitive balance and full army legality are not certified."
	var sources := ["chaplain", "assault-intercessor-squad", "bladeguard-veteran-squad"] if assault else ["captain", "intercessor-squad", "hellblaster-squad"]
	for source: String in sources:
		var resolved := Catalog.resolve("Space Marines", "40kdc:11e:adeptus-astartes:" + source)
		if not resolved.error.is_empty(): return resolved
		if not resolved.spec.get("current_reference", false): return {"error": "Tactical training requires current local profiles: " + source}
		list.catalog_digest = resolved.pack_hash
		list.entries.append({"unit_id": resolved.unit.id, "name": resolved.unit.name, "edition": "11e", "faction": "Space Marines", "role": Roster.role(resolved.unit.keywords), "models": resolved.models, "cost": resolved.cost, "copies": 1, "source_digest": resolved.pack_hash})
	return {"error": "", "list": list}

static func tip(phase: String) -> String:
	match phase:
		"deployment": return "Deploy behind cover with routes to objectives. Fire and Manoeuvre favours shooting; Close Assault needs a protected approach."
		"start_turn", "command": return "Review the available Combat Doctrine and Captain choices. Only legal abilities and Gladius stratagems appear; their use is optional."
		"movement": return "Consider the opponent's reaction opportunities before moving. Keep the leader with its attached unit and plan a route to an objective."
		"shooting": return "Hellblasters offer standard or supercharged plasma: inspect damage and Hazardous risk before confirming. Review available stratagems and keep CP for reactions."
		"charge": return "Check charge targets and the displayed roll requirement. A charge can create melee opportunities for the Chaplain's unit and Bladeguard."
		"fight": return "When the Bladeguard choice opens, compare its offensive and defensive stance. Review eligible Fight stratagems before committing attacks."
		_: return "Inspect recorded effects and CP in the battle log. Passing an optional choice preserves free play; required decisions still block progression."

static func experiments() -> Array[String]:
	return [
		"[COMMAND] Try a Captain or Chaplain ability when offered.",
		"[COMMAND / REACTION] Spend CP on a Gladius/Core stratagem; check cost and battle log.",
		"[SHOOTING] Compare standard and supercharged plasma; resolve Hazardous.",
		"[CHARGE / FIGHT] Charge with Assault Intercessors; compare Bladeguard attack/defend."
	]

static func experiment_progress(state: Dictionary) -> Dictionary:
	var used: Dictionary = state.get("unit_abilities", {}).get("used", {})
	var leader := false
	for key: Variant in used:
		if str(key).begins_with("acumen:") or str(key).begins_with("spiritual:"):
			leader = true
			break
	var stratagem := false
	for use: Variant in state.get("stratagems", {}).get("uses", []):
		if use is Dictionary and not str(use.get("stratagem", "")).is_empty():
			stratagem = true
			break
	var tracker: Dictionary = state.get("training_experiments", {})
	var standard_plasma := bool(tracker.get("standard_plasma", false))
	var supercharged_plasma := bool(tracker.get("supercharged_plasma", false))
	var hazardous := bool(tracker.get("hazardous", false))
	var stance: bool = not state.get("unit_abilities", {}).get("bladeguard", {}).is_empty()
	return {"leader": leader, "stratagem": stratagem, "standard_plasma": standard_plasma, "supercharged_plasma": supercharged_plasma, "hazardous": hazardous, "plasma": standard_plasma and supercharged_plasma and hazardous, "bladeguard": stance, "complete": leader and stratagem and standard_plasma and supercharged_plasma and hazardous and stance}

static func experiment_lines(state: Dictionary) -> Array[String]:
	var progress := experiment_progress(state)
	var lines: Array[String] = []
	lines.append("[%s] %s" % ["DONE" if progress.leader else "OPEN", experiments()[0]])
	lines.append("[%s] %s" % ["DONE" if progress.stratagem else "OPEN", experiments()[1]])
	lines.append("[%s] %s" % ["DONE" if progress.plasma else ("IN PROGRESS" if progress.standard_plasma or progress.supercharged_plasma or progress.hazardous else "OPEN"), experiments()[2]])
	lines.append("[%s] %s" % ["DONE" if progress.bladeguard else "OPEN", experiments()[3]])
	return lines

static func experiment_count(state: Dictionary) -> int:
	var progress := experiment_progress(state)
	var count := 0
	for key: String in ["leader", "stratagem", "plasma", "bladeguard"]:
		if bool(progress.get(key, false)): count += 1
	return count

static func opportunity_status(choices: Array) -> String:
	var leader_ability := false
	var cp_stratagem := false
	var bladeguard_stance := false
	for choice: Dictionary in choices:
		match str(choice.get("action", "")):
			"acumen", "spiritual-leader": leader_ability = true
			"detachment-stratagem", "core-stratagem": cp_stratagem = true
			"bladeguard": bladeguard_stance = true
	var labels: Array[String] = []
	if leader_ability: labels.append("leader ability")
	if cp_stratagem: labels.append("CP stratagem")
	if bladeguard_stance: labels.append("Bladeguard stance")
	if labels.is_empty(): return ""
	if labels.size() == 1: return "READY NOW — %s is a legal choice" % labels[0]
	return "READY NOW — %s are legal choices" % _join_choice_labels(labels)

static func _join_choice_labels(labels: Array[String]) -> String:
	if labels.size() == 2: return "%s and %s" % [labels[0], labels[1]]
	return "%s, and %s" % [", ".join(labels.slice(0, labels.size() - 1)), labels[-1]]

static func experiment_window(state: Dictionary) -> String:
	var phase := str(state.get("phase", ""))
	var unit_abilities: Dictionary = state.get("unit_abilities", {})
	if phase == "deployment" and unit_abilities.get("setup_players", []).size() < 2:
		return "PREPARATION — finish Warlords and leader attachments"
	match phase:
		"pre_battle": return "PREPARATION — finish Warlords and leader attachments"
		"deployment": return "DEPLOYMENT — place units legally"
		"start_turn", "command": return "COMMAND — look for a leader ability or CP stratagem"
		"movement": return "MOVEMENT — build a route to the next opportunity"
		"shooting": return "SHOOTING — compare standard/supercharged plasma"
		"charge", "fight": return "CHARGE / FIGHT — look for Assault Intercessor and Bladeguard choices"
		"end_turn": return "END OF TURN — resolve required effects"
		_: return "WAIT FOR A LEGAL WINDOW — required choices still gate progression"

static func matches(state: Dictionary) -> bool:
	var armies: Dictionary = state.get("saved_army_setup", {}).get("armies", {})
	if armies.size() != 2: return false
	var signatures: Array[String] = []
	for army_selection: Dictionary in armies.values():
		var entries: Array[String] = []
		for entry: Dictionary in army_selection.get("entries", []):
			if int(entry.get("copies", 0)) != 1 or entry.has("enhancement_id"): return false
			entries.append("%s:%d" % [str(entry.get("definition_id", "")).get_slice(":", 3), int(entry.get("models", 0))])
		entries.sort()
		signatures.append(",".join(entries))
	signatures.sort()
	return signatures == ["assault-intercessor-squad:5,bladeguard-veteran-squad:3,chaplain:1", "captain:1,hellblaster-squad:5,intercessor-squad:5"]

static func summary() -> String:
	var lines: Array[String] = []
	for assault: bool in [false, true]:
		var report := army(assault)
		if not report.error.is_empty(): return "Current local catalog unavailable: " + str(report.error)
		var admitted := Catalog.admit({"schema_version": 2, "faction": "Space Marines", "category": "custom", "points_limit": 1000, "entries": report.list.entries.map(func(entry: Dictionary): return {"definition_id": entry.unit_id, "models": entry.models, "copies": entry.copies})})
		if not admitted.error.is_empty(): return str(admitted.error)
		var formation: Array[String] = []
		for entry: Dictionary in report.list.entries:
			formation.append("%s (%d)" % [str(entry.name), int(entry.models)])
		lines.append("%s • %d pts\n%s" % [report.list.name, admitted.total, ", ".join(formation)])
	return "\n".join(lines) + "\nLocal Gladius free play with tips • no downloads\nPractice: abilities • CP stratagems • plasma/Hazardous • Bladeguard stances\nAsymmetric forces; legality and competitive balance are not certified."
