extends RefCounted
## Shared endpoint checks for revived models; game geometry remains ground-board scoped.
const Geometry = preload("res://scripts/edition_11/contact_movement.gd")
const Terrain = preload("res://scripts/edition_11/terrain.gd")
const Board = preload("res://scripts/rules.gd")
const EPSILON := 0.001

static func projected(state: Dictionary, current: Dictionary) -> Dictionary:
 var copy := state.duplicate(true)
 for model: int in current.get("wounds", {}): copy.units[model].wounds = current.wounds[model]
 for model: int in current.get("placements", {}):
  copy.units[model].wounds = current.get("wounds", {}).get(model, 1)
  copy.units[model].position = current.placements[model]
  if current.get("revive_on_battlefield", false): copy.units[model].on_battlefield = true
 return copy

static func error(state: Dictionary, model: int, destination: Vector2, current: Dictionary) -> String:
 if not destination.is_finite(): return "Choose a finite base-centre position."
 var unit: Dictionary = state.units[model]
 var radius: float = unit.radius
 var half := Board.half_board(state)
 if absf(destination.x) + radius > half.x + EPSILON or absf(destination.y) + radius > half.y + EPSILON: return "The returned model's whole base must fit on the battlefield."
 var copy := projected(state, current)
 copy.units[model].wounds = 1
 if current.get("revive_on_battlefield", false): copy.units[model].on_battlefield = true
 copy.units[model].position = destination
 var anchor_near := false
 for anchor: int in current.anchors:
  if state.units[anchor].wounds > 0 and Geometry.edge(copy.units[model], state.units[anchor]) <= 2.0 + EPSILON: anchor_near = true
 if not anchor_near: return "Return within 2 inches of a surviving model that was on the battlefield at Command entry; returned models cannot extend this anchor chain."
 for other: int in copy.units:
  if other == model or copy.units[other].wounds <= 0 or not copy.units[other].get("on_battlefield", true): continue
  var distance := Geometry.edge(copy.units[model], copy.units[other])
  if destination.distance_to(copy.units[other].position) < radius + float(copy.units[other].radius) - EPSILON: return "Returned bases cannot overlap another living or previewed model."
  if copy.units[other].squad == current.squad and distance > 9.0 + EPSILON: return "Keep the returned model within 9 inches of every model in its unit."
  if copy.units[other].owner != unit.owner and distance <= 2.0 + EPSILON and copy.units[other].squad not in current.engaged: return "A return cannot create engagement with a new enemy unit."
 # A return is a setup, not a movement path: only test the endpoint.
 return Terrain.path_error(copy, model, destination)
