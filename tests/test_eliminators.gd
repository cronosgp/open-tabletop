extends SceneTree
const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const MatchCommands = preload("res://scripts/edition_11/match_command_service.gd")
const UNIT := "eliminator-squad"
var failures := 0
func check(ok: bool, message: String) -> void:
 if not ok:
  push_error(message)
  failures += 1
func lists() -> Dictionary:
 var result := F.selections()
 result[1].entries = [
  {"definition_id": "40kdc:11e:adeptus-astartes:captain", "models": 1, "copies": 1},
  {"definition_id": "40kdc:11e:adeptus-astartes:" + UNIT, "models": 3, "copies": 2}]
 return result
func fixture() -> Dictionary:
 var s := F.P.initial_state({"checked_rosters": true, "official_mission": true, "unit_abilities": true, "combat_doctrines": true, "reanimation_protocols": true, "awakened_dynasty": true, "core_stratagems": true, "manual_allocation": false}, lists())
 if s.has("error"): return s
 s.awakened_dynasty.pending = []
 s.mission.stage = "battle"
 s.phase = "shooting"
 s.unit_abilities.setup_players = [1, 2]
 s.unit_abilities.battle_players = [1, 2]
 s.unit_abilities.phase_key = C.UnitActions.key(s)
 s.unit_abilities.window = {}
 s.deployment.complete = true
 s.terrain.areas = []
 s.turn = 3
 s.round = 2
 s.active = 1
 for model: int in s.units:
  s.units[model].position = Vector2(-20, -12) if s.units[model].owner == 1 else Vector2(20, 12)
 s.units[300].position = Vector2(0, -8)
 s.cp = {1: 3, 2: 3}
 for key in ["attack_rerolls", "save_rerolls", "damage_rerolls", "count_rerolls", "hazard_rerolls"]: s.stratagems[key] = false
 return s
func place_target(s: Dictionary, inches: float) -> void:
 for model: int in C.living(s, 4): s.units[model].position = s.units[300].position + Vector2(inches + s.units[300].radius + s.units[model].radius, 0)
func pick(s: Dictionary, action: String, model: int = -999, value: String = "", target: int = -999) -> Dictionary:
 for row: Dictionary in C.unit_choices(s, 1):
  if row.action == action and (model == -999 or row.model == model) and (value == "" or row.value == value) and (target == -999 or row.target == target): return row
 return {}
func submit_choice(s: Dictionary, player: int, selected: Dictionary, revision: int = -2147483648) -> Dictionary:
 var decision := C.UnitActions.pending_decision(s)
 var projected: Dictionary = {}
 for option: Dictionary in decision.get("legal_options", []):
  if str(option.get("action", "")) == str(selected.get("action", "")) and int(option.get("model", -1)) == int(selected.get("model", -1)) and int(option.get("target", -1)) == int(selected.get("target", -1)) and str(option.get("value", "")) == str(selected.get("value", "")): projected = option; break
 var payload := selected
 if not projected.is_empty(): payload = {"_decision_type": MatchCommands.UNIT_CHOICE_ENVELOPE, "decision_id": str(decision.get("decision_id", "")), "option_id": str(projected.get("id", "")), "choice": selected}
 return MatchCommands.execute(s, player, {"kind": MatchCommands.SELECT_UNIT_CHOICE, "revision": int(s.revision) if revision == -2147483648 else revision, "point": Vector2.ZERO, "choice": payload})
func use(s: Dictionary, action: String, model: int = -999, value: String = "", target: int = -999) -> String:
 var selected := pick(s, action, model, value, target)
 if selected.is_empty(): return "Unavailable: " + action
 return str(submit_choice(s, 1, selected).get("error", ""))
func declaration(gun: String = "bolt-sniper-rifle") -> Array:
 return [{"model": 300, "target": 4, "amount": 1, "weapon": gun, "profile": "standard"}]
func _initialize() -> void: call_deferred("run")
func run() -> void:
 var s := fixture()
 check(not s.has("error"), "Eliminator profile failed admission")
 if s.has("error"):
  print(s)
  quit(1)
  return
 check(s.training_points[1] == 260 and C.living(s, 3).size() == 3 and s.units[300].sergeant and not s.units[301].sergeant, "Composition, Sergeant or 85-point cost incorrect")
 check(s.units[300].radius == 20.0 / 25.4 and s.squads[3].stats.movement_inches == 8 and s.squads[3].stats.toughness == 4, "Current model data incorrect")
 place_target(s, 10)
 check(use(s, "optics", 300, "cover").is_empty(), "Ignores Cover choice rejected")
 var prepared := C.AttackPlan.prepare(s, 3, false, declaration(), true)
 check(prepared.error.is_empty() and C.UnitAbilities.weapon(s, 300, 4, Profiles.profile(UNIT).ranged[0].profiles.standard, false).keywords.get("ignores-cover", false), "Optics did not reach prepared ranged attacks")
 check(not C.UnitAbilities.weapon(s, 500, 4, Profiles.profile(UNIT).ranged[0].profiles.standard, false).keywords.get("ignores-cover", false), "Optics leaked to another unit")
 check(not C.UnitAbilities.weapon(s, 300, 4, Profiles.profile(UNIT).melee[0].profiles.standard, true).keywords.get("ignores-cover", false), "Optics leaked to melee")
 var before := var_to_str(s)
 check(not C.advance_phase(s, 1, s.revision).is_empty() and not C.attack_window_error(s, 1, 500, s.revision, false).is_empty() and var_to_str(s) == before, "Selection did not lock attack order and phase")
 check(not use(s, "optics", 500, "cover").is_empty(), "Another unit replaced a live shooting selection")
 var stale := pick(s, "optics-cancel")
 var stale_result := submit_choice(s, 1, stale, s.revision - 1)
 check(not str(stale_result.get("error", "")).is_empty() and var_to_str(s) == before, "Stale optics request changed state")
 check(use(s, "optics-cancel").is_empty() and C.UnitAbilities.Detection.selection(s).is_empty(), "Selection cancellation failed")
 # A selected enemy needs range, not visibility; detection precedes target legality.
 place_target(s, 20)
 var target: Vector2 = s.units[400].position
 s.terrain.areas = [{"name": "Detection fixture", "category": "light", "bounds": Rect2(target - Vector2(1, 1), Vector2(2, 2)), "features": [{"bounds": Rect2(target + Vector2(0, 0.8), Vector2(1, 0.1)), "height": 0.1, "blocks_end": false}]}]
 check(4 not in C.AttackPlan.legal_targets(s, 300, false, "bolt-sniper-rifle", "standard"), "Hidden target initially visible outside 15 inches")
 check(use(s, "optics", 300, "detect", 4).is_empty(), "Invisible enemy in 24 inches unavailable to Optics")
 check(C.Terrain.pair(s, 300, 400).detection == 21 and 4 in C.AttackPlan.legal_targets(s, 300, false, "bolt-sniper-rifle", "standard"), "Detection increase did not enable target selection")
 prepared = C.AttackPlan.prepare(s, 3, false, declaration(), true)
 check(prepared.error.is_empty() and not prepared.batches[0].weapon.keywords.get("ignores-cover", false), "Detection branch also granted Ignores Cover")
 check(use(s, "optics", 300, "cover").is_empty() and C.Terrain.pair(s, 300, 400).detection == 15, "Changing the preview accumulated both effects")
 check(use(s, "optics-cancel").is_empty(), "Preview cancellation rejected")
 place_target(s, 24)
 check(not pick(s, "optics", 300, "detect", 4).is_empty(), "24-inch inclusive boundary rejected")
 place_target(s, 24.02)
 check(pick(s, "optics", 300, "detect", 4).is_empty(), "Beyond-24-inch enemy offered")
 s = fixture()
 place_target(s, 10)
 check(use(s, "optics", 300, "cover").is_empty(), "Second shooting selection failed")
 # Miss all attacks: completion still consumes the unit's shooting and clears optics.
 var outcome := C.resolve_attack_plan(s, 1, 300, declaration(), s.revision, false, true, func() -> int: return 1)
 if not outcome.error.is_empty() or not s.squads[3].shot: print({"outcome": outcome, "pending": s.get("pending_attack", {}), "window": s.unit_abilities.window})
 check(outcome.error.is_empty() and s.squads[3].shot and s.unit_abilities.get("optics", {}).is_empty() and pick(s, "optics", 300).is_empty(), "Missed shooting failed to expire optics")
 s = fixture()
 place_target(s, 10)
 s.squads[3].started_action_turn = s.turn
 check(pick(s, "optics", 300).is_empty(), "Action-blocked unit offered shooting selection")
 s.squads[3].started_action_turn = -1
 s.squads[3].fell_back = true
 check(pick(s, "optics", 300).is_empty(), "Fall Back unit without permission offered Optics")
 s.squads[3].fell_back = false
 s.active = 2
 check(C.UnitActions.optics_choices(s, 1).is_empty(), "Optics available in opponent turn")
 # Preparation: both ordinary Eliminators share their option; Sergeant is independent.
 s = fixture()
 s.phase = "deployment"
 s.unit_abilities.setup_players = []
 check(use(s, "eliminator-troopers", -1, "las", 3).is_empty(), "Trooper replacement rejected")
 check(s.units[301].ranged_weapons[0].id == "las-fusil" and s.units[302].ranged_weapons[0].id == "las-fusil" and s.units[300].ranged_weapons[0].id == "bolt-sniper-rifle", "Trooper replacement changed wrong models")
 check(use(s, "eliminator-sergeant", 300, "carbine").is_empty() and s.units[300].ranged_weapons[0].id == "instigator-bolt-carbine", "Sergeant carbine option rejected")
 check(pick(s, "eliminator-sergeant", 301).is_empty(), "Trooper gained Sergeant-only carbine")
 check(use(s, "eliminator-troopers", -1, "sniper", 3).is_empty() and s.units[301].ranged_weapons[0].id == "bolt-sniper-rifle", "Reversing troop loadout failed")
 s.phase = "shooting"
 s.unit_abilities.setup_players = [1, 2]
 place_target(s, 10)
 var carbine: Dictionary = Profiles.eliminator_gun("carbine").profiles.standard
 check(C.UnitAbilities.weapon(s, 300, 4, carbine, false).keywords.get("lethal-hits", false), "Instigator lacked non-heavy Lethal Hits")
 for keyword in ["MONSTER", "VEHICLE"]:
  s.units[400].keywords.append(keyword)
  check(not C.UnitAbilities.weapon(s, 300, 4, carbine, false).keywords.get("lethal-hits", false), "Instigator gained Lethal Hits against " + keyword)
  s.units[400].keywords.erase(keyword)
 check(not carbine.keywords.has("lethal-hits"), "Target-specific effects mutated the source weapon")
 var las: Dictionary = Profiles.eliminator_gun("las").profiles.standard
 check(las.damage == "D3+3" and las.strength == 10 and las.keywords.heavy, "Las Fusil source profile incorrect")
 var invalid := lists()
 invalid[1].entries[1].copies = 3
 check(not C.RosterValidation.admit(invalid[1]).error.is_empty(), "Eliminator repetition cap ignored")
 invalid = lists()
 invalid[1].entries[1].models = 6
 check(not C.RosterValidation.admit(invalid[1]).error.is_empty(), "Unsupported Eliminator composition admitted")
 var catalog := F.P.Training.Capabilities.current_catalog_choice({"id": "openhammer:11e:Space%20Marines:d6c3-e9d2-430d-6c2f", "edition": "11e", "faction": "Space Marines"})
 check(catalog.get("options", []) == [{"models": 3, "cost": 85}], "Catalog retained historical API composition/price")
 var game = load("res://scenes/main.tscn").instantiate()
 root.add_child(game)
 game.auto_models.button_pressed = false
 game._start_objectives(2)
 game.state = fixture()
 game.unit_abilities = true
 game.selected = -1
 game._spawn_pieces()
 game._refresh()
 for index in range(game.unit_action_picker.item_count):
  var row: Dictionary = game.unit_action_picker.get_item_metadata(index)
  if row.action == "optics" and row.model == 300 and row.value == "cover":
   game.unit_action_picker.select(index)
   break
 game._request_unit_action()
 check(C.UnitAbilities.Detection.selection(game.state).get("squad", -1) == 3 and "selected Eliminator" in game.decision_label.text and "other units wait" in game.unit_action_help.text and "Ignores Cover" in game.unit_action_help.text and game.unit_action_picker.get_selected_metadata().value == "cover", "Actual ability control failed to communicate selected shooting")
 print("Eliminator checks: %d failures" % failures)
 quit(1 if failures else 0)
