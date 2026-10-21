extends SceneTree
const F = preload("res://tests/all_units_fixture.gd")
const P = F.P
const C = F.C
const D = C.DetachmentStratagems
const Army = preload("res://scripts/edition_11/army_capabilities.gd")
const Enhancements = preload("res://scripts/edition_11/stormlance_enhancements.gd")
var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func fixture() -> Dictionary:
	var s := P.initial_state({"unit_abilities": true, "reanimation_protocols": true, "combat_doctrines": true, "awakened_dynasty": true, "core_stratagems": true, "attack_rerolls": true, "manual_allocation": false}, F.selections())
	s.terrain.areas = []
	s.unit_abilities.setup_players = [1, 2]
	s.unit_abilities.battle_players = [1, 2]
	s.deployment.complete = true
	s.mission.stage = "battle"
	s.phase = "command"
	s.active = 1
	s.turn = 3
	s.round = 2
	s.unit_abilities.phase_key = C.UnitActions.key(s)
	s.cp = {1: 3, 2: 3}
	C.Doctrines.enable(s, "tactical-brethren")
	D.enable_tactical_brethren(s)
	return s

func roster(source: String, enhancement_id: String) -> Dictionary:
	return {"schema_version": 2, "faction": "Space Marines", "category": "training", "points_limit": 500,
		"entries": [{"definition_id": "40kdc:11e:adeptus-astartes:" + source, "models": 1, "copies": 1, "enhancement_id": enhancement_id}]}

func choice_for(s: Dictionary, player: int, value: String, target: int = -1) -> Dictionary:
	for choice: Dictionary in D.choices(s, player):
		if str(choice.get("value", "")) == value and (target < 0 or int(choice.get("target", -1)) == target): return choice
	return {}

func _initialize() -> void:
	var captain_id := "40kdc:11e:adeptus-astartes:captain"
	var captain := "40kdc:11e:adeptus-astartes:captain"
	check(Enhancements.valid_for(captain, Enhancements.TACTICAL_INSIGHT, Enhancements.TACTICAL_BRETHREN), "Tactical Insight is eligible for the Captain datasheet in the export")
	check(Enhancements.valid_for(captain, Enhancements.LAURELS_OF_VIGILANCE, Enhancements.TACTICAL_BRETHREN), "Laurels of Vigilance is eligible for an Astartes model on an exported datasheet")
	var laurels_admission: Dictionary = Army.admit(roster("captain", Enhancements.LAURELS_OF_VIGILANCE))
	var insight_admission: Dictionary = Army.admit(roster("captain", Enhancements.TACTICAL_INSIGHT))
	check(laurels_admission.get("error", "").is_empty() and laurels_admission.total == 100, "Laurels of Vigilance adds its 10-point local cost")
	check(insight_admission.get("error", "").is_empty() and insight_admission.total == 105, "Tactical Insight adds its 15-point local cost")
	var selected := F.selections()
	selected[1].entries[1].enhancement_id = Enhancements.TACTICAL_INSIGHT
	var prepared := P.initial_state({"unit_abilities": true, "reanimation_protocols": true, "combat_doctrines": true, "awakened_dynasty": true, "core_stratagems": true, "marine_detachment": Enhancements.TACTICAL_BRETHREN}, selected)
	check(not prepared.has("error") and prepared.units[300].get("enhancement_id", "") == Enhancements.TACTICAL_INSIGHT and C.Doctrines.has_doctrine(prepared, 3, "tactical"), "Tactical Insight assignment materializes in a prepared Tactical Brethren match")

	var s := fixture()
	s.units[100].definition_id = captain_id
	s.units[100].keywords = ["ADEPTUS ASTARTES", "INFANTRY", "CAPTAIN"]
	s.units[100].enhancement_id = Enhancements.TACTICAL_INSIGHT
	s.squads[1].enhancement_id = Enhancements.TACTICAL_INSIGHT
	s.combat_doctrines.active[1] = "assault"
	check(C.Doctrines.has_doctrine(s, 1, "assault") and C.Doctrines.has_doctrine(s, 1, "tactical"), "Tactical Insight adds Tactical Doctrine alongside Assault Doctrine")

	s = fixture()
	check(not Enhancements.active(s, 1, Enhancements.TACTICAL_INSIGHT) and not C.Doctrines.has_doctrine(s, 1, "tactical"), "Source-restricted Tactical Insight does not affect a unit when no eligible bearer has it assigned")
	s.phase = "movement"
	s.active = 2
	s.combat_doctrines.active.erase(1)
	for model: int in s.units:
		if int(s.units[model].squad) == 1: s.units[model].keywords = ["ADEPTUS ASTARTES", "INFANTRY"]
		if int(s.units[model].squad) == 1: s.units[model].position = Vector2.ZERO
		if int(s.units[model].squad) == 2: s.units[model].position = Vector2(8.0, 0.0)
	D.record_move(s, 2)
	check(not C.Doctrines.has_doctrine(s, 1, "tactical"), "Tactical Brethren's additional use does not activate Tactical Doctrine by itself")
	var masterful := choice_for(s, 1, D.MASTERFUL_TACTICS, 1)
	var masterful_result := D.apply(s, 1, masterful, func() -> int: return 4)
	check(masterful_result.get("error", "").is_empty() and int(s.detachment_stratagems.tactics[1].inches) == 4, "Masterful Tactics uses its D6 Normal Move when Tactical Doctrine is inactive")
	s = fixture()
	s.phase = "movement"
	s.active = 2
	for model: int in s.units:
		if int(s.units[model].squad) == 1: s.units[model].keywords = ["ADEPTUS ASTARTES", "INFANTRY"]
		if int(s.units[model].squad) == 1: s.units[model].position = Vector2.ZERO
		if int(s.units[model].squad) == 2: s.units[model].position = Vector2(8.0, 0.0)
	D.record_move(s, 2)
	s.combat_doctrines.active[1] = "tactical"
	masterful = choice_for(s, 1, D.MASTERFUL_TACTICS, 1)
	masterful_result = D.apply(s, 1, masterful)
	check(masterful_result.get("error", "").is_empty() and int(s.detachment_stratagems.tactics[1].inches) == 6, "Tactical Doctrine makes Masterful Tactics a fixed 6-inch Normal Move")

	s = fixture()
	s.phase = "shooting"
	s.active = 2
	s.unit_abilities.phase_key = C.UnitActions.key(s)
	s.unit_abilities.window = {"kind": D.ARMOUR_WINDOW, "owners": [1], "squad": 1, "attacker_squad": 2, "declaration": {"player": 2, "squad": 2, "entries": [{"target": 1}]}}
	var armour_error := D.use_armour(s, 1, 1, 2)
	check(armour_error.is_empty() and s.cp[1] == 2 and s.stratagems.uses.back().stratagem == D.TACTICAL_ARMOUR, "Tactical Brethren Armour of Contempt uses the source card identity and binds the attacker")

	s = fixture()
	s.phase = "shooting"
	s.active = 1
	s.squads[1].shot = true
	D.after_attacks(s, 1, [2], 0, {"batches": [{"target": 2}]}, {"pools": [{"hits": 2}]})
	var domination := choice_for(s, 1, D.DOMINATION_FIRE, 1)
	check(not domination.is_empty() and int(domination.get("enemy_target", -1)) == 2, "Domination Fire is offered only after the unit hit an eligible enemy")
	var domination_result := D.apply(s, 1, domination)
	check(domination_result.get("error", "").is_empty() and s.cp[1] == 2 and D.suppression_hit_modifier(s, 2) == -1, "Domination Fire suppresses the chosen hit unit with -1 to Hit")
	s.turn += 2
	check(D.suppression_hit_modifier(s, 2) == 0, "Suppression ends at the start of the shooter's next turn")

	s = fixture()
	s.units[100].definition_id = captain_id
	s.units[100].keywords = ["ADEPTUS ASTARTES", "INFANTRY", "CAPTAIN"]
	s.units[100].enhancement_id = Enhancements.LAURELS_OF_VIGILANCE
	s.units[100].position = Vector2.ZERO
	s.squads[1].enhancement_id = Enhancements.LAURELS_OF_VIGILANCE
	s.squads[900] = s.squads[1].duplicate(true)
	s.squads[900].owner = 1
	s.units[900] = {"squad": 900, "owner": 1, "wounds": 1, "max_wounds": 1, "on_battlefield": true, "keywords": ["ADEPTUS ASTARTES", "BATTLELINE", "INFANTRY"], "position": Vector2(11.0, 0.0), "radius": 0.5}
	var discount := Enhancements.laurels_vigilance_discount(s, 1, 900, "fire-overwatch")
	check(discount == 1, "Laurels of Vigilance discounts an eligible Battleline target within 12 inches")
	Enhancements.consume_laurels_vigilance(s, 1)
	check(Enhancements.laurels_vigilance_discount(s, 1, 900, "heroic-intervention") == 0, "Laurels of Vigilance is once per battle round per army across both stratagems")
	print("Tactical Brethren checks: %d failures" % failures)
	quit(1 if failures else 0)
