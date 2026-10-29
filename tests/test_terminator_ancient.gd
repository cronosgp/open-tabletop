extends SceneTree
const F = preload("res://tests/marine_gravis_ancient_fixture.gd")
const All = preload("res://tests/all_units_fixture.gd")
const C = F.C
const P = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Army = preload("res://scripts/edition_11/army_capabilities.gd")
const S = preload("res://scripts/edition_11/support_attachments.gd")
const WeaponChecks = preload("res://tests/space_marine_datasheet_checks.gd")
var failures := 0
func check(ok: bool,message: String) -> void:
 if not ok:push_error(message);failures+=1
func six() -> int:return 6
func model_for(state: Dictionary, owner: int, identity: String) -> int:
 for model: int in state.units:
  var unit: Dictionary = state.units[model]
  if int(unit.get("owner", -1)) == owner and C.UnitAbilities.identity(unit) == identity: return model
 return -1
func fixture(attached: bool = true) -> Dictionary:
 var lists := All.current_marine_selections()
 var entries: Array = [F.entry("ancient-in-terminator-armour"), F.entry("captain-in-gravis-armour"), F.entry("captain-in-terminator-armour"), F.entry("heavy-intercessor-squad", 5), F.entry("terminator-squad", 5)]
 lists[1].entries = entries.duplicate(true)
 lists[2].entries = entries.duplicate(true)
 var state := All.P.initial_state({"unit_abilities": true, "combat_doctrines": true, "reanimation_protocols": true, "awakened_dynasty": true, "core_stratagems": true, "manual_allocation": false}, lists)
 if state.has("error"): return state
 if attached:
  C.UnitActions.attach(state, 100, 9)
  C.UnitActions.attach(state, 500, 9)
  C.UnitActions.attach(state, 300, 7)
 state.mission.stage = "battle"
 state.phase = "shooting"
 state.active = 1
 state.turn = 3
 state.round = 2
 state.unit_abilities.setup_players = [1, 2]
 state.unit_abilities.battle_players = [1, 2]
 state.unit_abilities.window = {}
 state.unit_abilities.phase_key = C.UnitActions.key(state)
 state.awakened_dynasty.pending = []
 state.terrain.areas = []
 state.cp = {1: 0, 2: 0}
 state.mission.objectives = [{"name": "Standard test", "kind": "marker", "position": Vector2(0, -8), "controller": 0, "secured": 0, "levels": {1: 0, 2: 0}}]
 for model: int in state.units:
  state.units[model].on_battlefield = true
  state.units[model].position = Vector2(-15, 15) if state.units[model].owner == 1 else Vector2(18, 16)
 for model: int in C.living(state, 9): state.units[model].position = Vector2(0, -8)
 return state
func _initialize() -> void:call_deferred("run")
func run() -> void:
 var s := fixture()
 check(not s.has("error"),"Terminator Ancient admission failed: %s" % str(s.get("error", "")))
 if s.has("error"):print(s);quit(1);return
 var profile: Dictionary = P.profile("ancient-in-terminator-armour")
 check(profile.source_book_id == "000000139" and profile.source_datasheet_id == "000002677" and profile.source_export_updated_at == "2026-10-16T21:03:46+03:00", "Ancient preserves its local Wahapedia source identity")
 check(profile.models == 1 and is_equal_approx(profile.base_radius_inches, 20.0/25.4) and profile.points_by_models == {1: 75} and profile.stats == {"movement_inches": 5, "toughness": 6, "save_target": 2, "wounds": 5, "leadership_target": 6, "objective_control": 2, "invulnerable_target": 4}, "Ancient's one-model profile, base, characteristics and price match the local export")
 check(profile.keywords == ["INFANTRY", "ANCIENT", "CHARACTER", "IMPERIUM", "TERMINATOR", "ADEPTUS ASTARTES"] and "DEATHWING" not in profile.keywords, "Ancient retains unconditional keywords and excludes chapter-conditional Deathwing")
 var resolution := Army.resolve("Space Marines", "40kdc:11e:adeptus-astartes:ancient-in-terminator-armour")
 check(resolution.get("error", "").is_empty() and int(resolution.get("cost", -1)) == 75 and resolution.get("unsupported_abilities", []).is_empty(), "Ancient resolves from the consolidated local catalog with no blocked abilities")
 var admitted := Army.admit({"schema_version": 2, "faction": "Space Marines", "category": "incursion", "points_limit": 1000, "entries": [F.entry("ancient-in-terminator-armour")]})
 check(admitted.error.is_empty() and admitted.total == 75, "Ancient is admitted at the local 75-point cost")
 for owner in [1, 2]:
  var owner_model := model_for(s, owner, "ancient-in-terminator-armour")
  check(owner_model >= 0 and s.units[owner_model].max_wounds == 5, "Player %d materializes the current Terminator Ancient profile" % owner)
 for ability: String in ["support", "deep-strike", "combat-doctrines", "raise-the-banner", "never-shall-the-standard-fall"]:
  check(C.UnitAbilities.has(s, 9, ability), "Ancient retains source ability %s" % ability)
 var weapon_failures := WeaponChecks.fixed_weapon_plan_failures(s, profile, 100, 2)
 check(weapon_failures.is_empty(), "Storm Bolter and Master-crafted Power Weapon pass Equipment and AttackPlan: %s" % str(weapon_failures))
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
 s=fixture()
 for model: int in C.living(s,9):s.units[model].position=Vector2(-15,15)
 check(C.UnitAbilities.defensive_wound_modifier(s,9,7,6)==0,"Standard active outside objective range")
 s=fixture()
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
 s=fixture(false)
 check(C.UnitActions.attachment_allowed(s,100,9) and not C.UnitActions.attachment_allowed(s,100,7),"Ancient attachment boundary incorrect")
 s.unit_abilities.implementation="historical"
 check(C.UnitAbilities.defensive_wound_modifier(s,9,7,6)==0,"Standard leaked into historical implementation")
 print("Terminator Ancient checks: %d failures" % failures)
 quit(0 if failures==0 else 1)
