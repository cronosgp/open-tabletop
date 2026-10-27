extends RefCounted
## Bounded Black Templars Vow-sworn Crusaders support.
const AbilityCatalog = preload("res://scripts/edition_11/unit_ability_catalog.gd")
const MarineProfiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Contact = preload("res://scripts/edition_11/contact_movement.gd")
const Objectives = preload("res://scripts/edition_11/objectives.gd")
const Traits = preload("res://scripts/edition_11/weapon_traits.gd")
const ID := "templar-vows-11e-v2"
const DOCTRINES_ID := "combat-doctrines-11e-gladius-v1"
const UPHOLD := "uphold-honour"
const ABHOR := "abhor-the-witch"
const CHALLENGE := "accept-any-challenge"

static func enabled_for(state: Dictionary, owner: int) -> bool:
	if owner not in [1, 2]: return false
	var doctrine_state: Dictionary = state.get("combat_doctrines", {})
	if doctrine_state.get("implementation", "") != DOCTRINES_ID: return false
	var assignments: Dictionary = doctrine_state.get("detachments", {})
	var detachment := str(assignments.get(owner, assignments.get(str(owner), doctrine_state.get("detachment", "none"))))
	if detachment != "vow-sworn-crusaders": return false
	if not AbilityCatalog.enabled(state): return false
	var chapters: Dictionary = state.get("marine_chapters", {})
	return str(chapters.get(owner, chapters.get(str(owner), ""))) == "BLACK TEMPLARS"

static func needs_choice(state: Dictionary, owner: int) -> bool:
	if not enabled_for(state, owner) or state.get("phase", "") != "start_turn" or int(state.get("turn", -1)) != 1 or int(state.get("round", -1)) != 1: return false
	var doctrine_state: Dictionary = state.get("combat_doctrines", {})
	var selected: Dictionary = doctrine_state.get("templar_vows", {})
	var passed: Dictionary = doctrine_state.get("templar_vow_passed", {})
	return not selected.has(owner) and not selected.has(str(owner)) and not bool(passed.get(owner, passed.get(str(owner), false)))

static func choices(state: Dictionary, owner: int) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if not needs_choice(state, owner): return result
	result.append({"label": "Uphold the Honour of the Emperor — secure objectives and retain action eligibility after Advancing", "action": "templar-vow-select", "value": UPHOLD})
	result.append({"label": "Abhor the Witch, Destroy the Witch — melee attacks against Psykers gain Precision and Lance", "action": "templar-vow-select", "value": ABHOR})
	result.append({"label": "Accept Any Challenge, No Matter the Odds — +1 to wound with melee attacks against tougher targets", "action": "templar-vow-select", "value": CHALLENGE})
	result.append({"label": "Skip Templar Vow selection", "action": "templar-vow-pass"})
	return result

static func apply_choice(state: Dictionary, owner: int, selected: Dictionary) -> String:
	if not needs_choice(state, owner): return "No Templar Vow selection is pending."
	var vow := str(selected.get("value", ""))
	if vow not in [UPHOLD, ABHOR, CHALLENGE]: return "Select one of the available Templar Vows."
	state.combat_doctrines.templar_vows[owner] = vow
	return ""

static func display_name(vow: String) -> String:
	match vow:
		UPHOLD: return "Uphold the Honour of the Emperor"
		ABHOR: return "Abhor the Witch, Destroy the Witch"
		CHALLENGE: return "Accept Any Challenge, No Matter the Odds"
	return ""

static func pass_choice(state: Dictionary, owner: int) -> String:
	if not needs_choice(state, owner): return "No Templar Vow selection is pending."
	state.combat_doctrines.templar_vow_passed[owner] = true
	return ""

static func selected_vow(state: Dictionary, owner: int) -> String:
	if not enabled_for(state, owner): return ""
	var selected: Dictionary = state.get("combat_doctrines", {}).get("templar_vows", {})
	return str(selected.get(owner, selected.get(str(owner), "")))

static func infantry_unit(state: Dictionary, squad: int) -> bool:
	if not state.get("squads", {}).has(squad): return false
	var alive := Contact.alive(state, squad)
	if alive.is_empty(): return false
	for model: int in alive:
		var unit: Dictionary = state.units[model]
		var profile := MarineProfiles.profile(AbilityCatalog.identity(unit))
		var keywords: Array = profile.get("keywords", [])
		if profile.is_empty() or "ADEPTUS ASTARTES" not in keywords or "INFANTRY" not in keywords: return false
	return true

static func current_astartes_unit(state: Dictionary, squad: int) -> bool:
	if not state.get("squads", {}).has(squad): return false
	var alive := Contact.alive(state, squad)
	if alive.is_empty(): return false
	for model: int in alive:
		var unit: Dictionary = state.units[model]
		var profile := MarineProfiles.profile(AbilityCatalog.identity(unit))
		if profile.is_empty() or "ADEPTUS ASTARTES" not in profile.get("keywords", []): return false
	return true

static func advance_action_allowed(state: Dictionary, squad: int) -> bool:
	if not state.get("squads", {}).has(squad) or not infantry_unit(state, squad): return false
	var owner := int(state.squads[squad].get("owner", -1))
	return selected_vow(state, owner) == UPHOLD

static func abhor_active(state: Dictionary, squad: int, target: int, melee: bool) -> bool:
	if not melee or not state.get("squads", {}).has(squad) or not state.get("squads", {}).has(target): return false
	var owner := int(state.squads[squad].get("owner", -1))
	if selected_vow(state, owner) != ABHOR or not current_astartes_unit(state, squad): return false
	return "PSYKER" in Traits.target_keywords(state, target)

static func challenge_active(state: Dictionary, squad: int, melee: bool) -> bool:
	if not melee or not state.get("squads", {}).has(squad): return false
	var owner := int(state.squads[squad].get("owner", -1))
	return selected_vow(state, owner) == CHALLENGE and current_astartes_unit(state, squad)

static func secure_controlled_objectives(state: Dictionary, owner: int, control_value: Callable) -> void:
	if selected_vow(state, owner) != UPHOLD: return
	var objectives: Array = state.get("mission", {}).get("objectives", [])
	for index in range(objectives.size()):
		var objective: Dictionary = objectives[index]
		if int(objective.get("controller", 0)) != owner: continue
		for squad: int in Objectives.controlling_squads(state, objective, control_value):
			if int(state.squads[squad].get("owner", -1)) == owner and infantry_unit(state, squad):
				Objectives.secure(state, index, owner)
				break
