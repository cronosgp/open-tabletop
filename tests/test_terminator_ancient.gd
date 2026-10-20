extends SceneTree
## Written for the deferred final batch; not executed during implementation.
const F = preload("res://tests/marine_gravis_ancient_fixture.gd")
const C = F.C
const P = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const S = preload("res://scripts/edition_11/support_attachments.gd")
var failures := 0
func check(ok: bool,message: String) -> void:
 if not ok:push_error(message);failures+=1
func six() -> int:return 6
func _initialize() -> void:call_deferred("run")
func run() -> void:
 var s := F.fixture()
 check(not s.has("error"),"Terminator Ancient admission failed")
 if s.has("error"):print(s);quit(1);return
 check(P.profile("ancient-in-terminator-armour").points==75 and s.units[100].max_wounds==5 and s.units[100].attachment_role=="support" and s.units[500].attachment_role=="leader","Ancient stats/cost/separate Support slot incorrect")
 check(s.squads[9].training_cost==355 and C.UnitAbilities.has(s,9,"deep-strike"),"Combined Terminator formation cost/Deep Strike incorrect")
 check("DEATHWING" not in s.units[100].keywords and not C.UnitAbilities.has(s,9,"honour-of-the-company") and not C.UnitAbilities.has(s,9,"deeds-of-legend"),"Ancient variants or chapter adaptations merged")
 check(C.UnitAbilities.defensive_wound_modifier(s,9,7,6)==-1 and C.UnitAbilities.defensive_wound_modifier(s,9,6,6)==0 and C.UnitAbilities.defensive_wound_modifier(s,9,5,6)==0,"Standard strict S>T condition incorrect")
 s.squads[9].battle_shocked=true
 check(C.UnitAbilities.defensive_wound_modifier(s,9,7,6)==-1,"Defensive standard incorrectly requires objective control")
 s.squads[9].battle_shocked=false
 s.units[100].position=Vector2(-15,15)
 check(C.UnitAbilities.defensive_wound_modifier(s,9,7,6)==-1,"Standard requires bearer itself in objective range")
 s.units[100].wounds=0
 check(C.UnitAbilities.defensive_wound_modifier(s,9,7,6)==0,"Dead Ancient retained defensive standard")
 s=F.fixture()
 for model: int in C.living(s,9):s.units[model].position=Vector2(-15,15)
 check(C.UnitAbilities.defensive_wound_modifier(s,9,7,6)==0,"Standard active outside objective range")
 s=F.fixture()
 for model: int in C.living(s,2):
  s.units[model].position=Vector2(0,-2)
  s.units[model].ranged_weapons=[{"id":"standard-probe","profiles":{"standard":{"name":"Standard probe","attacks":1,"skill":3,"strength":7,"ap":0,"damage":1,"range_inches":24,"keywords":{}}}}]
 var plan := C.AttackPlan.single_target(s,2,9,false)
 var prepared := C.AttackPlan.prepare(s,2,false,plan,true)
 check(prepared.error.is_empty() and not prepared.get("batches",[]).is_empty(),"Attack targeting standard rejected")
 for batch: Dictionary in prepared.get("batches",[]):
  check(int(batch.context.get("wound_modifier",0))==(-1 if batch.weapon.strength>6 else 0),"Attack declaration missed S/T defensive condition")
 s.units[100].wounds=0
 for batch: Dictionary in prepared.get("batches",[]):check(batch.context.wound_modifier==-1,"Prepared defence lost source effect mid-attack declaration")
 s.units[100].wounds=5
 s.phase="movement"
 s.unit_abilities.phase_key=C.UnitActions.key(s)
 check(C.advance_phase(s,1,s.revision,six).is_empty() and s.mission.objectives[0].secured==1,"Terminator Ancient did not Raise the Banner")
 check(not S.matching_error([F.entry("ancient-in-terminator-armour"),F.entry("heavy-intercessor-squad",5)]).is_empty(),"Terminator Support admitted with Gravis bodyguard")
 s=F.fixture(false)
 check(C.UnitActions.attachment_allowed(s,100,9) and not C.UnitActions.attachment_allowed(s,100,7),"Ancient attachment boundary incorrect")
 s.unit_abilities.implementation="historical"
 check(C.UnitAbilities.defensive_wound_modifier(s,9,7,6)==0,"Standard leaked into historical implementation")
 print("Terminator Ancient checks: %d failures" % failures)
 quit(0 if failures==0 else 1)
