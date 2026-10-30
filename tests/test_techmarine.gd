extends SceneTree
const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Catalog = preload("res://scripts/edition_11/army_capabilities.gd")
const AbilityCatalog = preload("res://scripts/edition_11/unit_ability_catalog.gd")
const Equipment = preload("res://scripts/edition_11/equipment.gd")
const Tech = preload("res://scripts/edition_11/techmarine.gd")
const MatchCommands = preload("res://scripts/edition_11/match_command_service.gd")
const PendingDecisions = preload("res://scripts/edition_11/pending_decision_registry.gd")
const TECHMARINE_ID := "40kdc:11e:adeptus-astartes:techmarine"
const BALLISTUS_ID := "40kdc:11e:adeptus-astartes:ballistus-dreadnought"
const INTERCESSOR_ID := "40kdc:11e:adeptus-astartes:intercessor-squad"
const WEAPONS := [
 {"id": "forge-bolter", "profile": "standard", "melee": false, "name": "Forge Bolter", "range_inches": 24.0, "attacks": 3, "skill": 2, "strength": 5, "ap": -1, "damage": 2, "keywords": {"sustained-hits": 1}},
 {"id": "grav-pistol", "profile": "standard", "melee": false, "name": "Grav-pistol", "range_inches": 12.0, "attacks": 2, "skill": 2, "strength": 2, "ap": -1, "damage": 3, "keywords": {"anti-vehicle": 2, "close-quarters": true}},
 {"id": "omnissian-power-axe-and-servo-arm", "profile": "standard", "melee": true, "name": "Omnissian Power Axe and Servo-arm", "range_inches": 0.0, "attacks": 5, "skill": 3, "strength": 6, "ap": -2, "damage": 2, "keywords": {}}
]
var failures := 0
func check(ok: bool, message: String) -> void:
 if not ok:
  push_error(message)
  failures += 1
func six() -> int: return 6
func entry(name: String, models: int = 1) -> Dictionary:
 return {"definition_id": "40kdc:11e:adeptus-astartes:" + name, "models": models, "copies": 1}
func fixture() -> Dictionary:
 var lists := F.current_marine_selections()
 lists[1].entries = [entry("techmarine"), entry("ballistus-dreadnought"), entry("intercessor-squad", 5)]
 lists[2].entries = [entry("intercessor-squad", 5), entry("redemptor-dreadnought")]
 var state := F.P.initial_state({"unit_abilities": true, "combat_doctrines": true, "reanimation_protocols": true, "awakened_dynasty": true, "core_stratagems": true, "manual_allocation": false}, lists)
 if state.has("error"): return state
 for model: int in state.units:
  state.units[model].on_battlefield = true
  state.units[model].position = Vector2(-18, 16) if state.units[model].owner == 1 else Vector2(18, 16)
 state.phase = "movement"
 state.turn = 3
 state.round = 2
 state.active = 1
 state.unit_abilities.window = {}
 state.unit_abilities.setup_players = [1, 2]
 state.unit_abilities.battle_players = [1, 2]
 state.combat_doctrines.selected_turn[1] = 3
 state.awakened_dynasty.pending = []
 return state
func find(state: Dictionary, identity: String, owner: int = 1) -> int:
 for model: int in state.units:
  if int(state.units[model].get("owner", -1)) == owner and Tech.identity(state.units[model]) == identity: return model
 return -1
func select(state: Dictionary, action: String) -> Dictionary:
 for option: Dictionary in C.unit_choices(state, 1):
  if option.action == action: return option
 return {}
func submit_choice(state: Dictionary, player: int, selected: Dictionary, roller: Callable = Callable()) -> Dictionary:
 var decision := PendingDecisions.current(state, ["unit-actions"])
 var payload: Dictionary = selected
 if not decision.is_empty():
  var projected: Dictionary = {}
  for option: Dictionary in decision.get("legal_options", []):
   if str(option.get("action", "")) == str(selected.get("action", "")) and int(option.get("model", -1)) == int(selected.get("model", -1)) and int(option.get("target", -1)) == int(selected.get("target", -1)) and str(option.get("value", "")) == str(selected.get("value", "")):
    projected = option
    break
  if projected.is_empty(): return {"error": "The current decision does not project the submitted Techmarine choice."}
  payload = {"_decision_type": MatchCommands.UNIT_CHOICE_ENVELOPE, "decision_id": str(decision.get("decision_id", "")), "option_id": str(projected.get("id", "")), "choice": selected}
 return MatchCommands.execute(state, player, {"kind": MatchCommands.SELECT_UNIT_CHOICE, "revision": int(state.revision), "choice": payload}, roller)

func weapon_plan(state: Dictionary, squad: int, model: int, target: int, expected: Dictionary) -> Dictionary:
 var previous_phase := str(state.phase)
 var previous_active := int(state.active)
 var previous_positions := {}
 for member: int in C.living(state, squad) + C.living(state, target): previous_positions[member] = state.units[member].position
 state.phase = "fight" if bool(expected.melee) else "shooting"
 state.active = int(state.squads[squad].owner)
 state.units[model].position = Vector2.ZERO
 for target_model: int in C.living(state, target):
  var base_edge_distance := 0.9 if bool(expected.melee) or expected.keywords.has("close-quarters") else 6.0
  var center_distance := float(state.units[model].radius) + float(state.units[target_model].radius) + base_edge_distance
  state.units[target_model].position = Vector2(center_distance, 0)
 var result := C.AttackPlan.prepare(state, squad, bool(expected.melee), [{
  "model": model, "target": target, "amount": int(expected.attacks) if bool(expected.melee) else 1,
  "weapon": str(expected.id), "profile": str(expected.profile)
 }], true)
 state.phase = previous_phase
 state.active = previous_active
 for member: int in previous_positions: state.units[member].position = previous_positions[member]
 return result

func check_weapon(state: Dictionary, squad: int, model: int, target: int, expected: Dictionary) -> void:
 var selected := Equipment.select(state, model, bool(expected.melee), str(expected.id), str(expected.profile))
 check(str(selected.get("error", "")).is_empty(), "%s is selectable through Equipment" % expected.id)
 if not str(selected.get("error", "")).is_empty(): return
 for field: String in ["name", "range_inches", "attacks", "skill", "strength", "ap", "damage", "keywords"]:
  check(selected.stats.get(field) == expected[field], "%s %s matches the local export" % [expected.id, field])
 var plan := weapon_plan(state, squad, model, target, expected)
 check(str(plan.get("error", "")).is_empty() and plan.get("batches", []).size() == 1,
  "%s enters AttackPlan: %s" % [expected.id, plan.get("error", "")])
 if str(plan.get("error", "")).is_empty() and plan.get("batches", []).size() == 1:
  var planned: Dictionary = plan.batches[0].weapon
  var planned_keywords: Dictionary = expected.keywords.duplicate(true)
  planned_keywords.erase("close-quarters")
  check(planned.get("name") == expected.name and planned.get("strength") == expected.strength
   and planned.get("ap") == expected.ap and planned.get("damage") == expected.damage and planned.get("keywords", {}) == planned_keywords,
   "%s preserves its source name and weapon traits in AttackPlan (name=%s traits=%s expected=%s)" % [expected.id, str(planned.get("name", "")), var_to_str(planned.get("keywords", {})), var_to_str(expected.keywords)])
func _initialize() -> void: call_deferred("run")
func run() -> void:
 var profile := Profiles.profile("techmarine")
 check(profile.source_book_id == "000000139" and profile.source_datasheet_id == "000000140" and profile.source_export_updated_at == "2026-10-16T21:03:46+03:00", "Techmarine cites the local Space Marines 11e export")
 check(profile.points == 55 and profile.points_by_models == {1: 55} and profile.models == 1 and is_equal_approx(profile.base_radius_inches, 20.0 / 25.4), "Techmarine cost, one-model composition and 40 mm base match the local export")
 check(profile.stats == {"movement_inches": 6, "toughness": 5, "save_target": 2, "wounds": 4, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 0}, "Techmarine characteristics match the local export")
 check(profile.keywords == ["INFANTRY", "CHARACTER", "TACTICUS", "EXPLOSIVES", "IMPERIUM", "ADEPTUS ASTARTES"], "Techmarine preserves all exported keywords")
 check(profile.ranged.size() == 2 and profile.melee.size() == 1 and profile.get("additional_weapon_profiles", {}).is_empty(), "The fixed sheet has two ranged weapons, one melee weapon and no equipment options")
 check(AbilityCatalog.RULES.get("techmarine", []) == ["leader", "techmarine-lone-operative", "blessings-of-the-omnissiah"], "All source-linked Techmarine abilities are registered")
 check(Catalog.current_catalog_choice({"id": TECHMARINE_ID, "edition": "11e", "faction": "Space Marines"}).get("options", []) == [{"models": 1, "cost": 55}], "Current construction exposes the source's fixed Techmarine composition and cost")
 var s := fixture()
 check(not s.has("error"), "Techmarine fixture could not be admitted")
 if s.has("error"):
  print(s)
  quit(1)
  return
 var tech := find(s, "techmarine")
 var tank := find(s, "ballistus-dreadnought")
 check(tech > 0 and tank > 0, "Techmarine or Astartes Vehicle absent")
 check(C.UnitAbilities.has(s, int(s.units[tech].squad), "leader") and C.UnitAbilities.has(s, int(s.units[tech].squad), "techmarine-lone-operative") and C.UnitAbilities.has(s, int(s.units[tech].squad), "blessings-of-the-omnissiah"), "The current-catalog Techmarine materializes its Leader and both datasheet abilities")
 var enemy_intercessor := find(s, "intercessor-squad", 2)
 check(enemy_intercessor > 0, "The second current Marine catalog provides the opposing target squad")
 if enemy_intercessor > 0:
  for expected: Dictionary in WEAPONS: check_weapon(s, int(s.units[tech].squad), tech, int(s.units[enemy_intercessor].squad), expected)
 s.units[tech].position = Vector2(0, 0)
 s.units[tank].position = Vector2(2.5, 0)
 check(C.UnitAbilities.lone_operative_active(s, tech), "Techmarine did not gain Lone Operative within 3 inches of friendly Vehicle")
 var enemy_shooter := find(s, "intercessor-squad", 2)
 var tech_squad_id: int = int(s.units[tech].squad)
 s.units[enemy_shooter].position = Vector2(20, 0)
 check(not C.AttackPlan.legal_targets(s, enemy_shooter, false).has(tech_squad_id), "Lone Operative allowed an enemy ranged target beyond 12 inches")
 var range_center: float = 12.0 + float(s.units[enemy_shooter].radius) + float(s.units[tech].radius)
 s.units[enemy_shooter].position = Vector2(range_center, 0)
 var exact_lone_operative_distance: float = float(C.Terrain.targeting(s, enemy_shooter, tech_squad_id).distance)
 for attempt in range(4):
  if exact_lone_operative_distance <= 12.0: break
  range_center -= 0.0001
  s.units[enemy_shooter].position = Vector2(range_center, 0)
  exact_lone_operative_distance = float(C.Terrain.targeting(s, enemy_shooter, tech_squad_id).distance)
 check(absf(exact_lone_operative_distance - 12.0) <= 0.0002 and C.AttackPlan.legal_targets(s, enemy_shooter, false).has(tech_squad_id), "Lone Operative allows targeting at the calibrated 12-inch base-edge boundary")
 s.units[enemy_shooter].position = Vector2(range_center + 0.01, 0)
 check(not C.AttackPlan.legal_targets(s, enemy_shooter, false).has(tech_squad_id), "Lone Operative blocks ranged targeting immediately beyond 12 inches")
 var exact_vehicle_boundary: float = 3.0 + float(s.units[tech].radius) + float(s.units[tank].radius)
 s.units[tank].position = Vector2(exact_vehicle_boundary, 0)
 check(absf(Tech.Geometry.edge(s.units[tech], s.units[tank]) - 3.0) <= 0.0002 and Tech.vehicle_targets(s, tech).has(tank), "Techmarine abilities include a friendly Astartes Vehicle at the 3-inch base-edge boundary")
 s.units[tank].position = Vector2(exact_vehicle_boundary + 0.01, 0)
 check(not Tech.vehicle_targets(s, tech).has(tank) and not C.UnitAbilities.lone_operative_active(s, tech), "Techmarine abilities stop selecting the Vehicle immediately beyond 3 inches")
 s.units[tank].position = Vector2(7, 0)
 check(not C.UnitAbilities.lone_operative_active(s, tech), "Techmarine retained Lone Operative outside 3 inches")
 s.units[tank].position = Vector2(2.5, 0)
 s.units[tank].wounds = 5
 var move_error := C.begin_movement(s, 1, tech, "normal", s.revision)
 check(move_error.is_empty() and s.unit_abilities.window.get("kind", "") == "blessings-of-the-omnissiah", "Blessings start-of-move window did not open through normal movement")
 var bless := select(s, "blessings-of-the-omnissiah")
 check(not bless.is_empty(), "Blessings did not offer nearby Vehicle")
 if not bless.is_empty():
  var start_decision := PendingDecisions.current(s, ["unit-actions"])
  var before_wrong_owner := var_to_bytes(s)
  var wrong_owner_result := submit_choice(s, 2, bless, six)
  check(not str(wrong_owner_result.get("error", "")).is_empty() and var_to_bytes(s) == before_wrong_owner, "The opponent cannot submit or mutate the Techmarine's movement choice")
  s = bytes_to_var(var_to_bytes(s))
  var restored_start_decision := PendingDecisions.current(s, ["unit-actions"])
  check(restored_start_decision.get("decision_id", "") == start_decision.get("decision_id", ""), "Blessings start-of-move decision identity survives save/restore")
  bless = select(s, "blessings-of-the-omnissiah")
  check(str(submit_choice(s, 1, bless, six).get("error", "")).is_empty(), "Blessings action resolves through the normalized command")
 check(s.units[tank].wounds == 8 and Tech.modifier_ignore_active(s, tank), "Blessings did not heal D3 / apply attack modifier protection")
 check(not Tech.characteristic_modifier_ignore_active(s, tank), "Techmarine Blessings incorrectly ignored direct BS/WS characteristic modifiers")
 check(s.pending_move.get("squad", -1) == s.units[tech].squad and s.unit_abilities.window.is_empty(), "Blessings did not resume the pending move")
 s.turn += 2
 check(not Tech.modifier_ignore_active(s, tank), "Blessings protection lasted beyond the start of the next own Movement phase")
 s = fixture()
 tech = find(s, "techmarine")
 tank = find(s, "ballistus-dreadnought")
 s.units[tech].position = Vector2(0, 0)
 s.units[tank].position = Vector2(2, 0)
 s.units[tank].wounds = s.units[tank].max_wounds
 var movement_squad: int = int(s.units[tech].squad)
 var start_move_error := C.begin_movement(s, 1, tech, "normal", s.revision)
 var movement_defer_choice := select(s, "blessings-defer") if start_move_error.is_empty() else {}
 var defer_error := "Could not open the Blessings deferral choice." if movement_defer_choice.is_empty() else str(submit_choice(s, 1, movement_defer_choice, six).get("error", ""))
 var placement_error := start_move_error if not start_move_error.is_empty() else defer_error if not defer_error.is_empty() else C.move(s, 1, tech, Vector2(-1, 0), s.revision)
 var finish_move_error := placement_error if not placement_error.is_empty() else C.finish_movement(s, 1, s.revision)
 check(finish_move_error.is_empty() and s.unit_abilities.window.get("kind", "") == "blessings-of-the-omnissiah", "Blessings end-of-move window did not open through normal movement completion: start=%s defer=%s place=%s finish=%s window=%s" % [start_move_error, defer_error, placement_error, finish_move_error, str(s.unit_abilities.window)])
 var movement_frame := C.ResolutionFrames.current(s)
 var movement_decision := C.UnitActions.pending_decision(s)
 check(movement_frame.get("kind", "") == "unit-action" and movement_frame.get("status", "") == "suspended" and movement_frame.get("action_id", "") == "movement:%d:%d:movement" % [s.turn, movement_squad], "Techmarine Blessings suspends the completed Movement frame")
 check(movement_decision.get("action_id", "") == movement_frame.get("action_id", "") and movement_decision.get("resume_frame_id", "") == movement_frame.get("frame_id", ""), "Techmarine Blessings decision identifies the movement continuation")
 check(Tech.vehicle_targets(s, tech).has(tank), "Friendly Astartes Vehicle model not targetable at 3 inches")
 var full_health_blessing := select(s, "blessings-of-the-omnissiah")
 check(not full_health_blessing.is_empty() and str(submit_choice(s, 1, full_health_blessing, six).get("error", "")).is_empty(), "Full-health Vehicle could not receive Blessings through the normalized command")
 check(s.units[tank].wounds == s.units[tank].max_wounds and Tech.modifier_ignore_active(s, tank), "Blessings failed to grant attack protection at full health")
 check(s.unit_abilities.window.is_empty() and C.ResolutionFrames.current(s).is_empty(), "Techmarine response completes the movement continuation")
 tech = find(s, "techmarine")
 var tech_squad: int = int(s.units[tech].squad)
 s.squads[tech_squad].moved = true
 s.squads[tech_squad].move_type = "ingress"
 check(not Tech.open_for_move(s, tech_squad, "end"), "Blessings incorrectly treated a reserve set-up as a move")
 s = fixture()
 tech = find(s, "techmarine")
 tank = find(s, "ballistus-dreadnought")
 s.units[tech].position = Vector2(0, 0)
 s.units[tank].position = Vector2(2, 0)
 var move_squad: int = int(s.units[tech].squad)
 s.pending_move = {"squad": move_squad, "move_type": "normal", "spent": {}}
 check(Tech.open_for_move(s, move_squad, "start"), "Blessings start timing did not open for deferral test")
 var defer_choice := select(s, "blessings-defer")
 check(not defer_choice.is_empty() and str(submit_choice(s, 1, defer_choice, six).get("error", "")).is_empty(), "Blessings could not be deferred through the normalized command")
 s.pending_move = {}
 s.squads[move_squad].moved = true
 s.squads[move_squad].move_type = "normal"
 C.UnitActions.end_move(s, move_squad)
 var deferred_blessing := select(s, "blessings-of-the-omnissiah")
 check(not deferred_blessing.is_empty() and str(submit_choice(s, 1, deferred_blessing, six).get("error", "")).is_empty(), "Deferred Blessings did not resolve through the normalized command at the end of the move")
 s = fixture()
 tech = find(s, "techmarine")
 tank = find(s, "ballistus-dreadnought")
 var target := find(s, "redemptor-dreadnought", 2)
 s.phase = "shooting"
 s.active = 1
 s.units[tank].wounds = 4
 s.units[tank].position = Vector2(0, 0)
 s.units[target].position = Vector2(12, 0)
 var attack_rows: Array = [{"model": tank, "target": s.units[target].squad, "amount": 1}]
 var unbuffed := C.AttackPlan.prepare(s, int(s.units[tank].squad), false, attack_rows, false)
 check(unbuffed.error.is_empty() and unbuffed.batches[0].context.hit_modifier == -1 and unbuffed.batches[0].context.wound_modifier == -1, "Damaged attacker / Duty Eternal defender did not generate attack modifiers")
 s.unit_abilities.techmarine_blessings = {tank: {"owner": 1, "source": tech, "expires_turn": s.turn + 2}}
 var blessed := C.AttackPlan.prepare(s, int(s.units[tank].squad), false, attack_rows, false)
 check(blessed.error.is_empty() and blessed.batches[0].context.hit_modifier == 0 and blessed.batches[0].context.wound_modifier == 0, "Blessings failed to ignore Vehicle hit and wound modifiers in attack planning")
 print("Techmarine checks: %d failures" % failures)
 quit(0 if failures == 0 else 1)
