extends SceneTree
## Batch suite written for the final run; not executed during implementation.
const F = preload("res://tests/marine_phobos_fixture.gd")
const C = F.C
const P = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const MatchCommands = preload("res://scripts/edition_11/match_command_service.gd")
const PublicUnitCommand = preload("res://tests/public_unit_command.gd")
var failures := 0
func check(ok: bool,message: String) -> void:
 if not ok:push_error(message);failures+=1
func submit_choice(s: Dictionary, owner: int, choice: Dictionary) -> Dictionary:
 var decision := C.UnitActions.pending_decision(s)
 var payload: Dictionary = choice
 if not decision.is_empty():
  var projected: Dictionary = {}
  for option: Dictionary in decision.get("legal_options", []):
   if str(option.get("action", ""))==str(choice.get("action", "")) and int(option.get("model", -1))==int(choice.get("model", -1)) and int(option.get("target", -1))==int(choice.get("target", -1)) and str(option.get("value", ""))==str(choice.get("value", "")):projected=option;break
  if projected.is_empty():return {"error":"Choice missing from pending decision."}
  payload={"_decision_type":MatchCommands.UNIT_CHOICE_ENVELOPE,"decision_id":str(decision.get("decision_id", "")),"option_id":str(projected.get("id", "")),"choice":choice}
 return MatchCommands.execute(s,owner,{"kind":MatchCommands.SELECT_UNIT_CHOICE,"choice":payload,"revision":int(s.revision)})
func choose(s: Dictionary,action: String,value: String) -> String:
 for option: Dictionary in C.unit_choices(s,1):
  if option.action==action and option.value==value:return PublicUnitCommand.error(s,1,option)
 return "Choice unavailable"
func _initialize() -> void:call_deferred("run")
func run() -> void:
 var s := F.fixture()
 check(not s.has("error"),"Phobos Lieutenant admission failed")
 if s.has("error"):print(s);quit(1);return
 check(P.profile("lieutenant-in-phobos-armour").points==40 and s.units[700].max_wounds==4 and s.units[700].movement==8 and s.units[700].attachment_role=="support","Lieutenant stats/cost/role incorrect")
 check(C.UnitAbilities.every_model_has(s,5,"infiltrators") and not C.UnitAbilities.every_model_has(s,5,"deep-strike") and C.UnitAbilities.scout_distance(s,5)==0,"Mixed unit gained ineligible Deep Strike/Scout move")
 var weapon: Dictionary=P.profile("infiltrator-squad").ranged[0].profiles.standard
 check(C.UnitAbilities.weapon(s,500,2,weapon,false).keywords.get("lethal-hits",false),"Phobos Tactical Precision missing")
 for keyword: String in ["MONSTER","VEHICLE"]:
  s.units[200].keywords.append(keyword)
  check(not C.UnitAbilities.weapon(s,500,2,weapon,false).keywords.get("lethal-hits",false),"Tactical Precision ignored excluded target")
  s.units[200].keywords.erase(keyword)
 s=F.fixture(false)
 check(C.UnitActions.attachment_allowed(s,700,5) and C.UnitActions.attachment_allowed(s,700,3) and not C.UnitActions.attachment_allowed(s,700,1),"Phobos Support links incorrect")
 s.phase="deployment"
 s.unit_abilities.setup_players=[]
 for option: Dictionary in C.unit_choices(s,1):check(not(option.action=="reserve" and option.target==7),"Unattached mandatory Support entered reserves before formation declaration")
 check(choose(s,"phobos-lieutenant-gun","carbine").is_empty() and s.units[700].ranged_weapons.size()==1 and s.units[700].ranged_weapons[0].id=="master-crafted-bolt-carbine","Carbine swap retained pistol")
 C.UnitActions.attach(s,700,3)
 s.phase="deployment"
 check(C.UnitAbilities.Detection.infiltrators(s,3) and not C.UnitAbilities.Detection.stealth(s,3),"Eliminators plus Lieutenant lost Infiltrators or retained all-model Stealth")
 check(choose(s,"phobos-lieutenant-gun","pistol").is_empty() and s.units[700].ranged_weapons==P.profile("lieutenant-in-phobos-armour").ranged,"Pistol not restored after attachment")
 for option: Dictionary in C.unit_choices(s,1):check(not(option.action=="reserve" and option.target==3),"Mixed Phobos unit offered Deep Strike reserves")
 s.phase="command"
 s.unit_abilities.setup_players=[1,2]
 s.unit_abilities.phase_key=C.UnitActions.key(s)
 var acumen: Dictionary={}
 for option: Dictionary in C.unit_choices(s,1):
  if option.action=="acumen":acumen=option;break
 check(not acumen.is_empty(),"Captain did not offer Strategic Acumen")
 if not acumen.is_empty():
  var before_wrong_acumen_owner := var_to_bytes(s)
  var wrong_acumen_owner := submit_choice(s,2,acumen)
  check(not str(wrong_acumen_owner.get("error", "")).is_empty() and var_to_bytes(s)==before_wrong_acumen_owner,"The opponent cannot submit or mutate the immediate Strategic Acumen choice")
  var acumen_result := submit_choice(s,1,acumen)
  check(str(acumen_result.get("error", "")).is_empty(),"Captain opens doctrine response through the public command")
 var demi: Dictionary={}
 for option: Dictionary in C.unit_choices(s,1):
  if option.action=="demi" and option.value==acumen.value:demi=option;break
 var demi_result := submit_choice(s,1,demi) if not demi.is_empty() else {"error":"Demi-company Commander choice unavailable."}
 check(str(demi_result.get("error", "")).is_empty() and s.unit_abilities.doctrines[3].doctrine==acumen.value,"Phobos Lieutenant copies the Captain doctrine through the public command")
 print("Phobos Lieutenant checks: %d failures" % failures)
 quit(0 if failures==0 else 1)
