extends RefCounted
## Dependency-free source checks for OC; avoids Morale/Objectives preload cycles.
const Detection = preload("res://scripts/edition_11/detection_rules.gd")
static func honour(state: Dictionary, squad: int) -> int:
 if state.get("unit_abilities", {}).get("implementation", "") != Detection.ABILITY_IMPLEMENTATION_ID: return 0
 for model: Dictionary in state.units.values():
  if model.squad == squad and model.wounds > 0 and model.get("on_battlefield", true) and model.get("definition_id", "") == "40kdc:11e:adeptus-astartes:ancient": return 1
 return 0
