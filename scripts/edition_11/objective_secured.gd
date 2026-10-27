extends RefCounted
## Explicit Intercessor capability. Never activate arbitrary imported ability DSL.
const Objectives = preload("res://scripts/edition_11/objectives.gd")
const Morale = preload("res://scripts/edition_11/morale.gd")
const Capabilities = preload("res://scripts/edition_11/capabilities.gd")
const ID := "intercessor-objective-secured-v1"
const DEFINITION := "40kdc:11e:adeptus-astartes:intercessor-squad"
const SOURCE := "https://assets.warhammer-community.com/eng_04-06_warhammer40k_new40k_armageddon_spacemarines_datasheet_cards-hcuj9cke0r-h2rfuky1yw.pdf"

static func enable(state: Dictionary) -> void:
	state.objective_secured = {"implementation": ID}
	Capabilities.admit(state, "objective-secured", ID)
	for squad: int in state.squads:
		if not intercessors(state, squad): continue
		Capabilities.admit_squad(state, squad, "objective-secured")

static func intercessors(state: Dictionary, squad: int) -> bool:
	var found := false
	for model: Dictionary in state.units.values():
		if model.squad != squad: continue
		if model.get("definition_id", "") != DEFINITION: return false
		found = true
	return found

static func end_command(state: Dictionary) -> String:
	if state.get("objective_secured", {}).get("implementation", "") != ID or state.phase != "command": return ""
	var secured: Array[String] = []
	var objectives: Array = state.get("mission", {}).get("objectives", [])
	for index in range(objectives.size()):
		var objective: Dictionary = objectives[index]
		if objective.controller != state.active or objective.secured == state.active: continue
		for squad: int in Objectives.controlling_squads(state, objective, Callable(Morale, "objective_control")):
			if not intercessors(state, squad): continue
			# controlling_squads requires a living, in-range, positive-OC model.
			if Objectives.secure(state, index, state.active).is_empty(): secured.append(str(objective.name))
			break
	return "Objective Secured: " + ", ".join(secured) if not secured.is_empty() else ""
