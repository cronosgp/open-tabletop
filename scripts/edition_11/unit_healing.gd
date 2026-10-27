extends RefCounted
## Core 02.02.04 healing budget, with owner-selected wounds and revive previews.
const Placement = preload("res://scripts/edition_11/return_placement.gd")
const Geometry = preload("res://scripts/edition_11/contact_movement.gd")
const Groups = preload("res://scripts/edition_11/defender_groups.gd")

static func wounded(state: Dictionary, squad: int) -> Array[int]:
 var result: Array[int] = []
 for model: int in Geometry.alive(state, squad):
  if state.units[model].wounds < state.units[model].max_wounds: result.append(model)
 return result

static func returnable(state: Dictionary, squad: int) -> Array[int]:
 var result: Array[int] = []
 for model: int in state.units:
  var unit: Dictionary = state.units[model]
  if unit.squad == squad and unit.wounds == 0 and not Groups.character(unit): result.append(model)
 return result

static func needed(state: Dictionary, squad: int) -> bool:
 return not wounded(state, squad).is_empty() or not returnable(state, squad).is_empty()

static func begin(state: Dictionary, squad: int, amount: int, source: int, roll: Dictionary) -> Dictionary:
 if amount <= 0 or amount > 100 or Geometry.alive(state, squad).is_empty(): return {"error": "Invalid unit healing budget or empty unit."}
 var engaged: Array[int] = []
 for target: int in state.squads:
  if state.squads[target].owner == state.squads[squad].owner: continue
  for model: int in Geometry.alive(state, squad):
   if Geometry.distance_to_target_at_height(state, state.units[model], target) <= 2.001:
    engaged.append(target)
    break
 state.unit_abilities.window = {"kind": "healing", "revive_on_battlefield": true, "owners": [state.squads[squad].owner], "squad": squad, "source": source, "total": amount, "remaining": amount, "roll": roll.duplicate(true), "wounds": {}, "placements": {}, "anchors": state.unit_abilities.get("anchors", {}).get(squad, Geometry.alive(state, squad)).duplicate(), "engaged": engaged, "placement_failure_declared": false}
 _forced(state)
 return {"error": ""}

static func projected(state: Dictionary) -> Dictionary:
 return Placement.projected(state, state.unit_abilities.window)

static func _forced(state: Dictionary) -> void:
 var w: Dictionary = state.unit_abilities.window
 while w.remaining > 0:
  var view := projected(state)
  var models := wounded(view, w.squad)
  if models.size() == 1:
   var model: int = models[0]
   var amount := mini(w.remaining, int(view.units[model].max_wounds - view.units[model].wounds))
   w.wounds[model] = int(view.units[model].wounds) + amount
   w.remaining -= amount
  elif models.is_empty() and returnable(view, w.squad).is_empty():
   w.remaining = 0
  else: return

static func choices(state: Dictionary) -> Array[Dictionary]:
 var w: Dictionary = state.unit_abilities.window
 var result: Array[Dictionary] = []
 var view := projected(state)
 if w.remaining > 0:
  var models := wounded(view, w.squad)
  if not models.is_empty():
   for model: int in models: result.append({"action": "heal-wound", "model": model, "label": "Heal model %d: +1 wound (%d left)" % [model, w.remaining]})
  else:
   for model: int in returnable(view, w.squad): result.append({"action": "heal-revive", "model": model, "label": "Return model %d: place preview (%d left)" % [model, w.remaining]})
   result.append({"action": "heal-unplaceable", "model": -1, "label": "Declare no legal return position; discard remaining healing"})
 for model: int in w.placements: result.append({"action": "heal-place", "model": model, "label": "Adjust returned model %d preview" % model})
 result.append({"action": "heal-reset", "model": -1, "label": "Reset healing choices (keep the same roll)"})
 if w.remaining == 0: result.append({"action": "heal-confirm", "model": -1, "label": "Confirm healing and returned positions"})
 return result

static func apply(state: Dictionary, action: String, model: int, point: Vector2) -> Dictionary:
 var w: Dictionary = state.unit_abilities.window
 var view := projected(state)
 if action == "heal-wound":
  if w.remaining <= 0 or model not in wounded(view, w.squad): return {"error": "Select a wounded living model in the healing unit."}
  w.wounds[model] = int(view.units[model].wounds) + 1
  w.remaining -= 1
 elif action in ["heal-revive", "heal-place"]:
  if action == "heal-revive" and (w.remaining <= 0 or not wounded(view, w.squad).is_empty() or model not in returnable(view, w.squad)): return {"error": "Heal surviving wounded models before returning a non-Character model."}
  if action == "heal-place" and not w.placements.has(model): return {"error": "Select an existing returned-model preview."}
  var error := Placement.error(state, model, point, w)
  if not error.is_empty(): return {"error": error}
  if action == "heal-revive":
   w.wounds[model] = 1
   w.remaining -= 1
  w.placements[model] = point
 elif action == "heal-unplaceable":
  if not wounded(view, w.squad).is_empty() or w.remaining <= 0: return {"error": "Available wounds must heal living wounded models first."}
  w.remaining = 0
  w.placement_failure_declared = true
 elif action == "heal-reset":
  w.wounds = {}
  w.placements = {}
  w.remaining = w.total
  w.placement_failure_declared = false
 elif action == "heal-confirm":
  if w.remaining != 0: return {"error": "Resolve the healing budget first."}
  for returned: int in w.placements:
   var error := Placement.error(state, returned, w.placements[returned], w)
   if not error.is_empty(): return {"error": error}
  if not w.placements.is_empty() and not Geometry.coherent(view, w.squad): return {"error": "Returned models must leave the unit in coherency."}
  var restored := 0
  for id: int in w.wounds:
   restored += int(w.wounds[id]) - int(state.units[id].wounds)
   state.units[id].wounds = w.wounds[id]
  for id: int in w.placements:
   state.units[id].position = w.placements[id]
   state.units[id].on_battlefield = true
  state.unit_abilities.last_healing = {"squad": w.squad, "source": w.source, "roll": w.roll.duplicate(true), "budget": w.total, "restored": restored, "discarded": int(w.total) - restored, "returned": w.placements.duplicate(true), "placement_failure_declared": w.placement_failure_declared}
  state.unit_abilities.window = {}
  return {"error": ""}
 else: return {"error": "Unknown healing choice."}
 _forced(state)
 return {"error": ""}
