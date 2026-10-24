extends SceneTree
## Batch suite written for the final run; not executed during implementation.
const F = preload("res://tests/marine_phobos_fixture.gd")
const C = F.C
const D = preload("res://scripts/edition_11/detection_rules.gd")
const MatchCommands = preload("res://scripts/edition_11/match_command_service.gd")
const PendingDecisions = preload("res://scripts/edition_11/pending_decision_registry.gd")
var failures := 0
func check(ok: bool,message: String) -> void:
 if not ok:push_error(message);failures+=1
func six() -> int:return 6
func submit_choice(s: Dictionary, player: int, selected: Dictionary, point: Vector2 = Vector2.ZERO, roller: Callable = Callable(), revision: int = -2147483648) -> Dictionary:
 var decision := PendingDecisions.current(s, ["unit-actions"])
 var payload := selected
 if not decision.is_empty():
  if int(decision.get("priority_player_id", -1)) != player: return {"error": "The current UnitActions decision belongs to another player."}
  var projected: Dictionary = {}
  for option: Dictionary in decision.get("legal_options", []):
   if str(option.get("action", "")) == str(selected.get("action", "")) and int(option.get("model", -1)) == int(selected.get("model", -1)) and int(option.get("target", -1)) == int(selected.get("target", -1)) and str(option.get("value", "")) == str(selected.get("value", "")): projected = option; break
  if projected.is_empty(): return {"error": "The selected choice is not in the current projection."}
  payload = {"_decision_type": MatchCommands.UNIT_CHOICE_ENVELOPE, "decision_id": str(decision.get("decision_id", "")), "option_id": str(projected.get("id", "")), "choice": selected}
 return MatchCommands.execute(s, player, {"kind": MatchCommands.SELECT_UNIT_CHOICE, "choice": payload, "point": point, "revision": int(s.revision) if revision == -2147483648 else revision}, roller if roller.is_valid() else six)
func choose(s: Dictionary,action: String,model: int = -1,point: Vector2 = Vector2.ZERO,value: String = "") -> String:
 for option: Dictionary in C.unit_choices(s,1):
  if option.action==action and (model==-1 or option.model==model) and (value.is_empty() or option.value==value):return str(submit_choice(s,1,option,point,six).get("error", ""))
 return "Choice unavailable: "+action
func _initialize() -> void:call_deferred("run")
func run() -> void:
 var s := F.fixture()
 check(not s.has("error"),"Infiltrator admission failed")
 if s.has("error"):print(s);quit(1);return
 check(s.training_points[1]==300 and s.units[500].movement==8 and s.units[500].max_wounds==2,"Infiltrator formation/price/stats incorrect")
 var large := F.fixture(false,10)
 check(not large.has("error") and large.training_points[1]==365 and large.squads[5].training_cost==150,"Ten Infiltrators lost nonlinear price")
 check(D.infiltrators(s,5) and not D.stealth(s,5),"Mixed Phobos unit lost Infiltrators or gained Stealth")
 check(C.UnitActions.healing_choices(s,1).is_empty(),"Unequipped Helix granted healing")
 s.phase="deployment"
 s.unit_abilities.setup_players=[]
 check(choose(s,"helix-bearer",500,Vector2.ZERO,"on").is_empty() and choose(s,"helix-bearer",501,Vector2.ZERO,"on").is_empty(),"Helix bearer selection failed")
 check(not s.units[500].helix_gauntlet and s.units[501].helix_gauntlet,"Two Helix bearers retained")
 check(choose(s,"helix-bearer",501,Vector2.ZERO,"off").is_empty() and not s.units[501].helix_gauntlet,"Optional Helix could not be removed")
 choose(s,"helix-bearer",500,Vector2.ZERO,"on")
 s.phase="command"
 s.unit_abilities.setup_players=[1,2]
 s.unit_abilities.phase_key=C.UnitActions.key(s)
 s.units[700].wounds=2
 check(choose(s,"helix-heal").is_empty() and s.unit_abilities.window.total==3 and s.unit_abilities.window.ability_name=="Helix Gauntlet" and s.units[700].wounds==2,"Helix did not roll D3 or mutated before confirm")
 check(choose(s,"heal-confirm").is_empty() and s.units[700].wounds==4 and s.unit_abilities.last_healing.discarded==1,"Helix failed to heal attached Character or discard excess")
 s.units[501].wounds=1
 check(C.UnitActions.healing_choices(s,1).is_empty(),"Helix repeated in same Command")
 s=F.fixture()
 s.units[500].helix_gauntlet=true
 s.units[501].wounds=0
 check(choose(s,"helix-heal").is_empty() and choose(s,"heal-revive",501,Vector2(1.7,-8)).is_empty() and choose(s,"heal-confirm").is_empty() and s.units[501].wounds==2,"Helix failed shared return/heal sequence")
 s=F.fixture()
 s.units[500].helix_gauntlet=true
 s.units[500].wounds=0
 s.units[501].wounds=1
 check(C.UnitActions.healing_choices(s,1).is_empty(),"Dead Helix bearer granted healing")
 s=F.fixture()
 s.phase="shooting"
 s.unit_abilities.phase_key=C.UnitActions.key(s)
 var baseline := D.detection_range(s,200,false)
 check(choose(s,"omni-scramblers").is_empty() and D.detection_range(s,200,false)==baseline+3,"Omni did not add detection")
 check(C.UnitActions.omni_choices(s,1).is_empty() and not s.squads[5].shot and s.cp[1]==0,"Omni repeated or consumed shooting/CP")
 s.unit_abilities.optics={"mode":"detect","target":2,"squad":3,"phase_key":C.UnitActions.key(s)}
 check(D.detection_range(s,200,false)==baseline+9,"Omni failed to combine with different Optics effect")
 s.unit_abilities.erase("optics")
 s.phase="charge"
 check(D.detection_range(s,200,false)==baseline,"Detected mark outlasted phase")
 s.phase="shooting"
 s.turn+=2
 s.unit_abilities.phase_key=C.UnitActions.key(s)
 for model: int in C.living(s,2):s.units[model].position=Vector2(18,16)
 check(C.UnitActions.omni_choices(s,1).is_empty(),"Omni selected out-of-range unit")
 s.unit_abilities.implementation="historical"
 check(not D.infiltrators(s,5) and D.detection_range(s,200,false)==baseline,"Phobos effects leaked into historical implementation")
 s=F.fixture()
 s.phase="shooting"
 s.unit_abilities.phase_key=C.UnitActions.key(s)
 for model: int in C.living(s,2):s.units[model].position=Vector2(0,10)
 s.terrain.areas=[{"name":"Hidden target","category":"light","bounds":Rect2(-2,8,4,4),"features":[{"bounds":Rect2(-0.1,9.9,0.2,0.2),"height":0.1,"blocks_end":false}]}]
 check(C.UnitActions.omni_choices(s,1).is_empty(),"Omni bootstrapped visibility onto a hidden target outside current detection")
 s=F.fixture()
 s.phase="shooting"
 s.unit_abilities.phase_key=C.UnitActions.key(s)
 var option: Dictionary=C.UnitActions.omni_choices(s,1)[0]
 var before := var_to_str(s)
 var wrong_owner := submit_choice(s,2,option)
 var stale_choice := submit_choice(s,1,option,Vector2.ZERO,six,s.revision-1)
 check(not str(wrong_owner.get("error", "")).is_empty() and var_to_str(s)==before,"Opponent applied detected mark")
 check(not str(stale_choice.get("error", "")).is_empty() and var_to_str(s)==before,"Stale Omni choice changed state")
 print("Infiltrator Squad checks: %d failures" % failures)
 quit(0 if failures==0 else 1)
