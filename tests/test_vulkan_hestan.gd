extends SceneTree
const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const P = preload("res://scripts/edition_11/prepared_training.gd")
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Catalog = preload("res://scripts/edition_11/army_capabilities.gd")
const Prevention = preload("res://scripts/edition_11/unit_prevention.gd")
const Morale = preload("res://scripts/edition_11/morale.gd")
const WeaponChecks = preload("res://tests/space_marine_datasheet_checks.gd")
const WoundPrevention = preload("res://scripts/edition_11/wound_prevention.gd")
const PublicUnitCommand = preload("res://tests/public_unit_command.gd")
const MatchCommands = preload("res://scripts/edition_11/match_command_service.gd")
var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func entry(identity: String, models: int) -> Dictionary:
	return {"definition_id": "40kdc:11e:adeptus-astartes:%s" % identity, "models": models, "copies": 1}

func find_model(state: Dictionary, owner: int, identity: String) -> int:
	for model: int in state.units:
		if state.units[model].owner == owner and C.UnitAbilities.identity(state.units[model]) == identity: return model
	return -1

func find_squad(state: Dictionary, owner: int, identity: String, occurrence: int = 0) -> int:
	for squad: int in state.squads:
		if int(state.squads[squad].owner) != owner: continue
		var members: Array[int] = C.living(state, squad)
		if members.is_empty() or C.UnitAbilities.identity(state.units[members[0]]) != identity: continue
		if occurrence > 0:
			occurrence -= 1
			continue
		return squad
	return -1

func ranged_profile_with_keyword(state: Dictionary, model: int, keyword: String) -> Dictionary:
	for weapon: Dictionary in state.units[model].get("ranged_weapons", []):
		for profile_id: String in weapon.get("profiles", {}):
			var stats: Dictionary = weapon.profiles[profile_id]
			var keywords: Dictionary = stats.get("keywords", {})
			var present := bool(keywords.get(keyword, false)) if keyword == "torrent" else int(keywords.get(keyword, 0)) > 0
			if present:
				return {"weapon_id": str(weapon.get("id", "")), "profile_id": profile_id, "stats": stats}
	return {}

func find_choice(state: Dictionary, player: int, action: String, model: int = -1, target: int = -1) -> Dictionary:
	for option: Dictionary in C.UnitActions.choices(state, player):
		if option.action == action and (model < 0 or option.model == model) and (target < 0 or option.target == target): return option
	return {}

func apply_choice(state: Dictionary, player: int, action: String, model: int = -1) -> String:
	var option := find_choice(state, player, action, model)
	if option.is_empty(): return "Choice not offered: " + action
	var result: Dictionary = PublicUnitCommand.submit(state, player, option, Vector2.ZERO, func() -> int: return 6)
	return str(result.get("error", ""))

func _initialize() -> void: call_deferred("run")

func run() -> void:
	var profile := Profiles.profile("vulkan-hestan")
	check(profile.source_book_id == "000000139" and profile.source_datasheet_id == "000002726" and profile.source_export_updated_at == "2026-10-16T21:03:46+03:00", "Vulkan follows the local Wahapedia e11 source record")
	check(profile.points_by_models == {1: 105} and profile.models == 1 and profile.base_size_source_mm == 40, "Vulkan cost, composition and base match the export")
	check(profile.stats == {"movement_inches": 6, "toughness": 5, "save_target": 2, "wounds": 5, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 4}, "Vulkan characteristics, including the 4+ invulnerable save, match the export")
	check(profile.keywords.has("SALAMANDERS") and profile.keywords.has("TACTICUS") and profile.keywords.has("EXPLOSIVES") and profile.keywords.has("EPIC HERO"), "Vulkan source keywords are present")
	check(profile.ranged.size() == 2 and profile.ranged[1].profiles.standard.attacks == "D6+3" and profile.ranged[1].profiles.standard.skill == 0 and profile.ranged[1].profiles.standard.keywords.torrent, "Gauntlet of the Forge preserves its Torrent attack profile")
	check(profile.melee[0].profiles.standard.keywords.get("devastating-wounds", false), "Spear of Vulkan preserves Devastating Wounds")
	var catalog_row := Catalog.current_catalog_choice({"id": "40kdc:11e:adeptus-astartes:vulkan-hestan", "edition": "11e", "faction": "Space Marines", "options": [{"models": 1, "cost": 105}]})
	check(Catalog.SPECS.get("vulkan-hestan", {}).get("current_reference", false) and catalog_row.get("options", []).size() == 1 and catalog_row.options[0].cost == 105, "Vulkan is published at the local source cost in the consolidated construction catalog")
	var valid_roster := {"schema_version": 2, "faction": "Space Marines", "category": "incursion", "points_limit": 1000, "entries": [entry("vulkan-hestan", 1)]}
	var duplicate_roster: Dictionary = valid_roster.duplicate(true)
	duplicate_roster.entries[0].copies = 2
	check(Catalog.admit(valid_roster).get("error", "").is_empty() and not Catalog.admit(duplicate_roster).get("error", "").is_empty(), "The local catalog admits one Vulkan and enforces his Epic Hero copy limit")

	var selections := F.current_marine_selections()
	selections[1].entries = [entry("vulkan-hestan", 1), entry("assault-intercessor-squad", 5), entry("intercessor-squad", 5), entry("eradicator-squad-with-melta-rifles", 3), entry("infernus-squad", 5)]
	selections[2].entries = [entry("intercessor-squad", 5), entry("intercessor-squad", 10), entry("assault-intercessor-squad", 5)]
	var state: Dictionary = P.initial_state({"unit_abilities": true, "reanimation_protocols": true, "combat_doctrines": true, "awakened_dynasty": true, "core_stratagems": true, "attack_rerolls": true, "manual_allocation": false}, selections)
	check(not state.has("error"), "Vulkan is admitted into the prepared local Marine match")
	if state.has("error"):
		print("Vulkan local checks: %d failures" % (failures + 1))
		quit(1)
		return
	state.awakened_dynasty.pending.clear()
	var vulkan := find_model(state, 1, "vulkan-hestan")
	var squad: int = state.units[vulkan].squad if vulkan >= 0 else -1
	var intercessor := find_model(state, 1, "assault-intercessor-squad")
	var regular_intercessor := find_model(state, 1, "intercessor-squad")
	var eradicator := find_model(state, 1, "eradicator-squad-with-melta-rifles")
	var infernus := find_model(state, 1, "infernus-squad")
	var enemy := find_model(state, 2, "intercessor-squad")
	check(vulkan >= 0 and C.UnitAbilities.has(state, squad, "feel-no-pain-6") and C.UnitAbilities.has(state, squad, "leader") and C.UnitAbilities.has(state, squad, "combat-doctrines") and C.UnitAbilities.has(state, squad, "transhuman-strategist") and C.UnitAbilities.has(state, squad, "seeker-of-the-unfound") and C.UnitAbilities.has(state, squad, "forgefather"), "Vulkan's Feel No Pain 6+, Leader, faction and datasheet abilities register")
	check(vulkan >= 0 and Prevention.rules(state, vulkan).has({"target": 6, "against": "any"}), "Vulkan begins with the source-listed Feel No Pain 6+")
	check(intercessor >= 0 and regular_intercessor >= 0 and eradicator >= 0 and infernus >= 0 and enemy >= 0 and C.UnitActions.attachment_allowed(state, vulkan, int(state.units[intercessor].squad)), "Vulkan can lead a source-listed, locally admitted Assault Intercessor Squad")
	check(not C.UnitActions.attachment_allowed(state, vulkan, int(state.units[regular_intercessor].squad)), "Vulkan cannot lead an unlisted Intercessor Squad")
	check(C.UnitActions.attachment_allowed(state, vulkan, find_squad(state, 1, "eradicator-squad-with-melta-rifles")) and C.UnitActions.attachment_allowed(state, vulkan, find_squad(state, 1, "infernus-squad")), "Vulkan can lead source-listed Melta Rifle Eradicators and Infernus Squads")
	check(C.UnitAbilities.identity(state.units[enemy]) == "intercessor-squad" and int(state.units[enemy].owner) == 2, "The opposing roster materializes from the current local Marine catalog")
	if vulkan < 0 or enemy < 0 or eradicator < 0 or infernus < 0:
		print("Vulkan local checks: %d failures" % failures)
		quit(1)
		return
	var enemy_squad: int = int(state.units[enemy].squad)
	var fixed_weapon_failures := WeaponChecks.fixed_weapon_plan_failures(state, profile, vulkan, enemy_squad)
	check(fixed_weapon_failures.is_empty(), "All three fixed Vulkan weapons pass Equipment and AttackPlan: %s" % str(fixed_weapon_failures))

	var warlord := find_choice(state, 1, "warlord", vulkan)
	check(not warlord.is_empty(), "Vulkan is offered as Warlord during army preparation")
	if not warlord.is_empty():
		var warlord_result: Dictionary = PublicUnitCommand.submit(state, 1, warlord, Vector2.ZERO, func() -> int: return 6)
		check(warlord_result.get("error", "").is_empty(), "Vulkan Warlord declaration applies")
		state.active = 1
		state.round = 1
		state.cp[1] = 0
		C.UnitActions.start_round(state)
		check(state.cp[1] == 1, "Transhuman Strategist grants 1 CP when Vulkan is Warlord")
		C.UnitActions.start_round(state)
		check(state.cp[1] == 1, "Vulkan grants Warlord CP only once per battle round")

	state.phase = "deployment"
	state.unit_abilities.setup_players = [1, 2]
	state.deployment.order = [squad]
	state.deployment.index = 0
	state.deployment.complete = false
	state.deployment.placed = {vulkan: true}
	state.units[vulkan].position = Vector2(-12, 0)
	state.terrain.areas = []
	state.mission.objectives = [{"name": "Vulkan test marker", "kind": "marker", "position": Vector2(-12, 0), "controller": 0, "secured": 0, "levels": {1: 0, 2: 0}}]
	check(C.Deployment.confirm_error(state).contains("Seeker of the Unfound"), "Deployment cannot finish until Vulkan chooses an objective")
	state.deployment.order = [int(state.units[intercessor].squad), squad]
	state.deployment.index = 0
	check(not find_choice(state, 1, "seeker-objective", vulkan).is_empty(), "Seeker remains available during deployment if the player advances to another unit")
	state.deployment.order = [squad]
	state.deployment.index = 0
	var seeker := find_choice(state, 1, "seeker-objective", vulkan)
	var seeker_decision := C.UnitActions.pending_decision(state)
	var seeker_option: Dictionary = {}
	for option: Dictionary in seeker_decision.get("legal_options", []):
		if str(option.get("action", "")) == "seeker-objective" and int(option.get("model", -1)) == vulkan and int(option.get("target", -1)) == int(seeker.get("target", -1)): seeker_option = option
	check(seeker_decision.get("priority_player_id", -1) == 1 and seeker_decision.get("timing", "") == "deployment:unit-choice" and not seeker_option.is_empty(), "The deploying player receives a normalized Seeker of the Unfound decision")
	var before_wrong_seeker := var_to_bytes(state)
	var wrong_seeker := MatchCommands.execute(state, 2, {"kind": MatchCommands.SELECT_UNIT_CHOICE, "revision": state.revision, "choice": {"_decision_type": MatchCommands.UNIT_CHOICE_ENVELOPE, "decision_id": str(seeker_decision.get("decision_id", "")), "option_id": str(seeker_option.get("id", "")), "choice": seeker}}, func() -> int: return 6)
	check(not str(wrong_seeker.get("error", "")).is_empty() and var_to_bytes(state) == before_wrong_seeker, "The opponent cannot submit or mutate the deploying player's Seeker decision")
	var before_stale_seeker := var_to_bytes(state)
	var stale_seeker := MatchCommands.execute(state, 1, {"kind": MatchCommands.SELECT_UNIT_CHOICE, "revision": state.revision, "choice": {"_decision_type": MatchCommands.UNIT_CHOICE_ENVELOPE, "decision_id": str(seeker_decision.get("decision_id", "")), "option_id": "stale-seeker-option", "choice": seeker}}, func() -> int: return 6)
	check(not str(stale_seeker.get("error", "")).is_empty() and var_to_bytes(state) == before_stale_seeker, "A stale deployment option is rejected without changing the match")
	state = bytes_to_var(var_to_bytes(state))
	var restored_seeker_decision := C.UnitActions.pending_decision(state)
	check(restored_seeker_decision.get("decision_id", "") == seeker_decision.get("decision_id", "") and restored_seeker_decision.get("legal_options", []).any(func(option: Dictionary) -> bool: return option.get("id", "") == seeker_option.get("id", "")), "The deployment choice keeps its decision and option identities through save/restore")
	var seeker_error := apply_choice(state, 1, "seeker-objective", vulkan)
	check(seeker_error.is_empty(), "Seeker of the Unfound selects an objective after Vulkan is placed: " + seeker_error)
	check(C.Deployment.confirm_error(state).is_empty(), "The source-required objective choice clears the deployment gate")
	check(Morale.objective_control(state, vulkan) == 10 and Morale.leadership(state, squad).target == 5, "Vulkan gains OC 10 and Leadership 5+ while within range of his selected objective")
	check(Prevention.rules(state, vulkan).has({"target": 4, "against": "any"}), "Seeker of the Unfound grants Vulkan Feel No Pain 4+ at the selected objective")
	var seeker_fnp := WoundPrevention.resolve(1, 1, Prevention.rules(state, vulkan), "normal", func() -> int: return 4)
	check(seeker_fnp.get("error", "").is_empty() and seeker_fnp.target == 4 and seeker_fnp.prevented == 1, "Seeker improves Vulkan's actual wound-prevention roll to Feel No Pain 4+")
	state.units[vulkan].position = Vector2(0, 0)
	check(Morale.objective_control(state, vulkan) == 1 and Morale.leadership(state, squad).target == 6 and not Prevention.rules(state, vulkan).has({"target": 4, "against": "any"}) and Prevention.rules(state, vulkan).has({"target": 6, "against": "any"}), "Seeker bonuses end when Vulkan leaves objective range and his source Feel No Pain 6+ remains")
	var base_fnp := WoundPrevention.resolve(1, 1, Prevention.rules(state, vulkan), "normal", func() -> int: return 6)
	check(base_fnp.get("error", "").is_empty() and base_fnp.target == 6 and base_fnp.prevented == 1, "Vulkan's source Feel No Pain 6+ resolves after he leaves the selected objective")

	state.phase = "shooting"
	state.active = 1
	state.units[vulkan].position = Vector2(-12, 0)
	state.units[eradicator].position = Vector2(-9, 0)
	state.units[infernus].position = Vector2(-6, 0)
	var enemy_models := []
	for model: int in state.units:
		if state.units[model].owner == 2 and C.UnitAbilities.identity(state.units[model]) == "intercessor-squad": enemy_models.append(model)
	var unmarked_squad := find_squad(state, 2, "intercessor-squad", 1)
	var unmarked_models: Array[int] = C.living(state, unmarked_squad) if unmarked_squad >= 0 else []
	var distant_squad := find_squad(state, 2, "assault-intercessor-squad")
	var distant_models: Array[int] = C.living(state, distant_squad) if distant_squad >= 0 else []
	for index in range(enemy_models.size()): state.units[enemy_models[index]].position = Vector2(-2.0 + float(index) * 1.2, 4)
	for index in range(unmarked_models.size()): state.units[unmarked_models[index]].position = Vector2(2.0 + float(index) * 1.2, 4)
	for index in range(distant_models.size()): state.units[distant_models[index]].position = Vector2(16.0 + float(index) * 1.2, 4)
	var unmarked_target := unmarked_squad
	var forgefather := find_choice(state, 1, "forgefather-target", vulkan, enemy_squad)
	var unmarked_choice := find_choice(state, 1, "forgefather-target", vulkan, unmarked_target)
	var distant_choice := find_choice(state, 1, "forgefather-target", vulkan, distant_squad)
	check(not forgefather.is_empty() and not unmarked_choice.is_empty() and distant_choice.is_empty(), "Forgefather offers visible enemies within 24 inches and excludes the distant enemy")
	for index in range(distant_models.size()): state.units[distant_models[index]].position = Vector2(float(index) * 0.2, 0)
	state.terrain.areas = [{"name": "Opaque screen", "category": "dense", "bounds": Rect2(-7, -1, 1, 2), "features": [{"bounds": Rect2(-7, -1, 1, 2), "height": 4.0, "blocks_end": true}]}]
	var hidden_sight := C.Terrain.targeting(state, vulkan, distant_squad)
	check(not hidden_sight.visible and find_choice(state, 1, "forgefather-target", vulkan, distant_squad).is_empty(), "Forgefather excludes an enemy within 24 inches when opaque terrain blocks visibility")
	for index in range(distant_models.size()): state.units[distant_models[index]].position = Vector2(16.0 + float(index) * 1.2, 4)
	if not forgefather.is_empty():
		var marked := int(forgefather.target)
		var result: Dictionary = PublicUnitCommand.submit(state, 1, forgefather, Vector2.ZERO, func() -> int: return 6)
		check(result.get("error", "").is_empty(), "Forgefather target selection resolves")
		var melta_profile := ranged_profile_with_keyword(state, eradicator, "melta")
		var torrent_profile := ranged_profile_with_keyword(state, vulkan, "torrent")
		var ordinary_profile: Dictionary = state.units[intercessor].ranged_weapons[0].profiles.standard
		check(not melta_profile.is_empty() and not torrent_profile.is_empty(), "The current Eradicator and Vulkan catalogs expose real Melta and Torrent profiles")
		if not melta_profile.is_empty() and not torrent_profile.is_empty():
			var base_melta_strength := int(melta_profile.stats.strength)
			var base_torrent_strength := int(torrent_profile.stats.strength)
			var improved_melta := C.UnitAbilities.weapon(state, eradicator, marked, melta_profile.stats, false)
			var improved_torrent := C.UnitAbilities.weapon(state, vulkan, marked, torrent_profile.stats, false)
			var unmarked_melta := C.UnitAbilities.weapon(state, eradicator, unmarked_target, melta_profile.stats, false)
			var ordinary_attack := C.UnitAbilities.weapon(state, intercessor, marked, ordinary_profile, false)
			check(improved_melta.strength == base_melta_strength + 2 and improved_torrent.strength == base_torrent_strength + 2 and unmarked_melta.strength == base_melta_strength and ordinary_attack.strength == int(ordinary_profile.strength), "Forgefather adds +2 Strength only to Melta/Torrent attacks against the selected enemy")
			var melta_plan := C.AttackPlan.prepare(state, int(state.units[eradicator].squad), false, [{"model": eradicator, "target": marked, "weapon": melta_profile.weapon_id, "profile": melta_profile.profile_id, "amount": 1}], false)
			var torrent_plan := C.AttackPlan.prepare(state, squad, false, [{"model": vulkan, "target": marked, "weapon": torrent_profile.weapon_id, "profile": torrent_profile.profile_id, "amount": 1}], false)
			var unmarked_plan := C.AttackPlan.prepare(state, int(state.units[eradicator].squad), false, [{"model": eradicator, "target": unmarked_target, "weapon": melta_profile.weapon_id, "profile": melta_profile.profile_id, "amount": 1}], false)
			check(melta_plan.get("error", "").is_empty() and melta_plan.batches.size() == 1 and melta_plan.batches[0].weapon.strength == base_melta_strength + 2, "The selected Eradicator Melta AttackPlan applies Forgefather's +2 Strength")
			check(torrent_plan.get("error", "").is_empty() and torrent_plan.batches.size() == 1 and torrent_plan.batches[0].weapon.strength == base_torrent_strength + 2, "Vulkan's actual Gauntlet of the Forge AttackPlan applies Forgefather's +2 Strength")
			check(unmarked_plan.get("error", "").is_empty() and unmarked_plan.batches.size() == 1 and unmarked_plan.batches[0].weapon.strength == base_melta_strength, "The unmarked enemy receives no Forgefather Melta bonus")
		check(find_choice(state, 1, "forgefather-target", vulkan).is_empty(), "Forgefather selects one target in the Shooting phase")

	print("Vulkan He’stan local checks: %d failures" % failures)
	quit(1 if failures else 0)
