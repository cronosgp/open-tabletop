extends SceneTree
const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const Groups = preload("res://scripts/edition_11/defender_groups.gd")
const P = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const U = preload("res://scripts/edition_11/unit_prevention.gd")
var failures := 0
func check(ok: bool, message: String) -> void:
 if not ok:
  push_error(message)
  failures += 1
func six() -> int: return 6
func four() -> int: return 4
func three() -> int: return 3
func entry(name: String, models: int = 1) -> Dictionary:
 return {"definition_id": "40kdc:11e:adeptus-astartes:" + name, "models": models, "copies": 1}
func fixture(attached: bool = true) -> Dictionary:
 var lists := F.selections()
 lists[1].entries = [entry("chaplain-in-terminator-armour"), entry("intercessor-squad", 5), entry("terminator-squad", 5)]
 var s := F.P.initial_state({"checked_rosters": true, "official_mission": true, "unit_abilities": true, "combat_doctrines": true, "reanimation_protocols": true, "awakened_dynasty": true, "core_stratagems": true, "manual_allocation": false}, lists)
 if s.has("error"): return s
 if attached: C.UnitActions.attach(s, 100, 5)
 s.mission.stage = "battle"
 s.phase = "shooting"
 s.turn = 3
 s.round = 2
 s.active = 1
 s.unit_abilities.setup_players = [1, 2]
 s.unit_abilities.battle_players = [1, 2]
 s.unit_abilities.window = {}
 s.unit_abilities.phase_key = C.UnitActions.key(s)
 s.awakened_dynasty.pending = []
 s.terrain.areas = []
 s.cp = {1: 0, 2: 0}
 for model: int in s.units:
  s.units[model].on_battlefield = true
  s.units[model].position = Vector2(-18,16) if s.units[model].owner == 1 else Vector2(18,16)
 for model: int in C.living(s, 5): s.units[model].position = Vector2(0,-8)
 s.units[100].position = Vector2(0,-10)
 return s
func equip(s: Dictionary, value: String) -> String:
 for option: Dictionary in C.unit_choices(s, 1):
  if option.action == "terminator-chaplain-shield" and option.value == value: return C.unit_action(s, 1, option, Vector2.ZERO, s.revision)
 return "Equipment choice unavailable"
func attack(s: Dictionary, mortal: bool) -> Dictionary:
 var weapon := {"name": "Fortitude probe", "attacks": 1, "skill": 2, "strength": 12, "ap": -6, "damage": 2, "range_inches": 24, "keywords": {"devastating-wounds": true} if mortal else {}}
 return C.AttackPlan.resolve(s, {"targets": [5], "batches": [{"target": 5, "weapon": weapon, "context": {"weapon_count": 1}}]}, six if mortal else three, false)
func _initialize() -> void: call_deferred("run")
func run() -> void:
 var s := fixture()
 check(not s.has("error"), "Terminator Chaplain admission failed")
 if s.has("error"):
  print(s)
  quit(1)
  return
 check(s.training_points[1] == 350 and s.units[100].max_wounds == 5 and is_equal_approx(s.units[100].radius, 25.0/25.4), "Terminator Chaplain stats/price/base incorrect")
 check(s.units[100].attachment_role == "leader" and C.UnitAbilities.has(s, 5, "deep-strike"), "Terminator Chaplain lost Leader/Deep Strike")
 check(not C.UnitAbilities.has(s, 5, "spiritual-leader") and "DEATHWING" not in s.units[100].keywords, "Ordinary Chaplain or chapter rules leaked")
 var sword: Dictionary = P.profile("chaplain-in-terminator-armour").melee[0].profiles.standard
 check(C.UnitAbilities.weapon(s, 500, 2, sword, true).keywords.get("lance", false) and not C.UnitAbilities.weapon(s, 500, 2, sword, false).keywords.get("lance", false), "Litany did not affect unit melee only")
 var prevented := C.Attacks.Prevention.resolve(3, 3, U.rules(s, 500), "mortal", four)
 check(prevented.error.is_empty() and prevented.lost == 0 and prevented.rolls.size() == 3, "Fortitude failed on mortal wounds")
 prevented = C.Attacks.Prevention.resolve(2, 3, U.rules(s, 500), "normal", six)
 check(prevented.lost == 2 and prevented.rolls.is_empty(), "Fortitude prevented normal wounds")
 var resolved := attack(s, true)
 check(resolved.error.is_empty() and resolved.units[500].wounds == 3, "Automatic mortal allocation missed Fortitude")
 resolved = attack(s, false)
 check(resolved.error.is_empty() and resolved.units[500].wounds == 1, "Automatic ordinary damage gained Fortitude")
 s.units[500].feel_no_pain = [{"target": 5, "against": "any"}]
 prevented = C.Attacks.Prevention.resolve(2, 3, U.rules(s, 500), "mortal", four)
 check(prevented.target == 4 and prevented.rolls.size() == 2, "Fortitude stacked rolls or ignored better protection")
 s.pending_attack = {"unit_prevention": U.snapshot(s)}
 s.units[100].wounds = 0
 check(U.rules(s, 500).size() == 2, "Effect vanished mid-attacking-unit after source loss")
 s.pending_attack = {}
 check(U.rules(s, 500).size() == 1, "Fortitude persisted after source loss and attack completion")
 s = fixture()
 s.units[100].on_battlefield = false
 check(U.rules(s, 500).is_empty(), "Off-board source granted Fortitude")
 s.units[100].on_battlefield = true
 s.unit_abilities.implementation = "historical"
 check(U.rules(s, 500).is_empty(), "Fortitude leaked to historical implementation")
 s = fixture(false)
 check(C.UnitActions.attachment_allowed(s, 100, 5) and not C.UnitActions.attachment_allowed(s, 100, 3), "Terminator/Tacticus attachment boundaries merged")
 s.phase = "deployment"
 s.unit_abilities.setup_players = []
 check(equip(s, "shield").is_empty() and s.units[100].max_wounds == 6 and s.units[100].wounds == 6 and s.units[100].ranged_weapons.is_empty(), "Relic Shield did not replace bolter and add bearer wound")
 check(s.units[100].melee_weapons.size() == 1 and C.AttackPlan.legal_targets(s, 100, false).is_empty(), "Shield removed crozius or retained shooting")
 C.UnitActions.attach(s, 100, 5)
 s.phase = "deployment"
 check(Groups.profile(s, 100).wounds_per_model == 6 and s.units[500].max_wounds == 3, "Attachment shared shield wounds")
 check(equip(s, "bolter").is_empty() and s.units[100].max_wounds == 5 and s.units[100].ranged_weapons == P.profile("chaplain-in-terminator-armour").ranged, "Shield swap not reversible after attachment")
 var reserve: Dictionary = {}
 for option: Dictionary in C.unit_choices(s, 1):
  if option.action == "reserve" and option.target == 5: reserve = option
 s.points_limit = 500
 check(s.squads[5].training_cost == 265, "Reserve cost omitted attached Character")
 check(not reserve.is_empty() and not C.unit_action(s, 1, reserve, Vector2.ZERO, s.revision).is_empty() and s.unit_abilities.reserves.is_empty(), "Combined reserve unit bypassed half-points limit")
 s.points_limit = 1000
 check(C.unit_action(s, 1, reserve, Vector2.ZERO, s.revision).is_empty() and s.unit_abilities.reserves[5].cost == 265, "Legal combined reserve cost incorrect")
 s = fixture(false)
 s.phase = "deployment"
 s.unit_abilities.setup_players = []
 reserve = {}
 for option: Dictionary in C.unit_choices(s, 1):
  if option.action == "reserve" and option.target == 1: reserve = option
 check(not reserve.is_empty() and C.unit_action(s, 1, reserve, Vector2.ZERO, s.revision).is_empty() and not s.units[100].on_battlefield, "Standalone Chaplain Deep Strike reserves unavailable")
 s = fixture()
 var probe := {"name": "Manual Fortitude probe", "attacks": 1, "skill": 2, "strength": 12, "ap": -6, "damage": 2, "range_inches": 24, "keywords": {"devastating-wounds": true}}
 C.Allocation.start(s, {"targets": [5], "batches": [{"target": 5, "weapon": probe, "context": {"weapon_count": 1}}]}, 2, 2, [], false, false, false)
 var waiting := C.Allocation.pump(s, six)
 check(waiting.error.is_empty() and not waiting.complete and 500 in C.Allocation.eligible(s), "Manual allocation did not wait for recipient")
 check(C.Allocation.apply(s, 500, six).error.is_empty() and s.units[500].wounds == 3, "Manual mortal allocation missed Fortitude")
 s = fixture()
 s.phase = "movement"
 s.pending_move = {"squad": 5, "hazard_remaining": 2}
 check(C.allocate_escape_wound(s, 1, 500, s.revision, six).is_empty() and s.units[500].wounds == 3 and s.last_escape_prevention.prevented == 1, "Escape mortal wounds missed Fortitude")
 s = fixture()
 s.units[500].feel_no_pain = "invalid"
 check(not C.Attacks.Prevention.validate(U.rules(s, 500)).is_empty(), "Unit grant hid invalid personal prevention")
 check(not C.UnitActions.attachment_allowed(s, 100, 5), "Reserved Character created orphan reserve through late attachment")
 print("Terminator Chaplain checks: %d failures" % failures)
 quit(0 if failures == 0 else 1)
