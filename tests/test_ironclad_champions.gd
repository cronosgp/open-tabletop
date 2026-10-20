extends SceneTree
const F = preload("res://tests/all_units_fixture.gd")
const P = F.P
const C = F.C
const D = C.DetachmentStratagems
const Doctrines = preload("res://scripts/edition_11/combat_doctrines.gd")
const Enhancements = preload("res://scripts/edition_11/stormlance_enhancements.gd")
const Terrain = preload("res://scripts/edition_11/terrain.gd")
const Army = preload("res://scripts/edition_11/army_capabilities.gd")
var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func prepared(enhancement_id: String = "") -> Dictionary:
	var selections := F.selections()
	for entry: Dictionary in selections[1].entries:
		if str(entry.definition_id).ends_with(":assault-intercessor-squad"):
			entry.definition_id = "40kdc:11e:adeptus-astartes:redemptor-dreadnought"
			entry.models = 1
			if not enhancement_id.is_empty(): entry.enhancement_id = enhancement_id
	var s := P.initial_state({"unit_abilities": true, "reanimation_protocols": true, "combat_doctrines": true, "awakened_dynasty": true, "core_stratagems": true, "marine_detachment": "ironclad-champions"}, selections)
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

func squad_for(s: Dictionary, owner: int, identity: String = "") -> int:
	for model: int in s.units:
		var unit: Dictionary = s.units[model]
		if int(unit.owner) == owner and int(unit.wounds) > 0 and (identity.is_empty() or str(unit.definition_id).ends_with(":" + identity)):
			return int(unit.squad)
	return -1

func model_for(s: Dictionary, squad: int) -> int:
	for model: int in s.units:
		if int(s.units[model].squad) == squad and int(s.units[model].wounds) > 0: return model
	return -1

func choice_for(s: Dictionary, player: int, value: String, target: int, mode: String = "") -> Dictionary:
	for choice: Dictionary in D.choices(s, player):
		if str(choice.get("value", "")) == value and int(choice.get("target", -1)) == target and (mode.is_empty() or str(choice.get("mode", "")) == mode): return choice
	return {}

func _initialize() -> void:
	var dreadnought := "40kdc:11e:adeptus-astartes:redemptor-dreadnought"
	check(Enhancements.valid_for(dreadnought, Enhancements.ARTIFICER_SARCOPHAGUS, Enhancements.IRONCLAD), "Artificer Sarcophagus is eligible for the local Redemptor Dreadnought profile")
	check(Enhancements.valid_for(dreadnought, Enhancements.VENERABLE_CHAMPION, Enhancements.IRONCLAD), "Venerable Champion is eligible for the local Redemptor Dreadnought profile")
	var art_roster := {"schema_version": 2, "faction": "Space Marines", "category": "training", "points_limit": 500, "entries": [{"definition_id": dreadnought, "models": 1, "copies": 1, "enhancement_id": Enhancements.ARTIFICER_SARCOPHAGUS}]}
	var aura_roster := art_roster.duplicate(true)
	aura_roster.entries[0].enhancement_id = Enhancements.VENERABLE_CHAMPION
	var art_admission: Dictionary = Army.admit(art_roster)
	var aura_admission: Dictionary = Army.admit(aura_roster)
	check(art_admission.get("error", "").is_empty() and art_admission.total == 210, "Artificer Sarcophagus uses its 40-point local cost: %s" % str(art_admission))
	check(aura_admission.get("error", "").is_empty() and aura_admission.total == 200, "Venerable Champion uses its 30-point local cost: %s" % str(aura_admission))

	var s := prepared(Enhancements.ARTIFICER_SARCOPHAGUS)
	var dread_squad := squad_for(s, 1, "redemptor-dreadnought")
	var dread_model := model_for(s, dread_squad)
	check(not s.has("error") and dread_squad >= 0 and Doctrines.enduring_vengeance(s, dread_squad), "Ironclad Champions admits Enduring Vengeance for its living Astartes Dreadnought")
	check(C.UnitAbilities.damage(s, dread_model, 3) == 2 and C.UnitAbilities.damage(s, dread_model, 1) == 1, "Artificer Sarcophagus reduces incoming damage by 1 to a minimum of 1")
	check(not Doctrines.enduring_vengeance(s, squad_for(s, 1, "intercessor-squad")), "Enduring Vengeance excludes ordinary non-Dreadnought Astartes")
	var enemy_squad := squad_for(s, 2)
	var enemy_model := model_for(s, enemy_squad)
	s.units[dread_model].position = Vector2(10.0, 0.0)
	s.units[enemy_model].position = Vector2.ZERO
	s.units[dread_model].ranged_weapons = [{"id": "enduring-test", "profiles": {"standard": {"name": "Test Cannon", "range_inches": 48.0, "attacks": 1, "skill": 3, "strength": 10, "ap": -1, "damage": 1, "keywords": {}}}}]
	s.phase = "shooting"
	var enduring_plan: Dictionary = C.AttackPlan.prepare(s, dread_squad, false, [{"model": dread_model, "target": enemy_squad, "amount": 1, "weapon": "enduring-test", "profile": "standard"}], true)
	check(enduring_plan.get("error", "").is_empty() and enduring_plan.batches.size() == 1 and enduring_plan.batches[0].context.hit_reroll == "ones", "Enduring Vengeance supplies hit re-rolls of 1 in the normal shooting attack plan")

	var mercy := D.MERCY_IS_WEAKNESS
	s.phase = "shooting"
	var lethal_choice := choice_for(s, 1, mercy, dread_squad, "lethal")
	var lethal_result := D.apply(s, 1, lethal_choice)
	var base_weapon := {"attacks": 2, "strength": 9, "ap": -1, "damage": 2, "keywords": {"sustained-hits": 2}}
	var lethal_weapon: Dictionary = D.weapon(s, dread_squad, base_weapon, base_weapon, false)
	check(lethal_result.get("error", "").is_empty() and lethal_weapon.keywords.get("lethal-hits", false) and lethal_weapon.keywords.get("sustained-hits", 0) == 2 and s.cp[1] == 2, "Mercy is Weakness grants Lethal Hits for the phase, preserves existing traits and costs 1 CP")
	var other := prepared()
	dread_squad = squad_for(other, 1, "redemptor-dreadnought")
	other.phase = "shooting"
	var sustained_choice := choice_for(other, 1, mercy, dread_squad, "sustained")
	var sustained_result := D.apply(other, 1, sustained_choice)
	var sustained_weapon: Dictionary = D.weapon(other, dread_squad, base_weapon, base_weapon, true)
	check(sustained_result.get("error", "").is_empty() and sustained_weapon.keywords.get("sustained-hits", 0) == 2 and not sustained_weapon.keywords.get("lethal-hits", false), "Mercy is Weakness grants Sustained Hits 1 without replacing a stronger existing value")

	s = prepared()
	dread_squad = squad_for(s, 1, "redemptor-dreadnought")
	enemy_squad = squad_for(s, 2)
	var dread_unit := model_for(s, dread_squad)
	var enemy_unit := model_for(s, enemy_squad)
	s.units[dread_unit].position = Vector2.ZERO
	s.units[enemy_unit].position = Vector2(1.0, 0.0)
	s.phase = "fight"
	s.unit_abilities.window = {"kind": "start", "owners": [1]}
	var terror_choice := choice_for(s, 1, D.ADAMANTINE_TERROR, dread_squad)
	var terror_result := D.apply(s, 1, terror_choice, func() -> int: return 2)
	var terror_roll: Dictionary = s.get("last_adamantine_terror", [{}])[0]
	check(terror_result.get("error", "").is_empty() and D.adamantine_targets(s, dread_squad) == [enemy_squad], "Adamantine Terror only tests enemy units engaged with the selected Dreadnought")
	check(int(terror_roll.get("modifier", 0)) == -1 and not terror_roll.get("passed", true) and s.squads[enemy_squad].battle_shocked and s.cp[1] == 2, "Adamantine Terror applies -1 to the Battle-shock roll and marks a failed target")

	s = prepared()
	dread_squad = squad_for(s, 1, "redemptor-dreadnought")
	dread_unit = model_for(s, dread_squad)
	s.phase = "movement"
	s.unit_abilities.window = {"kind": D.UNSTOPPABLE_WINDOW, "owners": [1], "squad": dread_squad, "trigger": "movement", "action": "movement", "model": dread_unit, "move_type": "normal"}
	var advance_choice := choice_for(s, 1, D.UNSTOPPABLE_ADVANCE, dread_squad)
	var advance_result := D.apply(s, 1, advance_choice)
	check(advance_result.get("error", "").is_empty() and advance_result.has("resume_mobile_declaration") and D.mobile_active(s, dread_squad) and Terrain.mobile_unit(s, dread_unit) and s.cp[1] == 2, "Unstoppable Advance grants Mobile for the declaration and resumes the selected move")

	s = prepared(Enhancements.VENERABLE_CHAMPION)
	dread_squad = squad_for(s, 1, "redemptor-dreadnought")
	var infantry_squad := squad_for(s, 1, "intercessor-squad")
	dread_unit = model_for(s, dread_squad)
	var infantry_model := model_for(s, infantry_squad)
	enemy_squad = squad_for(s, 2)
	enemy_model = model_for(s, enemy_squad)
	s.units[dread_unit].position = Vector2.ZERO
	s.units[infantry_model].position = Vector2(3.0, 0.0)
	s.units[enemy_model].position = Vector2(15.0, 0.0)
	for model: int in s.units:
		if int(s.units[model].squad) == infantry_squad and model != infantry_model: s.units[model].wounds = 0
	s.units[infantry_model].ranged_weapons = [{"id": "aura-test", "profiles": {"standard": {"name": "Test Rifle", "range_inches": 48.0, "attacks": 1, "skill": 3, "strength": 4, "ap": 0, "damage": 1, "keywords": {}}}}]
	check(Enhancements.venerable_hit_reroll(s, infantry_squad), "Venerable Champion grants its aura within 6 inches to friendly Astartes Infantry")
	s.phase = "shooting"
	var aura_plan: Dictionary = C.AttackPlan.prepare(s, infantry_squad, false, [{"model": infantry_model, "target": enemy_squad, "amount": 1, "weapon": "aura-test", "profile": "standard"}], true)
	check(aura_plan.get("error", "").is_empty() and aura_plan.batches.size() == 1 and aura_plan.batches[0].context.hit_reroll == "ones", "Venerable Champion reroll enters a friendly Infantry attack plan within its aura")
	s.units[infantry_model].position = Vector2(10.0, 0.0)
	check(not Enhancements.venerable_hit_reroll(s, infantry_squad), "Venerable Champion aura ends beyond 6 inches")
	print("Ironclad Champions checks: %d failures" % failures)
	quit(1 if failures else 0)
