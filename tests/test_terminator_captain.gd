extends SceneTree
const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const Groups = preload("res://scripts/edition_11/defender_groups.gd")
const P = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Army = preload("res://scripts/edition_11/army_capabilities.gd")
const WeaponChecks = preload("res://tests/space_marine_datasheet_checks.gd")
const U = preload("res://scripts/edition_11/unit_prevention.gd")
const MatchCommands = preload("res://scripts/edition_11/match_command_service.gd")
const PublicUnitCommand = preload("res://tests/public_unit_command.gd")
var failures := 0
func check(ok: bool, message: String) -> void:
 if not ok:
  push_error(message)
  failures += 1
func six() -> int: return 6
func four() -> int: return 4
func three() -> int: return 3
func entry(name: String, models: int = 1) -> Dictionary:
 return {"definition_id": "40kdc:11e:adeptus-astartes:" + name, "models": models, "copies": 1}
func model_for(state: Dictionary, owner: int, identity: String) -> int:
 for model: int in state.units:
  var unit: Dictionary = state.units[model]
  if int(unit.get("owner", -1)) == owner and C.UnitAbilities.identity(unit) == identity: return model
 return -1
func fixture(attached: bool = true) -> Dictionary:
 var lists := F.current_marine_selections()
 lists[1].entries = [entry("captain-in-terminator-armour"), entry("intercessor-squad", 5), entry("terminator-squad", 5)]
 lists[2].entries = [entry("captain-in-terminator-armour"), entry("intercessor-squad", 5), entry("terminator-squad", 5)]
 var s := F.P.initial_state({"unit_abilities": true, "combat_doctrines": true, "reanimation_protocols": true, "awakened_dynasty": true, "core_stratagems": true, "manual_allocation": false}, lists)
 if s.has("error"): return s
 if attached: C.UnitActions.attach(s, 100, 5)
 s.mission.stage = "battle"
 s.phase = "shooting"
 s.turn = 3
 s.round = 2
 s.active = 1
 s.unit_abilities.setup_players = [1, 2]
 s.unit_abilities.battle_players = [1, 2]
 s.unit_abilities.window = {}
 s.unit_abilities.phase_key = C.UnitActions.key(s)
 s.awakened_dynasty.pending = []
 s.terrain.areas = []
 s.cp = {1: 0, 2: 0}
 for model: int in s.units:
  s.units[model].on_battlefield = true
  s.units[model].position = Vector2(-18,16) if s.units[model].owner == 1 else Vector2(18,16)
 for model: int in C.living(s, 5): s.units[model].position = Vector2(0,-8)
 s.units[100].position = Vector2(0,-10)
 return s
func choose(s: Dictionary, action: String, value: String) -> String:
 for option: Dictionary in C.unit_choices(s, 1):
  if option.action == action and option.value == value: return PublicUnitCommand.error(s, 1, option)
 return "Choice unavailable"
func one() -> int: return 1
func bad() -> int: return 7
func charge_fixture() -> Dictionary:
 var s := fixture()
 s.phase = "charge"
 s.unit_abilities.phase_key = C.UnitActions.key(s)
 s.stratagems.movement_rerolls = false
 for model: int in C.living(s, 2): s.units[model].position = Vector2(0,0)
 return s
func _initialize() -> void: call_deferred("run")
func run() -> void:
 var s := fixture()
 check(not s.has("error"), "Terminator Captain admission failed: %s" % str(s.get("error", "")))
 if s.has("error"):
  print(s)
  quit(1)
  return
 var profile: Dictionary = P.profile("captain-in-terminator-armour")
 check(profile.source_book_id == "000000139" and profile.source_datasheet_id == "000000135" and profile.source_export_updated_at == "2026-10-16T21:03:46+03:00", "Captain preserves its local Wahapedia source identity")
 check(profile.models == 1 and is_equal_approx(profile.base_radius_inches, 20.0/25.4) and profile.points_by_models == {1: 90} and profile.stats == {"movement_inches": 5, "toughness": 6, "save_target": 2, "wounds": 6, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 4}, "Captain's one-model profile, base, characteristics and price match the local export")
 check(profile.keywords == ["INFANTRY", "CAPTAIN", "CHARACTER", "IMPERIUM", "TERMINATOR", "ADEPTUS ASTARTES"] and "DEATHWING" not in profile.keywords, "Captain retains unconditional keywords and excludes chapter-conditional Deathwing")
 var resolution := Army.resolve("Space Marines", "40kdc:11e:adeptus-astartes:captain-in-terminator-armour")
 check(resolution.get("error", "").is_empty() and int(resolution.get("cost", -1)) == 90 and resolution.get("unsupported_abilities", []).is_empty(), "Captain resolves from the consolidated local catalog with no blocked abilities")
 var admitted := Army.admit({"schema_version": 2, "faction": "Space Marines", "category": "incursion", "points_limit": 1000, "entries": [entry("captain-in-terminator-armour")]})
 check(admitted.error.is_empty() and admitted.total == 90, "Captain is admitted at the local 90-point cost")
 for owner in [1, 2]:
  var owner_model := model_for(s, owner, "captain-in-terminator-armour")
  check(owner_model >= 0 and s.units[owner_model].max_wounds == 6, "Player %d materializes the current Terminator Captain profile" % owner)
 var expected_keywords := ["leader", "deep-strike", "combat-doctrines", "strategic-acumen", "unstoppable-valour", "transhuman-strategist"]
 for ability: String in expected_keywords:
  check(C.UnitAbilities.has(s, 5, ability), "Captain retains source ability %s" % ability)
 check(not C.UnitAbilities.has(s, 5, "finest-hour"), "Terminator Captain does not inherit the ordinary Captain's Finest Hour")
 var weapon_failures := WeaponChecks.fixed_weapon_plan_failures(s, profile, 100, 2)
 check(weapon_failures.is_empty(), "Default Storm Bolter and Relic Weapon pass Equipment and AttackPlan: %s" % str(weapon_failures))
 check(s.training_points[1] == 365 and s.units[100].max_wounds == 6 and is_equal_approx(s.units[100].radius,20.0/25.4), "Captain stats/price/base incorrect")
 check(C.UnitAbilities.has(s,5,"strategic-acumen") and C.UnitAbilities.has(s,5,"transhuman-strategist") and C.UnitAbilities.has(s,5,"deep-strike") and not C.UnitAbilities.has(s,5,"finest-hour"), "Captain identities/abilities merged")
 s = charge_fixture()
 s.squads[5].battle_shocked = true
 check(C.declare_charge(s,1,500,s.revision,one).error.is_empty() and s.stratagems.pending.get("valour",false), "Free charge decision unavailable at zero CP while shocked")
 var before := var_to_str(s)
 check(not C.resolve_roll_reaction(s,2,5,"unstoppable-valour",s.revision,six).is_empty() and var_to_str(s)==before, "Opponent rerolled charge")
 check(not C.resolve_roll_reaction(s,1,5,"unstoppable-valour",s.revision-1,six).is_empty() and var_to_str(s)==before, "Stale charge reroll accepted")
 check(not C.resolve_roll_reaction(s,1,5,"unstoppable-valour",s.revision,bad).is_empty() and var_to_str(s)==before, "Invalid dice changed charge")
 var valour_decision := C.Stratagems.pending_decision(s)
 var valour_option: Dictionary = {}
 for option: Dictionary in valour_decision.get("legal_options", []):
  if int(option.get("target", -1)) == 5 and str(option.get("value", "")) == "unstoppable-valour": valour_option = option
 var valour_choice := {"action": "stratagem-reaction", "model": -1, "target": 5, "value": "unstoppable-valour", "die": -1}
 var valour_envelope := {"_decision_type": MatchCommands.STRATAGEM_DECISION_ENVELOPE, "decision_id": str(valour_decision.get("decision_id", "")), "option_id": str(valour_option.get("id", "")), "choice": valour_choice}
 var before_wrong_valour_owner := var_to_bytes(s)
 var wrong_valour_owner := MatchCommands.execute(s, 2, {"kind": MatchCommands.COMMAND_REACTION, "choice": valour_envelope, "revision": s.revision}, six)
 check(not str(wrong_valour_owner.get("error", "")).is_empty() and var_to_bytes(s) == before_wrong_valour_owner, "The opponent cannot submit or mutate Unstoppable Valour's Charge decision")
 var stale_valour := MatchCommands.execute(s, 1, {"kind": MatchCommands.COMMAND_REACTION, "choice": valour_envelope, "revision": s.revision - 1}, six)
 check(not str(stale_valour.get("error", "")).is_empty() and var_to_bytes(s) == before_wrong_valour_owner, "A stale public Unstoppable Valour command leaves Charge unchanged")
 var valour_result := MatchCommands.execute(s, 1, {"kind": MatchCommands.COMMAND_REACTION, "choice": valour_envelope, "revision": s.revision}, six)
 check(str(valour_result.get("error", "")).is_empty() and s.pending_charge.rolls == [6,6] and s.cp[1]==0 and s.stratagems.uses.is_empty(), "Valour uses the public command to replace both dice for zero CP")
 check(not C.resolve_roll_reaction(s,1,5,"command-re-roll",s.revision,six).is_empty() and not C.resolve_roll_reaction(s,1,5,"unstoppable-valour",s.revision,six).is_empty(), "Charge dice rerolled twice")
 s = charge_fixture()
 check(C.declare_charge(s,1,500,s.revision,six).error.is_empty() and C.resolve_roll_reaction(s,1,5,"unstoppable-valour",s.revision,one).is_empty() and s.pending_charge.is_empty() and s.last_command_roll.rolls==[1,1], "Lower reroll result not mandatory")
 s = charge_fixture()
 check(C.declare_charge(s,1,500,s.revision,six).error.is_empty() and C.resolve_roll_reaction(s,1,5,"",s.revision).is_empty() and s.pending_charge.rolls==[6,6] and not s.last_command_roll.rerolled, "Accept did not preserve original charge")
 s = charge_fixture()
 s.units[100].wounds = 0
 check(C.declare_charge(s,1,500,s.revision,one).error.is_empty() and s.stratagems.pending.is_empty(), "Dead Captain granted Valour")
 s = fixture(false)
 check(C.UnitActions.attachment_allowed(s,100,5) and not C.UnitActions.attachment_allowed(s,100,3), "Captain attachment crosses armour boundary")
 s.phase = "deployment"
 s.unit_abilities.setup_players = []
 check(choose(s,"terminator-captain-gun","combi").is_empty() and choose(s,"terminator-captain-blade","fist").is_empty(), "Captain weapon replacements unavailable")
 check(s.units[100].ranged_weapons.size()==1 and s.units[100].ranged_weapons[0].profiles.size()==3 and s.units[100].melee_weapons[0].id=="relic-fist", "Combi modes treated as separate weapons or fist missing")
 var combi: Dictionary = s.units[100].ranged_weapons[0].profiles
 check(combi.infernus.keywords.torrent and combi.infernus.keywords.blast==1 and combi.damnatus.keywords.melta==2 and combi.damnatus.damage=="D3+2", "Combi characteristics/traits incorrect")
 var alternate_profile := {"ranged": P.terminator_captain_weapons(true, false).ranged, "melee": P.terminator_captain_weapons(true, true).melee}
 weapon_failures = WeaponChecks.fixed_weapon_plan_failures(s, alternate_profile, 100, 2)
 check(weapon_failures.is_empty(), "Selected Combi-weapon profiles and Relic Fist pass Equipment and AttackPlan: %s" % str(weapon_failures))
 C.UnitActions.attach(s,100,5)
 s.phase = "deployment"
 check(s.squads[5].training_cost==280 and choose(s,"terminator-captain-gun","bolter").is_empty() and s.units[100].melee_weapons[0].id=="relic-fist", "Gun swap changed fist or attachment cost omitted Captain")
 check(choose(s,"terminator-captain-blade","weapon").is_empty() and s.units[100].ranged_weapons==P.profile("captain-in-terminator-armour").ranged and s.units[100].melee_weapons==P.profile("captain-in-terminator-armour").melee, "Default equipment not restored after attachment")
 s.phase = "command"
 s.unit_abilities.setup_players=[1,2]
 s.unit_abilities.phase_key=C.UnitActions.key(s)
 s.combat_doctrines.selected_turn[1]=s.turn
 var acumen: Dictionary = {}
 for option: Dictionary in C.unit_choices(s,1):
  if option.action=="acumen": acumen=option; break
 check(not acumen.is_empty(), "Strategic Acumen unavailable to Terminator Captain")
 if not acumen.is_empty():
  var before_wrong_acumen_owner := var_to_bytes(s)
  var wrong_acumen_owner := MatchCommands.execute(s,2,{"kind":MatchCommands.SELECT_UNIT_CHOICE,"choice":acumen,"revision":s.revision})
  check(not str(wrong_acumen_owner.get("error","")).is_empty() and var_to_bytes(s)==before_wrong_acumen_owner,"The opponent cannot submit or mutate the Terminator Captain's immediate Strategic Acumen choice")
  var acumen_result := MatchCommands.execute(s,1,{"kind":MatchCommands.SELECT_UNIT_CHOICE,"choice":acumen,"revision":s.revision})
  check(str(acumen_result.get("error","")).is_empty() and s.unit_abilities.doctrines[5].doctrine==acumen.value, "Strategic Acumen resolves through the public command for the Terminator Captain")
 s = charge_fixture()
 s.cp[1]=2
 s.stratagems.attack_rerolls=true
 check(C.declare_charge(s,1,500,s.revision,one).error.is_empty(), "Charge window setup failed")
 before=var_to_str(s)
 check(not C.resolve_roll_reaction(s,1,5,"command-re-roll",s.revision,six).is_empty() and var_to_str(s)==before, "Attack-only reroll option enabled paid charge reroll")
 s.stratagems.movement_rerolls=true
 var reroll_decision := C.Stratagems.pending_decision(s)
 var reroll_option: Dictionary = {}
 for option: Dictionary in reroll_decision.get("legal_options", []):
  if int(option.get("target", -1)) == 5 and str(option.get("value", "")) == "command-re-roll": reroll_option = option
 var reroll_choice := {"action": "stratagem-reaction", "model": -1, "target": 5, "value": "command-re-roll", "die": -1}
 var reroll_envelope := {"_decision_type": MatchCommands.STRATAGEM_DECISION_ENVELOPE, "decision_id": str(reroll_decision.get("decision_id", "")), "option_id": str(reroll_option.get("id", "")), "choice": reroll_choice}
 var paid_reroll := MatchCommands.execute(s, 1, {"kind": MatchCommands.COMMAND_REACTION, "choice": reroll_envelope, "revision": s.revision}, six)
 check(str(paid_reroll.get("error", "")).is_empty() and s.cp[1]==1 and s.stratagems.uses.size()==1, "Public paid alternative did not consume CP/use")
 s=fixture(false)
 s.units[100].ranged_weapons=P.terminator_captain_weapons(true,false).ranged
 for model: int in C.living(s,2): s.units[model].position=Vector2(0,-2)
 s.units[100].position=Vector2(0,-8)
 for mode: String in ["infernus","purgatus","damnatus"]:
  var rows: Array=[{"model":100,"target":2,"amount":1,"weapon":"combi-weapon","profile":mode}]
  var prepared := C.AttackPlan.prepare(s,1,false,rows,true)
  check(prepared.error.is_empty(), "Combi profile rejected by attack engine: "+mode+" "+prepared.error)
 var mixed: Array=[{"model":100,"target":2,"amount":1,"weapon":"combi-weapon","profile":"infernus"},{"model":100,"target":2,"amount":1,"weapon":"combi-weapon","profile":"purgatus"}]
 check(not C.AttackPlan.prepare(s,1,false,mixed,true).error.is_empty(), "Two Combi profiles fired in same declaration")
 var invalid: Dictionary = P.terminator_captain_weapons(true,false).ranged[0].profiles.infernus.duplicate(true)
 var automatic := C.Attacks.roll_pool(invalid,C.AttackPlan.defender(s,2),{"weapon_count":1,"target_model_count":5,"benefit_of_cover":true},six)
 check(automatic.error.is_empty() and automatic.hit_rolls.is_empty() and automatic.hits==automatic.attacks, "Torrent with no BS rolled to hit or lost automatic hits in cover")
 invalid.keywords.erase("torrent")
 check(not C.Attacks._validate(invalid,C.AttackPlan.defender(s,2),{}).is_empty(), "Zero BS admitted without Torrent")
 s = fixture(false)
 s.unit_abilities.warlords = {1: 100}
 s.round = 1
 s.cp[1] = 0
 C.UnitActions.start_round(s)
 check(s.cp[1] == 1, "Transhuman Strategist grants its Warlord CP to the Terminator Captain")
 C.UnitActions.start_round(s)
 check(s.cp[1] == 1, "Terminator Captain cannot grant the Warlord CP twice in a battle round")
 s.round = 2
 s.units[100].wounds = 0
 C.UnitActions.start_round(s)
 check(s.cp[1] == 1, "A destroyed Terminator Captain no longer grants Transhuman Strategist CP")
 print("Terminator Captain checks: %d failures" % failures)
 quit(0 if failures==0 else 1)
