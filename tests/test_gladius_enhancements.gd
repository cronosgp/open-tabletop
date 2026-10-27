extends SceneTree
const F = preload("res://tests/all_units_fixture.gd")
const P = F.P
const C = F.C
const Enhancements = preload("res://scripts/edition_11/stormlance_enhancements.gd")
const Doctrines = preload("res://scripts/edition_11/combat_doctrines.gd")
const Army = preload("res://scripts/edition_11/army_capabilities.gd")
const Prevention = preload("res://scripts/edition_11/unit_prevention.gd")
const WoundPrevention = preload("res://scripts/edition_11/wound_prevention.gd")
const DefenderGroups = preload("res://scripts/edition_11/defender_groups.gd")
const MatchCommands = preload("res://scripts/edition_11/match_command_service.gd")
var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func roster_entry(source: String, models: int = 1, enhancement_id: String = "") -> Dictionary:
	var entry := {"definition_id": "40kdc:11e:adeptus-astartes:" + source, "models": models, "copies": 1}
	if not enhancement_id.is_empty(): entry.enhancement_id = enhancement_id
	return entry

func prepared(enhancement_id: String = "", source: String = "captain") -> Dictionary:
	var selections := F.selections()
	if source == "ancient":
		selections[1].entries = [roster_entry("ancient", 1, enhancement_id), roster_entry("intercessor-squad", 5)]
	else:
		for entry: Dictionary in selections[1].entries:
			if str(entry.definition_id).ends_with(":" + source): entry.enhancement_id = enhancement_id
	var s := P.initial_state({"unit_abilities": true, "reanimation_protocols": true, "combat_doctrines": true, "awakened_dynasty": true, "core_stratagems": true, "marine_detachment": Enhancements.GLADIUS}, selections)
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

func model_for(s: Dictionary, source: String, owner: int = 1) -> int:
	for model: int in s.units:
		var unit: Dictionary = s.units[model]
		if int(unit.owner) == owner and int(unit.wounds) > 0 and str(unit.definition_id).ends_with(":" + source): return model
	return -1

func _initialize() -> void:
	var captain := "40kdc:11e:adeptus-astartes:captain"
	var ancient := "40kdc:11e:adeptus-astartes:ancient"
	check(Enhancements.valid_for(captain, Enhancements.ADEPT_OF_THE_CODEX, Enhancements.GLADIUS), "Adept of the Codex accepts an eligible Captain")
	check(not Enhancements.valid_for("40kdc:11e:adeptus-astartes:captain-titus", Enhancements.ADEPT_OF_THE_CODEX, Enhancements.GLADIUS), "Adept of the Codex rejects an Epic Hero")
	check(Enhancements.valid_for(captain, Enhancements.ARTIFICER_ARMOUR, Enhancements.GLADIUS) and Enhancements.valid_for(captain, Enhancements.LAURELS_OF_TRIUMPH, Enhancements.GLADIUS), "Artificer Armour and Laurels of Triumph accept the eligible Captain")
	check(Enhancements.valid_for(ancient, Enhancements.STANDARD_OF_THE_EMPEROR_ASCENDANT, Enhancements.GLADIUS), "Standard of the Emperor Ascendant accepts the local Ancient profile")
	check(not Enhancements.valid_for(captain, Enhancements.STANDARD_OF_THE_EMPEROR_ASCENDANT, Enhancements.GLADIUS), "Standard of the Emperor Ascendant rejects a non-Ancient profile")
	check(int(Enhancements.RECORDS[Enhancements.ADEPT_OF_THE_CODEX].cost) == 20 and int(Enhancements.RECORDS[Enhancements.ARTIFICER_ARMOUR].cost) == 15 and int(Enhancements.RECORDS[Enhancements.LAURELS_OF_TRIUMPH].cost) == 20 and int(Enhancements.RECORDS[Enhancements.STANDARD_OF_THE_EMPEROR_ASCENDANT].cost) == 25, "All Gladius enhancement costs match the local Wahapedia export")
	var local_catalog: Dictionary = {}
	for record: Dictionary in Enhancements.catalog_records([captain, ancient]): local_catalog[record.id] = record
	check(local_catalog.has(Enhancements.ADEPT_OF_THE_CODEX) and local_catalog.has(Enhancements.ARTIFICER_ARMOUR) and local_catalog.has(Enhancements.LAURELS_OF_TRIUMPH) and local_catalog.has(Enhancements.STANDARD_OF_THE_EMPEROR_ASCENDANT), "All four Gladius enhancements appear for locally eligible catalog profiles")
	var captain_roster := {"schema_version": 2, "faction": "Space Marines", "category": "training", "points_limit": 500, "entries": [roster_entry("captain", 1, Enhancements.ADEPT_OF_THE_CODEX)]}
	var admission: Dictionary = Army.admit(captain_roster)
	check(admission.get("error", "").is_empty() and admission.total == 110, "Army admission adds Adept of the Codex's 20 points to Captain")

	var s := prepared(Enhancements.ADEPT_OF_THE_CODEX)
	var captain_model := model_for(s, "captain")
	var captain_squad := int(s.units[captain_model].squad)
	s.combat_doctrines.active[1] = "assault"
	check(Doctrines.has_doctrine(s, captain_squad, "assault") and Doctrines.has_doctrine(s, captain_squad, "tactical") and s.combat_doctrines.used.get(1, []) == [], "Adept of the Codex adds Tactical Doctrine without replacing or consuming Assault selection")
	var bodyguard_model := model_for(s, "intercessor-squad")
	var bodyguard_squad := int(s.units[bodyguard_model].squad)
	C.UnitActions.attach(s, captain_model, bodyguard_squad)
	check(int(s.units[captain_model].squad) == bodyguard_squad and Doctrines.has_doctrine(s, bodyguard_squad, "assault") and Doctrines.has_doctrine(s, bodyguard_squad, "tactical"), "Adept of the Codex remains active alongside the army doctrine after Captain attachment")

	s = prepared(Enhancements.ARTIFICER_ARMOUR)
	captain_model = model_for(s, "captain")
	var armour_profile: Dictionary = DefenderGroups.profile(s, captain_model)
	var armour_fnp: Array = Prevention.rules(s, captain_model)
	var prevented := WoundPrevention.resolve(1, int(s.units[captain_model].wounds), armour_fnp, "normal", func() -> int: return 5)
	check(armour_profile.get("error", "").is_empty() and int(armour_profile.save_target) == 2, "Artificer Armour changes only the assigned bearer's Save to 2+")
	check({"target": 5, "against": "any"} in armour_fnp and prevented.get("error", "").is_empty() and int(prevented.prevented) == 1, "Artificer Armour gives its bearer Feel No Pain 5+ in wound prevention")
	var infantry_model := model_for(s, "intercessor-squad")
	check(not ({"target": 5, "against": "any"} in Prevention.rules(s, infantry_model)), "Artificer Armour does not grant its unit-wide Feel No Pain")

	s = prepared(Enhancements.LAURELS_OF_TRIUMPH)
	captain_model = model_for(s, "captain")
	var melee_profile := {"attacks": 4, "strength": 4, "ap": -1, "damage": 1, "keywords": {}}
	var laurels_base: Dictionary = C.AttackPlan._enhancement_weapon(s, captain_model, melee_profile, true)
	check(laurels_base.strength == 5 and laurels_base.ap == -2 and laurels_base.attacks == 4, "Laurels of Triumph add +1 Strength and AP to the bearer's melee attacks")
	s.combat_doctrines.active[1] = "assault"
	var laurels_assault: Dictionary = C.AttackPlan._enhancement_weapon(s, captain_model, melee_profile, true)
	check(laurels_assault.strength == 6 and laurels_assault.ap == -3, "Laurels of Triumph add +2 Strength and AP while Assault Doctrine is active")
	var non_bearer: Dictionary = C.AttackPlan._enhancement_weapon(s, infantry_model, melee_profile, true)
	check(non_bearer == melee_profile, "Laurels of Triumph's melee characteristic bonus stays on the bearer")

	s = prepared(Enhancements.STANDARD_OF_THE_EMPEROR_ASCENDANT, "ancient")
	var ancient_model := model_for(s, "ancient")
	bodyguard_model = model_for(s, "intercessor-squad")
	bodyguard_squad = int(s.units[bodyguard_model].squad)
	C.UnitActions.attach(s, ancient_model, bodyguard_squad)
	var ancient_squad := int(s.units[ancient_model].squad)
	var ancient_fnp: Array = Prevention.rules(s, ancient_model)
	var enhanced_oc := C.Morale.objective_control(s, ancient_model)
	var old_model_enhancement := str(s.units[ancient_model].get("enhancement_id", ""))
	var old_squad_enhancement := str(s.squads[ancient_squad].get("enhancement_id", ""))
	s.units[ancient_model].enhancement_id = ""
	s.squads[ancient_squad].enhancement_id = ""
	var base_oc := C.Morale.objective_control(s, ancient_model)
	s.units[ancient_model].enhancement_id = old_model_enhancement
	s.squads[ancient_squad].enhancement_id = old_squad_enhancement
	check(Enhancements.standard_bearer(s, ancient_model) and enhanced_oc == base_oc + 1, "Standard of the Emperor Ascendant grants +1 OC to the assigned Ancient")
	check(int(C.Morale.leadership(s, ancient_squad).target) == 5 and {"target": 5, "against": "any"} in ancient_fnp, "Standard improves the bearer Leadership and grants Feel No Pain 5+")
	s.phase = "fight"
	s.fight_step = "attacks"
	s.fight_actor = 1
	s.fight_selected = ancient_squad
	s.squads[ancient_squad].charged = true
	var exhortations := Enhancements.standard_fight_choices(s, 1)
	var exhortation_error := "no choice"
	if not exhortations.is_empty(): exhortation_error = Enhancements.apply_standard_exhortation(s, 1, exhortations[0])
	var ancient_melee := C.AttackPlan._enhancement_weapon(s, bodyguard_model, melee_profile, true)
	check(exhortation_error.is_empty() and ancient_melee.attacks == 5 and Enhancements.standard_melee_attack_bonus(s, ancient_squad) == 1, "Ancient Exhortation adds one melee Attack to the attached unit for this phase")
	check(Enhancements.standard_fight_choices(s, 1).is_empty(), "Ancient Exhortation is once per battle per army")
	s = prepared(Enhancements.STANDARD_OF_THE_EMPEROR_ASCENDANT, "ancient")
	ancient_model = model_for(s, "ancient")
	bodyguard_model = model_for(s, "intercessor-squad")
	C.UnitActions.attach(s, ancient_model, int(s.units[bodyguard_model].squad))
	ancient_squad = int(s.units[ancient_model].squad)
	var enemy_squad := -1
	for squad_id: int in s.squads:
		if int(s.squads[squad_id].owner) == 2:
			enemy_squad = squad_id
			break
	var enemy_model := -1
	for model_id: int in s.units:
		if int(s.units[model_id].squad) == enemy_squad and int(s.units[model_id].wounds) > 0:
			enemy_model = model_id
			break
	s.phase = "fight"
	s.fight_step = "attacks"
	s.fight_actor = 1
	s.fight_selected = ancient_squad
	s.squads[ancient_squad].charged = true
	var ordinary_state: Dictionary = s.duplicate(true)
	var ordinary_exhortation: Dictionary = Enhancements.standard_fight_choices(ordinary_state, 1)[0]
	var ordinary_exhortation_result := MatchCommands.execute(ordinary_state, 1, {"kind": MatchCommands.SELECT_UNIT_CHOICE, "choice": ordinary_exhortation, "revision": ordinary_state.revision})
	check(ordinary_exhortation_result.error.is_empty(), "The current Fight actor can still use an unprojected immediate Fight choice")
	var pending_attack_state: Dictionary = s.duplicate(true)
	var pending_attack_id := "attack:%d:%d:%s:%d" % [pending_attack_state.turn, ancient_squad, pending_attack_state.phase, pending_attack_state.revision]
	pending_attack_state.pending_attack = {"squad": ancient_squad, "player": 1, "resolution_action_id": pending_attack_id, "current": {"phase": "order", "target": enemy_squad, "groups": [{"models": [enemy_model], "character": false}], "order": []}}
	var suspended_attack := C.ResolutionFrames.begin(pending_attack_state, "attack", pending_attack_id, "attack-defender-allocation")
	C.ResolutionFrames.suspend(pending_attack_state, str(suspended_attack.frame_id), "attack-defender-allocation")
	var blocked_exhortation := Enhancements.standard_fight_choices(pending_attack_state, 1)[0]
	var pending_attack_before := var_to_str(pending_attack_state)
	var blocked_exhortation_result := MatchCommands.execute(pending_attack_state, 1, {"kind": MatchCommands.SELECT_UNIT_CHOICE, "choice": blocked_exhortation, "revision": pending_attack_state.revision})
	check("damage allocation" in str(blocked_exhortation_result.error).to_lower() and pending_attack_before == var_to_str(pending_attack_state), "Attacker cannot use an unprojected Fight choice while the defender owns pending damage allocation")
	s.phase = "shooting"
	check(Enhancements.standard_melee_attack_bonus(s, ancient_squad) == 0, "Ancient Exhortation expires when the Fight phase ends")

	print("Gladius enhancement checks: %d failures" % failures)
	quit(1 if failures else 0)
