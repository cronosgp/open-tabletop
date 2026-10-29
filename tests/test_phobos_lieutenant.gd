extends SceneTree
## Batch suite written for the final run; not executed during implementation.
const F = preload("res://tests/marine_phobos_fixture.gd")
const AllUnits = preload("res://tests/all_units_fixture.gd")
const C = F.C
const P = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const ArmyCatalog = preload("res://scripts/edition_11/army_capabilities.gd")
const MarineLinks = preload("res://scripts/edition_11/marine_leader_links.gd")
const WeaponChecks = preload("res://tests/space_marine_datasheet_checks.gd")
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
func entry(identity: String,models: int = 1,copies: int = 1) -> Dictionary:
 return {"definition_id":"40kdc:11e:adeptus-astartes:"+identity,"models":models,"copies":copies}
func current_catalog_selections() -> Dictionary:
 var lists := AllUnits.current_marine_selections()
 for owner: int in [1,2]:
  lists[owner].entries=[entry("captain"),entry("eliminator-squad",3),entry("infiltrator-squad",5),entry("incursor-squad",5),entry("reiver-squad",5),entry("lieutenant-in-phobos-armour")]
 return lists
func find_model(s: Dictionary,owner: int,identity: String) -> int:
 for model: int in s.units:
  if int(s.units[model].owner)==owner and C.UnitAbilities.identity(s.units[model])==identity:return model
 return -1
func find_squad(s: Dictionary,owner: int,identity: String) -> int:
 for squad: int in s.squads:
  if int(s.squads[squad].get("owner",-1))!=owner:continue
  var living: Array[int]=C.living(s,int(squad))
  if not living.is_empty() and C.UnitAbilities.identity(s.units[living[0]])==identity:return int(squad)
 return -1
func _initialize() -> void:call_deferred("run")
func run() -> void:
 var s := F.fixture()
 check(not s.has("error"),"Phobos Lieutenant admission failed")
 if s.has("error"):print(s);quit(1);return
 var profile: Dictionary=P.profile("lieutenant-in-phobos-armour")
 check(profile.source_book_id=="000000139" and profile.source_datasheet_id=="000002530" and profile.source_export_updated_at=="2026-10-16T21:03:46+03:00","Profile identifies the pinned shared-book datasheet and export timestamp")
 check(profile.points==40 and profile.points_by_models=={1:40} and profile.models==1 and s.units[700].max_wounds==4 and s.units[700].movement==8 and s.units[700].attachment_role=="support","One-model 40-point Support profile or characteristics incorrect")
 check(is_equal_approx(float(profile.base_radius_inches),20.0/25.4) and profile.stats=={"movement_inches":8,"toughness":4,"save_target":3,"wounds":4,"leadership_target":6,"objective_control":1,"invulnerable_target":0},"40 mm base and source characteristics mismatch")
 var expected_keywords: Array[String]=["INFANTRY","CHARACTER","EXPLOSIVES","IMPERIUM","PHOBOS","SMOKE","ADEPTUS ASTARTES"]
 var actual_keywords: Array=profile.keywords.duplicate()
 expected_keywords.sort();actual_keywords.sort()
 check(actual_keywords==expected_keywords,"Lieutenant keywords differ from the pinned export")
 check(ArmyCatalog.resolve("Space Marines","40kdc:11e:adeptus-astartes:lieutenant-in-phobos-armour").get("error","").is_empty(),"Lieutenant resolves from the consolidated local roster catalog")
 var weapon_failures: Array[String]=WeaponChecks.fixed_weapon_plan_failures(s,profile,700,int(s.units[200].squad))
 check(weapon_failures.is_empty(),"Default pistol and combat blades fail Equipment/AttackPlan checks: %s" % str(weapon_failures))
 var marine_links: Array=MarineLinks.TARGETS.get("lieutenant-in-phobos-armour",[]).duplicate()
 marine_links.sort()
 check(marine_links==["eliminator-squad","incursor-squad","infiltrator-squad","reiver-squad"],"Common-book Leader links differ from the four source-listed Space Marine squads")
 for ability: String in ["support","combat-doctrines","infiltrators","deep-strike","tactical-precision","demi-company-commander"]:check(C.UnitAbilities.has(s,5,ability),"Lieutenant is missing source ability %s" % ability)
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
 var alternate_profile: Dictionary={"ranged":P.phobos_lieutenant_gun(true),"melee":profile.melee}
 weapon_failures=WeaponChecks.fixed_weapon_plan_failures(s,alternate_profile,700,int(s.units[200].squad))
 check(weapon_failures.is_empty(),"Replacement carbine and retained combat blades fail Equipment/AttackPlan checks: %s" % str(weapon_failures))
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
 var symmetric := AllUnits.P.initial_state({"checked_rosters":false,"official_mission":false,"unit_abilities":true,"combat_doctrines":true,"reanimation_protocols":true,"awakened_dynasty":true,"core_stratagems":true,"manual_allocation":false},current_catalog_selections())
 check(not symmetric.has("error"),"Both sides' current Marine catalogs admit the Lieutenant and all four common Leader targets")
 if not symmetric.has("error"):
  var current_links := MarineLinks.TARGETS["lieutenant-in-phobos-armour"].duplicate()
  for owner: int in [1,2]:
   var current_lieutenant := find_model(symmetric,owner,"lieutenant-in-phobos-armour")
   check(current_lieutenant>0,"Player %d materializes the Lieutenant from the consolidated current catalog" % owner)
   for target_identity: String in current_links:
    var target_squad := find_squad(symmetric,owner,target_identity)
    check(target_squad>0 and C.UnitActions.attachment_allowed(symmetric,current_lieutenant,target_squad),"Player %d Lieutenant can lead source-linked %s" % [owner,target_identity])
  var one_copy := ArmyCatalog.admit({"schema_version":2,"faction":"Space Marines","category":"custom","points_limit":1000,"entries":[entry("lieutenant-in-phobos-armour")]})
  var three_copies := ArmyCatalog.admit({"schema_version":2,"faction":"Space Marines","category":"custom","points_limit":1000,"entries":[entry("lieutenant-in-phobos-armour",1,3)]})
  var four_copies := ArmyCatalog.admit({"schema_version":2,"faction":"Space Marines","category":"custom","points_limit":1000,"entries":[entry("lieutenant-in-phobos-armour",1,4)]})
  check(one_copy.get("error","").is_empty() and int(one_copy.get("total",-1))==40 and three_copies.get("error","").is_empty() and int(three_copies.get("total",-1))==120 and not str(four_copies.get("error","")).is_empty(),"Local construction applies the non-Epic three-copy limit")
 print("Phobos Lieutenant checks: %d failures" % failures)
 quit(0 if failures==0 else 1)
