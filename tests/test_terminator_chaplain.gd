extends SceneTree
const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const Groups = preload("res://scripts/edition_11/defender_groups.gd")
const P = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Army = preload("res://scripts/edition_11/army_capabilities.gd")
const WeaponChecks = preload("res://tests/space_marine_datasheet_checks.gd")
const U = preload("res://scripts/edition_11/unit_prevention.gd")
const MatchCommandService = preload("res://scripts/edition_11/match_command_service.gd")
const PendingDecisions = preload("res://scripts/edition_11/pending_decision_registry.gd")
const ResolutionFrames = preload("res://scripts/edition_11/resolution_frame.gd")
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
 lists[1].entries = [entry("chaplain-in-terminator-armour"), entry("intercessor-squad", 5), entry("terminator-squad", 5)]
 lists[2].entries = [entry("chaplain-in-terminator-armour"), entry("intercessor-squad", 5), entry("terminator-squad", 5)]
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
func equip(s: Dictionary, value: String) -> String:
 for option: Dictionary in C.unit_choices(s, 1):
  if option.action != "terminator-chaplain-shield" or option.value != value: continue
  var decision := PendingDecisions.current(s, ["unit-actions"])
  for projected: Dictionary in decision.get("legal_options", []):
   if str(projected.get("action", "")) != str(option.get("action", "")) or int(projected.get("model", -1)) != int(option.get("model", -1)) or int(projected.get("target", -1)) != int(option.get("target", -1)) or str(projected.get("value", "")) != str(option.get("value", "")): continue
   var result := MatchCommandService.execute(s, 1, {
    "kind": MatchCommandService.SELECT_UNIT_CHOICE,
    "choice": {
     "_decision_type": MatchCommandService.UNIT_CHOICE_ENVELOPE,
     "decision_id": str(decision.get("decision_id", "")),
     "option_id": str(projected.get("id", "")),
     "choice": option
    },
    "revision": s.revision
   })
   return str(result.get("error", ""))
  return "Equipment option is absent from the current preparation decision."
 return "Equipment choice unavailable"
func submit_reserve(s: Dictionary, player: int, squad: int, decision_id: String = "", option_id: String = "") -> Dictionary:
 var decision := PendingDecisions.current(s, ["unit-actions"])
 if decision.is_empty(): return {"error": "No army-preparation decision is pending."}
 var domain_choice: Dictionary = {}
 for choice: Dictionary in C.unit_choices(s, player):
  if str(choice.get("action", "")) == "reserve" and int(choice.get("target", -1)) == squad:
   domain_choice = choice
   break
 if domain_choice.is_empty(): return {"error": "This squad has no current reserve choice."}
 var projected: Dictionary = {}
 for option: Dictionary in decision.get("legal_options", []):
  if str(option.get("action", "")) == str(domain_choice.get("action", "")) and int(option.get("model", -1)) == int(domain_choice.get("model", -1)) and int(option.get("target", -1)) == int(domain_choice.get("target", -1)) and str(option.get("value", "")) == str(domain_choice.get("value", "")):
   projected = option
   break
 if projected.is_empty(): return {"error": "This squad has no projected reserve option."}
 return MatchCommandService.execute(s, player, {
  "kind": MatchCommandService.SELECT_UNIT_CHOICE,
  "choice": {
   "_decision_type": MatchCommandService.UNIT_CHOICE_ENVELOPE,
   "decision_id": decision_id if not decision_id.is_empty() else str(decision.get("decision_id", "")),
   "option_id": option_id if not option_id.is_empty() else str(projected.get("id", "")),
   "choice": domain_choice
  },
  "revision": s.revision
 })
func attack(s: Dictionary, mortal: bool) -> Dictionary:
 var weapon := {"name": "Fortitude probe", "attacks": 1, "skill": 2, "strength": 12, "ap": -6, "damage": 2, "range_inches": 24, "keywords": {"devastating-wounds": true} if mortal else {}}
 return C.AttackPlan.resolve(s, {"targets": [5], "batches": [{"target": 5, "weapon": weapon, "context": {"weapon_count": 1}}]}, six if mortal else three, false)
func _initialize() -> void: call_deferred("run")
func run() -> void:
 var s := fixture()
 check(not s.has("error"), "Terminator Chaplain admission failed: %s" % str(s.get("error", "")))
 if s.has("error"):
  print(s)
  quit(1)
  return
 var profile: Dictionary = P.profile("chaplain-in-terminator-armour")
 check(profile.source_book_id == "000000139" and profile.source_datasheet_id == "000000115" and profile.source_export_updated_at == "2026-10-16T21:03:46+03:00", "Chaplain preserves its local Wahapedia source identity")
 check(profile.models == 1 and is_equal_approx(profile.base_radius_inches, 25.0/25.4) and profile.points_by_models == {1: 75} and profile.stats == {"movement_inches": 5, "toughness": 6, "wounds": 5, "save_target": 2, "leadership_target": 5, "objective_control": 1, "invulnerable_target": 4}, "Chaplain's one-model profile, base, characteristics and price match the local export")
 check(profile.keywords == ["INFANTRY", "CHAPLAIN", "CHARACTER", "IMPERIUM", "TERMINATOR", "ADEPTUS ASTARTES"] and "DEATHWING" not in profile.keywords, "Chaplain retains unconditional keywords and excludes chapter-conditional Deathwing")
 var resolution := Army.resolve("Space Marines", "40kdc:11e:adeptus-astartes:chaplain-in-terminator-armour")
 check(resolution.get("error", "").is_empty() and int(resolution.get("cost", -1)) == 75 and resolution.get("unsupported_abilities", []).is_empty(), "Chaplain resolves from the consolidated local catalog with no blocked abilities")
 var admitted := Army.admit({"schema_version": 2, "faction": "Space Marines", "category": "incursion", "points_limit": 1000, "entries": [entry("chaplain-in-terminator-armour")]})
 check(admitted.error.is_empty() and admitted.total == 75, "Chaplain is admitted at the local 75-point cost")
 for owner in [1, 2]:
  var owner_model := model_for(s, owner, "chaplain-in-terminator-armour")
  check(owner_model >= 0 and s.units[owner_model].max_wounds == 5, "Player %d materializes the current Terminator Chaplain profile" % owner)
 for ability: String in ["leader", "deep-strike", "combat-doctrines", "litany-of-hate", "zealous-fortitude"]:
  check(C.UnitAbilities.has(s, 5, ability), "Chaplain retains source ability %s" % ability)
 var weapon_failures := WeaponChecks.fixed_weapon_plan_failures(s, profile, 100, 2)
 check(weapon_failures.is_empty(), "Storm Bolter and Crozius Arcanum pass Equipment and AttackPlan: %s" % str(weapon_failures))
 check(s.training_points[1] == 350 and s.units[100].max_wounds == 5 and is_equal_approx(s.units[100].radius, 25.0/25.4), "Terminator Chaplain stats/price/base incorrect")
 check(s.units[100].attachment_role == "leader" and C.UnitAbilities.has(s, 5, "deep-strike"), "Terminator Chaplain lost Leader/Deep Strike")
 check(not C.UnitAbilities.has(s, 5, "spiritual-leader") and "DEATHWING" not in s.units[100].keywords, "Ordinary Chaplain or chapter rules leaked")
 var sword: Dictionary = P.profile("chaplain-in-terminator-armour").melee[0].profiles.standard
 check(C.UnitAbilities.weapon(s, 500, 2, sword, true).keywords.get("lance", false) and not C.UnitAbilities.weapon(s, 500, 2, sword, false).keywords.get("lance", false), "Litany did not affect unit melee only")
 var prevented := C.Attacks.Prevention.resolve(3, 3, U.rules(s, 500), "mortal", four)
 check(prevented.error.is_empty() and prevented.lost == 0 and prevented.rolls.size() == 3, "Fortitude failed on mortal wounds")
 prevented = C.Attacks.Prevention.resolve(2, 3, U.rules(s, 500), "normal", six)
 check(prevented.lost == 2 and prevented.rolls.is_empty(), "Fortitude prevented normal wounds")
 var resolved := attack(s, true)
 check(resolved.error.is_empty() and resolved.units[500].wounds == 3, "Automatic mortal allocation missed Fortitude")
 resolved = attack(s, false)
 check(resolved.error.is_empty() and resolved.units[500].wounds == 1, "Automatic ordinary damage gained Fortitude")
 s.units[500].feel_no_pain = [{"target": 5, "against": "any"}]
 prevented = C.Attacks.Prevention.resolve(2, 3, U.rules(s, 500), "mortal", four)
 check(prevented.target == 4 and prevented.rolls.size() == 2, "Fortitude stacked rolls or ignored better protection")
 s.pending_attack = {"unit_prevention": U.snapshot(s)}
 s.units[100].wounds = 0
 check(U.rules(s, 500).size() == 2, "Effect vanished mid-attacking-unit after source loss")
 s.pending_attack = {}
 check(U.rules(s, 500).size() == 1, "Fortitude persisted after source loss and attack completion")
 s = fixture()
 s.units[100].on_battlefield = false
 check(U.rules(s, 500).is_empty(), "Off-board source granted Fortitude")
 s.units[100].on_battlefield = true
 s.unit_abilities.implementation = "historical"
 check(U.rules(s, 500).is_empty(), "Fortitude leaked to historical implementation")
 s = fixture(false)
 check(C.UnitActions.attachment_allowed(s, 100, 5) and not C.UnitActions.attachment_allowed(s, 100, 3), "Terminator/Tacticus attachment boundaries merged")
 s.phase = "deployment"
 s.unit_abilities.setup_players = []
 check(equip(s, "shield").is_empty() and s.units[100].max_wounds == 6 and s.units[100].wounds == 6 and s.units[100].ranged_weapons.is_empty(), "Relic Shield did not replace bolter and add bearer wound")
 check(s.units[100].melee_weapons.size() == 1 and C.AttackPlan.legal_targets(s, 100, false).is_empty(), "Shield removed crozius or retained shooting")
 C.UnitActions.attach(s, 100, 5)
 s.phase = "deployment"
 check(Groups.profile(s, 100).wounds_per_model == 6 and s.units[500].max_wounds == 3, "Attachment shared shield wounds")
 check(equip(s, "bolter").is_empty() and s.units[100].max_wounds == 5 and s.units[100].ranged_weapons == P.profile("chaplain-in-terminator-armour").ranged, "Shield swap not reversible after attachment")
 var reserve: Dictionary = {}
 for option: Dictionary in C.unit_choices(s, 1):
  if option.action == "reserve" and option.target == 5: reserve = option
 s.points_limit = 500
 check(s.squads[5].training_cost == 265, "Reserve cost omitted attached Character")
 var reserve_decision := PendingDecisions.current(s, ["unit-actions"])
 var reserve_projection: Dictionary = reserve_decision.legal_options.filter(func(option: Dictionary) -> bool: return str(option.get("action", "")) == "reserve" and int(option.get("target", -1)) == 5)[0]
 var before_reserve := var_to_bytes(s)
 var wrong_owner_reserve := submit_reserve(s, 2, 5)
 var stale_reserve := submit_reserve(s, 1, 5, str(reserve_decision.decision_id), "stale-option")
 check(not wrong_owner_reserve.get("error", "").is_empty() and not stale_reserve.get("error", "").is_empty() and before_reserve == var_to_bytes(s), "Wrong-owner and stale reserve declarations are rejected unchanged")
 var over_limit_reserve := submit_reserve(s, 1, 5, str(reserve_decision.decision_id), str(reserve_projection.id))
 check(not reserve.is_empty() and not over_limit_reserve.get("error", "").is_empty() and s.unit_abilities.reserves.is_empty() and before_reserve == var_to_bytes(s), "Combined reserve unit bypassed the half-points limit")
 s.points_limit = 1000
 reserve_decision = PendingDecisions.current(s, ["unit-actions"])
 reserve_projection = reserve_decision.legal_options.filter(func(option: Dictionary) -> bool: return str(option.get("action", "")) == "reserve" and int(option.get("target", -1)) == 5)[0]
 var combined_reserve := submit_reserve(s, 1, 5, str(reserve_decision.decision_id), str(reserve_projection.id))
 check(combined_reserve.get("error", "").is_empty() and s.unit_abilities.reserves[5].cost == 265, "Public command admits legal combined reserve cost: %s" % str(combined_reserve))
 s = fixture(false)
 s.phase = "deployment"
 s.unit_abilities.setup_players = []
 reserve = {}
 for option: Dictionary in C.unit_choices(s, 1):
  if option.action == "reserve" and option.target == 1: reserve = option
 var standalone_reserve := submit_reserve(s, 1, 1)
 check(not reserve.is_empty() and standalone_reserve.get("error", "").is_empty() and not s.units[100].on_battlefield, "Public command permits standalone Chaplain Deep Strike reserves")
 s = fixture()
 var probe := {"name": "Manual Fortitude probe", "attacks": 1, "skill": 2, "strength": 12, "ap": -6, "damage": 2, "range_inches": 24, "keywords": {"devastating-wounds": true}}
 C.Allocation.start(s, {"targets": [5], "batches": [{"target": 5, "weapon": probe, "context": {"weapon_count": 1}}]}, 2, 2, [], false, false, false)
 var waiting := C.Allocation.pump(s, six)
 check(waiting.error.is_empty() and not waiting.complete and 500 in C.Allocation.eligible(s), "Manual allocation did not wait for recipient")
 check(C.Allocation.apply(s, 500, six).error.is_empty() and s.units[500].wounds == 3, "Manual mortal allocation missed Fortitude")
 s = fixture()
 s.phase = "movement"
 s.pending_move = {"squad": 5, "move_type": "desperate_escape", "origins": {}, "prior_flags": {}, "spent": {}, "bonus": 0, "hazard_remaining": 1, "hazard_rolls": [1], "locked": true}
 var movement_frame := ResolutionFrames.begin(s, "unit-action", "movement:%d:5:movement" % int(s.turn), "escape-wound-allocation")
 check(not movement_frame.is_empty() and ResolutionFrames.suspend(s, str(movement_frame.get("frame_id", "")), "escape-wound-allocation").is_empty(), "Escape allocation fixture retains its pending Movement continuation")
 var escape_decision := PendingDecisions.current(s, ["escape-wounds"])
 var escape_option: Dictionary = escape_decision.legal_options.filter(func(option: Dictionary) -> bool: return int(option.get("model", -1)) == 500)[0]
 var escape_allocation := MatchCommandService.execute(s, 1, {"kind": MatchCommandService.ALLOCATE_ESCAPE_WOUND, "choice": {"_decision_type": MatchCommandService.ESCAPE_WOUND_DECISION_ENVELOPE, "decision_id": str(escape_decision.decision_id), "option_id": str(escape_option.id), "choice": {"model": 500}}, "revision": s.revision}, six)
 check(escape_allocation.get("error", "").is_empty() and s.units[500].wounds == 3 and s.last_escape_prevention.prevented == 1, "Public Desperate Escape allocation applies Terminator Chaplain Fortitude")
 s = fixture()
 s.units[500].feel_no_pain = "invalid"
 check(not C.Attacks.Prevention.validate(U.rules(s, 500)).is_empty(), "Unit grant hid invalid personal prevention")
 check(not C.UnitActions.attachment_allowed(s, 100, 5), "Reserved Character created orphan reserve through late attachment")
 print("Terminator Chaplain checks: %d failures" % failures)
 quit(0 if failures == 0 else 1)
