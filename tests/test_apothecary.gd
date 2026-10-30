extends SceneTree
const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const H = preload("res://scripts/edition_11/unit_healing.gd")
const S = preload("res://scripts/edition_11/support_attachments.gd")
const Equipment = preload("res://scripts/edition_11/equipment.gd")
const MatchCommandService = preload("res://scripts/edition_11/match_command_service.gd")
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
 lists[1].entries = [entry("apothecary"), entry("captain"), entry("intercessor-squad", 5), entry("lieutenant")]
 var s := F.P.initial_state({"unit_abilities": true, "combat_doctrines": true, "reanimation_protocols": true, "awakened_dynasty": true, "core_stratagems": true, "manual_allocation": false}, lists)
 if s.has("error"): return s
 C.UnitActions.attach(s, 700, 5)
 C.UnitActions.attach(s, 100, 5)
 s.mission.stage = "battle"
 s.phase = "command"
 s.turn = 3
 s.round = 2
 s.active = 1
 s.unit_abilities.setup_players = [1, 2]
 s.unit_abilities.battle_players = [1, 2]
 s.unit_abilities.window = {}
 s.unit_abilities.phase_key = C.UnitActions.key(s)
 s.combat_doctrines.selected_turn[1] = 3
 s.awakened_dynasty.pending = []
 s.terrain.areas = []
 s.cp = {1: 0, 2: 0}
 for model: int in s.units:
  s.units[model].on_battlefield = true
  s.units[model].position = Vector2(-18, 16) if s.units[model].owner == 1 else Vector2(18, 16)
 var positions := {500: Vector2(0,-8), 501: Vector2(1.7,-8), 502: Vector2(3.4,-8), 503: Vector2(0,-6.3), 504: Vector2(1.7,-6.3), 100: Vector2(0,-9.8), 700: Vector2(1.8,-9.8)}
 for model: int in positions: s.units[model].position = positions[model]
 s.unit_abilities.anchors = {5: C.living(s, 5)}
 return s
func current_catalog_bodyguard_fixture(identity: String, models: int) -> Dictionary:
 var lists := F.current_marine_selections()
 lists[1].entries = [entry("apothecary"), entry(identity, models)]
 var options := {"unit_abilities": true, "reanimation_protocols": true, "combat_doctrines": true, "awakened_dynasty": true, "core_stratagems": true, "manual_allocation": false}
 if identity in ["crusader-squad", "sword-brethren-squad"]: options.marine_chapters = {1: "BLACK TEMPLARS", 2: "BLACK TEMPLARS"}
 elif identity == "inner-circle-companions": options.marine_chapters = {1: "DARK ANGELS", 2: "DARK ANGELS"}
 elif identity in ["deathwatch-veterans", "fortis-kill-team", "decimus-kill-team"]: options.marine_chapters = {1: "DEATHWATCH", 2: "DEATHWATCH"}
 return F.P.initial_state(options, lists)
func choose(s: Dictionary, action: String, model: int = -1, point: Vector2 = Vector2.ZERO) -> String:
  var result: Dictionary = {}
  if not C.UnitActions.pending_decision(s).is_empty():
   result = choose_normalized(s, action, model, point)
  else:
   var selected: Dictionary = {}
   for option: Dictionary in C.UnitActions.choices(s, 1):
    if option.action == action and (model == -1 or option.model == model): selected = option; break
   if selected.is_empty(): return "Choice unavailable: " + action
   result = MatchCommandService.execute(s, 1, {"kind": MatchCommandService.SELECT_UNIT_CHOICE, "revision": int(s.revision), "point": point, "choice": selected}, six)
  return str(result.get("error", ""))
func choose_normalized(s: Dictionary, action: String, model: int = -1, point: Vector2 = Vector2.ZERO, player: int = 1) -> Dictionary:
 var selected: Dictionary = {}
 for option: Dictionary in C.UnitActions.choices(s, player):
  if str(option.get("action", "")) == action and (model == -1 or int(option.get("model", -1)) == model): selected = option; break
 if selected.is_empty(): return {"error": "No projected %s healing choice." % action}
 return submit_normalized(s, player, selected, point)
func submit_normalized(s: Dictionary, player: int, selected: Dictionary, point: Vector2 = Vector2.ZERO, revision: int = -2147483648) -> Dictionary:
 var decision := C.UnitActions.pending_decision(s)
 if decision.is_empty(): return {"error": "No UnitActions decision is pending."}
 var projected: Dictionary = {}
 for option: Dictionary in decision.get("legal_options", []):
  if str(option.get("action", "")) == str(selected.get("action", "")) and int(option.get("model", -1)) == int(selected.get("model", -1)) and int(option.get("target", -1)) == int(selected.get("target", -1)) and str(option.get("value", "")) == str(selected.get("value", "")): projected = option; break
 if projected.is_empty(): return {"error": "The selected healing option is not in the pending decision."}
 return MatchCommandService.execute(s, player, {"kind": MatchCommandService.SELECT_UNIT_CHOICE, "revision": int(s.revision) if revision == -2147483648 else revision, "point": point, "choice": {"_decision_type": MatchCommandService.UNIT_CHOICE_ENVELOPE, "decision_id": str(decision.get("decision_id", "")), "option_id": str(projected.get("id", "")), "choice": selected}}, six)
func _initialize() -> void: call_deferred("run")
func run() -> void:
 var source_bodyguard_sizes := {"assault-intercessor-squad": 5, "bladeguard-veteran-squad": 3, "company-heroes": 4, "crusader-squad": 10, "decimus-kill-team": 10, "deathwatch-veterans": 5, "desolation-squad": 5, "fortis-kill-team": 10, "hellblaster-squad": 5, "infernus-squad": 5, "inner-circle-companions": 3, "intercessor-squad": 5, "sternguard-veteran-squad": 5, "sword-brethren-squad": 4}
 check(S.BODYGUARDS.apothecary.size() == source_bodyguard_sizes.size(), "Apothecary runtime Support map retains all fourteen current-standard bodyguards")
 for identity: String in S.BODYGUARDS.apothecary:
  var bodyguard_state := current_catalog_bodyguard_fixture(identity, int(source_bodyguard_sizes.get(identity, -1)))
  check(not bodyguard_state.has("error"), "Current Space Marine catalogs admit an Apothecary with %s: %s" % [identity, str(bodyguard_state.get("error", ""))])
  if bodyguard_state.has("error"): continue
  var apothecary_model := -1
  var bodyguard_squad := -1
  var bodyguard_models := 0
  for model: int in bodyguard_state.units:
   var unit: Dictionary = bodyguard_state.units[model]
   if unit.owner != 1: continue
   var identity_in_state := C.UnitAbilities.identity(unit)
   if identity_in_state == "apothecary": apothecary_model = model
   if identity_in_state == identity:
    bodyguard_squad = int(unit.squad)
    bodyguard_models += 1
  var has_models := apothecary_model > 0 and bodyguard_squad > 0
  check(bodyguard_models == int(source_bodyguard_sizes.get(identity, -1)) and has_models and C.UnitActions.attachment_allowed(bodyguard_state, apothecary_model, bodyguard_squad), "The source-linked current-catalog %s bodyguard is eligible for Apothecary" % identity)
  if has_models and C.UnitActions.attachment_allowed(bodyguard_state, apothecary_model, bodyguard_squad): C.UnitActions.attach(bodyguard_state, apothecary_model, bodyguard_squad)
  check(has_models and bodyguard_state.units[apothecary_model].squad == bodyguard_squad and bodyguard_state.units[apothecary_model].attachment_role == "support", "Apothecary attaches to the current-catalog %s bodyguard" % identity)
 var s := fixture()
 check(not s.has("error"), "Apothecary admission failed")
 if s.has("error"):
  print(s)
  quit(1)
  return
 check(s.training_points[1] == 270 and s.units[100].max_wounds == 4, "Apothecary price/profile incorrect")
 check(s.units[100].attachment_role == "support" and s.units[700].squad == 5, "Apothecary/Lieutenant attachment failed")
 check(not C.UnitActions.attachment_allowed(s, 300, 5), "Unsupported third attached Character admitted")
 check(S.matching_error([entry("apothecary"), entry("lieutenant"), entry("intercessor-squad", 5)]).is_empty(), "Pair requires two bodyguards")
 check(not S.matching_error([entry("apothecary"), entry("apothecary"), entry("intercessor-squad", 5)]).is_empty(), "Two Apothecaries share a bodyguard")
 check(C.UnitActions.healing_choices(s, 1).is_empty(), "Healthy unit offered healing")
 s.units[100].wounds = 2
 s.units[500].wounds = 1
 check(choose(s, "narthecium").is_empty(), "Narthecium unavailable")
 check(s.unit_abilities.window.total == 4 and s.units[100].wounds == 2 and s.units[500].wounds == 1, "Healing rolled wrong budget or mutated before confirmation")
 check(choose(s, "heal-wound", 500).is_empty(), "Owner cannot choose wounded survivor")
 check(s.units[500].wounds == 1 and choose(s, "heal-confirm").is_empty(), "Healing did not remain transactional")
 check(s.units[100].wounds == 4 and s.units[500].wounds == 2 and s.unit_abilities.last_healing.restored == 3 and s.unit_abilities.last_healing.discarded == 1, "Healing exceeded max wounds or lost excess accounting")
 check(C.UnitActions.healing_choices(s, 1).is_empty(), "Narthecium repeated this turn")
 s = fixture()
 s.units[100].wounds = 3
 s.units[501].wounds = 0
 s.units[502].wounds = 0
 s.units[300].wounds = 0
 check(choose(s, "narthecium").is_empty() and s.unit_abilities.window.remaining == 3, "Living model not healed before return")
 var before := var_to_str(s)
 check(not choose(s, "heal-revive", 501, s.units[500].position).is_empty() and var_to_str(s) == before, "Overlapping revival changed state")
 check(choose(s, "heal-revive", 501, Vector2(1.7,-8)).is_empty(), "Legal return rejected")
 check(H.projected(s).units[501].wounds == 2 and s.units[501].wounds == 0 and s.unit_abilities.window.remaining == 1, "Returned model not healed before next return")
 check(choose(s, "heal-reset").is_empty() and s.unit_abilities.window.total == 4 and s.unit_abilities.window.remaining == 3, "Reset changed budget or rerolled")
 check(choose(s, "heal-revive", 501, Vector2(1.7,-8)).is_empty() and choose(s, "heal-revive", 502, Vector2(3.4,-8)).is_empty(), "Multiple revival failed")
 check(choose(s, "heal-confirm").is_empty() and s.units[501].wounds == 2 and s.units[502].wounds == 1 and s.units[300].wounds == 0, "Revival confirmation wrong or revived Character")
 s = fixture()
 s.units[500].wounds = 1
 check(C.UnitActions.offer_command_healing(s) and s.unit_abilities.window.kind == "healing-order", "Command healing order absent")
 check(choose(s, "narthecium").is_empty() and choose(s, "heal-confirm").is_empty(), "Mandatory healing order deadlocked")
 s = fixture()
 s.units[500].wounds = 1
 s.squads[5].battle_shocked = true
 check(choose(s, "narthecium").is_empty(), "Battle-shock blocked non-stratagem healing")
 s = fixture()
 s.phase = "shooting"
 check(C.UnitActions.healing_choices(s, 1).is_empty(), "Narthecium outside Command")
 s.phase = "command"
 s.active = 2
 check(C.UnitActions.healing_choices(s, 1).is_empty(), "Narthecium on opponent turn")
 s = fixture()
 s.units[500].wounds = 1
 check(C.advance_phase(s, 1, s.revision, six).is_empty() and s.phase == "command" and s.unit_abilities.window.get("kind", "") == "healing-order", "Command advance skipped useful healing")
 var healing_frame := C.ResolutionFrames.current(s)
 var healing_decision := C.UnitActions.pending_decision(s)
 check(healing_frame.get("kind", "") == "phase-close" and healing_frame.get("status", "") == "suspended" and healing_decision.get("resume_frame_id", "") == healing_frame.get("frame_id", ""), "Command healing carries the persisted phase-close frame")
 var healing_frame_id := str(healing_frame.get("frame_id", ""))
 var before_pending_healing_close := var_to_bytes(s)
 var blocked_healing_close := C.advance_phase(s, 1, s.revision, six)
 check(not blocked_healing_close.is_empty() and var_to_bytes(s) == before_pending_healing_close, "Command close cannot bypass pending normalized Apothecary healing")
 var normalized_heal_order := choose_normalized(s, "narthecium")
 check(str(normalized_heal_order.get("error", "")).is_empty() and s.unit_abilities.window.get("kind", "") == "healing", "The Apothecary starts Command healing through its normalized public choice: " + str(normalized_heal_order.get("error", "")))
 s = bytes_to_var(var_to_bytes(s))
 healing_decision = C.UnitActions.pending_decision(s)
 check(healing_decision.get("resume_frame_id", "") == healing_frame_id and C.ResolutionFrames.current(s).get("frame_id", "") == healing_frame_id, "The Command healing continuation survives save and restore")
 var normalized_heal_confirm := choose_normalized(s, "heal-confirm")
 check(str(normalized_heal_confirm.get("error", "")).is_empty() and s.unit_abilities.window.is_empty(), "The normalized confirmation completes the Apothecary's transactional healing order: " + str(normalized_heal_confirm.get("error", "")))
 var resumed_healing_close := C.advance_phase(s, 1, s.revision, six)
 var opponent_end_pass := {"error": ""}
 for end_choice: Dictionary in C.UnitActions.choices(s, 2):
  if end_choice.action == "pass":
   opponent_end_pass = submit_normalized(s, 2, end_choice)
   break
 check(resumed_healing_close.is_empty() and str(opponent_end_pass.get("error", "")).is_empty() and s.phase == "movement" and C.ResolutionFrames.current(s).is_empty(), "Resuming Command close after the opponent passes their end-phase choices completes the original frame: " + resumed_healing_close + " / " + str(opponent_end_pass.get("error", "")))
 s = fixture()
 for id: int in C.living(s, 2): s.units[id].position = Vector2(0,-11.5)
 var plan := C.AttackPlan.single_target(s, 5, 2, true)
 var own: Array = []
 for row: Dictionary in plan:
  if row.model == 100: own.append(row)
 check(own.size() == 2 and own[0].weapon == "servo-armature" and own[0].amount == 4 and own[1].weapon == "reductor-pistol" and own[1].amount == 1, "Default melee omitted ordinary or Extra Attacks weapon")
 var servo := Equipment.select(s, 100, true, "servo-armature", "standard")
 var reductor := Equipment.select(s, 100, true, "reductor-pistol", "standard")
 var absolvor := Equipment.select(s, 100, false, "absolvor-bolt-pistol", "standard")
 check(servo.get("error", "").is_empty() and servo.stats.get("attacks") == 4 and servo.stats.get("strength") == 5 and servo.stats.get("ap") == 0 and servo.stats.get("damage") == 1, "Servo-armature exposes the exact source profile through Equipment")
 check(reductor.get("error", "").is_empty() and reductor.stats.get("attacks") == 1 and reductor.stats.get("strength") == 5 and reductor.stats.get("ap") == -4 and reductor.stats.get("damage") == 2 and reductor.stats.get("keywords", {}).get("extra-attacks", false), "Reductor Pistol exposes its exact Extra Attacks profile through Equipment")
 check(absolvor.get("error", "").is_empty() and absolvor.stats.get("range_inches") == 18.0 and absolvor.stats.get("attacks") == 1 and absolvor.stats.get("skill") == 3 and absolvor.stats.get("strength") == 5 and absolvor.stats.get("ap") == -2 and absolvor.stats.get("damage") == 2 and absolvor.stats.get("keywords", {}).get("close-quarters", false), "Absolvor Bolt Pistol exposes its exact profile through Equipment")
 s.phase = "shooting"
 s.active = 1
 var pistol_plan: Dictionary = C.AttackPlan.prepare(s, 5, false, [{"model": 100, "target": 2, "amount": 1, "weapon": "absolvor-bolt-pistol", "profile": "standard"}], true)
 check(pistol_plan.get("error", "").is_empty() and pistol_plan.get("batches", []).size() == 1 and pistol_plan.batches[0].weapon.get("strength") == 5 and pistol_plan.batches[0].weapon.get("ap") == -2 and pistol_plan.batches[0].weapon.get("damage") == 2, "Absolvor Bolt Pistol reaches AttackPlan with its source characteristics")
 s.phase = "command"
 check(s.units[100].ranged_weapons.size() == 1 and s.units[100].ranged_weapons[0].id == "absolvor-bolt-pistol" and "EXPLOSIVES" not in s.units[100].keywords, "Apothecary gained ranged Reductor or inferred keyword")
 s = fixture()
 s.units[500].wounds = 1
 check(choose(s, "narthecium").is_empty(), "Healing setup failed")
 var option: Dictionary = C.unit_choices(s, 1).filter(func(row: Dictionary) -> bool: return row.action == "heal-confirm")[0]
 before = var_to_str(s)
 check(not submit_normalized(s, 2, option).is_empty() and var_to_str(s) == before, "Opponent confirmed healing")
 check(not submit_normalized(s, 1, option, Vector2.ZERO, s.revision - 1).is_empty() and var_to_str(s) == before, "Stale healing command accepted")
 check(choose(s, "heal-confirm").is_empty(), "Owner cannot confirm after rejected commands")
 s.turn = 5
 s.units[500].wounds = 1
 check(not C.UnitActions.healing_choices(s, 1).is_empty(), "Narthecium failed to refresh next own turn")
 var only_apothecary: Array[String] = ["apothecary"]
 check(S.compatible(only_apothecary, "lieutenant"), "Reverse Support pair rejected")
 print("Apothecary checks: %d failures" % failures)
 quit(0 if failures == 0 else 1)

