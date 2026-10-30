extends SceneTree
const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const MatchCommands = preload("res://scripts/edition_11/match_command_service.gd")
const Army = preload("res://scripts/edition_11/army_capabilities.gd")
const DatasheetChecks = preload("res://tests/space_marine_datasheet_checks.gd")
const UNIT := "eliminator-squad"
const ELIMINATOR_ID := "40kdc:11e:adeptus-astartes:eliminator-squad"
var failures := 0
func check(ok: bool, message: String) -> void:
 if not ok:
  push_error(message)
  failures += 1
func lists() -> Dictionary:
 var result := F.current_marine_selections()
 result[1].entries = [
  {"definition_id": "40kdc:11e:adeptus-astartes:captain", "models": 1, "copies": 1},
   {"definition_id": ELIMINATOR_ID, "models": 3, "copies": 2}]
 return result
func fixture() -> Dictionary:
 var s := F.P.initial_state({"checked_rosters": false, "official_mission": false, "unit_abilities": true, "combat_doctrines": true, "reanimation_protocols": true, "awakened_dynasty": true, "core_stratagems": true, "manual_allocation": false}, lists())
 if s.has("error"):
  print("Eliminator fixture admission error: %s" % str(s.get("error", "")))
  return s
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
 # Prevent an optional enemy Armour of Contempt window from pausing missed-shot expiry.
 s.cp = {1: 3, 2: 0}
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

func check_weapon_plans(s: Dictionary, model: int) -> void:
 var loadout := {"ranged": s.units[model].ranged_weapons.duplicate(true), "melee": s.units[model].melee_weapons.duplicate(true)}
 for failure: String in DatasheetChecks.fixed_weapon_plan_failures(s, loadout, model, 4):
  check(false, failure)
func _initialize() -> void: call_deferred("run")
func run() -> void:
 var profile := Profiles.profile(UNIT)
 check(profile.source_book_id == "000000139" and profile.source_datasheet_id == "000001668" and profile.source_export_updated_at == "2026-10-16T21:03:46+03:00", "Eliminator profile identity matches the selected local export")
 check(profile.points_by_models == {3: 85} and profile.max_supported_copies == 2 and profile.stats == {"movement_inches": 8, "toughness": 4, "save_target": 3, "wounds": 2, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 0} and is_equal_approx(profile.base_radius_inches, 20.0 / 25.4), "Eliminator source cost, supported Incursion copy limit, profile and 40 mm base match")
 var expected_keywords := ["ADEPTUS ASTARTES", "EXPLOSIVES", "IMPERIUM", "INFANTRY", "PHOBOS", "SMOKE"]
 var actual_keywords: Array = profile.keywords.duplicate()
 actual_keywords.sort()
 check(actual_keywords == expected_keywords, "Eliminator common-book keywords match the export")
 check(profile.ranged.size() == 2 and profile.ranged[0].id == "bolt-sniper-rifle" and profile.ranged[1].id == "bolt-pistol" and profile.melee.size() == 1 and profile.melee[0].id == "ceramite-fists", "The default Sergeant/Veteran loadouts contain the source weapons")
 check(Army.SPECS[UNIT].current_reference and Army.SPECS[UNIT].max_supported_copies == 2, "Eliminators remain in the consolidated current catalog with the Incursion copy cap")
 var catalog := Army.current_catalog_choice({"id": ELIMINATOR_ID, "edition": "11e", "faction": "Space Marines"})
 check(catalog.get("options", []) == [{"models": 3, "cost": 85}], "The current catalog exposes only the fixed three-model source composition")
 var single := Army.admit({"schema_version": 2, "faction": "Space Marines", "category": "incursion", "points_limit": 1000, "entries": [{"definition_id": ELIMINATOR_ID, "models": 3, "copies": 1}]})
 var double := Army.admit({"schema_version": 2, "faction": "Space Marines", "category": "incursion", "points_limit": 1000, "entries": [{"definition_id": ELIMINATOR_ID, "models": 3, "copies": 2}]})
 var triple := Army.admit({"schema_version": 2, "faction": "Space Marines", "category": "incursion", "points_limit": 1000, "entries": [{"definition_id": ELIMINATOR_ID, "models": 3, "copies": 3}]})
 check(single.error.is_empty() and single.total == 85 and double.error.is_empty() and double.total == 170 and not triple.error.is_empty(), "Incursion admits two Eliminator Squads and rejects a third")
 var s := fixture()
 check(not s.has("error"), "Eliminator profile failed admission")
 if s.has("error"):
  print(s)
  quit(1)
  return
 check(s.training_points[1] == 260 and C.living(s, 3).size() == 3 and s.units[300].sergeant and not s.units[301].sergeant and not s.units[302].sergeant, "Current catalogs materialize one Captain and two three-model Eliminator squads at source cost")
 check(C.UnitAbilities.identity(s.units[400]) == "intercessor-squad", "The opposing roster uses the current Space Marines catalog")
 check(s.units[300].radius == 20.0 / 25.4 and s.squads[3].stats.movement_inches == 8 and s.squads[3].stats.toughness == 4 and s.squads[3].stats.wounds == 2 and s.squads[3].stats.save_target == 3, "Current model data and the 40 mm base match")
 for model: int in C.living(s, 3):
  check(is_equal_approx(float(s.units[model].radius), 20.0 / 25.4), "Each Eliminator has a 40 mm base proxy")
  check(C.UnitAbilities.has(s, 3, "infiltrators") and C.UnitAbilities.has(s, 3, "stealth") and C.UnitAbilities.has(s, 3, "chameleoline-cloaks") and C.UnitAbilities.has(s, 3, "special-issue-optics-and-ammunition"), "Core and datasheet abilities are admitted on the current profile")
  check_weapon_plans(s, model)
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
 # Preparation: ordinary models select their option independently; the Sergeant is independent.
 s = fixture()
 s.phase = "deployment"
 s.unit_abilities.setup_players = []
 var preparation_choices: Array = C.UnitActions.choices(s, 1)
 var first_trooper_label := ""
 var second_trooper_label := ""
 for preparation_choice: Dictionary in preparation_choices:
  if preparation_choice.get("action", "") != "eliminator-troopers": continue
  if preparation_choice.get("model", -1) == 301: first_trooper_label = str(preparation_choice.label)
  if preparation_choice.get("model", -1) == 302: second_trooper_label = str(preparation_choice.label)
 check(first_trooper_label == "Eliminator 1: Replace Bolt Sniper Rifle with Las Fusil" and second_trooper_label == "Eliminator 2: Replace Bolt Sniper Rifle with Las Fusil", "Preparation choices use clear trooper ordinals and describe the equipment change")
 var before_invalid_choices := var_to_str(s)
 var sergeant_as_trooper := C.UnitActions.apply(s, 1, {"action": "eliminator-troopers", "model": 300, "target": 3, "value": "las"}, Vector2.ZERO, func() -> int: return 1)
 var enemy_trooper := C.UnitActions.apply(s, 2, {"action": "eliminator-troopers", "model": 301, "target": 3, "value": "las"}, Vector2.ZERO, func() -> int: return 1)
 check(not str(sergeant_as_trooper.get("error", "")).is_empty() and not str(enemy_trooper.get("error", "")).is_empty() and var_to_str(s) == before_invalid_choices, "Trooper replacement rejects the Sergeant and the opposing player without changing state")
 check(not pick(s, "eliminator-troopers", 301, "las", 3).is_empty() and not pick(s, "eliminator-troopers", 302, "las", 3).is_empty(), "Each ordinary Eliminator has an independent Las Fusil choice")
 check(use(s, "eliminator-troopers", 301, "las", 3).is_empty(), "First trooper replacement rejected")
 check(s.units[301].ranged_weapons[0].id == "las-fusil" and s.units[302].ranged_weapons[0].id == "bolt-sniper-rifle" and s.units[300].ranged_weapons[0].id == "bolt-sniper-rifle", "First trooper replacement changed another model")
 check_weapon_plans(s, 301)
 check_weapon_plans(s, 302)
 check(not pick(s, "eliminator-troopers", 301, "sniper", 3).is_empty() and not pick(s, "eliminator-troopers", 302, "las", 3).is_empty(), "One model can restore its sniper rifle while the other keeps its Las Fusil")
 check(use(s, "eliminator-troopers", 302, "las", 3).is_empty() and s.units[301].ranged_weapons[0].id == "las-fusil" and s.units[302].ranged_weapons[0].id == "las-fusil", "Second trooper replacement rejected")
 check(use(s, "eliminator-troopers", 301, "sniper", 3).is_empty() and s.units[301].ranged_weapons[0].id == "bolt-sniper-rifle" and s.units[302].ranged_weapons[0].id == "las-fusil", "First trooper restores independently from the second")
 check(use(s, "eliminator-troopers", 302, "sniper", 3).is_empty() and s.units[301].ranged_weapons[0].id == "bolt-sniper-rifle" and s.units[302].ranged_weapons[0].id == "bolt-sniper-rifle", "Both ordinary models can restore their Bolt Sniper Rifles independently")
 check(use(s, "eliminator-sergeant", 300, "las", 3).is_empty() and s.units[300].ranged_weapons[0].id == "las-fusil", "The Sergeant can independently select a Las Fusil")
 check_weapon_plans(s, 300)
 check(use(s, "eliminator-sergeant", 300, "sniper", 3).is_empty() and s.units[300].ranged_weapons[0].id == "bolt-sniper-rifle", "The Sergeant can restore the Bolt Sniper Rifle")
 check(use(s, "eliminator-sergeant", 300, "carbine").is_empty() and s.units[300].ranged_weapons[0].id == "instigator-bolt-carbine", "Sergeant carbine option rejected")
 check_weapon_plans(s, 300)
 check(pick(s, "eliminator-sergeant", 301).is_empty(), "Trooper gained Sergeant-only carbine")
 check(pick(s, "eliminator-sergeant", 302).is_empty(), "Second trooper gained Sergeant-only options")
 s.phase = "shooting"
 s.unit_abilities.setup_players = [1, 2]
 place_target(s, 10)
 var carbine: Dictionary = Profiles.eliminator_gun("carbine").profiles.standard
 check(C.UnitAbilities.weapon(s, 300, 4, carbine, false).keywords.get("lethal-hits", false), "Instigator lacked non-heavy Lethal Hits")
 for keyword in ["MONSTER", "VEHICLE"]:
  s.units[400].keywords.append(keyword)
  check(not C.UnitAbilities.weapon(s, 300, 4, carbine, false).keywords.get("lethal-hits", false), "Instigator gained Lethal Hits against " + keyword)
  s.units[400].keywords.erase(keyword)
 check(carbine.keywords.get("lethal-hits", false) and carbine.get("target_restricted_traits", {}).get("lethal-hits") == ["MONSTER", "VEHICLE"], "Target-specific effects mutated the source weapon")
 var las: Dictionary = Profiles.eliminator_gun("las").profiles.standard
 check(las.damage == "D3+3" and las.strength == 10 and las.keywords.heavy, "Las Fusil source profile incorrect")
 var invalid := lists()
 invalid[1].entries[1].copies = 3
 check(not C.RosterValidation.admit(invalid[1]).error.is_empty(), "Eliminator repetition cap ignored")
 invalid = lists()
 invalid[1].entries[1].models = 6
 check(not C.RosterValidation.admit(invalid[1]).error.is_empty(), "Unsupported Eliminator composition admitted")
 var profile_catalog := Army.current_catalog_choice({"id": ELIMINATOR_ID, "edition": "11e", "faction": "Space Marines"})
 check(profile_catalog.get("options", []) == [{"models": 3, "cost": 85}], "The consolidated catalog retains the source composition/price without historical provider choices")
 var game = load("res://scenes/main.tscn").instantiate()
 root.add_child(game)
 await process_frame
 game._start_objectives(2)
 game._dismiss_home(1)
 game.auto_models.button_pressed = false
 game.state = fixture()
 game.combat_enabled = true
 game.state.units[301].ranged_weapons[0] = Profiles.eliminator_gun("las")
 check(game._setup_current_equipment({"action": "eliminator-troopers", "model": 301}) == "Las Fusil" and game._setup_current_equipment({"action": "eliminator-troopers", "model": 302}) == "Bolt Sniper Rifle", "Preparation help identifies each trooper's current weapon separately")
 check(game._setup_equipment_model_name(301) == "Eliminator 1" and game._setup_equipment_model_name(302) == "Eliminator 2" and game._setup_equipment_model_name(300) == "Eliminator Sergeant", "Preparation equipment captions use player-facing model names")
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
