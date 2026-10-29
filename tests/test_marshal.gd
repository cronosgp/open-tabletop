extends SceneTree

const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Catalog = preload("res://scripts/edition_11/army_capabilities.gd")
const AbilityCatalog = preload("res://scripts/edition_11/unit_ability_catalog.gd")
const Registry = preload("res://scripts/edition_11/capabilities.gd")
const Links = preload("res://scripts/edition_11/marine_leader_links.gd")
const Geometry = preload("res://scripts/edition_11/contact_movement.gd")
const Equipment = preload("res://scripts/edition_11/equipment.gd")
const PublicUnitCommand = preload("res://tests/public_unit_command.gd")
const DatasheetChecks = preload("res://tests/space_marine_datasheet_checks.gd")
const UNIT := "marshal"
const UNIT_ID := "40kdc:11e:adeptus-astartes:marshal"

var failures := 0

func _initialize() -> void:
	call_deferred("run")

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func entry(identity: String, models_count: int = 1) -> Dictionary:
	return {"definition_id": "40kdc:11e:adeptus-astartes:" + identity, "models": models_count, "copies": 1}

func selections() -> Dictionary:
	return {
		1: {"schema_version": 2, "faction": "Space Marines", "category": "custom", "points_limit": 1000, "entries": [entry(UNIT), entry("intercessor-squad", 5)]},
		2: {"schema_version": 2, "faction": "Space Marines", "category": "custom", "points_limit": 1000, "entries": [entry("intercessor-squad", 5), entry("assault-intercessor-squad", 5), entry("infernus-squad", 5), entry("hellblaster-squad", 5)]}
	}

func fixture() -> Dictionary:
	var state: Dictionary = F.P.initial_state({
		"checked_rosters": false, "official_mission": false, "unit_abilities": true,
		"combat_doctrines": true, "core_stratagems": true, "attack_rerolls": true,
		"manual_allocation": false, "marine_chapters": {1: "BLACK TEMPLARS", 2: "BLACK TEMPLARS"}
	}, selections())
	if state.has("error"): return state
	state.phase = "deployment"
	state.active = 1
	state.turn = 1
	state.round = 1
	return state

func model_for(state: Dictionary, owner: int, identity: String) -> int:
	for model: int in state.units:
		if int(state.units[model].get("owner", -1)) == owner and C.UnitAbilities.identity(state.units[model]) == identity: return model
	return -1

func option(state: Dictionary, player: int, action: String, value: String = "", target: int = -1, model: int = -1) -> Dictionary:
	for candidate: Dictionary in C.UnitActions.choices(state, player):
		if str(candidate.get("action", "")) != action: continue
		if not value.is_empty() and str(candidate.get("value", "")) != value: continue
		if target >= 0 and int(candidate.get("target", -1)) != target: continue
		if model >= 0 and int(candidate.get("model", -1)) != model: continue
		return candidate
	return {}

func run() -> void:
	var profile := Profiles.profile(UNIT)
	check(profile.get("source_book_id") == "000000162" and profile.get("source_datasheet_id") == "000002796" and profile.get("source_snapshot_id") == "20261021T130623Z", "Marshal profile cites the pinned Black Templars App export")
	check(profile.get("source_manifest_sha256") == "169db99791a91582fd043902303e73c4af83ec63e96c01817ce52cb5ce4deccf" and profile.get("source_slice_manifest_sha256") == "8a6d9529ae553b06203cdb2b6c8f1edd736f2a737ba1c215d2241bd1cdfb5bbe", "Marshal profile records both verified source manifest hashes")
	check(profile.get("points_by_models", {}) == {1: 80} and profile.get("models", 0) == 1 and profile.get("base_size_source_mm", 0) == 40, "The 80-point one-model profile and 40 mm base match the export")
	check(profile.get("stats", {}) == {"movement_inches": 6, "toughness": 5, "save_target": 3, "wounds": 5, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 4}, "Marshal characteristics, including its invulnerable save, match the export")
	check(profile.get("keywords", []) == ["INFANTRY", "CAPTAIN", "CHARACTER", "EXPLOSIVES", "IMPERIUM", "TACTICUS", "ADEPTUS ASTARTES", "BLACK TEMPLARS"], "All Marshal datasheet and faction keywords are present")
	check(profile.get("ranged", [])[0].id == "plasma-pistol" and profile.ranged[0].profiles.standard.keywords.get("close-quarters", false) and profile.ranged[0].profiles.supercharge.keywords.get("hazardous", false), "Plasma Pistol exposes both source profiles and Hazardous")
	check(profile.get("melee", [])[0].id == "master-crafted-power-weapon" and profile.melee[0].profiles.standard.attacks == 7 and profile.melee[0].profiles.standard.keywords.get("lethal-hits", false), "Master-crafted Power Weapon matches the source profile")
	check(profile.get("options", {}).get("ranged_packages", []) == ["plasma-pistol", "combi-weapon"] and Profiles.marshal_weapons("combi-weapon").ranged[0].profiles.size() == 3, "The Plasma Pistol replacement exposes all three Combi-weapon profiles")
	check(Catalog.SPECS.get(UNIT, {}).get("current_reference", false) and C.RosterValidation.POINTS.get(UNIT, {}).get("cost", -1) == 80, "Current construction and point catalogs admit Marshal at 80 points")
	check(Catalog.current_catalog_choice({"id": UNIT_ID, "edition": "11e", "faction": "Space Marines"}).get("options", []) == [{"models": 1, "cost": 80}], "The consolidated local catalog exposes the single-model Marshal")
	check(AbilityCatalog.RULES.get(UNIT, []).has("leader") and AbilityCatalog.RULES.get(UNIT, []).has("combat-doctrines") and AbilityCatalog.RULES.get(UNIT, []).has("transhuman-strategist"), "Leader, Combat Doctrines and Transhuman Strategist are registered")
	check(AbilityCatalog.RULES.get(UNIT, []).has("inspirational-exemplar") and AbilityCatalog.RULES.get(UNIT, []).has("pious-fervour") and Registry.KNOWN.get("inspirational-exemplar", {}).get("supported", false) and Registry.KNOWN.get("pious-fervour", {}).get("supported", false), "Both Marshal datasheet abilities are registered as supported local capabilities")
	check(Links.CHAPTER_TARGETS.get(UNIT, []) == ["assault-intercessor-squad", "bladeguard-veteran-squad", "infernus-squad", "intercessor-squad", "sternguard-veteran-squad", "crusader-squad", "sword-brethren-squad"], "All seven source-listed Leader targets are recorded")

	var state := fixture()
	if state.has("error"):
		check(false, "Both-player current-catalog Black Templars fixture materializes: %s" % str(state.get("error", "")))
	else:
		var marshal := model_for(state, 1, UNIT)
		var opponent_intercessors := model_for(state, 2, "intercessor-squad")
		var friendly_bodyguard := model_for(state, 1, "intercessor-squad")
		var opponent_squad := int(state.units[opponent_intercessors].squad) if opponent_intercessors >= 0 else -1
		var friendly_squad := int(state.units[friendly_bodyguard].squad) if friendly_bodyguard >= 0 else -1
		check(marshal >= 0 and opponent_intercessors >= 0 and friendly_bodyguard >= 0, "Both players materialize current-catalog Marines")
		if marshal >= 0 and opponent_intercessors >= 0 and friendly_bodyguard >= 0:
			for failure: String in DatasheetChecks.fixed_weapon_plan_failures(state, profile, marshal, opponent_squad): check(false, "Marshal default weapon plan: " + failure)
			check(not option(state, 1, "warlord", "", -1, marshal).is_empty(), "Marshal is available as the army's Warlord")
			var marshal_squad := int(state.units[marshal].squad)
			var combi_choice := option(state, 1, "marshal-ranged-loadout", "combi-weapon", marshal_squad, marshal)
			var combi_result := PublicUnitCommand.submit(state, 1, combi_choice)
			check(not combi_choice.is_empty() and combi_result.get("error", "").is_empty() and state.units[marshal].ranged_weapons[0].id == "combi-weapon", "The source-listed Combi-weapon replacement is applied in preparation")
			var restore_choice := option(state, 1, "marshal-ranged-loadout", "plasma-pistol", marshal_squad, marshal)
			var restore_result := PublicUnitCommand.submit(state, 1, restore_choice)
			check(not restore_choice.is_empty() and restore_result.get("error", "").is_empty() and state.units[marshal].ranged_weapons[0].id == "plasma-pistol", "The default Plasma Pistol can be restored through preparation")
			var attach_choice := option(state, 1, "attach", "", friendly_squad, marshal)
			var attach_result := PublicUnitCommand.submit(state, 1, attach_choice)
			check(not attach_choice.is_empty() and attach_result.get("error", "").is_empty() and int(state.units[marshal].squad) == friendly_squad, "Marshal attaches to a source-listed Intercessor unit")
			friendly_squad = int(state.units[marshal].squad)
			state.units[marshal].position = Vector2.ZERO
			var bodyguard_index := 0
			for bodyguard: int in Geometry.alive(state, friendly_squad):
				if bodyguard == marshal: continue
				state.units[bodyguard].position = Vector2(-0.4 + float(bodyguard_index) * 0.02, 0)
				bodyguard_index += 1
			var distances := {"intercessor-squad": 2.0, "assault-intercessor-squad": 3.0, "infernus-squad": 4.0, "hellblaster-squad": 14.0}
			for identity: String in distances:
				var enemy_model := model_for(state, 2, identity)
				if enemy_model < 0: continue
				var enemy_squad := int(state.units[enemy_model].squad)
				var enemy_index := 0
				for enemy: int in Geometry.alive(state, enemy_squad):
					state.units[enemy].position = Vector2(float(distances[identity]) + float(enemy_index) * 0.02, 0)
					enemy_index += 1
			state.phase = "fight"
			state.fight_step = "attacks"
			state.fight_actor = 1
			state.active = 1
			state.squads[friendly_squad].charged = true
			var pious_choice := option(state, 1, "pious-fervour", "", friendly_squad, marshal)
			check(not pious_choice.is_empty(), "Pious Fervour is offered when Marshal's unit is selected to fight")
			var unchanged := var_to_bytes(state)
			var wrong_owner := PublicUnitCommand.submit(state, 2, pious_choice)
			check(not str(wrong_owner.get("error", "")).is_empty() and unchanged == var_to_bytes(state), "The opponent cannot activate Marshal's Pious Fervour")
			var activated := PublicUnitCommand.submit(state, 1, pious_choice)
			var activation: Dictionary = state.unit_abilities.get("pious_fervour", {}).get(friendly_squad, {})
			check(activated.get("error", "").is_empty() and int(activation.get("nearby_enemy_units", 0)) == 3 and int(activation.get("bonus", 0)) == 3, "Pious Fervour counts three nearby enemy units, caps at +3 and excludes the distant fourth unit")
			check(C.UnitAbilities.pious_fervour_bonus(state, marshal) == 3, "The Marshal retains its attack bonus during the selected Fight activation")
			var marshal_melee: Dictionary = state.units[marshal].melee_weapons[0].profiles.standard
			var bodyguard_melee: Dictionary = Equipment.select(state, friendly_bodyguard, true).stats
			check(C.UnitAbilities.melee_attack_count(state, marshal, marshal_melee) == 10, "Pious Fervour adds three attacks to the Marshal's melee profile")
			check(C.UnitAbilities.melee_attack_count(state, friendly_bodyguard, bodyguard_melee) == int(bodyguard_melee.attacks), "Pious Fervour does not add attacks to attached bodyguards")
			check(C.UnitAbilities.hit_bonus(state, friendly_squad, opponent_squad, true, marshal, marshal_melee) == 1 and C.UnitAbilities.hit_bonus(state, friendly_squad, opponent_squad, true, friendly_bodyguard, bodyguard_melee) == 1, "Inspirational Exemplar grants +1 Hit to the whole unit's melee attacks")
			check(C.UnitAbilities.hit_bonus(state, friendly_squad, opponent_squad, false, marshal, state.units[marshal].ranged_weapons[0].profiles.standard) == 0, "Inspirational Exemplar does not modify ranged attacks")
			var declarations: Array = C.AttackPlan.single_target(state, friendly_squad, opponent_squad, true)
			var marshal_declaration: Dictionary = {}
			var bodyguard_declaration: Dictionary = {}
			for declaration: Dictionary in declarations:
				if int(declaration.get("model", -1)) == marshal: marshal_declaration = declaration
				elif int(declaration.get("model", -1)) != marshal and bodyguard_declaration.is_empty(): bodyguard_declaration = declaration
			check(int(marshal_declaration.get("amount", 0)) == 10 and int(bodyguard_declaration.get("amount", 0)) == int(bodyguard_melee.attacks), "AttackPlan allocates the Marshal's bonus attacks to him alone")
			var melee_plan := C.AttackPlan.prepare(state, friendly_squad, true, declarations, true)
			var found_marshal_batch := false
			for batch: Dictionary in melee_plan.get("batches", []):
				for source: Dictionary in batch.get("context", {}).get("attack_sources", []):
					if int(source.get("model", -1)) == marshal:
						found_marshal_batch = true
						check(int(batch.context.get("hit_modifier", 0)) == 1, "AttackPlan applies Inspirational Exemplar to the Marshal's melee attacks")
			check(melee_plan.get("error", "").is_empty() and found_marshal_batch, "Marshal and bodyguard melee attacks resolve through AttackPlan")
			var restored: Dictionary = bytes_to_var(var_to_bytes(state))
			check(C.UnitAbilities.pious_fervour_bonus(restored, marshal) == 3, "The active Pious Fervour record survives state serialization")
			restored.fight_selected = -1
			check(C.UnitAbilities.pious_fervour_bonus(restored, marshal) == 0, "Pious Fervour stops affecting attacks when the Fight activation ends")
			var committed_state: Dictionary = state.duplicate(true)
			var committed := C._commit_finished_attack(committed_state, friendly_squad, 1, declarations, true, melee_plan, {"killed": 0, "damage": 0, "pools": []}, func() -> int: return 1)
			check(committed.get("error", "").is_empty() and not committed_state.unit_abilities.get("pious_fervour", {}).has(friendly_squad), "Completing the Fight activation clears the saved Pious Fervour bonus")
			var empty_fight_state: Dictionary = state.duplicate(true)
			C._finish_empty_fight(empty_fight_state, 1, friendly_squad)
			check(not empty_fight_state.unit_abilities.get("pious_fervour", {}).has(friendly_squad), "An empty Fight activation also clears Pious Fervour")

	if failures == 0: print("Marshal local checks: passed")
	else: print("Marshal local checks: %d failures" % failures)
	quit(0 if failures == 0 else 1)
