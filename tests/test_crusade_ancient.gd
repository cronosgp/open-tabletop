extends SceneTree

const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Catalog = preload("res://scripts/edition_11/army_capabilities.gd")
const AbilityCatalog = preload("res://scripts/edition_11/unit_ability_catalog.gd")
const Registry = preload("res://scripts/edition_11/capabilities.gd")
const Links = preload("res://scripts/edition_11/marine_leader_links.gd")
const Support = preload("res://scripts/edition_11/support_attachments.gd")
const CrusadeAncient = preload("res://scripts/edition_11/crusade_ancient.gd")
const Morale = preload("res://scripts/edition_11/morale.gd")
const UNIT := "crusade-ancient"
var failures := 0

func _initialize() -> void:
	call_deferred("run")

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func entry(identity: String, models: int = 1) -> Dictionary:
	return {"definition_id": "40kdc:11e:adeptus-astartes:" + identity, "models": models, "copies": 1}

func selections() -> Dictionary:
	return {
		1: {"schema_version": 2, "faction": "Space Marines", "category": "custom", "points_limit": 500, "entries": [entry(UNIT), entry("crusader-squad", 10)]},
		2: {"schema_version": 2, "faction": "Space Marines", "category": "custom", "points_limit": 500, "entries": [entry("intercessor-squad", 5), entry("intercessor-squad", 5)]}
	}

func fixture() -> Dictionary:
	var state: Dictionary = F.P.initial_state({"checked_rosters": false, "official_mission": false, "unit_abilities": true,
		"combat_doctrines": true, "core_stratagems": true, "attack_rerolls": true,
		"manual_allocation": false, "marine_chapters": {1: "BLACK TEMPLARS", 2: "BLACK TEMPLARS"}}, selections())
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

func roll_four() -> int:
	return 4

func roll_three() -> int:
	return 3

func run() -> void:
	var profile := Profiles.profile(UNIT)
	check(profile.get("source_book_id", "") == "000000162" and profile.get("source_datasheet_id", "") == "000004136" and profile.get("source_snapshot_id", "") == "20261021T130623Z", "Crusade Ancient cites the verified Black Templars App datasheet and snapshot")
	check(profile.get("source_manifest_sha256", "") == "169db99791a91582fd043902303e73c4af83ec63e96c01817ce52cb5ce4deccf" and profile.get("source_slice_manifest_sha256", "") == "8a6d9529ae553b06203cdb2b6c8f1edd736f2a737ba1c215d2241bd1cdfb5bbe", "Crusade Ancient records both verified source manifest hashes")
	check(profile.get("points_by_models", {}) == {1: 45} and profile.get("base_size_source_mm", 0) == 40, "The one-model 45-point profile and 40 mm base match the export")
	check(profile.get("stats", {}) == {"movement_inches": 6, "toughness": 5, "save_target": 3, "wounds": 4, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 0}, "Crusade Ancient characteristics match the verified export")
	var keywords: Array = profile.get("keywords", []).duplicate()
	keywords.sort()
	check(keywords == ["ADEPTUS ASTARTES", "BLACK TEMPLARS", "CHARACTER", "EXPLOSIVES", "IMPERIUM", "INFANTRY", "TACTICUS"], "Crusade Ancient keywords match the verified export")
	check(profile.get("ranged", [])[0].get("profiles", {}).get("standard", {}) == {"name": "Bolt Pistol", "range_inches": 12.0, "attacks": 1, "skill": 3, "strength": 5, "ap": -1, "damage": 1, "keywords": {"close-quarters": true}}, "Bolt Pistol profile matches the verified export")
	check(profile.get("melee", [])[0].get("profiles", {}).get("standard", {}) == {"name": "Master-crafted Power Weapon", "range_inches": 0.0, "attacks": 5, "skill": 2, "strength": 5, "ap": -2, "damage": 2, "keywords": {"lethal-hits": true}}, "Master-crafted Power Weapon profile matches the verified export")
	check(Catalog.SPECS.get(UNIT, {}).get("current_reference", false) and C.RosterValidation.POINTS.get(UNIT, {}).get("cost", -1) == 45, "The consolidated catalog and roster points admit the 45-point profile")
	check(Links.CHAPTER_TARGETS.get(UNIT, []) == ["crusader-squad", "sword-brethren-squad"] and Support.BODYGUARDS.get(UNIT, []) == ["crusader-squad", "sword-brethren-squad"], "Only the two source-listed Black Templars Support targets are recorded")
	check(AbilityCatalog.RULES.get(UNIT, []).has("martial-honour") and AbilityCatalog.RULES.get(UNIT, []).has("vengeful-exhortation") and Registry.KNOWN.get("martial-honour", {}).get("supported", false) and Registry.KNOWN.get("vengeful-exhortation", {}).get("supported", false), "Both Crusade Ancient abilities are registered")
	var state := fixture()
	if state.has("error"):
		check(false, "Current-catalog Black Templars fixture materializes: %s" % str(state.get("error", "")))
	else:
		var ancient := model_for(state, 1, UNIT)
		var crusader := model_for(state, 1, "crusader-squad")
		var enemy := model_for(state, 2, "intercessor-squad")
		var squad := int(state.units[ancient].squad)
		var bodyguard_squad := int(state.units[crusader].squad)
		var enemy_squad := int(state.units[enemy].squad)
		check(ancient >= 0 and crusader >= 0 and enemy >= 0, "The current catalog materializes Crusade Ancient, Crusader Squad and an enemy target")
		check(C.UnitActions.attachment_allowed(state, ancient, bodyguard_squad), "Crusade Ancient can Support Crusader Squad")
		check(not C.UnitActions.attachment_allowed(state, ancient, enemy_squad), "Crusade Ancient cannot Support an enemy unit")
		var attach := {}
		for candidate: Dictionary in C.UnitActions.choices(state, 1):
			if candidate.get("action", "") == "attach" and int(candidate.get("model", -1)) == ancient and int(candidate.get("target", -1)) == bodyguard_squad: attach = candidate
		var attached := C.UnitActions.apply(state, 1, attach, Vector2.ZERO, Callable()) if not attach.is_empty() else {"error": "No attach choice"}
		check(attached.get("error", "").is_empty() and int(state.units[ancient].squad) == bodyguard_squad, "Crusade Ancient joins its listed Crusader Squad target")
		squad = bodyguard_squad
		state.phase = "fight"
		state.fight_step = "attacks"
		state.fight_actor = 2
		state.fight_selected = enemy_squad
		state.active = 2
		state.squads[enemy_squad].charged = true
		for model: int in C.living(state, enemy_squad): state.units[model].position = Vector2.ZERO
		for model: int in C.living(state, squad): state.units[model].position = Vector2(1.0, 0.0)
		var attack_entries := C.AttackPlan.single_target(state, enemy_squad, squad, true)
		check(not attack_entries.is_empty(), "The opposing Intercessors have a legal melee attack against the Crusader attachment")
		var declaration_result := C.resolve_attack_plan(state, 2, enemy, attack_entries, int(state.get("revision", -1)), true, false, Callable(self, "roll_four"))
		var declaration: Dictionary = C.UnitActions.pending(state).get("declaration", {})
		check(declaration_result.get("error", "").is_empty() and C.UnitActions.pending(state).get("kind", "") == "worthy-death", "The attack declaration automatically opens the Vengeful Exhortation reaction")
		var exhortation_choice := {}
		for candidate: Dictionary in C.UnitActions.choices(state, 1):
			if candidate.get("action", "") == CrusadeAncient.VENGEFUL_EXHORTATION_USE: exhortation_choice = candidate
		check(not exhortation_choice.is_empty(), "Vengeful Exhortation is offered before its unit is selected to fight")
		var enemy_before := var_to_bytes(state)
		var wrong_owner := C.UnitActions.apply(state, 2, exhortation_choice, Vector2.ZERO, Callable())
		check(not str(wrong_owner.get("error", "")).is_empty() and enemy_before == var_to_bytes(state), "Only the Crusade Ancient's owner may activate Vengeful Exhortation")
		var exhortation_result := C.UnitActions.apply(state, 1, exhortation_choice, Vector2.ZERO, Callable())
		check(exhortation_result.get("error", "").is_empty() and exhortation_result.get("resume_declaration", {}) == declaration and CrusadeAncient.vengeful_exhortation_active(state, squad), "Vengeful Exhortation activates and resumes the attack declaration")
		var casualty := -1
		for model: int in C.living(state, squad):
			if model != ancient: casualty = model; break
		state.units[casualty].wounds = 0
		var held := C.DetachmentStratagems.hold_destroyed(state, casualty, Callable(self, "roll_four"))
		check(held.get("held", false) and held.get("rule", "") == "vengeful-exhortation" and int(state.units[casualty].wounds) == 1, "Vengeful Exhortation retains a destroyed model on 4+")
		var failed_state: Dictionary = state.duplicate(true)
		var failed_casualty := -1
		for model: int in C.living(failed_state, squad):
			if model != ancient: failed_casualty = model; break
		failed_state.units[failed_casualty].wounds = 0
		var failed_hold := C.DetachmentStratagems.hold_destroyed(failed_state, failed_casualty, Callable(self, "roll_three"))
		check(not failed_hold.get("held", false) and failed_state.units[failed_casualty].wounds == 0, "Vengeful Exhortation removes a model after a failed 4+ roll")
		C.DetachmentStratagems.remove_lingering(state, squad)
		check(state.units[casualty].wounds == 0, "A retained model is removed when its unit fights")

		var martial_state: Dictionary = fixture()
		if not martial_state.has("error"):
			ancient = model_for(martial_state, 1, UNIT)
			crusader = model_for(martial_state, 1, "crusader-squad")
			enemy = model_for(martial_state, 2, "intercessor-squad")
			squad = int(martial_state.units[ancient].squad)
			var martial_attach := {}
			for candidate: Dictionary in C.UnitActions.choices(martial_state, 1):
				if candidate.get("action", "") == "attach" and int(candidate.get("model", -1)) == ancient and int(candidate.get("target", -1)) == int(martial_state.units[crusader].squad): martial_attach = candidate
			var martial_attach_result := C.UnitActions.apply(martial_state, 1, martial_attach, Vector2.ZERO, Callable()) if not martial_attach.is_empty() else {"error": "No attach choice"}
			squad = int(martial_state.units[crusader].squad)
			check(martial_attach_result.get("error", "").is_empty(), "Martial Honour check uses the actual attached-unit path")
			enemy_squad = int(martial_state.units[enemy].squad)
			for model: int in C.living(martial_state, enemy_squad): martial_state.units[model].wounds = 0
			martial_state.phase = "fight"
			martial_state.fight_actor = 1
			martial_state.fight_step = "attacks"
			martial_state.fight_selected = squad
			var committed := C._commit_finished_attack(martial_state, squad, 1, [], true, {"targets": [enemy_squad]}, {"killed": 5, "damage": 5, "pools": []}, Callable())
			check(committed.get("error", "").is_empty() and C.UnitActions.pending(martial_state).get("kind", "") == CrusadeAncient.MARTIAL_HONOUR_WINDOW, "Finishing a melee attack that destroys an enemy unit opens Martial Honour")
			var honour_choice := {}
			for candidate: Dictionary in C.UnitActions.choices(martial_state, 1):
				if candidate.get("action", "") == CrusadeAncient.MARTIAL_HONOUR_USE: honour_choice = candidate
			check(not honour_choice.is_empty(), "Martial Honour presents an optional post-attack choice")
			var honour_result := C.UnitActions.apply(martial_state, 1, honour_choice, Vector2.ZERO, Callable())
			check(honour_result.get("error", "").is_empty() and Morale.objective_control(martial_state, ancient) == 6 and Morale.objective_control(martial_state, crusader) == 2, "Martial Honour adds +5 OC only to the Crusade Ancient model")
			check(not CrusadeAncient.open_martial_honour(martial_state, squad, [enemy_squad], 1), "Martial Honour cannot be used twice by the same unit in one battle")
			var stacked_state: Dictionary = fixture()
			if not stacked_state.has("error"):
				var stacked_ancient := model_for(stacked_state, 1, UNIT)
				var stacked_crusader := model_for(stacked_state, 1, "crusader-squad")
				var stacked_enemy := model_for(stacked_state, 2, "intercessor-squad")
				var stacked_squad := int(stacked_state.units[stacked_crusader].squad)
				var stacked_target := int(stacked_state.units[stacked_enemy].squad)
				stacked_state.units[stacked_ancient].squad = stacked_squad
				for model: int in C.living(stacked_state, stacked_target): stacked_state.units[model].wounds = 0
				stacked_state.phase = "fight"
				stacked_state.unit_abilities.window = {"kind": "counter", "owners": [2], "resume_cursor": 2, "resume_step": "attacks"}
				check(CrusadeAncient.open_martial_honour(stacked_state, stacked_squad, [stacked_target], 1) and C.UnitActions.pending(stacked_state).get("resume_window", {}).get("kind", "") == "counter", "Martial Honour saves a pending post-Fight reaction window")
				var stacked_pass := {}
				for candidate: Dictionary in C.UnitActions.choices(stacked_state, 1):
					if candidate.get("action", "") == CrusadeAncient.MARTIAL_HONOUR_PASS: stacked_pass = candidate
				var stacked_pass_result := C.UnitActions.apply(stacked_state, 1, stacked_pass, Vector2.ZERO, Callable())
				check(not stacked_pass.is_empty() and stacked_pass_result.get("error", "").is_empty() and C.UnitActions.pending(stacked_state).get("kind", "") == "counter", "Passing Martial Honour restores the saved Counteroffensive decision")
			var not_destroyed_state: Dictionary = fixture()
			if not not_destroyed_state.has("error"):
				var alive_crusader := model_for(not_destroyed_state, 1, "crusader-squad")
				var alive_enemy := model_for(not_destroyed_state, 2, "intercessor-squad")
				check(not CrusadeAncient.open_martial_honour(not_destroyed_state, int(not_destroyed_state.units[alive_crusader].squad), [int(not_destroyed_state.units[alive_enemy].squad)], 1), "Martial Honour does not open while the enemy unit still has a living model")

	if failures == 0: print("test_crusade_ancient: OK")
	else: push_error("test_crusade_ancient: %d failure(s)" % failures)
	quit(0 if failures == 0 else 1)
