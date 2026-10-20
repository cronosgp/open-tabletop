extends SceneTree
const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const H = preload("res://scripts/edition_11/unit_healing.gd")
const S = preload("res://scripts/edition_11/support_attachments.gd")
var failures := 0
func check(ok: bool, message: String) -> void:
 if not ok:
  push_error(message)
  failures += 1
func six() -> int: return 6
func entry(name: String, models: int = 1) -> Dictionary:
 return {"definition_id": "40kdc:11e:adeptus-astartes:" + name, "models": models, "copies": 1}
func fixture() -> Dictionary:
 var lists := F.selections()
 lists[1].entries = [entry("apothecary"), entry("captain"), entry("intercessor-squad", 5), entry("lieutenant")]
 var s := F.P.initial_state({"checked_rosters": true, "official_mission": true, "unit_abilities": true, "combat_doctrines": true, "reanimation_protocols": true, "awakened_dynasty": true, "core_stratagems": true, "manual_allocation": false}, lists)
 if s.has("error"): return s
 C.UnitActions.attach(s, 700, 5)
 C.UnitActions.attach(s, 100, 5)
 s.mission.stage = "battle"
 s.phase = "command"
 s.turn = 3
 s.round = 2
 s.active = 1
 s.unit_abilities.setup_players = [1, 2]
 s.unit_abilities.battle_players = [1, 2]
 s.unit_abilities.window = {}
 s.unit_abilities.phase_key = C.UnitActions.key(s)
 s.combat_doctrines.selected_turn[1] = 3
 s.awakened_dynasty.pending = []
 s.terrain.areas = []
 s.cp = {1: 0, 2: 0}
 for model: int in s.units:
  s.units[model].on_battlefield = true
  s.units[model].position = Vector2(-18, 16) if s.units[model].owner == 1 else Vector2(18, 16)
 var positions := {500: Vector2(0,-8), 501: Vector2(1.7,-8), 502: Vector2(3.4,-8), 503: Vector2(0,-6.3), 504: Vector2(1.7,-6.3), 100: Vector2(0,-9.8), 700: Vector2(1.8,-9.8)}
 for model: int in positions: s.units[model].position = positions[model]
 s.unit_abilities.anchors = {5: C.living(s, 5)}
 return s
func choose(s: Dictionary, action: String, model: int = -1, point: Vector2 = Vector2.ZERO) -> String:
 for option: Dictionary in C.unit_choices(s, 1):
  if option.action == action and (model == -1 or option.model == model): return C.unit_action(s, 1, option, point, s.revision, six)
 return "Choice unavailable: " + action
func _initialize() -> void: call_deferred("run")
func run() -> void:
 var s := fixture()
 check(not s.has("error"), "Apothecary admission failed")
 if s.has("error"):
  print(s)
  quit(1)
  return
 check(s.training_points[1] == 270 and s.units[100].max_wounds == 4, "Apothecary price/profile incorrect")
 check(s.units[100].attachment_role == "support" and s.units[700].squad == 5, "Apothecary/Lieutenant attachment failed")
 check(not C.UnitActions.attachment_allowed(s, 300, 5), "Unsupported third attached Character admitted")
 check(S.matching_error([entry("apothecary"), entry("lieutenant"), entry("intercessor-squad", 5)]).is_empty(), "Pair requires two bodyguards")
 check(not S.matching_error([entry("apothecary"), entry("apothecary"), entry("intercessor-squad", 5)]).is_empty(), "Two Apothecaries share a bodyguard")
 check(C.UnitActions.healing_choices(s, 1).is_empty(), "Healthy unit offered healing")
 s.units[100].wounds = 2
 s.units[500].wounds = 1
 check(choose(s, "narthecium").is_empty(), "Narthecium unavailable")
 check(s.unit_abilities.window.total == 4 and s.units[100].wounds == 2 and s.units[500].wounds == 1, "Healing rolled wrong budget or mutated before confirmation")
 check(choose(s, "heal-wound", 500).is_empty(), "Owner cannot choose wounded survivor")
 check(s.units[500].wounds == 1 and choose(s, "heal-confirm").is_empty(), "Healing did not remain transactional")
 check(s.units[100].wounds == 4 and s.units[500].wounds == 2 and s.unit_abilities.last_healing.restored == 3 and s.unit_abilities.last_healing.discarded == 1, "Healing exceeded max wounds or lost excess accounting")
 check(C.UnitActions.healing_choices(s, 1).is_empty(), "Narthecium repeated this turn")
 s = fixture()
 s.units[100].wounds = 3
 s.units[501].wounds = 0
 s.units[502].wounds = 0
 s.units[300].wounds = 0
 check(choose(s, "narthecium").is_empty() and s.unit_abilities.window.remaining == 3, "Living model not healed before return")
 var before := var_to_str(s)
 check(not choose(s, "heal-revive", 501, s.units[500].position).is_empty() and var_to_str(s) == before, "Overlapping revival changed state")
 check(choose(s, "heal-revive", 501, Vector2(1.7,-8)).is_empty(), "Legal return rejected")
 check(H.projected(s).units[501].wounds == 2 and s.units[501].wounds == 0 and s.unit_abilities.window.remaining == 1, "Returned model not healed before next return")
 check(choose(s, "heal-reset").is_empty() and s.unit_abilities.window.total == 4 and s.unit_abilities.window.remaining == 3, "Reset changed budget or rerolled")
 check(choose(s, "heal-revive", 501, Vector2(1.7,-8)).is_empty() and choose(s, "heal-revive", 502, Vector2(3.4,-8)).is_empty(), "Multiple revival failed")
 check(choose(s, "heal-confirm").is_empty() and s.units[501].wounds == 2 and s.units[502].wounds == 1 and s.units[300].wounds == 0, "Revival confirmation wrong or revived Character")
 s = fixture()
 s.units[500].wounds = 1
 check(C.UnitActions.offer_command_healing(s) and s.unit_abilities.window.kind == "healing-order", "Command healing order absent")
 check(choose(s, "narthecium").is_empty() and choose(s, "heal-confirm").is_empty(), "Mandatory healing order deadlocked")
 s = fixture()
 s.units[500].wounds = 1
 s.squads[5].battle_shocked = true
 check(choose(s, "narthecium").is_empty(), "Battle-shock blocked non-stratagem healing")
 s = fixture()
 s.phase = "shooting"
 check(C.UnitActions.healing_choices(s, 1).is_empty(), "Narthecium outside Command")
 s.phase = "command"
 s.active = 2
 check(C.UnitActions.healing_choices(s, 1).is_empty(), "Narthecium on opponent turn")
 s = fixture()
 s.units[500].wounds = 1
 check(C.advance_phase(s, 1, s.revision, six).is_empty() and s.phase == "command" and s.unit_abilities.window.get("kind", "") == "healing-order", "Command advance skipped useful healing")
 s = fixture()
 for id: int in C.living(s, 2): s.units[id].position = Vector2(0,-11.5)
 var plan := C.AttackPlan.single_target(s, 5, 2, true)
 var own: Array = []
 for row: Dictionary in plan:
  if row.model == 100: own.append(row)
 check(own.size() == 2 and own[0].weapon == "servo-armature" and own[0].amount == 4 and own[1].weapon == "reductor-pistol" and own[1].amount == 1, "Default melee omitted ordinary or Extra Attacks weapon")
 check(s.units[100].ranged_weapons.size() == 1 and s.units[100].ranged_weapons[0].id == "absolvor-bolt-pistol" and "EXPLOSIVES" not in s.units[100].keywords, "Apothecary gained ranged Reductor or inferred keyword")
 s = fixture()
 s.units[500].wounds = 1
 check(choose(s, "narthecium").is_empty(), "Healing setup failed")
 var option: Dictionary = C.unit_choices(s, 1).filter(func(row: Dictionary) -> bool: return row.action == "heal-confirm")[0]
 before = var_to_str(s)
 check(not C.unit_action(s, 2, option, Vector2.ZERO, s.revision, six).is_empty() and var_to_str(s) == before, "Opponent confirmed healing")
 check(not C.unit_action(s, 1, option, Vector2.ZERO, s.revision - 1, six).is_empty() and var_to_str(s) == before, "Stale healing command accepted")
 check(choose(s, "heal-confirm").is_empty(), "Owner cannot confirm after rejected commands")
 s.turn = 5
 s.units[500].wounds = 1
 check(not C.UnitActions.healing_choices(s, 1).is_empty(), "Narthecium failed to refresh next own turn")
 var only_apothecary: Array[String] = ["apothecary"]
 check(S.compatible(only_apothecary, "lieutenant"), "Reverse Support pair rejected")
 print("Apothecary checks: %d failures" % failures)
 quit(0 if failures == 0 else 1)

