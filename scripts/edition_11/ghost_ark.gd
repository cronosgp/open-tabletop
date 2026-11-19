extends RefCounted
## Source-bounded Ghost Ark (000000543): Repair Barge.
const AbilityCatalog = preload("res://scripts/edition_11/unit_ability_catalog.gd")
const Geometry = preload("res://scripts/edition_11/contact_movement.gd")
const Reanimation = preload("res://scripts/edition_11/reanimation_protocols.gd")

const IDENTITY := "ghost-ark"
const WINDOW := "ghost-ark-repair-barge"

static func _living(state: Dictionary, squad: int) -> Array[int]:
	var result: Array[int] = []
	for model: int in state.get("units", {}):
		var u: Dictionary = state.units[model]
		if int(u.get("squad", -1)) == squad and int(u.get("wounds", 0)) > 0 and bool(u.get("on_battlefield", true)):
			result.append(model)
	result.sort()
	return result

static func _has_necron_warriors_keyword(state: Dictionary, squad: int) -> bool:
	for model: int in _living(state, squad):
		if "NECRON WARRIORS" in state.units[model].get("keywords", []):
			return true
	return false

static func _eligible_targets_for_ark(state: Dictionary, ark_model: int, wounded_targets: Array[int]) -> Array[int]:
	var result: Array[int] = []
	if not state.get("units", {}).has(ark_model): return result
	var ark: Dictionary = state.units[ark_model]
	if int(ark.get("wounds", 0)) <= 0 or not bool(ark.get("on_battlefield", true)): return result
	var turn := int(state.get("turn", 0))
	var used: Dictionary = state.get("unit_abilities", {}).get("used", {})
	if bool(used.get("repair-barge-ark:%d:%d" % [ark_model, turn], false)): return result
	var owner := int(ark.get("owner", -1))
	for target: int in wounded_targets:
		if not state.get("squads", {}).has(target) or int(state.squads[target].get("owner", -2)) != owner: continue
		if bool(used.get("repair-barge-target:%d:%d" % [target, turn], false)): continue
		if not _has_necron_warriors_keyword(state, target): continue
		if not Reanimation.supported_unit(state, target): continue
		for m: int in _living(state, target):
			if Geometry.edge(state.units[m], ark) <= 3.001:
				result.append(target)
				break
	result.sort()
	return result

## Repair Barge:
## Once per turn, just after an enemy unit finishes making its attacks, if one or more
## friendly NECRON WARRIORS units within 3" of this model lost one or more wounds as a
## result of those attacks, this model can use this ability. If it does, select one of
## those NECRON WARRIORS units; that unit's Reanimation Protocols activate. The same
## NECRON WARRIORS unit cannot be selected for this ability more than once per turn.
static func open_after_enemy_attacks(state: Dictionary, attacker: int, pools: Array) -> bool:
	if not AbilityCatalog.enabled(state) or not Reanimation.enabled(state): return false
	if not state.get("squads", {}).has(attacker): return false
	var attacker_owner := int(state.squads[attacker].get("owner", -1))
	var wounded_targets: Array[int] = []
	for pool_val: Variant in pools:
		if not pool_val is Dictionary: continue
		var pool: Dictionary = pool_val
		var target := int(pool.get("target_squad", -1))
		if not state.get("squads", {}).has(target) or int(state.squads[target].get("owner", -1)) == attacker_owner: continue
		var lost_wounds := int(pool.get("damage", 0)) > 0 or int(pool.get("models_destroyed", 0)) > 0
		if not lost_wounds:
			for alloc: Variant in pool.get("allocations", []):
				if alloc is Dictionary and (int(alloc.get("damage", 0)) > 0 or int(alloc.get("wounds_lost", 0)) > 0):
					lost_wounds = true
					break
		if lost_wounds and target not in wounded_targets:
			wounded_targets.append(target)
	if wounded_targets.is_empty(): return false
	var queue: Array[Dictionary] = []
	var ark_models: Array[int] = []
	for model: int in state.get("units", {}):
		var u: Dictionary = state.units[model]
		if int(u.get("owner", -1)) == attacker_owner or int(u.get("wounds", 0)) <= 0 or not bool(u.get("on_battlefield", true)): continue
		if AbilityCatalog.identity(u) == IDENTITY: ark_models.append(model)
	ark_models.sort()
	for ark_model: int in ark_models:
		var targets := _eligible_targets_for_ark(state, ark_model, wounded_targets)
		if not targets.is_empty():
			queue.append({"ark_model": ark_model, "targets": targets, "owner": int(state.units[ark_model].owner)})
	if queue.is_empty(): return false
	var first: Dictionary = queue.pop_front()
	var previous: Dictionary = state.get("unit_abilities", {}).get("window", {}).duplicate(true)
	state.unit_abilities.window = {
		"kind": WINDOW,
		"owners": [int(first.owner)],
		"model": int(first.ark_model),
		"squad": int(state.units[int(first.ark_model)].squad),
		"eligible_targets": first.targets,
		"wounded_targets": wounded_targets,
		"queue": queue,
		"resume_window": previous
	}
	return true

static func _advance(state: Dictionary, window: Dictionary) -> void:
	var wounded: Array[int] = []
	for t: Variant in window.get("wounded_targets", []): wounded.append(int(t))
	var queue: Array = window.get("queue", [])
	while not queue.is_empty():
		var next: Dictionary = queue.pop_front()
		var ark_model := int(next.get("ark_model", -1))
		var targets := _eligible_targets_for_ark(state, ark_model, wounded)
		if not targets.is_empty():
			state.unit_abilities.window = {
				"kind": WINDOW,
				"owners": [int(next.get("owner", -1))],
				"model": ark_model,
				"squad": int(state.units[ark_model].squad),
				"eligible_targets": targets,
				"wounded_targets": wounded,
				"queue": queue,
				"resume_window": window.get("resume_window", {}).duplicate(true)
			}
			return
	state.unit_abilities.window = window.get("resume_window", {}).duplicate(true)

static func choices(state: Dictionary, player: int) -> Array[Dictionary]:
	var window: Dictionary = state.get("unit_abilities", {}).get("window", {})
	if window.get("kind", "") != WINDOW or window.get("owners", []) != [player]: return []
	var ark_model := int(window.get("model", -1))
	var wounded: Array[int] = []
	for t: Variant in window.get("wounded_targets", []): wounded.append(int(t))
	var targets := _eligible_targets_for_ark(state, ark_model, wounded)
	var result: Array[Dictionary] = []
	for target: int in targets:
		result.append({
			"label": "Repair Barge %d: activate Reanimation Protocols for %s" % [ark_model, str(state.squads[target].get("name", "Necron Warriors"))],
			"action": "ghost-ark-repair-barge-use",
			"model": ark_model,
			"target": target,
			"value": "use"
		})
	result.append({
		"label": "Repair Barge %d: pass" % ark_model,
		"action": "ghost-ark-repair-barge-pass",
		"model": ark_model,
		"target": int(window.get("squad", -1)),
		"value": "pass"
	})
	return result

static func apply(state: Dictionary, player: int, selected: Dictionary, roller: Callable) -> Dictionary:
	var window: Dictionary = state.get("unit_abilities", {}).get("window", {})
	if window.get("kind", "") != WINDOW or window.get("owners", []) != [player] or selected not in choices(state, player):
		return {"error": "No matching Repair Barge decision is pending."}
	if str(selected.get("action", "")) == "ghost-ark-repair-barge-pass":
		_advance(state, window)
		return {"error": "", "message": "Repair Barge declined."}
	var ark_model := int(selected.get("model", -1))
	var target := int(selected.get("target", -1))
	var turn := int(state.get("turn", 0))
	state.unit_abilities.used["repair-barge-ark:%d:%d" % [ark_model, turn]] = true
	state.unit_abilities.used["repair-barge-target:%d:%d" % [target, turn]] = true
	_advance(state, window)
	if not state.reanimation.has("anchors"): state.reanimation.anchors = {}
	state.reanimation.anchors[target] = Geometry.alive(state, target)
	state.reanimation.pending = {"kind": "repair_barge", "player": player, "turn": turn, "remaining": [target], "current": {}, "results": []}
	return Reanimation.roll_unit(state, target, roller)
