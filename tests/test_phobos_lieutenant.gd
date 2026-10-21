extends SceneTree
## Batch suite written for the final run; not executed during implementation.
const F = preload("res://tests/marine_phobos_fixture.gd")
const C = F.C
const P = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
var failures := 0
func check(ok: bool,message: String) -> void:
 if not ok:push_error(message);failures+=1
func choose(s: Dictionary,action: String,value: String) -> String:
 for option: Dictionary in C.unit_choices(s,1):
  if option.action==action and option.value==value:return C.unit_action(s,1,option,Vector2.ZERO,s.revision)
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
 check(not acumen.is_empty() and C.unit_action(s,1,acumen,Vector2.ZERO,s.revision).is_empty(),"Captain did not open doctrine response")
 check(choose(s,"demi",acumen.value).is_empty() and s.unit_abilities.doctrines[3].doctrine==acumen.value,"Phobos Lieutenant did not copy Captain doctrine")
 print("Phobos Lieutenant checks: %d failures" % failures)
 quit(0 if failures==0 else 1)
