extends SceneTree
const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const P = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const S = preload("res://scripts/edition_11/support_attachments.gd")
const MatchCommands = preload("res://scripts/edition_11/match_command_service.gd")
const PendingDecisions = preload("res://scripts/edition_11/pending_decision_registry.gd")
var failures := 0
func check(ok: bool, message: String) -> void:
 if not ok:
  push_error(message)
  failures += 1
func six() -> int: return 6
func submit_projected_choice(s: Dictionary, player: int, selected: Dictionary, decision_id: String = "", option_id: String = "") -> Dictionary:
 var decision := C.UnitActions.pending_decision(s)
 if decision.is_empty() or int(decision.get("priority_player_id", -1)) != player: return {"error": "No matching UnitActions decision for Player %d." % player}
 var projected: Dictionary = {}
 for option: Dictionary in decision.get("legal_options", []):
  if str(option.get("action", "")) == str(selected.get("action", "")) and int(option.get("model", -1)) == int(selected.get("model", -1)) and int(option.get("target", -1)) == int(selected.get("target", -1)) and str(option.get("value", "")) == str(selected.get("value", "")): projected = option; break
 if projected.is_empty(): return {"error": "Selected choice is absent from the current decision."}
 var choice := {"_decision_type": MatchCommands.UNIT_CHOICE_ENVELOPE, "decision_id": decision_id if not decision_id.is_empty() else str(decision.get("decision_id", "")), "option_id": option_id if not option_id.is_empty() else str(projected.get("id", "")), "choice": selected}
 return MatchCommands.execute(s, player, {"kind": MatchCommands.SELECT_UNIT_CHOICE, "choice": choice, "revision": int(s.revision)})
func entry(name: String, models: int = 1, copies: int = 1) -> Dictionary:
 return {"definition_id": "40kdc:11e:adeptus-astartes:" + name, "models": models, "copies": copies}
func fixture(attach: bool = true) -> Dictionary:
 var lists := F.selections()
 lists[1].entries = [entry("ancient"), entry("bladeguard-ancient"), entry("bladeguard-veteran-squad", 3), entry("captain"), entry("intercessor-squad", 5)]
 var s := F.P.initial_state({"checked_rosters": true, "official_mission": true, "unit_abilities": true, "combat_doctrines": true, "reanimation_protocols": true, "awakened_dynasty": true, "core_stratagems": true, "manual_allocation": false}, lists)
 if s.has("error"): return s
 if attach:
  C.UnitActions.attach(s, 100, 9)
  C.UnitActions.attach(s, 300, 5)
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
 s.mission.objectives = [{"name": "Banner test", "kind": "marker", "position": Vector2(0, -8), "controller": 0, "secured": 0, "levels": {1: 0, 2: 0}}]
 for model: int in s.units:
  s.units[model].on_battlefield = true
  s.units[model].position = Vector2(-18, 16) if s.units[model].owner == 1 else Vector2(18, 16)
 for model: int in [900, 901, 902, 903, 904, 100]:
  s.units[model].position = Vector2(0, -8)
 return s
func _initialize() -> void: call_deferred("run")
func run() -> void:
 var s := fixture()
 check(not s.has("error"), "Ancients admission failed")
 if s.has("error"):
  print(s)
  quit(1)
  return
 check(s.training_points[1] == 375 and s.units[100].max_wounds == 4 and s.units[300].max_wounds == 4, "Ancient prices/compositions incorrect")
 check(s.units[100].objective_control == 2 and s.units[300].objective_control == 3 and C.Morale.objective_control(s, 100) == 3 and C.Morale.objective_control(s, 900) == 3, "Honour of Company did not modify every model or corrupted base OC")
 check(C.Morale.objective_control(s, 300) == 3 and C.Morale.objective_control(s, 500) == 1, "Bladeguard Ancient gained ordinary Ancient OC aura")
 check(s.units[100].attachment_role == "support" and s.units[300].attachment_role == "support", "Ancients consumed Leader slots")
 check("DEATHWING" not in s.units[300].keywords and "ANCIENT" in s.units[300].keywords and "ANCIENT" not in s.units[100].keywords, "Ancient keyword/source boundaries merged")
 s.squads[9].battle_shocked = true
 check(C.Morale.objective_control(s, 900) == 0 and C.Morale.objective_control(s, 100) == 0, "OC bonus bypassed Battle-shock")
 s.squads[9].battle_shocked = false
 s.units[100].on_battlefield = false
 check(C.Morale.objective_control(s, 900) == 2, "Off-board Ancient conferred OC")
 s.units[100].on_battlefield = true
 s.units[100].wounds = 0
 check(C.Morale.objective_control(s, 900) == 2, "Dead Ancient conferred OC")
 s = fixture()
 check(s.mission.objectives[0].secured == 0 and C.advance_phase(s, 1, s.revision, six).is_empty() and s.mission.objectives[0].secured == 1, "Raise the Banner did not secure at end of own Movement")
 for model: int in s.units:
  if s.units[model].owner == 1: s.units[model].position = Vector2(-18, 16)
 C.Objectives.resolve_control(s, Callable(C.Morale, "objective_control"))
 check(s.mission.objectives[0].controller == 1 and s.mission.objectives[0].secured == 1, "Banner security vanished when unit left")
 s.units[200].position = Vector2(0, -8)
 C.Objectives.resolve_control(s, Callable(C.Morale, "objective_control"))
 check(s.mission.objectives[0].controller == 2 and s.mission.objectives[0].secured == 0, "Banner prevented later enemy capture")
 s = fixture()
 s.units[100].wounds = 0
 s.units[500].position = Vector2(0, -8)
 check(C.advance_phase(s, 1, s.revision, six).is_empty() and s.mission.objectives[0].secured == 1, "Bladeguard Ancient did not confer Raise the Banner through its bodyguard")
 for variant: String in ["enemy-turn", "shooting", "dead", "shocked", "tie"]:
  s = fixture()
  if variant == "enemy-turn": s.active = 2
  if variant == "shooting": s.phase = "shooting"
  if variant == "dead": s.units[100].wounds = 0
  if variant == "shocked": s.squads[9].battle_shocked = true
  if variant == "tie":
   s.units[200].position = Vector2(0, -8)
   s.units[200].objective_control = 18
  s.unit_abilities.phase_key = C.UnitActions.key(s)
  check(C.advance_phase(s, C.actor(s), s.revision, six).is_empty() and s.mission.objectives[0].secured == 0, "Banner triggered incorrectly: " + variant)
 s = fixture()
 var sword: Dictionary = P.profile("bladeguard-veteran-squad").melee[0].profiles.standard
 check(C.UnitAbilities.weapon(s, 500, 2, sword, true).attacks == 4, "Deeds active outside objective range")
 s.units[500].position = Vector2(0, -8)
 check(C.UnitAbilities.weapon(s, 500, 2, sword, true).attacks == 5 and sword.attacks == 4 and C.UnitAbilities.melee_attack_count(s, 300, P.profile("bladeguard-ancient").melee[0].profiles.standard) == 5, "Deeds missed attached unit or mutated source")
 var pistol: Dictionary = P.profile("bladeguard-ancient").ranged[0].profiles.standard
 check(C.UnitAbilities.weapon(s, 300, 2, pistol, false).attacks == 1, "Deeds modified ranged attacks")
 s.units[501].position = Vector2(0, -6)
 s.units[502].position = Vector2(0, -4)
 s.units[300].position = Vector2(0, -10)
 for model: int in C.living(s, 2): s.units[model].position = Vector2(2, -8)
 for model: int in C.living(s, 4): s.units[model].position = Vector2(2, -6)
 var plan := [{"model": 500, "target": 2, "amount": 2}, {"model": 500, "target": 4, "amount": 3}, {"model": 501, "target": 4, "amount": 5}, {"model": 502, "target": 4, "amount": 5}, {"model": 300, "target": 2, "amount": 5}]
 var prepared := C.AttackPlan.prepare(s, 5, true, plan, true)
 check(prepared.error.is_empty(), "Deeds split plan rejected")
 if prepared.error.is_empty():
  var attacks := 0
  for batch: Dictionary in prepared.batches: attacks += int(batch.weapon.attacks)
  check(attacks == 20, "Deeds extra attack duplicated per split target")
 var defaults := C.AttackPlan.single_target(s, 5, 2, true)
 for row: Dictionary in defaults: check(row.amount == 5, "Default plan omitted modified melee A")
 s.units[300].wounds = 0
 check(C.UnitAbilities.weapon(s, 500, 2, sword, true).attacks == 4 and not C.AttackPlan.prepare(s, 5, true, plan, true).error.is_empty(), "Dead Bladeguard Ancient retained Deeds")
 # Augmenting matches must reserve restricted slots without depending on entry order.
 var legal := [entry("lieutenant"), entry("ancient"), entry("bladeguard-ancient"), entry("bladeguard-veteran-squad", 3), entry("hellblaster-squad", 5), entry("intercessor-squad", 5)]
 check(S.matching_error(legal).is_empty(), "Legal mixed Supports rejected")
 legal.reverse()
 check(S.matching_error(legal).is_empty(), "Support matching depends on entry order")
 check(not S.matching_error([entry("ancient"), entry("bladeguard-ancient"), entry("intercessor-squad", 5, 2)]).is_empty(), "Bladeguard Ancient admitted without Bladeguards")
 check(not S.matching_error([entry("ancient"), entry("judiciar"), entry("bladeguard-veteran-squad", 3, 2)]).is_empty(), "Ordinary Ancient admitted into Bladeguards")
 check(not S.matching_error([entry("bladeguard-ancient"), entry("judiciar"), entry("bladeguard-veteran-squad", 3)]).is_empty(), "Two Supports shared one slot")
 s = fixture(false)
 s.phase = "deployment"
 s.unit_abilities.setup_players = []
 for mode: String in ["power", "rifle"]:
  var option: Dictionary = {}
  for row: Dictionary in C.unit_choices(s, 1):
   if row.action == "ancient-loadout" and row.model == 100 and row.value == mode: option = row
  var decision := PendingDecisions.current(s, ["unit-actions"])
  var projected: Dictionary = decision.get("legal_options", []).filter(func(candidate: Dictionary) -> bool: return str(candidate.get("action", "")) == "ancient-loadout" and int(candidate.get("model", -1)) == 100 and str(candidate.get("value", "")) == mode)[0]
  var before_choice := var_to_bytes(s)
  var wrong_owner := submit_projected_choice(s, 2, option)
  var stale_option := submit_projected_choice(s, 1, option, str(decision.get("decision_id", "")), "stale-option")
  check(not wrong_owner.get("error", "").is_empty() and not stale_option.get("error", "").is_empty() and before_choice == var_to_bytes(s), "Wrong-owner and stale Ancient loadout choices are rejected unchanged")
  var loadout_result := submit_projected_choice(s, 1, option, str(decision.get("decision_id", "")), str(projected.get("id", "")))
  check(not option.is_empty() and loadout_result.get("error", "").is_empty(), "Ancient equipment swap uses the public preparation command: " + mode)
  check(s.units[100].ranged_weapons == P.ancient_weapons(mode == "power").ranged and s.units[100].melee_weapons == P.ancient_weapons(mode == "power").melee, "Ancient replacement removed fists/pistol or retained rifle")
 # Public preparation exposes both support declarations and preserves Leader vacancy.
 for model: int in [100, 300]:
  var option: Dictionary = {}
  for row: Dictionary in C.unit_choices(s, 1):
   if row.action == "attach" and row.model == model and row.target == (9 if model == 100 else 5): option = row
  var before := var_to_bytes(s)
  var wrong_owner := submit_projected_choice(s, 2, option)
  check(not option.is_empty() and not str(wrong_owner.get("error", "")).is_empty() and var_to_bytes(s) == before, "Opponent attached an Ancient")
  var attachment := submit_projected_choice(s, 1, option)
  check(str(attachment.get("error", "")).is_empty() and s.units[model].attachment_role == "support", "Ancient attachment uses the normalized command")
 check(C.UnitActions.attachment_allowed(s, 700, 5), "Ancient occupied the separate Captain Leader slot")
 s.unit_abilities.implementation = "historical"
 check(C.Morale.objective_control(s, 900) == 2, "Ancient OC leaked into historical ability implementation")
 print("Ancients checks: %d failures" % failures)
 quit(0 if failures == 0 else 1)
