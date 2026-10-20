extends RefCounted
const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
static func entry(name: String, models: int = 1) -> Dictionary:
 return {"definition_id":"40kdc:11e:adeptus-astartes:"+name,"models":models,"copies":1}
static func fixture(attached: bool = true) -> Dictionary:
 var lists := F.selections()
 lists[1].entries=[entry("ancient-in-terminator-armour"),entry("captain-in-gravis-armour"),entry("captain-in-terminator-armour"),entry("heavy-intercessor-squad",5),entry("terminator-squad",5)]
 var s := F.P.initial_state({"checked_rosters":true,"official_mission":true,"unit_abilities":true,"combat_doctrines":true,"reanimation_protocols":true,"awakened_dynasty":true,"core_stratagems":true,"manual_allocation":false},lists)
 if s.has("error"):return s
 if attached:
  C.UnitActions.attach(s,100,9)
  C.UnitActions.attach(s,500,9)
  C.UnitActions.attach(s,300,7)
 s.mission.stage="battle"
 s.phase="shooting"
 s.active=1
 s.turn=3
 s.round=2
 s.unit_abilities.setup_players=[1,2]
 s.unit_abilities.battle_players=[1,2]
 s.unit_abilities.window={}
 s.unit_abilities.phase_key=C.UnitActions.key(s)
 s.awakened_dynasty.pending=[]
 s.terrain.areas=[]
 s.cp={1:0,2:0}
 s.mission.objectives=[{"name":"Standard test","kind":"marker","position":Vector2(0,-8),"controller":0,"secured":0,"levels":{1:0,2:0}}]
 for model: int in s.units:
  s.units[model].on_battlefield=true
  s.units[model].position=Vector2(-15,15) if s.units[model].owner==1 else Vector2(18,16)
 for model: int in C.living(s,9):s.units[model].position=Vector2(0,-8)
 return s
