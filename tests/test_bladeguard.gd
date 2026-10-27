extends SceneTree
const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const B = preload("res://scripts/edition_11/bladeguard.gd")
const ResolutionFrames = preload("res://scripts/edition_11/resolution_frame.gd")
const Commands = preload("res://scripts/edition_11/match_command_service.gd")
const PendingDecisions = preload("res://scripts/edition_11/pending_decision_registry.gd")
var failures := 0
var calls := 0
func check(ok: bool, message: String) -> void:
 if not ok:
  push_error(message)
  failures += 1
func six() -> int:
 calls += 1
 return 6
func bad() -> int: return 0
func three() -> int: return 3
func selection(size: int = 3, copies: int = 1, leader: String = "captain") -> Dictionary:
 return {"schema_version": 2, "faction": "Space Marines", "category": "incursion", "points_limit": 1000, "entries": [{"definition_id": "40kdc:11e:adeptus-astartes:bladeguard-veteran-squad", "models": size, "copies": copies}, {"definition_id": "40kdc:11e:adeptus-astartes:" + leader, "models": 1, "copies": 1}]}
func fixture(size: int = 3, enemy_copies: int = 1, leader: String = "captain") -> Dictionary:
 var s := F.P.initial_state({"unit_abilities": true, "manual_allocation": false, "combat_doctrines": true, "reanimation_protocols": true, "awakened_dynasty": true, "core_stratagems": true}, {1: selection(size, 1, leader), 2: selection(3, enemy_copies)})
 if s.has("error"): return s
 s["mission"] = s.get("mission", {})
 s.mission.stage = "battle"
 s.phase = "fight"
 s.turn = 3
 s.round = 2
 s.active = 1
 s.fight_actor = 1
 s.fight_step = "attacks"
 s.fight_priority = "remaining"
 s.fight_selected = -1
 s.unit_abilities.setup_players = [1, 2]
 s.unit_abilities.battle_players = [1, 2]
 s.unit_abilities.window = {}
 s.unit_abilities.phase_key = C.UnitActions.key(s)
 s.terrain.areas = []
 s.cp = {1: 0, 2: 0}
 for model: int in s.units:
  var u: Dictionary = s.units[model]
  u.on_battlefield = true
  if C.UnitAbilities.identity(u) == "bladeguard-veteran-squad": u.position = Vector2(-2 if u.owner == 1 else 0, -8 + (model % 100) * 2)
  else: u.position = Vector2(-20 if u.owner == 1 else 20, 15)
  if u.squad == 4 and C.UnitAbilities.identity(u) == "bladeguard-veteran-squad": u.position = Vector2(0, -10 - (model % 100) * 2)
 for squad: int in s.squads:
  s.squads[squad].fought = false
  s.squads[squad].charged = false
  s.squads[squad].was_engaged = false
 return s
func pick(s: Dictionary, player: int, mode: String) -> Dictionary:
 for row: Dictionary in C.unit_choices(s, player):
  if row.action == "bladeguard" and row.value == mode: return row
 return {}
func choose(s: Dictionary, player: int, mode: String, roller: Callable = six) -> String:
 var selected := pick(s, player, mode)
 if selected.is_empty(): return "No Bladeguard stance choice is offered."
 return str(submit_normalized(s, player, selected, int(s.get("revision", -1)), roller).get("error", ""))
func submit_normalized(s: Dictionary, player: int, selected: Dictionary, revision: int = -2147483648, roller: Callable = six, decision_id: String = "", option_id: String = "") -> Dictionary:
 var decision := PendingDecisions.current(s, ["unit-actions"])
 if decision.is_empty(): return {"error": "No normalized Bladeguard decision is open."}
 var projected: Dictionary = {}
 for option: Dictionary in decision.get("legal_options", []):
  if option.get("action", "") == selected.get("action", "") and option.get("model", -1) == selected.get("model", -1) and option.get("target", -1) == selected.get("target", -1) and option.get("value", "") == selected.get("value", ""):
   projected = option
   break
 if projected.is_empty(): return {"error": "The current decision does not offer this Bladeguard choice."}
 return Commands.execute(s, player, {"kind": Commands.SELECT_UNIT_CHOICE, "revision": int(s.get("revision", -1)) if revision == -2147483648 else revision, "choice": {"_decision_type": Commands.UNIT_CHOICE_ENVELOPE, "decision_id": decision_id if not decision_id.is_empty() else str(decision.get("decision_id", "")), "option_id": option_id if not option_id.is_empty() else str(projected.get("id", "")), "choice": selected}}, roller)
func begin(s: Dictionary) -> Dictionary:
 return C.fight(s, 1, 100, 200, s.revision, six)
func _initialize() -> void: call_deferred("run")
func run() -> void:
 var s := fixture()
 check(not s.has("error"), "Bladeguard admission failed")
 if s.has("error"):
  print(s)
  quit(1)
  return
 check(C.RosterValidation.admit(selection()).total == 180 and C.living(s, 1).size() == 3 and s.units[100].max_wounds == 3 and s.squads[1].stats.invulnerable_target == 4, "Bladeguard price, formation or defense incorrect")
 check("DEATHWING" not in s.units[100].keywords and "EXPLOSIVES" in s.units[100].keywords and is_equal_approx(s.units[100].radius, 20.0 / 25.4), "Shared-book keywords or base incorrect")
 var larger := fixture(6)
 check(not larger.has("error") and C.RosterValidation.admit(selection(6)).total == 270 and C.living(larger, 1).size() == 6, "Six-model Bladeguard formation incorrect")
 check(not F.P.Training.Capabilities.admit(selection(3, 3)).error.is_empty(), "Third-copy price silently used first-copy costs in training")
 check(not C.RosterValidation.admit(selection(3, 3)).error.is_empty(), "Incursion admitted third Bladeguard copy")
 var start_calls := calls
 check(begin(s).error.is_empty() and calls == start_calls and C.actor(s) == 1 and C.UnitActions.pending(s).kind == "bladeguard", "Attacker stance did not pause before dice")
 var before := var_to_str(s)
 var selected := pick(s, 1, "attack")
 check(not submit_normalized(s, 2, selected, s.revision, six).is_empty() and var_to_str(s) == before, "Opponent changed attacker stance")
 check(not submit_normalized(s, 1, selected, s.revision - 1, six).is_empty() and var_to_str(s) == before, "Stale stance changed declaration")
 check(not C.advance_phase(s, 1, s.revision, six).is_empty() and var_to_str(s) == before, "Phase advanced through frozen declaration")
 check(not begin(s).error.is_empty() and var_to_str(s) == before, "Second attack bypassed declaration window")
 check(choose(s, 1, "attack").is_empty() and C.actor(s) == 2 and calls == start_calls and B.mode(s, 1) == "attack", "Attacker choice did not transfer to defender before dice")
 before = var_to_str(s)
 check(not choose(s, 2, "defend", bad).is_empty() and before == var_to_str(s), "Invalid attack roll committed defender ability or lost declaration")
 check(choose(s, 2, "defend").is_empty() and calls > start_calls and s.squads[1].fought and s.pending_attack.is_empty(), "Final stance did not resume frozen attack")
 check(s.last_attack.pools[0].hit_modifier == 0 and B.mode(s, 2) == "defend", "Opposing Bladeguard hit modifiers did not cancel")
 check(not B.available(s, 1) and not B.available(s, 2), "Stance could be changed twice in one turn")
 check(C.fight(s, 2, 200, 100, s.revision, six).error.is_empty() and C.UnitActions.pending(s).get("kind", "") != "bladeguard", "Spent abilities reopened on counterattack")
 check(B.hit_modifier(s, 1, 2, false) == -1, "Offensive melee bonus leaked into ranged attacks or defense disappeared")
 s.phase = "shooting"
 check(B.mode(s, 1).is_empty() and B.hit_modifier(s, 1, 2, true) == 0, "Stance survived its Fight phase")
 s.phase = "fight"
 s.turn += 1
 check(B.mode(s, 1).is_empty() and B.available(s, 1), "Next player turn did not reset once-per-turn availability")
 s = fixture()
 check(begin(s).error.is_empty() and choose(s, 1, "pass").is_empty() and choose(s, 2, "pass").is_empty(), "Declining stance did not resume attack")
 check(B.available(s, 1) and B.available(s, 2), "Declining consumed once-per-turn ability")
 check(C.fight(s, 2, 200, 100, s.revision, six).error.is_empty() and C.actor(s) == 2 and choose(s, 2, "pass").is_empty() and C.actor(s) == 1, "Declined stance did not reopen on a later legal trigger")
 check(choose(s, 1, "defend").is_empty() and s.last_attack.pools[0].hit_modifier == -1, "Already-fought target could not select defensive stance")
 s = fixture()
 s.phase = "deployment"
 s.unit_abilities.setup_players = []
 for kind: String in ["volkite", "plasma", "heavy"]:
  var option: Dictionary = {}
  for row: Dictionary in C.unit_choices(s, 1):
   if row.action == "bladeguard-pistol" and row.model == 100 and row.value == kind: option = row
  if kind == "volkite":
   var preparation_decision := PendingDecisions.current(s, ["unit-actions"])
   var before_pistol := var_to_bytes(s)
   var wrong_owner_pistol := submit_normalized(s, 2, option)
   var stale_pistol := submit_normalized(s, 1, option, -2147483648, six, str(preparation_decision.get("decision_id", "")), "stale-option")
   check(not wrong_owner_pistol.get("error", "").is_empty() and not stale_pistol.get("error", "").is_empty() and before_pistol == var_to_bytes(s), "Wrong-owner and stale Bladeguard pistol options are rejected unchanged")
  var pistol_result := submit_normalized(s, 1, option)
  check(not option.is_empty() and pistol_result.get("error", "").is_empty(), "Sergeant pistol choice uses the public preparation command: " + kind)
  check(s.units[100].ranged_weapons[0] == Profiles.bladeguard_pistol(kind) and s.units[101].ranged_weapons[0].id == "heavy-bolt-pistol", "Pistol swap changed trooper or failed to replace Sergeant inventory")
 check(C.UnitActions.attachment_allowed(s, 300, 1), "Captain cannot lead Bladeguard")
 for name: String in ["chaplain", "lieutenant", "judiciar"]:
  s.units[300].definition_id = "40kdc:11e:adeptus-astartes:" + name
  check(C.UnitActions.attachment_allowed(s, 300, 1), "Admitted attachment missing: " + name)
 # Split attacks freeze targets and offer every targeted Bladeguard unit once.
 s = fixture(3, 2)
 var entries := [{"model": 100, "target": 2, "amount": 2}, {"model": 100, "target": 4, "amount": 2}, {"model": 101, "target": 2, "amount": 4}, {"model": 102, "target": 2, "amount": 4}]
 start_calls = calls
 check(C.resolve_attack_plan(s, 1, 100, entries, s.revision, true, true, six).error.is_empty() and calls == start_calls, "Split melee declaration rolled before choices")
 entries[1].target = 1
 check(choose(s, 1, "pass").is_empty() and C.UnitActions.pending(s).remaining[0] == 2 and choose(s, 2, "defend").is_empty() and C.UnitActions.pending(s).remaining[0] == 4 and calls == start_calls, "Targeted units did not receive independent pre-dice choices")
 check(choose(s, 2, "attack").is_empty() and s.last_attack.targets == [2, 4] and B.mode(s, 2) == "defend" and B.mode(s, 4) == "attack", "Split targets changed after declaration or modes merged across units")
 s = fixture()
 var invalid := [{"model": 100, "target": 1, "amount": 4}]
 before = var_to_str(s)
 check(not C.resolve_attack_plan(s, 1, 100, invalid, s.revision, true, true, six).error.is_empty() and before == var_to_str(s), "Illegal attack opened or spent a stance window")
 # Checked admission uses the supported Marine-vs-Necron mission separately.
 var checked_lists := F.selections()
 checked_lists[1] = selection()
 var checked := F.P.initial_state({"checked_rosters": true, "official_mission": true, "unit_abilities": true, "combat_doctrines": true, "reanimation_protocols": true, "awakened_dynasty": true, "core_stratagems": true}, checked_lists)
 check(not checked.has("error") and checked.training_points[1] == 180, "Bladeguard failed checked Marine-vs-Necron admission")
 s = fixture()
 s.manual_allocation = true
 s.squads[2].stats.toughness = 3
 check(begin(s).error.is_empty() and choose(s, 1, "attack").is_empty() and choose(s, 2, "pass", three).is_empty() and not s.pending_attack.is_empty() and C.actor(s) == 2, "Stance did not hand unsaved attacks to manual defender allocation")
 var attempts := 0
 while not s.pending_attack.is_empty() and attempts < 30:
  var eligible := C.Allocation.eligible(s)
  if eligible.is_empty(): break
  check(C.allocate_damage(s, 2, eligible[0], s.revision, three).is_empty(), "Manual allocation failed after Bladeguard declaration")
  attempts += 1
 check(s.pending_attack.is_empty() and s.squads[1].fought and s.last_attack.pools[0].hit_modifier == 1 and s.last_attack.pools[0].damage_applied > 0, "Manual stance attack failed to finish exactly once")
 # A selected unit that has no remaining enemy in reach still receives its trigger.
 s = fixture()
 for model: int in C.living(s, 2): s.units[model].position = Vector2(15, -8)
 s.squads[1].was_engaged = true
 start_calls = calls
 check(C.advance_phase(s, 1, s.revision, six, 1).is_empty() and C.UnitActions.pending(s).get("kind", "") == "bladeguard" and not s.squads[1].fought, "Unengaged selection skipped Bladeguard choice")
 var empty_fight_frame := ResolutionFrames.current(s)
 var empty_fight_decision := C.UnitActions.pending_decision(s)
 check(empty_fight_frame.get("kind", "") == "fight" and empty_fight_frame.get("status", "") == "suspended" and empty_fight_frame.get("resume_point", "") == "empty-fight-bladeguard-choice", "Unengaged Bladeguard choice suspends a Fight continuation")
 check(empty_fight_decision.get("action_id", "") == empty_fight_frame.get("action_id", "") and empty_fight_decision.get("resume_frame_id", "") == empty_fight_frame.get("frame_id", ""), "Normalized Bladeguard choice carries its Fight continuation identity")
 s = bytes_to_var(var_to_bytes(s))
 empty_fight_frame = ResolutionFrames.current(s)
 empty_fight_decision = C.UnitActions.pending_decision(s)
 check(empty_fight_decision.get("resume_frame_id", "") == empty_fight_frame.get("frame_id", "") and empty_fight_frame.get("status", "") == "suspended", "Unengaged Fight choice survives save and resume")
 var suspended_fight_state := var_to_bytes(s)
 check(not C.advance_phase(s, 1, s.revision).is_empty() and suspended_fight_state == var_to_bytes(s), "Phase close cannot skip an unresolved unengaged Fight choice")
 var stance_option: Dictionary = {}
 for option: Dictionary in empty_fight_decision.legal_options:
  if option.get("value", "") == "defend": stance_option = option; break
 var stance_choice := pick(s, 1, "defend")
 var stance_result := Commands.execute(s, 1, {"kind": Commands.SELECT_UNIT_CHOICE, "revision": s.revision, "choice": {"_decision_type": Commands.UNIT_CHOICE_ENVELOPE, "decision_id": empty_fight_decision.decision_id, "option_id": stance_option.id, "choice": stance_choice}}, six)
 check(stance_result.get("error", "").is_empty() and s.squads[1].fought and calls == start_calls and B.mode(s, 1) == "defend", "Unengaged choice rolled dice or failed to finish")
 check(ResolutionFrames.current(s).is_empty(), "Unengaged Fight continuation completes after the stance choice")
 # Without an attacking unit still resolving, source loss ends the effect (Core 19.04).
 s = fixture()
 C.UnitActions.attach(s, 300, 1)
 s.phase = "fight"
 for model: int in s.units: s.units[model].on_battlefield = true
 check(B.offer(s, {"kind": "empty-fight", "player": 1, "squad": 1, "melee": true}, []), "Attached Bladeguard effect unavailable")
 B.choose(s, "defend")
 for model: int in [100, 101, 102]: s.units[model].wounds = 0
 check(B.mode(s, 1).is_empty() and not B.available(s, 1) and C.UnitAbilities.hit_bonus(s, 2, 1, true) == 0, "Destroyed bodyguard kept conferring Bladeguard on surviving Character")
 # Last-source casualties retain the declared modifier through all attacks, then stop.
 s = fixture()
 C.UnitActions.attach(s, 400, 2)
 s.phase = "fight"
 s.fight_step = "attacks"
 s.fight_actor = 1
 s.fight_selected = -1
 s.unit_abilities.phase_key = C.UnitActions.key(s)
 for model: int in s.units: s.units[model].on_battlefield = true
 s.units[400].position = Vector2(0, -10)
 s.units[101].wounds = 0
 s.units[102].wounds = 0
 for model: int in [200, 201, 202]:
  s.units[model].max_wounds = 1
  s.units[model].wounds = 1
 s.units[100].melee_weapons = [{"id": "source-loss-probe", "profiles": {"standard": {"name": "Source loss probe", "attacks": 4, "skill": 3, "strength": 10, "ap": -6, "damage": 1, "range_inches": 0, "keywords": {}}}}]
 s.manual_allocation = true
 check(begin(s).error.is_empty() and choose(s, 1, "attack").is_empty() and choose(s, 2, "defend", three).is_empty(), "Source loss attack failed declaration")
 var retained := false
 attempts = 0
 while not s.pending_attack.is_empty() and attempts < 20:
  if s.units[200].wounds == 0 and s.units[201].wounds == 0 and s.units[202].wounds == 0:
   retained = B.mode(s, 2) == "defend"
  var eligible := C.Allocation.eligible(s)
  if eligible.is_empty(): break
  check(C.allocate_damage(s, 2, eligible[0], s.revision, three).is_empty(), "Source loss allocation failed")
  attempts += 1
 check(retained and s.pending_attack.is_empty() and s.units[400].wounds == 4 and B.mode(s, 2).is_empty() and s.last_attack.pools[0].hit_modifier == 0, "Source effect did not expire exactly after the attacking unit finished")
 # Judiciar's melee Precision follows the stance responses, without skipping its prompt.
 s = fixture(3, 1, "judiciar")
 C.UnitActions.attach(s, 300, 1)
 C.UnitActions.attach(s, 400, 2)
 s.phase = "fight"
 s.fight_step = "attacks"
 s.fight_actor = 1
 s.fight_selected = -1
 s.unit_abilities.phase_key = C.UnitActions.key(s)
 for model: int in s.units: s.units[model].on_battlefield = true
 s.units[300].position = Vector2(-2, -10)
 s.units[400].position = Vector2(0, -10)
 check(C.FightQueue.first(s, 1) and not C.FightQueue.first(s, 2), "Attached Judiciar lost Tempormortis on Bladeguard")
 check(begin(s).error.is_empty() and choose(s, 1, "attack").is_empty() and choose(s, 2, "defend").is_empty(), "Judiciar attack did not pass stance responses")
 check(not s.pending_attack.is_empty() and s.pending_attack.current.phase == "precision" and C.actor(s) == 1 and 400 in C.Allocation.eligible(s), "Stances bypassed Judiciar Precision selection")
 check(C.allocate_damage(s, 1, 400, s.revision, six).is_empty() and s.pending_attack.is_empty() and s.units[400].wounds == 0 and s.squads[1].fought, "Judiciar Precision/Devastating Wounds did not complete after Bladeguard choice")
 s = fixture()
 s.unit_abilities.implementation = "historical"
 check(not B.available(s, 1) and B.mode(s, 1).is_empty(), "Current Bladeguard mechanic leaked into historical profile")
 print("Bladeguard checks: %d failures" % failures)
 quit(0 if failures == 0 else 1)
