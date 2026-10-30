extends SceneTree

const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Catalog = preload("res://scripts/edition_11/army_capabilities.gd")
const CapabilityRegistry = preload("res://scripts/edition_11/capabilities.gd")
const Abilities = preload("res://scripts/edition_11/unit_ability_catalog.gd")
const LeaderLinks = preload("res://scripts/edition_11/marine_leader_links.gd")
const Detection = preload("res://scripts/edition_11/detection_rules.gd")
const DatasheetChecks = preload("res://tests/space_marine_datasheet_checks.gd")
const PublicUnitCommand = preload("res://tests/public_unit_command.gd")

const UNIT := "spectrus-kill-team"
const UNIT_ID := "40kdc:11e:adeptus-astartes:spectrus-kill-team"

var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func entry(identity: String, models: int = 1, copies: int = 1) -> Dictionary:
	return {"definition_id": "40kdc:11e:adeptus-astartes:" + identity, "models": models, "copies": copies}

func lists() -> Dictionary:
	var result := F.current_marine_selections()
	for owner: int in [1, 2]:
		result[owner].category = "custom"
		result[owner].points_limit = 3000
	result[1].entries = [entry(UNIT, 10), entry("captain-in-phobos-armour"), entry("lieutenant-in-phobos-armour"), entry("librarian-in-phobos-armour")]
	result[2].entries = [entry("intercessor-squad", 5), entry("repulsor")]
	return result

func fixture() -> Dictionary:
	return F.P.initial_state({"checked_rosters": false, "official_mission": false, "unit_abilities": true, "combat_doctrines": true, "core_stratagems": true, "marine_chapters": {1: "DEATHWATCH", 2: "DEATHWATCH"}}, lists())

func find_squad(state: Dictionary, owner: int, identity: String) -> int:
	for model: int in state.units:
		if int(state.units[model].get("owner", -1)) == owner and C.UnitAbilities.identity(state.units[model]) == identity:
			return int(state.units[model].get("squad", -1))
	return -1

func models_for(state: Dictionary, squad: int, identity: String = UNIT) -> Array[int]:
	var result: Array[int] = []
	for model: int in state.units:
		if int(state.units[model].get("squad", -1)) == squad and C.UnitAbilities.identity(state.units[model]) == identity: result.append(model)
	result.sort()
	return result

func model_at_index(state: Dictionary, squad: int, index: int) -> int:
	for model: int in models_for(state, squad):
		if int(state.units[model].get("spectrus_kill_team_model", -1)) == index: return model
	return -1

func profile_weapon(category: String, weapon_id: String, mode: String = "standard") -> Dictionary:
	var profile := Profiles.profile(UNIT)
	for weapon: Dictionary in profile.get(category, []):
		if str(weapon.get("id", "")) == weapon_id: return weapon.get("profiles", {}).get(mode, {})
	return {}

func check_weapon_profiles(category: String, expected: Dictionary) -> void:
	for weapon_id: String in expected:
		check(profile_weapon(category, weapon_id) == expected[weapon_id], "%s profile matches the verified local export" % weapon_id)

func find_choice(state: Dictionary, owner: int, action: String, squad: int, model: int, value: String) -> Dictionary:
	for option: Dictionary in C.UnitActions.choices(state, owner):
		if str(option.get("action", "")) == action and int(option.get("target", -1)) == squad and int(option.get("model", -1)) == model and str(option.get("value", "")) == value: return option
	return {}

func choose(state: Dictionary, owner: int, action: String, squad: int, model: int, value: String) -> Dictionary:
	return PublicUnitCommand.submit(state, owner, find_choice(state, owner, action, squad, model, value))

func weapon_ids(unit: Dictionary, category: String) -> Array[String]:
	var result: Array[String] = []
	for weapon: Dictionary in unit.get(category + "_weapons", []): result.append(str(weapon.get("id", "")))
	return result

func equipment_attack_plan_failures(state: Dictionary, model: int, target_squad: int) -> Array[String]:
	var unit: Dictionary = state.units[model]
	return DatasheetChecks.fixed_weapon_plan_failures(state, {"ranged": unit.get("ranged_weapons", []), "melee": unit.get("melee_weapons", [])}, model, target_squad)

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var profile := Profiles.profile(UNIT)
	check(profile.get("name") == "Spectrus Kill Team" and profile.get("source_book_id") == "000000035" and profile.get("source_datasheet_id") == "000002779", "The profile maps to the current Deathwatch App datasheet")
	check(profile.get("source_snapshot_id") == "20261021T130623Z" and profile.get("source_manifest_sha256") == "169db99791a91582fd043902303e73c4af83ec63e96c01817ce52cb5ce4deccf" and profile.get("source_slice_manifest_sha256") == "4290befd02adf74ce1500df2c2425f9cb81b87d4d4b62fc0f9a39b17e3f05ade", "The source export and Spectrus slice are pinned by their verified hashes")
	check(profile.get("points_by_models", {}) == {10: 185} and profile.get("third_plus_points_by_models", {}) == {10: 195} and profile.get("models", 0) == 10 and profile.get("base_size_source_mm", 0) == 32, "The fixed ten-model composition, 32 mm bases and source copy-price tiers are recorded")
	check(profile.get("stats", {}) == {"movement_inches": 8, "toughness": 4, "save_target": 3, "wounds": 2, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 0}, "The shared characteristics match the four exported Infiltrator roles")
	check(profile.get("model_loadouts", []).map(func(row: Dictionary) -> String: return str(row.get("role", ""))) == ["sniper-infiltrator", "sniper-infiltrator", "oculus-infiltrator", "oculus-infiltrator", "special-issue-infiltrator", "special-issue-infiltrator", "marksman-infiltrator", "marksman-infiltrator", "marksman-infiltrator", "marksman-infiltrator"], "The profile preserves the fixed 2/2/2/4 model-role composition")
	check(profile.get("keywords", []) == ["ADEPTUS ASTARTES", "DEATHWATCH", "INFANTRY", "IMPERIUM", "SMOKE", "EXPLOSIVES", "KILL TEAM", "PHOBOS"], "The profile retains each source-listed unit keyword")
	check_weapon_profiles("ranged", {
		"bolt-pistol": {"name": "Bolt Pistol", "range_inches": 12.0, "attacks": 1, "skill": 3, "strength": 5, "ap": -1, "damage": 1, "keywords": {"close-quarters": true}},
		"bolt-sniper-rifle": {"name": "Bolt Sniper Rifle", "range_inches": 36.0, "attacks": 1, "skill": 3, "strength": 6, "ap": -2, "damage": 3, "keywords": {"precision": true, "heavy": true}},
		"deathwatch-bolt-carbine": {"name": "Deathwatch Bolt Carbine", "range_inches": 24.0, "attacks": 2, "skill": 3, "strength": 5, "ap": -1, "damage": 1, "keywords": {"precision": true, "lethal-hits": true}},
		"deathwatch-marksman-bolt-carbine": {"name": "Deathwatch Marksman Bolt Carbine", "range_inches": 24.0, "attacks": 2, "skill": 3, "strength": 5, "ap": -1, "damage": 1, "keywords": {"heavy": true, "lethal-hits": true}},
		"deathwatch-occulus-bolt-carbine": {"name": "Deathwatch Occulus Bolt Carbine", "range_inches": 24.0, "attacks": 2, "skill": 3, "strength": 5, "ap": -1, "damage": 1, "keywords": {"assault": true, "ignores-cover": true, "lethal-hits": true}},
		"instigator-bolt-carbine": {"name": "Instigator Bolt Carbine", "range_inches": 24.0, "attacks": 2, "skill": 2, "strength": 5, "ap": -2, "damage": 2, "keywords": {"lethal-hits": true, "precision": true, "rapid-fire": 2}, "target_restricted_traits": {"lethal-hits": ["MONSTER", "VEHICLE"]}},
		"las-fusil": {"name": "Las Fusil", "range_inches": 36.0, "attacks": 1, "skill": 3, "strength": 10, "ap": -3, "damage": "D3+3", "keywords": {"heavy": true}},
		"special-issue-bolt-pistol": {"name": "Special-issue Bolt Pistol", "range_inches": 12.0, "attacks": 1, "skill": 3, "strength": 5, "ap": -1, "damage": 1, "keywords": {"close-quarters": true, "precision": true}}
	})
	check_weapon_profiles("melee", {
		"ceramite-fists": {"name": "Ceramite Fists", "range_inches": 0.0, "attacks": 3, "skill": 3, "strength": 5, "ap": 0, "damage": 1, "keywords": {}},
		"combat-knife": {"name": "Combat Knife", "range_inches": 0.0, "attacks": 4, "skill": 3, "strength": 5, "ap": -1, "damage": 1, "keywords": {"precision": true}},
		"paired-combat-blades": {"name": "Paired Combat Blades", "range_inches": 0.0, "attacks": 3, "skill": 3, "strength": 5, "ap": -1, "damage": 1, "keywords": {"sustained-hits": 1}}
	})
	check(Catalog.SPECS.has(UNIT) and Abilities.RULES.get(UNIT, []) == ["infiltrators", "scouts-6", "combat-doctrines", "spectrus-doctrines", "helix-gauntlet"], "The current profile and all declared abilities are registered")
	check(CapabilityRegistry.known("spectrus-doctrines") and CapabilityRegistry.supported("spectrus-doctrines") and CapabilityRegistry.supported("helix-gauntlet"), "Spectrus Doctrines and Helix Gauntlet are exposed as supported capabilities")
	for leader: String in ["captain-in-phobos-armour", "lieutenant-in-phobos-armour", "librarian-in-phobos-armour"]:
		check(UNIT in LeaderLinks.targets(leader), "%s retains its source-listed Spectrus Leader link" % leader)
	var three_copies := Catalog.admit({"schema_version": 2, "faction": "Space Marines", "category": "custom", "points_limit": 1000, "entries": [{"definition_id": UNIT_ID, "models": 10, "copies": 3}]})
	check(three_copies.get("error", "").is_empty() and three_copies.get("total", -1) == 565, "Three copies use 185, 185 and 195 point source tiers")
	var invalid_size := Catalog.admit({"schema_version": 2, "faction": "Space Marines", "category": "custom", "points_limit": 1000, "entries": [entry(UNIT, 5)]})
	check(not str(invalid_size.get("error", "")).is_empty(), "Admission rejects sizes outside the fixed source composition")

	var state := fixture()
	var state_error := str(state.get("error", ""))
	check(state_error.is_empty(), "Spectrus materializes in the local Deathwatch current-catalog forces: " + state_error)
	if not state_error.is_empty():
		print("Spectrus Kill Team source-bounded checks: %d failures" % (failures + 1))
		quit(1)
		return
	var squad := find_squad(state, 1, UNIT)
	var spectrus_models := models_for(state, squad)
	check(spectrus_models.size() == 10 and int(state.squads[squad].get("training_cost", -1)) == 185, "The fixed unit materializes at its 185-point first-copy price")
	for model: int in spectrus_models:
		var unit: Dictionary = state.units[model]
		var source_profile_matches: bool = unit.get("keywords", []) == profile.keywords and int(unit.get("movement", 0)) == 8 and int(unit.get("max_wounds", 0)) == 2 and unit.defense.get("toughness", -1) == 4 and unit.defense.get("save_target", -1) == 3 and is_equal_approx(float(unit.get("radius", 0.0)), 16.0 / 25.4)
		check(source_profile_matches, "Model %d receives the source keywords, characteristics and 32 mm base" % int(unit.spectrus_kill_team_model))
	var captain := find_squad(state, 1, "captain-in-phobos-armour")
	var lieutenant := find_squad(state, 1, "lieutenant-in-phobos-armour")
	var librarian := find_squad(state, 1, "librarian-in-phobos-armour")
	check(C.UnitActions.attachment_allowed(state, C.living(state, captain)[0], squad), "Phobos Captain can attach to Spectrus")
	check(C.UnitActions.attachment_allowed(state, C.living(state, lieutenant)[0], squad), "Phobos Lieutenant can attach to Spectrus")
	check(C.UnitActions.attachment_allowed(state, C.living(state, librarian)[0], squad), "Phobos Librarian can attach to Spectrus")
	var attachment_state := fixture()
	var attachment_squad := find_squad(attachment_state, 1, UNIT)
	var attachment_lieutenant := find_squad(attachment_state, 1, "lieutenant-in-phobos-armour")
	var attachment_lieutenant_model := C.living(attachment_state, attachment_lieutenant)[0]
	var lieutenant_attach_choice := find_choice(attachment_state, 1, "attach", attachment_squad, attachment_lieutenant_model, "")
	var lieutenant_attach_result := PublicUnitCommand.submit(attachment_state, 1, lieutenant_attach_choice)
	check(not lieutenant_attach_choice.is_empty() and lieutenant_attach_result.get("error", "").is_empty() and attachment_state.units[attachment_lieutenant_model].get("attachment_role", "") == "leader", "The Lieutenant's Spectrus-specific Leader link attaches through the public preparation command as a Leader")
	check(Detection.infiltrators(state, squad) and C.UnitAbilities.scout_distance(state, squad) == 6, "Spectrus retains Infiltrators deployment and Scouts 6 movement")
	var sniper := model_at_index(state, squad, 0)
	var intercessors := find_squad(state, 2, "intercessor-squad")
	var repulsor := find_squad(state, 2, "repulsor")
	for model: int in [sniper, model_at_index(state, squad, 2), model_at_index(state, squad, 4), model_at_index(state, squad, 6)]:
		check(equipment_attack_plan_failures(state, model, intercessors).is_empty(), "Default Spectrus role weapons resolve through Equipment and AttackPlan")
	var las_fusil_choice := choose(state, 1, "spectrus-sniper-rifle", squad, sniper, "las-fusil")
	check(las_fusil_choice.get("error", "").is_empty() and weapon_ids(state.units[sniper], "ranged") == ["bolt-pistol", "las-fusil"], "A sniper model can replace its Bolt Sniper Rifle with a Las Fusil")
	check(equipment_attack_plan_failures(state, sniper, intercessors).is_empty(), "The Las Fusil loadout resolves through Equipment and AttackPlan")
	var restore_las_fusil := choose(state, 1, "spectrus-sniper-rifle", squad, sniper, "bolt-sniper-rifle")
	check(restore_las_fusil.get("error", "").is_empty(), "The Las Fusil replacement can be reversed to the Bolt Sniper Rifle")
	var instigator_choice := choose(state, 1, "spectrus-sniper-rifle", squad, sniper, "instigator-bolt-carbine")
	check(instigator_choice.get("error", "").is_empty() and weapon_ids(state.units[sniper], "ranged").has("instigator-bolt-carbine"), "A sniper model can replace its Bolt Sniper Rifle with an Instigator Bolt Carbine")
	check(equipment_attack_plan_failures(state, sniper, intercessors).is_empty(), "The Instigator loadout resolves through Equipment and AttackPlan")
	var instigator: Dictionary = state.units[sniper].ranged_weapons[1].profiles.standard
	check(C.UnitAbilities.weapon(state, sniper, intercessors, instigator, false).keywords.get("lethal-hits", false) and not C.UnitAbilities.weapon(state, sniper, repulsor, instigator, false).keywords.has("lethal-hits"), "The Instigator's Lethal Hits apply to non-MONSTER/non-VEHICLE targets only")
	var restore_sniper := choose(state, 1, "spectrus-sniper-rifle", squad, sniper, "bolt-sniper-rifle")
	check(restore_sniper.get("error", "").is_empty() and weapon_ids(state.units[sniper], "ranged") == ["bolt-pistol", "bolt-sniper-rifle"], "The sniper replacement can be reversed to its source default")
	var special_issue := model_at_index(state, squad, 4)
	var knife_swap := choose(state, 1, "spectrus-combat-knife", squad, special_issue, "on")
	check(knife_swap.get("error", "").is_empty() and weapon_ids(state.units[special_issue], "ranged") == ["special-issue-bolt-pistol", "deathwatch-bolt-carbine"] and weapon_ids(state.units[special_issue], "melee") == ["ceramite-fists"], "Replacing Combat Knife adds the Deathwatch Bolt Carbine and Ceramite Fists")
	check(equipment_attack_plan_failures(state, special_issue, intercessors).is_empty(), "The Deathwatch Bolt Carbine and Ceramite Fists resolve through Equipment and AttackPlan")
	var restore_knife := choose(state, 1, "spectrus-combat-knife", squad, special_issue, "off")
	check(restore_knife.get("error", "").is_empty() and weapon_ids(state.units[special_issue], "ranged") == ["special-issue-bolt-pistol"] and weapon_ids(state.units[special_issue], "melee") == ["combat-knife"], "The Combat Knife replacement restores the source loadout")
	var marksman := model_at_index(state, squad, 6)
	var second_marksman := model_at_index(state, squad, 7)
	var helix := choose(state, 1, "spectrus-helix-gauntlet", squad, marksman, "on")
	check(helix.get("error", "").is_empty() and weapon_ids(state.units[marksman], "ranged") == ["bolt-pistol"] and C.UnitAbilities.has(state, squad, "helix-gauntlet"), "The selected Helix bearer replaces its Marksman Carbine and activates the unit heal")
	check(equipment_attack_plan_failures(state, marksman, intercessors).is_empty(), "The Helix bearer loadout resolves through Equipment and AttackPlan")
	check(find_choice(state, 1, "spectrus-helix-gauntlet", squad, second_marksman, "on").is_empty(), "The unit withholds a second Helix Gauntlet choice")
	var forged_helix := {"action": "spectrus-helix-gauntlet", "model": second_marksman, "target": squad, "value": "on"}
	var before_forged_helix := var_to_bytes(state)
	check(not PublicUnitCommand.error(state, 1, forged_helix).is_empty() and before_forged_helix == var_to_bytes(state), "A forged second Helix choice is rejected without changing state")
	var undo_helix := choose(state, 1, "spectrus-helix-gauntlet", squad, marksman, "off")
	check(undo_helix.get("error", "").is_empty() and not C.UnitAbilities.has(state, squad, "helix-gauntlet") and weapon_ids(state.units[marksman], "ranged") == ["bolt-pistol", "deathwatch-marksman-bolt-carbine"], "The Helix replacement reverses to the source Marksman Bolt Carbine")
	helio_one(state, squad, marksman)

	state.phase = "fight"
	state.active = 2
	state.unit_abilities.window = {}
	state.unit_abilities.end_done = ""
	for model: int in spectrus_models: state.units[model].position = Vector2(-18.0, 0.0)
	for model: int in C.living(state, intercessors) + C.living(state, repulsor): state.units[model].position = Vector2(18.0, 0.0)
	check(squad in C.UnitActions.spectrus_doctrine_squads(state, 1), "An unengaged Spectrus unit is eligible at the end of the opponent's Fight phase")
	var out_of_range_position: Vector2 = state.units[C.living(state, intercessors)[0]].position
	state.units[model_at_index(state, squad, 0)].position = out_of_range_position
	check(squad not in C.UnitActions.spectrus_doctrine_squads(state, 1), "An engaged Spectrus unit cannot use Spectrus Doctrines")
	state.units[model_at_index(state, squad, 0)].position = Vector2(-18.0, 0.0)
	state.unit_abilities.end_done = ""
	check(C.UnitActions.open_end(state), "The opponent's Fight-phase close opens an optional ability window")
	var reserve_choice := find_choice(state, 1, "spectrus-doctrines-reserve", squad, -1, "")
	var reserve_result := PublicUnitCommand.submit(state, 1, reserve_choice)
	check(not reserve_choice.is_empty() and reserve_result.get("error", "").is_empty() and state.unit_abilities.reserves.get(squad, {}).get("source", "") == "spectrus-doctrines", "Spectrus Doctrines places the unit into the shared Strategic Reserves state")
	for model: int in spectrus_models: check(not state.units[model].get("on_battlefield", true), "Spectrus model %d leaves the battlefield with its unit" % model)

	print("Spectrus Kill Team source-bounded checks: %d failures" % failures)
	quit(1 if failures else 0)

func helio_one(state: Dictionary, squad: int, model: int) -> void:
	var chosen := choose(state, 1, "spectrus-helix-gauntlet", squad, model, "on")
	if not chosen.get("error", "").is_empty():
		check(false, "Helix can be equipped after restoring the source loadout: " + str(chosen.get("error", "")))
		return
	state.units[model].wounds = 1
	state.phase = "command"
	state.active = 1
	state.unit_abilities.window = {}
	state.unit_abilities.setup_players = [1, 2]
	state.unit_abilities.phase_key = C.UnitActions.key(state)
	C.Doctrines.select_doctrine(state, 1, "none")
	check(C.UnitActions.offer_command_healing(state), "The active Command phase offers Helix healing for the wounded Spectrus unit")
	var heal_choice := find_choice(state, 1, "helix-heal", squad, model, "")
	var heal_start := PublicUnitCommand.submit(state, 1, heal_choice, Vector2.ZERO, func() -> int: return 1)
	check(not heal_choice.is_empty() and heal_start.get("error", "").is_empty() and state.units[model].wounds == 1 and int(state.unit_abilities.window.get("wounds", {}).get(model, -1)) == 2, "Helix previews the D3 healing without changing the model before confirmation")
	var confirm: Dictionary = {}
	for option: Dictionary in C.UnitActions.choices(state, 1):
		if str(option.get("action", "")) == "heal-confirm": confirm = option
	var heal_confirm := PublicUnitCommand.submit(state, 1, confirm)
	check(not confirm.is_empty() and heal_confirm.get("error", "").is_empty() and state.unit_abilities.window.is_empty() and state.units[model].wounds == 2, "The player confirms the bounded Helix healing decision")
