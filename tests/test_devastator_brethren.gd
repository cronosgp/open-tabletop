extends SceneTree
const F = preload("res://tests/all_units_fixture.gd")
const P = F.P
const C = F.C
const D = C.DetachmentStratagems
const Enhancements = preload("res://scripts/edition_11/stormlance_enhancements.gd")
const Army = preload("res://scripts/edition_11/army_capabilities.gd")
var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func prepared(enhancement_id: String = "") -> Dictionary:
	var selections := F.selections()
	if not enhancement_id.is_empty(): selections[1].entries[1].enhancement_id = enhancement_id
	var s := P.initial_state({"unit_abilities": true, "reanimation_protocols": true, "combat_doctrines": true, "awakened_dynasty": true, "core_stratagems": true, "marine_detachment": Enhancements.DEVASTATOR_BRETHREN}, selections)
	if s.has("error"): return s
	s.terrain.areas = []
	s.unit_abilities.setup_players = [1, 2]
	s.unit_abilities.battle_players = [1, 2]
	s.awakened_dynasty.setup_done = true
	s.awakened_dynasty.pending = []
	s.deployment.complete = true
	s.mission.stage = "battle"
	s.phase = "command"
	s.active = 1
	s.turn = 3
	s.round = 2
	s.unit_abilities.phase_key = C.UnitActions.key(s)
	s.cp = {1: 3, 2: 3}
	return s

func roster(source: String, enhancement_id: String) -> Dictionary:
	return {"schema_version": 2, "faction": "Space Marines", "category": "training", "points_limit": 500,
		"entries": [{"definition_id": "40kdc:11e:adeptus-astartes:" + source, "models": 1, "copies": 1, "enhancement_id": enhancement_id}]}

func choice_for(s: Dictionary, player: int, value: String, target: int = -1) -> Dictionary:
	for choice: Dictionary in D.choices(s, player):
		if str(choice.get("value", "")) == value and (target < 0 or int(choice.get("target", -1)) == target): return choice
	return {}

func _initialize() -> void:
	var captain := "40kdc:11e:adeptus-astartes:captain"
	check(Enhancements.valid_for(captain, Enhancements.MASTER_FORGED_FIREARMS, Enhancements.DEVASTATOR_BRETHREN), "Master-forged Firearms matches the Captain source eligibility row")
	check(Enhancements.valid_for(captain, Enhancements.HONOUR_OF_VIGILANCE, Enhancements.DEVASTATOR_BRETHREN), "Honour of Vigilance matches the Captain source eligibility row")
	var firearm_admission: Dictionary = Army.admit(roster("captain", Enhancements.MASTER_FORGED_FIREARMS))
	var honour_admission: Dictionary = Army.admit(roster("captain", Enhancements.HONOUR_OF_VIGILANCE))
	check(firearm_admission.get("error", "").is_empty() and firearm_admission.total == 105, "Master-forged Firearms adds its 15-point local cost")
	check(honour_admission.get("error", "").is_empty() and honour_admission.total == 110, "Honour of Vigilance adds its 20-point local cost")

	var s := prepared(Enhancements.MASTER_FORGED_FIREARMS)
	check(not s.has("error") and s.units[300].get("enhancement_id", "") == Enhancements.MASTER_FORGED_FIREARMS, "Master-forged Firearms is assigned to the eligible bearer in prepared match state")
	var weapon := {"attacks": "D6", "strength": 4, "ap": -1, "damage": "D3", "keywords": {"psychic": false}}
	var improved := C.AttackPlan._enhancement_weapon(s, 300, weapon, false)
	check(improved.attacks == "D6+1" and improved.strength == 5 and improved.ap == -2 and improved.damage == "D3+1", "Master-forged Firearms improves ranged A, S, AP and D by one")
	var psychic := weapon.duplicate(true)
	psychic.keywords.psychic = true
	var psychic_result := C.AttackPlan._enhancement_weapon(s, 300, psychic, false)
	check(psychic_result == psychic, "Master-forged Firearms excludes Psychic attacks")

	s = prepared(Enhancements.HONOUR_OF_VIGILANCE)
	s.combat_doctrines.active[1] = "devastator"
	var honour_weapon := C.AttackPlan._enhancement_weapon(s, 300, weapon, false)
	check(honour_weapon.keywords.get("lethal-hits", false), "Honour of Vigilance grants Lethal Hits to its unit's ranged attacks")
	s.phase = "movement"
	var opened := C.Stratagems.open_roll(s, 1, 3, "after_advance_roll", [2], {"squad": 3, "move_type": "advance", "bonus": 2})
	check(opened and C.Stratagems.pending(s).get("honour_vigilance", false), "Honour of Vigilance opens an Advance re-roll while Devastator Doctrine is active")
	var before_cp := int(s.cp[1])
	var reroll_error := C.resolve_roll_reaction(s, 1, 3, "honour-of-vigilance", s.revision, func() -> int: return 5)
	check(reroll_error.is_empty() and int(s.pending_move.bonus) == 5 and int(s.cp[1]) == before_cp, "Honour of Vigilance replaces the Advance die without spending CP")

	s = prepared()
	s.phase = "shooting"
	s.combat_doctrines.active[1] = "devastator"
	var storm := choice_for(s, 1, D.STORM_OF_FIRE, 1)
	var storm_result := D.apply(s, 1, storm)
	var profile := {"attacks": 2, "strength": 4, "ap": -1, "damage": 1, "keywords": {}}
	var storm_profile := D.weapon(s, 1, profile, profile, false)
	check(storm_result.get("error", "").is_empty() and storm_profile.keywords.get("ignores-cover", false) and storm_profile.ap == -2, "Storm of Fire grants Ignores Cover and +1 AP with Devastator Doctrine")
	s = prepared()
	s.phase = "shooting"
	storm = choice_for(s, 1, D.STORM_OF_FIRE, 1)
	storm_result = D.apply(s, 1, storm)
	storm_profile = D.weapon(s, 1, profile, profile, false)
	check(storm_result.get("error", "").is_empty() and storm_profile.keywords.get("ignores-cover", false) and storm_profile.ap == -1, "Storm of Fire grants Ignores Cover without the doctrine AP bonus")

	s = prepared()
	s.phase = "shooting"
	s.active = 2
	s.units[100].wounds = 0
	D.after_attacks(s, 2, [1], 1, {}, {})
	var pending_hail: Dictionary = s.detachment_stratagems.get("hail_of_vengeance_pending", {})
	var hail := choice_for(s, 1, D.HAIL_OF_VENGEANCE, 1)
	var hail_result := D.apply(s, 1, hail)
	check(pending_hail.get("victims", []).has(1) and hail_result.get("error", "").is_empty() and s.cp[1] == 1, "Hail of Vengeance is offered after a model is destroyed and costs 2 CP")
	check(D.vengeful_actor(s) == 1 and D.vengeful_shooter(s, 1) and int(s.detachment_stratagems.hail_of_vengeance.attacker) == 2, "Hail of Vengeance opens shooting for the damaged unit, bound to the enemy shooter")
	check(D.reactive_shooting_target(s, 1) == 2, "Hail of Vengeance exposes its attacker as the only legal reaction-shot target")
	var hail_attack_error := C.attack_window_error(s, 1, 101, s.revision, false)
	check(hail_attack_error.is_empty(), "Hail of Vengeance lets the damaged unit shoot during the opponent's Shooting phase")

	s = prepared()
	s.phase = "shooting"
	s.active = 2
	s.unit_abilities.window = {"kind": D.ARMOUR_WINDOW, "owners": [1], "squad": 1, "attacker_squad": 2, "declaration": {"player": 2, "squad": 2, "entries": [{"target": 1}]}}
	var armour_error := D.use_armour(s, 1, 1, 2)
	check(armour_error.is_empty() and s.cp[1] == 2 and s.stratagems.uses.back().stratagem == D.DEVASTATOR_ARMOUR, "Devastator Brethren Armour of Contempt spends 1 CP and retains its source-card identity")
	print("Devastator Brethren checks: %d failures" % failures)
	quit(1 if failures else 0)
