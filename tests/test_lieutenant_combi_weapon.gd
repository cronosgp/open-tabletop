extends SceneTree
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Army = preload("res://scripts/edition_11/army_capabilities.gd")
const Catalog = preload("res://scripts/implemented_army_catalog.gd")
const F = preload("res://tests/all_units_fixture.gd")
const Abilities = preload("res://scripts/edition_11/unit_abilities.gd")
const Prevention = preload("res://scripts/edition_11/unit_prevention.gd")
const WoundRolls = preload("res://scripts/edition_11/wound_prevention.gd")
const Combi = preload("res://scripts/edition_11/combi_lieutenant.gd")
const Detection = preload("res://scripts/edition_11/detection_rules.gd")
const AttackPlan = preload("res://scripts/edition_11/attack_plan.gd")
const MatchCommands = preload("res://scripts/edition_11/match_command_service.gd")
const PendingDecisions = preload("res://scripts/edition_11/pending_decision_registry.gd")
var failures := 0

func check(ok: bool, message: String) -> void:
 if not ok:
  push_error(message)
  failures += 1

func _initialize() -> void:
 call_deferred("run")

func submit_choice(state: Dictionary, player: int, selected: Dictionary, point: Vector2 = Vector2.ZERO, roller: Callable = Callable()) -> Dictionary:
 var decision := PendingDecisions.current(state, ["unit-actions"])
 var payload: Dictionary = selected
 if not decision.is_empty():
  var projected: Dictionary = {}
  for option: Dictionary in decision.get("legal_options", []):
   if str(option.get("action", "")) == str(selected.get("action", "")) and int(option.get("model", -1)) == int(selected.get("model", -1)) and int(option.get("target", -1)) == int(selected.get("target", -1)) and str(option.get("value", "")) == str(selected.get("value", "")):
    projected = option
    break
  if projected.is_empty(): return {"error": "The current decision does not project the submitted Evade and Survive choice."}
  payload = {"_decision_type": MatchCommands.UNIT_CHOICE_ENVELOPE, "decision_id": str(decision.get("decision_id", "")), "option_id": str(projected.get("id", "")), "choice": selected}
 return MatchCommands.execute(state, player, {"kind": MatchCommands.SELECT_UNIT_CHOICE, "revision": int(state.revision), "point": point, "choice": payload}, roller)

func run() -> void:
 var profile := Profiles.profile("lieutenant-with-combi-weapon")
 check(profile.get("source_book_id", "") == "000000139" and profile.get("source_datasheet_id", "") == "000000076" and profile.get("source_export_updated_at", "") == "2026-10-16T21:03:46+03:00", "Combi Lieutenant profile points to the selected local Wahapedia sheet and revision")
 check(profile.points_by_models == {1: 85} and profile.base_radius_inches == 20.0 / 25.4 and profile.stats == {"movement_inches": 8, "toughness": 4, "save_target": 3, "wounds": 4, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 0}, "Fixed characteristics, 40mm base radius and 85-point cost match the extracted sheet")
 check(profile.ranged.size() == 1 and profile.ranged[0].id == "combi-weapon" and profile.ranged[0].profiles.bolter.keywords == {"rapid-fire": 1, "assault": true} and profile.ranged[0].profiles.flamer.keywords == {"torrent": true, "assault": true, "blast": 1}, "Combi-weapon alternate profiles and traits match the local extraction")
 check(profile.ranged[0].profiles.bolter.attacks == 2 and profile.ranged[0].profiles.bolter.skill == 2 and profile.ranged[0].profiles.bolter.strength == 5 and profile.ranged[0].profiles.bolter.ap == -1 and profile.ranged[0].profiles.bolter.damage == 2 and profile.ranged[0].profiles.bolter.range_inches == 24.0, "Bolter profile characteristics match the local extraction")
 check(profile.ranged[0].profiles.flamer.attacks == 3 and profile.ranged[0].profiles.flamer.skill == 0 and profile.ranged[0].profiles.flamer.strength == 5 and profile.ranged[0].profiles.flamer.ap == -1 and profile.ranged[0].profiles.flamer.damage == 1 and profile.ranged[0].profiles.flamer.range_inches == 12.0, "Flamer profile characteristics match the local extraction")
 check(profile.melee.size() == 1 and profile.melee[0].id == "paired-combat-blades" and profile.melee[0].profiles.standard.attacks == 6 and profile.melee[0].profiles.standard.keywords == {"sustained-hits": 1}, "Paired Combat Blades profile matches the local extraction")
 check(Army.SPECS["lieutenant-with-combi-weapon"].current_reference and Army.SPECS["lieutenant-with-combi-weapon"].validation_status == "tests_passed_local_targeted", "The profile is admitted only after targeted local rules validation")
 var unit := {"id": "40kdc:11e:adeptus-astartes:lieutenant-with-combi-weapon", "edition": "11e", "faction": "Space Marines", "name": profile.name}
 check(not Army.current_catalog_choice(unit).is_empty() and Army.resolve("Space Marines", unit.id).get("error", "").is_empty(), "Admitted datasheet resolves through the local consolidated construction catalog")
 var catalog := Catalog.new()
 root.add_child(catalog)
 catalog.select_edition("11e")
 check(not catalog.lookup(unit.id).is_empty(), "Admitted datasheet is present in the consolidated local construction catalog")
 var selections := F.selections()
 for entry: Dictionary in selections[1].entries:
  if entry.definition_id.ends_with(":lieutenant"):
   entry.definition_id = unit.id
   entry.models = 1
 var state := F.P.initial_state({"unit_abilities": true, "combat_doctrines": true, "reanimation_protocols": true, "awakened_dynasty": true, "core_stratagems": true}, selections)
 check(not state.has("error"), "Admitted Lieutenant materializes in a local match fixture: %s" % state.get("error", ""))
 if not state.has("error"):
  var lieutenant := -1
  var enemy := -1
  for model: int in state.units:
   if state.units[model].owner == 1 and Abilities.identity(state.units[model]) == "lieutenant-with-combi-weapon": lieutenant = model
   if state.units[model].owner == 2 and Abilities.identity(state.units[model]) == "necron-warriors" and enemy < 0: enemy = model
  check(lieutenant >= 0 and enemy >= 0, "Match contains the Lieutenant and an enemy unit")
  if lieutenant >= 0 and enemy >= 0:
   var squad: int = state.units[lieutenant].squad
   check(Abilities.has(state, squad, "feel-no-pain-5") and Abilities.has(state, squad, "infiltrators") and Abilities.has(state, squad, "lone-operative") and Abilities.has(state, squad, "stealth"), "Lieutenant's prevention, deployment, targeting and cover abilities are registered")
   check({"target": 5, "against": "any"} in Prevention.rules(state, lieutenant), "Feel No Pain 5+ is assigned to the Lieutenant and consumed by the prevention resolver")
   var fnp_roll := WoundRolls.resolve(1, 4, Prevention.rules(state, lieutenant), "normal", func() -> int: return 5)
   check(fnp_roll.error.is_empty() and fnp_roll.prevented == 1 and fnp_roll.lost == 0, "Lieutenant's Feel No Pain 5+ prevents an allocated wound through the shared resolver")
   check(Abilities.lone_operative_active(state, lieutenant), "Lone Operative is active while the Lieutenant remains a standalone unit")
   state.terrain = {"id": "terrain-11e-v1", "areas": []}
   state.phase = "shooting"
   state.active = 2
   state.units[lieutenant].position = Vector2(0, 0)
   state.units[enemy].position = Vector2(20, 0)
   check(squad not in AttackPlan.legal_targets(state, enemy, false), "Ranged attacks cannot target the standalone Lieutenant beyond 12 inches")
   state.units[enemy].position = Vector2(10, 0)
   check(squad in AttackPlan.legal_targets(state, enemy, false), "Lone Operative allows a ranged target within 12 inches")
   state.phase = "command"
   state.active = 1
   state.turn = 2
   state.awakened_dynasty.pending = []
   state.combat_doctrines.selected_turn[1] = 2
   state.terrain = {"id": "custom", "areas": [{"name": "Test ruin", "category": "light", "bounds": Rect2(4, 4, 2, 2), "features": [{"bounds": Rect2(4, 4, 2, 2), "height": 1.0, "blocks_end": false}]}]}
   state.units[enemy].position = Vector2(4.5, 4.5)
   var priority: Dictionary = {}
   var priority_choices := Combi.priority_choices(state, 1)
   if not priority_choices.is_empty(): priority = priority_choices[0]
   check(not priority.is_empty(), "Command phase offers visible terrain features for Priority Target Identified")
   if not priority.is_empty():
    var priority_result: Dictionary = submit_choice(state, 1, priority, Vector2.ZERO, func() -> int: return 1)
    var priority_error := str(priority_result.get("error", ""))
    check(priority_error.is_empty() and is_equal_approx(Detection.detection_range(state, enemy, false), 18.0), "Identifying a feature adds 3 inches to enemy detection while that enemy is within it: %s range=%s marker=%s" % [priority_error, str(Detection.detection_range(state, enemy, false)), str(state.unit_abilities.get("priority_target", {}))])
    check(is_equal_approx(Detection.detection_range(state, enemy, false), 18.0), "The priority marker remains active through the current turn")
    state.turn = 3
    check(is_equal_approx(Detection.detection_range(state, enemy, false), 15.0), "The terrain detection bonus expires at the end of the turn")
    state.turn = 2
   state.mission.stage = "battle"
   state.awakened_dynasty.pending = []
   state.phase = "movement"
   state.turn = 2
   state.active = 2
   state.terrain = {"id": "terrain-11e-v1", "areas": []}
   state.units[lieutenant].position = Vector2(0, 0)
   state.units[enemy].position = Vector2(7, 0)
   for model: int in state.units:
    if state.units[model].squad == state.units[enemy].squad and model != enemy: state.units[model].wounds = 0
   var moved_squad: int = int(state.units[enemy].squad)
   var movement_error := F.C.move(state, 2, enemy, Vector2(6, 0), state.revision)
   var finish_error := movement_error if not movement_error.is_empty() else F.C.finish_movement(state, 2, state.revision)
   var movement_frame := F.C.ResolutionFrames.current(state)
   var movement_decision := F.C.UnitActions.pending_decision(state)
   check(finish_error.is_empty() and state.unit_abilities.window.get("kind", "") == "evade-and-survive", "A completed enemy move opens Evade and Survive through the movement command flow: move=%s finish=%s window=%s" % [movement_error, finish_error, str(state.unit_abilities.window)])
   check(movement_frame.get("status", "") == "suspended" and movement_frame.get("action_id", "") == "movement:%d:%d:movement" % [state.turn, moved_squad] and movement_decision.get("resume_frame_id", "") == movement_frame.get("frame_id", ""), "Evade and Survive decision retains the completed Movement frame")
   var before_wrong_owner := var_to_bytes(state)
   var decline: Dictionary = {}
   for option: Dictionary in F.C.UnitActions.choices(state, 1):
    if option.get("action", "") == "evade-pass": decline = option
   var wrong_owner_result := submit_choice(state, 2, decline)
   check(not str(wrong_owner_result.get("error", "")).is_empty() and var_to_bytes(state) == before_wrong_owner, "The enemy mover cannot submit or mutate Evade and Survive")
   state = bytes_to_var(var_to_bytes(state))
   movement_decision = PendingDecisions.current(state, ["unit-actions"])
   check(movement_decision.get("resume_frame_id", "") == movement_frame.get("frame_id", ""), "Evade and Survive's normalized decision retains the Movement frame through save/restore")
   check(not decline.is_empty() and str(submit_choice(state, 1, decline).get("error", "")).is_empty() and F.C.ResolutionFrames.current(state).is_empty(), "Declining Evade and Survive through the normalized command completes the movement continuation")
   state.units[enemy].position = Vector2(7, 0)
   state.unit_abilities.window = {"kind": "resumable-test-window", "owners": [1]}
   Combi.open_after_enemy_move(state, state.units[enemy].squad)
   check(state.unit_abilities.window.get("kind", "") == "evade-and-survive" and state.unit_abilities.window.resume_window.get("kind", "") == "resumable-test-window", "An enemy move ending within 8 inches opens the reaction and preserves any prior pending decision")
   if state.unit_abilities.window.get("kind", "") == "evade-and-survive":
    var evade_choices := Combi.choices(state, 1)
    var use: Dictionary = evade_choices[0]
    var roller := func() -> int: return 4
    var started: Dictionary = submit_choice(state, 1, use, Vector2.ZERO, roller)
    check(started.error.is_empty() and state.unit_abilities.window.get("kind", "") == "evade-placement" and state.unit_abilities.window.distance == 5, "Evade rolls D3+3 and opens a bounded movement preview")
    if state.unit_abilities.window.get("kind", "") == "evade-placement":
     var placement_choice: Dictionary = {}
     for option: Dictionary in Combi.choices(state, 1):
      if option.get("action", "") == "evade-place" and option.model == lieutenant: placement_choice = option
     var placement: Dictionary = submit_choice(state, 1, placement_choice, Vector2(-5, 0), roller)
     var confirm_choice: Dictionary = {}
     for option: Dictionary in Combi.choices(state, 1):
      if option.get("action", "") == "evade-confirm": confirm_choice = option
     var confirm: Dictionary = submit_choice(state, 1, confirm_choice, Vector2.ZERO, roller)
     check(placement.error.is_empty() and confirm.error.is_empty() and state.units[lieutenant].position == Vector2(-5, 0) and state.unit_abilities.window.get("kind", "") == "resumable-test-window", "Evade confirms a legal coherent, unengaged move and resumes the prior decision")
 if failures == 0: print("Lieutenant with Combi-weapon extraction profile checks passed.")
 catalog.free()
 quit(0 if failures == 0 else 1)
