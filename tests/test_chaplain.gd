extends SceneTree
const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
## Canonical entries sort as Captain 100, Chaplain 300, bodyguard 500.
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
var failures := 0
func check(ok: bool, message: String) -> void:
 if not ok:
  push_error(message)
  failures += 1
func lists() -> Dictionary:
 var result := F.selections()
 result[1].entries = [
  {"definition_id": "40kdc:11e:adeptus-astartes:chaplain", "models": 1, "copies": 1},
  {"definition_id": "40kdc:11e:adeptus-astartes:intercessor-squad", "models": 5, "copies": 1},
  {"definition_id": "40kdc:11e:adeptus-astartes:captain", "models": 1, "copies": 1}]
 return result
func fixture(smoke_target: bool = false) -> Dictionary:
 var selection := lists()
 if smoke_target: selection[1].entries[1] = {"definition_id": "40kdc:11e:adeptus-astartes:eliminator-squad", "models": 3, "copies": 1}
 var s := F.P.initial_state({"checked_rosters": true, "official_mission": true, "unit_abilities": true, "combat_doctrines": true, "reanimation_protocols": true, "awakened_dynasty": true, "core_stratagems": true, "manual_allocation": false}, selection)
 if s.has("error"): return s
 s.awakened_dynasty.pending = []
 s.mission.stage = "battle"
 s.phase = "movement"
 s.turn = 3
 s.round = 2
 s.active = 1
 s.unit_abilities.setup_players = [1, 2]
 s.unit_abilities.battle_players = [1, 2]
 s.unit_abilities.window = {}
 s.unit_abilities.phase_key = C.UnitActions.key(s)
 s.terrain.areas = []
 s.cp = {1: 0, 2: 0}
 for model: int in s.units: s.units[model].position = Vector2(-20, -12) if s.units[model].owner == 1 else Vector2(20, 12)
 s.units[300].position = Vector2(0, -8)
 place(s, 6)
 s.squads[5].battle_shocked = true
 return s
func place(s: Dictionary, edge: float) -> void:
 for model: int in C.living(s, 5): s.units[model].position = s.units[300].position + Vector2(edge + s.units[model].radius + s.units[300].radius, 0)
func open_start(s: Dictionary) -> void:
 s.unit_abilities.erase("phase_key")
 s.unit_abilities.window = {}
 C.UnitActions.reconcile(s)
func choice(s: Dictionary, action: String, target: int = -999, model: int = -999) -> Dictionary:
 for row: Dictionary in C.unit_choices(s, 1):
  if row.action == action and (target == -999 or row.target == target) and (model == -999 or row.model == model): return row
 return {}
func _initialize() -> void: call_deferred("run")
func run() -> void:
 var s := fixture()
 check(not s.has("error"), "Chaplain admission failed")
 if s.has("error"):
  print(s)
  quit(1)
  return
 check(s.training_points[1] == 235 and s.squads[3].stats.invulnerable_target == 4 and s.units[300].radius == 20.0 / 25.4 and s.squads[3].stats.leadership_target == 5, "Chaplain price, base, leadership or invulnerable save incorrect")
 check(choice(s, "spiritual-leader").is_empty(), "Spiritual Leader available after phase start")
 open_start(s)
 check(C.UnitActions.actor(s) == 1 and not choice(s, "spiritual-leader", 5).is_empty(), "Six-inch start-window target rejected")
 var selected := choice(s, "spiritual-leader", 5)
 var before := var_to_str(s)
 check(not C.unit_action(s, 2, selected, Vector2.ZERO, s.revision).is_empty() and var_to_str(s) == before, "Wrong player cleared Battle-shock")
 check(not C.unit_action(s, 1, selected, Vector2.ZERO, s.revision - 1).is_empty() and var_to_str(s) == before, "Stale Spiritual Leader changed state")
 check(C.unit_action(s, 1, selected, Vector2.ZERO, s.revision).is_empty() and not s.squads[5].battle_shocked and s.cp[1] == 0, "Spiritual Leader failed or spent CP")
 s.squads[5].battle_shocked = true
 s.phase = "shooting"
 open_start(s)
 check(choice(s, "spiritual-leader").is_empty(), "Same-round second phase bypassed usage cap")
 s.turn += 1
 s.active = 2
 s.phase = "charge"
 open_start(s)
 check(choice(s, "spiritual-leader").is_empty(), "Opponent turn reset per-round usage")
 s.round += 1
 open_start(s)
 check(not choice(s, "spiritual-leader", 5).is_empty(), "New battle round did not restore Spiritual Leader")
 # No line of sight requirement, and the Chaplain may himself be shocked.
 s = fixture()
 s.squads[3].battle_shocked = true
 s.terrain.areas = [{"name": "Opaque screen", "category": "dense", "bounds": Rect2(2, -10, 1, 4), "features": [{"bounds": Rect2(2, -10, 1, 4), "height": 4.0, "blocks_end": true}]}]
 open_start(s)
 check(not C.Terrain.targeting(s, 300, 5).visible and not choice(s, "spiritual-leader", 5).is_empty() and not choice(s, "spiritual-leader", 3).is_empty(), "Visibility or source Battle-shock illegally blocked the ability")
 place(s, 6.02)
 open_start(s)
 check(choice(s, "spiritual-leader", 5).is_empty(), "Beyond-six-inch target offered")
 s = fixture()
 s.units[300].wounds = 0
 open_start(s)
 check(choice(s, "spiritual-leader").is_empty(), "Dead Chaplain offered the ability")
 s.units[300].wounds = 4
 s.units[300].on_battlefield = false
 open_start(s)
 check(choice(s, "spiritual-leader").is_empty(), "Off-board Chaplain offered the ability")
 for phase in ["command", "movement", "shooting", "charge", "fight"]:
  s = fixture()
  s.phase = phase
  s.active = 2
  open_start(s)
  check(not choice(s, "spiritual-leader", 5).is_empty(), "Missing Spiritual Leader start for phase " + phase)
 s = fixture()
 s.phase = "command"
 open_start(s)
 if C.Doctrines.needs_choice(s):
  check(C.select_combat_doctrine(s, 1, "none", s.revision).is_empty(), "Doctrine choice failed before Spiritual Leader")
 check(not choice(s, "spiritual-leader", 5).is_empty(), "Own Command doctrine decision consumed Spiritual Leader start window")
 s = fixture()
 s.phase = "deployment"
 s.unit_abilities.setup_players = []
 check(not choice(s, "warlord", -999, 300).is_empty() and C.UnitActions.attachment_allowed(s, 300, 5), "Chaplain Warlord or Leader declaration omitted")
 check(not C.UnitActions.attachment_allowed(s, 100, 3), "Captain attached to a Chaplain instead of a bodyguard")
 selected = choice(s, "attach", 5, 300)
 check(C.unit_action(s, 1, selected, Vector2.ZERO, s.revision).is_empty() and s.units[300].squad == 5 and s.units[300].attachment_role == "leader", "Chaplain attachment failed")
 check(not C.UnitActions.attachment_allowed(s, 100, 5), "Second Leader attached to the same bodyguard")
 # Bodyguard gains Lance while the source lives; it is not a flat wound bonus.
 var blade: Dictionary = Profiles.profile("intercessor-squad").melee[0].profiles.standard
 check(C.UnitAbilities.weapon(s, 500, 4, blade, true).keywords.get("lance", false) and not blade.keywords.has("lance"), "Litany did not reach bodyguards or mutated source weapon")
 var pistol: Dictionary = Profiles.profile("chaplain").ranged[0].profiles.standard
 check(not C.UnitAbilities.weapon(s, 300, 4, pistol, false).keywords.get("lance", false), "Litany affected ranged attacks")
 s.phase = "fight"
 s.unit_abilities.setup_players = [1, 2]
 s.unit_abilities.window = {}
 s.unit_abilities.phase_key = C.UnitActions.key(s)
 s.units[300].position = Vector2(0, -8)
 for model: int in C.living(s, 4): s.units[model].position = Vector2(s.units[300].radius + s.units[model].radius + 1.5, -8)
 var entries := [{"model": 300, "target": 4, "amount": 5, "weapon": "crozius-arcanum", "profile": "standard"}]
 var prepared := C.AttackPlan.prepare(s, 5, true, entries, true)
 if not prepared.error.is_empty(): print(prepared.error)
 check(prepared.error.is_empty() and prepared.batches[0].count == 7 and prepared.batches[0].context.get("wound_modifier", 0) == 0, "Crozius Cleave 1 or uncharged Lance incorrect")
 s.squads[5].charged = true
 prepared = C.AttackPlan.prepare(s, 5, true, entries, true)
 check(prepared.error.is_empty() and prepared.batches[0].context.wound_modifier == 1, "Charged Litany failed to apply Lance")
 s.units[300].wounds = 0
 check(not C.UnitAbilities.weapon(s, 500, 4, blade, true).keywords.get("lance", false), "Dead Chaplain retained Litany")
 # A start-phase unit ability may restore eligibility for a start-phase stratagem.
 s = fixture(true)
 s.active = 2
 s.phase = "shooting"
 s.cp[1] = 1
 open_start(s)
 var smoke: Dictionary = {}
 for row: Dictionary in C.unit_choices(s, 1):
  if row.value == "smokescreen": smoke = row
 check(smoke.is_empty(), "Shocked Eliminators offered Smokescreen before restoration")
 selected = choice(s, "spiritual-leader", 5)
 check(C.unit_action(s, 1, selected, Vector2.ZERO, s.revision).is_empty(), "Spiritual Leader failed in a mixed start window")
 for row: Dictionary in C.unit_choices(s, 1):
  if row.value == "smokescreen": smoke = row
 var smoke_recorded := false
 check(not smoke.is_empty() and C.unit_action(s, 1, smoke, Vector2.ZERO, s.revision).is_empty() and s.cp[1] == 0, "Restored unit could not use Smokescreen in the same start window")
 for record: Dictionary in s.core_reactions.smoke:
  if int(record.get("squad", -1)) == 5: smoke_recorded = true
 check(smoke_recorded, "Smokescreen did not record the eligible squad")
 var invalid := lists()
 invalid[1].entries[0].copies = 3
 check(not C.RosterValidation.admit(invalid[1]).error.is_empty(), "Chaplain repetition cap omitted")
 var catalog := F.P.Training.Capabilities.current_catalog_choice({"id": "openhammer:11e:Space%20Marines:ceb5-55c7-2d49-d952", "edition": "11e", "faction": "Space Marines"})
 check(catalog.get("options", []) == [{"models": 1, "cost": 60}], "Chaplain catalog price/composition incorrect")
 print("Chaplain checks: %d failures" % failures)
 quit(1 if failures else 0)
