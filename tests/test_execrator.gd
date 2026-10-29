extends SceneTree

const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Catalog = preload("res://scripts/edition_11/army_capabilities.gd")
const AbilityCatalog = preload("res://scripts/edition_11/unit_ability_catalog.gd")
const Registry = preload("res://scripts/edition_11/capabilities.gd")
const Links = preload("res://scripts/edition_11/marine_leader_links.gd")
const Enhancements = preload("res://scripts/edition_11/stormlance_enhancements.gd")
const Geometry = preload("res://scripts/edition_11/contact_movement.gd")
const PublicUnitCommand = preload("res://tests/public_unit_command.gd")
const DatasheetChecks = preload("res://tests/space_marine_datasheet_checks.gd")
const Execrator = preload("res://scripts/edition_11/execrator.gd")
const UNIT := "execrator"
const UNIT_ID := "40kdc:11e:adeptus-astartes:execrator"

var failures := 0
var dice: Array[int] = []
var dice_index := 0

func _initialize() -> void:
	call_deferred("run")

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func die() -> int:
	if dice_index >= dice.size(): return 4
	var result := dice[dice_index]
	dice_index += 1
	return result

func entry(identity: String, models_count: int = 1, enhancement_id: String = "") -> Dictionary:
	return {"definition_id": "40kdc:11e:adeptus-astartes:" + identity, "models": models_count, "copies": 1, "enhancement_id": enhancement_id}

func selections() -> Dictionary:
	return {
		1: {"schema_version": 2, "faction": "Space Marines", "category": "training", "points_limit": 500, "entries": [entry(UNIT), entry("crusader-squad", 10)]},
		2: {"schema_version": 2, "faction": "Space Marines", "category": "training", "points_limit": 500, "entries": [entry("captain-on-bike", 1, Enhancements.TEMPERED_IN_BATTLE), entry("outrider-squad", 3), entry("intercessor-squad", 5)]}
	}

func fixture() -> Dictionary:
	var state: Dictionary = F.P.initial_state({
		"checked_rosters": false, "official_mission": false, "unit_abilities": true,
		"combat_doctrines": true, "core_stratagems": true, "attack_rerolls": true,
		"manual_allocation": false,
		"marine_detachments": {1: "vow-sworn-crusaders", 2: Enhancements.WRATH_OF_THE_ROCK},
		"marine_chapters": {1: "BLACK TEMPLARS", 2: "DARK ANGELS"}
	}, selections())
	if state.has("error"): return state
	state.phase = "deployment"
	state.active = 1
	state.turn = 1
	state.round = 1
	state.unit_abilities.window = {}
	return state

func model_for(state: Dictionary, owner: int, identity: String) -> int:
	for model: int in state.units:
		if int(state.units[model].get("owner", -1)) == owner and C.UnitAbilities.identity(state.units[model]) == identity: return model
	return -1

func option(state: Dictionary, player: int, action: String, target: int = -1, model: int = -1, value: String = "") -> Dictionary:
	for candidate: Dictionary in C.UnitActions.choices(state, player):
		if str(candidate.get("action", "")) != action: continue
		if target >= 0 and int(candidate.get("target", -1)) != target: continue
		if model >= 0 and int(candidate.get("model", -1)) != model: continue
		if not value.is_empty() and str(candidate.get("value", "")) != value: continue
		return candidate
	return {}

func run() -> void:
	var profile := Profiles.profile(UNIT)
	check(profile.get("source_book_id") == "000000162" and profile.get("source_datasheet_id") == "000004135" and profile.get("source_snapshot_id") == "20261021T130623Z", "Execrator profile cites the verified Black Templars App datasheet and snapshot")
	check(profile.get("source_manifest_sha256") == "169db99791a91582fd043902303e73c4af83ec63e96c01817ce52cb5ce4deccf" and profile.get("source_slice_manifest_sha256") == "8a6d9529ae553b06203cdb2b6c8f1edd736f2a737ba1c215d2241bd1cdfb5bbe", "Execrator profile records both verified source manifest hashes")
	check(profile.get("points_by_models", {}) == {1: 65} and profile.get("models", 0) == 1 and profile.get("base_size_source_mm", 0) == 40, "The 65-point one-model profile and 40 mm base match the export")
	check(profile.get("stats", {}) == {"movement_inches": 6, "toughness": 5, "save_target": 3, "wounds": 4, "leadership_target": 5, "objective_control": 1, "invulnerable_target": 4}, "Execrator characteristics match the verified export")
	var sorted_keywords: Array = profile.get("keywords", []).duplicate()
	sorted_keywords.sort()
	check(sorted_keywords == ["ADEPTUS ASTARTES", "BLACK TEMPLARS", "CHAPLAIN", "CHARACTER", "EXPLOSIVES", "IMPERIUM", "INFANTRY", "TACTICUS"], "Execrator keywords match the verified export")
	check(profile.get("ranged", [])[0].get("id", "") == "absolvor-bolt-pistol" and profile.ranged[0].profiles.standard == {"name": "Absolvor Bolt Pistol", "range_inches": 18.0, "attacks": 1, "skill": 3, "strength": 5, "ap": -2, "damage": 2, "keywords": {"close-quarters": true}}, "Absolvor Bolt Pistol matches the source profile")
	check(profile.get("melee", [])[0].get("id", "") == "crozius-arcanum" and profile.melee[0].profiles.standard == {"name": "Crozius Arcanum", "range_inches": 0.0, "attacks": 5, "skill": 2, "strength": 6, "ap": -1, "damage": 2, "keywords": {"cleave": 1}}, "Crozius Arcanum matches the source profile")
	var extra_weapon := Profiles.additional_weapon(UNIT, "melee", "master-crafted-power-weapon")
	check(extra_weapon.get("profiles", {}).get("standard", {}).get("keywords", {}) == {"extra-attacks": true, "lethal-hits": true}, "The optional Master-crafted Power Weapon has the source Extra Attacks and Lethal Hits traits")
	check(Catalog.SPECS.get(UNIT, {}).get("current_reference", false) and C.RosterValidation.POINTS.get(UNIT, {}).get("cost", -1) == 65, "The consolidated catalog and roster points admit the 65-point profile")
	check(Catalog.current_catalog_choice({"id": UNIT_ID, "edition": "11e", "faction": "Space Marines"}).get("options", []) == [{"models": 1, "cost": 65}], "The local construction catalog exposes the single-model Execrator profile")
	check(AbilityCatalog.RULES.get(UNIT, []).has("remorseless-persecution") and AbilityCatalog.RULES.get(UNIT, []).has("condemnatory-annihilation") and Registry.KNOWN.get("condemnatory-annihilation", {}).get("supported", false), "Both Execrator abilities are registered as supported rules")
	check(Links.CHAPTER_TARGETS.get(UNIT, []) == ["crusader-squad", "sword-brethren-squad"], "The two source-listed Leader targets are recorded")

	var state := fixture()
	if state.has("error"):
		check(false, "The Black Templars and Wrath of the Rock fixture materializes: %s" % str(state.get("error", "")))
	else:
		var execrator := model_for(state, 1, UNIT)
		var crusader := model_for(state, 1, "crusader-squad")
		var captain_bike := model_for(state, 2, "captain-on-bike")
		var outrider := model_for(state, 2, "outrider-squad")
		var intercessor := model_for(state, 2, "intercessor-squad")
		check(execrator >= 0 and crusader >= 0 and captain_bike >= 0 and outrider >= 0 and intercessor >= 0, "Both current-catalog armies materialize the Execrator, its Leader target and the Tempered bearer")
		var execrator_squad := int(state.units[execrator].get("squad", -1))
		var crusader_squad := int(state.units[crusader].get("squad", -1))
		var enemy_squad := int(state.units[intercessor].get("squad", -1))
		check(C.UnitActions.attachment_allowed(state, execrator, crusader_squad), "Execrator can Lead a source-listed Crusader Squad")
		for failure: String in DatasheetChecks.fixed_weapon_plan_failures(state, profile, execrator, enemy_squad): check(false, "Execrator default weapon plan: " + failure)
		state.squads[execrator_squad].advanced = true
		check(C.Doctrines.charge_error(state, execrator_squad).is_empty(), "Remorseless Persecution allows this Execrator unit to charge after Advancing")
		state.squads[execrator_squad].advanced = false
		state.squads[enemy_squad].advanced = true
		check(not C.Doctrines.charge_error(state, enemy_squad).is_empty(), "Remorseless Persecution does not remove the normal Advance-and-charge restriction from other units")
		state.squads[enemy_squad].advanced = false
		var hand_flamer := option(state, 1, "execrator-pistol-loadout", execrator_squad, execrator, "hand-flamer")
		var hand_result := PublicUnitCommand.submit(state, 1, hand_flamer)
		check(not hand_flamer.is_empty() and str(hand_result.get("error", "")).is_empty() and state.units[execrator].ranged_weapons[0].id == "hand-flamer", "The Hand Flamer replacement is applied through the public preparation command")
		check(option(state, 1, "execrator-extra-melee", execrator_squad, execrator, "on").is_empty(), "The additional Master-crafted Power Weapon is not offered with the Hand Flamer")
		var invalid_extra := C.UnitActions.apply(state, 1, {"action": "execrator-extra-melee", "model": execrator, "target": execrator_squad, "value": "on"}, Vector2.ZERO, Callable())
		check(not str(invalid_extra.get("error", "")).is_empty(), "The Hand Flamer and additional Master-crafted Power Weapon cannot be combined")
		var restore_pistol := option(state, 1, "execrator-pistol-loadout", execrator_squad, execrator, "absolvor-bolt-pistol")
		var restore_result := PublicUnitCommand.submit(state, 1, restore_pistol)
		var add_extra := option(state, 1, "execrator-extra-melee", execrator_squad, execrator, "on")
		var extra_result := PublicUnitCommand.submit(state, 1, add_extra)
		check(str(restore_result.get("error", "")).is_empty() and str(extra_result.get("error", "")).is_empty() and state.units[execrator].ranged_weapons[0].id == "absolvor-bolt-pistol" and state.units[execrator].melee_weapons.size() == 2, "The Absolvor and Crozius remain equipped when the additional melee weapon is selected")
		check(state.units[execrator].melee_weapons.any(func(weapon: Dictionary) -> bool: return weapon.get("id", "") == "master-crafted-power-weapon" and weapon.profiles.standard.keywords.get("extra-attacks", false)), "The additional weapon is preserved as an Extra Attacks profile")
		var blocked_pistol := C.UnitActions.apply(state, 1, {"action": "execrator-pistol-loadout", "model": execrator, "target": execrator_squad, "value": "hand-flamer"}, Vector2.ZERO, Callable())
		check(not str(blocked_pistol.get("error", "")).is_empty() and state.units[execrator].ranged_weapons[0].id == "absolvor-bolt-pistol", "The Absolvor cannot be replaced while the additional Master-crafted Power Weapon is equipped")
		state.units[execrator].position = Vector2.ZERO
		var enemy_squads: Array[int] = [int(state.units[outrider].get("squad", -1)), enemy_squad]
		enemy_squads.sort()
		var first_models := Geometry.alive(state, enemy_squads[0])
		var second_models := Geometry.alive(state, enemy_squads[1])
		for model: int in first_models: state.units[model].position = Vector2(1.0, 20.0 + model)
		for model: int in second_models: state.units[model].position = Vector2(3.0, 20.0 + model)
		state.units[first_models[0]].position = Vector2(1.0, 0.0)
		state.units[second_models[0]].position = Vector2(3.0, 0.0)
		var bearer_squad := int(state.units[captain_bike].get("squad", -1))
		state.units[captain_bike].position = Vector2(9.0, 0.0)
		check(Enhancements.tempered_in_battle_active(state, enemy_squads[0]) and Enhancements.tempered_in_battle_active(state, enemy_squads[1]), "Tempered in Battle applies to both engaged enemy units")
		check(Execrator.engaged_enemy_squads(state, execrator_squad) == enemy_squads, "Only living enemy units within Engagement Range are selected")
		state.squads[enemy_squads[0]].battle_shocked = true
		state.phase = "fight"
		state.active = 1
		state.fight_actor = 1
		state.fight_step = "attacks"
		state.fight_selected = execrator_squad
		state.unit_abilities.window = {}
		dice = [4, 4, 3, 3, 6, 6]
		dice_index = 0
		var committed := C._commit_finished_attack(state, execrator_squad, 1, [], true, {"targets": enemy_squads}, {"killed": 1, "damage": 1, "pools": []}, Callable(self, "die"))
		check(str(committed.get("error", "")).is_empty() and state.unit_abilities.get(Execrator.LAST_KEY, {}).get("results", []).size() == 2, "A Fight kill forces a -1 Battle-shock test for every enemy unit still engaged with the Execrator")
		check(state.squads[enemy_squads[0]].battle_shocked and state.squads[enemy_squads[1]].battle_shocked, "A failed test applies Battle-shock, and an already Battle-shocked unit stays so after a pass")
		check(C.UnitActions.actor(state) == 2, "Each optional Tempered in Battle reroll belongs to the controller of the tested units")
		var first_keep := option(state, 2, Execrator.KEEP_ACTION, enemy_squads[0])
		var first_reroll := option(state, 2, Execrator.REROLL_ACTION, enemy_squads[0])
		var keep_result := C.UnitActions.apply(state, 2, first_keep, Vector2.ZERO, Callable(self, "die"))
		check(not first_keep.is_empty() and not first_reroll.is_empty() and str(keep_result.get("error", "")).is_empty() and state.squads[enemy_squads[0]].battle_shocked, "The target controller can keep a passing result without clearing existing Battle-shock")
		var second_reroll := option(state, 2, Execrator.REROLL_ACTION, enemy_squads[1])
		var reroll_result := C.UnitActions.apply(state, 2, second_reroll, Vector2.ZERO, Callable(self, "die"))
		check(not second_reroll.is_empty() and str(reroll_result.get("error", "")).is_empty() and state.squads[enemy_squads[1]].battle_shocked == false and dice_index == 6, "Tempered in Battle re-rolls both dice at -1 and a passing replacement clears newly applied Battle-shock")
		check(state.unit_abilities.get(Execrator.LAST_KEY, {}).get("results", [])[1].get("rerolled_from", []) == [3, 3], "The original test and replacement roll are retained in the combat record")

		var quiet_state := fixture()
		if not quiet_state.has("error"):
			var quiet_execrator := model_for(quiet_state, 1, UNIT)
			var quiet_squad := int(quiet_state.units[quiet_execrator].squad)
			for model: int in quiet_state.units:
				if int(quiet_state.units[model].get("owner", -1)) == 2: quiet_state.units[model].position = Vector2(20.0 + model, 20.0)
			var no_kill := Execrator.after_fight_kill(quiet_state, quiet_squad, true, 0, Callable())
			var no_engagement := Execrator.after_fight_kill(quiet_state, quiet_squad, true, 1, Callable())
			check(no_kill.get("results", []).is_empty() and no_engagement.get("results", []).is_empty(), "No test occurs without a Fight-phase kill or a living engaged enemy unit")

	if failures == 0: print("test_execrator: OK")
	else: push_error("test_execrator: %d failure(s)" % failures)
	quit(0 if failures == 0 else 1)
