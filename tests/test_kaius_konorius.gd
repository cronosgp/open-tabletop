extends SceneTree
const F = preload("res://tests/all_units_fixture.gd")
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Catalog = preload("res://scripts/edition_11/army_capabilities.gd")
const Attachments = preload("res://scripts/edition_11/attached_units.gd")
const Prevention = preload("res://scripts/edition_11/unit_prevention.gd")
const A = F.C.UnitAbilities
const U = F.C.UnitActions
var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func find_unit(state: Dictionary, owner: int, identity: String) -> int:
	for model: int in state.units:
		if state.units[model].owner == owner and A.identity(state.units[model]) == identity: return model
	return -1

func run() -> void:
	var profile := Profiles.profile("kaius-konorius")
	check(profile.source_book_id == "000000139" and profile.source_datasheet_id == "000004248" and profile.source_export_updated_at == "2026-10-16T21:03:46+03:00", "Kaius cites the pinned local Wahapedia 11e export")
	check(profile.points_by_models == {1: 100} and profile.max_supported_copies == 1 and profile.stats == {"movement_inches": 6, "toughness": 5, "save_target": 2, "wounds": 5, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 4}, "Kaius characteristics, 40 mm base and cost match the export")
	check(profile.keywords.has("ULTRAMARINES") and profile.keywords.has("TACTICUS") and profile.keywords.has("EPIC HERO"), "Kaius source keywords are recorded")
	check(profile.ranged[0].profiles.standard.attacks == 1 and profile.ranged[0].profiles.standard.skill == 2 and profile.ranged[0].profiles.standard.keywords == {"close-quarters": true}, "Heavy Bolt Pistol matches the export")
	check(profile.melee[0].profiles.strike.attacks == 5 and profile.melee[0].profiles.strike.keywords == {"precision": true} and profile.melee[0].profiles.sweep.attacks == 6 and profile.melee[0].profiles.sweep.keywords == {"cleave": 2}, "Both Severance and Rebuke profiles match the export")
	var identity := "40kdc:11e:adeptus-astartes:kaius-konorius"
	var catalog := Catalog.current_catalog_choice({"id": identity, "edition": "11e", "faction": "Space Marines"})
	check(catalog.get("options", []) == [{"models": 1, "cost": 100, "third_plus_cost": 100}], "Kaius publishes the exact one-model source cost after the check gate is lifted")
	check(Catalog.resolve("Space Marines", identity).get("error", "").is_empty(), "Kaius resolves through the admitted current-reference catalog")

	var selections := F.selections()
	var own_entries: Array = []
	for entry: Dictionary in selections[1].entries:
		if str(entry.definition_id).ends_with(":captain") or str(entry.definition_id).ends_with(":terminator-squad") or str(entry.definition_id).ends_with(":lieutenant"): continue
		own_entries.append(entry)
	selections[1].entries = own_entries
	selections[1].entries.append({"definition_id": identity, "models": 1, "copies": 1})
	selections[1].entries.append({"definition_id": "40kdc:11e:adeptus-astartes:bladeguard-veteran-squad", "models": 3, "copies": 1})
	selections[1].entries.append({"definition_id": "40kdc:11e:adeptus-astartes:apothecary", "models": 1, "copies": 1})
	var state: Dictionary = F.P.initial_state({"unit_abilities": true, "reanimation_protocols": true, "combat_doctrines": true, "awakened_dynasty": true, "core_stratagems": true, "attack_rerolls": true, "manual_allocation": false}, selections)
	check(not state.has("error"), "Kaius, Bladeguard Veterans and an Apothecary resolve from the consolidated local catalog")
	if not state.has("error"):
		var kaius := find_unit(state, 1, "kaius-konorius")
		var bladeguard := find_unit(state, 1, "bladeguard-veteran-squad")
		var apothecary := find_unit(state, 1, "apothecary")
		var overlord := find_unit(state, 2, "overlord")
		var warriors := find_unit(state, 2, "necron-warriors")
		check(kaius > 0 and bladeguard > 0 and apothecary > 0 and overlord > 0 and warriors > 0, "Kaius and all test targets materialize")
		if kaius > 0 and bladeguard > 0 and apothecary > 0 and overlord > 0 and warriors > 0:
			var bodyguard := int(state.units[bladeguard].squad)
			check(U.attachment_allowed(state, kaius, bodyguard) and not U.attachment_allowed(state, kaius, int(state.units[warriors].squad)), "Kaius can attach only to a listed Marine bodyguard, not a Necron unit")
			state.phase = "deployment"
			state.awakened_dynasty.pending = []
			var kaius_warlord_available := false
			for option: Dictionary in U.choices(state, 1):
				if option.action == "warlord" and option.model == kaius: kaius_warlord_available = true
			check(kaius_warlord_available, "Kaius is eligible to be designated as Warlord")
			check(Prevention.rules(state, apothecary).is_empty(), "Veteran Bodyguard does not protect a Character while Kaius is unattached")
			state.revision = 0
			state.turn = 1
			state.phase = "start_turn"
			var attach_error := Attachments.form_practice_unit(state, bodyguard, int(state.units[kaius].squad), int(state.units[apothecary].squad), true)
			check(attach_error.is_empty(), "Kaius and Apothecary form the admitted Leader/Support attachment: " + attach_error)
			if attach_error.is_empty():
				var apothecary_rules: Array = Prevention.rules(state, apothecary)
				check({"target": 4, "against": "any"} in apothecary_rules, "Veteran Bodyguard grants Feel No Pain 4+ to the other attached Character")
				check({"target": 4, "against": "any"} not in Prevention.rules(state, kaius), "Veteran Bodyguard does not grant its bearer the other-Character benefit")
				state.phase = "fight"
				state.units[kaius].position = Vector2.ZERO
				state.units[overlord].position = Vector2(0.5, 0)
				state.units[warriors].position = Vector2(0.5, 1)
				var squad := int(state.units[kaius].squad)
				var character_attack := F.C.AttackPlan.prepare(state, squad, true, [{"model": kaius, "target": state.units[overlord].squad, "amount": 5, "weapon": "severance-and-rebuke", "profile": "strike"}], true)
				check(character_attack.error.is_empty() and character_attack.batches[0].context.hit_reroll == "ones" and character_attack.batches[0].context.wound_reroll == "ones", "Calgar's Champion re-rolls hit and wound rolls of 1 against a Character unit")
				var ordinary_attack := F.C.AttackPlan.prepare(state, squad, true, [{"model": kaius, "target": state.units[warriors].squad, "amount": 5, "weapon": "severance-and-rebuke", "profile": "strike"}], true)
				check(ordinary_attack.error.is_empty() and ordinary_attack.batches[0].context.get("hit_reroll", "none") != "ones" and ordinary_attack.batches[0].context.get("wound_reroll", "none") != "ones", "Calgar's Champion does not apply against a non-Character unit")
	print("Kaius Konorius local checks: %d failures" % failures)
	quit(1 if failures else 0)

func _initialize() -> void:
	call_deferred("run")
