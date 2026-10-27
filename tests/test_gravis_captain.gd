extends SceneTree
## Written for the deferred final batch; not executed during implementation.
const F = preload("res://tests/marine_gravis_ancient_fixture.gd")
const C = F.C
const P = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const PublicUnitCommand = preload("res://tests/public_unit_command.gd")
var failures := 0
func check(ok: bool, message: String) -> void:
 if not ok: push_error(message); failures+=1
func three() -> int:return 3
func equip(s: Dictionary, mode: String) -> String:
 for option: Dictionary in C.unit_choices(s,1):
  if option.action=="gravis-captain-loadout" and option.value==mode:return PublicUnitCommand.error(s,1,option)
 return "Unavailable loadout"
func _initialize() -> void:call_deferred("run")
func run() -> void:
 var s := F.fixture()
 check(not s.has("error"),"Gravis Captain admission failed")
 if s.has("error"): print(s);quit(1);return
 check(s.units[300].max_wounds==6 and is_equal_approx(s.units[300].radius,20.0/25.4),"Gravis Captain wounds/base incorrect")
 check(P.profile("captain-in-gravis-armour").points==90 and s.units[300].attachment_role=="leader","Gravis Captain cost/role incorrect")
 check(C.UnitAbilities.has(s,7,"strategic-acumen") and C.UnitAbilities.has(s,7,"transhuman-strategist") and not C.UnitAbilities.has(s,7,"finest-hour") and not C.UnitAbilities.has(s,7,"deep-strike"),"Gravis Captain inherited another Captain's abilities")
 check(C.UnitAbilities.damage(s,300,3)==2 and C.UnitAbilities.damage(s,700,3)==3 and C.UnitAbilities.damage(s,300,1)==1 and C.UnitAbilities.damage(s,300,0)==0,"Refuse to Yield scope/minimum incorrect")
 s=F.fixture(false)
 check(C.UnitActions.attachment_allowed(s,300,7) and not C.UnitActions.attachment_allowed(s,300,9),"Gravis Captain crossed armour boundary")
 var probe := {"name":"Yield probe","attacks":1,"skill":2,"strength":12,"ap":-6,"damage":3,"range_inches":24,"keywords":{}}
 var resolved := C.AttackPlan.resolve(s,{"targets":[3],"batches":[{"target":3,"weapon":probe,"context":{"weapon_count":1}}]},three)
 check(resolved.error.is_empty() and resolved.units[300].wounds==4,"Allocated damage did not use Refuse to Yield")
 s.phase="deployment"
 s.unit_abilities.setup_players=[]
 for mode: String in ["blade","chainsword","fist","rifle"]:
  check(equip(s,mode).is_empty(),"Gravis loadout unavailable: "+mode)
  var expected := P.gravis_captain_weapons(mode)
  check(s.units[300].ranged_weapons==expected.ranged and s.units[300].melee_weapons==expected.melee,"Replacement retained incompatible equipment: "+mode)
  if mode!="rifle":
   check(s.units[300].melee_weapons.size()==2 and s.units[300].melee_weapons[1].profiles.standard.keywords.get("extra-attacks",false),"Relic lost Extra Attacks")
   s.units[300].position=Vector2(0,-8)
   for model: int in C.living(s,2):s.units[model].position=Vector2(1.8,-8)
   var plan := C.AttackPlan.single_target(s,3,2,true)
   check(plan.size()==2 and plan[0].amount==5 and plan[1].amount=={"blade":2,"chainsword":3,"fist":1}[mode],"Default melee omitted gauntlet or extra relic attacks")
 C.UnitActions.attach(s,300,7)
 s.phase="deployment"
 check(equip(s,"blade").is_empty() and equip(s,"rifle").is_empty(),"Gravis equipment not reversible after attachment")
 s.unit_abilities.implementation="historical"
 check(C.UnitAbilities.damage(s,300,3)==3,"Refuse to Yield leaked into historical implementation")
 print("Gravis Captain checks: %d failures" % failures)
 quit(0 if failures==0 else 1)
