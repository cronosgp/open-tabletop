extends SceneTree
const F = preload("res://tests/all_units_fixture.gd")
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Catalog = preload("res://scripts/edition_11/army_capabilities.gd")
const Attachments = preload("res://scripts/edition_11/attached_units.gd")
const Prevention = preload("res://scripts/edition_11/unit_prevention.gd")
const Doctrines = preload("res://scripts/edition_11/combat_doctrines.gd")
const DatasheetChecks = preload("res://tests/space_marine_datasheet_checks.gd")
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

func entry(identity: String, models: int = 1) -> Dictionary:
	return {"definition_id": "40kdc:11e:adeptus-astartes:%s" % identity, "models": models, "copies": 1}

func run() -> void:
	var profile := Profiles.profile("kaius-konorius")
	check(profile.source_book_id == "000000139" and profile.source_datasheet_id == "000004248" and profile.source_export_updated_at == "2026-10-16T21:03:46+03:00", "Kaius cites the pinned local Wahapedia 11e export")
	check(profile.points_by_models == {1: 100} and profile.max_supported_copies == 1 and profile.models == 1 and is_equal_approx(profile.base_radius_inches, 20.0 / 25.4) and profile.stats == {"movement_inches": 6, "toughness": 5, "save_target": 2, "wounds": 5, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 4}, "Kaius composition, characteristics, 40 mm base and cost match the export")
	check(profile.keywords == ["INFANTRY", "CHARACTER", "EPIC HERO", "EXPLOSIVES", "TACTICUS", "ULTRAMARINES", "ADEPTUS ASTARTES"], "Kaius source keywords are recorded")
	check(profile.ranged[0].profiles.standard.attacks == 1 and profile.ranged[0].profiles.standard.skill == 2 and profile.ranged[0].profiles.standard.keywords == {"close-quarters": true}, "Heavy Bolt Pistol matches the export")
	check(profile.melee[0].profiles.strike.attacks == 5 and profile.melee[0].profiles.strike.keywords == {"precision": true} and profile.melee[0].profiles.sweep.attacks == 6 and profile.melee[0].profiles.sweep.keywords == {"cleave": 2}, "Both Severance and Rebuke profiles match the export")
	check(profile.ranged.size() == 1 and profile.melee.size() == 1 and profile.get("additional_weapon_profiles", {}).is_empty(), "Kaius has only his fixed source weapons and no alternate weapon profiles")
	var identity := "40kdc:11e:adeptus-astartes:kaius-konorius"
	var catalog := Catalog.current_catalog_choice({"id": identity, "edition": "11e", "faction": "Space Marines"})
	check(catalog.get("options", []) == [{"models": 1, "cost": 100, "third_plus_cost": 100}], "Kaius publishes the exact one-model source cost after the check gate is lifted")
	check(Catalog.resolve("Space Marines", identity).get("error", "").is_empty(), "Kaius resolves through the admitted current-reference catalog")

	var selections := F.current_marine_selections()
	selections[1].entries = [entry("kaius-konorius"), entry("captain"), entry("bladeguard-veteran-squad", 3), entry("assault-intercessor-squad", 5), entry("sternguard-veteran-squad", 5), entry("victrix-honour-guard", 3)]
	selections[2].entries = [entry("caanok-var"), entry("intercessor-squad", 5)]
	var state: Dictionary = F.P.initial_state({"unit_abilities": true, "reanimation_protocols": true, "combat_doctrines": true, "awakened_dynasty": true, "core_stratagems": true, "attack_rerolls": true, "manual_allocation": false}, selections)
	check(not state.has("error"), "Kaius and the current-catalog Marine units resolve for both players")
	if state.has("error"):
		print("Kaius setup error: ", state.get("error", ""), " keys=", state.keys())
	if not state.has("error"):
		var kaius := find_unit(state, 1, "kaius-konorius")
		var captain := find_unit(state, 1, "captain")
		var bladeguard := find_unit(state, 1, "bladeguard-veteran-squad")
		var assault_intercessors := find_unit(state, 1, "assault-intercessor-squad")
		var sternguard := find_unit(state, 1, "sternguard-veteran-squad")
		var victrix := find_unit(state, 1, "victrix-honour-guard")
		var character_target := find_unit(state, 2, "caanok-var")
		var ordinary_target := find_unit(state, 2, "intercessor-squad")
		check(kaius > 0 and captain > 0 and bladeguard > 0 and assault_intercessors > 0 and sternguard > 0 and victrix > 0 and character_target > 0 and ordinary_target > 0, "Kaius, a Captain, all four source-listed Support targets and both Marine test targets materialize")
		if kaius > 0 and captain > 0 and bladeguard > 0 and assault_intercessors > 0 and sternguard > 0 and victrix > 0 and character_target > 0 and ordinary_target > 0:
			var bodyguard := int(state.units[bladeguard].squad)
			var kaius_squad := int(state.units[kaius].squad)
			var captain_squad := int(state.units[captain].squad)
			check(A.has(state, kaius_squad, "support") and A.has(state, kaius_squad, "combat-doctrines") and A.has(state, kaius_squad, "veteran-bodyguard") and A.has(state, kaius_squad, "calgars-champion") and U.is_support_identity(state, state.units[kaius]), "Kaius registers as Support with Combat Doctrines and both named abilities")
			state.combat_doctrines.active[1] = "devastator"
			check(Doctrines.active_doctrines_for(state, kaius_squad).has("devastator"), "Kaius receives the active army Combat Doctrine through its source ability")
			check(U.attachment_allowed(state, kaius, bodyguard) and U.attachment_allowed(state, kaius, int(state.units[assault_intercessors].squad)) and U.attachment_allowed(state, kaius, int(state.units[sternguard].squad)) and U.attachment_allowed(state, kaius, int(state.units[victrix].squad)), "Kaius can attach to all four source-listed Support targets")
			check(not U.attachment_allowed(state, kaius, int(state.units[ordinary_target].squad)), "Kaius cannot attach to an unlisted Intercessor unit")
			for failure: String in DatasheetChecks.fixed_weapon_plan_failures(state, profile, kaius, int(state.units[ordinary_target].squad)):
				check(false, "Kaius source weapon plan: " + failure)
			state.phase = "deployment"
			state.awakened_dynasty.pending = []
			var kaius_warlord_available := false
			for option: Dictionary in U.choices(state, 1):
				if option.action == "warlord" and option.model == kaius: kaius_warlord_available = true
			check(kaius_warlord_available, "Kaius is eligible to be designated as Warlord")
			var kaius_attachment_available := false
			for option: Dictionary in U.choices(state, 1):
				if option.action == "attach" and option.model == kaius and option.target == bodyguard: kaius_attachment_available = true
			check(kaius_attachment_available, "Kaius's support attachment is offered during army preparation")
			check(Prevention.rules(state, captain).is_empty(), "Veteran Bodyguard does not protect a Character while Kaius is unattached")
			state.revision = 0
			state.turn = 1
			state.phase = "start_turn"
			var attach_error := Attachments.form_practice_unit(state, bodyguard, captain_squad, kaius_squad, true)
			check(attach_error.is_empty(), "Captain as Leader and Kaius as Support form the source-valid attachment: " + attach_error)
			if attach_error.is_empty():
				var captain_rules: Array = Prevention.rules(state, captain)
				check({"target": 4, "against": "any"} in captain_rules, "Veteran Bodyguard grants Feel No Pain 4+ to the other attached Character")
				check({"target": 4, "against": "any"} not in Prevention.rules(state, kaius), "Veteran Bodyguard does not grant its bearer the other-Character benefit")
				state.phase = "fight"
				state.units[kaius].position = Vector2.ZERO
				state.units[character_target].position = Vector2(0.5, 0)
				state.units[ordinary_target].position = Vector2(0.5, 1)
				var squad := int(state.units[kaius].squad)
				var character_attack := F.C.AttackPlan.prepare(state, squad, true, [{"model": kaius, "target": state.units[character_target].squad, "amount": 5, "weapon": "severance-and-rebuke", "profile": "strike"}], true)
				check(character_attack.error.is_empty() and character_attack.batches[0].context.hit_reroll == "ones" and character_attack.batches[0].context.wound_reroll == "ones", "Calgar's Champion re-rolls hit and wound rolls of 1 against a Character unit")
				var ordinary_attack := F.C.AttackPlan.prepare(state, squad, true, [{"model": kaius, "target": state.units[ordinary_target].squad, "amount": 5, "weapon": "severance-and-rebuke", "profile": "strike"}], true)
				check(ordinary_attack.error.is_empty() and ordinary_attack.batches[0].context.get("hit_reroll", "none") != "ones" and ordinary_attack.batches[0].context.get("wound_reroll", "none") != "ones", "Calgar's Champion does not apply against a non-Character unit")
	print("Kaius Konorius local checks: %d failures" % failures)
	quit(1 if failures else 0)

func _initialize() -> void:
	call_deferred("run")
