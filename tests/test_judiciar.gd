extends SceneTree
const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const Groups = preload("res://scripts/edition_11/defender_groups.gd")
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Roster = preload("res://scripts/edition_11/roster_validation.gd")
var failures := 0
func check(ok: bool, message: String) -> void:
 if not ok:
  push_error(message)
  failures += 1
func selection(body: String = "intercessor-squad", lieutenant: bool = false) -> Dictionary:
 var entries: Array = [{"definition_id": "40kdc:11e:adeptus-astartes:judiciar", "models": 1, "copies": 1}, {"definition_id": "40kdc:11e:adeptus-astartes:" + body, "models": 5, "copies": 1}]
 if lieutenant: entries.append({"definition_id": "40kdc:11e:adeptus-astartes:lieutenant", "models": 1, "copies": 1})
 return {"schema_version": 2, "faction": "Space Marines", "category": "incursion", "points_limit": 1000, "entries": entries}
func fixture() -> Dictionary:
 var lists := F.selections()
 lists[1] = selection()
 var s := F.P.initial_state({"checked_rosters": true, "official_mission": true, "unit_abilities": true, "combat_doctrines": true, "reanimation_protocols": true, "awakened_dynasty": true, "core_stratagems": true, "manual_allocation": true}, lists)
 if not s.has("error"):
  s.mission.stage = "battle"
  s.awakened_dynasty.pending = []
  s.active = 1
  s.unit_abilities.window = {}
 return s
func dice() -> int: return 4
func attack(s: Dictionary, melee: bool) -> Dictionary:
 var weapon := {"name": "Conditional save probe", "attacks": 1, "skill": 2, "strength": 10, "ap": -6, "damage": 1, "range_inches": 24, "keywords": {}}
 return C.AttackPlan.resolve(s, {"targets": [3], "batches": [{"target": 3, "weapon": weapon, "context": {"weapon_count": 1}}]}, dice, melee)
func _initialize() -> void: call_deferred("run")
func run() -> void:
 var s := fixture()
 check(not s.has("error"), "Judiciar admission failed")
 if s.has("error"):
  print(s)
  quit(1)
  return
 # Canonical sort puts Intercessors 100 and Judiciar 300.
 check(F.P.Training.Capabilities.canonical_id("Space Marines", "openhammer:11e:Space%20Marines:8dcb-987c-1ab4-b976") == "40kdc:11e:adeptus-astartes:judiciar", "Judiciar legacy identity did not resolve to current profile")
 check(s.training_points[1] == 135 and s.units[300].max_wounds == 4 and is_equal_approx(s.units[300].radius, 20.0 / 25.4), "Judiciar price, wounds or base incorrect")
 check(Groups.profile(s, 300).invulnerable_target == 0 and Groups.profile(s, 300, true).invulnerable_target == 4, "Judiciar melee protection leaked into shooting")
 check("EXPLOSIVES" not in s.units[300].keywords, "Judiciar incorrectly admitted Explosives")
 var blade: Dictionary = Profiles.profile("judiciar").melee[0].profiles.standard
 check(blade.attacks == 5 and blade.skill == 2 and blade.strength == 7 and blade.ap == -2 and blade.damage == 2 and blade.keywords.get("precision", false) and blade.keywords.get("devastating-wounds", false), "Executioner blade profile incorrect")
 var ranged := attack(s, false)
 var melee := attack(s, true)
 check(ranged.error.is_empty() and ranged.units[300].wounds == 3, "Automatic ranged resolution incorrectly used melee save")
 check(melee.error.is_empty() and melee.units[300].wounds == 4, "Automatic melee resolution lost conditional save")
 # Conditional defenses must validate before choosing the attack context.
 var validation := s.duplicate(true)
 validation.units[300].defense = {"invulnerable_target": 2, "melee_invulnerable_target": 4}
 check(Groups.profile(validation, 300, true).invulnerable_target == 2, "Conditional save replaced a better universal save")
 validation.units[300].defense.melee_invulnerable_target = 1
 check(not Groups.profile(validation, 300).error.is_empty(), "Invalid conditional save bypassed ranged validation")
 s.phase = "deployment"
 s.unit_abilities.setup_players = []
 var attach: Dictionary = {}
 for row: Dictionary in C.unit_choices(s, 1):
  if row.action == "attach" and row.model == 300 and row.target == 1: attach = row
 check(not attach.is_empty(), "Judiciar Support attachment omitted")
 if attach.is_empty():
  quit(1)
  return
 check(not Roster.seal(s, 1).is_empty(), "Unattached Support passed checked formation")
 check(C.unit_action(s, 1, attach, Vector2.ZERO, s.revision).is_empty(), "Judiciar attachment rejected")
 check(s.units[300].attachment_role == "support" and s.units[300].squad == 1, "Judiciar consumed Leader slot")
 check(Groups.profile(s, 300).invulnerable_target == 0 and Groups.profile(s, 300, true).invulnerable_target == 4 and Groups.profile(s, 100, true).invulnerable_target == 0, "Attachment lost or shared conditional invulnerable save")
 s.pending_attack = {"melee": true, "ability_saves": {}}
 var current := {"weapon": {"ap": -6}}
 check(C.Allocation.saved(s, current, 300, 4) and not C.Allocation.saved(s, current, 100, 4) and not C.Allocation.saved(s, current, 300, 1), "Manual/Precision conditional save incorrect")
 s.pending_attack.melee = false
 check(not C.Allocation.saved(s, current, 300, 4), "Manual ranged save used melee protection")
 s.pending_attack = {}
 s.phase = "fight"
 s.fight_step = "attacks"
 s.fight_selected = -1
 for squad: int in s.squads:
  s.squads[squad].fought = false
  s.squads[squad].charged = false
  s.squads[squad].was_engaged = true
 check(C.FightQueue.pool(s) == [1] and C.FightQueue.first(s, 1), "Tempormortis did not prioritize bodyguards")
 check(C.FightQueue.choose_actor(s, 2) and s.fight_actor == 1, "Fights First failed to choose eligible owner")
 var enemy: int = 2
 s.squads[enemy].charged = true
 check(C.FightQueue.choose_actor(s, 2) and s.fight_actor == 2 and 1 in C.FightQueue.pool(s), "Opponent selection priority lost when both sides fight first")
 s.squads[enemy].charged = false
 var implementation: String = s.unit_abilities.implementation
 s.unit_abilities.implementation = "historical"
 check(not C.FightQueue.first(s, 1), "Tempormortis leaked into historical implementation")
 s.unit_abilities.implementation = implementation
 s.units[300].on_battlefield = false
 check(not C.FightQueue.first(s, 1), "Off-board Judiciar retained Tempormortis")
 s.units[300].on_battlefield = true
 s.units[300].wounds = 0
 check(not C.FightQueue.first(s, 1) and C.FightQueue.pool(s).size() > 1, "Destroyed Judiciar retained Tempormortis")
 s.squads[1].charged = true
 check(C.FightQueue.first(s, 1), "Source loss removed charge priority")
 s.squads[1].charged = false
 s.squads[1].fights_first = true
 check(C.FightQueue.first(s, 1), "Source loss removed Counteroffensive priority")
 check(not Roster.admit(selection("hellblaster-squad")).error.is_empty(), "Judiciar admitted only ineligible Hellblaster bodyguard")
 check(not Roster.admit(selection("intercessor-squad", true)).error.is_empty(), "Two Supports admitted with one Support slot")
 var legal := selection("hellblaster-squad", true)
 legal.entries.append({"definition_id": "40kdc:11e:adeptus-astartes:intercessor-squad", "models": 5, "copies": 1})
 check(Roster.admit(legal).error.is_empty(), "Valid shared bodyguard matching rejected")
 for body: String in ["intercessor-squad", "assault-intercessor-squad", "infernus-squad", "sternguard-veteran-squad"]:
  check(Roster.admit(selection(body)).error.is_empty(), "Legal Judiciar bodyguard rejected: " + body)
 print("Judiciar checks: %d failures" % failures)
 quit(0 if failures == 0 else 1)
