extends SceneTree
const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Tech = preload("res://scripts/edition_11/techmarine.gd")
var failures := 0
func check(ok: bool, message: String) -> void:
 if not ok:
  push_error(message)
  failures += 1
func six() -> int: return 6
func entry(name: String, models: int = 1) -> Dictionary:
 return {"definition_id": "40kdc:11e:adeptus-astartes:" + name, "models": models, "copies": 1}
func fixture() -> Dictionary:
 var lists := F.selections()
 lists[1].entries = [entry("captain"), entry("ballistus-dreadnought"), entry("intercessor-squad", 5)]
 var state := F.P.initial_state({"unit_abilities": true, "combat_doctrines": true, "reanimation_protocols": true, "awakened_dynasty": true, "core_stratagems": true, "manual_allocation": false}, lists)
 if state.has("error"): return state
 var captain := find(state, "captain")
 if captain > 0:
  state.units[captain].definition_id = "40kdc:11e:adeptus-astartes:techmarine"
  state.units[captain].keywords = Profiles.profile("techmarine").keywords.duplicate()
  state.units[captain].max_wounds = 4
  state.units[captain].wounds = 4
  state.units[captain].radius = Profiles.profile("techmarine").base_radius_inches
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
func find(state: Dictionary, identity: String) -> int:
 for model: int in state.units:
  if Tech.identity(state.units[model]) == identity: return model
 return -1
func select(state: Dictionary, action: String) -> Dictionary:
 for option: Dictionary in C.unit_choices(state, 1):
  if option.action == action: return option
 return {}
func _initialize() -> void: call_deferred("run")
func run() -> void:
 var profile := Profiles.profile("techmarine")
 check(profile.points == 55 and profile.stats.toughness == 5 and profile.stats.save_target == 2, "Techmarine profile does not match local Wahapedia export")
 check(profile.ranged.size() == 2 and profile.melee[0].profiles.standard.attacks == 5, "Techmarine weapons do not match local Wahapedia export")
 var s := fixture()
 check(not s.has("error"), "Techmarine fixture could not be admitted")
 if s.has("error"):
  print(s)
  quit(1)
  return
 var tech := find(s, "techmarine")
 var tank := find(s, "ballistus-dreadnought")
 check(tech > 0 and tank > 0, "Techmarine or Astartes Vehicle absent")
 s.units[tech].position = Vector2(0, 0)
 s.units[tank].position = Vector2(2.5, 0)
 check(C.UnitAbilities.lone_operative_active(s, tech), "Techmarine did not gain Lone Operative within 3 inches of friendly Vehicle")
 var enemy_shooter := find(s, "necron-warriors")
 var tech_squad_id: int = int(s.units[tech].squad)
 s.units[enemy_shooter].position = Vector2(20, 0)
 check(not C.AttackPlan.legal_targets(s, enemy_shooter, false).has(tech_squad_id), "Lone Operative allowed an enemy ranged target beyond 12 inches")
 s.units[enemy_shooter].position = Vector2(12.5, 0)
 check(C.AttackPlan.legal_targets(s, enemy_shooter, false).has(tech_squad_id), "Lone Operative blocked an enemy ranged target within 12 inches")
 s.units[tank].position = Vector2(7, 0)
 check(not C.UnitAbilities.lone_operative_active(s, tech), "Techmarine retained Lone Operative outside 3 inches")
 s.units[tank].position = Vector2(2.5, 0)
 s.units[tank].wounds = 5
 var move_error := C.begin_movement(s, 1, tech, "normal", s.revision)
 check(move_error.is_empty() and s.unit_abilities.window.get("kind", "") == "blessings-of-the-omnissiah", "Blessings start-of-move window did not open through normal movement")
 var bless := select(s, "blessings-of-the-omnissiah")
 check(not bless.is_empty(), "Blessings did not offer nearby Vehicle")
 if not bless.is_empty(): check(C.unit_action(s, 1, bless, Vector2.ZERO, s.revision, six).is_empty(), "Blessings action rejected")
 check(s.units[tank].wounds == 8 and Tech.modifier_ignore_active(s, tank), "Blessings did not heal D3 / apply attack modifier protection")
 check(s.pending_move.get("squad", -1) == s.units[tech].squad and s.unit_abilities.window.is_empty(), "Blessings did not resume the pending move")
 s.turn += 2
 check(not Tech.modifier_ignore_active(s, tank), "Blessings protection lasted beyond the start of the next own Movement phase")
 s = fixture()
 tech = find(s, "techmarine")
 tank = find(s, "ballistus-dreadnought")
 s.units[tech].position = Vector2(0, 0)
 s.units[tank].position = Vector2(2, 0)
 s.squads[s.units[tech].squad].moved = true
 s.squads[s.units[tech].squad].move_type = "normal"
 s.units[tank].wounds = s.units[tank].max_wounds
 s.unit_abilities.window = {"kind": "other-window", "owners": [1]}
 C.UnitActions.end_move(s, int(s.units[tech].squad))
 check(s.unit_abilities.window.get("kind", "") == "blessings-of-the-omnissiah", "Blessings end-of-move window did not open through normal movement completion")
 check(Tech.vehicle_targets(s, tech).has(tank), "Friendly Astartes Vehicle model not targetable at 3 inches")
 var full_health_blessing := select(s, "blessings-of-the-omnissiah")
 check(not full_health_blessing.is_empty() and C.unit_action(s, 1, full_health_blessing, Vector2.ZERO, s.revision, six).is_empty(), "Full-health Vehicle could not receive Blessings")
 check(s.units[tank].wounds == s.units[tank].max_wounds and Tech.modifier_ignore_active(s, tank), "Blessings failed to grant attack protection at full health")
 check(s.unit_abilities.window.get("kind", "") == "other-window", "Blessings choice did not restore prior pending window")
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
 check(not defer_choice.is_empty() and C.unit_action(s, 1, defer_choice, Vector2.ZERO, s.revision, six).is_empty(), "Blessings could not be deferred to the end of the move")
 s.pending_move = {}
 s.squads[move_squad].moved = true
 s.squads[move_squad].move_type = "normal"
 C.UnitActions.end_move(s, move_squad)
 var deferred_blessing := select(s, "blessings-of-the-omnissiah")
 check(not deferred_blessing.is_empty() and C.unit_action(s, 1, deferred_blessing, Vector2.ZERO, s.revision, six).is_empty(), "Deferred Blessings did not resolve at the end of the move")
 s = fixture()
 tech = find(s, "techmarine")
 tank = find(s, "ballistus-dreadnought")
 var target := find(s, "necron-warriors")
 s.phase = "shooting"
 s.active = 1
 s.units[tank].wounds = 4
 s.units[tank].position = Vector2(0, 0)
 s.units[target].position = Vector2(12, 0)
 for defender_model: int in C.living(s, int(s.units[target].squad)):
  s.units[defender_model].definition_id = "40kdc:11e:adeptus-astartes:redemptor-dreadnought"
  s.units[defender_model].keywords = Profiles.profile("redemptor-dreadnought").keywords.duplicate()
 var attack_rows: Array = [{"model": tank, "target": s.units[target].squad, "amount": 1}]
 var unbuffed := C.AttackPlan.prepare(s, int(s.units[tank].squad), false, attack_rows, false)
 check(unbuffed.error.is_empty() and unbuffed.batches[0].context.hit_modifier == -1 and unbuffed.batches[0].context.wound_modifier == -1, "Damaged attacker / Duty Eternal defender did not generate attack modifiers")
 s.unit_abilities.techmarine_blessings = {tank: {"owner": 1, "source": tech, "expires_turn": s.turn + 2}}
 var blessed := C.AttackPlan.prepare(s, int(s.units[tank].squad), false, attack_rows, false)
 check(blessed.error.is_empty() and blessed.batches[0].context.hit_modifier == 0 and blessed.batches[0].context.wound_modifier == 0, "Blessings failed to ignore Vehicle hit and wound modifiers in attack planning")
 print("Techmarine checks: %d failures" % failures)
 quit(0 if failures == 0 else 1)
