extends RefCounted
## Unit-wide grants are computed from living sources, not copied permanently to recipients.
const Geometry = preload("res://scripts/edition_11/contact_movement.gd")
const Detection = preload("res://scripts/edition_11/detection_rules.gd")
const MarineEnhancements = preload("res://scripts/edition_11/stormlance_enhancements.gd")
const Capabilities = preload("res://scripts/edition_11/capabilities.gd")
const AdeptOfTheOmnissiah = preload("res://scripts/edition_11/adept_of_the_omnissiah.gd")
const AbilityCatalog = preload("res://scripts/edition_11/unit_ability_catalog.gd")
const GRANTS := {
	"chaplain-grimaldus": [{"target": 5, "against": "any"}],
	"death-company-dreadnought": [{"target": 6, "against": "any"}],
	"death-company-marines": [{"target": 6, "against": "any"}],
	"death-company-marines-with-jump-packs": [{"target": 6, "against": "any"}],
	"death-company-captain": [{"target": 6, "against": "any"}],
	"death-company-captain-with-jump-pack": [{"target": 6, "against": "any"}],
	"lemartes": [{"target": 6, "against": "any"}],
	"chaplain-in-terminator-armour": [{"target": 4, "against": "mortal"}],
	"librarian-in-terminator-armour": [{"target": 4, "against": "psychic"}],
	"librarian": [{"target": 4, "against": "psychic"}],
	"librarian-in-phobos-armour": [{"target": 4, "against": "psychic"}],
	"chief-librarian-tigurius": [{"target": 4, "against": "psychic"}, {"target": 4, "against": "mortal"}],
	"mephiston": [{"target": 5, "against": "any"}],
	"ezekiel": [{"target": 4, "against": "psychic"}, {"target": 4, "against": "mortal"}],
	"lazarus": [{"target": 3, "against": "psychic"}, {"target": 3, "against": "mortal"}],
	"lion-eljonson": [{"target": 4, "against": "psychic"}, {"target": 4, "against": "mortal"}]}

static func grants(state: Dictionary, squad: int) -> Array:
 var result: Array = []
 if state.get("unit_abilities", {}).get("implementation", "") != Detection.ABILITY_IMPLEMENTATION_ID: return result
 for model: int in Geometry.alive(state, squad):
  var source := str(state.units[model].get("definition_id", "")).get_slice(":", 3)
  for rule: Dictionary in GRANTS.get(source, []):
   if rule not in result: result.append(rule.duplicate())
 return result

static func snapshot(state: Dictionary) -> Dictionary:
 var result := {}
 for squad: int in state.squads: result[squad] = grants(state, squad)
 return result

static func rules(state: Dictionary, model: int) -> Variant:
 var personal: Variant = state.units[model].get("feel_no_pain", [])
 if not personal is Array: return personal
 var result: Array = personal.duplicate(true)
 var squad: int = int(state.units[model].get("squad", -1))
 var layered: Dictionary = state.get("detachment_stratagems", {}).get("layered_ceramite", {}).get(squad, {})
 var phase_key := "%d:%s" % [int(state.get("turn", 0)), str(state.get("phase", ""))]
 if Capabilities.enabled(state, "ironstorm-layered-ceramite") and layered.get("phase_key", "") == phase_key:
  var layered_fnp := {"target": 5, "against": "mortal"}
  if layered_fnp not in result: result.append(layered_fnp)
 var spirits: Dictionary = state.get("detachment_stratagems", {}).get("spirits_of_iron", {}).get(squad, {})
 if Capabilities.enabled(state, "medusa-spirits-of-iron") and spirits.get("phase_key", "") == phase_key:
  var spirits_fnp := {"target": 5, "against": "mortal"}
  if spirits_fnp not in result: result.append(spirits_fnp)
 if MarineEnhancements.artificer_armour_bearer(state, model) or MarineEnhancements.armour_of_antoninus_bearer(state, model) or MarineEnhancements.standard_bearer(state, model):
  var enhancement_fnp := {"target": 5, "against": "any"}
  if enhancement_fnp not in result: result.append(enhancement_fnp)
 if MarineEnhancements.flesh_is_weak_bearer(state, model):
  var flesh_is_weak_fnp := {"target": 5, "against": "any"}
  if flesh_is_weak_fnp not in result: result.append(flesh_is_weak_fnp)
 if AdeptOfTheOmnissiah.active_for_damage(state, squad):
  var adept_fnp := {"target": 5, "against": "any"}
  if adept_fnp not in result: result.append(adept_fnp)
 if _lion_watchers_aura_active(state, model):
  var lion_aura_fnp := {"target": 5, "against": "psychic"}
  var lion_aura_mortal_fnp := {"target": 5, "against": "mortal"}
  if lion_aura_fnp not in result: result.append(lion_aura_fnp)
  if lion_aura_mortal_fnp not in result: result.append(lion_aura_mortal_fnp)
 if bool(state.get("unit_abilities", {}).get("watcher_active", {}).get(squad, false)):
  var watcher_fnp := {"target": 4, "against": "mortal"}
  if watcher_fnp not in result: result.append(watcher_fnp)
 if state.get("unit_abilities", {}).get("implementation", "") != Detection.ABILITY_IMPLEMENTATION_ID: return result
 if _seeker_active(state, model):
  var seeker_fnp := {"target": 4, "against": "any"}
  if seeker_fnp not in result: result.append(seeker_fnp)
 squad = int(state.units[model].squad)
 if state.squads.has(squad) and state.squads[squad].get("attached", false) and "CHARACTER" in state.units[model].get("keywords", []):
  var kaius_present := false
  for source: int in Geometry.alive(state, squad):
   if str(state.units[source].get("definition_id", "")).ends_with(":kaius-konorius") and source != model:
    kaius_present = true
    break
  if kaius_present:
   var veteran_bodyguard := {"target": 4, "against": "any"}
   if veteran_bodyguard not in result: result.append(veteran_bodyguard)
 var retained: Dictionary = state.get("pending_attack", {}).get("unit_prevention", {})
 for rule: Dictionary in retained.get(squad, grants(state, squad)):
  if rule not in result: result.append(rule.duplicate())
 return result

static func _lion_watchers_aura_active(state: Dictionary, model: int) -> bool:
 if state.get("unit_abilities", {}).get("implementation", "") != Detection.ABILITY_IMPLEMENTATION_ID or not state.units.has(model): return false
 var squad := int(state.units[model].get("squad", -1))
 var keywords: Array = state.units[model].get("keywords", [])
 if "ADEPTUS ASTARTES" not in keywords or not state.squads.has(squad): return false
 var owner := int(state.units[model].get("owner", -1))
 var dark_angels := str(state.get("marine_chapters", {}).get(owner, "")).strip_edges().to_upper() == "DARK ANGELS" or "DARK ANGELS" in keywords
 if not dark_angels: return false
 for source_squad: int in state.squads:
  if int(state.squads[source_squad].get("owner", -1)) != owner: continue
  var abilities: Array = state.get("unit_abilities", {}).get("lion_primarch", {}).get(source_squad, {}).get("abilities", [])
  if "no-hiding-from-the-watchers" not in abilities: continue
  for source: int in Geometry.alive(state, source_squad):
   if str(state.units[source].get("definition_id", "")).get_slice(":", 3) != "lion-eljonson" or not state.units[source].get("on_battlefield", true): continue
   if Geometry.distance_to_target(state, state.units[source], squad) <= 6.001: return true
 return false

static func _seeker_active(state: Dictionary, model: int) -> bool:
 if not state.units.has(model) or str(state.units[model].get("definition_id", "")).get_slice(":", 3) != "vulkan-hestan": return false
 var selected: int = int(state.get("unit_abilities", {}).get("seeker_objectives", {}).get(model, -1))
 var objectives: Array = state.get("mission", {}).get("objectives", [])
 if selected < 0 or selected >= objectives.size(): return false
 var unit: Dictionary = state.units[model]
 var objective: Dictionary = objectives[selected]
 if objective.get("kind", "") == "terrain":
  var bounds: Rect2 = objective.bounds
  return unit.position.distance_to(unit.position.clamp(bounds.position, bounds.end)) <= float(unit.radius) + 0.001
 return maxf(0.0, unit.position.distance_to(objective.position) - float(unit.radius) - 20.0 / 25.4) <= 3.001 and absf(float(unit.get("elevation", 0.0)) - float(objective.get("elevation", 0.0))) <= 5.0
