extends SceneTree
const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const P = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const S = preload("res://scripts/edition_11/support_attachments.gd")
const MatchCommands = preload("res://scripts/edition_11/match_command_service.gd")
const PendingDecisions = preload("res://scripts/edition_11/pending_decision_registry.gd")
const Equipment = preload("res://scripts/edition_11/equipment.gd")
const Army = preload("res://scripts/edition_11/army_capabilities.gd")
const ChapterRules = preload("res://scripts/edition_11/chapter_rules.gd")
const ANCIENT_ID := "40kdc:11e:adeptus-astartes:ancient"
const BLADEGUARD_ANCIENT_ID := "40kdc:11e:adeptus-astartes:bladeguard-ancient"
const WEAPON_PROFILES := {
 "bolt-pistol:standard": {"melee": false, "range_inches": 12.0, "attacks": 1, "skill": 3, "strength": 5, "ap": -1, "damage": 1, "keywords": {"close-quarters": true}},
 "bolt-rifle:focused": {"melee": false, "range_inches": 24.0, "attacks": 1, "skill": 3, "strength": 6, "ap": -1, "damage": 2, "keywords": {"heavy": true, "rapid-fire": 1}},
 "bolt-rifle:saturation": {"melee": false, "range_inches": 24.0, "attacks": 2, "skill": 3, "strength": 5, "ap": -1, "damage": 1, "keywords": {"assault": true, "rapid-fire": 1}},
 "ceramite-fists:standard": {"melee": true, "range_inches": 0.0, "attacks": 4, "skill": 3, "strength": 5, "ap": 0, "damage": 1, "keywords": {}},
 "power-weapon:standard": {"melee": true, "range_inches": 0.0, "attacks": 5, "skill": 3, "strength": 5, "ap": -2, "damage": 1, "keywords": {}},
 "heavy-bolt-pistol:standard": {"melee": false, "range_inches": 18.0, "attacks": 1, "skill": 3, "strength": 5, "ap": -1, "damage": 1, "keywords": {"close-quarters": true}},
 "relics-of-battle:standard": {"melee": true, "range_inches": 0.0, "attacks": 4, "skill": 3, "strength": 5, "ap": -2, "damage": 2, "keywords": {}}
}
var failures := 0
func check(ok: bool, message: String) -> void:
 if not ok:
  push_error(message)
  failures += 1
func six() -> int: return 6
func submit_projected_choice(s: Dictionary, player: int, selected: Dictionary, decision_id: String = "", option_id: String = "") -> Dictionary:
 var decision := C.UnitActions.pending_decision(s)
 if decision.is_empty() or int(decision.get("priority_player_id", -1)) != player: return {"error": "No matching UnitActions decision for Player %d." % player}
 var projected: Dictionary = {}
 for option: Dictionary in decision.get("legal_options", []):
  if str(option.get("action", "")) == str(selected.get("action", "")) and int(option.get("model", -1)) == int(selected.get("model", -1)) and int(option.get("target", -1)) == int(selected.get("target", -1)) and str(option.get("value", "")) == str(selected.get("value", "")): projected = option; break
 if projected.is_empty(): return {"error": "Selected choice is absent from the current decision."}
 var choice := {"_decision_type": MatchCommands.UNIT_CHOICE_ENVELOPE, "decision_id": decision_id if not decision_id.is_empty() else str(decision.get("decision_id", "")), "option_id": option_id if not option_id.is_empty() else str(projected.get("id", "")), "choice": selected}
 return MatchCommands.execute(s, player, {"kind": MatchCommands.SELECT_UNIT_CHOICE, "choice": choice, "revision": int(s.revision)})
func entry(name: String, models: int = 1, copies: int = 1) -> Dictionary:
 return {"definition_id": "40kdc:11e:adeptus-astartes:" + name, "models": models, "copies": copies}
func check_weapon_profile(s: Dictionary, squad: int, model: int, target_squad: int, weapon_id: String, profile_id: String) -> void:
 var expected: Dictionary = WEAPON_PROFILES[weapon_id + ":" + profile_id]
 var selected := Equipment.select(s, model, bool(expected.melee), weapon_id, profile_id)
 check(str(selected.get("error", "")).is_empty(), "%s/%s is selectable through Equipment" % [weapon_id, profile_id])
 if not str(selected.get("error", "")).is_empty(): return
 for field: String in ["range_inches", "attacks", "skill", "strength", "ap", "damage"]:
  check(selected.stats.get(field) == expected[field], "%s/%s %s matches the verified source" % [weapon_id, profile_id, field])
 check(selected.stats.get("keywords", {}) == expected.keywords, "%s/%s preserves every source weapon trait" % [weapon_id, profile_id])
 var prior_phase: String = str(s.phase)
 var prior_active: int = int(s.active)
 var attacker_models: Array[int] = C.living(s, squad)
 var targets: Array[int] = C.living(s, target_squad)
 if targets.is_empty():
  check(false, "AttackPlan target squad has a living model")
  return
 var old_positions := {}
 for member: int in attacker_models + targets: old_positions[member] = s.units[member].position
 for index in range(attacker_models.size()):
  var member: int = attacker_models[index]
  s.units[member].position = Vector2.ZERO if member == model else Vector2(-10, 4 + index * 3)
 var first_target: int = targets[0]
 for index in range(targets.size()):
  var member: int = targets[index]
  s.units[member].position = Vector2(1, 0) if bool(expected.melee) and member == first_target else Vector2(4, 0) if member == first_target else Vector2(10, 4 + index * 3)
 s.phase = "fight" if bool(expected.melee) else "shooting"
 s.active = int(s.squads[squad].owner)
 var amount := int(selected.stats.attacks) if bool(expected.melee) else 1
 var plan: Dictionary = C.AttackPlan.prepare(s, squad, bool(expected.melee), [{"model": model, "target": target_squad, "amount": amount, "weapon": weapon_id, "profile": profile_id}], false)
 s.phase = prior_phase
 s.active = prior_active
 for member: int in old_positions: s.units[member].position = old_positions[member]
 check(str(plan.get("error", "")).is_empty() and plan.get("batches", []).size() == 1, "%s/%s routes through AttackPlan: %s" % [weapon_id, profile_id, plan.get("error", "")])
 if plan.get("error", "").is_empty() and plan.get("batches", []).size() == 1:
  var sources: Array = plan.batches[0].context.get("attack_sources", [])
  check(not sources.is_empty() and str(sources[0].get("weapon", "")) == weapon_id, "AttackPlan preserves %s/%s as the attack source: %s" % [weapon_id, profile_id, str(sources)])
func fixture(attach: bool = true) -> Dictionary:
 var lists := F.current_marine_selections()
 lists[1].entries = [entry("ancient"), entry("bladeguard-ancient"), entry("bladeguard-veteran-squad", 3), entry("captain"), entry("intercessor-squad", 5)]
 var s := F.P.initial_state({"unit_abilities": true, "combat_doctrines": true, "reanimation_protocols": true, "awakened_dynasty": true, "core_stratagems": true, "manual_allocation": false}, lists)
 if s.has("error"): return s
 if attach:
  C.UnitActions.attach(s, 100, 9)
  C.UnitActions.attach(s, 300, 5)
 s.awakened_dynasty.pending = []
 s.mission.stage = "battle"
 s.phase = "movement"
 s.turn = 3
 s.round = 2
 s.active = 1
 s.unit_abilities.setup_players = [1, 2]
 s.unit_abilities.battle_players = [1, 2]
 s.unit_abilities.window = {}
 s.unit_abilities.phase_key = C.UnitActions.key(s)
 s.terrain.areas = []
 s.cp = {1: 0, 2: 0}
 s.mission.objectives = [{"name": "Banner test", "kind": "marker", "position": Vector2(0, -8), "controller": 0, "secured": 0, "levels": {1: 0, 2: 0}}]
 for model: int in s.units:
  s.units[model].on_battlefield = true
  s.units[model].position = Vector2(-18, 16) if s.units[model].owner == 1 else Vector2(18, 16)
 for model: int in [900, 901, 902, 903, 904, 100]:
  s.units[model].position = Vector2(0, -8)
 return s
func _initialize() -> void: call_deferred("run")
func run() -> void:
 var ancient_profile: Dictionary = P.profile("ancient")
 var bladeguard_profile: Dictionary = P.profile("bladeguard-ancient")
 check(ancient_profile.get("source_book_id", "") == "000000139" and ancient_profile.get("source_datasheet_id", "") == "000002775" and ancient_profile.get("source_export_updated_at", "") == "2026-10-16T21:03:46+03:00", "Ancient identity maps to the source sheet and retains its local export stamp")
 check(bladeguard_profile.get("source_book_id", "") == "000000139" and bladeguard_profile.get("source_datasheet_id", "") == "000001165" and bladeguard_profile.get("source_export_updated_at", "") == "2026-10-16T21:03:46+03:00", "Bladeguard Ancient identity maps to the source sheet and retains its local export stamp")
 check(ancient_profile.get("points_by_models", {}) == {1: 40} and is_equal_approx(ancient_profile.get("base_radius_inches", 0.0), 20.0 / 25.4) and ancient_profile.get("stats", {}) == {"movement_inches": 6, "toughness": 5, "save_target": 3, "wounds": 4, "leadership_target": 6, "objective_control": 2, "invulnerable_target": 0}, "Ancient composition, cost, 40 mm base and characteristics match the snapshot")
 check(bladeguard_profile.get("points_by_models", {}) == {1: 70} and is_equal_approx(bladeguard_profile.get("base_radius_inches", 0.0), 20.0 / 25.4) and bladeguard_profile.get("stats", {}) == {"movement_inches": 6, "toughness": 5, "save_target": 3, "wounds": 4, "leadership_target": 6, "objective_control": 3, "invulnerable_target": 4}, "Bladeguard Ancient composition, cost, 40 mm base and characteristics match the snapshot")
 var ancient_keywords := ["ADEPTUS ASTARTES", "CHARACTER", "EXPLOSIVES", "IMPERIUM", "INFANTRY", "TACTICUS"]
 var actual_ancient_keywords: Array = ancient_profile.get("keywords", []).duplicate()
 actual_ancient_keywords.sort()
 check(actual_ancient_keywords == ancient_keywords, "Ancient retains its six unconditional source keywords")
 var bladeguard_keywords := ["ADEPTUS ASTARTES", "ANCIENT", "CHARACTER", "EXPLOSIVES", "IMPERIUM", "INFANTRY", "TACTICUS"]
 var actual_bladeguard_keywords: Array = bladeguard_profile.get("keywords", []).duplicate()
 actual_bladeguard_keywords.sort()
 check(actual_bladeguard_keywords == bladeguard_keywords, "Bladeguard Ancient retains its unconditional source keywords and resolves Deathwing by Chapter context")
 check(ancient_profile.get("ranged", []).size() == 2 and ancient_profile.ranged[0].id == "bolt-rifle" and ancient_profile.ranged[1].id == "bolt-pistol" and ancient_profile.get("melee", []).size() == 1 and ancient_profile.melee[0].id == "ceramite-fists", "Ancient default loadout contains its Bolt Rifle, Bolt Pistol and Ceramite Fists")
 check(bladeguard_profile.get("ranged", []).size() == 1 and bladeguard_profile.ranged[0].id == "heavy-bolt-pistol" and bladeguard_profile.get("melee", []).size() == 1 and bladeguard_profile.melee[0].id == "relics-of-battle", "Bladeguard Ancient fixed loadout matches the source")
 var ancient_choice := Army.current_catalog_choice({"id": ANCIENT_ID, "edition": "11e", "faction": "Space Marines"})
 var bladeguard_choice := Army.current_catalog_choice({"id": BLADEGUARD_ANCIENT_ID, "edition": "11e", "faction": "Space Marines"})
 var ancient_admission := Army.admit({"schema_version": 2, "faction": "Space Marines", "category": "incursion", "points_limit": 1000, "entries": [entry("ancient")]})
 var bladeguard_admission := Army.admit({"schema_version": 2, "faction": "Space Marines", "category": "incursion", "points_limit": 1000, "entries": [entry("bladeguard-ancient")]})
 check(Army.SPECS["ancient"].get("current_reference", false) and Army.SPECS["ancient"].get("validation_status", "") == "tests_passed_local_targeted" and ancient_choice.get("options", []) == [{"models": 1, "cost": 40}] and ancient_admission.get("error", "").is_empty() and ancient_admission.get("total", -1) == 40, "Current construction offers and admits the one-model Ancient at 40 points")
 check(Army.SPECS["bladeguard-ancient"].get("current_reference", false) and Army.SPECS["bladeguard-ancient"].get("validation_status", "") == "tests_passed_local_targeted" and bladeguard_choice.get("options", []) == [{"models": 1, "cost": 70}] and bladeguard_admission.get("error", "").is_empty() and bladeguard_admission.get("total", -1) == 70, "Current construction offers and admits the one-model Bladeguard Ancient at 70 points")
 var ancient_supports := S.links("ancient").duplicate()
 var bladeguard_supports := S.links("bladeguard-ancient").duplicate()
 ancient_supports.sort()
 bladeguard_supports.sort()
 check(ancient_supports == ["assault-intercessor-squad", "crusader-squad", "deathwatch-veterans", "decimus-kill-team", "desolation-squad", "fortis-kill-team", "hellblaster-squad", "infernus-squad", "inner-circle-companions", "intercessor-squad", "sternguard-veteran-squad", "sword-brethren-squad"] and bladeguard_supports == ["bladeguard-veteran-squad"], "Ancient Support targets mismatch: %s / %s" % [str(ancient_supports), str(bladeguard_supports)])
 var s := fixture()
 check(not s.has("error"), "Ancients admission failed")
 if s.has("error"):
  print(s)
  quit(1)
  return
 check(s.training_points[1] == 375 and s.units[100].max_wounds == 4 and s.units[300].max_wounds == 4, "Ancient prices/compositions incorrect")
 check(C.UnitAbilities.identity(s.units[100]) == "ancient" and C.UnitAbilities.identity(s.units[300]) == "bladeguard-ancient" and C.UnitAbilities.identity(s.units[200]) == "intercessor-squad", "Both Supports and their opposing bodyguard unit materialize from the current Marine catalog")
 check(s.units[100].ranged_weapons.size() == 2 and s.units[100].ranged_weapons.any(func(w: Dictionary) -> bool: return w.id == "bolt-pistol") and s.units[100].ranged_weapons.any(func(w: Dictionary) -> bool: return w.id == "bolt-rifle") and s.units[100].melee_weapons.size() == 1 and s.units[100].melee_weapons[0].id == "ceramite-fists", "Materialized Ancient starts with the exact source weapons")
 check(s.units[300].ranged_weapons.size() == 1 and s.units[300].ranged_weapons[0].id == "heavy-bolt-pistol" and s.units[300].melee_weapons.size() == 1 and s.units[300].melee_weapons[0].id == "relics-of-battle", "Materialized Bladeguard Ancient starts with the exact source weapons")
 check(C.UnitAbilities.has(s, 9, "raise-the-banner") and C.UnitAbilities.has(s, 9, "honour-of-the-company") and C.UnitAbilities.has(s, 5, "raise-the-banner") and C.UnitAbilities.has(s, 5, "deeds-of-legend"), "The two source-specific Ancient ability sets are admitted")
 check_weapon_profile(s, 9, 100, 2, "bolt-pistol", "standard")
 check_weapon_profile(s, 9, 100, 2, "bolt-rifle", "focused")
 check_weapon_profile(s, 9, 100, 2, "bolt-rifle", "saturation")
 check_weapon_profile(s, 9, 100, 2, "ceramite-fists", "standard")
 check_weapon_profile(s, 5, 300, 2, "heavy-bolt-pistol", "standard")
 check_weapon_profile(s, 5, 300, 2, "relics-of-battle", "standard")
 var dark_angels_state: Dictionary = s.duplicate(true)
 var dark_angels_context := ChapterRules.resolve_and_apply(dark_angels_state, {1: "none", 2: "none"}, {1: "DARK ANGELS"})
 check(dark_angels_context.get("error", "").is_empty() and "DEATHWING" in dark_angels_state.units[300].keywords and "DEATHWING" not in s.units[300].keywords, "The source Deathwing keyword is granted only in the Dark Angels Chapter context")
 check(s.units[100].objective_control == 2 and s.units[300].objective_control == 3 and C.Morale.objective_control(s, 100) == 3 and C.Morale.objective_control(s, 900) == 3, "Honour of Company did not modify every model or corrupted base OC")
 check(C.Morale.objective_control(s, 300) == 3 and C.Morale.objective_control(s, 500) == 1, "Bladeguard Ancient gained ordinary Ancient OC aura")
 check(s.units[100].attachment_role == "support" and s.units[300].attachment_role == "support", "Ancients consumed Leader slots")
 check("DEATHWING" not in s.units[300].keywords and "ANCIENT" in s.units[300].keywords and "ANCIENT" not in s.units[100].keywords, "Ancient keyword/source boundaries merged")
 s.squads[9].battle_shocked = true
 check(C.Morale.objective_control(s, 900) == 0 and C.Morale.objective_control(s, 100) == 0, "OC bonus bypassed Battle-shock")
 s.squads[9].battle_shocked = false
 s.units[100].on_battlefield = false
 check(C.Morale.objective_control(s, 900) == 2, "Off-board Ancient conferred OC")
 s.units[100].on_battlefield = true
 s.units[100].wounds = 0
 check(C.Morale.objective_control(s, 900) == 2, "Dead Ancient conferred OC")
 s = fixture()
 check(s.mission.objectives[0].secured == 0 and C.advance_phase(s, 1, s.revision, six).is_empty() and s.mission.objectives[0].secured == 1, "Raise the Banner did not secure at end of own Movement")
 for model: int in s.units:
  if s.units[model].owner == 1: s.units[model].position = Vector2(-18, 16)
 C.Objectives.resolve_control(s, Callable(C.Morale, "objective_control"))
 check(s.mission.objectives[0].controller == 1 and s.mission.objectives[0].secured == 1, "Banner security vanished when unit left")
 s.units[200].position = Vector2(0, -8)
 C.Objectives.resolve_control(s, Callable(C.Morale, "objective_control"))
 check(s.mission.objectives[0].controller == 2 and s.mission.objectives[0].secured == 0, "Banner prevented later enemy capture")
 s = fixture()
 s.units[100].wounds = 0
 s.units[500].position = Vector2(0, -8)
 check(C.advance_phase(s, 1, s.revision, six).is_empty() and s.mission.objectives[0].secured == 1, "Bladeguard Ancient did not confer Raise the Banner through its bodyguard")
 for variant: String in ["enemy-turn", "shooting", "dead", "shocked", "tie"]:
  s = fixture()
  if variant == "enemy-turn": s.active = 2
  if variant == "shooting": s.phase = "shooting"
  if variant == "dead": s.units[100].wounds = 0
  if variant == "shocked": s.squads[9].battle_shocked = true
  if variant == "tie":
   s.units[200].position = Vector2(0, -8)
   s.units[200].objective_control = 18
  s.unit_abilities.phase_key = C.UnitActions.key(s)
  check(C.advance_phase(s, C.actor(s), s.revision, six).is_empty() and s.mission.objectives[0].secured == 0, "Banner triggered incorrectly: " + variant)
 s = fixture()
 var sword: Dictionary = P.profile("bladeguard-veteran-squad").melee[0].profiles.standard
 check(C.UnitAbilities.weapon(s, 500, 2, sword, true).attacks == 4, "Deeds active outside objective range")
 s.units[500].position = Vector2(0, -8)
 check(C.UnitAbilities.weapon(s, 500, 2, sword, true).attacks == 5 and sword.attacks == 4 and C.UnitAbilities.melee_attack_count(s, 300, P.profile("bladeguard-ancient").melee[0].profiles.standard) == 5, "Deeds missed attached unit or mutated source")
 var pistol: Dictionary = P.profile("bladeguard-ancient").ranged[0].profiles.standard
 check(C.UnitAbilities.weapon(s, 300, 2, pistol, false).attacks == 1, "Deeds modified ranged attacks")
 s.units[501].position = Vector2(0, -6)
 s.units[502].position = Vector2(0, -4)
 s.units[300].position = Vector2(0, -10)
 for model: int in C.living(s, 2): s.units[model].position = Vector2(2, -8)
 for model: int in C.living(s, 4): s.units[model].position = Vector2(2, -6)
 var plan := [{"model": 500, "target": 2, "amount": 2}, {"model": 500, "target": 4, "amount": 3}, {"model": 501, "target": 4, "amount": 5}, {"model": 502, "target": 4, "amount": 5}, {"model": 300, "target": 2, "amount": 5}]
 var prepared := C.AttackPlan.prepare(s, 5, true, plan, true)
 check(prepared.error.is_empty(), "Deeds split plan rejected")
 if prepared.error.is_empty():
  var attacks := 0
  for batch: Dictionary in prepared.batches: attacks += int(batch.weapon.attacks)
  check(attacks == 20, "Deeds extra attack duplicated per split target")
 var defaults := C.AttackPlan.single_target(s, 5, 2, true)
 for row: Dictionary in defaults: check(row.amount == 5, "Default plan omitted modified melee A")
 s.units[300].wounds = 0
 check(C.UnitAbilities.weapon(s, 500, 2, sword, true).attacks == 4 and not C.AttackPlan.prepare(s, 5, true, plan, true).error.is_empty(), "Dead Bladeguard Ancient retained Deeds")
 # Augmenting matches must reserve restricted slots without depending on entry order.
 var legal := [entry("lieutenant"), entry("ancient"), entry("bladeguard-ancient"), entry("bladeguard-veteran-squad", 3), entry("hellblaster-squad", 5), entry("intercessor-squad", 5)]
 check(S.matching_error(legal).is_empty(), "Legal mixed Supports rejected")
 legal.reverse()
 check(S.matching_error(legal).is_empty(), "Support matching depends on entry order")
 check(not S.matching_error([entry("ancient"), entry("bladeguard-ancient"), entry("intercessor-squad", 5, 2)]).is_empty(), "Bladeguard Ancient admitted without Bladeguards")
 check(not S.matching_error([entry("ancient"), entry("judiciar"), entry("bladeguard-veteran-squad", 3, 2)]).is_empty(), "Ordinary Ancient admitted into Bladeguards")
 check(not S.matching_error([entry("bladeguard-ancient"), entry("judiciar"), entry("bladeguard-veteran-squad", 3)]).is_empty(), "Two Supports shared one slot")
 s = fixture(false)
 s.phase = "deployment"
 s.unit_abilities.setup_players = []
 for mode: String in ["power", "rifle"]:
  var option: Dictionary = {}
  for row: Dictionary in C.unit_choices(s, 1):
   if row.action == "ancient-loadout" and row.model == 100 and row.value == mode: option = row
  var decision := PendingDecisions.current(s, ["unit-actions"])
  var projected: Dictionary = decision.get("legal_options", []).filter(func(candidate: Dictionary) -> bool: return str(candidate.get("action", "")) == "ancient-loadout" and int(candidate.get("model", -1)) == 100 and str(candidate.get("value", "")) == mode)[0]
  var before_choice := var_to_bytes(s)
  var wrong_owner := submit_projected_choice(s, 2, option)
  var stale_option := submit_projected_choice(s, 1, option, str(decision.get("decision_id", "")), "stale-option")
  check(not wrong_owner.get("error", "").is_empty() and not stale_option.get("error", "").is_empty() and before_choice == var_to_bytes(s), "Wrong-owner and stale Ancient loadout choices are rejected unchanged")
  var loadout_result := submit_projected_choice(s, 1, option, str(decision.get("decision_id", "")), str(projected.get("id", "")))
  check(not option.is_empty() and loadout_result.get("error", "").is_empty(), "Ancient equipment swap uses the public preparation command: " + mode)
  check(s.units[100].ranged_weapons == P.ancient_weapons(mode == "power").ranged and s.units[100].melee_weapons == P.ancient_weapons(mode == "power").melee, "Ancient replacement removed fists/pistol or retained rifle")
  if mode == "power": check_weapon_profile(s, int(s.units[100].squad), 100, 2, "power-weapon", "standard")
 # Public preparation exposes both support declarations and preserves Leader vacancy.
 for model: int in [100, 300]:
  var option: Dictionary = {}
  for row: Dictionary in C.unit_choices(s, 1):
   if row.action == "attach" and row.model == model and row.target == (9 if model == 100 else 5): option = row
  var before := var_to_bytes(s)
  var wrong_owner := submit_projected_choice(s, 2, option)
  check(not option.is_empty() and not str(wrong_owner.get("error", "")).is_empty() and var_to_bytes(s) == before, "Opponent attached an Ancient")
  var attachment := submit_projected_choice(s, 1, option)
  check(str(attachment.get("error", "")).is_empty() and s.units[model].attachment_role == "support", "Ancient attachment uses the normalized command")
 check(C.UnitActions.attachment_allowed(s, 700, 5), "Ancient occupied the separate Captain Leader slot")
 s.unit_abilities.implementation = "historical"
 check(C.Morale.objective_control(s, 900) == 2, "Ancient OC leaked into historical ability implementation")
 print("Ancients checks: %d failures" % failures)
 quit(0 if failures == 0 else 1)
