extends SceneTree
const F = preload("res://tests/all_units_fixture.gd")
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Catalog = preload("res://scripts/edition_11/army_capabilities.gd")
const Roster = preload("res://scripts/edition_11/roster_validation.gd")
const Geometry = preload("res://scripts/edition_11/contact_movement.gd")
const AttackPlan = preload("res://scripts/edition_11/attack_plan.gd")
const AttackSequence = preload("res://scripts/edition_11/attack_sequence.gd")
const AttackRollWindow = preload("res://scripts/edition_11/attack_roll_window.gd")
const Leaders = preload("res://scripts/edition_11/leaders.gd")
const Abilities = preload("res://scripts/edition_11/unit_abilities.gd")
const DatasheetChecks = preload("res://tests/space_marine_datasheet_checks.gd")
var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func find_squad(state: Dictionary, owner: int, identity: String) -> int:
	for squad: int in state.squads:
		if state.squads[squad].owner != owner: continue
		for model: int in Geometry.alive(state, squad):
			if Abilities.identity(state.units[model]) == identity: return squad
	return -1

func find_model(state: Dictionary, owner: int, identity: String) -> int:
	for model: int in state.units:
		if state.units[model].owner == owner and Abilities.identity(state.units[model]) == identity: return model
	return -1

func run() -> void:
	var profile := Profiles.profile("kor-sarro-khan")
	check(profile.source_book_id == "000000139" and profile.source_datasheet_id == "000002709" and profile.source_export_updated_at == "2026-10-16T21:03:46+03:00", "Kor'sarro uses the local shared-book Wahapedia export")
	check(profile.points_by_models == {1: 80} and profile.max_supported_copies == 1 and profile.base_size_source_mm == 40 and profile.base_radius_inches == 20.0 / 25.4, "Kor'sarro is one Epic Hero model at the source cost and base size")
	check(profile.stats == {"movement_inches": 6, "toughness": 5, "save_target": 3, "wounds": 5, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 4}, "Kor'sarro's characteristics match the local export")
	check(profile.keywords == ["INFANTRY", "CHARACTER", "EPIC HERO", "CAPTAIN", "TACTICUS", "IMPERIUM", "EXPLOSIVES", "ADEPTUS ASTARTES", "WHITE SCARS"], "Chapter, faction and model keyword set matches the source")
	check(profile.ranged[0].profiles.standard == {"name": "Anzuq", "range_inches": 18.0, "attacks": 2, "skill": 3, "strength": 4, "ap": -1, "damage": 2, "keywords": {"close-quarters": true, "devastating-wounds": true, "anti-infantry": 4}, "target_required_traits": {"devastating-wounds": ["INFANTRY"]}}, "Anzuq retains Close-Quarters, Infantry-only Devastating Wounds and Anti-Infantry 4+")
	check(profile.ranged[1].profiles.standard.keywords == {"close-quarters": true} and profile.melee[0].profiles.standard.keywords == {"anti-character": 5, "precision": true, "devastating-wounds": true}, "Bolt Pistol and Moonfang weapon rules match the source")
	check(Catalog.SPECS.get("kor-sarro-khan", {}).get("current_reference", false) and Roster.POINTS.get("kor-sarro-khan", {}).get("sizes", {}) == {1: 80}, "Kor'sarro is reconciled at 80 points")
	var leaders: Array = Leaders.ATTACHMENTS.get("40kdc:11e:adeptus-astartes:kor-sarro-khan", [])
	check(leaders.size() == 6 and "40kdc:11e:adeptus-astartes:vanguard-veteran-squad" in leaders and "40kdc:11e:adeptus-astartes:vanguard-veteran-squad-with-jump-packs" not in leaders, "Leader link list matches all six exact source targets")

	var selections := F.current_marine_selections()
	selections[1].entries.append({"definition_id": "40kdc:11e:adeptus-astartes:kor-sarro-khan", "models": 1, "copies": 1})
	selections[1].entries.append({"definition_id": "40kdc:11e:adeptus-astartes:bladeguard-veteran-squad", "models": 3, "copies": 1})
	selections[2].entries.append({"definition_id": "40kdc:11e:adeptus-astartes:captain", "models": 1, "copies": 1})
	var state: Dictionary = F.P.initial_state({"unit_abilities": true, "combat_doctrines": true, "core_stratagems": true, "reanimation_protocols": true, "awakened_dynasty": true, "attack_rerolls": true, "manual_allocation": false}, selections)
	check(not state.has("error"), "Both players' current Space Marines rosters materialize from the local catalog")
	if state.has("error"): print(state.error)
	if not state.has("error"):
		var khan := find_model(state, 1, "kor-sarro-khan")
		var bodyguard := find_squad(state, 1, "bladeguard-veteran-squad")
		var character := find_squad(state, 2, "captain")
		var infantry := find_squad(state, 2, "intercessor-squad")
		check(khan > 0 and bodyguard > 0 and character > 0 and infantry > 0, "All selected units materialize")
		if khan > 0 and bodyguard > 0 and character > 0 and infantry > 0:
			for failure: String in DatasheetChecks.fixed_weapon_plan_failures(state, Profiles.profile("kor-sarro-khan"), khan, infantry):
				check(false, "Kor'sarro weapon plan: " + failure)
			var khan_squad := int(state.units[khan].squad)
			for model: int in Geometry.alive(state, bodyguard): state.units[model].position = Vector2.ZERO
			for model: int in Geometry.alive(state, character): state.units[model].position = Vector2(1.5, 0)
			for model: int in Geometry.alive(state, infantry): state.units[model].position = Vector2(1.5, 2)
			state.units[khan].position = Vector2.ZERO
			check(Abilities.has(state, khan_squad, "leader") and Abilities.has(state, khan_squad, "trophy-taker") and Abilities.has(state, khan_squad, "for-the-khan") and Abilities.has(state, khan_squad, "combat-doctrines") and Abilities.has(state, khan_squad, "transhuman-strategist"), "Core, faction and both named Khan abilities register")
			check(F.C.UnitActions.attachment_allowed(state, khan, bodyguard), "Kor'sarro can join an allowed source target")
			var character_attack := AttackPlan.prepare(state, khan_squad, true, [{"model": khan, "target": character, "amount": 6, "weapon": "moonfang", "profile": "standard"}], true)
			var infantry_attack := AttackPlan.prepare(state, khan_squad, true, [{"model": khan, "target": infantry, "amount": 6, "weapon": "moonfang", "profile": "standard"}], true)
			check(character_attack.error.is_empty() and character_attack.batches[0].context.hit_reroll == "ones" and character_attack.batches[0].context.wound_reroll == "ones", "Trophy Taker re-rolls hit and wound rolls of 1 against Characters")
			check(infantry_attack.error.is_empty() and infantry_attack.batches[0].context.get("hit_reroll", "none") != "ones" and infantry_attack.batches[0].context.get("wound_reroll", "none") != "ones", "Trophy Taker does not affect non-Character targets")
			F.C.UnitActions.attach(state, khan, bodyguard)
			check(int(state.units[khan].squad) == bodyguard and state.squads[bodyguard].attached, "Kor'sarro forms an attached unit with the selected bodyguard")
			var bodyguard_model := Geometry.alive(state, bodyguard)[0]
			var ranged := Abilities.weapon(state, bodyguard_model, character, Profiles.profile("kor-sarro-khan").ranged[1].profiles.standard, false)
			var melee := Abilities.weapon(state, bodyguard_model, character, Profiles.profile("kor-sarro-khan").melee[0].profiles.standard, true)
			check(ranged.keywords.get("assault", false) and melee.keywords.get("lance", false), "For the Khan! grants Assault and Lance across the Attached unit")

	var anti_weapon := {"name": "Anzuq", "range_inches": 18.0, "attacks": 2, "skill": 3, "strength": 4, "ap": -1, "damage": 2, "keywords": {"anti-infantry": 4, "devastating-wounds": true}}
	var defender := {"toughness": 7, "save_target": 3, "invulnerable_target": 0, "wounds_per_model": 5, "remaining_wounds": [5], "prevention": [[]]}
	var result := AttackSequence.roll_pool(anti_weapon, defender, {"target_keywords": ["INFANTRY"], "defer_saves": true}, func() -> int: return 4)
	check(result.error.is_empty() and result.critical_wounds == 2 and result.devastating_wounds == 2, "Anti-Infantry 4+ produces critical wounds and applies Devastating Wounds")
	var checkpoint := AttackRollWindow.begin(anti_weapon, defender, {"target_keywords": ["INFANTRY"], "defer_saves": true}, func() -> int: return 4)
	if str(checkpoint.get("error", "")).is_empty():
		checkpoint = AttackRollWindow.advance(checkpoint, checkpoint.revision, func() -> int: return 4)
		check(str(checkpoint.get("error", "")).is_empty(), "The interactive attack window advances from hits to wounds")
		checkpoint = AttackRollWindow.advance(checkpoint, checkpoint.revision, func() -> int: return 4)
		check(checkpoint.phase == "complete" and checkpoint.result.critical_wounds == 2 and checkpoint.result.devastating_wounds == 2, "Interactive hit/wound checkpoints preserve Anti-Infantry critical wounds")
	else:
		print(checkpoint)
		check(false, "Anti-Infantry validates in the interactive attack window")
	var anti_character := {"name": "Moonfang", "range_inches": 0.0, "attacks": 1, "skill": 2, "strength": 6, "ap": -3, "damage": 2, "keywords": {"anti-character": 5, "precision": true, "devastating-wounds": true}}
	var character_result := AttackSequence.roll_pool(anti_character, defender, {"target_keywords": ["CHARACTER"], "defer_saves": true}, func() -> int: return 5)
	check(character_result.error.is_empty() and character_result.critical_wounds == 1 and character_result.devastating_wounds == 1, "Anti-Character 5+ functions with Precision and Devastating Wounds")
	print("Kor'sarro Khan local checks: %d failures" % failures)
	quit(1 if failures else 0)

func _initialize() -> void:
	call_deferred("run")
