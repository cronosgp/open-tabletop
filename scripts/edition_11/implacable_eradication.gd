extends RefCounted
## Explicit training capability; never execute imported ability DSL.
const Objectives = preload("res://scripts/edition_11/objectives.gd")
const ID := "immortal-implacable-eradication-reference-v1"
const DEFINITION := "40kdc:11e:necrons:immortals"
const SOURCE := "https://www.warhammer-community.com/wp-content/uploads/2023/06/H5pO90rzYSAY6dHG.pdf"

static func enable(state: Dictionary) -> void:
	state.implacable_eradication = {"implementation": ID}
	for squad: int in state.squads:
		if not immortals(state, squad): continue
		state.squads[squad].disabled_abilities.erase("implacable-eradication")
		var abilities: Array = state.squads[squad].get("enabled_abilities", []).duplicate()
		if "implacable-eradication" not in abilities: abilities.append("implacable-eradication")
		state.squads[squad].enabled_abilities = abilities

static func immortals(state: Dictionary, squad: int) -> bool:
	var found := false
	for model: Dictionary in state.units.values():
		if model.squad != squad: continue
		if model.get("definition_id", "") != DEFINITION: return false
		found = true
	return found

static func mode(state: Dictionary, squad: int, target: int) -> String:
	if state.get("implacable_eradication", {}).get("implementation", "") != ID or not immortals(state, squad): return "none"
	if not state.squads.has(target) or state.squads[target].owner == state.squads[squad].owner: return "none"
	for model: Dictionary in state.units.values():
		if model.squad != target: continue
		for objective: Dictionary in state.get("mission", {}).get("objectives", []):
			if Objectives.in_range(model, objective): return "failed"
	return "ones"
