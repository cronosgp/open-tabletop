extends SceneTree
const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const Smoke = C.Terrain.Smoke
const MatchCommands = preload("res://scripts/edition_11/match_command_service.gd")
var failures := 0
func check(ok: bool, message: String) -> void:
 if not ok:
  push_error(message)
  failures += 1
func fixture() -> Dictionary:
 var lists := F.selections()
 lists[1].entries = [
  {"definition_id": "40kdc:11e:adeptus-astartes:captain", "models": 1, "copies": 1},
  {"definition_id": "40kdc:11e:adeptus-astartes:eliminator-squad", "models": 3, "copies": 1},
  {"definition_id": "40kdc:11e:adeptus-astartes:intercessor-squad", "models": 5, "copies": 1}]
 var s := F.P.initial_state({"checked_rosters": true, "official_mission": true, "terrain_layout": C.Mission.DEFAULT_TERRAIN_LAYOUT, "unit_abilities": true, "combat_doctrines": true, "reanimation_protocols": true, "awakened_dynasty": true, "core_stratagems": true, "manual_allocation": false}, lists)
 if s.has("error"): return s
 s.awakened_dynasty.pending = []
 s.mission.stage = "battle"
 s.phase = "shooting"
 s.turn = 4
 s.round = 2
 s.active = 2
 s.cp = {1: 3, 2: 3}
 s.unit_abilities.setup_players = [1, 2]
 s.unit_abilities.battle_players = [1, 2]
 s.unit_abilities.window = {}
 s.terrain.areas = []
 for model: int in s.units:
  s.units[model].position = Vector2(0, 12)
  if model not in [100, 300, 400, 401, 500]: s.units[model].wounds = 0
 s.units[300].position = Vector2(0, -7.5)
 s.units[400].position = Vector2(10, -8)
 s.units[401].position = Vector2(8, 4)
 s.units[500].position = Vector2(-10, -8)
 s.unit_abilities.erase("phase_key")
 C.UnitActions.reconcile(s)
 return s
func pick(s: Dictionary, rule: String) -> Dictionary:
 for row: Dictionary in C.unit_choices(s, 1):
  if row.action == "core-stratagem" and row.value == rule: return row
 return {}
func submit_choice(s: Dictionary, player: int, selected: Dictionary, revision: int = -2147483648) -> Dictionary:
 var decision := C.UnitActions.pending_decision(s)
 if decision.is_empty(): return {"error": "No pending UnitActions decision."}
 var projected: Dictionary = {}
 for option: Dictionary in decision.get("legal_options", []):
  if str(option.get("action", "")) == str(selected.get("action", "")) and int(option.get("model", -1)) == int(selected.get("model", -1)) and int(option.get("target", -1)) == int(selected.get("target", -1)) and str(option.get("value", "")) == str(selected.get("value", "")): projected = option; break
 if projected.is_empty(): return {"error": "The selected choice is not in the current projection."}
 return MatchCommands.execute(s, player, {"kind": MatchCommands.SELECT_UNIT_CHOICE, "revision": int(s.revision) if revision == -2147483648 else revision, "point": Vector2.ZERO, "choice": {"_decision_type": MatchCommands.UNIT_CHOICE_ENVELOPE, "decision_id": str(decision.get("decision_id", "")), "option_id": str(projected.get("id", "")), "choice": selected}})
func _initialize() -> void: call_deferred("run")
func run() -> void:
 var s := fixture()
 check(not s.has("error"), "Smoke fixture admission failed")
 if s.has("error"):
  print(s)
  quit(1)
  return
 check(C.UnitActions.actor(s) == 1 and C.UnitActions.pending(s).kind == "start", "Opponent Smoke start window did not open")
 var choice := pick(s, "smokescreen")
 check(not choice.is_empty() and choice.target == 3, "Eligible SMOKE unit not offered")
 var before := var_to_str(s)
 check(not submit_choice(s, 2, choice).get("error", "").is_empty() and var_to_str(s) == before, "Wrong player activated Smoke")
 var stale_smoke := submit_choice(s, 1, choice, s.revision - 1)
 check(not stale_smoke.get("error", "").is_empty() and var_to_str(s) == before, "Stale Smoke activation mutated state: result=%s state_unchanged=%s" % [str(stale_smoke), str(var_to_str(s) == before)])
 var smoke_result := submit_choice(s, 1, choice)
 check(smoke_result.get("error", "").is_empty() and s.cp[1] == 2 and s.stratagems.uses[-1].stratagem == "smokescreen", "Smoke cost/use recording failed: " + str(smoke_result.get("error", "")))
 check(pick(s, "smokescreen").is_empty(), "Smokescreen repeated in one phase")
 check(C.Terrain.benefit_of_cover(s, 400, 3), "Smoke source unit did not receive cover")
 check(C.Terrain.benefit_of_cover(s, 400, 5) and not C.Terrain.benefit_of_cover(s, 401, 5), "Intervening smoke cover ignored per-attacker geometry")
 check(not Smoke.cover(s, 300, 5), "Observer's own unit obstructed its sight")
 # Declining the remaining start window preserves the phase effect.
 var pass_choice: Dictionary = {}
 for row: Dictionary in C.unit_choices(s, 1):
  if row.action == "pass": pass_choice = row
 var pass_result := submit_choice(s, 1, pass_choice)
 check(pass_result.get("error", "").is_empty() and C.UnitActions.pending(s).is_empty(), "Start window could not finish: " + str(pass_result.get("error", "")))
 var prepared := C.AttackPlan.prepare(s, 4, false, [{"model": 400, "target": 5, "amount": 1}, {"model": 401, "target": 5, "amount": 1}], true)
 var covered := 0
 if prepared.error.is_empty():
  for batch: Dictionary in prepared.batches:
   if batch.context.benefit_of_cover: covered += 1
 if not prepared.error.is_empty(): print(prepared.error)
 check(prepared.error.is_empty() and prepared.batches.size() == 2 and covered == 1, "Smoke did not split attack pools by observing model")
 # Ignores Cover defeats this rules-granted benefit as well as terrain cover.
 var gun := {"attacks": 1, "skill": 3, "strength": 4, "ap": 0, "damage": 1, "keywords": {"ignores-cover": true}}
 var defender := {"toughness": 4, "save_target": 4, "wounds_per_model": 1, "remaining_wounds": [1]}
 var result := C.Attacks.resolve(gun, defender, {"benefit_of_cover": C.Terrain.benefit_of_cover(s, 400, 5)}, func() -> int: return 3)
 check(result.error.is_empty() and result.effective_skill == 3 and not result.benefit_of_cover and result.hits == 1, "Ignores Cover did not defeat Smoke")
 s.units[300].position = Vector2(15, -8)
 check(not Smoke.cover(s, 400, 5), "Smoke behind the observer provided cover")
 s.units[300].position = Vector2(-15, -8)
 check(not Smoke.cover(s, 400, 5), "Smoke behind the target provided cover")
 s.units[300].position = Vector2(0, 0)
 check(not Smoke.cover(s, 400, 5), "Smoke outside the sight cone provided cover")
 s.units[300].position = Vector2(0, -7.5)
 s.units[300].wounds = 0
 check(not Smoke.cover(s, 400, 5), "Dead smoke model still shielded another unit")
 s.units[300].wounds = 2
 s.units[300].on_battlefield = false
 check(not Smoke.cover(s, 400, 5), "Off-board smoke model still shielded another unit")
 s.units[300].on_battlefield = true
 s.phase = "charge"
 check(Smoke.active(s).is_empty() and not Smoke.cover(s, 400, 5), "Smoke survived the phase")
 s = fixture()
 s.cp[1] = 0
 check(pick(s, "smokescreen").is_empty(), "Smoke offered without CP")
 s.cp[1] = 3
 s.squads[3].battle_shocked = true
 check(pick(s, "smokescreen").is_empty(), "Battle-shocked Smoke unit eligible")
 s.squads[3].battle_shocked = false
 s.unit_abilities.window = {}
 check(pick(s, "smokescreen").is_empty(), "Smoke offered after the start window")
 s.unit_abilities.window = {"kind": "start", "owners": [1]}
 s.active = 1
 check(pick(s, "smokescreen").is_empty(), "Smoke offered during own Shooting")
 s = fixture()
 choice = pick(s, "smokescreen")
 check(submit_choice(s, 1, choice).get("error", "").is_empty(), "Second fixture Smoke rejected")
 s.unit_abilities.implementation = "historical"
 check(Smoke.active(s).is_empty(), "Smoke survived disabled unit implementation")
 print("Smokescreen checks: %d failures" % failures)
 quit(1 if failures else 0)
