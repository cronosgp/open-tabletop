extends RefCounted
## Source-bounded Trazyn the Infinite: Ancient Collector and Surrogate Hosts.
const AbilityCatalog = preload("res://scripts/edition_11/unit_ability_catalog.gd")
const Geometry = preload("res://scripts/edition_11/contact_movement.gd")
const Objectives = preload("res://scripts/edition_11/objectives.gd")

const IDENTITY := "trazyn-the-infinite"
const DEFINITION_ID := "40kdc:11e:necrons:trazyn-the-infinite"
const SURROGATE_ACTION := "surrogate-hosts"

static func _phase_key(state: Dictionary) -> String:
	return "%d:%s" % [int(state.get("turn", 0)), str(state.get("phase", ""))]

static func _is_trazyn(unit: Dictionary) -> bool:
	return AbilityCatalog.identity(unit) == IDENTITY or str(unit.get("definition_id", "")) == DEFINITION_ID

static func _has_keyword(unit: Dictionary, keyword: String) -> bool:
	var target_kw := keyword.strip_edges().to_upper()
	if target_kw == "NECRONS" and str(unit.get("definition_id", "")).begins_with("40kdc:11e:necrons:"):
		return true
	for kw: Variant in unit.get("keywords", []):
		if str(kw).replace("_", " ").replace("-", " ").strip_edges().to_upper() == target_kw:
			return true
	return false

static func _is_leading_unit(state: Dictionary, trazyn_unit: Dictionary) -> bool:
	var squad := int(trazyn_unit.get("squad", -1))
	if squad < 0 or not state.get("squads", {}).has(squad): return false
	if not bool(state.squads[squad].get("attached", false)): return false
	if str(trazyn_unit.get("attachment_role", "")) != "leader": return false
	for model_id: int in Geometry.alive(state, squad):
		var member: Dictionary = state.units[model_id]
		if not _is_trazyn(member) and str(member.get("attachment_role", "")) not in ["leader", "support"]:
			return true
	return false

## Ancient Collector:
## While this model is leading a unit, at the end of your Command phase, if this unit is within
## range of an objective marker you control, that objective marker remains under your control.
static func secure_controlled_objectives(state: Dictionary) -> String:
	if str(state.get("phase", "")) != "command" or not AbilityCatalog.enabled(state):
		return ""
	var owner := int(state.get("active", -1))
	var leading_squads: Array[int] = []
	for model_id: int in state.get("units", {}):
		var unit: Dictionary = state.units[model_id]
		if not _is_trazyn(unit): continue
		if int(unit.get("owner", -1)) != owner or int(unit.get("wounds", 0)) <= 0 or not bool(unit.get("on_battlefield", true)):
			continue
		if _is_leading_unit(state, unit):
			var sq := int(unit.get("squad", -1))
			if sq not in leading_squads:
				leading_squads.append(sq)
	if leading_squads.is_empty(): return ""
	var secured: Array[String] = []
	var objectives: Array = state.get("mission", {}).get("objectives", [])
	for index in range(objectives.size()):
		var objective: Dictionary = objectives[index]
		if int(objective.get("controller", 0)) != owner or int(objective.get("secured", 0)) == owner:
			continue
		var in_range_of_obj := false
		for sq: int in leading_squads:
			for model_id: int in Geometry.alive(state, sq):
				if Objectives.in_range(state.units[model_id], objective):
					in_range_of_obj = true
					break
			if in_range_of_obj: break
		if in_range_of_obj and Objectives.secure(state, index, owner).is_empty():
			secured.append(str(objective.get("name", "Objective %d" % (index + 1))))
	return "Ancient Collector: " + ", ".join(secured) if not secured.is_empty() else ""

## Surrogate Hosts:
## At the start of your Command phase, if this model is on the battlefield, you can select
## one other friendly Necrons Infantry Character model on the battlefield (excluding Skorpekh Lord
## or Epic Hero models). The selected model is destroyed (ignoring any rules triggered on destruction)
## and this model is put in its place, with all of its wounds remaining (attaching as Leader if applicable).
static func _eligible_surrogate_target(state: Dictionary, trazyn_id: int, trazyn_owner: int, target_id: int) -> bool:
	if target_id == trazyn_id: return false
	var target: Dictionary = state.units[target_id]
	if int(target.get("owner", -1)) != trazyn_owner or int(target.get("wounds", 0)) <= 0:
		return false
	if not bool(target.get("on_battlefield", true)): return false
	var sq := int(target.get("squad", -1))
	if state.get("unit_abilities", {}).get("reserves", {}).has(sq): return false
	if int(target.get("embarked_transport", -1)) >= 0: return false
	if not (_has_keyword(target, "NECRONS") and _has_keyword(target, "INFANTRY") and _has_keyword(target, "CHARACTER")):
		return false
	if _has_keyword(target, "EPIC HERO"): return false
	if AbilityCatalog.identity(target) == "skorpekh-lord": return false
	return true

static func surrogate_choices(state: Dictionary, player: int) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if str(state.get("phase", "")) != "command" or int(state.get("active", -1)) != player:
		return result
	var used: Dictionary = state.get("unit_abilities", {}).get("used", {})
	var pkey := _phase_key(state)
	for model_id: int in state.get("units", {}):
		var trazyn: Dictionary = state.units[model_id]
		if not _is_trazyn(trazyn) or int(trazyn.get("owner", -1)) != player: continue
		if int(trazyn.get("wounds", 0)) <= 0 or not bool(trazyn.get("on_battlefield", true)): continue
		var sq := int(trazyn.get("squad", -1))
		if state.get("unit_abilities", {}).get("reserves", {}).has(sq): continue
		if int(trazyn.get("embarked_transport", -1)) >= 0: continue
		if used.get("%s:%d:%s" % [SURROGATE_ACTION, model_id, pkey], false): continue
		var targets: Array[int] = []
		for other_id: int in state.get("units", {}):
			if _eligible_surrogate_target(state, model_id, player, other_id):
				targets.append(other_id)
		targets.sort()
		for target_id: int in targets:
			var tname := str(state.units[target_id].get("name", "Character"))
			result.append({
				"label": "Surrogate Hosts %d: replace %s %d" % [model_id, tname, target_id],
				"action": SURROGATE_ACTION,
				"model": model_id,
				"target": target_id
			})
	return result

static func apply_surrogate(state: Dictionary, player: int, selected: Dictionary) -> Dictionary:
	var model_id := int(selected.get("model", -1))
	var target_id := int(selected.get("target", -1))
	var matched := false
	for opt: Dictionary in surrogate_choices(state, player):
		if int(opt.get("model", -1)) == model_id and int(opt.get("target", -1)) == target_id:
			matched = true
			break
	if not matched:
		return {"error": "Surrogate Hosts requires an eligible friendly Necrons Infantry Character on the battlefield at the start of your Command phase."}

	var trazyn: Dictionary = state.units[model_id]
	var target: Dictionary = state.units[target_id]
	var target_pos: Vector2 = target.position
	var target_elevation := float(target.get("elevation", 0.0))
	var old_squad := int(trazyn.get("squad", -1))
	var target_squad := int(target.get("squad", -1))
	var target_was_leading := false
	if target_squad >= 0 and state.get("squads", {}).has(target_squad) and bool(state.squads[target_squad].get("attached", false)):
		for member_id: int in Geometry.alive(state, target_squad):
			if member_id != target_id and str(state.units[member_id].get("attachment_role", "")) not in ["leader", "support"]:
				target_was_leading = true
				break

	# Destroy the selected model without triggering destruction rules.
	target.wounds = 0
	target.on_battlefield = false

	# Detach Trazyn from old squad if needed.
	if old_squad != target_squad and old_squad >= 0 and state.get("squads", {}).has(old_squad):
		var old_still_attached := false
		for member_id: int in Geometry.alive(state, old_squad):
			if member_id != model_id and str(state.units[member_id].get("attachment_role", "")) in ["leader", "support"]:
				old_still_attached = true
				break
		if not old_still_attached:
			state.squads[old_squad].attached = false

	# Put Trazyn in target's place with all of Trazyn's wounds remaining.
	trazyn.position = target_pos
	trazyn.elevation = target_elevation
	if target_was_leading:
		trazyn.squad = target_squad
		trazyn.attachment_role = "leader"
		state.squads[target_squad].attached = true
	else:
		trazyn.erase("attachment_role")
		if old_squad != target_squad:
			trazyn.squad = target_squad
			if state.get("squads", {}).has(target_squad):
				state.squads[target_squad].attached = false

	if not state.has("unit_abilities"): state.unit_abilities = {}
	if not state.unit_abilities.has("used"): state.unit_abilities.used = {}
	state.unit_abilities.used["%s:%d:%s" % [SURROGATE_ACTION, model_id, _phase_key(state)]] = true
	return {
		"error": "",
		"message": "Surrogate Hosts: Trazyn the Infinite destroyed %s %d and took its place." % [str(target.get("name", "Character")), target_id]
	}
