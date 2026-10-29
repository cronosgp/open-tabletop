extends RefCounted
const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
static func entry(name: String, models: int = 1) -> Dictionary:
 return {"definition_id":"40kdc:11e:adeptus-astartes:"+name,"models":models,"copies":1}
static func fixture(attached: bool = true, models: int = 5) -> Dictionary:
 var lists := F.current_marine_selections()
 lists[1].entries=[entry("captain"),entry("eliminator-squad",3),entry("infiltrator-squad",models),entry("lieutenant-in-phobos-armour")]
 lists[2].entries=[entry("captain")]
 var s := F.P.initial_state({"checked_rosters":false,"official_mission":false,"unit_abilities":true,"combat_doctrines":true,"reanimation_protocols":true,"awakened_dynasty":true,"core_stratagems":true,"manual_allocation":false},lists)
 if s.has("error"):return s
 if attached:C.UnitActions.attach(s,700,5)
 s.mission.stage="battle"
 s.phase="command"
 s.active=1
 s.turn=3
 s.round=2
 s.unit_abilities.setup_players=[1,2]
 s.unit_abilities.battle_players=[1,2]
 s.unit_abilities.window={}
 s.unit_abilities.phase_key=C.UnitActions.key(s)
 s.awakened_dynasty.pending=[]
 s.combat_doctrines.selected_turn[1]=3
 s.terrain.areas=[]
 s.cp={1:0,2:0}
 for model: int in s.units:
  s.units[model].on_battlefield=true
  s.units[model].position=Vector2(-18,16) if s.units[model].owner==1 else Vector2(18,16)
 var positions := {500:Vector2(0,-8),501:Vector2(1.7,-8),502:Vector2(3.4,-8),503:Vector2(0,-6.3),504:Vector2(1.7,-6.3),700:Vector2(0,-9.8)}
 for model: int in positions:s.units[model].position=positions[model]
 for model: int in C.living(s,2):s.units[model].position=Vector2(0,3)
 s.unit_abilities.anchors={5:C.living(s,5)}
 return s
