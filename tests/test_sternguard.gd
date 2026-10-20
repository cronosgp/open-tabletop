extends SceneTree
const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const UNIT := "sternguard-veteran-squad"
var failures := 0
func check(ok: bool, message: String) -> void:
 if not ok:
  push_error(message)
  failures += 1
func lists() -> Dictionary:
 var result := F.selections()
 result[1].entries = [
  {"definition_id": "40kdc:11e:adeptus-astartes:captain", "models": 1, "copies": 1},
  {"definition_id": "40kdc:11e:adeptus-astartes:" + UNIT, "models": 5, "copies": 1},
  {"definition_id": "40kdc:11e:adeptus-astartes:" + UNIT, "models": 10, "copies": 1}]
 return result
func fixture() -> Dictionary:
 var s := F.P.initial_state({"checked_rosters": true, "official_mission": true, "unit_abilities": true, "combat_doctrines": true, "reanimation_protocols": true, "awakened_dynasty": true, "core_stratagems": true, "manual_allocation": false}, lists())
 if s.has("error"): return s
 s.awakened_dynasty.pending = []
 s.mission.stage = "battle"
 s.phase = "shooting"
 s.turn = 3
 s.round = 2
 s.active = 1
 s.cp = {1: 3, 2: 3}
 s.unit_abilities.setup_players = [1, 2]
 s.unit_abilities.battle_players = [1, 2]
 s.unit_abilities.window = {}
 s.unit_abilities.phase_key = C.UnitActions.key(s)
 s.terrain.areas = []
 for key in ["attack_rerolls", "save_rerolls", "damage_rerolls", "count_rerolls", "hazard_rerolls"]: s.stratagems[key] = false
 for model: int in s.units: s.units[model].position = Vector2(-20, -12) if s.units[model].owner == 1 else Vector2(20, 12)
 s.units[300].position = Vector2(0, -8)
 place(s, 6)
 return s
func place(s: Dictionary, inches: float) -> void:
 for model: int in C.living(s, 4): s.units[model].position = s.units[300].position + Vector2(inches + s.units[model].radius + s.units[300].radius, 0)
func pick(s: Dictionary, action: String, model: int, value: String) -> Dictionary:
 for row: Dictionary in C.unit_choices(s, 1):
  if row.action == action and row.model == model and row.value == value: return row
 return {}
func equip(s: Dictionary, action: String, model: int, value: String) -> String:
 return C.unit_action(s, 1, pick(s, action, model, value), Vector2.ZERO, s.revision)
func declaration(profile: String = "infernus", model: int = 300, gun: String = "artificer-firearm") -> Array:
 return [{"model": model, "target": 4, "amount": 1, "weapon": gun, "profile": profile}]
func _initialize() -> void: call_deferred("run")
func run() -> void:
 var s := fixture()
 check(not s.has("error"), "Sternguard profile failed admission")
 if s.has("error"):
  print(s)
  quit(1)
  return
 check(s.training_points[1] == 405 and C.living(s, 3).size() == 5 and C.living(s, 5).size() == 10, "5/10 models or current prices incorrect")
 check(s.units[300].melee_weapons[0].id == "chainsword" and s.units[301].melee_weapons[0].id == "ceramite-fists", "Sergeant and trooper default melee were merged")
 check("DEATHWING" not in s.units[300].keywords and s.units[300].radius == 16.0 / 25.4, "Shared profile gained chapter keyword or wrong base")
 check(C.UnitActions.attachment_allowed(s, 100, 3), "Reviewed Captain bodyguard link omitted")
 var prepared := C.AttackPlan.prepare(s, 3, false, declaration(), true)
 check(prepared.error.is_empty() and prepared.batches[0].count == 4 and prepared.batches[0].context.hit_reroll == "ones", "Infernus Rapid Fire 2 or Veteran Marksmen context missing")
 var purgatus := C.AttackPlan.prepare(s, 3, false, declaration("purgatus"), true)
 check(purgatus.error.is_empty() and purgatus.batches[0].count == 2 and purgatus.batches[0].weapon.strength == 7 and purgatus.batches[0].weapon.damage == 2, "Purgatus profile incorrect")
 var damnatus := C.AttackPlan.prepare(s, 3, false, declaration("damnatus"), true)
 check(damnatus.error.is_empty() and damnatus.batches[0].weapon.damage == "D3+4", "Damnatus half-range Melta failed")
 place(s, 6.02)
 damnatus = C.AttackPlan.prepare(s, 3, false, declaration("damnatus"), true)
 check(damnatus.error.is_empty() and damnatus.batches[0].weapon.damage == "D3+2", "Damnatus gained Melta beyond half range")
 s.squads[3].advanced = true
 check(4 in C.AttackPlan.legal_targets(s, 300, false, "artificer-firearm", "infernus") and 4 in C.AttackPlan.legal_targets(s, 300, false, "artificer-firearm", "damnatus"), "Artificer Assault profiles unavailable after Advance")
 s.squads[3].advanced = false
 # Actual hit replacement consumes one replacement per 1, never a second re-roll.
 var gun: Dictionary = purgatus.batches[0].weapon.duplicate(true)
 gun.attacks = 1
 var target := {"toughness": 4, "save_target": 4, "wounds_per_model": 1, "remaining_wounds": [1]}
 var dice: Array = [1, 4, 1]
 var resolved := C.Attacks.resolve(gun, target, {"weapon_count": 1, "hit_reroll": "ones"}, func() -> int: return dice.pop_front())
 check(resolved.error.is_empty() and resolved.hits == 1 and dice.is_empty(), "Veteran hit reroll was not resolved")
 dice = [1, 1]
 resolved = C.Attacks.resolve(gun, target, {"weapon_count": 1, "hit_reroll": "ones"}, func() -> int: return dice.pop_front())
 check(resolved.error.is_empty() and resolved.hits == 0 and dice.is_empty(), "A replacement 1 was re-rolled again")
 s = fixture()
 # Snap shooting forbids the otherwise active unit hit re-roll.
 s.phase = "movement"
 s.active = 2
 s.core_reactions.overwatch = {"phase_key": C.CoreReactions.phase_key(s), "squad": 3, "player": 1}
 prepared = C.AttackPlan.prepare(s, 3, false, declaration(), true)
 check(prepared.error.is_empty() and prepared.batches[0].context.get("hit_reroll", "none") == "none" and prepared.batches[0].context.snap_shooting, "Veteran Marksmen bypassed Snap Shooting prohibition")
 s = fixture()
 s.phase = "deployment"
 s.unit_abilities.setup_players = []
 check(pick(s, "sternguard-gun", 300, "heavy").is_empty(), "Sergeant gained trooper-only heavy weapon")
 check(equip(s, "sternguard-gun", 301, "heavy").is_empty() and s.units[301].ranged_weapons[0].id == "heavy-bolter", "Trooper Heavy Bolter replacement failed")
 check(pick(s, "sternguard-gun", 302, "pyre").is_empty(), "Five-model unit allowed second special weapon")
 check(equip(s, "sternguard-gun", 301, "pyre").is_empty() and s.units[301].ranged_weapons[0].id == "pyrecannon", "Existing replacement could not change type at the cap")
 check(equip(s, "sternguard-gun", 501, "heavy").is_empty() and equip(s, "sternguard-gun", 502, "pyre").is_empty() and pick(s, "sternguard-gun", 503, "heavy").is_empty(), "Ten-model special weapon cap incorrect")
 check(equip(s, "sternguard-melee", 300, "fist").is_empty() and s.units[300].melee_weapons[0].profiles.standard.strength == 8, "Sergeant Power Fist option failed")
 check(equip(s, "sternguard-melee", 300, "power").is_empty() and s.units[300].melee_weapons[0].profiles.standard.attacks == 5, "Sergeant Power Weapon option failed")
 check(pick(s, "sternguard-melee", 301, "fist").is_empty(), "Trooper gained Sergeant melee option")
 check(equip(s, "sternguard-gun", 301, "firearm").is_empty() and not pick(s, "sternguard-gun", 302, "pyre").is_empty(), "Reversing replacement did not restore capacity")
 check(equip(s, "sternguard-gun", 301, "pyre").is_empty(), "Pyrecannon re-equip failed")
 s.phase = "shooting"
 s.unit_abilities.setup_players = [1, 2]
 s.units[301].position = s.units[300].position
 prepared = C.AttackPlan.prepare(s, 3, false, declaration("standard", 301, "pyrecannon"), true)
 check(prepared.error.is_empty() and prepared.batches[0].count == 8 and prepared.batches[0].weapon.keywords.torrent, "Pyrecannon Blast 2 against ten models incorrect")
 for model: int in C.living(s, 3): s.units[model].wounds = 0
 check(not C.UnitAbilities.has(s, 3, "veteran-marksmen"), "Destroyed unit retained ability source")
 var invalid := lists()
 invalid[1].entries.append({"definition_id": "40kdc:11e:adeptus-astartes:" + UNIT, "models": 5, "copies": 1})
 check(not C.RosterValidation.admit(invalid[1]).error.is_empty(), "5/10 entries bypassed shared datasheet repetition cap")
 var catalog := F.P.Training.Capabilities.current_catalog_choice({"id": "openhammer:11e:Space%20Marines:907f-11-c4d1-ec21", "edition": "11e", "faction": "Space Marines"})
 check(catalog.get("options", []) == [{"models": 5, "cost": 105}, {"models": 10, "cost": 210}], "Catalog retained superseded API sizes/prices")
 print("Sternguard checks: %d failures" % failures)
 quit(1 if failures else 0)
